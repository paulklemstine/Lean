/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Eulerian Circuits and the Degree Parity Condition

This file defines **Eulerian circuits** for simple graphs and proves
the fundamental necessary condition: if a graph has an Eulerian circuit,
then every vertex has even degree.

This is one of the oldest theorems in graph theory, dating back to
Euler's 1736 solution of the Königsberg Bridge Problem.

## Main Results

* `IsEulerianCircuit` — A circuit that traverses every edge exactly once
* `IsEulerianCircuit.even_degree` — Every vertex in a graph with an
  Eulerian circuit has even degree
-/

import Mathlib

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]
         {G : SimpleGraph V} [DecidableRel G.Adj]

/-! ## Definition of Eulerian Circuit -/

/-- An **Eulerian circuit** is a closed walk that:
1. Is a trail (no repeated edges)
2. Is non-trivial (not the empty walk)
3. Uses every edge of the graph exactly once -/
structure Walk.IsEulerianCircuit {u : V} (p : G.Walk u u) : Prop where
  /-- The walk is a circuit (closed trail) -/
  isCircuit : p.IsCircuit
  /-- Every edge of the graph appears in the walk -/
  edges_eq : p.edges.toFinset = G.edgeFinset

/-! ## The Degree Parity Theorem -/

/-- **Euler's Degree Parity Theorem**: If a graph has an Eulerian circuit,
then every vertex has even degree.

In an Eulerian circuit, each time the walk passes through a vertex v,
it uses one edge to enter and one to leave. Since every edge is used
exactly once, the degree of v equals twice the number of passes, which
is even. The start vertex is also balanced since the walk is closed. -/
theorem Walk.IsEulerianCircuit.even_degree
    {u : V} {p : G.Walk u u} (hp : p.IsEulerianCircuit) (v : V) :
    Even (G.degree v) := by
  obtain ⟨ hp₁, hp₂ ⟩ := hp;
  have h_deg_even : ∀ v, Even (p.edges.countP (fun e => v ∈ e)) := by
    have h_deg_even : ∀ {u v : V} {p : G.Walk u v}, ∀ w, Even (p.edges.countP (fun e => w ∈ e)) ↔ (w = u ↔ w = v) := by
      intros u v p w; induction' p with u v p ih generalizing w; aesop;
      by_cases hw : w = v <;> by_cases hw' : w = p <;> simp_all +decide;
      · aesop;
      · simp_all +decide [ Nat.even_add_one ];
      · by_cases h : p = ih <;> simp_all +decide [ parity_simps ];
    aesop;
  have h_deg_eq : List.countP (fun e => v ∈ e) p.edges = Finset.card (Finset.filter (fun e => v ∈ e) G.edgeFinset) := by
    rw [ ← hp₂, List.countP_eq_length_filter ];
    rw [ ← Multiset.coe_card ];
    rw [ ← Multiset.toFinset_card_of_nodup ];
    · congr with e ; aesop;
    · exact List.Nodup.filter _ ( hp₁.edges_nodup );
  have h_deg_eq : Finset.card (Finset.filter (fun e => v ∈ e) G.edgeFinset) = Finset.card (G.incidenceFinset v) := by
    grind +suggestions;
  convert h_deg_even v using 1 ; aesop

/-- Contrapositive: if any vertex has odd degree, no Eulerian circuit exists. -/
theorem no_eulerian_circuit_of_odd_degree
    {v : V} (hodd : Odd (G.degree v)) :
    ∀ (u : V) (p : G.Walk u u), ¬p.IsEulerianCircuit := by
  exact fun u p hp => hodd.elim fun k hk => by have := hp.even_degree v; simp_all +decide [ parity_simps ] ;

end SimpleGraph