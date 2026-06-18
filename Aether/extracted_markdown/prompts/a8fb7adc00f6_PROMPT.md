
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

**Title**: The file `Computation/EastinKnill.lean` isolates the *algebraic kernel* of the
**Domain**: Logic
**Mathematical framing**: # Future Directions: The Eastin–Knill No-Go Theorem

The file `Computation/EastinKnill.lean` isolates the *algebraic kernel* of the
Eastin–Knill theorem in a fully rigorous, `sorry`-free, finite-dimensional matrix
setting over `ℂ`. A code is a Hermitian projector `P`; an operator is *detectable*
with scalar `c` when `P A P = c • P` (the compressed Knill–Laflamme condition).
The headline results are that detectable operators form a scalar-valued
linear/sum-closed family, that a transversal generator (a finite sum of detectable
single-site terms) compresses to a scalar `(∑ cᵢ)•P`, and that such generators are
**central** in the logical operator algebra — the precise obstruction to logical
universality (`eastin_knill_transversal_central`). The boundary theorem
`logical_noncentral_without_detection` shows the detection hypothesis is essential.

Below are five testable, falsifiable directions that extend this kernel toward the
full theorem and beyond.

## 1. From centrality to a genuine group-theoretic discreteness statement

The current `detectable_logical_central` proves the logical generator commutes with
*everything*; the next step is to show the connected component of the transversal
**gate group** acts trivially on the code, i.e. is contained in the global-phase
subgroup. Formalize a one-parameter family `t ↦ exp(t • (-I • A))` of unitaries and
prove that `P · exp(tA) · P = exp(t c) • P` whenever `A` is detectable, by
differentiating the matrix exponential and invoking `detectable_logical_central` at
the Lie-algebra level. **The key insight is** that commutation of the *generator*
with the whole logical algebra upgrades, via the Baker–Campbell–Hausdorff series, to
the *gate* acting as a pure phase — turning an infinitesimal statement into a global
one. **Why now?** Mathlib now has `NormedSpace.exp` with `exp_add` for commuting
elements and matrix-exponential derivative lemmas, so the analytic upgrade that was
previously out of reach is finally tractable on top of the algebraic core proved here.

## 2. Tensor-product realization of "single-site" detectability

We axiomatized single-site terms abstractly as detectable operators. The deeper claim
is geometric: an operator of the form `1 ⊗ … ⊗ Aᵢ ⊗ … ⊗ 1` acting on one tensor
factor of `(ℂ^d)^{⊗ n}` is *automatically* detectable for any distance-≥2 code.
Build `QECCode` instances from `TensorProduct`/`Matrix.kroneckerMap` and prove that
single-factor operators satisfy `P A P = c • P` directly from the Knill–Laflamme
distance condition. **The key insight is** that distance ≥ 2 is exactly the statement
that the code "cannot see" any single tensor factor, which is what forces the scalar
compression — so detectability is not an extra hypothesis but a *consequence* of code
distance. **Why now?** With the abstract centrality argument already discharged, the
only remaining gap to a textbook-faithful statement is this kronecker-product lemma,
which is pure linear algebra and ideally suited to the matrix API used here.

## 3. Quantitative / approximate Eastin–Knill

Real codes only *approximately* satisfy `P A P = c • P`. Define
`ApproxDetectable Q A c ε := ‖P A P − c • P‖ ≤ ε` and prove a stability theorem:
the logical commutator `‖[P A P, P B P]‖` is bounded by `2 ε ‖B‖` (a Lipschitz
version of `detectable_logical_central`), so near-detectable transversal generators
are *near*-central. **The key insight is** that the exact algebraic identity used in
`detectable_logical_central` degrades *linearly* in the detection error, which
quantifies exactly how much logical non-commutativity (hence computational power) a
code can buy per unit of detection violation — the modern "approximate QEC" refinement
of Eastin–Knill. **Why now?** Mathlib's matrix operator-norm and `‖·‖` sub-multiplicativity
lemmas make these inequalities provable, and the exact `ε = 0` case is already in hand
to anchor the bound.

## 4. Covariance and the Wigner–Araki–Yanase connection

Eastin–Knill is the discrete shadow of the Wigner–Araki–Yanase theorem: a conserved
*additive* charge `Q = ∑ Qᵢ` (a transversal Hamiltonian) cannot be measured/implemented
covariantly with perfect accuracy on a code. Formalize the charge as a
`TransversalGenerator`, prove `P Q P = (∑ cᵢ) • P` via `eastin_knill_transversal_scalar`,
and derive that the code carries *no* nontrivial logical charge — a clean no-go for
covariant codes. **The key insight is** that additivity of the conserved quantity is
*precisely* the `detectable_sum` closure we already proved, so charge conservation and
transversality are the same algebraic phenomenon viewed from two physical angles.
**Why now?** The summation lemma is done; only the (short) identification of the
physical charge with a transversal generator remains, making this a high-yield, low-cost
cross-domain bridge between quantum computation and quantum measurement theory.

## 5. Escaping the no-go: locating the largest non-central transversal subalgebra

The boundary theorem shows that *without* detection the logical algebra can be the full
(non-commutative) matrix algebra. Interpolate: for a code of distance exactly `d`,
characterize the maximal set of operators that remain detectable, and conjecture that
the transversal logical gates form precisely the normalizer of the stabilizer modulo
phases — a *finite* group whose order is computable from the code parameters.
**The key insight is** that the gap between "central/abelian" (perfect code) and "full
matrix algebra" (no code) is governed by a single integer, the code distance, so the
size of the achievable transversal gate set should be an explicit function of `(n, k, d)`.
**Why now?** With both extreme cases (`eastin_knill_transversal_central` and
`logical_noncentral_without_detection`) formalized, the project has the two endpoints
needed to state and test the interpolating conjecture computationally on small
stabilizer codes before attempting a general proof.

**Concept description**: # Future Directions: The Eastin–Knill No-Go Theorem

The file `Computation/EastinKnill.lean` isolates the *algebraic kernel* of the
Eastin–Knill theorem in a fully rigorous, `sorry`-free, finite-dimensional matrix
setting over `ℂ`. A code is a Hermitian projector `P`; an operator is *detectable*
with scalar `c` when `P A P = c • P` (the compressed Knill–Laflamme condition).
The headline results are that detectable operators form a scalar-valued
linear/sum-closed family, that a transversal generator (a finite sum of detectable
single-site terms) compresses to a scalar `(∑ cᵢ)•P`, and that such generators are
**central** in the logical operator algebra — the precise obstruction to logical
universality (`eastin_knill_transversal_central`). The boundary theorem
`logical_noncentral_without_detection` shows the detection hypothesis is essential.

Below are five testable, falsifiable directions that extend this kernel toward the
full theorem and beyond.

## 1. From centrality to a genuine group-theoretic discreteness statement

The current `detectable_logical_central` proves the logical generator commutes with
*everything*; the next step is to show the connected component of the transversal
**gate group** acts trivially on the code, i.e. is contained in the global-phase
subgroup. Formalize a one-parameter family `t ↦ exp(t • (-I • A))` of unitaries and
prove that `P · exp(tA) · P = exp(t c) • P` whenever `A` is detectable, by
differentiating the matrix exponential and invoking `detectable_logical_central` at
the Lie-algebra level. **The key insight is** that commutation of the *generator*
with the whole logical algebra upgrades, via the Baker–Campbell–Hausdorff series, to
the *gate* acting as a pure phase — turning an infinitesimal statement into a global
one. **Why now?** Mathlib now has `NormedSpace.exp` with `exp_add` for commuting
elements and matrix-exponential derivative lemmas, so the analytic upgrade that was
previously out of reach is finally tractable on top of the algebraic core proved here.

## 2. Tensor-product realization of "single-site" detectability

We axiomatized single-site terms abstractly as detectable operators. The deeper claim
is geometric: an operator of the form `1 ⊗ … ⊗ Aᵢ ⊗ … ⊗ 1` acting on one tensor
factor of `(ℂ^d)^{⊗ n}` is *automatically* detectable for any distance-≥2 code.
Build `QECCode` instances from `TensorProduct`/`Matrix.kroneckerMap` and prove that
single-factor operators satisfy `P A P = c • P` directly from the Knill–Laflamme
distance condition. **The key insight is** that distance ≥ 2 is exactly the statement
that the code "cannot see" any single tensor factor, which is what forces the scalar
compression — so detectability is not an extra hypothesis but a *consequence* of code
distance. **Why now?** With the abstract centrality argument already discharged, the
only remaining gap to a textbook-faithful statement is this kronecker-product lemma,
which is pure linear algebra and ideally suited to the matrix API used here.

## 3. Quantitative / approximate Eastin–Knill

Real codes only *approximately* satisfy `P A P = c • P`. Define
`ApproxDetectable Q A c ε := ‖P A P − c • P‖ ≤ ε` and prove a stability theorem:
the logical commutator `‖[P A P, P B P]‖` is bounded by `2 ε ‖B‖` (a Lipschitz
version of `detectable_logical_central`), so near-detectable transversal generators
are *near*-central. **The key insight is** that the exact algebraic identity used in
`detectable_logical_central` degrades *linearly* in the detection error, which
quantifies exactly how much logical non-commutativity (hence computational power) a
code can buy per unit of detection violation — the modern "approximate QEC" refinement
of Eastin–Knill. **Why now?** Mathlib's matrix operator-norm and `‖·‖` sub-multiplicativity
lemmas make these inequalities provable, and the exact `ε = 0` case is already in hand
to anchor the bound.

## 4. Covariance and the Wigner–Araki–Yanase connection

Eastin–Knill is the discrete shadow of the Wigner–Araki–Yanase theorem: a conserved
*additive* charge `Q = ∑ Qᵢ` (a transversal Hamiltonian) cannot be measured/implemented
covariantly with perfect accuracy on a code. Formalize the charge as a
`TransversalGenerator`, prove `P Q P = (∑ cᵢ) • P` via `eastin_knill_transversal_scalar`,
and derive that the code carries *no* nontrivial logical charge — a clean no-go for
covariant codes. **The key insight is** that additivity of the conserved quantity is
*precisely* the `detectable_sum` closure we already proved, so charge conservation and
transversality are the same algebraic phenomenon viewed from two physical angles.
**Why now?** The summation lemma is done; only the (short) identification of the
physical charge with a transversal generator remains, making this a high-yield, low-cost
cross-domain bridge between quantum computation and quantum measurement theory.

## 5. Escaping the no-go: locating the largest non-central transversal subalgebra

The boundary theorem shows that *without* detection the logical algebra can be the full
(non-commutative) matrix algebra. Interpolate: for a code of distance exactly `d`,
characterize the maximal set of operators that remain detectable, and conjecture that
the transversal logical gates form precisely the normalizer of the stabilizer modulo
phases — a *finite* group whose order is computable from the code parameters.
**The key insight is** that the gap between "central/abelian" (perfect code) and "full
matrix algebra" (no code) is governed by a single integer, the code distance, so the
size of the achievable transversal gate set should be an explicit function of `(n, k, d)`.
**Why now?** With both extreme cases (`eastin_knill_transversal_central` and
`logical_noncentral_without_detection`) formalized, the project has the two endpoints
needed to state and test the interpolating conjecture computationally on small
stabilizer codes before attempting a general proof.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
