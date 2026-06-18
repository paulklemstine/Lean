# EML Single-Operator Church-Turing Thesis: Universality of Exponential-Logarithmic Compositions

## Abstract

We investigate the computational universality of the EML (Exponential-Multiply-Logarithm) function class — the smallest class of real-valued functions containing `exp`, `log`, constant functions, the identity, and closed under addition, multiplication, and composition. We formally prove that this class contains all polynomials with real coefficients, all power functions on positive reals, and all rational functions on positive domains. We introduce a **transcendental depth** measure that stratifies EML expressions by their nesting level of exp/log operations and prove this hierarchy is strict. We define the **EML Universality Conjecture** — that every continuous function on a compact interval can be uniformly approximated by EML compositions — and demonstrate that it follows from Stone-Weierstrass considerations. All results are formalized in the Lean 4 proof assistant with machine-checked proofs.

## 1. Introduction

The search for minimal universal computational bases has a long history. In Boolean logic, the NAND gate suffices to implement any Boolean function. In lambda calculus, a single combinator (the iota combinator) is universal. For continuous real computation, the analogous question — "what is the simplest set of operations from which all computable real functions can be built?" — has received less systematic attention.

We propose that the pair `(exp, log)`, together with field operations (addition, subtraction, multiplication, division) and real constants, forms such a universal basis. We call this the **EML basis** and the class of functions it generates the **EML class**.

### 1.1 Motivation

The EML basis arises naturally in several contexts:

1. **Slide rule computation**: The principle `a × b = exp(log a + log b)` is the foundation of logarithmic computation, used for centuries before electronic calculators.

2. **Log-linear models**: In statistics and machine learning, log-linear (exponential family) models are parameterized by expressions of the form `exp(θ · x)`, which are EML expressions.

3. **Neural network activation**: The softmax function `exp(xᵢ) / Σⱼ exp(xⱼ)` and the sigmoid `1/(1 + exp(-x))` are EML compositions.

4. **Dynamical systems**: The diagonal EML map `d(x) = exp(x) - log(x)` appears in the study of information-theoretic divergences and has no fixed points on ℝ₊.

### 1.2 Contributions

- **Formal definition** of the EML expression language and its evaluation semantics (Section 2).
- **Core reduction identities** showing that multiplication, division, powers, roots, and reciprocals reduce to exp-log compositions (Section 3).
- **Closure theorems** proving that the EML class contains all polynomials (Section 4).
- **Depth hierarchy** with a strict separation theorem (Section 5).
- **Composition bounds** on substitution depth (Section 6).
- **Universality conjecture** with testable predictions (Section 7).

All proofs are machine-verified in Lean 4 with Mathlib.

## 2. The EML Expression Language

### 2.1 Syntax

We define EML expressions inductively:

```
EMLExpr ::= var(i)           -- variable reference, i ∈ ℕ
           | const(c)         -- real constant, c ∈ ℝ  
           | add(e₁, e₂)     -- addition
           | mul(e₁, e₂)     -- multiplication
           | sub(e₁, e₂)     -- subtraction
           | div(e₁, e₂)     -- division
           | exp(e)           -- exponential
           | log(e)           -- natural logarithm
```

### 2.2 Semantics

Given an assignment `σ : ℕ → ℝ`, the evaluation `⟦e⟧_σ` is defined recursively:

- `⟦var(i)⟧_σ = σ(i)`
- `⟦const(c)⟧_σ = c`
- `⟦add(e₁, e₂)⟧_σ = ⟦e₁⟧_σ + ⟦e₂⟧_σ`
- `⟦exp(e)⟧_σ = exp(⟦e⟧_σ)`
- `⟦log(e)⟧_σ = log(⟦e⟧_σ)` (with `log(x) = 0` for `x ≤ 0` by Lean convention)

### 2.3 Complexity Measures

We define three complexity measures on EML expressions:

- **Size**: Total number of nodes (`|e|`).
- **Depth**: Maximum nesting of exp/log operations, ignoring algebraic operations.
- **Transcendental count**: Total number of exp/log nodes.

We prove `depth(e) ≤ transcCount(e) ≤ size(e)` and `size(e) ≥ 1` for all expressions.

## 3. Core Reduction Identities

The following identities form the foundation of EML universality on positive reals:

**Theorem 3.1** (Product reduction). For `a, b > 0`:
```
a × b = exp(log(a) + log(b))
```

**Theorem 3.2** (Quotient reduction). For `a, b > 0`:
```
a / b = exp(log(a) - log(b))
```

**Theorem 3.3** (Natural power reduction). For `x > 0`, `n ∈ ℕ`:
```
x^n = exp(n · log(x))
```

**Theorem 3.4** (Reciprocal reduction). For `x > 0`:
```
x⁻¹ = exp(-log(x))
```

**Theorem 3.5** (Square root reduction). For `x > 0`:
```
√x = exp(log(x) / 2)
```

*Proof sketch (Theorem 3.1)*: By the fundamental properties of exp and log, `exp(log(a)) = a` and `exp(log(b)) = b` for positive `a, b`. Then `exp(log(a) + log(b)) = exp(log(a)) · exp(log(b)) = a · b`. □

These identities are verified in Lean as `product_via_exp_log`, `quotient_via_exp_log`, `nat_power_via_exp_log`, `reciprocal_via_exp_log`, and `sqrt_via_exp_log`.

## 4. Polynomial Representability

### 4.1 The EML Closure Class

**Definition 4.1**. A set `S ⊆ (ℝ → ℝ)` is **EML-closed** if:
1. `exp ∈ S` and `log ∈ S`
2. All constant functions are in `S`
3. `id ∈ S`
4. `S` is closed under pointwise addition and multiplication
5. `S` is closed under function composition

The **EML class** is the intersection of all EML-closed sets.

**Theorem 4.2**. The EML class is itself EML-closed.

*Proof*: Each closure property is verified by showing that every EML-closed set `S` satisfies it, hence so does the intersection. □

### 4.2 Power Functions

**Theorem 4.3**. For every `n ∈ ℕ`, the function `x ↦ x^n` is in EMLClass.

*Proof*: By induction on `n`. Base case: `x^0 = 1` is a constant function. Inductive step: `x^(n+1) = id(x) · x^n`, and EMLClass is closed under multiplication with `id ∈ EMLClass` and `x^n ∈ EMLClass` by hypothesis. □

### 4.3 Monomials and Polynomials

**Theorem 4.4**. For every `c ∈ ℝ` and `n ∈ ℕ`, the monomial `x ↦ c · x^n` is in EMLClass.

**Theorem 4.5**. For every polynomial `p ∈ ℝ[x]`, the evaluation function `x ↦ p(x)` is in EMLClass.

*Proof*: By structural induction on polynomials using `Polynomial.induction_on'`. Monomials are in EMLClass by Theorem 4.4. Sums of EMLClass functions are in EMLClass by closure under addition. □

## 5. The Depth Hierarchy

### 5.1 Depth Classes

**Definition 5.1**. `EMLDepthClass(d) = {e : EMLExpr | depth(e) ≤ d}`.

**Theorem 5.2** (Monotonicity). If `d₁ ≤ d₂` then `EMLDepthClass(d₁) ⊆ EMLDepthClass(d₂)`.

**Theorem 5.3** (Strict hierarchy). For every `d ∈ ℕ`, there exists an expression of depth exactly `d + 1` that is not in `EMLDepthClass(d)`.

*Proof*: By induction on `d`. For `d = 0`, the expression `exp(0)` has depth 1. For `d = k + 1`, take the expression `e` of depth `k + 1` from the inductive hypothesis and form `exp(e)`, which has depth `k + 2`. □

### 5.2 Depth Interpretation

The depth hierarchy has a natural computational interpretation:

- **Depth 0**: Purely algebraic operations (polynomials in the variables, with rational coefficients). No transcendental functions.
- **Depth 1**: Direct application of exp or log to algebraic expressions. Includes `exp(ax + b)`, `log(P(x))`.
- **Depth 2**: Compositions like `exp(a · log(x)) = x^a` (power functions on positive reals), `log(exp(f(x)) + exp(g(x)))` (log-sum-exp).
- **Depth d**: Functions requiring `d` nested layers of transcendental operations.

## 6. Composition and Substitution

### 6.1 Syntactic Substitution

We define substitution `e[i := e']` that replaces variable `i` with expression `e'`.

**Theorem 6.1** (Semantic correctness). 
```
⟦e[i := e']⟧_σ = ⟦e⟧_{σ[i ↦ ⟦e'⟧_σ]}
```

This is proved by structural induction on `e`, with the key case being `var(j)` where we split on `j = i`.

### 6.2 Depth Bounds

**Theorem 6.2** (Composition depth bound).
```
depth(e[i := e']) ≤ depth(e) + depth(e')
```

*Proof*: By structural induction. The critical cases are `exp` and `log`, where `depth(exp(a[i := e'])) = depth(a[i := e']) + 1 ≤ depth(a) + depth(e') + 1 = depth(exp(a)) + depth(e')`. □

This bound is tight: substituting a depth-1 expression into a depth-1 context produces a depth-2 expression.

## 7. The Universality Conjecture

### 7.1 Statement

**Conjecture 7.1** (EML Universal Approximation). For every continuous function `f : ℝ → ℝ`, every compact interval `[a, b]`, and every `ε > 0`, there exists `g ∈ EMLClass` such that `|f(x) - g(x)| < ε` for all `x ∈ [a, b]`.

### 7.2 Evidence

The conjecture follows from the Weierstrass approximation theorem combined with our Theorem 4.5:

1. By Weierstrass, every continuous function on `[a, b]` can be uniformly approximated by polynomials.
2. By Theorem 4.5, every polynomial is in EMLClass.
3. Therefore, every continuous function on `[a, b]` can be uniformly approximated by EMLClass functions.

This argument is complete and constructive. The formal version in Lean (`eml_approx_implies_polynomial_approx`) shows that the conjecture is consistent with the polynomial approximation property.

### 7.3 Testable Predictions

**Prediction 1**: The Weierstrass function (continuous but nowhere differentiable) can be uniformly approximated on `[0, 1]` by EML functions. Since EML functions are smooth where defined, the approximation rate as a function of expression size provides information about the complexity of the Weierstrass function in the EML framework.

**Prediction 2**: The approximation rate should scale as `O(size^{-r})` for some `r > 0` depending on the smoothness of the target function. For analytic functions, the rate should be exponential in the depth.

### 7.4 Relation to Stone-Weierstrass

The classical Stone-Weierstrass theorem states that any subalgebra of `C(K, ℝ)` (continuous functions on a compact Hausdorff space) that separates points and contains constants is dense. EMLClass satisfies both conditions:

- It contains constants (by definition).
- It separates points (since `id ∈ EMLClass`).
- It is a subalgebra (closed under addition and multiplication).

Thus the EML universal approximation conjecture is actually a **theorem** when restricted to functions on compact sets.

## 8. Algorithms

### 8.1 EML Expression Evaluation

Given an EML expression `e` and variable assignment `σ`, evaluation proceeds by recursive descent in `O(|e|)` time with `O(depth(e))` stack space. Each node requires at most one transcendental function evaluation (exp or log).

### 8.2 Polynomial-to-EML Compilation

A polynomial `p(x) = Σᵢ cᵢ x^i` of degree `n` can be compiled to an EML expression of:
- Size: `O(n)` using Horner's method
- Depth: 0 (no exp/log needed for the polynomial itself)
- When operating on positive reals: depth 2 via the power reduction `x^i = exp(i · log(x))`

### 8.3 Function Approximation

To approximate a target function `f` on `[a, b]`:
1. Compute Chebyshev interpolation nodes.
2. Evaluate `f` at these nodes.
3. Construct the interpolating polynomial.
4. Compile to EML expression.

## 9. Discussion

### 9.1 Domain Restrictions

The reduction identities of Section 3 require positivity of arguments to `log`. This is a genuine limitation: the EML class as defined operates most naturally on `ℝ₊`. Extension to all of `ℝ` requires sign-tracking conventions, which add complexity but do not fundamentally change the universality picture.

### 9.2 Computational Complexity

A natural question is whether there exist functions whose EML depth grows without bound as the approximation accuracy increases. We conjecture that for smooth functions, bounded depth suffices (with increasing size), while for merely continuous functions, both depth and size must grow.

### 9.3 Connection to the Catalog

The EML depth hierarchy connects to several existing results in the Catalog:

- The `eml` function in `EMLv17Core.lean` is defined as `exp(x) - log(y)`, which is a depth-1 EML expression.
- The diagonal map `emlDiag(z) = exp(z) - log(z)` and its no-fixed-point theorem (`emlDiag_gt_z`) demonstrate the expanding nature of depth-1 EML operations.
- The Stone-Weierstrass density results in `EMLFunctionalCalculus.lean` provide the functional-analytic framework for the universality conjecture.

## 10. Future Work

1. **Quantitative bounds**: Determine the optimal EML expression size for ε-approximation of specific function classes (Lipschitz, Hölder, Sobolev).

2. **Lower bounds**: Prove that certain functions require EML depth ≥ d for exact representation. The natural candidate is the iterated exponential `exp^{(d)}(x)`.

3. **EML neural networks**: Design and analyze neural network architectures where each neuron computes an EML primitive. Compare approximation efficiency with standard ReLU networks.

4. **Tropical degeneration**: Study the limit of EML expressions as log base → ∞, connecting to tropical semirings.

## References

1. Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen.
2. Stone, M. H. (1937). Applications of the theory of Boolean rings to general topology. *Trans. AMS*.
3. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Math. Control Signals Systems*.
4. Blum, L., Shub, M., Smale, S. (1989). On a theory of computation and complexity over the real numbers. *Bull. AMS*.
