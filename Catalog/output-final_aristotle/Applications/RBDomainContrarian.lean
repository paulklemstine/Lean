import Mathlib

/-!
# Contrarian probes of the Jung–Tix "RB-shape" characterization of finite posets

## Background

For a finite poset `P`, the domain-theoretic literature (Jung 1989; Jung–Tix 1998,
*The troublesome probabilistic powerdomain*) studies when the probabilistic
powerdomain of `P` is an **RB-domain** (a retract of a bifinite domain).  The
folklore/expected characterization is that this happens **iff** `P` has a least
element *and* its undirected Hasse graph is a **tree**.  Accordingly we call a
finite poset *RB-shaped* when

  `RBShape P := HasLeast P ∧ (hasseGraph P).IsTree`.

The genuinely domain-theoretic objects (valuations, powerdomains, bifinite
retracts) are far outside Mathlib, but the *combinatorial* condition above is
fully formalizable, and it is exactly the condition whose two conjuncts the
"team" description claims a suitable `P` must satisfy.

## Contrarian mission

This file, in the "contrarian" spirit, formulates two bold conjectures about
which single condition is *by itself* enough to force RB-shape, and **disproves
both** with explicit finite counterexamples, while isolating the reusable
mathematical core:

* **Conjecture A (refuted).** *A finite poset with a least element is RB-shaped.*
  Refuted by the four-element diamond `Bool × Bool` (the `2 × 2` Boolean
  lattice): it has a least element `(false, false)` but its Hasse graph contains
  a 4-cycle, so it is not a tree.  This is precisely the Jung–Tix obstruction.

* **Conjecture B (refuted).** *A finite poset whose Hasse graph is acyclic (a
  forest) has a least element.*  Refuted by the two-element antichain, whose
  Hasse graph is edgeless — hence acyclic — yet which has no least element.

The reusable heart is `diamond_not_isAcyclic`: **any** poset containing a
covering diamond `a ⋖ b, a ⋖ c, b ⋖ d, c ⋖ d` with `b ≠ c` has a non-acyclic
Hasse graph.  We also record a positive sanity check: the two-element chain
`Bool` *is* RB-shaped, so the characterization is not vacuous.

We do **not** claim the powerdomain/RB-domain equivalence itself; we work with
its combinatorial shadow `RBShape`.
-/

namespace RBDomainContrarian

open SimpleGraph

variable {P : Type*} [PartialOrder P]

/-- The undirected Hasse graph of a poset: `a` and `b` are adjacent iff one
covers the other. -/
def hasseGraph (P : Type*) [PartialOrder P] : SimpleGraph P where
  Adj a b := a ⋖ b ∨ b ⋖ a
  symm := by intro a b h; tauto
  loopless := ⟨by intro a h; rcases h with h | h <;> exact (h.lt.ne rfl)⟩

@[simp] lemma hasseGraph_adj {a b : P} :
    (hasseGraph P).Adj a b ↔ (a ⋖ b ∨ b ⋖ a) := Iff.rfl

/-- `P` has a least element. -/
def HasLeast (P : Type*) [PartialOrder P] : Prop := ∃ b : P, ∀ x, b ≤ x

/-- The combinatorial "RB shape": a least element together with a Hasse graph
that is a tree (connected and acyclic). -/
def RBShape (P : Type*) [PartialOrder P] : Prop :=
  HasLeast P ∧ (hasseGraph P).IsTree

/-! ## The reusable core: a covering diamond destroys acyclicity -/

/-
**Diamond obstruction.**  If a poset contains a covering diamond
`a ⋖ b`, `a ⋖ c`, `b ⋖ d`, `c ⋖ d` with `b ≠ c`, then its Hasse graph is not
acyclic: the two length-2 paths `a–b–d` and `a–c–d` are distinct paths with the
same endpoints.
-/
theorem diamond_not_isAcyclic {a b c d : P}
    (hab : a ⋖ b) (hac : a ⋖ c) (hbd : b ⋖ d) (hcd : c ⋖ d) (hbc : b ≠ c) :
    ¬ (hasseGraph P).IsAcyclic := by
  -- By definition of `IsAcyclic`, we need to show that there exist two distinct paths between a and d.
  intro h
  have h_path1 : (a ≠ b ∧ b ≠ d ∧ a ≠ d) := by
    exact ⟨ hab.ne, hbd.ne, ne_of_lt ( hab.lt.trans hbd.lt ) ⟩
  have h_path2 : (a ≠ c ∧ c ≠ d ∧ a ≠ d) := by
    exact ⟨ hac.ne, hcd.ne, h_path1.2.2 ⟩
  have h_path3 : (b ≠ c) := by
    exact hbc
  have h_path4 : (d ≠ a) := by
    tauto
  have h_path_a_d1 : ∃ p1 : (hasseGraph P).Path a d, p1.val.support = [a, b, d] := by
    refine' ⟨ ⟨ SimpleGraph.Walk.cons ( Or.inl hab ) ( SimpleGraph.Walk.cons ( Or.inl hbd ) SimpleGraph.Walk.nil ), _ ⟩, _ ⟩ <;> simp +decide [ * ]
  have h_path_a_d2 : ∃ p2 : (hasseGraph P).Path a d, p2.val.support = [a, c, d] := by
    refine' ⟨ ⟨ SimpleGraph.Walk.cons ( Or.inl hac ) ( SimpleGraph.Walk.cons ( Or.inl hcd ) SimpleGraph.Walk.nil ), _ ⟩, _ ⟩ <;> simp +decide [ * ];
  obtain ⟨ p1, hp1 ⟩ := h_path_a_d1
  obtain ⟨ p2, hp2 ⟩ := h_path_a_d2
  have h_eq : p1 = p2 := isAcyclic_iff_path_unique.mp h p1 p2
  have h_contra : b = c := by
    grind +splitIndPred
  contradiction

/-- A covering diamond prevents the Hasse graph from being a tree. -/
theorem diamond_not_isTree {a b c d : P}
    (hab : a ⋖ b) (hac : a ⋖ c) (hbd : b ⋖ d) (hcd : c ⋖ d) (hbc : b ≠ c) :
    ¬ (hasseGraph P).IsTree :=
  fun ht => diamond_not_isAcyclic hab hac hbd hcd hbc ht.IsAcyclic

/-- A covering diamond prevents the poset from being RB-shaped. -/
theorem diamond_not_rbShape {a b c d : P}
    (hab : a ⋖ b) (hac : a ⋖ c) (hbd : b ⋖ d) (hcd : c ⋖ d) (hbc : b ≠ c) :
    ¬ RBShape P :=
  fun h => diamond_not_isTree hab hac hbd hcd hbc h.2

/-! ## Conjecture A is false: the diamond `Bool × Bool` -/

section Diamond

/-- Decidable strict order on the diamond, derived from its decidable `≤`. -/
instance : DecidableRel (· < · : (Bool × Bool) → (Bool × Bool) → Prop) :=
  fun _ _ => decidable_of_iff _ (lt_iff_le_not_ge).symm

/-- The covering relation on any finite poset with decidable strict order is
decidable, letting us check the diamond's covers by `decide`. -/
instance decCovBy {Q : Type*} [PartialOrder Q] [Fintype Q] [DecidableEq Q]
    [DecidableRel (· < · : Q → Q → Prop)] :
    DecidableRel (· ⋖ · : Q → Q → Prop) := fun a b =>
  decidable_of_iff (a < b ∧ ∀ c, a < c → ¬ c < b)
    ⟨fun ⟨h1, h2⟩ => ⟨h1, fun c hc => h2 c hc⟩, fun ⟨h1, h2⟩ => ⟨h1, fun _ hc => h2 hc⟩⟩

/-- The `2 × 2` Boolean lattice `Bool × Bool` has a least element `(false, false)`. -/
theorem boolProd_hasLeast : HasLeast (Bool × Bool) :=
  ⟨(false, false), by decide⟩

/-- The Hasse graph of `Bool × Bool` is not a tree: the diamond
`(ff) ⋖ (tf), (ff) ⋖ (ft), (tf) ⋖ (tt), (ft) ⋖ (tt)` gives a 4-cycle. -/
theorem boolProd_not_rbShape : ¬ RBShape (Bool × Bool) :=
  diamond_not_rbShape
    (a := (false, false)) (b := (true, false)) (c := (false, true)) (d := (true, true))
    (by decide) (by decide) (by decide) (by decide) (by decide)

/-- **Refutation of Conjecture A.**  Having a least element is *not sufficient*
for RB-shape: the diamond `Bool × Bool` has a least element yet is not RB-shaped.
This is the Jung–Tix diamond obstruction in combinatorial form. -/
theorem least_not_sufficient_for_rbShape :
    HasLeast (Bool × Bool) ∧ ¬ RBShape (Bool × Bool) :=
  ⟨boolProd_hasLeast, boolProd_not_rbShape⟩

end Diamond

/-! ## Conjecture B is false: the two-element antichain -/

section Antichain

/-- A two-element type carrying the discrete (equality) order: an antichain. -/
inductive Anti2 | a | b
  deriving DecidableEq, Fintype

instance : PartialOrder Anti2 where
  le := Eq
  le_refl := fun _ => rfl
  le_trans := fun _ _ _ h1 h2 => h1.trans h2
  le_antisymm := fun _ _ h1 _ => h1

/-- In the antichain the strict order is empty. -/
theorem anti2_not_lt (x y : Anti2) : ¬ x < y := by
  rw [lt_iff_le_not_ge]; rintro ⟨h1, h2⟩; exact h2 h1.symm.le

/-- The Hasse graph of the antichain is the edgeless graph. -/
theorem hasseGraph_anti2_eq_bot : hasseGraph Anti2 = ⊥ := by
  ext x y
  simp only [hasseGraph_adj, SimpleGraph.bot_adj, iff_false, not_or]
  exact ⟨fun h => anti2_not_lt _ _ h.lt, fun h => anti2_not_lt _ _ h.lt⟩

/-- The antichain's Hasse graph is acyclic (it is a forest). -/
theorem anti2_isAcyclic : (hasseGraph Anti2).IsAcyclic := by
  rw [hasseGraph_anti2_eq_bot]; exact isAcyclic_bot

/-- The antichain has no least element. -/
theorem anti2_not_hasLeast : ¬ HasLeast Anti2 := by
  rintro ⟨w, hw⟩
  have ha : w = Anti2.a := hw Anti2.a
  have hb : w = Anti2.b := hw Anti2.b
  rw [ha] at hb
  exact absurd hb (by decide)

/-- **Refutation of Conjecture B.**  An acyclic Hasse graph (forest) does *not*
force a least element: the two-element antichain is a forest with no least
element. -/
theorem forest_not_sufficient_for_hasLeast :
    (hasseGraph Anti2).IsAcyclic ∧ ¬ HasLeast Anti2 :=
  ⟨anti2_isAcyclic, anti2_not_hasLeast⟩

end Antichain

/-! ## Positive sanity check: the two-element chain is RB-shaped -/

section Chain

/-- The two-element chain `Bool` has least element `false`. -/
theorem bool_hasLeast : HasLeast Bool := ⟨false, by decide⟩

/-
The Hasse graph of `Bool` is a tree, so `Bool` is RB-shaped.  This shows the
`RBShape` condition is not vacuous.
-/
theorem bool_rbShape : RBShape Bool := by
  have h_tree : SimpleGraph.IsTree (hasseGraph Bool) := by
    have h_connected : (hasseGraph Bool).Connected := by
      simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
      exact Or.inl <| SimpleGraph.Adj.reachable <| by simp +decide [ hasseGraph_adj ] ;
    have h_acyclic : (hasseGraph Bool).IsAcyclic := by
      simp +decide [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ];
      simp +decide [ SimpleGraph.isBridge_iff ];
      constructor <;> intro h <;> rcases h with ( _ | ⟨ _, _, h ⟩ ) <;> simp_all +decide [ SimpleGraph.adj_comm ]
    exact (by
    constructor <;> assumption);
  exact ⟨ bool_hasLeast, h_tree ⟩

end Chain

/-! ## Strengthening Conjecture B: a genuine tree without a least element -/

section VTree

/-- The three-element **"V" poset**: two incomparable minimal elements `a, b`
below a common top `c` (`a < c`, `b < c`, with `a, b` incomparable).  Its Hasse
graph is the path `a – c – b`, a genuine tree, yet it has no least element. -/
inductive V3 | a | b | c
  deriving DecidableEq, Fintype

/-- The order relation of the V poset: `x ≤ y` iff `x = y` or `y` is the top `c`. -/
def V3.le (x y : V3) : Prop := x = y ∨ y = V3.c

instance : DecidableRel V3.le :=
  fun x y => inferInstanceAs (Decidable (x = y ∨ y = V3.c))

instance : PartialOrder V3 where
  le := V3.le
  le_refl := by decide
  le_trans := by decide
  le_antisymm := by decide

instance : DecidableRel (· ≤ · : V3 → V3 → Prop) :=
  fun x y => inferInstanceAs (Decidable (V3.le x y))

instance : DecidableRel (· < · : V3 → V3 → Prop) :=
  fun _ _ => decidable_of_iff _ (lt_iff_le_not_ge).symm

/-- The two covering relations of the V poset. -/
theorem v3_ac_covBy : V3.a ⋖ V3.c := by decide
theorem v3_bc_covBy : V3.b ⋖ V3.c := by decide

/-- The V poset has no least element: `a` and `b` are incomparable minimal
elements. -/
theorem v3_not_hasLeast : ¬ HasLeast V3 := by
  show ¬ (∃ w : V3, ∀ x, w ≤ x); decide

/-
The Hasse graph of the V poset is a genuine tree (the path `a – c – b`).
-/
theorem v3_hasseGraph_isTree : (hasseGraph V3).IsTree := by
  refine ⟨SimpleGraph.connected_iff_exists_forall_reachable _ |>.mpr ⟨V3.c, ?_⟩, ?_⟩
  · intro w
    cases w <;> simp +decide [SimpleGraph.Reachable]
    · exact ⟨SimpleGraph.Walk.cons (Or.inr v3_ac_covBy) SimpleGraph.Walk.nil⟩
    · exact ⟨SimpleGraph.Walk.cons (Or.inr v3_bc_covBy) SimpleGraph.Walk.nil⟩
    · exact ⟨SimpleGraph.Walk.nil⟩
  · rw [SimpleGraph.isAcyclic_iff_forall_adj_isBridge]
    simp +decide [SimpleGraph.isBridge_iff, hasseGraph]

/-- **Strengthened refutation of Conjecture B.**  Even a genuine *tree* Hasse
graph (connected and acyclic) does not force a least element: the V poset is a
tree yet has two incomparable minimal elements and no least element.  This
sharpens `forest_not_sufficient_for_hasLeast` from "forest" to "tree". -/
theorem tree_not_sufficient_for_hasLeast :
    (hasseGraph V3).IsTree ∧ ¬ HasLeast V3 :=
  ⟨v3_hasseGraph_isTree, v3_not_hasLeast⟩

end VTree

end RBDomainContrarian