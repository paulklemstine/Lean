# What a Mean and a Standard Deviation Already Know

*How two published numbers can settle — or refuse to settle — a scientific dispute, and what happened when we asked them about a "breach" that turned out not to exist.*

---

## A number that was too low

Somewhere in a long chain of experiments, a knob was turned. Call the knob $u$. Turning it up makes a system work harder, and a certain quality score — call it $\mathrm{sp}(u)$ — goes down. The engineering contract said the score must stay above a floor of $0.60$.

An earlier round of testing had reported something alarming: at the setting $u = 3.5$, the score had dipped **below** the floor. Not on average, but on some runs. One run in particular came back startlingly low. If that reading were real, the whole calibration would need to be redone.

So the experiment was repeated properly: fourteen fresh, independent populations, each with five times as much data as before. The verdict came back as a short block of summary statistics — the kind you would see in any paper's results table:

$$\text{mean} = 0.6282, \qquad \text{standard error} = 0.0041, \qquad \text{95\% interval} = [0.6204,\ 0.6363],$$
$$\text{sample standard deviation} = 0.0155, \qquad \text{runs below the floor} = 0/14 .$$

The interval sits comfortably above $0.60$. No run dipped below. Case closed?

Not quite — and the interesting part is *why not*. Because there were really two competing explanations for the original alarm, and they need different kinds of evidence to kill:

- **H1 — the centre is below the floor.** The system genuinely fails at $u = 3.5$; the earlier low readings were the truth.
- **H2 — the centre is fine, but the tail is wide.** On average the system is above the floor, but the spread is large enough that individual runs regularly fall through it. In engineering, that is often the *worse* diagnosis: an unreliable system is harder to fix than a uniformly bad one.

H1 dies immediately: the interval $[0.6204, 0.6363]$ excludes $0.60$. But H2 is a statement about the *tail*, and the summary line reports the *centre* and the *spread*. Does the published pair — mean $0.6282$ and standard deviation $0.0155$ — already rule out a wide tail? Or do you need to look at all fourteen individual numbers?

That question has a clean, complete, and slightly surprising answer. It turns out that a mean and a standard deviation know *exactly* how much they know, and you can compute it.

---

## The pigeonhole principle for variance

The engine behind everything that follows is one inequality, so simple it is almost embarrassing, and so sharp it decides the whole dispute.

Suppose you have $n$ numbers $x_1, \dots, x_n$ with a known centre $m$, and you know their total squared spread
$$\mathrm{SS} \;=\; \sum_{i=1}^{n} (x_i - m)^2 .$$
Pick any level $c$ strictly below the centre. Then:

> **The Finite One-Sided Dispersion Bound.** *The number of points at or below $c$ satisfies*
> $$\#\{\,i : x_i \le c\,\} \cdot (m - c)^2 \;\le\; \mathrm{SS}.$$

The proof takes one line. Every point sitting at or below $c$ is at distance at least $m - c$ from the centre, so it contributes at least $(m-c)^2$ to the sum of squares; the other points contribute a nonnegative amount; so the count times $(m-c)^2$ cannot exceed the total.

This is Chebyshev's inequality with all the probability stripped out. There is no random variable here, no distribution, no sample-size asymptotics — just $n$ numbers on a line and a budget they have to share. The picture to carry is a **budget**: the total squared spread is a fixed pot of money, and every point that strays a distance $\delta$ from the centre spends $\delta^2$ of it. Straying is quadratically expensive.

Now feed in the recorded numbers. Fourteen runs, mean $m = 0.6282$, sample standard deviation $s = 0.0155$. The total squared spread is
$$\mathrm{SS} = (n-1)s^2 = 13 \times 0.0155^2 = 0.00312325 .$$
The floor is at $c = 0.60$, a margin of $m - c = 0.0282$, so each sub-floor run costs $0.0282^2 = 0.00079524$. The budget divided by the price is
$$\frac{0.00312325}{0.00079524} = 3.927\ldots$$

**At most three of the fourteen runs can be below the floor.** Not four. That is a theorem about any fourteen numbers with that mean and that spread, and it required no access to the individual readings.

---

## The cap is real, and so is its limit

So the summary line does some work: it refutes any claim that four or more runs breached the floor. Everything of the form "half the runs failed" is dead on arrival.

But three is not zero — and the natural next question is whether the bound is merely a crude estimate that could be tightened. It cannot. Consider the population
$$\underbrace{0.5999,\ 0.5999,\ 0.5999}_{\text{three sub-floor runs}},\ \underbrace{0.635918\ldots,\ \dots,\ 0.635918\ldots}_{\text{eleven runs}} .$$
Its mean is *exactly* $0.6282$, and its total squared spread is $0.0030579\ldots$, which is **smaller** than the recorded $0.00312325$ — so its sample standard deviation, $0.015337$, is smaller than the recorded $0.0155$. And three of its runs are below the floor.

This is a legitimate, fully compliant population. It matches the published summary better than the published summary matches itself, and it breaches the floor three times.

So we get a precise epistemic statement:

> **What the summary line decides.** *The published pair (mean $0.6282$, standard deviation $\le 0.0155$) is consistent with exactly $0$, $1$, $2$, or $3$ sub-floor runs, and with nothing else. Three is the largest achievable count.*

That is the honest answer to "did we need the raw data?" **Yes — and exactly this much.** The observed $0/14$ carries genuine information beyond the summary; H2 dies at the level of individual runs, not at the level of the table. Anyone who wants to claim four breaches, however, can be refuted from the table alone.

There is a methodological lesson buried here that generalises far beyond this one experiment: **the standard deviation is the wrong instrument for a tail question at small $n$.** It is not that H2 was false and the summary showed it. It is that the summary *cannot* show it, and knowing that in advance would have told the experimenters to publish the seed-level column.

---

## Depth is more expensive than breadth

The budget picture has a second consequence that the counting bound alone misses. Ask not *how many* runs went low, but *how low any single run could possibly have gone*.

Here the bound becomes brutally simple. A single run at depth $\delta$ below the centre spends $\delta^2$ of a budget of $0.00312325$. So
$$\delta \;\le\; \sqrt{0.00312325} \;=\; 0.055886\ldots$$

> **The No-Deep-Breach Theorem.** *In any fourteen-run population with mean $0.6282$ and sample standard deviation at most $0.0155$, every single run exceeds $0.5723$.*

The original alarming reading — a run somewhere around $0.55$ — is **arithmetically impossible** in the new population, no matter what the other thirteen runs do. The historical claim that the deep-breach run "has no analogue at five times the data" is not an observation about the new data. It is a consequence of two published numbers.

Combining depth and count gives the full trade-off. If $k$ runs each sit at depth $\delta$ or more below the centre, then
$$k\,\delta^2 \;\le\; 0.00312325 ,$$
which produces a small, complete ladder:

| depth below the mean | maximum number of runs at that depth | status |
|---|---|---|
| $0.0282$ (the floor itself) | $3$ | attained |
| $0.0400$ | $1$ | attained |
| $0.0559$ | $0$ | impossible |

Each rung is sharp where it says "attained". The middle one, for instance, is realised by a population with one run at $0.5882$ — a full $0.04$ below the mean, and $0.0118$ below the floor — and thirteen runs at $0.631276\ldots$; its mean is exactly $0.6282$ and its spread is comfortably inside budget. Nature has room for one such run. It has no room for two.

Note the shape of the trade-off: **depth is quadratically expensive, breadth only linearly so.** Halving the depth quadruples the number of runs you can afford. That asymmetry is the entire reason a "single catastrophic outlier" story is easier to kill with summary statistics than a "generally shaky" story.

---

## What actually survived

Refuting a breach is not the same as finding nothing. The experiment carried a second column: the same fourteen runs measured at the *lower* knob setting $u = 2.5$, and the paired difference
$$\Delta_i = \mathrm{sp}_i(2.5) - \mathrm{sp}_i(3.5) .$$
Every one of the fourteen differences was positive. The mean drop was $0.1057$, with interval $[0.0999, 0.1112]$.

**Fourteen out of fourteen.** How impressed should we be? There is a way to answer that requires no distributional assumption at all.

Suppose the knob setting carries no information — the sharp null hypothesis. Then which member of each pair got labelled "$2.5$" and which "$3.5$" is arbitrary, and we may flip any subset of the labels. Each of the $2^{14} = 16{,}384$ sign patterns $s$ gives a re-labelled total
$$T(s) = \sum_{i=1}^{14} \pm \Delta_i .$$
The observed statistic is the all-plus total. The question is how many of the $16{,}384$ re-labellings match or beat it.

Since every $\Delta_i$ is strictly positive, flipping even one sign strictly decreases the total. So **exactly one** re-labelling is as extreme as the observed one: the one we saw.

> **The Exact Sign Test.** *If all $n$ paired differences are strictly positive, the one-sided randomization $p$-value is exactly $2^{-n}$.* At $n = 14$: $p = 1/16384 \approx 6.1 \times 10^{-5}$.

Exact, not asymptotic. No normality, no large-sample approximation, no variance estimate. Positivity of fourteen numbers is the entire input.

---

## The randomization tail is a subset-sum problem

That argument sees only the very top of the distribution. What does the rest of the tail look like? Here a change of coordinates reveals something structural.

Let $S$ be the set of coordinates a sign pattern flips. Then
$$T(s) \;=\; \sum_i \Delta_i \;-\; 2\sum_{i \in S} \Delta_i .$$
The re-labelled statistic is an affine image of a **subset sum**. The $2^n$ sign patterns are the vertices of a Boolean cube; the event "at least as extreme as observed" is the cube's intersection with a half-space. And so, for any tolerance $t$:

> **The Subset-Sum Correspondence.** *The number of re-labellings within $2t$ of the observed statistic equals the number of subsets of the runs whose difference-mass is at most $t$.*

This is a genuine bridge between three subjects: randomization inference, lattice points of the Boolean cube in a half-space, and subset-sum counting. It explains, in one line, why exact randomization $p$-values are computationally hard in general — subset-sum counting is $\#\mathrm{P}$-hard — and why the degenerate case $t = 0$ above was so easy.

It also gives us robustness for free. Applying the dispersion bound to the *difference* column (mean $0.1057$, paired standard deviation at most $0.0110$, hence a budget of $13 \times 0.0110^2 = 0.001573$ and a maximal single-run deviation of $0.039661$) yields:

> **The Two-Sided Uniformity Band.** *Every single run's drop lies strictly between $0.066$ and $0.1454$.*

The lower half is "degrades everywhere" as a theorem: no run is even close to insensitive; each loses at least $62\%$ of the mean drop. The upper half rules out the mirror-image story that a few hypersensitive runs are dragging the average up. The degradation is uniform *from both sides*.

Feed that uniform bound $\Delta_i \ge 0.066$ back into the subset-sum count. Only subsets small enough to fit under the tolerance can qualify, so the count collapses into a binomial tail: with a tolerance of $t = 0.13$, only subsets of size $0$ or $1$ survive, giving at most $\binom{14}{0} + \binom{14}{1} = 15$ re-labellings. So even a *robustified* $p$-value — one that hands an adversary a free $0.26$ haircut, about $18\%$ of the total effect $1.4798$ — stays below $15/16384 < 10^{-3}$.

And there is a **spectral gap**: every re-labelling other than the observed one falls short of it by at least $2 \times 0.066 = 0.132$, nearly $9\%$ of the total mass. The observed statistic is not a marginal maximum; it is an isolated one. That gap is the structural reason the paired comparison is decisive while the unpaired floor question was not.

---

## Why the pairing worked: a hidden shared quality

One last piece of arithmetic explains the whole thing. Write $\mathrm{SS}(x)$ for a column's total squared deviation about its own mean, and $\mathrm{SP}(a,b)$ for the total cross-product of two columns. Then, exactly,
$$\mathrm{SS}(a - b) = \mathrm{SS}(a) + \mathrm{SS}(b) - 2\,\mathrm{SP}(a,b) .$$
Pairing reduces dispersion precisely when the two columns are positively correlated.

Both knob settings produced columns with spread $0.0155$; the difference column has spread at most $0.0110$ — *smaller than either*. Solving the identity:
$$\frac{\mathrm{SP}(a,b)}{\mathrm{SS}(a)} \;\ge\; 1 - \frac{0.0110^2}{2 \times 0.0155^2} = 0.748\ldots$$

> **The Forced-Correlation Bound.** *The run-level correlation between the two knob settings is at least $0.74$.*

This is not a statistical impression from a scatter plot; it is forced by the published interval widths. And it changes the engineering conclusion completely. A run that scores well at $u = 2.5$ scores well at $u = 3.5$. The two columns move together, separated by an almost constant offset. **The degradation is a population-level property carried by a shared latent quality, not a per-run idiosyncrasy.** There is no bad seed to hunt down. There is one uniform $0.11$ offset to fix.

---

## Where the floor is actually crossed

Finally, a prediction. The system is $0.0282$ above the floor at $u = 3.5$ and losing $0.1057$ per unit of $u$. The simplest model,
$$\mathrm{sp}(u) = m - b\,(u - 3.5) \quad\text{with } b > 0,$$
is strictly decreasing and therefore crosses the floor at a unique point
$$u^\star = 3.5 + \frac{m - 0.60}{b} .$$
At the recorded estimates $u^\star = 3.7668$. Better: sweep the *entire* box of intervals — every centre in $[0.6204, 0.6363]$ and every slope in $[0.0999, 0.1112]$ — and the crossing still lands strictly inside
$$3.68 \;<\; u^\star \;<\; 3.87 .$$

That is a falsifiable forecast. It predicts $u = 3.5$ safe (consistent with the verdict) and $u = 4.0$ breached. A single population above the floor at $u = 4.0$, or a single population below it at $u = 3.6$, kills the linear model outright.

One small audit closes the loop: $0.0155/\sqrt{14} = 0.0041425\ldots$, matching the published standard error of $0.0041$ to within $5 \times 10^{-5}$, and the interval half-width is $1.92$ standard errors — an ordinary two-sided $95\%$ interval. The resampling procedure added no width of its own, so "the interval excludes the floor" is not an artefact of the method.

---

## The moral

The alarming original result was sampling noise, and the new data says so. But almost everything worth saying about the new data was already latent in five published numbers, waiting to be extracted by an inequality a schoolchild could prove.

Two lessons stand out. First, **summary statistics are not summaries — they are constraints**, and you can compute exactly which claims they settle and which they leave open. The mean and standard deviation here refute four breaches, refute any deep breach, refute any insensitive run, and force a correlation of $0.74$ — but they cannot refute three shallow breaches, and no amount of cleverness will make them. Publishing the raw column mattered, and now we know precisely why.

Second, when an effect refuses to die under a sign test with a spectral gap at the top of its randomization distribution, and when the uniformity band forbids both insensitive and hypersensitive runs, you are not looking at an outlier problem. You are looking at a uniform property of the system. Hunt the mechanism, not the bad seed.
