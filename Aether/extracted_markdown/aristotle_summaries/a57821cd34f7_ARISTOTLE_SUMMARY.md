# Summary of changes for run 27b82040-b688-4d0c-a238-c69031ac735a
I extended the formalized diffusion-model noise-schedule theory with a new, fully proved (sorry-free) Lean file and a research roadmap.

## New Lean file: `Catalog/Pythagorean/DiffusionScheduleExtensions.lean`
Self-contained (imports only Mathlib; re-states the small base layer it builds on). It contains the following new, complete theorems — all verified to compile and to depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `univGaussianKL_same_var` — when two Gaussians share a variance σ²>0, their KL collapses to the pure quadratic `(μ₁-μ₂)²/(2σ²)`. (the variational core)
- `univGaussianKL_same_var_eq_zero_iff` — that shared-variance KL is `0` iff the means coincide.
- `ddpm_kl_eq_noise_mse` — the centerpiece: a DDPM reverse step's KL (variance fixed to the schedule value βt) equals the positively-weighted noise-prediction error `βt/(2·αt·(1-ᾱt))·(εθ-ε)²`. This is the exact algebraic identity underlying the DDPM noise-prediction training objective, proved via the √-collapse `Real.sq_sqrt`.
- `ddpm_kl_zero_iff` — that per-step KL vanishes iff the predicted noise equals the true noise (variational optimality of the reverse step).
- `diffusionAlphaBar_const` / `diffusionAlphaBar_const_ge` / `diffusionAlphaBar_const_le` / `diffusionAlphaBar_const_two_sided` — a two-sided exponential envelope `exp(-(c+c²)t) ≤ ᾱ_t ≤ exp(-c·t)` for the constant schedule on `0 ≤ c ≤ 1/2`. The lower envelope is the non-trivial part, proved by a mean-value-theorem / derivative-sign argument on `g(c)=log(1-c)+c+c²`.
- `continuousLimit_two_sided` — the continuous-time corollary `exp(-(β+β²/T)) ≤ ᾱ_T ≤ exp(-β)` for the schedule `β_i = β/T`, giving the quantitative `O(β²/T)` rate at which `ᾱ_T → exp(-β)`.
- `multiGaussianKL` with `multiGaussianKL_nonneg` and `multiGaussianKL_self` — the additive anisotropic (product) Gaussian KL, non-negative and vanishing on the diagonal.

Each main result carries a brief `-- !-- … -- !--` proof sketch and a docstring. The file builds cleanly (no errors, warnings, or `sorry`).

## `FUTURE_DIRECTIONS.md` (project root)
Five falsifiable research conjectures extending the above: (1) a closed-form separable ELBO from the noise-MSE identity; (2) monotone tightening of the constant-schedule envelope as T grows; (3) an SNR half-life threshold at cumulative noise `log 2`; (4) a KL-to-stationary-Gaussian decay rate in the `ᾱ_t ≤ 1/2` regime; (5) strict convexity (curvature `1/σ²`) of the reverse KL in the predicted mean. Each includes a "The key insight is…" statement, a "Why now?" justification, and a concrete falsifiable Lean test.

Note: the directions document points back to this work; direction (4) corrects the originally proposed unconditional bound, which fails as `ᾱ_t → 1`, by restricting to the `ᾱ_t ≤ 1/2` regime where it holds.