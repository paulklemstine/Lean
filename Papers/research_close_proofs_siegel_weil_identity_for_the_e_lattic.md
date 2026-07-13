# The Siegel–Weil Identity for the $E_8$ Theta Series and the Arithmetic of Its Fourier Coefficients

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The $E_8$ lattice is the unique even unimodular positive-definite lattice of rank
$8$. Its theta series — the generating function of the number of lattice vectors
of each squared length — coincides with the normalized weight-$4$ Eisenstein
series $E_4$, an instance of the Siegel–Weil mass formula in a case where the
genus consists of a single class. Concretely, the number of vectors of squared
length $2n$ equals $r_{E_8}(n) = 240\,\sigma_3(n)$, where
$\sigma_3(n) = \sum_{d\mid n} d^3$. We develop the arithmetic consequences of
this identification at the level of Fourier coefficients. We establish: the
geometric closed form for $\sigma_3$ on prime powers; the Hecke three-term
recurrence characterizing $\sigma_3$ as the coefficient system of a Hecke
eigenform; multiplicativity of $\sigma_3$; and the global Hecke convolution
identity
$\sigma_3(m)\sigma_3(n) = \sum_{d\mid \gcd(m,n)} d^3\,\sigma_3(mn/d^2)$. We then
prove several structural refinements: the congruence
$\sigma_3(n)\equiv\sigma_1(n)\pmod 6$; the divisor lower bounds $n^3\le\sigma_3(n)$
and $n^3+1\le\sigma_3(n)$ for $n\ge2$; and a characterization of primality,
$\sigma_3(n)=n^3+1 \iff n$ prime (for $n\ge2$), together with the growth bound
$240\,n^3\le r_{E_8}(n)$. Finally we exhibit two contrarian counterexamples that
delimit the theory: $r_{E_8}$ is *not* multiplicative, and the Hecke recurrence
genuinely requires a prime base. We record the flagship open identity
$\sigma_7(n)=\sigma_3(n)+120\sum_{m=1}^{n-1}\sigma_3(m)\sigma_3(n-m)$ (equivalent
to $E_4^2=E_8$), verified numerically.

## 1. Introduction

Among positive-definite lattices, the even unimodular ones occupy a special
place: they are self-dual and their theta series are modular forms of weight
$n/2$ for the full modular group, where $n$ is the rank. In rank $8$ there is
exactly one such lattice up to isometry, the root lattice $E_8$. The Siegel–Weil
formula, in general, equates a weighted average of theta series over a genus with
an Eisenstein series; when the genus is a single class, the average degenerates to
that single theta series. In rank $8$ this yields the clean identity

$$\Theta_{E_8}(\tau) = E_4(\tau),$$

where $E_4$ is the normalized weight-$4$ Eisenstein series with Fourier expansion
$E_4(\tau) = 1 + 240\sum_{n\ge1}\sigma_3(n)\,q^n$, $q = e^{2\pi i\tau}$. Reading
off coefficients gives the representation numbers

$$r_{E_8}(n) = 240\,\sigma_3(n), \qquad \sigma_3(n) = \sum_{d\mid n} d^3.$$

The purpose of this paper is to develop, at the level of these Fourier
coefficients, the complete Hecke-eigenform structure carried by $\sigma_3$, and to
mine it for arithmetic refinements — including a primality characterization and a
congruence between divisor systems — while carefully marking the boundary of the
theory with two counterexamples. All statements are proved by elementary and
self-contained arguments; no analytic machinery beyond the definition of the
divisor function is required for the coefficient-level results.

## 2. Definitions and notation

Throughout, $n, m, d, p, a, b, r$ denote nonnegative integers, and $p$ is prime
where indicated.

**Definition 2.1 (Divisor power sums).** For $k \ge 0$ and $n \ge 1$, set
$$\sigma_k(n) = \sum_{d \mid n} d^k,$$
the sum being over the positive divisors of $n$. In particular $\sigma_0(n)$ is
the number of divisors, $\sigma_1(n)$ the sum of divisors, and $\sigma_3(n)$ the
sum of cubes of divisors. These are the arithmetic functions of interest.

**Definition 2.2 ($E_8$ representation number).** For $n \ge 1$, define
$$r_{E_8}(n) = 240\,\sigma_3(n).$$
By the Siegel–Weil identification $\Theta_{E_8}=E_4$, this is the number of
vectors $x$ in the $E_8$ lattice with $\langle x, x\rangle = 2n$.

**Definition 2.3 (Hecke convolution kernel).** For $m, n \ge 1$, define the
right-hand side of the Hecke identity
$$\mathrm{H}(m,n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right).$$

## 3. The prime-power structure

The behaviour of $\sigma_3$ on prime powers is the local building block of the
whole theory.

**Theorem 3.1 (Prime-power geometric form).** For a prime $p$ and $a \ge 0$,
$$\sigma_3(p^a) = 1 + p^3 + p^6 + \cdots + p^{3a} = \frac{p^{3(a+1)}-1}{p^3-1}.$$

*Proof sketch.* The divisors of $p^a$ are precisely $1, p, \dots, p^a$; cubing and
summing gives a finite geometric series with ratio $p^3$. $\square$

**Theorem 3.2 (Hecke three-term recurrence).** For a prime $p$ and $r \ge 0$,
$$\sigma_3(p^{r+2}) + p^3\,\sigma_3(p^r) = \sigma_3(p)\,\sigma_3(p^{r+1}).$$

*Proof sketch.* Write $g_a = \sigma_3(p^a) = (p^{3(a+1)}-1)/(p^3-1)$ from
Theorem 3.1. With $\sigma_3(p) = 1 + p^3$, both sides expand to
$(p^{3(r+3)} - p^3 - p^{3(r+1)} + 1)/(p^3-1)$ after clearing the common
denominator; equivalently, the identity is the standard second-order linear
recurrence $g_{r+2} = (1+p^3)g_{r+1} - p^3 g_r$ satisfied by any geometric
sequence with ratio $p^3$ shifted by a constant, whose characteristic roots are
$1$ and $p^3$. $\square$

The recurrence in Theorem 3.2 exhibits $\sigma_3$ as the coefficient system of a
Hecke eigenform: at each prime $p$, the local Hecke operator $T_p$ acts with
eigenvalue $\sigma_3(p) = 1 + p^3$, and the two-dimensional local recursion has
characteristic polynomial $X^2 - \sigma_3(p)X + p^3$.

## 4. Global structure: multiplicativity and Hecke convolution

**Theorem 4.1 (Multiplicativity).** If $\gcd(m,n) = 1$, then
$$\sigma_3(mn) = \sigma_3(m)\,\sigma_3(n).$$

*Proof sketch.* Divisors of $mn$ factor uniquely as products $d_1 d_2$ with
$d_1 \mid m$, $d_2 \mid n$ when $m, n$ are coprime; cubing respects this
factorization, and the double sum factors as a product of sums. $\square$

**Theorem 4.2 (Global Hecke convolution identity).** For all $m, n \ge 1$,
$$\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right) = \mathrm{H}(m,n).$$

*Proof sketch.* Both sides are multiplicative in the pair $(m,n)$ (using
Theorem 4.1 and the fact that $\gcd$ and the divisor sum split over coprime
components), so it suffices to check the identity when $m = p^a$ and $n = p^b$ are
powers of the same prime $p$. There, writing $\mu = \min(a,b)$, the right-hand
side becomes $\sum_{i=0}^{\mu} p^{3i}\,\sigma_3(p^{a+b-2i})$. Using the geometric
form of Theorem 3.1, one shows by induction on $\mu$ (equivalently, by the
telescoping identity
$\sum_{i=0}^{\mu} p^{3i} \sum_{l=0}^{a+b-2i} p^{3l} = \big(\sum_{i=0}^{a}p^{3i}\big)\big(\sum_{j=0}^{b}p^{3j}\big)$)
that this equals $\sigma_3(p^a)\,\sigma_3(p^b)$. $\square$

**Corollary 4.3 (Coprime case).** If $\gcd(m,n) = 1$ then $\mathrm{H}(m,n)$ has a
single term ($d=1$) and Theorem 4.2 reduces to Theorem 4.1.

**Corollary 4.4 (Diagonal / sum-of-squares relation).** Taking $m = n$ in
Theorem 4.2,
$$\sigma_3(n)^2 = \sum_{d \mid n} d^3\,\sigma_3\!\left(\frac{n^2}{d^2}\right).$$

## 5. Arithmetic refinements

We now record structural facts about $\sigma_3$ that go beyond the eigenform
identities.

### 5.1 A congruence between divisor systems

**Lemma 5.1 (Cubes mod 6).** For every integer $d \ge 0$, $d^3 \equiv d \pmod 6$.

*Proof sketch.* $d^3 - d = (d-1)\,d\,(d+1)$ is a product of three consecutive
integers, hence divisible by $2$ and by $3$, so by $6$. (Equivalently, check the
six residues $d \bmod 6 \in \{0,1,2,3,4,5\}$ directly.) $\square$

**Theorem 5.2 (Congruence $\sigma_3 \equiv \sigma_1 \bmod 6$).** For every
$n \ge 1$,
$$\sigma_3(n) \equiv \sigma_1(n) \pmod 6.$$

*Proof sketch.* Sum the pointwise congruence $d^3 \equiv d \pmod 6$ of
Lemma 5.1 over the divisors $d$ of $n$; the left side is $\sigma_3(n)$ and the
right side is $\sigma_1(n)$. $\square$

This is a genuine linear relation between the weight-$4$ and weight-$2$ divisor
systems, i.e. between the Fourier coefficients of $E_4$ and $E_2$.

### 5.2 Lower bounds and primality

**Theorem 5.3 (Cube lower bound).** For every $n \ge 1$, $n^3 \le \sigma_3(n)$.

*Proof sketch.* $n$ is a divisor of itself, so $n^3$ is one of the nonnegative
summands in $\sigma_3(n) = \sum_{d\mid n} d^3$. $\square$

**Theorem 5.4 (Two-divisor lower bound).** For every $n \ge 2$,
$n^3 + 1 \le \sigma_3(n)$.

*Proof sketch.* For $n \ge 2$ the divisors $1$ and $n$ are distinct, contributing
$1^3 + n^3 = n^3 + 1$ to the sum of nonnegative cubes $\sigma_3(n)$. $\square$

**Theorem 5.5 (Primality characterization).** For $n \ge 2$,
$$\sigma_3(n) = n^3 + 1 \quad\Longleftrightarrow\quad n \text{ is prime}.$$

*Proof sketch.* If $n$ is prime its only divisors are $1$ and $n$, so
$\sigma_3(n) = 1 + n^3$ exactly. Conversely, if $n \ge 2$ is composite it has a
divisor $d$ with $2 \le d < n$ and $d \ne 1, n$; then $1, d, n$ are three distinct
divisors, so $\sigma_3(n) \ge 1 + d^3 + n^3 \ge 1 + 8 + n^3 > n^3 + 1$,
contradicting equality. Hence equality forces primality. $\square$

Theorem 5.5 is a primality test expressed purely through the Fourier
coefficients of the $E_8$ theta series: $n$ is prime iff the coefficient
$\sigma_3(n)$ attains its minimum possible value $n^3+1$.

**Theorem 5.6 (Growth of the representation numbers).** For every $n \ge 1$,
$$240\,n^3 \le r_{E_8}(n).$$

*Proof sketch.* Multiply the bound $n^3 \le \sigma_3(n)$ of Theorem 5.3 by
$240$ and use $r_{E_8}(n) = 240\,\sigma_3(n)$. $\square$

## 6. Contrarian counterexamples: the boundary of the theory

The eigenform identities are sharp; naive strengthenings fail. Documenting the
failures clarifies exactly which normalizations and hypotheses are essential.

**Proposition 6.1 ($r_{E_8}$ is not multiplicative).** It is *not* true that
$r_{E_8}(mn) = r_{E_8}(m)\,r_{E_8}(n)$ for all coprime $m,n$. For instance
$$r_{E_8}(6) = 60480, \qquad r_{E_8}(2)\,r_{E_8}(3) = 2160 \cdot 6720 = 14515200.$$

*Proof sketch.* Direct evaluation: $\sigma_3(6) = 252$, so
$r_{E_8}(6) = 240\cdot252 = 60480$, whereas
$r_{E_8}(2)\,r_{E_8}(3) = (240\cdot9)(240\cdot28) = 240^2\cdot252$. The two differ
by the factor $240$. The correct coprime law is
$r_{E_8}(mn) = \tfrac{1}{240}\,r_{E_8}(m)\,r_{E_8}(n)$; multiplicativity holds for
$\sigma_3$, not for the normalized count $240\,\sigma_3$. $\square$

**Proposition 6.2 (Hecke recurrence requires primality).** There exist a
composite $p$ and $r$ for which the three-term recurrence of Theorem 3.2 fails.
Taking $p = 6$, $r = 0$:
$$\sigma_3(6^2) + 6^3\,\sigma_3(1) = 55477 \ne 63504 = \sigma_3(6)\,\sigma_3(6).$$

*Proof sketch.* $\sigma_3(36) = 55261$ and $\sigma_3(6) = 252$; then
$55261 + 216 = 55477$ while $252^2 = 63504$. The recurrence relies on the
prime-power divisor structure of Theorem 3.1, which is unavailable when the base
is composite. $\square$

## 7. Algorithms

We summarize the effective procedures underlying the numerical corroboration.

**Algorithm 7.1 (Divisor power sum).** Compute $\sigma_k(n)$ by trial division up
to $\sqrt n$, accumulating $d^k + (n/d)^k$ for each divisor pair. Complexity
$O(\sqrt n)$ arithmetic operations.

**Algorithm 7.2 (Hecke identity verifier).** For each pair $(m,n)$ in a range,
compute $\sigma_3(m)\sigma_3(n)$ and $\mathrm{H}(m,n) = \sum_{d\mid\gcd(m,n)} d^3\,\sigma_3(mn/d^2)$
and compare. Complexity $O(\sqrt{\gcd(m,n)}\cdot\sqrt{mn})$ per pair.

**Algorithm 7.3 ($E_4^2 = E_8$ convolution verifier).** For each $n$, compute the
Cauchy convolution $C(n) = \sum_{m=1}^{n-1}\sigma_3(m)\sigma_3(n-m)$ and check
$\sigma_7(n) = \sigma_3(n) + 120\,C(n)$. Complexity $O(n\sqrt n)$ per $n$.

## 8. Applications and discussion

The identification $r_{E_8}(n) = 240\,\sigma_3(n)$ is a template for how
extremal geometry and elementary arithmetic interlock. Three themes emerge.

1. **Geometry as arithmetic.** Counting lattice vectors — an intrinsically
   geometric operation — is reduced to summing cubes of divisors. This is the
   coefficient-level shadow of the modularity of theta series, and it makes
   geometric quantities computable by pure number theory.

2. **Eigenform rigidity.** The Hecke recurrence and convolution law show that the
   entire sequence $(r_{E_8}(n))_n$ is determined by its values at primes; the
   local eigenvalue $1 + p^3$ propagates everywhere. Propositions 6.1–6.2 show
   this rigidity is delicate: it depends on both the correct normalization and on
   primality.

3. **Primality in disguise.** Theorem 5.5 packages a primality test inside the
   Fourier coefficients of a modular form, illustrating how spectral/geometric
   data can encode multiplicative arithmetic.

## 9. Future directions

**Flagship target ($E_4^2 = E_8$).** The identity
$$\sigma_7(n) = \sigma_3(n) + 120\sum_{m=1}^{n-1}\sigma_3(m)\,\sigma_3(n-m),\qquad n\ge1,$$
is equivalent to the one-dimensionality of the space of weight-$8$ modular forms
for $\mathrm{SL}_2(\mathbb{Z})$ (so $E_4^2$ and $E_8$, having the same constant
term, must coincide). It is verified numerically here for $n = 1,\dots,10$. A
rigorous proof can proceed either through the modular-forms dimension count
$\dim M_8 = 1$, or through an elementary but intricate Lambert-series / divisor
convolution manipulation.

**Diagonal Hecke identity as a standalone lemma.** The specialization
$\sigma_3(n)^2 = \sum_{d\mid n} d^3\,\sigma_3(n^2/d^2)$ of Corollary 4.4 deserves
packaging as a reusable "sum-of-squares" Hecke relation.

**Sharper congruences.** Beyond $\sigma_3(n)\equiv\sigma_1(n)\pmod 6$, one may
seek Ramanujan-type congruences for $240\,\sigma_3(n)$ modulo small primes and
prime powers and their interaction with multiplicativity.

**Full theta-series statement.** The truly geometric goal is to prove directly
that *every* even unimodular positive-definite lattice of rank $8$ has exactly
$240\,\sigma_3(n)$ vectors of squared length $2n$ — the genuine Siegel–Weil
statement — which requires the theory of even unimodular lattices, the
single-class genus in rank $8$, and modularity of the theta series.

## 10. Conclusion

The Siegel–Weil identity in rank $8$ turns the census of the densest known
eight-dimensional lattice into the arithmetic function $\sigma_3$. We have
developed the full local and global Hecke structure of these coefficients, added
a congruence linking two divisor systems, a family of divisor lower bounds, and a
primality characterization, and delimited the theory with two sharp
counterexamples. The remaining frontier — the product identity $E_4^2 = E_8$ and
the lattice-theoretic Siegel–Weil statement itself — points toward a complete
elementary account of why eight-dimensional geometry and the arithmetic of
divisors are, in this case, one and the same.
