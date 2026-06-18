# Formalized Transseries: Asymptotic Expansions Beyond Power Series

## Abstract

We present a formalized theory of transseries — formal sums of transmonomials of the form exp(γx) · x^α · (log x)^β — as a fragment of the general theory of transseries. Our development introduces the transmonomial exponent group TransExp as the lexicographic product ℝ ×ₗ (ℝ ×ₗ ℝ), equipped with a linear order that captures the asymptotic dominance hierarchy exp ≫ poly ≫ log. We construct the transseries algebra as the additive monoid algebra ℝ[TransExp] with convolution multiplication, and prove key structural theorems: the ultrametric inequality for the leading-term valuation, the dominance separation principle, the asymptotic comparison theorem (uniqueness of transseries expansions), multiplicative compatibility of the valuation, and a realization coherence theorem connecting the algebraic structure to actual asymptotic behavior. We also establish a bridge between EML (exp-minus-log) operations and transmonomial group arithmetic. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

Power series, the classical tool for asymptotic analysis, are fundamentally limited: they cannot express growth rates beyond polynomial. Functions involving exponentials (exp(x)), logarithms (log x), and their compositions require a richer framework. Transseries, introduced by Écalle [1] and developed by van den Dries, Macintyre, and Marker [2], provide precisely this framework.

The full theory of transseries involves well-ordered (possibly transfinite) sums, nested exponentials and logarithms, and a proof that the resulting field is real-closed. Our work formalizes a tractable but non-trivial fragment: transseries with finitely supported sums of transmonomials of depth 1 (single exponentials and logarithms).

### 1.2 Contributions

1. **Novel mathematical structure**: TransExp as the lexicographically ordered group (ℝ³, +, ≤_lex), representing the exponent space of transmonomials.

2. **Valuation theory**: A complete formal treatment of the leading-term valuation on finitely-supported transseries, including:
   - The ultrametric inequality (Theorem 3.3)
   - Dominance separation (Theorem 3.5)
   - Multiplicative compatibility via convolution (Theorem 3.6)

3. **Asymptotic comparison theorem**: Formal proof that a transseries is uniquely determined by its asymptotic expansion at all orders (Theorem 3.4).

4. **Realization coherence**: A map from abstract transseries to real-valued functions that preserves multiplication (Theorem 4.1) and validates the algebraic ordering against actual asymptotic dominance (Theorem 4.3).

5. **EML bridge**: A formal connection between the EML operation exp(log a - log b) and transmonomial arithmetic (Theorem 4.2).

## 2. The Transmonomial Exponent Group

### 2.1 Definition

**Definition 2.1** (TransExp). A *transmonomial exponent* is a triple (γ, α, β) ∈ ℝ³, representing the growth class of the function

    m(γ, α, β)(x) = exp(γx) · x^α · (log x)^β

as x → ∞.

In Lean 4, we define:
```
abbrev TransExp := ℝ ×ₗ (ℝ ×ₗ ℝ)
```

### 2.2 Algebraic Structure

TransExp inherits from ℝ³ the structure of an additive commutative group, where addition corresponds to multiplication of transmonomials:

    m(γ₁, α₁, β₁) · m(γ₂, α₂, β₂) = m(γ₁+γ₂, α₁+α₂, β₁+β₂)

### 2.3 Dominance Order

The *dominance order* on TransExp is the lexicographic order: (γ₁, α₁, β₁) < (γ₂, α₂, β₂) if γ₁ < γ₂, or γ₁ = γ₂ and α₁ < α₂, or γ₁ = γ₂ and α₁ = α₂ and β₁ < β₂.

**Theorem 2.2** (Growth Hierarchy). For γ > 0 and α > 0:
- pureLog(β) < purePoly(α) for all β (polynomial dominates logarithmic)
- purePoly(α) < pureExp(γ) for all α (exponential dominates polynomial)

**Theorem 2.3** (Order-Group Compatibility). The dominance order is translation-invariant: a ≤ b implies c + a ≤ c + b. This makes (TransExp, +, ≤) an ordered abelian group.

## 3. The Transseries Algebra

### 3.1 Definition

**Definition 3.1** (TransSeries). A *transseries* is an element of the additive monoid algebra ℝ[TransExp], i.e., a finitely-supported function f : TransExp → ℝ. The support supp(f) = {e ∈ TransExp : f(e) ≠ 0} is a finite subset of TransExp.

Addition is pointwise. Multiplication is convolution:

    (f * g)(e) = Σ_{e₁ + e₂ = e} f(e₁) · g(e₂)

**Remark.** The convolution multiplication (from AddMonoidAlgebra) differs from pointwise multiplication (from Finsupp). We define `convProd` explicitly to resolve this instance diamond in the formalization.

### 3.2 Leading Term Valuation

**Definition 3.2** (Leading Exponent and Coefficient). For a nonzero transseries f, the *leading exponent* leadExp(f) is the maximum element of supp(f) under the dominance order, and the *leading coefficient* leadCoeff(f) = f(leadExp(f)).

**Theorem 3.3** (Ultrametric Inequality). For nonzero f, g with f + g ≠ 0:
    
    leadExp(f + g) ≤ max(leadExp(f), leadExp(g))

*Proof sketch.* The support of f + g is contained in supp(f) ∪ supp(g). Every element of this union is bounded by max(leadExp(f), leadExp(g)). □

**Theorem 3.4** (Asymptotic Comparison Theorem). If f and g are transseries such that their truncations agree at every order — i.e., truncAbove(f, e) = truncAbove(g, e) for all e ∈ TransExp — then f = g.

*Proof.* For any exponent e, the truncation at e preserves the coefficient at e (since e ≤ e). Hence f(e) = g(e) for all e, giving f = g by extensionality. □

**Theorem 3.5** (Dominance Separation Principle). If leadExp(g) < leadExp(f) and f + g ≠ 0, then leadExp(f + g) = leadExp(f).

*Proof.* Since leadExp(f) ∉ supp(g) (all of g's support is below leadExp(g) < leadExp(f)), we have (f+g)(leadExp(f)) = f(leadExp(f)) ≠ 0. Hence leadExp(f) ∈ supp(f+g), forcing leadExp(f+g) ≥ leadExp(f). The reverse inequality follows from the ultrametric property. □

### 3.3 Multiplicative Structure

**Theorem 3.6** (Convolution of Monomials).
    single(e₁, c₁) * single(e₂, c₂) = single(e₁ + e₂, c₁ · c₂)

This follows directly from AddMonoidAlgebra.single_mul_single.

**Corollary 3.7** (Valuation Multiplicativity). For nonzero c₁, c₂:
- leadExp(single(e₁,c₁) * single(e₂,c₂)) = e₁ + e₂
- leadCoeff(single(e₁,c₁) * single(e₂,c₂)) = c₁ · c₂

## 4. Realization and the EML Bridge

### 4.1 Realization Map

**Definition 4.1.** The *realization* of a transmonomial exponent e = (γ, α, β) at x ∈ ℝ is:

    realize(e)(x) = exp(γx) · x^α · (log x)^β

**Theorem 4.1** (Multiplicative Coherence). For x > 1:

    realize(e₁ + e₂)(x) = realize(e₁)(x) · realize(e₂)(x)

*Proof.* Uses Real.exp_add, Real.rpow_add (with x > 0), and rpow_add for log x (with log x > 0 since x > 1). □

**Boundary analysis.** The hypothesis x > 1 is necessary. At x = 1, log(1) = 0, and 0^(β₁) · 0^(β₂) may not equal 0^(β₁+β₂) when some βᵢ are negative or non-integer.

### 4.2 EML Bridge

**Theorem 4.2** (EML-Transseries Bridge). For x > 1 with realize(eᵢ)(x) > 0:

    eml(realize(e₁)(x), realize(e₂)(x)) = realize(e₁ - e₂)(x)

where eml(a,b) = exp(log a - log b) = a/b for positive reals.

This shows that the EML operation — division disguised as an exp-log composition — corresponds exactly to the group subtraction operation in the transmonomial exponent space.

### 4.3 Dominance Coherence

**Theorem 4.3** (Exponential Dominance Coherence). For γ₁ < γ₂ and any constant C:

    ∃ x₀, ∀ x > x₀, C · exp(γ₁x) < exp(γ₂x)

*Proof.* The inequality reduces to C < exp((γ₂-γ₁)x). Since γ₂-γ₁ > 0 and exp is unbounded, such x₀ exists. Concretely, x₀ = (|C|+1)/(γ₂-γ₁) suffices. □

### 4.4 Negation Coherence

**Theorem 4.4.** For x > 1 with realize(e)(x) ≠ 0:

    realize(-e)(x) = realize(e)(x)⁻¹

## 5. PEGB Analysis of Main Theorems

### 5.1 Asymptotic Comparison Theorem (Theorem 3.4)

- **P**roof: Complete Lean 4 proof using Finsupp.ext and filter semantics.
- **E**xample: f = 3·single(pureExp(2)) + single(purePoly(1)), g = same. Agreement at all orders gives f = g.
- **G**eneralization: Extends to well-ordered (possibly infinite) support if truncation is defined appropriately.
- **B**oundary: For infinite support without well-ordering, the theorem fails — the series ΣHardy fields provide counterexamples where distinct objects have the same asymptotic expansion.

### 5.2 Dominance Separation (Theorem 3.5)

- **P**roof: Uses ultrametric inequality and support analysis.
- **E**xample: f = e²ˣ + x³, g = x¹⁰. leadExp(f) = (2,0,0), leadExp(g) = (0,10,0). leadExp(f+g) = (2,0,0) = leadExp(f).
- **G**eneralization: Works for any ordered group algebra, not just ℝ[TransExp].
- **B**oundary: When leadExp(f) = leadExp(g) but leadCoeff(f) = -leadCoeff(g), cancellation occurs and the result fails.

### 5.3 EML-Transseries Bridge (Theorem 4.2)

- **P**roof: Combines eml_eq_div with multiplicative coherence.
- **E**xample: eml(e²ˣ, eˣ) = e²ˣ/eˣ = eˣ. Exponent: (2,0,0) - (1,0,0) = (1,0,0) = pureExp(1). Consistent.
- **G**eneralization: Any exp-log-expressible operation on transmonomials has an exponent-space counterpart.
- **B**oundary: Fails when realizeExp returns 0 (e.g., when x = 0 and polyDeg < 0).

## 6. Conjectures

**Conjecture 6.1** (Full Multiplicative Valuation). For general (non-monomial) transseries f, g with f * g ≠ 0 (using convolution multiplication):

    leadExp(convProd(f, g)) = leadExp(f) + leadExp(g)

*Computational test*: Verify for f = single(e₁, c₁) + single(e₂, c₂) and g = single(e₃, c₃) where e₁ > e₂ and no cancellation occurs.

**Conjecture 6.2** (Inverse Existence). Every transseries f with leadCoeff(f) ≠ 0 has a formal inverse in the completion (allowing infinite but well-ordered support).

## 7. Algorithms

### 7.1 Leading Term Extraction

```python
def leading_term(coeffs: dict[tuple[float,float,float], float]) -> tuple:
    """Extract the leading transmonomial and coefficient."""
    if not coeffs:
        return None
    return max(coeffs.items(), key=lambda kv: kv[0])
```

### 7.2 Transseries Multiplication (Convolution)

```python
def convolve(f: dict, g: dict) -> dict:
    """Convolution product of two finitely-supported transseries."""
    result = {}
    for (e1, c1) in f.items():
        for (e2, c2) in g.items():
            e_sum = tuple(a+b for a,b in zip(e1, e2))
            result[e_sum] = result.get(e_sum, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}
```

## 8. Related Work

- Écalle [1] introduced the general theory of transseries and resurgent functions.
- van den Dries, Macintyre, Marker [2] proved the field of logarithmic-exponential transseries is real-closed.
- Schmeling [3] provided a comprehensive treatment of the algebraic theory.
- Aschenbrenner, van den Dries, van der Hoeven [4] proved the definitive result on H-fields and asymptotic differential algebra.

## 9. Conclusion

We have formalized a self-contained fragment of transseries theory, establishing the core algebraic structure (ordered group algebra), the valuation theory (ultrametric inequality, dominance separation), the uniqueness theorem (asymptotic comparison), and the realization coherence connecting abstract algebra to concrete asymptotics. The EML bridge theorem provides a novel connection to the EML framework, showing that the exp-log operation is the natural transmonomial group operation.

## References

[1] J. Écalle. Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac. Hermann, 1992.

[2] L. van den Dries, A. Macintyre, D. Marker. Logarithmic-exponential power series. J. London Math. Soc. 56(3):417-434, 1997.

[3] M. Schmeling. Corps de transséries. Ph.D. thesis, Université Paris 7, 2001.

[4] M. Aschenbrenner, L. van den Dries, J. van der Hoeven. Asymptotic Differential Algebra and Model Theory of Transseries. Annals of Mathematics Studies, Princeton University Press, 2017.
