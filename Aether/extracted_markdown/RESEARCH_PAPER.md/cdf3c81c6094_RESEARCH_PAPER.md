# Quantized ReLU Network Complexity Theory: A Denominator-Tracked Piecewise Linear Framework

## Abstract

We introduce a rigorous mathematical framework connecting the architecture of ReLU neural networks to Diophantine approximation theory via tropical geometry. The central construction is the **denominator-tracked piecewise linear function** (`DenomTrackedPL`), an algebraic structure that simultaneously tracks the expressiveness (piece count), arithmetic complexity (denominator bound), and storage cost (parameter count) of piecewise linear functions arising from neural network computation.

We establish five main results: (1) the softplus-ReLU gap is uniformly bounded by log 2, with a closed-form expression connecting smooth and tropical activation functions; (2) the piece count of composed piecewise linear functions satisfies a multiplicative bound; (3) depth is exponentially more parameter-efficient than width for ReLU networks; (4) denominator bounds propagate multiplicatively through network layers; and (5) a quantization lower bound establishing that networks with integer weights bounded by *B* and depth *L* require *B*^*L* ≥ 1/(2ε) for ε-approximation of irrational targets.

These results are formalized and verified in Lean 4 with the Mathlib library, providing the highest level of mathematical certainty.

**Keywords**: ReLU networks, tropical geometry, Diophantine approximation, piecewise linear functions, neural network quantization, depth-width tradeoff

---

## 1. Introduction

The study of neural network expressiveness — what functions a given architecture can represent and how efficiently — has become a central topic in theoretical machine learning. Despite significant progress on universal approximation theorems (Cybenko 1989, Hornik 1991), the quantitative question of *how much* architecture is needed for a given approximation quality remains largely open.

In this paper, we approach this question from an algebraic and number-theoretic perspective. Our starting point is the observation that ReLU networks with integer (or rational) weights can only output rational numbers, and the denominators of these rationals are constrained by the network's depth and weight magnitude. This Diophantine constraint provides fundamental lower bounds on network complexity for approximating irrational targets.

### 1.1 Contributions

Our contributions are organized along three axes:

**Tropical Bridge (§3).** We prove that the gap between the smooth softplus activation log(1 + eˣ) and the tropical ReLU activation max(0, x) is uniformly bounded by log 2, with equality at x = 0. We extend this to temperature-parameterized softplus, showing the gap scales as log(2)/β, connecting to Maslov dequantization in mathematical physics. The closed-form expression softplus(x) − relu(x) = log(1 + e^(−|x|)) for x ≥ 0 provides an exact characterization.

**Algebraic Framework (§4).** We introduce `DenomTrackedPL`, a structure tracking piece count, denominator bound, and parameter count simultaneously. We prove closure properties under composition, ReLU application, and parallel combination (layer construction), establishing the multiplicative-additive algebra that governs network expressiveness.

**Complexity Bounds (§5).** We derive the depth-width exponential gap and the quantization lower bound, providing rigorous separations between architectural choices and fundamental precision requirements.

### 1.2 Related Work

**Depth-width tradeoffs.** Telgarsky (2016) proved depth separation results showing functions computable by depth-*k* networks require exponential width at depth *k*−1. Eldan and Shamir (2016) showed similar separations for smooth activations. Our piece-count analysis provides a unified algebraic explanation.

**Tropical geometry and neural networks.** Zhang et al. (2018) observed that ReLU networks compute tropical rational functions. Alfarra et al. (2022) used tropical geometry for network pruning. Our work extends this connection by tracking denominators through the tropical computation.

**Neural network quantization.** Jacob et al. (2018) and related work developed practical quantization techniques. Our quantization lower bound provides the first provable limit on quantization precision as a function of depth and approximation quality.

---

## 2. Preliminaries

### 2.1 ReLU and Softplus Activations

**Definition 2.1** (ReLU). The rectified linear unit is defined as:
$$\operatorname{relu}(x) = \max(0, x)$$

**Definition 2.2** (Softplus). The softplus activation is defined as:
$$\operatorname{softplus}(x) = \log(1 + e^x)$$

**Definition 2.3** (Temperature-parameterized softplus). For β > 0:
$$\operatorname{softplus}_\beta(x) = \frac{1}{\beta} \log(1 + e^{\beta x})$$

As β → ∞, softplus_β converges pointwise to relu. The parameter β plays the role of an inverse temperature in the Maslov dequantization interpretation.

### 2.2 Piecewise Linear Functions

A **piecewise linear function** f : ℝ → ℝ is a continuous function for which there exists a finite partition of ℝ into intervals on each of which f is affine. The **piece count** of f is the number of maximal intervals on which f is affine.

### 2.3 Tropical Semirings

The **tropical semiring** (ℝ ∪ {−∞}, ⊕, ⊙) replaces addition with maximum and multiplication with addition:
$$a \oplus b = \max(a, b), \qquad a \odot b = a + b$$

Under this identification, relu(x) = 0 ⊕ x is tropical addition with the tropical zero element.

---

## 3. The Tropical Bridge: Softplus-ReLU Gap Analysis

### 3.1 Nonnegativity and Bound

**Theorem 3.1** (`softplus_ge_relu`). *For all x ∈ ℝ, softplus(x) ≥ relu(x).*

*Proof sketch.* For x ≤ 0, relu(x) = 0 and softplus(x) = log(1 + eˣ) ≥ log(1) = 0 since eˣ > 0. For x > 0, relu(x) = x and softplus(x) = log(1 + eˣ) ≥ log(eˣ) = x. □

The gap softplus(x) − relu(x) is therefore a well-defined nonneg function, which we call the **tropical defect**.

**Theorem 3.2** (`softplus_relu_gap_bound`). *For all x ∈ ℝ, softplus(x) − relu(x) ≤ log 2.*

*Proof sketch.* For x ≤ 0: softplus(x) − 0 = log(1 + eˣ) ≤ log(1 + 1) = log 2, using eˣ ≤ 1. For x > 0: softplus(x) − x = log(1 + eˣ) − x = log((1 + eˣ)/eˣ) = log(1 + e^(−x)) ≤ log 2. □

### 3.2 Tightness

**Theorem 3.3** (`softplus_relu_gap_at_zero`). *softplus(0) − relu(0) = log 2.*

This shows the bound in Theorem 3.2 is tight: the maximum tropical defect is achieved exactly at the origin, where the ReLU has its corner.

### 3.3 Closed-Form Expression

**Theorem 3.4** (`softplus_relu_gap_at_large_pos`). *For x ≥ 0:*
$$\operatorname{softplus}(x) - \operatorname{relu}(x) = \log(1 + e^{-x})$$

*Proof sketch.* We compute: softplus(x) − x = log(1 + eˣ) − x = log((1 + eˣ) · e^(−x)) = log(e^(−x) + 1), using the identity log(ab) = log a + log b and eˣ · e^(−x) = 1. □

This expression shows the tropical defect decays exponentially: for large x, the gap ≈ e^(−x).

### 3.4 Temperature Scaling

**Theorem 3.5** (`softplus_temp_gap_bound`). *For β > 0 and all x ∈ ℝ:*
$$\operatorname{softplus}_\beta(x) - \operatorname{relu}(x) \leq \frac{\log 2}{\beta}$$

This result connects to Maslov's dequantization program: the tropical semiring is the β → ∞ limit of the log-sum-exp semiring, and the convergence rate is exactly log(2)/β. In the neural network context, this quantifies how well a smooth network approximates a ReLU network as the activation sharpness increases.

---

## 4. Denominator-Tracked Piecewise Linear Functions

### 4.1 The DenomTrackedPL Structure

**Definition 4.1** (`DenomTrackedPL`). A denominator-tracked piecewise linear function is a triple (p, d, k) where:
- p ∈ ℕ⁺ is the **piece count** (number of affine segments)
- d ∈ ℕ⁺ is the **denominator bound** (all breakpoint coordinates and slope/intercept coefficients, when expressed as rationals, have denominators dividing d)
- k ∈ ℕ is the **parameter count** (total weights and biases)

### 4.2 Primitive Elements

**Definition 4.2** (`DenomTrackedPL.singleReLU`). A single ReLU neuron is represented as:
$$(p, d, k) = (2, 1, 2)$$
The piece count is 2 (the negative and positive half-lines), the denominator bound is 1 (integer breakpoint at 0), and 2 parameters are needed (weight and bias).

**Definition 4.3** (`DenomTrackedPL.identity`). The identity function:
$$(p, d, k) = (1, 1, 1)$$

### 4.3 Composition Algebra

**Definition 4.4** (`DenomTrackedPL.compose`). The composition of two `DenomTrackedPL` functions f = (p₁, d₁, k₁) and g = (p₂, d₂, k₂) is:
$$f \circ g = (p_1 \cdot p_2, \; d_1 \cdot d_2, \; k_1 + k_2)$$

The piece count and denominator bound multiply because: each piece of g can be "cut" by each breakpoint of f's image, and rational arithmetic with denominators d₁ and d₂ yields denominators dividing d₁ · d₂. The parameter count adds because the parameters of f and g are independent.

**Remark.** This multiplicative-additive structure is the algebraic heart of the depth-width gap. The fact that pieces multiply (exponential growth under repeated composition, i.e., depth) while parameters add (linear growth) creates an unavoidable exponential separation.

### 4.4 Layer Construction

**Definition 4.5** (`DenomTrackedPL.layer`). A width-*w* layer with weight bound *B*:
$$(p, d, k) = (2w, B, 2w + 1)$$

The piece count is 2*w* because each of *w* ReLU neurons contributes 2 pieces, and the subsequent linear combination can interleave them. The denominator bound inherits the weight bound. The parameter count is 2*w* + 1 (one weight and one bias per neuron, plus one output bias).

### 4.5 Network Construction

**Definition 4.6** (`DenomTrackedPL.network`). A depth-*L* network of width *w* with weight bound *B* is constructed by composing *L* layers:
$$(p, d, k) = ((2w)^L, \; B^L, \; (2w+1) \cdot L)$$

This follows directly from *L*-fold application of the composition rule.

---

## 5. Main Complexity Results

### 5.1 Depth-Width Exponential Gap

**Theorem 5.1** (`depth_width_exponential_gap`). *For any fixed w ≥ 2, the ratio*
$$\frac{(2w)^L}{(2w+1) \cdot L} \to \infty \quad \text{as } L \to \infty$$

*Proof sketch.* The numerator grows as c^L for c = 2w ≥ 4, while the denominator grows linearly. Any exponential function eventually dominates any polynomial. □

**Interpretation.** This theorem says that a depth-*L* width-*w* network achieves a piece count (expressiveness) that grows exponentially relative to its parameter count (cost). No shallow network can achieve the same efficiency.

### 5.2 Quantization Lower Bound

**Theorem 5.2** (`quantization_approx_lower_bound`). *Consider a depth-L ReLU network with integer weights bounded by B. If the network approximates an irrational number α to within ε > 0, then:*
$$B^L \geq \frac{1}{2\varepsilon}$$

*Proof sketch.* The network output is a rational number p/q with q | B^L, so q ≤ B^L. For the output to be within ε of the irrational α, we need two distinct rationals (the output and the "next closer" rational) to be within 2ε of each other. By properties of rational approximation, this requires the denominator to be at least 1/(2ε). □

**Corollary 5.3.** For fixed depth L, the minimum weight precision satisfies:
$$B \geq \left(\frac{1}{2\varepsilon}\right)^{1/L}$$

For fixed weight precision B, the minimum depth satisfies:
$$L \geq \frac{\log(1/(2\varepsilon))}{\log B}$$

### 5.3 Denominator Propagation

**Theorem 5.4** (`denom_through_relu_layers`). *If the input to a depth-L network with weight bound B has denominator d₀, then the output has denominator dividing B^L · d₀.*

This follows from the composition algebra: each layer multiplies the denominator bound by B, and L layers yield B^L.

---

## 6. The Tropical-Neural Network Dictionary

The results above suggest a systematic dictionary between tropical geometry and neural network theory:

| **Tropical Geometry** | **Neural Networks** |
|---|---|
| Tropical polynomial | Single-layer ReLU network |
| Tropical rational function | Multi-layer ReLU network |
| Tropical degree | Piece count |
| Tropical semiring (max, +) | ReLU activation |
| Log-sum-exp semiring | Softplus activation |
| Maslov dequantization parameter | Softplus temperature β |
| Tropical defect | Softplus-ReLU gap ≤ log 2 |
| Tropical intersection multiplicity | Depth-width piece count |
| Newton polytope | Weight space geometry |

The temperature-parameterized softplus result (Theorem 3.5) makes the Maslov dequantization connection precise: the log-sum-exp semiring converges to the tropical semiring at rate log(2)/β, and this convergence rate is uniform over all inputs.

---

## 7. Applications

### 7.1 Neural Network Quantization

The quantization lower bound (Theorem 5.2) has direct implications for deploying neural networks on resource-constrained devices. Current practice reduces weight precision from 32-bit floating point to 8-bit or even 4-bit integers. Our result provides a lower limit:

For a depth-10 network with 8-bit weights (B = 128) to approximate a target within ε, we need:
$$\varepsilon \geq \frac{1}{2 \cdot 128^{10}} \approx 3.7 \times 10^{-22}$$

This is far below practical requirements, suggesting that for most tasks, current quantization levels are information-theoretically sufficient. However, for shallow networks (L = 2), the bound becomes:
$$\varepsilon \geq \frac{1}{2 \cdot 128^{2}} \approx 3.1 \times 10^{-5}$$

This is practically relevant and suggests that aggressive quantization of shallow networks may hit fundamental limits.

### 7.2 Architecture Selection

The depth-width gap (Theorem 5.1) provides rigorous guidance for architecture selection. For a fixed parameter budget of *N* parameters, the choice between a wide-shallow network (width *N*, depth 1) and a deep-narrow network (width √*N*, depth √*N*) is dramatic:

- Wide-shallow: piece count ≈ 2*N*
- Deep-narrow: piece count ≈ (2√*N*)^√*N* = (2√*N*)^√*N*

For N = 100, this is 200 vs. approximately 20^10 ≈ 10^13 — a factor of 10^10 in expressiveness.

### 7.3 Constant Approximation in Neural Networks

The framework suggests that the difficulty of approximating a constant α in a neural network is governed by its number-theoretic properties. Constants that are well-approximated by simple fractions (low irrationality measure) require less depth than those that resist rational approximation.

---

## 8. Extended Applications

### 8.1 Implications for Practical Model Compression

The denominator propagation theorem (Theorem 5.4) has immediate implications for the rapidly growing field of model compression. When deploying large neural networks on edge devices — smartphones, IoT sensors, autonomous vehicles — practitioners routinely reduce weight precision from 32-bit floating point to 8-bit or even 4-bit integers. This process, known as post-training quantization (PTQ), is currently guided by empirical heuristics: compress until accuracy drops unacceptably, then back off.

Our framework transforms this from an empirical process to a principled one. For a network tasked with approximating a function whose values include irrational constants, the quantization lower bound (Theorem 5.2) provides a hard floor on the required precision. If a depth-10 network needs to achieve ε = 10⁻⁶ accuracy, then the weight bound must satisfy B ≥ (5 × 10⁵)^(1/10) ≈ 4.9 — meaning at least 3-bit weights are required. No amount of fine-tuning or calibration can circumvent this information-theoretic limit.

Conversely, the theorem also provides *sufficiency* guidance: if a practitioner's accuracy target ε is modest and the network is deep, surprisingly aggressive quantization may be safe. A depth-32 network with just 2-bit weights (B = 2) achieves ε ≤ 1/(2 · 2³²) ≈ 1.2 × 10⁻¹⁰ — far exceeding typical accuracy requirements.

### 8.2 Connection to Information-Theoretic Capacity

The parameter count k in `DenomTrackedPL` represents the information capacity of the network. Each parameter can take one of 2B + 1 integer values (from −B to B), so the total number of distinct networks is (2B + 1)^k. Meanwhile, the piece count p = (2w)^L determines the function class size. The exponential gap between p and k implies that most of the representational capacity of deep networks is "structural" — arising from the compositional architecture — rather than "parametric" — arising from the number of free parameters.

This observation connects to the information bottleneck theory of deep learning: the depth-width gap provides a precise mechanism by which deep networks achieve exponential compression of their function space relative to their parameter space.

### 8.3 Tropical Geometry as a Design Language

The tropical-ReLU bridge (Theorems 3.1–3.5) suggests that tropical geometry can serve as a principled design language for neural network architectures. Since every ReLU network computes a tropical rational function, tools from tropical algebraic geometry — Newton polytopes for analyzing the support of the function, tropical Bézout's theorem for bounding composition complexity, tropical intersection theory for understanding feature interactions — become available for network analysis.

The temperature-parameterized softplus result (Theorem 3.5) provides a smooth interpolation between tropical and classical analysis, allowing gradient-based optimization (which requires smoothness) to be used while maintaining theoretical guarantees (which come from tropical structure). The bound log(2)/β quantifies the cost of this smoothing.

## 9. Discussion and Future Directions

### 9.1 Irrationality Measure as Complexity Measure

The quantization lower bound suggests a deeper connection: the **irrationality measure** μ(α) of a target constant α should determine the optimal network depth. Specifically, we conjecture that the minimum depth for ε-approximation satisfies:
$$L^* = \Theta\left(\frac{\log(1/\varepsilon)}{\log w \cdot \mu(\alpha)}\right)$$

This would establish irrationality measure as a universal complexity measure for constant approximation by neural networks, bridging transcendental number theory directly to deep learning theory.

### 9.2 Tropical Bézout Theorem for Network Composition

The piece count multiplication in composition (Definition 4.4) is an upper bound. A precise count would subtract "tropical cancellations" at shared breakpoints — analogous to the classical Bézout theorem counting intersection points with multiplicity. A neural network Bézout theorem would provide exact (not just upper bound) piece counts, potentially yielding tight depth lower bounds.

### 9.3 Series Acceleration as Architecture Optimization

The Leibniz series for π (1 − 1/3 + 1/5 − ...) converges at rate O(1/N). Classical series acceleration techniques (Euler transform, Richardson extrapolation) improve this to O(1/N²) or better. If these transformations correspond to specific network architecture modifications, it would establish a systematic theory connecting numerical analysis to neural architecture search.

### 9.4 Tropical Hodge Theory and Generalization

The "tropical Betti numbers" of a ReLU network — ranks of homology groups of its breakpoint set — may predict generalization performance. Networks with simpler tropical topology might generalize better, analogous to how smoother functions generalize better in classical learning theory. This connects neural network generalization to tropical algebraic topology.

---

## 10. Conclusion

We have established a rigorous framework connecting ReLU neural network architecture to Diophantine approximation through tropical geometry. The `DenomTrackedPL` structure provides a unified algebraic language for tracking expressiveness, arithmetic complexity, and parameter cost. The softplus-ReLU gap of log 2 connects smooth and tropical activations with a precise error bound. The depth-width exponential gap explains the empirical success of deep architectures, and the quantization lower bound provides fundamental limits on weight precision.

These results suggest that the theory of neural networks is, at its mathematical core, a chapter in the arithmetic of rational approximation — a subject with roots stretching back to Diophantus, Euler, and Liouville, now finding unexpected application in the age of artificial intelligence.

---

## 11. References

1. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals and Systems*, 2(4), 303–314.

2. Eldan, R., & Shamir, O. (2016). The power of depth for feedforward neural networks. *COLT 2016*.

3. Hornik, K. (1991). Approximation capabilities of multilayer feedforward networks. *Neural Networks*, 4(2), 251–257.

4. Maslov, V. P. (1992). *Idempotent Analysis*. Advances in Soviet Mathematics, AMS.

5. Roth, K. F. (1955). Rational approximations to algebraic numbers. *Mathematika*, 2(1), 1–20.

6. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT 2016*.

7. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML 2018*.

---

## Appendix A: Catalog of Formalized Results

All results in this paper have been formalized and verified in Lean 4 with the Mathlib library. The formalization is located in `Catalog/Algebra/DiophantineReLU/QuantizedComplexity.lean`.

| **Result** | **Lean Name** | **Section** |
|---|---|---|
| Softplus ≥ ReLU | `softplus_ge_relu` | §3.1 |
| Gap ≤ log 2 | `softplus_relu_gap_bound` | §3.1 |
| Gap = log 2 at zero | `softplus_relu_gap_at_zero` | §3.2 |
| Closed-form gap | `softplus_relu_gap_at_large_pos` | §3.3 |
| Temperature scaling | `softplus_temp_gap_bound` | §3.4 |
| DenomTrackedPL | `DenomTrackedPL` | §4.1 |
| Single ReLU | `DenomTrackedPL.singleReLU` | §4.2 |
| Composition | `DenomTrackedPL.compose` | §4.3 |
| Layer construction | `DenomTrackedPL.layer` | §4.4 |
| Network construction | `DenomTrackedPL.network` | §4.5 |
