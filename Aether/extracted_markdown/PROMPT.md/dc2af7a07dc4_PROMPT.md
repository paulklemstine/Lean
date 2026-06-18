
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

**Title**: The file `ConstructiveFoundations.lean` establishes a self-contained HoTT
**Domain**: Applications
**Mathematical framing**: # Future Directions: Constructive Foundations from Homotopy Type Theory

The file `ConstructiveFoundations.lean` establishes a self-contained HoTT
fragment with four load-bearing results: the coincidence of the two notions of
equivalence (`equiv_iff_contr_fibers`), the *full biconditional* Fundamental
Theorem of Identity Types (`fundamental_theorem_id`), the equivalence-induction
principle that the univalence hypothesis unlocks (`equivalence_induction`), and
a genuine higher inductive type — propositional truncation — with its recursion
principle (`PTrunc`, `PTrunc.rec`, `PTrunc.rec_unique`). The following
directions extend this frontier; each is testable in Lean and falsifiable.

## 1. A computation rule for equivalence induction

`equivalence_induction` currently gives only the *eliminator*: a proof of
`P A (refl A)` yields `P B e` for all `B, e`. The natural next theorem is the
**β/computation rule**: when the eliminator is applied to the reflexivity
equivalence, it returns the base case *propositionally*, and — under a
strengthened coherent `Univalence` carrying `idToEquiv (toId (refl A)) = refl A`
as a `leftInv`-style law — even *definitionally*. One should also prove the
**2-out-of-3** and **2-out-of-6** closure laws for `≃ₕ` directly from
`equiv_iff_contr_fibers`.

The key insight is that contractibility of fibers (`qequiv_contr_fiber`) makes
"being an equivalence" a *proposition*, so the 2-out-of-3 law reduces to a
contractibility-juggling argument that never needs to inspect the chosen
inverses. Why now? With both faces of equivalence already proved equal in this
file, the property-level reasoning that 2-out-of-3 requires is finally available
without re-deriving inverses by hand.

## 2. The n-truncation hierarchy

`PTrunc` is the `(-1)`-truncation. Define the `0`-truncation (set truncation) as
the quotient by the "mere-equality" relation, and conjecture its universal
property: maps into any h-set factor uniquely through it. More ambitiously,
build the general `n`-truncation by a hub-and-spoke quotient and prove the
recursion principle into `n`-types.

The key insight is that each truncation level is characterized by a *lifting
property against the next sphere inclusion*, and `PTrunc.rec_unique` is exactly
the `n = -1` instance of that uniform statement — so the hierarchy is obtained by
replaying one proof schema with the relation parameter varied. Why now? The
quotient-as-HIT pattern is already validated here for `n = -1`; promoting the
relation from `fun _ _ => True` to `mere-equality` is a small, local change that
immediately tests whether the schema generalizes.

## 3. The Structure Identity Principle (cross-domain bridge to `Algebra`)

Using the `Univalence` hypothesis, conjecture and prove a **Structure Identity
Principle**: for a one-sorted algebraic signature (e.g. monoids), isomorphic
structures are *equal*, hence every property is transported across isomorphism by
`equivalence_induction`. This connects the present `Applications/HoTT` work
directly to the catalog's `Algebra` developments.

The key insight is that an isomorphism of structures is precisely an equivalence
of carriers that commutes with the operations, and `equivalence_induction` lets
us reduce "prove `P` of an isomorphic structure" to "prove `P` of the identity
isomorphism" — collapsing transport-of-structure to a single base case. Why now?
`equivalence_induction` is the exact tool the SIP needs, and it is proved and
axiom-clean in this file, so the only remaining work is the (purely
bookkeeping) commutation-with-operations layer.

## 4. Voevodsky's theorem: univalence implies function extensionality

In Lean, `funext` is ambient, which obscures the deep HoTT fact that it is a
*consequence* of univalence. Conjecture: working with a synthetic universe `𝒰`
equipped only with a `Univalence`-style structure (and *no* ambient `funext`),
one can derive function extensionality for maps into `𝒰`. Formalize the
weak-equivalence / naive-non-dependent-funext chain abstractly.

The key insight is that the map `(A → Σ_{b} (b = ·))  →  (A → B)` is a
fiberwise equivalence over the contractible based-path space, so `funext` falls
out of `fundamental_theorem_id` applied to a path space of function types. Why
now? The biconditional Fundamental Theorem proved here is the precise engine
Voevodsky's argument uses; the one-directional catalog version was insufficient,
so this derivation only becomes reachable with `fundamental_theorem_id`.

## 5. Encode–decode for concrete identity types (bridge to `Combinatorics`)

Apply `fundamental_theorem_id` as a *computation device*: pick a concrete family
`C` (the coproduct `Bool`, the natural numbers, a finite type) and exhibit a
contractible pointed total space to *read off* the identity type of that type.
Conjecture closed-form codes for `a = b` in coproducts and in `Fin n`, with the
counting consequences cross-listed to the catalog's combinatorial results.

The key insight is that the encode–decode method is not merely descriptive: the
forward direction of `fundamental_theorem_id` *manufactures* the equivalence
`(a = x) ≃ C x` from a single contractibility witness, so designing the family
`C` is the entire creative step and the equivalence is then free. Why now? The
forward implication — the half that does the manufacturing — was missing from the
catalog and is supplied here, so encode–decode becomes a turnkey method rather
than a bespoke construction per type.

**Concept description**: # Future Directions: Constructive Foundations from Homotopy Type Theory

The file `ConstructiveFoundations.lean` establishes a self-contained HoTT
fragment with four load-bearing results: the coincidence of the two notions of
equivalence (`equiv_iff_contr_fibers`), the *full biconditional* Fundamental
Theorem of Identity Types (`fundamental_theorem_id`), the equivalence-induction
principle that the univalence hypothesis unlocks (`equivalence_induction`), and
a genuine higher inductive type — propositional truncation — with its recursion
principle (`PTrunc`, `PTrunc.rec`, `PTrunc.rec_unique`). The following
directions extend this frontier; each is testable in Lean and falsifiable.

## 1. A computation rule for equivalence induction

`equivalence_induction` currently gives only the *eliminator*: a proof of
`P A (refl A)` yields `P B e` for all `B, e`. The natural next theorem is the
**β/computation rule**: when the eliminator is applied to the reflexivity
equivalence, it returns the base case *propositionally*, and — under a
strengthened coherent `Univalence` carrying `idToEquiv (toId (refl A)) = refl A`
as a `leftInv`-style law — even *definitionally*. One should also prove the
**2-out-of-3** and **2-out-of-6** closure laws for `≃ₕ` directly from
`equiv_iff_contr_fibers`.

The key insight is that contractibility of fibers (`qequiv_contr_fiber`) makes
"being an equivalence" a *proposition*, so the 2-out-of-3 law reduces to a
contractibility-juggling argument that never needs to inspect the chosen
inverses. Why now? With both faces of equivalence already proved equal in this
file, the property-level reasoning that 2-out-of-3 requires is finally available
without re-deriving inverses by hand.

## 2. The n-truncation hierarchy

`PTrunc` is the `(-1)`-truncation. Define the `0`-truncation (set truncation) as
the quotient by the "mere-equality" relation, and conjecture its universal
property: maps into any h-set factor uniquely through it. More ambitiously,
build the general `n`-truncation by a hub-and-spoke quotient and prove the
recursion principle into `n`-types.

The key insight is that each truncation level is characterized by a *lifting
property against the next sphere inclusion*, and `PTrunc.rec_unique` is exactly
the `n = -1` instance of that uniform statement — so the hierarchy is obtained by
replaying one proof schema with the relation parameter varied. Why now? The
quotient-as-HIT pattern is already validated here for `n = -1`; promoting the
relation from `fun _ _ => True` to `mere-equality` is a small, local change that
immediately tests whether the schema generalizes.

## 3. The Structure Identity Principle (cross-domain bridge to `Algebra`)

Using the `Univalence` hypothesis, conjecture and prove a **Structure Identity
Principle**: for a one-sorted algebraic signature (e.g. monoids), isomorphic
structures are *equal*, hence every property is transported across isomorphism by
`equivalence_induction`. This connects the present `Applications/HoTT` work
directly to the catalog's `Algebra` developments.

The key insight is that an isomorphism of structures is precisely an equivalence
of carriers that commutes with the operations, and `equivalence_induction` lets
us reduce "prove `P` of an isomorphic structure" to "prove `P` of the identity
isomorphism" — collapsing transport-of-structure to a single base case. Why now?
`equivalence_induction` is the exact tool the SIP needs, and it is proved and
axiom-clean in this file, so the only remaining work is the (purely
bookkeeping) commutation-with-operations layer.

## 4. Voevodsky's theorem: univalence implies function extensionality

In Lean, `funext` is ambient, which obscures the deep HoTT fact that it is a
*consequence* of univalence. Conjecture: working with a synthetic universe `𝒰`
equipped only with a `Univalence`-style structure (and *no* ambient `funext`),
one can derive function extensionality for maps into `𝒰`. Formalize the
weak-equivalence / naive-non-dependent-funext chain abstractly.

The key insight is that the map `(A → Σ_{b} (b = ·))  →  (A → B)` is a
fiberwise equivalence over the contractible based-path space, so `funext` falls
out of `fundamental_theorem_id` applied to a path space of function types. Why
now? The biconditional Fundamental Theorem proved here is the precise engine
Voevodsky's argument uses; the one-directional catalog version was insufficient,
so this derivation only becomes reachable with `fundamental_theorem_id`.

## 5. Encode–decode for concrete identity types (bridge to `Combinatorics`)

Apply `fundamental_theorem_id` as a *computation device*: pick a concrete family
`C` (the coproduct `Bool`, the natural numbers, a finite type) and exhibit a
contractible pointed total space to *read off* the identity type of that type.
Conjecture closed-form codes for `a = b` in coproducts and in `Fin n`, with the
counting consequences cross-listed to the catalog's combinatorial results.

The key insight is that the encode–decode method is not merely descriptive: the
forward direction of `fundamental_theorem_id` *manufactures* the equivalence
`(a = x) ≃ C x` from a single contractibility witness, so designing the family
`C` is the entire creative step and the equivalence is then free. Why now? The
forward implication — the half that does the manufacturing — was missing from the
catalog and is supplied here, so encode–decode becomes a turnkey method rather
than a bespoke construction per type.

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
