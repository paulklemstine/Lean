import Mathlib

/-!
# Degree degradation under deletion of a path's edges

This file isolates the *structural engine* behind connectivity-preserving
Hamiltonian-path theorems (Hasunuma 2025 and the `n ≥ 6k+6` prescribed-end
strengthening): deleting the edges of a path from a graph reduces **every**
vertex degree by at most `2`, because a path is a subgraph of maximum degree
`≤ 2`.

We work with `Set.ncard` of neighbor sets (the "degree" in a finite graph) so
that no `DecidableRel` / `Fintype (neighborSet)` bookkeeping is needed.

## Main results

* `path_subgraph_ncard_neighborSet_le_two` — every vertex has at most two
  neighbors inside the subgraph spanned by a path.
* `neighborSet_deleteEdges_path` — the neighbor set after deleting a path's
  edges is the original neighbor set minus the path-subgraph neighbors.
* `ncard_neighborSet_deleteEdges_path_ge` — **degree drops by at most `2`**:
  `deg_G(w) ≤ deg_{G - E(P)}(w) + 2` for every vertex `w`.
* `ncard_neighborSet_deleteEdges_ge_two_mul_succ` — **degree survival** under the
  `4k+4` / `⌈(n+1)/2⌉` hypotheses of the research conjecture: deleting any
  path's edges leaves minimum degree `≥ 2k+1`.
* `deleteEdges_path_min_degree_ge` — the *necessary* degree condition `δ ≥ k`
  for `k`-connectivity survives the deletion, with surplus `k+1`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the only reason a Hamiltonian path can be deleted
  while keeping high connectivity is that a path is "thin" — it costs each
  vertex at most two incident edges.  We conjectured `deg` drops by `≤ 2`
  uniformly, with equality exactly at internal vertices.
* Experiment (Experimenter): formalized the path subgraph `p.toSubgraph` and
  used the Mathlib neighbor-set computations
  (`IsPath.neighborSet_toSubgraph_internal/startpoint/endpoint`) to bound the
  spanned degree by `2`, then transported the bound through `deleteEdges` via
  `adj_toSubgraph_iff_mem_edges`.
* Analysis (Analyst): the `≤ 2` bound is tight (internal vertices reach `2`),
  so this is the exact, not merely asymptotic, degradation. It is the precise
  quantity that any connectivity-preserving deletion argument must control.
* Critique (Critic): the result needs `p.IsPath`, not merely a walk — a closed
  walk could revisit a vertex and remove more than two incident edges.  Guarded
  accordingly.  No finiteness of `V` is required for the subgraph bound; only
  `Set.Finite` of the neighbor set (automatic for `Fintype V`) is needed for the
  `ncard` arithmetic in the deletion theorem.
-- !-- end Lab Notes -- !--
-/

open SimpleGraph

namespace ConnPreservingHamPath

variable {V : Type*} {G : SimpleGraph V} {u v : V}

/-
Every vertex is incident to at most two edges of a path: the path subgraph
has maximum degree `≤ 2`.
-/
lemma path_subgraph_ncard_neighborSet_le_two
    (p : G.Walk u v) (hp : p.IsPath) (w : V) :
    (p.toSubgraph.neighborSet w).ncard ≤ 2 := by
  by_cases hw : w ∈ p.support;
  · -- Write `w = p.getVert i` with `i ≤ p.length` (use `SimpleGraph.Walk.mem_support_iff_exists_getVert` or `getVert` enumeration of support).
    obtain ⟨i, hi⟩ : ∃ i : ℕ, i ≤ p.length ∧ w = p.getVert i := by
      rw [ SimpleGraph.Walk.mem_support_iff_exists_getVert ] at hw ; tauto;
    by_cases hi0 : i = 0 <;> by_cases hilength : i = p.length;
    · cases p <;> simp_all +decide;
    · by_cases hnp : p.Nil <;> simp_all +decide [ SimpleGraph.Walk.IsPath.neighborSet_toSubgraph_startpoint ];
      cases p <;> aesop;
    · by_cases hnp : p.Nil <;> simp_all +decide [ SimpleGraph.Walk.IsPath.neighborSet_toSubgraph_endpoint ];
      cases p <;> aesop;
    · rw [ hi.2, SimpleGraph.Walk.IsPath.ncard_neighborSet_toSubgraph_internal_eq_two hp ( by omega ) ( by omega ) ];
  · rw [ show p.toSubgraph.neighborSet w = ∅ from _ ] ; norm_num;
    simp +decide [ Set.eq_empty_iff_forall_notMem ];
    intro x hx; have := hx.fst_mem; aesop;

/-
Deleting the edges of `p` removes exactly the path-subgraph neighbors.
-/
lemma neighborSet_deleteEdges_path (p : G.Walk u v) (w : V) :
    (G.deleteEdges {e | e ∈ p.edges}).neighborSet w
      = G.neighborSet w \ p.toSubgraph.neighborSet w := by
  ext x; simp +decide [ SimpleGraph.Walk.adj_toSubgraph_iff_mem_edges ] ;

/-
**Degree degradation engine.**  Deleting the edges of a path from `G`
reduces the degree of every vertex by at most `2`.
-/
theorem ncard_neighborSet_deleteEdges_path_ge
    [Fintype V] (p : G.Walk u v) (hp : p.IsPath) (w : V) :
    (G.neighborSet w).ncard
      ≤ ((G.deleteEdges {e | e ∈ p.edges}).neighborSet w).ncard + 2 := by
  -- Rewrite the deleted neighbor set using `neighborSet_deleteEdges_path`: it equals `G.neighborSet w \ p.toSubgraph.neighborSet w`.
  have h_delete : (G.neighborSet w).ncard ≤ ((G.neighborSet w) \ (p.toSubgraph.neighborSet w)).ncard + (p.toSubgraph.neighborSet w).ncard := by
    rw [ ← Set.ncard_union_eq ];
    · exact Set.ncard_le_ncard fun x hx => by by_cases hx' : x ∈ p.toSubgraph.neighborSet w <;> aesop;
    · exact disjoint_sdiff_self_left;
  exact h_delete.trans ( add_le_add ( by rw [ neighborSet_deleteEdges_path ] ) ( path_subgraph_ncard_neighborSet_le_two p hp w ) )

/-!
## Degree survival under the `4k+4` / `⌈(n+1)/2⌉` hypotheses

Here `⌈(n+1)/2⌉` is written in `ℕ` as `(n+2)/2`, which equals `⌈(n+1)/2⌉` for all
`n` (check both parities).

-- !-- Lab Notes (continued) -- !--
* Hypothesis (Hypothesizer): the `6k+6 → 4k+4` improvement should not break the
  degree bookkeeping; the degree threshold alone should leave large slack after
  deletion.  We conjectured the deleted graph keeps minimum degree `≥ 2k+1`.
* Experiment (Experimenter): combined the at-most-`2` degree drop with
  `(n+2)/2 ≥ 2k+3` (from `n ≥ 4k+4`), closed by `omega` (which reasons about `ℕ`
  division by the literal `2`).
* Analysis (Analyst): the surviving degree `2k+1` is far above the *necessary*
  threshold `k`; the surplus `k+1` shows the degree count is NOT the obstruction
  to the `4k+4` conjecture.  The genuine difficulty is purely the *connectivity*
  (cut structure) of the deleted graph — the converse Whitney direction `δ ⇒ κ`,
  which Mathlib lacks.  This isolates *where* the `4k+4` problem is hard.
* Critique (Critic): these are necessary, not sufficient, conditions; they do
  not prove the conjecture.  The hypothesis `2 ≤ k` is unnecessary for degree
  survival and is therefore dropped here (it belongs only to the conjecture
  statement `Conjecture_4k4`).
-- !-- end Lab Notes -- !--
-/

/-- **Degree survival.**  Under the conjecture's order bound `n ≥ 4k+4` and degree
threshold `δ(G) ≥ ⌈(n+1)/2⌉ = (n+2)/2`, deleting the edges of any path leaves
every vertex with degree at least `2k+1`. -/
theorem ncard_neighborSet_deleteEdges_ge_two_mul_succ
    [Fintype V] {k : ℕ}
    (hn : 4 * k + 4 ≤ Fintype.card V)
    (hdeg : ∀ x, (Fintype.card V + 2) / 2 ≤ (G.neighborSet x).ncard)
    (p : G.Walk u v) (hp : p.IsPath) (w : V) :
    2 * k + 1 ≤ ((G.deleteEdges {e | e ∈ p.edges}).neighborSet w).ncard := by
  have hengine := ncard_neighborSet_deleteEdges_path_ge p hp w
  have hd := hdeg w
  omega

/-- The *necessary* degree condition `δ ≥ k` for `k`-connectivity survives the
deletion, with surplus `k + 1`. -/
theorem deleteEdges_path_min_degree_ge
    [Fintype V] {k : ℕ}
    (hn : 4 * k + 4 ≤ Fintype.card V)
    (hdeg : ∀ x, (Fintype.card V + 2) / 2 ≤ (G.neighborSet x).ncard)
    (p : G.Walk u v) (hp : p.IsPath) (w : V) :
    k + 1 ≤ ((G.deleteEdges {e | e ∈ p.edges}).neighborSet w).ncard := by
  have := ncard_neighborSet_deleteEdges_ge_two_mul_succ hn hdeg p hp w
  omega

end ConnPreservingHamPath