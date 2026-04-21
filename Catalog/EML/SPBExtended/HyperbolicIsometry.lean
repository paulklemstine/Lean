/-! # CatalogBuild.EML.SPBExtended.HyperbolicIsometry

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 16
-/

import Mathlib

noncomputable section

/-- spbH is commutative -/
theorem spbHG_comm (u v : ℝ) : spbHG u v = spbHG v u := by
  simp [spbHG, add_comm, mul_comm]


/-- spbH has identity 0 -/
theorem spbHG_zero (v : ℝ) : spbHG v 0 = v := by simp [spbHG]


/-- spbH has inverse -v -/
theorem spbHG_neg (v : ℝ) : spbHG v (-v) = 0 := by simp [spbHG]


/-- [Section: # SPB and Hyperbolic Geometry
The hyperbolic SPB spbH(u,v) = (u+v)/(1+uv) is an isometry of the
Poincaré disk model of hyperbolic geometry.
## Key Results
- spbH preserves the distance kernel |x-y|/|1-xy|
- The conformal factor transforms covariantly
- The Cayley transform is a group homomorphism
- Connection to the Beltrami-Klein model] -/
theorem spbHG_diff (x y a : ℝ) (hx : 1 + x * a ≠ 0) (hy : 1 + y * a ≠ 0) :
    spbHG x a - spbHG y a = (x - y) * (1 - a ^ 2) / ((1 + x * a) * (1 + y * a)) := by
  unfold spbHG; rw [ div_sub_div _ _ hx hy ] ; ring;


theorem one_sub_spbHG_mul (x y a : ℝ) (hx : 1 + x * a ≠ 0) (hy : 1 + y * a ≠ 0) :
    1 - spbHG x a * spbHG y a =
    (1 - x * y) * (1 - a ^ 2) / ((1 + x * a) * (1 + y * a)) := by
  unfold spbHG; rw [ div_mul_div_comm ] ; rw [ one_sub_div ] ; ring;
  positivity


theorem conformal_transform' (x a : ℝ) (h : 1 + x * a ≠ 0) :
    1 - spbHG x a ^ 2 = (1 - x ^ 2) * (1 - a ^ 2) / (1 + x * a) ^ 2 := by
  unfold spbHG;
  grind


/-- The "velocity addition" is bounded -/
theorem spbHG_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbHG u v| < 1 := by
  rw [abs_lt] at *
  constructor
  · rw [spbHG, lt_div_iff₀] <;> nlinarith
  · rw [spbHG, div_lt_iff₀] <;> nlinarith


theorem cayley_homomorphism' (x y : ℝ)
    (hx : 1 - x ≠ 0) (hy : 1 - y ≠ 0) (hxy : 1 + x * y ≠ 0)
    (hd : 1 - spbHG x y ≠ 0) :
    (1 + spbHG x y) / (1 - spbHG x y) = ((1 + x) / (1 - x)) * ((1 + y) / (1 - y)) := by
  unfold spbHG;
  grind +splitImp


/-- The Jacobian is always positive for |a| < 1 -/
theorem spbHG_jacobian_pos (x a : ℝ) (h : 1 + x * a ≠ 0) (ha : |a| < 1) :
    (1 - a ^ 2) / (1 + x * a) ^ 2 > 0 := by
  apply div_pos
  · have := abs_lt.mp ha; nlinarith
  · positivity


/-- The artanh additive formula identity -/
theorem artanh_additive_formula' (x y : ℝ) :
    (1 + x) * (1 + y) + (1 - x) * (1 - y) = 2 * (1 + x * y) := by ring


/-- The Beltrami-Klein inner product identity -/
theorem beltrami_klein_identity' (u v : ℝ) :
    (1 - u * v) ^ 2 - (u - v) ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) := by ring


/-- The hyperbolic cosine identity (1D case) -/
theorem hyperbolic_cosine_identity' (u v : ℝ) :
    (1 - u * v) ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) + (u - v) ^ 2 := by ring


theorem distance_kernel_ratio (x y a : ℝ)
    (hx : 1 + x * a ≠ 0) (hy : 1 + y * a ≠ 0)
    (hxy : 1 - x * y ≠ 0) (ha : 1 - a ^ 2 ≠ 0)
    (hd : 1 - spbHG x a * spbHG y a ≠ 0) :
    (spbHG x a - spbHG y a) / (1 - spbHG x a * spbHG y a) = (x - y) / (1 - x * y) := by
  rw [ div_eq_div_iff ];
  · unfold spbHG;
    grind;
  · assumption;
  · assumption


/-- Rapidity is a natural parameter -/
theorem rapidity_def' (v : ℝ) (hv : |v| < 1) :
    0 < (1 + v) / (1 - v) := by
  have := abs_lt.mp hv
  apply div_pos <;> linarith


theorem one_plus_spbHG_sq (x a : ℝ) (h : 1 + x * a ≠ 0) :
    1 + spbHG x a ^ 2 = ((1 + x * a) ^ 2 + (x + a) ^ 2) / (1 + x * a) ^ 2 := by
  unfold spbHG;
  field_simp


/-- The Lorentz composition identity -/
theorem lorentz_composition' (u v : ℝ) (h : 1 + u * v ≠ 0) :
    (1 - spbHG u v ^ 2) * (1 + u * v) ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) := by
  unfold spbHG; field_simp; ring


end
