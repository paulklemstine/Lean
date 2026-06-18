
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

**Title**: Proof Complexity Collapse: P=NP via Proof Checking
**Domain**: Applications
**Mathematical framing**: The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.
**Concept description**: The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.
**Novelty estimate**: 0.97
**Breakthrough potential**: 0.97
Research domain: Applications
Research mode: team


### Lean 4 Sketch
Define EML-Frege proof system: axioms are EML identities, inference rules are substitution and modus ponens. Prove soundness (all provable formulas are true) and completeness (all true quantifier-free formulas have proofs). The key lemma: every boolean function on n variables has an EML representation of depth O(log n). This follows from EML universality. Prove that EML-Frege polynomially simulates Extended Frege by encoding each EF-rule as a constant-depth EML derivation.



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
