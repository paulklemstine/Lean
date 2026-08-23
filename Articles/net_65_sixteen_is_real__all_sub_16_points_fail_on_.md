# Sixteen Keys: How Much of a Machine's Memory Actually Matters?

Ask a large language model to read a thousand words and then answer a question, and something quietly counterintuitive happens inside. At every step, the model looks back over everything it has read — a thousand positions, each with a weight saying "pay this much attention here". Those thousand numbers form a probability distribution. And that distribution is almost always spectacularly lopsided. A few positions carry nearly all the weight; the rest are rounding error.

Engineers have exploited this for years. If only a handful of positions matter, why store the rest? Keep the top $k$ keys, throw away the tail, and you get a model that runs faster and remembers longer with the same hardware. The whole family of techniques — top-$k$ attention, cache eviction, streaming attention — rests on this single bet.

But the bet needs a number. How large must $k$ be? And, more urgently as contexts stretch from thousands of tokens to millions: **does $k$ have to grow as the context grows?**

That question has a crisp answer, and it is not the answer most people expect.

---

## The knee

Start by making the question precise. Sort the attention weights from a single step into decreasing order: $w_0 \ge w_1 \ge w_2 \ge \cdots$, all positive. If you keep the top $k$ of them out of a context of length $n$, the fraction of attention mass you retain is

$$R(n,k) \;=\; \frac{w_0 + w_1 + \cdots + w_{k-1}}{w_0 + w_1 + \cdots + w_{n-1}}.$$

Now fix a bar — call it the *gate* — say $\tau = 0.98$: you insist on keeping $98\%$ of the mass. The smallest budget that clears the bar is the **knee**:

$$k^*(n) \;=\; \text{the least } k \text{ with } R(n,k) \ge \tau.$$

The knee is the honest answer to "how many keys do I need?" And its most interesting feature is how it changes as the context $n$ grows. Define the **context sensitivity**

$$\Delta(n) \;=\; k^*(2n) - k^*(n),$$

the extra keys you must buy each time you double the context. If $\Delta$ stays bounded, one fixed budget serves you forever. If $\Delta$ grows, every doubling costs you, and long-context inference has a hard scaling wall.

---

## An experiment, and a surprise

Measurements on two real models at gate $0.98$ produced two very different pictures. For a half-billion-parameter model, walking up a ladder of context lengths, the knee chain **rose**: $16$, then $20$, then $24$. For a three-times-larger model, the same ladder gave a **flat** chain: $16$, then $16$.

The obvious story writes itself: bigger models are more focused, so the knee shrinks with scale. Test it by sweeping *below* the grid floor — try budgets of $4$, $6$, $8$, $12$ on the larger model at context length $1024$ and see how low you can go. Here is what came back:

| budget $k$ | 4 | 6 | 8 | 12 |
|---|---|---|---|---|
| retained mass | $0.9318$ | $0.9532$ | $0.9660$ | $0.9759$ |

Every one fails the $0.98$ bar. The last, at $k=12$, misses by a hair — about two standard errors. The knee at context $1024$ is not below $16$. Sixteen is real.

So the knee does **not** shrink with scale. What changed with scale is something subtler and, it turns out, much more meaningful: not the size of the budget but its *stability*. The bigger model's budget stopped caring about the context length. And that is where the mathematics begins, because it turns out one can say exactly what kind of model has a context-stable budget — and it has nothing to do with how many parameters it has.

---

## What two measurements can prove

Before explaining the mechanism, there is a piece of housekeeping that turns out to be a theorem rather than a technicality.

An experimentalist reports a grid: some budgets pass, some fail. What does that establish? Here is the key fact, and it is almost embarrassingly simple.

> **The razor.** If budget $a$ fails ($R(n,a) < \tau$) and budget $b$ passes ($R(n,b) \ge \tau$), then the knee satisfies $a < k^*(n) \le b$.

Why? Because keeping more keys can never retain less mass: $R(n,k)$ increases with $k$. So if the knee were $\le a$, then $a$ would already pass, contradiction. And $b$ passes, so the least passing budget is at most $b$.

That is the entire proof, and note what it does *not* use: no assumption about the corpus, no sampling model, nothing about the architecture. Given a fail at $12$ and a pass at $16$, the conclusion

$$12 < k^*(1024) \le 16$$

is a deduction, not a statistical inference. "The knee is exactly $16$" is really shorthand for this bracket; the leftover fuzziness is the coarseness of the grid, nothing more.

The same monotonicity certifies something about the failing table itself. For *any* positive attention profile whatsoever, on any context longer than $12$,

$$R(n,4) < R(n,6) < R(n,8) < R(n,12),$$

strictly. The measured chain $0.9318 < 0.9532 < 0.9660 < 0.9759$ was never in danger of being a plateau — its increase is forced. Each failing point is a genuinely independent piece of evidence, and the failures are necessarily ordered.

---

## Two worlds: the gap and the floor

Now for the mechanism. Two extreme kinds of attention profile behave completely differently, and everything else falls between them.

**World one: a spectral gap.** Suppose each weight is at most a fixed fraction of the last: $w_{i+1} \le r\,w_i$ with $r < 1$. Attention decays geometrically. Then here is the striking fact: for every budget $k \ge 1$ and **every context length $n$**,

$$R(n,k) \;\ge\; 1 - \frac{r^k}{1-r}.$$

The context length has vanished from the guarantee. The reason is a clean cancellation: the mass you throw away is at most $w_0 r^k/(1-r)$ — a geometric tail measured in units of the biggest weight — while the mass you keep is at least $w_0$. The largest weight cancels, and with it any dependence on how long the context is.

Turn that into a budget and you get a formula. To clear a gate $\tau$, it suffices to take

$$K(r,\tau) \;=\; \max\left\{\left\lceil \frac{\log\big((1-\tau)(1-r)\big)}{\log r} \right\rceil,\; 1 \right\}.$$

This single number works at every context length, from $1024$ to a million. It is the mathematics behind "a $16$-key budget covers both models". Notice what it depends on: the decay ratio $r$ and the gate $\tau$. Not the context. Not the model size. Not the number of layers. **Just the shape of the tail.**

**World two: a floor.** Now suppose the opposite — the weights never really decay, but hover in a band $c \le w_i \le M$ with $c > 0$. There is no gap; attention is diffuse. Then the knee cannot stay bounded. In fact

$$k^*(n) \;\ge\; \frac{\tau\,n\,c}{M},$$

linear in the context. The proof is a one-liner: the mass you keep is at most $kM$, the total mass is at least $nc$, and clearing the gate means $\tau \cdot nc \le kM$. For perfectly flat attention ($w \equiv 1$) this is sharp on both sides — the knee is squeezed between $\tau n$ and $\lceil \tau n \rceil$ — and the context sensitivity $\Delta(n)$ grows without bound. Every doubling of the context doubles your budget. That is the scaling wall.

These two worlds are genuinely different, and both are real: the profile $w_i = 2^{-i}$ has one budget good for all contexts, while the flat profile has no finite budget at all. So a rising knee chain and a flat knee chain are not noise around a common truth. They are fingerprints of two different internal geometries.

---

## The knee is not literally flat — and that matters

Here is where the mathematics pushes back on the experimental language. It is tempting to read a chain $\{16, 16\}$ as a conservation law: $k^*(2n) = k^*(n)$, the knee is invariant. That is false, and it is false even in the friendliest possible case.

Take the perfect geometric profile $w_i = 2^{-i}$ and gate $3/4$. At context length $1$, the single key holds everything, so $k^*(1) = 1$. At context length $2$, the total mass is $1 + \tfrac12 = \tfrac32$, so one key retains $\tfrac{1}{3/2} = \tfrac23 \approx 0.667$, below the bar; you need both keys, and $k^*(2) = 2$.

The knee moved. Why? Because of a fact so simple it is easy to overlook: **a longer context always dilutes a fixed budget.** The numerator of $R(n,k)$ doesn't change when $n$ grows, but the denominator does, so a fixed budget's retained fraction creeps downward with context length. Near a gate crossing, that creep can push the knee up a step — even with the fastest imaginable decay.

The moral is precise and useful. A two-point measurement can support the claim "the budget is *bounded* across contexts". It can never support "the budget is *equal* across contexts". The right invariant isn't equality; it's **context stability** — the existence of one finite budget that works at every length. And the right way to report any single measurement is a bracket, not a number.

---

## The exact answer: it's a convergence test

Geometric decay is enough for stability, but it's a heavy hypothesis. Real attention spectra don't decay that fast. What is the true boundary?

Here is the theorem that answers it, and it is startlingly classical:

> **Stability equals summability.** For any positive attention profile and any gate strictly between $0$ and $1$, a single context-independent key budget exists **if and only if** the infinite series $\sum_i w_i$ converges.

That is it. The entire question — "does my key budget scale with context, or not?" — collapses to whether the sorted attention weights form a convergent series.

The forward direction is the illuminating one. If a fixed budget $K$ works at every context length, then the mass in the head, $H(K)$, must always be at least $\tau$ times the total, $H(n)$. So $H(n) \le H(K)/\tau$ for every $n$: the partial sums are bounded. And a series of positive terms with bounded partial sums converges. Conversely, if the series converges to $S$, then since $\tau S < S$ some finite $k$ has $H(k) > \tau S \ge \tau H(n)$ for every $n$ — that $k$ is your universal budget.

Two consequences are worth pausing on.

**The gate doesn't matter.** Raising the bar from $0.98$ to $0.999$ raises the *value* of the budget, sometimes a lot. But it cannot change *whether a finite budget exists*, because summability doesn't mention $\tau$. Stability is a property of the model, not of your measurement standard. That is a rigidity nobody would guess in advance.

**There is a critical exponent.** Attention spectra are usually fitted with a power law — Zipf's law, $w_i \propto (i+1)^{-s}$. And $\sum_i (i+1)^{-s}$ converges exactly when $s > 1$. So:

$$\boxed{\text{Zipf attention with exponent } s \text{ has a context-stable key budget} \iff s > 1.}$$

A sharp phase transition at $s = 1$. Above it, one budget forever; at or below it, every candidate budget is eventually defeated by a long enough context. Measuring a knee at two context lengths tells you which side of the transition your model is on.

This reframes the whole experiment. The observed difference between a rising chain and a flat chain isn't a fact about parameter counts. It's a fact about where each model's attention spectrum sits relative to the critical exponent $s=1$.

And it makes the knee an instrument. Fit the measured retention grid $(0.9318, 0.9532, 0.9660, 0.9759)$ at $k = 4, 6, 8, 12$ to a power law, and the exponents come out at $2.35$, $2.30$, $2.29$, $2.24$ — consistent to within a few percent, and comfortably above the critical value. For a power law with $s$ in that range, the computed knee at gate $0.98$ sits at $11$–$15$ keys and does not budge as the context grows from $1024$ to $65{,}536$. That is a falsifiable prediction of continued flatness, made from a spectrum fitted at a single context length. The knee is a spectrometer for the model's attention.

---

## Many heads, one worst case

Real transformers have dozens of attention heads per layer, and a deployed cache budget must serve all of them at once. So: how do budgets combine?

The answer comes from a fact about fractions. If you merge two heads, their masses add, so the merged retained fraction is $\frac{A_1 + A_2}{B_1 + B_2}$ — the *mediant* of $\frac{A_1}{B_1}$ and $\frac{A_2}{B_2}$. And a mediant always lies between its two parents. Therefore:

> The retained mass of a mixture is at least the smaller and at most the larger of the two per-head retained masses; consequently the mixture's knee lies between the two per-head knees.

Two conclusions follow. First, **stability is contagious in the good direction**: mixing context-stable heads gives a context-stable model, with budget the maximum of the two. Adding well-behaved heads never destabilises you. Second, and less comfortably, **a single bad head is fatal**: one gapless, subcritical head is enough to make the whole model's budget grow with context, because summability is destroyed by a single divergent summand.

Stability obeys a max law, not an average law. The system is as good as its worst head — which also means per-head knee measurements should bracket the model-level knee, a directly testable prediction.

---

## Why this matters outside the lab

Everything above is elementary in its ingredients — monotone functions, geometric series, a convergence test for positive series — and that is the point. These are not delicate facts that hold for one architecture on one corpus. They are structural, and they redirect an engineering question.

The engineering question was: *how many keys do I need, and how does that scale?* The theory says: stop measuring the budget and start measuring the **tail exponent of the sorted attention spectrum**. If it's above $1$, a fixed cache serves any context and you can plan hardware around a constant. If it's at or below $1$, no fixed cache will do and you need a fundamentally different mechanism — the growth is not a tuning problem but a mathematical inevitability.

It also disciplines the reporting. A knee measurement is a bracket, never a point. A flat chain is evidence of boundedness, never of an equality law. And a knee that doesn't move under a doubling of context is not a coincidence to be marvelled at — it is a convergent series making itself visible from the outside.

Sixteen is real. But the truth behind sixteen isn't the number. It's that the model's attention, sorted and laid out, is a series that converges — and once you know that, the number takes care of itself.
