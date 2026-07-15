# Computational Evidence

The formal target reduces to exact finite edge-count identities, so only a small table is needed. For representative graphs with no isolated vertices:

| graph | `n` | `m` | `C(n,2)/m` |
|---|---:|---:|---:|
| `K₂` | 2 | 1 | 1 |
| `K₃` | 3 | 3 | 1 |
| path `P₄` | 4 | 3 | 2 |
| cycle `C₄` | 4 | 4 | 3/2 |
| matching on 4 vertices | 4 | 2 | 3 |
| `K₄` | 4 | 6 | 1 |
| matching on 6 vertices | 6 | 3 | 5 |

These cases support the proved interval `1 ≤ C(n,2)/m ≤ n-1`. Complete graphs attain the lower endpoint, and perfect matchings attain the upper endpoint for even `n`.

No OEIS search is relevant: the object is the standard binomial coefficient `C(n,2)`, not a newly observed sequence.

A counterexample hunt against the interval finds none. The universal probability-threshold claim itself is instead revealed to be automatic for `p < 1`, since every simple graph satisfies `m ≤ C(n,2)`.
