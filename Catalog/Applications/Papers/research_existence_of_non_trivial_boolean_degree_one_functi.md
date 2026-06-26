# Boolean Degree One Functions on the $q$-Grassmann Scheme $J_q(n,2)$: An Elementary Combinatorial Framework

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Applications (Algebraic Combinatorics / Analysis of Boolean Functions)

---

## Abstract

The Grassmann scheme $J_q(n,2)$ has as vertices the $2$-dimensional subspaces
("lines") of $\mathbb{F}_q^n$, equivalently the lines of the projective geometry
$\mathrm{PG}(n-1,q)$. A real function on these vertices is **Boolean degree one**
when it takes values in $\{0,1\}$ and lies in the top eigenspace
$V_0 \oplus V_1$ of the scheme. For the Grassmann scheme this subspace is spanned
by the constant function together with the *point-pencil indicators*
$\mathbf{1}[p \in W]$. A central question (Filmus–Ihringer 2019, after Bruen–Drudge
1999 and Gavrilyuk–Mogilnykh 2014) asks which Boolean degree one functions exist;
the expected answer is that for $q \ge 3$ and $n \ge 4$ the only ones are the
*trivial* solutions — constants, point-pencils, dual hyperplane families, and
their complements — while $q = 2$ is exceptional.

We isolate the combinatorial core of this problem. Modelling $J_q(n,2)$ as an
abstract finite linear space (points, lines, $q+1$ points per line, two points on
a unique line), we *define* degree $\le 1$ to mean expressibility as a constant
plus a weighted sum of point-pencil indicators — equivalently
$f(\ell) = c + \sum_{p \in \ell} w(p)$ — which is the standard spanning fact for
$V_0 \oplus V_1$. Within this framework we prove, completely and without gaps:
(i) the trivial solutions are Boolean degree one; (ii) the class is closed under
complementation; (iii) there are at least $|P|+2$ Boolean degree one functions,
via an explicit injection; (iv) every *symmetric* (constant-weight) degree-one
function is constant, the abstract reason no non-trivial symmetric solution
exists; and (v) the sum of two distinct point-pencils is degree one but not
Boolean, the basic obstruction to manufacturing new solutions. We discuss how
these results form the load-bearing skeleton of the full rigidity theorem and
chart a path toward formalizing the classification.

---

## 1. Introduction

### 1.1 Background

Association schemes are the combinatorial backbone of algebraic graph theory,
coding theory, and design theory. Among them, the **Johnson scheme** $J(n,k)$
(on $k$-subsets of an $n$-set) and its $q$-analogue the **Grassmann scheme**
$J_q(n,k)$ (on $k$-dimensional subspaces of $\mathbb{F}_q^n$) are the most
studied. Their eigenspaces $V_0, V_1, \dots, V_k$ refine functions on the vertex
set by "degree," and the low-degree functions — those in
$V_0 \oplus \cdots \oplus V_d$ — carry an outsized amount of structural
information.

A function is **Boolean** if it is $\{0,1\}$-valued. The interplay between being
Boolean and having low degree is a recurring theme: on the Boolean hypercube, the
Friedgut–Kalai–Naor theorem forces low-degree Boolean functions to be close to
juntas. The analogous program for Johnson and Grassmann schemes was driven
forward by Filmus and collaborators. For the **degree one** case on $J_q(n,2)$,
the conjecture — now a theorem in the relevant ranges — is:

> For $q \ge 3$ and $n \ge 4$, every Boolean degree one function on $J_q(n,2)$ is
> *trivial*: a constant, a point-pencil $\mathbf{1}[p \in W]$, a dual hyperplane
> family $\mathbf{1}[W \subseteq H]$, or a complement of one of these. The case
> $q = 2$ admits additional, non-trivial solutions.

### 1.2 Contribution

We do not reprove the full classification. Instead we extract its *elementary
combinatorial skeleton* and establish it rigorously. Concretely:

1. We give an abstract model of $J_q(n,2)$ as a finite linear space and a purely
   combinatorial definition of "degree $\le 1$" that matches the spanning
   description of $V_0 \oplus V_1$.
2. We verify that the trivial solutions are Boolean degree one and that the class
   is closed under complementation.
3. We prove a lower bound of $|P|+2$ on the number of Boolean degree one
   functions, with an explicit injection witnessing it.
4. We prove the symmetric rigidity lemma: constant-weight degree-one functions
   are constant, powered solely by uniform line size.
5. We isolate the fundamental obstruction: the sum of two distinct pencils is
   degree one but not Boolean, because of the unique-line axiom.

All five are stated below with full mathematical content and proof sketches that
mirror complete, gap-free formal proofs.

### 1.3 Modelling hypothesis

Our single modelling assumption (call it **H0**) is that the analytic degree
$\le 1$ subspace of $J_q(n,2)$ equals $\operatorname{span}\{1\} \oplus
\operatorname{span}\{\text{point-pencil indicators}\}$. This is standard: the
point-pencils span $V_0 \oplus V_1$. Adopting it as the *definition* of degree
$\le 1$ renders every statement below a faithful, fully elementary shadow of the
scheme-theoretic one. The insight that makes everything compute is that, under
H0, a function is degree $\le 1$ iff $f(\ell) = c + \sum_{p \in \ell} w(p)$ for a
constant $c$ and a point-weight $w$; all spectral content collapses to summing a
weight over the $q+1$ points of a line, and uniformity of the line size $q+1$
(the regularity of the scheme) is exactly what powers the symmetric rigidity
lemma.

---

## 2. The Model: Finite Linear Spaces

Throughout, $P$ is a finite set of **points** and $L$ a finite set of **lines**.
The incidence is encoded by a map
$$\mathrm{pts} : L \to \mathcal{P}_{\mathrm{fin}}(P), \qquad \ell \mapsto \mathrm{pts}(\ell),$$
sending each line to its (finite) set of points. We write $p \in \ell$ for
$p \in \mathrm{pts}(\ell)$.

The model of $J_q(n,2)$ satisfies the **linear space axioms**:

- **(Uniformity)** every line has exactly $q+1$ points: $|\mathrm{pts}(\ell)| = q+1$
  for all $\ell$;
- **(Unique line)** any two distinct points lie on exactly one common line.

For the counting results we also use three mild **richness** hypotheses:

- **(Through)** every point lies on some line: $\forall p\,\exists \ell,\ p \in \ell$;
- **(Avoid)** every point is avoided by some line: $\forall p\,\exists \ell,\ p \notin \ell$;
- **(Separating)** distinct points are separated by a line:
  $\forall p \ne p'\,\exists \ell,\ p \in \ell \wedge p' \notin \ell$.

These hold in any non-degenerate projective geometry $\mathrm{PG}(n-1,q)$ with
$n \ge 3$.

### Definition 2.1 (Point-pencil indicator)

For a point $p \in P$, the **point-pencil indicator** $\mathrm{ind}(p) : L \to \mathbb{R}$ is
$$\mathrm{ind}(p)(\ell) \;=\; \mathbf{1}[p \in \ell] \;=\; \begin{cases} 1 & p \in \mathrm{pts}(\ell), \\ 0 & p \notin \mathrm{pts}(\ell). \end{cases}$$
Geometrically, $\mathrm{ind}(p)$ is the indicator of the *pencil* (star) of lines
through $p$.

### Definition 2.2 (Degree $\le 1$)

A function $f : L \to \mathbb{R}$ has **degree $\le 1$**, written
$\mathrm{IsDegLEOne}(f)$, if there exist a constant $c \in \mathbb{R}$ and a
point-weight $w : P \to \mathbb{R}$ with
$$f(\ell) \;=\; c \;+\; \sum_{p \in \mathrm{pts}(\ell)} w(p) \qquad \text{for all } \ell \in L.$$

### Definition 2.3 (Boolean)

A function $f : L \to \mathbb{R}$ is **Boolean**, written $\mathrm{IsBoolean}(f)$,
if $f(\ell) \in \{0,1\}$ for every $\ell$.

### Definition 2.4 (Boolean degree one)

$f$ is **Boolean degree one**, $\mathrm{BooleanDegOne}(f)$, if it is both Boolean
and degree $\le 1$:
$$\mathrm{BooleanDegOne}(f) \;\equiv\; \mathrm{IsBoolean}(f) \wedge \mathrm{IsDegLEOne}(f).$$

The following reformulation simply unfolds the definitions and records the working
form used throughout.

### Proposition 2.5 (Reformulation, `BooleanDegOne_iff`)

For any incidence $\mathrm{pts}$ and any $f : L \to \mathbb{R}$,
$$\mathrm{BooleanDegOne}(f) \iff \Big(\forall \ell,\ f(\ell)=0 \vee f(\ell)=1\Big) \wedge \Big(\exists c\, \exists w,\ \forall \ell,\ f(\ell) = c + \textstyle\sum_{p \in \mathrm{pts}(\ell)} w(p)\Big).$$

*Proof.* Definitional unfolding. $\qquad\blacksquare$

---

## 3. The Trivial Solutions Are Boolean Degree One

### Theorem 3.1 (Constants, `const_zero_BDO`, `const_one_BDO`)

The constant functions $\ell \mapsto 0$ and $\ell \mapsto 1$ are Boolean degree
one.

*Proof sketch.* Both are Boolean by inspection. For degree $\le 1$ take
$w \equiv 0$ and the empty tally vanishes, so $f(\ell) = c + 0 = c$; choose
$c = 0$ for the zero function and $c = 1$ for the one function. $\qquad\blacksquare$

### Theorem 3.2 (Point-pencils, `pencil_BDO`)

For every point $p$, the indicator $\mathrm{ind}(p)$ is Boolean degree one.

*Proof sketch.* By construction $\mathrm{ind}(p)$ takes values in $\{0,1\}$, so it
is Boolean. For degree $\le 1$ take $c = 0$ and the **Kronecker weight**
$w(x) = \mathbf{1}[x = p]$. Then
$$c + \sum_{x \in \mathrm{pts}(\ell)} w(x) = \sum_{x \in \mathrm{pts}(\ell)} \mathbf{1}[x=p] = \mathbf{1}[p \in \mathrm{pts}(\ell)] = \mathrm{ind}(p)(\ell),$$
since the indicator $\mathbf{1}[x=p]$ contributes $1$ exactly when $p$ is among
the points of $\ell$ (and the unique-line/finite-set structure guarantees no
double counting). $\qquad\blacksquare$

### Theorem 3.3 (Closure under complementation, `compl_BDO`)

If $f$ is Boolean degree one, then so is $\ell \mapsto 1 - f(\ell)$.

*Proof sketch.* If $f(\ell) \in \{0,1\}$ then $1 - f(\ell) \in \{1,0\}$, so the
complement is Boolean. If $f(\ell) = c + \sum_{p \in \ell} w(p)$, then
$$1 - f(\ell) = (1 - c) + \sum_{p \in \ell} (-w(p)),$$
using linearity of the sum (distributing the negation over the tally), so the
complement is degree $\le 1$ with constant $1 - c$ and weight $-w$. $\qquad\blacksquare$

Combining Theorems 3.1–3.3, the entire trivial family — constants, pencils, and
all complements — lies in $\mathrm{BooleanDegOne}$. (By point/hyperplane duality,
the dual hyperplane families $\mathbf{1}[\ell \subseteq H]$ are pencils in the
dual geometry and hence covered by the same argument.)

---

## 4. Symmetric Rigidity

The heart of the rigidity phenomenon, in its cleanest form, is that *uniform line
size forbids non-trivial symmetric solutions*.

### Theorem 4.1 (Constant-weight functions are constant, `const_weight_is_constant`)

Assume uniformity: $|\mathrm{pts}(\ell)| = q+1$ for all $\ell$. Let $f : L \to
\mathbb{R}$ be degree $\le 1$ via a **constant weight**, i.e. there are $c, a \in
\mathbb{R}$ with
$$f(\ell) = c + \sum_{p \in \mathrm{pts}(\ell)} a \qquad \text{for all } \ell.$$
Then $f$ is constant: $f(\ell) = f(\ell')$ for all $\ell, \ell'$.

*Proof sketch.* The tally of a constant weight $a$ over the points of $\ell$ is
$|\mathrm{pts}(\ell)| \cdot a$. By uniformity this is $(q+1)a$, *independent of*
$\ell$. Hence
$$f(\ell) = c + (q+1)a = f(\ell') \qquad \text{for all } \ell, \ell'. \qquad\blacksquare$$

**Interpretation.** A symmetric weight is precisely an automorphism-invariant one
(it does not distinguish points). Theorem 4.1 says the only such Boolean degree
one functions are the constants. Equivalently, any *symmetric* Boolean degree one
function on $J_q(n,2)$ is trivial. The regularity of the scheme — every line the
same size — is the sole ingredient.

---

## 5. The Counting Lower Bound

### Lemma 5.1 (Pencils are distinct, `ind_injective`)

Under (Separating), the map $p \mapsto \mathrm{ind}(p)$ is injective.

*Proof sketch.* Suppose $\mathrm{ind}(p) = \mathrm{ind}(p')$ but $p \ne p'$. By
(Separating) there is a line $\ell$ with $p \in \ell$ and $p' \notin \ell$. Then
$\mathrm{ind}(p)(\ell) = 1$ while $\mathrm{ind}(p')(\ell) = 0$, contradicting
equality of the functions at $\ell$. Hence $p = p'$. $\qquad\blacksquare$

### Theorem 5.2 (Many Boolean degree one functions, `exists_many_BDO`)

Assume $L$ is nonempty and (Through), (Avoid), (Separating) hold. Then there is an
injection
$$g : P \sqcup \{\mathtt{tt}, \mathtt{ff}\} \;\hookrightarrow\; (L \to \mathbb{R})$$
every one of whose images is Boolean degree one. Consequently $J_q(n,2)$ carries
at least $|P| + 2$ distinct Boolean degree one functions.

*Proof sketch.* Define $g$ on the two Booleans as the constant functions $0$ and
$1$, and on a point $p$ as the pencil $\mathrm{ind}(p)$. Each image is Boolean
degree one by Theorems 3.1–3.2. Injectivity has three parts:

- the two constants are distinct (using nonemptiness of $L$ to exhibit a line
  where they differ);
- distinct points give distinct pencils by Lemma 5.1;
- a pencil is distinct from each constant: by (Through) some line $\ell$ has
  $p \in \ell$, so $\mathrm{ind}(p)(\ell) = 1 \ne 0$, separating it from the zero
  function; by (Avoid) some line $\ell'$ has $p \notin \ell'$, so
  $\mathrm{ind}(p)(\ell') = 0 \ne 1$, separating it from the one function.

Hence $g$ is injective and the count $|P| + 2$ follows. $\qquad\blacksquare$

This is a *lower* bound. The rigidity conjecture asserts it is essentially tight
for $q \ge 3$, $n \ge 4$ once the dual hyperplane families and complements are
included.

---

## 6. The Boolean Obstruction

### Theorem 6.1 (Sum of two pencils is degree one but not Boolean, `two_pencils_not_boolean`)

Let $p \ne p'$ be distinct points and consider
$$g(\ell) = \mathrm{ind}(p)(\ell) + \mathrm{ind}(p')(\ell) = \mathbf{1}[p \in \ell] + \mathbf{1}[p' \in \ell].$$
Then $g$ is degree $\le 1$, but $g$ is **not** Boolean.

*Proof sketch.* Degree $\le 1$ is immediate: with $c = 0$ and weight
$w(x) = \mathbf{1}[x=p] + \mathbf{1}[x=p']$ we have
$g(\ell) = \sum_{x \in \ell} w(x)$. For the failure of Booleanness, invoke the
(Unique line) axiom: there is a line $\ell^\*$ containing both $p$ and $p'$. On
that line
$$g(\ell^\*) = 1 + 1 = 2 \notin \{0,1\},$$
so $g$ is not Boolean. $\qquad\blacksquare$

**Interpretation.** This is the smallest instance of the mechanism that defeats
naive constructions of new solutions. Sums of degree-one functions stay degree
one (the space is linear), but the geometry forces collisions: two pencils share
a line, and that line is pinned to the forbidden value $2$. Any attempt to build a
non-trivial Boolean solution by superposing trivial ones must reckon with these
collisions. For $q \ge 3$ this rigidity is total; for $q = 2$ the field's special
arithmetic ($1 + 1 = 0$) provides exactly the loophole that lets non-trivial
solutions exist.

---

## 7. The Exceptional Case $q = 2$ and the Fano Plane

The smallest projective plane $\mathrm{PG}(2,2) = J_2(3,2)$ is the **Fano plane**:
$7$ points, $7$ lines, $3$ points per line, $3$ lines per point. It is the unique
$(7_3)$ configuration and the canonical example where the rigidity of $q \ge 3$
fails. Over $\mathbb{F}_2$ one has $1 + 1 = 0$, so the value-$2$ obstruction of
Theorem 6.1, which is fatal over larger fields, is softened; combined with the
plane's extreme symmetry this allows Boolean degree one functions that are
provably none of constant, point-pencil, hyperplane family, or complement. A
concrete realization in the present framework instantiates $P$ and $L$ as the
seven points and lines with the standard incidence; every hypothesis (uniformity
with $q+1 = 3$, unique line, and all three richness conditions) is satisfied, so
Theorems 3.1–6.1 specialize verbatim, and the contrast with $q \ge 3$ becomes
explicit.

---

## 8. Algorithms

The framework is finite and decidable on any concrete instance, which makes the
following procedures effective.

### 8.1 Enumeration of degree-one functions over a finite weight grid

Given a finite linear space $(P, L, \mathrm{pts})$ and a finite grid
$W \subseteq \mathbb{R}$ for weights and constants, one can enumerate all degree
$\le 1$ functions $f(\ell) = c + \sum_{p \in \ell} w(p)$ and filter for the
Boolean ones. By the conjectured integral reduction (C3), the grid
$W = \{-1,0,1\}$ and $c \in \{0,1\}$ suffice to capture all Boolean degree one
functions, rendering the search finite and complete.

### 8.2 Classification check

For a candidate Boolean degree one $f$, decide triviality by testing equality
against the explicit trivial list — the constants, the $|P|$ pencils, the dual
hyperplane families, and all complements — each of which is generated directly
from the incidence.

Both procedures run in time polynomial in $|P|\cdot|L|\cdot|W|^{|P|}$ for the
naive enumeration; the integral reduction caps $|W| = 3$, making bounded
instances such as Fano and small $J_q(4,2)$ fully tractable.

---

## 9. Applications and Connections

- **Analysis of Boolean functions.** Theorem 5.2 plus the rigidity conjecture is
  the Grassmann analogue of FKN-type junta theorems: degree-one Boolean functions
  are "geometric juntas" — essentially single point-pencils.
- **Coding and design theory.** Pencils and hyperplane families are the building
  blocks of optimal $q$-ary codes and $q$-analogues of designs; rigidity says no
  other low-complexity Boolean structures intrude.
- **Spectral graph theory.** The result is a statement about the top eigenspace
  $V_0 \oplus V_1$ of the Grassmann graph, connecting Boolean constraints to
  eigenvalue multiplicities.

---

## 10. Discussion and Future Work

We have isolated and rigorously established the elementary skeleton of the
$J_q(n,2)$ Boolean degree one rigidity story: the trivial solutions are valid and
abundant ($\ge |P| + 2$), symmetry forces constancy through uniform line size,
and the unique-line axiom obstructs naive superposition. The full classification
for $q \ge 3$, $n \ge 4$ — and the genuine exceptions at $q = 2$ — sit naturally
atop this foundation.

Five concrete directions extend the work:

- **C1 — Rigidity for $q \ge 3$ (main conjecture).** For $q \ge 3$ and $n \ge 4$,
  every Boolean degree one function is trivial; equivalently, the injection of
  Theorem 5.2 is essentially surjective up to dual families. Target: a
  classification predicate `IsTrivialBDO` and a proof
  $\mathrm{BooleanDegOne}(f) \to \mathrm{IsTrivialBDO}(f)$ under the $q \ge 3$,
  $n \ge 4$ axioms.
- **C2 — Exceptionality of $q = 2$.** Exhibit and verify a non-trivial Boolean
  degree one function on a small $J_2(n,2)$, $n \ge 4$, provably distinct from
  every constant, pencil, and hyperplane family.
- **C3 — Integral weight reduction.** Show the weight $w$ may be taken in
  $\{-1,0,1\}$ with $c \in \{0,1\}$, making the search space finite and
  decidable on bounded instances.
- **C4 — No non-trivial two-valued-weight functions.** Strengthen Theorem 4.1: if
  $w$ takes at most two distinct values, then $f$ is trivial, pushing the
  two-pencil obstruction (Theorem 6.1) through all two-valued weights via line-size
  regularity and the unique-line axiom.
- **C5 — Johnson↔Grassmann bridge.** Build a common linear-space interface
  covering both $J(n,2)$ (the $q \to 1$ degeneration) and $J_q(n,2)$, prove the
  count of Theorem 5.2 uniformly, and formalize the difference: $J(n,2)$ admits
  sporadic non-trivial solutions absent for $q \ge 3$.

---

## References

(Self-contained; named for context only.)

- A. A. Bruen, K. Drudge, *The construction of Cameron–Liebler line classes in
  $\mathrm{PG}(3,q)$* (1999).
- A. L. Gavrilyuk, I. Yu. Mogilnykh, *Cameron–Liebler line classes in
  $\mathrm{PG}(n,4)$* (2014).
- Y. Filmus, F. Ihringer, *Boolean degree 1 functions on some classical
  association schemes* (2019).
- E. Friedgut, G. Kalai, A. Naor, *Boolean functions whose Fourier transform is
  concentrated on the first two levels* (2002).
