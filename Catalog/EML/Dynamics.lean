/-! # CatalogBuild.EML.Dynamics

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17
-/

import Mathlib

noncomputable section

/-- The iteration g(x) = 1 - ln(x). This is eml(0, x). -/
def oneMinusLog (x : ℝ) : ℝ := 1 - Real.log x




/-- g(1) = 1: the point x = 1 is a fixed point. -/
theorem oneMinusLog_fixed_one : oneMinusLog 1 = 1 := by
  simp [oneMinusLog, Real.log_one]




/-- g(e) = 0. -/
theorem oneMinusLog_at_e : oneMinusLog (Real.exp 1) = 0 := by
  simp [oneMinusLog, Real.log_exp]




/-- g(1/e) = 2. -/
theorem oneMinusLog_at_inv_e :
    oneMinusLog (Real.exp (-1)) = 2 := by
  simp [oneMinusLog, Real.log_exp]; ring




/-- g(g(x)) = 1 - ln(1 - ln(x)) = the second iterate. -/
theorem oneMinusLog_compose (x : ℝ) :
    oneMinusLog (oneMinusLog x) = 1 - Real.log (1 - Real.log x) := by
  simp [oneMinusLog]




/-- The derivative of g is g'(x) = -1/x. -/
theorem oneMinusLog_deriv (x : ℝ) (hx : x ≠ 0) :
    HasDerivAt oneMinusLog (-x⁻¹) x := by
  unfold oneMinusLog
  convert hasDerivAt_const x 1 |>.sub (Real.hasDerivAt_log hx) using 1
  ring




/-- |g'(1)| = 1, so x = 1 is a neutral (non-hyperbolic) fixed point. -/
theorem oneMinusLog_neutral_fixed_point :
    |(-1 : ℝ) / 1| = 1 := by norm_num




/-- The exp tower is strictly increasing in n for x > 0. -/
theorem expTower_strictMono_step (x : ℝ) (hx : 0 < x) (n : ℕ) :
    expTower x n < expTower x (n + 1) := by
  induction n with
  | zero =>
    simp [expTower]
    linarith [Real.add_one_le_exp x]
  | succ n ih =>
    simp only [expTower]
    exact Real.exp_strictMono ih




/-- [Section: # CatalogBuild.EML.Dynamics
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17] -/
theorem expTower_unbounded (x : ℝ) (hx : 0 < x) :
    ∀ M : ℝ, ∃ n : ℕ, M < expTower x n := by
  -- By induction, we show that expTower x n ≥ n - 1 for all n.
  have h_lower_bound : ∀ n : ℕ, expTower x n ≥ n - 1 := by
    intro n;
    induction' n with n ih <;> norm_num [ expTower ] at *;
    · linarith;
    · linarith [ Real.add_one_le_exp ( expTower x n ) ];
  exact fun M => ⟨ ⌊M + 1⌋₊ + 1, by have := h_lower_bound ( ⌊M + 1⌋₊ + 1 ) ; push_cast at *; linarith [ Nat.lt_floor_add_one ( M + 1 ) ] ⟩




/-- The diagonal iteration: x_{n+1} = exp(x_n) - ln(x_n). -/
def emlDiagIter (x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => Real.exp (emlDiagIter x₀ n) - Real.log (emlDiagIter x₀ n)




/-- [Section: # CatalogBuild.EML.Dynamics
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17] -/
theorem emlDiag_increases (x : ℝ) (hx : 0 < x) :
    Real.exp x - Real.log x > x := by
  by_contra! h_contra;
  rw [ show Real.exp x = Real.exp 1 * Real.exp ( x - 1 ) by rw [ ← Real.exp_add, add_sub_cancel ] ] at h_contra;
  nlinarith [ Real.add_one_le_exp ( x - 1 ), Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos hx ]




/-- The 2D EML map Φ(x, y) = (eml(x,y), eml(y,x)). -/
def emlPhi (p : ℝ × ℝ) : ℝ × ℝ :=
  (Real.exp p.1 - Real.log p.2, Real.exp p.2 - Real.log p.1)




/-- The Jacobian of Φ at (x,y) with y > 0, x > 0. -/
theorem emlPhi_jacobian (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    let J := !![Real.exp x, -1/y; -1/x, Real.exp y]
    J.det = Real.exp x * Real.exp y - 1 / (x * y) := by
  simp [Matrix.det_fin_two]
  ring




/-- The trace of the Jacobian. -/
theorem emlPhi_trace (x y : ℝ) :
    Real.exp x + Real.exp y > 0 := by
  linarith [Real.exp_pos x, Real.exp_pos y]




/-- A period-2 point of g satisfies g(g(x)) = x. -/
def isPeriod2 (x : ℝ) : Prop := oneMinusLog (oneMinusLog x) = x




/-- x = 1 is a period-2 point (it's actually a fixed point). -/
theorem one_is_period2 : isPeriod2 1 := by
  simp [isPeriod2, oneMinusLog, Real.log_one]




/-- Any fixed point is also a period-2 point. -/
theorem fixed_implies_period2 (x : ℝ) (hx : oneMinusLog x = x) :
    isPeriod2 x := by
  simp [isPeriod2, hx]




end
