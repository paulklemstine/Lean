# Summary of changes for run f6dba9be-3403-45cd-8ac8-f7937de7aa0f
Built a new, fully machine-checked Lean 4 development formalizing the universal power-law scaling of minimal PDE-solver / neural-operator size near a spectral phase transition.

**New file:** `MachineLearning/SpectralPhaseTransition/Core.lean` (module `MachineLearning.SpectralPhaseTransition.Core`), plus `MachineLearning/SpectralPhaseTransition/FUTURE_DIRECTIONS.md`.

**Central object.** `Nmin ρ ε = sInf {n | ρ^n ≤ ε}`, the minimal iteration/depth count to drive a contraction `ρ = 1 - g` (spectral gap `g`) below target error `ε`.

**Theorems proved (sorry-free, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):**
- `Nmin_sandwich` — headline two-sided power law `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1`, so size diverges as `g⁻¹`. Floor from Bernoulli `1 - n·g ≤ (1-g)^n`; ceiling from `1 - g ≤ e^{-g}`.
- `Nmin_sandwich_accelerated` — the same with `g ↦ √g` (Chebyshev/CG acceleration), halving the exponent to `1/2`.
- `power_law_control` / `power_law_control_accelerated` — with the gap closing as `g = D^α` in the control parameter `D`, divergence is `D^{-α}` (resp. `D^{-α/2}`).
- `accelerated_exponent_lt` — the two universality classes differ: `α/2 < α`.
- `power_law_discretization_independent` — replacing `g` by `c·D^α` for any `c ∈ (0,1]` keeps the exponent `α`; only the prefactor moves (renormalization-style universality).
- Supporting lemmas `reachSet_nonempty`, `Nmin_mem`, `Nmin_le`.

**Computable confirmation.** A rational analogue `NminQ` `#eval`s to `44` (ρ=0.9) and `459` (ρ=0.99), numerically validating the tenfold `g⁻¹` growth.

**Notebook & directions.** Each file carries `-- !-- Lab Notebook -- !--` (Hypothesis/Result/Insight/Failure) and `-- !-- ... -- !--` proof-sketch blocks. `FUTURE_DIRECTIONS.md` gives a synthesis, a results table, and 5 falsifiable conjectures (sharp logarithmic-correction asymptotic, optimality of the √g acceleration barrier via Chebyshev extremality, exponent additivity `max(α₁,α₂)` for coupled gaps, a conserved width–depth product, and Jordan-block exponent multiplication `α·m`), each with a "key insight" and "Why now?".

The file builds cleanly (`lake build MachineLearning.SpectralPhaseTransition.Core`) with zero sorries. This is a cold-start, self-contained development (the referenced `Core.lean`/`Nmin` did not previously exist in the catalog); pre-existing unrelated broken files elsewhere in the project (e.g. `Algebra/Jacobian/Defs.lean`) were left untouched.