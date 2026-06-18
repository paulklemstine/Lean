
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

**Title**: The current framework models theories by their set of provably well-ordered ordi
**Domain**: Pythagorean
**Mathematical framing**: # Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Ordinal Collapsing Functions and the Bachmann-Howard Ordinal

The current framework models theories by their set of provably well-ordered ordinals, but stops at the supremum (sSup). The next natural step is to formalize ordinal collapsing functions — the Bachmann-Howard hierarchy — which provide concrete ordinal notation systems for theories significantly beyond ε₀. The key insight is that ordinal collapsing functions (ψ, θ) allow us to "name" large ordinals using smaller ones as indices, creating a computable notation system for ordinals up to the Bachmann-Howard ordinal. Why now? Mathlib already has `ONote` for ordinals below ε₀; extending to collapsing functions would be the first formalization of these in any proof assistant, bridging the gap between concrete notation systems and abstract ordinal theory.

**Testable conjecture**: A collapsing function ψ_Ω defined on ordinal notations below Ω (the first uncountable ordinal) yields a well-founded notation system whose order type is exactly the Bachmann-Howard ordinal.

## 2. Proof-Theoretic Ordinals of Concrete Theories

Our `BoundedTheory` framework is abstract — it characterizes theories by their provably-WO sets without connecting to specific formal systems. The key insight is that by formalizing the encoding of well-ordering proofs in specific theories (PA, ATR₀, Π¹₁-CA₀), we can prove that the abstract PTO matches the known values: |PA| = ε₀, |ATR₀| = Γ₀, |Π¹₁-CA₀| = ψ_Ω(ε_{Ω+1}). Why now? The `bounded_theory_saturated` theorem shows all BoundedTheories are automatically saturated, which means the abstract framework perfectly captures the "initial segment" structure of provability — this is exactly the structure needed to connect to concrete theories.

**Testable conjecture**: There exists a computable function mapping PA proofs of transfinite induction principles to ordinal notations below ε₀, and every notation below ε₀ arises this way.

## 3. The Ordinal Triangle Inequality Obstruction and Commutative Quotients

We discovered that the natural ordinal-valued "distance" depthDist fails the triangle inequality due to non-commutativity of ordinal addition. The key insight is that this failure is not a bug but a feature: it reflects the genuine asymmetry of proof-theoretic strength, where combining two theories is not commutative at the ordinal level. Why now? The `depthDist_monotone_right` theorem shows that monotonicity holds, suggesting that the right framework is a directed metric space (quasi-metric) rather than a metric space. Formalizing the quasi-metric structure and characterizing when the triangle inequality does hold (e.g., for theories with PTOs below ω^ω, where ordinal arithmetic is commutative up to Cantor normal form) would give a precise boundary.

**Testable conjecture**: depthDist satisfies the triangle inequality if and only if all three PTOs involved are additive principal ordinals (ordinals α such that β + γ < α whenever β, γ < α).

## 4. Theory Strength as a Well-Quasi-Order

The `pto_strictly_increasing_chain` theorem shows that strictly increasing chains of theories have strictly increasing PTOs. The key insight is that by combining this with the well-foundedness of ordinals below a bound, we can show that the space of theories with bounded PTO forms a well-quasi-order under the provability inclusion relation. Why now? This would connect proof-theoretic ordinal analysis to the theory of well-quasi-orders (Kruskal's theorem, graph minor theorem), potentially yielding new independence results.

**Testable conjecture**: The set of BoundedTheories with PTO below ε₀, ordered by provablyWO inclusion, contains no infinite antichain (and is in fact a better-quasi-order).

## 5. Effective Ordinal Assignments via Fast-Growing Hierarchies

Mathlib's `ONote.fastGrowing` and `fastGrowingε₀` provide a computable hierarchy of functions ℕ → ℕ indexed by ordinal notations. The key insight is that the fast-growing hierarchy gives an effective characterization of proof-theoretic ordinals: a theory T has PTO ≥ α if and only if T can prove totality of the fast-growing function f_α. Why now? The `FinitelyDescribedTheory` structure already connects abstract PTOs to concrete `NONote` values; the next step is to connect these to the function-growth characterization, which is the historically primary way proof-theoretic ordinals were computed.

**Testable conjecture**: For every NONote α, there is a BoundedTheory T_α with PTO = α.repr such that T_α proves totality of `ONote.fastGrowing α` but no theory with PTO < α.repr can prove the same.

**Concept description**: # Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Ordinal Collapsing Functions and the Bachmann-Howard Ordinal

The current framework models theories by their set of provably well-ordered ordinals, but stops at the supremum (sSup). The next natural step is to formalize ordinal collapsing functions — the Bachmann-Howard hierarchy — which provide concrete ordinal notation systems for theories significantly beyond ε₀. The key insight is that ordinal collapsing functions (ψ, θ) allow us to "name" large ordinals using smaller ones as indices, creating a computable notation system for ordinals up to the Bachmann-Howard ordinal. Why now? Mathlib already has `ONote` for ordinals below ε₀; extending to collapsing functions would be the first formalization of these in any proof assistant, bridging the gap between concrete notation systems and abstract ordinal theory.

**Testable conjecture**: A collapsing function ψ_Ω defined on ordinal notations below Ω (the first uncountable ordinal) yields a well-founded notation system whose order type is exactly the Bachmann-Howard ordinal.

## 2. Proof-Theoretic Ordinals of Concrete Theories

Our `BoundedTheory` framework is abstract — it characterizes theories by their provably-WO sets without connecting to specific formal systems. The key insight is that by formalizing the encoding of well-ordering proofs in specific theories (PA, ATR₀, Π¹₁-CA₀), we can prove that the abstract PTO matches the known values: |PA| = ε₀, |ATR₀| = Γ₀, |Π¹₁-CA₀| = ψ_Ω(ε_{Ω+1}). Why now? The `bounded_theory_saturated` theorem shows all BoundedTheories are automatically saturated, which means the abstract framework perfectly captures the "initial segment" structure of provability — this is exactly the structure needed to connect to concrete theories.

**Testable conjecture**: There exists a computable function mapping PA proofs of transfinite induction principles to ordinal notations below ε₀, and every notation below ε₀ arises this way.

## 3. The Ordinal Triangle Inequality Obstruction and Commutative Quotients

We discovered that the natural ordinal-valued "distance" depthDist fails the triangle inequality due to non-commutativity of ordinal addition. The key insight is that this failure is not a bug but a feature: it reflects the genuine asymmetry of proof-theoretic strength, where combining two theories is not commutative at the ordinal level. Why now? The `depthDist_monotone_right` theorem shows that monotonicity holds, suggesting that the right framework is a directed metric space (quasi-metric) rather than a metric space. Formalizing the quasi-metric structure and characterizing when the triangle inequality does hold (e.g., for theories with PTOs below ω^ω, where ordinal arithmetic is commutative up to Cantor normal form) would give a precise boundary.

**Testable conjecture**: depthDist satisfies the triangle inequality if and only if all three PTOs involved are additive principal ordinals (ordinals α such that β + γ < α whenever β, γ < α).

## 4. Theory Strength as a Well-Quasi-Order

The `pto_strictly_increasing_chain` theorem shows that strictly increasing chains of theories have strictly increasing PTOs. The key insight is that by combining this with the well-foundedness of ordinals below a bound, we can show that the space of theories with bounded PTO forms a well-quasi-order under the provability inclusion relation. Why now? This would connect proof-theoretic ordinal analysis to the theory of well-quasi-orders (Kruskal's theorem, graph minor theorem), potentially yielding new independence results.

**Testable conjecture**: The set of BoundedTheories with PTO below ε₀, ordered by provablyWO inclusion, contains no infinite antichain (and is in fact a better-quasi-order).

## 5. Effective Ordinal Assignments via Fast-Growing Hierarchies

Mathlib's `ONote.fastGrowing` and `fastGrowingε₀` provide a computable hierarchy of functions ℕ → ℕ indexed by ordinal notations. The key insight is that the fast-growing hierarchy gives an effective characterization of proof-theoretic ordinals: a theory T has PTO ≥ α if and only if T can prove totality of the fast-growing function f_α. Why now? The `FinitelyDescribedTheory` structure already connects abstract PTOs to concrete `NONote` values; the next step is to connect these to the function-growth characterization, which is the historically primary way proof-theoretic ordinals were computed.

**Testable conjecture**: For every NONote α, there is a BoundedTheory T_α with PTO = α.repr such that T_α proves totality of `ONote.fastGrowing α` but no theory with PTO < α.repr can prove the same.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Pythagorean
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
