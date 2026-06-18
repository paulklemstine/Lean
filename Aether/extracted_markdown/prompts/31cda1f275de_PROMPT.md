
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

**Title**: Entropy as a Topological Invariant: The Boltzmann Bridge
**Domain**: Geometry
**Mathematical framing**: The key insight is that Boltzmann entropy S = k log W is a topological invariant of the energy landscape. If the energy function E: X -> R on a state space X defines a filtration by sublevel sets X_t = {x : E(x) <= t}, then the persistent homology barcode of this filtration encodes the entropy as the sum of bar lengths: S(E) = k * sum_i (d_i - b_i) where b_i and d_i are birth and death times of persistent homology bars. Conjecture: The Boltzmann entropy of a physical system equals the total persistence (sum of bar lengths) of the energy landscape filtration, up to an additive constant. Why now: persistent homology has matured as a computational tool, and the stability theorem guarantees that small perturbations in the energy function produce small changes in the barcode — exactly the thermodynamic stability we expect. Test: compute the persistent homology barcode for the Ising model energy landscape on a 4x4 lattice and verify that sum of bar lengths equals k log(2^{16}) = 16k log 2. Impact: entropy becomes a computable topological quantity, bridging thermodynamics and algebraic topology. Phase transitions correspond to births of new bars in the barcode.
**Concept description**: The key insight is that Boltzmann entropy S = k log W is a topological invariant of the energy landscape. If the energy function E: X -> R on a state space X defines a filtration by sublevel sets X_t = {x : E(x) <= t}, then the persistent homology barcode of this filtration encodes the entropy as the sum of bar lengths: S(E) = k * sum_i (d_i - b_i) where b_i and d_i are birth and death times of persistent homology bars. Conjecture: The Boltzmann entropy of a physical system equals the total persistence (sum of bar lengths) of the energy landscape filtration, up to an additive constant. Why now: persistent homology has matured as a computational tool, and the stability theorem guarantees that small perturbations in the energy function produce small changes in the barcode — exactly the thermodynamic stability we expect. Test: compute the persistent homology barcode for the Ising model energy landscape on a 4x4 lattice and verify that sum of bar lengths equals k log(2^{16}) = 16k log 2. Impact: entropy becomes a computable topological quantity, bridging thermodynamics and algebraic topology. Phase transitions correspond to births of new bars in the barcode.
**Novelty estimate**: 0.93
**Breakthrough potential**: 0.93
Research domain: Geometry
Research mode: team


### Lean 4 Sketch
Define the energy filtration F_t = {x : E(x) <= t} for energy function E on state space X. Compute the persistent homology barcode {b_i, d_i} of this filtration. Prove: S(E) = k * sum_i (d_i - b_i) + C where C is a constant depending only on X. Key lemma: for the Ising model on L x L lattice with E(sigma) = -J sum_{<i,j>} sigma_i sigma_j, the barcode has bars born at -4JL^2 (ground state) and dying at 0 (paramagnetic), with total persistence = 4JL^2 = kT log(2^{L^2}) at the critical point.



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
