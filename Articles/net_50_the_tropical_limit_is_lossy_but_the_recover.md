# One Key Is Not Enough, Four Almost Are: What Happens When a Language Model Is Forced to Pay Attention to Just One Thing

Every time a modern language model writes a word, it looks back. For each new token it compares a "query" against every earlier token's "key", producing a row of scores $x_1, x_2, \dots, x_n$, one per earlier position. Those scores are turned into weights by the **softmax**,

$$p_i = \frac{e^{x_i}}{\sum_{j=1}^{n} e^{x_j}},$$

and the model reads a weighted average of what the earlier tokens had to say. This operation — *attention* — is the beating heart of the transformer. It is also the reason these models are so hungry for memory: to look back over $n$ tokens, you must keep all $n$ keys and values around, in every layer, in a structure called the KV cache. On a laptop or a small graphics card, that cache, not the model weights, is often what runs out first.

So here is a tempting idea. Look at a typical attention row and you will usually find that a handful of positions carry most of the weight. Why not keep only the strongest few? Or, at the extreme, why not keep only the single strongest one — replace the soft average with a hard pointer?

That extreme has a name in mathematics. It is the **tropical limit**, and this article is about what happens when you take it on a real model, and about a small set of exact inequalities that explain what you see.

## The tropical shadow of the softmax

The denominator of the softmax hides a function with a long pedigree: the **log-sum-exp**,

$$\mathrm{LSE}(x) = \log \sum_{j=1}^{n} e^{x_j}.$$

Log-sum-exp is a "soft maximum". It is always at least as large as the largest score, and at most $\log n$ larger:

$$\max_j x_j \;\le\; \mathrm{LSE}(x) \;\le\; \max_j x_j + \log n.$$

If you sharpen all the scores by a temperature $\varepsilon$ and rescale, $\varepsilon\,\mathrm{LSE}(x/\varepsilon)$, then as $\varepsilon \to 0$ the soft maximum turns into the honest maximum. In that limit addition becomes "max" and multiplication becomes "plus" — the arithmetic of the *tropical semiring*, a world studied by algebraic geometers and optimizers and named, half in jest, after the Brazilian mathematician Imre Simon. Physicists know the same passage as Maslov dequantization: the classical limit of a quantum sum over paths, where only the best path survives.

In attention the tropical limit is exactly the "keep one key" policy. The softmax collapses onto the argmax, and the model points instead of blending.

How far is any given attention row from its tropical shadow? There is a perfectly natural yardstick: the distance between the soft max and the hard max,

$$g = \mathrm{LSE}(x) - \max_j x_j.$$

We call this the **Maslov gap** of the row. It is zero only in the idealized limit where all the weight sits on one key, and it can be as large as $\log n$, which happens when the row is completely flat. It is measured in *nats*, the natural-logarithm cousin of bits.

## The experiment: dial the cache down to one

The experiment behind this article took a pretrained half-billion-parameter language model with 24 layers (Qwen2.5-0.5B) and ran it on natural text, in full 32-bit precision, at three context lengths: 512, 1024 and 2048 tokens. Before measuring anything, the hand-written forward pass was checked to reproduce the reference implementation exactly. Then attention was replaced, in every layer and every head, by an *oracle top-$k$* version: for each row, keep only the $k$ highest-scoring keys, renormalize the softmax over them, and throw the rest away. Quality was scored on a held-out final tenth of the text as a **retention** number — $1$ means indistinguishable from full attention — and the **knee** is the smallest $k$ at which retention reaches $0.98$.

Here is what came back.

| keys kept $k$ | context 512 | context 1024 | context 2048 |
|---|---|---|---|
| $1$ (pure argmax) | $0.364$ | $0.289$ | $0.250$ |
| $2$ | $0.787$ | $0.740$ | $0.700$ |
| $4$ | $0.910$ | $0.891$ | $0.876$ |
| $8$ | $0.962$ | $0.949$ | $0.941$ |
| knee (retention $\ge 0.98$) | $16$ | $32$ | $24$ |

Three things jump out.

**The tropical limit is a catastrophe.** Pointer-only attention keeps between a quarter and a third of the model's behavior. And it gets *worse* as the context gets longer: $0.364$, then $0.289$, then $0.250$.

**The recovery is astonishingly fast.** Adding a single second key more than doubles retention at every context length. Four keys bring the model to roughly $0.88$–$0.91$; eight keys to $0.94$–$0.96$. Each added key buys less than the last: going from one key to two is worth $+0.34$ to $+0.45$, two to four $+0.12$ to $+0.17$, four to eight only $+0.05$ to $+0.07$.

**The knees are perfectly reproducible.** The chain $\{16, 32, 24\}$ matched an earlier sweep run with a different script in a different session, exactly. Because the evaluation is deterministic, the knee is a property of the model and the text, not of the run.

## Why the argmax gets worse with length

Suppose the top score in a row beats every other score by a margin of at least $m$. How much weight is the top key guaranteed? Each of the other $n-1$ keys contributes at most $e^{-m}$ relative to the winner, so

$$p_{\max} \;\ge\; F(m,n) = \frac{1}{1 + (n-1)\,e^{-m}}.$$

Call $F$ the **argmax floor**. It is an exact, if pessimistic, guarantee. And it has two simple properties, both of which can be proved in a line: for a fixed margin it *decreases* as $n$ grows, and it tends to $0$ as $n \to \infty$. A margin that would make a winner dominant among 500 competitors is not enough among 2000; a long context is a crowded room in which even a clearly loudest voice gets drowned out by the murmur of everyone else.

That is the structural reason behind the first observation. Unless the model sharpens its margins in step with $\log n$, a one-key cache must lose more and more as the context grows.

## Gap equals surprise

The Maslov gap turns out to be more than a yardstick. Applied to any key $i$ (not just the winner) define $g_i = \mathrm{LSE}(x) - x_i$. Then, by simply unwinding the definitions,

$$p_i = e^{-g_i}.$$

The softmax weight of a key is exactly $e$ to the minus its gap. At the winner, $e^{-g}$ is precisely the fraction of attention mass that an argmax cache keeps. In information-theoretic language, $g$ is the **min-entropy** of the attention distribution: the "surprise" of its most likely outcome. A row with gap $1.86$ nats keeps only $e^{-1.86} \approx 16\%$ of its mass on the top key.

## A map of where the model is tropical

The experiment measured this gap for every row of every layer, giving a **Maslov-gap map** of the model. Most of the network turns out to be fairly close to tropical. At contexts 512 and 1024 the median gap of the bulk layers lies between $0.17$ and $1.86$ nats — inside $\log 8 \approx 2.08$, which is what you would get if all the mass were spread evenly over eight keys. At 2048 every bulk layer has median gap at most $1.46$.

There is exactly one region that is far from tropical: the last two layers, 22 and 23. Their median gaps are $2.33$ and $2.16$ at 512 tokens, $2.55$ and $2.37$ at 1024, and $2.69$ and $2.52$ at 2048, with the top tenth of rows reaching about $3.4$ nats. These are the model's *diffuse tail*: layers that genuinely average over many positions and drift further from the tropical limit as the context grows.

## A prediction that failed, and the inequality that says why

Before the run, a third prediction had been written down: that the **crystallization loss** — the quantity

$$K = \sum_i p_i (1 - p_i),$$

which is zero for a perfect pointer and grows as attention spreads — would be at most $1/4$ on average. It was not. Layer means came in between $0.34$ and $0.97$.

The interesting part is that the gap map alone already predicts this failure, thanks to a two-sided inequality. Write $C = \sum_i p_i^2$ for the **collision probability** (the chance that two independent draws from the attention pick the same key). Since the weights sum to one, $K = 1 - C$. Now two observations:

- Every weight is at most the largest one, so $C = \sum p_i \cdot p_i \le \sum p_i \cdot p_{\max} = p_{\max} = e^{-g}$.
- The sum of squares is at least its largest term, so $C \ge p_{\max}^2 = e^{-2g}$.

Together they give the **crystallization sandwich**:

$$1 - e^{-g} \;\le\; K \;\le\; 1 - e^{-2g}.$$

(In the language of information theory: the Rényi entropy of order two lies between the min-entropy and twice the min-entropy.) The lower half is exact for a perfectly flat row.

From the lower half it follows that any row with a gap larger than $1/3$ nat has crystallization above $1/4$, because $e^{-1/3} < 3/4$. Turned around: a crystallization budget of $1/4$ would force the gap below $\log(4/3) \approx 0.29$ nat. With bulk medians reaching $1.86$ nats, the prediction never had a chance. Real attention carries a heavy soft tail: individually tiny weights that are collectively load-bearing.

## How many keys does a target really need?

The same two observations become lower bounds on how many keys any cache must hold. Suppose a set $S$ of keys keeps a fraction $\tau$ of the attention mass.

- Since no key weighs more than $e^{-g}$, we need $|S| \cdot e^{-g} \ge \tau$, so $|S| \ge \tau\, e^{g}$. **Key counts grow exponentially with the gap.**
- By the Cauchy–Schwarz inequality, $\tau^2 \le |S| \sum_{i \in S} p_i^2 \le |S|\, C$, so $|S| \ge \tau^2 / C = \tau^2/(1-K)$.

Plug in the measurements. In layer 22 at 2048 tokens the median gap is $2.69$ nats, and $0.98 \cdot e^{2.69} \approx 14.4$. So a row whose top weight is no larger than $e^{-2.69}$ cannot reach 98% of its attention mass with fewer than 13 keys — in fact with fewer than 15. A layer whose crystallization is $0.97$ (collision $0.03$) needs at least $0.98^2 / 0.03 \approx 32.01$, that is, at least 33 keys. These numbers sit squarely in the range of the measured knees $\{16, 32, 24\}$. The diffuse tail alone is enough to explain why the knee is in the tens and not in the single digits.

## Tropical core, thin soft correction

There is a hopeful flip side. If the keys you keep stand clearly above the ones you drop — every dropped score at least $m$ below every kept one — then the mass you lose is small and easy to bound:

$$1 - \text{(kept mass)} \;\le\; \frac{n-k}{k}\, e^{-m},$$

where $k$ is the number of kept keys. The loss decays exponentially in the margin, but grows only linearly in $n$ — which means only logarithmically in the margin needed. And in the log-sum-exp language, the price of truncation is exact: dropping everything outside $S$ lowers the log-sum-exp by precisely $-\log(\text{kept mass})$. For the argmax cache that price is the Maslov gap itself.

This is the picture the data paint. Most layers have a **tropical core** — a few dominant keys — plus a **thin soft correction** that a small number of extra keys absorbs. Pointer-style caches with $k$ between $1$ and $4$ sit well below the knee, but the measured curve says exactly what each additional key is worth, and that is what an engineer designing aggressive cache compression for a small-memory machine needs to know.

## A curious arithmetic fact: retention is not mass

One last observation hides a surprise. Suppose retention were just the fraction of attention mass kept by the top $k$ keys. List the weights in decreasing order; the top $2k$ consist of the top $k$ plus the next $k$, and each of those next ones is no bigger than its counterpart in the top block. So for any sorted mass curve $R$,

$$R(2k) \;\le\; 2\,R(k).$$

Doubling the budget can at most double the mass. But the measured curve breaks this rule at every context length: from $k=1$ to $k=2$ retention multiplies by $2.16$, $2.56$ and $2.80$. So the model's retention cannot be a plain kept-mass curve. It must be a *nonlinear readout* of the kept mass — for example, a compounding across the 24 layers, each of which loses a little.

If the readout were a product $\prod_\ell (1 - \varepsilon_\ell)$ of per-layer retentions, the classical Weierstrass product inequality brackets it:

$$1 - \sum_\ell \varepsilon_\ell \;\le\; \prod_\ell (1 - \varepsilon_\ell) \;\le\; e^{-\sum_\ell \varepsilon_\ell}.$$

With the argmax retention $0.2503$ at 2048 tokens, the total per-layer loss would have to lie between $0.7497$ and $\log(1/0.2503) \approx 1.385$ nats. Whether retention really compounds this way is an open question, and a testable one.

## What it means, and what it does not

The honest limitations first: one model, one corpus, an oracle that knows the true scores before choosing which keys to keep. Real eviction policies must decide without that knowledge, and the gap between oracle and policy is the next thing to measure.

But the shape of the story is clear, and the inequalities make it robust. The tropical limit — attention as a pure pointer — is lossy, and provably gets lossier with context. The loss is concentrated where the Maslov-gap map says it should be: in the diffuse final layers. The recovery from that limit is fast, because most layers are a tropical core plus a thin soft tail; and the size of the cache you need is governed, exponentially, by the gap. Among the suggested next steps: give the near-tropical layers a tiny cache and only the last two a full one, and use the cheap-to-estimate collision probability $\sum p_i^2$ as a per-head budget certificate.

Attention, it turns out, is almost a pointer. The "almost" is where all the interesting mathematics lives.
