import Mathlib

/-!
# Distance to Affine Hyperplanes

This file proves the fundamental formula for the Euclidean distance from a point
to an affine hyperplane `{y | ⟪u, y⟫_ℝ = c}` in a finite-dimensional inner product space:

  `infDist x {y | ⟪u, y⟫_ℝ = c} = |⟪u, x⟫_ℝ - c| / ‖u‖`

This is the atomic geometric lemma underlying polyhedral robustness certificates
for tropical/ReLU classifiers.

## Main Results

* `affineHyperplane_nonempty` — nonemptiness when `u ≠ 0`
* `affineHyperplane_isClosed` — closedness
* `dist_to_hyperplane_eq` — exact distance formula
* `dist_to_tie_hyperplane_eq` — distance to the tie set of two affine forms
-/

open scoped InnerProductSpace
open Metric Set

noncomputable section

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- The affine hyperplane `{y | ⟪u, y⟫_ℝ = c}`. -/
def affineHyperplane (u : E) (c : ℝ) : Set E :=
  {y : E | ⟪u, y⟫_ℝ = c}

/-
The hyperplane `{y | ⟪u, y⟫_ℝ = c}` is nonempty when `u ≠ 0`.
-/
lemma affineHyperplane_nonempty [FiniteDimensional ℝ E] (u : E) (c : ℝ) (hu : u ≠ 0) :
    (affineHyperplane u c).Nonempty := by
  refine' ⟨ ( c / ‖u‖ ^ 2 ) • u, _ ⟩;
  simp +decide [ affineHyperplane, inner_smul_right, hu ]

/-
The hyperplane `{y | ⟪u, y⟫_ℝ = c}` is closed.
-/
lemma affineHyperplane_isClosed (u : E) (c : ℝ) :
    IsClosed (affineHyperplane u c) := by
  exact isClosed_eq ( continuous_const.inner continuous_id' ) continuous_const

/-
**Distance to affine hyperplane formula.**
The Euclidean distance from a point `x` to the hyperplane `{y | ⟪u, y⟫_ℝ = c}`
equals `|⟪u, x⟫_ℝ - c| / ‖u‖`, provided `u ≠ 0`.
-/
theorem dist_to_hyperplane_eq [FiniteDimensional ℝ E]
    (u : E) (c : ℝ) (x : E) (hu : u ≠ 0) :
    Metric.infDist x (affineHyperplane u c) = |⟪u, x⟫_ℝ - c| / ‖u‖ := by
  -- By Lemma 25, there exists a point y in the hyperplane such that the distance from x to y is equal to the infimum distance.
  have h_exists_y : ∃ y ∈ affineHyperplane u c, dist x y = |⟪u, x⟫_ℝ - c| / ‖u‖ := by
    refine' ⟨ x - ( ⟪u, x⟫_ℝ - c ) • ( ‖u‖ ^ 2 ) ⁻¹ • u, _, _ ⟩ <;> simp_all +decide [ affineHyperplane, inner_sub_left, inner_smul_right ];
    · simp +decide [ inner_sub_right, inner_smul_right, hu, norm_smul, mul_assoc, mul_left_comm, sq ];
    · simp +decide [ norm_smul, div_eq_mul_inv, sq, hu ];
  refine' le_antisymm ( infDist_le_dist_of_mem h_exists_y.choose_spec.1 |> le_trans <| h_exists_y.choose_spec.2.le ) _;
  -- By definition of infimum distance, for any $y \in H$, we have $dist x y \geq |⟪u, x⟫_ℝ - c| / ‖u‖$.
  have h_dist_ge : ∀ y ∈ affineHyperplane u c, dist x y ≥ |⟪u, x⟫_ℝ - c| / ‖u‖ := by
    intro y hy
    have h_dist_ge : dist x y ≥ |⟪u, x⟫_ℝ - ⟪u, y⟫_ℝ| / ‖u‖ := by
      have h_dist_ge : |⟪u, x⟫_ℝ - ⟪u, y⟫_ℝ| ≤ ‖u‖ * ‖x - y‖ := by
        simpa [ inner_sub_right ] using abs_real_inner_le_norm u ( x - y );
      rwa [ ge_iff_le, div_le_iff₀' ( norm_pos_iff.mpr hu ), dist_eq_norm ];
    exact h_dist_ge.trans' ( by rw [ hy.out ] );
  rw [ Metric.infDist_eq_iInf ];
  exact le_csInf ⟨ _, ⟨ h_exists_y.choose, h_exists_y.choose_spec.1 ⟩, rfl ⟩ fun r hr => by aesop;

/-
Variant: distance to the "tie hyperplane" of two affine forms.
Given affine forms `ℓ₁(y) = ⟪a₁, y⟫ + b₁` and `ℓ₂(y) = ⟪a₂, y⟫ + b₂`,
the tie set `{y | ℓ₁(y) = ℓ₂(y)}` is a hyperplane with normal `a₁ - a₂`.
The distance from `x` to this tie set is `|ℓ₁(x) - ℓ₂(x)| / ‖a₁ - a₂‖`.
-/
theorem dist_to_tie_hyperplane_eq [FiniteDimensional ℝ E]
    (a₁ a₂ : E) (b₁ b₂ : ℝ) (x : E) (h : a₁ ≠ a₂) :
    Metric.infDist x {y : E | ⟪a₁, y⟫_ℝ + b₁ = ⟪a₂, y⟫_ℝ + b₂}
      = |(⟪a₁, x⟫_ℝ + b₁) - (⟪a₂, x⟫_ℝ + b₂)| / ‖a₁ - a₂‖ := by
  convert dist_to_hyperplane_eq ( a₁ - a₂ ) ( b₂ - b₁ ) x ( sub_ne_zero.mpr h ) using 1;
  · congr! 2;
    ext y; simp +decide [ affineHyperplane ] ; ring;
    rw [ inner_sub_left ] ; constructor <;> intro <;> linarith;
  · rw [ inner_sub_left ] ; ring

end