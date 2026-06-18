# Summary of changes for run 944bf9b7-a9f9-461d-b53e-04342553d01a
## Completed: Diffusion Models as SDEs — Lean 4 Formalization

### Deliverables

**`Catalog/Physics/DiffusionSDE.lean`** — 185 lines, 5 theorems, 0 sorry, clean build.

**`FUTURE_DIRECTIONS.md`** — 5 research directions with synthesis and results summary.

### Theorem Declarations

| # | Name | Status | Statement |
|---|------|--------|-----------|
| 1 | `ou_mean_tendsto_zero` | **proved** | OU mean m₀·exp(-θt) → 0 as t → ∞ for θ > 0 |
| 2 | `ou_variance_tendsto_stationary` | **proved** | OU variance converges to σ²/(2θ) universally |
| 3 | `kl_div_gaussian_self_eq_zero` | **proved** | KL(N(m,v) ‖ N(m,v)) = 0 |
| 4 | `kl_div_gaussian_nonneg` | **proved** | KL(N(m₁,v₁) ‖ N(m₂,v₂)) ≥ 0 (Gibbs' inequality) |
| 5 | `ou_variance_pos` | **proved** | OU variance stays positive for v₀ > 0, σ² > 0, θ > 0, t ≥ 0 |

### Approach

Rather than axiomatizing Itô calculus (absent from Mathlib), we formalize the **deterministic signatures** of the Ornstein-Uhlenbeck process — mean decay, variance convergence, and KL divergence properties — which are the quantities that actually matter for diffusion model convergence theory.

Key definitions:
- `ouMean m₀ θ t = m₀ · exp(-θt)` — mean evolution
- `ouVariance v₀ σsq θ t` — variance evolution (explicit solution to the Riccati ODE)
- `klDivGaussian m₁ v₁ m₂ v₂` — KL divergence between univariate Gaussians

The KL nonnegativity proof (Theorem 4) is the most technically interesting: it reduces to the fundamental inequality log(x) ≤ x − 1 via `Real.log_le_sub_one_of_pos`, with `nlinarith` closing the algebraic remainder.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound) — verified via `#print axioms`.