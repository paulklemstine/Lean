
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

**Title**: The L-Function Oracle: What If We Could Compute L-Functions Instantly?
**Domain**: Shared
**Mathematical framing**: Suppose we had an oracle that computes L(s, chi) for any L-function and any complex s in O(1) time. What theorems would follow? Conjecture: The L-function oracle implies (1) The Riemann Hypothesis (compute zeros directly), (2) The BSD conjecture (compute the order of vanishing at s=1), (3) The Sato-Tate conjecture (compute the distribution of a_p), (4) Langlands functoriality (compare L-functions on both sides of the functoriality lift), and (5) A polynomial-time algorithm for factoring (the L-function of an elliptic curve E over Z/nZ detects factors of n). But the oracle also implies IMPOSSIBILITY results: (6) P != NP (because NP-complete problems would reduce to L-function computations that the oracle solves in O(1), contradicting the time hierarchy theorem if P = NP). Wait — the oracle solves L-function computations in O(1), so if P = NP, then NP problems can be encoded as L-function computations and solved instantly, but the oracle's existence is an axiom, not a theorem. The correct statement: the L-function oracle collapses the polynomial hierarchy to L-function computations. Test: prove that the Riemann Hypothesis follows from the oracle. Prove that BSD follows. Prove that factoring is in P given the oracle. Impact: understanding what an L-function oracle implies tells us exactly how powerful L-functions are — and how far we are from proving things about them.
**Concept description**: Suppose we had an oracle that computes L(s, chi) for any L-function and any complex s in O(1) time. What theorems would follow? Conjecture: The L-function oracle implies (1) The Riemann Hypothesis (compute zeros directly), (2) The BSD conjecture (compute the order of vanishing at s=1), (3) The Sato-Tate conjecture (compute the distribution of a_p), (4) Langlands functoriality (compare L-functions on both sides of the functoriality lift), and (5) A polynomial-time algorithm for factoring (the L-function of an elliptic curve E over Z/nZ detects factors of n). But the oracle also implies IMPOSSIBILITY results: (6) P != NP (because NP-complete problems would reduce to L-function computations that the oracle solves in O(1), contradicting the time hierarchy theorem if P = NP). Wait — the oracle solves L-function computations in O(1), so if P = NP, then NP problems can be encoded as L-function computations and solved instantly, but the oracle's existence is an axiom, not a theorem. The correct statement: the L-function oracle collapses the polynomial hierarchy to L-function computations. Test: prove that the Riemann Hypothesis follows from the oracle. Prove that BSD follows. Prove that factoring is in P given the oracle. Impact: understanding what an L-function oracle implies tells us exactly how powerful L-functions are — and how far we are from proving things about them.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.88
Research domain: Shared
Research mode: team


### Lean 4 Sketch
Define the L-oracle O(s, chi) = L(s, chi) for any L-function chi and complex s. RH: compute all zeros of zeta(s) by evaluating zeta(s) on a fine grid and checking sign changes — O(R^2) oracle calls for zeros up to height R. BSD: compute L(E, 1) and check if it's zero (rank >= 1) or compute the Taylor expansion around s=1 to get the order of vanishing. Sato-Tate: compute a_p(E) for all p up to N by evaluating L(s, E) at s = it for varying t, and extract a_p from the Euler product. Factoring: give



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
