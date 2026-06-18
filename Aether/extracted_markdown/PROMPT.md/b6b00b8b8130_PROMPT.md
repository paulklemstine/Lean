
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

**Title**: This cycle established, in `Catalog/Logic/IdempotentProbabilityLDP.lean`, the
**Domain**: Applications
**Mathematical framing**: # Future Directions — Idempotent Probability: Large Deviations

This cycle established, in `Catalog/Logic/IdempotentProbabilityLDP.lean`, the
backbone of an *exact* (limit-free) large deviation theory for max-plus probability
measures: the semiclassical bridge `t⁻¹·log ∑ exp(t·aᵢ) → max aᵢ`
(`tropical_laplace_limit`), convexity of the idempotent cumulant generating function
(`cumulant_convexOn`), additivity of the cumulant under max-plus convolution
(`cumulant_conv`, `cumulant_convPow`), and the Legendre–Fenchel identity together with
the Fenchel–Young inequality (`cumulant_eq_legendre`, `fenchel_young`). The following
directions extend this frontier and are each concrete enough to refute by a single
counterexample or to settle by a single Lean theorem.

## 1. Fenchel–Moreau biconjugation: the rate function is the convex hull

The cumulant `Λ` is the Legendre–Fenchel transform of the rate function `I = -pot`,
and `Λ` is convex. The natural completion is the *double* transform: defining the
biconjugate `I** (z) = sup_s (s·z - Λ(s))`, conjecture that `I**` equals the lower
convex hull of `I` over the support, and that `I** = I` exactly when the points
`(ptsᵢ, -potᵢ)` already lie on a convex curve. Equality of `Λ` evaluated at a support
point with the Fenchel–Young bound should characterize the *exposed* atoms.

The key insight is that in idempotent probability the Fenchel–Moreau theorem is not an
asymptotic statement but a finite combinatorial fact about which atoms survive on the
upper boundary of the Newton-style polygon of `(ptsᵢ, potᵢ)`. Why now? We already have
`cumulant_eq_legendre` and `fenchel_young` in place, so the only missing ingredient is
the reverse `sup`-over-`s` direction, which reduces to a finite convex-hull extremality
argument that the prover handled cleanly for the forward inequalities.

## 2. A Gärtner–Ellis theorem for the semiclassical limit

`tropical_laplace_limit` shows the temperature-scaled free energy of a *fixed* family
converges to its max. The Gärtner–Ellis upgrade replaces the fixed family by a
sequence whose scaled cumulants `t⁻¹·Λ_t(t·s)` converge to a limiting convex `Λ∞(s)`;
conjecture that then the empirical law satisfies an LDP with rate `Λ∞*`. A falsifiable
finite instance: for triangular arrays `a^{(t)} : Fin n → ℝ` with `a^{(t)}_i → a_i`,
the limit of the free energies equals `max_i a_i`.

The key insight is that the `log ∑ exp` / `max` sandwich (`max_le_log_sum_exp` and
`log_sum_exp_le_max_add_log_card`) is uniform in the entries, so convergence of the
entries transfers directly to convergence of the free energy without any
probabilistic machinery. Why now? The two-sided estimate is already isolated as
`freeEnergy_bounds`, and a uniform-in-`t` version is a routine `Filter`-level
strengthening of the squeeze already used in `tropical_laplace_limit`.

## 3. Varadhan's lemma in the idempotent semiring

Classical Varadhan computes `lim t⁻¹ log ∫ exp(t·g) dμ_t = sup_x (g(x) - I(x))`.
Conjecture the *exact* idempotent analogue: for a max-plus measure with potential
`pot` and any bounded `g`, the idempotent integral `max_i (pot_i + g(pts_i))` equals
`sup_x (g(x) - I(x))` over the support, with **equality and no error term**, and that
this is precisely the `t → ∞` limit of `t⁻¹ log ∑_i exp(t·(pot_i + g(pts_i)))`.

The key insight is that Varadhan's lemma collapses, in the `(max, +)` semiring, to the
defining property of `sup'` — the asymptotic integral *is* the idempotent integral, so
the "variational formula" becomes a definitional identity rather than a theorem. Why
now? `cumulant` is exactly the special case `g = s·pts`, and `tropical_laplace_limit`
already proves the `t → ∞` collapse for that `g`; generalizing the test function `g`
reuses the same sandwich verbatim.

## 4. Contraction principle under affine (and Lipschitz) push-forward

If `T : ℝ → ℝ` is affine, the push-forward of a max-plus measure has rate function
`I_T(y) = inf{ I(x) : T(x) = y }`. Conjecture the exact contraction identity
`Λ_{T_* μ}(s) = Λ_μ(scale·s) + s·shift` for `T(x) = scale·x + shift`, and more
generally that for monotone `T` the cumulant transforms by precomposition with the
Legendre dual of `T`. A clean falsifiable corollary: the empirical-mean map
`Sₙ ↦ Sₙ/n` sends the `n`-fold cumulant `n·Λ` to `Λ` itself, recovering an
`n`-independent rate.

The key insight is that contraction in idempotent probability is just functoriality of
`sup'` under reindexing, so `inf`-convolution of rate functions corresponds to addition
of cumulants — exactly the additivity already proved in `cumulant_conv`. Why now? The
two-step and `n`-step additivity theorems (`cumulant_conv`, `cumulant_convPow`) are the
hard half; the affine push-forward is a one-line reparametrization of `cumulant`.

## 5. Tropical Cramér rate for the empirical mean, with a sharp scaling law

Combining 1 and 4, conjecture the headline idempotent Cramér theorem: the empirical
mean of `n` i.i.d. max-plus steps has rate function `I = Λ_X*` *exactly for every `n`*,
and the deviation cost of observing mean `z` is `n · I(z)` with the optimal cost
realized by the constant argmax trajectory. The falsifiable sharpness claim: no
trajectory achieves mean `z` at cost strictly below `n·I(z)`, and the bound is
attained, so the inequality in `fenchel_young` becomes an equality precisely on the
convex hull of the support.

The key insight is that the linear scaling `Λ_{Sₙ} = n·Λ_X` from `cumulant_convPow`
forces the per-step rate to be `n`-independent, turning the classical *asymptotic*
Cramér statement into an *exact finite-`n*` law — the defining miracle of idempotent
probability. Why now? `cumulant_convPow` already delivers the exact `n`-scaling, and
`sup'_pi_sum` even exhibits the optimal constant-argmax trajectory, so the extremal
(attainment) half of Cramér is essentially constructed and only needs to be packaged
as a standalone optimality theorem.

**Concept description**: # Future Directions — Idempotent Probability: Large Deviations

This cycle established, in `Catalog/Logic/IdempotentProbabilityLDP.lean`, the
backbone of an *exact* (limit-free) large deviation theory for max-plus probability
measures: the semiclassical bridge `t⁻¹·log ∑ exp(t·aᵢ) → max aᵢ`
(`tropical_laplace_limit`), convexity of the idempotent cumulant generating function
(`cumulant_convexOn`), additivity of the cumulant under max-plus convolution
(`cumulant_conv`, `cumulant_convPow`), and the Legendre–Fenchel identity together with
the Fenchel–Young inequality (`cumulant_eq_legendre`, `fenchel_young`). The following
directions extend this frontier and are each concrete enough to refute by a single
counterexample or to settle by a single Lean theorem.

## 1. Fenchel–Moreau biconjugation: the rate function is the convex hull

The cumulant `Λ` is the Legendre–Fenchel transform of the rate function `I = -pot`,
and `Λ` is convex. The natural completion is the *double* transform: defining the
biconjugate `I** (z) = sup_s (s·z - Λ(s))`, conjecture that `I**` equals the lower
convex hull of `I` over the support, and that `I** = I` exactly when the points
`(ptsᵢ, -potᵢ)` already lie on a convex curve. Equality of `Λ` evaluated at a support
point with the Fenchel–Young bound should characterize the *exposed* atoms.

The key insight is that in idempotent probability the Fenchel–Moreau theorem is not an
asymptotic statement but a finite combinatorial fact about which atoms survive on the
upper boundary of the Newton-style polygon of `(ptsᵢ, potᵢ)`. Why now? We already have
`cumulant_eq_legendre` and `fenchel_young` in place, so the only missing ingredient is
the reverse `sup`-over-`s` direction, which reduces to a finite convex-hull extremality
argument that the prover handled cleanly for the forward inequalities.

## 2. A Gärtner–Ellis theorem for the semiclassical limit

`tropical_laplace_limit` shows the temperature-scaled free energy of a *fixed* family
converges to its max. The Gärtner–Ellis upgrade replaces the fixed family by a
sequence whose scaled cumulants `t⁻¹·Λ_t(t·s)` converge to a limiting convex `Λ∞(s)`;
conjecture that then the empirical law satisfies an LDP with rate `Λ∞*`. A falsifiable
finite instance: for triangular arrays `a^{(t)} : Fin n → ℝ` with `a^{(t)}_i → a_i`,
the limit of the free energies equals `max_i a_i`.

The key insight is that the `log ∑ exp` / `max` sandwich (`max_le_log_sum_exp` and
`log_sum_exp_le_max_add_log_card`) is uniform in the entries, so convergence of the
entries transfers directly to convergence of the free energy without any
probabilistic machinery. Why now? The two-sided estimate is already isolated as
`freeEnergy_bounds`, and a uniform-in-`t` version is a routine `Filter`-level
strengthening of the squeeze already used in `tropical_laplace_limit`.

## 3. Varadhan's lemma in the idempotent semiring

Classical Varadhan computes `lim t⁻¹ log ∫ exp(t·g) dμ_t = sup_x (g(x) - I(x))`.
Conjecture the *exact* idempotent analogue: for a max-plus measure with potential
`pot` and any bounded `g`, the idempotent integral `max_i (pot_i + g(pts_i))` equals
`sup_x (g(x) - I(x))` over the support, with **equality and no error term**, and that
this is precisely the `t → ∞` limit of `t⁻¹ log ∑_i exp(t·(pot_i + g(pts_i)))`.

The key insight is that Varadhan's lemma collapses, in the `(max, +)` semiring, to the
defining property of `sup'` — the asymptotic integral *is* the idempotent integral, so
the "variational formula" becomes a definitional identity rather than a theorem. Why
now? `cumulant` is exactly the special case `g = s·pts`, and `tropical_laplace_limit`
already proves the `t → ∞` collapse for that `g`; generalizing the test function `g`
reuses the same sandwich verbatim.

## 4. Contraction principle under affine (and Lipschitz) push-forward

If `T : ℝ → ℝ` is affine, the push-forward of a max-plus measure has rate function
`I_T(y) = inf{ I(x) : T(x) = y }`. Conjecture the exact contraction identity
`Λ_{T_* μ}(s) = Λ_μ(scale·s) + s·shift` for `T(x) = scale·x + shift`, and more
generally that for monotone `T` the cumulant transforms by precomposition with the
Legendre dual of `T`. A clean falsifiable corollary: the empirical-mean map
`Sₙ ↦ Sₙ/n` sends the `n`-fold cumulant `n·Λ` to `Λ` itself, recovering an
`n`-independent rate.

The key insight is that contraction in idempotent probability is just functoriality of
`sup'` under reindexing, so `inf`-convolution of rate functions corresponds to addition
of cumulants — exactly the additivity already proved in `cumulant_conv`. Why now? The
two-step and `n`-step additivity theorems (`cumulant_conv`, `cumulant_convPow`) are the
hard half; the affine push-forward is a one-line reparametrization of `cumulant`.

## 5. Tropical Cramér rate for the empirical mean, with a sharp scaling law

Combining 1 and 4, conjecture the headline idempotent Cramér theorem: the empirical
mean of `n` i.i.d. max-plus steps has rate function `I = Λ_X*` *exactly for every `n`*,
and the deviation cost of observing mean `z` is `n · I(z)` with the optimal cost
realized by the constant argmax trajectory. The falsifiable sharpness claim: no
trajectory achieves mean `z` at cost strictly below `n·I(z)`, and the bound is
attained, so the inequality in `fenchel_young` becomes an equality precisely on the
convex hull of the support.

The key insight is that the linear scaling `Λ_{Sₙ} = n·Λ_X` from `cumulant_convPow`
forces the per-step rate to be `n`-independent, turning the classical *asymptotic*
Cramér statement into an *exact finite-`n*` law — the defining miracle of idempotent
probability. Why now? `cumulant_convPow` already delivers the exact `n`-scaling, and
`sup'_pi_sum` even exhibits the optimal constant-argmax trajectory, so the extremal
(attainment) half of Cramér is essentially constructed and only needs to be packaged
as a standalone optimality theorem.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
