# Computational evidence

The selected theorem is algebraic rather than conjectural: affine squares over a finite field are pairwise orthogonal. Small orders nevertheless provide useful checks.

| field | nonzero slopes | predicted family size |
|---|---:|---:|
| `ZMod 2` | `{1}` | 1 |
| `ZMod 3` | `{1,2}` | 2 |
| `ZMod 5` | `{1,2,3,4}` | 4 |
| `ZMod 7` | `{1,2,3,4,5,6}` | 6 |

For two distinct slopes `a,b`, equality of the two superposed entries gives
`a*x+y = a*x'+y'` and `b*x+y = b*x'+y'`. Subtraction forces
`(a-b)(x-x')=0`; field cancellation forces `x=x'`, and then `y=y'`.
Thus no counterexample can occur over a field. The Lean file also contains checked concrete consequences for orders 3 and 5, including orthogonality of slopes 1 and 2 at order 3.

No OEIS search is relevant: the cardinality is exactly `q-1`, not an experimentally discovered sequence. No plot is informative for this finite incidence statement.
