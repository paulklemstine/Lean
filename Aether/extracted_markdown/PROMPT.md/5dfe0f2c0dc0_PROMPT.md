
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

**Title**: The current formalization uses an abstract `DSepOracle` satisfying graphoid axio
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Do-Calculus Formalization

## 1. Concrete d-Separation via Path Blocking

The current formalization uses an abstract `DSepOracle` satisfying graphoid axioms. The natural next step is to define d-separation concretely via path blocking (chains, forks, and colliders) and prove it satisfies all graphoid axioms. The key insight is that d-separation can be characterized as a reachability problem in a "moralized ancestral graph," which reduces the problem to ordinary graph connectivity. Why now? The `CausalDAG` infrastructure (topological ordering, reachability, mutilation) is fully in place, and the `DPath` structure already exists — we just need the blocking predicate and the moralization construction.

## 2. Completeness of Do-Calculus for Identifiability

Shpitser and Pearl (2006) proved that do-calculus is complete for identifying causal effects in semi-Markovian models. Formalizing this would require: (a) defining the "hedge" criterion, (b) showing that non-identifiability implies existence of two models agreeing on observational but not interventional distributions, and (c) showing every identifiable effect has a do-calculus derivation. The key insight is that the hedge structure provides a finite witness for non-identifiability, making the completeness proof constructive. Why now? The `DoDerivation` inductive type and `DoCalculusRule.graphCondition` already encode the derivation system — what's missing is the connection to actual probability distributions.

## 3. Algorithmic Identifiability via ID Algorithm

The ID algorithm (Tian and Pearl, 2002) provides a recursive decision procedure for causal effect identifiability. Formalizing this as a verified algorithm in Lean 4 would give us a certified decision procedure with extraction to executable code. The key insight is that the ID algorithm's recursion follows the c-component (confounding component) decomposition of the DAG, which can be defined using the `descendantsSet` and `ancestorsSet` operations already formalized. Why now? The mutilation algebra (composition, commutativity, idempotence) provides the foundation for reasoning about the graph transformations the algorithm performs.

## 4. Structural Causal Models with Measure-Theoretic Semantics

The current formalization captures the syntactic/graph-theoretic side of do-calculus. A deeper formalization would attach measure-theoretic semantics: each vertex carries a measurable space, each structural equation is a measurable function, and the do-operator corresponds to replacing a structural equation with a constant. The key insight is that the `intervention_disconnects` theorem (ancestors become empty after mutilation) is the graph-theoretic shadow of the measure-theoretic fact that intervened variables become independent of their former causes. Why now? Mathlib's measure theory library is mature enough to support this, and the graph-theoretic foundation proven here ensures the combinatorial side is solid.

## 5. Causal Discovery: Faithfulness and the PC Algorithm

Moving from causal inference (given a known DAG) to causal discovery (learning the DAG from data) requires the faithfulness assumption: that d-separation exactly characterizes conditional independence. Formalizing the PC algorithm's correctness under faithfulness would connect the d-separation oracle to statistical testing. The key insight is that under faithfulness, the `DSepOracle.symmetry`, `decomposition`, and `weak_union` axioms are not just sufficient but necessary — they characterize exactly the conditional independence relations that can arise from a DAG. Why now? The abstract `DSepOracle` structure is designed to be instantiated with concrete independence relations, making it the natural bridge between the graph-theoretic and statistical worlds.

**Concept description**: # Future Directions: Do-Calculus Formalization

## 1. Concrete d-Separation via Path Blocking

The current formalization uses an abstract `DSepOracle` satisfying graphoid axioms. The natural next step is to define d-separation concretely via path blocking (chains, forks, and colliders) and prove it satisfies all graphoid axioms. The key insight is that d-separation can be characterized as a reachability problem in a "moralized ancestral graph," which reduces the problem to ordinary graph connectivity. Why now? The `CausalDAG` infrastructure (topological ordering, reachability, mutilation) is fully in place, and the `DPath` structure already exists — we just need the blocking predicate and the moralization construction.

## 2. Completeness of Do-Calculus for Identifiability

Shpitser and Pearl (2006) proved that do-calculus is complete for identifying causal effects in semi-Markovian models. Formalizing this would require: (a) defining the "hedge" criterion, (b) showing that non-identifiability implies existence of two models agreeing on observational but not interventional distributions, and (c) showing every identifiable effect has a do-calculus derivation. The key insight is that the hedge structure provides a finite witness for non-identifiability, making the completeness proof constructive. Why now? The `DoDerivation` inductive type and `DoCalculusRule.graphCondition` already encode the derivation system — what's missing is the connection to actual probability distributions.

## 3. Algorithmic Identifiability via ID Algorithm

The ID algorithm (Tian and Pearl, 2002) provides a recursive decision procedure for causal effect identifiability. Formalizing this as a verified algorithm in Lean 4 would give us a certified decision procedure with extraction to executable code. The key insight is that the ID algorithm's recursion follows the c-component (confounding component) decomposition of the DAG, which can be defined using the `descendantsSet` and `ancestorsSet` operations already formalized. Why now? The mutilation algebra (composition, commutativity, idempotence) provides the foundation for reasoning about the graph transformations the algorithm performs.

## 4. Structural Causal Models with Measure-Theoretic Semantics

The current formalization captures the syntactic/graph-theoretic side of do-calculus. A deeper formalization would attach measure-theoretic semantics: each vertex carries a measurable space, each structural equation is a measurable function, and the do-operator corresponds to replacing a structural equation with a constant. The key insight is that the `intervention_disconnects` theorem (ancestors become empty after mutilation) is the graph-theoretic shadow of the measure-theoretic fact that intervened variables become independent of their former causes. Why now? Mathlib's measure theory library is mature enough to support this, and the graph-theoretic foundation proven here ensures the combinatorial side is solid.

## 5. Causal Discovery: Faithfulness and the PC Algorithm

Moving from causal inference (given a known DAG) to causal discovery (learning the DAG from data) requires the faithfulness assumption: that d-separation exactly characterizes conditional independence. Formalizing the PC algorithm's correctness under faithfulness would connect the d-separation oracle to statistical testing. The key insight is that under faithfulness, the `DSepOracle.symmetry`, `decomposition`, and `weak_union` axioms are not just sufficient but necessary — they characterize exactly the conditional independence relations that can arise from a DAG. Why now? The abstract `DSepOracle` structure is designed to be instantiated with concrete independence relations, making it the natural bridge between the graph-theoretic and statistical worlds.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Algebra
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
