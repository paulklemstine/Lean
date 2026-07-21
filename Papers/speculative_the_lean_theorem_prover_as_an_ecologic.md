# Computational Evidence

## Small-case calculations

The finite profile used to test the definitions has result/line pairs:

| State | Results | Lines | Fitness |
|---|---:|---:|---:|
| algebraic center | 30 | 10 | 3 |
| analytic center | 20 | 10 | 2 |
| combinatorial center | 24 | 12 | 2 |
| cross-style adapter | 9 | 6 | 3/2 |

Thus the adapter lies strictly below all three centers. The accompanying theorem file checks representative ratios and proves the general boundary-crossing result that makes such a penalized adapter unavoidable on every region-crossing path.

For the imported finite-word model, the candidate counts are `2^5 = 32`, `3^3 = 27`, and generally `q^n`. These exact counts provide a combinatorial source for a rapidly growing theorem-count numerator.

## OEIS search results

No OEIS search was used. The only sequence required here is the elementary exponential sequence `q^n`; assigning an OEIS identifier would add no evidence to the structural claims.

## Counterexample hunt

Three unconditional formulations fail:

1. A named style need not contain a local maximum if migration edges can leave the style toward a fitter state.
2. A region-crossing path need not lose fitness if its boundary edge is unpenalized.
3. An unrestricted infinite ecosystem need not have a global maximum; scores can increase along an infinite chain.

The proved statements therefore include, respectively, style-preserving neighborhoods and champion bounds, a strict boundary penalty, and finiteness of the comparison class.

## Table interpretation

The table is illustrative rather than empirical. It exercises the exact rational fitness definition and the strict-valley inequalities; it does not estimate the fitness of any existing mathematical library.
