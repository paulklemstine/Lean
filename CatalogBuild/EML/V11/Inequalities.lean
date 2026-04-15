/-! # CatalogBuild.EML.V11.Inequalities

Auto-generated from theorem catalog database.
Domain: EML/V11
Declarations: 16
-/

import Mathlib

noncomputable section

/-- Bregman divergence of exp: D_exp(x,y) = exp(x) - exp(y) - exp(y)(x-y). -/
def bregmanExp (x y : ℝ) : ℝ :=
  Real.exp x - Real.exp y - Real.exp y * (x - y)


/-- AM-GM for two positive reals: (a + b)/2 ≥ √(ab). -/
theorem eml_amgm (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a + b) / 2 ≥ Real.sqrt (a * b) := by
  rw [ge_iff_le]
  have h1 : 0 ≤ (a + b) / 2 := by linarith
  rw [← Real.sqrt_sq h1]
  exact Real.sqrt_le_sqrt (by nlinarith [sq_nonneg (a - b)])


/-- EML form of AM-GM: eml(ln a, a) = a − ln a ≥ 1 for a > 0. -/
theorem eml_amgm_form (a : ℝ) (ha : 0 < a) :
    eml (Real.log a) a ≥ 1 := by
  unfold eml; rw [Real.exp_log ha]
  linarith [Real.log_le_sub_one_of_pos ha]


/-- The fundamental EML inequality: eml(x, y) ≥ 1 + x − log(y) for all x, y. -/
theorem eml_fundamental_ineq (x y : ℝ) :
    eml x y ≥ 1 + x - Real.log y := by
  unfold eml; linarith [Real.add_one_le_exp x]


/-- EML at y = 1: eml(x, 1) = exp(x) ≥ x + 1. -/
theorem eml_at_one_ge (x : ℝ) : eml x 1 ≥ x + 1 := by
  unfold eml; simp [Real.log_one]; linarith [Real.add_one_le_exp x]


/-- Reverse: eml(x,y) ≤ exp(x) for y ≥ 1. -/
theorem eml_le_exp (x y : ℝ) (hy : 1 ≤ y) :
    eml x y ≤ Real.exp x := by
  unfold eml; linarith [Real.log_nonneg hy]


/-- Bregman divergence of exp is nonneg. -/
theorem bregmanExp_nonneg (x y : ℝ) : bregmanExp x y ≥ 0 := by
  unfold bregmanExp
  have := Real.add_one_le_exp (x - y)
  rw [show x = y + (x - y) by ring, Real.exp_add]
  nlinarith [Real.exp_pos y, Real.exp_pos (x - y)]


/-- Bregman divergence equals zero iff x = y. -/
theorem bregmanExp_eq_zero_iff (x y : ℝ) :
    bregmanExp x y = 0 ↔ x = y := by
  constructor <;> intro h
  · contrapose! h; unfold bregmanExp
    cases lt_or_gt_of_ne h <;>
      have := Real.add_one_lt_exp (sub_ne_zero_of_ne h) <;>
      simp_all +decide [Real.exp_sub]
    · rw [lt_div_iff₀] at this <;> nlinarith [Real.exp_pos x, Real.exp_pos y]
    · rw [lt_div_iff₀] at this <;> nlinarith [Real.exp_pos x, Real.exp_pos y]
  · unfold bregmanExp; aesop


/-- Bregman divergence is NOT symmetric. -/
theorem bregmanExp_not_symmetric :
    ∃ x y : ℝ, bregmanExp x y ≠ bregmanExp y x := by
  use 1, 0; norm_num [bregmanExp]
  exact ne_of_lt (by have := Real.exp_one_lt_d9.le; norm_num1 at *; linarith)


/-- Young's inequality (special case p=q=2): ab ≤ (a² + b²)/2. -/
theorem young_ineq_special (a b : ℝ) :
    a * b ≤ (a ^ 2 + b ^ 2) / 2 := by
  nlinarith [sq_nonneg (a - b)]


/-- [Section: ## Section 4: Self-Pairing Bounds] -/
theorem emlSelfPair_ge_half_exp (x : ℝ) (hx : 1 ≤ x) :
    emlSelfPair x ≥ Real.exp x / 2 := by
  unfold emlSelfPair;
  rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( x - 1 ) ]


/-- d(1) = e (exact value). -/
theorem emlDiag_at_one : emlDiag 1 = Real.exp 1 := by
  unfold emlDiag; simp [Real.log_one]


/-- [Section: ## Section 5: Diagonal Map Inequalities] -/
theorem emlDiag_ge_e_ge_one (z : ℝ) (hz : 1 ≤ z) :
    emlDiag z ≥ Real.exp 1 := by
  unfold emlDiag;
  rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( z - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]


/-- [Section: ## Section 6: EML and Entropy Bounds] -/
theorem eml_entropy_bound (p : ℝ) (hp : 0 < p) :
    -p * Real.log p ≤ p * eml 0 p := by
  unfold eml; nlinarith [ Real.add_one_le_exp 0, Real.log_le_sub_one_of_pos hp ] ;


/-- eml(eml(x,y), 1) ≥ eml(x,y) + 1 (composition with y=1). -/
theorem eml_compose_bound (x y : ℝ) :
    eml (eml x y) 1 ≥ eml x y + 1 :=
  eml_at_one_ge (eml x y)


/-- For |x| ≤ 1: σ(x) ≥ x² (since σ(x) ≥ 1 ≥ x²). -/
theorem emlSelfPair_dominates_sq_unit (x : ℝ) (hx : |x| ≤ 1) :
    emlSelfPair x ≥ x ^ 2 := by
  have h1 : emlSelfPair x ≥ 1 := emlSelfPair_ge_one x
  have h2 : x ^ 2 ≤ 1 := by
    rw [abs_le] at hx; nlinarith
  linarith


end
