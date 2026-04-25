/-! # CatalogBuild.Geometry.Stereographic.MoebiusGroup

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10
-/

import Geometry.Stereographic.Basic
import Mathlib

noncomputable section

/-- 1D Möbius transformation z ↦ (az+b)/(cz+d) -/
def moebius1D (a b c d : ℝ) (z : ℝ) : ℝ := (a * z + b) / (c * z + d)




/-- [Section: # CatalogBuild.Geometry.Stereographic.MoebiusGroup
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
theorem moebius_1d_composition (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ z : ℝ)
    (h₁ : c₂ * z + d₂ ≠ 0) (h₂ : c₁ * ((a₂ * z + b₂) / (c₂ * z + d₂)) + d₁ ≠ 0) :
    moebius1D a₁ b₁ c₁ d₁ (moebius1D a₂ b₂ c₂ d₂ z) =
    moebius1D (a₁ * a₂ + b₁ * c₂) (a₁ * b₂ + b₁ * d₂)
              (c₁ * a₂ + d₁ * c₂) (c₁ * b₂ + d₁ * d₂) z := by
                unfold moebius1D;
                grind




/-- [Section: # CatalogBuild.Geometry.Stereographic.MoebiusGroup
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
theorem moebius_1d_id (z : ℝ) : moebius1D 1 0 0 1 z = z := by
  unfold moebius1D; norm_num;




theorem moebius_1d_inversion (z : ℝ) (hz : z ≠ 0) :
    moebius1D 0 1 1 0 z = 1 / z := by
      unfold moebius1D; ring




theorem moebius_1d_translation (a z : ℝ) :
    moebius1D 1 a 0 1 z = z + a := by
      unfold moebius1D; ring;




theorem moebius_1d_scaling (s z : ℝ) :
    moebius1D s 0 0 1 z = s * z := by
      unfold moebius1D; ring




theorem cross_ratio_translation_invariant (a z₁ z₂ z₃ z₄ : ℝ) :
    ((z₁ + a) - (z₃ + a)) * ((z₂ + a) - (z₄ + a)) =
    (z₁ - z₃) * (z₂ - z₄) := by
      ring




theorem cayley_transform_real_to_circle (t : ℝ) :
    ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 + (2 * t / (t ^ 2 + 1)) ^ 2 = 1 := by
      field_simp
      ring




theorem sqNormFin_translate {N : ℕ} (y a : Fin N → ℝ) :
    sqNormFin (fun i => y i + a i) =
    sqNormFin y + 2 * ∑ i, y i * a i + sqNormFin a := by
      unfold sqNormFin;
      simp +decide only [add_sq, mul_assoc, sum_add_distrib, Finset.mul_sum _ _ _]




theorem sqNormFin_scale {N : ℕ} (y : Fin N → ℝ) (r : ℝ) :
    sqNormFin (fun i => r * y i) = r ^ 2 * sqNormFin y := by
      unfold sqNormFin; rw [ Finset.mul_sum ] ; exact Finset.sum_congr rfl fun _ _ => by ring;




end
