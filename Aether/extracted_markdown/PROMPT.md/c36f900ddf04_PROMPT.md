
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

**Title**: Tropicalized Berggren dynamics as a min-plus automaton on primitive Pythagorean triples
**Domain**: Bridges
**Mathematical framing**: Let `A,B,C` be the Berggren generators acting on primitive Pythagorean triples, with classical word evaluation already available through `evalWord`-style infrastructure. Introduce a tropical state space `T = ℤ × ℤ × ℤ` or a quotient capturing logarithmic coordinate growth, together with tropical affine pieces `x ↦ M ⊗ x ⊕ b` in min-plus notation. For each generator `G ∈ {A,B,C}`, define a finite family of affine pieces whose pointwise minimum models the dominant-growth behavior of `G`. Then define the tropical evaluation `tropEval : Word → T → T` by composition. Main conjectural/provable statements: (1) functoriality: `tropEval (uv) = tropEval v ∘ tropEval u`; (2) piecewise-linearity/canonical form for each word using tropical polynomial machinery from `Tropical/Canonical/Basic.lean`; (3) comparison theorem: if `h` is a classical height such as `max x y z` or `x+y+z`, then there exist explicit constants or exact formulas with `tropEval w` bounding or determining `log h (evalWord w)` up to controlled error; (4) branch-pruning theorem: if a tropical lower bound for height already exceeds `N`, then every classical descendant exceeds `N`, yielding a certified search algorithm. Lean work should focus on a finite, algebraic version first: define tropical affine pieces over integers, prove composition lemmas, then connect them to Berggren matrices via coordinate inequalities. This is falsifiable because the comparison theorem may fail for some candidate height or state encoding; success requires identifying the correct invariant and proving it generator-by-generator.
**Concept description**: The key insight is that the Berggren generation of primitive Pythagorean triples should admit a tropical shadow: by applying coordinatewise valuation or logarithmic size functionals to the Berggren matrices, one can induce a min-plus piecewise-linear dynamical system whose states encode growth, branch preference, and invariants of the classical tree. This is not a restatement of existing Berggren or tropical results: the goal is to prove that specific arithmetic invariants of words in the Berggren generators are recoverable from a tropical recursion, giving a new bridge between Pythagorean enumeration and tropical geometry. Why now: the catalog already has strong verified foundations for Berggren dynamics in `Geometry/BerggrenRamanujan.lean`, Lorentz/Pythagorean structure in `Algebra/BerggrenLorentz/Core.lean`, cryptographic word evaluation in `Cryptography/BerggrenFingerprintRigidity.lean` and `Cryptography/BerggrenLatticeReduction.lean`, while Tropical has an explicit high-priority canonical-basic gap in `Tropical/Canonical/Basic.lean`. This makes it timely to define tropical affine pieces for Berggren generator actions and prove comparison theorems between classical word evaluation and tropicalized growth profiles. Concretely, define for each Berggren generator a tropical affine map on a suitable state space of log-coordinates; prove that tropical evaluation of a word is additive under concatenation, monotone under generator extension, and gives lower or upper bounds on Euclidean norm, max-coordinate, or Lorentz height of the corresponding primitive triple. The strongest target is a theorem of the form: for every word w, the tropical evaluation equals the minimum over affine pieces determined by the Berggren matrices, and this quantity controls a classical arithmetic invariant of `evalWord w`. A second target is an algorithmic pipeline: given a target size bound, the tropical automaton prunes Berggren search branches while preserving completeness for all triples below that bound. This would matter because it turns an exact arithmetic tree into a formally verified min-plus heuristic with provable guarantees, opening a route from tropical geometry to certified enumeration and possibly to cryptographic complexity estimates for Berggren-based constructions.
**Novelty estimate**: 0.91
**Breakthrough potential**: 0.88
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create `Bridges/TropicalBerggrenAutomaton.lean`. Reuse Berggren generator and `evalWord` definitions from Cryptography/Geometry files. Import or extend `Tropical/Canonical/Basic.lean` to define integer-valued tropical affine pieces and their evaluation. Prove generator-specific inequalities first, then induct on words. If needed, first discharge the six sorries in `Tropical/Canonical/Basic.lean` as enabling infrastructure, but only insofar as necessary for the bridge theorem.



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
