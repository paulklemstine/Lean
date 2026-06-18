
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

**Title**: Tropical Lipschitz Bounds for Arithmetic Height via Valuation Depth
**Domain**: Bridges
**Mathematical framing**: Define an inductive syntax of rational expressions and two semantics: (1) evaluation into `ℚ` where defined, and (2) a tropical cost/height upper-bound semantics valued in `ℕ` or `ℤ≥0∞`. Prove by structural recursion that the arithmetic height of the evaluated expression is controlled by the tropical semantics. Base cases use positivity and normalization of `ratArithHeight`; additive steps use `vdepth_sum_le` as the computational analogue of height subadditivity; multiplicative and inversion steps require proving new lemmas showing arithmetic height behaves subadditively under multiplication and is invariant/symmetric under inversion on nonzero rationals. Then package the result as a bridge theorem: rational-expression evaluation is nonexpanding from the tropicalized valuation-depth metric to an arithmetic-height pseudometric, possibly via a `TropicalValuationObject`/`UltraNormObj` interface. Stronger corollaries should include explicit bounds for straight-line programs, compositionality under expression substitution, and a computable certificate that a bounded-depth arithmetic circuit has bounded output height. The statements are concrete and falsifiable: each inequality can fail if the proposed semantics is wrong, so the development must discover the correct normalization.
**Concept description**: The key insight is that the existing arithmetic-height object on rationals and the valuation-depth measure on computations appear to satisfy the same subadditive/max-plus control laws, so one can build a genuine bridge theorem: tropicalized arithmetic height is bounded by a valuation-depth functional and therefore induces explicit Lipschitz estimates in an ultrametric/tropical semantics. Why now: the catalog already contains the exact primitives needed on both sides — `Bridges/ArithmeticVCDimension.lean` provides `ArithHeightMeasure`, `ratArithHeight`, and positivity; `Computation/PadicValuationDepth.lean` provides `ValuationDepthMeasure`, `vdepth_const_eq_zero`, and `vdepth_sum_le`; and `Bridges/CategoricalTropicalUltrametric.lean` supplies the tropical/ultrametric categorical interface. This makes it tractable to prove a new family of bridge theorems rather than merely defining another analogous structure. Concretely, formalize a map from rational expressions built from constants, addition, multiplication, and inversion to a tropical cost semantics, then prove falsifiable inequalities of the form height-of-output <= tropical accumulation of local valuation depths, with sharper statements for sums and products. The target is an algorithmic pipeline: any rational computation gets an automatically extracted tropical upper bound on arithmetic height growth, yielding a bridge from arithmetic complexity to tropical metric control. This is distinct from the in-flight valuation-functor project because the focus is not on defining arithmetic height itself as an ultrametric valuation functor, but on proving quantitative comparison and Lipschitz/complexity inequalities between already-existing measures across domains.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.84
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create a new file in Bridges, likely `Bridges/TropicalArithmeticHeightBounds.lean`. Reuse `ratArithHeight` and `ValuationDepthMeasure`; define an expression type `RatExpr`; prove lemmas `height_const`, `height_add_le`, `height_mul_le`, `height_inv`; define tropical cost recursively; prove `ratArithHeight (eval e) ≤ cost e` under domain hypotheses; then add metric/Lipschitz corollaries through `CategoricalTropicalUltrametric`.



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
