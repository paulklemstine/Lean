# Summary of changes for run cbc8c85e-9a3d-4e98-b057-95678d17d6fa
## Local-to-Global Structure of the Exponential-Convolution Ring

I added a new research file `Catalog/Applications/SpeciesConvolutionLocalRing.lean` extending the
combinatorial species program (`CombinatorialSpecies.lean` → `SpeciesAnalyticBridge.lean` →
`SpeciesConvolutionRing.lean`). It builds directly on the catalog's bundled ring isomorphism
`egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧` and transports the local-ring / domain structure of formal power
series onto the species ring, exposing the "invertibility is detected at one stalk" picture.

### Main results (all proved, `sorry = 0`, axioms = propext / Classical.choice / Quot.sound)
- `egf_constantCoeff` — the stalk at the origin of `egf a` is the empty-set count `a 0`.
- `ConvSeq.instIsLocalRing` — counting sequences form a local ring (transported from `ℚ⟦X⟧`).
- `ConvSeq.isUnit_iff` — a counting sequence is a unit iff `a 0 ≠ 0` (local detection of global invertibility).
- `ConvSeq.mem_maximalIdeal_iff` — the maximal ideal is the augmentation ideal `{a | a 0 = 0}`.
- `ConvSeq.instIsDomain` — the exponential-convolution ring is an integral domain.

### Deliverables
- The Lean file carries per-result `-- !-- ... -- !--` proof-sketch blocks and `-- !-- Lab Notebook -- !--`
  blocks (Hypothesis / Result / Insight / Failure analysis).
- `Catalog/Applications/FUTURE_DIRECTIONS.md` gives the synthesis, a results table, and 5 falsifiable
  research directions (order valuation/DVR refinement, constructive species reciprocal, exponential
  formula as `𝔪 ≃ 1 + 𝔪`, residue field & split exact sequence, multivariate sheaf over the polydisk),
  each with a "The key insight is..." sentence and a "Why now?" justification.

### Repairs enabling the build
The species chain had two pre-existing duplicate-declaration errors that blocked compilation:
`egf_injective` was re-declared in `SpeciesAnalyticBridge.lean` and `binConv_comm` in
`SpeciesConvolutionRing.lean`, both already present in the base file. I commented out the redundant
downstream copies (preserving them in block comments with explanatory notes); downstream uses resolve
to the imported base declarations. I also added a scoped `SpeciesChain` library target to
`lakefile.toml` so the species chain builds in isolation under the repo's `Catalog.*` module naming.

`lake build SpeciesChain` completes successfully and the new file contains no `sorry`.