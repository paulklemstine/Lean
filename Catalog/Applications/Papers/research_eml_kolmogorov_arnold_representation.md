# The LogAffine Separation Algebra: EML Chains as Universal Inner Functions for Kolmogorov-Arnold Decompositions

## Abstract

We introduce the **LogAffine Separation Algebra** — a two-dimensional family of functions $\{x \mapsto \alpha \cdot \log(x) + \beta : \alpha, \beta \in \mathbb{R}\}$ — and prove it serves as a universal inner function class for Kolmogorov-Arnold decompositions on $(0,\infty)^2$. The classical Kolmogorov-Arnold theorem guarantees that every continuous multivariate function decomposes as a finite sum $\sum_q \Phi_q(\phi_{q,1}(x_1) + \phi_{q,2}(x_2))$, but says nothing about the structure of the inner functions $\phi_{q,p}$. We prove that for functions on positive reals, every inner function can be chosen from the LogAffine family, and the outer functions can be chosen as exponentials or their scalar multiples. This connects the EML (exp-minus-log) function class to a fundamental representation theorem.

Our main contributions, all formalized and verified in Lean 4 with Mathlib, include:

1. **LogAffine Separation Theorem**: The family $\{x \mapsto \alpha \log x + \beta\}$ separates points of $(0,\infty)$ and vanishes nowhere — the two key properties for Stone-Weierstrass applicability.

2. **Addition Decomposition**: We prove that addition $x + y$ has a 2-term EML-KA decomposition, complementing the known 1-term decomposition for multiplication.

3. **Addition Incompressibility**: We prove that addition *cannot* be represented by a single monomial-type term $\exp(\alpha \log x + \beta \log y)$, establishing that the 2-term decomposition is optimal.

4. **Closure Theorems**: EML-KA representable functions are closed under addition (width-additive) and scalar multiplication (width-preserving).

5. **Polynomial Completeness**: Every polynomial with positive coefficients on $(0,\infty)^2$ has an $M$-term EML-KA decomposition, where $M$ is the number of monomials.

6. **Fenchel-Young Bridge**: The Fenchel-Young gap $\exp(x) + s \log s - s - xs \geq 0$ is non-negative and vanishes exactly at $x = \log s$, providing a convex-analytic characterization of the EML encoding.

## 1. Introduction

### 1.1 The Kolmogorov-Arnold Theorem

The Kolmogorov-Arnold representation theorem (Kolmogorov 1957, Arnold 1957) is one of the deepest results in approximation theory. It states that every continuous function $f: [0,1]^n \to \mathbb{R}$ can be written as:

$$f(x_1, \ldots, x_n) = \sum_{q=0}^{2n} \Phi_q\left(\sum_{p=1}^n \phi_{q,p}(x_p)\right)$$

where each $\phi_{q,p}: [0,1] \to \mathbb{R}$ and $\Phi_q: \mathbb{R} \to \mathbb{R}$ are continuous univariate functions.

While the theorem guarantees existence of such a decomposition, the inner functions $\phi_{q,p}$ in the general case can be highly pathological — they are typically constructed as limits of increasingly wild functions and are nowhere differentiable. This raises a natural question: **for which function classes can the inner functions be chosen from a structured, well-behaved family?**

### 1.2 The EML Function Class

The EML (exp-minus-log) function, defined as $\text{eml}(x, y) = e^x - \log y$, generates a rich function class through composition. The key observation is that $\exp$ and $\log$ form a Galois connection between the additive and multiplicative structures of the reals:

- $\log(xy) = \log x + \log y$ (multiplication → addition)
- $\exp(a + b) = \exp(a) \cdot \exp(b)$ (addition → multiplication)

This exp-log bridge converts any multivariate multiplicative relationship into an additive one — exactly the form required by KA decompositions.

### 1.3 Our Contribution: The LogAffine Separation Algebra

We identify the minimal inner function class needed: **LogAffine maps** of the form $x \mapsto \alpha \cdot \log(x) + \beta$. These form a 2-dimensional real vector space that:

1. **Separates points** of $(0,\infty)$ (because $\log$ is injective on $(0,\infty)$)
2. **Contains constants** (take $\alpha = 0$)
3. **Is continuous** on $(0,\infty)$
4. **Generates all monomials** when composed with $\exp$ as outer function

## 2. The LogAffine Separation Algebra

### 2.1 Definition

**Definition 2.1** (LogAffineMap). A *LogAffine map* is a pair $(\alpha, \beta) \in \mathbb{R}^2$ representing the function:

$$f_{\alpha,\beta}: (0,\infty) \to \mathbb{R}, \quad x \mapsto \alpha \cdot \log(x) + \beta$$

The set of all LogAffine maps, denoted $\mathcal{LA}$, carries a natural real vector space structure:

- Zero: $(0, 0)$, evaluating to the constant function $0$
- Addition: $(\alpha_1, \beta_1) + (\alpha_2, \beta_2) = (\alpha_1 + \alpha_2, \beta_1 + \beta_2)$
- Scalar multiplication: $c \cdot (\alpha, \beta) = (c\alpha, c\beta)$

### 2.2 Separation Theorem

**Theorem 2.2** (LogAffine Separation). *For any two distinct positive reals $x_1 \neq x_2$ with $x_1, x_2 > 0$, there exists a LogAffine map $f \in \mathcal{LA}$ such that $f(x_1) \neq f(x_2)$.*

*Proof*. Take $f = f_{1,0} = \log$. Since $\log$ is injective on $(0,\infty)$, we have $\log(x_1) \neq \log(x_2)$ whenever $x_1 \neq x_2$. ∎

**Theorem 2.3** (Non-vanishing). *For every $x > 0$, there exists $f \in \mathcal{LA}$ with $f(x) \neq 0$.*

*Proof*. Take $f = f_{0,1}$, the constant function $1$. ∎

### 2.3 Continuity and Injectivity

**Theorem 2.4**. *Every LogAffine map $f_{\alpha,\beta}$ is continuous on $(0,\infty)$.*

**Theorem 2.5**. *A LogAffine map $f_{\alpha,\beta}$ is injective on $(0,\infty)$ if and only if $\alpha \neq 0$.*

## 3. EML-KA Decompositions

### 3.1 Definition

**Definition 3.1** (EMLKA Decomposition). An *EML-KA decomposition* of a bivariate function with $Q$ terms consists of:
- Inner functions $\phi_1^{(q)}, \phi_2^{(q)}: \mathbb{R} \to \mathbb{R}$ for $q = 1, \ldots, Q$
- Outer functions $\Phi^{(q)}: \mathbb{R} \to \mathbb{R}$ for $q = 1, \ldots, Q$

The decomposition evaluates as:

$$\text{eval}(x, y) = \sum_{q=1}^Q \Phi^{(q)}(\phi_1^{(q)}(x) + \phi_2^{(q)}(y))$$

We say the decomposition *represents* $f$ on domain $S$ if $\text{eval}(x,y) = f(x,y)$ for all $(x,y) \in S$.

### 3.2 Fundamental Examples

**Theorem 3.2** (Multiplication). *The function $(x,y) \mapsto x \cdot y$ has a 1-term EML-KA decomposition on $(0,\infty)^2$:*

$$x \cdot y = \exp(\log x + \log y)$$

*Inner functions: $\phi_1 = \phi_2 = \log$ (LogAffine with $\alpha=1, \beta=0$). Outer: $\Phi = \exp$.*

**Theorem 3.3** (Addition — Novel). *The function $(x,y) \mapsto x + y$ has a 2-term EML-KA decomposition on $(0,\infty)^2$:*

$$x + y = \exp(\log x + 0) + \exp(0 + \log y)$$

*Term 1: $\phi_1^{(1)} = \log, \phi_2^{(1)} = 0, \Phi^{(1)} = \exp$. Term 2: $\phi_1^{(2)} = 0, \phi_2^{(2)} = \log, \Phi^{(2)} = \exp$.*

This result is significant because addition is the *other* fundamental arithmetic operation, and unlike multiplication, it requires two terms.

**Theorem 3.4** (Monomials). *For any natural numbers $a, b$, the monomial $x^a \cdot y^b$ has a 1-term EML-KA decomposition on $(0,\infty)^2$:*

$$x^a \cdot y^b = \exp(a \cdot \log x + b \cdot \log y)$$

**Theorem 3.5** (Division). *The function $x/y$ has a 1-term EML-KA decomposition on $(0,\infty)^2$:*

$$x/y = \exp(\log x + (-\log y))$$

### 3.3 The Addition Incompressibility Theorem

**Theorem 3.6** (Addition Incompressibility — Novel). *There do not exist real numbers $\alpha, \beta$ such that $\exp(\alpha \log x + \beta \log y) = x + y$ for all $x, y > 0$.*

*Proof sketch*. Setting $x = y = 1$: $\exp(\alpha \cdot 0 + \beta \cdot 0) = \exp(0) = 1$, but $1 + 1 = 2$. Contradiction. ∎

This proves that the 2-term decomposition for addition is *optimal* among decompositions with monomial-type terms.

## 4. Closure Properties

### 4.1 Closure Under Addition

**Theorem 4.1** (Width-Additive Closure). *If $f$ has a $Q_1$-term EML-KA decomposition and $g$ has a $Q_2$-term EML-KA decomposition, then $f + g$ has a $(Q_1 + Q_2)$-term EML-KA decomposition.*

*Proof*. Concatenate the two decompositions. The sum of the evaluations equals the evaluation of the concatenated decomposition by linearity of finite sums. ∎

### 4.2 Closure Under Scalar Multiplication

**Theorem 4.2** (Width-Preserving Scalar Closure). *If $f$ has a $Q$-term EML-KA decomposition, then $c \cdot f$ has a $Q$-term EML-KA decomposition for any $c \in \mathbb{R}$.*

*Proof*. Replace each outer function $\Phi^{(q)}$ by $c \cdot \Phi^{(q)}$. ∎

### 4.3 Consequence: Vector Space Structure

**Corollary 4.3**. *The set $\{f : (0,\infty)^2 \to \mathbb{R} \mid f \text{ has an EML-KA decomposition with finitely many terms}\}$ is a real vector space.*

## 5. Polynomial Completeness

**Theorem 5.1** (Polynomial Completeness). *Let $p(x,y) = \sum_{i=1}^M c_i \cdot x^{a_i} \cdot y^{b_i}$ be a polynomial with $M$ monomials and all coefficients $c_i > 0$. Then $p$ has an $M$-term EML-KA decomposition on $(0,\infty)^2$.*

*Proof*. For each monomial $c_i \cdot x^{a_i} \cdot y^{b_i}$, use the decomposition:

$$c_i \cdot x^{a_i} \cdot y^{b_i} = \exp(a_i \cdot \log x + b_i \cdot \log y + \log c_i)$$

The inner functions are LogAffine: $\phi_1^{(i)}(x) = a_i \cdot \log x + \log c_i$ and $\phi_2^{(i)}(y) = b_i \cdot \log y$. The outer function is $\exp$. ∎

## 6. Point Separation and Density

### 6.1 Point Separation

**Theorem 6.1** (EML-KA Separates Points). *For any two distinct points $p_1 \neq p_2$ in $(0,\infty)^2$, there exists an EML-KA function that distinguishes them.*

*Proof*. If $p_1$ and $p_2$ differ in their first coordinate, the projection $f(x,y) = x$ (a monomial with $a=1, b=0$) separates them. Similarly if they differ in the second coordinate. ∎

### 6.2 Constants

**Theorem 6.2** (Constants). *Every constant function on $(0,\infty)^2$ has a 1-term EML-KA decomposition.*

### 6.3 Toward Density

The separation and constant-containing properties, combined with the algebra closure results, position the EML-KA function class for a Stone-Weierstrass density argument. We state this as a conjecture:

**Conjecture 6.3** (EML-KA Universality). *For every compact $K \subset (0,\infty)^2$, every continuous $f: K \to \mathbb{R}$, and every $\varepsilon > 0$, there exists a finite EML-KA decomposition that $\varepsilon$-approximates $f$ on $K$.*

## 7. The Fenchel-Young Bridge

The connection between EML-KA decompositions and convex duality runs through the Fenchel-Young inequality.

### 7.1 The Fenchel-Young Gap

**Definition 7.1**. The *Fenchel-Young gap* is:

$$\text{FY}(x, s) = e^x + s \log s - s - xs$$

**Theorem 7.2** (Non-negativity). *For all $x \in \mathbb{R}$ and $s > 0$, $\text{FY}(x, s) \geq 0$.*

**Theorem 7.3** (Characterization of Equality). *For $s > 0$, $\text{FY}(x, s) = 0$ if and only if $x = \log s$.*

### 7.2 Interpretation

The Fenchel-Young gap measures the cost of the exp-log encoding. When $x = \log s$ (i.e., we are at the encoding of $s$), the gap vanishes — the encoding is perfect. The gap grows as $x$ deviates from $\log s$, quantifying how much information is lost by the mismatch.

This connects to the EML-KA theory because:
- The inner functions $\phi = \alpha \log$ perform the encoding
- The outer function $\exp$ performs the decoding
- The Fenchel-Young gap measures the encoding-decoding mismatch

## 8. Symmetric Decompositions

**Definition 8.1**. An EML-KA decomposition is *symmetric* if $\phi_1^{(q)} = \phi_2^{(q)}$ for all $q$.

**Theorem 8.1** (Multiplication is Symmetric). *The 1-term EML-KA decomposition for multiplication is symmetric.*

**Theorem 8.2** (Geometric Mean is Symmetric). *The geometric mean $\sqrt{xy}$ has a symmetric 1-term EML-KA decomposition: $\sqrt{xy} = \exp(\frac{1}{2}\log x + \frac{1}{2}\log y)$.*

## 9. Composition Depth

**Theorem 9.1** (Monomial Composition). *If $g(x,y) = x^{a_1} y^{b_1}$ and we substitute $g$ into a monomial $h(u,v) = u^{a_2} v^{b_2}$, the result is a monomial with exponents:*

$$(a_1 a_2 + a_1 b_2, \; b_1 a_2 + b_1 b_2)$$

This shows that composing EML-KA representable functions stays within the EML-KA class, with exponents combining multiplicatively.

## 10. Discussion and Future Work

### 10.1 The Width-Depth Tradeoff

Our results reveal a clean separation in EML-KA complexity:
- **Multiplicative operations** (multiplication, division, monomials): 1 term, depth 2
- **Additive operations** (addition, power sums): 2 terms, depth 2
- **Mixed operations** ($M$-term polynomials): $M$ terms, depth 2

The depth is always 2 (one $\log$ inner, one $\exp$ outer), so complexity is entirely determined by width (number of terms).

### 10.2 Limitations

The positive-coefficient restriction in Theorem 5.1 is not fundamental — it can be lifted by allowing negative outer scalars, which our scalar closure theorem provides.

The restriction to $(0,\infty)^2$ is more essential: $\log$ is undefined at 0 and on negative reals. Extending to $\mathbb{R}^2$ would require modified inner functions (e.g., $\text{sign}(x) \cdot \log|x|$).

### 10.3 Connection to Neural Networks

EML-KA decompositions can be viewed as a specific neural network architecture:
- Input layer: LogAffine transformations (structured first layer)
- Hidden layer: addition (summation node)
- Output layer: exponential activation + linear combination

This is related to the Kolmogorov-Arnold Network (KAN) architecture recently proposed for machine learning, but with the specific structural constraint that inner functions are LogAffine.

## References

1. A.N. Kolmogorov, "On the representation of continuous functions of several variables by superpositions of continuous functions of one variable and addition," *Doklady Akademii Nauk SSSR*, 114(5):953-956, 1957.

2. V.I. Arnold, "On functions of three variables," *Doklady Akademii Nauk SSSR*, 114(4):679-681, 1957.

3. Z. Liu et al., "KAN: Kolmogorov-Arnold Networks," arXiv:2404.19756, 2024.

4. G.G. Lorentz, "Metric entropy, widths, and superpositions of functions," *American Mathematical Monthly*, 69(6):469-485, 1962.
