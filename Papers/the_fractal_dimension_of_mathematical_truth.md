# Computational evidence

The finite calculations are machine-checked in `Bridges/TruthFractalEvidence.lean`.

| `n` | admissible paired prefixes `2^n` | ambient prefixes at length `2n`, `2^(2n)` | square identity |
|---:|---:|---:|:---:|
| 0 | 1 | 1 | `1² = 1` |
| 1 | 2 | 4 | `2² = 4` |
| 2 | 4 | 16 | `4² = 16` |
| 3 | 8 | 64 | `8² = 64` |
| 4 | 16 | 256 | `16² = 256` |
| 5 | 32 | 1024 | `32² = 1024` |

## Sequence search

The columns are the elementary geometric sequences `2^n` and `4^n`; no OEIS lookup is needed to identify them.

## Counterexample hunt

`small_case_counterexample_hunt` checks every `n < 6`. No counterexample exists at any scale because `pairedTruth_exact_half_dimension` proves the identity for every natural number `n`.

## Interpretation

Taking base-2 logarithms, the admissible count has logarithm `n`, while the ambient count at length `2n` has logarithm `2n`. Their ratio is therefore `1/2` at every positive tested scale, matching the general exact theorem.
