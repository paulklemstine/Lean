
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

**Title**: Neural Network Training as Renormalization Group Flow
**Domain**: MachineLearning
**Mathematical framing**: The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying parameters), just as each RG step integrates out short-distance modes. Conjecture: The fixed points of SGD on neural networks are precisely the critical points of a renormalization group flow defined by the coarse-graining operator that averages over parameter subsets. Why now: recent work on neural network Gaussian processes shows that infinite-width networks have exact RG fixed points, and the beta function of SGD training has been computed for linear networks. Test: prove that for a 2-layer ReLU network trained on isotropic data, the SGD fixed point corresponds to the Wilson-Fisher fixed point in d=2 dimensions, and compute the critical exponents. Impact: neural network training would be governed by universality classes, meaning the same network trained on different data converges to the same fixed point if the data distribution is in the same universality class.
**Concept description**: The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying parameters), just as each RG step integrates out short-distance modes. Conjecture: The fixed points of SGD on neural networks are precisely the critical points of a renormalization group flow defined by the coarse-graining operator that averages over parameter subsets. Why now: recent work on neural network Gaussian processes shows that infinite-width networks have exact RG fixed points, and the beta function of SGD training has been computed for linear networks. Test: prove that for a 2-layer ReLU network trained on isotropic data, the SGD fixed point corresponds to the Wilson-Fisher fixed point in d=2 dimensions, and compute the critical exponents. Impact: neural network training would be governed by universality classes, meaning the same network trained on different data converges to the same fixed point if the data distribution is in the same universality class.
**Novelty estimate**: 0.7110671834625324
**Breakthrough potential**: 0.5499999999999999
Research domain: MachineLearning
Research mode: team


### Lean 4 Sketch
Define the neural RG flow: for a network f_theta with parameters theta in R^N, the coarse-graining operator C_epsilon averages over parameters within epsilon-balls. Prove that the flow d(theta)/dt = -nabla L(theta) has fixed points that coincide with the RG fixed points of C_epsilon. For a 2-layer ReLU network f(x) = sum_j a_j * ReLU(w_j . x + b_j), prove that the NTK (neural tangent kernel) at the fixed point satisfies K*(x,y) = C * |x-y|^{-2+eta} for some critical exponent eta. Compare with th



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
