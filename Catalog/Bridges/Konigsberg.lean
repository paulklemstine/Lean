/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.EulerianTrail

/-!
# The Königsberg Bridge Problem

We formalize and prove the impossibility of the Königsberg Bridge Problem,
the founding result of graph theory (Euler, 1736).

## The Problem

The city of Königsberg (now Kaliningrad) was set on both sides of the Pregel River,
and included two large islands connected to each other and to the two mainland
portions by seven bridges. The problem asks whether there is a walk through the
city that crosses each bridge exactly once.

## The Graph

We model the four landmasses as vertices 0–3 of a multigraph:
- Vertex 0: Central island (Kneiphof)
- Vertex 1: Northern bank
- Vertex 2: Southern bank
- Vertex 3: Eastern island (Lomse)

The seven bridges are:
- Edges 0, 1: Two bridges from vertex 0 to vertex 1
- Edges 2, 3: Two bridges from vertex 0 to vertex 2
- Edge 4: One bridge from vertex 0 to vertex 3
- Edge 5: One bridge from vertex 1 to vertex 3
- Edge 6: One bridge from vertex 2 to vertex 3

## Main Results

* `Bridges.konigsberg_degrees` : The degrees of the four vertices are 5, 3, 3, 3.
* `Bridges.konigsberg_odd_count` : All four vertices have odd degree.
* `Bridges.konigsberg_no_eulerian_trail` : There is no Eulerian trail in the Königsberg graph.
-/

namespace Bridges

/-- The Königsberg bridge graph: 4 vertices, 7 edges. -/
def konigsberg : Multigraph 4 7 where
  endpt₁ := ![0, 0, 0, 0, 0, 1, 2]
  endpt₂ := ![1, 1, 2, 2, 3, 3, 3]

/-- The degree of vertex 0 (Kneiphof island) is 5. -/
theorem konigsberg_degree_0 : konigsberg.degree 0 = 5 := by native_decide

/-- The degree of vertex 1 (northern bank) is 3. -/
theorem konigsberg_degree_1 : konigsberg.degree 1 = 3 := by native_decide

/-- The degree of vertex 2 (southern bank) is 3. -/
theorem konigsberg_degree_2 : konigsberg.degree 2 = 3 := by native_decide

/-- The degree of vertex 3 (Lomse island) is 3. -/
theorem konigsberg_degree_3 : konigsberg.degree 3 = 3 := by native_decide

/-- All four vertices of the Königsberg graph have odd degree. -/
theorem konigsberg_all_odd : ∀ v : Fin 4, konigsberg.degree v % 2 = 1 := by
  intro v; fin_cases v <;> native_decide

/-- The number of odd-degree vertices in the Königsberg graph is 4. -/
theorem konigsberg_odd_count :
    (Finset.univ.filter (fun v : Fin 4 => konigsberg.degree v % 2 = 1)).card = 4 := by
  native_decide

/-- **Königsberg Bridge Theorem**: There is no Eulerian trail in the Königsberg graph.

This is the founding theorem of graph theory. Euler showed in 1736 that since all
four vertices have odd degree, no walk can cross each of the seven bridges exactly once.

The proof combines:
1. The Euler Parity Theorem: any Eulerian trail implies ≤ 2 odd-degree vertices.
2. The computation that Königsberg has 4 odd-degree vertices. -/
theorem konigsberg_no_eulerian_trail : IsEmpty (EulerianTrail konigsberg) := by
  constructor
  intro t
  have h1 := t.odd_degree_vertices_le_two
  have h2 := konigsberg_odd_count
  omega

end Bridges