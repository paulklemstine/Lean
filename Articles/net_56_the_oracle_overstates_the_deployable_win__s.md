# The Oracle's Discount: Why Hindsight Compresses Memory Better Than Any Live Algorithm Can

## A cheap-looking bargain

Every large language model carries a growing suitcase. As it reads, it stores a
key–value record for each token it has seen, and every new token it produces
must consult that entire pile. Double the conversation and you double the
memory; double it again and the memory bill doubles again. This suitcase — the
*KV cache* — is now the dominant cost of serving long-context models, and the
obvious question is whether most of it can simply be thrown away.

The evidence that it can is genuinely striking. Take a trained model, run it on
real text, and record the full attention matrix: for each query position $t$ and
each earlier key position $j$, the probability $w_t(j)$ that $t$ places on $j$.
These rows sum to $1$. Then ask: if I had been allowed to keep only $B$ of the
$n$ keys, how much of each row's probability mass would survive?

If you answer that question *after* looking at the row — keeping, for each row,
the $B$ keys it actually attends to most — the answer is embarrassing. On a
small modern model with a context of $1024$ tokens, keeping just $32$ keys per
row retains

$$0.9913$$

of the attention mass. At $64$ keys it is $0.9953$. Ninety-nine point five
percent of a row's attention lives in six percent of its context. Attention, it
seems, is almost entirely concentrated, and a thirty-fold memory reduction costs
essentially nothing.

That number, reproduced to four decimal places across independent runs, is real.
It is also *unbuyable*. This article is about the precise sense in which it is
unbuyable — and about a theorem which says that the gap between the hindsight
number and anything a deployed system can achieve is not a gap of a few points
that better engineering will close, but the largest gap arithmetically possible.

## Two selectors, one budget

Call a **cache** a set $S$ of at most $B$ key positions drawn from $\{0,\dots,n-1\}$.
The **retention** of a cache on row $t$ is the attention mass it preserves:

$$\mathrm{kept}(t, S) \;=\; \sum_{j \in S} w_t(j).$$

Because each row is a probability distribution, retention lies in $[0,1]$, and
$1$ means nothing was lost.

The **oracle** is the best possible retention at budget $B$:

$$\mathrm{oracle}(t) \;=\; \max_{|S| \le B,\; S \subseteq \{0,\dots,n-1\}} \mathrm{kept}(t, S).$$

The maximum ranges over every admissible cache, and — crucially — it is taken
*after* row $t$ is revealed. The oracle picks the cache for a query it has
already read. That is what makes $0.9953$ achievable, and it is also, of course,
impossible: in a real system the cache must exist *before* the query arrives.

So define the honest object. A **causally honest policy** $P$ is a rule that, at
each row $t$, produces an admissible cache using only rows strictly earlier than
$t$. Formally, two demands: $P(w,t)$ always has at most $B$ keys from the
context, and if two attention matrices $w$ and $w'$ agree on all rows $r < t$,
then $P(w,t) = P(w',t)$. That second clause is the entire content of the word
"deployable". It is what every real eviction scheme satisfies, because a real
scheme cannot read the future.

The measurement that started this story compared the two on identical data at
identical budgets. The most widely used honest heuristic is the *heavy hitter*:
score each key by the attention it has accumulated so far,

$$\mathrm{acc}_t(j) \;=\; \sum_{r < t} w_r(j),$$

and keep the $B$ highest scorers. At $B = 64$ it retained $0.8822$, against the
oracle's $0.9953$. Eleven and a third points of daylight. A hybrid — half the
budget to heavy hitters, half reserved for the most recent keys — closed some of
it, reaching $0.9384$, but no arm of the experiment ever reached the $0.95$ that
had been pre-registered as the threshold for "deployable win". Even a cache of
$128$ keys, an eighth of the whole context, topped out at $0.9605$.

The question is whether $11.3$ points is a measurement of tuning laziness or of
something structural.

## The impossibility

It is structural, and the structure is embarrassingly simple once you see it.

Fix any $n$, any budget $B < n$, and any number $T$ of preceding rows. Consider
this family of attention matrices, indexed by a target key $j_0 < n$: every row
before the last is *uniform*, placing mass $1/n$ on each of the $n$ keys; the
final row $T$ is a *one-hot*, placing all its mass on $j_0$ and nothing
elsewhere. Every row is a legitimate probability distribution. Call this
instance $\mathrm{adv}(j_0)$.

Two observations finish the argument.

**The oracle wins outright.** On $\mathrm{adv}(j_0)$, the singleton cache
$\{j_0\}$ is admissible whenever $B \ge 1$, and it retains all of the final
row's mass. So the oracle retains exactly $1$, at every budget from $1$ upward.

**Every honest policy can be made to lose outright.** The instances
$\mathrm{adv}(0), \mathrm{adv}(1), \dots, \mathrm{adv}(n-1)$ are *identical on
every row before the last*. A causally honest policy, by definition, cannot
distinguish them; it must output the same cache $S$ on all of them. But $S$ has
at most $B < n$ elements, so some $j_0 < n$ is missing from it. On that
instance, the policy retains

$$\sum_{j \in S} w_T(j) \;=\; 0.$$

Put them together:

> **Theorem (The oracle overstates the deployable win).** For every $n$, every
> budget $B$ with $1 \le B < n$, and every causally honest policy $P$, there is
> an instance on which the oracle retains $1$ and $P$ retains $0$. The
> oracle-to-policy gap is exactly $1$.

One hundred points. Not eleven. The measured gap is the *mild* version of a
separation that is, in the worst case, total. And no cleverness is exempt:
heavy hitters, pure recency, the hybrid, anything with a learned importance
head, anything at all — the theorem quantifies over all honest policies at once,
so any scheme you can actually deploy is covered by it before you have written
a line of it.

## It isn't bad luck

A natural objection: the adversary chose one nasty instance out of $n$: surely a
policy is fine on average? It is not fine enough. Sum the policy's retention
across the whole family. Because the policy outputs the same set $S$ on all
$n$ instances, its retention on $\mathrm{adv}(j_0)$ is $1$ when $j_0 \in S$ and
$0$ otherwise. So

$$\sum_{j_0 = 0}^{n-1} \mathrm{kept}\big(T, P(\mathrm{adv}(j_0))\big) \;=\; |S| \;\le\; B,$$

and the *average* retention over the family is at most $B/n$ — the budget
fraction, nothing more — while the oracle sits at $1$ throughout. Keeping six
percent of the context buys you six percent of the mass, on average, against a
hindsight selector that keeps essentially all of it.

Nor does randomness rescue anything. Suppose you flip coins and mix a whole
portfolio of honest policies with probabilities $q_i$ summing to one. Averaging
the bound above across the mixture and then across the family — the classical
minimax-averaging trick — produces a single instance $\mathrm{adv}(j_0)$ on
which the *expected* retention of the randomised policy is at most $B/n$. The
obstruction is informational, not a symptom of determinism.

This is the sentence the whole programme reduces to: **trained attention is
prunable in retrospect, not predictable in advance.** Accumulated attention
probability is a biased estimator of future importance, and the reason is not
that it is a bad statistic. It is that *no* function of the past is an unbiased
one.

## What would have to be true instead

The impossibility is a statement about what a policy cannot know. Turn it
around: what *assumption* would let hindsight transfer?

Here the mathematics is exact and rather pretty. Suppose you rank keys not by
the true future row but by any score $s$ — the accumulated attention, a learned
importance head, whatever — and take the top $B$. Say the score is
**consistent** with the row if it never contradicts it: whenever
$s(k) \le s(j)$, also $w_t(k) \le w_t(j)$. Then:

> **Theorem (Consistency is exactly what is needed).** If the score is
> consistent with the served row, the score-ranked cache *is* an optimal cache:
> its retention equals the oracle's.

The proof is an exchange argument. If the top-$B$-by-score set $H$ and a rival
cache $S$ differ, every key that $S$ holds and $H$ does not is out-scored by
some key that $H$ holds and $S$ does not; consistency converts "out-scored" into
"carries no more attention mass", and swapping them one at a time can only
improve $H$. A counting step — $H$ is as large as any admissible $S$ — guarantees
there are enough partners to swap with.

Real scores are not perfectly consistent, and the argument degrades gracefully.
Say the score is **$\varepsilon$-consistent** if $s(k) \le s(j)$ forces
$w_t(k) \le w_t(j) + \varepsilon$; that is, an inversion costs at most
$\varepsilon$ of misjudged mass. Then

$$\mathrm{oracle}(t) \;\le\; \mathrm{kept}\big(t, \text{top-}B\text{-by-}s\big) \;+\; B\varepsilon .$$

The whole deployment question collapses into a single scalar, the *consistency
defect* $\varepsilon$. And the price is **exact**, not merely an upper bound: on
the instance where the $B$ top-scoring keys happen to carry weight $0$ while
every other key carries $\varepsilon$, the oracle collects exactly $B\varepsilon$
and the score-ranked cache collects exactly $0$. So no sharper conversion of
score quality into retention exists. Notice also what the price is *not*
proportional to: it scales with the cache size $B$, not with the context length
$n$. The correction a deployment table needs is a function of how much you keep,
not of how much you read.

There is a companion form of the same statement that names the hidden
assumption behind heavy hitters directly. If the served row is an
order-preserving affine image of the accumulated score — $w_t(j) = c \cdot
\mathrm{acc}_t(j) + d$ with $c \ge 0$, a *stationarity* hypothesis — then the
heavy-hitter cache is exactly the oracle cache. If the row is within
$\varepsilon/2$ of such an image, heavy hitters lose at most $B\varepsilon$.
That is precisely the assumption the heavy-hitter literature makes silently, and
the measured $11.3$ points are the price of its being false.

## Why hybrids, and why they are forced

The experiment found something else worth explaining: adding a recency reserve
to heavy hitters helped at *every* budget, by $5.7$, $5.6$, and $4.2$ points at
$B = 32, 64, 128$. Is that a tuning fact or a structural one?

Structural, and two two-line examples show it. Consider:

- the **stale** instance, where every early row hammers key $0$, but the row you
  must serve attends the *current* key $n-1$;
- the **pinned** instance, where every row, including the one you serve, attends
  the same old key $0$.

Pure accumulation retains $0$ on stale (it has spent its whole budget on key $0$
and evicted the only key that matters) and $1$ on pinned. Pure recency retains
$1$ on stale and $0$ on pinned (the key it needs is the oldest one, the first
thing recency throws away). So neither heuristic dominates the other, and the
failure is not marginal: on each family the loser retains nothing at all.

Now split the budget: $a$ keys by accumulated score, $b$ keys by recency. Such a
split retains everything on *both* families precisely when $a \ge 1$ and
$b \ge 1$. If $b = 0$ it loses the stale family completely; if $a = 0$ it loses
the pinned family completely. The hybrid is not a hyperparameter — it is the
unique shape of policy that survives both diagnostics, which is why it wins at
every budget in the table.

And yet the hybrid is still a causally honest policy. It therefore inherits the
impossibility theorem word for word: there are instances on which it retains
$0$ while the oracle retains $1$. Hybridisation reshuffles which failure modes
you suffer; it does not exempt you from having any. That, in structural form, is
why the pre-registered $0.95$ target failed and why buying a bigger cache did
not save it.

## Three escape routes, all closed

Once you have the theorem, the natural engineering responses can be checked
against it directly.

**"Evict in blocks, not individual keys."** Real systems page memory in blocks
of, say, $128$ keys. Does coarser granularity change anything? Lift the oracle
to block granularity — it may only choose whole blocks — and on the adversarial
family it still retains everything, because the block containing $j_0$ is itself
an admissible cache. Every causal policy still retains nothing. The wall is
causality, not granularity.

**"Allocate budget cleverly across layers."** A transformer has many attention
layers, and one can imagine spending a global budget where it does the most
good. Optimal allocation of a total budget $B$ across two layers with loss
curves $f$ and $g$ is exactly a *min-plus convolution*,

$$(f \oplus g)(B) \;=\; \min_{0 \le a \le B} \big( f(a) + g(B-a) \big),$$

the tropical-algebra operation that also governs shortest paths and scheduling.
Suppose each layer's deployable loss exceeds its oracle loss by at least
$\delta$. Then the optimally allocated two-layer loss exceeds the optimally
allocated oracle loss by at least $2\delta$ — and by induction, over $L$ layers,
by at least $L\delta$. The per-layer policy penalty passes straight through the
optimisation. Reallocating budget cannot recover the gap; it accumulates, once
per layer.

**"Use a bigger budget."** At $B = n$ the whole context is admissible and the
gap is, trivially, zero: the oracle's advantage is exactly the advantage of
choosing, and there is nothing to choose when you keep everything. The theorem's
hypothesis $B < n$ is therefore necessary — and it is also the only regime
anyone cares about.

## What to do with this

The practical instruction is short and unglamorous. **Oracle retention curves
are upper bounds, not forecasts.** A published table showing $99\%$ retention at
a $32$-key cache is a true statement about the *compressibility* of trained
attention and a false statement about the *deployability* of a $32$-key cache.
The two differ by a quantity that has a name and a formula: the consistency
defect $\varepsilon$ of whatever score you actually use, multiplied by the
budget $B$, and then again by the number of layers.

The optimistic reading is that this is measurable. The defect is a per-row
maximum over inversions in a matrix that the oracle arm already materialises;
computing it requires no retraining and no new kernels. If the defect of
accumulated attention on trained models turns out to be $O(1/B)$, the observed
retention band is forced, and oracle tables become usable after a
one-parameter correction. The open question is not whether the gap exists — it
provably does, and in the worst case it is total — but why trained attention is
kind enough to make it eleven points instead of a hundred, and whether that
kindness can be certified while the model is running rather than confirmed after
the fact.

There is a wider moral here, one that shows up whenever we measure a system by
what it *could* have done. Compressibility in hindsight and predictability in
advance are different quantities, and the first is systematically the more
flattering. The suitcase really does contain mostly air. Knowing which parts are
air, before you open it, is a different problem — and the mathematics says it is
one you cannot solve for free.
