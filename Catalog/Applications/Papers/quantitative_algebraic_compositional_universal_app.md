# Quantitative Algebraic-Compositional Universal Approximation for EML Networks under Finite Products and Max-Composition

## Abstract

We develop a formally verified **quantitative approximation calculus** that shows how pointwise approximation errors propagate through algebraic and lattice operations on compact domains. Given functions approximated by network-like primitives with explicit error and value bounds, we prove sharp, compositional bounds for:
- **Addition** (error adds linearly)
- **Scalar multiplication** (error scales by |c|)
- **Multiplication** (Leibniz-type error: Bf·εg + Mg·εf)
- **Maximum** (error bounded by max(εf, εg) — the sharp ℓ∞-Lipschitz bound)

These primitive bounds are packaged into a unified **expression tree calculus**: for any expression built from generators using +, ·, scalar multiplication, and max, we give explicit structural error and value bounds that can be computed from the tree syntax alone. The entire development — 19 theorems including the main compositional closure theorem — is formalized and verified in Lean 4 with Mathlib, with no remaining `sorry` axioms.

As a bridge to tropical and smooth analysis, we also formalize the **log-sum-exp approximation** to max: |τ·log(exp(a/τ) + exp(b/τ)) - max(a,b)| ≤ τ·log(2), connecting exact lattice operations to differentiable surrogates.

## 1. Introduction

Universal approximation theorems guarantee that neural networks, EML networks, and other function classes can approximate any continuous function on compact sets to arbitrary accuracy. However, classical results are qualitative: they assert existence without tracking error propagation. When building complex approximants from simpler ones — multiplying two network outputs, taking their maximum, forming linear combinations — the resulting error depends on the structure of the composition in a way that existing theorems do not quantify.

This paper fills that gap. We develop a **compositional approximation calculus** with three key properties:

1. **Explicit bounds**: Every error estimate is a concrete numerical expression in the input errors and value bounds.
2. **Structural compositionality**: Error bounds propagate through an expression tree by structural recursion.
3. **Formal verification**: All theorems are machine-checked in Lean 4.

### 1.1 Motivation

Consider approximating f(x) = max(p(x)·q(x), r(x)) where p, q, r are approximated by network functions P, Q, R with errors εp, εq, εr. What is the error of the composed approximant max(P·Q, R)?

Our calculus gives an immediate answer. The product P·Q has error ≤ Bp·εq + Mq·εp (the Leibniz bound, where Bp bounds |p| and Mq bounds |Q|). The max with R then has error ≤ max(Bp·εq + Mq·εp, εr). No new proof is needed — the bound follows mechanically from the expression structure.

### 1.2 Relation to EML and Tropical Analysis

EML (Exponential-Multiplicative-Logarithmic) networks generate functions through compositions of exp, log, and multiplication. The Stone-Weierstrass theorem guarantees that the EML subalgebra is dense in C(K, ℝ) on compact K. Our work adds the quantitative layer: given individual EML approximants to generators, what is the error after algebraic combination?

The max operation connects this to **tropical/max-plus algebra**, where max replaces addition and addition replaces multiplication. Our sharp bound |max(a,b) - max(c,d)| ≤ max(|a-c|, |b-d|) — the 1-Lipschitz property of max in the ℓ∞ norm — is the key inequality bridging classical analysis to the tropical world.

## 2. Elementary Inequalities

### 2.1 The Leibniz Product Error Bound

**Theorem (mul_sub_mul_bound).** For all f, g, F, G ∈ ℝ:

|f · g - F · G| ≤ |f| · |g - G| + |G| · |f - F|

*Proof.* Write f·g - F·G = f·(g - G) + G·(f - F), then apply the triangle inequality and |a·b| = |a|·|b|. □

This telescoping identity is the workhorse of product error analysis. It has a natural interpretation: the first term captures the error from approximating g while holding f exact, and the second captures the error from approximating f while holding G fixed.

**Corollary (mul_sub_mul_bounded).** If |f| ≤ Bf, |G| ≤ Mg, |f - F| ≤ εf, |g - G| ≤ εg, then:

|f · g - F · G| ≤ Bf · εg + Mg · εf

### 2.2 The Sharp Max-Lipschitz Inequality

**Theorem (abs_max_sub_max_le_max, from Mathlib).** For all a, b, c, d ∈ ℝ:

|max(a,b) - max(c,d)| ≤ max(|a-c|, |b-d|)

This says max is **1-Lipschitz** in the ℓ∞ norm on ℝ². The bound is sharp: equality holds when the "winning" argument stays the same (e.g., a > b and c > d, then LHS = |a - c| = max(|a - c|, |b - d|) when |a - c| ≥ |b - d|).

We also prove the weaker additive form:

**Theorem (max_lipschitz_add).** |max(a,b) - max(c,d)| ≤ |a - c| + |b - d|.

## 3. Pointwise Approximation Closure

We define a predicate `PointwiseApprox K f F ε M` meaning: for all x ∈ K, |f(x) - F(x)| ≤ ε and |F(x)| ≤ M. The first component tracks approximation error; the second tracks value bounds, which are needed for the multiplication rule.

### 3.1 Linear Operations

**Theorem (approx_add).** If PointwiseApprox K f F εf Mf and PointwiseApprox K g G εg Mg, then PointwiseApprox K (f+g) (F+G) (εf+εg) (Mf+Mg).

**Theorem (approx_smul).** If PointwiseApprox K f F ε M, then PointwiseApprox K (c·f) (c·F) (|c|·ε) (|c|·M).

These are straightforward from the triangle inequality.

### 3.2 Multiplication

**Theorem (approx_mul).** If PointwiseApprox K f F εf Mf and PointwiseApprox K g G εg Mg, and |f(x)| ≤ Bf on K, then:

PointwiseApprox K (f·g) (F·G) (Bf·εg + Mg·εf) (Mf·Mg)

The error bound is the Leibniz estimate from §2.1. The value bound Mf·Mg follows from |F·G| = |F|·|G| ≤ Mf·Mg.

### 3.3 Maximum

**Theorem (approx_max).** If PointwiseApprox K f F εf Mf and PointwiseApprox K g G εg Mg, then:

PointwiseApprox K max(f,g) max(F,G) max(εf, εg) max(Mf, Mg)

This is the sharpest possible bound: the max operation does not accumulate errors, it merely propagates the worst-case input error. This is the quantitative manifestation of max being non-expansive.

## 4. The Expression Tree Calculus

### 4.1 Syntax and Semantics

We define an expression tree type `EMLExprR ι` with constructors:
- `var i` — variable reference
- `const c` — real constant
- `add e₁ e₂` — addition
- `mul e₁ e₂` — multiplication
- `smul c e` — scalar multiplication
- `maxOp e₁ e₂` — pointwise maximum

Evaluation `e.eval v : α → ℝ` interprets variables via `v : ι → α → ℝ`.

### 4.2 Structural Bounds

**Value bound** `e.boundVal B : ℝ` computes a bound on |e.eval v x| given |v i x| ≤ B i:
- var i → B i
- const c → |c|
- add e₁ e₂ → e₁.boundVal + e₂.boundVal
- mul e₁ e₂ → e₁.boundVal · e₂.boundVal
- smul c e → |c| · e.boundVal
- maxOp e₁ e₂ → max(e₁.boundVal, e₂.boundVal)

**Error bound** `e.errBound ε B : ℝ` computes the worst-case propagated error:
- var i → ε i
- const c → 0
- add e₁ e₂ → e₁.errBound + e₂.errBound
- mul e₁ e₂ → e₁.boundVal · e₂.errBound + e₂.boundVal · e₁.errBound
- smul c e → |c| · e.errBound
- maxOp e₁ e₂ → max(e₁.errBound, e₂.errBound)

### 4.3 Main Theorem

**Theorem (approx_expr).** Let φ be an expression, f_i the true variable functions, F_i their approximants with |f_i(x) - F_i(x)| ≤ ε_i and |F_i(x)| ≤ M_i and |f_i(x)| ≤ B_i. Then:

∀ x ∈ K, |φ.eval(f, x) - φ.eval(F, x)| ≤ φ.errBound(ε, λi. max(B_i, M_i))

*Proof.* By structural induction on φ, using the primitive closure theorems from §3 at each constructor. The multiplication case requires both the Leibniz error bound and the value bound from both sub-expressions. The max case uses the sharp ℓ∞-Lipschitz inequality. □

This theorem is the **real "calculus" statement**: any finite algebraic/max expression in approximable generators is approximable with explicit, mechanically computable error.

## 5. The Log-Sum-Exp Bridge

### 5.1 Smooth Approximation of Max

**Theorem (softmax_error).** For τ > 0:

|τ · log(exp(a/τ) + exp(b/τ)) - max(a,b)| ≤ τ · log 2

This bridges the exact max to the smooth log-sum-exp, with error controlled by the temperature parameter τ. As τ → 0, the approximation converges to exact max.

### 5.2 Significance for EML

The log-sum-exp function is built from exp, log, and addition — all operations in the EML catalog. This means:

1. If EML can approximate exp and log with error δ on a bounded domain, then it can approximate max(f, g) with error at most max(εf, εg) + τ·log(2) + O(δ), for any temperature τ > 0.

2. By taking τ small and δ small (which requires larger networks), the max error can be made arbitrarily small.

This provides a concrete, quantitative path from the EML approximation library to tropical/max-plus computations.

## 6. Discussion: Making Abstract Mathematics Concrete

### For the General Reader

Imagine you're building a complex machine from simpler parts, where each part has a small manufacturing tolerance. How much does the final product's precision suffer from the accumulated tolerances?

This is exactly what our theorems answer for function approximation. The "parts" are simple network approximations; the "machine" is a complex function built from them using arithmetic and max. Our calculus gives a **recipe** for computing the total error from the individual errors, without doing any new analysis.

The key surprise is the **max operation**: when you take the maximum of two approximate quantities, the error is only as bad as the worst individual error — not the sum. This is because max doesn't amplify errors; it just selects one value. Mathematically, max is "non-expansive" or "1-Lipschitz." This makes max-based compositions remarkably well-behaved for approximation.

In contrast, multiplication does amplify errors, but in a controlled way: the error of f·g is roughly |f|·(error of g) + |g|·(error of f). This is the chain rule of approximation, analogous to the Leibniz product rule in calculus.

### For Practitioners

The compositional calculus has immediate practical value:

1. **Error budgeting**: Given a target overall error, work backwards through the expression tree to determine required per-component accuracies.

2. **Network sizing**: Since network width/depth typically trades off against approximation error, the error bounds translate to width/depth requirements for the composed network.

3. **Modular design**: Approximate each basis function independently (perhaps using different architectures optimized for each), then combine with guaranteed error bounds.

4. **Tropical neural networks**: The max-closure result enables principled analysis of ReLU-like architectures, where max(0, x) is a fundamental operation.

### Connections to Existing Work

- **Stone-Weierstrass**: Our results make the qualitative density theorem quantitative for generated algebras.
- **Tropical geometry**: The max-closure theorem is the first step toward a quantitative tropical approximation theory.
- **Neural network theory**: The Leibniz product bound is standard in perturbation analysis; our contribution is packaging it into a formal, reusable calculus.
- **Interval arithmetic**: The structural bound propagation is reminiscent of interval arithmetic, but operates on error radii rather than interval endpoints.

## 7. Formalization Details

The entire development is contained in `EML/Quantitative/AlgebraicMaxClosure.lean` (~380 lines). Key statistics:

| Category | Count |
|----------|-------|
| Theorems proved | 19 |
| Lines of Lean | ~380 |
| `sorry` remaining | 0 |
| Non-standard axioms | 0 |
| Axioms used | propext, Classical.choice, Quot.sound |

The proofs use standard Mathlib tactics (`linarith`, `gcongr`, `positivity`, `grind`) and rely on the Mathlib lemma `abs_max_sub_max_le_max` for the sharp max-Lipschitz inequality.

## 8. Applications

### 8.1 Automated Error Budgeting

Given an expression tree and a target accuracy δ, solve backwards for per-variable error budgets:

```python
# Given expression φ and target error δ
# Find ε_i such that φ.errBound(ε, B) ≤ δ
# This is a linear program when φ involves only add/smul/max
# and a bilinear program for mul
```

### 8.2 Neural Architecture Design

When designing a network to approximate a specific algebraic expression:
1. Decompose the target into an expression tree
2. Use errBound to determine per-component accuracy requirements
3. Size each component network to meet its requirement
4. The compositional theorem guarantees the overall accuracy

### 8.3 Certified Numerical Computing

The bounds enable certified forward evaluation: given interval bounds on inputs, propagate through the expression to get guaranteed output intervals. This is useful in safety-critical applications where worst-case guarantees are required.

## 9. Future Directions

1. **Width tracking**: Integrate with EML width/depth measures to get combined error + complexity bounds.
2. **Composition with Lipschitz maps**: Extend to general Lipschitz post-compositions (partially done in the existing `UniformApprox.lean`).
3. **Rate theory**: For specific function classes (Hölder, Sobolev), derive explicit rates of approximation through the expression tree.
4. **Tropical optimization**: Use the max-closure theorem to develop quantitative tropical polynomial approximation.
5. **Backward error analysis**: Given a target error, automatically compute optimal per-variable error budgets.
6. **Deep composition**: Extend the expression tree to include function composition, giving error bounds for deep networks.
