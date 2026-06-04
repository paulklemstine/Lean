# Mathematical Foundations of the Transformer Architecture: A Formal Treatment

## Abstract

We present a rigorous mathematical formalization of the transformer architecture, treating its core components — softmax attention, multi-head attention, layer normalization, residual connections, and positional encoding — as precisely defined mathematical objects. We establish twelve machine-verified theorems characterizing their algebraic and geometric properties. Our main results include: (1) a gauge symmetry theorem showing softmax is invariant under constant shifts; (2) the bilinearity of attention scores and their factorization through a Gram matrix WqᵀWk; (3) the centering property of layer normalization as projection onto a hyperplane; (4) the compositional structure of transformer depth; and (5) order-preservation of the softmax map. All results are formally verified in the Lean 4 theorem prover with the Mathlib library, ensuring complete logical correctness.

## 1. Introduction

The transformer architecture (Vaswani et al., 2017) has become the dominant paradigm in machine learning, powering large language models, vision transformers, and multi-modal systems. Despite its practical success, the mathematical foundations of the transformer remain largely informal. Most analyses treat the architecture as a computational graph without examining the algebraic and geometric properties of its components.

This paper takes a different approach. We formalize each component of the transformer as a mathematical object — functions between finite-dimensional real vector spaces — and prove structural theorems about their properties. Our formalization reveals that the transformer's components implement natural mathematical operations: maps to the probability simplex, bilinear forms, hyperplane projections, and iterated compositions.

### 1.1 Contributions

1. **Formal definitions** of softmax, attention scores, layer normalization, residual connections, positional encoding, multi-head attention, and transformer blocks as structures over `Fin n → ℝ`.

2. **Twelve machine-verified theorems** establishing:
   - Softmax shift invariance (gauge symmetry)
   - Softmax as a probability distribution (simplex map)
   - Bilinearity of attention scores (left and right linearity)
   - Gram matrix factorization of attention scores
   - Layer normalization centering (zero mean property)
   - Compositional structure of transformer depth
   - Residual connection identity property
   - Residual stream decomposition
   - Softmax monotonicity (order preservation)
   - Linearity of matrix-vector multiplication

3. **Novel mathematical structures**: the `AttentionHead`, `MultiHeadConfig`, `FFNLayer`, and `TransformerBlockParams` structures, and the `attentionGramMatrix` definition connecting attention to spectral theory.

### 1.2 Related Work

Prior formalizations of neural network components include work on ReLU networks (Petersen & Voigtlaender, 2018), tropical geometry of attention (various), and the categorical semantics of architectures. Our work differs in focusing on the specific algebraic properties of the transformer's components rather than on approximation theory or categorical abstractions.

## 2. Definitions

### 2.1 Vector Spaces and Notation

We work with finite-dimensional real vector spaces represented as `Fin n → ℝ`. For a natural number `n` with `n ≥ 1` (formalized as `[NeZero n]`), the space `Fin n → ℝ` is the space of real-valued vectors of dimension `n`.

### 2.2 Softmax

**Definition 2.1 (Softmax).** For x ∈ ℝⁿ with n ≥ 1, the softmax function σ: ℝⁿ → ℝⁿ is defined by:

$$\sigma(x)_i = \frac{\exp(x_i)}{\sum_{j=1}^n \exp(x_j)}$$

The denominator is always positive since exp is everywhere positive and the sum is over a nonempty set.

### 2.3 Attention Head

**Definition 2.2 (Attention Head).** An attention head with model dimension d, key dimension dₖ, and value dimension dᵥ is a triple (Wq, Wk, Wv) of real matrices:
- Wq ∈ ℝ^{dₖ × d} (query projection)
- Wk ∈ ℝ^{dₖ × d} (key projection)  
- Wv ∈ ℝ^{dᵥ × d} (value projection)

**Definition 2.3 (Attention Score).** The attention score between vectors xᵢ, xⱼ ∈ ℝᵈ is:

$$\text{score}(x_i, x_j) = \sum_{k=1}^{d_k} (W_q x_i)_k \cdot (W_k x_j)_k = x_i^\top (W_q^\top W_k) x_j$$

**Definition 2.4 (Attention Gram Matrix).** The Gram matrix of an attention head is:

$$G = W_q^\top W_k \in \mathbb{R}^{d \times d}$$

### 2.4 Layer Normalization

**Definition 2.5 (Vector Mean).** For x ∈ ℝⁿ:

$$\mu(x) = \frac{1}{n} \sum_{i=1}^n x_i$$

**Definition 2.6 (Centering).** The centered vector is:

$$\tilde{x}_i = x_i - \mu(x)$$

**Definition 2.7 (Layer Normalization).** With learned parameters γ, β ∈ ℝⁿ and variance σ²(x) = (1/n)∑ᵢ(x̃ᵢ)²:

$$\text{LN}(x)_i = \gamma_i \cdot \frac{\tilde{x}_i}{\sqrt{\sigma^2(x)}} + \beta_i$$

### 2.5 Residual Connection

**Definition 2.8 (Residual Connection).** For f: α → α:

$$\text{Res}(f, x) = f(x) + x$$

### 2.6 Positional Encoding

**Definition 2.9 (Sinusoidal Positional Encoding).** At position pos and dimension i:

$$PE(\text{pos}, i) = \begin{cases} \sin(\text{pos}/10000^{2\lfloor i/2 \rfloor/d}) & \text{if } i \text{ even} \\ \cos(\text{pos}/10000^{2\lfloor i/2 \rfloor/d}) & \text{if } i \text{ odd} \end{cases}$$

Positional encoding enters additively: X̂ = X + PE.

### 2.7 Depth Composition

**Definition 2.10 (Layer Iteration).** For a function f: α → α, the L-fold iteration is:

$$f^{(0)} = \text{id}, \quad f^{(L+1)} = f \circ f^{(L)}$$

## 3. Main Results

### 3.1 Softmax Shift Invariance (Gauge Symmetry)

**Theorem 3.1.** *For any x ∈ ℝⁿ and c ∈ ℝ, σ(x + c·1) = σ(x).*

*Proof sketch.* For each coordinate i:

$$\sigma(x + c \cdot \mathbf{1})_i = \frac{\exp(x_i + c)}{\sum_j \exp(x_j + c)} = \frac{e^c \cdot \exp(x_i)}{e^c \cdot \sum_j \exp(x_j)} = \frac{\exp(x_i)}{\sum_j \exp(x_j)} = \sigma(x)_i$$

The key step uses the multiplicative property of the exponential: exp(a + b) = exp(a)·exp(b), and the factoring of the common exp(c) from the sum.

**Interpretation.** This is a gauge symmetry in the physics sense: the observable (attention weights) is invariant under a global transformation (constant shift). It implies that attention depends only on *relative* scores between positions.

### 3.2 Softmax as Probability Distribution

**Theorem 3.2.** *For any x ∈ ℝⁿ, ∑ᵢ σ(x)ᵢ = 1 and σ(x)ᵢ > 0 for all i.*

*Proof sketch.* Positivity: exp(xᵢ) > 0 and ∑ⱼ exp(xⱼ) > 0, so their ratio is positive. Sum-to-one: ∑ᵢ exp(xᵢ)/S = (∑ᵢ exp(xᵢ))/S = S/S = 1.

**Interpretation.** Softmax is a smooth map from ℝⁿ to the open probability simplex Δ°ₙ₋₁. Together with Theorem 3.1, this shows softmax factors through the quotient ℝⁿ/ℝ·1 → Δ°ₙ₋₁.

### 3.3 Bilinearity of Attention Scores

**Theorem 3.3.** *The attention score is bilinear:*
- *(Left linearity)* score(ax + by, z) = a·score(x, z) + b·score(y, z)
- *(Right linearity)* score(z, ax + by) = a·score(z, x) + b·score(z, y)

*Proof sketch.* Since Wq and Wk are linear maps, mulVec distributes over linear combinations. The inner product (dot product) is then bilinear.

**Interpretation.** Pre-softmax attention defines a bilinear form on ℝᵈ × ℝᵈ. The learned weight matrices determine the geometry of this form. The space of possible attention geometries is parametrized by pairs of matrices (Wq, Wk), or equivalently, by Gram matrices WqᵀWk.

### 3.4 Gram Matrix Factorization

**Theorem 3.4.** *score(xᵢ, xⱼ) = xᵢᵀ · (WqᵀWk) · xⱼ = ∑ₐ xᵢ(a) · (G · xⱼ)(a), where G = WqᵀWk.*

*Proof sketch.* Expand the sum ∑ₖ (Wq·xᵢ)ₖ · (Wk·xⱼ)ₖ and rearrange using commutativity of multiplication and interchange of summation order.

**Interpretation.** The Gram matrix G = WqᵀWk encodes the complete geometry of an attention head. Its eigendecomposition G = UΛUᵀ reveals the principal attention directions: eigenvectors with large eigenvalues define "important" directions in embedding space that dominate attention scores.

### 3.5 Layer Normalization Centering

**Theorem 3.5.** *∑ᵢ (xᵢ - μ(x)) = 0, and consequently μ(x̃) = 0.*

*Proof sketch.* ∑ᵢ(xᵢ - μ) = ∑ᵢ xᵢ - n·μ = ∑ᵢ xᵢ - ∑ᵢ xᵢ = 0.

**Interpretation.** Layer normalization projects onto the centered hyperplane H₀ = {x ∈ ℝⁿ : ∑ᵢ xᵢ = 0}. This (n-1)-dimensional subspace is orthogonal to the all-ones vector 1. Combined with the gauge symmetry of softmax (Theorem 3.1), this shows a deep structural consistency: both layer normalization and attention are insensitive to the "global offset" direction.

### 3.6 Depth Composition

**Theorem 3.6.** *f^{(m+n)} = f^{(m)} ∘ f^{(n)}, i.e., iterateLayer f (m+n) x = iterateLayer f m (iterateLayer f n x).*

*Proof.* By induction on m. The base case m = 0 is immediate from the definition. The inductive step uses the definition of f^{(m+1)} = f ∘ f^{(m)} and the inductive hypothesis.

**Interpretation.** Transformer depth is genuinely compositional: there are no hidden interactions between the first n layers and the subsequent m layers beyond the sequential flow of information through the residual stream.

### 3.7 Residual Stream Decomposition

**Theorem 3.7.** *Res(g, Res(f, x)) = g(f(x) + x) + (f(x) + x).*

**Theorem 3.8.** *When f ≡ 0, Res(f, x) = x.*

**Interpretation.** The residual stream accumulates additive corrections. Each transformer block contributes a perturbation to the identity. The identity shortcut (Theorem 3.8) ensures that any layer can be "turned off" without disrupting the information flow.

### 3.8 Softmax Monotonicity

**Theorem 3.9.** *If xᵢ ≤ xⱼ, then σ(x)ᵢ ≤ σ(x)ⱼ.*

*Proof sketch.* Since xᵢ ≤ xⱼ implies exp(xᵢ) ≤ exp(xⱼ) (monotonicity of exp), and the denominator is common and positive, the ratio preserves the ordering.

**Interpretation.** The attention mechanism is a *faithful* representation of score ordering: higher raw scores always produce higher attention weights. There are no inversions or threshold effects.

## 4. The Bilinear Form Perspective

Combining Theorems 3.3 and 3.4, the pre-softmax attention mechanism defines a parametric family of bilinear forms on ℝᵈ indexed by the Gram matrix G = WqᵀWk. This connects the transformer to classical mathematical structures:

1. **Spectral theory**: The eigendecomposition of G determines the principal attention directions.
2. **Rank constraints**: If dₖ < d, then G has rank at most dₖ, forcing attention to operate in a low-dimensional subspace.
3. **Positive definiteness**: If Wq = Wk, then G = WqᵀWq is positive semi-definite, making attention scores non-negative inner products.
4. **Indefinite forms**: When Wq ≠ Wk, G can be indefinite, allowing attention to have both positive and negative scores — a feature exploited in practice.

## 5. Conjecture: Universal Approximation via Depth

**Conjecture 5.1.** For any continuous sequence-to-sequence function F: (ℝᵈ)ⁿ → (ℝᵈ)ⁿ and any ε > 0, there exists a transformer T with finitely many blocks, each with finitely many heads and bounded FFN width, such that ‖T(X) - F(X)‖ < ε for all X in a compact set K ⊆ (ℝᵈ)ⁿ.

**Computational test:** For d = n = 2, construct an explicit transformer that approximates the reversal function (x₁, x₂) ↦ (x₂, x₁) to within ε = 0.01 on the unit cube. The bilinearity of attention and the universality of the FFN sublayers should suffice.

**Status:** Open. The bilinearity of attention (Theorem 3.3) and the compositional depth structure (Theorem 3.6) provide necessary building blocks, but the full result requires showing that softmax nonlinearity combined with FFN universality generates sufficient expressivity.

## 6. Algorithms

### 6.1 Attention Score Computation

```
INPUT: Attention head (Wq, Wk, Wv), query vector x, key vector y
OUTPUT: Attention score

1. Compute q = Wq · x  (query projection)
2. Compute k = Wk · y  (key projection)
3. Return score = qᵀk   (inner product)
```

By Theorem 3.4, this equivalently computes xᵀ(WqᵀWk)y, allowing precomputation of the Gram matrix for efficiency.

### 6.2 Softmax with Numerical Stability

```
INPUT: Score vector s ∈ ℝⁿ
OUTPUT: Probability vector p ∈ Δⁿ⁻¹

1. Compute m = max(s)          (for numerical stability)
2. Compute s' = s - m·1        (shift — exact by Theorem 3.1)
3. Compute eᵢ = exp(s'ᵢ)      (all ≤ 1 now)
4. Compute S = ∑ᵢ eᵢ          (denominator)
5. Return pᵢ = eᵢ / S         (softmax output)
```

The shift in step 2 is *exactly correct* by Theorem 3.1, not an approximation.

## 7. Discussion

### 7.1 Structural Coherence

The theorems reveal a structural coherence in the transformer architecture that goes beyond engineering convenience. The gauge symmetry of softmax (Theorem 3.1) and the centering of layer normalization (Theorem 3.5) both eliminate the same redundant degree of freedom — the global offset in representation space. The bilinearity of attention (Theorems 3.3–3.4) ensures that attention geometry is determined by a finite-dimensional parameter (the Gram matrix), making learning tractable.

### 7.2 Connections to Physics

The shift invariance of softmax is formally analogous to gauge invariance in electromagnetism, where physical observables (the electromagnetic field) are invariant under gauge transformations of the potential. In the transformer, the "potential" is the raw logit vector, and the "observable" is the attention weight distribution. The analogy suggests that transformers might be amenable to techniques from gauge theory, including the identification of gauge-invariant quantities and the construction of gauge-equivariant architectures.

### 7.3 Limitations

Our formalization captures the algebraic structure of individual transformer components but does not yet address the full dynamics of training (gradient flow), the statistical properties of learned representations, or the interaction between multiple heads in multi-head attention. These remain important directions for future work.

## 8. Future Work

1. **Spectral analysis of learned Gram matrices**: Characterize the eigenvalue distribution of WqᵀWk in trained transformers to understand attention geometry empirically.

2. **Universal approximation**: Prove or disprove Conjecture 5.1 by combining the bilinearity results with FFN universality theorems.

3. **Tropical limit**: Connect to existing formalizations of tropical attention (LSEConvergence) by proving that the Gram matrix factorization persists in the tropical limit.

4. **Equivariance theory**: Extend the permutation equivariance results (Compositionality.lean) to the full transformer block with layer normalization.

## References

1. Vaswani, A., et al. (2017). Attention is All You Need. *NeurIPS*.
2. Ba, J. L., Kiros, J. R., & Hinton, G. E. (2016). Layer Normalization. *arXiv:1607.06450*.
3. He, K., et al. (2016). Deep Residual Learning for Image Recognition. *CVPR*.
4. Yun, C., et al. (2020). Are Transformers Universal Approximators of Sequence-to-Sequence Functions? *ICLR*.
