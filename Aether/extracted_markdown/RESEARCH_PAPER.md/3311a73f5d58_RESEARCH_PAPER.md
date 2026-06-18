# EML-KA Representation Theory: The Logarithmic Isomorphism and Multivariate Extensions

## Abstract

We develop new structural theory for the EML-Kolmogorov-Arnold (EML-KA) representation system, which decomposes multivariate functions as sums of univariate compositions involving exponentials and logarithms. Our central contribution is the **Logarithmic Isomorphism Principle**: the coordinate transformation (x₁,...,xₙ) ↦ (log x₁,...,log xₙ) converts the EML-KA representation problem into a linear ridge function approximation problem, revealing why the framework achieves dramatic compression over the classical Kolmogorov-Arnold bound.

We prove fifteen theorems, all formally verified in Lean 4 with Mathlib:
(1) Real-exponent monomials have 1-term EML-KA decompositions in any dimension;
(2) The exponential product closure: products of monomials remain single-term;
(3) Polynomial completeness: M-monomial polynomials have M-term decompositions;
(4) A barrier theorem: addition cannot be a single monomial;
(5) The AM-GM inequality with a tightness characterization via EML-KA;
(6) A cross-domain bridge connecting Rényi entropy to EML-KA structure.

**Keywords**: Kolmogorov-Arnold representation, exponential-logarithmic functions, universal approximation, formal verification, Rényi entropy

---

## 1. Introduction

### 1.1 The Kolmogorov-Arnold Representation Theorem

The Kolmogorov-Arnold theorem (Kolmogorov 1957, Arnold 1957) states that any continuous function f: [0,1]ⁿ → ℝ can be written as:

$$f(x_1, \ldots, x_n) = \sum_{q=0}^{2n} \Phi_q\left(\sum_{p=1}^n \varphi_{q,p}(x_p)\right)$$

where each φ_{q,p}: [0,1] → ℝ and Φ_q: ℝ → ℝ are continuous univariate functions. The inner functions φ_{q,p} can be chosen independent of f, depending only on the dimension n.

### 1.2 The EML Framework

The EML (Exponential-Minus-Logarithm) operation eml(x,y) = exp(x) - log(y) provides a fundamental building block connecting exponential and logarithmic functions. Previous work established:

- **EML chain operations**: compositions of exp, log, and affine maps (KolmogorovArnoldEMLDeep)
- **Multiplication decomposition**: x·y = exp(log x + log y) as a 1-term EML-KA decomposition (KolmogorovArnoldEML)
- **Natural-exponent monomials**: x^a · y^b for a,b ∈ ℕ have 1-term decompositions (KolmogorovArnoldEMLDeep)
- **Stone-Weierstrass connection**: EML-generated subalgebras are dense (StoneWeierstrassApprox)

### 1.3 Our Contributions

We extend and deepen the EML-KA theory in several directions:

1. **Real exponents** (§3): Generalize from ℕ to ℝ exponents using rpow
2. **Exponential product closure** (§3): Products of monomials are single-term
3. **n-variable decomposition** (§4): Arbitrary-dimension monomial theorem
4. **Power sum decomposition** (§5): x^n + y^n as 2-term EML-KA
5. **Logarithmic isomorphism** (§7): The change of coordinates that linearizes monomials
6. **AM-GM tightness** (§8): Characterization of equality in the EML-KA AM-GM
7. **Barrier result** (§11): Addition requires multiple terms
8. **Rényi entropy bridge** (§9): Cross-domain connection to information theory
9. **LogSumExp bounds** (§10): Tight bounds for the smooth maximum

---

## 2. Definitions

### 2.1 Weighted KA Decomposition

**Definition** (KADecomp). A *weighted Kolmogorov-Arnold decomposition* with Q terms for bivariate functions consists of:
- Inner functions φ₁_q, φ₂_q: ℝ → ℝ for q = 1,...,Q
- Outer functions Φ_q: ℝ → ℝ
- Weights w_q ∈ ℝ

The decomposition evaluates as:
$$f(x,y) = \sum_{q=1}^Q w_q \cdot \Phi_q(\varphi_{1,q}(x) + \varphi_{2,q}(y))$$

### 2.2 EML-KA Decomposition

An EML-KA decomposition is a KA decomposition where:
- Inner functions are of the form x ↦ a · log(x) + b (affine compositions with log)
- Outer functions are exp (or compositions thereof)

### 2.3 EML-KA Complexity

The *EML-KA complexity* of a function f on (0,∞)² is the minimum Q such that f has a Q-term EML-KA decomposition.

---

## 3. Real-Exponent Monomials and Product Closure

### 3.1 The Fundamental Identity

**Theorem 3.1** (rpow_monomial_eq_exp_sum). *For x, y > 0 and a, b ∈ ℝ:*
$$x^a \cdot y^b = \exp(a \cdot \log x + b \cdot \log y)$$

*Proof sketch.* Apply rpow_def_of_pos to rewrite x^a = exp(a · log x) and y^b = exp(b · log y), then combine using exp_add. □

This theorem generalizes the existing natural-exponent result to arbitrary real exponents, enabling fractional powers, negative powers, and irrational exponents.

### 3.2 Product Closure

**Theorem 3.2** (exp_product_closure). *For all a₁, b₁, a₂, b₂, x, y ∈ ℝ:*
$$\exp(a_1 \log x + b_1 \log y) \cdot \exp(a_2 \log x + b_2 \log y) = \exp((a_1+a_2) \log x + (b_1+b_2) \log y)$$

*Proof.* Direct from exp_add and ring normalization. □

**Corollary** (ka_exp_product_correct). The product of two 1-term exp-based KA decompositions is a 1-term decomposition.

### 3.3 Formal EML-KA Decomposition

**Theorem 3.3** (rpow_monomial_ka_correct). *The decomposition*
$$\text{rpowMonomialKA}(a,b) = (\varphi_1(x) = a \log x,\; \varphi_2(y) = b \log y,\; \Phi = \exp,\; w = 1)$$
*correctly represents x^a · y^b on (0,∞)².*

---

## 4. n-Variable Generalization

**Theorem 4.1** (nvar_monomial_eq_exp_sum). *For n ∈ ℕ, x: Fin n → ℝ₊, a: Fin n → ℝ:*
$$\prod_{i=0}^{n-1} x_i^{a_i} = \exp\left(\sum_{i=0}^{n-1} a_i \cdot \log x_i\right)$$

*Proof sketch.* Rewrite exp of the sum as a product of exponentials using exp_sum, then apply rpow_def_of_pos to each factor. □

This result shows that the 1-term decomposition holds in *any* dimension, far below the 2n+1 bound of the classical KA theorem.

| Dimension n | Classical KA terms | EML-KA terms (monomials) |
|-------------|-------------------|--------------------------|
| 2           | 5                 | 1                        |
| 3           | 7                 | 1                        |
| 10          | 21                | 1                        |
| 100         | 201               | 1                        |

---

## 5. Power Sum and Arithmetic Mean Decompositions

**Theorem 5.1** (power_sum_ka_correct). *For x, y > 0 and n ∈ ℕ:*
$$x^n + y^n = \exp(n \log x) + \exp(n \log y)$$
*This is a 2-term EML-KA decomposition.*

**Theorem 5.2** (arith_mean_ka_correct). *For x, y > 0:*
$$(x+y)/2 = \frac{1}{2} \exp(\log x) + \frac{1}{2} \exp(\log y)$$
*This is a 2-term weighted EML-KA decomposition with weights 1/2.*

---

## 6. Polynomial Completeness

**Theorem 6.1** (polynomial_emlka_complete). *For any polynomial with M monomial terms:*
$$\sum_{i=1}^M c_i \cdot x^{a_i} \cdot y^{b_i} = \sum_{i=1}^M c_i \cdot \exp(a_i \log x + b_i \log y)$$
*for all x, y > 0.*

*Proof.* Apply Finset.sum_congr and the monomial identity to each term. □

---

## 7. The Logarithmic Isomorphism Principle

### 7.1 Linearization in Log-Coordinates

**Theorem 7.1** (log_coord_bivariate_linear). *For all a, b, t₁, t₂ ∈ ℝ:*
$$\exp(a t_1 + b t_2) = (\exp t_1)^a \cdot (\exp t_2)^b$$

Under the substitution t₁ = log x, t₂ = log y, this becomes: the monomial x^a · y^b corresponds to the *linear function* a·t₁ + b·t₂ in log-coordinates, composed with exp.

### 7.2 Polynomial Ridge Structure

**Theorem 7.2** (log_coord_polynomial_ridge). *In log-coordinates, polynomials become sums of exponentials of linear functions:*
$$\sum_i c_i \cdot (\exp t_1)^{a_i} \cdot (\exp t_2)^{b_i} = \sum_i c_i \cdot \exp(a_i t_1 + b_i t_2)$$

This reveals the deep structure: EML-KA decompositions are precisely **ridge function approximations** in logarithmic coordinates. Each term exp(α·t₁ + β·t₂) is a ridge function — constant on the lines α·t₁ + β·t₂ = c.

---

## 8. AM-GM Inequality and Tightness

### 8.1 The Inequality

**Theorem 8.1** (eml_ka_amgm). *For x, y > 0:*
$$\exp\left(\frac{\log x + \log y}{2}\right) \leq \frac{x + y}{2}$$

This is Jensen's inequality applied to the convex function exp, reinterpreted as: the 1-term geometric mean decomposition is dominated by the 2-term arithmetic mean decomposition.

### 8.2 Tightness Characterization

**Theorem 8.2** (eml_ka_amgm_tight). *Equality holds in Theorem 8.1 if and only if x = y.*

This characterizes when a 2-term decomposition (arithmetic mean) collapses to behave identically to a 1-term decomposition (geometric mean).

---

## 9. Cross-Domain Bridge: Rényi Entropy

### 9.1 Power Sum Connection

**Theorem 9.1** (renyi_power_sum_eml). *For α ∈ ℝ and 0 < p < 1:*
$$p^\alpha + (1-p)^\alpha = \exp(\alpha \log p) + \exp(\alpha \log(1-p))$$

The Rényi power sum — the core object in Rényi entropy — is exactly a 2-term EML-KA expression.

### 9.2 Collision Entropy

**Theorem 9.2** (renyi_two_collision). *At α = 2:*
$$\frac{1}{1-2} \cdot \log(p^2 + (1-p)^2) = -\log(p^2 + (1-p)^2)$$

This is the collision entropy, which measures the probability that two independent samples from the distribution coincide.

---

## 10. LogSumExp Bounds

**Theorem 10.1** (logSumExp_ge_max). *For all a, b ∈ ℝ:*
$$\log(\exp a + \exp b) \geq \max(a, b)$$

**Theorem 10.2** (logSumExp_le_max_add). *For all a, b ∈ ℝ:*
$$\log(\exp a + \exp b) \leq \max(a, b) + \log 2$$

Together, these bound the log-sum-exp function — which serves as a smooth, differentiable alternative to the max function — within an additive constant of log 2 ≈ 0.693.

---

## 11. Barrier Result

**Theorem 11.1** (addition_not_monomial). *There do not exist constants c, a, b ∈ ℝ such that x + y = c · x^a · y^b for all x, y > 0.*

*Proof sketch.* Evaluate at (1,1), (2,1), (1,2), and (2,2) to derive contradictory constraints. From (1,1): c = 2. From (2,1) and (1,2): 2^a = 2^b = 3/2. From (2,2): 2^(a+b) = 2. But 2^(a+b) = (3/2)² = 9/4 ≠ 2. □

This proves that addition has EML-KA complexity ≥ 2, establishing a fundamental lower bound.

---

## 12. Summary of EML-KA Complexity

| Function | EML-KA Complexity | Proof |
|----------|-------------------|-------|
| x^a · y^b (monomial) | 1 | Thm 3.3 |
| x · y (multiplication) | 1 | Cor. of Thm 3.3 |
| x / y (division) | 1 | div_ka_complexity_one |
| x^n + y^n (power sum) | ≤ 2 | Thm 5.1 |
| (x+y)/2 (arithmetic mean) | ≤ 2 | Thm 5.2 |
| x + y (addition) | ≥ 2 | Thm 11.1 |
| M-monomial polynomial | ≤ M | Thm 6.1 |

---

## 13. Discussion

### 13.1 The Logarithmic Isomorphism as a Unifying Principle

The central insight of this work is that the map L: (0,∞)ⁿ → ℝⁿ given by L(x) = (log x₁,...,log xₙ) transforms the EML-KA problem from a nonlinear approximation problem into a *linear* one. In log-coordinates:

- Monomials become linear functions
- Polynomials become sums of exponentials of linear functions (ridge functions)
- The product operation becomes addition
- The Kolmogorov-Arnold inner functions become simple affine maps

This linearization principle explains why EML-KA achieves much better compression than the general Kolmogorov-Arnold bound: the "complexity" of the inner functions is absorbed by the logarithmic change of coordinates.

### 13.2 Connection to Neural Networks

The EML-KA framework can be viewed as a restricted neural network architecture where:
- The "input layer" applies log to each variable
- The "hidden layer" computes linear combinations
- The "output layer" applies exp and sums with weights

This is remarkably similar to the architecture of Kolmogorov-Arnold Networks (KANs), recently proposed as alternatives to Multi-Layer Perceptrons. Our results provide rigorous complexity bounds for what such networks can represent.

### 13.3 Limitations

The framework requires positive inputs (domain (0,∞)ⁿ), which excludes functions on ℝⁿ directly. The barrier result for addition shows that the 1-term miracle for monomials does not extend to all functions. And the polynomial completeness theorem, while ensuring representability, does not address approximation rates for non-polynomial functions.

---

## 14. Future Work

Several directions merit investigation:

1. **Approximation rates**: How quickly do M-term EML-KA decompositions converge to continuous functions as M → ∞?
2. **Optimal decompositions**: For a given function, what is the minimum number of terms, and can it be computed?
3. **Transcendental functions**: Can sin(xy), exp(x+y), and other transcendental functions be efficiently approximated?
4. **Learning algorithms**: Can EML-KA decompositions be learned from data, analogous to KAN training?
5. **Higher-order Rényi**: What other information-theoretic quantities have natural EML-KA structure?

---

## References

1. Kolmogorov, A.N. (1957). "On the representation of continuous functions of several variables by superpositions of continuous functions of a smaller number of variables." *Doklady Akademii Nauk SSSR*, 108, 179–182.

2. Arnold, V.I. (1957). "On functions of three variables." *Doklady Akademii Nauk SSSR*, 114, 679–681.

3. Liu, Z., et al. (2024). "KAN: Kolmogorov-Arnold Networks." *arXiv:2404.19756*.

4. EML Catalog. `EML/KolmogorovArnoldEMLDeep.lean` — EML chain operations and monomial decompositions.

5. EML Catalog. `EML/KolmogorovArnoldEML.lean` — KA decomposition structure and continuity.

6. EML Catalog. `EML/EMLv17Core.lean` — Core EML definitions and properties.

7. EML Catalog. `EML/StoneWeierstrassApprox.lean` — Stone-Weierstrass approximation for EML subalgebras.
