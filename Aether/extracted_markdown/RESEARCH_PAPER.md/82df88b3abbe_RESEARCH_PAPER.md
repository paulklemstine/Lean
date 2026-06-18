# Logarithmic Derivative Algebra: A Graded Depth-Reducing Homomorphism for EML Functions

## Abstract

We develop the **Logarithmic Derivative Algebra**, a novel algebraic framework for understanding the depth hierarchy of EML (Exp-Mul-Log) functions through Mathlib's `logDeriv` operator. Our central result is the **Layer-Stripping Identity**: for any differentiable function g, the logarithmic derivative of exp ∘ g equals the ordinary derivative of g. This identity, combined with the multiplicative-to-additive homomorphism property of logDeriv, establishes logDeriv as a calibrated depth reducer on iterated exponentials. We prove a **Product Formula** showing that the derivative of the n-fold iterated exponential equals the product of all lower exponential layers, derive the **LogDeriv Product Formula** as a consequence, and establish symbolic depth bounds showing that differentiation never increases exponential depth. We connect these results to the Schwarzian derivative, demonstrating a bridge between EML depth complexity and projective geometry. All 12 main theorems are formally verified in Lean 4 with Mathlib, with no axioms beyond the standard `propext`, `Classical.choice`, and `Quot.sound`.

**Keywords**: logarithmic derivative, iterated exponential, depth hierarchy, graded homomorphism, differential algebra, EML, Schwarzian derivative, formal verification

## 1. Introduction

### 1.1 Background

The class of **EML functions** — functions built from constants, the variable x, addition, multiplication, and the operation eml(a,b) = a·exp(b) — forms a natural intermediate class between polynomials and arbitrary smooth functions. The **exponential depth** of an EML expression, counting the maximum nesting of exponential operations, provides a natural measure of transcendental complexity.

Previous work in this catalog established:
- Symbolic differentiation raises depth by at most 1 (Catalog: `Pythagorean/DiffClosure.lean`)
- The sharp bound: differentiation does NOT increase depth (Catalog: `Bridges/LogDerivLevel.lean`)
- Hardy level bounds for EML expressions (Catalog: `Pythagorean/HardyHierarchy/DepthStability.lean`)
- The closure operator structure of EML function classes (Catalog: `EML/GaloisInsertionClosure.lean`)

### 1.2 This Paper's Contribution

We extend the depth-stability results to a full algebraic framework by proving:

1. **Layer-Stripping Identity** (`logDeriv_exp_comp`): logDeriv(exp ∘ g) = deriv g
2. **Iterated Layer-Stripping** (`logDeriv_iterExp_succ`): logDeriv(iterExp(n+1)) = deriv(iterExp n)
3. **Product Formula** (`hasDerivAt_iterExp_succ`, `deriv_iterExp_succ`): deriv(iterExp(n+1)) x = ∏_{k=0}^n iterExp(k+1) x
4. **LogDeriv Product Formula** (`logDeriv_iterExp_eq_prod`): Combination of (2) and (3)
5. **Graded Homomorphism** (`logDeriv_finset_prod`): logDeriv(∏ fᵢ) = ∑ logDeriv(fᵢ)
6. **Degree Extraction** (`logDeriv_pow_id`): logDeriv(x^n) = n/x
7. **ODE Characterization** (`logDeriv_const_implies_exp_ode`): logDeriv f = c ⟹ f' = c·f
8. **Depth Stability** (`expDepth_symDeriv_le`): Symbolic differentiation never increases depth
9. **Schwarzian Bridge** (`schwarzian_exp_eq`): S(exp) = -1/2

### 1.3 Cross-Domain Connections

Our results bridge three mathematical domains:
- **Differential Algebra**: logDeriv as the fundamental operator in differential fields
- **Complexity Theory**: Exponential depth as "circuit depth" for transcendental computation
- **Projective Geometry**: The Schwarzian derivative as projective curvature

## 2. Definitions

### 2.1 Iterated Exponential

```
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => exp (iterExp n x)
```

### 2.2 Logarithmic Derivative

Following Mathlib, `logDeriv f x = deriv f x / f x`. This is the standard logarithmic derivative from differential algebra.

### 2.3 Symbolic Expression Type

```
inductive SympExpr where
  | const : ℝ → SympExpr
  | var : SympExpr
  | add : SympExpr → SympExpr → SympExpr
  | mul : SympExpr → SympExpr → SympExpr
  | exp : SympExpr → SympExpr
```

with evaluation `eval`, exponential depth `expDepth`, and symbolic differentiation `symDeriv`.

### 2.4 Schwarzian Derivative

The Schwarzian derivative is defined as:
```
S(f)(x) = f''(x)/f'(x) - (3/2)(f'(x)/f(x))²
```

## 3. Main Results

### 3.1 The Layer-Stripping Identity (Theorem 1)

**Theorem** (`logDeriv_exp_comp`). For any differentiable g : ℝ → ℝ and any x : ℝ,
```
logDeriv (fun x => exp (g x)) x = deriv g x
```

*Proof sketch*. By definition, logDeriv(exp ∘ g)(x) = (exp ∘ g)'(x) / (exp ∘ g)(x). The chain rule gives (exp ∘ g)'(x) = exp(g(x)) · g'(x). Since exp never vanishes, exp(g(x)) cancels, leaving g'(x).

**PEGB Analysis**:
- **P**roof: Complete formal proof in Lean 4, using `norm_num` with differentiability and non-vanishing hypotheses.
- **E**xample: For g(x) = x², logDeriv(exp(x²))(x) = 2x. The exponential wrapper is stripped, and only the derivative of the inner function remains.
- **G**eneralization: This extends naturally to any normed field 𝕜' where exp is defined. The identity holds for complex exponentials as well.
- **B**oundary: Fails for non-differentiable g (logDeriv defaults to 0). Also fails if we replace exp with a function that has zeros.

### 3.2 Iterated Layer-Stripping (Theorem 2)

**Theorem** (`logDeriv_iterExp_succ`). For any n : ℕ and x : ℝ,
```
logDeriv (iterExp (n + 1)) x = deriv (iterExp n) x
```

*Proof sketch*. Since iterExp(n+1) = exp ∘ iterExp(n) and iterExp(n) is differentiable (proved by induction), apply the layer-stripping identity.

**PEGB Analysis**:
- **P**roof: One-line application of `logDeriv_exp_comp` with `differentiable_iterExp`.
- **E**xample: logDeriv(exp(exp(x))) = deriv(exp(x)) = exp(x). The outer exp is stripped.
- **G**eneralization: Extends to any "tower-building" operation, not just exp.
- **B**oundary: For n=0, logDeriv(exp(x)) = 1, which is deriv(id)(x) = 1. The identity reduces to tautology at the base level.

### 3.3 Product Formula (Theorem 3)

**Theorem** (`hasDerivAt_iterExp_succ`). For any n : ℕ and x : ℝ,
```
HasDerivAt (iterExp (n + 1)) (∏ k ∈ range (n + 1), iterExp (k + 1) x) x
```

*Proof sketch*. By induction on n. Base case: HasDerivAt(exp)(exp x)(x) and the product over range(1) is just exp(x). Inductive step: apply the chain rule for exp to the inductive hypothesis, then rewrite the product using `Finset.prod_range_succ`.

**PEGB Analysis**:
- **P**roof: Induction with `HasDerivAt.exp` and `Finset.prod_range_succ`.
- **E**xample: deriv(exp(exp(x))) = exp(exp(x)) · exp(x) = E₂(x) · E₁(x).
- **G**eneralization: For any invertible function F replacing exp, the chain rule still gives a product formula, but the factors are F'(iterF(k)(x)).
- **B**oundary: The product grows super-exponentially, reflecting the extreme growth rate of iterated exponentials.

### 3.4 LogDeriv Product Formula (Theorem 4)

**Theorem** (`logDeriv_iterExp_eq_prod`). For any n : ℕ and x : ℝ,
```
logDeriv (iterExp (n + 2)) x = ∏ k ∈ range (n + 1), iterExp (k + 1) x
```

*Proof*. Combine `logDeriv_iterExp_succ` and `deriv_iterExp_succ`.

### 3.5 Graded Homomorphism (Theorem 5)

**Theorem** (`logDeriv_finset_prod`). For a finite family of functions f_i with f_i(x) ≠ 0,
```
logDeriv (∏ i ∈ s, f_i) x = ∑ i ∈ s, logDeriv (f_i) x
```

This extends Mathlib's `logDeriv_prod` to our setting and establishes logDeriv as a graded ring homomorphism.

### 3.6 Depth Stability (Theorem 6)

**Theorem** (`expDepth_symDeriv_le`). For any symbolic expression e,
```
e.symDeriv.expDepth ≤ e.expDepth
```

*Proof sketch*. Structural induction on e. The key case is exp(a): symDeriv(exp(a)) = a' · exp(a), which has depth max(depth(a'), depth(a) + 1) ≤ depth(a) + 1 = depth(exp(a)) by the inductive hypothesis.

**PEGB Analysis**:
- **P**roof: Structural induction with omega-level arithmetic.
- **E**xample: symDeriv(exp(exp(x))) = exp(x)·exp(exp(x)), which has depth 2 = depth(exp(exp(x))).
- **G**eneralization: This should extend to expressions with division and negation.
- **B**oundary: Does not hold for arbitrary rewrite rules — only for the standard chain/product rule.

### 3.7 Schwarzian Bridge (Theorem 7)

**Theorem** (`schwarzian_exp_eq`). The Schwarzian of exp at any point x equals -1/2:
```
S(exp)(x) = exp''(x)/exp'(x) - (3/2)(exp'(x)/exp(x))² = -1/2
```

*Proof sketch*. Since exp' = exp and exp'' = exp, the first term is 1 and the second is 3/2, giving 1 - 3/2 = -1/2.

**PEGB Analysis**:
- **P**roof: `norm_num` with `Real.exp_ne_zero`.
- **E**xample: At x=0, S(exp)(0) = 1/1 - (3/2)(1/1)² = -1/2.
- **G**eneralization: For iterExp(n), the Schwarzian involves products of exponential layers and has a recursive structure.
- **B**oundary: Möbius transformations have S = 0 (depth 0). The non-zero Schwarzian of exp quantifies its "projective curvature" at depth 1.

## 4. Algorithms

### 4.1 Depth Computation

Given a symbolic expression tree, compute its exponential depth in O(n) time by a bottom-up traversal.

### 4.2 Symbolic LogDeriv

Given an expression e representing exp(g), extract g and compute its symbolic derivative. This reduces depth by 1 in O(|e|) time.

### 4.3 Iterative Depth Reduction

To reduce an expression of depth d to depth 0: apply symbolic logDeriv d times. Total cost: O(d · |e|) since each step is linear.

## 5. Discussion

### 5.1 Relation to Transseries

In the theory of transseries (formal solutions to ODEs involving nested exponentials and logarithms), the logarithmic derivative is the fundamental operator that relates different levels of the transseries hierarchy. Our depth-reduction theorem provides a constructive, formally verified version of this relationship for the EML fragment.

### 5.2 Relation to Complexity Theory

The exponential depth hierarchy of EML expressions is analogous to the circuit depth hierarchy in computational complexity. Our results show that logDeriv is the canonical "depth simplification" operator — the analogue of circuit simplification for transcendental expressions. The graded homomorphism property ensures that this simplification is algebraically well-behaved.

### 5.3 Relation to WKB Approximation

In semiclassical physics, the WKB approximation writes solutions as y = exp(S/ℏ), where S is the classical action. The logarithmic derivative y'/y = S'/ℏ extracts the "phase velocity" from the exponential ansatz. Our product formula for iterated exponentials generalizes this to nested WKB phases.

## 6. Future Work

1. **Complex Extension**: Extend the layer-stripping identity to ℂ-valued functions, where exp is periodic and the analysis is richer.
2. **Normal Forms**: Develop a canonical simplification procedure for EML expressions using iterated logDeriv, achieving linear (not quadratic) size growth.
3. **Galois Theory**: Connect the depth hierarchy to differential Galois theory, showing that depth = differential transcendence degree.
4. **Computational Complexity Bridge**: Formalize the correspondence between EML depth and circuit depth.

## 7. References

1. `Bridges/LogDerivLevel.lean` — Sharp depth bound for logarithmic differentiation
2. `Pythagorean/DiffClosure.lean` — Differential closure for Hardy hierarchies
3. `EML/GaloisInsertionClosure.lean` — Galois insertion closure for EML
4. `EML/Complexity/Defs.lean` — EML circuit depth separation definitions
5. `EML/EMLv17Core.lean` — Core EML definitions and identities
6. Mathlib `Analysis.Calculus.LogDeriv` — Logarithmic derivative in Mathlib

## Appendix: Formal Statement Summary

| # | Name | Statement |
|---|------|-----------|
| 1 | `logDeriv_exp_comp` | logDeriv(exp ∘ g) = deriv g |
| 2 | `logDeriv_iterExp_succ` | logDeriv(iterExp(n+1)) = deriv(iterExp n) |
| 3 | `hasDerivAt_iterExp_succ` | HasDerivAt (iterExp(n+1)) (∏ iterExp(k+1)) |
| 4 | `deriv_iterExp_succ` | deriv(iterExp(n+1)) = ∏ iterExp(k+1) |
| 5 | `logDeriv_iterExp_eq_prod` | logDeriv(iterExp(n+2)) = ∏ iterExp(k+1) |
| 6 | `logDeriv_finset_prod` | logDeriv(∏ fᵢ) = ∑ logDeriv(fᵢ) |
| 7 | `logDeriv_pow_id` | logDeriv(x^n) = n/x |
| 8 | `logDeriv_const_implies_exp_ode` | logDeriv f = c ⟹ f' = c·f |
| 9 | `expDepth_symDeriv_le` | depth(symDeriv e) ≤ depth(e) |
| 10 | `expDepth_symDeriv_iterExpExpr` | depth(symDeriv(iterExpExpr(n+1))) ≤ n+1 |
| 11 | `schwarzian_exp_eq` | S(exp) = -1/2 |
| 12 | `differentiable_iterExp` | iterExp n is differentiable |
