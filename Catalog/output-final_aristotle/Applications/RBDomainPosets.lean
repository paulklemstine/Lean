import Mathlib

/-!
# Combinatorial characterization of RB-shaped finite posets

## Background

For a finite poset `P`, a theorem of Jung and Tix (see `JungTix1998`, building on
`Jung1989` and `AbramskyJung1994`) characterizes when the *probabilistic
powerdomain* of `P` is an **RB-domain** (a retract of a bifinite domain):
this holds **iff** `P` has a least element and the undirected Hasse graph of `P`
is a tree.

The domain-theoretic side of this equivalence (probabilistic powerdomains,
RB-domains, retracts of bifinite domains) is far outside the current scope of
Mathlib.  What *is* fully formalizable — and what we develop here rigorously — is
the **combinatorial characterizing condition** itself, together with the
structural theorems that make it usable:

* the undirected Hasse graph `hasseGraph P` of a finite poset;
* `HasLeast P`, the existence of a least element;
* `RBShape P := HasLeast P ∧ (hasseGraph P).IsTree`, the right-hand side of the
  Jung–Tix characterization.

We build a chain of results culminating in a *computable* reformulation of the
tree condition purely in terms of an edge count:

> A finite poset is RB-shaped **iff** it has a least element and its Hasse graph
> has exactly `n - 1` covering edges (`n = |P|`).

The mathematical heart is `hasseGraph_connected_of_hasLeast`: a least element
forces the Hasse graph to be connected, so for such posets "is a tree" collapses
to the Euler edge count `#edges + 1 = #vertices`.

We do **not** claim to prove the powerdomain/RB-domain equivalence itself; we
formalize the poset-combinatorial half on which that classification rests.
-/

namespace RBDomainPosets

open SimpleGraph

variable {P : Type*} [PartialOrder P]

/-- The undirected Hasse graph of a poset: `a` and `b` are adjacent iff one
covers the other. -/
def hasseGraph (P : Type*) [PartialOrder P] : SimpleGraph P where
  Adj a b := a ⋖ b ∨ b ⋖ a
  symm := by
    intro a b h
    tauto
  loopless := ⟨by
    intro a h
    rcases h with h | h <;> exact (h.lt.ne rfl)⟩

@[simp] lemma hasseGraph_adj {a b : P} :
    (hasseGraph P).Adj a b ↔ (a ⋖ b ∨ b ⋖ a) := Iff.rfl

/-- `P` has a least element. -/
def HasLeast (P : Type*) [PartialOrder P] : Prop := ∃ b : P, ∀ x, b ≤ x

/-- The Jung–Tix "RB shape" of a finite poset: a least element together with a
Hasse graph that is a tree. -/
def RBShape (P : Type*) [PartialOrder P] : Prop :=
  HasLeast P ∧ (hasseGraph P).IsTree

/-
A least element, if it exists, is unique.
-/
theorem least_unique {b b' : P} (hb : ∀ x, b ≤ x) (hb' : ∀ x, b' ≤ x) : b = b' := by
  exact le_antisymm ( hb b' ) ( hb' b )

/-
In a finite poset, every non-minimal element has a lower cover.
-/
theorem exists_lower_cover [Fintype P] {a : P} (ha : ¬ IsMin a) :
    ∃ c, c ⋖ a := by
  apply exists_covBy_of_wellFoundedGT ha

/-
If `b` is a least element of a finite poset, then in the Hasse graph every
vertex is reachable from `b`.
-/
theorem reachable_of_least [Fintype P] {b : P} (hb : ∀ x, b ≤ x) (a : P) :
    (hasseGraph P).Reachable b a := by
  induction' a using WellFoundedLT.induction with a ih;
  by_cases ha : IsMin a;
  · have := ha ( hb a );
    exact le_antisymm this ( hb a ) ▸ SimpleGraph.Reachable.refl _;
  · obtain ⟨ c, hc ⟩ := exists_lower_cover ha;
    exact ( ih c hc.lt ).trans ( SimpleGraph.Adj.reachable ( by tauto ) )

/-
A finite poset with a least element has a connected Hasse graph.
-/
theorem hasseGraph_connected_of_hasLeast [Fintype P] (h : HasLeast P) :
    (hasseGraph P).Connected := by
  obtain ⟨ b, hb ⟩ := h;
  refine' SimpleGraph.connected_iff_exists_forall_reachable _ |>.2 ⟨ b, fun x => _ ⟩;
  grind +suggestions

/-
**Edge count of an RB-shaped poset.** If `P` is RB-shaped then its Hasse
graph has exactly `|P| - 1` covering edges.
-/
theorem rbShape_edge_count [Fintype P] (h : RBShape P) :
    Nat.card (hasseGraph P).edgeSet + 1 = Nat.card P := by
  obtain ⟨ _, htree ⟩ := h;
  have := htree.card_edgeFinset; simp_all +decide [ Nat.card_eq_fintype_card ] ;

/-
**Computable characterization of RB shape.** For a finite poset, being
RB-shaped is equivalent to having a least element and having exactly `|P| - 1`
Hasse edges.  (The tree condition's acyclicity is automatic once a least element
guarantees connectivity, so only the Euler edge count needs to be checked.)
-/
theorem rbShape_iff_hasLeast_and_edgeCount [Fintype P] :
    RBShape P ↔ HasLeast P ∧ Nat.card (hasseGraph P).edgeSet + 1 = Nat.card P := by
  refine' ⟨ _, fun h => ⟨ h.1, _ ⟩ ⟩;
  · exact fun h => ⟨ h.1, rbShape_edge_count h ⟩;
  · refine' SimpleGraph.isTree_iff_connected_and_card.2 ⟨ _, _ ⟩;
    · exact hasseGraph_connected_of_hasLeast h.1;
    · exact h.2

/-
**Any nonempty finite linear order is RB-shaped-ready on the least-element side.**
A finite (indeed any) linear order that is nonempty has a least element, so the
`HasLeast` conjunct of the criterion holds automatically for chains.
-/
theorem linearOrder_hasLeast (L : Type*) [LinearOrder L] [Fintype L] [Nonempty L] :
    HasLeast L :=
  ⟨Finset.univ.min' Finset.univ_nonempty,
    fun x => Finset.min'_le _ _ (Finset.mem_univ x)⟩

/-
**Decidability of having a least element** for a finite poset with decidable
order.  This makes the left conjunct of the criterion checkable.
-/
instance decidableHasLeast [Fintype P] [DecidableEq P] [DecidableRel (· ≤ · : P → P → Prop)] :
    Decidable (HasLeast P) := by
  unfold HasLeast
  infer_instance

/-
**Decidability of RB shape** for a finite poset with decidable order.  Using the
reformulation `rbShape_iff_hasLeast_and_edgeCount`, deciding RB-shape reduces to
the decidable `HasLeast` test together with a single natural-number equality (the
Euler edge count), so the property is decidable.  (It is marked `noncomputable`
only because the underlying `Nat.card` used in the edge count has no executable
code; the decision procedure exists at the propositional level.)
-/
noncomputable instance decidableRBShape
    [Fintype P] [DecidableEq P] [DecidableRel (· ≤ · : P → P → Prop)] :
    Decidable (RBShape P) :=
  decidable_of_iff _ rbShape_iff_hasLeast_and_edgeCount.symm

/-- `CovBy` is decidable in a finite poset with a decidable strict order. -/
instance decidableCovBy [Fintype P] [DecidableRel (· < · : P → P → Prop)] :
    DecidableRel (· ⋖ · : P → P → Prop) := fun a b =>
  decidable_of_iff (a < b ∧ ∀ c, a < c → ¬ c < b)
    ⟨fun ⟨h1, h2⟩ => ⟨h1, fun c hc => h2 c hc⟩, fun ⟨h1, h2⟩ => ⟨h1, fun _ hc => h2 hc⟩⟩

/-- Adjacency in the Hasse graph is decidable in a finite poset with a decidable
strict order. -/
instance decidableHasseAdj [Fintype P] [DecidableRel (· < · : P → P → Prop)] :
    DecidableRel (hasseGraph P).Adj := fun a b => by
  unfold hasseGraph; simp only; infer_instance

/-
**Computable edge-count reformulation.** Same statement as
`rbShape_iff_hasLeast_and_edgeCount`, but phrased with the executable
`Finset.card` of the Hasse edge finset and `Fintype.card`, so that it powers a
genuinely computable decision procedure.
-/
theorem rbShape_iff_hasLeast_and_edgeFinset
    [Fintype P] [DecidableEq P] [DecidableRel (· < · : P → P → Prop)] :
    RBShape P ↔
      HasLeast P ∧ (hasseGraph P).edgeFinset.card + 1 = Fintype.card P := by
  rw [rbShape_iff_hasLeast_and_edgeCount]
  have he : Nat.card (hasseGraph P).edgeSet = (hasseGraph P).edgeFinset.card := by
    rw [Nat.card_eq_fintype_card, SimpleGraph.edgeFinset_card]
  have hv : Nat.card P = Fintype.card P := Nat.card_eq_fintype_card
  rw [he, hv]

/-
**Computable decidability of RB shape.** Using the executable reformulation
`rbShape_iff_hasLeast_and_edgeFinset`, the RB-shape property is decidable by a
genuinely computable procedure (an edge count via `Finset.card` plus the
decidable least-element test).
-/
instance decidableRBShapeComputable
    [Fintype P] [DecidableEq P] [DecidableRel (· ≤ · : P → P → Prop)]
    [DecidableRel (· < · : P → P → Prop)] :
    Decidable (RBShape P) :=
  decidable_of_iff _ rbShape_iff_hasLeast_and_edgeFinset.symm

end RBDomainPosets