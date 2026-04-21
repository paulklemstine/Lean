/-! # CatalogBuild.Bridges.SPBApplications

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 16
-/

import Mathlib
import Pythagorean.AlgebraicIdentities
import Pythagorean.Core

noncomputable section

/-- Successive Lorentz boosts: the gamma factor compounds. -/
theorem successive_boosts (u v : ℝ) (huv : 1 + u * v ≠ 0) :
    (1 - spbH u v ^ 2) * (1 + u * v) ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) := by
  unfold spbH; field_simp; ring



/-- Relativistic momentum-velocity relation. -/
theorem momentum_velocity (v : ℝ) (h : 1 + v * v ≠ 0) :
    spbH v v = 2 * v / (1 + v ^ 2) := by
  unfold spbH; ring



/-- Three-boost composition: spbH(spbH(u,v), w). -/
theorem three_boost (u v w : ℝ) (h1 : 1 + u * v ≠ 0) (h2 : 1 + v * w ≠ 0)
    (h3 : 1 + spbH u v * w ≠ 0) (h4 : 1 + u * spbH v w ≠ 0) :
    spbH (spbH u v) w = spbH u (spbH v w) := by
  unfold spbH at *; field_simp; ring



/-- Einstein velocity addition is bounded by 1. -/
theorem einstein_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 :=
  SPBAlgebra.spbH_bounded u v hu hv



/-- Phase addition rule: clearing denominators. -/
theorem phase_addition (f1 f2 : ℝ) (h : 1 - f1 * f2 ≠ 0) :
    spb f1 f2 * (1 - f1 * f2) = f1 + f2 := by
  unfold spb; field_simp



/-- Scaling property: spb(kx, ky) = k(x+y)/(1-k²xy). -/
theorem spb_scaled (k x y : ℝ) (h : 1 - k * x * (k * y) ≠ 0) :
    spb (k * x) (k * y) = k * (x + y) / (1 - k ^ 2 * (x * y)) := by
  unfold spb; congr 1 <;> ring



/-- Tangent of angle between two lines with slopes m₁ and m₂. -/
theorem angle_between_slopes (m1 m2 : ℝ) :
    spb m1 (-m2) = (m1 - m2) / (1 + m1 * m2) := by
  unfold spb; ring



/-- Reflection composition angle. -/
theorem reflection_composition_angle (m1 m2 : ℝ) :
    spb m2 (-m1) = (m2 - m1) / (1 + m2 * m1) := by
  unfold spb; ring



/-- Two 45° rotations: 1 - 1·1 = 0 (undefined = ∞ = tan(90°)). -/
theorem rotation_90_pole : 1 - (1 : ℝ) * 1 = 0 := by norm_num



/-- spb(1/2, 1/2) = 4/3 (approximating tan(2·arctan(1/2))). -/
theorem two_arctan_half : spb (1/2 : ℝ) (1/2) = 4/3 := by unfold spb; norm_num



/-- Returns bounded in (-1, 1) compose via spbH, staying bounded. -/
theorem return_composition (r1 r2 : ℝ) (h1 : |r1| < 1) (h2 : |r2| < 1) :
    |spbH r1 r2| < 1 := einstein_bounded r1 r2 h1 h2



/-- The growth factor (1+r)/(1-r) is multiplicative under spbH. -/
theorem log_growth_additive (r1 r2 : ℝ)
    (h1 : r1 ≠ 1) (h2 : r2 ≠ 1)
    (huv : 1 + r1 * r2 ≠ 0) (hs : spbH r1 r2 ≠ 1) :
    (1 + spbH r1 r2) / (1 - spbH r1 r2) =
    ((1 + r1) / (1 - r1)) * ((1 + r2) / (1 - r2)) := by
  unfold spbH; field_simp; ring



/-- Workspace boundary condition. -/
theorem workspace_boundary (t1 t2 c : ℝ) (h : 1 - t1 * t2 ≠ 0) :
    spb t1 t2 = c ↔ t1 + t2 = c * (1 - t1 * t2) := by
  unfold spb; rw [div_eq_iff h]



/-- Mechanism Jacobian: ∂(spb(t₁,t₂))/∂t₁ = (1+t₂²)/(1-t₁t₂)². -/
theorem mechanism_jacobian (t1 t2 : ℝ) (h : 1 - t1 * t2 ≠ 0) :
    HasDerivAt (fun t => spb t t2) ((1 + t2 ^ 2) / (1 - t1 * t2) ^ 2) t1 := by
  unfold spb
  have := HasDerivAt.div
    (HasDerivAt.add (hasDerivAt_id t1) (hasDerivAt_const t1 t2))
    (HasDerivAt.sub (hasDerivAt_const t1 1) (HasDerivAt.mul_const (hasDerivAt_id t1) t2))
    h
  convert this using 1; simp [id]; field_simp; ring



/-- Half-angle tangent to sine: 2t/(1+t²) · (1+t²) = 2t. -/
theorem half_angle_tan_sin (t : ℝ) (h : 1 + t ^ 2 ≠ 0) :
    2 * t / (1 + t ^ 2) * (1 + t ^ 2) = 2 * t := by field_simp



/-- Half-angle tangent to cosine: (1-t²)/(1+t²) · (1+t²) = 1-t². -/
theorem half_angle_tan_cos (t : ℝ) (h : 1 + t ^ 2 ≠ 0) :
    (1 - t ^ 2) / (1 + t ^ 2) * (1 + t ^ 2) = 1 - t ^ 2 := by field_simp



end
