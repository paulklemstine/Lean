/-! # CatalogBuild.EML.PythagoreanBridgeResearch

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 69
-/

import Mathlib

noncomputable section

/-- The EML operator on reals: eml(x, y) = exp(x) - log(y). -/
def eml' (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- M₁ preserves the Pythagorean relation. -/
theorem M₁_preserves (v : ℤ × ℤ × ℤ) (h : IsPythTriple' v.1 v.2.1 v.2.2) :
    IsPythTriple' (M₁ v).1 (M₁ v).2.1 (M₁ v).2.2 := by
  unfold IsPythTriple' M₁ at *; nlinarith


/-- M₂ preserves the Pythagorean relation. -/
theorem M₂_preserves (v : ℤ × ℤ × ℤ) (h : IsPythTriple' v.1 v.2.1 v.2.2) :
    IsPythTriple' (M₂ v).1 (M₂ v).2.1 (M₂ v).2.2 := by
  unfold IsPythTriple' M₂ at *; nlinarith


/-- M₃ preserves the Pythagorean relation. -/
theorem M₃_preserves (v : ℤ × ℤ × ℤ) (h : IsPythTriple' v.1 v.2.1 v.2.2) :
    IsPythTriple' (M₃ v).1 (M₃ v).2.1 (M₃ v).2.2 := by
  unfold IsPythTriple' M₃ at *; nlinarith


/-- M₁ preserves the Lorentz form. -/
theorem M₁_preserves_lorentz (v : ℤ × ℤ × ℤ) :
    lorentzForm (M₁ v) = lorentzForm v := by
  unfold lorentzForm M₁; ring


/-- M₂ preserves the Lorentz form. -/
theorem M₂_preserves_lorentz (v : ℤ × ℤ × ℤ) :
    lorentzForm (M₂ v) = lorentzForm v := by
  unfold lorentzForm M₂; ring


/-- M₃ preserves the Lorentz form. -/
theorem M₃_preserves_lorentz (v : ℤ × ℤ × ℤ) :
    lorentzForm (M₃ v) = lorentzForm v := by
  unfold lorentzForm M₃; ring


/-- The Lorentz form vanishes on Pythagorean triples. -/
theorem lorentz_zero_iff_pyth (v : ℤ × ℤ × ℤ) :
    lorentzForm v = 0 ↔ IsPythTriple' v.1 v.2.1 v.2.2 := by
  unfold lorentzForm IsPythTriple'; omega


/-- The hypotenuse of M₂(a,b,c) is 2a + 2b + 3c. -/
theorem M₂_hyp (a b c : ℤ) : (M₂ (a, b, c)).2.2 = 2*a + 2*b + 3*c := by
  unfold M₂; ring_nf


/-- **Hypotenuse Growth Theorem for M₂**: For any triple with a,b,c > 0,
applying M₂ strictly increases the hypotenuse. -/
theorem M₂_hyp_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (M₂ (a, b, c)).2.2 := by
  simp [M₂_hyp]; nlinarith


/-- eml(x, 1) = exp(x): exponential recovery. -/
theorem eml'_exp (x : ℝ) : eml' x 1 = Real.exp x := by
  simp [eml', Real.log_one]


/-- eml(0, y) = 1 - log(y): constant-exponential case. -/
theorem eml'_zero_left (y : ℝ) : eml' 0 y = 1 - Real.log y := by
  simp [eml', Real.exp_zero]


/-- eml(eml(x, 1), 1) = exp(exp(x)): double exponential via EML. -/
theorem eml'_double_exp (x : ℝ) : eml' (eml' x 1) 1 = Real.exp (Real.exp x) := by
  simp [eml', Real.log_one]


/-- eml(eml(eml(x,1),1),1) = exp(exp(exp(x))): triple exponential. -/
theorem eml'_triple_exp (x : ℝ) :
    eml' (eml' (eml' x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  simp [eml', Real.log_one]


/-- **EML Fixed Point Theorem**: exp has no real fixed point. -/
theorem eml_exp_no_fixed_point : ∀ x : ℝ, eml' x 1 ≠ x := by
  intro x h
  simp [eml', Real.log_one] at h
  have : Real.exp x > x := by linarith [add_one_le_exp x]
  linarith


/-- Addition in log-space: log(exp(a) * exp(b)) = a + b. -/
theorem eml_add_encoding (a b : ℝ) :
    Real.log (Real.exp a * Real.exp b) = a + b := by
  rw [← Real.exp_add, Real.log_exp]


/-- Subtraction in log-space: log(exp(a) / exp(b)) = a - b. -/
theorem eml_sub_encoding (a b : ℝ) :
    Real.log (Real.exp a / Real.exp b) = a - b := by
  rw [← Real.exp_sub, Real.log_exp]


/-- Multiplication in log-space: exp(log a + log b) = a * b for positive reals. -/
theorem eml_mul_encoding (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    Real.exp (Real.log a + Real.log b) = a * b := by
  rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]


/-- Squaring in log-space: exp(2 * log a) = a² for positive reals. -/
theorem eml_sq_encoding (a : ℝ) (ha : 0 < a) :
    Real.exp (2 * Real.log a) = a ^ 2 := by
  rw [mul_comm, Real.exp_mul, Real.exp_log ha]; norm_num


/-- **Product of Pythagorean hypotenuses**: If c₁² = a₁² + b₁² and c₂² = a₂² + b₂²,
then (c₁·c₂)² = (a₁a₂ - b₁b₂)² + (a₁b₂ + a₂b₁)². -/
theorem pyth_hyp_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTriple' a₁ b₁ c₁) (h₂ : IsPythTriple' a₂ b₂ c₂) :
    IsPythTriple' (a₁*a₂ - b₁*b₂) (a₁*b₂ + a₂*b₁) (c₁ * c₂) := by
  unfold IsPythTriple' at *; nlinarith [brahmagupta_fibonacci a₁ b₁ a₂ b₂]


/-- Every Pythagorean triple satisfies a² + b² - c² = 0. -/
theorem pyth_mod_c (a b c : ℤ) (h : IsPythTriple' a b c) :
    c ∣ (a ^ 2 + b ^ 2 - c ^ 2) := by
  unfold IsPythTriple' at h; simp [h]


/-- A Pythagorean quadruple. -/
def IsPythQuad' (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2


/-- Basic quadruple examples. -/
theorem quad_basic : IsPythQuad' 1 2 2 3 := by norm_num [IsPythQuad']

/-- [Section: ## Section 10: Quadruple Generalizations] -/
theorem quad_237 : IsPythQuad' 2 3 6 7 := by norm_num [IsPythQuad']

theorem quad_1489 : IsPythQuad' 1 4 8 9 := by norm_num [IsPythQuad']


/-- Embedding triples into quadruples. -/
theorem triple_to_quad (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythQuad' a b 0 c := by
  unfold IsPythQuad' IsPythTriple' at *; linarith


/-- Quadruple Lorentz form. -/
def lorentzForm4 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2


/-- Quadruple condition in terms of the 4D Lorentz form. -/
theorem quad_lorentz_zero (a b c d : ℤ) :
    IsPythQuad' a b c d ↔ lorentzForm4 a b c d = 0 := by
  unfold IsPythQuad' lorentzForm4; omega


/-- A Berggren path is a list of steps. -/
abbrev BPath := List BStep


/-- Evaluate a path from the root (3, 4, 5). -/
def evalPath (p : BPath) : ℤ × ℤ × ℤ :=
  p.foldl (fun v s => applyStep s v) (3, 4, 5)


/-- Every single step preserves the Pythagorean property. -/
theorem applyStep_preserves (s : BStep) (v : ℤ × ℤ × ℤ)
    (h : IsPythTriple' v.1 v.2.1 v.2.2) :
    IsPythTriple' (applyStep s v).1 (applyStep s v).2.1 (applyStep s v).2.2 := by
  cases s
  · exact M₁_preserves v h
  · exact M₂_preserves v h
  · exact M₃_preserves v h


/-- Every single step preserves the Lorentz form. -/
theorem applyStep_preserves_lorentz (s : BStep) (v : ℤ × ℤ × ℤ) :
    lorentzForm (applyStep s v) = lorentzForm v := by
  cases s
  · exact M₁_preserves_lorentz v
  · exact M₂_preserves_lorentz v
  · exact M₃_preserves_lorentz v


/-- Folding preserves Pythagorean property. -/
theorem foldl_preserves_pyth (p : BPath) (v : ℤ × ℤ × ℤ)
    (h : IsPythTriple' v.1 v.2.1 v.2.2) :
    let w := p.foldl (fun v s => applyStep s v) v
    IsPythTriple' w.1 w.2.1 w.2.2 := by
  induction p generalizing v with
  | nil => simpa
  | cons s p ih => exact ih _ (applyStep_preserves s v h)


/-- **Main Theorem**: Every Berggren path produces a Pythagorean triple. -/
theorem evalPath_is_pyth (p : BPath) :
    IsPythTriple' (evalPath p).1 (evalPath p).2.1 (evalPath p).2.2 := by
  exact foldl_preserves_pyth p (3, 4, 5) (by norm_num [IsPythTriple'])


/-- Folding preserves the Lorentz form. -/
theorem foldl_preserves_lorentz (p : BPath) (v : ℤ × ℤ × ℤ) :
    lorentzForm (p.foldl (fun v s => applyStep s v) v) = lorentzForm v := by
  induction p generalizing v with
  | nil => simp
  | cons s p ih =>
    simp [List.foldl]
    rw [ih]
    exact applyStep_preserves_lorentz s v


/-- The Lorentz form is invariant along any Berggren path. -/
theorem evalPath_lorentz (p : BPath) :
    lorentzForm (evalPath p) = lorentzForm (3, 4, 5) := by
  exact foldl_preserves_lorentz p (3, 4, 5)


/-- The Lorentz form of the root is 0. -/
theorem root_lorentz : lorentzForm (3, 4, 5) = 0 := by
  native_decide


/-- The root triple. -/
theorem evalPath_root : evalPath [] = (3, 4, 5) := by rfl


/-- First-generation children. -/
theorem evalPath_A : evalPath [.A] = (5, 12, 13) := by native_decide

/-- [Section: ## Section 12: Specific Berggren Computations] -/
theorem evalPath_B : evalPath [.B] = (21, 20, 29) := by native_decide

theorem evalPath_C : evalPath [.C] = (15, 8, 17) := by native_decide


/-- Second-generation examples. -/
theorem evalPath_AA : evalPath [.A, .A] = (7, 24, 25) := by native_decide

theorem evalPath_AB : evalPath [.A, .B] = (55, 48, 73) := by native_decide


/-- All first-generation triples are Pythagorean. -/
theorem first_gen_all_pyth :
    IsPythTriple' 5 12 13 ∧ IsPythTriple' 21 20 29 ∧ IsPythTriple' 15 8 17 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [IsPythTriple']


/-- The log-space Pythagorean variety:
{ (α, β, γ) | exp(2α) + exp(2β) = exp(2γ) }. -/
def pythLogVariety (α β γ : ℝ) : Prop :=
  Real.exp (2 * α) + Real.exp (2 * β) = Real.exp (2 * γ)


/-- Embedding into log-space: if a² + b² = c² for positive a, b, c,
then exp(2 log a) + exp(2 log b) = exp(2 log c). -/
theorem pyth_to_log_variety (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    pythLogVariety (Real.log a) (Real.log b) (Real.log c) := by
  unfold pythLogVariety
  rw [eml_sq_encoding a ha, eml_sq_encoding b hb, eml_sq_encoding c hc]
  exact h


/-- The inverse of M₁: recovers the parent triple from an M₁-child. -/
def M₁_inv (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2,
   -2 * v.1 - v.2.1 + 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)


/-- M₁_inv is a left inverse of M₁. -/
theorem M₁_inv_left (v : ℤ × ℤ × ℤ) : M₁_inv (M₁ v) = v := by
  ext <;> simp [M₁, M₁_inv] <;> ring


/-- M₁_inv is a right inverse of M₁. -/
theorem M₁_inv_right (v : ℤ × ℤ × ℤ) : M₁ (M₁_inv v) = v := by
  ext <;> simp [M₁, M₁_inv] <;> ring


/-- M₁ applied to (3,4,5) gives (5,12,13), and M₁_inv recovers (3,4,5). -/
theorem M₁_inv_example : M₁_inv (5, 12, 13) = (3, 4, 5) := by native_decide


/-- Euclid's parametrization produces Pythagorean triples. -/
theorem euclid_produces_triple (m n : ℤ) :
    IsPythTriple' (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  unfold IsPythTriple'; ring


/-- The EML encoding of Euclid's formula produces valid triples. -/
theorem euclid_eml_bounded :
    ∀ m n : ℤ, ∃ a b c : ℤ,
      a = m ^ 2 - n ^ 2 ∧ b = 2 * m * n ∧ c = m ^ 2 + n ^ 2 ∧
      IsPythTriple' a b c := by
  intro m n
  exact ⟨m^2 - n^2, 2*m*n, m^2 + n^2, rfl, rfl, rfl, euclid_produces_triple m n⟩


/-- Scaling a Pythagorean triple preserves the property. -/
theorem pyth_scale (a b c k : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (k * a) (k * b) (k * c) := by
  unfold IsPythTriple' at *; ring_nf; nlinarith [sq_nonneg k]


/-- In log-space, scaling corresponds to translation. -/
theorem log_scale (k a : ℝ) (hk : 0 < k) (ha : 0 < a) :
    Real.log (k * a) = Real.log k + Real.log a :=
  Real.log_mul (ne_of_gt hk) (ne_of_gt ha)


/-- EML expression tree. -/
inductive EMLExprTree where
  | one : EMLExprTree
  | var : ℕ → EMLExprTree
  | eml : EMLExprTree → EMLExprTree → EMLExprTree


/-- Size of an EML expression tree. -/
def EMLExprTree.size : EMLExprTree → ℕ
  | .one => 1
  | .var _ => 1
  | .eml l r => 1 + l.size + r.size


/-- Depth of an EML expression tree. -/
def EMLExprTree.depth : EMLExprTree → ℕ
  | .one => 0
  | .var _ => 0
  | .eml l r => 1 + max l.depth r.depth


/-- Leaf count. -/
def EMLExprTree.leafCount : EMLExprTree → ℕ
  | .one => 1
  | .var _ => 1
  | .eml l r => l.leafCount + r.leafCount


/-- Internal node count. -/
def EMLExprTree.nodeCount : EMLExprTree → ℕ
  | .one => 0
  | .var _ => 0
  | .eml l r => 1 + l.nodeCount + r.nodeCount


/-- In any binary tree, leaves = internal nodes + 1. -/
theorem EMLExprTree.leaf_eq_node_succ (e : EMLExprTree) :
    e.leafCount = e.nodeCount + 1 := by
  induction e with
  | one => rfl
  | var _ => rfl
  | eml l r ihl ihr =>
    simp [EMLExprTree.leafCount, EMLExprTree.nodeCount, ihl, ihr]; omega


/-- Size = 2 * nodeCount + 1. -/
theorem EMLExprTree.size_eq (e : EMLExprTree) :
    e.size = 2 * e.nodeCount + 1 := by
  induction e with
  | one => rfl
  | var _ => rfl
  | eml l r ihl ihr =>
    simp [EMLExprTree.size, EMLExprTree.nodeCount, ihl, ihr]; omega


/-- Parity predicate: a is odd, b is even, c is odd. -/
def OddEvenOdd (v : ℤ × ℤ × ℤ) : Prop :=
  ¬ Even v.1 ∧ Even v.2.1 ∧ ¬ Even v.2.2


/-- M₁ preserves the (odd, even, odd) parity pattern. -/
theorem M₁_preserves_parity (a b c : ℤ) (h : OddEvenOdd (a, b, c)) :
    OddEvenOdd (M₁ (a, b, c)) := by
  simp only [OddEvenOdd, M₁] at *; obtain ⟨ha, hb, hc⟩ := h
  rw [Int.not_even_iff_odd, Int.odd_iff] at ha hc; rw [Int.even_iff] at hb
  exact ⟨by rw [Int.not_even_iff_odd, Int.odd_iff]; omega,
         by rw [Int.even_iff]; omega,
         by rw [Int.not_even_iff_odd, Int.odd_iff]; omega⟩


/-- M₂ preserves the (odd, even, odd) parity pattern. -/
theorem M₂_preserves_parity (a b c : ℤ) (h : OddEvenOdd (a, b, c)) :
    OddEvenOdd (M₂ (a, b, c)) := by
  simp only [OddEvenOdd, M₂] at *; obtain ⟨ha, hb, hc⟩ := h
  rw [Int.not_even_iff_odd, Int.odd_iff] at ha hc; rw [Int.even_iff] at hb
  exact ⟨by rw [Int.not_even_iff_odd, Int.odd_iff]; omega,
         by rw [Int.even_iff]; omega,
         by rw [Int.not_even_iff_odd, Int.odd_iff]; omega⟩


/-- M₃ preserves the (odd, even, odd) parity pattern. -/
theorem M₃_preserves_parity (a b c : ℤ) (h : OddEvenOdd (a, b, c)) :
    OddEvenOdd (M₃ (a, b, c)) := by
  simp only [OddEvenOdd, M₃] at *; obtain ⟨ha, hb, hc⟩ := h
  rw [Int.not_even_iff_odd, Int.odd_iff] at ha hc; rw [Int.even_iff] at hb
  exact ⟨by rw [Int.not_even_iff_odd, Int.odd_iff]; omega,
         by rw [Int.even_iff]; omega,
         by rw [Int.not_even_iff_odd, Int.odd_iff]; omega⟩


/-- The root (3, 4, 5) has the (odd, even, odd) pattern. -/
theorem root_parity : OddEvenOdd (3, 4, 5) := by
  unfold OddEvenOdd; decide


/-- Any Berggren step preserves the parity pattern. -/
theorem applyStep_preserves_parity (s : BStep) (v : ℤ × ℤ × ℤ)
    (h : OddEvenOdd v) : OddEvenOdd (applyStep s v) := by
  obtain ⟨a, b, c⟩ := v
  cases s
  · exact M₁_preserves_parity a b c h
  · exact M₂_preserves_parity a b c h
  · exact M₃_preserves_parity a b c h


/-- Helper: foldl preserves parity. -/
theorem foldl_preserves_parity (p : BPath) (v : ℤ × ℤ × ℤ)
    (h : OddEvenOdd v) :
    OddEvenOdd (p.foldl (fun v s => applyStep s v) v) := by
  induction p generalizing v with
  | nil => simpa
  | cons s p ih => exact ih _ (applyStep_preserves_parity s v h)


/-- **Parity Invariant Theorem**: Every triple in the Berggren tree
has the pattern (odd, even, odd). -/
theorem evalPath_parity (p : BPath) : OddEvenOdd (evalPath p) :=
  foldl_preserves_parity p (3, 4, 5) root_parity


end
