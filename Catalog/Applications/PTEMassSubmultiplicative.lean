/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.PTEExponentialBase

/-!
# Submultiplicativity of the minimal mass, and rigidity of minimal near misses

Two structural facts about the invariant `minMass` of `Applications/PTEIdealWitnesses.lean`
(the least mass `∑_j |e j|` of a nonzero integral vector invisible to the window `k < K`).

**Submultiplicativity.**  `minMass (K₁ + K₂) ≤ minMass K₁ · minMass K₂`.  Convolution adds
windows and multiplies masses, so this looks immediate — but it is not, because the
convolution of two nonzero vectors must be shown to be *nonzero*, and the mass-optimal
witnesses come with no information about their first visible moment.  The missing step is
`exists_sharp_window`: **every nonzero vector supported on `{0,…,N}` has a well-defined
first visible moment**, obtained by minimising over the moment index and using the Lagrange
engine to know that not every moment vanishes.  With that, submultiplicativity follows and
gives, by iteration, `minMass (n · K) ≤ (minMass K) ^ n` — a Fekete-type statement whose
`K = 12` instance is the growth base `24^{1/12}` of
`Applications/PTEExponentialBase.lean`.

**Rigidity.**  A near miss at window `K` whose sides have the *minimal* size `K` allowed by
`PTESize.card_ge_window_of_nearMiss` has **disjoint** sides: no node may be shared.  Indeed
in that case the two monic root polynomials differ by a nonzero constant, and a shared node
would be a common root, forcing that constant to vanish.  So size-minimal near misses are
genuine Prouhet–Tarry–Escott configurations, with no common padding — the padding freedom
of the catalog's `near_miss_iff` disappears exactly at the minimal size.

## Main results

* `exists_sharp_window` — first visible moment of a nonzero vector.
* `minMass_mono`, `minMass_submul` — monotonicity and submultiplicativity.
* `minMass_pow_le` — `minMass (n · K) ≤ (minMass K) ^ n`.
* `minMass_thirteen_le`, `minMass_twentytwo_le` — sample values obtained by composing the
  certified witnesses.
* `nearMiss_disjoint_of_card_eq_window` — **rigidity of size-minimal near misses.**

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  If `minMass` is submultiplicative and `minMass K = 2K` held for
all `K`, then `2(K₁+K₂) ≤ 4 K₁ K₂`, which is no contradiction — so submultiplicativity is
*consistent* with the polynomial-mass conjecture and cannot refute it.  Conversely any
single new ideal witness improves the global growth base.  Bold form: `minMass` is
*exactly* multiplicative on windows that admit ideal witnesses.

EXPERIMENT (Experimenter).  Submultiplicativity proved.  Exact multiplicativity is **false**
as stated: `minMass 2 · minMass 2 = 16` but `minMass 4 = 8`, so the inequality is strict at
`(2,2)` — recorded as `minMass_submul_strict`.  This kills the bold form immediately, which
is exactly what an adversarial test is for.

ANALYSIS (Analyst).  Strictness at `(2,2)` says composition is wasteful: convolving two
copies of `(1,-2,1)` gives mass `16` at window `4`, while the ideal quadruple
`{0,4,7,11} / {1,2,9,10}` gives `8`.  So the convolution engine is never optimal where
ideal witnesses exist; its value is that it *extends* beyond them.

CRITIQUE (Critic).  `exists_sharp_window` is the load-bearing lemma and is not vacuous: it
fails for the zero vector, and the hypothesis `e j₀ ≠ 0` is used through the Lagrange engine
`eq_zero_of_moments_zero_int`.  The rigidity theorem needs `card s = K` exactly; for
`card s > K` shared nodes really do occur (add a common element to any near miss), so the
hypothesis cannot be weakened.
-/

open Finset Polynomial

namespace PTERigid

open PowerSumSharpness InvisibleWeights PTESize PTEWitness PTEBase

/-! ## Truncation and the first visible moment -/

/-- Truncating a weight vector outside `{0,…,N}` changes neither its moments nor its mass. -/
def trunc (N : ℕ) (e : ℕ → ℤ) : ℕ → ℤ := fun j => if j ≤ N then e j else 0

lemma trunc_supp (N : ℕ) (e : ℕ → ℤ) : ∀ j, N < j → trunc N e j = 0 := by
  intro j hj
  simp [trunc, Nat.not_le.mpr hj]

lemma moment_trunc (N : ℕ) (e : ℕ → ℤ) (k : ℕ) : moment N (trunc N e) k = moment N e k := by
  refine Finset.sum_congr rfl fun j hj => ?_
  rw [show trunc N e j = e j from if_pos (Nat.lt_succ_iff.mp (mem_range.mp hj))]

lemma mass_trunc (N : ℕ) (e : ℕ → ℤ) :
    ∑ j ∈ range (N + 1), |trunc N e j| = ∑ j ∈ range (N + 1), |e j| := by
  refine Finset.sum_congr rfl fun j hj => ?_
  rw [show trunc N e j = e j from if_pos (Nat.lt_succ_iff.mp (mem_range.mp hj))]

lemma invisible_trunc {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e) : Invisible N K (trunc N e) :=
  fun k hk => by rw [moment_trunc, he k hk]

/-- **First visible moment.**  A vector invisible to the window `k < K` and nonzero somewhere
on `{0,…,N}` is invisible to a *maximal* window `K' ≥ K`, at whose top index the moment is
nonzero.  (Existence uses the Lagrange engine: if every moment up to `N` vanished the vector
would be zero on `{0,…,N}`.) -/
theorem exists_sharp_window {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ∃ K', K ≤ K' ∧ Invisible N K' e ∧ moment N e K' ≠ 0 := by
  classical
  have hex : ∃ k, moment N e k ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hne (eq_zero_of_moments_zero_int (fun k _ => hcon k) j₀ hj₀)
  refine ⟨Nat.find hex, ?_, ?_, Nat.find_spec hex⟩
  · by_contra hlt
    push_neg at hlt
    exact Nat.find_spec hex (he _ hlt)
  · intro k hk
    exact not_not.mp (Nat.find_min hex hk)

/-! ## Submultiplicativity of `minMass` -/

theorem minMass_mono {K K' : ℕ} (h : K' ≤ K) : minMass K' ≤ minMass K := by
  obtain ⟨N, e, hinv, hnz, hmass⟩ := minMass_mem K
  exact minMass_le ⟨N, e, invisible_mono h hinv, hnz, hmass⟩

/-- **Submultiplicativity.**  Windows add and masses multiply under convolution, so the
minimal mass is submultiplicative in the window length. -/
theorem minMass_submul (K₁ K₂ : ℕ) : minMass (K₁ + K₂) ≤ minMass K₁ * minMass K₂ := by
  obtain ⟨N₁, w₀, hinv₁, ⟨i₁, hi₁, hne₁⟩, hmass₁⟩ := minMass_mem K₁
  obtain ⟨N₂, e₀, hinv₂, ⟨i₂, hi₂, hne₂⟩, hmass₂⟩ := minMass_mem K₂
  set w := trunc N₁ w₀ with hw
  set e := trunc N₂ e₀ with hee
  have hwinv : Invisible N₁ K₁ w := invisible_trunc hinv₁
  have heinv : Invisible N₂ K₂ e := invisible_trunc hinv₂
  have hwne : w i₁ ≠ 0 := by rwa [hw, trunc, if_pos hi₁]
  have hene : e i₂ ≠ 0 := by rwa [hee, trunc, if_pos hi₂]
  obtain ⟨Kw, hKw, hwinv', hwtop⟩ := exists_sharp_window hwinv hi₁ hwne
  obtain ⟨Ke, hKe, heinv', hetop⟩ := exists_sharp_window heinv hi₂ hene
  have hsupp : ∀ j, N₂ < j → e j = 0 := trunc_supp N₂ e₀
  have hconv : Invisible (N₂ + N₁) (Ke + Kw) (kconv N₁ w e) :=
    kconv_invisible hsupp heinv' hwinv'
  have htop : moment (N₂ + N₁) (kconv N₁ w e) (Ke + Kw) ≠ 0 := by
    rw [moment_kconv_top hsupp heinv' hwinv']
    exact mul_ne_zero (mul_ne_zero
      (by exact_mod_cast (Nat.choose_pos (by omega : Ke ≤ Ke + Kw)).ne') hetop) hwtop
  have hnz : ∃ j ≤ N₂ + N₁, kconv N₁ w e j ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    refine htop (Finset.sum_eq_zero fun j hj => ?_)
    rw [hcon j (Nat.lt_succ_iff.mp (mem_range.mp hj)), zero_mul]
  have hmass : ∑ j ∈ range (N₂ + N₁ + 1), |kconv N₁ w e j| ≤ ((minMass K₁ * minMass K₂ : ℕ) : ℤ) := by
    have h := l1_kconv_le (M := N₁) (w := w) hsupp
    rw [hw, mass_trunc, hmass₁] at h
    rw [hee, mass_trunc, hmass₂] at h
    push_cast
    exact h.trans (le_of_eq (by ring))
  exact minMass_le_of_bound (invisible_mono (by omega) hconv) hnz hmass

/-- Iterating submultiplicativity: `minMass (n · K) ≤ (minMass K) ^ n`. -/
theorem minMass_pow_le (K n : ℕ) : minMass (n * K) ≤ (minMass K) ^ n := by
  induction n with
  | zero => simpa using minMass_le (massAchievable_two_pow 0)
  | succ n ih =>
      calc minMass ((n + 1) * K) = minMass (K + n * K) := by ring_nf
        _ ≤ minMass K * minMass (n * K) := minMass_submul _ _
        _ ≤ minMass K * (minMass K) ^ n := Nat.mul_le_mul_left _ ih
        _ = (minMass K) ^ (n + 1) := by ring

/-- **Submultiplicativity is strict** at `(K₁, K₂) = (2, 2)`: composing two copies of the
window-`2` witness costs `16`, while the ideal quadruple costs `8`. -/
theorem minMass_submul_strict : minMass (2 + 2) < minMass 2 * minMass 2 := by
  rw [minMass_two, show minMass (2 + 2) = minMass 4 from rfl, minMass_four]
  norm_num

theorem minMass_thirteen_le : minMass 13 ≤ 48 := by
  have h := minMass_submul 12 1
  rw [minMass_twelve, minMass_one] at h
  simpa using h

theorem minMass_twentytwo_le : minMass 22 ≤ 480 := by
  have h := minMass_submul 12 10
  rw [minMass_twelve, minMass_ten] at h
  simpa using h

/-! ## Rigidity of size-minimal near misses -/

/-- The monic polynomial with root multiset `s` (nodes cast to `ℚ`). -/
noncomputable def rootPoly (s : Multiset ℕ) : ℚ[X] :=
  ((Multiset.map (Nat.cast : ℕ → ℚ) s).map fun a => X - C a).prod

lemma rootPoly_eval_eq_zero {s : Multiset ℕ} {a : ℕ} (ha : a ∈ s) :
    (rootPoly s).eval ((a : ℚ)) = 0 := by
  rw [rootPoly, Polynomial.eval_multiset_prod]
  refine Multiset.prod_eq_zero ?_
  refine Multiset.mem_map.mpr ⟨X - C ((a : ℚ)), ?_, by simp⟩
  exact Multiset.mem_map.mpr ⟨(a : ℚ),
    Multiset.mem_map.mpr ⟨a, ha, rfl⟩, rfl⟩

lemma card_cast_multiset (s : Multiset ℕ) :
    Multiset.card (Multiset.map (Nat.cast : ℕ → ℚ) s) = Multiset.card s := by
  simp

/-- **Rigidity of size-minimal near misses.**  If two distinct multisets of naturals have
equal power sums throughout the window `k < K` and one of them has the minimal possible size
`K`, then they share no element: the near miss is a genuine Prouhet–Tarry–Escott pair, with
no common padding. -/
theorem nearMiss_disjoint_of_card_eq_window {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t)
    (hs : Multiset.card s = K) (ht : Multiset.card t = K) :
    ∀ a ∈ s, a ∉ t := by
  classical
  set sQ : Multiset ℚ := Multiset.map (Nat.cast : ℕ → ℚ) s with hsQ
  set tQ : Multiset ℚ := Multiset.map (Nat.cast : ℕ → ℚ) t with htQ
  have hcards : Multiset.card sQ = K := by rw [hsQ, card_cast_multiset, hs]
  have hcardt : Multiset.card tQ = K := by rw [htQ, card_cast_multiset, ht]
  have hpow : ∀ m < K, (sQ.map (fun x => x ^ m)).sum = (tQ.map (fun x => x ^ m)).sum := by
    intro m hm
    rw [hsQ, htQ, powerSum_eq_rat_powerSum, powerSum_eq_rat_powerSum, h m hm]
  have hes := esymm_eq_of_powerSum_eq hpow
  -- the two monic root polynomials differ by a constant
  have hcoeff : ∀ j, 1 ≤ j → (rootPoly s).coeff j = (rootPoly t).coeff j := by
    intro j hj
    rcases le_or_gt j K with hjK | hjK
    · rw [rootPoly, rootPoly,
        Multiset.prod_X_sub_C_coeff sQ (by omega : j ≤ Multiset.card sQ),
        Multiset.prod_X_sub_C_coeff tQ (by omega : j ≤ Multiset.card tQ),
        hcards, hcardt, hes (K - j) (by omega)]
    · have hds : (rootPoly s).natDegree = K := by
        rw [rootPoly, Polynomial.natDegree_multiset_prod_X_sub_C_eq_card, hcards]
      have hdt : (rootPoly t).natDegree = K := by
        rw [rootPoly, Polynomial.natDegree_multiset_prod_X_sub_C_eq_card, hcardt]
      rw [Polynomial.coeff_eq_zero_of_natDegree_lt (by omega),
        Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)]
  have hconst : rootPoly s - rootPoly t = C ((rootPoly s).coeff 0 - (rootPoly t).coeff 0) := by
    ext j
    rcases Nat.eq_zero_or_pos j with rfl | hj
    · simp
    · rw [Polynomial.coeff_sub, hcoeff j hj, sub_self, Polynomial.coeff_C, if_neg (by omega)]
  have hcne : (rootPoly s).coeff 0 - (rootPoly t).coeff 0 ≠ 0 := by
    intro hc
    rw [hc, map_zero, sub_eq_zero] at hconst
    have hroots := congrArg Polynomial.roots hconst
    rw [rootPoly, rootPoly, Polynomial.roots_multiset_prod_X_sub_C,
      Polynomial.roots_multiset_prod_X_sub_C] at hroots
    exact hne (Multiset.map_injective (f := fun x : ℕ => (x : ℚ)) Nat.cast_injective hroots)
  intro a ha hat
  refine hcne ?_
  have h1 : (rootPoly s).eval ((a : ℚ)) = 0 := rootPoly_eval_eq_zero ha
  have h2 : (rootPoly t).eval ((a : ℚ)) = 0 := rootPoly_eval_eq_zero hat
  have := congrArg (fun p : ℚ[X] => p.eval ((a : ℚ))) hconst
  simpa [h1, h2] using this.symm

/-- The rigidity statement in the language of invisible vectors: a *mass-minimal* invisible
vector at window `K` (mass `2K`) has all its `2K` units of mass on distinct nodes of two
disjoint node sets — there is no cancellation slack. -/
theorem minimal_mass_sides_disjoint {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t)
    (hmass : Multiset.card s + Multiset.card t = 2 * K) :
    Multiset.card s = K ∧ Multiset.card t = K ∧ ∀ a ∈ s, a ∉ t := by
  have h1 := card_ge_window_of_nearMiss h hne
  have h2 := card_ge_window_of_nearMiss' h hne
  have hs : Multiset.card s = K := by omega
  have ht : Multiset.card t = K := by omega
  exact ⟨hs, ht, nearMiss_disjoint_of_card_eq_window h hne hs ht⟩

end PTERigid