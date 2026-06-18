
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

**Title**: Proof Phase Transitions: Sharp Thresholds in Automated Theorem Discovery
**Domain**: Tropical
**Mathematical framing**: Conjecture: For any sufficiently expressive formal system F and natural random ensemble E_n of true statements of size n, there exists a critical resource density parameter rho_c (measuring available axioms, lemmas, or search-budget per symbol) such that the probability an automated prover finds a proof within bounded time undergoes a sharp threshold at rho_c, analogous to SAT phase transitions; moreover, near rho_c the proof-search graph exhibits universal scaling exponents independent of the prover architecture. Test: Construct benchmark ensembles of parametrized true statements across domains (e.g. random bounded-depth combinatorial identities, finite-group facts, graph properties with certificates), vary rho = resources/n, and measure solve probability, runtime susceptibility, proof-graph component statistics, and finite-size scaling across distinct provers; confirmation requires reproducible sharp thresholds and shared critical exponents, while broad smooth behavior or prover-specific non-universal scaling refutes the conjecture. Impact: Establishes a statistical-mechanics theory of theorem proving, predicts when additional lemmas or compute produce dramatic gains, guides curriculum and benchmark design for theorem-proving AI, and could reveal new complexity invariants of mathematical theories based on their critical proof structure.
**Concept description**: Conjecture: For any sufficiently expressive formal system F and natural random ensemble E_n of true statements of size n, there exists a critical resource density parameter rho_c (measuring available axioms, lemmas, or search-budget per symbol) such that the probability an automated prover finds a proof within bounded time undergoes a sharp threshold at rho_c, analogous to SAT phase transitions; moreover, near rho_c the proof-search graph exhibits universal scaling exponents independent of the prover architecture. Test: Construct benchmark ensembles of parametrized true statements across domains (e.g. random bounded-depth combinatorial identities, finite-group facts, graph properties with certificates), vary rho = resources/n, and measure solve probability, runtime susceptibility, proof-graph component statistics, and finite-size scaling across distinct provers; confirmation requires reproducible sharp thresholds and shared critical exponents, while broad smooth behavior or prover-specific non-universal scaling refutes the conjecture. Impact: Establishes a statistical-mechanics theory of theorem proving, predicts when additional lemmas or compute produce dramatic gains, guides curriculum and benchmark design for theorem-proving AI, and could reveal new complexity invariants of mathematical theories based on their critical proof structure.
**Novelty estimate**: 0.7
**Breakthrough potential**: 0.7
Research domain: Tropical
Research mode: team




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
