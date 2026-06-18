
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

**Title**: The parametric continuity theorem (`parametric_fixedPoint_continuous`) establish
**Domain**: Applications
**Mathematical framing**: # Future Directions: Parametric Fixed-Point Theory

## 1. Lipschitz Parametric Banach Theorem with Explicit Constants

The parametric continuity theorem (`parametric_fixedPoint_continuous`) establishes that the fixed-point map is continuous when the family varies continuously. A stronger result should hold: if the family `t ↦ F(t)` is Lipschitz in a metric parameter space with constant `L` (i.e., `dist(F(s)(x), F(t)(x)) ≤ L · dist(s,t)` uniformly in `x`), then `t ↦ x⋆(t)` is Lipschitz with constant `L/(1-K)`.

The key insight is that the bound `dist(x⋆(s), x⋆(t)) ≤ sup_x dist(F(s)(x), F(t)(x)) / (1-K)` already implicit in our proof gives the Lipschitz constant directly — no additional machinery is needed beyond plugging in the uniform Lipschitz hypothesis on the family.

Why now? The `contraction_fixedPoint_stability` theorem already handles the pointwise case. The upgrade to Lipschitz families is a one-line corollary once the uniform bound is formalized. This would directly connect to the implicit function theorem via the parametric contraction mapping approach.

## 2. Hölder Continuity of Fixed Points for Non-Uniformly Contracting Families

When the contraction factor itself varies with the parameter — `K(t) < 1` for each `t` but `sup_t K(t) = 1` — the fixed-point map may still be continuous but loses Lipschitz regularity. The conjecture is that if `K(t) ≤ 1 - c · dist(t, t₀)^β` for some `β > 0`, then the fixed-point map is Hölder continuous with exponent depending on `β`.

The key insight is that the denominator `1 - K(t)` in the stability bound degenerates as `K(t) → 1`, creating a singularity that Hölder regularity can still control. This bridges our sharp K=1 counterexample with the smooth K<1 theory.

Why now? The sharpness result (`contraction_sharpness`) precisely identifies where the theory breaks down. Understanding the transition region between K<1 (guaranteed fixed points) and K=1 (possible failure) requires exactly this Hölder analysis. Mathlib's `HolderWith` API provides the formalization target.

## 3. Equivariant Fixed Points for Group-Parametrized Families

If a group `G` acts on both the parameter space and the metric space, and the family of contracting maps is equivariant (`F(g·t)(g·x) = g · F(t)(x)`), then the fixed-point map should be equivariant as well (`x⋆(g·t) = g · x⋆(t)`). This would formalize the principle that symmetries of the causal structure are inherited by self-consistent solutions.

The key insight is that uniqueness of fixed points forces equivariance: since `g · x⋆(t)` is a fixed point of `F(g·t)` (by equivariance of the family), it must equal the unique fixed point `x⋆(g·t)`. The proof is a direct application of `fixedPoint_unique`.

Why now? The composition theorem (`ContractingWith.comp`) shows that the algebraic structure of contracting maps is well-behaved. Group equivariance is the natural next algebraic property to formalize, and connects to Mathlib's extensive `MulAction` framework.

## 4. Nadler's Theorem: Set-Valued Contractions

For a set-valued map `F : α → Closeds α` that is contracting under the Hausdorff metric (i.e., `hausdorffDist(F(x), F(y)) ≤ K · dist(x,y)` with `K < 1`), Nadler's theorem guarantees existence of a fixed point `x ∈ F(x)`. This generalizes the Banach theorem to nondeterministic dynamics.

The key insight is that the Banach iteration can be adapted: choose `x₁ ∈ F(x₀)` closest to `x₀`, then `x₂ ∈ F(x₁)` closest to `x₁`, etc. The contraction on the Hausdorff metric ensures this sequence is Cauchy, and the limit is a fixed point. The challenge is formalizing the "choose closest point" step using Mathlib's `EMetric.hausdorffDist`.

Why now? Mathlib has `EMetric.hausdorffDist` and `TopologicalSpace.Closeds`. The gap is connecting the Hausdorff metric contraction to pointwise fixed-point existence. Our parametric framework provides the template for handling the iteration argument.

## 5. Rate-Optimal Iteration for Non-Autonomous Contractions

Given a sequence of contracting maps `f₁, f₂, ...` with possibly different contraction factors `K_n < 1`, the composition `f_n ∘ ... ∘ f₁` converges to a unique "target" point. The conjecture is that the convergence rate is `∏ᵢ Kᵢ`, and when `∑ᵢ (1 - Kᵢ) = ∞`, convergence is guaranteed even though individual factors may approach 1.

The key insight is that `ContractingWith.comp` gives `K₁ · K₂` as the factor for the composition of two contractions. Iterating this, the composition of `n` maps has factor `∏ᵢ₌₁ⁿ Kᵢ`. The divergence condition `∑(1-Kᵢ) = ∞` ensures `∏ Kᵢ → 0`, guaranteeing convergence even in the non-stationary case.

Why now? The composition theorem is now proved, giving the base case. The extension to infinite products connects to Mathlib's `HasProd` API and provides convergence guarantees for adaptive algorithms where the contraction factor changes at each step (e.g., learning rate schedules in optimization).

**Concept description**: # Future Directions: Parametric Fixed-Point Theory

## 1. Lipschitz Parametric Banach Theorem with Explicit Constants

The parametric continuity theorem (`parametric_fixedPoint_continuous`) establishes that the fixed-point map is continuous when the family varies continuously. A stronger result should hold: if the family `t ↦ F(t)` is Lipschitz in a metric parameter space with constant `L` (i.e., `dist(F(s)(x), F(t)(x)) ≤ L · dist(s,t)` uniformly in `x`), then `t ↦ x⋆(t)` is Lipschitz with constant `L/(1-K)`.

The key insight is that the bound `dist(x⋆(s), x⋆(t)) ≤ sup_x dist(F(s)(x), F(t)(x)) / (1-K)` already implicit in our proof gives the Lipschitz constant directly — no additional machinery is needed beyond plugging in the uniform Lipschitz hypothesis on the family.

Why now? The `contraction_fixedPoint_stability` theorem already handles the pointwise case. The upgrade to Lipschitz families is a one-line corollary once the uniform bound is formalized. This would directly connect to the implicit function theorem via the parametric contraction mapping approach.

## 2. Hölder Continuity of Fixed Points for Non-Uniformly Contracting Families

When the contraction factor itself varies with the parameter — `K(t) < 1` for each `t` but `sup_t K(t) = 1` — the fixed-point map may still be continuous but loses Lipschitz regularity. The conjecture is that if `K(t) ≤ 1 - c · dist(t, t₀)^β` for some `β > 0`, then the fixed-point map is Hölder continuous with exponent depending on `β`.

The key insight is that the denominator `1 - K(t)` in the stability bound degenerates as `K(t) → 1`, creating a singularity that Hölder regularity can still control. This bridges our sharp K=1 counterexample with the smooth K<1 theory.

Why now? The sharpness result (`contraction_sharpness`) precisely identifies where the theory breaks down. Understanding the transition region between K<1 (guaranteed fixed points) and K=1 (possible failure) requires exactly this Hölder analysis. Mathlib's `HolderWith` API provides the formalization target.

## 3. Equivariant Fixed Points for Group-Parametrized Families

If a group `G` acts on both the parameter space and the metric space, and the family of contracting maps is equivariant (`F(g·t)(g·x) = g · F(t)(x)`), then the fixed-point map should be equivariant as well (`x⋆(g·t) = g · x⋆(t)`). This would formalize the principle that symmetries of the causal structure are inherited by self-consistent solutions.

The key insight is that uniqueness of fixed points forces equivariance: since `g · x⋆(t)` is a fixed point of `F(g·t)` (by equivariance of the family), it must equal the unique fixed point `x⋆(g·t)`. The proof is a direct application of `fixedPoint_unique`.

Why now? The composition theorem (`ContractingWith.comp`) shows that the algebraic structure of contracting maps is well-behaved. Group equivariance is the natural next algebraic property to formalize, and connects to Mathlib's extensive `MulAction` framework.

## 4. Nadler's Theorem: Set-Valued Contractions

For a set-valued map `F : α → Closeds α` that is contracting under the Hausdorff metric (i.e., `hausdorffDist(F(x), F(y)) ≤ K · dist(x,y)` with `K < 1`), Nadler's theorem guarantees existence of a fixed point `x ∈ F(x)`. This generalizes the Banach theorem to nondeterministic dynamics.

The key insight is that the Banach iteration can be adapted: choose `x₁ ∈ F(x₀)` closest to `x₀`, then `x₂ ∈ F(x₁)` closest to `x₁`, etc. The contraction on the Hausdorff metric ensures this sequence is Cauchy, and the limit is a fixed point. The challenge is formalizing the "choose closest point" step using Mathlib's `EMetric.hausdorffDist`.

Why now? Mathlib has `EMetric.hausdorffDist` and `TopologicalSpace.Closeds`. The gap is connecting the Hausdorff metric contraction to pointwise fixed-point existence. Our parametric framework provides the template for handling the iteration argument.

## 5. Rate-Optimal Iteration for Non-Autonomous Contractions

Given a sequence of contracting maps `f₁, f₂, ...` with possibly different contraction factors `K_n < 1`, the composition `f_n ∘ ... ∘ f₁` converges to a unique "target" point. The conjecture is that the convergence rate is `∏ᵢ Kᵢ`, and when `∑ᵢ (1 - Kᵢ) = ∞`, convergence is guaranteed even though individual factors may approach 1.

The key insight is that `ContractingWith.comp` gives `K₁ · K₂` as the factor for the composition of two contractions. Iterating this, the composition of `n` maps has factor `∏ᵢ₌₁ⁿ Kᵢ`. The divergence condition `∑(1-Kᵢ) = ∞` ensures `∏ Kᵢ → 0`, guaranteeing convergence even in the non-stationary case.

Why now? The composition theorem is now proved, giving the base case. The extension to infinite products connects to Mathlib's `HasProd` API and provides convergence guarantees for adaptive algorithms where the contraction factor changes at each step (e.g., learning rate schedules in optimization).

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
