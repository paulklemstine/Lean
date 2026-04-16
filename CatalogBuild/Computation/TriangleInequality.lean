/-! # CatalogBuild.Computation.TriangleInequality

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 19
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.TriangleInequality
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 19] -/
def D_eml (x y : ℝ) : ℝ := Real.exp x + Real.exp y - Real.log x - Real.log y - 2



theorem D_eml_symm (x y : ℝ) : D_eml x y = D_eml y x := by
  simp [D_eml]; ring



theorem D_eml_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) : D_eml x y > 0 := by
  simp only [D_eml]
  nlinarith [quadratic_le_exp_of_nonneg hx.le, quadratic_le_exp_of_nonneg hy.le,
    Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy,
    sq_nonneg x, sq_nonneg y]



theorem D_eml_diag (x : ℝ) : D_eml x x = 2 * (Real.exp x - Real.log x - 1) := by
  simp [D_eml]; ring



theorem D_eml_diag_ge_two (x : ℝ) (hx : 0 < x) : D_eml x x ≥ 2 := by
  rw [D_eml_diag]
  nlinarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]



def f_eml (x : ℝ) : ℝ := Real.exp x - Real.log x - 1



/-- D(x,y) = f(x) + f(y). D is SEPARABLE. -/
theorem D_eml_separable (x y : ℝ) : D_eml x y = f_eml x + f_eml y := by
  simp [D_eml, f_eml]; ring



theorem f_eml_pos (x : ℝ) (hx : 0 < x) : f_eml x > 0 := by
  simp [f_eml]
  nlinarith [quadratic_le_exp_of_nonneg hx.le, Real.log_le_sub_one_of_pos hx, sq_nonneg x]



theorem f_eml_ge_one (x : ℝ) (hx : 0 < x) : f_eml x ≥ 1 := by
  simp [f_eml]
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]



/-- Triangle inequality for D — immediate from separability. -/
theorem D_eml_triangle (x y z : ℝ) (_hx : 0 < x) (hy : 0 < y) (_hz : 0 < z) :
    D_eml x z ≤ D_eml x y + D_eml y z := by
  rw [D_eml_separable, D_eml_separable, D_eml_separable]
  linarith [f_eml_pos y hy]



/-- Derived metric: d(x,y) = |f(x) - f(y)|. -/
def d_eml_metric (x y : ℝ) : ℝ := |f_eml x - f_eml y|



theorem d_eml_metric_symm (x y : ℝ) : d_eml_metric x y = d_eml_metric y x := by
  simp [d_eml_metric, abs_sub_comm]



theorem d_eml_metric_self (x : ℝ) : d_eml_metric x x = 0 := by
  simp [d_eml_metric]



theorem d_eml_metric_triangle (x y z : ℝ) :
    d_eml_metric x z ≤ d_eml_metric x y + d_eml_metric y z := by
  simp only [d_eml_metric]
  have h : f_eml x - f_eml z = (f_eml x - f_eml y) + (f_eml y - f_eml z) := by ring
  calc |f_eml x - f_eml z|
      = |(f_eml x - f_eml y) + (f_eml y - f_eml z)| := by rw [h]
    _ ≤ |f_eml x - f_eml y| + |f_eml y - f_eml z| := abs_add_le _ _



theorem d_eml_metric_zero_iff (x y : ℝ) :
    d_eml_metric x y = 0 ↔ f_eml x = f_eml y := by
  simp [d_eml_metric, abs_eq_zero, sub_eq_zero]



theorem f_eml_convex : ConvexOn ℝ (Set.Ioi 0) f_eml := by
  have h1 : ConvexOn ℝ (Set.Ioi 0) (fun x => Real.exp x - Real.log x) :=
    (convexOn_exp.subset (Set.subset_univ _) (convex_Ioi 0)).sub
      strictConcaveOn_log_Ioi.concaveOn
  exact h1.sub (concaveOn_const 1 (convex_Ioi 0))



def bregman_eml (x y : ℝ) : ℝ :=
  f_eml x - f_eml y - (Real.exp y - y⁻¹) * (x - y)



theorem bregman_eml_self (x : ℝ) : bregman_eml x x = 0 := by
  simp [bregman_eml]



theorem bregman_eml_nonneg (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    bregman_eml x y ≥ 0 := by
      unfold bregman_eml;
      rw [ show f_eml x = Real.exp x - Real.log x - 1 by rfl, show f_eml y = Real.exp y - Real.log y - 1 by rfl ];
      -- We'll use the fact that $e^x$ is convex to show that $e^x - e^y \geq e^y (x - y)$ for $x, y > 0$.
      have h_exp_convex : ∀ x y : ℝ, 0 < x → 0 < y → Real.exp x - Real.exp y ≥ Real.exp y * (x - y) := by
        exact fun x y hx hy => by rw [ show x = y + ( x - y ) by ring, Real.exp_add ] ; nlinarith [ Real.exp_pos y, Real.exp_pos ( x - y ), Real.add_one_le_exp ( x - y ) ] ;
      -- We'll use the fact that $-\log x$ is convex to show that $-\log x + \log y \geq -y^{-1} (x - y)$ for $x, y > 0$.
      have h_log_convex : ∀ x y : ℝ, 0 < x → 0 < y → -Real.log x + Real.log y ≥ -y⁻¹ * (x - y) := by
        intros x y hx hy; have := Real.log_le_sub_one_of_pos ( div_pos hx hy ) ; rw [ Real.log_div ] at this <;> ring_nf at * <;> nlinarith [ inv_pos.2 hy, mul_inv_cancel₀ hy.ne' ] ;
      grind



end
