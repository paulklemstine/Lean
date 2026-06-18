# Transseries Asymptotic Expansions: Formal Foundations and Uniqueness Theorems

## Abstract

We develop a rigorous formalization of transseries theory, focusing on the asymptotic dominance hierarchy, expansion uniqueness, and Hardy field closure properties. Our main contributions are:

1. **Asymptotic expansion uniqueness theorems** for finite-term transseries in the {exp, log, 1} basis, proving that coefficients are uniquely determined by the function.
2. **Coefficient recovery algorithms** that extract each coefficient through successive limit operations, establishing a constructive version of the uniqueness theorem.
3. **Hardy field closure under differentiation** for EML-type transseries, showing that derivatives remain in the exp-log function class.
4. **A bridge between the EML function** eml(x,y) = exp(x) - log(y) and transseries theory, identifying it as a canonical two-term transseries element.

All main results are formally verified in Lean 4 with Mathlib.

**Keywords**: transseries, asymptotic analysis, Hardy fields, formal verification, EML functions

## 1. Introduction

### 1.1 Background

Transseries, introduced by Écalle [1] and developed extensively by van den Dries, Macintyre, and Marker [2], generalize formal power series by incorporating exponential and logarithmic terms. The field of transseries ℝ[[x]]^{LE} (where LE denotes logarithmic-exponential) is a proper extension of the field of formal Laurent series that captures the asymptotic behavior of a wide class of real-valued functions.

The fundamental objects in transseries theory are **transmonomials** — formal expressions built from a variable x using exponentiation, logarithm, and real powers:

```
exp(x), log(x), exp(exp(x)), x^α, x^α · log(x)^β, exp(x) · log(x), ...
```

These monomials admit a total ordering by asymptotic growth rate, and linear combinations of transmonomials form the transseries.

### 1.2 Motivation: The EML Function

Our work is motivated by the **EML function** eml(x, y) = exp(x) - log(y), which has been extensively studied as a fundamental building block in function approximation theory [3]. The EML function is a natural two-term transseries:

```
eml(x, x) = 1 · exp(x) + (-1) · log(x)
```

Understanding the asymptotic structure of this function — why its leading behavior is exponential, why the coefficients are unique, and why the derivative stays within the same function class — requires the machinery of transseries theory.

### 1.3 Contributions

We make the following specific contributions:

1. **Definitions**: We formalize the asymptotic dominance relation, asymptotic equivalence, and asymptotic negligibility as limit-based predicates.

2. **Growth hierarchy**: We prove the fundamental ordering:
   ```
   exp(exp(x)) ≫ exp(x) ≫ x^n ≫ x ≫ log(x)
   ```
   including transitivity of the dominance relation.

3. **Uniqueness theorems**: We prove that two-term and three-term transseries expansions are unique (coefficients are determined), and that equality of functions implies equality of coefficients.

4. **Coefficient recovery**: We give constructive proofs that each coefficient in an EML-type transseries a·exp(x) + b·log(x) + c can be recovered through limit operations.

5. **Hardy field closure**: We verify that differentiation preserves the EML function class.

## 2. Definitions

### 2.1 Asymptotic Relations

Let f, g : ℝ → ℝ be functions defined for sufficiently large x.

**Definition 2.1** (Asymptotic Dominance). We say f **asymptotically dominates** g, written f ≫ g, if
```
lim_{x→∞} f(x)/g(x) = +∞
```

**Definition 2.2** (Asymptotic Equivalence). We say f is **asymptotically equivalent** to g, written f ~ g, if
```
lim_{x→∞} f(x)/g(x) = 1
```

**Definition 2.3** (Asymptotic Negligibility). We say f is **asymptotically negligible** compared to g, written f = o(g), if
```
lim_{x→∞} f(x)/g(x) = 0
```

**Definition 2.4** (Asymptotic Positivity). f is **asymptotically positive** if f(x) > 0 for all sufficiently large x.

### 2.2 The EML Diagonal

**Definition 2.5**. The **EML diagonal function** is
```
emlDiagFun(x) = exp(x) - log(x)
```

## 3. Main Results

### 3.1 The Growth Hierarchy

**Theorem 3.1** (Exponential Dominance). For every n ∈ ℕ, exp ≫ (x ↦ x^n).

*Proof sketch*: This follows from the classical result `tendsto_exp_div_pow_atTop` in Mathlib, which states that exp(x)/x^n → ∞.

**Theorem 3.2** (Identity Dominates Log). id ≫ log, i.e., x/log(x) → ∞.

*Proof sketch*: Substitute u = log(x), reducing to exp(u)/u → ∞, which is the n=1 case of Theorem 3.1.

**Theorem 3.3** (Iterated Exponential Dominance). (x ↦ exp(exp(x))) ≫ exp.

*Proof sketch*: exp(exp(x))/exp(x) = exp(exp(x) - x), and since exp(x) - x → ∞, this tends to ∞.

**Theorem 3.4** (Transitivity). If f ≫ g and g ≫ h, and g is asymptotically positive, then f ≫ h.

*Proof sketch*: f(x)/h(x) = (f(x)/g(x)) · (g(x)/h(x)). Both factors tend to +∞ (the second eventually, by positivity of g), so the product tends to +∞.

### 3.2 Negligibility Results

**Theorem 3.5**. log = o(id), log = o(exp), and 1 = o(exp).

These are the "reverse" statements corresponding to the dominance results.

### 3.3 Asymptotic Expansion Uniqueness

**Theorem 3.6** (Two-Term Uniqueness). Let m₁, m₂ be asymptotically positive functions with m₁ ≫ m₂. If a·m₁ + b·m₂ = o(m₂) for some constants a, b ∈ ℝ, then a = 0 and b = 0.

*Proof sketch*: Dividing by m₂, we get a·(m₁/m₂) + b → 0. If a ≠ 0, then a·(m₁/m₂) → ±∞ (since m₁/m₂ → ∞), making a·(m₁/m₂) + b → ±∞, contradicting the limit being 0. So a = 0, and then b → 0 but b is constant, so b = 0.

**Theorem 3.7** (Three-Term Uniqueness). Under analogous hypotheses with m₁ ≫ m₂ ≫ m₃, if a·m₁ + b·m₂ + c·m₃ = o(m₃), then a = b = c = 0.

*Proof sketch*: Apply the two-term result to extract a = 0, then reduce to the two-term case for b and c.

### 3.4 The Coefficient Recovery Theorem

**Theorem 3.8** (Leading Coefficient Recovery). For any a, b, c ∈ ℝ,
```
lim_{x→∞} (a·exp(x) + b·log(x) + c) / exp(x) = a
```

**Theorem 3.9** (Log Coefficient Recovery). For any a, b, c ∈ ℝ,
```
lim_{x→∞} (a·exp(x) + b·log(x) + c - a·exp(x)) / log(x) = b
```

**Theorem 3.10** (Constant Recovery). The constant term c is exactly recoverable:
```
a·exp(x) + b·log(x) + c - a·exp(x) - b·log(x) = c
```

*Proof of Theorem 3.8*: (a·exp + b·log + c)/exp = a + b·log/exp + c/exp. Since log/exp → 0 (Theorem 3.5) and c/exp → 0, the limit is a.

### 3.5 The Main Uniqueness Theorem

**Theorem 3.11** (EML Transseries Uniqueness). If for all x ∈ ℝ,
```
a₁·exp(x) + b₁·log(x) + c₁ = a₂·exp(x) + b₂·log(x) + c₂
```
then a₁ = a₂, b₁ = b₂, and c₁ = c₂.

*Proof*: The equality gives (a₁-a₂)·exp + (b₁-b₂)·log + (c₁-c₂) = 0 for all x. Applying Theorem 3.8 with the zero function yields a₁-a₂ = 0. Similarly for the other coefficients via Theorems 3.9 and 3.10.

### 3.6 EML Asymptotic Structure

**Theorem 3.12** (EML ~ exp). The EML diagonal is asymptotically equivalent to exp:
```
emlDiagFun ~ exp
```
i.e., (exp(x) - log(x))/exp(x) → 1 as x → ∞.

**Theorem 3.13** (EML Exact Expansion). For all x ∈ ℝ,
```
emlDiagFun(x) = 1·exp(x) + (-1)·log(x)
```

**Theorem 3.14** (Scaled EML). For α > 0, exp(αx) - log(αx) ~ exp(αx) as x → ∞.

**Theorem 3.15** (EML Unbounded). Tendsto emlDiagFun atTop atTop.

### 3.7 Hardy Field Closure

**Theorem 3.16** (EML Derivative). For x > 0,
```
d/dx[exp(x) - log(x)] = exp(x) - 1/x
```

**Theorem 3.17** (Transseries Derivative). For x > 0,
```
d/dx[a·exp(x) + b·log(x) + c] = a·exp(x) + b/x
```

**Theorem 3.18** (Hierarchy Preservation). exp ≫ (x ↦ 1/x).

This shows that differentiation preserves the dominance ordering: the derivative of the dominant term (exp) still dominates the derivative of the subdominant term (log → 1/x).

### 3.8 Asymptotic Equivalence Properties

**Theorem 3.19** (Reflexivity). If f is eventually nonzero, then f ~ f.

**Theorem 3.20** (Transitivity). If f ~ g and g ~ h and g is eventually nonzero, then f ~ h.

**Theorem 3.21** (Incompatibility). If g is asymptotically positive, f ~ g and f = o(g) cannot both hold. (Proof: the limit f/g cannot be both 1 and 0.)

### 3.9 Transseries Algebra

**Theorem 3.22** (Additive Closure). The sum of two EML transseries is an EML transseries:
```
(a₁·exp + b₁·log + c₁) + (a₂·exp + b₂·log + c₂) = (a₁+a₂)·exp + (b₁+b₂)·log + (c₁+c₂)
```

**Theorem 3.23** (Scalar Closure). r·(a·exp + b·log + c) = (ra)·exp + (rb)·log + (rc).

**Theorem 3.24** (Multiplicative Non-Closure). The product of two EML transseries involves the cross term exp(x)·log(x), which is NOT in the {exp, log, 1} basis:
```
(a₁·exp + b₁·log)(a₂·exp + b₂·log) = a₁a₂·exp² + (a₁b₂+a₂b₁)·exp·log + b₁b₂·log²
```

This last result is significant: it shows that the EML basis is a *module* but not a *ring*, motivating the need for the full (infinitely generated) transseries algebra.

## 4. Discussion

### 4.1 Relation to Full Transseries Theory

Our results formalize the foundational layer of transseries theory. The full theory, as developed by Aschenbrenner, van den Dries, and van der Hoeven [4], establishes that the field of transseries is:
- **Real closed** (every polynomial of odd degree has a root)
- **Model-complete** (every first-order sentence has a definite truth value)
- A **universal domain** for Hardy fields

Our uniqueness theorems (Theorems 3.6, 3.7, 3.11) are instances of the general uniqueness principle for well-ordered transseries, specialized to finite expansions.

### 4.2 PEGB Analysis

**P (Proof)**: All 25+ theorems are formally verified in Lean 4.

**E (Example)**: The EML function eml(x,x) = exp(x) - log(x) serves as a concrete two-term transseries. Its coefficients (1, -1) are recoverable, its derivative stays in the Hardy field, and it demonstrates asymptotic equivalence to its leading term.

**G (Generalization)**: The natural next step is extending from the {exp, log, 1} basis to the full transmonomial hierarchy including exp(exp(x)), log(log(x)), and mixed terms like exp(x)·log(x). The uniqueness theorem should extend to any well-ordered set of transmonomials.

**B (Boundary)**: The uniqueness theorem breaks down for:
- Functions with essential singularities that don't admit transseries expansions
- Non-archimedean settings where the dominance relation may not be total
- Functions like sin(exp(x)) that oscillate at all scales

### 4.3 Cross-Domain Bridge

Our work bridges **analysis** (asymptotic behavior) with **algebra** (the ring/module structure of transseries) and **differential algebra** (Hardy field closure). The key insight is that asymptotic growth rates form an ordered algebraic structure that mirrors ordinal arithmetic in set theory.

## 5. Algorithms

### 5.1 Coefficient Recovery Algorithm

```
Input: A function f(x) = a·exp(x) + b·log(x) + c (coefficients unknown)
Output: The triple (a, b, c)

1. Compute a = lim_{x→∞} f(x)/exp(x)
2. Compute b = lim_{x→∞} (f(x) - a·exp(x))/log(x)
3. Compute c = f(x₀) - a·exp(x₀) - b·log(x₀) for any x₀
```

### 5.2 Growth Classification Algorithm

```
Input: A function f
Output: Its growth class (super_exponential, exponential, polynomial, logarithmic, bounded)

1. Compare f(x)/exp(x) at large x:
   - If → ∞: super_exponential
   - If → positive constant: exponential
   - If → 0: continue
2. Compare f(x)/x^N for various N:
   - If f(2x)/f(x) ≈ 2^α for some α: polynomial of degree α
3. Compare f(x)/log(x):
   - If → positive constant: logarithmic
4. Otherwise: bounded
```

## 6. Future Work

1. **Full transmonomial basis**: Extend uniqueness to infinite well-ordered transseries
2. **Real closedness**: Formalize the proof that ℝ[[x]]^{LE} is real closed
3. **Model completeness**: Connect to the Aschenbrenner–van den Dries–van der Hoeven theorem
4. **Differential-algebraic closure**: Show that the Hardy field of EML functions is closed under solving algebraic differential equations
5. **Computational transseries**: Implement efficient algorithms for transseries arithmetic

## References

[1] J. Écalle, *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*, Hermann, Paris, 1992.

[2] L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential power series," *J. London Math. Soc.* 56 (1997), 417–434.

[3] Catalog: `EML/EMLv17Core.lean` — The EML function and its properties.

[4] M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra and Model Theory of Transseries*, Annals of Mathematics Studies 195, Princeton University Press, 2017.

[5] J. van der Hoeven, *Transseries and Real Differential Algebra*, Lecture Notes in Mathematics 1888, Springer, 2006.

[6] Catalog: `EML/KolmogorovArnoldEMLDeep.lean` — EML chain operations.

## Appendix: Formal Verification Summary

| Theorem | File | Status |
|---------|------|--------|
| exp_dominates_power | TransseriesDefs.lean | ✓ Verified |
| id_dominates_log | TransseriesDefs.lean | ✓ Verified |
| exp_exp_dominates_exp | TransseriesDefs.lean | ✓ Verified |
| log_negligible_vs_id | TransseriesDefs.lean | ✓ Verified |
| const_negligible_vs_exp | TransseriesDefs.lean | ✓ Verified |
| log_negligible_vs_exp | TransseriesDefs.lean | ✓ Verified |
| asymp_expansion_unique_two | TransseriesDefs.lean | ✓ Verified |
| asymp_expansion_unique_three | TransseriesDefs.lean | ✓ Verified |
| eml_diag_asymp_exp | TransseriesDefs.lean | ✓ Verified |
| eml_diag_exact_expansion | TransseriesDefs.lean | ✓ Verified |
| asympDominates_trans | TransseriesTheorems.lean | ✓ Verified |
| asympNegligible_of_dominates | TransseriesTheorems.lean | ✓ Verified |
| asymp_equiv_not_negligible | TransseriesTheorems.lean | ✓ Verified |
| asympEquiv_refl | TransseriesTheorems.lean | ✓ Verified |
| asympEquiv_trans | TransseriesTheorems.lean | ✓ Verified |
| leading_coeff_recovery | TransseriesTheorems.lean | ✓ Verified |
| log_coeff_recovery | TransseriesTheorems.lean | ✓ Verified |
| const_coeff_recovery | TransseriesTheorems.lean | ✓ Verified |
| eml_transseries_unique | TransseriesTheorems.lean | ✓ Verified |
| eml_scaled_asymp | TransseriesTheorems.lean | ✓ Verified |
| eml_diag_tendsto_top | TransseriesTheorems.lean | ✓ Verified |
| eml_diag_deriv | TransseriesTheorems.lean | ✓ Verified |
| eml_transseries_deriv | TransseriesTheorems.lean | ✓ Verified |
| deriv_preserves_hierarchy | TransseriesTheorems.lean | ✓ Verified |
| eml_transseries_add | TransseriesTheorems.lean | ✓ Verified |
| eml_transseries_smul | TransseriesTheorems.lean | ✓ Verified |
| eml_product_cross_term | TransseriesTheorems.lean | ✓ Verified |
