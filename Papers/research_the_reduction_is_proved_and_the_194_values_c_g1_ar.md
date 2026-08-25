# Rigidity of the Monstrous-Moonshine Head Product

### From a Laurent coefficient to a complete finite invariant

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Monstrous Moonshine attaches to each of the $194$ conjugacy classes $g$ of the
Monster simple group a McKay–Thompson series
$T_g(q) = q^{-1} + 0 + c_g(1)q + c_g(2)q^2 + \cdots$, whose *head table* is the
list of $194$ integers $c_g(1)$. We study the $194$-fold product
$P = \prod_g T_g$ as an element of the field of formal Laurent series, and prove
three things about it.

First, a **reduction**: for series in McKay–Thompson normalization (simple pole
with residue-coefficient $1$, vanishing constant term), the Laurent coefficient
of $P$ in degree $-192$ is exactly $\sum_g c_g(1)$, and the coefficient in degree
$-191$ is exactly $\sum_g c_g(2)$. Consequently the assertion "the coefficient of
$q^{-192}$ in $P$ equals $S$" is *equivalent* to the decidable integer equation
$\sum_g c_g(1) = S$. The degree-$3$ statement rests on a division-free Newton
identity for the cubic coefficient of a finite product of power series with
constant term $1$.

Second, a **Vieta theorem**: for head-normalized data, the coefficient of $P$ in
degree $2k - 194$ is the $k$-th elementary symmetric function $e_k$ of the head
table, for every $k \ge 0$. The cases $k = 0, 1$ recover the exact pole order
$194$ with leading coefficient $1$, and the reduction above.

Third, a **rigidity theorem**: two integral head tables produce the same
$194$-fold product if and only if they agree as multisets. The product is
therefore a *complete* invariant of the table up to relabelling, so the passage
from an infinite Laurent-series statement to finite arithmetic loses nothing.
Equality of two Monster-sized products is decidable, and two candidate tables
with different sums are already separated by their products.

We complement the structural results with a self-contained, division-free
derivation of the identity-class entry $c_{1A}(1) = 196884$ from the identity
$j = E_4^3/\Delta$ using only formal power series over $\mathbb{Z}$, together
with the first twelve Ramanujan tau values and the Hecke relations, congruences
and non-vanishing statements they satisfy. Finally we record an a priori bound:
if moonshine's prediction $c_g(1) = 1 + \chi_{196883}(g)$ holds, the value of the
finite check is confined to $194 \pm 194\cdot196883$.

**Keywords:** Monstrous Moonshine, McKay–Thompson series, elementary symmetric
functions, Vieta's formulas, formal Laurent series, Newton identities, modular
invariant $j$, Ramanujan tau function.

---

## 1. Introduction

### 1.1 Background

The modular invariant
$$j(q) = \frac{1}{q} + 744 + 196884\,q + 21493760\,q^2 + 864299970\,q^3 + \cdots$$
and the Monster sporadic simple group $\mathbb{M}$ are linked by McKay's
observation $196884 = 196883 + 1$, where $196883$ is the dimension of the
smallest faithful irreducible representation of $\mathbb{M}$. Conway and Norton's
Monstrous Moonshine conjecture extends the observation to all $194$ conjugacy
classes: to each class $g$ it attaches a *McKay–Thompson series*
$$T_g(q) = \frac{1}{q} + 0 + c_g(1)\,q + c_g(2)\,q^2 + \cdots,$$
predicted to be the normalized generator of the function field of a genus-zero
subgroup of $\mathrm{SL}_2(\mathbb{R})$, with
$c_g(n) = \operatorname{tr}(g \mid V^\natural_n)$ for the graded moonshine module
$V^\natural = \bigoplus_n V^\natural_n$. In particular
$$c_g(1) = 1 + \chi_{196883}(g),$$
so the *head table* $\bigl(c_g(1)\bigr)_{g}$ is a list of $194$ integers read off
the character table of $\mathbb{M}$. The identity class gives
$T_{1A} = j - 744$ and $c_{1A}(1) = 196884$.

### 1.2 The question addressed here

Statements about the head layer of moonshine can be packaged as statements about
the single product
$$P = \prod_{g} T_g(q),$$
an element of $\mathbb{C}((q))$ with a pole of order $194$. Two questions arise
naturally:

1. **Reduction.** Which arithmetic statements about the head table are
   *equivalent* to statements about the Laurent coefficients of $P$?
2. **Completeness.** Is such a reduction lossy? A single Laurent coefficient
   sees only one symmetric function of $194$ numbers, so one might expect the
   product to forget most of the table.

The answer to (1) is that the coefficient in degree $-192$ *is* the sum of the
head table (Theorem 4.2), the coefficient in degree $-191$ *is* the sum of the
next column (Theorem 3.4), and more generally the coefficient in degree
$2k-194$ *is* the $k$-th elementary symmetric function of the head table
(Theorem 5.3). The answer to (2) is that the reduction is not lossy at all: the
product determines the head table up to permutation (Theorem 6.5), which is the
strongest possible statement, since a product is symmetric in its factors.

### 1.3 Organization

Section 2 sets up the algebra of normalized Laurent series. Section 3 proves a
division-free Newton identity at level $3$ and derives the degree-$(3-m)$
coefficient of a product of $m$ normalized series. Section 4 states the
reduction to a decidable integer equation. Section 5 proves the Vieta theorem
for head-normalized data. Section 6 proves rigidity and its corollaries,
including decidability. Section 7 derives the identity-class entry from
first-principles formal power series algebra and records the accompanying tau
data. Section 8 gives a priori bounds. Sections 9–11 discuss algorithms,
applications and open directions.

---

## 2. Normalized Laurent series

Fix the field $\mathbb{C}((q))$ of formal Laurent series with integer exponents
and coefficients in $\mathbb{C}$: elements are formal sums
$f = \sum_{n \in \mathbb{Z}} f_n q^n$ whose support is bounded below. Write
$[q^n]f := f_n$.

**Definition 2.1 (trace series).** Given a coefficient function
$c : \mathbb{N} \to \mathbb{C}$, the associated *trace series* is
$$T_c \;=\; q^{-1} + \sum_{n \ge 0} c(n)\,q^{n} \;\in\; \mathbb{C}((q)).$$

**Definition 2.2 (normalized).** A Laurent series $f$ is *normalized* if it has
no terms in degrees $< -1$ and $[q^{-1}]f = 1$. Every trace series is
normalized, and conversely every normalized series is the trace series of its
own non-negative coefficients.

**Definition 2.3 (normalized part).** For normalized $f$, put
$$\widehat f \;:=\; q\,f \;\in\; \mathbb{C}[[q]],$$
a formal power series with $\widehat f(0) = 1$ and
$[q^{n+1}]\widehat f = [q^{n}]f$ for $n \ge 0$.

The elementary but essential bookkeeping lemma is:

**Lemma 2.4 (pole order of a product).** If $f_1,\dots,f_m$ are normalized, then
$$\prod_{i=1}^m f_i \;=\; q^{-m}\prod_{i=1}^m \widehat{f_i},$$
where the right-hand product is a power series with constant term $1$.
Consequently the product has a pole of order exactly $m$ with leading
coefficient $1$, and for every $k \ge 0$,
$$[q^{\,k-m}]\prod_i f_i \;=\; [q^k]\prod_i \widehat{f_i}. \tag{2.1}$$

*Proof.* Multiply the defining relations $\widehat{f_i} = q f_i$ and use
multiplicativity of the constant term. $\square$

Equation (2.1) is the bridge used throughout: every statement about a Laurent
coefficient near the pole becomes a statement about a low-degree coefficient of
a product of power series with constant term $1$.

**Definition 2.5 (head table and head product).** Let $N_{\mathbb{M}} = 194$ be
the number of conjugacy classes of the Monster. A *head table* is a function
$t : \{1,\dots,194\} \to \mathbb{Z}$. Its *head series* are the trace series of
the coefficient functions
$$c^{(i)}(n) \;=\; \begin{cases} t_i & n = 1,\\ 0 & \text{otherwise},\end{cases}
\qquad\text{i.e.}\qquad T^{(i)} = q^{-1} + t_i\,q,$$
and the *head product* is
$$P(t) \;=\; \prod_{i=1}^{194} T^{(i)} \;=\; \prod_{i=1}^{194}\bigl(q^{-1} + t_i q\bigr).$$

The head series is the truncation of $T_g$ to the data actually being checked:
it retains the pole $q^{-1}$, the vanishing constant term required by
McKay–Thompson normalization, and the head coefficient $c_g(1) = t_i$. Since the
degree-$(-192)$ coefficient of a $194$-fold product of normalized series depends
only on the coefficients $c_g(0)$ and $c_g(1)$ (Theorem 4.1), the truncation is
harmless for the head layer, and it makes the higher-degree structure exactly
computable.

**Lemma 2.6.** $\widehat{T^{(i)}} = q(q^{-1} + t_i q) = 1 + t_i q^2$, and hence
$$q^{194}\,P(t) \;=\; \prod_{i=1}^{194}\bigl(1 + t_i q^{2}\bigr). \tag{2.2}$$

---

## 3. Newton identities and the third coefficient

For a finite family $(g_i)_{i \in s}$ of power series with $g_i(0) = 1$, the
low-degree coefficients of $\prod_i g_i$ are universal polynomials in the
coefficients of the factors. Level $1$ and level $2$ are classical:
$$[q^1]\prod_i g_i = \sum_i [q^1]g_i, \qquad
[q^2]\prod_i g_i = \sum_i [q^2]g_i + e_2\bigl([q^1]g_i\bigr),$$
where $e_2(a) = \tfrac12\bigl((\sum a_i)^2 - \sum a_i^2\bigr)$. Level $3$
requires a little more care, and — since we wish to remain in a division-free
setting valid over any commutative ring — we clear denominators.

**Theorem 3.1 (Newton identity at level 3).** Let $s$ be a finite index set and
$g_i$ power series with $[q^0]g_i = 1$ for all $i \in s$. Write
$a_r^{(i)} = [q^r]g_i$ and $p_r = \sum_{i\in s}(a_1^{(i)})^r$. Then
$$6\,[q^3]\prod_{i \in s} g_i \;=\; 6\sum_i a_3^{(i)}
\;+\; 6\Bigl[\Bigl(\sum_i a_1^{(i)}\Bigr)\Bigl(\sum_i a_2^{(i)}\Bigr) - \sum_i a_1^{(i)}a_2^{(i)}\Bigr]
\;+\; \bigl(p_1^{3} - 3p_1p_2 + 2p_3\bigr).$$

*Proof sketch.* Induct on $s$. For the empty family both sides vanish. For the
step $s \mapsto s \cup \{a\}$, expand the cubic coefficient of a binary product,
$$[q^3](AB) = A_0B_3 + A_1B_2 + A_2B_1 + A_3B_0,$$
with $A = g_a$ and $B = \prod_{i \in s} g_i$; substitute $A_0 = B_0 = 1$, the
level-$1$ identity $B_1 = \sum_{i \in s} a_1^{(i)}$, the level-$2$ identity for
$B_2$, and the inductive hypothesis for $B_3$. What remains is a polynomial
identity in the coefficients, verified by expanding both sides; concretely, the
difference of the two sides is
$3\,a_1^{(a)}\cdot(\text{level-2 identity})$, so the step closes as a linear
combination of the two previously established identities. $\square$

The bracketed term is the "mixed" second elementary symmetric expression in the
pairs $(a_1^{(i)}, a_2^{(i)})$, and $\tfrac16(p_1^3 - 3p_1p_2 + 2p_3) = e_3(a_1)$
is Newton's expression for the third elementary symmetric function in terms of
power sums.

Combining Theorem 3.1 with the bridge (2.1) gives the Laurent statement.

**Theorem 3.2 (third Laurent coefficient of a normalized product).** Let
$f_1,\dots,f_m$ be normalized Laurent series with non-negative coefficients
$a_r^{(i)} = [q^r]f_i$. Then, with $p_r = \sum_i (a_0^{(i)})^r$,
$$6\,[q^{\,3-m}]\prod_{i=1}^m f_i \;=\; 6\sum_i a_2^{(i)}
+ 6\Bigl[\Bigl(\sum_i a_0^{(i)}\Bigr)\Bigl(\sum_i a_1^{(i)}\Bigr) - \sum_i a_0^{(i)}a_1^{(i)}\Bigr]
+ \bigl(p_1^3 - 3p_1p_2 + 2p_3\bigr).$$

*Proof.* Apply (2.1) with $k = 3$ and Theorem 3.1 to the factors
$\widehat{f_i}$, noting $[q^{r+1}]\widehat{f_i} = a_r^{(i)}$. $\square$

**Corollary 3.3 (level 2).** Under the same hypotheses,
$$[q^{\,2-m}]\prod_i f_i = \sum_i a_1^{(i)} + e_2\bigl(a_0^{(i)}\bigr).$$

**Theorem 3.4 (McKay–Thompson normalization kills the corrections).** If in
addition $a_0^{(i)} = c_i(0) = 0$ for every $i$ — as McKay–Thompson
normalization demands — then all power sums $p_r$ and all mixed terms vanish,
and for $m = 194$,
$$[q^{-192}]\prod_{i=1}^{194} T_{c_i} = \sum_{i} c_i(1),
\qquad
[q^{-191}]\prod_{i=1}^{194} T_{c_i} = \sum_{i} c_i(2).$$

Thus the two Laurent coefficients immediately above the pole are exactly the
column sums of the first two columns of the head table.

---

## 4. The reduction to a decidable integer equation

**Theorem 4.1 (reduction, coefficient form).** For every integral head table
$t : \{1,\dots,194\} \to \mathbb{Z}$,
$$[q^{-192}]\,P(t) \;=\; \Bigl(\sum_{i=1}^{194} t_i\Bigr)\cdot 1_{\mathbb{C}},$$
the integer $\sum_i t_i$ viewed in $\mathbb{C}$.

*Proof.* The head series have vanishing constant coefficients, so Theorem 3.4
applies with $c_i(1) = t_i$. $\square$

**Theorem 4.2 (the head statement is finite arithmetic).** For every integral
head table $t$ and every $S \in \mathbb{Z}$,
$$[q^{-192}]\,P(t) = S \quad\Longleftrightarrow\quad \sum_{i=1}^{194} t_i = S.$$

*Proof.* Theorem 4.1 and injectivity of $\mathbb{Z} \hookrightarrow \mathbb{C}$.
$\square$

The right-hand side is a comparison of two integers: given the table, it is
decided by $193$ additions. The transcendental-looking left-hand side has been
eliminated *without* weakening the statement — the implication runs both ways.

An identical argument at the next level, using Theorem 3.4, gives:

**Theorem 4.3 (level-3 reduction).** For integral $t$ and $S \in \mathbb{Z}$,
the degree-$(-191)$ coefficient of the $194$-fold product built from the trace
series $q^{-1} + t_i q^2$ equals $S$ if and only if $\sum_i t_i = S$.

### 4.1 A verified instance

The reduction is only useful if entries of the table are *known* rather than
assumed. Section 7 derives $c_{1A}(1) = 196884$ from the defining identity
$j = E_4^3/\Delta$ with no external data. Combining it with an illustrative
table whose remaining $193$ entries are the placeholder value $1$ (the value
$c_g(1)$ would take at a class with $\chi_{196883}(g) = 0$) yields the check
$$\sum_i t_i = 196884 + 193 = 197077, \qquad\text{hence}\qquad
[q^{-192}]P(t) = 197077,$$
an equality between an infinite Laurent product and an integer, settled by
addition. The point is methodological: after the reduction, only the table
itself remains, entry by entry.

---

## 5. Vieta for the moonshine product

The reduction uses one Laurent coefficient. The full product carries a whole
spectrum of them, and they are exactly the elementary symmetric functions of the
table.

**Definition 5.1.** For $0 \le k \le 194$ the *$k$-th symmetric invariant* of a
head table $t$ is
$$e_k(t) \;=\; \sum_{\substack{T \subseteq \{1,\dots,194\}\\ |T| = k}} \;\prod_{i \in T} t_i \;\in\; \mathbb{Z},$$
with $e_0(t) = 1$ and $e_k(t) = 0$ for $k > 194$.

**Lemma 5.2 (expansion of $\prod(1 + a_i q^2)$).** For any finite family
$(a_i)_{i \in I}$ in a commutative ring and any $k \ge 0$,
$$[q^{2k}]\prod_{i \in I}\bigl(1 + a_i q^{2}\bigr) \;=\; \sum_{\substack{T \subseteq I \\ |T| = k}} \prod_{i \in T} a_i,$$
and all odd-degree coefficients vanish.

*Proof.* Expand the product over subsets: distributing
$\prod_i (a_i q^2 + 1)$ gives $\sum_{T \subseteq I} \bigl(\prod_{i\in T} a_i\bigr) q^{2|T|}$.
Extracting the coefficient of $q^{2k}$ keeps exactly the subsets of size $k$.
$\square$

**Theorem 5.3 (Vieta for the head product).** For every integral head table $t$
and every $k \ge 0$,
$$[q^{\,2k-194}]\,P(t) \;=\; e_k(t).$$

*Proof.* By Lemma 2.6, $q^{194}P(t) = \prod_i (1 + t_i q^2)$; extract the
coefficient of $q^{2k}$ using Lemma 5.2 and shift degrees by $194$. $\square$

**Corollary 5.4 (exact pole order).** $[q^{-194}]P(t) = e_0(t) = 1$: the pole has
order exactly $194$ and the product is monic there. No cancellation can occur,
whatever the table.

**Corollary 5.5.** $k = 1$ recovers Theorem 4.1: $[q^{-192}]P(t) = \sum_i t_i$.

**Corollary 5.6 (odd degrees vanish).** For head-normalized data all Laurent
coefficients in odd degrees relative to the pole vanish; the product is an even
series in $q$ after multiplication by $q^{194}$.

Theorem 5.3 thus turns an infinite family of analytic-looking quantities into a
single finite algebraic object: the generating polynomial
$$\Phi_t(X) \;=\; \prod_{i=1}^{194}\bigl(X + t_i\bigr) \;=\; \sum_{k=0}^{194} e_k(t)\,X^{194-k}. \tag{5.1}$$

---

## 6. Rigidity: the product is a complete invariant

We now show that no information about the table is lost in passing to the
product. Write $\mathcal{M}(t)$ for the multiset $\{\!\{t_1, \dots, t_{194}\}\!\}$.

**Lemma 6.1 (permutation invariance).** If $\mathcal{M}(t) = \mathcal{M}(u)$ then
$P(t) = P(u)$.

*Proof.* The head product is the product of the multiset image of $t$ under
$x \mapsto q^{-1} + xq$; equal multisets have equal images, and the product of a
multiset does not depend on any ordering. $\square$

**Lemma 6.2 (equal products force equal invariants).** If $P(t) = P(u)$ then
$e_k(t) = e_k(u)$ for every $k$.

*Proof.* Apply $[q^{2k-194}](-)$ to both sides and use Theorem 5.3; the
resulting equality of complex numbers is an equality of integers. $\square$

**Lemma 6.3 (Vieta for $\Phi_t$).** For $0 \le k \le 194$,
$$[X^{k}]\,\Phi_t(X) \;=\; e_{194-k}(t),$$
and $\deg \Phi_t = 194$ with $\Phi_t$ monic.

*Proof.* Expand the product over subsets as in Lemma 5.2, with $X$ contributing
from the complementary subset. $\square$

**Lemma 6.4 (equal invariants force equal multisets).** If $e_k(t) = e_k(u)$ for
all $k$, then $\mathcal{M}(t) = \mathcal{M}(u)$.

*Proof.* By Lemma 6.3 the polynomials $\Phi_t$ and $\Phi_u$, viewed in
$\mathbb{C}[X]$, have identical coefficients in degrees $\le 194$ and vanish
above, so $\Phi_t = \Phi_u$. Each is a product of $194$ monic linear factors, so
by unique factorization in $\mathbb{C}[X]$ its multiset of roots with
multiplicity is $\{\!\{-t_i\}\!\}$ and $\{\!\{-u_i\}\!\}$ respectively. Equality
of polynomials gives equality of root multisets; negating and using injectivity
of $\mathbb{Z} \hookrightarrow \mathbb{C}$ yields
$\mathcal{M}(t) = \mathcal{M}(u)$. $\square$

**Theorem 6.5 (rigidity of the head table).** For integral head tables $t, u$,
$$P(t) = P(u) \quad\Longleftrightarrow\quad \mathcal{M}(t) = \mathcal{M}(u).$$

*Proof.* ($\Leftarrow$) Lemma 6.1. ($\Rightarrow$) Lemma 6.2 followed by
Lemma 6.4. $\square$

Theorem 6.5 says the map $t \mapsto P(t)$ is injective on multisets: the
$194$-fold product is a **complete invariant** of the head table up to
relabelling. Since the product is symmetric in its factors, no finer statement
is possible. In particular the reduction of Section 4 is not a lossy shadow of
the analytic statement; the analytic object and the finite table carry exactly
the same information.

**Corollary 6.6 (separation by the finite check).** If $\sum_i t_i \ne \sum_i u_i$
then $P(t) \ne P(u)$.

*Proof.* Contrapositive of Lemma 6.2 at $k=1$, since
$e_1(t) = \sum_i t_i$. $\square$

This is the form used in practice: a candidate table that is perturbed in a way
that changes the sum is detected already by the single coefficient in degree
$-192$; a perturbation preserving the sum but changing the multiset is detected
by some higher $e_k$, by Theorem 6.5.

**Corollary 6.7 (decidability).** Equality of two $194$-fold McKay–Thompson head
products is a decidable relation: by Theorem 6.5 it is equivalent to equality of
two multisets of $194$ integers, decided in $O(n\log n)$ time by sorting.

Corollary 6.7 deserves emphasis. A priori, $P(t) = P(u)$ is an equality of two
formal Laurent series, i.e. an infinite family of equalities of complex numbers.
Rigidity collapses it to a finite combinatorial test.

**Remark 6.8 (why $q^2$ and not $q$).** The proof works because the head series
has a *vanishing constant term*: $\widehat{T^{(i)}} = 1 + t_i q^2$ is a
polynomial in $q^2$ of degree $1$, so the product is precisely a specialization
of the generic polynomial $\prod(1 + t_i Y)$ at $Y = q^2$. Had the constant
terms $c_g(0)$ been non-zero, the coefficients would mix two columns of the
table (as visible in Theorem 3.2) and the clean Vieta statement would fail.
McKay–Thompson normalization is exactly what makes the head layer rigid.

---

## 7. Deriving the identity-class entry from first principles

A finite check needs verified inputs. We show that at least one entry — the one
McKay noticed — is obtainable by pure formal algebra over $\mathbb{Z}$, with no
analysis, no convergence and no division.

### 7.1 Setting

Work in $\mathbb{Z}[[q]]$. Define
$$E_4 \;=\; 1 + 240\sum_{n \ge 1}\sigma_3(n)\,q^{n},
\qquad \sigma_3(n) = \sum_{d \mid n} d^3,$$
and for $m \in \mathbb{N}$ the *truncated eta product*
$$D_m \;=\; \prod_{k=1}^{m}\bigl(1 - q^{k}\bigr)^{24},$$
so that the discriminant form is $\Delta = q\,D_\infty$ and $j = E_4^3/\Delta$.
Equivalently, $q\,j$ is the solution $f$ of $D_\infty \cdot f = E_4^3$.

### 7.2 Congruence calculus

For $N \in \mathbb{N}$ write $f \equiv g \pmod{q^N}$ when $[q^n]f = [q^n]g$ for
all $n < N$.

**Lemma 7.1.** $f \equiv g \pmod{q^N}$ if and only if $q^N \mid f - g$ in
$\mathbb{Z}[[q]]$. Consequently the relation is an equivalence relation
compatible with addition, multiplication and powers, and one may cancel a factor
that is a unit of $\mathbb{Z}[[q]]$.

*Proof.* Divisibility by $q^N$ is exactly vanishing of the coefficients below
degree $N$. Compatibility with products follows from
$fg - f'g' = f(g - g') + g'(f - f')$; cancellation by a unit $u$ follows from
$f - g = u^{-1}\bigl(u(f-g)\bigr)$. $\square$

**Lemma 7.2 (unit-ness).** $[q^0]D_m = 1$, hence $D_m$ is a unit of
$\mathbb{Z}[[q]]$.

*Proof.* A power series over a commutative ring is invertible iff its constant
term is; each factor $(1-q^k)^{24}$ with $k \ge 1$ has constant term $1$.
$\square$

**Lemma 7.3 (invisibility of late factors).** If $N \le k$ then
$(1-q^k)^{24} \equiv 1 \pmod{q^N}$.

*Proof.* $(1-q^k) - 1 = -q^k$ divides $(1-q^k)^{24} - 1$, and
$q^N \mid q^k$. $\square$

**Theorem 7.4 (truncation stability).** If $N \le m+1$ and $N \le m'+1$ then
$D_m \equiv D_{m'} \pmod{q^N}$.

*Proof.* By Lemma 7.3 and $D_{m+1} = D_m(1-q^{m+1})^{24}$, passing from $D_{m+1}$
to $D_m$ does not change coefficients below degree $N$ once $m+1 \ge N$; induct
down to the common value $D_{N-1}$. $\square$

Theorem 7.4 is what makes the *infinite* eta product well defined coefficientwise
without any convergence theory: the coefficient of $q^n$ stabilizes as soon as
the cut-off exceeds $n$.

### 7.3 Integrality and uniqueness

**Theorem 7.5 (unique integral quotient).** For every $m$ there is a unique
$f \in \mathbb{Z}[[q]]$ with $D_m \cdot f = E_4^3$, namely $f = D_m^{-1}E_4^3$.
Its coefficients are integers, and by Theorem 7.4 they are independent of $m$
below degree $m+1$.

Thus the integrality of the $j$-coefficients is a triviality of formal algebra —
the eta product is a unit — rather than a theorem about modular forms.

**Theorem 7.6 (window uniqueness).** Let $N \le m+1$ and $N \le m'+1$. If
$E_4^3 \equiv D_m f$ and $E_4^3 \equiv D_{m'} g \pmod {q^N}$, then
$f \equiv g \pmod{q^N}$.

*Proof.* Combine $D_m f \equiv D_{m'} g$ with Theorem 7.4 to get
$D_m f \equiv D_m g$, then cancel the unit $D_m$ (Lemma 7.1). $\square$

### 7.4 The verified window

Finite convolution of integer coefficient lists establishes the truncated
identity
$$E_4^{3} \;\equiv\; D_{11}\cdot\bigl(1 + 744q + 196884q^{2} + 21493760q^{3} + 864299970q^{4} + 20245856256q^{5}$$
$$+\; 333202640600q^{6} + 4252023300096q^{7} + 44656994071935q^{8} + 401490886656000q^{9}$$
$$+\; 3176440229784420q^{10} + 22567393309593600q^{11}\bigr) \pmod{q^{12}}. \tag{7.1}$$

By Theorem 7.6, *every* solution $f$ of $D_m f = E_4^3$ with $m \ge 11$ has
exactly these twelve coefficients. Since $q\,j$ is such a solution, we obtain
$$j \;=\; q^{-1} + 744 + 196884\,q + 21493760\,q^{2} + \cdots + 22567393309593600\,q^{10} + O(q^{11}),$$
and in particular:

**Theorem 7.7 (identity-class head entry).** $c_{1A}(1) = [q^1](j - 744) = 196884$,
and McKay's identity $196884 = 1 + 196883$ holds on this derived value.

The same computation identifies the coefficients of $D_m$ below degree $12$ with
the Ramanujan tau values.

**Theorem 7.8 (tau values).** For $m \ge 11$ and $1 \le n \le 12$,
$[q^{n-1}]D_m = \tau(n)$, with
$$(\tau(1),\dots,\tau(12)) = (1,\,-24,\,252,\,-1472,\,4830,\,-6048,\,-16744,\,84480,\,-113643,\,-115920,\,534612,\,-370944).$$

On these *derived* numbers the classical structural facts can be observed rather
than quoted:

**Proposition 7.9 (Hecke relations).** $\tau(2)\tau(3) = \tau(6)$,
$\tau(2)\tau(5) = \tau(10)$, $\tau(3)\tau(4) = \tau(12)$,
$\tau(4) = \tau(2)^2 - 2^{11}$, $\tau(9) = \tau(3)^2 - 3^{11}$, and
$\tau(8) = \tau(2)\tau(4) - 2^{11}\tau(2)$.

**Proposition 7.10 (Ramanujan's congruence).**
$\tau(n) \equiv \sigma_{11}(n) \pmod{691}$ for $1 \le n \le 12$.

**Proposition 7.11 (Lehmer window).** $\tau(n) \ne 0$ for $1 \le n \le 12$ — the
first window of Lehmer's open conjecture that $\tau$ never vanishes.

**Proposition 7.12 (McKay decompositions).** With $d_1 = 1$, $d_2 = 196883$,
$d_3 = 21296876$, $d_4 = 842609326$, $d_5 = 19360062527$,
$d_6 = 293553734298$ the dimensions of the smallest irreducible representations
of the Monster, the derived coefficients $c(n) = [q^n]\,(j - 744)$ satisfy
$$c(1) = d_1 + d_2,\qquad c(2) = d_1 + d_2 + d_3,\qquad c(3) = 2d_1 + 2d_2 + d_3 + d_4,$$
$$c(4) = 2d_1 + 3d_2 + 2d_3 + d_4 + d_5,\qquad
c(5) = 3d_1 + 5d_2 + 4d_3 + d_4 + 2d_5 + d_6.$$

These are the numerical shadow of the graded moonshine module.

---

## 8. A priori bounds on the finite check

Moonshine predicts $c_g(1) = 1 + \chi(g)$ for the $196883$-dimensional
irreducible character $\chi$. Since $|\chi(g)| \le \chi(1) = 196883$ for every
$g$, we get an unconditional constraint on the value of the finite check under
that prediction.

**Theorem 8.1 (bound).** Let $t$ be an integral head table and $B \ge 0$ with
$|t_i - 1| \le B$ for all $i$. Then
$$\Bigl|\sum_{i=1}^{194} t_i - 194\Bigr| \;\le\; 194\,B.$$

*Proof.* $\sum_i t_i - 194 = \sum_i (t_i - 1)$; apply the triangle inequality
and bound each term by $B$. $\square$

**Corollary 8.2 (moonshine interval).** With $B = 196883$,
$$194 - 38195302 \;\le\; \sum_i t_i \;\le\; 194 + 38195302,$$
i.e. the check must land in $[-38195108,\,38195496]$. A proposed table outside
that interval is refuted with no modular input whatsoever.

**Remark 8.3 (extremality of the identity class).** The derived entry satisfies
$|c_{1A}(1) - 1| = 196883$, exactly the extreme permitted by Theorem 8.1. This
is the numerical fingerprint of $\chi$ attaining its maximum modulus at the
identity, i.e. of $1A$ being the identity class.

---

## 9. Algorithms

Three computational procedures underlie the results.

**A. Truncated series arithmetic over $\mathbb{Z}$.** Represent a series modulo
$q^N$ by a list of $N$ integers; multiply by Cauchy convolution
$(a \ast b)_n = \sum_{k=0}^{n} a_k b_{n-k}$, at cost $O(N^2)$ per product. The
eta product $D_m$ modulo $q^N$ costs $O(mN^2)$ naively, but Lemma 7.3 lets one
stop at $m = N-1$, and each factor $(1-q^k)^{24}$ can be raised by repeated
squaring in $O(N^2\log 24)$. The whole twelve-term verification of (7.1) is a
few thousand integer multiplications.

**B. Symmetric invariants of the head table.** Compute all $e_k(t)$ for
$0 \le k \le 194$ by the standard incremental recursion: start from the
polynomial $1$ and multiply successively by $(1 + t_i Y)$, i.e.
$e_k \leftarrow e_k + t_i e_{k-1}$ scanning $k$ downwards. Cost $O(n^2)$
multiplications of big integers for $n = 194$ entries — and by Theorem 5.3 the
resulting vector *is* the list of Laurent coefficients of the moonshine product
in degrees $-194, -192, \dots, 194$.

**C. Deciding equality of two Monster-sized products.** By Theorem 6.5, sort
both tables and compare, $O(n\log n)$. Equivalently, compare the $e_k$ vectors
produced by algorithm B: by Lemma 6.4 the two tests are equivalent, and the
sorting test is asymptotically cheaper.

---

## 10. Discussion

### 10.1 What has been achieved

The head layer of Monstrous Moonshine — the layer McKay actually observed — is,
after the reduction, a statement about $194$ integers. Three features make this
more than bookkeeping.

*Equivalence, not implication.* Theorem 4.2 is an "if and only if". The finite
equation is not a necessary condition extracted from a richer statement; it is
the statement.

*Completeness.* Theorem 6.5 shows the product is a complete invariant of the
table up to permutation, so the reduction cannot be fooled by a rearranged or
perturbed table. Any wrong table is separated from the right one by some
Laurent coefficient, and a wrong *sum* is separated already by the first one.

*Derivability of the input.* Section 7 shows that at least one entry can be
produced rather than assumed, using only the unit-ness of the eta product and a
congruence calculus modulo $q^N$. This makes precise what "checking the head
table" would cost in full: $194$ independent computations of the same kind.

### 10.2 Limitations

The results concern the head layer only. Moonshine proper — the genus-zero
property, the modularity of every $T_g$, the existence and structure of the
graded module — is far beyond a finite check; it was established by Borcherds in
1992. Furthermore, the reduction takes the head table as input data; nothing
here derives the $193$ non-identity entries, which require either the Monster's
character table or a per-class modular computation. Finally, the head series
used in Sections 5–6 truncate $T_g$ after the $c_g(1)$ term. That truncation is
faithful for the head layer (Theorem 3.4 shows the degree-$(-192)$ coefficient
of the full product depends only on the columns $c_g(0)$ and $c_g(1)$), but the
Vieta description of *all* coefficients in Theorem 5.3 is a statement about the
truncated product, not about $\prod_g T_g$ in its entirety.

### 10.3 Relation to symmetric function theory

The mathematical content of Sections 5–6 is a specialization of the fundamental
theorem of symmetric functions: a multiset of $n$ numbers in an integral domain
is determined by its elementary symmetric functions. What is added is the
*dictionary*: for McKay–Thompson-normalized series the symmetric functions are
literally Laurent coefficients of a product, in degrees $2k - n$. The dictionary
is what turns an analytic question into a combinatorial one, and Remark 6.8
identifies exactly which normalization makes it work.

---

## 11. Future directions

**D1. Certificates for the full head table.** Conjecturally every head
coefficient $c_g(1)$ is computable by the same eta-product mechanism used here
for the identity class: for each of the $194$ classes there should be an eta
quotient $\prod_d \eta(d\tau)^{r_d}$ (plus an explicit additive constant) whose
$q$-expansion, truncated at $q^8$, has $q$-coefficient $c_g(1)$, with the
truncated identity checkable by finite integer arithmetic. The key point is that
the mechanism never needs modularity: an eta quotient is a unit times a power of
$q$ in $\mathbb{Z}[[q]]$, so its coefficients are forced by pure formal algebra,
exactly as the identity-class entry is forced here. The machinery in Section 7 —
the congruence calculus, truncation stability, unit cancellation — is parametric
in the exponent vector; only the exponent data per class is missing. A natural
test is to discharge one non-identity class, say $2A$, end to end, then loop. If
the conjecture holds, the entire $194$-entry table becomes derived data and the
head statement becomes a single arithmetic evaluation; if some class admits no
eta-quotient generator, the failing classes isolate exactly where genuinely
modular input is unavoidable.

**D2. The symmetric-function spectrum.** Theorem 5.3 identifies the Laurent
coefficients of the product in degrees $2k-194$ with the symmetric invariants
$e_k$ of the head table. Conjecturally these are non-zero for every
$k \le 194$, and the normalized sequence $|e_k|$ is strictly log-concave in $k$.
The point is that Vieta turns an analytic-looking question about a Laurent
expansion into Newton's inequalities for a $194$-element multiset of integers:
since $\Phi_t(X) = \prod_g (X + c_g(1))$ has all roots real by construction,
Newton's inequality $e_{k-1}e_{k+1} \le e_k^2$ (after normalization by binomial
coefficients) and Maclaurin's inequality apply. What remains is a finite
real-rootedness computation on the table itself.

**D3. Deeper Laurent layers.** Theorem 3.2 computes the coefficient in degree
$3-m$ of a product of $m$ arbitrary normalized series. The analogous universal
polynomial in degree $r-m$ involves the $r$-th complete Newton expression in the
first $r$ columns of the table. Making the pattern uniform in $r$ — a
division-free Newton identity at all levels, with McKay–Thompson normalization
collapsing it to $\sum_g c_g(r-1)$ — would extend the reduction from the head
layer to any fixed depth.

**D4. Sharper separation.** Corollary 6.6 separates tables by their sums.
Quantifying rigidity — how many coefficients of the product must be inspected to
distinguish two tables differing in exactly one entry by exactly one — would give
an effective, minimal certificate for the check.

---

## 12. Summary of results

| Statement | Content |
|---|---|
| Pole order | The $194$-fold product has a pole of order exactly $194$ with leading coefficient $1$. |
| Reduction | $[q^{-192}]P(t) = \sum_g c_g(1)$; the Laurent statement is *equivalent* to a decidable integer equation. |
| Level 3 | $[q^{-191}]$ of the full product is $\sum_g c_g(2)$, via a division-free Newton identity $6e_3 = p_1^3 - 3p_1p_2 + 2p_3$. |
| Vieta | $[q^{2k-194}]P(t) = e_k\bigl(c_g(1)\bigr)$ for all $k$. |
| Rigidity | $P(t) = P(u)$ iff the tables agree as multisets: the product is a complete invariant. |
| Decidability | Equality of two Monster-sized products reduces to comparing two multisets of $194$ integers. |
| Separation | Different table sums already give different products. |
| Identity entry | $c_{1A}(1) = 196884$ is forced by $E_4^3 = \Delta\, j$ using formal power series over $\mathbb{Z}$ alone. |
| Tau data | $\tau(1),\dots,\tau(12)$, with Hecke relations, Ramanujan's congruence mod $691$, and non-vanishing in that window. |
| Bound | $\bigl|\sum_g c_g(1) - 194\bigr| \le 194 \cdot 196883 = 38195302$ under moonshine's character prediction. |
