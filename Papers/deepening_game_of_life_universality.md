# Computational Evidence

The formal development concerns the geometric dependency region for Conway's local rule.

## Small cases

For generation counts `t = 0,1,2,3,4`, the radius-`t` Chebyshev squares have side lengths
`1,3,5,7,9` and therefore contain respectively

| `t` | side length | cells |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 3 | 9 |
| 2 | 5 | 25 |
| 3 | 7 | 49 |
| 4 | 9 | 81 |

These values match `(2t+1)^2`, the bound formalized in Lean.

## Sequence identification

The counts are the odd squares `1, 9, 25, 49, 81, ...`. No OEIS lookup is needed for the proof: the sequence follows directly by counting the Cartesian product of two integer intervals of length `2t+1`.

## Counterexample hunt

Boundary checks at `t = 0` and `t = 1` agree with the definitions: the time-zero dependency cone is the singleton center, while one local update reads precisely the nine-cell closed Moore neighborhood. The Lean proof establishes the containment for every natural `t`, superseding finite sampling.

## Interpretation

Compared with the earlier recursive union estimate `9^t`, the square light-cone estimate is quadratic, `(2t+1)^2`. This is an ambient input-region bound; it does not assert that every point in the square semantically affects every output configuration.
