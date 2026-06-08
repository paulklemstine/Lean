/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.Multigraph

/-!
# Eulerian Trails and the Parity Theorem

We define Eulerian trails in finite multigraphs and prove the fundamental
**Euler Parity Theorem**: a multigraph admitting an Eulerian trail has at
most two vertices of odd degree.

## Main Definitions

* `Bridges.EulerianTrail` : An Eulerian trail in a multigraph.
* `Bridges.EulerianTrail.visitCount` : Number of times a vertex appears in the vertex sequence.

## Main Results

* `Bridges.EulerianTrail.degree_visit_identity` : `degree(v) + [start=v] + [end=v] = 2·visits(v)`.
* `Bridges.EulerianTrail.odd_degree_vertices_le_two` : At most 2 vertices have odd degree.
-/

namespace Bridges

/-- An Eulerian trail in a multigraph: a walk that traverses every edge exactly once. -/
structure EulerianTrail {nV nE : ℕ} (G : Multigraph nV nE) where
  /-- The sequence of vertices visited. -/
  vertices : Fin (nE + 1) → Fin nV
  /-- The edge used at step `i`. A permutation ensures every edge is used exactly once. -/
  edgePerm : Equiv.Perm (Fin nE)
  /-- At each step, the edge connects consecutive vertices. -/
  connects : ∀ i : Fin nE,
    let e := edgePerm i
    (G.endpt₁ e = vertices i.castSucc ∧ G.endpt₂ e = vertices i.succ) ∨
    (G.endpt₁ e = vertices i.succ ∧ G.endpt₂ e = vertices i.castSucc)

namespace EulerianTrail

variable {nV nE : ℕ} {G : Multigraph nV nE} (t : EulerianTrail G)

/-- The number of times vertex `v` appears in the trail's vertex sequence. -/
def visitCount (v : Fin nV) : ℕ :=
  (Finset.univ.filter (fun j : Fin (nE + 1) => t.vertices j = v)).card

/-- The starting vertex of the trail. -/
def startVertex : Fin nV := t.vertices (0 : Fin (nE + 1))

/-- The ending vertex of the trail. -/
def endVertex : Fin nV := t.vertices (Fin.last nE)

/-- Indicator function: 1 if the proposition holds, 0 otherwise. -/
abbrev ind (P : Prop) [Decidable P] : ℕ := if P then 1 else 0

/-
**Step Count Lemma**: At each step, the count of `v` among edge endpoints
equals the count among consecutive vertices.
-/
theorem step_count_eq (v : Fin nV) (i : Fin nE) :
    ind (G.endpt₁ (t.edgePerm i) = v) + ind (G.endpt₂ (t.edgePerm i) = v) =
    ind (t.vertices i.castSucc = v) + ind (t.vertices i.succ = v) := by
      cases t.connects i <;> simp_all +decide [ ind ];
      ring

/-
The indicator sum over `castSucc` plus the last-vertex indicator equals the visit count.
-/
theorem sum_indicator_castSucc (v : Fin nV) :
    (∑ i : Fin nE, ind (t.vertices i.castSucc = v)) + ind (t.vertices (Fin.last nE) = v) =
    t.visitCount v := by
      -- We can rewrite the visit count as a sum over the indices using the indicator function.
      have h_visit_sum : t.visitCount v = ∑ j : Fin (nE + 1), (if t.vertices j = v then 1 else 0) := by
        simp [visitCount];
      rw [ h_visit_sum, Fin.sum_univ_castSucc ]

/-
The indicator sum over `succ` plus the first-vertex indicator equals the visit count.
-/
theorem sum_indicator_succ (v : Fin nV) :
    (∑ i : Fin nE, ind (t.vertices i.succ = v)) + ind (t.vertices 0 = v) =
    t.visitCount v := by
      unfold Bridges.EulerianTrail.visitCount Bridges.EulerianTrail.ind;
      rw [ Finset.card_filter, Fin.sum_univ_succ ];
      ring

/-
Reindexing the first endpoint sum through the edge permutation.
-/
theorem sum_perm_eq₁ (v : Fin nV) :
    (∑ e : Fin nE, ind (G.endpt₁ e = v)) =
    (∑ i : Fin nE, ind (G.endpt₁ (t.edgePerm i) = v)) :=
  (Fintype.sum_equiv t.edgePerm _ _ (congrFun rfl)).symm

/-
Reindexing the second endpoint sum through the edge permutation.
-/
theorem sum_perm_eq₂ (v : Fin nV) :
    (∑ e : Fin nE, ind (G.endpt₂ e = v)) =
    (∑ i : Fin nE, ind (G.endpt₂ (t.edgePerm i) = v)) :=
  (Fintype.sum_equiv t.edgePerm _ _ (congrFun rfl)).symm

/-
The degree equals the sum of endpoint indicators over all edges.
-/
theorem degree_eq_sum_ind (v : Fin nV) :
    G.degree v = ∑ e : Fin nE, ind (G.endpt₁ e = v) + ∑ e : Fin nE, ind (G.endpt₂ e = v) := by
  unfold Multigraph.degree; simp +decide [ ind ] ;

/-
**Degree–Visit Identity**: `degree(v) + [start=v] + [end=v] = 2·visits(v)`.
-/
theorem degree_visit_identity (v : Fin nV) :
    G.degree v + ind (t.startVertex = v) + ind (t.endVertex = v) =
    2 * t.visitCount v := by
      rw [ degree_eq_sum_ind, sum_perm_eq₁, sum_perm_eq₂ ];
      rw [ ← Finset.sum_add_distrib ];
      rw [ Finset.sum_congr rfl fun i hi => step_count_eq t v i ];
      rw [ Finset.sum_add_distrib, two_mul ];
      linarith! [ sum_indicator_castSucc t v, sum_indicator_succ t v ]

/-
Degree has the same parity as the endpoint indicator sum.
-/
theorem degree_parity (v : Fin nV) :
    G.degree v % 2 = (ind (t.startVertex = v) + ind (t.endVertex = v)) % 2 := by
      by_contra! h;
      exact h ( by have := t.degree_visit_identity v; omega )

end EulerianTrail

/-
**Euler's Parity Theorem**: At most 2 vertices have odd degree in a graph
with an Eulerian trail. This is the necessary condition first discovered
by Euler in 1736.
-/
theorem EulerianTrail.odd_degree_vertices_le_two
    {nV nE : ℕ} {G : Multigraph nV nE} (t : EulerianTrail G) :
    (Finset.univ.filter (fun v : Fin nV => G.degree v % 2 = 1)).card ≤ 2 := by
      -- By degree_parity, the set of vertices with an odd degree is a subset of {startVertex, endVertex}.
      have h_subset : {v | G.degree v % 2 = 1} ⊆ ({t.startVertex, t.endVertex} : Set (Fin nV)) := by
        intro v hv; have := t.degree_parity v; simp_all +decide [ Nat.add_mod ] ;
        unfold ind at hv; aesop;
      exact Finset.card_le_card ( show _ ⊆ { t.startVertex, t.endVertex } from fun x hx => by simpa using h_subset <| by simpa using hx ) |> le_trans <| Finset.card_insert_le _ _

end Bridges