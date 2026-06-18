# Future Directions: NTK Spectral Convergence

This cycle extended the Neural Tangent Kernel programme (`NTKCore`, `NTKSpectral`)
from *per-eigenmode* statements to the *full training trajectory*. The new file
`NTKSpectralConvergence.lean` establishes:

- linearity of the gradient-descent residual map (`gdResidual_smul`,
  `gdResidual_add`, `gdResidual_sum`);
- the **closed-form spectral solution** `gdResidual_sum_eigenbasis`:
  `u_t = Σ cᵢ (1 − ηλᵢ)ᵗ vᵢ` for any eigen-expansion `u₀ = Σ cᵢ vᵢ`;
- a **spectrum-driven decay bound** `gdResidual_eigenbasis_decay` that derives
  geometric decay directly from explicit per-eigenvalue bounds `|1 − ηλᵢ| ≤ c`,
  with *no* opaque `IsContractive` hypothesis;
- the asymptotics: convergence to zero under contractivity
  (`gdResidual_tendsto_zero`, `gdResidual_norm_tendsto_zero`), stable-mode decay
  (`gdResidual_eigenvector_tendsto_zero`), and the matching boundary result that
  an unstable mode diverges (`gdResidual_eigenvector_divergence`).

The following directions are concrete, falsifiable next steps.

## 1. From the sup-norm to the Euclidean operator norm: spectral contractivity

The current `gdResidual_eigenbasis_decay` bounds the residual by
`cᵗ · Σ|cᵢ|‖vᵢ‖`, where the `Σ|cᵢ|‖vᵢ‖` factor is an `ℓ¹`-style overhead coming
from the triangle inequality and the ambient **sup norm** on `Fin n → ℝ`. The
conjecture is that on `EuclideanSpace ℝ (Fin n)`, where `K` is symmetric with an
orthonormal eigenbasis, the clean operator bound
`‖(I − ηK)u‖₂ ≤ (maxᵢ|1 − ηλᵢ|)·‖u‖₂` holds, i.e. `K` *itself* satisfies
`IsContractive` with the spectral constant — closing the loop with
`gdResidual_geometric_decay` exactly.

The key insight is that the `Σ|cᵢ|` overhead is an artifact of the sup norm, not
of the dynamics: in the `ℓ²` geometry the eigenvectors are orthogonal, so
Parseval turns the sum of squared modes into an exact identity and the worst-case
eigenvalue controls the whole operator with no overhead. Why now? Mathlib already
has `Matrix.IsHermitian.spectral_theorem` and the `EuclideanSpace` API, so the
orthonormal eigenbasis and Parseval identity are available off the shelf; the only
new work is transporting `gdResidual` across the `Fin n → ℝ ≃ EuclideanSpace`
isometry.

## 2. Optimal-rate convergence theorem with the condition-number constant

`NTKSpectral.optimalRate_contraction` / `optimalRate_minimizes` already pin down
the optimal step `η* = 2/(μ+L)` and its contraction `(L−μ)/(L+μ)` for the two
extreme modes. The conjecture is a single capstone theorem: for a PSD kernel with
spectrum in `[μ, L]` (`0 < μ ≤ L`), running gradient descent at `η*` yields
`‖u_t‖ ≤ ((L−μ)/(L+μ))ᵗ ‖u₀‖`, and *no* fixed step size achieves a smaller
asymptotic rate — an exact min–max characterisation of NTK training speed by the
condition number `κ = L/μ`.

The key insight is that the worst-case contraction over a whole interval `[μ, L]`
is always attained at the two endpoints, because `λ ↦ |1 − ηλ|` is convex, so the
interval problem reduces to the already-solved two-point problem. Why now? The
two-point optimum is proven in `NTKSpectral`; combining it with Direction 1's
operator-norm bound and `gdResidual_eigenbasis_decay` would assemble the full
statement from pieces that already exist in the catalog.

## 3. Quantitative stopping-time / iteration-complexity bound

Convergence (`gdResidual_tendsto_zero`) is qualitative. The conjecture is an
explicit iteration count: under `IsContractive K η c`, for every tolerance
`ε > 0` the residual satisfies `‖u_t‖ ≤ ε` for all
`t ≥ ⌈log(‖u₀‖/ε) / log(1/c)⌉`, and this `O(log(1/ε)/log(1/c))` bound is tight up
to rounding for a single eigenmode.

The key insight is that geometric decay is *exactly* exponential, so inverting the
bound `cᵗ‖u₀‖ ≤ ε` is a logarithm computation rather than an asymptotic estimate —
the stopping time is a closed form, not just a limit. Why now? The decay estimate
`gdResidual_geometric_decay` is already in `NTKCore`, and Mathlib's
`Real.log`/`Real.rpow` monotonicity lemmas make inverting `cᵗ ≤ ε/‖u₀‖`
mechanical; this upgrades a `Tendsto` into a usable complexity guarantee.

## 4. Lazy-regime robustness of the closed-form solution

`NTKConvergence.ntk_single_step_perturbation` measures one-step kernel
perturbation. The conjecture is a trajectory-level robustness theorem built on the
closed form: if `K̃ = K + E` with `‖E‖` small, then the residual computed with the
perturbed kernel stays within `t · η · ‖E‖ · ‖u₀‖` of the closed-form solution
`Σ cᵢ(1 − ηλᵢ)ᵗ vᵢ` for the exact kernel — a rigorous statement of "the kernel is
approximately constant during lazy training."

The key insight is that the per-step perturbation error accumulates only
*linearly* in `t` because each step is a contraction-or-near-contraction, so the
errors do not compound geometrically — exactly the mechanism that makes the
infinite-width lazy regime well-behaved. Why now? The single-step bound is already
proven, and the new linearity lemmas (`gdResidual_add`, `gdResidual_smul`) let one
telescope the global error into a sum of single-step errors that the existing
lemma controls.

## 5. Spectral bias: mode-wise convergence ordering

The closed form `u_t = Σ cᵢ(1 − ηλᵢ)ᵗ vᵢ` predicts that, for `0 < ηλᵢ < 1`,
larger eigenvalues decay faster. The conjecture formalises *spectral bias*: order
the eigenvalues `λ₁ ≥ λ₂ ≥ … `; then for the optimal small step the mode
coefficients satisfy `|cᵢ(1 − ηλᵢ)ᵗ|` decaying in a strictly faster geometric rate
for larger `λᵢ`, so high-eigenvalue ("low-frequency") components are fit first.

The key insight is that the per-mode rate `|1 − ηλ|` is *monotone* in `λ` on the
stable side `ηλ < 1`, so the closed form turns the qualitative "neural networks
learn low frequencies first" folklore into a precise, provable ordering of decay
exponents. Why now? `gdResidual_sum_eigenbasis` gives the exact mode coefficients,
and `gdResidual_eigenvector_norm` gives their exact magnitudes, so the ordering is
a direct comparison of `|1 − ηλᵢ|ᵗ` across modes — no new analytic machinery is
required, only the monotonicity already implicit in `eigenvalue_stable_iff`.
