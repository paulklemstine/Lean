import Mathlib

/-!
# From optimal cake portions to the plastic number and a substitution matrix

The constant governing two-slice portions is usually presented as `μ = 1 + ρ`,
where `0 < ρ < 1` and `ρ³ + ρ² = 1`.  This file proves an exact bridge to two
apparently different subjects:

* the **plastic number**, the positive root `p` of `p³ = p + 1`, familiar from
  the Padovan recurrence; and
* a positive eigenvalue of the nonnegative substitution matrix
  `[[0,1,0],[0,0,1],[1,1,0]]`.

Precisely, `p = ρ⁻¹`, the portion constant is `μ = p²`, and
`(1,p,p²)` is a strictly positive eigenvector of that matrix with eigenvalue
`p`.  Thus the same algebraic scaling controls cake balancing, a linear
recurrence, and a three-state substitution dynamics.
-/

namespace CakePlasticSpectralBridge

open Set Matrix

/-- The polynomial defining the cake scaling constant. -/
def cakePoly (x : ℝ) : ℝ := x ^ 3 + x ^ 2

lemma cakePoly_strictMonoOn : StrictMonoOn cakePoly (Set.Ici 0) := by
  exact fun x hx y hy hxy => by
    unfold cakePoly
    nlinarith [hx.out, hy.out, pow_two_nonneg (y - x), pow_two_nonneg (x + y)]

lemma rho_exists_unique : ∃! x : ℝ, x ∈ Set.Ioo (0 : ℝ) 1 ∧ cakePoly x = 1 := by
  apply_rules [existsUnique_of_exists_of_unique]
  · apply_rules [intermediate_value_Ioo] <;> norm_num [cakePoly]
    exact Continuous.continuousOn (by unfold cakePoly; continuity)
  · exact fun y₁ y₂ h₁ h₂ => StrictMonoOn.injOn cakePoly_strictMonoOn h₁.1.1.le h₂.1.1.le <| h₁.2.trans h₂.2.symm

/-- The cake scaling constant `ρ`, uniquely determined in `(0,1)`. -/
noncomputable def rho : ℝ := Classical.choose (ExistsUnique.exists rho_exists_unique)

lemma rho_spec : rho ∈ Set.Ioo (0 : ℝ) 1 ∧ cakePoly rho = 1 := by
  exact Classical.choose_spec (ExistsUnique.exists rho_exists_unique)

lemma rho_pos : 0 < rho := rho_spec.1.1
lemma rho_lt_one : rho < 1 := rho_spec.1.2
lemma rho_equation : rho ^ 3 + rho ^ 2 = 1 := rho_spec.2

/-- The proposed optimal two-slice portion ratio. -/
noncomputable def portionConstant : ℝ := 1 + rho

/-- The reciprocal cake scale. -/
noncomputable def plastic : ℝ := rho⁻¹

/-
The reciprocal scale is the plastic number: `p³ = p + 1`.
-/
theorem plastic_cubic : plastic ^ 3 = plastic + 1 := by
  grind +locals

lemma plastic_pos : 0 < plastic := by
  exact inv_pos.mpr rho_pos

/-
The first bridge: the cake portion ratio is the square of the plastic number.
-/
theorem portionConstant_eq_plastic_sq : portionConstant = plastic ^ 2 := by
  grind +locals

/-- The Padovan transition/substitution matrix. -/
def padovanMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  !![0, 1, 0;
     0, 0, 1;
     1, 1, 0]

/-- Its canonical positive eigenvector. -/
noncomputable def plasticEigenvector : Fin 3 → ℝ := ![1, plastic, plastic ^ 2]

/-
The plastic vector is strictly positive coordinatewise.
-/
theorem plasticEigenvector_pos (i : Fin 3) : 0 < plasticEigenvector i := by
  fin_cases i <;> norm_num [ plastic_pos, plasticEigenvector ]

/-
The second bridge: the plastic number is an eigenvalue of the Padovan
transition matrix, witnessed by a strictly positive eigenvector.
-/
theorem padovanMatrix_mulVec :
    padovanMatrix *ᵥ plasticEigenvector = plastic • plasticEigenvector := by
  ext i;
  fin_cases i <;> norm_num [ Matrix.mulVec ];
  · unfold padovanMatrix plasticEigenvector; norm_num [ dotProduct ] ;
    norm_num [ Fin.sum_univ_succ ];
  · unfold plasticEigenvector; norm_num [ Matrix.vecHead, Matrix.vecTail, dotProduct ] ; ring;
    simp +decide [ Fin.sum_univ_succ, padovanMatrix ];
  · unfold padovanMatrix plasticEigenvector; norm_num [ Fin.sum_univ_succ, dotProduct ] ; ring;
    linarith [ plastic_cubic ]

/-
Combined connector theorem: the cake constant is the square of a positive
matrix eigenvalue.  This packages the exact bridge between circular cake
balancing and substitution/recurrence dynamics.
-/
theorem cake_ratio_is_square_of_positive_matrix_eigenvalue :
    portionConstant = plastic ^ 2 ∧
      (∀ i, 0 < plasticEigenvector i) ∧
      padovanMatrix *ᵥ plasticEigenvector = plastic • plasticEigenvector := by
  exact ⟨portionConstant_eq_plastic_sq, plasticEigenvector_pos, padovanMatrix_mulVec⟩

/-
The plastic eigenvalue lies strictly between `1` and `2`.
-/
theorem one_lt_plastic_lt_two : 1 < plastic ∧ plastic < 2 := by
  constructor
  · exact lt_of_le_of_lt (by norm_num) (inv_strictAnti₀ rho_pos rho_lt_one)
  · -- Since `rho > 1/2`, we have `plastic = rho⁻¹ < 2`.
    have h_rho_gt_half : 1 / 2 < rho := by
      nlinarith [rho_spec.1.1, rho_spec.1.2, rho_equation]
    exact inv_lt_of_inv_lt₀ (by norm_num) (by linarith)

/-
Consequently the portion constant lies strictly between `1` and `2`.
-/
theorem one_lt_portionConstant_lt_two : 1 < portionConstant ∧ portionConstant < 2 := by
  constructor <;> norm_num [portionConstant, portionConstant_eq_plastic_sq, one_lt_plastic_lt_two]
  · exact rho_pos;
  · linarith [ rho_lt_one ]

end CakePlasticSpectralBridge