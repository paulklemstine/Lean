# One Number, Two-Thirds of the Signal: How Far Can You Predict a Lucky Modulus?

*Twenty-four quick tests of Euler's criterion capture most of what can be known about how "lucky" a number is for the quadratic sieve. The rest is not hiding in better features. It is buried under coin-flip noise.*

---

## A sieve, a modulus, and a lot of luck

Picture a factoring algorithm at work. You hand it a large odd number $N$, the product of two secret primes, and ask it to recover them. The quadratic sieve, one of the classic workhorses of integer factorization, does not attack $N$ head-on. It produces a long stream of auxiliary numbers of the form

$$v = j^2 - N,$$

with $j$ running through integers just above $\sqrt{N}$, and it keeps the ones that are **smooth**: numbers whose prime factors are all at most a fixed bound $B$. Once it has gathered enough smooth values, a bit of linear algebra over the two-element field combines them into a congruence of squares, and a factor of $N$ falls out.

Most of the running time goes into one thing: waiting for smooth values. How long you wait depends on the **smoothness rate**, the fraction of sieve values that turn out to be $B$-smooth. Here is the fact behind this story: *that rate is not the same for every $N$.* Two moduli of exactly the same size can have noticeably different rates. Some numbers are simply luckier.

Where does the luck come from? Think about a small odd prime $p$. The prime $p$ can divide $j^2 - N$ only if $j^2 \equiv N \pmod p$, that is, only if $N$ is a **quadratic residue** modulo $p$ (a perfect square in arithmetic mod $p$). If it is, the congruence has two solutions for $j$, and $p$ divides about $2/p$ of all sieve values. If it is not, $p$ never divides them at all. Every small prime for which $N$ is a residue is a free source of small factors, and each one makes smoothness a little more likely.

So a natural guess: count them.

## The residue dial

Over two centuries ago, Euler gave a fast test for quadratic residues. For an odd prime $p$ and an integer $N$,

$$N^{(p-1)/2} \equiv 1 \pmod p \quad\Longleftrightarrow\quad N \text{ is a nonzero square modulo } p.$$

That is **Euler's criterion**. In the language of the Legendre symbol $\left(\tfrac{N}{p}\right)$, which equals $+1$ for nonzero residues, $-1$ for non-residues and $0$ when $p \mid N$, the test passes exactly when $\left(\tfrac{N}{p}\right) = 1$.

Now run the test for every odd prime up to $100$. There are $24$ of them, from $3$ up to $97$. Count how many tests pass. Call the result the **QR count** of $N$:

$$\mathrm{QR}(N) = \#\left\{\, p \le 100 \text{ odd prime} : N^{(p-1)/2} \equiv 1 \pmod p \,\right\}.$$

It is a whole number between $0$ and $24$, a single reading on what we might call the *residue dial* of $N$. The predictor studied here is about as simple as a predictor can be:

$$\widehat{\text{rate}}(N) = \beta_0 + \beta_1 \cdot \mathrm{QR}(N).$$

One feature and two coefficients, nothing more.

The dial has a clean statistical structure, and it can be worked out exactly. For one prime $p$, exactly $(p-1)/2$ of the $p$ residue classes pass the test. (Zero always fails, because zero is a square but not a *nonzero* one.) So the test for $p$ is not a fair coin. It passes with probability $(p-1)/(2p)$, a little under one half, and its variance is $(p^2-1)/(4p^2)$. More important, by the Chinese Remainder Theorem the residues of $N$ modulo different primes behave like independent coordinates as $N$ runs over a full period. The 24 tests are therefore exactly uncorrelated, and the variance of the count is the plain sum of the 24 individual variances:

$$\text{mean of } \mathrm{QR} = \sum_{p} \frac{p-1}{2p} \approx 11.35, \qquad \text{variance of } \mathrm{QR} = \sum_{p} \frac{p^2-1}{4p^2} \approx 2.44^2 .$$

## How good is good?

In the experiment behind this work, each modulus $N$ in a panel got exactly $60$ sieve values, and each value was scored $1$ if smooth and $0$ if not. The difficulty is measured by the parameter $u = \log v / \log B$, the classical Dickman parameter. Larger $u$ means smoothness is rarer. Fitted on one set of moduli and tested on fresh ones, the one-feature predictor gave:

* at $u = 2.5$: $R^2 = 0.2998$, with calibration slope $1.003$ (predictions neither too bold nor too timid);
* at $u = 3.5$: $R^2 = 0.2246$, with calibration slope $0.896$;
* moved without refitting to larger, 44-bit moduli, it still gave $R^2 \approx 0.23$ and $0.17$, with slopes $0.84$ and $0.79$.

An $R^2$ of $0.30$ does not sound impressive. Seventy percent of the variation is left unexplained. The obvious next move is to add features: weight the primes, add pairs of primes, feed everything into a neural network.

That move is mostly wasted effort, and the reason has nothing to do with number theory. It is pure statistics.

## The coin-flip ceiling

Suppose some modulus $N$ has a true smoothness rate $\theta_N$, say $0.2$. You observe $60$ sieve values. Even if you knew $\theta_N$ exactly, the number of smooth values you see is a binomial random variable, and the observed rate $k/60$ wobbles around $0.2$ with variance $\theta_N(1-\theta_N)/60 \approx 0.0027$. That wobble is pure luck of the draw. It belongs to *those particular sixty values*, not to $N$. No property of $N$, however cleverly extracted, can predict it.

That gives a hard limit. A short calculation, the bias–variance identity for a binomial proportion, makes it exact. For any guess $c$,

$$\mathbb{E}\!\left[\left(\tfrac{k}{n} - c\right)^2\right] = (\theta - c)^2 + \frac{\theta(1-\theta)}{n}.$$

The first term is the part a predictor can shrink. The second is the **sampling floor**, which nothing can touch. Add this up over a panel of moduli and the total variation of the observed rates splits cleanly into *systematic signal* plus *binomial floor*. If the systematic variance across moduli is $V$ and the average per-draw variance is $E$, the best $R^2$ any predictor of $N$ can reach is

$$\text{ceiling}(n) = \frac{V}{V + E/n}.$$

There is a matching theorem that holds sample by sample, with no expectations involved. Arrange the $0/1$ outcomes in a table with one row per modulus and $n$ entries per row. Let $\bar y_N$ be the mean of row $N$. For *any* predictor $f$ that assigns one number $f(N)$ to each modulus, the residual sum of squares splits exactly as

$$\sum_{N}\sum_{i}\bigl(y_{N,i} - f(N)\bigr)^2 \;=\; \underbrace{\sum_N \sum_i \bigl(y_{N,i} - \bar y_N\bigr)^2}_{\text{within-row noise}} \;+\; n \sum_N \bigl(\bar y_N - f(N)\bigr)^2 .$$

The first term does not depend on $f$ at all. It is a floor that every predictor of $N$ must pay in full, and only the row means themselves reach it exactly. For $0/1$ data the floor has a familiar form: it equals $n\sum_N \bar y_N(1-\bar y_N)$, the empirical binomial variance. The second term is the only thing a better predictor can ever reduce, and it measures how far the predictor sits from the row means.

In the experiment, the ceiling at $60$ values per modulus came out around $0.45$ at $u = 2.5$ and around $0.31$ at $u = 3.5$. Compare the predictor with these numbers rather than with $1$:

$$\frac{0.2998}{0.45} \approx 0.666, \qquad \frac{0.2246}{0.31} \approx 0.725 .$$

**The single QR count gets two-thirds to three-quarters of the way to the ceiling.** That is two-thirds of everything any function of $N$ could possibly achieve with this much data, not two-thirds of the total variation.

## Squared correlation, exactly

There is a neat way to see what "fraction of the ceiling" means. Fit the best straight line $\beta_0 + \beta_1 x(N)$ on any single per-modulus feature $x$ by ordinary least squares. Its $R^2$ factors exactly:

$$R^2_{\text{one feature}} \;=\; \text{ceiling} \times \rho^2,$$

where $\rho$ is the correlation, across the panel, between the feature $x(N)$ and the observed per-modulus rates $\bar y_N$. The proof is just "completing the square". As a side effect, the same algebra gives a proof of the Cauchy–Schwarz inequality $\rho^2 \le 1$, so a one-feature line can never overshoot the ceiling.

So "the QR count reaches 66% of the ceiling" says exactly that its squared correlation with the per-modulus rates is about $0.66$. The question "can a better single feature do better?" turns into "which feature correlates best with the rates?", a geometry question about projecting onto a direction.

## The decisive test: is anything left?

The most telling number in the experiment is not $R^2$. It is the ratio

$$\kappa = \frac{\text{residual variance of the predictor}}{\text{pure 60-draw binomial floor}} .$$

If a predictor captured *every* systematic difference between moduli, its residuals would be pure coin-flip noise and $\kappa$ would be $1$. The measured value was **$1.12$ to $1.24$**. The QR count leaves only 12–24% more scatter than the irreducible floor.

One identity ties the pieces together. If the residual is $\kappa$ times the floor $F$, out of a total variation $T$, the predictor attains the fraction

$$\frac{R^2}{\text{ceiling}} = 1 - \frac{(\kappa - 1)F}{T - F}$$

of its ceiling. When the floor is a large share of the total, as it is here, even a $\kappa$ close to $1$ leaves a visible gap to the ceiling. This is the arithmetic behind the slogan: **the headroom lies in more values per $N$, not in more features.** The ceiling formula $V/(V + E/n)$ climbs steadily as $n$ grows and tends to $1$. If the ceiling is $0.45$ with $60$ draws, the same formula predicts about $0.62$ with $120$ draws and about $0.77$ with $240$. Richer features can only pay off once there are more draws per modulus to support them.

## Honest bookkeeping

The experiment came with stated hypotheses, and in the spirit of good science the misses were recorded as misses. Two of them (call them H1 and H2) specified bands for the held-out $R^2$ and calibration. At $u = 3.5$ the results fell outside those bands by $0.025$ and $0.012$, a hair's width but a miss all the same. The third hypothesis, H3, that the residual sits within a small factor of the binomial floor, held clearly.

Running the algebra above against the reported numbers also turned up a small inconsistency. If $R^2$, the ceiling and $\kappa$ are all measured on the same sums of squares, they must satisfy

$$1 - R^2 = \kappa\,(1 - \text{ceiling}).$$

At $u = 3.5$ the numbers fit. With $R^2 = 0.2246$ and ceiling $0.31$, the identity forces $\kappa$ between $1.12$ and $1.13$, inside the reported range. At $u = 2.5$ they fit less well. With $R^2 = 0.2998$ and $\kappa \le 1.24$, the ceiling would have to be below $0.436$, not $0.45$. Either the ceiling and the held-out $R^2$ were computed on different data, or $\kappa$ at $u = 2.5$ is closer to $1.27$. The discrepancy is mild, but it is the sort of thing that exact algebra catches and eyeballing misses.

## What the dial cannot see

There is a sobering coda. The QR count predicts how *productive* a factoring run will be, so it is tempting to think it says something about the *factors*. It says nothing.

The reason is again exact. Fix the residue of $N$ modulo $p$ (any nonzero class $n$). Among all the ways to write $n = x \cdot y$ modulo $p$, exactly $(p-1)/2$ have a first factor $x$ that is a quadratic residue, and exactly $(p-1)/2$ have one that is not. The split is perfectly even. In addition, the Legendre symbol is multiplicative:

$$\left(\frac{PQ}{p}\right) = \left(\frac{P}{p}\right)\left(\frac{Q}{p}\right),$$

so the dial sees only the product of the two factors' characters, never either one alone. A predictor built on the residues of $N$ can tell you that $N$ will be a cooperative modulus for the sieve. It cannot tell you which residue class either secret factor lies in. It estimates the *input statistics of a method*, and it carries zero information about the answer the method is looking for. For anyone worried about cryptographic consequences, this is a reassuring barrier, and it is a theorem, not a hope.

## The broader moral

This story is not really about factoring. It describes any situation where you predict a *per-unit rate* from a handful of noisy trials per unit: conversion rates for each web page, defect rates for each production batch, response rates for each patient, hit rates for each hospital. In all of them:

1. Measure your predictor against the **sampling ceiling**, not against perfection. An $R^2$ of $0.30$ can be excellent.
2. Compare the residual with the **binomial floor**. If the ratio is close to $1$, your feature set is essentially complete for the data you have.
3. If you want more, **collect more trials per unit** before you engineer more features. The ceiling grows with $n$. Your feature set does not raise it.

Twenty-four applications of Euler's 18th-century test, added into one integer, explain two-thirds of everything that sixty sieve values per modulus can reveal. The remaining third is mostly not a pattern waiting to be found. It is noise that more draws per modulus would wash out.
