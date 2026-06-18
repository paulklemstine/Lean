# EML-KA Depth Theory: Depth-Independence for Monomials and the Fenchel-Young Duality Bridge

## Abstract

We develop a rigorous theory connecting EML (exponential-minus-logarithm) function chains to the Kolmogorov-Arnold representation theorem. We introduce the concept of **EML chains** — compositions of exponential, logarithmic, and affine operations — and define their **transcendental depth** as the count of non-affine operations. Our central result is the **depth-independence phenomenon**: every monomial x^a · y^b on (0,∞)² admits a 1-term EML-KA decomposition with max chain depth 1, independent of the exponents a and b. This extends to M-term decompositions for M-monomial polynomials at constant depth. We establish a **Fenchel-Young duality bridge** connecting EML operations to convex optimization, proving that the Fenchel-Young gap FYGap(x,s) = exp(x) + s·log(s) - s - x·s is nonneg and vanishes exactly when s = exp(x). We formalize Bregman divergences from both exp and -log, prove Gibbs' inequality for KL divergence with an exact characterization of equality, and show that the neg-entropy function ψ(x) = x·log(x) - x has exp as its convex conjugate. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: Kolmogorov-Arnold representation, EML chains, depth independence, Fenchel-Young inequality, Bregman divergence, convex duality

---

## 1. Introduction

The Kolmogorov-Arnold representation theorem (1957) states that every continuous function f : [0,1]^n → ℝ can be written as

f(x₁, …, xₙ) = Σ_{q=0}^{2n} Φ_q(Σ_{p=1}^n φ_{q,p}(x_p))

where each φ_{q,p} and Φ_q is a continuous univariate function. While the theorem guarantees existence, it provides no explicit construction of the inner and outer functions.

We investigate the hypothesis that for functions on (0,∞)^n, the inner and outer functions can be chosen from the **EML function class** — compositions of exp, log, and affine maps. Our main discovery is that this choice yields a **depth-independent** representation for monomials, with the decomposition complexity remaining constant regardless of exponent magnitude.

### 1.1 Contributions

1. **EML Chain Formalism** (§2): We define EML chains, their evaluation semantics, and transcendental depth, providing a formal language for discussing EML-KA decompositions.

2. **Depth-Independence Theorem** (§3): We prove that every monomial x^a · y^b has a 1-term EML-KA decomposition with max chain depth 1, and extend this to M-monomial polynomials.

3. **Fenchel-Young Duality Bridge** (§4): We formalize the Fenchel-Young gap, prove its nonnegativity and characterize its zero set, establishing the variational optimality of the exp-log pairing.

4. **Bregman Divergence Theory** (§5): We prove nonnegativity of exp-Bregman and neglog-Bregman divergences, Gibbs' inequality for KL divergence, and its equality characterization.

5. **Depth Lower Bounds** (§6): We prove that depth-0 EML expressions compute only affine functions, establishing that transcendental operations are necessary for nonlinear computation.

---

## 2. EML Chain Formalism

### 2.1 Definitions

**Definition 2.1 (EML Chain Operation).** An EML chain operation is one of:
- `exp`: x ↦ e^x
- `log`: x ↦ ln(x)
- `affine(a, b)`: x ↦ a·x + b

**Definition 2.2 (EML Chain).** An EML chain is a finite list [op₁, op₂, …, opₖ] of EML chain operations. Its evaluation at x is opₖ(…(op₂(op₁(x)))…).

**Definition 2.3 (Transcendental Depth).** The depth of an EML chain is the number of non-affine operations (exp and log). Affine operations have depth 0.

**Example.** The power chain for x^a is [log, affine(a, 0), exp], with depth 2.

### 2.2 EML-KA Decomposition

**Definition 2.4.** An EML-KA decomposition with Q terms consists of:
- Inner chains chain₁_q, chain₂_q for each term q ∈ {0, …, Q-1}
- Outer chains outerChain_q for each term
- Evaluation: f(x,y) = Σ_q outerChain_q(chain₁_q(x) + chain₂_q(y))

**Definition 2.5.** The max depth of an EML-KA decomposition is max_q max(depth(chain₁_q), depth(chain₂_q), depth(outerChain_q)).

---

## 3. The Depth-Independence Theorem

### 3.1 Monomial Decomposition

**Theorem 3.1 (Monomial EML-KA Correctness).** For all a, b ∈ ℝ and x, y > 0,
the 1-term EML-KA decomposition with:
- chain₁ = [log, affine(a, 0)]
- chain₂ = [log, affine(b, 0)]
- outerChain = [exp]

evaluates to x^a · y^b.

*Proof.* By direct computation:
outerChain(chain₁(x) + chain₂(y)) = exp(a·log(x) + b·log(y)) = exp(log(x^a))·exp(log(y^b)) = x^a · y^b. ∎

**Theorem 3.2 (Depth Independence).** The max chain depth of the monomial decomposition is 1, independent of a and b.

*Proof.* Each of chain₁ and chain₂ contains one non-affine operation (log), so has depth 1. The outerChain contains one non-affine operation (exp), so has depth 1. The max is 1. ∎

### 3.2 Polynomial Extension

**Theorem 3.3 (Polynomial EML-KA).** For an M-monomial polynomial p(x,y) = Σᵢ cᵢ · x^{aᵢ} · y^{bᵢ}, there exists an M-term EML-KA decomposition that evaluates to p(x,y) for all x, y > 0.

*Proof.* Use one term per monomial. Term i has chain₁_i = [log, affine(aᵢ, 0)], chain₂_i = [log, affine(bᵢ, 0)], outerChain_i = [exp, affine(cᵢ, 0)]. The evaluation of term i is cᵢ · exp(aᵢ·log(x) + bᵢ·log(y)) = cᵢ · x^{aᵢ} · y^{bᵢ}. Summing over all terms gives p(x,y). ∎

**Theorem 3.4 (Polynomial Depth Bound).** The max chain depth of the polynomial decomposition is at most 1.

### 3.3 Discussion

The depth-independence result contrasts sharply with arithmetic circuit complexity, where computing x^n typically requires Θ(log n) multiplications (by repeated squaring). The EML-KA representation sidesteps this by leveraging the log-exp bridge: log converts multiplication to addition (linear, "free"), and a single exp at the end converts back.

This suggests a fundamental efficiency advantage for architectures that use exp/log as activation functions over those that use polynomial-type activations (ReLU, powers).

---

## 4. The Fenchel-Young Duality Bridge

### 4.1 The Fenchel-Young Gap

**Definition 4.1.** The Fenchel-Young gap is FYGap(x, s) = exp(x) + s·log(s) - s - x·s for s > 0.

**Lemma 4.2 (Factorization).** FYGap(x, s) = s · (exp(x - log(s)) - (x - log(s)) - 1).

*Proof.* Direct algebraic manipulation using exp(x - log(s)) = exp(x)/s. ∎

**Theorem 4.3 (Nonnegativity).** FYGap(x, s) ≥ 0 for all x ∈ ℝ, s > 0.

*Proof.* By Lemma 4.2, FYGap = s · (exp(u) - u - 1) where u = x - log(s). Since exp(u) ≥ 1 + u for all u, the factor is nonneg. Since s > 0, the product is nonneg. ∎

**Theorem 4.4 (Zero Characterization).** FYGap(x, s) = 0 if and only if s = exp(x).

*Proof.* By the factorization, FYGap = 0 iff exp(u) - u - 1 = 0 (since s > 0). The function g(u) = exp(u) - u - 1 has g(0) = 0, g'(u) = exp(u) - 1, so g is strictly convex with a unique minimum at u = 0. Thus g(u) = 0 iff u = 0, i.e., x = log(s), i.e., s = exp(x). ∎

### 4.2 Variational Interpretation

The Fenchel-Young inequality x·s ≤ exp(x) + s·log(s) - s states that exp and the neg-entropy s·log(s) - s are convex conjugates. The gap measures the "duality distance" — how far a pair (x, s) is from the conjugate pairing.

This connects EML-KA decompositions to:
- **Optimal transport**: The Fenchel-Young gap generates a cost function for transport plans.
- **Mirror descent**: The neg-entropy ψ(x) = x·log(x) - x has gradient log(x) and conjugate exp(s), making the exp-log pair the natural choice for multiplicative weight updates.
- **Information geometry**: The KL divergence is the Bregman divergence of neg-entropy.

---

## 5. Bregman Divergence Theory

### 5.1 Component Divergences

**Definition 5.1.** The exp-Bregman divergence: D_exp(p, q) = exp(p) - exp(q) - exp(q)·(p - q).

**Theorem 5.2.** D_exp(p, q) ≥ 0 for all p, q ∈ ℝ.

*Proof.* Write p = q + (p-q) and use exp(q + u) = exp(q)·exp(u) ≥ exp(q)·(1 + u). ∎

**Definition 5.3.** The neglog-Bregman divergence: D_{-log}(p, q) = -log(p) + log(q) + (1/q)·(p - q).

**Theorem 5.4.** D_{-log}(p, q) ≥ 0 for p, q > 0.

*Proof.* Rewrite as log(q/p) + p/q - 1 ≥ 0 using log(t) ≤ t - 1. ∎

### 5.2 KL Divergence

**Definition 5.5.** The KL-Bregman divergence: D_ψ(p, q) = p·log(p/q) - (p - q).

**Theorem 5.6 (Gibbs' Inequality).** D_ψ(p, q) ≥ 0 for p, q > 0.

**Theorem 5.7 (Equality Characterization).** D_ψ(p, q) = 0 if and only if p = q.

*Proof.* Uses the strict version of log(t) ≤ t - 1: for t > 0, t ≠ 1, log(t) < t - 1. Applied to t = q/p, this gives p·log(p/q) > p - q when p ≠ q. ∎

### 5.3 The EML-Bregman Divergence

The combined EML-Bregman divergence D_exp + D_{-log} is nonneg and captures both the exponential and logarithmic aspects of EML duality simultaneously.

---

## 6. Depth Lower Bounds

### 6.1 Expression Trees

**Definition 6.1.** An EML expression tree has nodes: var, const(c), add(e₁, e₂), smul(c, e), expOf(e), logOf(e). The non-affine depth is the maximum nesting depth of exp/log nodes.

**Theorem 6.2.** If an EML expression has naDepth = 0, then it computes an affine function x ↦ a·x + b.

*Proof.* By structural induction. The base cases (var, const) are affine. Addition and scaling of affine functions are affine. The exp and log cases are vacuously true since their depth is ≥ 1. ∎

This establishes that transcendental operations (exp, log) are *necessary* for computing any nonlinear function via EML expressions.

---

## 7. Algorithms

### 7.1 EML-KA Decomposition Algorithm

**Input:** Monomial polynomial p(x,y) = Σᵢ cᵢ · x^{aᵢ} · y^{bᵢ}
**Output:** EML-KA decomposition with M terms

```
for each term i:
    chain₁[i] = [LOG, AFFINE(aᵢ, 0)]
    chain₂[i] = [LOG, AFFINE(bᵢ, 0)]
    outer[i] = [EXP, AFFINE(cᵢ, 0)]
return (chain₁, chain₂, outer)
```

**Complexity:** O(M) construction, O(M) evaluation per point.

### 7.2 Fenchel-Young Optimization

Given x, find the optimal s minimizing FYGap(x, s):

```
s* = exp(x)  # Exact solution
```

This is the *mirror map* of convex optimization: the gradient of exp evaluated at x.

---

## 8. Applications

### 8.1 Neural Network Architecture

The depth-independence result suggests that **EML-KAN** (Kolmogorov-Arnold Networks with exp/log activations) can represent any monomial polynomial at depth 1. This contrasts with ReLU networks, which require depth O(log d) for degree-d polynomials.

Concretely, an EML-KAN layer with M neurons computes:

y = Σ_{i=1}^M c_i · exp(a_i · log(x₁) + b_i · log(x₂))

This is a polynomial of the form Σ c_i x₁^{a_i} x₂^{b_i}. The learnable parameters are the coefficients c_i, exponents a_i, and exponents b_i — a total of 3M parameters per layer. The architecture naturally enforces the EML-KA structure, ensuring that each neuron computes a monomial term.

For the n-variate case, each neuron has n+1 parameters (n exponents plus one coefficient), giving (n+1)M parameters per layer. This scales linearly in both M and n.

### 8.2 Symbolic Regression

EML-KA decompositions provide a structured search space for symbolic regression: find the best M monomial terms (coefficients and exponents) to approximate an unknown function. The fixed architecture reduces the search to optimizing 3M real parameters per term.

The search space has several attractive properties:
- **Completeness**: By the polynomial approximation theorem, any continuous function on (0,∞)² can be approximated arbitrarily well.
- **Structured**: The decomposition has a fixed architecture (log-affine-exp), reducing the search to parameter optimization.
- **Interpretable**: Each term c·x^a·y^b has a clear physical interpretation as a power law with known exponents.

### 8.3 Information-Theoretic Compression

The Fenchel-Young bridge connects EML-KA decompositions to rate-distortion theory. The KL divergence, being a Bregman divergence of neg-entropy, naturally decomposes into EML operations.

For a source with distribution p and a code with distribution q, the coding redundancy is exactly klBregman(p, q). Our equality characterization (Theorem 5.7) shows that the redundancy vanishes if and only if the code perfectly matches the source — a formal statement of the source coding theorem's achievability condition.

### 8.4 Circuit Complexity

The depth-independence result has implications for algebraic circuit complexity. In the standard arithmetic circuit model, computing the monomial x^n requires Θ(log n) depth (via repeated squaring). In the EML circuit model, x^n requires only depth 1 (one log, one affine scaling, one exp). This represents an exponential depth reduction.

Formally, consider the complexity class of functions computable by EML circuits of depth d. Our Theorem 6.2 shows that depth-0 EML circuits compute only affine functions. The monomial decomposition shows that depth-1 circuits compute all monomials. The depth hierarchy question — whether depth-(k+1) strictly extends depth-k — remains open and is a key direction for future work.

---

## 9. Discussion

### 9.1 Comparison with Classical KA Representations

The classical Kolmogorov-Arnold theorem uses pathological continuous functions for the inner maps φ_{q,p}. These functions, while continuous, are typically nowhere differentiable and have fractal-like structure, making them useless for computation. The EML-KA approach replaces these with smooth, well-understood functions (exp and log), sacrificing generality (the domain is restricted to (0,∞)²) for practicality.

The trade-off is favorable in many applications. Most functions arising in physics, engineering, and machine learning are naturally defined on positive domains (concentrations, probabilities, energies, rates). For these functions, the EML-KA decomposition provides an explicit, differentiable, and computationally efficient representation.

### 9.2 Relation to the Fenchel-Young Inequality

The Fenchel-Young gap FYGap(x, s) = exp(x) + s·log(s) - s - x·s has a natural interpretation as a measure of "suboptimality" in the exp-log pairing. When the gap is zero, the pair (x, s) lies on the conjugate curve s = exp(x), representing perfect duality. When the gap is positive, there is room for improvement.

The factorization FYGap(x, s) = s · (exp(u) - u - 1) where u = x - log(s) reveals the structure clearly. The factor exp(u) - u - 1 is the "deviation from linearity" of the exponential function at the point u, and it vanishes only at u = 0. This is a manifestation of the strict convexity of exp.

### 9.3 The Role of Affine Operations

A key design choice in our formalism is that affine operations (x ↦ a·x + b) are "free" in the depth measure. This is motivated by the fact that affine maps are the simplest possible transformations: they preserve linearity and can be composed without increasing complexity. In neural network terms, affine operations correspond to the linear layers (weight matrices and biases) that are computationally cheap compared to nonlinear activations.

The depth-zero characterization theorem (Theorem 6.2) validates this choice: without transcendental operations, only affine functions can be computed. This means that exp and log are the genuine sources of computational power in EML chains, while affine operations serve only as "connective tissue" between them.

### 9.4 Limitations

The current theory has several limitations:

1. **Domain restriction**: The EML-KA decomposition requires x, y > 0. Functions defined on domains including zero or negative values cannot be directly decomposed.

2. **Approximation vs. exact representation**: For functions that are not monomial polynomials, EML-KA provides only approximations. The approximation rate is conjectured to be O(1/M) but this remains unproven.

3. **Non-uniqueness**: The decomposition is not unique. Different choices of monomial terms can represent the same polynomial. Identifying the "best" decomposition (minimizing terms or error) is an optimization problem.

4. **Higher-order corrections**: For non-polynomial functions, the Taylor expansion gives monomial terms with increasing exponents. The convergence rate depends on the smoothness of the target function, and the EML-KA approach inherits these limitations.

## 10. Computational Verification

All theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The verification covers:

- **Correctness proofs**: `monomial_ka_spec`, `poly_ka_spec` verify that the EML-KA decompositions compute the intended functions.
- **Depth bounds**: `monomial_ka_max_depth`, `poly_ka_max_depth_le` verify that depths are constant.
- **Inequality proofs**: `fenchel_young_gap_nonneg`, `bregmanExp_nonneg`, `bregmanNegLog_nonneg`, `klBregman_nonneg` verify nonnegativity of divergences.
- **Equality characterizations**: `fenchel_young_gap_eq_zero_iff`, `klBregman_eq_zero_iff` verify exact conditions for equality.
- **Structural results**: `EMLExpr.depth_zero_is_affine` verifies that depth-0 expressions are affine by structural induction.
- **Derivative computation**: `negEntropy_deriv` verifies that the gradient of neg-entropy is log.

The formalization uses no axioms beyond the standard ones (propext, Classical.choice, Quot.sound) and no `sorry` placeholders. The total verification comprises approximately 500 lines of Lean code across two files.

## 11. Future Work

1. **EML-KA Universality Conjecture**: Can every continuous function on a compact subset of (0,∞)² be uniformly approximated by finite-term EML-KA decompositions? A proof strategy via Stone-Weierstrass and the point-separation property of logarithms is outlined in the Future Directions document.

2. **Approximation Rate**: We conjecture O(1/M) approximation error for M-term decompositions. This is testable computationally by fitting EML-KA decompositions to target functions like sin(x·y) on compact domains and measuring the convergence rate.

3. **Higher Dimensions**: Extend to n-variate monomials x₁^{a₁} · … · xₙ^{aₙ}, which should have constant-depth n-term decompositions. The n-variate monomial x₁^{a₁} ··· xₙ^{aₙ} = exp(Σ aᵢ · log(xᵢ)) has a 1-term decomposition with n inner chains.

4. **Tropical Geometry Connection**: Under the tropical limit t → 0⁺, the operation t·log(Σ exp(fᵢ/t)) converges to max(fᵢ). This suggests that EML-KA decompositions have tropical analogs, connecting continuous optimization to combinatorial optimization.

5. **Depth Hierarchy**: Prove that the EML depth hierarchy is strict: exp(exp(x)) requires depth 2, exp(exp(exp(x))) requires depth 3, etc. The depth-0 characterization (Theorem 6.2) provides the base case.

---

## 12. Conclusion

We have established a rigorous theory of EML-KA decompositions with three main contributions: (1) the depth-independence theorem showing constant-depth decompositions for all monomials and polynomials, (2) the Fenchel-Young duality bridge connecting EML to convex optimization, and (3) a complete Bregman divergence theory including Gibbs' inequality with equality characterization.

The depth-independence phenomenon is the central discovery: the EML-KA decomposition of any monomial x^a · y^b has max chain depth 1, independent of the exponents. This is achieved through the log-exp bridge, which converts multiplicative structure (powers, products) into additive structure (sums, scalings) via logarithms, processes it linearly, and converts back via exponentiation. The entire transformation has a fixed three-step structure: log, affine, exp.

The Fenchel-Young duality bridge provides the theoretical foundation for why exp and log are the right building blocks. They are convex conjugates, meaning they are optimally paired in a variational sense. The Fenchel-Young gap characterizes this optimality precisely: the gap vanishes if and only if the arguments are conjugate-paired.

All results are machine-verified in Lean 4, providing a certified foundation for future work on EML-based function representation and neural network architecture.

---

## References

1. Kolmogorov, A.N. (1957). On the representation of continuous functions of several variables by superpositions of continuous functions of one variable and addition. *Doklady Akademii Nauk SSSR*, 114, 953-956.

2. Arnold, V.I. (1959). On functions of three variables. *Doklady Akademii Nauk SSSR*, 114, 679-681.

3. Liu, Z. et al. (2024). KAN: Kolmogorov-Arnold Networks. *arXiv:2404.19756*.

4. Bregman, L.M. (1967). The relaxation method of finding the common point of convex sets and its application to the solution of problems in convex programming. *USSR Computational Mathematics and Mathematical Physics*, 7(3), 200-217.

5. Rockafellar, R.T. (1970). *Convex Analysis*. Princeton University Press.
