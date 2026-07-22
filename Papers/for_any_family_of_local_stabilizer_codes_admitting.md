# Computational evidence: Singleton defect bounds

The formal results concern consequences of the quantum Singleton inequality
`k + 2(d - 1) ≤ n`. Because the proof is symbolic linear arithmetic, exhaustive
finite testing is not needed for validity, but small cases clarify the endpoint
correction.

| `n` | `d` | largest allowed `k` | geometric defect `n-2d` | exact defect `n+2-2d` |
|---:|---:|---:|---:|---:|
| 5 | 3 | 1 | -1 | 1 |
| 7 | 3 | 3 | 1 | 3 |
| 10 | 4 | 4 | 2 | 4 |
| 12 | 6 | 2 | 0 | 2 |
| 20 | 9 | 4 | 2 | 4 |

These examples show that the raw quantity `n-2d` is not itself always an upper
bound for `k`; the exact finite-length budget is `n+2-2d`. Their densities differ
by `2/n`, which vanishes for diverging block length.

## Counterexample hunt

The naive finite claim `k ≤ n-2d` fails for the admissible parameters
`[[5,1,3]]`: `1 ≤ -1` is false. This motivates the corrected exact theorem.
For every integer triple in the displayed sample satisfying Singleton, the
corrected inequality `k ≤ n+2-2d` holds, with equality when `k` is chosen maximal.
No claim about existence of a code for every admissible parameter triple is made.

## Sequence/OEIS and plots

No new integer sequence is central here, so an OEIS search would not be
informative. The relevant dependence is affine: at fixed `d`, maximal `k` has
slope one in `n`; after normalization, the endpoint discrepancy is the elementary
curve `2/n`. A separate plot would add little beyond the table.
