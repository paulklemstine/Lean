# Computational evidence

The selected theorem is structural rather than conjectural: the limit property reduces definitionally to the universal property of dependent functions, so numerical experimentation is not needed for the proof. Small dimensions nevertheless confirm the chosen sphere model:

| dimension | ambient coordinates | defining equation | north pole |
|---:|---:|---|---|
| 0 | 1 | `x₀² = 1` | `(1)` |
| 1 | 2 | `x₀² + x₁² = 1` | `(1,0)` |
| 2 | 3 | `x₀² + x₁² + x₂² = 1` | `(1,0,0)` |
| 3 | 4 | `x₀² + x₁² + x₂² + x₃² = 1` | `(1,0,0,0)` |

For each displayed case, negating all coordinates preserves the equation and has no fixed point: a fixed point would force every coordinate to zero, contradicting that the sum of squares is one. This argument is proved uniformly in Lean for every dimension.

No integer sequence is asserted by the formal result, so an OEIS search is inapplicable. A counterexample hunt for the universal limit claim is also inapplicable after specifying the discrete diagram: any cone map is forced coordinatewise, which is exactly the uniqueness proof formalized in `allSpheresConeIsLimit`.
