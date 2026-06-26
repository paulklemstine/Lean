# Theorem Trace — Row-exchange under eventual contraction (five-vertex half-strip)

Ground-truth source: Phase A Lean file `Catalog/Novelty/FiveVertexRowExchange.lean`
(namespace `FiveVertexRowExchange`). Setting: `R` a complete `NormedRing`
(`CompleteSpace R`), specialized to `TM = Matrix (Fin 5) (Fin 5) ℝ` with the
`L∞` operator norm (`Matrix.linftyOpNormedRing` / `Matrix.linftyOpNormedAlgebra`).

## Explicitly present theorems (verbatim signatures from the Lean output)

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `conj_pow_eq` | If `u*u = 1` and `u*x = x*u`, then `u * x^n * u = x^n` for all `n`. | yes (informal "the swap slides through") | Lemma 1 |
| `conj_inverse_one_sub_eq` | If `u*u = 1`, `u*x = x*u`, `‖x‖ < 1`, then `u * Ring.inverse (1-x) * u = Ring.inverse (1-x)`. | yes (main theorem, plain language) | Theorem 2 |
| `conj_tsum_geom_eq` | Same hypotheses give `u * (∑' n, x^n) * u = ∑' n, x^n`. | yes (series form) | Corollary 3 |
| `conj_unit_inverse_one_sub_eq` | For a unit `u : Rˣ` with `u*x = x*u` and `‖x‖<1`, `u * Ring.inverse (1-x) * u⁻¹ = Ring.inverse (1-x)`. | yes (symmetry-group generalization) | Theorem 4 |
| `norm_inverse_one_sub_le` | For `[NormOneClass R]`, `‖x‖<1`: `‖Ring.inverse (1-x)‖ ≤ (1-‖x‖)⁻¹`. | yes (Neumann bound) | Theorem 5 |

## Named in Phase A lab notes / future directions as established this cycle
(definitions and corollaries on the concrete `TM` ring; statements as described
in the Lean docstring and Future Directions text)

| Lean name | Description | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `prodDown` (def) | Accumulated half-strip product `prodDown M (m+1) = M m * prodDown M m`, `prodDown M 0 = 1`. | yes | Definition (Section 2) |
| `prodDown_tendsto_zero` | Eventual contraction (`‖M k‖ ≤ c < 1` for `k ≥ N`) implies `‖prodDown M m‖ → 0`. | yes | Theorem 6 |
| `transferProduct_vanishes` | Specialization of `prodDown_tendsto_zero` to `TM`. | yes | Corollary |
| `rowExchange` (def) | `rowExchange i j = (Equiv.swap i j).permMatrix`, with `S*S = 1`, `‖S‖ = 1`. | yes | Definition (Section 2) |
| `rowExchange_resolvent_invariant` | Specialization of `conj_inverse_one_sub_eq` to `S = rowExchange i j` on `TM`. | yes | Corollary |
| `rowExchange_transferProduct_vanishes` | Row exchange preserves the norm-collapse of the transfer product. | yes | Corollary |

No theorems are stated in the prose that do not appear above. No theorem name is
paraphrased into a grander claim; the resolvent-invariance and product-vanishing
statements are reported exactly as proved (abstract result is invariance of the
geometric resolvent / partition-sum operator, not a stronger spectral claim).
