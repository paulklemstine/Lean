# What a Word Cannot Know About Its Own Importance

## A short story about memory, attention, and the limits of looking inward

Every large language model has a memory problem, and it is a very literal one.

When a model reads a long document, it does not re-read the text each time it produces a new word. Instead it keeps, for every token it has already seen, a small bundle of numbers — a *key* and a *value* — in a scratchpad called the KV cache. To generate the next word the model compares the current query against every stored key, turns those comparisons into a probability distribution called *attention*, and mixes the corresponding values. The scratchpad is what lets a model finish your sentence after fifty pages.

The trouble is that the scratchpad grows linearly with the length of the text and never shrinks. At a hundred thousand tokens it can dwarf the model's own weights. So a whole engineering literature has grown up around one question: **if you can only keep $B$ of the $n$ stored tokens, which $B$ do you keep?**

That question has an obvious-looking answer, and this article is about why the obvious answer cannot work — not because nobody has engineered it well enough, but because of a theorem.

---

## The tempting idea

Here is the tempting idea, and it is genuinely a good one. Each stored token has a key vector $k_i$ — a list of, say, $64$ numbers that the model itself computed to summarize what that token *is*. Surely some tokens are intrinsically more "attention-worthy" than others: a rare proper noun, the start of a quotation, a sentence boundary. If importance is written into the key, then a small predictor — a *probe* — trained to read $k_i$ and output "this token will receive a lot of attention later" would give us a cheap, static, one-shot eviction rule. Score every key once as it arrives, keep the top $B$, throw the rest away, never look back.

So: fit that probe. For each attention head separately, fit a linear map from the $64$-dimensional key to the logarithm of the total attention that token will go on to receive over the rest of the document. Fit it on training documents only, then deploy it as a streaming eviction rule on held-out documents and measure how much of the true future attention mass survives in the cache.

The measurement, on a small transformer with $1024$-token contexts:

| budget $B$ | keep-what-you-used | content probe | oracle |
|---|---|---|---|
| $32$ | $0.8633$ | $0.8395$ | $0.9913$ |
| $64$ | $0.8822$ | $\mathbf{0.8938}$ | $0.9953$ |
| $128$ | $0.9189$ | $\mathbf{0.9284}$ | — |

The three columns are: a baseline that simply accumulates how much attention each token has received *so far* and evicts the least-used; the content probe; and the oracle that knows the future exactly and keeps the genuinely best $B$ tokens.

The probes are not garbage. Averaged over all (layer, head) cells they explain about $33\%$ of the variance in future attention — coefficient of determination $R^2 = 0.329$, ranging from $0.113$ in the least predictable cell up to $0.639$ in the best, with a clear depth pattern: high near the input, low in the middle. Any interpretability researcher would call that a real signal.

And yet, as an eviction policy, the probe is a dud. At $B = 64$ it beats the usage baseline by just over one point of retained attention mass, closing
$$\frac{0.8938 - 0.8822}{0.9953 - 0.8822} = 10.26\%$$
of the distance to the oracle. At $B = 32$ it is *worse* than the baseline: the closure fraction is $-18.59\%$. Ten full points of retained mass separate the best content policy from the oracle, at every budget tested.

The pre-registered prediction had been that a probe with real signal would close at least a third of the oracle gap. It closed a tenth, and sometimes went backwards. The verdict earned a name: **content is a weak predictor of importance**.

The interesting question is *why* — and the answer turns out to be a chain of three theorems, each one a ceiling above the last, each one saying something a better engineer cannot fix.

---

## Ceiling one: sixty-four numbers cannot see a thousand directions

Start with the crudest obstruction: counting dimensions.

An affine probe assigns to token $i$ the score $s_i = \langle w, k_i \rangle + b$. Now ask what such a score can *know* about a profile of true importances $a = (a_1, \dots, a_n)$. Whatever the probe does, its interaction with the truth passes through the inner product $\sum_i a_i s_i$, and expanding that gives
$$\sum_i a_i s_i = \sum_{j=1}^{d} w_j \Big( \sum_i a_i k_{ij} \Big) + b \sum_i a_i .$$

Everything on the right is built from just $d + 1$ numbers: the $d$ *key moments* $\sum_i a_i k_{ij}$ and the total mass $\sum_i a_i$. The map sending an importance profile to that list is linear, so its image lives in a space of dimension at most $d+1$, and by rank–nullity its kernel has dimension at least $n - (d+1)$.

**The Dimension Blindness Theorem.** *For any arrangement of keys whatsoever, if $d + 1 < n$ then there exists a nonzero importance profile $a$, with genuine variance, such that every affine probe — every weight vector $w$, every intercept $b$ — achieves $R^2 \le 0$ on it: worse than simply predicting the average. Moreover the space of such profiles has dimension at least $n - (d+1)$.*

The proof is three lines once you see it. If $a$ lies in the kernel, then $\sum_i a_i s_i = 0$ for every probe simultaneously, and also $\sum_i a_i = 0$, so the mean of $a$ is zero and its total variance is $\sum_i a_i^2$. Expanding the squared error,
$$\sum_i (a_i - s_i)^2 = \sum_i a_i^2 - 2\sum_i a_i s_i + \sum_i s_i^2 = \text{(variance)} + \sum_i s_i^2 \ \ge\ \text{(variance)},$$
so the probe's error exceeds the variance of the target and $R^2 \le 0$.

At the measured geometry — $64$-dimensional keys, $1024$-token contexts — this says that **at least $959$ of the $1024$ directions in importance space are completely invisible to every linear probe**. The visible fraction is $65/1024 < 6.4\%$.

Notice the delicious tension with the measurement. The probes achieved $R^2 = 0.329$ on the *actual* profiles, five times the visible fraction of an unstructured profile. The probe is genuinely picking up structure in real data. And the eviction policy still fails. So the failure is not a fitting failure — nobody needs to try harder at regression. Something else is going on.

---

## Ceiling two: what content is, and what content is not

Suppose we give up on linearity entirely. Let the score be *any* function of the key content — a deep network, a lookup table, an oracle over key vectors. What is the ceiling then?

Group the tokens into *fibers*: all tokens whose key content is the same value $y$. Within a fiber, a content-measurable score must output the same number for every member — it literally cannot tell them apart. And the number that minimizes squared error against a set of targets is their mean. So:

**The Content Ceiling (an ANOVA bound).** *For any content map $\mathrm{key}: i \mapsto \mathrm{key}(i)$ and any function $f$ whatsoever, the score $s_i = f(\mathrm{key}(i))$ has squared error at least*
$$SS_{\text{within}} \;=\; \sum_{y} \sum_{i : \mathrm{key}(i) = y} \big(a_i - \bar a_y\big)^2, \qquad \bar a_y = \text{mean of } a \text{ over the fiber } y,$$
*and consequently $R^2 \le 1 - SS_{\text{within}}/SS_{\text{tot}}$. The bound is attained exactly, by the conditional-mean predictor $f(y) = \bar a_y$, so this is not merely an upper bound but the supremum of what content can explain.*

This closes off the "just use a bigger network" escape: nonlinearity buys at most the distance from the measured $0.329$ up to $1 - SS_{\text{within}}/SS_{\text{tot}}$, and not one point more.

But there is an honest caveat, and it deserves to be stated as loudly as the theorem. **Within a single document, all key vectors are distinct.** Every fiber is a singleton, every within-fiber sum of squares is zero, and the ceiling degenerates to the vacuous $R^2 \le 1$. The bound has content only for a *pooled population* — many documents, the same key contents recurring in different surroundings. Which is, of course, exactly the population the probe was trained on. The caveat is not a footnote; it points straight at the real theorem.

---

## Ceiling three: importance is relational

Here is the heart of the matter.

Model a deployment as a family of *contexts* $w$ — documents, prompts, conversations — that share a pool of possible key contents $i$. In context $w$, key $i$ has true future attention $a_w(i)$. A **static** policy — and any content-only policy is static, because the content of a key does not change when you put it in a different document — commits to one selection $S$ of size $B$, once and for all.

The first observation is an innocuous exchange of summation order with a surprising moral:

**Averaging Lemma.** *A fixed selection $S$ retains, averaged over contexts, exactly the mass that $S$ carries in the context-averaged importance profile $\bar a(i) = \frac{1}{|W|}\sum_w a_w(i)$.*

In other words: **a static policy sees only the mean profile.** All context-conditional information is annihilated before the policy ever gets to act. It follows immediately that the best conceivable static policy is the top-$B$ set of $\bar a$, and then that this best static policy is bounded above by the average over contexts of the per-context oracles, because *the maximum of an average never exceeds the average of the maxima*:
$$\underbrace{\text{any static policy}}_{\text{any probe, any architecture}} \;\le\; \underbrace{\text{top-}B\text{ set of }\bar a}_{\text{ceiling of the whole family}} \;\le\; \underbrace{\text{average of per-context oracles}}_{\text{what the measurement calls "oracle"}}.$$

The middle-to-right gap is a Jensen gap for the max-functional. Call it the **relational deficit**. It is nonnegative always, and it is bounded below by the loss suffered in any *single* bad context, divided by the number of contexts — one pathological document is enough to force a positive deficit.

And it is genuinely positive, in the simplest example imaginable.

**The Swap Witness.** *Take two contexts and two key contents whose roles are exchanged: in context $1$, content $P$ is worth $u$ and content $Q$ is worth $v$; in context $2$, content $P$ is worth $v$ and content $Q$ is worth $u$, with $u > v$. Give the cache a budget of one. Then the two contents have identical averages $(u+v)/2$, so every static score — linear, nonlinear, ridge, neural, adversarially clairvoyant about content — retains exactly $(u+v)/2$. The oracle retains $u$. The deficit is exactly*
$$\frac{u - v}{2} \; > \; 0 .$$

Nothing about the score class enters the argument. There is no probe to improve. The two keys are *identical as content* and *different as roles*, and roles are not a property of the key.

This is the law the round is named for. **Importance is relational and positional, not intrinsic to key identity.** A key vector is a description of a word; how much attention it will receive is a fact about the conversation that word finds itself in.

---

## The two ceilings are one number

The regression story ("content can explain at most so much variance") and the selection story ("static caches lose at least so much mass") look like they belong to different subjects. They are one Cauchy–Schwarz step apart.

**Dispersion Bound.** *The relational deficit is at most*
$$\sqrt{\frac{B \cdot D}{|W|}}, \qquad D = \sum_i \sum_w \big(a_w(i) - \bar a(i)\big)^2 ,$$
*where $D$ is exactly the context dispersion — the part of the importance variance that no function of content can explain.*

One measurable population quantity therefore controls both the achievable $R^2$ of any probe and the retained-mass gap of any content-based eviction policy. And the shape is right, not merely convenient: on the swap witness the true deficit is $(u-v)/2$ while the bound evaluates to $(u-v)/\sqrt{2}$, so the inequality is loose by the constant factor $\sqrt 2$ and by nothing else, for every $u > v$. The $\sqrt{B \cdot \text{dispersion}}$ shape is exact; only the constant has slack. Conversely, if the contexts all agree, the dispersion is zero and the deficit is zero — the bound is tight at the boundary too.

---

## Two curiosities in the data, and what they mean

The measured table has two features that a careless reader would dismiss as noise. Both are theorems.

**The sign flip is real.** The probe loses at $B = 32$ and wins at $B = 64$ and $B = 128$. Is that a measurement artefact? No: it is a structural possibility of top-$B$ selection. Consider four keys with true future attentions $(5, 1, 9, 0)$. One score ranks them $0 \succ 1 \succ 2 \succ 3$; another ranks them $1 \succ 2 \succ 0 \succ 3$. At budget $1$ the first retains $5$ and the second retains $1$ — the first wins decisively. At budget $2$ the first retains $5 + 1 = 6$ and the second retains $1 + 9 = 10$ — the second wins decisively. Same scores, same truth, opposite verdicts. (And at budget $2$ both are strictly below the oracle's $5 + 9 = 14$, so the crossing changes the *ranking* of the two policies without changing the fact that both are far from optimal.)

The moral is a methodological one with teeth: **a comparison of two eviction policies at one budget carries no information about another budget.** Any paper that reports a single operating point has reported a single operating point.

**Heterogeneity across depth is a bonus, not a blemish.** The probe's accuracy varies sharply with depth — $R^2$ as low as $0.113$ and as high as $0.639$. Does that spread hurt the model-level guarantee? It helps. Because the guarantee aggregates per-head residuals through a square root, and the square root is strictly concave, unequal residuals give a strictly *smaller* total than equal residuals with the same mean. Numerically, for the extreme pair,
$$\sqrt{1 - 0.639} + \sqrt{1 - 0.113} = 1.5426 \; < \; 1.5799 = 2\sqrt{1 - \tfrac{0.639 + 0.113}{2}} .$$
So reporting only the mean $R^2 = 0.329$ *understates* the probe. Even generously scored, it still loses.

---

## What to build instead

None of this says caching is hopeless. It says something sharper about where the remaining headroom lives.

Three nested ceilings are now in place, and they are ordered: affine probes sit under a rank-$(d+1)$ obstruction; arbitrary content functions sit under the ANOVA ceiling; every static policy of any kind sits under the top-$B$ mass of the context-averaged profile, which is itself below the oracle by the relational deficit. The measured probe fails at the first level. The ten-point gap is guaranteed by the third.

For anyone shipping a long-context system, the consequences are concrete:

1. **Track usage online.** The advantage of the accumulation baseline is not that it is a better predictor; it is that it is allowed to depend on the context. That is precisely the right the static policy is denied, and precisely what the swap witness shows is worth $(u-v)/2$.
2. **Keep recency.** It remains the dominant cheap signal, and for the same structural reason: position is context, and context is what content cannot see.
3. **Budget your expectations.** At aggressive budgets, roughly ten points of retained attention mass are provably out of reach of content-based scoring. That is not a target for the next engineer; it is a constant of the population.
4. **Never extrapolate a single-budget comparison.** The crossing instance shows dominance can and does reverse.

There is a pleasing philosophical residue here. The dream behind interpretability-driven caching is that meaning is *in* the representation — that if we could only read the vector well enough, it would tell us everything about the token, including its future. What these theorems say is that a certain kind of fact is simply not in there. A word's importance is not a property of the word. It is a property of the sentence, the argument, the question being asked. The vector knows what the token *is*. It cannot know what the token will be *needed for*.

That is not a limitation of our probes. It is what the word "relational" means.
