# Future Directions: Neural Network Training as Renormalization Group Flow

## 1. Spectral Universality for Nonlinear RG Flows

The current `commuting_contractions_same_fixedPoint` theorem establishes universality for *linear* (contracting) flows. The key insight is that for *nonlinear* flows with a hyperbolic fixed point, the Hartman–Grobman theorem guarantees that the local dynamics is topologically conjugate to the linearization — meaning the critical exponents (eigenvalues of the Jacobian at the fixed point) classify the universality class even in the nonlinear setting.

**Conjecture**: For a C¹ self-map T on a Banach space with a hyperbolic fixed point x* (all eigenvalues of DT(x*) have modulus ≠ 1), the local topological type of the dynamics is determined entirely by the number of eigenvalues inside and outside the unit circle. Two such maps with the same spectral partition are locally topologically conjugate.

**Why now?** Mathlib now has Fréchet derivatives (`HasFDerivAt`) and the spectral theory of bounded operators is developing. The finite-dimensional Hartman–Grobman theorem is within reach of formalization using the contraction mapping theorem on function spaces (the "graph transform" proof). This would give a rigorous foundation for the claim that neural network training dynamics near convergence is governed by universality classes.

## 2. RG Flow on Reproducing Kernel Hilbert Spaces (Neural Tangent Kernel)

The Neural Tangent Kernel (NTK) K(x,y) governs the training dynamics of infinitely wide neural networks. At the NTK fixed point, the kernel satisfies a self-consistency equation K = Φ(K) where Φ is determined by the activation function. The key insight is that this self-consistency equation IS an RG fixed-point equation, and our `affineMap_fixedPt_eq` theorem captures the linearized version.

**Conjecture**: For networks with ReLU activation trained on isotropic data on S^{d-1}, the NTK fixed-point kernel K*(x,y) = F(x·y) satisfies F(t) = c₀ + c₁·t + c₂·(π - arccos(t))/π for explicit constants c₀, c₁, c₂ depending on d. The map Φ is contracting on the space of positive-definite kernels on S^{d-1} with respect to the operator norm, with contraction constant K = 1/√(2π) < 1.

**Why now?** The explicit NTK computation for ReLU networks is known (Cho & Saul 2009, Daniely et al. 2016). Formalizing it requires arc-cosine kernel computations on spheres, which are now approachable given Mathlib's integration and special function support.

## 3. Beta Function Gradient Flow and Lyapunov Theory

Our `beta_eq_zero_iff` theorem characterizes fixed points as zeros of the beta function β(x) = T(x) - x. The key insight is that for gradient descent T(x) = x - η∇L(x), we have β(x) = -η∇L(x), so the loss function L itself is a Lyapunov function for the beta-function flow — the beta function always points "downhill" in L.

**Conjecture**: For a μ-strongly convex, L-smooth loss function with η < 2/L, the RG flow T(x) = x - η∇L(x) satisfies: (a) L is a strict Lyapunov function (L(T(x)) < L(x) for x ≠ x*), (b) the convergence rate is geometric with exponent (1 - ημ)², and (c) the "anomalous dimension" η_anom = -log(1 - ημ)/log(scale) determines the universality class.

**Why now?** Mathlib has extensive convexity theory (`StronglyConvex`, `LipschitzWith` for gradients). The geometric convergence rate for strongly convex optimization is a well-known result that should be formalizable by extending our `contracting_orbit_dist_bound` with explicit Lipschitz constants from convexity assumptions.

## 4. Composition of Coarse-Graining: The RG Semigroup

Our semiconjugacy results show that fixed points are preserved under a single coarse-graining map. The key insight is that the *composition* of coarse-graining maps at different scales forms a semigroup, and the fixed points of this semigroup are the truly scale-invariant objects — the conformal field theories in physics, or the "emergent features" learned by deep networks.

**Conjecture**: Let {C_ε}_{ε>0} be a one-parameter family of contracting maps on a complete metric space with C_ε ∘ C_δ = C_{ε+δ} (semigroup property). Then (a) all C_ε share the same unique fixed point x*, and (b) the convergence rate of C_ε to x* is O(e^{-λε}) for a universal exponent λ independent of the initial condition — this λ is the "mass gap" of the RG flow.

**Why now?** This is a direct generalization of `commuting_contractions_same_fixedPoint` from two commuting maps to a continuous semigroup. Mathlib has semigroup theory and one-parameter semigroups (`OneSemigroup`). The mass gap computation connects to spectral theory of the generator of the semigroup.

## 5. Multi-Scale Universality: Hierarchical RG and Deep Networks

Deep networks have a natural hierarchical structure: layer l computes features at "scale l". The key insight is that a deep network with L layers implements L successive coarse-graining steps, and the entire network is a composition C_L ∘ ··· ∘ C_1 of RG transformations — each layer integrates out features at one scale.

**Conjecture**: For a deep linear network with weight matrices W_1, ..., W_L of decreasing rank (rank(W_l) ≥ rank(W_{l+1})), the product W_L···W_1 converges to a rank-1 matrix as L → ∞ (the "infrared limit"). The rate of convergence is determined by the ratio of the two largest singular values of the individual matrices, σ₂/σ₁, which plays the role of the "relevant coupling" in RG theory.

**Why now?** This connects to the well-studied theory of products of random matrices (Furstenberg, Oseledets). The singular value analysis of deep linear networks has been carried out by Saxe et al. (2014) and Arora et al. (2018). Formalizing the convergence of matrix products to rank-1 projectors is achievable with Mathlib's SVD-adjacent linear algebra (singular values, spectral theory of compact operators).
