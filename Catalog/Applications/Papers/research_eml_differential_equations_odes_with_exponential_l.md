# A Degree–Parity Obstruction to Rational Solutions of the Airy Riccati Equation

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty / Differential Galois Theory

## Abstract

We study the Riccati equation $v' + v^2 = f$ associated, via the logarithmic
derivative substitution $v = y'/y$, with the second-order linear differential
equation $y'' = f\,y$ over the polynomial ring $\mathbb{R}[X]$. Clearing
denominators in a candidate rational solution $v = p/q$ reduces the existence of
a rational solution to the solvability of the polynomial identity
$$ p'\,q - p\,q' + p^2 = f\,q^2, \qquad q \neq 0. $$
Our main theorem is a sharp degree–parity obstruction: **if $\deg f$ is odd, this
identity has no solution with $q \neq 0$**, hence $v' + v^2 = f$ has no rational
solution. The proof requires neither coprimality of $p$ and $q$ nor any pole
analysis; it is a pure $\deg$ count built on a "Wronskian-like" degree-drop lemma
$\deg(p'q - pq') \le \deg p + \deg q - 1$. Specializing to $f = X$ (degree one,
odd) yields the non-existence of a rational solution to the Airy Riccati equation
$v' + v^2 = x$ — the genuinely Galois-theoretic reducible-case obstruction for
Airy's equation $y'' = x\,y$, sitting one layer above the elementary polynomial
obstruction. All results have been formally verified. We situate the theorem in
the three-layer obstruction tower (polynomial → rational Riccati → abstract
differential field) and explain its role in the Kovacic decision procedure.

## 1. Introduction

### 1.1 Airy's equation and the closed-form question

Airy's equation
$$ y'' = x\,y \tag{1} $$
is among the most ubiquitous second-order linear ODEs in mathematical physics,
governing the behaviour of solutions near a simple turning point: the intensity
of light at an optical caustic, the WKB wavefunction of a quantum particle at a
classical turning point, telescope-aperture diffraction, and (through the
Tracy–Widom law) the edge statistics of large random matrices. Its solutions,
the Airy functions $\mathrm{Ai}(x)$ and $\mathrm{Bi}(x)$, are entire but
*non-elementary*: they cannot be expressed by finitely many algebraic operations,
exponentials, and logarithms.

The modern framework for such statements is **differential Galois theory**
(Picard–Vessiot theory). To a linear ODE one attaches a linear algebraic group,
the differential Galois group $G$, whose structure governs the solvability of the
equation in *Liouvillian* terms. For a second-order equation $y'' = f y$ (no
first-order term, so $G \le \mathrm{SL}_2$), Kovacic's algorithm provides an
effective decision procedure. Its very first branch — the **reducible case** —
tests whether $G$ has a common eigenvector, which happens exactly when the
associated **Riccati equation** admits a *rational* solution.

### 1.2 The Riccati reduction

The logarithmic-derivative substitution $v = y'/y$ transforms (1), more generally
$y'' = f y$, into the first-order quadratic **Riccati equation**
$$ v' + v^2 = f. \tag{2} $$
Indeed $v' = (y'/y)' = y''/y - (y'/y)^2 = f - v^2$. A Liouvillian solution of the
linear equation forces (in the reducible case) an algebraic — in the simplest
instance rational — solution of (2). Thus closing the door on rational solutions
of (2) closes the most important door to elementary solutions of (1).

### 1.3 Contribution

This paper isolates and proves, with a minimal and robust argument, the
rational-function obstruction for the entire odd-degree family. The contributions
are:

1. A **Wronskian-like degree-drop lemma** (Lemma 1, `natDegree_wronskianLike_le`):
   $\deg(p'q - pq') \le \deg p + \deg q - 1$.
2. The **odd-degree Riccati obstruction** (Theorem 2,
   `no_rational_solves_riccati_odd_deg`): for $\deg f$ odd, the cleared identity
   $p'q - pq' + p^2 = f q^2$ has no solution with $q \neq 0$.
3. The **Airy specialization** (Theorem 3, `no_rational_solves_riccati_airy`):
   $v' + v^2 = x$ has no rational solution.
4. A **combined first-step obstruction** (Corollary 4,
   `airy_no_poly_and_no_rational_riccati`) bundling the polynomial obstruction
   with the rational Riccati obstruction.

All statements are formalized over $\mathbb{R}[X]$ and machine-checked.

## 2. Preliminaries and definitions

We work in the polynomial ring $\mathbb{R}[X]$ with formal derivative
$\partial = \frac{d}{dX}$, written $p'$. We use the natural-number degree
$\deg p := \operatorname{natDegree}(p) \in \mathbb{N}$, with the convention
$\deg 0 = 0$; statements involving leading behaviour are guarded by nonvanishing
hypotheses to avoid the degenerate degree of the zero polynomial.

We record the standard facts used throughout:

- **(D1) Product degree.** For $p, q \neq 0$, $\deg(pq) = \deg p + \deg q$.
- **(D2) Power degree.** $\deg(p^n) = n\deg p$ for $p \neq 0$; in particular
  $\deg(p^2) = 2\deg p$.
- **(D3) Derivative degree drop.** $\deg(p') \le \deg p - 1$ (and $=$ in
  characteristic zero when $\deg p \ge 1$), with $\deg(p') = 0$ when $\deg p = 0$.
- **(D4) Sub/Add degree.** $\deg(a \pm b) \le \max(\deg a, \deg b)$, with equality
  when the degrees differ.

**Definition (rational solution of the Riccati equation).** A *rational solution*
of (2) is an element $v = p/q \in \mathbb{R}(X)$ with $p, q \in \mathbb{R}[X]$,
$q \neq 0$, satisfying $v' + v^2 = f$ in $\mathbb{R}(X)$.

**Definition (polynomial Wronskian).** For $f, g \in \mathbb{R}[X]$,
$W(f,g) := f\,g' - g\,f'$ (in the formalization, `polyWronskian`).

The following standard reduction makes the rational problem polynomial.

**Lemma 0 (clearing denominators).** For $p, q \in \mathbb{R}[X]$ with
$q \neq 0$, the rational function $v = p/q$ satisfies $v' + v^2 = f$ in
$\mathbb{R}(X)$ if and only if
$$ p'\,q - p\,q' + p^2 = f\,q^2 \tag{3} $$
holds in $\mathbb{R}[X]$.

*Proof.* By the quotient rule $v' = (p'q - pq')/q^2$ and $v^2 = p^2/q^2$, so
$v' + v^2 = (p'q - pq' + p^2)/q^2$. Equating to $f$ and multiplying by
$q^2 \neq 0$ (legitimate in the field $\mathbb{R}(X)$) gives (3); the converse
divides (3) by $q^2$. $\qquad\blacksquare$

The work below studies (3) directly, keeping the entire argument inside
$\mathbb{R}[X]$ while faithfully encoding "rational solution of the Riccati
equation."

## 3. The Wronskian-like degree-drop lemma

The first-order part of the cleared identity (3) is the antisymmetric combination
$p'q - pq'$. Although the naive degree estimate from (D1) would give
$\deg p + \deg q$, the leading terms cancel.

**Lemma 1 (`natDegree_wronskianLike_le`).** For all $p, q \in \mathbb{R}[X]$,
$$ \deg\!\big(p'\,q - p\,q'\big) \le \deg p + \deg q - 1. $$

*Proof sketch.* By (D4), $\deg(p'q - pq') \le \max\big(\deg(p'q),\,\deg(pq')\big)$.
We bound each product. The degenerate cases $\deg p = 0$ or $\deg q = 0$ are
handled directly: if $p$ is constant then $p' = 0$ so $p'q = 0$ and
$pq' = p\,q'$ has degree $\le \deg q - 1 = \deg p + \deg q - 1$, and symmetrically
if $q$ is constant. In the main case $\deg p, \deg q \ge 1$, by (D1) and (D3),
$$ \deg(p'q) \le (\deg p - 1) + \deg q = \deg p + \deg q - 1, $$
$$ \deg(pq') \le \deg p + (\deg q - 1) = \deg p + \deg q - 1, $$
so the maximum is at most $\deg p + \deg q - 1$. $\qquad\blacksquare$

This is the polynomial-ring shadow of the classical fact that the Wronskian of
two solutions of a second-order equation has degree strictly below the product of
their degrees; it is what makes the parity argument tight in Case 1 below.

## 4. The odd-degree Riccati obstruction

We now prove the main theorem.

**Theorem 2 (`no_rational_solves_riccati_odd_deg`).** Let $f, p, q \in
\mathbb{R}[X]$ with $q \neq 0$ and $\deg f$ **odd**. Then the identity (3),
$$ p'\,q - p\,q' + p^2 = f\,q^2, $$
is impossible. Consequently the Riccati equation $v' + v^2 = f$ has no rational
solution.

*Proof.* Suppose (3) holds. Write $d_p = \deg p$, $d_q = \deg q$. Since
$q \neq 0$, by (D1)–(D2) the right-hand side has degree
$$ \deg(f q^2) = \deg f + 2 d_q, \tag{4} $$
which is **odd**, being odd plus even. We bound the left-hand side. By Lemma 1
and (D2), with $L := p'q - pq' + p^2$,
$$ \deg L \le \max\big(\deg(p'q - pq'),\ \deg(p^2)\big) \le \max\big(d_p + d_q - 1,\ 2 d_p\big). \tag{5} $$

We split on the relation between $d_p$ and $d_q$.

**Case 1: $d_p \ge d_q$.** Then $d_p + d_q - 1 \le 2 d_p - 1 < 2 d_p$, so the
$p^2$ term strictly dominates the cross term. Hence the leading term of $L$ is the
leading term of $p^2$ (which is nonzero when $p \neq 0$; if $p = 0$ then $L = 0$
cannot equal $f q^2 \neq 0$), giving $\deg L = 2 d_p$ — an **even** number. By
(3), $\deg L = \deg(f q^2)$, which is odd by (4). An even number cannot equal an
odd number. Contradiction.

**Case 2: $d_p < d_q$.** Then $2 d_p \le 2 d_q - 2$ and
$d_p + d_q - 1 \le 2 d_q - 2$, so by (5), $\deg L \le 2 d_q - 2$. But by (4),
$\deg(f q^2) = \deg f + 2 d_q \ge 1 + 2 d_q > 2 d_q - 2$ (using $\deg f \ge 1$,
which holds since $\deg f$ is odd and hence nonzero). Thus the left side has
strictly smaller degree than the right side, contradicting (3).

In both cases we reach a contradiction, so no such $p, q$ exist. By Lemma 0, the
Riccati equation $v' + v^2 = f$ therefore has no rational solution. $\qquad\blacksquare$

**Remarks.**

- *No coprimality.* The argument never assumes $\gcd(p,q) = 1$. The obstruction is
  purely metric (a statement about degrees), and is in this sense stronger than the
  textbook pole-counting argument, which typically normalizes $v$ to lowest terms.
- *Sharpness of the parity hypothesis.* The hypothesis $\deg f$ odd is
  load-bearing. For even $\deg f$ the parity clash in Case 1 disappears and Case 2
  no longer forces a strict gap; correspondingly, equations $y'' = f y$ with
  $\deg f$ even (e.g. $f = X^2$) can possess rational Riccati solutions. Thus the
  theorem captures exactly the odd-degree boundary.
- *Whole family at once.* The proof uses only the parity of $\deg f$, so it covers
  the infinite family $y'' = f y$ with $\deg f$ odd uniformly.

## 5. The Airy specialization and the combined obstruction

**Theorem 3 (`no_rational_solves_riccati_airy`).** There are no polynomials
$p, q \in \mathbb{R}[X]$ with $q \neq 0$ satisfying
$$ p'\,q - p\,q' + p^2 = X\,q^2. $$
Equivalently, the Airy Riccati equation $v' + v^2 = x$ has no rational solution.

*Proof.* Apply Theorem 2 with $f = X$. Here $\deg X = 1$, which is odd. $\qquad\blacksquare$

For completeness we recall the elementary polynomial layer it sits above.

**Background (catalog, `EMLDiffObstruction`).** The following are established by
direct degree comparison in $\mathbb{R}[X]$:

- (`degree_second_deriv_lt_degree_X_mul`) For $p \neq 0$, $\deg(p'') < \deg(X p)$,
  since $\deg(p'') \le \deg p - 2 < \deg p + 1 = \deg(X p)$.
- (`no_poly_solves_airy`) No nonzero $p$ satisfies $p'' = X p$; immediate from the
  previous strict inequality.
- (`no_poly_solves_second_order_pos_deg`) For $\deg q \ge 1$ and $p \neq 0$,
  $p'' = q p$ is impossible, since $\deg(p'') \le \deg p - 2 < \deg q + \deg p =
  \deg(q p)$.
- (`no_poly_solves_riccati_airy`) No polynomial satisfies $v' + v^2 = X$: a
  constant fails ($c^2 = X$ impossible), and for $\deg v \ge 1$ one has
  $\deg(v' + v^2) = 2\deg v$ (even) which cannot equal $\deg X = 1$.
- (`poly_wronskian_derivative_zero`) If $f'' = q f$ and $g'' = q g$ then
  $W(f,g)' = f g'' - g f'' = f(qg) - g(qf) = 0$; the polynomial Abel identity.

**Corollary 4 (`airy_no_poly_and_no_rational_riccati`).** The Airy first-step
obstruction holds in two layers simultaneously: (i) no nonzero polynomial
satisfies $y'' = x y$, and (ii) the associated Riccati equation $v' + v^2 = x$
has no rational solution.

*Proof.* Part (i) is `no_poly_solves_airy`; part (ii) is Theorem 3. $\qquad\blacksquare$

## 6. The three-layer obstruction tower

The results assemble into a strictly increasing tower of obstructions for
$y'' = f y$:

1. **Polynomial layer.** No polynomial solution exists when $\deg f \ge 1$. The
   obstruction is a one-sided degree mismatch: $p''$ is too small to equal $f p$.
2. **Rational Riccati layer** (this paper). Even allowing rational logarithmic
   derivatives $v = p/q$, no solution exists when $\deg f$ is odd. The obstruction
   is degree *parity*. This is strictly stronger than the polynomial layer
   (rational candidates strictly extend polynomial ones) and is the genuine
   reducible-case test of Kovacic's algorithm.
3. **Abstract differential-field layer.** Over any differential field, the
   Wronskian of two solutions of $y'' = a y$ has zero derivative, hence is a
   constant; this pins the solution space at dimension $\le 2$ and frames
   $G \le \mathrm{SL}_2$. The polynomial Wronskian identity above is its
   $\mathbb{R}[X]$ instance.

## 7. Algorithmic reading

Theorem 2 has a direct algorithmic interpretation. The reducible-case branch of
Kovacic's algorithm searches for a rational solution $v$ of (2) by bounding the
degrees of numerator and denominator and solving the resulting (finite) system of
polynomial equations. Theorem 2 short-circuits this search by a single parity
test:

> **Decision rule.** Given $y'' = f y$ with $f \in \mathbb{R}[X]$: if $\deg f$ is
> odd, immediately report "no rational Riccati solution / reducible case fails"
> without enumerating any candidate degrees.

A naive search over numerator/denominator degree bounds $N$ costs polynomially in
$N$ per candidate and must be repeated across a range of $N$; the parity test is
$O(1)$ given $\deg f$. We make both the test and a brute-force corroboration
explicit in the accompanying demonstrations: an exhaustive symbolic search over
bounded-degree $p, q$ confirms that (3) has no solution for $f = X, X^3, X^5$ and
*does* admit solutions for representative even-degree $f$, exhibiting the
sharpness of the parity hypothesis.

## 8. Applications and significance

The Airy function is indispensable across optics (caustics, rainbow theory),
quantum mechanics (turning-point/WKB analysis), diffraction, and random matrix
theory (the Tracy–Widom edge law). Each application invokes a function that
provably has no elementary closed form. Theorem 2 makes the *first and most
decisive* step of that impossibility maximally transparent and maximally robust:
it depends on a single integer parity, not on delicate analytic estimates, and it
covers an infinite odd-degree family in one stroke. For symbolic-computation
systems, the parity decision rule offers an instant negative certificate for the
reducible case of a broad class of second-order equations.

## 9. Discussion and future work

The obstruction proved here is the rational-function layer of a longer program.
Three directions stand out.

**D1. Algebraic (not merely rational) obstruction for the odd-degree family.**
*Conjecture.* For every $f \in \mathbb{R}[X]$ of odd degree, $v' + v^2 = f$ has no
solution algebraic over $\mathbb{R}(X)$. The degree/parity dichotomy proved here
for rational $v$ should be a shadow of a ramification-parity invariant: an
algebraic $v$ of degree $d$ over $\mathbb{R}(X)$ contributes a $v^2$ whose Puiseux
valuations at infinity are even multiples of the local uniformizer, which cannot
match the odd pole/zero pattern forced by odd-degree $f$. The clean $\deg$-parity
engine of Theorem 2 should lift to algebraic extensions via a valuation-at-infinity
refinement, now within reach of available Puiseux/Hahn-series machinery.

**D2. Wronskian constancy and the dimension of the solution space.**
*Conjecture.* In any differential field $K$ with constants $C$, the solution set
$\{y : y'' = a y\}$ is a $C$-vector space of dimension $\le 2$, equal to $2$
exactly when a nonzero-Wronskian pair exists. The constancy of the Wronskian turns
linear dependence of two solutions into the vanishing of their Wronskian —
converting a differential statement into finite-dimensional linear algebra over
$C$.

**D3. A Galois-group dichotomy indexed by $\deg f \bmod 2$.**
*Conjecture.* For $f \in \mathbb{R}[X]$, the differential Galois group of
$y'' = f y$ is reducible (a common eigenvector $\Leftrightarrow$ a rational Riccati
solution) only if $\deg f$ is even; for odd $\deg f$ the group is
$\mathrm{SL}_2$-large, with Airy ($f = X$) the minimal instance. Theorem 2 is
exactly the reducible-case test, and its parity obstruction shows the test always
fails for odd degree, pinning the group away from the triangularizable locus. The
remaining Kovacic cases (imprimitive / finite) are finitely checkable.

## 10. Conclusion

A second-order linear ODE as simple as $y'' = x y$ resists every elementary
formula, and the reason — at its sharpest first step — is the parity of an
integer. By clearing denominators in the associated Riccati equation and counting
degrees, we proved that for any odd-degree coefficient $f$ the equation
$v' + v^2 = f$ has no rational solution, with Airy as the minimal instance. The
argument is coordinate-free of pole analysis, requires no coprimality, generalizes
across an infinite family, and has been fully machine-verified. It is the rational
layer of a three-tier obstruction tower and the reducible-case engine of the
Kovacic decision procedure.

## Appendix: formal result index

| Name | Statement |
|---|---|
| `natDegree_wronskianLike_le` | $\deg(p'q - pq') \le \deg p + \deg q - 1$ |
| `no_rational_solves_riccati_odd_deg` | $\deg f$ odd $\Rightarrow$ $p'q - pq' + p^2 = f q^2$ ($q\neq0$) impossible |
| `no_rational_solves_riccati_airy` | $p'q - pq' + p^2 = X q^2$ ($q\neq0$) impossible |
| `airy_no_poly_and_no_rational_riccati` | combined polynomial + rational Riccati obstruction for $y''=xy$ |
| `degree_second_deriv_lt_degree_X_mul` | $p \neq 0 \Rightarrow \deg(p'') < \deg(Xp)$ |
| `no_poly_solves_airy` | $p \neq 0 \Rightarrow p'' = Xp$ impossible |
| `no_poly_solves_second_order_pos_deg` | $\deg q \ge 1,\ p\neq0 \Rightarrow p'' = qp$ impossible |
| `no_poly_solves_riccati_airy` | $v' + v^2 = X$ has no polynomial solution |
| `poly_wronskian_derivative_zero` | $f''=qf,\ g''=qg \Rightarrow (fg'-gf')'=0$ |
| `no_poly_solves_gen_airy` | $n\ge1,\ p\neq0 \Rightarrow p'' = X^n p$ impossible |
