
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

**Title**: Quantum Surreal Numbers: Superposition of All Real Numbers
**Domain**: Geometry
**Mathematical framing**: Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION — simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 — the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.
**Concept description**: Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION — simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 — the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.
**Novelty estimate**: 0.86
**Breakthrough potential**: 0.86
Research domain: Geometry
Research mode: team


### Lean 4 Sketch
Define Q(No) as the tensor product of the surreal field No with the complex numbers C. Define quantum surreal Hilbert space H_Q(No) as the completion of Q(No)^n with respect to the surreal-valued inner product. Prove the spectral theorem for self-adjoint operators on H_Q(No) by transfinite induction on the birthday of the surreal eigenvalues. The key lemma: if A is self-adjoint with surreal eigenvalues, then A = integral lambda dE(lambda) where E(lambda) are projections and lambda ranges over su



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
