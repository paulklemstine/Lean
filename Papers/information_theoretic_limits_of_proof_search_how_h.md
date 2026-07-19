# Computational Evidence

## Small-case calculations

For uniform branching `q` and depth `L`, the candidate population is `q^L`.

| Branching `q` | Depth `L` | Candidates `q^L` | Information `log₂(q^L)` |
|---:|---:|---:|---:|
| 2 | 5 | 32 | 5 |
| 3 | 3 | 27 | approximately 4.755 |
| 4 | 3 | 64 | 6 |
| 5 | 5 | 3125 | approximately 11.610 |

The first three candidate counts are included as concrete checked examples in `Catalog/Combinatorics/ProofSearchInformationLimits.lean`.

For strict binary compression, the number of strings shorter than `n` is `2^n - 1`. At `n = 5`, this gives `31`, fewer than the `32` objects of length five.

## OEIS search results

The diagonal candidate counts `n^n` begin

`1, 4, 27, 256, 3125, 46656, 823543, 16777216`.

No external OEIS lookup was supplied or performed, so no identifier is asserted here.

## Counterexample hunt

The proposed unconditional `n log n` law was tested against fixed binary branching. At depth `n`, binary branching gives `2^n` candidates and therefore exactly `n` bits of candidate-count information, not `n log₂ n`. Thus the universal formulation fails; `n log n` requires branching that itself grows polynomially with `n`.

A second boundary concerns probability. Candidate cardinality does not determine `-log₂ P(P)` for an individual derivation: different probability measures on the same finite candidate set assign different information values. A probability model must therefore be specified separately.

## Numerical pattern

For the diagonal model, `log₂(n^n) / (n log₂ n) = 1` whenever `n > 1`. This is an exact identity, not a fitted asymptotic trend. The accompanying theorem establishes the identity symbolically for every natural `n`, including boundary behavior under the standard logarithm convention.
