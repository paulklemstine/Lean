# Computational Evidence

## Small-case calculations

For the friendship graph with `n` triangles, the closed formula is

`P(F_n,q) = q ((q-1)(q-2))^n`.

| `n` | vertices | `P(F_n,2)` | `P(F_n,3)` | `P(F_n,6)` |
|---:|---:|---:|---:|---:|
| 0 | 1 | 2 | 3 | 6 |
| 1 | 3 | 0 | 6 | 120 |
| 2 | 5 | 0 | 12 | 2400 |
| 3 | 7 | 0 | 24 | 48000 |
| 4 | 9 | 0 | 48 | 960000 |

For every `n ≥ 1`, the first positive palette size is three. Under the imposed three-category emotional floor, the same conclusion also holds for `n = 0`.

A one-edge graph supplies the smallest counterexample to the proposed universal bipartite root at two: it has two proper two-colorings, obtained by exchanging the two colors between its endpoints.

## Sequence search

At the minimum admissible palette the friendship counts begin `3, 6, 12, 24, 48`, a geometric sequence. At six colors they begin `6, 120, 2400, 48000, 960000`, also geometric. No OEIS identifier is needed for these elementary geometric sequences.

## Counterexample hunt

The universal statement “every bipartite graph has chromatic value zero at two” fails immediately for a single edge. The corrected behavior is the opposite for any two-colorable graph: existence of a proper two-coloring makes the value at two positive. The emotional floor must therefore be imposed as a modeling constraint rather than deduced as a polynomial root.

## Structural comparison

The ratio `P(F_n,6) / P(F_n,3)` equals `2 · 10^n`. Each additional triangle doubles the number of assignments at the minimum palette but multiplies the six-palette count by twenty. This motivates comparing the ratio under other patterns of gluing triangles.
