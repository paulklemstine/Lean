# Computational Evidence

## Small-case calculations

For the determinant-one trace recurrence

`u₀ = 2`, `u₁ = t`, `uₙ₊₂ = t uₙ₊₁ - uₙ`,

the first terms at `t = 3` are:

| n | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---:|---:|---:|---:|---:|---:|
| uₙ | 2 | 3 | 7 | 18 | 47 | 123 |

Adjacent pairs give the constant values

| pair `(x,y)` | `x² - 3xy + y²` |
|---|---:|
| `(2,3)` | -5 |
| `(3,7)` | -5 |
| `(7,18)` | -5 |
| `(18,47)` | -5 |
| `(47,123)` | -5 |

The accompanying arithmetic development proves symbolically that the constant is
`4 - t²` for every integer `t` and every index, rather than relying on these samples.

## OEIS search results

The trace-three sample `2, 3, 7, 18, 47, 123, ...` is the Lucas-type recurrence
`uₙ₊₂ = 3uₙ₊₁ - uₙ`. No external sequence identifier was needed for the proof, and no
identifier is asserted here without a checked search result.

## Counterexample hunt and boundary cases

* At `t = 2`, the sequence is constant `2`, and the conic invariant is `0`; thus positive
discriminant and hyperbolic growth require the boundary condition `|t| > 2`.
* Pure rotations in the disk model can fix the origin, so raw orbit points need not be
discrete or distinct without hypotheses on the acting subgroup and stabilizer.
* Counting by true hyperbolic radius should exhibit exponential volume scale. This makes
a universal `R²/(2 log R)` law implausible when `R` denotes hyperbolic radius.
* Tessellation vertices alone have no canonical multiplication, so a unique-factorization
claim requires an additional algebraic structure before it is testable.

## Numerical table versus plots

The table is more informative than a plot at this scale: it exhibits the exact integral
quadratic invariant and avoids numerical roundoff in disk coordinates.
