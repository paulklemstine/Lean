# Future Directions — Neural Tangent Kernel Formalization

## Synthesis

This cycle established the structural and convergence backbone of Neural Tangent
Kernel (NTK) theory in Lean 4, in `Catalog/MachineLearning/NeuralTangentKernel.lean`.
The deliverable proves, with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

- **`ntkGramMatrix_posSemidef`** — the empirical NTK Gram matrix `K = J Jᵀ` is
  positive semidefinite (a Gram matrix), so its spectrum lives in `[0, ∞)`.
- **`ntkGramMatrix_isSymm`** and **`gdUpdateMat_isSymm`** — `K` and the
  gradient-descent update operator `I - ηK` are symmetric; the residual dynamics
  are diagonalizable in an orthonormal eigenbasis.
- **`gdResidual_geometric_decay`** / **`gdResidual_tendsto_zero`** — an
  index-agnostic engine: a per-step contraction `‖step v‖ ≤ c‖v‖` with `c < 1`
  forces `‖r_t‖ ≤ c^t ‖r_0‖ → 0`.
- **`contractionFactor_optimalRate`**, **`optimalRate_minimizes`**,
  **`contractionFactor_optimal_lt_one`**, **`ntk_gd_optimal_convergence`** — the
  genuinely new content: a *spectral calibration* of the previously black-box
  constant `c`. We prove that the contraction landscape
  `c(η) = max(|1 - η λ_min|, |1 - η λ_max|)` is globally minimized at
  `η* = 2/(λ_min + λ_max)`, with optimal value `(λ_max - λ_min)/(λ_max + λ_min)
  = (κ - 1)/(κ + 1)` (condition number `κ = λ_max/λ_min`), which is `< 1` exactly
  when the kernel is positive definite.

The architectural lesson: separating the *scalar* optimization of the contraction
factor from the *matrix* machinery keeps every proof robust and reusable, while
still delivering the headline result that the optimal NTK learning rate is the
classical strongly-convex step size.

## Results Summary

| Theorem | Content | Status |
|---|---|---|
| `ntkGramMatrix_posSemidef` | `J Jᵀ ⪰ 0` | proved |
| `ntkGramMatrix_isSymm` | `(J Jᵀ)ᵀ = J Jᵀ` | proved |
| `gdUpdateMat_isSymm` | `I - ηK` symmetric | proved |
| `gdResidual_geometric_decay` | `‖r_t‖ ≤ c^t ‖r_0‖` | proved |
| `gdResidual_tendsto_zero` | `c < 1 ⟹ ‖r_t‖ → 0` | proved |
| `contractionFactor_optimalRate` | value `(κ-1)/(κ+1)` at `η*` | proved |
| `optimalRate_minimizes` | `η*` global minimizer | proved |
| `contractionFactor_optimal_lt_one` | optimal factor `< 1` | proved |
| `ntk_gd_optimal_convergence` | capstone convergence | proved |

## Research Directions

### 1. Operator norm = spectral radius for the symmetric update operator

The current convergence theorem feeds the *scalar* contraction factor `c(η*)` into
the abstract decay engine as a hypothesis `‖step v‖ ≤ c‖v‖`. The missing bridge is
the matrix-level fact that, for the symmetric operator `I - ηK`, the operator norm
on `EuclideanSpace ℝ (Fin n)` equals `max_i |1 - η λ_i|`, exactly the predicted
`contractionFactor`. The key insight is that for a Hermitian matrix the operator
norm equals the spectral radius, so the per-step contraction bound is *not* an
assumption but a consequence of `ntkGramMatrix_isSymm` plus the eigenvalue API.
Why now? We already have symmetry (`gdUpdateMat_isSymm`) and positivity
(`ntkGramMatrix_posSemidef`); connecting to `Matrix.IsHermitian.eigenvalues` and
`Matrix.IsHermitian.spectral_theorem` would let `ntk_gd_optimal_convergence`
*discharge* its contraction hypothesis automatically from the spectrum, closing
the loop between §2 (abstract decay) and §3 (spectral calibration) of the file.

### 2. Loss decay rate and strong convexity under positive definiteness

We proved residual-norm decay; the natural strengthening is the *loss* decay
`L(θ_t) = ½‖r_t‖² ≤ (1 - η λ_min)^{2t} L(θ_0)` when `K ≻ 0`. The key insight is
that this is the squared statement of `gdResidual_geometric_decay` with the sharper
per-coordinate contraction `1 - η λ_min` on the slowest mode, and it upgrades
"convergence" to a quantitative *strongly-convex* rate. Why now? The decay engine
is already coordinate-free, and the only new ingredient is the strict lower bound
`λ_min > 0`, i.e. upgrading `PosSemidef` to `PosDef`, which reduces to linear
independence of the Jacobian rows via `Matrix.PosDef` and `Matrix.rank`.

### 3. Positive definiteness from Jacobian full row rank

`ntkGramMatrix_posSemidef` gives `K ⪰ 0`; the falsifiable conjecture is the exact
criterion `K = J Jᵀ ≻ 0 ⟺ J has full row rank (rank = n)`, equivalently the
gradient feature vectors `{∇_θ f(x_i)}` are linearly independent. The key insight
is that this is the Gram-matrix nondegeneracy theorem in disguise:
`(J Jᵀ).PosDef ↔ Function.Injective J.mulVecᵀ`. Why now? It is the precise
hypothesis that directions 1 and 2 both require (`λ_min > 0`), it is fully
decidable for concrete rational `J` (enabling `#eval`/`decide` sanity checks), and
Mathlib's `Matrix.posDef_iff` and rank theory put it within reach.

### 4. Block / multi-output NTK over product index types

Real classifiers have vector outputs, making the NTK a block Gram matrix
`K ∈ ℝ^{nk × nk}` indexed by `Fin n × Fin k`. The conjecture is that *every*
theorem in the file generalizes verbatim by replacing the index type `Fin n` with
an arbitrary `Fintype ι`, because none of the proofs use the order structure of
`Fin n`. The key insight is that `ntkGramMatrix`, `gdUpdateMat`, and the decay
engine are already index-agnostic, so the block NTK is *still* a Gram matrix and
hence PSD with the identical contraction theory. Why now? Re-stating the
definitions with `variable {ι : Type*} [Fintype ι] [DecidableEq ι]` is a
near-mechanical refactor that would immediately yield the multi-output convergence
theorem and stress-test the robustness of the proof architecture — a concrete,
falsifiable claim (it fails if any proof secretly used `Fin n`-specific lemmas).

### 5. RKHS interpolation and the representer theorem

The NTK induces a reproducing-kernel Hilbert space, and the infinite-width limit
states that gradient descent converges to the minimum-norm interpolant. The
falsifiable milestone is the *finite-dimensional representer theorem*: the GD limit
lies in `span{K(x_i, ·)}`. The key insight is that this is orthogonal projection in
disguise — the optimum is the projection of any interpolant onto the span of kernel
sections, which Mathlib's `orthogonalProjection` already supplies. Why now? The
positivity and symmetry results give a bona fide inner product on the column space
of `K`, so the representer theorem can be stated and proved at the matrix level
(`Submodule.span` + `orthogonalProjection`) *before* the heavier task of
constructing the full RKHS completion — a self-contained, world-class next step.
