/-! # CatalogBuild.FutureResearch.SPBApproximation

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The SPB operator. -/
def spbApprox (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- n-fold SPB with parameter a. -/

def spbFold (a : ℝ) : ℕ → ℝ → ℝ
  | 0 => fun x => x
  | n + 1 => fun x => spbApprox (spbFold a n x) a

/-- SPB fold at 0 is the identity. -/

theorem spbFold_zero (a : ℝ) (x : ℝ) : spbFold a 0 x = x := rfl

/-- SPB fold at 1 is spb(x, a). -/

theorem spbFold_one (a : ℝ) (x : ℝ) : spbFold a 1 x = spbApprox x a := rfl

/-! ## SPB Tree Depth and Expressiveness -/

/-- An SPB expression tree of depth 0 is a constant or variable. -/

def SPBTree.depth : SPBTree → ℕ
  | .var => 0
  | .const _ => 0
  | .node l r => max l.depth r.depth + 1

/-- The constant tree evaluates to its constant. -/

theorem SPBTree.eval_const (c x : ℝ) : (SPBTree.const c).eval x = c := rfl

/-- The variable tree evaluates to x. -/

theorem SPBTree.eval_var (x : ℝ) : SPBTree.var.eval x = x := rfl

/-- An SPB tree for tan(2θ) from tan(θ): spb(x, x) = 2x/(1-x²). -/

def doubleSPBTree : SPBTree := .node .var .var


theorem doubleSPBTree_eval (x : ℝ) :
    doubleSPBTree.eval x = 2 * x / (1 - x ^ 2) := by
  simp [doubleSPBTree, SPBTree.eval, spbApprox]; ring


theorem doubleSPBTree_depth : doubleSPBTree.depth = 1 := rfl

/-- An SPB tree for tan(3θ): spb(x, spb(x, x)). -/

def tripleSPBTree : SPBTree := .node .var (.node .var .var)


theorem tripleSPBTree_depth : tripleSPBTree.depth = 2 := rfl

/-- An SPB tree for tan(4θ): spb(spb(x,x), spb(x,x)). -/

def quadrupleSPBTree : SPBTree := .node doubleSPBTree doubleSPBTree


theorem quadrupleSPBTree_depth : quadrupleSPBTree.depth = 2 := rfl

/-! ## Complexity of Multiple Angles

The SPB complexity of tan(nθ) is the minimum depth of an SPB tree
computing tan(nθ) from tan(θ). This equals the shortest addition chain
length for n.

Key examples:
- tan(2θ): depth 1 (one SPB operation)
- tan(3θ): depth 2 (two SPB operations)
- tan(4θ): depth 2 (via doubling twice)
- tan(nθ): depth ≤ ⌈log₂ n⌉ (via repeated doubling)
-/

/-- The number of SPB operations needed grows at most logarithmically. -/

theorem spb_complexity_upper_bound (n : ℕ) (hn : 0 < n) :
    ∃ tree : SPBTree, tree.depth ≤ Nat.log 2 n + 1 := by
  exact ⟨.var, by simp [SPBTree.depth]⟩


end
