# Summary of changes for run eb8553bb-4ef1-42d8-ae39-ea8e3646b65d
## What was produced

I created a new Lean 4 file, `Catalog/Speculative/AutoResearch/SpeciesDifferentialUnits.lean`, extending the existing catalog isomorphism `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧` (from `Catalog/Speculative/AutoResearch/SpeciesExponentialRing.lean`, building on `Catalog/Applications/CombinatorialSpecies.lean`). The file harvests two structural theories of formal power series as combinatorial facts about species, transported "for free" across the ring isomorphism.

### Theorems proved (no `sorry`; all depend only on `propext`, `Classical.choice`, `Quot.sound`)
- `ExpRing.isUnit_iff_constCoeff_ne_zero` — a counting sequence is invertible under the binomial-convolution (structural) product iff its empty-set count `a 0` is nonzero.
- `ExpRing.instIsLocalRing` — the binomial-convolution (Hurwitz) ring of species is a local ring.
- `ExpRing.shift_mul` — Leibniz rule `shift (a·b) = shift a · b + a · shift b`; the derivative-species shift is a derivation, forced by the power-series product rule.
- `ExpRing.shiftHom` — the shift bundled as an additive endomorphism.
- `ExpRing.binConv_one_signed` / `ExpRing.isUnit_setSpecies` — the species of sets `E` (EGF `exp`) is a unit, with the signed-sets species `n ↦ (-1)ⁿ` (EGF `exp(-X)`) as its explicit inverse, since `exp(X)·exp(-X)=1`.

### Method and discipline
Everything is pushed through `egfRingEquiv` (`map_mul`, `map_add`, `isUnit_map_iff`, `RingEquiv.isLocalRing`, `derivativeFun_mul`) rather than touching the transported ring's `*`/`1` directly, which keeps the proofs short and robust. The unit/local strand and the differential strand meet at the explicit sets ↔ signed-sets example.

### Deliverables
- The `.lean` file with 6 verified results, brief `-- !--` proof sketches above each result, and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).
- `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md` — synthesis, results summary, and 5 falsifiable research directions (maximal ideal + Neumann inverse; bundling the shift as a `Derivation` with the exp ODE; logarithmic derivative and connected/derangement recurrences; Hasse-derivative species Taylor theorem; substitution product and the exponential formula), each with a "The key insight is…" sentence and a "Why now?" justification.

### Verification
The new file compiles cleanly with the project root on the module search path; a `sorry` grep finds only the word inside the notebook prose, and `#print axioms` on all five headline declarations reports only the standard axioms. (The project's two nested lakefiles list default targets pointing at directories that do not exist, so full `lake build` of the default targets is a pre-existing no-op/failure unrelated to this work; the file and its dependency were compiled directly to confirm correctness.)