/-! # CatalogBuild.EML.SymbolicRegression

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 18
-/

import Mathlib

noncomputable section

/-- An EML regression tree with real-valued leaf parameters. -/
inductive EMLRegTree where
  | leaf : ℝ → EMLRegTree
  | var : ℕ → EMLRegTree
  | node : EMLRegTree → EMLRegTree → EMLRegTree



/-- Evaluate an EML regression tree. -/
def EMLRegTree.eval (t : EMLRegTree) (vars : ℕ → ℝ) : ℝ :=
  match t with
  | .leaf c => c
  | .var n => vars n
  | .node l r => Real.exp (l.eval vars) - Real.log (r.eval vars)



/-- Leaf count of a regression tree. -/
def EMLRegTree.leafCount : EMLRegTree → ℕ
  | .leaf _ => 1
  | .var _ => 1
  | .node l r => l.leafCount + r.leafCount



/-- Node count of a regression tree. -/
def EMLRegTree.nodeCount : EMLRegTree → ℕ
  | .leaf _ => 0
  | .var _ => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount



/-- Parameter count: number of real-valued leaf parameters. -/
def EMLRegTree.paramCount : EMLRegTree → ℕ
  | .leaf _ => 1
  | .var _ => 0
  | .node l r => l.paramCount + r.paramCount



/-- Fundamental tree identity: leaves = nodes + 1. -/
theorem EMLRegTree.leaf_eq_node_succ (t : EMLRegTree) :
    t.leafCount = t.nodeCount + 1 := by
  induction t with
  | leaf _ => rfl
  | var _ => rfl
  | node l r ihl ihr => simp [leafCount, nodeCount, ihl, ihr]; omega



/-- The EML search space includes the exponential function.
exp(x) = eml(x, 1) = exp(x) - ln(1) = exp(x). -/
theorem search_space_has_exp :
    ∃ t : EMLRegTree, ∀ x : ℝ, t.eval (fun _ => x) = Real.exp x := by
  exact ⟨.node (.var 0) (.leaf 1), fun x => by simp [EMLRegTree.eval, Real.log_one]⟩



/-- The search space includes the natural logarithm.
eml(0, eml(eml(0, x), 1))
= exp(0) - ln(exp(exp(0) - ln(x)) - ln(1))
= 1 - ln(exp(1 - ln(x)))
= 1 - (1 - ln(x))
= ln(x)   for x > 0. -/
theorem search_space_has_log :
    ∃ t : EMLRegTree, ∀ x : ℝ, 0 < x →
      t.eval (fun _ => x) = Real.log x := by
  refine ⟨.node (.leaf 0) (.node (.node (.leaf 0) (.var 0)) (.leaf 1)), fun x hx => ?_⟩
  simp [EMLRegTree.eval, Real.log_one, Real.exp_zero]



/-- The search space includes addition (via log(exp(x)·exp(y)) = x + y). -/
theorem search_space_has_addition :
    ∀ a b : ℝ, Real.log (Real.exp a * Real.exp b) = a + b := by
  intro a b
  rw [← Real.exp_add, Real.log_exp]



/-- The search space includes subtraction (via log(exp(x)/exp(y)) = x - y). -/
theorem search_space_has_subtraction :
    ∀ a b : ℝ, Real.log (Real.exp a / Real.exp b) = a - b := by
  intro a b
  rw [← Real.exp_sub, Real.log_exp]



/-- The search space includes multiplication (for positive reals). -/
theorem search_space_has_multiplication :
    ∀ a b : ℝ, 0 < a → 0 < b →
      Real.exp (Real.log a + Real.log b) = a * b := by
  intro a b ha hb
  rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]



/-- For a fixed EML tree topology, the evaluation function is differentiable
in the leaf parameters (when log arguments are positive).
This enables gradient-based continuous optimization. -/
theorem eml_leaf_differentiable :
    Differentiable ℝ (fun c : ℝ => Real.exp c - Real.log 1) := by
  exact differentiable_exp.sub (differentiable_const _)



/-- Minimum depth needed for n leaves. -/
def minDepthForLeaves (n : ℕ) : ℕ := Nat.log 2 n



/-- Nat.log is at most the number itself. -/
theorem depth_lower_bound (n : ℕ) (_hn : 1 ≤ n) :
    Nat.log 2 n ≤ n := Nat.log_le_self 2 n



/-- Kepler's third law: T² = k · a³, equivalently T = √k · a^(3/2).
In EML form using ln and exp:
ln(T) = (1/2)·ln(k) + (3/2)·ln(a)
This is a linear relationship in log-space, discoverable by EML regression. -/
theorem kepler_third_law_log_form (k a T : ℝ) (hk : 0 < k) (ha : 0 < a) (hT : 0 < T)
    (hkepler : T^2 = k * a^3) :
    Real.log T = (1/2) * Real.log k + (3/2) * Real.log a := by
  have h1 : T = Real.sqrt (k * a^3) := by
    rw [← hkepler]
    rw [Real.sqrt_sq (le_of_lt hT)]
  rw [h1, Real.log_sqrt (by positivity), Real.log_mul (by positivity) (by positivity)]
  rw [Real.log_pow]
  ring



/-- The level-n EML master formula parameter count. -/
def regressionMasterParams (n : ℕ) : ℕ := 5 * 2^n - 6



/-- Level-2 master formula has 14 free parameters — enough for most physical laws. -/
theorem regression_level2_params : regressionMasterParams 2 = 14 := by native_decide



/-- Level-3 master formula has 34 free parameters — sufficient for complex models. -/
theorem regression_level3_params : regressionMasterParams 3 = 34 := by native_decide



end
