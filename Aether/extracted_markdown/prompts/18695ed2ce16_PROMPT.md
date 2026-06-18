
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: The current framework establishes qualitative novelty certification (ε-separatio
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Quantitative Packing Bounds with Covering Numbers

The current framework establishes qualitative novelty certification (ε-separation, diameter bounds). A natural next step is to formalize *covering numbers* N(S, ε) and *packing numbers* M(S, ε) for subsets of metric spaces, and prove the classical sandwich inequality M(S, 2ε) ≤ N(S, ε) ≤ M(S, ε). This would yield explicit cardinality bounds: any mutually ε-separated subset of a ball of radius R in ℝ^d has at most (2R/ε + 1)^d elements.

**The key insight is** that the packing-covering duality transforms our qualitative mutual-separation predicate into a quantitative capacity bound, giving a formal upper limit on how many "genuinely novel" outputs can exist in a bounded region.

**Why now?** Mathlib already has `Metric.ball`, `Bornology.IsBounded`, and basic `Finset` cardinality infrastructure. The ε-net theory in finite-dimensional spaces is well-understood and the combinatorial core (pigeonhole on a grid covering) is within reach of current automation.

## 2. Novelty Persistence Under Lipschitz Maps

If f : α → β is L-Lipschitz and x is ε-novel w.r.t. S in α, then f(x) is (ε/L)-novel w.r.t. f(S) in β. This "novelty transport" theorem would formalize how novelty certificates survive transformations — crucial for applications where theorems are compared via embeddings into a common feature space. The converse direction (lower-Lipschitz / bi-Lipschitz maps preserving novelty) would establish that embeddings don't create spurious novelty.

**The key insight is** that Lipschitz maps contract distances by at most factor L, so novelty thresholds scale predictably — and bi-Lipschitz maps give both upper and lower transport, making the embedding faithful.

**Why now?** Mathlib's `LipschitzWith` and `AntilipschitzWith` API is mature and well-connected to the metric space infrastructure we already use. The proofs should compose cleanly with `novel_triangle_transfer`.

## 3. Adaptive Threshold Selection via Minimum Distance

Define the *novelty score* of x w.r.t. S as inf_{s ∈ S} dist(x, s) (or min for finite S). Formalize this as a function and prove: (a) x is ε-novel iff novelty_score(x, S) ≥ ε, (b) the novelty score is 1-Lipschitz in x, (c) the novelty score is anti-monotone in S. This connects our predicate-based framework to a continuous scoring function suitable for optimization.

**The key insight is** that the novelty score is the distance-to-set function restricted to finite sets, inheriting all its regularity properties (1-Lipschitz, lower semicontinuity) while being computable.

**Why now?** Mathlib has `Metric.infDist` and its Lipschitz properties (`lipschitz_infDist`). Specializing to finite sets and connecting to our `IsNovel` predicate is a clean formalization target.

## 4. Hierarchical Novelty via Ultrametric Trees

For structured theorem spaces where similarity is hierarchical (e.g., theorems about groups are more similar to each other than to theorems about topology), the natural metric is an ultrametric: d(x,z) ≤ max(d(x,y), d(y,z)). In ultrametric spaces, our novelty framework simplifies dramatically: every ball is both open and closed, and the packing bound becomes exact rather than approximate. Formalize ultrametric novelty and prove that the mutual-separation predicate decomposes into independent subtree problems.

**The key insight is** that ultrametric spaces have a canonical tree structure where ε-balls are exactly the nodes at height ε, turning the novelty certification problem into a tree search that avoids the curse of dimensionality.

**Why now?** Mathlib has `Metric.IsUltrametricDist` and basic ultrametric lemmas. The tree decomposition of ultrametric balls is folklore but not yet formalized, making it a genuine contribution.

## 5. Compositional Novelty for Structured Proofs

Theorems are not atomic objects — they have structure (hypotheses, conclusions, proof steps). Define a *compositional novelty score* that decomposes a structured object into components and aggregates component-level novelty. Formalize this for product metric spaces: if (x₁, x₂) is the decomposition and S = S₁ × S₂, prove that novelty in the product relates to component novelties via ε² ≤ ε₁² + ε₂² (for the L² product metric). This would enable modular novelty certification where each component is certified independently.

**The key insight is** that product metric spaces let us decompose novelty certification into independent sub-problems, and the Pythagorean relationship between component and total novelty gives tight, composable bounds.

**Why now?** Mathlib's `PseudoMetricSpace` instances for `Prod` and the `Pi` type are well-developed. The componentwise novelty bounds follow from standard metric inequalities that are already available.

**Concept description**: # Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Quantitative Packing Bounds with Covering Numbers

The current framework establishes qualitative novelty certification (ε-separation, diameter bounds). A natural next step is to formalize *covering numbers* N(S, ε) and *packing numbers* M(S, ε) for subsets of metric spaces, and prove the classical sandwich inequality M(S, 2ε) ≤ N(S, ε) ≤ M(S, ε). This would yield explicit cardinality bounds: any mutually ε-separated subset of a ball of radius R in ℝ^d has at most (2R/ε + 1)^d elements.

**The key insight is** that the packing-covering duality transforms our qualitative mutual-separation predicate into a quantitative capacity bound, giving a formal upper limit on how many "genuinely novel" outputs can exist in a bounded region.

**Why now?** Mathlib already has `Metric.ball`, `Bornology.IsBounded`, and basic `Finset` cardinality infrastructure. The ε-net theory in finite-dimensional spaces is well-understood and the combinatorial core (pigeonhole on a grid covering) is within reach of current automation.

## 2. Novelty Persistence Under Lipschitz Maps

If f : α → β is L-Lipschitz and x is ε-novel w.r.t. S in α, then f(x) is (ε/L)-novel w.r.t. f(S) in β. This "novelty transport" theorem would formalize how novelty certificates survive transformations — crucial for applications where theorems are compared via embeddings into a common feature space. The converse direction (lower-Lipschitz / bi-Lipschitz maps preserving novelty) would establish that embeddings don't create spurious novelty.

**The key insight is** that Lipschitz maps contract distances by at most factor L, so novelty thresholds scale predictably — and bi-Lipschitz maps give both upper and lower transport, making the embedding faithful.

**Why now?** Mathlib's `LipschitzWith` and `AntilipschitzWith` API is mature and well-connected to the metric space infrastructure we already use. The proofs should compose cleanly with `novel_triangle_transfer`.

## 3. Adaptive Threshold Selection via Minimum Distance

Define the *novelty score* of x w.r.t. S as inf_{s ∈ S} dist(x, s) (or min for finite S). Formalize this as a function and prove: (a) x is ε-novel iff novelty_score(x, S) ≥ ε, (b) the novelty score is 1-Lipschitz in x, (c) the novelty score is anti-monotone in S. This connects our predicate-based framework to a continuous scoring function suitable for optimization.

**The key insight is** that the novelty score is the distance-to-set function restricted to finite sets, inheriting all its regularity properties (1-Lipschitz, lower semicontinuity) while being computable.

**Why now?** Mathlib has `Metric.infDist` and its Lipschitz properties (`lipschitz_infDist`). Specializing to finite sets and connecting to our `IsNovel` predicate is a clean formalization target.

## 4. Hierarchical Novelty via Ultrametric Trees

For structured theorem spaces where similarity is hierarchical (e.g., theorems about groups are more similar to each other than to theorems about topology), the natural metric is an ultrametric: d(x,z) ≤ max(d(x,y), d(y,z)). In ultrametric spaces, our novelty framework simplifies dramatically: every ball is both open and closed, and the packing bound becomes exact rather than approximate. Formalize ultrametric novelty and prove that the mutual-separation predicate decomposes into independent subtree problems.

**The key insight is** that ultrametric spaces have a canonical tree structure where ε-balls are exactly the nodes at height ε, turning the novelty certification problem into a tree search that avoids the curse of dimensionality.

**Why now?** Mathlib has `Metric.IsUltrametricDist` and basic ultrametric lemmas. The tree decomposition of ultrametric balls is folklore but not yet formalized, making it a genuine contribution.

## 5. Compositional Novelty for Structured Proofs

Theorems are not atomic objects — they have structure (hypotheses, conclusions, proof steps). Define a *compositional novelty score* that decomposes a structured object into components and aggregates component-level novelty. Formalize this for product metric spaces: if (x₁, x₂) is the decomposition and S = S₁ × S₂, prove that novelty in the product relates to component novelties via ε² ≤ ε₁² + ε₂² (for the L² product metric). This would enable modular novelty certification where each component is certified independently.

**The key insight is** that product metric spaces let us decompose novelty certification into independent sub-problems, and the Pythagorean relationship between component and total novelty gives tight, composable bounds.

**Why now?** Mathlib's `PseudoMetricSpace` instances for `Prod` and the `Pi` type are well-developed. The componentwise novelty bounds follow from standard metric inequalities that are already available.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
