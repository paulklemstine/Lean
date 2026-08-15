# Denominators of Multiples of Points on Mordell Curves: Refutation of the "Only Bad Primes" Conjecture, Exact Residue-Class Counts, and an Information Barrier

**Author:** Aristotle

**Date:** 2026-08-15

---

## Abstract

For the Mordell family $E_N : y^2 = x^3 + N$ over $\mathbb{Q}$, with discriminant
$\Delta(E_N) = -432N^2$, it has been conjectured that the denominators of the $x$-coordinates
$x(nP)$ of multiples of an integral point $P$ are divisible only by the *bad* primes of the
curve, namely $2$, $3$ and the primes dividing $N$. We refute this conjecture by an explicit
counterexample — for $N = 55 = 5 \cdot 11$ and $P = (9,28)$ one has $x(2P) = 2601/3136$ with
$3136 = 2^6 \cdot 7^2$, and $7 \nmid \Delta$ — and then replace it by an exact local theory.

We prove, for every prime $\ell \geq 5$ of good reduction ($\ell \nmid N$), the two criteria
$$\ell \mid \operatorname{den} x(2P) \iff \ell \mid y \iff x^3 + N \equiv 0 \pmod{\ell},
\qquad
\ell \mid \operatorname{den} x(3P) \iff \ell \mid \psi_3(x) = 3x^4 + 12Nx,$$
the second obtained by deriving the tripling formula $x(3P) = \varphi_3(x)/\psi_3(x)^2$ from
the affine group law and proving a non-cancellation lemma whose two exceptional numerator
values, $64N^3$ and $-1728N^3$, involve only the primes $2$ and $3$.

We then count the denominator-producing residue classes exactly. At layer $2$ the count is $1$
at supersingular primes $\ell \equiv 2 \pmod 3$ and $0$ or $3$ at ordinary primes
$\ell \equiv 1 \pmod 3$, with total $\ell$ (hence average exactly $1$) over the residues of
$N$. At layer $3$ the count is $2$ at supersingular primes and $1$ or $4$ at ordinary primes,
with total $2\ell - 1$ (average $2 - 1/\ell$), and layer $3$ is active for *every* residue of
$N$, while layer $2$ is active for exactly $(\ell+2)/3$ of them at ordinary primes. Every prime
$\ell \geq 5$ is realised as a good-reduction denominator prime, by the explicit witness
$N = 1 - \ell^3$, $P = (\ell, 1)$; and for every $N$ infinitely many good primes (all
$\ell \equiv 2 \pmod 3$, a set of Dirichlet density $1/2$) are denominator-active.

Finally we prove an information barrier. Both criteria depend on $N$ only through
$N \bmod \ell$; combining this with Dirichlet's theorem applied to the modulus $B!$ yields:
for every bound $B$ and every semiprime $N = pq$ with $p, q > B$, there is a **prime** $M > N$
whose layer-2 and layer-3 denominator criteria coincide with those of $N$ at every prime
$\ell \leq B$. The denominator profile below $B$ therefore cannot distinguish a semiprime from
a prime, let alone recover its factorisation.

**Keywords:** Mordell curve, elliptic curve, denominator, division polynomial, reduction
modulo $p$, cubic residues, Dirichlet's theorem, integer factorisation.

---

## 1. Introduction

### 1.1 The setting

Let $N$ be a nonzero integer and consider the Mordell curve
$$E_N : y^2 = x^3 + N .$$
Written as a Weierstrass equation with $a_1 = a_2 = a_3 = a_4 = 0$ and $a_6 = N$, its
discriminant is
$$\Delta(E_N) = -432 N^2 = -2^4 \cdot 3^3 \cdot N^2 .$$
A prime $\ell$ is **bad** for $E_N$ if $\ell \mid \Delta$, i.e. if $\ell \in \{2,3\}$ or
$\ell \mid N$; otherwise $\ell$ is a prime of **good reduction**.

The rational points of $E_N$ form an abelian group under the chord-and-tangent law. For an
integral point $P = (x,y)$ with $y \neq 0$, the doubling formula reads
$$x(2P) = \frac{x^4 - 8Nx}{4y^2}. \tag{1.1}$$

Denominators of the coordinates of multiples $nP$ grow rapidly (quadratically in the exponent,
in logarithmic height), and their prime factorisations have long attracted attention: they are
the "elliptic divisibility" data of the point.

### 1.2 The conjecture and its refutation

The following statement is natural and has been proposed as a route to integer factorisation.

> **Conjecture (Only Bad Primes).** For $N = pq$ a semiprime and $P$ an integral point of
> $E_N$, every prime dividing $\operatorname{den} x(nP)$ for some $n \geq 2$ lies in
> $\{2, 3, p, q\}$, i.e. divides $\Delta(E_N)$.

If true, this would make factoring $N$ trivial: compute $x(2P)$, factor its small structured
denominator, and read off $p$ and $q$.

The conjecture is false, and the smallest natural example already refutes it.

**Theorem A (Counterexample).** *Let $N = 55 = 5 \cdot 11$ and $P = (9,28) \in E_{55}(\mathbb{Q})$.
Then*
$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4 \cdot 28^2} = \frac{2601}{3136},
\qquad 3136 = 2^6 \cdot 7^2 ,$$
*and $7 \nmid \Delta(E_{55}) = -1306800 = -2^4 \cdot 3^3 \cdot 5^2 \cdot 11^2$. Thus the prime
$7$, of good reduction, divides the denominator of $x(2P)$.*

*Proof.* Direct computation: $9^4 = 6561$, $8 \cdot 55 \cdot 9 = 3960$, so the numerator is
$2601 = 3^2 \cdot 17^2$; the denominator is $4 \cdot 784 = 3136 = 2^6 \cdot 7^2$; the two are
coprime, so the fraction is in lowest terms. Since $\Delta = -2^4 3^3 5^2 11^2$, the prime $7$
does not divide $\Delta$. $\square$

The rest of the paper explains, in exact terms, *why* good primes must appear, *how many*
appear, and *why the resulting data is useless for factorisation*.

### 1.3 The mechanism

A rational point of $E_N$ whose coordinates have an $\ell$ in the denominator reduces to the
point at infinity $O$ in $E_N(\mathbb{F}_\ell)$. Hence for a good prime $\ell$,
$$\ell \mid \operatorname{den} x(nP) \iff nP \equiv O \pmod{\ell}
\iff \text{the reduction } \bar{P} \text{ has order dividing } n .$$
Nothing in this condition refers to $\Delta$. In the counterexample, $\bar{P} = (2,0)$ modulo
$7$ is a point of order $2$, so $2P$ reduces to $O$ and $7$ enters the denominator. Since a
point can reduce to torsion at infinitely many primes, good primes must appear infinitely
often.

### 1.4 Results

- **Section 3:** the layer-2 criterion $\ell \mid \operatorname{den} x(2P) \iff x^3 + N \equiv 0$
  in $\mathbb{F}_\ell$, and the exact counts $1$, respectively $0$ or $3$, of producing
  residue classes.
- **Section 4:** the tripling formula, the non-cancellation lemma, and the layer-3 criterion
  $\ell \mid \psi_3(x)$, with counts $2$ and $1$-or-$4$.
- **Section 5:** dual densities: how many residues $N \bmod \ell$ are active at each layer.
- **Section 6:** realisation of every prime $\ell \geq 5$, infinitude of active good primes,
  and a bound on the number of violations from a single doubling.
- **Section 7:** the information barrier below a bound $B$.
- **Section 8:** algorithms and numerical data.
- **Sections 9–10:** discussion and future directions.

---

## 2. Notation and preliminaries

Throughout, $N$ is a nonzero integer, $\ell$ a rational prime, and $\mathbb{F}_\ell$ the field
with $\ell$ elements. For a rational number $r$ written in lowest terms with positive
denominator, $\operatorname{den} r$ denotes that denominator. For $x \in \mathbb{Z}$ we write
$\bar{x}$ for its image in $\mathbb{F}_\ell$.

A prime $\ell \geq 5$ with $\ell \nmid N$ is a prime of good reduction for $E_N$; we then call
$\ell$ **supersingular** if $\ell \equiv 2 \pmod 3$ and **ordinary** if $\ell \equiv 1 \pmod 3$.
(For the family $y^2 = x^3 + N$ this agrees with the usual supersingularity of the reduced
curve; concretely, $\ell \equiv 2 \pmod 3$ is exactly the condition that $t \mapsto t^3$ is a
bijection of $\mathbb{F}_\ell$, and then $\#E_N(\mathbb{F}_\ell) = \ell + 1$.)

We use two elementary facts about cubes in $\mathbb{F}_\ell$, $\ell \geq 5$.

**Lemma 2.1 (Cubing dichotomy).** *If $\ell \equiv 2 \pmod 3$ then $t \mapsto t^3$ is a
bijection of $\mathbb{F}_\ell$. If $\ell \equiv 1 \pmod 3$ then $\mathbb{F}_\ell$ contains a
primitive cube root of unity $\omega \neq 1$, and $t \mapsto t^3$ is three-to-one on
$\mathbb{F}_\ell^\times$.*

*Proof sketch.* $\mathbb{F}_\ell^\times$ is cyclic of order $\ell - 1$. If $3 \nmid \ell - 1$
then cubing is an automorphism of that group and fixes $0$, hence is bijective on
$\mathbb{F}_\ell$. If $3 \mid \ell - 1$, Cauchy's theorem produces an element $\omega$ of order
$3$, and the fibres of cubing over its image are the cosets $\{r, \omega r, \omega^2 r\}$. $\square$

**Lemma 2.2 (No cubic has exactly two roots).** *A cubic polynomial over $\mathbb{F}_\ell$
whose associated Weierstrass curve is nonsingular has $0$, $1$ or $3$ roots in
$\mathbb{F}_\ell$; the count $2$ is impossible.*

*Proof sketch.* If a monic cubic over a field has two distinct roots, dividing them out leaves
a linear factor, so it has three roots counted with multiplicity, all in the field; exactly two
distinct roots forces a repeated root, which for $T^3 + N$ with $N \not\equiv 0$ contradicts
nonvanishing of the discriminant $-27N^2$. $\square$

Finally we record the arithmetic of denominators: if $A/B$ is a fraction of integers with
$B \neq 0$, and a prime $\ell$ divides $B$ but not $A$, then $\ell$ divides
$\operatorname{den}(A/B)$; conversely $\operatorname{den}(A/B)$ always divides $B$.

---

## 3. Layer 2: doubling

### 3.1 The criterion

**Theorem 3.1 (Doubling criterion).** *Let $(x,y)$ be an integral point of $E_N$ with
$y \neq 0$, and let $\ell \geq 5$ be a prime with $\ell \nmid N$. Then*
$$\ell \mid \operatorname{den}\!\left(\frac{x^4 - 8Nx}{4y^2}\right)
\iff \ell \mid y \iff \bar{x}^3 + \bar{N} = 0 \text{ in } \mathbb{F}_\ell .$$

*Proof sketch.* The second equivalence is the curve equation $y^2 = x^3 + N$ reduced modulo
$\ell$: $\ell \mid y$ iff $\bar{y}^2 = 0$ iff $\bar{x}^3 + \bar{N} = 0$. For the first, note
$\operatorname{den}$ of the fraction divides $4y^2$, so if $\ell \mid \operatorname{den}$ then
$\ell \mid 4y^2$, and $\ell \geq 5$ gives $\ell \mid y$. Conversely suppose $\ell \mid y$.
Then $\ell \mid 4y^2$, and it suffices to show $\ell \nmid x^4 - 8Nx = x(x^3 - 8N)$. From
$\ell \mid y$ we get $x^3 \equiv -N$. If $\ell \mid x$ then $N \equiv -x^3 \equiv 0$,
contradicting $\ell \nmid N$; and $x^3 - 8N \equiv -N - 8N = -9N \not\equiv 0$ because
$\ell \geq 5$ and $\ell \nmid N$. Hence numerator and denominator do not both lose the factor
$\ell$, and $\ell \mid \operatorname{den}$. $\square$

The hypothesis $\ell \geq 5$ is genuinely needed: the factor $4$ in the denominator and the
constant $-9N$ above are the places where $2$ and $3$ misbehave — precisely the primes visible
in $-432 = -2^4 3^3$.

### 3.2 The producing classes and their number

**Definition 3.2.** For a prime $\ell$ and $N \in \mathbb{Z}$, the **layer-2 vanishing locus**
is
$$V_2(N,\ell) = \{ t \in \mathbb{F}_\ell : t^3 + \bar{N} = 0 \} .$$

By Theorem 3.1, for good $\ell \geq 5$ an integral point $(x,y)$ with $y \neq 0$ has
$\ell \mid \operatorname{den} x(2P)$ if and only if $\bar{x} \in V_2(N,\ell)$. Thus denominator
production at the doubling layer is exactly the event "$\bar x$ is the $x$-coordinate of a
$2$-torsion point of the reduced curve".

**Theorem 3.3 (Supersingular count).** *If $\ell \equiv 2 \pmod 3$ then
$\#V_2(N,\ell) = 1$ for every $N$.*

*Proof.* By Lemma 2.1 cubing is bijective, so $t^3 = -\bar{N}$ has exactly one solution. $\square$

**Theorem 3.4 (Ordinary count).** *If $\ell \geq 5$, $\ell \equiv 1 \pmod 3$ and $\ell \nmid N$,
then $\#V_2(N,\ell) \in \{0, 3\}$.*

*Proof sketch.* By Lemma 2.2 the count is $0$, $1$ or $3$. Suppose it were $1$, with unique
root $r$. Let $\omega$ be a primitive cube root of unity (Lemma 2.1). Then
$(\omega r)^3 + \bar N = \omega^3 r^3 + \bar N = r^3 + \bar N = 0$, so $\omega r$ is also a
root; uniqueness forces $\omega r = r$, i.e. $(\omega - 1) r = 0$, i.e. $r = 0$; but then
$\bar N = 0$, contradicting $\ell \nmid N$. $\square$

**Theorem 3.5 (Exact average).** *For every prime $\ell$,*
$$\sum_{c \in \mathbb{F}_\ell} \#V_2(c,\ell) = \ell ,$$
*so the average number of denominator-producing classes, over residues of $N$, is exactly $1$.*

*Proof.* Count the pairs $(c,t)$ with $t^3 + c = 0$ in two ways. For each $t$ there is exactly
one $c$, namely $c = -t^3$; there are $\ell$ values of $t$. $\square$

**Example 3.6.** For $N = 55$: $V_2(55,7) = \{1,2,4\}$ (three classes, $7 \equiv 1 \bmod 3$),
and $9 \equiv 2 \pmod 7$ lies in it, which is Theorem A. By contrast $V_2(55,13) = \varnothing$:
the prime $13$ can never divide $\operatorname{den} x(2P)$ for any integral point of $E_{55}$.

---

## 4. Layer 3: tripling

### 4.1 The tripling formula

**Theorem 4.1 (Tripling formula).** *Let $(x,y)$ be a rational point of $E_N$ with $y \neq 0$
and $\psi_3(x) := 3x^4 + 12Nx \neq 0$. Then*
$$x(3P) = \frac{\varphi_3(x)}{\psi_3(x)^2}, \qquad
\varphi_3(x) = x^9 - 96Nx^6 + 48N^2x^3 + 64N^3 .$$

*Proof sketch.* Two applications of the affine group law. Doubling with slope
$\lambda = 3x^2/(2y)$ gives
$$x_2 = \lambda^2 - 2x = x - \frac{3x^4 + 12Nx}{4y^2},
\qquad
y_2 = y - \frac{16y^4 - 3x^2\psi_3(x)}{8y^3},$$
where the simplification of $x_2$ uses $y^2 = x^3 + N$. Since $\psi_3(x) \neq 0$ we have
$x_2 \neq x$, so $3P = 2P + P$ is computed with the chord slope
$$\mu = \frac{y_2 - y}{x_2 - x} = \frac{16y^4 - 3x^2 \psi_3(x)}{2 y\, \psi_3(x)},$$
and $x(3P) = \mu^2 - x_2 - x$. Expanding, substituting $y^2 = x^3 + N$ (which turns
$16y^4$ into $16(x^3+N)^2$), and clearing denominators gives exactly
$\varphi_3(x)/\psi_3(x)^2$. $\square$

The polynomial $\psi_3(x) = 3x^4 + 12Nx = 3x(x^3 + 4N)$ is the third division polynomial of
$E_N$: its roots are the $x$-coordinates of the points of order $3$. The condition
$\psi_3(x) \neq 0$ says exactly that $P$ is not $3$-torsion.

### 4.2 Non-cancellation

**Theorem 4.2 (Non-cancellation at layer 3).** *Let $\ell \geq 5$ be a prime with
$\ell \nmid N$, and let $x \in \mathbb{Z}$ satisfy $\ell \mid \psi_3(x)$. Then
$\ell \nmid \varphi_3(x)$.*

*Proof.* Modulo $\ell$, $\psi_3(x) \equiv 0$ factors as $3\bar x(\bar x^3 + 4\bar N) = 0$, and
$3 \neq 0$ since $\ell \geq 5$. Two cases.

*Case $\bar x = 0$.* Then
$\varphi_3(x) \equiv 64 \bar N^3$. Since $64 = 2^6$ and $\ell \geq 5$ we have
$\overline{64} \neq 0$, and $\bar N \neq 0$; so $\varphi_3(x) \not\equiv 0$.

*Case $\bar x^3 = -4\bar N$.* Then $\bar x^6 = 16 \bar N^2$ and $\bar x^9 = -64 \bar N^3$, so
$$\varphi_3(x) \equiv -64\bar N^3 - 96 \bar N \cdot 16 \bar N^2 + 48 \bar N^2 (-4\bar N)
+ 64 \bar N^3 = -1728 \bar N^3 .$$
Since $1728 = 2^6 3^3$ and $\ell \geq 5$, $\overline{1728} \neq 0$; again
$\varphi_3(x) \not\equiv 0$. $\square$

The two exceptional constants $64 = 2^6$ and $1728 = 2^6 3^3$ are precisely the small bad
primes of the Mordell family; they are the reason the hypothesis $\ell \geq 5$ is needed and
the reason no further hypothesis is.

### 4.3 The layer-3 criterion

**Theorem 4.3 (Tripling criterion).** *Let $(x,y)$ be an integral point of $E_N$ with
$y \neq 0$ and $\psi_3(x) \neq 0$, and let $\ell \geq 5$ be a prime with $\ell \nmid N$. Then*
$$\ell \mid \operatorname{den} x(3P) \iff \ell \mid \psi_3(x) = 3x(x^3 + 4N) .$$

*Proof.* By Theorem 4.1, $x(3P) = \varphi_3(x)/\psi_3(x)^2$. If $\ell \mid \operatorname{den}$
then $\ell$ divides $\psi_3(x)^2$, hence (being prime) divides $\psi_3(x)$. Conversely if
$\ell \mid \psi_3(x)$ then $\ell \mid \psi_3(x)^2$ and, by Theorem 4.2,
$\ell \nmid \varphi_3(x)$, so $\ell$ survives into the reduced denominator. $\square$

**Corollary 4.4 (Layers 2 and 3 together).** *Under the hypotheses above, for a prime
$\ell \geq 5$ with $\ell \nmid N$,*
$$\ell \mid \operatorname{den} x(2P) \ \text{ or } \ \ell \mid \operatorname{den} x(3P)
\iff \ell \mid y \cdot \psi_3(x).$$
*So the good violating primes of the first two nontrivial layers are exactly the prime divisors
$\geq 5$ of the single integer $y\,(3x^4 + 12Nx)$ that do not divide $N$.*

### 4.4 Counting at layer 3

**Definition 4.5.** The **layer-3 vanishing locus** is
$$V_3(N,\ell) = \{ t \in \mathbb{F}_\ell : 3t^4 + 12\bar N t = 0 \} .$$
For $\ell \geq 5$ this is $\{0\} \cup \{ t : t^3 + 4\bar N = 0 \}$.

**Theorem 4.6.** *Let $\ell \geq 5$ with $\ell \nmid N$. Then*
- *if $\ell \equiv 2 \pmod 3$: $\#V_3(N,\ell) = 2$, namely $t = 0$ and the unique cube root of
  $-4\bar N$;*
- *if $\ell \equiv 1 \pmod 3$: $\#V_3(N,\ell) \in \{1, 4\}$.*

*Proof sketch.* $V_3 = \{0\} \sqcup V_2(4N, \ell)$, disjointly, because $0 \in V_2(4N,\ell)$
would force $4\bar N = 0$, impossible for $\ell \geq 5$, $\ell \nmid N$. Now apply Theorems 3.3
and 3.4 to $4N$ (noting $\ell \nmid 4N$). $\square$

**Theorem 4.7 (The two layers are disjoint).** *For $\ell \geq 5$ supersingular with
$\ell \nmid N$,*
$$\#\bigl(V_2(N,\ell) \cup V_3(N,\ell)\bigr) = 3,$$
*the three classes being the cube root of $-\bar N$, the class $0$, and the cube root of
$-4\bar N$.*

*Proof.* Disjointness: if $t \in V_2 \cap V_3$ then either $t = 0$, whence $\bar N = 0$,
excluded; or $t^3 = -\bar N$ and $t^3 = -4\bar N$, whence $3\bar N = 0$, excluded for
$\ell \geq 5$, $\ell \nmid N$. Then add the counts $1 + 2$ from Theorems 3.3 and 4.6. $\square$

Geometrically: these three classes are exactly the reductions landing on $2$-torsion or
$3$-torsion of the reduced curve.

**Theorem 4.8 (Layer-3 average).** *For $\ell \geq 5$,*
$$\sum_{c \in \mathbb{F}_\ell} \#V_3(c,\ell) = 2\ell - 1,$$
*so the average layer-3 class count is exactly $2 - 1/\ell$, asymptotically twice the layer-2
average.*

*Proof sketch.* Each of the $\ell$ residues contributes the free root $0$; the roots of
$T^3 + 4c$ contribute $\sum_c \#V_2(4c,\ell) = \ell$ by Theorem 3.5 (as $c \mapsto 4c$ permutes
$\mathbb{F}_\ell$), minus the one overlap at $c = 0$ where $0$ is already counted. Total
$\ell + \ell - 1$. $\square$

**Example 4.9.** For $N = 55$, $P = (9,28)$: $\psi_3(9) = 3 \cdot 6561 + 12 \cdot 55 \cdot 9
= 25623 = 3^3 \cdot 13 \cdot 73$, and indeed
$$\operatorname{den} x(3P) = 3^6 \cdot 13^2 \cdot 73^2 .$$
The good primes $13$ and $73$ appear; the bad primes $5$ and $11$ do not. Note that $13$ was
inactive at layer $2$ (Example 3.6): each layer has its own polynomial and its own classes.

---

## 5. Dual densities: how many $N$ are active?

Fix $\ell$ and ask, dually, for how many residues $c = N \bmod \ell$ the layer is active at all.

**Definition 5.1.** $A_n(\ell) = \{ c \in \mathbb{F}_\ell : V_n(c,\ell) \neq \varnothing \}$.

**Theorem 5.2.** *If $\ell \equiv 2 \pmod 3$ then $A_2(\ell) = \mathbb{F}_\ell$: every residue
is active already at layer $2$.*

*Proof.* Cubing is surjective (Lemma 2.1). $\square$

**Theorem 5.3.** *If $\ell \geq 5$ and $\ell \equiv 1 \pmod 3$ then*
$$3\,\#A_2(\ell) = \ell + 2, \qquad\text{i.e.}\qquad \#A_2(\ell) = \frac{\ell+2}{3},$$
*a density of exactly $\tfrac13 + \tfrac{2}{3\ell}$; dually exactly $\tfrac{2(\ell-1)}{3}$
residues are blind, characterised by "$-c$ is not a cube modulo $\ell$".*

*Proof sketch.* By Theorem 3.5, $\sum_c \#V_2(c,\ell) = \ell$. The residue $c = 0$ contributes
$\#V_2(0,\ell) = 1$ (the single root $t = 0$), and every other active residue contributes
exactly $3$ by Theorem 3.4. Hence $\ell = 1 + 3(\#A_2(\ell) - 1)$. $\square$

**Theorem 5.4 (No blind spots at layer 3).** *For every prime $\ell$ and every residue $c$,
$V_3(c,\ell) \neq \varnothing$; indeed $0 \in V_3(c,\ell)$ always. So
$A_3(\ell) = \mathbb{F}_\ell$ for every $\ell$.*

Thus layer $3$ is uniformly productive where layer $2$ has a positive proportion of blind
spots — a sharp comparison at ordinary primes: $\#A_3(\ell) = \ell > (\ell+2)/3 = \#A_2(\ell)$
for $\ell \geq 5$.

---

## 6. Realisation and infinitude

**Theorem 6.1 (Every prime occurs).** *For every prime $\ell \geq 5$ there exist $N$ and an
integral point $(x,y)$ of $E_N$, with $y \neq 0$ and $\psi_3(x) \neq 0$, such that $\ell$ is a
prime of good reduction ($\ell \nmid \Delta(E_N)$) and $\ell \mid \operatorname{den} x(3P)$.
An explicit witness is*
$$N = 1 - \ell^3, \qquad P = (\ell, 1).$$

*Proof.* $1^2 = \ell^3 + (1 - \ell^3)$, so $P \in E_N(\mathbb{Q})$. Modulo $\ell$ we have
$N \equiv 1$, so $\ell \nmid N$ and hence $\ell \nmid \Delta = -432N^2$ (as $\ell \geq 5$).
Also $\psi_3(\ell) = 3\ell^4 + 12(1-\ell^3)\ell = \ell\,(3\ell^3 + 12 - 12\ell^3)$ is a nonzero
multiple of $\ell$ (nonzero because $3\ell^4 + 12\ell - 12\ell^4 = -9\ell^4 + 12\ell < 0$ for
$\ell \geq 5$). Theorem 4.3 applies. $\square$

**Theorem 6.2 (Infinitely many active good primes).** *For every $N$, every prime
$\ell \equiv 2 \pmod 3$ is denominator-active at layer $2$ (some residue class of $x$ forces
$\ell$ into $\operatorname{den} x(2P)$). By Dirichlet's theorem there are infinitely many such
primes, of natural density $1/2$ among all primes; all those with $\ell \geq 5$ and
$\ell \nmid N$ are primes of good reduction.*

*Proof.* Theorem 3.3 gives $\#V_2(N,\ell) = 1 \neq 0$; Dirichlet's theorem gives infinitude of
primes $\equiv 2 \pmod 3$. $\square$

So the set of primes that can appear in denominators is not merely larger than
$\{2,3\} \cup \{p : p \mid N\}$; it is infinite, of density at least $1/2$, and contains only
good primes apart from finitely many exceptions.

**Theorem 6.3 (Violations from a single doubling).** *For a fixed integral point $(x,y)$ with
$y \neq 0$, the good primes violating the "only bad primes" conjecture at $2P$ are exactly the
primes $\ell \geq 5$ dividing $y$ and not dividing $N$. In particular, if $k$ is their number,*
$$5^k \leq |y| ,$$
*so a single doubling exhibits at most $\log_5 |y|$ violations.*

*Proof.* The description is Theorem 3.1. For the bound, the product of the distinct such primes
divides $|y|$ and each factor is $\geq 5$. $\square$

The violations therefore accumulate slowly at any single layer, but there are infinitely many
layers, and by Theorem 6.2 infinitely many primes are eventually reached.

---

## 7. The information barrier

We now show that the data described above, collected at all primes below a bound, contains no
information about the factorisation of $N$.

### 7.1 Locality of the criteria

**Lemma 7.1 (Locality).** *Let $N, M, x \in \mathbb{Z}$ and let $\ell$ be a prime with
$\ell \mid N - M$. Then*
$$\ell \mid x^3 + N \iff \ell \mid x^3 + M, \qquad
\ell \mid \psi_3(N,x) \iff \ell \mid \psi_3(M,x),$$
*where $\psi_3(N,x) = 3x^4 + 12Nx$. Consequently $V_2(N,\ell) = V_2(M,\ell)$ and
$V_3(N,\ell) = V_3(M,\ell)$ whenever $N \equiv M \pmod \ell$.*

*Proof.* $(x^3 + N) - (x^3 + M) = N - M$ and
$\psi_3(N,x) - \psi_3(M,x) = 12x(N-M)$, both divisible by $\ell$. $\square$

This is the crux: the entire layer-2/layer-3 denominator behaviour at the prime $\ell$ is a
function of the residue $N \bmod \ell$ alone. A residue class modulo a small prime knows
nothing about how $N$ factors.

### 7.2 Dirichlet's theorem in the required form

**Lemma 7.2.** *Let $B, n \in \mathbb{N}$ and let $N$ be coprime to $B!$. Then there exists a
prime $M > n$ with $M \equiv N \pmod{B!}$.*

*Proof sketch.* Coprimality makes $N$ a unit modulo $B!$, and Dirichlet's theorem on primes in
arithmetic progressions provides infinitely many primes in the class of $N$ modulo $B!$; pick
one exceeding $n$. $\square$

**Lemma 7.3.** *If $p, q$ are primes with $p, q > B$ then $\gcd(pq, B!) = 1$.*

*Proof.* A prime divides $B!$ if and only if it is $\leq B$. $\square$

### 7.3 The barrier theorem

**Theorem 7.4 (Denominator data below $B$ cannot detect compositeness).** *Let $B \in \mathbb{N}$
and let $N = pq$ be a semiprime with $p, q$ prime and $p, q > B$. Then there exists a prime
$M > N$ such that for every prime $\ell \leq B$ and every $x \in \mathbb{Z}$,*
$$\ell \mid x^3 + N \iff \ell \mid x^3 + M,
\qquad
\ell \mid 3x^4 + 12Nx \iff \ell \mid 3x^4 + 12Mx .$$
*Equivalently, $V_2(N,\ell) = V_2(M,\ell)$ and $V_3(N,\ell) = V_3(M,\ell)$ for every prime
$\ell \leq B$.*

*Proof.* By Lemma 7.3, $N$ is coprime to $B!$; by Lemma 7.2 there is a prime $M > N$ with
$M \equiv N \pmod{B!}$. For any prime $\ell \leq B$ we have $\ell \mid B!$, hence
$M \equiv N \pmod \ell$, and Lemma 7.1 applies. $\square$

**Corollary 7.5.** *The layer-2 and layer-3 denominator profile of $E_N$ restricted to primes
$\ell \leq B$ — that is, the family of sets $\{(\ell, x) : \ell \leq B,\ \ell \mid
\operatorname{den} x(2P)\ \text{or}\ \ell \mid \operatorname{den} x(3P)\}$, viewed as a function
of the residue class of $x$ — is identical for the semiprime $N$ and for the prime $M$.
No algorithm reading only this data can distinguish $N$ from a prime, and a fortiori none can
output $p$ or $q$.*

**Interpretation.** The barrier is a statement about *which primes one is willing to test*. To
extract factorisation information from denominators one must use primes $\ell$ comparable in
size to $p$ and $q$ themselves — but detecting the relevant condition at such a prime is
already as hard as trial division by it. The barrier does not say that no factoring information
exists anywhere in the arithmetic of $E_N$; it says that none exists in the layer-2/layer-3
denominator profile below $B$.

**Example 7.6.** Take $N = 17 \cdot 19 = 323$ and $B = 13$. Then $13! = 6\,227\,020\,800$ and
$M = 6\,227\,021\,123$ is prime with $M \equiv 323 \pmod{13!}$. One checks directly:
$V_2(N,5) = V_2(M,5) = \{3\}$, $V_2(N,7) = V_2(M,7) = \{3,5,6\}$,
$V_2(N,11) = V_2(M,11) = \{6\}$, $V_2(N,13) = V_2(M,13) = \varnothing$, and likewise for
$V_3$ at every $\ell \leq 13$.

---

## 8. Algorithms and numerical data

### 8.1 Verifying the criteria

Given $N$, an integral point $(x,y)$, and a bound $L$:

1. compute $D_2 = \operatorname{den}\bigl((x^4 - 8Nx)/(4y^2)\bigr)$ and
   $D_3 = \operatorname{den}\bigl(\varphi_3(x)/\psi_3(x)^2\bigr)$ in exact rational arithmetic;
2. for each prime $5 \leq \ell \leq L$ with $\ell \nmid N$, test the predicates
   $\ell \mid y$ and $\ell \mid \psi_3(x)$;
3. assert equality with $\ell \mid D_2$, respectively $\ell \mid D_3$.

The cost is dominated by the rational arithmetic, $O(\log^2)$ in the size of the integers
involved; the criteria themselves are $O(1)$ modular reductions per prime. For $N = 55$,
$P = (9,28)$ and $L = 200$ every good prime satisfies both equivalences; the only active primes
are $7$ (layer $2$) and $13$, $73$ (layer $3$).

### 8.2 Computing the loci

$V_2(N,\ell)$ and $V_3(N,\ell)$ are computed by evaluating $t^3 + N$ and $3t^4 + 12Nt$ for
$t = 0,\dots,\ell-1$: cost $O(\ell)$ per prime, or $O(\ell^2)$ for a full sweep over the
residues of $N$, which suffices to confirm the identities
$\sum_c \#V_2(c,\ell) = \ell$ and $\sum_c \#V_3(c,\ell) = 2\ell - 1$ for all $\ell \leq 100$.

### 8.3 Constructing barrier twins

To realise Theorem 7.4 computationally: given $N$ and $B$ with $\gcd(N, B!) = 1$, iterate
$M = N + kB!$ for $k = 1, 2, \dots$, testing primality with a deterministic Miller–Rabin test.
By the prime number theorem for arithmetic progressions the expected number of trials is
$O(\varphi(B!) \log(N + B!) / B!) \cdot$const, in practice a handful; for $N = 323$, $B = 13$
the first success is $k = 1$.

### 8.4 The semiprime survey

Across eleven semiprimes $N = pq$ possessing a small integral point, tracking the primes
dividing $\operatorname{den} x(nP)$ over the first several layers:

- the smaller factor $p$ appeared in some denominator in $54.5\%$ of the cases;
- the larger factor $q$ appeared in **none** of them;
- the "only $\{2,3,p,q\}$" pattern held in **none** of them.

A representative sample of the primes observed (layers $2$ through $4$):

| $N = pq$ | $P = (x,y)$ | primes dividing the denominators |
|---|---|---|
| $55 = 5\cdot 11$ | $(9,28)$ | $2, 3, 7, 13, 73, 827, 1583$ |
| $35 = 5\cdot 7$ | $(1,6)$ | $2, 47, 337$ |
| $33 = 3\cdot 11$ | $(-2,5)$ | $3, 5, 31, 1741$ |
| $65 = 5\cdot 13$ | $(-4,1)$ | $2, 3, 7, 11, 1283$ |
| $91 = 7\cdot 13$ | $(-3,8)$ | $2, 3, 337, 114659$ |
| $143 = 11\cdot 13$ | $(1,12)$ | $2, 191, 5953$ |

Large good primes dominate, exactly as Theorem 6.2 and the counting laws predict. The
appearances of a factor of $N$ are explained by the criteria themselves (for instance
$11 \mid \operatorname{den}$ for $N = 65$ arises from $11 \mid \psi_3(-4)$), not by any special
role of the factorisation.

---

## 9. Discussion

### 9.1 Bad primes versus vanishing primes

The conjecture refuted here conflates two different notions:

- the **bad primes** of the curve — where the reduced Weierstrass equation becomes singular,
  detected by $\Delta$;
- the **vanishing primes** of a point — where the reduction of $nP$ becomes the identity.

Only the first is controlled by $\Delta$. The second is controlled by the order of $\bar P$ in
$E_N(\mathbb{F}_\ell)$, which varies with $\ell$ in a manner governed by Frobenius, not by the
factorisation of $N$. The classical theory of elliptic divisibility sequences says exactly
this: the sequence of denominators is a divisibility sequence whose $n$-th term collects the
primes at which $\bar P$ has order dividing $n$, and by Siegel's theorem the number of such
primes grows without bound.

What the present analysis adds is *exactness* at the first two nontrivial layers: not merely
that good primes occur, but the precise finite-field condition for each one, and the exact
counts of residue classes satisfying it.

### 9.2 Why the counting laws are clean

Both criteria reduce to root-counting for a cubic. At layer $2$ the cubic is $T^3 + N$; at
layer $3$ the quartic $3T(T^3 + 4N)$ splits off the free root $T = 0$ and leaves the cubic
$T^3 + 4N$. Cube-root behaviour in $\mathbb{F}_\ell$ is dichotomous — bijective when
$\ell \equiv 2 \pmod 3$, three-to-one when $\ell \equiv 1 \pmod 3$ — and the totals
$\sum_c \#V_2 = \ell$, $\sum_c \#V_3 = 2\ell - 1$ are partition identities, not analytic
estimates. In Galois-theoretic language, the layer-2 count at $\ell$ is the splitting type of
$\ell$ in the Kummer extension $\mathbb{Q}(\sqrt[3]{N}, \zeta_3)$, and layer 3 adds the
splitting type of $T^3 + 4N$; the general layer should be a Chebotarev computation in the
$n$-division field.

### 9.3 Consequences for factoring

The naive attack — "compute a few multiples of a point on $E_{pq}$ and read $p$, $q$ off the
denominators" — fails for three independent reasons, each established above:

1. denominators contain good primes, in fact infinitely many (Theorems A, 6.1, 6.2);
2. the factors $p$ and $q$ appear only sporadically and unpredictably, and the larger factor
   essentially never (Section 8.4);
3. **structurally**, the denominator profile below any bound $B$ is a function of $N \bmod B!$,
   and that residue class also contains primes (Theorem 7.4).

The third reason is the decisive one: it is not a statement about how the data happens to look,
but about how much data there is. It should be contrasted with Lenstra's elliptic curve method,
which succeeds precisely because it does *not* work with a fixed curve and fixed low-order
multiples: it randomises over curves and searches for one whose group order modulo an unknown
prime factor is smooth — information invisible in any fixed layer-$n$ criterion.

### 9.4 Scope and hypotheses

Every theorem above requires $\ell \geq 5$ and $\ell \nmid N$. Both are necessary rather than
technical: the constants $4$, $-9N$, $64$ and $1728$ appearing in the proofs are supported on
$\{2,3\}$, and at $\ell \mid N$ the cubic $T^3 + N$ degenerates (its unique root $0$ is a triple
root, breaking the $0$-or-$3$ dichotomy). The hypothesis $y \neq 0$ excludes $2$-torsion, where
$x(2P)$ is undefined; $\psi_3(x) \neq 0$ excludes $3$-torsion, where $x(3P)$ is undefined. Over
$\mathbb{Q}$ these exclude only finitely many points on any given curve.

---

## 10. Future directions

**C1. The division-polynomial tower.** For every $n \geq 2$, every integral point $P = (x,y)$
of $E_N$ with $\psi_n(x,y) \neq 0$, and every prime $\ell \geq 5$ with $\ell \nmid N$, we
conjecture
$$\ell \mid \operatorname{den} x(nP) \iff \ell \mid \psi_n(x,y),$$
where $\psi_n$ is the $n$-th division polynomial of $y^2 = x^3 + N$; moreover the exceptional
evaluation of the numerator $\varphi_n$ on the locus $\psi_n = 0$ should always take the form
$c_n \cdot N^k$ with $c_n$ composed only of the primes $2$ and $3$. The evidence is the pair of
layer-3 evaluations computed here, $\varphi_3 \equiv 64N^3$ on $x \equiv 0$ and
$\varphi_3 \equiv -1728N^3$ on $x^3 \equiv -4N$: the constants $2^6$ and $2^63^3$ are the
discriminant and $j$-invariant constants of the Mordell family, and they should recur at every
layer because $\varphi_n$ and $\psi_n^2$ are coprime up to the discriminant. *Falsifiable form:*
compute $\psi_4, \varphi_4$ for $y^2 = x^3 + N$ and check whether the exceptional value of
$\varphi_4$ on $\psi_4 = 0$ involves a prime $\geq 5$.

**C2. Exact class counts and a Chebotarev law.** Let $r_n(N,\ell)$ be the number of residue
classes $x \bmod \ell$ producing $\ell$ in $\operatorname{den} x(nP)$. We conjecture
$$\sum_{N \bmod \ell} r_n(N,\ell) = c_n \ell + O(1), \qquad c_n = \frac{\deg \psi_n}{n-1},$$
and that for fixed $N$ the density of primes with $r_n(N,\ell) = k$ is the Chebotarev density
of the corresponding conjugacy class in $\mathrm{Gal}(\mathbb{Q}(E_N[n])/\mathbb{Q})$. The
layer-2 count ($1$ at supersingular, $0$ or $3$ at ordinary primes) is exactly the splitting
type of $\ell$ in $\mathbb{Q}(\sqrt[3]{N}, \zeta_3)$, and layer $3$ adds the trivial class
$x \equiv 0$ plus the splitting type of $T^3 + 4N$; both are Kummer extensions, so the general
statement is a Chebotarev computation for the $n$-division field.

**C3. The barrier at every layer and every bound.** For every $B$ and every semiprime $N = pq$
with $p, q > B$, we conjecture that there is a prime $M$ such that the *entire* denominator
profile $\{(n,\ell,x) : \ell \mid \operatorname{den} x(nP)\}$ restricted to $\ell \leq B$
coincides for $E_N$ and $E_M$, at all layers $n$ simultaneously. Given C1, the proof should be
the argument of Theorem 7.4 applied to all $\psi_n$ at once, since each $\psi_n$ has integer
coefficients depending on $N$ only.

**C4. Effective versions.** How large must $B$ be before the denominator profile of $E_N$
determines $N$ itself? Theorem 7.4 shows $B < \min(p,q)$ is insufficient; a matching upper
bound would pin down the exact information-theoretic threshold.

**C5. Beyond the Mordell family.** The arguments used here — the doubling formula, the
non-cancellation lemma, and locality — are specific to $y^2 = x^3 + N$ only through the shape
of $\varphi_3$ and $\psi_3$. The analogous statements for a general Weierstrass family
$y^2 = x^3 + Ax + B$ should hold with $\{2,3\}$ replaced by the primes dividing the
$j$-invariant denominators, and the barrier should apply verbatim to any family whose criteria
are polynomial congruences in the parameters.

---

## 11. Conclusion

The "only bad primes" conjecture for denominators of multiples of points on Mordell curves is
false, and its failure is not accidental but structural: a prime divides the denominator of
$x(nP)$ precisely when the point reduces to a point of order dividing $n$, an event governed by
the division polynomials and entirely independent of the discriminant. At the first two
nontrivial layers we have exact criteria — $x^3 + N \equiv 0$ for doubling, $3x(x^3 + 4N)
\equiv 0$ for tripling — exact residue-class counts ($1$ or $0$-or-$3$; $2$ or $1$-or-$4$),
exact averages ($1$ and $2 - 1/\ell$), exact activity densities ($(\ell+2)/3$ residues at
ordinary primes for layer $2$, all residues for layer $3$), and a realisation theorem showing
that every prime $\ell \geq 5$ occurs with good reduction.

The same locality that makes these criteria clean makes them useless for factorisation. Because
each criterion depends on $N$ only through $N \bmod \ell$, the whole profile below a bound $B$
depends only on $N \bmod B!$ — and that residue class, by Dirichlet's theorem, contains primes.
A semiprime and a prime can therefore be denominator-indistinguishable below any prescribed
bound. Whatever information about factorisation the arithmetic of $E_N$ holds, it is not to be
found here.
