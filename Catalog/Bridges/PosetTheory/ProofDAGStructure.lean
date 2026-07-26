import Mathlib
import Bridges.PigeonholeInjectionBridge.PigeonholeInjectionBridge

/-!
# Ranked Dependency Networks: Width, Depth, and Robustness

A dependency network is represented by a relation `R`, oriented from a premise to a
statement using that premise.  Acyclicity means that the transitive closure has no
self-loop.  This development separates three structural facts from empirical claims
about large mathematical corpora.

First, every finite acyclic network has a canonical topological rank: the number of
strict ancestors.  Second, combining this rank with the pigeonhole principle gives a
width–depth theorem: if there are more statements than available rank levels, two
statements on one level are incomparable.  Third, a family of totally ordered dependency
networks remains weakly connected after deletion of any one nonterminal vertex.  Thus
acyclicity alone neither implies a power law nor universal hub-removal fragility.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): finite acyclicity should force a topological hierarchy, but
neither a heavy-tailed degree law nor articulation hubs.  A depth bound should instead
force width by a pigeonhole argument.

Experiment (Experimenter): rank each node by the cardinality of its transitive
predecessor set; test deletion on strict total-order networks, where every surviving
pair remains joined by a direct edge in one orientation.

Analysis (Analyst): reachability strictly enlarges predecessor sets, producing the
ranking.  Bounded ranks then create an incomparable pair whenever the vertex count
exceeds the number of levels.  Total-order networks provide robust acyclic examples,
contradicting any graph-theoretic derivation of fragility from acyclicity alone.

Critique (Critic): the results do not estimate a degree-distribution exponent and do
not identify historical theorems as hubs; those are empirical questions requiring a
specified corpus and dependency extraction policy.  Connectivity is explicitly weak
connectivity of the surviving directed network, avoiding an ambiguous use of
"disconnects".  Nonemptiness and cardinality hypotheses prevent vacuity.

Synthesis (Principal Investigator): finite proof structure yields a rigorous
order-theoretic width–depth law, while a concrete robust family establishes the boundary
between structural theorem and corpus-dependent hypothesis.
-- !-- end Lab Notes -- !--
-/

open scoped Classical

namespace ProofDAGStructure

variable {V : Type*}

/-- A direct dependency relation is acyclic when its nonempty transitive closure is
irreflexive. -/
def Acyclic (R : V → V → Prop) : Prop := ∀ v, ¬ Relation.TransGen R v v

/-- The strict ancestors of a node in a finite dependency network. -/
noncomputable def ancestors [Fintype V] (R : V → V → Prop) (v : V) : Finset V :=
  Finset.univ.filter (fun u => Relation.TransGen R u v)

/-
Reachability carries every ancestor of the source to an ancestor of the target.
-/
lemma ancestors_mono [Fintype V] {R : V → V → Prop} {a b : V}
    (hab : Relation.TransGen R a b) : ancestors R a ⊆ ancestors R b := by
  intro v hv
  simp [ancestors] at hv;
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hv.trans hab ⟩

/-
Along a dependency chain, the ancestor set grows strictly.
-/
lemma ancestors_ssubset [Fintype V] {R : V → V → Prop} (hR : Acyclic R)
    {a b : V} (hab : Relation.TransGen R a b) : ancestors R a ⊂ ancestors R b := by
  convert Finset.ssubset_iff_subset_ne.2 ⟨ ancestors_mono hab, ?_ ⟩;
  simp_all +decide [ Finset.ext_iff, ancestors ];
  exact ⟨ a, by have := hR a; tauto ⟩

/-
Every finite acyclic dependency network has a canonical topological numbering,
given by the number of strict ancestors.
-/
theorem canonical_topological_rank [Fintype V] {R : V → V → Prop} (hR : Acyclic R) :
    ∀ {a b : V}, Relation.TransGen R a b →
      (ancestors R a).card < (ancestors R b).card := by
  intro a b hab;
  apply Finset.card_lt_card; exact ancestors_ssubset hR hab;

/-
A bounded topological ranking with fewer levels than vertices forces two distinct,
mutually incomparable statements on the same level.  This is a width–depth tradeoff
obtained by bridging acyclic order structure with the finite pigeonhole principle.
-/
theorem incomparable_pair_of_rank_bound [Fintype V] {R : V → V → Prop}
    (levels : ℕ) (rank : V → Fin levels)
    (hrank : ∀ {a b : V}, Relation.TransGen R a b → rank a < rank b)
    (hcard : levels < Fintype.card V) :
    ∃ a b : V, a ≠ b ∧ ¬ Relation.TransGen R a b ∧ ¬ Relation.TransGen R b a := by
  obtain ⟨a, b, hab, heq⟩ :=
    PigeonholeInjectionBridge.pigeonhole rank (by simpa using hcard)
  exact ⟨a, b, hab, fun h => heq.not_lt (hrank h),
    fun h => heq.not_gt (hrank h)⟩

/-- Weak reachability while avoiding a deleted vertex: each step may follow a dependency
edge in either direction, and every visited endpoint must survive. -/
inductive AvoidingWalk (R : V → V → Prop) (deleted : V) : V → V → Prop
  | refl {a} (ha : a ≠ deleted) : AvoidingWalk R deleted a a
  | step {a b c} (ha : a ≠ deleted) (hab : R a b ∨ R b a)
      (hbc : AvoidingWalk R deleted b c) : AvoidingWalk R deleted a c

/-- The strict total-order dependency network on `Fin n`. -/
def totalOrderDAG (n : ℕ) : Fin n → Fin n → Prop := fun i j => i < j

/-
Strict total-order dependency networks are acyclic.
-/
theorem totalOrderDAG_acyclic (n : ℕ) : Acyclic (totalOrderDAG n) := by
  intro v h;
  have h_trans : ∀ i j : Fin n, Relation.TransGen (fun i j : Fin n => i < j) i j → i < j := by
    intro i j hij; induction hij <;> [ tauto; exact lt_trans ‹_› ‹_› ] ;
  exact lt_irrefl _ ( h_trans _ _ h )

/-
Deleting any vertex from a total-order dependency network leaves all surviving
vertices weakly connected.  This gives an infinite family of acyclic networks with no
single-vertex weak-connectivity fragility.
-/
theorem totalOrderDAG_robust_after_deletion (n : ℕ) (deleted a b : Fin n)
    (ha : a ≠ deleted) (hb : b ≠ deleted) :
    AvoidingWalk (totalOrderDAG n) deleted a b := by
  rcases eq_or_ne a b with rfl | hab;
  · exact AvoidingWalk.refl ha;
  · cases lt_or_gt_of_ne hab <;> [ exact AvoidingWalk.step ha ( Or.inl ( by tauto ) ) ( AvoidingWalk.refl hb ) ; exact AvoidingWalk.step ha ( Or.inr ( by tauto ) ) ( AvoidingWalk.refl hb ) ]

/-
In particular, for every size at least three there is a nontrivial acyclic network,
with three distinct named vertices, whose deletion at an arbitrary vertex preserves weak
connectivity among all survivors.
-/
theorem exists_robust_acyclic_family (n : ℕ) (hn : 3 ≤ n) :
    ∃ R : Fin n → Fin n → Prop,
      Acyclic R ∧
      (∃ x y z : Fin n, x ≠ y ∧ x ≠ z ∧ y ≠ z) ∧
      ∀ deleted a b, a ≠ deleted → b ≠ deleted → AvoidingWalk R deleted a b := by
  use totalOrderDAG n;
  exact ⟨ totalOrderDAG_acyclic n, by
    exact ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, ⟨ 2, by linarith ⟩, by norm_num, by norm_num, by norm_num ⟩, totalOrderDAG_robust_after_deletion n ⟩

end ProofDAGStructure