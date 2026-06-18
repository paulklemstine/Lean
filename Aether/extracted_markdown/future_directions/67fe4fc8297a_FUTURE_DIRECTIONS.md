# Future Research Directions: Neural Scaling Laws from Statistical Mechanics

## Synthesis

This research cycle established a rigorous mathematical foundation for neural network scaling laws, proving that the compute-optimal scaling exponent is the harmonic mean of the data and parameter scaling exponents: γ = αβ/(α+β). We formalized the full chain from spectral decay of kernel eigenvalues (λ_k ∼ k^{-s}) through the spectral-to-scaling map (α = (s-1)/s) to the harmonic composition law, along with the balanced allocation theorem (α·R_N = β·R_P at optimality) and the bottleneck principle.

The most promising cross-domain connection is between the harmonic mean structure of scaling laws and the parallel-channel structures that appear throughout the Catalog — particularly in the EML framework's ensemble complexity theory (`EML/AdvancedTheory.lean`: `ensemble_complexity_additive`) and in cryptographic kernel hiding theorems (`Cryptography/CohomologicalCrypto/Foundation.lean`: `hiding_from_kernel_size`). The harmonic mean arises whenever two independent "channels" or "resources" compete under a shared budget constraint, and this pattern is ubiquitous in information theory, statistical mechanics, and algebraic complexity.

The direction with highest breakthrough potential is Direction 1 (Multi-Resource Scaling Laws), because extending from 2-resource to k-resource scaling would provide a complete theory for optimizing large-scale AI training across data, parameters, training steps, and batch size simultaneously — a problem of immense practical importance with an elegant mathematical structure.

---

### Direction 1: Multi-Resource Harmonic Scaling Laws

**Conjecture**: For a k-resource scaling law L(x₁,...,xₖ) = Σᵢ Aᵢ · xᵢ^{-αᵢ} + E under the compute constraint ∏ᵢ xᵢ^{wᵢ} = C (where wᵢ are weight exponents), the compute-optimal scaling exponent is the weighted harmonic mean:

γ = (Σᵢ wᵢ)⁻¹ · (Σᵢ wᵢ/αᵢ)⁻¹

For k=2 with w₁=w₂=1, this reduces to γ = αβ/(α+β), recovering our proven result.

**Test**: Verify the formula for k=3 with the constraint N·P·T = C (data × parameters × training steps). Use published 3-way scaling data from Kaplan et al. (2020) to check whether the measured compute exponent matches the predicted 3-way harmonic mean.

**Impact**: A complete multi-resource theory would settle the optimal allocation question for all AI training resources simultaneously, potentially saving billions of dollars in compute by revealing the optimal 4-way split (data, parameters, steps, batch size).

**Catalog References**: `Speculative/AutoResearch/ScalingLaws/Core.lean` (harmonic_exponent_reciprocal, optimal_exponents_sum_to_one), `EML/AdvancedTheory.lean` (ensemble_complexity_additive)

**Proof Strategy**: (1) Define a k-resource `MultiScalingLaw` structure. (2) Apply Lagrange multipliers to the constrained optimization. (3) Show the first-order conditions give αᵢ·Rᵢ = λ·wᵢ·∏xⱼ/xᵢ for all i. (4) Derive the harmonic mean formula by substitution. Key lemma: the KKT conditions for this convex program have a unique solution.

**Domain Bridges**: Statistical Mechanics (partition function optimization) ↔ Machine Learning (compute allocation) ↔ Information Theory (rate-distortion tradeoffs)

**Lineage**: Builds on harmonic_exponent_reciprocal and optimal_exponents_sum_to_one from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Universality Classes for Neural Architectures

**Conjecture**: Neural architectures can be classified into a finite number of "spectral universality classes" based on their NTK eigenvalue decay rate s. Specifically:
- Shallow networks: s = d/2 + 1 (where d is input dimension)
- Deep fully-connected networks: s = d + 1
- Transformers with attention: s = 2 (independent of d)
- Convolutional networks: s depends on kernel size but not depth beyond a critical depth

The conjecture predicts that the data scaling exponent α = (s-1)/s is determined entirely by the universality class, not by specific architectural hyperparameters within a class.

**Test**: Compute NTK eigenvalue spectra numerically for 50+ architectures varying depth, width, activation function, and attention mechanism. Cluster the decay rates and verify that they fall into discrete classes.

**Impact**: Would provide a principled taxonomy of neural architectures based on their learning-theoretic properties, potentially identifying new architecture classes with superior scaling exponents.

**Catalog References**: `Speculative/AutoResearch/ScalingLaws/Core.lean` (spectral_exponent_monotone, spectral_exponent_range, spectral_exponent_limit_is_one)

**Proof Strategy**: (1) Formalize the NTK spectrum for specific architectures using Mercer's theorem. (2) Prove that for ReLU networks, the spectral decay is s = d + 1 for deep networks (using Hermite expansion). (3) Show universality: small perturbations to the architecture don't change s. Key tool: the spectral-to-scaling map's strict monotonicity guarantees distinct exponents for distinct classes.

**Domain Bridges**: Functional Analysis (Mercer's theorem, spectral theory) ↔ Machine Learning (NTK theory) ↔ Statistical Physics (universality classes, renormalization group)

**Lineage**: Builds on spectral_exponent_monotone and spectral_exponent_range from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Phase Transitions in Scaling Law Exponents

**Conjecture**: The scaling exponents (α, β) undergo discrete phase transitions as a function of the task complexity measure τ (e.g., the number of distinct reasoning steps required). Specifically, for language modeling:
- Below a critical complexity τ_c: α ≈ 0.5, β ≈ 0.5 (memorization regime)
- Above τ_c: α ≈ 0.33, β ≈ 0.33 (generalization regime)
- Near τ_c: the exponents exhibit critical scaling with universal critical exponents

**Test**: Train 100+ language models on datasets of varying complexity (simple facts vs. multi-step reasoning) and measure (α, β) for each. Plot the exponents as a function of τ and look for discontinuities.

**Impact**: Would explain why different benchmarks show different scaling behaviors and predict when scaling laws "break" — a critical question for AI safety and capability forecasting.

**Catalog References**: `Speculative/AutoResearch/ScalingLaws/Core.lean` (harmonic_exponent_lt_min, harmonic_eq_arithmetic_iff), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: (1) Model the task as a mixture of sub-problems with different spectral properties. (2) Show that the effective exponent is dominated by the hardest sub-problem as scale increases. (3) Prove that the crossover between regimes occurs at a sharp threshold (using large deviation theory). Key lemma: harmonic_mono_left implies the effective exponent decreases as harder sub-problems are added.

**Domain Bridges**: Statistical Physics (phase transitions, critical phenomena) ↔ Machine Learning (scaling regimes) ↔ Complexity Theory (computational phase transitions)

**Lineage**: Builds on harmonic_mono_left and harmonic_exponent_lt_min from this cycle. Connects to `Computation/InfoEfficientAlgorithms.lean`.

**Ambition**: extension

---

### Direction 4: Tropical Geometry of Loss Landscapes and Scaling

**Conjecture**: The piecewise-linear structure of ReLU networks creates a tropical geometric structure in the loss landscape, and the scaling exponents can be read off from the Newton polytope of the tropical loss function. Specifically, the data scaling exponent α equals the codimension of the dominant face of the Newton polytope divided by the ambient dimension.

**Test**: Compute the tropical variety of the loss function for small ReLU networks (2-3 layers, <100 parameters) and verify that the Newton polytope face dimensions match the empirically measured scaling exponents.

**Impact**: Would connect two of the Catalog's strongest themes — tropical geometry and machine learning — providing a completely new geometric interpretation of scaling laws.

**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalProofSemantics.lean` (size_pos), `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (valuation_prime_power), `Speculative/AutoResearch/ScalingLaws/Core.lean` (PowerLawScaling, spectralToScalingExponent)

**Proof Strategy**: (1) Represent the ReLU network loss as a tropical polynomial. (2) Compute the Newton polytope and its face structure. (3) Relate face codimension to the effective dimension of the learned representation. (4) Show that this effective dimension determines the scaling exponent via the spectral-to-scaling map.

**Domain Bridges**: Tropical Geometry (Newton polytopes, tropical varieties) ↔ Machine Learning (ReLU networks, loss landscapes) ↔ Algebraic Geometry (toric varieties, moment maps)

**Lineage**: Builds on tropical formalization in `TropicalProofSemantics.lean` and scaling framework from this cycle.

**Ambition**: extension

---

### Direction 5: Information-Theoretic Lower Bounds on Scaling Exponents

**Conjecture**: For any learning algorithm (not just kernel methods), the scaling exponent satisfies α ≤ (d-1)/d where d is the intrinsic dimension of the data manifold. This would be a fundamental information-theoretic limit, independent of the algorithm.

Furthermore, the compute scaling exponent satisfies γ ≤ (d-1)/(2d), achieved when α = β = (d-1)/d (both resources scale at the information-theoretic limit).

**Test**: Measure the intrinsic dimension of standard datasets (CIFAR, ImageNet, text corpora) using nearest-neighbor methods, then verify that no learning algorithm achieves a scaling exponent exceeding (d-1)/d.

**Impact**: Would establish absolute limits on how fast AI can improve with scale, with profound implications for AI forecasting and the "diminishing returns" debate.

**Catalog References**: `Speculative/AutoResearch/ScalingLaws/Core.lean` (spectral_exponent_range, variance_upper_bound), `Speculative/AutoResearch/MachineLearning/PACBayes/KLProperties.lean` (risk_bound_from_kl_bernoulli)

**Proof Strategy**: (1) Use the minimax theorem to establish a lower bound on the risk for any estimator. (2) Show that the optimal rate is determined by the metric entropy of the function class. (3) Connect metric entropy to intrinsic dimension via covering number bounds. (4) Derive the exponent bound α ≤ (d-1)/d from the entropy scaling. Key tool: Fano's inequality and the risk_bound_from_kl_bernoulli theorem.

**Domain Bridges**: Information Theory (Fano's inequality, metric entropy) ↔ Machine Learning (minimax rates) ↔ Differential Geometry (manifold dimension) ↔ PAC-Bayes theory

**Lineage**: Builds on variance_upper_bound and spectral_exponent_range from this cycle, and risk_bound_from_kl_bernoulli from existing catalog.

**Ambition**: extension
