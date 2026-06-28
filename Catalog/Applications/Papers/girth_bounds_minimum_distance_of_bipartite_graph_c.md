# Theorem Trace — Girth bounds minimum distance of bipartite graph codes

Source of truth: `Catalog/Novelty/BipartiteGraphCodeGirth.lean` (Phase A output).
This internal file lists every Lean declaration, its mathematical content, and
where it is referenced in `ARTICLE.md` and `RESEARCH_PAPER.md`. No theorem below
is paraphrased into a grander claim; the prose states exactly these results.

## Definitions

| Lean name | Mathematical meaning | In ARTICLE | In PAPER |
|---|---|---|---|
| `biGraph` | The simple bipartite graph on `L ⊕ R` whose adjacency is the incidence relation `inc : L → R → Prop` (left vertex `l` ~ right vertex `r` iff `inc l r`). | yes ("the wiring diagram") | Def. 1 |
| `restrictGraph` | The subgraph of `biGraph inc` keeping only edges incident to a left vertex in a chosen finite set `S ⊆ L`. | yes ("zoom in on S") | Def. 3 |
| `B(G)` (code) | Binary linear code: a codeword is a finite set `S` of left vertices such that every right vertex has an **even** number of neighbours in `S`. | yes | Def. 2 |

## Lemmas (infrastructure)

| Lean name | Statement | In PAPER |
|---|---|---|
| `instDecBi`, `instDecRestrict` | Decidability of the adjacency relations. | (mentioned: computability) |
| `restrictGraph_le` | `restrictGraph inc S ≤ biGraph inc` (it is a subgraph). | Lemma 4 |
| `restrictGraph_adj_inl_inr` | Adjacency unfolding: `Adj (inl l) (inr r) ↔ inc l r ∧ l ∈ S`. | Lemma 4 |
| `restrict_neighborFinset_inl` | Neighbours of `l ∈ S` are its right-neighbours. | Lemma 4 |
| `restrict_neighborFinset_inr` | Neighbours of `r` are its left-neighbours lying in `S`. | Lemma 4 |
| `restrict_degree_inl_mem` | `deg(inl l) = #{r : inc l r}` for `l ∈ S` (= `d` when left-`d`-regular). | Lemma 5 |
| `restrict_degree_inl_not_mem` | `deg(inl l) = 0` for `l ∉ S`. | Lemma 5 |
| `restrict_degree_inr` | `deg(inr r) = #{l ∈ S : inc l r}` (parity controlled by codeword condition). | Lemma 5 |

## Main graph-theoretic lemmas

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `exists_isCycle_of_no_degree_one` | A finite simple graph with at least one edge and **no vertex of degree one** contains a cycle. | yes ("no dead ends ⇒ a loop") | Lemma 6 |
| `isCycle_length_le_two_mul_card_left` | A cycle of the bipartite graph has length at most twice the number of distinct left vertices it visits. | yes ("a loop alternates sides") | Lemma 7 |

## Main theorem

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `girth_bounds_min_distance` | For a simple left-`d`-regular bipartite graph with `d ≥ 2` and `egirth ≥ 2k+2`, every non-empty codeword of `B(G)` has size `≥ k+1`; i.e. the minimum distance of `B(G)` is at least `k+1`. | yes (main result; Fano & K_{2,3} examples) | Theorem 8 |

Note on examples (verified numerically in `demo.py`): the Fano incidence graph (`d=3`, girth `6`) gives bound `≥ 3` with actual `d_min = 4` (no odd-weight codewords), so it is **not** a tightness witness; the complete bipartite graph `K_{2,3}` (`d=3`, girth `4`) meets the bound with equality (`d_min = 2`). The prose was corrected accordingly; do not claim Fano distance `= 3`.

Proof chain (as packaged by `girth_bounds_min_distance`):
`2k+2 ≤ egirth(G) ≤ length(cycle) ≤ 2·#left ≤ 2|S|`, hence `k+1 ≤ |S|`.
