# Computational Evidence

## Small-case calculations

The proof targets are structural rather than census-specific. For the cycle Cayley graph of the additive group of order five with connection set `{+1,-1}`, each vertex has two neighbours. Adjacent pairs have no common neighbour, while vertices at distance two have one common neighbour. Translating both roots preserves these values, in agreement with dependence on the group difference.

For the complete Cayley graph on a group of order four, obtained from all nonidentity elements, every vertex has degree three and every distinct pair has two common neighbours. Again, the profile is constant on every nonidentity difference.

## OEIS search results

No sequence identification is required for the theorem proved here. The arXiv signal about newly contributed generator-rank and monolithic-group sequences motivated using exact symmetry principles rather than asserting unverified sequence IDs or finite census totals.

## Counterexample hunt and boundary cases

The claims require an inverse-closed connection set not containing the identity, exactly the hypotheses needed for a simple undirected Cayley graph. Dropping inverse closure can produce a directed relation rather than a simple graph. Including the identity creates loops. Neither altered object is covered by the theorem.

Regularity alone is insufficient for the pair-difference conclusion: a regular graph has no canonical multiplication or coherent difference coordinate. Vertex-transitive non-Cayley graphs preserve local data along automorphism orbits, but need not admit the sharply transitive translations used in the proof.

## Evidence table

| Group / connection set | degree | common-neighbour profile by difference | expected invariance |
|---|---:|---|---|
| cyclic order 5, `{±1}` | 2 | 0 for `±1`, 1 for `±2` | yes |
| order 4, all nonidentity elements | 3 | 2 for every nonidentity difference | yes |
| arbitrary finite group, inverse-closed `S` | `|S|` | `|S ∩ gS|` up to orientation convention | yes |

The deliverable establishes the underlying bijections directly, so these small cases are illustrations rather than the basis of the result.
