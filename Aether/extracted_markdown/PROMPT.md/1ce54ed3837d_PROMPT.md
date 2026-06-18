
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

**Title**: The next step in the large cardinal hierarchy after Mahlo is the measurable card
**Domain**: Shared
**Mathematical framing**: # Future Directions: Large Cardinal Hierarchy Formalization

## 1. Measurable Cardinals via Ultrafilters

The next step in the large cardinal hierarchy after Mahlo is the measurable cardinal. A cardinal κ is measurable if there exists a κ-complete non-principal ultrafilter on κ. This can be formalized using Mathlib's existing filter and ultrafilter infrastructure. The key theorem to prove would be: every measurable cardinal is Mahlo, establishing the next link in the consistency strength chain.

The key insight is that the existence of a κ-complete ultrafilter on κ implies that the set of regular cardinals below κ is not just stationary but in fact belongs to the ultrafilter — a much stronger property. This can be proved by showing that the set of singular cardinals below κ is not in the ultrafilter (using the Ulam matrix argument).

Why now? Mathlib already has `Filter`, `Ultrafilter`, and `Filter.CountableInter` (the countable completeness analogue). Extending to κ-completeness is a natural generalization, and the Ulam matrix argument has a clean combinatorial structure well-suited to formal verification.

## 2. Club Filter as a Normal Filter

Our formalization defines club and stationary sets with an ω-closure condition. The full theory requires closure under arbitrary sequences of length less than κ (not just countable sequences). Formalizing the club filter as a normal κ-complete filter on κ would unify several results and enable the Fodor pressing-down lemma (Fodor's theorem), which states that every regressive function on a stationary set is constant on a stationary subset.

The key insight is that the club filter is not just closed under finite intersection but under < κ-sized intersection (for regular uncountable κ), making it a normal ideal. This connects set theory to the theory of Boolean algebras and forcing.

Why now? The ω-closed version is formalized. Generalizing to arbitrary cofinality requires Ordinal.bsup infrastructure, which Mathlib now provides. Fodor's theorem has a short inductive proof once the definitions are right.

## 3. Indescribable Cardinals and Reflection Principles

A cardinal κ is Π¹_n-indescribable if for every Π¹_n sentence φ that holds in V_κ, there exists α < κ such that φ holds in V_α. The hierarchy of indescribable cardinals sits between Mahlo and measurable in consistency strength. Formalizing this requires a theory of the cumulative hierarchy V_α, which could be built using well-founded recursion on ordinals.

The key insight is that inaccessibility is equivalent to Π⁰₁-indescribability, and the Mahlo property is equivalent to Π¹₀-indescribability (a classical result of Hanf and Scott). This provides an alternative characterization of the large cardinals we formalized.

Why now? The key infrastructure — ordinal recursion, cardinal arithmetic, and the aleph fixed point theorem — is now in place from our formalization. The cumulative hierarchy can be built as a family of types indexed by ordinals using well-founded recursion.

## 4. Consistency Strength Separation via Inner Models

The ultimate goal is to prove strict separation: Con(ZFC + ∃ Mahlo) → Con(ZFC + ∃ inaccessible), but not vice versa. This requires constructing inner models — for example, showing that if κ is Mahlo, then V_κ is a model of ZFC + "there exists an inaccessible cardinal." This is inherently metamathematical and requires formalizing satisfaction relations for set-theoretic formulas.

The key insight is that the aleph fixed point theorem (proved in our formalization) and the exists_inaccessible_below theorem together show that V_κ for Mahlo κ sees inaccessible cardinals — this is the semantic content of consistency strength separation. Formalizing the satisfaction relation is the missing piece.

Why now? Recent work on formalizing Gödel's incompleteness theorems in Lean (e.g., the FLean project) provides patterns for encoding syntax and satisfaction. Our cardinal arithmetic results (pow_lt, aleph fixed points) provide the mathematical content that the inner model argument needs.

## 5. Cardinal Arithmetic Independence: Easton's Theorem

Easton's theorem states that the function κ ↦ 2^κ on regular cardinals can be essentially arbitrary (subject to König's theorem constraints). Formalizing even a weak version — showing that GCH is independent of ZFC — would connect our cardinal arithmetic results to forcing theory. Our `IsInaccessible.pow_lt` theorem shows that inaccessible cardinals provide natural upper bounds for cardinal exponentiation; Easton's theorem shows these bounds are essentially optimal.

The key insight is that our iterPow construction (used to build strong limits) is a special case of the beth function, and the gap between beth and aleph fixed points is precisely where GCH independence lives.

Why now? The iterPow infrastructure and strong limit theorems from our formalization provide the "ground model" side of the forcing argument. Formalizing Boolean-valued models (the algebraic approach to forcing) could leverage Mathlib's complete Boolean algebra library.

**Concept description**: # Future Directions: Large Cardinal Hierarchy Formalization

## 1. Measurable Cardinals via Ultrafilters

The next step in the large cardinal hierarchy after Mahlo is the measurable cardinal. A cardinal κ is measurable if there exists a κ-complete non-principal ultrafilter on κ. This can be formalized using Mathlib's existing filter and ultrafilter infrastructure. The key theorem to prove would be: every measurable cardinal is Mahlo, establishing the next link in the consistency strength chain.

The key insight is that the existence of a κ-complete ultrafilter on κ implies that the set of regular cardinals below κ is not just stationary but in fact belongs to the ultrafilter — a much stronger property. This can be proved by showing that the set of singular cardinals below κ is not in the ultrafilter (using the Ulam matrix argument).

Why now? Mathlib already has `Filter`, `Ultrafilter`, and `Filter.CountableInter` (the countable completeness analogue). Extending to κ-completeness is a natural generalization, and the Ulam matrix argument has a clean combinatorial structure well-suited to formal verification.

## 2. Club Filter as a Normal Filter

Our formalization defines club and stationary sets with an ω-closure condition. The full theory requires closure under arbitrary sequences of length less than κ (not just countable sequences). Formalizing the club filter as a normal κ-complete filter on κ would unify several results and enable the Fodor pressing-down lemma (Fodor's theorem), which states that every regressive function on a stationary set is constant on a stationary subset.

The key insight is that the club filter is not just closed under finite intersection but under < κ-sized intersection (for regular uncountable κ), making it a normal ideal. This connects set theory to the theory of Boolean algebras and forcing.

Why now? The ω-closed version is formalized. Generalizing to arbitrary cofinality requires Ordinal.bsup infrastructure, which Mathlib now provides. Fodor's theorem has a short inductive proof once the definitions are right.

## 3. Indescribable Cardinals and Reflection Principles

A cardinal κ is Π¹_n-indescribable if for every Π¹_n sentence φ that holds in V_κ, there exists α < κ such that φ holds in V_α. The hierarchy of indescribable cardinals sits between Mahlo and measurable in consistency strength. Formalizing this requires a theory of the cumulative hierarchy V_α, which could be built using well-founded recursion on ordinals.

The key insight is that inaccessibility is equivalent to Π⁰₁-indescribability, and the Mahlo property is equivalent to Π¹₀-indescribability (a classical result of Hanf and Scott). This provides an alternative characterization of the large cardinals we formalized.

Why now? The key infrastructure — ordinal recursion, cardinal arithmetic, and the aleph fixed point theorem — is now in place from our formalization. The cumulative hierarchy can be built as a family of types indexed by ordinals using well-founded recursion.

## 4. Consistency Strength Separation via Inner Models

The ultimate goal is to prove strict separation: Con(ZFC + ∃ Mahlo) → Con(ZFC + ∃ inaccessible), but not vice versa. This requires constructing inner models — for example, showing that if κ is Mahlo, then V_κ is a model of ZFC + "there exists an inaccessible cardinal." This is inherently metamathematical and requires formalizing satisfaction relations for set-theoretic formulas.

The key insight is that the aleph fixed point theorem (proved in our formalization) and the exists_inaccessible_below theorem together show that V_κ for Mahlo κ sees inaccessible cardinals — this is the semantic content of consistency strength separation. Formalizing the satisfaction relation is the missing piece.

Why now? Recent work on formalizing Gödel's incompleteness theorems in Lean (e.g., the FLean project) provides patterns for encoding syntax and satisfaction. Our cardinal arithmetic results (pow_lt, aleph fixed points) provide the mathematical content that the inner model argument needs.

## 5. Cardinal Arithmetic Independence: Easton's Theorem

Easton's theorem states that the function κ ↦ 2^κ on regular cardinals can be essentially arbitrary (subject to König's theorem constraints). Formalizing even a weak version — showing that GCH is independent of ZFC — would connect our cardinal arithmetic results to forcing theory. Our `IsInaccessible.pow_lt` theorem shows that inaccessible cardinals provide natural upper bounds for cardinal exponentiation; Easton's theorem shows these bounds are essentially optimal.

The key insight is that our iterPow construction (used to build strong limits) is a special case of the beth function, and the gap between beth and aleph fixed points is precisely where GCH independence lives.

Why now? The iterPow infrastructure and strong limit theorems from our formalization provide the "ground model" side of the forcing argument. Formalizing Boolean-valued models (the algebraic approach to forcing) could leverage Mathlib's complete Boolean algebra library.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
Research mode: team




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
