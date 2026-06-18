# Summary of changes for run b4c4449d-8933-48c9-a14a-46caf759382c
## Summary

I added a new research file `Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean` extending the project's Hodge–Laplacian message-passing convergence theory along two of its declared research directions, plus a `FUTURE_DIRECTIONS.md` driving the next cycle.

### New Lean results (all sorry-free; axioms only `propext`, `Classical.choice`, `Quot.sound`)
Building on `mpStep`/`mpStep_smul`/`mpStep_harmonic_fixed` from `HodgeMessagePassingConvergence.lean`:

**Exact mode dynamics & matching lower bound (parent Direction 5):**
- `mpStep_eigenvector` — one layer acts as scalar `(1 − αν)·` on an eigenvector `L v = ν·v`.
- `mpStep_iterate_eigenvector` — closed-form depth-`k` orbit `(1 − αν)ᵏ·v`.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`, showing the prior cycle's geometric upper bound is *attained* (two-sided tightness).
- `oversmoothing_depth_necessary` — sub-tolerance on the slowest mode forces `σᵏ < ε/⟪v,v⟫`, i.e. logarithmic depth is necessary.

**Polynomial / Chebyshev filters (parent Direction 3):**
- `mpFilter` (def) plus `mpFilter_nil`/`mpFilter_cons` — a degree-`m` filter `∏(1 − αᵢL)` as a `List.prod` of gradient steps in `Module.End ℝ E`.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν) = ∏(1 − αᵢν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — the heavy-ball (degree-2) filter is the explicit quadratic `1 − (α+β)L + αβL²`.

The file contains the required `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !-- comment -- !--` proof sketches for each theorem.

### FUTURE_DIRECTIONS.md
A freeform narrative with Synthesis, Results Summary, and five falsifiable research directions (exact `Θ(log(1/ε)/log(1/ρ))` depth law; Chebyshev optimality; identifying the limit as the orthogonal projection onto `ker L`; unconditional contraction for `L = BᵀB` via the spectral theorem; the full Hodge Laplacian), each including a "The key insight is..." sentence and a "Why now?" justification, citing the relevant catalog declarations.

### Build fix
The repository's top-level `lakefile.toml` pointed its library globs at directories that live under `Catalog/`, so the project did not build. I added `srcDir = "Catalog"` to the package config, which resolves the module paths (e.g. `Speculative.AutoResearch.*`) correctly. The new module builds cleanly with no warnings; a pre-existing missing-file issue elsewhere in the catalog (`Algebra/Jacobian/Defs.lean`) is unrelated and untouched.

Verification: `lake build Speculative.AutoResearch.HodgeFilterDynamics` succeeds, the file has no `sorry`, and `#print axioms` on the main theorems shows only the standard three axioms.