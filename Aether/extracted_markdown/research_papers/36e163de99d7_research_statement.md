# Anisotropic Footprint Bound on Finite Cartesian Products: A Formally Verified Generalization of the Alon–Füredi Theorem

## Abstract

We prove the anisotropic footprint bound for multivariate polynomials evaluated on arbitrary finite Cartesian products over a field: given finite nonempty sets $S_1, \ldots, S_n \subseteq F$ and a nonzero polynomial $f \in F[X_1, \ldots, X_n]$ with $\deg_{X_i}(f) \leq e_i < |S_i|$, the number of grid points in $\prod_i S_i$ where $f$ does not vanish is at least $\prod_i (|S_i| - e_i)$. This generalizes the classical footprint bound from uniform grids ($F_q^n$) to non-uniform Cartesian products—the natural setting for coding theory with unequal symbol sets, combinatorial Nullstellensatz on restricted domains, and algebraic complexity on product state spaces.

The proof is formalized in Lean 4 with the Mathlib library, constituting the first machine-verified proof of the anisotropic Alon–Füredi theorem. We develop reusable infrastructure including grid definitions, support-based reducedness predicates, and a complete chain of helper lemmas connecting the `finSuccEquiv` algebra equivalence to fiberwise root counting.

We additionally prove:
- A restricted-grid combinatorial Nullstellensatz (existence of nonzero evaluations),
- A `degreeOf`-based formulation,
- A uniform-grid specialization recovering the classical bound.

**Keywords:** Schwartz-Zippel lemma, Alon-Füredi theorem, combinatorial Nullstellensatz, affine Cartesian codes, multivariate polynomials, finite fields, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The Schwartz-Zippel lemma [Schwartz 1980, Zippel 1979] and its refinements are foundational tools in theoretical computer science and combinatorics. The classical statement bounds the number of zeros of a polynomial on a Cartesian product of identical sets. However, many applications naturally involve *non-uniform* product sets:

- **Coding theory:** Evaluation codes on grids where each coordinate uses a different subset of the field (affine Cartesian codes [López et al. 2014]).
- **Combinatorics:** The combinatorial Nullstellensatz [Alon 1999] applies on arbitrary product sets but only gives existence, not counting.
- **Algebraic complexity:** Polynomial identity testing over structured (non-uniform) evaluation domains.
- **Statistical mechanics:** Product configuration spaces where each site has a different number of states.

### 1.2 Main Contributions

1. **Theorem (Anisotropic Footprint Bound).** Let $F$ be a field, $S_i \subseteq F$ finite nonempty sets for $i = 1, \ldots, n$, and $f \in F[X_1, \ldots, X_n]$ nonzero. If for each $i$, every monomial of $f$ has exponent $\leq e_i < |S_i|$ in $X_i$, then
$$|\{x \in \prod_i S_i : f(x) \neq 0\}| \geq \prod_i (|S_i| - e_i).$$

2. **Restricted-Grid Nullstellensatz.** Under the same hypotheses, there exists $x \in \prod_i S_i$ with $f(x) \neq 0$.

3. **Formal Verification.** Complete machine-checked proofs in Lean 4 with Mathlib, with zero `sorry` statements and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 1.3 Relation to Prior Work

The bound $\prod_i (|S_i| - e_i)$ appears implicitly in several contexts:

- **Alon (1999):** The combinatorial Nullstellensatz gives the *existence* of a nonzero evaluation point but not the quantitative lower bound.
- **Ball and Serra (2009):** Proved a version of the Alon-Füredi theorem for uniform grids.
- **López, Rentería-Márquez, and Villarreal (2014):** Proved the bound in the context of affine Cartesian codes. Their proof uses algebraic-geometric methods (Hilbert function computation).
- **Clark (2014):** Gave an elementary proof via induction for the general case.

Our contribution is threefold: (a) a clean, self-contained statement and proof in the language of modern algebra, (b) formal machine verification, and (c) reusable infrastructure for future formalization work on polynomial evaluation codes and Nullstellensatz-type results.

---

## 2. Definitions and Notation

### 2.1 The Grid

Let $F$ be a field and $n \geq 0$ an integer. For finite sets $S_i \subseteq F$ ($i = 1, \ldots, n$), the **grid** is
$$\text{Grid}(S) := \prod_{i=1}^n S_i = \{(x_1, \ldots, x_n) : x_i \in S_i \text{ for all } i\}.$$

In the formal development, we define:
```
def grid (S : Fin n → Finset F) : Finset (Fin n → F) := Fintype.piFinset S
```

### 2.2 Reducedness

A polynomial $f \in F[X_1, \ldots, X_n]$ is **reduced on grid $S$** if for every monomial $X^m = \prod_i X_i^{m_i}$ appearing in $f$ (i.e., with nonzero coefficient), we have $m_i < |S_i|$ for all $i$.

```
def IsReducedOnGrid (S : Fin n → Finset F) (f : MvPolynomial (Fin n) F) : Prop :=
  ∀ i m, m ∈ f.support → m i < (S i).card
```

This is equivalent to $f$ being a representative modulo the ideal $\langle \prod_{a \in S_i}(X_i - a) : i \rangle$, but the support-based definition avoids heavy ideal-theoretic machinery.

### 2.3 Exponent Bounds

Instead of using `degreeOf` (which can be cumbersome in formal proofs), we work with explicit exponent bound functions $e : \{1, \ldots, n\} \to \mathbb{N}$ satisfying:
- $m_i \leq e_i$ for all monomials $X^m$ in $f$ and all $i$, and
- $e_i < |S_i|$ for all $i$.

This generality allows the bound to be applied with any convenient upper bound on the coordinatewise degrees, not just the exact degree.

---

## 3. Main Results

### 3.1 Restricted-Grid Nullstellensatz

**Theorem 3.1.** *Let $F$ be a field, $S_i \subseteq F$ finite nonempty sets, and $f \in F[X_1, \ldots, X_n]$ a nonzero polynomial that is reduced on grid $S$. Then there exists $x \in \text{Grid}(S)$ with $f(x) \neq 0$.*

This is the qualitative version of the footprint bound and serves as an important stepping stone.

### 3.2 Anisotropic Footprint Bound

**Theorem 3.2 (Main Theorem).** *Let $F$ be a field, $S_i \subseteq F$ finite nonempty for $i = 1, \ldots, n$, and $f \in F[X_1, \ldots, X_n]$ nonzero. Suppose $e : \{1, \ldots, n\} \to \mathbb{N}$ satisfies:*
1. *$m_i \leq e_i$ for all monomials $X^m$ in $f$ and all $i$;*
2. *$e_i < |S_i|$ for all $i$.*

*Then*
$$|\{x \in \text{Grid}(S) : f(x) \neq 0\}| \geq \prod_{i=1}^n (|S_i| - e_i).$$

### 3.3 Corollaries

**Corollary 3.3 (degreeOf version).** *If $\deg_{X_i}(f) < |S_i|$ for all $i$, then*
$$|\{x \in \text{Grid}(S) : f(x) \neq 0\}| \geq \prod_i (|S_i| - \deg_{X_i}(f)).$$

**Corollary 3.4 (Uniform grid).** *When all $S_i = S_0$ and all degree bounds equal $d < |S_0|$,*
$$|\text{nonzeros}| \geq (|S_0| - d)^n.$$

---

## 4. Proof Architecture

### 4.1 Overview

The proof proceeds by strong induction on $n$ (the number of variables), using the `MvPolynomial.finSuccEquiv` algebra equivalence:
$$F[X_0, X_1, \ldots, X_n] \cong (F[X_1, \ldots, X_n])[X_0]$$

This equivalence decomposes a multivariate polynomial into a univariate polynomial (in $X_0$) with multivariate coefficients.

### 4.2 Base Case ($n = 0$)

When $n = 0$, the polynomial $f$ is a nonzero constant. The grid is a singleton. The product $\prod_i (|S_i| - e_i)$ over the empty index set equals 1. The constant evaluates to a nonzero value at the unique grid point, so the nonzero count is 1 ≥ 1.

### 4.3 Inductive Step ($n \to n + 1$)

Let $P = \text{finSuccEquiv}(f) \in (F[X_1, \ldots, X_n])[X_0]$. We establish:

1. **$P \neq 0$** because `finSuccEquiv` is an algebra isomorphism.

2. **$\text{natDegree}(P) \leq e_0$** because every monomial of $f$ has exponent $\leq e_0$ in $X_0$.

3. **The leading coefficient $c = \text{leadingCoeff}(P)$ is nonzero** (by definition of leading coefficient for nonzero polynomials).

4. **$c$ satisfies the inductive hypotheses** on the grid $(S_1, \ldots, S_n)$ with bounds $(e_1, \ldots, e_n)$: every monomial of $c$ has exponent $\leq e_j$ in $X_j$ for $j \geq 1$ (by the `finSuccEquiv_coeff_coeff` lemma).

5. **By induction,** $|\{a \in \text{Grid}(S_1, \ldots, S_n) : c(a) \neq 0\}| \geq \prod_{i=1}^n (|S_i| - e_i)$.

6. **For each base point $a$ with $c(a) \neq 0$:** The mapped polynomial $Q_a = P \text{ evaluated at } a$ is a nonzero univariate polynomial with $\text{natDegree}(Q_a) \leq e_0$. By the univariate root bound, $Q_a$ has $\leq e_0$ roots in $S_0$, hence $\geq |S_0| - e_0$ nonzeros.

7. **Counting:** The nonzero set of $f$ on the full grid contains, for each good base point $a$, at least $|S_0| - e_0$ nonzero fiber points. Since the fibers are disjoint (by the injectivity of `Fin.cons`), the total is:
$$\text{nonzeros} \geq \prod_{i=1}^n (|S_i| - e_i) \cdot (|S_0| - e_0) = \prod_{i=0}^n (|S_i| - e_i).$$

### 4.4 Key Lemmas

The proof chain relies on the following formally verified lemmas:

| Lemma | Statement |
|-------|-----------|
| `finSuccEquiv_ne_zero` | $f \neq 0 \Rightarrow \text{finSuccEquiv}(f) \neq 0$ |
| `finSuccEquiv_natDegree_le` | Support bound on $X_0$ exponents → natDegree bound |
| `finSuccEquiv_coeff_support` | Support of coefficients of $\text{finSuccEquiv}(f)$ ⊆ shifted support of $f$ |
| `finSuccEquiv_leadingCoeff_support_bound` | Leading coefficient inherits exponent bounds from $f$ |
| `map_eval_natDegree_le` | natDegree of mapped polynomial ≤ $e_0$ |
| `Polynomial.card_filter_roots_le` | Number of roots of nonzero polynomial in set ≤ natDegree |
| `Polynomial.card_filter_nonroots_ge` | Number of nonroots ≥ |S| − natDegree |

---

## 5. Applications

### 5.1 Affine Cartesian Codes

**Definition.** The *affine Cartesian code* $\mathcal{C}(S, e)$ is the image of the evaluation map:
$$\text{ev} : \{f : \deg_{X_i}(f) \leq e_i\} \to F^{|\text{Grid}(S)|}, \quad f \mapsto (f(x))_{x \in \text{Grid}(S)}.$$

**Parameters:**
- **Length:** $n = \prod_i |S_i|$
- **Dimension:** $k = \prod_i (e_i + 1)$
- **Minimum distance:** $d \geq \prod_i (|S_i| - e_i)$ (by Theorem 3.2)

**Computational Example (from demo.py):**
- Grid: $\{0,1,2,3\} \times \{0,1,2\}$ over $\text{GF}(5)$
- Degree bounds: $e_x = 2, e_y = 1$
- Length: $n = 12$, Dimension: $k = 6$
- Distance bound: $d \geq (4-2)(3-1) = 4$
- Empirical minimum weight (1000 samples): 4 (bound is tight!)

### 5.2 Polynomial Identity Testing

For testing $f \equiv 0$ by evaluating at random points from $\prod_i S_i$:
$$\Pr[f(x) = 0 \mid f \neq 0] \leq 1 - \prod_i \frac{|S_i| - e_i}{|S_i|}.$$

With non-uniform grids, one can optimize the evaluation domain: use larger sets in coordinates where the degree is highest to maximize the detection probability.

### 5.3 Combinatorial Applications

The Cauchy-Davenport theorem follows: for $A, B \subseteq \mathbb{F}_p$, $|A + B| \geq \min(p, |A| + |B| - 1)$. The proof uses the polynomial $f(x,y) = \prod_{c \in C}(x + y - c)$ on the grid $A \times B$. If $|C| < |A| + |B| - 1$, the polynomial has degree $< |A|$ in $x$ and $< |B|$ in $y$, yet vanishes on $A \times B$, contradicting the Nullstellensatz.

---

## 6. Computational Experiments

### 6.1 Verification of the Bound

We verified the footprint bound computationally on 50 random polynomials over various anisotropic grids in $\text{GF}(101)$. In all cases, the actual nonzero count exceeded the theoretical lower bound, with the ratio (actual/bound) ranging from 1.0 (tight) to over 8.0.

### 6.2 Dimensional Scaling

For the polynomial $f = \sum_{i=1}^n X_i$ (degree 1 per variable) on grids with $|S_i| = 2 + i$:

| $n$ | Grid size | Nonzeros | Bound | Ratio |
|-----|-----------|----------|-------|-------|
| 1   | 3         | 2        | 2     | 1.00  |
| 2   | 12        | 11       | 6     | 1.83  |
| 3   | 60        | 59       | 24    | 2.46  |
| 4   | 360       | 359      | 120   | 2.99  |
| 5   | 2520      | 2519     | 720   | 3.50  |

### 6.3 Code Distance Verification

For the affine Cartesian code on $\{0,1,2,3\} \times \{0,1,2\}$ with $e = (2,1)$ over $\text{GF}(5)$, the theoretical minimum distance bound is $(4-2)(3-1) = 4$. Sampling 1000 random nonzero codewords, the minimum weight found was exactly 4, confirming tightness.

---

## 7. Formalization Details

### 7.1 File Structure

The formalization consists of two files:

- **`FootprintHelpers.lean`** (≈120 lines): Univariate root counting, `finSuccEquiv` properties, and algebraic helper lemmas.
- **`CartesianFootprintBound.lean`** (≈240 lines): Definitions, main theorems, and corollaries.

### 7.2 Proof Statistics

| Result | Lines | Axioms |
|--------|-------|--------|
| `exists_eval_ne_zero` | ~50 | propext, Classical.choice, Quot.sound |
| `footprint_bound` | ~60 | propext, Classical.choice, Quot.sound |
| `footprint_bound_degreeOf` | ~5 | propext, Classical.choice, Quot.sound |
| `uniform_grid_footprint_bound` | ~5 | propext, Classical.choice, Quot.sound |
| All helper lemmas | ~50 | propext, Classical.choice, Quot.sound |

All proofs use only the standard Lean axioms with no additional assumptions.

### 7.3 Key Design Decisions

1. **Support-based reducedness** rather than ideal-theoretic quotients, avoiding heavy algebra infrastructure.
2. **`Fintype.piFinset`** for the grid, giving clean `Finset` operations.
3. **`finSuccEquiv`** for the variable-peeling induction, leveraging Mathlib's existing algebra equivalence.
4. **Explicit exponent bounds** (`e : Fin n → ℕ`) rather than `degreeOf`, with the latter as a corollary.

---

## 8. Discussion and Future Work

### 8.1 Limitations

- The formalization works over arbitrary fields but does not address extensions to commutative rings with zero divisors.
- The interpolation equivalence (bijectivity of the evaluation map on reduced polynomials) is stated but not formally proved in this work.
- The ideal-theoretic viewpoint ($F[X]/\langle g_1, \ldots, g_n \rangle \cong \text{Fun}(\text{Grid}, F)$) is not formalized.

### 8.2 Open Questions

1. Can the bound be improved when $f$ has additional structure (e.g., sparse support)?
2. What is the correct tropical/idempotent analogue of the footprint bound?
3. Can the formalization be extended to multivariate evaluation codes over non-commutative rings?

### 8.3 Impact

This formalization provides:
- A reusable Lean library for polynomial evaluation on finite grids.
- A template for formalizing other Nullstellensatz-type results.
- Infrastructure for future work on evaluation codes and algebraic combinatorics in Lean.

---

## References

1. N. Alon, "Combinatorial Nullstellensatz," *Combin. Probab. Comput.* 8 (1999), 7–29.
2. S. Ball, O. Serra, "Punctured combinatorial Nullstellensätze," *Combinatorica* 29 (2009), 1–14.
3. P. Clark, "The combinatorial Nullstellensätze revisited," *Electron. J. Combin.* 21 (2014), #P4.15.
4. H. López, C. Rentería-Márquez, R. Villarreal, "Affine Cartesian codes," *Des. Codes Cryptogr.* 71 (2014), 5–19.
5. J. Schwartz, "Fast probabilistic algorithms for verification of polynomial identities," *J. ACM* 27 (1980), 701–717.
6. R. Zippel, "Probabilistic algorithms for sparse polynomials," *EUROSAM '79*, LNCS 72, Springer, 1979, 216–226.
7. M. Alon, Z. Füredi, "Covering the cube by affine hyperplanes," *European J. Combin.* 14 (1993), 79–83.
