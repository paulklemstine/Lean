
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

**Title**: The current formalization works with fixed Rademacher sign vectors. The natural 
**Domain**: Applications
**Mathematical framing**: # Future Directions: Rademacher Complexity and Generalization Bounds

## 1. Measure-Theoretic Rademacher Complexity via Expectation

The current formalization works with fixed Rademacher sign vectors. The natural next step is to define the *expected* empirical Rademacher complexity as the expectation over all 2^n Rademacher sign assignments: R_n(H) = E_σ[sup_{h∈H} (1/n)∑ σᵢh(xᵢ)]. This requires summing over `Fin n → {-1,1}` (a `Fintype`) and averaging. The key insight is that `Finset.univ` on `Fin n → Fin 2` gives us all 2^n sign patterns, making the expectation a finite sum that avoids measure theory entirely while being mathematically precise. Why now? The `rademacherCorrelation` and `isRademacher_abs_eq_one` infrastructure is in place, and Mathlib's `Fintype` instances for function types provide the combinatorial backbone.

## 2. Symmetrization Lemma and Generalization Gap

The symmetrization lemma states that E[sup_{h∈H} |R(h) - R̂_n(h)|] ≤ 2·R_n(H), connecting the generalization gap to Rademacher complexity. Formalizing this requires a "ghost sample" argument: introduce an independent copy of the data, use the triangle inequality, then introduce Rademacher signs by the symmetry of the ghost sample. The key insight is that the proof reduces to showing that replacing xᵢ with x'ᵢ is equivalent to multiplying by a Rademacher sign, which is a purely combinatorial argument when samples are drawn from a finite distribution. Why now? The boundedness theorem (`rademacher_correlation_bounded`) and monotonicity (`rademacher_sup_monotone`) provide the inequality scaffolding needed.

## 3. Multi-Layer Neural Network Complexity via Inductive Composition

The spectral norm composition bound (`spectral_norm_correlation_bound`) handles one linear layer. For an L-layer network with activation functions, we need an inductive argument: compose L applications of the spectral bound with contraction from Lipschitz activations (ReLU has Lipschitz constant 1). The conjecture is that for an L-layer network with spectral norm bounds C₁,...,C_L and 1-Lipschitz activations, the sum of squared output correlations is bounded by (∏ Cₗ²) times the sum of squared input correlations. The key insight is that this is a straightforward induction on L using `spectral_norm_correlation_bound` at each step, with the contraction principle (to be formalized) handling the nonlinear activations between layers. Why now? The single-layer bound is proved, and the inductive structure maps cleanly onto `Nat.rec`.

## 4. Finite Class Rademacher Bound via Massart's Lemma

For a finite hypothesis class H with |H| = m, the expected Rademacher complexity satisfies R_n(H) ≤ max_{h∈H} ‖h‖₂ · √(2 ln m) / n. This is Massart's lemma, which gives the tightest known bound for finite classes. The key insight is that the proof uses the exponential moment method: for any λ > 0, E[exp(λ sup)] ≤ ∑ E[exp(λ·correlation)] ≤ m·exp(λ²B²/(2n)) by Hoeffding's lemma applied to each coordinate, then optimize over λ. Why now? The `rademacher_correlation_bounded` theorem provides the B-boundedness needed for Hoeffding's lemma, and the finite class structure means the union bound is a simple `Finset.sum_le_card_nsmul`.

## 5. PAC-Bayes Generalization via KL Divergence

The PAC-Bayes theorem provides tighter generalization bounds for stochastic predictors: for any posterior Q over H and prior P, E_Q[R(h)] ≤ E_Q[R̂(h)] + √(KL(Q‖P) + ln(n/δ))/(2(n-1))). This extends our deterministic bounds to the Bayesian setting. The key insight is that the KL divergence term replaces the log-cardinality term from Massart's lemma, allowing continuous hypothesis spaces while maintaining finite-dimensional tractability. Formalizing KL divergence for distributions over finite sets is straightforward using `Finset.sum` and `Real.log`. Why now? The empirical risk infrastructure (`empiricalRisk`, `empirical_risk_bounded`) is ready, and the PAC-Bayes bound is the natural bridge between our Rademacher framework and modern deep learning theory where weight distributions (rather than individual weights) are the primary object of study.

**Concept description**: # Future Directions: Rademacher Complexity and Generalization Bounds

## 1. Measure-Theoretic Rademacher Complexity via Expectation

The current formalization works with fixed Rademacher sign vectors. The natural next step is to define the *expected* empirical Rademacher complexity as the expectation over all 2^n Rademacher sign assignments: R_n(H) = E_σ[sup_{h∈H} (1/n)∑ σᵢh(xᵢ)]. This requires summing over `Fin n → {-1,1}` (a `Fintype`) and averaging. The key insight is that `Finset.univ` on `Fin n → Fin 2` gives us all 2^n sign patterns, making the expectation a finite sum that avoids measure theory entirely while being mathematically precise. Why now? The `rademacherCorrelation` and `isRademacher_abs_eq_one` infrastructure is in place, and Mathlib's `Fintype` instances for function types provide the combinatorial backbone.

## 2. Symmetrization Lemma and Generalization Gap

The symmetrization lemma states that E[sup_{h∈H} |R(h) - R̂_n(h)|] ≤ 2·R_n(H), connecting the generalization gap to Rademacher complexity. Formalizing this requires a "ghost sample" argument: introduce an independent copy of the data, use the triangle inequality, then introduce Rademacher signs by the symmetry of the ghost sample. The key insight is that the proof reduces to showing that replacing xᵢ with x'ᵢ is equivalent to multiplying by a Rademacher sign, which is a purely combinatorial argument when samples are drawn from a finite distribution. Why now? The boundedness theorem (`rademacher_correlation_bounded`) and monotonicity (`rademacher_sup_monotone`) provide the inequality scaffolding needed.

## 3. Multi-Layer Neural Network Complexity via Inductive Composition

The spectral norm composition bound (`spectral_norm_correlation_bound`) handles one linear layer. For an L-layer network with activation functions, we need an inductive argument: compose L applications of the spectral bound with contraction from Lipschitz activations (ReLU has Lipschitz constant 1). The conjecture is that for an L-layer network with spectral norm bounds C₁,...,C_L and 1-Lipschitz activations, the sum of squared output correlations is bounded by (∏ Cₗ²) times the sum of squared input correlations. The key insight is that this is a straightforward induction on L using `spectral_norm_correlation_bound` at each step, with the contraction principle (to be formalized) handling the nonlinear activations between layers. Why now? The single-layer bound is proved, and the inductive structure maps cleanly onto `Nat.rec`.

## 4. Finite Class Rademacher Bound via Massart's Lemma

For a finite hypothesis class H with |H| = m, the expected Rademacher complexity satisfies R_n(H) ≤ max_{h∈H} ‖h‖₂ · √(2 ln m) / n. This is Massart's lemma, which gives the tightest known bound for finite classes. The key insight is that the proof uses the exponential moment method: for any λ > 0, E[exp(λ sup)] ≤ ∑ E[exp(λ·correlation)] ≤ m·exp(λ²B²/(2n)) by Hoeffding's lemma applied to each coordinate, then optimize over λ. Why now? The `rademacher_correlation_bounded` theorem provides the B-boundedness needed for Hoeffding's lemma, and the finite class structure means the union bound is a simple `Finset.sum_le_card_nsmul`.

## 5. PAC-Bayes Generalization via KL Divergence

The PAC-Bayes theorem provides tighter generalization bounds for stochastic predictors: for any posterior Q over H and prior P, E_Q[R(h)] ≤ E_Q[R̂(h)] + √(KL(Q‖P) + ln(n/δ))/(2(n-1))). This extends our deterministic bounds to the Bayesian setting. The key insight is that the KL divergence term replaces the log-cardinality term from Massart's lemma, allowing continuous hypothesis spaces while maintaining finite-dimensional tractability. Formalizing KL divergence for distributions over finite sets is straightforward using `Finset.sum` and `Real.log`. Why now? The empirical risk infrastructure (`empiricalRisk`, `empirical_risk_bounded`) is ready, and the PAC-Bayes bound is the natural bridge between our Rademacher framework and modern deep learning theory where weight distributions (rather than individual weights) are the primary object of study.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
