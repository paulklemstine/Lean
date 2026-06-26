# The Golden Ratio is Badly Approximable: A Norm-Form Approach to Diophantine Approximation

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty — Continued Fractions and Diophantine Approximation

## Abstract

We develop a self-contained, elementary theory of the Diophantine approximation
properties of the golden ratio $\varphi = (1+\sqrt5)/2$, the prototypical *badly
approximable* number and the extremal case of Hurwitz's theorem. Avoiding the
machinery of continued fractions entirely, we base the analysis on a single
algebraic object: the integer **norm form** $N(p,q) = p^2 - pq - q^2$, which
factors over $\mathbb{R}$ as $(p - q\varphi)(p - q\psi)$, where $\psi =
(1-\sqrt5)/2$ is the algebraic conjugate. Because $5$ is not a perfect square,
$N(p,q)$ never vanishes for $q \geq 1$, hence $|N(p,q)| \geq 1$; this integrality
lower bound, combined with the factorization and an explicit estimate
$\sqrt5 < 8/3$, yields the quantitative badly-approximable bound
$|\varphi - p/q| \geq (1/3)/q^2$ for all integers $p$ and $q \geq 1$. We further
establish a Binet-type identity $F_{n+1} - \varphi F_n = \psi^n$ relating the
Fibonacci convergents to the geometric decay of the conjugate, derive from it the
**Fibonacci linear forms** $F_n\varphi - F_{n+1} = -\psi^n$ that drive a
Diophantine irrationality engine to prove $\varphi$ irrational, and deduce as a
corollary that $\varphi$ is **not a Liouville number**. All results have been
formally verified. We close by stating three conjectural generalizations to the
metallic ratios $\alpha_m = (m + \sqrt{m^2+4})/2$ and to the Legendre converse
characterizing best approximations as continued-fraction convergents.

## 1. Introduction

### 1.1 The approximation hierarchy

Diophantine approximation studies how closely irrational numbers can be
approximated by rationals, measured against the size of the denominator. The
foundational result is **Dirichlet's approximation theorem**: for every
irrational $\alpha \in \mathbb{R}$ there exist infinitely many fractions $p/q$
(in lowest terms, $q \geq 1$) with

$$\left|\alpha - \frac{p}{q}\right| < \frac{1}{q^2}.$$

Hurwitz (1891) sharpened the universal constant: there are infinitely many $p/q$
with $|\alpha - p/q| < 1/(\sqrt5\, q^2)$, and $\sqrt5$ is optimal in the sense
that for any $c > \sqrt5$ there exist irrationals (namely $\varphi$ and its
$\mathrm{GL}_2(\mathbb{Z})$-equivalents) admitting only finitely many $p/q$ with
$|\alpha - p/q| < 1/(c\,q^2)$.

A real number $\alpha$ is **badly approximable** if there is a constant $c > 0$
with $|\alpha - p/q| \geq c/q^2$ for all rationals $p/q$. Equivalently (by the
theory of continued fractions) the partial quotients of $\alpha$ are bounded. The
golden ratio, whose continued fraction is $[1;1,1,1,\ldots]$, has the smallest
possible partial quotients and is therefore the extremal badly approximable
number: it realizes the Hurwitz wall.

At the opposite end of the spectrum sit the **Liouville numbers**: irrationals
$\alpha$ such that for every $n$ there exist infinitely many $p/q$ with
$|\alpha - p/q| < 1/q^n$. Liouville (1844) proved that algebraic numbers cannot
be Liouville, thereby exhibiting the first explicit transcendental numbers. Badly
approximable numbers are maximally far from Liouville.

### 1.2 Contribution

This paper isolates the quantitative core of the above hierarchy for $\varphi$
through a purely algebraic argument built on the integer norm form. We prove,
with full formal rigor and no appeal to the general theory of continued
fractions:

1. **Norm-form factorization** (Theorem 3.1): $(p - q\varphi)(p - q\psi) = p^2 -
   pq - q^2$ over $\mathbb{R}$.
2. **Integrality of the norm** (Theorem 3.2): for integers with $q \geq 1$,
   $p^2 - pq - q^2 \neq 0$, hence $|p^2 - pq - q^2| \geq 1$.
3. **Binet-type identity** (Theorem 4.1): $F_{n+1} - \varphi F_n = \psi^n$.
4. **Fibonacci linear forms** (Theorem 4.2): for every $\varepsilon > 0$ there
   exist $q \geq 1$, $p \in \mathbb{Z}$ with $0 < |q\varphi - p| < \varepsilon$.
5. **Irrationality** (Theorem 4.3): $\varphi$ is irrational.
6. **Badly approximable** (Theorem 5.1): $|\varphi - p/q| \geq (1/3)/q^2$ for all
   integers $p$ and $q \geq 1$.
7. **Not Liouville** (Corollary 5.2): $\varphi$ is not a Liouville number.

The strategy is deliberately elementary, replacing the convergent calculus with
the single observation that a nonzero integer has absolute value at least one.

## 2. Definitions and basic identities

### 2.1 The golden ratio and its conjugate

**Definition 2.1.** The *golden ratio* and its *conjugate* are
$$\varphi = \frac{1+\sqrt5}{2}, \qquad \psi = \frac{1-\sqrt5}{2}.$$

**Lemma 2.2 (algebraic relations).** The following hold:
$$\varphi + \psi = 1, \qquad \varphi\,\psi = -1, \qquad \varphi - \psi = \sqrt5.$$

*Proof.* Direct computation from $(\sqrt5)^2 = 5$. The sum and difference are
immediate; for the product, $\varphi\psi = \tfrac14(1+\sqrt5)(1-\sqrt5) =
\tfrac14(1 - 5) = -1$. $\square$

**Lemma 2.3 (quadratic equations).** Both $\varphi$ and $\psi$ satisfy
$x^2 = x + 1$; equivalently $\varphi^2 = \varphi + 1$ and $\psi^2 = \psi + 1$.

*Proof.* $x^2 - x - 1 = (x - \varphi)(x - \psi)$ by Lemma 2.2, since the sum of
roots is $1$ and the product is $-1$. $\square$

**Lemma 2.4 (size of the conjugate).** $|\psi| < 1$. Explicitly $-1 < \psi < 0$,
since $\psi = (1 - \sqrt5)/2$ and $2 < \sqrt5 < 3$.

**Lemma 2.5 (numerical bound).** $\sqrt5 < 8/3$. *Proof.* $(8/3)^2 = 64/9 > 5$.
$\square$

## 3. The norm form and the integrality lower bound

The engine of the entire analysis is the quadratic form $N(p,q) = p^2 - pq -
q^2$, the *norm* of $p - q\varphi$ in the ring $\mathbb{Z}[\varphi]$.

**Theorem 3.1 (norm-form factorization).** For all real $p, q$,
$$(p - q\varphi)(p - q\psi) = p^2 - pq - q^2.$$

*Proof.* Expand the left side:
$$(p - q\varphi)(p - q\psi) = p^2 - pq(\varphi + \psi) + q^2\,\varphi\psi
= p^2 - pq\cdot 1 + q^2\cdot(-1) = p^2 - pq - q^2,$$
using Lemma 2.2. $\square$

**Theorem 3.2 (nonvanishing of the norm).** For integers $p, q$ with $q \geq 1$,
$$p^2 - pq - q^2 \neq 0.$$

*Proof.* Suppose $p^2 - pq - q^2 = 0$. Multiplying by $4$ and completing the
square gives $(2p - q)^2 = 5q^2$. Hence $5 = \big((2p-q)/q\big)^2$ exhibits $5$
as the square of a rational, so $5$ would be a perfect square in $\mathbb{Z}$.
But $2^2 = 4 < 5 < 9 = 3^2$, a contradiction. $\square$

**Corollary 3.3 (integrality lower bound).** For integers $p, q$ with $q \geq 1$,
$$\big|\,p^2 - pq - q^2\,\big| \geq 1.$$

*Proof.* $p^2 - pq - q^2$ is a nonzero integer (Theorem 3.2), and every nonzero
integer has absolute value at least $1$. $\square$

This single inequality — that a nonzero integer cannot be smaller than $1$ — is
the entire arithmetic content of badly approximability. Everything else is the
analytic packaging of Corollary 3.3 through the factorization of Theorem 3.1.

## 4. Fibonacci convergents and irrationality

### 4.1 The Binet identity

The convergents of $\varphi = [1;1,1,\ldots]$ are the ratios $F_{n+1}/F_n$ of
consecutive Fibonacci numbers, where $F_0 = 0,\, F_1 = 1,\, F_{n+2} = F_{n+1} +
F_n$. The error of these convergents is controlled exactly.

**Theorem 4.1 (Binet-type identity).** For all $n \geq 0$,
$$F_{n+1} - \varphi\,F_n = \psi^{\,n}.$$

*Proof.* By strong induction on $n$. The base cases $n = 0$ ($F_1 - \varphi F_0 =
1 = \psi^0$) and $n = 1$ ($F_2 - \varphi F_1 = 1 - \varphi = \psi$, by Lemma 2.2)
hold directly. For $n \geq 2$, write $n = k+2$ and use the Fibonacci recurrence
$F_{n+1} = F_n + F_{n-1}$, $F_n = F_{n-1} + F_{n-2}$:
$$F_{n+1} - \varphi F_n = (F_n - \varphi F_{n-1}) + (F_{n-1} - \varphi F_{n-2})
= \psi^{n-1} + \psi^{n-2} = \psi^{n-2}(\psi + 1) = \psi^{n-2}\,\psi^2 = \psi^n,$$
using the inductive hypothesis at $n-1$ and $n-2$ and the identity $\psi^2 =
\psi + 1$ (Lemma 2.3). $\square$

Equivalently, the *Fibonacci linear forms* are
$$F_n\,\varphi - F_{n+1} = -\psi^{\,n}.$$
Since $|\psi| < 1$, these are nonzero numbers tending geometrically to $0$.

### 4.2 Small linear forms and irrationality

**Theorem 4.2 (small linear forms).** For every $\varepsilon > 0$ there exist a
natural number $q \geq 1$ and an integer $p$ with
$$0 < |q\,\varphi - p| < \varepsilon.$$

*Proof.* Choose $N$ with $|\psi|^{N+1} < \varepsilon$ (possible since $|\psi| <
1$). Set $q = F_{N+1}$ and $p = F_{N+2}$. Then $q \geq 1$, and by Theorem 4.1,
$q\varphi - p = F_{N+1}\varphi - F_{N+2} = -\psi^{N+1}$. Hence $|q\varphi - p| =
|\psi|^{N+1} < \varepsilon$, and it is nonzero because $\psi \neq 0$. $\square$

**Theorem 4.3 (irrationality).** $\varphi$ is irrational.

*Proof.* We invoke the Diophantine irrationality criterion: *if for every
$\varepsilon > 0$ there exist $q \geq 1$ and $p \in \mathbb{Z}$ with $0 <
|q\,\alpha - p| < \varepsilon$, then $\alpha$ is irrational.* Indeed, if $\alpha =
a/b$ with $b \geq 1$, then for any integers $q \geq 1$, $p$ the quantity
$q\alpha - p = (qa - pb)/b$ is a rational with denominator $b$; if nonzero it has
absolute value $\geq 1/b$. Taking $\varepsilon = 1/b$ contradicts the existence
of arbitrarily small nonzero forms. By Theorem 4.2 the hypothesis holds for
$\varphi$, so $\varphi$ is irrational. $\square$

This is precisely the continued-fraction route to irrationality, recast as a
quantitative statement about the decay of the convergent errors $\psi^n$.

## 5. The badly-approximable bound and its consequences

**Theorem 5.1 (badly approximable).** For all integers $p$ and all integers
$q \geq 1$,
$$\left|\varphi - \frac{p}{q}\right| \geq \frac{1/3}{q^2}.$$

*Proof.* Set $t = |p - q\varphi| \geq 0$. By Theorem 3.1 and Corollary 3.3,
$$1 \leq |p^2 - pq - q^2| = |p - q\varphi|\cdot|p - q\psi| = t\cdot|p - q\psi|.$$
Now $p - q\psi = (p - q\varphi) + q(\varphi - \psi) = (p - q\varphi) + q\sqrt5$
by Lemma 2.2, so by the triangle inequality and $q \geq 1 > 0$,
$$|p - q\psi| \leq |p - q\varphi| + q\sqrt5 = t + q\sqrt5.$$
Combining,
$$1 \leq t\,(t + q\sqrt5) = t^2 + \sqrt5\,(q\,t). \tag{$\ast$}$$
We claim $q\,t \geq 1/3$. Suppose not, so $q\,t < 1/3$. Since $q \geq 1$ we also
have $t \leq q\,t < 1/3$, hence $t^2 < 1/9$. Using $\sqrt5 < 8/3$ (Lemma 2.5),
$$t^2 + \sqrt5\,(q\,t) < \frac19 + \frac83\cdot\frac13 = \frac19 + \frac89 = 1,$$
contradicting $(\ast)$. Therefore $q\,t \geq 1/3$. Finally, since $t = |p -
q\varphi| = q\,|\varphi - p/q|$,
$$q^2\left|\varphi - \frac{p}{q}\right| = q\,t \geq \frac13,
\qquad\text{i.e.}\qquad
\left|\varphi - \frac{p}{q}\right| \geq \frac{1/3}{q^2}. \square$$

**Remark 5.1.1 (the constant).** The constant $1/3$ is not optimal: Hurwitz's
theorem implies the sharp constant for $\varphi$ is $1/\sqrt5 \approx 0.447$,
attained in the limit along the Fibonacci convergents. The elementary argument
above captures the correct *order* $1/q^2$ and a genuine positive constant; the
sharp value $\sqrt5$ requires the matching threshold analysis (companion result),
which shows that for any $c > \sqrt5$ only finitely many $p/q$ satisfy
$|\varphi - p/q| < 1/(c\,q^2)$.

**Corollary 5.2 (not a Liouville number).** $\varphi$ is not a Liouville number.

*Proof.* A Liouville number $\alpha$ admits, for every $n$, infinitely many $p/q$
($q \geq 2$) with $|\alpha - p/q| < 1/q^n$. Taking $n = 3$ would give infinitely
many $p/q$ with $|\varphi - p/q| < 1/q^3$. But Theorem 5.1 forces $|\varphi -
p/q| \geq (1/3)/q^2 = q/(3q^3) \geq 1/(3q^3) \cdot q$; concretely, for $q \geq 1$
we have $(1/3)/q^2 \leq |\varphi - p/q| < 1/q^3$ would require $q/3 < 1$, i.e.
$q \leq 2$, leaving only finitely many denominators. Hence the Liouville
condition fails at $n = 3$ and $\varphi$ is not Liouville. (More directly,
$\varphi$ is algebraic of degree $2$, and Liouville's theorem forbids algebraic
numbers from being Liouville.) $\square$

## 6. Algorithms

The proofs are constructive and translate directly into computation.

### 6.1 Fibonacci convergents

The best rational approximations to $\varphi$ are the convergents $F_{n+1}/F_n$.
Generating them is linear in $n$:

```
Algorithm CONVERGENTS(n):
  a, b <- 0, 1            # F_0, F_1
  convergents <- []
  for i in 1..n:
    a, b <- b, a + b      # advance Fibonacci pair
    append (b, a) to convergents   # numerator F_{i+1}, denominator F_i
  return convergents
```

The error of the $n$-th convergent is exactly $|\varphi - F_{n+1}/F_n| =
|\psi|^n / F_n$, by Theorem 4.1 divided by $F_n$.

### 6.2 Verifying the badly-approximable bound

Given a denominator $q$, the closest fraction to $\varphi$ has numerator
$p = \mathrm{round}(q\varphi)$; checking the bound amounts to confirming
$q^2|\varphi - p/q| \geq 1/3$:

```
Algorithm CHECK_BADLY_APPROXIMABLE(Q):
  for q in 1..Q:
    p <- round(q * phi)
    score <- q^2 * |phi - p/q|
    assert score >= 1/3
  return min score over all q
```

The minimum score across all $q$ converges downward to $1/\sqrt5 \approx 0.447$,
realized along Fibonacci denominators, confirming both the $1/3$ floor and its
non-optimality.

## 7. Applications and connections

- **Number theory.** The norm form $N(p,q) = p^2 - pq - q^2$ is the field norm of
  $\mathbb{Z}[\varphi]$, the ring of integers of $\mathbb{Q}(\sqrt5)$. The
  badly-approximable bound is a Diophantine shadow of the fact that this norm is
  integer-valued and nonzero on nonzero lattice points.
- **Continued fractions and the Lagrange spectrum.** $\varphi$ is the smallest
  point of the Lagrange spectrum, the set of optimal approximation constants. Our
  bound is the elementary half of locating it.
- **Dynamical systems.** Badly approximable numbers correspond to bounded
  trajectories of the Gauss map and are exactly the rotation numbers that are
  KAM-stable; $\varphi$ is the "most stable" rotation number, which is why it
  appears in models of quasiperiodicity and in the spacing of phyllotactic
  spirals.
- **Computer science.** Fibonacci ratios give the optimal probe sequence in
  Fibonacci search and underlie Zeckendorf representations.

## 8. Discussion and future work

The norm-form method is robust: it depends only on (i) a real quadratic
factorization of an integer form and (ii) the discriminant not being a perfect
square. This suggests immediate generalizations.

**Conjecture 1 (metallic ratios are badly approximable).** For each integer
$m \geq 1$, the metallic ratio $\alpha_m = (m + \sqrt{m^2+4})/2$ (root of $x^2 =
mx + 1$, with $\alpha_1 = \varphi$) satisfies $|\alpha_m - p/q| \geq c_m/q^2$ for
all $q \geq 1$, with explicit $c_m = 1/(2\sqrt{m^2+4})$, and $\alpha_m$ is not
Liouville. The norm form $p^2 - mpq - q^2$ factors as $(p - q\alpha_m)(p -
q\beta_m)$ with $\alpha_m - \beta_m = \sqrt{m^2+4}$, and $m^2+4$ is never a
perfect square (since $m^2 < m^2+4 < (m+1)^2$ for $m \geq 2$, and $5$ for
$m = 1$), so $|N| \geq 1$ exactly as for $\varphi$.

**Conjecture 2 (sharp Hurwitz constant per metallic ratio).** For $\alpha_m$, the
optimal Hurwitz constant is exactly $\sqrt{m^2+4}$: for any $c > \sqrt{m^2+4}$
only finitely many $p/q$ satisfy $|\alpha_m - p/q| < 1/(c\,q^2)$, while infinitely
many beat every $c < \sqrt{m^2+4}$. The threshold argument $1 \leq t(t +
q\sqrt{m^2+4}) \Rightarrow \sqrt{m^2+4}/c < 1$ controls finiteness, mirroring the
$\sqrt5$ case, with the boundary rate realized by the $\alpha_m$-convergents.

**Conjecture 3 (Legendre converse).** If $|\alpha - p/q| < 1/(2q^2)$ with
$\gcd(p,q) = 1$, then $p/q$ is a convergent of the continued fraction of
$\alpha$; consequently the badly-approximable lower bounds of Conjectures 1–2 are
attained *only* along the convergents. Combined with the norm-form lower bound,
the set of record approximations to a quadratic irrational is exactly its
convergent sequence, giving a clean Lagrange-spectrum description.

## 9. Conclusion

By distilling the Diophantine behavior of the golden ratio to a single integer
norm form and the elementary fact that nonzero integers are bounded below by $1$,
we obtain a fully self-contained proof that $\varphi$ is badly approximable, is
irrational, and is not Liouville — recovering the quantitative essence of
Hurwitz's and Liouville's theorems for the most irrational number, without
invoking the general theory of continued fractions. The method is parametric in
the discriminant and points toward a uniform treatment of all real quadratic
irrationals.

## References

The results here are elementary and self-contained; the classical background may
be found in standard texts on Diophantine approximation (Dirichlet's theorem,
Hurwitz's theorem, Liouville's theorem, and the theory of continued fractions and
the Lagrange spectrum).
