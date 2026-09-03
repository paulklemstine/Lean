import Mathlib
import Probability.PPowMultiseedVonMangoldt

/-!
# Seed stability: the prime-power lift depends on the window, not on the seed

Fourth cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  The
experiment reports five seeds `20260940–44` whose lifts at `(u = 3.5, w = 240)`
are `+0.055 / +0.049 / +0.051 / +0.050 / +0.048`: a cross-seed sd of `0.0025`,
an order of magnitude below the lift itself.  Modelling a seed by the *offset*
of the window, this file proves the deterministic analogue: the prime-power mass
of a window of length `w` is `w · (prime-power density) + O(prime-power total)`,
where the error term is *independent of the offset*, so any two seeds differ by
at most twice that error, no matter where their windows sit.

* `ppDensity M = ∑_{d ≤ M} ppWeight d / d` — the prime-power density
  (an increasing partial sum of `∑_p log p / (p(p-1))`).
* `ppTotal M = ∑_{d ≤ M} ppWeight d` — the total prime-power weight below `M`;
  it is supported on the `p^k` with `k ≥ 2` only, of which there are at most
  `√M · log₂ M` (`card_ppSupport_le`), so it is a genuinely small error term.
* `windowMass_sub_density_le` — **the seed-uniform window law**:
  `|windowMass a w - w · ppDensity M| ≤ ppTotal M` for every offset `a ≥ 1`
  whose window fits below `M`.
* `windowMass_seed_dispersion` — **cross-seed stability**: any two offsets
  `a, b` give lifts differing by at most `2 · ppTotal M`, while the common main
  term is linear in `w`.  This is the exact analogue of "sd `0.0025` versus
  lift `0.05`".
-/

namespace PPowMultiseed

open Finset ArithmeticFunction

/-- The prime-power density below `M`: the partial sums of `∑_p log p/(p(p-1))`. -/
noncomputable def ppDensity (M : ℕ) : ℝ := ∑ d ∈ Finset.Icc 1 M, ppWeight d / (d : ℝ)

/-- The total prime-power weight below `M` (a Chebyshev `ψ - θ` quantity). -/
noncomputable def ppTotal (M : ℕ) : ℝ := ∑ d ∈ Finset.Icc 1 M, ppWeight d

lemma ppTotal_nonneg (M : ℕ) : 0 ≤ ppTotal M :=
  Finset.sum_nonneg fun d _ => ppWeight_nonneg d

/-- The exact window law, with the summation range enlarged to any `M ≥ N`
(the extra terms vanish because `⌊N/d⌋ = 0` for `d > N`). -/
theorem ppMass_eq_sum_extended {N M : ℕ} (h : N ≤ M) :
    windowMass 1 N = ∑ d ∈ Finset.Icc 1 M, ppWeight d * ((N / d : ℕ) : ℝ) := by
  rw [ppMass_eq_sum_ppWeight_mul_div]
  refine Finset.sum_subset (fun d hd => ?_) (fun d hdM hd => ?_)
  · simp only [Finset.mem_Icc] at hd ⊢
    exact ⟨hd.1, le_trans hd.2 h⟩
  · simp only [Finset.mem_Icc, not_and, not_le] at hd
    simp only [Finset.mem_Icc] at hdM
    have hzero : N / d = 0 := Nat.div_eq_of_lt (hd hdM.1)
    simp [hzero]

/-- Splitting a window off the initial segment. -/
theorem windowMass_eq_sub {a w : ℕ} (ha : 1 ≤ a) :
    windowMass a w = windowMass 1 (a - 1 + w) - windowMass 1 (a - 1) := by
  have h := windowMass_add 1 (a - 1) w
  have hrw : 1 + (a - 1) = a := by omega
  rw [hrw] at h
  linarith

/-- **The seed-uniform window law.**  For every offset `a ≥ 1` whose window fits
below `M`, the prime-power mass of `[a, a+w)` is `w · ppDensity M` up to an error
of at most `ppTotal M`, *independently of the offset*. -/
theorem windowMass_sub_density_le {a w M : ℕ} (ha : 1 ≤ a) (hM : a - 1 + w ≤ M) :
    |windowMass a w - w * ppDensity M| ≤ ppTotal M := by
  classical
  set A := a - 1 with hA
  have hAM : A ≤ M := by omega
  have h1 : windowMass 1 (A + w) = ∑ d ∈ Finset.Icc 1 M, ppWeight d * (((A + w) / d : ℕ) : ℝ) :=
    ppMass_eq_sum_extended hM
  have h2 : windowMass 1 A = ∑ d ∈ Finset.Icc 1 M, ppWeight d * ((A / d : ℕ) : ℝ) :=
    ppMass_eq_sum_extended hAM
  have hsplit : windowMass a w - w * ppDensity M
      = ∑ d ∈ Finset.Icc 1 M,
          ppWeight d * ((((A + w) / d : ℕ) : ℝ) - ((A / d : ℕ) : ℝ) - (w : ℝ) / d) := by
    rw [windowMass_eq_sub ha, ← hA, h1, h2, ppDensity, Finset.mul_sum, ← Finset.sum_sub_distrib,
      ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun d _ => ?_
    field_simp
  rw [hsplit]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
  refine Finset.sum_le_sum fun d hd => ?_
  simp only [Finset.mem_Icc] at hd
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd.1
  have hdivmod1 : d * ((A + w) / d) + (A + w) % d = A + w := Nat.div_add_mod _ _
  have hdivmod2 : d * (A / d) + A % d = A := Nat.div_add_mod _ _
  have hmod1 : (A + w) % d < d := Nat.mod_lt _ (by exact_mod_cast hd.1)
  have hmod2 : A % d < d := Nat.mod_lt _ (by exact_mod_cast hd.1)
  have hc1 : (d : ℝ) * (((A + w) / d : ℕ) : ℝ) + (((A + w) % d : ℕ) : ℝ) = (A : ℝ) + w := by
    exact_mod_cast congrArg (fun t : ℕ => (t : ℝ)) hdivmod1
  have hc2 : (d : ℝ) * ((A / d : ℕ) : ℝ) + ((A % d : ℕ) : ℝ) = (A : ℝ) := by
    exact_mod_cast congrArg (fun t : ℕ => (t : ℝ)) hdivmod2
  have hkey : (((A + w) / d : ℕ) : ℝ) - ((A / d : ℕ) : ℝ) - (w : ℝ) / d
      = (((A % d : ℕ) : ℝ) - (((A + w) % d : ℕ) : ℝ)) / d := by
    field_simp
    linarith
  have hbound : |(((A % d : ℕ) : ℝ) - (((A + w) % d : ℕ) : ℝ)) / d| ≤ 1 := by
    rw [abs_div, abs_of_pos hdpos, div_le_one hdpos, abs_le]
    have h1' : ((A % d : ℕ) : ℝ) < d := by exact_mod_cast hmod2
    have h2' : (((A + w) % d : ℕ) : ℝ) < d := by exact_mod_cast hmod1
    have h3' : (0 : ℝ) ≤ ((A % d : ℕ) : ℝ) := by positivity
    have h4' : (0 : ℝ) ≤ (((A + w) % d : ℕ) : ℝ) := by positivity
    constructor <;> linarith
  rw [abs_mul, abs_of_nonneg (ppWeight_nonneg d), hkey]
  calc ppWeight d * |(((A % d : ℕ) : ℝ) - (((A + w) % d : ℕ) : ℝ)) / d|
      ≤ ppWeight d * 1 := by
        exact mul_le_mul_of_nonneg_left hbound (ppWeight_nonneg d)
    _ = ppWeight d := by ring

/-- **Cross-seed stability.**  Two windows of the same length `w` placed at
*arbitrary* offsets `a` and `b` carry prime-power masses differing by at most
`2 · ppTotal M`, while the shared main term `w · ppDensity M` is linear in `w`.
The dispersion across seeds is therefore controlled by a quantity that does not
grow with `w` at all. -/
theorem windowMass_seed_dispersion {a b w M : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (hMa : a - 1 + w ≤ M) (hMb : b - 1 + w ≤ M) :
    |windowMass a w - windowMass b w| ≤ 2 * ppTotal M := by
  have h1 := windowMass_sub_density_le ha hMa
  have h2 := windowMass_sub_density_le hb hMb
  have := abs_sub_abs_le_abs_sub (windowMass a w - w * ppDensity M)
    (windowMass b w - w * ppDensity M)
  have key : |(windowMass a w - w * ppDensity M) - (windowMass b w - w * ppDensity M)|
      ≤ |windowMass a w - w * ppDensity M| + |windowMass b w - w * ppDensity M| :=
    abs_sub _ _
  have hsimp : (windowMass a w - w * ppDensity M) - (windowMass b w - w * ppDensity M)
      = windowMass a w - windowMass b w := by ring
  rw [hsimp] at key
  linarith

/-! ## The error term is small: counting the higher prime powers -/

/-- The support of `ppWeight` inside `[1, M]`. -/
noncomputable def ppSupport (M : ℕ) : Finset ℕ :=
  {d ∈ Finset.Icc 1 M | ppWeight d ≠ 0}

/-- **There are few higher prime powers.**  Every `d ≤ M` with `ppWeight d ≠ 0`
is a `p^k` with `k ≥ 2`, hence `p ≤ √M` and `k ≤ log₂ M`; the map `d ↦ (p, k)`
is injective, so `#ppSupport M ≤ √M · (log₂ M + 1)`.  Thus the error term
`ppTotal M` of `windowMass_sub_density_le` is a sum of at most `√M log₂ M`
terms, each at most `log M`: it is sublinear, while the main term is linear in
the window length. -/
theorem card_ppSupport_le (M : ℕ) :
    (ppSupport M).card ≤ Nat.sqrt M * (Nat.log 2 M + 1) := by
  classical
  have hstruct : ∀ d ∈ ppSupport M, ∃ p k : ℕ, p.Prime ∧ 2 ≤ k ∧ d = p ^ k := by
    intro d hd
    simp only [ppSupport, Finset.mem_filter, Finset.mem_Icc] at hd
    obtain ⟨⟨hd1, hdM⟩, hdne⟩ := hd
    have hpp : IsPrimePow d := by
      by_contra hc
      exact hdne (ppWeight_eq_zero_of_not_isPrimePow hc)
    obtain ⟨p, k, hp, hk, hpk⟩ := hpp
    have hpprime : p.Prime := hp.nat_prime
    refine ⟨p, k, hpprime, ?_, by rw [← hpk]⟩
    rcases Nat.lt_or_ge k 2 with hk2 | hk2
    · exfalso
      have hk1 : k = 1 := by omega
      apply hdne
      unfold ppWeight
      rw [if_pos]
      rw [← hpk, hk1, pow_one]
      exact hpprime
    · exact hk2
  have hmap : ∀ d ∈ ppSupport M,
      ((Nat.minFac d, (Nat.factorization d) (Nat.minFac d)) : ℕ × ℕ) ∈
        Finset.Icc 1 (Nat.sqrt M) ×ˢ Finset.Icc 1 (Nat.log 2 M + 1) := by
    intro d hd
    obtain ⟨p, k, hp, hk, rfl⟩ := hstruct d hd
    have hdM : p ^ k ≤ M := by
      simp only [ppSupport, Finset.mem_filter, Finset.mem_Icc] at hd
      exact hd.1.2
    have hmin : (p ^ k).minFac = p := Nat.Prime.pow_minFac hp (by omega)
    have hfac : (p ^ k).factorization p = k := by
      rw [Nat.Prime.factorization_pow hp]; simp
    have hpsq : p * p ≤ M := by
      have h1 : p ^ 2 ≤ p ^ k := Nat.pow_le_pow_right hp.pos hk
      calc p * p = p ^ 2 := by ring
        _ ≤ p ^ k := h1
        _ ≤ M := hdM
    have hple : p ≤ Nat.sqrt M := Nat.le_sqrt.2 hpsq
    have h2k : (2 : ℕ) ^ k ≤ M := le_trans (Nat.pow_le_pow_left hp.two_le k) hdM
    have hkle : k ≤ Nat.log 2 M := Nat.le_log_of_pow_le (by norm_num) h2k
    simp only [Finset.mem_product, Finset.mem_Icc, hmin, hfac]
    exact ⟨⟨hp.pos, hple⟩, ⟨by omega, by omega⟩⟩
  have hinj : Set.InjOn
      (fun d : ℕ => ((Nat.minFac d, (Nat.factorization d) (Nat.minFac d)) : ℕ × ℕ))
      ↑(ppSupport M) := by
    intro d₁ h₁ d₂ h₂ heq
    simp only [Finset.mem_coe] at h₁ h₂
    obtain ⟨p, k, hp, hk, rfl⟩ := hstruct d₁ h₁
    obtain ⟨q, l, hq, hl, rfl⟩ := hstruct d₂ h₂
    simp only [Nat.Prime.pow_minFac hp (by omega : k ≠ 0),
      Nat.Prime.pow_minFac hq (by omega : l ≠ 0), Prod.mk.injEq] at heq
    obtain ⟨hpq, hkl⟩ := heq
    subst hpq
    rw [Nat.Prime.factorization_pow hp, Nat.Prime.factorization_pow hp] at hkl
    simp at hkl
    rw [hkl]
  have hcard := Finset.card_le_card_of_injOn _
    (fun d hd => Finset.mem_coe.2 (hmap d (Finset.mem_coe.1 hd))) hinj
  calc (ppSupport M).card
      ≤ (Finset.Icc 1 (Nat.sqrt M) ×ˢ Finset.Icc 1 (Nat.log 2 M + 1)).card := hcard
    _ = Nat.sqrt M * (Nat.log 2 M + 1) := by
        rw [Finset.card_product, Nat.card_Icc, Nat.card_Icc]
        simp

/-- The error term is a sum over the (few) higher prime powers only. -/
theorem ppTotal_eq_sum_ppSupport (M : ℕ) :
    ppTotal M = ∑ d ∈ ppSupport M, ppWeight d := by
  classical
  unfold ppTotal ppSupport
  rw [Finset.sum_filter_ne_zero]

end PPowMultiseed