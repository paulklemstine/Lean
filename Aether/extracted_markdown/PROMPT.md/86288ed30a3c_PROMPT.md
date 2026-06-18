
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

**Title**: The Arithmetic of Games: Surreal Numbers as Number Fields
**Domain**: Pythagorean
**Mathematical framing**: Conway's surreal numbers No form a proper class containing all real numbers, all ordinal numbers, and all infinitesimals. Every real number r has a surreal representation r = {r - 1 | r + 1}. Every ordinal alpha has a surreal representation alpha = {alpha |}. Every infinitesimal epsilon = {0 | 1, 1/2, 1/4, ...}. The surreal numbers form a field (in fact, a real-closed field). Conjecture: the subfield of surreals born by day omega (the set of surreals with finite birthdays) is isomorphic to the field of real algebraic numbers extended with all dyadic rationals. More precisely: No_{omega} = Q[2^{-n} : n in N] (the rationals extended with all dyadic rationals). The subfield born by day omega^2 contains all real numbers that are algebraic over the dyadic rationals, plus all infinitesimals that are algebraic over the reals. Conjecture: No_{omega^2} = R(x) where x is the smallest positive infinitesimal. Test: compute the field structure of surreals born by day omega and verify the isomorphism with the dyadic rationals. Impact: the surreal number hierarchy encodes the constructive hierarchy of real number fields — each birthday level adds exactly the algebraic closures needed.
**Concept description**: Conway's surreal numbers No form a proper class containing all real numbers, all ordinal numbers, and all infinitesimals. Every real number r has a surreal representation r = {r - 1 | r + 1}. Every ordinal alpha has a surreal representation alpha = {alpha |}. Every infinitesimal epsilon = {0 | 1, 1/2, 1/4, ...}. The surreal numbers form a field (in fact, a real-closed field). Conjecture: the subfield of surreals born by day omega (the set of surreals with finite birthdays) is isomorphic to the field of real algebraic numbers extended with all dyadic rationals. More precisely: No_{omega} = Q[2^{-n} : n in N] (the rationals extended with all dyadic rationals). The subfield born by day omega^2 contains all real numbers that are algebraic over the dyadic rationals, plus all infinitesimals that are algebraic over the reals. Conjecture: No_{omega^2} = R(x) where x is the smallest positive infinitesimal. Test: compute the field structure of surreals born by day omega and verify the isomorphism with the dyadic rationals. Impact: the surreal number hierarchy encodes the constructive hierarchy of real number fields — each birthday level adds exactly the algebraic closures needed.
**Novelty estimate**: 0.8
**Breakthrough potential**: 0.8
Research domain: Pythagorean
Research mode: team


### Lean 4 Sketch
Define No_alpha = {surreals with birthday < alpha}. No_0 = empty. No_1 = {0} = {{|}}. No_2 = {-1, 0, 1} (three surreals). No_3 = {-2, -1/2, -1, -1/4, 0, 1/4, 1/2, 1, 2} (but actually No_3 has 7 surreals). By day omega: No_omega = all dyadic rationals m/2^n for m in Z, n in N. This is a field: the dyadic rationals are closed under +, -, *, / (for nonzero). Proof: m/2^n + k/2^l = (m*2^l + k*2^n)/2^{n+l} which is dyadic. Product: (m/2^n)(k/2^l) = mk/2^{n+l}. Reciprocal: 1/(m/2^n) = 2^n/m which is r



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
