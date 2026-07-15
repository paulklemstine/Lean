# Computational Evidence

## Small-case calculations

For one witness face with `r` vertices, its canonical downward-closed certificate is its powerset and has the following face counts:

| `r` | certificate faces `2^r` |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |

For the complete width-two skeleton on `n` vertices, the face count is `1 + n + C(n,2)`:

| `n` | face count | tree benchmark `2n` |
|---:|---:|---:|
| 1 | 2 | 2 |
| 2 | 4 | 4 |
| 3 | 7 | 6 |
| 4 | 11 | 8 |
| 5 | 16 | 10 |

The `n = 4` row is formalized as `width_two_tree_count_conjecture_false`.

## OEIS search

The powerset counts are the standard powers-of-two sequence `1, 2, 4, 8, 16, 32, …` (OEIS A000079). The width-two skeleton counts `1, 2, 4, 7, 11, 16, …` are the central polygonal numbers (OEIS A000124, with indexing beginning at `n = 0`).

## Counterexample hunt

The proposed universal tree-count extrapolation already fails at `n = 3`: the complete width-two skeleton has seven faces rather than six. The formal development records the clearer `n = 4` instance, eleven rather than eight.

No counterexample exists to the proved `q·2^m` bound: the proof bounds a finite union by the sum of the cardinalities of its constituent powersets and is fully checked in Lean.

## Interpretation

The calculations separate two phenomena. Width alone allows quadratically many width-two faces as the ambient set grows. In contrast, fixing the actual number and width of designated witness faces gives a certificate bound independent of ambient size.
