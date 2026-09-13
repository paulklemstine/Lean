# Genuinely Dependent Fibre Families of One-Variable Tropical Polynomials

**Author:** Aristotle
**Date:** 2026-09-13

---

## Abstract

Let $p(x) = \min_{0 \le i \le n}(c_i + i x)$ be the min-plus (tropical) polynomial of
degree $n$ with rational coefficient vector $c = (c_0, \ldots, c_n)$. Its *fibre* at a
point $x$ is the set $F_{n,c}(x) = \{ i \le n : c_i + i x = p(x)\}$ of exponents
attaining the minimum; the cardinality $|F_{n,c}(x)|$ is the local multiplicity of $p$
at $x$. We study the parametrised family of finite sets $x \mapsto F_{n,c}(x)$ and ask
whether it can be *pointwise equivalent* to a constant family, i.e. whether there can
exist a fixed finite set $T$ and a bijection $F_{n,c}(x) \simeq T$ for every $x$.

We prove that the answer is no, in the strongest possible form: for **every** degree
$n \ge 1$ and **every** coefficient vector, the fibre family is not pointwise equivalent
to a constant family. The proof is constructive — the point
$x^\star = \max_{1 \le i \le n}(c_0 - c_i)/i$ is always a corner, and $x^\star + 1$
always has a singleton fibre — and requires no genericity, convexity, or
non-degeneracy hypothesis. We then determine exactly which non-constancy patterns occur.
For every $k$ with $2 \le k \le n+1$ an explicit degree-$n$ *step polynomial* has a fibre
of cardinality $k$ alongside a fibre of cardinality $1$, and the range $k \le n+1$ is
optimal. At the structural level, a single monotone ordering law — winning exponents
decrease as the argument increases — yields the almost-disjointness of fibres, the
window bound $|F(x)| \le \mathrm{hi}(x) - \mathrm{lo}(x) + 1$, the degree bound
$\sum_{x \in S}(|F(x)| - 1) \le n$ over arbitrary finite $S$, the finiteness of the
corner set, and the bound of $n$ on the number of corners. For convex coefficient data,
specified by a nondecreasing sequence of Newton-polygon increments, we compute fibres
exactly: the fibre at $-v$ is the closed index window carrying slope $v$, so its
cardinality is one more than the number of increments equal to $v$; summing over slopes
turns the degree bound into an equality. Consequently the multiplicity profile of a
convex tropical polynomial of degree $n$ is precisely a composition of $n$, and
conversely every composition of $n$ is realised by an explicit staircase polynomial.
Finally we show that the equality form genuinely requires convexity: for
$c = (0,5,1,7)$ of degree $3$ the total multiplicity excess is $2 < 3$, the defect
counting the lattice points of the lower hull unoccupied by monomials. We contrast the
polynomial fibre family with a min-plus divisor-lattice aggregate whose argmin family
*is* constant, showing that non-constancy is a feature of crossing lines rather than of
tropicalisation as such.

**Keywords.** tropical polynomial, min-plus algebra, fibre family, local multiplicity,
Newton polygon, composition, tropical fundamental theorem, piecewise-linear optimisation.

---

## 1. Introduction

### 1.1 Tropical polynomials as lower envelopes

The min-plus semiring $(\mathbb{Q} \cup \{+\infty\}, \oplus, \odot)$ replaces addition by
minimum, $a \oplus b = \min(a,b)$, and multiplication by addition,
$a \odot b = a + b$. Its additive identity is $+\infty$ and its multiplicative identity
is $0$. A polynomial in this semiring,
$$p = \bigoplus_{i=0}^{n} c_i \odot x^{\odot i},$$
becomes, under the translation back to ordinary arithmetic, the function
$$p(x) \;=\; \min_{0 \le i \le n} \bigl(c_i + i\,x\bigr).$$
Thus a tropical polynomial of degree $n$ is the pointwise minimum of $n+1$ affine
functions whose slopes are the exponents $0, 1, \ldots, n$. It is piecewise linear and
concave, and its graph is determined by finitely many breakpoints.

This concreteness is what makes tropical geometry effective: the tropicalisation of an
algebraic object is a polyhedral shadow that retains the essential numerical invariants.
The invariant relevant here is *multiplicity*, which in the tropical world is the lattice
length of an edge of the Newton polygon.

### 1.2 The fibre family

Throughout, $n \in \mathbb{N}$ and $c : \mathbb{N} \to \mathbb{Q}$ is an arbitrary
coefficient function (only its values on $\{0, \ldots, n\}$ matter).

> **Definition 1.1 (Tropical evaluation).**
> $\displaystyle \mathrm{tv}_{n,c}(x) \;=\; \min_{0 \le i \le n} \bigl(c_i + i x\bigr)$,
> the minimum over the nonempty index range $\{0,\ldots,n\}$.

> **Definition 1.2 (Fibre).** The *fibre* of $p$ at $x \in \mathbb{Q}$ is the finite set
> of winning exponents
> $$F_{n,c}(x) \;=\; \bigl\{\, i \in \{0,1,\ldots,n\} \;:\; c_i + i x = \mathrm{tv}_{n,c}(x) \,\bigr\}.$$
> Its cardinality $|F_{n,c}(x)|$ is the *local multiplicity* of $p$ at $x$.

The map $x \mapsto F_{n,c}(x)$ is a family of finite sets indexed by the tropical line.
It is the combinatorial datum of the polynomial: away from finitely many points it is a
singleton recording which monomial is active; at the breakpoints it records how many
monomials collide.

We are interested in whether this family can be dispensed with — whether it could be
repackaged as a family that does not vary.

> **Definition 1.3 (Pointwise equivalence).** Two families $F, G : \mathbb{Q} \to
> \mathcal{P}_{\mathrm{fin}}(\mathbb{N})$ are *pointwise equivalent* if for every
> $x$ there is a bijection $F(x) \to G(x)$.

> **Definition 1.4 (Constant family).** A family $G$ is *constant* if there exists a
> finite set $T$ with $G(x) = T$ for all $x$.

> **Definition 1.5 (Genuinely dependent).** A family $F$ is *genuinely dependent* if
> there is no constant family $G$ pointwise equivalent to $F$.

Because a bijection between finite sets preserves cardinality, pointwise equivalence to a
constant family forces $|F(x)|$ to be independent of $x$. Conversely, if $|F(x)| = k$ for
all $x$ then $F$ is pointwise equivalent to the constant family with value
$\{1,\ldots,k\}$. So:

> **Lemma 1.6 (Cardinality criterion).** $F$ is genuinely dependent if and only if
> there exist $x, y$ with $|F(x)| \ne |F(y)|$.
>
> *Proof.* A bijection $F(x) \to G(x) = T$ gives $|F(x)| = |T|$ for every $x$, so
> pointwise equivalence to a constant family implies constant cardinality; the converse
> is the explicit bijection above. $\square$

The paper is organised around the following programme.

1. **Existence (§3).** Every tropical polynomial of positive degree is genuinely
   dependent, with an explicit witness pair of points.
2. **Rarity (§4).** Non-constancy is confined to at most $n$ points: a degree bound and
   a corner-count bound, both consequences of one ordering law.
3. **Realisability (§5).** Every admissible multiplicity $2 \le k \le n+1$ occurs.
4. **Exact computation (§6).** For convex coefficient data, fibres are computed exactly
   from the Newton polygon and the degree bound becomes an equality.
5. **Classification (§7).** The multiplicity profiles of convex polynomials are exactly
   the compositions of $n$.
6. **Failure of equality (§8).** A non-convex example with strict inequality, and the
   interpretation of the defect.
7. **Contrast (§9).** A tropical family that *is* constant, delimiting the phenomenon.

### 1.3 Relation to the tropical fundamental theorem

The classical statement is that a tropical polynomial of degree $n$ has exactly $n$
roots counted with multiplicity, where the roots are the breakpoints and the multiplicity
of a breakpoint is the lattice length of the corresponding Newton-polygon edge. Our
Theorem 4.6 is the inequality half of this statement, valid with no hypotheses on $c$;
Theorem 6.4 is the equality half, valid exactly in the convex regime; and §8 shows that
some hypothesis is genuinely necessary for the equality. The refinement in §7 — that all
and only compositions of $n$ arise as ordered multiplicity profiles — appears to be the
natural sharp form of the statement.

---

## 2. Basic calculus of fibres

We record the elementary facts used everywhere below.

> **Lemma 2.1 (Membership).** $i \in F_{n,c}(x)$ if and only if $i \le n$ and
> $c_i + i x \le c_j + j x$ for every $j \le n$.
>
> *Proof.* The minimum $\mathrm{tv}_{n,c}(x)$ is $\le c_i + ix$ for $i \le n$, and any
> value that is a lower bound for all monomials is $\le$ the minimum. Equality
> $c_i + ix = \mathrm{tv}_{n,c}(x)$ is therefore equivalent to $c_i + ix$ being a lower
> bound for all monomial values. $\square$

> **Lemma 2.2 (Non-emptiness).** $F_{n,c}(x) \ne \varnothing$ for every $x$; hence
> $1 \le |F_{n,c}(x)|$.
>
> *Proof.* The minimum of a nonempty finite set of rationals is attained. $\square$

> **Lemma 2.3 (Upper bound).** $|F_{n,c}(x)| \le n + 1$.
>
> *Proof.* $F_{n,c}(x) \subseteq \{0,\ldots,n\}$. $\square$

The next result is the structural engine of the entire theory.

> **Theorem 2.4 (Monotone ordering law).** Let $x < y$. If $i \in F_{n,c}(x)$ and
> $j \in F_{n,c}(y)$, then $j \le i$.
>
> *Proof.* By Lemma 2.1, $c_i + i x \le c_j + j x$ and $c_j + j y \le c_i + i y$. Adding
> and cancelling the coefficients gives $ix + jy \le jx + iy$, i.e.
> $(j - i)(y - x) \le 0$. Since $y - x > 0$ we get $j \le i$. $\square$

Geometrically this is concavity: the active slope of the lower envelope is nonincreasing
in $x$. Combinatorially it says the fibres sweep the index range monotonically from the
top down as $x$ increases. Two consequences are immediate.

> **Corollary 2.5 (Almost disjointness).** If $x \ne y$ then
> $|F_{n,c}(x) \cap F_{n,c}(y)| \le 1$.
>
> *Proof.* Say $x < y$, and let $a, b$ lie in both fibres. Applying Theorem 2.4 with
> $a \in F(y)$, $b \in F(x)$ gives $a \le b$; with the roles reversed, $b \le a$. Hence
> $a = b$. $\square$

Two distinct affine functions of $x$ agree at most once; Corollary 2.5 is the fibrewise
form of that statement.

> **Definition 2.6 (Index window).** Write
> $\mathrm{lo}(x) = \min F_{n,c}(x)$ and $\mathrm{hi}(x) = \max F_{n,c}(x)$.

> **Lemma 2.7 (Window bound).**
> $|F_{n,c}(x)| \le \mathrm{hi}(x) - \mathrm{lo}(x) + 1$, and $\mathrm{hi}(x) \le n$.
>
> *Proof.* $F_{n,c}(x) \subseteq [\mathrm{lo}(x), \mathrm{hi}(x)] \cap \mathbb{Z}$, whose
> cardinality is $\mathrm{hi}(x) - \mathrm{lo}(x) + 1$. $\square$

> **Lemma 2.8 (Windows are stacked).** If $x < y$ then
> $\mathrm{hi}(y) \le \mathrm{lo}(x)$; and if $x \le y$ then
> $\mathrm{lo}(y) \le \mathrm{hi}(x)$.
>
> *Proof.* The first is Theorem 2.4 applied to $\mathrm{lo}(x) \in F(x)$ and
> $\mathrm{hi}(y) \in F(y)$. The second follows from the first when $x < y$ (via
> $\mathrm{lo}(y) \le \mathrm{hi}(y) \le \mathrm{lo}(x) \le \mathrm{hi}(x)$) and is
> trivial when $x = y$. $\square$

So the windows of distinct points are back-to-back intervals in $\{0,\ldots,n\}$,
ordered oppositely to the points, overlapping in at most an endpoint.

---

## 3. Corners always exist

> **Theorem 3.1 (Corner existence).** Let $n \ge 1$ and let $c$ be arbitrary. Put
> $$x^\star \;=\; \max_{1 \le i \le n} \frac{c_0 - c_i}{i}.$$
> Then $|F_{n,c}(x^\star)| \ge 2$ and $F_{n,c}(x^\star + 1) = \{0\}$.
>
> *Proof.* Let $i_0 \in \{1,\ldots,n\}$ attain the maximum, so
> $x^\star = (c_0 - c_{i_0})/i_0$.
>
> *Step 1: index $0$ wins at $x^\star$.* For $1 \le i \le n$ we have
> $(c_0 - c_i)/i \le x^\star$, and $i > 0$, so $c_0 - c_i \le i x^\star$, i.e.
> $c_0 \le c_i + i x^\star$. For $i = 0$ this is trivial. By Lemma 2.1,
> $0 \in F_{n,c}(x^\star)$.
>
> *Step 2: $i_0$ also wins at $x^\star$.* Clearing the denominator in
> $x^\star = (c_0 - c_{i_0})/i_0$ gives $c_{i_0} + i_0 x^\star = c_0$. Combined with
> Step 1, the monomial value at $i_0$ equals the minimum, so
> $i_0 \in F_{n,c}(x^\star)$. Since $i_0 \ne 0$, the fibre has at least two elements.
>
> *Step 3: index $0$ wins alone at $x^\star + 1$.* For $1 \le j \le n$, Step 1 gives
> $c_0 \le c_j + j x^\star$, hence
> $c_0 < c_0 + j \le c_j + j x^\star + j = c_j + j(x^\star + 1)$,
> the strict inequality because $j \ge 1$. So index $0$ is the unique minimiser, and
> $F_{n,c}(x^\star+1) = \{0\}$. $\square$

The point $x^\star$ is the last place at which the constant monomial can still be tied or
beaten; to its right the constant monomial is the unique winner forever.

> **Theorem 3.2 (Non-constancy; main theorem, witness form).** For every $n \ge 1$ and
> every coefficient vector $c$, the family $x \mapsto F_{n,c}(x)$ is genuinely dependent:
> there is no constant family pointwise equivalent to it.
>
> *Proof.* Suppose $G(x) = T$ for all $x$ and $F_{n,c}(x) \simeq G(x)$ for all $x$. Then
> $|F_{n,c}(x)| = |T|$ for all $x$. Take $x^\star$ as in Theorem 3.1: then
> $|T| = |F_{n,c}(x^\star)| \ge 2$ and $|T| = |F_{n,c}(x^\star + 1)| = 1$, a
> contradiction. $\square$

Three features of Theorem 3.2 deserve emphasis.

* **No hypotheses on $c$.** The statement is not "the witnesses can be chosen so that two
  fibres have unequal cardinality"; it is "for every witness this already happens".
  Universality replaces a choice.
* **Constructive.** The witnesses are $x^\star$ and $x^\star + 1$, both computed from the
  coefficients by a maximum over $n$ rationals.
* **Sharp in the second coordinate.** The right-hand witness has fibre exactly $\{0\}$, so
  the two cardinalities differ by the maximum available margin for the given corner.

> **Corollary 3.3.** For $n \ge 1$ and every $c$ there exist $x,y$ with
> $|F_{n,c}(x)| \ne |F_{n,c}(y)|$; equivalently there is no $k$ with
> $|F_{n,c}(x)| = k$ for all $x$.

---

## 4. Corners are rare: the degree bound

> **Definition 4.1 (Corner set).**
> $\mathrm{Corn}(n,c) = \{ x \in \mathbb{Q} : |F_{n,c}(x)| \ge 2 \}$.

Theorem 3.1 says $\mathrm{Corn}(n,c) \ne \varnothing$ for $n \ge 1$. We now bound it.

> **Proposition 4.2 (Telescoping bound).** For every nonempty finite $S \subset
> \mathbb{Q}$, writing $a = \min S$ and $b = \max S$,
> $$\sum_{x \in S} \bigl(|F_{n,c}(x)| - 1\bigr) \;\le\; \mathrm{hi}(a) - \mathrm{lo}(b).$$
>
> *Proof.* Induction on $|S|$. If $S = \{a\}$ then $b = a$ and the claim is the window
> bound of Lemma 2.7. Otherwise let $S' = S \setminus \{a\}$, with $a' = \min S'$ and
> $b' = \max S' = b$. Then
> $$\sum_{x \in S}(|F(x)|-1) = (|F(a)|-1) + \sum_{x \in S'}(|F(x)|-1)
> \le \bigl(\mathrm{hi}(a) - \mathrm{lo}(a)\bigr) + \bigl(\mathrm{hi}(a') - \mathrm{lo}(b)\bigr),$$
> using Lemma 2.7 on $a$ and the induction hypothesis on $S'$. Since $a < a'$, Lemma 2.8
> gives $\mathrm{hi}(a') \le \mathrm{lo}(a)$, so the right-hand side is at most
> $\mathrm{hi}(a) - \mathrm{lo}(b)$. $\square$

The telescoping is the precise sense in which each corner "spends" a disjoint slice of
the index range: the windows are stacked (Lemma 2.8) and the excess at each point is at
most the length of its own window.

> **Theorem 4.3 (Degree bound).** For every $n$, every $c$, and every finite
> $S \subset \mathbb{Q}$,
> $$\sum_{x \in S} \bigl(|F_{n,c}(x)| - 1\bigr) \;\le\; n.$$
>
> *Proof.* For $S = \varnothing$ the sum is $0$. Otherwise apply Proposition 4.2 and
> $\mathrm{hi}(\min S) \le n$, $\mathrm{lo}(\max S) \ge 0$. $\square$

> **Theorem 4.4 (Finitely many corners).** $\mathrm{Corn}(n,c)$ is finite, and
> $|\mathrm{Corn}(n,c)| \le n$.
>
> *Proof.* Each $x \in \mathrm{Corn}(n,c)$ contributes $|F(x)| - 1 \ge 1$ to the sum in
> Theorem 4.3. If the corner set contained $n+1$ distinct points $t$, then taking
> $S = t$ in Theorem 4.3 would give $n + 1 \le \sum_{x \in t}(|F(x)|-1) \le n$, absurd.
> Hence the corner set has at most $n$ elements, in particular is finite. $\square$

> **Corollary 4.5 (Structure of the family).** For $n \ge 1$ the fibre family takes the
> value $1$ for all but at most $n$ points of $\mathbb{Q}$, takes a value $\ge 2$ at some
> point, and satisfies $|F(x)| \le n+1$ everywhere. It is therefore genuinely dependent
> but only finitely so.

> **Theorem 4.6 (Sharpness of the degree bound).** The bound of Theorem 4.3 is attained:
> for the totally degenerate polynomial $c \equiv 0$ we have $F_{n,c}(0) = \{0,\ldots,n\}$
> and $\sum_{x \in \{0\}}(|F(x)|-1) = n$.
>
> *Proof.* At $x = 0$ every monomial value is $c_i = 0$, so all $n+1$ indices tie. $\square$

Thus one extreme is a single corner of multiplicity $n+1$; §6 exhibits the opposite
extreme, $n$ corners each of multiplicity $2$, which saturates both Theorem 4.3 and
Theorem 4.4 simultaneously.

---

## 5. Every admissible cardinality is realised

Lemma 2.3 caps multiplicities at $n+1$; Theorem 3.1 puts a value $\ge 2$ somewhere. We
now show the whole admissible range is populated, with the simplest possible witnesses.

> **Definition 5.1 (Step polynomial).** For $k \ge 1$ let
> $$\sigma_k(i) = \begin{cases} 0, & i < k, \\ 1, & i \ge k. \end{cases}$$
> The degree-$n$ step polynomial of width $k$ is $\min_{i \le n}(\sigma_k(i) + i x)$.

Its Newton polygon has a single lower edge of lattice length $k-1$ from $(0,0)$ to
$(k-1,0)$, followed by an ascent.

> **Lemma 5.2 (Fibre at the origin).** If $1 \le k \le n+1$ then
> $F_{n,\sigma_k}(0) = \{0,1,\ldots,k-1\}$, of cardinality $k$.
>
> *Proof.* At $x = 0$ the monomial value at $i$ is $\sigma_k(i) \in \{0,1\}$. Since
> $k \ge 1$, $\sigma_k(0) = 0$, so the minimum is $0$, and $i$ attains it iff
> $\sigma_k(i) = 0$ iff $i < k$. As $k \le n+1$, all such $i$ are admissible. $\square$

> **Lemma 5.3 (Fibre at $1$).** If $k \ge 1$ then $F_{n,\sigma_k}(1) = \{0\}$.
>
> *Proof.* At $x = 1$ the monomial value at $i$ is $\sigma_k(i) + i \ge i \ge 0$, with
> value $0$ at $i = 0$. For $i \ge 1$ the value is $\ge 1 > 0$. $\square$

> **Theorem 5.4 (Dependent solutions at every nontrivial finite cardinality).** For all
> $n$ and all $k$ with $2 \le k \le n+1$ there is a degree-$n$ tropical polynomial with
> a fibre of cardinality exactly $k$ and a fibre of cardinality exactly $1$; in
> particular the two cardinalities are unequal and the family is genuinely dependent.
> The range $k \le n+1$ is optimal by Lemma 2.3.
>
> *Proof.* Take $c = \sigma_k$, $x = 0$, $y = 1$, and apply Lemmas 5.2 and 5.3. $\square$

> **Corollary 5.5 (Two distinct nontrivial multiplicities from degree $2$ on).** For
> $n \ge 2$ there are degree-$n$ polynomials $\sigma_2$ and $\sigma_3$ with
> $|F_{n,\sigma_2}(0)| = 2$, $|F_{n,\sigma_3}(0)| = 3$, and
> $|F_{n,\sigma_2}(1)| = |F_{n,\sigma_3}(1)| = 1$.

> **Corollary 5.6 (Maximal multiplicity).** $|F_{n,\sigma_{n+1}}(0)| = n+1$, and no fibre
> of any degree-$n$ polynomial exceeds $n+1$. (Note $\sigma_{n+1}$ restricted to
> $\{0,\ldots,n\}$ is the zero vector, recovering Theorem 4.6.)

Theorem 5.4 is the quantitative form of the research question: *genuinely dependent
solutions exist at every nontrivial finite cardinality the degree permits.*

---

## 6. Convex data: exact fibres from the Newton polygon

Bounds are one thing; exact computation is another. We now parametrise polynomials by
their slope increments, which is the Newton-polygon presentation.

> **Definition 6.1 (Increment presentation).** For $d : \mathbb{N} \to \mathbb{Q}$ set
> $$C_d(i) \;=\; \sum_{\ell < i} d_\ell,$$
> so that $C_d(i+1) - C_d(i) = d_i$. Call $d$ *convex* if it is nondecreasing; then
> $i \mapsto C_d(i)$ is a convex sequence and the points $(i, C_d(i))$ all lie on the
> lower convex hull, with edge slopes $d_0 \le d_1 \le \cdots$.

> **Lemma 6.2 (Telescoping identity).** For $i \le j$,
> $$\bigl(C_d(j) + j x\bigr) - \bigl(C_d(i) + i x\bigr) \;=\; \sum_{i \le \ell < j} \bigl(d_\ell + x\bigr).$$
>
> *Proof.* The coefficient difference is $\sum_{i \le \ell < j} d_\ell$ and the linear
> difference is $(j-i)x = \sum_{i \le \ell < j} x$. $\square$

Every comparison between monomials therefore reduces to comparing the increments with the
number $-x$. Write $x = -v$; then $d_\ell + x = d_\ell - v$.

> **Theorem 6.3 (Exact fibre, window form).** Let $A \le B \le n$ and $v \in \mathbb{Q}$
> satisfy
> * $d_\ell < v$ for all $\ell < A$,
> * $d_\ell = v$ for all $A \le \ell < B$,
> * $d_\ell > v$ for all $B \le \ell < n$.
>
> Then $F_{n, C_d}(-v) = \{A, A+1, \ldots, B\}$, and hence
> $|F_{n,C_d}(-v)| = B - A + 1$.
>
> *Proof.* Write $V(i) = C_d(i) + i(-v)$. By Lemma 6.2, for $i \le j$,
> $V(j) - V(i) = \sum_{i \le \ell < j}(d_\ell - v)$.
>
> *Above $A$ the value never decreases*: for $A \le i \le n$ every term $d_\ell - v$ with
> $\ell \ge A$ is $\ge 0$, so $V(i) \ge V(A)$.
>
> *Below $A$ the value strictly decreases*: for $i < A$ the sum
> $V(A) - V(i) = \sum_{i \le \ell < A}(d_\ell - v)$ consists of strictly negative terms,
> so $V(A) < V(i)$.
>
> *On $[A,B]$ the value is constant*: for $A \le i \le B$ the terms $d_\ell - v$ with
> $A \le \ell < B$ vanish, so $V(i) = V(A)$.
>
> *Above $B$ the value strictly increases*: for $B < i \le n$ the sum
> $V(i) - V(B) = \sum_{B \le \ell < i}(d_\ell - v)$ has all terms strictly positive.
>
> Hence the minimum of $V$ is $V(A)$ and it is attained exactly on $\{A,\ldots,B\}$.
> $\square$

For convex $d$ the hypotheses of Theorem 6.3 hold automatically with
$$A = \#\{\ell < n : d_\ell < v\}, \qquad B = \#\{\ell < n : d_\ell \le v\},$$
because monotonicity makes $\{\ell < n : d_\ell < v\}$ and $\{\ell < n : d_\ell \le v\}$
initial segments of $\{0,\ldots,n-1\}$. Since $B - A = \#\{\ell < n : d_\ell = v\}$ we
obtain the central computation.

> **Theorem 6.4 (Multiplicity = slope count $+\;1$).** Let $d$ be convex. Then for every
> $v \in \mathbb{Q}$,
> $$\bigl|F_{n,C_d}(-v)\bigr| \;=\; \#\{\ell < n : d_\ell = v\} \;+\; 1.$$
>
> *Proof.* Apply Theorem 6.3 with $A, B$ as above. The hypotheses hold: for $\ell < A$,
> $d_\ell < v$ by the initial-segment description; for $A \le \ell < B$, $d_\ell \le v$
> but not $< v$, so $d_\ell = v$; for $B \le \ell < n$, $\neg(d_\ell \le v)$, so
> $d_\ell > v$. Then $|F| = B - A + 1 = \#\{\ell < n : d_\ell = v\} + 1$. $\square$

In Newton-polygon language: *the multiplicity of a corner is one more than the number of
increments (unit lattice edges) of that slope*, i.e. one more than the lattice length of
the corresponding hull edge. In particular $|F(-v)| = 1$ whenever $v$ is not one of the
slopes, confirming that corners occur only at the negatives of slopes.

> **Theorem 6.5 (Fundamental theorem, equality form for convex data).** Let $d$ be
> convex and let $\mathcal{V} = \{d_\ell : \ell < n\}$ be the set of distinct slopes.
> Then
> $$\sum_{v \in \mathcal{V}} \bigl(|F_{n,C_d}(-v)| - 1\bigr) \;=\; n.$$
>
> *Proof.* By Theorem 6.4 the $v$-th summand is $\#\{\ell < n : d_\ell = v\}$. The sets
> $\{\ell < n : d_\ell = v\}$, for $v \in \mathcal{V}$, partition $\{0,\ldots,n-1\}$, so
> the sum of their cardinalities is $n$. $\square$

> **Corollary 6.6 (Both halves).** For convex $d$: the sum over the slope corners equals
> $n$ exactly, while for *every* finite $S$ the sum is at most $n$ (Theorem 4.3). Hence
> the slope corners exhaust the corner set and no multiplicity is lost.

### 6.1 The generic polynomial

> **Definition 6.7 (Ramp polynomial).** $\rho_i = \binom{i}{2} = i(i-1)/2$; the associated
> increments are $d_\ell = \ell$, strictly increasing.

> **Lemma 6.8 (Exact difference formula).** For all $m, j \in \mathbb{N}$,
> $$\bigl(\rho_j + j(-m)\bigr) - \bigl(\rho_m + m(-m)\bigr) \;=\; \frac{(j-m)(j-m-1)}{2}.$$
>
> *Proof.* Expand: the left side is
> $\tfrac{j(j-1)}{2} - jm - \tfrac{m(m-1)}{2} + m^2$. Setting $t = j - m$, this equals
> $\tfrac{t(t-1)}{2}$ after simplification. $\square$

Since $t(t-1) \ge 0$ for every integer $t$, with equality exactly at $t \in \{0,1\}$:

> **Theorem 6.9 (Generic corners).** For $m+1 \le n$, $F_{n,\rho}(-m) = \{m, m+1\}$, of
> cardinality $2$. Consequently the ramp polynomial of degree $n$ has exactly $n$
> corners, namely $0, -1, \ldots, -(n-1)$, each simple, and
> $$\sum_{m=0}^{n-1} \bigl(|F_{n,\rho}(-m)| - 1\bigr) = n.$$
> Both the corner-count bound (Theorem 4.4) and the degree bound (Theorem 4.3) are
> attained simultaneously.
>
> *Proof.* Lemma 6.8 gives $V(j) \ge V(m)$ for all integers $j$, with equality iff
> $j \in \{m, m+1\}$; both lie in $\{0,\ldots,n\}$ when $m+1 \le n$. The corner count and
> the sum follow, the upper bound of $n$ corners coming from Theorem 4.4. $\square$

This is the exact opposite extreme to Theorem 4.6: maximum number of corners, minimum
multiplicity each, same total.

---

## 7. The composition spectrum

Read the multiplicity excesses of the corners from left to right. By Theorems 4.3 and
6.5 they form a sequence of positive integers summing to at most $n$, with equality in
the convex case. Such a sequence is a **composition** of $n$: an ordered tuple
$(m_0, \ldots, m_{r-1})$ of positive integers with $\sum_j m_j = n$. We show all
compositions arise, via an explicit construction.

> **Definition 7.1 (Staircase of a composition).** Given block sizes
> $m_0, \ldots, m_{r-1}$, set $M_j = m_0 + \cdots + m_{j-1}$ (so $M_0 = 0$ and
> $M_r = n$), and define the *staircase increment function*
> $$d^{(m)}_\ell \;=\; \#\{\, j < r \;:\; M_{j+1} \le \ell \,\},$$
> the index of the block containing position $\ell$.

> **Lemma 7.2 (Convexity and block counting).** $d^{(m)}$ is nondecreasing, and for
> $j < r$,
> $$\#\bigl\{\ell < n : d^{(m)}_\ell = j\bigr\} \;=\; m_j.$$
>
> *Proof.* Monotonicity: increasing $\ell$ can only enlarge the set being counted.
> For the count: since $M$ is nondecreasing, $d^{(m)}_\ell = j$ holds precisely when
> $M_j \le \ell < M_{j+1}$; that interval contains $M_{j+1} - M_j = m_j$ integers, all
> $< M_r = n$. $\square$

> **Theorem 7.3 (Every composition is realised).** Let $(m_0,\ldots,m_{r-1})$ be a
> composition of $n$ and let $P = C_{d^{(m)}}$ be the associated degree-$n$ convex
> tropical polynomial. Then for every $j < r$,
> $$\bigl|F_{n, P}(-j)\bigr| \;=\; m_j + 1,$$
> and $\sum_{j<r}\bigl(|F_{n,P}(-j)| - 1\bigr) = n$.
>
> *Proof.* Lemma 7.2 says $d^{(m)}$ is convex and has exactly $m_j$ positions of slope
> $j$. Theorem 6.4 at $v = j$ gives $|F(-j)| = m_j + 1$. Summing gives
> $\sum_j m_j = n$. $\square$

> **Theorem 7.4 (Composition spectrum).** A tuple of positive integers
> $(\mu_0, \ldots, \mu_{r-1})$ is the ordered multiplicity-excess profile of some convex
> degree-$n$ tropical polynomial if and only if $\mu_0 + \cdots + \mu_{r-1} = n$, i.e.
> if and only if it is a composition of $n$.
>
> *Proof.* Necessity is Theorem 6.5 (the profile of a convex polynomial sums to $n$;
> positivity holds since each listed slope actually occurs). Sufficiency is
> Theorem 7.3. $\square$

Specialisations recover earlier results:

* **All blocks of size $1$** ($r = n$, $m_j = 1$): the generic staircase, $n$ simple
  corners — Theorem 6.9 up to an affine change of the slope scale.
* **One block** ($r = 1$, $m_0 = n$): a single corner of multiplicity $n+1$ —
  Theorem 4.6.
* **Two blocks** ($r = 2$): for every $0 \le m \le n$ there is a degree-$n$ polynomial
  with exactly two corners, of multiplicities $m+1$ and $n-m+1$. Concretely, with
  increments $d_\ell = 1$ for $\ell < m$ and $d_\ell = 2$ for $\ell \ge m$, the corners
  sit at $x = -1$ and $x = -2$ with those multiplicities, and their excesses $m$ and
  $n-m$ sum to $n$. For $m = 1$ and $n \ge 3$ the two cardinalities are $2$ and $n$, so
  the two corners have different multiplicities — a second, independent proof of
  genuine dependence, this time with **both** witnesses being corners.

> **Corollary 7.5 (Prescribed unequal pair).** For every $n \ge 3$ and every
> $1 \le m \le n-1$ with $m \ne n - m$, there is a degree-$n$ tropical polynomial two of
> whose fibres have the prescribed unequal cardinalities $m+1$ and $n-m+1$.

This is the strongest form of the original question: not only are two fibres of unequal
cardinality unavoidable, but any admissible unequal pair summing correctly can be
dictated in advance.

---

## 8. Failure of equality without convexity

Theorem 6.5 required convexity. It cannot be dropped.

> **Example 8.1 (A degree-$3$ polynomial with deficient multiplicity).** Let
> $$c = (0,\,5,\,1,\,7), \qquad p(x) = \min\bigl(0,\; 5 + x,\; 1 + 2x,\; 7 + 3x\bigr).$$
>
> * At $x = -\tfrac12$: the monomial values are $0,\ 4.5,\ 0,\ 5.5$. The minimum $0$ is
>   attained at $i = 0$ and $i = 2$, so $F_3(-\tfrac12) = \{0,2\}$.
> * At $x = -6$: the values are $0,\ -1,\ -11,\ -11$. The minimum $-11$ is attained at
>   $i = 2$ and $i = 3$, so $F_3(-6) = \{2,3\}$.
> * These are the only corners. Indeed the lower envelope consists of the segment of
>   slope $0$ on $(-\infty, -\tfrac12]$ (index $0$ active), the segment of slope $2$ on
>   $[-\tfrac12, -6]$ read right-to-left (index $2$ active), and the ray of slope $3$
>   (index $3$ active); index $1$ is never active.
>
> Hence
> $$\sum_{x} \bigl(|F_3(x)| - 1\bigr) = 1 + 1 = 2 \;<\; 3 = n.$$

> **Proposition 8.2 (Interpretation of the defect).** In Example 8.1 the point $(1,5)$
> lies strictly above the segment joining $(0,0)$ and $(2,1)$, since the segment has
> height $\tfrac12$ at abscissa $1$. The monomial $i=1$ is therefore *invisible*: it is
> never the strict minimum. The hull edge from $(0,0)$ to $(2,1)$ has lattice length
> $2$, yet it supports a corner of multiplicity only $2$ (excess $1$) because its
> interior lattice point is not occupied by a monomial of the polynomial. The total
> defect $n - \sum_x (|F(x)| - 1) = 1$ equals the number of missing lattice points.

This identifies the general phenomenon: the degree bound of Theorem 4.3 is an equality
exactly when the coefficient vector is *lattice-convex*, i.e. when every lattice point of
the lower hull is occupied by a monomial that attains the hull. The convex hypothesis of
Theorem 6.5 guarantees this, because the presentation $c_i = \sum_{\ell<i} d_\ell$ with
nondecreasing $d$ puts every point $(i, c_i)$ on the hull. This is a "needs a different
hypothesis" phenomenon, not a failure of the underlying theory: the inequality remains
universally valid, and the shortfall is itself a meaningful invariant.

---

## 9. A contrasting constant family

Theorem 3.2 would be less interesting if tropicalisation always produced non-constant
families. It does not.

> **Definition 9.1 (Divisor argmin family).** Let $w : \mathbb{N} \to \mathbb{N}$ be a
> weight. For $N \ge 1$ let $D(N)$ be the set of divisors of $N$ and let
> $$A_w(N) \;=\; \{\, d \in D(N) : w(d) \le w(e) \text{ for all } e \in D(N) \,\}$$
> be the set of divisors attaining the min-plus aggregate
> $\bigoplus_{d \mid N} w(d) = \min_{d \mid N} w(d)$.

> **Theorem 9.2 (The divisor argmin family is constant).** If $w$ is strictly increasing
> then $A_w(N) = \{1\}$ for every $N \ge 1$; in particular $|A_w(N)| = 1$ for all $N$,
> so this family *is* pointwise equivalent to a constant family.
>
> *Proof.* $1 \in D(N)$ and $w(1) \le w(e)$ for every $e \ge 1$ by monotonicity, so
> $1 \in A_w(N)$. Conversely if $d \in A_w(N)$ then $w(d) \le w(1)$, and strict
> monotonicity gives $d \le 1$; since $d \ge 1$ we get $d = 1$. Every element of the
> argmin then computes the aggregate value $w(1)$. $\square$

The structural reason for the contrast is clear. The divisor lattice has a bottom element
$1$ that is a divisor of *every* $N$ and minimises a monotone weight uniformly; one
candidate dominates globally. In the polynomial setting the candidates are affine
functions of distinct slopes, and no such function dominates another on the whole line —
any two of them cross. Non-constancy of the fibre family is a consequence of the
*geometry of crossing lines*, not of min-plus algebra per se.

---

## 10. Algorithms

All results above are effective. We record the two principal algorithms.

### 10.1 Fibre evaluation

*Input:* degree $n$, coefficients $c_0,\ldots,c_n \in \mathbb{Q}$, a point $x \in
\mathbb{Q}$.
*Output:* the value $\mathrm{tv}(x)$ and the fibre $F(x)$.

Evaluate the $n+1$ numbers $v_i = c_i + i x$ in exact rational arithmetic, take the
minimum, and return all indices attaining it. Cost: $\Theta(n)$ rational operations.
Exact arithmetic is essential — with floating point, ties (which are precisely the
interesting events) are detected unreliably.

### 10.2 Corner enumeration by lower-hull scan

*Input:* degree $n$, coefficients $c_0,\ldots,c_n$.
*Output:* the full list of corners with their fibres and multiplicities.

The graph of $p$ is the lower envelope of lines with slopes $0,1,\ldots,n$; by Legendre
duality the active indices are exactly the vertices of the **lower convex hull** of the
planar point set $\{(i, c_i)\}_{i=0}^{n}$, and the corner between two consecutive hull
vertices $(i, c_i)$ and $(j, c_j)$ occurs at
$$x \;=\; -\frac{c_j - c_i}{j - i},$$
the negative of the hull-edge slope. The fibre at that corner is the set of indices lying
on that hull edge (which for a lattice-convex vector is the full window
$\{i, i+1, \ldots, j\}$, and in general is the set of occupied hull points on the edge).
Because the abscissae $0,1,\ldots,n$ are already sorted, an Andrew monotone-chain scan
computes the hull in $\Theta(n)$ time and $\Theta(n)$ space, giving all corners in linear
time. Two by-products drop out for free:

* the total multiplicity excess $\sum_x (|F(x)| - 1)$, whose comparison with $n$ detects
  the lattice-convexity defect of §8;
* the ordered multiplicity profile, i.e. the composition realised by $c$ when it is
  lattice-convex.

Correctness follows from Theorem 6.3 applied edge by edge, and from the observation that
the envelope's breakpoints are exactly the negatives of the distinct hull-edge slopes.

### 10.3 Composition realisation

*Input:* a composition $(m_0,\ldots,m_{r-1})$ of $n$.
*Output:* coefficients realising it as a multiplicity profile.

Compute the prefix sums $M_j$, form the staircase $d^{(m)}$ of Definition 7.1 by a single
pass over $\ell = 0, \ldots, n-1$, and take prefix sums again to obtain
$c_i = \sum_{\ell<i} d^{(m)}_\ell$. Cost $\Theta(n)$. By Theorem 7.3 the resulting
polynomial has corners at $0,-1,\ldots,-(r-1)$ with multiplicities $m_j + 1$.

---

## 11. Applications and interpretation

**Parametric optimisation.** Read $i$ as an option, $c_i$ as a fixed cost, $i$ as a
sensitivity to a parameter $x$, and $p(x)$ as the optimal cost. Theorem 3.2 says a tie
between two options is unavoidable somewhere in the parameter range; Theorem 4.4 says the
ambiguous parameter values are at most $n$ in number; Theorem 2.4 says the optimal option
index is monotone in the parameter, the classical monotone-policy structure of parametric
linear programming.

**Piecewise-linear learning models.** A one-dimensional ReLU-type response is exactly a
max/min of affine functions. The fibre family is the *activation pattern*, the degree
bound caps the number of breakpoints by the number of distinct slopes, and Theorem 7.4
says any prescribed pattern of breakpoint multiplicities can be realised by choosing
biases appropriately. The defect phenomenon of §8 is the analytic shadow of *dead
units*: a unit whose affine piece never attains the envelope contributes nothing to the
breakpoint count.

**Information-theoretic Lagrangian curves.** Sweeping a Lagrange multiplier across a
finite family of affine lower bounds — as in the Lagrangian dual of a rate–distortion
problem, where each admissible channel contributes the affine function
$s \mapsto I + s\,D$ — produces exactly the min-plus envelope studied here. Its corners
are the multiplier values at which the optimising configuration switches, and the
ordering law says the optimal distortion slope is monotone in the multiplier.

**Tropical curves.** For a one-variable tropical polynomial, the corners are the roots
and the multiplicities are the lattice lengths of the Newton-polygon edges. Theorem 6.5
is the tropical fundamental theorem of algebra in this dictionary; Theorem 7.4 classifies
the possible root multiplicity data; §8 quantifies precisely how a non-lattice-convex
coefficient vector loses roots.

**Semiring faithfulness.** It is worth noting that nothing in the development is an
artefact of writing the minimum by hand: the function $\mathrm{tv}_{n,c}$ *is* the
evaluation of the polynomial $\bigoplus_{i \le n} c_i \odot x^{\odot i}$ in the min-plus
semiring, and the fibre *is* the support of that evaluation, i.e. the set of monomials
whose tropical value equals the tropical sum. In particular, at a corner at least two
distinct monomials of the tropical polynomial attain the evaluation, in the literal
semiring sense.

---

## 12. Discussion

Three themes organise the results.

**One mechanism.** The ordering law (Theorem 2.4) is the unique structural input. From it
follow almost-disjointness (2.5), the window bound (2.7), stacking (2.8), telescoping
(4.2), the degree bound (4.3), the corner-count bound (4.4), and, together with the
telescoping identity (6.2), the interval description of convex fibres (6.3). It is worth
stating what the law encodes: concavity of the lower envelope, seen through the
combinatorics of which slope is active.

**Universality, then quantification.** The original question asked whether witnesses
*can be chosen* with two fibres of unequal cardinality. The answer is stronger: no
choice is needed, since every degree-$n \ge 1$ polynomial already exhibits the
phenomenon (Theorem 3.2). Only then does the quantitative question become interesting —
which unequal pairs occur — and the answer is complete: every admissible cardinality
$2 \le k \le n+1$ (Theorem 5.4), every two-part prescription (Corollary 7.5), and indeed
every composition of the degree (Theorem 7.4).

**A false statement, corrected.** The naive guess that "the total multiplicity excess
always equals the degree" is false; Example 8.1 exhibits excess $2$ at degree $3$. The
correct universal statement is the inequality, with equality characterised by convexity
of the coefficient data. The gap is not noise — it counts the lattice points of the lower
hull that are unoccupied by monomials, which is the same as counting the monomials that
never attain the envelope.

**Scope and limitations.** The theory developed here is one-variable. Multivariable
tropical polynomials have fibre families indexed by $\mathbb{Q}^k$, where the corner set
is a polyhedral complex rather than a finite set, and the degree bound is replaced by a
statement about the mixed volumes of the Newton polytope. The ordering law has no direct
analogue: there is no total order on multivariable exponent vectors compatible with
argmin. Extending the classification of §7 beyond one variable is therefore a genuinely
different problem. Working over $\mathbb{Q}$ rather than $\mathbb{R}$ is immaterial to
every argument above except that exact corner locations are rational when the
coefficients are.

---

## 13. Future directions

*Derived from the analysis and adversarial review of the results above.*

### What survived, what failed, and why

* **Survived (universal form).** *Every* degree-$n \ge 1$ tropical polynomial, with no
  genericity or convexity assumption, has a corner and therefore a fibre family that is
  not pointwise equivalent to a constant family. The original statement ("the witnesses
  *can be chosen* with two fibres of unequal cardinality") is therefore true in a
  stronger, witness-free form: no choice is needed, all witnesses work.
* **Survived (quantitative form).** Every admissible cardinality $2 \le k \le n+1$ is
  realised, the bound $k \le n+1$ being optimal; and the pair of unequal cardinalities
  can be prescribed by any splitting of the degree.
* **Closed this cycle (composition spectrum).** Every composition of $n$ into $r$ parts
  is the multiplicity profile of an explicit degree-$n$ convex tropical polynomial — the
  staircase polynomial of the composition — and conversely every convex profile is a
  composition of $n$. The capstone statement now carries this refinement.
* **Failed as first stated.** "The total multiplicity excess equals the degree" is
  **false** without convexity: for $c = (0,5,1,7)$ the excess is $2 < 3$, because the
  monomial $i = 1$ lies strictly above the lower hull. The correct general statement is
  the inequality; equality holds exactly in the convex regime. This is a "needs a
  different hypothesis", not a "false" phenomenon.
* **Structural pattern extracted.** Every result above is controlled by one mechanism:
  the *monotone ordering law* (winning exponents decrease as the argument grows). It
  yields the window bound, the degree bound, the corner-count bound, and the interval
  description of convex fibres.

### Direction 1 — Lattice-length defect of a tropical fibre family

For a non-convex coefficient vector the corner multiplicity can be strictly smaller than
the lattice length of the corresponding Newton-polygon edge, and the total defect is
$n - \sum_x (|F(x)| - 1)$. The key insight is that the defect counts exactly the lattice
points of the lower hull that are *not* monomials of the polynomial, i.e. the failure of
the coefficient vector to be lattice-convex. Both sides of the proposed identity are
already established here — the hull-free inequality and the convex equality — so proving
the defect formula is the natural next step, and it would upgrade the inequality to an
exact accounting valid for every coefficient vector.

### Direction 2 — Stability of the profile under perturbation

The multiplicity profile is upper semicontinuous in the coefficients: a small generic
perturbation splits a corner of multiplicity $m+1$ into $m$ simple corners. Making this
quantitative — bounding the perturbation size needed to fully resolve a corner in terms
of the coefficient gaps — would give a tropical analogue of root-separation bounds.

### Direction 3 — Multivariable fibre families

Replace the tropical line by $\mathbb{Q}^k$. The corner locus becomes a polyhedral
complex dual to a regular subdivision of the Newton polytope, and the degree bound should
be replaced by a statement about the number of maximal cells. The ordering law fails, so
a new mechanism is needed; the natural candidate is the regular-subdivision duality
itself.

### Direction 4 — Algorithmic profile inversion

Given a target composition and additional constraints (integer coefficients, bounded
coefficient size, prescribed corner locations), decide realisability and produce a
witness. The staircase construction solves the unconstrained problem in linear time;
under integrality and location constraints the problem becomes a lattice-point feasibility
question whose complexity is open.

---

## 14. Summary of results

| Result | Statement | Hypotheses |
|---|---|---|
| Ordering law | $x < y \Rightarrow \max F(y) \le \min F(x)$ | none |
| Almost disjointness | $x \ne y \Rightarrow \lvert F(x) \cap F(y)\rvert \le 1$ | none |
| Multiplicity cap | $\lvert F(x)\rvert \le n+1$ | none |
| Corner existence | $\lvert F(x^\star)\rvert \ge 2$, $F(x^\star+1) = \{0\}$ | $n \ge 1$ |
| Genuine dependence | no constant family is pointwise equivalent | $n \ge 1$ |
| Degree bound | $\sum_{x \in S}(\lvert F(x)\rvert-1) \le n$ | none, $S$ finite |
| Corner count | at most $n$ corners | none |
| Realisability | some polynomial has fibres of sizes $k$ and $1$ | $2 \le k \le n+1$ |
| Convex fibres | $\lvert F(-v)\rvert = \#\{\ell < n : d_\ell = v\} + 1$ | $d$ nondecreasing |
| Equality form | $\sum_v (\lvert F(-v)\rvert-1) = n$ | $d$ nondecreasing |
| Composition spectrum | convex profiles $=$ compositions of $n$ | — |
| Strictness | excess $2 < 3$ for $c = (0,5,1,7)$ | non-convex |
| Contrast | divisor argmin family is constant | $w$ strictly increasing |
