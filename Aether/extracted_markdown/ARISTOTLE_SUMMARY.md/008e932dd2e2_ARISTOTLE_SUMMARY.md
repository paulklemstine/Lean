# Summary of changes for run 3b51c475-b8fe-435e-bc2b-c0e7ffaad361
## Completed: Neural Tangent Kernel Spectral Convergence Theory

Created `Catalog/MachineLearning/NTKSpectralTheory.lean` — a self-contained Lean 4 formalization that deepens the existing NTK convergence theory with 8 fully proved theorems (0 sorries).

### Proved Theorems

1. **`ntkGram_entry`** — Each entry of the NTK Gram matrix K = J·Jᵀ equals the dot product of parameter gradients: K_{ij} = Σ_k J_{ik}·J_{jk}.

2. **`ntkGram_symm`** — The NTK Gram matrix is symmetric, following from commutativity of the inner product.

3. **`ntkGram_posSemidef`** — The NTK Gram matrix J·Jᵀ is positive semidefinite. This is the structural reason the NTK is PSD: v^T K v = ‖Jᵀv‖² ≥ 0. Proved via Mathlib's `posSemidef_conjTranspose_mul_self`.

4. **`loss_evolution`** — **The fundamental loss evolution identity**: L(u − ηKu) = L(u) − 2η⟨u, Ku⟩ + η²·L(Ku). This is the cornerstone identity for analyzing gradient descent convergence — it decomposes the loss change into a gradient contribution and a learning-rate correction.

5. **`loss_monotone_decrease`** — **Loss monotonicity**: If η·‖Ku‖² ≤ 2⟨u, Ku⟩ (always satisfiable for PSD K with small enough η), then the loss decreases at every step.

6. **`fixed_point_implies_kernel_null`** — Fixed points of gradient descent satisfy Ku = 0, connecting NTK training to kernel regression interpolation.

7. **`kernel_null_implies_fixed`** + **`fixed_point_iff_kernel_null`** — Complete characterization: u is a fixed point of NTK gradient descent ⟺ u ∈ ker(K). This bridges neural network training to RKHS/kernel methods.

8. **`perturbation_single_step`** — The single-step perturbation between two kernels is exactly η·(K₂ − K₁)·u, formalizing the "lazy training" regime.

### Structure
- **Part 1**: Gram matrix structure (J·Jᵀ identity, symmetry, PSD)
- **Part 2**: Gradient descent dynamics (loss evolution identity)
- **Part 3**: Loss monotonicity (convergence guarantee)
- **Part 4**: Fixed point characterization (bridge to kernel regression)
- **Part 5**: Perturbation theory (lazy training foundation)

### Key Deepening
This extends the existing `NTKConvergence.lean` by:
- Establishing the *structural* reason for PSD (Gram matrix factorization J·Jᵀ), not just proving it from the definition
- Proving the fundamental loss evolution identity that governs all convergence analysis
- Deriving loss monotonicity as a consequence of the evolution identity
- Bridging to kernel regression via the fixed-point characterization

### Future Directions (in file)
Five testable conjectures on spectral concentration, width convergence rates, feature learning transitions, generalization bounds from spectral decay, and depth-width tradeoffs.