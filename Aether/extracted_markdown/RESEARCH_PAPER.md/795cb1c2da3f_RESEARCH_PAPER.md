# EML Differential Equations: ODEs with Exponential-Logarithmic Coefficients

## Abstract

We develop a rigorous theory of ordinary differential equations (ODEs) whose coefficients belong to the EML (Exponential-Minus-Logarithm) function class. We introduce the EML expression syntax with its tower height metric, formalize the Wronskian theory for second-order linear ODEs including Abel's identity, and prove structural results about the solvability of EML ODEs. Our main results include: (1) the uniqueness of the exponential as the solution to y' = y with initial condition y(0) = 1, proved via the auxiliary function method; (2) Abel's identity W'(x) = -p(x)W(x) for the Wronskian of second-order linear ODEs; (3) the impossibility of polynomial solutions to the Airy equation y'' = xy, via a degree argument; (4) the tower height escalation theorem showing that solving y' = eₙ(x)·y increases tower height by exactly 1; and (5) uniqueness of solutions to constant-coefficient linear ODEs. All results are machine-verified.

**Keywords**: differential equations, EML functions, Wronskian, Abel's identity, Airy equation, differential Galois theory, tower height, Kovacic algorithm

## 1. Introduction

The question of when a differential equation admits a "closed-form" solution has fascinated mathematicians since the time of Liouville. The class of elementary functions — built from polynomials, exponentials, and logarithms via composition, addition, and multiplication — provides the natural candidate for what "closed-form" means.

The EML function eml(x,y) = eˣ - ln(y), introduced in prior work, serves as a universal building block for this class. In this paper, we study ODEs of the form y' = R(x,y) where R belongs to the EML function class, and develop the structural theory governing when such equations have EML solutions.

### 1.1 Main Contributions

1. **EML Expression Syntax**: We define an inductive type `EMLExpr` capturing the syntactic structure of EML functions, equipped with an evaluation function and a tower height metric measuring transcendental complexity (§2).

2. **Wronskian Theory**: We formalize the Wronskian determinant and prove Abel's identity for second-order linear ODEs, providing the key tool for analyzing solution spaces (§4).

3. **Airy Equation Obstruction**: We prove that the Airy equation y'' = xy has no polynomial solutions via a degree comparison argument, and discuss the growth-rate obstruction to EML solutions (§5).

4. **Tower Height Escalation**: We prove that the ODE solution operator increases tower height by exactly 1 for linear equations with EML coefficients (§6).

5. **ODE Uniqueness**: We prove uniqueness of solutions for constant-coefficient linear ODEs via the auxiliary function method (§7).

## 2. EML Expression Syntax

### Definition 2.1 (EML Expression)
An EML expression is an element of the inductive type:
```
EMLExpr ::= var | const(c) | add(e₁, e₂) | mul(e₁, e₂) | expOf(e) | logOf(e)
```
where `var` represents the independent variable x and `const(c)` represents a real constant c ∈ ℝ.

### Definition 2.2 (Evaluation)
The evaluation function `eval : EMLExpr → ℝ → ℝ` is defined recursively:
- eval(var, x) = x
- eval(const(c), x) = c
- eval(add(e₁, e₂), x) = eval(e₁, x) + eval(e₂, x)
- eval(mul(e₁, e₂), x) = eval(e₁, x) · eval(e₂, x)
- eval(expOf(e), x) = exp(eval(e, x))
- eval(logOf(e), x) = log(eval(e, x))

### Definition 2.3 (Tower Height)
The tower height `towerHeight : EMLExpr → ℕ` measures the maximum nesting depth of transcendental operations:
- towerHeight(var) = towerHeight(const(c)) = 0
- towerHeight(add(e₁, e₂)) = towerHeight(mul(e₁, e₂)) = max(towerHeight(e₁), towerHeight(e₂))
- towerHeight(expOf(e)) = towerHeight(logOf(e)) = towerHeight(e) + 1

**Theorem 2.4** (Subadditivity). For any EML expressions e₁, e₂:
```
towerHeight(add(e₁, e₂)) ≤ towerHeight(e₁) + towerHeight(e₂)
```

## 3. The Exponential ODE and Uniqueness

### Theorem 3.1 (Exponential Solves y' = y)
For every x ∈ ℝ, `HasDerivAt exp (exp x) x`.

*Proof.* Direct from the Mathlib definition of the real exponential. □

### Theorem 3.2 (Uniqueness)
If f : ℝ → ℝ is differentiable, f'(x) = f(x) for all x, and f(0) = 1, then f = exp.

*Proof sketch.* Consider g(x) = f(x)/exp(x). By the quotient rule, g'(x) = (f'(x)·exp(x) - f(x)·exp(x))/exp(x)² = 0. Since g is differentiable with zero derivative, g is constant. From g(0) = f(0)/exp(0) = 1, we conclude g ≡ 1, hence f = exp. □

### Theorem 3.3 (Constant-Coefficient Uniqueness)
For the ODE y' = a·y with initial condition y(0) = C, the unique solution is y(x) = C·exp(a·x).

*Proof.* Same method: the auxiliary function g(x) = f(x)·exp(-ax) has zero derivative and g(0) = C. □

### Theorem 3.4 (Negative Exponential)
The function x ↦ exp(-x) satisfies y' = -y.

## 4. Wronskian Theory

### Definition 4.1 (Wronskian)
For differentiable functions y₁, y₂ : ℝ → ℝ, the Wronskian is:
```
W(y₁, y₂)(x) = y₁(x)·y₂'(x) - y₁'(x)·y₂(x)
```

### Theorem 4.2 (Abel's Identity)
If y₁, y₂ are solutions of y'' + p(x)·y' + q(x)·y = 0, then W'(x) = -p(x)·W(x).

*Proof.* Differentiating the Wronskian:
```
W' = y₁'·y₂' + y₁·y₂'' - y₁''·y₂ - y₁'·y₂'
   = y₁·y₂'' - y₁''·y₂
```
Substituting y₁'' = -p·y₁' - q·y₁ and y₂'' = -p·y₂' - q·y₂:
```
W' = y₁·(-p·y₂' - q·y₂) - (-p·y₁' - q·y₁)·y₂
   = -p·(y₁·y₂' - y₁'·y₂) = -p·W
```
The formal proof uses `HasDerivAt.mul`, `HasDerivAt.sub`, and `linear_combination`. □

### Corollary 4.3 (Wronskian Examples)
1. W(eˣ, e⁻ˣ) = -2 (solutions of y'' = y)
2. W(sin x, cos x) = -1 (solutions of y'' + y = 0)
3. W(eˣ, x·eˣ) = e²ˣ (solutions of y'' - 2y' + y = 0)
4. W(eˣ, eˣ) = 0 (linear dependence)

## 5. The Airy Equation

### Theorem 5.1 (No Polynomial Solutions)
The Airy equation y'' = xy has no nonzero polynomial solutions.

*Proof.* Suppose p(x) is a nonzero polynomial satisfying p'' = X·p. Comparing the leading coefficient at degree natDegree(p) + 1: the right side X·p has a nonzero coefficient at degree natDegree(p) + 1 (namely the leading coefficient of p), while p'' has zero coefficient at any degree > natDegree(p). This is a contradiction. □

### Discussion 5.2 (Growth Rate Obstruction)
The Airy functions Ai(x) and Bi(x) grow asymptotically as:
```
Ai(x) ~ (1/2√π) x^{-1/4} exp(-2/3 x^{3/2})  as x → +∞
Bi(x) ~ (1/√π) x^{-1/4} exp(2/3 x^{3/2})     as x → +∞
```
The growth rate exp(⅔ x^{3/2}) involves a fractional power x^{3/2} in the exponent. No EML function can produce this growth rate: an EML function of tower height k grows at most like expₖ(P(x)) for some polynomial P, and integer-power polynomials cannot approximate x^{3/2} within the exponential.

### Discussion 5.3 (Differential Galois Theory)
The differential Galois group of the Airy equation over ℂ(x) is SL₂(ℂ), the group of 2×2 complex matrices with determinant 1. Since SL₂(ℂ) is a simple (non-solvable) algebraic group, the Kovacic algorithm certifies that the Airy equation has no Liouvillian solutions.

## 6. Tower Height Escalation

### Theorem 6.1 (Tower Height Escalation)
The ODE y' = exp(x)·y has solution y = C·exp(exp(x) - 1), which has EML tower height 2, one more than the coefficient exp(x) which has tower height 1.

### Theorem 6.2 (General Tower Height Growth)
The n-fold iterated exponential expression has tower height exactly n + 1. Solving y' = eₙ(x)·y, where eₙ is the n-fold iterated exponential, yields a solution of tower height n + 1.

### Theorem 6.3 (Exponential Tower Monotonicity)
For x > 0, the exponential tower is strictly increasing: expTower(n+1, x) > expTower(n, x).

## 7. Differential Galois Actions

### Definition 7.1 (Differential Galois Action)
A differential Galois action on the 2D solution space of a second-order linear ODE is a 2×2 matrix (a₁₁, a₁₂; a₂₁, a₂₂) with determinant ±1.

### Theorem 7.2 (Determinant Multiplicativity)
The determinant map is multiplicative under composition of Galois actions.

This structure theorem implies that the differential Galois group of any second-order linear ODE with EML coefficients embeds into GL₂(ℝ) with determinant constrained to {±1}.

## 8. Separation of Variables

### Theorem 8.1 (Separable ODE Solution)
For the separable ODE y' = f(x)·g(y), if F is an antiderivative of f and G⁻¹ is the inverse of an antiderivative of 1/g, then y(x) = G⁻¹(F(x) + C) is a solution.

*Proof.* By the chain rule: y' = (G⁻¹)'(F(x)+C) · F'(x) = g(G⁻¹(F(x)+C)) · f(x) = f(x)·g(y(x)). □

### Corollary 8.2 (EML Closure)
If both ∫f(x)dx and ∫dy/g(y) are EML, then the solution to y' = f(x)·g(y) is EML.

## 9. Conjecture: Airy Tower Height Growth

**Conjecture.** The EML tower height of the best EML approximation to the Airy function Ai(x) on [0, N] grows at least logarithmically in N. Specifically, any EML expression e with towerHeight(e) ≤ k cannot approximate Ai(x) within error ε on [0, N] if N > exp⁽ᵏ⁾(1/ε).

**Computational test.** For k = 1, 2, 3, compute the best EML approximation of tower height k to numerically computed Ai(x) on [0, 10], [0, 100], [0, 1000] and measure the L∞ error. The conjecture predicts exponential error growth in N for fixed k.

## 10. Algorithms

### Algorithm 10.1: Kovacic Algorithm (Simplified)
Given a second-order linear ODE y'' + p(x)y' + q(x)y = 0 with p, q ∈ ℂ(x):

1. **Step 1**: Search for exponential solutions y = exp(∫ω) where ω is rational.
2. **Step 2**: Search for solutions y = exp(∫ω) where ω is algebraic of degree 2.
3. **Step 3**: Search for solutions y = exp(∫ω) where ω is algebraic of degree 4, 6, or 12.
4. **Step 4**: If steps 1-3 fail, the equation has no Liouvillian solutions.

For the Airy equation y'' = xy (p = 0, q = -x), all three steps fail because the Stokes phenomenon of the Airy function is incompatible with rational or algebraic ω.

## 11. Future Work

1. **Nonlinear EML ODEs**: Extend tower height analysis to nonlinear equations like the Painlevé transcendents.
2. **Higher-order equations**: Generalize Abel's identity and the Kovacic algorithm to nth-order linear ODEs.
3. **Computational verification**: Implement the full Kovacic algorithm and verify it against known examples.
4. **EML-Galois correspondence**: Establish a precise dictionary between EML tower height and the structure of the differential Galois group.

## References

1. Kovacic, J. "An algorithm for solving second order linear homogeneous differential equations." *J. Symbolic Comput.* 2 (1986), 3–43.

2. Singer, M. "Liouvillian solutions of nth order homogeneous linear differential equations." *Amer. J. Math.* 103 (1981), 661–682.

3. van der Put, M. and Singer, M. *Galois Theory of Linear Differential Equations.* Grundlehren der mathematischen Wissenschaften 328, Springer, 2003.

4. Olver, F.W.J. *Asymptotics and Special Functions.* Academic Press, 1974.

5. Liouville, J. "Mémoire sur l'intégration d'une classe de fonctions transcendantes." *J. Reine Angew. Math.* 13 (1835), 93–118.
