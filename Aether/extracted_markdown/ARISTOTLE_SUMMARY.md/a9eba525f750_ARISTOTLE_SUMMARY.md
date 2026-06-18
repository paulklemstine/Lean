# Summary of changes for run 6797921d-dbe9-4f3c-80e1-acf37b6937e7
## Delivered

A new sorry-free Lean 4 research file plus a research-roadmap document, extending the existing Hodge message-passing strand of the catalog.

### New Lean file: `Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`
Builds on `Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean` (reusing its `mpStep`, `mpStep_smul`, `mpStep_harmonic_fixed`, etc.). Ten new declarations, all proven with no `sorry` and depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`:

- `mpStep_eigenvector` — one layer acts as the scalar `(1 − αν)·` on an eigenvector `L v = ν•v`.
- `mpStep_iterate_eigenvector` — depth-`k` orbit is the closed form `(1 − αν)ᵏ•v`.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy on the slowest mode equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²` (the parent file's upper bound is *attained*).
- `oversmoothing_depth_necessary` — sub-tolerance forces `σᵏ < ε/⟪v,v⟫` (logarithmic depth is necessary).
- `mpFilter` (+ `mpFilter_nil`, `mpFilter_cons`) — degree-`|αs|` polynomial filter `∏(1 − αᵢL)` as a `List.prod` of steps in `Module.End ℝ E`.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν) = ∏(1 − αᵢν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — the heavy-ball filter is the explicit quadratic `1 − (α+β)L + αβL²`.

The file includes the required `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !--` proof-sketch comments on each theorem.

### Research roadmap: `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`
Freeform narrative with a Synthesis, a Results Summary, and five falsifiable directions (exact two-sided depth law, Chebyshev optimality of polynomial filters, deep limit = orthogonal projection onto `ker L`, unconditional contraction for `L = BᵀB` via the spectral theorem, and the full Hodge Laplacian `Δ`), each containing a "The key insight is…" sentence and a "Why now?" justification.

### Build fix
The project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no module (existing or new) could be resolved — every build failed looking for files at the repository root. Added that single line so the libraries (`Speculative.+`, etc.) resolve correctly. With it, the new module compiles cleanly: `lake build Speculative.AutoResearch.HodgeFilterDynamics` succeeds with zero `sorry`.