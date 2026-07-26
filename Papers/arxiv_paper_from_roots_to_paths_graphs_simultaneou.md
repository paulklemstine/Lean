# Computational evidence: rooted and ordinary three-vertex paths

## Small-case calculations

For the six-vertex graph with edge set

\[
\{02,03,05,12,14,23\},
\]

the Lean definitions compute the following per-vertex statistics:

| vertex | degree | central-rooted `P₃` count | end-rooted `P₃` count | ordinary `P₃` count |
|---:|---:|---:|---:|---:|
| 0 | 3 | 3 | 3 | 6 |
| 1 | 2 | 1 | 2 | 3 |
| 2 | 3 | 3 | 4 | 7 |
| 3 | 2 | 1 | 4 | 5 |
| 4 | 1 | 0 | 1 | 1 |
| 5 | 1 | 0 | 2 | 2 |

Thus all ordinary counts are distinct, whereas the end-rooted counts collide at
vertices 2 and 3 (and also at 1 and 5). The central-rooted counts exhibit the
expected collisions forced by equal degrees.

## OEIS search

No sequence arises in the selected finite-graph obstruction or counterexample,
so an OEIS search is not applicable.

## Counterexample hunt

The graph above is a certified counterexample to the plausible implication
“ordinary `P₃`-irregular implies end-rooted `P₃`-irregular.” The finite
calculations are encoded and kernel-checked in
`Catalog/Logic/RootedPathIrregularity/Contrarian.lean`.

The universal negative central-root claim does not rely on finite search: it is
proved from the theorem that every finite simple graph on at least two vertices
has two vertices of equal degree.
