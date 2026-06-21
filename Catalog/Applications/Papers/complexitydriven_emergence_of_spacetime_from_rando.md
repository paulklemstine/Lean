# Computational Evidence: Bond-Dimension Phase Transition (Tropical Min-Cut)

This note records the small-case sanity checks behind the Lean formalization in
`TensorNetworkComplexity.lean`, `BondDimensionTransition.lean`, and
`HolographicScaling.lean`.

## 1. The model

A tensor network on `N` vertices has, across a boundary bipartition, a family of
candidate Ryu–Takayanagi cuts. Cut `i` contributes
`area_i + size_i · t`, where `t = log D` (`D` = bond dimension), `size_i` = number
of cut bonds, `area_i` = fixed offset. The entanglement entropy is the tropical
(min-plus) polynomial `S(t) = min_i (area_i + size_i · t)`.

## 2. Two-cut crossover (worked example)

Take a small cut `(area_0, size_0) = (5, 1)` and a large cut
`(area_1, size_1) = (0, 2)`.

`critTime = (area_0 - area_1)/(size_1 - size_0) = (5 - 0)/(2 - 1) = 5`,
so `D_c = exp(5) ≈ 148.4`.

| t = log D | a0 + 1·t | a1 + 2·t | S(t) = min | active cut |
|-----------|----------|----------|------------|------------|
| 0         | 5        | 0        | 0          | large (c1) |
| 2         | 7        | 4        | 4          | large (c1) |
| 4         | 9        | 8        | 8          | large (c1) |
| 5         | 10       | 10       | 10         | tie (D_c)  |
| 6         | 11       | 12       | 11         | small (c0) |
| 8         | 13       | 16       | 13         | small (c0) |

The slope of `S` jumps from `2` (below `D_c`) to `1` (above `D_c`): a sharp,
first-order transition in the scaling exponent. This is exactly
`scalingExponent_jump`.

## 3. Concavity / curvature proxy

For the same example, the symmetric second difference at scale `h = 1`:

* away from the kink (`t = 2`): `S(1)+S(3)-2S(2) = 2 + 6 - 2·4 = 0` (flat: smooth);
* at the kink (`t = 5`): `S(4)+S(6)-2S(5) = 8 + 11 - 2·10 = -1 ≤ 0` (concave kink).

Every sampled second difference is `≤ 0`, consistent with `curvatureProxy_nonpos`
(universal one-sided curvature bound `0`). The negative value localizes at the
phase boundary — the "curvature is concentrated at the transition" picture.

## 4. Eventual affinity (smooth regime)

Adding a third cut `(area_2, size_2) = (-3, 3)` does not change the large-`t`
behavior: for `t` large the slope-`1` cut still wins (smallest size), so
`S(t) = 5 + 1·t` for all sufficiently large `t`. Numerically the crossover where
the size-1 cut becomes permanently dominant is at `t = 5` here. This matches
`mincutEntropy_eventually_affine`: beyond a threshold the entropy is exactly
affine with slope = minimal cut size.

## 5. Uniform-scaling invariance (heterogeneity test)

Scaling every bond distance by a common `c > 0` multiplies both
`distToFinset d B` and `distToFinset d (boundary\B)` by `c`, leaving the strict
inequality (hence wedge membership) unchanged. Tested on a 4-vertex toy metric:
the entanglement wedge of `B` is identical for `c ∈ {0.5, 1, 2, 10}`. This is the
content of `wedge_invariant_under_uniform_scaling`, and the reason genuine
emergence needs *heterogeneous* bond dimensions (`size_i` not all equal).

## 6. Sequence note

The piecewise-linear `S(t)` is a tropical (min-plus) polynomial; its breakpoints
are the pairwise crossover times `(area_i - area_j)/(size_j - size_i)`. No OEIS
sequence is claimed — the objects are real-parameter families, not an integer
sequence.
