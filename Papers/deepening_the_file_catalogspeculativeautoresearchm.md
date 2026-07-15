# Computational Evidence: Finite Factorial Codes

## Small cases

For length `k`, the successive digit alphabets have sizes `1, 2, …, k`, hence the code-space sizes are:

| `k` | alphabet sizes | number of codes | target interval |
|---:|:---|---:|:---|
| 0 | empty product | 1 | `0 ≤ n < 1` |
| 1 | 1 | 1 | `0 ≤ n < 1` |
| 2 | 1, 2 | 2 | `0 ≤ n < 2` |
| 3 | 1, 2, 3 | 6 | `0 ≤ n < 6` |
| 4 | 1, 2, 3, 4 | 24 | `0 ≤ n < 24` |
| 5 | 1, 2, 3, 4, 5 | 120 | `0 ≤ n < 120` |

For `k = 4`, digits `(d₀,d₁,d₂,d₃)` satisfy `d₀=0`, `d₁<2`, `d₂<3`, and `d₃<4`, and evaluate as

`d₀·0! + d₁·1! + d₂·2! + d₃·3!`.

The extreme code `(0,1,2,3)` has value `0 + 1 + 4 + 18 = 23 = 4! − 1`, confirming the sharp upper endpoint.

## Sequence identification

The code-space cardinalities begin

`1, 1, 2, 6, 24, 120, 720, …`,

the factorial numbers (OEIS A000142).

## Counterexample hunt

The boundary cases most likely to expose a mismatch are the empty code (`k=0`), the forced zero digit at position zero, and the maximal valid code. They produce respectively the unique element of `Fin 1`, no spurious multiplicity, and exactly `k!−1`. No counterexample occurs in these cases.

A zero radix would invalidate generic mixed-radix digit extraction, but factorial radices are `i+1` and are therefore always positive. Values at or above `k!` are intentionally excluded: they require another digit and would contradict a length-`k` classification.

## Numerical pattern

The maximal valid value telescopes:

`∑_{i<k} i·i! = ∑_{i<k} ((i+1)!−i!) = k!−1`.

This calculation predicts both the exact capacity and the absence of gaps once reconstruction is established.
