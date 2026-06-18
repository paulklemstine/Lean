# Future Directions: Spectral Scaling Laws

## Synthesis

This research cycle established the **Spectral Learning Model** as a rigorous mathematical framework for neural network scaling laws, proving 19 theorems connecting eigenvalue spectra to loss scaling. The central achievement is the **Loss-Compute AM-GM Bound** (L ≥ 2√(Bσ²/C)), which derives power-law scaling from the bias-variance tradeoff. The spectral effective dimension was introduced as a novel order parameter that detects the phase transition between data-efficient and variance-dominated learning regimes.

The most promising cross-domain connection is the **statistical mechanics bridge**: the spectral partition function Z(N) = Σ_{k<N} λ_k is mathematically isomorphic to a canonical partition function, with model capacity playing the role of inverse temperature. This connection—formalized through partition subadditivity and energy conservation—suggests that scaling law universality classes are classified by spectral decay exponents, just as critical phenomena are classified by critical exponents. The partition subadditivity theorem constrains the growth rate of effective dimension, which controls the transition between scaling regimes.

The highest breakthrough potential lies in **Direction 1 (Power-Law Spectral Scaling)**, because it would bridge the gap between our geometric spectrum results (which give exponential, not power-law, bias decay) and the power-law scaling observed empirically. This requires formalizing integral comparison bounds in Lean, connecting to Mathlib's analysis library. **Direction 3 (Spectral Phase Transitions)** offers the deepest conceptual novelty—formalizing the critical point where d(Bias)/dN = d(Var)/dN as a phase transition with a rigorous order parameter.

---

### Direction 1: Power-Law Spectral Scaling Bounds via Integral Comparison

**Conjecture**: For a power-law spectrum with eigenvalues λ_k = (k+1)^{-α} and target energies a_k = (k+1)^{-α} (natural alignment), the truncation bias satisfies:

Bias(N) = Σ_{k≥N} (k+1)^{-α} ≤ N^{-(α-1)} / (α-1) for α > 1

and the compute-optimal loss scales as L*(C) ~ C^{-(α-1)/(α+1)}.

**Test**: Numerically compute Bias(N) for α ∈ {1.5, 2.0, 3.0} and N ∈ {10, 100, 1000}. Verify the ratio Bias(N) · N^{α-1} · (α-1) converges to 1. For α=2, verify the compute-optimal exponent is -(2-1)/(2+1) = -1/3 by fitting log-log slopes.

**Impact**: This would complete the connection from spectral decay to scaling exponents, giving a precise formula α_scaling = (α_spectral - 1)/(α_spectral + 1) for the compute scaling exponent. The specific prediction α_scaling = 1/3 for α_spectral = 2 can be tested against empirical Chinchilla exponents.

**Catalog References**: `Shared/SpectralScaling/Defs.lean`, `Shared/SpectralScaling/ScalingLaws.lean`

**Proof Strategy**: The key lemma is an integral comparison: Σ_{k≥N} k^{-α} ≤ ∫_N^∞ x^{-α} dx = N^{-(α-1)}/(α-1). In Mathlib, use `MeasureTheory.integral_comp_rpow_Ioi` or construct the comparison directly via `Antitone.sum_le_integral`. Then optimize L(N) = C₁·N^{-(α-1)} + C₂·N/D subject to N·D = C using Lagrange multipliers or direct calculus.

**Domain Bridges**: MachineLearning (scaling_laws) <-> Analysis (integral_comparison) <-> Physics (critical_exponents)

**Lineage**: Builds on `SpectralScaling.loss_compute_amgm` and `SpectralScaling.geom_partial_sum` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Data Processing Inequality

**Conjecture**: For a composition of spectral learning models (e.g., layers in a deep network), the effective dimension is non-increasing: if f = g ∘ h where g has effective dimension d_g and h has effective dimension d_h, then the composed model's effective dimension satisfies d_f ≤ min(d_g, d_h).

This would be the spectral analogue of the data processing inequality (DPI) from information theory, formalized in `Shared/CrossDomainBridges.lean` as `neural_data_processing`.

**Test**: Construct two spectral models with known effective dimensions (e.g., geometric spectra with rates r₁=0.5 and r₂=0.8). Compose them by taking the product spectrum λ_k = λ_k^{(1)} · λ_k^{(2)}. Verify d_eff of the product ≤ min(d_eff₁, d_eff₂) for all N ∈ {1, ..., 100}.

**Impact**: Would provide a formal foundation for the "information bottleneck" theory of deep learning, explaining why deeper networks can be more efficient—they compress the effective dimension at each layer.

**Catalog References**: `Shared/CrossDomainBridges.lean` (neural_data_processing), `Shared/SpectralScaling/ScalingLaws.lean` (effDim_le_N)

**Proof Strategy**: Define spectrum composition via pointwise product or convolution. Use the bound d_eff ≤ N together with antitone ordering of composed eigenvalues. The key lemma is that product of antitone sequences is antitone, and the composed partition function is bounded by the minimum of the factors.

**Domain Bridges**: MachineLearning (deep_networks) <-> InformationTheory (data_processing) <-> SpectralTheory (eigenvalue_composition)

**Lineage**: Builds on `SpectralScaling.effDim_le_N` and `neural_data_processing` from the Catalog.

**Ambition**: extension

---

### Direction 3: Spectral Phase Transitions and Critical Exponents

**Conjecture**: For a one-parameter family of spectra λ_k(α) = (k+1)^{-α}, there exists a critical exponent α_c = 1 such that:
- For α > 1: the spectral partition function Z(N) converges as N → ∞ (learnable regime)
- For α ≤ 1: Z(N) → ∞ as N → ∞ (unlearnable regime)

At the critical point α = 1, the effective dimension grows logarithmically: d_eff(N) ~ log(N).

**Test**: Compute d_eff(N) for α ∈ {0.5, 0.8, 1.0, 1.2, 2.0} and N up to 10⁶. Verify:
- α=0.5: d_eff grows as N^{0.5} (power-law divergence)
- α=1.0: d_eff grows as log(N) (critical, logarithmic)
- α=2.0: d_eff saturates (subcritical, convergent)

**Impact**: This would establish a formal analogy between learning theory and phase transitions, with α playing the role of temperature. The critical exponent α_c = 1 separates learnable from unlearnable problems, providing a rigorous complexity measure for learning tasks.

**Catalog References**: `Shared/SpectralScaling/ScalingLaws.lean` (spectralPartition_mono, partition_subadditive_shift, effDim_le_N)

**Proof Strategy**: The convergence/divergence at α = 1 follows from the integral test for series convergence: Σ k^{-α} converges iff α > 1. Formalize using Mathlib's `Real.summable_nat_rpow` or construct the integral test from `Antitone.tendsto_sum_range_iff`. For the logarithmic growth at criticality, use Euler-Mascheroni constant bounds: Σ_{k=1}^{N} 1/k = ln(N) + γ + O(1/N).

**Domain Bridges**: MachineLearning (scaling_laws) <-> Analysis (series_convergence) <-> Physics (phase_transitions) <-> NumberTheory (harmonic_numbers)

**Lineage**: Builds on `SpectralScaling.spectralPartition_mono` and the geometric spectrum results from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Bayesian Spectral Scaling with Prior-Posterior Interplay

**Conjecture**: If the prior distribution over target functions assigns energy a_k^{prior} = λ_k (the Bayesian natural prior), then the posterior truncation bias after observing D data points satisfies:

Bias_posterior(N, D) = Σ_{k≥N} λ_k² / (λ_k + σ²/D)

This interpolates between the prior bias Σ_{k≥N} λ_k (D=0) and the noise floor σ²M/D (D→∞), and yields a sharper scaling law than the AM-GM bound.

**Test**: For geometric spectrum r=0.9, σ²=0.01, compare Bias_posterior vs truncBias at D ∈ {100, 1000, 10000}. Verify that Bias_posterior is always ≤ truncBias (the Bayesian posterior is never worse).

**Impact**: Would unify the spectral scaling framework with Bayesian learning theory, potentially explaining why neural networks often beat the AM-GM bound in practice—their implicit Bayesian regularization provides a tighter effective bias.

**Catalog References**: `Shared/SpectralScaling/Defs.lean` (SpectralLearningModel), `Shared/EntropyAlgebra.lean` (regularizer_loss_bound)

**Proof Strategy**: Define posterior bias using the Bayesian ridge regression formula. The key inequality Bias_posterior ≤ Bias follows from λ_k²/(λ_k + σ²/D) ≤ λ_k (since λ_k ≥ 0 and σ²/D ≥ 0). For the scaling law, optimize over N using calculus with the modified bias formula.

**Domain Bridges**: MachineLearning (Bayesian_learning) <-> Statistics (posterior_contraction) <-> SpectralTheory (eigenvalue_shrinkage)

**Lineage**: Builds on `SpectralScaling.truncBias_antitone` and `regularizer_loss_bound` from the Catalog.

**Ambition**: extension

---

### Direction 5: Multi-Task Spectral Scaling and Transfer Learning

**Conjecture**: For K related learning tasks sharing a common spectral basis but with different target energies {a_k^{(j)}}_{j=1}^{K}, the multi-task learning loss satisfies:

L_multi(N, D₁, ..., D_K) ≤ (1/K) Σ_j L_single(N, D_j) - Δ

where Δ ≥ 0 is a "transfer benefit" that depends on the alignment between tasks (correlation of target energies). When tasks are perfectly aligned (a^{(j)} ∝ a^{(1)} for all j), Δ = (K-1)/K · Var, saving nearly all variance.

**Test**: Generate K=5 tasks with geometric spectra sharing rate r=0.8 but with target energies randomly rotated by angle θ. Plot L_multi vs L_single_avg as a function of θ ∈ [0, π/2]. Verify Δ > 0 when θ < π/4 and Δ ≈ 0 when θ ≈ π/2.

**Impact**: Would provide a theoretical foundation for transfer learning scaling laws, predicting when and by how much multi-task training improves over single-task training. This connects to the empirical observation that foundation models benefit from diverse training tasks.

**Catalog References**: `Shared/SpectralScaling/ScalingLaws.lean` (energy_conservation, loss_compute_amgm)

**Proof Strategy**: Define multi-task loss as average bias plus shared variance (since modes are shared). The transfer benefit Δ arises from variance reduction: K tasks with the same mode each contribute D_j/K effective samples, giving total D_total = Σ D_j. Use Jensen's inequality for the convexity of the variance term.

**Domain Bridges**: MachineLearning (transfer_learning) <-> Statistics (multi-task_estimation) <-> SpectralTheory (shared_eigenbasis)

**Lineage**: Builds on `SpectralScaling.energy_conservation` and `SpectralScaling.loss_compute_amgm` from this cycle.

**Ambition**: extension
