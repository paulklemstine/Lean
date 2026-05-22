/-
Copyright (c) 2025. All rights reserved.

# Tropical Protocol Trees

This file defines tropical protocol trees and proves foundational theorems:

1. **Bellman/Path Characterization** (`value_eq_inf_pathValues`):
   The tropical value equals the infimum over all root-to-leaf path costs.

2. **Monotonicity** (`value_mono`):
   Pointwise larger leaf data yields a larger root value.

3. **Reconstruction** (`value_eq_of_eqData`):
   Trees with identical structure have identical values.

4. **Depth Lower Bound** (`numLeaves_le_branching_pow_depth`):
   With branching ≤ b, leaf count ≤ b^depth.

5. **Gauge Invariance** (`value_mapLeaves_add_const`):
   Adding constant k to all leaves shifts root value by k.

These formalize patterns from the GL₃ reconstruction theorems and
generalize `post_quantum_tree_depth_bound` from the catalog.
-/

import Mathlib

open WithTop

/-! ## Core Definition -/

/-- A tropical protocol tree: a finite rose tree with edge costs in `ℕ`
and leaf values in `WithTop ℕ` (= ℕ ∪ {⊤}, the min-plus semiring). -/
inductive TropProtocolTree where
  | leaf : WithTop ℕ → TropProtocolTree
  | node : List (ℕ × TropProtocolTree) → TropProtocolTree
deriving Repr

namespace TropProtocolTree

/-! ## Recursive Definitions -/

/-- The tropical value: min-plus aggregation over children.
`value (leaf a) = a`; `value (node cs) = ⨅ᵢ (cᵢ + value Tᵢ)`. -/
def value : TropProtocolTree → WithTop ℕ
  | .leaf a => a
  | .node cs =>
      cs.attach.foldr (fun ⟨p, _⟩ acc => ((p.1 : WithTop ℕ) + p.2.value) ⊓ acc) ⊤
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-- Depth of the tree. -/
def depth : TropProtocolTree → ℕ
  | .leaf _ => 0
  | .node cs => 1 + cs.attach.foldr (fun ⟨p, _⟩ acc => max p.2.depth acc) 0
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-- All root-to-leaf path values: edge cost sum + leaf value for each path. -/
def pathValues : TropProtocolTree → List (WithTop ℕ)
  | .leaf a => [a]
  | .node cs =>
      cs.attach.flatMap (fun ⟨p, _⟩ =>
        (p.2.pathValues).map (fun v => (p.1 : WithTop ℕ) + v))
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-- Number of leaves with finite value. -/
def numFiniteLeaves : TropProtocolTree → ℕ
  | .leaf a => if a = ⊤ then 0 else 1
  | .node cs => cs.attach.foldr (fun ⟨p, _⟩ acc => p.2.numFiniteLeaves + acc) 0
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-- Total number of leaves. -/
def numLeaves : TropProtocolTree → ℕ
  | .leaf _ => 1
  | .node cs => cs.attach.foldr (fun ⟨p, _⟩ acc => p.2.numLeaves + acc) 0
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-- Map a function over leaf values. -/
def mapLeaves (f : WithTop ℕ → WithTop ℕ) : TropProtocolTree → TropProtocolTree
  | .leaf a => .leaf (f a)
  | .node cs => .node (cs.attach.map (fun ⟨p, _⟩ => (p.1, mapLeaves f p.2)))
termination_by t => t
decreasing_by
  simp_wf; have := List.sizeOf_lt_of_mem ‹_›
  cases ‹_ × _›; simp_all [Prod.mk.sizeOf_spec]; omega

/-! ## Inductive Relations -/

/-- Bounded branching: every node has at most `b` children. -/
inductive BoundedBranching (b : ℕ) : TropProtocolTree → Prop where
  | leaf : ∀ a, BoundedBranching b (.leaf a)
  | node : ∀ cs, cs.length ≤ b →
      (∀ p ∈ cs, BoundedBranching b p.2) →
      BoundedBranching b (.node cs)

/-- Pointwise leaf ordering: same shape, same edge costs, leaf values ≤ pointwise. -/
inductive LeData : TropProtocolTree → TropProtocolTree → Prop where
  | leaf (a b : WithTop ℕ) (h : a ≤ b) : LeData (.leaf a) (.leaf b)
  | node_nil : LeData (.node []) (.node [])
  | node_cons {c : ℕ} {t₁ t₂ : TropProtocolTree}
      {cs₁ cs₂ : List (ℕ × TropProtocolTree)}
      (ht : LeData t₁ t₂)
      (hcs : LeData (.node cs₁) (.node cs₂)) :
      LeData (.node ((c, t₁) :: cs₁)) (.node ((c, t₂) :: cs₂))

/-- Structural data equality: same shape, same edge costs, same leaf values. -/
inductive EqData : TropProtocolTree → TropProtocolTree → Prop where
  | leaf (a : WithTop ℕ) : EqData (.leaf a) (.leaf a)
  | node_nil : EqData (.node []) (.node [])
  | node_cons {c : ℕ} {t₁ t₂ : TropProtocolTree}
      {cs₁ cs₂ : List (ℕ × TropProtocolTree)}
      (ht : EqData t₁ t₂)
      (hcs : EqData (.node cs₁) (.node cs₂)) :
      EqData (.node ((c, t₁) :: cs₁)) (.node ((c, t₂) :: cs₂))

/-! ## Simp Lemmas -/

@[simp] theorem value_leaf (a : WithTop ℕ) : (leaf a).value = a := by
  simp [value]

@[simp] theorem value_node_nil : (node []).value = ⊤ := by
  simp [value]

@[simp] theorem depth_leaf (a : WithTop ℕ) : (leaf a).depth = 0 := by
  simp [depth]

@[simp] theorem depth_node_nil : (node []).depth = 1 := by
  simp [depth]

@[simp] theorem numLeaves_leaf (a : WithTop ℕ) : (leaf a).numLeaves = 1 := by
  simp [numLeaves]

@[simp] theorem numLeaves_node_nil : (node []).numLeaves = 0 := by
  simp [numLeaves]

@[simp] theorem pathValues_leaf (a : WithTop ℕ) : (leaf a).pathValues = [a] := by
  simp [pathValues]

@[simp] theorem numFiniteLeaves_leaf (a : WithTop ℕ) :
    (leaf a).numFiniteLeaves = if a = ⊤ then 0 else 1 := by
  simp [numFiniteLeaves]

/-! ## Cons Unfolding Lemmas -/

theorem value_node_cons (c : ℕ) (t : TropProtocolTree)
    (cs : List (ℕ × TropProtocolTree)) :
    (node ((c, t) :: cs)).value = ((c : WithTop ℕ) + t.value) ⊓ (node cs).value := by
  -- By definition of `value`, we can unfold the expression for the value of the node.
  rw [TropProtocolTree.value];
  simp +decide [ List.attach, List.foldr_cons ];
  congr;
  -- By definition of `value`, we can rewrite the right-hand side of the equation.
  rw [TropProtocolTree.value]

theorem numLeaves_node_cons (c : ℕ) (t : TropProtocolTree)
    (cs : List (ℕ × TropProtocolTree)) :
    (node ((c, t) :: cs)).numLeaves = t.numLeaves + (node cs).numLeaves := by
  -- By definition of `numLeaves`, we have:
  have h_numLeaves_def : ∀ (cs : List (ℕ × TropProtocolTree)), (node cs).numLeaves = cs.attach.foldr (fun ⟨p, _⟩ acc => p.2.numLeaves + acc) 0 := by
    -- By definition of `numLeaves`, we have `numLeaves (node cs) = cs.attach.foldr (fun ⟨p, _⟩ acc => p.2.numLeaves + acc) 0`.
    intros cs
    rw [TropProtocolTree.numLeaves];
  simp +decide [ List.attach, h_numLeaves_def ]

theorem numFiniteLeaves_node_cons (c : ℕ) (t : TropProtocolTree)
    (cs : List (ℕ × TropProtocolTree)) :
    (node ((c, t) :: cs)).numFiniteLeaves =
      t.numFiniteLeaves + (node cs).numFiniteLeaves := by
  -- By definition of `numFiniteLeaves`, we can split the sum into the sum of the finite leaves of the first child and the sum of the finite leaves of the rest of the children.
  have h_split : ∀ (cs : List (ℕ × TropProtocolTree)), (node cs).numFiniteLeaves = cs.attach.foldr (fun ⟨p, _⟩ acc => p.2.numFiniteLeaves + acc) 0 := by
    intro cs
    rw [TropProtocolTree.numFiniteLeaves];
  simp +decide [ h_split ];
  conv => rw [ List.foldr_map ] ;

theorem depth_node_cons (c : ℕ) (t : TropProtocolTree)
    (cs : List (ℕ × TropProtocolTree)) :
    (node ((c, t) :: cs)).depth = 1 + max t.depth ((node cs).depth - 1) := by
  -- By definition of depth, we have:
  have h_depth_def : ∀ (cs : List (ℕ × TropProtocolTree)), (node cs).depth = 1 + cs.attach.foldr (fun ⟨p, _⟩ acc => max p.2.depth acc) 0 := by
    intros cs
    rw [TropProtocolTree.depth];
  simp +decide [ List.attach, h_depth_def ]

theorem pathValues_node_cons (c : ℕ) (t : TropProtocolTree)
    (cs : List (ℕ × TropProtocolTree)) :
    (node ((c, t) :: cs)).pathValues =
      (t.pathValues.map (fun v => (c : WithTop ℕ) + v)) ++ (node cs).pathValues := by
  -- By definition of `pathValues`, we can expand the left-hand side.
  rw [pathValues];
  simp +decide [ List.flatMap, List.attach ];
  rw [ pathValues ];
  rfl

/-! ## Theorem 1: Bellman / Path Characterization -/

/-
**Bellman Principle.** The tropical value equals the infimum over all
root-to-leaf path values. This is the fundamental semantic theorem:
recursive min-plus evaluation = global shortest-path optimization.
-/
theorem value_eq_inf_pathValues (T : TropProtocolTree) :
    T.value = T.pathValues.foldr (· ⊓ ·) ⊤ := by
  induction' n : T.depth using Nat.strong_induction_on with n ih generalizing T;
  cases' T with a cs;
  · simp +decide [ TropProtocolTree.pathValues, TropProtocolTree.value ];
  · induction' cs with c cs ihizing n;
    · unfold TropProtocolTree.value TropProtocolTree.pathValues; aesop;
    · rw [ depth_node_cons ] at n;
      rw [ value_node_cons, pathValues_node_cons ];
      rw [ List.foldr_append ];
      rw [ ih _ _ _ rfl ];
      · induction' c.2.pathValues with v vs ih <;> simp +decide [ * ];
        · grind;
        · rw [ ← ih ];
          simp +decide [ ← min_assoc ];
          rw [ ← add_min ];
      · grind

/-! ## Theorem 2: Monotonicity -/

/-
**Monotonicity.** Pointwise larger leaf data ⟹ larger root value.
-/
theorem value_mono {T₁ T₂ : TropProtocolTree} (h : LeData T₁ T₂) :
    T₁.value ≤ T₂.value := by
  -- By induction on the LeData proof h, we can show that the value of T₁ is less than or equal to the value of T₂.
  induction' h with T₁ T₂ h ih;
  · aesop;
  · rfl;
  · simp_all +decide [ value_node_cons ]

/-! ## Theorem 3: Reconstruction -/

theorem eqData_implies_leData {T₁ T₂ : TropProtocolTree} (h : EqData T₁ T₂) :
    LeData T₁ T₂ := by
  induction h;
  · exact TropProtocolTree.LeData.leaf _ _ le_rfl;
  · constructor;
  · exact LeData.node_cons ‹_› ‹_›

theorem eqData_symm {T₁ T₂ : TropProtocolTree} (h : EqData T₁ T₂) :
    EqData T₂ T₁ := by
  -- We'll use induction on the structure of the tree to prove that the equality relation is symmetric.
  induction' h with T₁ T₂ h ih₁T₂ ih;
  · constructor;
  · constructor;
  · exact TropProtocolTree.EqData.node_cons ‹_› ‹_›

/-- **Reconstruction Theorem.** Identical structure ⟹ identical values.
This is the protocol analogue of GL₃ boundary determination. -/
theorem value_eq_of_eqData {T₁ T₂ : TropProtocolTree} (h : EqData T₁ T₂) :
    T₁.value = T₂.value :=
  le_antisymm (value_mono (eqData_implies_leData h))
    (value_mono (eqData_implies_leData (eqData_symm h)))

/-! ## Theorem 4: Depth Lower Bound -/

/-
**Depth Lower Bound.** With branching ≤ b, leaf count ≤ b^depth.
Generalizes `post_quantum_tree_depth_bound` from the catalog.
-/
theorem numLeaves_le_branching_pow_depth (b : ℕ) (T : TropProtocolTree)
    (hb : BoundedBranching b T) : T.numLeaves ≤ b ^ T.depth := by
  induction' hb with T hbT ihT ih;
  · simp +decide [ TropProtocolTree.numLeaves, TropProtocolTree.depth ];
  · -- By definition of `numLeaves` and `depth`, we can expand the left-hand side.
    have h_expand : (node hbT).numLeaves = List.sum (List.map (fun p => p.2.numLeaves) hbT) ∧ (node hbT).depth = 1 + List.foldr (fun p acc => max p.2.depth acc) 0 hbT := by
      constructor <;> induction hbT <;> simp_all +decide [ List.sum_cons, List.foldr ];
      · rename_i k hk ihk;
        rw [ ← hk ( Nat.le_of_lt ihT ), numLeaves_node_cons ];
      · grind +suggestions;
    -- By the induction hypothesis, each child's number of leaves is at most $b^{child.depth}$.
    have h_ind : List.sum (List.map (fun p => p.2.numLeaves) hbT) ≤ List.sum (List.map (fun p => b ^ (List.foldr (fun p acc => max p.2.depth acc) 0 hbT)) hbT) := by
      refine' List.sum_le_sum fun p hp => le_trans ( by solve_by_elim ) _;
      refine' Nat.pow_le_pow_right ( Nat.pos_of_ne_zero _ ) _;
      · rintro rfl; simp_all +decide [ BoundedBranching ];
      · have h_max : ∀ {l : List (ℕ × TropProtocolTree)}, p ∈ l → p.2.depth ≤ List.foldr (fun p acc => max p.2.depth acc) 0 l := by
          intros l hl; induction l <;> aesop;
        exact h_max hp;
    simp_all +decide [ pow_add ];
    exact h_ind.trans ( Nat.mul_le_mul_right _ ihT )

theorem numFiniteLeaves_le_numLeaves (T : TropProtocolTree) :
    T.numFiniteLeaves ≤ T.numLeaves := by
  induction' T using TropProtocolTree.recOn with T ih cs ih;
  rw [ numFiniteLeaves_leaf, numLeaves_leaf ];
  rotate_left;
  bv_omega;
  rotate_left;
  rw [ numFiniteLeaves_node_cons, numLeaves_node_cons ];
  exact add_le_add ( by assumption ) ( by assumption );
  · assumption;
  · split_ifs <;> norm_num;
  · unfold TropProtocolTree.numFiniteLeaves TropProtocolTree.numLeaves; simp +decide ;

/-- Finite leaves bounded by branching^depth. -/
theorem numFiniteLeaves_le_branching_pow_depth (b : ℕ) (T : TropProtocolTree)
    (hb : BoundedBranching b T) : T.numFiniteLeaves ≤ b ^ T.depth :=
  le_trans (numFiniteLeaves_le_numLeaves T) (numLeaves_le_branching_pow_depth b T hb)

/-! ## Theorem 5: Tropical Gauge Invariance -/

/-
**Gauge Invariance.** Adding constant k to all leaves shifts root value by k.
-/
theorem value_mapLeaves_add_const (T : TropProtocolTree) (k : ℕ) :
    (T.mapLeaves (fun a => (k : WithTop ℕ) + a)).value = (k : WithTop ℕ) + T.value := by
  induction' T using TropProtocolTree.recOn with T ih;
  all_goals norm_cast;
  all_goals repeat' rw [ mapLeaves ];
  all_goals norm_num;
  rename_i h₁ h₂;
  convert congr_arg₂ ( · ⊓ · ) _ h₂ using 1;
  convert value_node_cons _ _ _ using 1;
  congr! 1;
  rotate_left;
  rotate_left;
  exact ↑‹ℕ × TropProtocolTree›.1 + ( mapLeaves ( fun a => ↑k + a ) ‹ℕ × TropProtocolTree›.2 ).value;
  exact h₁;
  rotate_left;
  rw [ mapLeaves ];
  congr! 1;
  rw [ value_node_cons ];
  rw [ ← h₁ ];
  rw [ add_min ];
  rw [ ‹ ( mapLeaves ( fun a => ↑k + a ) _ ).value = ↑k + _›, add_comm ];
  grind

end TropProtocolTree