
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

**Title**: Chaos as a Computable Shadow: The Shadowing Lemma for Real Programs
**Domain**: Geometry
**Mathematical framing**: The shadowing lemma says that near an approximate orbit of a chaotic system, there exists a true orbit. In other words, every 'almost correct' trajectory of a chaotic map has a 'truly correct' trajectory nearby. This means that numerical errors in chaotic simulations are not bugs — they are SHADOWS of real trajectories. Conjecture: Every program that computes a chaotic map f: R^n -> R^n has the property that its floating-point output is shadowed by a true orbit of f. More precisely, for every epsilon > 0, there exists delta > 0 such that if x_0, x_1, ..., x_N is a delta-pseudo-orbit (|x_{n+1} - f(x_n)| < delta for all n), then there exists a true orbit y_0, y_1, ..., y_N with |x_n - y_n| < epsilon for all n. The shadowing time N(epsilon, delta) grows at most polynomially in 1/delta for hyperbolic maps. Test: implement the logistic map f(x) = 4x(1-x) in floating-point and compute 10^6 iterations. For each floating-point orbit, use binary search to find the shadowing true orbit. Verify that the shadowing distance is at most 10^{-10} for floating-point precision 10^{-16}. Impact: numerical chaos is not error — it is a computable shadow of mathematical truth. Your computer's rounding errors are tracing out REAL orbits of the chaotic system.
**Concept description**: The shadowing lemma says that near an approximate orbit of a chaotic system, there exists a true orbit. In other words, every 'almost correct' trajectory of a chaotic map has a 'truly correct' trajectory nearby. This means that numerical errors in chaotic simulations are not bugs — they are SHADOWS of real trajectories. Conjecture: Every program that computes a chaotic map f: R^n -> R^n has the property that its floating-point output is shadowed by a true orbit of f. More precisely, for every epsilon > 0, there exists delta > 0 such that if x_0, x_1, ..., x_N is a delta-pseudo-orbit (|x_{n+1} - f(x_n)| < delta for all n), then there exists a true orbit y_0, y_1, ..., y_N with |x_n - y_n| < epsilon for all n. The shadowing time N(epsilon, delta) grows at most polynomially in 1/delta for hyperbolic maps. Test: implement the logistic map f(x) = 4x(1-x) in floating-point and compute 10^6 iterations. For each floating-point orbit, use binary search to find the shadowing true orbit. Verify that the shadowing distance is at most 10^{-10} for floating-point precision 10^{-16}. Impact: numerical chaos is not error — it is a computable shadow of mathematical truth. Your computer's rounding errors are tracing out REAL orbits of the chaotic system.
**Novelty estimate**: 0.83
**Breakthrough potential**: 0.83
Research domain: Geometry
Research mode: team


### Lean 4 Sketch
State the Anosov shadowing lemma: for a hyperbolic map f on a compact manifold, for every epsilon > 0 there exists delta > 0 such that every delta-pseudo-orbit is epsilon-shadowed by a true orbit. Prove the conjecture: every floating-point computation of f is a delta-pseudo-orbit with delta = machine epsilon. By shadowing, there exists a true orbit within epsilon. The shadowing distance epsilon is at most C * delta^(1/s) where s is the expansion rate and C depends on the map. For the logistic ma



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
