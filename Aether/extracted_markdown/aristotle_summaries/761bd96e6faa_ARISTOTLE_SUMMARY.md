# Summary of changes for run 4caebede-f961-4bee-bad4-61904aaa3051
Completed a full research cycle on **Scaling Laws from Spectral Decay**, delivering two self-contained, fully compiling Lean 4 files (no `sorry`, only standard axioms) plus the required research notes, all under `Catalog/MachineLearning/ScalingLawSpectral/`.

## Theorem declarations (all `proved`)

**Core.lean** — the scaling-law backbone:
1. `tail_sum_inv_sq_le` — proved — the α=2 spectral-tail bias `∑_{M<k≤N} 1/k²` telescopes to `1/M` (via `1/k² ≤ 1/(k-1) − 1/k`).
2. `amgm_bias_variance` — proved — the α=2 risk `1/x + x/N ≥ 2/√N`, the canonical `N^{-1/2}` exponent (two-term AM–GM).
3. `amgm_bias_variance_min` — proved — the `2/√N` bound is attained at `x=√N`, so the exponent is exact and tight.
4. `scaling_law_general` — proved (centerpiece) — for general decay `α = a+1 > 1`, `x^{-a} + x/N ≥ (a+1)·a^{-a/(a+1)}·N^{-a/(a+1)}`, the full `-(α-1)/α` family, via weighted AM–GM with weights chosen so the `x`-powers cancel.

**Extensions.lean** — Critic + generalization loop:
5. `compute_optimal_allocation` — proved — under compute budget `M·N=C`, `1/M + M²/C ≥ (3/2^{2/3})·C^{-1/3}`, the Chinchilla-type compute-optimal `C^{-1/3}` law with `M~C^{1/3}, N~C^{2/3}` (three-term AM–GM).
6. `double_descent_pole` — proved — replacing variance `M/N` by the interpolation-regime `M/(N-M)` forces risk above any bound as `M→N⁻`, rigorously locating where the classical law breaks down (the double-descent seed).

## Notes (first-class deliverables)
- Each theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a `-- !-- ... -- !--` one-line proof sketch.
- `FUTURE_DIRECTIONS.md` contains the mandated `## Synthesis`, `## Results Summary` (all six theorems), and `## Research Directions` (5 falsifiable directions, each with Hypothesis / Test / Why now / If true / If false, plus a "key insight" sentence): general-α tail via integral comparison, sharp two-sided double-descent, multi-resource compute-optimal allocation for general α, matching minimax lower bounds, and deriving α from NNGP/NTK architecture.

## Verification
Both files compile via `lake env lean` with exit code 0, zero errors; a project-wide search confirms no `sorry`; and `#print axioms` shows every result depends only on `propext`, `Classical.choice`, `Quot.sound`.

Note: the project's `Catalog/*` modules are addressed under root `Catalog` (e.g. `MachineLearning.*`) and the project had no prior build artifacts for cross-module source resolution, so `Extensions.lean` imports `Mathlib` directly and references `Core.lean` in its documentation rather than via `import`; the two extension theorems are independent of Core's lemmas, so nothing is lost.