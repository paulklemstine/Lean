# Future Research Directions: Stereographic Neural Attention

## Synthesis

This research cycle established the mathematical foundations of **stereographic attention** — an attention mechanism built on the Cauchy kernel K(q,k) = 1/(1+‖q-k‖²) and grounded in the conformal geometry of the Riemann sphere. The key discovery is the **stereographic distance identity**, which reveals that the Cauchy kernel is not an arbitrary choice but the canonical kernel induced by stereographic projection. This identity — ‖σ(x)−σ(y)‖² = 4‖x−y‖²/((1+‖x‖²)(1+‖y‖²)) — provides a precise bridge between flat-space computations and spherical geometry, making every attention computation interpretable as a measurement on the Riemann sphere.

The cycle proved six categories of results: kernel properties (positivity, bounds, symmetry, monotonicity), stereographic geometry (projection onto sphere, distance identity), probabilistic structure (weights form a probability distribution), sparsity (Markov bound on active keys), dominance (concentration under matching keys, analogous to the attention sink theorem), and structural properties (inherent softness, polynomial weight ratios). The dominance theorem directly connects to the Catalog's `softmax_weight_dominant_bound` (SinkTheorem.lean), establishing a parallel between Cauchy and softmax attention paradigms.

The most promising cross-domain connection is between the stereographic distance identity and the geometric improvement bounds in ConvergenceTheory.lean. The sphere's Riemannian structure could provide tighter convergence analyses for attention-based optimization. The inherent softness result (Cauchy attention can never achieve hard attention) is a structural impossibility theorem that constrains the expressivity of polynomial-kernel attention, analogous to the barriers from diagonalization results in the Catalog.

---

### Direction 1: Universal Approximation for Cauchy Attention

**Conjecture**: For any continuous function f: ℝᵈ → ℝ and any ε > 0, there exists a single-layer Cauchy attention network with sufficiently many keys such that the attention output approximates f to within ε in supremum norm on any compact set. Formally: the family of functions {x ↦ Σⱼ wⱼ(x)·vⱼ : wⱼ normalized Cauchy weights, vⱼ ∈ ℝ} is dense in C(K,ℝ) for any compact K ⊂ ℝᵈ.

**Test**: First, prove that Cauchy attention can approximate any softmax attention output to arbitrary precision (by showing the Cauchy kernel can approximate the exponential kernel on compact sets via scaling). Then use the known universal approximation of softmax attention as a bridge. Alternatively, directly prove density using the Stone-Weierstrass theorem: verify that the family of Cauchy-weighted combinations separates points and contains constants.

**Impact**: If true, this establishes stereographic attention as a theoretically complete replacement for softmax attention. If false, it characterizes the expressivity gap and identifies which functions require exponential kernels.

**Catalog References**: `FINAL/MachineLearning/ConvergenceTheory.lean` (geometric_improvement_bound), `Catalog/MachineLearning/ClosureNetworkUAP.lean`

**Proof Strategy**: The key lemma is that for any two distinct points x ≠ y, there exists a key configuration such that the Cauchy attention output separates x and y. This follows from K(x,x) = 1 > K(x,y) for y ≠ x. Then apply Stone-Weierstrass. The harder part is handling the non-compact domain; restrict to compact subsets.

**Domain Bridges**: MachineLearning <-> Algebra (Stone-Weierstrass is algebraic), MachineLearning <-> Geometry (sphere geometry constrains approximation)

**Lineage**: Builds on stereoProj_sqNorm_eq_one, normalizedCauchyWeight_sum, cauchyKernel_self from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hyperbolic Stereographic Attention

**Conjecture**: Replacing the Euclidean Cauchy kernel 1/(1+‖x-y‖²) with the hyperbolic Cauchy kernel 1/(1+d_H(x,y)²), where d_H is the Poincaré disk distance d_H(x,y) = arccosh(1 + 2‖x-y‖²/((1-‖x‖²)(1-‖y‖²))), produces an attention mechanism with exponential sparsity: the number of active keys at threshold ε is O(log(1/ε)) instead of O(1/ε). This would combine the geometric naturality of stereographic attention with the hierarchical representation power of hyperbolic geometry.

**Test**: (1) Define the hyperbolic Cauchy kernel formally. (2) Prove the analogue of the Markov sparsity bound. (3) Show that for keys arranged on a hyperbolic lattice, the exponential volume growth of hyperbolic space forces most kernel values to be exponentially small, giving an O(log(1/ε)) active key count. Compare with the Euclidean O(1/ε) bound.

**Impact**: Hyperbolic spaces naturally represent tree-like hierarchical structures (parse trees, taxonomies, knowledge graphs). Hyperbolic stereographic attention could provide both geometric structure AND hierarchical inductive bias, potentially unifying geometric attention with hierarchical representation learning.

**Catalog References**: `MachineLearning/HyperbolicNumberTheory/Core.lean` (hyperbolic_counting_upper_bound_conjecture), `FINAL/MachineLearning/ConvergenceTheory.lean`

**Proof Strategy**: The key insight is that hyperbolic balls of radius r have volume growing as exp(r), so packing arguments give exponentially fewer near-neighbors. Formalize the hyperbolic distance, define the kernel, prove the volume growth bound, then derive the sparsity improvement via a geometric packing argument.

**Domain Bridges**: MachineLearning <-> Geometry (hyperbolic geometry), MachineLearning <-> Computation (algorithmic implications of exponential sparsity)

**Lineage**: Builds on activeKeyCount_le_inv_threshold and stereo_sqDist_identity from this cycle. Extends to negative curvature.

**Ambition**: grand_challenge

---

### Direction 3: Cauchy Attention Sink Classification

**Conjecture**: A key configuration (q, k₁,...,k_N) in Cauchy attention has a "sink" at key j₀ (meaning w_{j₀} > 1/2) if and only if the Cauchy kernel value K(q, k_{j₀}) exceeds the sum of all other kernel values: K(q,k_{j₀}) > Σ_{j≠j₀} K(q,k_j). Moreover, the maximal weight key is unique (no ties are possible for generic configurations).

**Test**: (1) Prove the forward direction: if K(q,k_{j₀}) > Σ_{j≠j₀} K(q,k_j), then w_{j₀} > 1/2 (this should follow from the definition of normalized weights). (2) Prove the reverse direction. (3) Prove genericity: the set of configurations with tied maximal weights has measure zero.

**Impact**: This gives a complete algebraic characterization of the attention sink phenomenon for Cauchy attention, complementing the softmax characterization in SinkTheorem.lean. The measure-zero result on ties would show that Cauchy attention sinks are structurally stable.

**Catalog References**: `Catalog/MachineLearning/SinkTheorem.lean` (softmax_weight_dominant_bound, dominant_column_is_row_argmax)

**Proof Strategy**: The forward and reverse directions are straightforward algebra from the normalized weight definition. The genericity result requires showing that the equation K(q,k_j) = K(q,k_i) (for i ≠ j) defines a submanifold of codimension 1 in configuration space, using Sard's theorem or the implicit function theorem.

**Domain Bridges**: MachineLearning <-> Geometry (configuration space analysis), MachineLearning <-> Algebra (algebraic variety structure of tie sets)

**Lineage**: Builds on cauchy_dominant_weight_bound, cauchy_never_hard_attention from this cycle. Extends the SinkTheorem.lean results.

**Ambition**: extension

---

### Direction 4: Conformal Equivariance of Stereographic Attention

**Conjecture**: Stereographic attention is equivariant under Möbius transformations of the Riemann sphere. Specifically, if M is a Möbius transformation (fractional linear transformation) of ℂ ≅ ℝ², then for queries and keys transformed by M, the attention weights are preserved: w_j(Mq, Mk₁,...,Mk_N) = w_j(q, k₁,...,k_N).

**Test**: (1) Formalize Möbius transformations as 2×2 matrices acting on ℂ. (2) Show that the Cauchy kernel is Möbius-invariant: K(Mx, My) = K(x,y). This reduces to showing that Möbius transformations are isometries of the sphere's round metric (known classically). (3) Conclude equivariance of normalized weights.

**Impact**: Möbius equivariance would mean stereographic attention has a built-in symmetry group (PSL(2,ℂ) for complex queries, or SO(n+1,1) in general dimension). This is a much richer symmetry than the permutation equivariance of standard attention, and could provide inductive bias for problems with conformal symmetry (fluid dynamics, conformal field theory, computer vision under projective transformations).

**Catalog References**: `Catalog/Geometry/` (for differential geometry infrastructure), `Catalog/Algebra/` (for group actions)

**Proof Strategy**: The key mathematical fact is that Möbius transformations correspond to rotations of the Riemann sphere, and the Cauchy kernel is a function of the spherical distance, which is rotation-invariant. Formalize this chain: Möbius ↔ sphere rotation ↔ distance preservation ↔ kernel invariance.

**Domain Bridges**: Geometry <-> MachineLearning (conformal geometry meets attention), Physics <-> MachineLearning (conformal field theory symmetries)

**Lineage**: Builds on stereo_sqDist_identity and cauchyKernel_comm from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Scaled Cauchy Kernel Optimization

**Conjecture**: For the parametric Cauchy kernel K_α(x,y) = 1/(1 + α‖x-y‖²) with learnable scale α > 0, the optimal α for minimizing the L² distance between Cauchy attention output and softmax attention output satisfies α* = Θ(1/d) where d is the key dimension. This predicts that higher-dimensional attention should use smaller scaling parameters.

**Test**: (1) For fixed query-key configurations of varying dimension d ∈ {2, 4, 8, 16, 32, 64}, numerically optimize α to minimize ‖output_cauchy(α) − output_softmax‖². (2) Fit the relationship α*(d) and test the 1/d hypothesis. (3) Prove analytically that for isotropic Gaussian keys, the optimal α satisfies α* ~ C/d for an explicit constant C.

**Impact**: If confirmed, this gives a principled initialization for the scale parameter, analogous to the 1/√d scaling in standard attention. The proof would reveal the geometric meaning of attention scaling: it compensates for the concentration of measure in high dimensions.

**Catalog References**: `FINAL/MachineLearning/ConvergenceTheory.lean` (geometric_improvement_bound), `MachineLearning/Generalization/SpectralBounds.lean` (scc_bound_tendsto_zero)

**Proof Strategy**: Use the concentration of measure phenomenon: for random keys in ℝᵈ, ‖x-y‖² concentrates around 2d (for unit Gaussian keys). The Cauchy kernel 1/(1+α·2d) should match the typical softmax weight exp(-d)/Z, giving α ~ 1/(2d). Formalize using Gaussian moment bounds.

**Domain Bridges**: MachineLearning <-> Physics (concentration of measure), MachineLearning <-> Computation (algorithmic implications of dimensional scaling)

**Lineage**: Builds on cauchyKernel_antitone_sqDist and cauchy_weight_ratio from this cycle.

**Ambition**: extension
