# Future Directions — ML Loss Landscape: Critical Points and Strict Saddles

## Synthesis

This cycle formalized the **strict saddle** picture of the loss landscape at a
critical point through its canonical local model: a quadratic form
`Q(x) = ½ xᵀ H x` whose Hessian `H` is the symmetric matrix of second
derivatives.  The central structural discovery is that the *entire* qualitative
behaviour at the critical point — minimum vs. saddle, escapable vs. trapped — is
carried by a single scalar: the sign of an eigenvalue of `H`.  A negative
eigenvalue `λ` with eigenvector `v` produces a one-dimensional *descent line*
(`quadraticLoss_neg_on_eigenline`), which immediately defeats local minimality
(`origin_not_localMin`) and, crucially, drives gradient descent to *diverge*
along that line.

The sharpest insight is a duality with the Neural Tangent Kernel theory already
in the catalog (`NTKCore`, `NTKSpectral`).  The *same* affine map `x ↦ x − ηHx`
that contracts every mode of a PSD kernel (NTK convergence,
`gdResidual_geometric_decay`) becomes an *expansion* the moment a single
eigenvalue turns negative: the per-step factor `r = 1 − ηλ` crosses from `r < 1`
to `r > 1`.  We made this quantitative — `gd_iterate_on_eigenline` gives the
closed form `(r^t c)•v`, `gd_norm_on_eigenline` its norm, and
`gd_escapes_strict_saddle` shows the iterate overshoots any radius in
logarithmically (hence polynomially) many steps.  The PSD boundary case
`psd_origin_global_min` proves the converse environment is genuinely trapping,
confirming that the negative-eigenvalue hypothesis is necessary rather than
cosmetic.

What we deliberately did *not* attempt: the measure-theoretic statement that
"almost all critical points are saddles," the multi-eigenvalue (non-eigenline)
escape dynamics, and stochastic (noisy) SGD escape.  The eigenline reduction was
the key simplification that made everything provable: it converts a multivariate
Hessian-curvature question into one-dimensional scalar dynamics.  The directions
below are exactly the places where that reduction must be relaxed.

## Results Summary

- `origin_is_critical`: proved — the origin is always a critical point of the quadratic model (`∇Q(0)=0`).
- `quadraticLoss_origin`: proved — the loss value at the critical point is the `0` baseline.
- `quadraticLoss_neg_on_eigenline`: proved — a negative Hessian eigenvalue yields a line of strictly decreasing loss (the strict saddle property).
- `origin_not_localMin`: proved — consequently the origin is not a local minimum; every neighbourhood contains a strictly lower point.
- `gdMap_on_eigenline`: proved — one GD step restricted to an eigenline is scalar multiplication by `1 − ηλ`.
- `gd_iterate_on_eigenline`: proved — closed form `gdIter = (r^t c)•v` for `r = 1 − ηλ` along an eigenline.
- `gd_norm_on_eigenline`: proved — the iterate norm equals `r^t · |c| · ‖v‖`, geometric growth when `r > 1`.
- `gd_escapes_strict_saddle`: proved — GD exceeds any target radius after finitely (logarithmically) many steps; polynomial-time saddle escape.
- `psd_origin_global_min`: proved — boundary case: a PSD Hessian makes the origin a global minimum (no escape direction).

## Research Directions

### Direction 1: Quantitative escape-time bound (explicit step count)
**Hypothesis**: With `r = 1 − ηλ > 1`, the first step `T` at which
`‖gdIter H η (c•v) T‖ ≥ R` satisfies `T ≤ ⌈log (R / (|c|‖v‖)) / log r⌉`, and this
bound is tight up to `+1`.
**Test**: Strengthen `gd_escapes_strict_saddle` from a pure existence statement to
one that exhibits an explicit `T` as a `Nat.clog`/`Real.log` expression and proves
the inequality, plus a matching lower bound on the minimal escape time.
**Why now**: `gd_norm_on_eigenline` already gives the *exact* norm `r^t·|c|·‖v‖`,
so the escape time is literally a logarithm inversion — only the integer-ceiling
bookkeeping remains.
**If true**: Upgrades "polynomial time" to a sharp `Θ(log R)` rate, the honest
quantitative form of the strict-saddle escape theorem.
**If false**: Would reveal that integer rounding or the `≥` vs `>` boundary makes
the naive logarithmic count off by more than a constant — a subtlety worth
documenting.

### Direction 2: Escape from a general (non-eigenvector) initialization
**Hypothesis**: If `H` is symmetric with *some* negative eigenvalue and the start
point `x₀` has nonzero projection onto the corresponding eigenspace, then
`‖gdIter H η x₀ t‖ → ∞`; the projection onto the most-negative eigenmode
eventually dominates.
**Test**: Diagonalize `H` via `Matrix.IsHermitian.spectral_theorem`, decompose
`x₀` in the eigenbasis, apply `gd_iterate_on_eigenline` coordinate-wise, and show
the largest-`r` term dominates the norm.
**Why now**: `gd_iterate_on_eigenline` already solves each eigen-coordinate
exactly; the only new ingredient is the orthogonal decomposition, which Mathlib's
spectral theorem supplies.
**If true**: Removes the artificial "start exactly on the eigenline" hypothesis,
giving escape from almost every initialization (full Lebesgue-a.e. statement).
**If false**: Pinpoints a measure-zero stable manifold (the orthogonal complement
of the unstable eigenspace) where GD does *not* escape — itself the content of the
stable-manifold theorem.

### Direction 3: The stable manifold is measure zero ("almost all → saddle escape")
**Hypothesis**: The set of initializations from which gradient descent on a
quadratic with an indefinite Hessian fails to escape is contained in a proper
linear subspace, hence has Lebesgue measure zero.
**Test**: Identify the non-escape set with the span of the non-negative
eigenspaces, show it is a proper subspace under the negative-eigenvalue
hypothesis, and invoke `MeasureTheory` measure-zero-of-proper-subspace results.
**Why now**: Direction 2 supplies the precise characterization of the non-escape
set as an eigenspace; turning "proper subspace" into "measure zero" is a packaged
Mathlib fact.
**If true**: Delivers the headline claim — *almost all* trajectories escape strict
saddles — in fully formal measure-theoretic form.
**If false**: Forces re-examination of degenerate spectra (e.g. `λ = 0`
directions), exposing where the strict-saddle assumption `λ < 0` (not `≤ 0`) is
load-bearing.

### Direction 4: Strict saddle property for non-quadratic losses via the Hessian
**Hypothesis**: For a `C²` loss `L : ℝⁿ → ℝ` with a critical point `p`
(`fderiv L p = 0`) whose Hessian `fderiv (fderiv L) p` has a negative eigenvalue,
`p` is not a local minimum.
**Test**: Use the second-order Taylor expansion (`Mathlib`'s
`taylor`/`HasFDerivAt` second-order remainder) to reduce to the quadratic case
`quadraticLoss_neg_on_eigenline` along the negative-curvature direction, absorbing
the `o(‖x−p‖²)` remainder.
**Why now**: The quadratic descent line is already proved; Taylor's theorem turns
the genuine loss into "quadratic + lower-order error," which is exactly the regime
where the strict inequality survives for small `t`.
**If true**: Lifts the entire strict-saddle story from quadratics to arbitrary
smooth losses — the form actually relevant to neural networks.
**If false**: Would indicate the second-order remainder can overwhelm the
quadratic descent (e.g. flat/degenerate directions), marking the boundary of the
second-order saddle test.

### Direction 5: Noisy (stochastic) escape and the saddle-vs-minimum dichotomy
**Hypothesis**: Perturbed gradient descent `x_{t+1} = x_t − η H x_t + ξ_t` with
bounded isotropic noise `ξ_t` escapes a strict saddle with high probability even
when started *on* the stable manifold, because noise injects nonzero projection
onto the unstable eigenmode.
**Test**: Model `ξ_t` as a fixed perturbation with guaranteed nonzero unstable
component; show the unstable coordinate still grows like `r^t` plus a noise term,
and bound the failure probability under a simple noise model.
**Why now**: The deterministic eigenline growth `r^t` from `gd_norm_on_eigenline`
is the dominant term; noise only needs to seed it, so the analysis reduces to the
proved geometric growth plus a perturbation estimate.
**If true**: Explains why *stochastic* GD escapes saddles that deterministic GD
can get stuck on — the practically important phenomenon.
**If false**: Would show the noise model is too weak to guarantee escape,
clarifying exactly how much (and what kind of) stochasticity SGD needs.
