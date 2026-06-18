# Summary of changes for run e5c8a3ec-1c28-40e3-b628-f107fc6db6b1
## Tropical Satake Support Reconstruction for GL₄ — Completed

### Formally Verified Mathematics (Lean 4)

All 17 theorems are **fully proved with no `sorry`**, building cleanly with Lean 4.28.0 / Mathlib. Axiom usage is restricted to `propext`, `Classical.choice`, and `Quot.sound`.

**`Tropical/GL4Separation.lean`** — Core definitions and separation theorems:
- `DomGL4`, `omega1Eval`/`omega2Eval`/`omega3Eval`, `gap12`/`gap23`/`gap34`, `domKey`, `domGapKey`, `TestDir`, `evalTestDir`
- `dominant_coordinate_recovery` — prefix sums recover individual coordinates
- `dominant_extensionality_by_prefix_sums` — **key theorem**: 4 prefix sums determine any ℤ⁴ function (no dominance needed)
- `domGapKey_injective` — gap-key encoding is injective (telescoping reconstruction)
- `dominant_extensionality_by_fundamental_and_gap` — extensionality from fundamental weights + root gaps
- `finite_test_family_separates_dominant` — 7 test directions separate dominant coweights
- `exists_separating_testdir_of_ne_dominant` — distinct dominants are separated
- `support_point_determined_by_test_values` — support points determined by test values

**`Tropical/GL4Faithfulness.lean`** — Tropical functions, reconstruction, and faithfulness:
- `TropFuncGL4` structure, `dirMax`/`dirMin`, `supportArgmax`, `tropEvalMin`, `IsGeneric`
- `singleton_argmax_of_strict_exposure` — strict exposure yields singleton argmax
- `unique_exposed_support_from_test_data` — exposed support points are uniquely determined
- `tropEvalMin_le_of_mem` / `tropEvalMin_eq_of_mem` — basic transform properties
- `coeff_from_exposed_direction` — coefficient extraction from exposing direction
- `singleton_tropEvalMin_determines_function` — singleton functions determined by transform
- `generic_exposed_achieves_min` — generic points achieve transform minimum
- `coeff_eq_of_support_eq_generic` — **main faithfulness**: support equality + genericity + transform equality ⟹ coefficient equality
- `tropical_Satake_faithful_GL4_generic` — full faithfulness theorem

### Python Demos (`Tropical/demos/`)

- `tropical_gl4_demo.py` — 6 interactive demonstrations covering separation, strict exposure, coefficient recovery, faithfulness, a counterexample showing unweighted dirMax fails, and gap-key injectivity
- `tropical_gl4_visualization.py` — 4 publication-quality matplotlib figures:
  - `tropical_separation.png` — test direction projections of dominant coweights
  - `tropical_exposure.png` — strict exposure mechanism
  - `tropical_transform.png` — weighted tropical transform and coefficient recovery
  - `tropical_counterexample.png` — counterexample for unweighted case

### Research Paper (`Tropical/paper.md`)

A complete mathematical paper with:
- Abstract, introduction with Langlands program context
- Full proof details for all main theorems
- The counterexample showing unweighted dirMax alone fails (sets {(5,3,1,0),(4,4,2,0)} and {(5,3,1,−1),(4,4,2,0)} have identical 7-direction dirMax values)
- Applications to tropical geometry, representation theory, and optimization
- Scientific American-style discussion section with CAT scan analogy
- Appendix with complete theorem inventory and axiom verification

### Key Mathematical Insight

The central discovery is that the 4 prefix sums (ω₁, ω₂, ω₃, Σ) form an injective encoding of ALL integer 4-tuples — this is a universal linear-algebra fact requiring no dominance. The 7 test directions provide redundancy useful for the exposure/peeling arguments. For the weighted tropical transform under genericity, faithfulness follows from a clean comparison argument: genericity gives F.val ≤ G.val pointwise, and any strict inequality would force the transforms to differ.