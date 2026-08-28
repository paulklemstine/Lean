# The Ghost in the Sieve

## How a 1% wobble in the arithmetic of $x^2 - N$ was chased down, cornered, and dissolved

---

### A rumour about numbers

Every method humanity has for splitting a large number into its prime factors — every method that actually works at scale — rests on the same superstition. You cook up a stream of integers, you hope some of them factor into small primes, and you hope they do so at roughly the rate that *random* integers of the same size would.

That word *hope* is load-bearing. The integers you cook up are not random. In the quadratic sieve and its descendants, you take the number $N$ you want to factor, take $s = \lceil \sqrt{N} \rceil$, and grind through the values

$$v = j^2 - N, \qquad j = s+1, s+2, s+3, \dots$$

These are small — around $\sqrt{N}$ in magnitude — and they are transparently *structured*: they are shifted squares. The entire running-time analysis of the algorithm assumes that this structure does not matter, that a shifted square is as likely to be **smooth** (to have all of its prime factors below some bound $B$) as a random integer of the same size.

Nobody has proved this. It is a heuristic. And heuristics, when you push them hard enough, sometimes crack.

Two years of measurement had produced a rumour that this one was cracking. In a study of 96-bit balanced semiprimes — the regime where the smoothness parameter $u = \log v / \log B$ sits around $9$, deep in the territory where smooth numbers are vanishingly rare — the candidates $j^2 - N$ appeared to be smooth **less often** than matched random controls. Not dramatically: about $5\%$ less at one measurement threshold, about $14\%$ less at another. Every single confidence interval covered the null value $1$, so nothing was formally significant. But every way the data was split in half, the deficit pointed the same direction.

That is exactly the shape of a real effect hiding under insufficient data. It is also exactly the shape of nothing at all.

This article is about what happened when the rumour was tested properly — and about the surprisingly rich mathematics that had to be built to know what "properly" even means.

---

### The measurement

The experiment is conceptually simple. Fix a modulus $N$. Draw candidate values $v = j^2 - N$ for $j$ ranging over an interval past $\sqrt N$. For each candidate, draw a **paired control**: a random integer of exactly the same bit length, with exactly the same leading three bits of mantissa, but random low bits. Push both through the *identical* smoothness test — a cascade of greatest-common-divisor computations against products of consecutive primes, stripping out all prime factors below $10^5$, then below $10^6$, and asking what remains.

Count the smooth hits on each side. The statistic is the ratio

$$r = \frac{\text{smooth rate among candidates } j^2-N}{\text{smooth rate among size-matched controls}}.$$

If shifted squares behave like random integers, $r = 1$. The rumoured deficit says $r < 1$.

The replication run used $128$ distinct moduli and $150{,}000$ samples per modulus: exactly $19.2$ million candidate/control pairs. And the answer came back:

> At the better-powered threshold, $r \approx 0.99$ with a $95\%$ interval of $[0.919,\ 1.0101]$.
> At the pre-registered primary threshold, the interval was $[0.8571,\ 1.1488]$.

Both cover $1$. The deficit did not replicate downward. But — and this is where the story gets interesting — saying *that* correctly requires several theorems.

---

### Theorem 1: what "tighter" means

When a study reports an interval $[\ell, h]$ containing the null value $1$, what number should you carry forward as its contribution to knowledge? Not the width alone, and not the centre alone. The honest summary is the **edge distance**: how far, in the worst case, the truth could be from $1$ and still be inside your interval,

$$E = \max\big(|\ell - 1|,\ |h-1|\big).$$

Here is the first clean fact, and it is an exact identity, not an approximation:

> **The Edge Decomposition.** For any interval $[\ell,h]$ that contains $1$, write $c = (\ell+h)/2$ for its centre and $w = (h-\ell)/2$ for its half-width. Then
> $$E = w + |c - 1|.$$

The proof is a two-line case analysis on whether $c \ge 1$ or $c \le 1$, but the meaning is worth pausing on. A study's deliverable is the sum of two independent virtues: **precision** ($w$ small) and **absence of drift** ($c$ near $1$). A run can improve its headline number by being sharper, or by having its point estimate return towards the null — and those are different scientific events. Reporting only $E$ conflates them; the identity lets you unconflate them.

For our two runs: the pilot's interval $[0.8630,\ 1.0389]$ has $E = 0.137$. The replication's $[0.919,\ 1.0101]$ has $E = 0.081$. So the replication tightens the deliverable by a factor of $1.7$. Moreover — and this matters, because it rules out the boring explanation — *both summands improved independently*. The replication is strictly more precise ($w$ fell from $0.08795$ to $0.04555$) **and** strictly less drifted ($|c-1|$ fell from $0.04905$ to $0.03545$). The tightening is not an artifact of re-centring.

---

### Theorem 2: what four agreeing coin flips are worth

The original rumour's most persuasive feature was the direction stability: split the data in half, four different ways, and every half-sample pointed downward. That *feels* like evidence.

It is worth exactly $1/8$.

> **The Direction-Stability Bound.** Among the $2^k$ possible sign patterns of $k$ split-half comparisons, exactly $2$ are constant. Under the null, where each sign is a fair coin, the probability that all $k$ agree is therefore $2/2^k = 2^{1-k}$.

For $k = 4$, that is $1/8 = 0.125$, comfortably above any conventional threshold. In fact one needs $k \ge 6$ agreeing split-halves before the sign test even reaches the $5\%$ level: $2^{1-k} \le 1/20$ if and only if $k \ge 6$. Four agreeing halves are not a signal. They are a Tuesday.

This is the kind of correction that only looks obvious once someone writes it down. Direction stability is genuinely persuasive to the human eye, and genuinely worthless at shallow depth.

---

### Theorem 3: why the primes force the null

Now for the part that explains *why* the answer came back null — and why the effect, if it exists at all, must be subtle.

Fix an odd prime $p$ not dividing $N$. How often does $p$ divide a candidate $j^2 - N$? That happens exactly when $j^2 \equiv N \pmod p$, and the number of solutions is governed by the Legendre symbol:

> **Local Density.** The number of residues $j \bmod p$ with $p \mid j^2 - N$ is exactly $1 + \left(\frac{N}{p}\right)$. Hence the local density is
> $$\delta_p(N) = \frac{1 + \left(\frac{N}{p}\right)}{p} = \begin{cases} 2/p & \text{if } N \text{ is a square mod } p,\\ 0 & \text{otherwise.}\end{cases}$$

Compare this to the control density $1/p$ for a random integer. At *every single prime*, the candidate pool deviates from the control pool by $\pm 100\%$. There is no small-perturbation regime here; the local behaviour is violently non-random.

And yet:

> **The Two-Class Average.** If $N_1$ is a quadratic residue mod $p$ and $N_2$ is not, then
> $$\frac{\delta_p(N_1) + \delta_p(N_2)}{2} = \frac{1}{p},$$
> exactly the control density.

There it is. Averaged over the two quadratic classes, the violent local deviation cancels *identically*. This is the structural form of the null hypothesis: the candidates are not random, but their non-randomness is a **rearrangement across the population of moduli**, not a net drift. Some $N$ are lucky at $p$ and get double the hits; the rest get none; and the pool average is untouched.

There is a second consequence, and it is the one that dictated the entire experimental design. Model the multiplicative bias of one modulus across $k$ small primes as

$$B = \prod_{i=1}^{k} (1 + \varepsilon_i), \qquad \varepsilon_i = \pm 1 \text{ independently}.$$

Then $\mathbb{E}[B] = 1$ — that is the cancellation again — but $\mathbb{E}[B^2] = 2^k$, so

$$\operatorname{Var}(B) = 2^k - 1.$$

The between-modulus variance is **exponentially large** in the number of small primes. Two different moduli are wildly different worlds. This is why you cannot treat $19.2$ million pairs as $19.2$ million independent observations: they live inside only $128$ genuinely independent worlds.

---

### Theorem 4: independence, and the one heuristic that remains

The multiplicative model above assumes the conditions at different primes are independent. Usually that is a hand-wave. Here it isn't:

> **Exact Local Independence.** For coprime moduli $a$ and $b$, the number of residues $j \bmod ab$ that survive both sieving conditions — that is, with $a \nmid j^2-N$ *and* $b \nmid j^2-N$ — is exactly the product of the two individual survivor counts. Equivalently, the local survival densities multiply *with no error term whatsoever*.

The reason is the Chinese Remainder Theorem: the ring $\mathbb{Z}/ab$ splits as $\mathbb{Z}/a \times \mathbb{Z}/b$, and the pair of congruence conditions is exactly a condition on the two components. Independence here is not an approximation to be justified; it is an isomorphism. Iterating gives exact multiplicativity over any finite set of pairwise coprime moduli.

This is worth stating clearly because it *localises the remaining ignorance*. The Dickman-style heuristic that underwrites factoring algorithms has two steps: (i) the congruence conditions at distinct primes are independent; (ii) one may pass from a finite set of primes to full smoothness. Step (i) is a theorem. Only step (ii) is still a leap. If the shifted-square heuristic ever fails, it fails there.

The per-prime discrepancy, incidentally, has a beautifully clean form: the candidate's local survival probability is $1 - \delta_p(N)$, and it differs from the control's $1 - 1/p$ by exactly $\left(\frac{N}{p}\right)/p$ — a quantity of either sign, magnitude $1/p$.

---

### Theorem 5: the bootstrap has variance exactly $\sigma^2/m$

Given the exponential between-modulus variance, the run resampled whole moduli — the *cluster bootstrap*. Draw $128$ moduli with replacement, recompute the ratio, repeat $2000$ times, read off percentiles.

Practitioners know the folklore: a cluster bootstrap's spread is governed by the number of clusters, and throwing more data into each cluster doesn't help. It turns out this folklore is an exact identity.

Model the resample space honestly: it is the finite set of all $m^m$ index maps $s: \{1,\dots,m\} \to \{1,\dots,m\}$, each equally likely. The engine is a marginalisation identity that says the resample coordinates are exactly independent:

$$\sum_{s} \prod_{i=1}^m F(i, s(i)) \;=\; \prod_{i=1}^{m} \sum_{j=1}^{m} F(i,j).$$

From it one extracts the one- and two-coordinate corollaries $\sum_s g(s(k)) = m^{m-1}\sum_j g(j)$ and, for $k \ne l$, $\sum_s g(s(k))h(s(l)) = m^{m-2}(\sum g)(\sum h)$. Assembling them gives:

> **The Exact Bootstrap Variance Law.** For any cluster values $c_1,\dots,c_m$, the variance of the resample mean over the *entire* resample space is
> $$\operatorname{Var}_{\text{boot}} = \frac{\operatorname{Var}(c)}{m}.$$
> Not asymptotically. Exactly, at every $m$.

Applied to a two-level design with $m$ clusters and $n$ pairs per cluster, this says the bootstrap variance is exactly the **between**-cluster variance divided by $m$. The within-cluster dispersion — hence the pair count $n$ — does not appear at all. Combined with the classical decomposition $\text{total} = \text{within} + \text{between}$ (also exact for a balanced design), you get a design rule with no wiggle room:

> To reach a target bootstrap standard error $t$, you need $m \ge \operatorname{Var}(c)/t^2$ clusters, **whatever the pair count**.

The law is also non-degenerate in the right way: the bootstrap spread is zero if and only if every cluster carries the identical value. Two differing moduli already force a strictly positive interval. Nobody is getting a suspiciously tight interval for free.

---

### Theorem 6: how big must the next run be?

Now the design rule can be turned on the future. The realised run had $m = 128$ clusters and half-width $0.04555$; the $c/\sqrt m$ law calibrates the constant to $c = 0.04555\sqrt{128} \approx 0.5154$. To resolve a $1\%$ deviation — to have an interval at the point estimate $0.99$ actually exclude $1$ — the half-width must fall below $0.01$. The criterion $c/\sqrt m < \delta$ is equivalent to $m > (c/\delta)^2$, so:

- $10\times$ the clusters ($m \le 1280$): **provably not enough**.
- $30\times$ the clusters ($m \ge 3840$): **provably sufficient**.
- The exact threshold is $m = 2656$ clusters, about $20.75\times$ the realised run.

The informally-quoted "we'd need a 10–30× run" turns out to be exactly right, and $[10\times, 30\times]$ is the narrowest decade-scale bracket the $\sqrt m$ law admits.

One more diagnostic falls out. The replication's precision was already good enough that if the truth had sat at the pilot's point estimate of $0.947$, the interval would have excluded $1$. It didn't. That is genuine evidence — not proof, but evidence — that the pilot's effect size was too large.

---

### Theorem 7: $\sqrt 2$ is a ceiling, not a promise

The last act is combining the two runs. Standard theory: for independent estimates with variances $v_1, v_2$, every weighted average $w x_1 + (1-w)x_2$ has variance at least $v_1 v_2/(v_1+v_2)$, with equality exactly at the inverse-variance weight $w = v_2/(v_1+v_2)$.

Translated to half-widths, the pooled half-width is $h_1 h_2/\sqrt{h_1^2 + h_2^2}$. The folklore says pooling two studies buys you a factor of $\sqrt 2$. The truth is sharper and less generous:

> **The Pooling Ceiling.** For any positive $h_1, h_2$, the pooled half-width satisfies
> $$\frac{\min(h_1,h_2)}{\sqrt 2} \le \frac{h_1 h_2}{\sqrt{h_1^2+h_2^2}},$$
> with equality **if and only if** $h_1 = h_2$; the inequality is strict whenever the precisions differ.

So $\sqrt 2$ is the best case, attained only when the two studies are equally precise. Here the pilot is $1.93\times$ noisier than the replication, and the realised gain over the replication alone is under $12\%$. Pooling with a much noisier study buys almost nothing — and this is the correct general statement, replacing a folk claim that happened to be false in this instance.

What does pooling say about the drift? The inverse-variance pooled interval has centre $\approx 0.9617$ and half-width $\approx 0.04045$, so its upper edge sits at about $1.0021$ — still covering $1$, though barely. Pooling does *not* resurrect the deficit.

And the widely-quoted "joint point estimate $\approx 0.97$"? That is the *equal-weight* average of $0.947$ and $0.99$, namely $0.9685$. Weighting by precision, as pooling actually requires, gives $\approx 0.9805$ — strictly closer to $1$. The residual tension is smaller than the headline suggested, in the direction of the null.

---

### A note on honest failure

Two things went wrong in this run, and both became theorems.

First, a **display defect**. The output writer stored the candidate smooth rate rounded to four decimal places. The true rate is around $3 \times 10^{-5}$. Rounding to four places maps the entire range $[0,\ 5\times 10^{-5})$ to the single value $0$, and the raw hit counts were not saved. The stored figure of $0.0$ is therefore not merely imprecise — it is provably not the measured value, since the measured value is provably positive. What survives is a reconstruction: multiplying the confidence interval for $r$ by the control rate $3.1\times 10^{-5}$ pins the candidate rate to $[2.65701,\ 3.56128] \times 10^{-5}$. A quoted bracket of $[2.66,\ 3.56]\times10^{-5}$ circulated — but its endpoints are rounded *inwards*, so it is not a valid enclosure. The correct outward-rounded bracket is $[2.65,\ 3.57]\times 10^{-5}$. A rounding error in a rounding-error correction: mathematics is unforgiving.

Second, a **degenerate bootstrap**. A small smoke-test leg produced a nonsensical verdict, blamed on too few usable resamples. Is that plausible? Call a cluster an *event cluster* if it carries at least one smooth hit; a resample is useless exactly when it selects none, since then the ratio is $0/0$. Exactly $(m-h)^m$ of the $m^m$ resamples avoid a fixed set of $h$ event clusters, so the useless fraction is exactly $(1 - h/m)^m \le e^{-h}$, uniformly in $m$. Hence **a single event cluster already guarantees at least a $1 - e^{-1} \approx 63.2\%$ usable fraction**. Observing fewer than $100$ usable resamples out of $2000$ is therefore impossible with even one event cluster. The smoke leg's population had *no smooth hit at all*. Its interval carries no information about the ratio rather than carrying a wide one — which is precisely why discarding it in favour of the full run was correct.

---

### Where this leaves us

The rumour is downgraded. A fresh, independent, better-powered measurement returns a ratio of $0.99$ with the tightest interval yet obtained in this regime, and the deliverable edge shrinks from $0.137$ to $0.081$. Pooling with the pilot does not restore the deficit. The persuasive direction stability was worth $1/8$. The randomness heuristic that underwrites integer factorisation survives another assault, now out to smoothness parameter $u \approx 11.7$.

No barrier was breached; no constant was shaved. What was gained instead is a piece of exact infrastructure: an identity that says what a confidence interval delivers, a count that prices direction stability, a Legendre-symbol computation that explains both the null and the heavy tails, an isomorphism that makes local independence a theorem rather than a hope, an exact variance law for cluster resampling, and a threshold — $2656$ clusters — that tells the next experiment exactly how large it has to be.

That last number is the real deliverable. A rumour that cannot be resolved is a nuisance. A rumour with a price tag attached is a plan.
