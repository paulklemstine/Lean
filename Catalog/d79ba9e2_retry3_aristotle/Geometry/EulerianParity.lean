/-
# Eulerian trails: the classical parity theorem

A small, self-contained development of the parity (handshake-style) theorem for
Eulerian trails in finite undirected multigraphs **with loops**.

## Model

* `Multigraph nV nE` is a finite multigraph on vertex set `Fin nV` with edge set
  `Fin nE`, given by two endpoint maps `endpt₁ endpt₂ : Fin nE → Fin nV`.
  A loop is an edge `e` with `endpt₁ e = endpt₂ e`.

* `degree G v` counts endpoint incidences at `v`, summing over **both** endpoint
  slots; hence a loop at `v` contributes `2`.

* `Trail G` is an Eulerian trail: a vertex walk `verts : Fin (nE+1) → Fin nV`
  together with a permutation `edgePerm` of the edges (so every edge is used
  exactly once) and a proof `adj` that the `i`-th step traverses edge
  `edgePerm i` between `verts i.castSucc` and `verts i.succ`, in either
  orientation.

## Main results

1. `Trail.parity_identity` — the local counting identity at every vertex `v`:
   `degree G v + startIndicator v + endIndicator v = 2 * visitCount v`.
   The proof is pure finite counting: each internal visit contributes two
   incidences, each endpoint one.

2. `Trail.odd_degree_isEndpoint` — if `Odd (degree G v)` then `v` is the start
   or the end vertex of the trail.

3. `Trail.card_oddDegree_le_two` — at most two vertices have odd degree.

4. `Trail.closed_even_degree` — if the trail is closed (start = end) then every
   vertex has even degree.
-/
import Mathlib

namespace EulerianParity

open Finset

/-- A finite undirected multigraph with loops: vertices `Fin nV`, edges `Fin nE`,
and two endpoint maps. -/
structure Multigraph (nV nE : ℕ) where
  endpt₁ : Fin nE → Fin nV
  endpt₂ : Fin nE → Fin nV

variable {nV nE : ℕ}

/-- The degree of `v`: the number of endpoint incidences equal to `v`, counting
both endpoint slots. A loop at `v` contributes `2`. -/
def degree (G : Multigraph nV nE) (v : Fin nV) : ℕ :=
  (univ.filter (fun e => G.endpt₁ e = v)).card +
  (univ.filter (fun e => G.endpt₂ e = v)).card

/-- An Eulerian trail: a vertex walk using every edge exactly once. -/
structure Trail (G : Multigraph nV nE) where
  /-- The walk of `nE + 1` vertices. -/
  verts : Fin (nE + 1) → Fin nV
  /-- The order in which the edges are traversed (each edge exactly once). -/
  edgePerm : Equiv.Perm (Fin nE)
  /-- Step `i` traverses edge `edgePerm i` between consecutive walk vertices,
  in either orientation. -/
  adj : ∀ i : Fin nE,
      (G.endpt₁ (edgePerm i) = verts i.castSucc ∧ G.endpt₂ (edgePerm i) = verts i.succ) ∨
      (G.endpt₁ (edgePerm i) = verts i.succ ∧ G.endpt₂ (edgePerm i) = verts i.castSucc)

namespace Trail

variable {G : Multigraph nV nE}

/-- The starting vertex of the trail. -/
def start (T : Trail G) : Fin nV := T.verts 0

/-- The ending vertex of the trail. -/
def last (T : Trail G) : Fin nV := T.verts (Fin.last nE)

/-- The number of times the walk visits `v` (over all `nE + 1` positions). -/
def visitCount (T : Trail G) (v : Fin nV) : ℕ :=
  ∑ j : Fin (nE + 1), (if T.verts j = v then 1 else 0)

/-- `1` if `v` is the start vertex, else `0`. -/
def startIndicator (T : Trail G) (v : Fin nV) : ℕ :=
  if T.verts 0 = v then 1 else 0

/-- `1` if `v` is the end vertex, else `0`. -/
def endIndicator (T : Trail G) (v : Fin nV) : ℕ :=
  if T.verts (Fin.last nE) = v then 1 else 0

/-- Count of steps whose *first* (castSucc) walk vertex equals `v`. -/
def castCount (T : Trail G) (v : Fin nV) : ℕ :=
  ∑ i : Fin nE, (if T.verts i.castSucc = v then 1 else 0)

/-- Count of steps whose *second* (succ) walk vertex equals `v`. -/
def succCount (T : Trail G) (v : Fin nV) : ℕ :=
  ∑ i : Fin nE, (if T.verts i.succ = v then 1 else 0)

variable (T : Trail G) (v : Fin nV)

/-
Splitting the walk at its last vertex.
-/
lemma visit_eq_cast_add_end : T.visitCount v = T.castCount v + T.endIndicator v := by
  unfold Trail.visitCount Trail.castCount Trail.endIndicator; rw [ Fin.sum_univ_castSucc ] ;

/-
Splitting the walk at its first vertex.
-/
lemma visit_eq_start_add_succ : T.visitCount v = T.startIndicator v + T.succCount v := by
  convert Fin.sum_univ_succ _

/-
The degree of `v` equals the number of consecutive walk pairs incident to
`v` (first slot plus second slot). This is where the edge permutation and the
adjacency condition are used.
-/
lemma degree_eq_cast_add_succ : degree G v = T.castCount v + T.succCount v := by
  -- By definition of degree, we can express it as the sum over the edges of the number of times the vertex appears as an endpoint.
  have h_deg : degree G v = ∑ e : Fin nE, (if G.endpt₁ e = v then 1 else 0) + ∑ e : Fin nE, (if G.endpt₂ e = v then 1 else 0) := by
    unfold degree; aesop;
  have h_perm : ∀ e : Fin nE, (if G.endpt₁ (T.edgePerm e) = v then 1 else 0) + (if G.endpt₂ (T.edgePerm e) = v then 1 else 0) = (if T.verts e.castSucc = v then 1 else 0) + (if T.verts e.succ = v then 1 else 0) := by
    intro e; rcases T.adj e with h|h <;> simp +decide [ h ] ;
    ring;
  convert Finset.sum_congr rfl fun e _ => h_perm e using 1;
  any_goals exact Finset.univ;
  · convert h_deg using 1;
    rw [ Finset.sum_add_distrib, Equiv.sum_comp T.edgePerm fun e => if G.endpt₁ e = v then 1 else 0, Equiv.sum_comp T.edgePerm fun e => if G.endpt₂ e = v then 1 else 0 ];
  · unfold Trail.castCount Trail.succCount; simp +decide [ Finset.sum_add_distrib ] ;

/-- **Local parity identity.** At every vertex `v`:
`degree G v + startIndicator v + endIndicator v = 2 * visitCount v`. -/
theorem parity_identity :
    degree G v + T.startIndicator v + T.endIndicator v = 2 * T.visitCount v := by
  have hd := T.degree_eq_cast_add_succ v
  have h1 := T.visit_eq_cast_add_end v
  have h2 := T.visit_eq_start_add_succ v
  omega

/-- If `v` has odd degree, then it is the start or the end vertex of the trail. -/
theorem odd_degree_isEndpoint (h : Odd (degree G v)) :
    v = T.start ∨ v = T.last := by
  obtain ⟨ k, hk ⟩ := h;
  have := parity_identity T v; simp_all +decide [ Nat.even_iff ];
  unfold Trail.startIndicator Trail.endIndicator at this;
  unfold Trail.start Trail.last; split_ifs at this <;> omega;

/-- The set of odd-degree vertices has cardinality at most `2` (the existence of
the Eulerian trail `T` is essential). -/
theorem card_oddDegree_le_two (T : Trail G) :
    (univ.filter (fun v => Odd (degree G v))).card ≤ 2 := by
  exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun v => Odd ( degree G v ) ) Finset.univ ⊆ { T.start, T.last } from fun v hv => by have := odd_degree_isEndpoint ( T := T ) ( v := v ) ( Finset.mem_filter.mp hv |>.2 ) ; aesop ) ) ( Finset.card_insert_le _ _ )

/-- If the trail is closed (start equals end), every vertex has even degree. -/
theorem closed_even_degree (hclosed : T.start = T.last) (v : Fin nV) :
    Even (degree G v) := by
  have hid := T.parity_identity v;
  grind +locals

end Trail

end EulerianParity