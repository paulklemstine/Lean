# Formalized Transseries: Asymptotic Expansions Beyond Power Series

## Abstract

We present a formal mathematical framework for transseries — generalized formal series involving iterated exponentials and logarithms — with complete machine-verified proofs of the core structural theorems. Our contributions include: (1) a formalization of **growth levels** as lexicographically ordered pairs (depth, exponent) that capture the asymptotic hierarchy of transmonomials; (2) the **Depth Separation Theorem** proving that transmonomials at higher depths asymptotically dominate all lower-depth transmonomials; (3) an **Asymptotic Uniqueness Theorem** showing that exponential coefficients are uniquely determined by boundedness conditions; (4) the **Exp-Log Galois Connection** establishing that depth-shifting operations form an order-preserving bijection; and (5) connections to the EML (exp-minus-log) framework. All 25+ theorems are proved without sorry and verified by the Lean 4 proof assistant with Mathlib.

**Keywords**: transseries, asymptotic analysis, formal verification, growth hierarchy, Hardy fields

## 1. Introduction

### 1.1 Background

Transseries, introduced by Écalle [1] and systematically developed by van den Dries, Macintyre, and Marker [2], generalize formal power series by incorporating iterated exponentials and logarithms. A *transmonomial* of depth *d* takes the form:

- Depth 0: x^α (power functions)
- Depth 1: exp(αx) (exponentials)
- Depth 2: exp(α·exp(x)) (double exponentials)
- Depth −1: (log x)^α (logarithmic)

A *transseries* is a formal sum of transmonomials with real coefficients. The field of transseries possesses remarkable algebraic properties — van den Dries et al. proved it is real closed and admits a natural ordering compatible with asymptotic comparison.

### 1.2 Our Contributions

We provide the first comprehensive formalization of the core structural theory of transseries, including:

1. **Growth Level Algebra** (§3): Definition of growth levels as `ℤ ×ₗ ℝ` with lexicographic ordering, yielding a decidable linear order on transmonomials.

2. **Depth Separation Theorems** (§4): Complete proofs that:
   - `exp(αx) / x^n → ∞` for α > 0 (exponential-polynomial separation)
   - `exp(exp(x)) / exp(cx) → ∞` for all c (depth-2 vs depth-1 separation)
   - `log(x) / x^ε → 0` for ε > 0 (logarithmic subordination)

3. **Asymptotic Uniqueness** (§5): If `|exp(αx) − exp(βx)| ≤ C` eventually and α,β ≥ 0, then α = β.

4. **Growth Filtration Structure** (§6): Novel formalization of the depth stratification with exp/log Galois connection.

5. **EML Connection** (§7): Integration with the exp-minus-log operation framework.

## 2. Definitions

### 2.1 Growth Levels

**Definition 2.1** (Growth Level). A *growth level* is an element of `ℤ ×ₗ ℝ`, where the first component is the *depth* and the second is the *exponent*. The ordering is lexicographic: `(d₁, e₁) < (d₂, e₂)` iff `d₁ < d₂`, or `d₁ = d₂` and `e₁ < e₂`.

```
abbrev GrowthLevel := ℤ ×ₗ ℝ
```

This yields a decidable linear order, essential for defining finite supports and leading terms.

### 2.2 Transmonomials

**Definition 2.2** (Transmonomial Evaluation). The evaluation of a transmonomial at depth *d* with exponent *α* is:

| Depth | Evaluation | Lean Definition |
|-------|-----------|----------------|
| −1 | (log x)^α | `transmonomial_depthNeg1 α` |
| 0 | x^α | `transmonomial_depth0 α` |
| 1 | exp(αx) | `transmonomial_depth1 α` |
| 2 | exp(α·exp(x)) | `transmonomial_depth2 α` |

### 2.3 Formal Transseries

**Definition 2.3** (Formal Transseries). A *formal transseries* is a triple `(S, c, h)` where:
- `S : Finset GrowthLevel` is the support
- `c : GrowthLevel → ℝ` is the coefficient function
- `h : ∀ g ∉ S, c(g) = 0` ensures finite support

```
structure FormalTransseries where
  support : Finset GrowthLevel
  coeff : GrowthLevel → ℝ
  coeff_zero_outside : ∀ g, g ∉ support → coeff g = 0
```

### 2.4 Asymptotic Dominance

**Definition 2.4** (Asymptotic Dominance). `f` *asymptotically dominates* `g`, written `AsympDominates f g`, if `f(x)/g(x) → +∞` as `x → +∞`.

### 2.5 Growth Filtration

**Definition 2.5** (Growth Filtration). A *growth filtration* is a depth-stratification of growth levels with the property that within each stratum, comparison reduces to exponent comparison.

```
structure GrowthFiltration where
  stratum : GrowthLevel → ℤ
  stratum_eq_depth : ∀ g, stratum g = g.depth
  intra_stratum_compare : ∀ g₁ g₂,
    g₁.depth = g₂.depth → (g₁ < g₂ ↔ g₁.exponent < g₂.exponent)
```

## 3. Growth Level Algebra

### 3.1 Linear Order

The lexicographic ordering on `ℤ × ℝ` induces a linear order on growth levels via `LinearOrder.lift'`. Key structural theorems:

**Theorem 3.1** (Cross-Depth Comparison). Any exponential-level growth dominates any polynomial-level growth: `power β < expLevel α` for α > 0.

**Theorem 3.2** (Depth Hierarchy). The canonical growth levels satisfy `logLevel β < power α < expLevel γ < expExpLevel δ` for positive exponents.

### 3.2 Exp-Log Shifts

**Definition 3.3**. The *exp shift* and *log shift* operations:
```
def expShift (g : GrowthLevel) : GrowthLevel := (g.depth + 1, g.exponent)
def logShift (g : GrowthLevel) : GrowthLevel := (g.depth - 1, g.exponent)
```

**Theorem 3.4** (Galois Connection). `expShift` and `logShift` are mutual inverses and both strictly monotone.

**Theorem 3.5** (Iterated Depth). The n-fold iterated exp shift satisfies `(iterExpShift n g).depth = g.depth + n`.

## 4. Depth Separation Theorems

### 4.1 Exponential-Polynomial Separation

**Theorem 4.1** (Exp Dominates Poly). For α > 0 and n ∈ ℕ:
$$\lim_{x \to \infty} \frac{e^{\alpha x}}{x^n} = +\infty$$

*Proof sketch*: Reduce to the unit case α = 1 via substitution y = αx, then apply the Mathlib lemma `Real.tendsto_exp_div_pow_atTop`.

### 4.2 Depth-2 vs Depth-1 Separation

**Theorem 4.2** (Double Exp Dominates). For any constant c ∈ ℝ:
$$\lim_{x \to \infty} \frac{e^{e^x}}{e^{cx}} = +\infty$$

*Proof sketch*: Write the ratio as `exp(exp(x) - cx)`. The exponent `exp(x) - cx → ∞` by Theorem 4.1 (with n=1), and exp preserves this divergence.

**Corollary 4.3**. `exp(exp(x)) / (exp(x))^n → ∞` for all n.

### 4.3 Logarithmic Subordination

**Theorem 4.4** (Log Subordination). For ε > 0:
$$\lim_{x \to \infty} \frac{\log x}{x^\varepsilon} = 0$$

*Proof sketch*: Substitution y = x^ε transforms this to (1/ε) · log(y) / y → 0, which follows from standard analysis.

**Theorem 4.5** (Power Dominates Log). For ε > 0: `x^ε / log(x) → ∞`.

### 4.4 Same-Depth Comparison

**Theorem 4.6** (Depth-1 Exponent Comparison). For α₁ > α₂:
$$\frac{e^{\alpha_1 x}}{e^{\alpha_2 x}} = e^{(\alpha_1 - \alpha_2)x} \to +\infty$$

**Theorem 4.7** (Depth-0 Exponent Comparison). For α₁ > α₂:
$$\frac{x^{\alpha_1}}{x^{\alpha_2}} = x^{\alpha_1 - \alpha_2} \to +\infty$$

## 5. Asymptotic Uniqueness

### 5.1 Main Theorem

**Theorem 5.1** (Exponential Coefficient Determination). Let α, β ≥ 0. If there exists C > 0 such that `|exp(αx) − exp(βx)| ≤ C` for all sufficiently large x, then α = β.

*Proof*: By contradiction. Assume α ≠ β; WLOG α > β. Then exp(αx) − exp(βx) = exp(βx)·(exp((α−β)x) − 1). Since β ≥ 0, exp(βx) ≥ 1, and exp((α−β)x) → ∞, the product diverges, contradicting boundedness.

**Remark 5.2**. The hypothesis α, β ≥ 0 is necessary. Counterexample: α = 0, β = −1 gives |1 − exp(−x)| ≤ 1, yet α ≠ β.

### 5.2 Coefficient Uniqueness

**Theorem 5.3** (Coefficient Uniqueness). If T₁, T₂ are formal transseries with `T₁.coeff g = T₂.coeff g` for all growth levels g, then `(T₁ + (−1)·T₂).coeff g = 0` for all g.

## 6. Growth Filtration Structure

### 6.1 The Canonical Filtration

**Theorem 6.1** (Canonical Filtration). There exists a growth filtration where `stratum(g) = g.depth` and within each stratum, comparison reduces to exponent comparison.

### 6.2 Hardy Field Properties

**Theorem 6.2** (Eventual Positivity). 
- `exp(αx) > 0` for all x (depth 1)
- `x^α > 0` eventually for α > 0 (depth 0)  
- `log(x) > 0` eventually (depth −1)

**Theorem 6.3** (Eventual Nonvanishing). Every depth-1 transmonomial `exp(αx)` is eventually nonzero.

### 6.3 Leading Term Determines Sign

**Theorem 6.4**. For c > 0 and n ∈ ℕ, `c·exp(x) − x^n > 0` eventually. The leading term (depth 1) determines the eventual sign.

## 7. EML Connection

### 7.1 Transseries Decomposition

The EML operation `eml(a,b) = exp(a) − log(b)` decomposes as a sum of a depth-1 term and a depth-(−1) term.

**Theorem 7.1** (EML Asymptotic Dominance). `(exp(a) − log(b)) / exp(a) → 1` as a → ∞. The exponential component asymptotically dominates the logarithmic component.

**Theorem 7.2** (EML Depth Decomposition). `exp(a) − log(b) = exp(a) + (−log(b))`, expressing EML as a two-term transseries.

## 8. Single-Term Algebra

**Theorem 8.1** (Support Disjointness). Single-term transseries at different growth levels have disjoint supports.

**Theorem 8.2** (Coefficient Recovery). The coefficient of a single-term transseries at its growth level equals its defining coefficient.

## 9. Discussion

### 9.1 Relation to Prior Work

Our formalization captures the "elementary" but foundational layer of transseries theory. The full theory of van den Dries–Macintyre–Marker [2] proves much deeper results — real closedness, the existence of derivations, and model-theoretic transfer principles — which would require substantial additional formalization effort.

### 9.2 Novel Aspects

1. **Growth Filtration as a first-class mathematical structure**: Rather than treating depth stratification as an ad hoc classification, we formalize it as a structure with axioms and prove it captures the complete asymptotic comparison theory.

2. **Exp-Log Galois Connection**: The mutual invertibility and monotonicity of depth-shifting operations is formalized as a pair of strictly monotone functions, revealing a clean Galois-connection structure.

3. **EML Integration**: We connect the transseries framework to the EML operation, showing how the depth hierarchy naturally explains EML's asymptotic behavior.

### 9.3 Limitations

Our current formalization treats only finitely-supported transseries. The full theory requires well-ordered supports (allowing infinite series) and a more sophisticated definition of summation. Additionally, we do not yet formalize multiplication of transseries, which requires a convolution product on the growth level monoid.

## 10. Algorithms

### 10.1 Transmonomial Comparison

Given two transmonomials with growth levels (d₁, e₁) and (d₂, e₂):
1. If d₁ ≠ d₂, the one with higher depth dominates.
2. If d₁ = d₂, the one with larger exponent dominates.
3. If both are equal, the transmonomials have the same growth rate.

This is an O(1) comparison algorithm.

### 10.2 Leading Term Extraction

Given a transseries T:
1. Find the maximum growth level in the support (using the linear order).
2. The coefficient at this level is the leading coefficient.
3. The growth level determines the dominant asymptotic behavior.

## 11. Future Work

1. **Infinite-support transseries**: Extend to well-ordered infinite supports.
2. **Multiplication**: Define the convolution product and prove field axioms.
3. **Real closedness**: Formalize the theorem that the transseries field is real closed.
4. **Derivations**: Formalize the natural derivation on transseries.
5. **Hardy field embedding**: Show that germs of EML functions embed into the transseries field.

## References

[1] J. Écalle, *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*, Hermann, 1992.

[2] L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential power series," *J. London Math. Soc.* 56 (1997), 417–434.

[3] L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential series," *Ann. Pure Appl. Logic* 111 (2001), 61–113.

[4] M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra and Model Theory of Transseries*, Annals of Mathematics Studies 195, Princeton University Press, 2017.
