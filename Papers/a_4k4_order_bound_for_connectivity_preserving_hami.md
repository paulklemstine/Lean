# Theorem Trace (internal anti-hallucination record)

This file lists every theorem, lemma, and definition appearing in the Phase A
Lean output, together with its mathematical statement and where it is referenced
in `ARTICLE.md` and `RESEARCH_PAPER.md`. No result outside this list is claimed
anywhere in the package.

## Source file: `Catalog/Novelty/ConnPreservingHamPath/Connectivity.lean`

| Lean name | Kind | Mathematical statement | Article | Paper |
|---|---|---|---|---|
| `IsKConnected` | def | `G` has `k < |V|` and deleting any `S` with `|S| < k` leaves `G.induce (Sᶜ)` connected. | §"What 'staying connected' means" | Def. 2.1 |
| `Connected.exists_adj_of_ne` | lemma | In a connected graph with two distinct vertices, every vertex has a neighbor (no isolated vertices). | §"No vertex is an island" | Lemma 2.2 |
| `IsKConnected.le_ncard_neighborSet` | theorem | If `IsKConnected G k` then for every vertex `w`, `k ≤ |N(w)|` (Whitney's easy bound `κ ≤ δ`). | §"The price of connectivity" | Thm. 2.3 |
| `Conjecture_4k4` | def (Prop) | For `k ≥ 2`, `|V| ≥ 4k+4`, `G` `k`-connected, `δ(G) ≥ ⌈(n+1)/2⌉`: for all distinct `u,v` there is a Hamiltonian `u`–`v` path whose edge-deletion stays `k`-connected. | §"The conjecture" | Conj. 4.1 |

## Source file: `Catalog/Novelty/ConnPreservingHamPath/PathDegree.lean`

| Lean name | Kind | Mathematical statement | Article | Paper |
|---|---|---|---|---|
| `path_subgraph_ncard_neighborSet_le_two` | theorem | Every vertex has at most two neighbors inside the subgraph spanned by a path. | §"Why a path is thin" | Thm. 3.1 |
| `neighborSet_deleteEdges_path` | theorem | After deleting a path's edges, `N_{G-E(P)}(w) = N_G(w) \ N_{P}(w)`. | §"Why a path is thin" | Lemma 3.2 |
| `ncard_neighborSet_deleteEdges_path_ge` | theorem | `deg_G(w) ≤ deg_{G-E(P)}(w) + 2` (degree drops by at most 2). | §"Why a path is thin" | Thm. 3.3 |
| `ncard_neighborSet_deleteEdges_ge_two_mul_succ` | theorem | Under the `4k+4` / `⌈(n+1)/2⌉` hypotheses, deleting any path's edges leaves min degree `≥ 2k+1`. | §"Degrees survive easily" | Thm. 3.4 |
| `deleteEdges_path_min_degree_ge` | theorem | The necessary degree condition `δ ≥ k` survives deletion, with surplus `k+1`. | §"Degrees survive easily" | Cor. 3.5 |

## Notes
- The `4k+4` statement (`Conjecture_4k4`) is **open**: stated as a `Prop`, not proved.
- All degree results (`PathDegree.lean`) are fully proved and unconditional given `p.IsPath`.
- `IsKConnected.le_ncard_neighborSet` is the *easy* (necessary) half of Whitney's
  inequality `κ ≤ δ`; the converse is explicitly NOT claimed.
