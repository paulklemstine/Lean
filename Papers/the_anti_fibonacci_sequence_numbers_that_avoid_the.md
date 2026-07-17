# Computational Evidence

## Small-case calculations

Two interpretations were tested separately.

| index `n` | literal least-avoiding rule | displayed increment rule |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 1 | 1 |
| 2 | 1 | 2 |
| 3 | 1 | 4 |
| 4 | 1 | 7 |
| 5 | 1 | 11 |
| 6 | 1 | 16 |
| 7 | 1 | 22 |
| 8 | 1 | 29 |

For the literal rule, the forbidden value is a sum of two positive integers and is
therefore at least two; hence one is always the least admissible value.  For the
displayed rule, successive increments are `0,1,2,3,...`.

## Large-index test

The exact displayed-rule identity gives

`A(1,000,000) = 1 + 1,000,000·999,999/2 = 499,999,500,001`.

Thus `A(n)/n² = 0.499999500001` at one million, approaching one half rather than one
quarter.  This calculation is backed by the general exact identities proved in
`Catalog/Pythagorean/AntiFibonacciDiagnosis.lean`.

## OEIS search

No external OEIS identification is asserted.  The displayed terms are the elementary
triangular shift `1 + n(n-1)/2`; an external database lookup was unnecessary for the
mathematical diagnosis and no unverifiable identifier is reported.

## Counterexample hunt

The proposed literal sequence already fails at index two: the least positive integer
different from `1+1=2` is `1`, not `2`.  The proposed quarter-square asymptotic also
fails: the displayed sequence has exact leading term `n²/2`.  The accompanying theorem
strengthens this finite observation by proving that its discrepancy from the
quarter-square model exceeds every prescribed linear error.
