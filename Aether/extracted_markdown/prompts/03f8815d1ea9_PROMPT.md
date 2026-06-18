
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

**Title**: The abstract simulation preorder formalized in `ProofSystemCollapse.lean` captur
**Domain**: Applications
**Mathematical framing**: # Future Directions: Proof System Collapse Theory

## 1. Polynomial Simulation and the Cook–Reckhow Program

The abstract simulation preorder formalized in `ProofSystemCollapse.lean` captures the *qualitative* structure of proof complexity. The next step is to enrich simulation with *quantitative* bounds — polynomial-time proof translation and polynomial proof-size blowup. The key insight is that our lattice structure (union = join, intersection = meet) should lift to the polynomial setting: the union of two p-bounded systems should be p-bounded, and the meet should have proof size bounded by the sum of the components. Why now? Lean 4's `Complexity` namespace and recent formalizations of polynomial-time functions in Mathlib provide the computational backbone needed to state polynomial simulation precisely. The testable conjecture: *the indexed union of finitely many p-bounded proof systems is p-bounded*, formalized as a theorem about `ProofSys.iUnion` restricted to systems whose proof sizes are polynomially related to formula size.

## 2. Concrete Proof Systems: Resolution and Frege

The abstract framework should be instantiated with concrete proof systems to yield non-trivial lower and upper bounds. Define a `ResolutionSystem` over CNF formulas (clauses as `Finset (Fin n × Bool)`) and a `FregeSystem` with substitution and modus ponens rules. The key insight is that the singleton system construction in our duality theorem (`singletonSys`) can be generalized to *interpolation systems*, where the proof of a formula encodes a Craig interpolant. The testable conjecture: *Resolution does not simulate Frege*, witnessed by the formalized pigeonhole principle — PHP formulas have polynomial Frege proofs but require exponential resolution proofs (Ben-Sasson and Wigderson 1999). This would be the first formalized proof complexity separation in Lean.

## 3. Proof System Morphisms as a Category

The `ProofSysMorphism` structure (explicit proof translations preserving verification) forms a category whose objects are proof systems and whose morphisms are proof translations. The key insight is that functorial properties of this category encode proof-theoretic phenomena: natural transformations between morphisms correspond to proof transformation strategies, and adjunctions capture optimal simulation relationships. Why now? Mathlib's category theory library is mature enough to express this directly. The testable conjecture: *the category of proof systems with morphisms has all small limits and colimits*, which would give a clean categorical account of why arbitrary meets and joins of proof systems exist.

## 4. EML-Based Proof Systems and Circuit Depth

The `EMLExpr` syntax already formalized in this project provides a concrete basis for defining proof systems where proof steps are verified by evaluating EML (exp-log) expressions. The key insight is that if EML expressions of depth $d$ can represent all Boolean circuits of depth $O(d)$, then an EML-Frege system could have fundamentally different proof complexity from standard Frege systems. Why now? The `towerExpr_depth` theorem already gives exact depth bounds for tower expressions, providing the quantitative control needed to state depth-bounded simulation results. The testable conjecture: *for the EML-Frege system defined via `EMLExpr` evaluation, every propositional tautology on $n$ variables has a proof of size $O(n^c)$ for some fixed $c$*, which would separate EML-Frege from systems known to require superpolynomial proofs.

## 5. Proof System Collapse for Finite Formula Spaces

When the formula type `F` is finite, every sound proof system has a finite provable set, and the simulation preorder is a finite partial order. The key insight is that in this setting, the maximality theorem (`complete_simulates_all_sound`) becomes *decidable*: we can computationally verify whether a system is complete by enumerating all valid formulas. Why now? Lean 4's `Decidable` and `Fintype` instances make this computationally executable via `#eval`. The testable conjecture: *for `F = Fin n`, the number of simulation-equivalence classes of sound proof systems is exactly the number of antichains in the power set lattice of valid formulas*, which connects proof system collapse to Dedekind numbers — a surprising bridge between proof complexity and enumerative combinatorics.

**Concept description**: # Future Directions: Proof System Collapse Theory

## 1. Polynomial Simulation and the Cook–Reckhow Program

The abstract simulation preorder formalized in `ProofSystemCollapse.lean` captures the *qualitative* structure of proof complexity. The next step is to enrich simulation with *quantitative* bounds — polynomial-time proof translation and polynomial proof-size blowup. The key insight is that our lattice structure (union = join, intersection = meet) should lift to the polynomial setting: the union of two p-bounded systems should be p-bounded, and the meet should have proof size bounded by the sum of the components. Why now? Lean 4's `Complexity` namespace and recent formalizations of polynomial-time functions in Mathlib provide the computational backbone needed to state polynomial simulation precisely. The testable conjecture: *the indexed union of finitely many p-bounded proof systems is p-bounded*, formalized as a theorem about `ProofSys.iUnion` restricted to systems whose proof sizes are polynomially related to formula size.

## 2. Concrete Proof Systems: Resolution and Frege

The abstract framework should be instantiated with concrete proof systems to yield non-trivial lower and upper bounds. Define a `ResolutionSystem` over CNF formulas (clauses as `Finset (Fin n × Bool)`) and a `FregeSystem` with substitution and modus ponens rules. The key insight is that the singleton system construction in our duality theorem (`singletonSys`) can be generalized to *interpolation systems*, where the proof of a formula encodes a Craig interpolant. The testable conjecture: *Resolution does not simulate Frege*, witnessed by the formalized pigeonhole principle — PHP formulas have polynomial Frege proofs but require exponential resolution proofs (Ben-Sasson and Wigderson 1999). This would be the first formalized proof complexity separation in Lean.

## 3. Proof System Morphisms as a Category

The `ProofSysMorphism` structure (explicit proof translations preserving verification) forms a category whose objects are proof systems and whose morphisms are proof translations. The key insight is that functorial properties of this category encode proof-theoretic phenomena: natural transformations between morphisms correspond to proof transformation strategies, and adjunctions capture optimal simulation relationships. Why now? Mathlib's category theory library is mature enough to express this directly. The testable conjecture: *the category of proof systems with morphisms has all small limits and colimits*, which would give a clean categorical account of why arbitrary meets and joins of proof systems exist.

## 4. EML-Based Proof Systems and Circuit Depth

The `EMLExpr` syntax already formalized in this project provides a concrete basis for defining proof systems where proof steps are verified by evaluating EML (exp-log) expressions. The key insight is that if EML expressions of depth $d$ can represent all Boolean circuits of depth $O(d)$, then an EML-Frege system could have fundamentally different proof complexity from standard Frege systems. Why now? The `towerExpr_depth` theorem already gives exact depth bounds for tower expressions, providing the quantitative control needed to state depth-bounded simulation results. The testable conjecture: *for the EML-Frege system defined via `EMLExpr` evaluation, every propositional tautology on $n$ variables has a proof of size $O(n^c)$ for some fixed $c$*, which would separate EML-Frege from systems known to require superpolynomial proofs.

## 5. Proof System Collapse for Finite Formula Spaces

When the formula type `F` is finite, every sound proof system has a finite provable set, and the simulation preorder is a finite partial order. The key insight is that in this setting, the maximality theorem (`complete_simulates_all_sound`) becomes *decidable*: we can computationally verify whether a system is complete by enumerating all valid formulas. Why now? Lean 4's `Decidable` and `Fintype` instances make this computationally executable via `#eval`. The testable conjecture: *for `F = Fin n`, the number of simulation-equivalence classes of sound proof systems is exactly the number of antichains in the power set lattice of valid formulas*, which connects proof system collapse to Dedekind numbers — a surprising bridge between proof complexity and enumerative combinatorics.

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
