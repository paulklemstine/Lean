/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Binary Elimination Trees: Definitions

This file defines binary elimination trees (`HTree`) and their core operations,
forming the foundation for hierarchical classifier robustness theory.

## Main definitions

- `HTree α`: A binary tree with leaves labeled by elements of `α`.
- `HTree.eval`: The winner of the elimination tournament under a score function.
- `HTree.classes`: The set of class labels appearing as leaves.
- `HTree.eval_mem_classes`: The winner is always a leaf of the tree.
- `HTree.depth`: The depth of the tree.
-/

open Classical

noncomputable section

/-- Binary elimination tree with leaves labeled by elements of `α`.
    Internal nodes represent pairwise comparisons: the winners of the left
    and right subtrees are compared, and the higher-scoring one advances. -/
inductive HTree (α : Type)
  | leaf : α → HTree α
  | node : HTree α → HTree α → HTree α
  deriving DecidableEq

namespace HTree

variable {α : Type}

/-- The winner of the elimination tournament using score function `s`.
    At each internal node, the winners of the left and right subtrees
    are compared, and the one with the higher (or equal) score advances. -/
def eval : HTree α → (α → ℝ) → α
  | .leaf a, _ => a
  | .node L R, s =>
    let u := L.eval s
    let v := R.eval s
    if s u ≥ s v then u else v

@[simp]
theorem eval_leaf (a : α) (s : α → ℝ) : (HTree.leaf a).eval s = a := rfl

theorem eval_node (L R : HTree α) (s : α → ℝ) :
    (HTree.node L R).eval s =
      if s (L.eval s) ≥ s (R.eval s) then L.eval s else R.eval s := rfl

/-- The set of class labels appearing as leaves in the subtree. -/
def classes [DecidableEq α] : HTree α → Finset α
  | .leaf a => {a}
  | .node L R => L.classes ∪ R.classes

@[simp]
theorem classes_leaf [DecidableEq α] (a : α) : (HTree.leaf a).classes = {a} := rfl

@[simp]
theorem classes_node [DecidableEq α] (L R : HTree α) :
    (HTree.node L R).classes = L.classes ∪ R.classes := rfl

/-- The winner of the elimination tournament is always a leaf of the tree. -/
theorem eval_mem_classes [DecidableEq α] (T : HTree α) (s : α → ℝ) :
    T.eval s ∈ T.classes := by
  induction T with
  | leaf a => simp [eval, classes]
  | node L R ihL ihR =>
    simp only [eval_node, classes_node, Finset.mem_union]
    split
    · exact Or.inl ihL
    · exact Or.inr ihR

/-- The depth of the elimination tree. -/
def depth : HTree α → ℕ
  | .leaf _ => 0
  | .node L R => 1 + max L.depth R.depth

end HTree

end