

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Quantum-Informational Neural Capacity: Von Neumann Effective Rank, Subadditive Depth Certification, and Bures Metric Optimization Convergence

### Core Mathematical Framework

We establish quantum information theory as the natural language for certifying neural network expressivity and optimization. The key insight: any weight matrix $W \in \mathbb{R}^{m \times n}$ induces a density matrix $\rho_W = WW^* / \mathrm{Tr}(WW^*)$, and the full apparatus of quantum information—von Neumann entropy, Bures distance, quantum Fisher information—applies to yield certified, computationally explicit bounds.

### Part I: Density Matrices from Neural Weights and Von Neumann Effective Rank

**Definition: `NeuralDensityMatrix`**
A neural density matrix is the normalization of the Gram matrix of a weight matrix. For $W : \text{Matrix}(\text{Fin } m)(\text{Fin } n)\mathbb{R}$ with $\mathrm{Tr}(WW^*) > 0$, define:
$$\rho_W := \frac{WW^*}{\mathrm{Tr}(WW^*)}$$

In Lean 4:
```lean
/-- A neural density matrix is the Gram normalization of a weight matrix.
    Bridge: connects neural network expressivity to quantum state geometry. -/
structure NeuralDensityMatrix (m n : ℕ) where
  weight : Matrix (Fin m) (Fin n) ℝ
  trace_pos : (weight * weightᵀ).trace > 0

namespace NeuralDensityMatrix

/-- The density matrix ρ_W = WW*/Tr(WW*) -/
def densityMatrix (ρ : NeuralDensityMatrix m n) : Matrix (Fin m) (Fin m) ℝ :=
  (ρ.weight * ρ.weightᵀ) /ᵥ fun _ => (ρ.weight * ρ.weightᵀ).trace

/-- Von Neumann effective rank: d_eff = exp(S(ρ)) where S is von Neumann entropy.
    This interpolates between 1 (degenerate, rank-1) and rank(W) (isotropic).
    Bridge: connects spectral analysis to information-theoretic expressivity. -/
noncomputable def vonNeumannEffectiveRank (ρ : NeuralDensityMatrix m n) : ℝ :=
  Real.exp (vonNeumannEntropy ρ.densityMatrix)
```

**Theorem 1: `von_neumann_effective_rank_bounds`**
```lean
/-- The effective rank d_eff = exp(S(ρ)) satisfies 1 ≤ d_eff ≤ rank(W).
    The lower bound is tight (rank-1 matrices), the upper bound is tight (isotropic matrices).
    Bridge: connects quantum entropy to linear algebraic rank. -/
theorem von_neumann_effective_rank_bounds (ρ : NeuralDensityMatrix m n) :
    1 ≤ ρ.vonNeumannEffectiveRank ∧
    ρ.vonNeumannEffectiveRank ≤ ρ.weight.rank := by
  -- Strategy A: Use concavity of x log x and Jensen's inequality.
  -- The function f(x) = x log x is convex on (0,∞), so -Σ λᵢ log λᵢ ≤ log(Σ λᵢ²/Σ λᵢ²)
  -- actually: S(ρ) ≤ log(rank) by Jensen since log is concave and λᵢ sum to 1.
  -- For lower bound: S(ρ) ≥ 0 since -Σ λᵢ log λᵢ ≥ 0 (Gibbs' inequality).
  -- Strategy B: Direct computation with eigenvalue inequalities.
  -- Strategy A is cleaner: use entropy_maximized_by_uniform and gibbs_inequality.
  sorry -- TODO: implement both strategies
```

**Theorem 2: `effective_rank_eq_rank_iff_isotropic`**
```lean
/-- The effective rank equals the actual rank iff all nonzero eigenvalues are equal
    (isotropic spectrum). This is the quantum analogue of "uniform variance."
    Bridge: connects quantum equipartition to expressivity maximality. -/
theorem effective_rank_eq_rank_iff_isotropic (ρ : NeuralDensityMatrix m n) :
    ρ.vonNeumannEffectiveRank = (ρ.weight.rank : ℝ) ↔
    ∀ i ∈ ρ.nonzeroEigenvalues, ∀ j ∈ ρ.nonzeroEigenvalues, i = j := by
  -- Key insight: S(ρ) = log(rank) iff all nonzero eigenvalues equal 1/rank.
  -- This follows from strict concavity of log: equality in Jensen iff uniform distribution.
  -- Use strict_concavity_log and jensen_equality_condition.
  sorry
```

**Theorem 3: `von_neumann_entropy_concavity`**
```lean
/-- Von Neumann entropy is concave: S(λρ₁ + (1-λ)ρ₂) ≥ λS(ρ₁) + (1-λ)S(ρ₂).
    This means mixing density matrices increases entropy (decreases effective rank).
    Bridge: connects quantum statistical mechanics to neural capacity monotonicity. -/
theorem von_neumann_entropy_concavity (ρ₁ ρ₂ : DensityMatrix m) (λ : ℝ) (hλ : 0 ≤ λ ∧ λ ≤ 1) :
    vonNeumannEntropy (λ • ρ₁.1 + (1 - λ) • ρ₂.1) ≥
    λ * vonNeumannEntropy ρ₁.1 + (1 - λ) * vonNeumannEntropy ρ₂.1 := by
  -- Strategy: Use the variational characterization S(ρ) = inf_σ Tr(ρ log ρ - ρ log σ).
  -- Or: reduce to eigenvalue level using spectral decomposition.
  -- Key lemma: for probability distributions, Shannon entropy is concave.
  -- Use spectral_theorem_self_adjoint and shannon_concavity applied to eigenvalues.
  sorry
```

### Part II: Subadditive Depth Certification

**Definition: `ComposedNeuralDensity`**
```lean
/-- A sequence of neural density matrices representing a deep network.
    The composed weight matrix W_k · ... · W_1 defines the end-to-end map. -/
structure DeepNeuralDensity (k : ℕ) where
  layers : Fin k → NeuralDensityMatrix m m
  composed : Matrix (Fin m) (Fin m) ℝ :=
    (List.finRange k).foldr (fun i acc => (layers i).weight * acc) 1
```

**Theorem 4: `subadditive_depth_capacity_certification`** (MAIN THEOREM)
```lean
/-- The effective rank of composed layers is multiplicatively subadditive:
    d_eff(W_k...W_1) ≤ Πᵢ d_eff(Wᵢ).
    This certifies that deep network capacity is bounded by the product of per-layer capacities.
    
    Explicitly: if each layer has effective rank at most r, then k layers have
    effective rank at most rᵏ = exp(k · log r).
    
    Bridge: connects quantum subadditivity to certified neural expressivity bounds.
    Application: certified_robustness for deep networks via information-theoretic capacity. -/
theorem subadditive_depth_capacity_certification (net : DeepNeuralDensity k) (hk : k ≥ 1) :
    net.composed.vonNeumannEffectiveRank ≤
    (∏ i : Fin k, (net.layers i).vonNeumannEffectiveRank) := by
  -- Strategy A (Primary): Use the inequality S(ρ_σ) ≤ Σᵢ S(ρᵢ) where ρ_σ is the
  -- density matrix of the composed system, derived from strong subadditivity of
  -- von Neumann entropy: S(ρ_{AB}) ≤ S(ρ_A) + S(ρ_B).
  -- For weight matrices: eigenvalues of W₁W₂ are bounded by products of singular values.
  -- Use singular_value_product_bound: σᵢ(W₁W₂) ≤ σᵢ(W₁)·σ₁(W₂).
  -- Then: S(ρ_{composed}) ≤ S(ρ_{W_k}) + ... + S(ρ_{W_1}) by induction.
  -- Exponentiate both sides: exp(S(ρ_{composed})) ≤ exp(Σ S(ρᵢ)) = Π exp(S(ρᵢ)).
  
  -- Strategy B: Direct eigenvalue argument. If σ₁ ≥ ... ≥ σₛ are singular values of
  -- the composed matrix, then σᵢ ≤ min_j(σⱼ(W_k)...σⱼ(W_1)) by multiplicative
  -- Weyl inequalities. Then -Σ pᵢ log pᵢ ≤ -Σᵢ Σⱼ pᱼ⁽ⁱ⁾ log pⱼ⁽ⁱ⁾ where
  -- pⱼ⁽ⁱ⁾ = σⱼ(Wᵢ)²/Tr(WᵢWᵢᵀ).
  
  -- Strategy C: Use the data processing inequality. The map ρ ↦ WρW*/Tr(WρW*)
  -- is a quantum channel, and von Neumann entropy decreases under quantum channels
  -- relative to the input entropy. Apply this iteratively.
  sorry
```

**Theorem 5: `multiplicative_depth_capacity_exact`**
```lean
/-- When all layers are isotropic (equal nonzero singular values), depth capacity
    is exactly multiplicative: d_eff(W_k...W_1) = Πᵢ d_eff(Wᵢ).
    This is the saturation condition for subadditive depth certification. -/
theorem multiplicative_depth_capacity_exact (net : DeepNeuralDensity k)
    (h_iso : ∀ i, (net.layers i).isotropic) :
    net.composed.vonNeumannEffectiveRank =
    (∏ i : Fin k, (net.layers i).vonNeumannEffectiveRank) := by
  -- Isotropic layers have equal singular values, so composition preserves
  -- the product structure. Use effective_rank_eq_rank_iff_isotropic and
  -- rank_multiplicative_under_composition.
  sorry
```

**Theorem 6: `certified_expressivity_lipschitz_bound`**
```lean
/-- The expressivity of a k-layer network is Lipschitz-bounded by the product of
    per-layer effective ranks, with explicit constant:
    ‖f(x) - f(y)‖ ≤ (∏ᵢ d_eff(Wᵢ)) · ‖x - y‖ · max_i ‖Wᵢ‖_op.
    
    This gives a certified_robustness bound for quantum-informational ML.
    Bridge: connects quantum capacity bounds to Lipschitz certification. -/
theorem certified_expressivity_lipschitz_bound (net : DeepNeuralDensity k)
    (x y : Fin n → ℝ) :
    ‖net.composed *ᵥ x - net.composed *ᵥ y‖ ≤
    (∏ i : Fin k, (net.layers i).vonNeumannEffectiveRank) *
    (max i, ‖(net.layers i).weight‖_op) * ‖x - y‖ := by
  -- Use subadditive_depth_capacity_certification for the effective rank bound
  -- and operator_norm_composition for the spectral norm bound.
  sorry
```

### Part III: Bures Metric and Natural Gradient Convergence

**Definition: `BuresMetric`**
```lean
/-- The Bures distance between density matrices:
    d_B(ρ₁, ρ₂) = √(2(1 - Tr(√(√ρ₁ ρ₂ √ρ₁)))).
    This is the quantum analogue of the Fisher-Rao distance.
    Bridge: connects quantum state geometry to natural gradient optimization. -/
noncomputable def buresDistance (ρ₁ ρ₂ : Matrix (Fin m) (Fin m) ℝ)
    [h₁ : IsDensityMatrix ρ₁] [h₂ : IsDensityMatrix ρ₂] : ℝ :=
  Real.sqrt (2 * (1 - (ρ₁.sqrt * ρ₂ * ρ₁.sqrt).sqrt.trace))
```

**Theorem 7: `bures_metric_triangle_inequality`**
```lean
/-- The Bures distance satisfies the triangle inequality, making it a metric
    on the space of density matrices. This is the quantum generalization of
    the Fisher-Rao triangle inequality.
    Bridge: connects metric geometry to quantum state space. -/
theorem bures_metric_triangle_inequality (ρ₁ ρ₂ ρ₃ : DensityMatrix m) :
    buresDistance ρ₁.1 ρ₃.1 ≤ buresDistance ρ₁.1 ρ₂.1 + buresDistance ρ₂.1 ρ₃.1 := by
  -- Strategy: Use the Uhlmann fidelity F(ρ,σ) = Tr(√(√ρ σ √ρ)).
  -- The Bures distance is d_B = √(2(1-F)), and fidelity satisfies:
  -- F(ρ₁,ρ₃) ≥ F(ρ₁,ρ₂) · F(ρ₂,ρ₃) (multiplicative property).
  -- Then: √(2(1-F₁₃)) ≤ √(2(1-F₁₂·F₂₃)) ≤ √(2(1-F₁₂)) + √(2(1-F₂₃)).
  -- Key lemma: for f₁,f₂ ∈ [0,1], √(2(1-f₁f₂)) ≤ √(2(1-f₁)) + √(2(1-f₂)).
  -- This follows from (a+b)² ≥ a² + b² when a,b ≥ 0.
  sorry
```

**Theorem 8: `bures_lipschitz_certified_robustness`**
```lean
/-- If two neural density matrices are close in Bures distance, their induced
    linear maps are close with a certified Lipschitz constant:
    ‖W₁x - W₂x‖ ≤ √(2·d_B(ρ₁,ρ₂)·Tr(W₁W₁ᵀ + W₂W₂ᵀ)) · ‖x‖.
    
    This gives certified_robustness for neural networks under weight perturbation
    measured in the quantum Fisher metric.
    Bridge: connects quantum metric geometry to adversarial robustness certification. -/
theorem bures_lipschitz_certified_robustness (ρ₁ ρ₂ : NeuralDensityMatrix m n)
    (x : Fin n → ℝ) :
    ‖ρ₁.weight *ᵥ x - ρ₂.weight *ᵥ x‖ ≤
    Real.sqrt (2 * buresDistance ρ₁.densityMatrix ρ₂.densityMatrix *
      (ρ₁.weight * ρ₁.weightᵀ).trace + (ρ₂.weight * ρ₂.weightᵀ).trace) * ‖x‖ := by
  -- Use the relationship between Bures distance and trace distance:
  -- d_B(ρ,σ) ≤ √(2·d_tr(ρ,σ)) where d_tr = (1/2)‖ρ-σ‖₁
  -- Then ‖W₁x - W₂x‖ ≤ ‖W₁ - W₂‖_op · ‖x‖
  -- And ‖W₁ - W₂‖²_F = Tr((W₁-W₂)(W₁-W₂)ᵀ) ≤ 2(Tr(W₁W₁ᵀ) + Tr(W₂W₂ᵀ))·d_B²
  sorry
```

**Theorem 9: `quantum_natural_gradient_convergence_rate`**
```lean
/-- Natural gradient descent on the Bures manifold converges at rate
    O(κ(g_F) · log(1/ε)) where κ(g_F) is the condition number of the quantum
    Fisher information metric g_F.
    
    Explicitly: after t ≥ κ(g_F) · log(R/ε) steps, the loss satisfies
    L(θₜ) - L* ≤ ε, where R = L(θ₀) - L* is the initial suboptimality.
    
    Bridge: connects Riemannian optimization to certified convergence in quantum ML.
    Application: post_quantum_security of quantum-trained models. -/
theorem quantum_natural_gradient_convergence_rate
    (L : DensityMatrix m → ℝ) (h_convex : ConvexOn {ρ | IsDensityMatrix ρ} L)
    (h_lipschitz : ∀ ρ σ, |L ρ - L σ| ≤ C * buresDistance ρ σ)
    (θ₀ : DensityMatrix m) (ε : ℝ) (hε : ε > 0) :
    ∃ t : ℕ, t ≤ Nat.ceil (conditionNumber (quantumFisherMetric θ₀) *
      Real.log (2 * (L θ₀.1 - inf L) / ε)) ∧
    L (naturalGradientStep θ₀ t).1 - inf L ≤ ε := by
  -- Strategy: Use the geodesic convexity of the Bures manifold.
  -- The quantum Fisher metric is the Hessian of the relative entropy.
  -- Natural gradient on this manifold is equivalent to mirror descent with
  -- the von Neumann entropy Bregman divergence.
  -- Convergence follows from the Riemannian gradient descent analysis with
  -- geodesic Lipschitz constant and geodesic strong convexity.
  -- Key lemmas: geodesic_convexity_loss, fisher_metric_condition_bound,
  -- natural_gradient_geodesic_descent.
  sorry
```

**Theorem 10: `von_neumann_entropy_data_processing`**
```lean
/-- The von Neumann entropy of neural density matrices satisfies the data
    processing inequality: for any weight matrix W, S(WρW*/Tr(WρW*)) ≤ S(ρ).
    This certifies that neural network layers cannot increase the effective rank
    of the information content, establishing an information-theoretic bottleneck.
    
    Bridge: connects quantum channel theory to information bottleneck in deep learning.
    Application: certified_robustness via information capacity bounds. -/
theorem von_neumann_entropy_data_processing (ρ : DensityMatrix m)
    (W : Matrix (Fin m) (Fin m) ℝ) (hW : (W * ρ.1 * Wᵀ).trace > 0) :
    vonNeumannEntropy (W * ρ.1 * Wᵀ /ᵥ fun _ => (W * ρ.1 * Wᵀ).trace) ≤
    vonNeumannEntropy ρ.1 := by
  -- This is the quantum data processing inequality (DPI).
  -- Strategy A: Use Klein's inequality: Tr(σ log σ) - Tr(σ log ρ) ≥ 0 for density matrices.
  -- Strategy B: Use the Lindblad extension and partial trace argument.
  -- Strategy C: Use the monotonicity of relative entropy under CPTP maps.
  -- The map ρ ↦ WρW*/Tr(WρW*) is a CPTP map, so DPI applies directly.
  sorry
```

**Theorem 11: `effective_rank_composition_submultiplicative`**
```lean
/-- The effective rank of the product of weight matrices is submultiplicative:
    d_eff(W₁ · W₂) ≤ d_eff(W₁) · d_eff(W₂) · max(1, ‖W₁‖²_op/Tr(W₁W₁ᵀ)) · max(1, ‖W₂‖²_op/Tr(W₂W₂ᵀ))
    
    This gives an explicit, computable bound on composed effective rank.
    Bridge: connects multiplicative spectral theory to quantum expressivity. -/
theorem effective_rank_composition_submultiplicative
    (W₁ : NeuralDensityMatrix m p) (W₂ : NeuralDensityMatrix p n) :
    (W₁.weight * W₂.weight).vonNeumannEffectiveRank ≤
    W₁.vonNeumannEffectiveRank * W₂.vonNeumannEffectiveRank *
    max 1 (‖W₁.weight‖_op² / (W₁.weight * W₁.weightᵀ).trace) *
    max 1 (‖W₂.weight‖_op² / (W₂.weight * W₂.weightᵀ).trace) := by
  -- Use the singular value inequality σᵢ(AB) ≤ σᵢ(A) · σ₁(B) and
  -- the relationship between effective rank and singular value distribution.
  -- The correction factors account for the normalization mismatch between
  -- the product density matrix and the product of density matrices.
  sorry
```

**Theorem 12: `bures_distance_quantum_fisher_relation`**
```lean
/-- The Bures distance is infinitesimally related to the quantum Fisher information:
    d_B²(ρ, ρ + εH) = ε² · g_F(ρ)[H, H] + O(ε³)
    where g_F is the quantum Fisher information metric.
    This establishes the Bures metric as the natural Riemannian metric on density matrices.
    
    Bridge: connects information geometry to quantum statistical mechanics. -/
theorem bures_distance_quantum_fisher_relation
    (ρ : DensityMatrix m) (H : Matrix (Fin m) (Fin m) ℝ)
    (hH : H = Hᵀ) (h_trace : (ρ.1 * H).trace = 0) :
    Filter.Tendsto (fun ε => buresDistance ρ.1 (ρ.1 + ε • H)² / ε²)
      (𝓝[≠] 0) (𝓝 (quantumFisherInner ρ H H)) := by
  -- Use the Taylor expansion of the matrix square root:
  -- √(ρ + εH) = √ρ + ε·L_ρ(H) + O(ε²) where L_ρ is the symmetric logarithmic derivative.
  -- Then: Tr(√(√ρ(ρ+εH)√ρ)) = Tr(ρ) + (ε²/2)·g_F(ρ)[H,H] + O(ε³)
  -- So d_B² = 2(1 - 1 - (ε²/2)·g_F + O(ε³)) = ε²·g_F + O(ε³).
  sorry
```

**Theorem 13: `quantum_fisher_geodesic_convexity`**
```lean
/-- Loss functions that are geodesically convex on the Bures manifold satisfy
    accelerated convergence. For L geodesically μ-strongly convex and geodesically
    L-Lipschitz, natural gradient descent converges in
    O(√(L/μ) · log(1/ε)) steps (quantum Nesterov acceleration).
    
    Bridge: connects Riemannian optimization theory to quantum ML acceleration. -/
theorem quantum_fisher_geodesic_convexity
    (L : DensityMatrix m → ℝ) (μ L_rate : ℝ) (hμ : μ > 0) (hL : L_rate > 0)
    (h_gconvex : GeodesicallyStronglyConvex BuresMetric μ L)
    (h_glipschitz : GeodesicallyLipschitz BuresMetric L_rate L)
    (θ₀ : DensityMatrix m) (ε : ℝ) (hε : ε > 0) :
    ∃ t : ℕ, t ≤ Nat.ceil (Real.sqrt (L_rate / μ) * Real.log (2 / ε)) ∧
    L (quantumNaturalGradientDescent θ₀ t).1 - inf L ≤ ε := by
  -- Use the geodesic Nesterov acceleration analysis on Riemannian manifolds.
  -- The Bures manifold has non-negative sectional curvature (it's an open cone
  -- in the PSD cone), so the standard Riemannian Nesterov analysis applies.
  -- Key reference: Ahn & Sra, "From Nesterov's Estimate Sequence to Riemannian Acceleration"
  sorry
```

**Theorem 14: `thermal_capacity_entropy_tradeoff`**
```lean
/-- For a neural density matrix ρ at effective "temperature" T (defined via
    eigenvalue distribution), the effective rank and von Neumann entropy satisfy
    the thermal tradeoff: d_eff(ρ) · T ≤ S(ρ) · T + log(d), where d = dim.
    
    This is the neural-network analogue of the thermodynamic entropy-temperature relation
    and bounds the expressivity-regularization tradeoff.
    
    Bridge: connects statistical mechanics (temperature, entropy) to ML regularization.
    Application: certified_robustness via entropy regularization. -/
theorem thermal_capacity_entropy_tradeoff (ρ : NeuralDensityMatrix m n)
    (T : ℝ) (hT : T > 0) :
    ρ.vonNeumannEffectiveRank * T ≤
    vonNeumannEntropy ρ.densityMatrix * T + Real.log m := by
  -- Use the relation d_eff = exp(S), so d_eff · T = exp(S) · T.
  -- By Gibbs' inequality: S ≤ log(rank) ≤ log(m).
  -- So d_eff · T = exp(S) · T ≤ exp(log(m)) · T = m · T.
  -- More precisely: exp(S) · T ≤ exp(S) · T + log(m) iff log(m) ≥ 0, which holds for m ≥ 1.
  -- Actually need: d_eff · T ≤ S · T + log(m), i.e., exp(S) · T ≤ S · T + log(m).
  -- This follows from exp(S) ≤ S + log(m) when S ≤ log(m) (which is true since
  -- S ≤ log(rank) ≤ log(m) for an m×m density matrix).
  sorry
```

**Theorem 15: `lattice_crypto_hardness_from_effective_rank`**
```lean
/-- If a neural network has effective rank d_eff, then inverting it (finding x from Wx)
    requires at least Ω(2^(d_eff/2)) operations assuming the quantum hardness of
    lattice problems (GapSVP).
    
    This establishes a cryptographic lower bound on neural network inversion using
    quantum-informational capacity.
    
    Bridge: connects quantum information theory to post-quantum cryptography.
    Application: post_quantum_security of neural network models. -/
theorem lattice_crypto_hardness_from_effective_rank
    (ρ : NeuralDensityMatrix m n) (h_gap : ∀ poly_time_adversary, ¬ poly_time_adversary ρ.weight)
    (h_svp : QuantumHardnessGapSVP) :
    ∀ adversary, adversary.complexity ≥ Real.exp (ρ.vonNeumannEffectiveRank / 2) →
    ¬ adversary.inverts ρ.weight := by
  -- Strategy: Reduce to the short vector problem in the lattice generated by W.
  -- If W has effective rank d_eff, then the lattice L(W) has a gap of at least
  -- 2^(d_eff/2) between λ₁ and λ₂ (first and second minima).
  -- By Ajtai's reduction, finding short vectors in such lattices is as hard as GapSVP.
  -- Therefore, any adversary that inverts W must solve a lattice problem of
  -- comparable difficulty, requiring Ω(2^(d_eff/2)) operations.
  sorry
```

### Definitions and Structures Required

```lean
/-- The von Neumann entropy of a density matrix -/
noncomputable def vonNeumannEntropy (ρ : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  -∑ i, (eigenvectorBasis ρ i).2 * Real.log (eigenvectorBasis ρ i).2

/-- A certified density matrix (positive semidefinite, trace 1) -/
structure DensityMatrix (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℝ
  h_pos : mat.IsPSD
  h_trace : mat.trace = 1

/-- The quantum Fisher information metric -/
noncomputable def quantumFisherMetric (ρ : DensityMatrix n) :
    InnerProductSpace.Core ℝ (Matrix (Fin n) (Fin n) ℝ) :=
  ⟨fun H₁ H₂ => (ρ.1⁻¹ * H₁ * H₂).trace + (H₁ * ρ.1⁻¹ * H₂).trace⟩

/-- Natural gradient descent step on the Bures manifold -/
noncomputable def naturalGradientStep (ρ : DensityMatrix n) (t : ℕ) : DensityMatrix n :=
  -- Project Euclidean gradient onto the Bures tangent space
  -- using the quantum Fisher metric, then take a geodesic step
  sorry -- requires geodesic computation

/-- Quantum Fisher information condition number -/
noncomputable def conditionNumber (g : quantumFisherMetric ρ) : ℝ :=
  g.maxEigenvalue / g.minEigenvalue

/-- Isotropic spectrum: all nonzero eigenvalues are equal -/
def IsIsotropic (ρ : DensityMatrix n) : Prop :=
  ∀ i j, ρ.eigenvalue i ≠ 0 → ρ.eigenvalue j ≠ 0 → ρ.eigenvalue i = ρ.eigenvalue j

/-- Quantum hardness of GapSVP (axiom for cryptographic reduction) -/
axiom QuantumHardnessGapSVP : Prop
```

### Proof Strategy Summary

1. **Effective rank bounds** (Theorems 1-2): Use Jensen's inequality with the concavity of log for the upper bound S ≤ log(rank), and Gibbs' inequality S ≥ 0 for the lower bound. Equality characterization uses strict concavity.

2. **Subadditive depth certification** (Theorems 4-6): Primary strategy is quantum data processing inequality applied iteratively. Each layer is a CPTP map, so entropy (hence effective rank) cannot increase. The product bound follows from exp(Σ Sᵢ) = Π exp(Sᵢ).

3. **Bures metric properties** (Theorems 7-8): Use Uhlmann's fidelity F(ρ,σ) = Tr(√(√ρ σ √ρ)) and its multiplicative property F(ρ₁,ρ₃) ≥ F(ρ₁,ρ₂)·F(ρ₂,ρ₃). The Lipschitz bound follows from trace distance inequalities.

4. **Natural gradient convergence** (Theorems 9, 13): Use geodesic convexity on the Bures manifold (which has non-negative curvature). The convergence rate follows from Riemannian optimization theory with the quantum Fisher metric.

5. **Cryptographic hardness** (Theorem 15): Reduce neural network inversion to the shortest vector problem in the lattice generated by the weight matrix, using Ajtai's worst-case to average-case reduction.

### Significance and Future Directions

This work opens **quantum-informational machine learning theory** by establishing that:
- Neural network expressivity is certified by von Neumann entropy (quantum capacity)
- Depth-capacity bounds follow from quantum subadditivity (information bottleneck)
- Natural gradient convergence is certified by Bures geometry (quantum optimization)
- Cryptographic hardness of inversion follows from effective rank (post-quantum security)

These are not analogies but precise mathematical correspondences: weight matrices ARE density matrices, expressivity IS von Neumann entropy, and optimization IS geodesic flow on the Bures manifold.

**FUTURE_DIRECTIONS.md should include:**
1. Quantum error correction for neural networks: Can we use quantum error-correcting codes to certify robustness against adversarial perturbations?
2. Entanglement-based expressivity: Extend to multi-layer networks with entanglement between layers (tensor product structure).
3. Quantum advantage in optimization: Prove that quantum natural gradient achieves provably faster convergence than classical gradient descent.
4. Post-quantum security of neural networks: Develop lattice-based cryptographic primitives from neural effective rank.
5. Tropical quantum information: Develop the tropical analogue of von Neumann entropy (min-plus entropy) and its applications to tropical ML.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of quantum-informational machine learning by proving three foundational theorems that establish quantum information measures as certified bounds on neural network capacity and optimization. The paradigm-shifting insight: neural network weight matrices W, when normalized to density matrices ρ = WW*/Tr(WW*), admit full quantum-information-theoretic analysis. (1) Von Neumann entropy S(ρ) = -Σ λᵢ log λᵢ defines an effective rank d_eff = exp(S(ρ)) that tightly bounds layer expressivity, with d_eff = rank(W) iff all singular values are equal (isotropic) and d_eff → 1 as the matrix degenerates to rank-1. (2) Quantum subadditivity S(ρ_composed) ≤ Σ S(ρ_layer) yields multiplicative depth-capacity bounds: d_eff(W_k…W₁) ≤ Π d_eff(Wᵢ), certifying that deep network capacity is bounded by the product of per-layer capacities. (3) The Bures distance d_B(ρ₁,ρ₂) = √(2(1 - Tr(√(√ρ₁ρ₂√ρ₁)))) induces the quantum Fisher information metric on weight space, giving reparameterization-invariant natural gradient descent with certified convergence rate O(κ(g)·log(1/ε)). This creates an unexpected bridge between quantum physics (density matrices, von Neumann entropy, Bures geometry) and machine learning (expressivity, depth capacity, optimization), opening quantum-informational ML theory.

            ### Precise Mathematical Framing
            For W ∈ M_{m×n}(ℂ) with singular values σ₁ ≥ … ≥ σ_r > 0, define ρ_W = W*W/Tr(W*W) with eigenvalues pᵢ = σᵢ²/Σⱼσⱼ². The von Neumann entropy S(ρ) = -Σᵢ pᵢ log pᵢ satisfies 0 ≤ S(ρ) ≤ log(min(m,n)). THEOREM 1 (Effective Rank Expressivity): d_eff(W) := exp(S(ρ_W)) satisfies 1 ≤ d_eff(W) ≤ rank(W), with d_eff(W) = rank(W) iff all nonzero singular values are equal, and d_eff(W) → 1 as the ratio σ₁/σ_r → ∞. This certifies that isotropic weight matrices maximize expressivity per parameter. THEOREM 2 (Subadditive Depth Capacity): For composed layers W = W_k…W₂W₁, the quantum subadditivity inequality gives S(ρ_W) ≤ Σᵢ S(ρ_{Wᵢ}), hence d_eff(W) ≤ Πᵢ d_eff(Wᵢ). Equality holds iff the layers have orthogonal row/column spaces (quantum product state condition). This multiplicative bound certifies that deep network expressivity is fundamentally constrained by per-layer effective ranks. THEOREM 3 (Bures Metric Convergence): The quantum Fisher information g_{ij} = Re(Tr(ρ{∂logρ/∂θᵢ, ∂logρ/∂θⱼ}/2)) defines a Riemannian metric on the parameter manifold. Natural gradient descent θ ← θ - η·g⁻¹∇L converges to ε-accuracy in at most C·κ(g)·log(1/ε) iterations, where κ(g) is the condition number of the quantum Fisher information matrix. The Bures metric is reparameterization-invariant: d_B(ρ(θ), ρ(θ')) depends only on the density matrices, not the parameterization.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `depth_convergence_rate_bound` : theorem depth_convergence_rate_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `full_space_entropy` : theorem full_space_entropy (n : ℕ) :
     (file: Bridges/QuantumStabilizerClosure.lean)
  3. `deep_network_region_bound` : theorem deep_network_region_bound (k : ℕ) (widths : Fin k → ℕ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  4. `depth_bounded_stabilization` : theorem depth_bounded_stabilization {α : Type*} [BooleanAlgebra α]
     (file: Bridges/ProvabilitySpectralTheory.lean)
  5. `code_rate_bounded` : theorem code_rate_bounded (n k : ℕ) (hk : k ≤ n) (hn : 0 < n) :
     (file: Bridges/StabilizerGaloisConcatenation.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Proof Quantum Dynamics: Normalization Superposition, Cut-Interference Uncertainty, and Proof Entanglement Certification, Berggren Lattice Cryptography: Pythagorean Lattice SVP, Berggren-LLL Basis Reduction, and Certified Diophantine NTRU Key Exchange, Noetherian Cryptographic Certification: ACC Protocol Termination, Finitely Generated Key Certification, and Quotient Ring Homomorphic Correctness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
