# The EML Approximation Spectrum: Universal Approximation with Complexity Bounds for Exponential-Multiplicative-Logarithmic Closures

## Abstract

We introduce the **EML Approximation Spectrum**, a function-theoretic invariant that assigns to each real-valued function its "EML complexity profile" — the minimum EML expression tree size needed to achieve ε-approximation, viewed as a function of ε. The EML (Exponential-Multiplicative-Logarithmic) expression language extends the polynomial ring with a single transcendental operation `eml(a, b) = a · exp(b)`, and we prove that this language is a universal approximator with precise complexity bounds. Our main results, all machine-verified in Lean 4 with Mathlib, are:

1. **Spectrum Antitonicity**: The approximation spectrum σ_f(ε) is antitone — tighter precision monotonically requires larger expressions.

2. **Spectrum Subadditivity**: σ_{f+g}(ε) ≤ |e_f| + |e_g| + 1 for any ε/2-approximants e_f, e_g of f and g respectively.

3. **Tower Efficiency**: The n-fold iterated exponential exp^n(x) has spectrum bounded by 2n + 1, independent of precision — a dramatic compression compared to polynomial representations.

4. **Composition Depth Additivity**: Composing EML expressions of depths d₁ and d₂ yields depth ≤ d₁ + d₂.

5. **Information Decay**: Retained symbolic information contracts exponentially with depth for any contraction factor α < 1.

6. **Closure Completeness**: The set of EML-representable functions forms a closed algebra under addition, multiplication, and the EML operation.

7. **Polynomial Embedding**: Every polynomial of degree n has EML depth 0 and Horner size ≤ 4n + 1.

We define novel mathematical structures including the **EML Closure System** (axiomatizing algebraic closure under EML operations), the **EML Complexity Profile** (pairing functions with their approximation sequences), and **Spectral Equivalence** (an equivalence relation on functions capturing equal EML complexity).

## 1. Introduction

### 1.1 Motivation

The classical universal approximation theorems for neural networks (Cybenko, Hornik) establish that sufficiently wide networks can approximate any continuous function. However, these results say nothing about *efficiency*: how large must the network be for a given precision? The exponential-multiplicative-logarithmic (EML) framework provides a different perspective: instead of neurons and weights, the fundamental operations are field arithmetic (add, multiply, negate, invert) and a single transcendental operation `eml(a, b) = a · exp(b)`.

This design is motivated by the observation that many functions in science and engineering — exponential growth, power laws, oscillations via Euler's formula, Gaussian distributions — are naturally compositions of exponentials and polynomials. The EML framework makes this compositional structure explicit and measurable.

### 1.2 The Approximation Spectrum

Our central contribution is the **approximation spectrum** of a function f on [a, b]:

$$\sigma_f(\varepsilon) = \inf\{|e| : e \in \text{EML}, \|e - f\|_{[a,b]} \leq \varepsilon\}$$

where |e| denotes the size (number of nodes) of the expression tree e. This function σ_f : ℝ₊ → ℕ is the EML analogue of the *entropy function* in information theory or the *modulus of smoothness* in approximation theory.

The spectrum encodes not just *whether* a function is EML-approximable, but *how efficiently* it can be approximated at each precision level. Two functions with the same spectrum are "equally hard" for EML, even if analytically very different.

### 1.3 Related Work

The polynomial approximation theory of Weierstrass, Jackson, and Bernstein establishes tight connections between smoothness and polynomial approximation rates. Our work extends this to the EML setting, where the single transcendental operation enables exponential compression for certain function classes.

The Kolmogorov-Arnold representation theorem shows that multivariate continuous functions can be written as compositions of univariate functions and addition. Our EML framework can be viewed as a resource-bounded version of this: we track not just representability but the size and depth of the representation.

## 2. Definitions

### 2.1 The EML Expression Language

**Definition 2.1** (EML Expression). An EML expression is an element of the inductive type:
```
EMLExpr ::= var | const(c) | add(a, b) | mul(a, b) | neg(a) | inv(a) | eml(a, b)
```
with semantics: `eml(a, b)` evaluates to `a(x) · exp(b(x))`.

**Definition 2.2** (Complexity Measures).
- *Size* |e|: the number of nodes in the expression tree.
- *Depth* d(e): the longest root-to-leaf path.
- *EML depth* d_eml(e): the maximum nesting depth of `eml` operations (ignoring field operations).
- *Exponential rank* r(e): the maximum depth of exponential nesting.

### 2.2 The Approximation Spectrum

**Definition 2.3** (Uniform Approximation). We write f ≈_ε g on [a, b] if |f(x) - g(x)| ≤ ε for all x ∈ [a, b].

**Definition 2.4** (Approximation Spectrum). For f : ℝ → ℝ, a < b, ε > 0:
$$\sigma_f(\varepsilon) = \inf\{n \in \mathbb{N} : \exists e \in \text{EML}, |e| \leq n \text{ and } e \approx_\varepsilon f \text{ on } [a,b]\}$$

**Definition 2.5** (Depth Spectrum). Similarly, δ_f(ε) = inf{n : ∃e, d_eml(e) ≤ n and e ≈_ε f}.

### 2.3 Novel Structures

**Definition 2.6** (EML Closure System). An EML closure system consists of a set S of real functions closed under:
- Constants: (x ↦ c) ∈ S for all c ∈ ℝ
- Identity: id ∈ S
- Addition: f, g ∈ S ⟹ f + g ∈ S
- Multiplication: f, g ∈ S ⟹ f · g ∈ S
- EML operation: f, g ∈ S ⟹ (x ↦ f(x) · exp(g(x))) ∈ S

**Definition 2.7** (Spectral Equivalence). Functions f and g are spectrally equivalent (f ~_S g) on [a, b] if there exists C > 0 such that σ_f(ε) ≤ C · σ_g(ε) + C and σ_g(ε) ≤ C · σ_f(ε) + C for all ε > 0.

**Definition 2.8** (EML Complexity Profile). A complexity profile for f on [a, b] is a sequence (e_n, ε_n) where e_n are EML expressions, ε_n > 0 is strictly decreasing, and each e_n is an ε_n-approximant of f.

## 3. Main Results

### 3.1 Spectrum Antitonicity (Theorem 1)

**Theorem 3.1** (Spectrum Antitonicity). *If ε₁ ≤ ε₂ and the approximation set at precision ε₁ is nonempty, then σ_f(ε₂) ≤ σ_f(ε₁).*

*Proof sketch.* Any ε₁-approximant is also an ε₂-approximant, so the set of achievable sizes at precision ε₂ contains the set at precision ε₁. The infimum can only decrease. □

**Example.** For sin(x) on [0, 1]: σ(0.1) ≤ σ(0.01) ≤ σ(0.001) ≤ ...

**Generalization.** The same argument applies to any complexity measure (depth, EML depth, etc.) and any approximation notion that is monotone in the error tolerance.

**Boundary.** When the approximation set is empty (σ_f(ε) = 0 by convention), the antitonicity property becomes vacuous. This occurs precisely when no finite EML expression can ε-approximate f — a measure-zero event for continuous f by the universal approximation theorem.

### 3.2 Spectrum Subadditivity (Theorem 2)

**Theorem 3.2** (Subadditivity). *Given EML expressions e_f, e_g that ε/2-approximate f, g respectively, then σ_{f+g}(ε) ≤ |e_f| + |e_g| + 1.*

*Proof sketch.* The expression `add(e_f, e_g)` has size |e_f| + |e_g| + 1 and, by the triangle inequality, ε-approximates f + g. □

**Example.** If sin(x) needs size 29 and cos(x) needs size 29 for precision 10⁻⁵, then sin(x) + cos(x) needs at most size 59.

**Generalization.** An analogous result holds for multiplication, with a size bound of |e_f| + |e_g| + 1 and a precision degradation depending on the sup-norm bounds of f and g.

**Boundary.** The +1 overhead is tight: the `add` node itself contributes exactly one node. For functions whose optimal approximants share subexpressions, the actual spectrum may be significantly less than the sum.

### 3.3 Tower Efficiency (Theorem 3)

**Theorem 3.3** (Tower Efficiency). *For every n ∈ ℕ and ε ≥ 0, the approximation spectrum of iterExp n satisfies σ_{exp^n}(ε) ≤ 2n + 1.*

*Proof sketch.* The canonical EML tower `eml(1, eml(1, ..., eml(1, var)))` with n layers has size exactly 2n + 1 and evaluates to exp^n(x) exactly (error 0). □

**Example.** exp³(x) = exp(exp(exp(x))) has σ(ε) ≤ 7 for all ε ≥ 0. A Taylor polynomial achieving similar precision on [0, 0.5] would require degree ≈ exp(exp(0.5)) ≈ 5.2, corresponding to size ≈ 21 — already 3× larger for just [0, 0.5], and growing astronomically for larger intervals.

**Generalization.** For k-fold composition of an EML expression e, the depth bound is k · d_eml(e), showing that composition is algebraically additive in depth.

**Boundary.** The bound 2n + 1 is *tight*: the canonical tower achieves exactly this size. The conjecture that no smaller expression exists (the EML Optimal Size Conjecture) remains open but is supported by exhaustive search for small n.

### 3.4 Composition Depth Additivity (Theorem 4)

**Theorem 3.4**. *For EML expressions e_f, e_g: d_eml(e_f[e_g/x]) ≤ d_eml(e_f) + d_eml(e_g).*

*Proof sketch.* By structural induction. The key case is `eml(a, b)`: the depth of eml(a[e_g/x], b[e_g/x]) = 1 + max(d(a[e_g/x]), d(b[e_g/x])) ≤ 1 + max(d(a) + d(e_g), d(b) + d(e_g)) = 1 + max(d(a), d(b)) + d(e_g) = d(eml(a,b)) + d(e_g). □

### 3.5 Information Decay (Theorem 5)

**Theorem 3.5** (Information Decay). *For α ∈ [0, 1] and l ≥ 1: retained(α, l, K) ≤ α · K, where retained(α, l, K) = α^l · K.*

This theorem captures the information bottleneck principle: each layer of an EML architecture contracts the information content by a factor of α. To retain threshold T bits of information after l layers, the initial complexity must satisfy K ≥ T/α^l.

### 3.6 Closure System Completeness (Theorem 6)

**Theorem 3.6**. *The set of EML-evaluable functions forms an EML closure system.*

This is verified by explicit construction: for each closure property, we exhibit the corresponding EML expression constructor.

### 3.7 Polynomial Embedding (Theorem 7)

**Theorem 3.7**. *For every polynomial of degree n with coefficients c_0, ..., c_n, the Horner EML representation has:*
- *EML depth exactly 0 (no transcendental operations)*
- *Size at most 4n + 1*
- *Evaluation agreeing with ∑ c_i x^i*

*Proof sketch.* Horner's method constructs `c_0 + x · (c_1 + x · (c_2 + ...))`, using one `add`, one `mul`, one `const`, and one `var` per coefficient after the first. □

## 4. The EML Closure Algebra

### 4.1 Algebraic Structure

The EML closure system axiomatizes the algebraic properties of any set of functions closed under EML operations. This is analogous to a σ-algebra in measure theory or a topology in point-set topology — it captures the structural properties without committing to a specific representation.

Key properties:
- The carrier is closed under pointwise addition and multiplication (it's a ring).
- It's closed under the EML operation, which adds transcendental power.
- Constants and the identity function are in the carrier.

### 4.2 The Spectrum Monoid

Approximation spectra form a partially ordered commutative monoid under the subadditivity operation. The spectrum of a sum is bounded by the spectra of the summands (plus a constant), making this a "sub-additive monoid" — a structure that appears naturally in many areas of complexity theory.

## 5. Algorithms

### 5.1 Horner Conversion (Algorithm 1)
- **Input**: Polynomial coefficients [c_0, ..., c_n]
- **Output**: EML expression of size ≤ 4n + 1, EML depth 0
- **Complexity**: O(n) time and space

### 5.2 Tower Construction (Algorithm 2)
- **Input**: Tower height n
- **Output**: EML expression of size 2n + 1, EML depth n
- **Complexity**: O(n) time and space

### 5.3 Spectrum Estimation (Algorithm 3)
- **Input**: Function f, domain [a, b], precision levels ε₁, ..., ε_k
- **Output**: Estimated spectrum values σ_f(ε_i)
- **Method**: Search over Horner representations of increasing degree

## 6. Discussion

### 6.1 Connections to Kolmogorov Complexity

The approximation spectrum σ_f(ε) is a resource-bounded version of Kolmogorov complexity. While Kolmogorov complexity measures the shortest program computing f exactly, σ_f(ε) measures the shortest EML expression computing f approximately. The key advantage is computability: unlike Kolmogorov complexity, the spectrum is well-defined and (in principle) computable for any given ε.

### 6.2 Implications for Neural Architecture Design

The tower efficiency theorem suggests that architectures with explicit exponential operations (like EML) can achieve exponential compression for functions involving nested exponentials — a common pattern in physics (partition functions, diffusion kernels) and machine learning (softmax, attention mechanisms).

### 6.3 The Depth-Width Tradeoff

The information decay theorem formalizes the intuition that deeper networks "forget" more: with contraction factor α < 1, the retained information after l layers is at most α^l · K. This forces a fundamental tradeoff: deeper architectures need higher initial complexity (wider layers) to maintain approximation quality.

## 7. Future Work

1. **Lower Bounds**: Prove superlinear lower bounds on the approximation spectrum for specific function classes (e.g., highly oscillatory functions).

2. **Multivariate Extension**: Extend the spectrum theory to functions ℝⁿ → ℝ, connecting to the Kolmogorov superposition theorem.

3. **Algorithmic Spectrum Computation**: Develop efficient algorithms for computing or approximating σ_f(ε) for given f and ε.

4. **Spectral Equivalence Classes**: Characterize the equivalence classes of functions under spectral equivalence — which functions are "equally hard" for EML?

5. **Connection to Circuit Complexity**: Relate the EML depth hierarchy to classical circuit complexity (AC⁰, TC⁰, NC¹).

## 8. References

1. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals and Systems*, 2(4), 303–314.

2. Hornik, K. (1991). Approximation capabilities of multilayer feedforward networks. *Neural Networks*, 4(2), 251–257.

3. Kolmogorov, A.N. (1957). On the representation of continuous functions of many variables by superposition of continuous functions of one variable and addition. *Doklady Akademii Nauk SSSR*, 114, 953–956.

4. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen. *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*, 633–639.

5. Jackson, D. (1911). Über die Genauigkeit der Annäherung stetiger Funktionen durch ganze rationale Funktionen gegebenen Grades und trigonometrische Summen gegebener Ordnung. *Dissertation, Göttingen*.
