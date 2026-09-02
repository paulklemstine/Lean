# Hindsight Is Not a Forecast
### A guided tour of the oracle-to-policy barrier in attention-cache eviction

---

## 1. The suitcase that is mostly air

A language model reading a long document carries a growing suitcase. For every token it has
seen, it stores a key–value record, and every new token it produces must consult the whole
pile. Double the context, double the memory. This is now the dominant cost of serving
long-context models, and the obvious remedy is to throw most of the suitcase away.

The evidence that you can is genuinely startling. Run a trained model, record the attention
matrix — for each query row $t$ and each key $j$, the probability $w_t(j)$ that $t$ places on
$j$, with $\sum_j w_t(j) = 1$ — and ask: if I kept only $B$ of the $n$ keys, how much of each
row's mass would survive? Define the **retention** of a cache $S$ as

$$\mathrm{kept}(t, S) = \sum_{j \in S} w_t(j) \in [0, 1].$$

Answer that question *after* reading the row, keeping the $B$ heaviest keys, and on a real
model at context $1024$ you get $0.9913$ at $B = 32$ and $0.9953$ at $B = 64$. Ninety-nine and a
half percent of a row's attention lives in six percent of its context.

Hold onto that number. The entire tour is about the gap between it and anything you can
actually deploy.

---

## 2. Two selectors, one budget

Everything hinges on a single distinction, and it is worth stating precisely before we play
with it.

An **admissible cache** is a set $S \subseteq \{0, \dots, n-1\}$ with $|S| \le B$. The
**oracle** is the best retention available at that budget,

$$\mathrm{oracle}(t) = \max_{|S| \le B} \mathrm{kept}(t, S),$$

with the maximum taken *after* row $t$ is revealed. A **causally honest policy** $P$ is a rule
that, at each row $t$, returns an admissible cache computed from rows strictly earlier than
$t$: if two attention matrices agree on all rows $r < t$, the policy must return the same cache
on both. That second clause is the whole meaning of the word "deployable".

Three honest policies matter here. The **heavy hitter** scores each key by the attention it has
accumulated, $\mathrm{acc}_t(j) = \sum_{r < t} w_r(j)$, and keeps the top $B$. **Recency** keeps
the $B$ newest keys. The **hybrid** splits the budget between the two.

The sandbox below lets you drive all of them. Start with the *trained-like* family and a
comfortable budget: everything looks fine. Then switch the family to *adversarial* and press
the button.

{{interactive_demo:0}}

<details>
<summary><b>What just happened? — the counting argument in full</b></summary>

Fix a budget $B < n$ and consider $n$ instances indexed by a target key $j_0$: every row before
the last is uniform ($1/n$ on each key), and the last row is a one-hot at $j_0$. Every row is a
legitimate probability distribution.

*The oracle wins outright.* The singleton $\{j_0\}$ is admissible whenever $B \ge 1$ and captures
the whole served row, so $\mathrm{oracle}(T) = 1$ on every instance.

*Every honest policy can be made to lose outright.* All $n$ instances are **identical on every
row before the last**. A causal policy reads only those rows, so it must output the *same*
cache $S$ on all of them. Since $|S| \le B < n$, some $j_0$ is missing from $S$, and on that
instance the policy retains $\sum_{j \in S} w_T(j) = 0$.

> **Theorem.** For every $n$, every $1 \le B < n$, and every causally honest policy $P$, there is
> an instance on which the oracle retains $1$ and $P$ retains $0$. The oracle-to-policy gap is
> exactly $1$ — the maximum arithmetically possible.

And it is not bad luck. Summing over the family, the policy's retention on instance $j_0$ is the
indicator $\mathbf{1}[j_0 \in S]$, so

$$\sum_{j_0 < n} \mathrm{kept}\big(T, P(\mathrm{adv}(j_0))\big) = |S| \le B,$$

and the average retention is at most $B/n$ — the budget fraction and nothing more — against an
oracle value of $1$ everywhere. Randomising does not help either: average the bound over any
finite mixture of causal policies and then over the family, and some single instance still holds
the *expected* retention below $B/n$. That is the classical
[minimax averaging argument](https://en.wikipedia.org/wiki/Yao%27s_principle), and it says the
obstruction is informational, not a symptom of determinism.

</details>

The one-line summary, which will be worth repeating: **trained attention is prunable in
retrospect, not predictable in advance.**

---

## 3. Seeing both numbers at once

Before going further, it helps to put the measurement and the theorem side by side. On the left
is what was actually observed on a trained model; on the right is what is provable in the worst
case.

{{visualization:0}}

The measured table behind the left panel:

| arm | $B=32$ | $B=64$ | $B=128$ |
|---|---|---|---|
| oracle (per-row top-$k$) | $0.9913$ | $0.9953$ | — |
| accumulated heavy hitters | $0.8633$ | $0.8822$ | $0.9189$ |
| hybrid (heavy hitters + recency) | $0.9205$ | $0.9384$ | $0.9605$ |

Three pre-registered predictions were tested. That the gap at matched budget would exceed two
points: **confirmed**, at $11.31$. That a recency reserve would help: **confirmed**, by $5.7$,
$5.6$ and $4.2$ points. That some deployable arm would reach $0.95$ at $B = 64$: **refuted** —
the best was $0.9384$, and even a cache of an eighth of the context stopped at $0.9605$.

So the measured gap is eleven points and the provable gap is a hundred. Both facts are real, and
the distance between them is the interesting scientific question. What makes trained attention
kinder than the worst case?

---

## 4. The positive half: what would have to be true

The impossibility says what a policy cannot know. Turn it around and ask what *assumption* would
make hindsight transfer. The answer is exact and rather pretty.

Rank keys by any score $s$ — accumulated attention, a learned head, anything — and keep the top
$B$. Call the score **consistent** with the served row if it never contradicts it: whenever
$s(k) \le s(j)$, also $w_t(k) \le w_t(j)$.

> **Theorem.** If the score is consistent with the served row, the score-ranked cache *is* an
> optimal cache: its retention equals the oracle's.

Real scores are imperfect, and the degradation is graceful. Call the score
**$\varepsilon$-consistent** if $s(k) \le s(j)$ only forces $w_t(k) \le w_t(j) + \varepsilon$. Then

$$\mathrm{oracle}(t) \le \mathrm{kept}\big(t, \mathrm{top}_B(s)\big) + B\varepsilon .$$

The whole deployment question has collapsed into one scalar. Play with it.

{{interactive_demo:1}}

<details>
<summary><b>Click to reveal the exchange argument</b></summary>

Let $H = \mathrm{top}_B(s)$ and let $S$ be any admissible cache. Split both retentions along the
common part $S \cap H$: those terms are identical and cancel, so only $S \setminus H$ against
$H \setminus S$ matters.

Every key of $\mathrm{top}_B(s)$ out-scores every key outside it, so for
$k \in S \setminus H$ and $j \in H \setminus S$ we have $s(k) \le s(j)$, and
$\varepsilon$-consistency upgrades this to $w_t(k) \le w_t(j) + \varepsilon$. Choosing $j_0$ to
minimise $w_t$ on $H \setminus S$ gives

$$\sum_{k \in S \setminus H} w_t(k) \le |S \setminus H| \cdot \big(w_t(j_0) + \varepsilon\big).$$

The cardinality identity $|S \setminus H| + |S \cap H| = |S| \le |H| = |H \setminus S| + |H \cap S|$
gives $|S \setminus H| \le |H \setminus S|$ — there are always enough partners to swap with — and
minimality of $j_0$ gives $|H \setminus S| \, w_t(j_0) \le \sum_{H \setminus S} w_t$. Collecting
terms, $\mathrm{kept}(t,S) \le \mathrm{kept}(t,H) + |H|\varepsilon$. Take the maximum over $S$.

With $\varepsilon = 0$ this is exact optimality, and it also proves the oracle's own problem is
trivial: the best cache for a *known* row is just its $B$ largest entries. Retrospective pruning
is a one-line greedy — which is precisely why the oracle number is so easy to quote.

</details>

<details>
<summary><b>Click to reveal why the price cannot be improved</b></summary>

Take the score $s(j) = -j$, so the top-$B$ set is $\{0, \dots, B-1\}$, and the row that gives
weight $0$ to exactly those keys and weight $\varepsilon$ to every other key. The score-ranked
cache retains $0$; the block $\{B, \dots, 2B-1\}$ is admissible and retains $B\varepsilon$. Any
two weights differ by at most $\varepsilon$, so the instance genuinely is $\varepsilon$-consistent
and the guarantee applies — with equality.

Two consequences worth carrying away. First, no sharper conversion of score quality into
retention exists, so $B\varepsilon$ is *the* deployment correction rather than *a* bound on it.
Second, the correction scales with the **cache size** $B$, not with the context length $n$: what
you must discount depends on how much you keep, not on how much you read.

</details>

There is a companion statement that names the hidden assumption behind heavy hitters directly.
If the served row is an order-preserving affine image of the accumulated score,
$w_t(j) = c \cdot \mathrm{acc}_t(j) + d$ with $c \ge 0$ — call this **stationarity** — then the
heavy-hitter cache is exactly the oracle cache; and if the row is within $\varepsilon/2$ of such
an image, it loses at most $B\varepsilon$. That is what the heavy-hitter literature assumes
silently, and the measured $11.3$ points are the price of its being false.

---

## 5. Turning the theory into a computation

Two of these ideas are directly executable. The first computes the oracle's optimal cache by the
exchange lemma and the consistency defect of whatever score you deploy — the number the whole
deployment correction hangs on.

{{algorithm:0}}

The second is an honest streaming simulator. The subtle part is not the eviction rule but the
*update ordering*: the cache serving row $t$ must be built before row $t$ is folded into the
accumulated score. Get that backwards and you get retained fractions above $1$, which is
impossible for a probability row — a free and very effective correctness gate.

{{algorithm:1}}

---

## 6. Why hybrids win, and why they are still trapped

The measurement found that adding a recency reserve helped at *every* budget. Is that tuning, or
structure? Two examples settle it.

- The **stale** instance: every early row hammers key $0$, but the row you must serve attends the
  *current* key $n-1$.
- The **pinned** instance: every row, including the served one, attends the same old key $0$.

{{visualization:1}}

Pure accumulation retains $0$ on stale and $1$ on pinned. Pure recency retains $1$ on stale and
$0$ on pinned. Neither dominates, and the loser does not merely underperform — it retains
*nothing*. Now split the budget: $a$ slots by accumulated score, $b$ slots by recency. Such a
split retains everything on both families **precisely when $a \ge 1$ and $b \ge 1$**; with
$b = 0$ it loses stale completely, with $a = 0$ it loses pinned completely.

So the hybrid is not a hyperparameter. It is the unique shape of policy that survives both
diagnostics — which is exactly why it wins at every budget in the table. Go back to
{{interactive_demo:0}}, switch to *stale*, and drag the recency slider to zero to watch the
failure happen.

And yet the hybrid is itself causally honest, so the impossibility theorem applies to it word
for word. Hybridisation changes *which* failure modes you suffer. It does not exempt you from
having any. That is the structural reason the $0.95$ target failed and buying a bigger cache
did not save it.

---

## 7. Three escapes, all closed

**"Evict in blocks."** Real systems page memory in blocks of, say, $128$ keys. Lift the oracle to
block granularity — it may only choose whole blocks — and on the adversarial family it *still*
retains everything, because the block containing the target is itself an admissible cache. Every
causal policy still retains nothing. The wall is causality, not granularity.

**"Allocate budget cleverly across layers."** Spending a global budget optimally over layers with
loss curves $f$ and $g$ is exactly a
[min-plus convolution](https://en.wikipedia.org/wiki/Tropical_semiring),

$$(f \oplus g)(B) = \min_{0 \le a \le B}\big(f(a) + g(B-a)\big),$$

the tropical-algebra operation that also governs shortest paths. If each layer's deployable loss
exceeds its oracle loss by $\delta$, the optimally allocated $L$-layer loss exceeds the optimally
allocated oracle loss by $L\delta$. The penalty passes straight through the optimisation, and it
accumulates once per layer.

{{algorithm:2}}

**"Use a bigger budget."** At $B = n$ the whole context is admissible, the oracle has nothing to
choose, and the gap is zero. That is why the hypothesis $B < n$ appears in every statement — and
it is the only regime anyone cares about.

---

## 8. Check it yourself

Everything above is verified numerically here: brute-force oracle against greedy, consistency
attaining the oracle exactly, the $B\varepsilon$ guarantee and its equality case, the
adversarial family and the $B/n$ average, the Yao-style mixture bound, the two diagnostics, the
block-granularity check, the layer accumulation, and the recorded table with its three verdicts.

{{demo:0}}

---

## 9. What to take away

**Oracle retention curves are upper bounds, not forecasts.** A table showing $99\%$ retention at a
$32$-key cache is a true statement about the *compressibility* of trained attention and a false
statement about the *deployability* of a $32$-key cache. The two differ by a quantity with a
name and a formula: the consistency defect $\varepsilon$ of the score you actually use, times the
budget $B$, times the number of layers.

The hopeful part is that $\varepsilon$ is measurable — it is a maximum over inversions in a matrix
the oracle computation already produces, with no retraining and no new kernels. If it turns out
to be $O(1/B)$ on trained models, the observed retention band is forced and oracle tables become
usable after a one-parameter correction. The open question is not whether the gap exists — it
provably does, and in the worst case it is total — but why trained attention is kind enough to
make it eleven points instead of a hundred, and whether that kindness can be certified while the
model is running rather than confirmed after the fact.

There is a wider moral, visible whenever we grade a system by what it *could* have done.
Compressibility in hindsight and predictability in advance are different quantities, and the
first is systematically the more flattering. The suitcase really is mostly air. Knowing which
parts are air, before you open it, is a different problem — and one you cannot solve for free.
