# Computational Evidence

## Small-case calculations

The coordinate-axis classification predicts that the number of equivariant simplicial vertex maps from the boundary of the `(m+1)`-cross-polytope to the boundary of the `(n+1)`-cross-polytope is

`2^(m+1) · (n+1)!/(n-m)!` when `m ≤ n`, and zero otherwise.

The factor `2^(m+1)` records independent target signs, while the falling factorial records injections of source axes into target axes. Direct enumeration of this formula gives:

| target `n` | `m=0` | `m=1` | `m=2` | `m=3` | `m=4` | `m=5` |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 2 | 0 | 0 | 0 | 0 | 0 |
| 1 | 4 | 8 | 0 | 0 | 0 | 0 |
| 2 | 6 | 24 | 48 | 0 | 0 | 0 |
| 3 | 8 | 48 | 192 | 384 | 0 | 0 |
| 4 | 10 | 80 | 480 | 1920 | 3840 | 0 |

## Counterexample hunt

For all displayed dimensions, existence occurs exactly in the triangular region `m ≤ n`. No small case contradicts the proposed exact criterion. In particular, the first forbidden diagonal consists of `(m,n) = (1,0), (2,1), (3,2), (4,3), (5,4)`.

## Sequence search

No OEIS identification is needed: each row is explicitly a signed falling-factorial sequence. For fixed `m`, the nonzero counts are the polynomial sequence `2^(m+1) · (n+1)_{m+1}`.

## Interpretation

The computations isolate coordinate injectivity as the decisive invariant and motivate the structural proof: signs affect the number of maps but never their existence.