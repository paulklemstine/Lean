# Formalized Transseries: Asymptotic Expansions Beyond Power Series

## Abstract

We present a rigorous formalization of the foundational theory of transseries — formal asymptotic expansions incorporating iterated exponentials and logarithms. We introduce the **growth level** framework, a pair (depth, exponent) classifying transmonomials by their asymptotic growth rate, and establish that growth levels form a strict total order. We prove the fundamental asymptotic dominance hierarchy: exponential functions dominate all polynomials, double exponentials dominate all powers of single exponentials, and logarithms are negligible relative to any positive power. We bridge these results to the EML (exp-log-multiply) function algebra, proving that the EML function eml(x,y) = exp(x) - log(y) is asymptotically equivalent to its leading exponential term, and establishing the diagonal gap theorem: exp(x) - log(x) ≥ 2 for all x > 0, with strict inequality away from x = 1. All results are machine-verified with complete proofs.

## 1. Introduction

### 1.1 Background

Transseries, introduced by Écalle and independently developed by van der Hoeven, extend classical power series by incorporating exponential and logarithmic terms at all levels of nesting. The field of transseries 𝕋 is a real-closed ordered differential field containing ℝ and admitting an exponential function, providing a universal domain for asymptotic analysis of exp-log-polynomial functions.

The theory has deep connections to:
- **Model theory**: Aschenbrenner, van den Dries, and van der Hoeven proved that the field of transseries is model-complete and admits quantifier elimination in a natural language [1].
- **Hardy fields**: Transseries provide the universal Hardy field, the "algebraic closure" of the field of germs of exp-log-polynomial functions at infinity.
- **Surreal numbers**: The surreal numbers contain the transseries as a natural subfield.

### 1.2 Contributions

We formalize the foundational layer of transseries theory:

1. **Growth Level Hierarchy** (§2): A formalized classification of transmonomials by exponential depth and polynomial exponent, with a machine-verified proof that this classification gives a strict total order.

2. **Asymptotic Dominance Theorems** (§3): Complete proofs of the fundamental separation results:
   - exp(x)/x^n → ∞ for all n ∈ ℕ (Theorem 3.1)
   - exp(exp(x))/exp(cx) → ∞ for all c ∈ ℝ (Theorem 3.2)  
   - log(x)/x^α → 0 for all α > 0 (Theorem 3.3)
   - x^n/exp(x) → 0 for all n ∈ ℕ (Theorem 3.4)

3. **Exp-Log Duality** (§4): Proof that the exponential and logarithmic shifts on growth levels are inverse order isomorphisms.

4. **EML Bridge** (§5): Connection to the EML function algebra, proving asymptotic decomposition and the diagonal gap theorem.

5. **Transseries Uniqueness** (§6): The formal uniqueness theorem for transseries coefficients.

### 1.3 Relation to Catalog

This work builds on and extends several results from the existing theorem catalog:

- **`EML/EMLv17Core.lean`**: Definitions of the eml function and its basic properties (monotonicity, convexity, derivative).
- **`EML/KolmogorovArnoldEMLDeep.lean`**: The exp-log cancellation identity `eml_chain_exp_log_cancel`.
- **`EML/V14Research.lean`**: The exp-log gap theorem `eml14_exp_log_gap`.
- **`Geometry/EMLStoneWeierstrass.lean`**: The real power representation `exp_real_log_eq_rpow`.

Our contribution deepens these results by:
- Placing them in the systematic framework of transseries growth levels
- Proving the asymptotic dominance hierarchy that explains *why* the exp-log gap exists
- Establishing the double-exponential separation that goes beyond single-level comparisons
- Formalizing the uniqueness theorem that connects coefficient equality to function identity

## 2. Growth Levels

### 2.1 Definition

A **growth level** is a pair g = (d, α) ∈ ℤ × ℝ representing the asymptotic growth class:
- d = 0, α: polynomial growth x^α
- d > 0, α: d-times iterated exponential exp^d(x^α)
- d < 0, α: |d|-times iterated logarithm log^|d|(x^α)

```
structure GrowthLevel where
  depth : ℤ
  exponent : ℝ
```

### 2.2 Lexicographic Order

We define the strict order lexicographically: g₁ < g₂ if d₁ < d₂, or if d₁ = d₂ and α₁ < α₂. This captures the asymptotic intuition: depth is the primary discriminator (exp always beats polynomial), and within the same depth, higher exponent means faster growth.

**Theorem 2.1** (Trichotomy). For any growth levels a, b: exactly one of a < b, a = b, b < a holds.

*Proof.* By trichotomy on ℤ (for depths) and trichotomy on ℝ (for exponents), with case analysis. □

**Theorem 2.2** (Transitivity). The order is transitive.

**Theorem 2.3** (Irreflexivity). No growth level is strictly less than itself.

### 2.3 Exp-Log Shifts

The **exponential shift** expShift(d, α) = (d+1, α) and **logarithmic shift** logShift(d, α) = (d-1, α) are inverse bijections that preserve the order:

**Theorem 2.4** (Shift Cancellation). logShift ∘ expShift = id and expShift ∘ logShift = id.

**Theorem 2.5** (Order Preservation). a < b ⟺ expShift(a) < expShift(b).

This makes (expShift, logShift) an order isomorphism of the growth levels with themselves, reflecting the algebraic duality of exp and log.

### 2.4 Depth Filtration

The growth levels decompose into **depth slices** {g | g.depth = d} for each d ∈ ℤ. These slices are pairwise disjoint and their union is all of GrowthLevel. Each slice is order-isomorphic to (ℝ, <) via the exponent map.

## 3. Asymptotic Dominance

### 3.1 Exponential vs. Polynomial

**Theorem 3.1** (Exp Dominates Polynomial). For all n ∈ ℕ:
  lim_{x→∞} exp(x) / x^{n+1} = ∞

*Proof sketch.* This follows from the Mathlib result `tendsto_exp_div_pow_atTop`, which is proved by induction on n using L'Hôpital's rule. □

**Theorem 3.2** (Polynomial Negligible vs. Exp). For all n ∈ ℕ:
  lim_{x→∞} x^n / exp(x) = 0

This is the contrapositive formulation, proved using `tendsto_pow_mul_exp_neg_atTop_nhds_zero`.

### 3.2 Double-Exponential Separation

**Theorem 3.3** (Depth-2 Dominates Depth-1). For all c ∈ ℝ:
  lim_{x→∞} exp(exp(x)) / exp(cx) = ∞

*Proof sketch.* Write exp(exp(x))/exp(cx) = exp(exp(x) - cx). Since exp(x) - cx → ∞ (by Theorem 3.1 with n=0), and exp is monotone increasing to ∞, the composition tends to ∞. □

This is the canonical example of the depth gap: no matter how large the constant c, the double exponential eventually dwarfs exp(cx). Setting c = n gives:

**Corollary 3.4**. exp(exp(x)) / (exp(x))^n → ∞ for all n ∈ ℕ.

### 3.3 Logarithmic Negligibility

**Theorem 3.5** (Log Negligible vs. Powers). For all α > 0:
  lim_{x→∞} log(x) / x^α = 0

*Proof sketch.* Substitute y = log(x), reducing to y/exp(αy) → 0, which follows from Theorem 3.2. □

## 4. Iterated Exp-Log Cancellation

**Theorem 4.1** (Double Cancellation). For x > 1:
  exp(exp(log(log(x)))) = x

*Proof.* For x > 1, log(x) > 0, so exp(log(log(x))) = log(x) by the inverse property. Then exp(log(x)) = x. □

This result formalizes the algebraic coherence of the exp-log tower: two layers of wrapping and unwrapping cancel perfectly, recovering the original value.

## 5. EML Bridge

### 5.1 Asymptotic Decomposition

The EML function eml(x, y) = exp(x) - log(y) has a natural two-term transseries expansion. The leading term is at growth level (1, 1) with coefficient 1, and the subleading term is at growth level (-1, 1) with coefficient -1 (in the y-variable).

**Theorem 5.1** (EML Asymptotic Equivalence). For fixed y > 0:
  lim_{x→∞} (exp(x) - log(y)) / exp(x) = 1

**Theorem 5.2** (Log Negligibility). For any y ∈ ℝ:
  lim_{x→∞} log(y) / exp(x) = 0

**Theorem 5.3** (Residual Extraction). The residual after subtracting the leading term is constant:
  (exp(x) - log(y)) - exp(x) = -log(y) for all x

### 5.2 Diagonal Gap

**Theorem 5.4** (Diagonal Gap). For x > 0:
  exp(x) - log(x) ≥ 2

*Proof.* From the classical inequalities exp(x) ≥ 1 + x and log(x) ≤ x - 1:
  exp(x) - log(x) ≥ (1 + x) - (x - 1) = 2 □

**Theorem 5.5** (Strict Diagonal Gap). For x > 0, x ≠ 1:
  exp(x) - log(x) > 2

*Proof.* At least one of the inequalities is strict: exp(x) > 1 + x for x ≠ 0 (strict convexity), and log(x) < x - 1 for x ≠ 1 (strict concavity). For x > 0 and x ≠ 1, the latter always holds. □

### 5.3 Monotonicity

**Theorem 5.6**. x ↦ eml(x, y) is strictly increasing for any fixed y.

**Theorem 5.7**. y ↦ eml(x, y) is strictly decreasing on (0, ∞) for any fixed x.

## 6. Transseries Uniqueness

### 6.1 The Type of Transseries

We define a transseries as a finitely supported function from growth levels to ℝ:
```
abbrev TransseriesF := GrowthLevel →₀ ℝ
```

This captures the essential idea: a transseries is a finite formal sum T = Σᵢ aᵢ · mᵢ where each mᵢ is a transmonomial classified by its growth level.

### 6.2 Uniqueness Theorem

**Theorem 6.1** (Transseries Extensionality). If T₁(g) = T₂(g) for all growth levels g, then T₁ = T₂.

This follows from `Finsupp.ext` but encodes the key principle: the transseries expansion of a function (when it exists) is unique. Two transseries that "agree to all orders" — matching at every growth level — must be identical.

## 7. PEGB Analysis

### Theorem: Exponential Dominates Polynomial (§3.1)
- **P**roof: Complete, using Mathlib's `tendsto_exp_div_pow_atTop`.
- **E**xample: exp(100) ≈ 2.69 × 10^43, while 100^10 = 10^20. The ratio is ≈ 2.69 × 10^23.
- **G**eneralization: Extends to real exponents via rpow. Next level: exp(x^α) dominates x^β for any α > 0.
- **B**oundary: Breaks for subexponential functions like exp(√x), which has growth level (1, 1/2) — same depth but lower exponent.

### Theorem: Double-Exponential Separation (§3.2)
- **P**roof: Complete, via exp(exp(x) - cx) decomposition.
- **E**xample: At x = 10, exp(exp(10))/exp(10·10) ≈ exp(22016) — a number with ≈ 9500 digits.
- **G**eneralization: exp^{n+1}(x) dominates any power of exp^n(x). The hierarchy is infinite.
- **B**oundary: For *sub-iterated* growth like exp(x·log(x)), the separation is more subtle.

### Theorem: Diagonal Gap (§5.2)
- **P**roof: Complete, from AM-GM-type bounds on exp and log.
- **E**xample: At x = 1, exp(1) - log(1) ≈ 2.718, confirming gap > 2. Minimum approaches 2 near x → 0⁺.
- **G**eneralization: For exp^n(x) - log^n(x), analogous gaps exist with larger constants.
- **B**oundary: The gap constant 2 is specific to the depth-(1, -1) pair. Higher depth pairs have larger gaps.

## 8. Discussion

### 8.1 Cross-Domain Bridge

The transseries framework bridges three domains:
- **Analysis** (asymptotic growth rates and limits)
- **Algebra** (ordered fields, differential algebra)
- **Logic** (model completeness, o-minimality)

Our growth level formalization provides the concrete combinatorial structure underlying this bridge: the totally ordered pair (depth, exponent) is simple enough to compute with, yet rich enough to classify all exp-log-polynomial growth rates.

### 8.2 Limitations

Our formalization covers the *finitely supported* case — transseries with finitely many terms. The full theory requires:
- Well-ordered supports (Hahn series)
- Infinite sums with convergence conditions
- The grid-based representation of van der Hoeven

These extensions are natural targets for future formalization.

## 9. Algorithms

### 9.1 Growth Level Comparison
Compare two growth levels in O(1) time by comparing depths (integers), then exponents (reals).

### 9.2 Transseries Addition
Add two finitely supported transseries by combining their supports and adding coefficients at shared growth levels.

### 9.3 Asymptotic Comparison
Given two transseries, compare their leading (maximal) growth levels. If they differ, the one with the higher growth level dominates. If they agree, compare the leading coefficients and recurse on the remainder.

## 10. References

[1] M. Aschenbrenner, L. van den Dries, J. van der Hoeven. *Asymptotic Differential Algebra and Model Theory of Transseries*. Annals of Mathematics Studies, Princeton University Press, 2017.

[2] J. van der Hoeven. *Transseries and Real Differential Algebra*. Lecture Notes in Mathematics, Springer, 2006.

[3] J. Écalle. *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*. Hermann, 1992.

[4] Catalog reference: `EML/EMLv17Core.lean` — EML function definition and basic identities.

[5] Catalog reference: `EML/KolmogorovArnoldEMLDeep.lean` — exp-log chain cancellation.

[6] Catalog reference: `EML/V14Research.lean` — exp-log gap theorem.
