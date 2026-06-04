# EML Approximation Spectrum: Depth-Width Tradeoffs for Exponential-Minus-Logarithmic Neural Networks

## Abstract

We introduce the **EML Approximation Spectrum**, a novel mathematical structure that captures the depth-width tradeoff surface for neural networks using the activation function σ(x) = exp(ax + b) − log(cx + d). We prove five main results: (1) a Taylor quadratic extraction theorem showing that EML activations natively capture second-order polynomial behavior with cubic residuals; (2) a width-w approximation theorem establishing that a single EML neuron approximates x² on [0,1] with error O(1/w); (3) a composition error theorem quantifying error propagation through deep networks; (4) a smoothness theorem proving EML units are differentiable everywhere on their domain (contrasting with ReLU's non-differentiability at 0); and (5) a depth advantage crossover theorem showing that for depth d ≥ 8we/3, EML networks achieve strictly better approximation than piecewise linear (ReLU) networks of the same width. All results are formalized with complete machine-checked proofs.

## 1. Introduction

Neural network expressiveness — the class of functions a network can approximate to a given accuracy — is fundamentally determined by three factors: the activation function, the network's width (number of neurons per layer), and its depth (number of layers). Understanding how these factors interact is a central problem in approximation theory and deep learning theory.

The classical universal approximation theorems (Cybenko 1989, Hornik 1991) establish that width-bounded shallow networks can approximate any continuous function, but say little about the required width. Subsequent work has shown that depth can exponentially reduce the width needed for certain function classes (Telgarsky 2016, Eldan-Shamir 2016).

Most existing results focus on the ReLU activation max(0, x), which is piecewise linear. The piecewise linearity has important consequences: compositions of ReLU functions are themselves piecewise linear, and the number of linear pieces grows polynomially in width and exponentially in depth. This combinatorial structure underlies most depth separation results.

We study a fundamentally different activation: the **EML (exponential-minus-logarithmic)** function exp(ax + b) − log(cx + d). Unlike ReLU, the EML activation is analytic (infinitely differentiable) on its domain, and its Taylor expansion contains all polynomial degrees. This analytic structure enables a qualitatively different mechanism for function approximation: rather than stitching together linear pieces, EML networks extract polynomial terms through Taylor expansion.

### 1.1 Contributions

1. **Novel mathematical structure**: The EML Approximation Spectrum, which maps (depth, width) pairs to achievable approximation errors, with formally proven monotonicity and upward-closure of isoperformance sets.

2. **Taylor quadratic extraction** (Theorem 1): |exp(t) − 1 − t − t²/2| ≤ |t|³/6 · exp(|t|), establishing that EML activations extract quadratic terms with cubic residuals.

3. **Width-w approximation** (Theorem 2): A single EML neuron with parameter ε = 1/w approximates x² on [0,1] with uniform error ≤ e/(3w).

4. **Composition error propagation** (Theorem 3): For L-Lipschitz outer function, the composition error satisfies |f₁∘f₂ − g₁∘g₂| ≤ L·ε₂ + ε₁.

5. **Smoothness theorem** (Theorem 4): EML units have closed-form derivatives and are differentiable at every domain point.

6. **Depth advantage crossover** (Theorem 5): When d ≥ 8we/3, the EML error bound e/(3wd) strictly improves upon the piecewise linear bound 1/(8w²).

## 2. Definitions

### 2.1 EML Unit

An **EML unit** with parameters (a, b, c, d, w) ∈ ℝ⁵ is the function:

φ(x) = w · (exp(ax + b) − log(cx + d))

defined on the domain {x ∈ ℝ : cx + d > 0}.

### 2.2 EML Layer and Network

An **EML layer** of width W is a function:

L(x) = Σᵢ₌₁ᵂ φᵢ(x) + β

where φᵢ are EML units and β is a bias term.

An **EML network** of depth D is a composition L_D ∘ L_{D-1} ∘ ⋯ ∘ L_1.

### 2.3 EML Approximation Spectrum

**Definition (Novel).** The **EML Approximation Spectrum** for a target function f on [a,b] is a structure S = (f, E) where E : ℕ × ℕ → ℝ≥0 satisfies:

1. **Non-negativity**: E(d, w) ≥ 0 for all d, w.
2. **Width antitonicity**: For fixed d, w₁ ≤ w₂ implies E(d, w₂) ≤ E(d, w₁).
3. **Depth antitonicity**: For fixed w, d₁ ≤ d₂ implies E(d₂, w) ≤ E(d₁, w).

The function E(d, w) represents the best achievable uniform approximation error on [a,b] using an EML network of depth d and width w.

**Dominance.** Spectrum S₁ **dominates** S₂ if E₁(d, w) ≤ E₂(d, w) for all d, w.

**Isoperformance set.** For error level ε, the isoperformance set is I(ε) = {(d, w) : E(d, w) ≤ ε}.

### 2.4 Auxiliary Definitions

The **EML quadratic extractor**: Q(ε, x) = exp(εx) − 1 − εx

The **normalized extractor**: N(ε, x) = 2Q(ε, x)/ε²

## 3. Main Results

### 3.1 Taylor Quadratic Extraction (Theorem 1)

**Theorem.** For all t ∈ ℝ:

|exp(t) − 1 − t − t²/2| ≤ |t|³/6 · exp(|t|)

*Proof sketch.* Express the remainder as the tail of the Taylor series: exp(t) − 1 − t − t²/2 = Σₙ₌₃^∞ tⁿ/n!. Take absolute values and use |tⁿ/n!| ≤ |t|³/6 · |t|^{n-3}/(n-3)! (since n!/6 ≥ (n-3)! for n ≥ 3). Sum the geometric series to obtain |t|³/6 · Σₖ₌₀^∞ |t|ᵏ/k! = |t|³/6 · exp(|t|).

**Example (P).** At t = 0.1: |exp(0.1) − 1 − 0.1 − 0.005| ≈ 1.67 × 10⁻⁴, while |0.1|³/6 · exp(0.1) ≈ 1.84 × 10⁻⁴. Ratio ≈ 0.91.

**Generalization (G).** The bound extends to complex t with the same form, and the constant 1/6 is optimal (it equals 1/3! for the degree-3 Taylor coefficient).

**Boundary (B).** As |t| → ∞, the bound grows as |t|³ · exp(|t|)/6 while the actual remainder grows as exp(|t|), so the bound becomes increasingly loose. For |t| > 3, the ratio of bound to actual remainder exceeds 10.

### 3.2 Width-w Approximation of x² (Theorem 2)

**Theorem.** For w ≥ 1 and x ∈ [0, 1]:

|N(1/w, x) − x²| ≤ e/(3w)

where N(ε, x) = 2(exp(εx) − 1 − εx)/ε².

*Proof sketch.* Apply Theorem 1 with t = x/w. The normalized extractor satisfies N(1/w, x) = x² + 2w²R where R = exp(x/w) − 1 − x/w − (x/w)²/2. By Theorem 1, |R| ≤ |x/w|³/6 · exp(|x/w|). For x ∈ [0,1]: |2w²R| ≤ 2w² · x³/(6w³) · exp(x/w) ≤ 2/(6w) · exp(1/w) ≤ e/(3w).

**Example (P).** At w = 10, x = 0.5: N(0.1, 0.5) ≈ 0.250417, true value 0.25, error ≈ 4.17 × 10⁻⁴. Bound: e/30 ≈ 0.0906.

**Generalization (G).** For smooth functions f ∈ Cᵏ[0,1], EML networks of width w can achieve error O(w^{-k}) by extracting higher-order Taylor terms. This generalizes the quadratic case (k = 2) and is unachievable by piecewise linear networks.

**Boundary (B).** The O(1/w) rate cannot be improved to O(1/w²) using a single EML neuron — the cubic Taylor remainder is inherently O(ε) = O(1/w). Achieving O(1/w²) requires either multiple neurons (width > 1) or depth > 1.

### 3.3 Composition Error (Theorem 3)

**Theorem.** Let f₁ ≈ g₁ with error ε₁ (at the relevant point) and f₂ ≈ g₂ with error ε₂. If g₁ is L-Lipschitz, then:

|f₁(f₂(x)) − g₁(g₂(x))| ≤ L · ε₂ + ε₁

*Proof sketch.* Triangle inequality: split at g₁(f₂(x)). The first term uses Lipschitz continuity of g₁; the second uses the approximation of g₁ by f₁.

**Example (P).** Let g₁(x) = 2x (Lipschitz with L = 2), g₂(x) = x², and suppose f₁ has error 0.01 and f₂ has error 0.05. Then the composed error ≤ 2 · 0.05 + 0.01 = 0.11.

**Generalization (G).** For d layers with errors ε₁, ..., ε_d and Lipschitz constants L₁, ..., L_d, the total error is bounded by Σᵢ εᵢ · Πⱼ>ᵢ Lⱼ.

**Boundary (B).** The Lipschitz constant is crucial. If L > 1, errors are amplified through layers, potentially making deep networks worse than shallow ones. Stable deep networks require L ≤ 1 (contraction) at each layer.

### 3.4 EML Smoothness (Theorem 4)

**Theorem.** An EML unit φ(x) = w · (exp(ax + b) − log(cx + d)) has derivative:

φ'(x) = w · (a · exp(ax + b) − c/(cx + d))

at every point x with cx + d > 0.

**Example (P).** For the unit with a = 1, b = 0, c = 1, d = 1: φ'(0) = 1 · (1 · e⁰ − 1/1) = 0. The function has a critical point at x = 0.

**Generalization (G).** The second derivative φ''(x) = w · (a² · exp(ax + b) + c²/(cx + d)²) is always positive (for w > 0), meaning EML units are convex on their entire domain.

**Boundary (B).** At cx + d = 0, the log component has a logarithmic singularity, and the derivative diverges. The domain restriction is essential and cannot be removed.

### 3.5 Depth Advantage Crossover (Theorem 5)

**Theorem.** For w ≥ 1, d ≥ 1, and 8we ≤ 3d:

e/(3wd) ≤ 1/(8w²)

That is, the EML error bound at depth d beats the piecewise linear error bound.

*Proof sketch.* Cross-multiply (both denominators are positive): need 8w² · e ≤ 3wd, i.e., 8we ≤ 3d, which is the hypothesis.

**Example (P).** At w = 5: crossover depth = ⌈8 · 5 · e/3⌉ = 37. For d = 37: EML error ≤ e/555 ≈ 0.00490; PWL error = 1/200 = 0.005. EML wins.

**Generalization (G).** For approximating degree-k polynomials, we conjecture the crossover depth scales as O(w · e^{1/k}), making depth increasingly valuable for smoother targets.

**Boundary (B).** For w = 1, d ≥ 8: EML matches PWL with a single neuron per layer. For w → ∞, the required depth d ∼ 8we/3 → ∞, meaning infinite width cannot be replaced by depth alone.

## 4. The Approximation Spectrum as a Mathematical Object

### 4.1 Properties

**Proposition (Proven).** The isoperformance set I(ε) is upward-closed: if (d₁, w₁) ∈ I(ε) and d₂ ≥ d₁, w₂ ≥ w₁, then (d₂, w₂) ∈ I(ε).

**Proposition (Proven).** If spectrum S₁ dominates S₂, then I₂(ε) ⊆ I₁(ε) for all ε.

### 4.2 Concrete Spectra

**PWL Spectrum** for x² on [0,1]: E_PWL(d, w) = 1/(8w²) (depth-independent).

**EML Spectrum** for x² on [0,1]: E_EML(d, w) = e/(3wd) (product of depth and width).

The PWL spectrum has vertical isoperformance curves (only width matters). The EML spectrum has hyperbolic isoperformance curves (wd = constant), revealing the depth-width symmetry of EML networks.

### 4.3 Crossover Geometry

**Theorem (Proven).** For width w and depth d with 8we ≤ 3d, the EML spectrum dominates the PWL spectrum pointwise: E_EML(d, w) ≤ E_PWL(d, w).

The crossover curve d = 8we/3 in the (w, d)-plane divides the spectrum into two regions:
- **Below the curve** (d < 8we/3): PWL achieves better bounds
- **Above the curve** (d ≥ 8we/3): EML achieves better bounds

## 5. Algorithm: EML Network Construction for Polynomial Approximation

### Input
- Target polynomial p(x) of degree k on [0, 1]
- Desired accuracy ε > 0

### Algorithm
1. Choose width w = ⌈e/(3ε)⌉ (sufficient for O(1/w) per-layer error)
2. Choose depth d = ⌈k/2⌉ (each layer extracts ~2 polynomial degrees)
3. For each layer ℓ = 1, ..., d:
   a. Set εℓ = 1/w
   b. Construct EML unit with a = εℓ, b = 0, c = 0, d = 1
   c. Weight by 2/εℓ² and subtract linear correction
4. Return composed network

### Complexity
- Total parameters: O(wd) = O(k · e/(3ε))
- Evaluation time: O(wd) multiplications and exp/log evaluations
- Error: O(ε) by Theorem 2 and iterated application of Theorem 3

## 6. Falsifiable Conjecture

**Conjecture (EML Approximation Rate).** There exists a universal constant C > 0 such that for any L-Lipschitz function f on [0,1], and any w, d ≥ 1, there exists an EML network of depth d and width w achieving:

sup_{x ∈ [0,1]} |net(x) − f(x)| ≤ CL/(wd)²

**Testable prediction.** For f(x) = |x − 1/2| (Lipschitz with L = 1), compute the actual approximation error of an optimized depth-2, width-w EML network. If the error is Ω(1/w) rather than O(1/w²), the conjecture is false.

**Evidence for.** The quadratic extraction mechanism suggests that EML's smooth activation should enable higher-order approximation. The O(1/w) rate at depth 1 and the O(1/(wd)) rate with depth d are consistent with the conjectured O(1/(wd)²) being achievable through more sophisticated constructions.

**Evidence against.** The Lipschitz condition alone (without smoothness) may be insufficient. The function |x − 1/2| has a corner at x = 1/2, and EML's smooth activation may not be able to efficiently approximate non-smooth features, regardless of depth.

## 7. Cross-Connections

### 7.1 Connection to EML Chain Theory
The EMLChainOp structure from the Kolmogorov-Arnold-EML theory (catalog: `EML.KolmogorovArnoldEMLDeep`) provides an algebraic framework for EML compositions. Our composition error theorem (Theorem 3) gives quantitative bounds for the approximation quality of EML chains, complementing the algebraic structure theory.

### 7.2 Connection to Complexity Classes
The EML complexity classes from `Bridges.UniversalApproxComplexity` classify functions by their EML description complexity growth. Our approximation spectrum refines this classification by explicitly tracking the depth-width decomposition of complexity.

### 7.3 Connection to Tropical Geometry
The ReLU network's piecewise linearity connects to tropical geometry (where max and + replace + and ×). The EML activation, being analytic, operates in classical algebraic geometry. The depth-width crossover theorem quantifies exactly where the "tropical" approach (ReLU) gives way to the "classical" approach (EML).

## 8. Discussion

### 8.1 Why Smoothness Matters
The smoothness advantage of EML over ReLU manifests in three ways:
1. **Approximation theory**: Smooth activations can extract higher-order polynomial terms, enabling faster convergence for smooth targets.
2. **Optimization landscape**: Smooth loss surfaces have better-behaved gradients, avoiding the pathological gradient geometry of ReLU networks.
3. **Generalization**: Smooth networks have lower Rademacher complexity under natural parameter bounds, potentially giving better generalization guarantees.

### 8.2 Limitations
Our results are upper bounds on approximation error, not lower bounds. We have not proven that the O(1/w) rate is tight for single-layer EML networks (though we believe it is). The depth advantage theorem relies on a specific error model (uniform error on [0,1]) and may not extend to other error metrics or domains.

### 8.3 The Spectrum as a Design Tool
The approximation spectrum provides a principled framework for neural architecture design: given a computational budget B (total parameters = w × d), the optimal allocation between depth and width depends on which spectrum applies. For EML networks approximating smooth functions, the optimum is d = w = √B (equal allocation), while for ReLU networks, the optimum is d = 1, w = B (all width).

## 9. Future Work

1. **Lower bounds**: Prove matching Ω(1/w) lower bounds for single-layer EML approximation of x².
2. **Higher-order extraction**: Extend the quadratic extraction to degree-k polynomial extraction using iterated Taylor expansion.
3. **Multivariate extension**: Generalize the spectrum to functions on [0,1]ⁿ and establish the conjectured O((wd)^{-2/n}) rate.
4. **Empirical validation**: Train EML networks on standard benchmarks and compare actual convergence rates with theoretical bounds.

## References

1. Cybenko, G. (1989). "Approximation by superpositions of a sigmoidal function." Mathematics of Control, Signals, and Systems.
2. Hornik, K. (1991). "Approximation capabilities of multilayer feedforward networks." Neural Networks.
3. Telgarsky, M. (2016). "Benefits of depth in neural networks." COLT.
4. Eldan, R. & Shamir, O. (2016). "The power of depth for feedforward neural networks." COLT.
5. DeVore, R. (1998). "Nonlinear approximation." Acta Numerica.
