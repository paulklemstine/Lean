# Future Directions — Hodge–Laplacian Message Passing, Post Deep-Limit Cycle

## Synthesis

This cycle (`HodgeDeepLimit.lean`) closed the loop from *"the residual energy gets
small"* to *"the network computes a canonical object"*. The earlier cycles had two
gaps. First, the convergence cycle assumed a contraction "for all `x`", which at a
rate `ρ < 1` is only satisfiable when `ker L = 0`: a harmonic `h` is a fixed point,
so `⟪Th, Th⟫ = ⟪h, h⟫ ≤ ρ ⟪h, h⟫` forces `h = 0`, secretly trivialising the very
harmonics the theory is meant to preserve. Second, convergence was stated only as
*energy below ε* with a non-constructive depth `∃ K`.

`HodgeDeepLimit.lean` repairs both. We replace the dishonest hypothesis with a
strict contraction **only on the residual subspace** `(ker L)ᗮ`, prove that subspace
is invariant under one layer for symmetric `L` (`mpStep_mem_orthogonal`) and at every
depth (`mpStep_iterate_mem_orthogonal`), and recover the geometric `ρᵏ` residual
energy decay under the corrected hypothesis (`mpStep_iterate_contraction_orthogonal`).
We then upgrade energy decay to genuine **norm convergence**: depth-`k` message
passing on a harmonic-plus-residual input converges in norm to the harmonic part
(`mpStep_iterate_tendsto_harmonic`), and in finite dimension, on *every* input, the
deep limit equals the orthogonal projection onto the harmonic (cohomology) subspace
(`mpStep_deep_limit_eq_cohomology_projection`). The bridge
`hodge_deep_limit_is_harmonic_projection` instantiates this at the abstract
combinatorial Hodge Laplacian `Δ = up + down` of `HodgeSpectralThreshold.lean`.
Finally, the non-constructive `∃ K` is replaced by an explicit, logarithm-free
stopping rule `criticalDepth ρ R ε`, proved correct by a Bernoulli bound
(`criticalDepth_energy_bound`).

The decisive technical move is that energy `⟪v, v⟫ = ‖v‖²` is the bridge between the
polynomial spectral estimates of the earlier cycles and the analytic limit: the
`ρᵏ‖r‖²` energy bound squeezes `‖Tᵏ r‖² → 0`, whence `Tᵏ(h + r) → h`, and the deep
limit needs only the orthogonal decomposition `x = starProjection x +
(x − starProjection x)` available in finite dimension.

## Results Summary

| Theorem | Statement |
|---|---|
| `mpStep_mem_orthogonal` | `(ker L)ᗮ` is invariant under one layer `T = 1 − αL` (symmetric `L`). |
| `mpStep_iterate_mem_orthogonal` | Residual-subspace invariance persists at every depth. |
| `mpStep_iterate_contraction_orthogonal` | Residual energy decays as `ρᵏ ⟪r,r⟫` under the honest, subspace-only contraction. |
| `mpStep_iterate_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm for `L h = 0`, `r ∈ (ker L)ᗮ`. |
| `mpStep_deep_limit_eq_cohomology_projection` | In finite dimension, `Tᵏ x → starProjection_{ker L} x` for every input `x`. |
| `criticalDepth_energy_bound` | The explicit, log-free depth drives residual energy below `ε`. |
| `hodge_deep_limit_is_harmonic_projection` | Deep simplicial message passing at `Δ = up + down` computes the harmonic projection. |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The deep limit as a bona fide operator identity: `Tⁿ → π` in operator norm, and `π² = π`

We proved pointwise convergence `Tᵏ x → π x`, where `π = starProjection_{ker L}`. The
next step is to promote this to an operator-norm statement: under the residual
contraction, the iterates `Tᵏ` converge in operator norm to the orthogonal projection
`π` onto `ker L`, with the explicit rate `‖Tᵏ − π‖ ≤ ρ^{k/2}`, and the limit satisfies
the idempotent and self-adjoint laws `π ∘ π = π`, `π = π*`. The key insight is that
`mpStep_iterate_contraction_orthogonal` already bounds the residual energy *uniformly
in the residual* `r`, so `‖(Tᵏ − π) x‖ = ‖Tᵏ r_x‖ ≤ ρ^{k/2} ‖r_x‖ ≤ ρ^{k/2} ‖x‖`,
which is exactly the hypothesis of `ContinuousLinearMap.opNorm_le_bound` — the
per-orbit bound is *already* an operator-norm bound in disguise. Why now? With
`mpStep_deep_limit_eq_cohomology_projection` giving the pointwise limit and the
uniform `ρᵏ` energy bound in hand, the only remaining ingredient is packaging `mpStep`
as a `ContinuousLinearMap` over the finite-dimensional `E`, where every linear map is
automatically continuous; the projector then emerges as a genuine Banach-space limit
of the layer monoid rather than merely as a target of orbits.

### 2. From assumed gap to derived gap: produce `ρ = 1 − μ/λ < 1` from the spectral gap `μ > 0`

The contraction rate `ρ` is currently a hypothesis (`hcontract`). For a symmetric
positive-semidefinite `L` with smallest nonzero Rayleigh value `μ > 0` on `(ker L)ᗮ`
and largest eigenvalue `λ`, the spectral step `α = 1/λ` should *produce* a valid
residual contraction with `ρ = 1 − μ/λ < 1`, discharging `hcontract` outright. The key
insight is that `HodgeMessagePassingConvergence.contraction_factor_at_optimal` already
pins the per-layer factor to `1 − μ/λ`; what remains is the Rayleigh lower bound
`μ ⟪x,x⟫ ≤ ⟪x, L x⟫` *restricted to* `(ker L)ᗮ`, i.e. that the smallest nonzero
eigenvalue is attained on the residual subspace. Why now? Mathlib's finite-dimensional
spectral theorem for symmetric operators makes "smallest nonzero eigenvalue is
attained" reachable, and combining it with this cycle's
`mpStep_deep_limit_eq_cohomology_projection` would yield a fully hypothesis-free
theorem: *deep message passing on a finite-dimensional symmetric PSD Laplacian
computes the cohomology projection, with no assumed contraction rate at all.*

### 3. End-to-end depth complexity: `criticalDepth` as an explicit function of the spectral gap

`criticalDepth ρ R ε` is stated in terms of the abstract rate `ρ`. Substituting the
derived `ρ = 1 − μ/λ` from Direction 2 yields a depth bound purely in terms of the
spectral gap `μ`, the top eigenvalue `λ`, the input energy `R = ‖r‖²`, and the
tolerance `ε` — a concrete, checkable layer count for recovering the `k`-th Betti
class. The key insight is that the Bernoulli argument behind `criticalDepth_energy_bound`
is *uniform in `ρ`*, so plugging in `1 − μ/λ` is a literal substitution, not a new
proof: `criticalDepth (1 − μ/λ) R ε = ⌈R λ / (μ ε)⌉ + 1`. Why now? With Direction 2
supplying `ρ`, this becomes a short corollary converting a spectral invariant of the
complex into a falsifiable, numerically testable depth estimate against actual
simplicial-complex experiments.

### 4. Robustness under perturbed / noisy layers `T + Eₖ`

Real message passing uses approximate, possibly stochastic, Laplacians. Conjecture: if
each layer is `T + Eₖ` with summable perturbations `Σ ‖Eₖ‖ < ∞`, and the unperturbed
`T` contracts `(ker L)ᗮ` by `ρ < 1`, then the perturbed orbit still converges, to a
point within `O(Σ ‖Eₖ‖ / (1 − ρ))` of the true harmonic projection. The key insight is
that the geometric `ρᵏ` residual decay of `mpStep_iterate_contraction_orthogonal` makes
the perturbation error series an absolutely convergent telescoping sum, so the
perturbed limit exists and is Lipschitz-stable in the perturbation stream. Why now? The
clean `ρᵏ` bound proved this cycle is precisely the summability engine such an argument
needs — without it the error series would not visibly converge — and the
finite-dimensional projection target is already in place.

### 5. Polynomial / Chebyshev acceleration: does a degree-`d` filter `p(L)` beat `1 − αL`?

The layer `1 − αL` is the degree-1 polynomial filter. Conjecture: a Chebyshev-type
degree-`d` polynomial layer `p_d(L)` that still fixes `ker L` pointwise achieves
residual contraction `ρ_d ≈ ρ^{d}` per layer at the same harmonic-preservation
guarantee, giving a provable depth speedup of factor `d`. The key insight is that *any*
real polynomial `p` with `p(0) = 1` fixes `ker L` (since `p(L) h = p(0) h = h` whenever
`L h = 0`), so the entire invariance/decomposition scaffold of `HodgeDeepLimit.lean`
transfers verbatim and only the scalar contraction factor changes. Why now? The
harmonic-fixed-point and residual-invariance lemmas here are already stated for a
general layer that fixes `ker L`, not specifically for `1 − αL`; generalizing to a
polynomial layer requires re-deriving only the one scalar Rayleigh/contraction
estimate, while the structural convergence theorems remain polynomial-agnostic.
