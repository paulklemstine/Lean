
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

**Title**: Impossible Geometries: Where Parallel Lines Converge AND Diverge
**Domain**: Computation
**Mathematical framing**: Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converge AND diverge? Define a Split Geometry on R^2 where the parallel postulate is direction-dependent: lines parallel to the x-axis diverge (hyperbolic behavior) while lines parallel to the y-axis converge (elliptic behavior). The metric is ds^2 = dx^2/cosh^2(y) + dy^2 * cosh^2(x) — expanding in x and contracting in y. Conjecture: Split Geometry is a consistent Riemannian geometry with curvature K(x,y) = -sech^2(y) + sech^2(x) that changes sign across the diagonals. The geometry has a 'phase boundary' along the lines y = x and y = -x where K = 0 (flat). In the region |x| > |y|, K > 0 (elliptic) and in the region |y| > |x|, K < 0 (hyperbolic). The geodesics in split geometry are piecewise combinations of exponential curves (in hyperbolic regions) and trigonometric curves (in elliptic regions). Test: compute the Christoffel symbols and curvature tensor for the split metric. Prove that geodesics cross the phase boundary at most twice. Compute the area of a split triangle with one vertex in each region. Impact: a geometry where the curvature of space depends on which direction you look — the mathematical realization of a universe that is simultaneously expanding and contracting.
**Concept description**: Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converge AND diverge? Define a Split Geometry on R^2 where the parallel postulate is direction-dependent: lines parallel to the x-axis diverge (hyperbolic behavior) while lines parallel to the y-axis converge (elliptic behavior). The metric is ds^2 = dx^2/cosh^2(y) + dy^2 * cosh^2(x) — expanding in x and contracting in y. Conjecture: Split Geometry is a consistent Riemannian geometry with curvature K(x,y) = -sech^2(y) + sech^2(x) that changes sign across the diagonals. The geometry has a 'phase boundary' along the lines y = x and y = -x where K = 0 (flat). In the region |x| > |y|, K > 0 (elliptic) and in the region |y| > |x|, K < 0 (hyperbolic). The geodesics in split geometry are piecewise combinations of exponential curves (in hyperbolic regions) and trigonometric curves (in elliptic regions). Test: compute the Christoffel symbols and curvature tensor for the split metric. Prove that geodesics cross the phase boundary at most twice. Compute the area of a split triangle with one vertex in each region. Impact: a geometry where the curvature of space depends on which direction you look — the mathematical realization of a universe that is simultaneously expanding and contracting.
**Novelty estimate**: 0.81
**Breakthrough potential**: 0.81
Research domain: Computation
Research mode: team


### Lean 4 Sketch
Define the split metric g = diag(1/cosh^2(y), cosh^2(x)) on R^2. Compute the Christoffel symbols: Gamma^1_{11} = tanh(y), Gamma^1_{12} = 0, Gamma^1_{22} = -sinh(x)cosh(x), Gamma^2_{11} = -tanh(y)*cosh^2(x)*cosh^2(y), Gamma^2_{12} = 0, Gamma^2_{22} = -sinh(x)cosh(x). Compute curvature: K = -sech^2(y) + sech^2(x). Verify: K = 0 on y = x and y = -x. K > 0 for |x| > |y| (elliptic). K < 0 for |y| > |x| (hyperbolic). Prove geodesic crossing: a geodesic that enters the elliptic region and then the hype



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
