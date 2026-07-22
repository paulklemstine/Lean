# Computational evidence

## Small-case calculations

For preparation cost `p = 1`, the formal model gives

| candidates `n` | molecular time `n + 1` | sequential time `2n` | sequential / molecular |
|---:|---:|---:|---:|
| 1 | 2 | 2 | 1.000 |
| 2 | 3 | 4 | 1.333 |
| 4 | 5 | 8 | 1.600 |
| 8 | 9 | 16 | 1.778 |
| 16 | 17 | 32 | 1.882 |
| 1024 | 1025 | 2048 | 1.998 |

The first four rows are certified in Lean by `preparation_cost_small_cases`; the general factor-two bound, including the `n = 2^10` instance, is certified by `boolean_search_no_exponential_speedup` and `ten_bit_search_bound`.

For Boolean search with `n = 2^k`, the two times are `2^k + 1` and `2^(k+1)`. Their ratio approaches 2 rather than growing exponentially.

## OEIS search

No OEIS search is relevant: the sequences used here are elementary affine and power-of-two sequences, not a newly observed combinatorial sequence.

## Counterexample hunt

Boundary cases were checked while formulating the theorem. The hypothesis `1 ≤ p` is essential to its intended interpretation: if preparation were free (`p = 0`), molecular time is always 1 while sequential time is `n`, so no uniform factor-two bound exists. With `p ≥ 1`, the Lean theorem proves the bound for every natural `n`, making a separate finite random search unnecessary.

## Interpretation

These calculations support only the explicit end-to-end cost model formalized in the Lean file. They are not measurements of DNA hardware and do not establish the empirical storage or operation-rate conjectures in the research prompt.
