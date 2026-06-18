# Future Directions: Multi-Mode NTK Spectral Decay

The file `NTKSpectralDecay.lean` closes Research Direction #2 of the NTK
programme. It upgrades the *single-mode* spectral analysis of `NTKSpectral.lean`
to the **full residual**: a superposition of eigenmodes now decays geometrically
at the worst-case rate (`gdResidual_multimode_decay`), and that geometric rate is
turned into an explicit iteration-complexity budget through the condition number
(`optimalRate_iteration_complexity`) and a power-law spectrum
(`powerlaw_iteration_complexity`). The following directions extend this frontier.

## 1. Orthogonal eigenbasis and the *exact* energy identity

The current capstone, `gdResidual_multimode_decay`, bounds `‖u_t‖` by a sum of
mode magnitudes via the triangle inequality, with no orthogonality assumption.
When the eigenvectors are orthonormal this becomes an *equality* in energy:
`‖u_t‖² = Σ_k c_k² (1 - ηλ_k)^{2t}`. Formalizing this would refine the worst-case
geometric bound into the true per-mode energy spectrum, exposing the
"effective rank" of the trajectory at time `t`.

The key insight is that the residual map `u ↦ (I-ηK)^t u` is *self-adjoint and
diagonal* in the eigenbasis, so Parseval's identity (`Matrix.IsHermitian.spectral_theorem`
plus `EuclideanSpace` inner-product orthonormality) converts the norm of a sum of
orthogonal vectors into the sum of their squared norms — no cross terms survive.

Why now? `gdResidual_sum_eigenvectors` already gives the exact mode
decomposition `u_t = Σ_k c_k (1-ηλ_k)^t v_k`; the only missing ingredient is the
Pythagorean step, for which Mathlib's `orthonormal` and `inner_sum` API is
directly applicable. This is the natural strengthening of the file's best
theorem from an inequality to an identity.

## 2. The slowest mode dominates: matching lower bound on convergence

`gdResidual_multimode_decay` is an *upper* bound. The companion result is a
*lower* bound: the residual cannot decay faster than its slowest stable mode, so
`‖u_t‖ ≥ |c_{k*}| · |1 - ηλ_{k*}|^t · ‖v_{k*}‖` where `k*` indexes the eigenvalue
closest to the stability boundary. Together with Direction #1 this pins the
convergence rate to `Θ((1-ηλ_min)^t)`, proving the optimal learning rate of
`NTKSpectral.optimalRate_minimizes` is *rate-tight*, not merely worst-case
optimal.

The key insight is that for an orthogonal mode the projection of `u_t` onto the
single eigenvector `v_{k*}` already has norm `|c_{k*}|·|1-ηλ_{k*}|^t·‖v_{k*}‖`,
and a projection never increases the norm, giving the lower bound for free once
orthogonality (Direction #1) is in place.

Why now? `gdResidual_eigenvector_norm` (in `NTKSpectral.lean`) supplies the exact
single-mode norm law; the projection inequality `‖proj u‖ ≤ ‖u‖` is `norm_inner_le_norm`
/ `ContinuousLinearMap.norm_proj_le`. The upper bound being already formal makes
the two-sided sandwich the obvious next deliverable.

## 3. Effective dimension as the true complexity parameter

The iteration count in `optimalRate_iteration_complexity` scales with the global
condition number `κ = λ_max/λ_min`, which is pessimistic when only a few modes
carry the signal. The sharper parameter is the **effective dimension**
`d_eff(η) = Σ_k 1 / (1 - (1-ηλ_k)²)`, which counts modes weighted by how slowly
they converge. A theorem of the form "`‖u_t‖² ≤ ε` after `t = O(d_eff · log(1/ε))`
steps" would replace the crude `κ` by a spectrum-adaptive quantity.

The key insight is that `d_eff` is exactly the trace of the resolvent
`(I - (I-ηK)²)^{-1}` restricted to stable modes, so the energy identity of
Direction #1 lets one bound the time-integrated energy `Σ_t ‖u_t‖²` by `d_eff · ‖u_0‖²`
through a geometric-series-in-each-mode summation.

Why now? Direction #1 provides the energy identity that makes `d_eff` appear as a
sum of per-mode geometric series (`tsum_geometric_of_lt_one`), and the file's
power-law machinery (`powerlaw_condition_number`) gives a concrete spectrum on
which `d_eff ≪ κ`, demonstrating the improvement quantitatively.

## 4. Continuous-time gradient flow and the exponential decay law

The discrete dynamics `u_{t+1} = (I-ηK)u_t` has a continuous-time limit
`u'(τ) = -K u(τ)`, whose solution is `u(τ) = exp(-τK) u_0`, decaying like
`e^{-λ_k τ}` per mode. Formalizing the limit `(I - (τ/N)K)^N → exp(-τK)` as
`N → ∞` would connect the file's discrete-step theorems to the ODE picture and
remove the learning-rate stability constraint `ηλ < 2` entirely.

The key insight is that `(I - (τ/N)K)^N` is a matrix Lie-product approximation to
`exp(-τK)`, and on each eigenmode it reduces to the scalar limit
`(1 - τλ/N)^N → e^{-τλ}`, which is the classical `Real.tendsto_one_plus_div_pow_exp`
result already in Mathlib.

Why now? `gdResidual_sum_eigenvectors` diagonalizes the discrete flow exactly, so
the matrix limit reduces *modewise* to a one-dimensional real limit that Mathlib
already proves — turning a hard operator-convergence statement into a finite sum
of scalar limits.

## 5. Robustness: spectral decay under kernel perturbation

The whole analysis assumes a fixed kernel `K`. In finite-width networks the
kernel drifts to `K + Δ`. A perturbation theorem `‖u_t^{K+Δ} - u_t^{K}‖ ≤
t · η · ‖Δ‖_op · ρ^{t-1} · ‖u_0‖` (a discrete Grönwall estimate) would quantify
how much the multi-mode decay of Direction #3 degrades, bridging this file to
Research Direction #3 (lazy-training kernel perturbation) of the NTK programme.

The key insight is that the difference of two matrix powers telescopes,
`A^t - B^t = Σ_{j<t} A^j (A-B) B^{t-1-j}`, so a uniform contraction bound `ρ` on
both operators turns the telescoped sum into `t · ‖A-B‖_op · ρ^{t-1}` — a clean
discrete Grönwall inequality requiring only operator-norm submultiplicativity.

Why now? `gdResidual_eq_pow` (in `NTKCore.lean`) already expresses the trajectory
as a matrix power, and the multi-mode contraction constant `ρ` is now formalized
in `gdResidual_multimode_decay`. The telescoping identity is a finite-sum algebra
fact, making this the lowest-hanging bridge to the perturbation theory.
