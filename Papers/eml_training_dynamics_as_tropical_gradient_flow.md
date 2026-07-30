# Computational evidence: three-sample tropical training

For the ordered reduced targets `(-2, 1, 5)`, the tropical scalar-neuron loss is

`L(x) = |x+2| + |x-1| + |x-5|`.

## Small-case calculations

| `x` | -4 | -2 | -1 | 0 | 1 | 2 | 4 | 5 | 7 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `L(x)` | 16 | 10 | 9 | 8 | **7** | 8 | 10 | 13 | 19 |

The unique minimum in this sample is the median target `x = 1`.
The unit-speed clipped flow `Φ(t,x)` reaches `1` after time `|x-1|`; for example,
`Φ(3,-2)=1` and `Φ(10,5)=1`. Representative calculations are also encoded as
kernel-checked Lean examples in `Catalog/Applications/EML/TropicalGradientFlow.lean`.

## Counterexample hunt

The candidate universal claim was checked conceptually across all order regions,
not merely numerically. If `a ≤ m ≤ c`, the absolute-value loss has slopes
`-3, -1, 1, 3` on the four intervals cut out by `a,m,c`, so it decreases up to
`m` and increases after `m`. Repeated targets do not create a counterexample:
with three observations, the median remains the unique minimizer. The formal
Lean proof covers arbitrary real `a,m,c,x`, including ties.

A stronger smooth-gradient interpretation would be false as stated because the
absolute-value loss is nondifferentiable at data points. The formal result uses
the correct piecewise-linear subgradient flow.

## OEIS search

No integer sequence is naturally produced by this continuous optimization
problem, so an OEIS search is not applicable.

## Plot/table interpretation

The table is the relevant discrete view of the piecewise-linear graph. Its four
linear regions meet at `-2`, `1`, and `5`, and the direction field points toward
`1` on both sides.
