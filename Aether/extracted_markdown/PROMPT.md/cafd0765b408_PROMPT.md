
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

**Title**: The Monster Group's Secret Message: Moonshine Beyond the j-Function
**Domain**: Computation
**Mathematical framing**: The Monster group M is the largest sporadic simple group, with order 2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71 (approximately 8 * 10^{53}). Monstrous moonshine says that the coefficients of the j-function encode the dimensions of representations of M. But the j-function is just the TIP of the iceberg. Conjecture: The full moonshine correspondence associates to each conjugacy class g in M a McKay-Thompson series T_g(q) = sum a_n(g) q^n that is a modular function of a specific level, and the product over all g in M of T_g(q) equals a modular form of weight |M|/24 that encodes the complete character table of M. The secret message: the Monster group IS a modular form, and every property of M (its order, its character table, its maximal subgroups) can be read off from the q-expansion of this product. Test: compute the first 100 coefficients of T_g(q) for each conjugacy class of M and verify they match the known character values. Prove that the product of all T_g(q) converges to a modular form. Impact: the Monster is not just connected to modular forms — it IS a modular form. The 194 conjugacy classes of M correspond to 194 modular forms, and their product encodes everything.
**Concept description**: The Monster group M is the largest sporadic simple group, with order 2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71 (approximately 8 * 10^{53}). Monstrous moonshine says that the coefficients of the j-function encode the dimensions of representations of M. But the j-function is just the TIP of the iceberg. Conjecture: The full moonshine correspondence associates to each conjugacy class g in M a McKay-Thompson series T_g(q) = sum a_n(g) q^n that is a modular function of a specific level, and the product over all g in M of T_g(q) equals a modular form of weight |M|/24 that encodes the complete character table of M. The secret message: the Monster group IS a modular form, and every property of M (its order, its character table, its maximal subgroups) can be read off from the q-expansion of this product. Test: compute the first 100 coefficients of T_g(q) for each conjugacy class of M and verify they match the known character values. Prove that the product of all T_g(q) converges to a modular form. Impact: the Monster is not just connected to modular forms — it IS a modular form. The 194 conjugacy classes of M correspond to 194 modular forms, and their product encodes everything.
**Novelty estimate**: 0.89
**Breakthrough potential**: 0.89
Research domain: Computation
Research mode: team


### Lean 4 Sketch
State the moonshine conjecture (proved by Borcherds): each conjugacy class g of M has a McKay-Thompson series T_g(q) that is a Hauptmodul of genus 0 for a specific modular curve. Extend: define the Monster product P(q) = prod_{g in Conj(M)} T_g(q)^{1/|C(g)|} where C(g) is the conjugacy class. Prove P(q) converges: log P(q) = sum_g (1/|C(g)|) * log T_g(q) = sum_g sum_n (1/|C(g)|) * a_n(g)/n * q^n. Each term is bounded by |a_n(g)|/n * |q|^n which is O(n^{3/2}) by Deligne's bound. Prove P(q) is a m



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
