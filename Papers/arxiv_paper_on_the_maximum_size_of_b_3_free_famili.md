# Computational Evidence

## Small-case calculations

The elementary gain numerator from the four-layer construction is

`N(q) = q^4 (q - 1)(q^2 - 1)(q^3 - 1) - q^6`.

For the first prime powers:

| `q` | `N(q)` |
|---:|---:|
| 2 | 272 |
| 3 | 32,967 |
| 4 | 721,664 |
| 5 | 7,424,375 |
| 7 | 236,371,247 |
| 8 | 922,775,552 |
| 9 | 3,056,369,679 |

All sampled values are positive. The accompanying theorem proves positivity for every integer `q ≥ 2`, which includes every prime power.

For the deterministic cube obstruction, the smallest nondegenerate rank parameter is `k = 2`. The bottom has cardinality `0`, the singleton extensions cardinality `1`, and the top cardinality `3`. If all singleton labels lie in the span of the bottom, the top span has the same dimension as the bottom, contradicting the top-layer selection rule. The same calculation persists for all `k ≥ 2` after translating the four cardinalities by `k - 2`.

## OEIS search results

No sequence identification is needed: the sampled numerator values arise by direct evaluation of an explicit polynomial expression rather than by a newly observed recurrence or counting sequence.

## Counterexample hunt

The universal positivity claim was checked on the small prime powers shown above; no counterexample was found. More importantly, the final result establishes the inequality symbolically for every `q ≥ 2`.

The interval obstruction was tested against its necessary boundary assumptions. If `k < 2`, natural-number subtraction collapses the intended four distinct ranks, so the hypothesis `2 ≤ k` is essential to the stated rank interpretation. If one omits freshness or pairwise distinctness of `x`, `y`, and `z`, the eight purported vertices can collapse; these assumptions are therefore retained.

## Table interpretation

The rapid growth of `N(q)` confirms that positivity of the numerator is not the limiting issue. The useful asymptotic constant also contains a large positive denominator and the Euler product `Δ_q`; optimizing the actual gain requires considering all of those factors rather than the numerator alone.
