# Computational evidence

## Small-case calculations

For the quadratic field parameter `D = 5`, the certified examples in
`QuadraticColorExamples.lean` establish:

| prime `p` | `(5/p)` | local behavior indicated by the color |
|---:|---:|---|
| 5  | 0  | ramified |
| 7  | -1 | nonsquare / inert |
| 11 | 1  | square / split |
| 13 | -1 | nonsquare / inert |
| 19 | 1  | square / split |

These are not merely external calculations: each row is represented by a Lean theorem proved
with `norm_num`.

## OEIS search

No sequence is intrinsic to the uniform local theorem proved here, so no OEIS identification
is claimed. A future certified enumeration of fundamental discriminants by absolute bound
would naturally produce a counting sequence suitable for an OEIS comparison.

## Counterexample hunt

The candidate three-way classification was checked against the cases above, including the
ramified edge case `p ∣ D`. No counterexample was found. More importantly, the universal Lean
theorem `quadratic_local_shape_color_classification` proves the classification for every
integer `D` and every prime `p`, making a larger finite sample unnecessary for that local
claim.

## Scope of the evidence

This evidence does not enumerate all quadratic fields of discriminant at most 1000 and does
not computationally verify a global automorphic correspondence. It supports the precise local
Legendre-symbol theorem formalized in this phase.
