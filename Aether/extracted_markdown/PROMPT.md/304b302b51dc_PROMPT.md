
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

**Title**: The fifth cycle established *pointwise* convergence of gradient message passing
**Domain**: Applications
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

The fifth cycle established *pointwise* convergence of gradient message passing
`T = 1 - α·L` to the harmonic (cohomology) subspace: the harmonic part of any input
is transported exactly through every depth while the residual contracts at the
spectral rate (`HodgeMessagePassingConvergence`). This cycle lifts that single-orbit
picture to **global, integrated energy laws** for the whole operator family
(`HodgeMessagePassingEnergy`):

1. **Heterogeneous depth commutes** — layers `1 - α·L` and `1 - β·L` of *different*
   learning rates commute, and so do their powers (`mpStep_comm`,
   `mpStep_comm_iterate`). A deep network with an arbitrary *schedule* of step sizes
   depends only on the multiset of rates, not their order.
2. **Energy is antitone in depth** — under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite** — for a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`). This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge
   heat flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down`
   in `hodge_total_energy_bound`.

Together with the catalog foundation (`HodgeSpectralThreshold.harmonic_iff`,
`ker_hodgeLaplacian`, `mode_decay`, `depth_threshold`) this gives a complete
algebraic + analytic dossier for one operator family. The directions below push it
toward genuinely new mathematics.

## Results Summary

| Theorem | Statement |
| --- | --- |
| `mpStep_comm` | `(1−α·L)(1−β·L) = (1−β·L)(1−α·L)` for any `L`, `α`, `β`. |
| `mpStep_comm_iterate` | `Tα^m · Tβ^n = Tβ^n · Tα^m`. |
| `mpStep_energy_antitone` | `⟪T^{k+1}r⟫ ≤ ⟪T^k r⟫` when `ρ ≤ 1`. |
| `mpStep_partial_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ (∑_{k<n} ρ^k)·⟪r,r⟫`. |
| `mpStep_total_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)` for `0 ≤ ρ < 1`. |
| `hodge_total_energy_bound` | the budget instantiated at `Δ = up + down`. |

All six are proved with no `sorry`, depending only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The total-energy budget is sharp, and the gap to it measures the spectral gap

`mpStep_total_energy_bound` proves `∑_k ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)`. Conjecture: when
`r` is a single eigenvector of `L` with eigenvalue `λ` and the step is `α`, the
inequality is an *equality* with `ρ = (1−αλ)²`, and for general `r` the deficit
`⟪r,r⟫/(1−ρ) − ∑_k ⟪T^k r⟫` is a positive-definite quadratic form whose smallest
eigenvalue is controlled by the spectral gap `μ`. The key insight is that on each
eigenline message passing is an exact geometric series, so the only slack in the
bound comes from *mixing* eigenvalues — making the deficit a direct, computable
probe of the spectrum. Why now? We already have the per-mode dynamics
(`HodgeSpectralThreshold.mode_decay`) and the aggregate bound in the same library;
the equality case is a finite eigen-expansion away and needs no new analysis.

### 2. Optimal *schedules* beat constant steps, and order genuinely does not matter

Because `mpStep_comm_iterate` makes a heterogeneous schedule order-independent, the
depth-`k` operator is `∏_{i<k}(1 − α_i·L)`, a degree-`k` polynomial in `L` vanishing
nowhere on `ker L`. Conjecture: choosing `{α_i}` to be the reciprocals of Chebyshev
nodes on `[μ, λ_max]` minimises the worst-case residual energy over the spectrum,
strictly beating any constant step for `k ≥ 2`, with an explicit
`1/T_k((λ_max+μ)/(λ_max−μ))` rate. The key insight is that order-independence turns
schedule design into *polynomial approximation on the spectrum* — exactly the
setting where Chebyshev polynomials are extremal. Why now? `mpStep_comm` /
`mpStep_comm_iterate` are the precise algebraic fact (commuting layers ⇒ a single
product polynomial) that legitimises importing the Chebyshev acceleration theory;
the polynomial framing is now formally available.

### 3. The discrete Dirichlet action Γ-converges to the continuous Hodge flow

`mpStep_total_energy_bound` is the discrete analogue of `∫₀^∞ ‖∇u(t)‖² dt < ∞`.
Conjecture: as the step `α → 0` with depth `k ≈ t/α`, the discrete total energy
`α·∑_{k<t/α} ⟪T^k r⟫` converges to the continuous Dirichlet action
`∫₀^t ⟪e^{−sL} r, L e^{−sL} r⟫ ds` of the Hodge heat semigroup, and the harmonic
limit of `T^k` coincides with the orthogonal projector onto `ker L`. The key insight
is that the geometric budget `⟪r,r⟫/(1−ρ)` is the Riemann sum of the exponential
integral, so the discrete law is not an analogy but a quadrature of the continuous
one. Why now? The uniform-in-`n` bound proved here is exactly the equi-coercivity
hypothesis a Γ-convergence / semigroup-limit argument needs, and Mathlib now carries
enough one-parameter semigroup theory to state the limit.

### 4. A cross-domain bridge: integrated energy bounds expander mixing on the up-Laplacian

The catalog has an expander program (`Algebra/ExpanderWalk/Amplification`,
`ClassicalGroupExpanders`). Conjecture: instantiating `L` as the *normalised
up-Hodge Laplacian* of an expander complex, the finite total-energy budget
`⟪r,r⟫/(1−ρ)` with `ρ = 1 − gap` reproduces and quantitatively sharpens the
expander-mixing lemma for `k`-dimensional simplicial walks, with the spectral gap of
`Δ` replacing the second graph eigenvalue. The key insight is that message-passing
energy decay and random-walk mixing are the *same* operator inequality read in two
languages — Dirichlet-energy contraction versus L²-mixing. Why now? Both halves now
live in this catalog with compatible self-adjoint-PSD interfaces, so the bridge is a
matter of matching hypotheses rather than building new spectral theory.

### 5. Antitonicity characterises admissible (stable) learning rates exactly

`mpStep_energy_antitone` assumes a sub-unital contraction (`ρ ≤ 1`). Conjecture: for
a self-adjoint PSD `L` with top eigenvalue `λ_max`, per-layer energy antitonicity for
*all* inputs holds **iff** `0 ≤ α ≤ 2/λ_max`, and the boundary `α = 2/λ_max` is the
unique step where some mode is merely preserved (energy constant) rather than
strictly decreased. The key insight is that antitonicity is equivalent to the
operator inequality `0 ≼ T ≼ 1`, i.e. `‖1 − αL‖ ≤ 1`, which is a clean spectral
condition on `α`. Why now? The forward direction is one short step from the proved
`mpStep_contraction`/`mpStep_energy_antitone`; the converse needs only a single
extremal eigenvector, giving a falsifiable iff that pins down the stability region.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

The fifth cycle established *pointwise* convergence of gradient message passing
`T = 1 - α·L` to the harmonic (cohomology) subspace: the harmonic part of any input
is transported exactly through every depth while the residual contracts at the
spectral rate (`HodgeMessagePassingConvergence`). This cycle lifts that single-orbit
picture to **global, integrated energy laws** for the whole operator family
(`HodgeMessagePassingEnergy`):

1. **Heterogeneous depth commutes** — layers `1 - α·L` and `1 - β·L` of *different*
   learning rates commute, and so do their powers (`mpStep_comm`,
   `mpStep_comm_iterate`). A deep network with an arbitrary *schedule* of step sizes
   depends only on the multiset of rates, not their order.
2. **Energy is antitone in depth** — under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite** — for a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`). This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge
   heat flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down`
   in `hodge_total_energy_bound`.

Together with the catalog foundation (`HodgeSpectralThreshold.harmonic_iff`,
`ker_hodgeLaplacian`, `mode_decay`, `depth_threshold`) this gives a complete
algebraic + analytic dossier for one operator family. The directions below push it
toward genuinely new mathematics.

## Results Summary

| Theorem | Statement |
| --- | --- |
| `mpStep_comm` | `(1−α·L)(1−β·L) = (1−β·L)(1−α·L)` for any `L`, `α`, `β`. |
| `mpStep_comm_iterate` | `Tα^m · Tβ^n = Tβ^n · Tα^m`. |
| `mpStep_energy_antitone` | `⟪T^{k+1}r⟫ ≤ ⟪T^k r⟫` when `ρ ≤ 1`. |
| `mpStep_partial_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ (∑_{k<n} ρ^k)·⟪r,r⟫`. |
| `mpStep_total_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)` for `0 ≤ ρ < 1`. |
| `hodge_total_energy_bound` | the budget instantiated at `Δ = up + down`. |

All six are proved with no `sorry`, depending only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The total-energy budget is sharp, and the gap to it measures the spectral gap

`mpStep_total_energy_bound` proves `∑_k ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)`. Conjecture: when
`r` is a single eigenvector of `L` with eigenvalue `λ` and the step is `α`, the
inequality is an *equality* with `ρ = (1−αλ)²`, and for general `r` the deficit
`⟪r,r⟫/(1−ρ) − ∑_k ⟪T^k r⟫` is a positive-definite quadratic form whose smallest
eigenvalue is controlled by the spectral gap `μ`. The key insight is that on each
eigenline message passing is an exact geometric series, so the only slack in the
bound comes from *mixing* eigenvalues — making the deficit a direct, computable
probe of the spectrum. Why now? We already have the per-mode dynamics
(`HodgeSpectralThreshold.mode_decay`) and the aggregate bound in the same library;
the equality case is a finite eigen-expansion away and needs no new analysis.

### 2. Optimal *schedules* beat constant steps, and order genuinely does not matter

Because `mpStep_comm_iterate` makes a heterogeneous schedule order-independent, the
depth-`k` operator is `∏_{i<k}(1 − α_i·L)`, a degree-`k` polynomial in `L` vanishing
nowhere on `ker L`. Conjecture: choosing `{α_i}` to be the reciprocals of Chebyshev
nodes on `[μ, λ_max]` minimises the worst-case residual energy over the spectrum,
strictly beating any constant step for `k ≥ 2`, with an explicit
`1/T_k((λ_max+μ)/(λ_max−μ))` rate. The key insight is that order-independence turns
schedule design into *polynomial approximation on the spectrum* — exactly the
setting where Chebyshev polynomials are extremal. Why now? `mpStep_comm` /
`mpStep_comm_iterate` are the precise algebraic fact (commuting layers ⇒ a single
product polynomial) that legitimises importing the Chebyshev acceleration theory;
the polynomial framing is now formally available.

### 3. The discrete Dirichlet action Γ-converges to the continuous Hodge flow

`mpStep_total_energy_bound` is the discrete analogue of `∫₀^∞ ‖∇u(t)‖² dt < ∞`.
Conjecture: as the step `α → 0` with depth `k ≈ t/α`, the discrete total energy
`α·∑_{k<t/α} ⟪T^k r⟫` converges to the continuous Dirichlet action
`∫₀^t ⟪e^{−sL} r, L e^{−sL} r⟫ ds` of the Hodge heat semigroup, and the harmonic
limit of `T^k` coincides with the orthogonal projector onto `ker L`. The key insight
is that the geometric budget `⟪r,r⟫/(1−ρ)` is the Riemann sum of the exponential
integral, so the discrete law is not an analogy but a quadrature of the continuous
one. Why now? The uniform-in-`n` bound proved here is exactly the equi-coercivity
hypothesis a Γ-convergence / semigroup-limit argument needs, and Mathlib now carries
enough one-parameter semigroup theory to state the limit.

### 4. A cross-domain bridge: integrated energy bounds expander mixing on the up-Laplacian

The catalog has an expander program (`Algebra/ExpanderWalk/Amplification`,
`ClassicalGroupExpanders`). Conjecture: instantiating `L` as the *normalised
up-Hodge Laplacian* of an expander complex, the finite total-energy budget
`⟪r,r⟫/(1−ρ)` with `ρ = 1 − gap` reproduces and quantitatively sharpens the
expander-mixing lemma for `k`-dimensional simplicial walks, with the spectral gap of
`Δ` replacing the second graph eigenvalue. The key insight is that message-passing
energy decay and random-walk mixing are the *same* operator inequality read in two
languages — Dirichlet-energy contraction versus L²-mixing. Why now? Both halves now
live in this catalog with compatible self-adjoint-PSD interfaces, so the bridge is a
matter of matching hypotheses rather than building new spectral theory.

### 5. Antitonicity characterises admissible (stable) learning rates exactly

`mpStep_energy_antitone` assumes a sub-unital contraction (`ρ ≤ 1`). Conjecture: for
a self-adjoint PSD `L` with top eigenvalue `λ_max`, per-layer energy antitonicity for
*all* inputs holds **iff** `0 ≤ α ≤ 2/λ_max`, and the boundary `α = 2/λ_max` is the
unique step where some mode is merely preserved (energy constant) rather than
strictly decreased. The key insight is that antitonicity is equivalent to the
operator inequality `0 ≼ T ≼ 1`, i.e. `‖1 − αL‖ ≤ 1`, which is a clean spectral
condition on `α`. Why now? The forward direction is one short step from the proved
`mpStep_contraction`/`mpStep_energy_antitone`; the converse needs only a single
extremal eigenvector, giving a falsifiable iff that pins down the stability region.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
