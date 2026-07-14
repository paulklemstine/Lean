# Computational Evidence: AVD-total colourings of central graphs

## Small-case calculations

For the central graph `C(G)` of a graph `G` on `|V|` vertices:

* Every original vertex of `C(G)` has degree `|V| − 1` (each original vertex is
  joined either directly, to a non-neighbour, or through the subdivision vertex of
  a real edge, to a neighbour). Verified by `central_degree_inl`.
* Every subdivision vertex has degree `2`.

Consequently, for a non-complete `G` any non-adjacent pair `a, b` of `G` is an
adjacent pair of equal degree `|V| − 1` in `C(G)`.

| `G`            | `d` | `|V|` | degree bound `d+3` | order bound `|V|+1` |
|----------------|-----|-------|--------------------|---------------------|
| `C₅` (5-cycle) | 2   | 5     | 5                  | 6                   |
| `C₆`           | 2   | 6     | 5                  | 7                   |
| Petersen       | 3   | 10    | 6                  | 11                  |
| `K_{3,3}`      | 3   | 6     | 6                  | 7                   |

In every non-complete regular case the order bound `|V| + 1` strictly exceeds the
degree bound `d + 3` except when `|V| = d + 2` (the "near-complete" regular
graphs), confirming that `|V|`, not `d`, governs the invariant.

## Counterexample hunt

The mission conjecture `χ''ₐ(C(G)) = d + 3` was tested against the smallest
non-complete regular graph, the 5-cycle. Since `|V| = 5`, the order lower bound
forces `χ''ₐ(C(C₅)) ≥ 6 > 5 = d + 3`, so the conjectured equality is **false**.
This is captured formally in `cycle5_avd_ge_six`.

## Structural pattern

The single decisive fact is that all original vertices of `C(G)` are mutually of
maximum degree `|V| − 1`, and non-adjacency in `G` becomes adjacency in `C(G)`.
The equal-degree obstruction (`not_isAVD_of_adjacent_eqdeg`) then rules out any
palette of size `≤ |V|`, and palette-padding (`avd_coloring_castLE`) upgrades the
exact-`|V|` obstruction to all smaller sizes.

## Why this is sufficient

The claim proved is a universally quantified *lower bound*; a single family of
witnesses (regular non-complete graphs, with `C₅` explicit) suffices to
demonstrate strict separation from the degree bound, and the general proof is
uniform in `G`, so no exhaustive search is required.
