
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

**Title**: The previous strands of this project pinned down two complementary pictures of
**Domain**: Applications
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing: the Convergence Cycle

## Synthesis

The previous strands of this project pinned down two complementary pictures of
combinatorial Hodge theory on cochain spaces. `HodgeSpectralThreshold.lean`
established the **spectral depth threshold**: the message-passing layer
`T = 1 - t·Δ` fixes the harmonic subspace `ker Δ` exactly, while every non-harmonic
spectral mode is geometrically suppressed, giving an explicit finite depth to reach
any energy tolerance. Separately, `HodgeThreeWayDecomposition.lean` /
`HodgeBettiRank.lean` identified the harmonic subspace as the middle summand of the
orthogonal splitting `V = range d* ⊕ range e ⊕ ker Δ`, with `dim ker Δ` the Betti
number.

This cycle (`HodgeMessagePassingConvergence.lean`) closes the gap between *energy
decay* and genuine *convergence*. The decisive structural observation is that the
gradient layer `mpStep L α = 1 - α·L` is a **linear operator** (`mpStep_add`,
`mpStep_smul`), realized as an element of `Module.End ℝ E` so that depth — iteration
`Tᵏ` — is linear for free. Linearity splits every input `x = h + r` into a *fixed*
harmonic part `h` (`mpStep_iterate_add_harmonic`) plus a residual `Tᵏ r` whose energy
contracts at the spectral rate `ρᵏ` (`mpStep_iterate_contraction`). Together these
give a convergence statement, not merely decay: the squared distance from the depth-`k`
output to the harmonic component is bounded by `ρᵏ ⟪r,r⟫` (`mpStep_dist_to_harmonic_bound`),
so a finite depth reaches any tolerance (`mpStep_converges_to_harmonic`). We also
derive the per-layer contraction factor `1 - αμ(2 - αλ)` directly from the Rayleigh
bounds (`mpStep_contraction`) and prove the **spectral step** `α = 1/λ` is optimal,
where the factor equals `1 - μ/λ` (`contraction_factor_optimal`,
`contraction_factor_at_optimal`). Finally, `hodge_harmonic_mpStep_fixed` bridges back
to the catalog: routing through `HodgeSpectralThreshold.harmonic_iff`, every
closed-and-coclosed cochain of the Hodge Laplacian `Δ = up + down` is an exact fixed
point of message passing at every depth.

The upshot, made rigorous: **deep Hodge message passing transports the cohomology
(harmonic) part exactly and suppresses everything else, with the spectral gap as the
convergence rate.**

## Results Summary

- `mpStep_add`, `mpStep_smul` — the message-passing layer is a linear operator.
- `mpStep_harmonic_fixed`, `mpStep_iterate_harmonic_fixed` — harmonic signals are
  exact fixed points at every depth.
- `mpStep_iterate_add_harmonic` — depth transports the harmonic part as an additive
  constant.
- `mpStep_contraction` — per-layer factor `1 - αμ(2 - αλ)` from spectral bounds.
- `mpStep_iterate_contraction` — geometric `ρᵏ` decay of the residual energy.
- `mpStep_dist_to_harmonic_bound` — distance-to-harmonic bound `ρᵏ⟪r,r⟫`.
- `mpStep_converges_to_harmonic` — finite depth reaches any tolerance.
- `contraction_factor_optimal`, `contraction_factor_at_optimal` — `α = 1/λ` is
  optimal, with rate `1 - μ/λ`.
- `hodge_harmonic_mpStep_fixed` — cross-file bridge: cohomology is fixed by message
  passing.

All theorems are sorry-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The limit is *exactly* the harmonic orthogonal projection.

We proved that the depth-`k` output converges to the harmonic vector `h` appearing in
a chosen decomposition `x = h + r`. The next step is to identify `h` intrinsically as
`orthogonalProjection (ker L) x`, independent of the decomposition. The key insight is
that the residual `r = x - proj x` produced by message passing always lives in the
energy-carrying complement `(ker L)ᗮ = range L`, so `x = proj x + (x - proj x)` is the
*unique* harmonic-plus-orthogonal splitting and convergence forces `h = proj x`. **Why
now?** `HodgeThreeWayDecomposition` already supplies the orthogonal splitting machinery
and `(ker d)ᗮ = range d*`, while `mpStep_iterate_add_harmonic` already isolates `h`;
the only missing piece is `Submodule.orthogonalProjection` bookkeeping over the
existing inner-product layer, turning our convergence theorem into a statement that
message passing *computes a topological invariant*.

### 2. Spectral-gap sufficiency: when does a concrete `L = BᵀB` satisfy the
contraction hypothesis?

Our convergence theorems take the per-layer contraction `⟪Tx,Tx⟫ ≤ ρ⟪x,x⟫` as a
hypothesis, and `mpStep_contraction` already reduces it to the two Rayleigh bounds
`μ⟪x,x⟫ ≤ ⟪x,Lx⟫` and `⟪Lx,Lx⟫ ≤ λ⟪x,Lx⟫`. The falsifiable conjecture: for `L = BᵀB`
with smallest *nonzero* eigenvalue `μ > 0` and largest eigenvalue `λ`, every step
`α ∈ (0, 2/λ)` yields such a `ρ = 1 - αμ(2 - αλ) < 1` on `(ker L)ᗮ`. The key insight is
that the two Rayleigh bounds are exactly the extremal eigenvalue characterizations of a
symmetric PSD operator, so they should drop out of the spectral theorem rather than be
assumed. **Why now?** Mathlib's `Matrix.IsHermitian.spectral_theorem` and
`LinearMap.IsSymmetric.eigenvalue` give the eigen-decomposition of `BᵀB` off the shelf,
turning the hypotheses of `mpStep_contraction` into provable Rayleigh-quotient
estimates and making the whole convergence pipeline unconditional for concrete `B`.

### 3. Higher-order / Chebyshev message passing beats plain gradient steps.

Replace the single-step map `1 - αL` by a degree-`m` polynomial `p_m(L)` (the
Chebyshev / heavy-ball filters used in spectral GNNs). The conjecture: the optimal
degree-`m` polynomial achieves contraction `ρ_m ≈ ((√λ - √μ)/(√λ + √μ))^m`, a quadratic
speedup in depth over the plain linear rate `(1 - μ/λ)`. The key insight is that our
linearity lemmas (`mpStep_add`, `mpStep_smul`) and harmonic-fixing lemmas generalise
*verbatim* to any polynomial of `L`, since `p(L)` is linear and fixes `ker L` whenever
`p(0) = 1`; only the scalar contraction-factor analysis changes, becoming a
Chebyshev-extremal optimisation on `[μ, λ]`. **Why now?** The linear-operator
scaffolding is already sorry-free, so the new content is a self-contained real-analysis
optimisation that `polyrith`/`nlinarith` can attack for fixed small `m` (e.g. the
heavy-ball case `m = 2`) before the general bound.

### 4. Full Hodge Laplacian `Δ = d*d + e e*` and the down-Laplacian.

We worked with a single symmetric PSD operator `L` (e.g. the up Laplacian `BᵀB`). The
conjecture: the *same* convergence-to-harmonic theorem holds verbatim for the full
Hodge Laplacian `Δ` of `HodgeThreeWayDecomposition`, with the limit being the harmonic
projection onto `ker Δ` and the rate set by the smallest nonzero eigenvalue of `Δ`. The
key insight is that `Δ` is again symmetric PSD with `ker Δ` fixed by `1 - αΔ`, so every
lemma in `HodgeMessagePassingConvergence` transfers once `Δ` replaces `L`; the
three-way decomposition guarantees the residual splits into exact + coexact pieces that
are *both* contracted. **Why now?** `hodgeLap`, `hodgeLap_ker = ker d ⊓ ker e*`, the
orthogonality lemmas, and our own `hodge_harmonic_mpStep_fixed` are already proven, so
the harmonic-fixing step `Δh = 0 ⟹ mpStep h = h` is immediate and only the spectral
bounds for `Δ` remain.

### 5. Quantitative oversmoothing: a matching *lower* bound forcing depth.

We proved an upper bound `ρᵏ⟪r,r⟫` on the residual energy. The falsifiable converse:
there exist inputs (residuals aligned with the *slowest* nonzero mode) for which the
distance to harmonics is bounded *below* by `c·σᵏ⟪r,r⟫` with `σ = (1 - αμ)²` close to
`1`, proving the depth threshold is essentially tight — one genuinely needs
`Θ(log(1/ε)/log(1/ρ))` layers. The key insight is that the slowest mode is an
eigenvector of `L` with eigenvalue `μ`, on which `mpStep` acts as *exact* scalar
multiplication by `(1 - αμ)`, so the iterate is computed in closed form (a geometric
sequence) rather than merely bounded. **Why now?** Combined with Direction 2's
eigen-decomposition, the single-eigenvector orbit becomes an exact equality with no
inequality slack, converting our one-sided bound into a two-sided characterization of
the convergence rate.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing: the Convergence Cycle

## Synthesis

The previous strands of this project pinned down two complementary pictures of
combinatorial Hodge theory on cochain spaces. `HodgeSpectralThreshold.lean`
established the **spectral depth threshold**: the message-passing layer
`T = 1 - t·Δ` fixes the harmonic subspace `ker Δ` exactly, while every non-harmonic
spectral mode is geometrically suppressed, giving an explicit finite depth to reach
any energy tolerance. Separately, `HodgeThreeWayDecomposition.lean` /
`HodgeBettiRank.lean` identified the harmonic subspace as the middle summand of the
orthogonal splitting `V = range d* ⊕ range e ⊕ ker Δ`, with `dim ker Δ` the Betti
number.

This cycle (`HodgeMessagePassingConvergence.lean`) closes the gap between *energy
decay* and genuine *convergence*. The decisive structural observation is that the
gradient layer `mpStep L α = 1 - α·L` is a **linear operator** (`mpStep_add`,
`mpStep_smul`), realized as an element of `Module.End ℝ E` so that depth — iteration
`Tᵏ` — is linear for free. Linearity splits every input `x = h + r` into a *fixed*
harmonic part `h` (`mpStep_iterate_add_harmonic`) plus a residual `Tᵏ r` whose energy
contracts at the spectral rate `ρᵏ` (`mpStep_iterate_contraction`). Together these
give a convergence statement, not merely decay: the squared distance from the depth-`k`
output to the harmonic component is bounded by `ρᵏ ⟪r,r⟫` (`mpStep_dist_to_harmonic_bound`),
so a finite depth reaches any tolerance (`mpStep_converges_to_harmonic`). We also
derive the per-layer contraction factor `1 - αμ(2 - αλ)` directly from the Rayleigh
bounds (`mpStep_contraction`) and prove the **spectral step** `α = 1/λ` is optimal,
where the factor equals `1 - μ/λ` (`contraction_factor_optimal`,
`contraction_factor_at_optimal`). Finally, `hodge_harmonic_mpStep_fixed` bridges back
to the catalog: routing through `HodgeSpectralThreshold.harmonic_iff`, every
closed-and-coclosed cochain of the Hodge Laplacian `Δ = up + down` is an exact fixed
point of message passing at every depth.

The upshot, made rigorous: **deep Hodge message passing transports the cohomology
(harmonic) part exactly and suppresses everything else, with the spectral gap as the
convergence rate.**

## Results Summary

- `mpStep_add`, `mpStep_smul` — the message-passing layer is a linear operator.
- `mpStep_harmonic_fixed`, `mpStep_iterate_harmonic_fixed` — harmonic signals are
  exact fixed points at every depth.
- `mpStep_iterate_add_harmonic` — depth transports the harmonic part as an additive
  constant.
- `mpStep_contraction` — per-layer factor `1 - αμ(2 - αλ)` from spectral bounds.
- `mpStep_iterate_contraction` — geometric `ρᵏ` decay of the residual energy.
- `mpStep_dist_to_harmonic_bound` — distance-to-harmonic bound `ρᵏ⟪r,r⟫`.
- `mpStep_converges_to_harmonic` — finite depth reaches any tolerance.
- `contraction_factor_optimal`, `contraction_factor_at_optimal` — `α = 1/λ` is
  optimal, with rate `1 - μ/λ`.
- `hodge_harmonic_mpStep_fixed` — cross-file bridge: cohomology is fixed by message
  passing.

All theorems are sorry-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The limit is *exactly* the harmonic orthogonal projection.

We proved that the depth-`k` output converges to the harmonic vector `h` appearing in
a chosen decomposition `x = h + r`. The next step is to identify `h` intrinsically as
`orthogonalProjection (ker L) x`, independent of the decomposition. The key insight is
that the residual `r = x - proj x` produced by message passing always lives in the
energy-carrying complement `(ker L)ᗮ = range L`, so `x = proj x + (x - proj x)` is the
*unique* harmonic-plus-orthogonal splitting and convergence forces `h = proj x`. **Why
now?** `HodgeThreeWayDecomposition` already supplies the orthogonal splitting machinery
and `(ker d)ᗮ = range d*`, while `mpStep_iterate_add_harmonic` already isolates `h`;
the only missing piece is `Submodule.orthogonalProjection` bookkeeping over the
existing inner-product layer, turning our convergence theorem into a statement that
message passing *computes a topological invariant*.

### 2. Spectral-gap sufficiency: when does a concrete `L = BᵀB` satisfy the
contraction hypothesis?

Our convergence theorems take the per-layer contraction `⟪Tx,Tx⟫ ≤ ρ⟪x,x⟫` as a
hypothesis, and `mpStep_contraction` already reduces it to the two Rayleigh bounds
`μ⟪x,x⟫ ≤ ⟪x,Lx⟫` and `⟪Lx,Lx⟫ ≤ λ⟪x,Lx⟫`. The falsifiable conjecture: for `L = BᵀB`
with smallest *nonzero* eigenvalue `μ > 0` and largest eigenvalue `λ`, every step
`α ∈ (0, 2/λ)` yields such a `ρ = 1 - αμ(2 - αλ) < 1` on `(ker L)ᗮ`. The key insight is
that the two Rayleigh bounds are exactly the extremal eigenvalue characterizations of a
symmetric PSD operator, so they should drop out of the spectral theorem rather than be
assumed. **Why now?** Mathlib's `Matrix.IsHermitian.spectral_theorem` and
`LinearMap.IsSymmetric.eigenvalue` give the eigen-decomposition of `BᵀB` off the shelf,
turning the hypotheses of `mpStep_contraction` into provable Rayleigh-quotient
estimates and making the whole convergence pipeline unconditional for concrete `B`.

### 3. Higher-order / Chebyshev message passing beats plain gradient steps.

Replace the single-step map `1 - αL` by a degree-`m` polynomial `p_m(L)` (the
Chebyshev / heavy-ball filters used in spectral GNNs). The conjecture: the optimal
degree-`m` polynomial achieves contraction `ρ_m ≈ ((√λ - √μ)/(√λ + √μ))^m`, a quadratic
speedup in depth over the plain linear rate `(1 - μ/λ)`. The key insight is that our
linearity lemmas (`mpStep_add`, `mpStep_smul`) and harmonic-fixing lemmas generalise
*verbatim* to any polynomial of `L`, since `p(L)` is linear and fixes `ker L` whenever
`p(0) = 1`; only the scalar contraction-factor analysis changes, becoming a
Chebyshev-extremal optimisation on `[μ, λ]`. **Why now?** The linear-operator
scaffolding is already sorry-free, so the new content is a self-contained real-analysis
optimisation that `polyrith`/`nlinarith` can attack for fixed small `m` (e.g. the
heavy-ball case `m = 2`) before the general bound.

### 4. Full Hodge Laplacian `Δ = d*d + e e*` and the down-Laplacian.

We worked with a single symmetric PSD operator `L` (e.g. the up Laplacian `BᵀB`). The
conjecture: the *same* convergence-to-harmonic theorem holds verbatim for the full
Hodge Laplacian `Δ` of `HodgeThreeWayDecomposition`, with the limit being the harmonic
projection onto `ker Δ` and the rate set by the smallest nonzero eigenvalue of `Δ`. The
key insight is that `Δ` is again symmetric PSD with `ker Δ` fixed by `1 - αΔ`, so every
lemma in `HodgeMessagePassingConvergence` transfers once `Δ` replaces `L`; the
three-way decomposition guarantees the residual splits into exact + coexact pieces that
are *both* contracted. **Why now?** `hodgeLap`, `hodgeLap_ker = ker d ⊓ ker e*`, the
orthogonality lemmas, and our own `hodge_harmonic_mpStep_fixed` are already proven, so
the harmonic-fixing step `Δh = 0 ⟹ mpStep h = h` is immediate and only the spectral
bounds for `Δ` remain.

### 5. Quantitative oversmoothing: a matching *lower* bound forcing depth.

We proved an upper bound `ρᵏ⟪r,r⟫` on the residual energy. The falsifiable converse:
there exist inputs (residuals aligned with the *slowest* nonzero mode) for which the
distance to harmonics is bounded *below* by `c·σᵏ⟪r,r⟫` with `σ = (1 - αμ)²` close to
`1`, proving the depth threshold is essentially tight — one genuinely needs
`Θ(log(1/ε)/log(1/ρ))` layers. The key insight is that the slowest mode is an
eigenvector of `L` with eigenvalue `μ`, on which `mpStep` acts as *exact* scalar
multiplication by `(1 - αμ)`, so the iterate is computed in closed form (a geometric
sequence) rather than merely bounded. **Why now?** Combined with Direction 2's
eigen-decomposition, the single-eigenvector orbit becomes an exact equality with no
inequality slack, converting our one-sided bound into a two-sided characterization of
the convergence rate.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
