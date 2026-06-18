# Summary of changes for run 791204b7-8593-436d-8096-c7a673483cf8
Built a new, fully machine-checked Lean 4 development formalizing the core of the conjecture "Universal Scaling of Minimal Neural PDE Solvers at Operator-Spectrum Phase Transitions."

## Deliverables

**`MachineLearning/SpectralPDEScaling/Core.lean`** (single Mathlib-only file; the project's Lean root is the `Catalog/` directory and the file is auto-included by the `MachineLearning` library glob). It compiles cleanly with **zero `sorry`s**, **no warnings/errors**, and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`, verified via the axiom checker).

Central object: the minimal iteration/depth count `Nmin ρ ε = least n with ρ^n ≤ ε` — the scalar shadow of how much solver depth/width is needed to invert a discretized solution operator with contraction factor `ρ = 1 - g` (gap `g`).

Main results (all proven):
- `Nmin_sandwich` — the universal two-sided power law for the unaccelerated (Neumann/Richardson) class: `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1`, hence divergence `~ g⁻¹` with a class-universal exponent and an ε-dependent prefactor band. Its two halves `Nmin_ge` (from Bernoulli `1 - n·g ≤ (1-g)^n`) and `Nmin_le` (from `1 - g ≤ e^{-g}`) are the whole engine.
- `Nmin_sandwich_accelerated` — the square-root–accelerated (Chebyshev/CG) class: `Nmin (1-√g) ε ~ g^{-1/2}`, exponent halved.
- `power_law_control` / `power_law_control_accelerated` — composing a gap `g = D^α` closing as a power of the control parameter `D = |λ-λc|` gives divergence `D^{-α}` resp. `D^{-α/2}`, i.e. critical exponents `ν = α` resp. `ν = α/2`.
- `accelerated_exponent_lt` — the exponent dichotomy `α/2 < α` distinguishing the two universality classes.
- `power_law_discretization_independent` — replacing `g` by `c·D^α` for any microscopic constant `c ∈ (0,1]` leaves the exponent equal to `α` (only the prefactor moves): the renormalization-style universality statement.
- Foundations `reachSet_nonempty`, `pow_Nmin_le`, `Nmin_le_of_pow_le`, plus a computable rational analogue `NminQ` whose `#eval` numerically confirms the law (gap 0.1 → 44 steps, gap 0.01 → 459 steps, a ~10× increase matching `g⁻¹`).

The file contains the required Lab Notebook block (Hypothesis/Result/Insight/Failure analysis) and brief `-- !--` proof-sketch comments on each result.

**`MachineLearning/SpectralPDEScaling/FUTURE_DIRECTIONS.md`** — a narrative synthesis, a results-summary table, and 5 falsifiable conjectures (sharp prefactor/log-correction limit; optimality of the `1/2` acceleration barrier via Chebyshev extremality; exponent additivity `ν = max(α₁,α₂)` for composed transitions; a conserved width–depth product near criticality; Jordan/exceptional-point exponent multiplication `D^{-α·m}`), each with a "The key insight is…" sentence and a "Why now?" justification.

## Catalog synthesis
The work sits in the MachineLearning domain and bridges it with operator-spectral / phase-transition themes present in the catalog (e.g. the width-as-order-parameter viewpoint of `Bridges/PhaseTransition.lean`), recasting "phase transition controls learnability/solver complexity" as a quantitative, exponent-level power law grounded in approximation theory rather than reproving existing results.

No prior declarations were modified or duplicated; only the two new files were added.