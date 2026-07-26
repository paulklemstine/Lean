import Mathlib

/-!
# Euler's Bridge Theorem

This file formalizes Euler's theorem on Eulerian circuits in simple graphs,
inspired by the famous Königsberg Bridge Problem (1736).

The central result is that **if a graph admits an Eulerian circuit, then every
vertex has even degree**. This is proved by establishing that in any closed walk,
each vertex is incident to an even number of edges — a fact we call the
*Walk Incidence Parity Lemma*. Combined with a trail covering all edges, this
forces every degree to be even.

We also prove the **Odd-Degree Parity Theorem**: in any finite graph, the number
of vertices with odd degree is always even. This is a direct corollary of the
Handshaking Lemma (which is already in Mathlib).

## Main Results

* `Bridges.walk_incidenceCount_mod2` — The parity of the incidence count of any
  vertex in a walk depends only on whether the vertex is an endpoint.
* `Bridges.circuit_incidenceCount_even` — In a closed walk, every vertex has
  even incidence count.
* `Bridges.eulerian_circuit_implies_even_degree` — If a graph has an Eulerian
  circuit, then every vertex has even degree.
* `Bridges.card_odd_degree_vertices_even` — The number of vertices with odd
  degree in any finite graph is even.

## References

* Euler, L. "Solutio problematis ad geometriam situs pertinentis." 1736.
-/

namespace Bridges

open SimpleGraph Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

section WalkIncidence

variable {G : SimpleGraph V} [DecidableRel G.Adj]

/-- The number of edges in a walk's edge list that are incident to a given vertex. -/
noncomputable def Walk.incidenceCount {u v : V} (w : G.Walk u v) (x : V) : ℕ :=
  w.edges.countP (fun e => x ∈ e)

/-
**Walk Incidence Parity Lemma**: In a walk from `u` to `v`, the incidence
count of a vertex `x` has the same parity as the number of endpoints equal to `x`.

This is the combinatorial heart of Euler's theorem. The proof proceeds by
induction on the walk structure.
-/
omit [Fintype V] [DecidableRel G.Adj] in
theorem walk_incidenceCount_mod2 {u v : V} (w : G.Walk u v) (x : V) :
    Walk.incidenceCount w x % 2 =
    ((if x = u then 1 else 0) + (if x = v then 1 else 0)) % 2 := by
  -- By definition of incidence count, we can split the walk into its edges and count the number of edges incident to x.
  have h_edges : ∀ {u v : V} (w : G.Walk u v) (x : V), (w.edges.countP (fun e => x ∈ e)) % 2 = ((if x = u then 1 else 0) + (if x = v then 1 else 0)) % 2 := by
    intro u v w x; induction w <;> simp +decide [ *, List.countP_cons ] ;
    · split_ifs <;> norm_num;
    · split_ifs at * <;> simp_all +decide [ Nat.add_mod ];
  exact h_edges w x

/-
In any closed walk, every vertex has even incidence count.
-/
omit [Fintype V] [DecidableRel G.Adj] in
theorem circuit_incidenceCount_even {u : V} (w : G.Walk u u) (x : V) :
    Even (Walk.incidenceCount w x) := by
  exact even_iff_two_dvd.mpr ( Nat.dvd_of_mod_eq_zero ( by rw [ Bridges.walk_incidenceCount_mod2 ] ; aesop ) )

end WalkIncidence

section EulerianCircuit

variable {G : SimpleGraph V} [DecidableRel G.Adj]

/-- An Eulerian circuit is a circuit (closed trail) that traverses every edge
of the graph exactly once. -/
def IsEulerianCircuit {v : V} (w : G.Walk v v) : Prop :=
  w.IsCircuit ∧ ∀ e ∈ G.edgeFinset, e ∈ w.edges

/-
The edge list of an Eulerian circuit, viewed as a finset, equals the
graph's edge finset.
-/
lemma eulerian_edges_toFinset {v : V} {w : G.Walk v v} (hE : IsEulerianCircuit w) :
    w.edges.toFinset = G.edgeFinset := by
  refine' Finset.Subset.antisymm _ _;
  · exact fun e he => by simpa using w.edges_subset_edgeSet ( List.mem_toFinset.mp he ) ;
  · intro e he; have := hE.2 e; aesop;

/-
The number of edges in a graph's edge finset that are incident to a given
vertex equals the degree of that vertex.
-/
lemma incident_edges_card_eq_degree (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    (G.edgeFinset.filter (fun e => x ∈ e)).card = G.degree x := by
  -- By definition of degree, we know that the degree of x is equal to the number of edges incident to x.
  have h_deg : G.degree x = (G.incidenceFinset x).card := by
    fapply Finset.card_bij;
    use fun a ha => s(x, a);
    · aesop;
    · grind;
    · simp +decide [ SimpleGraph.incidenceSet ];
      rintro ⟨ u, v ⟩ huv hxuv; cases hxuv; aesop;
  grind +suggestions

/-
In an Eulerian circuit, the incidence count of any vertex equals its degree.
-/
lemma eulerian_incidenceCount_eq_degree {v : V} {w : G.Walk v v}
    (hE : IsEulerianCircuit w) (x : V) :
    Walk.incidenceCount w x = G.degree x := by
  rw [ ← incident_edges_card_eq_degree G x, Walk.incidenceCount ];
  rw [ List.countP_eq_length_filter ];
  rw [ ← List.toFinset_card_of_nodup ];
  · congr 1 with e ; simp +decide;
    exact fun _ => ⟨ fun h => by simpa using w.edges_subset_edgeSet h, fun h => by have := hE.2 e; aesop ⟩;
  · exact List.Nodup.filter _ ( hE.1.edges_nodup )

/-- **Euler's Bridge Theorem (Necessary Condition)**: If a graph admits an
Eulerian circuit, then every vertex has even degree.

This is the result Euler used in 1736 to prove that the Königsberg Bridge
Problem has no solution, marking the birth of graph theory. -/
theorem eulerian_circuit_implies_even_degree {v : V} {w : G.Walk v v}
    (hE : IsEulerianCircuit w) (x : V) :
    Even (G.degree x) := by
  rw [← eulerian_incidenceCount_eq_degree hE]
  exact circuit_incidenceCount_even w x

end EulerianCircuit

section OddDegree

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-
**Odd-Degree Parity Theorem**: The number of vertices with odd degree in any
finite graph is always even. This is a direct corollary of the Handshaking Lemma
(`SimpleGraph.sum_degrees_eq_twice_card_edges`).
-/
omit [DecidableEq V] in
theorem card_odd_degree_vertices_even :
    Even (Finset.univ.filter (fun v => Odd (G.degree v))).card := by
  exact SimpleGraph.even_card_odd_degree_vertices G

end OddDegree

end Bridges