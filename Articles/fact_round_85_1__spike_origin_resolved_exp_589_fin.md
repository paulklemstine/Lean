# The Spike That Wasn't

### How the geometry of a search window manufactures a statistical signal — and how exact arithmetic dissolves it

---

## A bump at the edge

Somewhere in a large computational experiment, a histogram had a bump.

The experiment was of a shape that will be familiar to anyone who has ever hunted for factors, for smooth numbers, or for solutions of a quadratic congruence. For each of $128$ large numbers $N$ — each around $96$ bits, so of size roughly $10^{29}$ — a program marched an index $j$ across a window,

$$W(N) \;=\; \bigl[\,\lfloor\sqrt N\rfloor + 1,\; 3\lfloor\sqrt N\rfloor\,\bigr],$$

and at each position computed the **residue**

$$v \;=\; j^2 - N .$$

Some positions produced a "hit" — the residue passed whatever arithmetic test the experiment cared about. Pooled across all $128$ moduli, $9594$ hits were recorded, and half a million control runs were generated for comparison.

Then someone sliced the window into ten equal parts and counted hits in each. The first tenth — the *left edge*, the positions immediately above $\sqrt N$ — was overloaded. Against a flat baseline, which expects one tenth of the hits in one tenth of the window, the first decile carried an excess of about $605$ hits: a pooled rate ratio of $1.637$, where $1$ means "nothing to see". Fit a two-component model — a background plus a bump localized at the left edge — and the model-selection statistic came back at $\Delta\mathrm{AICc} = 49.78$, an enormous margin over the pre-registered decision bar of $6$.

The natural reading was seductive: **there is a positional kernel**. Something about *where* you are in the window, independent of how big the residue happens to be, makes hits more likely near the left end.

This article is about why that reading is wrong — completely, not partially — and about the small pile of exact theorems that replace it. The punchline is that the left edge of this window is not a *place*; it is a *size*. And once you know that, every number in the paragraph above turns out to have a different author.

---

## The window has a secret

Start with the simplest possible question. If $j$ sits in the first tenth of the window, how big can $v = j^2 - N$ be?

Write $s = \lfloor\sqrt N\rfloor$ for the integer square root. The window runs from $s+1$ to $3s$; it has $2s$ positions; the first decile is the leading tenth of them, which is the set of $j$ with

$$5j \;\le\; 6s .$$

Now just square. Since $s^2 \le N$,

$$25 v \;=\; 25 j^2 - 25N \;\le\; (5j)^2 - 25 s^2 \;\le\; (6s)^2 - 25 s^2 \;=\; 11 s^2 .$$

That is the whole computation, and it is a theorem of exact integer arithmetic with no error term, no asymptotics, and no probability in sight:

> **The Inclusion Bound.** For every first-decile position $j$ of the window of $N$, the residue satisfies $25\,v \le 11\,s^2 \le 11\,N$, i.e. $v \le 0.44\,N$.

The constant $11/25$ is not slack. It is attained: take $N = (5m)^2$ and $j = 6m$, the very last first-decile position, and you get $25v = 11 s^2$ on the nose.

Now put in the numbers. The moduli of the experiment are below $2^{96}$. So every first-decile residue obeys

$$v \;\le\; 0.44 \cdot 2^{96} \;=\; 0.88 \cdot 2^{95} \;<\; 2^{95},$$

which is to say: **every first-decile residue has bit length strictly less than $96$.** Not "almost all". Not "with high probability". Every one, always, by arithmetic.

And here is the empirical table of first-decile hits, broken out by the bit length of $v$:

| bit length of $v$ | $<80$ | $80$–$89$ | $90$–$95$ | $\ge 96$ |
|---|---|---|---|---|
| first-decile hits | $0$ | $85$ | $1469$ | $0$ |

That final zero is not data. It is a geometric identity of the window, dressed up as an observation. A hit whose residue has $96$ or more bits *cannot* be in the first decile — the exclusion is deterministic, and it fires for every one of the $128$ moduli.

It is worth stressing that this is genuinely an *edge* phenomenon and not a property of the window as a whole: deeper in the very same window, residues comfortably exceed $2^{96}$. For $N = 2^{94}$ and $j = 3\cdot 2^{47}$ — the last window position — the residue is exactly $2^{97}$. The window spans small and large residues; the decile cut slices off precisely the small ones.

So the first decile is not a random sample of the window's residue distribution. It is a **pure tiny-$v$ stratum**, selected by size, wearing the costume of a position.

---

## Position and magnitude are the same variable

The inclusion bound is a one-sided inequality, but the underlying degeneracy is total. Inside a single modulus, $v = j^2 - N$ is a *strictly increasing* function of $j$ on the window, and it is invertible in closed form:

$$j \;=\; \bigl\lfloor \sqrt{N + v}\,\bigr\rfloor .$$

Position determines residue; residue determines position. Consequently, at fixed $N$, **any** weighting of hits by position can be reproduced exactly by a weighting of hits by magnitude, and vice versa: given a positional weight $w(j)$, the magnitude weight $m(v) := w(\lfloor\sqrt{N+v}\rfloor)$ agrees with it at every window position. The two model families are observationally indistinguishable. No single-modulus experiment, however large, can separate a positional kernel from a size effect. They are literally the same statistic.

The counting version is just as clean. Ask, for a threshold $x$, how many window positions have residue at most $x$. The answer is a closed form in the *position* variable:

$$\#\{\, j \in W(N) : v \le x \,\} \;=\; \min\bigl(3\lfloor\sqrt N\rfloor,\ \lfloor\sqrt{N+x}\rfloor\bigr) - \lfloor\sqrt N\rfloor .$$

Every magnitude sublevel set is a positional prefix, and every positional prefix is a magnitude sublevel set.

On the cleanest moduli — the perfect squares $N = (5m)^2$ — this becomes an exact dictionary. The window has exactly $10m$ positions; the first decile has exactly $m$ of them, so its name is literal; and the first-decile predicate is *equivalent*, position by position, to the magnitude threshold $v \le 11m^2$. A "first-decile analysis" and a "$v \le 0.44 N$ analysis" are not two analyses that happen to agree. They are one analysis with two names.

If you let the scale run to infinity, a pretty limit law falls out. For $N = M^2$ and a threshold $y M^2$ with $0 \le y \le 8$, the fraction of window positions with $v \le yM^2$ satisfies the sharp bound

$$\Bigl|\,F_M(yM^2) - \tfrac{\sqrt{1+y}-1}{2}\,\Bigr| \;\le\; \frac{1}{2M},$$

so that in the limit the rescaled residue $v/M^2$ has distribution function $(\sqrt{1+y}-1)/2$ on $[0,8]$. That is precisely the law of $(1+2U)^2 - 1$ where $U$ is uniform on $[0,1]$ — which is exactly what you would guess, since a uniformly chosen window position is $j = M(1+2U)$. At the decile level $y = 11/25$ the limit law returns $\frac{1}{10}$ *exactly*, with zero error, on the divisible moduli. There is no scale, and no asymptotic regime, in which the positional cut carries a shred of information beyond the magnitude cut.

---

## Simpson's paradox, wearing a lab coat

Now we can ask the honest statistical question. Take the hits, sort them into bands by the bit length of $v$, and compare the first-decile rate *within each band*. The answer:

- band $80$–$89$: rate ratio $1.000$;
- band $90$–$95$: rate ratio $1.097$.

Essentially nothing. Yet against the flat, size-blind baseline the pooled ratio is $1.637$. Where does the gap come from?

There is an exact identity that answers this, and it is elementary enough to write in one line. Suppose the data are split into bands $i$; band $i$ has exposure $n_i$ and observed edge count $k_i$, its own band-specific edge rate is $p_i$, and the flat baseline uses a single rate $p_0$. Define

$$\text{flat excess} = \sum_i k_i - p_0\sum_i n_i, \qquad \text{band excess} = \sum_i (k_i - p_i n_i), \qquad \text{composition} = \sum_i (p_i - p_0) n_i .$$

Then, with no hypotheses whatsoever,

$$\boxed{\ \text{flat excess} \;=\; \text{band excess} \;+\; \text{composition}. \ }$$

The two boundary readings are immediate and they are the whole story.

- If every band is **size-matched** — $k_i = p_i n_i$, rate ratio exactly $1$ in each band — then the band excess is zero and the *entire* flat excess is composition. A spike of arbitrary size can appear with no rate elevation anywhere.
- If the bands are **homogeneous** — all $p_i$ equal to $p_0$ — the composition term vanishes and the flat baseline is honest.

So a composition artifact requires genuine band heterogeneity. And that is exactly what the inclusion bound supplies, in the most extreme possible form: the band with $v \ge 2^{96}$ has a first-decile rate that is *mechanically zero*.

Here is an explicit configuration in exactly the shape the window geometry forces. Two bands: a tiny-$v$ band with $n_0 = 3000$ exposure and edge rate $p_0 = 0.53$, carrying $k_0 = 1590$ edge hits, and a large-$v$ band with $n_1 = 6594$ exposure and edge rate $0$, carrying no edge hits. Within each band the rate ratio is exactly $1$; the band-referenced excess is exactly $0$. Against a flat baseline of $p_0 = 0.1$, the flat excess exceeds $600$ and the pooled rate ratio exceeds $1.6$.

Nothing is happening, and a spike of $600$ appears. This is Simpson's paradox in the exact configuration produced by the window.

The multiplicative version is even more direct. If every band satisfies the matched bound $k_i \le R\, p_i n_i$, then

$$\text{pooled rate ratio} \;\le\; R \times \underbrace{\frac{\sum_i p_i n_i}{p_0 \sum_i n_i}}_{\text{composition factor}} .$$

Feed in the measured numbers: matched ratio $R = 1.097$, composition factor $1.4924$. Their product is $1.6372$ — the observed pooled ratio of $1.637$ to four decimal places. There is nothing left over. Not "little"; *nothing*.

And the composition factor is not a free parameter you can tune to taste. If all band rates lie in $[p_{\min}, p_{\max}]$, then whatever the exposure allocation,

$$\frac{p_{\min}}{p_0} \;\le\; \text{composition factor} \;\le\; \frac{p_{\max}}{p_0},$$

with equality above only when *all* exposure sits on maximal-rate bands. The artifact is bounded by the **rate spread**, never by the sample size — you cannot manufacture an arbitrarily large composition spike by collecting more data, only by widening the gap between bands. In this experiment the gap is as wide as gaps get, because one band's rate is exactly zero by arithmetic.

Running the same identity in the other direction bounds how much of the observed excess *must* be composition. With a matched ratio at most $R$ and a flat-null expectation $E$,

$$\text{composition} \;\ge\; \frac{\text{flat excess} - (R-1)E}{R}.$$

At $R = 1.097$, $E = 959.4$ and a flat excess of at least $604.76$, this gives composition $\ge 466$: at least **77 %** of the entire spike is composition, as an inequality rather than an impression.

---

## The ghost that persisted, and where it lived

There was one more piece of evidence, and it was the strongest-looking. Suppose you throw away the tiny-$v$ stratum altogether — truncate to $v \ge 2^{95}$ — and refit. A left-edge component *still* appears in the pooled fit, with weight $0.0403$ and $\Delta\mathrm{AICc} = 49.78$. Surely that is a positional effect that has survived the purge?

It is not, and two independent arguments say so.

**First: pooled evidence is not stratum evidence.** Fit a two-component model to a pooled sample and you are forcing one shared parameter on strata that differ. There is an exact accounting for this. Let $G$ be the *null misspecification gap*: twice the log-likelihood that stratum-wise nulls gain over a single pooled null. Then $G \ge 0$ always, and

$$\Delta\mathrm{AICc}_{\text{pooled}} \;\le\; \sum_i \Delta\mathrm{AICc}_i \;+\; G \;+\; (\text{penalty defect of the split}).$$

Any pooled excess beyond the strata is heterogeneity of the *null*, not support for the extra component. And the stratified numbers are: $\Delta\mathrm{AICc} = 5.94$ in band $[96,98)$ — **below** the registered bar of $6$ — and $\Delta\mathrm{AICc} = -0.40$ for bit length $\ge 98$, which is to say the extra component is actively unhelpful there. With a penalty defect of at most $3$, the inequality forces $G \ge 41.2$: over four fifths of the imposing pooled statistic is measuring the size gradient between bit-length bands. Splitting into strata also *raises* the small-sample penalty, so the stratified analysis is the conservative one — the sub-bar strata are not an artefact of a laxer criterion.

**Second: what remains is exactly what a truncation boundary produces.** The surviving signal lives entirely in the band $[96,98)$, adjacent to the truncation cut, and vanishes beyond it. Model a band as $2m$ consecutive size cells with local density $f$, and define the apparent left-edge excess as the lower half's mass minus the upper half's. Then: for *any* nonincreasing density the edge excess is nonnegative — a spurious left-edge weight is automatic; for a flat density it is exactly zero — so the effect is a *gradient* effect, not an edge effect; and for a geometric density $f_i = r^i$ the relative edge excess is exactly

$$\frac{1-r^m}{1+r^m},$$

which is strictly decreasing in $r$ and bounded by $m(1-r)$. Near a truncation boundary the surviving size density is steep, $r$ is well below $1$, and an apparent edge component appears. Two bands further out the density is locally flat, $r \to 1$, and it vanishes. Sub-bar at $[96,98)$, absent at $\ge 98$: that is the signature of a boundary gradient, and it is the signature that was observed.

---

## What the controls could and could not say

The control arm produced, over $128$ moduli, first-decile share $z$-scores with mean $-0.223$, standard deviation $0.945$, and a maximum absolute value of $2.53$. The ledger records "controls clean". That claim deserves to be stated precisely, and so does its limit.

A maximum of $|z| = 2.53$ over $128$ independent strata is not a near-miss; it is unremarkable. The multiplicity-corrected bound $2m e^{-t^2/2}$ at $m = 128$, $t = 2.53$ evaluates to more than $1$: it constrains nothing at all. In fact any threshold clearing a $5\,\%$ Bonferroni bar over $128$ strata must exceed $4$. So "controls clean" correctly means *no exceedance was produced* — it does not mean the null was confirmed. Absence of a flag is weaker than evidence, and it is worth saying so out loud rather than banking the reassurance.

---

## The verdict, and what survives it

Assembled, the components give a single statement:

> Under the empirical inputs, the left-edge profile decomposes into (1) a mechanically forced tiny-$v$ stratum — every first-decile hit has $v < 2^{95}$ by exact arithmetic; (2) a band-composition term that reproduces the pooled rate ratio of $1.637$ from a matched within-band ratio of $1.097$ and nothing else; and (3) a pooled-null heterogeneity term that absorbs at least $34$ of the $49.78$ units of "evidence" and lives at a truncation boundary. **No positional component remains.**

This retracts an earlier reading — one that had the kernel surviving at reduced strength, with "half genuine small-$|v|$ structure beyond the size prediction". That half was a truncation-boundary gradient.

What survives is worth naming, because retractions that delete everything are usually retracting too much.

The **overdispersion is real**. There genuinely are about $605$ more first-decile hits than a flat baseline expects. The finding is not that the excess is illusory; it is that the excess has an *identified origin*, and the origin is size composition forced by the window's geometry, not location.

The **mechanical degeneracy is now load-bearing**. It began as a caveat and ended as the central theorem. And it carries a design lesson far beyond this experiment: the only source of identification in the design — pooling across moduli, since two hits with the same residue can occupy different window positions in different windows — is *also* the only source of the confound. You cannot get one without the other.

Finally, both surviving mechanisms are **scale-carrying**. The inclusion bound is exact arithmetic, so it grows with $N$: at $128$ bits, at $256$ bits, at any size, the first decile of this window is still a pure tiny-$v$ stratum. This is not a finite-sample quirk that will wash out with a bigger run. It is a permanent feature of the shape of the search.

The lesson generalizes past sieves and residues. Whenever a covariate you are slicing on is an exact function of a covariate you are ignoring, your baseline is not a baseline — it is a second hypothesis you forgot to write down. The most honest thing a large computation can tell you is sometimes that the interesting structure was in the coordinate system all along.
