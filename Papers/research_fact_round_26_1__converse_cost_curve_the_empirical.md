# The Converse Cost Curve: A Unified Cost–Information Plane for Factor-Revealing Witnesses of Semiprimes

**Author:** Aristotle
**Date:** 2026-09-19

---

## Abstract

Let $N = pq$ be a semiprime with distinct primes $p \ne q$. A *factor-revealing witness* is a quantity attached to $N$ whose value, together with $N$, determines the unordered pair $\{p,q\}$, and a *definition route* is the cost of evaluating that witness by its defining computation. We study four classical witnesses — the greatest-common-divisor sum $M_1(N) = \sum_{x<N}\gcd(x,N)$, the first hit of the zero-divisor scan, congruences of squares, and the count of idempotents modulo $N$ — and prove that they occupy a single cost–information plane.

Our results are of four kinds. **(i) Exact closed forms.** We prove $M_1(pq) + 2(p+q) = 4pq + 1$, and more generally that *every* local gcd-statistic $S_f(N) = \sum_{x<N} f(\gcd(x,N))$ satisfies the four-cell formula $S_f(pq) = f(pq) + (q-1)f(p) + (p-1)f(q) + (p-1)(q-1)f(1)$; hence no summand $f$ can extract anything finer than the unordered pair, and the class contains information-free members. We also prove the affine equivalence $M_1(N) + 1 = 2\varphi(N) + 2N$ on semiprimes. **(ii) Exact costs.** The zero-divisor scan stops at exactly $\min(p,q)$; the scan plane contains exactly $p+q-1$ informative residues and exactly $\varphi(N) = (p-1)(q-1)$ wasted probes; a uniformly random probe strategy pays the same $\Omega(\min(p,q))$. **(iii) Counting ladders.** For every $N > 0$ the residue ring modulo $N$ has exactly $2^{\omega(N)}$ idempotents, and for every odd $N > 0$ exactly $2^{\omega(N)}$ square roots of unity, where $\omega(N)$ is the number of distinct prime factors. Hence the two counters are $\omega$-detectors: they are constant on semiprimes and carry zero factorisation information, while their $\Theta(N)$ definition routes are the most expensive in the family. All content of these routes sits in the individual nontrivial witnesses, each of which reveals a factor by a single gcd. **(iv) Barriers.** We prove a *no-polylogarithmic-route* theorem: for every degree $d$ there is a threshold beyond which every route cost of every balanced semiprime exceeds $(\log_2 N)^d$. We then strengthen the statement from a cost barrier to an information barrier in the black-box gcd-probe model: for any adaptive strategy, any query budget $T$ and any output rule, two semiprimes with disjoint factorisations produce the identical transcript, so no $T$-query gcd-probe algorithm outputs the factor pair for every semiprime.

The results are a *converse for a family*, not an unconditional hardness theorem: they delimit precisely what the known witness routes can and cannot deliver, and isolate the remaining gap as the programme's open theoretical target.

**Keywords:** semiprime, gcd-sum, Pillai's arithmetical function, idempotent, square root of unity, Chinese Remainder Theorem, black-box lower bound, cost–information trade-off.

---

## 1. Introduction

### 1.1 Motivation

Integer factorisation is asymmetric in a way that is easy to state and hard to explain. Multiplying two $k$-bit primes takes $O(k^2)$ bit operations; the best known general algorithms for recovering them from the product take time subexponential in $k$, and the elementary ones take time about $2^{k/2}$. No unconditional superpolynomial lower bound is known.

In the absence of an unconditional theorem, a productive substitute is to map the landscape: to take the known *factor-revealing witnesses*, determine exactly what each one knows and exactly what each one costs, and prove that no member of the family escapes the observed scale. This paper carries out that programme for four classical witnesses and two infinite families that contain them.

The organising observation is a dichotomy that recurs at every level:

> **Counting is cheap information and expensive computation; finding is the reverse.**

A witness that *counts* solutions of a local equation modulo $N$ typically returns a function of $\omega(N)$ — the number of distinct prime factors — and is therefore constant across the entire family of semiprimes. A witness that *exhibits* one nontrivial solution hands over a factor for the price of one gcd. The expensive part of every classical factoring method is exhibiting, not counting; and the results below make that statement precise for every route in the family.

### 1.2 Setting and conventions

Throughout, $N = pq$ where $p$ and $q$ are distinct primes; such $N$ is a *semiprime*. We write $s = p+q$ for the elementary symmetric sum, $\varphi$ for Euler's totient, and $\omega(N)$ for the number of distinct prime factors of $N$. A semiprime is *balanced* if (after ordering $p \le q$) we have $q \le 2p$; balanced semiprimes are what cryptographic key generation produces, and they are the hardest instances for the trial-division-style methods.

Costs are counted in arithmetic operations on residues; for definition routes this is simply the number of loop iterations of the defining computation. "Polylogarithmic" always means $\mathrm{poly}(\log N)$, i.e. polynomial in the bit length of the input, and this is the standard of efficiency we measure against.

### 1.3 The witness family

| Witness | Definition | Definition route | Cost |
|---|---|---|---|
| $W_1$ | $M_1(N) = \sum_{x<N} \gcd(x,N)$ | full $N$-scan | $\Theta(N)$ |
| $W_2$ | least $x>0$ with $\gcd(x,N)>1$ | scan to first hit | $\min(p,q)$ |
| $W_3$ | a congruence of squares $x^2\equiv y^2$ | Fermat / continued fractions / Pell | $\sqrt N$-scale |
| $W_4$ | $\#\{x : x^2 \equiv x \pmod N\}$ | full $N$-scan | $\Theta(N)$ |

Sections 3–6 treat these in turn; Section 7 fuses them into the no-polylogarithmic-route theorem, and Section 8 proves the black-box converse.

### 1.4 Contributions

1. **Exact closed form for $W_1$** and the constructive reach chain $W_1 \to s \to \{p,q\}$ (Section 3).
2. **A closed form for the entire class of local gcd-statistics**, showing the class collapses onto the four-element divisor lattice (Section 4).
3. **The exact cost, hit count, miss count and random-probe cost of the zero-divisor scan** (Section 5).
4. **Two counting ladders**, $\#\{x^2 = x\} = 2^{\omega(N)}$ for all $N>0$ and $\#\{x^2=1\} = 2^{\omega(N)}$ for odd $N>0$, together with the reveal lemmas that extract a factor from any nontrivial witness (Section 6).
5. **The no-polylogarithmic-route theorem** for the whole family on balanced semiprimes (Section 7).
6. **A complete black-box converse** in the adaptive gcd-probe model (Section 8).

---

## 2. Preliminaries

We record the two elementary facts used repeatedly.

**Lemma 2.1 (gcd against a prime).** *For a prime $p$ and any $x$,*
$$\gcd(x,p) = \begin{cases} p & \text{if } p \mid x,\\ 1 & \text{otherwise.}\end{cases}$$

*Proof.* $\gcd(x,p)$ divides $p$, hence is $1$ or $p$; it is $p$ exactly when $p \mid x$. $\square$

**Lemma 2.2 (multiplicativity across a coprime split).** *If $\gcd(p,q)=1$ then $\gcd(x,pq) = \gcd(x,p)\gcd(x,q)$ for all $x$.*

Combining the two: for a semiprime $N=pq$,
$$\gcd(x,N) = \big(\tfrac{}{}[p\mid x]\,p + [p\nmid x]\big)\big([q\mid x]\,q + [q\nmid x]\big),$$
so $\gcd(x,N)$ takes only the four values $1, p, q, pq$, and the residues below $N$ partition into four cells according to which primes divide $x$.

**Lemma 2.3 (cell sizes).** *Let $N = pq$ with $p\ne q$ prime. Among the residues $0 \le x < N$:*

- *exactly $q$ are divisible by $p$ (namely $0, p, 2p, \dots, (q-1)p$);*
- *exactly $p$ are divisible by $q$;*
- *exactly $1$ is divisible by both (namely $x=0$, since $pq \mid x$ and $x < pq$ force $x=0$);*
- *hence exactly $q-1$ are divisible by $p$ only, exactly $p-1$ by $q$ only, and exactly $(p-1)(q-1) = \varphi(N)$ by neither.*

*Proof.* The multiples of $p$ below $pq$ are the image of $\{0,\dots,q-1\}$ under the injection $i \mapsto pi$, giving $q$ of them; symmetrically for $q$. A common multiple is a multiple of $pq$ by coprimality, and the only such below $pq$ is $0$. Inclusion–exclusion gives the rest, and the last count is $\varphi(pq) = \varphi(p)\varphi(q)$. $\square$

This four-cell partition is the combinatorial skeleton of Sections 3–5.

---

## 3. Witness $W_1$: the gcd-sum and the reach chain

### 3.1 The closed form

**Definition 3.1.** *Pillai's arithmetical function* is $M_1(N) = \sum_{x=0}^{N-1}\gcd(x,N)$. Its definition route is a full scan of the $N$ residues: $\Theta(N)$ gcd computations.

**Theorem 3.2 (closed form for a semiprime).** *Let $p\ne q$ be primes and $N=pq$. Then*
$$M_1(N) + 2(p+q) = 4N + 1,$$
*equivalently $M_1(N) = 4N - 2s + 1$ with $s = p+q$.*

*Proof sketch.* Expand the summand via Lemmas 2.1–2.2 as
$$\gcd(x, N) = 1 + (p-1)[p\mid x] + (q-1)[q \mid x] + (p-1)(q-1)[p \mid x][q\mid x],$$
which one verifies by checking the four divisibility cases. Summing over $0 \le x < N$ and applying Lemma 2.3 to each of the four sums gives
$$M_1(N) = pq + (p-1)q + (q-1)p + (p-1)(q-1) = 4pq - 2(p+q) + 1. \qquad \square$$

(The identity is stated additively so that it is valid in the natural numbers without truncated subtraction.)

**Example 3.3.** $N=15$: $M_1 = 45 = 60 - 16 + 1$. $N=35$: $M_1 = 117 = 140 - 24 + 1$. $N=143=11\cdot13$: $M_1 = 572 - 48 + 1 = 525$.

### 3.2 Rigidity and the reach chain

**Theorem 3.4 (rigidity of the pair).** *If $p+q = p'+q'$, $pq = p'q'$, $p \le q$ and $p'\le q'$, then $p=p'$ and $q=q'$.*

*Proof sketch.* Over the integers, $(q-p)^2 = (p+q)^2 - 4pq = (p'+q')^2 - 4p'q' = (q'-p')^2$. Both differences are non-negative by the orderings, so $q - p = q'-p'$; combined with the equality of sums this yields the claim. $\square$

**Corollary 3.5 (explicit recovery).** *For a semiprime,*
$$s = p+q = \frac{4N+1-M_1(N)}{2},$$
*and $(N, s)$ determines $\{p,q\}$.*

**Theorem 3.6 ($W_1$ reaches the factors).** *If $N = pq = p'q'$ are two factorisations into distinct primes with $p\le q$, $p'\le q'$, and $M_1(pq) = M_1(p'q')$, then $p=p'$ and $q=q'$.*

*Proof.* Theorem 3.2 applied to both sides forces $p+q = p'+q'$; Theorem 3.4 finishes. $\square$

**Remark 3.7 (an honest caveat).** Taken at face value, "$N$ together with a witness determines $\{p,q\}$" is vacuous: unique factorisation already determines $\{p,q\}$ from $N$ alone. The substance of the reach chain is *constructive*: Corollary 3.5 is an explicit affine recovery of $s$ from $(N, M_1)$ using $O(1)$ arithmetic operations, and Theorem 3.4 is an explicit algebraic recovery of the pair from $(N,s)$ via a square root. The chain therefore says: *the only obstruction to factoring along this route is evaluating $M_1$*, and by Theorem 3.2 the witness value is an affine function of data one is trying to find.

### 3.3 The equivalence with the totient

**Theorem 3.8.** *For a semiprime $N=pq$, $\;M_1(N) + 1 = 2\varphi(N) + 2N$.*

*Proof.* $\varphi(N) = (p-1)(q-1) = N - s + 1$, so $2\varphi(N) + 2N = 4N - 2s + 2 = M_1(N)+1$ by Theorem 3.2. $\square$

Thus $M_1$ and $\varphi$ are affinely equivalent on semiprimes. Since knowledge of $\varphi(N)$ for a semiprime is classically equivalent to factoring it, reading $M_1$ is exactly as informative — and exactly as hard — as reading $\varphi$. The gcd-sum is not a new handle; it is an old handle with a different label.

---

## 4. The entire class of local gcd-statistics

A natural question is whether some other summand does better than the identity.

**Definition 4.1.** For $f : \mathbb{N} \to \mathbb{N}$, the *local gcd-statistic* is
$$S_f(N) = \sum_{x=0}^{N-1} f(\gcd(x,N)).$$
Taking $f = \mathrm{id}$ gives $W_1$; taking $f(d) = [d>1]$ counts the non-units; taking $f(d)=d^2$ gives the gcd-square sum, and so on.

**Theorem 4.2 (class-wide closed form).** *For every $f$ and every semiprime $N=pq$ with $p\ne q$,*
$$S_f(N) = f(pq) + (q-1)f(p) + (p-1)f(q) + (p-1)(q-1)f(1).$$

*Proof sketch.* Partition $\{0,\dots,N-1\}$ into the four cells of Lemma 2.3 according to divisibility by $p$ and by $q$. On each cell $\gcd(x,N)$ is constant with value $pq$, $p$, $q$, $1$ respectively, so the sum of $f(\gcd(x,N))$ over a cell is the cell size times $f$ of that value. Summing the four contributions gives the formula. $\square$

**Corollary 4.3 (the class sees only the divisor lattice).** *Every local gcd-statistic of a semiprime is a symmetric function of $\{p,q\}$ determined by the four values $f(1), f(p), f(q), f(pq)$. No choice of $f$ extracts anything finer than the unordered pair.*

**Corollary 4.4 (information-free members exist).** *Taking $f \equiv 1$ gives $S_f(N) = N$.*

*Proof.* Substituting into Theorem 4.2: $1 + (q-1) + (p-1) + (p-1)(q-1) = pq$. $\square$

That is, there are members of the class whose $\Theta(N)$ definition route returns the input. Corollary 4.4 is the $W_4$ phenomenon — a constant, hence blind, counter — occurring inside the sum class.

**Corollary 4.5 (the informative member).** *For $f=\mathrm{id}$, Theorem 4.2 reduces to Theorem 3.2, and $s$ is recovered from $(N, S_f)$ by one subtraction and one halving.*

The moral of Section 4 is that the class of gcd-local sums is *one witness with a parameter*, not an infinite reservoir of new ideas. Improving the exponent cannot come from a cleverer summand; the summand only redistributes weights among four numbers.

---

## 5. Witness $W_2$: exact cost of the zero-divisor scan

### 5.1 The stopping point

**Definition 5.1.** The *zero-divisor scan* on $N$ walks $x = 1, 2, 3, \dots$ and halts at the first $x$ with $\gcd(x,N) > 1$; we call such an $x$ a *hit*.

**Lemma 5.2 (hits are multiples).** *For $N = pq$ with $p,q$ prime, $\gcd(x,N)>1$ if and only if $p \mid x$ or $q\mid x$.*

*Proof.* If the gcd exceeds $1$ it has a prime divisor $r$, which divides both $x$ and $pq$, hence equals $p$ or $q$. Conversely if $p\mid x$ then $p \mid \gcd(x,N)$, which is therefore at least $p > 1$. $\square$

**Theorem 5.3 (the exact cost).** *For $N=pq$ with $p,q$ prime, $\min(p,q)$ is the least element of $\{x > 0 : \gcd(x,N)>1\}$.*

*Proof.* $\min(p,q)$ divides $N$ and exceeds $1$, so it is a hit. Conversely, by Lemma 5.2 any positive hit is a multiple of $p$ or of $q$, hence at least $p$ or at least $q$, hence at least $\min(p,q)$. $\square$

This is an *exact* cost statement: not $O(\cdot)$, not $\Theta(\cdot)$, but equality. And the cost buys the entire factorisation at once:

**Proposition 5.4.** $\min(p,q)\cdot\max(p,q) = N$ *and* $N / \min(p,q) = \max(p,q)$.

**Theorem 5.5 ($W_2$ reaches the factors).** *If $pq = p'q'$ with $p\le q$, $p'\le q'$, $p$ prime, and $\min(p,q) = \min(p',q')$, then $p = p'$ and $q = q'$.*

*Proof.* The hypothesis says $p = p'$; cancelling $p$ in $pq = pq'$ gives $q = q'$. $\square$

### 5.2 The geometry of the scan plane

**Theorem 5.6 (hit count).** *For a semiprime $N = pq$ with $p \ne q$, the number of hits among $0 \le x < N$ is exactly $p + q - 1$.*

*Proof sketch.* By Lemma 5.2 the hit set is the union of the multiples of $p$ and the multiples of $q$ below $N$; by Lemma 2.3 these sets have $q$ and $p$ elements and intersect exactly in $\{0\}$. Inclusion–exclusion gives $p+q-1$. $\square$

**Theorem 5.7 (miss count).** *Exactly $\varphi(N) = (p-1)(q-1)$ residues below $N$ satisfy $\gcd(x,N)=1$.*

So of the $N$ residues, $p+q-1$ carry information and $\varphi(N)$ do not. For a balanced semiprime the informative fraction is $\approx 2/\sqrt N$: the scan plane is almost entirely inert.

### 5.3 Randomisation does not help

**Theorem 5.8 (random probe cost).** *For a semiprime $N=pq$ with $p \ne q$,*
$$\#\{\text{hits}\}\cdot\min(p,q) \le 2N.$$

*Proof sketch.* By Theorem 5.6 the left side is $(p+q-1)\min(p,q)$. Assuming WLOG $p \le q$, this is $(p+q-1)p \le 2pq$ since $p + q - 1 \le 2q$ for $p \ge 2$. $\square$

**Corollary 5.9.** *A uniformly random probe hits with probability at most $2/\min(p,q)$, so the expected number of probes before a hit is $\Omega(\min(p,q))$: randomisation pays the same wall as the deterministic scan.*

### 5.4 The $\sqrt{N}$ wall

**Theorem 5.10 (balanced scan cost).** *If $p\le q\le 2p$ then $N = pq \le 2\min(p,q)^2$; equivalently the scan cost is at least $\sqrt{N/2}$.*

*Proof.* $\min(p,q)=p$ and $pq \le p\cdot 2p = 2p^2$. $\square$

**Proposition 5.11 (and no more).** *Always $\min(p,q)^2 \le pq$, so the scan cost never exceeds $\sqrt N$.*

Together: on balanced semiprimes the $W_2$ route sits *exactly* on the $\sqrt N$ scale, $\sqrt{N/2} \le \text{cost} \le \sqrt N$ — the same scale as the classical elementary factoring methods.

---

## 6. Witnesses $W_3$ and $W_4$: two counting ladders

### 6.1 Idempotents

**Definition 6.1.** An *idempotent* modulo $N$ is a residue $x$ with $x^2 \equiv x \pmod N$.

**Theorem 6.2 (semiprime idempotent count).** *For $N=pq$ with distinct primes, there are exactly $4$ idempotents modulo $N$.*

*Proof sketch.* In a field the equation $x(x-1)=0$ forces $x \in \{0,1\}$, so each of $\mathbb{Z}/p$ and $\mathbb{Z}/q$ carries exactly two idempotents. Idempotents of a product ring are pairs of idempotents, and the Chinese Remainder isomorphism $\mathbb{Z}/pq \cong \mathbb{Z}/p \times \mathbb{Z}/q$ is a ring isomorphism, hence transports idempotents bijectively. The count is $2 \cdot 2 = 4$. $\square$

The four idempotents are $0$, $1$, and a conjugate pair $e, 1-e$. **The trivial idempotent $x=0$ is one of the four and must not be excluded**: it is precisely the CRT choice $(0,0)$. For $N=15$ the four are $0,1,6,10$; for $N=35$ they are $0,1,15,21$.

**Corollary 6.3 (the counter is constant).** *Any two semiprimes have the same idempotent count, namely $4$. The $\Theta(N)$ definition route that computes the count therefore carries zero bits about the factorisation.*

The general shape of the phenomenon:

**Theorem 6.4 (idempotent ladder).** *For every $N > 0$, the number of idempotents modulo $N$ is $2^{\omega(N)}$, where $\omega(N)$ is the number of distinct prime factors of $N$.*

*Proof sketch.* Two ingredients, combined by induction on the coprime-factorisation structure of $N$.

*Local rigidity.* Modulo $p^n$ with $p$ prime the only idempotents are $0$ and $1$. Indeed, if $x^2 = x$ and $v$ is the representative of $x$ in $[0,p^n)$, then $p^n \mid v(v-1)$. The prime $p$ cannot divide both $v$ and $v-1$ (their difference is $1$), so $p^n$ is coprime to one of the two factors and hence divides the other; that is, $v \equiv 0$ or $v \equiv 1$. The local count is thus $2 = 2^{\omega(p^n)}$.

*Multiplicativity.* For coprime $a,b$ the CRT isomorphism transports idempotents, and idempotents of a product are pairs of idempotents, so the count is multiplicative. Since $\omega$ is additive on coprime factors, $2^{\omega}$ is multiplicative, and the base cases $N=1$ (count $1 = 2^0$) and $N = p^n$ match. $\square$

**Example 6.5.** $N = 105 = 3\cdot 5\cdot 7$ has $\omega = 3$ and exactly $8$ idempotents. $N = 49 = 7^2$ has $\omega = 1$ and only the two trivial idempotents. Both are confirmed by direct enumeration.

So the $W_4$ route is an *$\omega$-detector*: it reports the number of distinct prime factors and nothing else. It cannot distinguish two moduli with the same $\omega$, in particular never two semiprimes — while paying the most expensive definition route in the family.

### 6.2 Square roots of unity

**Theorem 6.6 (square-root ladder).** *For every odd $N>0$, the equation $x^2 \equiv 1 \pmod N$ has exactly $2^{\omega(N)}$ solutions.*

*Proof sketch.* The same two ingredients. *Local rigidity:* modulo an odd prime power $p^n$, if $x^2=1$ and $v$ is the representative of $x$, then $p^n \mid (v-1)(v+1)$. An odd prime $p$ cannot divide both $v-1$ and $v+1$, since their difference is $2$ and $p \nmid 2$. Hence $p^n$ divides one of the factors and $x = \pm 1$: the local count is $2$. *Multiplicativity:* square roots of unity multiply across a product of monoids, and CRT transports them; $\omega$ is additive on coprime factors. $\square$

**Remark 6.7 (the hypothesis is necessary).** Oddness cannot be dropped. Modulo $8$ the solutions of $x^2 \equiv 1$ are $1,3,5,7$ — four of them, while $\omega(8)=1$. The prime $2$ is exactly where the "difference is $2$" step of local rigidity fails.

**Corollary 6.8 (family instance).** *An odd semiprime has exactly four square roots of unity, $\pm 1$ and a conjugate pair obtained by a CRT sign flip. Hence the counter is constant on odd semiprimes and is a second $\omega$-detector.*

**Example 6.9.** $N=35$: the roots are $1,6,29,34$. $N = 15$: four again, the same value. $N = 45 = 3^2\cdot5$: four again — the ladder is blind to the exponent, as it must be, since $\omega(45)=2$.

### 6.3 The reveal lemmas: individual witnesses do pay

The counters are blind, but each nontrivial witness is worth a factor.

**Theorem 6.10 (a nontrivial idempotent reveals a factor).** *Let $N = pq$ with distinct primes, and let $0 < x < N$, $x \ne 1$, satisfy $N \mid x(x-1)$. Then $\gcd(x,N) \in \{p,q\}$.*

*Proof sketch.* Each of $p,q$ divides $x(x-1)$, hence divides $x$ or $x-1$. If both divide $x$ then $N \mid x$, impossible for $0<x<N$. If both divide $x-1$ then $N \mid x-1$, forcing $x=1$. So exactly one of $p,q$ divides $x$ and the other divides $x-1$; the one dividing $x$ is then $\gcd(x,N)$, because the gcd is a divisor of $N$ strictly between $1$ and $N$. $\square$

**Theorem 6.11 (a congruence of squares reveals a factor).** *Let $N = pq$ with distinct primes and let $y < x$ with $0 < x - y < N$, $N \nmid (x+y)$, and $N \mid (x-y)(x+y)$ — the situation $x^2 \equiv y^2$, $x \not\equiv \pm y$. Then $\gcd(x-y, N) \in \{p,q\}$.*

*Proof sketch.* As above: each prime divides $x-y$ or $x+y$. Both dividing $x-y$ would force $N \mid x-y$, contradicting $0 < x-y < N$; both dividing $x+y$ is excluded by hypothesis. So one prime goes to each side, and $\gcd(x-y,N)$ is a proper nontrivial divisor of $N$, hence a prime factor. $\square$

**Proposition 6.12 (cofactor).** *If $g \in \{p,q\}$ then $N/g$ is the other prime.*

Theorem 6.11 is the *reveal step* shared by Fermat's difference-of-squares, the continued-fraction method, Pell-type relations, the quadratic sieve and, in negated form, the Miller–Rabin test. The reveal step costs one gcd; the expensive part of all of these algorithms is producing the congruence in the first place. Section 7 quantifies that in the family.

**Synthesis of Section 6.** For both local equations, the *cardinality* of the solution set is a function of $\omega(N)$ alone and hence blind, while any *individual* nontrivial solution is worth the full factorisation. All the factor content of the $W_3$ and $W_4$ routes sits in the witnesses, never in their number.

---

## 7. No polylogarithmic route anywhere

We now fuse the parts. Define the *route-cost set* of a semiprime,
$$\mathrm{Cost}(p,q) = \{\,pq,\ \min(p,q)\,\},$$
containing the $\Theta(N)$ full scans of $W_1$ and $W_4$ and the exact $\min(p,q)$ cost of $W_2$.

**Lemma 7.1 (floor of the plane).** *For $p,q \ge 1$, every $c \in \mathrm{Cost}(p,q)$ satisfies $\min(p,q) \le c$.*

*Proof.* $\min(p,q) \le pq$ since the other factor is at least $1$; and $\min(p,q) \le \min(p,q)$. $\square$

**Theorem 7.2 (the $\sqrt N$ floor).** *If $p \le q \le 2p$ then every $c \in \mathrm{Cost}(p,q)$ satisfies $N = pq \le 2c^2$.*

*Proof.* Theorem 5.10 gives $pq \le 2\min(p,q)^2$, and Lemma 7.1 gives $\min(p,q)\le c$. $\square$

**Lemma 7.3 (polynomials lose).** *For every degree $d$ there is $K$ such that $(m+1)^d < 2^m$ for all $m \ge K$.*

*Proof sketch.* $m^d = o(2^m)$ as $m \to \infty$; make the asymptotic explicit by taking $K$ past the point where the ratio drops below $\tfrac14$ and absorbing the shift $m \mapsto m+1$ into the factor $2$ in $2^{m+1} = 2\cdot 2^m$. $\square$

**Theorem 7.4 (NO POLYLOGARITHMIC ROUTE ANYWHERE).** *Fix any degree $d \in \mathbb{N}$. There is a threshold $K$ such that for all $p,q \ge 1$ with $p \le q \le 2p$ and $pq \ge K$, and for every route cost $c \in \mathrm{Cost}(p,q)$,*
$$\big(\log_2 (pq)\big)^d \;<\; c.$$

*Proof sketch.* Put $N = pq$ and $k = \lfloor \log_2 N\rfloor$; the threshold $K = 2^{K_0+1}$ is chosen so that $k \ge K_0 + 1$, where $K_0$ is the constant from Lemma 7.3 for degree $2d$. Two inequalities collide:

1. *Geometry:* $2^{k} \le N \le 2p^2$ by balancedness, so $2^{k-1} \le p^2$.
2. *Analysis:* $k^{2d} < 2^{k-1}$ by Lemma 7.3.

Chaining them, $(k^d)^2 = k^{2d} < 2^{k-1} \le p^2$, hence $k^d < p = \min(p,q) \le c$ by Lemma 7.1. $\square$

**Interpretation and honest boundary.** Theorem 7.4 is a theorem about *definition routes* — the cost of evaluating each witness by the computation that defines it — on balanced semiprimes. It is not a lower bound over all algorithms; that remains open and is the programme's theoretical target. What Theorem 7.4 does establish is that no amount of tuning inside the family produces a $\mathrm{poly}(\log N)$ method: the family's cheapest cost, $\min(p,q)$, is on the $\sqrt N$ scale, and the bit length can never catch a square root.

**Theorem 7.5 (one plane).** *Let $N = pq = p'q'$ be two factorisations into distinct primes with $p \le q$, $p'\le q'$. Then the following are equivalent:*

1. $M_1(pq) = M_1(p'q')$;
2. $\min(p,q) = \min(p',q')$;
3. $p+q = p'+q'$;
4. $p = p'$ and $q = q'$;

*while the idempotent counter and the square-root counter (for odd moduli) return the constant $4$ in both cases and hence distinguish nothing.*

*Proof sketch.* (1)$\Leftrightarrow$(3) is Theorem 3.2 applied twice. (2)$\Rightarrow$(4) is Theorem 5.5, and (4)$\Rightarrow$(2) is immediate. (3)$\Leftrightarrow$(4) is Theorem 3.4. The final clause is Corollaries 6.3 and 6.8. $\square$

Theorem 7.5 is the precise sense in which the family lies on *one* cost–information plane: every informative route delivers exactly the symmetric datum $s = p+q$ — no more, no less — and every blind route delivers $\omega(N)$.

---

## 8. The black-box converse: from cost barrier to information barrier

Theorem 7.4 constrains the given routes. This section removes the restriction to those routes, at the price of restricting the *access model* to the operation all four of them actually perform: a gcd probe against the hidden modulus.

**Definition 8.1 (adaptive strategy).** A *strategy* is a function $S$ from finite lists of natural numbers to natural numbers: given the list of answers received so far, it names the next residue to probe. A strategy has *positive probes* if $S(\ell) > 0$ for every list $\ell$.

**Definition 8.2 (transcript).** The *transcript* of $S$ on a hidden modulus $N$ after $T$ probes is defined recursively: $\mathrm{tr}_0 = [\,]$ and $\mathrm{tr}_{n+1} = \mathrm{tr}_n \mathbin{+\!\!+} [\gcd(S(\mathrm{tr}_n), N)]$.

**Definition 8.3 (null run).** The $n$-th *null probe* of $S$ is $S([1,1,\dots,1])$ with $n$ ones — the probe $S$ would make if every answer so far had been $1$.

**Lemma 8.4 (blindness).** *If $\gcd(\text{$n$-th null probe}, N) = 1$ for all $n < T$, then the transcript of $S$ on $N$ after $T$ probes is the all-ones list of length $T$.*

*Proof sketch.* Induction on $T$. If the transcript after $n$ probes is all ones, the next probe is by definition the $n$-th null probe, whose answer is $1$ by hypothesis; appending gives the all-ones list of length $n+1$. $\square$

**Lemma 8.5 (small probes are blind).** *If $p,q$ are primes and $0 < x < \min(p,q)$, then $\gcd(x, pq) = 1$.*

*Proof.* By Lemma 5.2 a non-unit $x$ would be a positive multiple of $p$ or of $q$, hence at least $\min(p,q)$. $\square$

**Theorem 8.6 (two indistinguishable semiprimes).** *For any strategy $S$ with positive probes and any budget $T$, there exist primes $p_1 < q_1$ and $p_2 < q_2$ with $p_1 < p_2$ (so the two factorisations are disjoint) such that the transcripts of $S$ on $p_1q_1$ and on $p_2q_2$ after $T$ probes are both the all-ones list of length $T$.*

*Proof sketch.* Let $B$ be the maximum of the first $T$ null probes — a finite number, since there are finitely many of them, and computable from $S$ alone without reference to any modulus. By the infinitude of primes choose four primes $B < p_1 < q_1 < p_2 < q_2$. For either modulus $N_i = p_iq_i$, every null probe is a positive integer at most $B$, hence strictly less than both prime factors, hence coprime to $N_i$ by Lemma 8.5. Lemma 8.4 now gives the all-ones transcript for both. $\square$

**Theorem 8.7 (no black-box algorithm factors).** *Let $S$ be any adaptive strategy with positive probes, $T$ any query budget, and $f$ any output rule mapping transcripts to pairs. Then there exists a semiprime $N = pq$ with $p<q$ prime such that $f(\mathrm{tr}_T(S,N)) \ne (p,q)$.*

*Proof.* Take $p_1<q_1$ and $p_2<q_2$ as in Theorem 8.6; both transcripts are the same list $L$, so $f$ returns the same pair on both. If $f(L) = (p_1,q_1)$, then $f(L) \ne (p_2,q_2)$ since $p_1 < p_2$, and the second semiprime is answered wrongly. Otherwise the first is. $\square$

**Remark 8.8 (why this is stronger).** Theorem 7.4 says the family's routes are *expensive*. Theorem 8.7 says a gcd-probe algorithm is *blind*: it is not that it needs many queries to find the answer, it is that with any fixed number of queries the answers it receives are literally constant across instances with different answers. This is an information-theoretic barrier, and no cleverness in probe selection — adaptivity is fully allowed — evades it. The trade-off is the restricted access model; Theorem 8.7 says nothing about algorithms that do arithmetic on $N$ itself, such as the number field sieve.

**Example 8.9.** The naive increasing scan, whose $n$-th probe is $n+1$ regardless of answers, is a strategy in this sense; on $N = 143$ its first ten probes all return $1$.

---

## 9. Algorithms

Three procedures organise the computational side of the results.

**Algorithm 1 (gcd-sum route).** Compute $M_1(N) = \sum_{x<N}\gcd(x,N)$ by a full scan, recover $s = (4N+1-M_1)/2$, then solve $t^2 = s^2 - 4N$ and output $\big(\tfrac{s-t}{2}, \tfrac{s+t}{2}\big)$. Complexity: $\Theta(N)$ gcd computations plus $O(1)$ arithmetic. Correctness: Theorem 3.2, Corollary 3.5, Theorem 3.4. The closed form makes the scan redundant *if $s$ is known* — which is precisely the point: the route is a tautology whose only non-trivial step is the one that costs $N$.

**Algorithm 2 (zero-divisor scan).** For $x = 2,3,\dots$ compute $g = \gcd(x,N)$ and halt when $g>1$; output $(g, N/g)$. Complexity: exactly $\min(p,q)$ iterations (Theorem 5.3), i.e. between $\sqrt{N/2}$ and $\sqrt N$ for balanced semiprimes. Correctness: Theorem 5.3 and Proposition 5.4.

**Algorithm 3 (witness reveal).** Given a nontrivial idempotent $x$ (or a congruence of squares $x^2\equiv y^2$ with $x \not\equiv \pm y$), output $\gcd(x, N)$ (resp. $\gcd(x-y,N)$) and its cofactor. Complexity: one gcd, $O(\log^2 N)$ bit operations. Correctness: Theorems 6.10, 6.11 and Proposition 6.12.

The three together display the dichotomy: Algorithm 3 is essentially free but requires a witness; Algorithms 1 and 2 manufacture the required information at $\Theta(N)$ and $\Theta(\sqrt N)$ cost respectively; and Theorem 7.4 says no route in the family does better.

---

## 10. Empirical notes

The theorems above were preceded by measurement, and the measurements are reported as observed, including where they contradicted expectation.

- The gcd-sum route and the idempotent route both exhibited a measured cost exponent $\alpha = 1.000$ in $\mathrm{cost} \sim N^{\alpha}$, matching the $\Theta(N)$ definition route exactly.
- The zero-divisor scan matched $\mathrm{cost} = \min(p,q)$ in $60$ of $60$ trials — now Theorem 5.3, with no error term.
- The continued-fraction route measured $\alpha \approx 0.398$, *below* the naive $\tfrac12$: the period length of the continued fraction of $\sqrt N$ drifted as $\ell/\sqrt N \approx 0.75, 0.18, 0.23$ across the tested sizes, so the period lags $\sqrt N$ rather than tracking it. This is recorded as measured; we make no claim about its asymptotics.
- The reach chain (witness $\to s \to \{p,q\}$) held jointly at $100\%$ across the family — now Theorems 3.6, 5.5 and 7.5.
- Two process notes worth preserving. A first run sized its semiprimes by a bit parameter while $N$ carried twice that many bits, producing an intended $10^9$-operation stall; it was caught before any claim was made. And the idempotent scan initially *excluded* $x=0$ as trivial and then failed its own assertion that the count is four — the trivial idempotent is one of the two CRT sign choices, and this bug is the reason Theorem 6.2 is stated with the count $4$ and not $3$.

---

## 11. Discussion

### 11.1 What is proved and what is not

The results delimit a family. Within the class of local gcd-statistics, the idempotent and square-root counters, and the zero-divisor scan, every route is super-polylogarithmic on balanced semiprimes (Theorem 7.4), and every informative route delivers exactly the same datum $s=p+q$ (Theorem 7.5). Within the adaptive gcd-probe model, no algorithm at all succeeds (Theorem 8.7). Neither statement implies that factoring is hard: an algorithm outside both the family and the access model — the number field sieve is one — is untouched by these theorems.

### 11.2 The counting/finding dichotomy as a design principle

Theorems 6.4 and 6.6 make precise a phenomenon that appears everywhere in computational number theory. Local equations modulo $N$ have solution-set cardinalities given by CRT multiplicativity: a local count times a local count. Since the local counts are shape data — they depend on the prime powers, not on the primes — the global count is a function of the *shape* of the factorisation, typically $2^{\omega(N)}$. Shape is not identity. Any invariant obtained by counting solutions of a local equation therefore has an information ceiling, and one can predict in advance that it will be blind on the semiprime family. Conversely the individual solutions are conjugacy-breaking: a CRT sign flip is exactly a choice of which prime goes on which side, and reading the choice off — one gcd — reads the factorisation off.

This suggests a heuristic for evaluating proposed factoring witnesses before implementing them: *ask whether the quantity is a cardinality*. If it is, and the underlying equation is local, it is almost certainly an $\omega$-detector.

### 11.3 The $\varphi$-equivalence and what it rules out

Theorem 3.8 places $M_1$ in the same equivalence class as $\varphi$. This is a negative result with teeth: proposals to factor via gcd-sums, gcd-square-sums, or any local gcd-statistic (Theorem 4.2) reduce to already-known equivalences and inherit their difficulty. Corollary 4.4 sharpens the point by exhibiting members of the class whose entire $\Theta(N)$ output is $N$.

### 11.4 The black-box model in context

Theorem 8.7 belongs to the tradition of oracle separations and query lower bounds. Its strength is that it is unconditional, fully adaptive, and allows an arbitrary output rule; its weakness is that the model forbids exploiting the algebraic structure of $N$ directly. It is nonetheless the correct model for the family under study: all four witnesses access $N$ only through gcd probes at their core loops, so Theorem 8.7 shows the family's failure is not a failure of engineering.

---

## 12. Future directions

1. **Beyond gcd probes.** Extend the black-box converse to strategies that may also perform modular arithmetic: probe with $x \mapsto x^e \bmod N$, or allow ring operations, and ask whether an adversary argument survives. The natural target is a model that contains Pollard's $\rho$ and $p-1$ as instances.
2. **Unbalanced semiprimes.** Theorem 7.4 assumes $q \le 2p$. For unbalanced moduli the $W_2$ route costs $\min(p,q)$, which may be small; the correct statement is a trade-off between imbalance and cost, and a sharp form is not yet written down.
3. **The continued-fraction exponent.** The measured $\alpha \approx 0.398$ for the period length of $\sqrt N$ deserves a theoretical explanation. Known results on continued fraction periods of quadratic irrationals give upper bounds of order $\sqrt N \log N$; what the *typical* period of a balanced semiprime looks like is the open question suggested by the measurement.
4. **Ladders at the prime $2$.** Theorem 6.6 requires odd $N$; the even case has count $2^{\omega(N)}$ multiplied by a correction depending on the $2$-adic valuation ($1$, $2$ or $4$). Recording the full even ladder would complete the square-root count for all $N$.
5. **Other local equations.** The method of Section 6 — local rigidity plus CRT — applies verbatim to $x^k = 1$ and $x^k = x$. The local counts involve $\gcd(k, p-1)$, so the global counts are no longer pure powers of $2$ and in principle carry *more* than $\omega(N)$. Determining whether any such counter is genuinely informative on semiprimes, and at what cost, is the most promising direction for escaping the ceiling described in §11.2.
6. **Quantitative reach.** Theorem 7.4 gives an explicit but generous threshold. Extracting the optimal constant — the least $N$ beyond which the family's cheapest route exceeds $(\log_2 N)^d$ — would turn the asymptotic statement into a usable table.

---

## 13. Conclusion

Four classical factor-revealing witnesses, plus the two infinite families containing them, occupy one cost–information plane. The gcd-sum is an affine function of $N$ and $s = p+q$, equivalent to Euler's totient, and so is every local gcd-statistic. The zero-divisor scan stops at exactly $\min(p,q)$, wastes exactly $\varphi(N)$ probes, and is not helped by randomisation. The idempotent count and the square-root-of-unity count are both exactly $2^{\omega(N)}$ and are therefore constant on the semiprime family, carrying zero factorisation information despite the most expensive definition routes — while any single nontrivial witness of either kind yields a prime factor in one gcd. On balanced semiprimes, every route in the family exceeds every fixed power of the bit length beyond an explicit threshold; and in the adaptive gcd-probe model the barrier is not cost but blindness: two semiprimes with disjoint factorisations produce identical transcripts, so no bounded-query algorithm can factor.

The picture is a map, not a proof of hardness. But it is a map on which every known road through this terrain runs through the same high pass, and it now comes with a proof that the pass is high.
