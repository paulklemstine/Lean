
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

**Title**: Thermodynamic Proof Erasure: Landauer's Principle for Mathematics
**Domain**: Applications
**Mathematical framing**: Landauer's principle states that erasing one bit of information dissipates at least kT*ln(2) of heat. Apply this to proof theory: erasing a proof of theorem T to recover a shorter proof is an information-theoretic process with a thermodynamic cost. Conjecture: The minimum energy required to compress a proof of n steps into a proof of m steps (m < n) is at least kT*(n-m)*ln(2), and this bound is tight for proofs in propositional logic. A proof of length n contains n bits of information (each step is a binary choice in the search tree). Compressing it to m steps requires erasing n-m bits, each costing kT*ln(2) by Landauer. This gives a physical lower bound on proof compression that is independent of the proof system. Test: formalize proof compression as an irreversible computation and derive the Landauer bound. Compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of algebra into a 100-step proof. Impact: connects information thermodynamics to proof complexity, providing a physical lower bound on proof compression.
**Concept description**: Landauer's principle states that erasing one bit of information dissipates at least kT*ln(2) of heat. Apply this to proof theory: erasing a proof of theorem T to recover a shorter proof is an information-theoretic process with a thermodynamic cost. Conjecture: The minimum energy required to compress a proof of n steps into a proof of m steps (m < n) is at least kT*(n-m)*ln(2), and this bound is tight for proofs in propositional logic. A proof of length n contains n bits of information (each step is a binary choice in the search tree). Compressing it to m steps requires erasing n-m bits, each costing kT*ln(2) by Landauer. This gives a physical lower bound on proof compression that is independent of the proof system. Test: formalize proof compression as an irreversible computation and derive the Landauer bound. Compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of algebra into a 100-step proof. Impact: connects information thermodynamics to proof complexity, providing a physical lower bound on proof compression.
**Novelty estimate**: 0.24999999999999992
**Breakthrough potential**: 0.24999999999999992
Research domain: Applications
Research mode: team


### Lean 4 Sketch
Formalize proof erasure as a thermodynamic process: deleting a proof of length n requires at least kT*n*ln(2) of heat dissipation (Landauer's principle applied to each proof step). Prove that proof compression by a factor of c requires at least kT*n*(1-1/c)*ln(2) of erasure energy. Derive the bound by modeling each proof step as a binary decision in a search tree, so erasing n-m steps loses n-m bits. Test: compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of a



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
