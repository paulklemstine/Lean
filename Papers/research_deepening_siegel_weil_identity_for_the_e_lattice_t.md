# A Universal Hecke Convolution Law for Divisor-Power Sums, with Application to the $E_8$ Theta Series

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The Siegel–Weil identity in rank $8$ asserts that the theta series of the even
unimodular lattice $E_8$ equals the weight-$4$ Eisenstein series $E_4$. At the
level of Fourier coefficients this is the classical formula
$r(n) = 240\,\sigma_3(n)$, where $r(n)$ counts the lattice vectors of squared
length $2n$ and $\sigma_3(n) = \sum_{d\mid n} d^3$. The arithmetic content of
this identity — that $240\,\sigma_3$ inherits the full Hecke-eigenform structure
of $E_4$ — is encapsulated in the global convolution law
$$
\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\tfrac{mn}{d^2}\right).
$$
We prove that this law is not special to weight $4$: for **every** exponent $s$
the divisor-power sum $\sigma_s$ satisfies the identical convolution identity.
We give a complete, elementary derivation resting on a single geometric
double-sum identity, and we extract two families of consequences: (i) the Hecke
operator eigenvalue relation
$\sigma_s(p)\sigma_s(n) = \sigma_s(pn) + [p\mid n]\,p^s\,\sigma_s(n/p)$, valid
for *all* $n$; and (ii) the growth bound $n^s \le \sigma_s(n)$. Both are
transported back to the $E_8$ representation numbers, yielding
$r(p)r(n) = 240\bigl(r(pn) + [p\mid n]\,p^3\,r(n/p)\bigr)$ and
$240\,n^3 \le r(n)$. Every result is stated for general $s$; the classical
$E_8$ statement is recovered verbatim as the case $s = 3$.

**Keywords:** $E_8$ lattice, theta series, Siegel–Weil identity, Eisenstein
series, divisor-power sum, Hecke eigenform, multiplicative arithmetic function,
Hecke operator.

---

## 1. Introduction

Among all lattices in Euclidean space, the even unimodular lattice $E_8 \subset
\mathbb{R}^8$ is exceptional. It is the unique even unimodular lattice in its
dimension, it realizes the densest lattice sphere packing in $\mathbb{R}^8$, and
its automorphism group is the Weyl group of the exceptional root system $E_8$.
A fundamental invariant of a lattice $\Lambda$ is its **theta series**
$$
\theta_\Lambda(\tau) = \sum_{x \in \Lambda} q^{\langle x, x\rangle / 2},
\qquad q = e^{2\pi i \tau},\ \operatorname{Im}\tau > 0,
$$
whose coefficients record how many lattice vectors have each given squared
length. For an even unimodular lattice of rank $8$, $\theta_\Lambda$ is a
modular form of weight $4$ for the full modular group $\mathrm{SL}_2(\mathbb Z)$.
Because the space of such forms is one-dimensional and spanned by the Eisenstein
series $E_4$, and because both $\theta_\Lambda$ and $E_4$ have constant term
$1$, they must coincide:
$$
\theta_{E_8} = E_4 = 1 + 240 \sum_{n\ge 1} \sigma_3(n)\,q^n.
$$
This is the rank-$8$ case of the **Siegel–Weil identity**, which in general
equates a weighted average of theta series over a genus of quadratic forms with
an Eisenstein series. In rank $8$ the relevant genus has a single class, so the
average degenerates to the single lattice $E_8$, and the identity becomes the
sharp coefficient formula
$$
\boxed{\,r(n) = 240\,\sigma_3(n)\,}
$$
where $r(n) = \#\{x \in E_8 : \langle x,x\rangle = 2n\}$ and
$\sigma_3(n) = \sum_{d\mid n} d^3$.

The purpose of this paper is to isolate the *arithmetic backbone* of this
identity and to generalize it. The statement $\theta_{E_8} = E_4$ is equivalent
(via the Hecke theory of modular forms) to $240\,\sigma_3$ being a Hecke
eigenform, and this eigenform property is captured, purely arithmetically, by
the convolution law
$$
\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\tfrac{mn}{d^2}\right).
\tag{$\ast$}
$$
Our main results are:

1. **Universality (Theorem 5.1).** The convolution law $(\ast)$ holds with
   $3$ replaced by *any* exponent $s \in \mathbb{N}$. Thus each divisor-power
   sum $\sigma_s$ — the coefficient system of the weight-$(s+1)$ Eisenstein
   series — is a Hecke eigenform, and the $E_8$ statement is exactly $s = 3$.

2. **Global Hecke relation (Theorem 6.1).** For every prime $p$ and *every*
   integer $n$,
   $$
   \sigma_s(p)\,\sigma_s(n) = \sigma_s(pn) + [p\mid n]\,p^s\,\sigma_s(n/p),
   $$
   the concrete form of "$\sigma_s$ is a $T_p$-eigenfunction with eigenvalue
   $\sigma_s(p) = 1 + p^s$."

3. **Consequences for $E_8$ (Section 7).** The growth bound $n^s\le\sigma_s(n)$
   and the two results above transport to the representation numbers $r(n)$,
   giving $240\,n^3 \le r(n)$ and the recurrence
   $r(p)r(n) = 240\bigl(r(pn) + [p\mid n]\,p^3\,r(n/p)\bigr)$.

The entire development is elementary and self-contained: no modular-forms
machinery is used in the proofs. The single nontrivial ingredient is a
combinatorial identity for products of finite geometric progressions
(Section 3), from which the prime-power case follows immediately; global
multiplicativity then propagates the identity to all integers.

---

## 2. Definitions and notation

Throughout, $s, m, n, p, r, a, b$ denote nonnegative integers, and $p$ denotes
a prime where stated. We write $[\,P\,]$ for the Iverson bracket, equal to $1$
if the proposition $P$ holds and $0$ otherwise, and $v_p(n)$ for the $p$-adic
valuation of $n$.

**Definition 2.1 (Divisor-power sum).** For $s \ge 0$ and $n \ge 1$,
$$
\sigma_s(n) = \sum_{d \mid n} d^s,
$$
the sum ranging over the positive divisors of $n$. By convention
$\sigma_s(0) = 0$. Note $\sigma_0(n)$ is the number of divisors of $n$ and
$\sigma_1(n)$ their sum.

**Definition 2.2 ($E_8$ representation numbers).** With $E_8$ the even
unimodular rank-$8$ lattice, $r(n) = \#\{x \in E_8 : \langle x, x\rangle = 2n\}$.
Motivated by the Siegel–Weil identity we set
$$
r_{E_8}(n) = 240\,\sigma_3(n),
$$
the $E_4$/Siegel–Weil prediction for $r(n)$; the classical theorem is
$r(n) = r_{E_8}(n)$.

**Definition 2.3 (Hecke convolution).** For $s, m, n \ge 0$,
$$
H_s(m,n) = \sum_{d \mid \gcd(m,n)} d^s\,\sigma_s\!\left(\frac{mn}{d^2}\right).
$$
The identity $(\ast)$ and its generalization assert $\sigma_s(m)\sigma_s(n) =
H_s(m,n)$. Immediately from the definition, $H_s(0,n) = H_s(m,0) = 0$, since
$\gcd$ with $0$ makes the argument vanish under our conventions.

We freely use the fact that $\sigma_s$ is **multiplicative**: if
$\gcd(m,n) = 1$ then $\sigma_s(mn) = \sigma_s(m)\,\sigma_s(n)$. This is standard
and follows from the bijection between divisors of $mn$ and pairs of divisors of
$m$ and $n$ when $m,n$ are coprime.

---

## 3. The geometric double-sum identity

The combinatorial core of the whole theory is the following regrouping of the
product of two finite geometric progressions.

**Lemma 3.1 (Geometric double sum).** For all $q, a, b \ge 0$,
$$
\Bigl(\sum_{i=0}^{a} q^{\,i}\Bigr)\Bigl(\sum_{j=0}^{b} q^{\,j}\Bigr)
   = \sum_{i=0}^{\min(a,b)} q^{\,i}\,\Bigl(\sum_{\ell=0}^{a+b-2i} q^{\,\ell}\Bigr).
$$

*Proof sketch.* By symmetry assume $a \le b$, so $\min(a,b) = a$. The left side
is $\sum_{i=0}^{a}\sum_{j=0}^{b} q^{i+j}$, the sum of $q^{k}$ over the lattice
rectangle $\{(i,j): 0\le i\le a,\ 0\le j\le b\}$, with $k = i+j$. Group the
rectangle by the "antidiagonal shift" $i$ after folding: for each $i$ with
$0 \le i \le a$, the terms with the smaller coordinate equal to $i$ trace out a
one-dimensional strip whose exponents $i + \ell$ range over
$\ell = 0, \dots, a + b - 2i$; summing $q^{i}\sum_{\ell} q^{\ell}$ over these
strips recovers every cell of the rectangle exactly once. Formally the identity
is proved by induction on $a$: the base case $a = 0$ is immediate, and the
inductive step peels off the strip $i = a$ (contributing
$q^{a}\sum_{\ell=0}^{b-a} q^{\ell}$) and rewrites the remainder using the
inductive hypothesis with $a-1$ and $b-1$, after which the telescoping of
partial geometric sums closes the computation. $\qquad\blacksquare$

Setting $q = p^s$ converts Lemma 3.1 into an identity among $\sigma_s$-values at
prime powers, which is the subject of the next section.

---

## 4. Prime-power structure

**Lemma 4.1 (Geometric form at prime powers).** For a prime $p$ and $r \ge 0$,
$$
\sigma_s(p^r) = \sum_{i=0}^{r} p^{\,s i} = 1 + p^s + p^{2s} + \cdots + p^{rs}.
$$

*Proof.* The divisors of $p^r$ are exactly $p^0, p^1, \dots, p^r$; raising each
to the $s$-th power and summing gives $\sum_{i=0}^{r} p^{si}$. $\qquad\blacksquare$

**Corollary 4.2.** $\sigma_s(p) = 1 + p^s$ for every prime $p$.

**Lemma 4.3 (Three-term Hecke recurrence at a prime power).** For a prime $p$
and $r \ge 0$,
$$
\sigma_s(p^{r+2}) + p^s\,\sigma_s(p^r) = \sigma_s(p)\,\sigma_s(p^{r+1}).
$$

*Proof.* Substitute the geometric form of Lemma 4.1 and $\sigma_s(p) = 1 + p^s$.
The right side is
$(1 + p^s)\sum_{i=0}^{r+1} p^{si} = \sum_{i=0}^{r+1}p^{si} +
\sum_{i=0}^{r+1}p^{s(i+1)} = \sum_{i=0}^{r+1}p^{si} + \sum_{i=1}^{r+2}p^{si}$.
The left side is $\sum_{i=0}^{r+2}p^{si} + p^s\sum_{i=0}^{r}p^{si} =
\sum_{i=0}^{r+2}p^{si} + \sum_{i=1}^{r+1}p^{si}$. Both equal
$1 + 2\sum_{i=1}^{r+1}p^{si} + p^{s(r+2)}$, so they agree. $\qquad\blacksquare$

Lemma 4.3 is precisely the statement that the weight-$(s+1)$ Eisenstein series
is a $T_p$-eigenform with eigenvalue $\sigma_s(p)$; we recover a global version
in Section 6.

**Lemma 4.4 (Hecke convolution at prime powers).** For a prime $p$ and
$a, b \ge 0$,
$$
H_s(p^a, p^b) = \sigma_s(p^a)\,\sigma_s(p^b).
$$

*Proof.* Since $p$ is prime, $\gcd(p^a,p^b) = p^{\min(a,b)}$, and its divisors
are $p^0, \dots, p^{\min(a,b)}$. Writing $d = p^i$ we have $d^s = p^{si}$ and
$p^a p^b / d^2 = p^{a+b-2i}$, so
$$
H_s(p^a,p^b) = \sum_{i=0}^{\min(a,b)} p^{si}\,\sigma_s(p^{a+b-2i})
   = \sum_{i=0}^{\min(a,b)} p^{si} \sum_{\ell=0}^{a+b-2i} p^{s\ell},
$$
using Lemma 4.1. By Lemma 3.1 with $q = p^s$, this equals
$\bigl(\sum_{i=0}^a p^{si}\bigr)\bigl(\sum_{j=0}^b p^{sj}\bigr) =
\sigma_s(p^a)\sigma_s(p^b)$. $\qquad\blacksquare$

---

## 5. The universal Hecke convolution identity

We now bootstrap the prime-power identity to all integers via multiplicativity.
Two multiplicativity statements are needed: for $\sigma_s$ (standard) and for
the convolution $H_s$.

**Lemma 5.1 (Multiplicativity of $H_s$).** Suppose $m,m',n,n'$ satisfy the
pairwise coprimality conditions $\gcd(m,m')=\gcd(n,n')=\gcd(m,n')=\gcd(m',n)=1$.
Then
$$
H_s(m\,m',\ n\,n') = H_s(m,n)\,H_s(m',n').
$$

*Proof sketch.* Under the coprimality hypotheses,
$\gcd(mm', nn') = \gcd(m,n)\,\gcd(m',n')$ with the two factors coprime, so every
divisor $d \mid \gcd(mm',nn')$ factors uniquely as $d = xy$ with
$x \mid \gcd(m,n)$ and $y \mid \gcd(m',n')$. The map $(x,y)\mapsto xy$ is a
bijection from the product of divisor sets. Substituting and using
$mm'nn'/(xy)^2 = (mn/x^2)(m'n'/y^2)$ together with the multiplicativity of
$\sigma_s$ across the coprime factors $mn/x^2$ and $m'n'/y^2$ splits the sum as a
product, giving $H_s(m,n)H_s(m',n')$. $\qquad\blacksquare$

**Corollary 5.2 (Coprime collapse).** If $\gcd(m,n) = 1$, then
$H_s(m,n) = \sigma_s(m)\,\sigma_s(n)$.

*Proof.* The only divisor of $\gcd(m,n) = 1$ is $d = 1$, so
$H_s(m,n) = \sigma_s(mn) = \sigma_s(m)\sigma_s(n)$ by multiplicativity.
$\qquad\blacksquare$

**Theorem 5.3 (Universal Hecke convolution identity).** For every exponent
$s \ge 0$ and all $m, n \ge 0$,
$$
\sigma_s(m)\,\sigma_s(n) = \sum_{d \mid \gcd(m,n)} d^s\,\sigma_s\!\left(\frac{mn}{d^2}\right)
\;=\; H_s(m,n).
$$

*Proof.* The case $m = 0$ or $n = 0$ is immediate from the conventions
($\sigma_s(0) = 0 = H_s(0,n)$). For positive $m,n$ we argue by strong induction
on $m$, proving $H_s(m,n) = \sigma_s(m)\sigma_s(n)$ for all $n$. If
$\gcd(m,n) = 1$, apply Corollary 5.2. Otherwise pick a prime $p$ dividing both
$m$ and $n$, and factor out the $p$-parts: write $m = p^a m'$ and $n = p^b n'$
with $a = v_p(m) \ge 1$, $b = v_p(n) \ge 1$, and $p \nmid m'$, $p \nmid n'$.
Then $m' < m$, and the four coprimality conditions of Lemma 5.1 hold for the
pairs $(p^a, m')$ and $(p^b, n')$ (each prime power is coprime to the
prime-to-$p$ parts). Lemma 5.1 gives
$$
H_s(m,n) = H_s(p^a, p^b)\,H_s(m',n').
$$
By Lemma 4.4, $H_s(p^a,p^b) = \sigma_s(p^a)\sigma_s(p^b)$, and by the induction
hypothesis (since $m' < m$), $H_s(m',n') = \sigma_s(m')\sigma_s(n')$. Multiplying
and regrouping with the multiplicativity of $\sigma_s$ (the pairs $p^a,m'$ and
$p^b,n'$ are coprime) yields
$$
H_s(m,n) = \sigma_s(p^a m')\,\sigma_s(p^b n') = \sigma_s(m)\,\sigma_s(n),
$$
completing the induction. $\qquad\blacksquare$

**Corollary 5.4 (The $E_8$ / weight-$4$ identity).** Taking $s = 3$,
$$
\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right),
$$
which is the arithmetic backbone of $\theta_{E_8} = E_4$, i.e. of
$r(n) = 240\,\sigma_3(n)$.

---

## 6. The global Hecke operator relation

Theorem 5.3 at the special case $m = p$ yields a relation valid for *all* $n$,
not merely prime powers.

**Theorem 6.1 (Hecke $T_p$ eigenvalue relation).** For every prime $p$, every
exponent $s$, and every $n \ge 0$,
$$
\sigma_s(p)\,\sigma_s(n) = \sigma_s(pn) + [\,p \mid n\,]\cdot p^s\,\sigma_s(n/p).
$$

*Proof.* Apply Theorem 5.3 with $m = p$: the sum runs over
$d \mid \gcd(p, n)$. If $p \nmid n$ then $\gcd(p,n) = 1$ and the sum has the
single term $d = 1$, giving $\sigma_s(p)\sigma_s(n) = \sigma_s(pn)$, which
matches the claim since the bracket vanishes. If $p \mid n$ then
$\gcd(p,n) = p$ and the divisors are $1$ and $p$. The term $d = 1$ contributes
$\sigma_s(pn)$; the term $d = p$ contributes $p^s\,\sigma_s(pn/p^2) =
p^s\,\sigma_s(n/p)$. Summing gives the stated relation. $\qquad\blacksquare$

Equivalently, $\sigma_s$ is a simultaneous eigenfunction of every classical
Hecke operator $T_p$ with eigenvalue $\sigma_s(p) = 1 + p^s$; Theorem 6.1 is the
familiar identity
$T_p\,\sigma_s = \sigma_s(p)\,\sigma_s$
written out on coefficients.

**Proposition 6.2 (Growth bound).** For $n \ge 1$, $\ n^s \le \sigma_s(n)$.

*Proof.* Among the divisors of $n$ is $n$ itself, contributing the single term
$n^s$ to the nonnegative sum $\sigma_s(n) = \sum_{d\mid n} d^s$. $\qquad\blacksquare$

---

## 7. Consequences for the $E_8$ representation numbers

We now transport the general-weight results back to $s = 3$ and the
Siegel–Weil prediction $r_{E_8}(n) = 240\,\sigma_3(n)$.

**Theorem 7.1 (Cubic lower bound).** For $n \ge 1$,
$$
240\,n^3 \le r_{E_8}(n).
$$

*Proof.* Multiply the bound $n^3 \le \sigma_3(n)$ of Proposition 6.2 (case
$s = 3$) by $240$. $\qquad\blacksquare$

**Theorem 7.2 (Hecke recurrence for representation numbers).** For every prime
$p$ and every $n \ge 0$,
$$
r_{E_8}(p)\,r_{E_8}(n) = 240\,\Bigl(r_{E_8}(pn) + [\,p\mid n\,]\,p^3\,r_{E_8}(n/p)\Bigr).
$$

*Proof.* By definition $r_{E_8}(k) = 240\,\sigma_3(k)$. The left side is
$240^2\,\sigma_3(p)\sigma_3(n)$. By Theorem 6.1 (with $s = 3$),
$\sigma_3(p)\sigma_3(n) = \sigma_3(pn) + [p\mid n]\,p^3\,\sigma_3(n/p)$.
Multiplying by $240^2$ and factoring one $240$ out of the parenthesis yields the
claim. $\qquad\blacksquare$

Since $r(n) = r_{E_8}(n)$ by the Siegel–Weil identity, Theorems 7.1 and 7.2 are
statements about the true geometric point-counts of $E_8$: the lattice is at
least cubically crowded, and its counting function satisfies a prime-indexed
recurrence.

---

## 8. Algorithms

The results above are effective. We record the two computational primitives.

**Algorithm A (Divisor-power sum).** Given $s$ and $n \ge 1$, compute
$\sigma_s(n)$ by enumerating divisors up to $\sqrt{n}$ in pairs. Complexity
$O(\sqrt n)$ integer operations (before big-integer cost of the powers).

**Algorithm B (Hecke convolution check).** Given $s, m, n$, compute
$H_s(m,n) = \sum_{d\mid\gcd(m,n)} d^s \sigma_s(mn/d^2)$ by enumerating the
divisors of $\gcd(m,n)$; each term calls Algorithm A. This verifies Theorem 5.3
numerically and, restricted to $m = p$, Theorem 6.1.

A direct enumeration of $E_8$ lattice vectors of squared length $2n$ (over the
"all-integer / all-half-integer with even sum" coordinate model) confirms
$r(n) = 240\,\sigma_3(n)$ for small $n$; this provides an independent check that
the arithmetic prediction matches the geometry.

---

## 9. Discussion and applications

The convolution law $\sigma_s(m)\sigma_s(n) = \sum_{d\mid\gcd(m,n)} d^s
\sigma_s(mn/d^2)$ is the coefficient-level shadow of the Hecke-eigenform
property of Eisenstein series. Isolating it as a purely arithmetic statement has
three benefits. First, it makes the $E_8 = E_4$ identity's *arithmetic* content
independent of modular-forms machinery: the fact that the $E_8$ counting numbers
satisfy a clean multiplicative recurrence is elementary. Second, it exposes the
identity as one rung of an infinite ladder indexed by $s$; the geometry of
$E_8$ merely selects $s = 3$. Third, the explicit $T_p$ relation of Theorem 6.1
gives a fast recursive way to compute $\sigma_s(n)$, and hence $r(n)$, from its
values at prime powers.

Applications of the $E_8$ formula itself are classical and wide-ranging: the
theta series controls the lattice's role in optimal sphere packing in dimension
$8$, in the construction of error-correcting structures, and in conformal field
theory where $E_8$ appears as a chiral lattice. The recurrence of Theorem 7.2
provides an arithmetic handle on the representation numbers used in these
settings.

---

## 10. Future directions

Several natural extensions present themselves.

1. **The $\sigma_7$ convolution identity ($E_4^2 = E_8$).** The rank-$16$
   Siegel–Weil setting (the lattices $E_8 \oplus E_8$ and $D_{16}^+$) predicts
   the classical identity
   $\sigma_7(n) = \sigma_3(n) + 120\sum_{m=1}^{n-1}\sigma_3(m)\sigma_3(n-m)$.
   Establishing this requires either a Lambert-series / generating-function
   argument or the one-dimensionality of the weight-$8$ space of modular forms;
   it is a substantial but well-defined target.

2. **Prime-factorization closed form.** Combining multiplicativity with the
   $p$-adic valuation gives
   $\sigma_s(n) = \prod_{p\mid n}\bigl(\sum_{i=0}^{v_p(n)} p^{si}\bigr)$ and, over
   $\mathbb{Q}$, the rational closed form $\prod_{p\mid n}
   (p^{s(v_p(n)+1)}-1)/(p^s-1)$.

3. **Dirichlet series / Euler product.** The coefficient-level Euler product
   $\sum_{n\ge1}\sigma_s(n)\,n^{-w} = \zeta(w)\,\zeta(w-s)$ makes the
   "$L$-function factorization" of the Eisenstein series explicit and can be
   phrased as a formal Dirichlet-series identity.

4. **Uniqueness of the genus.** The exactness of $\theta_{E_8} = E_4$ rests on
   the even unimodular rank-$8$ genus having a single class. Formalizing the
   mass formula / class-number-one statement in this rank would connect the
   coefficient identities here to the underlying lattice geometry.

5. **General even unimodular rank $8k$.** For $k \ge 2$ the theta series equals
   the Eisenstein series $E_{4k}$ only modulo cusp forms; capturing the cuspidal
   correction (e.g. via the discriminant form $\Delta$) would generalize the
   identity beyond the cusp-free rank-$8$ case.

---

## 11. Conclusion

We have shown that the arithmetic heart of the Siegel–Weil identity in rank $8$
— the convolution law obeyed by the divisor-cube sum $\sigma_3$ — is a special
case of a universal law valid for divisor-power sums $\sigma_s$ of every weight.
The proof reduces to a single geometric double-sum identity for products of
finite geometric progressions, propagated to all integers by multiplicativity.
From the universal law we obtained the explicit Hecke $T_p$ eigenvalue relation
for all $n$, and an elementary growth bound, both transported to the $E_8$
representation numbers. The picture that emerges is that $E_8$'s celebrated
counting formula $r(n) = 240\,\sigma_3(n)$ is one distinguished instance of an
arithmetic structure that spans every Eisenstein weight at once.
