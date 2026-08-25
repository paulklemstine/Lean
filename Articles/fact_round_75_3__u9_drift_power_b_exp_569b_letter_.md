# Seventy-Six Million Coin Flips That Were Really Only Twelve Thousand

## How a single random seed can quietly turn a mountain of data into a molehill — and the exact algebra that tells you how big the molehill is

There is a particular feeling that comes over an experimenter around hour two of a long computation. The counters are climbing. The log file is filling up. Seventy-six million measurements, then eighty, then eighty-five. Somewhere behind the progress bar is a number you care about, and every extra million samples is supposed to be pinning it down a little more tightly.

This is a story about the moment that feeling turns out to be wrong — and about the mathematics that makes "wrong" into something you can compute to the last decimal place.

The setting was a randomness test. For each of $128$ carefully chosen large composite numbers, an automated experiment drew $600{,}000$ paired samples: a *candidate* value and a matched *control* value, checked for a certain arithmetic property, and tallied. The quantity of interest is a ratio $r$ of two hit rates. If the underlying process is as structureless as theory says it should be, $r = 1$. Any persistent departure from $1$ would be a small crack in a wall that a long line of experiments has been testing.

$128 \times 600{,}000 = 76{,}800{,}000$ paired evaluations. Two and a bit times the size of the earlier pilot. Nearly ninety minutes of wall clock. And the honest answer at the end of it is that this run carries no more information than about $12{,}800$ independent measurements — a factor of six thousand less than the raw count suggests.

That is not a bug in the code. It is a theorem.

## The first illusion: sampling harder inside the same cage

Suppose you want to estimate an average, and your data comes in $k$ *clusters* — here, the $128$ composite numbers, each with its own idiosyncrasies — with $m$ measurements inside each cluster. Measurements in the same cluster are not independent; they share whatever peculiarity the cluster has. Write $\rho$ for that shared correlation and $\sigma^2$ for the variance of a single measurement.

Then the variance of the grand mean over all $km$ measurements is exactly

$$\mathrm{Var} \;=\; \frac{\sigma^2\bigl(1 + (m-1)\rho\bigr)}{km}.$$

The bracket $1 + (m-1)\rho$ is the *design effect*: the price of clustering. It is always at least $1$, so clustered sampling is never better than independent sampling. But the interesting thing is what happens when you push $m$ up, which is exactly what "run it longer" means. The $m$ in the numerator and the $m$ in the denominator fight, and the numerator wins to a draw:

$$\mathrm{Var} \;\ge\; \frac{\rho\,\sigma^2}{k} \qquad \text{for every } m,$$

and as $m \to \infty$ the variance decreases *to* that value, never below. There is a floor, and the floor is set by $k$ — the number of clusters — not by the number of samples.

Translated into sample-size language: the *effective sample size*, the number of genuinely independent measurements your run is worth, is

$$\frac{km}{1 + (m-1)\rho} \;\le\; \frac{k}{\rho}.$$

With $k = 128$ clusters and an intra-cluster correlation of a mere one percent, $\rho = 1/100$, that ceiling is $12{,}800$. Not $12{,}800{,}000$. Twelve thousand eight hundred. Sampling the same $128$ objects harder does not help; you have to go get more objects.

This is why the confidence intervals reported for the run were computed by resampling the $128$ moduli rather than the $76.8$ million pairs. That is not statistical timidity. It is the only arithmetically defensible thing to do, and the inequality above is the reason.

## The second illusion: counting one dataset twice

Now the part of the story that had to be retracted.

The experiment had three legs: an earlier pilot, a medium run called $G_1$ with $150{,}000$ samples per modulus, and the long run $B$ with $600{,}000$. Three legs, three estimates of $r$, three error bars. The obvious move is *inverse-variance weighting* — combine them with weights proportional to precision — and that is what was done. The combined interval came out as roughly $[0.942, 1.000]$, tantalisingly kissing the null value.

Then someone traced the random streams. $G_1$ and $B$ ran from the same master seed, consuming the same chunk seeds in the same order. $B$'s first $150{,}000$ samples per modulus were not merely similar to $G_1$'s — they were *byte-identical*, candidates and paired controls alike. $G_1$ was a prefix of $B$. The three-leg combination had counted one dataset twice.

How much does that cost? Exactly this much. Model the stream as a sequence of uncorrelated draws, each of variance $\sigma^2$, and let a *leg* be the average of the draws at some finite set $S$ of stream positions. Then any two legs cut from one stream have covariance

$$\mathrm{Cov}(\bar{x}_S, \bar{x}_T) \;=\; \frac{\sigma^2\,|S \cap T|}{|S|\,|T|}.$$

Everything follows from that one line. Pool the two legs with weight $w$ on the first, and the variance you *actually* have exceeds the variance the independence bookkeeping *reports* by a term you can write down:

$$\mathrm{Var}_{\text{true}} \;=\; \mathrm{Var}_{\text{reported}} \;+\; \frac{2w(1-w)\,\sigma^2\,|S \cap T|}{|S|\,|T|}.$$

The two agree if and only if $S$ and $T$ are disjoint. For sample means cut from a single stream, statistical independence *is* set-theoretic disjointness — there is no weaker sufficient condition, no "mostly independent", no "independent enough".

Two special cases sting. If you pool a dataset with *itself* at equal weights, the formula reports exactly half the true variance: your error bars shrink by $\sqrt{2}$ for free, which is to say fraudulently. And if one leg is a genuine prefix of the other, $S \subseteq T$, the inverse-variance pool has true variance

$$\frac{\sigma^2\bigl(3|S| + |T|\bigr)}{\bigl(|S| + |T|\bigr)^2},$$

which is an inflation factor of $\dfrac{3|S| + |T|}{|S| + |T|} > 1$ over what was reported. At the geometry that actually occurred — $150{,}000$ nested inside $600{,}000$, so $|T| = 4|S|$ — that factor is exactly $7/5$.

Worse than inflated: the pool is *worse than throwing the prefix away*. The long leg alone has variance $\sigma^2/|T| = \sigma^2/(4|S|)$; the pool has $7\sigma^2/(25|S|)$, which is larger. Adding the short run to the long run actively degrades the estimate. Everyone's intuition says more data cannot hurt; for overlapping legs, that intuition is simply false.

And the punchline for the experiment: rescaling a variance by $7/5$ rescales a $z$-statistic by $1/\sqrt{7/5} \approx 0.845$. Any deficit whose *reported* two-sided statistic reaches at most $2.14$ — the figure obtained from the corrected combination — has an honest statistic strictly below $1.96$. The interval $[0.9226, 0.9966]$ that appeared to exclude $1$ does not exclude it once the shared stream is paid for. The gate closes. No confirmed deviation is available from that seed.

## The third illusion: fresh data, stale population

The retraction left a fallback: combine only the pilot and the long run $B$, which share no draws at all. Different code paths, different random consumption, disjoint measurement machinery. Surely *those* are independent?

They are not, and the reason is one level up. A recorder check reconstructed the pilot's $24$ composite moduli and found all $24$ of them sitting inside $B$'s pool of $128$. The two legs share no draws, but they share *objects*.

To see the cost, split each measurement into a per-object part and a private part: the object contributes a component of variance $\rho\sigma^2$ shared by every draw on it, and each draw adds a private component of variance $(1-\rho)\sigma^2$. A leg is now indexed by a set $K$ of objects and a set $T$ of draw indices. The covariance of two legs is the sum of two terms:

$$\mathrm{Cov} \;=\; \underbrace{\frac{\rho\,\sigma^2\,|K \cap K'|}{|K|\,|K'|}}_{\text{shared objects}} \;+\; \underbrace{\frac{(1-\rho)\,\sigma^2\,|K \cap K'|\,|T \cap T'|}{|K|\,|T|\,|K'|\,|T'|}}_{\text{shared draws}}.$$

This single identity contains both of the round's failures as its two summands. The prefix-nesting disaster is the second term. The pilot-inside-$B$ problem is the *first* term, which survives even when the second vanishes: with disjoint draws but nested populations, $K \subseteq K'$, the covariance is

$$\frac{\rho\,\sigma^2}{|K'|} \;>\; 0 \quad \text{whenever } \rho > 0.$$

Only disjoint object populations give exactly zero. Fresh draws are not enough; you need fresh *objects* — which, in a deterministic pipeline where the population is itself generated from the master seed, means a genuinely different master seed.

## What one seed is worth

Put the two mechanisms together and a general principle emerges, one that no amount of clever reweighting can dodge.

Suppose a lab cuts *any* finite family of legs $S_1, \dots, S_n$ from a single stream — nested, overlapping, re-sliced, re-weighted, however you like — and pools them with *any* weights summing to $1$. Let $U = S_1 \cup \dots \cup S_n$ be the set of draws actually consumed. Then

$$\mathrm{Var}(\text{pool}) \;\ge\; \frac{\sigma^2}{|U|},$$

and the bound is attained by the uniform average over $U$. The only resource is the number of *distinct* draws. Not the number of legs, not the sophistication of the weights, not how many papers the legs appear in.

For a chain of ever-longer runs $S_1 \subseteq S_2 \subseteq \dots \subseteq S_n$ from one seed, the union is just $S_n$, so the whole lineage is worth its longest run and no more. A lineage is one dataset wearing several hats.

The contrast is stark and quantitative. Two *disjoint* legs of equal size — a genuinely fresh master seed — pool to $\sigma^2/(|S| + |T|)$, which for $|S| = |T|$ is exactly half the variance of either. Error bars divided by $\sqrt{2}$: the real thing, not the illusory $\sqrt{2}$ that self-pooling manufactures. Re-running a prefix can never buy this. Only new randomness can.

There is even a rule for what to do when your legs *are* correlated and you cannot fix it. For legs of variances $v_1, v_2$ and covariance $c$, completing the square on the pooled variance $w^2 v_1 + (1-w)^2 v_2 + 2w(1-w)c$ gives the optimal weight and the best achievable variance:

$$w^\star = \frac{v_2 - c}{v_1 + v_2 - 2c}, \qquad \mathrm{Var}_{\min} = \frac{v_1 v_2 - c^2}{v_1 + v_2 - 2c}.$$

Inverse-variance weighting — the textbook default — coincides with the optimum precisely when $c(v_2 - v_1) = 0$: either the legs are uncorrelated, or they are equally precise. For legs of unequal precision, zero covariance is not a convenience; it is the exact licence for the standard formula. And for a prefix nested inside a longer run, the optimal weight comes out to $w^\star = 0$. *Discard the prefix* is not a rule of thumb. It is the least-squares solution.

## The verdict, and the honest cliffhanger

So where does this leave the physics?

At the primary smoothness cut the run gives $r = 0.9710$ with a cluster-resampled interval $[0.8976, 1.0521]$; at the secondary cut, $r = 0.9623$ with $[0.9224, 1.0040]$. Both intervals cover $1$. The three-leg combination that appeared to do better is withdrawn — it counted a dataset twice. The two-leg fallback that appeared to exclude $1$ at $z \approx 2.14$ is withdrawn too — its legs share their population, and the $7/5$ inflation drags the honest statistic below threshold.

Every dataset from that master seed is *one* seed's evidence. Jointly it sits three to five percent below $1$: interesting, consistently signed, and entirely uncertified. The candidate-side deficit even points *opposite* to the direction a known compensating mechanism would predict, which would make it a new weak effect if it is real.

The decisive step is not more samples. The theorems above say more samples on the same objects converge to a floor of finite precision, and that floor has already been reached. The decisive step is a fresh master seed: a new population, a new stream, disjoint on both levels, whose combination with the existing data is licensed by the disjointness clause rather than assumed in defiance of it. If the deficit survives that, it is a candidate deviation with a real exclusion behind it. If it returns to $1$, the randomness hypothesis stands, tightened.

The lab-wide rule adopted in the aftermath is one sentence long, and it is now a corollary rather than an opinion: *a replication must vary the master seed, and the run must assert in its own output that it did.* Redrawing a population from inside a fixed stream is not replication. It is the same experiment, told twice, with error bars shrunk by a factor you can now compute exactly.

Seventy-six million pairs. Twelve thousand eight hundred honest observations. The difference between those two numbers is not a failure of computing power. It is a theorem about what randomness you have actually spent.
