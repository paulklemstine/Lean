# Computational Evidence

## Small cases

For the displayed sequence defined by `A(0)=1` and `A(n+1)=A(n)+n`, the first terms are

| `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `A(n)` | 1 | 1 | 2 | 4 | 7 | 11 | 16 | 22 | 29 | 37 | 46 |
| `A(n)+A(n+1)` | 2 | 3 | 6 | 11 | 18 | 27 | 38 | 51 | 66 | 83 | 102 |
| `n²+2` | 2 | 3 | 6 | 11 | 18 | 27 | 38 | 51 | 66 | 83 | 102 |

The consecutive sums match `n²+2` throughout and the exact identity is proved in the accompanying development.

## Large-index calculation

The exact closed form gives

`A(10^6) = 499999500001`,

hence

`A(10^6)/(10^6)² = 0.499999500001`.

This is close to `1/2`, not `1/4`. The exact value at one million is included as a proved theorem rather than an unchecked numerical assertion.

## OEIS identification

The displayed terms are the lazy-caterer or central polygonal numbers, OEIS A000124, with formula `1 + n(n-1)/2`. This identification applies to the displayed data, not to the literal “least positive integer unequal to one forbidden sum” rule, which is a different and under-specified construction.

## Counterexample hunt

The proposed sum-avoidance fails at index five:

`A(5)=11=A(4)+A(3)=7+4`.

The proposed bounded approximation by `floor(n²/4)` also fails: the accompanying theorem proves that for every bound `C`, some `n` satisfies `n²+4C < 4A(n)`. Thus the discrepancy from `n²/4` is unbounded.

The proposed nonconvergence of consecutive ratios is contradicted by the exact quadratic closed form; the existing analytic result establishes convergence to `1`.
