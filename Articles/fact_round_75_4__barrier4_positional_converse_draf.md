# The Arithmetic of a Hint

### What a well-placed clue is really worth — and why "no" is often the most valuable answer of all

---

## A needle, a haystack, and an oracle

Imagine a haystack of total size $1$. Somewhere inside it, uniformly at random, sits a needle. You may search by sweeping: examining a region of size $m$ costs you $m$. Sweep the whole haystack and you pay $1$. That is the baseline, and every clever idea in this article is measured against it. If a strategy has expected cost $c$, we call

$$S \;=\; \frac{1}{c}$$

its **speedup**: how many times faster than brute force it is.

Now someone offers you a hint. They have marked off a **block** $B$ occupying a fraction $\mu$ of the haystack, and they hand you an oracle that, when the needle is in $B$, shouts "it's in the block!" — but only with probability $P$. The oracle never lies; it merely sometimes fails to speak.

How much is that hint worth?

This is the question this article answers, and the answers turn out to be much sharper — and much stranger — than one expects. There is a law for the value of the hint. There is a hard ceiling of exactly $4/3$ on an entire *class* of tricks, and no ceiling at all on another. There is a search cost that saturates at exactly $\log_2 W + \tfrac{1}{2}$, half a query above where the naive optimum sits. And at the end, all of it lands on a very old problem: why factoring a large number seems to cost about $\sqrt{N}$, and why no amount of clever sieving changes that exponent by so much as a hair.

---

## The value of silence

Start with the oracle. There are two ways to use it, and the difference between them is the whole first act.

**The wasteful reading.** The oracle fires: you sweep the block, cost $\mu$, done. The oracle is silent: you learn nothing, so you sweep the entire haystack, cost $1$. The oracle fires with probability $(1-\mu)\cdot 0 + \mu P$... let us just say your expected cost works out to

$$c_{\text{fire-or-silent}}(\mu, P) \;=\; 1 - (1-\mu)P .$$

**The certified reading.** But wait. If the oracle is *committed to a policy* — if you and the oracle have agreed in advance that it fires whenever the needle is in the block and it manages to detect it — then silence is not nothing. Silence is *evidence*. When the oracle stays quiet, the needle is much more likely to be outside the block, and in the idealized committed protocol silence is a genuine **certificate**: the needle lies in the complement, of size $1-\mu$. You never re-scan the block at all. Expected cost:

$$c_{\text{cert}}(\mu,P) \;=\; \mu P + (1-P)(1-\mu).$$

And there is a third, clumsier protocol: sweep the block first no matter what, and on a miss sweep everything again. Cost $c_{\text{rescan}}(\mu,P) = \mu + (1-P)$.

Here is the first small miracle. Those three numbers are not merely ordered. They are **equally spaced**:

$$c_{\text{fire-or-silent}} - c_{\text{cert}} \;=\; c_{\text{rescan}} - c_{\text{fire-or-silent}} \;=\; \mu(1-P).$$

The three protocols form an arithmetic progression with common difference $\mu(1-P)$ — which is exactly *the measure of the block times the probability that the oracle stays silent*. Read it out loud: **each non-certifying silence costs you exactly one block-measure.** Every step down the ladder of sophistication throws away the same fixed quantity of information, priced in the currency of haystack.

This settles a question that had been left open in a draft version of the theory, where the fire-or-silent law was taken as the law of the fixed-window oracle. It is not. It is the *middle* of three, and it strictly understates what a committed protocol achieves whenever the block is nonempty and the oracle is imperfect. The certified law supersedes it.

## The ceiling that isn't there — and the one that is

A natural guess: since the best you can hope for is to always land inside the block, the speedup should be capped at $1/\mu$. Sweep a $\mu$-fraction instead of everything; that's a $1/\mu$-fold saving.

The guess is *almost* right, and the way it fails is instructive. If the block is small — precisely, if $\mu \le 1/2$ — then indeed

$$S_{\text{cert}} \;\le\; \frac{1}{\mu},$$

with equality exactly when the oracle is perfect ($P = 1$). But take a *huge* block, say $\mu = 9/10$, and an oracle that never fires at all, $P = 0$. Then silence is guaranteed — and silence certifies that the needle is in the remaining tenth of the haystack. Your cost is $1/10$, your speedup is $10$, and $1/\mu = 10/9$. The "cap" is exceeded ninefold.

The honest statement is symmetric:

$$S_{\text{cert}} \;\le\; \frac{1}{\min(\mu,\,1-\mu)} .$$

A certificate is a certificate whichever side of the partition it points to. The $1/\mu$ form is the small-block special case.

There is a second surprise hiding at the balance point. Put $\mu = 1/2$. Then

$$c_{\text{cert}}(1/2, P) \;=\; \tfrac12 P + (1-P)\tfrac12 \;=\; \tfrac12$$

*for every value of $P$ whatsoever.* At a perfectly balanced block, the oracle's accuracy is **informationally worthless**. Whether it is an infallible seer or a stone that never speaks, you pay $1/2$ and you get a speedup of exactly $2$. All the oracle has done is tell you which half — and a coin does that too, because silence about half the space is exactly as informative as noise about half the space. The degeneracy is invisible in the fire-or-silent law and appears only once you take certification seriously.

Finally: is there any *universal* constant ceiling on what a positional hint can buy? No. Given any bound $C$ you like, take $\mu = 1/(|C|+3)$ and a perfect oracle; the speedup is $|C|+3 > C$. A positional oracle is an unbounded resource. Hold that thought — it is the crux of the last act.

## Which end to start from

One more piece of the fixed-window story, and it has a pleasingly asymmetric answer. If you must sweep, should you sweep the block first or the complement first?

For the certified protocol, **block-first always wins**, unconditionally: the difference in cost is exactly $P(1-\mu) \ge 0$. Starting with the complement means that on the (probability $P$) event that the oracle fires, the complement sweep was pure waste.

For the clumsy re-scanning protocol B, block-first wins **if and only if $\mu \le P$**. This is an exact criterion, not a rule of thumb — and it explains a puzzling pattern in numerical sweeps of the model, where block-first was observed to fail sometimes and every single failing configuration had $P < \mu$. Of course it did: that is precisely the region where the criterion is violated. A representative failure: $\mu = 1/2$, $P = 1/4$, where complement-first costs $3/4$ and block-first costs $5/4$.

---

## Act two: the half-query that never goes away

Change the setting. Now the needle is in an interval — a **window** of width $W$ — and instead of a single yes/no oracle you may ask *adaptive binary queries*: each query costs $1$ and halves the surviving window. When you stop, you scan what's left, and scanning a residual window of width $w$ costs $w/2$ on average (the needle is uniform in it).

Commit to $k$ queries and your expected total is

$$\mathrm{cost}(W,k) \;=\; \frac{W}{2^{k+1}} \;+\; k .$$

This is not a modelling ansatz: it is exactly the value of the honest recursive process "either scan now at $W/2$, or pay $1$, halve, and continue," unrolled $k$ times.

The natural stopping point — the **pin** — is $k = \log_2 W$, where the residual window has width $1$. On a dyadic window $W = 2^m$ the pinned cost is

$$\mathrm{cost}(2^m, m) \;=\; \tfrac12 + m \;=\; \log_2 W + \tfrac12 .$$

That half is the signature of the model, and it is exact — not asymptotic, not approximate — on every dyadic width. It is also precisely the fixed point of the doubling recursion $V(2W) = V(W)+1$ with $V(1) = 1/2$: doubling the window costs exactly one extra query, forever. This is what saturation means here.

### Three different "optimal" numbers of queries

And now the trap. Is the pin the *cheapest* place to stop?

It is not. On a dyadic window $W = 2^m$ the cost curve never drops below $m$ — that is a genuine lower envelope, valid for every $k$ — and the value $m$ is attained at $k = m-1$ **and** at $k = m-2$, both. (At one query short of the pin, the residual window has width $2$, costing $1$ to scan, so the total is $(m-1) + 1 = m$. At two queries short, the residual has width $4$, costing $2$, total $(m-2)+2 = m$. A perfect tie.) The pin sits at $m + \tfrac12$: exactly **half a query above the minimum**, on every dyadic window, forever.

So the argmin offsets are $\{-2,-1\}$, never $0$. And there is a third convention still: the economically optimal stopping point, defined by when the marginal value of a query goes negative in an application-specific accounting, lands about one query beyond the argmin. Three distinct notions of "the right $k$" — the pin $\log_2 W$, the argmin $\log_2 W - 1$, and the economic optimum — differing by small integer offsets and by that stubborn half. Conflate any two and your census of optimal costs shifts by $1$ or $\tfrac12$, which is exactly the size of the effects the theory is trying to measure.

The marginal accounting has its own moral. The *correct* identity is the **net** one:

$$\mathrm{cost}(W,k) - \mathrm{cost}(W,k+1) \;=\; \frac{W}{2^{k+2}} \;-\; 1 .$$

An extra query saves you the halved residual scan $W/2^{k+2}$, but it *costs one query*. A drafted version of the theory omitted the $-1$ — the "gross" form — and it is simply false; it already fails at $W = 4$, $k = 0$, where the true marginal is $1 - 1 = 0$ while the gross form predicts $1$.

Finally, for windows of arbitrary (non-dyadic) width $W \ge 1$, the closed form is a two-sided bracket: no choice of $k$ ever gets below $\log_2 W - \tfrac12$, and some choice always achieves $\log_2 W + \tfrac12$. The saturation formula is correct to within a single half-query, everywhere, with the upper bound exactly attained on dyadic widths.

---

## Act three: two kinds of resource, and why sieving can't save you

Here is the payoff. A realistic search pipeline is a composition: a cheap **filter** $F$ throws away most candidates, and a **positional stage** $R$ then localizes within what survives. Because costs multiply along a pipeline, so do speedups:

$$S(R \circ F) \;=\; S(R)\cdot S(F).$$

The claim — the *SET/COST dichotomy* — is that these two factors are governed by radically different laws.

**The COST class.** A residue filter selects a congruence class of density $\theta$: with probability $\theta$ the target is in the selected class (scan cost $\theta$), otherwise the filter says nothing useful and you scan everything. Cost $1 - \theta(1-\theta)$. And since $\theta(1-\theta) \le 1/4$ always,

$$S(F) \;=\; \frac{1}{1-\theta(1-\theta)} \;\le\; \frac{4}{3},$$

with equality **exactly** at the balanced density $\theta = 1/2$. Four thirds. That is the greatest element of the whole family: not a limit, not a supremum approached but never reached, but an attained maximum, and attained at exactly one point.

Better still, that $4/3$ is not a free-floating constant. Note that $1-\theta(1-\theta)$ is the fire-or-silent law from Act One evaluated at its **uninformative point** $P = \mu = \theta$ — the configuration where the oracle fires exactly as often as the block is big and therefore carries no information beyond the block's own measure. So $4/3$ is the maximum of a one-dimensional *diagonal slice* of the two-parameter cost surface we started with. Two stories, one surface.

**The SET class.** A positional stage partitions the space into $n$ classes of measures $m_1,\dots,m_n$ and certifies which one holds the target; its expected cost is $\sum_i m_i^2$. By Cauchy–Schwarz, $\sum m_i^2 \ge 1/n$, so the speedup is at most $n$ — and if the certificate is $k$ bits, at most $2^k$. Equality holds precisely for the uniform partition; any imbalance strictly costs you speedup (a rigidity statement, proved by the same sum-of-squares algebra). Unlike $4/3$, the number $2^k$ has no constant bound: buy more bits, get more speedup.

**So what about the measurements?** Empirical anchors in this line of work report speedups of $5.19\times$, $6.91\times$, $4.35\times$, $29.1\times$. Every one of these blows through $4/3$. Does that break the cap?

No. Each of them is an exact rational value of the fixed-window law:

$$5.19\times = \tfrac{400}{77}\ \ (\mu=0.05,\,P=0.85), \qquad 6.91\times = \tfrac{200000}{28943}, \qquad 4.35\times = \tfrac{200000}{45986}, \qquad 29.1\times = \tfrac{500000}{17203},$$

and each factors legally as $S = S(R)\cdot \tfrac43$ with the positional factor $S(R) = \tfrac34 S$ comfortably inside its own budget $1/\mu$ (for the first three, $\mu = 1/20$ allows $S(R)$ up to $20$; $\tfrac34 \cdot 5.19 \approx 3.9$). Exceeding $4/3$ is **class-crossing, not cap-breaking**: the measurement is not a residue filter doing something impossible, it is a positional stage doing something ordinary. Indeed no residue filter alone can ever reach even the smallest anchor. The barrier map is internally consistent, and the dichotomy is strict: the residue class is capped at $4/3$ while the positional class exceeds every constant.

### The corner of the hyperbola

Now specialize to the oldest search problem there is. To factor $N$, look for a divisor on the tropical line $X \odot Y = N$ — in ordinary language, the hyperbola $xy = N$ — and note that every nontrivial factorization has a factor in the **corner window** $[1,\sqrt N]$. For a semiprime $N = pq$ with $p<q$ prime, that window contains *exactly one* nontrivial witness, namely $p$ itself: the divisors $d$ of $N$ with $d^2 \le N$, minus the trivial $d=1$, are precisely $\{p\}$.

The corner window has relative measure $1/\sqrt N$. Feed that into the machinery and the conclusion is immediate and unforgiving: any pipeline built from a positional stage costing at least the corner measure, composed with *any* residue filter whatsoever, has speedup at most

$$\frac{4}{3}\sqrt{N}.$$

The residue class buys you a constant factor of four-thirds on top of the positional $\sqrt N$. It cannot touch the exponent. And the certified fixed-window oracle at the corner measure is capped by $\sqrt N$ exactly, attained only by a perfect oracle. All the sieving in the world — all the congruence tricks, all the "throw away the candidates that can't work" cleverness — lives in the COST class, and the COST class has a ceiling of $4/3$.

---

## What we still don't know

Three gaps remain load-bearing, and they are honest ones.

The first asks for a genuine **measure on the stratum**: a quantity $\Delta(\pi, R)$ capturing how much a given ordering $\pi$ of the search space costs relative to the positional stage $R$. Without it, the stratification is qualitative.

The second is an **extremality** question: is descending-from-$\sqrt N$ the best order among all orders a machine can actually compute from $N$? One expects a Siegel-type ineffectivity here — a proof that some better order cannot exist, without ever being able to say which orders are ruled out.

The third is a naming problem that Act Two made unavoidable: pinning down, once and for all, which of the three $k$'s a given statement is about.

And there is a structural conjecture worth stating. The $4/3$ was the maximum of a diagonal slice, determined by an informational constraint ("the oracle is uninformative"). If that is the pattern, then *every* constant in the barrier map should be the extremum of some slice cut out by some informational budget — turning a scattered collection of magic numbers into a single convex-analytic problem on one surface. That would be the difference between a map with landmarks and a map with contour lines.

---

**The shape of the answer.** A hint is worth $1/(\mu P + (1-P)(1-\mu))$. Silence is worth a block-measure per certificate. Adaptivity saturates at $\log_2 W + \frac12$, half a query above the argmin, forever. Congruence tricks are worth at most $4/3$. And the corner of the hyperbola is worth $\sqrt{N}$, no more — which is why factoring is hard, and why it will stay hard until someone finds a resource that is neither a filter nor a position.
