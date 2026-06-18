
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

**Title**: The natural next step after soundness is **completeness**: every tautology is pr
**Domain**: Applications
**Mathematical framing**: # Future Directions: Propositional Logic Metatheory

## 1. Completeness of the Hilbert System

The natural next step after soundness is **completeness**: every tautology is provable. This requires constructing maximal consistent extensions of theories (Lindenbaum's lemma) and building canonical models. The key insight is that the syntactic deduction theorem we proved makes Lindenbaum's lemma tractable — it reduces the extension step to a single disjunction. Why now? Our `syntactic_deduction` and `weakening` theorems provide the exact structural infrastructure needed for the inductive extension argument, and the `consistency` theorem gives the base case.

**Testable conjecture**: For any `φ : PropForm`, `IsTautology φ → Proves ∅ φ`. The proof should construct a maximal consistent set containing `neg φ` and derive a contradiction from the model it induces.

## 2. Compactness from Completeness

Once completeness is established, **propositional compactness** follows: if every finite subset of `Γ` has a model, then `Γ` has a model. The key insight is that compactness is equivalent to the statement "if `Γ ⊨ φ` then some finite `Δ ⊆ Γ` satisfies `Δ ⊨ φ`", and this follows from completeness since syntactic proofs are finite objects. Why now? The `Models` and `Proves` definitions are already set up to state and prove this, and the finite nature of `Proves` derivations is built into our inductive type.

**Testable conjecture**: `Models Γ φ → ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Models ↑Δ φ`.

## 3. Cut Elimination for Sequent Calculus

Define a Gentzen-style sequent calculus for propositional logic and prove **cut elimination**: any sequent derivation using the cut rule can be transformed into one without it. The key insight is that cut elimination is a syntactic normalization result — it corresponds to β-reduction in the Curry-Howard correspondence, and our Hilbert-style infrastructure can serve as a reference system for proving equivalence. Why now? The Hilbert system theorems provide a certified "backend" against which a sequent calculus can be verified, and the syntactic deduction theorem is the Hilbert-side analogue of the cut rule.

**Testable conjecture**: Define `SeqProves : List PropForm → PropForm → Prop` with structural rules and cut. Then show `SeqProvesCutFree Γ φ ↔ SeqProves Γ φ` where the cut-free variant omits the cut rule.

## 4. Interpolation Theorem

Craig's interpolation theorem states: if `Proves ∅ (imp φ ψ)`, then there exists a formula `θ` whose variables appear in both `φ` and `ψ` such that `Proves ∅ (imp φ θ)` and `Proves ∅ (imp θ ψ)`. The key insight is that interpolation can be proved by induction on cut-free sequent calculus proofs (connecting to Direction 3), or by a direct semantic argument using our Boolean evaluation. Why now? Our `eval`-based semantics provides the natural framework to define "variables of a formula" and verify the variable-containment condition, and soundness ensures the interpolant is meaningful.

**Testable conjecture**: `Proves ∅ (imp φ ψ) → ∃ θ, (vars θ ⊆ vars φ ∩ vars ψ) ∧ Proves ∅ (imp φ θ) ∧ Proves ∅ (imp θ ψ)` where `vars` extracts the set of variable indices.

## 5. Decision Procedure Certification

Formalize a resolution-based decision procedure for propositional satisfiability and prove it **sound and complete** with respect to our `eval` semantics. The key insight is that resolution can be viewed as a restricted form of cut in a clause-based sequent calculus, making it a natural specialization of Direction 3. Why now? Our `IsTautology` and `Models` definitions provide the correctness specification, and the `soundness` theorem ensures that any proof produced by the decision procedure corresponds to a genuine semantic fact. This bridges our logical metatheory directly to verified automated reasoning.

**Testable conjecture**: Define `resolve : List (List (ℕ × Bool)) → Bool` implementing unit propagation + resolution. Then prove `resolve clauses = true → ∀ v, ∃ c ∈ clauses, ∀ l ∈ c, evalLit v l = false` (unsatisfiability certificate).

**Concept description**: # Future Directions: Propositional Logic Metatheory

## 1. Completeness of the Hilbert System

The natural next step after soundness is **completeness**: every tautology is provable. This requires constructing maximal consistent extensions of theories (Lindenbaum's lemma) and building canonical models. The key insight is that the syntactic deduction theorem we proved makes Lindenbaum's lemma tractable — it reduces the extension step to a single disjunction. Why now? Our `syntactic_deduction` and `weakening` theorems provide the exact structural infrastructure needed for the inductive extension argument, and the `consistency` theorem gives the base case.

**Testable conjecture**: For any `φ : PropForm`, `IsTautology φ → Proves ∅ φ`. The proof should construct a maximal consistent set containing `neg φ` and derive a contradiction from the model it induces.

## 2. Compactness from Completeness

Once completeness is established, **propositional compactness** follows: if every finite subset of `Γ` has a model, then `Γ` has a model. The key insight is that compactness is equivalent to the statement "if `Γ ⊨ φ` then some finite `Δ ⊆ Γ` satisfies `Δ ⊨ φ`", and this follows from completeness since syntactic proofs are finite objects. Why now? The `Models` and `Proves` definitions are already set up to state and prove this, and the finite nature of `Proves` derivations is built into our inductive type.

**Testable conjecture**: `Models Γ φ → ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Models ↑Δ φ`.

## 3. Cut Elimination for Sequent Calculus

Define a Gentzen-style sequent calculus for propositional logic and prove **cut elimination**: any sequent derivation using the cut rule can be transformed into one without it. The key insight is that cut elimination is a syntactic normalization result — it corresponds to β-reduction in the Curry-Howard correspondence, and our Hilbert-style infrastructure can serve as a reference system for proving equivalence. Why now? The Hilbert system theorems provide a certified "backend" against which a sequent calculus can be verified, and the syntactic deduction theorem is the Hilbert-side analogue of the cut rule.

**Testable conjecture**: Define `SeqProves : List PropForm → PropForm → Prop` with structural rules and cut. Then show `SeqProvesCutFree Γ φ ↔ SeqProves Γ φ` where the cut-free variant omits the cut rule.

## 4. Interpolation Theorem

Craig's interpolation theorem states: if `Proves ∅ (imp φ ψ)`, then there exists a formula `θ` whose variables appear in both `φ` and `ψ` such that `Proves ∅ (imp φ θ)` and `Proves ∅ (imp θ ψ)`. The key insight is that interpolation can be proved by induction on cut-free sequent calculus proofs (connecting to Direction 3), or by a direct semantic argument using our Boolean evaluation. Why now? Our `eval`-based semantics provides the natural framework to define "variables of a formula" and verify the variable-containment condition, and soundness ensures the interpolant is meaningful.

**Testable conjecture**: `Proves ∅ (imp φ ψ) → ∃ θ, (vars θ ⊆ vars φ ∩ vars ψ) ∧ Proves ∅ (imp φ θ) ∧ Proves ∅ (imp θ ψ)` where `vars` extracts the set of variable indices.

## 5. Decision Procedure Certification

Formalize a resolution-based decision procedure for propositional satisfiability and prove it **sound and complete** with respect to our `eval` semantics. The key insight is that resolution can be viewed as a restricted form of cut in a clause-based sequent calculus, making it a natural specialization of Direction 3. Why now? Our `IsTautology` and `Models` definitions provide the correctness specification, and the `soundness` theorem ensures that any proof produced by the decision procedure corresponds to a genuine semantic fact. This bridges our logical metatheory directly to verified automated reasoning.

**Testable conjecture**: Define `resolve : List (List (ℕ × Bool)) → Bool` implementing unit propagation + resolution. Then prove `resolve clauses = true → ∀ v, ∃ c ∈ clauses, ∀ l ∈ c, evalLit v l = false` (unsatisfiability certificate).

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
