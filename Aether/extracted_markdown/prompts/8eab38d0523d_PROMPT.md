
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

**Title**: Stochastic Galois Theory: Random Permutations Have Generic Galois Groups
**Domain**: MachineLearning
**Mathematical framing**: The Galois group of a random polynomial over Q is S_n with probability 1. This is the Hilbert irreducibility theorem in probabilistic form. But what about random polynomials over finite fields? For f in F_p[x] of degree n chosen uniformly at random, the Galois group is S_n with probability approaching 1 as p grows. Conjecture: the probability that Gal(f) is NOT S_n is O(p^{-1/2}) for fixed n, and the exceptional cases concentrate at polynomials with discriminant zero or small Galois groups. More precisely, P(Gal(f) != S_n) = c_n / sqrt(p) + O(1/p) where c_n depends only on n. For n=2: P(Gal(f) != S_2) = P(discriminant = 0) = 1/p. For n=3: P(Gal(f) != S_3) = P(f has a rational root) = 3/p + O(1/p^2). Test: enumerate all monic polynomials of degree n over F_p for small p and n, compute Galois groups, verify P(Gal != S_n) ~ c_n / sqrt(p). Impact: random polynomials have maximal Galois groups — algebraic randomness is generic.
**Concept description**: The Galois group of a random polynomial over Q is S_n with probability 1. This is the Hilbert irreducibility theorem in probabilistic form. But what about random polynomials over finite fields? For f in F_p[x] of degree n chosen uniformly at random, the Galois group is S_n with probability approaching 1 as p grows. Conjecture: the probability that Gal(f) is NOT S_n is O(p^{-1/2}) for fixed n, and the exceptional cases concentrate at polynomials with discriminant zero or small Galois groups. More precisely, P(Gal(f) != S_n) = c_n / sqrt(p) + O(1/p) where c_n depends only on n. For n=2: P(Gal(f) != S_2) = P(discriminant = 0) = 1/p. For n=3: P(Gal(f) != S_3) = P(f has a rational root) = 3/p + O(1/p^2). Test: enumerate all monic polynomials of degree n over F_p for small p and n, compute Galois groups, verify P(Gal != S_n) ~ c_n / sqrt(p). Impact: random polynomials have maximal Galois groups — algebraic randomness is generic.
**Novelty estimate**: 0.82
**Breakthrough potential**: 0.82
Research domain: MachineLearning
Research mode: team


### Lean 4 Sketch
For a random monic polynomial f(x) = x^n + a_{n-1}x^{n-1} + ... + a_0 over F_p, the Galois group is a subgroup of S_n. Compute P(Gal(f) = S_n) by counting. For n=2: Gal(f) = S_2 unless discriminant = a_1^2 - 4*a_0 = 0, which happens for p choices of a_1 (each gives one a_0), so P = 1 - p/p^2 = 1 - 1/p. For n=3: Gal(f) != S_3 iff f has a rational root (3 choices of root, each determines f) or Gal = A_3 (discriminant is a square). Count both cases. For general n: use the fact that random permutati



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
