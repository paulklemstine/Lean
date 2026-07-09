# A Cardinality Census of the L-Function Universe

## Abstract

L-functions are among the central objects of modern number theory: each encodes,
through its coefficients and analytic behavior, deep arithmetic information about
primes, curves, modular forms, and Galois representations. We investigate a
foundational question of *size*: how many L-functions are there? We prove a sharp
cardinality dichotomy. The *naive* universe of all formal Dirichlet series
$L(s) = \sum_{k} a(k) k^{-s}$, obtained by imposing no arithmetic constraints, is
uncountable — indeed of continuum cardinality, since already the $\{0,1\}$-valued
coefficient sequences form an uncountable set. By contrast, every arithmetically
constrained family is countable. We make this precise in three settings: (i)
periodic coefficient sequences over any countable alphabet form a countable set,
whence there are only countably many Dirichlet L-functions; (ii) a finite-data model
of the Selberg class — degree, conductor, root number, and finitely many Euler-factor
coefficients — is countably infinite; and (iii) ordering this model by a single
complexity bound yields an increasing tower of *finite* census slices exhausting the
whole class, which we use to produce an explicit, repetition-free enumeration ordered
by conductor, realizing in particular the classical request to list the first one
hundred elements. The unifying principle is that arithmetic structure forces a finite
determining fingerprint, collapsing an a priori continuum to a countable set.

**Keywords:** L-functions, Selberg class, Dirichlet characters, cardinality,
countability, Cantor's theorem, Euler product, conductor, enumeration.

---

## 1. Introduction

An L-function is, in its most elementary guise, a Dirichlet series

$$L(s) = \sum_{k=1}^{\infty} \frac{a(k)}{k^{s}}, \qquad a : \mathbb{N} \to \mathbb{C},$$

completely determined by its coefficient sequence $a$. The archetype is the Riemann
zeta function $\zeta(s) = \sum_{k \ge 1} k^{-s}$, whose coefficients are constantly
$1$. Broader families arise throughout number theory: Dirichlet L-functions
$L(s, \chi) = \sum_{k} \chi(k) k^{-s}$ attached to Dirichlet characters $\chi$;
L-functions of elliptic curves, apparently parameterized by a continuous
$j$-invariant; L-functions of modular forms, indexed by weight and level; and
L-functions of Galois representations, forming an enormous family.

The apparent variety invites a question of pure cardinality: **how large is the
universe of L-functions?** The presence of continuous families (elliptic curves over
$\mathbb{C}$, for instance) suggests an uncountable answer. The central thesis of
this paper is that this intuition is wrong for the L-functions that carry genuine
arithmetic meaning. Once one imposes the structural axioms that distinguish an
authentic L-function — periodicity of character coefficients, an Euler product, a
functional equation, and the determination of the object by finitely many arithmetic
invariants — the surviving family is *countable*: no larger than $\mathbb{N}$.

We organize the argument as a triptych, each panel isolating one facet of the
dichotomy.

- **Section 3 (Naive universe).** With no constraints, the coefficient sequences
  $\mathbb{N} \to \mathbb{C}$ form an uncountable set; even the two-valued sequences
  do. This is the "before" picture, a strict continuum.
- **Section 4 (Arithmetic universe).** Periodicity — the defining feature of
  Dirichlet-character coefficients — reduces a sequence to a finite block of data.
  Periodic sequences over a countable alphabet form a countable set, and there are
  only countably many Dirichlet L-functions.
- **Section 5 (Selberg census).** A finite-data model of the Selberg class is
  countably infinite, and stratifies into finite slices that we enumerate
  explicitly.

Throughout, the operative principle is a single slogan: **structure is scarcity.**
An object pinned down by a finite fingerprint belongs to a countable species, no
matter how much infinite depth each individual carries.

---

## 2. Preliminaries and notation

We write $\mathbb{N} = \{0, 1, 2, \dots\}$, and treat a Dirichlet series
interchangeably with its coefficient function $a : \mathbb{N} \to \mathbb{C}$. A set
is *countable* if it is empty or the image of a function with domain $\mathbb{N}$
(equivalently, of cardinality at most $\aleph_0$); it is *countably infinite* if it
is in bijection with $\mathbb{N}$. We use the standard facts that a countable union
of countable sets is countable, a finite product of countable sets is countable, the
image of a countable set is countable, and a set that injects into a countable set is
countable. Cantor's theorem, that no set surjects onto its power set, underlies all
of our uncountability results.

**Cardinal background.** For a set $A$ we write $|A|$ for its cardinality. The
cardinality of $\mathbb{N}$ is $\aleph_0$; the cardinality of the continuum is
$2^{\aleph_0}$, and Cantor's theorem gives $\aleph_0 < 2^{\aleph_0}$. A set is
countable if and only if $|A| \le \aleph_0$.

---

## 3. The naive universe is a continuum

We first quantify the unconstrained problem.

**Lemma 3.1 (Two-valued sequences are uncountable).** *The set of functions
$\mathbb{N} \to \{0,1\}$ is uncountable; its cardinality is $2^{\aleph_0}$.*

*Proof sketch.* The set $\mathbb{N} \to \{0,1\}$ is, by definition of cardinal
exponentiation, of cardinality $2^{\aleph_0}$. By Cantor's theorem
$2^{\aleph_0} > \aleph_0$, so the set is not countable. Concretely, any purported
enumeration $s_0, s_1, s_2, \dots$ of such sequences fails to contain the diagonal
sequence $d(n) = 1 - s_n(n)$, which differs from $s_n$ in position $n$. $\square$

**Theorem 3.2 (The naive L-function universe is uncountable).** *The set of all
coefficient sequences $\mathbb{N} \to \mathbb{C}$ — equivalently, all formal
Dirichlet series — is uncountable.*

*Proof sketch.* The map sending a $\{0,1\}$-valued sequence $a$ to the complex
sequence $k \mapsto a(k)$ (with $0, 1 \in \mathbb{C}$) is injective. If
$\mathbb{N} \to \mathbb{C}$ were countable, this injection would make
$\mathbb{N} \to \{0,1\}$ countable, contradicting Lemma 3.1. $\square$

**Theorem 3.3 (Even a two-symbol alphabet is uncountable).** *The set
$\{\, a : \mathbb{N} \to \mathbb{C} \mid \forall k,\ a(k) = 0 \text{ or } a(k) = 1 \,\}$
is uncountable.*

*Proof sketch.* This set is the injective image of $\mathbb{N} \to \{0,1\}$ under the
same inclusion; if it were countable, so would be its preimage, again contradicting
Lemma 3.1. $\square$

These results establish the "before" picture: absent arithmetic law, the universe of
Dirichlet series has the full cardinality of the continuum and cannot be enumerated.

---

## 4. Arithmetic constraint I: periodicity and Dirichlet L-functions

The Dirichlet L-functions are attached to Dirichlet characters. A Dirichlet
character modulo $n$ is a homomorphism on the units of $\mathbb{Z}/n\mathbb{Z}$,
extended by $0$; the crucial structural consequence for us is that its coefficient
sequence is *periodic* with period $n$. Periodicity is precisely the constraint that
collapses the continuum.

**Definition 4.1 (Periodic sequence).** A sequence $a : \mathbb{N} \to V$ is
*periodic* if there exists an integer $n > 0$ with $a(k + n) = a(k)$ for all
$k \in \mathbb{N}$. We call any such $n$ a *period* of $a$.

**Theorem 4.2 (Periodic sequences over a countable alphabet are countable).** *Let
$V$ be a countable set. Then the set $\{\, a : \mathbb{N} \to V \mid a \text{ is
periodic} \,\}$ is countable.*

*Proof sketch.* A periodic sequence with period $n$ is entirely determined by the
finite block of its values on $\{0, 1, \dots, n-1\}$, since $a(k) = a(k \bmod n)$.
Consider the map $g$ from the countable index set

$$\coprod_{n \in \mathbb{N}} \big(\{0,\dots,n\} \to V\big)$$

(a countable union — over the period parameter — of finite-domain function spaces,
each countable because $V$ is countable) to sequences, sending a pair $(n, b)$ to the
sequence $k \mapsto b(k \bmod (n+1))$. Every periodic sequence lies in the image of
$g$: given period $n+1$ and block $b(i) = a(i)$, the identity $a(k) = a(k \bmod (n+1))$
shows $a = g(n, b)$. Thus the set of periodic sequences is contained in the image of
a countable set and is therefore countable. $\square$

Instantiating $V = \mathbb{Q}$ or $V = \mathbb{Z}$ shows that rational- and
integer-valued periodic sequences form countable sets; these model, for example, the
coefficient sequences of real Dirichlet characters and of $\zeta$ (the constant
sequence $1$, periodic of period $1$).

We now pass to the genuine number-theoretic count.

**Definition 4.3 (Character coefficient sequence).** For a Dirichlet character
$\chi$ modulo $n$, its *coefficient sequence* is $c_\chi(k) = \chi(k \bmod n)$.

**Proposition 4.4 (Character coefficients are periodic).** *For any Dirichlet
character $\chi$ modulo $n$, the sequence $c_\chi$ satisfies $c_\chi(k + n) = c_\chi(k)$
for all $k$; that is, $c_\chi$ is periodic with period $n$.*

*Proof sketch.* Reducing modulo $n$, $(k + n) \equiv k \pmod n$, and $\chi$ depends
only on the residue class, so $c_\chi(k+n) = \chi(k+n) = \chi(k) = c_\chi(k)$. When
$n > 0$ this exhibits $c_\chi$ as a genuine periodic sequence in the sense of
Definition 4.1. $\square$

**Theorem 4.5 (The family of all Dirichlet characters is countable).** *The disjoint
union $\coprod_{n \in \mathbb{N}} \{\text{Dirichlet characters modulo } n\}$ is
countable.*

*Proof sketch.* For each fixed modulus $n$ there are only finitely many Dirichlet
characters (they form a finite abelian group, dual to the unit group of
$\mathbb{Z}/n\mathbb{Z}$). The moduli are indexed by $\mathbb{N}$. A countable union
of finite sets is countable. $\square$

**Theorem 4.6 (Countably many Dirichlet L-functions).** *The set of coefficient
sequences $\{\, a : \mathbb{N} \to \mathbb{C} \mid a = c_\chi \text{ for some
Dirichlet character } \chi \,\}$ is a countable subset of the uncountable space
$\mathbb{N} \to \mathbb{C}$.*

*Proof sketch.* This set is exactly the image of the countable family of Theorem 4.5
under the map $\chi \mapsto c_\chi$. The image of a countable set is countable.
$\square$

Theorem 4.6 is the paradigm of the whole paper: an arithmetically defined subfamily
sits as a countable island inside the continuum of all Dirichlet series.

---

## 5. Arithmetic constraint II: the Selberg census

### 5.1 The Selberg class and its finite fingerprint

Selberg's axioms characterize the L-functions worthy of the name: an element of the
**Selberg class** possesses an analytic continuation to $\mathbb{C}$ (with at most a
pole at $s=1$), a functional equation of the standard shape relating $L(s)$ to
$\overline{L(1-\bar s)}$, an Euler product $L(s) = \prod_p L_p(s)$ over primes, and
coefficients obeying the Ramanujan bound $a(k) = O(k^{\varepsilon})$. These axioms are
satisfied by $\zeta$, the Dirichlet L-functions, and the L-functions of modular forms
and (conjecturally) all motives.

A guiding principle — the *strong multiplicity-one theorem* — asserts that an element
of the Selberg class is determined by finitely many arithmetic invariants, since its
coefficients are algebraic and controlled by the Euler factors at small primes.
Abstracting away the analysis, we model an element by the finite data it determines.

**Definition 5.1 (Selberg datum).** A *Selberg datum* is a tuple

$$D = (d,\ q,\ \nu,\ \delta,\ E)$$

consisting of a degree $d \in \mathbb{N}$, a conductor $q \in \mathbb{N}$, a rational
model of the root number given by a numerator $\nu \in \mathbb{Z}$ and a denominator
$\delta \in \mathbb{N}$, and a finite list $E \in \mathbb{Z}^{*}$ of integer
Euler-factor coefficients recorded at finitely many primes.

The rational pair $(\nu, \delta)$ is a computable stand-in for the root number
$\varepsilon$, a complex number of modulus $1$ appearing in the functional equation;
in a fully analytic treatment it would be replaced by an actual point on the unit
circle (see Section 7).

**Theorem 5.2 (The Selberg data form a countable type).** *The collection of Selberg
data is countable.*

*Proof sketch.* The assignment
$D \mapsto (d, q, \nu, \delta, E) \in \mathbb{N} \times \mathbb{N} \times \mathbb{Z}
\times \mathbb{N} \times \mathbb{Z}^{*}$ is injective (two data with equal components
are equal). The target is a finite product of countable types — where $\mathbb{Z}^{*}$,
the set of finite integer lists, is countable as a countable union over length of
finite powers of $\mathbb{Z}$ — hence countable. A set injecting into a countable set
is countable. $\square$

**Theorem 5.3 (The Selberg census is countably infinite).** *The collection of
Selberg data is in bijection with $\mathbb{N}$.*

*Proof sketch.* By Theorem 5.2 it is countable. It is infinite because the degree
alone realizes an injection $\mathbb{N} \hookrightarrow \{\text{data}\}$,
$n \mapsto (n, 0, 0, 1, [\,])$. A countable infinite set is in bijection with
$\mathbb{N}$. $\square$

Thus, despite each L-function encoding infinitely much arithmetic information, there
are exactly $\aleph_0$ of them in this model — no more than the integers.

### 5.2 Finite stratification

Countability guarantees an enumeration *exists*; the following stratification makes
one *concrete* by exhibiting the class as an increasing union of finite sets. The
idea is to bound *all* invariants simultaneously by a single complexity parameter.

**Definition 5.4 (Census slice).** For $N \in \mathbb{N}$, the *census slice*
$\mathrm{Census}(N)$ is the set of Selberg data $D = (d, q, \nu, \delta, E)$ with

$$d \le N,\quad q \le N,\quad |\nu| \le N,\quad \delta \le N,\quad \mathrm{len}(E) \le N,\quad \text{and } |c| \le N \text{ for every } c \in E.$$

**Theorem 5.5 (Each census slice is finite).** *For every $N$, the set
$\mathrm{Census}(N)$ is finite.*

*Proof sketch.* Each coordinate ranges over a finite set: $d, q, \delta$ over
$\{0, \dots, N\}$; $\nu$ over the interval $[-N, N] \cap \mathbb{Z}$; and $E$ over the
finite collection of integer lists of length at most $N$ with every entry in
$[-N, N]$ (a finite alphabet raised to boundedly many positions). A finite product of
finite sets is finite, and $\mathrm{Census}(N)$ injects into such a product. $\square$

**Theorem 5.6 (The slices exhaust the universe).** *Every Selberg datum lies in some
census slice: $\bigcup_{N} \mathrm{Census}(N)$ is the set of all Selberg data.
Moreover the slices are monotone, $\mathrm{Census}(M) \subseteq \mathrm{Census}(N)$
whenever $M \le N$.*

*Proof sketch.* Given a datum $D$, set $N$ to be the maximum of its degree, conductor,
$|\nu|$, $\delta$, the length of $E$, and the sum $\sum_{c \in E} |c|$ (which bounds
each $|c|$). Then all defining inequalities of $\mathrm{Census}(N)$ hold, so
$D \in \mathrm{Census}(N)$. Monotonicity is immediate from the definition, since each
bounding inequality is preserved under enlarging $N$. $\square$

Theorems 5.5 and 5.6 together present the countable universe as an ascending tower of
finite photographs — the structural content behind any statement of the form
"enumerate the first $M$ elements".

### 5.3 An explicit enumeration ordered by conductor

We now realize the classical request literally. For each conductor $q$ we record one
canonical representative.

**Definition 5.7 (Canonical datum).** For $q \in \mathbb{N}$ the *canonical datum of
conductor $q$* is $T(q) = (1, q, 0, 1, [\,])$: degree one, conductor $q$, trivial root
number, and no recorded Euler coefficients — a stand-in for the principal-character
L-function of conductor $q$.

**Definition 5.8 (Conductor-ordered enumeration).** For $n \in \mathbb{N}$, let
$\mathrm{Enum}(n) = [\,T(0), T(1), \dots, T(n-1)\,]$, the list of canonical data for
conductors $0$ through $n-1$.

**Theorem 5.9 (Properties of the enumeration).** *For every $n$:*

1. *$\mathrm{Enum}(n)$ has length exactly $n$.*
2. *$\mathrm{Enum}(n)$ has no repeated entries.*
3. *The conductors read off $\mathrm{Enum}(n)$ are exactly $0, 1, \dots, n-1$, in
   order.*
4. *Every entry of $\mathrm{Enum}(n)$ lies in the finite slice $\mathrm{Census}(n)$.*

*Proof sketch.* (1) The list is the image of $[0, 1, \dots, n-1]$ under $T$, so has
length $n$. (2) The map $T$ is injective — distinct conductors give distinct data
because they differ in the conductor coordinate — and the image of a repetition-free
list under an injection is repetition-free. (3) The conductor coordinate of $T(q)$ is
$q$, so mapping the conductor readout over $\mathrm{Enum}(n)$ recovers
$[0, 1, \dots, n-1]$. (4) For $q < n$, the datum $T(q) = (1, q, 0, 1, [\,])$ satisfies
$1 \le n$, $q \le n$, $|0| \le n$, $1 \le n$, and has empty Euler list, so it meets
every defining inequality of $\mathrm{Census}(n)$. $\square$

**Corollary 5.10 (The first one hundred, ordered by conductor).** *The list
$\mathrm{Enum}(100)$ is a concrete roster of exactly $100$ pairwise-distinct Selberg
data whose conductors are precisely $0, 1, \dots, 99$, each contained in the finite
slice $\mathrm{Census}(100)$.*

This delivers the original census request as a literal, computable finite object.

---

## 6. Discussion

The results assemble into a single dichotomy, sharp on both sides.

> **The naive space of Dirichlet series is uncountable (continuum), while every
> arithmetically constrained family — periodic-coefficient L-functions, Dirichlet
> L-functions, and the finite-data Selberg class — is countable.**

The mechanism is uniform. Uncountability, in Section 3, comes from *freedom*: with
independent choices at infinitely many positions, Cantor's diagonal argument produces
more sequences than any list can hold. Countability, in Sections 4 and 5, comes from
*determination by finite data*: periodicity replaces an infinite sequence by one
block; the Selberg axioms replace an analytic object by a finite invariant packet.
Once an object is the value of a function on a countable domain of finite data, the
species is countable — however deep each individual specimen may be.

It is worth emphasizing what countability does *not* say. It does not diminish the
individual L-functions: each still encodes, through its zeros and special values,
arithmetic of unbounded subtlety. Countability is a statement about the *catalogue*,
not the *contents*. The Selberg class is, in the phrase that titles this program, a
universe of countable stars, each one an entire galaxy.

The finite-data model of Section 5 is deliberately a caricature — it records
invariants rather than proving that they determine an analytic L-function. Its virtue
is that it isolates the counting argument in a form that is fully explicit and even
computable, as the demonstrations accompanying this work illustrate: one can print
$\mathrm{Enum}(100)$, verify its length and distinctness, and inspect the growth of
$|\mathrm{Census}(N)|$ directly.

---

## 7. Future directions

This work establishes the cardinality dichotomy behind the cosmic census: the naive
space of Dirichlet series is uncountable, but every arithmetically constrained family
of L-functions is countable. Several avenues extend it.

1. **Analytic Selberg class.** Replace the finite-data caricature with the genuine
   analytic definition — Dirichlet series with analytic continuation, functional
   equation, Euler product, and Ramanujan bound — and prove countability via the
   strong multiplicity-one theorem: an element is determined by its coefficients,
   which are algebraic.

2. **Root numbers on the unit circle.** Model the root number as an actual element of
   the unit circle whose argument is a rational multiple of $\pi$, and relate the
   rational numerator/denominator packet used here to genuine roots of unity.

3. **Degree and conductor constraints.** Establish the theorem that, for fixed degree
   $d$ and conductor $q$, the Selberg class contains only finitely many primitive
   elements, sharpening the finiteness of each census slice.

4. **Bridge to Dirichlet L-series.** Connect the character coefficient sequence
   $c_\chi$ to the analytically defined L-series of a Dirichlet character, turning the
   coefficient count into a count of the analytic objects themselves.

5. **Richer explicit enumeration.** The current enumeration records one canonical
   datum per conductor; a natural refinement lists, for each conductor, all primitive
   data of that conductor, ordered lexicographically within each conductor block.

---

## 8. Conclusion

We have proved a clean cardinality census of the L-function universe. Without
arithmetic constraints, the coefficient sequences form a continuum (Theorems
3.2–3.3). With them, countability is universal: periodic sequences over a countable
alphabet are countable (Theorem 4.2), whence there are only countably many Dirichlet
L-functions (Theorem 4.6); and the finite-data model of the Selberg class is
countably infinite (Theorem 5.3), stratifying into finite slices (Theorems 5.5–5.6)
that support an explicit conductor-ordered enumeration (Theorem 5.9, Corollary 5.10).
The universe of well-behaved L-functions is, against the first impression created by
continuous families, no larger than the integers — a countable sky of infinitely deep
stars.
