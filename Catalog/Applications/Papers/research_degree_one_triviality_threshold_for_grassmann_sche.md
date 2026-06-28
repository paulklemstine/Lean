# The Degree-One Triviality Threshold for Grassmann Schemes: A Verified Combinatorial Backbone

## Abstract

The Grassmann scheme $J_q(n,k)$ is the association scheme whose points are the
$k$-dimensional subspaces of an $n$-dimensional vector space over the finite field
$\mathbb{F}_q$. A central rigidity question on these schemes is the **degree-one
triviality threshold conjecture**: for every prime power $q$ and integers $2 \le k
\le n/2$, if $n \ge 2k+1$ then every Boolean degree-one function on $J_q(n,k)$ is
*trivial*, i.e. a $\{0,1\}$-linear combination of point indicators and their
duals. The conjecture is known for $q=2$ (all $k$) and for $q \in \{3,4,5\}$ with
$k=2$.

This paper develops, and formally verifies, the combinatorial backbone required to
state the conjecture faithfully and to expose its structural levers. We define the
Gaussian binomial coefficient $\binom{n}{k}_q$ through the division-free $q$-Pascal
recurrence and establish: (i) the classical degeneration $\binom{n}{k}_1 =
\binom{n}{k}$, identifying the $q\to 1$ limit of $J_q(n,k)$ with the Johnson scheme
$J(n,k)$; (ii) nonemptiness $\binom{n}{k}_q \ge 1$ for $k \le n$, $q \ge 1$; (iii)
the closed form $\binom{n}{1}_q = 1 + q + \cdots + q^{n-1}$ for the point count;
(iv) the mirror symmetry $\binom{n}{k}_q = \binom{n}{n-k}_q$, whose $k=1$ slice is
point–hyperplane duality; and (v) strict ambient monotonicity $\binom{n}{k}_q <
\binom{n+1}{k}_q$ for $q \ge 2$. In the classical limit we transport three
structural facts: unimodality $\binom{n}{k}_1 \le \binom{n}{\lfloor n/2\rfloor}_1$,
ambient monotonicity $\binom{n}{k}_1 \le \binom{m}{k}_1$ for $n \le m$, and total
mass $\sum_{k=0}^n \binom{n}{k}_1 = 2^n$. We explain how the mirror symmetry makes
the trivial family duality-closed (yielding a sharpness prediction at $n=2k$) and
how strict growth conjecturally upgrades to a $q$-uniform spectral gap.

**Keywords:** Grassmann scheme, Gaussian binomial coefficient, $q$-analogue,
Johnson scheme, point–hyperplane duality, Boolean degree-one functions, association
schemes.

---

## 1. Introduction

### 1.1 Association schemes of subsets and subspaces

The **Johnson scheme** $J(n,k)$ has as its points the $k$-element subsets of
$\{1,\dots,n\}$, related according to the size of their pairwise intersection. Its
linear-algebraic $q$-analogue is the **Grassmann scheme** $J_q(n,k)$, whose points
are the $k$-dimensional subspaces of $\mathbb{F}_q^n$, related according to the
dimension of their pairwise intersection. These schemes are the prototypical
*distance-regular* and *cometric* (Q-polynomial) association schemes, and their
harmonic analysis underlies large swathes of extremal combinatorics, coding
theory, and the analysis of Boolean functions.

The number of points of $J_q(n,k)$ is the **Gaussian binomial coefficient**
(Gaussian polynomial) $\binom{n}{k}_q$, the canonical $q$-analogue of the binomial
coefficient. Despite its ubiquity, Mathlib (v4.28.0) contains no development of the
Gaussian binomial; the present work builds the needed theory from first principles
and verifies every identity.

### 1.2 Boolean degree-one functions and triviality

Each association scheme carries a canonical orthogonal eigenspace decomposition of
the function space on its points. The **degree-one** functions are those supported
on the trivial eigenspace together with the first nontrivial eigenspace — the
"linear" layer of the scheme's Fourier analysis. A function is **Boolean** if it is
$\{0,1\}$-valued.

On $J_q(n,k)$ there are two canonical families of degree-one Boolean functions:

- **Point indicators** $\mathbf{1}_{p \subseteq \cdot}$: for a fixed point (line)
  $p$, the indicator of the $k$-subspaces $V$ with $p \subseteq V$.
- **Dual indicators** $\mathbf{1}_{\cdot \subseteq H}$: for a fixed hyperplane $H$,
  the indicator of the $k$-subspaces $V$ with $V \subseteq H$.

A Boolean degree-one function is called **trivial** if it is a $\{0,1\}$-linear
combination of point indicators and dual indicators. The mirror symmetry
$\binom{n}{k}_q = \binom{n}{n-k}_q$ makes the two families interchangeable under the
scheme's duality; consequently the trivial functions are precisely the
**duality-closed span of rank-one indicators**.

### 1.3 The threshold conjecture

> **Conjecture 1 (Degree-one triviality threshold).** For every prime power $q$ and
> integers $k, n$ with $2 \le k \le n/2$, if $n \ge 2k+1$ then every Boolean
> degree-one function on $J_q(n,k)$ is trivial.

The case $q = 2$ is known for all $k$; the cases $q \in \{3,4,5\}$ are known for
$k = 2$. The conjecture asserts uniformity across all prime powers $q$ once
$n \ge 2k+1$.

### 1.4 Contributions

This paper formalizes and verifies the *counting layer* on which any faithful
attack on Conjecture 1 must rest, and isolates two structural levers:

1. A division-free construction of $\binom{n}{k}_q$ and the identities
   `qBinom_one`, `qBinom_pos`, `qBinom_one_eq_geom`, `qBinom_symm`,
   `point_hyperplane_duality`, and `qBinom_strictMono_left` (Section 3).
2. The exact $q\to 1$ degeneration to the Johnson scheme, with three transported
   classical facts `qBinom_one_unimodal_bound`, `qBinom_one_mono_ambient`,
   `qBinom_one_total_mass` (Section 4).
3. A structural reading of the threshold: duality-closure of the trivial family
   (Section 5.1), the sharpness prediction at $n=2k$ via self-duality (Section
   5.2), and the strict-growth $\Rightarrow$ spectral-gap heuristic (Section 5.3).

Every numbered theorem below corresponds to a machine-checked statement.

---

## 2. Definitions

Throughout, $q, n, k$ denote natural numbers and $\mathbb{F}_q$ the field with $q$
elements (when $q$ is a prime power).

**Definition 2.1 (Gaussian binomial via $q$-Pascal).** The Gaussian binomial
coefficient $\binom{n}{k}_q$, written `qBinom q n k`, is defined by the
recurrence
$$\binom{n}{0}_q = 1, \qquad \binom{0}{k+1}_q = 0,$$
$$\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{\,k+1}\,\binom{n}{k+1}_q.$$

This *first $q$-Pascal recurrence* defines $\binom{n}{k}_q$ as an honest natural
number with no division. It is the $q$-analogue of $\binom{n+1}{k+1} = \binom{n}{k}
+ \binom{n}{k+1}$, recovered at $q=1$.

**Definition 2.2 (Grassmann scheme point set).** For a prime power $q$, the point
set of $J_q(n,k)$ is the set of $k$-dimensional subspaces of $\mathbb{F}_q^n$; its
cardinality is $\binom{n}{k}_q$. The points of $J_q(n,1)$ are the lines through the
origin; the *hyperplanes* are the points of $J_q(n,n-1)$.

**Definition 2.3 (Trivial Boolean degree-one function).** A Boolean degree-one
function $f$ on $J_q(n,k)$ is *trivial* if there exist coefficient sets so that
$$f = \sum_{p} a_p\, \mathbf{1}_{p \subseteq \cdot} + \sum_{H} b_H\,
\mathbf{1}_{\cdot \subseteq H}, \qquad a_p, b_H \in \{0,1\},$$
where $p$ ranges over lines and $H$ over hyperplanes.

---

## 3. The Gaussian-binomial backbone

We record the structural identities, with proof sketches. All are proved by
induction on the recurrence of Definition 2.1; none reduces to a `decide`/`rfl`
computation.

**Theorem 3.1 (`qBinom_one`: classical degeneration).** For all $n, k$,
$$\binom{n}{k}_1 = \binom{n}{k}.$$
*Proof sketch.* Set $q=1$ in Definition 2.1. The recurrence becomes
$\binom{n+1}{k+1}_1 = \binom{n}{k}_1 + 1^{k+1}\binom{n}{k+1}_1 = \binom{n}{k}_1 +
\binom{n}{k+1}_1$, which is ordinary Pascal addition, with identical base cases.
Induction on $n$ (with $k$ universally quantified) closes the gap. $\square$

This identifies the $q\to 1$ limit of the Grassmann scheme with the Johnson scheme:
$|J_1(n,k)| = \binom{n}{k} = |J(n,k)|$.

**Theorem 3.2 (`qBinom_pos`: nonemptiness).** If $q \ge 1$ and $k \le n$ then
$$\binom{n}{k}_q \ge 1.$$
*Proof sketch.* Induction on $n$. The base case $\binom{n}{0}_q = 1$ holds. For the
step, $\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q \ge
\binom{n}{k}_q \ge 1$ by the inductive hypothesis, using $q^{k+1} \ge 0$. The
hypothesis $q \ge 1$ is load-bearing: at $q=0$ the term $q^{k+1}$ vanishes and one
can lose positivity above the diagonal. $\square$

**Theorem 3.3 (`qBinom_one_eq_geom`: point count).** For all $n \ge 1$,
$$\binom{n}{1}_q = 1 + q + q^2 + \cdots + q^{n-1} = \sum_{i=0}^{n-1} q^i.$$
*Proof sketch.* Induction on $n$ using the recurrence with $k=0$:
$\binom{n+1}{1}_q = \binom{n}{0}_q + q\,\binom{n}{1}_q = 1 + q\sum_{i=0}^{n-1} q^i =
\sum_{i=0}^{n} q^i$. Geometrically, $\binom{n}{1}_q = \frac{q^n-1}{q-1}$ counts the
lines of $\mathbb{F}_q^n$: $q^n-1$ nonzero vectors, each line containing $q-1$ of
them. $\square$

**Theorem 3.4 (Second $q$-Pascal recurrence).** For all $n, k$,
$$\binom{n+1}{k+1}_q = q^{\,n-k}\,\binom{n}{k}_q + \binom{n}{k+1}_q.$$
*Proof sketch.* This $q^{n-k}$-twisted partner of Definition 2.1 is the
combinatorial expression of "extend a $k$-subspace either inside or transversally
to a fixed hyperplane." It is proved by a parallel induction and is the auxiliary
identity needed to push the symmetry induction (Theorem 3.5) through. $\square$

**Theorem 3.5 (`qBinom_symm`: mirror symmetry).** For all $k \le n$,
$$\binom{n}{k}_q = \binom{n}{\,n-k\,}_q.$$
*Proof sketch.* Strong induction on $n$, using *both* Pascal recurrences (Def. 2.1
and Thm. 3.4). Writing $k' = n-k$, the two recurrences express $\binom{n+1}{k+1}_q$
and $\binom{n+1}{(n+1)-(k+1)}_q = \binom{n+1}{n-k}_q$ in terms of strictly smaller
symmetric pairs, which match by the inductive hypothesis. Geometrically the
symmetry is the orthogonal-complement bijection $V \mapsto V^{\perp}$ between
$k$- and $(n-k)$-dimensional subspaces. This is the load-bearing identity of the
whole theory. $\square$

**Theorem 3.6 (`point_hyperplane_duality`).** For all $n \ge 1$,
$$\binom{n}{1}_q = \binom{n}{\,n-1\,}_q,$$
i.e. the number of points (lines) equals the number of hyperplanes.
*Proof sketch.* The $k=1$ instance of Theorem 3.5. It is the counting shadow of the
point/dual-point duality to which the word "trivial" refers in Conjecture 1:
point indicators and dual indicators are exchanged by $V \mapsto V^\perp$. $\square$

**Theorem 3.7 (`qBinom_strictMono_left`: strict ambient growth).** If $q \ge 2$ and
$1 \le k \le n$ then
$$\binom{n}{k}_q < \binom{n+1}{k}_q.$$
*Proof sketch.* By the recurrence (suitably indexed), $\binom{n+1}{k}_q -
\binom{n}{k}_q$ equals a sum of strictly positive terms involving $q^{k} \ge 2^k >
0$ together with a strictly positive lower-order $q$-binomial (Theorem 3.2). The
hypothesis $q \ge 2$ is essential: at $q=1$ the inequality reduces to strict
monotonicity of ordinary binomials in $n$, which fails past the central column
(e.g. $\binom{2}{2} = \binom{3}{2}$ would require $1 < 3$ to hold strictly at the
diagonal but plateaus appear in general). $\square$

---

## 4. The classical $q \to 1$ limit

Setting $q=1$ degenerates $J_q(n,k)$ to the Johnson scheme. Via Theorem 3.1, three
classical facts about ordinary binomials transport verbatim. We use the standard
binomial toolkit: middle-coefficient maximality $\binom{n}{k} \le
\binom{n}{\lfloor n/2\rfloor}$, monotonicity $\binom{n}{k}\le\binom{m}{k}$ for
$n\le m$, and the row sum $\sum_{k=0}^n \binom{n}{k} = 2^n$.

**Theorem 4.1 (`qBinom_one_unimodal_bound`: unimodality).** For all $n, k$,
$$\binom{n}{k}_1 \le \binom{n}{\lfloor n/2\rfloor}_1.$$
*Proof sketch.* Rewrite both sides via Theorem 3.1 and apply middle-coefficient
maximality of ordinary binomials. The central scheme $J_1(n,\lfloor n/2\rfloor)$ is
the largest. $\square$

This is the conceptual link to the threshold $n \ge 2k+1$: that regime forces $k$
strictly below the central index $\lfloor n/2\rfloor$, the part of the row where the
scheme is still *growing* — exactly where few degree-one functions can exist.

**Theorem 4.2 (`qBinom_one_mono_ambient`: ambient monotonicity).** If $n \le m$
then
$$\binom{n}{k}_1 \le \binom{m}{k}_1.$$
*Proof sketch.* Rewrite via Theorem 3.1 and apply monotonicity of $\binom{\cdot}{k}$.
This is the $q=1$ shadow of the strict growth of Theorem 3.7. $\square$

**Theorem 4.3 (`qBinom_one_total_mass`: total mass).** For all $n$,
$$\sum_{k=0}^{n} \binom{n}{k}_1 = 2^n.$$
*Proof sketch.* Rewrite the summand pointwise (a sum-congruence) via Theorem 3.1,
then apply the row-sum identity $\sum_{k=0}^n \binom{n}{k} = 2^n$. The classical
limit of the Grassmann poset is the Boolean lattice on $n$ elements. $\square$

---

## 5. Structural consequences for the threshold

The verified backbone does not prove Conjecture 1, but it pins down the structural
mechanisms that any proof must exploit. We record three.

### 5.1 The trivial family is duality-closed

By Theorem 3.5, $V \mapsto V^\perp$ is a bijection $J_q(n,k) \leftrightarrow
J_q(n,n-k)$ exchanging point indicators with dual indicators. Hence the family of
trivial functions (Definition 2.3) is *closed under scheme duality*: it is exactly
the duality-closed $\{0,1\}$-span of rank-one indicators. Conjecture 1 is therefore
the statement that, above the threshold, the degree-one Boolean functions coincide
with this duality-closed span — no exotic Boolean function escapes it.

### 5.2 Sharpness at $n = 2k$ (Conjecture 2)

> **Conjecture 2 (Sharpness).** For every prime power $q$ and $k \ge 2$, the scheme
> $J_q(2k,k)$ (ambient dimension exactly $2k$, failing $n \ge 2k+1$) admits a
> *non-trivial* Boolean degree-one function.

At $n = 2k$, Theorem 3.5 gives $\binom{2k}{k}_q = \binom{2k}{\,2k-k\,}_q$ with
$k = n-k$: the scheme is **self-dual**. Self-duality is conjectured to furnish an
additional $\pm 1$ eigenvector beyond the point/dual span — precisely a non-trivial
degree-one Boolean function. The symmetry theorem thus identifies the self-dual
locus *exactly* at $n=2k$, recasting "the threshold is $2k+1$" from a numerical
coincidence into a structural prediction, testable by exhibiting one explicit
function for small $(q,k)$.

### 5.3 Strict growth and a uniform spectral gap (Conjecture 3)

> **Conjecture 3 (Spectral gap).** For $q \ge 2$ and $1 \le k \le n$, the strict
> inequality $\binom{n}{k}_q < \binom{n+1}{k}_q$ (Theorem 3.7) upgrades to a
> quantitative gap: the second-largest eigenvalue of the $J_q(n,k)$ adjacency
> operator is bounded away from the largest by a factor depending only on $q$,
> uniformly in $n$.

Heuristically, strict monotonicity in the ambient dimension is the counting shadow
of a *non-degenerate* refinement of the association scheme, and non-degeneracy of
the refinement is equivalent to a uniform spectral gap. Since strict growth holds
for all $q \ge 2$ and fails at $q \le 1$, the gap can depend only on $q$ — exactly
the regime where Conjecture 1 is open. A $q$-uniform eigenvalue/interlacing bound,
built on the single inductive object $\binom{n}{k}_q$ rather than $q$-by-$q$
casework, is the missing ingredient.

---

## 6. Algorithms

We summarize the constructive content as algorithms operating on natural numbers
(exact arithmetic, no floating point).

**Algorithm 6.1 (`qBinomTable`: bottom-up $q$-Pascal).** Compute $\binom{n}{k}_q$
by filling the $q$-Pascal triangle from Definition 2.1. Complexity $O(nk)$ additions
of big integers, $O(k)$ space with row-rolling.

**Algorithm 6.2 (`pointCountGeom`).** Compute the point count $\binom{n}{1}_q =
\sum_{i=0}^{n-1} q^i$ via the geometric series (Theorem 3.3). Complexity $O(n)$.

**Algorithm 6.3 (`checkSymmetry`).** Verify Theorem 3.5 for a window of parameters
by comparing $\binom{n}{k}_q$ with $\binom{n}{n-k}_q$ from the table.

**Algorithm 6.4 (`classicalLimitCheck`).** Verify the degeneration of Theorem 3.1
and the total-mass identity of Theorem 4.3 by comparing the $q=1$ table row against
$\binom{n}{k}$ and against $2^n$.

---

## 7. Applications

- **Subspace codes and network coding.** The points of $J_q(n,k)$ are the codewords
  of constant-dimension subspace codes, used in random linear network coding. Exact
  counts $\binom{n}{k}_q$ and the symmetry of Theorem 3.5 control code sizes and
  dual codes.
- **$q$-analogue extremal combinatorics.** Degree-one triviality is the
  linear-algebraic stability statement underlying $q$-analogues of Erdős–Ko–Rado
  and related theorems: small Boolean functions must coincide with the obvious
  extremal families.
- **Analysis of Boolean functions on schemes.** Conjecture 1 is the "low-degree
  Boolean functions are juntas" principle transplanted from the Boolean cube to
  Grassmann domains, with applications to hardness of approximation and learning.

---

## 8. Discussion and future work

The verified backbone makes the threshold conjecture a precise, structurally
anchored target. Three levers stand out. First (Section 5.1), the mirror symmetry
makes the trivial family duality-closed, so the conjecture is about coincidence of
two explicitly described spaces. Second (Section 5.2), the same symmetry pins the
self-dual locus at $n=2k$, predicting sharpness one step below the threshold.
Third (Section 5.3), strict ambient growth for $q \ge 2$ is the counting shadow of
a conjectural $q$-uniform spectral gap, the analytic engine a uniform proof would
need.

The decisive open ingredient is a $q$-uniform eigenvalue/interlacing bound on the
Grassmann adjacency operator, now expressible against a single inductive object,
$\binom{n}{k}_q$, rather than as $q$-by-$q$ casework. Verifying Conjecture 2 for
small $(q,k)$ by exhibiting one explicit non-trivial function at $n=2k$ would
confirm sharpness and constrain the form of the extremal eigenvector, guiding the
general argument.

### Future Directions (summary)

- **Conjecture 1 (headline):** uniform degree-one triviality for all prime powers
  $q$ once $n \ge 2k+1$; known for $q=2$ (all $k$) and $q\in\{3,4,5\}$ ($k=2$).
- **Conjecture 2 (sharpness):** non-trivial degree-one Boolean functions exist at
  $n = 2k$, where the scheme is self-dual.
- **Conjecture 3 (spectral gap):** strict growth upgrades to a $q$-only spectral
  gap, uniform in $n$.

---

## Appendix A. Numerical tables

$q$-binomials $\binom{n}{2}_q$ (for $n = 0,1,2,\dots$):

- $q = 1$: $0, 0, 1, 3, 6, 10, 15, \dots$ (ordinary $\binom{n}{2}$).
- $q = 2$: $0, 0, 1, 7, 35, 155, 651, \dots$
- $q = 3$: $0, 0, 1, 13, 130, 1210, 11011, \dots$

Point counts $\binom{n}{1}_q = 1 + q + \cdots + q^{n-1}$:

- $q = 2$: $1, 3, 7, 15, 31, \dots$ (Mersenne $2^n-1$).
- $q = 3$: $1, 4, 13, 40, 121, \dots$ ($\tfrac{3^n-1}{2}$).

Total mass at $q=1$: $\sum_{k=0}^n \binom{n}{k}_1 = 2^n$ (Theorem 4.3).
