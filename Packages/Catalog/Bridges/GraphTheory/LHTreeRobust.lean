/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.HTreeRobust
/-!
# Heterogeneous Lipschitz Robustness for Labeled Elimination Trees

This file extends the hierarchical robustness theory to elimination trees where
each internal node has its own Lipschitz constant.

## Main results

- `LHTree.eval_stable`: The tournament winner is preserved if each node's
  margin exceeds its own perturbation budget.
-/

open Classical

noncomputable section

/-- Binary elimination tree with per-node Lipschitz constants. -/
inductive LHTree (α : Type)
  | leaf : α → LHTree α
  | node : ℝ → LHTree α → LHTree α → LHTree α

namespace LHTree

variable {α : Type} {X : Type}

/-- Winner of the labeled elimination tournament. -/
def eval : LHTree α → (α → ℝ) → α
  | .leaf a, _ => a
  | .node _ L R, s =>
    let u := L.eval s
    let v := R.eval s
    if s u ≥ s v then u else v

@[simp]
theorem eval_leaf (a : α) (s : α → ℝ) : (LHTree.leaf a).eval s = a := rfl

theorem eval_node (c : ℝ) (L R : LHTree α) (s : α → ℝ) :
    (LHTree.node c L R).eval s =
      if s (L.eval s) ≥ s (R.eval s) then L.eval s else R.eval s := rfl

/-- Nodewise Lipschitz condition with nonneg constants. -/
def NodewiseLip : LHTree α → (α → X → ℝ) → (X → X → ℝ) → Prop
  | .leaf _, _, _ => True
  | .node c L R, score, D =>
    (0 ≤ c) ∧
    (∀ u v x y,
      |(score u x - score v x) - (score u y - score v y)| ≤ c * D x y) ∧
    L.NodewiseLip score D ∧
    R.NodewiseLip score D

/-- Per-node margin condition. -/
def NodeMarginsAbove : LHTree α → (α → ℝ) → ℝ → Prop
  | .leaf _, _, _ => True
  | .node c L R, s, r =>
    c * r < |s (L.eval s) - s (R.eval s)| ∧
    L.NodeMarginsAbove s r ∧
    R.NodeMarginsAbove s r

/-
**Heterogeneous robustness theorem**: If each internal node's margin
    exceeds its own Lipschitz constant times the distance bound, and the
    nodewise Lipschitz condition holds, then the tournament winner is preserved.
-/
theorem eval_stable
    (T : LHTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (r : ℝ)
    (hLip : T.NodewiseLip score D)
    {x y : X}
    (hy : D x y ≤ r)
    (hmargin : T.NodeMarginsAbove (fun a => score a x) r) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x) := by
  -- By induction on the tree structure.
  induction' T with c L R ihL ihR;
  · rfl;
  · cases hLip;
    cases hmargin;
    rename_i h₁ h₂ h₃;
    rw [ LHTree.eval_node, LHTree.eval_node ];
    split_ifs <;> simp_all +decide [ abs_le ];
    · cases abs_cases ( score ( R.eval fun a => score a x ) x - score ( ihL.eval fun a => score a x ) x ) <;> nlinarith [ h₁.1 ( R.eval fun a => score a x ) ( ihL.eval fun a => score a x ) x y ];
    · cases abs_cases ( score ( R.eval fun a => score a x ) x - score ( ihL.eval fun a => score a x ) x ) <;> nlinarith [ h₁.1 ( R.eval fun a => score a x ) ( ihL.eval fun a => score a x ) x y ]

end LHTree

end