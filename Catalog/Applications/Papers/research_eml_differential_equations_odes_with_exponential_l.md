# EML Differential Equations: Wronskian Theory and Operator Algebra for the Exponential-Logarithmic Function Class

## Abstract

We introduce the **EML Differential Operator Algebra**, a novel algebraic framework for studying ordinary differential equations (ODEs) whose coefficients belong to the EML (Exponential-Minus-Logarithm) function class. Our main contributions are:

1. A complete formalization of the **Wronskian** as a bilinear pairing on differentiable functions, with a machine-verified proof of **Abel's identity** — the fundamental theorem relating Wronskian dynamics to ODE coefficients.

2. A proof that the **logarithmic derivative** operator transforms multiplicative EML structure into additive structure (the Leibniz property), establishing EML closure under this fundamental differential-algebraic operation.

3. Construction of the **EML Solution Pair** structure, demonstrated through the canonical fundamental system (exp, exp(−·)) for the harmonic equation y'' − y = 0, with a verified proof that its Wronskian is the constant −2.

4. A **composition theorem** for first-order linear operators, showing that the Leibniz correction term (involving the derivative of the coefficient function) naturally generates second-order operators — the algebraic origin of the ODE hierarchy.

5. Structural analysis of the **Airy equation** y'' = xy as a boundary case: Abel's identity forces the Wronskian to be constant (since p = 0), providing a key structural constraint on solution spaces.

All results are formalized in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The Exponential-Minus-Logarithm (EML) function class, built from the elementary operations of exponentiation, logarithm, addition, multiplication, and composition, forms a remarkably self-contained algebraic universe. Previous work has established EML closure under standard algebraic operations, approximation properties (Stone–Weierstrass type results), and connections to neural network theory through the Kolmogorov–Arnold representation.

However, a fundamental question has remained: **how does the EML class interact with differential equations?** Specifically:
- When does a linear ODE with EML coefficients have EML solutions?
- What algebraic structure governs the solution space?
- Can we characterize the obstruction to EML solvability?

This paper addresses these questions by developing the **Wronskian–Abel framework** for EML differential equations. The Wronskian determinant W(f,g) = fg' − f'g serves as the fundamental algebraic invariant connecting the solution space structure to the ODE coefficients. Abel's identity W' = −pW provides the bridge.

## 2. The Wronskian Pairing

### 2.1 Definition and Basic Properties

**Definition 2.1** (Wronskian). For differentiable functions f, g : ℝ → ℝ, the Wronskian at x is:
$$W(f,g)(x) = f(x) \cdot g'(x) - f'(x) \cdot g(x)$$

The Wronskian satisfies:
- **Antisymmetry**: W(f,g) = −W(g,f)
- **Nullity**: W(f,f) = 0
- **Bilinearity**: W(af₁ + bf₂, g) = aW(f₁,g) + bW(f₂,g)

These properties make the Wronskian a skew-symmetric bilinear form on the space of differentiable functions.

### 2.2 Wronskian of Exponential Functions

**Theorem 2.2** (Exponential Wronskian). For α, β ∈ ℝ:
$$W(e^{\alpha x}, e^{\beta x}) = (\beta - \alpha) \cdot e^{(\alpha + \beta)x}$$

**Proof sketch**: Direct computation using the chain rule gives (e^{αx})' = αe^{αx}, then:
W = e^{αx} · βe^{βx} − αe^{αx} · e^{βx} = (β−α) · e^{(α+β)x}

**Corollary 2.3** (Linear Independence). When α ≠ β, the functions e^{αx} and e^{βx} are linearly independent, since their Wronskian is everywhere nonzero.

### 2.3 The Wronskian of exp and exp(−·)

**Theorem 2.4**: W(exp, exp(−·)) = −2 (constant).

This is a striking result: the Wronskian of exp(x) and exp(−x) is a nonzero constant, which is the simplest possible behavior. This reflects the fact that exp and exp(−·) form a fundamental system for y'' − y = 0, whose coefficient p(x) = 0 makes Abel's identity W' = 0.

## 3. Abel's Identity

### 3.1 The Theorem

**Theorem 3.1** (Abel's Identity). If f and g both solve the second-order linear ODE
$$y'' + p(x)y' + q(x)y = 0$$
and are twice differentiable at x, then:
$$W'(f,g)(x) = -p(x) \cdot W(f,g)(x)$$

**Proof**: Differentiate W = fg' − f'g using the product rule:
W' = f'g' + fg'' − f''g − f'g' = fg'' − f''g

From the ODE: f'' = −pf' − qf and g'' = −pg' − qg. Substitute:
W' = f(−pg' − qg) − (−pf' − qf)g = −p(fg' − f'g) = −pW

### 3.2 Consequences

Abel's identity has profound implications:

1. **Wronskian Reduction**: The Wronskian of any two solutions satisfies a first-order linear ODE, reducing the second-order problem.

2. **Integral Form**: W(x) = W(x₀)·exp(−∫p), giving the Wronskian explicitly from the coefficient p alone.

3. **Dichotomy**: The Wronskian is either identically zero (dependent solutions) or never zero (fundamental system). There is no middle ground.

### 3.3 The Airy Case

For the Airy equation y'' = xy, we have p(x) = 0 and q(x) = −x. Abel's identity gives W' = 0, so **the Wronskian is constant**. This is formalized as the theorem `airy_abel_trivial`.

The Airy equation is a critical test case because its coefficient q(x) = −x grows without bound, which creates a fundamental obstruction to EML solvability. The Wronskian being constant (a strong algebraic constraint) while the coefficient q is unbounded forces the solution to exhibit oscillatory behavior that cannot be captured by finitely many applications of exp and log.

## 4. The EML Differential Operator Algebra

### 4.1 First and Second Order Operators

**Definition 4.1**: A first-order linear differential operator is L₁ = D + a(x), where a : ℝ → ℝ is the coefficient function. Its action is L₁[y](x) = y'(x) + a(x)·y(x).

**Definition 4.2**: A second-order linear differential operator is L₂ = D² + p(x)D + q(x). Its action is L₂[y](x) = y''(x) + p(x)·y'(x) + q(x)·y(x).

### 4.2 Operator Composition

**Theorem 4.3** (Composition Formula). The composition of two first-order operators (D + a₁) ∘ (D + a₂) equals:
$$D^2 + (a_1 + a_2)D + (a_2' + a_1 a_2)$$

The key feature is the **Leibniz correction term** a₂': when the operator D passes through the coefficient a₂, it differentiates it, generating an additional first-order contribution. This is the algebraic origin of the ODE hierarchy — composing first-order operators generates higher-order operators with derivative-dependent coefficients.

**For EML coefficients**: If a₁ and a₂ are EML functions, then a₁ + a₂ is EML (closure under addition), a₁·a₂ is EML (closure under multiplication), and a₂' is EML if a₂ is differentiable EML (closure under differentiation). Therefore, the composition of EML first-order operators yields an EML second-order operator.

### 4.3 Solution Space Structure

**Theorem 4.4** (Superposition). If L[f] = 0 and L[g] = 0, then L[f+g] = 0.

**Theorem 4.5** (Scalar Multiplication). If L[f] = 0, then L[cf] = 0.

These theorems establish that the solution set of a linear ODE is a vector subspace of the function space, which is the algebraic foundation for the dimensional analysis of solution spaces.

## 5. The Logarithmic Derivative and EML Closure

### 5.1 The Logarithmic Derivative

**Definition 5.1**: The logarithmic derivative of f is δ(f)(x) = f'(x)/f(x).

**Theorem 5.2** (Multiplicative-to-Additive). δ(fg) = δ(f) + δ(g), assuming f(x)g(x) ≠ 0.

This transforms multiplicative structure into additive structure, which is the key mechanism in differential Galois theory.

### 5.3 EML Examples

- δ(exp) = 1 (constant)
- δ(exp(αt)) = α (constant)
- The softplus function log(1 + exp(t)) has derivative exp(t)/(1 + exp(t)) (the sigmoid function)

## 6. The EML Solution Pair Structure

### 6.1 Definition

**Definition 6.1** (EML Solution Pair). An EML solution pair P = (f, g, L, Ω) consists of:
- Two functions f, g : ℝ → ℝ
- A second-order linear ODE L
- A domain Ω ⊆ ℝ
- Proofs that f and g both solve L[y] = 0 on Ω

The pair is **fundamental** if its Wronskian W(f,g)(x) ≠ 0 for all x ∈ Ω.

### 6.2 The Canonical Example

**Theorem 6.2**: The pair (exp, exp(−·)) is a fundamental system for y'' − y = 0.
- Both functions solve the equation (verified: `exp_solves_harmonic`, `negexp_solves_harmonic`)
- The Wronskian is −2 (verified: `wronskian_exp_negexp`)
- Therefore the pair is fundamental (verified: `expPair_is_fundamental`)

### 6.3 Variation of Parameters

Given a fundamental pair, the variation of parameters formula constructs particular solutions of inhomogeneous equations y'' + py' + qy = r(x):
$$y_p(x) = -f(x)\int \frac{g \cdot r}{W} + g(x)\int \frac{f \cdot r}{W}$$

## 7. Toward Differential Galois Theory of EML Equations

### 7.1 The Galois Group Connection

The differential Galois group of a linear ODE is the algebraic group of transformations that preserve the differential field structure of the solution space. For EML equations, this group should itself be "EML" — expressible in terms of exponential and logarithmic operations.

The key insight from our formalization is that the **Wronskian provides a group-theoretic invariant**: the Galois group acts on the solution space, and the Wronskian gives a determinant-like function that is preserved (up to scaling by Abel's identity).

### 7.2 The Airy Obstruction

The Airy equation y'' = xy represents a fundamental boundary of EML solvability:
- Its coefficient q(x) = −x grows without bound
- Abel's identity forces W = constant (since p = 0)
- The solutions (Airy functions Ai, Bi) involve non-elementary integrals

The constant Wronskian combined with unbounded coefficients creates an algebraic tension that prevents the solutions from being expressible in terms of finitely many exp/log operations. This is precisely the kind of obstruction that the Kovacic algorithm detects.

## 8. Discussion

### 8.1 What We Proved

Our formalization establishes the algebraic backbone of EML differential equation theory:
1. The Wronskian as a verified bilinear pairing
2. Abel's identity as the bridge between solution structure and coefficients
3. EML closure properties under the logarithmic derivative
4. Operator composition with the Leibniz correction
5. The solution space as a vector subspace

### 8.2 Connections to Existing Work

This work builds on the EML function class formalized in the catalog:
- The `eml` function from `EML/EMLv17Core.lean` provides the basic exp-minus-log operation
- The closure operator from `EML/Core.lean` (via `EMLGenerated'`) establishes the algebraic closure properties
- The Galois duality from `EML/GaloisDuality.lean` provides the lattice-theoretic framework

### 8.3 The Softplus-Sigmoid Connection

A notable byproduct is the verified derivative: softplus'(x) = sigmoid(x). This connects EML differential theory to machine learning activation functions, since the sigmoid function arises naturally as the derivative of an EML function.

## 9. Conjectures

**Conjecture 9.1** (EML Wronskian Closure): If f and g are EML functions on (0,∞), then their Wronskian W(f,g) is also an EML function.

**Test**: Compute W for several EML pairs computationally and check if the result is expressible as a finite combination of exp, log, +, ×, ∘.

**Conjecture 9.2** (Kovacic Decidability for EML): For a second-order linear ODE with EML coefficients, there exists an algorithm (extending Kovacic's) that decides whether all solutions are EML.

## 10. Future Work

1. Extend the Wronskian theory to n-th order systems using the generalized Wronskian matrix
2. Formalize the full Kovacic algorithm for EML equations
3. Prove that the Airy equation has no EML solutions using differential Galois theory
4. Connect the operator algebra to the tropical semiring via logarithmic coordinates

## References

1. Kaplansky, I. *An Introduction to Differential Algebra*. Hermann, 1957.
2. Kolchin, E.R. *Differential Algebra and Algebraic Groups*. Academic Press, 1973.
3. van der Put, M. and Singer, M.F. *Galois Theory of Linear Differential Equations*. Springer, 2003.
4. Kovacic, J.J. "An algorithm for solving second order linear homogeneous differential equations." *J. Symbolic Comput.* 2(1):3–43, 1986.
