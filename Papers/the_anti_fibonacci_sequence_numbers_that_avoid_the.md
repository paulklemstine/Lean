# Computational Evidence

## Small-case calculations

There are two distinct rules in the proposed description.

For the literal rule, the first two terms are `1,1`. Their sum is `2`, so the least positive integer unequal to that sum is `1`. The same argument then repeats forever:

| index `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| literal `A(n)` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

The displayed terms instead follow successive increments `0,1,2,3,…`:

| index `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| displayed `D(n)` | 1 | 1 | 2 | 4 | 7 | 11 | 16 | 22 | 29 |
| `D(n)-D(n-1)` | – | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |

This yields `D(n)=1+n(n-1)/2`, so its quadratic coefficient is `1/2`.

## OEIS search results

No external OEIS identification was used. The displayed values are an elementary shift of the triangular numbers; the exact recurrence and closed form suffice to identify their structure without relying on a database match.

## Counterexample hunt

The first computed recurrence step already refutes the advertised interpretation: the literal third term is `1`, not `2`. Moreover, the proved even-index identity

`D(2k) = floor((2k)^2/4) + k(k-1) + 1`

shows that the discrepancy from the proposed quarter-square law grows without bound. Thus neither a search to `10^6` nor a numerical convergence plot is needed to decide the stated conjecture.

## Representative comparison table

| `n` | `D(n)` | `floor(n²/4)` | discrepancy |
|---:|---:|---:|---:|
| 2 | 2 | 1 | 1 |
| 4 | 7 | 4 | 3 |
| 6 | 16 | 9 | 7 |
| 8 | 29 | 16 | 13 |
| 10 | 46 | 25 | 21 |

At `n=2k`, the discrepancy is exactly `k(k-1)+1`, explaining the accelerating separation visible in the table.
