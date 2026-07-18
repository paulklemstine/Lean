# Computational Evidence: Prime Rearrangements

## Small-case calculations

The finite-prefix extension mechanism was checked conceptually on the first few layers: a prescription on the first `k` indices can be enclosed in a finite initial segment containing those indices and all their prescribed images. The number of permutations on the first `k` rooms is

| `k` | 0 | 1 | 2 | 3 | 4 | 5 |
|---:|---:|---:|---:|---:|---:|---:|
| permutations | 1 | 1 | 2 | 6 | 24 | 120 |

These are the factorial numbers. The imported factorial-code classification establishes the count and gives an injective extension of all such finite rearrangements into permutations of the infinite hotel.

## Million-prime random-permutation test

A sieve generated the first 1,000,000 primes, ending at 15,485,863. Ten reproducible pseudorandom permutations of these indices were tested. The columns report the fraction of ratios within 10% of 1 over all indices, the same fraction over the final half of the indices, and the fraction in that final half below 1/2 or above 2.

| trial | all within 10% | tail within 10% | tail below 1/2 | tail above 2 |
|---:|---:|---:|---:|---:|
| 1 | 0.089316 | 0.131844 | 0.393148 | 0.001032 |
| 2 | 0.089670 | 0.132826 | 0.393944 | 0.001122 |
| 3 | 0.088979 | 0.131388 | 0.393166 | 0.001084 |
| 4 | 0.088599 | 0.131274 | 0.393124 | 0.001080 |
| 5 | 0.089435 | 0.132170 | 0.392650 | 0.001056 |
| 6 | 0.089173 | 0.131868 | 0.392634 | 0.001064 |
| 7 | 0.089557 | 0.132404 | 0.392978 | 0.001106 |
| 8 | 0.089591 | 0.132798 | 0.392956 | 0.001084 |
| 9 | 0.089438 | 0.132406 | 0.393274 | 0.001068 |
| 10 | 0.089422 | 0.132218 | 0.392746 | 0.001042 |

The proposed empirical conclusion is contradicted: a uniformly random permutation of a large finite prefix does not make most ratios close to 1. Roughly 39.3% of ratios in the final half are below 1/2, while only about 13.2% lie within 10% of 1.

## Counterexample hunt and interpretation

The finite random model should not be confused with a probability distribution on all permutations of the natural numbers. There is no uniform probability measure on the countably infinite symmetric group extending the uniform measures on finite symmetric groups. Accordingly, an “exact density” is undefined until a probability model or an exhaustion-and-normalization scheme is specified.

The topological statement survives. Every pointwise neighborhood fixes only finitely many values, and those values can be completed inside a finite initial segment, with the resulting permutation equal to the identity afterward. Its prime ratio is therefore eventually exactly 1.

The suggested reversal `n ↦ N-n` is only a permutation of a finite interval, not of all natural numbers. It cannot serve as an infinite counterexample without a different definition.

## Sequence search

The finite-layer counts are the factorial numbers, OEIS A000142: `1, 1, 2, 6, 24, 120, ...`. No further database identification is needed for the ratio data, which are sample statistics rather than an integer sequence.
