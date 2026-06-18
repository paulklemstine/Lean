# Future Directions: EML Special Functions Research

## Synthesis

This research cycle established the **EML Singularity Spectrum** — a novel mathematical structure classifying singularities of functions into four types (removable, pole, logBranch, essential) — and used it to formalize the relationship between the EML operator `eml(x,y) = exp(x) - log(y)` and classical special functions. The Gamma function was shown to have a meromorphic singularity spectrum (simple poles at non-positive integers), making it EML-compatible, while essential singularity spectra were proved to be excluded from both the meromorphic and EML-compatible classes. The hypergeometric function ₂F₁ was formalized via Pochhammer symbols, with its coefficient recurrence, ratio test convergence, and termination at negative integer parameters all machine-verified.

The most promising cross-domain connection is the **Pochhammer-EML bridge**: rising factorials decompose into sums of logarithms (Theorem 12), and each factor is recoverable via `eml'(log(a+k), 1) = a+k` (Theorem 13). This means hypergeometric coefficients — and by extension, an enormous family of special functions including all classical orthogonal polynomials — are intrinsically EML objects. This connects to the existing Catalog's approximation theory (`EML/DeepApprox.lean`) and suggests that EML's universal approximation property may have a spectral explanation through hypergeometric representations.

A surprising discovery was the disproof of the monotonicity conjecture for Γ(x) - log(x) on (1,∞), revealing that this function has a minimum near x ≈ 2.4. This suggests investigating the critical points of EML-Gamma compositions more carefully.

The direction with highest breakthrough potential is **Direction 1** (EML Singularity Algebra), because establishing composition rules for singularity spectra would provide a complete calculus for determining EML-compatibility of arbitrary function compositions — a tool with applications in approximation theory, special function theory, and potentially numerical analysis.

---

### Direction 1: EML Singularity Algebra — Composition Rules for Spectra

**Conjecture**: There exist explicit composition rules for EML singularity spectra: if f has spectrum S₁ and g has spectrum S₂, then f ∘ g has a spectrum S₃ whose singularity types are determined by a fixed algebra:
- pole ∘ pole = pole (with multiplied orders)
- pole ∘ logBranch = logBranch
- essential ∘ anything = essential
- exp applied to a logBranch yields a pole (as proved in Theorem 15: exp(c·log(x)) = x^c)

More precisely: define a binary operation ⊗ on EMLSingType such that if f has singularity type t₁ at g(z₀) and g has singularity type t₂ at z₀, then f ∘ g has singularity type t₁ ⊗ t₂ at z₀.

**Test**: Verify the composition rules against known special function compositions:
1. exp(log(z)) = z: essential ∘ logBranch should give removable — does the algebra predict this?
2. Γ(1/z): poles of Gamma composed with pole of 1/z — predict essential singularity at z = 0?
3. log(Γ(z)): logBranch ∘ pole — predict logBranch?

**Impact**: If true, this gives a complete, computable calculus for EML-compatibility of arbitrary compositions. This would be the first algebraic characterization of which function compositions stay within the EML class.

**Catalog References**: `EML/SpecialFunctions.lean` (EMLSingType, EMLSingSpectrum), `EML/EMLv17Core.lean` (eml operator), `EML/DeepApprox.lean` (deep composition approximation)

**Proof Strategy**: Define the ⊗ operation as a function EMLSingType → EMLSingType → EMLSingType. State and prove composition theorems one case at a time. The hardest case is likely essential ∘ logBranch, where the composition of exp(1/z) with log(z) near z = 0 needs careful analysis.

**Domain Bridges**: Singularity Theory <-> Approximation Theory (EML universality may follow from spectral completeness)

**Lineage**: Builds on Theorems 3, 4, 5, 15 of this cycle; extends the meromorphic_isEMLCompatible theorem to compositions.

**Ambition**: grand_challenge

---

### Direction 2: Gauss Hypergeometric ODE via EML Differential Calculus

**Conjecture**: The formal hypergeometric series ₂F₁(a,b;c;z) satisfies the Gauss hypergeometric ODE:
z(1-z)y'' + [c - (a+b+1)z]y' - ab·y = 0
in the sense that term-by-term differentiation of the power series and substitution into the ODE yields the zero series.

More precisely: define `hypergeom_ode_residual(a,b,c,n)` as the coefficient of z^n when the ODE is applied to ₂F₁. Conjecture: this residual is identically zero for all n.

**Test**: Compute the ODE residual for specific values (a,b,c) = (1,1,2) and verify it vanishes for n = 0, 1, ..., 20 computationally. Then attempt a formal proof by showing the residual satisfies a linear recurrence whose unique solution is the zero sequence.

**Impact**: This would be the first machine-verified proof that ₂F₁ satisfies its classical ODE. Combined with the coefficient recurrence (Theorem 6), it would give a complete formal treatment of the Gauss hypergeometric function.

**Catalog References**: `EML/SpecialFunctions.lean` (hypergeomCoeff, hypergeomCoeff_succ), `EML/EMLv17Core.lean` (EML derivatives)

**Proof Strategy**:
1. Define the n-th coefficient of the ODE residual as a function of hypergeometric coefficients.
2. Use the recurrence relation (Theorem 6) to simplify.
3. Show the resulting expression telescopes to zero.
The key identity is: n(n-1)c_n + n·c_n·[c-(a+b+1)] + terms involving c_{n-1} and c_{n-2} must cancel.

**Domain Bridges**: Special Function Theory <-> Differential Equations <-> EML Approximation

**Lineage**: Direct extension of Theorems 6, 22, 23 from this cycle.

**Ambition**: extension

---

### Direction 3: EML Representation of Bernoulli Numbers and Zeta Values

**Conjecture**: The Bernoulli numbers B_n satisfy an EML recurrence relation of the form:
B_{n+1} = EML-expression involving B_0, ..., B_n and log/exp operations.

More specifically: since ζ(2n) = (-1)^{n+1} · B_{2n} · (2π)^{2n} / (2·(2n)!), and the factorial (2n)! = Γ(2n+1) is an EML object (Theorem 9), the zeta values ζ(2n) can be expressed through EML operations composed with Bernoulli numbers.

**Test**:
1. Compute B_0, ..., B_20 and verify the EML recurrence computationally.
2. Check whether ζ(2) = π²/6 can be expressed as an EML combination of π and rational Pochhammer symbols.
3. Investigate whether the Bernoulli number generating function z/(e^z - 1) has an EML-compatible singularity spectrum.

**Impact**: This would connect the EML framework to number theory through zeta values. If Bernoulli numbers have an EML recurrence, it would provide a new computational method and potentially new identities.

**Catalog References**: `EML/SpecialFunctions.lean` (log_gamma_sum, risingFactorial), Mathlib's `riemannZeta_two`, `riemannZeta_two_mul_nat`

**Proof Strategy**: Start from the generating function z/(e^z - 1) = Σ B_n z^n/n!. The denominator e^z - 1 is an EML object (it's exp(z) - 1). Study the singularity spectrum of the generating function: it has simple poles at z = 2πik (k ≠ 0), making it meromorphic and hence EML-compatible.

**Domain Bridges**: Number Theory (Bernoulli numbers, zeta values) <-> EML Framework <-> Approximation Theory

**Lineage**: Builds on the Gamma-EML bridge (Theorem 9) and the hypergeometric-Gamma connection; extends toward Mathlib's `riemannZeta` infrastructure.

**Ambition**: grand_challenge

---

### Direction 4: Quantitative EML Approximation Bounds via Hypergeometric Error Analysis

**Conjecture**: The error of approximating a smooth function f on [0,1] by an N-term EML composition satisfies:
‖f - EML_N(f)‖_∞ ≤ C · ₂F₁(1, 1; N+1; ‖f‖) / N
where C depends on the regularity of f, and the hypergeometric factor captures the combinatorial structure of the approximation error.

**Test**: Numerically approximate several test functions (sin, polynomial, Runge function) by EML compositions of increasing depth N, and check whether the error decays like 1/₂F₁(1,1;N+1;·).

**Impact**: This would provide the first explicit, non-asymptotic error bounds for EML approximation, connecting the hypergeometric machinery to the universal approximation theorem in `EML/DeepApprox.lean`.

**Catalog References**: `EML/DeepApprox.lean` (HasApproxRate, deep_uniform_approx), `EML/SpecialFunctions.lean` (hypergeom2F1_partial, hypergeomCoeff)

**Proof Strategy**: Use the explicit coefficient structure of ₂F₁ to bound the tail of the approximation error series. The key step is showing that the error after N terms of an EML expansion is controlled by the partial sum of a hypergeometric series.

**Domain Bridges**: Approximation Theory <-> Special Functions <-> Machine Learning (neural network approximation rates)

**Lineage**: Connects this cycle's hypergeometric results to the existing `eml_has_approx_rate` theorem in the Catalog.

**Ambition**: extension

---

### Direction 5: Critical Points of EML-Gamma Compositions

**Conjecture**: The function f(x) = Γ(x) - log(x) has exactly one critical point on (1, ∞), which is a global minimum. This minimum occurs at the unique solution of Γ(x)·ψ(x) = 1/x, where ψ is the digamma function.

**Test**:
1. Numerically find the zero of f'(x) = Γ(x)·ψ(x) - 1/x on (1, ∞).
2. Verify that f''(x) > 0 at this point (confirming it's a minimum).
3. Check whether the minimum value satisfies any algebraic relation.
4. Investigate whether the analogous function Γ(x) - α·log(x) has a unique minimum for each α > 0, and whether the minimum location depends monotonically on α.

**Impact**: This would extend the disproved conjecture from this cycle into a complete analysis of the critical point structure. If the minimum location satisfies an algebraic relation, it would be a new special constant.

**Catalog References**: `EML/SpecialFunctions.lean` (gamma_gt_log_nat, gamma_recurrence_log, the disproved conjecture)

**Proof Strategy**: Use Mathlib's `Real.differentiableAt_Gamma` and the digamma function to compute f'. Show f' changes sign exactly once on (1, ∞) using the intermediate value theorem, combined with the asymptotic behavior: f'(x) → -∞ as x → 1+ and f'(x) → +∞ as x → ∞.

**Domain Bridges**: Analysis (critical point theory) <-> Special Functions (digamma) <-> EML Framework

**Lineage**: Direct continuation of the disproved conjecture from this cycle, turning a failure into a research direction.

**Ambition**: extension
