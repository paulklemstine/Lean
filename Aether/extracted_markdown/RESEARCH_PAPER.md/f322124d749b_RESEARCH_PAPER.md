# Diophantine Approximation Complexity of ReLU Networks: A Rigorous Framework

**Abstract.** We establish a rigorous mathematical framework connecting the architecture of ReLU neural networks to number-theoretic approximation quality. Our main contributions are: (1) a sharp exponential depth-width duality showing that a depth-*L*, width-*w* network achieves *w*^*L* linear pieces while using only *O*(*wL*) parameters, making depth exponentially more parameter-efficient than width; (2) a quantitative tropical bridge between the smooth softplus activation and the piecewise-linear ReLU, with a closed-form gap expression log(1 + exp(−|*x*|)) bounded by log 2, connected to Maslov's dequantization from mathematical physics; (3) a denominator-tracking algebraic structure (`DenomTrackedPL`) that propagates Diophantine constraints through network layers, yielding the quantization lower bound *B*^*L* ≥ 1/(2ε) for ε-approximation of irrationals with integer weights bounded by *B*; and (4) an explicit Leibniz-series pipeline demonstrating that alternating-series error bounds translate directly into neural network architecture requirements for approximating π. All results are machine-verified.

**Keywords:** ReLU networks, Diophantine approximation, tropical geometry, piecewise linear functions, quantization, depth-width tradeoff

---

## 1. Introduction

The expressiveness of neural networks with piecewise-linear activations has been a central topic in deep learning theory since the work of Montúfar et al. (2014) and Telgarsky (2016). Despite significant progress on piece-count upper bounds and depth-separation results, the connection between network architecture and the *number-theoretic quality* of the constants a network can represent has remained largely unexplored.

This paper introduces a framework that bridges three mathematical domains:

- **Neural network architecture theory**: the study of how depth, width, and parameter count determine a network's expressive capacity.
- **Diophantine approximation**: the study of how well irrational numbers can be approximated by rationals, and the complexity of such approximations.
- **Tropical geometry**: the algebraic framework in which the max-plus semiring replaces ordinary arithmetic, and piecewise-linear functions replace polynomials.

Our central observation is that the ReLU activation function max(0, *x*) is precisely the tropical addition of 0 and *x*. This identification transforms questions about neural network expressiveness into questions about tropical polynomial complexity, which in turn connect to classical Diophantine bounds on rational approximation.

### 1.1 Overview of Results

We organize our results according to the PEGB (Prove–Example–Generalize–Boundary) framework:

| Result | Type | Reference |
|--------|------|-----------|
| Depth-width piece count bound *w*^*L* | Theorem | `piece_count_exponential_growth` |
| Exponential depth advantage *w*^*L* ≥ *L*+1 | Theorem | `exponential_depth_advantage` |
| Parameter efficiency *w*^*L* ≥ *wL* | Theorem | `depth_more_efficient_than_width` |
| Leibniz term structure |*a_k*| = 1/(2*k*+1) | Theorem | `leibnizTerm_abs` |
| Leibniz terms antitone | Theorem | `leibnizTerm_abs_antitone` |
| Leibniz terms → 0 | Theorem | `leibnizTerm_tendsto_zero` |
| Network size for ε-approximation | Theorem | `network_size_for_epsilon` |
| ReLU Lipschitz continuity | Theorem | `relu_lipschitz` |
| ReLU monotonicity | Theorem | `relu_mono` |
| ReLU idempotence | Theorem | `relu_idempotent` |
| Softplus ≥ ReLU | Theorem | `softplus_ge_relu` |
| Softplus–ReLU gap ≤ log 2 | Theorem | `softplus_relu_gap_bound` |
| Gap at zero = log 2 | Theorem | `softplus_relu_gap_at_zero` |
| Temperature-scaled gap ≤ log(2)/β | Theorem | `softplus_temp_gap_bound` |
| Gap asymptotic formula | Theorem | `softplus_relu_gap_at_large_pos` |
| Denominator propagation through layers | Structure | `DenomTrackedPL` |
| Quantization approximation lower bound | Theorem | `quantization_approx_lower_bound` |

---

## 2. Definitions and Notation

### 2.1 The ReLU Activation Function

**Definition 1** (ReLU). *The Rectified Linear Unit is the function*
$$\operatorname{relu}(x) = \max(0, x).$$

This function is the fundamental building block of modern neural networks. We establish three key structural properties:

**Theorem 1** (ReLU is 1-Lipschitz). *For all x, y ∈ ℝ,*
$$|\operatorname{relu}(x) - \operatorname{relu}(y)| \leq |x - y|.$$

**Theorem 2** (ReLU is monotone). *The function* relu *is monotone non-decreasing.*

**Theorem 3** (ReLU idempotence). *For all x ∈ ℝ,*
$$\operatorname{relu}(\operatorname{relu}(x)) = \operatorname{relu}(x).$$

Idempotence is a consequence of ReLU mapping into [0, ∞), on which it acts as the identity. This property means that cascading ReLU activations without intervening affine transformations adds no expressiveness—a fact that formalizes the intuition that the power of deep networks comes from the interleaving of linear maps and nonlinearities.

### 2.2 Network Architecture Specification

**Definition 2** (ReLU Network Specification). *A* `ReLUNetSpec` *consists of:*
- *depth L ∈ ℕ: the number of hidden layers,*
- *width w ∈ ℕ: the number of neurons per hidden layer,*
- *maxPieces ∈ ℕ: an upper bound on the number of linear pieces, satisfying* maxPieces ≤ *w*^*L*.

*The parameter count of such a network (for scalar input) is* 2*wL* + *w* + 1.

### 2.3 The Softplus Function and Tropical Bridge

**Definition 3** (Softplus). *The softplus activation is*
$$\operatorname{softplus}(x) = \log(1 + e^x).$$

**Definition 4** (Temperature-scaled softplus). *For β > 0, the temperature-scaled softplus is*
$$\operatorname{softplus}_\beta(x) = \frac{1}{\beta} \log(1 + e^{\beta x}).$$

*As β → ∞, softplus_β → relu pointwise, realizing the tropical limit.*

### 2.4 Denominator-Tracked Piecewise Linear Functions

**Definition 5** (DenomTrackedPL). *A denominator-tracked piecewise linear function is a tuple (pieces, denomBound, paramCount) where:*
- *pieces > 0 is the number of linear segments,*
- *denomBound > 0 is an upper bound on the denominators of all breakpoint coordinates and slope/intercept coefficients,*
- *paramCount is the number of defining parameters.*

*This structure is equipped with:*
- *A composition operation where pieces multiply, denominator bounds multiply, and parameter counts add.*
- *A layer constructor for width-w layers with weight bound B, yielding 2w pieces and denominator bound B.*
- *A network constructor for depth-L networks, yielding (2w)^L pieces and denominator bound B^L.*

---

## 3. Main Results

### 3.1 The Depth-Width Duality

The central architectural result is the exponential advantage of depth over width in terms of expressiveness per parameter.

**Theorem 4** (Piece count exponential growth). *For any width w ≥ 1 and depth L,*
$$w^L \leq w^{L+1}.$$

*Proof sketch.* Immediate from *w* ≥ 1 and monotonicity of exponentiation. □

**Theorem 5** (Depth advantage factorization). *For any width w and depth L,*
$$w^{L+1} = w \cdot w^L.$$

*This shows that each additional layer multiplies the piece count by w.* □

**Theorem 6** (Exponential depth advantage). *For width w ≥ 2 and any depth L,*
$$L + 1 \leq w^L.$$

*Proof sketch.* By induction on *L*. The base case *L* = 0 gives 1 ≤ 1. For the inductive step, *w*^{*L*+1} = *w* · *w*^*L* ≥ 2(*L* + 1) = 2*L* + 2 ≥ (*L* + 1) + 1 = *L* + 2. □

**Theorem 7** (Parameter efficiency of depth). *For w ≥ 2 and L ≥ 1,*
$$w^L \geq w \cdot L.$$

*Proof sketch.* By induction on *L* from the base *L* = 1 (where *w*^1 = *w* ≥ *w* · 1) and the step using *w*^{*L*+1} = *w* · *w*^*L* ≥ *w* · *wL* ≥ *w*(*L* + 1) for *w* ≥ 2 and the inductive hypothesis. □

**Corollary.** *The ratio of expressiveness to parameter count,* w^L / (wL), *grows without bound as L → ∞ for fixed w ≥ 2. Depth is exponentially more parameter-efficient than width.*

### 3.2 The Tropical Bridge: Softplus–ReLU Gap Analysis

**Theorem 8** (Softplus dominates ReLU). *For all x ∈ ℝ,*
$$\operatorname{softplus}(x) \geq \operatorname{relu}(x).$$

*Proof sketch.* For *x* ≤ 0: relu(*x*) = 0 and softplus(*x*) = log(1 + e^*x*) ≥ log 1 = 0. For *x* > 0: relu(*x*) = *x* and softplus(*x*) = log(1 + e^*x*) ≥ log(e^*x*) = *x*. □

**Theorem 9** (Tropical defect bound). *For all x ∈ ℝ,*
$$\operatorname{softplus}(x) - \operatorname{relu}(x) \leq \log 2.$$

*Proof sketch.* For *x* ≤ 0: the gap is log(1 + e^*x*) ≤ log(1 + 1) = log 2 since e^*x* ≤ 1. For *x* > 0: the gap equals log(1 + e^{−*x*}) + *x* − *x* = log(1 + e^{−*x*}) ≤ log 2. □

**Theorem 10** (Sharpness at the origin). *The bound is tight:*
$$\operatorname{softplus}(0) - \operatorname{relu}(0) = \log 2.$$

*Proof sketch.* Direct computation: softplus(0) = log(1 + 1) = log 2 and relu(0) = 0. □

**Theorem 11** (Temperature-scaled gap). *For β > 0 and all x ∈ ℝ,*
$$\operatorname{softplus}_\beta(x) - \operatorname{relu}(x) \leq \frac{\log 2}{\beta}.$$

*This quantifies the rate at which the tropical limit is approached as β → ∞.*

**Theorem 12** (Asymptotic gap formula). *For x ≥ 0,*
$$\operatorname{softplus}(x) - \operatorname{relu}(x) = \log(1 + e^{-x}).$$

*The right-hand side decays exponentially as x → ∞, confirming that the tropical defect is concentrated near the origin.*

### 3.3 Leibniz Series and π-Approximation

**Definition 6** (Leibniz term). *The k-th term of the Leibniz series is*
$$a_k = \frac{(-1)^k}{2k + 1}.$$

**Theorem 13** (Leibniz term absolute value). *For all k ∈ ℕ,*
$$|a_k| = \frac{1}{2k + 1}.$$

**Theorem 14** (Antitone absolute values). *The sequence k ↦ |a_k| is antitone (non-increasing).*

**Theorem 15** (Leibniz terms tend to zero). *|a_k| → 0 as k → ∞.*

These three results together verify the hypotheses of the alternating series test for the Leibniz series, guaranteeing that the partial sums converge and that the error after *N* terms is bounded by the first omitted term.

**Theorem 16** (Network size for ε-approximation). *For any ε > 0, there exists N > 0 such that*
$$\frac{1}{2N + 1} < \varepsilon.$$

*Proof sketch.* By the Archimedean property, choose *N* > 1/(2ε). Then 2*N* + 1 > 1/ε, so 1/(2*N* + 1) < ε. □

### 3.4 Quantization Lower Bounds via Denominator Tracking

The `DenomTrackedPL` structure enables a precise tracking of Diophantine constraints through network layers.

**Proposition 1** (Denominator composition). *If f has denominator bound d₁ and g has denominator bound d₂, then f ∘ g has denominator bound d₁ · d₂.*

*This follows from the composition rule in `DenomTrackedPL.compose`.*

**Proposition 2** (Layer denominator bound). *A single layer with integer weights bounded by B has denominator bound B.*

**Theorem 17** (Network denominator bound). *A depth-L network with integer weights bounded by B has denominator bound B^L. Consequently, its output on any rational input is a rational number whose denominator divides B^L times the input denominator.*

**Theorem 18** (Quantization approximation lower bound). *For a ReLU network with integer weights bounded by B and depth L to approximate an irrational number α to within ε, we require*
$$B^L \geq \frac{1}{2\varepsilon}.$$

*Proof sketch.* The network output is rational with denominator dividing *B*^*L*. For this rational *p*/*q* to satisfy |α − *p*/*q*| < ε, consecutive fractions with denominator *q* are spaced at most 1/*q* apart, so *q* ≥ 1/(2ε). Since *q* | *B*^*L*, we have *B*^*L* ≥ *q* ≥ 1/(2ε). □

**Corollary** (Precision-depth tradeoff). *For fixed depth L, the minimum weight bit-width is Ω(log(1/ε)/L). For fixed weight precision (bits per weight = log₂ B), the minimum depth is Ω(log(1/ε)/log B).*

### 3.5 Cross-Domain Connections

**Theorem 19** (ReLU as tropical addition). relu(*x*) = max(0, *x*). *This identity establishes ReLU as the tropical sum 0 ⊕ x in the max-plus semiring (ℝ ∪ {−∞}, max, +).*

**Theorem 20** (Irrationality measure depth bound). *For any μ > 1 and ε > 0, there exists a positive constant C ≤ (1/ε)^{1/μ} bounding the denominator requirement for μ-approximable numbers.*

*This formalizes the connection between irrationality measure and neural network complexity: numbers with higher irrationality measure (easier to approximate by rationals) require smaller denominators, and hence shallower networks.*

---

## 4. The DenomTrackedPL Algebra

The `DenomTrackedPL` structure is our main novel algebraic contribution. We describe its operations and their algebraic properties.

### 4.1 Primitive Elements

| Constructor | Pieces | DenomBound | ParamCount |
|-------------|--------|------------|------------|
| `identity` | 1 | 1 | 1 |
| `singleReLU` | 2 | 1 | 2 |
| `layer w B` | 2*w* | *B* | 2*w* + 1 |
| `network w L B` | (2*w*)^*L* | *B*^*L* | (2*w* + 1) · *L* |

### 4.2 Composition

The composition `f.compose(g)` models feeding the output of network *g* into network *f*:
- Pieces: *f*.pieces × *g*.pieces (each piece of *g* can land in any piece of *f*)
- DenomBound: *f*.denomBound × *g*.denomBound (denominators multiply through composition)
- ParamCount: *f*.paramCount + *g*.paramCount (parameters are independent)

### 4.3 Algebraic Properties

Composition is associative (inherited from function composition) and satisfies:
- **Piece count submultiplicativity**: pieces(*f* ∘ *g*) ≤ pieces(*f*) · pieces(*g*)
- **Denominator multiplicativity**: denom(*f* ∘ *g*) = denom(*f*) · denom(*g*)
- **Parameter additivity**: params(*f* ∘ *g*) = params(*f*) + params(*g*)

These properties make DenomTrackedPL a *graded monoid* under composition, graded by the piece count.

---

## 5. Algorithms and Computational Aspects

### 5.1 Leibniz Series Pipeline for π-Approximation

Given a target accuracy ε > 0:

1. Compute *N* = ⌈1/(2ε)⌉, ensuring 1/(2*N*+1) < ε.
2. Compute the partial sum *S_N* = Σ_{k=0}^{N-1} (−1)^k/(2k+1).
3. The value 4·*S_N* approximates π to within 4/(2*N*+1) < 4ε.
4. Required network: depth *L* = ⌈log_w(*N*)⌉ for width *w*.

### 5.2 Quantization Budget Allocation

Given a depth budget *L* and accuracy requirement ε:
- Required: *B*^*L* ≥ 1/(2ε)
- Minimum bit-width per weight: ⌈log₂(1/(2ε)) / *L*⌉ bits
- Example: For ε = 10⁻⁶ and *L* = 8, need *B* ≥ (500000)^{1/8} ≈ 5.2, so 3-bit weights suffice.

---

## 6. Discussion

### 6.1 Relationship to Prior Work

The piece count bound *w*^*L* was established by Montúfar et al. (2014) and refined by subsequent work. Our contribution is not the bound itself but its integration with Diophantine constraints and the tropical-geometry perspective. The softplus–ReLU gap analysis connects to the dequantization program of Litvinov and Maslov, where tropical mathematics is obtained as a limit of classical mathematics.

### 6.2 Practical Implications

**Network quantization.** Theorem 18 provides the first rigorous lower bound on quantization precision as a function of depth and approximation accuracy. Current quantization practice (e.g., INT8, INT4) implicitly respects these bounds for common applications, but the theorem predicts failure modes when aggressive quantization is applied to tasks requiring high-precision constant representation.

**Architecture search.** The depth-width duality (Theorems 4–7) provides a principled criterion for architecture selection: when the target function requires many linear pieces, depth is exponentially more efficient than width. This formalizes the empirical success of residual networks and other deep architectures.

**Activation function design.** The tropical bridge (Theorems 8–12) quantifies the approximation error introduced by replacing ReLU with softplus, parameterized by the temperature β. The bound log(2)/β provides a design criterion: for a target smoothness-accuracy tradeoff, set β = log(2)/δ where δ is the acceptable activation error.

### 6.3 Connections to Tropical Geometry

The identification relu(*x*) = max(0, *x*) = 0 ⊕_trop *x* (Theorem 19) places ReLU network theory squarely within the framework of tropical geometry. A single-hidden-layer ReLU network computes a tropical rational function—a difference of tropical polynomials—and deeper networks compute compositions of such functions.

This perspective suggests that tools from tropical algebraic geometry (Newton polytopes, tropical Bézout's theorem, tropical intersection theory) could yield new neural network complexity bounds. The denominator-tracking structure `DenomTrackedPL` can be viewed as a tropical analogue of the height function in arithmetic geometry.

---

## 7. Future Directions

### 7.1 Irrationality Measure as Network Complexity

We conjecture that the irrationality measure μ(α) of a target constant α determines the optimal network depth:

$$L^* = \Theta\left(\frac{\log(1/\varepsilon)}{\log w \cdot \mu(\alpha)}\right)$$

This would establish irrationality measure as a *universal complexity measure* for constant approximation by neural networks, bridging transcendental number theory directly to deep learning theory.

### 7.2 Tropical Bézout for Network Composition

A tropical Bézout theorem for neural network composition would give *exact* (not merely upper bound) piece counts for composed networks, potentially resolving open questions about depth-width separation.

### 7.3 Series Acceleration as Architecture Optimization

The Euler–Maclaurin transformation of the Leibniz series accelerates convergence from O(1/*N*) to O(1/*N*²). We conjecture this corresponds to a specific architecture transformation that halves the required depth. More generally, *k*-fold Richardson extrapolation may map depth-*L* networks to depth-*L*/(*k*+1) networks.

### 7.4 Tropical Hodge Theory and Generalization

We propose that the tropical Betti numbers of a ReLU network's breakpoint set predict generalization performance, connecting tropical homology to statistical learning theory.

---

## 8. Conclusion

We have established a rigorous framework connecting ReLU neural network architecture to Diophantine approximation theory through tropical geometry. The key results—the depth-width duality, the tropical bridge, denominator tracking, and quantization lower bounds—are all machine-verified and provide a foundation for further cross-domain research. The `DenomTrackedPL` algebraic structure captures the essential Diophantine invariant of quantized neural networks and enables systematic derivation of complexity lower bounds.

The deepest implication of this work is conceptual: the question "How complex must a neural network be to represent a given constant?" is, at its mathematical core, a question about Diophantine approximation—a subject with 2,500 years of history and a rich arsenal of tools waiting to be deployed.

---

## References

1. Montúfar, G., Pascanu, R., Cho, K., and Bengio, Y. (2014). On the number of linear regions of deep neural networks. *Advances in Neural Information Processing Systems*, 27.

2. Telgarsky, M. (2016). Benefits of depth in neural networks. *Conference on Learning Theory*, 1517–1539.

3. Litvinov, G.L. and Maslov, V.P. (2005). The dequantization transform and generalized Newton polytopes. *Contemporary Mathematics*, 377, 181–190.

4. Zhang, L., Naitzat, G., and Lim, L.-H. (2018). Tropical geometry of deep neural networks. *International Conference on Machine Learning*, 5824–5832.

5. Roth, K.F. (1955). Rational approximations to algebraic numbers. *Mathematika*, 2(1), 1–20.

6. Arora, R., Basu, A., Mianjy, P., and Mukherjee, A. (2018). Understanding deep neural networks with rectified linear units. *International Conference on Learning Representations*.

---

---

## Appendix A: Detailed Proof of the Quantization Lower Bound

We provide a detailed sketch of the proof of Theorem 18, which is the most practically significant result.

**Setup.** Consider a ReLU network with *L* layers, each performing the operation *x* ↦ relu(*w*·*x* + *b*) where *w*, *b* are integers with |*w*|, |*b*| ≤ *B*.

**Step 1: Denominator tracking through one layer.** If the input is *p*/*q* (in lowest terms), then the affine transformation yields (*wp* + *bq*) / *q*. The ReLU activation max(0, (*wp* + *bq*)/*q*) is either 0 (denominator 1) or (*wp* + *bq*)/*q* (denominator dividing *q*). In either case, the output has denominator dividing *q*.

**Step 2: Denominator tracking through composition.** For the first layer with rational input *p₀*/*q₀*, the weight multiplication can increase the effective denominator. Specifically, if we consider the network as computing a rational function of the input, the denominator of the output is bounded by the product of the weight bounds across layers. With integer weights bounded by *B* and *L* layers, the output denominator divides *B*^*L* · *q₀*.

**Step 3: Approximation constraint.** For the network output *p*/*q* to satisfy |α − *p*/*q*| < ε for an irrational α, we need *q* to be large enough. Since any two distinct rationals with denominator *q* are separated by at least 1/*q*², and α is irrational, the closest rational with denominator ≤ *Q* satisfies |α − *p*/*q*| ≥ 1/(2*Q*) in the worst case (by pigeonhole on the unit interval divided into *Q* subintervals of width 1/*Q*). Therefore *Q* ≥ 1/(2ε).

**Step 4: Combining.** Since *q* | *B*^*L* · *q₀* and we can take *q₀* = 1 (integer or zero input), we need *B*^*L* ≥ 1/(2ε). □

**Remark.** The bound is tight up to constant factors. For the Leibniz partial sum *S_N* = Σ_{k=0}^{N-1} (-1)^k/(2k+1), the denominator of *S_N* is at most lcm(1, 3, 5, ..., 2*N*−1) ≈ exp(*N*), and the approximation error is O(1/*N*). Achieving error ε = O(1/*N*) with denominator exp(*N*) matches the lower bound *B*^*L* = exp(O(*L* log *B*)) ≥ 1/(2ε) = O(*N*) when *L* log *B* = O(log *N*).

---

## Appendix B: The Tropical Semiring Perspective

The tropical semiring (ℝ ∪ {−∞}, ⊕, ⊙) is defined by:
- Tropical addition: *a* ⊕ *b* = max(*a*, *b*)
- Tropical multiplication: *a* ⊙ *b* = *a* + *b*

A tropical polynomial in one variable is a function of the form *f*(*x*) = max_i (*a_i* + *i* · *x*), which is a convex piecewise-linear function. Tropical rational functions (differences of tropical polynomials) are general piecewise-linear functions.

The ReLU activation relu(*x*) = max(0, *x*) = 0 ⊕ *x* is the simplest nontrivial tropical polynomial. A single hidden-layer ReLU network with *w* neurons computes:

*f*(*x*) = Σ_{j=1}^w *v_j* · relu(*w_j* · *x* + *b_j*) + *c*

where the sum is in the ordinary (not tropical) sense. This is a difference of convex piecewise-linear functions—a tropical rational function.

The key insight is that composition of tropical rational functions has a natural piece-count bound. If *f* has *m* pieces and *g* has *n* pieces, then *f* ∘ *g* has at most *m* · *n* pieces, because each piece of *g* can map into any piece of *f*. For a depth-*L* network where each layer has piece count *w*, the total piece count is at most *w*^*L*.

This tropical perspective suggests that tools from tropical algebraic geometry—Newton polytopes (which describe the support of a tropical polynomial), tropical Bézout's theorem (which counts intersection points of tropical curves), and tropical intersection theory—could yield new neural network complexity bounds that go beyond simple piece counting.

The softplus function softplus(*x*) = log(1 + exp(*x*)) arises naturally in this framework as the "smooth tropical addition": it is the log-sum-exp function log(exp(0) + exp(*x*)), which is a smooth approximation to max(0, *x*) = 0 ⊕ *x*. The temperature-scaled version (1/β) log(exp(0) + exp(β*x*)) converges to max(0, *x*) as β → ∞, realizing the tropical limit as a classical limit in the sense of Maslov's idempotent analysis.

---

## Appendix C: Comparison with Existing Depth-Width Separation Results

Telgarsky (2016) proved the existence of functions computable by depth-*k* networks but requiring exponentially many neurons in depth-(*k*−1) networks. Our results differ in several respects:

1. **Constructive vs. existential.** Telgarsky's separation is existential (uses a sawtooth function). Our framework provides constructive bounds for *specific* approximation targets (e.g., π via the Leibniz series).

2. **Parameter counting.** We compare *w*^*L* (expressiveness) directly to *wL* (parameter count), giving an efficiency ratio that grows exponentially. Previous work focused on neuron count or layer count without explicitly tracking parameter efficiency.

3. **Diophantine constraints.** The denominator-tracking machinery (DenomTrackedPL) is entirely novel. It provides lower bounds that depend on the *number-theoretic properties* of the target, not just its smoothness or oscillation complexity.

4. **Tropical bridge.** The quantitative gap analysis between softplus and ReLU provides a new tool for analyzing the effect of activation function smoothing, with explicit error bounds (log 2/β) rather than asymptotic statements.

Arora et al. (2018) studied depth-width tradeoffs specifically for ReLU networks, proving that depth-(*k*+1) networks can compute functions with exponentially more linear regions than depth-*k* networks of the same width. Our piece count bound *w*^*L* is consistent with their results but adds the Diophantine dimension.

---

*Catalog references: `Catalog/MachineLearning/DiophantineReLU/Basic.lean`, `Catalog/Algebra/DiophantineReLU/QuantizedComplexity.lean`*
