/-! # CatalogBuild.Algebra.Core.Trigonometric

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5
-/

import Mathlib
import Pythagorean.Core

noncomputable section

/-- arctan is a homomorphism from (ℝ, spb) to (ℝ, +), for inputs with xy < 1. -/
theorem arctan_spb_hom (x y : ℝ) (hxy : x * y < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb
  exact (Real.arctan_add hxy).symm


/-- The double-angle SPB formula: spb(t,t) = 2t/(1-t²). -/
theorem spb_double_is_tan_double (t : ℝ) :
    spb t t = 2 * t / (1 - t ^ 2) := by
  unfold spb; ring


/-- Machin's formula restated: 4·arctan(1/5) - arctan(1/239) = π/4,
equivalently spb(spb(spb(1/5, 1/5), spb(1/5, 1/5)), -1/239) = 1. -/
theorem machin_via_spb :
    spb (spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5))) (-1/239) = 1 := by
  unfold spb; norm_num


/-- [Section: # SPB and Trigonometric Identities
Connections between SPB and trigonometric functions.
## Main Results
- `arctan_spb_hom`: arctan(spb(x,y)) = arctan(x) + arctan(y) for xy < 1
- `spb_double_is_tan_double`: spb(t,t) = 2t/(1-t²) (double angle formula)
- `machin_via_spb`: Machin's formula via SPB
- `arctan_one`: arctan(1) = π/4
- `weierstrass_sin_via_tan`: sin(2α) = 2tan(α)/(1+tan²(α))
- `weierstrass_cos_via_tan`: cos(2α) = (1-tan²(α))/(1+tan²(α))] -/
theorem weierstrass_sin_via_tan (α : ℝ) (hcos : cos α ≠ 0) :
    sin (2 * α) = 2 * tan α / (1 + tan α ^ 2) := by
  rw [ sin_two_mul, Real.tan_eq_sin_div_cos ];
  field_simp;
  norm_num


/-- [Section: # CatalogBuild.Bridges.SPBBridge.Trigonometric
Auto-generated from theorem catalog database.
Domain: Bridges/SPBBridge
Declarations: 5] -/
theorem weierstrass_cos_via_tan (α : ℝ) (hcos : cos α ≠ 0) :
    cos (2 * α) = (1 - tan α ^ 2) / (1 + tan α ^ 2) := by
  rw [ Real.cos_two_mul, Real.tan_eq_sin_div_cos, div_pow ];
  field_simp;
  rw [ Real.sin_sq ] ; ring


end
