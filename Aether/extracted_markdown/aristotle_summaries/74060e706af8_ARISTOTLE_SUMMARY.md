# Summary of changes for run 90d3c85e-e0b2-4bf4-991f-e05a48031391
Produced a complete Phase-A research cycle on **reversible computing and thermodynamic cost**, extending the existing catalog file `Computation/ReversibleSortingBennett.lean` (Bennett witnesses, `maxFiberSize`, `infoErased`, `landauerGap`).

## New Lean files (all compile, 0 sorries, only `propext`/`Classical.choice`/`Quot.sound` axioms)

**`Catalog/Computation/TightAncillaBound.lean`** — introduces `RevSim`, a *reversible simulation* (an injection `g : α → β × Aux` with `(g a).1 = f a`), the right generalization of Bennett's bijection-only witness to arbitrary, possibly non-surjective functions:
- `maxFiberSize_le_card_of_revSim` — lower bound: every simulation needs ≥ `maxFiberSize f` ancilla states.
- `exists_revSim_fin_maxFiber` — upper bound: `Fin (maxFiberSize f)` ancilla always suffice.
- `tight_ancilla_bound` — combines the two: `maxFiberSize f` is exactly minimal; no simulation into `Fin (maxFiberSize f − 1)` exists when a nontrivial fiber is present.
- `maxFiberSize_le_one_iff_injective` — one ancilla state ⇔ injectivity.

**`Catalog/Computation/IrreversibilityCost.lean`** — sharpens the catalog's non-strict `landauer_gap_nonneg` into a strict dichotomy:
- `image_card_lt_of_not_injective`, `infoErased_pos_iff_not_injective` — positive information erasure characterises non-injectivity.
- `landauerGap_pos_of_not_injective` — at positive temperature every non-injective map costs strictly positive work.

Together these establish the chain: more than one ancilla state ⇔ non-injective ⇔ erases information ⇔ strictly positive Landauer gap, with `maxFiberSize` as the single governing invariant.

Each file contains `-- !-- Lab Notebook --!--` blocks (Hypothesis/Result/Insight/Failure analysis) and `-- !-- sketch ... --!--` proof sketches, as requested.

**`FUTURE_DIRECTIONS.md`** — synthesis, a results-summary table, and 5 falsifiable next-cycle conjectures (optimal ancilla in bits, composition sub-additivity, strict entropy decrease, the functor to `Equiv.Perm`/Toffoli circuits, and a refinement-order data-processing law), each with a "The key insight is…" sentence and a "Why now?" justification.

Note: `lakefile.toml` needed `srcDir = "Catalog"` added so the existing `Computation.*` module imports resolve to the files under `Catalog/Computation/`; with this fix the whole project (8028 jobs) builds successfully.