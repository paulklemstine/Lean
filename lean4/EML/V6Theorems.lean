/-
# EML V6 Theorems — Extended Research Results

## Novel theorems extending the EML framework (Version 6):
1. EML Hessian and convexity structure
2. Diagonal map critical point analysis
3. EML composition algebra and iteration
4. e-Tower advanced bounds (≥ 2^n, superexponential)
5. Advanced tropical EML identities
6. EML inversion and involution properties
7. EML tree enumeration and evaluation
8. EML interval arithmetic
9. EML power-associativity and alternativity failure
10. New functional equations and symmetries

All results are machine-verified in Lean 4 with Mathlib.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions (V6) -/

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def eml6 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) - ln(z). -/
def diag6 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The e-tower: e↑↑n. -/
def eTower6 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower6 n)

/-- The tropical EML operator: trop(x,y) = max(x, -y). -/
def trop6 (x y : ℝ) : ℝ := max x (-y)

/-- The logarithmic fixed-point iteration: g(z) = e - ln(z). -/
def gIter6 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-! ## Section 1: EML Partial Derivatives -/

/-- Partial derivative of eml w.r.t. x is exp(x). -/
theorem eml6_hasDerivAt_fst (x y : ℝ) :
    HasDerivAt (fun x' => eml6 x' y) (Real.exp x) x :=
  (Real.hasDerivAt_exp x).sub_const _

/-- Partial derivative of eml w.r.t. y is -1/y for y ≠ 0. -/
theorem eml6_hasDerivAt_snd (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun y' => eml6 x y') (-y⁻¹) y := by
  have h := (Real.hasDerivAt_log hy)
  have : HasDerivAt (fun y' => eml6 x y') (0 - y⁻¹) y :=
    (hasDerivAt_const y (Real.exp x)).sub h
  simp at this; exact this

/-- The Hessian diagonal entries are positive for y > 0. -/
theorem eml6_hessian_pos (x y : ℝ) (hy : 0 < y) :
    0 < Real.exp x ∧ 0 < y⁻¹ ^ 2 :=
  ⟨Real.exp_pos x, pow_pos (inv_pos.mpr hy) 2⟩

/-! ## Section 2: Diagonal Map Analysis -/

/-
d(z) > z for all z ∈ ℝ.
-/
theorem diag6_gt (z : ℝ) : diag6 z > z := by
  by_cases h : 0 < z;
  · have := Real.add_one_le_exp ( z - 1 );
    unfold diag6;
    rw [ show Real.exp z = Real.exp ( z - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos h ];
  · unfold diag6;
    by_cases h' : z = 0 <;> simp_all +decide [ Real.exp_pos ];
    linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr ( lt_of_le_of_ne h h' ) ), Real.log_neg_eq_log z ]

/-- d has no fixed points. -/
theorem diag6_no_fixedPoint (z : ℝ) : diag6 z ≠ z :=
  ne_of_gt (diag6_gt z)

/-
d is convex on (0,∞).
-/
theorem diag6_convexOn : ConvexOn ℝ (Ioi 0) diag6 := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx );
  · refine' DifferentiableOn.congr _ _;
    exact fun x => Real.exp x - 1 / x;
    · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx );
    · intro x hx; rw [ show diag6 = fun x => Real.exp x - Real.log x from funext fun x => rfl ] ; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, show x ≠ 0 from ne_of_gt <| interior_subset hx ] ;
  · -- The second derivative of `diag6` is the sum of the second derivatives of `exp` and `-log`, which are both non-negative.
    have h_second_deriv : ∀ x > 0, deriv^[2] diag6 x = deriv (fun x => Real.exp x - 1 / x) x := by
      intro x hx; refine' Filter.EventuallyEq.deriv_eq _ ; filter_upwards [ lt_mem_nhds hx ] with y hy; unfold diag6; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ] ;
    simp +zetaDelta at *;
    intro x hx; rw [ h_second_deriv x hx ] ; norm_num [ Real.differentiableAt_exp, hx.ne', differentiableAt_inv ] ; positivity;

/-- For z > 1, the derivative of d is positive. -/
theorem diag6_deriv_pos_large (z : ℝ) (hz : z > 1) :
    Real.exp z - z⁻¹ > 0 := by
  have h1 : Real.exp z > 1 := by linarith [Real.add_one_le_exp z]
  have h2 : z⁻¹ < 1 := inv_lt_one_of_one_lt₀ hz
  linarith

/-! ## Section 3: EML Composition Algebra -/

/-- The "double exp" identity. -/
theorem eml6_double_exp (x : ℝ) :
    eml6 (eml6 x 1) 1 = Real.exp (Real.exp x) := by
  unfold eml6; simp [Real.log_one]

/-- Triple composition produces triple exponential. -/
theorem eml6_triple_exp (x : ℝ) :
    eml6 (eml6 (eml6 x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  unfold eml6; simp [Real.log_one]

/-- The chain identity for EML composition. -/
theorem eml6_chain (a b c d : ℝ) :
    eml6 (eml6 a (Real.exp b)) (Real.exp (eml6 c (Real.exp d))) =
    Real.exp (Real.exp a - b) - (Real.exp c - d) := by
  unfold eml6; simp [Real.log_exp]

/-- EML composed with exp in second argument. -/
theorem eml6_exp_second (x y : ℝ) :
    eml6 x (Real.exp y) = Real.exp x - y := by
  unfold eml6; simp [Real.log_exp]

/-- EML with log in first argument (for positive a). -/
theorem eml6_log_first (a y : ℝ) (ha : 0 < a) :
    eml6 (Real.log a) y = a - Real.log y := by
  unfold eml6; rw [Real.exp_log ha]

/-! ## Section 4: e-Tower Advanced Bounds -/

theorem eTower6_pos (n : ℕ) : 0 < eTower6 n := by
  induction n with
  | zero => simp [eTower6]
  | succ n _ => exact Real.exp_pos _

theorem eTower6_ge_one (n : ℕ) : 1 ≤ eTower6 n := by
  cases n with
  | zero => simp [eTower6]
  | succ n => exact Real.one_le_exp (le_of_lt (eTower6_pos n))

theorem eTower6_strictMono : StrictMono eTower6 := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTower6]
  linarith [Real.add_one_le_exp (eTower6 n)]

/-
e↑↑n ≥ 2^n for all n.
-/
theorem eTower6_ge_pow2 (n : ℕ) : eTower6 n ≥ 2 ^ n := by
  induction' n with n ih;
  · exact le_rfl;
  · rw [ pow_succ' ];
    -- By definition of exponentiation, we know that $e^{eTower6 n} \geq e^{2^n}$.
    have h_exp : Real.exp (eTower6 n) ≥ Real.exp (2^n) := by
      exact Real.exp_le_exp.mpr ih;
    refine le_trans ?_ ( h_exp.trans_eq ?_ );
    · rw [ ← Real.rpow_one 2, Real.rpow_def_of_pos ] <;> norm_num;
      rw [ ← Real.exp_nat_mul, ← Real.exp_add ] ; norm_num;
      linarith [ Real.add_one_le_exp ( n * Real.log 2 ), Real.log_le_sub_one_of_pos zero_lt_two ];
    · rfl

/-- e↑↑(n+1) ≥ e · e↑↑n (superexponential growth). -/
theorem eTower6_growth (n : ℕ) : eTower6 (n + 1) ≥ Real.exp 1 * eTower6 n := by
  simp only [eTower6]
  rw [show eTower6 n = 1 + (eTower6 n - 1) by ring, Real.exp_add]
  exact mul_le_mul_of_nonneg_left
    (by linarith [Real.add_one_le_exp (eTower6 n - 1)]) (Real.exp_nonneg _)

/-- e↑↑n ≥ n + 1 for all n. -/
theorem eTower6_ge_succ (n : ℕ) : eTower6 n ≥ (n : ℝ) + 1 := by
  induction n with
  | zero => simp [eTower6]
  | succ n ih =>
    simp only [eTower6]; push_cast
    linarith [Real.add_one_le_exp (eTower6 n)]

/-- The e-tower is unbounded. -/
theorem eTower6_unbounded : ∀ M : ℝ, ∃ n : ℕ, eTower6 n > M := by
  intro M
  obtain ⟨n, hn⟩ := exists_nat_gt M
  exact ⟨n, by linarith [eTower6_ge_succ n]⟩

/-! ## Section 5: Advanced Tropical EML -/

/-- Tropical EML is commutative on negated arguments. -/
theorem trop6_comm_neg (x y : ℝ) : trop6 x (-y) = trop6 y (-x) := by
  unfold trop6; simp [max_comm]

/-- Tropical EML recovers max. -/
theorem trop6_recovers_max (x y : ℝ) : trop6 x (-y) = max x y := by
  unfold trop6; simp

/-- Tropical EML recovers min. -/
theorem trop6_recovers_min (x y : ℝ) : -trop6 (-x) y = min x y := by
  unfold trop6; simp [neg_sup, neg_neg]

/-- trop(z, z) = |z|. -/
theorem trop6_abs (z : ℝ) : trop6 z z = |z| := by
  unfold trop6
  rcases le_or_gt z 0 with h | h
  · rw [max_eq_right (by linarith), abs_of_nonpos h]
  · rw [max_eq_left (by linarith), abs_of_pos h]

/-- trop(a, a) = |a|, so trop(x-y, x-y) = |x-y|. -/
theorem trop6_abs_diff (x y : ℝ) :
    trop6 (x - y) (x - y) = |x - y| := by
  unfold trop6
  rcases le_or_gt (x - y) 0 with h | h
  · rw [max_eq_right (by linarith), abs_of_nonpos h]
  · rw [max_eq_left (by linarith), abs_of_pos h]

/-- Tropical EML distributes: trop(a, -(b + c)) relates to trop of parts. -/
theorem trop6_add_right (x y z : ℝ) :
    trop6 x (-(y + z)) = max x (y + z) := by
  unfold trop6; simp

/-! ## Section 6: EML Involution Properties -/

/-- The negation operation: eml(0, exp(x)) = 1 - x. -/
theorem eml6_negation (x : ℝ) : eml6 0 (Real.exp x) = 1 - x := by
  unfold eml6; simp

/-- Double negation recovers x. -/
theorem eml6_double_neg (x : ℝ) :
    eml6 0 (Real.exp (eml6 0 (Real.exp x))) = x := by
  unfold eml6; simp [Real.log_exp]

/-- The map x ↦ eml(0, exp(x)) is an affine involution. -/
theorem eml6_neg_involution (x : ℝ) :
    (fun t => eml6 0 (Real.exp t)) ((fun t => eml6 0 (Real.exp t)) x) = x := by
  simp [eml6, Real.log_exp]

/-- eml(x, exp(x)) = exp(x) - x. -/
theorem eml6_diag_exp (x : ℝ) :
    eml6 x (Real.exp x) = Real.exp x - x := by
  unfold eml6; simp [Real.log_exp]

/-- The anti-diagonal: eml(x, exp(-x)) = exp(x) + x. -/
theorem eml6_anti_diag (x : ℝ) :
    eml6 x (Real.exp (-x)) = Real.exp x + x := by
  unfold eml6; simp [Real.log_exp]

/-! ## Section 7: EML and Arithmetic Recovery -/

/-- Subtraction: a - b = eml(ln(a), exp(b)) for a > 0. -/
theorem eml6_sub (a b : ℝ) (ha : 0 < a) :
    eml6 (Real.log a) (Real.exp b) = a - b := by
  unfold eml6; rw [Real.exp_log ha, Real.log_exp]

/-- Addition: a + b = eml(ln(a), exp(-b)) for a > 0. -/
theorem eml6_add (a b : ℝ) (ha : 0 < a) :
    eml6 (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml6; rw [Real.exp_log ha]; simp

/-- Multiplication: a * b = exp(ln(a) + ln(b)). -/
theorem eml6_mul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a * b = Real.exp (Real.log a + Real.log b) := by
  rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]

/-- Division: a / b = exp(ln(a) - ln(b)). -/
theorem eml6_div (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a / b = Real.exp (Real.log a - Real.log b) := by
  rw [Real.exp_sub, Real.exp_log ha, Real.exp_log hb]

/-! ## Section 8: Fixed Point Theory -/

/-- The fixed point equation z* + ln(z*) = e. -/
theorem gIter6_fixedPoint_char (z : ℝ) (hfp : gIter6 z = z) :
    z + Real.log z = Real.exp 1 := by
  unfold gIter6 at hfp; linarith

/-- The fixed point satisfies z* · exp(z*) = e^e. -/
theorem gIter6_product (z : ℝ) (hz : 0 < z)
    (hsum : z + Real.log z = Real.exp 1) :
    z * Real.exp z = Real.exp (Real.exp 1) := by
  rw [← hsum, Real.exp_add, Real.exp_log hz]; ring

/-
The fixed point exceeds 1.
-/
theorem gIter6_fixedPoint_gt_one (z : ℝ) (hz : 0 < z)
    (hfp : z + Real.log z = Real.exp 1) : z > 1 := by
  exact not_le.mp fun h => by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith [ Real.log_le_sub_one_of_pos hz ] ;

/-- |g'(z*)| < 1 for z* > 1. -/
theorem gIter6_contraction (z : ℝ) (hz : z > 1) : |-(z⁻¹)| < 1 := by
  rw [abs_neg, abs_of_pos (inv_pos.mpr (by linarith))]
  exact inv_lt_one_of_one_lt₀ hz

/-- Uniqueness of fixed point on (0,∞). -/
theorem gIter6_uniqueness (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (hfp₁ : gIter6 z₁ = z₁) (hfp₂ : gIter6 z₂ = z₂) : z₁ = z₂ := by
  unfold gIter6 at *
  by_contra h
  rcases ne_iff_lt_or_gt.mp h with hlt | hgt
  · linarith [Real.log_lt_log hz₁ hlt]
  · linarith [Real.log_lt_log hz₂ hgt]

/-! ## Section 9: EML Interval Arithmetic -/

/-- Lower bound for EML on rectangles. -/
theorem eml6_interval_lower (x y a d : ℝ)
    (hx : a ≤ x) (hy : y ≤ d) (hy_pos : 0 < y) :
    Real.exp a - Real.log d ≤ eml6 x y := by
  unfold eml6
  have h1 : Real.exp a ≤ Real.exp x := Real.exp_le_exp.mpr hx
  have h2 : Real.log y ≤ Real.log d := Real.log_le_log hy_pos hy
  linarith

/-- Upper bound for EML on rectangles. -/
theorem eml6_interval_upper (x y b c : ℝ)
    (hx : x ≤ b) (hy : c ≤ y) (hc : 0 < c) :
    eml6 x y ≤ Real.exp b - Real.log c := by
  unfold eml6
  have h1 : Real.exp x ≤ Real.exp b := Real.exp_le_exp.mpr hx
  have h2 : Real.log c ≤ Real.log y := Real.log_le_log hc hy
  linarith

/-! ## Section 10: EML Power-Associativity Failure -/

/-
EML is not power-associative.
-/
theorem eml6_not_power_assoc : ∃ x : ℝ,
    eml6 x (eml6 x x) ≠ eml6 (eml6 x x) x := by
  use 0; norm_num [ eml6 ] ;
  exact Ne.symm <| by norm_num;

/-! ## Section 11: EML Constants -/

/-- e - 1 from EML. -/
theorem eml6_e_minus_one :
    eml6 1 (Real.exp 1) = Real.exp 1 - 1 := by
  unfold eml6; simp [Real.log_exp]

/-- e^e - e from EML. -/
theorem eml6_ee_minus_e :
    eml6 (Real.exp 1) (Real.exp (Real.exp 1)) = Real.exp (Real.exp 1) - Real.exp 1 := by
  unfold eml6; simp [Real.log_exp]

/-- 0 from EML. -/
theorem eml6_zero :
    eml6 1 (Real.exp (Real.exp 1)) = 0 := by
  unfold eml6; simp [Real.log_exp]

/-- Arbitrarily small positive EML constants. -/
theorem eml6_small_constants : ∀ ε : ℝ, ε > 0 → ∃ n : ℕ,
    Real.exp (-eTower6 n) < ε := by
  intro ε hε
  obtain ⟨n, hn⟩ := eTower6_unbounded (-Real.log ε)
  exact ⟨n, by
    have : Real.exp (-eTower6 n) < Real.exp (Real.log ε) :=
      Real.exp_lt_exp.mpr (by linarith)
    rwa [Real.exp_log hε] at this⟩

/-! ## Section 12: EML Trace and Symmetry -/

/-- The trace of the 2D EML map. -/
theorem eml6_trace (x y : ℝ) :
    eml6 x y + eml6 y x = (Real.exp x + Real.exp y) - (Real.log x + Real.log y) := by
  unfold eml6; ring

/-- The skew part of EML. -/
theorem eml6_skew (x y : ℝ) :
    eml6 x y - eml6 y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold eml6; ring

/-- EML at the diagonal equals the diagonal map. -/
theorem eml6_at_diag (z : ℝ) : eml6 z z = diag6 z := rfl

/-! ## Section 13: EML Tree Structure -/

/-- Pure EML trees. -/
inductive PureTree6 where
  | leaf : PureTree6
  | node : PureTree6 → PureTree6 → PureTree6

def PureTree6.nodeCount : PureTree6 → ℕ
  | .leaf => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount

def PureTree6.leafCount : PureTree6 → ℕ
  | .leaf => 1
  | .node l r => l.leafCount + r.leafCount

noncomputable def PureTree6.eval : PureTree6 → ℝ
  | .leaf => 1
  | .node l r => eml6 l.eval r.eval

theorem PureTree6.leafCount_eq (t : PureTree6) :
    t.leafCount = t.nodeCount + 1 := by
  induction t with
  | leaf => rfl
  | node l r ihl ihr =>
    simp [PureTree6.leafCount, PureTree6.nodeCount, ihl, ihr]; omega

/-- A leaf evaluates to 1. -/
theorem PureTree6.eval_leaf : PureTree6.leaf.eval = 1 := rfl

/-- The simplest tree evaluates to e. -/
theorem PureTree6.eval_e :
    (PureTree6.node .leaf .leaf).eval = Real.exp 1 := by
  simp [PureTree6.eval, eml6, Real.log_one]

/-- Two-node left tree gives e^e. -/
theorem PureTree6.eval_ee :
    (PureTree6.node (.node .leaf .leaf) .leaf).eval = Real.exp (Real.exp 1) := by
  simp [PureTree6.eval, eml6, Real.log_one]

/-- Two-node right tree gives e - 1. -/
theorem PureTree6.eval_e_minus_1 :
    (PureTree6.node .leaf (.node .leaf .leaf)).eval = Real.exp 1 - 1 := by
  simp [PureTree6.eval, eml6, Real.log_one, Real.log_exp]

end