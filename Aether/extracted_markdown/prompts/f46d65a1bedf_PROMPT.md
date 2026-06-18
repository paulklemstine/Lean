
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

**Title**: Our framework shows that soundness implies consistency but not vice versa, with 
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Logic-Physics Bridge

## 1. Formalizing the Completeness Theorem for Classical Propositional Theories

Our framework shows that soundness implies consistency but not vice versa, with the pathological theory (where negation is identity) as a separator. A natural next step is to formalize sufficient conditions under which consistency implies soundness — the completeness direction. **The key insight is** that for theories where negation is an involution *without fixed points* (i.e., ¬φ ≠ φ for all φ), consistency should imply the existence of a model via a Lindenbaum-type construction. **Why now?** The abstract framework in `ConsistencyFramework.lean` already has all the definitions needed; the missing piece is the Zorn's-lemma-based maximal extension, which Mathlib's `Zorn.zorn_subset` can provide.

## 2. Hierarchical Provability: Formalizing the Ordinal Analysis of Theory Strength

The interpretability ordering on theories is a preorder, and our `Interpretation.comp` shows it is transitive. An important open question is formalizing the *well-foundedness* of consistency strength for natural theories — the observation that natural mathematical theories are linearly ordered by consistency strength. **The key insight is** that one can associate proof-theoretic ordinals to theories and show that the interpretability ordering on sufficiently well-behaved theories embeds into the ordinals. **Why now?** Mathlib has extensive ordinal arithmetic (`Ordinal.lean`), and our `GoedelianTheory` structure provides the right abstraction level to state the conjecture that the consistency strength of extensions of PA is well-ordered.

## 3. Quantum Consistency via Operator Algebras

The physical-theory-as-model paradigm in our framework treats the physical world as a classical model. For quantum theories, the "model" should be a C*-algebra or von Neumann algebra, where sentences are self-adjoint operators and truth is spectral membership. **The key insight is** that replacing the Prop-valued `val` in our `Model` structure with a projection-valued measure on a Hilbert space gives a non-commutative generalization where soundness still implies consistency, but the counterexample space is richer — non-commutative theories can be consistent in ways that have no classical analog. **Why now?** Mathlib has C*-algebra foundations (`Analysis.NormedSpace.Star`), and the abstract `Model` structure in our framework was designed to be replaceable with richer semantic structures.

## 4. Effective Interpretability and Computational Complexity of Consistency

Our `Interpretation` structure requires only that translations preserve provability, with no computability constraints. In practice, interpretations between theories (e.g., the interpretation of PA in ZFC) are computable. **The key insight is** that restricting to *computable* interpretations (where `translate` is a computable function and `preserves_provability` has a computable witness) gives a refinement of the consistency hierarchy that connects to computational complexity — specifically, the complexity of deciding whether a given sentence is in the image of the translation. **Why now?** Lean 4's computational foundation makes it natural to distinguish computable from non-computable interpretations, and Mathlib's computability library provides the tools to formalize this distinction.

## 5. The Tennenbaum Phenomenon: Non-Standard Models and Physical Theories

Our `PhysicalTheory` has a *standard* model (the physical world). Tennenbaum's theorem says that every non-standard model of PA is non-computable. This creates an interesting tension: physical theories should have computable models (since physics is computable), but extensions of these theories may only have non-standard, non-computable models. **The key insight is** that formalizing the distinction between standard and non-standard models within our framework would give a sharp characterization of which theory extensions preserve "physical realizability" — a notion strictly between consistency and soundness. **Why now?** The `theoryOfModel` construction in `TheoryHierarchy.lean` already converts models to theories; adding a computability predicate on models would immediately yield the refined hierarchy.

**Concept description**: # Future Directions: Logic-Physics Bridge

## 1. Formalizing the Completeness Theorem for Classical Propositional Theories

Our framework shows that soundness implies consistency but not vice versa, with the pathological theory (where negation is identity) as a separator. A natural next step is to formalize sufficient conditions under which consistency implies soundness — the completeness direction. **The key insight is** that for theories where negation is an involution *without fixed points* (i.e., ¬φ ≠ φ for all φ), consistency should imply the existence of a model via a Lindenbaum-type construction. **Why now?** The abstract framework in `ConsistencyFramework.lean` already has all the definitions needed; the missing piece is the Zorn's-lemma-based maximal extension, which Mathlib's `Zorn.zorn_subset` can provide.

## 2. Hierarchical Provability: Formalizing the Ordinal Analysis of Theory Strength

The interpretability ordering on theories is a preorder, and our `Interpretation.comp` shows it is transitive. An important open question is formalizing the *well-foundedness* of consistency strength for natural theories — the observation that natural mathematical theories are linearly ordered by consistency strength. **The key insight is** that one can associate proof-theoretic ordinals to theories and show that the interpretability ordering on sufficiently well-behaved theories embeds into the ordinals. **Why now?** Mathlib has extensive ordinal arithmetic (`Ordinal.lean`), and our `GoedelianTheory` structure provides the right abstraction level to state the conjecture that the consistency strength of extensions of PA is well-ordered.

## 3. Quantum Consistency via Operator Algebras

The physical-theory-as-model paradigm in our framework treats the physical world as a classical model. For quantum theories, the "model" should be a C*-algebra or von Neumann algebra, where sentences are self-adjoint operators and truth is spectral membership. **The key insight is** that replacing the Prop-valued `val` in our `Model` structure with a projection-valued measure on a Hilbert space gives a non-commutative generalization where soundness still implies consistency, but the counterexample space is richer — non-commutative theories can be consistent in ways that have no classical analog. **Why now?** Mathlib has C*-algebra foundations (`Analysis.NormedSpace.Star`), and the abstract `Model` structure in our framework was designed to be replaceable with richer semantic structures.

## 4. Effective Interpretability and Computational Complexity of Consistency

Our `Interpretation` structure requires only that translations preserve provability, with no computability constraints. In practice, interpretations between theories (e.g., the interpretation of PA in ZFC) are computable. **The key insight is** that restricting to *computable* interpretations (where `translate` is a computable function and `preserves_provability` has a computable witness) gives a refinement of the consistency hierarchy that connects to computational complexity — specifically, the complexity of deciding whether a given sentence is in the image of the translation. **Why now?** Lean 4's computational foundation makes it natural to distinguish computable from non-computable interpretations, and Mathlib's computability library provides the tools to formalize this distinction.

## 5. The Tennenbaum Phenomenon: Non-Standard Models and Physical Theories

Our `PhysicalTheory` has a *standard* model (the physical world). Tennenbaum's theorem says that every non-standard model of PA is non-computable. This creates an interesting tension: physical theories should have computable models (since physics is computable), but extensions of these theories may only have non-standard, non-computable models. **The key insight is** that formalizing the distinction between standard and non-standard models within our framework would give a sharp characterization of which theory extensions preserve "physical realizability" — a notion strictly between consistency and soundness. **Why now?** The `theoryOfModel` construction in `TheoryHierarchy.lean` already converts models to theories; adding a computability predicate on models would immediately yield the refined hierarchy.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
