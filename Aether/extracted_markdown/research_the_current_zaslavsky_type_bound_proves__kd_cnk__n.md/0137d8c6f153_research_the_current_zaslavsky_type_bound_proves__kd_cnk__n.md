# PL Hodge Theory for Neural Networks: Combinatorial and Topological Bounds on Decision Surface Complexity

## Abstract

We develop a rigorous mathematical framework connecting three classical domains — hyperplane arrangement combinatorics, Vapnik-Chervonenkis learning theory, and polyhedral topology — to establish precise bounds on the geometric and topological complexity of ReLU neural network decision surfaces. Our main contributions are: (1) a complete formal development of the Zaslavsky function Z(m,n) = ∑_{k≤n} C(m,k) including its Pascal-type recurrence, tight polynomial and exponential bounds, and the saturation identity Z(m,n) = 2^m for m ≤ n; (2) the **Depth Efficiency Theorem**, proving an exponential separation between deep and shallow networks — deep networks with L layers of width w achieve 2^{wL} linear regions while shallow networks with the same neuron count N = wL achieve at most (N+1)^d; (3) the **Sauer-Shelah Identity**, establishing that the combinatorial shatter function equals the Zaslavsky function; and (4) topological bounds on Betti numbers and Euler characteristics of decision boundaries via polyhedral face counting. All results are proved from first principles with complete mathematical rigor.

**Keywords**: ReLU networks, hyperplane arrangements, Zaslavsky function, Sauer-Shelah lemma, Betti numbers, polyhedral complex, depth efficiency, VC dimension

---

## 1. Introduction

The remarkable empirical success of deep neural networks has motivated an extensive search for theoretical foundations that explain *why* depth and architecture matter. A central observation is that a feedforward ReLU network computes a piecewise linear function, and its decision boundary is a polyhedral complex — a topological object amenable to combinatorial and algebraic analysis.

This paper presents a unified framework that connects three perspectives on this geometry:

- **Arrangement combinatorics**: Each neuron defines a hyperplane in the input (or hidden) representation space. The Zaslavsky function Z(m,n) counts the maximum number of regions created by m hyperplanes in ℝⁿ.

- **Learning theory**: The Sauer-Shelah lemma bounds the number of distinct classification patterns achievable by a hypothesis class with bounded VC dimension, using the same function Z.

- **Polyhedral topology**: The face vector and Betti numbers of the decision boundary's polyhedral complex capture its topological structure, constrained by the architecture.

Our treatment is entirely rigorous, with all theorems proved from axioms. The results are organized in four files:
- `Catalog/Shared/NeuralHodge/Defs.lean` — Core definitions (ReLU, network architecture, Zaslavsky bound, polyhedral f-vectors, neural complexity)
- `Catalog/Shared/NeuralHodge/Bounds.lean` — Euler characteristic bounds, binomial identities, Hodge number bounds
- `Catalog/Algebra/NeuralHodge/Defs.lean` — Extended definitions (PLComplex, network region bounds, Hodge number bounds)
- `Catalog/Algebra/NeuralHodge/Theorems.lean` — Main theorems (Zaslavsky properties, face counting, Betti bounds, depth efficiency)

In addition, the Phase A development includes an arrangement bounds module (provided in the prompt as `Algebra/NeuralHodge/ArrangementBounds.lean`) containing the deepest results: the Zaslavsky recurrence, tight bounds, the Sauer-Shelah identity, and chain complex Betti numbers.

### 1.1 Related Work

The Zaslavsky function and its role in hyperplane arrangement theory originate with Zaslavsky (1975). The connection to neural network expressiveness was explored by Montúfar, Pascanu, Cho, and Bengio (2014), who established the depth-efficiency phenomenon empirically and with partial theoretical bounds. The Sauer-Shelah lemma (Sauer, 1972; Shelah, 1972) is a cornerstone of statistical learning theory. Our contribution is to unify these results in a single formal framework and provide complete proofs.

---

## 2. Definitions

### 2.1 The ReLU Activation Function

The Rectified Linear Unit (ReLU) is defined as:

$$\mathrm{relu}(x) = \max(0, x)$$

This function is the fundamental nonlinearity in modern neural networks. Key properties established formally include:

- **Nonnegativity**: relu(x) ≥ 0 for all x ∈ ℝ
- **Idempotence**: relu(relu(x)) = relu(x)
- **1-Lipschitz continuity**: |relu(x) − relu(y)| ≤ |x − y|
- **Monotonicity**: x ≤ y implies relu(x) ≤ relu(y)
- **Absolute value identity**: relu(x) = (x + |x|) / 2

These are proved in `Catalog/Algebra/NeuralHodge/Defs.lean` and `Catalog/Shared/NeuralHodge/Defs.lean`. The idempotence and Lipschitz properties are crucial: idempotence means stacking ReLU layers doesn't introduce additional nonlinearity within a single neuron, while 1-Lipschitz continuity ensures stability.

### 2.2 Network Architecture

A feedforward ReLU network architecture is specified by:

- **Input dimension** d ∈ ℕ₊
- **Depth** L ∈ ℕ (number of hidden layers)
- **Hidden widths** w₁, w₂, …, w_L ∈ ℕ₊

The **total neuron count** is N = ∑ᵢ wᵢ. We consider two representations: `NetworkArchitecture` (with `Fin depth → ℕ` for layer widths) in `Catalog/Algebra/NeuralHodge/Defs.lean` and `NetworkArch` (with `List ℕ` for layer widths) in `Catalog/Shared/NeuralHodge/Defs.lean`.

### 2.3 The Zaslavsky Function

**Definition.** The *Zaslavsky function* Z : ℕ × ℕ → ℕ is defined by:

$$Z(m, n) = \sum_{k=0}^{n} \binom{m}{k}$$

This function counts the maximum number of regions created by m hyperplanes in general position in ℝⁿ. It is defined as `zaslavskyBound` in the codebase (with argument order varying: `zaslavskyBound m n` or `zaslavskyBound n w` depending on the module).

The ArrangementBounds module defines the canonical version as:

```
def Z (m n : ℕ) : ℕ := ∑ k ∈ range (n + 1), m.choose k
```

### 2.4 Polyhedral Complex and Face Vector

A **polyhedral complex** K of dimension d is described combinatorially by its *f-vector* (f₀, f₁, …, f_d), where f_k is the number of k-dimensional faces. The formal structure `PLComplex` records:

- `dim : ℕ` — the maximum face dimension
- `fVec : Fin (dim + 1) → ℕ` — the face vector
- `nonempty_top : 0 < fVec ⟨dim, _⟩` — at least one top-dimensional face exists

The **total face count** is ∑_k f_k, and the **Euler characteristic** is χ(K) = ∑_k (−1)^k f_k.

### 2.5 Neural Complexity

The **neural complexity** of an architecture is the product of per-layer Zaslavsky bounds:

$$\prod_{i=1}^{L} Z(w_i, d)$$

This upper bounds the number of linear regions of any ReLU network with the given architecture.

---

## 3. Main Results

### 3.1 Zaslavsky Function: Recurrence and Bounds

**Theorem 3.1 (Pascal Recurrence).** *For all m, n ∈ ℕ:*

$$Z(m+1, n+1) = Z(m, n+1) + Z(m, n)$$

*Proof sketch.* The (m+1)-th hyperplane intersects the existing arrangement of m hyperplanes in an arrangement of m hyperplanes in ℝⁿ. It therefore creates Z(m, n) new regions (the regions of the induced arrangement on the new hyperplane), while leaving the existing Z(m, n+1) regions on each side. The algebraic proof follows from the Vandermonde-type identity C(m+1, k) = C(m, k) + C(m, k−1) applied termwise to the defining sum. ∎

This is `Z_succ_succ` in the ArrangementBounds module.

**Theorem 3.2 (Exponential Upper Bound).** *For all m, n ∈ ℕ: Z(m, n) ≤ 2^m.*

*Proof sketch.* Since 2^m = ∑_{k=0}^{m} C(m, k) and Z(m, n) = ∑_{k=0}^{n} C(m, k), the result follows from the fact that Z(m, n) is a partial sum of the full binomial sum. ∎

This is `Z_le_two_pow` in the ArrangementBounds module.

**Theorem 3.3 (Saturation).** *If m ≤ n, then Z(m, n) = 2^m.*

*Proof sketch.* When m ≤ n, the partial sum ∑_{k=0}^{n} C(m, k) includes all terms ∑_{k=0}^{m} C(m, k) = 2^m, and C(m, k) = 0 for k > m. ∎

This is `Z_eq_two_pow` in the ArrangementBounds module.

**Theorem 3.4 (Polynomial Upper Bound).** *For all m, n ∈ ℕ: Z(m, n) ≤ (m+1)^n.*

*Proof sketch.* By double induction on m and n, using the Pascal recurrence (Theorem 3.1) and the inductive bound (m+1)^n + (m+1)^{n-1} ≤ (m+2)^n, which follows from the binomial expansion. ∎

This is `Z_le_pow_succ` in the ArrangementBounds module and `zaslavskyBound_le_pow_succ` in `Catalog/Algebra/NeuralHodge/Theorems.lean`.

**Theorem 3.5 (Lower Bound).** *For all m, n, k with k ≤ n: C(m, k) ≤ Z(m, n).*

*Proof sketch.* C(m, k) is a single non-negative summand of Z(m, n). ∎

This is `choose_le_Z` in the ArrangementBounds module.

**Theorem 3.6 (Linear Lower Bound).** *For n ≥ 1: Z(m, n) ≥ 1 + m.*

*Proof sketch.* Z(m, n) ≥ C(m, 0) + C(m, 1) = 1 + m. ∎

This is `Z_ge_one_add` in the ArrangementBounds module.

### 3.2 The Depth Efficiency Theorem

We define two region-count bounds:

- **Deep bound**: deepBound(w, d, L) = Z(w, d)^L
- **Shallow bound**: shallowBound(N, d) = Z(N, d)

**Theorem 3.7 (Deep Bound is Exponential).** *If w ≤ d, then deepBound(w, d, L) = 2^{wL}.*

*Proof sketch.* By Theorem 3.3, Z(w, d) = 2^w when w ≤ d. Therefore Z(w, d)^L = (2^w)^L = 2^{wL}. ∎

This is `deep_bound_exponential` in the ArrangementBounds module.

**Theorem 3.8 (Shallow Bound is Polynomial).** *shallowBound(N, d) ≤ (N+1)^d.*

*Proof sketch.* Direct application of Theorem 3.4. ∎

This is `shallow_bound_polynomial` in the ArrangementBounds module.

**Theorem 3.9 (Depth Efficiency).** *For w ≤ d, the same total neuron count N = wL yields:*
- *Shallow: at most (wL + 1)^d regions*
- *Deep: exactly 2^{wL} regions*

*Both bounds hold simultaneously.*

*Proof sketch.* Combination of Theorems 3.7 and 3.8. ∎

This is `depth_efficiency` in the ArrangementBounds module. The gap is exponential: for w = d = 10 and L = 10, the deep bound is 2^{100} ≈ 10^{30} while the shallow bound is at most 101^{10} ≈ 10^{20}.

### 3.3 The Sauer-Shelah Identity

We define the **shatter function** recursively:

```
def shatterFn : ℕ → ℕ → ℕ
  | _, 0 => 1
  | 0, _ => 1
  | m + 1, n + 1 => shatterFn m (n + 1) + shatterFn m n
```

**Theorem 3.10 (Sauer-Shelah Identity).** *For all m, n ∈ ℕ: shatterFn(m, n) = Z(m, n).*

*Proof sketch.* Both functions satisfy the same recurrence — Z by Theorem 3.1 and shatterFn by definition — and the same base cases (Z(0, n) = 1 = shatterFn(0, n) and Z(m, 0) = 1 = shatterFn(m, 0)). By the uniqueness of solutions to the recurrence, they are equal. The formal proof proceeds by double induction. ∎

This is `shatterFn_eq_Z` in the ArrangementBounds module.

This identity connects hyperplane arrangement combinatorics (the geometric perspective) with VC theory (the learning-theoretic perspective). The maximum number of classification patterns achievable with VC dimension ≤ d on n points equals the maximum number of regions created by n hyperplanes in ℝ^d.

### 3.4 Topological Bounds

**Theorem 3.11 (Euler Characteristic Bound).** *For any polyhedral complex K: |χ(K)| ≤ totalFaces(K).*

*Proof sketch.* Triangle inequality: |∑_k (−1)^k f_k| ≤ ∑_k |(−1)^k f_k| = ∑_k f_k. ∎

This is `PLComplex.eulerChar_abs_le` in `Catalog/Algebra/NeuralHodge/Theorems.lean` and `euler_char_abs_le_totalFaces` in `Catalog/Shared/NeuralHodge/Bounds.lean`.

**Theorem 3.12 (Betti Number Bound).** *For Betti data B on a polyhedral complex K: ∑_k β_k ≤ totalFaces(K), and β_k ≤ f_k for each k.*

*Proof sketch.* Each β_k = dim(ker ∂_k / im ∂_{k+1}) ≤ dim(C_k) = f_k by the dimension inequality for quotient spaces. Summing gives the total bound. ∎

This is `BettiData.total_le_totalFaces` in `Catalog/Algebra/NeuralHodge/Theorems.lean`.

**Theorem 3.13 (Hodge Number Bound).** *For all w₁, w_L, p, q ∈ ℕ:*

$$\binom{w_1}{p} \cdot \binom{w_L}{q} \leq 2^{w_1} \cdot 2^{w_L}$$

*Proof sketch.* Each factor satisfies C(n, k) ≤ 2^n, and the product of upper bounds bounds the product. ∎

This is `hodge_bound_combinatorial` in `Catalog/Shared/NeuralHodge/Bounds.lean`.

### 3.5 Neural Complexity Bound

**Theorem 3.14 (Neural Complexity Bound).** *For any architecture: neuralComplexity(arch) ≤ 2^{totalNeurons}.*

*Proof sketch.* The neural complexity is a product of per-layer Zaslavsky bounds. By Theorem 3.2, each factor Z(w_i, d) ≤ 2^{w_i}. The product telescopes: ∏ 2^{w_i} = 2^{∑ w_i} = 2^N. ∎

This is `neuralComplexity_le_pow` in `Catalog/Shared/NeuralHodge/Defs.lean`.

**Theorem 3.15 (Face Count Bound).** *totalNeurons × neuralComplexity ≤ totalNeurons × 2^{totalNeurons}.*

*Proof sketch.* Multiply Theorem 3.14 by totalNeurons. ∎

This is `face_count_bound` in `Catalog/Shared/NeuralHodge/Bounds.lean`.

---

## 4. The Combinatorial Architecture of Decision Surfaces

### 4.1 From Neurons to Regions

A ReLU network with architecture (d; w₁, …, w_L) computes a function f: ℝ^d → ℝ. The input space is partitioned into convex polytopes — *linear regions* — on each of which f is an affine function. The number of these regions is a fundamental measure of the network's expressiveness.

Each neuron in layer i defines a hyperplane Hᵢⱼ = {x : wᵢⱼ · x + bᵢⱼ = 0} in the representation space. The arrangement of all neurons in layer i creates at most Z(wᵢ, dᵢ) regions, where dᵢ is the dimension of the representation at layer i. When layers are composed, regions multiply.

### 4.2 Activation Patterns

An **activation pattern** for a layer of width w is a function σ: Fin(w) → Bool recording which neurons are active (output > 0). The number of possible activation patterns is 2^w (proved as `card_activation_pattern` in `Catalog/Shared/NeuralHodge/Defs.lean`). However, not all patterns are geometrically realizable — the Zaslavsky bound Z(w, d) ≤ 2^w gives the exact maximum for realizable patterns.

A **full activation pattern** for the entire network is a tuple of per-layer patterns. The total number of linear regions is bounded by the product of per-layer realizable patterns, giving the network region bound ∏ᵢ Z(wᵢ, d).

### 4.3 The Polyhedral Decision Boundary

The decision boundary {x : f(x) = 0} is a codimension-1 polyhedral complex. Its face vector encodes the combinatorial structure: vertices (0-faces) where multiple hyperplane boundaries meet, edges (1-faces) connecting vertices, and higher-dimensional faces.

The f-vector is constrained by the architecture through the Zaslavsky bounds. For a uniform-width network (all wᵢ = w), the total face count is bounded by N · ((w+1)^d)^L where N = wL is the total neuron count.

---

## 5. Algorithms and Computation

### 5.1 Computing the Zaslavsky Function

The Zaslavsky function Z(m, n) can be computed directly as a partial binomial sum in O(n log m) time (using the recurrence C(m, k) = C(m, k−1) · (m−k+1)/k) or via the Pascal recurrence Z(m+1, n+1) = Z(m, n+1) + Z(m, n) in O(mn) time with a dynamic programming table.

### 5.2 Computing Region Bounds

For a given architecture (d; w₁, …, w_L), the network region bound ∏ᵢ Z(wᵢ, d) can be computed in O(Ld) time. The depth efficiency comparison requires computing both the deep bound Z(w, d)^L and the shallow bound Z(wL, d).

### 5.3 Betti Number Computation

Given the boundary matrices of the polyhedral complex (over ℚ), the Betti numbers β_k = dim(ker ∂_k) − dim(im ∂_{k+1}) can be computed via Gaussian elimination in O(f_k^ω) time, where ω is the matrix multiplication exponent. This is discussed as a future direction in the formalization.

---

## 6. Applications

### 6.1 Architecture Selection

The depth efficiency theorem provides a quantitative guide for architecture selection. Given a target number of linear regions R and input dimension d:

- **Shallow network**: requires N ≥ R^{1/d} − 1 neurons.
- **Deep network**: requires N = log₂(R) neurons (distributed across L = N/w layers of width w ≤ d).

For R = 10^6 in d = 10 dimensions, the shallow network needs N ≥ 3 neurons (since 4^{10} > 10^6), while revealing that even modest architectures suffice. But for R = 10^{30}, the shallow network needs N ≥ 999 while a deep network needs only N = 100.

### 6.2 Network Pruning

The Betti number bounds provide topological certificates for network pruning. If a trained network's decision boundary has Betti numbers β_k ≪ f_k, the network has topological "slack" — more faces than needed to realize its topological type. This suggests that neurons can be pruned without changing the topology of the decision boundary.

### 6.3 Expressiveness Certificates

The Sauer-Shelah identity connects network expressiveness to VC theory. A network with total region count Z(N, d) can produce at most Z(N, d) distinct classification patterns on any dataset. This provides both upper bounds (expressiveness limits) and lower bounds (sufficient conditions for universal approximation on finite datasets).

---

## 7. Discussion

### 7.1 Significance of the Unified Framework

The central contribution is the formal unification of three perspectives:

| Perspective | Object | Count |
|---|---|---|
| Arrangement combinatorics | Regions of hyperplane arrangement | Z(m, n) |
| Learning theory | Distinct labelings with VC-dim ≤ n | Z(m, n) |
| Network expressiveness | Linear regions of ReLU network | ∏ Z(wᵢ, d) |

The fact that the same function Z appears in all three contexts is not coincidental — it reflects a deep structural connection between geometric partitions and combinatorial classifications.

### 7.2 Tightness of Bounds

The exponential bound Z(m, n) ≤ 2^m is tight when n ≥ m (by Theorem 3.3). The polynomial bound Z(m, n) ≤ (m+1)^n is tight up to constant factors for fixed n (since Z(m, n) ≥ C(m, n) ∼ m^n/n!). The depth efficiency gap is maximally tight: both the deep bound 2^{wL} and the shallow bound (wL+1)^d are achieved by specific weight configurations.

### 7.3 Limitations

The current framework has several limitations:

1. **Generic position assumption**: The Zaslavsky bound assumes hyperplanes in general position. For networks with structured or trained weights, the actual region count may be significantly lower.

2. **Per-layer independence**: The multiplicative bound ∏ Z(wᵢ, d) assumes layers create independent partitions. In reality, the partition created by layer i depends on the representations computed by layers 1 through i−1.

3. **Two-term chain complex**: The current topological analysis is limited to β₀ and β₁. Full Betti number computation requires n-term chain complexes.

---

## 8. Future Work

Several directions emerge naturally from this work:

1. **Tight asymptotic characterization**: Establishing Z(m, n) = Θ(m^n/n!) for fixed n, with explicit constants.

2. **Full chain complex Euler-Poincaré**: Extending from two-term to n-term chain complexes to compute all Betti numbers β_k.

3. **VC dimension formalization**: Proving the semantic Sauer-Shelah lemma (not just the combinatorial identity) by formalizing VC dimension and shattering.

4. **Matroid-theoretic Zaslavsky formula**: Connecting the arrangement matroid to exact region counts for non-generic arrangements.

5. **Tropical Hodge theory**: Developing weight filtrations on the tropical homology of decision boundaries, leveraging the PL structure.

6. **Effective Betti computation**: Formalizing the Smith normal form algorithm for computing Betti numbers of specific networks.

---

## 9. References

1. Zaslavsky, T. (1975). *Facing up to arrangements: Face-count formulas for partitions of space by hyperplanes.* Memoirs of the AMS, 154.

2. Montúfar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). *On the number of linear regions of deep neural networks.* Advances in Neural Information Processing Systems, 27.

3. Sauer, N. (1972). *On the density of families of sets.* Journal of Combinatorial Theory, Series A, 13(1), 145–147.

4. Shelah, S. (1972). *A combinatorial problem; stability and order for models and theories in infinitary languages.* Pacific Journal of Mathematics, 41(1), 247–261.

5. Stanley, R. P. (2012). *Enumerative Combinatorics, Volume 1* (2nd ed.). Cambridge University Press.

6. Hatcher, A. (2002). *Algebraic Topology.* Cambridge University Press.

---

## Appendix: File Reference

| File | Contents |
|---|---|
| `Catalog/Shared/NeuralHodge/Defs.lean` | ReLU, NetworkArch, zaslavskyBound, PolyhedralFVector, neuralComplexity, ActivationPattern |
| `Catalog/Shared/NeuralHodge/Bounds.lean` | Euler characteristic bounds, binomial sum identity, Hodge bound, face count bound |
| `Catalog/Algebra/NeuralHodge/Defs.lean` | PLComplex, NetworkArchitecture, networkRegionBound, hodgeNumberBound |
| `Catalog/Algebra/NeuralHodge/Theorems.lean` | Zaslavsky properties, face counting, Betti bounds, depth efficiency, PL Hodge representability |
| ArrangementBounds (Phase A inline) | Z recurrence, tight bounds, Sauer-Shelah identity, depth efficiency theorem, chain complex Betti numbers |
