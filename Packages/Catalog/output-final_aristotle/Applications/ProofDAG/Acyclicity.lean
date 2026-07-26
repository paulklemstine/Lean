/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Acyclicity, Foundations, and the Order Structure of Dependency Networks

A dependency network is *acyclic* precisely when no statement transitively depends on
itself: a genuine derivation can never route back to its own conclusion.  We encode this
by requiring the transitive closure of the dependency relation to be irreflexive.

Acyclicity has two immediate structural consequences on a finite network:

* the transitive closure is a **strict partial order** (irreflexive and transitive), so
  "is used, directly or indirectly, in the proof of" is a genuine ranking of statements;
* every nonempty finite acyclic network possesses a **foundation** (a source: a statement
  with no dependencies) and a **frontier** (a sink: a statement nothing depends on).

The foundation result is the precise sense in which mathematics rests on axioms: run the
dependency arrows backwards and, because the network is finite and acyclic, you must halt
at statements that are assumed rather than derived.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): acyclicity, finiteness, and nonemptiness together force the
existence of a dependency-free foundational statement — the graph-theoretic shadow of "every
proof bottoms out at axioms".

Experiment (Experimenter): encode acyclicity as irreflexivity of `Relation.TransGen R`.  The
transitive closure is transitive by construction, hence (finite + irreflexive) well-founded;
a minimal element of the whole type under the closure is a source of `R`.  Sinks follow by
applying the source result to the reversed relation.

Analysis (Analyst): the crux is `Finite.wellFounded_of_trans_of_irrefl`, which upgrades an
irreflexive transitive relation on a finite type to a well-founded one.  The reversal
argument reuses `Relation.TransGen` commuting with `flip`, avoiding a second well-foundedness
proof.

Critique (Critic): the source/sink statements are non-vacuous — they are existentials guarded
by `[Nonempty V]`, and the acyclicity hypothesis is genuinely load-bearing (a network with a
2-cycle has neither a source nor a sink).  `Acyclic.irrefl` is a real specialisation, not a
restatement: it extracts direct irreflexivity from transitive irreflexivity.

Synthesis (PI): the strict-order and foundation results turn a bare relation into a ranked,
axiom-grounded structure, providing the scaffolding for fragility analysis.
-/
import Mathlib

namespace ProofDAG

variable {V : Type*}

/-- A dependency relation is **acyclic** when no statement transitively depends on itself. -/
def Acyclic (R : V → V → Prop) : Prop := ∀ v, ¬ Relation.TransGen R v v

/-
Acyclicity forbids a statement from being an immediate premise of itself.
-/
theorem Acyclic.irrefl {R : V → V → Prop} (h : Acyclic R) (v : V) : ¬ R v v := by
  exact fun h' => h v ( Relation.TransGen.single h' )

/-- Under acyclicity, the transitive closure "is used, directly or indirectly, to prove"
is a strict partial order on statements. -/
theorem transGen_isStrictOrder {R : V → V → Prop} (h : Acyclic R) :
    IsStrictOrder V (Relation.TransGen R) where
  irrefl := h
  trans := fun _ _ _ => Relation.TransGen.trans

/-
**Existence of foundations.** Every nonempty finite acyclic dependency network contains
a source: a statement with no dependencies at all.
-/
theorem exists_source {R : V → V → Prop} [Finite V] [Nonempty V] (h : Acyclic R) :
    ∃ v : V, ∀ u : V, ¬ R u v := by
  -- By contradiction, assume there is no such v.
  by_contra h_no_source;
  obtain ⟨a, ha⟩ : ∃ a : V, ∀ b : V, ¬Relation.TransGen R b a := by
    convert ( WellFounded.has_min ( Finite.wellFounded_of_trans_of_irrefl ( Relation.TransGen ( R ) ) ) ( Set.univ : Set V ) ( Set.univ_nonempty ) ) using 1;
    · aesop;
    · exact ⟨ fun v hv => h v hv ⟩;
  exact h_no_source ⟨ a, fun u hu => ha u <| Relation.TransGen.single hu ⟩

/-
**Existence of frontiers.** Every nonempty finite acyclic dependency network contains a
sink: a statement on which nothing depends.
-/
theorem exists_sink {R : V → V → Prop} [Finite V] [Nonempty V] (h : Acyclic R) :
    ∃ v : V, ∀ u : V, ¬ R v u := by
  convert exists_source _;
  · infer_instance;
  · grind;
  · intro v hv;
    convert h v _;
    exact Relation.transGen_swap.mp hv

end ProofDAG