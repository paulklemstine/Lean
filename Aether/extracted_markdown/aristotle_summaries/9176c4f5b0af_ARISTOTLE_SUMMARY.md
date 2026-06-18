# Summary of changes for run c73df1f8-dfab-4752-8744-4d3ceb762009
Delivered a new self-contained Lean 4 research file plus a research roadmap, extending the catalog's EGF ring-isomorphism work on combinatorial species.

## New file: `Catalog/Speculative/AutoResearch/SpeciesDifferentialUnits.lean`
Building on `SpeciesExponentialRing.lean`/`CombinatorialSpecies.lean` (whose EGF transform is the ring isomorphism `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧` between the binomial-convolution "Hurwitz" ring of counting sequences and formal power series over ℚ), this file harvests two structural theories of `ℚ⟦X⟧` as combinatorial facts about species. Because the proving toolchain cannot resolve the project's `Catalog.*` cross-module imports, the EGF base layer is re-derived in a fresh namespace (`SpeciesDiffUnits`), exactly as `SpeciesExponentialRing.lean` itself did relative to `CombinatorialSpecies.lean`.

Main results (all `sorry`-free; each depends only on `propext`, `Classical.choice`, `Quot.sound`, verified individually):
- `ExpRing.isUnit_iff_constCoeff_ne_zero` — a species is invertible under the structural product iff its empty-set count `a 0 ≠ 0` (transported via `isUnit_map_iff` + `PowerSeries.isUnit_iff_constantCoeff`).
- `ExpRing.instIsLocalRing` — the binomial-convolution ring is a local ring (transported via `RingEquiv.isLocalRing`).
- `ExpRing.shift_mul` — the Leibniz rule `(F·G)′ = F′·G + F·G′`: the shift `a ↦ a(·+1)` is a derivation, forced by `PowerSeries.derivativeFun_mul` through the isomorphism; bundled as the additive endomorphism `ExpRing.shiftHom`.
- `binConv_one_signed` / `ExpRing.isUnit_setSpecies` — the species of sets `E` (constant-one sequence, EGF `exp`) is a unit whose explicit inverse is the signed-sets species `n ↦ (-1)ⁿ` (EGF `exp(-X)`), the analytic shadow of the inclusion–exclusion identity `∑ᵢ C(n,i)(-1)^{n-i} = [n=0]`.

The file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !-- … -- !--` one-to-two-sentence proof sketches before each theorem. A notable recorded pitfall: the transported ring's `*`/`1` are not defeq-transparent to `binConv`/`deltaSeq` for `exact`/`apply`/`rw`, so those bridges require `convert` or transport through `egfRingEquiv`.

## `FUTURE_DIRECTIONS.md` (repo root)
A narrative synthesis, a results summary, and five falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification): (1) explicit maximal ideal and the recursive Neumann inverse of a unit species; (2) bundling the shift as a Mathlib `Derivation` and the species exp/log ODE; (3) the substitution product and exponential formula, with the "no constant term" hypothesis identified as maximal-ideal membership; (4) higher shifts, Hasse derivatives, and a species Taylor theorem; (5) the λ-ring/cycle-index refinement of the units and derivation theorems.