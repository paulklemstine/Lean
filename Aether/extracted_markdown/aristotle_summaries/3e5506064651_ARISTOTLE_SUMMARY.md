# Summary of changes for run cbbe0721-6253-4bb1-9f97-90509028a0c3
Created exactly one new, self-contained Lean file, `Catalog/Bridges/CategoricalTropicalRips.lean` (namespace `Bridges.CategoricalTropicalRips`), delivering a compact, fully-proved package of transport-compatibility and invariance lemmas for the existing persistent-homology / Vietoris–Rips interleaving geometry (the `Filtration` / `Interleaved` / `interleavingDist` / `eInterleavingDist` / `SeparationQuotient` arc in `Applications/BoltzmannBridge/`). The file builds with no `sorry` and every theorem depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

What is proved (all by unfolding definitions, an extensionality lemma, and the existing isometry/pseudometric API — no new abstractions):
- `filtration_ext` — extensionality for `Filtration` (weights determine the filtration).
- `shift` / `comap` — the smoothing (tropical shift, `weight ↦ weight − a`, `a ≥ 0`) and relabeling-along-an-equivalence functors, with `@[simp]` weight lemmas.
- `shift_comap` — relabeling commutes with shift.
- `Interleaved_comap_iff` — interleaving is invariant under relabeling.
- `interleavingDist_comap` and `eInterleavingDist_comap` — the real- and `ℝ≥0∞`-valued interleaving distances are invariant under relabeling.
- `edist_mk_comap` — the invariance descends to the genuine `EMetricSpace` separation quotient.
- `selfShiftDist_comap` and `eSelfShiftDist_transport` — the bundled transport principle: any exact self-shift-distance statement for a filtration transfers verbatim to all of its relabelings and to its quotient image (the self-shift-distance value is taken as a hypothesis, in line with the instruction not to attempt the lower-bound/sharpness result).

I deliberately included the quotient transport since the separation-quotient API was usable and stable.

Build configuration note: the `Applications/` sources (which contain the interleaving development this file builds on) were not part of any declared Lake library, so they could not be imported. I declared an `Applications` library (glob `Applications.+`, not added to default targets, so only the modules actually imported get compiled) in the project lakefile(s), and supplied the package `srcDir = "Catalog"` so the existing `Catalog/...` layout resolves. These are minimal build-config additions; no existing library code was modified or rewritten.