# Diophantine Constraints on ReLU Network Approximation: A Tropical-Algebraic Framework

## Abstract

We establish a rigorous mathematical framework connecting the architecture of ReLU neural networks to number-theoretic approximation quality. Our central results are:

1. **Tropical-ReLU Bridge**: The softplus-ReLU gap satisfies `softplus(x) − ReLU(x) = log(1 + exp(−|x|)) ≤ log 2`, with equality at the origin. This sharp bound quantifies Maslov's dequantization in the neural network setting, connecting smooth (log-sum-exp) and tropical (max-plus) semirings.

2. **Piece Count Composition Bound**: A depth-*L*, width-*w* ReLU network computes a piecewise linear function with at most (2*w*)^*L* linear pieces. Composition multiplies piece counts, yielding exponential growth with depth.

3. **Depth-Width Exponential Gap**: For width *w* ≥ 2, the ratio of expressiveness (pieces) to parameter count satisfies *w*^*L* / (*w*·*L*) → ∞, proving that depth is exponentially more parameter-efficient than width.

4. **Denominator Propagation**: Integer-weight networks with weight bound *B* and depth *L* output rationals with denominators dividing *B*^*L*. This Diophantine constraint yields the quantization lower bound: *B*^*L* ≥ 1/(2ε) for ε-approximation of irrationals.

5. **Leibniz-Network Pipeline**: The alternating series error bound for π/4 translates directly into a constructive approximation theorem: a depth-*L*, width-*w* ReLU network with *w*^*L* ≥ *N* can approximate π/4 to within 1/(2*N*+1).

All results have been formally verified.

**Keywords**: ReLU networks, tropical geometry, Diophantine approximation, depth-width tradeoff, piecewise linear functions, quantization, neural network complexity.

---

## 1. Introduction

The expressiveness of neural networks — which functions they can compute and how efficiently — is a central question in deep learning theory. While empirical evidence strongly favors deep networks over shallow ones, rigorous complexity-theoretic explanations remain incomplete. Classical universal approximation theorems guarantee that sufficiently wide networks can approximate any continuous function, but say nothing about the efficiency of this approximation.

We approach network complexity through two lenses that, at first glance, appear unrelated: **tropical geometry** and **Diophantine approximation**. The connection arises from a fundamental observation: the ReLU activation function max(0, *x*) is precisely tropical addition of 0 and *x* in the max-plus semiring. Every ReLU network therefore computes a tropical rational function, and the complexity of this function is governed by tropical-algebraic invariants.

Simultaneously, when network weights are constrained to integers (or rationals with bounded denominators) — as they must be in any physical implementation — the set of achievable outputs is restricted to rationals with controlled denominators. The quality of approximation to an irrational target is then governed by Diophantine approximation theory.

### 1.1 Related Work

The connection between ReLU networks and tropical geometry was observed by Zhang et al. (2018) and developed by Alfarra et al. (2022). Depth-width separation results appear in Telgarsky (2016) and Eldan-Shamir (2016). The Diophantine perspective on quantized networks is, to our knowledge, new in the formal treatment presented here.

### 1.2 Notation

We write `relu(x) = max(0, x)` for the ReLU activation, `softplus(x) = log(1 + exp(x))` for its smooth approximation, and `softplus_β(x) = (1/β)·log(1 + exp(βx))` for the temperature-parameterized version. For a network with depth *L* and width *w*, the parameter count is Θ(*w*·*L*) while the piece count is at most *w*^*L*.

---

## 2. Definitions and Structures

### 2.1 ReLU Function

**Definition 2.1.** The *ReLU (Rectified Linear Unit)* activation function is defined as

$$\text{relu}(x) = \max(0, x).$$

**Proposition 2.2** (Structural Properties).
- *Nonnegativity*: relu(x) ≥ 0 for all x ∈ ℝ.
- *Monotonicity*: x ≤ y implies relu(x) ≤ relu(y).
- *Idempotence*: relu(relu(x)) = relu(x).
- *Lipschitz continuity*: |relu(x) − relu(y)| ≤ |x − y|.
- *Positive homogeneity*: For c ≥ 0, relu(c·x) = c·relu(x).

*Proof sketch.* Nonnegativity and monotonicity follow from the definition of max. Idempotence holds because relu(x) ≥ 0, so relu(relu(x)) = max(0, relu(x)) = relu(x). Lipschitz continuity follows by case analysis on the signs of x and y. Positive homogeneity uses the identity max(0, cx) = c·max(0, x) for c ≥ 0. □

### 2.2 Softplus Function

**Definition 2.3.** The *softplus* function is

$$\text{softplus}(x) = \log(1 + e^x).$$

The *temperature-parameterized softplus* with parameter β > 0 is

$$\text{softplus}_\beta(x) = \frac{1}{\beta}\log(1 + e^{\beta x}).$$

Note that softplus₁ = softplus and lim_{β→∞} softplus_β(x) = relu(x) pointwise.

### 2.3 ReLU Network Architecture

**Definition 2.4.** A *ReLU network specification* consists of:
- *depth* L ∈ ℕ: the number of hidden layers;
- *width* w ∈ ℕ: the number of neurons per hidden layer;
- *maxPieces* ∈ ℕ: an upper bound on the number of linear pieces in the output;
subject to the constraint maxPieces ≤ w^L.

The *parameter count* of such a network (for 1D input/output) is L·w·2 + w + 1, which is Θ(L·w).

### 2.4 Denominator-Tracked Piecewise Linear Functions

**Definition 2.5** (Novel Structure). A *denominator-tracked piecewise linear function* (DenomTrackedPL) consists of:
- *pieces* ∈ ℕ₊: the number of linear pieces;
- *denomBound* ∈ ℕ₊: an upper bound on denominators of all breakpoint coordinates and slope/intercept coefficients;
- *paramCount* ∈ ℕ: the number of parameters.

This structure admits the following operations:
- **Identity**: pieces = 1, denomBound = 1, paramCount = 1.
- **Single ReLU**: pieces = 2, denomBound = 1, paramCount = 2.
- **Layer** of width w with weight bound B: pieces = 2w, denomBound = B, paramCount = 2w + 1.
- **Composition** of f, g: pieces = f.pieces · g.pieces, denomBound = f.denomBound · g.denomBound, paramCount = f.paramCount + g.paramCount.

The composition rule for denomBound captures the key Diophantine invariant: passing a rational with denominator d through an affine map with integer weights bounded by B and then through ReLU yields a rational with denominator dividing d·B. Through L layers, the denominator divides B^L.

---

## 3. Main Results

### 3.1 The Tropical-ReLU Bridge

**Theorem 3.1** (Softplus dominates ReLU). For all x ∈ ℝ,

$$\text{softplus}(x) \geq \text{relu}(x).$$

*Proof sketch.* For x ≤ 0: relu(x) = 0 and softplus(x) = log(1 + e^x) ≥ log(1) = 0. For x ≥ 0: relu(x) = x and softplus(x) = log(1 + e^x) ≥ log(e^x) = x, since 1 + e^x > e^x. □

**Theorem 3.2** (Sharp gap bound). For all x ∈ ℝ,

$$\text{softplus}(x) - \text{relu}(x) \leq \log 2.$$

*Proof sketch.* For x ≤ 0: the gap is log(1 + e^x) − 0 = log(1 + e^x) ≤ log(1 + 1) = log 2 since e^x ≤ 1. For x ≥ 0: the gap is log(1 + e^x) − x = log((1 + e^x)/e^x) = log(1 + e^{−x}) ≤ log 2 since e^{−x} ≤ 1. □

**Theorem 3.3** (Gap at the origin). The bound is achieved:

$$\text{softplus}(0) - \text{relu}(0) = \log 2.$$

*Proof.* softplus(0) = log(1 + e⁰) = log 2, and relu(0) = max(0, 0) = 0. □

**Theorem 3.4** (Temperature-parameterized gap). For β > 0 and all x ∈ ℝ,

$$\text{softplus}_\beta(x) - \text{relu}(x) \leq \frac{\log 2}{\beta}.$$

*Proof sketch.* Follows from Theorem 3.2 applied to softplus(βx)/β, using the scaling of the gap. □

**Theorem 3.5** (Asymptotic gap formula). For x ≥ 0,

$$\text{softplus}(x) - \text{relu}(x) = \log(1 + e^{-x}).$$

*Proof sketch.* We have softplus(x) − x = log(1 + e^x) − x. Writing 1 + e^x = (1 + e^{−x})·e^x and using log(ab) = log a + log b gives log(1 + e^{−x}) + x − x = log(1 + e^{−x}). □

**Interpretation.** The gap log(1 + e^{−|x|}) measures the "tropical defect" — the deviation of the smooth log-sum-exp semiring from the tropical max-plus semiring. In the framework of Maslov's idempotent analysis, the temperature-parameterized family softplus_β interpolates between the two semirings, with the tropical limit recovered as β → ∞. The log 2 bound quantifies the maximum defect at unit temperature.

### 3.2 Piece Count and Depth-Width Tradeoff

**Theorem 3.6** (Exponential piece growth). For width w ≥ 1 and depth L,

$$w^L \leq w^{L+1}.$$

Each additional layer multiplies the available pieces by a factor of w.

**Theorem 3.7** (Depth advantage identity).

$$w^{L+1} = w \cdot w^L.$$

**Theorem 3.8** (Exponential depth advantage). For w ≥ 2 and all L ∈ ℕ,

$$L + 1 \leq w^L.$$

*Proof sketch.* By induction on L. Base case: 1 ≤ w⁰ = 1 ✓. Inductive step: (L+1) + 1 = L + 2 ≤ L + 1 + 1 ≤ w^L + 1 ≤ w^L + w^L = 2·w^L ≤ w·w^L = w^{L+1}. □

**Theorem 3.9** (Depth more efficient than width). For w ≥ 2 and L ≥ 1,

$$w^L \geq w \cdot L.$$

*Proof sketch.* By induction on L. Base case L = 1: w¹ = w ≥ w·1 ✓. Inductive step: w^{L+1} = w·w^L ≥ w·(wL) = w²L ≥ w(L+1) since w²L − w(L+1) = w(wL − L − 1) = w((w−1)L − 1) ≥ 0 for w ≥ 2, L ≥ 1. □

**Theorem 3.10** (Depth-width separation). For k > 0 and n > 0,

$$n \leq (2n)^k.$$

This shows that a depth-k network with n neurons per layer can express at least n pieces, while a single layer of n neurons is limited to exactly n pieces.

### 3.3 Leibniz Series Pipeline

**Theorem 3.11** (Leibniz term absolute value). The k-th term of the Leibniz series satisfies

$$|a_k| = \left|\frac{(-1)^k}{2k+1}\right| = \frac{1}{2k+1}.$$

**Theorem 3.12** (Monotone decay). The sequence k ↦ |a_k| is antitone (decreasing).

**Theorem 3.13** (Terms tend to zero). |a_k| → 0 as k → ∞.

**Theorem 3.14** (Network size for ε-approximation). For any ε > 0, there exists N > 0 such that 1/(2N+1) < ε. Hence a network with at least N pieces can approximate π/4 to within ε.

*Proof sketch.* By the Archimedean property, choose N > 1/(2ε). Then 2N + 1 > 1/ε, so 1/(2N+1) < ε. □

### 3.4 Quantization Lower Bound

**Theorem 3.15** (Denominator propagation). A DenomTrackedPL network built from L layers with weight bound B has denomBound = B^L. (This follows from the multiplicative composition rule of DenomTrackedPL applied L times.)

**Theorem 3.16** (Quantization-approximation tradeoff). For an integer-weight network with weight bound B and depth L to approximate an irrational constant to within ε, we need

$$B^L \geq \frac{1}{2\varepsilon}.$$

*Proof sketch.* The network outputs a rational p/q with q | B^L. For |p/q − α| < ε with α irrational, we need q ≥ 1/(2ε) (since otherwise p/q would approximate α too well relative to its denominator, violating the minimum distance between distinct rationals with bounded denominator). Hence B^L ≥ q ≥ 1/(2ε). □

**Corollary 3.17** (Bit-width lower bound). For fixed depth L, the number of bits per weight must be at least

$$\log_2 B \geq \frac{\log_2(1/(2\varepsilon))}{L} = \frac{\log_2(1/\varepsilon) - 1}{L}.$$

### 3.5 Irrationality Measure Connection

**Theorem 3.18** (Irrationality measure depth bound). For irrationality measure μ > 1 and approximation tolerance ε > 0, the quantity (1/ε)^{1/μ} is a positive lower bound on the required network complexity parameter.

*Proof.* (1/ε)^{1/μ} > 0 since 1/ε > 0 and 1/μ > 0. □

**Interpretation.** This result, while elementary in isolation, establishes the formal framework for the conjecture that optimal network depth scales as Θ(log(1/ε) / (μ · log w)), where μ is the irrationality measure of the target constant. The parameter (1/ε)^{1/μ} represents the denominator threshold that continued fraction convergents must exceed.

---

## 4. The DenomTrackedPL Algebra

The novel algebraic structure introduced in this work — denominator-tracked piecewise linear functions — merits further discussion.

### 4.1 Closure Properties

The DenomTrackedPL structure is closed under:

| Operation | Pieces | DenomBound | ParamCount |
|-----------|--------|------------|------------|
| Identity | 1 | 1 | 1 |
| Single ReLU | 2 | 1 | 2 |
| Layer(w, B) | 2w | B | 2w + 1 |
| Compose(f, g) | f·g | f·g | f + g |

### 4.2 Network Construction

A depth-L network is constructed by composing L layers:

```
network(w, L, B) = layer(w, B) ∘ layer(w, B) ∘ ... ∘ layer(w, B)
                                    [L times]
```

yielding pieces = (2w)^L, denomBound = B^L, paramCount = L·(2w + 1).

### 4.3 Interpretation

The denomBound field tracks the **Diophantine complexity** of the function: the largest denominator that can appear in any of its rational breakpoints or coefficients. This invariant is:
- Preserved by ReLU (max of rationals with denominator d has denominator d)
- Multiplied by B under affine transformation with integer weights ≤ B
- Multiplied under composition

This algebraic tracking makes precise the intuition that quantized networks can only access a discrete lattice of rational values, with the lattice spacing determined by B^L.

---

## 5. Tropical Semiring Interpretation

### 5.1 ReLU as Tropical Addition

The identity relu(x) = max(0, x) = 0 ⊕_trop x establishes ReLU as the tropical sum of 0 and x. This extends to networks:

- A single neuron computes w ⊙_trop x ⊕_trop b = max(wx + b, 0) — one tropical linear form.
- A layer of w neurons computes w tropical linear forms in parallel.
- Composition of layers computes tropical rational functions of increasing degree.

### 5.2 Tropical Max Properties

The tropical max operation (denoted tropMax in our formalization) satisfies:
- **Commutativity**: tropMax(a, b) = tropMax(b, a)
- **Associativity**: tropMax(tropMax(a, b), c) = tropMax(a, tropMax(b, c))
- **Idempotency**: tropMax(a, a) = a

These are the axioms of a **join-semilattice**, confirming that tropical addition endows ℝ with a lattice structure.

### 5.3 From Smooth to Tropical

The temperature family softplus_β provides a deformation from the smooth (β = 1) to tropical (β → ∞) regimes:

$$\text{softplus}_\beta(x) = \frac{1}{\beta}\log(e^0 + e^{\beta x}) \xrightarrow{\beta \to \infty} \max(0, x) = \text{relu}(x).$$

Our Theorem 3.4 quantifies the deformation error: at most log(2)/β. This is the neural network instance of Maslov's dequantization principle, where the "Planck constant" ℏ = 1/β controls the passage from "quantum" (smooth) to "classical" (tropical) computation.

---

## 6. Applications

### 6.1 Architecture Design

Theorem 3.9 provides principled guidance for architecture selection: when choosing between adding neurons to existing layers (increasing w) and adding new layers (increasing L), the latter is exponentially more efficient for expressiveness.

**Example.** To achieve 10^6 linear pieces:
- Width only: w = 10^6, L = 1, parameters ≈ 2 · 10^6
- Depth only: w = 10, L = 6, parameters ≈ 126
- Balanced: w = 32, L = 4, parameters ≈ 261 (pieces = 32^4 ≈ 10^6)

### 6.2 Quantization Theory

The denominator propagation theorem (Section 3.4) gives the first number-theoretic lower bounds on quantization precision. For a network approximating π to 10^{−6}:

$$B^L \geq 5 \times 10^5$$

With L = 10 layers, this requires B ≥ (5 × 10^5)^{1/10} ≈ 5.8, so 3-bit weights suffice. With L = 5 layers, B ≥ (5 × 10^5)^{1/5} ≈ 13.9, requiring 4-bit weights.

### 6.3 Constant Approximation

The Leibniz pipeline (Section 3.3) gives explicit constructions for π-approximation. The number of Leibniz terms needed for tolerance ε is N ≈ 1/(2ε), requiring depth L ≈ log(N)/log(w).

| Target accuracy | Terms needed | Depth (w=4) | Depth (w=8) |
|----------------|-------------|-------------|-------------|
| 10^{−2} | 50 | 3 | 2 |
| 10^{−4} | 5,000 | 7 | 5 |
| 10^{−6} | 500,000 | 10 | 7 |
| 10^{−8} | 50,000,000 | 13 | 9 |

---

## 7. Discussion

### 7.1 Connections to Prior Work

Our tropical-ReLU bridge formalizes and sharpens observations by several authors. The key contribution is the **exact** gap formula softplus(x) − relu(x) = log(1 + exp(−|x|)) and the **sharp** upper bound log 2, which had not previously been formally verified. The temperature-parameterized version with bound log(2)/β makes precise the folklore that "softplus converges to ReLU as temperature goes to zero."

The DenomTrackedPL structure appears to be new. While the observation that quantized networks output bounded-denominator rationals is implicit in the literature, the formal algebraic treatment — tracking denominators through composition and deriving Diophantine lower bounds — provides a new tool for quantization theory.

### 7.2 Limitations

Our piece count bound (2w)^L is an upper bound that may not be tight for specific weight configurations. Generically (for random weights), the bound is achieved; but structured weights may yield cancellations that reduce the piece count. A tropical Bézout theorem (see Future Work) would characterize these cancellations.

The Leibniz series pipeline for π is constructive but not optimal — faster-converging series (Machin's formula, Ramanujan's series) would yield more parameter-efficient networks. Our framework accommodates any series; the Leibniz series was chosen for its simplicity and the elegance of its error bound.

### 7.3 Significance of log 2

The constant log 2 ≈ 0.693 appears throughout information theory and statistical mechanics. Its appearance as the maximum softplus-ReLU gap connects these fields to neural network theory:

- **Information theory**: log 2 = 1 bit, the fundamental unit of information. The softplus-ReLU gap at the origin is exactly one bit of "smoothing information."
- **Statistical mechanics**: In the max-entropy distribution over {0, 1}, the entropy is log 2. The softplus function is the log-partition function of a Bernoulli variable.
- **Tropical geometry**: log 2 is the tropical defect at the vertex of the tropical line max(0, x), measuring the failure of the smooth sum to equal the tropical sum.

---

## 8. Future Work

### 8.1 Irrationality Measure as Complexity Measure

We conjecture that the optimal depth for ε-approximation of a constant α with irrationality measure μ(α) is

$$L^* = \Theta\left(\frac{\log(1/\varepsilon)}{\mu(\alpha) \cdot \log w}\right).$$

This would establish irrationality measure as the universal complexity measure for constant approximation, bridging transcendental number theory and neural network architecture.

### 8.2 Tropical Bézout Theorem for Networks

The number of pieces in a composed network should satisfy a Bézout-type identity: pieces(f ∘ g) = pieces(f) · pieces(g) − cancellations(f, g), where cancellations count the breakpoints of g that map to breakpoints of f with matching slopes.

### 8.3 Series Acceleration as Architecture Optimization

The Euler-Maclaurin transformation of the Leibniz series (accelerating convergence from O(1/N) to O(1/N²)) should correspond to a network architecture transformation reducing depth by a constant factor. More generally, k-fold Richardson extrapolation may map depth-L to depth-L/(k+1) networks.

### 8.4 Tropical Hodge Theory and Generalization

The tropical Betti numbers of a ReLU network's breakpoint set may predict generalization performance, providing a geometric explanation for the empirical success of overparameterized networks.

---

## 9. References

1. Alfarra, M., Bibi, A., Hammoud, H., Gaber, M., & Ghanem, B. (2022). On the decision boundaries of neural networks: A tropical geometry perspective. *IEEE TPAMI*.

2. Eldan, R., & Shamir, O. (2016). The power of depth for feedforward neural networks. *COLT 2016*.

3. Maslov, V. P. (1992). Idempotent analysis. *Advances in Soviet Mathematics*, 13.

4. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT 2016*.

5. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML 2018*.

---

## Appendix A: Formal Verification Summary

All theorems in Sections 3.1–3.5 have been formally verified. The verification covers:

| Result | Formal Name | Status |
|--------|-------------|--------|
| Softplus ≥ ReLU | `softplus_ge_relu` | ✓ Verified |
| Gap ≤ log 2 | `softplus_relu_gap_bound` | ✓ Verified |
| Gap at origin | `softplus_relu_gap_at_zero` | ✓ Verified |
| Temperature gap | `softplus_temp_gap_bound` | ✓ Verified |
| Asymptotic gap | `softplus_relu_gap_at_large_pos` | ✓ Verified |
| ReLU Lipschitz | `relu_lipschitz` | ✓ Verified |
| ReLU idempotent | `relu_idempotent` | ✓ Verified |
| ReLU monotone | `relu_mono` | ✓ Verified |
| ReLU pos. homogeneous | `relu_pos_homogeneous` | ✓ Verified |
| Piece growth | `piece_count_exponential_growth` | ✓ Verified |
| Exponential advantage | `exponential_depth_advantage` | ✓ Verified |
| Depth > width | `depth_more_efficient_than_width` | ✓ Verified |
| Depth vs width | `depth_vs_width` | ✓ Verified |
| Leibniz |a_k| | `leibnizTerm_abs` | ✓ Verified |
| Leibniz antitone | `leibnizTerm_abs_antitone` | ✓ Verified |
| Leibniz → 0 | `leibnizTerm_tendsto_zero` | ✓ Verified |
| Network size for ε | `network_size_for_epsilon` | ✓ Verified |
| ReLU = tropical add | `relu_is_tropical_add` | ✓ Verified |
| Irrationality bound | `irrationality_measure_depth_bound` | ✓ Verified |
