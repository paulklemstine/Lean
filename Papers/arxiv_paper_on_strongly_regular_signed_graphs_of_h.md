# Computational evidence

For a signed pentagon there are only `2^5 = 32` edge-sign assignments. The five cyclic two-path products are constant exactly for the two homogeneous assignments:

| edge signs | cyclic two-path products | constant? |
|---|---|---|
| `+++++` | `+++++` | yes |
| `-----` | `+++++` | yes |
| `-++++` | `--+++` | no |
| `--+++` | `+--++` | no |
| `-+-+-` | `-----` except at the wrap-around product | no |

Thus the finite search predicts that a common two-path sign must be `+1` and all five edge signs must agree. The Lean theorem `pentagon_two_path_signs_force_homogeneous` proves this for every assignment, rather than relying on the enumeration.

No OEIS sequence naturally arises from these local matrix identities. No counterexample was found: the universal pentagon claim is completely proved in Lean. The matrix identities were checked symbolically in the stronger parameterized forms formalized by `design_sign_gram`, `signedGram_switch_rows`, and `weighing_switch_rows`.
