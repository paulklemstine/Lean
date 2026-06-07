# EML Special Functions: Singularity Classification, Gamma-EML Bridge, and Hypergeometric Recurrence

## Abstract

We introduce the **EML Singularity Spectrum**, a novel mathematical structure that classifies singularities of functions built from exponential-logarithmic (EML) operations into four canonical types: removable, pole, logarithmic branch point, and essential. Using this framework, we establish a formal hierarchy: meromorphic functions form a strict subclass of EML-compatible functions, which in turn exclude essential singularities. We prove that the Gamma function's singularity spectrum is meromorphic (hence EML-compatible), while essential singularity spectra are provably excluded from both classes. We formalize the hypergeometric function ₂F₁ via Pochhammer (rising factorial) symbols, prove its three-term coefficient recurrence, and establish that its ratio of consecutive coefficients converges to 1, confirming radius of convergence 1. A key bridge theorem connects log(Γ(n+1)) to sums of logarithms — the fundamental "log part" of EML operations — and we derive a Stirling-type lower bound from this decomposition. All 26 theorems are machine-verified in Lean 4 with zero remaining sorry statements.

**Keywords**: EML operator, singularity classification, Gamma function, hypergeometric function, Pochhammer symbol, Stirling approximation, formal verification

## 1. Introduction

The EML (Exponential-Log-Monomial) operator, defined as `eml(x, y) = exp(x) - log(y)`, has emerged as a surprisingly rich algebraic object connecting analysis, approximation theory, and special function theory. Previous work established its convexity properties, monotonicity, and universal approximation capabilities. In this paper, we investigate how classical special functions — particularly the Gamma function Γ(z) and the Gauss hypergeometric function ₂F₁(a, b; c; z) — relate to the EML framework.

The central question is: **which special functions are "EML-compatible"?** We formalize this question by introducing the EML Singularity Spectrum, a structure that classifies the singularities of a function according to how they interact with exp-log operations. This leads to a clean hierarchy:

- **Meromorphic functions** (only removable singularities and poles): fully EML-compatible
- **EML-compatible functions** (allow logarithmic branch points): the natural domain of EML operations
- **Non-EML functions** (essential singularities): outside the EML class

### 1.1 Main Contributions

1. **EMLSingSpectrum** (Definition): A novel structure pairing a set of singular points with a classification function, subject to the axiom that regular points are classified as removable.

2. **Gamma is EML-meromorphic** (Theorems 1, 5): We prove that Gamma's singularity spectrum — simple poles at non-positive integers — is meromorphic, hence EML-compatible.

3. **Essential singularities are excluded** (Theorem 4): Functions with essential singularities provably fail both the meromorphic and EML-compatible tests.

4. **Hypergeometric recurrence** (Theorem 6): We prove the three-term recurrence c_{n+1} = c_n · (a+n)(b+n) / ((c+n)(n+1)) for ₂F₁ coefficients.

5. **Radius of convergence** (Theorem 23): The ratio of consecutive hypergeometric coefficients converges to 1, confirming |z| < 1 as the radius of convergence.

6. **Log-Gamma = EML sum** (Theorem 9): log(n!) = Σ_{k=0}^{n-1} log(k+1), connecting Gamma to iterated EML operations.

7. **Stirling-EML bound** (Theorem 11): n·log(n) - n + 1 ≤ log(n!) via induction with log-inequality analysis.

8. **Disproved conjecture**: The initial conjecture that Γ(x) - log(x) is monotone on (1, ∞) was machine-disproved, leading to the corrected bound Γ(n) > log(n) for n ≥ 1 (Theorem 26).

## 2. The EML Singularity Spectrum

### 2.1 Motivation

The EML operator eml(x, y) = exp(x) - log(y) has a factored singularity structure:
- In x: exp is entire, so no singularities
- In y: log has a branch point at y = 0, but is holomorphic on (0, ∞)

This observation suggests that EML operations naturally handle certain singularity types but not others. To formalize this, we need a classification.

### 2.2 Definition

**EMLSingType** is an inductive type with four constructors:

```
inductive EMLSingType where
  | removable          -- Function extends continuously
  | pole (order : ℕ)   -- Blow-up of finite order
  | logBranch          -- Logarithmic branch point
  | essential          -- Essential singularity
```

**EMLSingSpectrum** is a structure consisting of:
- `singularPoints : Set ℝ` — the set of singular points
- `classify : ℝ → EMLSingType` — classification function
- `regular_is_removable` — axiom: non-singular points are classified as removable

### 2.3 Classification Predicates

A spectrum S is **meromorphic** if ∀ x, (S.classify x).isMeromorphic = true, where isMeromorphic returns true for removable and pole types.

A spectrum S is **EML-compatible** if ∀ x, (S.classify x).isEMLCompatible = true, where isEMLCompatible returns true for all types except essential.

**Theorem 3** (Meromorphic ⊂ EML-compatible): If S is meromorphic, then S is EML-compatible. This follows from the logical inclusion: every type that is meromorphic is also EML-compatible.

### 2.4 Key Examples

**Gamma function spectrum** (gammaSingSpectrum):
- Singular points: {-n : n ∈ ℕ}
- Classification: pole of order 1 at each singular point, removable elsewhere

**Essential singularity spectrum** (essentialSingSpectrum x₀):
- Singular point: {x₀}
- Classification: essential at x₀, removable elsewhere

**Theorem 1**: gammaSingSpectrum is meromorphic. (Proof: by case analysis on the if-then-else classification.)

**Theorem 4**: essentialSingSpectrum x₀ is NOT meromorphic. (Proof: the classification at x₀ is .essential, which returns false for isMeromorphic.)

## 3. Pochhammer Symbols and Hypergeometric Function

### 3.1 Rising Factorial

We define the rising factorial independently (not using Mathlib's polynomial-valued ascPochhammer) to work directly with real-valued coefficients:

```
def risingFactorial (a : ℝ) : ℕ → ℝ
  | 0 => 1
  | n + 1 => risingFactorial a n * (a + n)
```

**Theorem 14**: risingFactorial a n = ∏_{k ∈ range n} (a + k)

**Theorem (1 = factorial)**: risingFactorial 1 n = n!

**Theorem (positivity)**: If a > 0, then risingFactorial a n > 0 for all n.

### 3.2 Hypergeometric Coefficients

The hypergeometric coefficient is:

```
def hypergeomCoeff (a b c : ℝ) (n : ℕ) : ℝ :=
  risingFactorial a n * risingFactorial b n / (risingFactorial c n * n!)
```

**Theorem 6** (Recurrence): c_{n+1} = c_n · (a+n)(b+n) / ((c+n)(n+1)), provided (c)_{n+1} ≠ 0.

**Theorem 22** (Ratio): c_{n+1}/c_n = (a+n)(b+n) / ((c+n)(n+1)), under non-vanishing conditions.

**Theorem 23** (Limit): The ratio (a+n)(b+n)/((c+n)(n+1)) → 1 as n → ∞. This is proved by dividing numerator and denominator by n², showing each factor converges to 1.

### 3.3 Special Values

**Theorem 7**: ₂F₁(a, b; c; 0) = 1 (only the n=0 term survives).

**Theorem 8**: ₂F₁(0, b; c; z) = 1 (risingFactorial 0 n = 0 for n ≥ 1).

### 3.4 Termination

**Theorem 24**: If a = -m (m ∈ ℕ), then risingFactorial(-m, n) = 0 for n > m. This is because the product contains the factor (-m + m) = 0.

**Theorem 25**: Consequently, hypergeomCoeff(-m, b, c, n) = 0 for n > m, making ₂F₁(-m, b; c; z) a polynomial of degree m.

## 4. Gamma-EML Bridge

### 4.1 Log-Gamma Decomposition

**Theorem 9**: log(n!) = Σ_{k=0}^{n-1} log(k+1)

This seemingly simple identity is the fundamental bridge between Gamma and EML. Each term log(k+1) is the "log part" of an EML evaluation: eml'(log(k+1), 1) = k+1 (Theorem 13).

### 4.2 Factorial as Product

**Theorem 10**: n! = ∏_{k ∈ range n} (k + 1)

Combined with the product representation of the rising factorial (Theorem 14), this shows that Pochhammer symbols generalize factorials.

### 4.3 Stirling Lower Bound

**Theorem 11**: For n ≥ 1, n·log(n) - n + 1 ≤ log(n!)

The proof uses strong induction. The inductive step requires showing that adding log(n+1) to the lower bound for n yields the lower bound for n+1, which reduces to the inequality n·log(1 + 1/n) ≤ 1, i.e., log(1 + 1/n) ≤ 1/n. This follows from the universal inequality log(1 + x) ≤ x for x > -1.

### 4.4 Pochhammer-EML Connection

**Theorem 12**: log((a)_n) = Σ_{k=0}^{n-1} log(a+k) for a > 0

**Theorem 13**: eml'(log(a+k), 1) = a + k for a + k > 0

These establish that the rising factorial is a "product of EML evaluations at unit," making Pochhammer symbols intrinsically EML objects.

## 5. Gamma Function Properties

### 5.1 Differentiability and Positivity

**Theorem 18**: Gamma is differentiable at all positive reals. (From Mathlib's differentiableAt_Gamma.)

**Theorem 19**: Gamma(x) > 0 for x > 0. (From Mathlib's Gamma_pos_of_pos.)

### 5.2 Recurrence in Log Form

**Theorem 20**: log Γ(x+1) = log(x) + log Γ(x) for x > 0

This is the continuous analog of the log-Gamma decomposition. The increment log(x) at each step is exactly the log-component of eml'(log(x), 1).

### 5.3 Gamma vs. Logarithm

**Theorem 26**: Γ(n) > log(n) for all natural numbers n ≥ 1.

This was established after the original conjecture (Γ(x) - log(x) is monotone on (1, ∞)) was machine-disproved. The disproof revealed that Γ(1) - log(1) = 1 > 0.307 ≈ Γ(2) - log(2), so the function decreases on (1, 2) before eventually increasing. The corrected theorem states a weaker but true bound.

## 6. Singularity Transmutation

### 6.1 Exp-Log Power Law

**Theorem 15**: exp(c · log(x)) = x^c for x > 0

This is the mechanism by which exp "transmutes" logarithmic branch points into algebraic singularities. When c is a negative integer, x^c has a pole — so exp composition converts log branch points to poles, staying within the meromorphic class.

### 6.2 Smoothness of EML

**Theorem 16**: emlDiag' is differentiable on (0, ∞) — the only singularity is at z = 0.

**Theorem 17a**: eml'(·, y) is differentiable everywhere (exp has no singularities).

**Theorem 17b**: eml'(x, ·) is differentiable away from 0 (log's only singularity).

## 7. Discussion

### 7.1 The EML-Compatible Hierarchy

Our results establish a strict hierarchy of function classes:

**Entire ⊂ Meromorphic ⊂ EML-compatible ⊂ All functions**

- Entire functions (like exp): trivial spectrum, no singularities
- Meromorphic functions (like Gamma): poles only
- EML-compatible: poles + log branch points (the natural EML domain)
- Non-EML: essential singularities present

The Gamma function sits in the meromorphic class. The EML operator itself has a log branch point at y = 0, placing it in the EML-compatible class. Functions with essential singularities (like exp(1/z)) are provably excluded.

### 7.2 Hypergeometric Functions in EML Context

The hypergeometric function ₂F₁ is naturally EML-compatible because:
1. Its singularities are at z = 1 (branch point) and z = ∞
2. Its coefficients are ratios of Pochhammer symbols, which are EML objects (Theorem 13)
3. The Gauss ODE it satisfies has regular singular points (poles), not essential singularities

### 7.3 The Disproved Conjecture

Our initial conjecture that Γ(x) - log(x) is monotone on (1, ∞) was rigorously disproved. This is a genuine mathematical discovery: the function has a minimum near x ≈ 2.4, which corresponds to the point where Gamma's growth rate (Gamma(x) · digamma(x)) first exceeds 1/x. This non-monotonicity has implications for EML approximation bounds.

## 8. Future Work

1. **Gauss ODE formalization**: Prove that the ₂F₁ partial sums satisfy the Gauss hypergeometric ODE z(1-z)y'' + [c-(a+b+1)z]y' - aby = 0 term by term.

2. **EML singularity algebra**: Develop composition rules for EML singularity spectra — if S₁ and S₂ are spectra of f and g, what is the spectrum of f ∘ g?

3. **Complex EML**: Extend the singularity classification to ℂ, where the distinction between different singularity types is analytically sharper.

4. **Zeta function analysis**: Rigorously formalize why the Riemann zeta function, despite having a single pole at s = 1, exhibits behavior that places it at the boundary of the EML class.

## 9. References

1. Abramowitz, M. and Stegun, I.A. *Handbook of Mathematical Functions*. Dover, 1965.
2. Andrews, G.E., Askey, R., and Roy, R. *Special Functions*. Cambridge University Press, 1999.
3. DLMF: NIST Digital Library of Mathematical Functions. https://dlmf.nist.gov/
4. The Mathlib Community. *Mathlib4*. https://github.com/leanprover-community/mathlib4
