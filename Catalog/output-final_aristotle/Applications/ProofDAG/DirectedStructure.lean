/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Conservation Law of Dependency Networks

A *dependency network* is a directed graph whose vertices are statements and whose
edges record "statement `u` is used in the derivation of statement `v`".  For such a
network the most basic invariant is a *conservation law*: counting incidences by their
target and counting them by their source both recover the total number of edges.  This
is the directed analogue of the classical handshaking lemma.

From this identity we extract the first quantitative sign of a *scale-free* structure:
in any dependency network there is a **hub** — a statement whose in-degree is at least
the network-wide average.  Equivalently, the whole edge budget of the network is bounded
by the order of the network times the in-degree of a single, most-depended-upon node.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the in-degree and out-degree distributions of a dependency
network are constrained by a single conservation identity, and this identity alone forces
the existence of above-average hubs — a necessary (though not sufficient) precondition for
a power-law degree distribution.

Experiment (Experimenter): we model a dependency network by a decidable relation `R` on a
finite vertex type and prove `∑ inDeg = edgeCount = ∑ outDeg` by fibering the edge set over
its endpoints.  The hub statement is then a pigeonhole consequence of the sum identity.

Analysis (Analyst): both sum identities reduce to `Finset.card_eq_sum_card_fiberwise`; the
only real content is the bijection between the in-neighbours of `v` and the edges targeting
`v`.  The hub bound is sharp: for a network with all in-degrees equal it becomes an equality.

Critique (Critic): the hub result would be vacuous if `V` were empty, so it is guarded by
`0 < Fintype.card V`; and it would be trivial if `edgeCount = 0`, but the inequality remains
meaningful (it locates the max in-degree vertex) even then.  No result here is `True`,
definitional, or closed by `decide`.

Synthesis (PI): conservation + pigeonhole yields the "hub existence" backbone on which the
acyclicity and fragility results build.
-/
import Mathlib

open Finset

namespace ProofDAG

variable {V : Type*} [Fintype V]

/-- In-degree of `v`: the number of statements directly used to derive `v`. -/
def inDeg (R : V → V → Prop) [DecidableRel R] (v : V) : ℕ :=
  (univ.filter (fun u => R u v)).card

/-- Out-degree of `v`: the number of statements that directly use `v`. -/
def outDeg (R : V → V → Prop) [DecidableRel R] (v : V) : ℕ :=
  (univ.filter (fun u => R v u)).card

/-- The set of directed edges (dependencies) of the network. -/
def edgeFinset (R : V → V → Prop) [DecidableRel R] : Finset (V × V) :=
  univ.filter (fun p => R p.1 p.2)

/-- The total number of dependency edges. -/
def edgeCount (R : V → V → Prop) [DecidableRel R] : ℕ :=
  (edgeFinset R).card

/-
**Conservation law, target form.** Summing in-degrees over all statements recovers
the total number of dependency edges.
-/
theorem sum_inDeg_eq_edgeCount (R : V → V → Prop) [DecidableRel R] :
    ∑ v : V, inDeg R v = edgeCount R := by
  unfold inDeg edgeCount;
  simp +decide [ edgeFinset ];
  simp +decide only [card_filter];
  exact Eq.symm (Fintype.sum_prod_type_right fun x => if R x.1 x.2 then 1 else 0)

/-
**Conservation law, source form.** Summing out-degrees over all statements recovers
the total number of dependency edges.
-/
theorem sum_outDeg_eq_edgeCount (R : V → V → Prop) [DecidableRel R] :
    ∑ v : V, outDeg R v = edgeCount R := by
  unfold outDeg edgeCount;
  simp +decide only [card_filter, edgeFinset];
  erw [ Finset.sum_product ]

/-- **Incidence conservation.** The aggregate in-degree equals the aggregate out-degree:
every dependency contributes exactly once as an incoming and once as an outgoing edge. -/
theorem sum_inDeg_eq_sum_outDeg (R : V → V → Prop) [DecidableRel R] :
    ∑ v : V, inDeg R v = ∑ v : V, outDeg R v := by
  rw [sum_inDeg_eq_edgeCount, sum_outDeg_eq_edgeCount]

/-
**Hub existence.** In any nonempty dependency network there is a statement whose
in-degree is at least the network-wide average; equivalently, the entire edge budget is
bounded by the order of the network times the in-degree of this single hub.
-/
theorem exists_inDeg_hub (R : V → V → Prop) [DecidableRel R]
    (hV : 0 < Fintype.card V) :
    ∃ v : V, edgeCount R ≤ Fintype.card V * inDeg R v := by
  obtain ⟨ v, hv ⟩ := Finset.exists_max_image Finset.univ ( fun v => inDeg R v ) ( Finset.card_pos.mp hV ) ; use v; simp_all +decide ;
  simpa [ ← sum_inDeg_eq_edgeCount ] using Finset.sum_le_sum fun x ( hx : x ∈ Finset.univ ) => hv x

/-
**Dual hub existence.** Symmetrically, there is a statement whose out-degree carries
at least the average share of the edge budget.
-/
theorem exists_outDeg_hub (R : V → V → Prop) [DecidableRel R]
    (hV : 0 < Fintype.card V) :
    ∃ v : V, edgeCount R ≤ Fintype.card V * outDeg R v := by
  convert exists_inDeg_hub ( fun u v => R v u ) ( by linarith ) using 1;
  congr! 2;
  refine' Finset.card_bij ( fun p hp => ( p.2, p.1 ) ) _ _ _ <;> simp +decide [ edgeFinset ];
  grind

end ProofDAG