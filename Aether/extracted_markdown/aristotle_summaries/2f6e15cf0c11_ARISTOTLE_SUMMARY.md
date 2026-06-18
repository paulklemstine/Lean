# Summary of changes for run bfe432fa-240e-4c86-a06e-5a87815a0262
## Inverse Stereographic Renormalization Group — 1D Ising bridge

I added a new, fully-proved Lean file `Catalog/Geometry/IsingStereoRG.lean` and the required `FUTURE_DIRECTIONS.md`.

### What the Lean file proves (0 sorries on all results; verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`)

The file makes the concept's conjecture precise in the one exactly-solvable test case — the 1D Ising model under Kadanoff decimation — and connects it to stereographic/conformal geometry. Definitions: `invStereo` (inverse stereographic projection), `isingRG` (the exact decimation map `x ↦ x²` in the variable `x = tanh K`), `betaIsing` (discrete beta function), and `conformalFactor`.

Theorems (all proved):
- `isingRG_fixed_points_iff` — decimation fixed points are exactly `{0,1}` (disordered/ordered fixed points).
- `deriv_isingRG` — the decimation map has derivative `2x`.
- `isingRG_eigenvalue_ordered` / `isingRG_eigenvalue_disordered` — RG eigenvalues `2` and `0`.
- `ising_correlation_length_exponent` — `log₂` of the ordered-fixed-point eigenvalue equals `1`, reproducing the exact 1D result `ν = 1`.
- `eigenvalue_eq_one_add_beta_deriv` — the RG multiplier equals `1 + β'(x)`, the precise form of the "beta function controls the flow" conjecture.
- `stereo_snd_eq_cayley_isingRG` — the conformal bridge: the second stereographic coordinate is exactly the Cayley transform of the decimation map.
- `stereo_fst_eq_isingRG`, `invStereo_on_circle` — the projected flow lives on the unit circle.
- `deriv_stereo_fst_at_zero` — the stereographic-map derivative at the disordered fixed point equals the conformal factor `2`.

The work explicitly builds on and cites existing catalog results (`StereographicRG.lean`'s `moebiusF'`, `deriv_moebiusF'_formula`, `conformal_factor_le_two`, `rgUpdate_composition`; and `InverseStereoResearch.lean`'s projection identities) rather than reproving them.

### FUTURE_DIRECTIONS.md
Contains 5 falsifiable conjectures extending the work (circle-conjugacy/linearization of decimation, block-size universality of `ν=1` via `logb`, a coordinate-free beta = projection-derivative statement, a Möbius cocycle for multi-step decimation matching `rgUpdate_composition`, and the `x=1/2` watershed boundary where the dictionary breaks). Each includes a "The key insight is..." sentence and a "Why now?" justification.

### Note on building
The project's `lakefile.toml` lib globs (`Geometry.+`, etc.) do not match the actual `Catalog/Geometry/` directory layout, so `lake build` cannot target these files directly — this is a pre-existing condition affecting the existing files too, not something introduced here. I therefore verified the new file by compiling its full contents through the Lean compiler directly (success, standard axioms only) and confirmed zero `sorry` occurrences.