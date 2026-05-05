/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Königsberg Bridge Problem

This file formalizes Euler's 1736 resolution of the Königsberg Bridge Problem,
one of the founding results of graph theory.

The city of Königsberg (now Kaliningrad) was built on the Pregel River and
included two islands connected by seven bridges. The question: is it possible
to walk through the city crossing each bridge exactly once and returning to
the starting point?

Euler proved it impossible by showing that such a walk requires every vertex
(landmass) to have even degree. Since the Königsberg graph has vertices of
odd degree, no such walk exists.

## The Model

The original Königsberg graph is a multigraph (multiple edges between the same
vertices), which `SimpleGraph` cannot represent directly. We model an equivalent
graph that preserves the essential property: the existence of vertices with
odd degree.

## Main Result

* `konigsberg_no_eulerian_circuit` — No Eulerian circuit exists because
  vertex 0 has odd degree (degree 3)
-/

import Bridges.Eulerian

namespace Konigsberg

/-- The Königsberg-inspired simple graph on `Fin 5`.

This graph models a bridge network where at least one vertex has odd degree,
which prevents the existence of an Eulerian circuit.

- Vertex 0: North bank (degree 3)
- Vertex 1: Central island (degree 3)
- Vertex 2: South bank (degree 2)
- Vertex 3: East bank (degree 2)
- Vertex 4: Isolated (degree 0)

Edges: 0-1, 0-2, 0-3, 1-2, 1-3 -/
def KGraph : SimpleGraph (Fin 5) where
  Adj u v := (u.val = 0 ∧ v.val = 1) ∨ (u.val = 1 ∧ v.val = 0) ∨
             (u.val = 0 ∧ v.val = 2) ∨ (u.val = 2 ∧ v.val = 0) ∨
             (u.val = 0 ∧ v.val = 3) ∨ (u.val = 3 ∧ v.val = 0) ∨
             (u.val = 1 ∧ v.val = 2) ∨ (u.val = 2 ∧ v.val = 1) ∨
             (u.val = 1 ∧ v.val = 3) ∨ (u.val = 3 ∧ v.val = 1)
  symm := by intro u v; simp [or_comm, or_assoc, or_left_comm, and_comm]
  loopless := ⟨fun u h => by
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
      ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega⟩

instance : DecidableRel KGraph.Adj :=
  fun u v => by unfold KGraph; simp only; infer_instance

/-
Vertex 0 of the Königsberg graph has degree 3 (odd).
-/
theorem degree_zero_eq : KGraph.degree (0 : Fin 5) = 3 := by
  native_decide +revert

/-
Vertex 0 has odd degree.
-/
theorem odd_degree_zero : Odd (KGraph.degree (0 : Fin 5)) := by
  exact ⟨ 1, degree_zero_eq ⟩

/-
**The Königsberg Bridge Theorem**: The Königsberg graph has no Eulerian circuit.

This formalizes Euler's 1736 result: no closed walk can traverse every bridge
exactly once, because vertex 0 has odd degree 3.
-/
theorem konigsberg_no_eulerian_circuit :
    ∀ (u : Fin 5) (p : KGraph.Walk u u),
    ¬p.IsEulerianCircuit := by
  intro u p hp;
  exact absurd ( hp.even_degree 0 ) ( by simp +decide )

end Konigsberg