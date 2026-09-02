# The Ruler Problem: Why a Measurement Can Only Ever Be a Rounding

## A knee that moved

Suppose you are tuning a large language model that must read a long document. At every step the model spreads its attention across the words it has already seen, assigning each one a weight. Most of that weight piles up on a handful of positions. So a natural engineering question arises: **how many of the highest-weighted positions do you actually have to keep** before the model's behaviour is indistinguishable from keeping them all?

Fix a target — say you want to retain $98\%$ of the total attention mass. Sort the weights in decreasing order, and let $f(k)$ be the fraction of the mass captured by the top $k$ of them. The function $f$ climbs from near zero to $1$, and it climbs steeply at first and then flattens: the classic "knee". The number you want is

$$k^\ast \;=\; \min\{\, k : f(k) \ge 0.98 \,\}.$$

That single integer is the whole ballgame. It is the size of the cache you ship. Halve it and you halve your memory bill.

Here is the awkward part. In one series of measurements on a half-billion-parameter model at a context length of $1024$ tokens, the answer came out as $32$. Later, the same model, the same corpus, the same target, the same everything — and the answer came out as $20$. Nothing about the model had changed. Nothing about the text had changed. What changed was the **ruler**.

The first measurement swept the budget over $4, 8, 16, 32, 64, \dots$ — doubling each time, because doubling is what one does. The second swept over $4, 8, 12, 20, 24$ — a finer, evenly spaced set of marks. And the answer moved.

This article is about the mathematics of that movement. It turns out that the discrepancy is not noise, not corpus sensitivity, not a fluke of the model. It is a theorem. Once you set it down properly, the entire phenomenon becomes a statement about divisibility and binary digits — elementary number theory, of the kind you could explain to a bright teenager, controlling a decision about gigabytes of GPU memory.

## Sampling a staircase

Strip away the machine learning. What you have is a nondecreasing function $f : \mathbb{N} \to \mathbb{R}$, a threshold $\tau$, and a true crossing point $k^\ast$, the least input at which $f$ reaches $\tau$. You do not get to see $f$. You get to evaluate it at a set $G \subseteq \mathbb{N}$ of your own choosing — the **sweep grid** — and you report the smallest grid point at which the threshold is met.

Call that reported value the *measurement*. And define, purely arithmetically, the **grid reading** of an integer $k$:

$$\operatorname{read}_G(k) \;=\; \min\{\, g \in G : g \ge k \,\},$$

the first mark on your ruler at or beyond $k$. (We require $G$ to be unbounded, so this always exists.)

The first theorem says these two things are the same object.

> **Measurement Theorem.** Let $f$ be nondecreasing and suppose the threshold $\tau$ is met somewhere. Then the knee measured by sweeping over $G$ is exactly the grid reading of the true knee:
> $$\min\{\, g \in G : f(g) \ge \tau \,\} \;=\; \operatorname{read}_G\!\left(k^\ast\right).$$

The proof is three lines: because $f$ is nondecreasing, a grid point clears the threshold precisely when it lies at or beyond $k^\ast$, so the two sets whose minima we are taking are literally the same set.

Three lines, but the consequence is a change of worldview. **A grid measurement is never wrong by accident.** It is not an estimate of the truth with some error attached. It is a *deterministic function* of the truth — namely rounding up to the nearest available mark. Every discrepancy between two sweeps is therefore fully explained by arithmetic, before a single word is said about experimental noise.

And the reading is exact — reports the truth on the nose — if and only if $k^\ast$ happens to lie on your grid.

## The ruler is a closure operator

The reading operator has a shape that mathematicians recognise instantly. It is *inflationary* ($k \le \operatorname{read}_G(k)$: a sweep never under-reports), *monotone* (bigger truths give bigger readings), and *idempotent* ($\operatorname{read}_G(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$: re-reading a reported number changes nothing). Its fixed points are exactly the grid points. In short, it is a **closure operator on the natural numbers whose closed sets are the grid**.

That is not just tidy vocabulary; it is a rigidity statement, and the second theorem makes it sharp.

> **Uniqueness of the Read-Out.** Suppose $M : \mathbb{N} \to \mathbb{N}$ is any map that is inflationary, monotone, idempotent, and satisfies $M(k) = k$ exactly when $k \in G$. Then $M = \operatorname{read}_G$.

Read that as an impossibility result. Anyone proposing a cleverer way to extract the true knee from a grid sweep — some interpolation, some fitting procedure — must give up one of those four properties. If your read-out never under-reports, respects order, is stable under repetition, and is honest exactly on the marks you actually measured, then it *is* rounding up. There is nothing else it could be. Extra information has to come from assumptions about the shape of $f$, not from cleverness about the numbers.

The proof is a two-way squeeze: $M(k)$ is a fixed point of $M$ lying at or above $k$, hence at or above the least grid point above $k$; and monotonicity plus fixedness at $\operatorname{read}_G(k)$ pushes $M(k)$ back down.

## Doubling grids and binary digits

Now specialise. Two families of ruler are in play.

The **arithmetic grid** of step $d$ has marks at every multiple of $d$. Its reading is exact at $k$ if and only if $d \mid k$. For the step-$4$ grid this is a statement about $2$-adic valuation: the sweep resolves $k$ exactly when $k$ has at least two trailing zeros in binary.

The **doubling grid** has marks at the powers of two. Its reading is
$$\operatorname{read}_{\text{dyad}}(k) \;=\; 2^{\lceil \log_2 k\rceil},$$
the least power of two at or above $k$. And exactness has a beautiful characterisation:

> **Digit-Sum Criterion.** A doubling sweep reports the true knee $k > 0$ exactly when the binary expansion of $k$ has a single one — that is, when the base-two digit sum of $k$ equals $1$.

So the fate of a measurement is decided by the *binary weight* of a number nobody has seen. Write out the three budgets in the story: $16 = 10000_2$ has weight $1$; $20 = 10100_2$ has weight $2$; $24 = 11000_2$ has weight $2$. A doubling sweep reports $16$ correctly and *cannot* report $20$ or $24$ correctly, no matter how carefully the experiment is run.

Where do they go instead? If $2^e < k \le 2^{e+1}$, the doubling sweep reports $2^{e+1}$, overstating the true budget by $2^{e+1} - k$. Since $16 < 20 \le 32$ and $16 < 24 \le 32$:

$$\operatorname{read}_{\text{dyad}}(16) = 16, \qquad \operatorname{read}_{\text{dyad}}(20) = 32, \qquad \operatorname{read}_{\text{dyad}}(24) = 32.$$

The overstatements are $12$ keys and $8$ keys respectively. And the original mystery evaporates: the coarse sweep's answer of $32$ was not a different measurement of the world. It was the *same* underlying truth, rounded up by a coarser ruler.

## The collapse of a chain

There is a second, subtler casualty. Distinct truths inside a single grid gap are reported identically. Formally: if $k \le k'$ and $k' \le \operatorname{read}_G(k)$, then $\operatorname{read}_G(k) = \operatorname{read}_G(k')$. For the doubling grid this says something memorable:

> **Octave Collapse.** No doubling sweep can distinguish two knees lying in the same octave: if $2^e < k \le k' \le 2^{e+1}$, then both are reported as $2^{e+1}$.

The knee budgets found at context lengths $512$, $1024$, $2048$ form the chain $16 < 20 < 24$. Its image under a doubling sweep is $16, 32, 32$. The strict increase from $1024$ to $2048$ *cannot survive* the coarse ruler — it is squeezed out by counting, not by the model's behaviour. A colleague reporting "$32$ at $2048$, and $32$ again on a second corpus" was not detecting corpus-independence; they were watching two different truths land in the same bin.

Comfortingly, the error runs only one way. A strict increase in the *readings* forces a strict increase in the truths: coarsening destroys resolution, but it never invents it. Whatever a coarse sweep says has genuinely separated, has genuinely separated.

## What five numbers really tell you

Now the honest part, and the most interesting mathematics in the story.

The fine sweep produced this table:

| $k$ | $4$ | $8$ | $12$ | $20$ | $24$ |
|---|---|---|---|---|---|
| retained | $0.8940$ | $0.9520$ | $0.9662$ | $0.9803$ | $0.9851$ |

against the gate $0.98$. The verdict announced was: the knee is $20$, and it lands exactly on the fine grid.

Half of that is a theorem. Call a nondecreasing $f$ *table-matching* if it reproduces those five values. Then:

> **Forced Reading.** Every table-matching profile yields sweep reading $20$: the least swept budget clearing the gate is $20$, for all of them.

That is genuinely robust — the reading is not an artifact of how the harness interpolates, because it does not depend on the profile at all beyond the five measured points. But the other half is where the data runs out:

> **Bracket Theorem.** Every table-matching profile satisfies $12 < k^\ast \le 20$, and nothing more can be extracted.

> **Tightness.** For *every* integer $t$ with $12 < t \le 20$ there is a nondecreasing profile reproducing all five measured values whose true knee is exactly $t$.

The witnesses are explicit staircases: hold the value at $0.9662$ until $t$, then jump to $0.9803$. Such a profile hits every measured point correctly and crosses the gate precisely at $t$.

Why does that matter? Because **the fine grid $\{4, 8, 12, 20, 24\}$ has a hole at $16$.** There is no swept point strictly between $12$ and $20$. So $k^\ast = 16$ and $k^\ast = 20$ are *both* consistent with the entire table:

> **Underdetermination.** There are two nondecreasing profiles reproducing the whole table — hence giving the identical sweep reading $20$ — whose true knees are $16$ and $20$.

Equivalently, in rounding language: the step-$4$ rounding of the true knee is either $16$ or $20$, and it is $20$ precisely when $k^\ast > 16$ — which is exactly the fact the sweep did not test.

So what survives? The deployment-facing claim survives completely: **$20$ keys suffice** at context $1024$, and $12$ do not. That is what you ship. What does *not* survive is the sharper narrative claim that the chain $16 < 20 < 24$ is strictly increasing, because the $1024$ cell may well be $16$ too. Certifying strict monotonicity requires running the one cell the grid skipped. That is a cheap, concrete, decisive experiment — and identifying it is precisely the value of doing the arithmetic carefully.

## How much can a ruler see at all?

Step back and ask a design question: given a window $[1, N]$ of possible knees, how many of them can a given sweep resolve exactly?

A step-$d$ arithmetic grid resolves exactly $\lfloor N/d \rfloor$ of them — a positive fraction $1/d$ of the window. A doubling grid resolves at most $\log_2 N + 1$ — a vanishing fraction. From $N = 32$ upward the step-$4$ grid strictly beats the doubling grid, and the gap grows exponentially: at $N = 2^{j+2}$ it is $2^j$ against roughly $j + 3$.

Sharper still is an *information* bound. Over all possible true knees in $[1, N]$, a doubling sweep can return at most $\lceil \log_2 N\rceil + 1$ distinct verdicts, full stop. So any chain of more than that many knees must contain a repeated reported value. **Apparent flatness in a coarse chain can be forced by pure counting, before any modelling assumption is made.** If you report a nine-cell chain from a doubling sweep over $[1, 64]$, at least two of your plateaus are artifacts, guaranteed.

Which sweeps resolve a given knee $k$? Exactly the arithmetic grids whose step divides $k$. So the "resolution power" of a budget — the number of arithmetic sweeps that see it exactly — is the classical divisor-counting function $\tau(k)$. Along our chain: $\tau(16) = 5$, $\tau(20) = 6$, $\tau(24) = 8$. Tempting to conclude that bigger budgets are easier to resolve; but $\tau$ is famously erratic, and the very next fine-grid cell breaks the pattern: $\tau(28) = 6 < 8 = \tau(24)$. Moving to a finer grid does not monotonically buy resolution.

Finally, the design principle that closes the loop:

> **The GCD Principle.** An arithmetic sweep of step $d$ resolves every member of a finite chain $K$ of knees if and only if $d$ divides $\gcd K$. Hence the coarsest arithmetic sweep that sees a whole chain has step exactly $\gcd K$.

For the chain $\{16, 20, 24\}$, $\gcd = 4$. The step-$4$ grid is therefore not a lucky guess but the *unique coarsest* arithmetic ruler capable of resolving all three cells; every coarser arithmetic sweep must misread at least one. Grid design has become an arithmetic optimisation problem.

## One mechanism, not three coincidences

The last piece is a family resemblance. An earlier round in this line of work reported a knee at $112$ under a fine sweep, which a doubling sweep had read as $128$. Is that the same phenomenon as $20 \mapsto 32$?

Yes, and provably so. Consider the "binary staircase" numbers $s(b, j) = 2^b(2^j - 1)$ — binary strings of $j$ ones followed by $b$ zeros. These satisfy $s(b,j) + 2^b = 2^{b+j}$, so for $j \ge 2$ they sit strictly inside the top octave below $2^{b+j}$:

> **Staircase Reading.** For every $b$ and every $j \ge 2$, a doubling sweep reads $s(b,j)$ as $2^{b+j}$ — the top of its octave. Every binary staircase number with at least two ones is misread as its ceiling power of two.

And $112 = 2^4(2^3 - 1) = s(4,3)$, so $112 \mapsto 2^7 = 128$. The two rounds are one theorem: $\operatorname{read}_{\text{dyad}}(20) = 2^{\lceil\log_2 20\rceil} = 32$ and $\operatorname{read}_{\text{dyad}}(112) = 2^{\lceil\log_2 112\rceil} = 128$. "Knees quantize to the grid" is not a slogan supported by anecdotes; it is a single statement with instances.

## What to take away

The moral is not "use finer grids". Finer grids cost more evaluations, and the counting results show the trade-off precisely. The moral is that **the ruler is part of the result**, and its contribution is computable in advance.

Before you run a sweep, you can already say: which budgets this sweep can report exactly (the multiples of its step, or the powers of two); how badly it will overstate a knee that falls in a gap (the distance to the next mark up); how many distinct verdicts it is even capable of producing; and which chains of knees it can certify as strictly increasing. All of that is divisibility, binary weight, and greatest common divisors — number theory that predates the transistor, deciding how much memory a language model needs.

And when two sweeps disagree, the right first question is not "which experiment was wrong?" It is: *are these two numbers the same truth, seen through two different rulers?* In the case that started this story, the answer was yes. The truth is somewhere in $\{13, \dots, 20\}$; the fine ruler rounds it to $20$; the coarse ruler rounds it to $32$; and the one measurement that would pin it down is the one at $16$ that nobody took.
