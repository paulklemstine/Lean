# The Firing Trace of Stage One of the Elliptic-Curve Method

### A largest-prime-factor law for the success moment, with model discrimination against the divisor null model and a scale-freeness obstruction for the collision baseline

---

## Abstract

Stage one of the elliptic-curve method of factorization (ECM) consumes the primes $p \le B_1$ in increasing order, multiplying an accumulating scalar by $p^{\lfloor \log_p B_1\rfloor}$ at each step. We study the *firing trace* of a successful run: the normalized index of the schedule step at which the accumulated scalar first annihilates the working point. We prove a **trace law**: for any order $n$ dividing the full stage-one multiplier $K(B_1)$ and any schedule cut $y$,
$$n \mid K(B_1, y) \iff P^{+}(n) \le y,$$
where $K(B_1,y) = \prod_{p \le y} p^{\lfloor \log_p B_1\rfloor}$ and $P^{+}(n)$ is the largest prime factor of $n$. Consequently the firing threshold is *exactly* $P^{+}(n)$ and the normalized firing index is $\pi(P^{+}(n))/\pi(B_1)$: the trace is a function of the largest prime factor alone.

Three consequences follow. **(i) The late tail is structurally thin.** Late firing forces a prime divisor in the window $(y, B_1]$, so the density of late firers among the integers in $(0,M]$ is at most $\sum_{y<p\le B_1}\lfloor M/p\rfloor$; at $B_1=100$ with the cut at $y=67$ — the final six of the twenty-five schedule steps, $24\%$ of the schedule — this caps the late mass at $2/25 = 8\%$, and the exact count over $(0, 67^2]$ is $330/4489 = 7.35\%$. A uniform firing index is therefore impossible, not merely unobserved. **(ii) The tail vanishes asymptotically.** From Erdős' primorial bound $y\# \le 4^{y}$ we derive the Chebyshev-type count $\#\{p : y < p \le B_1\}\cdot\lfloor\log_2 y\rfloor \le 2B_1$ and hence the unconditional density bound $2B_1 / (y\lfloor \log_2 y\rfloor)$, which is $4/\lfloor\log_2 y\rfloor \to 0$ for a cut at half the stage-one bound. **(iii) The divisor null model is refuted.** The divisors of $K(B_1)$ that fire by $y$ are exactly the divisors of $K(B_1,y)$, whence $\tau(K(B_1)) = \tau(K(B_1,y))\cdot\prod_{y<p\le B_1}(\lfloor\log_p B_1\rfloor+1)$; at $B_1=100$, $y=67$ the local factor is $64$, so the divisor model places $63/64\approx 98\%$ of its mass in precisely the window the integer model caps at $8\%$. The two models are more than a factor of twelve apart on the measured observable.

On the rate side we show that the random-collision baseline $1-(1-1/p)^{k}$ is bounded above by $k/p$, a quantity depending only on the ratio $k/p$ and therefore **scale free**: a collision-dominated account cannot predict any cross-scale collapse of the success rate at fixed $B_1/p$. At the honest operating point ($k = 2.59\,B_1$, $B_1/p = 0.125$) the ceiling is $0.324$ against a measured $0.625$, a $0.30$ excess that pigeonholes into at least $13$ genuine order-hits in a $40$-curve cell with $25$ successes.

Two pre-registered hypotheses — a uniform-then-late-concentrated firing index, and a bit-length collapse of the low-$B_1$ success rate toward the collision floor — are both refuted, the first with inverted geometry (hits fire near step zero: median index $0.09$–$0.10$; final-$20\%$ tail $0/55$, binomial $p\approx 0.004$) and the second by a flat cross-scale comparison ($65.0\%$ vs $62.5\%$, two-proportion $z$-test $p = 0.8161$). We close with a Mertens-type conjecture for the tail exponent, $\mathrm{tail}(\tau,B_1) = \log(1/(1-\tau))/\log B_1 \cdot (1+o(1))$, which matches computation to three decimal places at $B_1 = 10^6$.

**Keywords:** elliptic-curve method, smooth numbers, largest prime factor, Dickman–Golomb statistics, Mertens' theorem, primorial bounds, model discrimination.

---

## 1. Introduction

### 1.1 The question

The elliptic-curve method of factorization is a sub-exponential algorithm whose running time is governed by the density of smooth numbers. Given a composite $N$ with an unknown prime factor $p$, one selects a random elliptic curve $E$ over $\mathbb{Z}/N\mathbb{Z}$ and a point $P$ on it, and computes $K(B_1)\cdot P$ where
$$K(B_1) \;=\; \prod_{p' \le B_1} (p')^{\lfloor \log_{p'} B_1 \rfloor} \;=\; \mathrm{lcm}(1,2,\dots,B_1) \cdot (\text{units}).$$
If the order $n$ of $P$ in $E(\mathbb{F}_p)$ divides $K(B_1)$, then $K(B_1)\cdot P$ is the identity modulo $p$ but (typically) not modulo other prime factors of $N$; the projective arithmetic then requires an inverse of a quantity divisible by $p$, and the resulting greatest-common-divisor computation exposes $p$. By Hasse's theorem $|\#E(\mathbb{F}_p) - p - 1| \le 2\sqrt{p}$, so the success probability per curve is essentially the probability that a random integer near $p$ is $B_1$-smooth.

The literature is rich on *whether* and *how often* a curve succeeds. It is essentially silent on *when within a run* it succeeds. That is our subject. Since stage one is implemented as a walk over the schedule of primes $p_1 < p_2 < \dots < p_{\pi(B_1)}$, multiplying by $p_i^{\lfloor \log_{p_i} B_1\rfloor}$ at step $i$, each successful curve carries a *firing index*: the fraction of the schedule consumed at the moment the point died.

### 1.2 The pre-registered hypotheses

Two hypotheses were registered in advance of measurement.

**H1 (trace shape).** At small $B_1/p$, successes are dominated by accidental arithmetic collisions, which strike uniformly through the run; the firing index should therefore be **uniform** on $[0,1]$. At large $B_1/p$, successes reflect genuine *order completion*: the accumulated scalar must accrete every prime power the order needs, which should require most of the schedule; the firing index should therefore concentrate in the **final $20\%$**.

**H2 (rate collapse).** Guarded projective accounting carries a random-collision baseline of roughly $1-\exp(-cB_1/p)$ per curve, with $c$ the operations-per-unit-$B_1$ constant. If the low-$B_1$ successes are collision luck, then holding $B_1/p$ fixed and increasing the bit length of $p$ should drive the observed success rate down toward that baseline.

### 1.3 Results

Both hypotheses fail, and H1 fails with **inverted geometry**. Measured medians of the normalized firing index at $B_1/p = 0.9$ are $0.09$ and $0.102$ at bit lengths $26$ and $32$; the final-$20\%$ tail contains $0$ of $55$ recorded hits (binomial $p \approx 0.004$ against the registered $20\%$); and a Kolmogorov–Smirnov test rejects uniformity even at the small ratio $B_1/p=0.125$ ($p = 0.0166$ and $0.0446$). On the rate side, the measured per-cell success rates at $B_1/p = 0.125$ are $65.0\%$ (bit length $26$, CI $[0.495, 0.779]$) and $62.5\%$ (bit length $32$, CI $[0.470, 0.758]$) — far above the per-curve collision floor of $16.47\%$ computed with the registered constant $c=1.44$, and above the corrected floor of $27.1$–$27.8\%$ using the honest operation count $k = 2.59\,B_1$ — with no cross-scale drift whatever (two-proportion $z$-test, $p = 0.8161$).

Rather than stopping at these statistics, this paper supplies their *structural* explanation. Sections 2–4 develop the trace law and its consequences; Section 5 computes the competing divisor model exactly and shows the models make opposite predictions; Section 6 handles the collision baseline; Section 7 reports computation; Sections 8–9 discuss and conjecture.

---

## 2. The stage-one schedule and the trace law

### 2.1 Definitions

Throughout, $p$ and $q$ denote primes, $\pi(x)$ the prime-counting function, and $\lfloor \log_p B_1 \rfloor$ the largest exponent $e$ with $p^{e} \le B_1$.

> **Definition 2.1 (Schedule prefix).** For $y \ge 0$, $\mathcal{P}(y) := \{p \le y : p \text{ prime}\}$ is the set of schedule primes consumed by the time the walk reaches $y$.

> **Definition 2.2 (Partial stage-one multiplier).** For a stage-one bound $B_1$ and a cut $y$,
> $$K(B_1, y) \;:=\; \prod_{p \in \mathcal{P}(y)} p^{\lfloor \log_p B_1\rfloor}.$$
> We write $K(B_1) := K(B_1, B_1)$ for the full multiplier. Note $K(B_1,y) \ge 1$ always, and $K(B_1,y) = K(B_1, \min(y, B_1))$ since primes exceeding $B_1$ contribute exponent $0$.

> **Definition 2.3 (Largest prime factor).** $P^{+}(n) := \max\{p : p \mid n\}$ for $n \ge 2$, with the convention $P^{+}(0) = P^{+}(1) = 0$.

> **Definition 2.4 (Firing threshold and normalized index).** An order $n$ *fires at* $y$ if $n \mid K(B_1,y)$. It is *stage-one reachable* if $n \mid K(B_1)$. The **firing threshold** is $\inf\{y : n \mid K(B_1,y)\}$ and the **normalized firing index** is $\pi(\text{threshold})/\pi(B_1)$, a number in $[0,1]$.

> **Definition 2.5 (Late primes and late orders).** For a cut $y$, $\mathcal{L}(B_1,y) := \{p \text{ prime} : y < p \le B_1\}$. The *late orders* below $M$ are
> $$\mathcal{O}_{\mathrm{late}}(M,B_1,y) := \{n \in (0,M] : \exists\, p \in \mathcal{L}(B_1,y),\ p \mid n\}.$$

### 2.2 A preliminary lemma

> **Lemma 2.6.** Every prime dividing $K(B_1,y)$ is at most $y$.

*Proof.* Suppose the prime $q$ divides $\prod_{p \in \mathcal{P}(y)} p^{\lfloor\log_p B_1\rfloor}$. Since $q$ is prime it divides one of the factors $p^{\lfloor\log_p B_1\rfloor}$, hence divides $p$, hence equals $p$, and $p \le y$ by definition of $\mathcal{P}(y)$. $\square$

### 2.3 The trace law

> **Theorem 2.7 (Trace Law).** Let $n \ge 1$ be stage-one reachable, i.e. $n \mid K(B_1)$. Then for every $y \ge 0$,
> $$n \mid K(B_1, y) \quad\Longleftrightarrow\quad P^{+}(n) \le y.$$

*Proof.* ($\Rightarrow$) If $n = 1$ then $P^{+}(n) = 0 \le y$. Otherwise $n$ has a prime factorization, and $P^{+}(n) \mid n \mid K(B_1,y)$; Lemma 2.6 gives $P^{+}(n)\le y$.

($\Leftarrow$) Suppose $P^{+}(n) \le y$. Partition the schedule primes of $K(B_1)$ by the cut:
$$K(B_1) \;=\; \Big(\prod_{\substack{p \le B_1 \\ p \le y}} p^{\lfloor\log_p B_1\rfloor}\Big) \cdot \Big(\prod_{\substack{p \le B_1 \\ p > y}} p^{\lfloor\log_p B_1\rfloor}\Big) \;=\; A \cdot B .$$
Every prime $p$ occurring in $B$ satisfies $p > y \ge P^{+}(n)$, so $p \nmid n$; as $B$ is a product of powers of such primes, $\gcd(n, B) = 1$. Since $n \mid AB$ and $n$ is coprime to $B$, we get $n \mid A$. Finally $A$ divides $K(B_1,y)$ because the index set of $A$ is contained in $\mathcal{P}(y)$ (with the same exponents). $\square$

> **Corollary 2.8 (Exact threshold).** For stage-one reachable $n \ge 1$, the set $\{y : n \mid K(B_1,y)\}$ has least element exactly $P^{+}(n)$. Hence the firing threshold *is* the largest prime factor, and the normalized firing index is
> $$\mathrm{idx}(n) \;=\; \frac{\pi\big(P^{+}(n)\big)}{\pi(B_1)} .$$

> **Corollary 2.9 (Monotonicity).** If $P^{+}(m) \le P^{+}(n)$ then $\mathrm{idx}(m) \le \mathrm{idx}(n)$. The firing order is the largest-prime-factor order; no other feature of $m$ or $n$ intervenes.

The interpretive content of Theorem 2.7 is that the firing trace is a *lossy* observable in a very specific way: it records $P^{+}(n)$ and discards everything else about $n$ — its magnitude, its number of prime factors, its exponent pattern. Any prediction about the firing index is therefore a prediction about the distribution of largest prime factors, transported through the prime-counting compression $\pi$.

> **Remark 2.10 (Work-weighted form).** The same conclusion holds in work units rather than step counts. Since each schedule prime contributes a factor at most $B_1$ (because $p^{\lfloor \log_p B_1\rfloor} \le B_1$), we have $K(B_1,y) \le B_1^{\pi(y)}$; an order with a small largest prime factor is killed by a scalar of small bit length, not merely at an early step index. Conversely $\prod_{p \le B_1} p$ divides $K(B_1)$, since every prime $p \le B_1$ has $\lfloor \log_p B_1\rfloor \ge 1$.

---

## 3. The late tail is structurally thin: refutation of H1

### 3.1 Late firing forces a large prime

> **Proposition 3.1.** Let $n \ge 1$ be stage-one reachable and suppose $n \nmid K(B_1,y)$. Then there is a prime $p \in \mathcal{L}(B_1,y)$ with $p \mid n$; indeed $p = P^{+}(n)$ works.

*Proof.* By Theorem 2.7, $n \nmid K(B_1,y)$ forces $P^{+}(n) > y$; in particular $n \ge 2$, so $P^{+}(n)$ is a genuine prime divisor. Applying Theorem 2.7 with $y := B_1$ (where reachability gives $n \mid K(B_1)$) yields $P^{+}(n) \le B_1$. Hence $P^{+}(n) \in (y, B_1]$. $\square$

Thus every late firer sits inside $\mathcal{O}_{\mathrm{late}}(M,B_1,y)$ once $n \le M$, and the analytic problem becomes: *how many integers below $M$ are divisible by a prime in $(y,B_1]$?*

### 3.2 The sieve bound

> **Theorem 3.2 (Union bound on the late tail).** For all $M, B_1, y$,
> $$\#\,\mathcal{O}_{\mathrm{late}}(M,B_1,y) \;\le\; \sum_{p \in \mathcal{L}(B_1,y)} \Big\lfloor \frac{M}{p} \Big\rfloor \;\le\; M \sum_{p \in \mathcal{L}(B_1,y)} \frac{1}{p}.$$

*Proof.* $\mathcal{O}_{\mathrm{late}}$ is contained in the union over $p \in \mathcal{L}(B_1,y)$ of $\{n \le M : p \mid n\}$, each of which has exactly $\lfloor M/p\rfloor$ elements; sub-additivity of cardinality over a union gives the first inequality, and $\lfloor M/p\rfloor \le M/p$ the second. $\square$

> **Theorem 3.3 (Exactness in the short range).** If $M \le y^{2}$ the union above is *disjoint*, and
> $$\#\,\mathcal{O}_{\mathrm{late}}(M,B_1,y) \;=\; \sum_{p \in \mathcal{L}(B_1,y)} \Big\lfloor \frac{M}{p}\Big\rfloor .$$

*Proof.* If distinct late primes $p \ne q$ both divided some $n \le M$, coprimality would give $pq \mid n$, hence $y^{2} < pq \le n \le M \le y^{2}$, a contradiction. Disjointness makes the union bound an equality. $\square$

So in the regime $M \le y^{2}$ the late-firing density is *exactly* a truncated reciprocal prime sum — the object Mertens' theorem was designed to evaluate. This is the technical hinge of the whole paper: the trace law converts a positional question about an algorithm's ladder into a question about $\sum_{y<p\le B_1} 1/p$.

### 3.3 The concrete instance $B_1 = 100$

Take $B_1 = 100$, so $\pi(100) = 25$ and the schedule has twenty-five steps. Cut at $y = 67$, i.e. after step $\pi(67) = 19$. Then
$$\mathcal{L}(100, 67) = \{71, 73, 79, 83, 89, 97\},$$
the final six steps — $24\%$ of the schedule by step count, and hence a window at least as generous as the pre-registered "final $20\%$".

> **Lemma 3.4.** $\displaystyle\sum_{p \in \mathcal{L}(100,67)} \frac{1}{p} = 0.07401\ldots < \frac{2}{25} = 0.08 .$

> **Theorem 3.5 (Refutation of H1 at $B_1 = 100$).** For every $M \ge 1$,
> $$\#\,\mathcal{O}_{\mathrm{late}}(M, 100, 67) \;<\; \frac{2}{25}\,M \;=\; 0.08\,M .$$
> A uniform firing index over the final $24\%$ of the schedule would require density $0.24$; even the weaker registered target of $0.20$ exceeds the structural cap by a factor of $2.5$. Uniformity of the firing index is impossible, not merely unobserved.

*Proof.* Combine Theorem 3.2 with Lemma 3.4. $\square$

> **Theorem 3.6 (Exact value and two-sided sandwich).** Taking $M = 67^{2} = 4489$, Theorem 3.3 applies and
> $$\#\,\mathcal{O}_{\mathrm{late}}(4489, 100, 67) \;=\; 330, \qquad \frac{1}{20} \;<\; \frac{330}{4489} = 0.07351\ldots \;<\; \frac{1}{5}.$$
> The late tail is genuinely positive — the structure does not forbid late firing — but it carries roughly one third of the mass uniformity assigns it.

### 3.4 Likelihood of the observed empty tail

The experiment recorded $55$ hits, none in the final $20\%$ of the schedule.

> **Proposition 3.7.** Under the pre-registered uniform law the probability of an empty final-$20\%$ tail across $55$ independent hits is $(4/5)^{55} = 4.677\times 10^{-6}$. Under the structural cap of Theorem 3.5 (late mass $\le 2/25$) it is at least $(23/25)^{55} = 1.019 \times 10^{-2}$. Hence
> $$1000 \cdot (4/5)^{55} \;<\; (23/25)^{55},$$
> a likelihood ratio exceeding $2000$ in favour of the structural law.

This is the model-theoretic counterpart of the reported binomial rejection ($p \approx 0.004$): the data do not merely reject uniformity, they are *typical* under the structural alternative.

---

## 4. Asymptotics: the late tail decays like $1/\log B_1$

Section 3 is a numerical instance. We now remove the numerics.

> **Lemma 4.1 (Late primes divide the primorial).** $\prod_{p \in \mathcal{L}(B_1,y)} p$ divides the primorial $B_1\# = \prod_{p \le B_1} p$.

> **Theorem 4.2 (Chebyshev-type count of the late schedule).** For $y \ge 2$,
> $$\#\mathcal{L}(B_1,y)\cdot \lfloor \log_2 y\rfloor \;\le\; 2 B_1 .$$

*Proof.* Write $k = \#\mathcal{L}(B_1,y)$. Every late prime exceeds $y$, so $y^{k} \le \prod_{p\in\mathcal{L}} p$. By Lemma 4.1 and Erdős' bound $B_1\# \le 4^{B_1}$, that product is at most $4^{B_1}$. Also $2^{\lfloor \log_2 y\rfloor} \le y$. Chaining,
$$2^{k\lfloor \log_2 y\rfloor} = \big(2^{\lfloor\log_2 y\rfloor}\big)^{k} \le y^{k} \le \prod_{p \in \mathcal{L}} p \le 4^{B_1} = 2^{2B_1},$$
and comparing exponents of $2$ gives the claim. $\square$

> **Lemma 4.3.** $\displaystyle\sum_{p \in \mathcal{L}(B_1,y)} \frac{1}{p} \;\le\; \frac{\#\mathcal{L}(B_1,y)}{y}$, since each late prime exceeds $y$.

> **Theorem 4.4 (Unconditional late-density bound).** For all $M, B_1$ and every cut $y \ge 2$,
> $$\#\,\mathcal{O}_{\mathrm{late}}(M,B_1,y) \;\le\; \frac{2 M B_1}{y\,\lfloor \log_2 y\rfloor}.$$

*Proof.* Theorem 3.2 gives $\#\mathcal{O}_{\mathrm{late}} \le M\sum_{p\in\mathcal L} 1/p$; Lemma 4.3 bounds the sum by $\#\mathcal{L}/y$; Theorem 4.2 bounds $\#\mathcal{L}$ by $2B_1/\lfloor\log_2 y\rfloor$. $\square$

> **Corollary 4.5 (No constant-fraction late tail).** If the cut is at half the stage-one bound, $B_1 \le 2y$, then
> $$\frac{\#\,\mathcal{O}_{\mathrm{late}}(M,B_1,y)}{M} \;\le\; \frac{4}{\lfloor \log_2 y\rfloor} \;\xrightarrow[\;y\to\infty\;]{}\; 0 .$$
> In particular no fixed positive fraction — such as H1's $20\%$ — can be the late tail for all large $B_1$.

> **Example 4.6.** At $B_1 = 2^{20}$ with the cut at $y = 2^{19}$, Corollary 4.5 gives a late density below $4/19 \approx 0.2105$; at $B_1 = 2^{26}$, below $0.16$; at $B_1 = 2^{32}$, below $0.129$. The bound is deliberately crude (it discards the sparsity of primes beyond the Erdős estimate) but its *direction* is unconditional: the ceiling descends like the reciprocal of a logarithm.

---

## 5. Model discrimination: integer model versus divisor model

Theorems 3.5 and 4.4 are statements about a specific null model — the order is a uniform *integer* in $(0,M]$. The competing model, implicit whenever one says "the accounting is collision-dominated", takes the order to be a uniform *divisor of $K(B_1)$*. That model is computable exactly, and it predicts the opposite.

> **Theorem 5.1 (Divisor firing set).** For all $B_1, y$,
> $$\{d \mid K(B_1) : P^{+}(d) \le y\} \;=\; \{d : d \mid K(B_1,y)\}.$$
> That is, the divisors of the full multiplier that fire by position $y$ are exactly the divisors of the partial multiplier.

*Proof.* Immediate from Theorem 2.7 in both directions, using that $K(B_1,y) \mid K(B_1)$ (which follows from $K(B_1,y) = K(B_1,\min(y,B_1))$ and monotonicity of the index set). $\square$

> **Lemma 5.2 (Divisor count of a squarefree-indexed prime-power product).** For a finite set $S$ of primes and any exponent function $e : S \to \mathbb{N}$,
> $$\tau\Big(\prod_{p\in S} p^{e(p)}\Big) = \prod_{p \in S} \big(e(p)+1\big).$$

> **Theorem 5.3 (Divisor-model firing law).** For all $B_1, y$,
> $$\tau\big(K(B_1)\big) \;=\; \tau\big(K(B_1,y)\big)\cdot \prod_{p \in \mathcal{L}(B_1,y)} \big(\lfloor \log_p B_1\rfloor + 1\big).$$
> Equivalently, a uniformly random divisor of $K(B_1)$ fires by position $y$ with probability exactly
> $$\Big(\prod_{p \in \mathcal{L}(B_1,y)} \big(\lfloor\log_p B_1\rfloor+1\big)\Big)^{-1}.$$

*Proof.* Split $\mathcal{P}(B_1) = \mathcal{P}(\min(y,B_1)) \sqcup \mathcal{L}(B_1,y)$; the two resulting factors of $K(B_1)$ are coprime, so $\tau$ is multiplicative across them; apply Lemma 5.2 to the late factor and Theorem 5.1 to identify the early factor with $\tau(K(B_1,y))$. $\square$

> **Corollary 5.4 (The divisor model fires late).** At $B_1 = 100$, $y = 67$: each of the six late primes has $\lfloor \log_p 100\rfloor = 1$, so the local factor is $2^{6} = 64$ and
> $$\tau\big(K(100)\big) = 64 \cdot \tau\big(K(100,67)\big), \qquad \frac{\tau(K(100,67))}{\tau(K(100))} = \frac{1}{64}.$$
> The divisor model therefore places $63/64 = 98.44\%$ of its firing mass in the final six schedule steps. (Numerically $\tau(K(100)) = 660{,}602{,}880$ and $\tau(K(100,67)) = 10{,}321{,}920$.)

> **Theorem 5.5 (Discrimination).** On the single observable measured — the mass in the final six of the twenty-five schedule steps at $B_1 = 100$ — the integer model caps the mass at $2/25 = 0.08$ (Theorem 3.5) while the divisor model requires $63/64 = 0.984$. Since $12 \cdot (2/25) < 63/64$, the two null models differ by more than a factor of twelve, and the observable is decisive between them.

> **Corollary 5.6 (Verdict).** The measured empty tail has likelihood $(1/64)^{55} \approx 4.6\times10^{-100}$ under the divisor model, versus $\ge 10^{-2}$ under the integer model. The order of a point on a random curve behaves, as far as the firing trace is concerned, like a random *integer* below $B_1$, not like a random *divisor* of the stage-one multiplier. The early-fire signature is the $\pi$-compression of a typical largest prime factor.

This is worth emphasising as a methodological point: the trace observable was designed to test a hypothesis about *timing*, and it happens also to be a sharp discriminator between two natural priors on the order. Negative results about the registered hypotheses are thus accompanied by a positive result about model selection.

---

## 6. The collision baseline: refutation of H2

### 6.1 The ceiling

> **Definition 6.1.** The *collision probability* of a run of $k$ guarded group operations modulo $p$ is $\mathrm{coll}(p,k) := 1 - (1 - 1/p)^{k}$: the chance that some intermediate quantity is accidentally divisible by $p$, irrespective of the point's order.

> **Theorem 6.2 (Bernoulli ceiling).** For every prime $p$ and every $k \ge 0$, $\mathrm{coll}(p,k) \le k/p$.

*Proof.* Bernoulli's inequality $(1+x)^{k} \ge 1 + kx$ holds for $x \ge -2$ and $k \in \mathbb{N}$; apply it with $x = -1/p \ge -1$, so $(1-1/p)^{k} \ge 1 - k/p$, i.e. $1 - (1-1/p)^{k} \le k/p$. $\square$

### 6.2 Scale freedom, and why H2 was untestable as posed

> **Theorem 6.3 (Scale freedom).** If $k/p = \ell/q$ then $\mathrm{coll}(p,k) \le \ell/q$ and $\mathrm{coll}(q,\ell) \le k/p$: the ceiling is a function of the ratio alone.

The consequence is structural. In the experiment, the operation count is $k = c\,B_1$ and the design fixes $B_1/p$; hence $k/p = c\,(B_1/p)$ is *invariant* across bit lengths by construction. A collision-dominated account therefore predicts **the same** ceiling at $26$ bits and at $32$ bits. H2 asserted that the observed rate should collapse toward the floor as the bit length grows; but the floor does not move, so no such collapse is implied by the collision hypothesis in the first place. The measured flatness — $65.0\%$ versus $62.5\%$, two-proportion $z$-test $p = 0.8161$ — is exactly what *both* hypotheses predict, and therefore discriminates neither. H2 is not merely false: as posed, it was not a test.

What *does* discriminate is the level.

### 6.3 The level: collisions are subdominant

The pre-registration used $c = 1.44$, giving a per-curve floor of $1 - \exp(-1.44 \cdot 0.125) = 16.47\%$. Auditing the implementation showed the true operation count is $c = 2.59$ per unit of $B_1$; we recompute both ways and report both. With $c = 2.59$ and $B_1/p = 0.125$,
$$\frac{k}{p} = 2.59 \times 0.125 = 0.32375 \;<\; 0.324,$$
so by Theorem 6.2 the per-curve collision probability is at most $0.324$ for *every* prime $p$. (Exponential-model per-curve means are $27.1$–$27.8\%$; three-curve cell means under exact-op collision arithmetic are $61.2$–$62.3\%$, coincidentally close to the measured cell rates — a coincidence we flag explicitly below.)

> **Theorem 6.4 (Subdominance).** If $k \le 0.324\,p$ and the observed per-curve success rate satisfies $\mathrm{obs} \ge 0.625$, then $\mathrm{coll}(p,k) + 0.3 \le \mathrm{obs}$.

*Proof.* $\mathrm{coll}(p,k) \le k/p \le 0.324$ by Theorem 6.2, and $0.324 + 0.3 = 0.624 \le 0.625 \le \mathrm{obs}$. $\square$

### 6.4 Pigeonhole: genuine order-hits must exist

> **Theorem 6.5.** Let $S$ be the set of successful curves in a batch and $C$ the set of collision-driven ones. Then $\#(S\setminus C) \ge \#S - \#C$.

*Proof.* $S \subseteq (S\setminus C)\cup C$, so $\#S \le \#(S\setminus C)+\#C$. $\square$

> **Corollary 6.6 (The measured cell).** In a cell of $40$ curves with $25$ successes, at most $\lfloor 0.324\cdot 40\rfloor = 12$ can be collision-driven, so at least $\mathbf{13}$ successes are genuine order-hits.

**Verdict on H2.** Collisions are real and non-negligible — they account for up to a third of per-curve successes at the operating point — but they are *subdominant*, and the low-$B_1$ successes cannot be explained away as collision luck. Moreover the collision hypothesis is structurally incapable of predicting the cross-scale collapse H2 asserted.

---

## 7. Computation

We report direct computation over uniform orders, taking $B_1 = N$ and letting $n$ range over all integers in $(0,N]$, with the firing index $\pi(P^{+}(n))/\pi(N)$ evaluated by a largest-prime-factor sieve (cost $O(N\log\log N)$).

| $N$ | schedule steps $\pi(N)$ | median index | mean index | final-$20\%$ mass | first-$20\%$ mass |
|---:|---:|---:|---:|---:|---:|
| $10^{3}$ | $168$ | $0.083$ | $0.176$ | $3.4\%$ | $73.0\%$ |
| $10^{4}$ | $1229$ | $0.035$ | $0.122$ | $2.5\%$ | $81.7\%$ |
| $10^{5}$ | $9592$ | $0.014$ | $0.091$ | $1.9\%$ | $86.3\%$ |
| $10^{6}$ | $78498$ | $0.006$ | $0.072$ | $1.6\%$ | $89.0\%$ |

A uniform firing index would produce $0.500$ in both the median and mean columns and $20.0\%$ in both mass columns. Instead:

* the median firing index tends to zero — consistent with the measured medians $0.09$–$0.102$ at the (much smaller) $B_1$ of the live experiment;
* the final-$20\%$ mass decays monotonically, in line with Corollary 4.5;
* the first-$20\%$ mass rises toward $90\%$: the trace is overwhelmingly an early-fire phenomenon.

Direct verification of the trace law on all $(\text{divisor}, \text{cut})$ pairs for $B_1 \in \{12, 20, 30\}$ — $576$, $8640$ and $84{,}480$ pairs respectively — records zero violations, as Theorem 2.7 requires.

---

## 8. Discussion

### 8.1 Why the intuition failed

The intuition behind H1 was that "order completion takes the whole schedule". It is a natural picture and it is wrong for a specific reason: the accumulated scalar is not accreting the order's factors one at a time in a race against the schedule's end. By the time the walk has passed a prime $p$, the scalar already contains $p$ to the *maximum* exponent stage one will ever supply. So a reachable order is satisfied the instant its largest prime factor has been passed — and largest prime factors of typical integers are small. The $\pi$-rescaling then amplifies the effect enormously, because prime density falls off: passing from step $\pi(y)$ to $\pi(2y)$ costs many schedule steps but adds only sparse, high primes, which few orders need.

### 8.2 The trace law as a bridge

Theorem 2.7 has a use beyond refutation. It says the firing trace is an *observable of $P^{+}$*, so any classical result about the distribution of the largest prime factor becomes a prediction about the algorithm's runtime profile, and conversely any measured trace becomes an empirical probe of $P^{+}$ statistics on the arithmetically constrained population of elliptic-curve group orders. The Dickman function $\rho$, which governs $\Pr[P^{+}(n) \le n^{1/u}] \to \rho(u)$, and Golomb's results on the largest-prime-factor distribution, are the natural asymptotic inputs; Theorem 3.3 shows the finite-range problem is *exactly* a truncated Mertens sum.

### 8.3 Honest caveats

Several limitations are inherent to the measurement and are stated here so that the structural theorems are not over-read.

1. **Operation-count constant.** The pre-registered baseline used $c = 1.44$; the honest count is $c = 2.59$. All baselines are recomputed both ways and both are reported. The corrected floor is higher and correspondingly weakens — but does not overturn — the excess argument of Section 6.
2. **Numerical coincidence.** Under exact-operation collision arithmetic, three-curve cell means come out at $61.2$–$62.3\%$, uncomfortably close to the measured cell rates. This coincidence is flagged rather than suppressed. The per-curve excess (Theorem 6.4), the trace-shape rejection, and the empty late tail are what rule out collision dominance; the cell-level rate alone would not.
3. **Censoring.** Successes attributable purely to the second cofactor are censored from the accounting and are not counted as order-hits; this is a conservative choice that, if anything, understates the order-hit fraction.
4. **Silent failure mode.** One class of degenerate curves collapses without a diagnostic; this behaviour is inherited from the parent experimental design and is not re-derived here.
5. **Bound crudeness.** Corollary 4.5 discards prime sparsity beyond the Erdős estimate; the true decay is expected to be governed by the Mertens law of Section 9, which is sharper by a constant factor and matches computation closely.
6. **Independence in the likelihood computation.** Proposition 3.7 treats the $55$ hits as independent Bernoulli trials, which is the same assumption the pre-registered binomial test made; correlations induced by shared curve parameters would inflate both likelihoods but not, to first order, their ratio.

### 8.4 A caught error, reported

During instrumentation the closed-form step counter — used to cross-check the traced counter — was initially wrong on later chunks of the schedule: the relevant length *doubles* and the population count *adds*, rather than the off-by-one behaviour first coded. The discrepancy was caught by an assertion comparing traced against closed-form counts *before any full dataset existed*, fixed, and re-verified against $29$ of $29$ smoke curves; smoke data were regenerated after the fix. No result in this paper depends on the pre-fix counter.

### 8.5 Where this sits

This work is an audit that closes an evidence chain rather than a breach of any barrier. An earlier finding — that no abrupt destruction threshold appears in the parameter regime studied — was challenged on the grounds that its accounting conflated smoothness hits with collisions. The proposed amendment is rejected here, on two independent grounds (level and trace shape), and the earlier no-threshold account stands unamended. No constant is improved and no complexity claim is made. What is new is the trace law and the family of bounds it generates.

---

## 9. Future work

### 9.1 The Mertens Firing-Tail Law (conjecture)

Cut the schedule at the $(1-\tau)$-quantile, i.e. at $y$ with $\pi(y) = (1-\tau)\pi(B_1)$. By Theorem 3.3 the late-firing density in the short range is the truncated reciprocal sum $\sum_{y<p\le B_1} 1/p$, and Mertens' second theorem evaluates it as $\log\log B_1 - \log\log y + o(1)$. With $y \approx B_1^{1-\tau'}$ for the corresponding logarithmic scale, this suggests:

> **Conjecture 9.1 (Mertens Firing-Tail Law).**
> $$\mathrm{tail}(\tau, B_1) \;=\; \frac{\log\big(1/(1-\tau)\big)}{\log B_1}\,\big(1 + o(1)\big) \qquad (B_1 \to \infty).$$

At $\tau = 0.2$ the numerator is $\log(1.25) = 0.2231$, and the prediction against the computed table of Section 7 is:

| $B_1$ | predicted $\mathrm{tail}(0.2)$ | measured |
|---:|---:|---:|
| $10^{3}$ | $0.0323$ | $0.0340$ |
| $10^{4}$ | $0.0242$ | $0.0250$ |
| $10^{5}$ | $0.0194$ | $0.0190$ |
| $10^{6}$ | $0.0162$ | $0.0160$ |

Agreement to within a few thousandths across three orders of magnitude. Proving Conjecture 9.1 requires (i) an effective form of Mertens' theorem over the truncated range, (ii) control of the $\pi$-quantile-to-value conversion, and (iii) an inclusion–exclusion correction beyond the short range $M \le y^{2}$, where multiple large prime divisors become possible.

### 9.2 Further directions

* **Beyond the short range.** Theorem 3.3 is exact only for $M \le y^{2}$. A second-order inclusion–exclusion term $-\sum_{y<p<q\le B_1}\lfloor M/pq\rfloor$ should extend exactness to $M \le y^{3}$, and a full Legendre-type expansion should give the tail to all orders.
* **Sharpening the Chebyshev input.** Replacing Erdős' $4^{B_1}$ by an effective Chebyshev bound $\theta(x) < 1.001102\,x$ would improve the constant in Theorem 4.4 from $2$ to roughly $1.45/\log 2$, tightening Corollary 4.5.
* **Stage two.** The continuation phase of the elliptic-curve method admits a single extra large prime beyond $B_1$; the trace law should extend to a two-parameter statement in which the firing threshold is $\max(P^{+}_{(2)}(n), \text{second-largest})$, with the late tail governed by a two-dimensional Dickman-type region.
* **Order-population bias.** Elliptic-curve group orders are not uniform integers: they are biased by torsion structure and by the curve's construction. Quantifying the deviation of $P^{+}$ statistics on that population from the uniform-integer baseline would sharpen every density estimate here.
* **Early-abort scheduling.** If nine-tenths of the firing mass lies in the first fifth of the schedule, a practical implication follows: a *fractional* stage-one run at $B_1$ captures most of the hits of a full run, and the optimal allocation of a fixed operation budget across curves and schedule fractions is a concrete optimization problem the trace law makes tractable.
* **Trace as a diagnostic.** Because the firing index reads off $\pi(P^{+}(n))/\pi(B_1)$, an observed trace is a direct measurement of the largest prime factor of the hidden group order — usable as a runtime diagnostic to re-tune $B_1$ adaptively mid-computation.

---

## 10. Conclusion

The moment at which the first stage of the elliptic-curve method succeeds is not a complicated function of the run. It is the largest prime factor of the point's order, read through the prime-counting function. From that single identity follow: the structural thinness of the late tail (below $8\%$ at $B_1 = 100$, versus $20$–$24\%$ under uniformity), its unconditional decay like $1/\log$, the exact firing law of the competing divisor model and its refutation by more than a factor of twelve, and — on the rate side — the scale freedom of the collision baseline that renders a bit-length-collapse hypothesis untestable, together with a level gap of thirty percentage points that pigeonholes into at least thirteen genuine order-hits per measured cell.

Two pre-registered hypotheses died. The replacement is not another statistical claim but a theorem, and it points at one of the oldest questions in multiplicative number theory: how big is the biggest prime in a random integer? Almost always, small — which is precisely why this clock always strikes early.
