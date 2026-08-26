# Which Way Should You Walk? The Hidden Asymmetry in Searching for a Secret Factor

## A coin-flip that isn't

Suppose someone hands you a large number $N$ and tells you it is the product of two primes of the same size — the shape of number that guards a great deal of the world's encrypted traffic. You want the factors. You have no clever algorithm, only patience, and you decide to search by hand.

Where do you look? Not everywhere. If $N = pq$ with $p \le q$, then $p \le \sqrt{N}$, so you never need to test anything above $\sqrt{N}$. And if the two primes are *balanced* — meaning $q < 2p$, so neither is more than twice the other — then $p^2 \le N < 2p^2$, which pins the small factor into a narrow strip:

$$p \in \left(\sqrt{N/2},\ \sqrt{N}\right].$$

That strip, which we will call the **canonical window**, has length roughly $0.29\sqrt{N}$. It is where the answer lives.

Now the question that this article is about. You have a window and you are going to walk across it one integer at a time. You can start at the bottom, at $\sqrt{N/2}$, and walk *up*. Or you can start at the top, at $\sqrt{N}$, and walk *down*. Both walks are guaranteed to find $p$. Both cost you one "touch" per integer visited. Which walk is cheaper?

Instinct says it should not matter — that the answer is a coin flip, and the choice of direction is bookkeeping. Instinct is wrong. The two directions differ by a definite, computable factor, and which one wins depends on something surprisingly remote from the arithmetic of $N$: it depends on the *habits of the machine that generated the key in the first place*.

This article tells the story of that dependence, and of a specific claim that turned out to be exactly backwards.

## One number decides everything

Write the window as an interval of integers $[a, b]$ with $a = \lceil \sqrt{N/2}\rceil$ and $b = \lfloor \sqrt{N} \rfloor$, and let $d$ be the divisor you are hunting. Walking up costs $d - a + 1$ touches; walking down costs $b - d + 1$. Add them:

$$(d-a+1) + (b-d+1) = (b-a) + 2.$$

The divisor cancels. The two scans *share a fixed budget*: whatever one of them saves, the other spends. This conservation law is the whole reason the problem collapses to a single number.

Define the **tilt** of a key,

$$z = \frac{d-a}{b-a} \in [0,1],$$

the normalised height of the divisor inside its window: $z = 0$ if the factor sits at the very bottom, $z = 1$ if it sits at the very top. Then the upward walk costs $Lz + 1$ touches and the downward walk costs $L(1-z)+1$, where $L = b-a$ is the window length. Averaging over a whole population of keys with mean tilt $\bar z$ gives the exact ratio of total work:

$$S = \frac{L(1-\bar z)+1}{L\bar z + 1},$$

the factor by which the upward scan beats the downward one. For long windows this is very nearly the **tilt-only predictor** $(1-\bar z)/\bar z$; the discrepancy is exactly $(2\bar z - 1)\big/\big(\bar z (L\bar z+1)\big)$, which vanishes at $\bar z = 1/2$ and is never more than $1/(L\bar z^2)$ in absolute value. At the bit lengths used in real cryptography, $L$ is astronomically large and the predictor is exact for all practical purposes.

And so we arrive at the sharpest possible statement of the contest:

> **Inversion Theorem.** On any population of keys sharing a window, scanning downward from $\sqrt{N}$ beats scanning upward from $\sqrt{N/2}$ **if and only if** the population is *top-heavy*, that is, $\bar z > 1/2$.

No probability, no asymptotics, no hedging. One scalar, one threshold. If you can measure — or better, compute — the mean tilt of a family of keys, you know which direction wins and by how much.

## The tilt is not a property of the key. It is a property of the factory.

Here is the fact that turns this from a curiosity into a statement about cryptographic practice. Take a semiprime $N = pq$ with $p \le q$ and let $r = q/p$ be its **prime ratio**. Then the tilt of $p$ inside its window is

$$z(r) = \frac{r^{-1/2} - 2^{-1/2}}{1 - 2^{-1/2}}.$$

The size of $N$ has vanished. Only the ratio survives. A 2048-bit key and a 20-bit key with the same ratio have the same tilt. And $z$ is strictly decreasing, running from $z(1) = 1$ (perfectly balanced keys sit at the *top* of the window) to $z(2) = 0$ (maximally unbalanced keys sit at the bottom).

So the direction of the winning scan is not a property of any individual number. It is a property of the *distribution of ratios* that a key generator emits — its **generator tilt**. Two laboratories running the same factoring code on populations produced by different key generators will get opposite answers, and both will be right.

Setting $z(r) = 1/2$ gives the **tie ratio**, the exact break-even point:

$$r^\star = 24 - 16\sqrt{2} = 1.372583\ldots$$

Below $r^\star$ the population is top-heavy and downward wins; above $r^\star$ it is bottom-heavy and upward wins. Notice where $r^\star$ sits: strictly between $1$ and $2$. That is the first warning shot. "Balanced" — the property $q < 2p$, the property that guarantees the window even contains the factor — is *not* enough to determine the winner. The sign of the effect flips in the middle of the balance band.

## The control pool, and the mirage

Where did the belief in an upward-scan advantage come from? From testing it on the natural laboratory population: semiprimes whose ratio is spread uniformly across the balance band $[1,2]$. For such a pool the mean tilt integrates in closed form,

$$\bar z_{\text{uniform}} = \int_1^2 z(r)\,dr = \sqrt{2} - 1 = 0.414213\ldots,$$

comfortably below $1/2$. The pool is bottom-heavy, upward wins, and the predicted speedup is exactly $\sqrt{2} \approx 1.414$. A simulated pool of $600$ such keys measured $\bar z = 0.4114$ with a $95\%$ interval $[0.3887, 0.4341]$ and a measured speedup of $1.5896 \pm 0.0538$ — the analytic value sits right inside the tilt interval, and the measured speedup exceeds $\sqrt2$ for a reason we can name exactly. When each key has its own window, the total work is governed not by the plain average tilt but by the average *weighted by window length*; and since a larger ratio means a larger $N$ and hence a longer window, while a larger ratio also means a lower tilt, the weighting systematically favours the low-tilt keys. On a ratio-spread pool that pushes the effective tilt down to about $0.386$ and the speedup up to about $1.59$ — precisely what was seen. So far, so encouraging: the upward scan really does win about $40\%$ of the work, and the machinery that measures it is demonstrably sound.

But that pool was manufactured. Nobody's key generator samples a ratio.

## What a real key generator actually does

A deployed generator does something much simpler and much less accommodating. It picks two primes **independently**, each uniformly from the same bit-length window, and multiplies them. It never looks at the ratio. Whatever ratio comes out, comes out.

This model can be solved exactly, and the solution is the heart of the story. Normalise the bit-length window to $[1,2]$ and let $p, q$ be independent and uniform there, conditioned on $p \le q$. What is the law of $r = q/p$?

Start with the area of the region $\{(p,q) \in [1,2]^2 : p \le q \le rp\}$ for $1 \le r \le 2$. Slicing by $p$, the vertical extent above $p$ is $\min(rp, 2) - p$, and the formula for that extent changes at $p = 2/r$. Splitting the integral there and doing two elementary pieces gives a clean closed form:

$$A(r) = \frac{5}{2} - \frac{2}{r} - \frac{r}{2}.$$

Sanity checks: $A(1) = 0$ (no pair has ratio below $1$) and $A(2) = 1/2$ (every ordered pair has ratio at most $2$, and the ordered pairs are half the square). Differentiating in $r$ and dividing by the total mass $1/2$ produces the **ratio density**

$$f(r) = \frac{4}{r^2} - 1, \qquad 1 \le r \le 2,$$

and indeed $\int_1^2 f = 1$: it is a genuine probability density.

Look at its shape. At $r=1$ it takes the value $3$; at $r=2$ it vanishes. It is *heaped against perfect balance*. Independent same-size primes are overwhelmingly likely to come out nearly equal — the median ratio is about $1.22$, and roughly $71\%$ of pairs land below the tie ratio $r^\star$. This is not an artefact of any sampler; it is the geometry of a square cut by a line.

Now integrate the tilt against this density. The integrand expands into powers $r^{-5/2}, r^{-1/2}, r^{-2}$ and a constant, all elementary, and the result is a startlingly tidy closed form:

$$\bar z_{\text{independent}} = \int_1^2 z(r) f(r)\,dr = \frac{9 - 5\sqrt{2}}{3} = 0.642977\ldots$$

That is the punchline. It is **greater than one half**. The deployed generator class is top-heavy — as a theorem, not as a measurement. Real keys put their small factor high in the window, near $\sqrt{N}$, precisely because independent primes of the same size come out nearly equal. And the upward scan, which starts at the far end, has to cross almost the entire window to reach them.

The exact tilt-only speedup is

$$S = \frac{1 - \bar z}{\bar z} = \frac{5\sqrt{2} - 6}{9 - 5\sqrt{2}} = 0.555265\ldots$$

A number below $1$ means the upward scan *loses*. It loses about $44\%$ of the work. The claimed advantage is not merely absent; it is reversed, and reversed by nearly as large a factor as it was ever claimed to be present.

Simulation agrees, which is reassuring but no longer necessary: a pool of $600$ independently generated same-bit-length keys measured $\bar z = 0.6356$ with interval $[0.6150, 0.6562]$ — the exact value $0.642977$ lands inside it — and a measured speedup of $0.5578 \pm 0.0217$, which contains the exact prediction $0.555265$. Every key in that pool was in the window (same bit length forces balance, hence window membership, automatically), so nothing can be blamed on the scan being undefined. The upward scan was always available, always well-defined, and always losing.

## Can a different window save it?

The window multiplier is a free design parameter: instead of $(\sqrt{N/2}, \sqrt{N}]$ one may scan $(\sqrt{N/R}, \sqrt{N}]$ for any $R > 1$, provided the generator guarantees $q < Rp$. Widening the window changes the tilt law to $z_R(r) = (r^{-1/2} - R^{-1/2})/(1 - R^{-1/2})$ and moves the tie ratio to

$$r^\star(R) = \frac{4R}{(1+\sqrt{R})^2}.$$

Two facts about this expression close the door. First, $r^\star(R) > 1$ for *every* $R > 1$: no matter how you choose the window, there is always an interval of near-balanced ratios just above $1$ on which the upward scan loses. Second, $r^\star(R) < 4$ always: the tie point can never be pushed past ratio $4$, so "just widen the window" is capped and cannot outrun a generator whose mass sits near $1$. Since real generators concentrate their ratio mass exactly there, **no window design rescues the ascending scan.**

Meanwhile the artificial pools stay artificial: a ratio-uniform pool on $[1,R]$ has mean tilt exactly $1/(1+\sqrt{R})$, which is below $1/2$ for every $R>1$. Bottom-heaviness is a property of ratio-*spread* populations, and ratio-spread populations are laboratory constructions.

## Where exactly is the boundary?

The two solved cases sit inside one natural family. Suppose a generator's ratio density falls off like a power, $f(r) \propto r^{-\theta}$ on $[1,2]$. At $\theta = 0$ this is the flat laboratory control; as $\theta$ grows the mass piles up against perfect balance, imitating what real generators do. The mean tilt of this family increases steadily with $\theta$ — from $0$ in the limit of extreme spread to $1$ in the limit of extreme concentration — and it crosses one half at one single point. That point turns out to be a clean rational number:

$$\theta^\star = \frac{3}{2}.$$

The verification is two lines. Writing $I(s) = \int_1^2 r^{-s}\,dr$, the mean tilt is $1/2$ exactly when $I(\theta + \tfrac12)/I(\theta) = \tfrac12(1 + 2^{-1/2})$; and at $\theta = 3/2$ we have $I(2) = 1/2$ and $I(3/2) = 2-\sqrt2$, whose quotient is $1/(2(2-\sqrt2)) = (2+\sqrt2)/4$, which is precisely $\tfrac12(1+2^{-1/2})$. So a generator is adversarial to the upward scan exactly when its ratio density is steeper than $r^{-3/2}$ near balance — and the density that real independent sampling produces, which behaves like $4/r^2 - 1$, comfortably is.

## From real numbers to real machines

One might worry that all this lives in the continuum while an actual scan runs over integers, with a ceiling at one end and a floor at the other. The gap is a half step, and a half step is all the argument needs. Define the **margin** of a ratio,

$$m(r) = r^{-1/2} - \tfrac{1}{2}\left(1 + 2^{-1/2}\right),$$

which is positive exactly when $r < r^\star$, i.e. exactly in the top-heavy regime. Then for a key $N = pq$ with ratio $r$ satisfying $\sqrt{N} \ge 1/(2m(r))$, one has, on the *integer* window,

$$\left\lceil \sqrt{N/2} \right\rceil + \left\lfloor \sqrt{N} \right\rfloor < 2p,$$

which is precisely the statement that the downward scan strictly beats the upward one on that key. For a ratio anywhere near the deployed bulk, the threshold is a small constant, so the inequality holds for every key of cryptographic size. And when different keys have different windows — as they do — the per-key advantages simply add: if every key in a pool is top-heavy in its own window, the pool total is decided the same way, and a single strictly top-heavy key suffices to break a tie.

## What survives

Let me be careful about what has and has not been shown, because the honest scope is narrower than the headline and more useful.

What is settled: the direction of the divisor scan is decided by one scalar; that scalar is a property of the key generator, not of the key; its value for uniformly-spread ratios is $\sqrt{2}-1$ and for independent same-size primes is exactly $(9-5\sqrt{2})/3$; the first is bottom-heavy and the second is top-heavy; no choice of window multiplier changes the second verdict.

What is *not* claimed: any of this makes factoring easier. It does not. Both scans are exponentially hopeless on cryptographic key sizes, and reversing a $0.55$ into a $1.8$ is a constant-factor rearrangement of an intractable search. The measured $17\times$ apparent advantage seen on one deliberately narrow, deliberately unbalanced test pool is a pinning artefact: it requires advance knowledge of the ratio band, knowledge that a real attacker facing a bare $N$ does not have. There is no speed prescription here.

There are also limits of transfer. The simulations ran at small bit lengths where exhaustive enumeration is possible; the analytic results are scale-free by construction, but the *empirical* claim that real generators behave like independent same-size sampling relies on the standard heuristics for the distribution of primes, which were assumed rather than verified. If anything, the assumption is conservative: real generators apply extra filters that narrow the ratio band even further toward $1$ — which makes the tilt *more* adversarial, not less.

What is genuinely valuable is the shape of the conclusion. A plausible-sounding algorithmic advantage was measured, then chased to its source, and the source turned out to be the test harness rather than the mathematics. The advantage exists — but only on populations with a ratio spread that no deployed key generator produces, and that none has any reason to produce. Enforcing $q < 2p$, which sounds like exactly the condition you would need, is provably insufficient, because the sign of the effect flips at $24 - 16\sqrt{2}$, strictly inside that band.

That is a small, sharp, complete result: an entire family of hoped-for gains, characterised precisely, and located precisely outside the world.

## The moral

The lesson generalises well beyond factoring. When you benchmark an algorithm on a synthetic population, you are measuring the interaction of two things — the algorithm and the sampler — and the sampler is usually the one you have thought about least. Here the two were entangled so tightly that the algorithm's advantage had the *opposite sign* on synthetic and realistic inputs, and no amount of tuning the algorithm could have detected it. What detected it was doing the integral: writing the population as a probability law, pushing it through the cost model, and reading off a closed form.

The closed forms are $\sqrt{2}-1$ for the laboratory and $(9-5\sqrt{2})/3$ for the world. They sit on opposite sides of one half, and everything else follows.
