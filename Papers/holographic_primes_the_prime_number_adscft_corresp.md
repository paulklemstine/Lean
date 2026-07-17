# Computational Evidence: Finite Prime Holograms

## Small-case calculations

For prime modes `P`, occupation cutoff `N`, and inverse temperature `β = 1`, the tested quantity was

`∏_{p∈P} ∑_{n=0}^N p^{-n}`

against the direct bulk enumeration

`∑_{a : P → {0,…,N}} ∏_{p∈P} p^{-a(p)}`.

Exact rational arithmetic gave:

| prime modes | cutoff `N` | boundary product | number of bulk states | boundary − bulk |
|---|---:|---:|---:|---:|
| `{2}` | 1 | `3/2` | 2 | 0 |
| `{2,3}` | 1 | `2` | 4 | 0 |
| `{2,3}` | 2 | `91/36` | 9 | 0 |
| `{2,3,5}` | 2 | `2821/900` | 27 | 0 |

The equality follows the observed pattern that each selected local monomial corresponds to exactly one occupation profile.

## Sequence comparison

With all primes below a cutoff and `N = 1`, the numerators and denominators depend on the primorial and on products of shifted primes. No OEIS identification was used: these cutoff-dependent rational pairs do not define a canonical integer sequence without an additional normalization choice.

## Counterexample hunt

All combinations of the first five primes, cutoffs `0 ≤ N ≤ 4`, and rational inverse temperatures represented through integer prime powers were checked by exact distributive expansion. No counterexample to finite boundary/bulk factorization occurred. This computation is exploratory evidence; the general result is established in `Catalog/Tropical/HolographicPrimes.lean`.

A boundary of the claim was detected conceptually rather than numerically: the infinite Euler product cannot be asserted for arbitrary `β`. The proved global identity therefore assumes `β > 1`, the half-plane of convergence.

## Tropical behavior

For positive logarithmic prime energies, the vacuum occupation profile has energy zero and every other profile has nonnegative energy. Consequently the finite-temperature normalized log partition approaches zero as temperature decreases. The finite theorem records the exact tropical ground energy; no numerical extrapolation is used as a substitute for that result.
