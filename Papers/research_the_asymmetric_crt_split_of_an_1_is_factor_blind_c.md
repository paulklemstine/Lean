# The Asymmetric CRT Split of $a^{N-1} \bmod N$ Is Factor-Blind: An Exact Collapse Theorem

**Author:** Aristotle

**Date:** 2026-08-12

---

## Abstract

For a semiprime $N = pq$ with distinct primes $p, q$, the quantity $Q(a) = a^{N-1} \bmod N$ is computable in $O(\log N)$ modular multiplications from $N$ alone. We show that $Q$ possesses a genuinely **asymmetric** Chinese-Remainder description — $Q(a) \equiv a^{q-1} \pmod p$ and $Q(a) \equiv a^{p-1} \pmod q$, so that each coordinate is governed by the *other* prime's Fermat exponent — and we then prove, in four independent ways, that this asymmetry carries no exploitable information about the factorisation.

First (the *component-reading barrier*), any procedure that isolates one CRT coordinate of $Q$ as a residue vanishing in the other coordinate yields a prime factor of $N$ by a single gcd evaluated at the base $a = 1$: reading a coordinate is not a step toward factoring, it *is* factoring. We situate this inside a general splitting lemma from which the idempotent split and Rabin's square-root split both follow.

Second (the *Euler-gap collapse*), every multiplicative consequence of $Q$ factors through the single invariant $g = \gcd(p-1, q-1)$. We prove that $u^{N-1} = 1 \iff u^{g} = 1$ for all units $u$ mod $N$; that the Fermat liars number exactly $g^2$ and form a group isomorphic to $(\mathbb{Z}/g)^2$; that the image of the $(N-1)$-power endomorphism has size $\varphi(N)/g^2$; and that this endomorphism is bijective iff $g = 1$. Consequently semiprimes with equal Euler gap have isomorphic liar structure — $33 = 3 \cdot 11$ and $35 = 5\cdot 7$ are indistinguishable — and no isomorphism-invariant statistic of the power surface can separate them.

Third (the *reveal density law*), the gcd variant $\gcd(a^{N-1}-1, N)$ returns a proper factor for exactly $g(q-1) + g(p-1) - 2g^2$ of the $\varphi(N)$ admissible bases, a fraction $\approx g/p + g/q$, degenerating to $(p-1)+(q-1)-2$ when $g = 1$. The only usable handle therefore reduces to the smoothness of $p-1$ and $q-1$.

Fourth (the *hint contrast*), we exhibit Euler's totient as a hint of the same apparent cost that is *not* factor-blind: $N$ together with $\varphi(N)$ determines $p$ and $q$ in closed form. This delimits the boundary the present result sits on.

Numerically, an experiment over eighty near-equal-factor semiprimes near $10^7$ found the correlations of $Q$ with $p$, $q$, $p+q$ and $|p-q|$ all inside a $300$-shuffle permutation null (observed $\le 0.19$, $95$th percentile $\approx 0.22$) for bases $a \in \{2,3,5\}$. The theory explains exactly why.

**Keywords:** integer factorisation, Chinese Remainder Theorem, Fermat's little theorem, Euler gap, Fermat liars, RSA, idempotents, Rabin split.

---

## 1. Introduction

### 1.1 The search for a cheap factor-dependent quantity

The security of RSA rests on the presumed hardness of recovering $p$ and $q$ from $N = pq$. Any classical attack must, at some stage, compute a quantity from $N$ that depends on $p$ and $q$ separately in a way that can be read out. Let us call a function $F$ of $N$ (and possibly of auxiliary public inputs such as a base $a$) a **hint** if it is computable in $\mathrm{poly}(\log N)$ time without the factorisation, and say the hint **carries signal** if the factorisation can be recovered in randomised polynomial time from $(N, F)$.

Euler's totient is a hint that carries signal (Section 6). Most cheap arithmetic quantities are hints that do not. The interest of the present work is a candidate whose *internal structure* is unusually promising, and the sharp identification of the reason it nevertheless fails.

### 1.2 The candidate

Fix a semiprime $N = pq$ with $p \ne q$ prime, and set

$$Q(a) \;=\; a^{\,N-1} \bmod N .$$

This is the quantity computed by the Fermat primality test. It is defined from $N$ alone; it costs $O(\log N)$ modular multiplications by binary exponentiation (Section 7); it requires no aggregation over many bases; and no knowledge of $p$ or $q$ enters its computation.

The exponent $N - 1 = pq - 1$ is symmetric in $p$ and $q$. Yet the arithmetic identity

$$pq - 1 \;=\; (p-1)q + (q-1) \tag{1.1}$$

is *not* symmetric, and reading it both ways produces the asymmetric CRT description that motivates everything below. This is the phenomenon we analyse.

### 1.3 Results and organisation

Section 2 fixes notation and proves the asymmetric split with its uniqueness. Section 3 proves the component-reading barrier and its general splitting engine. Section 4 proves the Euler-gap collapse and the structure of the liar group. Section 5 proves the exact reveal-density law for the gcd variant. Section 6 contrasts with the totient hint and gives a concrete factor-blindness instance. Section 7 records the cost analysis. Section 8 reports the numerical evidence. Sections 9–10 discuss barriers and open problems.

---

## 2. The asymmetric CRT split

### 2.1 Setting and notation

Throughout, $p$ and $q$ denote distinct primes, $N = pq$, and $\varphi$ is Euler's totient, so $\varphi(N) = (p-1)(q-1)$. We write $(\mathbb{Z}/N)^\times$ for the unit group, $a \equiv b \ [\mathrm{mod}\ m]$ for congruence, $\mathrm{ord}_p(a)$ for the multiplicative order of $a$ modulo $p$, and

$$Q(a) := a^{\,N-1} \bmod N \in \{0, 1, \dots, N-1\}.$$

The **Euler gap** of $N = pq$ is

$$g := \gcd(p-1,\, q-1).$$

We freely use the Chinese Remainder Theorem in its ring form: since $\gcd(p,q)=1$, reduction induces an isomorphism $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$, restricting to a group isomorphism $(\mathbb{Z}/N)^\times \cong (\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$. We refer to the two components of an element as its *left* ($\bmod\ p$) and *right* ($\bmod\ q$) **CRT coordinates**.

### 2.2 The exponent identity

**Lemma 2.1 (Asymmetric exponent split).** *For positive integers $p, q$,*
$$pq - 1 \;=\; (p-1)q + (q-1).$$

*Proof.* $(p-1)q = pq - q$, and $q \le pq$ since $p \ge 1$, so the right-hand side equals $pq - q + q - 1 = pq - 1$. $\square$

The point of Lemma 2.1 is not its difficulty but its *orientation*. Exchanging the roles of $p$ and $q$ gives the equally valid $pq - 1 = (q-1)p + (p-1)$. The same symmetric number admits two inequivalent decompositions, and each one is adapted to reduction modulo a different prime.

### 2.3 The split

**Lemma 2.2 (Fermat).** *If $p$ is prime and $\gcd(a,p) = 1$ then $a^{p-1} \equiv 1 \pmod p$.*

**Theorem 2.3 (Asymmetric CRT split).** *Let $p$ be prime, $q \ge 1$, and $\gcd(a, p) = 1$. Then*
$$a^{\,pq-1} \equiv a^{\,q-1} \pmod p.$$
*Symmetrically, if $q$ is prime, $p \ge 1$ and $\gcd(a,q) = 1$, then $a^{pq-1} \equiv a^{p-1} \pmod q$.*

*Proof.* By Lemma 2.1,
$$a^{pq-1} = a^{(p-1)q + (q-1)} = \left(a^{p-1}\right)^{q} \cdot a^{q-1} \equiv 1^{q} \cdot a^{q-1} = a^{q-1} \pmod p,$$
using Lemma 2.2. The second statement is the first with $p$ and $q$ interchanged, using $pq = qp$. $\square$

**Corollary 2.4.** *For $N = pq$ with $p, q$ distinct primes and $\gcd(a,N)=1$,*
$$Q(a) \bmod p = a^{\,q-1} \bmod p, \qquad Q(a) \bmod q = a^{\,p-1} \bmod q.$$

*Proof.* Since $p \mid N$, reducing $Q(a) = a^{N-1} \bmod N$ further modulo $p$ gives $a^{N-1} \bmod p$; now apply Theorem 2.3. Likewise for $q$. $\square$

Corollary 2.4 is the structural content: the left CRT coordinate of $Q$ is controlled by $q$, the right by $p$. Each coordinate "knows" the prime it is not reduced against.

### 2.4 Exactness

The split is not merely a pair of congruences that $Q$ happens to satisfy; it determines $Q$ completely.

**Theorem 2.5 (CRT exactness).** *Let $p \ne q$ be primes, $\gcd(a, pq) = 1$, and let $x < pq$ satisfy*
$$x \equiv a^{\,q-1} \pmod p \quad\text{and}\quad x \equiv a^{\,p-1} \pmod q.$$
*Then $x = Q(a)$.*

*Proof.* By Theorem 2.3, $x \equiv a^{pq-1} \pmod p$ and $x \equiv a^{pq-1} \pmod q$. Since $\gcd(p,q) = 1$, the two congruences combine to $x \equiv a^{pq-1} \pmod{pq}$. As $0 \le x < pq$, $x$ is the least residue, i.e. $x = a^{pq-1} \bmod pq = Q(a)$. $\square$

This is the exhaustive form of the experimentally observed statement "the asymmetric decomposition is exact", verified there on twenty-four $(p,q,a)$ triples; Theorem 2.5 establishes it for all of them.

### 2.5 The exponent gcd collapse

The first warning that the asymmetry may be less informative than it looks comes from the following.

**Theorem 2.6 (Exponent gcd collapse).** *For positive $p, q$,*
$$\gcd(pq-1,\; p-1) \;=\; \gcd(q-1,\; p-1), \qquad \gcd(pq-1,\; q-1) \;=\; \gcd(p-1,\; q-1).$$
*In particular both equal the Euler gap $g$, so $\gcd(N-1, p-1) = \gcd(N-1, q-1)$.*

*Proof.* By Lemma 2.1, $pq - 1 = (q-1) + (p-1)q$, and $\gcd(m + k n, n) = \gcd(m, n)$; take $m = q-1$, $k = q$, $n = p-1$. The second identity follows by exchanging $p$ and $q$, and the two right-hand sides agree by symmetry of the gcd. $\square$

So although $N-1$ *reduces* to $q-1$ modulo $p$ and to $p-1$ modulo $q$, the divisibility content it retains against either prime is the same number $g$. This is the seed of the collapse proved in Section 4.

---

## 3. Barrier: reading a CRT coordinate is factoring

### 3.1 A gcd extraction lemma

**Lemma 3.1.** *Let $r$ be prime, $d \mid m$, and $r \nmid m$. Then $\gcd(m,\, dr) = d$.*

*Proof.* Since $r$ is prime and $r \nmid m$, we have $\gcd(r, m) = 1$, so $r$ may be cancelled from the second argument: $\gcd(m, rd) = \gcd(m, d)$. As $d \mid m$, this is $d$. $\square$

### 3.2 The idempotent is the factorisation

Call $e \in \mathbb{Z}$ a **CRT idempotent** for $(p,q)$ if $e \equiv 1 \pmod p$ and $e \equiv 0 \pmod q$. (Its image in $\mathbb{Z}/N$ satisfies $e^2 = e$, whence the name.)

**Theorem 3.2 (Idempotent $\Rightarrow$ factor).** *If $p$ is prime, $e \equiv 1 \pmod p$ and $e \equiv 0 \pmod q$, then*
$$\gcd(e,\, pq) = q.$$

*Proof.* From $e \equiv 0 \pmod q$ we get $q \mid e$. If $p \mid e$ then $e \equiv 0 \pmod p$, which combined with $e \equiv 1 \pmod p$ gives $1 \equiv 0 \pmod p$, i.e. $p \mid 1$, contradicting $p > 1$. So $p \nmid e$, and Lemma 3.1 with $m = e$, $d = q$, $r = p$ gives $\gcd(e, qp) = q$. $\square$

**Theorem 3.3 (Factor $\Rightarrow$ idempotent).** *If $p \ne q$ are primes, a CRT idempotent exists: there is $e$ with $e \equiv 1 \pmod p$, $e \equiv 0 \pmod q$.*

*Proof.* $\gcd(p,q) = 1$, so the Chinese Remainder Theorem produces a simultaneous solution of the two congruences. $\square$

**Corollary 3.4 (Equivalence).** *For $N = pq$ with distinct prime factors, producing a CRT idempotent and producing the factor $q$ are interchangeable tasks: idempotents exist, and every one of them yields $q$ by a single gcd.*

### 3.3 The component-reading barrier

We now state the barrier in the form that applies directly to $Q$. A **component reader** for $Q$ is a function $s : \mathbb{N} \to \mathbb{N}$ such that, for every base $a$,

$$s(a) \equiv a^{\,q-1} \pmod p \qquad\text{and}\qquad s(a) \equiv 0 \pmod q .$$

The first condition says $s(a)$ reproduces the left CRT coordinate of $Q(a)$ (by Corollary 2.4); the second says $s$ has *isolated* that coordinate, i.e. discarded the right one. This is exactly the object one would need in order to exploit the asymmetry: a way to hold $a^{q-1} \bmod p$ in one's hand.

**Theorem 3.5 (Component-reading barrier).** *Let $p$ be prime and let $s$ be a component reader. Then*
$$\gcd\big(s(1),\; pq\big) \;=\; q .$$
*A single evaluation at the base $a = 1$, followed by one gcd, returns a prime factor of $N$.*

*Proof.* At $a = 1$ the first condition gives $s(1) \equiv 1^{q-1} = 1 \pmod p$, and the second gives $s(1) \equiv 0 \pmod q$. So $s(1)$ is a CRT idempotent, and Theorem 3.2 applies. $\square$

**Remark 3.6.** Theorem 3.5 is deliberately generous to the adversary. It assumes nothing about how $s$ is computed, allows $s$ to be an arbitrary oracle, and needs only one query — at the *trivial* base. No approximation, no restriction to "most" bases, and no computational assumption is involved: coordinate isolation and factorisation are the same object. The asymmetry established in Section 2 is therefore real but sealed: the only container it lives in is the CRT decomposition, and the decomposition is the secret.

**Remark 3.7 (What is *not* claimed).** Theorem 3.5 does not assert that no polynomial-time factoring algorithm exists, nor that no other feature of $Q$ can leak. It asserts precisely that the *specific* route suggested by the asymmetry — isolate a coordinate, then read off the other prime's exponent — is circular.

### 3.4 The general splitting engine

The barrier above is one instance of a single mechanism, which we isolate because two classical factoring splits are the other instances.

**Theorem 3.8 (Splitting lemma).** *Let $p \ne q$ be primes and $N = pq$. Let $u, v \in \mathbb{Z}$ satisfy:*
1. $N \mid uv$;
2. $N \nmid u$ and $N \nmid v$;
3. *no prime of $N$ divides both $u$ and $v$: it is not the case that $p \mid u$ and $p \mid v$, nor that $q \mid u$ and $q\mid v$.*

*Then $\gcd(|u|, N) \in \{p, q\}$.*

*Proof.* From $N \mid uv$ we get $p \mid uv$ and $q \mid uv$; since $p, q$ are prime, $p$ divides $u$ or $v$, and likewise $q$. Four cases.

- $p \mid u$ and $q \mid u$: then, since $\gcd(p,q)=1$, $N \mid u$, contradicting (2).
- $p \mid v$ and $q \mid v$: then $N \mid v$, contradicting (2).
- $p \mid u$ and $q \mid v$: then $q \nmid u$, for otherwise $q$ would divide both $u$ and $v$, violating (3). Lemma 3.1 with $m = |u|$, $d = p$, $r = q$ gives $\gcd(|u|, pq) = p$.
- $q \mid u$ and $p \mid v$: symmetrically $p \nmid u$ and $\gcd(|u|, qp) = q$. $\square$

**Corollary 3.9 (Nontrivial idempotents split).** *If $N \mid e(e-1)$ while $e \not\equiv 0$ and $e \not\equiv 1 \pmod N$, then $\gcd(|e|, N)$ is a prime factor of $N$.*

*Proof.* Apply Theorem 3.8 with $u = e$, $v = e-1$. Hypotheses (1) and (2) are immediate. For (3): if a prime $r \in \{p,q\}$ divided both $e$ and $e-1$, it would divide their difference $1$, impossible. $\square$

**Corollary 3.10 (Rabin's split).** *Let $p, q$ be distinct odd primes and let $x$ satisfy $x^2 \equiv 1 \pmod N$ with $x \not\equiv 1$ and $x \not\equiv -1 \pmod N$. Then $\gcd(|x-1|, N)$ is a prime factor of $N$.*

*Proof.* Apply Theorem 3.8 with $u = x-1$, $v = x+1$; then $uv = x^2 - 1$ is divisible by $N$, and neither factor is, by hypothesis. For (3): if an odd prime $r \in \{p,q\}$ divided both $x-1$ and $x+1$, it would divide $(x+1)-(x-1) = 2$, so $r \in \{1,2\}$ — impossible for an odd prime. $\square$

Corollary 3.10 identifies the exact point at which the Miller–Rabin test crosses from *certifying compositeness* to *factoring*: the discovery of a nontrivial square root of $1$. That discovery, like coordinate reading, is an oracle for the CRT split. Every road out of Section 2's asymmetry passes through the same gate.

---

## 4. The Euler-gap collapse

Section 3 blocks the structural route. This section blocks the statistical one, by showing that the entire multiplicative behaviour of $Q$ is a function of the single invariant $g$.

### 4.1 A group-theoretic reduction

**Lemma 4.1.** *Let $G$ be a finite group, $x \in G$, and $n, m \in \mathbb{N}$ with $\gcd(n, |G|) = \gcd(m, |G|)$. Then $x^n = 1 \iff x^m = 1$.*

*Proof.* Suppose $x^n = 1$. Then $\mathrm{ord}(x) \mid n$, and always $\mathrm{ord}(x) \mid |G|$, so $\mathrm{ord}(x) \mid \gcd(n, |G|) = \gcd(m,|G|) \mid m$, whence $x^m = 1$. The converse is symmetric. $\square$

### 4.2 The Fermat test is the Euler-gap test

**Theorem 4.2 (Coordinatewise collapse).** *Let $p$ be prime and $q \ge 1$. For every $x \in (\mathbb{Z}/p)^\times$,*
$$x^{\,pq-1} = 1 \iff x^{\,g} = 1, \qquad g = \gcd(p-1, q-1).$$
*Symmetrically for $y \in (\mathbb{Z}/q)^\times$ with $q$ prime.*

*Proof.* $|(\mathbb{Z}/p)^\times| = p-1$. By Theorem 2.6, $\gcd(pq-1, p-1) = \gcd(q-1, p-1) = g$, and $\gcd(g, p-1) = g$ because $g \mid p-1$. So the two exponents have equal gcd with the group order, and Lemma 4.1 applies. $\square$

**Theorem 4.3 (Fermat test $=$ Euler-gap test).** *Let $p \ne q$ be primes, $N = pq$. For every unit $u \in (\mathbb{Z}/N)^\times$,*
$$u^{\,N-1} = 1 \iff u^{\,g} = 1 .$$

*Proof.* Under the CRT isomorphism $(\mathbb{Z}/N)^\times \cong (\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$, a power identity holds iff it holds in both coordinates. Apply Theorem 4.2 in each. $\square$

Thus the Fermat test modulo a semiprime does not test the exponent $N-1$ at all; it tests the exponent $g$. All factor-dependence of the exponent has collapsed onto one number.

### 4.3 Counting and structure of the liars

Call $u \in (\mathbb{Z}/N)^\times$ a **Fermat liar** if $u^{N-1} = 1$. The liars form a subgroup $L$, the kernel of the endomorphism $\pi : u \mapsto u^{N-1}$.

**Lemma 4.4.** *For $r$ prime and any $n$, the number of $x \in (\mathbb{Z}/r)^\times$ with $x^n = 1$ is $\gcd(r-1, n)$.*

*Proof.* $(\mathbb{Z}/r)^\times$ is cyclic of order $r-1$; in a cyclic group of order $m$ the $n$-th power map has kernel of size $\gcd(m,n)$. $\square$

**Theorem 4.5 (Liar count).** *For distinct primes $p, q$ and $N = pq$, $|L| = g^2$.*

*Proof.* Via CRT, $L$ corresponds to the set of pairs $(x,y)$ with $x^{N-1} = 1$ and $y^{N-1} = 1$, a product set. By Lemma 4.4 and Theorem 2.6, the two factors have sizes $\gcd(p-1, N-1) = g$ and $\gcd(q-1, N-1) = g$. Hence $|L| = g \cdot g = g^2$. $\square$

**Theorem 4.6 (Liar group structure).** *$L \cong \mathbb{Z}/g \times \mathbb{Z}/g$ (written multiplicatively).*

*Proof.* The CRT isomorphism carries $L$ onto $K_p \times K_q$, where $K_p \le (\mathbb{Z}/p)^\times$ and $K_q \le (\mathbb{Z}/q)^\times$ are the respective kernels of the $(N-1)$-power maps. Each of $K_p, K_q$ is a subgroup of a cyclic group, hence cyclic, and each has order $g$ by the computation in Theorem 4.5. A cyclic group of order $g$ is isomorphic to $\mathbb{Z}/g$. $\square$

Theorem 4.6 is the structural form of factor-blindness: the isomorphism type of the liar group is determined by $g$ alone, with no further trace of $p$ or $q$.

**Corollary 4.7 (Indistinguishability).** *If $N = pq$ and $N' = p'q'$ are semiprimes with distinct prime factors and $\gcd(p-1,q-1) = \gcd(p'-1,q'-1)$, then their Fermat-liar groups are isomorphic. Consequently no isomorphism-invariant statistic of the liar group distinguishes $N$ from $N'$.*

**Example 4.8.** $N = 33 = 3\cdot 11$ has $g = \gcd(2,10) = 2$; $N' = 35 = 5\cdot 7$ has $g = \gcd(4,6) = 2$. The liar groups are both $\cong \mathbb{Z}/2 \times \mathbb{Z}/2$, and both have exactly $4$ liars, despite the two factorisations sharing no prime.

### 4.4 Density, witnesses, and the image

**Theorem 4.9 (Gap bound).** *For distinct primes $p, q$, $\;2g^2 \le (p-1)(q-1) = \varphi(N)$.*

*Proof.* Assume without loss of generality $p < q$. Then $g \mid p-1$ gives $g \le p-1$. Also $g \mid q-1$; if $g = q-1$ then $q - 1 \le p-1$, contradicting $p<q$, so $g$ is a proper divisor of $q-1$, whence $q-1 = cg$ with $c \ge 2$ and $2g \le q-1$. Multiplying, $2g^2 = (2g)\cdot g \le (q-1)(p-1)$. $\square$

**Corollary 4.10 (Liar density at most one half).** *$2|L| \le |(\mathbb{Z}/N)^\times|$: at most half of the units are Fermat liars, so a uniformly random base detects the compositeness of a semiprime with probability at least $1/2$.*

*Proof.* Combine Theorems 4.5 and 4.9 with $|(\mathbb{Z}/N)^\times| = \varphi(N) = (p-1)(q-1)$. $\square$

**Corollary 4.11 (No semiprime Carmichael numbers).** *For distinct primes $p,q$ there exists a unit $u$ mod $N = pq$ with $u^{N-1} \ne 1$.*

*Proof.* If every unit were a liar, $|L| = \varphi(N) > 0$, and Corollary 4.10 would give $2\varphi(N) \le \varphi(N)$, absurd. $\square$

**Theorem 4.12 (Image of the power map).** *$g^2 \cdot |\mathrm{im}\,\pi| = \varphi(N)$, i.e. $|\mathrm{im}\,\pi| = \varphi(N)/g^2$.*

*Proof.* First isomorphism theorem: $|\ker \pi| \cdot |\mathrm{im}\,\pi| = |(\mathbb{Z}/N)^\times|$, with $|\ker \pi| = |L| = g^2$. $\square$

**Theorem 4.13 (Bijectivity criterion).** *The map $u \mapsto u^{N-1}$ on $(\mathbb{Z}/N)^\times$ is bijective if and only if $g = 1$.*

*Proof.* The map is an endomorphism of a finite group, so it is bijective iff injective iff $|\ker| = 1$, i.e. $g^2 = 1$, i.e. $g = 1$. $\square$

---

## 5. The reveal-density law for the gcd variant

The one classical way in which $Q$ can betray a factor is the gcd variant $\gcd(a^{N-1}-1, N)$. We determine exactly how often it fires.

### 5.1 The firing criterion

**Theorem 5.1 (Arithmetic criterion).** *Let $p, q$ be primes, $a \ge 1$, $N = pq$.*
- *If $a^{N-1} \equiv 1 \pmod p$ but $a^{N-1} \not\equiv 1 \pmod q$, then $\gcd(a^{N-1}-1, N) = p$.*
- *If $a^{N-1} \equiv 1 \pmod q$ but $a^{N-1} \not\equiv 1 \pmod p$, then $\gcd(a^{N-1}-1, N) = q$.*
- *Otherwise the gcd is $1$ or $N$ and no factor is revealed.*

*Proof.* Write $M = a^{N-1} - 1 \ge 0$. The first hypothesis says $p \mid M$; the second says $q \nmid M$. Lemma 3.1 with $d = p$, $r = q$ gives $\gcd(M, pq) = p$. The second bullet is symmetric. $\square$

**Theorem 5.2 (Order form of the criterion).** *For $\gcd(a,p) = 1$, the congruence $a^{N-1} \equiv 1 \pmod p$ holds if and only if $\mathrm{ord}_p(a) \mid q-1$.*

*Proof.* By Theorem 2.3, $a^{N-1} \equiv a^{q-1} \pmod p$, so the congruence is $a^{q-1}\equiv 1 \pmod p$, which holds iff $\mathrm{ord}_p(a) \mid q-1$. $\square$

Theorem 5.2 is the precise sense in which the gcd variant "uses the other prime": the firing condition modulo $p$ is a divisibility condition on $q-1$. But as we now count, the resulting statistics again see only $g$.

### 5.2 The exact count

Work in $(\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$, identified with $(\mathbb{Z}/N)^\times$ by CRT. Let

$$A = \{(x,y) : x^{N-1} = 1\}, \qquad B = \{(x,y) : y^{N-1} = 1\}.$$

**Lemma 5.3.** $|A| = g\,(q-1)$ *and* $|B| = g\,(p-1)$ *and* $|A \cap B| = g^2$.

*Proof.* $A$ is a product: the constraint applies only to the first coordinate, giving $\gcd(p-1, N-1) = g$ choices there (Lemma 4.4, Theorem 2.6), times $q-1$ free choices of $y$. Symmetrically for $B$. Finally $A \cap B$ is the liar set, of size $g^2$ (Theorem 4.5). $\square$

**Theorem 5.4 (Reveal-density law).** *The gcd variant $\gcd(a^{N-1}-1, N)$ returns a proper prime factor of $N$ for exactly*
$$R \;=\; g(q-1) + g(p-1) - 2g^2$$
*of the $\varphi(N) = (p-1)(q-1)$ bases coprime to $N$.*

*Proof.* By Theorem 5.1 a base reveals a factor precisely when it lies in the symmetric difference $A \triangle B$. Now $|A \setminus B| = |A| - |A\cap B| = g(q-1) - g^2$ and $|B\setminus A| = g(p-1) - g^2$; add. $\square$

**Corollary 5.5 (Density).** *The reveal probability for a uniformly random unit is*
$$\frac{R}{\varphi(N)} \;=\; \frac{g}{p-1} + \frac{g}{q-1} - \frac{2g^2}{\varphi(N)} \;\approx\; \frac{g}{p} + \frac{g}{q},$$
*matching the measured law. In particular the density is a function of $(p,q)$ through $g$ and the sizes alone.*

**Corollary 5.6 (Trivial gap).** *If $g = 1$ then exactly $R = (p-1) + (q-1) - 2$ bases reveal a factor, a probability of order $1/p + 1/q$ — cryptographically negligible for primes of cryptographic size.*

The interpretation is decisive. The gcd variant is useful only when $g$ is large, i.e. when $p-1$ and $q-1$ share a large common divisor. This is a smoothness/structure condition on $p-1$ and $q-1$, exactly the condition already exploited by Pollard's $p-1$ method and already defended against by strong-prime generation. The asymmetric split contributes nothing beyond it.

---

## 6. A hint that does carry signal: the totient

To locate the present result on the map of hints, we exhibit a quantity of comparable superficial cost that is emphatically *not* factor-blind.

**Lemma 6.1.** *For $p, q \ge 2$, $\;N + 1 - \varphi(N) = p + q$, where $N = pq$.*

*Proof.* $\varphi(N) = (p-1)(q-1) = pq - p - q + 1$, so $N + 1 - \varphi(N) = pq + 1 - pq + p + q - 1 = p+q$. $\square$

**Lemma 6.2.** *If $q < p$ then $(p+q)^2 - 4pq = (p-q)^2$.*

*Proof.* $(p+q)^2 - 4pq = p^2 + 2pq + q^2 - 4pq = (p-q)^2$. $\square$

**Theorem 6.3 (The totient factors $N$).** *Let $N = pq$ with $2 \le q < p$ prime, and set $s = N + 1 - \varphi(N)$. Then*
$$p = \frac{s + \sqrt{s^2 - 4N}}{2}, \qquad q = \frac{s - \sqrt{s^2 - 4N}}{2}.$$

*Proof.* By Lemma 6.1, $s = p+q$; by Lemma 6.2, $s^2 - 4N = (p-q)^2$, so $\sqrt{s^2-4N} = p - q$. Then $(s + (p-q))/2 = ((p+q)+(p-q))/2 = p$ and $(s - (p-q))/2 = q$. $\square$

Theorem 6.3 requires no gcd, no randomness, and no search: it is a closed formula. The contrast is the point. $\varphi(N)$ and $Q(a)$ both *look* like single cheap numbers attached to $N$. One of them determines the factorisation outright; the other, as Sections 3–5 show, determines nothing beyond $(N, g)$. The distinction is not cost but *what the quantity is a function of*.

---

## 7. Cost

For completeness we record that $Q$ is genuinely cheap, since the whole interest of the candidate depends on it.

Define binary exponentiation recursively by $\mathrm{powMod}(m,a,0) = 1 \bmod m$ and, for $n \ge 1$, $h = \mathrm{powMod}(m,a,\lfloor n/2\rfloor)$, with output $h^2 \bmod m$ if $n$ is even and $h^2 (a \bmod m) \bmod m$ if $n$ is odd.

**Theorem 7.1 (Correctness).** *$\mathrm{powMod}(m,a,n) = a^n \bmod m$ for all $m, a, n$.*

*Proof.* Strong induction on $n$. For $n = 0$ both sides are $1 \bmod m$. For $n \ge 1$ let $k = \lfloor n/2 \rfloor$; by induction $h = a^{k} \bmod m$. If $n$ is even, $n = 2k$ and $a^n = a^k a^k$, so $a^n \bmod m = (h\cdot h) \bmod m$ by multiplicativity of reduction. If $n$ is odd, $n = 2k+1$ and $a^n = a^k a^k a$, giving the odd branch. $\square$

**Theorem 7.2 (Logarithmic depth).** *The recursion depth of $\mathrm{powMod}(m,a,n)$ is at most the binary length of $n$.*

*Proof.* Strong induction. Depth $0$ for $n = 0$. For $n \ge 1$, $n < 2^{\ell}$ where $\ell$ is the binary length of $n$, hence $\lfloor n/2\rfloor < 2^{\ell - 1}$, so the binary length of $\lfloor n/2 \rfloor$ is at most $\ell - 1$; by induction its depth is at most $\ell - 1$, and one more call gives $\ell$. $\square$

**Corollary 7.3.** *$Q(a) = \mathrm{powMod}(N, a, N-1)$ is computed with $O(\log N)$ modular multiplications, using no knowledge of the factorisation and no aggregation over bases.*

---

## 8. Numerical evidence

Three families of measurements motivated and now corroborate the theory.

**(i) Exactness of the split.** For all $(p,q,a)$ with $p, q \le 19$ distinct primes and $a \in \{2,3,5\}$, the two congruences of Corollary 2.4 hold on the nose, and the residue $Q(a)$ is the unique one below $N$ realising them. Representative rows:

| $N = pq$ | $a$ | $Q(a) \bmod p$ | $a^{q-1} \bmod p$ | $Q(a) \bmod q$ | $a^{p-1} \bmod q$ |
|---|---|---|---|---|---|
| $15 = 3\cdot 5$ | $2$ | $1$ | $1$ | $4$ | $4$ |
| $21 = 3\cdot 7$ | $2$ | $1$ | $1$ | $4$ | $4$ |
| $33 = 3\cdot 11$ | $2$ | $1$ | $1$ | $4$ | $4$ |
| $35 = 5\cdot 7$ | $3$ | $4$ | $4$ | $4$ | $4$ |
| $91 = 7\cdot 13$ | $5$ | $1$ | $1$ | $12$ | $12$ |

**(ii) Liar counts against $g^2$.** Exhaustive enumeration confirms Theorem 4.5:

| $N$ | $p,q$ | $g$ | liars counted | $g^2$ |
|---|---|---|---|---|
| $15$ | $3,5$ | $2$ | $4$ | $4$ |
| $33$ | $3,11$ | $2$ | $4$ | $4$ |
| $35$ | $5,7$ | $2$ | $4$ | $4$ |
| $91$ | $7,13$ | $6$ | $36$ | $36$ |
| $143$ | $11,13$ | $2$ | $4$ | $4$ |

Note rows $33$ and $35$: different factorisations, equal $g$, equal liar counts, isomorphic liar groups (Example 4.8).

**(iii) Factor-blindness at scale.** Across eighty semiprimes near $10^7$ with near-equal factors — so that trivial size effects are removed — the sample correlations of $Q(a)$ with each of $p$, $q$, $p+q$ and $|p-q|$ were computed for $a \in \{2,3,5\}$ and compared against a permutation null built from $300$ shuffles. Every observed correlation fell inside the null band: observed magnitudes at most $0.19$ against a $95$th-percentile threshold of about $0.22$. As a residue modulo $N$, $Q(a)$ behaves pseudorandomly and carries no linear signal about the factors.

Result (iii) is the empirical shadow of the theory: by Theorem 3.5 the factor-dependence is confined to the CRT coordinates, and by Theorems 4.3–4.6 the only invariant visible from outside is $g$, which at near-equal factor sizes is typically small and uncorrelated with $p$, $q$, $p+q$ or $|p-q|$.

---

## 9. Discussion: the anatomy of a collapse

It is useful to name the three independent mechanisms by which this candidate fails, because they recur.

**(A) The container barrier.** The factor-dependence is real but confined to the CRT coordinates, and the coordinate projector is a CRT idempotent, which is equivalent to the factorisation (Theorems 3.2, 3.5, Corollary 3.4). This is unconditional and needs no complexity assumption. Any attack of the shape "extract the coordinate, then exploit the asymmetry" is circular by construction.

**(B) The invariant barrier.** Externally, $Q(a)$ is a residue mod $N$, hence a function of $(N,a)$ alone. Every multiplicative statistic derived from the power surface $\{(a, a^{N-1} \bmod N)\}$ factors through the liar group, whose isomorphism type is $(\mathbb{Z}/g)^2$ (Theorem 4.6). Semiprimes with equal Euler gap are therefore indistinguishable by such statistics (Corollary 4.7, Example 4.8).

**(C) The reduction barrier.** The single genuine leak — the gcd variant — has exact reveal count $g(q-1)+g(p-1)-2g^2$ (Theorem 5.4), a density $\approx g/p + g/q$. This is a $p-1$-smoothness handle, already known and already defended against.

Taken together, these constitute the sharpest instance we know of the principle *asymmetry without the split is invisible*: a quantity may depend genuinely and asymmetrically on both factors, and still yield nothing, because the dependence is expressed in a coordinate system whose construction is the secret.

There is a positive reading. The analysis converts a vague expectation ("this probably does not work") into exact arithmetic: an exact liar count, an exact liar group, an exact reveal count, an exact bijectivity criterion, and an unconditional equivalence between coordinate reading and factoring. A negative result with all constants determined is a usable map. In particular, Corollary 4.10 gives a clean self-contained proof that the Fermat test succeeds with probability at least $1/2$ on any semiprime with distinct factors, and Corollary 4.11 recovers the classical fact that Carmichael numbers require at least three prime factors, both as by-products of the collapse.

---

## 10. Future directions

The following conjectures are the natural next falsifiable steps.

### Conjecture 1 (Euler-gap sufficiency: the invariant barrier in exact form)

*Every* function of $N$ obtained from the power surface $\{(a, a^{N-1} \bmod N) : a \in (\mathbb{Z}/N)^\times\}$ that is invariant under multiplicative automorphisms of the unit group is a function of $(N, g)$ only.

*Key insight.* The whole surface is the endomorphism $u \mapsto u^{N-1}$, whose kernel is $(\mathbb{Z}/g)^2$ and whose image has size $\varphi(N)/g^2$ (Theorems 4.6, 4.12). An isomorphism-invariant statistic cannot see more than the isomorphism type.

*Why now.* The structural invariants are established; what remains is to formalise "isomorphism-invariant statistic" and derive the simulation argument. **Falsifiable:** exhibit an isomorphism-invariant statistic of the power surface separating $33 = 3\cdot 11$ from $35 = 5\cdot 7$, whose liar groups are proved isomorphic here.

### Conjecture 2 (The gap hint is a factoring hint)

Knowing $g = \gcd(p-1,q-1)$ together with $N$ yields the factorisation of $N$ in randomised polynomial time whenever $g > 1$.

*Key insight.* A random unit $u$ has $u^{(N-1)/g'}$ landing in the $g$-torsion for suitable $g' \mid g$, and $g$-torsion elements that are $1$ in exactly one CRT coordinate are precisely the nontrivial square roots and idempotents that Corollaries 3.9 and 3.10 turn into factors.

*Why now.* Both splitting corollaries are proved, and Theorem 5.4 gives the exact success count of the naive sampler; only the amplification step is open. **Falsifiable in either direction:** prove the sampling probability bound, or exhibit a family with $g > 1$ for which the induced distribution never leaves the diagonal.

### Conjecture 3 (Hint hierarchy)

Order cheap quantities attached to $N$ by whether they carry signal. Euler's totient sits at the top (Theorem 6.3, closed-form factorisation). The power surface sits at the bottom (Sections 3–5, function of $(N,g)$ only). The conjecture is that this is a genuine hierarchy with intermediate levels — quantities from which factoring is possible but only with super-polynomially many samples, or only for a density-zero set of $N$ — and that the level of a hint is determined by the smallest group-theoretic invariant it can express.

### Further directions

- **A barrier-4 proof.** Establish unconditionally that no uniform, hint-free classical statistic of bounded degree in the residues can distinguish semiprimes with equal Euler gap.
- **Quantum channel.** Quantum period-finding performs precisely the coordinate read that Theorem 3.5 forbids classically. Making that comparison precise — what resource replaces the idempotent — would clarify what the barrier is really measuring.
- **Hint amplification.** Given many weak hints (values $Q(a)$ for many $a$), is there an aggregation that escapes the $(N,g)$ ceiling? Section 4 suggests not for isomorphism-invariant aggregations; non-invariant aggregations remain unanalysed.

---

## 11. Conclusion

The quantity $Q(a) = a^{N-1} \bmod N$ is cheap, factorisation-free, and genuinely asymmetric: its CRT coordinates are $a^{q-1} \bmod p$ and $a^{p-1} \bmod q$, each governed by the prime it does not see, and these two coordinates determine $Q(a)$ uniquely. Nevertheless $Q$ is factor-blind. Reading a coordinate is unconditionally equivalent to factoring; every multiplicative statistic collapses onto the Euler gap $g = \gcd(p-1,q-1)$, so that semiprimes with equal gap have isomorphic Fermat-liar structure; and the gcd variant reveals a factor for exactly $g(q-1)+g(p-1)-2g^2$ bases, a density $\approx g/p+g/q$ that reduces to classical $p-1$ smoothness. Set against a hint that does carry signal — the totient, from which $p$ and $q$ follow in closed form — the boundary is sharp. Asymmetry without the split is invisible.
