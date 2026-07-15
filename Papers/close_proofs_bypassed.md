# Computational Evidence

## Small-case calculations

The executable certificate `primPart_check` evaluates every index in the interval `13 ≤ n ≤ 10000`. For each index it confirms the disjunction that the index is prime or its divisor-stripped Fibonacci primitive part exceeds one. At composite indices, the latter alternative yields a prime factor absent from every proper divisor index.

For the mixed-radix bridge, the first place values for bases `b(i)=i+1` are

| position `i` | running product `∏_{j<i}(j+1)` | `i!` |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 1 | 1 |
| 2 | 2 | 2 |
| 3 | 6 | 6 |
| 4 | 24 | 24 |
| 5 | 120 | 120 |

Thus the mixed-radix and factoradic value sums agree term by term.

## Sequence identification

The running products above are the factorial numbers. No external sequence lookup is needed because the equality follows from the product recurrence and is established symbolically for every index.

## Counterexample hunt

The certified Fibonacci search found no counterexample in `13 ≤ n ≤ 10000`. It does not test indices above `10000`, so no unbounded conclusion is drawn from it. This boundary exposed the unsupported tail in the previous statement and led to the corrected bounded theorem.

The validity predicates were also compared symbolically: `c(i) < i+1` is equivalent to `c(i) ≤ i` over natural numbers, leaving no exceptional zero-index case.
