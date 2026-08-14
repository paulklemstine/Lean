# The Higher-Power Reciprocity Channel Is Not a Residue Dial — and Buys Nothing

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $p$ be an unknown prime. A *residue dial* is a statistic of $p$ that is periodic — computable from $p \bmod M$ for a fixed modulus $M$ — and the quadratic residue channel is the archetype: quadratic residuacity of $2$ is decided by $p \bmod 8$, and the Legendre symbol at any fixed base is the reading of a periodic character of conductor $4|D|$. Periodicity makes a channel cheap to compute but caps its information content at $\log_2 M$ bits, so such a channel is either computable from a partial hint or informative, never both. Cubic and quartic residuacity are frequently proposed as an escape, on the grounds that cubic residuacity of $2$ is governed by the *non-congruence* condition $p = x^2 + 27y^2$.

We prove that the escape is real and that it is worthless. On the escape side: the cubic residuacity bit of $2$ is not computable from $p \bmod M$ for any $M$ dividing $720720 = \mathrm{lcm}(1,\dots,16)$, and this holds for *every* statistic valued in *any* type together with *any* decision rule, not merely for characters; explicit witnesses are the primes $43$ and $720763 = 43 + 720720$. The quartic bit fails likewise, witnessed by $137$ and $720857$. On the no-gain side: for every exponent $k$, a $K$-symbol residuacity fingerprint takes at most $2^K$ values, so separating $C$ candidates costs $K \ge \log_2 C$ symbols; the bound is exponent-independent and is *attained* at $K = 2$ by the cubic bits at bases $2, 3$ on the primes $\{7, 31, 61, 307\}$. Moreover, exactly $(p-1)/k$ of the $p-1$ units modulo $p$ are $k$-th powers, so the cubic bit is strictly sparser — hence individually less informative — than the quadratic bit. At a composite modulus $N = mn$ the residuacity predicate factors through the Chinese Remainder Theorem into a conjunction, hence is symmetric in the factors and cannot single one out. A hybrid pigeonhole bound shows that a hint $p \equiv r \pmod m$, $L$ dials of conductor lcm $M^*$, and $K$ higher-power bits leave at least $|\Omega|/\bigl((M^*/\gcd(M^*,m)) \cdot 2^K\bigr)$ indistinguishable candidates, the higher-power channel entering only through $2^K$. The conclusion is a closed accounting: the residue channel's information content is a dial part (determined by a small residue, hence hint-computable) plus fine-arithmetic noise (real, non-periodic, and reachable only through a computation presupposing $p$). Higher reciprocity adds no polynomial-time handle.

**Keywords:** cubic reciprocity, quartic reciprocity, power residue symbol, residuacity fingerprint, channel capacity, periodicity obstruction, Eisenstein integers.

---

## 1. Introduction

### 1.1 Dials, hints, and the shape of the question

Fix a large unknown prime $p$, or a semiprime $N = pq$ whose factors are unknown. A recurring question in computational number theory is whether classical arithmetic invariants leak usable information about the secret at polynomial cost in $\log N$. The paradigm of such an invariant is the quadratic residue symbol. For fixed $D \ne 0$ the map

$$p \longmapsto \left(\frac{D}{p}\right)$$

is, by quadratic reciprocity together with its supplements, a periodic function of $p$ with period dividing $4|D|$. We call such a periodic statistic a **residue dial**.

Periodicity is a double-edged property. On the one hand it is exactly what makes the symbol computable without knowing $p$ — the Jacobi symbol $\left(\frac{D}{N}\right)$ is computable in $O(\log^2 N)$ time by a Euclidean algorithm, no factorisation required. On the other hand a function of $p \bmod M$ can take at most $M$ values, so it distinguishes at most $M$ candidates and conveys at most $\log_2 M$ bits about the secret. In particular, if the attacker already possesses a hint $p \equiv r \pmod m$ from a side channel, the residual value of the dial collapses by a factor $\gcd(M, m)$. This is the *dial–threshold dichotomy*: a dial is either simulable from the hint or informative, but the two regimes are separated by an inequality involving only $M$ and $m$, never by anything about $p$ itself.

The natural attempt to break out of the dichotomy is to move up the reciprocity tower. Cubic reciprocity lives in the ring of Eisenstein integers $\mathbb{Z}[\omega]$, $\omega = e^{2\pi i/3}$; quartic reciprocity lives in the Gaussian integers $\mathbb{Z}[i]$. Their symbols take values in $\mu_3$ and $\mu_4$ respectively, are strictly finer objects than the Legendre symbol, and — crucially — their supplements are visibly *not* congruence conditions. Gauss's criterion for the cubic residuacity of $2$ at a prime $p \equiv 1 \pmod 3$ is

$$2 \text{ is a cube modulo } p \iff p = x^2 + 27y^2 \quad \text{for some } x, y \in \mathbb{Z},$$

equivalently $4p = A^2 + 27B^2$ with $A, B$ both even. This is a *splitting* condition in the non-normal cubic field $\mathbb{Q}(\sqrt[3]{2})$, whose Galois closure $\mathbb{Q}(\sqrt[3]{2}, \omega)$ has Galois group $S_3$. Class field theory identifies congruence-describable splitting sets with abelian extensions; an $S_3$-condition therefore has no chance of being periodic. So the higher-power channel really does leave the dial world.

The question this paper settles is whether leaving the dial world is *worth* anything to a computationally bounded observer.

### 1.2 Results

We prove four groups of statements.

**(A) The quadratic channel is a dial, exactly.** Quadratic residuacity of $2$ at an odd prime is decided by $p \bmod 8$; equivalently, there is an explicit periodic statistic of conductor $8$ whose reading is the quadratic bit. For every nonzero base the Legendre symbol coincides with a periodic character of conductor $4|D|$.

**(B) The cubic and quartic channels escape, absolutely.** For every $M$ dividing $720720 = \mathrm{lcm}(1,\dots,16)$ there exist two primes $\equiv 1 \pmod 3$ that are congruent modulo $M$ and have opposite cubic bits at base $2$ — namely $43$ and $720763$. Consequently no statistic depending on $p$ only through $p \bmod M$, valued in any type, composed with any decision rule, decides the cubic bit. The quartic analogue holds with $137$ and $720857$.

**(C) Escape does not raise capacity.** For every exponent $k$ and every choice of $K$ bases, the residuacity fingerprint (the vector of $K$ residuacity bits) takes at most $2^K$ values on any candidate set; hence separating $C$ candidates forces $K \ge \log_2 C$. The bound is attained at $K = 2$. Furthermore exactly $(p-1)/k$ units are $k$-th powers, so the cubic bit is sparser than the quadratic bit; and at a composite modulus the residuacity predicate is symmetric in the factors.

**(D) Hybrid no-amplification.** Hint plus dials plus higher-power bits, used jointly, still leave a large indistinguishable class, with the higher-power channel contributing only a factor $2^K$.

Section 2 fixes definitions. Section 3 proves (A). Section 4 constructs the escape witnesses and proves (B). Section 5 proves the capacity results (C), including sharpness and sparsity. Section 6 proves (D). Section 7 explains the circularity accounting and reconciles it with the numerical experiment that motivated the work. Section 8 discusses consequences and open problems.

---

## 2. Definitions and basic apparatus

Throughout, $p$ denotes a prime and $\mathbb{Z}/N$ the ring of residues modulo $N$, with unit group $(\mathbb{Z}/N)^\times$.

**Definition 2.1 (Power residue).** For natural numbers $k, N, a$, say that $a$ is a **$k$-th power residue modulo $N$**, written $\mathrm{PR}_k(N, a)$, if there exists $b \in \mathbb{Z}/N$ with $b^k \equiv a \pmod N$.

At a concrete modulus this predicate is decidable by exhaustive search over $\mathbb{Z}/N$, which is what makes the small witness computations of Section 4 verifiable by direct evaluation.

**Definition 2.2 (Power symbol).** For $p$ prime, $k \mid p-1$ and $\gcd(a, p) = 1$, the **$k$-th power symbol** of $a$ at $p$ is the residue class $a^{(p-1)/k} \bmod p$. Its *residuacity bit* is the truth value of $a^{(p-1)/k} \equiv 1$.

**Definition 2.3 (Residue dial).** A **dial** is a pair $(M, \chi)$ with $M \ge 1$ and $\chi : \mathbb{N} \to \mathbb{Z}$ satisfying $\chi(n + M) = \chi(n)$ for all $n$; $M$ is the **conductor**. A family $D_1, \dots, D_L$ of dials has **conductor lcm** $M^* = \mathrm{lcm}(M_1, \dots, M_L)$, and its **dial vector** at $p$ is $\mathrm{dv}(p) = (\chi_1(p), \dots, \chi_L(p))$.

Immediately from periodicity: if $M \mid M'$ and $a \equiv b \pmod{M'}$ then $\chi(a) = \chi(b)$. This is the only property of dials we use, and Theorem 4.6 will show the escape does not depend on it.

**Definition 2.4 (Residuacity fingerprint).** Fix an exponent $k$ and bases $a_1, \dots, a_K$. The **fingerprint** of a candidate modulus $N$ is the bit vector

$$\mathrm{rv}_k(N) = \bigl(\mathbf{1}[\mathrm{PR}_k(N, a_1)], \dots, \mathbf{1}[\mathrm{PR}_k(N, a_K)]\bigr) \in \{0,1\}^K .$$

This is the *secret-independent read-out* of the power symbols: unlike the symbol values themselves, which live in $\mathbb{Z}/p$ and therefore presuppose $p$, the fingerprint lives in a fixed finite set of size $2^K$. The distinction between the two is the technical heart of the paper's negative conclusion (Section 7).

### 2.1 The $k$-th power criterion

Everything downstream rests on a single group-theoretic statement, which involves no primality, no field structure, and no root of unity — which is exactly why it applies verbatim to cubic and quartic symbols.

**Theorem 2.5 ($k$-th power criterion in a finite cyclic group).** Let $G$ be a finite cyclic group of order $n$ and let $k \mid n$. Then for every $x \in G$,

$$\bigl(\exists y \in G : y^k = x\bigr) \iff x^{n/k} = 1 .$$

*Proof sketch.* ($\Rightarrow$) If $x = y^k$ then $x^{n/k} = y^{k \cdot (n/k)} = y^n = 1$ by Lagrange. ($\Leftarrow$) Pick a generator $g$ of $G$ and write $x = g^j$. Then $g^{j n/k} = 1$, so $n = \mathrm{ord}(g)$ divides $j \cdot (n/k)$. Writing $n = k \cdot (n/k)$ and cancelling the positive factor $n/k$ gives $k \mid j$; say $j = km$. Then $x = (g^m)^k$. $\square$

**Corollary 2.6 (Euler's criterion, all exponents).** Let $p$ be prime, $k \mid p-1$, and $\gcd(a,p) = 1$. Then $\mathrm{PR}_k(p, a)$ holds if and only if $a^{(p-1)/k} \equiv 1 \pmod p$.

*Proof sketch.* Apply Theorem 2.5 to $G = (\mathbb{Z}/p)^\times$, which is cyclic of order $p-1$, and transfer between the unit group and the field by noting that a nonzero $k$-th root of a unit is itself a unit. $\square$

For $k = 2$ this is classical Euler; for $k = 3, 4$ it is the algebraic definition of the cubic and quartic symbols as residuacity tests. Two further elementary facts will be used.

**Proposition 2.7 (Residuacity tower).** If $k \mid \ell$ then $\mathrm{PR}_\ell(N,a) \Rightarrow \mathrm{PR}_k(N,a)$.

*Proof sketch.* If $\ell = kc$ and $b^\ell = a$ then $(b^c)^k = a$. $\square$

Thus quartic residues are quadratic residues, while cubic and quadratic residuacity are *incomparable* — the channels are nested only along divisibility. Theorem 5.6 below makes the incomparability quantitative.

**Proposition 2.8 (Multiplicativity).** $\mathrm{PR}_k(N,a)$ and $\mathrm{PR}_k(N,b)$ imply $\mathrm{PR}_k(N,ab)$.

---

## 3. The quadratic channel is a dial

**Theorem 3.1 (Periodicity of the quadratic bit).** Let $p, q$ be odd primes with $p \equiv q \pmod 8$. Then $2$ is a quadratic residue modulo $p$ if and only if it is one modulo $q$.

*Proof sketch.* By Gauss's second supplement, for an odd prime $p$ one has $2 \in (\mathbb{F}_p^\times)^2$ if and only if $p \equiv 1$ or $7 \pmod 8$. The right-hand condition depends on $p$ only through $p \bmod 8$, so equal residues give equal bits. $\square$

**Theorem 3.2 (An explicit conductor-$8$ dial).** There is a dial of conductor $8$, namely

$$\chi(n) = \begin{cases} 1 & n \equiv 1, 7 \pmod 8, \\ 0 & \text{otherwise},\end{cases}$$

such that for every odd prime $p$: $2$ is a quadratic residue modulo $p$ if and only if $\chi(p) = 1$.

*Proof sketch.* Periodicity of $\chi$ is immediate from $(n+8) \bmod 8 = n \bmod 8$; correctness is the second supplement again. $\square$

**Theorem 3.3 (Legendre symbols are dial readings).** For every $D \ne 0$ there is a dial of conductor $4|D|$ whose reading at any odd prime $p$ equals the Legendre symbol $\left(\frac{D}{p}\right)$.

*Proof sketch.* The Kronecker–Jacobi symbol $n \mapsto \left(\frac{D}{n}\right)$ is periodic in $n$ with period dividing $4|D|$, and at an odd prime the Jacobi symbol coincides with the Legendre symbol. $\square$

The content of Section 3 is therefore that the quadratic channel is *exactly* a dial: informative up to $\log_2(4|D|)$ bits, cheap to compute, and fully simulable by anyone who knows $p$ modulo the conductor.

---

## 4. The escape: cubic and quartic residuacity are not congruence data

### 4.1 The witness modulus

Set

$$\mathcal{M} = 720720 = \mathrm{lcm}(1, 2, \dots, 16) = 2^4 \cdot 3^2 \cdot 5 \cdot 7 \cdot 11 \cdot 13 .$$

Any modulus $M \le 16$, and many larger ones, divides $\mathcal{M}$. Two integers congruent modulo $\mathcal{M}$ are congruent modulo every divisor of $\mathcal{M}$, so a single pair of primes differing by $\mathcal{M}$ defeats every candidate period in that range simultaneously.

### 4.2 Cubic witnesses

**Lemma 4.1.** $43$ and $720763 = 43 + 720720$ are prime, both $\equiv 1 \pmod 3$, and $43 \equiv 720763 \pmod M$ for every $M \mid 720720$.

**Lemma 4.2.** $2$ is a cube modulo $43$.

*Proof.* $20^3 = 8000 = 186 \cdot 43 + 2$, so $20^3 \equiv 2 \pmod{43}$. $\square$

**Lemma 4.3.** $2$ is not a cube modulo $720763$.

*Proof sketch.* By Corollary 2.6 with $k = 3$ it suffices to check the symbol. Modular exponentiation gives

$$2^{(720763-1)/3} = 2^{240254} \equiv 632375 \pmod{720763},$$

and $632375 \ne 1$, so the criterion fails. $\square$

Both facts agree with Gauss's criterion: $43 = 4^2 + 27 \cdot 1^2$ is of the form $x^2 + 27y^2$, whereas $720763$ admits no such representation (a finite check over $y$ with $27y^2 \le 720763$).

**Theorem 4.4 (Cubic residuacity is not periodic at any modulus dividing $720720$).** Let $M \mid 720720$. Then it is false that

$$\forall p, q \text{ prime with } p \equiv q \equiv 1 \!\!\pmod 3 \text{ and } p \equiv q \!\!\pmod M : \bigl(\mathrm{PR}_3(p,2) \leftrightarrow \mathrm{PR}_3(q,2)\bigr).$$

*Proof.* Instantiate at $(p,q) = (43, 720763)$. The hypotheses hold by Lemma 4.1; the conclusion would transport Lemma 4.2 into a contradiction with Lemma 4.3. $\square$

**Corollary 4.5.** No modulus $M \le 16$ decides cubic residuacity of $2$: every such $M$ divides $720720$.

**Theorem 4.6 (Absolute escape).** Let $M \mid 720720$, let $X$ be an arbitrary set, let $f : \mathbb{N} \to X$ be any function depending on its argument only through $\cdot \bmod M$ (i.e. $a \equiv b \pmod M \Rightarrow f(a) = f(b)$), and let $g : X \to \{\text{true}, \text{false}\}$ be an arbitrary decision rule. Then it is false that $\mathrm{PR}_3(p,2) \leftrightarrow g(f(p))$ for all primes $p \equiv 1 \pmod 3$.

*Proof.* $f(43) = f(720763)$ by periodicity of $f$. If the equivalence held, Lemma 4.2 would give $g(f(43))$ true, hence $g(f(720763))$ true, hence $\mathrm{PR}_3(720763, 2)$, contradicting Lemma 4.3. $\square$

Theorem 4.6 is the statement that matters conceptually: the escape is not an artefact of restricting attention to integer-valued characters or to a particular notion of "dial". *No* congruence-based computation of any kind produces the cubic bit.

### 4.3 Quartic witnesses

**Lemma 4.7.** $137$ and $720857 = 137 + 720720$ are prime and both $\equiv 1 \pmod 4$.

**Lemma 4.8.** $2$ is a fourth power modulo $720857$: indeed $96769^4 \equiv 2 \pmod{720857}$.

**Lemma 4.9.** $2$ is not a fourth power modulo $137$: $2^{(137-1)/4} = 2^{34} \equiv 136 \not\equiv 1 \pmod{137}$.

**Theorem 4.10 (Quartic escape).** For every $M \mid 720720$, every $M$-periodic statistic $f$ and every decision rule $g$, the composite $g \circ f$ fails to decide quartic residuacity of $2$ on primes $\equiv 1 \pmod 4$.

*Proof.* As Theorem 4.6, with the pair $(137, 720857)$ and Lemmas 4.8, 4.9. $\square$

### 4.4 Circularity, stated precisely

**Theorem 4.11 (The cubic bit requires the exponent).** There exist primes $p, q \equiv 1 \pmod 3$ with $p \equiv q \pmod{720720}$, $\mathrm{PR}_3(p,2)$ true and $\mathrm{PR}_3(q,2)$ false.

*Proof.* $(p,q) = (43, 720763)$. $\square$

The significance is the following accounting. There are exactly two known routes to the cubic residuacity bit of a prime $p$:

1. **The Euler route.** Evaluate $2^{(p-1)/3} \bmod p$ (Corollary 2.6). This is fast — $O(\log^3 p)$ bit operations — but the exponent $(p-1)/3$ and the modulus $p$ are both the secret.
2. **The Gauss route.** Decide whether $p = x^2 + 27y^2$. For a *hidden* factor of $N$ this amounts to producing a representation of a number one cannot even write down; obtaining it from $N$ alone is factoring-strength.

Theorem 4.11 closes the third door — the congruence route — which is precisely the door through which the quadratic bit escapes to cheap computability. Escape from periodicity and computational inaccessibility are the *same* theorem read in two directions.

### 4.5 Composite moduli: the symmetry barrier

One might hope to sidestep by computing residuacity at the *public* modulus $N$ rather than at $p$. The next result shows what such a computation can and cannot see.

**Theorem 4.12 (CRT factorisation of residuacity).** Let $m, n$ be coprime. Then

$$\mathrm{PR}_k(mn, a) \iff \mathrm{PR}_k(m, a) \wedge \mathrm{PR}_k(n, a).$$

*Proof sketch.* ($\Rightarrow$) Reduce a witness $b$ modulo each factor via the natural ring maps. ($\Leftarrow$) Given witnesses $x$ modulo $m$ and $y$ modulo $n$, let $b$ be the element of $\mathbb{Z}/mn$ corresponding to $(x,y)$ under the Chinese Remainder isomorphism; since the isomorphism is a ring map and carries $a$ to $(a, a)$, one has $b^k = a$. $\square$

**Corollary 4.13 (Symmetry).** For coprime $p, q$: $\mathrm{PR}_k(pq, a) \leftrightarrow \mathrm{PR}_k(qp, a)$. The $N$-computable residuacity datum is a function of the *unordered* factor pair.

Hence no amount of higher-power data computed from $N$ alone can distinguish $p$ from $q$. A symmetric function of $\{p, q\}$ cannot name a factor, no matter how many bases are queried. This is the higher-power form of the classical observation that the Jacobi symbol at $N$ is symmetric in the factors.

---

## 5. Capacity: the escape does not widen the channel

### 5.1 The ceiling

**Theorem 5.1 (Fingerprint capacity, exponent-independent).** Let $k \ge 1$, let $a_1, \dots, a_K$ be bases, and let $S$ be any finite set of candidate moduli. Then the image of $S$ under the fingerprint map $\mathrm{rv}_k$ has at most $2^K$ elements.

*Proof sketch.* The fingerprint takes values in $\{0,1\}^K$, whose cardinality is $2^K$; the image of any set under a map is contained in the codomain. $\square$

**Corollary 5.2 (Separation cost).** If $\mathrm{rv}_k$ is injective on $S$ then $|S| \le 2^K$, and therefore $K \ge \log_2 |S|$.

The bound mentions neither $k$ nor the reciprocity law. It is the formal content of the experimental observation that cubic fingerprints separate candidate primes at exactly the quadratic rate: the rate is a property of the number of bits read, not of the law they come from.

**Corollary 5.3 (Forced collisions).** If $|S| > 2^K$ then there exist distinct $p, q \in S$ with $\mathrm{rv}_k(p) = \mathrm{rv}_k(q)$, for every exponent $k$.

### 5.2 The ceiling is attained

A capacity bound is worthless if the channel never approaches it. It does.

**Theorem 5.4 (Sharpness at $K = 2$).** The two cubic residuacity bits at bases $2$ and $3$ are injective on $S = \{7, 31, 61, 307\}$, a set of exactly $2^2$ primes; hence the bound of Corollary 5.2 is attained, and no set of five or more primes admits an injective two-bit cubic fingerprint.

*Proof.* Direct evaluation of the four fingerprints:

| $p$ | $\mathrm{PR}_3(p,2)$ | $\mathrm{PR}_3(p,3)$ | fingerprint |
|---|---|---|---|
| $7$ | false | false | $(0,0)$ |
| $31$ | true ($4^3 = 64 \equiv 2$) | false | $(1,0)$ |
| $61$ | false | true ($4^3 = 64 \equiv 3$) | $(0,1)$ |
| $307$ | true ($52^3 \equiv 2$) | true ($192^3 \equiv 3$) | $(1,1)$ |

All four patterns are distinct, so the map is injective; the upper bound is Corollary 5.2. $\square$

(Again Gauss's criterion agrees: $31 = 2^2 + 27$ and $307 = 8^2 + 27\cdot 3^2$ are of the form $x^2+27y^2$, while $7$ and $61$ are not.)

### 5.3 The higher bit is a worse bit

**Theorem 5.5 (Sparsity of $k$-th powers).** Let $p$ be prime and $k \mid p-1$. Then exactly $(p-1)/k$ of the $p-1$ units modulo $p$ are $k$-th powers.

*Proof sketch.* The $k$-th power map is an endomorphism of the cyclic group $(\mathbb{Z}/p)^\times$ of order $n = p-1$; its image has index $\gcd(k, n) = k$, hence cardinality $n/k$. $\square$

**Corollary 5.6 (The cubic bit is sparser than the quadratic bit).** If $6 \mid p-1$ then the cubes among the units number $(p-1)/3$ and the squares number $(p-1)/2$, and $(p-1)/3 < (p-1)/2$.

Information-theoretically, a bit with success probability $1/3$ carries entropy $H(1/3) \approx 0.918$ bits, versus exactly $1$ bit at probability $1/2$. So per symbol the cubic channel is *strictly poorer* than the quadratic one. Combined with Theorem 5.1 — the same worst-case ceiling — this explains, rather than merely records, the experimental finding that cubic bits separate slightly fewer candidates than quadratic bits.

### 5.4 Transversality without amplification

The escape theorems say the cubic bit is not a congruence datum. It could still be a *quadratic* datum in disguise. It is not.

**Theorem 5.7 (All four joint patterns occur).** Among primes $p \equiv 1 \pmod 3$, all four combinations of (quadratic bit of $2$, cubic bit of $2$) are realised:

| $p$ | $2$ a square? | $2$ a cube? |
|---|---|---|
| $7$ | yes ($3^2 = 9 \equiv 2$) | no |
| $13$ | no | no |
| $31$ | yes ($8^2 = 64 \equiv 2$) | yes ($4^3 \equiv 2$) |
| $43$ | no | yes ($20^3 \equiv 2$) |

**Corollary 5.8 (Mutual independence).** There is no function $g$ with $\mathrm{PR}_3(p,2) \leftrightarrow g(\mathrm{PR}_2(p,2))$ for all primes $p \equiv 1 \pmod 3$ — the primes $7$ and $31$ share a quadratic bit and differ in the cubic bit. Symmetrically, there is no $g$ with $\mathrm{PR}_2(p,2) \leftrightarrow g(\mathrm{PR}_3(p,2))$ — the primes $31$ and $43$ share a cubic bit and differ in the quadratic bit.

The two channels are therefore genuinely transverse. This is a *positive* structural fact — the cubic bit is not redundant — and it is exactly why the joint bound of the next section is a product, not a maximum. But transversality is not amplification: $K$ transverse bits are still $K$ bits.

---

## 6. The hybrid bound

We now combine every resource an adversary might plausibly hold.

**Lemma 6.1 (Fibrewise pigeonhole).** Let $S$ be a finite nonempty set and $f : S \to B$ any map. Then there is a value $v$ in the image with

$$|S| \le \bigl|\{s \in S : f(s) = v\}\bigr| \cdot |f(S)| .$$

*Proof sketch.* Partition $S$ into the fibres over $f(S)$ and take $v$ maximising the fibre size; the sum of $|f(S)|$ terms, each at most the maximum, is $|S|$. $\square$

**Theorem 6.2 (Hybrid no-amplification).** Let $\Omega$ be a nonempty finite set of candidates all lying in one hint class $p \equiv r \pmod m$ with $m \ge 1$. Let $D_1, \dots, D_L$ be dials with conductor lcm $M^*$ and dial vector $\mathrm{dv}$, and let $\mathrm{rv}_k$ be a $K$-symbol residuacity fingerprint at any exponent $k$ and any bases. Then there is a joint reading $(v, w)$ such that

$$|\Omega| \le \bigl|\{p \in \Omega : \mathrm{dv}(p) = v \text{ and } \mathrm{rv}_k(p) = w\}\bigr| \cdot \Bigl(\frac{M^*}{\gcd(M^*, m)} \cdot 2^K\Bigr).$$

*Proof sketch.* Apply Lemma 6.1 to the joint statistic $F(p) = (\mathrm{dv}(p), \mathrm{rv}_k(p))$. The image of $F$ embeds into the product of the images of the two components, so $|F(\Omega)|$ is at most the product of their cardinalities. The dial component is bounded by $M^*/\gcd(M^*, m)$: all candidates share a residue mod $m$, so their residues mod $M^*$ range over at most that many classes, and $\mathrm{dv}$ factors through the residue mod $M^*$. The fingerprint component is bounded by $2^K$ (Theorem 5.1). $\square$

Read the bound as an indistinguishability statement: at least

$$\frac{|\Omega|}{(M^*/\gcd(M^*,m)) \cdot 2^K}$$

candidates share *every* piece of information the adversary holds. The higher-power channel enters only through the factor $2^K$ — precisely the contribution that $K$ bits from *any* source would make. In particular, replacing the cubic bits with quadratic bits at $K$ new bases changes nothing in the bound. Escaping periodicity relabels which bits are read; it does not create bits.

---

## 7. The mirage of full-symbol separation

The experiment motivating this work reported a striking datum: for the $68$ primes $p \in [1000, 2000]$ with $p \equiv 1 \pmod 3$, and the five bases $2, 3, 5, 7, 11$, the vector of full cubic symbol values $\bigl(a_i^{(p-1)/3} \bmod p\bigr)_{i \le 5}$ separated all $68$ primes — and so did the quadratic analogue. Perfect separation with five symbols looks like a powerful attack.

It is not, and Theorem 5.1 explains why without contradiction. The bound applies to the fingerprint $\mathrm{rv}_k$, whose values live in the *fixed* set $\{0,1\}^K$. It does not apply to the raw symbol values, which live in $\mathbb{Z}/p$ — a set whose very description contains the secret. A statistic valued in $\mathbb{Z}/p$ trivially separates distinct primes because it *encodes* $p$. The "$68/68$" is circularity in numerical costume: to compute the separating statistic one must already know the separand.

Restricting to the honest, secret-independent read-out gives:

| fingerprint (bases $2,3,5,7,11$; $68$ primes) | distinct values | capacity |
|---|---|---|
| full quadratic symbol values | $68 / 68$ | not bounded — values live in $\mathbb{Z}/p$ |
| full cubic symbol values | $68 / 68$ | not bounded — same artefact |
| quadratic residuacity bits | $31 / 68$ | $2^5 = 32$ |
| cubic residuacity bits | $23 / 68$ | $2^5 = 32$ |

Both bit-channels are pinned under the ceiling $32$ of Theorem 5.1. The quadratic bits nearly saturate it ($31$ of $32$); the cubic bits reach only $23$, consistent with the bias predicted by Theorem 5.5 — a $1/3$-dense predicate wastes more of the pattern space than a $1/2$-dense one. There is no higher-power advantage in the data, and the theory predicts there could not be.

---

## 8. Discussion

### 8.1 The closed accounting

Combining the results yields a complete description of what the residue channel can carry. For a secret prime $p$:

$$\text{residue-channel information} \;=\; \underbrace{\text{dial part}}_{\text{determined by } p \bmod M^*} \;+\; \underbrace{\text{fine-arithmetic part}}_{\text{non-periodic, needs } p} .$$

The dial part is bounded by $\log_2 M^*$ bits and is exactly what a partial hint erodes (Theorem 6.2). The fine-arithmetic part — the cubic and quartic bits, governed by $p = x^2 + 27y^2$ and its quartic analogue — is genuinely new information (Corollary 5.8) and genuinely non-periodic (Theorem 4.6), but is obtainable only through the exponent $(p-1)/k$ or through a factoring-strength representation problem, and is capped at $2^K$ patterns in any case (Theorem 5.1). There is no third component. Higher reciprocity, on this reading, is not a partially-explored resource; it is a fully accounted one.

### 8.2 Why the escape had to close the door

It is worth emphasising that the negative conclusion is not an accident of the particular witnesses. The escape from periodicity is a consequence of non-abelian structure: the splitting condition for the cubic residuacity of $2$ is the splitting condition of the $S_3$-extension $\mathbb{Q}(\sqrt[3]{2}, \omega)$, and by class field theory only abelian splitting sets are unions of ray classes. Congruence computability and abelian structure are the same phenomenon; the cheapness of the Legendre symbol is the cheapness of an abelian character. Therefore *any* channel that escapes periodicity is, for the same reason, not computable by congruence methods. Escape and inaccessibility are not two findings but one, viewed from either end.

### 8.3 Comparison with the quadratic channel

| feature | quadratic | cubic / quartic |
|---|---|---|
| periodic in $p$? | yes, conductor $8$ for base $2$ (Theorem 3.2) | no, at any modulus dividing $720720$ (Theorem 4.6) |
| computable without $p$? | yes, Jacobi symbol in $O(\log^2 N)$ | no known route avoiding $p$ or factoring |
| $N$-computable version | Jacobi symbol at $N$ — symmetric | symmetric (Corollary 4.13) |
| density of residues | $1/2$ | $1/k$ (Theorem 5.5) |
| capacity of $K$ bits | $2^K$ | $2^K$ (Theorem 5.1), attained (Theorem 5.4) |

Each row that improves in the second column is paid for by a row that worsens.

### 8.4 Limitations

Three honest caveats. First, the escape theorems are proved for the specific modulus family $M \mid 720720$; unbounded escape (for *every* modulus $M$) is stated as Conjecture A below and follows morally from the $S_3$-argument, though a fully elementary proof is not given here. Second, sharpness of the capacity bound is exhibited at $K = 2$; whether all $2^K$ patterns occur among small primes for larger $K$ is Conjecture B. Third, the results concern *residuacity bits* as the read-out. A hypothetical attacker with a way to use the raw symbol value without knowing $p$ would fall outside this analysis — but such a use is exactly what the circularity argument of Section 4.4 forbids by the known routes.

### 8.5 Future directions

Five questions stand out.

**Conjecture A (Unbounded escape).** For every modulus $M \ge 1$ there exist primes $p \equiv q \pmod M$, both $\equiv 1 \pmod 3$, with $2$ a cube modulo $p$ and not modulo $q$. We have proved this for every $M \mid 720720$. The general case should follow from the fact that $2$ is a cube modulo $p$ exactly when $p = x^2 + 27y^2$ — a splitting condition in the non-abelian field $\mathbb{Q}(\sqrt[3]{2}, \omega)$ — since a congruence condition would force the splitting set of a non-normal cubic field to be a union of ray classes, contradicting the Galois group $S_3$. What is wanted is a Chebotarev-free argument: it suffices to exhibit, for each $M$, a *pair* of primes in one class with different splitting behaviour, and the $x^2 + 27y^2$ parametrisation makes such pairs constructible rather than merely dense.

**Conjecture B (Exact capacity, not just the ceiling).** For bases $a_1, \dots, a_K$ multiplicatively independent modulo cubes, the cubic residuacity fingerprint attains all $2^K$ patterns on primes below $\exp(O(K))$. Attainment is proved for $K = 2$ with the explicit set $\{7, 31, 61, 307\}$. The joint distribution of cubic bits should be governed by the Galois group of the compositum $\mathbb{Q}(\omega, \sqrt[3]{a_1}, \dots, \sqrt[3]{a_K})$, which is $(\mathbb{Z}/3)^K \rtimes \mathbb{Z}/2$ for independent bases; equidistribution then forces every pattern to appear with density $3^{-K}$.

**Question C (Beyond bits).** Is there any read-out of the power symbol, other than the residuacity bit, that lives in a secret-independent value set? A negative answer would upgrade Theorem 5.1 from a statement about one read-out to a statement about the channel.

**Question D (Higher $k$).** The sparsity theorem says $k$-th powers occupy a $1/k$ fraction. As $k$ grows the bit becomes more informative when it says "yes" and less often says it. Is there an optimal $k$ for a fixed query budget, and does the optimum scale with the candidate set size?

**Question E (Non-abelian channels generally).** Cubic reciprocity is the smallest non-abelian escape. Does *any* Artin symbol at a non-abelian extension provide a poly-time handle, or is the escape/inaccessibility duality of Section 8.2 a theorem about all of them?

---

## 9. Conclusion

Higher-power reciprocity was a well-motivated candidate for a stronger residue channel: its symbols are finer than the Legendre symbol and its criteria are provably not congruence conditions. Both halves of that motivation are correct, and we have proved both. The cubic residuacity bit of $2$ is not computable from $p \bmod M$ for any $M$ dividing $\mathrm{lcm}(1,\dots,16)$, by any statistic and any decision rule, with the explicit witness pair $43$ and $720763$; the quartic bit fails likewise at $137$ and $720857$; and the cubic bit is not a function of the quadratic bit or conversely. Yet the channel's capacity is unchanged: a $K$-symbol residuacity fingerprint takes at most $2^K$ values at every exponent, this ceiling is attained at $K=2$, the higher bit is strictly sparser hence individually poorer, the composite-modulus version is symmetric in the factors, and the joint hint-plus-dials-plus-bits bound admits the higher-power channel only through the factor $2^K$.

The verdict is therefore negative and, we believe, final for this line of attack. The residue channel carries a dial part and fine-arithmetic noise, and nothing else. The higher-power reciprocity channel is closed.
