# The Hump That Nobody Owns

### How a tiny bump in a factoring experiment turned out to be a theorem about averages

---

## A bump where there shouldn't be one

Suppose you are trying to factor a large number $N$ — say a 96-bit integer, the kind of thing that would take a laptop a few seconds and a hand calculation several lifetimes. One of the oldest good ideas in the business, going back to Fermat and refined into the modern quadratic sieve, is this: walk $j$ upward from $\lceil\sqrt{N}\rceil$ and look at the values

$$v = j^2 - N.$$

If you can find enough $j$'s for which $v$ factors completely into small primes — *smooth* values, in the trade's language — then linear algebra over $\mathbb{F}_2$ hands you a factorization of $N$. Everything about the running time of such an algorithm comes down to a single question: **how often is $v$ smooth?**

The textbook answer is a beautiful piece of analytic number theory. If you pick an integer $v$ at random of size roughly $x$, the probability that all of its prime factors are below a bound $B$ is asymptotically $\rho(u)$, where $u = \log v / \log B$ and $\rho$ is the *Dickman function* — the unique continuous solution of the delay differential equation

$$u\,\rho'(u) = -\rho(u-1), \qquad \rho(u) = 1 \text{ for } 0 \le u \le 1.$$

On the first interesting stretch, $1 \le u \le 2$, this has the clean closed form $\rho(u) = 1 - \log u$. Beyond that it decays roughly like $u^{-u}$: smoothness becomes precipitously rare.

So one fits the Dickman curve to the observed smoothness rate of $v = j^2 - N$ and expects the residual to be noise. In a large computational experiment — some 9,594 smooth hits harvested against half a million controls, spread across 128 different 96-bit moduli — the residual was **not** noise. Over the range $t \in [0.45, 0.85]$ of the rescaled Dickman argument there sat a hump of log-amplitude

$$A = 0.1163 \pm 0.0360,$$

a bit over three standard deviations away from zero. A control experiment — the same machinery run against random integers of matched size, with no $j^2 - N$ structure — produced $0.0269 \pm 0.0109$: statistically nothing. The hump was real, and it belonged to the arithmetic of $j^2 - N$.

## Hunting the carrier — and coming up empty

The natural next move is to find the culprit. Statisticians call this looking for a *carrier*: a single simple feature of each hit that, once you condition on it, makes the anomaly evaporate. The obvious candidates were the small-prime divisibility flags. Is $v$ even? Divisible by 3? By 5? By 7? Does it have many small prime factors? Is it sharing a factor with $N$?

Each candidate was tested against a pre-registered bar: to be declared the carrier, conditioning on it had to remove at least 60% of the hump and leave every stratum statistically quiet. The result was the flattest possible failure. **Every single candidate removed exactly 0%.** Parity left both strata at $z = 3.51$ and $4.16$; divisibility by 3 left $4.36$ and $2.38$; by 5, $4.56$ and $1.84$; by 7, $3.91$ and $2.44$. Splitting hits into terciles by their number of small prime factors left all three terciles loud. The shared-factor test could not even be run: at 96 bits the prime factors of $N$ are astronomically larger than any $j$ in the window, so the stratum was structurally empty.

And yet there was a clue. Conditioning on divisibility *did* something — it consistently absorbed 45–60% of the amplitude in the yes-stratum, while parity and the factor-count statistic absorbed none. The excess wasn't hiding in one place. It was smeared across the whole small-prime divisibility structure of $v$.

This article is about why that outcome was not bad luck. It was **forced**. Once you write down the arithmetic honestly, the hump cannot have a single carrier — and the same arithmetic tells you exactly how big the hump should be.

## The one-line reason: squares are not random

Here is where the naive baseline lies to you. It says: a small prime $p$ divides a random integer with probability $1/p$. But $v = j^2 - N$ is not a random integer; it's a very structured one. For an odd prime $p$,

$$p \mid j^2 - N \iff j^2 \equiv N \pmod p,$$

and whether that congruence has solutions depends entirely on whether $N$ is a *quadratic residue* modulo $p$. Write $X_p(N)$ for the number of residues $j \bmod p$ solving it. Then

$$X_p(N) = \begin{cases} 2 & \text{if } N \text{ is a nonzero square mod } p,\\ 0 & \text{if } N \text{ is a non-residue mod } p,\\ 1 & \text{if } p \mid N. \end{cases}$$

Compactly, $X_p(N) = \chi_p(N) + 1$ where $\chi_p$ is the Legendre symbol. So the true density with which $p$ divides the sieve values is not $1/p$; it is $X_p(N)/p$, which for a fixed $N$ is either $2/p$ or $0$ — a coin already flipped, once and for all, when $N$ was chosen.

Now the crucial bookkeeping fact. Sum $X_p(N)$ over all $N$ modulo $p$: exactly half the nonzero residues are squares, contributing 2 each, half are non-residues contributing 0, and $N \equiv 0$ contributes 1. The total is exactly $p$, so the average of $X_p$ is exactly $1$. The naive rate $1/p$ is **right on average and wrong for every individual $N$**.

That is the whole story in miniature, and it generalizes past primes with no effort at all. For *any* modulus $m$, counting pairs $(j, N)$ with $j^2 \equiv N \pmod m$ two ways — group them by $j$, or group them by $N$ — gives

$$\sum_{N \bmod m} \#\{ j \bmod m : m \mid j^2 - N \} = m.$$

Mean preservation holds at every modulus. Primality never enters; it's just fibre counting.

## Jensen does the rest

Mean preservation plus one more ingredient produces the hump, and the ingredient is convexity.

Smoothness is a *multiplicative* quantity: the chance that $v$ is smooth goes up when $v$ has many small prime divisors, and the natural proxy is a product $\prod_p c^{X_p(N)}$ with a weight $c$ per divisibility hit. Any such functional is convex in the divisibility counts, and Jensen's inequality says a convex functional of a spread-out random variable exceeds the functional at the mean:

$$\frac{1}{m}\sum_{N} G\big(X_m(N)\big) \; \ge \; G(1) \quad \text{for every convex } G.$$

The right-hand side is precisely the naive baseline — it evaluates the smoothness functional at the naive rate. The left-hand side is the truth. **The truth is always above the baseline.** Moreover, whenever $m \ge 3$ the inequality is strict for strictly convex $G$, because the divisibility rate is genuinely non-constant: squaring folds $x$ and $-x$ together, so some target modulo $m$ has no square roots at all and the distribution can never be a point mass.

For odd primes one can go further and compute the excess exactly rather than merely bound it. Every functional of the root count collapses onto three values, weighted by the residue split:

$$\sum_{N \bmod p} g\big(X_p(N)\big) = g(1) + \frac{p-1}{2}\,\big(g(2) + g(0)\big).$$

Specialising to $g(x) = c^x$ gives the identity that carries the whole analysis:

$$\sum_{N \bmod p} c^{X_p(N)} = \underbrace{p\,c}_{\text{naive baseline}} \; + \; \underbrace{\frac{(p-1)(c-1)^2}{2}}_{\text{mixture excess}}.$$

Look at the shape of that excess. It is **quadratic** in $c - 1$. It is a *variance* effect, not a shift of the mean — which is exactly what mean preservation demanded. Equivalently, in relative terms, the excess factor for the prime $q$ is

$$E_q(c) = 1 + \Big(1 - \tfrac1q\Big)\frac{(c-1)^2}{2c}.$$

And there is the elegant twin of the mean identity: the deviations satisfy $\sum_N (X_p(N)-1)^2 = p - 1$ exactly, the maximum possible over-dispersion for a mean-one count taking values in $\{0,1,2\}$.

## Why no prime can be the carrier

Now the punchline. Because the primes act more or less independently (Chinese remainder theorem), the total log-amplitude of the hump is a sum of per-prime contributions,

$$A = \sum_{i=1}^{k} \log E_{q_i}(c), \qquad \log E_q(c) = \log\Big(1 + \big(1 - \tfrac1q\big) X\Big), \quad X = \frac{(c-1)^2}{2c}.$$

The astonishing thing is how *uniform* those contributions are. The shape factor $X$ is the same for every prime; the only prime-dependence is the tiny factor $1 - 1/q$, which for any odd prime lies between $2/3$ (at $q=3$) and $1$. Since $\log(1+\cdot)$ is concave and vanishes at zero, this squeezes every prime's contribution into a factor $3/2$ of every other's. No prime is an outlier. Hence, in a mixture with $k$ primes, each individual prime's share of the total amplitude satisfies

$$\frac{\log E_{q_j}(c)}{A} \;\le\; \frac{3}{2k}.$$

With $k \ge 3$ small primes in play, the best any single prime can do is 50% — already below the pre-registered 60% bar. With $k \ge 5$, no single prime reaches 30%. The experiment's uniform "0% removed" table was not a measurement failure; it was the visible face of a structural theorem. **The per-hit binary covariate family is provably incapable of carrying this feature.** And the conclusion survives conditioning: after removing any single prime, at least half the amplitude remains, and what remains is still a genuine, positive hump.

Run the logic backwards and you get something more useful than a negative result: a *measuring instrument*. If the excess is spread evenly over $k$ primes, then knowing the total amplitude $A$ tells you roughly how many primes are involved. Precisely,

$$\frac{A}{X} \;\le\; k \;\le\; \frac{3}{2}\cdot\frac{A}{\log(1+X)}.$$

The amplitude brackets the number of carrier primes. A tomography of the sieve from a single fitted bump.

## Reading the amplitude as a spread

There is one more dictionary to write down, and it is the piece that turns the qualitative story into a number.

Everything above says the true smoothness rate is a *mixture*: some values of $v$ effectively behave as if their Dickman argument were $u$, and others as if it were slightly smaller, because they carry extra small prime factors and are therefore easier to smooth. Model that crudely as a symmetric two-point mixture — argument $u$ with probability $\tfrac12$, argument $u - \delta$ with probability $\tfrac12$ — and compare it against the exact Dickman curve evaluated at the *mean* argument $u - \delta/2$. That comparison is exactly what fitting an exact Dickman baseline to mixed data does, and on the first branch $\rho(u) = 1 - \log u$ the resulting gap can be computed in closed form:

$$\mathrm{Hump}(u,\delta) \;=\; \frac{\rho(u) + \rho(u-\delta)}{2} - \rho\!\left(u - \frac{\delta}{2}\right) \;=\; \frac{1}{2}\log\!\left(1 + \frac{\delta^2}{4u(u-\delta)}\right).$$

Three things about this formula deserve a moment. It vanishes when $\delta = 0$: no spread, no hump, as it must. It is strictly positive for every nonzero spread — the convexity of $\rho$ again, guaranteeing that a mixture always sits above the pointwise baseline. And it is strictly increasing in $\delta$ on the whole admissible range $0 \le \delta < u$: bigger spread, bigger hump, monotonically, with no ambiguity.

Monotone means invertible, and this one inverts *exactly*. Given a measured amplitude $A > 0$, set $s = e^{2A} - 1$; then the spread is

$$\delta(u, A) \;=\; 2u\left(\sqrt{s^2 + s} - s\right),$$

and this always lands strictly inside $(0, u)$ and reproduces $A$ on the nose. Better still, the relative spread $\delta/u$ depends on $A$ alone: the calibration is scale-free. Whatever the size regime of the sieve, a hump of a given amplitude means the same fractional spread in the effective Dickman argument.

So the measured $A = 0.1163$ is not just a bump. It is a readout. It says: the population of sieve values splits, in effect, into regimes whose Dickman arguments differ by a definite, computable fraction — and combined with the counting bracket above, it tells you how many small primes are conspiring to produce that split.

## What it means, and what it does not

It is worth being precise about the scope of the claim. Nothing here says the quadratic sieve is faster or slower than we thought. What it says is that the *baseline model* was mis-specified in a specific, correctable way: modelling the smoothness of $j^2 - N$ by a pointwise Dickman value silently assumes each small prime divides at its average rate, when in truth each prime has already made a binary decision — residue or non-residue — before the sieve begins. Averaging over $N$ hides the decision; conditioning on $N$ reveals it; and convexity guarantees the hidden structure always pushes the smoothness rate *up*, never down. The right baseline is a mixture over the residue classes of $N$ modulo the small primes, and the mixture's excess is exactly quantified above.

The negative result is arguably the more valuable half. There is a temptation, whenever an anomaly appears in a large computational experiment, to keep testing binary features until one of them "explains" it. Here we can prove in advance that the entire family of per-hit binary features is a dead end, because the effect is second-order — a variance effect distributed nearly uniformly over many primes, with a rigorous ceiling of $3/(2k)$ on any single one's share. That closes a search space rather than merely failing to search it.

And the mechanism is remarkably robust to the details. It used only two facts about $j^2 - N$: the root count has mean one over $N$, and it is not constant. Both survive if you replace $j^2$ by any sieve polynomial, or a prime modulus by a prime power, or a composite. Whatever the sieve, if the divisibility rate varies with the target while preserving its mean, the smoothness rate beats the naive baseline — and by an amount you can now read off, invert, and use.

The hump is real. Nobody owns it. That, it turns out, is the theorem.
