# The Ruler, Not the Room: How a Measurement Grid Manufactured a Scientific Disagreement

## Two labs, two numbers, one curve

Imagine two teams measuring the same quantity in the same way, on two halves of the same pile of text. The quantity is a *memory budget*: when a language model attends to a long context, how many of the stored keys must it keep to retain, say, $98\%$ of the quality it would have with everything kept? Call the smallest sufficient budget the **knee**, written $k^\*$. Below the knee, quality falls off; at and above it, quality is good enough.

Team A, working on the first shard of text with a fine measurement grid, reports $k^\* = 24$. Team B, working on the second shard with a coarser grid, reports $k^\* = 32$. The gap is a third of the budget. That is exactly the size of discrepancy that launches a research program: perhaps the second shard is linguistically different, perhaps its attention mass is more spread out, perhaps there is a real "shard effect."

There isn't. There is only a ruler effect.

When Team B's sweep is rerun on the *same* shard with the *same* text and the *same* quality gate, but with the finer grid of candidate budgets $\{16, 20, 24, 28, 32\}$, the measured retentions are

| budget $k$ | 20 | 24 | 28 | 32 |
|---|---|---|---|---|
| retained quality | $0.9790$ | $0.9832$ | $0.9853$ | $0.9862$ |

against a gate of $0.98$. The first budget that clears the gate is $24$. Corpus B's knee is $24$, exactly as corpus A's is. The earlier $32$ was never a fact about the corpus. It was a fact about the coarse grid $\{8, 16, 32, 64\}$, which simply has no point between $16$ and $32$ and therefore *cannot* report $24$ even when $24$ is the truth.

This little story turns out to have a crisp and rather beautiful mathematical skeleton, and the skeleton has consequences well beyond one experiment. It says exactly what a grid measurement of a threshold can and cannot tell you; exactly when two independent replications are *forced* to agree; and — this is the part with real design bite — exactly how much a sweep with $s$ sample points can possibly resolve, which grid achieves that maximum, and why that optimal grid is unique.

## What a sweep actually measures

Model the experiment abstractly. Let $A(k)$ be the retained quality at budget $k$, a nondecreasing function of $k$ (more memory never hurts), and let $g$ be the gate, here $0.98$. The **true knee** is
$$k^\*(A,g) \;=\; \min\{k : A(k) \ge g\}.$$
But an experimenter never sees $A$; she sees $A$ evaluated at a finite set $G$ of sampled budgets. What she reports is the **grid knee**,
$$\hat{k}(G,A,g) \;=\; \min\{k \in G : A(k) \ge g\}.$$

The first theorem is the whole story in one line.

> **Factorisation Theorem.** For any nondecreasing curve $A$ and any grid $G$ containing at least one budget that clears the gate,
> $$\hat{k}(G,A,g) \;=\; \min\{k \in G : k \ge k^\*(A,g)\}.$$

In words: *a sweep never measures the curve. It measures the ceiling of the true knee inside its own grid.* Every other feature of the curve — its shape, its slope, its absolute accuracy level, which corpus produced it — is invisible to the sweep once the true knee is fixed. Two corpora with the same knee give identical sweeps at every gate; two corpora with different knees in the same grid cell also give identical sweeps at every gate.

Three consequences follow immediately, and each has an experimental moral.

**A sweep can only over-report.** Since the reported value is a grid point at or above $k^\*$, we always have $\hat{k} \ge k^\*$. A knee measurement is an upper bound, never an underestimate. If you provision memory at the reported budget, you are safe; you are merely possibly wasteful.

**A grid reading is exact precisely when it is lucky.** $\hat{k} = k^\*$ if and only if $k^\* \in G$. There is no cleverness that repairs this: exactness is grid membership, nothing else.

**Refining can only lower the reading.** If $G \subseteq H$ then $\hat{k}(H) \le \hat{k}(G)$. So when a finer sweep contradicts a coarser one, the finer one is *always* the smaller number, and the difference is bookkeeping, not physics.

For the doubling grids $\{1, 2, 4, 8, \dots\}$ that everyone reaches for first, one can bound the damage exactly: the reported knee always satisfies $\hat{k} < 2k^\*$. The observed inflation from $24$ to $32$ is a factor $1.33$, comfortably inside that ceiling and unable to exceed it. The disagreement between the two teams was never even large enough to be surprising.

And the artifact cannot be reasoned away after the fact. One can write down two nondecreasing curves that agree at *every* point of the coarse grid $\{8,16,32,64\}$ — so they produce identical sweep outputs at every possible gate — while their true knees are any two values you like inside $(16, 32]$. A coarse reading of $32$ is logically compatible with a true knee of $17$, of $24$, or of $32$. Comparing a coarse reading on one corpus against a fine reading on another can therefore never be evidence of a corpus-level difference. It is a comparison of rulers.

Applied to the measured data, this yields the concrete verdict. The corpus-B retention curve at context $2048$ has true knee $24$; the fine grid reports $24$; the coarse grid $\{8,16,32,64\}$, reading *the very same curve*, reports $32$. One corpus, one curve, two answers. No shard-level effect is needed to manufacture the disagreement, and none exists.

## When replication is guaranteed, not lucky

The two corpora agree on the knee at all three contexts tested — $16$ keys at context $512$, $20$ at $1024$, $24$ at $2048$ — a perfect $3 \times 2$ table. Is that a coincidence worth celebrating?

No: it is forced, and one can say by how much.

> **Replication Law.** Suppose two retention curves are uniformly close, $|A(j) - B(j)| \le \varepsilon$ for every budget $j$. Suppose the first curve clears the gate at $k$ with margin greater than $\varepsilon$, i.e. $A(k) \ge g + \varepsilon$, and misses it with margin greater than $\varepsilon$ at every smaller budget, i.e. $A(j) + \varepsilon < g$ for all $j < k$. Then the second curve has *exactly* the same knee: $k^\*(B, g) = k$.

The measured margins make this quantitative. Corpus B clears the $0.98$ gate at budget $24$ by $0.0032$ and misses it at budget $20$ by $0.0010$. Hence **any** corpus whose retention curve stays uniformly within $\varepsilon = 0.0009$ of corpus B's has knee exactly $24$. Replication across the two shards is not a happy accident; it is a theorem about the size of the measured margins.

The hypothesis is also indispensable, in the strongest possible sense: for every tolerance $\varepsilon > 0$ and every target $N$, there exist two nondecreasing curves within $\varepsilon$ of each other whose knees are $1$ and $N$. Knees are discontinuous functionals of curves. What tames them is margin, and only margin. So the honest way to report a replicated knee is to report the margins alongside it — they are the quantity that certifies the replication.

## Accuracy level and knee position are independent

A second worry about the two shards: corpus B's absolute accuracy is $0.4946$ against corpus A's $0.4760$. The second shard is simply easier. Doesn't that contaminate the comparison?

It cannot, and the reason is a one-line invariance. The quantity being gated is not raw accuracy but **retention**, $R(k) = \mathrm{raw}(k) / \mathrm{raw}(\mathrm{ctx})$, the fraction of full-context quality preserved at budget $k$. Multiply the whole raw sweep by any positive constant $c$ — that is precisely what "an easier corpus" means to first order — and $R$ is unchanged, since $c \cdot \mathrm{raw}(k) / (c \cdot \mathrm{raw}(\mathrm{ctx})) = R(k)$. Hence the knee is unchanged, at every gate.

In particular, if corpus B's sweep differed from corpus A's by exactly the difficulty factor $0.4946/0.4760$, the two knees would be equal at every gate whatsoever. Accuracy level and knee position are independent coordinates of a model's behaviour: the first says how well it does, the second says how much memory it needs to do it. Observing that they moved independently in the data is not a paradox — it is the expected behaviour.

## The chain, and the law behind it

With the artifact removed, the deployment table is clean and it has structure:
$$k^\*(512) = 16, \qquad k^\*(1024) = 20, \qquad k^\*(2048) = 24.$$
Four extra keys per doubling of the context. In closed form,
$$k^\*(\mathrm{ctx}) \;=\; 4\log_2 \mathrm{ctx} \;-\; 20 .$$

Two things are worth saying about this. First, the third cell was a **prediction, not a fit**: any law affine in $\log_2 \mathrm{ctx}$ matching the first two cells is *forced* to give $24$ at $2048$, since two points determine a line — and it pins the slope to exactly $4$ keys per doubling and the intercept to $-20$. Second, the prediction is falsifiable: any competing slope $a \ne 4$ that still matches context $512$ predicts something other than $24$ at context $2048$. The measurement discriminates. That it then returned $24$, twice, on two disjoint corpora, is a genuine confirmation.

Where does a logarithmic law come from? It sits strictly between the two textbook stories about attention mass, and rules both of them out.

* If the attention weights follow a **Zipf** (heavy-tailed) profile $p_i \propto 1/(i+1)$, the retained mass at budget $k$ grows like $\log k / \log n$. Capturing $98\%$ of harmonic mass out of $2^{11}$ keys then requires more than $32$ keys — strictly more than the measured $24$. Worse, the required budget is *unbounded*: for every gate $\tau \in (0, 1]$ and every $K$ there is a context length whose Zipf knee exceeds $K$. Heavy tails are simply too expensive to match the data.
* If the weights follow a **truncated geometric** (light-tailed) profile $p_i \propto 2^{-i}$, the knee at the $0.98$ gate is exactly $6$ keys — and it is exactly $6$ at *every* context length beyond a trivial threshold. Light tails are too cheap, and, decisively, too rigid: their knee does not move with the context, whereas the measured knee moves by $8$ keys from $512$ to $2048$.

So the profiles realising the measured deployment table live strictly between Zipf and geometric: they must be light enough that $24$ keys suffice at context $2048$, yet heavy enough that the required budget grows without saturating. That trichotomy — too dear, too cheap-and-rigid, and the logarithmic middle — is where the empirical result feeds back into modelling.

## How much can a sweep resolve? An exact answer

The grid artifact raises an engineering question that turns out to have a startlingly clean solution. Suppose you can afford $s$ sample points, and you want your reported knee to be within a factor $r$ of the truth. How wide a range of possible knees can you cover?

Make the deployment constraint precise. A grid $G$ **localises** the range $[1, N]$ to a factor $r$ if for every budget $c \le N$ there is a sampled point $g \in G$ with
$$c \;\le\; g \;\le\; r\,c,$$
i.e. a point at or above $c$ (so you never under-provision) but overshooting by at most $r$. By the Factorisation Theorem, this is exactly the statement that the sweep reports every true knee in $[1, N]$ to within a factor $r$.

> **Sweep Capacity Theorem.** For $r \ge 1$, the largest range that $s$ sample points can localise to a factor $r$ is exactly
> $$\Sigma(r, s) \;=\; r + r^2 + \cdots + r^s,$$
> attained by the *offset* geometric grid $\{\,r,\; r + r^2,\; \dots,\; r + \cdots + r^s\,\}$.

The upper bound comes from peeling the largest sample point $M$: it can serve only budgets $c \ge M/r$, so the remaining $s-1$ points must, by themselves, localise everything below roughly $M/r$; induction plus the relation $M \le r\lfloor (M-1)/r\rfloor + r$ closes the loop. Attainment is the observation that the offset grid places each point at the exact *top* of the interval it can serve, wasting nothing.

That offsetting is the surprise. The classical grid $\{1, r, r^2, \dots\}$ is *not* optimal — indeed, for $r \ge 2$ the optimum never samples the budget $1$ at all, so the classical grid is structurally excluded. And the true capacity $\Sigma(r,s)$ is squeezed strictly between the naive guess $r^s$ (too small: two points at $r = 2$ already cover $[1,6] > 4$, via $\{2,6\}$) and the crude packing bound $(r+1)^s$ (too large, always).

There is more: the optimum is *unique*.

> **Rigidity Theorem.** If a grid of $s$ points localises the full capacity range $[1, \Sigma(r,s)]$ to a factor $r$, it *is* the offset geometric grid. No other placement achieves capacity.

And uniqueness is a knife-edge phenomenon: one budget below capacity it already fails. At $r = 2$ with two points, both $\{2,6\}$ and $\{2,5\}$ localise $[1,5]$; only $\{2,6\}$ survives to $[1,6]$. Rigidity is a property *of the capacity*, not of good grids in general.

Turn the theorem around and you get the practical dual: the minimum number of points needed to cover $[1,N]$ to a factor $r$ is the least $s$ with $N \le \Sigma(r,s)$. For the experiment in question: four doubling-accurate points buy exactly $[1, 30]$, achieved *only* by $\{2, 6, 14, 30\}$; the coarse grid actually used, $\{8, 16, 32, 64\}$, has the same four points but is blind at budget $3$ (there is nothing in $[3,6]$), so it does not even cover $[1,30]$. And honestly covering $[1,64]$ costs exactly **six** points. The original sweep was under-resourced by half — which is, in retrospect, exactly why it produced an artifact.

## One number governs a sweep

The deployment constraint above is deliberately one-sided: never report below the knee. What if you relax it and allow a factor $r$ of slack on *either* side — good enough for exploratory work, where you only want to know the knee's order of magnitude?

> **Two-Sided Capacity Theorem.** The maximum range that $s$ points can cover with a factor $r$ of slack on either side is exactly $\Sigma(r^2, s) = r^2 + r^4 + \cdots + r^{2s}$, again with a unique optimal grid.

At $r = 2$ and $s = 4$: the two-sided capacity is $340$, achieved uniquely by $\{2, 10, 42, 170\}$, versus a one-sided capacity of $30$ achieved uniquely by $\{2, 6, 14, 30\}$. The gap is enormous, and it can be priced precisely:
$$\Sigma(r, 2s-1) \;<\; \Sigma(r^2, s) \;<\; \Sigma(r, 2s) .$$
An $s$-point two-sided sweep beats a $(2s-1)$-point one-sided sweep and loses to a $2s$-point one. **The price of never under-provisioning is a factor two in sweep points — and no more.** That is a clean, usable number for anyone budgeting an experiment.

The pattern $r \rightsquigarrow r^2$ between the two theorems is not a coincidence, and the final result explains it. Let the tolerance be asymmetric: a grid $G$ is allowed to overshoot a budget $c$ by a factor $b$ and undershoot by a factor $a$, meaning some $g \in G$ satisfies
$$g \le b\,c \qquad\text{and}\qquad c \le a\,g .$$

> **Asymmetric Capacity and the Product Law.** For $a, b \ge 1$, the exact capacity of $s$ points is $\Sigma(ab, s)$, attained by the unique grid $\{\,b\,(\Sigma(ab, j) + 1) : 0 \le j < s\,\}$. Consequently the set of achievable ranges depends on the pair $(a,b)$ **only through the product $ab$**.

One number governs a sweep. The one-sided theorem is the case $(a,b) = (1,r)$, the two-sided theorem the case $(a,b) = (r,r)$ — hence $r$ versus $r^2$ — and their optimal grids are the corresponding instances of the single asymmetric optimum. Tolerance is a currency, freely convertible between the two sides at par.

The concrete instance is striking. With four sample points:

* allowed a factor $2$ upward only, you localise $[1, 30]$;
* allowed a factor $2$ on *either* side, you localise $[1, 340]$;
* allowed a factor $4$ upward only, you localise $[1, 340]$ — *exactly the same range*.

Doubling your one-sided tolerance is worth precisely as much as symmetrising it. If you need never to under-provision, you can buy back every bit of the resolution you lost simply by loosening the overshoot factor from $2$ to $4$. Nothing else about the asymmetry matters.

## The moral

The episode began with a mundane-looking inconsistency between two experiments and ended with an exact theory of what a grid measurement of a threshold can say. The verdict on the original question is unambiguous: the corpus-B disagreement was a grid artifact, the $\{16, 20, 24\}$ chain replicates cell-for-cell across two disjoint corpora at all three contexts, and the accuracy difference between the corpora is invisible to the knee by an exact invariance.

But the durable content is the design theory that the artifact forced into the open. A sweep reports the ceiling of the truth in its own grid, and nothing more. Replication is a margin phenomenon with a computable threshold. The resolving power of $s$ sample points at tolerance $(a,b)$ is exactly $ab + (ab)^2 + \cdots + (ab)^s$, the optimal placement is offset-geometric and unique, and only the product $ab$ matters. Whenever you measure a threshold by sampling — a phase transition in a simulation, a dose response, a scaling knee — these are the rules of the instrument, and it is far cheaper to know them before the sweep than to discover them in a disagreement afterwards.
