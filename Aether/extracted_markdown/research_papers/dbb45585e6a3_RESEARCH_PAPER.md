# Formalized Transseries: Asymptotic Expansions Beyond Power Series

## Abstract

We present a formalization of the foundational theory of transseries in Lean 4, establishing the strict dominance hierarchy of exponential-logarithmic-polynomial monomials, the faithfulness of asymptotic comparison, and the connection to the EML (exp-minus-log) function system. Our main results include: (1) the complete proof that exponentials dominate all polynomials and logarithms are subordinate to all positive powers; (2) the strict hierarchy theorem for iterated exponentials; (3) the asymptotic comparison theorem showing that distinct leading monomials produce distinguishable asymptotic behavior; (4) the Hardy field structure of exponential-polynomial functions; and (5) the bridge theorem connecting iterated EML diagonal composition to the exponential tower. All results are machine-verified with no axioms beyond the standard foundations.

**Keywords**: Transseries, asymptotic expansion, Hardy field, exponential dominance, EML function, formal verification

## 1. Introduction

### 1.1 Background

Transseries, introduced by Écalle [1] and developed by van den Dries, Macintyre, and Marker [2], provide a formal framework for asymptotic expansions that extend classical power series. While power series involve only integer powers of a variable, transseries allow exponentials, logarithms, and their iterations as building blocks.

The fundamental insight is that functions arising in analysis — solutions of differential equations, growth rates of algorithms, asymptotic counts in combinatorics — often cannot be captured by convergent power series but have canonical transseries representations. The field of transseries $\mathbb{T}$ is real closed [3], meaning it satisfies the same first-order theory as $\mathbb{R}$, and carries a natural derivation making it a differential field.

### 1.2 The EML Connection

The EML (exp-minus-log) function $\text{eml}(x,y) = e^x - \log y$, studied extensively in the EML research program [4,5], provides a natural bridge to transseries theory. The EML function combines the two fundamental operations — exponentiation and logarithm — that generate the transseries hierarchy. Its diagonal $d(z) = e^z - \log z$ is a map whose iterations climb the exponential tower, generating increasingly complex asymptotic behavior.

### 1.3 Contributions

Our contributions are:

1. **Formal definitions** of asymptotic dominance, asymptotic equivalence, iterated exponentials/logarithms, transseries monomials, and Hardy fields in Lean 4.

2. **Dominance hierarchy theorems**: Machine-verified proofs that:
   - $\exp$ dominates all polynomials: $x^n / e^x \to 0$
   - $\log$ is subordinate to all positive powers: $\log x / x^\varepsilon \to 0$ for $\varepsilon > 0$
   - Iterated exponentials form a strict hierarchy: $\text{iterExp}_n / \text{iterExp}_{n+1} \to 0$
   - The monomial dominance order is trichotomous (total)

3. **Asymptotic comparison theorem**: Proof that functions with distinct exponential growth rates are asymptotically distinguishable, and that asymptotic equivalence preserves growth rate data injectively.

4. **EML bridge theorems**: Proofs connecting EML diagonal iteration to the exponential hierarchy, including growth bounds and asymptotic equivalence to $\exp$.

5. **Hardy field structure**: Formalization of Hardy fields and proof that exponential-polynomial functions satisfy the eventual-sign property.

## 2. Definitions

### 2.1 Asymptotic Relations

**Definition 2.1** (Asymptotic Dominance). A function $f$ *asymptotically dominates* $g$, written $\text{AsympDominates}(f,g)$, if $g(x)/f(x) \to 0$ as $x \to +\infty$.

**Definition 2.2** (Asymptotic Equivalence). Functions $f$ and $g$ are *asymptotically equivalent*, written $\text{AsympEquiv}(f,g)$, if $f(x)/g(x) \to 1$ as $x \to +\infty$.

### 2.2 Iterated Operations

**Definition 2.3** (Iterated Exponential).
$$\text{iterExp}(0, x) = x, \qquad \text{iterExp}(n+1, x) = \exp(\text{iterExp}(n, x))$$

**Definition 2.4** (Iterated Logarithm).
$$\text{iterLog}(0, x) = x, \qquad \text{iterLog}(n+1, x) = \log(\text{iterLog}(n, x))$$

### 2.3 Transseries Monomials

**Definition 2.5** (Transseries Monomial). A *first-level transseries monomial* is a triple $(\alpha, \beta, \gamma) \in \mathbb{R}^3$ representing the function $x^\alpha \cdot e^{\beta x} \cdot (\log x)^\gamma$.

**Definition 2.6** (Dominance Order). Monomial $m_1 = (\alpha_1, \beta_1, \gamma_1)$ *dominates* $m_2 = (\alpha_2, \beta_2, \gamma_2)$ if $(\beta_1, \alpha_1, \gamma_1) >_{\text{lex}} (\beta_2, \alpha_2, \gamma_2)$.

### 2.4 EML Functions

**Definition 2.7** (EML). $\text{eml}(x,y) = e^x - \log y$.

**Definition 2.8** (EML Diagonal). $\text{emlDiag}(z) = e^z - \log z$.

**Definition 2.9** (Iterated EML Diagonal). $\text{emlDiagIter}(0, z) = z$, $\text{emlDiagIter}(n+1, z) = \text{emlDiag}(\text{emlDiagIter}(n, z))$.

### 2.5 Hardy Fields

**Definition 2.10** (Hardy Field). A set $S$ of functions $\mathbb{R} \to \mathbb{R}$ is a *Hardy field* if it is closed under $+$, $-$, $\times$, contains all constants, and every nonzero $f \in S$ eventually has constant sign.

## 3. Main Results

### 3.1 The Dominance Hierarchy

**Theorem 3.1** (Exponential Dominates Polynomials). *For all $n \in \mathbb{N}$:*
$$\lim_{x \to +\infty} \frac{x^n}{e^x} = 0$$

*Proof.* By Mathlib's `Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero`. □

**Theorem 3.2** (Logarithmic Subordination). *For all $\varepsilon > 0$:*
$$\lim_{x \to +\infty} \frac{\log x}{x^\varepsilon} = 0$$

*Proof sketch.* Substitute $y = \log x$, reducing to $y / e^{y\varepsilon} \to 0$, which follows from Theorem 3.1. □

**Theorem 3.3** (Iterated Exponential Hierarchy). *For all $n \in \mathbb{N}$:*
$$\lim_{x \to +\infty} \frac{\text{iterExp}(n, x)}{\text{iterExp}(n+1, x)} = 0$$

*Proof sketch.* By Theorem 3.1 with the substitution $u = \text{iterExp}(n, x)$, noting that $\text{iterExp}(n, \cdot)$ tends to $+\infty$ by induction. □

**Theorem 3.4** (Monomial Trichotomy). *For any monomials $m_1, m_2$, exactly one of $m_1 \succ m_2$, $m_1 \equiv m_2$, or $m_1 \prec m_2$ holds.*

*Proof.* Lexicographic trichotomy on the three components. □

### 3.2 Asymptotic Comparison

**Theorem 3.5** (Exponential Growth Injectivity). *If $\beta_1 \neq \beta_2$, then $e^{\beta_1 x}$ and $e^{\beta_2 x}$ are not asymptotically equivalent.*

*Proof sketch.* Their ratio $e^{(\beta_1 - \beta_2)x}$ tends to $+\infty$ or $0$, neither of which equals $1$. □

**Theorem 3.6** (Asymptotic Comparison for Exponential-Polynomial Sums). *If $\beta_1 > \beta_2$ and $a_1 \neq 0$, then:*
$$\frac{a_1 e^{\beta_1 x} + a_2 e^{\beta_2 x}}{a_1 e^{\beta_1 x}} \to 1$$

*This shows the leading term determines the asymptotic behavior.*

*Proof sketch.* The ratio simplifies to $1 + (a_2/a_1) e^{(\beta_2 - \beta_1)x}$, and $e^{(\beta_2 - \beta_1)x} \to 0$ since $\beta_2 - \beta_1 < 0$. □

**Theorem 3.7** (Transitivity of Dominance). *Asymptotic dominance is transitive: if $f \succ g$ and $g \succ h$, then $f \succ h$.*

*Proof sketch.* $h/f = (h/g)(g/f) \to 0 \cdot 0 = 0$. □

### 3.3 EML Bridge Results

**Theorem 3.8** (EML Leading Term). *For fixed $y > 0$, $\text{eml}(x,y) / e^x \to 1$ as $x \to +\infty$.*

*This shows $e^x$ is the leading term of the EML function.*

**Theorem 3.9** (EML Diagonal Dominance). *For $z > 1$, $\text{emlDiag}(z) > z$.*

*This means each application of the EML diagonal pushes values higher.*

**Theorem 3.10** (EML Diagonal Asymptotic). *$\text{emlDiag}(z) / e^z \to 1$ as $z \to +\infty$.*

*The logarithmic correction is asymptotically negligible.*

**Theorem 3.11** (Iterated EML Strict Growth). *For $z > 1$ and all $n$, $\text{emlDiagIter}(n+1, z) > \text{emlDiagIter}(n, z)$.*

**Theorem 3.12** (Double EML Super-Exponential). *For $z > 2$, $\text{emlDiagIter}(2, z) > e^z$.*

*Two iterations of the EML diagonal already exceed the single exponential.*

### 3.4 Hardy Field Properties

**Theorem 3.13** (Eventual Sign). *For $a \neq 0$, the function $x \mapsto a \cdot e^{\beta x}$ is eventually of constant sign (positive if $a > 0$, negative if $a < 0$).*

**Theorem 3.14** (Valuation Characterization). *Two monomials have the same valuation if and only if they are equivalent (same $\alpha$, $\beta$, $\gamma$).*

## 4. The PEGB Framework

### 4.1 Exponential Dominance (Theorem 3.1)

- **Proof**: Complete, verified in `ExpDominance.lean`.
- **Example**: $100^5 / e^{100} \approx 3.7 \times 10^{-34}$.
- **Generalization**: Extends to $p(x)/e^x \to 0$ for any polynomial $p$, and to iterated exponentials (Theorem 3.3).
- **Boundary**: Fails for $e^x / e^x = 1$; fails when the base is not $e$ but a number $\leq 1$.

### 4.2 Asymptotic Comparison (Theorem 3.6)

- **Proof**: Complete, verified in `ExpDominance.lean`.
- **Example**: $(e^{2x} - 3e^x) / e^{2x} \to 1$ as $x \to \infty$.
- **Generalization**: Extends to sums of arbitrarily many exponential terms; the leading term always determines the asymptotic behavior (this is the foundation of the full comparison theorem for transseries).
- **Boundary**: Breaks when $\beta_1 = \beta_2$ (same exponential rate) — then polynomial degrees matter.

### 4.3 EML Diagonal Hierarchy (Theorems 3.9–3.12)

- **Proof**: Complete, verified in `EMLBridge.lean`.
- **Example**: $\text{emlDiag}(5) = e^5 - \log 5 \approx 146.8$, while $5$ itself is much smaller.
- **Generalization**: Each iteration of `emlDiag` climbs one level of the exponential tower; $n$ iterations produce $\text{iterExp}(n)$-scale growth.
- **Boundary**: The bound `emlDiag(z) > z` requires $z > 1$; for $z \leq 0$, `emlDiag` is not even well-defined.

### 4.4 Monomial Trichotomy (Theorem 3.4)

- **Proof**: Complete, verified in `ExpDominance.lean`.
- **Example**: $x^2 e^x \succ x^{1000}$ (exponential beats polynomial).
- **Generalization**: The lexicographic order extends to higher-level transseries monomials involving iterated exponentials.
- **Boundary**: The order is total on monomials but not on general transseries (where cancellation can occur between terms).

## 5. Cross-Domain Bridge: Tropical Valuations

The valuation map $v : \text{TransseriesMonomial} \to \mathbb{R}^3$ sending $(\alpha, \beta, \gamma)$ to $(\beta, \alpha, \gamma)$ connects transseries to **tropical geometry**. In tropical mathematics, the "value" of an expression is determined by its leading term under a valuation — exactly as in transseries.

Specifically:
- The tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$ acts on transseries valuations.
- Adding two transseries corresponds to taking the $\max$ of their valuations (the dominant term wins).
- Multiplying two transseries corresponds to adding their valuations.

This bridge shows that transseries theory and tropical geometry are two faces of the same coin: both are theories of **dominant-term asymptotics**.

## 6. Algorithms

### 6.1 Monomial Comparison

```
COMPARE_MONOMIALS(m₁, m₂):
  if m₁.β > m₂.β: return ≻
  if m₁.β < m₂.β: return ≺
  if m₁.α > m₂.α: return ≻
  if m₁.α < m₂.α: return ≺
  if m₁.γ > m₂.γ: return ≻
  if m₁.γ < m₂.γ: return ≺
  return ≡
```

### 6.2 Asymptotic Expansion

```
EXPAND_EML_CHAIN(chain, depth):
  if depth = 0: return identity transseries
  t = EXPAND_EML_CHAIN(chain, depth - 1)
  return exp(t) - log(t)  // symbolic expansion
```

## 7. Discussion

### 7.1 Relation to Prior Work

Our formalization deepens the existing EML theory in the Catalog by placing it within the broader framework of transseries and Hardy fields. The key catalog results we build upon include:

- `eml_log_exp` (EML/EMLv17Core.lean): The identity $\text{eml}(\log a, \exp b) = a - b$ for $a > 0$, which shows EML implements the fundamental exp-log cancellation.
- `eml_chain_exp_log_cancel` (EML/KolmogorovArnoldEMLDeep.lean): The chain cancellation $\exp(\log x) = x$, which is the identity that makes the exponential tower well-defined.
- `eml14_exp_log_gap` (EML/V14Research.lean): The gap between exponential and logarithmic scales, which our dominance hierarchy theorem generalizes.

### 7.2 Limitations

Our formalization covers the "first level" of the transseries hierarchy — monomials involving single exponentials, polynomials, and logarithms. The full transseries construction involves:

1. **Higher-level monomials**: $e^{e^x}$, $e^{e^{e^x}}}$, etc., which require an ordinal-indexed hierarchy.
2. **Infinite sums**: Formal series with well-ordered support over the monomial group.
3. **Field operations**: Full division and the real-closedness theorem.
4. **Differential structure**: The derivation on transseries and its interaction with the valuation.

These extensions are significant formal verification challenges that we leave for future work.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed research directions.

## References

[1] J. Écalle. *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*. Actualités Mathématiques, Hermann, Paris, 1992.

[2] L. van den Dries, A. Macintyre, D. Marker. "Logarithmic-exponential series." *Annals of Pure and Applied Logic*, 111(1-2):61–113, 2001.

[3] M. Aschenbrenner, L. van den Dries, J. van der Hoeven. *Asymptotic Differential Algebra and Model Theory of Transseries*. Annals of Mathematics Studies, Princeton University Press, 2017.

[4] EML Research Program. `Catalog/EML/EMLv17Core.lean`. Definition of eml and basic identities.

[5] EML Research Program. `Catalog/EML/KolmogorovArnoldEMLDeep.lean`. EML chain theory and Kolmogorov-Arnold connections.

[6] G.H. Hardy. *Orders of Infinity*. Cambridge Tracts in Mathematics, 1910.

[7] M. Rosenlicht. "Hardy fields." *Journal of Mathematical Analysis and Applications*, 93:297–311, 1983.
