# Computational Evidence

## Small-case calculations

For balanced parameters `n = 2d`, the Singleton condition becomes `2d + k ≤ 2d + 2`, hence `k ≤ 2`. Representative cases are:

| distance `d` | physical size `n` | allowed `k` values |
|---:|---:|---:|
| 1 | 2 | 0, 1, 2 |
| 2 | 4 | 0, 1, 2 |
| 3 | 6 | 0, 1, 2 |
| 5 | 10 | 0, 1, 2 |
| 10 | 20 | 0, 1, 2 |

For defect `delta`, with `n = 2d + delta`, the bound becomes `k ≤ delta + 2`:

| defect `delta` | maximum Singleton-compatible `k` |
|---:|---:|
| 0 | 2 |
| 1 | 3 |
| 2 | 4 |
| 5 | 7 |
| 10 | 12 |

## Counterexample hunt

The claim that the Singleton inequality can be “rearranged” into an exact identity fails whenever the bound is not saturated. For example, `[[n,k,d]] = [[6,1,3]]` satisfies `2d+k = 7 ≤ 8 = n+2`, but the proposed equality would require `k = n-2d+2 = 2`, contrary to `k = 1`.

The claimed reversed redundancy inequality also has an endpoint failure without positive distance: `(n,k,d) = (0,0,0)` satisfies `n = 2d` and `k ≤ n`, while `n-k ≤ 2(d-1)` is true under natural-number subtraction but `2 ≤ k` is false. This identifies `d ≥ 1` as a necessary guard for the equivalence used in the analysis.

No counterexample exists to the defect-capacity implication at the parameter-arithmetic level: substituting `n = 2d + delta` into `2d+k ≤ n+2` directly yields `k ≤ delta+2`.

## Sequence search

No new integer sequence arises: the maximum logical capacity at defects `delta = 0,1,2,…` is the affine sequence `2,3,4,…`. An OEIS lookup is therefore not informative for this study.

## Interpretation boundary

These calculations test consequences of the proposed parameter dictionary. They do not test the existence of corresponding stabilizer codes, a geometric realization, or a dynamical identification of gravity with syndrome processing.
