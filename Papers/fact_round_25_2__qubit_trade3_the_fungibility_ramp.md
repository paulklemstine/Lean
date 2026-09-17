# The Unlucky Half

### Why some numbers keep their secrets no matter how many times you ask

---

## 0 · A slot machine that has been welded shut

Imagine a bank of slot machines that each pay out one time in twenty. With a hundred pulls your chance of winning is
$$1 - (1 - 0.05)^{100} \approx 0.994 .$$
That is the logic of every randomized algorithm: *samples are a currency*. Spend more, get more.

Now weld one machine in three shut. They still hum, the lever still moves, the reels still spin — and they will never pay. Your success curve still rises with every pull, but it rises toward a ceiling made of the fraction of machines that actually work. Past a point the right advice is not "pull harder"; it is "walk to a different machine".

This page is about a welded machine hidden inside the most celebrated randomized algorithm in quantum computing — the period-finding route to integer factorization — and about the razor-sharp arithmetic law that tells you, before you spend a single sample, which machine you are standing at.

> **The punchline, up front.** For $N = pq$ a product of two distinct odd primes and a base $a$, write the multiplicative orders of $a$ modulo each prime as a power of two times an odd number: $\operatorname{ord}_p(a) = 2^i u$, $\operatorname{ord}_q(a) = 2^j v$. Then period certificates can factor $N$ using this base **if and only if $i \neq j$**. Nothing else matters — not the size of $N$, not the length of the period, not the number of measurements.

---

## 1 · The classical miracle that factoring rests on

<details>
<summary><b>Refresher: multiplicative order, and why it factors numbers</b> (click to expand)</summary>

Fix $N$ and a base $a$ coprime to it. The powers $a, a^2, a^3, \dots \bmod N$ eventually return to $1$; the first time this happens, at step $L$, defines the **multiplicative order** $L = \operatorname{ord}_N(a)$.

If $L$ is even we may write
$$\left(a^{L/2}-1\right)\left(a^{L/2}+1\right) = a^L - 1 \equiv 0 \pmod N .$$
So $N$ divides a product of two numbers. If $N$ divides *neither* of them, then its prime factors must be distributed between the two — and Euclid's algorithm recovers one of them instantly:
$$\gcd\!\left(a^{L/2}-1,\ N\right) \in \{p, q\}.$$

The quantum part of a factoring pipeline does exactly one job: it estimates $L$. Everything after that — the halving, the subtraction, the gcd — is grade-school arithmetic. A useful vocabulary: an exponent $m$ with $N \mid a^{2m}-1$ is a **period certificate**; the classical stage consumes certificates and tries to turn them into factors.

Background reading: [multiplicative order](https://en.wikipedia.org/wiki/Multiplicative_order), [Shor's algorithm](https://en.wikipedia.org/wiki/Shor%27s_algorithm), [the Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem).
</details>

The whole story hinges on the word *neither*. If $a^{L/2} \equiv 1 \pmod N$ the gcd is $N$; if $a^{L/2} \equiv -1 \pmod N$ the gcd is $1$. Textbooks call this bad luck and tell you to try again.

It is not luck. For a **fixed base** it is a permanent property, and the next widget lets you see it happen.

---

## 2 · Play the lottery yourself

Pick a semiprime, pick a base, and read the verdict. Then press *random unlucky base* and look at panel 3: it scans **every** exponent the sampling stage could ever return, and finds nothing. That is what a structural cap looks like from the inside.

{{interactive_demo:0}}

Things worth trying:

* Set $p = 23$, $q = 29$, and step the base slider. Watch the valuation row: the verdict flips exactly when the two valuations separate, and never for any other reason.
* Find two *different* orders with the *same* valuation — for instance $22 = 2 \cdot 11$ and $14 = 2\cdot 7$. Same verdict as identical orders: unlucky. **It is the valuation, not the order, that decides.**
* In panel 2, notice that red cells form a product pattern, not a diagonal — that is the geometry behind the density bound of the next section.
* In panel 4, drag the sample slider all the way up and watch the blue curve flatten against the red line it can never touch.

---

## 3 · The two theorems, stated properly

### The unlucky half

> **Theorem (the unlucky cap).** Let $N = pq$ with $p \ne q$ odd primes, and suppose $\operatorname{ord}_p(a) = 2^k u$ and $\operatorname{ord}_q(a) = 2^k v$ with $u, v$ odd — *the same* power of two. Then for **every** exponent $m$ with $N \mid a^{2m}-1$,
> $$N \mid a^m - 1 \quad\text{or}\quad N \mid a^m + 1,$$
> and therefore $\gcd(a^m-1, N) \in \{1, N\}$. No period certificate whatsoever extracts a factor.

<details>
<summary><b>Click to reveal the proof</b></summary>

Since $N \mid a^{2m}-1$, both $p$ and $q$ divide $a^{2m}-1$. Modulo a prime, the only square roots of $1$ are $\pm 1$, so $a^m \equiv \pm 1 \pmod p$ and $a^m \equiv \pm 1 \pmod q$.

The sign modulo $p$ is $+1$ exactly when $\operatorname{ord}_p(a) \mid m$, and similarly modulo $q$. So it suffices to show these two divisibilities are equivalent. Suppose $2^k u \mid m$. Both orders divide $2m$, so $2^k v \mid 2m$, hence $v \mid 2m$; as $v$ is odd, $v \mid m$. Also $2^k \mid m$. Since $2^k$ and the odd number $v$ are coprime, $2^k v \mid m$. The reverse implication is symmetric.

Matching signs means $a^m \equiv 1$ modulo both primes (so modulo $N$, by coprimality) or $a^m \equiv -1$ modulo both (so modulo $N$). In the first case $\gcd(a^m-1,N)=N$; in the second, any common divisor of $a^m-1$ and $N$ divides their difference-with-$a^m+1$, namely $2$, and $N$ is odd, so the gcd is $1$. $\blacksquare$
</details>

Read the quantifier carefully: *for every exponent*. That is why no sample budget can help. Sampling produces exponents; the theorem has already ruled out all of them.

### The lucky half — with an explicit witness

> **Theorem (mixed valuations always split).** If $\operatorname{ord}_p(a) = 2^i u$ and $\operatorname{ord}_q(a) = 2^j v$ with $u,v$ odd and $j < i$, then for $L = \operatorname{lcm}(\operatorname{ord}_p a, \operatorname{ord}_q a)$ the exponent $L/2$ is a valid halved period and
> $$\gcd\!\left(a^{L/2}-1,\ N\right) = q .$$

<details>
<summary><b>Click to reveal the proof</b></summary>

The power of two in an lcm is the larger of the two, so $L = 2^i \operatorname{lcm}(u,v)$ and $L/2 = 2^{i-1}\operatorname{lcm}(u,v)$.

Since $j \le i-1$ and $v \mid \operatorname{lcm}(u,v)$, the order $2^j v$ divides $L/2$: hence $q \mid a^{L/2}-1$. But $2^i u \nmid L/2$, because $L/2$ contains only $2^{i-1}$ and $\operatorname{lcm}(u,v)$ is odd: hence $p \nmid a^{L/2}-1$. A divisor of $pq$ that is divisible by $q$ and not by $p$ is exactly $q$. $\blacksquare$
</details>

Putting the halves together gives the **two-adic splitting criterion**: some certificate splits $N$ $\iff$ $i \ne j$. The decision procedure below is nothing more than this statement, made executable.

{{algorithm:0}}

---

## 4 · How much of the floor is welded?

If nearly every base were unlucky, the algorithm would be in trouble. It is not, and the reason is a clean counting argument.

> **Theorem (density bound).** In a product of two finite cyclic groups, at least one of even order, at most half of all elements have coordinate orders with equal two-adic valuation.

<details>
<summary><b>Click to reveal the counting argument</b></summary>

In a cyclic group of order $n$, the number of elements whose order divides a given divisor $e$ of $n$ is exactly $e$. Taking $e = n/2$ for even $n$: exactly half the group has order dividing $n/2$.

Now halving $n$ lowers its two-adic valuation by one and leaves its odd part alone. So an element has order dividing $n/2$ precisely when the valuation of its order is strictly below $v_2(n)$. Hence:

* the **top** valuation level is the complement of that half — exactly $n/2$ elements;
* every **lower** level sits inside the other half — at most $n/2$ elements;
* levels above $v_2(n)$ are empty.

Every level set therefore holds at most half the group. Fix the first coordinate of a pair; its valuation is some $k$; the second coordinate must land in the level set at $k$, which is at most half of its group. Averaging over the first coordinate gives the bound. $\blacksquare$
</details>

Two consequences, both practical:

* **Re-drawing the base works.** Each fresh base escapes the cap with probability at least $1/2$, so the expected number of draws is at most two and the chance that five draws all fail is under $1/32$. Empirically it is far better: for typical moduli the unlucky density sits near $0.25$.
* **A splitting base always exists, explicitly.** Glue a primitive root modulo $p$ to the residue $1$ modulo $q$ by the Chinese Remainder Theorem. Its orders are $p-1$ (even) and $1$ (odd) — valuations that cannot agree.

The next visualization shows the lattice geometry behind the bound and the two one-dimensional valuation profiles whose product it is.

{{visualization:1}}

And here is the measurement itself, over every unit of a list of semiprimes, together with the resulting re-draw statistics:

{{demo:1}}

---

## 5 · Building numbers to order

To test any of this at scale you need semiprimes whose per-prime orders you control. For a real cryptographic modulus the order of a random base is around $\operatorname{lcm}(p-1,q-1) \sim 2^{30}$ and beyond — hopeless to simulate — and searching at random for small semiprimes with prescribed *simultaneous* orders has a hit rate around $10^{-7}$. So you construct instead of search.

> **Theorem (projection).** In a finite group, if $d$ divides the order $n$ of an element $g$, then $g^{\,n/d}$ has order exactly $d$.
>
> **Corollary.** For every divisor $r$ of $p-1$, the units modulo the prime $p$ contain an element of exact order $r$.

That gives a recipe: pick primes $p, q \equiv 1 \pmod r$; manufacture elements of exact order $d_p, d_q \in \{r, r/2\}$ by projection; glue them with the Chinese Remainder Theorem. With $r = 2u$ and $u$ odd, the two possible orders have valuations $1$ and $0$, so on this population *equal orders* and *equal valuations* coincide, and the dichotomy is visible at a glance.

{{algorithm:1}}

<details>
<summary><b>A note from the laboratory: how the cap was discovered</b></summary>

The first constructed population produced measurement records that were all zero, trial after trial. It looked like a simulator bug. It was not: the generator had been drawing bases with *identical* per-prime orders, which is precisely the permanently unlucky case. The bug report turned into a theorem.

Three further defects were caught and fixed before any claim was recorded: an infinite loop on odd half-orders; an early return on the first certificate, which hid later certificates that would have split; and a hard-coded verdict string, replaced by output computed from the data.
</details>

---

## 6 · The ramp, and the ceiling it climbs toward

Now assemble the cost model. Fix a base and modulus:

* **Unlucky base** — success probability is exactly $0$ at every budget. Forever.
* **Mixed base** — each sample independently yields a usable certificate with probability $p$, so
  $$P(s) = C\left(1 - (1-p)^s\right),$$
  with $C$ the certification ceiling of the sampling stage.

> **Proposition (shape of the ladder).** For $C \ge 0$ and $p \in [0,1]$: failures multiply, $1-P(s+t) = (1-P(s))(1-P(t))$ at unit ceiling; the marginal gain is $C p (1-p)^s$, hence positive and decreasing; small budgets are priced linearly, $P(s) \le C p s$; and $P(s) < C$ for every finite $s$ while $P(s)\to C$.

Average over a population in which a fraction $\mu$ of instances are mixed:

> **Theorem (the ceiling factorizes).** The population success rate increases with the budget to the limit
> $$C_{\text{pop}} = C \times \mu,$$
> the certification rate times the mixed-role fraction, and stays **strictly** below it at every finite budget.

This is the whole moral in one formula. The budget moves you along the ladder; only $\mu$ — that is, re-drawing bases — moves the ladder's top.

{{visualization:0}}

**Measured against theory.** On constructed populations with control parameters $r \in \{210, 310, 434, 510\}$, the single-sample factoring probability rose with the phase-register size as
$$0.018 \;\to\; 0.056 \;\to\; 0.158 \;\to\; 0.181,$$
and at a fixed register size the sample ladder read $0.056, 0.204, 0.471$ for $s = 1, 4, 11$, against the independence prediction $1-(1-0.06)^s = 0.060, 0.219, 0.494$. The population saturated near $0.53$ — the certification rate multiplied by a mixed-role share of about two thirds — and no budget pushed it further.

The outcome taxonomy is worth staring at:

| outcome | share |
|---|---|
| spurious or partial certificate | $0.844$ |
| permanently unlucky base | $0.109$ |
| factor extracted | $0.044$ |
| no certificate produced at all | $0.003$ |

Only three trials in a thousand failed to produce *some* certificate. The classical stage is not busy post-processing good certificates; it is busy **rejecting bad ones**. In this pipeline the bottleneck is the filter, not the device.

---

## 7 · Putting it all together

The end-to-end procedure below is a Las Vegas algorithm: sample, extract, and when the base turns out to be welded shut, draw a new one. The density bound is exactly what makes its expected running time finite.

{{algorithm:2}}

And the full numerical tour — exhaustive verification of the criterion, the cap in action, a constructed population, the independence law, and the measured ramp — is here:

{{demo:0}}

---

## 8 · What to take away

1. **A two-integer comparison decides everything.** Period certificates can factor $N = pq$ with base $a$ exactly when $v_2(\operatorname{ord}_p a) \ne v_2(\operatorname{ord}_q a)$.
2. **Bad luck can be permanent.** When the valuations agree, the failure is a theorem about all exponents, not a probability about one.
3. **The escape is cheap and guaranteed.** At most half of all bases are welded; re-drawing works, and an explicit splitting base always exists.
4. **Samples buy motion, not altitude.** The success curve is $C\mu(1-(1-p)^s)$: the budget moves you along it, the population structure fixes its ceiling.
5. **The general diagnostic.** Whenever a randomized method is applied to a population with structurally dead instances, ask not only "what is the per-sample success probability?" but "what fraction of instances is dead, and what operation resamples the *instance* rather than the *trial*?"

<details>
<summary><b>Open problems, for the reader who wants to push further</b></summary>

* **Exact densities.** The bound of $1/2$ is not tight; the valuation profile of a cyclic group is geometric, so the coincidence probability ought to be a closed-form finite sum in the pair $(v_2(p-1), v_2(q-1))$, reproducing the observed clustering near $0.25$.
* **More than two prime factors.** For $N$ with $\omega$ distinct odd prime factors, the natural conjecture is that a certificate splits $N$ exactly when the multiset of per-prime valuations is non-constant, with unlucky density decaying geometrically in $\omega$.
* **Which certificates split.** The criterion exhibits $L/2$ as a witness; for a sampler returning random multiples of the order, the conditional probability that the returned exponent splits would turn the ceiling $C$ into a computable function of the valuation pair.
* **A cost-optimal re-draw schedule.** With per-shot and per-base costs given, minimize the expected cost to the first factor — diminishing returns plus the density bound should give a closed-form optimum for shots-per-base.
</details>
