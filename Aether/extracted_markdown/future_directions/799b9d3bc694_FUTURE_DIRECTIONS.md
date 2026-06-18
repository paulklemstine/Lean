# Future Directions — Hodge–Laplacian Message Passing, Deep-Limit Cycle

## Synthesis

The previous cycles established two layers of the spectral-depth picture for
Hodge-Laplacian message passing. `HodgeSpectralThreshold.lean` proved that the
harmonic (cohomology) subspace is an exact, depth-invariant fixed set and that every
non-harmonic mode is geometrically suppressed (`depth_threshold`).
`HodgeMessagePassingConvergence.lean` upgraded *energy decay* to a *convergence-below-ε*
statement (`mpStep_converges_to_harmonic`) and identified the optimal spectral step.
`HodgeThreeWayDecomposition.lean` / `HodgeFullDecomposition.lean` supplied the static
algebraic backbone (`V = coexact ⊕ exact ⊕ harmonic`, the discrete Hodge theorem).

This cycle (`HodgeDeepLimit.lean`) closes the gap between *"the residual gets small"*
and *"the network computes a canonical object"*. Its results are:

1. **A corrected, honest contraction hypothesis.** The prior cycle's contraction
   "for all `x`" is, with rate `ρ < 1`, only satisfiable when `ker L = 0` — it secretly
   trivializes the very harmonics it is meant to preserve. We replace it with a strict
   contraction *only on the residual subspace* `(ker L)ᗮ`, prove that subspace is
   invariant under one layer for symmetric `L` (`mpStep_mem_orthogonal`,
   `mpStep_iterate_mem_orthogonal`), and recover the geometric `ρᵏ` residual decay
   (`mpStep_iterate_contraction_orthogonal`).

2. **Vector convergence to the cohomology projection.** Depth-`k` message passing on any
   input converges *in norm* (not merely in energy) to the orthogonal projection onto
   the harmonic subspace (`mpStep_iterate_tendsto_harmonic`,
   `mpStep_deep_limit_eq_cohomology_projection`). Deep Hodge message passing **is** the
   cohomology projector. The bridge `hodge_deep_limit_is_harmonic_projection`
   instantiates this at the abstract combinatorial Hodge Laplacian `Δ = up + down`.

3. **A constructive, logarithm-free critical depth.** The non-constructive `∃ K` is
   replaced by an explicit closed-form stopping rule `criticalDepth ρ R ε`, proved
   correct (`criticalDepth_energy_bound`) via a Bernoulli bound — no logarithms,
   rational arithmetic only.

## Results Summary

| Theorem | Statement |
|---|---|
| `mpStep_mem_orthogonal` | `(ker L)ᗮ` is invariant under one layer `T = 1 - αL` (symmetric `L`). |
| `mpStep_iterate_mem_orthogonal` | Residual subspace invariance persists at every depth. |
| `mpStep_iterate_contraction_orthogonal` | Residual energy decays as `ρᵏ ⟪r,r⟫` under subspace contraction. |
| `mpStep_iterate_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm for `L h = 0`, `r ∈ (ker L)ᗮ`. |
| `mpStep_deep_limit_eq_cohomology_projection` | In finite dimension, `Tᵏ x → πₖₑᵣ ₗ x` for every input `x`. |
| `criticalDepth_energy_bound` | The explicit log-free depth drives residual energy below `ε`. |
| `hodge_deep_limit_is_harmonic_projection` | Deep simplicial message passing at `Δ = up + down` computes the harmonic projection. |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The deep limit is a *bona fide* idempotent: `T^∞ = πₖₑᵣ ₗ` as an operator identity

We proved pointwise convergence `Tᵏ x → π x`. The next step is to promote this to an
operator-norm statement: under a uniform spectral gap on `(ker L)ᗮ`, the iterates `Tᵏ`
converge in operator norm to the orthogonal projection `π`, and the limit satisfies the
idempotent law `π² = π`, `π = π*`. The key insight is that the residual subspace is not
just invariant but a *uniform* `ρ`-contraction, so `‖Tᵏ − π‖ ≤ ρᵏ`; the projector
emerges as a genuine Banach-space limit of the layer monoid, not merely as a target of
orbits. Why now? `mpStep_iterate_contraction_orthogonal` already gives the per-orbit
`ρᵏ` bound uniformly in `r`; turning a uniform pointwise bound into an operator-norm
bound is exactly `ContinuousLinearMap.opNorm_le_bound` over a finite-dimensional space,
so the analytic infrastructure is now in place.

### 2. From assumed gap to *derived* gap: existence of `ρ < 1` from `μ > 0`

Currently the contraction rate `ρ` is a hypothesis. For symmetric PSD `L` with smallest
nonzero Rayleigh value `μ > 0` and largest `λ`, the spectral step `α = 1/λ` should
*produce* a valid `ρ = 1 - μ/λ < 1` on `(ker L)ᗮ`, discharging `hcontract` entirely.
The key insight is that `contraction_factor_at_optimal` (previous cycle) already pins the
factor to `1 - μ/λ`; what remains is to show the Rayleigh lower bound `μ⟪x,x⟫ ≤ ⟪x,Lx⟫`
holds on `(ker L)ᗮ` for finite-dimensional symmetric PSD `L`, i.e. that the smallest
nonzero eigenvalue is attained. Why now? Mathlib's finite-dimensional spectral theorem
(`LinearMap.IsSymmetric.eigenvalue…`, `inner_map_self_eq…`) makes the eigenvalue-attained
statement reachable, and combining it with this cycle's convergence theorem would yield a
fully hypothesis-free "deep message passing computes cohomology" theorem.

### 3. Quantitative cohomology recovery: explicit depth as a function of the spectral gap

`criticalDepth` is stated in terms of the abstract rate `ρ`. Substituting the derived
rate `ρ = 1 - μ/λ` from Direction 2 yields a depth bound purely in terms of the spectral
gap `μ`, the top eigenvalue `λ`, the input norm and the tolerance — an end-to-end,
checkable complexity estimate for recovering the `k`-th Betti class. The key insight is
that the Bernoulli argument behind `criticalDepth_energy_bound` is *uniform in `ρ`*, so
plugging in `1 - μ/λ` is a literal substitution, not a new proof. Why now? With Direction
2 supplying `ρ`, this becomes a one-line corollary that converts a spectral invariant of
the complex into a concrete, falsifiable layer count — testable against numerical
simplicial-complex experiments.

### 4. Robustness: convergence under a perturbed or noisy layer `T + Eₖ`

Real message passing uses approximate, possibly stochastic, Laplacians. Conjecture: if
each layer is `T + Eₖ` with `Σ ‖Eₖ‖ < ∞` (summable perturbations) and the unperturbed
`T` contracts `(ker L)ᗮ` by `ρ < 1`, then the perturbed orbit still converges, to a point
within `O(Σ‖Eₖ‖/(1−ρ))` of the true harmonic projection. The key insight is that the
geometric `ρᵏ` decay proved here gives an absolutely convergent telescoping series for the
perturbation error, so the limit exists and is Lipschitz-stable in the perturbation
stream. Why now? The clean `ρᵏ` residual bound (`mpStep_iterate_contraction_orthogonal`)
is precisely the summability engine such a perturbation argument needs; without it the
error series would not visibly converge.

### 5. Higher-order / multi-step layers and acceleration: does a polynomial `p(L)` beat `1 − αL`?

The layer `1 − αL` is the degree-1 polynomial filter. Conjecture: a Chebyshev-type
degree-`d` polynomial layer `p_d(L)` (still fixing `ker L` pointwise) achieves residual
contraction `ρ_d = ρ^{≈d}` per layer at the same harmonic-preservation guarantee, giving
a provable depth speedup. The key insight is that *any* real polynomial `p` with
`p(0) = 1` fixes `ker L` (since `p(L)h = p(0)h = h` when `Lh = 0`), so the entire
invariance/decomposition scaffold of this file transfers verbatim, and only the scalar
contraction factor changes. Why now? The harmonic-fixed-point lemmas here are stated for a
general linear `T` fixing `ker L`, not specifically for `1 − αL`, so generalizing to
`p(L)` requires re-deriving only the one scalar Rayleigh estimate — the structural
theorems are already polynomial-agnostic.
