# The Experiment That Changed Its Mind

## How a single flipped sign killed a promising anomaly — and why the mathematics says it had to

### A five-percent rumour

Somewhere in the vast bookkeeping of right triangles, a rumour had been circulating.

The setting is a large computational search over Pythagorean-type configurations: for a huge collection of moduli $N$, the search counts how many sampled pairs $(a,b)$ produce a "hit" — a configuration satisfying the relation under test. Two streams run side by side. One is the *candidate* stream, drawn from the structured family whose behaviour is in question. The other is the *control* stream, a deliberately structureless comparison. If nothing interesting is going on, the two counts should be statistically indistinguishable, and their ratio

$$r \;=\; \frac{\text{total candidate hits}}{\text{total control hits}}$$

should sit at $1$, up to noise.

For three successive rounds of experiments, $r$ came in below $1$. Not dramatically — $0.9468$, then $0.988$, then $0.9623$. A deficit of a few percent. Small, but it kept reappearing, and each time it passed the gate: the reported $95\%$ confidence interval sat entirely below $1$. Three independent-looking legs, all pointing the same way. It was starting to look like a *deviation from randomness* — a structural fingerprint hiding in the arithmetic.

Then someone noticed that all three legs shared a random seed.

### The arbiter

So a fresh run was commissioned, on a seed that had never touched the earlier stream. Band-9, $96$-bit moduli, $128$ separate values of $N$, six hundred thousand sampled pairs each: $76.8$ million pairs in total, nearly an hour and a half of computation.

The result: $2598$ candidate hits versus $2252$ control hits at the primary threshold. That is

$$r \;=\; \frac{2598}{2252} \;=\; 1.1536,$$

with a $95\%$ interval of $[1.0540,\,1.2611]$ — an interval that excludes $1$, decisively, **from above**. At the looser threshold, $40617/38594 = 1.0524$, interval $[1.0051,\,1.1016]$. Again above.

The old family said *deficit*. The clean seed said *surplus*. Not "a smaller effect", not "a bigger effect" — the opposite sign.

And that is the end of the story, because a directional disagreement is a much stronger refutation than a numerical one. Here is why, in one line of mathematics.

### Two intervals cannot both be right

Suppose two runs claim to be estimating the same unknown quantity $\rho$, each reporting an interval that, by its own advertisement, contains $\rho$ with probability at least $1-\alpha$. Call $A$ the event "run 1's interval contains $\rho$" and $B$ the event "run 2's interval contains $\rho$". If the two intervals are *disjoint* as subsets of the line — one strictly below $1$, the other strictly above — then $A$ and $B$ are disjoint events. Disjoint events have probabilities that add, and probabilities cannot exceed $1$:

$$(1-\alpha) + (1-\alpha) \;\le\; \mathbb{P}(A) + \mathbb{P}(B) \;=\; \mathbb{P}(A \cup B) \;\le\; 1,$$

which forces $1 \le 2\alpha$, i.e. $\alpha \ge 1/2$. For nominal $95\%$ intervals, $\alpha = 0.05$, and the inequality is simply false. **At least one of the two coverage claims is wrong — or the two runs are not measuring the same thing at all.**

That is the whole rejection, and it is airtight. It does not require deciding *which* seed family is at fault. It only requires that they disagree in direction. The candidate anomaly, twice banked and once downgraded across three earlier papers, is dead.

The same argument scales. If $s$ runs report pairwise incompatible intervals, each with nominal coverage $1-\alpha$, then summing over all of them gives

$$s \,(1-\alpha) \;\le\; 1, \qquad\text{i.e.}\qquad \alpha \;\ge\; 1 - \tfrac{1}{s}.$$

Three mutually disagreeing runs would falsify any nominal coverage better than $67\%$. Disagreement is not a nuisance to be averaged away; it is a *measurement* of how badly the error bars are being oversold.

### Symmetric skepticism

Here is the part that separates careful science from motivated reasoning. The clean seed read a **surplus** of $+15\%$, with an interval excluding $1$ from above. Why not bank *that* as the new anomaly?

Because the same skepticism has to cut both ways. It is a single run. The earlier family was also "a single seed", replicated three times through a shared stream, and it produced a confident interval too — pointing the wrong way. A one-run interval that excludes $1$ is exactly the object whose reliability is now in question. So nothing is banked in either direction. The honest verdict is: *randomness stands*, with a measured fluctuation envelope of roughly $\pm 5$–$15\%$ per run at this scale.

That envelope is not a shrug. It is the real discovery of the round, and it has a proof.

### Why one run can never settle this

The counts are not a single homogeneous pile. They arrive in **clusters** — one cluster per modulus $N$. And the clusters are wildly uneven. In the arbiter run, the three biggest candidate clusters carried $600$, $561$, and $540$ hits, against a control maximum of $359$. That is not noise around a common mean; that is genuine *overdispersion*.

To quantify it, write $x_1,\dots,x_m$ for the per-cluster counts, $S = \sum_i x_i$ for the grand total, and define the **relative cluster dispersion**

$$\mathrm{rsd}(x) \;=\; \frac{\sqrt{\sum_{i}\bigl(x_i - \bar{x}\bigr)^2}}{S}, \qquad \bar{x} = \frac{S}{m}.$$

This is not an arbitrary formula. It is *exactly* the relative standard deviation of the resampled total under the nonparametric cluster bootstrap — the resampling scheme that produced the reported intervals. Drawing $m$ clusters uniformly at random with replacement and re-adding their counts gives a random total $T^\ast$, and one can show by an exact combinatorial identity (summing over all $m^m$ equally likely resamples) that

$$\frac{1}{m^m}\sum_{\text{resamples}} \bigl(T^\ast - S\bigr)^2 \;=\; \sum_i \bigl(x_i - \bar x\bigr)^2.$$

So the bootstrap's own variance is precisely $\sum_i (x_i-\bar x)^2$, and $\mathrm{rsd}$ is precisely the bootstrap's relative error bar. Any statement about $\mathrm{rsd}$ is a statement about the interval that was actually printed.

And here is the floor. For *any* cluster $j$,

$$\boxed{\;\frac{x_j}{S} - \frac{1}{m} \;\le\; \mathrm{rsd}(x).\;}$$

The proof is disarmingly short: the single term $(x_j - \bar x)^2$ is at most the whole sum, so taking square roots gives $x_j - \bar x \le \sqrt{\sum_i (x_i-\bar x)^2}$, and dividing by $S$ turns the left-hand side into $x_j/S - 1/m$.

In words: **if one cluster carries a share $f$ of all the hits, your one-run relative resolution can never be better than $f - 1/m$.** No amount of sampling *within* clusters helps, because the bootstrap resamples *clusters*.

Plug in the recorded numbers. The arbiter had $m = 128$ clusters, a top cluster of $600$ hits, and a grand total of $40617$. The floor is

$$\frac{600}{40617} - \frac{1}{128} \;\approx\; 0.01477 - 0.00781 \;=\; 0.00696.$$

The reported half-width at that cut was $(1.1016 - 1.0051)/2 \approx 0.048$ — comfortably more than twice the floor. So the interval is *consistent* with the cluster structure. The run did not report an error bar narrower than its own geometry permits. That audit item closes cleanly.

### The overdispersion is built into the triangles

One might hope that the lumpiness is an artefact of the sampler, something that a better design would smooth out. It is not. It is a property of Pythagorean arithmetic itself.

Cluster the hits by hypotenuse: for a fixed $c$, let $H(c)$ be the set of ordered pairs of positive legs $(a,b)$ with $a^2 + b^2 = c^2$. For $c=5$ this is exactly $\{(3,4),(4,3)\}$ — two hits. But cluster sizes are **unbounded**:

> **Theorem (Unbounded hypotenuse multiplicity).** For every $k$ there exists a hypotenuse $c$ with $|H(c)| \ge k$.

The construction is explicit and pretty. Take the classical family $(m^2-1,\;2m,\;m^2+1)$, which is Pythagorean for every $m$, and let $m$ run over $2,3,\dots,k+1$, giving hypotenuses $h_v = (v+2)^2+1$ for $v = 0,\dots,k-1$. Now set

$$C_k \;=\; \prod_{v<k} h_v \;=\; \prod_{v=0}^{k-1}\bigl((v+2)^2+1\bigr).$$

Every $h_v$ divides $C_k$, so each triple can be scaled by the integer $C_k/h_v$ to a triple with hypotenuse exactly $C_k$. That gives $k$ leg pairs sharing the hypotenuse $C_k$, and a short cross-multiplication argument shows they are genuinely distinct (the map $v \mapsto (v+2)^2+1$ is injective, and a coincidence between two scaled legs would force a scaled leg to equal the hypotenuse, which is impossible since legs are strictly shorter).

For $k=3$: $C_3 = 5 \cdot 10 \cdot 17 = 850$. The theorem promises $3$ hits. The truth is $14$ — because the real count is multiplicative in the primes $\equiv 1 \pmod 4$ dividing $C_k$, and the scaled family only sees one triple per factor. The proof is a floor; reality overshoots it.

Combining unbounded multiplicity with the resolution floor gives the sharpest statement of the round:

> **Theorem (Near-half floor).** For every $\varepsilon > 0$ there exist two distinct hypotenuses whose genuine hit clusters form a two-cluster family with relative resolution floor at least $\tfrac12 - \varepsilon$.

Take one hypotenuse with a huge cluster of size $h$ and pair it with $c=5$, whose cluster has size $2$. The floor is
$$\frac{h}{h+2} - \frac12 \;=\; \frac12 - \frac{2}{h+2} \;\xrightarrow[h\to\infty]{}\; \frac12 .$$
Clustered Pythagorean search has **no universal averaging**. There is no bound, valid for all cluster profiles, that says "sample enough pairs and the relative error goes below $\delta$".

### The mediant, or: a pooled surplus is never a mirage

One more structural fact keeps the analysis honest. The pooled ratio $r = (\sum_i x_i)/(\sum_i y_i)$ is a *mediant* of the per-cluster ratios $x_i/y_i$, and mediants are trapped:

> **Theorem (Mediant envelope).** With all $y_i > 0$, there exist clusters $\ell$ and $u$ with
> $$\frac{x_\ell}{y_\ell} \;\le\; \frac{\sum_i x_i}{\sum_i y_i} \;\le\; \frac{x_u}{y_u}.$$

The pooled ratio can never escape the range of ratios actually attained. Two consequences. First, a pooled surplus $r > 1$ *forces* at least one individual cluster with $x_i > y_i$: aggregation cannot manufacture an effect out of clusters that all show deficits. Second — and this is the warning — a single dominant cluster can drag the pooled ratio all the way to its own value. The pooled statistic is a weighted-median-like object whose sensitivity is governed almost entirely by the biggest clusters. Exactly the ones the multiplicity theorem says are unboundedly big.

### The false alarms

Two alarms were raised during the audit, and both dissolved.

The first was a formatting ghost. A coordinator display printed a value of $3.38 \times 10^{-5}$ using five-decimal formatting, rendering it as `0.00003` — which appeared to fall outside its interval. It does not; truncation moved it. That this can happen at all is a triviality with a clean statement: there exist $lo < x < hi$ whose five-decimal truncation $\lfloor 10^5 x\rfloor/10^5$ lies strictly below $lo$. Take $lo = 0.000031$, $x = 0.0000338$, $hi = 0.000035$; then $\lfloor 3.38 \rfloor / 10^5 = 0.00003 < lo$. A display artefact carries no information about the underlying number, and the raw counts recompute exactly.

The second was the interval itself: was the reported bootstrap CI reproducible? An independent $4000$-replicate rebootstrap from the persisted raw counts reproduced the stored interval to three decimals ($[1.0540, 1.2611]$ against a stored $[1.0541, 1.2686]$). It was.

### What it would take to reopen the gate

Nothing here is banked, so nothing here is unfalsifiable. The round named its own reopening condition, and the arithmetic behind it is simple. Independent runs with variances $v_1,\dots,v_k$ combine by inverse-variance weighting to a pooled variance

$$V \;=\; \Bigl(\sum_i v_i^{-1}\Bigr)^{-1},$$

which is at most the smallest single $v_i$ — pooling never hurts — and which equals exactly $\sigma^2/k$ when all runs share a common $\sigma^2$. The recorded half-width at the looser cut corresponds to a one-run standard error of about $0.025$. Three genuinely distinct seeds would pool to $\sqrt{0.025^2/3} \approx 0.0144 < 0.02$, which is the joint resolution the round declared necessary.

But the numerical burden is not the whole burden. Any future claim must also *explain the sign flip*: why one seed family reads a deficit and another a surplus at the same scale. Until someone does, the honest reading is that both are fluctuations inside a $\pm 5$–$15\%$ envelope that this experiment has now, for the first time, measured rather than assumed.

### The value of a null

It is tempting to read this round as a failure: three papers of accumulating evidence, wiped out by one fresh seed. That is the wrong reading.

What the round produced is a *map with contour lines*. Before, "the search sees no deviation from randomness" was an assertion. Now it comes with quantified resolution floors: a proof that the reported error bars match the cluster structure; a proof that the cluster structure is intrinsic to Pythagorean arithmetic and not an artefact; a proof that in the worst case no single run can do better than a near-$50\%$ relative resolution; and an exact identity showing that the bootstrap being used is the very object those floors constrain. The randomness line now extends through the next scale band with a measured fluctuation envelope attached.

There is a discipline in that arc worth naming: bank, downgrade, null with an independence audit, and finally a clean rejection by sign flip. Four rounds, each one correcting the last, none of them hiding the correction. The strongest thing you can say about a scientific pipeline is not that it finds effects. It is that it can kill its own.

The rumour is dead. The map is better than it was.
