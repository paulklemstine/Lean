# Computational Evidence: Neural Tangent Dynamics

## Small-case calculations

For a two-sample, two-parameter Jacobian

| sample | parameter 1 | parameter 2 |
|---|---:|---:|
| 1 | 1 | 2 |
| 2 | 3 | 4 |

its Gram kernel is

|  | sample 1 | sample 2 |
|---|---:|---:|
| sample 1 | 5 | 11 |
| sample 2 | 11 | 25 |

For residual `(1, -1)`, the kernel energy is `8`. The induced parameter gradient is `(-2, -2)`, whose squared norm is also `8`, illustrating the Gram-energy identity.

For the diagonal kernel `diag(2, 1)` with learning rate `1/4`, residual coordinates are multiplied at each step by `(1/2, 3/4)`. Starting from `(1, 1)`, the first five residuals are:

| step | first coordinate | second coordinate | squared norm |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 2 |
| 1 | 1/2 | 3/4 | 13/16 |
| 2 | 1/4 | 9/16 | 337/1024 |
| 3 | 1/8 | 27/64 | 793/4096 |
| 4 | 1/16 | 81/256 | 6817/65536 |

The slow coordinate controls the asymptotic squared-norm contraction factor `(3/4)² = 9/16`.

## OEIS search results

No integer sequence is intrinsic to these matrix identities or convergence bounds, so an OEIS comparison is not applicable.

## Counterexample hunt

Positive semidefiniteness alone does not guarantee convergence. The zero Jacobian has zero NTK, so every residual is fixed forever. Likewise, for the scalar kernel `K = 1`, a learning rate greater than `2` makes the residual multiplier `1 - η` have magnitude greater than one, causing divergence. These examples justify an explicit strict-contraction or spectral-gap condition.

A bounded-Jacobian condition is also essential for a drift estimate linear in Jacobian displacement: the product difference `xy - x₀y₀` can be arbitrarily large for fixed displacement if the base values are unbounded.

## Numerical table interpretation

The calculations support the structural decomposition used in the results: Gram form gives nonnegative energy, a spectral condition gives contraction, and bounded Jacobian drift controls deviation from fixed-kernel dynamics.
