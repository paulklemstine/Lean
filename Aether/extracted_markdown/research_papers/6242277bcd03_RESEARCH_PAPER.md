# EML Spectral Filtration of the Kolmogorov-Arnold Algebra

## Abstract

We introduce the **EML Spectral Filtration**, a depth-indexed hierarchy of function classes arising from Kolmogorov-Arnold decompositions whose building-block functions are finite compositions of exponentials, logarithms, and affine maps. We prove that this filtration is strictly increasing (the depth-0 class is a proper subset of the depth-3 class), that the resulting algebra is closed under addition and scalar multiplication, that it contains all monomials x^a · y^b at depth 3, and that it separates points on the positive quadrant (0,∞)². We establish a rigorous lower bound showing multiplication x·y cannot be represented at depth 0, and connect the algebra to convex duality via the Fenchel-Young inequality. All main results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: Kolmogorov-Arnold representation, EML chains, spectral filtration, exp-log algebra, depth hierarchy, Stone-Weierstrass density

---

## 1. Introduction

The Kolmogorov-Arnold representation theorem (Kolmogorov 1957, Arnold 1957) states that every continuous function f : [0,1]^n → ℝ can be written as:

$$f(x_1, \ldots, x_n) = \sum_{q=0}^{2n} \Phi_q\left(\sum_{p=1}^n \varphi_{q,p}(x_p)\right)$$

where all φ_{q,p} and Φ_q are continuous univariate functions. The theorem is existential — it guarantees the decomposition exists but provides no constructive information about the inner and outer functions.

We investigate the following question: **Can the inner and outer functions in a KA decomposition be chosen from a structured, finitely describable class?** Specifically, we consider the class of **EML chains** — finite compositions of three elementary operations:
- **exp**: x ↦ e^x
- **log**: x ↦ ln(x)
- **affine**: x ↦ ax + b

### 1.1 Main Contributions

1. **Novel Mathematical Structure (EML Spectral Filtration)**: A depth-indexed hierarchy F₀ ⊆ F₁ ⊆ F₂ ⊆ ... of function classes, where F_d consists of functions representable by EML-KA decompositions of total transcendental depth ≤ d.

2. **Strict Hierarchy Theorem**: F₀ ⊊ F₃, witnessed by multiplication x·y which lies in F₃ but not F₀.

3. **Algebraic Closure**: The union ∪_d F_d is closed under addition and scalar multiplication.

4. **Monomial Completeness**: Every monomial x^a · y^b (a, b ∈ ℕ) lies in F₃.

5. **Polynomial Completeness**: Every polynomial on (0,∞)² is EML-KA representable.

6. **Point Separation**: Logarithmic inner functions separate points of (0,∞)².

7. **Convex Duality Connection**: The Fenchel-Young inequality provides a variational characterization of the exp-log pair underlying the filtration.

---

## 2. Definitions

### 2.1 EML Operations and Chains

**Definition 2.1 (EML Operation)**. An EML operation is one of:
- `exp`: the exponential function x ↦ e^x
- `log`: the natural logarithm x ↦ ln(x)  
- `affine(a, b)`: the affine function x ↦ ax + b

**Definition 2.2 (EML Chain)**. An EML chain is a finite list [op₁, op₂, ..., opₖ] of EML operations. Its evaluation at x is:

$$\text{eval}([op_1, \ldots, op_k], x) = op_1(op_2(\cdots op_k(x) \cdots))$$

**Definition 2.3 (Transcendental Depth)**. The transcendental depth of an EML chain is the number of exp and log operations it contains. Affine operations contribute 0 to the depth.

### 2.2 EML-KA Decomposition

**Definition 2.4 (EMLKA)**. An EML-KA decomposition with Q terms is a triple (φ₁, φ₂, Φ) where:
- φ₁ : Fin Q → List EMLOp (inner chains for x)
- φ₂ : Fin Q → List EMLOp (inner chains for y)  
- Φ : Fin Q → List EMLOp (outer chains)

Its evaluation at (x, y) is:
$$\text{EMLKA.eval}(x, y) = \sum_{q=1}^Q \Phi_q(\varphi_{1,q}(x) + \varphi_{2,q}(y))$$

**Definition 2.5 (Total Depth)**. The total depth of an EMLKA is the maximum over all terms of the sum of the inner and outer depths.

### 2.3 Spectral Filtration

**Definition 2.6 (Spectral Level)**. A function f : ℝ → ℝ → ℝ belongs to spectral level D (written f ∈ F_D) if there exists an EMLKA decomposition with total depth ≤ D that represents f on the positive quadrant (0,∞)².

---

## 3. Main Results

### 3.1 The Multiplication Decomposition

**Theorem 3.1** (mul_emlka_correct). For all x, y > 0:
$$\exp(\log x + \log y) = x \cdot y$$

This gives a 1-term EMLKA decomposition of multiplication with inner chains [log] and outer chain [exp], achieving total depth 3 (one log + one log + one exp).

*Proof sketch*: Direct computation using exp(log x) = x and exp(a + b) = exp(a) · exp(b). □

### 3.2 Monomial Completeness

**Theorem 3.2** (monomial_emlka_eval). For all x, y > 0 and a, b ∈ ℕ:
$$(monomialEMLKA\; a\; b).\text{eval}\; x\; y = x^a \cdot y^b$$

where monomialEMLKA uses inner chains [affine(a, 0), log] and [affine(b, 0), log] with outer chain [exp].

*Proof*: We have eval = exp(a · log x + b · log y) = exp(a · log x) · exp(b · log y) = x^a · y^b, using the identity exp(n · log x) = x^n for x > 0 and n ∈ ℕ. □

### 3.3 The Depth Lower Bound

**Theorem 3.3** (mul_not_affine_ka). There exist no function Φ : ℝ → ℝ and constants a₁, b₁, a₂, b₂ such that Φ(a₁x + b₁ + a₂y + b₂) = xy for all x, y > 0.

*Proof sketch*: Case analysis on whether a₂ = 0 or a₁ = 0 (then the LHS is independent of one variable while xy depends on both). If both are nonzero, fixing x = 1 determines Φ as affine, but then the decomposition is affine in (x, y) and cannot equal the nonlinear function xy. Verified by instantiation at (1,1), (2,1), (1,2), (2,2). □

### 3.4 Strict Spectral Hierarchy

**Theorem 3.4** (spectral_hierarchy_strict). The spectral filtration is strictly increasing: ∃ f, f ∈ F₃ ∧ f ∉ F₀.

*Proof*: Take f(x,y) = xy. By Theorem 3.1, f ∈ F₃. If f ∈ F₀, then by the characterization of level-0 functions (Theorem 3.6), f(x,y) = αx + βy + γ for all x, y > 0. Evaluating at (1,1), (2,1), (1,2), (2,2) gives α = 1, β = 1, γ = 0. But then f(3,3) = 6 ≠ 9 = 3·3. □

### 3.5 Algebraic Closure

**Theorem 3.5** (emlka_add_closure, emlka_scalar_closure). If f₁ has a Q₁-term EMLKA and f₂ has a Q₂-term EMLKA, then f₁ + f₂ has a (Q₁ + Q₂)-term EMLKA. If f has a Q-term EMLKA, then c · f has a Q-term EMLKA.

*Proof sketch*: For addition, merge decompositions by concatenation with Fin.addCases. For scalar multiplication, prepend affine(c, 0) to each outer chain. □

### 3.6 Level-0 Characterization

**Theorem 3.6** (spectral_level_zero_affine). If f ∈ F₀, then there exist α, β, γ ∈ ℝ such that f(x,y) = αx + βy + γ for all x, y > 0.

*Proof*: By induction on EML chains of depth 0, each such chain evaluates as an affine function. An EMLKA with all-affine chains computes Σ_q (a_q · (c₁_q · x + d₁_q + c₂_q · y + d₂_q) + b_q), which is affine in (x, y). □

### 3.7 Point Separation

**Theorem 3.7** (emlka_separates_points). For any two distinct points (x₁, y₁) ≠ (x₂, y₂) in (0,∞)², there exist a, b ∈ ℝ such that a · log(x₁) + b · log(y₁) ≠ a · log(x₂) + b · log(y₂).

*Proof*: If x₁ ≠ x₂, take a = 1, b = 0; injectivity of log on (0,∞) gives log(x₁) ≠ log(x₂). If y₁ ≠ y₂, take a = 0, b = 1. □

### 3.8 Polynomial Completeness

**Theorem 3.8** (polynomial_emlka). Every polynomial Σᵢ cᵢ · x^{aᵢ} · y^{bᵢ} with M monomials has an M-term EMLKA decomposition on (0,∞)².

*Proof*: Construct inner chains [affine(aᵢ, 0), log] and [affine(bᵢ, 0), log] with outer chains [affine(cᵢ, 0), exp] for each term. □

### 3.9 Fenchel-Young Bound

**Theorem 3.9** (emlka_fenchel_young_bound). For all x ∈ ℝ and s > 0:
$$x \cdot s \leq \exp(x) + s \cdot \log(s) - s$$

with equality iff x = log(s).

*Proof*: From the fundamental inequality exp(t) ≥ 1 + t applied to t = x - log(s), we get exp(x)/s ≥ 1 + x - log(s), which rearranges to the desired bound. □

---

## 4. The EML-KA Approximation Algorithm

### 4.1 Exact Decomposition Algorithm for Polynomials

**Input**: Polynomial p(x,y) = Σᵢ cᵢ x^{aᵢ} y^{bᵢ}

**Output**: EMLKA decomposition

**Algorithm**:
1. For each monomial term i:
   - Set inner₁[i] = [affine(aᵢ, 0), log]
   - Set inner₂[i] = [affine(bᵢ, 0), log]
   - Set outer[i] = [affine(cᵢ, 0), exp]
2. Return EMLKA with Q = number of monomials

**Correctness**: Each term evaluates to cᵢ · exp(aᵢ · log(x) + bᵢ · log(y)) = cᵢ · x^{aᵢ} · y^{bᵢ}.

### 4.2 Approximate Decomposition via Taylor Expansion

For transcendental functions f(x, y) on a compact K ⊂ (0,∞)², approximate by:
1. Compute degree-N Taylor polynomial pₙ in the variables u = log(x), v = log(y)
2. Expand pₙ(u, v) = Σ cᵢ u^{aᵢ} v^{bᵢ} (polynomial in log-coordinates)
3. Apply the polynomial decomposition algorithm

This achieves ε-approximation for sufficiently large N by the density of polynomials.

---

## 5. Connections and Implications

### 5.1 Connection to Neural Network Architectures

The EML Spectral Filtration provides a mathematical foundation for Kolmogorov-Arnold Networks (KANs). The depth of the filtration corresponds to the complexity of learnable univariate functions: shallow networks (depth 2-3) capture multiplicative interactions, while deeper networks handle more complex nonlinearities.

### 5.2 Connection to Information Theory

The Fenchel-Young inequality (Theorem 3.9) connects the EML algebra to the theory of Bregman divergences and exponential families. The pair (exp, s·log(s) - s) forms a conjugate pair in the sense of convex analysis, which is the foundation of maximum entropy methods and information geometry.

### 5.3 Connection to Catalog Results

This work extends `EML.KolmogorovArnoldEMLDeep` from the Aether Catalog, which established basic EML chain machinery and proved multiplication and monomial decompositions. Our contributions are:
- The *spectral filtration* as a novel mathematical structure
- The *strict hierarchy theorem* (lower bound + upper bound)
- The *algebraic closure properties* making the filtration an algebra
- The *Fenchel-Young connection* to convex duality

---

## 6. Falsifiable Conjecture

**Conjecture (EML-KA Depth Characterization)**: For the function f(x,y) = exp(x·y) restricted to [1,2]², the spectral depth is exactly 5.

**Test**: Attempt to construct a 1-term EMLKA of depth 4 that ε-approximates exp(x·y) on [1,2]² for ε = 0.01. If no such decomposition exists after exhaustive numerical search over affine parameters, the lower bound of 5 is supported.

**Prediction**: Depth 4 is insufficient because exp(x·y) requires composing exp with a product, and the product itself requires depth 3, giving a minimum of depth 4 for the composition. However, the outer exp adds depth 1, suggesting depth 5.

---

## 7. Boundary Analysis and Counterexamples

### 7.1 Boundary: Non-positive Domain

The EML-KA framework requires the positive quadrant because log is undefined at 0 and negative numbers. For functions on domains including 0 (e.g., f(x,y) = x·y on [0,1]²), the theory does not directly apply. This is a genuine limitation, not an artifact of the proof technique — logarithms diverge at 0.

### 7.2 Counterexample: Depth-0 Cannot Capture Any Nonlinear Interaction

By Theorem 3.6, depth-0 functions are affine. Therefore:
- f(x,y) = x² is not in F₀ (take y = 0, this is a function of x alone that is nonlinear)
- f(x,y) = max(x, y) is not in F₀ (it is not affine)
- f(x,y) = x·y is not in F₀ (Theorem 3.4)

### 7.3 Generalization: n-variable Monomials

The monomial decomposition generalizes immediately to n variables:
$$x_1^{a_1} \cdots x_n^{a_n} = \exp\left(\sum_{j=1}^n a_j \cdot \log(x_j)\right)$$

This is an n-variable KA decomposition with Q = 1 term and depth 3.

---

## 8. Future Work

1. **Sharp depth bounds**: Determine the exact spectral depth of specific transcendental functions (e.g., sin(x·y), exp(x·y)).

2. **Negative domain extension**: Develop an analogous theory for functions on all of ℝ² using signed logarithms or alternative encodings.

3. **Quantitative approximation rates**: Bound the number of terms Q needed to achieve ε-approximation of a given continuous function, as a function of its regularity.

4. **Categorical structure**: Investigate whether the spectral filtration carries additional categorical structure (e.g., monoidal structure from the product of decompositions).

---

## References

1. Kolmogorov, A.N. (1957). On the representation of continuous functions of several variables by superposition of continuous functions of one variable and addition. *Doklady Akademii Nauk SSSR*, 114, 953-956.

2. Arnold, V.I. (1957). On functions of three variables. *Doklady Akademii Nauk SSSR*, 114, 679-681.

3. Sprecher, D.A. (1965). On the structure of continuous functions of several variables. *Transactions of the AMS*, 115, 340-355.

4. Liu, Z., et al. (2024). KAN: Kolmogorov-Arnold Networks. *arXiv:2404.19756*.

5. Aether Catalog, `EML.KolmogorovArnoldEMLDeep` — EML chain definitions and basic KA decomposition results.
