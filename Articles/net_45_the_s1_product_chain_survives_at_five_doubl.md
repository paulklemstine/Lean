# The Razor's Edge: What a Five-Doubling Chain of Coincidences Can and Cannot Tell Us

## A law that keeps coming true

Every modern language model spends most of its time doing one thing: comparing each token it is reading to every token it has read before. That comparison — attention — costs work proportional to $L^2$, where $L$ is the length of the context. Double the context and you quadruple the bill. It is the single most stubborn cost curve in the field.

The obvious escape is to be selective. If, when processing a given position, the model only really *uses* a handful of earlier positions, then we could simply throw the rest away: keep a budget of $k$ positions out of $L$, and pay $kL$ instead of $L^2$. The speedup is $L/k$.

The whole question is how big $k$ has to be. And here a small, strange empirical law has been emerging from a long series of controlled experiments. Fix a model of depth $d$. Sweep the budget $k$ over a grid, and find the smallest $k$ at which the pruned model still retains $98\%$ of the unpruned model's held-out accuracy. Call that threshold the **knee**, $k^\*$. The law says
$$k^\* \;=\; \frac{d \cdot L}{32}.$$

That is a *product law*: the knee is proportional to the depth times the context. In the depth-$4$ family it predicts $k^\* = L/8$: $16$ at $L=128$, $32$ at $256$, $64$ at $512$, $128$ at $1024$, and $256$ at $2048$.

The measurement at $L = 2048$ — sixteen times the shortest context in the ladder, five successive doublings, and about five hours of training for a single cell — came back at exactly $256$. The prediction, stated before the run, was confirmed. Five rungs, all exact.

This article is about what that chain actually establishes, and — the more interesting half — about the three precise ways it is weaker than it looks. All three are theorems, not opinions.

## The measurement, and the width of a hair

The sweep at $L = 2048$ reads, as retained accuracy relative to the unpruned model:

| $k$ | 96 | 128 | 160 | 192 | 224 | **256** | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| retained | .939 | .951 | .963 | .970 | .976 | **.9813** | .984 | .993 | .997 | .996 | .998 |

The bar is $0.98$. The first grid point to clear it is $256$; the previous grid point, $224$, misses by $0.004$. So $k^\* = 256$, as predicted.

But look at how it clears: $0.9813$ against a bar of $0.98$. The margin is $\mathbf{0.0013}$ — thirteen ten-thousandths. The earlier rungs of the chain cleared by $0.007$, $0.010$, $0.003$ and $0.006$. This one is by far the thinnest, and it is well inside the spread one sees between two random seeds of the same configuration, which at nearby cells has been measured at around $0.006$.

Here is the first theorem, and it is sharp in both directions. Say the knee claim "$k^\* = 256$" is **$\eta$-robust** if every curve within $\eta$ of the measured one — at every grid point — still has its knee at $256$. Then:

> **Robustness radius.** The knee claim at this cell is $\eta$-robust **if and only if** $\eta \le 0.0013$.

The "if" direction is a check that every deficit below the knee ($0.041$, $0.029$, $0.017$, $0.010$, $0.004$) exceeds the margin, so no admissible perturbation can promote a lower grid point while keeping $256$ above the bar. The "only if" direction is a construction: for any $\eta > 0.0013$ one writes down an *increasing* curve within $\eta$ of the measurement whose value at $256$ falls below the bar. The exact robustness radius of a five-doubling confirmation is the width of a hair.

Push a little further. At $\eta = 0.006$ — the seed-to-seed spread already measured in this family — one can exhibit a perfectly monotone curve within $\eta$ of the measurement whose knee is $224$, one grid step down. In other words: *the one-step drop that a second seed might report is already visible inside the first seed's own noise, before the second seed is ever run.*

## How long is a chain, really?

A chain of exact rungs is a conjunction. It is only as strong as its weakest link, and there is a clean way to say so.

Given a ladder of margins $m_0, m_1, m_2, \dots$ — one per rung of the doubling ladder — define the **certification depth at noise $\eta$** to be the number $n$ such that the first $n$ rungs all have margin at least $\eta$, and rung $n$ does not. This is exactly the same "first failure" functional as the knee itself, applied to the ladder instead of to the sweep. It is well defined (the depth is unique), and it has the property one wants:

> **More noise certifies fewer doublings.** If $\eta \le \eta'$, then the certification depth at $\eta'$ is at most the depth at $\eta$.

For the measured ladder $m = (0.007,\ 0.010,\ 0.003,\ 0.006,\ 0.0013)$ the numbers are brutal:

- at $\eta = 0.0013$ (the chain's own tightest margin): depth $5$;
- at $\eta = 0.002$: depth $4$;
- at $\eta = 0.004$: depth $2$;
- at $\eta = 0.006$ (the inter-seed spread): depth $\mathbf{2}$;
- at $\eta = 0.010$: depth $0$.

So the honest headline is not "the product law is exact at five doublings". It is: **the law is exact at five doublings, and certified at two.** The third rung, with its $0.003$ margin, is the choke point; everything past it is contingent on noise smaller than the noise we have actually observed.

Is five-in-a-row surprising at all? Under the natural null model — each rung independently reads either the predicted budget or one grid step below it, by a fair coin — exactly one ladder in $2^n$ is exact at every rung. For $n = 5$ that is $1/32 < 0.05$: a five-rung chain *is* significant at the conventional level. (For $n = 2$, the size of a mere two-cell replication, it is $1/4$, which is not.) The chain is real evidence. It is simply evidence for a claim whose certified depth is shorter than its measured depth.

Finally, a translation. The product law says $k = dL/32$. The deployable speedup is $L/k$. These are literally the same statement:

> For positive $d, L, k$: $\;k = dL/32\;$ holds **if and only if** the speedup $L/k$ equals the context-independent constant $32/d$.

At $d = 4$ that constant is $8$, and indeed $2048/256 = 8$. The exactness of the product law and the context-independence of the guaranteed speedup are one fact wearing two hats. (One footnote of arithmetic hygiene: at the alternative reading $k = 224$ the speedup is $2048/224 = 64/7 \approx 9.14$, not the $10.3$ that appeared in an early write-up — an error of more than a full multiple.)

## The second story: selection is losing its edge

The knee is one number. The same run measures something else, and it is the more interesting number precisely because it is the weakest.

Pruning by "keep the $k$ positions with the largest attention weight" is only worth doing if it beats *keeping $k$ positions at random*. Call the difference the **selection gap**. Across the ladder it reads $+5.9$ and $+4.6$ accuracy points at $L=256$, $+5.3/+4.6$ at $512$, $+5.9/+4.6$ at $1024$ — and only $+1.7/+1.8$ at $L = 2048$. Selection is *diluting*: at sixteen times the context, choosing carefully is barely better than choosing blindly.

To say anything precise about this we need the objects. An **attention profile** is a function $p$ assigning a non-negative weight to each of the $L$ positions, with total weight $1$. For a budget $k$, the **top-$k$ mass** $T_k(p)$ is the largest total weight carried by any $k$ of the positions. This is exactly what a data-free top-$k$ pruner retains. It exists and is unique whenever $k \le L$ — the maximum over a finite non-empty family of subsets.

What is the random baseline, exactly? Not approximately, exactly. Average the mass over *all* $k$-subsets. A double count does it: summing $\sum_{i \in S} p_i$ over every $S$ of size $k$ counts each position once for every $k$-subset containing it, and there are $\binom{L-1}{k-1}$ of those, so
$$\sum_{|S| = k} \sum_{i \in S} p_i \;=\; \binom{L-1}{k-1} \sum_i p_i .$$
Dividing by the number of subsets and using $L\binom{L-1}{k-1} = k\binom{L}{k}$ gives the clean statement:

> **The random-$k$ baseline is exactly $k/L$ of the total mass.**

The null model the experiment compares against is therefore not an approximation to be estimated; it is a theorem.

Two consequences follow immediately, and they cut in opposite directions.

**First: a positive gap means nothing.** Since the maximum of a finite set is at least its average,
$$T_k(p) \;\ge\; \frac{k}{L},$$
always, for every profile. The selection gap is *non-negative by theorem*. So the observation that all measured gaps came out positive is not evidence for structure in attention — it could not have come out otherwise. Only the *size* of the gap carries information.

**Second: a zero gap would mean everything.** Suppose the gap vanishes at some intermediate budget $0 < k < L$, i.e. $T_k(p) = k/L$ exactly. Then every $k$-subset has exactly the same mass (a family of numbers whose maximum equals their mean is constant), and picking two positions $i \ne j$ and completing each with the *same* $(k-1)$ other positions forces $p_i = p_j$. So:

> **Rigidity.** A vanishing selection gap forces the profile to be exactly uniform.

Dilution is therefore a *quantitative approach to complete unstructuredness*. A gap of zero would be the strongest possible negative result about data-free attention pruning: it would say the attention distribution has no preferred positions at all. The measured $+1.7$ at $16\times$ context is not "still positive, so we're fine"; it is a reading on a dial whose zero is the death of the method.

## No bounded working set

The same run measures the **effective support** $N_{\mathrm{eff}} = 1/\sum_i p_i^2$, the standard "how many positions is this distribution really spread over". It reads $291.16$ at $L = 1024$ and $526.39$ at $L = 2048$: a factor $1.81$ per doubling. Sublinear (it does not keep up with the context) but nowhere near saturating (it does not stop growing). And directly: the top-$128$ positions carry only $0.589$ of the mass at $L = 2048$, the top-$256$ only $0.731$. There is no small set of positions that "is" the computation.

Cauchy–Schwarz turns this into a hard cap. If $S$ is any set of $k$ positions then $\left(\sum_{i\in S} p_i\right)^2 \le k \sum_{i \in S} p_i^2 \le k \sum_i p_i^2$, so
$$T_k(p)^2 \;\le\; \frac{k}{N_{\mathrm{eff}}}, \qquad\text{equivalently}\qquad k \;\ge\; \beta^2 N_{\mathrm{eff}}$$
to retain a fraction $\beta$ of the mass. Concentration measurements *cap* what any budget can retain, and the required budget scales with $N_{\mathrm{eff}}$.

From which the structural conclusion:

> **No bounded working set.** If a family of attention profiles has unbounded effective support, then for every fixed budget $k$ and every target fraction $m > 0$ there is a context in the family at which the top-$k$ mass falls below $m$.

A context-independent budget cannot retain a constant fraction of the attention mass. Whatever the knee law is, it must grow with the context — which is precisely why the product law is a product law.

There is a sting in the tail, and it is a check on the study's own arithmetic. Feed the measured top-$256$ mass $0.731$ into the cap: it forces $\sum_i p_i^2 \ge 0.731^2/256$, hence an inverse participation ratio strictly *below* $526.39$. The two reported numbers are incompatible as literal readings of the same functional, so the reported effective support must be a different concentration measure (an entropy-based one), and the two must not be combined in a single bound. Conversely, reading $N_{\mathrm{eff}} = 526.39$ as a genuine inverse participation ratio, a budget of $256$ could carry at most $\sqrt{256/526.39} < 0.70$ of the attention mass — far below the $0.98$ bar. **The knee is a statement about the layer's output, not about the attention distribution.** Mass retention and accuracy retention are genuinely different thresholds, and conflating them is a mistake the numbers themselves catch.

## The dilution theorem: what the weakest number proves

Now the payoff. What would it mean for attention to be *scale-invariant* — for the profile at $2L$ to be "the same shape" as the profile at $L$? The exact form of that null hypothesis is **self-similar refinement**: each position splits into two positions of half its weight. A Zipf-like profile that simply resolves finer as the context lengthens does exactly this.

Compare at matched sparsity: budget $k$ out of $L$ before, budget $2k$ out of $2L$ after. The easy half is that the refined pruner can copy the old choice — take both halves of each previously selected position — so $T_{2k}(\mathrm{split}\,p) \ge T_k(p)$, and since the baselines $k/L$ and $2k/2L$ agree, the gap cannot shrink.

The hard half is that the refined pruner can do no better, and it is not obvious: a $2k$-subset of the refined context need not be a union of split pairs. It may take one half of some positions and both halves of others — a *fractional* selection problem with weights in $\{1/2, 1\}$. Does that relaxation buy anything? No, and here is why. Describe a subset $U$ of the refined context by its two traces $S_{\mathrm{t}}, S_{\mathrm{f}}$ (which positions contribute their first half, which their second). Then
$$2\,\mathrm{mass}(U) \;=\; \sum_{S_{\mathrm{t}}} p + \sum_{S_{\mathrm{f}}} p \;=\; 2\sum_{D} p + \sum_{E} p,$$
where $D = S_{\mathrm{t}} \cap S_{\mathrm{f}}$ are the doubly-selected positions and $E$ the symmetric difference, with $2|D| + |E| = |U| = 2k$. So $E$ has *even* size $2(k - |D|)$ — and in any set of even size $2m$, some $m$ of the elements carry at least half the mass (take a maximiser among the $m$-subsets; its complement inside $E$ has the same size, hence no more mass). Adjoining that half $C$ to $D$ gives exactly $k$ positions with $\mathrm{mass}(U) \le \sum_{D \cup C} p \le T_k(p)$. No positivity, no ordering, no normalisation is used.

> **Exchange theorem.** $T_{2k}(\mathrm{split}\,p) = T_k(p)$ exactly. Hence **the selection gap is exactly invariant under self-similar refinement**: scale-invariant attention neither dilutes nor concentrates the advantage of top-$k$ selection.

And therefore, two-sidedly:

> **Any** measured change in the selection gap across a context doubling at matched sparsity — up or down — refutes exact self-similarity of the attention profile.

The measured drop from $+5.9$ to $+1.7$ is such a change. So the weakest number of the whole study, the one that looked like a mere erosion of an advantage, is in fact its most falsifiable output: the long-context attention profile is not the self-similar refinement of the short-context one. Whatever shape you fit to the $1024$ profile, the $2048$ profile is a different shape — flatter, more nearly uniform, closer to the rigidity point at which selective pruning stops being selection at all.

## Where this leaves us

Three sentences, then.

The product law $k^\* = dL/32$ has now been confirmed at five consecutive doublings, which under a fair null is significant, and which is the same statement as a constant $8\times$ deployable speedup at depth $4$ — but its certified depth at the noise we have actually measured is two doublings, not five, and the sixteen-times cell clears its bar by $0.0013$, less than a quarter of the inter-seed spread.

Meanwhile the mechanism the law is supposed to describe is quietly failing: the effective support keeps growing, no bounded working set exists, the budget needed to hold a fixed fraction of attention mass scales like the effective support, and the advantage of choosing well over choosing at random has fallen from six accuracy points to under two — a change which, by the exchange theorem, is by itself a proof that attention is not merely rescaling as the context grows.

The decisive experiment is small and obvious: a second seed at the sixteen-times cell. If it reads $256$, the chain is two-seed exact at five doublings. If it reads $224$ — the reading that the first seed's own noise already contains — the chain breaks exactly where the theory says the thinnest margin is. Either way the interesting frontier has moved from the threshold to the profile: not *how big is the knee*, but *how long can selection remain worth doing at all*.
