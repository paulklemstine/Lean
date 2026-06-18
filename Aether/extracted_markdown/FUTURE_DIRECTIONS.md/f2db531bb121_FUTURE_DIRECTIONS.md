# Future Directions: Stereographic Neural Attention

## Synthesis

This research cycle established a rigorous mathematical foundation for stereographic attention — an attention mechanism built on the Cauchy kernel K(q,k) = 1/(1+‖q−k‖²) arising from stereographic projection onto the Riemann sphere. The central results are: (1) a tight sparsity radius bound showing that only keys within distance √(1/ε − 1) contribute weight ≥ ε, (2) the Cauchy-Gaussian bridge theorem showing that softmax attention is the limiting case (t → ∞) of a one-parameter family containing stereographic attention, and (3) a complete probability distribution theory for normalized Cauchy weights.

The most promising cross-domain connection is between the Cauchy kernel and the **Poisson kernel** from harmonic analysis. The Cauchy kernel is essentially the radial component of the Poisson kernel for the half-space, and the stereographic projection maps between the sphere and the plane where the Poisson kernel naturally lives. This means stereographic attention computes something akin to harmonic extension — a deep connection that could yield both theoretical insights (approximation theory) and practical algorithms (harmonic attention). The bridge theorem also connects to the **rational quadratic kernel** family in Gaussian processes, suggesting that stereographic attention inherits universal approximation properties from GP theory.

The highest breakthrough potential lies in Direction 1 (Riesz kernel family), because it simultaneously generalizes our sparsity results to a rich family of kernels AND provides the mathematical machinery needed to prove universal approximation for stereographic attention. If the Riesz family admits a clean sparsity-approximation tradeoff theorem, it would establish a new theoretical framework for understanding the geometry of attention.

---

### Direction 1: Riesz Kernel Attention and the Sparsity-Approximation Tradeoff

**Conjecture**: For the Riesz kernel family K_s(q,k) = 1/(1+‖q−k‖²)^s with s > 0, there exists a sharp phase transition at s = d/2 (where d is the embedding dimension): for s < d/2, the kernel is L¹-integrable on ℝ^d and yields uniformly bounded attention weight sums; for s ≥ d/2, the attention weight sum grows without bound as keys fill space. Specifically, for N uniformly distributed keys in a ball of radius R, the sum ∑ K_s(0, kᵢ) satisfies:
- s > d/2: sum ~ C(s,d) · N (bounded growth)
- s = d/2: sum ~ C · N · log(R)
- s < d/2: sum ~ C · N · R^{d-2s}

**Test**: Formalize the Riesz kernel in Lean 4. Prove the sparsity radius bound for general s: K_s(q,k) ≥ ε implies ‖q−k‖² ≤ (1/ε)^{1/s} − 1. Numerically verify the phase transition by computing weight sums for s = 0.5, 1.0, 1.5, 2.0 in dimensions d = 2, 4, 8.

**Impact**: If true, this provides a rigorous framework for choosing the kernel exponent s as a function of dimension and desired sparsity level. The phase transition at s = d/2 would be a new result connecting attention theory to potential theory (where the same critical exponent governs the behavior of Riesz potentials).

**Catalog References**: `Novelty/StereographicAttention/Theorems.lean` (sparsity radius bound, Cauchy kernel properties), `Geometry/GapMatterResearch.lean` (measure on spheres), `Bridges/NeuralBirkhoffDecomposition.lean` (geometric sum bounds)

**Proof Strategy**: 
1. Define the Riesz kernel family in Lean 4 as `riesz_kernel (s : ℝ) (q k : EuclideanSpace ℝ (Fin d)) : ℝ := (1 + ‖q - k‖ ^ 2) ^ (-s)`.
2. Prove the generalized sparsity radius bound using the same algebraic argument as for s = 1.
3. For the phase transition, use the integral comparison: ∑ K_s(0, kᵢ) ≈ N · ∫ K_s(0,x) dx over the key distribution, and compute the integral using polar coordinates. The integral ∫₀^∞ r^{d-1}/(1+r²)^s dr converges iff s > d/2.
4. For the formal Lean proofs, focus on the sparsity bound (algebraic) and leave the integral asymptotics as computed examples.

**Domain Bridges**: Harmonic Analysis (Riesz potentials) ↔ Attention Mechanisms (kernel choice) ↔ Gaussian Processes (rational quadratic kernel family)

**Lineage**: Extends the sparsity radius bound and Cauchy kernel theory from this cycle's `Novelty/StereographicAttention/Theorems.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Harmonic Attention — Attention as Poisson Extension

**Conjecture**: Stereographic attention with the Cauchy kernel computes a discrete approximation to the Poisson extension operator. Specifically, for a function f defined at points k₁, ..., k_N on ℝ^d, the stereographic attention output ∑ w̃ᵢ · f(kᵢ) converges (as the keys become dense) to the Poisson integral (P * f)(q), the harmonic extension of f to the upper half-space. The convergence rate is O(h^2) where h is the key spacing, matching the order of the Poisson kernel's smoothness.

**Test**: In dimension d=1, the Poisson kernel for the upper half-plane is P_y(x) = y/(π(x²+y²)). Show that for height y=1, P_1(x) = 1/(π(1+x²)), which is proportional to the Cauchy kernel. Verify numerically that discrete Cauchy attention on a grid of N keys approximates the Poisson integral with error O(1/N²).

**Impact**: If true, this establishes attention mechanisms as a discrete version of a classical operator from harmonic analysis, providing (a) approximation guarantees from classical theory, (b) connections to maximum principles and boundary value problems, and (c) a theoretical explanation for why attention is effective at "interpolating" information.

**Catalog References**: `Novelty/StereographicAttention/Theorems.lean` (Cauchy kernel = conformal factor), `Novelty/StereographicAttention/Defs.lean` (normalized weights definition)

**Proof Strategy**:
1. Define the Poisson kernel P_y(x) = c_d · y / (‖x‖² + y²)^{(d+1)/2} and show its relationship to the Cauchy kernel.
2. Prove that for y=1 in d=1, P_1(x) ∝ K(0,x) = 1/(1+x²).
3. Use Riemann sum approximation theory to bound the error between discrete attention and the continuous Poisson integral.
4. Key lemma: the Poisson kernel is in L¹(ℝ^d) with integral 1, so the Poisson integral is a probability-weighted average — exactly matching the structure of attention.

**Domain Bridges**: Harmonic Analysis (Poisson kernel, boundary value problems) ↔ Neural Attention (weight computation) ↔ Potential Theory (harmonic functions)

**Lineage**: Extends the conformal factor identity from this cycle and connects to `Geometry/GapMatterResearch.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Möbius-Equivariant Attention

**Conjecture**: The Cauchy kernel on the Riemann sphere is invariant under Möbius transformations (the conformal automorphisms of the sphere). Specifically, for any Möbius transformation φ: S^n → S^n and the corresponding map σ⁻¹ ∘ φ ∘ σ on ℝ^n (where σ is stereographic projection), the Cauchy kernel satisfies K(φ(q), φ(k)) = |J_φ(q)|^{1/d} · |J_φ(k)|^{1/d} · K(q,k), where J_φ is the Jacobian determinant. This conformal covariance property is unique to the Cauchy kernel among radial kernels.

**Test**: Formalize Möbius transformations in Lean 4 (starting with inversions and translations, which generate the full group). Prove the conformal covariance identity for inversions x ↦ x/‖x‖². Numerically verify for 2D Möbius transformations (which correspond to complex functions (az+b)/(cz+d)).

**Impact**: If true, this gives stereographic attention a built-in equivariance property that softmax attention lacks. Möbius equivariance means the attention mechanism is "aware" of the conformal structure of the embedding space, potentially enabling better handling of scale-invariant and rotationally symmetric data.

**Catalog References**: `Novelty/StereographicAttention/Theorems.lean` (Cauchy kernel symmetry, conformal factor), `Geometry/GapMatterResearch.lean` (sphere geometry)

**Proof Strategy**:
1. Define Möbius transformations as compositions of inversions, translations, and dilations.
2. Prove the covariance identity for each generator separately.
3. Show the identity is closed under composition.
4. The key calculation: under inversion x ↦ x/‖x‖², ‖φ(q)−φ(k)‖² = ‖q−k‖²/(‖q‖²·‖k‖²), and the Jacobian is |J_φ(x)| = 1/‖x‖^{2d}.

**Domain Bridges**: Conformal Geometry (Möbius group) ↔ Equivariant Neural Networks ↔ Complex Analysis (bilinear transformations)

**Lineage**: Extends the dimension-independence and conformal factor results from this cycle.

**Ambition**: extension

---

### Direction 4: Universal Approximation for Stereographic Attention Layers

**Conjecture**: A single stereographic attention layer with sufficiently many heads can approximate any continuous function on compact subsets of ℝ^d to arbitrary precision. Specifically, for any continuous f: K → ℝ^m (K compact) and ε > 0, there exist query projections W_Q, key projections W_K, value projections W_V, and a number of heads H such that the multi-head stereographic attention output approximates f to within ε in the sup norm.

**Test**: Prove that the span of functions x ↦ ∑ᵢ cᵢ/(1+‖Wᵢx − bᵢ‖²) is dense in C(K) for K compact. This is the kernel version of the universal approximation theorem, using the Cauchy kernel instead of sigmoid activations.

**Impact**: If true, this would be the first universal approximation result for an attention mechanism with built-in sparsity, establishing that sparsity does not sacrifice expressiveness.

**Catalog References**: `Novelty/StereographicAttention/Theorems.lean` (kernel properties, bridge theorem), `Bridges/NeuralBirkhoffDecomposition.lean` (decomposition techniques)

**Proof Strategy**:
1. The Cauchy kernel K(·, k) = 1/(1+‖·−k‖²) is a radial basis function. By the Stone-Weierstrass theorem, it suffices to show that the algebra generated by translates of this kernel separates points on K.
2. Key lemma: K(x, k₁) ≠ K(x, k₂) for some x whenever k₁ ≠ k₂ (follows from the strict monotonicity of the kernel and the identity K(k₁, k₁) = 1 > K(k₁, k₂) for k₁ ≠ k₂).
3. Alternatively, use the bridge theorem: since the Cauchy family converges to the Gaussian kernel (which is known to be universal), and universal approximation is stable under limits, the Cauchy kernel inherits universality.

**Domain Bridges**: Approximation Theory (Stone-Weierstrass, UAT) ↔ Attention Mechanisms ↔ Kernel Methods (characteristic kernels)

**Lineage**: Builds on the bridge theorem and kernel properties from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Stereographic Attention

**Conjecture**: There exists a "tropicalization" of stereographic attention where the Cauchy kernel K(q,k) = 1/(1+‖q−k‖²) is replaced by its tropical analog: K_trop(q,k) = −min(0, ‖q−k‖_∞² − c) for a capacity parameter c > 0. The resulting tropical attention mechanism computes piecewise-linear functions and admits an exact sparse representation: exactly those keys with ‖q−k‖_∞ ≤ √c receive nonzero weight, and the weight is a linear function of ‖q−k‖_∞².

**Test**: Define tropical stereographic attention in Lean 4. Prove the exact sparsity characterization (sharp cutoff at ‖q−k‖_∞ = √c). Show that tropical attention over ℤ^d can be computed in O(|S| · d) time with no floating-point arithmetic.

**Impact**: If true, this creates a bridge between tropical geometry and attention mechanisms, potentially enabling exact (not approximate) sparse attention for integer-valued or quantized embeddings.

**Catalog References**: `Tropical/` (tropical geometry catalog), `Novelty/StereographicAttention/Theorems.lean` (sparsity radius bound to tropicalize), `Bridges/NeuralBirkhoffDecomposition.lean`

**Proof Strategy**:
1. Define the tropical Cauchy kernel using min/max operations.
2. The sparsity characterization is exact because the tropical kernel has a hard cutoff (not polynomial decay).
3. Prove that tropical attention weights are piecewise-linear in the query coordinates.
4. Connect to tropical convexity: the set of keys receiving nonzero weight is a tropical polytope.

**Domain Bridges**: Tropical Geometry ↔ Attention Mechanisms ↔ Integer/Quantized Computing

**Lineage**: Extends this cycle's stereographic attention to the tropical setting, connecting to the project's `Tropical/` research thread.

**Ambition**: extension
