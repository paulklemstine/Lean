# The Cheapest Question You Can Ask a Neural Network

## Why "how far did the weights move?" is the wrong question — and what to ask instead

---

### An operation without a diagnostic

Suppose you have two neural networks. They started life as the same model, and then they were fine-tuned apart: one on medical text, one on legal briefs. They have the same architecture, the same layer count, the same shapes. Now you want to perform surgery. You want to take a block of layers out of the second network and graft it into the first, and you want the patient to survive.

This is not a thought experiment. Model merging, block splicing, adapter transplantation, and "franken-merges" are everyday practice. And the practice has an everyday problem: **you cannot tell in advance which blocks will transplant cleanly and which will destroy the model.**

The standard folk diagnostic is distance. Compute how far the donor's weights are from the host's weights — some norm of $W_A - W_B$ — and assume that small distance means safe transplant, large distance means danger. This is not superstition. It rests on a genuine theorem, the Lipschitz bound, which we will state precisely below. The trouble is that the theorem says something much weaker than what people use it for.

This article is about a sharper diagnostic, and about a precise sense in which the distance diagnostic is not merely weak but *actively misleading*. The punchline can be stated in one sentence:

> There is a quantity computable from a single forward pass — no transplant, no gradient, no second model evaluation — that provably upper-bounds the damage a transplant will do; and there is no such quantity computable from weight-space distance alone.

Let us make all of that precise.

---

### The setup: decisions, not activations

Fix a finite set $\Omega$ of *positions* — think of them as the tokens in a held-out evaluation corpus, or the examples in a validation set. At each position the network produces a vector of $m$ scores (logits), and then commits to the largest one. We say that index $j$ is the **strict top** of a score vector $f$ if $f(i) < f(j)$ for every $i \neq j$: the argmax is unambiguous.

What we care about is not how much the activations wobble but whether the *decision* changes. So define the **damage fraction** of a transplant to be
$$\mathrm{damage} \;=\; \frac{\#\{x \in \Omega : d_H(x) \neq d(x)\}}{\#\Omega},$$
where $d(x)$ is the reference decision at position $x$ and $d_H(x)$ is the decision made by the hybrid model after the graft. If the agreement fraction is $a$, the damage is $1 - a$. In real measurements on a two-arm transplant experiment, the numbers look like this:

| block transplanted | agreement with reference | damage |
|---|---|---|
| deep "tail" block | $0.5443$ | $0.4557$ |
| middle "bulk" block | $0.8385$ | $0.1615$ |

The damage column is the thing a predictor must reproduce. Nearly half of all decisions flipped in the tail arm; only a sixth flipped in the bulk arm. Any honest predictor has to see that difference *before* the transplant.

---

### The distance diagnostic, stated honestly

Consider a linear block: features $\mathrm{feat}(x) \in \mathbb{R}^k$ go in, and the logits come out as $\mathrm{logit}_W(x)_j = \sum_{i} W_{ji}\,\mathrm{feat}(x)_i$. Suppose every entry of the weight difference is bounded, $|(W_A)_{ji} - (W_B)_{ji}| \le \delta$, and every feature coordinate is bounded, $|\mathrm{feat}(x)_i| \le B$. Then a two-line triangle-inequality argument gives the **Lipschitz bound**:
$$\bigl|\mathrm{logit}_{W_A}(x)_j - \mathrm{logit}_{W_B}(x)_j\bigr| \;\le\; k\,\delta\,B \qquad \text{for every } x, j.$$

Now pair this with a margin argument. If a score vector has a strict top with a gap larger than $2\varepsilon$ over every competitor, and you perturb every coordinate by at most $\varepsilon$, the top cannot change — the leader loses at most $\varepsilon$, the challenger gains at most $\varepsilon$, and $2\varepsilon$ of cushion absorbs both. So:

> **The norm route is sound.** If at every position the host's top-1 gap exceeds $2k\delta B$, then the transplanted block reproduces the host's decision everywhere, and the damage is exactly zero.

That is a real theorem and it is genuinely useful — as a *certificate*. If your gaps are enormous and your weights are close, you are safe. What it is not is a predictor. And here is where the story turns.

---

### Distance is not just loose. It is an anti-predictor.

Look again at the Lipschitz bound: $k\delta B$. The weight distance $\delta$ appears, but so does the feature scale $B$. Weight distance alone knows nothing about the *direction* in which the weights moved relative to the directions the features actually occupy. And that gap is fatal.

Here is the construction, in two dimensions, and it is embarrassingly simple. Let every feature vector be $\mathrm{feat}(x) = (1, 0)$: the second coordinate is a **dead direction**, invisible to the logits.

**Block one (dead direction, huge distance).** Let
$$W_A = \begin{pmatrix} 1 & 0 \\ 0 & 0\end{pmatrix}, \qquad W_B = \begin{pmatrix} 1 & D \\ 0 & 0\end{pmatrix}$$
for any $D$ you like — a million, if you want. The weight matrices differ by exactly $D$ in one entry. But that entry multiplies the dead coordinate. Both blocks output logits $(1, 0)$ at every position; both choose class $0$; the transplant damage is **exactly $0$**.

**Block two (live direction, tiny distance).** Now let
$$W_A' = \begin{pmatrix} d/2 & 0 \\ -d/2 & 0\end{pmatrix}, \qquad W_B' = \begin{pmatrix} -d/2 & 0 \\ d/2 & 0\end{pmatrix}$$
for any small $d > 0$. Here the entries differ by exactly $d$, and they sit squarely on the *live* coordinate. Block $A'$ outputs $(d/2, -d/2)$ and picks class $0$; block $B'$ outputs $(-d/2, d/2)$ and picks class $1$. Every single decision flips. The transplant damage is **exactly $1$**.

So for any $0 < d < D$ whatsoever we have a distance-$D$ transplant with zero damage sitting next to a distance-$d$ transplant with total damage. Damage is not monotone in weight-space distance — not approximately, not usually, not at all.

One can push this to its sharpest form. Suppose someone claims a function $g$ with the property that damage $\le g(\delta)$ whenever the entrywise weight distance is at most $\delta$. Feeding the live-direction block at scale $\delta$ into that claim forces $g(\delta) \ge 1$ for every $\delta > 0$. Since damage is a fraction, $g \equiv 1$ is the trivially true bound. **Every norm-only damage bound is vacuous.** There is no theorem to be had here; the missing ingredient is precisely the feature scale, i.e. where the drift points, not how big it is.

---

### The margin diagnostic

The alternative uses information the distance diagnostic throws away: the shape of the score vector itself.

Fix a drift budget $\varepsilon$. Call a position $x$ **margin-certified** if two things hold: the donor's own top-1 gap at $x$ exceeds $2\varepsilon$, meaning $u(x)_{d(x)} - u(x)_j > 2\varepsilon$ for every $j \ne d(x)$; and the actual drift between the donor's scores $u$ and the hybrid's scores $v$ is within budget, $|u(x)_j - v(x)_j| \le \varepsilon$ for all $j$. Call $x$ **uncertified** otherwise, and let
$$\mathrm{unc} \;=\; \frac{\#\{\text{uncertified positions}\}}{\#\Omega}$$
be the **margin-uncertified fraction** — the margin scarcity of the block.

The point of the definition is that a certified position is *provably safe*: the margin argument freezes its decision. So every damaged position must be uncertified, which is a containment of sets, which becomes a containment of fractions:

> **The margin screen.** For any block, at any drift level $\varepsilon$,
> $$\mathrm{damage} \;\le\; \mathrm{unc}.$$
> Consequently, if the forward-pass statistic sits below a threshold $\tau$, the measured post-transplant damage is guaranteed to sit below $\tau$ too.

This is the deliverable: **portability becomes predictable without performing the transplant.** You run the donor forward once over your held-out set, you histogram the top-1 gaps, you read off the fraction of positions with insufficient margin, and you have a certified ceiling on how much damage a graft can possibly do.

Run the deep tail block through it: measured agreement $0.5443$ pins the damage at $0.4557$, and the margin statistic certifies scarcity of at least $0.4557$. The screen is *exactly saturated* on that arm — the ceiling and the floor meet.

---

### Being honest about the screen

A screen that only ever says "danger" is worthless, so it matters that this one can be wrong in one direction only, and that the direction is the safe one.

It is genuinely one-sided: there is a configuration with margin-uncertified fraction $1$ and damage $0$ — every position lacks a certificate, and nothing breaks. Absence of proof is not proof of damage. So the screen cannot be turned into an estimate.

It is also *attained*: there is a configuration with uncertified fraction $1$ and damage $1$. So no universal improvement exists — there is no constant $c < 1$ with $\mathrm{damage} \le c \cdot \mathrm{unc}$ for all blocks. The bound is exactly as tight as a bound of this shape can be.

---

### Ranking blocks, not just bounding one

In practice you do not have one block; you have a stack of them, and you want a *ranking*: which block is safest to move? So the honest question is whether the predictor and the damage are positively correlated across a family of blocks.

Write $\mathrm{dam}(b)$ and $\mathrm{pred}(b)$ for the damage and the margin statistic of block $b$, and use the ordinary empirical mean, variance, and covariance across the $L$ blocks. We know $\mathrm{dam}(b) \le \mathrm{pred}(b)$. Suppose additionally that the screen is *tight to $\eta$*: it never overshoots by more than $\eta$, so $\mathrm{pred}(b) \le \mathrm{dam}(b) + \eta$. Then:

> **Correlation theorem.**
> $$\mathrm{cov}(\mathrm{pred}, \mathrm{dam}) \;\ge\; \mathrm{Var}(\mathrm{dam}) \;-\; \tfrac{\eta}{2}\sqrt{\mathrm{Var}(\mathrm{dam})}.$$
> In particular the covariance is strictly positive whenever the damage spread $\sqrt{\mathrm{Var}(\mathrm{dam})}$ exceeds $\eta/2$.

The proof is two classical ingredients glued together. Write $\mathrm{pred} = \mathrm{dam} + e$ where the slack $e$ lives in $[0,\eta]$. Covariance is additive, so $\mathrm{cov}(\mathrm{pred},\mathrm{dam}) = \mathrm{Var}(\mathrm{dam}) + \mathrm{cov}(e, \mathrm{dam})$. Cauchy–Schwarz bounds the second term below by $-\sqrt{\mathrm{Var}(e)}\sqrt{\mathrm{Var}(\mathrm{dam})}$, and a Popoviciu-type bound says a quantity confined to an interval of length $\eta$ has variance at most $\eta^2/4$, so $\sqrt{\mathrm{Var}(e)} \le \eta/2$. Done.

Instantiate at the two measured arms, $\mathrm{dam} = (0.4557,\, 0.1615)$. Then $\mathrm{Var} = 0.02164$ and $\sqrt{\mathrm{Var}} = 0.14710$, so the covariance is certified positive for any screen slack $\eta < 0.2942$ — and the tail arm has slack $\eta = 0$ exactly.

And the distance? Take the two blocks from the counterexample: the dead-direction block (distance $D$, damage $0$, margin statistic $0$) and the live-direction block (distance $d$, damage $1$, margin statistic $1$). For two-point families the covariance has the closed form $\mathrm{cov}\bigl((a,b),(c,e)\bigr) = (a-b)(c-e)/4$, and out comes
$$\mathrm{cov}(\text{margin},\,\text{damage}) = \tfrac{1}{4} > 0, \qquad \mathrm{cov}(\text{distance},\,\text{damage}) = -\tfrac{D-d}{4} < 0.$$
Same blocks, same measurement, opposite signs. The forward-pass statistic ranks them correctly; the weight-space distance ranks them exactly backwards.

---

### Cheaper still: entropy, and then two numbers

The margin statistic needs a full histogram of top-1 gaps. Can we get away with less?

**Entropy.** For a nonnegative score vector $p$, the **collision mass** is $C = \sum_k p_k^2$, and the Rényi-2 entropy is $H_2 = -\log C$. A nonnegative vector's largest entry is at most $\sqrt{C}$. So if $C \le 4\varepsilon^2$, then the top score itself is at most $2\varepsilon$, hence certainly the *gap* is at most $2\varepsilon$, hence the position is uncertified. Call such positions **diffuse**; equivalently, in entropy form, $x$ is diffuse exactly when $H_2 \ge 2\log\frac{1}{2\varepsilon}$. This gives
$$\mathrm{diffuse} \;\le\; \mathrm{unc}, \qquad \mathrm{damage} \;\le\; \mathrm{unc}.$$
A block whose predictions are entropically spread out can never be certified portable below its diffuse fraction — diffuseness is a *certified obstruction to certification*. Contrapositively, any block certified portable below $\tau$ is necessarily $\tau$-concentrated. (And, honestly: the sandwich cannot be closed. There are totally diffuse blocks with zero damage. Diffuseness bounds the certificate, not the damage.)

**Two scalars.** Finally, suppose you refuse to compute any histogram at all and will only report two numbers: a cap $G$ on the top-1 gap and the mean gap $\mu$ over your held-out set. A reverse-Markov argument does the rest. If gaps are capped at $G$ and average at least $\mu$, then the fraction of positions with gap below $2\varepsilon$ is at most $(G-\mu)/(G-2\varepsilon)$: a large average under a hard ceiling leaves little room for stragglers. Since only low-gap positions can be uncertified, and only uncertified positions can be damaged,
$$\mathrm{damage} \;\le\; \frac{G - \mu}{G - 2\varepsilon} \qquad (2\varepsilon < G).$$
Two forward-pass scalars, one inequality, a certified bound on surgical damage. The bound is sharp: two positions with gaps $2\varepsilon$ and $G$ realise it exactly at $1/2$.

This last form is falsifiable in the strongest sense. The tail arm's damage is $0.4557$; therefore its gap statistics *must* satisfy $\mu \le G - 0.4557\,(G - 2\varepsilon)$. At $G = 5$ nats and $\varepsilon = 0.16$, that caps the donor tail's mean top-1 gap at $2.8673$ nats. Measure a higher mean gap and the entire margin route collapses.

---

### What the story is really about

Strip away the machine learning and the moral is old. A perturbation's effect is not determined by its magnitude but by its alignment with the directions the system is actually sensitive to. The weight-space norm measures the perturbation; the margin measures the sensitivity. Only the second one knows about the first's relevance.

What is new is the sharpness. It is one thing to say the norm bound is loose. It is another to prove that *any* damage bound depending on the distance alone must be the trivial one, and to exhibit a single data set on which distance and damage have opposite covariance signs. The norm route survives — but strictly demoted, from predictor to sufficient condition. Meanwhile the cheap statistic that everyone already has, sitting in the logits of a forward pass they already ran, turns out to carry a certificate.

Before you cut, look at the margins.
