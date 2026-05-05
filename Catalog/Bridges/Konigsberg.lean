--- a/Bridges/Konigsberg.lean
+++ b/Bridges/Konigsberg.lean
@@ -1,168 +1,86 @@
---- a/Bridges/Konigsberg.lean
-+++ b/Bridges/Konigsberg.lean
-@@ -1,99 +1,86 @@
- /-
--Copyright (c) 2025. All rights reserved.
--Released under Apache 2.0 license.
-+Copyright (c) 2025 Harmonic. All rights reserved.
-+Released under Apache 2.0 license as described in the file LICENSE.
-+-/
-+import Mathlib
-+import Bridges.EulerianTrail
- 
--# The Königsberg Bridge Problem — Formalized
-+/-!
-+# The Königsberg Bridge Problem
- 
--This file formalizes the Königsberg Bridge Problem, widely considered
--the founding problem of graph theory. In 1736, Euler proved that it is
--impossible to traverse all seven bridges of Königsberg exactly once.
-+We formalize and prove the impossibility of the Königsberg Bridge Problem,
-+the founding result of graph theory (Euler, 1736).
- 
--We model the Königsberg graph (4 vertices, 7 edges as a multigraph)
--and prove impossibility using the Eulerian trail parity condition.
-+## The Problem
- 
--Since Mathlib's `SimpleGraph` does not support multigraphs, we work
--with a simple-graph abstraction that captures the essential parity
--obstruction: a graph where more than two vertices have odd degree
--cannot have an Eulerian trail.
-+The city of Königsberg (now Kaliningrad) was set on both sides of the Pregel River,
-+and included two large islands connected to each other and to the two mainland
-+portions by seven bridges. The problem asks whether there is a walk through the
-+city that crosses each bridge exactly once.
- 
--## Main results
-+## The Graph
- 
--* `konigsberg_no_eulerian_trail` — The Königsberg graph has no Eulerian trail.
--* `odd_degree_obstruction` — A graph with more than 2 odd-degree vertices
--  has no Eulerian trail (from Mathlib).
--* `konigsberg_four_odd` — All four Königsberg vertices have odd degree.
-+We model the four landmasses as vertices 0–3 of a multigraph:
-+- Vertex 0: Central island (Kneiphof)
-+- Vertex 1: Northern bank
-+- Vertex 2: Southern bank
-+- Vertex 3: Eastern island (Lomse)
-+
-+The seven bridges are:
-+- Edges 0, 1: Two bridges from vertex 0 to vertex 1
-+- Edges 2, 3: Two bridges from vertex 0 to vertex 2
-+- Edge 4: One bridge from vertex 0 to vertex 3
-+- Edge 5: One bridge from vertex 1 to vertex 3
-+- Edge 6: One bridge from vertex 2 to vertex 3
-+
-+## Main Results
-+
-+* `Bridges.konigsberg_degrees` : The degrees of the four vertices are 5, 3, 3, 3.
-+* `Bridges.konigsberg_odd_count` : All four vertices have odd degree.
-+* `Bridges.konigsberg_no_eulerian_trail` : There is no Eulerian trail in the Königsberg graph.
- -/
- 
--import Mathlib
-+namespace Bridges
- 
--/-! ### The Königsberg graph
-+/-- The Königsberg bridge graph: 4 vertices, 7 edges. -/
-+def konigsberg : Multigraph 4 7 where
-+  endpt₁ := ![0, 0, 0, 0, 0, 1, 2]
-+  endpt₂ := ![1, 1, 2, 2, 3, 3, 3]
- 
--The city of Königsberg (now Kaliningrad) had 4 landmasses connected by
--7 bridges. We model this as a complete graph on 4 vertices (K₄), which
--is the simple graph that captures the connectivity pattern.
-+/-- The degree of vertex 0 (Kneiphof island) is 5. -/
-+theorem konigsberg_degree_0 : konigsberg.degree 0 = 5 := by native_decide
- 
--In the original problem, some pairs of landmasses had multiple bridges
--between them, making the true model a multigraph. However, for the
--Eulerian trail condition, what matters is the parity of degrees at each
--vertex. K₄ has all vertices of degree 3 (odd), which suffices to prove
--impossibility via Euler's theorem. -/
-+/-- The degree of vertex 1 (northern bank) is 3. -/
-+theorem konigsberg_degree_1 : konigsberg.degree 1 = 3 := by native_decide
- 
--/-- The four landmasses of Königsberg. -/
--inductive Konigsberg : Type
--  | A  -- North bank
--  | B  -- South bank
--  | C  -- Island (Kneiphof)
--  | D  -- East district
--  deriving DecidableEq, Fintype
-+/-- The degree of vertex 2 (southern bank) is 3. -/
-+theorem konigsberg_degree_2 : konigsberg.degree 2 = 3 := by native_decide
- 
--open Konigsberg
--
--/-- The Königsberg graph modeled as K₄ (complete graph on 4 vertices).
--Every pair of distinct vertices is connected, capturing the fact that
--every pair of landmasses had at least one bridge between them. -/
--def konigsbergGraph : SimpleGraph Konigsberg := ⊤
--
--instance : DecidableRel konigsbergGraph.Adj := by
--  intro u v
--  simp only [konigsbergGraph]
--  infer_instance
--
--/-
--Every vertex in K₄ has degree 3 (odd).
---/
--theorem konigsberg_degree (v : Konigsberg) : konigsbergGraph.degree v = 3 := by
--  fin_cases v <;> simp +decide
-+/-- The degree of vertex 3 (Lomse island) is 3. -/
-+theorem konigsberg_degree_3 : konigsberg.degree 3 = 3 := by native_decide
- 
- /-- All four vertices of the Königsberg graph have odd degree. -/
--theorem konigsberg_all_odd :
--    ∀ v : Konigsberg, Odd (konigsbergGraph.degree v) := by
--  intro v
--  rw [konigsberg_degree]
--  exact ⟨1, rfl⟩
-+theorem konigsberg_all_odd : ∀ v : Fin 4, konigsberg.degree v % 2 = 1 := by
-+  intro v; fin_cases v <;> native_decide
- 
--/-
--The number of odd-degree vertices in the Königsberg graph is 4.
---/
--theorem konigsberg_four_odd :
--    Fintype.card { v : Konigsberg // Odd (konigsbergGraph.degree v) } = 4 := by
--  decide +revert
-+/-- The number of odd-degree vertices in the Königsberg graph is 4. -/
-+theorem konigsberg_odd_count :
-+    (Finset.univ.filter (fun v : Fin 4 => konigsberg.degree v % 2 = 1)).card = 4 := by
-+  native_decide
- 
--/-- **Euler's Theorem (necessary condition)**: If a graph has an Eulerian trail,
--then the number of odd-degree vertices is 0 or 2.
--This is the key obstruction from Mathlib. -/
--theorem euler_necessary {V : Type*} [Fintype V] [DecidableEq V]
--    {G : SimpleGraph V} [DecidableRel G.Adj] {u v : V}
--    {p : G.Walk u v} (hp : p.IsEulerian) :
--    Fintype.card { w : V | Odd (G.degree w) } = 0 ∨
--    Fintype.card { w : V | Odd (G.degree w) } = 2 :=
--  hp.card_odd_degree
-+/-- **Königsberg Bridge Theorem**: There is no Eulerian trail in the Königsberg graph.
- 
--/-
--**The Königsberg Bridge Theorem**: There is no Eulerian trail in the
--Königsberg graph. This formalizes Euler's 1736 result — one cannot walk
--through Königsberg crossing each bridge exactly once.
---/
--theorem konigsberg_no_eulerian_trail :
--    ∀ (u v : Konigsberg) (p : konigsbergGraph.Walk u v), ¬p.IsEulerian := by
--  intro u v p h;
--  have := euler_necessary h; simp_all +decide ;+This is the founding theorem of graph theory. Euler showed in 1736 that since all
-+four vertices have odd degree, no walk can cross each of the seven bridges exactly once.
-+
-+The proof combines:
-+1. The Euler Parity Theorem: any Eulerian trail implies ≤ 2 odd-degree vertices.
-+2. The computation that Königsberg has 4 odd-degree vertices. -/
-+theorem konigsberg_no_eulerian_trail : IsEmpty (EulerianTrail konigsberg) := by
-+  constructor
-+  intro t
-+  have h1 := t.odd_degree_vertices_le_two
-+  have h2 := konigsberg_odd_count
-+  omega
-+
-+end Bridges+/-
+Copyright (c) 2025 Harmonic. All rights reserved.
+Released under Apache 2.0 license as described in the file LICENSE.
+-/
+import Mathlib
+import Bridges.EulerianTrail
+
+/-!
+# The Königsberg Bridge Problem
+
+We formalize and prove the impossibility of the Königsberg Bridge Problem,
+the founding result of graph theory (Euler, 1736).
+
+## The Problem
+
+The city of Königsberg (now Kaliningrad) was set on both sides of the Pregel River,
+and included two large islands connected to each other and to the two mainland
+portions by seven bridges. The problem asks whether there is a walk through the
+city that crosses each bridge exactly once.
+
+## The Graph
+
+We model the four landmasses as vertices 0–3 of a multigraph:
+- Vertex 0: Central island (Kneiphof)
+- Vertex 1: Northern bank
+- Vertex 2: Southern bank
+- Vertex 3: Eastern island (Lomse)
+
+The seven bridges are:
+- Edges 0, 1: Two bridges from vertex 0 to vertex 1
+- Edges 2, 3: Two bridges from vertex 0 to vertex 2
+- Edge 4: One bridge from vertex 0 to vertex 3
+- Edge 5: One bridge from vertex 1 to vertex 3
+- Edge 6: One bridge from vertex 2 to vertex 3
+
+## Main Results
+
+* `Bridges.konigsberg_degrees` : The degrees of the four vertices are 5, 3, 3, 3.
+* `Bridges.konigsberg_odd_count` : All four vertices have odd degree.
+* `Bridges.konigsberg_no_eulerian_trail` : There is no Eulerian trail in the Königsberg graph.
+-/
+
+namespace Bridges
+
+/-- The Königsberg bridge graph: 4 vertices, 7 edges. -/
+def konigsberg : Multigraph 4 7 where
+  endpt₁ := ![0, 0, 0, 0, 0, 1, 2]
+  endpt₂ := ![1, 1, 2, 2, 3, 3, 3]
+
+/-- The degree of vertex 0 (Kneiphof island) is 5. -/
+theorem konigsberg_degree_0 : konigsberg.degree 0 = 5 := by native_decide
+
+/-- The degree of vertex 1 (northern bank) is 3. -/
+theorem konigsberg_degree_1 : konigsberg.degree 1 = 3 := by native_decide
+
+/-- The degree of vertex 2 (southern bank) is 3. -/
+theorem konigsberg_degree_2 : konigsberg.degree 2 = 3 := by native_decide
+
+/-- The degree of vertex 3 (Lomse island) is 3. -/
+theorem konigsberg_degree_3 : konigsberg.degree 3 = 3 := by native_decide
+
+/-- All four vertices of the Königsberg graph have odd degree. -/
+theorem konigsberg_all_odd : ∀ v : Fin 4, konigsberg.degree v % 2 = 1 := by
+  intro v; fin_cases v <;> native_decide
+
+/-- The number of odd-degree vertices in the Königsberg graph is 4. -/
+theorem konigsberg_odd_count :
+    (Finset.univ.filter (fun v : Fin 4 => konigsberg.degree v % 2 = 1)).card = 4 := by
+  native_decide
+
+/-- **Königsberg Bridge Theorem**: There is no Eulerian trail in the Königsberg graph.
+
+This is the founding theorem of graph theory. Euler showed in 1736 that since all
+four vertices have odd degree, no walk can cross each of the seven bridges exactly once.
+
+The proof combines:
+1. The Euler Parity Theorem: any Eulerian trail implies ≤ 2 odd-degree vertices.
+2. The computation that Königsberg has 4 odd-degree vertices. -/
+theorem konigsberg_no_eulerian_trail : IsEmpty (EulerianTrail konigsberg) := by
+  constructor
+  intro t
+  have h1 := t.odd_degree_vertices_le_two
+  have h2 := konigsberg_odd_count
+  omega
+
+end Bridges