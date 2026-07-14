# The Music of Averages: How Sums Reveal Hidden Growth Laws

## A question about crowds, not individuals

Number theory is full of sequences that jump around wildly. Count the divisors of an integer, the number of ways it can be written as a sum of two squares, or the class number of a quadratic form, and you get a jagged, unpredictable line. Yet mathematicians have learned a beautiful secret: *even when the individual values are chaotic, their averages are serene.* Pile up enough terms and a smooth, universal growth law emerges from the noise.

This article is about the engine that makes those averages predictable. The central discovery is deceptively simple to state. Suppose you have a rule that assigns a size to each whole number, and you form the running total

$$S(X) = \sum_{n \le X} a(n).$$

For an enormous class of natural sequences, this total does not grow in some exotic way. It grows like

$$S(X) \sim C \cdot X^{\alpha} \cdot (\log X)^{k},$$

a **power of $X$ times a power of the logarithm of $X$**. Three numbers — the constant $C$, the exponent $\alpha$, and the log-exponent $k$ — completely describe the long-run behavior. Everything else is a rounding error that fades away.

The symbol $\sim$ ("is asymptotic to") means the ratio of the two sides tends to $1$ as $X$ grows without bound. It does not mean the two sides are ever equal; it means they become indistinguishable in proportion. That is exactly the sense in which a crowd is predictable while its members are not.

## Why a power and a logarithm?

The two exponents come from utterly different places, and part of the pleasure of the subject is watching them appear.

The **power** $\alpha$ measures how fast the terms themselves grow. If $a(n)$ behaves like $n^p$, then adding up the first $X$ of them is like measuring the area under the curve $y = x^p$, which scales as $X^{p+1}$. Summation acts like integration: it raises the exponent by one. This is the origin of the clean law

$$\sum_{n < N} n^{p} \sim \frac{N^{p+1}}{p+1} \qquad (p > 0),$$

which we prove below. Here $\alpha = p+1$ and there is no logarithm at all ($k = 0$).

The **logarithm** $k$ is subtler. It appears when the terms grow so slowly that ordinary powers cannot capture them — the borderline case. The purest example is the average size of a logarithm itself:

$$\sum_{n < N} \log n \sim N \log N.$$

Here the power is trivial ($\alpha = 1$) but a genuine logarithm survives ($k = 1$). This is nothing other than the leading term of Stirling's famous approximation for factorials, since $\sum_{n<N}\log n = \log\big((N-1)!\big)$. Stirling's formula, in this light, is a statement about an *average*.

The real drama is when both effects operate at once. Weight each term by both a power and a logarithm, and the two exponents coexist:

$$\sum_{n < N} n^{p} \log n \sim \frac{N^{p+1}\log N}{p+1} \qquad (p > 0).$$

Now $\alpha = p + 1 > 1$ and $k = 1$ are *both* nontrivial. This single formula is the smallest, cleanest specimen that displays the full target shape $C\,X^{\alpha}(\log X)^k$ with nothing degenerate about it. It is the heart of the story.

## The trick that ties it together: summation is integration

How does one actually prove these laws? The recurring idea is an old and elegant one, sometimes called an Euler–Maclaurin sandwich. A sum is a staircase; an integral is a ramp. If the terms are increasing, each rectangular step of the staircase is trapped between two slices of the ramp. Writing this out for the function $f(x) = x^p$ gives

$$\int_{0}^{N-1} x^{p}\,dx \;\le\; \sum_{n < N} n^{p} \;\le\; \int_{0}^{N} x^{p}\,dx.$$

Both integrals evaluate to something close to $N^{p+1}/(p+1)$, and as $N$ grows the two ends of the sandwich squeeze together in proportion. The sum has nowhere to go but the same limit. The mixed power–log law is proved the same way, using the antiderivative

$$\int x^{p}\log x\,dx = \frac{x^{p+1}\log x}{p+1} - \frac{x^{p+1}}{(p+1)^2},$$

whose leading term is exactly the claimed asymptotic.

## Transferring a law through an average

The most powerful result is not any single formula but a *machine* for producing new ones. It answers the question: if I already know that $f(n)$ and $g(n)$ have the same growth, do their running totals also have the same growth?

The answer is yes, under one natural condition. If $f(n) \sim g(n)$ term by term, if $g$ is eventually positive, and if the totals of $g$ diverge to infinity, then

$$\sum_{n < N} f(n) \;\sim\; \sum_{n < N} g(n).$$

We call this the **Riesz-mean transfer**. It says asymptotic equivalence survives the act of averaging. Its engine room is a version of the classical Stolz–Cesàro theorem tailored to the "little-o" notation: if the discrepancy $h(n)$ is negligible compared to $g(n)$, then the *accumulated* discrepancy is negligible compared to the *accumulated* $g$. Intuitively, a small relative error, summed up, stays a small relative error — provided the reference grows without bound so early wobbles get washed out.

The reward for having this machine is that laws compound. Feed the power law $\sum_{n<N} n^p \sim N^{p+1}/(p+1)$ back into the transfer machine and you obtain a genuine *second-order* average, a sum of sums:

$$\sum_{n < N}\ \sum_{m < n} m^{p} \;\sim\; \frac{N^{p+2}}{(p+1)(p+2)}.$$

Each layer of summation raises the power by one and contributes a new factor to the constant. This is the seed of the theory of *Riesz means* of higher order, the smoothed averages that make delicate arithmetic sums behave.

## Where this points: the arithmetic of shapes

Why build this engine at all? Because the sequences that matter most in number theory are exactly the wild ones whose averages hide these laws. A guiding example is the **Hurwitz class numbers** $H(n)$, which count — with careful weighting — the inequivalent binary quadratic forms of discriminant $-n$. Equivalently, they measure the number of ways a shape can tile the plane up to symmetry. Individually the $H(n)$ are erratic; but weighted sums $\sum_{n \le X} H(n)\,w(n)$, where the weight $w$ comes from the deep world of modular and Maass forms, are conjectured and known to obey precisely the power–logarithm law $C\,X^{\alpha}(\log X)^k$. The exponents encode spectral data — the frequencies, so to speak, at which these arithmetic objects vibrate.

The results assembled here are the analytic backbone of that program. The transfer machine converts a growth law for the raw counts into a growth law for any smoothly weighted average of them. The power, log, and mixed laws supply the model cases against which every finer result is calibrated. And the iterated law shows how smoothing of arbitrary order is built from a single reusable step.

## The takeaway

Three lessons echo through this small theory. First, **summation is a smoothing operation**: it turns jagged sequences into smooth growth curves and, like integration, systematically raises exponents. Second, **the shape of that growth is almost always the same** — a power of $X$ times a power of $\log X$ — so the entire long-run behavior of a complicated sum collapses into three numbers. Third, **growth laws are contagious**: once you know how one sequence behaves, a single transfer principle spreads that knowledge to every average built on top of it.

From counting divisors to counting quadratic forms to reading the spectrum of a Maass form, the same quiet melody plays underneath. Individually, the numbers are noise. Averaged, they sing.
