# The Core Is Shared, the Tail Is Personal

## What changes when a language model learns to be helpful?

Take a large language model that has only ever been trained to predict the next
word in a stream of text. Now take the version of that same model that has been
fine-tuned to answer questions politely, follow instructions, and refuse
dangerous requests. Two models, same skeleton, same layer count, same
dimensions — one of them a raw text predictor, one of them an assistant.

How different are they on the inside?

The naive expectation is a slow, steady drift. The fine-tune nudges every
weight a little; those nudges compound as information flows upward; by the top
of the network the two models should be measurably far apart, with the distance
growing monotonically with depth. Call this the **monotone divergence picture**.
It is intuitive, it is widely assumed, and — when you actually measure it — it
is wrong in two separate and instructive ways.

This article is about those two failures and about the mathematics that
explains them. The short version, which will take the rest of the article to
unpack, is a slogan:

> **The core is shared. The tail is personal.**

And a warning, which turns out to be a theorem:

> **Looking alike is not the same as behaving alike.**

---

## What the measurement actually says

Run a small transformer — 24 layers — in both its base and its instruction-tuned
form, on identical held-out prompts, and record, layer by layer, the internal
key and value vectors that the attention mechanism caches. Three numbers stand
out.

**First: the bottom of the stack is not merely similar, it is identical.** At
layer 0 the keys of the two models coincide exactly; their cosine similarity is
$1.0000$. Nothing has diverged yet, because nothing has had a chance to.

**Second: the divergence is a hump, not a ramp.** The relative difference
between the two models' keys climbs steadily with depth, reaches a peak of
about $0.217$ around layer 16, and then *falls back* to roughly $0.16$ by layer
23. The monotone picture predicts a curve that only goes up. The measured curve
comes back down.

**Third — and this is the interesting one — similarity and behaviour come
apart.** Averaged across the stack, the two models pick the *same* attention
target (the same top-scoring position) about $89\%$ of the time. But in the last
two layers that agreement collapses: $0.568$ at layer 22, $0.627$ at layer 23.
Meanwhile, in those very same layers, the cosine similarity of the cached keys
is a placid $0.983$ and $0.988$. The vectors look almost the same. The decisions
they produce are close to a coin flip apart.

That last observation is the puzzle. Cosine similarity of $0.983$ *feels* like a
guarantee. It is not. And the reason it is not is a clean piece of mathematics
that has nothing to do with transformers at all.

---

## Why "almost the same vector" guarantees nothing

Strip the problem to its bones. A layer of attention produces a vector of
scores $u = (u_1,\dots,u_n)$, one per candidate position, and then acts on the
largest one. Say that index $i$ is the **decision** of $u$ if $u_j < u_i$ for
every $j \neq i$. Two models "agree" at a layer when their score vectors have
the same decision.

Now ask: what property of $u$ and $v$ guarantees that they decide the same way?

The honest answer is a **margin**, not an angle.

> **Margin Stability Theorem.** Let $u$ and $v$ be score vectors and let
> $\varepsilon \ge 0$. If $u$ decides $i$ with a gap larger than $2\varepsilon$
> — that is, $u_i - u_j > 2\varepsilon$ for every $j \neq i$ — and if
> $|u_j - v_j| \le \varepsilon$ for every coordinate $j$, then $v$ also decides
> $i$.

The proof is one line of arithmetic: $v_i \ge u_i - \varepsilon$ and
$v_j \le u_j + \varepsilon$, so $v_i - v_j \ge (u_i - u_j) - 2\varepsilon > 0$.
The factor $2$ appears because the perturbation can push the leader down and a
challenger up at the same time — and it cannot be improved. Take
$u = (2\varepsilon, 0)$, whose gap is exactly $2\varepsilon$, and move both
coordinates by exactly $\varepsilon$ to reach $v = (\varepsilon, \varepsilon)$.
The decision is gone: the two coordinates tie, and $v$ has no strict top at all.
So $2$ is the sharp constant.

That is the positive half. The negative half is where the tail of the network
lives.

> **Cosine Dissociation Theorem.** For every $\varepsilon > 0$ there exist two
> score vectors $u$ and $v$ with cosine similarity greater than
> $1 - \varepsilon$ whose decisions are *different*.

The witness is disarmingly simple. Fix a small $t > 0$ and take
$$u = (1+t,\ 1), \qquad v = (1,\ 1+t).$$
Model $u$ chooses the first position; model $v$ chooses the second; they could
not disagree more completely. Yet their cosine similarity is exactly
$$\cos(u,v) = \frac{2 + 2t}{t^2 + 2t + 2} \;\ge\; 1 - \frac{t}{2},$$
which tends to $1$ as $t \to 0$. Choosing $t = \varepsilon$ finishes the proof.

The consequence is worth stating plainly: **no function of cosine similarity
alone can lower-bound decision agreement.** A layer with cosine $0.983$ can have
*any* agreement rate whatsoever, including zero. The measured tail point —
cosine $0.983$, agreement $0.568$ — violates no inequality. It was never
paradoxical. It is what the geometry permits.

---

## Why the *tail*, though?

Dissociation is possible everywhere. Why does it actually happen in layers 22
and 23 and nowhere else?

Because those are the layers where attention is **diffuse**. When a layer's
attention distribution $p$ spreads its mass thinly across many positions,
nobody is far ahead, and the margin is tiny by arithmetic necessity. The
relevant statistic is the **collision mass** $C = \sum_k p_k^2$ — the
probability that two independent draws from $p$ land on the same position. A
sharply peaked distribution has $C$ close to $1$; a distribution spread evenly
over $m$ positions has $C = 1/m$.

> **Collision Bound.** Every coordinate of a nonnegative vector $p$ satisfies
> $p_i \le \sqrt{\sum_k p_k^2}$.

So the top attention weight can never exceed $\sqrt{C}$. Diffuse attention has
a small leader, and therefore a small gap. This upgrades to a fragility
statement:

> **Diffuse Attention Is Decision-Fragile.** If $p$ is a nonnegative attention
> distribution with collision mass $C$ currently deciding $i$, then for every
> $\eta > 0$ and *every* alternative index $j$, there is a vector $q$ with
> $|p_k - q_k| \le \sqrt{C} + \eta$ for all $k$ that decides $j$.

You can move the decision anywhere you like using a perturbation the size of
$\sqrt{C}$. In the diffuse tail, $\sqrt{C}$ is small — smaller than the
measured fine-tune delta of about $0.16$. The fine-tune does not need to
work hard to change the model's mind up there. It gets it for free.

---

## A surprising ally: tropical geometry

Here the story converges with a completely different measurement made on the
same network. Attention uses the softmax, and softmax is a smoothed version of
the maximum. The standard way to quantify "how smoothed" is the **Maslov gap**
$$\gamma = \log\!\Big(\sum_j e^{x_j}\Big) - x_i,$$
the difference between the soft aggregate and the hard one at the chosen index.
When $\gamma \approx 0$, softmax is behaving like a max — the layer is
*near-tropical*, doing genuinely max-plus arithmetic. When $\gamma$ is large,
the layer is far from tropical: many terms contribute, and the "max" is a
committee decision.

Measured across the same 24-layer stack, the Maslov gap sits near zero almost
everywhere — and jumps to a median of $2.5$–$2.7$ in exactly layers 22 and 23.

That is not a coincidence, and it is not even really a second fact. The Maslov
gap and the margin bound each other in both directions:

> **Margin $\Rightarrow$ near-tropical.** If every competitor is at least $m$
> below the top, then $\gamma \le \log\!\big(1 + (n-1)e^{-m}\big)$, which decays
> exponentially in $m$.
>
> **Far-from-tropical $\Rightarrow$ small margin.** Conversely, if the measured
> gap satisfies $\gamma \ge g$ with $g \ge 1$, then the margin obeys
> $m \le \log(n-1) + \log 2 - g$: every nat of Maslov gap costs a nat of margin.
>
> **Small margin $\Rightarrow$ flippable.** A decision held by a gap of at most
> $m$ over some competitor is destroyed by a coordinatewise perturbation of size
> $(m+\eta)/2$.

Chain these and you get a single statement: **far from tropical $\Rightarrow$
diffuse $\Rightarrow$ fragile.** A tropical-geometry measurement, an
information-theoretic measurement, and a behavioural measurement were all
looking at the same two layers through three different windows, and the three
windows are connected by explicit inequalities. That kind of convergence is the
best evidence available that one has found a real structural feature rather
than an artefact.

---

## The hump, explained

Back to the second surprise: the divergence that climbs to $0.217$ at layer 16
and then falls to $0.16$ by layer 23.

Model the two networks as running through the *same* layer maps $f_k$, except
that the fine-tune injects a small weight delta at each layer:
$$a_{k+1} = f_k(a_k), \qquad b_{k+1} = f_k(b_k) + \delta_k,$$
and write $d_k = \|a_k - b_k\|$ for the divergence. If each shared layer is
$L$-Lipschitz and $\|\delta_k\| \le \varepsilon$, then
$d_{k+1} \le L\,d_k + \varepsilon$, which unrolls to
$d_k \le \varepsilon(1 + L + \cdots + L^{k-1})$ — and for nonexpansive layers
($L = 1$) simply to $d_k \le k\varepsilon$.

Notice what that bound permits and what it forbids. It permits arbitrary
growth. It forbids *decrease* by more than the injected delta. So:

> **The hump is a contraction certificate.** If the divergence after a shared
> layer is smaller than the incoming divergence by more than the injected
> delta, then that shared layer map strictly contracts the pair of states.

Monotone divergence was never an axiom waiting to be refuted by data; its
failure is *equivalent* to contractivity of the shared machinery. And the
measured numbers give a quantitative dichotomy. With a per-layer delta budget
of $\varepsilon = 0.01$, the fall from $0.217$ at layer 16 to $0.16$ at layer 23
forces one of two things: either the tail maps contract the state pair by a
factor of at most $4/5$, or the tail deltas are larger than assumed, carrying a
total budget of at least $0.057$ across the seven layers $[16, 23)$ — in which
case some *single* layer injects at least $0.008$. There is no third option.

---

## Cashing it in: serving many models from one core

All of this has a directly practical payoff. Suppose you want to serve $n$
different fine-tunes of the same base model from one machine with limited
memory. If the first $s$ of $L$ layers of key/value machinery can be shared and
only the remaining $L-s$ must be kept per model, the cost is
$$\mathrm{cost}(n) = s + n(L - s) = nL - (n-1)s,$$
so sharing saves exactly $(n-1)s$, and the amortized per-model memory ratio
converges to the **tail fraction**
$$\frac{\mathrm{cost}(n)}{nL} \longrightarrow \frac{L-s}{L}.$$
With $L = 24$ and $s = 22$ that limit is $1/12$: asymptotically, each additional
fine-tune costs one twelfth of a model.

But safety must come from a margin, never from an angle. On every layer where
the reference model holds its decision with gap exceeding $2\varepsilon$ and the
shared cache is $\varepsilon$-accurate, both models provably decide the same
way; certifying $22$ layers out of $24$ therefore guarantees a provable
agreement fraction of at least $11/12 \approx 0.9167$. (The informal shorthand
"share 22 of 24 layers at $\ge 0.92$ agreement" is slightly optimistic:
$22/24 = 0.9167 < 0.92$. The certified figure is $11/12$.) And by the Cosine
Dissociation Theorem, no cosine threshold could ever have replaced that margin
hypothesis.

How deep can the shared core run? Track the error budget
$B_0 = 0$, $B_{k+1} = L_k B_k + \varepsilon$, which dominates the true
divergence. Declare layer $k$ *shareable* when its margin exceeds $2B_k$. Two
structural facts follow. If the layers never contract and the margin profile
never increases with depth, the shareable layers form an **initial segment** —
sharing is a prefix property, precisely the empirical "core shared, tail
personal" shape. And for nonexpansive layers, $B_k = k\varepsilon$, so every
layer of depth $k < m/(2\varepsilon)$ is shareable: with $\varepsilon = 0.01$
and margin $m = 0.5$, that is every layer up to depth $24$, and the bound is
tight — at depth $25$ the certificate genuinely fails.

---

## Where identity lives

One last prediction, for the obvious next experiment. Take two fine-tunes of
one base model and swap only their last two layers. Whose behaviour does the
hybrid inherit?

Factor each model as a tail composed with a core. If the tail is $K$-Lipschitz,
the output divergence splits as
$$\|\text{out}_A - \text{out}_B\| \le K\|\text{core}_A - \text{core}_B\| +
\|\text{tail}_A - \text{tail}_B\|,$$
which read backwards is an attribution law: any output divergence beyond
$K$ times the core divergence *must* be carried by the tails. Identity measured
at the output and absent from the core has nowhere else to live.

And the swap itself has a predicted outcome: if the two cores agree to within
$\varepsilon$ and model $B$'s tail holds its decision with margin greater than
$2K\varepsilon$, then the hybrid — model $B$'s tail running on model $A$'s core
— makes exactly model $B$'s decision. Under a margin hypothesis, the tail
carries the decision and the core is interchangeable. Without a margin
hypothesis the conclusion fails, by the dissociation theorem again: "the caches
look alike" never licenses a swap.

So the picture that emerges is not the smooth drift we started with. It is a
building with a shared foundation, a shared frame, and a bespoke top floor. Most
of a transformer is common machinery, computing something close to a maximum,
holding its decisions by comfortable margins, indifferent to which fine-tune it
belongs to. Then, in the last two layers, the margins vanish, the softmax stops
behaving like a max, and the network's choices become genuinely its own.

The bulk is shared. The identity is in the tail.
