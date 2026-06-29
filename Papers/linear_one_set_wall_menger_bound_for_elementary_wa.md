# Theorem Trace (internal anti-hallucination ledger)

Every result discussed in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to a named
declaration in the Phase A Lean output. No result is stated that does not appear
there. The two fully-given source files are
`Catalog/Novelty/WallMengerCore.lean` and
`Catalog/Novelty/WallMengerConnectivityBridge.lean`; the conjecture-level
declarations (`subwall_tiling`, `exists_clean_subwall`, `wall_menger_dichotomy`)
are referenced by the Phase A docstrings and future-directions text and live in
`Catalog/Novelty/WallMengerSubwall.lean`.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `exists_maximal_packing` | A finite family `F` of finsets over `V` admits a pairwise-disjoint subfamily `P ⊆ F` of maximum cardinality among all pairwise-disjoint subfamilies of `F`. | "The greedy heart" section | Def. of packing + Thm 1 |
| `packing_cover_duality` | If a finite family of nonempty finsets, each of size `≤ c`, has no `s` pairwise-disjoint members, then the union `X` of a maximal packing hits every member and `|X| ≤ c·(s−1)`. | "From packing to cover" | Thm 2 (main engine) |
| `wall_menger_separator_bound` | The `c = 4` specialisation of `packing_cover_duality`: the hitting set satisfies `|X| ≤ 4s − 4 = F(s)`. | "The number four" | Thm 3 (separator constant) |
| `kConnected_neighbor_packing` | In a `k`-connected finite simple graph, the neighbour singletons `{n}` for `n ∈ N(w)` form a pairwise-disjoint family of nonempty sets of cardinality `≥ k`. | "Connectivity always pays the packing toll" | Thm 4 (connectivity bridge) |
| `IsKConnected` (def, dependency) | `G` has `> k` vertices and deleting `< k` vertices keeps it connected. | mentioned | Definitions |
| `IsKConnected.le_ncard_neighborSet` (dependency, Whitney `κ ≤ δ`) | Every vertex of a `k`-connected graph has degree `≥ k`. | mentioned | used in Thm 4 |
| `wall_menger_dichotomy` (conjecture assembly) | The one-set dichotomy: small separator `X` (`|X| ≤ F(s)`) OR an `r`-subwall with `s` disjoint `A`–`W'` paths, when wall height `≥ T(s,r)=(8s+4)r`. | framing | Statement of conjecture |
| `subwall_tiling` / `exists_clean_subwall` (conjecture assembly) | A wall of height `(8s+4)r` tiles into many disjoint `r`-subwalls; pigeonhole leaves one untouched by separator and path endpoints. | framing | Subwall section |

Constants (from concept + Lean): `T(s,r) = (8s+4)·r`, `F(s) = 4s−4`,
per-member cost `c = 4` (nail wall-degree).
