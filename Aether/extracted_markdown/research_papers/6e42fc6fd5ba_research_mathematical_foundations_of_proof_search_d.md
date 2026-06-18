# Proof Search Dimension: Fractal Geometry of Theorem Difficulty

## Abstract

We develop the mathematical foundations of **proof search dimension**, a continuous measure of theorem difficulty based on the fractal geometry of successful proof paths in search trees. For a uniform search tree with branching factor *b* and *k* surviving branches per node (1 ≤ k ≤ b, b ≥ 2), the search dimension D = log(k)/log(b) ∈ [0,1] provides a complete classification of search difficulty. We establish sharp phase transitions at D = 0 (deterministic search, k = 1) and D = 1 (trivial search, k = b), prove monotonicity in the surviving count, derive a product composition law for independent searches, and connect the dimension to exponential decay rates of success probability. We introduce heterogeneous search dimension for non-uniform branching and prove consistency with the uniform case. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: proof search, fractal dimension, search complexity, phase transitions, entropy, heterogeneous branching

---

## 1. Introduction

The question of why some mathematical theorems are harder to prove than others has been studied primarily through the lens of computational complexity theory, which classifies problems into discrete classes (P, NP, PSPACE, etc.). While powerful, this classification is coarse — it groups together problems of vastly different practical difficulty and provides no continuous measure of "how hard" a specific theorem is within a complexity class.

We propose an alternative framework based on **fractal geometry**. Consider a proof search tree where each node represents a proof state, and edges represent proof steps (tactic applications, lemma selections, etc.). At each node, there are *b* possible moves, of which *k* lead toward a valid proof. The set of successful paths through depth *d* has cardinality k^d, embedded in a tree of total size b^d.

By analogy with Hausdorff dimension, we define the **search dimension** as D = log(k)/log(b). This quantity:
- Is continuous, ranging from 0 to 1
- Equals 0 if and only if k = 1 (deterministic search)
- Equals 1 if and only if k = b (trivial search)
- Determines the exponential decay rate of success probability with depth
- Satisfies a natural composition law for independent sub-problems

### 1.1 Related Work

The connection between search and fractals has been explored in percolation theory (Grimmett, 1999) and random graph theory (Bollobás, 2001), where critical exponents characterize phase transitions. Our framework differs in that the "fractal" is defined on the search tree itself rather than an external geometric object.

The relationship between search dimension and information theory connects to work on entropy-based complexity measures (Grünwald & Vitányi, 2003) and the study of Kolmogorov complexity of proofs (Li & Vitányi, 2008).

## 2. Definitions

### 2.1 Search Parameters

**Definition 2.1 (Search Parameters).** A *search parameter set* is a triple T = (k, b, h) where:
- k ∈ ℕ is the *surviving count* (number of successful branches per node)
- b ∈ ℕ is the *branching factor* (total branches per node)
- h = (hk_pos, hk_le, hb) is a proof that 1 ≤ k ≤ b and 2 ≤ b

The constraint k ≥ 1 ensures at least one successful path exists. The constraint b ≥ 2 ensures the tree genuinely branches (otherwise dimension is undefined).

### 2.2 Search Dimension

**Definition 2.2 (Search Dimension).** For search parameters T = (k, b, h), the *search dimension* is:

$$D(T) = \frac{\log k}{\log b}$$

where log denotes the natural logarithm.

### 2.3 Entropy Deficit

**Definition 2.3 (Search Entropy Deficit).** The *entropy deficit* of T is:

$$\Delta(T) = 1 - D(T)$$

This measures the fraction of the search tree that leads to dead ends.

### 2.4 Heterogeneous Search Trees

**Definition 2.4 (Heterogeneous Search Tree).** A *heterogeneous search tree* of depth d (d ≥ 1) is a sequence of level parameters H = (d, (k_i, b_i)_{i=1}^d) where each (k_i, b_i) satisfies 1 ≤ k_i ≤ b_i and b_i ≥ 2.

**Definition 2.5 (Heterogeneous Search Dimension).** The *heterogeneous search dimension* is:

$$D(H) = \frac{\sum_{i=1}^d \log k_i}{\sum_{i=1}^d \log b_i}$$

### 2.5 Success Probability

**Definition 2.6 (Success Probability).** The probability of finding a successful path at depth d in a uniform search tree T = (k, b, h) is:

$$P(T, d) = \left(\frac{k}{b}\right)^d$$

## 3. Main Results

### 3.1 Dimension Bounds

**Theorem 3.1 (Nonnegativity).** For any search parameters T, D(T) ≥ 0.

*Proof sketch.* Since k ≥ 1, we have log(k) ≥ 0. Since b ≥ 2, we have log(b) > 0. The ratio of a nonneg number by a positive number is nonneg. □

**Theorem 3.2 (Upper Bound).** For any search parameters T, D(T) ≤ 1.

*Proof sketch.* Since k ≤ b and both are positive, log(k) ≤ log(b) by monotonicity of log. Since log(b) > 0, dividing both sides by log(b) yields D(T) ≤ 1. □

### 3.2 Phase Transitions

**Theorem 3.3 (Left Phase Transition).** D(T) = 0 if and only if k = 1.

*Proof sketch.* Since log(b) > 0, D = 0 iff log(k) = 0. For natural numbers k ≥ 1, log(k) = 0 iff k = 1 (since log is injective on positives and log(1) = 0). □

**Theorem 3.4 (Right Phase Transition).** D(T) = 1 if and only if k = b.

*Proof sketch.* D = 1 iff log(k) = log(b) (dividing both sides by the positive quantity log(b)). By injectivity of log on the positive reals, this holds iff k = b. □

These two theorems establish **sharp phase transitions**: the boundary values D = 0 and D = 1 are achieved exactly at the extremes of the parameter space.

### 3.3 Monotonicity

**Theorem 3.5 (Monotonicity in Surviving Count).** If T₁ and T₂ have the same branching factor and k₁ ≤ k₂, then D(T₁) ≤ D(T₂).

*Proof sketch.* Monotonicity of log gives log(k₁) ≤ log(k₂). Since the common denominator log(b) is positive, the ratio preserves the inequality. □

### 3.4 Product Composition Law

**Definition 3.6 (Product Search).** The product of T₁ = (k₁, b₁) and T₂ = (k₂, b₂) is T₁ × T₂ = (k₁k₂, b₁b₂).

**Theorem 3.7 (Product Law).** The dimension of the product satisfies:

$$D(T_1 \times T_2) \cdot \log(b_1 b_2) = D(T_1) \cdot \log(b_1) + D(T_2) \cdot \log(b_2)$$

*Proof sketch.* The LHS equals log(k₁k₂) by canceling log(b₁b₂). The RHS equals log(k₁) + log(k₂) by canceling each log(b_i). Both sides equal log(k₁k₂) = log(k₁) + log(k₂) by the product rule for logarithms. □

**Corollary.** When b₁ = b₂ = b, the product dimension is the average: D(T₁ × T₂) = (D(T₁) + D(T₂))/2.

### 3.5 Success Probability Decay

**Theorem 3.8 (Decay Rate).** The logarithm of the success probability satisfies:

$$\log P(T, d) = d \cdot (D(T) - 1) \cdot \log b$$

*Proof sketch.* log(P) = log((k/b)^d) = d · log(k/b) = d · (log(k) − log(b)). Factor out log(b): d · (log(k)/log(b) − 1) · log(b) = d · (D − 1) · log(b). □

This shows the search dimension directly controls the exponential decay rate of success probability. When D = 1, log(P) = 0 for all d (success probability stays at 1). When D = 0, log(P) = −d · log(b), giving the maximal decay rate.

### 3.6 Entropy Deficit Properties

**Theorem 3.9.** The entropy deficit satisfies:
- Δ(T) + D(T) = 1
- 0 ≤ Δ(T) ≤ 1

**Theorem 3.10 (Entropy Interpretation).** The entropy deficit Δ = 1 − D can be interpreted as the "wasted information" fraction. At depth d, the total information in the tree is d · log(b), while the information needed to specify a successful path is d · D · log(b). The deficit d · Δ · log(b) represents information devoted to dead-end branches.

### 3.7 Heterogeneous Consistency

**Theorem 3.11 (Uniform Reduction).** A heterogeneous tree where all levels have the same parameters (k, b) has heterogeneous dimension equal to the uniform dimension D = log(k)/log(b).

*Proof sketch.* The numerator is d · log(k) and the denominator is d · log(b). Cancel d (which is ≥ 1, hence nonzero) to obtain log(k)/log(b). □

**Theorem 3.12 (Nonnegativity).** The heterogeneous search dimension is nonneg.

## 4. Algorithms

### 4.1 Dimension Computation

Given (k, b), compute D = log(k)/log(b) in O(1) time using floating-point logarithms.

### 4.2 Heterogeneous Dimension Estimation

Given a sequence of level parameters (k_i, b_i) for i = 1, ..., d:
1. Compute S_k = Σ log(k_i) and S_b = Σ log(b_i) in O(d) time.
2. Return D = S_k / S_b.

### 4.3 Empirical Dimension Estimation

Given a search process with observable outcomes:
1. Run N random walks of depth d through the search tree.
2. Count the number S of successful walks.
3. Estimate the success probability P̂ = S/N.
4. Estimate dimension: D̂ = 1 + log(P̂) / (d · log(b)).

## 5. Applications

### 5.1 Automated Theorem Proving

The search dimension provides a theoretical basis for predicting the difficulty of proof goals before attempting them. A prover could:
- Estimate D from a small sample of random proof attempts
- Allocate computational resources proportional to the expected difficulty (lower D → more resources)
- Decide between depth-first and breadth-first strategies based on D

### 5.2 Complexity Theory

The product law suggests connections to additive complexity theory. The dimension of a composite problem is a weighted average of component dimensions, mirroring how entropy is additive for independent processes.

### 5.3 AI Training Curriculum

Theorems could be ordered by search dimension for curriculum learning: start with high-D (easy) theorems and gradually decrease D. The continuous nature of the dimension enables smooth difficulty scheduling.

## 6. Discussion

### 6.1 Limitations

The uniform model assumes constant branching and survival rates, which is unrealistic for most proof searches. The heterogeneous extension addresses this partially, but assumes independence between levels.

The framework measures difficulty of *search* rather than difficulty of *insight*. A theorem requiring a single brilliant but non-obvious step might have high search dimension (once you have the key idea, many paths work) but be subjectively very hard.

### 6.2 Connection to Valuation Depth

The search dimension measures "horizontal" complexity (how many paths survive), while the valuation depth framework from p-adic computation theory measures "vertical" complexity (how deep the computation must go). A unified framework combining both dimensions — a two-dimensional complexity measure (width × depth) — could capture both aspects simultaneously.

## 7. Future Work

- **Heterogeneous Lyapunov exponents**: When branching factors are random, the search dimension should converge to a Lyapunov exponent, connecting to ergodic theory.
- **Quantum search dimension**: Grover's algorithm effectively increases D from D to √D, suggesting a "quantum dimension" framework.
- **Empirical validation**: Measure the search dimension of actual proof searches in automated theorem provers and correlate with observed difficulty.

## 8. Conclusion

We have established the mathematical foundations of proof search dimension, proving that D = log(k)/log(b) provides a well-defined, bounded, monotone measure of search difficulty with sharp phase transitions and natural composition properties. The framework connects fractal geometry, information theory, and proof complexity in a unified continuous measure of theorem difficulty.

## References

1. Bollobás, B. (2001). *Random Graphs*. Cambridge University Press.
2. Grimmett, G. (1999). *Percolation*. Springer.
3. Grünwald, P. & Vitányi, P. (2003). Kolmogorov complexity and information theory. *Journal of Logic, Language and Information*, 12(4), 497-529.
4. Li, M. & Vitányi, P. (2008). *An Introduction to Kolmogorov Complexity and Its Applications*. Springer.
5. Mandelbrot, B. (1982). *The Fractal Geometry of Nature*. W.H. Freeman.
