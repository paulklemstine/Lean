# The Clock That Always Strikes Early

## What a factoring algorithm's stopwatch reveals about the secret life of integers

There is a certain kind of scientific pleasure in being wrong in an interesting way. You write down two guesses before you look at the data, you look at the data, and both guesses turn out to be not merely wrong but *inverted* — the arrow of the effect points the other way. That is what happened here, and the reason it happened turns out to be a small, sharp theorem about the largest prime factor of a random number.

The setting is one of the workhorses of computational number theory: **the elliptic-curve method of factorization**, or ECM. It is the algorithm you reach for when you have a large composite number $N$ and you suspect it has a medium-sized prime factor $p$ hiding inside — say thirty or forty digits — that trial division will never find and that the heavy machinery of the number field sieve is overkill for.

What we studied is not whether ECM works. It does. We studied something stranger: **when, during a run, does it work?** And the answer is a clean piece of mathematics that says the algorithm's moment of success is not distributed across its runtime at all. It is pinned, almost always, to the very beginning.

---

## Stage one, in one paragraph

Pick a bound $B_1$ — a few thousand, a few million, whatever your patience allows. Pick a random elliptic curve modulo $N$ and a point $P$ on it. Now build the enormous integer

$$K(B_1) \;=\; \prod_{p \le B_1} p^{\lfloor \log_p B_1 \rfloor},$$

the product over all primes $p$ up to $B_1$ of the highest power of $p$ that still fits under $B_1$. This is essentially $\mathrm{lcm}(1, 2, \ldots, B_1)$. Then compute $K(B_1) \cdot P$ on the curve.

The magic is this. Behind the scenes, your curve modulo $N$ is secretly a curve modulo each prime factor $p$ of $N$ at once. Each of those has its own group of points, of some order, and the point $P$ has some order $n$ in it. If $n$ happens to divide $K(B_1)$ — that is, if $n$ is **$B_1$-smooth**, built entirely from small primes — then the multiplication kills $P$ modulo $p$ while leaving it alive modulo the other factors. The arithmetic breaks in a very specific way, a modular inverse fails, and the failure hands you $p$ on a plate. Hasse's theorem tells you the group orders wander in a window of width about $4\sqrt{p}$ around $p$, so ECM's success is exactly the probability that a random integer near $p$ is smooth. Different curve, different order, another roll of the dice.

Crucially, you do not build $K(B_1)$ and then multiply once. You **walk the schedule**: prime by prime, in increasing order, multiplying the accumulated scalar by one prime power at a time. Prime $2$, then $3$, then $5$, then $7$, and so on, $\pi(B_1)$ steps in all. And at every step you can ask: has it fired yet?

That question — *at which step of the walk does the curve fire?* — is the subject of this article. Call the answer, rescaled to lie between $0$ and $1$, the **firing index**. A curve that succeeds on the third of a hundred steps has firing index $0.03$; one that succeeds only on the last step has index $1.00$.

---

## Two reasonable guesses, both wrong

Before looking at any data, we wrote down two hypotheses. Both were reasonable. Both are now dead.

The first concerned the *shape* of the firing-index distribution. There is a folk intuition that says: when $B_1$ is generous relative to $p$, so that success is nearly guaranteed, the curve must be grinding through most of the schedule before the accumulated scalar finally contains every prime power the order needs. Success in that regime is *order completion* — you finish the job at the end. So the firing index should bunch up in the **final 20%** of the schedule. And when $B_1$ is stingy, so that genuine smoothness is rare, the successes you do see should be dumb luck — random arithmetic collisions that can strike at any moment — so the firing index should look **uniform**.

The second concerned the *rate* of success at stingy $B_1$. There is a nuisance effect in ECM bookkeeping: even with no smoothness at all, a run of $k$ modular operations has some chance of stumbling into a multiple of $p$ by accident. That chance is $1 - (1 - 1/p)^k$, the **collision baseline**. If the successes observed at small $B_1$ were really collisions in disguise, then as the prime $p$ grows — as you move from $26$-bit to $32$-bit targets at a fixed ratio $B_1/p$ — the observed success rate should slide down toward that baseline.

Here is what the measurements said.

At the ratio $B_1/p = 0.125$, the observed per-cell success rates were $65.0\%$ at bit length $26$ (confidence interval $0.495$–$0.779$) and $62.5\%$ at bit length $32$ (interval $0.470$–$0.758$). The collision baseline, computed honestly, is at most about $32\%$. Not only did the rate fail to slide toward the baseline — it sat roughly twice as high, and a two-proportion test across the two bit lengths returned $p = 0.82$: no drift whatsoever. The second hypothesis died of a flat line.

And at the generous ratio $B_1/p = 0.9$, where the "grind to the end" story should have been at its strongest, the **median firing index was $0.09$**. Nine percent. Out of $55$ recorded successes across the whole experiment, the number that landed in the final $20\%$ of the schedule was **zero**. Under the pre-registered uniform law that outcome has probability $(4/5)^{55} \approx 4.7 \times 10^{-6}$.

The clock does not strike at the end. It strikes almost immediately.

---

## The theorem that explains it

Why? Because the firing moment is not a complicated function of the run. It is one number, and everybody who has ever factored an integer by hand already knows which one.

Write $K(B_1, y)$ for the scalar accumulated after the schedule has consumed every prime up to $y$:

$$K(B_1, y) \;=\; \prod_{p \le y} p^{\lfloor \log_p B_1 \rfloor}.$$

Write $P^{+}(n)$ for the **largest prime factor** of $n$. Then:

> **The Trace Law.** Let $n$ be an order that stage one can reach at all, meaning $n$ divides the full multiplier $K(B_1)$. Then for every schedule position $y$,
> $$n \mid K(B_1, y) \quad \Longleftrightarrow \quad P^{+}(n) \le y.$$

The proof is two lines in each direction, and it is worth seeing because it explains everything that follows. If $n$ divides the partial product, then its largest prime factor divides that partial product too — and every prime dividing $K(B_1,y)$ is one of the schedule primes at most $y$, so $P^{+}(n) \le y$. Conversely, suppose $P^{+}(n) \le y$. Split the full product $K(B_1)$ into the part built from primes $\le y$ and the part built from primes $> y$. Since every prime dividing $n$ is at most $y$, $n$ is coprime to the second part; and since $n$ divides the product of the two, it must divide the first. Done.

The consequence is stark. **The firing threshold is exactly $P^{+}(n)$** — not approximately, not on average, exactly: it is the least $y$ at which the scalar annihilates the point. And so the normalized firing index is

$$\text{index} \;=\; \frac{\pi\big(P^{+}(n)\big)}{\pi(B_1)},$$

where $\pi$ counts primes. Everything about the order $n$ — how large it is, how many prime factors it has, what their multiplicities are — is irrelevant. Only the largest prime factor is visible in the trace.

Now recall a classical fact about integers: **the largest prime factor of a random number is usually much smaller than the number itself.** More than two-thirds of integers below $N$ have their largest prime factor below $N^{1/2}$; the median of $\log P^{+}(n) / \log n$ hovers around $0.62$, and the *prime-counting* rescaling that the trace law imposes compresses the interesting range even further, because there are so many more primes down low than up high. Half of all integers are even; a third are divisible by $3$; only one integer in $97$ is divisible by $97$. So an order whose largest prime factor is one of the last few schedule primes is a rarity by construction.

Sieve the statement and you get a bound. If a curve fires *late* — after schedule position $y$ — then by the trace law its order must be divisible by some prime in the window $(y, B_1]$. Union-bound over those primes and the count of such orders in $(0, M]$ is at most $\sum_{y < p \le B_1} \lfloor M/p \rfloor$: the late tail is controlled by a **reciprocal sum of large primes**, which is small precisely because large primes are sparse and their reciprocals are tiny.

Make it concrete. Take $B_1 = 100$. The schedule has $\pi(100) = 25$ steps. Cut at $y = 67$: the primes beyond the cut are $71, 73, 79, 83, 89, 97$ — the final six of the twenty-five steps, a full $24\%$ of the schedule by step count. What fraction of orders can possibly fire in that window? At most

$$\frac{1}{71} + \frac{1}{73} + \frac{1}{79} + \frac{1}{83} + \frac{1}{89} + \frac{1}{97} \;=\; 0.0740 \;<\; \frac{2}{25} = 0.08.$$

Eight percent, where uniformity demands twenty-four. And the bound is nearly tight: among the $4489$ integers in $(0, 67^2]$, exactly $330$ fire late — a density of $7.35\%$. The final quarter of the schedule carries a *third* of the mass a uniform law assigns it.

Given that, the observed empty tail stops being a scandal and becomes a formality. Under the structural cap, seeing zero late hits out of $55$ has probability at least $(23/25)^{55} \approx 1.0 \times 10^{-2}$ — an unremarkable Tuesday. Under uniformity it has probability $4.7 \times 10^{-6}$. The likelihood ratio exceeds $2000$ in favour of the structural law.

---

## The rival theory, and how it lost

Here is where the story gets genuinely interesting, because there was a competing account, and it was not stupid.

When people worry about collision-contaminated bookkeeping, they are implicitly modelling the point's order not as a random *integer* but as a random *divisor of the multiplier* $K(B_1)$. That is a very different probability distribution, and it is easy to compute exactly what it predicts.

The number of divisors of $K(B_1)$ factors cleanly:

$$\tau\big(K(B_1)\big) \;=\; \tau\big(K(B_1, y)\big) \cdot \prod_{y < p \le B_1} \big(\lfloor \log_p B_1 \rfloor + 1\big).$$

The reason is that the divisors of $K(B_1)$ that fire by position $y$ are — by the trace law again — *exactly* the divisors of the partial product $K(B_1,y)$. Each prime beyond the cut contributes an independent choice of exponent, and multiplies the divisor count by $\lfloor \log_p B_1 \rfloor + 1$.

At $B_1 = 100$, $y = 67$, each of the six late primes appears to the first power in the multiplier, so the factor is $2^6 = 64$. The divisor model therefore predicts that only one divisor in $64$ fires within the first nineteen steps, and that **$63/64 \approx 98\%$ of the mass lands in the final six steps**.

So the two null models make diametrically opposite predictions about the same observable: the integer model caps that window at $8\%$; the divisor model puts $98\%$ there. They differ by more than a factor of twelve — indeed, the divisor model's likelihood for the observed empty tail is $(1/64)^{55} \approx 10^{-100}$, which is not so much refuted as vaporized.

The measurement therefore does real work. It does not merely reject a hypothesis; it *selects a model*. **The order of a point on a random elliptic curve behaves, for the purposes of the firing trace, like a random integer below $B_1$ — not like a random divisor of the stage-one multiplier.** The early-fire signature is the prime-counting compression of a typical largest prime factor, and nothing else.

---

## And it gets worse for uniformity as $B_1$ grows

The $B_1 = 100$ computation is a single data point. The general theorem removes the numerics entirely, and it rests on a beautiful old estimate of Erdős: the product of all primes up to $y$ — the *primorial* — never exceeds $4^{y}$.

Feed that into the late window. The primes beyond the cut $y$ each exceed $y$, so their product is at least $y^{k}$ where $k$ is how many of them there are; and their product divides the primorial of $B_1$, so it is at most $4^{B_1}$. Comparing exponents in base two gives a Chebyshev-flavoured count:

$$\#\{p \text{ prime} : y < p \le B_1\} \cdot \lfloor \log_2 y \rfloor \;\le\; 2 B_1.$$

Combine it with the reciprocal-sum sieve and you get an unconditional density bound: the number of orders in $(0, M]$ that fire after position $y$ is at most

$$M \cdot \frac{2 B_1}{y \, \lfloor \log_2 y \rfloor}.$$

Set the cut at half the stage-one bound, and the density is at most $4 / \lfloor \log_2 y \rfloor$. That tends to zero. **A constant-fraction late tail — the $20\%$ the original hypothesis demanded — is not merely unobserved; it is impossible for all large $B_1$.** At $B_1 = 2^{20}$ with the cut at $2^{19}$ the tail is already capped below $4/19 \approx 21\%$, and at $B_1 = 2^{32}$ below $13\%$, and the ceiling keeps descending like the reciprocal of a logarithm.

Direct computation over uniform orders confirms the trend far beyond where any bound is tight. Taking $B_1 = N$ and letting $n$ range over all integers up to $N$:

| $N$ | schedule steps | median index | final-$20\%$ mass | first-$20\%$ mass |
|---|---|---|---|---|
| $10^3$ | $168$ | $0.083$ | $3.4\%$ | $73.0\%$ |
| $10^4$ | $1229$ | $0.035$ | $2.5\%$ | $81.7\%$ |
| $10^5$ | $9592$ | $0.014$ | $1.9\%$ | $86.3\%$ |
| $10^6$ | $78498$ | $0.006$ | $1.6\%$ | $89.0\%$ |

Uniformity would print $0.500$ in the median column and $20\%$ in both mass columns. Instead nearly nine-tenths of the mass is in the first fifth of the schedule, and the median firing index is heading to zero.

---

## What about the collisions?

The other hypothesis — "it was collisions all along" — deserves a fair hearing, and it gets one from a piece of elementary inequality wrangling.

Bernoulli's inequality gives, for a run of $k$ guarded operations modulo $p$,

$$1 - \left(1 - \frac{1}{p}\right)^{k} \;\le\; \frac{k}{p}.$$

Look hard at the right-hand side. It depends on $k$ and $p$ **only through their ratio**. This is the fatal structural feature: the collision baseline is *scale free*. Two experiments at wildly different bit lengths but the same ratio $k/p$ share the same ceiling exactly. So a collision-dominated account, whatever else it might explain, categorically **cannot predict a decline in success rate as the bit length grows at fixed $B_1/p$** — which was the entire content of the second hypothesis. The hypothesis was not merely false; it was never testable in the way it was posed. The flat measurement ($p = 0.82$ across bit lengths) is what the collision theory itself predicts.

And the ceiling is quantitatively too low anyway. Honest accounting puts the operation count at roughly $2.59 \, B_1$ per curve — not the $1.44 \, B_1$ used in the original registration, a discrepancy we corrected and report both ways. At $B_1/p = 0.125$ that gives $k/p \le 0.324$, so the collision ceiling is at most $32.4\%$ against a measured $62.5\%$. **A gap of about thirty percentage points that collisions cannot fill at any scale.**

Turn the gap into a count by pigeonhole. In a cell of $40$ curves with $25$ successes, at most $\lfloor 0.324 \times 40 \rfloor = 12$ can be collision-driven, so **at least $13$ of them are genuine order-hits**. Collisions are real. They are not the story.

---

## The shape of an honest negative result

This work belongs to a genre that deserves more respect than it gets: the bookkeeping audit that fails to find the fraud it was hunting, and finds a law instead.

The chain of reasoning began with a suspicion. An earlier finding — that ECM exhibits no sudden "destruction wall" as a certain parameter is pushed — was challenged on the grounds that its accounting conflated genuine smoothness hits with random collisions. The natural amendment was: *the low-$B_1$ successes were collision luck, so the no-wall conclusion needs revising.* Two discriminating tests were pre-registered. Both refuted the amendment. The amendment chain terminates; the earlier account stands, unamended.

Along the way there was a bug — a closed-form step counter that miscounted on later chunks of the schedule, because the relevant quantity doubles rather than growing by one less. It was caught by an internal consistency check against a directly traced counter *before any full dataset existed*, fixed, and re-verified. Worth mentioning because the honest reporting of a caught error is part of what makes the rest of the numbers believable. So are the caveats: one class of side-channel successes is censored from the accounting and reported as such; a certain failure mode collapses silently and is inherited from the parent experimental design.

What survives all of that is not a statistical claim at all. It is a theorem: **the firing step of a stage-one elliptic-curve run is the largest prime factor of the point's order, and nothing else** — and therefore the whole rich, complicated question of when the algorithm succeeds during its run collapses to the oldest question in multiplicative number theory, the one Dickman and Golomb asked about the size of the biggest prime in a random integer.

There is a conjecture waiting at the end of this, and it is pretty. Because the trace law turns a *positional* question about an algorithm's ladder into a *reciprocal sum over primes*, and reciprocal sums over primes are governed by Mertens' theorem, the late tail should obey

$$\mathrm{tail}(\tau, B_1) \;=\; \frac{\log\big(1/(1-\tau)\big)}{\log B_1} \cdot \big(1 + o(1)\big)$$

for a cut at the $(1-\tau)$-quantile of the schedule. At $\tau = 0.2$ and $B_1 = 10^6$ that predicts $0.0162$. The computation above measured $0.016$.

Two hypotheses died. What replaced them tells you, to three decimal places, when a factoring algorithm will get lucky — and the answer is: right at the start, because the biggest prime in a random number is almost never big.
