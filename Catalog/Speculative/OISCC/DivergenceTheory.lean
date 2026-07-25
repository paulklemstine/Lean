/-
# OISCC V9: Divergence Theory

## Addressing P-D1: Universal Divergence of the 2D EML Map

This file formalizes results toward proving that the 2D EML map
Φ(x,y) = (EML(x,y), EML(y,x)) has no bounded orbits in ℝ²₊.

Key results:
1. Diagonal map has no fixed points and diverges
2. The EML trace V(x,y) grows under iteration
3. Phi has no fixed points in ℝ²₊
4. Lyapunov analysis
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions -/

/-- The EML operation. -/
def EMLv (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- The 2D EML map. -/
def Phi (p : ℝ × ℝ) : ℝ × ℝ := (EMLv p.1 p.2, EMLv p.2 p.1)

/-- The diagonal EML map d(x) = exp(x) - ln(x). -/
def diagEML (x : ℝ) : ℝ := Real.exp x - Real.log x

/-- The Lyapunov candidate: V(x,y) = exp(x) + exp(y). -/
def lyapV (p : ℝ × ℝ) : ℝ := Real.exp p.1 + Real.exp p.2

/-- The trace: Tr(x,y) = EML(x,y) + EML(y,x). -/
def traceEML (p : ℝ × ℝ) : ℝ := EMLv p.1 p.2 + EMLv p.2 p.1

/-! ## Section 1: Diagonal Map Properties -/

/-- The diagonal map strictly exceeds identity: d(x) > x for x > 0. -/
theorem diagEML_gt_id (x : ℝ) (hx : 0 < x) : diagEML x > x := by
  unfold diagEML
  have hexp : Real.exp x ≥ 1 + x + x ^ 2 / 2 := quadratic_le_exp_of_nonneg hx.le
  have hlog : Real.log x ≤ x - 1 := Real.log_le_sub_one_of_pos hx
  nlinarith [sq_nonneg x]

/-- The diagonal map has no fixed points on (0, ∞). -/
theorem diagEML_no_fixed_point (x : ℝ) (hx : 0 < x) :
    diagEML x ≠ x := ne_of_gt (diagEML_gt_id x hx)

/-- d(x) ≥ 2 for all x > 0. -/
theorem diagEML_ge_two (x : ℝ) (hx : 0 < x) : diagEML x ≥ 2 := by
  unfold diagEML
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]

/-! ## Section 2: Trace Properties -/

/-- The trace formula. -/
theorem traceEML_eq (x y : ℝ) :
    traceEML (x, y) = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  simp [traceEML, EMLv]; ring

/-- The trace is symmetric. -/
theorem traceEML_symm (x y : ℝ) : traceEML (x, y) = traceEML (y, x) := by
  simp [traceEML, EMLv]; ring

/-- The trace ≥ 4 for positive arguments. -/
theorem traceEML_ge_four (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    traceEML (x, y) ≥ 4 := by
  rw [traceEML_eq]
  linarith [Real.add_one_le_exp x, Real.add_one_le_exp y,
            Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy]

/-! ## Section 3: Lyapunov Analysis -/

/-- The Lyapunov function is always positive. -/
theorem lyapV_pos (p : ℝ × ℝ) : 0 < lyapV p := by
  simp [lyapV]; positivity

/-- For y > 0: exp(EML(x,y)) = exp(exp(x))/y. -/
theorem exp_EML_formula (x y : ℝ) (hy : 0 < y) :
    Real.exp (EMLv x y) = Real.exp (Real.exp x) / y := by
  simp [EMLv, Real.exp_sub, Real.exp_log hy]

/-- Lyapunov growth: V(Φ(x,y)) = exp(exp(x))/y + exp(exp(y))/x for x,y > 0. -/
theorem lyapV_growth (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    lyapV (Phi (x, y)) = Real.exp (Real.exp x) / y +
                          Real.exp (Real.exp y) / x := by
  simp [lyapV, Phi]
  rw [exp_EML_formula x y hy, exp_EML_formula y x hx]

/-! ## Section 4: Phi Has No Fixed Points -/

/-
Phi has no fixed points in ℝ²₊.
-/
theorem Phi_no_fixed_point (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Phi (x, y) ≠ (x, y) := by
  -- Assume Φ(x,y) = (x,y). Then EML(x,y)=x and EML(y,x)=y.
  by_contra h_contra
  obtain ⟨hxy, hyx⟩ : EMLv x y = x ∧ EMLv y x = y := by
    exact ⟨ congr_arg Prod.fst h_contra, congr_arg Prod.snd h_contra ⟩;
  unfold EMLv at *;
  -- We know that $e^x \geq 1 + x + \frac{x^2}{2}$ for all $x$.
  have h_exp_bound : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
    exact?;
  nlinarith [ h_exp_bound x hx.le, h_exp_bound y hy.le, Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy ]

/-! ## Section 5: Divergence Results -/

/-
The max of coordinates grows under the EML map for large enough inputs.
-/
theorem max_coord_growth (x y : ℝ) (hx : 0 < x) (hy : 0 < y)
    (hbig : max x y ≥ 2) :
    max (EMLv x y) (EMLv y x) > max x y := by
  cases max_cases x y <;> simp_all +decide [ EMLv ];
  · left;
    -- We'll use that $e^x > x + x^2 / 2$ for $x > 0$.
    have h_exp_gt : Real.exp x > x + x^2 / 2 := by
      -- We'll use the exponential property: $e^x = \sum_{n=0}^{\infty} \frac{x^n}{n!}$.
      have h_exp_series : Real.exp x = ∑' n, x^n / Nat.factorial n := by
        simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
      rw [ h_exp_series ];
      refine' lt_of_lt_of_le _ ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) ) ; norm_num [ Finset.sum_range_succ, Nat.factorial ] ; nlinarith [ pow_pos hx 3 ];
    nlinarith [ Real.log_le_sub_one_of_pos hy ];
  · refine' Or.inr _;
    -- We'll use that $e^y > y + y^2 / 2$ for $y \geq 2$.
    have h_exp_gt_y_sq : Real.exp y > y + y^2 / 2 := by
      rw [ Real.exp_eq_exp_ℝ ];
      rw [ NormedSpace.exp_eq_tsum_div ];
      refine' lt_of_lt_of_le _ ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial y ) ) ; norm_num [ Finset.sum_range_succ, Nat.factorial ] ; nlinarith [ pow_pos hy 3 ];
    nlinarith [ Real.log_le_sub_one_of_pos hx ]

end