# The Global Spectral Ihara Zeta Function of a Graph: The Riemann Hypothesis is Equivalent to the Ramanujan Property

## Abstract

To every finite connected $(q+1)$-regular graph one may attach an Ihara zeta
function, an analogue of the Riemann and Dedekind zeta functions built from the
graph's closed non-backtracking geodesics. By the Bass–Ihara determinant
formula, the nontrivial part of this zeta is governed by the **global spectral
zeta**
$$
Z^{-1}(u) = \prod_{i=1}^{n}\big(1 - \lambda_i u + q u^2\big),
$$
a product of quadratic Euler factors, one for each adjacency eigenvalue
$\lambda_i$, each factor having the exact shape $1 - a T + p T^2$ of an
elliptic-curve local factor. We develop the analytic number theory of this
object and prove that its **Riemann Hypothesis** — the assertion that every zero
lies on the critical circle $|u| = 1/\sqrt{q}$ — is *equivalent* to the graph
being a **Ramanujan graph**, i.e. to every eigenvalue satisfying the Ramanujan
bound $\lambda_i^2 \le 4q$. We establish, in full, the normalization
$Z^{-1}(0) = 1$, Euler-product multiplicativity over disjoint unions of spectra,
the global functional equation $(qu^2)^n Z^{-1}(1/(qu)) = Z^{-1}(u)$, the local
and global Riemann Hypotheses (Ramanujan $\Rightarrow$ RH), the nonvanishing
reformulation off the critical circle, and the converse (non-Ramanujan
$\Rightarrow$ RH fails), culminating in the equivalence RH $\Leftrightarrow$
Ramanujan. We give proof sketches, numerical demonstrations, and applications to
expander graph certification.

**Keywords.** Ihara zeta function, Ramanujan graph, Riemann Hypothesis, adjacency
spectrum, Euler product, functional equation, expander graph, Bass–Ihara formula.

---

## 1. Introduction

The Riemann zeta function $\zeta(s) = \prod_p (1 - p^{-s})^{-1}$ encodes the
distribution of the prime numbers, and the Riemann Hypothesis — that its
nontrivial zeros lie on the critical line $\Re(s) = 1/2$ — is the central open
problem of analytic number theory. A recurrent theme of twentieth-century
mathematics is that such zeta functions have *combinatorial* and *geometric*
avatars whose Riemann Hypotheses are provable. The most celebrated is the family
of zeta functions of curves over finite fields, for which the Riemann Hypothesis
is a theorem (part of the Weil conjectures) and takes the form of the
Ramanujan–Petersson bound on Frobenius eigenvalues.

There is a beautiful discrete member of this family: the **Ihara zeta function**
of a finite graph, introduced by Ihara and developed by Serre, Sunada, Hashimoto,
Bass, and Stark–Terras, among others. It is defined by an Euler product over the
graph's **prime geodesics** — the equivalence classes of closed, tailless,
non-backtracking walks that are not powers of shorter walks — in complete analogy
with the Euler product over primes. Remarkably, for a $(q+1)$-regular graph this
infinite product is a rational function, given by the **Bass–Ihara determinant
formula**
$$
\zeta_G(u)^{-1} = (1 - u^2)^{(n-1)(q-1)/2}\,\det\!\big(I - Au + q u^2 I\big),
\tag{1}
$$
where $A$ is the adjacency matrix, $n$ the number of vertices, and each vertex has
degree $q+1$.

The poles of $\zeta_G$ and the number-theoretic content of (1) are controlled
entirely by the determinant factor, which decomposes over the adjacency spectrum
$\{\lambda_i\}_{i=1}^n$ into a product of quadratic **Euler factors**
$$
p(\lambda, q, u) = 1 - \lambda u + q u^2,
$$
each of the elliptic-curve type $1 - aT + pT^2$. This paper isolates and studies
the resulting **global spectral zeta**
$$
Z^{-1}(u) = \prod_{i=1}^{n} p(\lambda_i, q, u) = \det\!\big(I - Au + q u^2 I\big).
$$

Our central result is the following exact dichotomy.

> **Main Theorem (RH $\Leftrightarrow$ Ramanujan).** Let $q > 0$ and let
> $\lambda_1, \dots, \lambda_n \in \mathbb{R}$ be the spectrum. Every zero $z$ of
> $Z^{-1}$ satisfies $|z| = 1/\sqrt{q}$ if and only if $\lambda_i^2 \le 4q$ for
> every $i$.

The "if" direction is the graph Riemann Hypothesis: for a Ramanujan graph, all
zeros lie on the critical circle. The "only if" direction is its sharp converse:
a single eigenvalue exceeding the Ramanujan window produces a zero off the
circle. Along the way we prove the structural properties that make $Z^{-1}$ a
bona fide zeta function: normalization, Euler-product multiplicativity, and a
functional equation whose fixed-point set is exactly the critical circle.

**Organization.** Section 2 fixes definitions. Section 3 treats the structural
properties (normalization, multiplicativity, functional equation). Section 4
proves the local Riemann Hypothesis and its converse for a single Euler factor.
Section 5 assembles the global equivalence. Section 6 gives algorithms and
numerical demonstrations. Section 7 discusses applications and Section 8 future
directions.

---

## 2. Definitions

Throughout, $q$ is a positive parameter (for a $(q+1)$-regular graph it is a
positive integer, but the analysis needs only $q > 0$), and the spectrum is a
finite family $\lambda : I \to \mathbb{C}$ indexed by a finite set $s \subseteq
I$. We write $\|z\|$ for the modulus of a complex number and $\operatorname{Nm}(z)
= \|z\|^2$ for its squared modulus.

**Definition 2.1 (Local Euler factor).** For $\lambda, q, u \in \mathbb{C}$ the
*local factor* at the spectral value $\lambda$ is
$$
p(\lambda, q, u) = 1 - \lambda u + q u^2.
$$
It is the quadratic in $u$ whose two roots multiply to $1/q$ and sum to
$\lambda/q$; formally it matches the Euler factor $1 - aT + pT^2$ of an elliptic
curve, with $\lambda$ the analogue of the trace of Frobenius and $q$ the analogue
of the residue characteristic.

**Definition 2.2 (Global spectral zeta).** For a finite index set $s$, a spectrum
$\lambda : I \to \mathbb{C}$, and parameters $q, u$, the *global spectral Ihara
zeta* (in its reciprocal, entire form) is
$$
Z^{-1}_s(u) = \prod_{i \in s} p(\lambda_i, q, u).
$$
When $s$ ranges over all $n$ vertices this equals $\det(I - Au + qu^2 I)$, the
nontrivial factor of the Bass–Ihara formula (1).

**Definition 2.3 (Critical circle).** For $q > 0$ the *critical circle* is
$\{u \in \mathbb{C} : |u| = 1/\sqrt{q}\}$. It is characterized intrinsically as
the fixed-point locus of the Ihara reflection $u \mapsto 1/(qu)$ (Section 3.3).

**Definition 2.4 (Riemann Hypothesis for $Z^{-1}$).** We say $Z^{-1}$ *satisfies
the Riemann Hypothesis* if every zero $z$ of $Z^{-1}$ lies on the critical
circle, $|z| = 1/\sqrt{q}$.

**Definition 2.5 (Ramanujan bound).** A real spectral value $\lambda$ satisfies
the *Ramanujan bound* if $\lambda^2 \le 4q$. A graph is a *Ramanujan graph* when
every nontrivial adjacency eigenvalue satisfies this bound; equivalently
$|\lambda| \le 2\sqrt{q}$, matching the bound $|a| \le 2\sqrt{p}$ of the
Hasse–Weil / Ramanujan–Petersson theory.

---

## 3. Structural properties

We first establish that $Z^{-1}$ behaves like a zeta function.

### 3.1 Normalization

**Proposition 3.1 (Normalization).** For every finite $s$, spectrum $\lambda$,
and $q$,
$$
Z^{-1}_s(0) = 1.
$$

*Proof sketch.* At $u = 0$ each factor is $p(\lambda_i, q, 0) = 1 - 0 + 0 = 1$,
and the empty-to-full product of ones is $1$. $\square$

This is the discrete analogue of $\zeta(s) \to 1$ as $\Re(s) \to \infty$: the
zeta function is normalized to the value $1$ at the base point of its expansion.

### 3.2 Euler-product multiplicativity

**Proposition 3.2 (Multiplicativity over disjoint unions).** If $s$ and $t$ are
disjoint finite index sets, then
$$
Z^{-1}_{s \cup t}(u) = Z^{-1}_{s}(u)\cdot Z^{-1}_{t}(u).
$$

*Proof sketch.* The product defining $Z^{-1}_{s \cup t}$ ranges over
$s \cup t$; disjointness lets the product over a union split as the product over
$s$ times the product over $t$. $\square$

This is the graph analogue of the multiplicativity of a Dedekind zeta function as
a product over its primes: partitioning the spectrum multiplies the zetas. In
particular the spectral zeta of a disjoint union of graphs is the product of the
individual spectral zetas, since the spectrum of a disjoint union is the union of
spectra.

### 3.3 Functional equation

The critical circle owes its distinguished status to a reflection symmetry.

**Lemma 3.3 (Local functional equation).** For $q \neq 0$ and $u \neq 0$,
$$
q u^2 \cdot p\!\left(\lambda, q, \frac{1}{qu}\right) = p(\lambda, q, u).
$$

*Proof sketch.* Substitute $1/(qu)$ into $p$ and clear denominators:
$$
q u^2\Big(1 - \tfrac{\lambda}{qu} + q\cdot\tfrac{1}{q^2u^2}\Big)
 = q u^2 - \lambda u + 1 = p(\lambda, q, u).
$$
$\square$

**Theorem 3.4 (Global functional equation).** For a spectrum $\lambda$ on a
finite set $s$ of cardinality $n = |s|$, and $q \neq 0$, $u \neq 0$,
$$
(q u^2)^{n}\, Z^{-1}_s\!\left(\frac{1}{qu}\right) = Z^{-1}_s(u).
$$

*Proof sketch.* Apply Lemma 3.3 factorwise: for each $i \in s$,
$q u^2\, p(\lambda_i, q, 1/(qu)) = p(\lambda_i, q, u)$. Taking the product over the
$n$ indices, the automorphy factors multiply to $(qu^2)^n$ and the right-hand
factors reassemble into $Z^{-1}_s(u)$. $\square$

The reflection $u \mapsto 1/(qu)$ is an involution whose fixed points satisfy
$u^2 = 1/q$, i.e. $|u| = 1/\sqrt{q}$: the critical circle is *precisely* the fixed
locus of the symmetry, exactly as the critical line $\Re(s) = 1/2$ is fixed by
$s \mapsto 1 - s$. This structural fact is the geometric reason the zeros want to
lie on the circle.

---

## 4. The local Riemann Hypothesis

The entire arithmetic content reduces to a single quadratic factor.

### 4.1 Ramanujan implies critical-circle roots

**Theorem 4.1 (Local RH, squared form).** Let $\lambda, q \in \mathbb{R}$ with
$q > 0$ and $\lambda^2 \le 4q$. If $z \in \mathbb{C}$ satisfies
$p(\lambda, q, z) = 0$, then
$$
\operatorname{Nm}(z) = \|z\|^2 = \frac{1}{q}.
$$

*Proof sketch.* Write $z = x + iy$ and expand $1 - \lambda z + q z^2 = 0$ into
real and imaginary parts:
$$
1 - \lambda x + q(x^2 - y^2) = 0, \qquad -\lambda y + 2 q x y = 0.
$$
The imaginary equation gives $y(\,2qx - \lambda\,) = 0$, so either $y = 0$ or
$x = \lambda/(2q)$.

- If $y = 0$, the root is real and the real equation reads
  $q x^2 - \lambda x + 1 = 0$. Its discriminant is $\lambda^2 - 4q \le 0$; a real
  root can exist only in the boundary case $\lambda^2 = 4q$, where
  $x = \lambda/(2q)$ and $x^2 = \lambda^2/(4q^2) = 1/q$, so
  $\operatorname{Nm}(z) = 1/q$.
- If $x = \lambda/(2q)$, substitute into the real equation:
  $1 - \lambda\cdot\frac{\lambda}{2q} + q\big(\frac{\lambda^2}{4q^2} - y^2\big) = 0$,
  which simplifies to $q y^2 = 1 - \frac{\lambda^2}{4q}$, hence
  $$
  \operatorname{Nm}(z) = x^2 + y^2 = \frac{\lambda^2}{4q^2}
     + \frac{1}{q} - \frac{\lambda^2}{4q^2} = \frac{1}{q}.
  $$

In all cases $\operatorname{Nm}(z) = 1/q$. (The Ramanujan bound guarantees the
value $1 - \lambda^2/(4q) \ge 0$ needed for a genuine root.) $\square$

Equivalently $\|z\| = 1/\sqrt{q}$: under the Ramanujan bound both roots of the
Euler factor sit exactly on the critical circle.

### 4.2 Non-Ramanujan produces an off-circle root

**Theorem 4.2 (Off-circle root).** Let $\lambda, q \in \mathbb{R}$ with $q > 0$
and $\lambda^2 > 4q$. Then the local factor has a real root
$$
z = \frac{\lambda + \sqrt{\lambda^2 - 4q}}{2q}
$$
with $\|z\| \neq 1/\sqrt{q}$.

*Proof sketch.* With $\lambda^2 - 4q > 0$ the quadratic $q z^2 - \lambda z + 1 = 0$
has two distinct real roots
$z_\pm = \frac{\lambda \pm \sqrt{\lambda^2 - 4q}}{2q}$, and one verifies directly
that $p(\lambda, q, z_+) = 0$. Their product is $z_+ z_- = 1/q$ while $z_+ \neq
z_-$, so they cannot both equal $\pm 1/\sqrt{q}$; the larger-magnitude root
$z_+$ has $|z_+| > 1/\sqrt{q}$, hence $\|z_+\| \neq 1/\sqrt{q}$. $\square$

Thus a single eigenvalue outside the Ramanujan window forces a zero strictly off
the critical circle.

---

## 5. The global equivalence

We now globalize. The key elementary fact is that a finite product vanishes iff
one of its factors vanishes.

**Theorem 5.1 (Global RH: Ramanujan $\Rightarrow$ RH).** Let $q > 0$ and
$\lambda : I \to \mathbb{R}$ with $\lambda_i^2 \le 4q$ for all $i \in s$. If
$z \in \mathbb{C}$ satisfies $Z^{-1}_s(z) = 0$, then $\|z\| = 1/\sqrt{q}$.

*Proof sketch.* Since $Z^{-1}_s(z) = \prod_{i \in s} p(\lambda_i, q, z) = 0$, some
factor vanishes: there is $i \in s$ with $p(\lambda_i, q, z) = 0$. As
$\lambda_i^2 \le 4q$, Theorem 4.1 gives $\operatorname{Nm}(z) = 1/q$, i.e.
$\|z\| = \sqrt{1/q} = 1/\sqrt{q}$. $\square$

**Corollary 5.2 (Nonvanishing off the circle).** Under the hypotheses of Theorem
5.1, if $\|z\| \neq 1/\sqrt{q}$ then $Z^{-1}_s(z) \neq 0$. Equivalently, for a
Ramanujan graph $Z^{-1}$ has no zeros off the critical circle.

*Proof sketch.* Contrapositive of Theorem 5.1. $\square$

**Theorem 5.3 (Converse: non-Ramanujan $\Rightarrow$ RH fails).** Let $q > 0$ and
suppose some $i_0 \in s$ has $\lambda_{i_0}^2 > 4q$. Then there exists
$z \in \mathbb{C}$ with $Z^{-1}_s(z) = 0$ and $\|z\| \neq 1/\sqrt{q}$.

*Proof sketch.* By Theorem 4.2 the factor $p(\lambda_{i_0}, q, \cdot)$ has a root
$z$ with $\|z\| \neq 1/\sqrt{q}$. Because $i_0 \in s$, this $z$ makes one factor
of the product vanish, so $Z^{-1}_s(z) = 0$; yet $z$ is off the circle. $\square$

Combining Theorems 5.1 and 5.3 yields the headline result.

**Theorem 5.4 (RH $\Leftrightarrow$ Ramanujan).** For $q > 0$ and real spectrum
$\lambda$ on a finite set $s$,
$$
\Big(\forall z,\ Z^{-1}_s(z) = 0 \Rightarrow \|z\| = \tfrac{1}{\sqrt{q}}\Big)
\quad\Longleftrightarrow\quad
\big(\forall i \in s,\ \lambda_i^2 \le 4q\big).
$$

*Proof sketch.* ($\Leftarrow$) is Theorem 5.1. ($\Rightarrow$) is the
contrapositive of Theorem 5.3: if some $\lambda_{i_0}^2 > 4q$, then there is an
off-circle zero, contradicting RH; hence RH forces the Ramanujan bound at every
index. $\square$

This is the exact discrete counterpart of the equivalence, for curves over finite
fields, between the Riemann Hypothesis (all Frobenius eigenvalues of absolute
value $\sqrt{q}$) and the Hasse–Weil bound. Here the "curve" is a network, the
"Frobenius eigenvalues" are the adjacency eigenvalues, and the Riemann Hypothesis
is decidable by inspection of the spectrum.

---

## 6. Algorithms and numerical demonstrations

Every ingredient is finitely computable. We record the core algorithms.

**Algorithm A (Spectral RH certificate).** Given the adjacency spectrum
$\{\lambda_i\}$ and the regularity parameter $q$, decide whether the graph is
Ramanujan / satisfies RH:
1. For each eigenvalue $\lambda_i$, test $\lambda_i^2 \le 4q$.
2. Return **RH holds** iff all tests pass; otherwise return a witness $i_0$ with
   $\lambda_{i_0}^2 > 4q$ and the off-circle root
   $z = (\lambda_{i_0} + \sqrt{\lambda_{i_0}^2 - 4q})/(2q)$.

Complexity: $O(n)$ arithmetic operations given the spectrum (or $O(n^3)$ to first
diagonalize $A$).

**Algorithm B (Zero locator).** For each eigenvalue $\lambda_i$, compute the two
roots of $q z^2 - \lambda_i z + 1 = 0$ by the quadratic formula; when
$\lambda_i^2 \le 4q$ they are complex conjugates of modulus $1/\sqrt{q}$, and one
verifies $|z| = 1/\sqrt{q}$ numerically as a check on Theorem 4.1.

**Algorithm C (Functional-equation verifier).** Evaluate $Z^{-1}(u)$ and
$(qu^2)^n Z^{-1}(1/(qu))$ at sample points and confirm equality to machine
precision, empirically validating Theorem 3.4.

Concrete spectra illustrate the dichotomy:

- The complete graph $K_{q+2}$ is $(q+1)$-regular with nontrivial eigenvalue
  $\lambda = -1$; since $1 \le 4q$ for $q \ge 1$, it is Ramanujan and all zeros
  lie on $|u| = 1/\sqrt{q}$.
- Cycle graphs $C_n$ are $2$-regular ($q = 1$) with eigenvalues
  $2\cos(2\pi k/n) \in [-2, 2]$, all satisfying $\lambda^2 \le 4$; they are
  Ramanujan, and the roots parametrize the unit circle $|u| = 1$.
- A regular graph engineered to have an eigenvalue $\lambda$ with $\lambda^2 > 4q$
  (a non-expander) yields two real reciprocal-in-$q$ roots straddling the circle,
  exhibiting explicit RH failure.

The accompanying demonstration code realizes Algorithms A–C, verifies the
functional equation, and plots the zeros of $Z^{-1}$ against the critical circle
for Ramanujan and non-Ramanujan spectra.

---

## 7. Applications

**Expander certification.** Ramanujan graphs are optimal expanders — sparse
graphs with spectral gap as large as the Alon–Boppana bound permits — and are
foundational in the construction of error-correcting codes, pseudorandom
generators, superconcentrators, and fault-tolerant networks. Theorem 5.4 recasts
"optimal expansion" as an analytic Riemann Hypothesis: to certify a network as an
optimal expander it suffices to confirm that the zeros of one explicit polynomial
$Z^{-1}$ all lie on the critical circle. Conversely, an off-circle zero is a
certificate of a bottleneck (an eigenvalue outside the Ramanujan window).

**A provable model of the Weil RH.** The local factor $1 - \lambda u + qu^2$ is
literally the Euler factor $1 - aT + pT^2$ of a curve. The graph theory thus
furnishes a completely elementary, fully provable model of the Riemann Hypothesis
for curves over finite fields, with the Ramanujan bound $|\lambda| \le 2\sqrt{q}$
playing the role of $|a| \le 2\sqrt{p}$. It is a pedagogical and conceptual
bridge between spectral graph theory and arithmetic geometry.

**Zeta-function bookkeeping via multiplicativity.** Proposition 3.2 lets one
assemble the spectral zeta of a large network from those of its components, and
underlies the study of how $Z^{-1}$ factors under graph coverings — the analogue
of Artin factorization of Dedekind zetas.

---

## 8. Discussion and future work

We have isolated the global spectral Ihara zeta $Z^{-1}(u) = \prod_i (1 -
\lambda_i u + qu^2)$ and proved, completely and elementarily, the equivalence
between its Riemann Hypothesis and the Ramanujan property of the graph, together
with the structural triad of normalization, Euler-product multiplicativity, and a
functional equation whose fixed locus is the critical circle. The following
directions extend the theory.

1. **From spectrum to adjacency matrix.** Connect $Z^{-1}$ directly to
   $\det(I - Au + qu^2 I)$ via the characteristic polynomial and eigenvalue
   products, so that the results are stated for a $(q+1)$-regular graph $G$ and its
   adjacency matrix $A$ rather than an abstract spectrum.

2. **The full Bass–Ihara formula.** Incorporate the $(1 - u^2)^{(n-1)(q-1)/2}$
   prefactor and prove the determinant identity (1) for regular graphs, deducing
   the complete pole structure of $\zeta_G$ itself.

3. **Prime geodesic counting.** Relate $u\,\frac{d}{du}\log Z_G(u)$ to the number
   $N_m$ of closed non-backtracking tailless geodesics of length $m$, yielding the
   graph analogue of the explicit formula and a "prime geodesic theorem" for
   Ramanujan graphs.

4. **Weighted / irregular graphs.** Generalize the local factor to
   $\det(I - Au + Qu^2)$ with a diagonal degree matrix $Q$, extending the RH
   dichotomy beyond the regular case.

5. **Counting zeros on the circle.** Upgrade the qualitative dichotomy to an exact
   count: the number of zeros of $Z^{-1}$ on $|u| = 1/\sqrt{q}$ equals twice the
   number of eigenvalues in the Ramanujan window, using root multiplicities.

6. **Zeta of coverings.** Study how $Z^{-1}$ factors under graph coverings (the
   analogue of Artin factorization of Dedekind zetas), building on the
   multiplicativity of Proposition 3.2.

---

## References (classical, for context)

- Y. Ihara, *On discrete subgroups of the two by two projective linear group over
  $\mathfrak{p}$-adic fields*, J. Math. Soc. Japan (1966).
- H. Bass, *The Ihara–Selberg zeta function of a tree lattice*, Internat. J.
  Math. (1992).
- A. Terras, *Zeta Functions of Graphs: A Stroll through the Garden*, Cambridge
  University Press (2011).
- A. Lubotzky, R. Phillips, P. Sarnak, *Ramanujan graphs*, Combinatorica (1988).
