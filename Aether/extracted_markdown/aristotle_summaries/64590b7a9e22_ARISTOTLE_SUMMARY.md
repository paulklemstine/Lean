# Summary of changes for run b772bc6a-124b-41f0-82de-97cd30d051ca
Added a new self-contained Lean file `Computation/ReversibleAncillaBound.lean` and `Computation/FUTURE_DIRECTIONS.md`, extending the catalog's reversible-computing work in `Computation/ReversibleSortingBennett.lean`.

## What was proved (all sorry-free; only standard axioms propext/Classical.choice/Quot.sound)

The file establishes a sharp min–max characterization of the auxiliary ("ancilla") overhead required to make an arbitrary function `f : α → β` on finite types logically reversible, where reversibility means an injective `g : α → β × Aux` with `(g a).1 = f a`.

1. `fiber_card_le_maxFiberSize` — every fiber `{a // f a = b}` has at most `maxFiberSize f` elements.
2. `revAncilla_lower_bound` — any reversible simulation needs at least `maxFiberSize f` ancilla states. This strengthens the catalog's `rev_witness_aux_lower_bound` from requiring a bijection to requiring only an injection.
3. `exists_revAncilla_maxFiber` — a constructive upper bound: `maxFiberSize f` ancilla states always suffice (index each input by its rank within its own fiber).
4. `revAncilla_isLeast` (headline) — combining (2) and (3): `maxFiberSize f` is the least achievable ancilla size, an exact `IsLeast` characterization.
5. `injective_iff_maxFiberSize_le_one` — `f` is already reversible (no nontrivial ancilla) iff its largest fiber has size ≤ 1.
6. `revAncilla_one_of_injective` — injective functions need only a single ancilla state (the "1 ancilla bit" case for bijections).
7. `maxFiberSize_const` — the fully collapsing map on `n` inputs needs exactly `n` ancilla states (the extremal, sorting-style case).

Each theorem carries a brief `-- !-- ... -- !--` proof sketch. The file builds cleanly with no warnings. To match the subagent's dependency tooling, `maxFiberSize` is restated locally (mirroring the catalog definition, cited in the docstring) so the file depends only on Mathlib.

## FUTURE_DIRECTIONS.md
Five falsifiable conjectures extending the result: (1) the logarithmic bit-count version `⌈log₂(maxFiberSize f)⌉`; (2) sub-additivity of ancilla under composition; (3) identifying `maxFiberSize` with the worst-case Shannon-entropy drop and Landauer floor; (4) realizing the optimal ancilla by concrete Toffoli/CNOT circuits; (5) an average-case ancilla bound via the fiber-size distribution / conditional entropy. Each includes a "key insight" sentence and a "Why now?" justification.