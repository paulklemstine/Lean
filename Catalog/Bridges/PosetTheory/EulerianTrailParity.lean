import Mathlib

/-!
# Eulerian trails imply at most two odd-degree vertices

This file is a minimal, self-contained formalization of the classical parity
theorem for Eulerian trails on finite multigraphs.

A finite multigraph is encoded by an endpoint map `ends : Fin nE → Fin nV × Fin nV`,
sending each edge index to an *ordered* pair of vertices.  The `degree` of a vertex
is the number of edge endpoints incident to it: each edge contributes `1` for each
of its two endpoints equal to `v`, so a loop at `v` contributes `2`.

An `EulerianTrail` is a walk that uses every edge exactly once: a vertex sequence
`walk : Fin (nE+1) → Fin nV` together with a permutation `edgeAt` of the edges such
that the `i`-th step of the walk traverses edge `edgeAt i` (in either orientation).

The main results are:

* `degree_eq_walk_sum` — the degree of `v` is the sum over walk steps of the number
  of the two consecutive walk positions equal to `v`;
* `degree_add_endpoints` — a telescoping/endpoint-correction identity:
  `degree v + (start-indicator + end-indicator) = 2 * (number of walk positions = v)`;
* `even_degree_of_internal` — a vertex that is neither the start nor the end of the
  trail has even degree;
* `odd_degree_mem_endpoints` — an odd-degree vertex must be the start or the end;
* `odd_degree_vertices_le_two` — there are at most two odd-degree vertices.
-/

namespace EulerianTrailParity

open Finset

/-- A finite multigraph on `nV` vertices and `nE` edges, encoded by an endpoint map
sending each edge to an ordered pair of vertices. -/
structure Multigraph (nV nE : ℕ) where
  /-- The ordered pair of endpoints of each edge. -/
  ends : Fin nE → Fin nV × Fin nV

variable {nV nE : ℕ}

/-- The degree of a vertex `v`: the number of edge endpoints equal to `v`.
Each edge contributes the sum of two indicators (one per endpoint), so a loop at `v`
contributes `2`. -/
def degree (G : Multigraph nV nE) (v : Fin nV) : ℕ :=
  ∑ e : Fin nE,
    ((if (G.ends e).1 = v then 1 else 0) + (if (G.ends e).2 = v then 1 else 0))

/-- An Eulerian trail of `G`: a vertex sequence `walk` together with a permutation
`edgeAt` of the edges, such that the `i`-th step traverses edge `edgeAt i` between the
consecutive walk vertices (in either orientation). -/
structure EulerianTrail (G : Multigraph nV nE) where
  /-- The sequence of `nE + 1` vertices visited by the trail. -/
  walk : Fin (nE + 1) → Fin nV
  /-- The order in which the edges are traversed. -/
  edgeAt : Equiv.Perm (Fin nE)
  /-- The `i`-th step traverses edge `edgeAt i` between `walk i` and `walk (i+1)`. -/
  compat : ∀ i : Fin nE,
    G.ends (edgeAt i) = (walk i.castSucc, walk i.succ) ∨
    G.ends (edgeAt i) = (walk i.succ, walk i.castSucc)

/-
**Degree/incidence identity (A).** The degree of `v` equals the sum, over walk
steps, of the number of the two consecutive walk positions equal to `v`.
-/
theorem degree_eq_walk_sum (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV) :
    degree G v =
      ∑ i : Fin nE,
        ((if et.walk i.castSucc = v then 1 else 0) +
         (if et.walk i.succ = v then 1 else 0)) := by
  unfold degree;
  rw [ ← Equiv.sum_comp et.edgeAt ];
  grind +suggestions

/-
**Endpoint-correction identity.** Adding the start and end indicators to the degree
yields twice the number of walk positions equal to `v`.
-/
theorem degree_add_endpoints (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV) :
    degree G v +
        ((if et.walk 0 = v then 1 else 0) +
         (if et.walk (Fin.last nE) = v then 1 else 0))
      = 2 * ∑ j : Fin (nE + 1), (if et.walk j = v then 1 else 0) := by
  convert congr_arg₂ ( · + · ) ( degree_eq_walk_sum G et v ) rfl using 1;
  have := Fin.sum_univ_castSucc ( fun j => if et.walk j = v then 1 else 0 ) ; have := Fin.sum_univ_succ ( fun j => if et.walk j = v then 1 else 0 ) ; simp_all +decide [ two_mul, Finset.sum_add_distrib ] ;
  grind

/-
**(B)** A vertex that is neither the start nor the end of the trail has even degree.
-/
theorem even_degree_of_internal (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV)
    (h0 : v ≠ et.walk 0) (hlast : v ≠ et.walk (Fin.last nE)) : Even (degree G v) := by
  have := degree_add_endpoints G et v;
  grind

/-
**(C)** Any odd-degree vertex must be the start or the end of the trail.
-/
theorem odd_degree_mem_endpoints (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV)
    (h : Odd (degree G v)) : v = et.walk 0 ∨ v = et.walk (Fin.last nE) := by
  grind +suggestions

/-
**(D)** The set of odd-degree vertices has cardinality at most `2`.
-/
theorem odd_degree_vertices_le_two (G : Multigraph nV nE) (et : EulerianTrail G) :
    (Finset.univ.filter (fun v => Odd (degree G v))).card ≤ 2 := by
  exact le_trans ( Finset.card_le_card fun x hx => show x ∈ { et.walk 0, et.walk ( Fin.last nE ) } from by have := odd_degree_mem_endpoints G et x ( by aesop ) ; aesop ) ( Finset.card_insert_le _ _ ) |> le_trans <| by norm_num;

end EulerianTrailParity