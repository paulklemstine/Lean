# The Knee in the Curve: How Much Memory Does Attention Really Need?

## A number on a slide

Somewhere in an engineering document there is a small table. It says: at context length $512$, keep $16$ keys; at $1024$, keep $20$; at $2048$, keep $24$. Underneath, a footnote: "retains $98\%$ of attention mass."

Tables like this decide what runs on your phone. A modern language model, when it reads a long document, computes for each position a row of nonnegative weights $w_0, w_1, w_2, \dots$ summing to one — how much this position attends to each earlier one. Storing all of them is what makes long-context models expensive. But attention rows are famously lopsided: a handful of keys usually carry almost all the weight. So engineers ask a simple question. **How many keys do I have to keep before I have kept a fraction $g$ of the mass?**

Sort the row from heaviest to lightest, write

$$M(k) \;=\; \sum_{i<k} w_i$$

for the mass retained by the top $k$ keys, and define the **retention knee** at gate $g$:

$$k^*(g) \;=\; \min\{\,k : M(k) \ge g\,\}.$$

That is the number in the table. This article is about what that number really is — what you can honestly conclude about it from a measurement, what forces the numbers in a deployment table to line up the way they do, and a surprisingly clean theory that says the knee is squeezed between an *entropy* on one side and a *decay rate* on the other.

## What a sweep actually measures

Here is a real reading. At context $2048$, on a fixed corpus, averaged over $12$ evaluation windows, with the gate set at $g = 0.98$:

| keys $k$ | 20 | 24 | 28 | 32 |
|---|---|---|---|---|
| retained mass | $0.9793$ | $0.9835$ | $0.9854$ | $0.9885$ |

At $k=20$ the gate fails; at $k=24$ it passes. Headline: *the knee at $2048$ is twenty-four.*

But look again. Nobody measured $k=21,22,23$. What the experiment establishes is not "$k^* = 24$" but a **bracket**. And the bracket is a theorem, not a convention:

> **Bracketing.** If the weights are nonnegative and $M(a) < g \le M(b)$, then $a < k^*(g) \le b$.

The proof is two lines. Nonnegativity makes $M$ nondecreasing, so if the knee were $\le a$ the gate would already pass at $a$ — contradiction; and $b$ passes, so the knee is at most $b$. Applied to the row above: **$20 < k^*(0.98) \le 24$**. That, and nothing finer, is what the four numbers license. The reported "$24$" is the honest top of the bracket.

This distinction is not pedantry, because a sweep never reports $k^*$; it reports the least *grid point* that passes,

$$k^*_G(g) = \min\{k \in G : M(k) \ge g\},$$

for whatever grid $G$ of tested values it used. Three facts govern this reported number, and together they explain the entire folklore of "the knee moved when we refined the grid":

- **A sweep never under-reports:** $k^*(g) \le k^*_G(g)$, always.
- **Refining a grid can only lower the reported knee:** if $G \subseteq G'$ then $k^*_{G'}(g) \le k^*_G(g)$.
- **On-grid landing is exact:** if the true knee happens to be one of the tested values, the sweep reports it exactly.

So when a coarse sweep says $28$ and a fine sweep says $24$, no experiment was wrong. *The grid was.* And there is a quantitative version: a sweep on an arithmetic grid of spacing $s$ (starting at or below the knee) satisfies

$$k^*(g) \;\le\; k^*_G(g) \;<\; k^*(g) + s.$$

Spacing $4$ pins the truth to a window of four keys; spacing $16$ pins it to a window of sixteen. That single inequality is the whole reason the fine grid was run, and the whole reason its answer supersedes the coarse one.

A toy example makes the effect concrete. Take the dyadic row $w_i = 2^{-(i+1)}$, so that $M(k) = 1 - 2^{-k}$. Its true knee at gate $0.98$ is exactly $6$, since $M(5) = 0.96875 < 0.98 \le 0.984375 = M(6)$. Sweep it on the power-of-two grid $\{2,4,8,16\}$ and you will report $8$ — a $33\%$ over-provision of memory, on a profile with no noise at all. Add the single point $6$ to the grid and the truth reappears.

## Why the deployment chain must climb

The table's three entries, $16 < 20 < 24$, look like an empirical coincidence. They are not. Longer contexts *spread* attention: with more positions competing, no fixed number of keys does as well as before. Formalize "spreads" as a partial-sum comparison — the standard notion of one profile **majorizing** another:

> **Majorization implies knee monotonicity.** If $M_v(k) \le M_w(k)$ for every $k$, then $k^*_w(g) \le k^*_v(g)$.

The flatter profile $v$ needs at least as many keys as the peakier profile $w$, at every gate. And there is a strict version that turns "at least as many" into "strictly more" using exactly the datum a sweep produces:

> **Strict chain.** If the longer-context profile still fails the gate at the shorter context's knee, its knee is strictly larger.

Chain those two observations at $512 \to 1024 \to 2048$ and the strictly increasing sequence $16 < 20 < 24$ is *forced*, not fitted. And the certificates a sweep hands you — fail at $15$, pass at $16$; fail at $19$, pass at $20$; fail at $23$, pass at $24$ — pin the three knees exactly, all inside the $30$-key budget the deployment table promised.

The reading also has margins worth noting. At $k=24$ the retained mass exceeds the gate by $+0.0035$; at $k=20$ it misses by $-0.0007$. The pass has **five times** the room the failure had. That asymmetry is why the reading is robust rather than a razor's edge.

## An honest negative result

Now the part that makes this a piece of mathematics rather than a report.

If your attention rows are *sorted* — heaviest key first — then the retention curve $M$ is **discretely concave**: equal-width blocks of keys contribute less and less as you move right. Formally, for $k \le k'$ and any block width $d$,

$$M(k'+d) - M(k') \;\le\; M(k+d) - M(k).$$

The reason is immediate: the block starting at $k'$ consists of keys that are each no heavier than the corresponding keys in the block starting at $k$. And crucially, averaging over evaluation windows preserves this: an average of concave curves is concave.

Now check the reported row. The block $24 \to 28$ adds $0.9854 - 0.9835 = 0.0019$. The *later* block $28 \to 32$ adds $0.9885 - 0.9854 = 0.0031$. The increments **go up**. Therefore:

> **Obstruction.** The four reported numbers cannot be the window-averaged top-$k$ masses of sorted attention rows, for any number of windows.

This does not falsify the knee. The knee conclusion used only monotonicity, and monotonicity is intact: $20 < k^* \le 24$ stands. What it kills is *extrapolation*. Any procedure that assumes the retention curve is concave — interpolating to a finer gate, projecting a larger model's budget from a smaller model's curve — is unlicensed by this data. Something in the measurement pipeline (unsorted rows, per-window renormalization, a shard boundary) is not what the concave model assumes. "Needs a different definition," not "false" — the most useful kind of negative result, because it tells you exactly which inferences to stop making.

## The knee has a floor, and its name is entropy

Everything so far is order theory: it can certify that $k$ keys *suffice*. What about the other direction — a guarantee that you *cannot* get away with fewer? That requires knowing something about how flat the row is, and the right measure of flatness turns out to be the **attention energy**

$$E(k) \;=\; \sum_{i<k} w_i^2,$$

the collision probability of the attention distribution, i.e. $2^{-H_2}$ where $H_2$ is the Rényi-2 (collision) entropy. A spiky row has large energy; a flat one has energy near zero.

Cauchy–Schwarz does the rest. For any $k$ keys, $\left(\sum_{i<k} w_i\right)^2 \le k \sum_{i<k} w_i^2$, so if those $k$ keys retain mass at least $g$,

$$g^2 \;\le\; k\, E(k).$$

Read forwards, this is a **lower bound on the knee**: a row whose energy never exceeds $E$ cannot meet the gate with fewer than $g^2/E$ keys,

$$k^*(g) \;\ge\; \frac{g^2}{E}.$$

Read backwards, it is something more interesting: a **measured knee caps the entropy**. If a sweep certifies $k^*(g) \le K$, then the first $K$ keys must carry energy at least $g^2/K$. For the reading above — gate $0.98$, knee at most $24$ — this says

$$E(24) \;>\; 0.04, \qquad\text{equivalently}\qquad H_2 \;<\; \log_2 25 \;\approx\; 4.64 \text{ bits}.$$

That is a *falsifiable prediction about the rows themselves*, obtained from a table of four numbers and no further measurement. Any measured attention row that is flatter than $4.64$ bits of collision entropy cannot have a knee of $24$ at gate $0.98$. Go and look; if the rows are flatter, the pipeline is wrong.

And the constant cannot be improved. Take the plateau row that spreads mass $0.98$ evenly over exactly $24$ keys: its knee at gate $0.98$ is exactly $24$, and its energy is exactly $0.98^2/24 = 0.04001\overline{6}$. The floor is attained. There is also a cruder cousin, the peak bound: if no single key carries more than $M$, then $k^*(g) \ge g/M$ — one line from summing $k$ terms each at most $M$.

## How lossy is the floor? A dichotomy

A lower bound is only useful if it is close to the truth. So: how far can the real knee exceed $g^2/E$?

Start with the natural model of a decaying row, the geometric profile $w_i = (1-a)a^i$ with ratio $a \in (0,1)$. Everything is computable in closed form. Retention is $M(k) = 1 - a^k$, so the knee is the least $k$ with $a^k \le 1-g$, and since $\log(1/a) \ge 1-a$,

$$k^*(g) \;\le\; 1 + \frac{\log\frac{1}{1-g}}{1-a}.$$

The energy is exactly

$$E(a) \;=\; \sum_{i\ge 0}(1-a)^2 a^{2i} \;=\; \frac{1-a}{1+a},$$

so the Cauchy–Schwarz floor reads $g^2(1+a)/(1-a)$. Both quantities blow up like $1/(1-a)$ as the row flattens. The natural guess — that the truth outruns the floor without bound as $a \to 1^-$ — is therefore **wrong**, and the two rates cancel exactly:

> **Flatness bound.** For every geometric row and every gate $g \in (0,1)$,
> $$k^*(g) \;\le\; \frac{1 + \log\frac{1}{1-g}}{g^2} \cdot \frac{g^2}{E(a)}.$$
> The constant depends on the gate **alone**, uniformly in the decay ratio.

At $g = 0.98$ the constant is $(1 + \log 50)/0.9604 \approx 5.11$, so **six** is a safe integer bound: on any geometric row, the true key budget is within a factor of six of its collision-entropy floor. A sanity check on the dyadic row $a = 1/2$: energy $1/3$, floor $0.9604 \times 3 = 2.88$, true knee $6$, ratio $2.08$ — comfortably inside. On the uniform row over $n$ keys the floor is even sharper: the truth is $\ge gn$, the floor is $g^2n$, so the loss is exactly a factor $1/g = 1.02$ at $g = 0.98$.

So does an entropy measurement determine the key budget in general? **No** — and here is the counterexample. Take the *spike-plus-plateau* row: one dominant key of weight $1/2$, then $2m$ keys of weight $1/(4m)$, then nothing. It is a genuine sorted probability row (total mass $1$). At gate $3/4$:

- Retention is $M(k) = \tfrac12 + \tfrac{k-1}{4m}$ on the plateau, so the knee is exactly $m+1$ — it grows linearly in the plateau length.
- The energy is pinned in $[\,1/4,\; 1/4 + 1/(8m)\,]$, because the spike alone contributes $1/4$ and the plateau contributes $2m \cdot 1/(16m^2) = 1/(8m)$. The Rényi-2 entropy never exceeds $2$ bits, however long the plateau.
- Hence the Cauchy–Schwarz floor $g^2/E$ never exceeds $\;(3/4)^2/(1/4) = 9/4$ keys — while the true knee is $m+1$.

Let $m$ grow and the ratio (truth)/(floor) grows without bound, at a *fixed* gate, on honestly sorted probability rows. Put the two halves side by side and you get a clean dichotomy:

> **Tightness dichotomy.** On the geometric family, the knee-to-floor ratio is bounded by a constant depending on the gate alone. On the spike-plus-plateau family, at the same gate, it is unbounded.

**Exponential decay, not sortedness, is what makes the entropy floor informative.** A single number — the collision entropy — can never *certify* a memory budget; it only ever bounds it from below, and that bound can be off by any factor you like. The upper half must come from a decay hypothesis.

## Closing the sandwich

Which is exactly what the last piece supplies. Suppose an attention row has energy at most $E$ and an exponentially decaying tail, $1 - M(k) \le C r^k$. Then any $N$ with $C r^N \le 1-g$ is a valid budget, and the knee is pinned on both sides:

$$\frac{g^2}{E} \;\le\; k^*(g) \;\le\; N.$$

Two hypotheses of completely different character — one information-theoretic, one about decay — trap the number in the deployment table. A pleasant corollary is a free **consistency test**: any reported triple (gate $g$, energy bound $E$, tail certificate $Cr^N \le 1-g$) must satisfy $g^2/E \le N$. A report violating it is internally inconsistent no matter what the sweep printed. With $N=30$ and $g=0.98$ the test demands $E \ge 0.032$; the round-16 numbers clear it with room to spare.

One last structural bonus, for multi-head models: retained mass is linear in the profile, so for any blend $\lambda u + (1-\lambda)v$ of two attention profiles,

$$k^*_{\lambda u + (1-\lambda)v}(g) \;\le\; \max\{k^*_u(g),\, k^*_v(g)\}.$$

Averaging heads never costs keys. Budget for the hardest head and every mixture of them is covered.

## What the number means now

We started with a number on a slide and ended with a theory. The table entry "$24$ keys at context $2048$" is now:

- an **honest bracket** $20 < k^* \le 24$, with the grid-spacing inequality saying precisely how much finer sweeping could tighten it;
- a **forced chain** $16 < 20 < 24$, because longer contexts majorize shorter ones and each still failed at the previous knee;
- a **prediction** that the underlying rows carry fewer than $4.64$ bits of collision entropy — equivalently, energy above $0.04$ in their first $24$ keys — a falsifiable statement about data nobody has published;
- and a **warning**, from the concavity obstruction, that those four numbers cannot come from window-averaged sorted rows, so no concave extrapolation from them is licensed.

The final lesson is the dichotomy. There is a beautiful temptation to summarize an attention row by one scalar — its entropy — and read the memory budget off it. On exponentially decaying rows that works, to within a factor of about five at a $98\%$ gate. On a row with one spike and a long flat shelf it fails by an unbounded factor. Real attention rows live somewhere between those two worlds, and knowing *which* world a row is in is exactly the missing measurement. That is a much more interesting question than whether the knee is twenty-four.

It is, though. To within a bracket of four.
