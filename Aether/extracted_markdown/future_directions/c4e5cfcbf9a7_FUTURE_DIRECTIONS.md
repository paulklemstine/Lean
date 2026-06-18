# Future Directions — Hodge–Laplacian Message Passing, Constructive Deep-Limit Cycle

## Synthesis

Three earlier cycles built the spectral-depth picture of Hodge–Laplacian message
passing in layers. `HodgeSpectralThreshold` established the dimension-free
harmonic backbone (`harmonic_iff`, the Hodge vanishing principle) and geometric
suppression of non-harmonic modes. `HodgeMessagePassingConvergence` upgraded
energy decay to convergence, deriving the per-layer contraction factor
`1 - αμ(2 - αλ)` and proving the spectral step `α = 1/λ` optimal with rate
`1 - μ/λ`. `HodgeDeepLimit` then proved that, with the *honest* residual-subspace
contraction, deep message passing converges in norm to the cohomology projector,
and gave an explicit logarithm-free stopping rule `criticalDepth` via a Bernoulli
bound.

This cycle (`HodgeDeepLimitConstructive`) closes those threads into four
operational guarantees that the prior files set up but never assembled:

1. **Self-consistency** — the cohomology projection `P x = (ker L).starProjection x`
   is an *exact* fixed point of every layer at every depth
   (`mpStep_iterate_starProjection_fixed`): the deep limit is a genuine
   equilibrium, not merely an accumulation point.
2. **A limit-free, closed-form error bound** — at the *computable* depth
   `criticalDepth ρ ⟪r,r⟫ ε`, the energy gap to cohomology is `≤ ε`
   (`mpStep_energy_bound_at_criticalDepth`), with no limits and no existentials.
3. **End-to-end spectral convergence** — from the raw Rayleigh bounds alone, the
   optimal step `α = 1/λ` drives deep message passing to the projector at the sharp
   rate `1 - μ/λ` (`mpStep_spectral_deep_limit`).
4. **Uniqueness** — any norm-limit of the depth sequence *must* be the projector
   (`mpStep_deep_limit_unique`): the canonical object the network computes is
   well-defined.

## Results Summary

| Theorem | Statement | Depends on (catalog) |
|---|---|---|
| `mpStep_iterate_starProjection_fixed` | `Tᵏ (P x) = P x` for all depths `k` | `mpStep_iterate_harmonic_fixed` |
| `mpStep_energy_bound_at_criticalDepth` | energy gap `≤ ε` at explicit depth | `mpStep_dist_to_harmonic_bound`, `criticalDepth_energy_bound` |
| `mpStep_spectral_deep_limit` | `Tᵏ x → P x` at `α = 1/λ`, rate `1 - μ/λ` | `mpStep_contraction`, `contraction_factor_at_optimal`, `mpStep_deep_limit_eq_cohomology_projection` |
| `mpStep_deep_limit_unique` | the deep limit is unique | `mpStep_deep_limit_eq_cohomology_projection` |

All four are proved `sorry`-free and depend only on `propext`,
`Classical.choice`, and `Quot.sound`.

## Research Directions

### 1. Operator-level deep limit: the iterates converge to the projector *as operators*

The current `mpStep_spectral_deep_limit` is pointwise — `Tᵏ x → P x` for each fixed
input `x`. In finite dimension this should upgrade to convergence in operator norm:
`‖Tᵏ - P‖ → 0`, where `P = (ker L).starProjection` regarded as a continuous linear
map. **The key insight is** that the residual subspace `(ker L)ᗮ` is `T`-invariant
(already proved as `mpStep_iterate_mem_orthogonal`) and finite-dimensional, so the
restriction `T|_{(ker L)ᗮ}` is a genuine strict contraction with a *uniform*
operator-norm rate `√ρ`, and `Tᵏ = P ⊕ (T|_{(ker L)ᗮ})ᵏ` under the orthogonal
splitting `E = ker L ⊕ (ker L)ᗮ`. **Why now?** We have already isolated the exact
fixed point (direction-0 of this cycle) and the invariant complement; the only
missing piece is packaging the pointwise rate into a single spectral-radius
estimate, which `Module.End` and `ContinuousLinearMap.opNorm` make routine. This is
falsifiable: exhibit any symmetric PSD `L` and step `α` where `Tᵏ x → P x` for every
`x` but `‖Tᵏ - P‖ ↛ 0` would refute it (impossible in finite dimension, but the
conjecture pins down exactly where finite-dimensionality is load-bearing).

### 2. Optimality of the spectral step is *strict*, and quantifiably so

`contraction_factor_optimal` shows `α = 1/λ` minimizes the contraction factor, but
only as a non-strict inequality. The conjecture: the gap is the perfect square
`(factor at α) − (factor at 1/λ) = μ·(αλ − 1)²/λ`, so any `α ≠ 1/λ` is strictly
worse, and the depth penalty for using `α = (1±δ)/λ` is exactly
`log(1/(1−μ/λ + μδ²λ)) / log(1/(1−μ/λ))`. **The key insight is** that the entire
suboptimality is captured by `sq_nonneg (αλ − 1)`, which already appears in the
proof of `contraction_factor_optimal` as a one-line `nlinarith` witness — promoting
`≤` to `<` for `α ≠ 1/λ` is a strict-positivity refinement of the same square.
**Why now?** The square is already in hand; turning it into a *quantitative* depth-
penalty theorem connects the spectral theory to the constructive `criticalDepth`
bound and gives the first end-to-end statement about the *cost* of a mistuned step.
Falsifiable: a numerical sweep finding any `α ≠ 1/λ` matching the `1/λ` depth would
break it.

### 3. Robustness of the deep limit to a perturbed Laplacian

Real simplicial complexes are noisy: one observes `L̃ = L + E` with `‖E‖` small.
Conjecture: the deep limit is Lipschitz-stable in the perturbation, i.e.
`‖P_{L̃} − P_L‖ ≤ C·‖E‖/gap`, where `gap = μ` is the spectral gap and `P_L` is the
cohomology projector of `L`. **The key insight is** that the harmonic subspace is a
*spectral* object — the kernel is the eigenspace at `0`, separated from the rest of
the spectrum by the gap `μ` — so Davis–Kahan-type `sin Θ` perturbation bounds apply,
and the message-passing iterates inherit the projector's stability because they
converge *to* it uniformly (direction 1). **Why now?** This cycle just proved the
deep limit *is* the projector and is *unique*; stability of a uniquely-defined
spectral projector under perturbation is the natural next invariant, and it is the
property that makes the whole "deep message passing computes topology" story usable
on empirical data. Falsifiable: a perturbation collapsing the gap (`μ → 0`) should
make the bound blow up, and any example with bounded `1/μ` yet discontinuous `P`
would refute it.

### 4. A two-sided critical depth: the explicit bound is also a lower bound

`criticalDepth` is currently a *sufficient* depth (Bernoulli upper bound on `ρᵏ`).
Conjecture: it is tight up to a universal constant — there exists `c > 0` such that
*no* depth below `c · criticalDepth ρ R ε` can guarantee energy `≤ ε` for all
residuals of energy `R`, because the worst-case residual (the bottom eigenvector of
`L|_{(ker L)ᗮ}`) decays at *exactly* rate `ρ`. **The key insight is** that the
geometric bound `ρᵏ R` is achieved with equality on a single eigenmode, so the
Bernoulli slack is only in converting `ρᵏ ≤ 1/(1 + k(1−ρ)/ρ)`, which is tight to
within a factor of `log(1/ρ)/(1−ρ) → 1` as `ρ → 1`. **Why now?** We have the
explicit upper bound and the exact eigenmode dynamics from `mode_decay` in
`HodgeSpectralThreshold`; pairing them yields the first *matching lower bound* on the
depth of a message-passing network, a genuine complexity statement. Falsifiable:
construct a single `L` and residual where energy `≤ ε` is reached strictly faster
than `c · criticalDepth` for every `c > 0`.

### 5. Beyond gradient layers: momentum/Chebyshev acceleration of the deep limit

The layer `T = 1 − αL` is plain gradient descent; its rate `1 − μ/λ` is governed by
the condition number `λ/μ`. Conjecture: a two-term recurrence
`x_{k+1} = (1 − αL)x_k + β(x_k − x_{k−1})` (heavy-ball / Chebyshev message passing)
converges to the *same* cohomology projector but with the accelerated rate
`1 − √(μ/λ)`, a quadratic improvement in the condition number, while still fixing
the harmonic subspace exactly. **The key insight is** that momentum does not touch
`ker L` — harmonic vectors are fixed points of *both* `T` and the identity, so the
two-term recurrence leaves them invariant — and on the invariant complement
`(ker L)ᗮ` it reduces to the classical Chebyshev iteration whose optimal rate is the
square root of the gradient rate. **Why now?** This cycle has fully characterized the
gradient deep limit (fixed point, rate, uniqueness, explicit depth); the acceleration
question is the obvious frontier, and Mathlib's `Polynomial.Chebyshev` plus the
existing `mpStep` linear-operator scaffolding make the harmonic-preservation half
immediate. Falsifiable: any momentum schedule that perturbs the harmonic output
(`P x` no longer fixed) or fails to beat `1 − μ/λ` on a well-conditioned `L` would
refute it.
