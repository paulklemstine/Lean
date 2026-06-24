# A Verified Base Layer for the Ordered Field of Transseries: Monomial Signs, Arithmetic, Square Roots, and Infinitesimals

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Applications (asymptotic analysis / ordered algebra)

## Abstract

Transseries are formal asymptotic expansions that generalize power series by
admitting, in addition to powers of the variable $x$, powers of $\log x$ and of
the iterated exponentials $e^{x}, e^{e^{x}}, \dots$. They form a non-Archimedean
ordered field that is the natural setting for asymptotic expansions "beyond power
series," including the exponentially small phenomena invisible to classical
perturbation theory. We present a mathematically correct, machine-verified *base
layer* for this field, realized concretely as the lexicographically ordered Hahn
series field $\textsf{TSeries} = \mathrm{Lex}(\mathrm{HahnSeries}\;\textsf{TransMono}\;\mathbb{R})$
over the transmonomial value group $\textsf{TransMono} = \mathrm{Lex}(\mathbb{Z} \to_0 \mathbb{R})$.
Working with the single-term generator $\textsf{term}(g,a)$ — the series with sole
coefficient $a$ on transmonomial $g$ — we establish: (i) a *sign characterization*,
$0 < \textsf{term}(g,a) \iff 0 < a$, together with its negative counterpart; (ii)
the *monomial multiplication law* $\textsf{term}(g,a)\cdot\textsf{term}(h,b)=\textsf{term}(g+h,ab)$;
(iii) a *corrected square-root law* for square-compatible monomials, tracking both
exponent and coefficient; (iv) the impossibility of a negative-coefficient monomial
being a square; and (v) the existence of *positive infinitesimals*, with an explicit
witness. We are explicit about scope: this is **not** a proof of real closure nor of
general square-root closure, but the verified foundation those results require. We
give full statements, proof sketches faithful to the formal development, supporting
algorithms and numerical demonstrations, and a roadmap toward real closure.

---

## 1. Introduction

### 1.1 Asymptotics beyond power series

When a quantity is studied as $x \to +\infty$, its behavior is governed not by a
single number but by a hierarchy of *scales of growth*. A power series
$\sum_n a_n x^{-n}$ captures the polynomially-graded part of this hierarchy, but
it is structurally incapable of representing two ubiquitous phenomena:

1. **Trans-polynomial growth**: quantities like $e^{x}$, $e^{e^{x}}$, $\dots$
   that exceed every power of $x$; and
2. **Exponentially small corrections**: quantities like $e^{-x}$ or $e^{-x^2}$
   that are smaller than every power $x^{-n}$ and yet are not zero — the terms
   responsible for Stokes phenomena, resurgence, and the long-time (in)stability
   of dynamical systems.

**Transseries** (Dahn–Göring, Écalle, van den Dries–Macintyre–Marker, van der
Hoeven) supply a single algebraic structure containing all such scales at once.
A transseries is a well-ordered formal sum of real multiples of *transmonomials* —
products of real powers of $x$, $\log x$, $e^{x}$, $e^{e^{x}}$, and so on. The
totality forms a real, non-Archimedean ordered field with remarkable closure
properties (it is, famously, real-closed and closed under formal differentiation
and composition).

### 1.2 Contribution and scope

Deep closure theorems for transseries rest on a foundation of elementary but
error-prone facts about *monomials*: how their signs are determined, how they
multiply, when they admit square roots, and how infinitesimals arise. This paper
formalizes that foundation with machine-checked proofs.

We emphasize, exactly as the formal development does, what is **and is not**
claimed. We do **not** prove real closure of the transseries field, nor
square-root closure in general. We **do** provide a verified base layer:

- monomial signs (Theorems 3.1, 3.2),
- monomial arithmetic (Theorem 3.3),
- valid square roots of positive square-compatible monomials, and the
  non-squareness of negative monomials (Theorems 3.4, 3.5),
- constants as monomials (Lemmas 3.6, 3.7), and
- positive infinitesimals, with an explicit witness (Theorem 3.8, Lemma 3.9,
  Corollary 3.10).

Section 2 fixes the model; Section 3 states and sketches the results; Section 4
gives algorithms; Section 5 gives applications and numerical demonstrations;
Sections 6–7 discuss limitations and future work toward real closure.

### 1.3 On the formalization and its guarantees

Every statement in Section 3 is a theorem with a complete, machine-checked proof;
the proof sketches below are faithful summaries of those formal arguments, naming
the exact lemmas they invoke. Two methodological commitments are worth
highlighting. First, *the hypotheses are exactly the ones used*: the square-root
law, for instance, carries both the nonnegativity hypothesis $a \ge 0$ and the
halvability hypothesis $g = k + k$ because the proof genuinely needs both; neither
is decorative. Second, *negative results are stated as positive theorems*:
"a negative monomial is not a square" is not an informal caveat but a proved
proposition (Theorem 3.5). This discipline is what distinguishes a verified base
layer from a plausible sketch, and it is what makes the layer safe to build on:
any later development can cite these statements without re-auditing their
hypotheses.

---

## 2. The model

We realize transseries via *Hahn series*, the standard device for giving formal
infinite sums over an ordered value group a robust field structure.

### Definition 2.1 (Transmonomial value group)
The **value group of transmonomials** is
$$\textsf{TransMono} \;:=\; \mathrm{Lex}\,(\mathbb{Z} \to_0 \mathbb{R}),$$
the additive group of finitely supported functions $\mathbb{Z} \to \mathbb{R}$,
equipped with the **lexicographic order** (`Finsupp.Lex`): for $g \neq 0$, the
sign of $g$ is the sign of $g(h^\*)$ at the *smallest* index $h^\*$ on which $g$ is
supported (equivalently, $g < g'$ iff at the least index where they differ, $g$
has the smaller value). The integer index $h$ is the *tower height* (height $0$ is
the scale of $x$, height $1$ the scale of $e^{x}$, height $-1$ the scale of
$\log x$, etc.), and the real value $g(h)$ is the exponent at that height; addition
is pointwise, so multiplying monomials adds exponents height-by-height. By the
convention of Definition 2.2 the *dominant* monomial of a series is the one on the
*smallest* group element, so a strictly positive group element corresponds to an
*infinitesimal* scale (cf. Theorem 3.8).

### Definition 2.2 (Field of transseries)
The **field of transseries** is the lexicographically ordered Hahn series field
$$\textsf{TSeries} \;:=\; \mathrm{Lex}\big(\mathrm{HahnSeries}\;\textsf{TransMono}\;\mathbb{R}\big).$$
A Hahn series over $\textsf{TransMono}$ with coefficients in $\mathbb{R}$ is a
function from $\textsf{TransMono}$ to $\mathbb{R}$ whose support is well-ordered;
this well-ordering guarantees that products are defined and that the structure is
a field. The $\mathrm{Lex}$ wrapper installs the order in which a series' sign is
the sign of the coefficient on its *smallest-index* (dominant) monomial: writing
$\mathrm{lc}(s)$ for that **leading coefficient**, one has the standard fact
$0 < s \iff 0 < \mathrm{lc}(s)$. Over the ordered field $\mathbb{R}$, this makes
$\textsf{TSeries}$ a (strict) ordered field.

**Remark 2.2.1 (Why Hahn series, and why well-ordering matters).** The defining
restriction on a Hahn series — that its support be *well-ordered* in the value
group — is precisely what makes the formal infinite sum $\sum_g c_g\,(\text{magnitude } g)$
multiply and invert like an honest element of a field. Well-ordering guarantees
that in a product each output monomial receives only finitely many contributions,
so the convolution coefficient is a finite sum; it guarantees a well-defined
*dominant* (smallest) monomial, hence a leading coefficient and a sign; and it
underlies the recursive inversion that makes $\textsf{TSeries}$ a field rather than
merely a ring. The one-term series $\textsf{term}(g,a)$ has the simplest possible
support — a single point — so all of these mechanisms specialize to elementary,
directly checkable identities, which is exactly why the base layer can be made
airtight before any infinite-support reasoning is attempted.

### Definition 2.3 (One-term series / monomial generator)
For $g \in \textsf{TransMono}$ and $a \in \mathbb{R}$, the **one-term series** is
$$\textsf{term}(g,a) \;:=\; \mathrm{toLex}\big(\mathrm{single}\;g\;a\big) \in \textsf{TSeries},$$
the series whose only nonzero coefficient is $a$, placed on the monomial $g$.
These generate $\textsf{TSeries}$ as a Hahn series field and are the objects all
of our results concern. Its leading coefficient is $a$ (the monomial $g$ being the
unique, hence smallest, support point).

### Definition 2.4 (Explicit positive exponent)
$$\textsf{posExp} \;:=\; \mathrm{toLex}\big(\mathrm{single}\;(0:\mathbb{Z})\;(1:\mathbb{R})\big) \in \textsf{TransMono},$$
the transmonomial with unit real exponent at tower height $0$ — the generator
whose one-term series $\textsf{term}(\textsf{posExp},1)$ is the explicit
infinitesimal of Theorem 3.8 (it behaves like a reciprocal scale such as $1/x$ as
$x\to\infty$).

---

## 3. Main results

Throughout, $g, h, k \in \textsf{TransMono}$ and $a, b \in \mathbb{R}$.

### 3.1 Signs of monomials

#### Theorem 3.1 (Monomial positivity, `single_pos_iff_coeff_pos`)
$$0 < \textsf{term}(g,a) \quad\Longleftrightarrow\quad 0 < a.$$

*Proof sketch.* The sign of a Hahn series equals the sign of its leading
coefficient: $0 < s \iff 0 < \mathrm{lc}(s)$ (Mathlib's
`leadingCoeff_pos_iff`, transported across $\mathrm{Lex}$). For a one-term series
the leading coefficient is exactly the coefficient: $\mathrm{lc}(\textsf{term}(g,a)) = a$
(`leadingCoeff_of_single`, after $\mathrm{ofLex}\circ\mathrm{toLex} = \mathrm{id}$).
Composing the two equivalences gives the claim. The monomial $g$ is irrelevant to
the sign. $\square$

#### Theorem 3.2 (Monomial negativity, `single_neg_of_coeff_neg`)
$$a < 0 \;\Longrightarrow\; \textsf{term}(g,a) < 0.$$

*Proof sketch.* Dual to Theorem 3.1, using $s < 0 \iff \mathrm{lc}(s) < 0$
(`leadingCoeff_neg_iff`) and again $\mathrm{lc}(\textsf{term}(g,a)) = a$. $\square$

### 3.2 Arithmetic of monomials

#### Theorem 3.3 (Monomial law, `term_mul_term`)
$$\textsf{term}(g,a)\cdot\textsf{term}(h,b) \;=\; \textsf{term}(g+h,\;a\,b).$$

*Proof sketch.* This is the $\mathrm{Lex}$-wrapped instance of the Hahn-series
identity $\mathrm{single}\;g\;a \cdot \mathrm{single}\;h\;b = \mathrm{single}\;(g+h)\;(ab)$
(`single_mul_single`). Convolution of two single-support series produces a single
support point at the sum $g+h$ of the supports, with coefficient the product $ab$.
$\square$

The monomial law is the computational nucleus of the theory: it is exactly the
identity needed to show that a valuation (Section 7) is multiplicative.

### 3.3 Constants

#### Lemma 3.6 (Naturals as monomials, `natCast_eq_term`)
For $n \in \mathbb{N}$, $\;(n : \textsf{TSeries}) = \textsf{term}(0, (n:\mathbb{R}))$.

#### Lemma 3.7 (Unit as monomial, `one_eq_term`)
$(1 : \textsf{TSeries}) = \textsf{term}(0, 1)$.

*Proof sketch (both).* The natural-number cast and the unit of the Hahn series
field are, by definition, constant series supported on the identity monomial $0$;
their coefficient there is $n$ (resp. $1$). Equality of coefficient functions
(`coeff_inj`) transported across $\mathrm{toLex}$ gives the identities. $\square$

These lemmas anchor constants on the bottom rung ($g = 0$) of the magnitude
ladder, which is precisely what makes the infinitesimal argument (Theorem 3.8)
go through.

### 3.4 Square roots

#### Theorem 3.4 (Square root of a square-compatible monomial, `single_square_of_double_exponent`)
If $g = k + k$ and $0 \le a$, then
$$\big(\textsf{term}(k,\sqrt{a})\big)^{2} \;=\; \textsf{term}(g,a).$$

*Proof sketch.* Expand the square and apply the monomial law (Theorem 3.3):
$$\textsf{term}(k,\sqrt a)^2 = \textsf{term}(k,\sqrt a)\cdot\textsf{term}(k,\sqrt a) = \textsf{term}(k+k,\;\sqrt a\cdot\sqrt a).$$
Substitute $k+k = g$ and use $\sqrt a \cdot \sqrt a = a$ for $a \ge 0$
(`Real.mul_self_sqrt`). $\square$

**Remark (why both conditions matter).** The result tracks *two* data: the
exponent must be *halvable* ($g = k+k$), and the coefficient must be nonnegative
($a \ge 0$). An informal "square root halves the exponent" that ignores the
coefficient is simply wrong; the formal statement corrects it by replacing $a$ by
$\sqrt a$ under the explicit hypothesis $a \ge 0$. This is the precise algebraic
seed of the divisibility requirement on the value group discussed in Section 7.

#### Theorem 3.5 (Negative monomials are not squares, `not_square_negative_monomial`)
$$a < 0 \;\Longrightarrow\; \neg\,\mathrm{IsSquare}\big(\textsf{term}(g,a)\big).$$

*Proof sketch.* Suppose $\textsf{term}(g,a) = r^2$ for some $r \in \textsf{TSeries}$.
In an ordered ring $r^2 \ge 0$, so $\textsf{term}(g,a) \ge 0$. But Theorem 3.2
gives $\textsf{term}(g,a) < 0$, a contradiction. $\square$

### 3.5 Infinitesimals

#### Theorem 3.8 (Positive infinitesimal monomial, `positive_infinitesimal_monomial`)
For any $\delta \in \textsf{TransMono}$ with $0 < \delta$, the monomial
$\varepsilon := \textsf{term}(\delta, 1)$ satisfies
$$0 < \varepsilon \qquad\text{and}\qquad (n : \textsf{TSeries})\cdot \varepsilon < 1 \;\text{ for every } n \in \mathbb{N}.$$

*Proof sketch.* Positivity is Theorem 3.1 with $a = 1$. For the infinitesimality,
rewrite the product using Lemmas 3.6–3.7 and the monomial law:
$(n)\cdot\varepsilon = \textsf{term}(0,n)\cdot\textsf{term}(\delta,1) = \textsf{term}(\delta, n)$,
while $1 = \textsf{term}(0,1)$. Comparing these two one-term series with the Hahn
order (`HahnSeries.lt_iff`) reduces to a comparison at the dominant index $0$:
since $0 \neq \delta$ (because $0 < \delta$), the series $\textsf{term}(\delta,n)$
has coefficient $0$ at index $0$ while $1$ has coefficient $1$ there, and at all
indices below $\delta$ both vanish. Hence $\textsf{term}(\delta,n) < 1$ for every
$n$. Intuitively: the product lives on the strictly positive (hence
infinitesimal) magnitude $\delta$, so it is dominated by the constant $1$, whose
dominant monomial is the smaller group element $0$. $\square$

This is a constructive failure of the Archimedean property: $\varepsilon$ is a
positive element no integer multiple of which reaches $1$.

#### Lemma 3.9 (`posExp_pos`)
$0 < \textsf{posExp}$ in $\textsf{TransMono}$.

*Proof sketch.* Compare $\textsf{posExp} = \mathrm{single}\;0\;1$ with $0$ in the
lexicographic order (`Finsupp.Lex.lt_iff`): they agree (both $0$) at every index
below $0$, and at index $0$ the value $1 > 0$ decides positivity. $\square$

#### Corollary 3.10 (Explicit infinitesimal, `explicit_positive_infinitesimal`)
Instantiating Theorem 3.8 at $\delta = \textsf{posExp}$ yields the explicit
positive infinitesimal $\textsf{term}(\textsf{posExp}, 1)$ — a named, computable
witness that $\textsf{TSeries}$ is non-Archimedean.

---

### 3.6 A worked example

The four laws compose into concrete computations. Consider the positive,
square-compatible monomial $s = \textsf{term}(g, 9)$ with $g$ the exponent $4$ at
tower height $0$ (so $g = k + k$ with $k$ the exponent $2$). By Theorem 3.4,
$$\sqrt{s} = \textsf{term}(k, 3), \qquad \text{since } \sqrt{9} = 3 \text{ and } k+k = g,$$
and squaring back via the monomial law (Theorem 3.3) recovers
$\textsf{term}(k,3)\cdot\textsf{term}(k,3) = \textsf{term}(k+k, 9) = s$. The naive
rule that halves only the exponent would return $\textsf{term}(k, 9)$, whose square
is $\textsf{term}(g, 81) \neq s$ — a concrete witness that the coefficient must also
be rooted, exactly as the corrected Theorem 3.4 prescribes. Meanwhile
$\textsf{term}(g, -9)$ is, by Theorem 3.5, not a square at all. Finally, taking
$\delta = \textsf{posExp}$ (Definition 2.4, positive by Lemma 3.9), the element
$\varepsilon = \textsf{term}(\delta, 1)$ satisfies $0 < \varepsilon$ and
$n\varepsilon = \textsf{term}(\delta, n) < 1$ for every $n$ (Theorem 3.8): adding
$\varepsilon$ to itself $10^{18}$ times still does not reach the constant $1$. The
accompanying demonstration code reproduces each of these equalities and
inequalities symbolically and confirms them against an order-faithful numerical
grounding.

## 4. Algorithms

The verified laws are equational and decidable on finite data, so they induce
exact symbolic algorithms on one-term series (and, by linearity, on
finite-support series). We record the two most important.

### 4.1 Monomial multiplication

Direct realization of Theorem 3.3. Represent a transmonomial as a finite map from
tower height to real exponent; represent a one-term series as a pair
(monomial, coefficient). Multiplication adds the maps and multiplies the
coefficients. Complexity: $O(|g| + |h|)$ in the supports.

### 4.2 Monomial square-root decision

Direct realization of Theorems 3.4 and 3.5. Given $\textsf{term}(g,a)$: if
$a < 0$, report "not a square" (Theorem 3.5); if $a \ge 0$ and every exponent in
$g$ is even-halvable on the chosen index group, return $\textsf{term}(g/2,\sqrt a)$
(Theorem 3.4); otherwise report "not square-compatible in this value group" — the
obstruction that motivates Section 7.

---

## 5. Applications and numerical demonstration

Because the value group is concrete (finitely supported real exponents over
integer heights), all four laws can be exercised numerically by *grounding*
transmonomials at a large real value of $x$ and checking that the symbolic
identities match the floating-point reality, and that the order predictions
(signs, dominance, infinitesimality) hold. The accompanying `demo.py` does
exactly this: it implements `term`, the monomial law, the square-root law, the
sign rule, and the infinitesimal construction, and verifies on concrete inputs
(e.g. $\sqrt{9x^4}=3x^2$, $(3e^{x})(2e^{e^{x}})$, and
$n\cdot\textsf{term}(\textsf{posExp},1) < 1$ for growing $n$ as $x\to\infty$)
that the formal predictions are borne out, including the *failure* of the naïve
exponent-only square-root rule that omits the coefficient.

Three concrete uses follow directly. (i) *Exact symbolic asymptotics:* because the
monomial law (Theorem 3.3) is an exact identity on finitely supported data, one can
multiply and compare leading terms of asymptotic expansions without numerical
error, the foundation of any transseries-based asymptotic calculus. (ii)
*Certified sign determination:* Theorems 3.1–3.2 reduce the sign of a one-term
expansion to the sign of a single real number, a primitive needed whenever one
must decide the eventual sign of a function from its expansion (e.g. comparing two
growth rates). (iii) *Detecting non-squares and obstructions:* Theorem 3.5 gives a
decision procedure for one-term non-squares, and Theorem 3.4 isolates the precise
algebraic requirement (halvability of the exponent) that an ambient value group
must satisfy for square roots to exist — information that directly drives the
design choice in Section 7 to pass to a divisible value group.

The non-Archimedean infinitesimal of Theorem 3.8 is itself of independent
interest: it exhibits, by an explicit and computable witness, a positive element
below every $1/n$, the hallmark separating transseries from the real line and the
reason transseries can resolve infinitely many distinct scales of smallness at
once.

---

## 6. Discussion: what is proven, and what is not

The development is deliberately conservative. It supplies airtight versions of the
statements every higher transseries theorem silently relies upon, and it exposes —
rather than papers over — the hypotheses that make them true (the coefficient
condition $a\ge0$ *and* the exponent condition $g=k+k$ in the square-root law). It
does **not** assert:

- **Real closure.** That every odd-degree polynomial over $\textsf{TSeries}$ has a
  root remains future work.
- **General square-root closure.** Theorem 3.4 covers only square-compatible
  monomials; arbitrary positive series require the recursive leading-term method
  (Section 7) and a divisible value group.

Stating these non-claims explicitly is part of the contribution: it prevents the
common informal error of conflating "monomials behave well" with "the field is
real-closed."

---

## 7. Future directions

These build directly on the verified base layer (signs, arithmetic, square roots
of square-compatible monomials, infinitesimals).

1. **From monomials to finite-support polynomials.** Extend the sign
   characterization (Theorems 3.1–3.2) from one-term series to finitely supported
   ones: the sign of a nonzero finite sum is the sign of its leading
   (smallest-index) coefficient (Mathlib's `leadingCoeff_pos_iff`/`neg_iff`), so
   the remaining work is computing the leading coefficient of an explicit finite
   sum of `term`s and matching it to the dominant monomial.

2. **The leading-term valuation.** Formalize the map sending each nonzero
   transseries to its dominant transmonomial (`orderTop`), and prove
   multiplicativity, ultrametric inequalities, and order-compatibility in one
   place. The monomial law (Theorem 3.3) is exactly the computational core
   showing the valuation of a product of monomials adds; the general lemmas
   bootstrap from this single-monomial case.

3. **Divisibility of the value group.** Square-root closure needs a 2-divisible
   value group; real closure needs full divisibility. $\textsf{TransMono} =
   \mathrm{Lex}(\mathbb{Z}\to_0\mathbb{R})$ is *not* 2-divisible (the integer
   tower index obstructs halving). Replacing the tower index by a divisible group
   (e.g. $\mathrm{Lex}(\mathbb{Q}\to_0\mathbb{R})$) or passing to the divisible
   hull makes Theorem 3.4 apply to *every* positive monomial. Theorem 3.4 makes
   this requirement precise via its explicit hypothesis $g = k + k$.

4. **Square roots of arbitrary positive series by recursive leading-term
   cancellation.** Beyond monomials, obtain $\sqrt{s}$ for any positive $s$ by
   factoring out the (now halvable) dominant monomial, reducing to $\sqrt{1+u}$
   with $u$ infinitesimal, and iterating leading-term cancellation; convergence is
   controlled by the well-ordering of the support. This is the gateway to real
   closure.

---

## References (for context; the paper is self-contained)

- H. Hahn, *Über die nichtarchimedischen Größensysteme* (1907).
- J. Écalle, *Les fonctions résurgentes* (1981–85).
- L. van den Dries, A. Macintyre, D. Marker, *Logarithmic-exponential series* (2001).
- J. van der Hoeven, *Transseries and Real Differential Algebra* (Springer LNM 1888, 2006).
