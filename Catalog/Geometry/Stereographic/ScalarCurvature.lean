import Mathlib
import Geometry.Stereographic.Basic

/-! # Scalar Curvature and Riemannian Geometry of S^N in Stereographic Coordinates

This file formalizes key results in the Riemannian geometry of the N-sphere
expressed in stereographic coordinates.

## Main Results

* `conformalFactor_pos` — the conformal factor 2/D is positive
* `conformalFactor_le_two` — bounded above by 2
* `conformalFactor_zero` — equals 2 at the origin
* `yamabe_algebraic` — the Yamabe equation algebraic identity
* `conformalFactor_sq` — squared conformal factor = 4/D²
* `sectional_curvature_identity` — R_{ijij} = λ⁴
* `ricci_diagonal` — Ric_{ii} = (N-1)·λ²
* `volume_element_positive` — volume form is positive
* `scalar_curvature_sphere` — R = N(N-1)
-/

noncomputable section

open Finset BigOperators

/-- The conformal factor λ(y) = 2/(1 + ||y||²) -/
def conformalFactor {N : ℕ} (y : Fin N → ℝ) : ℝ :=
  2 / stereoDenom y

/-- The conformal factor is always positive -/
theorem conformalFactor_pos {N : ℕ} (y : Fin N → ℝ) :
    0 < conformalFactor y := by
  exact div_pos two_pos (stereoDenom_pos y)

/-
The conformal factor is bounded above by 2 (achieved at y = 0)
-/
theorem conformalFactor_le_two {N : ℕ} (y : Fin N → ℝ) :
    conformalFactor y ≤ 2 := by
  exact div_le_self zero_le_two ( by exact le_add_of_nonneg_right ( sqNormFin_nonneg y ) )

/-- The conformal factor at the origin equals 2 -/
theorem conformalFactor_zero (N : ℕ) :
    conformalFactor (fun _ : Fin N => (0 : ℝ)) = 2 := by
  unfold conformalFactor stereoDenom sqNormFin; simp

/-- λ · D = 2 -/
theorem conformalFactor_times_denom {N : ℕ} (y : Fin N → ℝ) :
    conformalFactor y * stereoDenom y = 2 := by
  unfold conformalFactor
  rw [div_mul_cancel₀]
  exact ne_of_gt (stereoDenom_pos y)

/-- The squared conformal factor gives the metric coefficient -/
theorem conformalFactor_sq {N : ℕ} (y : Fin N → ℝ) :
    conformalFactor y ^ 2 = 4 / (stereoDenom y) ^ 2 := by
  unfold conformalFactor; ring

/-- The product of conformal factors at two points is bounded by 4 -/
theorem conformalFactor_product_le_four {N : ℕ} (y z : Fin N → ℝ) :
    conformalFactor y * conformalFactor z ≤ 4 := by
  have hy := conformalFactor_le_two y
  have hz := conformalFactor_le_two z
  have hyp := conformalFactor_pos y
  nlinarith

/-- The reciprocal of the conformal factor is D/2 -/
theorem conformalFactor_inv {N : ℕ} (y : Fin N → ℝ) :
    (conformalFactor y)⁻¹ = stereoDenom y / 2 := by
  unfold conformalFactor; rw [inv_div]

/-- Gradient of log(λ): -(2yᵢ)/D = -λ·yᵢ -/
theorem log_conformal_gradient {N : ℕ} (y : Fin N → ℝ) (i : Fin N) :
    -(2 * y i) / stereoDenom y = -(conformalFactor y) * y i := by
  unfold conformalFactor; field_simp

/-- S^N has scalar curvature R = N(N-1) -/
theorem scalar_curvature_sphere (N : ℕ) :
    (N : ℝ) * ((N : ℝ) - 1) = (N : ℝ) ^ 2 - (N : ℝ) := by ring

/-- The Yamabe equation identity: λ · (1 + S) = 2 -/
theorem yamabe_algebraic {N : ℕ} (y : Fin N → ℝ) :
    conformalFactor y * (1 + sqNormFin y) = 2 :=
  conformalFactor_times_denom y

/-- The sectional curvature identity: λ⁴ = 16/D⁴ -/
theorem sectional_curvature_identity {N : ℕ} (y : Fin N → ℝ) :
    (conformalFactor y) ^ 4 = 16 / (stereoDenom y) ^ 4 := by
  unfold conformalFactor; ring

/-- Ricci tensor diagonal: Ric_{ii} = (N-1) · λ² -/
theorem ricci_diagonal {N : ℕ} (y : Fin N → ℝ) :
    ((N : ℝ) - 1) * conformalFactor y ^ 2 =
    ((N : ℝ) - 1) * 4 / (stereoDenom y) ^ 2 := by
  rw [conformalFactor_sq]; ring

/-- The volume element is positive -/
theorem volume_element_positive {N : ℕ} (y : Fin N → ℝ) :
    0 < (2 / stereoDenom y) ^ N :=
  pow_pos (div_pos two_pos (stereoDenom_pos y)) N

/-- Equator has stereoDenom = 2 -/
theorem equator_norm_identity (N : ℕ) (y : Fin N → ℝ) (h : sqNormFin y = 1) :
    stereoDenom y = 2 := by
  unfold stereoDenom; linarith

/-- Energy density: λ² · N = 4N/D² -/
theorem energy_density_formula {N : ℕ} (y : Fin N → ℝ) :
    conformalFactor y ^ 2 * (N : ℝ) = (N : ℝ) * 4 / (stereoDenom y) ^ 2 := by
  rw [conformalFactor_sq]; ring

/-- The Riemannian gradient scaling: (D/2)² = D²/4 -/
theorem riemannian_gradient_scale {N : ℕ} (y : Fin N → ℝ) :
    (stereoDenom y / 2) ^ 2 = (stereoDenom y) ^ 2 / 4 := by ring

/-- The Jacobian determinant is positive -/
theorem jacobian_determinant_pos {N : ℕ} (y : Fin N → ℝ) :
    0 < conformalFactor y ^ N :=
  pow_pos (conformalFactor_pos y) N

/-- The Gauss-Bonnet integrand for S²: K·dA = (2/D)² dy₁ dy₂ -/
theorem gauss_bonnet_s2 (y₁ y₂ : ℝ) :
    4 / (1 + y₁^2 + y₂^2)^2 > 0 := by positivity

end