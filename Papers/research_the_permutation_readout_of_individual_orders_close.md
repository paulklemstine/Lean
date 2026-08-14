# The Stratified Cycle Readout of Multiplication on $\mathbb{Z}/N\mathbb{Z}$: Complete Structure, a Valid Factoring Algorithm, and Why It Is Sealed

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $N \ge 1$ and let $a$ be coprime to $N$. The map $\sigma_a(x) = ax$ is a permutation of the whole ring $\mathbb{Z}/N\mathbb{Z}$, not merely of its unit group. We determine its cycle structure completely: for each divisor $d \mid N$ the stratum $S_d = \{x : \gcd(x,N)=d\}$ is $\sigma_a$-invariant, has cardinality $\varphi(N/d)$, and every one of its points lies on a cycle of length exactly $\operatorname{ord}_{N/d}(a)$; hence $\#\mathrm{cycles}(\sigma_a) = \sum_{d\mid N} \varphi(N/d)/\operatorname{ord}_{N/d}(a)$. For a semiprime $N = pq$ this exhibits the individual orders $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ as *distinct cycle lengths* on strata of sizes $q-1$ and $p-1$, an asymmetric readout strictly richer than the symmetric datum $\operatorname{ord}_N(a) = \operatorname{lcm}(\operatorname{ord}_p a, \operatorname{ord}_q a)$ that any unit-group probe returns; when $a$ is primitive modulo $q$ the cycle through the point $p$ has length $q-1$, so the readout is a correct factoring algorithm.

We then prove that this asymmetry is nevertheless inaccessible, and quantify exactly how much information the readout carries. Three barriers are established: (i) *circular entry* — every point of a nontrivial stratum is itself a nontrivial divisor of $N$; (ii) *cost* — the free stratum has $\varphi(N) > \sqrt{N}$ elements, and for balanced semiprimes the informative points have density at most $6/\sqrt{N}$; (iii) *order-finding* — every cycle length divides $\operatorname{ord}_N(a)$. A Burnside identity, $\operatorname{ord}_N(a)\cdot\#\mathrm{cycles} = \sum_{k<\operatorname{ord}_N(a)} \gcd(N, a^k-1)$, identifies the readout as the aggregate of the classical Pollard $p-1$ probes, and shows the cycle count exceeds its minimum precisely when one of those probes already factors $N$. An excess formula, $\#\mathrm{cycles}(pq) = \#\mathrm{cycles}(p)\#\mathrm{cycles}(q) + (\gcd(\operatorname{ord}_p a,\operatorname{ord}_q a)-1)i_pi_q$, shows the only datum beyond the lcm is the gcd of the two prime orders.

Finally we classify the coarsest summary, the permutation sign, at *every* modulus: for odd $N$, $\sigma_a$ is even iff the Jacobi symbol $J(a\mid N)=+1$ (a general Zolotarev–Frobenius law obtained by parity localisation over strata); for even $N = 2^s m$ the odd part is invisible — $\sigma_a$ is always even when $N \equiv 2 \pmod 4$, and is odd exactly when $4 \mid N$ and $a \equiv 3 \pmod 4$. Both are polynomial-time computable without factoring. Two enlargements of the attack surface are closed in the same way: the affine cycle count of $x \mapsto Ax+b$ depends on $b$ only through $\gcd(\gcd(N, A-1), b)$, with the affine sign the product of the multiplicative and translation signs; and the power map $x \mapsto x^k$ on $\mathbb{Z}/p\mathbb{Z}$ has $\#\mathrm{cycles}(x\mapsto kx \text{ on } \mathbb{Z}/(p-1)\mathbb{Z}) + 1$ cycles, so it is the multiplicative readout one level down, with the explicit sign law "even iff $4\mid p-1 \Rightarrow k \equiv 1 \pmod 4$".

**Keywords:** multiplicative order, cycle structure, Zolotarev's lemma, Jacobi symbol, integer factorisation, Burnside's lemma, affine permutations, cryptographic barriers.

---

## 1. Introduction

### 1.1 The lcm-blindness of order probes

Almost every algorithm that attacks the integer factorisation problem through multiplicative structure — Pollard's $p-1$ method, Williams' $p+1$, Shor's period-finding — ultimately manipulates *orders*. For $N$ a product of two distinct primes $p, q$ and $a$ coprime to $N$, the Chinese Remainder Theorem gives

$$\operatorname{ord}_N(a) \;=\; \operatorname{lcm}\bigl(\operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\bigr). \tag{1.1}$$

An adversary who does not know $p$ and $q$ can still compute freely inside the unit group $(\mathbb{Z}/N\mathbb{Z})^\times$; but every quantity so obtained is a function of $\operatorname{ord}_N(a)$ and hence, by (1.1), a *symmetric* function of the two prime orders. The individual values $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ are flattened by the least common multiple. We call this phenomenon **lcm-blindness**; it is a genuine information-theoretic loss and an obstruction to a large family of would-be attacks.

It is therefore natural to ask whether some object canonically attached to $a$ and $N$ escapes the flattening. The present paper studies the most elementary candidate: the permutation

$$\sigma_a : \mathbb{Z}/N\mathbb{Z} \longrightarrow \mathbb{Z}/N\mathbb{Z}, \qquad \sigma_a(x) = a\,x,$$

of the **whole ring**, not merely of its unit group. Because $\sigma_a$ also acts on the non-unit classes, it is strictly finer than any unit-group probe, and — as we show — it separates $\operatorname{ord}_p(a)$ from $\operatorname{ord}_q(a)$ completely.

### 1.2 Summary of contributions

1. **Exact structure (Section 3).** The *stratification law*: the cycle structure of $\sigma_a$ is determined divisor by divisor, with the stratum $S_d$ carrying $\varphi(N/d)/\operatorname{ord}_{N/d}(a)$ cycles all of length $\operatorname{ord}_{N/d}(a)$.
2. **Asymmetric readout and a factoring algorithm (Section 4).** For $N=pq$ the four strata display $\{\operatorname{ord}_N(a), \operatorname{ord}_q(a), \operatorname{ord}_p(a), 1\}$; for $a$ primitive at $q$ the cycle through $p$ returns $q$ exactly. A concrete pair of multipliers with equal $\operatorname{ord}_N$ and different readouts shows the strictness of the refinement.
3. **Three barriers (Section 5).** Circular entry, an $\Omega(N)$ enumeration cost with informative density $\le 6/\sqrt{N}$, and the reduction of individual cycle lengths to order-finding.
4. **The readout is a Pollard aggregate (Section 6).** A Burnside identity and a minimality criterion.
5. **Exact information surplus (Section 7).** The excess formula and supermultiplicativity.
6. **The sign at every modulus (Section 8).** A general Zolotarev–Frobenius theorem for odd $N$ and a complete even-modulus law; both factorisation-free.
7. **Closure of two enlargements (Section 9).** Affine maps and power maps.

Sections 10–12 give algorithms, numerical illustrations, and a discussion of what the results say about hardness.

---

## 2. Setting and notation

Throughout, $N \ge 1$ is an integer and $a$ an integer with $\gcd(a,N)=1$. We write:

* $\varphi$ for Euler's totient function;
* $\operatorname{ord}_M(a)$ for the multiplicative order of $a$ modulo $M$, i.e. the least $k \ge 1$ with $a^k \equiv 1 \pmod M$ (with the convention $\operatorname{ord}_1(a)=1$);
* $\gcd(x,N)$ for the greatest common divisor, computed on any integer representative of $x \in \mathbb{Z}/N\mathbb{Z}$ (this is well defined);
* $J(a \mid N)$ for the Jacobi symbol, defined for odd $N \ge 1$ as $\prod_p (a \mid p)^{v_p(N)}$ over the Legendre symbols of the prime factors of $N$;
* $i_M = \varphi(M)/\operatorname{ord}_M(a)$ for the **index** of $a$ at modulus $M$ (an integer, since the order divides the group exponent's multiple $\varphi(M)$ by Lagrange).

**Definition 2.1 (multiplication permutation).** $\sigma_a : \mathbb{Z}/N\mathbb{Z} \to \mathbb{Z}/N\mathbb{Z}$, $\sigma_a(x) = ax$. Since $a$ is invertible mod $N$, $\sigma_a$ is a bijection.

**Definition 2.2 (stratum).** For $d \mid N$, $S_d = \{x \in \mathbb{Z}/N\mathbb{Z} : \gcd(x,N) = d\}$. The strata partition $\mathbb{Z}/N\mathbb{Z}$ as $d$ ranges over the divisors of $N$; $S_1$ is the unit group and $S_N = \{0\}$.

**Definition 2.3 (period, cycle count).** The *period* of $x$ is the least $k \ge 1$ with $a^k x \equiv x \pmod N$; its cycle (orbit) is $\{a^k x : k \ge 0\}$. We write $\#\mathrm{cycles}(\sigma_a)$, or $C(N,a)$, for the number of distinct orbits.

Since $\gcd(ax, N) = \gcd(x,N)$ for invertible $a$, each stratum is $\sigma_a$-invariant, so the cycle structure decomposes over the strata.

---

## 3. The stratification law

The following divisibility fact is the engine of the whole analysis; everything else is bookkeeping around it.

**Lemma 3.1 (modulus reduction).** Let $N \ge 1$ and $x, m \ge 0$. Then
$$N \mid m x \iff \frac{N}{\gcd(N,x)} \;\Big|\; m .$$

*Proof.* Put $d = \gcd(N,x)$ and write $N = d\,N'$, $x = d\,x'$ with $\gcd(N',x')=1$. If $N \mid mx$ then $dN' \mid m d x'$, so $N' \mid m x'$, and coprimality gives $N' \mid m$. Conversely if $N' \mid m$, say $m = N'c$, then $mx = N'c\,dx' = N\,(c x')$. $\square$

**Theorem 3.2 (stratified period law).** Let $\gcd(a,N)=1$, $x \in \mathbb{Z}/N\mathbb{Z}$, $k \ge 0$. Then
$$a^k x \equiv x \pmod N \iff \operatorname{ord}_{N/\gcd(N,x)}(a) \mid k .$$
In particular the period of $x$ equals $\operatorname{ord}_{N/\gcd(N,x)}(a)$, a quantity depending on $x$ only through its stratum.

*Proof sketch.* The congruence $a^k x \equiv x$ says $N \mid (a^k-1)x$, which by Lemma 3.1 is equivalent to $(N/\gcd(N,x)) \mid (a^k-1)$, i.e. to $a^k \equiv 1$ modulo the reduced modulus $M = N/\gcd(N,x)$. Since $a$ remains invertible mod $M$ (as $M \mid N$), this holds iff $\operatorname{ord}_M(a) \mid k$. Taking the least positive such $k$ gives the period. $\square$

**Proposition 3.3 (stratum size).** For $d \mid N$, $|S_d| = \varphi(N/d)$.

*Proof sketch.* The map $x \mapsto x/d$ is a bijection from $S_d$ onto $\{y \in \mathbb{Z}/(N/d)\mathbb{Z} : \gcd(y, N/d) = 1\}$, whose cardinality is $\varphi(N/d)$. $\square$

**Corollary 3.4 (cycles within a stratum).** For $d \mid N$, the stratum $S_d$ is a disjoint union of cycles all of the same length $\operatorname{ord}_{N/d}(a)$, and their number is
$$c_d \;=\; \frac{\varphi(N/d)}{\operatorname{ord}_{N/d}(a)} \;=\; i_{N/d}.$$
Equivalently, $|S_d| = c_d \cdot \operatorname{ord}_{N/d}(a)$.

**Theorem 3.5 (cycle count).** For $\gcd(a,N)=1$,
$$C(N,a) \;=\; \sum_{d \mid N} \frac{\varphi(N/d)}{\operatorname{ord}_{N/d}(a)} \;=\; \sum_{e \mid N} i_e . \tag{3.1}$$

*Proof.* Partition $\mathbb{Z}/N\mathbb{Z}$ into strata and apply Corollary 3.4; reindex $e = N/d$. $\square$

Two immediate specialisations will be used repeatedly.

**Corollary 3.6 (prime modulus).** For $p$ prime and $\gcd(a,p)=1$: $C(p,a) = 1 + (p-1)/\operatorname{ord}_p(a) = 1 + i_p$.

**Corollary 3.7 (prime power).** For $p$ prime, $\gcd(a,p)=1$, $k\ge 0$: $C(p^k, a) = \sum_{j=0}^{k} \varphi(p^j)/\operatorname{ord}_{p^j}(a) = \sum_{j=0}^k i_{p^j}$.

---

## 4. The asymmetric readout at a semiprime, and a factoring algorithm

Let $N = pq$ with $p \ne q$ prime, $\gcd(a,N)=1$.

**Theorem 4.1 (four strata).** The strata of $\mathbb{Z}/pq\mathbb{Z}$ and their data are:

| stratum | cardinality | common cycle length | number of cycles |
|---|---|---|---|
| $S_1$ (units) | $\varphi(N) = (p-1)(q-1)$ | $\operatorname{ord}_N(a)$ | $\varphi(N)/\operatorname{ord}_N(a)$ |
| $S_p$ | $q-1$ | $\operatorname{ord}_q(a)$ | $i_q$ |
| $S_q$ | $p-1$ | $\operatorname{ord}_p(a)$ | $i_p$ |
| $S_N = \{0\}$ | $1$ | $1$ | $1$ |

Consequently
$$C(pq, a) \;=\; 1 \;+\; \frac{\varphi(N)}{\operatorname{ord}_N(a)} \;+\; \frac{q-1}{\operatorname{ord}_q(a)} \;+\; \frac{p-1}{\operatorname{ord}_p(a)} . \tag{4.1}$$

*Proof.* Immediate from Theorem 3.5 and Proposition 3.3, since the divisors of $pq$ are $1, p, q, pq$ and $N/p = q$, $N/q = p$. $\square$

The point of Theorem 4.1 is not the count but the **cycle-length spectrum** $\{\operatorname{ord}_N(a), \operatorname{ord}_q(a), \operatorname{ord}_p(a), 1\}$: the two prime orders appear separately, on strata of *different* sizes $q-1$ and $p-1$, and are therefore individually identifiable. The readout is asymmetric where (1.1) is symmetric.

**Theorem 4.2 (factor recovery).** Let $p, q$ be primes and suppose $a$ is primitive modulo $q$, i.e. $\operatorname{ord}_q(a) = q-1$. Then the cycle of $\sigma_a$ through the point $p \in \mathbb{Z}/pq\mathbb{Z}$ has length exactly $q-1$, and $q = (\text{that length}) + 1$ is a divisor of $pq$ with $1 < q < pq$.

*Proof.* $\gcd(p, pq) = p$, so by Theorem 3.2 the period of $p$ is $\operatorname{ord}_{pq/p}(a) = \operatorname{ord}_q(a) = q-1$. $\square$

Thus the readout is, formally, a **correct factoring algorithm**. It performs as advertised on examples:

| $N$ | $a$ | length of cycle through $p$ | recovered factors |
|---|---|---|---|
| $143$ | $2$ | $12$ | $\{11,13\}$ |
| $221$ | $7$ | $16$ | $\{13,17\}$ |
| $899$ | $3$ | $30$ | $\{29,31\}$ |
| $3127$ | $2$ | $58$ | $\{53,59\}$ |

**Proposition 4.3 (the free stratum is lcm-blind).** If $\gcd(a,N)=\gcd(b,N)=1$ and $\operatorname{ord}_N(a) = \operatorname{ord}_N(b)$, then $\sigma_a$ and $\sigma_b$ have identical cycle lengths at every point of the unit stratum $S_1$, and the same number of cycles inside $S_1$.

*Proof.* By Theorem 3.2 every $x \in S_1$ has period $\operatorname{ord}_N(a)$; the count in $S_1$ is $\varphi(N)/\operatorname{ord}_N(a)$. $\square$

So the refinement genuinely lives outside the unit group. That it is a *strict* refinement is witnessed concretely.

**Example 4.4 (separation beyond the lcm).** Take $N = 65 = 5\cdot 13$, $a = 57$, $b = 31$. Then $\operatorname{ord}_{65}(57) = \operatorname{ord}_{65}(31) = 4$, so no unit-group probe distinguishes $a$ from $b$. But $\operatorname{ord}_5(57) = 4$ while $\operatorname{ord}_5(31) = 1$, so on the stratum $S_{13}$ (the nonzero multiples of $13$) the first permutation has $4$-cycles and the second has fixed points. Even the coarse statistic $C$ separates them: $C(65,57) = 17$ while $C(65,31) = 20$.

---

## 5. Three barriers

The results of Section 4 are, taken alone, a factoring algorithm that defeats lcm-blindness. This section explains why it is nevertheless useless. Each barrier is proved for the general readout, not merely for a particular implementation.

### 5.1 Circular entry

**Theorem 5.1 (informative points are factors).** Let $x \in \mathbb{Z}/N\mathbb{Z}$ with $d = \gcd(x,N) \notin \{1, N\}$. Then $d$ is a divisor of $N$ with $1 < d < N$.

*Proof.* $d \mid N$ always; the hypothesis excludes the two trivial values, and $d \le N$ with $d \ne N$ gives $d < N$. $\square$

Trivial as a statement, decisive as a barrier: to read a cycle in a nontrivial stratum one must *possess* a point of it, and possessing such a point already yields a nontrivial factor of $N$ by a single Euclidean algorithm. The permutation contributes nothing that the gcd has not already given. Conversely, the only stratum an adversary can enter for free is $S_1$, where Proposition 4.3 says the readout is exactly $\operatorname{ord}_N(a)$ — the lcm again.

### 5.2 Cost: enumeration and informative density

**Theorem 5.2 (the free stratum exceeds the trial-division range).** Let $p \ne q$ be primes with $p, q \ge 3$. Then $\lfloor\sqrt{pq}\rfloor < \varphi(pq)$.

*Proof sketch.* For odd distinct primes $\ge 3$ one has $\varphi(pq) = (p-1)(q-1) > pq/2 \ge \lfloor\sqrt{pq}\rfloor^2/2$, and $pq \ge 15$; combining gives the claim. $\square$

Reading the cycle structure requires traversing orbits; even the free part of the structure has more points than the entire search space of trial division, and vastly more than the $O(N^{1/4})$ expected work of Pollard's rho. A permutation of an $N$-element set cannot be fully resolved in fewer than $N$ applications of the map.

**Theorem 5.3 (informative density $\le 6/\sqrt{N}$).** Let $p \le q \le 2p$ be primes (a *balanced* semiprime) and $N = pq$. The number of informative points — those in $S_p \cup S_q$, i.e. the nonzero multiples of $p$ or of $q$ — is $p + q - 1$, and
$$(p+q-1)\,\lfloor\sqrt{N}\rfloor \;\le\; 6N,$$
i.e. the informative points have density at most $6/\sqrt{N}$.

*Proof sketch.* Balance gives $\lfloor\sqrt{N}\rfloor \le 2p$ and $p + q - 1 \le 3p$, whence $(p+q-1)\lfloor\sqrt N\rfloor \le 3p \cdot \sqrt{pq} \le 6pq$ after using $\sqrt{pq}\le q\sqrt{2}$ and $q \le 2p$; a short case analysis on $\lfloor\sqrt{N}\rfloor$ makes this exact in integers. $\square$

So blind sampling for an informative point costs $\Omega(\sqrt N)$ trials, and each *successful* trial already factors $N$ by gcd — barrier 5.1 again, now with a density estimate attached.

### 5.3 Reading one cycle length is order-finding

**Proposition 5.4.** For every $x$, the period of $x$ divides $\operatorname{ord}_N(a)$; indeed $\operatorname{ord}_M(a) \mid \operatorname{ord}_N(a)$ whenever $M \mid N$.

*Proof.* $a^{\operatorname{ord}_N(a)} \equiv 1 \pmod N$ implies the same congruence mod $M$. $\square$

Hence no cycle length is "new"; each is a divisor of the global order, and determining it is itself an instance of order-finding — precisely the problem an attack of this kind was meant to circumvent. There is no cheap oracle for a single stratum's length.

---

## 6. The readout is an aggregate of Pollard probes

The next result explains structurally why the cycle count cannot contain unexpected information.

**Lemma 6.1 (fixed points).** For any $k$, the permutation $x \mapsto a^k x$ of $\mathbb{Z}/N\mathbb{Z}$ has exactly $\gcd(N, a^k - 1)$ fixed points.

*Proof sketch.* $a^k x \equiv x$ iff $N \mid (a^k-1)x$ iff $\bigl(N/\gcd(N,a^k-1)\bigr) \mid x$ (Lemma 3.1 with the roles of $x$ and $m$ exchanged), and the multiples of $N/g$ in $\mathbb{Z}/N\mathbb{Z}$ number exactly $g = \gcd(N, a^k-1)$. $\square$

**Theorem 6.2 (Burnside identity).** Let $L = \operatorname{ord}_N(a)$ and $a \ge 1$ with $\gcd(a,N)=1$. Then
$$L \cdot C(N,a) \;=\; \sum_{k=0}^{L-1} \gcd\bigl(N,\ a^k - 1\bigr). \tag{6.1}$$

*Proof sketch.* The cyclic group $\langle a \rangle$ of order $L$ acts on $\mathbb{Z}/N\mathbb{Z}$ with orbits precisely the cycles of $\sigma_a$. Burnside's orbit-counting lemma gives $C = \frac1L \sum_{k<L} |\mathrm{Fix}(a^k)|$, and Lemma 6.1 evaluates each term. (The $k=0$ term contributes $\gcd(N,0)=N$.) $\square$

The summands on the right of (6.1) are exactly the probes computed by Pollard's $p-1$ algorithm. The readout is therefore not a new source of information but a *sum* over an old one. This is made sharp by:

**Theorem 6.3 (minimality criterion).** With $L = \operatorname{ord}_N(a)$,
$$L\cdot C(N,a) \;=\; N + (L-1) \iff \gcd(N, a^k-1) = 1 \ \text{ for all } 1 \le k < L .$$

*Proof.* By (6.1), $L\cdot C = N + \sum_{k=1}^{L-1}\gcd(N,a^k-1)$, and each summand is $\ge 1$ with equality iff the probe is trivial; the sum equals $L-1$ iff all $L-1$ summands equal $1$. $\square$

In words: the cycle count exceeds its minimum possible value **exactly when some Pollard probe already succeeds** in producing a nontrivial factor. Any advantage the readout appears to offer is an advantage the classical algorithm has already taken.

---

## 7. The exact information surplus over the lcm

How much does the composite readout know beyond the two prime readouts? Exactly one number.

**Theorem 7.1 (index identity).** For $N = pq$ with $p\ne q$ prime and $\gcd(a,N)=1$,
$$\frac{\varphi(pq)}{\operatorname{ord}_{pq}(a)} \;=\; \gcd\bigl(\operatorname{ord}_p a,\ \operatorname{ord}_q a\bigr)\cdot i_p \cdot i_q, \qquad i_p = \frac{p-1}{\operatorname{ord}_p a},\ \ i_q = \frac{q-1}{\operatorname{ord}_q a}.$$

*Proof.* By (1.1) and $\operatorname{lcm}(u,v)\gcd(u,v) = uv$,
$\varphi(pq)/\operatorname{ord}_{pq}(a) = (p-1)(q-1)\gcd/(\operatorname{ord}_p a \cdot \operatorname{ord}_q a) = \gcd \cdot i_p i_q$. $\square$

**Corollary 7.2 (parity of the unit-stratum count).** For odd primes $p \ne q$ the number $\varphi(pq)/\operatorname{ord}_{pq}(a)$ is even, since $p-1$ and $q-1$ are both even and at least one factor of $2$ survives in $\gcd\cdot i_p i_q$. Hence multiplication by a unit is an *even* permutation of the unit stratum whenever $N$ has two coprime factors exceeding $2$. (This is the key parity-localisation input to Section 8.)

**Theorem 7.3 (excess formula).** For $N=pq$, $p \ne q$ prime, $\gcd(a,N)=1$:
$$C(pq,a) \;=\; C(p,a)\,C(q,a) \;+\; \bigl(\gcd(\operatorname{ord}_p a,\ \operatorname{ord}_q a) - 1\bigr)\, i_p\, i_q . \tag{7.1}$$

*Proof.* Substitute Theorem 7.1 into (4.1): $C(pq,a) = 1 + \gcd\cdot i_pi_q + i_q + i_p$, while $C(p,a)C(q,a) = (1+i_p)(1+i_q) = 1 + i_p + i_q + i_pi_q$. Subtract. $\square$

**Corollary 7.4 (supermultiplicativity, and its equality case).** $C(pq,a) \ge C(p,a)C(q,a)$, with equality if and only if $\gcd(\operatorname{ord}_p a, \operatorname{ord}_q a) = 1$.

**Corollary 7.5 (primitive multipliers).** If $a$ is primitive at both primes then $i_p = i_q = 1$ and the surplus is $\gcd(p-1,q-1) - 1 \ge 1$ for odd $p,q$: the composite readout is then strictly richer than the pair of prime readouts.

Interpretation: the unit group already reveals $\operatorname{lcm}(\operatorname{ord}_p a, \operatorname{ord}_q a)$; by (7.1) the whole additional content of the ring-level readout is $\gcd(\operatorname{ord}_p a, \operatorname{ord}_q a)$. Since $\operatorname{lcm}\cdot\gcd = \operatorname{ord}_p a\cdot\operatorname{ord}_q a$, knowing both is equivalent to knowing the product — one extra number, obtainable only at the cost of Section 5.

---

## 8. The sign: a complete, factorisation-free law at every modulus

A permutation of an $n$-element set with $c$ cycles has sign $(-1)^{n-c}$. So the parity of $N - C(N,a)$ is the coarsest possible summary of the readout. One might hope that a single bit distilled from the whole spectrum retains secret information. It does not.

### 8.1 Prime modulus: Zolotarev

**Theorem 8.1 (Zolotarev, cycle-count form).** Let $p$ be an odd prime, $\gcd(a,p)=1$. Then $a$ is a quadratic residue mod $p$ if and only if $i_p = (p-1)/\operatorname{ord}_p(a)$ is even, if and only if $p - C(p,a)$ is even.

*Proof sketch.* The unit group is cyclic of order $p-1$; writing $a = g^t$ for a generator $g$, $\operatorname{ord}_p(a) = (p-1)/\gcd(t,p-1)$ and $i_p = \gcd(t,p-1)$. Euler's criterion says $a$ is a square iff $t$ is even, which happens iff $\gcd(t,p-1)$ is even (using that $p-1$ is even). Finally $C(p,a) = 1+i_p$ by Corollary 3.6, so $p - C(p,a) = (p-1) - i_p \equiv i_p \pmod 2$. $\square$

### 8.2 Parity localisation and the general odd law

By (3.1), $C(N,a) = \sum_{e \mid N} i_e$, and by the classical identity $N = \sum_{e\mid N}\varphi(e)$ the parity of $N - C(N,a)$ is a sum of stratum contributions. The following three facts localise that parity onto the prime factors of $N$.

**Lemma 8.2 (parity-dead strata).** If $e = uv$ with $\gcd(u,v)=1$ and $u,v > 2$, then $i_e = \varphi(e)/\operatorname{ord}_e(a)$ is even.

*Proof sketch.* $\varphi(e) = \varphi(u)\varphi(v)$ with both factors even, while $\operatorname{ord}_e(a) = \operatorname{lcm}(\operatorname{ord}_u a, \operatorname{ord}_v a)$; the same lcm–gcd computation as in Theorem 7.1 gives $i_e = \gcd(\operatorname{ord}_u a, \operatorname{ord}_v a) i_u i_v$, and the two even totients force a surviving factor $2$. $\square$

**Lemma 8.3 (parity along a prime tower).** Let $p$ be an odd prime, $\gcd(a,p)=1$, $k\ge1$. Then $\operatorname{ord}_{p^k}(a) = \operatorname{ord}_p(a)\cdot p^{\,j}$ for some $0 \le j \le k-1$, and consequently $i_{p^k} = p^{\,k-1-j} i_p \equiv i_p \pmod 2$.

*Proof sketch.* $\operatorname{ord}_{p^k}(a) \mid \operatorname{ord}_p(a) p^{k-1}$ because $(\mathbb{Z}/p^k\mathbb{Z})^\times$ is the product of a cyclic group of order $p-1$ and one of order $p^{k-1}$; and $\operatorname{ord}_p(a) \mid \operatorname{ord}_{p^k}(a)$ by reduction. The cofactor $p^{k-1-j}$ is odd, so the index parity is constant along the tower. $\square$

**Proposition 8.4 (divisor-sum parity).** For odd $N \ge 1$ and $\gcd(a,N)=1$,
$$\sum_{e \mid N} i_e \;\equiv\; 1 + \sum_{p \in \mathrm{pf}(N)} i_p \pmod 2,$$
where $\mathrm{pf}(N)$ is the list of prime factors of $N$ **with multiplicity**.

*Proof sketch.* Induct on the number of prime factors. For $N = p^k$, Lemma 8.3 gives $\sum_{j\le k} i_{p^j} = 1 + \sum_{j=1}^k i_{p^j} \equiv 1 + k\,i_p$, which matches the right-hand side since $p$ occurs $k$ times in $\mathrm{pf}(N)$. For a coprime splitting, Lemma 8.2 kills every mixed divisor with two coprime parts $>2$, so only the pure prime-power divisors survive modulo $2$. $\square$

**Theorem 8.5 (readout parity).** For odd $N$ and $\gcd(a,N)=1$: $N - C(N,a) \equiv \sum_{p \in \mathrm{pf}(N)} i_p \pmod 2$.

*Proof.* $N = \sum_{e\mid N}\varphi(e)$ is odd, so $N \equiv 1$; combine with (3.1) and Proposition 8.4. $\square$

**Theorem 8.6 (general Zolotarev–Frobenius law).** For every odd $N \ge 1$ and every $a$ coprime to $N$,
$$J(a \mid N) = 1 \iff N - C(N,a) \ \text{ is even},$$
i.e. $\sigma_a$ is an even permutation of $\mathbb{Z}/N\mathbb{Z}$ precisely when the Jacobi symbol is $+1$.

*Proof.* $J(a\mid N) = \prod_{p \in \mathrm{pf}(N)} (a\mid p)$, and by Theorem 8.1 each Legendre symbol is $+1$ iff $i_p$ is even. Hence $J(a\mid N)=1$ iff the number of odd $i_p$ is even, iff $\sum_{p} i_p$ is even, which by Theorem 8.5 is the parity of $N - C(N,a)$. $\square$

### 8.3 Even modulus: the odd part is invisible

**Theorem 8.7 (even-modulus sign).** Write $N = 2^s m$ with $s \ge 1$ and $m$ odd, $\gcd(a,N)=1$. Then
$$N - C(N,a) \equiv \begin{cases} 0 \pmod 2, & s = 1,\\[2pt] i_4 = \varphi(4)/\operatorname{ord}_4(a) \pmod 2, & s \ge 2,\end{cases}$$
and $i_4$ is odd exactly when $a \equiv 3 \pmod 4$. Thus $\sigma_a$ is always even when $N \equiv 2 \pmod 4$, and when $4 \mid N$ it is odd exactly when $a \equiv 3 \pmod 4$ — **independently of the odd part $m$**.

*Proof sketch.* Two ingredients. First a doubling law: $i_{2j} = i_j$ for odd $j$, because $(\mathbb{Z}/2j\mathbb{Z})^\times \cong (\mathbb{Z}/j\mathbb{Z})^\times$; this pairs off the divisors $e$ and $2e$ of $N$, cancelling their contributions modulo $2$. Second, an exponent bound: for odd $a$ and $t \ge 3$, $\operatorname{ord}_{2^t}(a) \mid 2^{t-2}$, so $i_{2^t} = \varphi(2^t)/\operatorname{ord}_{2^t}(a)$ is divisible by $2^{t-1}/2^{t-2} = 2$ — the pure $2$-power strata above $4$ are parity-dead. Together with Lemma 8.2 for the mixed divisors, only the divisor $4$ survives, and $\operatorname{ord}_4(a) = 1$ or $2$ according as $a \equiv 1$ or $3 \pmod 4$, giving $i_4 = 2$ or $1$. $\square$

**Theorem 8.8 (complete sign law).** For every $N \ge 1$ and every $a$ coprime to $N$,
$$N - C(N,a) \ \text{is even} \iff \begin{cases} J(a \mid N) = 1, & N \text{ odd},\\ 4 \mid N \Rightarrow a \equiv 1 \!\!\pmod 4, & N \text{ even}.\end{cases}$$

Both alternatives are computable in polynomial time from $a$ and $N$ alone — the Jacobi symbol by quadratic reciprocity, the second by inspection of $a \bmod 4$. **The sign bit of the readout is free.** No attack can extract secret structure from it.

---

## 9. Two enlargements of the attack surface, closed

### 9.1 A cycle count for arbitrary self-maps

To compare families of permutations we need a uniform notion. For an arbitrary $f : \mathbb{Z}/N\mathbb{Z} \to \mathbb{Z}/N\mathbb{Z}$ define the *iteration orbit* $\mathcal{O}_f(x) = \{f^{[k]}(x) : 0 \le k < N\}$ and let $C_f$ be the number of distinct sets $\mathcal{O}_f(x)$, $x \in \mathbb{Z}/N\mathbb{Z}$. For a permutation of an $N$-element set every orbit closes within $N$ steps, so $C_f$ is the honest cycle count; and for $f = \sigma_a$ one recovers $C_f = C(N,a)$.

**Lemma 9.1 (conjugation invariance).** If $e$ is a bijection of $\mathbb{Z}/N\mathbb{Z}$ with $e \circ f = g \circ e$, then $C_g = C_f$.

*Proof sketch.* Induction gives $g^{[k]}(e(x)) = e(f^{[k]}(x))$, so $\mathcal{O}_g(e(x)) = e(\mathcal{O}_f(x))$; the map $S \mapsto e(S)$ is injective on subsets and carries the family of $f$-orbits bijectively to the family of $g$-orbits. $\square$

### 9.2 Affine maps

**Theorem 9.2 (invisible shift).** Let $\gcd(a,N)=1$ and suppose $1 - a$ is invertible modulo $N$. Then for every $b$,
$$C\bigl(x \mapsto ax+b\bigr) \;=\; C(N,a).$$

*Proof.* Let $c = b(1-a)^{-1}$, so $ac + b = c$. The translation $e(x) = x + c$ satisfies $e(ax) = ax + c = a x + ac + b = a(x+c) + b$, i.e. $e \circ \sigma_a = \sigma_{a,b}\circ e$ where $\sigma_{a,b}(x)=ax+b$. Apply Lemma 9.1. $\square$

**Theorem 9.3 (pure translation).** For $b \in \mathbb{Z}/N\mathbb{Z}$, the translation $x \mapsto x+b$ has exactly $\gcd(N,b)$ cycles, all of length $N/\gcd(N,b)$.

*Proof sketch.* Every orbit is a coset of the cyclic subgroup generated by $b$, whose order is $N/\gcd(N,b)$; the number of cosets is $\gcd(N,b)$. $\square$

The general case interpolates between these two extremes, and the answer is a single gcd.

**Theorem 9.4 (classification of the affine readout).** Let $A$ be a unit of $\mathbb{Z}/N\mathbb{Z}$ and put $g = \gcd\bigl(N,\ A - 1\bigr)$. Then for all shifts $b, b'$,
$$\gcd(g, b) = \gcd(g, b') \implies C\bigl(x\mapsto Ax+b\bigr) = C\bigl(x\mapsto Ax+b'\bigr).$$
In particular $C(x \mapsto Ax+b) = C(N,A)$ whenever $g \mid b$, and Theorem 9.2 is the case $g=1$.

*Proof sketch.* Two conjugations act on the family $\sigma_{A,b}$: rescaling by a unit $u$ (i.e. $e(x)=ux$) sends $\sigma_{A,b}$ to $\sigma_{A,ub}$, and translating by $t$ sends $\sigma_{A,b}$ to $\sigma_{A,b+(A-1)t}$. Hence the cycle count is a function of the orbit of $b$ under $b \mapsto ub + (A-1)t$, $u \in (\mathbb{Z}/N\mathbb{Z})^\times$, $t \in \mathbb{Z}/N\mathbb{Z}$. Bézout's identity realises $g$ inside the ideal generated by $A-1$ and $N$, and a standard computation shows that this orbit is exactly $\{b' : \gcd(g,b') = \gcd(g,b)\}$. Lemma 9.1 finishes. $\square$

**Interpretation.** Enlarging the family $x \mapsto ax$ (one parameter) to $x \mapsto ax + b$ (two parameters) buys exactly one additional gcd probe, $\gcd(N, a-1, b)$ — polynomial-time computable without any factorisation. The affine readout adds nothing.

**Theorem 9.5 (affine sign law).** For every $N$, every $a$ coprime to $N$, and every shift $b$,
$$N - C(x\mapsto ax+b) \;\equiv\; \bigl(N - C(N,a)\bigr) + \bigl(N - \gcd(N,b)\bigr) \pmod 2 .$$
That is, $\mathrm{sign}(\sigma_{a,b}) = \mathrm{sign}(\sigma_a)\cdot\mathrm{sign}(x\mapsto x+b)$.

*Proof sketch.* Use the general fact that a permutation $\pi$ of a finite set $X$ has $\mathrm{sign}(\pi) = (-1)^{|X| - \#\mathrm{orbits}(\pi)}$, together with multiplicativity of the sign: $\sigma_{a,b} = \tau_b \circ \sigma_a$ where $\tau_b(x)=x+b$. Theorem 9.3 supplies $\#\mathrm{orbits}(\tau_b) = \gcd(N,b)$. $\square$

**Corollary 9.6.** At an odd modulus $N$ the shift never affects the sign — for $N$ odd, $N - \gcd(N,b)$ is even iff $\gcd(N,b)$ is odd, which always holds — so $\mathrm{sign}(\sigma_{a,b})$ equals $J(a\mid N)$ for every $a$ and every $b$: again factorisation-free.

### 9.3 Power maps

**Theorem 9.7 (power readout at a prime).** Let $p$ be prime and $k \ge 1$ with $\gcd(k, p-1)=1$, so that $x \mapsto x^k$ is a permutation of $\mathbb{Z}/p\mathbb{Z}$. Then
$$C\bigl(x \mapsto x^k \ \text{on } \mathbb{Z}/p\mathbb{Z}\bigr) \;=\; C\bigl(p-1,\ k\bigr) \;+\; 1 ,$$
the right-hand count being that of the *multiplication* permutation $y \mapsto ky$ of $\mathbb{Z}/(p-1)\mathbb{Z}$.

*Proof sketch.* Fix a primitive root $g$ mod $p$. The discrete logarithm is a bijection $\mathbb{Z}/p\mathbb{Z} \to \mathrm{Option}\bigl(\mathbb{Z}/(p-1)\mathbb{Z}\bigr)$ sending $0$ to the extra point and $g^y$ to $y$; under it $x \mapsto x^k$ becomes $y \mapsto ky$ with the extra point fixed. Orbit counts are invariant under conjugation by a bijection, and adjoining a fixed point adds exactly one orbit. $\square$

So the power readout is the multiplicative readout **one level down**, at the modulus $p-1$. Since $p-1$ is even, Theorem 8.7 applies verbatim and yields:

**Theorem 9.8 (power-map sign law).** For an odd prime $p$ and $k \ge 1$ with $\gcd(k,p-1)=1$, the permutation $x \mapsto x^k$ of $\mathbb{Z}/p\mathbb{Z}$ is even if and only if
$$4 \mid p-1 \implies k \equiv 1 \pmod 4 .$$

Once more the sign is explicit and factorisation-free.

---

## 10. Algorithms

We record the procedures implicit above, with their costs.

**Algorithm A (stratified cycle count).** *Input:* $N$, $a$ with $\gcd(a,N)=1$. *Output:* $C(N,a)$.
For each divisor $d$ of $N$, compute $M = N/d$, then $\varphi(M)$ and $\operatorname{ord}_M(a)$, and accumulate $\varphi(M)/\operatorname{ord}_M(a)$. Cost: $\tau(N)$ order computations. Note this is a *predictive* formula for someone who already knows the factorisation of $N$; it is not available to an adversary.

**Algorithm B (brute-force readout).** *Input:* $N$, $a$. *Output:* the multiset of cycle lengths.
Mark all elements unvisited; for each unvisited $x$, walk $x, ax, a^2x, \dots$ until returning to $x$, marking as you go and recording the length. Cost: exactly $N$ map applications and $O(N)$ memory. This is the honest cost of the readout for someone without the factorisation, and it is the content of barrier 5.2.

**Algorithm C (factoring from an informative point).** *Input:* $N = pq$, a multiplier $a$ primitive at $q$, and a point $x \in S_p$. *Output:* $q$.
Walk the cycle through $x$ and return (length $+ 1$). Correct by Theorem 4.2 — but note that Theorem 5.1 makes the *input* $x$ already a factorisation of $N$: the algorithm is correct and useless.

**Algorithm D (Burnside cross-check).** *Input:* $N$, $a$. *Output:* verification of (6.1).
Compute $L = \operatorname{ord}_N(a)$ and $\sum_{k<L}\gcd(N,a^k-1)$ by repeated squaring and Euclid; compare with $L\cdot C(N,a)$. Cost $O(L \log^2 N)$. Any $k$ with $1 < \gcd(N,a^k-1) < N$ is a successful Pollard probe.

**Algorithm E (free sign prediction).** *Input:* $N$, $a$. *Output:* the parity of $N - C(N,a)$.
If $N$ is odd, return "even" iff $J(a\mid N)=1$ (reciprocity, $O(\log^2 N)$); if $N$ is even, return "even" iff ($4 \nmid N$ or $a \equiv 1 \bmod 4$). Correct by Theorem 8.8. Cost: polynomial, no factorisation. This algorithm predicts a global invariant of a permutation on $N$ points without ever touching the permutation.

---

## 11. Numerical illustrations

**$N = 143 = 11\cdot 13$, $a=2$.** $\operatorname{ord}_{143}(2)=60$, $\operatorname{ord}_{11}(2)=10$, $\operatorname{ord}_{13}(2)=12$. Strata: $|S_1|=120$ with $2$ cycles of length $60$; $|S_{11}|=12$ with one cycle of length $12$; $|S_{13}|=10$ with one cycle of length $10$; $|S_{143}|=1$. Total $C=5$, matching (4.1). Burnside: $60\cdot 5 = 300 = \sum_{k<60}\gcd(143, 2^k-1)$, the sum consisting of $143$ (at $k=0$), nine hits of value $11$ or $13$, and the rest $1$ — each hit a successful Pollard probe (e.g. $k=10$ gives $11$, $k=12$ gives $13$).

**$N=65$, $a=57$ vs $b=31$.** $\operatorname{ord}_{65}(57)=\operatorname{ord}_{65}(31)=4$; unit-stratum data identical. $C(65,57)=17$, $C(65,31)=20$. The readouts differ; the lcm does not. Signs: $65-17 = 48$ even and $J(57\mid65)=+1$; $65-20=45$ odd and $J(31\mid65)=-1$ — Theorem 8.6 in action.

**Excess.** $N=13\cdot 17$, $a=7$: $\operatorname{ord}_{13}(7)=12$, $\operatorname{ord}_{17}(7)=16$, $i_p=i_q=1$, $\gcd=4$; (7.1) predicts $2\cdot 2 + 3 = 7 = C(221,7)$.

**Affine.** $N=15$, $A=4$: $g=\gcd(15,3)=3$. Shifts with $\gcd(3,b)=3$ give $9$ cycles (the multiplicative value), shifts with $\gcd(3,b)=1$ give $3$ — exactly two classes, as Theorem 9.4 requires. For $A=2$, $g=1$ and all $15$ shifts give the same count $5$.

**Power maps.** $p=13$: $k=5$ gives $9$ cycles $=C(12,5)+1$; $k=7$ gives $10 = C(12,7)+1$. Since $4 \mid 12$, the sign law says $x\mapsto x^k$ is even iff $k\equiv 1 \pmod 4$: indeed $k=1,5$ are even permutations and $k=7,11$ odd.

**Cost.** For $N=3127=53\cdot59$ the enumeration touches all $3127$ points ($\varphi(N)=3016$ of them units), while $\lfloor\sqrt N\rfloor = 55$; informative points number $111$, density $0.036 \le 6/\sqrt{N} \approx 0.107$. For $N = 34571 = 181\cdot 191$: $34571$ points versus $\lfloor\sqrt N\rfloor = 185$, informative density $0.011$.

---

## 12. Discussion

### 12.1 What kind of barrier is this?

The usual vocabulary of cryptographic hardness — one-wayness, unstructuredness, generic-group lower bounds — does not describe the situation here. The secret is not hidden by the object: the cycle structure of $\sigma_a$ *displays* $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ separately and permits reading $q$ off a single cycle by a subtraction. The obstruction is that the object is an enumeration of $N$ elements whose informative region is exactly the set of points that already constitute a factorisation. One might call this an **access barrier** rather than an information barrier: the information is present, exact, and cheap to interpret, but the apparatus for viewing it costs $\Theta(N)$ and its interesting sub-apparatus is inaccessible by construction.

This suggests a sharper way to formulate hardness claims for order-based attacks: not "the readout is symmetric" (it is not) but "every polynomial-time-accessible functional of the readout is computable from $(N,a)$ alone". Sections 6, 8 and 9 verify exactly this for the natural candidates: the cycle count is a Pollard aggregate; the sign is a Jacobi symbol (odd $N$) or a residue condition mod $4$ (even $N$); the affine extension adds one gcd; the power maps are the same readout one level down.

### 12.2 Placement in the order-probe hierarchy

The results complete a natural three-step characterisation of multiplicative orders as an attack resource:

* **Free as probes.** Anything computable inside $(\mathbb{Z}/N\mathbb{Z})^\times$ is available to the adversary — but by (1.1) it is lcm-flattened.
* **Partial as constraints.** Order information constrains the smooth parts of $p-1$ and $q-1$, which is what Pollard's $p-1$ exploits; Theorem 6.3 shows the cycle count is precisely the aggregate of those constraints and improves on them only when they already succeed.
* **Sealed as readouts.** The ring-level permutation does separate the individual orders (Theorem 4.1) and does factor (Theorem 4.2), yet is sealed behind the three barriers of Section 5 and the freeness results of Sections 8–9.

### 12.3 Positive by-products

Although the cryptanalytic verdict is negative, several statements are of independent interest:

* The stratification law (Theorem 3.5) is a clean closed form for the cycle type of multiplication on a general residue ring, and specialises to a divisor-sum formula for prime powers (Corollary 3.7).
* Theorem 8.6 is a Zolotarev–Frobenius theorem for arbitrary odd moduli, proved by parity localisation over strata; Theorem 8.7 completes it at even moduli, where the phenomenon that the sign forgets the odd part of $N$ entirely seems worth advertising.
* Theorem 9.4 is a complete classification of the affine cycle count in terms of a single gcd, and Theorem 9.7 identifies the power-map readout at a prime with the multiplicative readout at $p-1$.

---

## 13. Future directions

1. **A barrier-4 lower bound.** Prove unconditionally that *any* algorithm extracting an individual prime order from the ring-level readout requires $\Omega(N)$ operations, in a model that captures "iterating the permutation" without presupposing a specific implementation. The Burnside identity (6.1) suggests the right currency: what an algorithm can learn cheaply is a partial sum of Pollard probes.
2. **A quantum channel.** Period-finding samples group structure without enumerating it. Is there a quantum procedure whose measurement statistics see the *stratified* structure — the individual $\operatorname{ord}_{N/d}(a)$ — rather than only the global $\operatorname{ord}_N(a)$? The strata are not subgroups, so the standard hidden-subgroup framework does not directly apply.
3. **Hint amplification.** All barriers here are for the uniform, hint-free setting. If an adversary is given a weak hint about $p$ or $q$ (a few bits, an approximation, a smoothness promise), does the stratified readout amplify it? Theorem 5.3's density bound is the quantitative statement to beat.
4. **Beyond affine and power families.** The two enlargements analysed here collapse to the multiplicative readout. Are there permutation families of $\mathbb{Z}/N\mathbb{Z}$, still cheap to specify, whose cycle structure is *not* conjugate to a multiplicative one and not a readout one level down?
5. **General moduli and higher-degree strata.** The excess formula (7.1) is stated for two prime factors. What is the exact surplus for $N$ with $r$ prime factors, and is there an inclusion–exclusion form of the "only the gcds are new" principle?
6. **Signs of other arithmetic permutations.** Theorems 8.8 and 9.8 give complete sign laws for multiplication, affine maps and power maps. The same parity-localisation technique should apply to further natural families (e.g. Möbius transformations on the projective line over $\mathbb{Z}/N\mathbb{Z}$), each time asking whether the resulting invariant is factorisation-free.

---

## 14. Conclusion

The permutation $x \mapsto ax$ of $\mathbb{Z}/N\mathbb{Z}$ has a completely determined cycle structure: strata indexed by the divisors of $N$, with sizes $\varphi(N/d)$ and uniform cycle lengths $\operatorname{ord}_{N/d}(a)$. For a semiprime this separates the two prime orders into distinct cycle lengths, defeating the lcm-blindness that limits unit-group probes, and yields a correct factoring algorithm. It is nonetheless useless: informative points are themselves factorisations, the enumeration costs more than trial division, individual cycle lengths are order-finding problems, the cycle count is an aggregate of Pollard probes that beats its floor only when a probe already wins, the surplus over the lcm is exactly one gcd, and every coarse summary — the sign at any modulus, the affine extension, the power maps — is computable in polynomial time from $N$ and $a$ alone. The asymmetric readout exists, is exactly understood, and is sealed.
