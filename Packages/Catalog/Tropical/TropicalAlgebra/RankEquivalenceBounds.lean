/-
# Rank-one equivalence bounds for tropical matrices

This file builds on `MinPlusRankOne.lean`.  It isolates the rank-one case of the
standard comparison between factor rank, Kapranov rank, and tropical minor rank.
At rank one no cancellation issue remains: a valued rank-one lift has an
additively separable valuation matrix, while tropical rank at most one is exactly
the vanishing of every tropical `2 × 2` minor.

The Kapranov predicate below is deliberately named a *valuation condition*: it is
the intrinsic condition on the value matrix of a rank-one lift.  Realizing the
potentials in a particular valued field additionally requires surjectivity of its
value map and is therefore kept separate from this field-independent theorem.
-/

import Tropical.TropicalAlgebra.MinPlusRankOne

noncomputable section

/-- The field-independent valuation condition forced by a classical rank-one
lift: its value matrix is a sum of a row potential and a column potential. -/
def KapranovRankOneValuationCondition {n m : ℕ}
    (A : Fin n → Fin m → ℝ) : Prop :=
  AdditivelySeparable A

/-- Tropical minor rank is at most one when every tropical `2 × 2` minor is
balanced.  Repeated rows or columns are allowed in this formulation, matching
the existing catalog definition. -/
def TropicalMinorRankLEOne {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  TropicalRankOneMinorCondition A

/-- Factor rank at most one and the rank-one Kapranov valuation condition agree. -/
theorem minPlusFactorRankLE_one_iff_kapranovValuation
    {n m : ℕ} (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ KapranovRankOneValuationCondition A := by
  exact minPlusFactorRankLE_one_iff_additivelySeparable A

/-- For nonempty matrices, the rank-one Kapranov valuation condition agrees with
tropical minor rank at most one. -/
theorem kapranovValuation_iff_tropicalMinorRankLEOne
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    KapranovRankOneValuationCondition A ↔ TropicalMinorRankLEOne A := by
  exact additivelySeparable_iff_tropicalRankOneMinorCondition A

/-- **Rank-one three-way equivalence.**  Factor rank at most one, the intrinsic
Kapranov rank-one valuation condition, and tropical minor rank at most one are
equivalent for a nonempty finite matrix. -/
theorem factor_kapranov_tropical_rank_one_equivalence
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔
      KapranovRankOneValuationCondition A ∧ TropicalMinorRankLEOne A := by
  constructor
  · intro h
    have hk : KapranovRankOneValuationCondition A :=
      (minPlusFactorRankLE_one_iff_kapranovValuation A).mp h
    exact ⟨hk, (kapranovValuation_iff_tropicalMinorRankLEOne A).mp hk⟩
  · rintro ⟨hk, _⟩
    exact (minPlusFactorRankLE_one_iff_kapranovValuation A).mpr hk

/-- A single unbalanced tropical `2 × 2` minor is simultaneously a lower-bound
certificate excluding factor rank one and the rank-one Kapranov valuation
condition. -/
theorem unbalanced_minor_forces_rank_gt_one
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ)
    (i i' : Fin n) (j j' : Fin m)
    (hminor : A i j + A i' j' ≠ A i j' + A i' j) :
    ¬ MinPlusFactorRankLE 1 A ∧
      ¬ KapranovRankOneValuationCondition A ∧
      ¬ TropicalMinorRankLEOne A := by
  have ht : ¬ TropicalMinorRankLEOne A := by
    intro h
    exact hminor (h i i' j j')
  have hk : ¬ KapranovRankOneValuationCondition A := by
    intro h
    exact ht ((kapranovValuation_iff_tropicalMinorRankLEOne A).mp h)
  have hf : ¬ MinPlusFactorRankLE 1 A := by
    intro h
    exact hk ((minPlusFactorRankLE_one_iff_kapranovValuation A).mp h)
  exact ⟨hf, hk, ht⟩

/-- The three rank-one upper bounds are invariant under transposition. -/
theorem rank_one_bounds_transpose
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    (MinPlusFactorRankLE 1 A ↔ MinPlusFactorRankLE 1 (fun j i => A i j)) ∧
    (KapranovRankOneValuationCondition A ↔
      KapranovRankOneValuationCondition (fun j i => A i j)) ∧
    (TropicalMinorRankLEOne A ↔ TropicalMinorRankLEOne (fun j i => A i j)) := by
  have ht : TropicalMinorRankLEOne A ↔
      TropicalMinorRankLEOne (fun j i => A i j) := by
    constructor
    · intro h j j' i i'
      simpa [add_comm] using h i i' j j'
    · intro h i i' j j'
      simpa [add_comm] using h j j' i i'
  have hk : KapranovRankOneValuationCondition A ↔
      KapranovRankOneValuationCondition (fun j i => A i j) := by
    rw [kapranovValuation_iff_tropicalMinorRankLEOne,
      kapranovValuation_iff_tropicalMinorRankLEOne]
    exact ht
  have hf : MinPlusFactorRankLE 1 A ↔
      MinPlusFactorRankLE 1 (fun j i => A i j) := by
    rw [minPlusFactorRankLE_one_iff_kapranovValuation,
      minPlusFactorRankLE_one_iff_kapranovValuation]
    exact hk
  exact ⟨hf, hk, ht⟩

/-- Negation exchanges min-plus and max-plus rank-one factor bounds while leaving
both the Kapranov valuation and tropical-minor conditions unchanged. -/
theorem min_max_rank_one_duality
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    (MinPlusFactorRankLE 1 A ↔ MaxPlusFactorRankLE 1 (fun i j => -A i j)) ∧
    (KapranovRankOneValuationCondition A ↔
      KapranovRankOneValuationCondition (fun i j => -A i j)) ∧
    (TropicalMinorRankLEOne A ↔
      TropicalMinorRankLEOne (fun i j => -A i j)) := by
  have hk : KapranovRankOneValuationCondition A ↔
      KapranovRankOneValuationCondition (fun i j => -A i j) := by
    constructor
    · exact additivelySeparable_neg A
    · intro h
      have hh := additivelySeparable_neg (fun i j => -A i j) h
      simpa only [neg_neg] using hh
  have ht : TropicalMinorRankLEOne A ↔
      TropicalMinorRankLEOne (fun i j => -A i j) := by
    constructor
    · exact tropicalRankOneMinorCondition_neg A
    · intro h
      have hh := tropicalRankOneMinorCondition_neg (fun i j => -A i j) h
      simpa only [neg_neg] using hh
  have hf : MinPlusFactorRankLE 1 A ↔
      MaxPlusFactorRankLE 1 (fun i j => -A i j) := by
    rw [minPlusFactorRankLE_one_iff_additivelySeparable,
      maxPlusFactorRankLE_one_iff_additivelySeparable]
    exact hk
  exact ⟨hf, hk, ht⟩

end