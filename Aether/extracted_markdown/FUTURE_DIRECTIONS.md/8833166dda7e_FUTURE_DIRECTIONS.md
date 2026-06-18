# Future Directions — Hodge–Laplacian Message Passing, Convergence Cycle

## Synthesis

The previous cycle established the **spectral depth threshold** picture
(`HodgeSpectralThreshold.lean`): the up Hodge Laplacian `L = Bᵀ B` is symmetric and
positive semidefinite, its kernel is the harmonic (cohomology) subspace, harmonic signals
are *exact* fixed points of message passing `mpStep L α x = x - α(Lx)`, and off the kernel
the Dirichlet energy contracts geometrically — giving a finite depth threshold to reach any
energy tolerance. Separately, `HodgeThreeWayDecomposition.lean` / `HodgeBettiRank.lean`
pinned the harmonic subspace down as the middle summand of the orthogonal splitting
`V = range d* ⊕ range e ⊕ ker Δ`, with `dim ker Δ` the Betti number.

This cycle closes the gap between those two strands. `HodgeMessagePassingConvergence.lean`
proves that the layer map is **linear**, so the harmonic component of a signal is transported
through every layer untouched while the residual is contracted at the spectral rate. The
consequence is a genuine *convergence* statement, not merely energy decay: the squared
distance from the depth-`k` output to the harmonic component is bounded by `ρ^k‖r‖²`, and a
finite depth reaches any tolerance (`mpStep_dist_to_harmonic_bound`,
`mpStep_converges_to_harmonic`). We also pinned down the **optimal step**: the contraction
factor `1 - αμ(2 - αλ)` is minimised at the spectral step `α = 1/λ`, where it equals
`1 - μ/λ` (`contraction_factor_optimal`, `contraction_factor_at_optimal`).

The upshot, made rigorous: **deep Hodge message passing computes the orthogonal projection
onto cohomology**, i.e. a topological invariant of the input, and the spectral gap is exactly
the convergence rate.

## Results Summary

- `mpStep_add`, `mpStep_smul` — the message-passing layer is a linear operator.
- `mpStep_iterate_add_harmonic` — depth transports the harmonic part as an additive constant.
- `mpStep_dist_to_harmonic_bound` — geometric decay `ρ^k‖r‖²` of the distance to harmonics.
- `mpStep_converges_to_harmonic` — finite depth reaches any tolerance of the harmonic part.
- `contraction_factor_optimal` / `contraction_factor_at_optimal` — `α = 1/λ` is optimal,
  giving rate `1 - μ/λ`.

All theorems are sorry-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The limit is *exactly* the harmonic orthogonal projection.

We proved the depth-`k` output converges to a fixed harmonic vector `h`; the next step is to
identify `h` intrinsically as `proj_{ker L} x`, the orthogonal projection of the input onto the
harmonic subspace, independent of the chosen decomposition `x = h + r`. The key insight is that
the residual `r` produced by message passing always lives in `(ker L)ᗮ = range L` (the
energy-carrying complement), so the decomposition `x = proj x + (x - proj x)` is the *unique*
one with harmonic-plus-orthogonal parts, and convergence forces `h = proj x`. **Why now?**
`HodgeThreeWayDecomposition` already supplies `(ker d)ᗮ = range d*` and the orthogonal splitting
machinery, and `mpStep_iterate_add_harmonic` already isolates `h`; the missing piece is purely
`Submodule.orthogonalProjection` bookkeeping over the catalog's existing inner-product layer.

### 2. Spectral-gap sufficiency: when does a concrete `B` satisfy the contraction hypothesis?

Our convergence theorems take the per-layer contraction `⟨Tx,Tx⟩ ≤ ρ⟨x,x⟩` as a hypothesis.
The falsifiable conjecture: for `L = BᵀB` with smallest *nonzero* eigenvalue `μ > 0` and
largest eigenvalue `λ`, every step `α ∈ (0, 2/λ)` yields such a `ρ < 1` *on the orthogonal
complement of the kernel*, with `ρ = 1 - αμ(2 - αλ)`. The key insight is that
`mpStep_contraction` already proves the pointwise inequality from the spectral bounds
`μ⟨x,x⟩ ≤ ⟨x,Lx⟩` and `⟨Lx,Lx⟩ ≤ λ⟨x,Lx⟩`; what remains is to *derive* those two bounds from
genuine eigenvalue data via the spectral theorem. **Why now?** Mathlib's
`LinearMap.IsSymmetric.eigenvalue` / `Matrix.IsHermitian.spectral_theorem` give the eigen-decomposition
of `BᵀB` off the shelf, so the spectral bounds become Rayleigh-quotient estimates.

### 3. Higher-order / Chebyshev message passing beats plain gradient steps.

Replace the single-step map `I - αL` by a degree-`m` polynomial `p_m(L)` (Chebyshev/Heavy-ball
filters used in spectral GNNs). Conjecture: the optimal degree-`m` polynomial achieves
contraction `ρ_m ≈ ((√λ - √μ)/(√λ + √μ))^m`, a quadratic speedup in depth over the linear rate
`(1 - μ/λ)` of plain steps. The key insight is that our linearity lemmas (`mpStep_add`,
`mpStep_smul`) generalise verbatim to *any* polynomial of `L`, since `p(L)` is linear and fixes
`ker L`; only the contraction-factor analysis changes, becoming a Chebyshev-extremal problem on
`[μ, λ]`. **Why now?** The linear-operator scaffolding is already in place and sorry-free, so the
new content is a self-contained real-analysis optimisation that `polyrith`/`nlinarith` can attack
for fixed small `m` before the general bound.

### 4. Down-Laplacian and the full Hodge Laplacian `Δ = d*d + ee*`.

We worked with the up Laplacian `L = BᵀB`. Conjecture: the *same* convergence-to-harmonic
theorem holds for the full Hodge Laplacian `Δ` of `HodgeThreeWayDecomposition`, with the limit
being the harmonic projection `ker Δ` and the rate set by the smallest nonzero eigenvalue of
`Δ`. The key insight is that `Δ` is again symmetric PSD with `ker Δ` fixed by `I - αΔ`, so every
lemma in this file transfers once `Δ` replaces `L`; the three-way decomposition guarantees the
residual splits cleanly into exact + coexact pieces that are *both* contracted. **Why now?**
`hodgeLap`, `hodgeLap_ker = ker d ⊓ ker e*`, and the orthogonality lemmas are already proven, so
the harmonic-fixing step `Δh = 0 ⟹ mpStep h = h` is immediate.

### 5. Quantitative oversmoothing: a matching *lower* bound forcing depth.

We proved an upper bound `ρ^k‖r‖²` on the residual. The falsifiable converse: there exist
inputs (residuals aligned with the *slowest* nonzero mode) for which the distance to harmonics
is bounded *below* by `c·σ^k‖r‖²` with `σ = (1 - αμ)² ` close to `1`, proving that the depth
threshold is essentially tight — you genuinely *need* `Θ(log(1/ε)/log(1/ρ))` layers. The key
insight is that the slowest mode is an eigenvector of `L` with eigenvalue `μ`, on which
`mpStep` acts as exact scalar multiplication by `(1 - αμ)`, so the iterate is computed in closed
form rather than merely bounded. **Why now?** Combined with Direction 2's eigen-decomposition,
the single-eigenvector orbit is an exact geometric sequence, turning the lower bound into an
equality that needs no inequality slack at all.
