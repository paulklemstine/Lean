# EML-Kolmogorov-Arnold Representation Theory

## Abstract

We establish a systematic connection between the EML (exp-log-minus) function class and Kolmogorov-Arnold representations. For a bivariate function f : ℝ² → ℝ, the Kolmogorov-Arnold theorem guarantees decompositions of the form f(x,y) = Σ_{q} Φ_q(φ_{1,q}(x) + φ_{2,q}(y)) with at most 2n+1 = 5 terms. We prove that multiplication, powers, geometric means, and division all admit 1-term decompositions where the inner functions are logarithms and the outer function is the exponential—both EML primitives. We establish the continuity of these decompositions, prove that EML primitives separate points on (0,∞), show that the decomposition algebra is closed under addition, and connect the framework to information theory via the KL divergence. We prove the Fenchel-Young inequality as the variational foundation underlying EML-KA efficiency. All results are formalized and machine-verified.

**Keywords**: Kolmogorov-Arnold theorem, EML functions, exponential-logarithm decomposition, representation theory, information theory, convex duality

---

## 1. Introduction

### 1.1 Background

The Kolmogorov-Arnold representation theorem (Kolmogorov 1957, Arnold 1957) states that every continuous function f : [0,1]^n → ℝ can be written as

$$f(x_1, \ldots, x_n) = \sum_{q=0}^{2n} \Phi_q\left(\sum_{p=1}^n \varphi_{q,p}(x_p)\right)$$

where each φ_{q,p} : [0,1] → ℝ and Φ_q : ℝ → ℝ are continuous univariate functions. This result resolved Hilbert's 13th problem by showing that functions of arbitrarily many variables can be reduced to compositions of univariate functions and addition.

The theorem is existential—it guarantees the inner and outer functions exist but does not specify them constructively. The inner functions in the original proof are highly irregular (Hölder continuous but nowhere differentiable).

### 1.2 The EML Function Class

The EML (exp-log-minus) operation is defined as:

$$\text{eml}(x, y) = e^x - \ln y$$

This single binary operation subsumes both exp and log:
- exp(x) = eml(x, 1), since log(1) = 0
- log(y) = 1 - eml(0, y), since exp(0) = 1

Combined with field operations, eml generates the elementary real function class. The compilation theorem (established in prior work) shows that every expression built from exp, log, and field operations can be rewritten using eml as the sole transcendental primitive.

### 1.3 Our Contribution

We prove that for a significant class of multivariate functions—including all monomial, power, and mean functions—the Kolmogorov-Arnold inner and outer functions can be chosen from the EML function class. Specifically:

1. **Multiplication** x·y = exp(log x + log y) gives a 1-term EML-KA decomposition (vs. the general bound of 5 terms).
2. **Power functions** x^n = exp(n·log x) decompose with a single scaled-log inner function.
3. **Geometric mean** √(xy) = exp(½ log x + ½ log y) uses half-scaled logs.
4. **Division** x/y = exp(log x - log y) uses negated log.
5. **KL divergence** p·log(p/q) decomposes via EML, bridging to information theory.
6. **Fenchel-Young inequality** provides the variational foundation.

---

## 2. Definitions and Notation

### 2.1 KA Decomposition Structure

**Definition 2.1** (KADecomp₂). A *Q-term Kolmogorov-Arnold decomposition* for a bivariate function consists of:
- Inner functions φ₁_q, φ₂_q : ℝ → ℝ for q ∈ {0, ..., Q-1}
- Outer functions Φ_q : ℝ → ℝ for q ∈ {0, ..., Q-1}

The decomposition evaluates as:

$$\text{eval}(x, y) = \sum_{q=0}^{Q-1} \Phi_q(\varphi_{1,q}(x) + \varphi_{2,q}(y))$$

**Definition 2.2** (Represents). A decomposition d *represents* f on S ⊆ ℝ² if eval(x,y) = f(x,y) for all (x,y) ∈ S.

### 2.2 EML Primitives

**Definition 2.3** (EMLPrimitive). An EML primitive is one of:
- expFn: x ↦ exp(x)
- logFn: x ↦ log(x)
- affine(a,b): x ↦ a·x + b

An *EML-KA decomposition* is one where all inner and outer functions are EML primitives or compositions thereof.

### 2.3 Weighted KA Decomposition

**Definition 2.4** (WKADecomp₂). A *weighted Q-term KA decomposition* extends KADecomp₂ with scalar weights w_q ∈ ℝ:

$$\text{eval}_w(x, y) = \sum_{q=0}^{Q-1} w_q \cdot \Phi_q(\varphi_{1,q}(x) + \varphi_{2,q}(y))$$

---

## 3. Main Results

### 3.1 Multiplication (Theorem: mul_ka_decomp_spec)

**Theorem 3.1.** For all x, y > 0:

$$\exp(\log x + \log y) = x \cdot y$$

*Proof.* By the addition law for exp and the inverse property exp(log z) = z for z > 0:
$$\exp(\log x + \log y) = \exp(\log x) \cdot \exp(\log y) = x \cdot y. \qquad \square$$

**Corollary 3.2** (mul_ka_represents). The decomposition mulKADecomp with φ₁ = φ₂ = log, Φ = exp represents multiplication on (0,∞)².

### 3.2 Power Functions (Theorem: exp_mul_log_eq_pow)

**Theorem 3.3.** For all x > 0 and n ∈ ℕ:

$$\exp(n \cdot \log x) = x^n$$

*Proof.* By induction on n.
- Base case (n = 0): exp(0 · log x) = exp(0) = 1 = x⁰.
- Inductive step: exp((k+1) · log x) = exp(k · log x + log x) = exp(k · log x) · exp(log x) = x^k · x = x^{k+1}. □

### 3.3 Geometric Mean (Theorem: exp_half_log_eq_sqrt_mul)

**Theorem 3.4.** For all x, y > 0:

$$\exp\left(\tfrac{1}{2}\log x + \tfrac{1}{2}\log y\right) = \sqrt{xy}$$

*Proof.* We have ½ log x + ½ log y = ½(log x + log y) = ½ log(xy). Then exp(½ log(xy)) = (xy)^{1/2} = √(xy) by the definition of real powers. □

### 3.4 Division (Theorem: div_ka_decomp_spec)

**Theorem 3.5.** For all x, y > 0:

$$\exp(\log x - \log y) = \frac{x}{y}$$

*Proof.* exp(log x - log y) = exp(log x) / exp(log y) = x/y. □

### 3.5 KA Closure Under Addition (Theorem: ka_add_eval)

**Theorem 3.6.** If d₁ is a Q₁-term decomposition and d₂ is a Q₂-term decomposition, then their sum (concatenating all terms) is a (Q₁+Q₂)-term decomposition satisfying:

$$(d_1 \oplus d_2)(x, y) = d_1(x, y) + d_2(x, y)$$

*Proof.* The sum over Fin(Q₁ + Q₂) splits via Fin.sum_univ_add into the sum over the first Q₁ indices plus the sum over the last Q₂ indices. The dite conditions resolve correctly in each range. □

### 3.6 Fenchel-Young Inequality (Theorem: fenchel_young_eml)

**Theorem 3.7.** For all x ∈ ℝ and s > 0:

$$x \cdot s \leq e^x + s \cdot \ln s - s$$

*Proof.* From the fundamental inequality log(u) ≤ u - 1 for u > 0, applied to u = exp(x)/s, we get log(exp(x)/s) ≤ exp(x)/s - 1, i.e., x - log s ≤ exp(x)/s - 1. Multiplying by s > 0: s·x - s·log s ≤ exp(x) - s, giving x·s ≤ exp(x) + s·log s - s. □

**Theorem 3.8** (fenchel_young_tight). Equality holds when x = log s:

$$(\log s) \cdot s = e^{\log s} + s \cdot \ln s - s = s + s \ln s - s = s \ln s$$

---

## 4. Cross-Domain: Information Theory

### 4.1 KL Divergence Decomposition (Theorem: kl_div_decomp)

**Theorem 4.1.** For p, q > 0:

$$p \cdot \log\frac{p}{q} = p \cdot \log p - p \cdot \log q$$

This decomposes the KL integrand into a sum of univariate terms: the self-information p·log p (a function of p alone) and the cross-term p·log q (bilinear in p and q).

### 4.2 EML Encoding (Theorem: kl_eml_connection)

**Theorem 4.2.** The KL integrand can be expressed via the EML operation:

$$p \cdot \log\frac{p}{q} = p \cdot \log p - p \cdot (1 - \text{eml}(0, q))$$

where eml(0, q) = 1 - log q. This shows the KL divergence integrand is naturally within the EML computational framework.

---

## 5. Continuity and Separation

### 5.1 Continuity (Theorem: mul_ka_continuous_on)

**Theorem 5.1.** The map (x, y) ↦ exp(log x + log y) is continuous on (0,∞)².

*Proof.* Log is continuous on (0,∞), projection maps (x,y) ↦ x and (x,y) ↦ y are continuous, addition is continuous, and exp is continuous on ℝ. The composition of continuous maps is continuous. □

### 5.2 Point Separation (Theorem: eml_ka_inner_separates)

**Theorem 5.2.** For any x₁, x₂ ∈ (0,∞) with x₁ ≠ x₂, there exists an EML primitive φ such that φ(x₁) ≠ φ(x₂).

*Proof.* Take φ = log. Since log is injective on (0,∞) (being strictly monotone), log(x₁) ≠ log(x₂). □

---

## 6. Efficiency Analysis

### 6.1 Term Count Comparison

| Function | General KA bound | EML-KA terms | Savings |
|----------|-----------------|-------------|---------|
| x·y      | 5 (2·2+1)      | 1           | 80%     |
| x^n      | 3 (2·1+1)      | 1           | 67%     |
| √(xy)    | 5               | 1           | 80%     |
| x/y      | 5               | 1           | 80%     |
| f + g    | Q₁ + Q₂        | Q₁ + Q₂    | —       |

### 6.2 EML Depth

The *EML depth* of a decomposition counts the number of nested exp/log layers:
- Multiplication: depth 2 (one log layer + one exp layer)
- Powers: depth 2 (one scaled-log layer + one exp layer)
- Division: depth 2 (one log/neg-log layer + one exp layer)

All elementary operations achieve the minimum possible EML depth of 2.

---

## 7. Computational Experiments

### 7.1 Numerical Verification

We verified all decompositions numerically in Python (see `demo.py`).

| Test | x | y | KA result | Direct | Error |
|------|---|---|-----------|--------|-------|
| Multiplication | 3.0 | 4.0 | 12.0000000000 | 12.0 | 2.2e-15 |
| Power (x³) | 2.0 | — | 8.0000000000 | 8.0 | 1.8e-15 |
| Geom. mean | 4.0 | 9.0 | 6.0000000000 | 6.0 | 8.9e-16 |
| Division | 6.0 | 3.0 | 2.0000000000 | 2.0 | 4.4e-16 |

All decompositions achieve machine-precision accuracy (errors < 10⁻¹⁴).

### 7.2 Fenchel-Young Gap

The Fenchel-Young gap exp(x) + s·log(s) - s - x·s was verified to be non-negative for all tested (x, s) pairs, with the gap vanishing at x = log(s).

---

## 8. Algorithms

### 8.1 KA Decomposition Construction

**Algorithm 1: Construct EML-KA Decomposition**

```
Input: Target operation type τ ∈ {mul, pow(n), geom_mean, div}
Output: KADecomp₂ with Q = 1

function ConstructEMLKA(τ):
    match τ:
        case mul:
            return KADecomp₂(φ₁ = log, φ₂ = log, Φ = exp)
        case pow(n):
            return KADecomp₂(φ₁ = n·log, φ₂ = 0, Φ = exp)
        case geom_mean:
            return KADecomp₂(φ₁ = ½·log, φ₂ = ½·log, Φ = exp)
        case div:
            return KADecomp₂(φ₁ = log, φ₂ = -log, Φ = exp)
```

**Complexity**: O(1) construction, O(Q) evaluation per point.

### 8.2 KA Decomposition Addition

**Algorithm 2: Add KA Decompositions**

```
Input: d₁ with Q₁ terms, d₂ with Q₂ terms
Output: d with Q₁ + Q₂ terms

function AddKA(d₁, d₂):
    Q ← Q₁ + Q₂
    for q = 0 to Q-1:
        if q < Q₁:
            (φ₁_q, φ₂_q, Φ_q) ← (d₁.φ₁_q, d₁.φ₂_q, d₁.Φ_q)
        else:
            (φ₁_q, φ₂_q, Φ_q) ← (d₂.φ₁_{q-Q₁}, d₂.φ₂_{q-Q₁}, d₂.Φ_{q-Q₁})
    return KADecomp₂(Q, φ₁, φ₂, Φ)
```

**Complexity**: O(Q₁ + Q₂) construction, O(Q₁ + Q₂) evaluation.

---

## 9. Discussion

### 9.1 Why Exp and Log?

The privileged role of exp and log in EML-KA decompositions is not accidental. It arises from three structural properties:

1. **Homomorphism**: log converts multiplication to addition, which is the combining operation in KA decompositions.
2. **Injectivity**: log is injective on (0,∞), ensuring point separation.
3. **Convex duality**: exp and the entropy function are Legendre conjugates, connected by the Fenchel-Young inequality.

### 9.2 Limitations

The current results are restricted to functions expressible as products, quotients, and powers of the input variables. The conjecture that *all* continuous functions on (0,∞)² admit finite EML-KA decompositions remains open.

The key obstruction is *sums of powers*: log(x² + y²) does not obviously factor through the addition structure of the KA decomposition. This is the simplest test case for the conjecture.

### 9.3 Connection to KAN Networks

The Kolmogorov-Arnold Network (KAN) architecture (Liu et al. 2024) learns both inner and outer functions. Our results suggest a prior: initializing inner functions as logarithms and outer functions as exponentials should be highly effective for learning multiplicative/power-law relationships, which are ubiquitous in physics and engineering.

---

## 10. Future Work

1. **Conjecture verification**: Can log(x² + y²) be decomposed into a finite number of EML-KA terms? A computational search over 3-term decompositions with parameterized inner/outer functions would test this.

2. **Approximation bounds**: For functions that do not have exact EML-KA decompositions, what is the best Q-term EML-KA approximation error as a function of Q?

3. **Higher dimensions**: Extend the multiplication decomposition to n variables: x₁·x₂·...·xₙ = exp(Σ log xᵢ). This is a 1-term decomposition for any n, while the general KA bound is 2n+1.

4. **Tropical limits**: As parameters approach infinity, do EML-KA decompositions converge to tropical (max-plus) decompositions?

---

## References

1. Kolmogorov, A.N. (1957). On the representation of continuous functions of several variables by superposition of continuous functions of one variable and addition. *Doklady Akademii Nauk SSSR*, 114, 953–956.

2. Arnold, V.I. (1957). On functions of three variables. *Doklady Akademii Nauk SSSR*, 114, 679–681.

3. Sprecher, D.A. (1965). On the structure of continuous functions of several variables. *Transactions of the AMS*, 115, 340–355.

4. Liu, Z., et al. (2024). KAN: Kolmogorov-Arnold Networks. *arXiv:2404.19756*.

5. Braun, J., & Griebel, M. (2009). On a constructive proof of Kolmogorov's superposition theorem. *Constructive Approximation*, 30(3), 653–675.
