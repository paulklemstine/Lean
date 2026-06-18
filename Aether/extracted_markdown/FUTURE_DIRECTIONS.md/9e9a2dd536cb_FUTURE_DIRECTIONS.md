# Future Research Directions

## Synthesis

This research cycle established the information-geometric foundations of EML statistical manifolds, proving 17 theorems about Fisher information, Bregman divergence, and natural gradient structure. The central discovery is the **uniform Fisher information lower bound I₁₁ ≥ 1**, which distinguishes EML manifolds from standard neural network architectures and guarantees non-degeneracy of the Riemannian structure.

The most promising cross-domain connection is between the **Bregman divergence framework** (information geometry) and the **tropical semiring** (algebraic geometry). The log-partition function Ψ(a,b) = a²/2 + b²/2 + exp(a)·log(|b|+1) contains both exponential and logarithmic terms — precisely the operations that become linear under tropicalization. This suggests a tropical limit of information geometry that could connect M_EML to the max-plus algebra already developed in the Catalog's tropical semiring work.

The cycle also revealed important negative results: the EML manifold does NOT have constant negative curvature (refuting the hyperbolic geometry conjecture), and the log-partition is NOT convex in the b-parameter for large a. These failures are informative — they reveal the fundamental asymmetry between exponential and logarithmic parameters and constrain future conjectures.

---

### Direction 1: Tropical Fisher Information and the Maslov Dequantization of M_EML

**Conjecture**: In the tropical limit (replacing (×, +) with (max, +)), the Fisher information metric of M_EML converges to a piecewise-linear metric on a tropical variety, and the Bregman divergence becomes a tropical distance function. Specifically, define the tropical log-partition Ψ_trop(a,b) = max(a², b², a + log(|b|+1)). Then the tropical Fisher metric is the subdifferential of Ψ_trop, and the associated Bregman divergence is the tropical Hausdorff distance.

**Test**: Compute Ψ_trop for specific parameter values and verify that the tropical Bregman divergence satisfies a tropical three-point identity. Formalize the tropical limit theorem: for t → ∞, (1/t)·Ψ(ta, tb) → Ψ_trop(a, b).

**Impact**: If true, this provides a bridge between continuous information geometry and discrete/combinatorial optimization via tropical methods. This could enable polynomial-time approximation algorithms for natural gradient descent on EML manifolds.

**Catalog References**: `EML/EMLTropicalSemiring.lean`, `EML/MaxPlusStoneWeierstrass.lean`, `Tropical/` directory

**Proof Strategy**: 
1. Define the tropical log-partition as a max of linear functions.
2. Prove the scaling limit Ψ(ta,tb)/t → Ψ_trop(a,b) using dominated convergence and the fact that exp(ta) grows fastest.
3. Show the tropical Bregman divergence is a max of affine functions (piecewise linear).
4. Verify the tropical three-point identity algebraically.

**Domain Bridges**: Information Geometry <-> Tropical Algebraic Geometry <-> Combinatorial Optimization

**Lineage**: Builds on `EMLFisher.emlLogPartition` and `EMLFisher.bregman_three_point` from this cycle, plus existing tropical semiring work.

**Ambition**: grand_challenge

---

### Direction 2: Fisher-Rao Gradient Flow and Wasserstein Distance on EML Manifolds

**Conjecture**: The natural gradient flow on M_EML (the ODE dθ/dt = -I(θ)⁻¹·∇L(θ)) is equivalent to the Wasserstein gradient flow of the KL divergence on the space of probability measures. Specifically, the Fisher-Rao distance d_FR(p_θ, p_θ') on M_EML is bounded above and below by constant multiples of the Wasserstein-2 distance W₂(p_θ, p_θ'): c₁·W₂ ≤ d_FR ≤ c₂·W₂, where c₁, c₂ depend on the uniform Fisher bound I ≥ 1.

**Test**: Compute both distances for specific 1D EML distributions (varying only a with b = 1 fixed) and verify the bi-Lipschitz bound numerically. Check whether c₁ = 1 (conjectured from the I ≥ 1 bound).

**Impact**: If true, this would connect the statistical geometry of EML to optimal transport theory, enabling the use of Wasserstein-based algorithms (Sinkhorn, etc.) for natural gradient computation. The uniform Fisher bound would give a uniform bi-Lipschitz constant, which is extremely rare.

**Catalog References**: `Shared/EMLFisherGeometry.lean` (this cycle), `EML/TrainingDynamics.lean`

**Proof Strategy**:
1. Define the Fisher-Rao distance as the geodesic distance under the Fisher metric.
2. For 1D EML (a only), the geodesic equation is solvable since I₁₁ = 1 + exp(a)·C.
3. Compare with W₂ by bounding the density ratio using the EML structure.
4. The lower bound c₁ ≥ 1/√(I_max) follows from Cramér-Rao; the upper bound from I ≥ 1.

**Domain Bridges**: Information Geometry <-> Optimal Transport <-> Neural Network Training

**Lineage**: Builds on `eml_fisher_ge_one` and `ngd_optimal_step` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Higher-Dimensional Fisher Geometry of Deep EML Networks

**Conjecture**: For a deep EML network with L layers and n parameters per layer, the Fisher information matrix I ∈ ℝ^(nL × nL) has the following block structure: I is block-diagonal with L blocks of size n × n (one per layer), plus off-diagonal blocks that decay exponentially in layer distance. The smallest eigenvalue of I is bounded below by 1 (generalizing I₁₁ ≥ 1 to the full matrix).

**Test**: Construct the Fisher matrix for a 2-layer, 2-parameter-per-layer EML network (4 × 4 matrix) and compute its eigenvalues. Verify the block structure and the eigenvalue lower bound.

**Impact**: If the eigenvalue lower bound holds, it would prove that deep EML networks avoid the vanishing Fisher information problem that plagues deep ReLU networks. This would give a theoretical explanation for EML's training stability.

**Catalog References**: `EML/EMLNeuralNetworks.lean`, `EML/DeepComposition.lean`, `EML/KolmogorovArnoldEMLDeep.lean`

**Proof Strategy**:
1. Write the Fisher matrix for the composed log-partition Ψ = Ψ_L ∘ ... ∘ Ψ_1.
2. Use the chain rule for Hessians: Hess(f∘g) = (Jg)ᵀ(Hess f)(Jg) + Σ (∂f/∂y_i)(Hess g_i).
3. The block-diagonal structure follows from the chain rule; the decay follows from the exponential decay of (Jg)ᵀ across layers.
4. The eigenvalue bound uses I₁₁ ≥ 1 at each layer and Cauchy interlacing.

**Domain Bridges**: Information Geometry <-> Deep Learning Theory <-> Linear Algebra (spectral theory)

**Lineage**: Builds on `eml_fisher_ge_one` and `emlLogPartition_strictConvex_a` from this cycle.

**Ambition**: extension

---

### Direction 4: α-Connections and Projective Flatness on the EML 1-Manifold

**Conjecture**: The α-connection ∇^(α) on the 1-dimensional EML manifold (a only, b fixed) is projectively flat for α = ±1. For α = 1 (exponential connection), the geodesics are straight lines in natural parameters θ. For α = -1 (mixture connection), the geodesics are straight lines in expectation parameters η = Ψ'(θ). The 1-manifold is dually flat with dual potentials Ψ and Ψ* (its Legendre transform).

**Test**: Compute the Christoffel symbols Γ^(α) for α = 1 and α = -1 on the 1D EML manifold. Verify that they vanish (flatness). Compute the Legendre transform Ψ* numerically and verify it inverts Ψ.

**Impact**: Confirms the dually flat structure in 1D, which is the foundation for efficient Fisher vector products and information-geometric optimization algorithms.

**Catalog References**: `Shared/EMLFisherGeometry.lean`, `EML/ExtendedTheory.lean`

**Proof Strategy**:
1. Define the α-connection Christoffel symbols: Γ^(α) = (1-α)/2 · Ψ''' / Ψ''.
2. For α = 1: Γ^(1) = 0, so the e-connection is flat.
3. For α = -1: transform to η-coordinates and show Γ^(-1) = 0.
4. The Legendre transform Ψ*(η) = η·θ(η) - Ψ(θ(η)) where θ(η) inverts η = Ψ'(θ).

**Domain Bridges**: Information Geometry <-> Convex Analysis (Legendre duality) <-> Optimization

**Lineage**: Builds on `emlLogPartition_deriv_a`, `emlLogPartition_deriv2_a`, and `emlLogPartition_strictConvex_a` from this cycle.

**Ambition**: extension

---

### Direction 5: Quantum Fisher Information for EML Density Operators

**Conjecture**: Define a quantum EML density operator ρ(a,b) = exp(a·H₁ + b·log(H₂ + I))/Tr(exp(a·H₁ + b·log(H₂ + I))) for Hermitian operators H₁, H₂. The symmetric logarithmic derivative (SLD) Fisher information of this quantum EML family satisfies a quantum analog of the uniform lower bound: F_Q(a,b) ≥ Var_ρ(H₁) ≥ λ_min(H₁)², where λ_min is the smallest eigenvalue gap.

**Test**: Compute the SLD Fisher information for 2×2 matrices (qubit case) with H₁ = σ_z (Pauli-Z) and H₂ = I + σ_x. Verify the lower bound numerically.

**Impact**: Would extend EML information geometry to quantum systems, potentially enabling quantum-aware natural gradient methods for variational quantum circuits with EML-style parameterizations.

**Catalog References**: `EML/QuantumDensityEstimation.lean`, `EML/EMLQuantumHybrid.lean`

**Proof Strategy**:
1. Define the quantum log-partition function Ψ_Q(a,b) = log Tr(exp(aH₁ + b·log(H₂+I))).
2. The SLD Fisher information is the Hessian of Ψ_Q (same as classical case for quantum exponential families).
3. Use the Golden-Thompson inequality Tr(e^{A+B}) ≤ Tr(e^A e^B) to bound the curvature.
4. The lower bound follows from Var_ρ(H₁) = Ψ_Q'' ≥ λ_min²·dim by convexity.

**Domain Bridges**: Information Geometry <-> Quantum Information <-> Variational Quantum Algorithms

**Lineage**: Builds on `eml_fisher_ge_one` and the Fisher-Hessian correspondence from this cycle.

**Ambition**: grand_challenge
