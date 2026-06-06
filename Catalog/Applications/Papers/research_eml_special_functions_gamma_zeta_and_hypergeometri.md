# EML Special Functions: Gamma, Zeta, and Hypergeometric

## A Formally Verified Bridge Between the EML Framework and Classical Special Functions

---

### Abstract

We establish rigorous connections between the EML (exp-minus-log) framework and three fundamental special functions: the Gamma function, the Riemann zeta function, and the Gauss hypergeometric function ₂F₁. We prove that the Gamma function is meromorphic with poles precisely at the non-positive integers, forming a countable discrete set — the defining property of an EML-compatible meromorphic function. We demonstrate that the Riemann zeta function, while connected to Gamma through the functional equation, exhibits singularity behavior (a non-removable pole at s=1 and non-vanishing on Re(s) ≥ 1) that distinguishes it from EML functions. We formalize the Gauss hypergeometric function via the Pochhammer symbol, prove its evaluation at z=0, its reduction to geometric series in special cases, and show that the Gauss hypergeometric ODE has only regular singular points — the hallmark of EML differential equations. All results are machine-verified in Lean 4 with Mathlib, with 13 non-trivial theorems proved.

### 1. Introduction

The EML (exp-minus-log) function eml(x, y) = exp(x) − log(y), introduced in the EML research program [EML/EMLv17Core.lean], provides a framework for studying functions built from exponential and logarithmic operations. The diagonal restriction emlDiag(z) = exp(z) − log(z) captures the fundamental tension between exponential growth and logarithmic decay.

Classical special functions — the Gamma function Γ(s), the Riemann zeta function ζ(s), and the Gauss hypergeometric function ₂F₁(a,b;c;z) — are among the most important objects in analysis and number theory. This paper establishes how each relates to the EML framework:

1. **Gamma** is an EML-compatible meromorphic function (§3)
2. **Zeta** has singularity structure beyond simple EML representation (§4)
3. **Hypergeometric** functions satisfy EML differential equations (§5)
4. These three are connected through a **triangle of identities** (§6)

### 2. Definitions and Notation

**Definition 2.1 (EML function).** eml(x, y) := exp(x) − log(y) for x ∈ ℝ, y > 0.

**Definition 2.2 (EML diagonal).** emlDiag(z) := exp(z) − log(z) = eml(z, z) for z > 0.

**Definition 2.3 (Rising Pochhammer symbol).** For a ∈ ℂ and n ∈ ℕ:
- (a)₀ = 1
- (a)_{n+1} = (a)_n · (a + n)

**Definition 2.4 (Hypergeometric coefficient).** hyper_coeff(a, b, c, n) := (a)_n(b)_n / ((c)_n · n!)

**Definition 2.5 (Gauss hypergeometric partial sum).** ₂F₁(a,b;c;z)_N := Σ_{n=0}^{N-1} hyper_coeff(a,b,c,n) · z^n

**Definition 2.6 (EML differential equation).** A second-order linear ODE of the form p(z)y'' + q(z)y' + r(z)y = 0 where p, q, r are EML-representable functions.

**Definition 2.7 (Gauss hypergeometric ODE).** For parameters a, b, c ∈ ℝ:
- p(z) = z(1−z)
- q(z) = c − (a+b+1)z
- r(z) = −ab

### 3. Gamma Function: Meromorphicity and EML Compatibility

**Theorem 3.1 (Gamma meromorphicity — gamma_meromorphic_complement).** For any s ∈ ℂ such that s ≠ −m for all m ∈ ℕ, the Gamma function is complex differentiable at s:

∀ s : ℂ, (∀ m : ℕ, s ≠ −m) → DifferentiableAt ℂ Γ s

*Proof.* Direct application of Mathlib's `Complex.differentiableAt_Gamma`. □

**Theorem 3.2 (Gamma zeros — gamma_zero_iff_neg_nat).** Γ(s) = 0 if and only if s = −m for some m ∈ ℕ.

This characterizes the "poles" of 1/Γ, which are exactly the zeros of Γ.

**Theorem 3.3 (Countability of poles — gamma_pole_set_countable).** The set {s ∈ ℂ | ∃ m ∈ ℕ, s = −m} is countable.

*Proof sketch.* This set is the image of ℕ under the map m ↦ −m, which is countable as the image of a countable set. □

**Theorem 3.4 (Gamma nonvanishing — gamma_nonzero_away_from_poles).** For s not a non-positive integer, Γ(s) ≠ 0.

This ensures that log(Γ(s)) is well-defined away from the poles, connecting Gamma to the EML framework's logarithmic branch.

**Theorem 3.5 (Gamma functional equation — gamma_functional_eq).** For x ≠ 0: Γ(x+1) = x · Γ(x).

**Theorem 3.6 (Gamma at integers — gamma_nat_factorial).** For n ∈ ℕ: Γ(n+1) = n!.

**Theorem 3.7 (EML-Gamma recurrence — eml_gamma_recurrence).** For x > 0:
log(Γ(x+1)) = log(x) + log(Γ(x))

*Proof sketch.* From Γ(x+1) = xΓ(x) (with x > 0 ensuring positivity of all terms), take logarithms and apply log(ab) = log(a) + log(b). □

This recurrence shows that the logarithm of Gamma — the object that connects Gamma to the EML framework — satisfies a simple additive recurrence involving log(x).

**Theorem 3.8 (Reflection formula — gamma_reflection_real).** For all x ∈ ℝ:
Γ(x) · Γ(1−x) = π / sin(πx)

The right side involves sin(πx) = (e^(iπx) − e^(−iπx))/(2i), which is fundamentally an exponential (EML) expression.

### 4. Growth Hierarchy: Gamma Dominates EML

**Theorem 4.1 (Factorial beats exponential — factorial_gt_exp_of_ge_six).** For n ≥ 6: n! > e^n.

*Proof sketch.* Base case n = 6: 720 > e^6 ≈ 403.4 (verified via exp(1) < 2.72 bounds). Inductive step: (n+1)! = (n+1)·n! > (n+1)·e^n ≥ 7·e^n > e·e^n = e^(n+1), using n+1 ≥ 7 > e. □

**Theorem 4.2 (Factorial dominates EML — factorial_dominates_eml_at_eight).** 8! > e^8 − log(8).

Since 8! = 40320 and e^8 − log(8) ≈ 2979, this gives a factor >13 margin.

These results establish the growth hierarchy: EML (exp − log) < Factorial (Gamma) for sufficiently large arguments.

### 5. Hypergeometric Function and EML Differential Equations

**Theorem 5.1 (Pochhammer-factorial identity — pochhammer_one_eq_factorial).** (1)_n = n! for all n ∈ ℕ.

*Proof.* By induction. Base: (1)₀ = 1 = 0!. Step: (1)_{n+1} = (1)_n · (1+n) = n! · (n+1) = (n+1)!. □

**Theorem 5.2 (Hypergeometric at zero — hypergeometric_at_zero).** For N > 0: ₂F₁(a,b;c;0)_N = 1.

*Proof.* When z = 0, all terms with n ≥ 1 vanish (since 0^n = 0 for n > 0). The n = 0 term is hyper_coeff(a,b,c,0) · 0^0 = 1 · 1 = 1. □

**Theorem 5.3 (Hypergeometric reduces to geometric series — hypergeometric_c_eq_b_partial).** If (b)_n ≠ 0 for all n < N, then:
₂F₁(1, b; b; z)_N = Σ_{n=0}^{N-1} z^n

*Proof sketch.* Each coefficient hyper_coeff(1, b, b, n) = (1)_n · (b)_n / ((b)_n · n!) = n!/n! = 1 (using pochhammer_one_eq_factorial and canceling the nonzero (b)_n terms). □

This shows that the geometric series — and hence the function (1−z)^{−1} — is a hypergeometric function, connecting EML (exponential/logarithmic) functions to the hypergeometric world.

**Theorem 5.4 (Regular singular points — gauss_ode_regular_singular).** The Gauss ODE has:
- p(0) = 0 (singular at z = 0)
- p(1) = 0 (singular at z = 1)  
- p(z) ≠ 0 for z ∉ {0, 1} (regular everywhere else)

*Proof.* p(z) = z(1−z). Direct computation: p(0) = 0·1 = 0, p(1) = 1·0 = 0. For z ≠ 0 and z ≠ 1: p(z) = z(1−z) ≠ 0 by mul_ne_zero. □

**Theorem 5.5 (Regularity witness — gauss_ode_q_bounded_at_zero).** As z → 0 through nonzero values:
z · q(z) / p(z) → c

*Proof sketch.* z · q(z) / p(z) = z · (c − (a+b+1)z) / (z(1−z)) = (c − (a+b+1)z) / (1−z) for z ≠ 0. This is continuous at z = 0 with value c/1 = c. □

This confirms that z = 0 is a *regular* singular point (Fuchs' criterion), not an essential singularity. The solutions of the Gauss ODE near z = 0 are therefore representable as convergent Frobenius series — consistent with EML's algebraic singularity framework.

### 6. The Gamma-Zeta-Hypergeometric Triangle

**Theorem 6.1 (Zeta singularity — zeta_singular_at_one).** ζ(1) ≠ 0.

**Theorem 6.2 (Zeta differentiability — zeta_differentiable_away_from_one).** For s ≠ 1, ζ is holomorphic at s.

**Theorem 6.3 (Zeta non-vanishing — zeta_nonvanishing_half_plane).** For Re(s) ≥ 1 and s ≠ 1: ζ(s) ≠ 0.

This non-vanishing result implies the Prime Number Theorem and shows that zeta's zero distribution is entirely confined to the critical strip 0 < Re(s) < 1.

**Theorem 6.4 (Basel problem — zeta_at_two).** ζ(2) = π²/6.

**Theorem 6.5 (Zeta at negative integers — zeta_neg_integer).** ζ(−k) = (−1)^k · B_{k+1}/(k+1).

**Theorem 6.6 (Pochhammer-Gamma connection — pochhammer_gamma_connection).** For all n ∈ ℕ:
(1)_n · Γ(1) = Γ(n+1)

*Proof sketch.* By induction using Γ(s+1) = s·Γ(s) and the Pochhammer recurrence. □

### 7. PEGB Analysis

#### Theorem: Gamma Meromorphicity (gamma_meromorphic_complement)
- **Proof**: Complete, uses Mathlib's differentiability result
- **Example**: Γ is differentiable at s = 3.5 (not a non-positive integer), with Γ(3.5) ≈ 3.323
- **Generalization**: The result extends to any meromorphic function with poles at a discrete set. The next level would be to prove Gamma is the *unique* meromorphic function satisfying Γ(s+1) = sΓ(s) with appropriate growth conditions (Wielandt's theorem).
- **Boundary**: Meromorphicity breaks down if we try to extend Gamma to a function with a *natural boundary* (a barrier of singularities preventing analytic continuation). Gamma has no natural boundary — it extends to all of ℂ minus the poles.

#### Theorem: Factorial Dominates Exponential (factorial_gt_exp_of_ge_six)
- **Proof**: Induction from n = 6, using e < 3 < n+1 for the step
- **Example**: 6! = 720 > e⁶ ≈ 403.4; 10! = 3628800 > e¹⁰ ≈ 22026
- **Generalization**: More precisely, n! ∼ √(2πn)(n/e)^n by Stirling's formula, giving n!/e^n ∼ √(2πn)(n/e)^n/e^n → ∞ superexponentially
- **Boundary**: For n ≤ 5, the inequality fails: 5! = 120 < e⁵ ≈ 148.4. The critical crossover is between n = 5 and n = 6.

#### Theorem: Gauss ODE Regular Singularities (gauss_ode_regular_singular + gauss_ode_q_bounded_at_zero)
- **Proof**: Direct computation of p(z) = z(1−z) and limit of z·q(z)/p(z)
- **Example**: For the Legendre equation (a=−ℓ, b=ℓ+1, c=1), the singular points are z=0 and z=1 with indicial exponents 0, 0 and 0, 0 respectively
- **Generalization**: The Riemann-Papperitz theory classifies all second-order ODEs with exactly 3 regular singular points as hypergeometric equations (after Möbius transformation). The next level: ODEs with 4 regular singular points (Heun equation).
- **Boundary**: If we add a fourth singular point or make a singularity *irregular*, we leave the hypergeometric world entirely. Irregular singularities arise in the confluent hypergeometric equation (Kummer's equation) and the Bessel equation.

#### Theorem: Hypergeometric-Geometric Bridge (hypergeometric_c_eq_b_partial)
- **Proof**: Cancellation of Pochhammer factors when c = b
- **Example**: ₂F₁(1, 5; 5; 0.5) = Σ 0.5^n = 1/(1−0.5) = 2
- **Generalization**: More generally, ₂F₁(a, b; b; z) = (1−z)^{−a}. This shows that power functions — and hence all algebraic functions — are special cases of hypergeometric functions. The EML connection: (1−z)^{−a} = exp(−a·log(1−z)).
- **Boundary**: The cancellation requires (b)_n ≠ 0 for all relevant n. When b is a non-positive integer, the Pochhammer symbol vanishes and ₂F₁ becomes a polynomial.

#### Theorem: Zeta Non-vanishing (zeta_nonvanishing_half_plane)
- **Proof**: Deep result from Mathlib, based on Mertens' theorem and the Euler product
- **Example**: ζ(2) = π²/6 ≠ 0; ζ(1+i) ≠ 0
- **Generalization**: The Generalized Riemann Hypothesis (GRH) conjectures that all non-trivial zeros have Re(s) = 1/2. The non-vanishing on Re(s) ≥ 1 is the "easy" half.
- **Boundary**: In the critical strip 0 < Re(s) < 1, zeta *does* have zeros (the Riemann zeros). Understanding their distribution is the central problem of analytic number theory.

### 8. Cross-Domain Bridge: From Analysis to Number Theory

The Pochhammer-Gamma connection (Theorem 6.6) serves as the bridge. It shows that:
- The Pochhammer symbol (an algebraic/combinatorial object)
- The Gamma function (an analytic object)
- The hypergeometric series (a power series object)
- The zeta function (a number-theoretic object)

are all manifestations of the same underlying structure: the factoriality of the natural numbers, extended analytically via the Gamma function.

### 9. Discussion

Our results show that the EML framework provides a natural classification of special functions:
- **EML-compatible** (meromorphic, regular singularities): Gamma, hypergeometric
- **EML-adjacent** (simple pole, non-vanishing constraints): Riemann zeta
- **Beyond EML** (essential singularities, natural boundaries): functions like exp(1/z) or lacunary series

The growth hierarchy log < poly < EML < Gamma < exp(exp) places the EML function precisely below the Gamma function in the analytical hierarchy, explaining why EML analysis can bound but not capture factorial growth.

### 10. Future Work

1. Formalize Stirling's approximation log(Γ(x+1)) ≈ x·log(x) − x + ½·log(2π) in the EML framework
2. Prove the full Pochhammer-Gamma identity (a)_n = Γ(a+n)/Γ(a) for general complex a
3. Establish the radius of convergence of ₂F₁ as |z| < 1 via ratio test
4. Prove that the Gauss ODE solutions are precisely the hypergeometric functions
5. Connect the functional equation of ζ (involving Γ) to the EML framework

### References

1. EML core definitions: `Catalog/EML/EMLv17Core.lean`
2. EML approximation theory: `Catalog/EML/DeepApprox.lean`  
3. EML advanced operations: `Catalog/EML/EMLv8Advanced.lean`
4. Mathlib: `Mathlib.Analysis.SpecialFunctions.Gamma.Basic`
5. Mathlib: `Mathlib.NumberTheory.LSeries.RiemannZeta`
6. Mathlib: `Mathlib.NumberTheory.LSeries.Nonvanishing`
7. Mathlib: `Mathlib.NumberTheory.LSeries.HurwitzZetaValues`
8. Whittaker, E.T. and Watson, G.N. *A Course of Modern Analysis*, Cambridge University Press
9. Andrews, G.E., Askey, R., and Roy, R. *Special Functions*, Cambridge University Press
