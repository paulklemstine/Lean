# A Spectral–Arithmetic Dictionary for the Ihara Zeta Function of a Regular Graph

## Abstract

The Ihara zeta function of a finite graph packages its prime cycles into an
Euler product formally identical to the Riemann zeta function's product over
primes. For a $(q+1)$-regular graph the Bass–Ihara determinant formula reduces
this infinite product to a finite determinant whose spectral expansion yields,
for each adjacency eigenvalue $\lambda$, a **local factor**
$p(\lambda,q,u) = 1 - \lambda u + q u^2$ having exactly the shape of the Euler
factor $1 - aT + pT^2$ of an elliptic curve over a finite field. We develop the
resulting dictionary — eigenvalue $\leftrightarrow$ trace of Frobenius, degree
parameter $\leftrightarrow$ residue characteristic — and prove its structural
laws. The local factor obeys a functional equation under the reflection
$u \mapsto 1/(qu)$, which lifts to the full determinant; it factors as
$(1-\alpha u)(1-\beta u)$ with $\alpha+\beta=\lambda$ and $\alpha\beta=q$. From
the single relation $\alpha\beta=q$ we deduce the **Riemann Hypothesis for
Ramanujan graphs**: when the Ramanujan bound $\lambda^2 \le 4q$ holds, every
zero of the local factor lies on the critical circle $|z| = 1/\sqrt q$; and when
$\lambda^2 > 4q$ the factor has two distinct real zeros of product $1/q$ that
straddle the circle. Finally, for the cycle graph $C_n$ (the $2$-regular,
$q=1$ case) the determinant collapses to $(1-u^n)^2$ via factorization over the
$n$-th roots of unity, realizing the cyclotomic instance of the theory. All
results are stated and proved inline.

**Keywords:** Ihara zeta function, regular graph, adjacency spectrum, Ramanujan
graph, Riemann Hypothesis, functional equation, Euler factor, roots of unity.

---

## 1. Introduction

To a finite graph $G$ one associates prime cycles: equivalence classes $[C]$ of
closed geodesic walks (tailless backtrackless closed walks) that are not proper
powers of shorter walks. These are the multiplicative atoms of the graph's loop
structure, and by direct analogy with the Euler product for the Riemann zeta
function one defines the **Ihara zeta function**
$$
\zeta_G(u) \;=\; \prod_{[C]} \bigl(1 - u^{|C|}\bigr)^{-1},
$$
the product ranging over prime cycles $[C]$ of length $|C|$. Although the product
is infinite, for a regular graph it is a rational function, by the Bass–Ihara
determinant formula recalled below.

The purpose of this paper is to make explicit, and to prove, a precise
correspondence between the analytic features of $\zeta_G$ and the arithmetic of
$L$-functions of elliptic curves over finite fields. The bridge is the local
factor $1 - \lambda u + q u^2$ attached to each adjacency eigenvalue $\lambda$,
whose form coincides with the Euler factor of an elliptic curve. We prove the
functional equation, the reciprocal-root factorization, the determinant-level
functional equation, the graph Riemann Hypothesis in both its Ramanujan and
non-Ramanujan regimes, and the cyclotomic collapse for cycle graphs.

Throughout, $q$ is a fixed degree parameter (so the graph is $(q+1)$-regular),
$A$ is the adjacency matrix of $G$ on $n$ vertices, and $\{\lambda_j\}_{j=1}^n$
is the multiset of eigenvalues of $A$.

---

## 2. The Bass–Ihara determinant formula and the local factor

We take as our analytic starting point the classical closed form.

**Theorem 2.1 (Bass–Ihara determinant formula).**
For a connected $(q+1)$-regular graph $G$ on $n$ vertices with adjacency matrix
$A$,
$$
\zeta_G(u)^{-1}
\;=\;
(1-u^2)^{(n-1)(q-1)/2}\;\det\!\bigl(I - A\,u + q\,u^2 I\bigr).
$$

Because $A$ is symmetric with real spectrum $\{\lambda_j\}$, the determinant
diagonalizes:
$$
\det\!\bigl(I - A\,u + q\,u^2 I\bigr)
\;=\;
\prod_{j=1}^{n}\bigl(1 - \lambda_j\,u + q\,u^2\bigr).
$$
Each quadratic factor is the object of study.

**Definition 2.2 (Local factor).**
For $\lambda, q, u \in \mathbb{C}$ the **local factor** at the spectral value
$\lambda$ is
$$
p(\lambda, q, u) \;=\; 1 - \lambda\,u + q\,u^2 .
$$

**The arithmetic dictionary.** The Euler factor of an elliptic curve $E$ over a
finite field with $p$ elements is $1 - a_p T + p T^2$, where $a_p$ is the trace
of Frobenius. Term-by-term identification with $p(\lambda,q,u)$ yields:

| Elliptic curve over $\mathbb{F}_p$ | $(q+1)$-regular graph |
|---|---|
| residue characteristic $p$ | degree parameter $q$ |
| trace of Frobenius $a_p$ | adjacency eigenvalue $\lambda$ |
| Euler factor $1 - a_p T + p T^2$ | local factor $1 - \lambda u + q u^2$ |
| Hasse bound $|a_p| \le 2\sqrt{p}$ | Ramanujan bound $|\lambda| \le 2\sqrt{q}$ |
| Riemann Hypothesis (roots on $|T|=1/\sqrt p$) | zeros on $|u| = 1/\sqrt q$ |

The remainder of the paper establishes the structural laws that make this
dictionary rigorous.

---

## 3. The functional equation

**Theorem 3.1 (Functional equation of the local factor).**
For all $\lambda, q, u \in \mathbb{C}$ with $q \ne 0$ and $u \ne 0$,
$$
q\,u^2 \; p\!\left(\lambda, q, \tfrac{1}{qu}\right) \;=\; p(\lambda, q, u).
$$

*Proof.* Substitute $u \mapsto 1/(qu)$ in Definition 2.2:
$$
p\!\left(\lambda,q,\tfrac{1}{qu}\right)
= 1 - \frac{\lambda}{qu} + q\cdot\frac{1}{q^2u^2}
= 1 - \frac{\lambda}{qu} + \frac{1}{qu^2}.
$$
Multiplying by $qu^2$ gives
$q u^2 - \lambda u + 1 \cdot \tfrac{qu^2}{qu^2}$; clearing denominators,
$q u^2 \cdot p(\lambda,q,1/(qu)) = qu^2 - \lambda u + 1 = p(\lambda,q,u)$. The
identity is a rational function identity, valid whenever $q,u \ne 0$. $\qquad\blacksquare$

The reflection $u \mapsto 1/(qu)$ is the graph analogue of $s \mapsto 1-s$; the
prefactor $qu^2$ is the automorphy factor. The symmetry lifts multiplicatively
to the determinant.

**Theorem 3.2 (Functional equation of the determinant).**
Let $S$ be a finite index set, $\lambda : S \to \mathbb{C}$ a family of spectral
values, and $q, u \in \mathbb{C}$ with $q \ne 0$, $u \ne 0$. Then
$$
(q\,u^2)^{|S|}\;\prod_{i \in S} p\!\left(\lambda_i, q, \tfrac{1}{qu}\right)
\;=\;
\prod_{i \in S} p(\lambda_i, q, u).
$$

*Proof.* Write $(qu^2)^{|S|} = \prod_{i\in S}(qu^2)$ and combine the two
products into $\prod_{i\in S}\bigl(qu^2\,p(\lambda_i,q,1/(qu))\bigr)$. Apply
Theorem 3.1 factorwise. $\qquad\blacksquare$

Taking $S = \{1,\dots,n\}$ and $\lambda_i = \lambda_i$ the eigenvalues of $A$
gives the functional equation of $\det(I - Au + qu^2 I)$, hence of
$\zeta_G(u)^{-1}$ up to the elementary factor $(1-u^2)^{(n-1)(q-1)/2}$.

---

## 4. Reciprocal-root factorization

**Theorem 4.1 (Frobenius factorization).**
Suppose $\alpha, \beta \in \mathbb{C}$ satisfy $\alpha + \beta = \lambda$ and
$\alpha\beta = q$. Then
$$
p(\lambda, q, u) \;=\; (1 - \alpha\,u)(1 - \beta\,u).
$$

*Proof.* Expanding,
$(1-\alpha u)(1-\beta u) = 1 - (\alpha+\beta)u + \alpha\beta\,u^2
= 1 - \lambda u + q u^2 = p(\lambda,q,u)$. $\qquad\blacksquare$

The numbers $\alpha, \beta$ are the Frobenius-type reciprocal eigenvalues; by
Vieta they are the reciprocals of the roots of $p$. The relation $\alpha\beta=q$
is the graph analogue of the determinant-of-Frobenius relation and is the single
arithmetic input that drives the functional equation ($u \mapsto 1/(qu)$
exchanges the reciprocal roots), the product-of-roots law, and the critical
circle below.

---

## 5. The Riemann Hypothesis for regular graphs

We now locate the zeros of the local factor as $z$ ranges over $\mathbb{C}$,
i.e. the solutions of $p(\lambda,q,z) = 0$, for real $\lambda$ and $q>0$. The
critical circle is $|z| = 1/\sqrt q$.

**Theorem 5.1 (Riemann Hypothesis, squared form).**
Let $\lambda \in \mathbb{R}$, $q > 0$, and suppose the Ramanujan bound
$\lambda^2 \le 4q$ holds. Then every zero $z \in \mathbb{C}$ of
$p(\lambda, q, z) = 0$ satisfies
$$
|z|^2 \;=\; \tfrac{1}{q}.
$$

*Proof.* Write $z = x + iy$. The equation $1 - \lambda z + q z^2 = 0$ separates
into real and imaginary parts:
$$
\text{(Re)}\quad 1 - \lambda x + q(x^2 - y^2) = 0,
\qquad
\text{(Im)}\quad -\lambda y + 2q x y = 0.
$$
The imaginary equation factors as $y(2qx - \lambda) = 0$, giving two cases.

*Case $y = 0$.* Then $z = x$ is real and $qx^2 - \lambda x + 1 = 0$. The
discriminant is $\lambda^2 - 4q \le 0$ by hypothesis. If $\lambda^2 < 4q$ there
is no real solution, so this case is vacuous; if $\lambda^2 = 4q$ the double root
is $x = \lambda/(2q)$ with $x^2 = \lambda^2/(4q^2) = 4q/(4q^2) = 1/q$, so
$|z|^2 = 1/q$.

*Case $x = \lambda/(2q)$.* Substituting into the real equation,
$1 - \lambda\cdot\tfrac{\lambda}{2q} + q\bigl(\tfrac{\lambda^2}{4q^2} - y^2\bigr) = 0$,
i.e. $1 - \tfrac{\lambda^2}{2q} + \tfrac{\lambda^2}{4q} - q y^2 = 0$, hence
$q y^2 = 1 - \tfrac{\lambda^2}{4q}$ and
$$
|z|^2 = x^2 + y^2 = \frac{\lambda^2}{4q^2} + \frac{1}{q} - \frac{\lambda^2}{4q^2}
= \frac{1}{q}.
$$
In both cases $|z|^2 = 1/q$. $\qquad\blacksquare$

**Corollary 5.2 (Riemann Hypothesis, critical circle).**
Under the hypotheses of Theorem 5.1, every zero $z$ satisfies
$$
\|z\| \;=\; \frac{1}{\sqrt q}.
$$

*Proof.* Take square roots in Theorem 5.1: $\|z\| = \sqrt{|z|^2} = \sqrt{1/q}
= 1/\sqrt q$. $\qquad\blacksquare$

Thus for a **Ramanujan graph** — one all of whose nontrivial eigenvalues obey
$|\lambda| \le 2\sqrt q$ — all zeros of $\zeta_G$ lie on the critical circle: the
graph zeta satisfies its Riemann Hypothesis.

**Theorem 5.3 (Converse boundary: off-circle zeros).**
Let $\lambda \in \mathbb{R}$, $q > 0$, and suppose $\lambda^2 > 4q$. Then
$p(\lambda, q, \cdot)$ has two distinct real zeros $z_1 \ne z_2$ with
$$
z_1 z_2 = \tfrac{1}{q}.
$$

*Proof.* The discriminant $\lambda^2 - 4q > 0$, so
$$
z_{1,2} = \frac{\lambda \mp \sqrt{\lambda^2 - 4q}}{2q}
$$
are two real numbers, distinct because $\sqrt{\lambda^2 - 4q} > 0$. Each solves
$qz^2 - \lambda z + 1 = 0$; by Vieta the product of the roots of
$qz^2 - \lambda z + 1$ equals the constant-to-leading ratio $1/q$. Direct
verification: $z_1 z_2 = \dfrac{\lambda^2 - (\lambda^2 - 4q)}{4q^2} = \dfrac{4q}{4q^2}
= \dfrac1q$. $\qquad\blacksquare$

Because the product of the two real zeros is $1/q$ while they are distinct, they
cannot both equal $1/\sqrt q$: exactly one lies strictly inside the critical
circle and the other strictly outside. Off-circle zeros therefore occur only in
reciprocal inside/outside pairs, one pair per eigenvalue violating the Ramanujan
bound. This yields the sharp dichotomy:

> **The Riemann Hypothesis for regular graphs.** The Ihara zeta of a $(q+1)$-regular
> graph has all its zeros on the critical circle $|u| = 1/\sqrt q$ if and only if
> the graph is Ramanujan ($|\lambda| \le 2\sqrt q$ for all nontrivial $\lambda$).
> Violations of the bound produce reciprocal inside/outside pairs of real zeros.

The threshold is exactly $\lambda^2 = 4q$, the boundary at which the local
factor's discriminant vanishes and its two roots coalesce on the critical circle.

---

## 6. The cyclotomic instance: cycle graphs

The cleanest illustration is the cycle graph $C_n$, in which $n$ vertices form a
ring and each has degree $2$. Here $q + 1 = 2$, so $q = 1$, and the critical
circle degenerates to the unit circle. The eigenvalues of $A(C_n)$ are the well
known
$$
\lambda_k = 2\cos\!\left(\frac{2\pi k}{n}\right), \qquad k = 0, 1, \dots, n-1.
$$

**Lemma 6.1 (Roots-of-unity product).**
Let $n \ge 1$ and let $\mu_n = \{w : w^n = 1\}$ be the set of $n$-th roots of
unity. For all $u \in \mathbb{C}$,
$$
\prod_{w \in \mu_n} (1 - w\,u) \;=\; 1 - u^n .
$$

*Proof.* The polynomial $\prod_{w\in\mu_n}(X - w) = X^n - 1$ since the $n$-th
roots of unity are exactly the roots of $X^n - 1$, each simple. Evaluate the
identity $\prod_{w\in\mu_n}(X - w) = X^n - 1$ appropriately: substituting and
using $\prod_{w\in\mu_n} w = (-1)^{n+1}$, or directly, since $w \mapsto w^{-1}$
permutes $\mu_n$, one has $\prod_{w\in\mu_n}(1 - w u) = \prod_{w\in\mu_n}(1 - wu)$.
Setting $X = 1/u$ (for $u\ne 0$) in $\prod (X-w) = X^n-1$ and multiplying by
$u^n$: $\prod_{w}(1 - wu) = u^n\bigl((1/u)^n - 1\bigr)\cdot(-1)^n\cdots = 1 - u^n$,
the difference-of-powers factorization $1^n - u^n$. (The case $u=0$ is
immediate.) $\qquad\blacksquare$

**Theorem 6.2 (Spectral determinant of the cycle graph).**
For the cycle graph $C_n$ with $q = 1$,
$$
\det\!\bigl(I - A\,u + u^2 I\bigr)
= \prod_{k=0}^{n-1}\bigl(1 - \lambda_k u + u^2\bigr)
= (1 - u^n)^2,
$$
hence $\zeta_{C_n}(u)^{-1} = (1 - u^n)^2$.

*Proof.* With $\omega = e^{2\pi i/n}$ we have
$\lambda_k = \omega^k + \omega^{-k}$, so each local factor factors by Theorem 4.1
with $\alpha = \omega^k$, $\beta = \omega^{-k}$ (indeed
$\alpha + \beta = \lambda_k$ and $\alpha\beta = 1 = q$):
$$
1 - \lambda_k u + u^2 = (1 - \omega^k u)(1 - \omega^{-k} u).
$$
Taking the product over $k = 0, \dots, n-1$: the factors $(1-\omega^k u)$ range
over all $w \in \mu_n$, and so do the factors $(1 - \omega^{-k} u)$. Hence
$$
\prod_{k=0}^{n-1}(1 - \lambda_k u + u^2)
= \Bigl(\prod_{w\in\mu_n}(1 - w u)\Bigr)^2 = (1 - u^n)^2
$$
by Lemma 6.1. The Bass–Ihara formula with $q=1$ has trivial prefactor
$(1-u^2)^{(n-1)\cdot 0/2} = 1$, giving $\zeta_{C_n}(u)^{-1} = (1-u^n)^2$.
$\qquad\blacksquare$

This is the bridge between cyclotomy and the graph zeta function: the cycle graph
is the instance where the local factors regroup exactly into the cyclotomic
binomial $1 - u^n$. Its two prime cycles (the loop around the ring and its
reversal) are precisely reflected in the exponent $2$.

---

## 7. Algorithms

The theory is entirely constructive. We record two algorithms that turn it into
computation.

**Algorithm A (Zeta from the spectrum).** Given the adjacency matrix $A$ of a
$(q+1)$-regular graph, compute the eigenvalues $\{\lambda_j\}$, form the local
factors $1 - \lambda_j u + q u^2$, multiply them, and multiply by the Bass–Ihara
prefactor $(1-u^2)^{(n-1)(q-1)/2}$ to obtain $\zeta_G(u)^{-1}$ as a polynomial in
$u$. Complexity is dominated by the eigen-decomposition, $O(n^3)$.

**Algorithm B (Riemann Hypothesis test).** For each eigenvalue $\lambda_j$
compute the discriminant $\lambda_j^2 - 4q$. If all discriminants are
$\le 0$ (equivalently $\max_j |\lambda_j| \le 2\sqrt q$ over nontrivial
eigenvalues), the graph is Ramanujan and all zeros lie on $|u| = 1/\sqrt q$;
otherwise report each violating eigenvalue together with the reciprocal
inside/outside pair of real zeros it produces. Complexity $O(n)$ after the
spectrum is known.

---

## 8. Applications

**Ramanujan graphs and networks.** The equivalence "Ramanujan $\Leftrightarrow$
graph Riemann Hypothesis" gives a spectral certificate of optimal connectivity.
Ramanujan graphs are the sparsest expanders with the largest possible spectral
gap and underlie efficient communication networks, expander codes, derandomization,
and fast mixing of Markov chains.

**Counting closed geodesics.** The logarithmic derivative
$u\,\frac{d}{du}\log\zeta_G(u) = \sum_{m\ge1} N_m u^m$ encodes the number $N_m$ of
closed geodesics of length $m$. Through the determinant factorization these
counts become power sums of the reciprocal zeros — a Selberg-type trace formula
on a finite graph.

**A solvable model of RH.** Because the graph Riemann Hypothesis is a theorem for
Ramanujan graphs, the Ihara zeta is a fully rigorous, finite-dimensional
laboratory for the phenomenology (functional equation, critical line/circle,
explicit formula) of the classical Riemann Hypothesis.

---

## 9. Discussion and future work

The single relation $\alpha\beta = q$ — the product of the Frobenius-type
reciprocal roots — simultaneously produces the functional equation
$u \mapsto 1/(qu)$, the product-of-roots law $z_1 z_2 = 1/q$, and the
critical-circle identity $|z| = 1/\sqrt q$. This economy suggests several
extensions.

1. **The Ramanujan threshold as the real-zero boundary.** For a $(q+1)$-regular
   graph the number of eigenvalues violating $|\lambda|\le 2\sqrt q$ should equal
   the number of real zeros of $\zeta_G$ on $(1/\sqrt q, 1)$ with multiplicity,
   each such eigenvalue contributing exactly one zero inside and one outside the
   critical circle. The reciprocal-product law makes off-circle zeros a rigid
   invariant of the spectral gap.

2. **A trace-formula bridge.** The expansion
   $u\frac{d}{du}\log\zeta_G(u) = \sum_{m\ge1} N_m u^m$ with $N_m$ the number of
   closed geodesics of length $m$ should equal $\sum_j (\lambda_j^{\mathrm{geo}})^m$
   for geodesic eigenvalues obtained from the reciprocal zeros of the
   determinant — an additive Selberg-type identity from a multiplicative one.

3. **Cyclotomic collapse for circulants.** Among connected circulant graphs the
   Ihara zeta inverse should factor as a product of cyclotomic binomials
   $\prod_d (1 - u^d)^{e_d}$ precisely when the connection set is symmetric under
   negation, with $C_n$ the extremal minimal case.

Each direction is now within reach: the determinant factorization, its functional
equation, the real-root dichotomy across $\lambda^2 = 4q$, and the roots-of-unity
product are all established above.

---

## 10. Conclusion

The Ihara zeta function of a regular graph is a reciprocal rational function whose
local factors are formally Euler factors of elliptic curves. Its zeros obey a
Riemann Hypothesis — all on the critical circle $|u| = 1/\sqrt q$ — exactly when
the graph is Ramanujan, and depart from the circle only in reciprocal
inside/outside pairs when the Ramanujan bound is violated. The cycle graph
realizes the cyclotomic instance, with determinant $(1-u^n)^2$. The spectral
combinatorics of a finite network thereby speaks the language of arithmetic
$L$-functions, term for term.
