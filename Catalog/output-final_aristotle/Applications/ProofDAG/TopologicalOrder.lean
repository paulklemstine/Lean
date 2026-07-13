/-
# Topological Structure of Proof DAGs

A mathematical proof is a directed acyclic graph (DAG): the *nodes* are statements
and the *edges* are the direct-implication (dependency) relation, "statement `a` is
used in the proof of statement `b`".  Acyclicity is exactly the statement that there
is no circular argument: no statement can be reached from itself along a chain of
dependencies.

This file develops the topological structure of such a DAG as a chain of results,
each building on the previous one, culminating in:

* every finite proof DAG admits a **topological numbering** — a rank function `f`
  with `f a < f b` whenever `a` is used (directly or transitively) to prove `b`
  (`IsAcyclic.exists_topological_numbering`);
* every nonempty finite proof DAG has a **foundational statement** (a source: a node
  with no incoming dependency, `IsAcyclic.exists_source`) and a **capstone statement**
  (a sink, `IsAcyclic.exists_sink`);
* a finite proof DAG on `n` statements has at most `n(n-1)/2` direct dependencies
  (`IsAcyclic.two_mul_edgeCount_le`).

Here acyclicity is modeled abstractly: an *acyclic relation* is a relation `R` on a
finite vertex type whose transitive closure is irreflexive.
-/
import Mathlib

open Finset
open scoped Classical

namespace ProofDAG

variable {V : Type*}

/-- A relation `R` (the direct-dependency relation of a proof) is **acyclic** when no
vertex is reachable from itself along a nonempty chain of edges: the transitive
closure `Relation.TransGen R` is irreflexive.  This is precisely the absence of any
circular argument. -/
def IsAcyclic (R : V → V → Prop) : Prop := ∀ v, ¬ Relation.TransGen R v v

/-! ## Step 1–3: Acyclicity forbids short and long cycles -/

/-
An acyclic relation has no self-loops: no statement is used directly in its own
proof.
-/
theorem IsAcyclic.irrefl {R : V → V → Prop} (h : IsAcyclic R) (v : V) : ¬ R v v := by
  exact fun h' => h v ( Relation.TransGen.single h' )

/-
An acyclic relation is asymmetric: two statements cannot each depend directly on
the other.
-/
theorem IsAcyclic.asymm {R : V → V → Prop} (h : IsAcyclic R) (a b : V) :
    R a b → ¬ R b a := by
  exact fun ha hb => h a ( Relation.TransGen.head ha ( Relation.TransGen.single hb ) )

/-
An acyclic relation has no cycles of *any* length: its transitive closure is
asymmetric.  If `a` reaches `b` then `b` cannot reach `a`.
-/
theorem IsAcyclic.transGen_asymm {R : V → V → Prop} (h : IsAcyclic R) (a b : V) :
    Relation.TransGen R a b → ¬ Relation.TransGen R b a := by
  exact fun hab hba => h a <| hab.trans hba

/-! ## Step 4–6: The predecessor set

The rank of a node is the number of its strict ancestors, i.e. the statements that
it depends on (directly or transitively). -/

variable [Fintype V]

/-- The set of strict ancestors of `v`: all `u` from which `v` is reachable along a
nonempty dependency chain. -/
noncomputable def predSet (R : V → V → Prop) (v : V) : Finset V :=
  Finset.univ.filter (fun u => Relation.TransGen R u v)

/-
If `a` reaches `b`, then `a` is a strict ancestor of `b`.
-/
theorem mem_predSet_of_transGen {R : V → V → Prop} {a b : V}
    (h : Relation.TransGen R a b) : a ∈ predSet R b := by
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h ⟩

/-
Reachability is monotone on predecessor sets: if `a` reaches `b`, every ancestor
of `a` is an ancestor of `b`.
-/
theorem predSet_subset_of_transGen {R : V → V → Prop} {a b : V}
    (h : Relation.TransGen R a b) : predSet R a ⊆ predSet R b := by
  intro u hu;
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Relation.TransGen.trans ( Finset.mem_filter.mp hu |>.2 ) h ⟩

/-
In an acyclic relation, no node is its own ancestor.
-/
theorem not_mem_predSet_self {R : V → V → Prop} (h : IsAcyclic R) (a : V) :
    a ∉ predSet R a := by
  exact fun ha => h a ( Finset.mem_filter.mp ha |>.2 )

/-
The key strictness step: if `a` reaches `b` in an acyclic relation, then the
ancestor set of `a` is a *proper* subset of that of `b` (it gains at least `a`
itself).
-/
theorem predSet_ssubset_of_transGen {R : V → V → Prop} (h : IsAcyclic R) {a b : V}
    (hab : Relation.TransGen R a b) : predSet R a ⊂ predSet R b := by
  refine' ⟨ _, fun h' => _ ⟩;
  · grind +suggestions;
  · exact not_mem_predSet_self h a ( h' ( mem_predSet_of_transGen hab ) )

/-! ## Step 7: Topological numbering -/

/-
**Topological numbering.**  Every finite acyclic relation admits a rank function
`f : V → ℕ` that strictly increases along every dependency chain: `f a < f b`
whenever `a` is used (directly or transitively) in the proof of `b`.  In particular
`f a < f b` for every direct edge `R a b`.

The rank of a node is the number of its strict ancestors.
-/
theorem IsAcyclic.exists_topological_numbering {R : V → V → Prop} (h : IsAcyclic R) :
    ∃ f : V → ℕ, ∀ a b : V, Relation.TransGen R a b → f a < f b := by
  use fun v => (predSet R v).card;
  exact fun a b hab => Finset.card_lt_card ( predSet_ssubset_of_transGen h hab )

/-
Direct-edge form of the topological numbering.
-/
theorem IsAcyclic.exists_rank_edge {R : V → V → Prop} (h : IsAcyclic R) :
    ∃ f : V → ℕ, ∀ a b : V, R a b → f a < f b := by
  obtain ⟨ f, hf ⟩ := IsAcyclic.exists_topological_numbering h;
  exact ⟨ f, fun a b hab => hf a b ( Relation.TransGen.single hab ) ⟩

/-! ## Step 8–9: Foundational (source) and capstone (sink) statements -/

/-
**Foundational statement (source).**  Every nonempty finite proof DAG contains a
statement with no incoming dependency: a node `v` such that no `u` satisfies `R u v`.
This is the "axiom-like" foundation on which other statements rest.
-/
theorem IsAcyclic.exists_source {R : V → V → Prop} [Nonempty V] (h : IsAcyclic R) :
    ∃ v : V, ∀ u : V, ¬ R u v := by
  obtain ⟨f, hf⟩ : ∃ f : V → ℕ, ∀ a b : V, R a b → f a < f b := IsAcyclic.exists_rank_edge h;
  exact ⟨ Classical.choose ( Finset.exists_min_image Finset.univ f ( Finset.univ_nonempty ) ), fun u hu => not_le_of_gt ( hf _ _ hu ) ( Classical.choose_spec ( Finset.exists_min_image Finset.univ f ( Finset.univ_nonempty ) ) |>.2 _ ( Finset.mem_univ u ) ) ⟩

/-
**Capstone statement (sink).**  Every nonempty finite proof DAG contains a
statement that is used by nothing else: a node `v` such that no `u` satisfies
`R v u`.
-/
theorem IsAcyclic.exists_sink {R : V → V → Prop} [Nonempty V] (h : IsAcyclic R) :
    ∃ v : V, ∀ u : V, ¬ R v u := by
  obtain ⟨f, hf⟩ : ∃ f : V → ℕ, ∀ a b : V, R a b → f a < f b := IsAcyclic.exists_rank_edge h;
  exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty ) ), fun u hu => not_lt_of_ge ( Classical.choose_spec ( Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty ) ) |>.2 u ( Finset.mem_univ u ) ) ( hf _ _ hu ) ⟩

/-! ## Step 10: Edge-count bound (capstone) -/

/-- The set of direct dependency edges of `R`. -/
noncomputable def edgeFinset (R : V → V → Prop) : Finset (V × V) :=
  Finset.univ.filter (fun p => R p.1 p.2)

/-- The number of direct dependency edges. -/
noncomputable def edgeCount (R : V → V → Prop) : ℕ := (edgeFinset R).card

/-
**Sparsity of proof DAGs.**  A finite acyclic dependency relation on `n`
statements has at most `n(n-1)/2` direct edges; equivalently `2·|E| ≤ n(n-1)`.
This is the directed analogue of the acyclic edge bound: dependencies, having a
consistent direction, cannot be too dense.
-/
theorem IsAcyclic.two_mul_edgeCount_le {R : V → V → Prop} (h : IsAcyclic R) :
    2 * edgeCount R ≤ Fintype.card V * (Fintype.card V - 1) := by
  -- Let $f$ be a rank function for $R$.
  obtain ⟨f, hf⟩ := IsAcyclic.exists_rank_edge h;
  -- Let $A$ be the set of pairs $(a, b)$ such that $f(a) < f(b)$.
  set A := Finset.univ.filter (fun p : V × V => f p.1 < f p.2) with hA_def;
  -- Let $B$ be the set of pairs $(a, b)$ such that $f(a) > f(b)$.
  set B := Finset.univ.filter (fun p : V × V => f p.2 < f p.1) with hB_def;
  -- Since $A$ and $B$ are disjoint and their union is the set of all pairs $(a, b)$ with $a \neq b$, we have $|A \cup B| = |A| + |B|$.
  have h_union : (A ∪ B).card = A.card + B.card := by
    exact Finset.card_union_of_disjoint ( Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith );
  -- Since $A$ and $B$ are disjoint and their union is the set of all pairs $(a, b)$ with $a \neq b$, we have $|A \cup B| \leq n(n-1)$.
  have h_card_union : (A ∪ B).card ≤ Fintype.card V * (Fintype.card V - 1) := by
    refine' le_trans ( Finset.card_le_card _ ) _;
    exact Finset.offDiag Finset.univ;
    · grind +revert;
    · simp +decide [ mul_tsub ];
  -- Since $A$ and $B$ are disjoint and their union is the set of all pairs $(a, b)$ with $a \neq b$, we have $|A| = |B|$.
  have h_card_eq : A.card = B.card := by
    rw [ Finset.card_filter, Finset.card_filter ];
    rw [ ← Equiv.sum_comp ( Equiv.prodComm V V ) ] ; aesop;
  -- Since $edgeFinset R \subseteq A$, we have $edgeCount R \leq A.card$.
  have h_edge_subset_A : edgeFinset R ⊆ A := by
    exact fun p hp => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hf _ _ <| Finset.mem_filter.mp hp |>.2 ⟩;
  linarith [ Finset.card_le_card h_edge_subset_A, show edgeCount R ≤ A.card from Finset.card_le_card h_edge_subset_A ]

end ProofDAG