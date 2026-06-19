# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/Tropical/EigenzeroNoLeak.lean` (extends
`Catalog/Tropical/MinPlusAlgebra.lean`). Every claim in ARTICLE.md and
RESEARCH_PAPER.md must map to one of the entries below. No theorem is
paraphrased into a grander claim than its Lean statement.

## Definitions (from MinPlusAlgebra.lean)

| Lean name | Statement | Used in |
|---|---|---|
| `tropMatMul` | `(A ⊗ B) i j = inf_k (A i k + B k j)` | Article §1, Paper §2 Def 1 |
| `tropId` | `tropId n M i j = if i = j then 0 else M` | Paper §2 Def 2 |
| `tropMatVecMul` | `(A ⊗ v) i = inf_k (A i k + v k)` | Article §1, Paper §2 Def 3 |
| `IsTropicalEigenpair` | `∀ i, tropMatVecMul A v i = v i + lam` | Article §2, Paper §2 Def 4 |
| `WeightedDigraph` | `weights`, `nonneg : 0 ≤ w i j`, `self_loop_zero : w i i = 0` | Article §3, Paper §2 Def 5 |
| `MinPlusHash` | `compressor : Matrix (Fin m) (Fin n) ℝ`, `bounded` | Paper §2 Def 6 |

## Definition (from EigenzeroNoLeak.lean)

| Lean name | Statement | Used in |
|---|---|---|
| `tropResidual` | `tropResidual A v i = tropMatVecMul A v i - v i` | Article §2, Paper §2 Def 7 |

## Theorems (from EigenzeroNoLeak.lean)

| Lean name | Statement | Used in |
|---|---|---|
| `tropResidual_eq_eigenvalue` | eigenpair ⇒ `tropResidual A v i = lam` (every i) | Article §2, Paper Thm 1 |
| `tropResidual_const` | eigenpair ⇒ `tropResidual A v i = tropResidual A v j` | Paper Cor 1 |
| `tropical_eigenvalue_unique` | eigenpairs `(lam,v)`,`(mu,v)` ⇒ `lam = mu` | Article §2, Paper Thm 2 |
| `eigenzero_iff_fixed` | `IsTropicalEigenpair A 0 v ↔ ∀ i, tropMatVecMul A v i = v i` | Article §3, Paper Thm 3 |
| `eigenzero_no_leak` | eigenpair `(0,v)` ⇒ `tropResidual A v i = 0` (every i) | Article §3, Paper Thm 4 (MAIN) |
| `eigenzero_iterate` | eigenpair `(0,v)` ⇒ `(tropMatVecMul A)^[k] v = v` | Paper Thm 5 |
| `digraph_residual_nonpos` | weighted digraph ⇒ `tropResidual G.weights v i ≤ 0` | Paper Lemma 1 |
| `digraph_eigenvalue_nonpos` | digraph eigenpair ⇒ `lam ≤ 0` | Article §3, Paper Thm 6 (boundary) |
| `digraph_eigenzero_const` | constant vectors are digraph eigenpairs with `lam = 0` | Article §3, Paper Thm 7 |

## Theorems referenced from MinPlusAlgebra.lean (context, fully stated there)

| Lean name | Statement | Used in |
|---|---|---|
| `tropMatMul_assoc` | `(A⊗B)⊗C = A⊗(B⊗C)` | Article §1, Paper §2 |
| `tropMatVecMul_shift` | `A ⊗ (v + c) = (A ⊗ v) + c` | Article §3, Paper Thm 8-context |
| `trop_preimage_nonunique` | many `(A,B)` give same `A⊗B` | Article §1, Paper §6 |
| `tropMatVecMul_lipschitz` | matrix-vector product 1-Lipschitz (sup norm) | Paper §6 future work |
| `MinPlusHash.eval_shift` | hash translation-equivariant | Paper §5 |

## Section 4 results listed in the EigenzeroNoLeak.lean module docstring
(stated at the level of the docstring summary only; exact Lean statements
not reproduced verbatim because the displayed file is truncated at §4):

- `eigenpair_shift_invariant` / `eigenzero_shift_invariant` — shift
  equivariance of the spectrum.
- `eigenzero_residual_indistinguishable` /
  `eigenzero_residual_uninformative` — eigenvector indistinguishability at λ = 0.
- `minPlusHash_leak_only_offset` — the min-plus hash leaks at most the global offset.

These are described in prose only in terms of the docstring summary, with no
invented formal statement.
