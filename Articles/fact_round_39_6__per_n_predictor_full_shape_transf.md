# The Dial That Reads a Number's Fortune: Shape, Level, and the Quadratic Sieve

*Why some numbers are easier to factor than others — and why a single integer count, read in the right way, tells you how much easier.*

---

## A machine that eats numbers

Every time a browser opens a secure connection, it leans on a bet: that multiplying two large primes is easy, while recovering them from their product is hard. Much of public-key cryptography rests on that asymmetry, and the people who test it — the ones who try to factor big numbers on purpose — have a toolbox of beautiful algorithms. One of the most elegant is the **quadratic sieve**.

The idea is old and almost childlike. To factor a number $N$, look at the values of the polynomial

$$Q(x) = x^2 - N$$

for $x$ just above $\sqrt{N}$. These values are relatively small, and small numbers are more likely to be *smooth* — to break completely into small primes. Collect enough smooth values, combine them cleverly, and you produce two numbers $a$ and $b$ with $a^2 \equiv b^2 \pmod N$. With a bit of luck, $\gcd(a-b, N)$ is a proper factor. The hard part — the part that eats almost all the computing time — is finding the smooth values. That is done with a *sieve*: for each small prime $p$, you mark every $x$ for which $p$ divides $Q(x)$, and values that collect many marks are the promising ones.

Here is the twist that this article is about. **Not every $N$ is equally easy to sieve.** Two numbers of exactly the same size can have strikingly different "sieve yields" — different fractions of candidates that turn out to be smooth. Practitioners who tune a sieve want to know, before they start, roughly how productive it will be for *this* $N$. They want a dial.

A recent round of experiments proposed such a dial, validated it at three different scales, and found two things that sound like a slogan: **the shape transfers perfectly, but the level tracks each population.** What follows is the story of why that slogan is not just an empirical accident but, to a surprising degree, a theorem.

## The feature: counting friendly primes

The dial is built from a single integer. For each odd prime $p$ up to 100 — there are exactly 24 of them, from 3 to 97 — ask a yes-or-no question about $N$:

> Is $N$ a nonzero perfect square modulo $p$?

There is a fast way to answer it, discovered by Euler: compute $N^{(p-1)/2}$ modulo $p$. If $p$ does not divide $N$ and the answer is $1$, then $N$ is a square mod $p$; otherwise it is not. Call a prime that passes this test *friendly* to $N$. The feature is simply

$$\mathrm{QR}(N) = \#\{\text{odd primes } p \le 100 \text{ that pass Euler's test for } N\},$$

a whole number between $0$ and $24$. ("QR" stands for *quadratic residue*, the classical name for a nonzero square modulo $p$.)

The adopted dial, fitted from data, reads

$$\text{rate}(N) \approx -0.0035 + 0.01156\cdot \mathrm{QR}(N).$$

That is the whole predictor: count friendly primes, multiply, subtract a little. The experiments found that this count correlates with the actual measured sieve yield at about $r \approx 0.50$ at every scale tested (between $0.497$ and $0.521$ at the smoothness setting $u = 2.5$, where $u$ measures how demanding the smoothness requirement is). A correlation of one-half is not destiny, but for a quantity computed from 24 modular exponentiations, it is remarkable.

Why should this count matter at all? That question has an exact answer.

## The shape theorem: a count that is secretly a yield

A sieve works prime by prime. For a fixed prime $p$, the question "does $p$ divide $Q(x) = x^2 - N$?" depends only on $x$ modulo $p$. So in each block of $p$ consecutive values of $x$, the prime $p$ hits a fixed number of them — the number of solutions $r$ in $\{0, 1, \dots, p-1\}$ of

$$r^2 \equiv N \pmod p.$$

Call this number the *root count* of $p$. And here is the classical fact, which turns out to be the heart of the whole matter:

> **Root-Count Law.** For an odd prime $p$, the number of roots of $x^2 \equiv N \pmod p$ in one period is exactly $1 + \left(\frac{N}{p}\right)$, where $\left(\frac{N}{p}\right)$ is the Legendre symbol: $+1$ if $N$ is a nonzero square mod $p$, $-1$ if it is a non-square, and $0$ if $p$ divides $N$.

So a friendly prime contributes **two** roots — the familiar pair $\pm r$ — an unfriendly prime contributes **none**, and a prime that divides $N$ contributes exactly **one** (the root $r = 0$). And Euler's test, the cheap computation behind the feature, is *precisely* the condition that the Legendre symbol equals $+1$; nothing is lost in replacing the symbol with the exponentiation.

Add this up over all 24 primes and you get the first theorem worth putting a name on:

> **Shape Theorem.** For any set $S$ of odd primes and any $N$,
> $$\sum_{p \in S} (\text{root count of } p) \;=\; 2\cdot \mathrm{QR}_S(N) \;+\; \#\{p \in S : p \mid N\}.$$

For any $N$ with no prime factor up to 100 — which includes every RSA-style semiprime of interest — the last term is zero, and the total root mass is *exactly twice* the friendly-prime count. There is no hidden correction, no dependence on how big $N$ is, no fudge. Over any interval of $L$ complete periods, prime $p$ hits exactly $L$ times its root count, so the root mass is literally the number of sieve marks per period, prime by prime.

This is what "the shape transfers" means at its core. The relationship between the feature and the sieve's raw activity is an *identity of arithmetic*, and it is the same identity at every scale. When an experimenter fits a slope at one size of $N$ and carries it to another, they are partly carrying a fact that cannot change.

Of course, raw marks are not the same as smooth values: a sieve rewards primes roughly in proportion to $\log p$, and smoothness depends on large primes the feature never sees. That is why the correlation is $0.5$ and not $1$. But the *mechanism* — why more friendly primes means more yield — is exact.

## The level theorem: what the population decides

If the slope is a fact about arithmetic, what about the intercept, the $-0.0035$? This is where the second half of the slogan comes in: **the level tracks each population.** And again, there is an exact statement hiding behind it.

Take a single odd prime $p$ and let $N$ run through a complete set of remainders $0, 1, \dots, p-1$. How many of them pass Euler's test? Exactly half of the nonzero ones:

> **Half-Pass Law.** In any complete residue system modulo an odd prime $p$, exactly $(p-1)/2$ values of $N$ pass Euler's test.

The proof is a lovely bit of double counting. Every $r$ in $\{0,\dots,p-1\}$ is a root for exactly one $N$ (namely $N \equiv r^2$), so the root counts summed over all $N$ total $p$. But by the Root-Count Law, that sum is also $2\cdot(\text{number of passing }N) + 1$, the $1$ coming from $N \equiv 0$. Solve: $(p-1)/2$ passes.

Now let $N$ range over a whole common period $M$ — any number divisible by all the primes in play. Averaging the feature over that population gives an exact formula:

> **Population Mean Theorem.** If $M$ is a positive multiple of every prime in a set $S$ of odd primes, then the average of $\mathrm{QR}_S(N)$ over $0 \le N < M$ is exactly
> $$\sum_{p \in S} \frac{(p-1)/2}{p}.$$

Each prime contributes a little less than one-half: $\tfrac{1}{3}$ for $p = 3$, $\tfrac{2}{5}$ for $p = 5$, creeping toward $\tfrac12$ as $p$ grows. So the mean is pinned between $|S|/3$ and $|S|/2$. For the 24 odd primes up to 100, the population mean feature lies in $[8, 12)$ — its exact value is about $11.35$ — and because the dial is affine, the population mean of the predicted rate lies in

$$[\,0.08898,\; 0.13522\,).$$

This is the clean separation that the slogan was groping for. **The average level of the feature is a property of the population; the per-$N$ deviation from that average is a property of $N$.** When you change scales — bigger $N$, a different smoothness bound, a different sampling procedure — the population changes, the overall yield changes, and the intercept must move. But the slope that converts "one more friendly prime" into "this much more yield" has a structural reason to stay put.

## The transfer law: why "perfect" means "same slope"

The headline number from the experiment was this: when the slope fitted at one scale was carried over to another, and only the intercept was refitted, the resulting $R^2$ on the target scale was $0.2719$, against the target's own best-possible value, its squared correlation, of $0.2717$. Transfer, in other words, looked perfect.

There is an exact law that says what "perfect" can and cannot mean. Suppose on a target sample you use the predictor $a + b\,x$ with a *transferred* slope $b$, and choose the intercept $a$ to make the prediction pass through the target's means. Let $\hat\beta$ be the target's own least-squares slope, $S_{xx}$ and $S_{yy}$ the centred sums of squares of feature and yield, and $\rho^2$ their squared correlation. Then:

> **Transfer Law.** $$R^2_{\text{transfer}}(b) \;=\; \rho^2 \;-\; (b - \hat\beta)^2\,\frac{S_{xx}}{S_{yy}}.$$

It is a downward parabola in $b$, peaking at exactly $\rho^2$ when $b = \hat\beta$. Three consequences fall out at once:

1. **Refitting the level is always optimal.** For any slope, centering on the target's means beats every other intercept. You lose nothing, ever, by letting the level track the population.
2. **Transfer can never beat correlation.** No affine predictor whatsoever — transferred or not — can have in-sample $R^2$ above $\rho^2$.
3. **Equality means equal slopes.** Transfer $R^2$ equals $\rho^2$ *if and only if* the transferred slope is the target's own slope.

The law also turns vague talk of slopes being "in band" into an exact certificate: the transfer gap is at most $\varepsilon$ precisely when $(b - \hat\beta)^2 \le \varepsilon\, S_{yy}/S_{xx}$. The experiment reported all four tested transfer cells as in-band, and the law says exactly what that buys.

## A friendly critique hidden in the algebra

Consequence 2 has a sharp edge. If transfer $R^2$ can never exceed $\rho^2$ *on the same sample*, then a reported pair like ($0.2719$, $0.2717$) — transfer slightly *above* correlation — is impossible as two in-sample statistics of one target sample. Indeed, anything that rounds to $0.2719$ is at least $0.27185$, anything that rounds to $0.2717$ is at most $0.27175$, and the first would have to be no larger than the second.

That does not mean the result is wrong. It means the two numbers were computed on different samples — for instance, one on a held-out split and one on the full target — and the tiny difference is sampling noise. The honest summary is: *the transfer gap is indistinguishable from zero*, which by the Transfer Law means the transferred slope is indistinguishable from the target's own. That is a strong and clean finding; it just needs both numbers recomputed on one sample to be stated precisely.

The arithmetic offers a second gentle warning. The dial is positive exactly when $\mathrm{QR}(N) \ge 1$ and is never larger than $0.27394$ (its value at $\mathrm{QR} = 24$). But some numbers have *no* friendly primes at all. A concrete one is

$$N = 163{,}520{,}117 = 2027 \times 80671,$$

a product of two primes that happens to be a non-square modulo every odd prime up to 100. Its friendly-prime count is $0$, its total root mass is $0$ — the 24 sieve primes never touch $Q(x)$ — and the dial predicts a rate of $-0.0035$, which is a negative yield. Rates cannot be negative, so in practice the dial must be clipped at the bottom of its range. Such numbers are rare, but they exist, and a calibration tool should know about them.

## How good can any such dial be?

The final piece of the analysis asks a humbler question: if you insist on predicting yield from the friendly-prime count alone, what is the best you could ever do?

Because the count takes only 25 possible values, the data fall into at most 25 groups. Inside each group, the yields scatter around a group average. That scatter — the *pure error* — is a floor that no feature-based predictor can break:

> **Floor Decomposition.** For any rule $g$ that predicts from the feature alone,
> $$\sum_i \bigl(y_i - g(x_i)\bigr)^2 \;=\; \text{(pure error)} \;+\; \sum_i \bigl(m(x_i) - g(x_i)\bigr)^2,$$
> where $m(x)$ is the average yield of the group with feature value $x$.

Hence every feature-only predictor has error at least the pure error, and equality holds exactly for rules that reproduce the group averages. The constant predictor is one such rule, so the pure error is also at most the total spread.

This is what gives meaning to the experiment's "floor attribution" numbers. At $u = 2.5$, the adopted dial's residual was $1.31$ times the floor: there is real structure the straight line is not capturing — curvature in the group means, perhaps, or something the feature does not see. At $u = 3.5$, the ratio was $1.05$: the dial is within five percent of the best any function of this feature could ever do. It has squeezed the feature dry; what remains is noise relative to this feature.

## What the dial is, and is not

Put the pieces together and a picture emerges that is both modest and solid.

- The **shape** — how yield responds to one more friendly prime — rests on an exact identity: friendly primes are exactly the primes that contribute two sieve roots, and the root mass is exactly twice the count. It does not depend on the size of $N$, which is why a slope carries across scales.
- The **level** — the average yield — is set by the population: the mean feature over any complete period is an explicit sum, pinned between a third and a half of the number of primes. Change the population and the level must be refitted, and refitting it is always optimal.
- **Transfer** is governed by a parabola: perfect transfer means equal slopes, and nothing beats the target's own correlation in-sample.
- The **ceiling** for any feature-only predictor is the pure-error floor, and the adopted dial sits close to it at the harder smoothness setting.

The adopted form, $\text{rate}(N) \approx -0.0035 + 0.01156\cdot\mathrm{QR}(N)$, costs two dozen modular exponentiations to evaluate and gives a validated per-$N$ estimate of how generous the sieve will be — clipped at zero, refitted in level for each new population, trusted in slope. It does not threaten the security of anything; it simply lets a factoring engineer know, before spending hours of computation, whether this particular $N$ is a generous one.

There is something pleasing in that. A question from eighteenth-century number theory — *is $N$ a square modulo $p$?* — turns out to be exactly the right question to ask a twenty-first-century factoring machine about its afternoon's work.
