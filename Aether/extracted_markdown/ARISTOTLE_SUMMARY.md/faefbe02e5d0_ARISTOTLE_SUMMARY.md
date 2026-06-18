# Summary of changes for run 025ab2a9-9ec3-40cc-ac82-a5ef9646966c
Research cycle completed on **tropicalized binary weight enumerator profiles from the Smooth Poincaré code primitives**, extending the existing `Catalog/Applications/SmoothPoincare/` thread.

## New verified Lean file
`Catalog/Applications/SmoothPoincare/TropicalProfile.lean` — fully compiling, **0 sorries**, only standard/allowed axioms (the `native_decide`-derived `Lean.ofReduceBool`/`Lean.trustCompiler` appear only on the Hamming corollaries via inherited spectrum lemmas; the general theorems use just `propext, Classical.choice, Quot.sound`).

Building on the prior cycles' `twe`/`twePlus`/`minDist` machinery, it introduces the covering-radius invariant `maxWt C = max_{c∈C} wt c` and proves, for arbitrary length `n`:

- **Collapse theorem** (`twe_eq_min_zero_maxWt`): for any code containing `0`, the entire min-plus tropical enumerator is `twe C t = min(0, maxWt C · t)` — determined by the *single* invariant `maxWt`. Dual: `twePlus_eq_max_zero_maxWt`.
- **General profile self-duality** (`twe_add_twePlus`): `twe + twePlus = maxWt·t` for any `0`-containing code (no self-complementarity needed), generalizing the cycle-2 Hamming `=8t` identity.
- **Covering-radius additivity** (`maxWt_append`): `maxWt(C⊕D)=maxWt C+maxWt D`, the additive partner of the tropical-min law `minDist_append`.
- **Recovery theorem** (`twe_erase_eq_minDist_mul`): for `t ≥ 0`, the *punctured* enumerator `twe(C.erase 0) t = minDist C · t` — the minimum distance erased by the collapse is recovered as the positive slope after removing the origin.
- **Cycle-4 unification**: `maxWt_eq_length_of_ones_mem`, `twe_selfComplementary` (`= min(0,n·t)`), and `twe_add_twePlus_selfComplementary` (`twe+twePlus = n·t`) show the cycle-2 Hamming `8t` identity is a universal corollary for all self-complementary codes.
- **Hamming instantiations**: `hamming_maxWt = 8`, plus `min(0,8t)` and the `4·t` punctured slope re-derived from the general theorems rather than the spectrum.

## Lab notes
Inline `-- !-- Lab Notes -- !--` blocks (cycles 3 and 4) record the hypotheses, results, sign-selection insight (the sign of `t` picks which spectrum endpoint wins the tropical min/max), and failure analysis (ℝ←ℕ cast friction; necessity of `t ≥ 0` for recovery).

## FUTURE_DIRECTIONS.md
`Catalog/Applications/SmoothPoincare/FUTURE_DIRECTIONS.md` lists 5 falsifiable conjectures: (1) replication power law for `C^{⊕k}`; (2) tropical profile rigidity / inverse problem; (3) punctured-profile reconstruction of the weight Newton polygon; (4) a tropical Singleton/Gleason envelope `maxWt+minDist ≤ n+4`; (5) a tropical MacWilliams duality for dual codes.

## Build note
The provided `lakefile.toml` declared libraries whose globs (`Algebra.+`, etc.) did not match the on-disk module layout (`Catalog.*`), so no `Catalog` module was buildable. I added a single `[[lean_lib]] name = "Catalog"` with `globs = ["Catalog.+"]`, which lets these modules compile (verified end-to-end); existing files were left unchanged.

No prose articles, Python, HTML, or package files were produced, per the constraints.