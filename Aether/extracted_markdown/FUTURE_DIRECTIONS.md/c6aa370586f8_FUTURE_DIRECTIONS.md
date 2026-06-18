# Future Directions — Dream Logic / Paraconsistent Reasoning

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
