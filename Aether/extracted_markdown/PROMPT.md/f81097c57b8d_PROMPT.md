
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

**Title**: Arithmetic Concentration of Nodal Counts in Random Hecke Eigenfunctions on Large
**Domain**: Applications
**Mathematical framing**: Conjecture: Let {G_n} be a sequence of connected (q+1)-regular arithmetic Ramanujan graphs with |V(G_n)| -> infinity, and let f_n be an L^2-normalized Hecke eigenfunction of the graph adjacency operator with eigenvalue in a fixed compact subinterval of (-2sqrt(q), 2sqrt(q)). Define N_n as the number of edges {u,v} such that f_n(u)f_n(v) < 0 (the discrete nodal edge count). Then, after centering by its random-wave prediction and scaling by |V(G_n)|^(1/2), the distribution of N_n over Hecke eigenfunctions on G_n converges to a strictly smaller variance law than for non-arithmetic random regular graphs of the same degree; equivalently, arithmetic Hecke symmetry enforces a detectable variance deficit in nodal counts. Test: Compute full Hecke eigenbases for growing families of arithmetic Ramanujan graphs and compare the empirical mean/variance of normalized nodal edge counts against matched ensembles of non-arithmetic random regular graphs and Gaussian wave surrogates. The conjecture is supported if a stable, statistically significant variance deficit persists across graph families and spectral windows; it is refuted if the limiting variance matches the non-arithmetic random-wave benchmark. Impact: This would identify a new arithmetic fingerprint in quantum-chaotic graph observables, linking automorphic symmetry, discrete quantum ergodicity, and nodal geometry, and could yield new diagnostics for hidden arithmetic structure in networks and quantum simulators.
**Concept description**: Conjecture: Let {G_n} be a sequence of connected (q+1)-regular arithmetic Ramanujan graphs with |V(G_n)| -> infinity, and let f_n be an L^2-normalized Hecke eigenfunction of the graph adjacency operator with eigenvalue in a fixed compact subinterval of (-2sqrt(q), 2sqrt(q)). Define N_n as the number of edges {u,v} such that f_n(u)f_n(v) < 0 (the discrete nodal edge count). Then, after centering by its random-wave prediction and scaling by |V(G_n)|^(1/2), the distribution of N_n over Hecke eigenfunctions on G_n converges to a strictly smaller variance law than for non-arithmetic random regular graphs of the same degree; equivalently, arithmetic Hecke symmetry enforces a detectable variance deficit in nodal counts. Test: Compute full Hecke eigenbases for growing families of arithmetic Ramanujan graphs and compare the empirical mean/variance of normalized nodal edge counts against matched ensembles of non-arithmetic random regular graphs and Gaussian wave surrogates. The conjecture is supported if a stable, statistically significant variance deficit persists across graph families and spectral windows; it is refuted if the limiting variance matches the non-arithmetic random-wave benchmark. Impact: This would identify a new arithmetic fingerprint in quantum-chaotic graph observables, linking automorphic symmetry, discrete quantum ergodicity, and nodal geometry, and could yield new diagnostics for hidden arithmetic structure in networks and quantum simulators.
**Novelty estimate**: 0.7
**Breakthrough potential**: 0.7
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
