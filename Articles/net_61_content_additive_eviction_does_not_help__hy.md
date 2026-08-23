# The Cache That Cannot Be Saved

## Why adding a second opinion to a forgetting rule made it worse — and why that had to happen

Every system that remembers has to forget. A web browser keeps a few hundred pages in cache and drops the rest. An operating system holds a working set of memory pages and pushes the others to disk. A language model, running a long conversation, keeps a window of past tokens in fast memory and throws away the ones it judges least useful. In every case the same question comes up, and it is always the hardest question in the room:

**Of the things I am holding, which one should I throw away?**

The honest answer — throw away the one you will need least in the future — is not available, because the future has not happened yet. So engineers reach for *proxies*: cheap, computable numbers that stand in for the unavailable truth. And when one proxy disappoints, the instinct is universal and almost irresistible: *combine two proxies*. Surely two opinions are better than one.

This article is about a small, sharp piece of mathematics that says: for a large and natural class of "combine two proxies" schemes, adding the second opinion does not just fail to help. It provably, monotonically **hurts** — and the amount by which the best possible combination still falls short of perfect foresight is a property of the *data*, invisible to any amount of clever reweighting.

---

## The setup, stripped to its bones

Imagine $n$ items and a cache with room for $B$ of them. Each item $i$ has a **true value** $v(i)$: how much would be gained by keeping it. Nobody can see $v$ — it depends on requests that have not arrived.

What *is* visible are cheap signals. Two are standard:

- **Accumulated usage** $a(i)$: how heavily item $i$ has been used so far. (In a language model, this is the running total of attention that has flowed to a token — the signal behind "heavy hitter" cache policies.)
- **A static content probe** $p(i)$: a score computed from the item's content alone by a small, cheap predictor, without any usage history.

The scheme under the microscope is the most natural way to fuse them, the **additive hybrid**:

$$
s_\lambda(i) \;=\; a(i) \;+\; \lambda \cdot p(i),
$$

where $\lambda \ge 0$ is a knob controlling how much weight the content probe gets. Set $\lambda = 0$ and you get pure usage. Crank $\lambda$ up and content takes over. The policy is then the obvious one: **keep the $B$ highest-scoring items, evict the rest.**

Formally, we say a set $S$ of size $B$ is a *top set* for a score $s$ if no evicted item outscores any kept item: $s(j) \le s(i)$ for every kept $i \in S$ and every evicted $j \notin S$. What we care about is the **retained value**

$$
R(S) \;=\; \sum_{i \in S} v(i),
$$

the true worth of what survived. The **oracle** is the policy that scores with $v$ itself — the one that cheats by knowing the future.

The measurement that started this was a sweep over $\lambda$ on a small language model with a $1024$-token context. The numbers came out like this (retained fraction of the true value, budget $B$ slots):

| $B$ | $\lambda$ | retained |
|---|---|---|
| 64 | 0.00 | **0.9384** |
| 64 | 0.25 | 0.9383 |
| 64 | 1.00 | 0.9365 |
| 64 | 4.00 | 0.9344 |
| 32 | 1.00 | 0.9189 |
| 128 | 1.00 | 0.9544 |

Read the top block. As the probe gets more weight, the score gets *worse*, every single time, without a bump or a plateau. The best member of the whole family is the one that ignores the probe completely. And every member sits about $5.7$ percentage points below what an oracle achieves at the same budget.

Three things could have been true, and were written down in advance: (P1) *some* positive $\lambda$ beats $\lambda = 0$; (P2) $\lambda = 0$ is optimal; (P3) the best hybrid still trails the oracle by a wide margin. P1 was refuted. P2 and P3 were confirmed. The interesting part is not the table. The interesting part is that all three outcomes turn out to be *theorems* about the shape of the family, not accidents of one experiment.

---

## The exchange kernel: one lemma to rule them

Everything below rests on a single, disarmingly simple observation about swapping.

Suppose $S$ and $T$ are two candidate cache contents of the same size. They overlap somewhere; the disagreement lives in the two halves of their symmetric difference, $T \setminus S$ (things $T$ keeps and $S$ drops) and $S \setminus T$ (things $S$ keeps and $T$ drops). Because $S$ and $T$ have the same size, these two halves have the same size too.

> **Exchange Kernel.** If every item that $T$ keeps but $S$ drops is worth at most every item that $S$ keeps but $T$ drops, then $R(T) \le R(S)$.

The proof is three lines and uses no combinatorial machinery at all — no matching, no Hall's theorem, no bipartite argument. Take $j_0$, the *most* valuable element of $T \setminus S$, and $i_0$, the *least* valuable element of $S \setminus T$. By hypothesis $v(j_0) \le v(i_0)$. Then

$$
\sum_{j \in T \setminus S} v(j) \;\le\; |T\setminus S| \cdot v(j_0) \;=\; |S \setminus T| \cdot v(j_0) \;\le\; |S \setminus T| \cdot v(i_0) \;\le\; \sum_{i \in S \setminus T} v(i).
$$

The shared part $S \cap T$ contributes identically to both sides and cancels. Done. If the domination is strict and the sets genuinely differ, the conclusion is strict too.

That "$=$" in the middle — the equality of the two half-sizes — is where the fixed budget does its work. This is why the whole theory is about *matched budgets*: comparisons between caches of different sizes are a different game.

---

## Consequence 1: nothing beats the oracle, and it's not about your signal

Feed the exchange kernel the crudest possible input. Let $O$ be the oracle's top set, and let $S$ be the top set of *any* score $s$ whatsoever, at the same budget. Every item in $S \setminus O$ was rejected by the oracle, and every item in $O \setminus S$ was accepted, so by definition $v(j) \le v(i)$ for $j \in S \setminus O$, $i \in O \setminus S$. The kernel fires:

> **Universal Oracle Bound.** For every score function $s$ and every budget $B$, the top-$B$ set of $s$ retains no more true value than the oracle's top-$B$ set.

This sounds like a triviality, and in a sense it is — but note what the proof *did not use*. It used nothing about $s$. Not that it is a usage counter, not that it is a probe, not that it is a sum of the two, not that it is smooth or bounded or trained on anything. Accumulation, recency, content probes, and every linear combination of them are all the same object to this argument: a function $\iota \to \mathbb{R}$.

That is the first half of the law the experiments kept bumping into. The $5.7$-point gap is not a deficiency of any particular cheap signal. It is a property of the *instance* — of how badly the observable world happens to correlate with the unobservable one — and no reweighting can touch it. Enriching the signal family cannot cross the oracle line, because the line was drawn without ever looking at the family.

---

## Consequence 2: the sweep is a one-dimensional path, and it only goes one way

Now the sharper statement. Why should the response to $\lambda$ be *monotone*, rather than wobbling around with some lucky peak in the middle?

Here is the mechanism, and it is beautiful. Take two weights $\lambda_1 < \lambda_2$, with kept sets $S_1$ and $S_2$. Suppose item $j$ *entered* the cache when we raised the weight ($j \in S_2 \setminus S_1$) and item $i$ *left* ($i \in S_1 \setminus S_2$). Being top sets gives us two inequalities:

$$
a(j) + \lambda_1 p(j) \;\le\; a(i) + \lambda_1 p(i), \qquad a(i) + \lambda_2 p(i) \;\le\; a(j) + \lambda_2 p(j).
$$

Add them and cancel the $a$'s: $(\lambda_2 - \lambda_1)\,(p(j) - p(i)) \ge 0$, hence $p(i) \le p(j)$.

> **Single-Crossing Lemma.** When the probe weight goes up, every item that enters the cache has a probe score at least as high as every item that leaves.

Each pair of items crosses at most once, and always in the same direction. Turning the knob "up" *only ever* trades usage-heavy items for probe-heavy items — never the reverse. The $\lambda$-sweep is not an exploration of policy space; it is a **one-dimensional monotone path** through it, with two conserved directions of motion: the total probe mass of the cache never decreases, and (for $\lambda \ge 0$) the total usage mass never increases. You buy probe with usage, at a fixed exchange rate that only ever moves one way.

Now suppose the probe is *anti-aligned* with the truth: whenever $p(i) \le p(j)$ we also have $v(j) \le v(i)$ — a higher probe score never indicates a more valuable item. Chain this with the single-crossing lemma: entering items have higher probe, therefore lower value than leaving items. Feed that into the exchange kernel. Out drops:

> **Monotone Degradation Law.** If the content probe is anti-aligned with true value, then retained value is non-increasing in the probe weight: $R(S_{\lambda_2}) \le R(S_{\lambda_1})$ whenever $\lambda_1 < \lambda_2$. If the anti-alignment is strict and the kept set actually changes, the drop is strict.

Setting $\lambda_1 = 0$: **the pure-usage arm is optimal in the entire family.** P1 refuted, P2 confirmed, as theorems.

---

## The knob was never really the knob

A reasonable objection: the experiment did not combine $a$ and $p$ raw. It combined their *z-scores*, $z(a) + \lambda \, z(p)$, each signal centred and scaled. Does the standardization change anything?

No — and this is worth spelling out, because it is a common source of confusion. A top-$B$ set depends only on the *ordering* the score induces, and orderings are invariant under increasing affine maps: for $c > 0$, the top sets of $c\,s + d$ are exactly the top sets of $s$. Unfolding the z-scores,

$$
\frac{a(i)-\mu}{\sigma} + \lambda\,\frac{p(i)-\nu}{\tau} \;=\; \frac{1}{\sigma}\Big( a(i) + \tfrac{\lambda\sigma}{\tau}\,p(i) \Big) \;+\; \text{const},
$$

so the z-scored hybrid at weight $\lambda$ is *exactly* the raw hybrid at weight $\lambda\sigma/\tau$. Since $\sigma, \tau > 0$, this reparametrization is increasing: it renames the points of the path but does not reorder them. Every statement above survives verbatim.

A companion observation: a *constant* probe is completely inert. It shifts every score by the same amount and changes no kept set at any weight. So the degradation is caused by the probe's *variation* — by what it actually says — and not by the mere act of appending a second term.

---

## The sharpness: this is a verdict on the probe, not on addition

It would be easy to over-read the degradation law as "additive hybrids are a bad idea." That reading is wrong, and there is a two-item counterexample to prove it.

Take $B = 1$ and two items. Usage says $a = (1, 0)$; the probe says $p = (0, 1)$; the truth is $v = (0, 1)$. Here the probe is *aligned* with value precisely where usage is wrong. At $\lambda = 0$ the policy keeps item $0$ and retains $0$. At $\lambda = 2$ it keeps item $1$ and retains $1$. Positive probe weight **strictly helps**.

So the anti-alignment hypothesis is not removable, and that is exactly the point: the additive form is innocent. What the monotone degradation says is that *this particular probe*, on *this particular workload*, carries information that is anti-correlated with what the cache actually needs — and the additive machinery faithfully transmits that fact into a monotone decline. A probe carrying real signal would announce itself as a positive-$\lambda$ improvement. Silence in the sweep is a measurement of the probe, not a limitation of the fusion.

---

## The calibrated miniature

The whole phenomenon fits on four items. Let $a = (4,3,2,1)$ and $p = (8,6,4,2)$ — two genuinely different signals (they separate the first pair by $1$ and by $2$ respectively), but ordering the items the same, misleading way. Let the true values be

$$
v = (0.4692,\; 0.4692,\; 0.4977,\; 0.4977),
$$

and set the budget to $B = 2$.

For *every* $\lambda \ge 0$ the hybrid score $a + \lambda p$ is strictly decreasing in the index, so — and this is a small lemma worth stating, since it also certifies that the measured arm has no tie-breaking freedom — **a strictly ordered score forces the kept set to be the initial segment**. The hybrid keeps $\{0,1\}$ and retains exactly $0.9384$. The oracle keeps $\{2,3\}$ and retains exactly $0.9954$. The gap is exactly $0.0570$: **5.7 points, uniformly in $\lambda$**, matching the measurement to four decimal places.

The one knob that *does* work in this model is memory. With non-negative values, the oracle's retained value is monotone in the budget — enlarging the cache can only help, since any optimal small cache can be padded up to a larger set and the oracle at the larger budget beats that. The measured rows $0.9189 < 0.9384 < 0.9544$ for $B = 32, 64, 128$ are this monotonicity showing through. Buy slots, not scores.

---

## The deeper reason: an adversary with one spare item

The static picture — pick $B$ slots once — explains the shape of the sweep. But caches are sequential: a stream of requests arrives, and you fault whenever the requested item is absent, at which point you must bring it in and evict exactly one resident.

Here there is a second, harsher bound, and it is *structural*: it explains why no online cheap signal, however clever, can be the answer.

Suppose the workload has just $B + 1$ live items competing for $B$ slots — a single item too many. An **adaptive adversary** watches your deterministic eviction rule, whatever it is, and simply requests the item you just threw away. Every single request is a fault. On a stream of length $m$, you pay $m$.

Now look at the same stream with hindsight. On a fault, evict an item that will not be requested in the next $B-1$ steps — such an item always exists, because at most $B-1$ distinct items can appear in $B-1$ steps and the cache holds $B$. After that eviction the cache contains everything except the victim, so the next $B-1$ requests are guaranteed hits. Each fault therefore buys $B$ fault-free steps, giving a total $k$ of faults with

$$
k \cdot B \;<\; m + B, \qquad \text{i.e.} \quad k \le \lceil m / B \rceil.
$$

> **Factor-$B$ Separation.** For every deterministic eviction rule and every horizon $m$, there is a request stream of length $m$ on which the rule faults on *every* request, while some schedule for the same stream faults at most $\lceil m/B \rceil$ times.

And the additive hybrid family — "evict the resident item of least $a + \lambda p$" — is a deterministic eviction rule, for every $\lambda$. So it inherits the bound, uniformly. The pure-usage arm inherits it. A perfect content probe inherits it. A learned online predictor inherits it. The gap is not a fact about the quality of the score; it is a fact about not knowing the future, and the adversary needs only one item more than you have slots to expose it.

---

## What it all means

Three levels of "you cannot get there from here," stacked:

1. **No score can beat the oracle at matched budget.** The bound never inspects the score, so no enrichment of the signal family crosses it. The size of the gap belongs to the instance.
2. **Within an additive hybrid family, the sweep is a monotone path.** Single crossing means each pair of items exchanges at most once, always toward the probe. With an anti-aligned probe, the response is monotonically decreasing and the pure-usage endpoint is optimal — and this is a verdict on the probe, since an aligned probe demonstrably helps.
3. **Sequentially, every deterministic rule is a factor $B$ from hindsight.** One spare item suffices to force total failure against an adaptive adversary.

What survives? Not clever scores. The routes that remain open are *structural*: improve the quality of the usage tracking itself, or accept oracle-only numbers as upper bounds and report them honestly as such — or, simply and unromantically, buy more slots, the one knob that provably moves the needle.

There is something bracing about a negative result this clean. A whole family of engineering ideas — "let's blend in a content signal, let's tune the weight, let's grid-search $\lambda$" — is not merely reported to have failed on one benchmark. It is shown to be a single monotone curve, and told in advance which end of the curve is best. That is worth more than a better number. It tells you where to stop looking.
