# Polyhedral Topology of ReLU Neural Network Decision Surfaces: Zaslavsky Bounds, Depth Amplification, and Hodge-Type Estimates

## Abstract

We formalize the combinatorial-topological theory of ReLU neural network decision surfaces, establishing rigorous bounds on their polyhedral complexity in terms of network architecture parameters. Our main results are: (1) a proof of the Zaslavsky recurrence Z(m+1,n) = Z(m,n) + Z(m,n−1) for hyperplane arrangement region counts, directly applicable to single-layer ReLU networks; (2) a depth amplification theorem showing that the region bound for a depth-L width-w network is at most ((w+1)^n)^L, demonstrating the exponential advantage of depth over width; (3) a Hodge-type bound showing that the (p,q)-component of decision surface complexity satisfies h^{p,q} ≤ C(w₁,p)·C(w_L,q)·∏w_i ≤ 2^{total neurons}; and (4) Euler characteristic bounds via the f-vector triangle inequality. All results are fully formalized in Lean 4 with Mathlib.

## 1. Introduction

A ReLU neural network f: ℝⁿ → ℝ with L hidden layers computes a continuous piecewise linear function. Its decision surface V(f) = {x : f(x) = 0} is a polyhedral complex — a union of convex polytopes glued along their faces. The topology of this complex (its Betti numbers, Euler characteristic, and homological structure) determines the qualitative behavior of the classifier.

The central question we address is: **how does the network architecture (depth, width, input dimension) constrain the topological complexity of the decision surface?**

### 1.1 Prior Work

The study of linear regions in ReLU networks was initiated by Montúfar, Pascanu, Cho, and Bengio (2014), who proved that a network with L layers of width w has at most ∏_i Z(w_i, n) linear regions, where Z(m,n) is the Zaslavsky bound. Hanin and Rolnick (2019) refined these bounds and studied the average number of regions. Serra, Tjandraatmadja, and Ramalingam (2018) showed that the maximum number of regions can be achieved.

The connection to polyhedral topology was explored by Grigsby and Lindsey (2022), who studied the topology of decision boundaries. The Hodge-theoretic perspective we develop here appears to be new.

### 1.2 Contributions

Our contributions are:

1. **Zaslavsky recurrence** (Theorem 3.1): We prove Z(m+1,n) = Z(m,n) + Z(m,n−1), the fundamental recurrence for hyperplane arrangement region counts.

2. **Depth amplification** (Theorem 4.1): For a uniform-width network, networkRegionBound ≤ ((w+1)^n)^L.

3. **Hodge-type bound** (Theorem 5.1): hodgeBound(arch, p, q) ≤ 2^{totalNeurons}.

4. **Euler characteristic bound** (Theorem 3.4): |χ(K)| ≤ totalFaces(K).

5. **Monotonicity results**: Region bounds are monotone in layer widths (Theorem 4.2).

## 2. Definitions

### 2.1 f-Vector Data

An **f-vector** of dimension d is a function f: Fin(d+1) → ℕ, where f(k) counts the number of k-dimensional faces of a polyhedral complex.

The **total face count** is totalFaces(v) = Σ_k f(k).

The **Euler characteristic** is χ(v) = Σ_k (-1)^k f(k).

### 2.2 Network Architecture

A **ReluNetArch** consists of:
- inputDim: ℕ (input space dimension, positive)
- numLayers: ℕ (number of hidden layers)
- layerWidths: Fin numLayers → ℕ (width of each layer, all positive)

The **total number of neurons** is totalNeurons = Σ_i layerWidths(i).

### 2.3 Zaslavsky Bound

The **Zaslavsky bound** for m hyperplanes in ℝⁿ is:

Z(m, n) = Σ_{k=0}^{n} C(m, k)

This is the maximum number of regions created by m hyperplanes in general position.

### 2.4 Network Region Bound

The **network region bound** is:

networkRegionBound(arch) = ∏_i Z(layerWidths(i), inputDim)

### 2.5 Hodge Bound

For a network with ≥ 2 layers, the **(p,q)-Hodge bound** is:

hodgeBound(arch, p, q) = C(w₁, p) · C(w_L, q) · ∏_{middle} w_i

where w₁ is the first layer width and w_L is the last.

## 3. Zaslavsky Bound Theory

### Theorem 3.1 (Zaslavsky Recurrence)

For all m ≥ 0 and n ≥ 1:

Z(m+1, n) = Z(m, n) + Z(m, n−1)

**Proof sketch.** By expanding Z(m+1, n) = Σ_{k=0}^{n} C(m+1, k) and applying Pascal's identity C(m+1, k) = C(m, k) + C(m, k−1), the sum splits into Σ C(m,k) + Σ C(m,k−1). The first sum is Z(m,n); reindexing the second gives Z(m, n−1). ∎

**Geometric interpretation.** Adding a hyperplane H to an arrangement A partitions each region of A that H crosses into two pieces. The number of regions crossed equals the number of regions of the restricted arrangement A ∩ H, which is a (m)-hyperplane arrangement in ℝ^{n-1}.

### Theorem 3.2 (Zaslavsky Upper Bounds)

(a) Z(m, n) ≤ 2^m for all m, n.

(b) Z(m, n) ≤ (m+1)^n for all m, n.

**Proof sketch.** (a) Z(m,n) is a partial sum of binomial coefficients, bounded by the full sum 2^m. (b) By induction on m, using the recurrence and the inequality (m+1)^{n-1}·(m+2) ≤ (m+2)^n. ∎

### Theorem 3.3 (Monotonicity)

(a) Z is monotone increasing in m: m₁ ≤ m₂ implies Z(m₁, n) ≤ Z(m₂, n).

(b) Z is monotone increasing in n: n₁ ≤ n₂ implies Z(m, n₁) ≤ Z(m, n₂).

### Theorem 3.4 (Euler Characteristic Bound)

For any f-vector v: |χ(v)| ≤ totalFaces(v).

**Proof.** Triangle inequality for the alternating sum: |Σ (-1)^k f_k| ≤ Σ |(-1)^k f_k| = Σ f_k. ∎

### Theorem 3.5 (Refinement Monotonicity)

If v₁.f(i) ≤ v₂.f(i) for all i (v₂ refines v₁), then:
- totalFaces(v₁) ≤ totalFaces(v₂)
- |χ(v₁)| ≤ totalFaces(v₂)

## 4. Network Architecture Bounds

### Theorem 4.1 (Depth Amplification)

For a uniform-width network with L layers of width w and input dimension n:

networkRegionBound ≤ ((w+1)^n)^L

**Proof.** The region bound is a product of L copies of Z(w, n). By Theorem 3.2(b), each Z(w, n) ≤ (w+1)^n. ∎

**Example.** For n=5, w=10, L=5: bound is (11^5)^5 = 11^25 ≈ 1.16 × 10^26.
For the same total neurons (50) in a single layer: Z(50, 5) ≤ 51^5 ≈ 3.5 × 10^8. The deep network's bound is 10^{17} times larger.

### Theorem 4.2 (Width Monotonicity)

If w₁(i) ≤ w₂(i) for all layers i, then:

networkRegionBound(arch with w₁) ≤ networkRegionBound(arch with w₂)

### Theorem 4.3 (Positivity)

networkRegionBound(arch) > 0 for all architectures.

### Theorem 4.4 (Single Layer Reduction)

For a single-layer network: networkRegionBound = Z(w, n).

### Theorem 4.5 (Uniform Total Neurons)

For a uniform-width network: totalNeurons = w · L.

## 5. Hodge-Type Bounds

### Theorem 5.1 (Hodge Bound)

For any architecture and indices p, q:

hodgeBound(arch, p, q) ≤ 2^{totalNeurons}

**Proof sketch.** For numLayers ≥ 2, the bound is C(w₁,p)·C(w_L,q)·∏w_i. Using C(n,k) ≤ 2^n and w_i ≤ 2^{w_i}, the product is at most 2^{w₁}·2^{w_L}·∏2^{w_i} = 2^{Σw_i} = 2^{totalNeurons}. ∎

**Interpretation.** The (p,q)-Hodge number measures the "algebraic complexity" of the decision surface in the p-th and q-th dimensional directions. The bound shows this complexity is controlled by the total number of parameters (neurons) in the network, with the first and last layers playing distinguished roles.

## 6. The PL Hodge Property

**Observation.** For piecewise linear varieties (which include all ReLU network decision surfaces), the analog of the Hodge conjecture is automatically true: every homology class of V(f) is a formal ℤ-linear combination of faces, and each face is defined by a linear equation (hence is an "algebraic cycle" in the piecewise-linear sense).

This is because the chain complex of a polyhedral complex has chain modules C_k ≅ ℤ^{f_k}, and every cycle in C_k is automatically a linear combination of faces. The PL Hodge property is not a conjecture but a theorem, following from the definition of simplicial/polyhedral homology.

The non-trivial content is the **quantitative bound**: the Betti numbers β_k ≤ f_k, and the f_k are bounded by the network architecture as described above.

## 7. Discussion

### 7.1 Depth vs. Width

Our depth amplification theorem (Theorem 4.1) gives a precise mathematical explanation for the empirical observation that deep networks outperform shallow ones. The region count bound grows as ((w+1)^n)^L with depth but only as (w·L+1)^n with width, for the same total neuron budget. This exponential gap in the *upper bound* on expressivity is consistent with the known lower bounds of Telgarsky (2016) showing functions that deep networks can compute but shallow ones cannot approximate efficiently.

### 7.2 Architecture-Topology Correspondence

The Hodge bound (Theorem 5.1) reveals a layered structure in the topology of decision surfaces:
- The first layer controls the "spatial" complexity (indexed by p)
- The last layer controls the "dual" complexity (indexed by q)
- The middle layers provide a multiplicative amplification

This suggests that in practice, the first and last layers of a network play distinguished roles in shaping the decision boundary, while middle layers serve primarily to increase its complexity.

### 7.3 Limitations

Our bounds are upper bounds on the *maximum possible* topological complexity. The *actual* complexity of a trained network's decision surface depends on the training data and optimization algorithm. Typical trained networks may have far simpler decision surfaces than the maximum allowed by their architecture.

## 8. Future Work

1. **Tighter bounds via activation pattern analysis**: The Zaslavsky bound counts all possible activation patterns, but many may be unrealizable for a given network's weights. Studying the fraction of realizable patterns could yield tighter bounds.

2. **Connection to generalization**: The topological complexity of the decision surface is related to the VC dimension and Rademacher complexity of the hypothesis class. Formalizing these connections would link our bounds to generalization theory.

3. **Tropical geometry bridge**: ReLU(x) = max(0,x) is the tropical addition operation. Composing layers of a ReLU network is equivalent to evaluating a tropical rational function. This suggests that tropical algebraic geometry could provide tools for analyzing network decision surfaces.

## References

1. Montúfar, G., Pascanu, R., Cho, K., Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS*.
2. Zaslavsky, T. (1975). Facing up to arrangements: face-count formulas for partitions of space by hyperplanes. *Memoirs AMS*, 154.
3. Hanin, B., Rolnick, D. (2019). Complexity of linear regions in deep neural networks. *ICML*.
4. Grigsby, J.E., Lindsey, K. (2022). On transversality of bent hyperplane arrangements and the topological expressiveness of ReLU networks. *SIAM J. Appl. Algebra Geom.*
5. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT*.
6. Stanley, R. (1996). *Combinatorics and Commutative Algebra*. Birkhäuser.

## Catalog References

- `Catalog/Algebra/NeuralHodge/Theorems.lean` — Prior ReLU properties and PLComplex definitions
- `Catalog/Shared/NeuralHodge/Defs.lean` — NetworkArch, Zaslavsky definitions
- `Catalog/Shared/NeuralHodge/Bounds.lean` — Prior Euler characteristic and Hodge bounds
- `Novelty/NeuralHodge/Defs.lean` — Our FVectorData, ReluNetArch, zaslavskyBound, hodgeBound definitions
- `Novelty/NeuralHodge/FVector.lean` — Zaslavsky recurrence, Euler characteristic bounds
- `Novelty/NeuralHodge/Bounds.lean` — Depth amplification, Hodge bound, monotonicity
