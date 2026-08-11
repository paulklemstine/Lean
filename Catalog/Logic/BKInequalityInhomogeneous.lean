/-
# The van den Berg–Kesten inequality for inhomogeneous Bernoulli measures

`Catalog/Logic/BKInequalityBernoulli.lean` proves the BK inequality
`bernProb p (A □ B) ≤ bernProb p A * bernProb p B` for the homogeneous
Bernoulli site measure of density `p`.  The combinatorial half of that proof —
the decoupling events `bkPair K A B`, the fact that a witness pair cannot use an
undecoupled site twice (`bkPair_key`), monotonicity (`bkPair_mono`) and the two
endpoint identifications (`bkPair_empty`, `bkPair_univ`) — never mentions the
measure.  Only the summation half does.

This file redoes the summation half for an arbitrary *density vector*
`p : ι → ℝ`, i.e. for the inhomogeneous product measure `bernProbVec` of
`Catalog/Combinatorics/InhomogeneousBernoulli.lean`, and so obtains the BK
inequality in the generality in which the Harris inequality
`bernProbVec_harris` is already available in the catalog.

## Main results

* `bernProbVec_bk`: `bernProbVec p (A □ B) ≤ bernProbVec p A * bernProbVec p B`
  for every density vector `p` with values in `[0,1]` and all increasing `A`, `B`.
* `bernProbVec_bk_harris_sandwich`: the inhomogeneous BK and Harris bounds
  together.
* `bernProb_bk_of_bernProbVec`: the homogeneous BK inequality re-derived from
  the inhomogeneous one, so the latter is a genuine generalization.
* `bernProbVec_disjointPow_le`: exponential decay of `n` disjoint occurrences
  for an arbitrary density vector.
-/

import Logic.BKInequalityBernoulli
import Combinatorics.InhomogeneousBernoulli

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The doubled inhomogeneous sum -/

/-- The product of two independent inhomogeneous Bernoulli measures of the same
density vector, evaluated on an event of pairs. -/
noncomputable def bernProbVec2 (p : ι → ℝ) (E : Set ((ι → Bool) × (ι → Bool))) : ℝ :=
  ∑ ω : ι → Bool, ∑ ω' : ι → Bool,
    weightVec p ω * weightVec p ω' * E.indicator (fun _ => (1 : ℝ)) (ω, ω')

/-- The doubled probability of an event depending only on the first copy. -/
theorem bernProbVec2_of_fst (p : ι → ℝ) (C : Set (ι → Bool)) :
    bernProbVec2 p {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C} = bernProbVec p C := by
  rw [bernProbVec2, bernProbVec_eq_sum_mul_indicator]
  refine Finset.sum_congr rfl fun ω _ => ?_
  have hind : ∀ ω' : ι → Bool,
      weightVec p ω * weightVec p ω' *
          ({z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}).indicator (fun _ => (1 : ℝ)) (ω, ω')
        = weightVec p ω' * (weightVec p ω * C.indicator (fun _ => (1 : ℝ)) ω) := by
    intro ω'
    by_cases h : ω ∈ C
    · rw [Set.indicator_of_mem (by exact h : (ω, ω') ∈ {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}),
        Set.indicator_of_mem h]
      ring
    · rw [Set.indicator_of_notMem
        (by exact h : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}),
        Set.indicator_of_notMem h]
      ring
  rw [Finset.sum_congr rfl (fun ω' _ => hind ω'), ← Finset.sum_mul, sum_weightVec, one_mul]

/-- The doubled probability of a product event factorizes. -/
theorem bernProbVec2_prod (p : ι → ℝ) (A B : Set (ι → Bool)) :
    bernProbVec2 p {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B} =
      bernProbVec p B * bernProbVec p A := by
  rw [bernProbVec2, bernProbVec_eq_sum_mul_indicator, bernProbVec_eq_sum_mul_indicator,
    Finset.sum_mul]
  refine Finset.sum_congr rfl fun ω _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun ω' _ => ?_
  by_cases hB : ω ∈ B <;> by_cases hA : ω' ∈ A
  · rw [Set.indicator_of_mem
        (by exact ⟨hA, hB⟩ : (ω, ω') ∈ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_mem hA, Set.indicator_of_mem hB]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hA h.1 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hA]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hB h.2 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hB]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hA h.1 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hA]
    ring

/-! ## The decoupling step -/

/-- **Decoupling one more site does not decrease the probability**, for an
arbitrary density vector. -/
theorem bernProbVec2_bkPair_le_insert {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B)
    (K : Finset ι) {k : ι} (hk : k ∉ K) :
    bernProbVec2 p (bkPair K A B) ≤ bernProbVec2 p (bkPair (insert k K) A B) := by
  classical
  rw [bernProbVec2, bernProbVec2, sum_pair_split k, sum_pair_split k]
  refine Finset.sum_le_sum fun ω hω => Finset.sum_le_sum fun ω' hω' => ?_
  simp only [mem_filter, mem_univ, true_and] at hω hω'
  set ω₀ := Function.update ω k false with hω₀
  set ω'₀ := Function.update ω' k false with hω'₀
  have hwω : weightVec p ω = p k * offWeightVec p k ω := by
    rw [weightVec_eq_mul_offWeightVec p k ω, hω]; simp
  have hwω' : weightVec p ω' = p k * offWeightVec p k ω' := by
    rw [weightVec_eq_mul_offWeightVec p k ω', hω']; simp
  have hwω₀ : weightVec p ω₀ = (1 - p k) * offWeightVec p k ω := by
    rw [weightVec_eq_mul_offWeightVec p k ω₀, hω₀, offWeightVec_update_config]
    simp
  have hwω'₀ : weightVec p ω'₀ = (1 - p k) * offWeightVec p k ω' := by
    rw [weightVec_eq_mul_offWeightVec p k ω'₀, hω'₀, offWeightVec_update_config]
    simp
  set W := offWeightVec p k ω with hW
  set W' := offWeightVec p k ω' with hW'
  have hWnn : 0 ≤ W := offWeightVec_nonneg hp0 hp1 k ω
  have hW'nn : 0 ≤ W' := offWeightVec_nonneg hp0 hp1 k ω'
  set e₁ := (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω, ω') with he₁def
  set e₀ := (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω') with he₀def
  set F₁₁ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω, ω') with hF₁₁def
  set F₀₁ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω, ω'₀) with hF₀₁def
  set F₁₀ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω') with hF₁₀def
  set F₀₀ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω'₀) with hF₀₀def
  have hsnd : (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω, ω'₀) = e₁ := by
    rw [he₁def, hω'₀]
    by_cases h : (ω, ω') ∈ bkPair K A B
    · rw [Set.indicator_of_mem ((bkPair_snd_update hk ω ω' false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem (fun hc => h ((bkPair_snd_update hk ω ω' false).mp hc)),
        Set.indicator_of_notMem h]
  have hsnd₀ : (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω'₀) = e₀ := by
    rw [he₀def, hω'₀]
    by_cases h : (ω₀, ω') ∈ bkPair K A B
    · rw [Set.indicator_of_mem ((bkPair_snd_update hk ω₀ ω' false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem (fun hc => h ((bkPair_snd_update hk ω₀ ω' false).mp hc)),
        Set.indicator_of_notMem h]
  have hupdle : ∀ (ξ : ι → Bool) (v : ι), Function.update ξ k false v = true → ξ v = true := by
    intro ξ v hv
    by_cases hvk : v = k
    · subst hvk; simp at hv
    · rwa [Function.update_of_ne hvk] at hv
  have h0 : e₀ ≤ F₀₀ :=
    bkInd_le_of_imp _ _ _ _
      (fun hmem => bkPair_insert_of_fst_false hk (by simp [hω₀]) hmem)
  have h1 : e₁ ≤ F₀₁ + F₁₀ := by
    refine bkInd_le_add_of_imp_or _ _ _ _ _ (fun hmem => ?_)
    rcases bkPair_key hA hk hmem with h | h
    · exact Or.inl h
    · refine Or.inr ?_
      have hself : Function.update ω' k true = ω' := by
        rw [← hω']; exact Function.update_eq_self k ω'
      rwa [hself] at h
  have m1 : F₀₀ ≤ F₀₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (hupdle ω) (fun _ h => h) hmem)
  have m2 : F₀₀ ≤ F₁₀ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (fun _ h => h) (hupdle ω') hmem)
  have m3 : F₀₁ ≤ F₁₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (fun _ h => h) (hupdle ω') hmem)
  have m4 : F₁₀ ≤ F₁₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (hupdle ω) (fun _ h => h) hmem)
  have hlocal := bk_local_ineq (hp0 k) (hp1 k) (bkInd_eq_zero_or_one _ (ω₀, ω'))
    (bkInd_eq_zero_or_one _ (ω, ω')) (bkInd_eq_zero_or_one _ (ω₀, ω'₀))
    (bkInd_eq_zero_or_one _ (ω, ω'₀)) (bkInd_eq_zero_or_one _ (ω₀, ω'))
    (bkInd_eq_zero_or_one _ (ω, ω')) h0 h1 m1 m2 m3 m4
  rw [hwω, hwω', hwω₀, hwω'₀, hsnd, hsnd₀]
  nlinarith [mul_nonneg hWnn hW'nn, hlocal]

/-- Decoupling any set of sites does not decrease the probability. -/
theorem bernProbVec2_bkPair_le {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) (K : Finset ι) :
    bernProbVec2 p (bkPair (∅ : Finset ι) A B) ≤ bernProbVec2 p (bkPair K A B) := by
  classical
  induction K using Finset.induction_on with
  | empty => exact le_rfl
  | insert k K hk ih =>
    exact ih.trans (bernProbVec2_bkPair_le_insert hp0 hp1 hA hB K hk)

/-! ## The inhomogeneous BK inequality -/

/-- **The van den Berg–Kesten inequality for an arbitrary density vector.** -/
theorem bernProbVec_bk {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProbVec p (disjointOccur A B) ≤ bernProbVec p A * bernProbVec p B := by
  have h := bernProbVec2_bkPair_le hp0 hp1 hA hB (univ : Finset ι)
  rw [bkPair_empty, bernProbVec2_of_fst, bkPair_univ hA hB, bernProbVec2_prod] at h
  linarith [h]

/-- **Inhomogeneous BK and Harris together.** -/
theorem bernProbVec_bk_harris_sandwich {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProbVec p (disjointOccur A B) ≤ bernProbVec p A * bernProbVec p B ∧
      bernProbVec p A * bernProbVec p B ≤ bernProbVec p (A ∩ B) :=
  ⟨bernProbVec_bk hp0 hp1 hA hB, bernProbVec_harris hp0 hp1 hA hB⟩

/-- On constant density vectors the inhomogeneous inequality specializes to the
homogeneous BK inequality, so the former is a genuine generalization: this
re-derives `bernProb_bk` from `bernProbVec_bk`. -/
theorem bernProb_bk_of_bernProbVec {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p (disjointOccur A B) ≤ bernProb p A * bernProb p B := by
  have h := bernProbVec_bk (p := fun _ : ι => p) (fun _ => hp0) (fun _ => hp1) hA hB
  rwa [bernProbVec_const, bernProbVec_const, bernProbVec_const] at h

/-- **Exponential decay of disjoint occurrences for an arbitrary density
vector.** -/
theorem bernProbVec_disjointPow_le {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    ∀ n, bernProbVec p (disjointPow A n) ≤ (bernProbVec p A) ^ n
  | 0 => by simp [disjointPow, bernProbVec_univ]
  | n + 1 => by
    have hstep := bernProbVec_bk hp0 hp1 hA (disjointPow_isIncreasing hA n)
    have hih := bernProbVec_disjointPow_le hp0 hp1 hA n
    have hAnn : 0 ≤ bernProbVec p A := bernProbVec_nonneg hp0 hp1 A
    calc bernProbVec p (disjointPow A (n + 1))
        ≤ bernProbVec p A * bernProbVec p (disjointPow A n) := hstep
      _ ≤ bernProbVec p A * (bernProbVec p A) ^ n := mul_le_mul_of_nonneg_left hih hAnn
      _ = (bernProbVec p A) ^ (n + 1) := by ring

end BernoulliThresholdCoupling