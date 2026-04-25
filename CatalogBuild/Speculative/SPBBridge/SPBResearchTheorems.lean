/-! # CatalogBuild.Speculative.SPBBridge.SPBResearchTheorems

Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 8
-/

import Mathlib

noncomputable section

/-- det(M(a)·M(b)) = (1+a²)(1+b²) -/
theorem spbM_det_mul_expand (a b : ℝ) :
    (spbM a * spbM b).det = (1 + a ^ 2) * (1 + b ^ 2) := by
  rw [spbM_det_mul, spbM_det, spbM_det]


/-- det(M(a)^n) = (1+a²)^n -/
theorem spbM_pow_det (a : ℝ) (n : ℕ) :
    (spbM a ^ n).det = (1 + a ^ 2) ^ n := by
  rw [det_pow, spbM_det]


/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBResearchTheorems
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 8] -/
theorem spb_one_right (x : ℝ) : spb 1 x = (1 + x) / (1 - x) := by
  unfold spb; ring


/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBResearchTheorems
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 8] -/
theorem spbF_neg_neg {F : Type*} [Field F] (x y : F) :
    spbF (-x) (-y) = -spbF x y := by
  unfold spbF; ring


theorem spbF_double {F : Type*} [Field F] (x : F) :
    spbF x x = 2 * x / (1 - x ^ 2) := by
  unfold spbF; ring


/-- The correct sum identity: spb(x,y) + spb(-x,y) = 2y(1+x²)/((1-xy)(1+xy)) -/
theorem spb_sum_neg_first (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb (-x) y = 2 * y * (1 + x ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - -x * y = 1 + x * y := by ring
  rw [h3, div_add_div _ _ h1 h2]
  congr 1
  ring


theorem weierstrass_spb (θ : ℝ) (_hcos : cos (θ / 2) ≠ 0) (_hcos2 : cos θ ≠ 0) :
    spb (tan (θ / 2)) (tan (θ / 2)) = tan θ := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.tan_two_mul ];
  unfold spb; ring;


/-- Note: spb(x, 1/x) is degenerate since x·(1/x) = 1 makes the denominator 0.
In Lean, spb(x, 1/x) = 0 for all x ≠ 0. -/
theorem spb_self_reciprocal_degen (x : ℝ) (hx : x ≠ 0) :
    spb x (1/x) = 0 := by
  simp only [spb, one_div, add_comm x, mul_inv_cancel₀ hx, sub_self, div_zero]


end
