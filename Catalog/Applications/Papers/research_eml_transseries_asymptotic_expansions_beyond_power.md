# Graded Transseries Algebras: A Formalized Theory of Asymptotic Growth Hierarchies

## Abstract

We introduce the **Graded Transseries Algebra** (GTA), a novel algebraic framework that enriches the classical theory of transseries with an explicit depth filtration and exp-log adjunction. We formalize growth levels as pairs (depth, exponent), where depth tracks iterated exponentiation level and exponent parameterizes growth within each level. We prove the Exponential Dominance Theorem (exp(αx) dominates x^n for α > 0), the Three-Level Hierarchy (log ≪ polynomial ≪ exponential), the Double-Exponential Dominance (exp(exp(x)) ≫ exp(αx)), and the Asymptotic Comparison Theorem for same-level transmonomials. All results are formalized with complete machine-verified proofs.

**Keywords**: transseries, asymptotic analysis, growth hierarchy, formal verification, depth filtration

## 1. Introduction

Transseries, introduced by Écalle in his work on resurgent functions and independently by Dahn and Göring, provide a natural algebraic framework for asymptotic expansions that go beyond classical power series. While a formal power series involves only monomials x^n, a transseries can include transmonomials like exp(x), exp(exp(x)), log(x), and arbitrary combinations thereof.

The central insight of this work is that the space of transmonomials admits a natural **grading by depth**: the number of times the exponential function has been iterated. This depth grading is compatible with the algebraic operations and provides a filtration that structures the entire theory.

### 1.1 Contributions

1. **Growth Level Structure** (Definition 2.1): We formalize growth levels as pairs (d, α) ∈ ℤ × ℝ with lexicographic ordering, providing a total order on transmonomials.

2. **Depth Filtration** (Section 3): We define depth-based filtering and shifting operations on transseries and prove they form an involution pair.

3. **Asymptotic Separation Theorems** (Section 4): We prove four fundamental dominance results:
   - exp(x)/x^n → ∞ (Theorem 4.1)
   - exp(αx)/x^n → ∞ for α > 0 (Theorem 4.2)  
   - x^α/log(x)^n → ∞ for α > 0 (Theorem 4.3)
   - exp(exp(x))/exp(αx) → ∞ (Theorem 4.4)

4. **Classification Preservation** (Section 5): We show that depth shifts transform power series to exponential series and vice versa.

5. **Asymptotic Comparison** (Section 6): For transmonomials at the same growth level, the asymptotic ratio converges to the ratio of coefficients.

## 2. Growth Levels

### Definition 2.1 (Growth Level)
A **growth level** is a pair g = (d, α) where d ∈ ℤ is the **depth** and α ∈ ℝ is the **exponent**. The depth counts the level of iterated exponentiation:

| Depth d | Exponent α | Transmonomial |
|---------|-----------|---------------|
| -2 | α | log(log(x))^α |
| -1 | α | log(x)^α |
| 0 | α | x^α |
| 1 | α | exp(αx) |
| 2 | α | exp(α·exp(x)) |

### Definition 2.2 (Lexicographic Order)
Growth levels are ordered lexicographically: (d₁, α₁) < (d₂, α₂) if d₁ < d₂, or d₁ = d₂ and α₁ < α₂.

### Definition 2.3 (Depth Shifts)
The **exponential shift** maps (d, α) ↦ (d+1, α), corresponding to composition with exp. The **logarithmic shift** maps (d, α) ↦ (d-1, α), corresponding to composition with log.

**Theorem 2.1** (Exp-Log Duality): The exponential and logarithmic shifts are mutually inverse: for any growth level g, expShift(logShift(g)) = g and logShift(expShift(g)) = g.

**Theorem 2.2** (Iterated Shift): The n-fold exponential shift raises depth by exactly n: depth(expShift^n(g)) = depth(g) + n.

**Theorem 2.3** (Injectivity): Both expShift and logShift are injective on growth levels.

## 3. Transseries and Depth Filtration

### Definition 3.1 (Transseries)
A **transseries** T is a finite formal sum T = Σᵢ cᵢ · mᵢ where each cᵢ ∈ ℝ is a coefficient and each mᵢ is a transmonomial at growth level gᵢ.

### Definition 3.2 (Depth Filtration)
For a transseries T and d ∈ ℤ:
- The **d-component** T|_d consists of all terms with depth exactly d.
- The **d-truncation** T|_{≤d} consists of all terms with depth ≤ d.

### Definition 3.3 (Depth Shift Operations)
- **depthShiftUp(T)**: Apply expShift to every transmonomial in T.
- **depthShiftDown(T)**: Apply logShift to every transmonomial in T.

**Theorem 3.1** (Shift Involution): depthShiftDown(depthShiftUp(T)) = T and depthShiftUp(depthShiftDown(T)) = T for all transseries T.

**Theorem 3.2** (Term Preservation): Depth shifts preserve the number of terms.

## 4. Asymptotic Separation Theorems

These are the core analytic results that justify the depth hierarchy.

**Theorem 4.1** (Exponential Dominance): For every n ∈ ℕ,
$$\lim_{x \to \infty} \frac{e^x}{x^n} = \infty$$

*Proof sketch*: This follows from the Mathlib result `Real.tendsto_exp_div_pow_atTop`.

**Theorem 4.2** (Scaled Exponential Dominance): For α > 0 and n ∈ ℕ,
$$\lim_{x \to \infty} \frac{e^{\alpha x}}{x^n} = \infty$$

*Proof sketch*: Substitute y = αx and use Theorem 4.1 with appropriate scaling.

**Theorem 4.3** (Power vs. Logarithm): For α > 0 and n ∈ ℕ,
$$\lim_{x \to \infty} \frac{x^\alpha}{(\log x)^n} = \infty$$

*Proof sketch*: Substitute x = e^t, reducing to e^{αt}/t^n → ∞ by Theorem 4.2.

**Theorem 4.4** (Double-Exponential Dominance): For any α ∈ ℝ,
$$\lim_{x \to \infty} \frac{e^{e^x}}{e^{\alpha x}} = \infty$$

*Proof sketch*: Write the ratio as exp(exp(x) - αx). Since exp(x)/x → ∞, we have exp(x) - αx = x(exp(x)/x - α) → ∞, so the exponential of this also tends to ∞.

**Theorem 4.5** (Three-Level Hierarchy): For α > 0, γ > 0, and n ∈ ℕ:
$$\frac{x^\alpha}{(\log x)^n} \to \infty \quad \text{and} \quad \frac{e^{\gamma x}}{x^n} \to \infty$$

This theorem combines Theorems 4.2 and 4.3 into a single statement establishing the three-tiered hierarchy: logarithmic ≪ polynomial ≪ exponential.

## 5. Classification Theorems

### Definition 5.1 (Series Classification)
- A transseries is a **power series** if all terms have depth 0.
- A transseries is **purely exponential** if all terms have positive depth.
- A transseries is **purely logarithmic** if all terms have negative depth.

**Theorem 5.1**: Constants and x are power series; exp(x) is purely exponential; log(x) is purely logarithmic.

**Theorem 5.2** (Classification Shift): If T is a power series, then depthShiftUp(T) is purely exponential and depthShiftDown(T) is purely logarithmic.

This theorem reveals how the depth shift serves as a "classification transformer" — it systematically moves transseries between the three categories.

## 6. Asymptotic Comparison

**Theorem 6.1** (Same-Level Comparison): For transmonomials at the same growth level g with coefficients c₁, c₂ (c₂ ≠ 0):
$$\lim_{x \to \infty} \frac{c_1 \cdot m_g(x)}{c_2 \cdot m_g(x)} = \frac{c_1}{c_2}$$

This shows that the growth level determines the "shape" while the coefficient determines the "scale" — a principle analogous to the leading-term analysis in classical asymptotics.

## 7. The Graded Transseries Algebra

### Definition 7.1 (GTA)
The **Graded Transseries Algebra** is the algebraic structure consisting of:
1. The set of all finite transseries
2. Addition (concatenation of terms)
3. Scalar multiplication
4. The depth filtration
5. The exp-log shift adjunction

The key properties that make this a useful algebraic framework:
- **Shift involution**: depthShiftUp and depthShiftDown are mutually inverse
- **Classification compatibility**: shifts transform classification types systematically
- **Asymptotic coherence**: the algebraic structure reflects the analytic asymptotic hierarchy

## 8. Examples and Boundary Cases

### Example 8.1 (PEGB for Exponential Dominance)
- **Proof**: Complete formal proof via `Real.tendsto_exp_div_pow_atTop`
- **Example**: exp(x)/x^5 for x = 10, 100, 1000: 22026/100000 ≈ 0.22, but grows without bound
- **Generalization**: exp(αx) dominates x^n for any α > 0 (Theorem 4.2)
- **Boundary**: At α = 0, exp(0·x) = 1, which does NOT dominate x^n for n ≥ 1

### Example 8.2 (PEGB for Three-Level Hierarchy)
- **Proof**: Combination of Theorems 4.2 and 4.3
- **Example**: At x = e^10: log(x)=10, x=e^10≈22026, exp(x)≈exp(22026)
- **Generalization**: The hierarchy extends to arbitrary depth: depth d+1 always dominates depth d
- **Boundary**: At depth 0, x^α with α = 0 gives constant 1, which fails to dominate log(x)

### Example 8.3 (PEGB for Shift Classification)
- **Proof**: Direct computation on growth levels
- **Example**: T = 3x² + 5x (power series) → depthShiftUp(T) = 3·exp(2x) + 5·exp(x) (exponential)
- **Generalization**: n-fold depth shift sends depth-0 series to depth-n series
- **Boundary**: The empty transseries (zero) is simultaneously power series, exponential, and logarithmic (vacuously)

## 9. Algorithms

### Algorithm 9.1: Transseries Comparison
**Input**: Two transseries S, T  
**Output**: Which dominates asymptotically  
1. Extract leading growth levels g_S, g_T
2. Compare depths: if d_S > d_T, return S dominates
3. If depths equal, compare exponents: if α_S > α_T, return S dominates
4. If growth levels equal, compare leading coefficients

### Algorithm 9.2: Depth Filtration Decomposition
**Input**: A transseries T  
**Output**: Decomposition {T|_d : d ∈ support(T)}  
1. Extract all distinct depths from T.terms
2. For each depth d, filter terms with that depth
3. Return the mapping d ↦ T|_d

## 10. Conjectures and Future Work

### Conjecture 10.1 (Transmonomial Independence)
For any finite set of growth levels {g₁, ..., gₖ} with pairwise distinct entries, if Σᵢ cᵢ · m_{gᵢ}(x) = 0 for all sufficiently large x, then all cᵢ = 0.

**Test**: Verify computationally for growth levels at depths {-1, 0, 1} with various exponents.

### Conjecture 10.2 (Depth-Product Compatibility)
The product of a depth-d₁ transmonomial and a depth-d₂ transmonomial has depth max(d₁, d₂) when d₁ ≠ d₂, and depth d₁ with added exponents when d₁ = d₂.

## 11. Discussion

The Graded Transseries Algebra provides a clean algebraic framework for asymptotic analysis. The depth filtration is the key structural innovation: it organizes the space of growth rates into a hierarchy where the algebraic operations (addition, scalar multiplication, depth shift) are well-behaved.

The formal verification of the core asymptotic separation results — particularly the Double-Exponential Dominance theorem — demonstrates that these results, while intuitively obvious, require non-trivial proof techniques involving composition of limits and careful management of asymptotic estimates.

The connection to EML (exp-minus-log) theory is through the depth shift operations, which formalize the compositional structure of the exp and log functions. The shift involution theorem is the algebraic manifestation of the analytic identity exp(log(x)) = x.

## References

1. J. Écalle, *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*, Hermann, 1992.
2. L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential power series," *J. London Math. Soc.*, 56(3):417-434, 1997.
3. J. van der Hoeven, *Transseries and Real Differential Algebra*, Lecture Notes in Mathematics 1888, Springer, 2006.
4. M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra and Model Theory of Transseries*, Annals of Mathematics Studies 195, Princeton, 2017.
