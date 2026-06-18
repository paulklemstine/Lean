# Future Directions — Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpens the
convergence theory of `HodgeMessagePassingConvergence.lean` along two of that file's
declared research directions, turning a one-sided picture into a two-sided one and
generalizing a single gradient step into an entire family of spectral filters.

The previous strand established that one layer of gradient message passing
`mpStep L α = 1 − α·L` is a linear operator that fixes the harmonic subspace `ker L`
and contracts the residual energy by a factor `ρ`, giving the *upper* bound `ρᵏ⟪r,r⟫`
on the distance from the depth-`k` output to the cohomology (harmonic) part. Two
questions were left open: is that bound *attained* (is the spectral rate necessary, not
merely sufficient?), and does the whole scaffolding survive when the single step is
replaced by the higher-order/Chebyshev filters used in spectral GNNs?

We answer both affirmatively and constructively.

**Exactness on a mode.** On a genuine eigenvector `L v = ν·v`, message passing *is*
scalar multiplication: `mpStep L α v = (1 − αν)·v` (`mpStep_eigenvector`), so depth `k`
produces the closed-form orbit `(1 − αν)ᵏ·v` (`mpStep_iterate_eigenvector`) and the
energy is *exactly* `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).
Specializing to the slowest nonzero mode `ν = μ`, the distance-to-harmonic energy
equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²` (`oversmoothing_exact`) — an equality matching the
convergence cycle's inequality shape, so the geometric rate is tight. The inequality
`< ε` then *forces* `σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`): reaching tolerance
on the slowest mode requires logarithmic depth.

**Polynomial filters.** A degree-`m` filter is a product of gradient steps
`∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`. We model it as
`mpFilter L αs` — the `List.prod` (composition) of `mpStep`s in `Module.End ℝ E` — and
show the structural lemmas transfer verbatim: harmonics remain exact fixed points
(`mpFilter_harmonic_fixed`), and on an eigenvector the filter acts as the scalar
`∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`), with energy scaled by `p(ν)²`
(`mpFilter_eigenvector_energy`). The degree-2 (heavy-ball) case is the explicit
quadratic in `L`, `1 − (α+β)L + αβ·L²` (`mpStep_comp_eq`), exhibiting `mpFilter` as a
genuine polynomial of the operator.

The upshot: **the spectral gap is not just an upper bound on the convergence rate but
the exact rate on the extremal mode, and the entire linear-operator/harmonic-fixing
calculus is invariant under passing from a single gradient step to any `p(0) = 1`
polynomial filter — so Chebyshev acceleration is a scalar optimization on `[μ, λ]`, with
the operator-level bookkeeping already discharged.**

## Results Summary (all sorry-free; axioms: `propext`, `Classical.choice`, `Quot.sound`)

- `mpStep_eigenvector` — one layer acts as `(1 − αν)·` on an eigenvector.
- `mpStep_iterate_eigenvector` — depth-`k` orbit is `(1 − αν)ᵏ·v` in closed form.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy equals `σᵏ⟪v,v⟫`, `σ = (1 − αμ)²`
  (the convergence-cycle upper bound is attained).
- `oversmoothing_depth_necessary` — sub-tolerance on the slowest mode forces
  `σᵏ < ε/⟪v,v⟫` (logarithmic depth is necessary).
- `mpFilter` — degree-`|αs|` polynomial filter `∏(1 − αᵢL)` as a `List.prod` of steps.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — heavy-ball filter is the explicit quadratic `1 − (α+β)L + αβL²`.

## Research Directions

### 1. Two-sided convergence: an exact `Θ(log(1/ε)/log(1/σ))` depth law.

We now own both an upper bound (parent file) and a lower bound (`oversmoothing_exact`,
`oversmoothing_depth_necessary`) on the slowest-mode energy. The next step fuses them
into a single closed-form depth law: the smallest depth `k` with residual energy below
`ε` is *exactly* `⌈log(⟪v,v⟫/ε) / log(1/σ)⌉` on the extremal mode, and for a general
input lies sandwiched between the harmonic (zero-decay) and extremal-mode bounds.
**The key insight is** that on the slowest mode the iterate energy is a genuine
*geometric sequence* `σᵏ⟪v,v⟫`, so the depth threshold is not an estimate but the exact
ceiling of a logarithm, with no inequality slack anywhere. **Why now?**
`oversmoothing_exact` already delivers the exact energy `σᵏ⟪v,v⟫`; the only remaining
ingredient is Mathlib's `Real.logb` / `Nat.ceil` monotonicity to invert the geometric
law, upgrading the one-line division of `oversmoothing_depth_necessary` into a sharp
two-sided count.

### 2. Chebyshev optimality of the degree-`m` polynomial filter.

`mpFilter_eigenvector` shows a filter acts on `[μ, λ]` as the scalar polynomial
`p(ν) = ∏(1 − αᵢν)` with `p(0) = 1`. The falsifiable conjecture: the worst-case
contraction `maxₙ∈[μ,λ] |p(ν)|` over all `p(0)=1` degree-`m` polynomials is minimized by
the shifted Chebyshev polynomial, with optimal value
`ρ_m = ((√λ − √μ)/(√λ + √μ))^m / Tₘ((λ+μ)/(λ−μ))`, a quadratic depth speedup over the
plain rate `1 − μ/λ`. **The key insight is** that the operator-level work is finished —
every filter is `mpFilter L αs` and acts modewise as the *scalar* `p(ν)` — so the
problem collapses to the classical real-analysis extremal problem for
normalized-at-`0` polynomials on an interval. **Why now?** With `mpStep_comp_eq`
exhibiting the `m = 2` filter as `1 − (α+β)L + αβL²`, the heavy-ball case
`min_{α,β} max_{[μ,λ]} |1 − (α+β)ν + αβν²|` is a two-variable optimization that
`nlinarith`/`polyrith` can attack directly, validating the pattern before the general
Chebyshev bound.

### 3. The deep limit is the orthogonal projection onto `ker L`.

`oversmoothing_exact` pins the harmonic limit on a single mode, but the global limit of
`(mpStep L α)ᵏ x` for arbitrary `x` should be `orthogonalProjection (ker L) x`, a
basis-free topological invariant. The conjecture: under the contraction hypothesis,
`(mpStep L α)ᵏ x → orthogonalProjection (ker L) x` in norm. **The key insight is** that
`mpStep_iterate_add_harmonic` already splits `x = h + r` with `h` fixed and `r`
contracted, and for symmetric PSD `L` the residual `r` lives in `(ker L)ᗮ = range L`, so
the split *is* the orthogonal decomposition and uniqueness forces `h = proj x`. **Why
now?** `HodgeThreeWayDecomposition` supplies `(ker d)ᗮ = range d*` and the orthogonal
projection API; combined with `oversmoothing_exact`'s exact modewise control, the only
new content is `Submodule.orthogonalProjection` bookkeeping over the existing
inner-product layer.

### 4. Unconditional contraction for `L = BᵀB` via the spectral theorem.

The convergence pipeline assumes the per-layer contraction `⟪Tx,Tx⟫ ≤ ρ⟪x,x⟫`. For a
concrete coboundary `L = BᵀB`, this should be a theorem, not a hypothesis: with `μ` the
smallest nonzero eigenvalue and `λ` the largest, every step `α ∈ (0, 2/λ)` yields
`ρ = 1 − αμ(2 − αλ) < 1` on `(ker L)ᗮ`. **The key insight is** that
`mpFilter_eigenvector`/`mpStep_eigenvector` already give the *exact* action on each
eigenvector, so on an eigenbasis the contraction is the purely scalar fact
`(1 − αν)² ≤ ρ` for `ν ∈ [μ, λ]` — no operator inequalities remain. **Why now?**
Mathlib's `LinearMap.IsSymmetric.spectral_theorem` / eigenbasis decomposition expands
any `x ∈ (ker L)ᗮ` in eigenvectors, and our modewise energy lemma
`mpStep_iterate_eigenvector_energy` sums termwise to the global bound, making the whole
pipeline unconditional for concrete `B`.

### 5. Full Hodge Laplacian `Δ = d*d + e e*` and simultaneous exact/coexact decay.

We worked with a single symmetric PSD operator `L`. The conjecture: every result of
`HodgeFilterDynamics` holds verbatim for the full Hodge Laplacian `Δ` of
`HodgeThreeWayDecomposition`, with the limit being the projection onto `ker Δ` (the
Betti space) and the rate set by the smallest nonzero eigenvalue of `Δ`, while the
residual's exact and coexact parts are contracted *simultaneously*. **The key insight
is** that `Δ` is again symmetric PSD with `ker Δ = ker d ⊓ ker e*` fixed by `1 − αΔ`, so
`mpStep_eigenvector` and `mpFilter_harmonic_fixed` apply unchanged once `Δ` replaces
`L` (the bridge `hodge_harmonic_mpStep_fixed` already does this for the harmonic-fixing
half). **Why now?** `hodgeLaplacian`, `harmonic_iff`, and the cross-file bridge
`hodge_harmonic_mpStep_fixed` are already proven, so the harmonic-fixing step is
immediate and only the spectral bounds for `Δ` — supplied by Direction 4's eigenbasis —
remain to make convergence-to-cohomology fully unconditional.
