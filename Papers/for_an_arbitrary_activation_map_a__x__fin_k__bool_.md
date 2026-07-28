# Computational evidence

The target is a symbolic identity rather than a numerical conjecture. Small scalar cases nevertheless confirm the branch formula:

| preactivation `z` | pattern bit | `ReLU z` | selected branch |
|---:|:---:|---:|---:|
| -2 | false | 0 | 0 |
| 0 | false | 0 | 0 |
| 3 | true | 3 | 3 |

For two hidden neurons, the four formal patterns correspond respectively to the systems
`z₀ ≤ 0 ∧ z₁ ≤ 0`, `z₀ ≤ 0 ∧ 0 < z₁`, `0 < z₀ ∧ z₁ ≤ 0`, and
`0 < z₀ ∧ 0 < z₁`. Thus cell nonemptiness is exactly solvability of the selected
system. No integer sequence or OEIS search is relevant. Boundary value zero was
included in the counterexample hunt; strict-positive activation correctly places it
on the inactive branch, where ReLU is zero.
