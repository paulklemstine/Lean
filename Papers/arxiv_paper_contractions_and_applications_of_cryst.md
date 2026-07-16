# Computational Evidence

The investigation concerns structural contraction laws rather than a numerical sequence, so the relevant small cases are finite directed graphs.

| Original vertices and edges | Fibers | Quotient behavior |
|---|---|---|
| One vertex, no edge | one singleton | Reachability is reflexive before and after contraction. |
| Two vertices `a → b`, singleton fibers | two singletons | The unique nontrivial path lifts exactly. |
| Three vertices `a → b → c`, with `a,b` in one fiber and `c` in another | two fibers | Directed connectivity inside the first fiber lets the quotient edge lift from either valid representative in the required direction. |
| Two vertices `b → a` in one fiber, with a further edge `b → c` | `{a,b}` and `{c}` | From representative `a`, the quotient edge to the second fiber does not lift. This is a counterexample to replacing directed fiber connectivity by undirected connectivity. |

For character sums, weights `2, 3, 5` grouped first as `{2,3}` and `{5}`, then into a single tile, give `(2+3)+5 = 10`, equal to direct contraction `2+3+5 = 10`. The theorem establishes this identity for arbitrary finite types and every additive commutative monoid, so exhaustive numerical testing would add no further coverage.

No OEIS search applies: no integer sequence is introduced. The counterexample hunt instead targeted the only questionable universal claim, namely whether undirected fiber connectivity suffices; the oriented three-vertex example above disproves it.
