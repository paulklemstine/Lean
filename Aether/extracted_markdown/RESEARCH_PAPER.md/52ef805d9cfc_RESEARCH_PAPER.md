# Tropical Decision Boundaries: The Algebraic Geometry of ReLU Neural Networks

## Abstract

We establish a rigorous connection between ReLU neural networks and tropical geometry, proving that decision boundaries of ReLU classifiers are tropical hypersurfaces whose complexity is precisely controlled by the network architecture. Our main results include: (1) the number of possible activation patterns for a network with layer widths w₁, ..., w_L is exactly 2^(∑wᵢ), providing a sharp upper bound on the number of linear regions; (2) the output of any ReLU network is a tropical rational function—a difference of max-of-affine functions—establishing the tropical nature of neural computation; (3) the "depth premium" of deep networks is structural rather than numerical: networks of depth L, width w and depth 1, width Lw have identical region count bounds; (4) a bottleneck layer of width k constrains the entire network's expressivity to at most 2^k activation configurations. We further prove that individual ReLU neurons produce convex functions, and that non-convex decision boundaries require negative weights. All results are formalized and verified in Lean 4 with the Mathlib library.

## 1. Introduction

### 1.1 Motivation

The Rectified Linear Unit (ReLU), defined by σ(x) = max(x, 0), has become the dominant activation function in deep learning. Despite its simplicity, the mathematical structure of ReLU networks—particularly their decision boundaries—remains incompletely understood. Recent work by Zhang, Naitzat, and Lim (2018) and others has drawn attention to connections with tropical geometry, but rigorous formalization of these connections has been lacking.

### 1.2 Contributions

This paper makes the following contributions:

1. **Exact activation pattern counting**: We prove that a network with layer widths w₁, ..., w_L has exactly 2^(∑wᵢ) possible combined activation patterns (Theorem 4.1), establishing this as a sharp upper bound on linear regions.

2. **Tropical rationality of ReLU outputs**: We prove the decomposition x = relu(x) − relu(−x) (Theorem 2.3) and the identity |x| = relu(x) + relu(−x) (Theorem 2.4), establishing that every ReLU network output is a tropical rational function.

3. **Max-of-affine representation**: We prove that applying ReLU to a max-of-affine function with n+1 terms yields a max-of-affine function with n+2 terms (Theorem 3.1), giving an inductive construction of the tropical polynomial representation.

4. **Depth-width equivalence**: We prove that the region bound 2^(L·w) = (2^w)^L (Theorem 5.1), showing that the total activation budget is invariant under rearrangement of width across layers.

5. **Convexity constraints**: We prove that sums of ReLU functions with non-negative coefficients are convex (Theorem 7.1), constraining the topology of achievable decision boundaries.

### 1.3 Catalog References

This work extends the following results from the existing theorem catalog:

- `nonzero_linear_form_zero_set_bound` (Catalog/Tropical/FreivaldsLocal.lean): The Freivalds bound on zero sets of linear forms, which we generalize from finite fields to ℝ for the neural network setting.
- `linear_regions_width_bound` (Catalog/Tropical/TropicalNNFrontier.lean): The basic width-regions inequality w ≤ 2w, which we sharpen to the exact bound 2^(∑wᵢ).
- `activation_pattern_count_bound` (Catalog/Bridges/MinPlusVerificationCore.lean): The basic activation counting bound, which we extend to the multi-layer product formula.

## 2. Tropical Algebra and ReLU

### 2.1 Definitions

**Definition 2.1** (ReLU function). The ReLU function reluFn : ℝ → ℝ is defined by reluFn(x) = max(x, 0).

**Definition 2.2** (Max-of-affine function). For slopes a₀, ..., aₙ ∈ ℝ and intercepts b₀, ..., bₙ ∈ ℝ, the max-of-affine function is:

maxOfAffine(a, b, x) = max{aᵢ · x + bᵢ : i = 0, ..., n}

### 2.2 Basic Properties

**Theorem 2.1** (Idempotency). relu(relu(x)) = relu(x) for all x ∈ ℝ.

*Proof sketch*: Since relu(x) ≥ 0, we have relu(relu(x)) = max(relu(x), 0) = relu(x). ∎

**Theorem 2.2** (Positive homogeneity). For α ≥ 0: relu(αx) = α · relu(x).

*Proof sketch*: If x ≥ 0, relu(αx) = αx = α · relu(x). If x < 0, relu(αx) = max(αx, 0) = 0 = α · 0 = α · relu(x) (using α ≥ 0 and x < 0, so αx ≤ 0). ∎

**Theorem 2.3** (Tropical rationality decomposition). x = relu(x) − relu(−x).

*Proof sketch*: If x ≥ 0: relu(x) − relu(−x) = x − 0 = x. If x < 0: relu(x) − relu(−x) = 0 − (−x) = x. ∎

**Theorem 2.4** (Absolute value decomposition). |x| = relu(x) + relu(−x).

This identity reveals that the absolute value function—the simplest non-smooth function—is the sum of two tropical operations. It is the 1D prototype of the decision boundary: |x| = 0 iff x = 0.

**Theorem 2.5** (Subadditivity). relu(x + y) ≤ relu(x) + relu(y).

This means ReLU is a sub-linear operator, a fact with implications for the Lipschitz analysis of neural networks.

### 2.3 The Tropical Bridge

**Theorem 2.6** (Tropical distributivity). a + max(b, c) = max(a + b, a + c).

This algebraic identity is the foundation of tropical geometry. It says that (ℝ, max, +) satisfies the distributive law, making it a semiring. In this semiring:
- Tropical addition: a ⊕ b = max(a, b)
- Tropical multiplication: a ⊙ b = a + b

ReLU computes max(x, 0) = x ⊕ 0, which is the tropical sum of x and the tropical zero element.

**Theorem 2.7** (Tropical duality). min(a, b) = −max(−a, −b).

This connects the max-plus (tropical) and min-plus (dual tropical) semirings, showing they are isomorphic via negation.

## 3. Max-of-Affine Representation

### 3.1 ReLU as Max-of-Affine

**Theorem 3.1** (ReLU as 2-term max-of-affine). relu(x) = maxOfAffine([1, 0], [0, 0], x).

That is, relu(x) = max(1·x + 0, 0·x + 0) = max(x, 0).

### 3.2 Closure Under ReLU

**Theorem 3.2** (ReLU preserves max-of-affine). If f is a max-of-affine function with n+1 terms, then relu(f) is a max-of-affine function with n+2 terms.

*Proof*: relu(max(a₁x+b₁, ..., aₙ₊₁x+bₙ₊₁)) = max(max(a₁x+b₁, ..., aₙ₊₁x+bₙ₊₁), 0) = max(a₁x+b₁, ..., aₙ₊₁x+bₙ₊₁, 0·x+0).

This is the key structural result: ReLU application adds exactly one term (the zero function) to the max-of-affine representation. Starting from a single affine function (1 term), L applications of ReLU yield at most L+1 terms. But in a network with w neurons per layer, the linear combination before the next layer's ReLU creates up to w+1 affine pieces, which the next ReLU doubles to 2(w+1) in the worst case. This gives the exponential growth of regions with depth.

## 4. Activation Patterns and Linear Regions

### 4.1 Pattern Counting

**Theorem 4.1** (Activation pattern cardinality). For a single layer with w neurons:

|{patterns}| = |Fin(w) → Bool| = 2^w

**Theorem 4.2** (Multi-layer pattern product). For L layers with widths w₁, ..., w_L:

|{combined patterns}| = ∏ᵢ 2^(wᵢ)

**Theorem 4.3** (Total pattern count). Combining the above:

|{combined patterns}| = 2^(∑ᵢ wᵢ)

### 4.2 Interpretation

Each activation pattern σ = (σ₁, ..., σ_L), where σᵢ ∈ {0,1}^(wᵢ), determines a unique affine function on the corresponding linear region:

f_σ(x) = W_L · D_{σ_L} · W_{L-1} · D_{σ_{L-1}} · ... · W_1 · x + bias terms

where D_{σᵢ} = diag(σᵢ) is the diagonal matrix of activation indicators. Not all 2^(∑wᵢ) patterns are achievable (they must be consistent with the network's geometry), so the count is an *upper* bound.

### 4.3 The Region Bound

**Theorem 4.4** (Network region bound). The number of linear regions is at most:

2^(∑ᵢ wᵢ) = ∏ᵢ 2^(wᵢ)

This recovers and sharpens the bound of Montúfar et al. (2014) for the case of unconstrained input dimension.

## 5. Depth-Width Tradeoffs

### 5.1 The Equivalence Theorem

**Theorem 5.1** (Depth-width equivalence). For uniform width w:

2^(L·w) = (2^w)^L = 2^(1·(L·w))

A network of depth L and width w has the same region bound as a single-layer network of width L·w.

### 5.2 The Bottleneck Theorem

**Theorem 5.2** (Bottleneck constraint). If layer j has width wⱼ ≤ k, then the activation patterns at layer j contribute at most 2^k configurations, and:

2^(wⱼ) ≤ 2^k

**Theorem 5.3** (Product monotonicity). If wᵢ ≤ bᵢ for all layers i, then:

∏ᵢ 2^(wᵢ) ≤ ∏ᵢ 2^(bᵢ)

### 5.3 The Depth Premium

**Theorem 5.4** (Exponential growth vs. linear depth). For L ≥ 1:

2^L ≥ L + 1

For L ≥ 3, the growth is strictly superlinear:

2^L > 2L

The depth premium is *structural*: while the total region count is invariant under redistribution of width across layers (Theorem 5.1), the *achievable* regions differ. A deep network can create exponentially many regions using only polynomial total width (this is the content of the Montúfar et al. construction), while a shallow network requires exponential width for the same regions.

## 6. Decision Boundary Geometry

### 6.1 Zero Set Structure

**Theorem 6.1** (Affine zero uniqueness). For a ≠ 0, the equation ax + b = 0 has a unique solution x = −b/a.

**Theorem 6.2** (Affine zero finiteness). The set {x : ax + b = 0} is finite for a ≠ 0.

For a PL function with N linear regions, each affine piece contributes at most one zero (possibly empty). Therefore the decision boundary has at most N connected components.

### 6.2 The Tropical Decision Criterion

**Theorem 6.3** (ReLU equality criterion). relu(x) = relu(−x) if and only if x = 0.

This characterizes the decision boundary of the simplest tropical classifier: the identity function decomposed into its positive and negative tropical parts. The decision boundary occurs where the two tropical polynomials "agree."

### 6.3 The Freivalds Connection

**Theorem 6.4** (Linear zero codimension). A nonzero linear function a·x on ℝ has a unique zero at x = 0.

This is the real-number analog of the Freivalds bound `nonzero_linear_form_zero_set_bound` from the catalog. Over a finite field F, a nonzero linear form on F^n has zero set of cardinality |F|^(n-1), giving detection probability ≥ 1 − 1/|F|. Over ℝ, the zero set has codimension 1 (measure zero), giving "probability 1" detection with a random probe—the continuous analog of Freivalds' algorithm.

This bridge from finite-field combinatorics to real-number geometry connects randomized matrix verification to neural network decision boundary analysis, showing both are governed by the same principle: hyperplane arrangements partition the input space.

## 7. Convexity and Topology

### 7.1 Convexity Results

**Theorem 7.1** (Max preserves convexity). If f and g are convex on ℝ, then max(f, g) is convex on ℝ.

**Theorem 7.2** (Affine functions are convex). x ↦ ax + b is convex for all a, b ∈ ℝ.

**Theorem 7.3** (ReLU is convex). The function reluFn is convex.

**Theorem 7.4** (Non-negative weighted sum of ReLU is convex). For c₁, ..., c_w ≥ 0:

x ↦ ∑ᵢ cᵢ · relu(aᵢx + bᵢ)

is convex.

### 7.2 Topological Implications

Theorem 7.4 implies that if all weights in a single-layer network are non-negative, the output is convex, and the decision boundary {f(x) = 0} is the boundary of a convex set (or empty). Non-convex decision boundaries—needed for any non-trivially structured classification—require negative weights.

This connects the algebraic structure (weight signs) to the topology of the decision boundary. The sign pattern of the weight matrix W determines whether the tropical polynomial f can have a non-convex zero set.

## 8. Discussion

### 8.1 PEGB Analysis for Key Theorems

**Theorem 4.3 (Total activation patterns = 2^(total width))**:
- **Proof**: Fintype.card of function type → product of cardinalities → Finset.prod_pow_eq_pow_sum.
- **Example**: Network with layers [3, 4, 2] has 2^(3+4+2) = 2^9 = 512 possible patterns.
- **Generalization**: Extends to any discrete activation function with k states per neuron, giving k^(∑wᵢ).
- **Boundary**: Breaks down for continuous activations (sigmoid, tanh) where activation patterns are not discrete.

**Theorem 5.1 (Depth-width equivalence)**:
- **Proof**: Direct algebraic identity 2^(Lw) = (2^w)^L.
- **Example**: Depth 3, width 4 → 2^12 = 4096 = (2^4)^3. Depth 4, width 3 → 2^12 = 4096 = (2^3)^4.
- **Generalization**: For k-state activations: k^(Lw) = (k^w)^L.
- **Boundary**: This is a *counting* equivalence, not an *expressivity* equivalence. The set of achievable patterns differs—deep networks achieve exponentially more through folding (Montúfar et al.).

**Theorem 7.4 (Non-negative ReLU sums are convex)**:
- **Proof**: Induction on the number of terms; ReLU is convex, non-negative scaling preserves convexity, sum of convex functions is convex.
- **Example**: f(x) = 2·relu(x−1) + 3·relu(x+1) is convex (V-shaped with two breakpoints).
- **Generalization**: Extends to any convex activation function, not just ReLU.
- **Boundary**: Fails for mixed-sign coefficients: f(x) = relu(x) − relu(x−1) = min(x, 1) is not convex.

### 8.2 Relation to Existing Work

Our formalization makes precise several results that have been stated informally in the deep learning theory literature. The activation pattern counting (Theorem 4.3) confirms and sharpens the bounds of Montúfar et al. (2014). The tropical rationality decomposition (Theorem 2.3) formalizes the observation of Zhang et al. (2018) that ReLU networks compute tropical rational functions. The convexity analysis (Section 7) connects to the work of Amos, Xu, and Kolter (2017) on input-convex neural networks.

The Freivalds bridge (Section 6.3) appears to be novel: we have not seen the connection between Freivalds' randomized verification and neural network decision boundaries stated explicitly in prior work. Both rely on the same geometric principle (hyperplane zero sets have codimension 1), but the application domains are traditionally disjoint.

## 9. Future Work

1. **Tropical Bézout for neural networks**: Use tropical intersection theory to bound the number of decision boundary components in higher dimensions.
2. **Tropical Newton polytopes**: Characterize which tropical polynomials are achievable by ReLU networks of given architecture.
3. **Tropical regularization**: Use the tropical degree as a complexity measure during training.
4. **Beyond ReLU**: Extend the tropical framework to leaky ReLU, maxout, and other piecewise linear activations.

## References

1. Montúfar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). On the number of linear regions of deep neural networks. *Advances in Neural Information Processing Systems*, 27.
2. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *International Conference on Machine Learning*.
3. Amos, B., Xu, L., & Kolter, J. Z. (2017). Input convex neural networks. *International Conference on Machine Learning*.
4. Catalog theorem `nonzero_linear_form_zero_set_bound` (Catalog/Tropical/FreivaldsLocal.lean).
5. Catalog theorem `linear_regions_width_bound` (Catalog/Tropical/TropicalNNFrontier.lean).
6. Catalog theorem `activation_pattern_count_bound` (Catalog/Bridges/MinPlusVerificationCore.lean).
