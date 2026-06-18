# Summary of changes for run b1cdd454-880e-409a-b060-9952f2a914a2
Added a single coherent theorem-development extending the existing categorical tropical Rips / persistence interleaving ecosystem (the `BoltzmannBridge.Filtration` interleaving arc), in the new file `Catalog/Applications/BoltzmannBridge/InterleavingShiftSharpness.lean`.

What it contains (all proofs complete, no `sorry`, axioms limited to `propext`/`Classical.choice`/`Quot.sound`):

- `Filtration.shift F c hc` — the canonical `c`-scale shift of a filtration (for `0 ≤ c`), lowering every birth weight by `c` (which keeps the empty face born by scale `0` and preserves monotonicity, so the result is again a `Filtration`).
- `Filtration.shift_weight`, `Filtration.shift_sublevelFaces` — basic computation lemmas (the shift translates the sublevel family by `+c` in scale).
- `Filtration.interleaved_self_shift` — `F` and `F.shift c` are `c`-interleaved (upper half of sharpness).
- `Filtration.c_le_of_interleaved_self_shift` — every admissible interleaving shift is `≥ c`, via the empty-simplex obstruction (lower half of sharpness; needs no non-degeneracy hypothesis).
- `Filtration.eInterleavingDist_self_shift` — the sharp equality `eInterleavingDist F (F.shift c hc) = ENNReal.ofReal c`, and `Filtration.interleavingDist_self_shift` — its real-valued analogue `= c`.
- `Filtration.eInterleavingDist_self_shift_transport` — sharpness descends through any interleaving-isometric transport `Φ` (the explicit hypothesis is that `Φ` preserves `eInterleavingDist`), giving `eInterleavingDist (Φ F) (Φ (F.shift c hc)) = ENNReal.ofReal c`.
- `Filtration.edist_mk_self_shift` — the canonical quotient instance: in the genuine `EMetricSpace` separation quotient of the prior development, `edist (mk F) (mk (F.shift c hc)) = ENNReal.ofReal c`, since `SeparationQuotient.mk` is an isometry.

This reuses the existing definitions/theorems (`Filtration`, `sublevelFaces`, `sublevel_mono`, `Interleaved`, `interleavingDist`, `eInterleavingDist`, `eInterleavingDist_le`, `edist_quotient_mk`, `interleavingPseudoEMetric`) rather than creating parallel abstractions, and delivers both the requested transport form and the quotient-descent form of the sharp shift distance.

Build note: the project's source tree lives under `Catalog/` but the top-level `lakefile.toml` was not pointing there and did not declare the `Applications` library, so these files were previously unbuildable. I set the package `srcDir = "Catalog"` and added an `Applications` lean_lib (in both `lakefile.toml` and `Catalog/lakefile.toml`) so the interleaving ecosystem and the new file build. The whole import chain plus the new file compiles successfully.