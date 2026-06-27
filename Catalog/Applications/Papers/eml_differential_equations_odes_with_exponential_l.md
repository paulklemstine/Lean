# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/EML/EMLCoefficientODE.lean` and `Catalog/EML/EMLLogDerivHom.lean`.

| Lean name | Statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `EMLCoefficientODE.hasDerivAt_exp_comp_solves` | If `HasDerivAt F c x` then `HasDerivAt (fun t => exp (F t)) (c * exp (F x)) x`. I.e. if `F' = c` then `(exp∘F)' = c·(exp∘F)`. | "The master key" section | Theorem 1 (Master construction) |
| `EMLCoefficientODE.solves_log_coeff` | For `0 < x`, `HasDerivAt (fun t => exp (t·log t − t)) (log x · exp (x·log x − x)) x`. Solves `y' = (log x)·y`. | "The logarithm coefficient / Stirling exponent" | Theorem 2 |
| `EMLCoefficientODE.solves_exp_coeff` | `HasDerivAt (fun t => exp (exp t)) (exp x · exp (exp x)) x`. Solves `y' = (exp x)·y`. | "The exponential coefficient / double exponential" | Theorem 3 |
| `EMLCoefficientODE.solves_power_coeff` | For `0 < x` and any `a`, `HasDerivAt (fun t => exp (a·log t)) ((a/x)·exp (a·log x)) x`. Solves `y' = (a/x)·y`, solution `x^a`. | "The power coefficient" | Theorem 4 |
| `EMLCoefficientODE.solution_ratio_hasDerivAt_zero` | If `HasDerivAt y (c·y x) x` and `HasDerivAt F c x` then `HasDerivAt (fun t => y t / exp (F t)) 0 x`. Uniqueness up to a constant. | "One solution, up to a constant" | Theorem 5 |
| `EML.EMLLogDerivHom` (logarithmic derivative homomorphism) | `L(y) = y'/y` is a homomorphism from `K^×` (multiplicative) to `(K,+)` (additive): `L(yz) = L(y)+L(z)`. | "The hidden symmetry" | Section 2 (algebraic engine) |
| `EMLDiffGalois.firstOrder_ratio_isConstant` (referenced, from existing file) | If `y₁'=a·y₁`, `y₂'=a·y₂`, `y₂≠0` then `(y₁/y₂)'=0`. Algebraic counterpart of Theorem 5. | mentioned | Section 5 (Galois context) |

No theorems beyond these are claimed. No theorem name is paraphrased into a grander claim.
