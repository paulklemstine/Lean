
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

**Title**: The file `Paraconsistent.lean` builds a fully verified (axioms: `propext`, `Clas
**Domain**: Tropical
**Mathematical framing**: # Future Directions — Dream Logic / Paraconsistent Reasoning

The file `Paraconsistent.lean` builds a fully verified (axioms: `propext`, `Classical.choice`,
`Quot.sound` only) semantics for Priest's three-valued **Logic of Paradox** (`LP`) and its
minimally-inconsistent strengthening `LPm`. We proved that contradictions coexist
(`contradiction_satisfiable`), do not explode (`explosion_fails`), that excluded middle and
non-contradiction survive as *laws* while explosion as an *inference* dies
(`lem_valid`, `lnc_valid`), that material modus ponens fails (`mp_fails`), that glut-free dreams
collapse to classical reasoning (`classical_no_contradiction`), and — the centerpiece — that the
minimal-glut consequence relation is genuinely **non-monotone**: a conclusion `q` derivable from
`{p, p→q}` is *retracted* when the contradictory belief `¬p` is added (`retraction_nonmonotone`).

These results connect to several catalog domains: the `Logic/` library already hosts
`ProofSystemCollapse`, `ParadoxInteraction`, and `Completeness`, and the present work supplies the
missing *semantic* counterpart — a model theory in which paradox is a first-class citizen rather
than a pathology. Below are concrete, falsifiable conjectures the next cycle can attack, each
phrased so that a single Lean theorem (or its disproof) settles it.

## 1. Soundness and completeness of an `LP` Hilbert calculus

**Conjecture.** There is a finite axiom schema + the single rule "adjunction" whose derivability
relation `⊢` coincides exactly with the semantic `entails` defined in `Paraconsistent.lean`:
`Γ ⊢ A ↔ entails Γ A`, at least for finite `Γ`.

The key insight is that because `lem_valid` and `lnc_valid` already show `LP` retains every
classical *tautology*, the only thing a proof system must *block* is the explosion rule
`A, ¬A ⊢ B`; therefore a calculus obtained from a classical Hilbert system by **deleting
ex-falso and weakening disjunctive syllogism** should be both sound and complete, and the proof
of completeness can reuse the three-valued canonical-model construction rather than a Boolean one.

Why now? The semantic side is already formalized and machine-checked here, so a completeness
theorem is no longer a moving target — the right-hand side of the biconditional is pinned down,
and Mathlib's existing Lindenbaum/maximal-consistent-set machinery for classical logic can be
adapted value-by-value.

## 2. Decidability and a verified decision procedure for `entailsMin`

**Conjecture.** For finite premise sets over finitely many atoms, `entailsMin Γ A` is decidable,
and there is a `Decidable` instance whose correctness is proved against the `minimal`/`gluts`
definitions in this file.

The key insight is that `eval v A` depends only on the finitely many atoms occurring in `Γ ∪ {A}`,
so minimal models can be searched over the finite cube `{ff,bb,tt}^k`, and minimality reduces to a
*finite* `⊂`-comparison of glut sets rather than a quantifier over all of `ℕ → LP`.

Why now? `retraction_nonmonotone` already exhibits the subtle interaction between minimality and
`Set ⊂` by hand; turning that ad-hoc argument into a reusable `Finset`-based decision procedure is
the natural consolidation, and would let `decide`/`native_decide` certify non-monotonic inferences
automatically.

## 3. A monotonicity *boundary* theorem: when does `LPm` agree with `LP`?

**Conjecture.** `entailsMin Γ A` and `entails Γ A` coincide **exactly** on the consistent
fragment: if `Γ` has at least one glut-free model then `entailsMin Γ A ↔ entails Γ A`, and the two
relations differ only when every model of `Γ` is forced to contain an impossible object.

The key insight is that `retraction_nonmonotone` already pinpoints the mechanism — minimality
becomes informative precisely when consistency fails (the `¬p` premise forces `p = bb`); making
this an iff turns a single example into a structural dividing line between monotone and
non-monotone reasoning.

Why now? We have both relations defined side-by-side in one verified file with a worked example of
their disagreement, so the general criterion is a direct generalization rather than a fresh theory.

## 4. Belnap's four-valued `FOUR` and information-ordering retraction

**Conjecture.** Extending `LP` with a fourth value `nn` ("neither true nor false") to obtain the
bilattice `FOUR = {ff, nn, bb, tt}` yields a logic in which *two independent* orders coexist (a
truth order and a knowledge/information order), and belief retraction along the information order
is dual to the glut-minimization used in `LPm`.

The key insight is that our `gluts`-minimization is really minimization along *one* axis of a
hidden bilattice; making the second ("gaps") axis explicit should reveal that monotonicity holds
along the information order even where it fails along the truth order — a clean separation of "more
data" from "more commitment".

Why now? The three-valued core, its evaluation function, and the minimal-model apparatus are
already proved here; adding one constructor to `LP` and one clause to `eval`, `neg`, `conj`, `disj`
reuses essentially all the existing proof scaffolding.

## 5. Cross-domain bridge: paraconsistent valuations as a tropical/min-plus semiring

**Conjecture.** The pair `(LP, conj=min, disj=max)` under the order `ff < bb < tt` is a bounded
distributive lattice, and its `disj`/`conj` operations form a commutative idempotent semiring; the
designated-value filter `{bb, tt}` is precisely a prime-style filter, linking `LP` semantics to the
tropical (max-plus) structures catalogued in the `Tropical/` library.

The key insight is that the truth tables we verified (`conj = min`, `disj = max`) are *literally* a
two-element-spaced tropical semiring, so paraconsistent satisfiability can be recast as solvability
of a min-plus system — and tropical eigenvalue/idempotency theorems from the catalog should
transfer to statements about stable belief states under iterated revision.

Why now? Both the logic side (this file) and the tropical algebra side (the `Tropical/` catalog
domain) are present in the same project; the `min`/`max` identity is the explicit bridge, and the
research mandate to connect ideas across domains makes this the highest-novelty target.

**Concept description**: # Future Directions — Dream Logic / Paraconsistent Reasoning

The file `Paraconsistent.lean` builds a fully verified (axioms: `propext`, `Classical.choice`,
`Quot.sound` only) semantics for Priest's three-valued **Logic of Paradox** (`LP`) and its
minimally-inconsistent strengthening `LPm`. We proved that contradictions coexist
(`contradiction_satisfiable`), do not explode (`explosion_fails`), that excluded middle and
non-contradiction survive as *laws* while explosion as an *inference* dies
(`lem_valid`, `lnc_valid`), that material modus ponens fails (`mp_fails`), that glut-free dreams
collapse to classical reasoning (`classical_no_contradiction`), and — the centerpiece — that the
minimal-glut consequence relation is genuinely **non-monotone**: a conclusion `q` derivable from
`{p, p→q}` is *retracted* when the contradictory belief `¬p` is added (`retraction_nonmonotone`).

These results connect to several catalog domains: the `Logic/` library already hosts
`ProofSystemCollapse`, `ParadoxInteraction`, and `Completeness`, and the present work supplies the
missing *semantic* counterpart — a model theory in which paradox is a first-class citizen rather
than a pathology. Below are concrete, falsifiable conjectures the next cycle can attack, each
phrased so that a single Lean theorem (or its disproof) settles it.

## 1. Soundness and completeness of an `LP` Hilbert calculus

**Conjecture.** There is a finite axiom schema + the single rule "adjunction" whose derivability
relation `⊢` coincides exactly with the semantic `entails` defined in `Paraconsistent.lean`:
`Γ ⊢ A ↔ entails Γ A`, at least for finite `Γ`.

The key insight is that because `lem_valid` and `lnc_valid` already show `LP` retains every
classical *tautology*, the only thing a proof system must *block* is the explosion rule
`A, ¬A ⊢ B`; therefore a calculus obtained from a classical Hilbert system by **deleting
ex-falso and weakening disjunctive syllogism** should be both sound and complete, and the proof
of completeness can reuse the three-valued canonical-model construction rather than a Boolean one.

Why now? The semantic side is already formalized and machine-checked here, so a completeness
theorem is no longer a moving target — the right-hand side of the biconditional is pinned down,
and Mathlib's existing Lindenbaum/maximal-consistent-set machinery for classical logic can be
adapted value-by-value.

## 2. Decidability and a verified decision procedure for `entailsMin`

**Conjecture.** For finite premise sets over finitely many atoms, `entailsMin Γ A` is decidable,
and there is a `Decidable` instance whose correctness is proved against the `minimal`/`gluts`
definitions in this file.

The key insight is that `eval v A` depends only on the finitely many atoms occurring in `Γ ∪ {A}`,
so minimal models can be searched over the finite cube `{ff,bb,tt}^k`, and minimality reduces to a
*finite* `⊂`-comparison of glut sets rather than a quantifier over all of `ℕ → LP`.

Why now? `retraction_nonmonotone` already exhibits the subtle interaction between minimality and
`Set ⊂` by hand; turning that ad-hoc argument into a reusable `Finset`-based decision procedure is
the natural consolidation, and would let `decide`/`native_decide` certify non-monotonic inferences
automatically.

## 3. A monotonicity *boundary* theorem: when does `LPm` agree with `LP`?

**Conjecture.** `entailsMin Γ A` and `entails Γ A` coincide **exactly** on the consistent
fragment: if `Γ` has at least one glut-free model then `entailsMin Γ A ↔ entails Γ A`, and the two
relations differ only when every model of `Γ` is forced to contain an impossible object.

The key insight is that `retraction_nonmonotone` already pinpoints the mechanism — minimality
becomes informative precisely when consistency fails (the `¬p` premise forces `p = bb`); making
this an iff turns a single example into a structural dividing line between monotone and
non-monotone reasoning.

Why now? We have both relations defined side-by-side in one verified file with a worked example of
their disagreement, so the general criterion is a direct generalization rather than a fresh theory.

## 4. Belnap's four-valued `FOUR` and information-ordering retraction

**Conjecture.** Extending `LP` with a fourth value `nn` ("neither true nor false") to obtain the
bilattice `FOUR = {ff, nn, bb, tt}` yields a logic in which *two independent* orders coexist (a
truth order and a knowledge/information order), and belief retraction along the information order
is dual to the glut-minimization used in `LPm`.

The key insight is that our `gluts`-minimization is really minimization along *one* axis of a
hidden bilattice; making the second ("gaps") axis explicit should reveal that monotonicity holds
along the information order even where it fails along the truth order — a clean separation of "more
data" from "more commitment".

Why now? The three-valued core, its evaluation function, and the minimal-model apparatus are
already proved here; adding one constructor to `LP` and one clause to `eval`, `neg`, `conj`, `disj`
reuses essentially all the existing proof scaffolding.

## 5. Cross-domain bridge: paraconsistent valuations as a tropical/min-plus semiring

**Conjecture.** The pair `(LP, conj=min, disj=max)` under the order `ff < bb < tt` is a bounded
distributive lattice, and its `disj`/`conj` operations form a commutative idempotent semiring; the
designated-value filter `{bb, tt}` is precisely a prime-style filter, linking `LP` semantics to the
tropical (max-plus) structures catalogued in the `Tropical/` library.

The key insight is that the truth tables we verified (`conj = min`, `disj = max`) are *literally* a
two-element-spaced tropical semiring, so paraconsistent satisfiability can be recast as solvability
of a min-plus system — and tropical eigenvalue/idempotency theorems from the catalog should
transfer to statements about stable belief states under iterated revision.

Why now? Both the logic side (this file) and the tropical algebra side (the `Tropical/` catalog
domain) are present in the same project; the `min`/`max` identity is the explicit bridge, and the
research mandate to connect ideas across domains makes this the highest-novelty target.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Tropical
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
