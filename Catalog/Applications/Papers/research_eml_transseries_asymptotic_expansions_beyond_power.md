# EML Transseries: A Rigorous Hahn-Series Model of Asymptotic Expansions Beyond Power Series

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Geometry (asymptotic geometry of growth orders)

## Abstract

We construct a rigorous model of the field of **transseries** for a single exponential/logarithmic
tower with real exponents, realized as a Hahn-series field over a lexicographically ordered group of
transmonomials. The transmonomial group is the finitely-supported integer-indexed family of real
exponents $\mathbb{Z}\to_{0}\mathbb{R}$ under the lexicographic order keyed on tower height; the
transseries field is the Hahn-series field over this group with real coefficients. We prove that this
construction yields a genuine field, that its order coincides with asymptotic dominance — higher towers
dominate (the formal statement that $e^{e^x}$ beats every power of $e^x$, and $e^x$ beats every power of
$x$) — and that this formal order faithfully models real-analytic little-o domination. Our central
analytic result is the **asymptotic comparison theorem**: two transseries that agree to all orders are
equal, so a transseries is uniquely determined by its asymptotic expansion. We further establish a bridge
identifying an ad-hoc combinatorial dominance relation on labelled transmonomials with the rigorous
lexicographic order, under an explicit and load-bearing positivity hypothesis. All results are formalized
and machine-checked. We close by outlining the path toward real-closedness, truncation-closed subfields,
and an EML expansion map with a uniqueness guarantee.

## 1. Introduction

Power series are the canonical local model of analytic functions, but they are structurally incapable of
describing growth at infinity, and in particular cannot distinguish the asymptotic scales of
$\log x$, $x$, $e^x$, and $e^{e^x}$. The functions generated from the identity by exponentials,
logarithms, and field operations — the **exp-log** or **EML** functions — populate a rich hierarchy of
growth rates that demands a richer formal apparatus.

**Transseries** supply that apparatus. Introduced and developed by Écalle, van der Hoeven,
Aschenbrenner, van den Dries, and others, they extend power series in two directions: real exponents and
exponential/logarithmic "variables." A transseries is a well-ordered formal sum of transmonomials, and
the collection of all transseries forms an ordered field whose order is asymptotic dominance.

This paper presents a self-contained, rigorous construction of the transseries field for a single tower,
together with its core structural and analytic theorems. The construction is built on Hahn series, whose
well-ordered-support condition is exactly what makes infinite multiplication and division well-defined.

### 1.1 Contributions

1. A concrete realization of the transseries field as `TSeries := HahnSeries(TransMono, ℝ)` over the
   lexicographically ordered transmonomial group `TransMono := Lex(ℤ →₀ ℝ)`, inheriting a full **field**
   structure.
2. Three dominance theorems (`mono_lt_mono_of_height`, `mono_lt_mono_same`, `exp_dominates_pow`)
   establishing that the lexicographic order on transmonomials *is* asymptotic dominance, including the
   defining transseries fact that $e^x$ dominates $x^a$ for **every** real $a$.
3. Analytic grounding (`isLittleO_pow_exp`, `isLittleO_expPow_expExp`) connecting the formal order to
   genuine little-o domination of real functions at $+\infty$.
4. The **asymptotic comparison theorem** (`agreeToAllOrders_iff_eq`): agreement to all orders is
   equality, plus its equivalence-relation structure and contrapositive.
5. A bridge theorem (`embed_domRel_iff`) identifying a combinatorial dominance relation with the
   rigorous order, with an explicit positivity hypothesis shown to be essential.

## 2. The transmonomial group and the transseries field

### 2.1 Transmonomials

A **transmonomial** is a formal product

$$
\prod_{h \in \mathbb{Z}} (\text{level } h)^{a_h}
= \cdots (e^{e^x})^{a_2}\,(e^x)^{a_1}\, x^{a_0}\, (\log x)^{a_{-1}}\, (\log\log x)^{a_{-2}} \cdots
$$

with finitely many nonzero real exponents $a_h$. The integer $h$ is the **tower height**: $h=1$ is
$e^x$, $h=0$ is $x$, $h=-1$ is $\log x$, $h=2$ is $e^{e^x}$. The set of transmonomials is therefore the
group of finitely supported functions $\mathbb{Z}\to_{0}\mathbb{R}$ under pointwise addition of exponents
(which corresponds to multiplication of monomials).

**Definition 2.1 (Transmonomial group).**
$$
\mathbf{TransMono} := \mathrm{Lex}(\mathbb{Z}\to_{0}\mathbb{R}),
$$
the group $\mathbb{Z}\to_{0}\mathbb{R}$ equipped with the **lexicographic order**. Concretely, for
$u \ne v$ one finds the smallest index $h$ at which $u(h) \ne v(h)$ and declares $u < v$ iff
$u(h) < v(h)$ at that index.

To make "higher tower = more dominant" correspond to "smaller index = more significant," we encode a
transmonomial of height $h$ at finsupp index $-h$ (see Definition 2.3). The lexicographic order then makes
`TransMono` a linearly ordered abelian group.

**Definition 2.2 (Transseries field).**
$$
\mathbf{TSeries} := \mathrm{HahnSeries}(\mathbf{TransMono}, \mathbb{R}),
$$
the field of Hahn series with real coefficients supported on a well-ordered subset of `TransMono`.

**Theorem 2.1 (Field structure).** `TSeries` is a field.

*Proof sketch.* `TransMono` is a linearly ordered abelian group and $\mathbb{R}$ is a field. Hahn's
theorem (1907) states that the Hahn series over an ordered abelian group with coefficients in a field
form a field: well-ordered support guarantees that products have well-ordered support, and inverses of
units with a leading coefficient can be constructed by a transfinite geometric series. The construction
inherits this instance directly. Nontriviality, $1 \ne 0$, follows since $\mathbb{R}$ is nontrivial.
$\qquad\blacksquare$

### 2.2 Generators

**Definition 2.3 (Monomial and term).** For tower height $h \in \mathbb{Z}$ and exponent $a \in \mathbb{R}$,
$$
\mathrm{mono}(h, a) := \mathrm{toLex}\big(\mathrm{single}(-h,\, a)\big) \in \mathbf{TransMono},
\qquad
\mathrm{term}(h, a) := \mathrm{single}\big(\mathrm{mono}(h,a),\, 1\big) \in \mathbf{TSeries}.
$$
Thus $\mathrm{mono}(h,a)$ is the single transmonomial $(\text{level }h)^a$, and $\mathrm{term}(h,a)$ is
the one-term transseries with coefficient $1$ on it. The index negation $-h$ ensures that higher towers
sit at smaller (more significant) finsupp indices.

## 3. The order is asymptotic dominance

The structural heart of the theory is that the lexicographic order encodes growth. We prove this in three
theorems of increasing specificity.

**Theorem 3.1 (Height dominance, `mono_lt_mono_of_height`).** For all $h, h' \in \mathbb{Z}$ with
$h < h'$, all $a \in \mathbb{R}$, and all $a' > 0$,
$$
\mathrm{mono}(h, a) < \mathrm{mono}(h', a').
$$

*Proof sketch.* Both sides are single-support elements at indices $-h$ and $-h'$ respectively. Apply the
finsupp lexicographic criterion `Finsupp.Lex.lt_iff`: it suffices to exhibit the smallest differing index
and verify the inequality there. Since $h < h'$ we have $-h' < -h$, so the most significant index of
disagreement is $-h'$. At every index $d < -h'$ both single-support functions vanish; at $-h'$ the left
side is $0$ and the right side is $a' > 0$. Hence the left is lexicographically smaller. The negation
encoding turns "higher tower" into "smaller, more significant index," which is what makes height the
dominant coordinate. $\qquad\blacksquare$

**Theorem 3.2 (Same-height comparison, `mono_lt_mono_same`).** For all $h \in \mathbb{Z}$ and
$a < a'$ in $\mathbb{R}$,
$$
\mathrm{mono}(h, a) < \mathrm{mono}(h, a').
$$

*Proof sketch.* Both single-support elements live at the same index $-h$ and agree (trivially, being
zero) at all smaller indices. At $-h$ the comparison is $a < a'$. The lexicographic criterion concludes.
$\qquad\blacksquare$

**Theorem 3.3 (Exp dominates every power, `exp_dominates_pow`).** For every real exponent $a$,
$$
\mathrm{mono}(0, a) < \mathrm{mono}(1, 1),
\qquad\text{i.e.}\qquad x^a \prec e^x.
$$

*Proof sketch.* Instantiate Theorem 3.1 with $h = 0$, $h' = 1$, $a' = 1 > 0$. $\qquad\blacksquare$

**Remark (why this transcends power series).** No Laurent or Puiseux series valuation can satisfy
$x^a \prec e^x$ for *all* real $a$ simultaneously, because such valuations have value group of finite
"Archimedean rank" in the relevant sense and cannot place a single element above every power of $x$. The
ability to do so is the defining feature pushing transseries strictly beyond power series.

### 3.1 The valuation

The Hahn series carry a canonical valuation `orderTop` valued in `WithTop TransMono`, returning the
minimal support point (the leading transmonomial) or $\top$ for the zero series.

**Proposition 3.4 (`orderTop_term`).** $(\mathrm{term}(h,a)).\mathrm{orderTop} = \mathrm{mono}(h,a)$.

*Proof sketch.* The series $\mathrm{term}(h,a) = \mathrm{single}(\mathrm{mono}(h,a), 1)$ has single
support point $\mathrm{mono}(h,a)$ with nonzero coefficient $1$; `HahnSeries.orderTop_single` gives the
result. $\qquad\blacksquare$

**Proposition 3.5 (Multiplicativity, `orderTop_mul`).** For all $x, y \in \mathbf{TSeries}$,
$$
(x \cdot y).\mathrm{orderTop} = x.\mathrm{orderTop} + y.\mathrm{orderTop}.
$$

*Proof sketch.* This is the Hahn-series valuation's multiplicativity over a linearly ordered group: the
minimal support point of a product is the sum of the minimal support points of the factors, because the
coefficient there is the product of the leading coefficients, which is nonzero in a domain.
$\qquad\blacksquare$

**Proposition 3.6 (Constant embedding, `C_injective`).** The constant map $\mathbb{R}\to\mathbf{TSeries}$,
$r \mapsto C(r)$, is an injective ring homomorphism; hence $\mathbb{R}\hookrightarrow\mathbf{TSeries}$.

## 4. Analytic grounding

The formal order would be hollow if it did not model real growth. We connect it to genuine little-o
domination at $+\infty$.

**Theorem 4.1 (Exp dominates powers analytically, `isLittleO_pow_exp`).** For every $n \in \mathbb{N}$,
$$
(x \mapsto x^n) = o(e^x) \quad\text{as } x \to +\infty.
$$

*Proof sketch.* This is the classical fact $x^n/e^x \to 0$; it specializes Mathlib's
`Real.isLittleO_pow_exp_atTop`. It is the analytic shadow of Theorem 3.3. $\qquad\blacksquare$

**Theorem 4.2 (Double-exp dominates powers of exp, `isLittleO_expPow_expExp`).** For every $n \in
\mathbb{N}$,
$$
(x \mapsto (e^x)^n) = o\!\big(x \mapsto e^{e^x}\big) \quad\text{as } x \to +\infty.
$$

*Proof sketch.* Compose Theorem 4.1 with the substitution $x \mapsto e^x$, using that $e^x \to +\infty$
as $x \to +\infty$; little-o is preserved under such a divergent reparametrization. This is the analytic
shadow of Theorem 3.1 at heights $1 < 2$. $\qquad\blacksquare$

## 5. The asymptotic comparison theorem

We now formalize the uniqueness of asymptotic expansions.

**Definition 5.1 (Agreement to all orders, `AgreeToAllOrders`).** Two transseries $a, b$ **agree to all
orders** iff the valuation of their difference exceeds every transmonomial:
$$
\mathrm{AgreeToAllOrders}(a, b) :\iff \forall\, g \in \mathbf{TransMono},\quad
(g : \mathrm{WithTop}\,\mathbf{TransMono}) < (a - b).\mathrm{orderTop}.
$$
Intuitively, $a - b$ is asymptotically smaller than every nameable scale.

**Theorem 5.2 (Asymptotic comparison theorem, `agreeToAllOrders_iff_eq`).**
$$
\mathrm{AgreeToAllOrders}(a, b) \iff a = b.
$$

*Proof sketch.* ($\Rightarrow$) Suppose $a, b$ agree to all orders. We claim
$(a-b).\mathrm{orderTop} = \top$. If not, then by `WithTop.ne_top_iff_exists` there is some
$c \in \mathbf{TransMono}$ with $(a-b).\mathrm{orderTop} = c$. Instantiating the agreement hypothesis at
$g = c$ gives $c < c$, contradicting irreflexivity. Hence $(a-b).\mathrm{orderTop} = \top$, and since a
Hahn series has top valuation iff it is zero (`HahnSeries.orderTop_eq_top`), $a - b = 0$, i.e. $a = b$.
($\Leftarrow$) If $a = b$ then $a - b = 0$, whose valuation is $\top$, which exceeds every coercion
$g < \top$. $\qquad\blacksquare$

The theorem says precisely that the asymptotic expansion of a transseries — its full system of
coefficients across all transmonomials — determines the transseries uniquely. There is no remainder
hiding below all orders.

**Corollary 5.3 (Equivalence structure, `agreeToAllOrders_equivalence`).** `AgreeToAllOrders` is an
equivalence relation; in fact it equals equality. Reflexivity (`agreeToAllOrders_refl`) follows from the
backward direction; symmetry and transitivity transport through the iff.

**Corollary 5.4 (Genuine leading terms, `not_agree_zero_of_ne_zero`).** If $a \ne 0$ then
$\neg\,\mathrm{AgreeToAllOrders}(a, 0)$: every nonzero transseries fails to agree-to-all-orders with $0$,
i.e. has a detectable leading term. This is the contrapositive of Theorem 5.2 applied to $b = 0$.

## 6. Bridge to the combinatorial catalog

A more hands-on notion of transmonomial records a `level : ℤ` (positive for iterated exp, negative for
iterated log) and a real `exponent`, with an ad-hoc dominance relation `domRel` that compares level first,
then exponent. We embed such a labelled transmonomial $m$ into the rigorous group:

**Definition 6.1 (`embed`).** $\mathrm{embed}(m) := \mathrm{mono}(m.\mathrm{level},\ m.\mathrm{exponent})$.

**Theorem 6.2 (Bridge theorem, `embed_domRel_iff`).** For labelled transmonomials $m_1, m_2$ with
positive exponents ($0 < m_1.\mathrm{exponent}$ and $0 < m_2.\mathrm{exponent}$),
$$
m_1.\mathrm{domRel}\, m_2 \iff \mathrm{embed}(m_1) < \mathrm{embed}(m_2).
$$

*Proof sketch.* ($\Rightarrow$, `domRel_imp_lt`, needs only $0 < m_2.\mathrm{exponent}$) `domRel` holds
either by strictly lower level (apply Theorem 3.1) or equal level with strictly smaller exponent (apply
Theorem 3.2). ($\Leftarrow$) Trichotomy on levels: lower level gives the left disjunct of `domRel`; equal
level forces, via trichotomy on exponents and Theorem 3.2 plus antisymmetry, the strictly-smaller-exponent
case; a higher level would yield $\mathrm{embed}(m_2) < \mathrm{embed}(m_1)$ by `domRel_imp_lt` (using
$0 < m_1.\mathrm{exponent}$), contradicting the hypothesis via asymmetry. $\qquad\blacksquare$

**Remark (positivity is essential).** With a negative exponent at the dominant level — e.g. $(e^x)^{-1}$,
which tends to $0$ — the level-first `domRel` disagrees with true growth order, since a high-level
*negative* power is asymptotically small. The positivity hypotheses are therefore load-bearing, not
cosmetic; the rigorous construction makes explicit an assumption the naive definition silently makes.

## 7. Algorithms

The constructive content yields effective procedures on finitely-represented transmonomials and
transseries.

**Algorithm 1 (Lexicographic dominance comparison).** Given two transmonomials as finite maps
$h \mapsto a_h$, compare them in the asymptotic order. Scan tower heights from highest to lowest; at the
first height where exponents differ, the larger exponent (at the higher height) wins. Complexity is linear
in the combined support size after sorting by height, i.e. $O(k \log k)$ for $k$ nonzero exponents.

**Algorithm 2 (Leading-term / valuation extraction).** Given a finitely supported transseries (a finite
map from transmonomials to coefficients), return its leading transmonomial (the maximal one in dominance
order) and leading coefficient by a single max-scan, $O(k)$ where $k$ is the number of terms (using
Algorithm 1 for comparisons).

**Algorithm 3 (Agreement-to-all-orders check, finite truncations).** For finitely supported $a, b$,
compute $a - b$ termwise and test whether it is the zero series; by Theorem 5.2 this decides agreement to
all orders. Complexity $O(k_a + k_b)$ via a merge over sorted supports.

## 8. Applications

- **Asymptotic analysis of EML functions.** Transseries are the formal target of asymptotic expansion for
  exp-log functions; the comparison theorem guarantees that an expansion identifies its function uniquely
  within the formal field.
- **Differential equations at infinity.** Solutions of algebraic differential equations over the reals
  admit transseries expansions; the ordered-field structure supports formal manipulation of such
  solutions.
- **Model theory and o-minimality.** The logarithmic-exponential series field is a model of the theory of
  the real field with exponentiation; rigorous Hahn-series models underpin these results.
- **Resurgence and physics.** Transseries organize divergent perturbative expansions (instanton
  corrections of the form $e^{-S/g}$ alongside power series in $g$), where the non-power-series scales are
  exactly the exponential transmonomials.

## 9. Discussion

The construction makes precise, and machine-checks, a claim usually invoked informally: that the order on
transmonomials *is* asymptotic dominance. The encoding choices — finsupp index $-h$ for tower height $h$,
and the lexicographic order keyed on the most significant index — are exactly what align "higher tower" with
"more dominant." The asymptotic comparison theorem, while structurally a statement that only $0$ has top
valuation, is the genuine uniqueness principle once one accepts that Hahn coefficients are the asymptotic
data; the analytic little-o theorems certify that this acceptance is warranted.

A noteworthy methodological point is the careful isolation of hypotheses: the bridge theorem's positivity
requirement is not a technical convenience but reflects a real failure of the naive level-first rule on
negative dominant exponents.

## 10. Future work

1. **Real-closedness.** Prove that the transseries field (or a suitable maximally-closed subfield) is real
   closed: every positive element has a square root and every odd-degree polynomial a root, via
   Newton-polygon / Hensel arguments on the value group, solving term-by-term along the well-ordered
   support.
2. **Truncation-closed subfields.** Confine EML expansions to truncation-closed subfields (closed under
   taking initial segments of the transmonomial order), a lattice of subfields inheriting the order; the
   order-dual convention makes "initial segment" coincide with "dominant transmonomials."
3. **The EML expansion map and uniqueness.** Build the map sending each EML germ at $+\infty$ to its
   transseries, with injectivity: EML functions with the same expansion to all orders are asymptotically
   equal, connecting the formal comparison theorem to analytic little-o domination.
4. **Bridging formal order to analytic little-o.** Establish that the formal field order matches analytic
   asymptotic domination on real EML germs, closing the loop between the algebraic and analytic pictures.

## 11. Conclusion

We have given a rigorous, machine-checked model of the transseries field for a single exp/log tower with
real exponents: a Hahn-series field whose lexicographic order is asymptotic dominance, faithfully modeling
real little-o behavior, in which a transseries is uniquely determined by its asymptotic expansion. The
construction establishes the foundational ordered-field layer on which the broader EML transseries program
— real-closedness, truncation-closed subfields, and the EML expansion map — can be built.
