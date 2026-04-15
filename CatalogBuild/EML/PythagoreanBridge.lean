/-! # CatalogBuild.EML.PythagoreanBridge

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 39
-/

import Mathlib

noncomputable section

/-- Euclid's parametrization produces Pythagorean triples. -/
theorem euclid_param (m n : ℤ) :
    IsPythTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  unfold IsPythTriple; ring


/-- Berggren matrix M₁ (type A). -/
def berggrenA' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


/-- Berggren matrix M₂ (type B). -/
def berggrenB' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


/-- Berggren matrix M₃ (type C). -/
def berggrenC' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


/-- M₁ preserves the Pythagorean property. -/
theorem berggrenA_preserves' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (berggrenA' a b c).1 (berggrenA' a b c).2.1 (berggrenA' a b c).2.2 := by
  unfold IsPythTriple berggrenA' at *; nlinarith [h]


/-- M₂ preserves the Pythagorean property. -/
theorem berggrenB_preserves' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (berggrenB' a b c).1 (berggrenB' a b c).2.1 (berggrenB' a b c).2.2 := by
  unfold IsPythTriple berggrenB' at *; nlinarith [h]


/-- M₃ preserves the Pythagorean property. -/
theorem berggrenC_preserves' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (berggrenC' a b c).1 (berggrenC' a b c).2.1 (berggrenC' a b c).2.2 := by
  unfold IsPythTriple berggrenC' at *; nlinarith [h]


/-- The EML operator on reals. -/
def emlOp (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- exp(x) = eml(x, 1). -/
theorem eml_is_exp (x : ℝ) : emlOp x 1 = Real.exp x := by
  simp [emlOp, Real.log_one]


/-- log(x) = 1 - eml(0, x) for x > 0 (since eml(0,x) = 1 - log(x)). -/
theorem eml_recovers_log (x : ℝ) (hx : 0 < x) :
    1 - emlOp 0 x = Real.log x := by
  simp [emlOp, Real.exp_zero]


/-- EML expression tree with integer constants and variables. -/
inductive EMLPythExpr where
  | one : EMLPythExpr
  | var : ℕ → EMLPythExpr
  | eml : EMLPythExpr → EMLPythExpr → EMLPythExpr
  deriving Repr, BEq


/-- Evaluate an EML expression. -/
def EMLPythExpr.eval (e : EMLPythExpr) (vars : ℕ → ℝ) : ℝ :=
  match e with
  | .one => 1
  | .var n => vars n
  | .eml l r => emlOp (l.eval vars) (r.eval vars)


/-- Depth of an EML expression tree. -/
def EMLPythExpr.depth : EMLPythExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .eml l r => 1 + max l.depth r.depth


/-- Size (total nodes) of an EML expression tree. -/
def EMLPythExpr.size : EMLPythExpr → ℕ
  | .one => 1
  | .var _ => 1
  | .eml l r => 1 + l.size + r.size


/-- Leaf count. -/
def EMLPythExpr.leafCount : EMLPythExpr → ℕ
  | .one => 1
  | .var _ => 1
  | .eml l r => l.leafCount + r.leafCount


/-- Internal node count. -/
def EMLPythExpr.nodeCount : EMLPythExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .eml l r => 1 + l.nodeCount + r.nodeCount


/-- In any EML tree, leaves = internal nodes + 1. -/
theorem EMLPythExpr.leaf_eq_node_succ (e : EMLPythExpr) :
    e.leafCount = e.nodeCount + 1 := by
  induction e with
  | one => rfl
  | var _ => rfl
  | eml l r ihl ihr =>
    simp [EMLPythExpr.leafCount, EMLPythExpr.nodeCount, ihl, ihr]; omega


/-- EML expression for exp(x₀). -/
def emlExpExpr : EMLPythExpr := .eml (.var 0) .one


/-- EML expression for exp(x₀) evaluates correctly. -/
theorem emlExpExpr_eval (vars : ℕ → ℝ) :
    emlExpExpr.eval vars = Real.exp (vars 0) := by
  simp [emlExpExpr, EMLPythExpr.eval, emlOp, Real.log_one]


/-- Multiplication via exp-log for positive reals: x * y = exp(log(x) + log(y)). -/
theorem mul_via_eml (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Real.exp (Real.log x + Real.log y) = x * y := by
  rw [Real.exp_add, Real.exp_log hx, Real.exp_log hy]


/-- [Section: ## Section 5: Arithmetic via EML] -/
theorem sq_via_eml (x : ℝ) (hx : 0 < x) :
    Real.exp (2 * Real.log x) = x ^ 2 := by
      rw [ mul_comm, Real.exp_mul, Real.exp_log ] <;> norm_cast


/-- For positive integer triples, the log-space Pythagorean condition:
exp(2 log a) + exp(2 log b) = exp(2 log c). -/
theorem pyth_log_space (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : IsPythTriple a b c) :
    (a : ℝ) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by
  unfold IsPythTriple at h
  exact_mod_cast h


/-- Depth of a Berggren path. -/
def BerggrenPath.depth : BerggrenPath → ℕ
  | .root => 0
  | .applyA p => p.depth + 1
  | .applyB p => p.depth + 1
  | .applyC p => p.depth + 1


/-- Evaluate a Berggren path to get the triple. -/
def BerggrenPath.eval : BerggrenPath → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .applyA p =>
    let (a, b, c) := p.eval
    berggrenA' a b c
  | .applyB p =>
    let (a, b, c) := p.eval
    berggrenB' a b c
  | .applyC p =>
    let (a, b, c) := p.eval
    berggrenC' a b c


/-- Every Berggren path produces a Pythagorean triple. -/
theorem BerggrenPath.eval_is_pyth (p : BerggrenPath) :
    IsPythTriple (p.eval).1 (p.eval).2.1 (p.eval).2.2 := by
  induction p with
  | root => exact root_is_pyth
  | applyA p ih =>
    simp only [BerggrenPath.eval]
    exact berggrenA_preserves' _ _ _ ih
  | applyB p ih =>
    simp only [BerggrenPath.eval]
    exact berggrenB_preserves' _ _ _ ih
  | applyC p ih =>
    simp only [BerggrenPath.eval]
    exact berggrenC_preserves' _ _ _ ih


/-- The simplest Pythagorean quadruple: (1, 2, 2, 3). -/
theorem quad_1_2_2_3 : IsPythQuad 1 2 2 3 := by norm_num [IsPythQuad]


/-- Another quadruple: (2, 3, 6, 7). -/
theorem quad_2_3_6_7 : IsPythQuad 2 3 6 7 := by norm_num [IsPythQuad]


/-- Every Pythagorean triple embeds into a quadruple via (a, b, 0, c). -/
theorem triple_embeds_in_quad (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythQuad a b 0 c := by
  unfold IsPythQuad IsPythTriple at *; linarith


/-- Quadruples satisfy the real-valued constraint. -/
theorem quad_real_constraint (a b c d : ℤ) (h : IsPythQuad a b c d) :
    (a : ℝ) ^ 2 + (b : ℝ) ^ 2 + (c : ℝ) ^ 2 = (d : ℝ) ^ 2 := by
  unfold IsPythQuad at h; exact_mod_cast h


/-- A Pythagorean N-tuple: the sum of squares of all but the last equals the last squared. -/
def IsPythNTuple (xs : List ℤ) : Prop :=
  xs.length ≥ 3 ∧
  ∃ init last, xs = init ++ [last] ∧
    (init.map (· ^ 2)).sum = last ^ 2


/-- Every triple is a 3-tuple. -/
theorem triple_is_3tuple (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythNTuple [a, b, c] := by
  constructor
  · simp
  · exact ⟨[a, b], c, by simp, by simpa [IsPythTriple] using h⟩


/-- Every quadruple is a 4-tuple. -/
theorem quad_is_4tuple (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythNTuple [a, b, c, d] := by
  constructor
  · simp
  · exact ⟨[a, b, c], d, by simp, by simp [IsPythQuad] at h ⊢; linarith⟩


/-- **The Pythagorean-EML Bridge Theorem (structural version)**:
For every Berggren tree path, the resulting triple satisfies
the Pythagorean condition, which is expressible as an EML identity
in log-space coordinates. -/
theorem pythagorean_eml_bridge (p : BerggrenPath) :
    IsPythTriple (p.eval).1 (p.eval).2.1 (p.eval).2.2 :=
  p.eval_is_pyth


/-- The EML expression for exp(x₀) has depth 1. -/
theorem emlExpExpr_depth : emlExpExpr.depth = 1 := by
  simp [emlExpExpr, EMLPythExpr.depth]


/-- The EML expression for exp(x₀) has size 3. -/
theorem emlExpExpr_size : emlExpExpr.size = 3 := by
  simp [emlExpExpr, EMLPythExpr.size]


/-- Leaves are bounded by 2^depth. -/
theorem EMLPythExpr.leaves_le_pow_depth (e : EMLPythExpr) :
    e.leafCount ≤ 2 ^ e.depth := by
  induction e with
  | one => simp [leafCount, depth]
  | var _ => simp [leafCount, depth]
  | eml l r ihl ihr =>
    simp [leafCount, depth]
    calc l.leafCount + r.leafCount
        ≤ 2 ^ l.depth + 2 ^ r.depth := Nat.add_le_add ihl ihr
      _ ≤ 2 ^ max l.depth r.depth + 2 ^ max l.depth r.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 * 2 ^ max l.depth r.depth := by omega
      _ = 2 ^ (max l.depth r.depth + 1) := by ring
      _ = 2 ^ (1 + max l.depth r.depth) := by ring_nf


/-- The first child of (3,4,5) via M₁ is (5,12,13). -/
theorem berggren_child_A : BerggrenPath.eval (.applyA .root) = (5, 12, 13) := by
  native_decide


/-- The second child via M₂ is (21,20,29). -/
theorem berggren_child_B : BerggrenPath.eval (.applyB .root) = (21, 20, 29) := by
  native_decide


/-- The third child via M₃ is (15,8,17). -/
theorem berggren_child_C : BerggrenPath.eval (.applyC .root) = (15, 8, 17) := by
  native_decide


end
