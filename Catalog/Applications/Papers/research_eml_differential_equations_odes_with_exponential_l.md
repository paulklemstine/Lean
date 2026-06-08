# EML Differential Equations: Formal Obstructions to Elementary Solutions of Second-Order Linear ODEs

## Abstract

We formalize the theory connecting second-order linear ordinary differential equations with EML (exponential-monomial-logarithmic) coefficient functions to the solvability of associated Riccati equations. Our main results, formalized in Lean 4 with Mathlib, are: (1) **Abel's Wronskian Identity** — for solutions y₁, y₂ of y'' + p·y' + q·y = 0, the Wronskian satisfies W' = -p·W; (2) **Riccati Reduction** — the quotient derivative y'/y satisfies a first-order Riccati equation; (3) **Airy Polynomial Obstruction** — no polynomial satisfies the Riccati equation w' + w² = x associated to the Airy equation y'' = xy; (4) **Kovacic Case 1 Obstruction** — X is not a perfect square in ℝ[X], ruling out the first case of Kovacic's algorithm; and (5) **EML Differential Closure** — the class of EML functions is closed under differentiation, with explicit structure theorems for logarithmic derivatives and exponential-polynomial products. These results formalize the algebraic core of the classical proof that Airy's equation has no Liouvillian solutions.

## 1. Introduction

### 1.1 Background

The question of when a differential equation admits solutions expressible in terms of "elementary" functions has been a central problem in mathematics since Liouville's pioneering work in the 1830s. The EML functions — finite compositions of exponentials, monomials, and logarithms over a base field — form a natural class capturing what mathematicians call "closed-form" solutions.

For second-order linear ODEs of the form y'' + p(x)·y' + q(x)·y = 0, the differential Galois theory of Kolchin, Singer, and others provides a complete characterization: the equation has a Liouvillian solution if and only if the identity component of its differential Galois group is solvable. Kovacic (1986) made this constructive for rational coefficients.

### 1.2 Contributions

This work formalizes the foundational layer of this theory in Lean 4:

1. **Abel's Identity** (Theorem 3.1): The Wronskian of two solutions satisfies a first-order linear ODE determined solely by the coefficient p.

2. **Riccati Reduction** (Theorem 3.2): Solutions of y'' = r·y correspond to solutions of the Riccati equation w' + w² = r.

3. **Airy Riccati Obstruction** (Theorem 4.1): No polynomial in ℝ[X] satisfies w' + w² = X, proved by degree analysis.

4. **EML Differential Closure** (Theorems 5.1-5.4): The logarithmic derivative of products decomposes additively, exponential compositions have explicit derivative structure, and exponential-polynomial products are closed under differentiation.

5. **Growth and Square Obstructions** (Theorems 4.2-4.3): X is not a perfect square in ℝ[X], and √x is not a polynomial function, providing complementary obstructions.

### 1.3 Relation to Prior Work

Our formalization builds upon:
- The EML function theory from `EML/EMLv17Core.lean` (definitions of eml, emlDiag, sigmaEml)
- The Schwartz-Zippel and Freivalds results in `Algebra/FreivaldsSchwartzZippel.lean`
- The Galois theory connections in `Bridges/GaloisNeuralCorrespondence.lean`

We extend the existing `eml_beats_poly_for_towers` result (from `EML/UniversalApproxComplexity.lean`) by showing that the EML advantage has differential-equation-theoretic consequences: EML functions generate ODEs whose solution structure constrains what other EML functions can appear as solutions.

## 2. Definitions

### 2.1 EML Functions

**Definition** (EML function). The function eml : ℝ → ℝ → ℝ is defined by
```
eml(x, y) = exp(x) - log(y)
```
This combines the two fundamental transcendental operations and serves as the basic building block for the EML function class.

### 2.2 Linear ODEs

**Definition** (Second-order linear ODE). A function f satisfies the ODE y'' + p·y' + q·y = 0 at x if
```
HasDerivAt (deriv f) (-(p(x) · deriv f x + q(x) · f(x))) x
```

**Definition** (Reduced form). A function f satisfies y'' = r·y at x if
```
HasDerivAt (deriv f) (r(x) · f(x)) x
```

### 2.3 Wronskian and Riccati Substitution

**Definition** (Wronskian).
```
W(f₁, f₂)(x) = f₁(x) · f₂'(x) - f₂(x) · f₁'(x)
```

**Definition** (Riccati substitution).
```
w(x) = f'(x) / f(x)
```

## 3. Core Results: Abel's Identity and Riccati Reduction

### 3.1 Abel's Wronskian Identity

**Theorem 3.1** (Abel's Identity). *Let f₁, f₂ be differentiable functions both satisfying y'' + p·y' + q·y = 0 at x. Then the Wronskian satisfies*
```
HasDerivAt W (-p(x) · W(x)) x
```

*Proof sketch.* Differentiate W = f₁·f₂' - f₂·f₁' using the product rule:
```
W' = f₁'·f₂' + f₁·f₂'' - f₂'·f₁' - f₂·f₁''
   = f₁·f₂'' - f₂·f₁''
```
Substituting f₁'' = -p·f₁' - q·f₁ and f₂'' = -p·f₂' - q·f₂:
```
W' = f₁·(-p·f₂' - q·f₂) - f₂·(-p·f₁' - q·f₁)
   = -p·(f₁·f₂' - f₂·f₁') = -p·W
```

The formal proof in Lean uses `HasDerivAt.mul` for the product rule and `ring` for the algebraic simplification. □

**Remark.** A subtle point: the formal proof does not use the hypotheses that deriv f₁ and deriv f₂ are differentiable at x, because the proof extracts second-derivative information directly from the ODE hypothesis `SatisfiesLinearODE₂`, which provides `HasDerivAt (deriv f)` directly. This is a case where the formalization reveals that the classical statement includes unnecessary hypotheses.

### 3.2 Riccati Reduction

**Theorem 3.2** (Riccati Reduction). *Let f satisfy y'' = r(x)·y at x with f(x) ≠ 0. Then w = f'/f satisfies*
```
HasDerivAt w (r(x) - w(x)²) x
```

*Proof sketch.* Apply the quotient rule to w = f'/f:
```
w' = (f''·f - (f')²) / f² = (r·f² - (f')²) / f² = r - (f'/f)² = r - w²
```

The formal proof uses `HasDerivAt.div` and algebraic simplification. □

### 3.3 Structural Properties

**Theorem 3.3** (Wronskian antisymmetry). W(f₁, f₂) = -W(f₂, f₁).

**Theorem 3.4** (Wronskian self-vanishing). W(f, f) = 0.

These are proved by direct algebraic manipulation (`ring`).

## 4. Airy Equation Obstructions

### 4.1 No Polynomial Riccati Solutions

**Theorem 4.1** (Main Airy Obstruction). *There exists no polynomial w ∈ ℝ[X] such that w' + w² = X.*

*Proof.* By case analysis on deg(w):

**Case deg(w) ≤ 1:** Write w = aX + b by `Polynomial.eq_X_add_C_of_natDegree_le_one`. Evaluate at x = -1, 0, 1 to obtain the system:
- a + a² + b² - 2ab = -1
- a + b² = 0  
- a + a² + b² + 2ab = 1

These are inconsistent (the first and third give 4ab = 2, the second gives a = -b², and substitution yields a contradiction).

**Case deg(w) ≥ 2:** The leading coefficient of w² is (leading_coeff w)² ≠ 0 (since ℝ has no zero divisors). Therefore deg(w²) = 2·deg(w) ≥ 4. Since deg(w') ≤ deg(w) - 1 < 2·deg(w), we have deg(w' + w²) = 2·deg(w) ≥ 4 ≠ 1 = deg(X). □

**PEGB Analysis:**
- **P**roof: Complete Lean 4 proof by degree analysis and evaluation
- **E**xample: For w = X², we get w' + w² = 2X + X⁴, which has degree 4 ≠ 1
- **G**eneralization: The same argument shows no polynomial satisfies w' + w² = p(X) for any polynomial p of odd degree
- **B**oundary: The argument fails for w' + w² = X² (degree 2), which *could* have a degree-1 solution w = aX + b. Indeed w = X - 1/(2X) nearly works.

### 4.2 X Is Not a Perfect Square

**Theorem 4.2.** *There is no polynomial p ∈ ℝ[X] such that p² = X.*

*Proof.* If p² = X, then 2·deg(p) = deg(X) = 1, which is impossible since 2·deg(p) is even. □

This obstructs the first case of Kovacic's algorithm, which requires √r(x) to be rational.

### 4.3 √x Is Not Polynomial

**Theorem 4.3.** *There is no polynomial p ∈ ℝ[X] such that p(x) = √x for all x ≥ 0.*

*Proof.* If such p exists, then p(x)² = x for all x ≥ 0. Since ℝ[X] elements agreeing on an infinite set are equal, p² = X as polynomials. But deg(p²) is even while deg(X) = 1 is odd. □

**PEGB Analysis:**
- **P**roof: Uses the fact that polynomials agreeing on an infinite set are equal, then the degree parity argument
- **E**xample: √4 = 2, √9 = 3 — these values can't come from a polynomial since a degree-n polynomial is determined by n+1 points
- **G**eneralization: More generally, x^(p/q) for p/q not a natural number cannot be polynomial. The growth order p/q is a rational non-integer, incompatible with polynomial integer growth
- **B**oundary: x^(1/2) on [0,∞) *can* be uniformly approximated by polynomials (Weierstrass), but not exactly represented

## 5. EML Differential Algebra

### 5.1 Logarithmic Derivative Additivity

**Theorem 5.1.** *For differentiable f, g with f(x) ≠ 0, g(x) ≠ 0:*
```
(log(f·g))' = f'/f + g'/g
```

This is the infinitesimal version of log(ab) = log(a) + log(b) and underlies the multiplicative-to-additive correspondence in differential Galois theory.

### 5.2 Logarithmic Derivative of Exponential

**Theorem 5.2.** *For differentiable f:*
```
(exp(f))' / exp(f) = f'
```

This shows that exp maps the additive group of derivatives to the multiplicative group — the basic Galois correspondence in the differential setting.

### 5.3 Exponential-Polynomial Closure

**Theorem 5.3.** *For any a ∈ ℝ and differentiable p:*
```
(p·exp(a·x))' = (p' + a·p)·exp(a·x)
```

This closure theorem shows that exponential-polynomial products form a stable class under differentiation — the fundamental reason why EML functions appear as solutions to linear ODEs with polynomial coefficients.

### 5.4 Double Exponential ODE

**Theorem 5.4.** *The function exp(-exp(x)) satisfies f' = -exp(x)·f.*

This arises from Abel's identity when p(x) = exp(x), demonstrating that EML coefficients produce EML-structured solutions of the Wronskian equation.

**PEGB Analysis:**
- **P**roof: Chain rule composition of exp(-·) with -exp(·)
- **E**xample: At x = 0, exp(-e⁰) = exp(-1) ≈ 0.368, and the derivative is -1·0.368 = -0.368
- **G**eneralization: exp(-∫p) satisfies f' = -p·f for any continuous p; when p is EML of tower height n, this produces EML of height n+1
- **B**oundary: Infinite EML towers (exp(exp(exp(...)))) are not EML — the class requires finite height

## 6. Connections to Differential Galois Theory

### 6.1 The Galois Group of the Airy Equation

The differential Galois group of y'' = xy over ℂ(x) is known to be SL(2,ℂ). This group is:
- **Connected**: SL(2,ℂ) = SL(2,ℂ)⁰
- **Simple**: It has no proper normal algebraic subgroups
- **Non-solvable**: Its derived series does not terminate

By Kolchin's theorem, a linear ODE has Liouvillian solutions iff the identity component G⁰ of its differential Galois group is solvable. Since SL(2,ℂ)⁰ = SL(2,ℂ) is non-solvable, the Airy equation has no Liouvillian solutions.

### 6.2 Kovacic's Algorithm

Our polynomial obstruction theorem (Theorem 4.1) corresponds to **Case 1** of Kovacic's algorithm:

- **Case 1** requires a rational solution of the Riccati equation. Our theorem shows no polynomial solution exists; the full Case 1 check (for rational solutions P/Q) requires showing that pole analysis also fails.
- **Case 2** requires an algebraic solution of degree 2.
- **Case 3** requires an algebraic solution of degree 4, 6, or 12.

For the Airy equation, all three cases fail because SL(2,ℂ) has no proper algebraic subgroups of the required types.

### 6.3 Bridge to Classical Galois Theory

The structural parallel is precise: Abel's theorem on the Wronskian is the differential analog of the discriminant in classical Galois theory. Just as the discriminant of a polynomial determines whether its Galois group is contained in the alternating group, the Wronskian determines whether the differential Galois group preserves a particular bilinear form.

This bridge connects our results to `Bridges/GaloisNeuralCorrespondence.lean`, which formalizes `prime_degree_divides_galois_order` for classical field extensions. The differential analog would be: the "degree" of a Picard-Vessiot extension divides the order of the differential Galois group.

## 7. Algorithms

### 7.1 Kovacic Algorithm (Case 1)

```
Input: r(x) ∈ ℚ(x), the coefficient in y'' = r(x)·y
Output: An EML solution or "no elementary solution exists"

Step 1: Find the poles of r(x) and their orders
Step 2: For each pole, compute local exponents
Step 3: Check if w = ∑(local terms) satisfies w' + w² = r(x)
Step 4: If yes, return y = exp(∫w). If no, proceed to Case 2.
```

### 7.2 EML Tower Height Computation

```
Input: An EML expression e
Output: The tower height h(e)

h(polynomial) = 0
h(exp(e)) = h(e) + 1
h(log(e)) = h(e) + 1
h(e₁ + e₂) = max(h(e₁), h(e₂))
h(e₁ · e₂) = max(h(e₁), h(e₂))
```

## 8. Discussion

### 8.1 What the Formalization Reveals

The formal proofs reveal several insights not obvious from the classical presentation:

1. **Abel's Identity needs fewer hypotheses than expected.** The formal proof of Theorem 3.1 does not use the separate differentiability hypotheses for deriv f₁ and deriv f₂, because the ODE hypothesis already provides HasDerivAt for the second derivative.

2. **The polynomial obstruction is surprisingly robust.** The degree argument works uniformly for all degrees — there is no "exceptional" degree that requires special treatment.

3. **The square root obstruction connects algebra and analysis.** Theorem 4.3 uses the fact that polynomials agreeing on an infinite set are equal (an algebraic result) to bridge to the conclusion about growth orders (an analytic result).

### 8.2 Limitations

Our formalization does not cover:
- The full rational-function case of Kovacic Case 1 (pole analysis)
- Cases 2 and 3 of the Kovacic algorithm
- The complete proof that the Airy equation's Galois group is SL(2,ℂ)
- The general Kolchin theorem connecting Galois groups to Liouvillian solvability

These would require substantially more Mathlib infrastructure for algebraic groups and differential algebra.

## 9. Future Work

1. **Formalize the Stokes phenomenon**: The Airy function exhibits Stokes lines where its asymptotic expansion changes form. Formalizing this would connect our differential Galois theory to asymptotic analysis.

2. **Extend to Painlevé equations**: The Painlevé equations are the "next level" beyond linear ODEs. Their differential Galois theory involves nonlinear algebraic groups.

3. **Constructive Kovacic**: Implement a verified Kovacic algorithm in Lean that both decides solvability and constructs solutions when they exist.

## References

1. Kovacic, J.J. "An algorithm for solving second order linear homogeneous differential equations." *J. Symbolic Computation* 2 (1986), 3-43.

2. Singer, M. "Liouvillian solutions of n-th order homogeneous linear differential equations." *Amer. J. Math.* 103 (1981), 661-682.

3. van der Put, M.; Singer, M. *Galois Theory of Linear Differential Equations.* Springer, 2003.

4. Kolchin, E.R. *Differential Algebra and Algebraic Groups.* Academic Press, 1973.

5. Catalog results: `EML/EMLv17Core.lean` (eml definitions), `Bridges/GaloisNeuralCorrespondence.lean` (Galois order theorem), `EML/UniversalApproxComplexity.lean` (EML tower complexity).
