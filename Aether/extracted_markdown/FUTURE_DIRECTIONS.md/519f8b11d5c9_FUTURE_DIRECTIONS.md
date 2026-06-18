# Future Directions — Dream Logic / Paraconsistent Reasoning

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
