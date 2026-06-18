
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: The current framework models theories by their set of provably well-ordered ordi
**Domain**: Cryptography
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
Research domain: Cryptography
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
