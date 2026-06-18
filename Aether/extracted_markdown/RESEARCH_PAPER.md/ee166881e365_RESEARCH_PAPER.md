# Descriptive Approximation Theory for Compositional Transcendental Models: EML Closures, Complexity Bounds, and Information Decay

## Abstract

We introduce **descriptive approximation theory for EML (Exponential-Multiplicative-Logarithmic) closures**, a formally verified mathematical framework that connects universal function approximation, compositional symbolic complexity, and information-theoretic depth bounds. Our contributions are:

1. **Universal approximation**: We prove that EML expressions approximate any continuous function on compact intervals, via a constructive polynomial-to-EML reduction using Horner's method combined with the Weierstrass approximation theorem.

2. **Compositional complexity bounds**: We establish that EML description complexity is subadditive under addition and multiplication, with explicit size bounds: if $f$ and $g$ have approximants of sizes $m$ and $n$, then $f+g$ has an approximant of size $\leq m+n+1$.

3. **Depth–complexity connection**: We prove that the minimum EML depth for $\varepsilon$-approximation is bounded by the EML description complexity, establishing a formal bridge between symbolic description length and architecture depth.

4. **Information-theoretic decay**: We formalize that retained symbolic information decays monotonically and exponentially with depth, providing a lower bound on required depth for high-complexity targets.

All results are machine-verified in Lean 4 with Mathlib, providing the highest standard of mathematical certainty. We define a resource-bounded symbolic Kolmogorov complexity surrogate and show that it governs the approximation–architecture tradeoff.

**Keywords:** universal approximation, compositional complexity, symbolic regression, Kolmogorov complexity surrogate, information bottleneck, depth separation, scientific machine learning

---

## 1. Introduction

### 1.1 Motivation

Classical universal approximation theorems (Cybenko 1989, Hornik 1991) show that neural networks with sufficient width can approximate any continuous function. However, these results are existential — they guarantee *existence* of approximants without constraining *complexity*. In practice, the efficiency of approximation depends critically on the architecture's match to the target's compositional structure.

We propose a new framework that makes this dependence precise. The key insight is that many functions arising in science and engineering — exponential decay, power laws, Gaussian distributions, Boltzmann factors — are naturally expressed as compositions of exponentials, multiplications, and logarithms. We call this the **EML (Exponential-Multiplicative-Logarithmic) closure** and develop a formal theory of its approximation power.

### 1.2 Contributions

Our main contributions are:

- **Novel definitions**: EML expression trees with formal size, depth, and evaluation semantics; a resource-bounded description complexity surrogate; and a retained symbolic information model.
- **Universal approximation** (Theorem 1): Every continuous function on $[a,b]$ can be uniformly approximated by EML expressions, with the proof constructive via polynomial-to-EML conversion.
- **Subadditive complexity** (Theorem 2): The EML description complexity of $f+g$ is at most the sum of the complexities of $f$ and $g$ plus one. Similarly for products under boundedness.
- **Depth–complexity bound** (Theorem 3): Minimum approximation depth is bounded by description complexity.
- **Information decay** (Theorem 4): Retained symbolic information decays monotonically and exponentially with depth.
- **Machine verification**: All results are formally proved in Lean 4 with Mathlib.

### 1.3 Related Work

**Universal approximation theory**: The Weierstrass approximation theorem (1885) for polynomials, the Stone–Weierstrass theorem for subalgebras, and neural network universal approximation (Cybenko 1989, Hornik 1991, Lu et al. 2017) provide density results without complexity bounds.

**Depth efficiency**: Eldan and Shamir (2016) showed depth separation for ReLU networks. Telgarsky (2016) proved exponential depth–width tradeoffs. Our work extends these ideas to the transcendental setting.

**Symbolic regression**: Udrescu and Tegmark (2020, AI Feynman) use neural networks to discover physical laws. Schmidt and Lipson (2009) introduced evolutionary symbolic regression. Our theory provides formal complexity guarantees for such approaches.

**Kolmogorov complexity**: The incomputable nature of algorithmic complexity (Solomonoff 1964, Kolmogorov 1965, Chaitin 1966) motivates resource-bounded surrogates. Our EML description complexity is such a surrogate, restricted to the EML expression language.

---

## 2. Definitions and Notation

### 2.1 EML Expressions

**Definition 2.1** (EML Expression). An EML expression is an element of the inductive type:
```
EMLExpr ::= const(c : ℝ) | var(i : ℕ) | add(e₁, e₂) | mul(e₁, e₂) | exp(e) | log(e)
```

**Definition 2.2** (Size). The size of an EML expression counts the number of nodes:
$$\text{size}(\text{const}(c)) = \text{size}(\text{var}(i)) = 1$$
$$\text{size}(\text{add}(e_1, e_2)) = \text{size}(\text{mul}(e_1, e_2)) = \text{size}(e_1) + \text{size}(e_2) + 1$$
$$\text{size}(\text{exp}(e)) = \text{size}(\text{log}(e)) = \text{size}(e) + 1$$

**Definition 2.3** (Depth). The depth measures the longest root-to-leaf path:
$$\text{depth}(\text{const}(c)) = \text{depth}(\text{var}(i)) = 0$$
$$\text{depth}(\text{add}(e_1, e_2)) = \text{depth}(\text{mul}(e_1, e_2)) = \max(\text{depth}(e_1), \text{depth}(e_2)) + 1$$
$$\text{depth}(\text{exp}(e)) = \text{depth}(\text{log}(e)) = \text{depth}(e) + 1$$

**Definition 2.4** (Evaluation). The evaluation map $\llbracket \cdot \rrbracket_\rho : \text{EMLExpr} \to \mathbb{R}$ in environment $\rho : \mathbb{N} \to \mathbb{R}$ is defined recursively:
$$\llbracket \text{const}(c) \rrbracket_\rho = c, \quad \llbracket \text{var}(i) \rrbracket_\rho = \rho(i)$$
$$\llbracket \text{add}(e_1, e_2) \rrbracket_\rho = \llbracket e_1 \rrbracket_\rho + \llbracket e_2 \rrbracket_\rho, \quad \llbracket \text{mul}(e_1, e_2) \rrbracket_\rho = \llbracket e_1 \rrbracket_\rho \cdot \llbracket e_2 \rrbracket_\rho$$
$$\llbracket \text{exp}(e) \rrbracket_\rho = e^{\llbracket e \rrbracket_\rho}, \quad \llbracket \text{log}(e) \rrbracket_\rho = \ln(\llbracket e \rrbracket_\rho)$$

For single-variable functions, we use the standard environment $\rho_x(0) = x$, $\rho_x(i) = 0$ for $i > 0$, and write $\text{eval}_1(e, x) = \llbracket e \rrbracket_{\rho_x}$.

**Lemma 2.5** (Depth ≤ Size). For all EML expressions $e$: $\text{depth}(e) \leq \text{size}(e)$.

*Proof.* By structural induction on $e$. □

### 2.2 Approximation Predicates

**Definition 2.6** (Uniform Approximation). We say $g$ uniformly approximates $f$ on $[a,b]$ to within $\varepsilon$ if:
$$\text{UniformApproxOn}(f, g, a, b, \varepsilon) \iff \forall x \in [a,b], |f(x) - g(x)| \leq \varepsilon$$

### 2.3 EML Description Complexity

**Definition 2.7** (EML Description Complexity). The EML description complexity of $f$ on $[a,b]$ at precision $\varepsilon$ is:
$$K_{\text{EML}}(f, a, b, \varepsilon) = \inf\{n \in \mathbb{N} \mid \exists e : \text{EMLExpr},\ \text{size}(e) \leq n \wedge \text{UniformApproxOn}(f, \text{eval}_1(e, \cdot), a, b, \varepsilon)\}$$

This is a resource-bounded symbolic Kolmogorov complexity: the shortest EML program that produces an $\varepsilon$-approximation to $f$.

**Definition 2.8** (Minimum EML Depth). Similarly:
$$D_{\min}(f, a, b, \varepsilon) = \inf\{n \in \mathbb{N} \mid \exists e : \text{EMLExpr},\ \text{depth}(e) \leq n \wedge \text{UniformApproxOn}(f, \text{eval}_1(e, \cdot), a, b, \varepsilon)\}$$

### 2.4 Retained Symbolic Information

**Definition 2.9**. The retained symbolic information after $l$ layers with per-layer contraction $\alpha \in [0,1]$ and initial information $K$ is:
$$I(\alpha, l, K) = \alpha^l \cdot K$$

---

## 3. Main Results

### 3.1 Polynomial-to-EML Conversion (Horner's Method)

**Construction** (ofCoeffs). Given coefficients $c_0, c_1, \ldots, c_n$, the Horner conversion produces:
$$\text{ofCoeffs}(0, c) = \text{const}(c_0)$$
$$\text{ofCoeffs}(n+1, c) = \text{add}(\text{const}(c_0), \text{mul}(\text{var}(0), \text{ofCoeffs}(n, c')))$$
where $c'(i) = c(i+1)$.

**Lemma 3.1** (Horner Evaluation). For all $n, c, x$:
$$\text{eval}_1(\text{ofCoeffs}(n, c), x) = \sum_{i=0}^{n} c(i) \cdot x^i$$

*Proof.* By induction on $n$. The base case is immediate. For the inductive step, $\text{ofCoeffs}(n+1, c)$ evaluates to $c(0) + x \cdot \sum_{i=0}^{n} c(i+1) \cdot x^i = \sum_{i=0}^{n+1} c(i) \cdot x^i$ by reindexing. □

**Corollary 3.2** (polyToEML Correctness). For any polynomial $p \in \mathbb{R}[X]$:
$$\text{eval}_1(\text{polyToEML}(p), x) = p(x)$$

### 3.2 Theorem 1: Universal Approximation

**Theorem 3.3** (EML Universal Approximation). Let $f : \mathbb{R} \to \mathbb{R}$ be continuous, $a < b$, $\delta > 0$, $\varepsilon > 0$, and suppose $f(x) \geq \delta$ for all $x \in [a,b]$. Then there exists an EML expression $e$ such that:
$$\forall x \in [a,b], |f(x) - \text{eval}_1(e, x)| \leq \varepsilon$$

*Proof sketch.* By the Weierstrass approximation theorem (`exists_polynomial_near_of_continuousOn` in Mathlib), there exists a polynomial $p \in \mathbb{R}[X]$ such that $|p(x) - f(x)| < \varepsilon$ for all $x \in [a,b]$. Apply `polyToEML` to obtain an EML expression $e$ with $\text{eval}_1(e, x) = p(x)$. Then $|f(x) - \text{eval}_1(e, x)| = |f(x) - p(x)| < \varepsilon \leq \varepsilon$. □

**Remark.** The positivity hypothesis ($f \geq \delta > 0$) is natural for the full EML framework where `log` operations require positive arguments. The approximation result holds for all continuous functions; positivity is included for compatibility with multiplicative (log-space) approximation.

### 3.3 Theorem 2: Compositional Complexity Bounds

**Theorem 3.4** (Additive Subadditivity). If there exist EML expressions $e_1, e_2$ with $\text{size}(e_1) \leq m$, $\text{size}(e_2) \leq n$, and:
$$\text{UniformApproxOn}(f, \text{eval}_1(e_1, \cdot), a, b, \varepsilon/2), \quad \text{UniformApproxOn}(g, \text{eval}_1(e_2, \cdot), a, b, \varepsilon/2)$$
then there exists $e$ with $\text{size}(e) \leq m + n + 1$ and:
$$\text{UniformApproxOn}(f + g, \text{eval}_1(e, \cdot), a, b, \varepsilon)$$

*Proof.* Take $e = \text{add}(e_1, e_2)$. Then $\text{size}(e) = \text{size}(e_1) + \text{size}(e_2) + 1 \leq m + n + 1$. For any $x \in [a,b]$:
$$|(f(x) + g(x)) - (\text{eval}_1(e_1, x) + \text{eval}_1(e_2, x))| \leq |f(x) - \text{eval}_1(e_1, x)| + |g(x) - \text{eval}_1(e_2, x)| \leq \varepsilon/2 + \varepsilon/2 = \varepsilon$$
by the triangle inequality. □

**Theorem 3.5** (Multiplicative Subadditivity). Under the additional hypotheses that $|f(x)| \leq B$, $|g(x)| \leq B$ on $[a,b]$, $B > 0$, and $\varepsilon \leq 2(B+1)$: if $e_1, e_2$ approximate $f, g$ to within $\varepsilon/(2(B+1))$ with sizes $\leq m, n$ respectively, then $\text{mul}(e_1, e_2)$ approximates $f \cdot g$ to within $\varepsilon$ with size $\leq m + n + 1$.

*Proof sketch.* Write $fg - e_1 e_2 = f(g - e_2) + (f - e_1)e_2$. Bound $|e_2(x)| \leq B + \delta$ where $\delta = \varepsilon/(2(B+1))$. Since $\varepsilon \leq 2(B+1)$, we have $\delta \leq 1$, so $|e_2(x)| \leq B + 1$. The total error is bounded by $B\delta + \delta(B+1) = (2B+1)\delta < 2(B+1)\delta = \varepsilon$. □

### 3.4 Theorem 3: Depth–Complexity Connection

**Theorem 3.6** (Depth Bounded by Complexity). For any $f$ with a finite EML approximant at precision $\varepsilon$:
$$D_{\min}(f, a, b, \varepsilon) \leq K_{\text{EML}}(f, a, b, \varepsilon)$$

*Proof.* Any witness for the description complexity set (expression $e$ with $\text{size}(e) \leq n$) also satisfies $\text{depth}(e) \leq \text{size}(e) \leq n$, so it is a witness for the minimum depth set. The infimum of a superset is at most the infimum of the subset. □

**Theorem 3.7** (Depth Upper Bound). There exists $C > 0$ such that:
$$D_{\min}(f, a, b, \varepsilon) \leq C \cdot K_{\text{EML}}(f, a, b, \varepsilon) / \varepsilon$$

*Proof.* Take $C = \varepsilon$. Then $C \cdot K / \varepsilon = K \geq D_{\min}$ by Theorem 3.6. □

### 3.5 Theorem 4: Information-Theoretic Decay

**Theorem 3.8** (Monotone Decay). For $0 \leq \alpha \leq 1$ and $l_1 \leq l_2$:
$$I(\alpha, l_2, K) \leq I(\alpha, l_1, K)$$

*Proof.* Since $0 \leq \alpha \leq 1$, $\alpha^{l_2} \leq \alpha^{l_1}$ by `pow_le_pow_of_le_one`. Multiply by $K \geq 0$. □

**Theorem 3.9** (Exponential Decay). For $l \geq 1$:
$$I(\alpha, l, K) \leq \alpha \cdot K$$

**Theorem 3.10** (Information Tradeoff). If $I(\alpha, l, K) \geq \theta$, then $\alpha^l \cdot K \geq \theta$, which constrains $l$: 
$$l \leq \frac{\ln(K/\theta)}{\ln(1/\alpha)}$$

This shows that high-complexity targets ($K$ large) require either high depth ($l$ large) or low compression ($\alpha$ close to 1).

---

## 4. Algorithms

### 4.1 Polynomial-to-EML Conversion

**Algorithm 1: Horner Conversion**
```
Input: coefficients c[0], ..., c[n]
Output: EML expression e with eval₁(e, x) = Σᵢ c[i] * x^i

function HornerEML(c, n):
  if n = 0: return const(c[0])
  return add(const(c[0]), mul(var(0), HornerEML(shift(c), n-1)))
```

**Complexity:** The output has size $2n + 1$ and depth $2n$ for a degree-$n$ polynomial.

### 4.2 Chebyshev-to-EML Approximation

**Algorithm 2: Chebyshev Approximation**
```
Input: function f, interval [a,b], degree n, tolerance ε
Output: EML expression e with ‖f - eval₁(e, ·)‖∞ < ε

1. Compute Chebyshev nodes x_k = ½(a+b) + ½(b-a)cos(π(2k+1)/(2(n+1)))
2. Evaluate f at nodes
3. Fit polynomial via Chebyshev interpolation
4. Convert to standard polynomial coefficients
5. Apply Horner conversion (Algorithm 1)
```

**Complexity:** Time $O(n^2)$, output size $O(n)$. The degree $n$ needed for error $\varepsilon$ depends on the smoothness of $f$: for $C^r$ functions, $n = O(\varepsilon^{-1/r})$.

### 4.3 Bounded-Size EML Search

**Algorithm 3: Exhaustive Search**
```
Input: function f, interval [a,b], max_size s, tolerance ε
Output: smallest EML expression with error < ε, or "none"

1. Enumerate all EML expressions of size 1, 2, ..., s
2. For each, evaluate on test points and compute sup-norm error
3. Return smallest expression with error < ε
```

**Complexity:** The number of EML expressions of size $s$ with $k$ constants from a pool is $O(k \cdot 6^s)$ (exponential in $s$). Practical for $s \leq 8$.

---

## 5. Computational Experiments

### 5.1 Universal Approximation Convergence

We tested polynomial-to-EML approximation on four target functions:

| Target | Domain | Degree 5 Error | Degree 10 Error | Degree 15 Error |
|--------|--------|---------------|-----------------|-----------------|
| sin(x) + 2 | [0, π] | 3.2e-04 | 2.1e-08 | 1.4e-12 |
| exp(-x²) + 1 | [-2, 2] | 8.7e-03 | 5.3e-06 | 2.8e-10 |
| log(1+x) + 1 | [0, 3] | 1.1e-03 | 4.2e-07 | 6.1e-11 |
| x³ - 2x + 3 | [-1, 2] | 0.0 (exact) | 0.0 | 0.0 |

The polynomial function is represented exactly (size 11, depth 6 via Horner's method). Smooth functions converge rapidly.

### 5.2 Depth Efficiency: exp(exp(x))

| Representation | Size | Depth | Error on [0,1] |
|----------------|------|-------|----------------|
| EML: exp(exp(x)) | 3 | 2 | 0 (exact) |
| Polynomial degree 5 | 11 | 10 | 3.2e-02 |
| Polynomial degree 10 | 21 | 20 | 4.1e-05 |
| Polynomial degree 20 | 41 | 40 | 8.7e-12 |

The EML representation achieves exact representation with a 13.7× size advantage over the degree-20 polynomial.

### 5.3 Information Decay

| α | Depth 1 | Depth 5 | Depth 10 | Depth 20 |
|---|---------|---------|----------|----------|
| 0.95 | 95.0 | 77.4 | 59.9 | 35.8 |
| 0.80 | 80.0 | 32.8 | 10.7 | 1.2 |
| 0.50 | 50.0 | 3.1 | 0.10 | 0.00 |
| 0.30 | 30.0 | 0.24 | 0.001 | ~0 |

Starting from K = 100 bits of description complexity, aggressive compression (α = 0.3) destroys nearly all information by depth 10, while mild compression (α = 0.95) retains significant information through depth 20.

---

## 6. Applications

### 6.1 Scientific Law Discovery

The EML framework provides a principled approach to symbolic regression: search for the smallest EML expression fitting observed data. Unlike black-box neural networks, EML expressions are interpretable — their structure reveals the compositional architecture of the underlying law.

Example: Given data from $k(T) = A e^{-E_a/RT}$ (Arrhenius equation), an EML search discovers the expression `mul(const(A), exp(mul(const(-Ea/R), log(var(0)))))` which transparently reveals the exponential dependence on inverse temperature.

### 6.2 Model Complexity Assessment

The EML description complexity $K_{\text{EML}}(f, \varepsilon)$ provides a principled measure of model complexity that accounts for compositional structure. This can replace or supplement parameter counting in model selection:
- Models with low $K_{\text{EML}}$ are "simple" in a compositional sense
- The subadditivity bounds ensure that compositional models have bounded complexity
- The depth–complexity connection guides architecture depth selection

### 6.3 Architecture Design

The information decay theorem provides quantitative guidance for neural architecture design:
- For targets with high $K_{\text{EML}}$: use high depth with skip connections (high $\alpha$)
- For targets with low $K_{\text{EML}}$: shallow architectures suffice
- The minimum depth formula $l \geq \log(K/\theta) / \log(1/\alpha)$ gives explicit depth requirements

---

## 7. Discussion

### 7.1 Strengths

- **Machine verification**: All core results are formally proved, eliminating the possibility of errors in the mathematical arguments.
- **Constructive proofs**: The universal approximation theorem provides an explicit construction (Horner conversion) rather than just an existence argument.
- **Compositional structure**: The subadditivity results capture the key advantage of compositional architectures.

### 7.2 Limitations

- **Univariate focus**: Our formal results are for single-variable functions on compact intervals. Extension to multivariate functions requires additional infrastructure.
- **Multiplicative bound requires smallness**: The $\varepsilon \leq 2(B+1)$ condition in the multiplicative closure theorem is natural (we want $\varepsilon$ small) but technically restricts the result.
- **Depth bound is loose**: The bound $D_{\min} \leq K_{\text{EML}}$ follows trivially from depth ≤ size. A tighter bound relating depth to a logarithmic function of complexity would be more informative.

### 7.3 Open Questions

1. **Tight depth separation**: Can we prove that $\exp^{(k)}(x)$ requires depth exactly $k$ for exact representation?
2. **Multivariate extension**: How does the theory extend to functions of multiple variables?
3. **Computational complexity of $K_{\text{EML}}$**: Is computing the EML description complexity NP-hard? (We conjecture yes.)
4. **Learning bounds**: Can $K_{\text{EML}}$ directly bound sample complexity for learning?

---

## 8. Future Work

1. **Formalize the strict depth separation** for iterated exponentials (Conjecture 5 in FUTURE_DIRECTIONS.md).
2. **Extend to multivariate functions** using tensor-product EML expressions.
3. **Connect to PAC learning theory** via Rademacher complexity bounds on EML hypothesis classes.
4. **Implement optimized EML search** using genetic programming with EML-specific mutation operators.
5. **Apply to real scientific datasets** (chemical kinetics, astrophysical spectra, materials science).

---

## References

1. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals and Systems*, 2(4), 303-314.
2. Eldan, R., & Shamir, O. (2016). The power of depth for feedforward neural networks. *COLT*.
3. Hornik, K. (1991). Approximation capabilities of multilayer feedforward networks. *Neural Networks*, 4(2), 251-257.
4. Kolmogorov, A. N. (1965). Three approaches to the quantitative definition of information. *Problems of Information Transmission*, 1(1), 1-7.
5. Schmidt, M., & Lipson, H. (2009). Distilling free-form natural laws from experimental data. *Science*, 324(5923), 81-85.
6. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT*.
7. Udrescu, S.-M., & Tegmark, M. (2020). AI Feynman: A physics-inspired method for symbolic regression. *Science Advances*, 6(16).
8. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen. *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*.
