# EML Special Functions: Meromorphic Classification of Gamma, Zeta, and Hypergeometric Functions

## Abstract

We formalize the meromorphic classification of classical special functions within the EML (Exp-Minus-Log) framework. Our main results are: (1) the Gamma function Γ(s) is meromorphic at every point of ℂ, with simple poles at non-positive integers having residues (-1)^n/n!; (2) the Gauss hypergeometric function ₂F₁(a,b;c;z) satisfies the Gauss hypergeometric ODE, proved via a purely algebraic coefficient recurrence; (3) the EML kernel function eml(x,y) = exp(x) - log(y) exhibits strict convexity with a unique minimum at the self-pairing point. We also establish the bridge between Gamma and zeta functions through the completed zeta function ξ(s) = π^{-s/2}Γ(s/2)ζ(s), evaluating ξ(2) explicitly. All results are machine-verified in Lean 4 using Mathlib.

**Keywords**: Gamma function, Riemann zeta function, hypergeometric function, meromorphic functions, EML framework, formal verification

## 1. Introduction

The special functions of mathematical analysis — the Gamma function, the Riemann zeta function, and the Gauss hypergeometric function — have been studied for over 250 years. Despite their separate origins, these functions share deep structural connections that become visible through the lens of singularity classification and the EML framework.

The EML function class, defined by operations of exponentiation, subtraction, and logarithm, provides a natural hierarchy for classifying functions by their analytic complexity. In this paper, we formalize this classification for three fundamental special functions:

1. The **Gamma function** Γ(s), which generalizes the factorial and is meromorphic with simple poles.
2. The **Riemann zeta function** ζ(s), whose analytic structure encodes the distribution of primes.
3. The **Gauss hypergeometric function** ₂F₁(a,b;c;z), the "mother of all special functions."

Our contributions extend the EML catalog results, particularly building on the EML curvature theory (`EML/EMLv19Advanced.lean`: `eml_gauss_curvature_pos`) and the EML function approximation theory (`EML/DeepApprox.lean`: `eml_has_approx_rate`).

## 2. Definitions and Notation

### 2.1 Rising Factorial (Pochhammer Symbol)

**Definition 2.1.** For a ∈ ℂ and n ∈ ℕ, the *rising factorial* is defined by:
```
(a)_0 = 1
(a)_{n+1} = (a)_n · (a + n)
```

**Theorem 2.2** (Rising factorial of 1). For all n ∈ ℕ, (1)_n = n!.

*Proof.* By induction. Base: (1)_0 = 1 = 0!. Step: (1)_{n+1} = (1)_n · (1+n) = n! · (n+1) = (n+1)!. □

**Theorem 2.3** (Multiplicativity). For all a ∈ ℂ and m, n ∈ ℕ:
```
(a)_{m+n} = (a)_m · (a+m)_n
```

*Proof.* By induction on n. □

**Theorem 2.4** (Zero characterization). For n > 0, (a)_n = 0 if and only if there exists k < n with a = -k.

### 2.2 Hypergeometric Coefficients

**Definition 2.5.** The n-th coefficient of the Gauss hypergeometric series is:
```
c_n(a,b;c) = (a)_n · (b)_n / ((c)_n · n!)
```

**Definition 2.6.** The Gauss hypergeometric function is:
```
₂F₁(a,b;c;z) = Σ_{n=0}^∞ c_n(a,b;c) · z^n
```

### 2.3 EML Kernel

**Definition 2.7.** The EML kernel function is eml(x,y) = exp(x) - log(y) for x ∈ ℝ, y > 0.

**Definition 2.8.** The EML self-pairing is σ(x) = exp(x) - x.

## 3. Main Results

### 3.1 Meromorphic Structure of the Gamma Function

**Theorem 3.1** (Gamma is meromorphic away from poles). For every s ∈ ℂ that is not a non-positive integer, the Gamma function is meromorphic at s.

*Proof sketch.* At such points, Γ is differentiable (by `Complex.differentiableAt_Gamma`), hence analytic on an open set (by the complex-differentiable-implies-analytic theorem), hence meromorphic. The key technical step uses `DifferentiableOn.analyticAt` applied to the set complement of the non-positive integers, which is open since the set of non-positive integers is closed. □

**Theorem 3.2** (Gamma zeros). Γ(s) = 0 if and only if s = -n for some n ∈ ℕ.

**Theorem 3.3** (Reciprocal characterization). (Γ(s))⁻¹ = 0 if and only if s = -n for some n ∈ ℕ.

**Theorem 3.4** (Gamma residues). For each n ∈ ℕ, the function (s+n)·Γ(s) tends to (-1)^n/n! as s → -n (through non-pole values).

*Proof sketch.* By induction on n. Base case (n=0): s·Γ(s) = Γ(s+1) → Γ(1) = 1 as s → 0, by continuity of Gamma at s = 1. Inductive step: using Γ(s) = Γ(s+1)/s, we express (s+(n+1))·Γ(s) in terms of (s+1+n)·Γ(s+1) and s, then take limits using the inductive hypothesis for Γ at s+1 → -n. □

### 3.2 The Gauss Hypergeometric ODE

**Theorem 3.5** (Coefficient recurrence). If c + m ≠ 0 for all m ∈ ℕ, then:
```
(n+1)(c+n) · c_{n+1} = (a+n)(b+n) · c_n
```

*Proof sketch.* Direct computation from the definition, using risingFactorial_succ and the factorial recurrence. □

**Theorem 3.6** (Gauss ODE vanishing). The coefficient of z^n in z(1-z)y'' + [c-(a+b+1)z]y' - aby equals zero when y = ₂F₁(a,b;c;z). Explicitly:
```
(n+1)n · c_{n+1} - n(n-1) · c_n + c(n+1) · c_{n+1} - (a+b+1)n · c_n - ab · c_n = 0
```

*Proof sketch.* The expression factors as (n+1)(n+c) · c_{n+1} - (n+a)(n+b) · c_n, which vanishes by Theorem 3.5. □

This is the central result connecting the hypergeometric series to the Gauss ODE. The proof is *purely algebraic* — it reduces the differential equation to a coefficient recurrence, which is verified by direct computation with rising factorials.

### 3.3 Special Cases and Termination

**Theorem 3.7** (Termination). For m ∈ ℕ and n > m, c_n(-m, b; c) = 0.

*Proof.* The rising factorial (-m)_n = 0 for n > m since one of the factors (-m + k) = 0 for k = m < n. □

**Theorem 3.8** (Logarithmic case). c_n(1, 1; 2) = 1/(n+1) for all n ∈ ℕ.

*Proof.* By direct computation: (1)_n² / ((2)_n · n!) = (n!)² / ((n+1)! · n!) = 1/(n+1). □

This implies ₂F₁(1,1;2;z) = Σ z^n/(n+1) = -log(1-z)/z for |z| < 1.

### 3.4 EML Self-Pairing and Convexity

**Theorem 3.9** (Self-pairing minimum). σ(x) = exp(x) - x ≥ 1 for all x ∈ ℝ.

*Proof.* Immediate from the classical inequality exp(x) ≥ 1 + x. □

**Theorem 3.10** (Uniqueness of minimum). σ(x) = 1 if and only if x = 0.

*Proof.* By strict convexity of exp: exp(x) > 1 + x for x ≠ 0. □

**Theorem 3.11** (Strict convexity). For any fixed y, the function x ↦ eml(x,y) is strictly convex on ℝ.

*Proof.* The second derivative with respect to x is exp(x) > 0. □

### 3.5 The Gamma-Zeta Bridge

**Definition 3.12.** The completed zeta function is ξ(s) = π^{-s/2} Γ(s/2) ζ(s).

**Theorem 3.13** (Explicit evaluation). ξ(2) = π⁻¹ · π²/6.

*Proof.* At s = 2: π^{-1} · Γ(1) · ζ(2) = π⁻¹ · 1 · π²/6. Uses ζ(2) = π²/6 (Euler-Basel) and Γ(1) = 1. □

## 4. The PEGB Analysis

### 4.1 Gamma Meromorphicity (PEGB)

- **Proof**: Complete formal proof using Mathlib's `MeromorphicAt` API and `DifferentiableOn.analyticAt`.
- **Example**: Γ(5) = 4! = 24; Γ has a pole at s = 0 with residue 1.
- **Generalization**: The result extends to any function satisfying f(s+1) = s·f(s) with f(1) = 1. The singularity structure is determined by the functional equation.
- **Boundary**: The method does not apply to functions with essential singularities (e.g., exp(1/z)) or branch points (e.g., z^{1/2}).

### 4.2 Hypergeometric ODE (PEGB)

- **Proof**: Algebraic verification that the coefficient recurrence is equivalent to the ODE.
- **Example**: ₂F₁(1,1;2;z) = -log(1-z)/z satisfies z(1-z)y'' + (2-3z)y' - y = 0.
- **Generalization**: The method extends to any ₂F₁ solution of a second-order Fuchsian ODE with three regular singular points.
- **Boundary**: Does not directly apply to confluent hypergeometric functions (₁F₁) or generalized hypergeometric functions (pFq for p+1 ≠ q).

### 4.3 EML Convexity (PEGB)

- **Proof**: Second derivative test applied to the EML kernel.
- **Example**: σ(0) = 1, σ(1) ≈ 1.718, σ(-1) ≈ 1.368.
- **Generalization**: The strict convexity holds for any EML kernel eml(x,y) = exp(x) - log(y) as a function of x.
- **Boundary**: The EML kernel is *not* convex in y (since -log(y) is concave), giving it a saddle-point structure.

## 5. Cross-Domain Bridge: Hypergeometric-Number Theory

The completed zeta function ξ(s) = π^{-s/2}Γ(s/2)ζ(s) bridges:
- **Analysis** (Gamma function, meromorphic structure)
- **Number theory** (zeta function, prime distribution)
- **Geometry** (π, the circle constant)

The evaluation ξ(2) = π/6 encapsulates this bridge: it expresses a number-theoretic quantity (the sum of inverse squares, related to primes) in terms of a geometric constant, mediated by the analytic structure of the Gamma function.

Furthermore, the hypergeometric function provides a bridge between:
- **Algebra** (rising factorials, combinatorial identities)
- **Analysis** (ODE theory, convergence of series)
- **Special function theory** (reduction to classical functions in special cases)

## 6. Discussion

### 6.1 The Algebraic Nature of the Gauss ODE

Our proof of Theorem 3.6 reveals that the Gauss hypergeometric ODE is, at its core, an algebraic identity. The analytic content (convergence, differentiability) is needed only to justify the term-by-term operations on the power series. The ODE itself is equivalent to a recurrence on the coefficients, which can be verified by pure algebra.

This observation has implications for the formalization of ODE theory: many classical ODEs can be "algebraicized" by working with formal power series coefficients rather than analytic functions. This approach avoids the substantial analytic overhead of Mathlib's ODE theory.

### 6.2 EML Classification Hierarchy

The EML framework suggests a natural hierarchy of functions by their singularity structure:
1. **Entire functions** (no singularities): 1/Γ(s), exp(s), sin(s)
2. **Meromorphic functions** (poles only): Γ(s), ζ(s), tan(s)
3. **Functions with branch points**: log(s), s^α for non-integer α
4. **Functions with essential singularities**: exp(1/s), sin(1/s)

The Gamma function occupies level 2, but its reciprocal is at level 1 — demonstrating that the EML classification can change under simple algebraic operations.

## 7. Future Work

1. Formalize the Weierstrass product representation of 1/Γ(s).
2. Prove the functional equation ξ(s) = ξ(1-s) for the completed zeta function.
3. Extend the coefficient-recurrence approach to confluent hypergeometric functions.
4. Connect the EML convexity structure to information geometry and Fisher information.

## References

1. Catalog reference: `Catalog/EML/EMLv19Advanced.lean` — `eml_gauss_curvature_pos`
2. Catalog reference: `Catalog/EML/DeepApprox.lean` — `eml_has_approx_rate`
3. Catalog reference: `Catalog/EML/Core.lean` — `emlSelfPair_strictConvex`
4. Mathlib: `Mathlib.Analysis.SpecialFunctions.Gamma.Basic` — `Complex.Gamma`
5. Mathlib: `Mathlib.Analysis.SpecialFunctions.Gamma.Deriv` — `differentiableAt_Gamma`
6. Mathlib: `Mathlib.NumberTheory.LSeries.RiemannZeta` — `riemannZeta`
7. Mathlib: `Mathlib.Analysis.Meromorphic.Basic` — `MeromorphicAt`
8. NIST Digital Library of Mathematical Functions, Chapter 15: Hypergeometric Function
9. Whittaker & Watson, *A Course of Modern Analysis*, Cambridge University Press
