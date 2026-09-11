import Combinatorics.PlateauRungBudget

/-!
# Two-sided plateau identification: what a *lower* deceleration bound buys

## Research context

`Catalog.Combinatorics.PlateauRungBudget` shows that with a one-sided deceleration bound
`d_{n+1} ≤ r·d_n` a measured prefix pins the plateau to an interval of length `r·dₘ/(1−r)`,
whose right endpoint is the last measured value itself: the *upper* edge of the plateau is
never improved by further rungs, only the lower edge moves.

This file asks what happens when the experiment also certifies a **lower** deceleration
bound `rmin·d_n ≤ d_{n+1}` — that is, when the fade is known not to stop abruptly.  The
answer is a genuinely two-sided identification:

`twoSidedPlateauSet_eq_Icc` : the admissible plateaus after the prefix `p 0, …, p (m+1)` are
*exactly*

`[p (m+1) − rmax·dₘ/(1−rmax),  p (m+1) − rmin·dₘ/(1−rmin)]`,

an interval of length `dₘ·(rmax − rmin)/((1−rmax)(1−rmin))` (`twoSidedPlateauLength_eq`).

Consequences.

* `twoSided_length_lt_oneSided` — a lower bound strictly shortens the admissible interval
  as soon as `rmin > 0`: two-sided information is never wasted.
* `u108_two_sided_window` — at the U108 numbers with `rmin = 2/5`, `rmax = 1/2` the
  interval already has length `0.0259/3 < 0.0087`, five times inside the CI half-width
  `0.0445`, without measuring a single further rung.  Combined with
  `PlateauRungBudget.u108_rung_budget_zero` this is the strongest form of the
  "identification is cheap" branch of the dichotomy.
-/

namespace Catalog.Combinatorics.PlateauRungBudget

open Real Set Filter

/-! ## Section 1. Two-sided admissible fades -/

/-- A fade whose decrements contract by a factor in `[rmin, rmax]` at every step. -/
def TwoSidedFade (rmin rmax : ℝ) (s : ℕ → ℝ) : Prop :=
  (∀ n, s (n + 1) ≤ s n) ∧
  (∀ n, rmin * (s n - s (n + 1)) ≤ s (n + 1) - s (n + 2)) ∧
  (∀ n, s (n + 1) - s (n + 2) ≤ rmax * (s n - s (n + 1)))

lemma TwoSidedFade.admissible {rmin rmax : ℝ} {s : ℕ → ℝ} (h : TwoSidedFade rmin rmax s) :
    AdmissibleFade rmax s := ⟨h.1, h.2.2⟩

/-- The two-sided plateau set of a measured prefix. -/
def twoSidedPlateauSet (rmin rmax : ℝ) (p : ℕ → ℝ) (M : ℕ) : Set ℝ :=
  {L | ∃ s : ℕ → ℝ, TwoSidedFade rmin rmax s ∧ (∀ k ≤ M, s k = p k) ∧
        Tendsto s atTop (nhds L)}

/-! ## Section 2. The reverse tail bound -/

/-- Under a lower deceleration bound the steps cannot die out faster than `rmin^k`. -/
lemma twoSided_step_lower {rmin rmax : ℝ} {s : ℕ → ℝ} (h : TwoSidedFade rmin rmax s)
    (hrmin : 0 ≤ rmin) :
    ∀ n k, rmin ^ k * (s n - s (n + 1)) ≤ s (n + k) - s (n + k + 1) := by
  intro n k
  induction k with
  | zero => simp
  | succ k ih =>
      have hstep := h.2.1 (n + k)
      have e : n + (k + 1) = n + k + 1 := by omega
      have e2 : n + k + 1 + 1 = n + k + 2 := by omega
      rw [e, e2]
      calc rmin ^ (k + 1) * (s n - s (n + 1))
          = rmin * (rmin ^ k * (s n - s (n + 1))) := by ring
        _ ≤ rmin * (s (n + k) - s (n + k + 1)) := by
            exact mul_le_mul_of_nonneg_left ih hrmin
        _ ≤ s (n + k + 1) - s (n + k + 2) := hstep

/-- Hence the total remaining drop after index `n` is at least `dₙ · ∑_{j<k} rmin^j`. -/
lemma twoSided_tail_lower {rmin rmax : ℝ} {s : ℕ → ℝ} (h : TwoSidedFade rmin rmax s)
    (hrmin : 0 ≤ rmin) :
    ∀ n k, (s n - s (n + 1)) * (∑ j ∈ Finset.range k, rmin ^ j) ≤ s n - s (n + k) := by
  intro n k
  induction k with
  | zero => simp
  | succ k ih =>
      have hstep := twoSided_step_lower h hrmin n k
      have e : n + (k + 1) = n + k + 1 := by omega
      rw [e, Finset.sum_range_succ]
      have hexp : (s n - s (n + 1)) * ((∑ j ∈ Finset.range k, rmin ^ j) + rmin ^ k)
          = (s n - s (n + 1)) * (∑ j ∈ Finset.range k, rmin ^ j)
            + rmin ^ k * (s n - s (n + 1)) := by ring
      rw [hexp]
      linarith

/-- **Reverse localisation.**  A lower deceleration bound `rmin ∈ [0,1)` forces the plateau to
lie at least `dₙ/(1−rmin)` below the current value. -/
lemma twoSided_limit_lower {rmin rmax L : ℝ} {s : ℕ → ℝ} (h : TwoSidedFade rmin rmax s)
    (hrmin : 0 ≤ rmin) (hrmin1 : rmin < 1) (hlim : Tendsto s atTop (nhds L)) (n : ℕ) :
    (s n - s (n + 1)) / (1 - rmin) ≤ s n - L := by
  have hA : Tendsto (fun k => s n - s (n + k)) atTop (nhds (s n - L)) := by
    have h1 : Tendsto (fun k => s (n + k)) atTop (nhds L) := by
      simpa [Nat.add_comm] using hlim.comp (Filter.tendsto_add_atTop_nat n)
    exact h1.const_sub _
  have hgeom : Tendsto (fun k => ∑ j ∈ Finset.range k, rmin ^ j) atTop (nhds (1 - rmin)⁻¹) :=
    (hasSum_geometric_of_lt_one hrmin hrmin1).tendsto_sum_nat
  have hB : Tendsto (fun k => (s n - s (n + 1)) * (∑ j ∈ Finset.range k, rmin ^ j)) atTop
      (nhds ((s n - s (n + 1)) * (1 - rmin)⁻¹)) := hgeom.const_mul _
  have hle : (s n - s (n + 1)) * (1 - rmin)⁻¹ ≤ s n - L :=
    le_of_tendsto_of_tendsto' hB hA (fun k => twoSided_tail_lower h hrmin n k)
  rwa [div_eq_mul_inv]

/-! ## Section 3. The exact two-sided plateau set -/

/-- The splice with tail ratio `q ∈ [rmin, rmax]` is a two-sided admissible fade. -/
lemma spliceFade_twoSided {rmin rmax q L : ℝ} {p : ℕ → ℝ} {m : ℕ} (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hqlo : rmin ≤ q) (hqhi : q ≤ rmax)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hplo : ∀ k, k + 2 ≤ m + 1 → rmin * (p k - p (k + 1)) ≤ p (k + 1) - p (k + 2))
    (hphi : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ rmax * (p k - p (k + 1)))
    (hD0 : 0 ≤ p (m + 1) - L)
    (hDlo : rmin * (p m - p (m + 1)) ≤ (p (m + 1) - L) * (1 - q))
    (hDhi : (p (m + 1) - L) * (1 - q) ≤ rmax * (p m - p (m + 1))) :
    TwoSidedFade rmin rmax (spliceFade q L p (m + 1)) := by
  have hupper : AdmissibleFade rmax (spliceFade q L p (m + 1)) :=
    spliceFade_admissible hq0 hq1 hqhi hpmono hphi hD0 hDhi
  refine ⟨hupper.1, ?_, hupper.2⟩
  set M := m + 1 with hM
  set D : ℝ := p M - L with hD
  set s := spliceFade q L p M with hs
  have htail : ∀ n, M ≤ n → s n = L + D * q ^ (n - M) := fun n hn => spliceFade_of_le hn
  have hpre : ∀ k, k ≤ M → s k = p k := fun k hk => spliceFade_prefix hk
  intro n
  rcases lt_trichotomy (n + 1) M with hlt | heq | hgt
  · rw [hpre _ (by omega : n + 1 ≤ M), hpre _ (by omega : n + 2 ≤ M),
      hpre _ (by omega : n ≤ M)]
    exact hplo n (by omega)
  · have hnm : n = m := by omega
    subst hnm
    rw [hpre _ (le_refl M), hpre _ (by omega : n ≤ M), htail _ (by omega)]
    have e2 : n + 2 - M = 1 := by omega
    rw [e2, pow_one]
    have hPM : p M = L + D := by rw [hD]; ring
    rw [hPM]
    nlinarith
  · have hn : M ≤ n := by omega
    rw [htail n hn, htail (n + 1) (by omega), htail (n + 2) (by omega)]
    have e1 : n + 1 - M = (n - M) + 1 := by omega
    have e2 : n + 2 - M = (n - M) + 2 := by omega
    have hp1 : q ^ (n - M + 1) = q ^ (n - M) * q := pow_succ q _
    have hp2 : q ^ (n - M + 2) = q ^ (n - M) * q * q := by rw [pow_succ, pow_succ]
    rw [e1, e2, hp1, hp2]
    nlinarith [mul_nonneg (mul_nonneg (mul_nonneg (sub_nonneg.mpr hqlo) hD0)
      (pow_nonneg hq0 (n - M))) (by linarith : (0:ℝ) ≤ 1 - q)]

/-- **Exact two-sided identifiability.**  With deceleration ratios certified in
`[rmin, rmax] ⊆ [0, 1)`, the plateaus consistent with a measured prefix `p 0, …, p (m+1)` are
exactly the points of

`[p (m+1) − rmax·dₘ/(1−rmax), p (m+1) − rmin·dₘ/(1−rmin)]`.

Both edges are attained, by the geometric tails of ratio `rmax` and `rmin` respectively. -/
theorem twoSidedPlateauSet_eq_Icc {rmin rmax : ℝ} {p : ℕ → ℝ} {m : ℕ}
    (hrmin : 0 ≤ rmin) (hr : rmin ≤ rmax) (hrmax : rmax < 1)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hplo : ∀ k, k + 2 ≤ m + 1 → rmin * (p k - p (k + 1)) ≤ p (k + 1) - p (k + 2))
    (hphi : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ rmax * (p k - p (k + 1))) :
    twoSidedPlateauSet rmin rmax p (m + 1)
      = Icc (p (m + 1) - rmax * (p m - p (m + 1)) / (1 - rmax))
            (p (m + 1) - rmin * (p m - p (m + 1)) / (1 - rmin)) := by
  have hrmin1 : rmin < 1 := lt_of_le_of_lt hr hrmax
  have h1max : 0 < 1 - rmax := by linarith
  have h1min : 0 < 1 - rmin := by linarith
  have hdm : 0 ≤ p m - p (m + 1) := by have := hpmono m (le_refl m); linarith
  ext L
  simp only [twoSidedPlateauSet, mem_setOf_eq, mem_Icc]
  constructor
  · rintro ⟨s, hs, hpre, hlim⟩
    have hmemOne : L ∈ plateauSet rmax p (m + 1) :=
      ⟨s, hs.admissible, hpre, hlim⟩
    rw [plateauSet_prefix_eq_Icc (le_trans hrmin hr) hrmax hpmono hphi] at hmemOne
    refine ⟨hmemOne.1, ?_⟩
    -- the reverse bound at index `m+1`
    have hsm : s (m + 1) = p (m + 1) := hpre _ (le_refl _)
    have hsm0 : s m = p m := hpre _ (by omega)
    have hstep : rmin * (p m - p (m + 1)) ≤ p (m + 1) - s (m + 2) := by
      have h := hs.2.1 m
      rw [hsm, hsm0] at h
      exact h
    have hrev : (p (m + 1) - s (m + 2)) / (1 - rmin) ≤ p (m + 1) - L := by
      have h := twoSided_limit_lower hs hrmin hrmin1 hlim (m + 1)
      rw [hsm] at h
      exact h
    rw [div_le_iff₀ h1min] at hrev
    have hchain : rmin * (p m - p (m + 1)) / (1 - rmin) ≤ p (m + 1) - L := by
      rw [div_le_iff₀ h1min]
      linarith
    linarith
  · rintro ⟨hlo, hhi⟩
    have hD0 : 0 ≤ p (m + 1) - L := by
      have : 0 ≤ rmin * (p m - p (m + 1)) / (1 - rmin) :=
        div_nonneg (mul_nonneg hrmin hdm) h1min.le
      linarith
    rcases eq_or_lt_of_le hD0 with hD | hD
    · -- the plateau is the last measured value; possible only if the last step vanished
      have hdm0 : rmin * (p m - p (m + 1)) ≤ 0 := by
        have hle : rmin * (p m - p (m + 1)) / (1 - rmin) ≤ 0 := by linarith
        by_contra hcon
        push_neg at hcon
        have : 0 < rmin * (p m - p (m + 1)) / (1 - rmin) := div_pos hcon h1min
        linarith
      refine ⟨spliceFade rmin L p (m + 1),
        spliceFade_twoSided hrmin hrmin1 (le_refl rmin) hr hpmono hplo hphi hD0 ?_ ?_,
        fun k hk => spliceFade_prefix hk, spliceFade_tendsto hrmin hrmin1⟩
      · nlinarith
      · nlinarith [mul_nonneg (le_trans hrmin hr) hdm]
    · -- generic case: choose the tail ratio `q = D/(D + dₘ)`
      set D : ℝ := p (m + 1) - L with hDdef
      have hdmpos : 0 < p m - p (m + 1) := by
        rcases lt_or_eq_of_le hdm with hpos | hzero
        · exact hpos
        · exfalso
          have hzero' : p m - p (m + 1) = 0 := hzero.symm
          have : D ≤ rmax * (p m - p (m + 1)) / (1 - rmax) := by
            rw [hDdef]; linarith
          rw [hzero'] at this
          simp at this
          linarith
      have hsum : 0 < D + (p m - p (m + 1)) := by linarith
      set q : ℝ := D / (D + (p m - p (m + 1))) with hq
      have hq0 : 0 ≤ q := div_nonneg hD.le hsum.le
      have hq1 : q < 1 := by
        rw [hq, div_lt_one hsum]; linarith
      have hqlo : rmin ≤ q := by
        rw [hq, le_div_iff₀ hsum]
        have hDlo : rmin * (p m - p (m + 1)) / (1 - rmin) ≤ D := by rw [hDdef]; linarith
        rw [div_le_iff₀ h1min] at hDlo
        nlinarith
      have hqhi : q ≤ rmax := by
        rw [hq, div_le_iff₀ hsum]
        have hDhi : D ≤ rmax * (p m - p (m + 1)) / (1 - rmax) := by rw [hDdef]; linarith
        rw [le_div_iff₀ h1max] at hDhi
        nlinarith
      have hjunction : D * (1 - q) = (p m - p (m + 1)) * q := by
        rw [hq]
        field_simp
        ring
      refine ⟨spliceFade q L p (m + 1),
        spliceFade_twoSided hq0 hq1 hqlo hqhi hpmono hplo hphi hD0 ?_ ?_,
        fun k hk => spliceFade_prefix hk, spliceFade_tendsto hq0 hq1⟩
      · rw [← hDdef, hjunction]
        nlinarith
      · rw [← hDdef, hjunction]
        nlinarith

/-! ## Section 4. The two-sided interval length -/

/-- The two-sided admissible plateau interval has length
`dₘ·(rmax − rmin)/((1−rmax)(1−rmin))`. -/
theorem twoSidedPlateauLength_eq {rmin rmax : ℝ} {p : ℕ → ℝ} {m : ℕ}
    (hrmin1 : rmin < 1) (hrmax : rmax < 1) :
    (p (m + 1) - rmin * (p m - p (m + 1)) / (1 - rmin))
      - (p (m + 1) - rmax * (p m - p (m + 1)) / (1 - rmax))
      = (p m - p (m + 1)) * (rmax - rmin) / ((1 - rmax) * (1 - rmin)) := by
  have h1 : (1 : ℝ) - rmin ≠ 0 := by linarith
  have h2 : (1 : ℝ) - rmax ≠ 0 := by linarith
  field_simp
  ring

/-- **A lower deceleration bound is never wasted.**  As soon as `rmin > 0` and the last
measured step is positive, the two-sided interval is strictly shorter than the one-sided one
`rmax·dₘ/(1−rmax)`. -/
theorem twoSided_length_lt_oneSided {rmin rmax dm : ℝ} (hrmin : 0 < rmin) (hr : rmin ≤ rmax)
    (hrmax : rmax < 1) (hdm : 0 < dm) :
    dm * (rmax - rmin) / ((1 - rmax) * (1 - rmin)) < rmax * dm / (1 - rmax) := by
  have hrmin1 : rmin < 1 := lt_of_le_of_lt hr hrmax
  have h1 : 0 < 1 - rmin := by linarith
  have h2 : 0 < 1 - rmax := by linarith
  rw [div_lt_div_iff₀ (by positivity) h2]
  nlinarith [mul_pos hrmin hdm, mul_pos h2 h2]

/-- The two-sided interval width after a prefix ending at index `m+1`. -/
noncomputable def twoSidedPlateauLength (rmin rmax : ℝ) (p : ℕ → ℝ) (m : ℕ) : ℝ :=
  (p m - p (m + 1)) * (rmax - rmin) / ((1 - rmax) * (1 - rmin))

/-- **The two-sided contraction rate is only bracketed, never pinned.**  Each further rung
shrinks the two-sided interval by a factor lying in `[rmin, rmax]`, and both extremes occur
(the geometric ladders of ratio `rmin` and `rmax` realise them).  This is the two-sided
refinement of `plateauLength_geoFade_contracts`: with one-sided information the worst-case
factor is exactly `rmax`; with two-sided information the factor is itself only known up to
the measured ratio window. -/
theorem twoSided_contraction_bounds {rmin rmax : ℝ} {p : ℕ → ℝ} {m : ℕ}
    (hr : rmin ≤ rmax) (hrmax : rmax < 1)
    (hlo : rmin * (p m - p (m + 1)) ≤ p (m + 1) - p (m + 2))
    (hhi : p (m + 1) - p (m + 2) ≤ rmax * (p m - p (m + 1))) :
    rmin * twoSidedPlateauLength rmin rmax p m ≤ twoSidedPlateauLength rmin rmax p (m + 1) ∧
      twoSidedPlateauLength rmin rmax p (m + 1)
        ≤ rmax * twoSidedPlateauLength rmin rmax p m := by
  have hrmin1 : rmin < 1 := lt_of_le_of_lt hr hrmax
  have h1max : 0 < 1 - rmax := by linarith
  have h1min : 0 < 1 - rmin := by linarith
  have hden : 0 < (1 - rmax) * (1 - rmin) := mul_pos h1max h1min
  have hC : 0 ≤ (rmax - rmin) / ((1 - rmax) * (1 - rmin)) :=
    div_nonneg (by linarith) hden.le
  constructor
  · have h := mul_le_mul_of_nonneg_right hlo hC
    simp only [twoSidedPlateauLength, div_eq_mul_inv] at *
    nlinarith [h]
  · have h := mul_le_mul_of_nonneg_right hhi hC
    simp only [twoSidedPlateauLength, div_eq_mul_inv] at *
    nlinarith [h]

/-- **The U108 two-sided window.**  With the measured `d₀ = 0.0259` and ratios certified in
`[2/5, 1/2]`, the admissible plateau interval already has length `0.0259/3 < 0.0087`, well
inside the U108 CI half-width `0.0445` — and this without any further rung. -/
theorem u108_two_sided_window :
    (0.0259 : ℝ) * (1/2 - 2/5) / ((1 - 1/2) * (1 - 2/5)) < 87/10000 ∧
      (0.0259 : ℝ) * (1/2 - 2/5) / ((1 - 1/2) * (1 - 2/5)) < 445/10000 := by
  constructor <;> norm_num

end Catalog.Combinatorics.PlateauRungBudget