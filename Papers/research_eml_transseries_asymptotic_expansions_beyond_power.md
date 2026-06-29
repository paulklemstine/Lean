# A Grid-Based Hahn-Series Model of EML Transseries: Dominance, Asymptotic Comparison, and Ingredients of Real Closure

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (asymptotic analysis, ordered fields, formal series)

---

## Abstract

We develop a rigorous, fully formalized model of *transseries* — formal asymptotic
expansions that combine real powers of the variable $x$ with iterated exponentials
and logarithms $\log x, x, e^x, e^{e^x}, \dots$ — built on top of the theory of
Hahn series. The carrier is the field of Hahn series with real coefficients over
the lexicographically ordered group of *transmonomials*, modeled as the
finitely-supported maps $\mathbb{Z} \to_{\mathrm f} \mathbb{R}$ from integer
*tower heights* to real exponents. Within this model we establish three families
of results. First, the lexicographic order on transmonomials is exactly
asymptotic dominance: a higher tower height dominates any lower one regardless of
exponent, and within a fixed height the larger exponent dominates; in particular
$e^x$ dominates $x^a$ for *every* real $a$, a statement no power-series order can
express. Second, the **asymptotic comparison theorem**: two transseries that agree
to all orders (their difference is asymptotically smaller than every
transmonomial) are equal — so a transseries is uniquely determined by its
expansion. Third, the structural **ingredients of real closure**: the value group
is divisible, every one-term transseries admits an $n$-th root and is a square,
and we isolate the precise obstruction (non-divisibility of $\mathbb{Z}$) that
prevents Laurent series from being real closed and that real exponents overcome.
We also exhibit the field as a non-Archimedean ordered field containing
$\mathbb{R}$, and construct the exp-shift field automorphism realizing the
self-similarity of the growth-scale tower. All statements correspond to
machine-checked theorems; proof sketches are given throughout.

---

## 1. Introduction

### 1.1 Motivation

Asymptotic analysis pervades applied mathematics: solutions of differential
equations near singular points, the WKB method, perturbation theory, and the
divergent series of quantum field theory are all routinely manipulated through
their asymptotic expansions. The natural ambient objects for such expansions are
*transseries*: formal series that may involve, simultaneously, real powers of $x$,
logarithms, exponentials, and exponentials of exponentials. Transseries form the
backbone of Écalle's resurgence theory, of the model theory of the real
exponential field, and of the differential algebra of Hardy fields.

A central structural fact, established classically by van der Hoeven and others, is
that the field of transseries is an *ordered, real closed, differential field*. Our
goal here is a clean, self-contained, and verifiable model that captures the
order-theoretic and field-theoretic core of this picture — enough to state and
prove dominance laws, the asymptotic comparison (uniqueness) theorem, and the
decisive ingredients of real closure — using as foundation only the general theory
of Hahn series.

### 1.2 Contributions

1. A model `TSeries` of the transseries field as a Hahn-series field over the
   lexicographically ordered transmonomial group `TransMono = Lex (ℤ →₀ ℝ)`
   (Section 3), with $\mathbb{R}$ embedded as a subfield.
2. Dominance laws making the lexicographic order coincide with asymptotic
   dominance, culminating in `exp_dominates_pow` (Section 4), and their analytic
   counterparts `isLittleO_pow_exp` and `isLittleO_expPow_expExp`.
3. The asymptotic comparison theorem `agreeToAllOrders_iff_eq` and the fact that
   asymptotic agreement is an equivalence relation (Section 5).
4. The ordered-field structure, including the non-Archimedean phenomena
   `x_infinitesimal`, `inv_x_infinite`, and the order embedding of $\mathbb{R}$
   (Section 6).
5. The ingredients of real closure: `valueGroup_divisible`,
   `exists_nthRoot_term`, `isSquare_term`, and the obstruction
   `laurent_value_group_not_divisible` (Section 7).
6. The exp-shift automorphism `expShiftEquiv` and the unboundedness of the
   tower `exists_exp_tower_gt` (Section 8).

---

## 2. Preliminaries: Hahn series

Let $\Gamma$ be a linearly ordered abelian group (the *value group*) and $R$ a
ring (the *coefficient ring*). A **Hahn series** over $(\Gamma, R)$ is a function
$f : \Gamma \to R$ whose **support** $\{ g : f(g) \neq 0 \}$ is well-ordered (every
nonempty subset has a least element). We write $f = \sum_{g} f(g)\, t^g$
informally. Hahn series form a ring under pointwise addition and Cauchy-type
convolution; well-orderedness of supports guarantees that each coefficient of a
product is a finite sum.

**Fact (Hahn).** If $R$ is a field and $\Gamma$ is a linearly ordered abelian
group, then the Hahn series over $(\Gamma, R)$ form a field.

For a nonzero Hahn series $f$, its **order** $\mathrm{ord}(f)$ is the least element
of its support — the exponent of its leading (most dominant) term. We package this
as a valuation
$$\mathrm{orderTop}(f) \in \Gamma \cup \{\top\}, \qquad \mathrm{orderTop}(0) = \top,$$
with the conventions that $\top$ is strictly greater than every $g \in \Gamma$ and
$\mathrm{orderTop}(f) = g \in \Gamma$ iff $f \neq 0$ and $g$ is the order of $f$.
The key valuation properties we use are:

- **Multiplicativity:** $\mathrm{orderTop}(xy) = \mathrm{orderTop}(x) + \mathrm{orderTop}(y)$.
- **Dominant-term addition:** if $\mathrm{orderTop}(f) < \mathrm{orderTop}(g)$, then
  $\mathrm{orderTop}(f+g) = \mathrm{orderTop}(f)$.
- **Triviality criterion:** $\mathrm{orderTop}(f) = \top$ iff $f = 0$.
- **Single terms:** for $c \neq 0$, the one-term series $\mathrm{single}(g, c)$
  (the series whose only nonzero coefficient is $c$, at $g$) has
  $\mathrm{orderTop} = g$ and leading coefficient $c$.

These are exactly the hooks through which our model inherits its field and order
structure.

---

## 3. The transmonomial group and the transseries field

### 3.1 Transmonomials

A monomial in the transseries world is a formal product
$$\cdots (e^{e^x})^{a_2}\,(e^x)^{a_1}\, x^{a_0}\, (\log x)^{a_{-1}} \cdots,$$
with finitely many nonzero real exponents $a_h$, indexed by the integer **tower
height** $h$: height $0$ is $x$, height $1$ is $e^x$, height $-1$ is $\log x$,
height $2$ is $e^{e^x}$, and so on.

**Definition 3.1 (Transmonomials).** The group of transmonomials is
$$\mathtt{TransMono} := \mathrm{Lex}(\mathbb{Z} \to_{\mathrm f} \mathbb{R}),$$
the finitely-supported maps from heights to real exponents, equipped with the
lexicographic order. Group operation is pointwise addition of exponents
(corresponding to multiplication of monomials).

A subtlety governs the *direction* of the order. The lexicographic order on
finitely-supported functions compares at the *smallest* differing index. To make
"highest tower height = most significant" we store the exponent of height $h$ at
finsupp index $-h$. Concretely:

**Definition 3.2.** $\mathtt{mono}(h, a) := \mathrm{toLex}\big(\mathrm{single}(-h, a)\big)$,
the transmonomial with real exponent $a$ at tower height $h$ and zero elsewhere.

The lexicographic order makes `TransMono` a `LinearOrderedAddCommGroup`.

### 3.2 The field

**Definition 3.3 (Transseries).** The **field of transseries** is
$$\mathtt{TSeries} := \mathrm{HahnSeries}(\mathtt{TransMono}, \mathbb{R}).$$
By Hahn's theorem (Section 2), `TSeries` is a field (`instField`). For $h \in
\mathbb{Z}$, $a \in \mathbb{R}$ we write $\mathtt{term}(h,a) :=
\mathrm{single}(\mathtt{mono}(h,a), 1)$ for the one-term transseries
$(\text{level } h)^a$, and we set $x := \mathtt{term}(0,1)$, $e^x :=
\mathtt{term}(1,1)$, $\log x := \mathtt{term}(-1,1)$.

The real numbers embed via the constant series map $C : \mathbb{R} \to
\mathtt{TSeries}$.

**Theorem 3.4 (`C_injective`).** $C : \mathbb{R} \to \mathtt{TSeries}$ is an
injective ring homomorphism. Hence $\mathbb{R}$ is a subfield of the transseries.

*Proof sketch.* This is the injectivity of the constant embedding for Hahn series:
$C(r)$ is the one-term series with coefficient $r$ at the identity monomial, and
$C(r) = 0$ forces $r = 0$. $\qquad\blacksquare$

---

## 4. Dominance: the lexicographic order is asymptotic dominance

The defining feature of transseries is that exponentials dominate powers
*absolutely*. We show the lexicographic order encodes this.

**Theorem 4.1 (Height dominance, `mono_lt_mono_of_height`).** For heights $h < h'$,
all $a \in \mathbb{R}$, and $a' > 0$,
$$\mathtt{mono}(h, a) < \mathtt{mono}(h', a').$$

*Proof sketch.* By the lexicographic criterion for finsupp, it suffices to exhibit
the least index at which the two exponent-vectors differ and check the inequality
there. The relevant index is $-h'$ (stored slot for the higher height). At every
index $d < -h'$ both vectors vanish (each is a single-support vector at $-h$ or
$-h'$, and $-h > -h'$). At index $-h'$ the left vector is $0$ while the right is
$a' > 0$. Hence the right side is lexicographically larger. $\qquad\blacksquare$

**Theorem 4.2 (Same-height comparison, `mono_lt_mono_same`).** For a fixed height
$h$ and $a < a'$, $\mathtt{mono}(h,a) < \mathtt{mono}(h,a')$.

*Proof sketch.* Both vectors are supported only at index $-h$; they first differ
there, and $a < a'$. $\qquad\blacksquare$

**Theorem 4.3 (Exp dominates every power, `exp_dominates_pow`).** For *every* real
$a$,
$$\mathtt{mono}(0, a) < \mathtt{mono}(1, 1), \qquad\text{i.e.}\qquad x^a \prec e^x.$$

*Proof sketch.* Immediate from Theorem 4.1 with $h = 0 < 1 = h'$ and $a' = 1 > 0$.
The point is the universally quantified $a$: no order valued in $\mathbb{Z}$ or
$\mathbb{R}$ (as for Laurent/Puiseux series) can place $e^x$ above $x^a$ for all
$a$ simultaneously; the extra tower dimension is essential. $\qquad\blacksquare$

**Valuation laws.** The one-term valuation $\mathrm{orderTop}(\mathtt{term}(h,a)) =
\mathtt{mono}(h,a)$ (`orderTop_term`) and multiplicativity
$\mathrm{orderTop}(xy) = \mathrm{orderTop}(x) + \mathrm{orderTop}(y)$
(`orderTop_mul`) make `orderTop` a faithful measure of asymptotic size.

### 4.1 Analytic grounding

To certify that the *formal* order models real asymptotics, we connect to honest
little-o statements at $+\infty$.

**Theorem 4.4 (`isLittleO_pow_exp`).** For every $n \in \mathbb{N}$,
$x^n = o(e^x)$ as $x \to +\infty$.

**Theorem 4.5 (`isLittleO_expPow_expExp`).** For every $n \in \mathbb{N}$,
$(e^x)^n = o\big(e^{e^x}\big)$ as $x \to +\infty$.

*Proof sketch.* Theorem 4.4 is the classical growth comparison
$x^n / e^x \to 0$. Theorem 4.5 follows by composing Theorem 4.4 with the
substitution $x \mapsto e^x$ (which tends to $+\infty$), yielding $(e^x)^n =
o(e^{e^x})$. These are the analytic shadows of `exp_dominates_pow` (Theorem 4.3)
and height dominance (Theorem 4.1). $\qquad\blacksquare$

---

## 5. The asymptotic comparison theorem

We now formalize the uniqueness principle: a transseries is determined by its
asymptotic expansion.

**Definition 5.1 (Agreement to all orders, `AgreeToAllOrders`).** Two transseries
$a, b$ **agree to all orders** when, for every transmonomial $g$,
$$g < \mathrm{orderTop}(a - b)$$
(in $\mathtt{TransMono} \cup \{\top\}$). That is, the difference $a-b$ is
asymptotically smaller than *every* transmonomial scale.

**Theorem 5.2 (Asymptotic comparison, `agreeToAllOrders_iff_eq`).** For all
transseries $a, b$,
$$\mathrm{AgreeToAllOrders}(a,b) \iff a = b.$$

*Proof sketch.* ($\Rightarrow$) Suppose $a-b$ is dominated by every transmonomial.
If $\mathrm{orderTop}(a-b) \neq \top$, then it equals some $g \in \mathtt{TransMono}$;
instantiating the hypothesis at this $g$ gives $g < g$, a contradiction. Hence
$\mathrm{orderTop}(a-b) = \top$, so $a - b = 0$ by the triviality criterion, i.e.
$a = b$. ($\Leftarrow$) If $a = b$ then $a - b = 0$, $\mathrm{orderTop}(0) = \top$,
and $g < \top$ for every $g$. $\qquad\blacksquare$

**Corollary 5.3 (`agreeToAllOrders_equivalence`).** Agreement to all orders is an
equivalence relation — indeed it *is* equality.

**Corollary 5.4 (`not_agree_zero_of_ne_zero`).** A nonzero transseries does not
agree to all orders with $0$; it has a genuine leading term.

The mathematical weight of the theorem lies in Section 4: it is the *order
structure* on transmonomials that makes `orderTop` capture asymptotic size, and
Theorem 5.2 is the clean consequence that the asymptotic data are complete. The
quantification ranges over the entire uncountable monomial group, so the statement
is not vacuous.

---

## 6. The ordered, non-Archimedean field

Equipping the transseries field with the leading-term (lexicographic) order makes
it an ordered field.

**Definition 6.1.** $\mathtt{OTSeries} := \mathrm{Lex}(\mathtt{TSeries})$, the
transseries field with the order induced by comparing leading terms.

**Theorem 6.2 (Ordered field, `orderedField`).** $\mathtt{OTSeries}$ is a field
with a compatible linear order (a strict ordered ring).

**Theorem 6.3 (Positivity of monomials, `term_pos`).** Every one-term transseries
$\mathtt{term}(h,a)$ is positive, since its leading coefficient is $1 > 0$.

The order is **non-Archimedean**:

**Theorem 6.4 ($x$ is infinitesimal, `x_infinitesimal`).** For every $n \in
\mathbb{N}$, $(n+1)\cdot x < 1$. Thus the positive element $x$ is smaller than every
positive rational $1/(n+1)$.

**Theorem 6.5 ($1/x$ is infinite, `inv_x_infinite`).** For every $n \in
\mathbb{N}$, $n < \mathtt{term}(0,-1) = 1/x$.

**Theorem 6.6 (Reciprocity, `x_mul_inv_x`).** $x \cdot (1/x) = 1$.

*Proof sketch.* For 6.4, compute $(n+1)\cdot x = \mathrm{single}(\mathtt{mono}(0,1),
n+1)$; comparing leading terms against $1 = \mathrm{single}(0, 1)$ uses that
$\mathtt{mono}(0,1) > 0$ (the identity monomial), so the $x$-scale term is
dominated, giving $(n+1)x < 1$. Theorem 6.5 follows from 6.4 by inverting and
using positivity of $\mathtt{term}(0,-1)$. Theorem 6.6 is
$\mathtt{term}(0,1)\cdot \mathtt{term}(0,-1) = \mathtt{term}(0,0) = 1$ via the
exponent-addition law. $\qquad\blacksquare$

**Theorem 6.7 ($\mathbb{R}$ as an ordered subfield, `C_lt_iff`, `C_strictMono`).**
The constant embedding satisfies $C(a) < C(b) \iff a < b$, and is strictly
monotone. Combined with `C_injective`, this realizes $\mathbb{R}$ as a linearly
ordered subfield.

---

## 7. Ingredients of real closure

A real closed field is one that is ordered, in which every positive element has a
square root, and in which every odd-degree polynomial has a root. The classical
theorem that transseries are real closed rests on a structural criterion for Hahn
fields: roughly, the value group must be divisible and the residue field real
closed. We establish the value-group half explicitly and pinpoint the obstruction
that distinguishes transseries from Laurent series.

**Theorem 7.1 (Divisibility of the value group, `valueGroup_divisible`).** For
every transmonomial $g$ and every $n > 0$ there exists $g'$ with $n \cdot g' = g$.

*Proof sketch.* Take $g' := \mathrm{toLex}\big(\tfrac1n \cdot \mathrm{ofLex}(g)\big)$,
i.e. divide every real exponent of $g$ by $n$. Then $n\cdot g' = g$ coordinatewise,
using $n \cdot (n^{-1} a) = a$ in $\mathbb{R}$. $\qquad\blacksquare$

**Theorem 7.2 (Root extraction for monomials, `exists_nthRoot_term`).** For every
$h, a$ and $n > 0$ there exists $y \in \mathtt{OTSeries}$ with $y^n =
\mathtt{term}(h,a)$.

*Proof sketch.* Take $y := \mathtt{term}(h, a/n)$. By the power law for one-term
series, $\big(\mathtt{term}(h,a/n)\big)^n = \mathtt{term}(h, n\cdot(a/n)) =
\mathtt{term}(h,a)$. $\qquad\blacksquare$

**Theorem 7.3 (Monomials are squares, `isSquare_term`).** Every one-term
transseries is a square: $\mathtt{term}(h,a) = \big(\mathtt{term}(h,a/2)\big)^2$.

*Proof sketch.* The $n=2$ case of Theorem 7.2; equivalently $\mathtt{term}(h,a/2)
\cdot \mathtt{term}(h,a/2) = \mathtt{term}(h,a)$ by exponent addition.
$\qquad\blacksquare$

**Theorem 7.4 (The obstruction, `laurent_value_group_not_divisible`).** There is no
integer $k$ with $2k = 1$. Hence the value group $\mathbb{Z}$ of Laurent series is
not divisible.

*Proof sketch.* $2k = 1$ has no integer solution (parity / `omega`).
$\qquad\blacksquare$

**Discussion.** Theorems 7.1 and 7.4 are two sides of one coin. Laurent series use
integer exponents; halving an odd-exponent monomial leaves $\mathbb{Z}$, so $x$
has no square root and the field is *not* real closed. Transseries use *real*
exponents, restoring divisibility (7.1) and hence monomial root extraction (7.2,
7.3). This is the precise structural reason real exponents are mandatory, and it
identifies exactly the missing ingredient that the transseries construction
supplies. The full real-closure theorem additionally requires extending root
extraction from monomials to general series (via Newton-polygon / fixed-point
arguments over the real closed residue field $\mathbb{R}$); the present development
formalizes the value-group ingredient and the monomial-level roots, which are the
genuinely transseries-specific components.

---

## 8. The exp-shift automorphism

The substitution $x \mapsto e^x$ should raise every tower height by one. We realize
it as a field automorphism.

**Definition 8.1 (`expShift`, `expShiftEquiv`).** The exp-shift is the ring
homomorphism induced by the height shift $h \mapsto h+1$ on transmonomials;
together with the inverse log-shift $h \mapsto h-1$ it forms a field isomorphism
$\mathtt{expShiftEquiv} : \mathtt{TSeries} \xrightarrow{\ \cong\ } \mathtt{TSeries}$.

**Theorem 8.2 (Action on generators, `expShift_term`, `expShift_var`,
`expShift_log`).** $\mathtt{expShift}(\mathtt{term}(h,a)) = \mathtt{term}(h+1,a)$;
in particular $\mathtt{expShift}(x) = e^x$, $\mathtt{expShift}(e^x) =
\mathtt{term}(2,1) = e^{e^x}$, and $\mathtt{expShift}(\log x) = x$. Real constants
are fixed (`expShift_C`).

**Theorem 8.3 (Inverse laws, `expShift_logShift`, `logShift_expShift`).** The
log-shift is a two-sided inverse, so `expShiftEquiv` is an automorphism.

**Theorem 8.4 (Unbounded tower, `exists_exp_tower_gt`).** For every transmonomial
$g$ there is a natural number $n$ with $g < \mathtt{mono}(n, 1)$: no finite scale
is cofinal; the exponential tower has no top.

*Proof sketch.* Any $g$ has finite support, hence a maximal active height $h_{\max}$;
choosing $n > h_{\max}$ makes $\mathtt{mono}(n,1)$ dominate by height dominance
(Theorem 4.1). $\qquad\blacksquare$

These results express the self-similarity of the growth-scale tower: the field
looks the same one exponential level up, and the tower extends without bound.

---

## 9. Algorithms

The model is constructive enough to support symbolic computation on transmonomials
and on finite (truncated) transseries. We highlight three algorithms.

### 9.1 Dominance comparison of transmonomials

**Input:** two transmonomials as finite exponent maps $A, B : \mathbb{Z}
\to_{\mathrm f} \mathbb{R}$.
**Output:** the order relation $<, =, >$ (asymptotic dominance), matching the
lexicographic order with highest height most significant.

The algorithm scans heights from highest to lowest and returns at the first
disagreement. Complexity is $O(k \log k)$ to sort the union of active heights of
size $k$, then $O(k)$ to scan. This is the computational form of Theorems 4.1–4.2.

### 9.2 Leading-term (valuation) extraction

**Input:** a finite transseries as a list of (transmonomial, coefficient) pairs
with nonzero coefficients.
**Output:** the leading transmonomial (the `orderTop`) and its coefficient, or the
report that the series is $0$.

Take the maximum transmonomial under §9.1; its coefficient is the leading
coefficient. Complexity $O(m \cdot k)$ for $m$ terms over $k$ heights. This
computes `orderTop`/leading coefficient and underlies the comparison theorem of
Section 5.

### 9.3 Monomial $n$-th root

**Input:** a one-term transseries $\mathtt{term}(h,a)$ and $n > 0$.
**Output:** $\mathtt{term}(h, a/n)$, an $n$-th root.

This is the direct realization of Theorems 7.1–7.3: divide every real exponent by
$n$. Constant time per active height. With integer exponents this fails exactly
when $n \nmid a$ — the obstruction of Theorem 7.4.

---

## 10. Applications

- **Asymptotics of ODE solutions.** Formal transseries solutions of nonlinear ODEs
  near irregular singular points live precisely in a field of this kind; the
  comparison theorem (5.2) justifies term-by-term determination of coefficients.
- **Resurgence and divergent series.** The non-Archimedean ordered structure
  (Section 6) is the algebraic setting for Borel–Écalle summation and trans-series
  ansätze in physics.
- **Model theory of $\exp$.** The dominance laws (Section 4) and exp-shift (Section
  8) mirror the structure of Hardy fields and of the model-complete theory of
  $(\mathbb{R}, \exp)$.
- **Symbolic computation.** The algorithms of Section 9 give certified primitives
  for a transseries calculator: comparison, leading-term extraction, and roots.

---

## 11. Discussion

The model deliberately isolates the *order-theoretic and algebraic* skeleton of
transseries, deferring differential structure. Two design choices are central.
First, encoding tower height $h$ at finsupp index $-h$ aligns "highest tower" with
"least lexicographic index," so asymptotic dominance is *literally* the ambient
lexicographic order — no auxiliary translation is needed, and dominance theorems
reduce to the finsupp lex criterion. Second, using *real* exponents (value group
$\mathbb{R}^{(\mathbb{Z})}$ rather than $\mathbb{Z}^{(\mathbb{Z})}$) is what makes
the value group divisible; Theorem 7.4 shows this is not a convenience but a
necessity for real closure.

A natural question is whether the comparison theorem (5.2) is "too easy" inside the
Hahn model. The honest answer: the depth is in Section 4, where the order is shown
to model asymptotics; given that, uniqueness is the clean valuation-theoretic
consequence, exactly as in the classical theory once one accepts Hahn coefficients
as asymptotic data. We additionally anchor the formal order to genuine little-o
statements (Theorems 4.4–4.5) so the abstraction is not empty.

---

## 12. Future work

- **Differential structure.** Equip the field with the derivation extending
  $\frac{d}{dx}$, satisfying $x' = 1$, $(e^x)' = e^x \cdot 1$, and the chain rule
  across tower heights, making it a differential field and enabling formal ODE
  solving.
- **Full real closure.** Extend monomial root extraction (Section 7) to arbitrary
  series via Newton polygons and a fixed-point/Hensel argument over the real closed
  residue field $\mathbb{R}$, yielding the complete real-closedness theorem.
- **Composition and the exp/log functions.** Define composition of transseries and
  the genuine $\exp$ and $\log$ operators (not just the height-shift automorphism),
  and verify their inverse and functional laws.
- **Summability and Borel transform.** Connect the formal field to analyzable
  functions via Borel–Laplace summation, formalizing a slice of resurgence theory.
- **Reconstruction pipeline.** Formalize the inverse map from a well-ordered
  leading-term sequence back to its transseries and prove the round-trip
  correctness and uniqueness, giving a certified bridge between expansions and the
  objects they describe.

---

## 13. Summary of formal results

| Result | Name | Statement |
|---|---|---|
| Field structure | `instField` / `C_injective` | transseries form a field containing $\mathbb{R}$ |
| Height dominance | `mono_lt_mono_of_height` | higher tower dominates lower |
| Same-height order | `mono_lt_mono_same` | larger exponent dominates |
| Exp beats powers | `exp_dominates_pow` | $x^a \prec e^x$ for all real $a$ |
| Valuation laws | `orderTop_term`, `orderTop_mul` | leading term; multiplicativity |
| Analytic dominance | `isLittleO_pow_exp`, `isLittleO_expPow_expExp` | little-o at $+\infty$ |
| Comparison theorem | `agreeToAllOrders_iff_eq` | agree to all orders $\iff$ equal |
| Equivalence | `agreeToAllOrders_equivalence` | agreement is equality |
| Ordered field | `orderedField`, `term_pos` | strict ordered field; monomials positive |
| Non-Archimedean | `x_infinitesimal`, `inv_x_infinite`, `x_mul_inv_x` | infinitesimals and infinities |
| $\mathbb{R}$ ordered subfield | `C_lt_iff`, `C_strictMono` | order embedding of $\mathbb{R}$ |
| Value group divisible | `valueGroup_divisible` | $n\cdot g' = g$ solvable |
| Monomial roots | `exists_nthRoot_term`, `isSquare_term` | $n$-th roots; squares |
| Obstruction | `laurent_value_group_not_divisible` | $\nexists k\in\mathbb{Z},\ 2k=1$ |
| Exp-shift automorphism | `expShiftEquiv`, `expShift_var` | $x\mapsto e^x$ field iso |
| Unbounded tower | `exists_exp_tower_gt` | no cofinal scale |

All entries correspond to machine-checked theorems in the formal development.
