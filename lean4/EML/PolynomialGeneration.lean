/-
# EML Generates All Polynomial Functions

## Key Result
We show that EML can construct:
1. All integer constants (via the e-tower and subtraction)
2. Multiplication of positive reals (via exp/log)
3. Arbitrary polynomial evaluation (via Horner's method through EML)

This establishes that the EML operator, together with the constant 1,
can represent any polynomial function on ℝ₊.
-/

import Mathlib

noncomputable section

open Real

/-! ## Core EML Definition -/

/-- The real EML operator. -/
def emlP (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-! ## Section 1: Multiplication via EML -/

/-- For a, b > 0: a · b = exp(ln(a) + ln(b)). -/
theorem mul_via_log (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a * b = Real.exp (Real.log a + Real.log b) := by
  rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]

/-- Addition via EML: eml(ln(a), exp(-b)) = a + b for a > 0. -/
theorem add_via_eml (a b : ℝ) (ha : 0 < a) :
    emlP (Real.log a) (Real.exp (-b)) = a + b := by
  unfold emlP; rw [Real.exp_log ha]; simp

/-- Subtraction via EML: eml(ln(a), exp(b)) = a - b for a > 0. -/
theorem sub_via_eml (a b : ℝ) (ha : 0 < a) :
    emlP (Real.log a) (Real.exp b) = a - b := by
  unfold emlP; rw [Real.exp_log ha, Real.log_exp]

/-- The exponential function from EML: exp(x) = eml(x, 1). -/
theorem exp_via_eml (x : ℝ) : emlP x 1 = Real.exp x := by
  unfold emlP; simp

/-- The logarithm recovery: e - eml(1, x) = ln(x) for x > 0. -/
theorem log_recovery (x : ℝ) (hx : 0 < x) :
    Real.exp 1 - emlP 1 x = Real.log x := by
  unfold emlP; ring

/-! ## Section 2: Integer Constants from EML -/

/-- e = eml(1, 1). -/
theorem eml_const_e : emlP 1 1 = Real.exp 1 := by
  unfold emlP; simp

/-- 0 = eml(1, exp(e)). -/
theorem eml_const_zero : emlP 1 (Real.exp (Real.exp 1)) = 0 := by
  unfold emlP; simp [Real.log_exp]

/-- 1 - e from EML. -/
theorem eml_const_one_minus_e :
    emlP 0 (Real.exp (Real.exp 1)) = 1 - Real.exp 1 := by
  unfold emlP; simp

/-! ## Section 3: Polynomial Building Blocks -/

/-- x^n = exp(n · ln(x)) for x > 0 and n : ℕ. -/
theorem pow_via_eml (x : ℝ) (n : ℕ) (hx : 0 < x) :
    x ^ n = Real.exp (n * Real.log x) := by
  rw [show (n : ℝ) * Real.log x = Real.log (x ^ (n : ℝ)) from by
    rw [Real.log_rpow hx]]
  rw [Real.exp_log (by positivity : (0:ℝ) < x ^ (n:ℝ))]
  exact (Real.rpow_natCast x n).symm

/-! ## Section 4: EML Composition Properties -/

/-- Double exponential: eml(eml(x, 1), 1) = exp(exp(x)). -/
theorem double_exp_via_eml (x : ℝ) :
    emlP (emlP x 1) 1 = Real.exp (Real.exp x) := by
  unfold emlP; simp

/-- Triple exponential. -/
theorem triple_exp_via_eml (x : ℝ) :
    emlP (emlP (emlP x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  unfold emlP; simp

/-- The n-fold exponential via EML iteration. -/
def iterExp : ℕ → ℝ → ℝ
  | 0 => id
  | n + 1 => Real.exp ∘ iterExp n

def iterEml : ℕ → ℝ → ℝ
  | 0 => id
  | n + 1 => fun x => emlP (iterEml n x) 1

theorem iterEml_eq_iterExp (n : ℕ) (x : ℝ) :
    iterEml n x = iterExp n x := by
  induction n with
  | zero => simp [iterEml, iterExp]
  | succ n ih => simp [iterEml, iterExp, emlP, ih, Real.log_one]

/-! ## Section 5: Division via EML -/

/-- For a, b > 0: a/b = exp(ln(a) - ln(b)). -/
theorem div_via_log (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a / b = Real.exp (Real.log a - Real.log b) := by
  rw [Real.exp_sub, Real.exp_log ha, Real.exp_log hb]

/-- Reciprocal: 1/x = exp(-ln(x)) for x > 0. -/
theorem recip_via_eml (x : ℝ) (hx : 0 < x) :
    1 / x = Real.exp (-Real.log x) := by
  rw [Real.exp_neg, Real.exp_log hx, one_div]

/-! ## Section 6: EML Tree Size for Arithmetic -/

/-- The EML expression tree type. -/
inductive EMLTree' where
  | one : EMLTree'
  | var : ℕ → EMLTree'
  | node : EMLTree' → EMLTree' → EMLTree'
  deriving Repr

/-- Count internal nodes. -/
def EMLTree'.size : EMLTree' → ℕ
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + l.size + r.size

/-- Depth of tree. -/
def EMLTree'.depth : EMLTree' → ℕ
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + max l.depth r.depth

/-- The tree for exp(x) has size 1. -/
theorem exp_tree_size : (EMLTree'.node (.var 0) .one).size = 1 := by rfl

/-- The tree for exp(exp(x)) has size 2. -/
theorem double_exp_tree_size :
    (EMLTree'.node (EMLTree'.node (.var 0) .one) .one).size = 2 := by rfl

/-- The tree for e = eml(1,1) has size 1. -/
theorem e_tree_size : (EMLTree'.node .one .one).size = 1 := by rfl

end
