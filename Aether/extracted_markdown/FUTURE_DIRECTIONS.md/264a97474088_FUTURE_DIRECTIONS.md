# Future Directions: NTK Spectral Convergence

## Synthesis

This cycle delivered `Catalog/MachineLearning/NTKSpectral.lean` from a cold start
(no prior `NTKCore` existed in the catalog). The file builds the spectral theory
of the Neural Tangent Kernel (NTK) that controls gradient-descent training in the
lazy / infinite-width regime, and it does so as a *single coherent chain*:

1. **Spectrum exists and is nonnegative.** The NTK Gram matrix `Θ = Jᵀ J` is
   positive semidefinite (`ntkGram_posSemidef`), and its quadratic form is exactly
   the squared feature-space norm `xᵀ Θ x = ‖J x‖²` (`ntk_quadratic_form`,
   `ntk_quadratic_form_nonneg`). No training mode is ever amplified.
2. **Dynamics diagonalize into scalar modes.** In the eigenbasis, the residual
   decouples into modes `c_{k+1} = (1 - η λ) c_k` with closed form
   `c k = (1 - η λ)ᵏ c₀` (`ntk_mode_decay`).
3. **Condition number sets the rate.** At the optimal learning rate
   `η* = 2/(λ_min+λ_max)`, every mode contracts by the condition-number factor
   `(λ_max - λ_min)/(λ_max + λ_min) = (κ-1)/(κ+1)` (`optimal_lr_contraction`).
4. **Convergence follows.** Contraction yields the explicit bound
   `|c k| ≤ ρᵏ |c₀|` (`geometric_convergence`) and, for `ρ < 1`, convergence to
   zero (`contraction_tendsto_zero`), assembled into the capstone
   `ntk_optimal_tendsto_zero`: a positive-definite NTK spectrum trained at the
   optimal rate drives every residual mode to `0`.

This connects two catalog domains that previously sat apart: the *linear-algebra*
machinery of positive-semidefinite Gram matrices (cf. spectral / self-adjoint
work such as `SpectralSelfAdjoint`) and the *optimization-dynamics* results on
network training (cf. `ResNetLipschitz`, `Accelerated`, `AsymptoticRate`). The
bridge is the observation that the convergence rate is a purely spectral
quantity — the kernel's condition number.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `ntkGram_posSemidef` | `Jᵀ J` is PSD | proved |
| `ntk_quadratic_form` | `xᵀ(JᵀJ)x = (Jx)·(Jx)` | proved |
| `ntk_quadratic_form_nonneg` | `0 ≤ xᵀ(JᵀJ)x` | proved |
| `ntk_mode_decay` | `c k = (1-ηλ)ᵏ c₀` | proved |
| `optimal_lr_contraction` | `|1-η*λ| ≤ (κ-1)/(κ+1)` | proved |
| `geometric_convergence` | `|c k| ≤ ρᵏ|c₀|` | proved |
| `contraction_tendsto_zero` | `ρ<1 ⇒ c→0` | proved |
| `ntk_optimal_tendsto_zero` | PD spectrum + optimal LR ⇒ `c→0` | proved |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. Full matrix recurrence convergence (not just per-mode)

Lift the scalar capstone to the genuine matrix update
`r_{k+1} = (I - η Θ) r_k` and prove `‖r_k‖ ≤ ρᵏ ‖r_0‖` directly from the
operator norm of `I - η Θ`, where `ρ = (κ-1)/(κ+1)`. The key insight is that
`optimal_lr_contraction` is exactly the eigenvalue-wise bound on the symmetric
operator `I - η* Θ`, so its operator norm equals the per-mode contraction —
spectral-radius equals operator-norm for symmetric matrices. **Why now?** We
already have PSD-ness and the scalar contraction; Mathlib's
`Matrix.PosSemidef` and self-adjoint spectral theorem make the
diagonalization step reachable, turning the matrix claim into the scalar one we
proved.

### 2. Smallest-eigenvalue lower bound from data separation

Prove a quantitative lower bound `λ_min(Θ) ≥ δ(X) > 0` in terms of a geometric
separation `δ` of the inputs (e.g. minimal pairwise gap), making the convergence
rate *explicit* and *non-vacuous*. The key insight is that `Θ = Jᵀ J` is strictly
positive definite exactly when the feature rows of `J` are linearly independent,
and independence can be certified by a Gram-determinant / diagonal-dominance
argument. **Why now?** `ntk_quadratic_form` already identifies the quadratic form
with `‖Jx‖²`, so `λ_min > 0 ⇔ J` injective — the missing piece is a clean
diagonal-dominance lemma, which is squarely in scope.

### 3. Continuous-time gradient flow energy decay

Formalize the ODE `ṙ(t) = -Θ r(t)` and prove the energy estimate
`‖r(t)‖² ≤ e^{-2 λ_min t} ‖r(0)‖²`. The key insight is that
`d/dt ‖r‖² = -2 rᵀ Θ r ≤ -2 λ_min ‖r‖²` by the PSD quadratic-form bound we
already established, so Grönwall's inequality closes it. **Why now?** The
discrete story is complete and the differential inequality reuses
`ntk_quadratic_form_nonneg` verbatim; the only new dependency is Mathlib's
Grönwall lemma, isolating the analytic content.

### 4. Misalignment slowdown: spectral decomposition of the initial residual

Quantify how the convergence speed depends on the *alignment* of the initial
residual `r_0` with the top eigenvectors: components along large eigenvalues
vanish fast, components along `λ_min` dominate the tail. The key insight is that
`ntk_mode_decay` already gives each component an independent rate `(1-ηλ_i)`, so
the total error is `Σ_i (1-ηλ_i)^{2k} ⟨r_0, v_i⟩²` — a spectral series whose tail
is governed by the worst-aligned mode. **Why now?** With the per-mode closed form
in hand, this is a Parseval/`Finset.sum` bookkeeping result, no new analytic
machinery required.

### 5. Width-dependent NTK concentration (bridge to randomness)

State and prove a deterministic surrogate of the NTK concentration phenomenon:
if two Gram matrices satisfy `‖Θ' - Θ‖ ≤ ε`, then their optimal contraction rates
differ by `O(ε / λ_min²)`, so a finite-width kernel close to the infinite-width
NTK converges at nearly the same rate. The key insight is that the contraction
rate is a Lipschitz function of the spectrum (eigenvalue perturbation, Weyl's
inequality), so kernel closeness transfers to rate closeness. **Why now?** It
combines this cycle's `optimal_lr_contraction` with standard matrix-perturbation
bounds, forming a concrete bridge to the catalog's probabilistic / concentration
material without needing a full random-matrix development.
