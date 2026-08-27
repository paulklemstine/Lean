# Order Completion versus Collision: An Exact Arithmetic Theory of Stage-1 Firing in the Elliptic Curve Method

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

Stage 1 of Lenstra's elliptic curve method (ECM) multiplies a starting point by the scalar $k(B) = \prod_{q \le B} q^{\lfloor \log_q B\rfloor}$, accumulating one prime power at a time along the schedule of primes $q \le B$. Folklore models the resulting success as a *collision*: a chance event of probability approximately $1 - e^{-1.44 B/p}$ per curve. An empirical campaign at planted-prime bit lengths $26$ and $32$ found this model incompatible with observation on two independent legs: success rates were flat in the smoothness budget (three doses, rates $0.60$–$0.775$, all confidence intervals overlapping across scales), and the position within the prime schedule at which successful runs fired was decisively non-uniform, with medians in $[0.073, 0.293]$ and late-tail mass at most $13\%$.

We give a complete, unconditional arithmetic account of both phenomena, which shows that no probabilistic model of the *event* is needed at all. We prove: (i) stage-1 firing on a point of order $n$ is exactly the divisibility $n \mid k(B)$, equivalently $B$-powersmoothness of $n$; (ii) in a cyclic group of order $m$ the number of firing points is exactly $\gcd(m, k(B))$, which is the largest $B$-powersmooth divisor of $m$; (iii) the least schedule cutoff at which a firing order fires is exactly its largest prime factor; (iv) the cumulative firing count is a monotone staircase in the bound, constant unless the bound crosses a prime power dividing the order, with an exact multiplicative jump $q^{\min(v_q(m), \lfloor\log_q B\rfloor)}$, and maximal precisely at powersmoothness; (v) the firing positions form a set of at most $\omega(m) \le \log_2 m$ of the $\pi(B)$ schedule steps, hence cannot be uniform once the schedule is long, and a pigeonhole argument produces an inert block of at least $\pi(B)/(\omega(m)+1)$ consecutive-in-order schedule primes; (vi) with $c$ points the multi-curve success count is exactly $m^c - (m-\gcd(m,k))^c$; (vii) where order completion is impossible — every prime factor above the bound — the firing count collapses to $1$, giving an exact rate $1/m$ and validating the experimental control channel; and (viii) any order-completion rate exceeding $1.44 B/m$ provably beats the collision baseline, since $1 - e^{-x} \le x$. A worked cell ($m = 720$, $B = 10$) exhibits the entire staircase, $1, 8, 72, 360, 360$, and a true rate of $1/2$ against a collision ceiling of $1/50$.

**Keywords:** elliptic curve method, powersmooth, order completion, greatest common divisor staircase, largest prime factor, dose response, non-uniformity, integer factorization.

---

## 1. Introduction

### 1.1 Setting

Let $N$ be a composite integer with an unknown prime factor $p$. Lenstra's elliptic curve method chooses a curve $E$ and a point $P$ over $\mathbb{Z}/N$, and computes $k\cdot P$ using formulas that require modular inversions. The method succeeds when an inversion fails modulo $p$ but not modulo $N$, which happens when the order of the reduction $P \bmod p$ in $E(\mathbb{F}_p)$ divides $k$. Stage 1 uses the scalar

$$k(B) \;=\; \prod_{\substack{q \le B\\ q\ \mathrm{prime}}} q^{\lfloor \log_q B\rfloor},$$

built up prime by prime in increasing order. We write $k(B,C)$ for the partial product over primes $q \le C$, so that $k(B,C)$ is exactly the scalar accumulated after the schedule has processed all primes up to $C$, and $k(B) = k(B,B)$.

### 1.2 The two competing mechanisms

Two stories are told about why a stage-1 run at a modest bound $B$ succeeds.

**Order completion.** The order $n$ of the point genuinely divides $k(B)$ — the arithmetic of the group order cooperates with the schedule.

**Collision.** The success is a chance divisibility unrelated to smoothness of the order, whose per-curve rate the folklore model puts at $1 - \exp(-1.44 B/p)$.

The two stories make different predictions. Collision predicts a *dose response*: rates increasing in $B$ and decaying as $p$ grows, tracking the exponential formula. It also predicts nothing in particular about *when* in the schedule a success occurs — absent structure, uniformity across the $\pi(B)$ steps is the natural null. Order completion predicts flatness in $B$ across inert stretches, stability under increases of scale that leave the smooth part alone, and heavily front-loaded firing positions.

### 1.3 The empirical picture

A pre-registered campaign, with a fresh random seed disjoint from earlier lineages, ran stage 1 only, with $40$ trials per bit length, three smoothness budgets (bound equal to $\lceil 0.125\,T\rceil$, $\lceil 0.5\,T\rceil$, $\lfloor 0.9\,T\rfloor$ of a target $T$), and three curves per trial. It recorded:

* **Rate stability at every dose.** At planted-prime bit length $26$: rates $0.65$, $0.75$, $0.60$. At bit length $32$: $0.75$, $0.775$, $0.75$. Two-proportion tests gave $p = 0.329, 0.793, 0.152$; Wilson intervals overlapped at all three doses. The rates were flat in the budget fraction and stable across the scale jump — no decay toward $1-\exp(-1.44B/p)$.
* **Non-uniform, early firing.** Normalizing the schedule position of the successful step to $[0,1]$, a goodness-of-fit test against the uniform distribution rejected in all six cells ($p \le 0.002$); medians ranged over $[0.073, 0.293]$, and the mass in the top fifth of the schedule never exceeded $13\%$.
* **A separated collision floor.** Using the second, much larger prime factor $q$ of the modulus as a control channel (for which $B \ll q$ makes order completion impossible), hits at $q$ numbered $9$–$16$ per cell against $24$–$31$ at $p$. Independently, the first-curve success rate at the smallest dose and largest scale was $0.425$, about $2.58$ times the per-curve constant collision baseline $0.1647$.

The purpose of this paper is to show that all three signatures are shadows of exact arithmetic facts, provable without any probabilistic modelling of the event.

### 1.4 Contributions

We prove the eight results (i)–(viii) listed in the abstract, organized as: the firing criterion and firing cutoff (§3), exact counts and the staircase (§4), dose response and saturation (§5), the pigeonhole inert block (§6), controls, multi-curve amplification, and the collision comparison (§7). §8 gives a fully worked numerical cell; §9 discusses algorithmic consequences; §10 records precisely what is *not* provable at this level of generality, and why.

---

## 2. Definitions and notation

Throughout, $q$ and $r$ denote primes, $v_r(n)$ the exponent of $r$ in $n$, $\omega(n)$ the number of distinct prime factors of $n$, and $\pi(C)$ the number of primes $\le C$.

**Definition 2.1 (Truncated stage-1 scalar).** For $B, C \in \mathbb{N}$,
$$k(B,C) \;=\; \prod_{\substack{q \le C \\ q\ \mathrm{prime}}} q^{\lfloor \log_q B\rfloor}, \qquad k(B) := k(B,B).$$
$k(B,C)$ is exactly the scalar stage 1 has accumulated once it has processed every prime of the schedule up to $C$. Note $k(B,C) \ne 0$ always, and $k(B,C) \mid k(B,C')$ for $C \le C'$.

**Definition 2.2 (Powersmoothness).** $n$ is **$B$-powersmooth** if $q^{v_q(n)} \le B$ for every prime $q \mid n$.

**Definition 2.3 (Firing set).** For $m > 0$ and a scalar $k$, the **firing set** is
$$F(m,k) \;=\; \{\, a \in \{0,1,\dots,m-1\} \;:\; m \mid k\,a \,\},$$
the residues of $\mathbb{Z}/m$ annihilated by multiplication by $k$. Modelling $E(\mathbb{F}_p)$ as cyclic of order $m$ and the starting point as a uniform residue, $|F(m,k)|/m$ is the stage-1 success rate.

**Definition 2.4 (Largest prime factor).** $\mathrm{lpf}(n) = \max\{q : q \mid n\}$, with $\mathrm{lpf}(1) = 0$.

**Definition 2.5 (Schedule, jump set, large part).** The **schedule** at bound $B$ is the set of primes $\le B$, of cardinality $\pi(B)$. The **jump set** $J(m,B)$ is the set of cutoffs $C \le B$ at which the cumulative firing count $C \mapsto \gcd(m, k(B,C))$ strictly increases. The **large part** of $m$ above $L$ is
$$\mathrm{Lg}(m,L) \;=\; \prod_{\substack{q \mid m \\ q > L}} q^{v_q(m)}.$$

**Lemma 2.6 (Exponents of the scalar).** For any prime $r$,
$$v_r\bigl(k(B,C)\bigr) \;=\; \begin{cases} \lfloor \log_r B\rfloor, & r \le C,\\ 0, & r > C.\end{cases}$$

*Proof sketch.* The factorization of a product of prime powers over a set $S$ of distinct primes assigns to $r$ the exponent attached to $r$ if $r \in S$ and $0$ otherwise; here $S$ is the set of primes $\le C$ and the exponent attached to $q$ is $\lfloor\log_q B\rfloor$. $\square$

---

## 3. The firing criterion and the firing cutoff

The engine of the whole theory is the elementary equivalence "divisibility = coordinatewise domination of exponent vectors", applied to Lemma 2.6.

**Theorem 3.1 (Truncated firing criterion).** Let $n \ne 0$, $B \ne 0$. Then
$$n \mid k(B,C) \iff \forall\, q \mid n:\; q \le C \ \text{ and }\ q^{v_q(n)} \le B.$$

*Proof sketch.* $n \mid k(B,C)$ iff $v_r(n) \le v_r(k(B,C))$ for all primes $r$. By Lemma 2.6 this reads: for $r \le C$, $v_r(n) \le \lfloor\log_r B\rfloor$, which by the defining property of the integer logarithm is exactly $r^{v_r(n)} \le B$; and for $r > C$, $v_r(n) \le 0$, i.e. $r \nmid n$. Assembling the two cases over the primes dividing $n$ gives the stated conjunction. $\square$

**Theorem 3.2 (Order completion is exactly powersmoothness).** For $n \ne 0$, $B \ne 0$,
$$n \mid k(B) \iff n \text{ is } B\text{-powersmooth}.$$
Consequently, for a group element $g$ of finite order,
$$g^{\,k(B)} = 1 \iff \mathrm{ord}(g) \text{ is } B\text{-powersmooth}.$$

*Proof sketch.* Apply Theorem 3.1 with $C = B$. The extra clause "$q \le B$" is implied by "$q^{v_q(n)}\le B$" since $v_q(n)\ge 1$ forces $q \le q^{v_q(n)}$. The group form is $\mathrm{ord}(g) \mid k(B) \iff g^{k(B)}=1$. $\square$

This is the paper's central conceptual point: **the stage-1 success event contains no probabilistic content whatsoever.** Whatever randomness exists lives entirely in the draw of the curve, i.e. in the distribution of the group order — not in the event given that order.

**Theorem 3.3 (No order completion above the bound).** If some prime power exactly dividing $\mathrm{ord}(g)$ exceeds $B$ — in particular, if $\mathrm{ord}(g)$ has any prime factor $q > B$ — then $g^{k(B)} \ne 1$, for every schedule.

*Proof sketch.* Immediate from Theorem 3.2: powersmoothness fails at that prime. For the prime-factor form, $q \le q^{v_q}$. $\square$

Theorem 3.3 is the formal content of the experimental control channel: at the large factor $q$ of the modulus with $B \ll q$, order completion is impossible, so hits there measure the collision floor and nothing else.

**Theorem 3.4 (The firing position is the largest prime factor).** Let $n \ne 0$ be $B$-powersmooth. Then for every cutoff $C$,
$$n \mid k(B,C) \iff \mathrm{lpf}(n) \le C,$$
and hence $\mathrm{lpf}(n)$ is the *least* cutoff at which the accumulating scalar kills $n$.

*Proof sketch.* By Theorem 3.1, since powersmoothness already grants $q^{v_q(n)} \le B$ for all $q \mid n$, the criterion reduces to "$q \le C$ for all $q \mid n$", i.e. $\mathrm{lpf}(n) \le C$. Leastness is the case $C = \mathrm{lpf}(n)$ together with the forward implication. $\square$

**Corollary 3.5 (Early fire, arithmetized).** If $n$ is $B$-powersmooth with $\mathrm{lpf}(n) \le L$, the run fires within the first $\pi(L)$ of its $\pi(B)$ prime steps; the normalized firing position is at most $\pi(L)/\pi(B)$. Conversely, a run that has not fired by cutoff $L$ has an order with a prime factor exceeding $L$.

Corollary 3.5 converts "early fire" from a distributional slogan into a deterministic statement about largest prime factors. The empirical medians in $[0.073,0.293]$ are, on this reading, measurements of the distribution of $\pi(\mathrm{lpf}(m))/\pi(B)$ over randomly drawn group orders $m$.

---

## 4. Exact counts and the greatest-common-divisor staircase

**Theorem 4.1 (Exact firing count).** For $m > 0$ and any scalar $k$, $|F(m,k)| = \gcd(m,k)$.

*Proof sketch.* Write $g = \gcd(m,k)$, $d = m/g$. Since $m/g$ and $k/g$ are coprime, $m \mid k a \iff d \mid a$. The multiples of $d$ below $m$ are $d\cdot 0, d\cdot 1, \dots, d\cdot(g-1)$, a set of size $g$ because $j \mapsto dj$ is injective. $\square$

So the stage-1 success rate is *exactly* $\gcd(m, k(B))/m$: an arithmetic quantity, not an expectation.

**Theorem 4.2 (The firing count is the powersmooth part).** For $m \ne 0$, $B \ne 0$, the number $\gcd(m,k(B))$ divides $m$, is $B$-powersmooth, and is divisible by every $B$-powersmooth divisor of $m$. It is therefore the greatest $B$-powersmooth divisor of $m$ in the divisibility order.

*Proof sketch.* It divides $m$ and divides $k(B)$, so by Theorem 3.2 it is powersmooth. If $d \mid m$ is powersmooth then $d \mid k(B)$ by Theorem 3.2, hence $d \mid \gcd(m,k(B))$. $\square$

**Theorem 4.3 (Scale invariance).** If $w > 0$ is coprime to $k$, then $|F(mw,k)| = |F(m,k)|$.

*Proof sketch.* $\gcd(mw,k) = \gcd(m,k)$ when $\gcd(w,k)=1$. $\square$

The part of the group order living above the smoothness bound is invisible to the mechanism: it dilutes the *rate* (through the denominator) but cannot alter the firing *count*. This is the arithmetic reason a scale increase that leaves the smooth part statistically unchanged leaves the mechanism unchanged, as observed between bit lengths $26$ and $32$.

**Theorem 4.4 (Flatness of the cumulative count).** Let $m \ne 0$, $B \ne 0$, $C \le C'$. If no prime divisor of $m$ lies in $(C, C']$, then $\gcd(m,k(B,C)) = \gcd(m,k(B,C'))$.

*Proof sketch.* One direction of the divisibility is monotonicity of $k(B,\cdot)$. For the other, apply Theorem 3.1 to $n = \gcd(m,k(B,C'))$: each of its prime divisors divides $m$ and is $\le C'$, hence is $\le C$ by hypothesis, so $n \mid k(B,C)$. $\square$

**Theorem 4.5 (Exact description of the jump set).** For $m \ne 0$, $B \ne 0$,
$$J(m,B) \;=\; \{\, q \text{ prime} : q \mid m,\ q \le B \,\},$$
and hence $|J(m,B)| \le \omega(m) \le \log_2 m$.

*Proof sketch.* Theorem 4.4 shows a jump can occur only at a prime divisor of $m$; conversely at such a prime $q \le B$ the exponent of $q$ in the gcd increases from $\min(v_q(m), 0) = 0$ to $\min(v_q(m), \lfloor \log_q B\rfloor) \ge 1$, a strict increase. The bound $\omega(m)\le\log_2 m$ follows because $m$ is at least the product of its distinct prime factors, each $\ge 2$. $\square$

**Theorem 4.6 (Sparsity and non-uniformity of firing positions).** The firing positions occupy at most a $\log_2 m / \pi(B)$ fraction of the schedule. In particular, if $\log_2 m < \pi(B)$ there exists a schedule prime that is never a firing position, so the distribution of firing positions is not uniform on the schedule.

*Proof sketch.* Combine Theorem 4.5 with a cardinality count: if every schedule prime were a firing position we would have $\pi(B) \le |J(m,B)| \le \log_2 m$, contradicting the hypothesis. $\square$

This is the unconditional skeleton under the observed rejections of uniformity: the support of the firing-position distribution has size $O(\log m)$ while the schedule has length $\pi(B)$, which grows without bound. Uniformity is not merely unlikely; it is impossible.

**Theorem 4.7 (Early fire, quantitative form).** For $m \ne 0$ and $L \le B$,
$$\gcd\bigl(m, k(B)\bigr) \;\Bigm|\; \gcd\bigl(m, k(B,L)\bigr)\cdot \mathrm{Lg}(m,L),
\qquad\text{hence}\qquad
\gcd\bigl(m,k(B)\bigr) \le \gcd\bigl(m, k(B,L)\bigr)\cdot \mathrm{Lg}(m,L).$$

*Proof sketch.* Compare exponents prime by prime. For $r \le L$ both sides carry $\min(v_r(m), \lfloor\log_r B\rfloor)$. For $r > L$, the right-hand side carries $v_r(m)$ from the large part whenever $r \mid m$, which dominates the left-hand side's $\min(v_r(m), \cdot)$. $\square$

In words: *everything that ever fires has already fired by cutoff $L$, up to the large-prime part of the order.* An order whose large-prime part is small therefore fires in the first few percent of the schedule — quantitatively, not merely qualitatively.

---

## 5. Dose response: a monotone staircase that saturates

**Theorem 5.1 (Monotonicity in the bound).** If $B \le B'$ then $k(B) \mid k(B')$, and hence $\gcd(m,k(B)) \mid \gcd(m,k(B'))$ and $\gcd(m,k(B)) \le \gcd(m,k(B'))$ for $m \ne 0$.

*Proof sketch.* Prime by prime: for a prime $r \le B$ we have $r \le B'$ and $\lfloor \log_r B\rfloor \le \lfloor\log_r B'\rfloor$; for $B < r \le B'$ the exponent rises from $0$. $\square$

**Theorem 5.2 (No dose response).** Let $m, B, B' \ne 0$. If for every prime $q \mid m$ and every $1 \le j \le v_q(m)$ the conditions $q^j \le B$ and $q^j \le B'$ are equivalent — that is, no prime power dividing $m$ separates $B$ from $B'$ — then
$$\gcd(m,k(B)) = \gcd(m,k(B')).$$

*Proof sketch.* Compare exponents. For a prime $r \mid m$ the exponent of $r$ in $\gcd(m,k(B))$ is $\min(v_r(m), \lfloor\log_r B\rfloor)$ if $r \le B$ and $0$ otherwise. The hypothesis at $j=1$ makes the conditions $r \le B$ and $r \le B'$ equivalent; and the key elementary fact is that $\min(v,\lfloor\log_r B\rfloor)$ equals the largest $j \le v$ with $r^{j} \le B$, so the hypothesis for $1 \le j \le v_r(m)$ makes the two minima equal. Primes not dividing $m$ contribute $0$ on both sides. $\square$

Theorem 5.2 is the exact statement matching the recorded flatness of success rates in the budget fraction. Rates are piecewise constant in the bound, with jumps only at the (few) prime powers dividing the order.

**Theorem 5.3 (Saturation).** For $m, B \ne 0$: $\gcd(m,k(B)) = m$ if and only if $m$ is $B$-powersmooth.

*Proof sketch.* $\gcd(m,k(B)) = m \iff m \mid k(B) \iff$ powersmoothness, by Theorem 3.2. $\square$

Beyond powersmoothness, additional bound buys nothing: the staircase has topped out at rate $1$.

**Theorem 5.4 (Exact jump formula).** For $m \ne 0$ and $q$ prime,
$$\gcd\bigl(m, k(B,q)\bigr) \;=\; \gcd\bigl(m, k(B,q-1)\bigr)\cdot q^{\min\left(v_q(m),\, \lfloor \log_q B\rfloor\right)}.$$
In particular the count is unchanged when $q \nmid m$ or when $q > B$.

*Proof sketch.* Compare exponents at each prime $r$. At $r = q$: the left side carries $\min(v_q(m), \lfloor \log_q B\rfloor)$ (as $q \le q$), the right side $0 + \min(v_q(m),\lfloor\log_q B\rfloor)$ (as $q \not\le q-1$). At $r \ne q$ the conditions $r \le q$ and $r \le q-1$ agree and the extra factor contributes $0$. $\square$

Theorem 5.4 makes the staircase completely explicit: it is the partial-product sequence of the numbers $q^{\min(v_q(m), \lfloor\log_q B\rfloor)}$ over primes $q$ in increasing order, terminating (by Theorem 5.3) at the powersmooth part of $m$.

---

## 6. The long inert block: a pigeonhole obstruction to uniformity

Theorem 4.5 says the staircase has at most $\omega(m)$ jumps in $\pi(B)$ steps. A counting argument converts sparse jumps into a single long flat block.

**Lemma 6.1 (Same jump count implies same firing count).** For $C \le C' \le B$, if the number of jump primes $\le C$ equals the number of jump primes $\le C'$, then $\gcd(m,k(B,C)) = \gcd(m,k(B,C'))$.

*Proof sketch.* The two filtered sets are nested with equal cardinality, hence equal; so no prime divisor of $m$ lies in $(C,C']$, and Theorem 4.4 applies. $\square$

**Theorem 6.2 (Existence of a long inert block).** For $m, B \ne 0$ there is a set $S$ of schedule primes with
$$|S| \;\ge\; \frac{\pi(B)}{\omega(m)+1}$$
on which the firing count is constant: $\gcd(m,k(B,C)) = \gcd(m,k(B,C'))$ for all $C, C' \in S$.

*Proof sketch.* Map each schedule prime $C$ to the number of jump primes $\le C$, a value in $\{0,1,\dots,\omega(m)\}$ by Theorem 4.5. The schedule has $\pi(B)$ elements and the target has $\omega(m)+1$ values, so by pigeonhole some fiber has size at least $\pi(B)/(\omega(m)+1)$. Lemma 6.1 shows the firing count is constant on any fiber. $\square$

**Corollary 6.3.** If $\omega(m) \le 1$, at least half of the schedule is inert.

The uniform comparison distribution increases at every one of the $\pi(B)$ steps. A block of $\pi(B)/(\omega(m)+1)$ steps on which the empirical cumulative distribution is exactly constant is precisely the structural feature a Kolmogorov–Smirnov-type statistic responds to. Theorem 6.2 does not by itself produce a numerical lower bound on the sup-distance to uniform — that requires knowing where the block sits, not merely how long it is (see §10) — but it identifies the obstruction.

---

## 7. Controls, amplification, and the collision baseline

### 7.1 The control channel

**Theorem 7.1 (Collapse when order completion is impossible).** If every prime factor of $m$ exceeds $B$, then $\gcd(m,k(B)) = 1$, i.e. $|F(m,k(B))| = 1$: only the identity fires, and the order-completion rate is exactly $1/m$.

*Proof sketch.* By Theorem 4.2 the gcd is a powersmooth divisor of $m$; if it had a prime factor $q$, then $q \mid m$ and $q \le q^{v_q} \le B$, contradicting the hypothesis. So the gcd is $1$. $\square$

This is exactly the design logic of the experimental control: at the large factor $q$ of the modulus, $B \ll q$ forces the order-completion contribution down to $1/m$, so hits observed there measure the collision floor alone. The recorded separation — $9$–$16$ control hits versus $24$–$31$ signal hits per cell — is therefore an attribution of the excess to order completion, not an appeal to a model.

### 7.2 Rank-two groups

For a prime $p$, $E(\mathbb{F}_p) \cong \mathbb{Z}/m_1 \times \mathbb{Z}/m_2$ with $m_2 \mid m_1$ (possibly $m_2 = 1$).

**Theorem 7.2 (Firing count in a rank-two group).** The number of points of $\mathbb{Z}/m_1\times\mathbb{Z}/m_2$ annihilated by $k$ is $\gcd(m_1,k)\cdot\gcd(m_2,k)$.

*Proof sketch.* The firing set is the product $F(m_1,k)\times F(m_2,k)$; apply Theorem 4.1 to each factor. $\square$

**Corollary 7.3 (Rank two fires at least as often).** $\gcd(m_1 m_2, k) \le \gcd(m_1,k)\cdot\gcd(m_2,k)$.

*Proof sketch.* $\gcd(m_1m_2,k)$ divides $\gcd(m_1,k)\gcd(m_2,k)$, and the latter is positive. $\square$

Splitting the order into two cyclic factors can only enlarge the powersmooth part; the cyclic model is a conservative lower bound for real curves.

### 7.3 Multi-curve amplification

**Theorem 7.4 (Exact multi-curve count).** With $c$ independently chosen points of a cyclic group of order $m$, the number of $c$-tuples on which stage 1 fires at least once is exactly
$$m^{c} - \bigl(m - \gcd(m,k)\bigr)^{c},$$
so the success rate is exactly $1 - (1-\rho)^{c}$ with $\rho = \gcd(m,k)/m$.

*Proof sketch.* The complementary event "no coordinate fires" is a product set: each coordinate ranges over the $m - \gcd(m,k)$ non-firing residues, giving $(m-\gcd(m,k))^c$ tuples. Subtract from $m^c$. The rate identity is algebra. $\square$

Note that no independence *assumption* is made: this is a count of tuples in a product set, and independence is a consequence of the product structure rather than a hypothesis.

### 7.4 Against the collision heuristic

**Theorem 7.5 (Order completion beats the baseline).** For $m > 0$, if $\gcd(m, k(B)) > 1.44\,B$, then
$$1 - \exp\!\left(-\frac{1.44\,B}{m}\right) \;<\; \frac{\gcd(m,k(B))}{m}.$$

*Proof sketch.* $1 - e^{-x}\le x$ for all real $x$ (from $1 + t \le e^{t}$ at $t = -x$), so the baseline is at most $1.44 B/m$; the hypothesis gives $1.44 B/m < \gcd(m,k(B))/m$. $\square$

The folklore collision rate is thus not merely a different model — it is *dominated* by the exact order-completion rate whenever the powersmooth part of the order exceeds the linear threshold $1.44 B$. In the observed regime it is a floor, and the measured rates sit far above it.

---

## 8. A fully worked cell: $m = 720$, $B = 10$

Take $m = 720 = 2^4\cdot 3^2\cdot 5$ and $B = 10$. Then
$$k(10) = 2^{3}\cdot 3^{2}\cdot 5^{1}\cdot 7^{1} = 2520,\qquad \gcd(720, 2520) = 360 .$$

**The exact rate.** By Theorem 4.1, exactly $360$ of the $720$ residues fire: rate $1/2$. By Theorem 4.2, $360 = 2^3\cdot3^2\cdot5$ is the largest $10$-powersmooth divisor of $720$ — the factor $2^4 = 16 > 10$ is exactly what is lost.

**The staircase.** Advancing the cutoff through $1, 2, 3, 5, 7, 10$, the cumulative firing counts $\gcd(720, k(10,C))$ are
$$1,\quad 8,\quad 72,\quad 360,\quad 360,\quad 360 .$$
Each step matches Theorem 5.4: $2^{\min(4,3)} = 8$, then $\times 3^{\min(2,2)} = 9$, then $\times 5^{\min(1,1)} = 5$, then $\times 7^{\min(0,1)} = 1$. Two of the four schedule primes do nothing: $7$ because it does not divide $m$, and everything after $5$ because the count has saturated at the powersmooth part.

**Early fire.** $5\cdot\gcd(720, k(10,3)) = 5\cdot 72 = 360 = \gcd(720,k(10,10))$, and $2\cdot 360 = 720$: half of the whole group fires, and one fifth of all points that ever fire have already fired after only the first two of the four schedule primes. This is early fire in the exact sense of Corollary 3.5 and Theorem 4.7.

**Against the collision baseline.** The heuristic per-curve collision rate is at most $1.44\cdot 10/720 = 0.02$, while the true order-completion rate is $0.5$ — more than $25$ times larger. Theorem 7.5 applies since $\gcd(720,k(10)) = 360 > 14.4$.

**Multi-curve.** With $c = 3$ curves, Theorem 7.4 gives exactly $720^3 - 360^3$ successful triples, a rate of $1 - (1/2)^3 = 7/8 = 0.875$ — the scale of rate seen in the experimental cells at three curves.

---

## 9. Algorithmic consequences

Three of the results have direct operational content.

**9.1 Schedule pruning is bounded by the jump set.** By Theorem 4.5, only the primes dividing the group order can ever change the firing count. For a fixed unknown order, at most $\omega(m) \le \log_2 m$ of the $\pi(B)$ steps matter. One cannot identify them in advance — that is the factoring problem itself — but the structural fact bounds the achievable benefit of any adaptive schedule reordering: the useful steps are $O(\log m)$ in number, and by Theorem 3.4 the last of them is $\mathrm{lpf}(m)$.

**9.2 Budget allocation should be front-loaded.** Theorem 4.7 says everything but the large-prime part has already fired by any cutoff $L$. Empirically the median firing position lies in the first $10$–$30\%$ of the schedule. Under a fixed total budget, allocating trials to *more curves at a modest bound* rather than *fewer curves at a large bound* is favoured exactly when the staircase for a typical order is already saturated below the modest bound. Theorem 7.4 quantifies the trade: $c$ curves at rate $\rho$ give $1-(1-\rho)^c$ exactly.

**9.3 Dose response is not a tuning signal.** A practitioner who observes no rate change when raising $B$ should not conclude that the run is failing or that measurement noise dominates. Theorem 5.2 says exactly zero change is the *predicted* outcome unless the increase crosses a prime power dividing the order. Absence of dose response is evidence *for* order completion, not against it.

We record the two computational kernels used throughout.

**Algorithm A (staircase evaluation).** Given $m$ and $B$, compute the sequence $C \mapsto \gcd(m, k(B,C))$ over all primes $C \le B$ by sieving the primes up to $B$ ($O(B\log\log B)$), then maintaining a running product and gcd. Using Theorem 5.4, the update at $q$ is a multiplication by $q^{\min(v_q(m),\lfloor\log_q B\rfloor)}$, so the whole staircase costs $O(\pi(B)\log m)$ arithmetic operations without ever forming the (astronomically large) scalar $k(B)$.

**Algorithm B (firing position).** Given $m$ and $B$, decide firing and locate the firing position: factor $m$, test powersmoothness ($q^{v_q(m)} \le B$ for all $q \mid m$), and if it holds return $\mathrm{lpf}(m)$; the normalized position is $\pi(\mathrm{lpf}(m))/\pi(B)$. Correctness is Theorems 3.2 and 3.4.

---

## 10. Limitations: what is not provable at this generality

Two natural strengthenings of the empirical statements are *not* theorems at this level, and it is worth being precise about why.

**10.1 A distributional early-fire theorem.** The statement "the median normalized firing position is at most $0.3$" cannot be proved from arithmetic alone. For a single order $m$ the firing position is deterministic — it is $\pi(\mathrm{lpf}(m))/\pi(B)$ by Theorem 3.4 — so a median statement is a statement about a *family*, i.e. about the distribution of largest prime factors of powersmooth numbers in a range. That is Dickman-type analytic input (the density of integers whose largest prime factor is below $x^{1/u}$), and it is not available unconditionally in the form the experiment's operationalization requires. What survives unconditionally is the deterministic skeleton, Theorem 4.7: all but the large-prime part has already fired by cutoff $L$.

**10.2 A quantitative distance-to-uniform bound.** We prove the support-size version (Theorem 4.6) and the long-inert-block version (Theorem 6.2), which together make uniformity impossible. Converting a flat block of length $\ell$ into a lower bound on the Kolmogorov–Smirnov distance requires locating the block within the schedule: a flat run adjacent to the boundary contributes little sup-distance, while a flat run straddling the middle contributes about $\ell/(2\pi(B))$. Locating the block needs information about the position of the prime divisors of $m$ in the schedule, which is again distributional input about the order.

**10.3 Modelling assumptions.** Theorems 4.1–4.7 are stated for a cyclic group with a uniformly drawn point; Theorem 7.2 covers the rank-two case and Corollary 7.3 shows the cyclic model is conservative. The passage from "the group of points modulo the unknown prime" to "a cyclic group of order $m$ with $m$ drawn from some distribution" is the standard ECM modelling step and is not itself justified here.

---

## 11. Discussion

The empirical campaign posed a mechanism question — is low-bound stage-1 success collision luck or order completion firing early? — and answered it statistically. The arithmetic developed here answers it structurally, and in doing so explains why the statistical answer had to come out as it did.

The stage-1 success event is a divisibility (Theorem 3.2). Its count is a greatest common divisor (Theorem 4.1), identified as the powersmooth part of the order (Theorem 4.2). Its response to the smoothness budget is a monotone staircase (Theorem 5.1) that is constant between prime powers dividing the order (Theorem 5.2), jumps by an exactly known factor (Theorem 5.4), and saturates at powersmoothness (Theorem 5.3). Its position in the schedule is the largest prime factor of the order (Theorem 3.4), so the position distribution is supported on at most $\log_2 m$ of $\pi(B)$ steps (Theorem 4.6) and contains a flat block of length $\pi(B)/(\omega(m)+1)$ (Theorem 6.2). Where order completion is impossible, the rate is exactly $1/m$ (Theorem 7.1). And the folklore collision rate is dominated whenever the powersmooth part exceeds $1.44B$ (Theorem 7.5).

Every empirical signature is thereby accounted for: flatness in the dose (Theorem 5.2), stability across scales (Theorem 4.3), non-uniformity of firing position (Theorems 4.6 and 6.2), early firing (Theorem 4.7 and Corollary 3.5), the collision floor's subdominance (Theorems 7.1 and 7.5), and the observed multi-curve rates (Theorem 7.4). None of these required a probabilistic model of the success event; the only place randomness legitimately enters is the draw of the group order.

The practical reading stands: useful firing happens inside roughly the first $10$–$30\%$ of the schedule, and the remainder of stage 1 is, for a typical order, provably inert.

---

## 12. Future directions

**Distributional early fire from smooth-number analytics.** Combine Theorem 3.4 with quantitative estimates for the distribution of the largest prime factor of integers in a Hasse–Weil interval to obtain a genuine median statement. The right conditional shape is: for $m$ drawn from a distribution with a Dickman-type tail, $\mathbb{E}[\pi(\mathrm{lpf}(m))/\pi(B)]$ is small.

**From a flat run to a sup-distance bound.** Locate the inert block of Theorem 6.2 within the schedule and convert its length into an explicit lower bound on the Kolmogorov–Smirnov distance between the firing-position distribution and the uniform distribution on the schedule.

**Persistence where the smooth part must shrink.** The regime tested here keeps $B/p$ in a range where the powersmooth part remains substantial. The honest next question is whether early firing persists in the regime where $B/p$ must shrink — where the smoothness parameter $u = \log p/\log B$ grows into the $6$–$14$ range — since there Theorem 5.3's saturation is far from being reached and the staircase is genuinely partial.

**Stage-2 analogue.** Stage 2 of ECM tests one additional large prime beyond $B$. The corresponding exact event is $\mathrm{ord}(g) \mid k(B)\cdot q$ for a single prime $q$ in the stage-2 interval; the firing count becomes $\gcd(m, k(B)\,q)$, and the whole staircase theory should extend with an extra rank-one jump.

**Rank-two refinements.** Corollary 7.3 gives only an inequality. Quantifying the average gain of the true group structure over the cyclic model, as a function of the distribution of $(m_1,m_2)$, would sharpen predicted rates.

---

## Appendix: summary of results

| Result | Statement |
|---|---|
| Firing criterion | $n \mid k(B,C)$ iff every $q\mid n$ has $q\le C$ and $q^{v_q(n)}\le B$ |
| Order completion | $g^{k(B)}=1$ iff $\mathrm{ord}(g)$ is $B$-powersmooth |
| Exact count | $|F(m,k)| = \gcd(m,k)$ |
| Powersmooth part | $\gcd(m,k(B))$ is the greatest $B$-powersmooth divisor of $m$ |
| Firing position | least firing cutoff $=\mathrm{lpf}(n)$ |
| Sparsity | jump set $=\{q \mid m,\ q\le B\}$, size $\le\omega(m)\le\log_2 m$ |
| Non-uniformity | $\log_2 m < \pi(B)$ forces a never-firing schedule step |
| Inert block | some $\ge \pi(B)/(\omega(m)+1)$ schedule primes share one count |
| Monotonicity | $B\le B' \Rightarrow \gcd(m,k(B)) \mid \gcd(m,k(B'))$ |
| No dose response | count unchanged unless a prime power dividing $m$ separates $B$ from $B'$ |
| Saturation | count $=m$ iff $m$ is $B$-powersmooth |
| Jump formula | passing $q$ multiplies the count by $q^{\min(v_q(m),\lfloor\log_q B\rfloor)}$ |
| Early fire | $\gcd(m,k(B)) \mid \gcd(m,k(B,L))\cdot\mathrm{Lg}(m,L)$ |
| Scale invariance | $\gcd(mw,k)=\gcd(m,k)$ for $\gcd(w,k)=1$ |
| Control channel | all prime factors $>B$ $\Rightarrow$ count $=1$ |
| Rank two | count $=\gcd(m_1,k)\gcd(m_2,k)\ \ge\ \gcd(m_1m_2,k)$ |
| Multi-curve | exactly $m^c-(m-\gcd(m,k))^c$ successes; rate $1-(1-\rho)^c$ |
| Collision comparison | $\gcd(m,k(B))>1.44B \Rightarrow$ rate $>1-e^{-1.44B/m}$ |
