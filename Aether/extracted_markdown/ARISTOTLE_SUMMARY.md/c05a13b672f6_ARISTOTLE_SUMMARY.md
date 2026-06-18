# Summary of changes for run 40bfce11-4879-48d5-b6f8-9652011be15b
## What was produced

I added a new Lean theory and a research roadmap that build directly on the existing catalog Hodge theory (`Catalog/Tropical/HodgeDecomposition/Defs.lean`, namely `WeightedCoboundary`, `laplacianUp`, `adjunction`, and `ker_laplacianUp_eq_ker_d`).

**New file: `Catalog/Tropical/HodgeNTK/Threshold.lean`** — formalizes the depth dynamics of a linearized message-passing neural tangent kernel (NTK) on a finite weighted simplicial complex. A layer is the propagation operator `P = I − t·Δ^up` and the depth-`L` kernel is `P^L`. It contains **7 theorems, all proved with `sorry = 0`** and only standard axioms (the build completes with no errors; verified theorems carry no nonstandard axioms):

1. `mulVec_pow_eigen` — reusable spectral power lemma: `M *ᵥ u = c•u ⟹ Mᴸ *ᵥ u = cᴸ•u`.
2. `propagator_eigen` — one layer scales a `μ`-eigenvector by `1 − t·μ`.
3. `ntk_eigen_propagation` — the depth-`L` kernel scales a Hodge `μ`-eigenvector by exactly `(1 − t·μ)ᴸ`.
4. `ntk_harmonic_invariant` — harmonic cochains (`ker d = ker Δ^up`) are exact fixed points at *every* depth (topological signal never decays), proved via the catalog's `ker_laplacianUp_eq_ker_d`.
5. `ntk_nonharmonic_tendsto_zero` — non-harmonic modes decay geometrically iff the layer is contractive (`|1 − t·μ| < 1`).
6. `spectral_threshold_exists` — an explicit crossover depth `L_c`, governed by the Hodge spectral gap, beyond which harmonic signal dominates.
7. `ntk_crossover` — past `L_c` the harmonic scaling strictly dominates the non-harmonic scaling.

The file includes the required brief proof sketches and Lab Notebook blocks (Hypothesis / Result / Insight / Failure analysis) for each section.

**Key mathematical finding (a falsifiable refinement of the source conjecture):** in this exact infinite-width *linear* regime there is *no* finite "topology-blind" depth threshold — harmonic (topological) signal is a permanent invariant of depth, only non-harmonic signal contracts, and the threshold `L_c` instead marks where topology *takes over*. This is stated and proved precisely.

**New file: `FUTURE_DIRECTIONS.md`** — a narrative synthesis, a results-summary table, and 5 falsifiable research directions (quantitative `L_c ≍ log(A/B)/log(1/ρ)` law; the `0 < t·μ_max < 2` stability window; topology-detection separation between matched-degree complexes; convergence of `P^L` to the harmonic projector; extension to the full Hodge chain with `Δ^down`), each with an explicit "key insight" and "Why now?" justification.

The new theory was verified to build successfully against the catalog and Mathlib (no `sorry`, no errors). Build-infrastructure files I touched only to run that verification (the two `lakefile.toml`s, `Catalog/lake-manifest.json`, and temporary symlinks) were restored to their original state, so the only net changes to the project are the two new deliverable files.