# Computational evidence

## Small cases

The formal development uses the endpoint set

`B = {0, 2, 6, 14}`.

Its six unordered pairs have distinct integral midpoints:

| endpoints | midpoint | radius |
|---|---:|---:|
| 0, 2 | 1 | 1 |
| 0, 6 | 3 | 3 |
| 2, 6 | 4 | 2 |
| 0, 14 | 7 | 7 |
| 2, 14 | 8 | 6 |
| 6, 14 | 10 | 4 |

Thus four lattice points contain a positive-radius zero-skeleton about six
centers.  This table is certified in Lean by
`EndpointCubeSkeleta.linear_bound_counterexample`.

For two labels of size two, the full Cartesian relation has four objects and
both coordinate projections have size two.  This finite check is certified by
`EndpointCubeSkeleta.max_projection_bound_counterexample`.

## Counterexample hunt

The first construction above disproves the proposed universal strengthening
`|centers| ≤ |points|`.  The proved quadratic upper bound survives this test:
`6 ≤ 4^2`.

## OEIS search

No OEIS identification is asserted.  The finite examples test incidence and
projection inequalities rather than defining a canonical integer sequence.

## Scope

No numerical experiment is used as a substitute for proof.  Every claim from
these tables that is reported as a result also has a kernel-checked Lean
statement in the accompanying files.
