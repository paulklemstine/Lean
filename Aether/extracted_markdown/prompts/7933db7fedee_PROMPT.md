
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

**Title**: Sheaf Cohomology of Data: The Topology of Missing Information
**Domain**: Novelty
**Mathematical framing**: A dataset with missing values is a sheaf on a poset: the poset is the set of feature subsets (ordered by inclusion), and the sheaf assigns to each feature subset the set of complete observations on those features. The missing data creates 'holes' in the sheaf: H^0 measures the global sections (complete observations) and H^1 measures the obstructions to patching local observations into global ones. Conjecture: For a dataset with missing rate r, the dimension of H^1 is approximately r * n * (r * log(1/r)), where n is the number of features. This means: the 'amount of missing information' grows super-linearly with the missing rate, and imputation is fundamentally harder than interpolation because H^1 > 0 means there is no consistent way to fill in the missing data. The sheaf-theoretic imputation: fill in missing values by finding the section s in H^0 that minimizes the coboundary delta(s) in H^1. This is the maximum likelihood imputation under the assumption that the data is locally consistent. Test: generate synthetic datasets with known ground truth, introduce missing values at rate r, compute H^0 and H^1 of the data sheaf, and verify dim(H^1) ~ r*n*r*log(1/r). Compare sheaf-theoretic imputation with standard methods (mean, KNN, MICE). Impact: missing data is a topological problem, and the sheaf cohomology tells you exactly how much information is lost and whether it can be recovered.
**Concept description**: A dataset with missing values is a sheaf on a poset: the poset is the set of feature subsets (ordered by inclusion), and the sheaf assigns to each feature subset the set of complete observations on those features. The missing data creates 'holes' in the sheaf: H^0 measures the global sections (complete observations) and H^1 measures the obstructions to patching local observations into global ones. Conjecture: For a dataset with missing rate r, the dimension of H^1 is approximately r * n * (r * log(1/r)), where n is the number of features. This means: the 'amount of missing information' grows super-linearly with the missing rate, and imputation is fundamentally harder than interpolation because H^1 > 0 means there is no consistent way to fill in the missing data. The sheaf-theoretic imputation: fill in missing values by finding the section s in H^0 that minimizes the coboundary delta(s) in H^1. This is the maximum likelihood imputation under the assumption that the data is locally consistent. Test: generate synthetic datasets with known ground truth, introduce missing values at rate r, compute H^0 and H^1 of the data sheaf, and verify dim(H^1) ~ r*n*r*log(1/r). Compare sheaf-theoretic imputation with standard methods (mean, KNN, MICE). Impact: missing data is a topological problem, and the sheaf cohomology tells you exactly how much information is lost and whether it can be recovered.
**Novelty estimate**: 0.7903999999999999
**Breakthrough potential**: 0.78
Research domain: Novelty
Research mode: team


### Lean 4 Sketch
Define the data sheaf: for a dataset with n features and m observations, the poset P is the set of feature subsets S subset {1,...,n} ordered by inclusion. The sheaf F assigns to each S the set of observations that have all features in S present (complete rows restricted to columns in S). The restriction maps F(S) -> F(T) for T subset S are projections that drop columns in S\T. Define H^0(F) = ker(delta_0) = global sections (observations complete on ALL features). Define H^1(F) = ker(delta_1)/im



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
