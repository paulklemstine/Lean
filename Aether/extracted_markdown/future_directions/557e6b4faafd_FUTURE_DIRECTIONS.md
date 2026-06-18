# Future Directions — ML Loss Landscape: Critical Points and Saddle Points

## Synthesis

This cycle formalized the geometry of critical points of the **local quadratic
model** of a loss landscape. Near a critical point `x*`, a smooth loss is, to
second order, `L(x* + h) ≈ L(x*) + ½⟨h, ∇²L(x*) h⟩`, so the landscape shape is
controlled by the Hessian quadratic form `Q(h) = ⟨h, A h⟩`. Working over an
arbitrary real inner-product space, we proved the full **strict-saddle
dichotomy** for this model and the **deterministic escape dynamics** of gradient
descent. The structural insight that emerged is that the entire theory reduces to
two elementary moves: (1) a *spectral-to-geometric* bridge turning a negative
eigenvalue into a strict descent direction (`neg_eigenvalue_descent`), and (2) a
*one-parameter probe* `t ↦ t·v` that transports the local-minimum inequality to
the punctured neighborhood filter `𝓝[≠]0`, where it must fail because `Q(t·v) =
t²·Q(v) < 0`. This probe argument is exactly the second-order necessary
condition, and its contrapositive gives the clean iff `local_min ⇔ Hessian PSD`.

On the dynamics side, restricting gradient descent to a negative-curvature
eigencoordinate linearizes the update to multiplication by `r = 1 − η·lam > 1`,
giving a closed-form orbit `a_k = r^k·c0` whose magnitude diverges geometrically.
This is the sharpest, fully deterministic form of "SGD escapes strict saddles in
polynomial time": escape from any radius-`M` ball happens in `O(log M)` steps.

What did *not* yet get formalized: the global/probabilistic statements — "almost
all critical points are saddles" (a genericity/measure statement on the Hessian
spectrum) and the *stochastic* escape guarantee with noise. These are the natural
next targets, and the proved dichotomy makes them precise: saddles are exactly
the non-PSD Hessian case, so "almost all" becomes "PSD is nongeneric." The
quadratic model is the correct unit of progress; lifting from it to genuine
`C²` losses via Taylor's theorem is the main analytic gap.

## Results Summary

- `quadForm_smul`: proved — the Hessian model is homogeneous of degree 2,
  `Q(t·v) = t²·Q(v)`; the engine behind the one-parameter probe.
- `neg_eigenvalue_descent`: proved — a negative Hessian eigenvalue yields a strict
  descent direction `Q(v) < 0`; the spectral-to-geometric bridge.
- `strict_saddle_not_local_min`: proved — any direction with `Q(v) < 0` rules out
  a local minimum at the critical point (the core strict-saddle property).
- `neg_eigenvalue_not_local_min`: proved — a critical point whose Hessian has a
  negative eigenvalue is never a local minimum (it is a saddle).
- `local_min_implies_hessian_psd`: proved — second-order necessary condition: at a
  local minimum the Hessian quadratic form is positive semidefinite.
- `local_min_iff_hessian_psd`: proved — exact dichotomy: `0` is a local minimum of
  the quadratic model iff the Hessian form is PSD.
- `gradient_descent_escapes_saddle`: proved — gradient descent on a strict saddle
  escapes geometrically fast; the iterate magnitude diverges to `∞`.

## Research Directions

### Direction 1: From the quadratic model to genuine C² losses
**Hypothesis**: For a `C²` loss `L : E → ℝ` with critical point `x*` (i.e.
`fderiv ℝ L x* = 0`) whose Hessian `∇²L(x*)` has a strictly negative eigenvalue,
`x*` is not a local minimum of `L` itself (not merely of its quadratic model).
**Test**: Prove it by combining Taylor's theorem (`HasFTaylorSeriesUpTo` /
`taylor_mean_remainder` analogues in `E`) with `strict_saddle_not_local_min`: the
remainder is `o(‖h‖²)`, which cannot overturn the `t²·Q(v) < 0` leading term
along the eigendirection.
**Why now**: We already have the exact leading-order obstruction; only the
remainder bound is missing.
**If true**: The strict-saddle property holds for real losses, not just models.
**If false**: It would reveal a regime where higher-order terms rescue a
degenerate saddle — i.e., the Hessian test is genuinely incomplete.

### Direction 2: Genericity — "almost all critical points are saddles"
**Hypothesis**: In the space of symmetric Hessians (`Matrix.IsHermitian` /
self-adjoint operators), the PSD cone has empty interior complement structure
making "has a negative eigenvalue" both open and dense; hence PSD Hessians are
nongeneric, formalizing "almost all critical points are saddles."
**Test**: Show the set `{A : 0 < smallest eigenvalue or A non-PSD}` and prove the
non-PSD set is dense (perturb any PSD `A` by `−εI`). A measure-theoretic version
uses that the boundary `det = 0` is measure zero.
**Why now**: `local_min_iff_hessian_psd` reduces the slogan to a statement purely
about the Hessian spectrum, which is now the only object in play.
**If true**: Gives the precise sense of "overparameterized landscapes are saddle-
dominated."
**If false**: Would identify a structured family of losses where minima are
generic, contradicting the overparameterization folklore.

### Direction 3: Stochastic escape with explicit time bound
**Hypothesis**: For noisy gradient descent `a_{k+1} = (1−η·lam)·a_k + ξ_k` along a
negative-curvature coordinate (`lam < 0`), the expected escape time from a
radius-`δ` ball is `O(log(1/δ))` even when started exactly at the saddle (`a_0 =
0`), provided the noise has positive variance.
**Test**: Track `E[a_k²] = (1−η·lam)^{2k}·a_0² + σ²·Σ (1−η·lam)^{2j}` and show it
crosses any threshold in logarithmically many steps.
**Why now**: The deterministic closed form `a_k = r^k·c0` already exhibits the
`r > 1` amplification; adding an independent-noise variance recursion is a small
step.
**If true**: Formal "escapes saddles in polynomial time" with noise, the headline
result of strict-saddle optimization theory.
**If false**: Would show noise can be anti-correlated with the unstable mode and
trap iterates — a counterexample to naive escape claims.

### Direction 4: Multi-eigenvalue escape rate is governed by the most negative mode
**Hypothesis**: For diagonal Hessian `diag(lam_1,…,lam_n)` with at least one
`lam_i < 0`, full-vector gradient descent `x_{k+1} = x_k − η·A·x_k` from generic
`x_0` escapes at rate `max_i (1 − η·lam_i)`, i.e., the most negative eigenvalue
dominates.
**Test**: Decompose into eigencoordinates (each evolving as in
`gradient_descent_escapes_saddle`) and prove `‖x_k‖ ≥ |a_k^{(i*)}| → ∞` for the
most-negative index `i*`, with rate tight.
**Why now**: Each coordinate is exactly the proved scalar recursion; the lift is a
finite max over independent modes.
**If true**: Quantifies the escape rate as a spectral quantity, linking back to
`neg_eigenvalue_descent`.
**If false**: Coordinate coupling (off-diagonal Hessian) changes the rate — a cue
to study non-normal `A` where transient growth differs from eigenvalues.

### Direction 5: Strict-saddle property for the loss of a linear network
**Hypothesis**: For the squared loss `L(W₁,W₂) = ‖W₂W₁X − Y‖²` of a two-layer
linear network, every critical point that is not a global minimum has an
indefinite Hessian (a strict saddle), so `neg_eigenvalue_not_local_min` applies at
each such point.
**Test**: Compute the Hessian of `L` at a non-optimal critical point and exhibit a
direction `v` with `Q(v) < 0` (e.g., a rank-increasing perturbation), then invoke
`strict_saddle_not_local_min`.
**Why now**: We have the abstract operator-level criterion; linear networks are
the simplest concrete loss where the Hessian is explicitly computable.
**If true**: A fully formal instance of "no spurious local minima" for a real ML
architecture, bridging this cycle's abstract theory to a named model.
**If false**: Would pinpoint a spurious local minimum in linear networks,
contradicting the Baldi–Hornik / Kawaguchi line and demanding a revised
hypothesis.
