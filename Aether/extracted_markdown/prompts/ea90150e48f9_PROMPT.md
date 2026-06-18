
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

**Title**: Sheaf-Theoretic Data Integration: When Databases Form a Sheaf
**Domain**: MachineLearning
**Mathematical framing**: A database with missing entries is a partial section of a sheaf. The sheaf condition (gluing) says that if two partial sections agree on their overlap, they can be glued into a global section. Conjecture: the probability that a random database with missing rate r satisfies the sheaf condition (i.e., can be consistently filled in) is P(sheaf) = (1-r)^{C(n,k)} where n is the number of columns, k is the number of rows, and C(n,k) is the number of overlapping constraints. This means: for a database with n columns and k rows, the probability of consistent imputation drops exponentially with the number of overlapping constraints. The sheaf imputation method: fill in missing values by finding the closest global section of the data sheaf. This is equivalent to solving a constrained optimization problem where the constraints are the sheaf condition on every overlapping pair of feature subsets. Conjecture: sheaf imputation outperforms mean imputation and KNN imputation when the missing rate r < 0.5 and the number of features n > 10, because the sheaf condition provides exponentially many consistency constraints that other methods ignore. Test: generate synthetic databases with known ground truth, introduce missing values at rate r, compare sheaf imputation with mean, KNN, and MICE. Impact: data imputation is a sheaf cohomology problem. The sheaf condition is the natural consistency constraint for databases.
**Concept description**: A database with missing entries is a partial section of a sheaf. The sheaf condition (gluing) says that if two partial sections agree on their overlap, they can be glued into a global section. Conjecture: the probability that a random database with missing rate r satisfies the sheaf condition (i.e., can be consistently filled in) is P(sheaf) = (1-r)^{C(n,k)} where n is the number of columns, k is the number of rows, and C(n,k) is the number of overlapping constraints. This means: for a database with n columns and k rows, the probability of consistent imputation drops exponentially with the number of overlapping constraints. The sheaf imputation method: fill in missing values by finding the closest global section of the data sheaf. This is equivalent to solving a constrained optimization problem where the constraints are the sheaf condition on every overlapping pair of feature subsets. Conjecture: sheaf imputation outperforms mean imputation and KNN imputation when the missing rate r < 0.5 and the number of features n > 10, because the sheaf condition provides exponentially many consistency constraints that other methods ignore. Test: generate synthetic databases with known ground truth, introduce missing values at rate r, compare sheaf imputation with mean, KNN, and MICE. Impact: data imputation is a sheaf cohomology problem. The sheaf condition is the natural consistency constraint for databases.
**Novelty estimate**: 0.7813999999999999
**Breakthrough potential**: 0.73
Research domain: MachineLearning
Research mode: team


### Lean 4 Sketch
Define the data sheaf: for a database with n features and m observations, the base space is the poset P of feature subsets (ordered by inclusion). The sheaf F assigns to each feature subset S the set of complete observations on features S. The restriction maps F(S) -> F(T) for T subset S project out the features in S\T. The sheaf condition: for any cover {S_i} of S, the following is an equalizer: F(S) -> prod_i F(S_i) ==> prod_{i,j} F(S_i cap S_j). This means: a global section exists iff local s



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
