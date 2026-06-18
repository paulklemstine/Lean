# Summary of changes for run 337c68a7-83aa-48c6-ac4a-10433110fdfc
## Neural Tangent Kernel: Core Theory — Lean 4 Formalization

### File: `MachineLearning/NTKCore.lean`

A self-contained Lean 4 formalization of the mathematical core of Neural Tangent Kernel (NTK) theory (Jacot-Gabriel-Hongler 2018). **All 8 theorems compile with zero `sorry` statements** and depend only on standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Main Results (all fully proved):

1. **`ntkGramMatrix_posSemidef`** — The NTK Gram matrix K_{ij} = Σ_k Φ_{ik}Φ_{jk} is positive semidefinite. Proved by showing the quadratic form equals a sum of squares: v^T K v = Σ_k (Σ_i v_i Φ_{ik})² ≥ 0.

2. **`gdResidual_eq_pow`** — The residual after t steps of gradient descent equals (I - ηK)^t · u₀. Proved by induction on t using the matrix power identity.

3. **`gdResidual_geometric_decay`** — Under contractivity with constant c < 1, the residual norm decays geometrically: ‖u_t‖ ≤ c^t · ‖u₀‖. This is the core convergence estimate for NTK training.

4. **`linearized_residual_dynamics`** — **Key theorem**: In a linearized model f_lin(θ) = f(θ₀) + J(θ₀)(θ - θ₀), the residual dynamics are u_{t+1} = u_t - η·K·u_t where K = JJ^T is the NTK. This proves that **the kernel is constant along the training trajectory** — the "lazy training" regime.

5. **`gdStep_fixed_point_iff`** — Fixed point characterization: u is a fixed point of gradient descent iff Ku = 0, meaning convergence implies interpolation or projection onto the kernel null space.

6. **`ntkGramMatrix_eq_mul_transpose`** — Structural: K = ΦΦ^T.

7. **`gdUpdateOp_isSymm`** — Symmetry preservation: I - ηK is symmetric when K is.

8. **`ntk_universality`** — Architecture universality: two models with the same NTK produce identical trajectories.

### File: `FUTURE_DIRECTIONS.md`

Five research directions including spectral convergence rates, quantitative kernel perturbation bounds, loss landscape convexity, multi-output NTK, and RKHS connections.