
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

**Title**: The current formalization defines the Veblen hierarchy at finite levels `veblenN
**Domain**: Logic
**Mathematical framing**: # Future Directions: Ordinal Analysis Across Systems

## 1. Full Transfinite Veblen Hierarchy

The current formalization defines the Veblen hierarchy at finite levels `veblenN : ℕ → (Ordinal → Ordinal)` by iterating `Ordinal.deriv`. The natural next step is extending this to transfinite levels using ordinal-indexed recursion: define `veblen : Ordinal → Ordinal → Ordinal` where `veblen α` for limit `α` enumerates the common fixed points of all `veblen β` for `β < α`.

The key insight is that Mathlib's `Ordinal.deriv` already handles the successor case perfectly, so the challenge reduces to formalizing the limit case using `Ordinal.nfp` over a family indexed by ordinals below `α`.

Why now? Mathlib's ordinal fixed-point infrastructure (`deriv`, `nfp`, `derivFamily`) is mature enough to support this. The missing piece is a clean transfinite recursion scheme for function-valued ordinal families, which could be built using `Ordinal.rec` or well-founded recursion on ordinals.

## 2. Semantic Interpretation of BHOrd and Correctness of ψ

The `BHOrd` notation system defines ordinal terms syntactically but lacks a semantic interpretation function `BHOrd → Ordinal`. The conjecture is that one can define a partial interpretation function `interp : BHOrd → Option Ordinal` such that for all well-formed terms `t`, `interp t` agrees with the standard ordinal it represents, and moreover `interp (psi zero) = Some epsilon0` where `epsilon0` is our formalized ε₀.

The key insight is that the interpretation of `psi` requires defining the collapsing set `C(α)` as a well-founded inductive-recursive definition, not just the approximation sequence we currently have. The full `collapsingSet` needs to be shown to be closed under the required operations, and the minimum ordinal not in `collapsingSet α` gives `ψ(α)`.

Why now? We have both the syntactic system (`BHOrd`) and the semantic foundation (`collapsingApprox`, `collapsingSet`) formalized. Connecting them is the natural bridge theorem.

## 3. Proof-Theoretic Strength Separation: PA vs. KP

The central claim of ordinal analysis is that ε₀ is the proof-theoretic ordinal of PA while ψ(Ω^ω) is that of KP (Kripke-Platek set theory). A formalization of this would involve: (a) defining a notion of "provably well-ordered" for a formal system, (b) showing that PA proves the well-ordering of all ordinal notations below ε₀, and (c) showing PA cannot prove the well-ordering of ε₀ itself.

The key insight is that (b) can be formalized as a meta-theorem about derivability in PA, using Gödel numbering of ordinal terms. The hard part is (c), which requires formalizing Gentzen's consistency proof or its modern refinements.

Why now? Lean 4 has increasingly good support for meta-programming and proof reflection. The `ONote` type in Mathlib already provides ordinal notations below ε₀ with decidable ordering, which is exactly the structure needed for encoding "provably well-ordered" statements.

## 4. Ordinal Notation Comparison and Normal Forms

Our `BHOrd` type permits non-normal-form terms (e.g., `add (add one one) one` vs. `add one (add one one)`). A decidable comparison function `BHOrd.compare : BHOrd → BHOrd → Ordering` that respects ordinal semantics would require defining Cantor Normal Form for the extended system and proving that every term has a unique normal form.

The key insight is that comparison of `psi` terms reduces to comparison of their arguments when the arguments are in normal form, making the recursion well-founded on term size. This is essentially the Bachmann property: ψ is order-preserving on its domain.

Why now? The `termSize` function and `isSmall`/`psiDepth` predicates we defined provide the structural foundation for well-founded recursion on BHOrd terms. The comparison algorithm is well-documented in Buchholz's work on ordinal notation systems.

## 5. Automated Ordinal Bounds for Recursive Programs

A long-term application: given a structurally recursive function in Lean 4, automatically compute an ordinal bound on its computational complexity (in the sense of the slow-growing hierarchy). The Veblen hierarchy provides natural complexity classes: functions below ε₀ correspond to primitive recursive functions, those below Γ₀ to predicative functions.

The key insight is that Lean 4's termination checker already computes a well-founded relation for recursive functions. Mapping these relations to ordinal notations in our `BHOrd` system would give automatic complexity bounds, connecting proof-theoretic ordinal analysis to practical program analysis.

Why now? The formalized Veblen hierarchy provides the semantic foundation, and Lean 4's elaboration and meta-programming infrastructure makes it feasible to inspect termination proofs programmatically. The `veblenN_succ_fixedPoint` theorem ensures the hierarchy is coherent across levels.

**Concept description**: # Future Directions: Ordinal Analysis Across Systems

## 1. Full Transfinite Veblen Hierarchy

The current formalization defines the Veblen hierarchy at finite levels `veblenN : ℕ → (Ordinal → Ordinal)` by iterating `Ordinal.deriv`. The natural next step is extending this to transfinite levels using ordinal-indexed recursion: define `veblen : Ordinal → Ordinal → Ordinal` where `veblen α` for limit `α` enumerates the common fixed points of all `veblen β` for `β < α`.

The key insight is that Mathlib's `Ordinal.deriv` already handles the successor case perfectly, so the challenge reduces to formalizing the limit case using `Ordinal.nfp` over a family indexed by ordinals below `α`.

Why now? Mathlib's ordinal fixed-point infrastructure (`deriv`, `nfp`, `derivFamily`) is mature enough to support this. The missing piece is a clean transfinite recursion scheme for function-valued ordinal families, which could be built using `Ordinal.rec` or well-founded recursion on ordinals.

## 2. Semantic Interpretation of BHOrd and Correctness of ψ

The `BHOrd` notation system defines ordinal terms syntactically but lacks a semantic interpretation function `BHOrd → Ordinal`. The conjecture is that one can define a partial interpretation function `interp : BHOrd → Option Ordinal` such that for all well-formed terms `t`, `interp t` agrees with the standard ordinal it represents, and moreover `interp (psi zero) = Some epsilon0` where `epsilon0` is our formalized ε₀.

The key insight is that the interpretation of `psi` requires defining the collapsing set `C(α)` as a well-founded inductive-recursive definition, not just the approximation sequence we currently have. The full `collapsingSet` needs to be shown to be closed under the required operations, and the minimum ordinal not in `collapsingSet α` gives `ψ(α)`.

Why now? We have both the syntactic system (`BHOrd`) and the semantic foundation (`collapsingApprox`, `collapsingSet`) formalized. Connecting them is the natural bridge theorem.

## 3. Proof-Theoretic Strength Separation: PA vs. KP

The central claim of ordinal analysis is that ε₀ is the proof-theoretic ordinal of PA while ψ(Ω^ω) is that of KP (Kripke-Platek set theory). A formalization of this would involve: (a) defining a notion of "provably well-ordered" for a formal system, (b) showing that PA proves the well-ordering of all ordinal notations below ε₀, and (c) showing PA cannot prove the well-ordering of ε₀ itself.

The key insight is that (b) can be formalized as a meta-theorem about derivability in PA, using Gödel numbering of ordinal terms. The hard part is (c), which requires formalizing Gentzen's consistency proof or its modern refinements.

Why now? Lean 4 has increasingly good support for meta-programming and proof reflection. The `ONote` type in Mathlib already provides ordinal notations below ε₀ with decidable ordering, which is exactly the structure needed for encoding "provably well-ordered" statements.

## 4. Ordinal Notation Comparison and Normal Forms

Our `BHOrd` type permits non-normal-form terms (e.g., `add (add one one) one` vs. `add one (add one one)`). A decidable comparison function `BHOrd.compare : BHOrd → BHOrd → Ordering` that respects ordinal semantics would require defining Cantor Normal Form for the extended system and proving that every term has a unique normal form.

The key insight is that comparison of `psi` terms reduces to comparison of their arguments when the arguments are in normal form, making the recursion well-founded on term size. This is essentially the Bachmann property: ψ is order-preserving on its domain.

Why now? The `termSize` function and `isSmall`/`psiDepth` predicates we defined provide the structural foundation for well-founded recursion on BHOrd terms. The comparison algorithm is well-documented in Buchholz's work on ordinal notation systems.

## 5. Automated Ordinal Bounds for Recursive Programs

A long-term application: given a structurally recursive function in Lean 4, automatically compute an ordinal bound on its computational complexity (in the sense of the slow-growing hierarchy). The Veblen hierarchy provides natural complexity classes: functions below ε₀ correspond to primitive recursive functions, those below Γ₀ to predicative functions.

The key insight is that Lean 4's termination checker already computes a well-founded relation for recursive functions. Mapping these relations to ordinal notations in our `BHOrd` system would give automatic complexity bounds, connecting proof-theoretic ordinal analysis to practical program analysis.

Why now? The formalized Veblen hierarchy provides the semantic foundation, and Lean 4's elaboration and meta-programming infrastructure makes it feasible to inspect termination proofs programmatically. The `veblenN_succ_fixedPoint` theorem ensures the hierarchy is coherent across levels.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
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
