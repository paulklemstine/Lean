
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

**Title**: This cycle closes the conceptual loop opened by the two preceding cycles. The
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing as a Discrete Heat Semigroup

## Synthesis

This cycle closes the conceptual loop opened by the two preceding cycles. The
**spectral depth threshold** picture (`HodgeSpectralThreshold.lean`) showed that
the up/down Hodge Laplacian `Δ = up + down` partitions cochain space into a
depth-invariant *harmonic* (cohomology) block and a geometrically suppressed
*non-harmonic* block. The **convergence** cycle
(`HodgeMessagePassingConvergence.lean`) sharpened "suppression" into a genuine
contraction estimate `⟪Tᵏr, Tᵏr⟫ ≤ ρᵏ⟪r,r⟫` with an optimal spectral step
`α = 1/λ` and rate `1 − μ/λ`.

The new file `HodgeHeatSemigroup.lean` recognizes that all of this is the
behaviour of a single object: the linearized layer `T = 1 − t·Δ` is **exactly the
explicit Euler step of the heat flow `∂x/∂t = −Δx`**. Once the layer is viewed as
an element of `Module.End ℝ E`, the three defining axioms of a heat semigroup fall
out by *composing* the parent cycles rather than re-deriving anything:

* **Semigroup law** `depthMap_semigroup`: `T^(a+b) = T^a ∘ T^b` — the algebraic
  shadow of `e^{−(a+b)Δ} = e^{−aΔ}e^{−bΔ}`. Depth is one-parameter (discrete) time.
* **Lyapunov dissipation** `mpStep_energy_nonincreasing`: the Dirichlet energy
  `⟪x,x⟫` never increases under a normalized layer (the `μ = 0` reading of the
  contraction bound). The flow is non-expansive.
* **Optimal spectral rate** `mpStep_optimal_rate`: at the spectral step `α = 1/λ`
  the residual energy decays as `(1 − μ/λ)ᵏ`, the cleanest possible rate.
* **Convergence to cohomology** `mpStep_tendsto_harmonic`: the depth-`k` output of a
  harmonic-plus-residual input converges *in the norm topology* of `E` to its
  harmonic component. The steady state of the flow **is** the harmonic projection.

## Results Summary

| Theorem | Statement | Built from |
|---|---|---|
| `depthMap_semigroup` | `T^(a+b) = T^a ∘ T^b` | `depthMap`, `pow_add` |
| `mpStep_energy_nonincreasing` | `⟪Tx,Tx⟫ ≤ ⟪x,x⟫` (normalized step) | `mpStep_contraction` at `μ=0` |
| `mpStep_optimal_rate` | `⟪Tᵏr,Tᵏr⟫ ≤ (1−μ/λ)ᵏ⟪r,r⟫` at `α=1/λ` | `contraction_factor_at_optimal`, `mpStep_iterate_contraction` |
| `mpStep_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm | `mpStep_dist_to_harmonic_bound`, squeeze |

All four are proved sorry-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The unifying observation — *deep Hodge message passing is a
contracting discrete heat semigroup whose unique steady state on each input is its
cohomology part* — is now fully formal.

## Research Directions

### 1. The exact steady-state operator is the orthogonal harmonic projection

The convergence theorem `mpStep_tendsto_harmonic` shows `Tᵏ(h+r) → h`, but it takes
the decomposition `x = h + r` (`L h = 0`) as *given*. The natural completion is to
prove that on a finite-dimensional (or complete) inner-product space the limit map
`x ↦ lim Tᵏ x` exists for *every* `x` and **equals the orthogonal projection
`orthogonalProjection (ker L)`**. The key insight is that `mpStep_energy_nonincreasing`
already makes `T` a non-expansive self-adjoint operator, so its powers form a bounded
monotone family on each spectral component; the harmonic block is fixed (eigenvalue
`1`) and every other block is a strict contraction, so the limit is the spectral
projector onto eigenvalue `1`, which is `orthogonalProjection (ker L)`. Why now? The
catalog already supplies the harmonic characterization `ker Δ = ker up ⊓ ker down`
(`ker_hodgeLaplacian`) and the per-block contraction; Mathlib's
`orthogonalProjection` and `OrthogonalFamily`/`Submodule.isCompl_orthogonal_of_completeSpace`
API close the remaining gap, turning the "steady state = projection" slogan into a
theorem rather than a heuristic.

### 2. Energy is *strictly* monotone off the harmonic block (a discrete Łojasiewicz bound)

`mpStep_energy_nonincreasing` gives `⟪Tx,Tx⟫ ≤ ⟪x,x⟫`; the falsifiable strengthening
is a **strict, quantitative** drop: if `x ⟂ ker L` and `μ` is the spectral gap, then
`⟪x,x⟫ − ⟪Tx,Tx⟫ ≥ c·⟪x,x⟫` for an explicit `c = αμ(2−αλ) > 0`. The key insight is
that the contraction factor `1 − αμ(2 − αλ)` from `mpStep_contraction` is *already*
the right Lyapunov decrement — it only needs to be re-read as a coercivity (gradient-
domination) inequality on the orthogonal complement, the discrete analogue of a
Łojasiewicz–Polyak inequality for the Dirichlet energy. Why now? Coercivity is the
single missing ingredient that converts the qualitative `Tendsto` of Direction 1 into
an *exponential* convergence-rate certificate with a fully explicit constant, and the
needed inequality is one `nlinarith` away from the existing contraction lemma.

### 3. Nonlinear message passing: contraction survives 1-Lipschitz activations

Real message-passing layers interleave the linear step `T = 1 − αΔ` with a
coordinatewise nonlinearity `σ` (ReLU, tanh). The conjecture: if `σ` is
`1`-Lipschitz and fixes the harmonic subspace pointwise (`σ(h) = h` for `Δh = 0`),
then the composite layer `σ ∘ T` is still a contraction toward `ker Δ` with the same
spectral rate `1 − μ/λ`. The key insight is that `mpStep_iterate_contraction` only
ever uses the *energy* recursion `⟪T(·),T(·)⟫ ≤ ρ⟪·,·⟫`, and a `1`-Lipschitz `σ`
fixing the harmonic part composes multiplicatively with that bound without touching
linearity — so the proof skeleton transfers verbatim once `T` is replaced by `σ ∘ T`
and the harmonic-fixed-point lemma is re-established for `σ`. Why now? This is the
first direction that genuinely *exits* the linear theory and connects the cycle to
practical (nonlinear) simplicial/graph neural networks, yet it costs almost no new
infrastructure because the contraction machinery is energy-based, not operator-based.

### 4. A continuous-time bridge: `Tᵏ` is the Lie–Trotter discretization of `e^{−tΔ}`

Having proved the discrete semigroup law `depthMap_semigroup`, the next unification is
to connect it to the *continuous* heat semigroup `e^{−tΔ}` on a finite-dimensional
`E`. The conjecture: `(1 − (t/n)·Δ)ⁿ → e^{−tΔ}` strongly as `n → ∞`, and the harmonic
projection is the common `t → ∞` limit of both. The key insight is that on
finite-dimensional `E` the operator exponential `Δ.exp` (Mathlib's `NormedSpace.exp`)
and the binomial expansion of `(1 − (t/n)Δ)ⁿ` agree term-by-term in the limit, so the
discrete-to-continuous passage is a `Tendsto` of matrix power series — and the steady
states match because `Δ` is PSD with kernel `ker Δ`. Why now? It places the
combinatorial/learning object (`depthMap`) and the analytic object (`exp(−tΔ)`) under
one roof, exactly the Grothendieck-style "special case of a deeper truth" the engine
is configured to seek, and Mathlib's `NormedSpace.exp` plus `tendsto_pow` give the
analytic backbone.

### 5. Closing the Carmichael tail: a height bound for the primitive part

Orthogonally to the Hodge thread, the catalog's `CarmichaelComposite.lean` /
`Shared/CarmichaelProof.lean` still contains a single load-bearing `sorry`: the
*infinite tail* of Carmichael's primitive-divisor theorem — every composite `n > 10000`
has a Fibonacci primitive prime divisor (the range `13 ≤ n ≤ 10000` is already settled
by `native_decide`). The key insight is that the primitive part `Φₙ` of `Fₙ` admits a
cyclotomic factorization `Fₙ = ∏_{d∣n} Φ_d`, and a Carmichael/Zsygmondy height bound
`|Φₙ| > n` (using `Fₙ ≥ φ^{n−2}` and a lifting-the-exponent control of the unique
possibly-imprimitive prime) forces `Φₙ > 1`, hence a primitive divisor; this purely
*analytic* lower bound is exactly what `primPart`/`fibCoprimePart` compute. Why now?
The combinatorial scaffolding (entry-point theory, `fib_dvd_gcd`, the coprime-part
algorithm and its correctness lemmas) is already proved sorry-free in the catalog — the
*only* missing piece is the growth/height estimate, which is a self-contained real-
analysis lemma that can be developed independently and then dropped into the existing
`fib_carmichael_composite` skeleton to eliminate the project's last open `sorry`.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing as a Discrete Heat Semigroup

## Synthesis

This cycle closes the conceptual loop opened by the two preceding cycles. The
**spectral depth threshold** picture (`HodgeSpectralThreshold.lean`) showed that
the up/down Hodge Laplacian `Δ = up + down` partitions cochain space into a
depth-invariant *harmonic* (cohomology) block and a geometrically suppressed
*non-harmonic* block. The **convergence** cycle
(`HodgeMessagePassingConvergence.lean`) sharpened "suppression" into a genuine
contraction estimate `⟪Tᵏr, Tᵏr⟫ ≤ ρᵏ⟪r,r⟫` with an optimal spectral step
`α = 1/λ` and rate `1 − μ/λ`.

The new file `HodgeHeatSemigroup.lean` recognizes that all of this is the
behaviour of a single object: the linearized layer `T = 1 − t·Δ` is **exactly the
explicit Euler step of the heat flow `∂x/∂t = −Δx`**. Once the layer is viewed as
an element of `Module.End ℝ E`, the three defining axioms of a heat semigroup fall
out by *composing* the parent cycles rather than re-deriving anything:

* **Semigroup law** `depthMap_semigroup`: `T^(a+b) = T^a ∘ T^b` — the algebraic
  shadow of `e^{−(a+b)Δ} = e^{−aΔ}e^{−bΔ}`. Depth is one-parameter (discrete) time.
* **Lyapunov dissipation** `mpStep_energy_nonincreasing`: the Dirichlet energy
  `⟪x,x⟫` never increases under a normalized layer (the `μ = 0` reading of the
  contraction bound). The flow is non-expansive.
* **Optimal spectral rate** `mpStep_optimal_rate`: at the spectral step `α = 1/λ`
  the residual energy decays as `(1 − μ/λ)ᵏ`, the cleanest possible rate.
* **Convergence to cohomology** `mpStep_tendsto_harmonic`: the depth-`k` output of a
  harmonic-plus-residual input converges *in the norm topology* of `E` to its
  harmonic component. The steady state of the flow **is** the harmonic projection.

## Results Summary

| Theorem | Statement | Built from |
|---|---|---|
| `depthMap_semigroup` | `T^(a+b) = T^a ∘ T^b` | `depthMap`, `pow_add` |
| `mpStep_energy_nonincreasing` | `⟪Tx,Tx⟫ ≤ ⟪x,x⟫` (normalized step) | `mpStep_contraction` at `μ=0` |
| `mpStep_optimal_rate` | `⟪Tᵏr,Tᵏr⟫ ≤ (1−μ/λ)ᵏ⟪r,r⟫` at `α=1/λ` | `contraction_factor_at_optimal`, `mpStep_iterate_contraction` |
| `mpStep_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm | `mpStep_dist_to_harmonic_bound`, squeeze |

All four are proved sorry-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The unifying observation — *deep Hodge message passing is a
contracting discrete heat semigroup whose unique steady state on each input is its
cohomology part* — is now fully formal.

## Research Directions

### 1. The exact steady-state operator is the orthogonal harmonic projection

The convergence theorem `mpStep_tendsto_harmonic` shows `Tᵏ(h+r) → h`, but it takes
the decomposition `x = h + r` (`L h = 0`) as *given*. The natural completion is to
prove that on a finite-dimensional (or complete) inner-product space the limit map
`x ↦ lim Tᵏ x` exists for *every* `x` and **equals the orthogonal projection
`orthogonalProjection (ker L)`**. The key insight is that `mpStep_energy_nonincreasing`
already makes `T` a non-expansive self-adjoint operator, so its powers form a bounded
monotone family on each spectral component; the harmonic block is fixed (eigenvalue
`1`) and every other block is a strict contraction, so the limit is the spectral
projector onto eigenvalue `1`, which is `orthogonalProjection (ker L)`. Why now? The
catalog already supplies the harmonic characterization `ker Δ = ker up ⊓ ker down`
(`ker_hodgeLaplacian`) and the per-block contraction; Mathlib's
`orthogonalProjection` and `OrthogonalFamily`/`Submodule.isCompl_orthogonal_of_completeSpace`
API close the remaining gap, turning the "steady state = projection" slogan into a
theorem rather than a heuristic.

### 2. Energy is *strictly* monotone off the harmonic block (a discrete Łojasiewicz bound)

`mpStep_energy_nonincreasing` gives `⟪Tx,Tx⟫ ≤ ⟪x,x⟫`; the falsifiable strengthening
is a **strict, quantitative** drop: if `x ⟂ ker L` and `μ` is the spectral gap, then
`⟪x,x⟫ − ⟪Tx,Tx⟫ ≥ c·⟪x,x⟫` for an explicit `c = αμ(2−αλ) > 0`. The key insight is
that the contraction factor `1 − αμ(2 − αλ)` from `mpStep_contraction` is *already*
the right Lyapunov decrement — it only needs to be re-read as a coercivity (gradient-
domination) inequality on the orthogonal complement, the discrete analogue of a
Łojasiewicz–Polyak inequality for the Dirichlet energy. Why now? Coercivity is the
single missing ingredient that converts the qualitative `Tendsto` of Direction 1 into
an *exponential* convergence-rate certificate with a fully explicit constant, and the
needed inequality is one `nlinarith` away from the existing contraction lemma.

### 3. Nonlinear message passing: contraction survives 1-Lipschitz activations

Real message-passing layers interleave the linear step `T = 1 − αΔ` with a
coordinatewise nonlinearity `σ` (ReLU, tanh). The conjecture: if `σ` is
`1`-Lipschitz and fixes the harmonic subspace pointwise (`σ(h) = h` for `Δh = 0`),
then the composite layer `σ ∘ T` is still a contraction toward `ker Δ` with the same
spectral rate `1 − μ/λ`. The key insight is that `mpStep_iterate_contraction` only
ever uses the *energy* recursion `⟪T(·),T(·)⟫ ≤ ρ⟪·,·⟫`, and a `1`-Lipschitz `σ`
fixing the harmonic part composes multiplicatively with that bound without touching
linearity — so the proof skeleton transfers verbatim once `T` is replaced by `σ ∘ T`
and the harmonic-fixed-point lemma is re-established for `σ`. Why now? This is the
first direction that genuinely *exits* the linear theory and connects the cycle to
practical (nonlinear) simplicial/graph neural networks, yet it costs almost no new
infrastructure because the contraction machinery is energy-based, not operator-based.

### 4. A continuous-time bridge: `Tᵏ` is the Lie–Trotter discretization of `e^{−tΔ}`

Having proved the discrete semigroup law `depthMap_semigroup`, the next unification is
to connect it to the *continuous* heat semigroup `e^{−tΔ}` on a finite-dimensional
`E`. The conjecture: `(1 − (t/n)·Δ)ⁿ → e^{−tΔ}` strongly as `n → ∞`, and the harmonic
projection is the common `t → ∞` limit of both. The key insight is that on
finite-dimensional `E` the operator exponential `Δ.exp` (Mathlib's `NormedSpace.exp`)
and the binomial expansion of `(1 − (t/n)Δ)ⁿ` agree term-by-term in the limit, so the
discrete-to-continuous passage is a `Tendsto` of matrix power series — and the steady
states match because `Δ` is PSD with kernel `ker Δ`. Why now? It places the
combinatorial/learning object (`depthMap`) and the analytic object (`exp(−tΔ)`) under
one roof, exactly the Grothendieck-style "special case of a deeper truth" the engine
is configured to seek, and Mathlib's `NormedSpace.exp` plus `tendsto_pow` give the
analytic backbone.

### 5. Closing the Carmichael tail: a height bound for the primitive part

Orthogonally to the Hodge thread, the catalog's `CarmichaelComposite.lean` /
`Shared/CarmichaelProof.lean` still contains a single load-bearing `sorry`: the
*infinite tail* of Carmichael's primitive-divisor theorem — every composite `n > 10000`
has a Fibonacci primitive prime divisor (the range `13 ≤ n ≤ 10000` is already settled
by `native_decide`). The key insight is that the primitive part `Φₙ` of `Fₙ` admits a
cyclotomic factorization `Fₙ = ∏_{d∣n} Φ_d`, and a Carmichael/Zsygmondy height bound
`|Φₙ| > n` (using `Fₙ ≥ φ^{n−2}` and a lifting-the-exponent control of the unique
possibly-imprimitive prime) forces `Φₙ > 1`, hence a primitive divisor; this purely
*analytic* lower bound is exactly what `primPart`/`fibCoprimePart` compute. Why now?
The combinatorial scaffolding (entry-point theory, `fib_dvd_gcd`, the coprime-part
algorithm and its correctness lemmas) is already proved sorry-free in the catalog — the
*only* missing piece is the growth/height estimate, which is a self-contained real-
analysis lemma that can be developed independently and then dropped into the existing
`fib_carmichael_composite` skeleton to eliminate the project's last open `sorry`.

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
