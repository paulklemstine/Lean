# Period Certificates, the Two-Adic Splitting Criterion, and the Per-Modulus Unlucky Cap

**Author:** Aristotle
**Date:** 2026-09-17

---

## Abstract

The order-finding route to integer factorization rests on a probabilistic folklore claim: a period certificate for a base $a$ modulo a semiprime $N$ factors $N$ "with good probability", and repeated sampling drives the success rate toward certainty. We show that this claim conflates two entirely different sources of randomness, and we separate them exactly. For an odd semiprime $N = pq$ with distinct prime factors and a unit $a$ with per-prime multiplicative orders $d_p = 2^i u$ and $d_q = 2^j v$ ($u,v$ odd), we prove the **two-adic splitting criterion**: some even period of $a$ yields a nontrivial factor of $N$ via the greatest-common-divisor step if and only if $i \neq j$. The negative half — the **unlucky cap** — is quantified over all exponents, hence over all measurement outcomes and all sampling budgets: a matched-valuation base is permanently unlucky, and no number of samples can change that. The positive half is constructive: when $j < i$ the halved exact order $L/2$, with $L = \operatorname{lcm}(d_p,d_q)$, splits $N$ on the first certificate.

We complement the criterion with three further results. First, a **density bound**: in a product of two cyclic groups of even order — the Chinese-Remainder shape of the unit group modulo an odd semiprime — at most half of all elements have coordinate orders with equal two-adic valuation, so re-drawing the base escapes the cap with probability at least $1/2$; and an explicit splitting base always exists. Second, a **construction theorem** for order-controlled populations: in a finite group, $g^{n/d}$ has order exactly $d$ whenever $d \mid n = \operatorname{ord}(g)$, and for every divisor $r$ of $p-1$ the units modulo a prime $p$ contain an element of exact order $r$. Third, an analysis of the **fungibility ramp** $P(s) = C(1-(1-p)^s)$: samples compound as independence, gains are antitone, small budgets are priced linearly by a union bound, the ceiling is approached but never attained at any finite budget, and the population-averaged ceiling factorizes as certification rate times mixed-role fraction. Experimental results on constructed controlled-order semiprimes with control parameters $r \in \{210, 310, 434, 510\}$ confirm all of this: the single-sample factoring probability climbs $0.018 \to 0.056 \to 0.158 \to 0.181$ with register size, sample ladders track $1-(1-0.06)^s$, and the population saturates at $\approx 0.53$ — the certification rate times the roughly two-thirds mixed-role share. The outcome taxonomy ($0.844$ spurious or partial certificates, $0.109$ permanently unlucky, $0.044$ factor extracted, $0.003$ no certificate) locates the dominant classical cost in certificate filtering rather than certification.

**Keywords:** order finding, period certificate, two-adic valuation, semiprime factorization, Chinese Remainder Theorem, cyclic group density, sample complexity, structural cap.

---

## 1. Introduction

### 1.1 Sampling as a currency

A randomized procedure that succeeds with probability $p$ per trial succeeds at least once in $s$ independent trials with probability $1-(1-p)^s$. This formula is the backbone of a great deal of algorithmic practice, and of the cost accounting for quantum order finding in particular: to raise confidence, raise the shot count. Call this the **fungibility hypothesis** — that measurement samples are a currency exchangeable for success probability at a fixed, budget-independent rate.

The hypothesis fails silently in the presence of *structurally dead instances*: instances whose per-sample success probability is not small but exactly zero. Averaging over a population containing a positive fraction of dead instances yields a success curve that still rises with the sample budget, still looks like an independence ladder, but converges to a ceiling strictly below one. The ceiling is invisible to any analysis that fits a single per-sample probability to the aggregate data; it is a property of the *population*, not of the sampling.

### 1.2 Order finding and the classical extraction step

Let $N = pq$ with $p \ne q$ odd primes, and let $a$ be a unit modulo $N$. Write $L = \operatorname{ord}_N(a)$ for the multiplicative order. If $L$ is even, then
$$\left(a^{L/2}-1\right)\left(a^{L/2}+1\right) = a^{L}-1 \equiv 0 \pmod N,$$
and provided $a^{L/2} \not\equiv \pm 1 \pmod N$ the greatest common divisor $\gcd(a^{L/2}-1, N)$ is a nontrivial factor of $N$. The order-finding subroutine supplies (a multiple of) $L$; everything downstream is classical arithmetic.

The standard analysis treats the proviso $a^{L/2} \not\equiv \pm 1$ as a probabilistic event over the random choice of $a$, and bounds its failure probability by $1/2$. That bound is about *choosing the base*. It says nothing about a base already fixed, and the cost model of a sampling experiment holds the base fixed while spending shots.

### 1.3 Contributions

This paper settles the fixed-base question completely.

1. **The two-adic splitting criterion** (Theorem 3.6). For a fixed base $a$, *some* period certificate splits $N$ if and only if the two-adic valuations of $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ differ. Both directions are uniform in the measurement outcome.

2. **The unlucky cap** (Theorems 3.2, 3.3). When the valuations agree, *every* halved even period is $\pm 1$ modulo $N$, so *every* certificate yields a trivial gcd. Structural, not probabilistic.

3. **Constructive splitting** (Theorem 3.5). When the valuations differ, the halved exact order $L/2$ is an explicit splitting exponent; the extracted gcd is exactly the prime whose order carries the larger valuation.

4. **Density and escape** (Theorems 5.1, 5.3, 5.4). At most half of the bases in a product of two even-order cyclic groups are permanently unlucky, and an explicit splitting base — a primitive root modulo $p$ glued to $1$ modulo $q$ — always exists.

5. **Order-controlled construction** (Theorems 4.1, 4.2) and the **controlled-order dichotomy** (Theorem 4.3), which realize the two horns of the criterion in a simulable population.

6. **The fungibility ramp** (Section 6): the per-instance ladder, its independence, monotonicity, diminishing-returns and union-bound properties, and the population-level results — the ramp is capped by the mixed-role average, strictly below it at every finite budget, converging to it, and the cap factorizes as certification rate times mixed-role fraction.

Section 7 reports the experimental campaign that motivated and confirms the theory; Section 8 discusses implications for cost models of quantum factoring; Section 9 lists open problems.

---

## 2. Definitions and conventions

Throughout, $p$ and $q$ denote distinct odd primes and $N = pq$.

**Definition 2.1 (Per-prime order).** For a natural number $a$ and a prime $p$ with $p \nmid a$, the *order of $a$ modulo $p$*, written $\operatorname{ord}_p(a)$, is the least positive $k$ with $a^k \equiv 1 \pmod p$; equivalently, the order of the residue of $a$ in the unit group of the integers modulo $p$. We use the basic fact that $a^m \equiv 1 \pmod p$ if and only if $\operatorname{ord}_p(a) \mid m$.

**Definition 2.2 (Two-adic valuation).** For a positive integer $d$, $v_2(d)$ is the exponent of $2$ in the prime factorization of $d$; equivalently the unique $i$ with $d = 2^i u$ and $u$ odd. Existence and uniqueness of this decomposition is elementary and is used throughout.

**Definition 2.3 (Period certificate).** An exponent $m$ is a *halved period* of $a$ modulo $N$ if $N \mid a^{2m} - 1$. We call the datum $2m$ a *period certificate*: it is what the order-finding stage can certify (a multiple of the order), and it is what the classical stage consumes.

**Definition 2.4 (Splitting).** The exponent $m$ *splits* $N$, written $\operatorname{Splits}(a,p,q,m)$, if
$$\gcd\!\left(a^{m}-1,\; N\right) \in \{p, q\},$$
i.e. the gcd step returns a nontrivial factor. Since $\gcd(a^m-1,N)$ always divides $N = pq$, splitting is precisely the failure of the gcd to be $1$ or $N$.

**Definition 2.5 (Mixed and unlucky bases).** The base $a$ is *mixed* (for $N$) if $v_2(\operatorname{ord}_p a) \ne v_2(\operatorname{ord}_q a)$, and *permanently unlucky* otherwise.

**Definition 2.6 (Fungibility ramp).** For a ceiling $C \in [0,1]$, a per-sample success probability $p \in [0,1]$, and a budget $s \in \mathbb{N}$,
$$\operatorname{ramp}(C,p,s) := C\left(1-(1-p)^s\right).$$

**Definition 2.7 (Population ramp).** Let $P$ be a finite index set of instances, $\text{mixed}(i)$ a predicate, and $C_i, p_i$ per-instance ceilings and per-sample probabilities. Then
$$P_{\mathrm{pop}}(s) := \frac{1}{|P|}\sum_{i \in P} \big[\text{mixed}(i)\big]\cdot \operatorname{ramp}(C_i,p_i,s),
\qquad
C_{\mathrm{pop}} := \frac{1}{|P|}\sum_{i \in P} \big[\text{mixed}(i)\big]\cdot C_i,$$
where $[\cdot]$ is the indicator. The *mixed-role fraction* is $\mu := |\{i \in P : \text{mixed}(i)\}| / |P|$.

---

## 3. The sharp criterion

We first record the two arithmetic facts that drive everything.

**Lemma 3.0 (Square roots of unity modulo a prime).** Let $p$ be prime and suppose $p \mid a^{2m}-1$. Then $a^{m} \equiv 1 \pmod p$ or $a^m \equiv -1 \pmod p$.

*Proof sketch.* The residues modulo a prime form a field, and $x := a^m$ satisfies $x^2 = 1$, so $(x-1)(x+1)=0$ and one of the two factors vanishes. $\square$

**Lemma 3.1 (Common periods lift to the semiprime).** If $\operatorname{ord}_p(a) \mid m$ and $\operatorname{ord}_q(a) \mid m$, then $N = pq$ divides $a^m - 1$.

*Proof sketch.* Each hypothesis gives $p \mid a^m - 1$ and $q \mid a^m - 1$; since $p$ and $q$ are distinct primes they are coprime, so their product divides $a^m-1$. $\square$

The first main result upgrades Lemma 3.0 from one prime to the semiprime, under a divisibility-equivalence hypothesis.

**Theorem 3.2 (The unlucky cap, divisibility form).** Let $N = pq$ with $p \ne q$ odd primes, let $a$ be a unit, and suppose that for a given exponent $m$,
$$\operatorname{ord}_p(a) \mid m \iff \operatorname{ord}_q(a) \mid m .$$
If $N \mid a^{2m}-1$, then $N \mid a^m - 1$ or $N \mid a^m + 1$.

*Proof sketch.* From $N \mid a^{2m}-1$ we get $p \mid a^{2m}-1$ and $q \mid a^{2m}-1$, so by Lemma 3.0 each of $a^m \bmod p$ and $a^m \bmod q$ is $\pm 1$. The value is $+1$ modulo $p$ exactly when $\operatorname{ord}_p(a) \mid m$, and similarly for $q$; the hypothesis therefore forces the two signs to coincide. If both are $+1$, coprimality of $p$ and $q$ gives $N \mid a^m-1$; if both are $-1$, it gives $N \mid a^m+1$. $\square$

Two hypotheses imply the divisibility equivalence. The crude one is equality of the orders. The sharp one is equality of their two-adic valuations, and it is the one that matters.

**Lemma 3.2a (Odd-part transfer).** Let $u, v$ be odd and $k \ge 0$. If $2^k u \mid m$ and $2^k v \mid 2m$, then $2^k v \mid m$.

*Proof sketch.* From $2^k v \mid 2m$ we get $v \mid 2m$, and $v$ is odd, so $v \mid m$. From $2^k u \mid m$ we get $2^k \mid m$. Since $2^k$ and the odd number $v$ are coprime, their product divides $m$. $\square$

The hypothesis $2^k v \mid 2m$ is exactly what a period certificate supplies: if $N \mid a^{2m}-1$ then both per-prime orders divide $2m$. Hence, when the two orders share the two-adic part $2^k$, the conditions $\operatorname{ord}_p(a)\mid m$ and $\operatorname{ord}_q(a)\mid m$ are *equivalent* — each implies the other by Lemma 3.2a. This is precisely the divisibility equivalence required by Theorem 3.2.

**Theorem 3.3 (The unlucky cap, two-adic form).** Let $N = pq$ with $p \neq q$ odd primes and let $a$ have per-prime orders $\operatorname{ord}_p(a) = 2^{k}u$ and $\operatorname{ord}_q(a) = 2^{k}v$ with $u, v$ odd — the same two-adic valuation $k$. Then for every exponent $m$ with $N \mid a^{2m}-1$,
$$N \mid a^m - 1 \quad\text{or}\quad N \mid a^m + 1 .$$
Consequently $\gcd(a^m-1,N) \in \{1, N\}$ for every such $m$: no period certificate whatsoever extracts a factor.

*Proof sketch.* Since $N \mid a^{2m}-1$, both orders divide $2m$; Lemma 3.2a applied in both directions supplies the divisibility equivalence required by Theorem 3.2, giving $N \mid a^m \mp 1$. For the gcd statement: in the first case $N \mid a^m -1$, so the gcd is $N$. In the second case any common divisor of $a^m-1$ and $N$ also divides $(a^m+1)-(a^m-1) = 2$; since $N$ is odd, the gcd is $1$. $\square$

**Corollary 3.4 (Sample-budget invariance).** For an unlucky base, the probability of extracting a factor is $0$ at every sample budget $s$, because the event is empty in the exponent variable: the sampling stage can only ever produce multiples of the order, and Theorem 3.3 quantifies over all of them.

The positive direction needs one lemma about least common multiples and one about the gcd.

**Lemma 3.5a (Two-adic part of an lcm).** For odd $u,v$ and $j \le i$,
$$\operatorname{lcm}\!\left(2^i u,\ 2^j v\right) = 2^i \operatorname{lcm}(u,v).$$

*Proof sketch.* The exponent of $2$ in an lcm is the maximum of the exponents, namely $i$; for each odd prime the exponent is the maximum over $u$ and $v$. $\square$

**Lemma 3.5b (Splitting criterion).** If $\operatorname{ord}_p(a) \mid m$ but $\operatorname{ord}_q(a) \nmid m$, then $\gcd(a^m-1, N) = p$.

*Proof sketch.* The first hypothesis gives $p \mid a^m - 1$; the second gives $q \nmid a^m -1$. Hence the gcd, a divisor of $pq$, is divisible by $p$ and not by $q$, so equals $p$. $\square$

**Theorem 3.5 (Mixed valuations always split).** Let $\operatorname{ord}_p(a) = 2^i u$ and $\operatorname{ord}_q(a) = 2^j v$ with $u,v$ odd and $j < i$, and let $L = \operatorname{lcm}(\operatorname{ord}_p a, \operatorname{ord}_q a)$. Then $2 \cdot (L/2) = L$ is a period certificate of $a$ modulo $N$, and
$$\gcd\!\left(a^{L/2}-1,\ N\right) = q .$$

*Proof sketch.* By Lemma 3.5a, $L = 2^i\operatorname{lcm}(u,v)$, so $L/2 = 2^{i-1}\operatorname{lcm}(u,v)$. Since $j \le i-1$ and $v \mid \operatorname{lcm}(u,v)$, we get $\operatorname{ord}_q(a) = 2^j v \mid L/2$. Conversely $\operatorname{ord}_p(a) = 2^i u \nmid L/2$ because the power of two in $L/2$ is $2^{i-1}$ and $\operatorname{lcm}(u,v)$ is odd. Lemma 3.5b, with the roles of $p$ and $q$ exchanged, gives $\gcd = q$. That $L$ is a period follows from Lemma 3.1. $\square$

Combining the two horns:

**Theorem 3.6 (The two-adic splitting criterion).** Let $N = pq$ with $p \ne q$ odd primes, and let $a$ be a unit with $\operatorname{ord}_p(a) = 2^i u$, $\operatorname{ord}_q(a) = 2^j v$, $u,v$ odd. Then
$$\Big(\exists\, m:\ N \mid a^{2m}-1 \ \text{ and }\ \operatorname{Splits}(a,p,q,m)\Big) \iff i \neq j.$$

*Proof sketch.* ($\Leftarrow$) If $j<i$ apply Theorem 3.5; if $i<j$ apply it with $p$ and $q$ exchanged. ($\Rightarrow$) Contrapositive: if $i = j$, Theorem 3.3 makes every gcd trivial, and a trivial gcd is not a nontrivial factor. $\square$

Since every positive integer decomposes as $2^i u$ with $u$ odd, Theorem 3.6 applies to *every* unit: the set of bases usable for factoring $N$ through period certificates is exactly the set of mixed bases.

**Remark 3.7 (Why valuation, not order).** Equality of the orders is sufficient for unluckiness but far from necessary: $\operatorname{ord}_p(a)=22=2\cdot 11$ and $\operatorname{ord}_q(a)=14=2\cdot 7$ are different orders with the same valuation, and such a base is permanently unlucky. This is the gap the sharp criterion closes: the correct invariant is the pair of valuations, not the pair of orders.

---

## 4. Order-controlled populations

Testing the criterion on cryptographic semiprimes is impossible by simulation: the order of a typical base modulo $N=pq$ is of size $\operatorname{lcm}(p-1,q-1)$, already around $2^{30}$ for modest parameters, so a register simulation of period finding is out of reach. Searching at random for small semiprimes with prescribed *simultaneous* per-prime orders is equally hopeless — the density of such configurations is on the order of $10^{-7}$ in the relevant ranges. The remedy is construction rather than search, and it rests on two theorems.

**Theorem 4.1 (Projection produces prescribed order).** Let $G$ be a finite group, $g \in G$ with $n = \operatorname{ord}(g)$, and $d \mid n$. Then
$$\operatorname{ord}\!\left(g^{\,n/d}\right) = d .$$

*Proof sketch.* In a finite group $\operatorname{ord}(g^k) = n/\gcd(n,k)$. With $k = n/d$, a divisor of $n$, we have $\gcd(n, n/d) = n/d$, so the order is $n/(n/d) = d$. $\square$

**Theorem 4.2 (Prescribed orders exist modulo $p \equiv 1 \bmod r$).** Let $p$ be prime and $r \mid p-1$. Then the unit group modulo $p$ contains an element of exact order $r$.

*Proof sketch.* The unit group is cyclic of order $p-1$; take a generator $g$ and apply Theorem 4.1 with $n=p-1$ and $d=r$. $\square$

**The construction.** Fix a control parameter $r$ (in the experiments, $r \in \{210, 310, 434, 510\}$; all are twice an odd number). Choose primes $p, q \equiv 1 \pmod r$ by scanning $kr+1$. Draw per-prime orders $d_p, d_q$ independently and uniformly from $\{r, r/2\}$, realize elements of those exact orders by projection (Theorem 4.2), and combine them into a single base $a$ modulo $N=pq$ by the Chinese Remainder Theorem, so that $\operatorname{ord}_p(a) = d_p$ and $\operatorname{ord}_q(a)=d_q$ by construction. Writing $r = 2u$ with $u$ odd, the orders lie in $\{2u, u\}$, and the valuations are $1$ and $0$ respectively — so *equal orders* and *equal valuations* coincide on this population, and the dichotomy takes a particularly clean form.

**Theorem 4.3 (The controlled-order dichotomy).** Let $N = pq$ with $p \neq q$ odd primes, let $u$ be odd, and let $a$ have $\operatorname{ord}_p(a) \in \{2u, u\}$ and $\operatorname{ord}_q(a)\in\{2u,u\}$. Then:

1. if $\operatorname{ord}_p(a) = \operatorname{ord}_q(a)$, then for every $m$ with $N \mid a^{2m}-1$ the exponent $m$ does **not** split $N$; and
2. if $\operatorname{ord}_p(a) \neq \operatorname{ord}_q(a)$, then the exponent $u$ itself splits $N$.

*Proof sketch.* (1) Equal orders have equal valuations, so Theorem 3.3 applies and all gcds are trivial; a trivial gcd cannot equal $p$ or $q$, since $p < N$ and $q < N$ while the trivial values are $1$ and $N$. (2) Without loss of generality $\operatorname{ord}_p(a) = u$ and $\operatorname{ord}_q(a) = 2u$. Then $u \mid u$ but $2u \nmid u$ (as $u>0$), so Lemma 3.5b returns $\gcd(a^u-1,N) = p$. $\square$

It is convenient to package an instance of the construction as a tuple $I = (a,p,q,u)$ subject to the above hypotheses, with $\operatorname{Mixed}(I) :\iff \operatorname{ord}_p(a)\ne\operatorname{ord}_q(a)$ and $\operatorname{IsPeriodHalf}_I(m) :\iff N \mid a^{2m}-1$.

**Theorem 4.4 (Extractability equals mixedness).** For a controlled instance $I$,
$$\Big(\exists\, m:\ \operatorname{IsPeriodHalf}_I(m)\ \text{and}\ \operatorname{Splits}(a,p,q,m)\Big) \iff \operatorname{Mixed}(I).$$

*Proof sketch.* Right to left: take $m=u$ by Theorem 4.3(2), and note that $2u$ is a common multiple of both orders, so it is a period by Lemma 3.1. Left to right: contrapositive is Theorem 4.3(1). $\square$

Theorem 4.4 is the statement that makes the population model honest: the "welded" instances are exactly the non-mixed ones, and this holds at the level of *existence over all exponents*, not merely for the exponents a particular sampler is likely to output.

---

## 5. How many bases are unlucky?

The cap is per-base, so its practical importance is governed by the density of unlucky bases. The unit group modulo $N=pq$ is, by the Chinese Remainder Theorem, the product of two cyclic groups of even orders $p-1$ and $q-1$. We prove the density bound in that abstract setting.

**Lemma 5.0 (Lower half of a cyclic group).** Let $G$ be cyclic of even order $n$. Then exactly $n/2$ elements of $G$ have order dividing $n/2$.

*Proof sketch.* In a cyclic group of order $n$, for each divisor $e \mid n$ the number of elements of order dividing $e$ is exactly $e$. Apply with $e = n/2$. $\square$

**Theorem 5.1 (Level sets of the valuation are small).** Let $G$ be cyclic of even order $n$ and let $k \ge 0$. Then
$$\#\{x \in G : v_2(\operatorname{ord} x) = k\} \le n/2 .$$

*Proof sketch.* The case $k = v_2(n)$ — the top level — is the complement of the set of elements of order dividing $n/2$: halving $n$ drops its two-adic valuation by exactly one and leaves the odd part intact, so an element has order dividing $n/2$ precisely when its order has valuation strictly below $v_2(n)$. By Lemma 5.0 the top level therefore has exactly $n/2$ elements. For $k < v_2(n)$, every element of that level has order dividing $n/2$ — a divisor whose two-adic valuation is strictly smaller already divides the halved number — so the level is contained in a set of size $n/2$. Levels with $k > v_2(n)$ are empty. $\square$

**Theorem 5.2 (Unlucky pairs are at most half).** Let $G$ and $H$ be finite cyclic groups with $|H|$ even. Then
$$\#\{(x,y) \in G\times H : v_2(\operatorname{ord} x) = v_2(\operatorname{ord} y)\} \;\le\; |G|\cdot \frac{|H|}{2},$$
equivalently $2\cdot\#\{\text{unlucky pairs}\} \le |G|\cdot|H|$.

*Proof sketch.* Partition the pair count by the first coordinate: for fixed $x$, the admissible $y$ form the level set of $H$ at the fixed value $k = v_2(\operatorname{ord} x)$, of size at most $|H|/2$ by Theorem 5.1. Summing over $|G|$ choices of $x$ gives the bound. $\square$

**Corollary 5.3 (Density of permanently unlucky bases).** For an odd semiprime $N = pq$ with distinct prime factors, at most half of the units modulo $N$ are permanently unlucky; hence re-drawing the base escapes the structural cap with probability at least $1/2$ per draw.

*Proof sketch.* Transport Theorem 5.2 along the Chinese Remainder isomorphism, which matches the order of a residue modulo $p$ with the order of the first coordinate and likewise for $q$, and combine with the criterion of Theorem 3.6, under which unluckiness is exactly equality of coordinate valuations. $\square$

The abstract bound of Theorem 5.2 is proved unconditionally; Corollary 5.3 is its transport along an explicit group isomorphism, and its formal transport is listed in Section 9 as the first open task.

A concrete escape is also available, with no probability at all.

**Theorem 5.4 (Existence of a splitting base).** For every odd semiprime $N = pq$ with distinct prime factors there exist a base $a$ and an exponent $m$ such that $2m$ is a period of $a$ modulo $N$ and $\gcd(a^m-1,N)$ is a nontrivial factor of $N$.

*Proof sketch.* Take $g$ a primitive root modulo $p$ (Theorem 4.2 with $r=p-1$) and let $a$ be the Chinese-Remainder combination of $g$ modulo $p$ with $1$ modulo $q$. Then $\operatorname{ord}_p(a) = p-1$, which is even, and $\operatorname{ord}_q(a)=1$, which is odd, so the valuations differ and Theorem 3.5 applies. $\square$

**Empirical densities.** Exhaustive enumeration over all units for small semiprimes shows unlucky densities of $0.492$ for $N=7\cdot 11$, $0.244$ for $11\cdot 13$, $0.089$ for $13\cdot 17$, $0.059$ for $17 \cdot 19$, $0.249$ for $23\cdot 29$ and $31 \cdot 37$, $0.124$ for $41 \cdot 43$, and $0.250$ for $53 \cdot 59$ — all under the guaranteed one half, and clustering near one quarter for typical valuation profiles. In the same enumeration, the criterion of Theorem 3.6 agrees with brute-force search over all exponents in every single case, with zero mismatches.

---

## 6. The fungibility ramp

We now make precise the cost model that the structural cap constrains.

### 6.1 Per-instance ladder

Recall $\operatorname{ramp}(C,p,s) = C(1-(1-p)^s)$.

**Proposition 6.1 (Basic shape).** For $C \ge 0$ and $p \in [0,1]$:

1. *(One sample)* $\operatorname{ramp}(C,p,1) = Cp$.
2. *(Independence)* With unit ceiling, $1-\operatorname{ramp}(1,p,s+t) = \big(1-\operatorname{ramp}(1,p,s)\big)\big(1-\operatorname{ramp}(1,p,t)\big)$: failures multiply, so samples compound exactly as independent trials.
3. *(Marginal gain)* $\operatorname{ramp}(C,p,s+1)-\operatorname{ramp}(C,p,s) = C\,p\,(1-p)^s$.
4. *(Cap)* $\operatorname{ramp}(C,p,s) \le C$, with strict inequality for all finite $s$ whenever $C>0$ and $p<1$.
5. *(Monotonicity)* $s \mapsto \operatorname{ramp}(C,p,s)$ is monotone, and strictly increasing when $C>0$ and $0<p<1$.
6. *(Diminishing returns)* The gain sequence $C p (1-p)^s$ is antitone in $s$.
7. *(Linear pricing)* $\operatorname{ramp}(C,p,s) \le C\,p\,s$ — the union bound: small budgets buy success essentially linearly.
8. *(Convergence)* $\operatorname{ramp}(C,p,s) \to C$ as $s \to \infty$ for $p>0$.

*Proof sketch.* All eight items are direct computations with $(1-p)^s$; item 2 is the factorization $(1-p)^{s+t} = (1-p)^s(1-p)^t$, item 4 uses $0 < (1-p)^s$ for $p<1$, item 6 uses $(1-p)^{s+1}\le (1-p)^s$, item 7 is Bernoulli's inequality $(1-p)^s \ge 1-ps$, and item 8 is the geometric limit $(1-p)^s \to 0$. $\square$

Items 4 and 8 together are the precise sense in which the ceiling is asymptotic: reachable in the limit, unreachable at any finite budget.

### 6.2 Population ladder

With the notation of Definition 2.7:

**Theorem 6.2 (The population ramp is capped).** If $C_i \ge 0$ and $p_i \le 1$ for all $i \in P$, then $P_{\mathrm{pop}}(s) \le C_{\mathrm{pop}}$ for every $s$.

*Proof sketch.* Termwise, mixed instances obey Proposition 6.1(4) and unlucky instances contribute $0$ on both sides; sum and divide by $|P|$. $\square$

**Theorem 6.3 (Strict subsaturation).** If in addition some mixed instance $i_0 \in P$ has $C_{i_0} > 0$ and $p_{i_0} < 1$, then $P_{\mathrm{pop}}(s) < C_{\mathrm{pop}}$ for *every* finite $s$.

*Proof sketch.* The same termwise comparison, but strict at $i_0$ by Proposition 6.1(4), and a sum with one strict inequality is strict. $\square$

**Theorem 6.4 (Saturation value).** If $p_i > 0$ for all $i$, then $P_{\mathrm{pop}}(s) \to C_{\mathrm{pop}}$ as $s \to \infty$; and $P_{\mathrm{pop}}$ is monotone in $s$.

*Proof sketch.* Finite sums of convergent sequences converge, with the unlucky terms constant at $0$; divide by the constant $|P|$. Monotonicity is termwise from Proposition 6.1(5). $\square$

**Theorem 6.5 (The cap factorizes).** If every instance shares the same certification ceiling $C_i = C$, then
$$C_{\mathrm{pop}} = C\cdot\mu,$$
the product of the certification rate and the mixed-role fraction.

*Proof sketch.* The indicator-weighted sum of a constant is $C$ times the number of mixed instances; divide by $|P|$. $\square$

**Theorem 6.6 (Unlucky populations never move).** If no instance of $P$ is mixed, then $P_{\mathrm{pop}}(s) = 0$ for all $s$; conversely, every mixed instance admits a certificate that extracts a factor (Theorem 4.4), so a population of mixed instances has a strictly positive ceiling.

*Proof sketch.* Immediate from the definitions together with Theorem 4.4. $\square$

The content of this section is not that a capped exponential rises to its cap — that is calculus. It is the identification, made precise by Theorem 4.4, of the indicator $\text{mixed}(i)$ with an *arithmetic* property of the instance, and hence of the ceiling with a quantity that sampling cannot influence but base re-drawing can.

---

## 7. Experimental results

### 7.1 Design

Populations of controlled-order semiprimes were generated as in Section 4 for control parameters $r \in \{210, 310, 434, 510\}$, with primes $p,q \equiv 1 \pmod r$, per-prime orders drawn uniformly from $\{r, r/2\}$, and bases assembled by the Chinese Remainder Theorem. The period-finding stage was simulated with a phase register of size $t$, reported relative to the smallest register size at which certification becomes reliable (the "wall"). Each trial produced a measurement, a continued-fraction reconstruction of a candidate period, a certification check, and — when a certificate survived — the classical gcd extraction. Seeds were fixed; all reported quantities are computed from the recorded data.

### 7.2 The ramp against register size

Single-sample factoring probability $P_{\text{factor}}(s=1)$ as a function of register size:

| register size | $P_{\text{factor}}(s=1)$ |
|---|---|
| wall $-4$ | $0.018$ |
| wall $-2$ | $0.056$ |
| wall | $0.158$ |
| wall $+2$ | $0.181$ |

The same monotone ladder observed for abstract certification persists when the pipeline is required to output actual factors: enlarging the register buys success in the factoring metric, not merely in the certification metric.

### 7.3 Samples compound as independence

At register size wall $-2$, increasing the sample budget gave
$$P(1) = 0.056,\qquad P(4)=0.204,\qquad P(11)=0.471,$$
against the independence prediction $1-(1-0.06)^s = 0.060,\ 0.219,\ 0.494$. The agreement confirms Proposition 6.1(2) as an empirical law wherever the cap is not binding, and the small systematic shortfall is the cap beginning to bite.

### 7.4 Saturation and its factorization

Pushing the sample budget upward drove the population success rate to approximately $0.53$ and no further. This matches Theorem 6.5: the certification rate of the sampling stage multiplied by the mixed-role fraction of the population, which was approximately $2/3$ by design. Crucially, the saturation value is insensitive to the sample budget by construction of the population: increasing $s$ moves instances along their ladders but cannot make an unlucky instance contribute.

### 7.5 Outcome taxonomy

Over the full campaign, outcomes partitioned as

| outcome | share |
|---|---|
| spurious or partial certificate | $0.844$ |
| permanently unlucky base | $0.109$ |
| factor extracted | $0.044$ |
| no certificate produced | $0.003$ |

Two readings are worth emphasizing. First, failure to certify at all is negligible ($0.003$): certification is not the bottleneck. Second, the dominant burden — filtering spurious or partial certificates — is exactly the work of classical verification against $N$, which is cheap per item and therefore an aggregation problem rather than an algorithmic obstacle.

### 7.6 Method ledger

Four substantive defects were caught and corrected during the campaign, and are reported for completeness: (i) the naive design used real orders of size $\sim 2^{30}$, which are unsimulatable, forcing the controlled-order construction; (ii) a search for semiprimes with prescribed simultaneous orders was abandoned at an estimated density of $10^{-7}$ in favour of construction by the Chinese Remainder Theorem; (iii) the first constructed population produced all-zero measurements, which turned out to be the unlucky cap itself — identical per-prime orders — rather than a simulator bug, and this is what led to the theorems above; (iv) three implementation faults were fixed before any claim was recorded: an infinite loop on odd half-orders, an early return on the first certificate that masked later splitting certificates, and a hard-coded verdict string that was replaced by data-computed output.

---

## 8. Discussion

### 8.1 What the cap is, and is not

The cap is not a statement that factoring is hard, nor a limitation on quantum period finding as such. It is a statement about a *fixed base*: for a base whose per-prime orders share a two-adic valuation, the classical extraction step is provably incapable of returning a factor, for every certificate the quantum stage could produce. The standard success analysis of order-finding-based factoring already knows there is a failure mode; what is new here is that the failure mode is (a) exactly characterized by a two-integer comparison, (b) permanent per base rather than per trial, and (c) escapable by exactly one operation in the pipeline, namely re-drawing the base.

### 8.2 Consequences for cost models

Cost models for early quantum factoring typically price shots linearly and treat success probability as a smooth function of register size and shot count. The results here suggest a two-parameter model instead: a *ladder* parameter governing how success grows with shots, and a *ceiling* parameter governing what shots can ever buy. Only the first responds to the shot budget. In the short-register regime — the interesting one for near-term hardware — the correct optimization is therefore not "maximize shots" but "spend enough shots to approach the ladder's knee, then re-draw the base". The density bound of Theorem 5.2 quantifies the value of that re-draw: at least one half per attempt, and empirically closer to three quarters.

### 8.3 Where the classical work goes

The outcome taxonomy relocates the classical burden. Only $0.003$ of trials produced no certificate; $0.844$ produced a certificate that was spurious or only partially correct. The pipeline's classical stage is therefore dominated not by post-processing a good certificate but by *rejecting* bad ones — a task whose unit cost is a modular exponentiation and a gcd, and whose aggregate cost scales with the shot count. This inverts the intuitive picture in which the quantum device is the expensive component and the classical wrapper is bookkeeping.

### 8.4 A general moral about sampling

Beyond factoring, the structure identified here recurs whenever a randomized algorithm is applied to a population in which some instances are structurally dead. The aggregate success curve then has the form $C\mu(1-(1-p)^s)$, which is empirically indistinguishable from an ordinary independence ladder with a smaller per-sample probability until the budget grows large enough to reveal the ceiling. Fitting a single per-sample probability to such data systematically over-predicts the benefit of large budgets. The diagnostic is to look for an operation — analogous to re-drawing the base — that resamples the *instance* rather than the *trial*, and to price that operation separately.

---

## 9. Open problems and future work

1. **Transport of the density bound to residue bases.** Theorem 5.2 bounds unlucky pairs in an abstract product of cyclic groups; Corollary 5.3 states the consequence for units modulo $N = pq$. The remaining task is the careful bookkeeping that identifies the unit group modulo $pq$ with the product of the unit groups modulo $p$ and modulo $q$ *at the level of element orders*, matching $\operatorname{ord}_p(a)$ with the order of the first coordinate.

2. **Exact unlucky density as a function of the valuation pair.** The bound of one half is not tight. For cyclic groups of orders $2^{e_1}m_1$ and $2^{e_2}m_2$ with $m_1,m_2$ odd, the valuation profile of a cyclic group is geometric, so the coincidence probability should be a finite geometric sum rather than an inequality. The empirically observed densities near $0.25$ for typical moduli, and the value $0.254$ recorded across the sampled population, should be reproducible exactly from the pair $(e_1,e_2)$. Concretely: the number of elements of a cyclic group of order $2^e m$ ($m$ odd) whose order has valuation exactly $k$ is $2^{k-1}m'$-shaped for $1\le k \le e$ and behaves differently at $k=0$; assembling the two profiles gives a closed form.

3. **Beyond two prime factors.** For $N$ with $\omega$ distinct odd prime factors, the natural conjecture is that a period certificate splits $N$ if and only if the multiset of per-prime valuations is not constant, with the extracted factor determined by which coordinates carry the maximal valuation. The density of unlucky bases should then decay geometrically in $\omega$.

4. **Interaction with the choice of certificate.** The criterion asserts that *some* certificate splits when the valuations differ, and exhibits $L/2$. For a sampler that outputs random multiples of the order, the relevant quantity is the conditional probability that the returned exponent is splitting, given a mixed base. Quantifying this would turn the ceiling $C$ of the ramp into a computable function of the valuation pair.

5. **A cost-optimal re-draw schedule.** Given a per-shot cost and a per-base setup cost, the two-parameter model of Section 8.2 poses a clean optimization: choose the number of shots per base and the number of bases to minimize expected total cost to first factor. The diminishing-returns property (Proposition 6.1(6)) together with the density bound should yield a closed-form optimum.

---

## 10. Conclusion

For a fixed base $a$ and an odd semiprime $N = pq$, whether period certificates can factor $N$ is decided by a single comparison of two-adic valuations: the extraction succeeds for some certificate if and only if $v_2(\operatorname{ord}_p a) \neq v_2(\operatorname{ord}_q a)$, and in that case the halved exact order splits $N$ outright. When the valuations agree, every halved even period is $\pm 1$ modulo $N$ and no sample budget can help. At most half of all bases suffer this fate, a splitting base always exists, and the population-level consequence is a success curve that rises like an independence ladder toward a ceiling equal to the certification rate times the mixed-role fraction — approached, never attained, and immune to additional sampling. Samples buy motion along the ladder. Only a new base buys a taller ladder.
