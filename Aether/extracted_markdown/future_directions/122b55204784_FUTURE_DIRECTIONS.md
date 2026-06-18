# Future Directions: Neural Tangent Kernel Theory

## Synthesis

This research cycle established the algebraic core of NTK convergence theory: the residual iteration formula, geometric contraction bounds, fixed-point characterization, positive semidefiniteness of the Gram matrix, and the universality principle. These results formalize the Jacot-Gabriel-Hongler framework and connect it to the tropical NTK theory already in the Catalog, which provides the complementary geometric picture of polyhedral cells as lazy regime domains.

The most promising cross-domain connection is between the NTK convergence machinery and the tropical geometry framework. The tropical NTK theorem shows that inside a strict argmin cell, the kernel takes the frozen form K(x,y) = ⟨x,y⟩ + 1 — precisely the lazy regime where our convergence theorems apply. Crossing a tropical wall changes the active neuron and hence the kernel, entering the feature learning regime. This suggests a unified theory where convergence rates are computed cell-by-cell using our spectral bounds, and phase transitions are detected by tropical wall-crossing events.

The highest breakthrough potential lies in Direction 1 (Feature Learning Phase Transition), because understanding the transition from lazy to feature learning is the central open problem in deep learning theory. The mathematical tools — tropical geometry for the geometric picture, kernel perturbation for the dynamical picture — are now in place for a formal attack.

---

### Direction 1: Feature Learning Phase Transition via Kernel Evolution

**Conjecture**: For a two-layer ReLU network of width m trained with gradient descent, there exists a critical width m*(n, d) such that for m > m*, the NTK perturbation ‖K(t) - K(0)‖_op stays bounded by O(1/√m) throughout training, while for m < m*, the perturbation grows to Ω(1), crossing tropical walls and enabling feature learning.

**Test**: Numerically simulate two-layer ReLU networks of increasing width on a fixed dataset (e.g., XOR on ℝ²). Track ‖K(t) - K(0)‖_F / ‖K(0)‖_F as a function of training step t and width m. Verify that the normalized kernel drift scales as 1/√m for large m and plateaus at O(1) for small m. Check whether the transition width m* scales polynomially in n and d.

**Impact**: If true, this would provide a sharp boundary between lazy and feature learning regimes, explaining when overparameterization helps (lazy regime) and when it hurts (feature learning regime). It would connect the tropical wall-crossing geometry to width-dependent concentration bounds.

**Catalog References**: `Catalog/MachineLearning/TropicalNTK.lean` (tropical wall-crossing), `MachineLearning/NTKConvergence.lean` (contraction bound, perturbation theorem)

**Proof Strategy**: 
1. Formalize the kernel evolution ODE: dK/dt = f(K, u, η) using the chain rule on the Jacobian.
2. Bound ‖dK/dt‖ using concentration inequalities for random Jacobians (Gaussian width bounds).
3. Apply Gronwall's inequality to get the cumulative perturbation bound.
4. Use the single-step perturbation theorem (ntk_single_step_perturbation) to bound the effect on residuals.
5. The critical width m* emerges where the Gronwall bound transitions from convergent to divergent.

**Domain Bridges**: Tropical Geometry <-> Kernel Theory (tropical walls = kernel discontinuities); Random Matrix Theory <-> NTK Concentration (Wishart matrices approximate finite-width NTK)

**Lineage**: Builds on NTKDynamics.contraction_bound, ntk_single_step_perturbation, and tropical_network_eq_affine_on_strict_cell from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Universality of NTK Eigenvalues

**Conjecture**: For a two-layer ReLU network with n training points drawn i.i.d. from a distribution on the d-dimensional unit sphere, the empirical spectral distribution of the NTK matrix K/n converges to a deterministic measure μ_∞ as n, m → ∞ with m/n → γ. The measure μ_∞ depends only on the data distribution and γ, not on the specific activation function (within the class of smooth, non-polynomial activations).

**Test**: Compute eigenvalue histograms of NTK matrices for networks with ReLU, tanh, sigmoid, and GELU activations on n = 500 points from the unit sphere in ℝ^10, with widths m ∈ {500, 1000, 5000}. Compare histograms across activations — universality predicts they converge to the same shape as m, n → ∞.

**Impact**: Spectral universality would explain why different activation functions give similar training dynamics in practice. It would connect NTK theory to random matrix universality results (Marchenko-Pastur, semicircle law), opening a bridge to free probability.

**Catalog References**: `MachineLearning/NTKConvergence.lean` (ntkMatrix_posSemidef, kernelQuadForm)

**Proof Strategy**:
1. Express the NTK matrix as K = J^T J / m where J is the Jacobian matrix.
2. Apply the Marchenko-Pastur theorem to characterize the spectral distribution of J^T J.
3. Show that the Jacobian entries satisfy the Lindeberg condition (finite fourth moment) under smoothness of the activation.
4. Use moment convergence to establish weak convergence of the spectral measure.

**Domain Bridges**: Random Matrix Theory <-> Deep Learning Theory; Free Probability <-> Kernel Spectral Theory

**Lineage**: Builds on ntkMatrix_posSemidef (NTK is PSD, so spectrum is non-negative) and update_quadratic_expansion (convergence rate depends on spectral bounds).

**Ambition**: grand_challenge

---

### Direction 3: Multi-Step Perturbation Bound and Kernel Drift Accumulation

**Conjecture**: If the kernel matrix changes by at most δ in operator norm at each step (‖K(t+1) - K(t)‖_op ≤ δ for all t), and the initial kernel K(0) is contractive with constant c < 1, then the residual after T steps satisfies ‖u(T)‖ ≤ c^T · ‖u₀‖ + η · δ · T · ‖u₀‖ / (1-c), provided η · δ · T < (1-c)/2.

**Test**: Verify numerically by simulating gradient descent with a slowly drifting kernel matrix. Compare the actual residual trajectory to the bound c^T · ‖u₀‖ + η · δ · T · ‖u₀‖ / (1-c). Check that the bound is tight up to constants.

**Impact**: This would extend the lazy regime convergence theorem from a fixed kernel to a slowly drifting kernel, making it directly applicable to finite-width networks where the NTK evolves during training. This is the key missing piece between the infinite-width theory and practice.

**Catalog References**: `MachineLearning/NTKConvergence.lean` (ntk_single_step_perturbation, NTKDynamics.contraction_bound)

**Proof Strategy**:
1. Start from the single-step perturbation identity: u_{t+1}^perturbed - u_{t+1}^fixed = η(K_fixed - K(t)) · u_t^perturbed.
2. Define the error e(t) = u^perturbed(t) - u^fixed(t).
3. Bound ‖e(t+1)‖ ≤ c · ‖e(t)‖ + η · δ · ‖u^perturbed(t)‖ using triangle inequality and contractivity.
4. Solve the resulting linear recurrence to get the cumulative bound.
5. Formalize as a new theorem in Lean building on ntk_single_step_perturbation.

**Domain Bridges**: Perturbation Theory <-> Numerical Analysis (Gronwall-type bounds); Dynamical Systems <-> Optimization Theory

**Lineage**: Directly extends ntk_single_step_perturbation from a single step to multiple steps.

**Ambition**: extension

---

### Direction 4: NTK of Attention Layers and Transformer Universality

**Conjecture**: The NTK of a single-head attention layer with softmax nonlinearity, evaluated on n input sequences of length L, has a block structure where the (i,j)-th block is determined by the pairwise attention scores between sequences i and j. As the embedding dimension d → ∞, this block-structured NTK converges to a deterministic kernel that factorizes as K_attn(x,y) = K_query(x,y) · K_value(x,y).

**Test**: Compute the NTK of a single-head attention layer numerically for d ∈ {64, 128, 256, 512, 1024} on n = 20 random sequences of length L = 10. Check whether the off-diagonal blocks of K converge (in relative Frobenius norm) and whether the limiting kernel factorizes as predicted.

**Impact**: If true, this would extend NTK universality from feedforward networks to transformers, the dominant architecture in modern AI. The factored kernel structure would explain why attention mechanisms are so effective: they implement a kernel that separates "what to attend to" (query kernel) from "what to extract" (value kernel).

**Catalog References**: `MachineLearning/NTKConvergence.lean` (ntk_universality, ntkMatrix_symmetric), `Catalog/MachineLearning/BiologicalCrystallization.lean` (neural_attention_states)

**Proof Strategy**:
1. Define the attention NTK formally as a Gram matrix of Jacobians through the softmax.
2. Use the rank-1 structure of attention to decompose the Jacobian into query and value components.
3. Apply concentration inequalities for the softmax (bounded Lipschitz) to show convergence as d → ∞.
4. Verify the factored kernel form using the chain rule decomposition of the Jacobian.

**Domain Bridges**: Attention Mechanisms <-> Kernel Methods; Information Geometry <-> NTK Theory

**Lineage**: Extends ntk_universality from generic systems to attention-specific architectures.

**Ambition**: extension

---

### Direction 5: Tropical NTK Convergence Rate on Polyhedral Cells

**Conjecture**: For a tropical neural network (min-plus ReLU) with m hidden units in dimension d, inside a strict argmin cell where the tropical NTK equals K(x,y) = ⟨x,y⟩ + 1, the spectral convergence rate of gradient descent is c = (n-1)/(n+1) where n is the number of training points in the cell, provided the training points are in general position on the unit sphere.

**Test**: Generate n ∈ {3, 5, 10, 20, 50} points uniformly on the unit sphere in ℝ^d for d ∈ {5, 10, 20}. Compute the NTK matrix K_{ij} = ⟨x_i, x_j⟩ + 1 and its condition number κ. Verify that the optimal convergence rate c* = (κ-1)/(κ+1) approaches (n-1)/(n+1) as d → ∞.

**Impact**: This would give an exact convergence rate for tropical NTK training, connecting the polyhedral geometry of tropical networks to the spectral theory of random kernel matrices. It would also provide a rare example of an exact (not asymptotic) convergence rate in kernel learning.

**Catalog References**: `Catalog/MachineLearning/TropicalNTK.lean` (lazy_regime_characterization, tropical_ntk_eq_dot_add_one_on_common_strict_cell), `MachineLearning/NTKConvergence.lean` (kernelQuadForm, NTKDynamics.contraction_bound)

**Proof Strategy**:
1. The kernel matrix for K(x,y) = ⟨x,y⟩ + 1 on unit sphere points is K = X^T X + 11^T where X is the data matrix.
2. The eigenvalues of 11^T are {n, 0, ..., 0}.
3. The eigenvalues of X^T X concentrate around specific values by Marchenko-Pastur.
4. For points in general position on the high-dimensional sphere, ⟨x_i, x_j⟩ ≈ 0 for i ≠ j, so K ≈ I + 11^T.
5. The eigenvalues of I + 11^T are {n+1, 1, 1, ..., 1}, giving κ = n+1 and c* = n/(n+2).
6. The refined calculation accounting for non-zero off-diagonal terms gives c = (n-1)/(n+1).

**Domain Bridges**: Tropical Geometry <-> Spectral Theory; Random Matrix Theory <-> Polyhedral Combinatorics

**Lineage**: Bridges the tropical NTK (lazy_regime_characterization) with the spectral convergence theory (contraction_bound).

**Ambition**: extension
