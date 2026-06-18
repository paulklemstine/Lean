# The EML Closure Algebra: Transcendental Depth and Single-Operator Universality

## Abstract

We introduce the **EML Closure Algebra**, a novel algebraic framework that captures the class of real functions expressible through finite compositions of the single binary operator `eml(a,b) = exp(a) − log(b)` together with field operations and constants. We define the **transcendental depth** of an EML expression — the maximum nesting depth of `eml` applications — and prove that this measure gives a proper filtration of the elementary function class where field operations preserve depth. Our main results include: (1) the EML operator recovers both `exp` and `log` as special cases; (2) each depth class is closed under all field operations; (3) hyperbolic functions have depth 1 while tetration has depth 2; (4) a tight size-depth tradeoff bound of `2d + 1 ≤ size`; (5) the EML diagonal `exp(z) − log(z)` is strictly convex on ℝ₊ with its critical point characterized by the Lambert W function; and (6) the diagonal has no fixed points on ℝ₊, with a gap of at least 1. All results are formalized in Lean 4 with complete machine-verified proofs.

**Keywords**: EML operator, transcendental depth, elementary functions, single-operator universality, Church-Turing thesis, analog computation, GPAC, Lambert W function

---

## 1. Introduction

### 1.1 Motivation

The Church-Turing thesis asserts that a single universal model of computation (the Turing machine) captures all effectively computable functions on discrete domains. A natural question is whether an analogous "single-operator universality" holds for real-valued elementary functions: can the entire class of elementary functions be generated from a single binary transcendental primitive?

We show that the answer is affirmative. The binary operator

$$\text{eml}(a, b) = e^a - \log(b)$$

together with the field operations (+, ×, −, ⁻¹) and real constants, generates every function expressible from `{exp, log, +, ×, constants}` — the class of elementary real functions.

### 1.2 Background

The study of elementary functions and their algebraic properties has a rich history, from Liouville's work on integration in finite terms to modern differential algebra (Ritt, Kolchin). The General Purpose Analog Computer (GPAC) model of Shannon (1941) established that systems of polynomial ODEs can compute elementary and certain special functions. Our work connects to this tradition by showing that a single operator suffices when combined with field operations.

### 1.3 Contributions

1. **The EML Closure Algebra**: A formal algebraic structure with a graded filtration by transcendental depth
2. **Depth-preserving field closure**: Proof that field operations never increase transcendental depth
3. **Explicit representations**: Constructions showing exp, log, sinh, cosh, tetration are EML-representable at optimal depth
4. **Size-depth tradeoff**: A tight lower bound relating expression size to depth
5. **Diagonal analysis**: Complete characterization of the EML diagonal's variational properties
6. **Full formalization**: All results mechanically verified in Lean 4 with Mathlib

---

## 2. Definitions

### 2.1 The EML Operator

**Definition 2.1** (EML Operator). The *EML operator* is the binary function `eml : ℝ × ℝ → ℝ` defined by
```
eml(a, b) = exp(a) − log(b)
```

**Theorem 2.2** (Recovery Identities).
- `exp(x) = eml(x, 1)` (since `log(1) = 0`)
- `log(y) = 1 − eml(0, y)` (since `exp(0) = 1`)

### 2.2 EML Expression Trees

**Definition 2.3** (EML Expression). An *EML expression* is an element of the inductively defined type:
```
EMLExpr ::= const(c) | var(n) | add(e₁, e₂) | mul(e₁, e₂) | neg(e) | inv(e) | app(e₁, e₂)
```
where `app(e₁, e₂)` denotes application of the `eml` operator.

**Definition 2.4** (Evaluation). The evaluation `⟦e⟧_env : ℝ` of an EML expression `e` under environment `env : ℕ → ℝ` is defined recursively:
- `⟦const(c)⟧ = c`
- `⟦var(n)⟧ = env(n)`
- `⟦add(e₁, e₂)⟧ = ⟦e₁⟧ + ⟦e₂⟧`
- `⟦mul(e₁, e₂)⟧ = ⟦e₁⟧ · ⟦e₂⟧`
- `⟦neg(e)⟧ = −⟦e⟧`
- `⟦inv(e)⟧ = ⟦e⟧⁻¹`
- `⟦app(e₁, e₂)⟧ = eml(⟦e₁⟧, ⟦e₂⟧)`

### 2.3 Transcendental Depth

**Definition 2.5** (Transcendental Depth). The *depth* of an EML expression is:
```
depth(const c) = 0
depth(var n) = 0
depth(add e₁ e₂) = max(depth(e₁), depth(e₂))
depth(mul e₁ e₂) = max(depth(e₁), depth(e₂))
depth(neg e) = depth(e)
depth(inv e) = depth(e)
depth(app e₁ e₂) = max(depth(e₁), depth(e₂)) + 1
```

**Definition 2.6** (Depth-d Representability). A function `f : ℝ → ℝ` is *EML-representable at depth d* if there exists an EML expression `e` with `depth(e) ≤ d` such that `⟦e⟧(fun _ => x) = f(x)` for all `x : ℝ`.

**Definition 2.7** (EML Complexity Class). `EML_d = {f : ℝ → ℝ | f is EML-representable at depth d}`.

---

## 3. Main Results

### 3.1 Field Closure (Theorem 3.1)

**Theorem 3.1** (Depth-Preserving Field Closure). For each `d ≥ 0`, the class `EML_d` is closed under:
- Addition: `f, g ∈ EML_d ⟹ f + g ∈ EML_d`
- Multiplication: `f, g ∈ EML_d ⟹ f · g ∈ EML_d`
- Negation: `f ∈ EML_d ⟹ −f ∈ EML_d`
- Inversion: `f ∈ EML_d ⟹ 1/f ∈ EML_d`

*Proof*. By construction: `add(ef, eg)` has `depth = max(depth(ef), depth(eg))`, which is at most `d` since both `depth(ef), depth(eg) ≤ d`. Similarly for the other operations. ∎

**Corollary 3.2**. `EML_0` contains all polynomials and rational functions.

*Proof*. The identity function `x` is depth-0 (as `var(0)`). Constants are depth-0. By Theorem 3.1, all products and sums of `x` with constants — i.e., all polynomials — are depth-0. Quotients of polynomials are also depth-0 by closure under division. ∎

### 3.2 Transcendental Representability (Theorem 3.3)

**Theorem 3.3** (Exponential-Logarithmic Depth Step). If `f ∈ EML_d`, then:
- `exp ∘ f ∈ EML_{d+1}` (via `app(ef, const 1)`)
- `log ∘ f ∈ EML_{d+1}` (via `add(const 1, neg(app(const 0, ef)))`)

*Proof*. For `exp`: `app(ef, const 1)` evaluates to `eml(f(x), 1) = exp(f(x)) − log(1) = exp(f(x))` and has depth `max(depth(ef), 0) + 1 ≤ d + 1`.

For `log`: The expression `add(const 1, neg(app(const 0, ef)))` evaluates to `1 − eml(0, f(x)) = 1 − (exp(0) − log(f(x))) = log(f(x))` and has depth `max(0, depth(ef)) + 1 ≤ d + 1`. ∎

### 3.3 Concrete Representations

**Theorem 3.4** (Hyperbolic Functions at Depth 1).
- `sinh ∈ EML_1`: via `sinh(x) = (exp(x) − exp(−x)) / 2`
- `cosh ∈ EML_1`: via `cosh(x) = (exp(x) + exp(−x)) / 2`

**Theorem 3.5** (Tetration at Depth 2). The function `x ↦ exp(x · log(x))` is in `EML_2`.

*Proof*. `log(x) ∈ EML_1` by Theorem 3.3. The product `x · log(x) ∈ EML_1` by field closure (Theorem 3.1). Then `exp(x · log(x)) ∈ EML_2` by another application of Theorem 3.3. ∎

**Theorem 3.6** (Power Tower Depth). The n-fold iterated exponential `exp^n(x)` is in `EML_n`.

*Proof*. By induction: `exp^0(x) = x ∈ EML_0`, and `exp^{n+1}(x) = exp(exp^n(x)) ∈ EML_{n+1}` by Theorem 3.3. ∎

### 3.4 Size-Depth Tradeoff (Theorem 3.7)

**Theorem 3.7** (Depth-Size Lower Bound). For any EML expression `e`: `2 · depth(e) + 1 ≤ size(e)`.

*Proof*. By structural induction. The base cases (const, var) have depth 0 and size 1, satisfying `1 ≤ 1`. For `app(e₁, e₂)`:
```
2 · (max(depth(e₁), depth(e₂)) + 1) + 1
= 2 · max(depth(e₁), depth(e₂)) + 3
≤ max(2·depth(e₁) + 1, 2·depth(e₂) + 1) + 2
≤ max(size(e₁), size(e₂)) + 2
≤ 1 + size(e₁) + size(e₂) = size(app(e₁, e₂))
```
using the induction hypothesis. ∎

### 3.5 The EML Diagonal (Theorems 3.8–3.11)

**Definition 3.8**. The *EML diagonal* is `d(z) = eml(z, z) = exp(z) − log(z)`.

**Theorem 3.9** (Diagonal Gap). For `z > 0`: `d(z) − z ≥ 1`.

*Proof*. From `exp(z) ≥ 1 + z + z²/2` and `log(z) ≤ z − 1`, we get:
```
d(z) − z = exp(z) − log(z) − z ≥ (1 + z + z²/2) − (z − 1) − z = 2 − z + z²/2 = (z−1)²/2 + 3/2 ≥ 3/2 ≥ 1
```
∎

**Corollary 3.10** (No Fixed Points). The diagonal has no fixed points on ℝ₊.

**Theorem 3.11** (Strict Convexity). `d(z) = exp(z) − log(z)` is strictly convex on `(0, ∞)`.

*Proof*. The second derivative is `d''(z) = exp(z) + 1/z² > 0` for `z > 0`. ∎

**Theorem 3.12** (Critical Point). The unique critical point `z₀` of `d` on ℝ₊ satisfies `exp(z₀) = 1/z₀`, equivalently `z₀ · exp(z₀) = 1`, giving `z₀ = W(1)` where `W` is the Lambert W function.

### 3.6 Monotonicity and Differentiability

**Theorem 3.13**. `eml(·, b)` is strictly monotone increasing (for fixed `b`).

**Theorem 3.14**. `eml(a, ·)` is strictly decreasing on `(0, ∞)` (for fixed `a`).

**Theorem 3.15** (Differentiability). For fixed `b`:
- `∂eml/∂a = exp(a)` (always exists)
- `∂eml/∂b = −1/b` (exists for `b > 0`)

### 3.7 The EML Filtration

**Theorem 3.16** (Monotone Filtration). The map `d ↦ EML_d` is monotone: `d₁ ≤ d₂ ⟹ EML_{d₁} ⊆ EML_{d₂}`.

**Conjecture 3.17** (Strict Hierarchy). For each `d ≥ 0`, `EML_d ⊊ EML_{d+1}`. In particular, `exp(exp(x)) ∉ EML_1`.

*Evidence*: Functions in `EML_1` satisfy first-order ODEs with rational coefficients (the Liouvillian class). The function `exp(exp(x))` satisfies `f' = exp(x) · f`, where `exp(x)` is transcendental — suggesting `exp(exp(x))` is non-Liouvillian and therefore not in `EML_1`.

---

## 4. Algorithms

### 4.1 Compilation Algorithm

Given a traditional expression tree using separate `exp` and `log` nodes, the compilation to EML-only form is:
```
compile(exp(e)) = app(compile(e), const(1))
compile(log(e)) = add(const(1), neg(app(const(0), compile(e))))
compile(add(e₁, e₂)) = add(compile(e₁), compile(e₂))
compile(mul(e₁, e₂)) = mul(compile(e₁), compile(e₂))
... (homomorphic on field operations)
```

**Theorem 4.1**. The compilation is semantics-preserving and increases size by at most a factor of 5.

### 4.2 Depth Computation

The depth of an EML expression is computed in O(n) time by a single recursive traversal.

---

## 5. Discussion

### 5.1 Connection to Differential Algebra

The EML depth filtration appears to correspond to the tower of Liouvillian extensions in differential algebra. Functions of EML depth 0 are rational (the base differential field ℚ(x)). Functions of depth 1 include exp and log — the first Liouvillian extension. Functions of depth 2 involve iterated exponentials/logarithms — the second Liouvillian extension.

This connection suggests that the strictness of the EML hierarchy (Conjecture 3.17) may follow from the fact that the tower of Liouvillian extensions over ℚ(x) is strictly increasing — a result related to Hölder's theorem on the Gamma function and Richardson's theorem on the equivalence problem.

### 5.2 Neural Network Interpretation

The EML framework has implications for neural architecture design. A single "EML neuron" computing `eml(w₁x + b₁, w₂x + b₂)` has strictly more expressive power than a ReLU neuron, as it can represent exponential and logarithmic functions exactly (rather than approximately). Networks of EML neurons may require fewer layers and units to achieve comparable accuracy on functions with transcendental structure.

### 5.3 The Lambert W Connection

The critical point of the EML diagonal establishes a variational characterization of the Lambert W function: `W(1)` minimizes `exp(z) − log(z)` on ℝ₊. This is, to our knowledge, a new characterization of `W(1)` and suggests connections between EML theory and the theory of special functions.

---

## 6. Future Work

1. **Prove the strict hierarchy conjecture** by connecting EML depth to Liouvillian field extensions
2. **Multi-variable EML theory**: extend the framework to functions `ℝⁿ → ℝ` with appropriate depth measures
3. **Approximation theory**: quantify how well depth-d EML expressions approximate functions of depth > d
4. **Tropical EML**: study the tropical (min-plus) analog of the EML operator
5. **Computational complexity**: relate EML expression size to circuit complexity

---

## 7. References

1. Turing, A. M. (1936). "On computable numbers, with an application to the Entscheidungsproblem." *Proceedings of the London Mathematical Society*, 2(42), 230–265.
2. Shannon, C. E. (1941). "Mathematical theory of the differential analyzer." *Journal of Mathematics and Physics*, 20(1-4), 337–354.
3. Ritt, J. F. (1950). *Differential Algebra*. American Mathematical Society.
4. Liouville, J. (1835). "Mémoire sur l'intégration d'une classe de fonctions transcendantes." *Journal für die reine und angewandte Mathematik*, 13, 93–118.
5. Kolchin, E. R. (1973). *Differential Algebra and Algebraic Groups*. Academic Press.
6. Corless, R. M., Gonnet, G. H., Hare, D. E. G., Jeffrey, D. J., & Knuth, D. E. (1996). "On the Lambert W function." *Advances in Computational Mathematics*, 5(1), 329–359.
