# Rational-Torsion Degeneracy, the Inert Dial, and the Union-Dilution Law for CM Elliptic Curves

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

We study, for the two rational elliptic curves with complex multiplication of class number one and $j$-invariant $0$ and $1728$, the question of whether residue-class data about a prime $p$ can predict divisibility properties of the group order $\#E(\mathbb{F}_p)$ — the quantity on whose smoothness Lenstra's elliptic curve method of factorisation gambles. We prove a complete negative answer for the curve $E_0 : y^2 = x^3 + 1$ with complex multiplication by the Eisenstein integers, together with three exact structural laws that explain the negative answer and delimit precisely where predictive structure does and does not survive.

First, a **rational-torsion degeneracy**: $6 \mid \#E_0(\mathbb{F}_p)$ for every prime $p > 3$, proved without invoking the group law by exhibiting translation by the rational $3$-torsion point $(0,1)$ as an explicit fixed-point-free self-map of order three of the point set. Combined with an exact information-theoretic lemma — a constant Boolean observable has empirical mutual information exactly $0$ against every classifying statistic — this yields that the divisibility channels at levels $\ell \in \{1,2,3,6\}$ carry exactly zero bits on every finite sample of good primes and against every class function. We show that the null is a degeneracy of the *event* and not of the statistic, by proving that the same functional attains $\log 2$, and that the level-$5$ channel on the same curve is non-constant and attains $\log 2$ on an explicit two-prime sample. We then classify the silent set exactly: the divisibility $\ell \mid \#E_0(\mathbb{F}_p)$ is unconditional on the good primes **if and only if** $\ell \mid 6$, giving an all-or-nothing dichotomy between $0$ bits and a full bit.

Second, an **exact inert collapse and residue dial**: for $p \equiv 2 \pmod 3$ one has $\#E_0(\mathbb{F}_p) = p+1$ exactly, hence $a_p = 0$, and therefore $\ell \mid \#E_0(\mathbb{F}_p) \iff p \equiv -1 \pmod \ell$ for every $\ell \ge 1$. The same collapse holds for $E_{1728} : y^2 = x^3 + x$ on $p \equiv 3 \pmod 4$, so the mechanism is independent of the CM field; on the inert half elliptic-curve factorisation on these curves reduces literally to Williams' $p+1$ method. We complement this with an exact trace dichotomy — $a_p = 0$ if and only if $p$ is inert, for both curves — whence the count of primes with vanishing trace in any finite sample equals the count of inert primes identically. On the split half the corresponding visibility fails already at modulus $9$: the primes $13$ and $31$ are both $\equiv 4 \pmod 9$ and split, yet $9 \mid \#E_0(\mathbb{F}_{31}) = 36$ while $9 \nmid \#E_0(\mathbb{F}_{13}) = 12$, and $a_{13} = 2 \not\equiv -4 = a_{31} \pmod 9$.

Third, a **union-dilution law**: if a class-blind event of probability $b$ is mixed disjointly into a conditional channel with profile $a_k$, the weighted conditional variance is unchanged while the normaliser $\mu(1-\mu)$ increases below base rate $1/2$, so the squared correlation ratio satisfies $\eta^2(a+b) \le \eta^2(a)$, strictly for $b>0$ on a non-degenerate channel, with exact factor $\mu_A(1-\mu_A)/\mu_U(1-\mu_U)$; the family is monotone in $b$ and the set of achievable dilution factors is exactly $(0,1]$. Consequently a union channel is never stronger than the conditional channel it contains, and no universal constant below $1$ improves the bound.

**Keywords:** complex multiplication, elliptic curve factorisation, trace of Frobenius, rational torsion, mutual information, correlation ratio, supersingular reduction, Eisenstein integers.

---

## 1. Introduction

### 1.1 The question

Integer factorisation algorithms of the "one-prime-at-a-time" family all share a structure. To find a prime divisor $p$ of a composite $N$, one constructs an algebraic group $G_p$ depending on $p$, and hopes that $\#G_p$ is $B$-smooth (all prime factors at most $B$). If it is, computing $\prod_{q \le B} q^{\lfloor \log_q B \rfloor}$-th powers in a group one can manipulate without knowing $p$ reveals $p$ by a gcd.

- Pollard's $p-1$ method (1974) takes $G_p = \mathbb{F}_p^\times$, $\#G_p = p - 1$.
- Williams' $p+1$ method (1982) takes a norm-one torus, $\#G_p = p+1$.
- Lenstra's elliptic curve method (1987) takes $G_p = E(\mathbb{F}_p)$ for an elliptic curve $E/\mathbb{Q}$ with good reduction at $p$, so that by Hasse's theorem
$$\#E(\mathbb{F}_p) = p + 1 - a_p, \qquad |a_p| \le 2\sqrt{p} .$$

The decisive advantage of ECM is that $a_p$ varies with the curve: one may re-randomise until $\#E(\mathbb{F}_p)$ is smooth. This raises a natural and practically consequential question, which we call the **order-shadow question**:

> Is there a computable statistic of $p$ (in practice: a residue class, computable from $N$ itself for small moduli) that carries information about divisibility of $\#E(\mathbb{F}_p)$ by a fixed small $\ell$?

An affirmative answer would let a practitioner bias curve selection, and would be a structural weakness of factoring-based cryptography. The most promising candidates are curves with **complex multiplication**, whose Frobenius traces are governed by abelian reciprocity and are therefore, in principle, "residue-visible".

### 1.2 The two CM curves and the results

Over $\mathbb{Q}$ the two canonical CM curves are
$$E_0 : y^2 = x^3 + 1 \quad (j = 0, \ \mathrm{End} = \mathbb{Z}[\omega], \ \text{CM field } \mathbb{Q}(\sqrt{-3}), \ \text{bad primes } 2, 3),$$
$$E_{1728} : y^2 = x^3 + x \quad (j = 1728, \ \mathrm{End} = \mathbb{Z}[i], \ \text{CM field } \mathbb{Q}(i), \ \text{bad prime } 2).$$

This paper analyses the order-shadow question on $E_0$ (with $E_{1728}$ as the field-independence control) and answers it in the negative, with three exact refinements. Sections 3–5 contain the arithmetic (torsion degeneracy, inert collapse, residue dials, trace dichotomy); Section 6 the information theory (zero-bit law, non-vacuity, silent-set classification, curve-uniform torsion-silence); Section 7 the union-dilution law with its sharpness; Section 8 algorithms; Sections 9–10 discussion and future work.

A summary of the verdict:

1. On the inert half of the CM field, the curve order is $p+1$ **exactly**. Every divisibility question is a $p+1$ question. ECM on a CM curve there is the $p+1$ method, contributing nothing new.
2. The divisibility structure that *is* uniformly residue-visible is unconditional (a consequence of rational torsion) and therefore carries exactly zero bits.
3. On the split half, where the trace genuinely varies, it is invisible to residue classes already at modulus $9$.
4. Any attempt to combine channels into a union is provably *quieter* than the sharpest conditional channel inside it.

### 1.3 Notation

Throughout, $p$ denotes a prime. For $A, B \in \mathbb{F}_p$ with non-vanishing discriminant $-16(4A^3 + 27B^2)$ we write
$$\mathrm{Aff}(A,B) = \{(x,y) \in \mathbb{F}_p^2 : y^2 = x^3 + Ax + B\}, \qquad \#E_{A,B}(\mathbb{F}_p) = \#\mathrm{Aff}(A,B) + 1,$$
the $+1$ accounting for the point at infinity, and $a_p = p + 1 - \#E_{A,B}(\mathbb{F}_p)$. We abbreviate $\#E_0(\mathbb{F}_p) := \#E_{0,1}(\mathbb{F}_p)$ and $\#E_{1728}(\mathbb{F}_p) := \#E_{1,0}(\mathbb{F}_p)$. A prime $p > 3$ is called *good* for $E_0$. For $E_0$, $p$ is **inert** when $p \equiv 2 \pmod 3$ and **split** when $p \equiv 1 \pmod 3$; for $E_{1728}$, inert means $p \equiv 3 \pmod 4$.

---

## 2. A counting principle for free cyclic self-maps

All torsion results below are obtained from one elementary counting principle, which we isolate because it is used in a form stronger than the classical orbit-counting statement: we need it without assuming that the map comes from a group action, and without assuming primality of the order.

**Lemma 2.1 (Free-iterate counting).** *Let $\alpha$ be a finite set, $n \ge 1$, and $f : \alpha \to \alpha$ a self-map with $f^{[n]} = \mathrm{id}$ and $f^{[k]}(x) \ne x$ for every $x \in \alpha$ and every $0 < k < n$. Then $n \mid \#\alpha$.*

*Proof sketch.* The hypothesis $f^{[n]} = \mathrm{id}$ makes $f$ invertible with inverse $f^{[n-1]}$, so $f$ defines a permutation $g$ of $\alpha$; one checks $g^k$ acts as $f^{[k]}$. Then $g^n = 1$, and the order of $g$ is exactly $n$, since a smaller order $d$ would give $f^{[d]}(x) = x$ for any $x$. The cyclic subgroup $\langle g \rangle \le \mathrm{Sym}(\alpha)$ therefore has order $n$, and freeness of the iterates says exactly that all point stabilisers are trivial: writing an arbitrary element of $\langle g \rangle$ as $g^k$ with $0 \le k < n$, a fixed point of $g^k$ with $k>0$ is a fixed point of $f^{[k]}$. A free action of a group of order $n$ decomposes $\alpha$ into orbits of size exactly $n$, so $\#\alpha = n \cdot (\text{number of orbits})$. $\square$

For $n = 3$ freeness of $f$ alone suffices: if $f^{[2]}(x) = x$, then $f(x) = f^{[3]}(x) = x$, contradicting freeness at $k=1$. We use this special case in Section 3, and Lemma 2.1 in the curve-uniform statement of Section 6.4.

---

## 3. Rational-torsion degeneracy on the $j = 0$ curve

### 3.1 The translation map as an explicit rational self-map

The curve $E_0 : y^2 = x^3 + 1$ carries the rational point $T = (0,1)$, of order $3$ in the group law, and the rational point $(-1, 0)$, of order $2$. Because these are rational, they persist under reduction at every good prime. We convert the $3$-torsion into a counting statement by writing translation by $T$ as an explicit map, so that no group law needs to be invoked.

**Definition 3.1.** Over a field $F$ of characteristic $\ne 2, 3$, set, for $x \ne 0$,
$$\tau(x,y) \;=\; \left( \frac{2(1-y)}{x^2}, \ \frac{y-3}{y+1} \right).$$

The second coordinate is a Möbius transformation of order three; the first is obtained from the chord through $(x,y)$ and $T$, whose slope is $(y-1)/x$, after using the curve relation.

**Lemma 3.2 (Well-definedness).** *If $y^2 = x^3 + 1$ and $x \ne 0$ then $y - 1 \ne 0$ and $y + 1 \ne 0$.*

*Proof.* If $y = 1$ then $x^3 = y^2 - 1 = 0$, so $x = 0$; likewise for $y = -1$. $\square$

**Lemma 3.3 (Stability).** *If $y^2 = x^3+1$ and $x \ne 0$, then $\tau(x,y)$ again satisfies the curve equation, and its first coordinate is again non-zero.*

*Proof sketch.* Writing $X = 2(1-y)/x^2$ and $Y = (y-3)/(y+1)$, clearing denominators reduces $Y^2 - X^3 - 1 = 0$ to a polynomial identity that is a multiple of $y^2 - x^3 - 1$; explicitly, $Y^2 (y+1)^{-2}$-cleared form equals $-8(1-y)(x^3 - 1 + y^2)$ times the curve relation. Non-vanishing of $X$ is Lemma 3.2 together with characteristic $\ne 2$. $\square$

**Lemma 3.4 (Order three).** *Under the same hypotheses, $\tau^{[2]}(x,y) = \bigl(2x/(y-1), \ -(y+3)/(y-1)\bigr)$ and $\tau^{[3]}(x,y) = (x,y)$.*

*Proof sketch.* Both are direct computations with the curve relation used once each; the $y$-coordinate iterates purely as the Möbius map $y \mapsto (y-3)/(y+1)$, whose cube is the identity, and the $x$-coordinate follows from the stability identity of Lemma 3.3. $\square$

**Lemma 3.5 (Freeness).** *If $\mathrm{char}\, F \nmid 6$, then $\tau(x,y) \ne (x,y)$ for every point with $x \ne 0$.*

*Proof.* Equality of first coordinates gives $2(1-y) = x^3 = y^2 - 1$, i.e. $(y+3)(y-1) = 0$, so $y = -3$ by Lemma 3.2. Equality of second coordinates gives $y^2 = -3$. Substituting yields $9 = -3$, i.e. $12 = 0$, impossible when the characteristic divides neither $2$ nor $3$. $\square$

### 3.2 The degeneracy theorem

**Theorem 3.6 (Rational $3$-torsion degeneracy).** *For every prime $p > 3$, $\ 3 \mid \#E_0(\mathbb{F}_p)$.*

*Proof.* Define a self-map $\sigma$ of the full point set $E_0(\mathbb{F}_p) = \mathrm{Aff}(0,1) \cup \{\infty\}$ by
$$\infty \mapsto (0,1), \qquad (0,1) \mapsto (0,-1), \qquad (0,-1) \mapsto \infty, \qquad (x,y) \mapsto \tau(x,y) \ \ (x \ne 0),$$
observing that on the fibre $x = 0$ the only points are $(0, \pm 1)$, because $y^2 = 1$ factors as $(y-1)(y+1) = 0$. By Lemmas 3.3–3.4 the map is well defined and satisfies $\sigma^{[3]} = \mathrm{id}$; by Lemma 3.5 together with $p > 3$ (which separates $(0,1)$, $(0,-1)$, $\infty$) it is fixed-point free. Lemma 2.1 with $n = 3$ gives $3 \mid \#E_0(\mathbb{F}_p)$. $\square$

**Theorem 3.7 (Full $6$-torsion degeneracy).** *For every prime $p > 3$: $\ 2 \mid \#E_0(\mathbb{F}_p)$, hence $6 \mid \#E_0(\mathbb{F}_p)$, and consequently*
$$a_p \equiv p + 1 \pmod 6 .$$

*Proof.* For a curve $y^2 = f(x)$ with $f$ a separable cubic over $\mathbb{F}_p$, $p$ odd, the order is even if and only if $f$ has a root in $\mathbb{F}_p$ (a root contributes a point of order $2$, and conversely by pairing $(x, y) \leftrightarrow (x,-y)$ the affine count is congruent modulo $2$ to the number of roots). Here $f(x) = x^3 + 1$ has the root $x = -1$ unconditionally, and $\mathrm{disc}(x^3+1) = -27 \ne 0$ in $\mathbb{F}_p$ for $p \ne 3$. Combining with Theorem 3.6 and $\gcd(2,3)=1$ gives $6 \mid \#E_0(\mathbb{F}_p)$. The congruence follows from $a_p = p+1-\#E_0(\mathbb{F}_p)$. $\square$

Numerically: $\#E_0(\mathbb{F}_p) = 6, 12, 12, 12, 18, 12, 24, 30, 36$ for $p = 5,7,11,13,17,19,23,29,31$.

---

## 4. The inert collapse, field-independently

### 4.1 The Eisenstein case

**Theorem 4.1 (Inert collapse, $\mathbb{Q}(\sqrt{-3})$).** *If $p \equiv 2 \pmod 3$ then $\#E_0(\mathbb{F}_p) = p+1$ exactly, hence $a_p = 0$.*

*Proof.* Put $e = (2p-1)/3$, an integer because $p \equiv 2 \pmod 3$, and note $3e = 2(p-1) + 1$. For $u \in \mathbb{F}_p$, $u^{3e} = u^{2(p-1)}\cdot u = u$ by Fermat (trivially also for $u=0$). Hence $u \mapsto u^3$ is a bijection of $\mathbb{F}_p$ with inverse $u \mapsto u^e$. Therefore, for each $y \in \mathbb{F}_p$, the equation $x^3 = y^2 - 1$ has exactly one solution, namely $x = (y^2-1)^e$; so the second-coordinate projection $\mathrm{Aff}(0,1) \to \mathbb{F}_p$ is a bijection and $\#\mathrm{Aff}(0,1) = p$. Adding the point at infinity gives $p+1$. $\square$

### 4.2 The Gaussian case

**Theorem 4.2 (Inert collapse, $\mathbb{Q}(i)$).** *If $p \equiv 3 \pmod 4$ then $\#E_{1728}(\mathbb{F}_p) = p + 1$ exactly, hence $a_p = 0$.*

*Proof sketch.* Write $s(c) = \#\{y : y^2 = c\}$, so that $s(c) = \chi(c) + 1$ with $\chi$ the quadratic character (extended by $\chi(0)=0$). For $p \equiv 3 \pmod 4$ one has $\chi(-1) = -1$, whence $s(c) + s(-c) = \chi(c) + \chi(-c) + 2 = 2$ for all $c$: the fibres over $c$ and $-c$ contribute exactly two points in total. The cubic $g(x) = x^3 + x$ is odd, $g(-x) = -g(x)$, so re-indexing the affine count $S = \sum_x s(g(x))$ by $x \mapsto -x$ gives $S = \sum_x s(-g(x))$ and hence $2S = \sum_x \bigl(s(g(x)) + s(-g(x))\bigr) = 2p$, i.e. $S = p$. $\square$

**Theorem 4.3 (Field independence of the collapse).** *Let $q \equiv 2 \pmod 3$ and $r \equiv 3 \pmod 4$ be primes with good reduction. Then $\#E_0(\mathbb{F}_q) = q+1$ and $\#E_{1728}(\mathbb{F}_r) = r+1$; consequently, for every $\ell \ge 1$,*
$$\ell \mid \#E_0(\mathbb{F}_q) \iff \ell \mid q+1, \qquad \ell \mid \#E_{1728}(\mathbb{F}_r) \iff \ell \mid r+1 .$$

*In words: on the inert half of either CM field, every smoothness question about the elliptic order is literally the corresponding question about $p+1$; elliptic-curve factorisation on a CM curve there coincides with the $p+1$ method, and the mechanism does not depend on the CM field.*

### 4.3 The residue dial

**Theorem 4.4 (Inert dial).** *Let $p \equiv 2 \pmod 3$ and $\ell \ge 1$. Then*
$$\ell \mid \#E_0(\mathbb{F}_p) \iff p \equiv \ell - 1 \pmod \ell .$$
*In particular, for every $m \ge 0$, $\ 3^m \mid \#E_0(\mathbb{F}_p) \iff p \equiv 3^m - 1 \pmod{3^m}$; e.g. $9 \mid \#E_0(\mathbb{F}_p) \iff p \equiv 8 \pmod 9$ and $27 \mid \#E_0(\mathbb{F}_p) \iff p \equiv 26 \pmod{27}$.*

*Proof.* By Theorem 4.1 the order is $p+1$; and $\ell \mid n+1$ if and only if $n \bmod \ell = \ell - 1$, since $(n+1) \bmod \ell = (n \bmod \ell + 1) \bmod \ell$ and $n \bmod \ell + 1 \le \ell$. $\square$

**Corollary 4.5 (Residue visibility, inert half).** *If $p, q \equiv 2 \pmod 3$ and $p \equiv q \pmod \ell$, then $\ell \mid \#E_0(\mathbb{F}_p) \iff \ell \mid \#E_0(\mathbb{F}_q)$: on the inert half the ECM-order event is a function of $p \bmod \ell$.*

That the sharpest instances occur at powers of $3$ — the ramified prime of $\mathbb{Q}(\sqrt{-3})$ — is structurally meaningful: ramification shrinks the $3$-adic part of the relevant conductor, so that the Frobenius datum modulo $3^k$ is pinned by a small modulus. The next subsection shows that outside the inert half this pinning disappears.

### 4.4 Failure of the dial on the split half

**Theorem 4.6 (No split-half dial at modulus $9$).** *There exist primes $q, r$ with $q \equiv r \pmod 9$, both split ($q \equiv r \equiv 1 \pmod 3$), such that $9 \mid \#E_0(\mathbb{F}_q)$ and $9 \nmid \#E_0(\mathbb{F}_r)$. Moreover the traces are incongruent modulo $9$.*

*Proof.* Take $q = 31$ and $r = 13$: both are $\equiv 4 \pmod 9$ and $\equiv 1 \pmod 3$. Direct counting gives $\#E_0(\mathbb{F}_{31}) = 36$ and $\#E_0(\mathbb{F}_{13}) = 12$, so $9 \mid 36$ but $9 \nmid 12$. The traces are $a_{31} = 32 - 36 = -4$ and $a_{13} = 14 - 12 = 2$, and $-4 \not\equiv 2 \pmod 9$. $\square$

Thus the visibility of the elliptic order in residue classes of $p$ is precisely a *ramified-inert* phenomenon, and not a global congruence. On the split half, where $a_p$ genuinely varies (parameterised, classically, by the representation $4p = L^2 + 27M^2$ or $p = a^2+3b^2$), the residue class of $p$ modulo $9$ determines nothing.

---

## 5. The exact trace dichotomy

**Theorem 5.1 (Trace dichotomy, $\mathbb{Q}(\sqrt{-3})$).** *For a prime $p > 3$: $\ a_p(E_0) = 0 \iff p \equiv 2 \pmod 3$.*

*Proof.* ($\Leftarrow$) is Theorem 4.1. ($\Rightarrow$): by Theorem 3.7, $a_p \equiv p+1 \pmod 3$; if $a_p = 0$ then $3 \mid p+1$. Since $p > 3$ is prime, $p \not\equiv 0 \pmod 3$, so $p \equiv 2 \pmod 3$. $\square$

**Theorem 5.2 (Trace dichotomy, $\mathbb{Q}(i)$).** *For an odd prime $p$: $\ a_p(E_{1728}) = 0 \iff p \equiv 3 \pmod 4$.*

*Proof.* ($\Leftarrow$) is Theorem 4.2. ($\Rightarrow$): suppose $a_p = 0$ and $p \equiv 1 \pmod 4$. Then $-1$ is a square in $\mathbb{F}_p$, say $i^2 = -1$, so $x^3 + x = x(x-i)(x+i)$ has three distinct roots $0, i, -i$, whence $E_{1728}(\mathbb{F}_p)$ contains full rational $2$-torsion and $4 \mid \#E_{1728}(\mathbb{F}_p)$. But $a_p = 0$ says $\#E_{1728}(\mathbb{F}_p) = p+1 \equiv 2 \pmod 4$, a contradiction. $\square$

**Corollary 5.3 (Atomic trace law).** *For any finite sample $S$ of good primes,*
$$\#\{p \in S : a_p(E_0) = 0\} = \#\{p \in S : p \equiv 2 \ (\mathrm{mod}\ 3)\}, \qquad \#\{p \in S : a_p(E_{1728}) = 0\} = \#\{p \in S : p \equiv 3 \ (\mathrm{mod}\ 4)\} .$$

So an empirical observation that the trace vanishes on approximately half of a sample of primes is not a statistical near-coincidence requiring a density theorem: it is an *identity* between two counts, and the observed frequency is exactly the sampled inert frequency. (Dirichlet's theorem then makes that frequency tend to $1/2$, but the identity is exact at every finite sample size.) Equivalently, supersingularity of these two CM curves is a pure residue condition — the sharpest possible form of the classical picture.

---

## 6. The information-theoretic half

### 6.1 The empirical channel

Let $\Omega$ be a finite non-empty sample (in practice: a finite list of primes), $c : \Omega \to \kappa$ a *class statistic* with finite value set (in practice: $p \bmod m$), and $E : \Omega \to \{0,1\}$ a Boolean *event* (in practice: $\ell \mid \#E_0(\mathbb{F}_p)$). Under the counting measure define
$$P(k,b) = \frac{\#\{\omega : c(\omega)=k,\ E(\omega)=b\}}{\#\Omega}, \quad P_c(k) = \frac{\#\{\omega : c(\omega)=k\}}{\#\Omega}, \quad P_E(b) = \frac{\#\{\omega : E(\omega)=b\}}{\#\Omega},$$
$$I(c\,;E) \;=\; \sum_{k \in \kappa} \sum_{b \in \{0,1\}} P(k,b)\, \log \frac{P(k,b)}{P_c(k)\,P_E(b)},$$
the plug-in (empirical) mutual information in nats, with the convention $0\log 0 = 0$.

### 6.2 The zero-bit law and its non-vacuity

**Theorem 6.1 (Degeneracy law).** *If $E$ is constant on $\Omega$, then $I(c\,;E) = 0$ exactly, for every class statistic $c$.*

*Proof.* Let $E \equiv v$. Then $P_E(v) = 1$, $P(k,v) = P_c(k)$ for all $k$, and $P(k,b) = 0$ for $b \ne v$. Each summand with $b \ne v$ vanishes by the prefactor; each summand with $b = v$ equals $P_c(k)\log\bigl(P_c(k)/(P_c(k)\cdot 1)\bigr) = P_c(k) \log 1 = 0$ (and vanishes trivially if $P_c(k) = 0$). $\square$

**Theorem 6.2 (Silence of the small levels).** *For every finite non-empty sample of primes $> 3$, every class statistic, and every $\ell \in \{1,2,3,6\}$, the channel $\omega \mapsto [\ell \mid \#E_0(\mathbb{F}_{p_\omega})]$ has $I = 0$ exactly.*

*Proof.* Combine Theorem 3.7 (the event is identically true) with Theorem 6.1. $\square$

This is the headline null, and it is *exact*, not "below a noise floor". The event is genuinely arithmetic, genuinely abelian in origin, and genuinely visible; it just never varies.

Because a null result is only as trustworthy as the statistic producing it, we record the two non-vacuity facts.

**Proposition 6.3 (The functional attains a full bit).** *On the two-point sample $\Omega = \{0,1\}$ with $c = \mathrm{id}$ and $E = \mathrm{id}$, one has $I(c\,;E) = \log 2$.*

*Proof.* All four cells: $P(1,1) = P(0,0) = 1/2$, $P(1,0)=P(0,1)=0$, and all marginals $1/2$; the two non-zero cells each contribute $\tfrac12 \log\bigl((1/2)/(1/4)\bigr) = \tfrac12\log 2$. $\square$

**Proposition 6.4 (The level-$5$ event is conditional).** *$\#E_0(\mathbb{F}_{29}) = 30$ and $\#E_0(\mathbb{F}_5) = 6$, so $5 \mid \#E_0(\mathbb{F}_{29})$ while $5 \nmid \#E_0(\mathbb{F}_{5})$. On the two-prime sample $\{29,5\}$ labelled by itself, the level-$5$ channel has $I = \log 2$.*

Hence the $\ell = 3$ null is a property of the **event** — a rational-torsion degeneracy — and not of the measuring statistic. The contrapositive is worth stating: a channel with $I \ne 0$ necessarily has a non-constant event.

### 6.3 Classification of the silent set

**Theorem 6.5 (Silent-set classification).** *For $\ell \ge 1$:*
$$\bigl(\ \ell \mid \#E_0(\mathbb{F}_p) \ \text{ for every prime } p > 3 \ \bigr) \iff \ell \mid 6 .$$
*Hence the zero-bit locus of $E_0$ is exactly $\{1,2,3,6\}$.*

*Proof.* ($\Leftarrow$) is Theorem 3.7. ($\Rightarrow$) needs a single prime: $\#E_0(\mathbb{F}_5) = 6$, so $\ell \mid 6$. $\square$

**Theorem 6.6 (All-or-nothing dichotomy).** *For every $\ell \ge 1$, exactly one of the following holds.*
1. *$\ell \mid 6$, and the channel $[\ell \mid \#E_0(\mathbb{F}_p)]$ carries exactly $0$ nats on every finite sample of good primes and against every class statistic.*
2. *$\ell \nmid 6$, and for every good prime $q$ with $\ell \mid \#E_0(\mathbb{F}_q)$, the two-prime sample $\{q, 5\}$ (labelled by itself) makes the same channel carry exactly $\log 2$ — a full bit.*

*Proof.* Case 1 is Theorems 6.5 and 6.1. In case 2, $\ell \nmid 6 = \#E_0(\mathbb{F}_5)$ makes $q$ and $5$ witnesses of opposite divisibility, so the event coincides with the sample label and Proposition 6.3 applies. $\square$

So there is no intermediate regime of "weakly informative" levels for this curve: silence is *equivalent* to rational torsion, and any non-silent level is already maximally informative on a suitably chosen (tiny) sample. What sample-level correlation actually exists for large samples is a separate, quantitative matter, addressed by the dilution analysis of Section 7.

### 6.4 The torsion-silence principle, curve-uniformly

Nothing in Section 6.2 used complex multiplication; only the *unconditional* divisibility did, and that came from rational torsion. Lemma 2.1 lets us state the general principle.

**Theorem 6.7 (Torsion-silence principle).** *Let $\Omega$ be a finite non-empty sample, and suppose each $\omega \in \Omega$ carries a finite point set $X_\omega$ together with a self-map $f_\omega : X_\omega \to X_\omega$ satisfying $f_\omega^{[n]} = \mathrm{id}$ and having no point of period $k$ for $0 < k < n$ — the shape of "reduction of a rational $n$-torsion point acting by translation". Then $n \mid \# X_\omega$ for every $\omega$, and consequently the channel $\omega \mapsto [\,n \mid \#X_\omega\,]$ has empirical mutual information exactly $0$ against every class statistic.*

No hypothesis is placed on $n$ (prime or not), on the curve, or on its CM field. The $E_0$ situation is the case $n = 3$ (and $n = 6$). The principle explains the phenomenon in the right generality: **rational torsion produces silence, complex multiplication does not.** Any curve with a rational point of order $n$ has a dead channel at level $n$; the interesting channels start above the torsion order, and the classification of Theorem 6.5 says that for $E_0$ they start immediately above it.

---

## 7. The union-dilution law

### 7.1 Statement

In practice an experiment rarely measures a single conditional event; it measures a union, e.g. "the elliptic order is divisible by $\ell$ **or** some class-independent auxiliary event occurs". The following law quantifies exactly what that does to the measured effect size.

Fix a finite class set $\kappa$ with weights $w_k \ge 0$, $\sum_k w_k = 1$, and a conditional-probability profile $a : \kappa \to [0,1]$, $a_k = P(A \mid k)$. Write
$$\mu(a) = \sum_k w_k a_k, \qquad V(a) = \sum_k w_k (a_k - \mu(a))^2, \qquad \eta^2(a) = \frac{V(a)}{\mu(a)\,(1-\mu(a))} .$$
$\eta^2$ is the squared correlation ratio of the binary channel: the fraction of the Bernoulli variance explained by the class. Let $B$ be a class-independent event, disjoint from $A$, with $P(B) = b$, so that $P(A \cup B \mid k) = a_k + b$.

**Theorem 7.1 (Union dilution).** *Assume $\mu(a) > 0$, $b \ge 0$, and $\mu(a) + b \le 1/2$. Then*
$$\eta^2(a + b) \ \le \ \eta^2(a),$$
*with strict inequality if $b>0$ and $V(a) > 0$. Moreover the exact factor is*
$$\frac{\eta^2(a+b)}{\eta^2(a)} \;=\; \frac{\mu_A(1-\mu_A)}{\mu_U(1-\mu_U)}, \qquad \mu_A = \mu(a), \ \ \mu_U = \mu(a) + b .$$

*Proof.* Two observations. (i) *Shift-invariance of the numerator*: $\mu(a+b) = \mu(a) + b$ because $\sum_k w_k = 1$, hence $(a_k + b) - \mu(a+b) = a_k - \mu(a)$ termwise and $V(a+b) = V(a)$. (ii) *Monotonicity of the normaliser*: $t \mapsto t(1-t)$ is strictly increasing on $[0,1/2]$, so $\mu_A(1-\mu_A) \le \mu_U(1-\mu_U)$, strictly if $b>0$. Dividing the common numerator $V(a) \ge 0$ by the larger denominator gives the inequality, and the ratio identity is immediate from $V(a+b) = V(a)$. $\square$

**Theorem 7.2 (Monotone family).** *Under the same hypotheses, if $0 \le b_1 \le b_2$ and $\mu(a) + b_2 \le 1/2$, then $\eta^2(a+b_2) \le \eta^2(a+b_1)$, strictly if $b_1 < b_2$ and $V(a) > 0$.*

### 7.2 Sharpness

Call $c \in \mathbb{R}$ an **achievable dilution factor** if there is an honest two-class channel — two classes of weight $1/2$, conditional probabilities $a_k \in (0,1)$, a class-blind admixture $b \ge 0$ with $a_k + b < 1$, non-degenerate variation $V(a) > 0$ and union base rate $\mu(a)+b \le 1/2$ — with $\eta^2(a+b) = c \cdot \eta^2(a)$.

**Theorem 7.3 (The achievable set is exactly $(0,1]$).** *Every achievable dilution factor lies in $(0,1]$, and every $c \in (0,1]$ is achieved.*

*Proof sketch.* The upper bound is Theorem 7.1; positivity holds because $V(a) > 0$ and both normalisers are positive. For attainment with $c = 1$, take $b = 0$. For $0 < c < 1$, set $r = \sqrt{1-c} \in (0,1)$ and $\mu = (1-r)/2 \in (0, 1/2)$, and take the two-class profile $a = (\mu + \mu/2, \ \mu - \mu/2)$ with class weights $1/2$ and admixture $b = 1/2 - \mu > 0$. Then $\mu(a) = \mu$, $V(a) = (\mu/2)^2$, the union base rate is exactly $1/2$, so $\mu_U(1-\mu_U) = 1/4$, and the factor is $4\mu(1-\mu) = (1-r)(1+r) = 1 - r^2 = c$. $\square$

Consequently the inequality "union channel $\le$ conditional channel" is universal and cannot be improved by any constant less than $1$: for any target loss factor there is a legitimate channel realising it exactly.

### 7.3 Interpretation

Three consequences deserve emphasis.

1. **Union measurements systematically understate conditional effects.** If a phenomenon is detected as $A \cup B$ with $B$ class-blind, the measured $\eta^2$ is smaller than the true conditional effect by a factor computable purely from the two base rates. Comparing that number against a threshold calibrated for the pure channel is a systematic error in the conservative direction.
2. **In the CM setting the dilution has an arithmetic source.** For $E_0$, the union of the ECM-order event with a class-blind half is diluted precisely because the split half of primes raises the unconditional base rate without adding class-conditional variation — the inert-class channel is the undiluted reference, and the union sits strictly below it. Swapping $\mathbb{Q}(\sqrt{-3})$ for $\mathbb{Q}(i)$ reproduces the same picture, as it must: nothing in Theorem 7.1 mentions the field.
3. **The bound is a variance-normalisation fact, not an arithmetic one.** It applies to any binary channel in any discipline. In this sense it is the most transportable result in the paper.

---

## 8. Algorithms

### 8.1 Exact point counting on the CM curves

For the modest primes relevant to verification, the exact order is computed by character summation:
$$\#E_{A,B}(\mathbb{F}_p) = 1 + \sum_{x \in \mathbb{F}_p} \bigl(1 + \chi(x^3+Ax+B)\bigr),$$
with $\chi$ evaluated by Euler's criterion $\chi(c) = c^{(p-1)/2}$. Cost: $O(p \log p)$ field operations. For the inert half the algorithm may be short-circuited to output $p+1$ by Theorem 4.1 or 4.2, an $O(1)$ answer — the practical content of the collapse.

### 8.2 Silent-set detection

Given a curve $E/\mathbb{Q}$ and a bound $L$, one determines which levels $\ell \le L$ are silent by computing $\#E(\mathbb{F}_p)$ for a modest set of good primes and intersecting the divisor sets. Theorem 6.5 guarantees that for $E_0$ the answer stabilises immediately: a single prime with $\#E = 6$ already forces the silent set to be contained in $\{1,2,3,6\}$, and the torsion theorem gives the reverse containment. In general the procedure computes $\gcd_p \#E(\mathbb{F}_p)$, whose divisors are exactly the candidate silent levels; the gcd stabilises rapidly, and the stable value equals the order of the rational torsion subgroup whenever the torsion acts freely on all good reductions.

### 8.3 Channel-information estimation

Given a sample of primes, a modulus $m$ and a level $\ell$, the empirical mutual information between $p \bmod m$ and $[\ell \mid \#E(\mathbb{F}_p)]$ is computed from the $|\kappa| \times 2$ contingency table in $O(\#\Omega + |\kappa|)$ operations after the point counts. The theory predicts a hard $0$ at every $\ell \mid 6$, for every $m$; any non-zero output there would indicate a bug rather than a discovery.

### 8.4 Dilution correction

Given an observed union effect $\eta^2_U$ and the two base rates $\mu_A, \mu_U$, the corresponding conditional effect is recovered exactly:
$$\eta^2_A \;=\; \eta^2_U \cdot \frac{\mu_U(1-\mu_U)}{\mu_A(1-\mu_A)} .$$
This is the practical form of Theorem 7.1 and should be applied before any comparison against a null threshold calibrated on a pure conditional channel.

---

## 9. Discussion

### 9.1 The verdict on the order-shadow question

For the $j=0$ CM curve the answer is a clean negative, and the negative decomposes into three distinct mechanisms.

- **Degeneracy.** The divisibility structure that is uniformly visible in residue classes — levels $1, 2, 3, 6$ — is unconditional, hence carries exactly zero bits. A fully residue-visible, abelian, $p+1$-sourced congruence on the elliptic order can reveal nothing whatsoever. The shadow is real only when the event is *conditional*.
- **Collapse.** Where a residue class does dictate divisibility — the inert half — the order is exactly $p+1$, so the "elliptic" method is the $p+1$ method and nothing has been gained over 1982.
- **Invisibility.** Where the arithmetic is genuinely two-dimensional — the split half — the trace is not a function of $p$ modulo $9$, so no residue dial exists at all.

Together these close the natural avenue: the CM structure does not hand a factoring practitioner a usable bias, and correspondingly does not weaken factoring-based cryptography.

### 9.2 Why the null is informative

A null result of the form "we measured a correlation and it was small" is weak evidence. The results above are of a different type: the correlation is *exactly* zero by an identity, the identity's cause is isolated (rational torsion, not complex multiplication), the cause is classified (silence $\iff \ell \mid 6$, with an all-or-nothing dichotomy), and the statistic used is proven non-degenerate (it attains $\log 2$ on an explicit sample, and does so for the level-$5$ channel on the very same curve). This is what it means to seal a null.

### 9.3 Ramification as the locus of visibility

A structural theme runs through Sections 4 and 5. The residue-visible phenomena all sit at the *ramified* prime of the CM field: for $\mathbb{Q}(\sqrt{-3})$ the dial is sharpest at $9 = 3^2$ and $27 = 3^3$; for $\mathbb{Q}(i)$ the corresponding phenomena sit at powers of $2$. Ramification shrinks the relevant conductor, so the Frobenius datum modulo a power of the ramified prime is pinned by a small modulus. At good (unramified) primes of the CM field, the same datum is not pinned — Theorem 4.6 is a concrete witness. One should therefore expect residue-class visibility of CM Frobenius data to be a *ramified* phenomenon in general.

### 9.4 Scope and limitations

The classification of the silent set (Theorem 6.5) is proved for $E_0$; the curve-uniform statement of Theorem 6.7 gives one inclusion in general (torsion $\Rightarrow$ silence) but not the converse for arbitrary $E/\mathbb{Q}$. The split-half invisibility is established by explicit counterexample at modulus $9$ rather than for all moduli. The dilution law is a theorem of finite-sample statistics and carries no arithmetic hypotheses; its application to a given experiment requires that the auxiliary event genuinely be class-independent and disjoint, which must be checked case by case.

---

## 10. Future directions

**C1′ (curve-uniform silent set).** For $E_0$ the silent set is exactly the divisor set of $6$, i.e. of the rational torsion order. Is it true for every $E/\mathbb{Q}$ that $\{\ell : \ell \mid \#E(\mathbb{F}_p) \text{ for all good } p\}$ equals the divisor set of $\#E(\mathbb{Q})_{\mathrm{tors}}$? One inclusion is Theorem 6.7 whenever the torsion translation acts freely; the converse requires producing, for each $\ell$ not dividing the torsion order, a single good prime whose order avoids $\ell$ — plausibly an effective Chebotarev statement about the mod-$\ell$ representation.

**C2′ (split-half dials).** Theorem 4.6 rules out a modulus-$9$ dial on the split half. Is there any modulus $m$ and level $\ell$ for which the split-half event $\ell \mid \#E_0(\mathbb{F}_p)$ is a function of $p \bmod m$? The classical parameterisation $4p = L^2 + 27M^2$ suggests not, and a proof should follow from equidistribution of $(L, M)$ in congruence classes.

**C3′ (dilution in higher-arity channels).** The union-dilution law treats a binary event and a single class-blind admixture. What is the analogous sharp statement for a union of $r$ mutually disjoint class-blind events, or for a non-binary observable measured by an $r$-ary correlation ratio? Monotonicity in total admixed mass (Theorem 7.2) suggests a clean generalisation.

**C4′ (torsion-silence for general algebraic groups).** Theorem 6.7 is stated for point sets with a free order-$n$ self-map. The same argument applies verbatim to any family of finite sets with such a structure — Jacobians of higher genus, algebraic tori, class groups with a distinguished element of known order. Which known factoring or discrete-log heuristics are silent for exactly this reason?

**C5′ (quantifying the non-silent levels).** The dichotomy of Theorem 6.6 says any $\ell \nmid 6$ is fully informative on a suitably chosen two-prime sample. The natural quantitative refinement asks for the large-sample behaviour: for a random good prime, what is the mutual information between $p \bmod m$ and $[\ell \mid \#E_0(\mathbb{F}_p)]$? On the inert half Theorem 4.4 answers this exactly (the event is a residue condition, so the information is that of the induced partition); on the split half the answer should be governed by the CM Sato–Tate / Hecke-character equidistribution, and the union-dilution law predicts how the two halves combine.

**C6′ (the ramification principle).** Formulate and prove a general statement of the form: for a CM elliptic curve with CM field $K$, the Frobenius trace $a_p$ modulo $\lambda^k$ is a function of $p$ modulo a small modulus precisely when $\lambda$ ramifies in $K$. The two curves treated here are the class-number-one cases; the higher class-number CM curves over number fields would test the principle properly.

---

## Appendix A. Reference values

| $p$ | $p \bmod 3$ | $\#E_0(\mathbb{F}_p)$ | $a_p$ | $p \bmod 4$ | $\#E_{1728}(\mathbb{F}_p)$ | $a_p$ |
|---|---|---|---|---|---|---|
| $5$ | $2$ (inert) | $6$ | $0$ | $1$ (split) | $4$ | $2$ |
| $7$ | $1$ (split) | $12$ | $-4$ | $3$ (inert) | $8$ | $0$ |
| $11$ | $2$ (inert) | $12$ | $0$ | $3$ (inert) | $12$ | $0$ |
| $13$ | $1$ (split) | $12$ | $2$ | $1$ (split) | $20$ | $-6$ |
| $17$ | $2$ (inert) | $18$ | $0$ | $1$ (split) | $16$ | $2$ |
| $19$ | $1$ (split) | $12$ | $8$ | $3$ (inert) | $20$ | $0$ |
| $23$ | $2$ (inert) | $24$ | $0$ | $3$ (inert) | $24$ | $0$ |
| $29$ | $2$ (inert) | $30$ | $0$ | $1$ (split) | $20$ | $10$ |
| $31$ | $1$ (split) | $36$ | $-4$ | $3$ (inert) | $32$ | $0$ |

Every entry of the $\#E_0$ column is divisible by $6$ (Theorem 3.7); every inert row has $a_p = 0$ and no split row does (Theorems 4.1, 4.2, 5.1, 5.2); the pair $(13, 31)$ realises Theorem 4.6.
