
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


## Concept

**Title**: Fractal Topology: Hausdorff Dimension as a Topological Invariant
**Domain**: Novelty
**Mathematical framing**: The Hausdorff dimension is normally a metric property, not a topological one. Investigate whether it can be made topological through the lens of fractal topology. Define the fractal topological dimension d_f(X) of a metric space X as the infimum of d such that X embeds in R^d with Hausdorff dimension preserved. Conjecture: For compact metric spaces, the Hausdorff dimension is a topological invariant modulo homeomorphisms that are bi-Lipschitz on a dense open set. More precisely, if X and Y are homeomorphic compact subsets of R^n, and the homeomorphism is bi-Lipschitz on a set of full Hausdorff dimension in X, then dim_H(X) = dim_H(Y). This would mean that fractal dimension is not just a metric accident but a topological invariant up to rough isometries. Test: compute d_f for the Sierpinski gasket (expected: 1 since connected, Hausdorff dimension log3/log2) and the Cantor set (expected: 0 since totally disconnected). Prove that the Koch curve and any bi-Lipschitz-equivalent curve have equal Hausdorff dimensions. Impact: elevates fractal dimension from a metric curiosity to a topological invariant, with applications to shape classification and topological data analysis.
**Concept description**: The Hausdorff dimension is normally a metric property, not a topological one. Investigate whether it can be made topological through the lens of fractal topology. Define the fractal topological dimension d_f(X) of a metric space X as the infimum of d such that X embeds in R^d with Hausdorff dimension preserved. Conjecture: For compact metric spaces, the Hausdorff dimension is a topological invariant modulo homeomorphisms that are bi-Lipschitz on a dense open set. More precisely, if X and Y are homeomorphic compact subsets of R^n, and the homeomorphism is bi-Lipschitz on a set of full Hausdorff dimension in X, then dim_H(X) = dim_H(Y). This would mean that fractal dimension is not just a metric accident but a topological invariant up to rough isometries. Test: compute d_f for the Sierpinski gasket (expected: 1 since connected, Hausdorff dimension log3/log2) and the Cantor set (expected: 0 since totally disconnected). Prove that the Koch curve and any bi-Lipschitz-equivalent curve have equal Hausdorff dimensions. Impact: elevates fractal dimension from a metric curiosity to a topological invariant, with applications to shape classification and topological data analysis.
**Novelty estimate**: 0.86
**Breakthrough potential**: 0.86
Research domain: Novelty
Research mode: team


### Lean 4 Sketch
Define d_f(X) = inf{d : X embeds in R^d preserving Hausdorff dimension}. Prove d_f is a topological invariant for compact metric spaces by showing it is preserved under bi-Lipschitz homeomorphisms on dense open sets. The key lemma: if h is bi-Lipschitz on a set S of full Hausdorff dimension in X, then dim_H(X) = dim_H(h(X)). Test: compute d_f(Sierpinski gasket) = 1 (connected) and d_f(Cantor set) = 0 (totally disconnected). Prove that dim_H is invariant under orientation-preserving bi-Lipschitz 



### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
