/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Convergence in probability of the second spectral moment of a Wigner matrix

For an arbitrary centred, unit-variance entry law `ℒ` (finitely supported, fourth
moment `m₄`), the second moment of the empirical spectral distribution of `W/√N`

* has expectation exactly `1 - 1/N`, and
* has variance exactly `2 (m₄ - 1) (N-1) / N³`,

so by Chebyshev's inequality it converges **in probability** to `1 = C₁`, the
second moment of the Wigner semicircle law.  This is the `k = 2` case of the
semicircle law, proved for a general Wigner ensemble rather than for a single
entry distribution.
-/
import Probability.WignerUniversalFourthMoment

open Matrix BigOperators Finset Filter Topology
open RademacherWigner (edgeOf edgeOf_comm edgeOf_eq_iff)
open scoped Classical

namespace WignerUniversal

variable {S : Type*} [Fintype S] {N : ℕ}

/-! ### Basic probabilistic infrastructure -/

/-- The weight (product law probability) of a configuration. -/
noncomputable def weight (L : EntryLaw S) (ω : Conf N S) : ℝ := ∏ e, L.w (ω e)

theorem weight_nonneg (L : EntryLaw S) (ω : Conf N S) : 0 ≤ weight L ω :=
  Finset.prod_nonneg fun _ _ => L.w_nonneg _

theorem gexpect_eq_sum_weight (L : EntryLaw S) (f : Conf N S → ℝ) :
    gexpect L f = ∑ ω : Conf N S, weight L ω * f ω := rfl

/-- Total mass one. -/
theorem gexpect_one (L : EntryLaw S) : gexpect (N := N) L (fun _ => 1) = 1 := by
  have h := gexpect_prod (N := N) L (fun _ _ => (1 : ℝ))
  simpa [L.total] using h

theorem gexpect_const (L : EntryLaw S) (c : ℝ) : gexpect (N := N) L (fun _ => c) = c := by
  have := gexpect_const_mul (N := N) L c (fun _ => 1)
  simpa [gexpect_one] using this

theorem gexpect_add (L : EntryLaw S) (f g : Conf N S → ℝ) :
    gexpect L (fun ω => f ω + g ω) = gexpect L f + gexpect L g := by
  unfold gexpect
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem gexpect_sub (L : EntryLaw S) (f g : Conf N S → ℝ) :
    gexpect L (fun ω => f ω - g ω) = gexpect L f - gexpect L g := by
  unfold gexpect
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun ω _ => by ring

/-- The probability of an event, i.e. of a finite set of configurations. -/
noncomputable def gprob (L : EntryLaw S) (A : Finset (Conf N S)) : ℝ :=
  ∑ ω ∈ A, weight L ω

theorem gprob_nonneg (L : EntryLaw S) (A : Finset (Conf N S)) : 0 ≤ gprob L A :=
  Finset.sum_nonneg fun ω _ => weight_nonneg L ω

theorem gprob_mono (L : EntryLaw S) {A B : Finset (Conf N S)} (h : A ⊆ B) :
    gprob L A ≤ gprob L B :=
  Finset.sum_le_sum_of_subset_of_nonneg h fun ω _ _ => weight_nonneg L ω

/-- **Chebyshev's inequality** for the product law. -/
theorem chebyshev (L : EntryLaw S) (X : Conf N S → ℝ) (mu eps : ℝ) (heps : 0 < eps) :
    eps ^ 2 * gprob L (Finset.univ.filter (fun ω : Conf N S => eps ≤ |X ω - mu|))
      ≤ gexpect L (fun ω => (X ω - mu) ^ 2) := by
  rw [gexpect_eq_sum_weight, gprob, Finset.mul_sum]
  calc ∑ ω ∈ Finset.univ.filter (fun ω : Conf N S => eps ≤ |X ω - mu|), eps ^ 2 * weight L ω
      ≤ ∑ ω ∈ Finset.univ.filter (fun ω : Conf N S => eps ≤ |X ω - mu|),
          weight L ω * (X ω - mu) ^ 2 := by
        refine Finset.sum_le_sum fun ω hω => ?_
        have hx : eps ≤ |X ω - mu| := (Finset.mem_filter.1 hω).2
        have hsq : eps ^ 2 ≤ (X ω - mu) ^ 2 := by
          have h1 : eps ^ 2 ≤ |X ω - mu| ^ 2 := by
            have habs : 0 ≤ |X ω - mu| := abs_nonneg _
            nlinarith [hx, heps.le, habs]
          rwa [sq_abs] at h1
        have := weight_nonneg L ω
        nlinarith [this, hsq]
    _ ≤ ∑ ω : Conf N S, weight L ω * (X ω - mu) ^ 2 := by
        refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
        intro ω _ _
        exact mul_nonneg (weight_nonneg L ω) (sq_nonneg _)

/-! ### The second trace moment and its square -/

theorem trace_pow_two (M : Matrix (Fin N) (Fin N) ℝ) :
    (M ^ 2).trace = ∑ i, ∑ j, M i j * M j i := by
  rw [pow_two, Matrix.trace_mul_comm]
  simp [Matrix.trace, Matrix.diag, Matrix.mul_apply]

theorem gexpect_entry_sq (L : EntryLaw S) {i j : Fin N} (h : i ≠ j) :
    gexpect L (fun ω : Conf N S => gentry L ω i j * gentry L ω j i) = 1 := by
  have h1 : ∀ ω : Conf N S, gentry L ω i j * gentry L ω j i
      = L.v (ω (edgeOf i j)) ^ 2 * L.v (ω (edgeOf i j)) ^ 0 := by
    intro ω
    rw [gentry_of_ne L ω h, ← gentry_symm L ω i j, gentry_of_ne L ω h]
    ring
  simp only [h1, pow_zero, mul_one]
  have h2 : ∀ ω : Conf N S, L.v (ω (edgeOf i j)) ^ 2
      = ∏ e, (if e = edgeOf i j then L.v (ω e) ^ 2 else 1) := by
    intro ω
    rw [prod_eq_single' (edgeOf i j) _ (fun e he => by simp [he])]
    simp
  simp only [h2]
  rw [gexpect_prod L (fun e s => if e = edgeOf i j then L.v s ^ 2 else 1)]
  rw [prod_eq_single' (edgeOf i j) _ (fun e he => by simp [he, L.total])]
  simp [L.var]

/-- **The expected second trace moment** of a general Wigner ensemble. -/
theorem gexpect_trace_two (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => ((GW L ω) ^ 2).trace) = (N : ℝ) * ((N : ℝ) - 1) := by
  have h1 : ∀ ω : Conf N S, ((GW L ω) ^ 2).trace
      = ∑ i : Fin N, ∑ j : Fin N, gentry L ω i j * gentry L ω j i := fun ω =>
    trace_pow_two (GW L ω)
  simp only [h1]
  rw [gexpect_sum]
  have h2 : ∀ i : Fin N,
      gexpect L (fun ω : Conf N S => ∑ j : Fin N, gentry L ω i j * gentry L ω j i)
        = ∑ j : Fin N, (if j = i then (0:ℝ) else 1) := by
    intro i
    rw [gexpect_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    by_cases hj : j = i
    · have h0 : ∀ ω : Conf N S, gentry L ω i j * gentry L ω j i = 0 := by
        intro ω; simp [gentry, hj]
      simp only [h0]
      rw [gexpect_zero, if_pos hj]
    · rw [gexpect_entry_sq L (Ne.symm hj), if_neg hj]
  rw [Finset.sum_congr rfl fun i _ => h2 i,
    Finset.sum_congr rfl fun i _ => RademacherWigner.sum_indicator_ne i]
  simp [Finset.card_univ]
  ring

/-! ### The second moment of the second trace moment -/

/-- Expected product of two squared entries: `m₄` on the diagonal of edge pairs and
`1` off it. -/
theorem gexpect_entry_sq_pair (L : EntryLaw S) {i j k l : Fin N} (hij : i ≠ j) (hkl : k ≠ l) :
    gexpect L (fun ω : Conf N S =>
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k)) =
      if (k = i ∧ l = j) ∨ (k = j ∧ l = i) then L.m4 else 1 := by
  have hexp : ∀ ω : Conf N S,
      (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k)
        = L.v (ω (edgeOf i j)) ^ 2 * L.v (ω (edgeOf k l)) ^ 2 := by
    intro ω
    rw [gentry_of_ne L ω hij, ← gentry_symm L ω i j, gentry_of_ne L ω hij,
      gentry_of_ne L ω hkl, ← gentry_symm L ω k l, gentry_of_ne L ω hkl]
    ring
  by_cases hpq : edgeOf i j = edgeOf k l
  · have hcond : (k = i ∧ l = j) ∨ (k = j ∧ l = i) := by
      rcases (edgeOf_eq_iff hij hkl).1 hpq with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · exact Or.inl ⟨h1.symm, h2.symm⟩
      · exact Or.inr ⟨h2.symm, h1.symm⟩
    have h4 : ∀ ω : Conf N S,
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k)
          = L.v (ω (edgeOf i j)) ^ 4 := by
      intro ω
      rw [hexp ω, hpq]
      ring
    simp only [h4]
    rw [gexpect_quad, if_pos hcond]
  · have hcond : ¬ ((k = i ∧ l = j) ∨ (k = j ∧ l = i)) := by
      rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
      · exact hpq rfl
      · exact hpq (edgeOf_comm _ _)
    simp only [hexp]
    rw [gexpect_double_pair L hpq, if_neg hcond]

/-- `ne i j = 1` iff `i ≠ j`. -/
def neInd (i j : Fin N) : ℝ := if i = j then 0 else 1

/-- Indicator of the coinciding ordered edge pair `(k,l) = (i,j)`. -/
def pairInd1 (i j k l : Fin N) : ℝ :=
  (if i = j then 0 else 1) * (if k = i then 1 else 0) * (if l = j then 1 else 0)

/-- Indicator of the reversed edge pair `(k,l) = (j,i)`. -/
def pairInd2 (i j k l : Fin N) : ℝ :=
  (if i = j then 0 else 1) * (if k = j then 1 else 0) * (if l = i then 1 else 0)

/-- The pointwise value of the expected product of two squared entries,
decomposed by inclusion–exclusion. -/
theorem gexpect_pair_decomp (L : EntryLaw S) (i j k l : Fin N) :
    gexpect L (fun ω : Conf N S =>
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k)) =
      neInd i j * neInd k l + (L.m4 - 1) * pairInd1 i j k l
        + (L.m4 - 1) * pairInd2 i j k l := by
  by_cases hij : i = j
  · have h0 : ∀ ω : Conf N S,
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k) = 0 := by
      intro ω; simp [gentry, hij]
    simp only [h0]
    rw [gexpect_zero]
    simp [neInd, pairInd1, pairInd2, hij]
  by_cases hkl : k = l
  · have h0 : ∀ ω : Conf N S,
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k) = 0 := by
      intro ω; simp [gentry, hkl]
    simp only [h0]
    rw [gexpect_zero]
    have h1 : pairInd1 i j k l = 0 := by
      unfold pairInd1
      by_cases h : k = i
      · by_cases h' : l = j
        · exact absurd (by rw [← h, hkl, h']) hij
        · simp [h']
      · simp [h]
    have h2 : pairInd2 i j k l = 0 := by
      unfold pairInd2
      by_cases h : k = j
      · by_cases h' : l = i
        · exact absurd (by rw [← h', ← hkl, h]) (Ne.symm hij)
        · simp [h']
      · simp [h]
    rw [h1, h2]
    simp [neInd, hkl]
  · rw [gexpect_entry_sq_pair L hij hkl]
    unfold neInd pairInd1 pairInd2
    by_cases h1 : k = i <;> by_cases h2 : l = j <;> by_cases h3 : k = j <;>
      by_cases h4 : l = i <;> simp_all

theorem sum_neInd_mul (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, neInd i j * neInd k l)
      = ((N : ℝ) * ((N : ℝ) - 1)) ^ 2 := by
  have hin : ∀ k : Fin N, (∑ l : Fin N, neInd k l) = (N : ℝ) - 1 := by
    intro k
    simpa [neInd] using RademacherWigner.sum_indicator_ne' k
  have hdouble : (∑ k : Fin N, ∑ l : Fin N, neInd k l) = (N : ℝ) * ((N : ℝ) - 1) := by
    rw [Finset.sum_congr rfl fun k _ => hin k]
    simp [Finset.card_univ]
    ring
  have key : ∀ i : Fin N,
      (∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, neInd i j * neInd k l)
        = ((N : ℝ) - 1) * ((N : ℝ) * ((N : ℝ) - 1)) := by
    intro i
    simp_rw [← Finset.mul_sum, hdouble, ← Finset.sum_mul, hin i]
  rw [Finset.sum_congr rfl fun i _ => key i]
  simp [Finset.card_univ]
  ring

theorem sum_pairInd1 (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairInd1 i j k l)
      = (N : ℝ) * ((N : ℝ) - 1) := by
  have key : ∀ i j : Fin N, (∑ k : Fin N, ∑ l : Fin N, pairInd1 i j k l)
      = (if i = j then (0:ℝ) else 1) := by
    intro i j
    simp_rw [pairInd1, ← Finset.mul_sum, RademacherWigner.sum_indicator_eq_one, mul_one]
    rw [← Finset.mul_sum, RademacherWigner.sum_indicator_eq_one, mul_one]
  simp_rw [key]
  rw [Finset.sum_congr rfl fun i _ => RademacherWigner.sum_indicator_ne' i]
  simp [Finset.card_univ]
  ring

theorem sum_pairInd2 (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairInd2 i j k l)
      = (N : ℝ) * ((N : ℝ) - 1) := by
  have key : ∀ i j : Fin N, (∑ k : Fin N, ∑ l : Fin N, pairInd2 i j k l)
      = (if i = j then (0:ℝ) else 1) := by
    intro i j
    simp_rw [pairInd2, ← Finset.mul_sum, RademacherWigner.sum_indicator_eq_one, mul_one]
    rw [← Finset.mul_sum, RademacherWigner.sum_indicator_eq_one, mul_one]
  simp_rw [key]
  rw [Finset.sum_congr rfl fun i _ => RademacherWigner.sum_indicator_ne' i]
  simp [Finset.card_univ]
  ring

/-- **The second moment of the second trace moment.** -/
theorem gexpect_trace_two_sq (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => (((GW L ω) ^ 2).trace) ^ 2) =
      ((N : ℝ) * ((N : ℝ) - 1)) ^ 2 + 2 * (L.m4 - 1) * ((N : ℝ) * ((N : ℝ) - 1)) := by
  have h1 : ∀ ω : Conf N S, (((GW L ω) ^ 2).trace) ^ 2 =
      ∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k) := by
    intro ω
    rw [trace_pow_two, sq]
    simp_rw [Finset.sum_mul, Finset.mul_sum, GW_apply]
  simp only [h1]
  rw [gexpect_sum]
  have h2 : ∀ i : Fin N,
      gexpect L (fun ω : Conf N S => ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        (gentry L ω i j * gentry L ω j i) * (gentry L ω k l * gentry L ω l k))
      = ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
          (neInd i j * neInd k l + (L.m4 - 1) * pairInd1 i j k l
            + (L.m4 - 1) * pairInd2 i j k l) := by
    intro i
    rw [gexpect_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [gexpect_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [gexpect_sum]
    exact Finset.sum_congr rfl fun l _ => gexpect_pair_decomp L i j k l
  rw [Finset.sum_congr rfl fun i _ => h2 i]
  have hsplit : (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
      (neInd i j * neInd k l + (L.m4 - 1) * pairInd1 i j k l
        + (L.m4 - 1) * pairInd2 i j k l))
      = (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, neInd i j * neInd k l)
        + (L.m4 - 1) * (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairInd1 i j k l)
        + (L.m4 - 1) * (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairInd2 i j k l) := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [hsplit, sum_neInd_mul, sum_pairInd1, sum_pairInd2]
  ring

/-! ### Mean, variance and convergence in probability -/

theorem normalizedMoment_two_eq (L : EntryLaw S) (ω : Conf N S) (hN : 0 < N) :
    WignerBridge.normalizedMoment (GW L ω) 2 = ((GW L ω) ^ 2).trace / (N : ℝ) ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [WignerBridge.normalizedMoment_eq, RademacherWigner.card_fin_config,
    RademacherWigner.sqrt_inv_sq]
  field_simp

/-- The expected second spectral moment of a general Wigner ensemble is `1 - 1/N`. -/
theorem gexpect_normalizedMoment_two (L : EntryLaw S) (N : ℕ) (hN : 0 < N) :
    gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 2)
      = 1 - 1 / (N : ℝ) := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hrw : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) 2
      = (1 / (N : ℝ) ^ 2) * ((GW L ω) ^ 2).trace := by
    intro ω
    rw [normalizedMoment_two_eq L ω hN]
    ring
  simp only [hrw]
  rw [gexpect_const_mul, gexpect_trace_two]
  field_simp

/-- **Exact variance of the second spectral moment**: `2 (m₄ - 1) (N-1) / N³`. -/
theorem variance_normalizedMoment_two (L : EntryLaw S) (N : ℕ) (hN : 0 < N) :
    gexpect L (fun ω : Conf N S =>
        (WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))) ^ 2)
      = 2 * (L.m4 - 1) * ((N : ℝ) - 1) / (N : ℝ) ^ 3 := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hrw : ∀ ω : Conf N S,
      (WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))) ^ 2
        = (1 / (N : ℝ) ^ 4) * (((GW L ω) ^ 2).trace) ^ 2
          + ((-2 * (1 - 1 / (N : ℝ)) / (N : ℝ) ^ 2) * ((GW L ω) ^ 2).trace
            + (1 - 1 / (N : ℝ)) ^ 2) := by
    intro ω
    rw [normalizedMoment_two_eq L ω hN]
    field_simp
    ring
  simp only [hrw]
  rw [gexpect_add, gexpect_add, gexpect_const_mul, gexpect_const_mul, gexpect_const,
    gexpect_trace_two, gexpect_trace_two_sq]
  field_simp
  ring

/-- **Convergence in probability of the second spectral moment.**  For any centred,
unit-variance entry law and any `ε > 0`, the probability that the second moment of
the empirical spectral distribution of `W/√N` deviates from the semicircle value
`C₁ = 1` by at least `ε` tends to zero. -/
theorem tendsto_gprob_secondMoment_deviation (L : EntryLaw S) (eps : ℝ) (heps : 0 < eps) :
    Tendsto (fun N : ℕ => gprob L (Finset.univ.filter (fun ω : Conf N S =>
        eps ≤ |WignerBridge.normalizedMoment (GW L ω) 2
          - WignerSemicircle.semicircleMoment 2|)))
      atTop (𝓝 0) := by
  set c : ℝ := (2 / eps) ^ 2 * (2 * (L.m4 - 1)) with hc
  have hG : Tendsto (fun N : ℕ => c * ((1 / (N : ℝ)) ^ 2 - (1 / (N : ℝ)) ^ 3)) atTop (𝓝 0) := by
    have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have h2 := (tendsto_const_nhds (x := c)).mul ((h.pow 2).sub (h.pow 3))
    simpa using h2
  refine squeeze_zero' (Eventually.of_forall fun N => gprob_nonneg L _) ?_ hG
  have hev : ∀ᶠ N : ℕ in atTop, (2 : ℝ) / eps < (N : ℝ) :=
    tendsto_natCast_atTop_atTop.eventually_gt_atTop (2 / eps)
  filter_upwards [hev, eventually_gt_atTop 0] with N hbig hN
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hNne : (N : ℝ) ≠ 0 := ne_of_gt hNR
  have hsmall : (1 : ℝ) / (N : ℝ) < eps / 2 := by
    rw [div_lt_div_iff₀ hNR (by norm_num : (0:ℝ) < 2)]
    rw [div_lt_iff₀ heps] at hbig
    linarith
  -- the deviation event is contained in the Chebyshev event
  have hsubset :
      (Finset.univ.filter (fun ω : Conf N S =>
        eps ≤ |WignerBridge.normalizedMoment (GW L ω) 2
          - WignerSemicircle.semicircleMoment 2|))
      ⊆ (Finset.univ.filter (fun ω : Conf N S =>
        eps / 2 ≤ |WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))|)) := by
    intro ω hω
    have hdev : eps ≤ |WignerBridge.normalizedMoment (GW L ω) 2
        - WignerSemicircle.semicircleMoment 2| := (Finset.mem_filter.1 hω).2
    rw [WignerSemicircle.semicircleMoment_two] at hdev
    refine Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_⟩
    set X := WignerBridge.normalizedMoment (GW L ω) 2 with hX
    have htri : |X - 1| ≤ |X - (1 - 1 / (N : ℝ))| + |1 / (N : ℝ)| := by
      have : X - 1 = (X - (1 - 1 / (N : ℝ))) + (-(1 / (N : ℝ))) := by ring
      rw [this]
      calc |(X - (1 - 1 / (N : ℝ))) + (-(1 / (N : ℝ)))|
          ≤ |X - (1 - 1 / (N : ℝ))| + |(-(1 / (N : ℝ)))| := abs_add_le _ _
        _ = |X - (1 - 1 / (N : ℝ))| + |1 / (N : ℝ)| := by rw [abs_neg]
    have habs : |(1 : ℝ) / (N : ℝ)| = 1 / (N : ℝ) := abs_of_nonneg (by positivity)
    rw [habs] at htri
    linarith
  have hcheb := chebyshev L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 2)
    (1 - 1 / (N : ℝ)) (eps / 2) (by linarith)
  rw [variance_normalizedMoment_two L N hN] at hcheb
  have hmono := gprob_mono L hsubset
  have hpos : (0 : ℝ) < (eps / 2) ^ 2 := by positivity
  have hbound : gprob L (Finset.univ.filter (fun ω : Conf N S =>
      eps / 2 ≤ |WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))|))
      ≤ c * ((1 / (N : ℝ)) ^ 2 - (1 / (N : ℝ)) ^ 3) := by
    have hgoal : gprob L (Finset.univ.filter (fun ω : Conf N S =>
        eps / 2 ≤ |WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))|))
        ≤ (2 * (L.m4 - 1) * ((N : ℝ) - 1) / (N : ℝ) ^ 3) / (eps / 2) ^ 2 :=
      (le_div_iff₀ hpos).2 (by rw [mul_comm]; exact hcheb)
    have hexpand : (2 * (L.m4 - 1) * ((N : ℝ) - 1) / (N : ℝ) ^ 3) / (eps / 2) ^ 2
        = c * ((1 / (N : ℝ)) ^ 2 - (1 / (N : ℝ)) ^ 3) := by
      rw [hc]
      field_simp
    rw [hexpand] at hgoal
    exact hgoal
  linarith

end WignerUniversal