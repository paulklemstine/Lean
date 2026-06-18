# Summary of changes for run 23cb5c2e-2142-4acf-9da9-50b0c0cb1659
Delivered a self-contained, fully-proved Lean 4 development formalizing the concept "Neural Network Training as Renormalization Group Flow," plus a future-directions document.

## New files
- `MachineLearning/RGFlowTraining.lean` — the mathematical core (compiles cleanly, **0 sorries**, only standard axioms `propext`/`Classical.choice`/`Quot.sound`).
- `MachineLearning/FUTURE_DIRECTIONS.md` — 5 testable, falsifiable research conjectures extending the work, each with a "key insight" and "Why now?" justification.

## Theorem catalogue (all `proved`)
Modelling a coarse-graining / RG step as an idempotent linear operator `P` on parameter space and identifying the residual `R = id − P` as the gradient of the relevance loss `½‖θ − Pθ‖²`:

1. `rg_sgd_fixedPoint_iff` — **SGD ↔ RG fixed-point correspondence**: critical points `Rθ = 0` are exactly RG fixed points `Pθ = θ` (the rigorous form of the conjecture).
2. `rg_fixedPoint_iff_mem_range` — for idempotent `P`, fixed points are exactly `range P` (the relevant/slow manifold).
3. `rgFlow` + `rgFlow_zero`, `rgFlow_proj` — closed-form training flow; slow (coarse-grained) modes are conserved.
4. `rgFlow_hasDerivAt` — the flow solves the gradient ODE `θ' = −Rθ`, identifying it with continuous gradient descent.
5. `rgFlow_dist` — exact exponential relaxation `‖θ(t) − Pθ₀‖ = e^{−t}‖Rθ₀‖` (unit critical-exponent / beta-function slope).
6. `rgFlow_tendsto`, `rgFlow_limit_isFixedPoint` — convergence to the RG fixed point `Pθ₀`, which is genuinely fixed.
7. `rg_universality` — initialisations in the same coarse-grained class converge to the *same* fixed point (the universality statement).
8. `rg_spectral_decay` — anisotropic per-mode decay at the mode-specific critical rate `λ` (single-mode building block of full spectral universality).

The work explicitly builds on and complements the existing finite-dimensional NTK / lazy-training algebra in `MachineLearning/NTKCore.lean`, reinterpreting the fixed-kernel gradient dynamics through an idempotent coarse-graining operator. Brief proof sketches are included inline as `-- !-- ... -- !--` comments. The build was verified with the module compiled explicitly and a confirmed absence of `sorry`.