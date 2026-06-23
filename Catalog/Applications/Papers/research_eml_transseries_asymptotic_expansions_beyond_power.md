# EML Transseries: A Hahn-Series Field Model and the Asymptotic Comparison Theorem

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Applications (Asymptotic Analysis / Ordered Algebra)

---

## Abstract

Transseries extend classical power series by admitting iterated exponentials and logarithms as building blocks, providing a closed asymptotic language for the growth of exp-log-monomial (EML) functions at $+\infty$. We construct the field of transseries concretely as a Hahn series field $\mathrm{TSeries} = \mathbb{H}\big(\mathrm{Lex}(\mathbb{Z} \to_{0} \mathbb{R}),\, \mathbb{R}\big)$, whose value group of *transmonomials* is the lexicographically ordered group of finitely supported maps from integer **heights** (the number of iterated exponentials, negative for logarithms) to real **exponents**. The Hahn construction endows this object with a complete field structure together with a valuation $\mathrm{orderTop}$ valued in $\mathrm{WithTop}(\mathrm{TransMono})$, the leading transmonomial of a series. Our central result is the **asymptotic comparison theorem**: two transseries that *agree to all orders* — meaning the valuation of their difference exceeds every transmonomial — are necessarily equal, and conversely. This is the uniqueness principle that distinguishes transseries from ordinary asymptotic expansions of real functions, which are not determined by their expansions (witness $e^{-1/x^2}$). We show the agreement relation is an equivalence relation coinciding with equality, derive the contrapositive that no nonzero series agrees to all orders with $0$, and anchor the abstract height order to real analysis via two dominance facts: $x^n = o(e^x)$ and $(e^x)^n = o(e^{e^x})$ as $x \to +\infty$. Finally, we build a bridge between this principled field model and a combinatorial "level-then-exponent" dominance relation used in catalog formalizations, proving the two orders coincide precisely on positive-exponent monomials and exhibiting the negative-exponent regime where the naive relation fails. All results have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Asymptotic analysis asks how quantities behave in a limit, and its answers are *rates of growth* rather than numbers. The classical instrument, the power series $\sum_n a_n x^n$, is incapable of representing transcendental growth: $e^x$ requires infinitely many powers and $e^{e^x}$ is outright unreachable. Yet such towers of exponentials and logarithms saturate combinatorics (set partitions grow like $e^{e^x}$), the analysis of algorithms, statistical mechanics, and the asymptotics of solutions to differential equations.

**Transseries** are the closure of formal power series under the operations that generate these objects: exponentiation, taking logarithms, and infinite (well-ordered) summation. They form a field in which every elementary growth rate has a canonical normal form, an exact arithmetic, and — the property we focus on here — a *uniqueness* guarantee: a transseries is determined by its asymptotic expansion to all orders. This article gives a self-contained account of a concrete Hahn-series realization of transseries and a complete proof of the asymptotic comparison theorem that expresses this uniqueness.

### 1.2 Contributions

1. A concrete field model of transseries as a Hahn series field over a lexicographically ordered group of transmonomials (Section 3).
2. The **asymptotic comparison theorem** (Theorem 5.2): agreeing to all orders is equivalent to equality.
3. Structural corollaries: the agreement relation is an equivalence relation (Theorem 5.4), and no nonzero series agrees to all orders with $0$ (Proposition 5.5).
4. Analytic grounding of the formal height order via two little-$o$ dominance results (Section 6).
5. A bridge theorem identifying a combinatorial dominance relation with the field's lexicographic order on positive-exponent monomials, together with a sharp delineation of where the identification fails (Section 7).

### 1.3 Relation to ordinary asymptotic expansions

The motivating contrast is **non-uniqueness for real functions**. The function

$$\phi(x) = \begin{cases} e^{-1/x^2}, & x \neq 0, \\ 0, & x = 0, \end{cases}$$

is smooth and is $o(x^n)$ near $0$ for every $n$, so its Taylor series at $0$ is identically zero — the *same* expansion as the zero function, although $\phi \neq 0$. Real asymptotic expansions thus fail to determine the function. The asymptotic comparison theorem says transseries suffer no such defect: distinct transseries always diverge at some finite, nameable order. This is the precise sense in which, for transseries, *the expansion is the object.*

---

## 2. Preliminaries: Hahn series and valuations

We recall the ambient algebraic framework.

**Definition 2.1 (Hahn series).** Let $(\Gamma, +, <)$ be a linearly ordered abelian group and $R$ a ring. A *Hahn series* over $\Gamma$ with coefficients in $R$ is a function $f : \Gamma \to R$ whose support $\mathrm{supp}(f) = \{ g \in \Gamma : f(g) \neq 0 \}$ is **well-ordered** in $\Gamma$. The set of all such series is denoted $\mathbb{H}(\Gamma, R)$. Addition is pointwise; multiplication is the convolution

$$(fg)(\gamma) = \sum_{\alpha + \beta = \gamma} f(\alpha)\, g(\beta),$$

which is well-defined because the well-ordering of supports makes each such sum finite.

**Fact 2.2.** If $R$ is a field and $\Gamma$ is a linearly ordered abelian group, then $\mathbb{H}(\Gamma, R)$ is a field. Inverses are computed by a formally convergent geometric expansion controlled by the well-ordering.

**Definition 2.3 (Order valuation).** For $f \in \mathbb{H}(\Gamma, R)$, the *order* (or top-valuation) is

$$\mathrm{orderTop}(f) = \begin{cases} \min \mathrm{supp}(f) \in \Gamma, & f \neq 0, \\ \top, & f = 0, \end{cases}$$

valued in $\mathrm{WithTop}(\Gamma) = \Gamma \cup \{\top\}$, where $\top$ is a maximal element strictly above every $g \in \Gamma$. The minimum exists because the support is well-ordered. By convention here, a *smaller* element of $\Gamma$ corresponds to a *more dominant* growth rate, so $\mathrm{orderTop}(f)$ records the leading transmonomial of $f$.

**Fact 2.4 (Valuation laws).** The order valuation satisfies:
- $\mathrm{orderTop}(f) = \top \iff f = 0$;
- $\mathrm{orderTop}(fg) = \mathrm{orderTop}(f) + \mathrm{orderTop}(g)$ (additivity of leading exponents under multiplication);
- $\mathrm{orderTop}(f + g) \ge \min(\mathrm{orderTop}(f), \mathrm{orderTop}(g))$.

The first law is the cornerstone of the comparison theorem; the others power division and root extraction.

---

## 3. The transmonomial group and the transseries field

### 3.1 Heights and exponents

The elementary growth rates are organized by an integer **height** counting iterated exponentials:

$$\dots,\ \log\log x\ (h=-2),\ \log x\ (h=-1),\ x\ (h=0),\ e^x\ (h=1),\ e^{e^x}\ (h=2),\ \dots$$

**Definition 3.1 (Transmonomial group).** A *transmonomial* is a finitely supported function from heights to real exponents:

$$\mathrm{TransMono} = \mathrm{Lex}\big(\mathbb{Z} \to_{0} \mathbb{R}\big) = \{\, m : \mathbb{Z} \to \mathbb{R} \mid m(h) \neq 0 \text{ for finitely many } h \,\},$$

made into an abelian group under pointwise addition of exponents (corresponding to multiplication of monomials), and ordered **lexicographically by height from the top down**: for $m \neq m'$, let $h^\star$ be the largest height at which they differ; then $m < m'$ iff $m(h^\star) < m'(h^\star)$ in the convention that places the larger object first, or equivalently $m > m'$ records that $m$ has the larger dominant exponent. Concretely, the tallest tower wins, and within a tier the larger exponent wins.

We write $\mathrm{mono}(h, a) \in \mathrm{TransMono}$ for the *pure transmonomial* assigning exponent $a$ to height $h$ and $0$ elsewhere; it represents the growth rate $\big(\exp^{\circ h}(x)\big)^a$ for $h \ge 0$ (and the analogous iterated-logarithm rate for $h < 0$). Thus $\mathrm{mono}(0, \alpha) = x^\alpha$, $\mathrm{mono}(1, \beta) = e^{\beta x}$, $\mathrm{mono}(2, 1) = e^{e^x}$.

**Lemma 3.2 (Lexicographic comparison).** For pure transmonomials of distinct heights $h_1 < h_2$ with nonzero exponents, $\mathrm{mono}(h_1, a) < \mathrm{mono}(h_2, b)$ whenever $b > 0$: the taller tower dominates regardless of the lower exponent. For equal heights, $\mathrm{mono}(h, a) < \mathrm{mono}(h, b) \iff a < b$.

This is exactly the order on which the entire growth hierarchy rests, and it follows from the lexicographic comparison `Finsupp.Lex.lt_iff` on finitely supported maps.

### 3.2 The field of transseries

**Definition 3.3 (Transseries).** The field of transseries is the Hahn series field over the transmonomial group with real coefficients:

$$\mathrm{TSeries} = \mathbb{H}\big(\mathrm{TransMono},\, \mathbb{R}\big).$$

An element is a formal sum $\sum_m c_m \cdot m$ with $c_m \in \mathbb{R}$ and well-ordered support. By Fact 2.2, $\mathrm{TSeries}$ is a field: transseries can be added, multiplied, and divided, with all field axioms holding exactly. The order valuation $\mathrm{orderTop} : \mathrm{TSeries} \to \mathrm{WithTop}(\mathrm{TransMono})$ returns the leading (most dominant) transmonomial of a nonzero series and $\top$ for $0$.

**Remark 3.4 (Formal dominance facts).** The field model records two formal dominance facts that mirror the analytic ones of Section 6: a formal statement that the height-$1$ generator dominates every real power of the height-$0$ generator (`exp_dominates_pow`), and that height-$1$ generators are dominated by height-$2$ generators (`mono_lt_mono_of_height`). These are order facts in $\mathrm{TransMono}$, instances of Lemma 3.2.

---

## 4. Agreeing to all orders

We now formalize the asymptotic-agreement relation that the comparison theorem characterizes.

**Definition 4.1 (Agreement to all orders).** Two transseries $a, b \in \mathrm{TSeries}$ *agree to all orders*, written $\mathrm{AgreeToAllOrders}(a, b)$, when the valuation of their difference exceeds every transmonomial:

$$\mathrm{AgreeToAllOrders}(a, b) \;:\equiv\; \forall\, g \in \mathrm{TransMono},\quad (g : \mathrm{WithTop}\,\mathrm{TransMono}) < \mathrm{orderTop}(a - b).$$

Interpreted asymptotically: $a - b$ is smaller than *every* named growth rate — smaller than $x^{-N}$ for all $N$, smaller than $e^{-x}$, smaller than $e^{-e^x}$, and so on without bound. The quantifier ranges over the entire (uncountable) transmonomial group; no finite leading rate is permitted to the difference.

---

## 5. The Asymptotic Comparison Theorem

### 5.1 Statement and proof

**Lemma 5.1.** For $f \in \mathrm{TSeries}$, $\mathrm{orderTop}(f) = \top \iff f = 0$. *(This is the first valuation law, Fact 2.4.)*

**Theorem 5.2 (Asymptotic comparison theorem).** For all $a, b \in \mathrm{TSeries}$,

$$\mathrm{AgreeToAllOrders}(a, b) \iff a = b.$$

*Proof.*

($\Rightarrow$) Assume $a$ and $b$ agree to all orders. We claim $\mathrm{orderTop}(a - b) = \top$. Suppose not; then $\mathrm{orderTop}(a-b)$ is a finite value, so there exists $c \in \mathrm{TransMono}$ with $\mathrm{orderTop}(a - b) = (c : \mathrm{WithTop}\,\mathrm{TransMono})$. Instantiating the agreement hypothesis at $g = c$ gives $(c) < \mathrm{orderTop}(a-b) = (c)$, contradicting irreflexivity of $<$. Hence $\mathrm{orderTop}(a - b) = \top$, and by Lemma 5.1, $a - b = 0$, i.e. $a = b$.

($\Leftarrow$) If $a = b$, then $a - b = 0$, so $\mathrm{orderTop}(a-b) = \top$, which is strictly greater than $(g)$ for every $g \in \mathrm{TransMono}$ since $\top$ is maximal. Thus $a$ and $b$ agree to all orders. $\qquad\blacksquare$

**Discussion.** The proof is short but not vacuous. The forward direction must *eliminate every possible finite leading rate*; this is the role of the `by_contra` step combined with the case analysis on $\mathrm{WithTop}$ (`WithTop.ne_top_iff_exists`). The mathematical weight lives entirely in the order structure of $\mathrm{TransMono}$ and in Lemma 5.1, which encode that the leading transmonomial is a faithful measure of asymptotic size. Once those are in place, uniqueness is the clean consequence — a hallmark of a well-chosen formalism.

### 5.2 Structural corollaries

**Corollary 5.3 (Reflexivity).** $\mathrm{AgreeToAllOrders}(a, a)$ holds for all $a$. *(Immediate from Theorem 5.2 with $a = b$.)*

**Theorem 5.4 (Equivalence relation).** $\mathrm{AgreeToAllOrders}$ is an equivalence relation on $\mathrm{TSeries}$.

*Proof.* By Theorem 5.2 the relation coincides extensionally with equality, which is reflexive, symmetric, and transitive; each property transfers through the biconditional. $\qquad\blacksquare$

**Proposition 5.5 (No nonzero series is asymptotically negligible).** If $a \neq 0$ then $\neg\,\mathrm{AgreeToAllOrders}(a, 0)$.

*Proof (contrapositive of Theorem 5.2).* If $\mathrm{AgreeToAllOrders}(a, 0)$ held, then $a = 0$ by Theorem 5.2, contradicting $a \neq 0$. $\qquad\blacksquare$

Proposition 5.5 is the assertion that **every nonzero transseries has a genuine leading term**: a definite dominant growth rate that no cancellation can hide below all orders. This is exactly the property that fails for ordinary asymptotic expansions (cf. $e^{-1/x^2}$ in Section 1.3).

---

## 6. Analytic grounding of the height order

The formal height order is not a free-floating abstraction; it is the bookkeeping of genuine limiting behavior. Two little-$o$ statements anchor it.

**Theorem 6.1 (Exponential dominates powers).** For every $n \in \mathbb{N}$,

$$x^{n} = o\big(e^{x}\big) \quad \text{as } x \to +\infty, \qquad \text{i.e.}\quad \lim_{x \to +\infty} \frac{x^n}{e^x} = 0.$$

This is the analytic content modeled by the formal dominance of height $1$ over height $0$.

**Theorem 6.2 (Double exponential dominates powers of the exponential).** For every $n \in \mathbb{N}$,

$$\big(e^{x}\big)^{n} = o\big(e^{e^{x}}\big) \quad \text{as } x \to +\infty.$$

*Proof sketch.* Apply Theorem 6.1 in the variable $u = e^x$: $u^n = o(e^u)$ as $u \to +\infty$. Compose with the fact that $e^x \to +\infty$ as $x \to +\infty$ (so the limit may be pulled back along $x \mapsto e^x$), yielding $(e^x)^n = o(e^{e^x})$. Formally this is `(Real.isLittleO_pow_exp_atTop).comp_tendsto Real.tendsto_exp_atTop`. $\qquad\blacksquare$

Theorem 6.2 certifies that height $2$ truly dominates height $1$, validating Lemma 3.2 against analysis. By iterating the substitution, the entire ladder of heights is seen to be a faithful encoding of real growth.

---

## 7. A bridge to combinatorial dominance

Informal and catalog-style treatments of transseries often use a *labelled* transmonomial — a pair $(\text{level} \in \mathbb{Z},\ \text{exponent} \in \mathbb{R})$ — together with a hand-built dominance relation.

**Definition 7.1 (Catalog transmonomial and dominance).** A *catalog transmonomial* is a record with fields $\mathrm{level} \in \mathbb{Z}$ and $\mathrm{exponent} \in \mathbb{R}$. The combinatorial dominance relation is

$$\mathrm{domRel}(m_1, m_2) \;:\equiv\; m_1.\mathrm{level} < m_2.\mathrm{level} \ \lor\ \big(m_1.\mathrm{level} = m_2.\mathrm{level} \ \land\ m_1.\mathrm{exponent} < m_2.\mathrm{exponent}\big).$$

In words: compare levels first; break ties by exponent.

**Definition 7.2 (Embedding).** Embed a catalog transmonomial into the field's transmonomial group by

$$\mathrm{embed}(m) = \mathrm{mono}(m.\mathrm{level},\, m.\mathrm{exponent}) \in \mathrm{TransMono}.$$

**Theorem 7.3 (Bridge on positive monomials).** For catalog transmonomials whose dominant exponents are positive, $\mathrm{domRel}$ coincides with the lexicographic order of the transmonomial group:

$$\mathrm{domRel}(m_1, m_2) \iff \mathrm{embed}(m_1) < \mathrm{embed}(m_2),$$

under the positivity hypothesis on the relevant exponent. *(Lean: `embed_domRel_iff`.)*

**Proposition 7.4 (Easy direction).** Without any positivity hypothesis on the larger monomial, $\mathrm{domRel}(m_1, m_2)$ still implies $\mathrm{embed}(m_1) < \mathrm{embed}(m_2)$ in the cases where level strictly increases or exponents compare within a level. *(Lean: `domRel_imp_lt`.)*

**Remark 7.5 (Why positivity is load-bearing).** The full equivalence *fails* for negative dominant exponents. Consider $(e^x)^{-1} = e^{-x}$, the catalog transmonomial of level $1$, exponent $-1$. The level-first $\mathrm{domRel}$ would rank it above every power of $x$ (because its level $1$ exceeds level $0$), yet $e^{-x}$ *decays* and is dominated by, e.g., $x^{1} = x$. The genuine growth order disagrees with $\mathrm{domRel}$ precisely because a negative exponent reverses the direction of growth at its level. The positivity condition in Theorem 7.3 marks exactly the boundary where the naive combinatorial rule is correct, exposing a subtlety that the informal definition silently assumes away.

---

## 8. Algorithms

Although transseries are defined by an infinite (well-ordered) support, all of their structural operations are computable order-by-order on finite truncations. We record the two algorithms underlying the results.

### 8.1 Transmonomial comparison

The lexicographic comparison of two transmonomials is decided by scanning their (finite) supports from the highest height downward.

**Algorithm `compare_transmonomials`.** Given $m_1, m_2 : \mathbb{Z} \to_0 \mathbb{R}$, return the order relation between them.

```
compare_transmonomials(m1, m2):
    H ← sort(support(m1) ∪ support(m2)) in DECREASING order of height
    for h in H:
        e1 ← m1[h] (default 0); e2 ← m2[h] (default 0)
        if e1 < e2: return LT       # m2 dominates at the highest differing height
        if e1 > e2: return GT
    return EQ                        # identical on all heights
```

Complexity: $O(k \log k)$ for $k = |\mathrm{supp}(m_1)| + |\mathrm{supp}(m_2)|$, dominated by sorting the union of heights.

### 8.2 Order-by-order agreement test

To test $\mathrm{AgreeToAllOrders}(a, b)$ for transseries available as truncations up to a cutoff height $G$, one checks that the leading transmonomial of $a - b$ exceeds every transmonomial up to $G$; the theorem guarantees that as $G \to \infty$ this stabilizes to the equality test.

```
agree_to_order(a, b, G):
    d ← a - b                       # subtract coefficient-wise, regroup by monomial
    if d == 0: return AGREE
    m* ← leading_transmonomial(d)   # orderTop(d): the dominant surviving monomial
    return (m* dominates every monomial of height ≤ G)
```

By Theorem 5.2, $a = b$ iff `agree_to_order(a, b, G)` returns AGREE for every $G$; on any finite data this reduces to the single test `d == 0`.

---

## 9. Applications

- **Exact asymptotics for differential equations.** Solving an ODE term-by-term in transseries yields a formal solution; Theorem 5.2 guarantees two formal solutions agreeing to all orders are identical, removing ambiguity from the construction.
- **Resurgence and exponential asymptotics.** Transseries are the native language of resurgence theory, where exponentially small terms ($e^{-S/\hbar}$) beyond all orders of a divergent power series carry physical content. The comparison theorem formalizes the sense in which such terms are *not* invisible: they live at a finite order in the transmonomial hierarchy.
- **Model theory of $o$-minimal structures.** The field of transseries (in its full Hardy-field-completed form) serves as a universal model for the asymptotic behavior of a broad class of definable functions; uniqueness of expansion is a prerequisite for such universality statements.
- **Algorithmic asymptotics.** The comparison and agreement algorithms (Section 8) underpin computer-algebra routines that decide equality and dominance of EML functions by manipulating finite truncations.

---

## 10. Discussion and Future Directions

The asymptotic comparison theorem is "true but shallow" *inside* the Hahn model — yet it is precisely the content of the classical comparison theorem once one accepts that Hahn coefficients are the asymptotic data. The genuine mathematical depth resides in the *order structure* of $\mathrm{TransMono}$ that makes $\mathrm{orderTop}$ capture asymptotic size; the comparison theorem is the clean corollary. Three directions extend the present work.

**Conjecture 1 — The transseries field is real closed.** The ordered field $\mathbb{H}(\mathrm{Lex}(\mathbb{Z} \to_0 \mathbb{R}), \mathbb{R})$, with the order induced by leading coefficient, admits square roots of all positive elements and roots of all odd-degree polynomials, hence is real closed. The key insight: root-finding in a Hahn-series field is governed by the *Newton polygon* of the polynomial over the valuation, so existence of roots reduces to solvability of the leading-coefficient equation in $\mathbb{R}$ (already real closed) plus a contraction/fixpoint iteration on the residual. *Why now?* The valuation is multiplicative and $\mathrm{orderTop}(x) = \top \iff x = 0$ — exactly the two facts a Newton-polygon argument needs to control leading terms.

**Conjecture 2 — Asymptotic comparison upgrades to a valuation isometry.** The map sending a nonzero transseries to its leading data, $x \mapsto (\mathrm{orderTop}(x),\ \mathrm{leadingCoeff}(x))$, is a surjective valuation onto $\mathrm{TransMono} \times \mathbb{R}^\times$ whose kernel-of-difference characterizes equality; i.e. two transseries are equal iff all truncations $\{m : m \le g\}$ agree for every $g$. The comparison theorem is then the $g \to \infty$ colimit of decidable truncated equalities.

**Conjecture 3 — Exp/log shift is an order automorphism.** The height shift $\mathrm{mono}(h, a) \mapsto \mathrm{mono}(h+1, a)$ extends to a strictly order-preserving group automorphism of $\mathrm{TransMono}$, and conjugating the Hahn construction by it models the substitution $x \mapsto e^x$ on transseries.

A further structural goal is a *full* transseries field closed under composition and derivation, which requires an infinite-rank value group (a transfinite tower) beyond the single-tower $\mathbb{Z} \to_0 \mathbb{R}$ model used here.

---

## 11. Conclusion

We have presented a concrete Hahn-series field model of EML transseries, organized by an integer height hierarchy of iterated exponentials and logarithms and ordered lexicographically. Within it, the asymptotic comparison theorem establishes that a transseries is uniquely determined by its expansion to all orders — the uniqueness principle that ordinary real asymptotic expansions lack. The result rests on two valuation laws (multiplicativity and $\mathrm{orderTop} = \top \iff 0$), is anchored to real analysis by exponential-dominance limits, and connects faithfully to combinatorial dominance on the positive-exponent regime. Together these results turn asymptotic reasoning about EML functions into exact algebra.

---

## Summary of formal results

| Name | Statement |
|------|-----------|
| `AgreeToAllOrders` | $\forall g,\ (g) < \mathrm{orderTop}(a-b)$ |
| `agreeToAllOrders_iff_eq` | $\mathrm{AgreeToAllOrders}(a,b) \iff a = b$ |
| `agreeToAllOrders_refl` | $\mathrm{AgreeToAllOrders}(a,a)$ |
| `agreeToAllOrders_equivalence` | $\mathrm{AgreeToAllOrders}$ is an equivalence relation |
| `not_agree_zero_of_ne_zero` | $a \neq 0 \Rightarrow \neg\,\mathrm{AgreeToAllOrders}(a,0)$ |
| `isLittleO_pow_exp` | $x^n = o(e^x)$ at $+\infty$ |
| `isLittleO_expPow_expExp` | $(e^x)^n = o(e^{e^x})$ at $+\infty$ |
| `embed` | $\mathrm{embed}(m) = \mathrm{mono}(m.\mathrm{level}, m.\mathrm{exponent})$ |
| `embed_domRel_iff` | $\mathrm{domRel} \iff \text{lex order}$ on positive monomials |
| `domRel_imp_lt` | $\mathrm{domRel}(m_1,m_2) \Rightarrow \mathrm{embed}(m_1) < \mathrm{embed}(m_2)$ |
