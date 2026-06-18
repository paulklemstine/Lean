
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

**Title**: **order-theoretic core of Gödel–Löb provability logic GL**
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Provability Logic as a Fixed-Point Theory

## Synthesis of this cycle

This cycle built the **order-theoretic core of Gödel–Löb provability logic GL** as a
self-contained, axiom-clean Lean development across two files.

* `Catalog/Logic/LobFixedPoint.lean` introduces the typeclass `GLOperator` — a
  Heyting algebra with a provability operator `□` satisfying only `□⊤ = ⊤`,
  `□(a ⊓ b) = □a ⊓ □b`, and **Löb's axiom** `□(□a ⇨ a) ≤ □a`. From these three
  equations *alone* we derive the whole skeleton of GL:
  - `box_mono` — monotonicity is a *theorem*, squeezed out of meet-preservation;
  - `loeb_fixed_point` — the **de Jongh–Sambin fixed point** `□(□a ⇨ a) = □a`;
  - `loeb_rule` — **Löb's theorem**, `□a ≤ a → a = ⊤` ("no nontrivial reflexive
    points");
  - `box_transitive` — **modal axiom 4** `□a ≤ □□a` is *derived* (Sambin's diagonal
    `a ⊓ □a`), not assumed;
  - `godel_second` / `consistency_unprovable` — **Gödel's Second Incompleteness
    Theorem** as the `a = ⊥` instance of the fixed point.

* `Catalog/Logic/LobNatModel.lean` realises the typeclass in the concrete
  converse-well-founded frame `(ℕ, >)`: `natBox S = {n | ∀ m < n, m ∈ S}`. Here we
  go beyond mere existence and *compute*:
  - `natBox_loeb` + the `GLOperator (Set ℕ)` instance `NatGL`;
  - `natGL_consistent` — the model is consistent (`□⊥ = {0} ≠ ⊤`);
  - `natBox_iterate_eq_Iio` — **the provability-rank computation**
    `□^k⊥ = Set.Iio k`: frame depth and iteration index coincide;
  - `consistency_strength_strictMono` — the consistency strengths `k ↦ □^k⊥` form a
    **strictly increasing** chain that never reaches `⊤`;
  - `godel_hierarchy` — **graded Gödel II**: every nontrivial `k`-fold consistency
    statement `□^{k+1}⊥ ⇨ ⊥` is unprovable, an explicit unprovability spectrum.

The development is cross-linked with the existing catalog: `GLOperator`'s box is the
algebraic shadow of `GLFrame.boxSet` (`Catalog/Logic/GLKripke.lean`), and the rank
computation makes the "time-stamped" intuition of `Catalog/Logic/TemporalGL.lean`
(`godel_second_at_time`) quantitative.

## Results summary

| Theorem | File | Content |
|---|---|---|
| `GLOperator.loeb_fixed_point` | LobFixedPoint | `□(□a ⇨ a) = □a` |
| `GLOperator.loeb_rule` | LobFixedPoint | `□a ≤ a → a = ⊤` |
| `GLOperator.box_transitive` | LobFixedPoint | axiom 4 derived from Löb |
| `GLOperator.godel_second` | LobFixedPoint | Gödel II at `⊥` |
| `natBox_iterate_eq_Iio` | LobNatModel | `□^k⊥ = Iio k` |
| `consistency_strength_strictMono` | LobNatModel | strictly increasing consistency chain |
| `godel_hierarchy` | LobNatModel | graded Gödel II / unprovability spectrum |

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

---

## Direction 1 — Uniqueness of modal fixed points (de Jongh–Sambin in algebra)

**Conjecture.** In any `GLOperator`, the box-guarded operator `x ↦ □(x ⇨ a)` has a
*unique* fixed point, and it is `□a`. More generally, any operator `F(x)` in which
every occurrence of `x` lies under a `□` admits a unique fixed point expressible
without `x`. Formally: `□(x ⇨ a) = x → x = □a`, and the minimal-instance uniqueness
should be provable directly from `loeb_fixed_point` and `loeb_rule`.

*The key insight is* that Löb's axiom is exactly the contraction condition that turns
`x ↦ □(x ⇨ a)` into an attracting map in the well-founded order: `loeb_rule` already
forbids nontrivial reflexive points, so two fixed points must collapse to one. We
proved *existence* (`loeb_fixed_point`); uniqueness is the missing antisymmetry step,
and it should reduce to applying `loeb_rule` to the bi-implication of two solutions.

*Why now?* The fixed point itself is already formalised (`loeb_fixed_point`), and
`box_mono` plus `loeb_rule` give precisely the monotonicity-and-rigidity pair a
uniqueness proof needs. The catalog's `BanachFixedPointBridge` makes the
"contraction ⇒ unique fixed point" analogy literal: transporting the well-founded
descent of `natBox` into that uniform-space statement is a concrete next file.

## Direction 2 — Completeness against finite well-founded models

**Conjecture.** An inequality `s ≤ t` between `□`-terms holds in *every* `GLOperator`
iff it holds in every `NatGL`-style model cut down to a finite initial segment
`Set (Fin n)` with the `>`-box. Equivalently, the finite converse-well-founded frames
are complete for the equational theory of `GLOperator`.

*The key insight is* that `box_transitive` shows every `GLOperator` is internally K4,
so the canonical-model construction collapses onto finite well-founded quotients —
exactly the frames our `natBox` instance exemplifies. Soundness is immediate from the
instance; the hard half is a filtration argument.

*Why now?* Both halves of the bridge are in place: the abstract algebra
(`GLOperator`) and a working concrete model (`NatGL`, `natBox_iterate_eq_Iio`). The
remaining step is to quotient an arbitrary algebra by a finite set of subformulas and
embed the quotient into a finite `natBox`-style frame.

## Direction 3 — The Magari functor as a monad

**Conjecture.** The assignment sending a Heyting algebra to its free `GLOperator` is a
monad on the category of Heyting algebras, whose Eilenberg–Moore algebras are exactly
the `GLOperator` structures; GL is the internal propositional logic of that
Eilenberg–Moore category.

*The key insight is* that `box_top` and `box_inf` make `□` a finite-meet-preserving
endofunctor on the algebra-viewed-as-thin-category, and Löb's axiom is a dinatural
"diagonal" condition — so the package assembles into a (co)monad rather than a bare
operator. `box_transitive` is then the comultiplication law in disguise.

*Why now?* Mathlib supports monads and Eilenberg–Moore categories directly, and
`GLOperator` is phrased so the forgetful functor and its laws can be read off without
redefinition. The free construction on the one-generator Boolean algebra would be the
Lindenbaum algebra of GL — a concrete, testable target.

## Direction 4 — Ordinal provability rank beyond `ω`

**Conjecture.** The rank computation `□^k⊥ = Iio k` extends transfinitely: defining
`□^α⊥` for ordinals `α` by `□^{α}⊥ = ⋃_{β<α} □(□^β⊥)` in a complete `GLOperator`, the
canonical model on `Set Ordinal` (with the `>`-box) satisfies `□^α⊥ = Iio α`, giving a
proper class of strictly increasing unprovable consistency strengths indexed by the
ordinals.

*The key insight is* that `natBox_iterate_eq_Iio` already identifies provability rank
with the identity on `ℕ`; the only obstruction to climbing past `ω` is taking suprema,
which a *complete* Heyting algebra supplies. `consistency_strength_strictMono` is the
`< ω` fragment, and ordinal well-foundedness is exactly the converse-well-foundedness
Löb's axiom encodes.

*Why now?* The finite hierarchy is fully proved and the limit step is a single
`iSup`/`Set.Iio` computation on `Ordinal`. Mathlib's `Ordinal` library has the
well-founded recursion and `Iio` lemmas needed, so this is a clean continuation
rather than new foundations.

## Direction 5 — Provability box as a well-founded nucleus (closure/interior duality)

**Conjecture.** The de Morgan dual `◇a := (□aᶜ)ᶜ` of a `GLOperator` is a *well-founded
co-closure* — deflationary, join-preserving, idempotent on its image — and the fixed
points of `□` form a frame on which `◇` acts as the nucleus of a sublocale. In `NatGL`
this is the locale of upward-closed (here: downward-determined) subsets of `(ℕ, >)`.

*The key insight is* that `box_transitive` gives `□a ≤ □□a` (inflationary on theorems)
while `loeb_rule` forbids reflexive points (strictly contracting off them): precisely
the signature of a *well-founded* nucleus, a structure with no analogue among ordinary
topological closure operators. `box_inf` supplies the finite-meet preservation a
nucleus requires.

*Why now?* The catalog already develops closure operators and locale-style dualities;
recasting `□` in that language is cross-domain unification rather than new groundwork,
and `NatGL` (with `natBox_iterate_eq_Iio`) supplies a concrete, computable locale to
test every nucleus law against.

**Concept description**: # Future Directions: Provability Logic as a Fixed-Point Theory

## Synthesis of this cycle

This cycle built the **order-theoretic core of Gödel–Löb provability logic GL** as a
self-contained, axiom-clean Lean development across two files.

* `Catalog/Logic/LobFixedPoint.lean` introduces the typeclass `GLOperator` — a
  Heyting algebra with a provability operator `□` satisfying only `□⊤ = ⊤`,
  `□(a ⊓ b) = □a ⊓ □b`, and **Löb's axiom** `□(□a ⇨ a) ≤ □a`. From these three
  equations *alone* we derive the whole skeleton of GL:
  - `box_mono` — monotonicity is a *theorem*, squeezed out of meet-preservation;
  - `loeb_fixed_point` — the **de Jongh–Sambin fixed point** `□(□a ⇨ a) = □a`;
  - `loeb_rule` — **Löb's theorem**, `□a ≤ a → a = ⊤` ("no nontrivial reflexive
    points");
  - `box_transitive` — **modal axiom 4** `□a ≤ □□a` is *derived* (Sambin's diagonal
    `a ⊓ □a`), not assumed;
  - `godel_second` / `consistency_unprovable` — **Gödel's Second Incompleteness
    Theorem** as the `a = ⊥` instance of the fixed point.

* `Catalog/Logic/LobNatModel.lean` realises the typeclass in the concrete
  converse-well-founded frame `(ℕ, >)`: `natBox S = {n | ∀ m < n, m ∈ S}`. Here we
  go beyond mere existence and *compute*:
  - `natBox_loeb` + the `GLOperator (Set ℕ)` instance `NatGL`;
  - `natGL_consistent` — the model is consistent (`□⊥ = {0} ≠ ⊤`);
  - `natBox_iterate_eq_Iio` — **the provability-rank computation**
    `□^k⊥ = Set.Iio k`: frame depth and iteration index coincide;
  - `consistency_strength_strictMono` — the consistency strengths `k ↦ □^k⊥` form a
    **strictly increasing** chain that never reaches `⊤`;
  - `godel_hierarchy` — **graded Gödel II**: every nontrivial `k`-fold consistency
    statement `□^{k+1}⊥ ⇨ ⊥` is unprovable, an explicit unprovability spectrum.

The development is cross-linked with the existing catalog: `GLOperator`'s box is the
algebraic shadow of `GLFrame.boxSet` (`Catalog/Logic/GLKripke.lean`), and the rank
computation makes the "time-stamped" intuition of `Catalog/Logic/TemporalGL.lean`
(`godel_second_at_time`) quantitative.

## Results summary

| Theorem | File | Content |
|---|---|---|
| `GLOperator.loeb_fixed_point` | LobFixedPoint | `□(□a ⇨ a) = □a` |
| `GLOperator.loeb_rule` | LobFixedPoint | `□a ≤ a → a = ⊤` |
| `GLOperator.box_transitive` | LobFixedPoint | axiom 4 derived from Löb |
| `GLOperator.godel_second` | LobFixedPoint | Gödel II at `⊥` |
| `natBox_iterate_eq_Iio` | LobNatModel | `□^k⊥ = Iio k` |
| `consistency_strength_strictMono` | LobNatModel | strictly increasing consistency chain |
| `godel_hierarchy` | LobNatModel | graded Gödel II / unprovability spectrum |

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

---

## Direction 1 — Uniqueness of modal fixed points (de Jongh–Sambin in algebra)

**Conjecture.** In any `GLOperator`, the box-guarded operator `x ↦ □(x ⇨ a)` has a
*unique* fixed point, and it is `□a`. More generally, any operator `F(x)` in which
every occurrence of `x` lies under a `□` admits a unique fixed point expressible
without `x`. Formally: `□(x ⇨ a) = x → x = □a`, and the minimal-instance uniqueness
should be provable directly from `loeb_fixed_point` and `loeb_rule`.

*The key insight is* that Löb's axiom is exactly the contraction condition that turns
`x ↦ □(x ⇨ a)` into an attracting map in the well-founded order: `loeb_rule` already
forbids nontrivial reflexive points, so two fixed points must collapse to one. We
proved *existence* (`loeb_fixed_point`); uniqueness is the missing antisymmetry step,
and it should reduce to applying `loeb_rule` to the bi-implication of two solutions.

*Why now?* The fixed point itself is already formalised (`loeb_fixed_point`), and
`box_mono` plus `loeb_rule` give precisely the monotonicity-and-rigidity pair a
uniqueness proof needs. The catalog's `BanachFixedPointBridge` makes the
"contraction ⇒ unique fixed point" analogy literal: transporting the well-founded
descent of `natBox` into that uniform-space statement is a concrete next file.

## Direction 2 — Completeness against finite well-founded models

**Conjecture.** An inequality `s ≤ t` between `□`-terms holds in *every* `GLOperator`
iff it holds in every `NatGL`-style model cut down to a finite initial segment
`Set (Fin n)` with the `>`-box. Equivalently, the finite converse-well-founded frames
are complete for the equational theory of `GLOperator`.

*The key insight is* that `box_transitive` shows every `GLOperator` is internally K4,
so the canonical-model construction collapses onto finite well-founded quotients —
exactly the frames our `natBox` instance exemplifies. Soundness is immediate from the
instance; the hard half is a filtration argument.

*Why now?* Both halves of the bridge are in place: the abstract algebra
(`GLOperator`) and a working concrete model (`NatGL`, `natBox_iterate_eq_Iio`). The
remaining step is to quotient an arbitrary algebra by a finite set of subformulas and
embed the quotient into a finite `natBox`-style frame.

## Direction 3 — The Magari functor as a monad

**Conjecture.** The assignment sending a Heyting algebra to its free `GLOperator` is a
monad on the category of Heyting algebras, whose Eilenberg–Moore algebras are exactly
the `GLOperator` structures; GL is the internal propositional logic of that
Eilenberg–Moore category.

*The key insight is* that `box_top` and `box_inf` make `□` a finite-meet-preserving
endofunctor on the algebra-viewed-as-thin-category, and Löb's axiom is a dinatural
"diagonal" condition — so the package assembles into a (co)monad rather than a bare
operator. `box_transitive` is then the comultiplication law in disguise.

*Why now?* Mathlib supports monads and Eilenberg–Moore categories directly, and
`GLOperator` is phrased so the forgetful functor and its laws can be read off without
redefinition. The free construction on the one-generator Boolean algebra would be the
Lindenbaum algebra of GL — a concrete, testable target.

## Direction 4 — Ordinal provability rank beyond `ω`

**Conjecture.** The rank computation `□^k⊥ = Iio k` extends transfinitely: defining
`□^α⊥` for ordinals `α` by `□^{α}⊥ = ⋃_{β<α} □(□^β⊥)` in a complete `GLOperator`, the
canonical model on `Set Ordinal` (with the `>`-box) satisfies `□^α⊥ = Iio α`, giving a
proper class of strictly increasing unprovable consistency strengths indexed by the
ordinals.

*The key insight is* that `natBox_iterate_eq_Iio` already identifies provability rank
with the identity on `ℕ`; the only obstruction to climbing past `ω` is taking suprema,
which a *complete* Heyting algebra supplies. `consistency_strength_strictMono` is the
`< ω` fragment, and ordinal well-foundedness is exactly the converse-well-foundedness
Löb's axiom encodes.

*Why now?* The finite hierarchy is fully proved and the limit step is a single
`iSup`/`Set.Iio` computation on `Ordinal`. Mathlib's `Ordinal` library has the
well-founded recursion and `Iio` lemmas needed, so this is a clean continuation
rather than new foundations.

## Direction 5 — Provability box as a well-founded nucleus (closure/interior duality)

**Conjecture.** The de Morgan dual `◇a := (□aᶜ)ᶜ` of a `GLOperator` is a *well-founded
co-closure* — deflationary, join-preserving, idempotent on its image — and the fixed
points of `□` form a frame on which `◇` acts as the nucleus of a sublocale. In `NatGL`
this is the locale of upward-closed (here: downward-determined) subsets of `(ℕ, >)`.

*The key insight is* that `box_transitive` gives `□a ≤ □□a` (inflationary on theorems)
while `loeb_rule` forbids reflexive points (strictly contracting off them): precisely
the signature of a *well-founded* nucleus, a structure with no analogue among ordinary
topological closure operators. `box_inf` supplies the finite-meet preservation a
nucleus requires.

*Why now?* The catalog already develops closure operators and locale-style dualities;
recasting `□` in that language is cross-domain unification rather than new groundwork,
and `NatGL` (with `natBox_iterate_eq_Iio`) supplies a concrete, computable locale to
test every nucleus law against.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
