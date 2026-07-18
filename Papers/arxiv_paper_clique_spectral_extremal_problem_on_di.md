# Computational evidence

The formal target is an exact algebraic balancing identity, so exhaustive experimentation is not required for soundness. Small cases nevertheless illustrate it.

For two varying part sizes `a,b` and fixed remaining parts, moving one vertex from `a` to `b` changes the number of `(s+2)`-cliques by

`(a - b - 1) * C_s(remaining parts)`.

Representative calculations:

| `s` | `a` | `b` | remaining parts | old count | balanced count | gain |
|---:|---:|---:|:---|---:|---:|---:|
| 0 | 5 | 2 | `[]` | 10 edges | 12 edges | 2 |
| 0 | 7 | 1 | `[]` | 7 edges | 12 edges | 5 |
| 1 | 5 | 2 | `[3]` | 30 triangles | 36 triangles | 6 |
| 1 | 6 | 1 | `[2,4]` | 92 triangles | 116 triangles | 24 |
| 2 | 5 | 2 | `[3,4]` | 120 four-cliques | 144 four-cliques | 24 |

For example, in the fourth row the predicted gain is
`(6 - 1 - 1) * (2 + 4) = 24`. In the last row it is
`(5 - 2 - 1) * (3 * 4) = 24`.

No counterexample exists under the theorem's hypotheses because the exact identity is proved in Lean. At the boundary `a=b+1`, the gain is zero, as expected. Strict increase requires both `a≥b+2` and a positive number of ways to select the remaining `s` parts.

No OEIS search was relevant: the result concerns a parameterized elementary-symmetric polynomial rather than a newly observed one-dimensional sequence.
