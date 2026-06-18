# Future Directions: Neural Network Training as Renormalization Group Flow

## Synthesis

This research cycle established the first rigorous, machine-verified connection between neural network training and renormalization group (RG) flow. The core discovery is that SGD on quadratic loss defines an exact RG flow with computable beta function β(w) = −η(aw − b), geometric convergence governed by a critical exponent ν = −1/log|1 − ηa|, and universality classes determined by sufficient statistics. The framework extends naturally to momentum SGD, multi-dimensional losses, and two-layer linear networks with gauge symmetry.

The most promising cross-domain connection emerging from this cycle is the bridge between the `ClosureFlow`/universality framework in `Bridges/RenormalizationUniversality.lean` and the neural network SGD dynamics formalized here. The `NNClosureRG` structure proves that SGD training with a macroscopic projection operator satisfies the same axioms as the abstract RG flows already cataloged — meaning all theorems about universality classes, quotient monoid descent, and stabilization from the existing catalog apply immediately to neural network training. This bridge has the highest breakthrough potential because it connects a mature algebraic framework (closure semirings, universality quotients) to a concrete application domain (deep learning), enabling transfer of results in both directions.

The key insight for future work is that the linear/quadratic results proved here are the "Gaussian fixed point" of the neural RG — the simplest, most tractable fixed point. The interesting physics (and interesting machine learning) lies at the non-Gaussian fixed points: the Wilson-Fisher fixed point (for finite-width networks), the conformal fixed point (for d = 2 data), and potential new universality classes arising from ReLU nonlinearity.

---

### Direction 1: Non-Gaussian Fixed Points and the Wilson-Fisher Correspondence

**Conjecture**: For a 2-layer ReLU network with width N trained on isotropic Gaussian data in d dimensions, the critical exponent ν of SGD convergence satisfies:

lim_{N→∞} ν_SGD(N, d) = ν_WF(d) = 1/(d − 2) + O(ε²)

where ε = 4 − d and ν_WF is the Wilson-Fisher critical exponent of the d-dimensional Ising model.

**Test**: For d = 3, train 2-layer ReLU networks with widths N = 100, 500, 1000, 5000 on isotropic unit-Gaussian data with linear target. Measure convergence rate of SGD to the trained fixed point. Extract ν_SGD by fitting |w_n − w*| ∼ exp(−n/ν). Plot ν_SGD vs 1/N and extrapolate to N = ∞. The Wilson-Fisher prediction is ν ≈ 0.63 for d = 3. If the extrapolated value differs by more than 10%, the conjecture is falsified.

**Impact**: If true, this establishes neural networks as a physical system in the Ising universality class, transferring all known scaling relations (α + 2β + γ = 2, hyperscaling, etc.) to learning theory. If false, it identifies neural networks as defining a genuinely new universality class with novel critical exponents.

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (universality quotient, closure flow), `MachineLearning/NeuralRGFlow.lean` (beta function, geometric convergence), `MachineLearning/TropicalNTKDynamics.lean` (cell structure, NTK invariance)

**Proof Strategy**: 
1. Formalize the 2-layer ReLU network as a concrete `NNClosureRG` with closure operator = effective weight projection.
2. Compute the beta function perturbatively around the Gaussian (linear) fixed point using 1/N expansion.
3. Show that the 1/N correction to the beta function matches the ε-expansion of the Wilson-Fisher beta function β_WF(g) = −εg + Cg² under the identification g ↔ 1/N.
4. The key lemma: prove that the ReLU nonlinearity generates a φ⁴-type interaction at order 1/N.

**Domain Bridges**: Physics (Ising model, Wilson-Fisher) ↔ MachineLearning (SGD, ReLU networks)

**Lineage**: Builds on `geometric_convergence`, `universality_same_trajectory`, and `fixed_point_singleton_class` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Stochastic RG and Mini-batch Noise

**Conjecture**: Mini-batch SGD with batch size B on quadratic loss L(w) = (1/2)aw² − bw + noise defines a stochastic RG flow whose stationary distribution is Gaussian with mean w* = b/a and variance σ²_stationary = ηT/(2 − ηa) where T = variance of gradient noise ~ 1/B.

**Test**: Run mini-batch SGD on quadratic loss with different batch sizes B ∈ {1, 10, 100, 1000}. Measure the stationary variance of w around w*. Compare to the prediction σ² = ηT/(2 − ηa). Falsifiable if the measured variance deviates systematically from the prediction.

**Impact**: This connects SGD noise to thermal fluctuations in the RG framework. The "temperature" T ~ 1/B provides a natural regularization, and the stationary distribution gives a Bayesian interpretation of SGD training. The framework would explain why small batch sizes generalize better (higher temperature → exploring more of the loss landscape).

**Catalog References**: `MachineLearning/NeuralRGFlow.lean` (QuadraticLoss1D, sgdStep), `Bridges/RenormalizationUniversality.lean` (ClosureFlow, AsymptoticCong)

**Proof Strategy**:
1. Define a stochastic variant of `NeuralRGFlow` with noise term: step(θ) = θ − η(grad(θ) + ξ) where ξ ~ N(0, T/η).
2. For quadratic loss, show the update is a linear stochastic recurrence w_{n+1} = (1−ηa)w_n + ηb + ηξ_n.
3. Prove the stationary distribution exists iff |1−ηa| < 1 (contraction condition) and compute its mean and variance.
4. Key lemma: the variance of the stationary distribution diverges as η → 2/a, analogous to divergence of susceptibility at a phase transition.

**Domain Bridges**: Physics (statistical mechanics, fluctuation-dissipation) ↔ MachineLearning (mini-batch SGD, generalization)

**Lineage**: Builds on `contraction_factor_lt_one` and `geometric_convergence` from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical RG Flow and Piecewise-Linear Networks

**Conjecture**: For ReLU networks, the RG flow is piecewise-linear on the tropical cell decomposition of parameter space. Within each tropical cell, the beta function is affine, and cell crossings correspond to phase transitions of the RG flow.

**Test**: For a 2-layer ReLU network with d = 2 inputs and m = 4 hidden units, explicitly compute the tropical cell decomposition of parameter space. Run SGD from 100 random initializations and count how many cell crossings occur before convergence. Conjecture: the number of cell crossings scales as log(1/ε) where ε is the final loss, and each crossing changes the universality class.

**Impact**: This would provide an exact, combinatorial description of feature learning (= cell crossings in the tropical decomposition). The tropical RG flow would be computable in closed form on each cell, reducing the analysis of deep learning to combinatorial geometry.

**Catalog References**: `MachineLearning/TropicalNTKDynamics.lean` (SameTropicalCell, TropicalFlatDirection, cellwise-constant kernels), `MachineLearning/NeuralRGFlow.lean` (NNClosureRG, beta function)

**Proof Strategy**:
1. Use the tropical cell structure from `TropicalNTKDynamics` to decompose the SGD trajectory into segments within each cell.
2. On each cell, the ReLU network is linear, so the results of this cycle (geometric convergence, beta function) apply exactly.
3. At cell boundaries, prove that the beta function is continuous but its derivative jumps — a first-order phase transition.
4. Key lemma: the number of cell crossings in an SGD trajectory is bounded by the number of tropical cells, which is bounded by O(mᵈ).

**Domain Bridges**: Tropical (cell decomposition, piecewise-linear) ↔ MachineLearning (ReLU, feature learning) ↔ Physics (phase transitions)

**Lineage**: Builds on `tropical_ntk_constant_along_flat_directions` from TropicalNTKDynamics and `sgd_fixed_iff_critical` from this cycle.

**Ambition**: extension

---

### Direction 4: Conformal Symmetry at d = 2

**Conjecture**: For d = 2 (the marginal dimension), the SGD RG flow of a 2-layer network exhibits logarithmic corrections to scaling — the hallmark of conformal symmetry. Specifically, the distance to the fixed point decays as |w_n − w*| ∼ 1/(n·log(n)) rather than geometrically.

**Test**: Train 2-layer networks on d = 2 isotropic data with varying widths. Measure the decay of |w_n − w*| and fit to both geometric (exp(−n/ν)) and logarithmic (1/(n·log(n))) decay models. At d = 2, the logarithmic model should provide a better fit. Compare fit quality using BIC.

**Impact**: Conformal symmetry at d = 2 would connect neural network training to conformal field theory (CFT), one of the most powerful and well-understood frameworks in theoretical physics. CFT provides exact solutions, operator algebras, and modular invariance that could give closed-form results for training dynamics.

**Catalog References**: `MachineLearning/NeuralRGFlow.lean` (wilsonFisherExponent, geometric_convergence), `EML/ModularForms.lean` (modular symmetry)

**Proof Strategy**:
1. Show that the Wilson-Fisher exponent ν = 1/(d−2) diverges at d = 2.
2. Compute the next-order correction in the ε-expansion at ε = 2, showing it gives logarithmic terms.
3. Formalize the BKT (Berezinskii-Kosterlitz-Thouless) transition scenario: the beta function has a double zero at the fixed point, leading to logarithmic rather than algebraic approach.
4. Key lemma: for the 1D quadratic loss at η = 1/a (the critical learning rate where contraction factor = 0), the system reaches the fixed point in exactly one step — this is the d → ∞ limit. Show that as d decreases toward 2, the approach becomes progressively slower, diverging logarithmically at d = 2.

**Domain Bridges**: Physics (CFT, BKT transition) ↔ MachineLearning (SGD dynamics) ↔ EML (modular forms)

**Lineage**: Builds on `wilsonFisherExponent`, `criticalExponent`, and `optimal_spectral_gap_zero` from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Closure-Semiring Structure of Training Dynamics

**Conjecture**: The set of SGD fixed points of a neural network, equipped with the operations inherited from the closure flow monoid structure, forms a closure semiring. The RG quotient of parameter space by the universality class equivalence relation carries a natural semiring structure where multiplication corresponds to network composition and addition corresponds to ensemble averaging.

**Test**: Construct two concrete `NNClosureRG` instances: (1) a 1D quadratic SGD flow with closure = identity, and (2) a 2D quadratic SGD flow with closure = projection to first component. Verify that the quotient monoid from `quotient_monoid_descent` (in `RenormalizationUniversality.lean`) inherits the expected algebraic structure. Falsifiable if the quotient fails to satisfy the semiring axioms.

**Impact**: This would establish that neural network training has the same algebraic structure as renormalization in quantum field theory and error-correcting codes, opening a three-way bridge between physics, ML, and coding theory.

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (ClosureFlowMonoid, ClosureFlowSemiring, quotient_monoid_descent, universality quotient), `MachineLearning/NeuralRGFlow.lean` (NNClosureRG, NNUniversalityClass)

**Proof Strategy**:
1. Extend `NNClosureRG` to `NNClosureFlowMonoid` by defining multiplication as network composition: (W₁, v₁) * (W₂, v₂) = composed network.
2. Show step is a monoid homomorphism: step(θ₁ * θ₂) = step(θ₁) * step(θ₂).
3. Show closure distributes over multiplication: cl(θ₁ * θ₂) = cl(cl(θ₁) * cl(θ₂)).
4. Apply `quotient_monoid_descent` to get the quotient monoid structure on universality classes.
5. Define addition as ensemble averaging and verify the semiring axioms.

**Domain Bridges**: Algebra (closure semirings) ↔ MachineLearning (network composition) ↔ Bridges (RG universality)

**Lineage**: Builds on `nnUniversalityClass_trans`, `fixed_point_singleton_class`, and `quotient_monoid_descent` from RenormalizationUniversality.

**Ambition**: extension
