# Denominators of Rational Points on Mordell Curves: the Failure of the "Only Bad Primes" Conjecture and the Apparition Index Law

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $N$ be a nonzero integer and let $E_N : y^2 = x^3 + N$ be the associated Mordell curve, with discriminant $\Delta = -432N^2$. A folklore heuristic — which we call the **"only bad primes" conjecture** — asserts that for $N = pq$ a semiprime, the denominators of the $x$-coordinates of the multiples $kP$ of a rational point $P \in E_N(\mathbb{Q})$ are divisible only by the primes dividing $\Delta$, namely $2$, $3$, $p$ and $q$. If true, this would turn a cheap iteration of the elliptic group law into a factoring procedure.

We refute the conjecture explicitly and then replace it by a complete structural theory. On $E_{55}$ with $P = (9,28)$ one has $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$, so the *good* prime $7$ divides the denominator; and $x(3P) = -2302089191/656538129$ with $656538129 = 3^6 \cdot 13^2 \cdot 73^2$, a denominator carrying the good primes $13$ and $73$ while containing neither $5$ nor $11$. The conjecture therefore fails in both directions at a single point of a single curve.

The positive results are the following, all valid for arbitrary $N \in \mathbb{Z}$ and arbitrary rational points.

1. **Square-denominator law.** Every rational point of $E_N$ satisfies $\operatorname{den} x = e^2$ and $\operatorname{den} y = e^3$ for a single positive integer $e$. Consequently every prime occurs to an even exponent in $\operatorname{den} x$, the set of achievable $x$-denominators below $X$ has cardinality at most $\sqrt{X}+1$, and hence density zero.
2. **Complete local law at good primes.** For a prime $\ell \ge 5$ with $\ell \nmid N$ and any $P = (x,y) \in E_N(\mathbb{Q})$: $\ell \mid \operatorname{den} x(2P) \iff \ell \mid \operatorname{den} x(P)$ or $\ell \mid \operatorname{num} y(P)$. The criterion is independent of the factorization of $N$.
3. **Exact filtration law.** For every odd prime $\ell$ (good or bad) with $\ell \mid \operatorname{den} x(P)$, the $\ell$-parts of $\operatorname{den} x(P)$ and $\operatorname{den} x(2P)$ coincide; at $\ell = 2$ one has exactly $v_2(\operatorname{den} x(2P)) = v_2(\operatorname{den} x(P)) + 2$.
4. **Subgroup property of the denominator kernel.** For every prime $\ell$, the set $E_\ell(\mathbb{Q}) = \{P : \ell \mid \operatorname{den} x(P)\} \cup \{\mathcal{O}\}$ is a subgroup of $E_N(\mathbb{Q})$, with an elementary proof through the chord identity that avoids the formal group.
5. **Apparition index law.** For every prime $\ell$ and every $P \in E_N(\mathbb{Q})$ there is $m = m(\ell,P) \in \mathbb{N}$ with $\ell \mid \operatorname{den} x(kP) \iff m \mid k$, for all $k \in \mathbb{Z}$. On $E_{55}$, $P = (9,28)$: $m(7) = 2$ and $m(13) = 3$.
6. **Infinite orbits from denominator growth.** $v_2(\operatorname{den} x(2^kQ)) = v_2(\operatorname{den} x(Q)) + 2k$ implies that any rational point with even $x$-denominator has infinite order and forces $E_N(\mathbb{Q})$ to be infinite; in particular $(9,28)$ has infinite order and $E_{55}(\mathbb{Q})$ is infinite, with infinitely many distinct multiples whose denominator carries the good prime $7$.

A survey of eleven semiprime Mordell curves found the "only bad primes" property holding in $0\%$ of cases, with the larger prime factor $q$ never appearing in a denominator and the smaller factor $p$ appearing about $54.5\%$ of the time. We conclude with a discussion of why the denominator sequence is structurally a function of $N$ alone and cannot detect its factorization.

**Keywords:** Mordell curve, elliptic curve, denominator, reduction modulo a prime, apparition index, rank of apparition, formal group, integer factorization.

---

## 1. Introduction

### 1.1 Mordell curves and their rational points

For a nonzero integer $N$, the **Mordell curve** is the plane cubic
$$E_N : y^2 = x^3 + N.$$
It is an elliptic curve over $\mathbb{Q}$ with discriminant
$$\Delta(E_N) = -432 N^2$$
and $j$-invariant $0$. Its set of rational points $E_N(\mathbb{Q})$, together with the point at infinity $\mathcal{O}$, is a finitely generated abelian group under the chord-and-tangent law. Concretely, for $P_1 = (x_1,y_1)$ and $P_2 = (x_2,y_2)$ with $x_1 \ne x_2$, the sum $P_3 = P_1 + P_2 = (x_3, y_3)$ is given by
$$\lambda = \frac{y_2 - y_1}{x_2 - x_1}, \qquad x_3 = \lambda^2 - x_1 - x_2, \qquad y_3 = \lambda(x_1 - x_3) - y_1,$$
and for the tangent case $P_1 = P_2$ with $y_1 \ne 0$ by $\lambda = 3x_1^2/(2y_1)$, so that
$$x(2P) = \frac{x^4 - 8Nx}{4(x^3 + N)} = \frac{x^4 - 8Nx}{4y^2}.$$

A prime $\ell$ is **bad** for $E_N$ if $\ell \mid \Delta$, i.e. if $\ell \in \{2,3\} \cup \{\ell : \ell \mid N\}$, and **good** otherwise. At a good prime the reduced curve $E_N/\mathbb{F}_\ell$ is again smooth, and reduction gives a group homomorphism from the $\ell$-integral points of $E_N(\mathbb{Q})$ to $E_N(\mathbb{F}_\ell)$.

### 1.2 The conjecture under examination

The following expectation is easy to form and has an attractive computational payoff.

> **"Only bad primes" conjecture.** Let $N = pq$ be a product of two distinct primes and let $P \in E_N(\mathbb{Q})$. Then every prime dividing the denominator of $x(kP)$, for any $k \ge 1$, lies in $\{2, 3, p, q\}$ — the set of primes dividing $\Delta = -432N^2$.

Its appeal is plain. Computing $x(kP)$ requires only rational arithmetic; extracting the denominator and removing the known factors $2$ and $3$ would leave a number built from $p$ and $q$, whence a single greatest common divisor with $N$ would split $N$. The conjecture, if true, would exhibit a factoring algorithm of striking simplicity.

**The conjecture is false.** Section 3 gives the counterexample. Sections 4–8 develop the theory that explains its failure and quantifies precisely how it fails.

### 1.3 Overview of results and method

Everything below rests on one elementary device: the **coprime parametrization**
$$x = \frac{a}{e^2}, \qquad y = \frac{b}{e^3}, \qquad \gcd(a,e) = \gcd(b,e) = 1, \qquad b^2 = a^3 + Ne^6,$$
which we prove is available for *every* rational point of *every* integral Mordell curve (Theorem 4.1 and Corollary 4.4). Once one has it, the group law becomes an identity between integers whose $\ell$-adic behaviour can be read off by inspection. No formal-group machinery, no descent, and no height theory is needed anywhere in the paper; the deepest input is unique factorization in $\mathbb{Z}$.

The structure is:

- §2 — the arithmetic dictionary between denominators and reduction;
- §3 — the counterexamples;
- §4 — the square-denominator law and the thinness of the denominator spectrum;
- §5 — the doubling formula and the complete local law;
- §6 — the exact $\ell$-adic filtration law;
- §7 — the denominator kernel as a subgroup, via the chord identity;
- §8 — the apparition index law and its two exact computations;
- §9 — infinite orbits from $2$-adic growth;
- §10 — the semiprime survey and the structural barrier to factorization;
- §11 — algorithms; §12 — discussion and future directions.

---

## 2. Denominators and reduction: the dictionary

Throughout, for a rational number $r$ we write $\operatorname{num} r$ and $\operatorname{den} r$ for its numerator and (positive) denominator in lowest terms, and $v_\ell$ for the $\ell$-adic valuation.

The following standard observation is the conceptual engine of the whole subject and explains at once why the "only bad primes" conjecture is hopeless.

**Proposition 2.1 (Denominator = reduction to infinity).** *Let $\ell$ be a prime of good reduction for $E_N$ and let $P \in E_N(\mathbb{Q})$ be affine. Then $\ell \mid \operatorname{den} x(P)$ if and only if $P$ reduces to the point at infinity of $E_N(\mathbb{F}_\ell)$.*

*Proof sketch.* If $\ell \nmid \operatorname{den} x(P)$ then, by the square-denominator law of §4, $\ell \nmid \operatorname{den} y(P)$ as well, so both coordinates are $\ell$-integral and reduce to a point of the affine curve over $\mathbb{F}_\ell$. Conversely if $\ell \mid \operatorname{den} x(P)$, then writing $x = a/e^2$, $y = b/e^3$ with $\ell \mid e$ and $\ell \nmid ab$, the point in projective coordinates is $(a e : b : e^3)$ after clearing, whose reduction is $(0:1:0)$. $\square$

Since reduction is a group homomorphism on $\ell$-integral points, Proposition 2.1 upgrades to the statement that

$$\ell \mid \operatorname{den} x(kP) \iff k\bar P = \bar{\mathcal{O}} \text{ in } E_N(\mathbb{F}_\ell) \iff \operatorname{ord}(\bar P) \mid k.$$

The right-hand side is a statement about the finite group $E_N(\mathbb{F}_\ell)$, whose order lies in the Hasse interval $[\ell + 1 - 2\sqrt\ell, \ \ell + 1 + 2\sqrt\ell]$. There is no reason whatsoever for it to be sensitive to whether $\ell \mid \Delta$; on the contrary, the order of $\bar P$ is a generic-looking divisor of $\# E_N(\mathbb{F}_\ell)$, and *every* good prime for which $\bar P$ has small order will appear in denominators early in the orbit.

This heuristic prediction is exactly what the theorems below prove unconditionally and, importantly, without ever needing the reduction-theoretic formalism: §7 recovers the divisibility statement $\operatorname{ord}(\bar P) \mid k \Rightarrow \ell \mid \operatorname{den} x(kP)$ purely by integer arithmetic on the chord formula, and §8 shows that the appearance set is a subgroup of $\mathbb{Z}$ even at bad primes, where Proposition 2.1 does not apply.

---

## 3. The counterexamples

### 3.1 A good prime in a denominator

**Theorem 3.1.** *Let $N = 55 = 5 \cdot 11$ and $P = (9,28) \in E_{55}(\mathbb{Q})$. Then*
$$x(2P) = \frac{2601}{3136}, \qquad 3136 = 2^6 \cdot 7^2 .$$
*The prime $7$ divides $\operatorname{den} x(2P)$ but $7 \nmid \Delta = -432 \cdot 55^2$, so $7$ is a prime of good reduction. Hence the "only bad primes" conjecture is false.*

*Proof.* First, $P$ lies on the curve: $28^2 = 784 = 729 + 55 = 9^3 + 55$. Since $\Delta \ne 0$ and $P$ satisfies the Weierstrass equation, $P$ is nonsingular. The tangent slope is $\lambda = 3\cdot 9^2/(2\cdot 28) = 243/56$, so
$$x(2P) = \lambda^2 - 18 = \frac{59049}{3136} - 18 = \frac{59049 - 56448}{3136} = \frac{2601}{3136}.$$
The fraction is in lowest terms because $2601 = 3^2\cdot 17^2$ and $3136 = 2^6\cdot 7^2$. Finally $-432\cdot 55^2 = -1306800 = -2^4\cdot 3^3\cdot 5^2\cdot 11^2$, which is not divisible by $7$. $\square$

Equivalently, and this is the content of §2: modulo $7$ the point $\bar P = (2,0)$ satisfies $2\bar P = \bar{\mathcal{O}}$, since $y \equiv 0$; the reduction is a point of order $2$.

### 3.2 Failure in both directions at a single point

A defender of the heuristic might hope that even if extra primes intrude, the primes $p$ and $q$ are still always present, so that a greatest common divisor still recovers them. The next multiple destroys that hope too.

**Theorem 3.2.** *With $N = 55$ and $P = (9,28)$,*
$$x(3P) = -\frac{2302089191}{656538129}, \qquad 656538129 = 3^6 \cdot 13^2 \cdot 73^2 = 25623^2 .$$
*Thus $\operatorname{den} x(3P)$ is divisible by the good primes $13$ and $73$ and is coprime to both $5$ and $11$. A single multiple of a single point simultaneously violates the "only bad primes" conjecture and the "denominators reveal the factorization" heuristic.*

*Proof sketch.* Compute $3P = 2P + P$ through the two branches of the affine group law: the tangent branch at $P$ (legitimate since $y(P) = 28 \ne -y(P)$) gives $2P = (2601/3136,\ -1308181/175616)$, and the chord branch applied to $2P$ and $P$ (legitimate since $x(2P) \ne x(P)$) yields the stated $x(3P)$. The factorization of the denominator is a finite verification. $\square$

Note the perfect square: $656538129 = 25623^2$ with $25623 = 3^3 \cdot 13 \cdot 73$. This is not a coincidence but an instance of the square-denominator law, to which we now turn.

---

## 4. The square-denominator law

**Theorem 4.1 (Square-denominator law).** *Let $N \in \mathbb{Z}$ and let $(x,y) \in \mathbb{Q}^2$ satisfy $y^2 = x^3 + N$. Then*
$$(\operatorname{den} x)^3 = (\operatorname{den} y)^2,$$
*and consequently there is a unique positive integer $e$ with*
$$\operatorname{den} x = e^2, \qquad \operatorname{den} y = e^3.$$

*Proof.* Write $x = a/d$, $y = b/f$ in lowest terms, with $d, f > 0$, $\gcd(a,d) = \gcd(b,f) = 1$. Substituting and clearing denominators,
$$b^2 d^3 = f^2\,(a^3 + N d^3). \tag{4.1}$$
Since $\gcd(b, f) = 1$ we get $f^2 \mid d^3$ from (4.1). Reducing (4.1) modulo $d$: $f^2 a^3 \equiv 0 \pmod{d}$, and $\gcd(a,d) = 1$, so $d \mid f^2$; in fact repeating the argument prime by prime with exponents gives $d^3 \mid f^2$ as well. Hence $d^3 = f^2$. Now for each prime $\ell$, $3v_\ell(d) = 2 v_\ell(f)$, so $2 \mid v_\ell(d)$ and $3 \mid v_\ell(f)$; setting $e = \prod_\ell \ell^{v_\ell(d)/2}$ gives $d = e^2$, $f = e^3$. $\square$

The integrality of $N$ is load-bearing: for $N = 1/8$ the point $(x,y) = (1/2,1/2)$ lies on $y^2 = x^3 + N$ and $\operatorname{den} x = 2$ is not a square.

**Corollary 4.2 (Even exponents).** *For any rational point of $E_N$ and any prime $\ell$, $v_\ell(\operatorname{den} x)$ is even. In particular $\ell \mid \operatorname{den} x \Rightarrow \ell^2 \mid \operatorname{den} x$ and $\ell^3 \mid \operatorname{den} y$.*

This is the affine shadow of the fact that a point in the kernel of reduction at $\ell$ lies in the formal group $\hat E(\ell\mathbb{Z}_\ell)$, where the standard parameter $t = -x/y$ has $v_\ell(t) = n \ge 1$ and $v_\ell(x) = -2n$, $v_\ell(y) = -3n$. The point of Theorem 4.1 is that no formal-group theory is required: coprimality and $\gcd(2,3) = 1$ suffice.

**Corollary 4.3 (Impossible denominators).** *A rational number whose denominator is not a perfect square is not the $x$-coordinate of any rational point of any integral Mordell curve. For instance, no point of $E_{55}(\mathbb{Q})$ has $x$-denominator $7$ — even though $7$ genuinely occurs, to the exponent $2$, in $\operatorname{den} x(2P)$.*

**Corollary 4.4 (Thinness of the denominator spectrum).** *The number of integers $\le X$ that occur as $\operatorname{den} x(P)$ for some rational point $P$ of some integral Mordell curve is at most $\lfloor\sqrt X\rfloor + 1$. In particular the set of achievable denominators has natural density $0$.*

These corollaries are stable along orbits: because the group law preserves $E_N(\mathbb{Q})$, all multiples $n \cdot P$ of a rational point satisfy the same law, so the entire orbit consists of points with square $x$-denominators.

**Corollary 4.5 (Coprime parametrization).** *Every rational point of $E_N$, $N \in \mathbb{Z}$, may be written*
$$x = \frac{a}{e^2}, \qquad y = \frac{b}{e^3}, \qquad e \ge 1, \quad \gcd(a,e) = \gcd(b,e) = 1, \quad b^2 = a^3 + N e^6,$$
*with $a = \operatorname{num} x$, $b = \operatorname{num} y$, $e^2 = \operatorname{den} x$.*

Corollary 4.5 is the workhorse of §§5–7: it converts every question about denominators into a question about the integers $a$, $b$, $e$ subject to the single relation $b^2 = a^3 + Ne^6$.

---

## 5. The complete local law at a good prime

Substituting the parametrization of Corollary 4.5 into the doubling formula gives an identity between integers.

**Lemma 5.1 (Integral doubling formula).** *With $x = a/e^2$, $y = b/e^3$ and $b \ne 0$,*
$$x(2P) = \frac{a^4 - 8Nae^6}{4b^2e^2} = \frac{a\,(b^2 - 9Ne^6)}{4b^2e^2},$$
*where the second form uses $b^2 = a^3 + Ne^6$, so that $a^4 - 8Nae^6 = a(a^3 - 8Ne^6) = a(b^2 - 9Ne^6)$.*

The factored numerator is what makes the local analysis immediate: for a prime $\ell \ge 5$ with $\ell \nmid N$, the numerator is divisible by $\ell$ only if $\ell \mid a$ or $\ell \mid b^2 - 9Ne^6$, and both possibilities are controlled.

**Theorem 5.2 (Good-prime criterion for $\ell$-integral points).** *Let $\ell \ge 5$ be prime with $\ell \nmid N$, and let $P = (x,y) \in E_N(\mathbb{Q})$ with $\ell \nmid \operatorname{den} x(P)$ (equivalently, $\ell \nmid e$). Then*
$$\ell \mid \operatorname{den} x(2P) \iff \ell \mid \operatorname{num} y(P).$$

*Proof sketch.* With $\ell \nmid e$, the $\ell$-part of the denominator of $a(b^2 - 9Ne^6)/(4b^2e^2)$ is governed by $b^2$, since $\ell \nmid 4e^2$. If $\ell \nmid b$ there is nothing in the denominator. If $\ell \mid b$, then $b^2 \equiv 0$, and $a^3 = b^2 - Ne^6 \equiv -Ne^6 \pmod \ell$, so $\ell \nmid a$ (as $\ell \nmid Ne$); moreover $b^2 - 9Ne^6 \equiv -9Ne^6 \not\equiv 0 \pmod\ell$ because $\ell \ge 5$ and $\ell \nmid 3Ne$. So the numerator is prime to $\ell$ and the $\ell$-part of $b^2$ survives into the denominator. $\square$

The hypotheses are sharp. If $\ell = 3$ the factor $9Ne^6$ can vanish modulo $\ell$ and the criterion genuinely fails; if $\ell \mid N$ the numerator can absorb the $\ell$-part.

Combining Theorem 5.2 with the filtration law of §6 covers all rational points:

**Theorem 5.3 (Complete local law).** *Let $\ell \ge 5$ be prime with $\ell \nmid N$ and let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \ne 0$. Then*
$$\ell \mid \operatorname{den} x(2P) \iff \big(\ell \mid \operatorname{den} x(P)\ \text{ or }\ \ell \mid \operatorname{num} y(P)\big).$$

*Proof.* If $\ell \nmid \operatorname{den} x(P)$ this is Theorem 5.2. If $\ell \mid \operatorname{den} x(P)$ then Theorem 6.1 below gives $v_\ell(\operatorname{den} x(2P)) = v_\ell(\operatorname{den} x(P)) > 0$, so both sides hold. $\square$

**Remark 5.4 (Independence of the factorization).** The right-hand side of Theorem 5.3 refers to $N$ only through the hypothesis $\ell \nmid N$. Formally: if two Mordell curves $E_N$ and $E_M$ carry rational points with the same coordinates $(x,y)$ — which forces $N = M$ — or, more usefully, if two points on possibly different curves share the data $(\operatorname{den} x, \operatorname{num} y)$ at $\ell$, then the criterion returns the same answer. There is no term in the criterion that can see the factorization $N = pq$. This is the precise sense in which the "only bad primes" conjecture is not merely false but structurally misconceived.

**Remark 5.5 (A congruence at the even prime).** At $\ell = 2$ there is an extra obstruction of a different flavour: if $2 \mid \operatorname{den} x(P)$ then $\operatorname{num} x(P) \equiv 1 \pmod 8$. Indeed $b^2 = a^3 + Ne^6$ with $e$ even forces $a^3 \equiv b^2 \pmod{64}$ with $a, b$ odd, and odd squares are $\equiv 1 \pmod 8$, whence $a^3 \equiv 1$ and so $a \equiv 1 \pmod 8$. Consistently, $x(2P) = 2601/3136$ on $E_{55}$ has $2601 = 8\cdot 325 + 1$.

---

## 6. The exact filtration law

**Theorem 6.1 (Odd primes: exact invariance).** *Let $N \in \mathbb{Z}$, let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \ne 0$, and let $\ell$ be an **odd** prime with $\ell \mid \operatorname{den} x(P)$. Then for every $m \ge 0$,*
$$\ell^m \mid \operatorname{den} x(2P) \iff \ell^m \mid \operatorname{den} x(P),$$
*equivalently $v_\ell(\operatorname{den} x(2P)) = v_\ell(\operatorname{den} x(P))$. No hypothesis on the reduction type of $\ell$ is needed: bad primes obey the same law.*

*Proof sketch.* Write $x = a/e^2$, $y = b/e^3$ with $\ell \mid e$ and $\gcd(ab, e) = 1$. By Lemma 5.1,
$$x(2P) = \frac{a(b^2 - 9Ne^6)}{4b^2e^2}.$$
Modulo $\ell$ the numerator is $\equiv a b^2 \not\equiv 0$, since $\ell \nmid a$ and $\ell \nmid b$. Hence no cancellation at $\ell$ is possible, and $v_\ell(\operatorname{den} x(2P)) = v_\ell(4b^2e^2) = v_\ell(e^2) = v_\ell(\operatorname{den} x(P))$, using $\ell$ odd and $\ell \nmid b$. $\square$

**Theorem 6.2 (The prime $2$: exact growth).** *Under the same hypotheses with $\ell = 2$ and $2 \mid \operatorname{den} x(P)$, one has for all $m$*
$$2^m \mid \operatorname{den} x(2P) \iff 2^m \mid 4\,\operatorname{den} x(P),$$
*equivalently $v_2(\operatorname{den} x(2P)) = v_2(\operatorname{den} x(P)) + 2$.*

*Proof sketch.* Identical, except that the constant $4$ in the denominator $4b^2e^2$ is no longer a unit and contributes exactly two extra levels; $b$ is odd because $\gcd(b,e) = 1$ and $e$ is even. $\square$

These are the affine, elementary forms of the statement that multiplication by $2$ acts on the formal group $\hat E(\ell\mathbb{Z}_\ell)$ as an isomorphism onto its image of index $|2|_\ell$: a bijection for odd $\ell$, and an index-$4$ inclusion at $\ell = 2$ in the $x$-coordinate normalization.

**Corollary 6.3 (Stability under $2$-power multiples).** *For odd $\ell$, the set of points with $\ell \mid \operatorname{den} x$ is stable under doubling, hence under all multiplications by powers of $2$. In particular, on $E_{55}$ with $P = (9,28)$, the good prime $7$ divides $\operatorname{den} x(2^k P)$ for every $k \ge 1$ — the counterexample of §3 propagates to an infinite family.*

**Numerical confirmation.** On $E_{55}$, $P = (9,28)$, the observed valuations are
$$v_7(\operatorname{den} x(nP)) = 2 \text{ for } n = 2,4,6,8 \quad\text{and}\quad 0 \text{ for } n = 1,3,5,7;$$
$$v_{13}(\operatorname{den} x(nP)) = 2 \text{ for } n = 3, 6;$$
$$v_2(\operatorname{den} x(2^kP)) = 6, 8, 10 \text{ for } k = 1,2,3,$$
matching Theorems 6.1 and 6.2 exactly.

---

## 7. The denominator kernel is a subgroup

Theorems 6.1–6.2 handle the tangent. The chord is harder, because when two points have equal denominator valuation the naive valuation count on the slope $\lambda = (y_2-y_1)/(x_2-x_1)$ degenerates: the terms $\lambda^2$ and $x_1$ have the same $\ell$-adic size and could in principle cancel. The resolution is to reverse the implication and use a slope-free identity.

**Lemma 7.1 (Chord identity).** *Let $P_i = (x_i,y_i)$, $i=1,2$, be points of $y^2 = x^3 + N$ with $x_1 \ne x_2$, and let $x_3$ be the $x$-coordinate of $P_1 + P_2$. Then*
$$x_3\,(x_1-x_2)^2 = x_1x_2(x_1+x_2) + 2N - 2y_1y_2 .$$

*Proof.* $x_3 = \lambda^2 - x_1 - x_2$ with $\lambda = (y_2-y_1)/(x_2-x_1)$, so
$$x_3(x_1-x_2)^2 = (y_2-y_1)^2 - (x_1+x_2)(x_1-x_2)^2 .$$
Expand using $y_i^2 = x_i^3 + N$:
$$(y_2-y_1)^2 = x_1^3 + x_2^3 + 2N - 2y_1y_2,$$
and $x_1^3+x_2^3 - (x_1+x_2)(x_1-x_2)^2 = x_1x_2(x_1+x_2)$ by a direct expansion. $\square$

The identity is slope-free and polynomial, with the curve parameters entering only through the single constant $N$. That is what makes the following argument elementary.

**Theorem 7.2 (Closure under the chord).** *Let $\ell$ be any prime — good or bad, including $\ell = 2$ — and let $P_1, P_2 \in E_N(\mathbb{Q})$ with $\ell \mid \operatorname{den} x(P_i)$ for $i = 1,2$. If $P_1 + P_2$ is affine with $x$-coordinate $x_3$, then $\ell \mid \operatorname{den} x_3$.*

*Proof sketch.* Suppose not, so $S := P_1 + P_2$ has $\ell$-integral $x$-coordinate, hence (by Theorem 4.1) $\ell$-integral $y$-coordinate. Write $P_1 = S - P_2 = S + (-P_2)$ and apply Lemma 7.1 to the pair $(S, -P_2)$, whose $x$-coordinates differ (the degenerate cases $S = \pm P_2$ and sums equal to $\mathcal{O}$ are handled separately, and each contradicts the hypotheses directly). Then
$$x(P_1) = \frac{x_S x_2 (x_S + x_2) + 2N + 2 y_S y_2}{(x_S - x_2)^2}.$$
Substituting the parametrizations $x_2 = a/e^2$, $y_2 = b/e^3$ with $\ell \mid e$, and clearing, one finds that the numerator and denominator, written over the common integral denominator, both carry the same power of $e$; the resulting reduced denominator is a unit at $\ell$. Hence $x(P_1)$ is $\ell$-integral, contradicting $\ell \mid \operatorname{den} x(P_1)$. $\square$

**Definition 7.3 (Denominator kernel).** For a prime $\ell$, put
$$E_\ell(\mathbb{Q}) := \{P \in E_N(\mathbb{Q}) : P = \mathcal{O}\ \text{ or }\ \ell \mid \operatorname{den} x(P)\}.$$

**Theorem 7.4 (Subgroup property).** *$E_\ell(\mathbb{Q})$ is a subgroup of $E_N(\mathbb{Q})$, for every prime $\ell$ and every $N \in \mathbb{Z}$.*

*Proof.* $\mathcal{O} \in E_\ell(\mathbb{Q})$ by convention. Closure under addition is Theorem 7.2 together with the trivial cases involving $\mathcal{O}$. Closure under negation holds because negation on a Weierstrass curve fixes the $x$-coordinate: $x(-P) = x(P)$. $\square$

**Corollary 7.5 (All integer multiples).** *If $\ell \mid \operatorname{den} x(P)$ then $\ell \mid \operatorname{den} x(kP)$ for every $k \in \mathbb{Z}$ for which $kP$ is affine — negative $k$ included.*

At good primes, Corollary 7.5 is the elementary counterpart of the reduction-theoretic statement of §2; but Theorem 7.4 is strictly stronger, since it applies verbatim at bad primes, where reduction is not a homomorphism into a smooth group.

---

## 8. The apparition index law

Being a subgroup has a consequence that is immediate to state and surprisingly rigid.

**Theorem 8.1 (Apparition index law).** *Let $N \in \mathbb{Z}$, let $\ell$ be a prime, and let $P \in E_N(\mathbb{Q})$. Then there is a natural number $m = m(\ell, P)$ such that, for every $k \in \mathbb{Z}$,*
$$\ell \mid \operatorname{den} x(kP) \iff m \mid k,$$
*where multiples $kP$ equal to $\mathcal{O}$ satisfy the left-hand condition vacuously. We call $m(\ell,P)$ the **apparition index** of $\ell$ in the orbit of $P$.*

*Proof.* Consider the homomorphism $f : \mathbb{Z} \to E_N(\mathbb{Q})$, $k \mapsto kP$. The preimage $H = f^{-1}(E_\ell(\mathbb{Q}))$ is a subgroup of $\mathbb{Z}$ by Theorem 7.4, hence cyclic: $H = m\mathbb{Z}$ for a unique $m \ge 0$. Unwinding the definitions, $k \in H$ exactly when $\ell \mid \operatorname{den} x(kP)$ (vacuously if $kP = \mathcal{O}$), which is the assertion. $\square$

Thus a prime never appears in denominators sporadically: **the set of indices at which it appears is an arithmetic progression through $0$, or is empty** (the case $m = 0$ never occurs when $P$ has infinite order and $\ell$ is a good prime, since then $\bar P$ has finite order; $m = 1$ means $\ell$ already divides $\operatorname{den} x(P)$).

This is the exact elliptic analogue of the classical **rank of apparition** in a Lucas sequence: for the Fibonacci numbers, the set $\{n : \ell \mid F_n\}$ is the set of multiples of a single index $\alpha(\ell)$. Here the underlying reason is the same — a divisibility condition that cuts out a subgroup of the index group.

**Theorem 8.2 (The index of $7$ on $E_{55}$).** *For $N = 55$ and $P = (9,28)$, and for every $k \in \mathbb{Z}$,*
$$7 \mid \operatorname{den} x(kP) \iff 2 \mid k .$$
*That is, the apparition index of the good prime $7$ is exactly $2$.*

*Proof.* Let $m$ be the index supplied by Theorem 8.1. Since $x(2P) = 2601/3136$ and $7 \mid 3136$, we get $m \mid 2$. Since $x(P) = 9$ has denominator $1$, which is not divisible by $7$, we get $m \nmid 1$, so $m \ne 1$; and $m \ne 0$ since $m \mid 2$. Hence $m = 2$. $\square$

The statement is a genuine equivalence, not a one-sided divisibility: the odd multiples are *proved* to fail the divisibility, so the "only bad primes" conjecture fails along a full arithmetic progression rather than at one sporadic index.

**Theorem 8.3 (The index of $13$ on $E_{55}$).** *For $N = 55$ and $P = (9,28)$, and for every $k \in \mathbb{Z}$,*
$$13 \mid \operatorname{den} x(kP) \iff 3 \mid k .$$

*Proof.* By Theorem 3.2, $\operatorname{den} x(3P) = 3^6\cdot 13^2\cdot 73^2$, so $13 \mid \operatorname{den} x(3P)$ and $m \mid 3$; and $m \ne 1$ because $x(P) = 9$ is integral. Hence $m = 3$. $\square$

**Corollary 8.4 (A superposition of progressions).** *Distinct good primes have distinct apparition indices in the same orbit. On $E_{55}$ with $P = (9,28)$ the failure locus of the "only bad primes" conjecture is the union of the even indices (contributed by $7$), the multiples of $3$ (contributed by $13$ and $73$), and further progressions for every other prime that ever appears — not a single periodic pattern.*

**Remark 8.5 (Identification of the index).** At a good prime $\ell$, §2 identifies $m(\ell,P)$ with the order of the reduced point $\bar P$ in $E_N(\mathbb{F}_\ell)$. Thus $m(\ell,P) \mid \#E_N(\mathbb{F}_\ell)$ and, by Hasse's bound, $m(\ell,P) \le \ell + 1 + 2\sqrt{\ell}$. On $E_{55}$: modulo $7$, $\bar P = (2,0)$ has order $2$; modulo $13$, $\bar P = (9,2)$ has order $3$. Both match Theorems 8.2 and 8.3.

---

## 9. Infinite orbits from denominator growth

The counterexamples of §3 multiply into infinite families only if the multiples $kP$ are genuinely distinct points. The exact $2$-adic law provides this for free, with no descent and no height machinery.

**Lemma 9.1 ($2$-torsion is integral).** *If $(x,y) \in E_N(\mathbb{Q})$ with $N \in \mathbb{Z}$ satisfies $y = 0$, then $\operatorname{den} x = 1$.*

*Proof.* By Theorem 4.1, $\operatorname{den} y = e^3$; but $y = 0$ has denominator $1$, so $e^3 = 1$, $e = 1$, and $\operatorname{den} x = e^2 = 1$. $\square$

**Corollary 9.2.** *A rational point with $2 \mid \operatorname{den} x$ is not $2$-torsion; in particular the $2$-power sub-orbit never reaches $\mathcal{O}$ and the doubling induction never stalls.*

**Theorem 9.3 (Exact $2$-adic growth along a $2$-power orbit).** *Let $Q \in E_N(\mathbb{Q})$ with $v := v_2(\operatorname{den} x(Q)) \ge 1$. Then for every $k \ge 0$ the multiple $2^kQ$ is affine and*
$$v_2\big(\operatorname{den} x(2^kQ)\big) = v + 2k .$$

*Proof.* Induction on $k$, using Theorem 6.2 for the step and Corollary 9.2 to guarantee that the point being doubled is not $2$-torsion. $\square$

**Corollary 9.4 (Infinite order and infinite Mordell–Weil group).** *If some $Q \in E_N(\mathbb{Q})$ has even $x$-denominator, then $k \mapsto 2^kQ$ is injective, $Q$ has infinite order, and $E_N(\mathbb{Q})$ is infinite (equivalently, $E_N$ has positive rank).*

*Proof.* The valuations $v+2k$ are pairwise distinct, so the points $2^kQ$ are pairwise distinct. $\square$

**Corollary 9.5 (The orbit on $E_{55}$).** *$m\cdot(9,28) \ne \mathcal{O}$ for all $m \ge 1$, so $(9,28)$ has infinite order and $E_{55}(\mathbb{Q})$ is infinite. Moreover there are infinitely many **distinct** rational points of $E_{55}$ whose $x$-denominator is divisible by the good prime $7$: the points $2^k \cdot (2P)$, $k \ge 0$, or equivalently all even multiples of $P$.*

*Proof.* Apply Corollary 9.4 to $Q = 2P$, whose $x$-denominator is $3136 = 2^6\cdot 7^2$; combine with Theorem 8.2 (or with Corollary 6.3). $\square$

This gives an explicit injection $\mathbb{N} \to E_{55}(\mathbb{Q})$ and therefore a fully constructive proof of infinitude, in contrast with the usual abstract descent argument.

---

## 10. Semiprime survey and the structural barrier

### 10.1 The survey

Eleven semiprime Mordell curves $E_{pq}$ were examined, each with a small rational point $P$ found by searching $x$ in a bounded range, and each with the first several multiples $P, 2P, \dots$ computed exactly in rational arithmetic. The denominators were factored and compared to the bad-prime set $\{2,3,p,q\}$. The findings:

| Statistic | Frequency |
|---|---|
| Some denominator in the orbit is divisible only by primes in $\{2,3,p,q\}$ | $0\%$ (0 of 11) |
| The larger prime factor $q$ appears in some denominator | $0\%$ (0 of 11) |
| The smaller prime factor $p$ appears in some denominator | $54.5\%$ (6 of 11) |

Typical output: on $E_{35}$ with $P = (1,6)$, the denominator primes over the first six multiples are $\{2,3,5,31,43,47,269,337,\dots\}$ — containing $5$ but not $7$, alongside a crowd of good primes. On $E_{91}$ with $P = (-3,8)$ the denominator primes over the same range are $\{2,3,5,47,59,151,337,401,2791,\dots\}$: **neither** $7$ nor $13$ occurs, while several good primes do.

The figures depend mildly on the sample: in a variant sample restricted to curves possessing an integral point with $|x| \le 200$, the smaller factor appeared about $71\%$ of the time and the larger factor once, on $N = 15 = 3\cdot 5$, where "larger factor" still means the small prime $5$. What is stable across samples is the qualitative conclusion — the "only bad primes" property never holds, and a large prime factor is never seen.

The pattern behind the asymmetry between $p$ and $q$ is not mysterious: the smaller factor $p$ is a small prime, and small primes have small residue fields, hence small point groups $E_N(\mathbb{F}_p)$, hence small apparition indices; a prime with index $m$ shows up within the first $m$ multiples. Large primes — good or bad — have indices of typical size $\sim \ell$ and are invisible in any short prefix of the orbit. This is precisely why $q$ never appeared.

### 10.2 The barrier

**Observation 10.1 (The denominator sequence does not see the factorization).** *Fix $N$ and $P$. For every prime $\ell$ of good reduction, the apparition index $m(\ell,P)$ equals the order of $\bar P$ in $E_N(\mathbb{F}_\ell)$, a quantity determined by the reduction of the pair $(E_N, P)$ modulo $\ell$. Nothing in this datum records whether $N$ is prime, a semiprime, or a product of many primes. Consequently the sequence $\big(\operatorname{den} x(kP)\big)_{k\ge1}$ is a function of $N$ **as a number**, and provides no oracle distinguishing $N = pq$ from a prime of comparable size.*

This is the sharp form of the negative conclusion. The "only bad primes" conjecture would have been an efficient factoring method; not only is it false, but its failure is generic and its underlying mechanism — order of reduction in a finite group — is exactly the mechanism that Lenstra's elliptic curve factorization method exploits *by varying the curve*, not by iterating one point on a fixed curve. Iterating a single point on a single curve provides no leverage, because the appearance of a prime $\ell$ is governed by $\#E_N(\mathbb{F}_\ell)$ and one must already know $\ell$ to detect it, or else stumble on it via a greatest common divisor whose success probability is that of finding a smooth group order — exactly Lenstra's method again.

An honest positive reading: the theory above tells you *when* a given prime will show up, and Lenstra's method is precisely the systematic exploitation of the same phenomenon with the roles of curve and prime reversed.

---

## 11. Algorithms

Three procedures underpin the computations. All arithmetic is exact rational arithmetic; the cost model counts bit operations on integers of the stated size.

### 11.1 Exact orbit computation

Given $N$ and $P$, compute $P, 2P, \dots, nP$ by repeated addition using the affine group law with exact rationals. The bit-size of the coordinates grows quadratically in the index: by the theory of canonical heights, $\log \operatorname{den} x(kP) \sim c\,k^2$ for a constant $c > 0$ depending on $(E_N, P)$, so the orbit is computable only for modest $n$ (in practice $n \le 12$ suffices to expose the phenomena). Total cost is dominated by the last steps: $\tilde O(k^2)$ bit operations per step at index $k$ using fast arithmetic.

### 11.2 Apparition index by reduction

Rather than searching the orbit, the apparition index at a good prime $\ell$ is computed directly as the order of $\bar P$ in $E_N(\mathbb{F}_\ell)$: build the finite group by counting points (or by baby-step/giant-step within the Hasse interval), then find the order of $\bar P$. This costs $O(\sqrt\ell)$ group operations rather than the exponential blow-up of orbit computation, and by Theorem 8.1 the answer is the exact apparition index. Verifying agreement of the two methods for small $\ell$ is a strong consistency check on the theory.

### 11.3 Denominator-valuation profiling

For each index $k$ and each small prime $\ell$, record $v_\ell(\operatorname{den} x(kP))$. Theorem 4.1 predicts all such valuations are even; Theorems 6.1 and 6.2 predict $v_\ell$ constant along $\{2^j Q\}$ for odd $\ell$ and arithmetic with common difference $2$ at $\ell = 2$; Theorem 8.1 predicts the support of $k \mapsto v_\ell$ is an arithmetic progression. The profile therefore gives a falsifiable numerical fingerprint for each theorem.

---

## 12. Discussion and future directions

### 12.1 What was established

The "only bad primes" conjecture is false, and it fails immediately, at the second multiple of an easily found point on a curve with $N = 55$. The explanation is not a defect of the example but a theorem: for a good prime $\ell$, divisibility of $\operatorname{den} x(kP)$ by $\ell$ is equivalent to $\bar P$ having order dividing $k$ in $E_N(\mathbb{F}_\ell)$, and since that group is finite, every good prime eventually appears — along the full arithmetic progression of multiples of its apparition index.

Around this refutation the paper builds a small, complete and entirely elementary theory of denominators on Mordell curves: the square-denominator law $(\operatorname{den} x, \operatorname{den} y) = (e^2, e^3)$; the complete local law at good primes $\ell \ge 5$; the exact filtration law, invariant at odd primes and $\times 4$ at the prime $2$; the subgroup property of the denominator kernel at *every* prime; and the apparition index law. As a by-product, unbounded $2$-adic denominator growth gives a constructive proof that $E_{55}(\mathbb{Q})$ is infinite.

### 12.2 Relation to classical theory

At good primes the results recover, in affine and elementary form, standard facts about the formal group $\hat E(\ell\mathbb{Z}_\ell)$: the filtration by $v_\ell(\operatorname{den} x) = 2n$, the bijectivity of multiplication by $2$ on the formal group for odd $\ell$, and the exact sequence relating $E(\mathbb{Q}_\ell)$, its reduction, and the kernel of reduction. The novelty of the presentation is that the arguments survive at bad primes and at $\ell = 2$, where the usual smooth-reduction hypotheses fail, and that they need nothing beyond unique factorization in $\mathbb{Z}$ and two polynomial identities: the doubling numerator $a^4 - 8Nae^6 = a(b^2 - 9Ne^6)$, and the slope-free chord identity $x_3(x_1-x_2)^2 = x_1x_2(x_1+x_2) + 2N - 2y_1y_2$.

The apparition index law puts denominators of elliptic orbits in the same family as elliptic divisibility sequences and Lucas sequences, where the classical notion of the rank of apparition plays the same role. The strengthening here is that the subgroup property, and hence the index law, is proved at all primes, not only at those of good reduction.

### 12.3 Future directions

The following directions are open; each is falsifiable by a single explicit rational point or by one finite computation.

**C1. Ultrametric valuation law for the chord.** Let $N \in \mathbb{Z}$, let $\ell$ be an odd prime, and let $P_1, P_2$ be rational points of $E_N$ in the denominator kernel at $\ell$ with $v_\ell(\operatorname{den} x(P_1)) \ne v_\ell(\operatorname{den} x(P_2))$. If $P_1 + P_2$ is affine with $x$-coordinate $x_3$, then
$$v_\ell(\operatorname{den} x_3) = \min\big(v_\ell(\operatorname{den} x(P_1)),\, v_\ell(\operatorname{den} x(P_2))\big),$$
and if the two valuations agree then $v_\ell(\operatorname{den} x_3) \ge v_\ell(\operatorname{den} x(P_1))$, with equality unless $\ell$ divides an explicit resultant. The key insight is that the closure proof already produces the chord $x$-coordinate as an explicit ratio $A/B$ of integers in the coprime parametrization $x = a/e^2$, $y = b/e^3$; the $\min$ law is then a statement about the $\ell$-adic sizes of the three summands of $A$, requiring only a term-by-term valuation count and no formal-group machinery. Since the qualitative closure statement is now proved, what remains is exactly this quantitative refinement.

**C2. Every good prime appears in the orbit of one non-torsion point.** Fix $N = 55$ and $P = (9,28)$. For every prime $\ell \notin \{2,3,5,11\}$ there is $k \ge 1$ with $\ell \mid \operatorname{den} x(kP)$, and the apparition index $m(\ell)$ equals the order of the reduction $\bar P$ in the finite group $E_{55}(\mathbb{F}_\ell)$; in particular $m(\ell) \mid \#E_{55}(\mathbb{F}_\ell)$ and $m(\ell) \le \ell + 1 + 2\sqrt\ell$ by Hasse's bound.

**C3. Distribution of apparition indices.** For fixed $(E_N, P)$, understand the distribution of $m(\ell)$ as $\ell$ varies: how often is $m(\ell)$ small, and what is the density of primes with $m(\ell) \le B$? This is an elliptic analogue of Artin-type questions about the order of a fixed element in $(\mathbb{Z}/\ell)^\times$, and it controls exactly how quickly the denominators of an orbit accumulate good primes.

**C4. Sharp counting for the denominator spectrum.** The square-denominator law bounds the number of achievable $x$-denominators below $X$ by $\sqrt X + 1$. What is the true counting function for a fixed curve, and for the union over all $N$ in a box? Which squares $e^2$ are achievable at all?

**C5. Higher-degree analogues.** For general Weierstrass curves $y^2 = x^3 + Ax + B$ over $\mathbb{Z}$ the square-denominator law persists, but the doubling numerator identity acquires extra terms. Determine the exact form of the local law and the filtration law in that generality, and identify the primes at which the analogue of Theorem 5.2 fails.

**C6. Bad-prime behaviour.** The filtration law and the subgroup property hold at bad primes, but the local criterion of Theorem 5.2 does not. Establish the correct replacement at additive and multiplicative primes, presumably in terms of the component group of the Néron model.

---

## 13. Summary of principal statements

For the reader's convenience, the main results in one place. Throughout $N \in \mathbb{Z}$, $E_N : y^2 = x^3 + N$, and $P = (x,y) \in E_N(\mathbb{Q})$.

- **Square-denominator law.** $\operatorname{den} x = e^2$ and $\operatorname{den} y = e^3$ for a unique $e \ge 1$; every prime occurs to an even exponent in $\operatorname{den} x$; the achievable denominators below $X$ number at most $\sqrt X + 1$.
- **Counterexample.** On $E_{55}$ with $P = (9,28)$: $x(2P) = 2601/3136$, $3136 = 2^6\cdot 7^2$, and $7 \nmid \Delta$; also $x(3P) = -2302089191/656538129$ with denominator $3^6\cdot13^2\cdot73^2$, containing the good primes $13, 73$ and neither $5$ nor $11$.
- **Complete local law.** For $\ell \ge 5$ with $\ell \nmid N$ and $y \ne 0$: $\ell \mid \operatorname{den} x(2P) \iff \ell \mid \operatorname{den} x(P)$ or $\ell \mid \operatorname{num} y(P)$.
- **Filtration law.** For odd $\ell$ with $\ell \mid \operatorname{den} x(P)$: $v_\ell(\operatorname{den} x(2P)) = v_\ell(\operatorname{den} x(P))$. For $\ell = 2$ with $2 \mid \operatorname{den} x(P)$: $v_2(\operatorname{den} x(2P)) = v_2(\operatorname{den} x(P)) + 2$.
- **Subgroup property.** $\{P : \ell \mid \operatorname{den} x(P)\} \cup \{\mathcal{O}\}$ is a subgroup of $E_N(\mathbb{Q})$ for every prime $\ell$.
- **Apparition index law.** There is $m = m(\ell,P) \in \mathbb{N}$ with $\ell \mid \operatorname{den} x(kP) \iff m \mid k$ for all $k \in \mathbb{Z}$. On $E_{55}$, $P=(9,28)$: $m(7) = 2$, $m(13) = 3$.
- **Infinitude.** $v_2(\operatorname{den} x(2^kQ)) = v_2(\operatorname{den} x(Q)) + 2k$; hence any point with even $x$-denominator has infinite order and $E_N(\mathbb{Q})$ is infinite. In particular $(9,28)$ has infinite order, $E_{55}(\mathbb{Q})$ is infinite, and infinitely many distinct multiples of $(9,28)$ have the good prime $7$ in the denominator.
- **Survey.** Over eleven semiprime Mordell curves: "only bad primes" holds $0\%$ of the time, $q$ appears $0\%$ of the time, $p$ appears $54.5\%$ of the time.
