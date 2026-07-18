# Computational evidence

For `f(x)=4x(1-x)`, the two inverse branches are

`L(y)=(1-√(1-y))/2`, `U(y)=(1+√(1-y))/2`.

Using the representative target `y = 3/4`:

| depth | branch word | seed | check |
|---:|:---:|---:|:---|
| 1 | L | 1/4 | `f(1/4)=3/4` |
| 1 | U | 3/4 | `f(3/4)=3/4` |
| 2 | LL | `(2-√3)/4` | `f²(seed)=3/4` |
| 2 | UL | `(2+√3)/4` | `f²(seed)=3/4` |
| 2 | LU | 1/4 | `f²(seed)=3/4` |
| 2 | UU | 3/4 | `f²(seed)=3/4` |

The four depth-two values are distinct and lie in `(0,1)`. The same recursive calculation predicts `2^n` distinct depth-`n` preimages for every target in `(0,1)`.

## Counterexample hunt and boundary cases

The open-interval restriction is essential. At `y=1`, both branches coincide at `1/2`, so binary words need not decode injectively. At `y=0`, the lower branch reaches the endpoint `0`. No collision between distinct branch words occurs for targets strictly between `0` and `1`, because at every level `L(y)<1/2<U(y)` and each branch is injective.

## Sequence search

The number of indexed preimages by depth is `1, 2, 4, 8, 16, ...`, the powers of two (OEIS A000079). This is supporting context only; the Lean development proves the general formula and does not rely on OEIS data.
