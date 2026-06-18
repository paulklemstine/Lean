# Summary of changes for run 6c6d5cef-ef02-4aa0-b6f9-33e8fd621e95
Created a new self-contained Lean development on **scaling laws from a power-law kernel spectrum**, plus its research notes.

## New files
- `Catalog/MachineLearning/ScalingLaws.lean` — 5 fully proved theorems (no `sorry`, verified to use only the standard axioms `propext`/`Classical.choice`/`Quot.sound`).
- `Catalog/MachineLearning/FUTURE_DIRECTIONS.md` — synthesis, results table, and 5 falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification).

## Mathematical content
For a power-law eigenspectrum `λ_i = i^(-α)` (α > 1), with the spectral truncation/generalization error `E(n) = ∑_{i>n} i^(-α)`, the file proves from first principles:
- `summable_plaw_iff` — finite-trace dichotomy: `∑_i i^(-α)` converges iff `α > 1`.
- `plawFun_antitoneOn` — the spectrum `x ↦ x^(-α)` is antitone on `[1,∞)`.
- `plawTail_le` — upper bound `E(n) ≤ n^(1-α)/(α-1)` (integral comparison `AntitoneOn.sum_le_integral` + `Real.tsum_le_of_sum_range_le`).
- `plawTail_ge` — matching lower bound `E(n) ≥ (1 - 2^(1-α))/(α-1)·(n+1)^(1-α)` via the reverse comparison `AntitoneOn.integral_le_sum` on a single finite window (no improper-integral limit needed).
- `scaling_law` (capstone) — two-sided `c·(n+1)^(1-α) ≤ E(n) ≤ C·n^(1-α)`, i.e. `E(n) = Θ(n^(1-α))`, so the scaling exponent is exactly `α - 1`.

## Catalog integration
The work bridges existing catalog packages: it extends the spectral viewpoint of `NTKSpectral.lean` (spectrum → optimization rate) to the generalization side (spectral decay → error scaling law), and serves as the non-parametric `Θ(n^(1-α))` counterpart to the `Θ(d/n)` PAC-Bayes rate of `AsymptoticRate.lean`. Each theorem carries a `-- !-- … -- !--` proof sketch, and the file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

Note: the requested companion target had no pre-existing `ScalingLaws.lean` in the repository, so it was authored fresh and proved completely rather than filled in. The project-wide `lake` default build target is misconfigured independently of this work; the new file was verified directly with `lake env lean` (0 sorries, 0 errors/warnings).