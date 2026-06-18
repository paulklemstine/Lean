
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpen
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpens the
convergence theory of `HodgeMessagePassingConvergence.lean` along two of that file's
declared research directions, turning a one-sided picture into a two-sided one and
generalizing a single gradient step into an entire family of spectral filters.

The previous strand established that one layer of gradient message passing
`mpStep L α = 1 - α·L` is a linear operator that fixes the harmonic subspace `ker L`
and contracts the residual energy by a factor `ρ`, giving the *upper* bound
`ρᵏ⟪r,r⟫` on the distance from the depth-`k` output to the cohomology (harmonic)
part. Two questions were left open: is that bound *attained* (is the spectral rate
necessary, not merely sufficient?), and does the whole scaffolding survive when the
single step is replaced by the higher-order/Chebyshev filters used in spectral GNNs?

We answer both affirmatively and constructively.

**Exactness on a mode.** On a genuine eigenvector `L v = ν·v`, message passing *is*
scalar multiplication: `mpStep L α v = (1 − αν)·v` (`mpStep_eigenvector`), so depth
`k` produces the closed-form orbit `(1 − αν)ᵏ·v` (`mpStep_iterate_eigenvector`) and
the energy is *exactly* `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).
Specializing to the slowest nonzero mode `ν = μ`, whose harmonic component is `0`,
the distance-to-harmonic energy equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`
(`oversmoothing_exact`) — an equality matching the convergence cycle's inequality
shape, so the geometric rate is tight. The inequality `< ε` then *forces*
`σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`): reaching tolerance on the slowest
mode requires logarithmic depth. This is the quantitative oversmoothing lower bound
of the parent file's Direction 5.

**Polynomial filters.** A degree-`m` filter is a product of gradient steps
`∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`. We model it as
`mpFilter L αs` — the `List.prod` (composition) of `mpStep`s in `Module.End ℝ E` —
and show the structural lemmas transfer verbatim: harmonics remain exact fixed points
(`mpFilter_harmonic_fixed`), and on an eigenvector the filter acts as the scalar
`∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`), with energy scaled by `p(ν)²`
(`mpFilter_eigenvector_energy`). The degree-2 (heavy-ball) case is the explicit
quadratic in `L`, `1 − (α+β)L + αβ L²` (`mpStep_comp_eq`), exhibiting `mpFilter` as a
genuine polynomial of the operator. This realizes the parent file's Direction 3.

The upshot: **the spectral gap is not just an upper bound on the convergence rate but
the exact rate on the extremal mode, and the entire linear-operator/harmonic-fixing
calculus is invariant under passing from a single gradient step to any
`p(0) = 1` polynomial filter — so Chebyshev acceleration is a scalar optimization on
`[μ, λ]`, with the operator-level bookkeeping already discharged.**

## Results Summary (all sorry-free; axioms: `propext`, `Classical.choice`, `Quot.sound`)

- `mpStep_eigenvector` — one layer acts as `(1 − αν)·` on an eigenvector.
- `mpStep_iterate_eigenvector` — depth-`k` orbit is `(1 − αν)ᵏ·v` in closed form.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy equals `σᵏ⟪v,v⟫`, `σ = (1−αμ)²`
  (matching lower bound: the convergence-cycle upper bound is attained).
- `oversmoothing_depth_necessary` — sub-tolerance on the slowest mode forces
  `σᵏ < ε/⟪v,v⟫` (logarithmic depth is necessary).
- `mpFilter` — degree-`|αs|` polynomial filter `∏(1 − αᵢL)` as a `List.prod` of steps.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — heavy-ball filter is the explicit quadratic `1 − (α+β)L + αβL²`.

## Research Directions

### 1. Two-sided convergence: an exact `Θ(log(1/ε)/log(1/ρ))` depth law.

We proved both an upper bound (parent file) and a lower bound (`oversmoothing_exact`,
`oversmoothing_depth_necessary`) on the slowest-mode energy. The next step is to fuse
them into a single closed-form depth law: the smallest depth `k` with residual energy
below `ε` is exactly `⌈log(⟪v,v⟫/ε) / log(1/σ)⌉` on the extremal mode, and lies
between the harmonic-and-extremal-mode bounds for a general input. **The key insight
is** that on the slowest mode the iterate is a *geometric sequence*, so the depth
threshold is not an estimate but an exact ceiling of a logarithm, with no
inequality slack. **Why now?** `oversmoothing_exact` already gives the exact energy
`σᵏ⟪v,v⟫`; the only remaining ingredient is Mathlib's `Real.logb`/`Nat.ceil`
monotonicity to invert the geometric law, turning the one-line division of
`oversmoothing_depth_necessary` into a sharp two-sided count.

### 2. Chebyshev optimality of the degree-`m` polynomial filter.

`mpFilter_eigenvector` shows a filter acts on `[μ, λ]` as the scalar polynomial
`p(ν) = ∏(1 − αᵢν)` with `p(0) = 1`. The falsifiable conjecture: the worst-case
contraction `maxₙ∈[μ,λ] |p(ν)|` is minimized by the shifted Chebyshev polynomial, with
optimal value `ρ_m = ((√λ − √μ)/(√λ + √μ))^m / Tₘ((λ+μ)/(λ−μ))`, a quadratic depth
speedup over the plain rate `(1 − μ/λ)`. **The key insight is** that the operator-level
work is finished — every filter is `mpFilter L αs` and acts modewise as `p(ν)` — so the
problem collapses to the classical real-analysis extremal problem for monic-normalized
polynomials on an interval. **Why now?** With `mpStep_comp_eq` exhibiting the `m = 2`
filter as `1 − (α+β)L + αβL²`, the heavy-ball case `min_{α,β} max_{[μ,λ]} |1 − (α+β)ν +
αβν²|` is a two-variable optimization that `nlinarith`/`polyrith` can attack directly,
validating the pattern before the general Chebyshev bound.

### 3. The limit is the orthogonal projection onto `ker L`.

`oversmoothing_exact` identifies the harmonic limit on a single mode, but the global
limit of `(mpStep L α)ᵏ x` for arbitrary `x` should be `orthogonalProjection (ker L) x`,
a basis-free topological invariant. The conjecture: under the contraction hypothesis,
`(mpStep L α)ᵏ x → orthogonalProjection (ker L) x` in norm. **The key insight is** that
`mpStep_iterate_add_harmonic` already splits `x = h + r` with `h` fixed and `r`
contracted, and for symmetric PSD `L` the residual `r` lives in `(ker L)ᗮ = range L`, so
the split is *the* orthogonal decomposition and uniqueness forces `h = proj x`. **Why
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
eigenvector, so on an eigenbasis the contraction is the scalar fact
`(1 − αν)² ≤ ρ` for `ν ∈ [μ, λ]` — no operator inequalities remain. **Why now?**
Mathlib's `LinearMap.IsSymmetric.spectral_theorem`/eigenbasis decomposition expands any
`x ∈ (ker L)ᗮ` in eigenvectors, and our modewise energy lemma
`mpStep_iterate_eigenvector_energy` sums termwise to the global bound, making the whole
pipeline unconditional for concrete `B`.

### 5. Full Hodge Laplacian `Δ = d*d + e e*` and simultaneous exact/coexact decay.

We worked with a single symmetric PSD operator `L`. The conjecture: every result of
`HodgeFilterDynamics` holds verbatim for the full Hodge Laplacian `Δ` of
`HodgeThreeWayDecomposition`, with the limit being the projection onto `ker Δ` (the
Betti space) and the rate set by the smallest nonzero eigenvalue of `Δ`, while the
residual's exact and coexact parts are contracted *simultaneously*. **The key insight
is** that `Δ` is again symmetric PSD with `ker Δ = ker d ⊓ ker e*` fixed by `1 − αΔ`,
so `mpStep_eigenvector` and `mpFilter_harmonic_fixed` apply unchanged once `Δ` replaces
`L`. **Why now?** `hodgeLaplacian`, `harmonic_iff`, and the cross-file bridge
`hodge_harmonic_mpStep_fixed` are already proven, so the harmonic-fixing step is
immediate and only the spectral bounds for `Δ` — supplied by Direction 4's eigenbasis —
remain to make convergence-to-cohomology fully unconditional.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpens the
convergence theory of `HodgeMessagePassingConvergence.lean` along two of that file's
declared research directions, turning a one-sided picture into a two-sided one and
generalizing a single gradient step into an entire family of spectral filters.

The previous strand established that one layer of gradient message passing
`mpStep L α = 1 - α·L` is a linear operator that fixes the harmonic subspace `ker L`
and contracts the residual energy by a factor `ρ`, giving the *upper* bound
`ρᵏ⟪r,r⟫` on the distance from the depth-`k` output to the cohomology (harmonic)
part. Two questions were left open: is that bound *attained* (is the spectral rate
necessary, not merely sufficient?), and does the whole scaffolding survive when the
single step is replaced by the higher-order/Chebyshev filters used in spectral GNNs?

We answer both affirmatively and constructively.

**Exactness on a mode.** On a genuine eigenvector `L v = ν·v`, message passing *is*
scalar multiplication: `mpStep L α v = (1 − αν)·v` (`mpStep_eigenvector`), so depth
`k` produces the closed-form orbit `(1 − αν)ᵏ·v` (`mpStep_iterate_eigenvector`) and
the energy is *exactly* `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).
Specializing to the slowest nonzero mode `ν = μ`, whose harmonic component is `0`,
the distance-to-harmonic energy equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`
(`oversmoothing_exact`) — an equality matching the convergence cycle's inequality
shape, so the geometric rate is tight. The inequality `< ε` then *forces*
`σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`): reaching tolerance on the slowest
mode requires logarithmic depth. This is the quantitative oversmoothing lower bound
of the parent file's Direction 5.

**Polynomial filters.** A degree-`m` filter is a product of gradient steps
`∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`. We model it as
`mpFilter L αs` — the `List.prod` (composition) of `mpStep`s in `Module.End ℝ E` —
and show the structural lemmas transfer verbatim: harmonics remain exact fixed points
(`mpFilter_harmonic_fixed`), and on an eigenvector the filter acts as the scalar
`∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`), with energy scaled by `p(ν)²`
(`mpFilter_eigenvector_energy`). The degree-2 (heavy-ball) case is the explicit
quadratic in `L`, `1 − (α+β)L + αβ L²` (`mpStep_comp_eq`), exhibiting `mpFilter` as a
genuine polynomial of the operator. This realizes the parent file's Direction 3.

The upshot: **the spectral gap is not just an upper bound on the convergence rate but
the exact rate on the extremal mode, and the entire linear-operator/harmonic-fixing
calculus is invariant under passing from a single gradient step to any
`p(0) = 1` polynomial filter — so Chebyshev acceleration is a scalar optimization on
`[μ, λ]`, with the operator-level bookkeeping already discharged.**

## Results Summary (all sorry-free; axioms: `propext`, `Classical.choice`, `Quot.sound`)

- `mpStep_eigenvector` — one layer acts as `(1 − αν)·` on an eigenvector.
- `mpStep_iterate_eigenvector` — depth-`k` orbit is `(1 − αν)ᵏ·v` in closed form.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy equals `σᵏ⟪v,v⟫`, `σ = (1−αμ)²`
  (matching lower bound: the convergence-cycle upper bound is attained).
- `oversmoothing_depth_necessary` — sub-tolerance on the slowest mode forces
  `σᵏ < ε/⟪v,v⟫` (logarithmic depth is necessary).
- `mpFilter` — degree-`|αs|` polynomial filter `∏(1 − αᵢL)` as a `List.prod` of steps.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — heavy-ball filter is the explicit quadratic `1 − (α+β)L + αβL²`.

## Research Directions

### 1. Two-sided convergence: an exact `Θ(log(1/ε)/log(1/ρ))` depth law.

We proved both an upper bound (parent file) and a lower bound (`oversmoothing_exact`,
`oversmoothing_depth_necessary`) on the slowest-mode energy. The next step is to fuse
them into a single closed-form depth law: the smallest depth `k` with residual energy
below `ε` is exactly `⌈log(⟪v,v⟫/ε) / log(1/σ)⌉` on the extremal mode, and lies
between the harmonic-and-extremal-mode bounds for a general input. **The key insight
is** that on the slowest mode the iterate is a *geometric sequence*, so the depth
threshold is not an estimate but an exact ceiling of a logarithm, with no
inequality slack. **Why now?** `oversmoothing_exact` already gives the exact energy
`σᵏ⟪v,v⟫`; the only remaining ingredient is Mathlib's `Real.logb`/`Nat.ceil`
monotonicity to invert the geometric law, turning the one-line division of
`oversmoothing_depth_necessary` into a sharp two-sided count.

### 2. Chebyshev optimality of the degree-`m` polynomial filter.

`mpFilter_eigenvector` shows a filter acts on `[μ, λ]` as the scalar polynomial
`p(ν) = ∏(1 − αᵢν)` with `p(0) = 1`. The falsifiable conjecture: the worst-case
contraction `maxₙ∈[μ,λ] |p(ν)|` is minimized by the shifted Chebyshev polynomial, with
optimal value `ρ_m = ((√λ − √μ)/(√λ + √μ))^m / Tₘ((λ+μ)/(λ−μ))`, a quadratic depth
speedup over the plain rate `(1 − μ/λ)`. **The key insight is** that the operator-level
work is finished — every filter is `mpFilter L αs` and acts modewise as `p(ν)` — so the
problem collapses to the classical real-analysis extremal problem for monic-normalized
polynomials on an interval. **Why now?** With `mpStep_comp_eq` exhibiting the `m = 2`
filter as `1 − (α+β)L + αβL²`, the heavy-ball case `min_{α,β} max_{[μ,λ]} |1 − (α+β)ν +
αβν²|` is a two-variable optimization that `nlinarith`/`polyrith` can attack directly,
validating the pattern before the general Chebyshev bound.

### 3. The limit is the orthogonal projection onto `ker L`.

`oversmoothing_exact` identifies the harmonic limit on a single mode, but the global
limit of `(mpStep L α)ᵏ x` for arbitrary `x` should be `orthogonalProjection (ker L) x`,
a basis-free topological invariant. The conjecture: under the contraction hypothesis,
`(mpStep L α)ᵏ x → orthogonalProjection (ker L) x` in norm. **The key insight is** that
`mpStep_iterate_add_harmonic` already splits `x = h + r` with `h` fixed and `r`
contracted, and for symmetric PSD `L` the residual `r` lives in `(ker L)ᗮ = range L`, so
the split is *the* orthogonal decomposition and uniqueness forces `h = proj x`. **Why
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
eigenvector, so on an eigenbasis the contraction is the scalar fact
`(1 − αν)² ≤ ρ` for `ν ∈ [μ, λ]` — no operator inequalities remain. **Why now?**
Mathlib's `LinearMap.IsSymmetric.spectral_theorem`/eigenbasis decomposition expands any
`x ∈ (ker L)ᗮ` in eigenvectors, and our modewise energy lemma
`mpStep_iterate_eigenvector_energy` sums termwise to the global bound, making the whole
pipeline unconditional for concrete `B`.

### 5. Full Hodge Laplacian `Δ = d*d + e e*` and simultaneous exact/coexact decay.

We worked with a single symmetric PSD operator `L`. The conjecture: every result of
`HodgeFilterDynamics` holds verbatim for the full Hodge Laplacian `Δ` of
`HodgeThreeWayDecomposition`, with the limit being the projection onto `ker Δ` (the
Betti space) and the rate set by the smallest nonzero eigenvalue of `Δ`, while the
residual's exact and coexact parts are contracted *simultaneously*. **The key insight
is** that `Δ` is again symmetric PSD with `ker Δ = ker d ⊓ ker e*` fixed by `1 − αΔ`,
so `mpStep_eigenvector` and `mpFilter_harmonic_fixed` apply unchanged once `Δ` replaces
`L`. **Why now?** `hodgeLaplacian`, `harmonic_iff`, and the cross-file bridge
`hodge_harmonic_mpStep_fixed` are already proven, so the harmonic-fixing step is
immediate and only the spectral bounds for `Δ` — supplied by Direction 4's eigenbasis —
remain to make convergence-to-cohomology fully unconditional.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
