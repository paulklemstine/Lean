# Summary of changes for run 53ad4e35-ca06-4132-a711-054b034d01ed
Created a new self-contained Lean development on **Stereographic Neural Attention**, building on the existing algebraic attention theory in `MachineLearning/Attention.lean`.

**New files (under `Catalog/MachineLearning/StereographicAttention/`):**
- `Core.lean` — the Lean deliverable.
- `FUTURE_DIRECTIONS.md` — 5 testable, falsifiable research conjectures (each with a "The key insight is…" sentence and a "Why now?" justification).

**Mathematics.** The softmax score is replaced by the Cauchy kernel `K(q,k) = 1/(1 + ‖q−k‖²)` on a real normed/inner-product space, developed along two pillars:

*Geometry (Cauchy score = sphere distance):*
- `stereoProj`, `stereoHeight` — components of inverse stereographic projection `σ : E → E × ℝ`.
- `stereo_on_sphere` — `‖σ(x)‖² = 1`, i.e. the image lands on the unit sphere.
- `stereo_chordal_eq_kernel` — the squared chordal distance from `σ(x)` to the north pole equals `4·K(x,0)`.

*Analytic sparsity:*
- `cauchyKernel_pos`, `cauchyKernel_le_one`, `cauchyKernel_eq_one_iff` (saturates at 1 exactly on the diagonal), `cauchyKernel_antitone`.
- `cauchyKernel_active_iff` and `cauchyKernel_active_closedBall` — the τ-active key set is *exactly* a Euclidean closed ball of radius `√(1/τ−1)` around the query.
- `cauchy_total_weight_le` (`Σ ≤ N`), `cauchy_sparsity_markov` (MAIN: `τ·#active ≤ Σ scores`), and `cauchy_sparsity_card_le` (`τ·#active ≤ N`).

All of these are fully proven (no `sorry`) and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. Two worked `example` blocks illustrate the diagonal maximum and strict monotonicity.

**Conjecture (intentionally left as `sorry`).** `cauchy_sublinear_mass_conjecture` states the corrected sublinear total-mass law for δ-separated keys in ℝ^d (`Σ scores ≤ C·N^{(d−2)/d}`), pinning the advertised `O(√N)` sparsity to the `d = 4` case; this is the single packing problem the rest of the file reduces it to. It is the only `sorry` in the file.

The module `MachineLearning.StereographicAttention.Core` builds successfully (verified with `lake build` against the Catalog package). Note: the Lake package root for this project is the `Catalog/` subdirectory.