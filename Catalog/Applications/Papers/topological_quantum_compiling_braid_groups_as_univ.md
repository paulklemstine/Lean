# Theorem Trace (internal anti-hallucination record)

Source of truth: Phase A Lean file
`Catalog/Geometry/JonesTemperleyLiebBraid4.lean`
(namespace `JonesTemperleyLiebBraid4`).

All packaging prose is restricted to the names below. No other theorems are
claimed. Density of the Jones image in SU(3), universality of quantum
computation, infinite order of products, and the Solovay–Kitaev step from the
*concept blurb* are NOT proved in the Lean source and are therefore presented
ONLY as motivation / future work, never as established results.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `jonesOp` | def | `jonesOp A X = A • 1 + A⁻¹ • X` (image of a braid generator σ) | yes | yes (Def. 1) |
| `jonesInv` | def | `jonesInv A X = A⁻¹ • 1 + A • X` (candidate inverse of σ) | yes | yes (Def. 2) |
| `delta_scalar_id` | thm | If `δ = -(A² + A⁻²)` then `A² + δ + A⁻² = 0` | yes | yes (Lemma 1) |
| `braid_commute` | thm | If `X*Y = Y*X` then `jonesOp A X * jonesOp A Y = jonesOp A Y * jonesOp A X` (far commutation) | yes | yes (Thm 2) |
| `braid_relation` | thm | Under loop value + TL relations: `σ₁σ₂σ₁ = σ₂σ₁σ₂` | yes | yes (Thm 1) |
| `jonesOp_mul_jonesInv` | thm | `jonesOp A X * jonesInv A X = 1` | yes | yes (Thm 3a) |
| `jonesInv_mul_jonesOp` | thm | `jonesInv A X * jonesOp A X = 1` | yes | yes (Thm 3b) |

Hypotheses used (TL relations): `A ≠ 0`, `δ = -(A² + A⁻²)`,
`X*X = δ • X`, `Y*Y = δ • Y`, `X*Y*X = X`, `Y*X*Y = Y`.

The second Phase A file (`ArithmeticPhaseLocking.lean`) is off-concept
(arithmetic dynamics of gradient descent) and truncated; it is NOT part of this
topological-quantum-compiling package and is excluded from all deliverables.
