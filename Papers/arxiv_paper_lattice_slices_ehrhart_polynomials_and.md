# Computational Evidence

## Small-case calculations

For a positive parameter vector `b`, cumulative bounds are `B_i = b_1 + ... + b_i`.
Exhaustive enumeration of positive integer vectors whose sorted entries satisfy
`x'_i ≤ B_i` gave the following data.

| `b` | cumulative profile | number of parking vectors | counts after fixing the last coordinate |
|---|---:|---:|---:|
| `(1)` | `(1)` | 1 | `(1)` |
| `(1,1)` | `(1,2)` | 3 | `(2,1)` |
| `(1,1,1)` | `(1,2,3)` | 16 | `(8,5,3)` |
| `(1,1,1,1)` | `(1,2,3,4)` | 125 | `(50,34,25,16)` |
| `(2,1)` | `(2,3)` | 8 | `(3,3,2)` |
| `(2,1,1)` | `(2,3,4)` | 50 | `(15,15,12,8)` |
| `(1,2,1)` | `(1,3,4)` | 34 | `(15,7,7,5)` |

The classical counts `1, 3, 16, 125` agree with `(n+1)^(n-1)` for `n = 1,2,3,4`.
The slice counts vary with the fixed value, confirming that a labelled-coordinate
slice theorem needs a value-dependent transformed profile rather than plain deletion
of a fixed rank.

## Sequence search

The classical sequence `1, 3, 16, 125, ...`, given by `(n+1)^(n-1)`, is the standard
count of parking functions. No external sequence database result is needed for the
new profile and slice claims, whose parameters are multivariate.

## Counterexample hunt

All parking vectors for the displayed profiles were checked against rank deletion:
a sorted vector remains parking after deleting rank `r` and deleting bound `B_r`.
No counterexample occurred. Profile monotonicity and the affine map
`x ↦ 1 + t(x-1)` were also tested for dimensions through four and factors
`t = 0,1,2,3`; no counterexample occurred.

A stronger naive conjecture—every fixed-coordinate slice is obtained by deleting one
rank independent of the fixed coordinate value—is contradicted by the nonconstant
slice-count rows above. The formal result therefore states the robust chamber-level
rank-deletion theorem and does not overstate the convex-hull gluing step.

## Tables and cryptographic scale

The table above also supplies the maximal cumulative bound used as a bounded-search
radius. For an `m × n` modular syndrome map, the finite-box criterion is
`q^m < (2B_n+1)^n`; under this strict inequality, two bounded candidates collide and
their difference is a nonzero modular-kernel vector of infinity norm at most `2B_n`.
