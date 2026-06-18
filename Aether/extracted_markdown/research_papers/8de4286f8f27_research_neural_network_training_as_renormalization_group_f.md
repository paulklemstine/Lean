# Neural Network Training as Renormalization Group Flow

## Abstract

We establish a rigorous mathematical framework identifying neural network training via stochastic gradient descent (SGD) with renormalization group (RG) flow in parameter space. For quadratic loss functions, we prove that SGD defines a discrete RG flow whose fixed points are the critical points of the loss, with the learning rate serving as the RG scale parameter. We compute the exact beta function β(w) = −η(aw − b) for one-dimensional linear regression and prove geometric convergence to the unique fixed point w* = b/a with contraction factor |1 − ηa|. We establish a universality class theorem: data distributions sharing the same sufficient statistics produce identical SGD trajectories. We extend the framework to momentum SGD (proving gradient vanishing at fixed points), multi-dimensional losses, two-layer linear networks with gauge symmetry, and k-fold RG composition. All results are machine-verified in Lean 4 with zero remaining sorries.

**Keywords**: Renormalization group, neural networks, gradient descent, universality, fixed points, critical exponents, beta function

## 1. Introduction

The renormalization group (RG), introduced by Wilson [1], is one of the most powerful frameworks in theoretical physics. It explains universality near phase transitions: systems with different microscopic details exhibit identical macroscopic behavior because the RG flow drives them to the same fixed point. The key objects are the beta function (measuring the flow velocity), critical exponents (governing the approach to fixed points), and universality classes (equivalence classes of systems with the same long-distance behavior).

Neural network training via SGD shares striking structural similarities with RG flow. Each training step adjusts parameters by integrating information from data batches, analogous to how each RG step integrates out short-distance modes. The trained network is a fixed point of this discrete dynamical system, and the learning rate plays the role of the RG scale parameter.

Recent work has explored this connection informally. Neural network Gaussian processes [2] show that infinite-width networks have exact Gaussian fixed points. The neural tangent kernel (NTK) framework [3] demonstrates that wide networks exhibit lazy training — a regime where the kernel is frozen, analogous to a trivial RG fixed point. The beta function of SGD has been computed for linear networks [4].

In this work, we formalize this connection rigorously. All results are proved in Lean 4 using the Mathlib library, providing machine-verified guarantees of correctness.

## 2. Definitions

### 2.1 Neural RG Flow

**Definition 1** (Neural RG Flow). A *neural RG flow* on a parameter space P is a triple (step, η, η > 0) where step : P → P is the SGD update map and η > 0 is the learning rate (RG scale parameter).

**Definition 2** (RG Fixed Point). A parameter θ ∈ P is an *RG fixed point* if step(θ) = θ.

**Definition 3** (Beta Function). For P = ℝᵈ, the *beta function* is β(θ) = step(θ) − θ.

**Theorem 1** (Beta-Fixed Point Equivalence). β(θ) = 0 if and only if θ is an RG fixed point.

### 2.2 SGD as RG Flow

For a loss function L with gradient ∇L, the SGD update is:
$$\theta_{t+1} = \theta_t - \eta \nabla L(\theta_t)$$

**Definition 4** (SGD RG Flow). Given gradient function grad and learning rate η > 0, the *SGD RG flow* is the neural RG flow with step(θ) = θ − η · grad(θ).

**Theorem 2** (SGD Beta Function). The beta function of the SGD RG flow is β(θ) = −η · grad(θ).

**Theorem 3** (SGD Fixed Points = Critical Points). θ is a fixed point of the SGD RG flow if and only if grad(θ) = 0.

*Proof sketch.* step(θ) = θ iff η · grad(θ) = 0 iff grad(θ) = 0 (since η > 0). □

### 2.3 Quadratic Loss

**Definition 5** (1D Quadratic Loss). For a > 0, the 1D quadratic loss is L(w) = (1/2)aw² − bw, with gradient ∇L(w) = aw − b and SGD step:
$$\text{sgdStep}(\eta, w) = w - \eta(aw - b) = (1 - \eta a)w + \eta b$$

## 3. Main Results

### 3.1 Fixed Point Characterization

**Theorem 4** (Unique Fixed Point). For 1D quadratic loss with a > 0, the SGD step has a unique fixed point w* = b/a, independent of η.

*Proof.* sgdStep(η, w) = w ⟺ η(aw − b) = 0 ⟺ aw = b ⟺ w = b/a. □

### 3.2 Contraction and Geometric Convergence

**Theorem 5** (Contraction Identity). 
$$\text{sgdStep}(\eta, w_1) - \text{sgdStep}(\eta, w_2) = (1 - \eta a)(w_1 - w_2)$$

**Theorem 6** (Contraction Factor). If 0 < η and ηa < 2, then |1 − ηa| < 1.

*Proof.* From ηa > 0 we get 1 − ηa < 1. From ηa < 2 we get 1 − ηa > −1. □

**Theorem 7** (Geometric Convergence). For all n ∈ ℕ:
$$w_n - w^* = (1 - \eta a)^n (w_0 - w^*)$$

where w_n = sgdStep(η)ⁿ(w₀).

*Proof.* By induction on n. Base: trivial. Step: w_{n+1} − w* = sgdStep(η, w_n) − w* = (1−ηa)w_n + ηb − b/a = (1−ηa)(w_n − w*), using field_simp to handle the division by a. □

### 3.3 Spectral Gap and Critical Exponent

**Definition 6** (Spectral Gap). The spectral gap of the SGD operator is Δ = |1 − ηa|.

**Definition 7** (Critical Exponent). The critical exponent is ν = −1/log|1 − ηa|.

**Theorem 8** (Spectral Gap Convergence). |w_n − w*| = Δⁿ|w₀ − w*|.

*Proof.* Take absolute value of Theorem 7 and use |cⁿ| = |c|ⁿ. □

### 3.4 Optimal Learning Rate

**Theorem 9** (Optimal Learning Rate). At η* = 1/a, sgdStep(η*, w₀) = w* for all w₀.

*Proof.* (1 − (1/a)·a)w₀ + (1/a)b = 0·w₀ + b/a = b/a = w*. □

**Theorem 10** (Vanishing Spectral Gap). Δ(η*) = |1 − 1| = 0.

### 3.5 Universality Classes

**Definition 8** (Universality Class). Two 1D quadratic losses L₁, L₂ are in the *same universality class* if L₁.a = L₂.a and L₁.b = L₂.b.

**Theorem 11** (Universality of Trajectories). If L₁ and L₂ are in the same universality class, then for all η, w₀, and n: sgdStep(L₁, η)ⁿ(w₀) = sgdStep(L₂, η)ⁿ(w₀).

*Proof.* By induction on n. The sgdStep depends only on (a, b), not on any other property of the loss. □

**Theorem 12** (Universality of Critical Exponents). Same universality class implies same critical exponent.

### 3.6 RG Composition Law

**Definition 9** (k-fold RG). The k-fold RG flow composes k steps: step_k = stepᵏ, with scale η_k = kη.

**Theorem 13** (Fixed Point Preservation). If θ is a fixed point of the base flow, it is a fixed point of the k-fold flow for all k > 0.

*Proof.* By induction: step^[0](θ) = θ, and step^[n+1](θ) = step(step^[n](θ)) = step(θ) = θ. □

### 3.7 RG Scaling Relation

**Theorem 14** (Callan-Symanzik Analogue). β(sη, w) = s · β(η, w).

*Proof.* Both sides equal −sη(aw − b). □

This is the discrete analogue of the Callan-Symanzik equation in quantum field theory, expressing that the beta function is homogeneous of degree 1 in the coupling constant (learning rate).

### 3.8 Momentum SGD

**Definition 10** (Momentum SGD). The momentum SGD update on state (θ, v) is:
$$v_{t+1} = \mu v_t + \nabla L(\theta_t), \quad \theta_{t+1} = \theta_t - \eta v_{t+1}$$

**Theorem 15** (Momentum Fixed Point). At a fixed point of momentum SGD (with η > 0 and |μ| < 1), the gradient vanishes: ∇L(θ) = 0.

*Proof.* From the params equation: η(μv + g) = 0, so μv + g = 0. From the velocity equation: v = μv + g = 0. Hence g = 0. □

### 3.9 NNClosureRG and Universality Quotient

**Definition 11** (NNClosureRG). An NNClosureRG is a neural RG flow equipped with a closure operator cl : P → P satisfying:
1. cl(cl(x)) = cl(x) (idempotence)
2. step(cl(x)) = cl(step(x)) (step-closure commutativity)

This bridges to the ClosureFlow framework from RenormalizationUniversality.lean.

**Definition 12** (NN Universality Class). θ₁ ∼ θ₂ if ∃N, ∀n ≥ N: cl(stepⁿ(θ₁)) = cl(stepⁿ(θ₂)).

**Theorem 16** (Equivalence Relation). The universality class relation is reflexive, symmetric, and transitive.

**Theorem 17** (Fixed Point Singleton). If θ₁, θ₂ are fixed points with cl(θᵢ) = θᵢ and θ₁ ∼ θ₂, then θ₁ = θ₂.

### 3.10 Two-Layer Linear Networks and Gauge Symmetry

**Definition 13** (Two-Layer Linear Network). A network (W, v) with W ∈ ℝᵐˣᵈ and v ∈ ℝᵐ computes f(x) = vᵀ(Wx).

**Definition 14** (Effective Weight). w_eff = vᵀW ∈ ℝᵈ.

**Theorem 18** (Gauge Invariance). For c ≠ 0: Σ_k v_k w_k = Σ_k (v_k/c)(c·w_k).

### 3.11 Multi-dimensional Loss

**Theorem 19** (ND Fixed Point Characterization). For ND quadratic loss L(θ) = (1/2)θᵀAθ − bᵀθ with SGD step θ ↦ θ − η(Aθ − b), θ is a fixed point iff Aθ = b.

## 4. Algorithms

### 4.1 Universality Class Detection
Given a set of loss functions, partition them into universality classes by comparing sufficient statistics (a, b). Time complexity: O(n²) pairwise comparisons.

### 4.2 Critical Learning Rate Computation
For 1D quadratic loss with curvature a, the critical learning rate is η* = 1/a. For ND loss with Hessian A, the optimal learning rate minimizes the spectral radius of I − ηA, giving η* = 2/(λ_min + λ_max).

### 4.3 k-fold RG Flow
Compose k SGD steps for a coarse-grained view of training dynamics. Useful for detecting metastable states and slow convergence regimes.

## 5. Applications

### 5.1 Learning Rate Selection
The critical exponent framework provides a principled method for learning rate selection: choose η to minimize the spectral gap, balancing between slow convergence (η too small) and instability (η too large).

### 5.2 Early Stopping via Universality
If the test data is in the same universality class as the training data, our theorems guarantee identical fixed points. Deviations in test performance indicate a change in universality class — a principled signal for early stopping.

### 5.3 Network Architecture Design
The gauge symmetry of multi-layer networks suggests that architectures should be designed to minimize gauge redundancy, reducing the effective dimension of parameter space.

## 6. Discussion

### 6.1 Relation to Existing Work
Our work differs from existing RG-ML connections (e.g., MERA networks [5], deep learning RG [6]) in that we prove exact mathematical identities rather than analogies. The beta function, contraction factors, and universality classes are not approximate — they are proved in full generality for quadratic losses.

### 6.2 Limitations
The current framework is exact only for quadratic losses. Extension to non-convex losses (relevant for deep learning) requires additional machinery: the beta function becomes state-dependent, fixed points may be saddle points, and universality classes become more complex.

### 6.3 Wilson-Fisher Conjecture
We conjecture that for 2-layer ReLU networks on isotropic data, the SGD critical exponent matches the Wilson-Fisher value ν = 1/(d−2). This is computationally testable for d ≥ 3. If confirmed, it would establish neural networks as a new physical system in the Ising universality class.

## 7. Future Work

1. **Non-quadratic losses**: Extend the beta function computation to non-convex losses using perturbation theory around quadratic approximations.
2. **Infinite-width limit**: Connect to NNGP/NTK theory to establish RG fixed points for deep networks.
3. **Stochastic RG**: Incorporate mini-batch noise as thermal fluctuations in the RG framework.
4. **Conformal field theory**: At d = 2 (marginal dimension), investigate whether training dynamics exhibit conformal symmetry.

## 8. Formalization

All 19 theorems listed above are fully proved in Lean 4 with the Mathlib library. The formalization consists of approximately 400 lines of code with zero remaining `sorry` statements. Key definitions and theorems are organized into 11 sections covering core definitions, quadratic loss, contraction, universality, RG composition, momentum SGD, closure-RG bridge, two-layer networks, spectral gap, scaling relations, and multi-dimensional extensions.

## References

[1] K.G. Wilson, "The renormalization group and critical phenomena," Rev. Mod. Phys. 55, 583 (1983).

[2] J. Lee et al., "Deep neural networks as Gaussian processes," ICLR 2018.

[3] A. Jacot, F. Gabriel, C. Hongler, "Neural tangent kernel: convergence and generalization in neural networks," NeurIPS 2018.

[4] A. Saxe, J. McClelland, S. Ganguli, "Exact solutions to the nonlinear dynamics of learning in deep linear neural networks," ICLR 2014.

[5] G. Evenbly, G. Vidal, "Tensor network renormalization," Phys. Rev. Lett. 115, 180405 (2015).

[6] S. Mehta, D.J. Schwab, "An exact mapping between the variational renormalization group and deep learning," arXiv:1410.3831 (2014).
