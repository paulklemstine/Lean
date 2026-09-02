# When Two Savings Cost More Than Their Sum

## The arithmetic that engineers wish were true

Everyone who has ever shrunk a large language model to fit on smaller hardware has, at some point, done the following back-of-the-envelope calculation.

*Compressing the weights from 32-bit floats to 4-bit integers costs me about 9% of my accuracy. Making the attention layer look at only the 16 most relevant tokens instead of all of them costs me about 2%. So doing both should cost me about 11%.*

It is a comfortable calculation. It is also wrong — and not by a rounding error. In a controlled experiment on a transformer language model, the two optimizations applied separately cost $2.3\%$ and $9.2\%$ of retained accuracy. Applied together, they cost $14.0\%$. The additive prediction was $11.5\%$. The missing $2.5$ percentage points did not come from a bug, a bad seed, or a badly tuned hyperparameter. They came from the mathematics of the two techniques interacting, and they are, in a precise sense, unavoidable.

This article is about *why*. The punchline is a single, slightly surprising sentence: **sparse attention amplifies quantization noise, because averaging over fewer numbers cancels less of it.** Everything else — the exact size of the penalty, the way it shrinks as you widen the attention budget, the reason 4-bit grouping makes it worse, and the one design change that makes it disappear — follows from that sentence with the inevitability of arithmetic.

## Two knobs, one head

Strip an attention head down to its mathematical bones. There are $n$ candidate keys in the context. Each carries a value, a real number $v_i$ (in reality a vector, but nothing here depends on the dimension). A *dense* head reads out the average of all of them,
$$\bar v = \frac{1}{n}\sum_{i=1}^{n} v_i,$$
and a *top-$k$* head reads out the average over a selected subset $S$ of size $k$,
$$\bar v_S = \frac{1}{k}\sum_{i \in S} v_i.$$

The first optimization — sparse attention — replaces $\bar v$ by $\bar v_S$. It saves memory: you only keep $k$ entries of the key–value cache instead of $n$. Its cost is the *attention degradation*
$$\mathrm{deg}_A = |\bar v_S - \bar v|,$$
the distance between what the sparse head reads and what the true head would have read.

The second optimization — weight quantization — does something different. It does not change *which* numbers you average; it changes *the numbers themselves*. Rounding each weight to a 4-bit grid perturbs every value by an error $\eta_i$. The dense head now reads $\bar v + \bar\eta$, so quantization alone costs
$$\mathrm{deg}_Q = |\bar\eta| = \Big|\frac{1}{n}\sum_{i=1}^n \eta_i\Big|.$$

And the combined system, sparse attention over quantized values, costs
$$\mathrm{deg}_{AQ} = |\bar v_S + \bar\eta_S - \bar v|, \qquad \bar\eta_S = \frac1k\sum_{i\in S}\eta_i .$$

The quantity that the whole story turns on is the **interaction cost**
$$I = \mathrm{deg}_{AQ} - \mathrm{deg}_A - \mathrm{deg}_Q .$$
If $I = 0$, the two axes are independent and the engineer's arithmetic works. If $I < 0$, the optimizations partly cancel and you get a bonus. If $I > 0$, the whole is worse than the sum of the parts — *super-additivity* — and every budget table built on naive addition is optimistic.

## Where the extra loss hides

Look at $\mathrm{deg}_Q$ and $\bar\eta_S$ side by side and the mechanism jumps out. Quantization error is roughly symmetric: about as many weights round up as round down. Averaging $n$ of them lets the pluses and minuses cancel, and $\bar\eta$ ends up tiny. That is why a 4-bit model works at all — dense attention is a noise-cancelling device.

Now average only $k = 16$ of them. There is far less cancellation. The sparse head is a *worse* noise-cancelling device, by a factor that we can compute exactly.

The cleanest way to see it is to consider quantization error that is invisible to the dense head, meaning $\sum_i \eta_i = 0$ exactly. Then $\mathrm{deg}_Q = 0$: quantization, measured on its own, is free. But the sparse head still reads $\bar\eta_S \ne 0$, and the entire loss it suffers beyond its own sparsity cost is pure interaction.

> **Exact interaction identity.** If the quantization error averages to zero over the full context, and the sparsity bias $\bar v_S - \bar v$ has the same sign as the sparse noise average $\bar\eta_S$, then
> $$I = |\bar\eta_S| .$$

That is the entire super-additive effect in one line, and it holds with $\mathrm{deg}_Q = 0$ — a case where the naive budget table predicts a penalty of *exactly zero* and reality delivers $|\bar\eta_S|$.

How large can $|\bar\eta_S|$ get? If each rounding error is bounded by $\varepsilon$ and the errors sum to zero over the whole context, then the answer is exactly
$$|\bar\eta_S| \;\le\; \varepsilon \cdot \min\!\Big(1, \frac{n-k}{k}\Big),$$
and, whenever the attention budget is at most half the context ($2k \le n$, which is the practically interesting regime), this bound is *attained*: there is a genuine zero-mean, $\varepsilon$-bounded rounding pattern that pushes the sparse read the full $\varepsilon$ off target. Adversarially, an entire epsilon of error can hide inside a sparse window.

The bound also does the right thing as the budget grows: $\varepsilon\min(1,(n-k)/k)$ never increases as $k$ increases, and once $k$ passes half the context it strictly decreases. That is the shape the experiment shows. The measured interaction cost at $k = 16, 20, 24$ was $2.51\%$, $1.77\%$, $1.60\%$ — positive at every budget, and shrinking monotonically as the window widens.

## The average case is even cleaner than the worst case

Worst-case bounds are the mathematician's comfort food, but engineers want to know what happens *typically*. Here the answer is prettier than the worst case, because it is an exact identity rather than an inequality.

Model the quantization error as random: each $\eta_i$ has mean zero, variance $\sigma^2$, and distinct coordinates are uncorrelated. (This is the standard dither model of rounding, and it is not vacuous — the ensemble of $2^n$ random sign patterns $\eta_i = \pm\sigma$, each equally likely, satisfies all three conditions exactly.) Then measure everything in mean square rather than in absolute value.

> **Mean-square interaction theorem.** Under centred, pairwise-uncorrelated quantization error of variance $\sigma^2$, the mean-square degradation of the combined system exceeds the sum of the mean-square degradations of its parts by *exactly*
> $$\sigma^2\Big(\frac1k - \frac1n\Big).$$

No adversary. No sign condition. No tuning. It is an identity of the model, strictly positive for every genuinely sparse budget $k < n$, and it decays like $1/k$.

The proof is a two-line computation once you set it up correctly. The sparse read of the noise, $\bar\eta_S$, has mean zero and mean square $\sigma^2/k$: this is the familiar statement that averaging $k$ independent numbers divides the variance by $k$. The dense read has mean square $\sigma^2/n$. The cross-term between the sparsity bias and the noise vanishes because the noise is centred. Subtract, and the interaction is $\sigma^2/k - \sigma^2/n$. The whole super-additive effect is the elementary fact that $1/k > 1/n$.

This also explains a subtlety that a purely empirical study would have missed. The interaction cost is *not* a pointwise law. There exist rounding patterns for which the combined system is *better* than either part alone: on the same four values and the same key budget, one choice of error makes $I = +1/2$ and another makes $I = -3/2$, because the rounding noise happens to push the sparse read back toward the dense answer. Super-additivity is a worst-case and mean-square phenomenon, and honest engineering advice has to say so.

## The verdict, stated properly

Three hypotheses were on the table before the experiment. *Sub-additivity*: the combined loss is at most the sum. *Super-additivity*: the combined loss can exceed the sum. *Independence*: the combined loss equals the sum. The mathematics settles all three at once, with a four-key example you can check by hand.

Take $n = 4$ keys with values $v = (0, 0, 3, 3)$, quantization error $\eta = (-1,-1,-1,+1)$, and the selected set $S = \{1,2\}$. Then $\bar v = 3/2$, $\bar v_S = 0$, so $\mathrm{deg}_A = 3/2$. The error averages to $-1/2$ over all four keys, so $\mathrm{deg}_Q = 1/2$. The combined read is $\bar v_S + \bar\eta_S = 0 - 1 = -1$, at distance $5/2$ from $\bar v$. So
$$I = \tfrac52 - \tfrac32 - \tfrac12 = \tfrac12 > 0.$$
Sub-additivity is refuted; so is independence; super-additivity is confirmed. And the *correct* budget law replacing the false additive one is two-sided:
$$\mathrm{deg}_A + \mathrm{deg}_Q \;\le\; \mathrm{deg}_{AQ} \;\le\; \mathrm{deg}_A + \mathrm{deg}_Q + \varepsilon\min\!\Big(1,\frac{n-k}{k}\Big) \quad\text{(worst case)} .$$
Naive additivity is a *lower* bound on the damage, never an upper bound. That single sign flip is the practical content of the whole investigation.

## A second mechanism: the moving threshold

There is a second way the two optimizations talk to each other, and it is discrete rather than statistical. Top-$k$ attention has to *decide* which keys to keep, by ranking scores. Quantized keys project slightly differently, so the scores move — and if two keys are close in score, the ranking can flip and the head attends to a genuinely different set of tokens.

This mechanism turns out to be sharply gated. If every retained key beats every discarded key by a score margin greater than $2\varepsilon$, where $\varepsilon$ bounds the score perturbation, the selected set cannot change at all: quantization is *unable* to re-route attention. The reasoning is a one-line squeeze — a flip requires a discarded key to overtake a retained one, which costs at most $\varepsilon$ of downward motion on one side and $\varepsilon$ of upward motion on the other, hence at most $2\varepsilon$ of margin.

And the constant $2$ is exact, not an artifact of a lossy estimate: with two keys of scores $+1$ and $-1$ and perturbations $-1$ and $+1$, the margin is exactly $2\varepsilon$ and the selection *does* flip. So the safe regime is genuinely "margin strictly above $2\varepsilon$", and in the flat, long-tailed score distributions that real attention heads produce, a large fraction of positions sit below that threshold.

## Why 4-bit grouping makes it worse — and how to fix it

The mean-square theorem assumed the rounding errors of different keys are uncorrelated. Modern 4-bit quantization violates that assumption on purpose: it shares one scale factor across each *group* of 128 weights, so the errors inside a group move together. Suppose same-group errors have correlation $\rho \ge 0$ and cross-group errors are uncorrelated. Then the sparse read transmits
$$\mathbb{E}\big[\bar\eta_S^{\,2}\big] = \frac{\sigma^2 k + \rho\sigma^2 P(S)}{k^2},$$
where $P(S)$ counts the *ordered same-group pairs* inside the selected set. Two extremes bracket everything:

- If the selected keys land in $k$ distinct groups — a **spread** selection — then $P(S) = 0$ and the head transmits the ideal $\sigma^2/k$.
- If they all land in one group — an **aligned** selection — then $P(S) = k(k-1)$ and the head transmits $\sigma^2\big(1+\rho(k-1)\big)/k$, strictly more whenever $\rho > 0$ and $k \ge 2$.

At the physically relevant extreme $\rho = 1$ — one shared scale per group, the whole group's error moving in lockstep, realized exactly by the ensemble of random group signs — the aligned selection transmits the *entire* variance $\sigma^2$. The averaging over $k$ keys buys you nothing whatsoever. All of the $1/k$ noise suppression that made 4-bit weights survivable in the first place is gone.

How bad can a general selection be? The answer is a clean combinatorial identity: if $m_t$ of the selected keys lie in group $t$, then
$$P(S) = \sum_t m_t(m_t - 1).$$
The penalty depends on the selection *only* through its group occupancy profile — not on which keys, not on their values, only on how many landed in each group. Since $\sum_t m_t = k$, this quantity is at most $k(k-1)$, with equality precisely for the aligned selection. So **the aligned selection is the worst possible, whatever the group structure**, and every selection transmits at most $\sigma^2(1+\rho(k-1))/k$.

In the other direction, the profile function $\sum_t m_t(m_t-1)$ is a *convex* count, so spreading helps in the strongest possible sense: moving one selected key from a group holding $a$ of them to a group holding $b \le a-2$ strictly decreases the total,
$$(a-1)(a-2) + (b+1)b \;<\; a(a-1) + b(b-1).$$
Balanced occupancy profiles are optimal; concentrated ones are pathological. That is a directly actionable design rule: **when you select $k$ keys under group-quantized weights, diversify them across quantization groups.** It costs nothing at inference time and it recovers a factor of up to $k$ in transmitted noise energy.

There is one more fix, and it is even simpler. The interaction exists because the error is centred on the *whole* context but read on a *subset*. Choose the quantization offsets so that the error is centred on the selected set instead — $\sum_{i\in S}\eta_i = 0$ — and the combined system loses exactly what sparse attention alone loses. The interaction cost becomes non-positive and the additive budget law is valid again. Selection-aware calibration is not a heuristic; it is the exact inverse of the mechanism.

## What to take away

The one-sentence version for a practitioner: *a 4-bit model with a 24-key attention window is not a 4-bit model plus a 24-key cache.* Budget tables that add the two costs will under-predict the damage, and the size of the shortfall is not arbitrary — it is $\sigma^2(1/k - 1/n)$ in mean square, at most $\varepsilon\min(1,(n-k)/k)$ in the worst case, growing as the window narrows, and multiplied by up to $k$ if your selected keys pile into a single quantization group.

The one-sentence version for a mathematician is even shorter. Sparse attention and quantization interact because the first shrinks the sample over which the second's noise is averaged, and $1/k > 1/n$.

It is a small inequality. It costs 2.5 points of accuracy.
