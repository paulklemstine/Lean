# Future Directions — Paraconsistent Reasoning: the LPm/LP Boundary and Bilattices

The new file `Catalog/Logic/ParaconsistentMinimalBoundary.lean` extends the verified LP
model theory of `Paraconsistent.lean` and, in doing so, **refutes** Direction 3 of the
previous cycle. That earlier conjecture asserted that minimal consequence `entailsMin` and
ordinary LP consequence `entails` coincide on the consistent fragment. We proved instead:

* `entails_imp_entailsMin` — the inclusion `entails ⇒ entailsMin` holds **unconditionally**
  (minimal models are models), so LPm is always at least as strong as LP.
* `minimalModel_iff_glutfree` — once a glut-free model exists, the minimal models are
  *exactly* the glut-free ones; hence `entailsMin` on a consistent premise set is precisely
  **classical** two-valued consequence.
* `ds_LPm_valid` and `ds_LP_invalid` — disjunctive syllogism `{p, ¬p ∨ q} ⊢ q` is **valid
  in LPm but invalid in LP**, even though `{p, ¬p ∨ q}` has a glut-free model.
* `entailsMin_strictly_stronger_than_entails` — therefore `entailsMin` and `entails`
  **differ on the consistent fragment**; the true boundary is "LPm = classical, LP =
  paraconsistent", with disjunctive syllogism as the separating witness.

The second half builds Belnap–Dunn `FOUR` with its two intrinsic orders and proves the
defining bilattice signature `neg_tle_antitone` / `neg_kle_monotone`: negation is antitone
for the truth order but monotone for the knowledge/information order, the precise sense in
which monotonicity is "restored along information". Below are five concrete, falsifiable
directions for the next cycle.

## 1. Classical–LPm collapse as an exact theorem

**Conjecture.** For every premise set `Γ` possessing a glut-free model and every formula
`A`, `entailsMin Γ A ↔ classicalEntails Γ A`, where `classicalEntails` is ordinary Boolean
consequence over `{ff, tt}`-valuations; and on such `Γ` the strict containment
`entails Γ A → entailsMin Γ A` is *proper* exactly when `A` requires disjunctive syllogism.

The key insight is that `minimalModel_iff_glutfree` already identifies minimal models with
glut-free (= classical) valuations, so the remaining work is a clean bijection between
glut-free LP valuations and Boolean valuations under which `desig ∘ eval` becomes Tarskian
truth — turning the worked separation `ds_LPm_valid`/`ds_LP_invalid` into a structural
equivalence "LPm restricted to consistent theories = classical logic".

Why now? The hard half — that minimality forces glut-freeness in the consistent case — is
already machine-checked, so the conjecture reduces to packaging a finite truth-value
dictionary rather than re-deriving the model theory.

## 2. A quantitative inconsistency measure from forced gluts

**Conjecture.** Define `inc Γ := ⨅ { (gluts v).ncard | v a model of Γ }` (the least number
of atoms any model must send to `bb`). Then `inc Γ = 0 ↔ Γ` has a glut-free model, `entails`
and `entailsMin` agree on `Γ` whenever `inc Γ = 0`, and `inc` is sub-additive:
`inc (Γ ∪ Δ) ≤ inc Γ + inc Δ`.

The key insight is that `minimalModel` already minimises `gluts` along `⊂`; replacing the
order-theoretic minimum by the cardinality minimum yields a numerical invariant whose
vanishing locus is exactly the consistent fragment isolated in `minimalModel_iff_glutfree`,
making "how non-monotone can LPm be?" a measurable question.

Why now? `gluts` and the forced-glut argument (`model_Γ₂_forces_bb` in the parent file,
`ds_LP_invalid` here) already pin down when a glut is unavoidable; counting those gluts is
the natural next abstraction and connects paraconsistency to the inconsistency-measurement
literature.

## 3. Belnap `FOUR` consequence is monotone along the knowledge order

**Conjecture.** Lift `eval` to `FOUR`, define information-ordered consequence
`entailsK Γ A` as preservation of designation across the `kle`-minimal models, and prove it
is **monotone**: `Γ ⊆ Δ → entailsK Γ A → entailsK Δ A`, in contrast to the truth-ordered
`entailsMin` proved non-monotone in the parent file.

The key insight is that `neg_kle_monotone` shows negation — the only order-sensitive
connective — is `kle`-monotone, so the whole evaluation map is `kle`-monotone, and adding
premises can only move models *up* the information order; this is exactly the structural
reason monotonicity should survive along `kle` while failing along truth.

Why now? `FOUR`, both orders, and the decisive `neg_kle_monotone`/`neg_tle_antitone`
dichotomy are already verified here, so the remaining task is to define `entailsK` and run
the monotonicity induction over the four connectives.

## 4. `FOUR` is a verified interlaced bilattice with a `CommSemiring` on each axis

**Conjecture.** The truth meet/join and knowledge meet/join on `FOUR` form two distributive
lattices satisfying the interlacing laws (each pair of operations is monotone w.r.t. the
*other* order), and each axis `(join, meet)` is a commutative idempotent semiring, extending
the LP semiring bridge `commSemiring` of the parent file from three to four values.

The key insight is that `tle`/`kle` are already proved to be partial orders
(`tle_refl/trans/antisymm`, `kle_refl/trans/antisymm`), so the lattice operations are forced
as `inf`/`sup`, and interlacing plus the semiring axioms are finite truth-table identities of
exactly the kind `decide` discharges here — promoting "LP is tropical" to "`FOUR` is a
double-tropical (bilattice) structure".

Why now? The order infrastructure and the `decide`-based finite-verification methodology are
both in place; adding four operations and their (interlacing) axioms reuses the existing
proof pattern verbatim.

## 5. Iterated belief revision as a `kle`-monotone fixed point

**Conjecture.** A revision operator `rev : (ℕ → FOUR) → (ℕ → FOUR)` built from
`kle`-monotone connectives is itself `kle`-monotone, hence by Knaster–Tarski has a least
fixed point in the information order; this fixed point is the unique stable belief state and
is reached by `kle`-monotone iteration, giving a constructive convergence theorem for
paraconsistent belief revision.

The key insight is that `neg_kle_monotone` makes every `FOUR` connective information-monotone,
so any pointwise revision map is monotone on the complete lattice `(ℕ → FOUR, kle)`; the
truth-order retraction `retraction_nonmonotone` of the parent file is then revealed as
iteration measured along the *wrong* order, and convergence is recovered along `kle`.

Why now? Both endpoints exist: `neg_kle_monotone` supplies monotonicity and Mathlib already
provides the Knaster–Tarski fixed-point theorem for complete lattices, so the work is to
present `(ℕ → FOUR, kle)` as a complete lattice and invoke it.
