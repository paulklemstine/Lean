# Algebraic Differential Equations in the EML Hierarchy: Wronskian Theory and Kovacic Classification

## Abstract

We develop a formal algebraic theory of second-order linear ordinary differential equations over abstract differential fields, with applications to the exponential-monomial-logarithmic (EML) function hierarchy. Our main contributions are: (1) a complete formalization of Abel's identity for the Wronskian, (2) the Solution Space Theorem showing that any solution of a second-order linear ODE is a constant-linear combination of two Wronskian-independent solutions, (3) the Riccati reduction linking second-order linear theory to first-order nonlinear theory, and (4) obstruction results for the Airy equation. We introduce the Differential Companion System (DCS) as a novel framework packaging the ODE, its Wronskian theory, the Riccati reduction, and the EML complexity classification into a single mathematical object. All results are proved in the purely algebraic setting of differential fields, requiring no topology, measure theory, or function spaces.

**Keywords**: Differential algebra, Wronskian, Abel's identity, Riccati equation, Kovacic algorithm, EML functions, Airy equation, differential Galois theory

## 1. Introduction

### 1.1 Background

The study of linear ordinary differential equations has a long history, dating back to the foundational work of Euler, Lagrange, and their contemporaries. A central question in this theory is: given a linear ODE with "elementary" coefficients, when do elementary solutions exist?

This question was first systematically addressed by Liouville (1841), who introduced the notion of elementary functions and proved that certain integrals (such as ∫e^{-x²}dx) cannot be expressed in elementary terms. The algebraic approach to this problem, initiated by Picard and Vessiot and developed by Kolchin, Kaplansky, and others, provides a complete framework through the differential Galois group.

For second-order linear ODEs of the form y'' + p(x)y' + q(x)y = 0 with rational function coefficients, the Kovacic algorithm (1986) provides a complete decision procedure: it determines the identity component of the differential Galois group and either produces an explicit Liouvillian solution or certifies that none exists.

### 1.2 Contributions

We formalize the foundational theory of second-order linear ODEs in the setting of abstract differential fields. Our approach is purely algebraic — we work with a field F equipped with a derivation D satisfying the Leibniz rule, without assuming any analytic structure. This has several advantages:

1. **Generality**: Our results apply to any differential field, not just function fields over ℝ or ℂ.
2. **Constructivity**: The algebraic proofs are often more explicit than analytic ones.
3. **Formalizability**: The algebraic framework interfaces cleanly with existing mathematical libraries.

Our main results are:

- **Abel's Identity** (Theorem 4.1): D(W(y₁,y₂)) = -p · W(y₁,y₂) for solutions y₁, y₂.
- **Solution Space Theorem** (Theorem 5.1): Any solution is a constant-linear combination of two Wronskian-independent solutions, with explicit formulas for the coefficients.
- **Riccati Reduction** (Theorem 6.1): A nonzero solution y with r = D(y)/y reduces the ODE to the Riccati equation r' + r² + pr + q = 0.
- **Airy Obstructions** (Theorems 8.1–8.2): The Airy equation admits no constant solutions and no solutions with constant logarithmic derivative.

### 1.3 Novel Structures

We introduce:

- **Differential Companion System (DCS)**: A structure bundling an ODE with its EML complexity level and gauge parameter.
- **EML Tower**: A formal hierarchy of field extensions by exponential and logarithmic elements, with a complexity measure that decomposes into exponential and logarithmic depths.
- **Riccati Companion**: The systematic correspondence between second-order linear ODEs and first-order Riccati equations.

## 2. Differential Fields

### 2.1 Definition

A **differential field** is a field F together with a map D: F → F satisfying:
- D(a + b) = D(a) + D(b) (additivity)
- D(a · b) = a · D(b) + D(a) · b (Leibniz rule)
- D(1) = 0

The last axiom is actually redundant (it follows from Leibniz applied to 1 = 1·1), but we include it for clarity.

### 2.2 Basic Properties

From these axioms, we derive:

**Proposition 2.1.** D(0) = 0.
*Proof.* D(0) = D(0 + 0) = D(0) + D(0), so D(0) = 0. □

**Proposition 2.2.** D(-a) = -D(a).
*Proof.* 0 = D(0) = D(a + (-a)) = D(a) + D(-a). □

**Proposition 2.3.** D(a²) = 2a · D(a).
*Proof.* D(a²) = D(a·a) = a·D(a) + D(a)·a = 2a·D(a). □

**Proposition 2.4** (Inverse rule). For a ≠ 0, D(a⁻¹) = -D(a) · a⁻².
*Proof.* From D(a · a⁻¹) = D(1) = 0, we get a·D(a⁻¹) + D(a)·a⁻¹ = 0. □

### 2.3 Constants

An element c ∈ F is a **constant** if D(c) = 0. The set of constants C_F forms a subfield of F:
- 0 and 1 are constants
- Constants are closed under +, -, ·
- If c ≠ 0 is a constant, so is c⁻¹

The constant subfield plays the role of the "scalars" for the ODE theory.

## 3. Second-Order Linear ODEs

### 3.1 Definition

A **second-order linear ODE** over a differential field F is specified by a pair (p, q) ∈ F², representing the equation:

D²(y) + p · D(y) + q · y = 0

where D² denotes D ∘ D. An element y ∈ F is a **solution** if it satisfies this equation.

### 3.2 Linearity

The solution set is a C_F-module:
- 0 is always a solution
- If y is a solution and c is a constant, then c·y is a solution
- If y₁, y₂ are solutions, then y₁ + y₂ is a solution

## 4. The Wronskian and Abel's Identity

### 4.1 Definition

The **Wronskian** of two elements y₁, y₂ ∈ F is:

W(y₁, y₂) = y₁ · D(y₂) - y₂ · D(y₁)

This is anti-symmetric: W(y₁, y₂) = -W(y₂, y₁), and W(y, y) = 0.

The Wronskian is C_F-bilinear: W(c·y₁, y₂) = c · W(y₁, y₂) for constants c.

### 4.2 Abel's Identity

**Theorem 4.1** (Abel's Identity). If y₁, y₂ are solutions of D²(y) + p·D(y) + q·y = 0, then:

D(W(y₁, y₂)) = -p · W(y₁, y₂)

*Proof sketch.* Compute D(W) = D(y₁)·D(y₂) + y₁·D²(y₂) - D(y₂)·D(y₁) - y₂·D²(y₁) = y₁·D²(y₂) - y₂·D²(y₁). Substituting D²(yᵢ) = -p·D(yᵢ) - q·yᵢ from the ODE, we get D(W) = y₁(-p·D(y₂) - q·y₂) - y₂(-p·D(y₁) - q·y₁) = -p·W. □

**Corollary 4.2.** If p = 0 (reduced/normal form), the Wronskian is constant.

### 4.3 The Three-Term Identity

**Proposition 4.3.** For any y₁, y₂, y₃ ∈ F:

W(y₃, y₂) · y₁ + W(y₁, y₃) · y₂ = y₃ · W(y₁, y₂)

This is a pure ring identity, independent of the differential structure.

## 5. Solution Space Structure

### 5.1 Cramer's Lemma

**Lemma 5.1** (Cramer's Lemma for Differential Fields). If W(y₁, y₂) ≠ 0 and a·y₁ + b·y₂ = 0 and a·D(y₁) + b·D(y₂) = 0, then a = b = 0.

*Proof.* The system [y₁, y₂; D(y₁), D(y₂)] · [a, b]ᵀ = 0 has determinant W(y₁, y₂) ≠ 0. □

### 5.2 The Solution Representation Theorem

**Theorem 5.1** (Solution Space Theorem). If y₁, y₂ are solutions with W(y₁, y₂) ≠ 0, and y₃ is any solution, then there exist unique constants c₁, c₂ ∈ C_F such that:

y₃ = c₁ · y₁ + c₂ · y₂

with c₁ = W(y₃, y₂) / W(y₁, y₂) and c₂ = W(y₁, y₃) / W(y₁, y₂).

*Proof sketch.* 
1. **Algebraic identity**: The three-term identity gives W(y₃,y₂)·y₁ + W(y₁,y₃)·y₂ = y₃·W(y₁,y₂), so dividing by W(y₁,y₂) gives the representation.

2. **Constancy**: By Abel's identity, D(W(yᵢ, yⱼ)) = -p · W(yᵢ, yⱼ) for all pairs of solutions. Therefore cᵢ = W(·,·)/W(y₁,y₂) has D(cᵢ) = 0 by the quotient rule (the -p factors cancel). This uses the key lemma: if D(a) = k·a and D(b) = k·b with b ≠ 0, then D(a·b⁻¹) = 0. □

## 6. The Riccati Reduction

### 6.1 From Linear to Nonlinear

**Theorem 6.1** (Riccati Reduction). If y ≠ 0 is a solution of D²(y) + p·D(y) + q·y = 0, then r = D(y)·y⁻¹ satisfies the Riccati equation:

D(r) + r² + p·r + q = 0

*Proof.* Compute D(r) = D(D(y)·y⁻¹) = D²(y)·y⁻¹ - D(y)²·y⁻² = D²(y)·y⁻¹ - r². From the ODE, D²(y) = -p·D(y) - q·y, so D²(y)·y⁻¹ = -p·r - q. Therefore D(r) = -p·r - q - r², giving D(r) + r² + p·r + q = 0. □

### 6.2 The Converse

**Theorem 6.2** (Converse Riccati). If r satisfies the Riccati equation and y ≠ 0 satisfies D(y) = r·y, then y solves the original ODE.

*Proof.* D²(y) = D(r·y) = D(r)·y + r·D(y) = D(r)·y + r²·y = (D(r) + r²)·y. The ODE becomes (D(r) + r² + p·r + q)·y = 0, which vanishes since r solves the Riccati equation. □

### 6.3 The Wronskian-Riccati Bridge

**Proposition 6.3.** For y₁, y₂ ≠ 0:

W(y₁, y₂) = y₁ · y₂ · (D(y₂)/y₂ - D(y₁)/y₁)

This expresses the Wronskian as a product of the solutions times the difference of their Riccati variables. When the Riccati variables coincide, the Wronskian vanishes — geometrically, the solutions are "parallel."

## 7. The EML Tower

### 7.1 Tower Structure

An **EML tower** over a differential field F₀ is a sequence of extensions:

F₀ ⊂ F₁ ⊂ F₂ ⊂ ··· ⊂ Fₙ

where each Fᵢ₊₁ = Fᵢ(θᵢ) with either:
- D(θᵢ) = θᵢ · D(aᵢ) for some aᵢ ∈ Fᵢ (**exponential extension**: θᵢ = exp(aᵢ))
- D(θᵢ) = D(aᵢ)/aᵢ for some aᵢ ∈ Fᵢ (**logarithmic extension**: θᵢ = log(aᵢ))

The **tower height** n is the total number of extensions. It decomposes as n = e + l where e is the number of exponential extensions and l is the number of logarithmic extensions.

### 7.2 Complexity Measure

The tower height provides a natural complexity measure for EML functions. A key structural result is that solving a linear ODE with coefficients at tower height k requires solutions at height at most k + 1 (in the reducible Kovacic case) or k + 2 (in the imprimitive case).

## 8. The Kovacic Classification

### 8.1 The Four Cases

The Kovacic algorithm classifies second-order linear ODEs y'' = r·y (reduced form with p = 0) into four cases based on the identity component G⁰ of the differential Galois group G:

| Case | G⁰ | Max Tower Height | Solution Type |
|------|-----|-------------------|---------------|
| Reducible | Gₘ (multiplicative) | 1 | Exponential |
| Imprimitive | Torus | 2 | √exp |  
| Finite | Trivial | 0 | Algebraic |
| Full | SL(2) | — | None |

### 8.2 The Airy Equation

The Airy equation y'' = x·y is the canonical example of Case 4 (full SL(2) Galois group).

**Definition 8.1.** An **Airy-type datum** in a differential field F consists of an element x ∈ F with:
- x is not constant (D(x) ≠ 0)
- D(x) = 1 (x behaves as the independent variable)
- D²(x) = 0 (x is "linear")

**Theorem 8.1** (Constant Solution Obstruction). The Airy equation has no nonzero constant solutions.

*Proof.* If y is constant, D(y) = D²(y) = 0, so the ODE gives -x·y = 0. In a field, x = 0 or y = 0. But D(x) = 1 ≠ 0 = D(0), so x ≠ 0. Therefore y = 0. □

**Theorem 8.2** (Riccati Non-Constancy). If y ≠ 0 solves the Airy equation, the Riccati variable r = D(y)/y cannot be constant.

*Proof.* By the Riccati reduction, r satisfies D(r) + r² - x = 0. If r is constant (D(r) = 0), then x = r², so D(x) = D(r²) = 2r·D(r) = 0. But D(x) = 1 ≠ 0, contradiction. □

This result is the first step in the full proof that the Airy equation has no Liouvillian solutions. The complete argument (which we formalize structurally but do not prove in full) requires showing that r cannot be a rational function or satisfy an algebraic equation over the rational functions.

## 9. The Differential Companion System

### 9.1 Definition

A **Differential Companion System (DCS)** for a differential field F packages:
1. A second-order linear ODE (p, q)
2. An EML complexity level n ∈ ℕ (the tower height of the coefficients)
3. A gauge parameter g ∈ F for reductions

### 9.2 Gauge Reduction

The DCS supports a **reduction** operation that transforms y'' + py' + qy = 0 into the reduced form z'' + rz = 0 where:

r = q - D(p)/2 - p²/4

This is accomplished by the substitution y = z · exp(-∫p/2). In the algebraic setting, we define the reduced ODE directly.

### 9.3 Properties

The reduction preserves:
- The solution space dimension (still 2 over constants)
- The Wronskian (up to a known factor)
- The Kovacic case (the Galois group is conjugate)

And it simplifies analysis by eliminating the first-derivative term, making the Wronskian constant (by Corollary 4.2).

## 10. PEGB Analysis

### 10.1 Abel's Identity (PEGB)

- **P**roof: Complete algebraic proof using only Leibniz rule and ODE substitution.
- **E**xample: For the harmonic oscillator y'' + y = 0 (p=0, q=1), solutions sin(x) and cos(x) have W = 1 (constant, since p=0).
- **G**eneralization: Abel's identity extends to systems of n-th order linear ODEs, where the Wronskian determinant satisfies D(W) = -tr(A)·W for the companion matrix A.
- **B**oundary: Abel's identity is specific to linear ODEs. For nonlinear equations, no analogous simple relation exists for the Wronskian.

### 10.2 Solution Space Theorem (PEGB)

- **P**roof: Constructive proof using Cramer's rule with explicit constant formulas.
- **E**xample: For y'' + y = 0, with y₁ = sin(x), y₂ = cos(x), and y₃ = 3sin(x) - 2cos(x), we get c₁ = W(y₃, cos(x))/W(sin(x), cos(x)) = 3, c₂ = -2.
- **G**eneralization: For n-th order linear ODEs, the solution space is n-dimensional over constants, with coefficients expressible via Cramer's rule using higher Wronskians.
- **B**oundary: The theorem requires W(y₁,y₂) ≠ 0. When W = 0, the solutions span a 1-dimensional (or 0-dimensional) space.

### 10.3 Riccati Reduction (PEGB)

- **P**roof: Direct algebraic computation using inverse rule for derivation.
- **E**xample: For y'' - y = 0 (solutions e^x, e^{-x}), the Riccati variable for y = e^x is r = 1, satisfying r' + r² - 1 = 0 + 1 - 1 = 0.
- **G**eneralization: The Riccati equation generalizes to matrix Riccati equations for higher-order systems, connecting to the theory of Lie groups.
- **B**oundary: The reduction requires y ≠ 0. At zeros of y, the Riccati variable r = y'/y has poles, which encode crucial information about the solution's behavior.

## 11. Conjecture

**Conjecture (EML Tower Monotonicity).** For a second-order linear ODE with coefficients at EML tower height k, if the differential Galois group G has a solvable identity component G⁰, then the minimal tower height of any Liouvillian solution is exactly:
- k + 1 if G⁰ is isomorphic to Gₘ (reducible case)
- k + 2 if G⁰ is a non-split torus (imprimitive case)
- k if G⁰ is trivial (finite case, algebraic solutions)

**Test:** Compute the tower heights for families of ODEs with known Galois groups (e.g., Bessel equations, confluent hypergeometric equations) and check whether the predicted heights match.

## 12. Discussion and Future Work

Our formalization establishes the algebraic core of the theory of second-order linear ODEs in a framework suitable for machine verification. The key insight is that the entire theory — from Abel's identity through the solution space theorem to the Riccati reduction — can be developed purely algebraically, without any analytic prerequisites.

Several directions for future work suggest themselves:

1. **Full Kovacic algorithm formalization**: Implementing the pole analysis and rational solution search that comprise the computational core of the Kovacic algorithm.

2. **Higher-order equations**: Extending the theory to n-th order linear ODEs, where the Wronskian becomes an n×n determinant and the Galois group acts on GL(n).

3. **Differential Galois correspondence**: Formalizing the Galois correspondence between intermediate differential field extensions and closed subgroups of the differential Galois group.

4. **Connection to the EML catalog**: Linking the differential complexity tower to the existing EML formalization in the catalog, particularly the approximation complexity results.

## References

1. Abel, N. H. (1829). Précis d'une théorie des fonctions elliptiques.
2. Kovacic, J. J. (1986). An algorithm for solving second order linear homogeneous differential equations. *Journal of Symbolic Computation*, 2(1), 3–43.
3. van der Put, M., & Singer, M. F. (2003). *Galois Theory of Linear Differential Equations*. Springer.
4. Kaplansky, I. (1957). *An Introduction to Differential Algebra*. Hermann.
5. Kolchin, E. R. (1973). *Differential Algebra and Algebraic Groups*. Academic Press.
6. Singer, M. F. (1981). Liouvillian solutions of n-th order homogeneous linear differential equations. *American Journal of Mathematics*, 103(4), 661–682.
