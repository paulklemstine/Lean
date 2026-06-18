
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

**Title**: The file `Logic/Paraconsistent.lean` now contains a fully verified (axioms: `pro
**Domain**: Applications
**Mathematical framing**: # Future Directions — Dream Logic / Paraconsistent Reasoning

The file `Logic/Paraconsistent.lean` now contains a fully verified (axioms: `propext`,
`Classical.choice`, `Quot.sound` only) model theory for Priest's three-valued **Logic of
Paradox** `LP` and its minimally-inconsistent strengthening **`LPm`**. We proved that
contradictions are satisfiable (`contradiction_satisfiable`) and do not explode
(`explosion_fails`), that excluded middle and non-contradiction survive as *laws*
(`lem_valid`, `lnc_valid`) while explosion and material modus ponens die as *inferences*
(`mp_fails`), that glut-free valuations reason classically (`classical_no_contradiction`,
`eval_ne_bb`), and — the centrepiece — that minimal-glut consequence is genuinely
**non-monotone**: `q`, a minimal consequence of `{p, p→q}`, is *retracted* once the
contradictory belief `¬p` is added (`retraction_nonmonotone`). The cross-domain payload
establishes `(LP, disj, conj)` as a commutative *idempotent* semiring (`commSemiring`,
`add_idem`, `mul_idem`) with `disj = max`, `conj = min` on the chain `ff < bb < tt`, and the
designated set `{bb, tt}` as a prime filter for both operations (`desig_mul`, `desig_add`).
This is the explicit bridge into the tropical / min-plus structures of the `Tropical/` catalog
domain. Below are five concrete, falsifiable directions that the next cycle can attack, each
phrased so a single Lean theorem (or its disproof) settles it.

## 1. A sound and complete Hilbert calculus for `entails`

**Conjecture.** There is a finite axiom schema plus the single rule *adjunction* whose
finitary derivability relation `⊢` coincides exactly with the semantic `entails` of the file:
for finite `Γ`, `Γ ⊢ A ↔ entails Γ A`.

The key insight is that `lem_valid` and `lnc_valid` already certify that `LP` keeps *every*
classical tautology, so the only thing a proof system must block is the explosion rule
`A, ¬A ⊢ B`; a calculus obtained from classical Hilbert axioms by deleting ex-falso and
disjunctive syllogism should be both sound and complete, and the completeness half can reuse a
three-valued canonical model built directly on the verified `eval`/`desig` pair rather than a
Boolean one.

Why now? The semantic right-hand side of the biconditional is already pinned down and
machine-checked, so completeness is no longer a moving target — `eval` and `isModel` give an
exact specification a canonical-model construction can be measured against.

## 2. A verified decision procedure for `entailsMin` over finite atom sets

**Conjecture.** For finite premise sets mentioning finitely many atoms, `entailsMin Γ A` is
decidable, and there is a `Decidable` instance proved correct against the
`minimalModel`/`gluts` definitions in the file.

The key insight is that `eval v A` depends only on the finitely many atoms occurring in
`Γ ∪ {A}`, so minimal models can be enumerated over the finite cube `LP^k` (`LP` is already a
`Fintype`), and minimality reduces to a *finite* `⊂`-comparison of glut `Finset`s instead of a
quantifier over all `v : ℕ → LP`.

Why now? `minimalModel_Γ₂_wstar` already carries out the subtle `gluts ⊂ gluts` minimality
argument by hand for one example; turning that ad-hoc reasoning into a reusable
`Finset`-indexed search is the natural consolidation and would let `decide` certify
non-monotone inferences automatically.

## 3. A monotonicity *boundary* theorem: when `entailsMin` equals `entails`

**Conjecture.** `entailsMin Γ A` and `entails Γ A` coincide **exactly** on the consistent
fragment: if `Γ` has at least one glut-free model then `entailsMin Γ A ↔ entails Γ A`, and the
two relations can differ only when every model of `Γ` is forced to carry a glut.

The key insight is that `minimal_Γ₁_glutfree` and `model_Γ₂_forces_bb` already isolate the
mechanism — minimality becomes informative precisely when consistency fails, because a forced
glut (`v 0 = bb`) is exactly what prevents the empty-glut model from existing; promoting this
into an iff converts the single worked example into a structural dividing line between monotone
and non-monotone reasoning.

Why now? Both relations sit side-by-side in one verified file together with a fully proved
example of their disagreement (`retraction_nonmonotone`), so the general criterion is a direct
generalization of lemmas that already exist rather than a fresh theory.

## 4. Belnap's four-valued `FOUR` and information-ordering retraction

**Conjecture.** Adjoining a fourth value `nn` ("neither true nor false") to obtain the
bilattice `FOUR = {ff, nn, bb, tt}` yields a logic carrying *two* independent orders — a truth
order and a knowledge/information order — in which belief retraction along the information
order is dual to the glut-minimization that drives `LPm`; concretely, monotonicity should be
*restored* along the information order even where it fails along the truth order.

The key insight is that the `gluts`-minimization proved here is really minimization along one
axis of a hidden bilattice; making the second ("gaps") axis explicit separates "more data"
from "more commitment", so the non-monotonicity of `retraction_nonmonotone` is revealed as an
artefact of measuring along the wrong order.

Why now? The three-valued core — `LP`, `eval`, `neg`/`conj`/`disj`, and the minimal-model
apparatus — is already proved, and extending it costs one extra constructor plus one clause per
operation, reusing essentially all existing proof scaffolding (`eval_ne_bb` generalizes almost
verbatim).

## 5. Tropical eigenvalues of belief-revision operators

**Conjecture.** Iterated paraconsistent belief revision is governed by the
idempotent-semiring structure proved in `commSemiring`: a revision step is a matrix over the
LP semiring `(disj, conj) = (max, min)`, and its long-run behaviour (stable belief states
under iterated revision) is computed by a max-min eigenvalue / Collatz–Wielandt principle,
transferring the tropical eigenvalue theorems of the `Tropical/` catalog (e.g.
`CollatzWielandt`, `MinPlusAlgebra`) verbatim to LP semantics.

The key insight is that `desig_add` and `desig_mul` show the designated filter is a prime
filter for `(+ , ×) = (max, min)`, so "reaching a stable designated belief" is exactly
solvability of a max-min linear fixed-point system — the same object whose spectral theory the
tropical library already formalizes.

Why now? Both endpoints of the bridge are present and verified in this project: the LP
idempotent semiring is established here (`commSemiring`, `add_idem`, `mul_idem`), and the
tropical eigenvalue machinery already lives in `Tropical/`, so the remaining work is to phrase
revision operators as LP-semiring matrices and invoke the existing spectral results.

**Concept description**: # Future Directions — Dream Logic / Paraconsistent Reasoning

The file `Logic/Paraconsistent.lean` now contains a fully verified (axioms: `propext`,
`Classical.choice`, `Quot.sound` only) model theory for Priest's three-valued **Logic of
Paradox** `LP` and its minimally-inconsistent strengthening **`LPm`**. We proved that
contradictions are satisfiable (`contradiction_satisfiable`) and do not explode
(`explosion_fails`), that excluded middle and non-contradiction survive as *laws*
(`lem_valid`, `lnc_valid`) while explosion and material modus ponens die as *inferences*
(`mp_fails`), that glut-free valuations reason classically (`classical_no_contradiction`,
`eval_ne_bb`), and — the centrepiece — that minimal-glut consequence is genuinely
**non-monotone**: `q`, a minimal consequence of `{p, p→q}`, is *retracted* once the
contradictory belief `¬p` is added (`retraction_nonmonotone`). The cross-domain payload
establishes `(LP, disj, conj)` as a commutative *idempotent* semiring (`commSemiring`,
`add_idem`, `mul_idem`) with `disj = max`, `conj = min` on the chain `ff < bb < tt`, and the
designated set `{bb, tt}` as a prime filter for both operations (`desig_mul`, `desig_add`).
This is the explicit bridge into the tropical / min-plus structures of the `Tropical/` catalog
domain. Below are five concrete, falsifiable directions that the next cycle can attack, each
phrased so a single Lean theorem (or its disproof) settles it.

## 1. A sound and complete Hilbert calculus for `entails`

**Conjecture.** There is a finite axiom schema plus the single rule *adjunction* whose
finitary derivability relation `⊢` coincides exactly with the semantic `entails` of the file:
for finite `Γ`, `Γ ⊢ A ↔ entails Γ A`.

The key insight is that `lem_valid` and `lnc_valid` already certify that `LP` keeps *every*
classical tautology, so the only thing a proof system must block is the explosion rule
`A, ¬A ⊢ B`; a calculus obtained from classical Hilbert axioms by deleting ex-falso and
disjunctive syllogism should be both sound and complete, and the completeness half can reuse a
three-valued canonical model built directly on the verified `eval`/`desig` pair rather than a
Boolean one.

Why now? The semantic right-hand side of the biconditional is already pinned down and
machine-checked, so completeness is no longer a moving target — `eval` and `isModel` give an
exact specification a canonical-model construction can be measured against.

## 2. A verified decision procedure for `entailsMin` over finite atom sets

**Conjecture.** For finite premise sets mentioning finitely many atoms, `entailsMin Γ A` is
decidable, and there is a `Decidable` instance proved correct against the
`minimalModel`/`gluts` definitions in the file.

The key insight is that `eval v A` depends only on the finitely many atoms occurring in
`Γ ∪ {A}`, so minimal models can be enumerated over the finite cube `LP^k` (`LP` is already a
`Fintype`), and minimality reduces to a *finite* `⊂`-comparison of glut `Finset`s instead of a
quantifier over all `v : ℕ → LP`.

Why now? `minimalModel_Γ₂_wstar` already carries out the subtle `gluts ⊂ gluts` minimality
argument by hand for one example; turning that ad-hoc reasoning into a reusable
`Finset`-indexed search is the natural consolidation and would let `decide` certify
non-monotone inferences automatically.

## 3. A monotonicity *boundary* theorem: when `entailsMin` equals `entails`

**Conjecture.** `entailsMin Γ A` and `entails Γ A` coincide **exactly** on the consistent
fragment: if `Γ` has at least one glut-free model then `entailsMin Γ A ↔ entails Γ A`, and the
two relations can differ only when every model of `Γ` is forced to carry a glut.

The key insight is that `minimal_Γ₁_glutfree` and `model_Γ₂_forces_bb` already isolate the
mechanism — minimality becomes informative precisely when consistency fails, because a forced
glut (`v 0 = bb`) is exactly what prevents the empty-glut model from existing; promoting this
into an iff converts the single worked example into a structural dividing line between monotone
and non-monotone reasoning.

Why now? Both relations sit side-by-side in one verified file together with a fully proved
example of their disagreement (`retraction_nonmonotone`), so the general criterion is a direct
generalization of lemmas that already exist rather than a fresh theory.

## 4. Belnap's four-valued `FOUR` and information-ordering retraction

**Conjecture.** Adjoining a fourth value `nn` ("neither true nor false") to obtain the
bilattice `FOUR = {ff, nn, bb, tt}` yields a logic carrying *two* independent orders — a truth
order and a knowledge/information order — in which belief retraction along the information
order is dual to the glut-minimization that drives `LPm`; concretely, monotonicity should be
*restored* along the information order even where it fails along the truth order.

The key insight is that the `gluts`-minimization proved here is really minimization along one
axis of a hidden bilattice; making the second ("gaps") axis explicit separates "more data"
from "more commitment", so the non-monotonicity of `retraction_nonmonotone` is revealed as an
artefact of measuring along the wrong order.

Why now? The three-valued core — `LP`, `eval`, `neg`/`conj`/`disj`, and the minimal-model
apparatus — is already proved, and extending it costs one extra constructor plus one clause per
operation, reusing essentially all existing proof scaffolding (`eval_ne_bb` generalizes almost
verbatim).

## 5. Tropical eigenvalues of belief-revision operators

**Conjecture.** Iterated paraconsistent belief revision is governed by the
idempotent-semiring structure proved in `commSemiring`: a revision step is a matrix over the
LP semiring `(disj, conj) = (max, min)`, and its long-run behaviour (stable belief states
under iterated revision) is computed by a max-min eigenvalue / Collatz–Wielandt principle,
transferring the tropical eigenvalue theorems of the `Tropical/` catalog (e.g.
`CollatzWielandt`, `MinPlusAlgebra`) verbatim to LP semantics.

The key insight is that `desig_add` and `desig_mul` show the designated filter is a prime
filter for `(+ , ×) = (max, min)`, so "reaching a stable designated belief" is exactly
solvability of a max-min linear fixed-point system — the same object whose spectral theory the
tropical library already formalizes.

Why now? Both endpoints of the bridge are present and verified in this project: the LP
idempotent semiring is established here (`commSemiring`, `add_idem`, `mul_idem`), and the
tropical eigenvalue machinery already lives in `Tropical/`, so the remaining work is to phrase
revision operators as LP-semiring matrices and invoke the existing spectral results.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
