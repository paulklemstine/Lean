# Summary of changes for run 1de3b5ef-7243-4529-a4a0-cdd71643077d
I extended the project's verified Logic-of-Paradox (LP) model theory with a new, fully proved Lean file and a research-conjecture document.

## New Lean file: `Catalog/Logic/ParaconsistentMinimalBoundary.lean`
A self-contained development (the catalog modules are not on the import path, so the small LP core it builds on is reproduced) whose new results were verified to compile with **no `sorry`** and using only the axioms `propext`, `Classical.choice`, `Quot.sound`.

The headline contribution is a **refutation of a standing conjecture** from the previous cycle's future-directions (that minimal consequence `entailsMin` and LP consequence `entails` coincide on the consistent fragment):

- `entails_imp_entailsMin` — minimal consequence is unconditionally weaker than LP consequence (every minimal model is a model).
- `minimalModel_iff_glutfree` — given a glut-free model, the minimal models are exactly the glut-free ones; hence `entailsMin` on a consistent premise set is classical two-valued consequence.
- `ds_LPm_valid` and `ds_LP_invalid` — disjunctive syllogism `{p, ¬p∨q} ⊢ q` is valid in LPm but invalid in LP, even though the premise set has a glut-free model.
- `entailsMin_strictly_stronger_than_entails` — the refutation: a consistent `Γ` where `entailsMin Γ q` holds but `entails Γ q` fails, so the two relations differ on the consistent fragment. The correct boundary is "LPm = classical, LP = paraconsistent", with disjunctive syllogism as the witness.

A second section develops the Belnap–Dunn four-valued bilattice `FOUR` with its two intrinsic orders (truth `tle`, knowledge/information `kle`), proves both are partial orders, and establishes the defining bilattice signature: negation is antitone for the truth order (`neg_tle_antitone`) but monotone for the knowledge order (`neg_kle_monotone`), with `neg_not_tle_monotone` showing the two orders genuinely differ. This makes precise the idea that monotonicity is "restored along the information order".

Each theorem carries a brief `-- !-- ... -- !--` proof-sketch comment.

## `FUTURE_DIRECTIONS.md`
Five testable, falsifiable conjectures for the next cycle (classical–LPm collapse as an exact theorem; a cardinality-based inconsistency measure from forced gluts; monotonicity of knowledge-ordered consequence on `FOUR`; `FOUR` as a verified interlaced bilattice with a semiring on each axis; belief revision as a `kle`-monotone Knaster–Tarski fixed point), each with a "The key insight is..." sentence and a "Why now?" justification grounded in the lemmas already proved.