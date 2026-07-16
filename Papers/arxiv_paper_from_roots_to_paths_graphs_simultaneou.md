# Computational Evidence

## Small cases

For the six-vertex graph with edges `02, 03, 05, 12, 14, 23`, direct finite evaluation gives:

| vertex | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---:|---:|---:|---:|---:|---:|
| ordinary `P₃` count | 6 | 3 | 7 | 5 | 1 | 2 |
| end-rooted `P₃` count | 3 | 2 | 4 | 4 | 1 | 2 |

Thus all ordinary counts differ, while the end-rooted count collides at vertices 2 and 3 (and also at 1 and 5). The finite identities establishing both rows and the associated counterexample are imported by `AffineProfiles.lean`.

For the affine example with statistics `i ∈ {0,1}` and vertices `v ∈ {0,1,2}`, the intercept is `i+v` and slope is `2v+i`. At `t=6`, the profiles are:

| statistic | v=0 | v=1 | v=2 |
|---|---:|---:|---:|
| i=0 | 0 | 13 | 26 |
| i=1 | 7 | 20 | 33 |

Both rows are injective, as predicted for every `t>5`.

## OEIS search

No sequence search was used: the target concerns finite graph-incidence vectors and a structural separation criterion, not a naturally arising one-dimensional integer sequence.

## Counterexample hunt

The six-vertex graph disproves the unguarded assertion that ordinary `P₃` irregularity implies end-rooted `P₃` irregularity. The surviving guarded statement requires the two compared vertices to have equal degree; under that condition, ordinary irregularity forces their end-rooted counts to differ.

## Boundary case

The strict affine threshold cannot generally be weakened to `t ≥ B`. At `t=B=1`, profiles with `(c₁,m₁)=(1,0)` and `(c₂,m₂)=(0,1)` coincide despite `m₁<m₂` and both intercepts being at most `B`.
