/-! # CatalogBuild.EML.SPBNewTheorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27
-/

import Mathlib

noncomputable section

/-- The SPB norm: N(x) = 1 + x². -/
def normSPB (x : ℝ) : ℝ := 1 + x ^ 2




/-- [Section: # CatalogBuild.EML.SPBNewTheorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 31] -/
theorem spb_preserves_cross_ratio (a b c d t : ℝ)
    (h1 : 1 - a * t ≠ 0) (h2 : 1 - b * t ≠ 0)
    (h3 : 1 - c * t ≠ 0) (h4 : 1 - d * t ≠ 0)
    (hac : (a - d) * (b - c) ≠ 0)
    (hac' : (spb a t - spb d t) * (spb b t - spb c t) ≠ 0) :
    crossRatio (spb a t) (spb b t) (spb c t) (spb d t) =
    crossRatio a b c d := by
  unfold crossRatio;
  unfold SPBNew.spb at *;
  grind




/-- [Section: # CatalogBuild.EML.SPBNewTheorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27] -/
theorem spb_elliptic_classification (a : ℝ) (ha : a ≠ 0) :
    (spbMat a).trace ^ 2 < 4 * (spbMat a).det := by
  norm_num [ spbMat, Matrix.det_fin_two ] ; nlinarith [ mul_self_pos.2 ha ]




theorem projSPB_eq_affine (x y : ℝ) (hd : 1 - x * y ≠ 0) :
    (projSPB x 1 y 1).1 / (projSPB x 1 y 1).2 = spb x y := by
  unfold projSPB spb; ring




theorem projSPB_comm (x₁ x₂ y₁ y₂ : ℝ) :
    projSPB x₁ x₂ y₁ y₂ = projSPB y₁ y₂ x₁ x₂ := by
  unfold projSPB; ring;




theorem projSPB_identity (x₁ x₂ : ℝ) :
    projSPB x₁ x₂ 0 1 = (x₁, x₂) := by
  unfold projSPB; aesop;




theorem projSPB_norm_mul (x₁ x₂ y₁ y₂ : ℝ) :
    (x₁^2 + x₂^2) * (y₁^2 + y₂^2) =
    (projSPB x₁ x₂ y₁ y₂).1^2 + (projSPB x₁ x₂ y₁ y₂).2^2 := by
  unfold projSPB; ring;




theorem spb_infinitesimal_generator (x : ℝ) :
    HasDerivAt (fun ε => spb x ε) (1 + x ^ 2) 0 := by
  unfold spb; convert HasDerivAt.div ( hasDerivAt_id 0 |> HasDerivAt.const_add x ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id 0 ) ) ) _ using 1 <;> norm_num;
  ring




/-- V(x) = 1 + x² is always positive (flow is always rightward). -/
theorem spb_generator_pos (x : ℝ) : (1 : ℝ) + x ^ 2 > 0 := by positivity




theorem cauchy_density_reciprocal (x : ℝ) :
    (1 + x ^ 2) * (1 / (Real.pi * (1 + x ^ 2))) = 1 / Real.pi := by
  rw [ mul_one_div, mul_comm ];
  rw [ ← div_div, div_self ( by positivity ) ]




theorem cocycle_geometric_series (x y : ℝ) (hxy : |x * y| < 1) :
    HasSum (fun n => (x * y) ^ n) (1 / (1 - x * y)) := by
  simpa using hasSum_geometric_of_abs_lt_one hxy




theorem cocycle_two_cocycle (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) =
    (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; ring;
  grind




/-- spbPow 0 returns 0 (the identity). -/
theorem spbPow_zero (x : ℝ) : spbPow 0 x = 0 := by simp [spbPow]




/-- Key DH algebraic identity: (a+b) · arctan(g) = a · arctan(g) + b · arctan(g).
This is the foundation for the DH shared secret: both parties compute
tan((a+b) · arctan(g)) by different routes. -/
theorem spb_dh_angle_add (a b : ℕ) (g : ℝ) :
    (↑(a + b) : ℝ) * Real.arctan g = ↑a * Real.arctan g + ↑b * Real.arctan g := by
  push_cast; ring




/-- The key Cauchy pullback identity: the SPB Jacobian transforms Cauchy densities correctly.
1/(1 + spb(x,a)²) · (1+a²)/(1-xa)² = (1+a²)/((1+x²)(1+a²)/(1-xa)²) ... simplifies to
the fundamental identity: (1 + spb(x,a)²) · (1-xa)² = (1+x²)(1+a²). -/
theorem cauchy_pullback_identity (a x : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spb x a ^ 2) * (1 - x * a) ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) := by
  unfold spb; field_simp; ring




/-- The d=1 division algebra construction: given SPB on ℝ,
define multiplication on ℝ² by (a,b)·(c,d) = (ac-bd, ad+bc).
This is complex number multiplication. -/
def complexMul (p q : ℝ × ℝ) : ℝ × ℝ :=
  (p.1 * q.1 - p.2 * q.2, p.1 * q.2 + p.2 * q.1)




/-- The norm on ℝ² is N(a,b) = a² + b². -/
def complexNorm (p : ℝ × ℝ) : ℝ := p.1 ^ 2 + p.2 ^ 2




theorem complexNorm_mul (p q : ℝ × ℝ) :
    complexNorm (complexMul p q) = complexNorm p * complexNorm q := by
  unfold complexNorm complexMul; ring;




theorem complex_mul_spb_connection (x y : ℝ) :
    complexMul (1, x) (1, y) = (1 - x * y, x + y) := by
  unfold complexMul; ring;




theorem complex_norm_eq_spb_norm (x : ℝ) :
    complexNorm (1, x) = normSPB x := by
  unfold complexNorm;
  unfold normSPB; ring




/-- For all a, tr(M(a)) = 2 (constant trace). -/
theorem spbMat_trace_constant (a : ℝ) :
    (spbMat a).trace = 2 := spbMat_trace a




theorem spb_discriminant_nonpos (a : ℝ) :
    (spbMat a).trace ^ 2 - 4 * (spbMat a).det = -(4 * a ^ 2) := by
  unfold spbMat; norm_num; ring;




theorem spb_discriminant_neg (a : ℝ) (ha : a ≠ 0) :
    (spbMat a).trace ^ 2 - 4 * (spbMat a).det < 0 := by
  unfold spbMat; norm_num; nlinarith [ mul_self_pos.2 ha ] ;




theorem spbH_contraction (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spbH x y| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hx, abs_lt.mp hy ] ⟩




theorem wick_norm_circular (x y : ℝ) :
    (1 + x^2) * (1 + y^2) = (1 - x*y)^2 + (x + y)^2 := by
  ring




theorem wick_norm_hyperbolic (x y : ℝ) :
    (1 - x^2) * (1 - y^2) = (1 + x*y)^2 - (x + y)^2 := by
  ring




theorem spbMat_det_prod (as : List ℝ) :
    (as.map spbMat).prod.det = (as.map (fun a => 1 + a^2)).prod := by
  induction as <;> simp_all +decide [ Matrix.det_fin_two ];
  unfold spbMat; norm_num; ring; aesop;




end
