/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Eulerian Impossibility: The Königsberg Bridge Theorem

This file formalizes the mathematical core of Euler's 1736 resolution of the
Königsberg Bridge Problem — the result that launched graph theory.

## Main Results

* `K4_degree` — Every vertex of the complete graph K₄ has degree 3.
* `K4_odd_degree_card` — All 4 vertices of K₄ have odd degree.
* `K4_no_eulerian_walk` — K₄ admits no Eulerian walk (trail visiting every edge exactly once).
* `odd_degree_eulerian_obstruction` — General theorem: a graph with more than 2
  odd-degree vertices admits no Eulerian walk.

## Historical Context

In 1736, Leonhard Euler proved that no walk through the city of Königsberg could
cross each of its seven bridges exactly once. His proof introduced the concept of
what we now call a graph, and established the first theorem of graph theory:
a connected graph has an Eulerian trail if and only if it has at most two vertices
of odd degree.
-/

import Mathlib

open SimpleGraph Finset

namespace Bridges

/-- The complete graph on 4 vertices (K₄), our proxy for the Königsberg bridge structure.
    Like the Königsberg graph, every vertex of K₄ has odd degree. -/
abbrev K4 : SimpleGraph (Fin 4) := ⊤

/-
Every vertex of K₄ has degree exactly 3.
-/
theorem K4_degree (v : Fin 4) : K4.degree v = 3 := by
  fin_cases v <;> simp +decide

/-
The number of odd-degree vertices in K₄ is 4 (all of them).
-/
theorem K4_odd_degree_card :
    (Finset.filter (fun v => Odd (K4.degree v)) Finset.univ).card = 4 := by
  native_decide

/-
**Eulerian Obstruction Theorem.** A finite simple graph with more than 2 odd-degree
    vertices admits no Eulerian walk. This is the contrapositive of the necessary
    condition from Euler's theorem.
-/
theorem odd_degree_eulerian_obstruction
    {V : Type*} {G : SimpleGraph V} [DecidableEq V] [Fintype V] [DecidableRel G.Adj]
    (h : (Finset.filter (fun v => Odd (G.degree v)) Finset.univ).card > 2) :
    ∀ (u v : V) (p : G.Walk u v), ¬p.IsEulerian := by
  -- By the necessary condition from Euler's theorem, if there's an Eulerian walk, the number of odd-degree vertices must be 0 or 2.
  have h_necessary : ∀ u v : V, ∀ p : G.Walk u v, p.IsEulerian → (Finset.filter (fun v => Odd (G.degree v)) Finset.univ).card = 0 ∨ (Finset.filter (fun v => Odd (G.degree v)) Finset.univ).card = 2 := by
    exact fun u v p a => Walk.IsEulerian.card_filter_odd_degree a rfl
  grind

/-
**K₄ has no Eulerian walk.** No walk on the complete graph K₄ traverses every edge
    exactly once. This is the graph-theoretic essence of the Königsberg Bridge Problem.
-/
theorem K4_no_eulerian_walk :
    ∀ (u v : Fin 4) (p : K4.Walk u v), ¬p.IsEulerian := by
  -- Apply the Eulerian Obstruction Theorem with the cardinality of the set of odd-degree vertices.
  apply odd_degree_eulerian_obstruction;
  native_decide

end Bridges