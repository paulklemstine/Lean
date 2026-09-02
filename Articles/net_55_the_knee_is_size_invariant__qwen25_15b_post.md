# The Knee That Refused to Grow

## Why a language model three times bigger needed exactly the same amount of memory

There is a comfortable intuition in machine learning that bigger models need bigger everything. More parameters, more compute, more memory — and, surely, a longer memory of what they have just read. A model that is three times larger ought to *use* more of its context, spreading its attention over more of the text it has seen. That intuition has a precise, measurable consequence, and this article is about what happened when the consequence was measured, and about the mathematics that explains the answer.

The measurement is simple to describe. When a transformer language model reads a passage of text and predicts the next word, it computes a set of *attention weights*: one nonnegative number for each earlier token, saying how much that token matters right now. Sort those numbers from largest to smallest. Then ask: **how many of the top-ranked tokens do you actually need to keep** before throwing the rest away changes essentially nothing about the model's output?

Call that number the **knee**, written $k^*$. It is the size of the model's genuine working set — the number of keys that must live in fast memory. It is not an abstract quantity: in a deployed system, the cache holding those keys is often the dominant cost, and the knee is exactly the budget that cache has to serve.

The experiment took a 1.5-billion-parameter model, three times the size of a 0.5-billion-parameter model measured under an identical protocol, and swept the budget. The result, at a $0.98$ agreement gate on held-out text:

| context length | knee of the 1.5B model | knee of the 0.5B model |
|---|---|---|
| $512$ | $16$ | $16$ |
| $1024$ | $16$ | $32$ |

Tripling the parameter count did not raise the budget by a single key. At the longer context it *halved* it. A pre-registered prediction — that the knee would land somewhere in $[24,48]$ at context $512$ and $[32,96]$ at context $1024$ — came in below its own floor at both cells.

The rest of this article is about the mathematics that turns this from an anecdote into a theorem.

---

## Making the knee precise

Fix a *profile*: a sequence $w_0, w_1, w_2, \dots$ of strictly positive numbers, thought of as attention weights already sorted in decreasing order of importance. For a budget $k$ define the **head mass**
$$M_w(k) = \sum_{i<k} w_i,$$
the total attention captured by the top $k$ keys. For a context length $n$ define the **retained fraction**
$$R_w(n,k) = \frac{M_w(\min(k,n))}{M_w(n)} \in (0,1],$$
the share of the context's attention that a budget of $k$ keys preserves. Finally, for a gate $\tau$ (in the experiment, $\tau = 0.98$) the **knee** is
$$k^*(w,n,\tau) = \min\{\,k : R_w(n,k) \ge \tau\,\},$$
the smallest budget that clears the gate.

Everything below is a theorem about this functional. No transformer appears in any proof; what appears is the shape of a decreasing positive sequence.

---

## The first mechanism: the knee cannot see size at all

Here is the cleanest possible reason a knee might not move when a model grows.

> **Theorem (Scale invariance of the knee).** For every profile $w$, every constant $c>0$, every context $n$ and every gate $\tau$,
> $$k^*(c\,w, n, \tau) = k^*(w, n, \tau).$$

The proof is one line of algebra: head mass is homogeneous, $M_{cw}(k) = c\,M_w(k)$, so the constant cancels in the numerator and denominator of the retained fraction, and the set of passing budgets is literally the same set. The knee is a functional of the *shape* of the profile — of its projective class — and never of its total mass.

This already kills the naive version of "bigger means hungrier". The crudest model of tripling a network is replicating its heads: if you replace one head by $m$ identical copies, the aggregate profile is $m\,w$, and

> **Corollary.** Replicating a head $m$ times leaves the knee unchanged at every context length and every gate. In particular, tripling the model in this sense moves the budget by exactly zero keys.

Scale invariance is exact, unconditional, and free. It is also, on its own, too crude to explain the experiment, because the 1.5B model is not a rescaled 0.5B model. So we need mechanisms that survive genuine structural change.

---

## The second mechanism: one envelope for a whole family

Suppose you have a whole family of models, indexed however you like — by depth, by width, by parameter count. Each model $s$ has its own profile $W_s$. Two mild things can be true of the family at once: every profile sits below one fixed *envelope* $v$ with $\sum_i v_i < \infty$, and every profile has a lead weight bounded away from zero, $W_s(0) \ge c > 0$.

> **Theorem (Envelope theorem: one budget for the whole family).** If every $W_s$ is strictly positive, dominated by a summable envelope $v$, and has lead weight at least $c>0$, then for any gate $\tau<1$ there exists a single budget $K$ such that
> $$k^*(W_s, n, \tau) \le K \quad \text{for every model } s \text{ and every context length } n \ge 1.$$

The proof is a tail argument with a numerical punchline. Summability of $v$ means its tail beyond some index $K$ is smaller than $(1-\tau)c$. For any model in the family, the mass sitting between budget $K$ and context $n$ is bounded by that same tail, while the mass inside the first $K$ keys is at least the lead weight $c$. Comparing the two forces the retained fraction above $\tau$. Crucially, $K$ is computed from the envelope, the lead weight and the gate alone: it is *blind to the model index*, hence blind to the parameter count.

This is the exact statement behind the empirical slogan that a budget of about thirty keys covers every real model measured. Note where the strength lives: the hypothesis $c>0$ is load-bearing. A family whose lead weights drift to zero has flattening attention, and no uniform budget can exist.

The converse is also true, and it says the phenomenon is rigid rather than soft:

> **Theorem (Rigidity).** If a family admits a size-uniform budget at gate $\tau \le 1$, then there is a $K$ such that every member concentrates a $\tau$-fraction of the mass of *every* context inside its first $K$ keys: $\tau\, M_{W_s}(n) \le M_{W_s}(K)$ for all $s$ and all $n \ge 1$.

So "one budget for all sizes" is not a statistical coincidence you can get by luck; it is equivalent to a uniform concentration property of the family's attention.

---

## The third mechanism: heads add, and the worst one wins

The most convincing explanation of the experiment is also the most elementary, and it is about how the profile a deployment actually sees is built. A model's attention over a key position is a *sum* over heads. Parameter count, in these families, grows largely by adding heads.

> **Theorem (Multi-head aggregation).** Let $W_1, \dots, W_H$ be strictly positive profiles (the heads), and let $\tau \le 1$. If every head clears the gate with $K$ keys, i.e. $k^*(W_j, n, \tau) \le K$ for all $j$, then the aggregate profile $\sum_j W_j$ also clears it:
> $$k^*\Big(\sum_{j} W_j,\ n,\ \tau\Big) \le K.$$
> **There is no hypothesis whatsoever on the number of heads $H$.**

The proof is a two-line inequality with a large moral. Passing the gate at budget $k$ means $\tau\,M_{W_j}(n) \le M_{W_j}(\min(k,n))$ — a *linear* inequality in the head's masses. Linear inequalities add. Since head mass is additive over heads, summing the per-head pass inequalities gives exactly the pass inequality for the aggregate.

The consequence is the sharpest available reading of the deployment slogan:

> **Corollary (Head count does not move the budget).** Two models assembled from head pools of any sizes — say $H_1$ heads and $H_2 \gg H_1$ heads — all of whose heads obey the same per-head budget $K$, have the same model-level budget $K$.

A model can become expensive only by *acquiring a bad head*, never by getting bigger per se. That is a genuinely different statement from "the knee happened not to move in two measurements": it says the direction "more heads" is a direction along which the budget is provably flat.

---

## Transferring a measured budget: how much distortion can you afford?

Suppose you have measured the budget of one model and want to reuse it on another whose attention looks *similar but not identical*. Call two profiles $\lambda$-comparable if $w_1 \le \lambda w_2$ and $w_2 \le \lambda w_1$ pointwise, for some $\lambda \ge 1$.

> **Theorem (Distortion bound and budget transfer).** If $w_1$ and $w_2$ are strictly positive and $\lambda$-comparable, then for every context $n \ge 1$ and every budget $k$,
> $$\frac{R_{w_1}(n,k)}{\lambda^{2}} \le R_{w_2}(n,k).$$
> Consequently, whenever $\lambda^{2}\tau \le 1$,
> $$k^*(w_2, n, \tau) \le k^*\big(w_1, n, \lambda^{2}\tau\big).$$

The square is not an accident: comparability is used once in the numerator of the retained fraction and once, in the opposite direction, in the denominator. Approximate agreement of *shape* — not exact proportionality — is enough to carry a measured budget from one model to another, at a price paid in gate margin.

And the price is real:

> **Theorem (The gate shift cannot be dropped).** The profiles $(95,4,1)$ and $(85,14,1)$ are $4$-comparable, yet at gate $0.9$ and context $3$ their knees are $1$ and $2$ respectively.

Both witnesses are strictly positive and the gate is interior, so this is no degenerate example. Comparability alone does not preserve the knee. Every transferred budget costs margin — and margin is precisely the quantity a two-point size sweep cannot measure.

---

## Refuting the growth law outright

The pre-registered hypothesis was "bigger models need bigger budgets". A measurement can fail to support a law; mathematics can kill it.

> **Theorem (No monotone size law).** There exist two strictly positive attention profiles $w_{\text{small}}$ and $w_{\text{large}}$ such that $M_{w_{\text{small}}}(n) < M_{w_{\text{large}}}(n)$ for every $n \ge 1$ — the second carries strictly more total attention mass at every context, the natural proxy for greater capacity — while at gate $0.98$ and context $512$,
> $$k^*(w_{\text{small}}) = 18, \qquad k^*(w_{\text{large}}) = 8.$$

The witnesses are geometric profiles: $w_i = r^i$ with $r = 4/5$ for the small model, and $10\cdot(3/5)^i$ for the large one. Their knees can be computed exactly, because a geometric profile passes as soon as $r^{K} \le 1-\tau$ (a *context-free* certificate) and fails at $K-1$ as soon as a short reference context says so (the retained fraction of a geometric profile is decreasing in the context, so a failure at a short context propagates upwards). A capacity increase accompanied by a ten-key *decrease* in the budget: "the knee grows with size" is false as a law about attention profiles, independently of any measurement.

Is the measured chain $k^*(512) = k^*(1024) = 16$ at least *consistent*? Yes, exactly:

> **Theorem (The flat chain is realizable).** The geometric profile with ratio $39/50$ has knee exactly $16$ at context $512$ and exactly $16$ at context $1024$, at gate $0.98$.

So flatness is attainable on the nose, but only as a statement about a profile class — never as a universal theorem.

---

## Auditing the measurement itself

The most bracing part of the story is what the mathematics says about the sweep table that produced the headline. Two things.

**First, the grid floor is a real hole.** At context $1024$ the round measured a pass at $16$ keys and *nothing below it*. A single pass at $k$ is compatible with every knee in $[1,k]$:

> **Theorem (Grid-floor indeterminacy).** There are two strictly positive profiles that both clear the $0.98$ gate at $16$ keys with context $1024$, whose knees are $16$ and $1$ respectively.

The low-knee witness is a perfectly ordinary geometric profile with a strong spectral gap — precisely the regime real models are claimed to occupy. So the reported $k^*=16$ at context $1024$ is an **upper bound only**, and the sub-$16$ follow-up sweep is logically necessary rather than a matter of taste. By contrast, at context $512$ the bracket is sound: a fail at $8$ ($0.9727$) and a pass at $16$ ($0.9896$) pin the knee to $(8,16]$ by monotonicity alone.

**Second, the measured curve is not the retained-mass curve.** Retained mass is strictly increasing in the budget below the context length. Both reported sweeps decrease somewhere: at context $512$, $48 \mapsto 0.9993$ then $64 \mapsto 0.9988$; at context $1024$, $48 \mapsto 0.9928$ then $64 \mapsto 0.9927$.

> **Theorem.** No strictly positive attention profile has retained fractions $0.9993$ at budget $48$ and $0.9988$ at budget $64$ on a context of $512$; likewise none has $0.9928$ at $48$ and $0.9927$ at $64$ on a context of $1024$.

The measured agreement ratio is therefore *not* the retained-mass functional — it is a downstream, non-monotone read-out of it. The observed decreases are $5\times10^{-4}$ and $10^{-4}$, comfortably inside the quoted standard error of about $0.3\%$, which locates the effect exactly: sampling noise on an accuracy statistic. Knee brackets read off such a curve are statements about that statistic, not about attention mass.

What *can* a sweep show? Everything monotone, and nothing else:

> **Theorem (Two-point realizability).** For grid points $0 < p < q < n$ and numbers $v_1, v_2$, there exists a strictly positive profile with $R_w(n,p)=v_1$ and $R_w(n,q)=v_2$ **if and only if** $0 < v_1 < v_2 < 1$.

The construction is a three-block profile — constant on $[0,p)$, on $[p,q)$ and beyond $q$ — with block heights solved from the target values. It rests on a small realization principle worth stating on its own: every strictly increasing cumulative function starting at $0$ is the head-mass function of a genuine positive profile, namely its sequence of increments. Applied to the honest part of the data, the pair $8 \mapsto 0.9727$, $16 \mapsto 0.9896$ *is* realizable exactly, so the inconsistency in the table is located precisely at the $48 \to 64$ step.

---

## A number-theoretic mirror

The same invariance has an exact arithmetic shadow, in a setting with no noise at all. A right triangle with integer sides $(a,b,c)$, $a^2+b^2=c^2$, supplies a geometric profile with decay ratio $a/c$. The "size" of a triple is the scaling factor $m$ in $(ma, mb, mc)$.

> **Theorem (The knee is a similarity invariant).** For every $m>0$, the triple $(ma,mb,mc)$ has the same knee as $(a,b,c)$, at every context and every gate.

Scaling a triangle changes its size but not its shape, and the ratio $a/c$ — hence the knee — depends only on the similarity class. This is the same homogeneity as scale invariance of the profile, but acting on the *index* of the family rather than on the weights: two group actions, one invariance. The near-isosceles triple $(696,697,985)$ therefore generates an infinite family $(696m, 697m, 985m)$ of arbitrarily large triples all with knee exactly $12$ at gate $0.98$.

And there is a universal bound with a sharp constant:

> **Theorem (Universal short-leg budget).** Every Pythagorean triple with $0 < a \le b$ has $k^*\big(\text{ratio } a/c\big) \le 12$ at gate $0.98$, at every context length. Eleven keys do not suffice: the triple $(696,697,985)$ needs exactly $12$.

The bound follows from the fact that the short leg of a right triangle satisfies $a/c \le 1/\sqrt 2 \approx 0.708$, so $r^{12} \le 0.708^{12} < 0.02$.

Yet the invariance is not vacuous, because the *other* leg behaves completely differently:

> **Theorem (Budget dichotomy).** Short legs of Pythagorean triples carry a universal $12$-key budget at gate $0.98$, valid at every size and every context. Long legs carry no universal budget at all: for every gate $\tau$ with $5/9 < \tau \le 1$ and every bound $K$, there is a triple and a context whose long-leg profile needs more than $K$ keys.

The long-leg witnesses are near-square triples $(2m+1,\ 2m^2+2m,\ 2m^2+2m+1)$, whose ratio $t/(t+1)$ tends to $1$: a nearly flat profile, and flat profiles have no small budget. And the same single triangle $(3,4,5)$ produces knees $8$ (short leg, ratio $3/5$) and $18$ (long leg, ratio $4/5$) at the same gate and context — while *every* rescaling $(3m,4m,5m)$ reproduces exactly the same pair.

That is the whole story in one sentence: **size is the direction in which the budget provably does not move; shape is the direction in which it moves a lot.**

---

## What this means when you deploy a model

The practical reading is unusually clean. The cache of keys and values a transformer must hold in fast memory is, on this evidence and by these mechanisms, governed by the concentration structure of trained attention — how fast the sorted weights decay — and not by capacity. Adding heads cannot raise it. Rescaling cannot raise it. A shared tail envelope across a family pins it to one number for the whole family. What *can* raise it is a change of shape: a flatter attention profile, one bad head, or a distortion of the profile large enough that the $\lambda^2$ gate shift eats the margin.

So at larger model sizes, the binding memory constraint moves elsewhere — to the weights themselves, not to the cache. The right engineering question is not "how big is the model?" but "how sharp is its attention, and what is its worst head?"

That second question is exactly the one the round failed to measure — the per-head statistics were lost in a harness rewrite — and the aggregation theorem explains why it matters: since the model-level budget is bounded by the worst per-head budget, the per-head spectrum is not a nice-to-have diagnostic. It is the only mechanistic explanation of a model-level knee there is.

---

## Two honest limitations

A two-point size sweep is a thin instrument, and the mathematics says so precisely. It cannot distinguish exact invariance (homogeneity) from approximate invariance (a shared envelope): both produce the same table. It cannot certify a lower bound at its own grid floor. And a transferred budget always spends gate margin that the sweep does not report. The way out is not more size points but a *gate* sweep at fixed budget — cheaper than the budget sweep already performed — which turns a knee measurement into an estimate of the tail decay exponent, and hence into a prediction for contexts nobody has run.

The other limitation is the pleasant kind. The theorems above are about sorted positive sequences. They apply to attention, but nothing in them knows about attention. Any system whose behaviour depends on the top of a sorted, rapidly decaying list of importances — cache design, sparse solvers, ranked retrieval, spectral truncation — inherits them. In all of these, the working set is set by shape, and size is flat.
