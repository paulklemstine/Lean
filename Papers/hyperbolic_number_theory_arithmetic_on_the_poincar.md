# Computational evidence

## Small cases

For the modular translation orbit

`z_n = n / (n + 2i)`,

the formal theorem `normSq_modularOrbit` gives

`|z_n|² = n² / (n² + 4)`.

The first nonnegative values are:

| `n` | `|z_n|²` | radial cutoff count `2n+1` |
|---:|---:|---:|
| 0 | 0 | 1 |
| 1 | 1/5 | 3 |
| 2 | 1/2 | 5 |
| 3 | 9/13 | 7 |
| 4 | 4/5 | 9 |
| 5 | 25/29 | 11 |

The first four radius calculations are kernel-checked by `first_radii`; the general radius and counting columns are proved by `normSq_modularOrbit` and `card_orbit_points`.

## Sequence search

The cutoff counts are the odd positive integers `1, 3, 5, 7, 9, 11, ...` (OEIS A005408). This identification is only descriptive; no external OEIS fact is used in a proof.

## Counterexample hunt

The initially considered reflection formula `z_{-n} = -conj(z_n)` fails already at `n = 1`. The corrected identity is `z_{-n} = conj(z_n)`, formally proved as `modularOrbit_neg`.

The broader claims about “hyperbolic primes” and a hyperbolic zeta function were not numerically tested because the prompt does not specify operations, a canonical norm, multiplicities, or a precise analytic function. Testing an arbitrary completion of those definitions would not provide evidence for a well-defined conjecture.

## Qualitative plot data

The exact formula proves that the points occur in conjugate pairs, move monotonically outward with `|n|`, remain strictly inside the unit disk, and converge to its ideal boundary. These facts are all formal theorems in `ModularOrbit.lean`; no floating-point plot is needed for them.
