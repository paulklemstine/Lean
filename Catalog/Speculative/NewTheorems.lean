/-! # CatalogBuild.Speculative.NewTheorems

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 49
-/

import Mathlib

noncomputable section

/-- The real EML operator: EML(a, b) = exp(a) - ln(b). -/
def EML9 (a b : ℝ) : ℝ := Real.exp a - Real.log b




/-- The diagonal map: d(x) = exp(x) - ln(x). -/
def diagMap9 (x : ℝ) : ℝ := Real.exp x - Real.log x




/-- The EML trace: Tr(x,y) = EML(x,y) + EML(y,x). -/
def EMLTrace9 (x y : ℝ) : ℝ := EML9 x y + EML9 y x




/-- The semigroup element T_c(x) = exp(x) - ln(c). -/
def T9 (c x : ℝ) : ℝ := Real.exp x - Real.log c




/-- The e-tower: e↑↑n. -/
def eTow9 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow9 n)




/-- [Section: # CatalogBuild.Speculative.NewTheorems
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 49] -/
theorem EML9_exp (x : ℝ) : EML9 x 1 = Real.exp x := by
  simp [EML9, Real.log_one]




/-- [Section: # CatalogBuild.Speculative.NewTheorems
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 49] -/
theorem EML9_one_minus_log (x : ℝ) : EML9 0 x = 1 - Real.log x := by
  simp [EML9]




theorem EML9_generates_e : EML9 1 1 = Real.exp 1 := by
  simp [EML9, Real.log_one]




theorem EML9_generates_zero : EML9 0 (Real.exp 1) = 0 := by
  simp [EML9, Real.log_exp]




theorem EML9_generates_ee : EML9 (EML9 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [EML9, Real.log_one]




theorem EML9_generates_eee : EML9 (EML9 (EML9 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [EML9, Real.log_one]




/-- ln recovery: EML(0, exp(EML(0, x))) = ln(x). -/
theorem EML9_recovers_ln (x : ℝ) : EML9 0 (Real.exp (EML9 0 x)) = Real.log x := by
  simp [EML9, Real.log_exp]




/-- Subtraction: EML(ln a, exp b) = a - b for a > 0. -/
theorem EML9_sub (a b : ℝ) (ha : 0 < a) :
    EML9 (Real.log a) (Real.exp b) = a - b := by
  simp [EML9, Real.exp_log ha, Real.log_exp]




/-- Addition: EML(ln a, exp(-b)) = a + b for a > 0. -/
theorem EML9_add (a b : ℝ) (ha : 0 < a) :
    EML9 (Real.log a) (Real.exp (-b)) = a + b := by
  simp [EML9, Real.exp_log ha, Real.log_exp]




/-- Multiplication: EML(ln a + ln b, 1) = a * b for a, b > 0. -/
theorem EML9_mul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML9 (Real.log a + Real.log b) 1 = a * b := by
  simp [EML9, Real.log_one, Real.exp_add, Real.exp_log ha, Real.exp_log hb]




/-- Division: EML(ln a - ln b, 1) = a / b for a, b > 0. -/
theorem EML9_div (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML9 (Real.log a - Real.log b) 1 = a / b := by
  simp [EML9, Real.log_one, Real.exp_sub, Real.exp_log ha, Real.exp_log hb]




/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x. -/
theorem EML9_double_neg (x : ℝ) : EML9 0 (Real.exp (EML9 0 (Real.exp x))) = x := by
  simp [EML9, Real.log_exp]




/-- The diagonal map is always ≥ 2 on (0, ∞). -/
theorem diagMap9_ge_two (x : ℝ) (hx : 0 < x) : diagMap9 x ≥ 2 := by
  unfold diagMap9
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]




theorem diagMap9_no_fixed_point (x : ℝ) (hx : 0 < x) : diagMap9 x ≠ x := by
  -- Use that exp(x) ≥ 1 + x + x²/2 and ln(x) ≤ x - 1.
  have h_exp_ln : Real.exp x ≥ 1 + x + x^2 / 2 ∧ Real.log x ≤ x - 1 := by
    exact ⟨ by rw [ Real.exp_eq_exp_ℝ ] ; rw [ NormedSpace.exp_eq_tsum_div ] ; exact le_trans ( by norm_num [ Finset.sum_range_succ ] ) ( Summable.sum_le_tsum ( Finset.range 3 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) ), Real.log_le_sub_one_of_pos hx ⟩;
  unfold diagMap9; nlinarith;




theorem diagMap9_gt_id (x : ℝ) (hx : 0 < x) : diagMap9 x > x := by
  unfold diagMap9;
  -- We'll use the fact that $e^x \geq 1 + x + \frac{x^2}{2}$ for all $x \geq 0$.
  have h_exp_bound : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
    exact fun x a => quadratic_le_exp_of_nonneg a;
  nlinarith [ h_exp_bound x hx.le, Real.log_le_sub_one_of_pos hx ]




/-- The first derivative of diagMap is exp(x) - 1/x. -/
theorem diagMap9_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt diagMap9 (Real.exp x - x⁻¹) x := by
  exact (hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')




/-- d''(x) = exp(x) + 1/x² > 0 for x > 0 (strict convexity). -/
theorem diagMap9_second_deriv_pos (x : ℝ) (hx : 0 < x) :
    Real.exp x + (1 / x ^ 2) > 0 := by positivity




/-- At a critical point, x · exp(x) = 1. -/
theorem diagMap9_critical_lambert (x : ℝ) (hx : 0 < x)
    (hcrit : Real.exp x = x⁻¹) : x * Real.exp x = 1 := by
  rw [hcrit]; exact mul_inv_cancel₀ hx.ne'




/-- The critical point equation exp(x) = 1/x ↔ x·exp(x) = 1. -/
theorem diagMap9_critical_equiv (x : ℝ) (hx : 0 < x) :
    (Real.exp x = x⁻¹) ↔ (x * Real.exp x = 1) := by
  constructor
  · intro h; rw [h]; exact mul_inv_cancel₀ hx.ne'
  · intro h; field_simp at h ⊢; linarith




theorem depth9_sep_exp_exp :
    ¬ ∃ a b : ℝ, ∀ x : ℝ, Real.exp (Real.exp x) = Real.exp (a * x + b) := by
  simp +zetaDelta at *;
  grind +suggestions




/-- x² ≠ exp(ax + b) for any constants a, b (polynomials separate from DEPTH(1)). -/
theorem depth9_sep_square :
    ¬ ∃ a b : ℝ, ∀ x : ℝ, x ^ 2 = Real.exp (a * x + b) := by
  intro ⟨a, b, h⟩
  have h0 := h 0
  simp at h0
  linarith [Real.exp_pos b]




/-- sin(x) ≠ exp(ax + b) for any constants a, b. -/
theorem depth9_sep_sin :
    ¬ ∃ a b : ℝ, ∀ x : ℝ, Real.sin x = Real.exp (a * x + b) := by
  intro ⟨a, b, h⟩
  have h0 := h 0
  simp at h0
  linarith [Real.exp_pos b]




/-- The EML trace formula. -/
theorem EMLTrace9_eq (x y : ℝ) :
    EMLTrace9 x y = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold EMLTrace9 EML9; ring




/-- EML trace is symmetric. -/
theorem EMLTrace9_symm (x y : ℝ) : EMLTrace9 x y = EMLTrace9 y x := by
  unfold EMLTrace9 EML9; ring




/-- The trace is always ≥ 4 for positive arguments. -/
theorem EMLTrace9_ge_four (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    EMLTrace9 x y ≥ 4 := by
  rw [EMLTrace9_eq]
  linarith [Real.add_one_le_exp x, Real.add_one_le_exp y,
            Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy]




/-- The EML anti-symmetric difference formula. -/
theorem EML9_antisym (x y : ℝ) :
    EML9 x y - EML9 y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold EML9; ring




/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem EML9_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EML9 x (y * z) = EML9 x y - Real.log z := by
  unfold EML9; rw [Real.log_mul hy.ne' hz.ne']; ring




/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x). -/
theorem EML9_shift (x c : ℝ) : EML9 (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EML9, Real.log_one, Real.exp_add, mul_comm]




/-- EML is strictly increasing in the first argument. -/
theorem EML9_strictMono_fst (y : ℝ) : StrictMono (fun x => EML9 x y) :=
  fun _ _ h => sub_lt_sub_right (Real.exp_lt_exp.mpr h) _




/-- EML is strictly decreasing in the second argument for y > 0. -/
theorem EML9_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => EML9 x y) (Ioi 0) :=
  fun _ hy _ _ hyz => sub_lt_sub_left (Real.log_lt_log hy hyz) _




/-- T_1 = exp. -/
theorem T9_one (x : ℝ) : T9 1 x = Real.exp x := by
  simp [T9, Real.log_one]




/-- T_c is strictly monotone. -/
theorem T9_strictMono (c : ℝ) : StrictMono (T9 c) :=
  fun _ _ h => sub_lt_sub_right (Real.exp_lt_exp.mpr h) _




/-- T_1 has no fixed points: exp(x) > x for all x. -/
theorem T9_one_no_fixed (x : ℝ) : T9 1 x > x := by
  rw [T9_one]
  linarith [Real.add_one_le_exp x]




theorem T9_noncomm : ∃ c₁ c₂ x : ℝ, T9 c₁ (T9 c₂ x) ≠ T9 c₂ (T9 c₁ x) := by
  unfold T9;
  refine' ⟨ 1, Real.exp 1, 0, _ ⟩ ; norm_num;
  linarith [ Real.add_one_lt_exp one_ne_zero ]




theorem eTow9_pos (n : ℕ) : 0 < eTow9 n := by
  induction n with
  | zero => simp [eTow9]
  | succ _ _ => exact Real.exp_pos _




theorem eTow9_strictMono : StrictMono eTow9 := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTow9]
  linarith [Real.add_one_le_exp (eTow9 n)]




theorem eTow9_ge_succ (n : ℕ) : eTow9 n ≥ (n : ℝ) + 1 := by
  induction n with
  | zero => simp [eTow9]
  | succ n ih =>
    simp only [eTow9]
    have h := Real.add_one_le_exp (eTow9 n)
    push_cast
    linarith




theorem eTow9_unbounded : ∀ M : ℝ, ∃ n : ℕ, eTow9 n > M := by
  intro M
  exact ⟨⌊M⌋₊, by linarith [Nat.lt_floor_add_one M, eTow9_ge_succ ⌊M⌋₊]⟩




/-- The double exponential tower: EML(EML(x,1), 1) = exp(exp(x)). -/
theorem EML9_double_exp (x : ℝ) :
    EML9 (EML9 x 1) 1 = Real.exp (Real.exp x) := by
  simp [EML9, Real.log_one]




/-- Diagonal iteration: diagMap(diagMap(x)) explicit form. -/
theorem diagMap9_compose (x : ℝ) :
    diagMap9 (diagMap9 x) = Real.exp (Real.exp x - Real.log x) -
      Real.log (Real.exp x - Real.log x) := by
  simp [diagMap9]




theorem exp_exp9_gt_four : Real.exp (Real.exp 1) > 4 := by
  rw [ show ( 4 : ℝ ) = ( Real.exp 1 ) * ( 4 / Real.exp 1 ) by rw [ mul_div_cancel₀ _ <| ne_of_gt <| Real.exp_pos _ ] ];
  have := Real.exp_one_gt_d9;
  rw [ ← Real.exp_log ( show 0 < Real.exp 1 * ( 4 / Real.exp 1 ) by positivity ) ] ; norm_num at * ; ring_nf at * ; norm_num at *;
  rw [ show ( 4 : ℝ ) = 2 ^ 2 by norm_num, Real.log_pow ] ; norm_num;
  exact lt_of_le_of_lt ( mul_le_mul_of_nonneg_left ( Real.log_two_lt_d9.le ) zero_le_two ) ( by norm_num; linarith )




theorem EML9_noncomm : ∃ x y : ℝ, EML9 x y ≠ EML9 y x := by
  unfold EML9;
  use 0, 1; norm_num;
  exact Ne.symm <| by norm_num;




theorem EML9_nonassoc :
    ∃ x y z : ℝ, EML9 (EML9 x y) z ≠ EML9 x (EML9 y z) := by
  use 0, 1, 1;
  norm_num [ EML9 ]




/-- Full arithmetic completeness summary. -/
theorem EML9_arithmetic_complete (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    EML9 a 1 = Real.exp a ∧
    EML9 (Real.log a) (Real.exp b) = a - b ∧
    EML9 (Real.log a) (Real.exp (-b)) = a + b ∧
    EML9 (Real.log a + Real.log b) 1 = a * b ∧
    EML9 (Real.log a - Real.log b) 1 = a / b := by
  exact ⟨EML9_exp a, EML9_sub a b ha, EML9_add a b ha,
         EML9_mul a b ha hb, EML9_div a b ha hb⟩




end
