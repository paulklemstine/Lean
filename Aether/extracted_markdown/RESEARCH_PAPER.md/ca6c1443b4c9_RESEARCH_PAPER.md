# EML Chains and Kolmogorov-Arnold Decomposition: Depth-Bounded Representations via Exponential-Logarithmic Primitives

## Abstract

We introduce **EML chains** — finite compositions of exponential, logarithmic, and affine operations — as a structured function class for Kolmogorov-Arnold (KA) decompositions. We prove that every monomial $x^a y^b$ ($a, b \in \mathbb{N}$) admits a 1-term EML-KA decomposition of depth exactly 3, independent of the monomial degree. This yields EML-KA decompositions for arbitrary polynomials with $M$ terms using exactly $M$ KA terms, each of bounded depth. We establish connections to convex duality via the Fenchel-Young inequality and to classical inequalities via the AM-GM theorem, both expressed naturally in the EML framework. All results are formalized and machine-verified in Lean 4 with Mathlib. We state a falsifiable universality conjecture: that EML-KA decompositions can approximate any continuous function on $(0,\infty)^2$ to arbitrary accuracy.

**Keywords**: Kolmogorov-Arnold representation, EML functions, exponential-logarithmic chains, function decomposition, universal approximation

---

## 1. Introduction

The Kolmogorov-Arnold representation theorem (Kolmogorov 1957, Arnold 1957) states that any continuous function $f : [0,1]^n \to \mathbb{R}$ can be written as

$$f(x_1, \ldots, x_n) = \sum_{q=0}^{2n} \Phi_q\left(\sum_{p=1}^n \varphi_{q,p}(x_p)\right)$$

where each $\varphi_{q,p}$ and $\Phi_q$ is a continuous univariate function. While existentially powerful, the theorem is non-constructive: it does not specify the nature of the inner functions $\varphi_{q,p}$.

Recent interest in Kolmogorov-Arnold Networks (KANs) for machine learning (Liu et al. 2024) has renewed attention to the question: what function classes suffice for the inner and outer functions? We propose that **EML chains** — compositions of $\exp$, $\log$, and affine maps — provide a natural, depth-bounded answer for a significant class of target functions.

### 1.1 The EML Operation

The EML (exponential-minus-logarithm) operation is defined as $\text{eml}(x, y) = e^x - \log y$. This operation naturally arises at the intersection of multiplicative and additive structures: $\exp$ converts addition to multiplication, while $\log$ converts multiplication to addition.

### 1.2 Contributions

1. **EML Chain formalism** (§2): We define EML chains as lists of elementary operations and prove composition and depth-subadditivity theorems.

2. **Monomial decomposition** (§3): We prove that every monomial $x^a y^b$ has a 1-term, depth-3 EML-KA decomposition, with the depth independent of $a$ and $b$.

3. **Polynomial decomposition** (§4): We construct explicit $M$-term EML-KA decompositions for polynomials with $M$ monomials.

4. **Variational connections** (§5): We prove the Fenchel-Young inequality and AM-GM in the EML framework, revealing the duality structure.

5. **Universality conjecture** (§6): We state a falsifiable conjecture about EML-KA universality with a concrete computational test.

---

## 2. EML Chains

### 2.1 Definition

An **EML chain operation** is one of:
- $\text{exp}$: $x \mapsto e^x$
- $\text{log}$: $x \mapsto \log x$  
- $\text{affine}(a, b)$: $x \mapsto ax + b$

An **EML chain** is a finite list $[op_1, op_2, \ldots, op_k]$ of such operations, evaluated as the composition $op_1 \circ op_2 \circ \cdots \circ op_k$.

**Definition (Depth)**. The depth of an EML chain counts the number of non-affine operations (i.e., the number of $\exp$ and $\log$ operations).

### 2.2 Composition Theorem

**Theorem 2.1** (Chain Composition). *For EML chains $c_1$ and $c_2$ and any $x \in \mathbb{R}$:*
$$\text{eval}(c_1 \mathbin{++} c_2, x) = \text{eval}(c_1, \text{eval}(c_2, x))$$

*Proof.* By structural induction on $c_1$. The base case ($c_1 = []$) is immediate. For $c_1 = op :: \text{rest}$, we have $\text{eval}((op :: \text{rest}) \mathbin{++} c_2, x) = op(\text{eval}(\text{rest} \mathbin{++} c_2, x)) = op(\text{eval}(\text{rest}, \text{eval}(c_2, x))) = \text{eval}(op :: \text{rest}, \text{eval}(c_2, x))$ by the induction hypothesis. $\square$

**Theorem 2.2** (Depth Subadditivity). *For EML chains $c_1$ and $c_2$:*
$$\text{depth}(c_1 \mathbin{++} c_2) \leq \text{depth}(c_1) + \text{depth}(c_2)$$

*Proof.* By induction on $c_1$ with case analysis on each operation type. $\square$

### 2.3 Fundamental Identities

- **Cancellation**: $\text{eval}([\exp, \log], x) = x$ for $x > 0$, and $\text{eval}([\log, \exp], x) = x$ for all $x$.
- **Scaled log**: The chain $[\text{affine}(a, 0), \log]$ evaluates to $x \mapsto a \cdot \log x$ and has depth 1.

---

## 3. Monomial Decomposition

### 3.1 EML-KA Decomposition Structure

An **EML-KA decomposition** with $Q$ terms consists of:
- Inner chains $\varphi_1^{(q)}, \varphi_2^{(q)}$ for the two variables
- Outer chains $\Phi^{(q)}$

The decomposition evaluates as:
$$d(x, y) = \sum_{q=1}^Q \Phi^{(q)}\!\left(\varphi_1^{(q)}(x) + \varphi_2^{(q)}(y)\right)$$

### 3.2 The Core Identity

**Theorem 3.1** (Monomial Identity). *For $x, y > 0$ and $a, b \in \mathbb{N}$:*
$$\exp(a \cdot \log x + b \cdot \log y) = x^a \cdot y^b$$

*Proof.* By the laws of exponents:
$$\exp(a \log x + b \log y) = \exp(a \log x) \cdot \exp(b \log y) = (\exp(\log x))^a \cdot (\exp(\log y))^b = x^a \cdot y^b$$
using $\exp(\log z) = z$ for $z > 0$ and $\exp(n \cdot t) = (\exp t)^n$. $\square$

### 3.3 Depth-3 Decomposition

**Theorem 3.2** (Monomial Completeness). *Every monomial $x^a y^b$ admits a 1-term EML-KA decomposition with:*
- *$\varphi_1 = [\text{affine}(a, 0), \log]$ (depth 1)*
- *$\varphi_2 = [\text{affine}(b, 0), \log]$ (depth 1)*  
- *$\Phi = [\exp]$ (depth 1)*
- *Maximum depth = 3 (= 1 + 1 + 1)*

**Corollary 3.3** (Depth Independence). *The maximum depth of the monomial EML-KA decomposition is exactly 3, independent of the exponents $a$ and $b$.*

This is perhaps the most striking result: a monomial of arbitrarily high degree (e.g., $x^{1000} y^{2000}$) has the same decomposition depth as the simple product $xy$.

---

## 4. Polynomial Decomposition

### 4.1 Term-by-Term Construction

**Theorem 4.1** (Polynomial Bound). *For any polynomial $p(x, y) = \sum_{i=1}^M c_i \cdot x^{a_i} y^{b_i}$ with $M$ monomials, there exists an EML-KA decomposition with $M$ terms such that for all $x, y > 0$:*
$$d(x, y) = p(x, y)$$

*Proof.* For the $i$-th term, use:
- $\varphi_1^{(i)} = [\text{affine}(a_i, 0), \log]$
- $\varphi_2^{(i)} = [\text{affine}(b_i, 0), \log]$
- $\Phi^{(i)} = [\text{affine}(c_i, 0), \exp]$

The $i$-th term evaluates to $c_i \cdot \exp(a_i \log x + b_i \log y) = c_i \cdot x^{a_i} y^{b_i}$ by the monomial identity. Summing over $i$ gives $p(x, y)$. $\square$

### 4.2 Comparison with Classical KA

| Property | Classical KA | EML-KA (monomials) | EML-KA (polynomials) |
|----------|-------------|--------------------|--------------------|
| Terms for $n = 2$ | 5 (fixed) | 1 per monomial | $M$ (# monomials) |
| Inner function class | Arbitrary continuous | EML chains | EML chains |
| Depth | Unbounded | 3 (fixed) | 3 (fixed) |
| Domain | $[0,1]^n$ | $(0,\infty)^2$ | $(0,\infty)^2$ |

---

## 5. Variational Connections

### 5.1 AM-GM via EML

**Theorem 5.1** (AM-GM in EML Form). *For $x, y > 0$:*
$$\exp\!\left(\frac{\log x + \log y}{2}\right) \leq \frac{x + y}{2}$$

*Proof sketch.* The left side equals $\sqrt{xy}$ (the geometric mean). The inequality $\sqrt{xy} \leq (x+y)/2$ follows from $(\sqrt{x} - \sqrt{y})^2 \geq 0$. $\square$

This result shows that the EML encoding (log) followed by linear averaging followed by EML decoding (exp) always underestimates the true average. The "nonlinearity gap" is $\frac{x+y}{2} - \sqrt{xy} = \frac{(\sqrt{x} - \sqrt{y})^2}{2}$.

### 5.2 Fenchel-Young Inequality

**Theorem 5.2** (Fenchel-Young). *For all $x \in \mathbb{R}$ and $s > 0$:*
$$x \cdot s \leq e^x + s \log s - s$$

*Equality holds if and only if $x = \log s$.*

*Proof sketch.* Set $t = e^x / s > 0$. The inequality reduces to $t - \log t - 1 \geq 0$, which follows from $\log t \leq t - 1$ for $t > 0$. $\square$

This inequality reveals that $\exp$ and $s \mapsto s \log s - s$ are convex conjugates, providing the variational foundation for the EML framework.

---

## 6. Universality Conjecture

**Conjecture 6.1** (EML-KA Universality). *For every continuous function $f : (0,\infty)^2 \to \mathbb{R}$, every compact $K \subset (0,\infty)^2$, and every $\varepsilon > 0$, there exists $Q \in \mathbb{N}$ and an EML-KA decomposition $d$ with $Q$ terms such that:*
$$\sup_{(x,y) \in K} |d(x, y) - f(x, y)| < \varepsilon$$

**Testable Prediction**: For $f(x, y) = \sin(xy)$ and $K = [1, 2]^2$, a 10-term EML-KA decomposition should achieve $\varepsilon = 0.01$.

**Evidence for the conjecture**:
1. Polynomials on $(0,\infty)^2$ have exact EML-KA decompositions (Theorem 4.1).
2. By the Stone-Weierstrass theorem, polynomials are dense in $C(K)$ for compact $K$.
3. EML chains are continuous (proved), so EML-KA decompositions are continuous.

**Potential obstacles**: The Stone-Weierstrass argument gives polynomial approximation, but the polynomial degree (and hence the number of EML-KA terms) grows with $1/\varepsilon$. A direct approximation using EML chain optimization might achieve better rates.

---

## 7. Algorithms

### 7.1 EML-KA Evaluation Algorithm

```
Input: EML-KA decomposition d with Q terms, point (x, y) ∈ (0,∞)²
Output: d(x, y)

result ← 0
for q = 1 to Q:
    u ← evalChain(d.φ₁[q], x)
    v ← evalChain(d.φ₂[q], y)
    result ← result + evalChain(d.Φ[q], u + v)
return result
```

### 7.2 EML-KA Fitting Algorithm

```
Input: Target function f, domain K, tolerance ε, max terms Q_max
Output: EML-KA decomposition approximating f on K

for Q = 1 to Q_max:
    Initialize chain parameters randomly
    Optimize: min_{params} sup_{(x,y) ∈ K} |d(x,y) - f(x,y)|
    if achieved error < ε:
        return d
return best decomposition found
```

---

## 8. Discussion

### 8.1 Connections to Neural Network Architecture

The EML-KA framework suggests a neural network architecture where:
- Input layer: log-transform positive inputs
- Hidden layers: affine transformations (standard linear layers)
- Output layer: exp-transform to decode

This "log-linear-exp" sandwich architecture naturally represents multiplicative relationships and has connections to attention mechanisms in transformers (where softmax = normalized exp).

### 8.2 Computational Complexity

The depth-3 bound for monomials implies that EML-KA evaluation can be parallelized to constant depth for any single monomial, with the total computation for an $M$-term polynomial requiring depth 3 with width $M$.

### 8.3 Limitations

1. The current results require $x, y > 0$. Extending to $\mathbb{R}^2$ requires handling the singularity of $\log$ at 0.
2. The polynomial decomposition requires $M$ terms for $M$ monomials, which may not be optimal.
3. The universality conjecture remains unproven.

---

## 9. Future Work

1. Prove or disprove the EML-KA universality conjecture.
2. Establish optimal term bounds: can $M$-monomial polynomials be decomposed with fewer than $M$ terms?
3. Extend to $n > 2$ variables and connect to the classical $2n+1$ bound.
4. Investigate the relationship between EML chain depth and approximation rate.
5. Build and train EML-KA neural networks on standard benchmarks.

---

## References

1. Kolmogorov, A. N. (1957). On the representation of continuous functions of several variables by superposition of continuous functions of one variable and addition. *Dokl. Akad. Nauk SSSR*, 114, 953-956.

2. Arnold, V. I. (1957). On functions of three variables. *Dokl. Akad. Nauk SSSR*, 114, 679-681.

3. Liu, Z., Wang, Y., Vaidya, S., et al. (2024). KAN: Kolmogorov-Arnold Networks. *arXiv:2404.19756*.

4. Sprecher, D. A. (1965). On the structure of continuous functions of several variables. *Trans. Amer. Math. Soc.*, 115, 340-355.

5. Braun, J., & Griebel, M. (2009). On a constructive proof of Kolmogorov's superposition theorem. *Constructive Approximation*, 30(3), 653-675.
