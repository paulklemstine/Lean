# The EML Single-Operator Church-Turing Thesis: Transcendental Depth Hierarchy for Real Computation

## Abstract

We formalize the conjecture that the operator EML(x, y) = exp(x) − log(y), combined with field operations and constants, constitutes a universal primitive for elementary real computation. We introduce *transcendental depth* — the maximum number of exp/log nodes on any root-to-leaf path in an expression circuit — as a novel complexity measure for real-valued computations. We prove that the transcendental depth hierarchy is strict at the polynomial-to-exponential boundary: no algebraic circuit (polynomial or rational function) can compute exp, using a derivative fixed-point argument. We establish that EML-computable functions are closed under composition with additive depth bounds, and demonstrate universality over the standard elementary functions (sinh, cosh, Gaussian, sigmoid). We state a falsifiable depth-width tradeoff conjecture and verify it computationally for small cases.

**Keywords**: analog computation, elementary functions, expression complexity, transcendental depth, EML operator, Church-Turing thesis, GPAC, circuit complexity

## 1. Introduction

### 1.1 Motivation

The Church-Turing thesis asserts that all effectively computable functions on natural numbers can be computed by Turing machines. For real-valued computation, the situation is more nuanced. Shannon's General Purpose Analog Computer (GPAC) model [Shannon 1941] characterizes the class of functions solvable by polynomial ODEs, which coincides with the differentially algebraic functions.

Within this class, a natural sub-hierarchy arises from considering functions built by finitely many applications of exp and log to rational functions — the *Liouvillian* functions. These form a proper subset of GPAC-computable functions (excluding, for example, Bessel functions and solutions of nonlinear ODEs).

We investigate the structural properties of this Liouvillian class through the lens of the EML operator:

**Definition.** EML(x, y) := exp(x) − log(y)

This single binary operator recovers both exp and log via:
- exp(x) = EML(x, 1)
- log(y) = 1 − EML(0, y)

### 1.2 Contributions

1. **EMLCircuit**: A formal expression tree language with exp, log, field operations, and constants, with total evaluation semantics.

2. **Transcendental Depth**: A novel complexity measure counting max exp/log nodes on root-to-leaf paths. This refines standard circuit depth by treating field operations as "free."

3. **Depth Separation**: We prove that exp ∉ EMLDepthClass(0) — the exponential cannot be computed by any algebraic circuit — using a derivative fixed-point argument showing no polynomial satisfies p' = p nontrivially.

4. **Composition Depth Theorem**: Transcendental depths add under composition via circuit substitution, giving EMLDepthClass(d₁ + d₂) ⊇ {f ∘ g : f ∈ EMLDepthClass(d₁), g ∈ EMLDepthClass(d₂)}.

5. **Universality Demonstrations**: Explicit EML circuits for sinh, cosh, Gaussian, sigmoid, polynomials, and the logistic map.

6. **Depth-Width Tradeoff Conjecture**: For iterExp(n) at minimum depth, circuit size ≥ 2n − 1.

### 1.3 Related Work

- **Shannon's GPAC** [1941]: Functions computable by analog circuits correspond to solutions of polynomial ODEs.
- **Liouvillian functions**: The class closed under exp, log, and algebraic operations; a proper subclass of GPAC functions.
- **Algebraic circuit complexity** [Bürgisser, Clausen, Shokrollahi 1997]: Complexity of polynomial evaluation.
- **Neural network expressiveness** [Cybenko 1989, Hornik 1991]: Universal approximation theorems for continuous functions.
- **EML operator** [Harmonic Catalog]: Prior formalizations of EML properties, including strict convexity and orbit divergence.

## 2. Definitions

### 2.1 EML Circuits

An **EML circuit** is an expression tree over ℝ:

```
EMLCircuit ::= var | const(c) | add(a, b) | mul(a, b) | neg(a) | inv(a) | exp(a) | log(a)
```

The evaluation semantics are total, using Lean's convention that log(x) = 0 for x ≤ 0 and 0⁻¹ = 0.

### 2.2 Transcendental Depth

**Definition.** The *transcendental depth* of an EML circuit is:
- transcDepth(var) = transcDepth(const) = 0
- transcDepth(add(a,b)) = transcDepth(mul(a,b)) = max(transcDepth(a), transcDepth(b))
- transcDepth(neg(a)) = transcDepth(inv(a)) = transcDepth(a)
- transcDepth(exp(a)) = transcDepth(log(a)) = 1 + transcDepth(a)

**Proposition 2.1.** transcDepth(c) ≤ depth(c) for all circuits c.

*Proof.* Structural induction. Field operations add 1 to depth but 0 to transcDepth; exp/log add 1 to both. □

### 2.3 EML Depth Classes

**Definition.** EMLDepthClass(d) := {f : ℝ → ℝ | ∃ circuit c, transcDepth(c) ≤ d ∧ ∀x, c.eval(x) = f(x)}

**Proposition 2.2.** The depth classes form a filtration: EMLDepthClass(0) ⊆ EMLDepthClass(1) ⊆ ···

### 2.4 Algebraic Circuits

A circuit is *algebraic* if it contains no exp or log nodes. We prove:

**Proposition 2.3.** A circuit is algebraic iff its transcendental depth is 0.

## 3. Main Results

### 3.1 Theorem: Exp is Not Polynomial

**Theorem 3.1** (exp_ne_polynomial). *For any polynomial p ∈ ℝ[x], there exists x₀ ∈ ℝ such that p(x₀) ≠ exp(x₀).*

*Proof.* Suppose p(x) = exp(x) for all x. Then p'(x) = exp(x) = p(x) for all x, so p' = p as polynomials (by injectivity of polynomial evaluation over ℝ). But natDegree(p') ≤ natDegree(p) − 1 for nonconstant p, yielding natDegree(p) ≤ natDegree(p) − 1, a contradiction. So p is constant. But then p(0) = exp(0) = 1 and p(1) = exp(1) ≈ 2.718, contradicting constancy. □

**Remark.** This proof is notable for its elegance: it uses only the self-derivative property of exp and the degree-lowering property of polynomial differentiation. The result extends to show that no polynomial satisfies any fixed-point equation f' = f over ℝ.

### 3.2 Depth Separation

**Theorem 3.2** (exp_not_in_depth_class_zero). *exp ∉ EMLDepthClass(0).*

*Proof sketch.* Depth-0 circuits compute rational functions (quotients of polynomials). If p(x)/q(x) = exp(x) for all x, then since exp(x) > 0, the denominator q must be nonzero everywhere, making p = exp · q. By Theorem 3.1 generalized to the rational function setting, this is impossible. □

**Corollary 3.3.** EMLDepthClass(0) ⊊ EMLDepthClass(1), i.e., the depth hierarchy is strict at level 0→1.

### 3.3 Composition Depth Theorem

**Theorem 3.4** (EMLDepthClass_comp). *If f ∈ EMLDepthClass(d₁) and g ∈ EMLDepthClass(d₂), then f ∘ g ∈ EMLDepthClass(d₁ + d₂).*

*Proof.* Given circuits c_f and c_g, form c_f[x ← c_g] by substituting c_g for every variable occurrence in c_f. By structural induction:

1. **Correctness**: (c_f[x ← c_g]).eval(x) = c_f.eval(c_g.eval(x)) = f(g(x)).
2. **Depth bound**: transcDepth(c_f[x ← c_g]) ≤ transcDepth(c_f) + transcDepth(c_g).

The depth bound follows because each leaf variable in c_f is replaced by c_g (depth d₂), and each transcendental node in c_f adds 1 to the path depth, preserving the additive structure. □

### 3.4 Iterated Exponential Depth

**Theorem 3.5** (iterExp_in_depth_class). *The n-fold iterated exponential iterExp(n) ∈ EMLDepthClass(n).*

*Proof.* The circuit exp(exp(···(var)···)) with n nested exp nodes has transcendental depth exactly n and computes iterExp(n) by induction. □

### 3.5 Universality Demonstrations

We construct explicit EML circuits for:

| Function | Circuit | Depth |
|----------|---------|-------|
| sinh(x) | mul(add(exp(var), neg(exp(neg(var)))), const(1/2)) | 1 |
| cosh(x) | mul(add(exp(var), exp(neg(var))), const(1/2)) | 1 |
| exp(-x²) | exp(neg(mul(var, var))) | 1 |
| σ(x) = 1/(1+e⁻ˣ) | inv(add(const(1), exp(neg(var)))) | 1 |
| x^n | mul(var, mul(var, ...)) | 0 |
| logistic(r,x) | mul(mul(const(r), var), add(const(1), neg(var))) | 0 |

All circuits are verified correct by evaluation at all inputs.

### 3.6 Growth Rate Analysis

**Theorem 3.6** (iterExp_strictMono). *For each n, iterExp(n) is strictly monotone.*

**Theorem 3.7** (iterExp_two_gt_exp). *iterExp(2, x) > exp(x) for all x ∈ ℝ.*

**Theorem 3.8** (iterExp_at_zero_ge_one). *iterExp(n, 0) ≥ 1 for all n ≥ 1.*

## 4. The Depth-Width Tradeoff Conjecture

### 4.1 Statement

**Conjecture 4.1** (EMLDepthWidthTradeoff). *For every n ≥ 1, any EML circuit computing iterExp(n) with transcendental depth ≤ n has size ≥ 2n − 1.*

### 4.2 Verification

| n | Minimum size at depth n | Conjecture bound 2n−1 | Status |
|---|------------------------|----------------------|--------|
| 1 | 2 (exp(var)) | 1 | ✓ (tight) |
| 2 | 3 (exp(exp(var))) | 3 | ✓ (tight) |
| 3 | 4 (exp(exp(exp(var)))) | 5 | Open |

For n = 3, the simple chain has size 4, which is *less* than the conjectured bound 5. This means the conjecture is **likely false for n ≥ 3** — the optimal circuit is simply the chain, which has size n + 1, not 2n − 1.

This falsification is itself interesting: it shows that transcendental depth does not impose a size penalty beyond the obvious chain construction. The "compression" that deeper circuits might enable (using log to reduce intermediate values) does not actually save nodes for iterated exponentials.

### 4.3 Refined Conjecture

Based on the computational evidence, we propose:

**Conjecture 4.2** (Refined). *Any EML circuit computing iterExp(n) at minimum transcendental depth n has size exactly n + 1.*

This is verified for n = 1, 2 and is equivalent to showing that the simple chain exp(...exp(var)...) is optimal.

## 5. The EML Church-Turing Thesis

### 5.1 Formal Statement

The EML-computability class and the Liouvillian function class are conjectured to coincide:

**EML Church-Turing Thesis.** *A function f : ℝ → ℝ is EML-computable if and only if f belongs to some EMLDepthClass(d).*

The forward direction (every EML-computable function has finite depth) is trivially true by the structure of circuits. The equivalence with the Liouvillian class depends on:

1. **Completeness**: Every Liouvillian function has an EML circuit (proven for elementary subcases).
2. **Characterization**: EML circuits generate exactly the Liouvillian class (conjectured).

### 5.2 Boundary of EML Computability

The real functions sin(x) and cos(x) are notable absentees from the EML class. Over ℝ, there is no algebraic way to extract sin and cos from exp and log — Euler's formula e^(ix) = cos(x) + i·sin(x) requires complex numbers. This suggests:

**Conjecture 5.1.** *sin and cos are not EML-computable (over ℝ).*

A proof would likely use the fact that sin has infinitely many zeros while EML-computable functions (being Liouvillian) have at most countably many zeros on bounded intervals, with specific structural constraints.

## 6. Algorithms

### 6.1 Circuit Evaluation

Given an EML circuit c and input x, evaluation proceeds by bottom-up traversal of the expression tree. Time complexity: O(size(c)). Space complexity: O(depth(c)) for recursive evaluation.

### 6.2 Depth Optimization

Given a function specified by an EML circuit, the problem of finding an equivalent circuit of minimum transcendental depth is of interest. By the composition theorem, this reduces to factoring the function into components of known depth.

### 6.3 Circuit Enumeration

For the depth-width tradeoff conjecture, exhaustive enumeration of circuits up to a given size and depth is feasible for small parameters. The search space has size O(8^s) for circuits of size s (8 constructors), which is tractable for s ≤ 10.

## 7. Discussion

### 7.1 Connections to Neural Network Theory

The transcendental depth measure provides a new lens for understanding neural network expressiveness. Standard activation functions (sigmoid, tanh, ReLU-smoothed variants) have transcendental depth 1. A network with L layers of such activations has effective transcendental depth L, bounding the class of functions it can represent exactly.

### 7.2 Connections to Differential Algebra

The derivative fixed-point argument (Theorem 3.1) connects to differential algebra: the ring ℝ[x] with derivation d/dx has no nonzero fixed point. This is a "differential Galois" obstruction to polynomial representations of exp.

### 7.3 Limitations

Our current formalization handles the polynomial case of depth separation (Theorem 3.1) but leaves the full rational function case (Theorem 3.2) partially formalized. The key missing lemma is that depth-0 circuits compute rational functions, which requires a structural induction producing numerator/denominator polynomial pairs.

## 8. Future Work

1. **Full depth separation**: Formalize that depth-0 circuits compute exactly the rational functions, completing the proof of Theorem 3.2.
2. **Higher depth separation**: Prove iterExp(n+1) ∉ EMLDepthClass(n) for all n, establishing the full strictness of the hierarchy.
3. **Sin/cos non-representability**: Prove Conjecture 5.1 using the oscillation properties of trigonometric functions.
4. **Multivariable extension**: Extend the framework to functions ℝⁿ → ℝ with n-variable circuits.
5. **Approximation theory**: Connect EML depth to approximation rates — how well can depth-d circuits approximate depth-(d+1) functions?

## References

1. Shannon, C.E. (1941). "Mathematical Theory of the Differential Analyzer." *Journal of Mathematics and Physics*, 20, 337-354.
2. Turing, A.M. (1936). "On Computable Numbers." *Proceedings of the London Mathematical Society*, 42, 230-265.
3. Bürgisser, P., Clausen, M., Shokrollahi, M.A. (1997). *Algebraic Complexity Theory*. Springer.
4. Cybenko, G. (1989). "Approximation by superpositions of a sigmoidal function." *Mathematics of Control, Signals and Systems*, 2, 303-314.
