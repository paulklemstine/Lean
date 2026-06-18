
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

**Title**: Proof Complexity Collapse: P=NP via Proof Checking
**Domain**: Logic
**Mathematical framing**: The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.
**Concept description**: The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.
**Novelty estimate**: 0.97
**Breakthrough potential**: 0.97
Research domain: Logic
Research mode: team


### Lean 4 Sketch
Define EML-Frege proof system: axioms are EML identities, inference rules are substitution and modus ponens. Prove soundness (all provable formulas are true) and completeness (all true quantifier-free formulas have proofs). The key lemma: every boolean function on n variables has an EML representation of depth O(log n). This follows from EML universality. Prove that EML-Frege polynomially simulates Extended Frege by encoding each EF-rule as a constant-depth EML derivation.



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
