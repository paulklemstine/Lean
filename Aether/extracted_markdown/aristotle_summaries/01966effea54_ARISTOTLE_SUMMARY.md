# Summary of changes for run d0d549b9-93a3-485b-882f-348056ab511c
Completed a full v16a scientific-team research cycle on "Galois Theory of Cellular Automata: Which Rules Have Reversible Dynamics?", delivering two compiling, sorry-free Lean 4 files plus a future-directions document under `Catalog/Computation/`.

## Deliverables
- `Catalog/Computation/CellularAutomataReversibility.lean` — abstract reversibility theory on the infinite lattice `ℤ → A`.
- `Catalog/Computation/ElementaryCAReversibility.lean` — the finite cyclic (`ℤ/3`, 8 configurations ≅ S₈) elementary-CA case.
- `Catalog/Computation/FUTURE_DIRECTIONS.md` — 5 bold, falsifiable conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

Both Lean files contain `-- !-- Lab Notes -- !--` blocks documenting the Hypothesize / Experiment / Analyze / Critique / Synthesize loop, and each builds cleanly (`lake build` succeeds, no `sorry`, only the allowed axioms `propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler`).

## Key findings (and refutation of the prompt's conjecture)
- The reversibility group is correctly *defined* as the centralizer of the shift inside `Equiv.Perm (configurations)` — this matches the conjecture's "permutations commuting with the shift operator" phrasing.
- However the conjectured order `8!/4 = 10080` is FALSE. On the infinite binary lattice the group is infinite: I proved the shift has infinite order (`shiftEquiv_pow_ne_one`, via the induction lemma `shiftEquiv_pow_apply`) hence `reversibilityGroup_infinite`. On the cyclic lattice `ℤ/3` the centralizer of the shift has order exactly 36 (`reversibilityGroup3_card`), giving the explicit counterexample `reversibilityGroup3_card_ne_10080` (36 ≠ 10080). The discrepancy is explained by the shift's `1²·3²` cycle type on the 8 configurations.
- Structural results with genuine proofs: shift order = 3 (`cyShift_orderOf`), complement is an involution, shift and complement commute (`shift_compl_commute`, `cyShift_cyCompl_commute`), and both lie in the reversibility group. The CA-canonical generators thus generate only a small abelian `ℤ/3 × ℤ/2` (order 6) inside the order-36 centralizer — showing CA-realizable reversibility is strictly thinner than the full centralizer.
- Catalog bridge: building on `Computation.ReversibleSortingBennett`, I proved `reversible_revWitness` — every bijective (reversible) map admits a Bennett reversible-computation witness with a trivial `PUnit` auxiliary type, i.e. reversible CAs need zero history.

The adversarial mandate is satisfied: the numeric conjecture is met head-on with an exhaustive Lean counterexample (enumeration over all 8! permutations), and the infinitude claim is shown robust (it holds for every nonzero shift power, not a single witness).