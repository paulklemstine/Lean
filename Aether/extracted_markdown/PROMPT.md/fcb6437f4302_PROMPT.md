
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

**Title**: The previous cycle established the **spectral depth threshold** picture
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Convergence Cycle

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

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Convergence Cycle

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

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
