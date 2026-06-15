# Summary of changes for run 95a29068-7da7-43b6-a19c-24cb5669e634
Added a complete, standalone Lean development of a tropical (max-plus) dynamical invariant on the Berggren tree, building directly on the existing Berggren–Lorentz formalization.

New file: `Catalog/Tropical/BerggrenTree/TropicalHeight.lean` (namespace `BerggrenLorentz.Tropical`), importing `Catalog.Algebra.BerggrenLorentz.Core` and reusing its `childA`/`childB`/`childC` maps, `IsPythag`, and the Pythagorean side-length lemmas.

What it contains:
- Tropical observable: `tropHeight a b c = max (max a b) c`, an explicit, computable max-plus linear form picking out the largest coordinate. A "standard-position" region `Ordered a b c := 0<a ∧ 0<b ∧ 0<c ∧ a≤c ∧ b≤c` is introduced; `ordered_of_pythag` shows every positive primitive Pythagorean triple lies there, and `tropHeight_eq_hyp` shows `T` is exactly the hypotenuse on it.
- Closure: `ordered_childA/B/C` prove standard position is preserved by all three Berggren children.
- Exact recursion formulas (the core deliverable): `tropHeight_childA = 2a−2b+3c`, `tropHeight_childB = 2a+2b+3c`, `tropHeight_childC = −2a+2b+3c`, i.e. the third (hypotenuse) rows `hypA/hypB/hypC` of the generators.
- Strict growth/monotonicity: `tropHeight_childA/B/C_grow` and `T_step_grow` show each child increases `T` by at least `2`; `T_step_mono` records monotonicity.
- Berggren dynamics on triples: a step function `step : Fin 3 → ℤ×ℤ×ℤ → ℤ×ℤ×ℤ`, the height `T`, the predicate `OrderedT`, and an executable word-application `applyWord`.
- Path theorems (the substantive results): `applyWord_ordered` (standard position preserved along any generator word) and `T_applyWord_lower`, the path-growth theorem `T (applyWord w x) ≥ T x + 2·|w|`, proved by induction on the word.
- Executable instances: `seed = (3,4,5)`, `applyWord_BBB` (three B-steps reach `(697,696,985)`), `T_applyWord_BBB = 985`, and `T_seed_BBB_lower` instantiating the path bound.

Verification: the file builds with no errors, no warnings, and contains no `sorry`. All main theorems (including `T_applyWord_lower`, `applyWord_ordered`, `T_step_mono`, the recursion formulas, and the concrete instances) depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. Proofs are by direct integer computation from the matrix formulas plus elementary `max` case splits, as requested, with no placeholders or unfinished declarations.

Note: the repository's `lakefile.toml` library globs do not match the `Catalog.*` module layout, so the default `lake build` is a pre-existing no-op/failure unrelated to this work; the new file was verified by compiling the module directly against its dependency.