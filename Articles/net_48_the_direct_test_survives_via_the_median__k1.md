# The Centre That Cannot Be Moved

## How a single stubborn number survived four failed predictions — and what the geometry of medians has to say about it

### A prediction that missed, and a law that didn't

Here is a story about being wrong in the most useful possible way.

A long-running series of experiments studies a simple, very practical question: in a system that attends to $\mathrm{ctx}$ items at a time, how many of those items do you actually need to keep? Throw away too many and quality collapses; keep them all and you pay the full price. Somewhere in between there is a **knee** — the smallest budget $k^\*$ at which quality still clears a fixed bar. Finding it is worth money: every factor you shave off the budget is a factor of speed.

The knee, unhappily, is noisy. Repeat the same experiment with a different random seed and you get a different $k^\*$. At context length $2048$, three independent repetitions gave

$$k^\* \in \{160,\ 224,\ 256\}.$$

Before the third of those runs, four specific point predictions were written down: $224$, $240$, $256$, $192$. The measured value was $160$. **All four predictions were refuted.** Not narrowly — the measurement landed outside every one of them.

And yet a fifth claim, made at the same time, came through untouched. That claim was not about a point. It was about the *centre* of the distribution:

$$\operatorname{median}\{160,224,256\} = 224 = \tfrac{7}{8}\cdot 256 .$$

Here $256 = d\cdot\mathrm{ctx}/32$ is what one might call the **product point** — a natural budget scale built from the two experimental parameters. At the shorter context $\mathrm{ctx} = 1024$, where the product point is $128$, three earlier seeds had given $\{96, 112, 128\}$ with median

$$112 = \tfrac{7}{8}\cdot 128 .$$

The same constant. Two contexts, six seeds, one number: $7/8$.

Individual seeds are unpredictable. Their median is not. That asymmetry is the subject of this article — and it turns out to be a statement in geometry, not in statistics.

---

### The median is a shape, not a sorting trick

Most people meet the median as a recipe: line the numbers up and take the middle one. That definition is combinatorial and slightly unsatisfying — it treats the numbers as tokens in a list rather than as points in space.

There is a much older definition, and it is geometric. Given points $p_1,\dots,p_n$, ask for the location $t$ that minimises the **total distance**

$$F(t) \;=\; \sum_{i=1}^{n} |t - p_i| .$$

This is the **Fermat–Weber problem**, posed by Fermat for three points in the plane and later used by the economist Alfred Weber to site a factory optimally between its suppliers. Its solution is called the *geometric median*. On a line, the geometric median and the sorted-list median are the same object — and that coincidence is the reason the median behaves so well.

The one-dimensional case is easy to see and easy to prove. Take three sorted points $a \le b \le c$. For any candidate $t$,

$$|t-a| + |t-b| + |t-c| \;\ge\; (c-a),$$

because $|t-a| + |t-c| \ge c - a$ by the triangle inequality, and $|t-b| \ge 0$. Equality forces *both* inequalities to be tight: $t$ must lie between $a$ and $c$, and $t$ must equal $b$. So:

> **Theorem (Fermat–Weber point of a triple).** For $a \le b \le c$ and any real $t$, the total distance $|t-a|+|t-b|+|t-c|$ is at least $c-a$, with equality **if and only if** $t = b$. The middle point is the unique minimiser, and the optimal cost is the spread $c-a$.

This is not a fact about the real line only. The same two-line argument works in any metric space, provided "middle" is replaced by *metric betweenness*: if $d(p,q) + d(q,r) = d(p,r)$, then $d(x,p) + d(x,q) + d(x,r) \ge d(p,r)$ for every $x$, with equality exactly at $x = q$. In a normed space, three points strung along a line therefore have the middle one as their unique geometric median — a fact about the whole ambient space, not merely about the line the data lives on.

Apply this to the measurements. The three knees at $\mathrm{ctx}=2048$, $\{160, 224, 256\}$, have unique geometric median $224$ with optimal cost $96$. The three at $\mathrm{ctx}=1024$, $\{96, 112, 128\}$, have unique geometric median $112$ with optimal cost $32$. The empirical "$7/8$-median law" is thus not a bookkeeping artefact of sorting. It is a **variational** statement: $7/8$ of the product point is the location that minimises total distance to the measured knees.

---

### Why the centre is robust: the median is a projection

The deeper reason the median resists noise is best seen by freezing two of the three measurements and letting the third wander.

Write $\operatorname{med}(a,b,x)$ for the median of three numbers. As a function of $x$ alone, with $a$ and $b$ fixed, it satisfies

$$\operatorname{med}(a,b,x) \;=\; \max\bigl(\min(a,b),\ \min(\max(a,b),\ x)\bigr).$$

In words: **clamp $x$ to the interval spanned by $a$ and $b$.** The median of three is nothing but the nearest-point projection of the free coordinate onto the segment fixed by the other two.

That single identification explains everything the experimenters observed qualitatively.

*The centre can never escape.* A projection lands in its target set, so no third seed, however extreme, can push the median outside $[\,a\wedge b,\ a\vee b\,]$; its range is exactly that compact segment.

*Extreme seeds are absorbed.* Projections are $1$-Lipschitz, and better: they are **firmly nonexpansive**,

$$\bigl(P(x) - P(y)\bigr)^2 \;\le\; (x-y)\bigl(P(x)-P(y)\bigr),$$

a strictly stronger inequality that says the projection never merely translates a displacement — it always contracts it against its own direction. Concretely, at $\mathrm{ctx}=2048$ the two earlier seeds fixed the segment $[224, 256]$, and the third seed came in at $160$. That is a distance of $64$ below the segment — a large excursion, more than half the segment's own length twice over — and the projection absorbed all of it. The centre did not move by even one unit.

*The centre is stable on a whole ray, not just at a point.* Which third seeds leave the median at $224$? Exactly those with $x \le 224$: the fibre of the projection over an endpoint of the segment is a closed half-line — the *normal cone* of the segment at that endpoint — while over an interior point it is a single point. So the set of "harmless" third seeds is the entire ray $(-\infty, 224]$, containing the measured $160$ with room to spare.

This last statement also corrects a plausible-sounding informal claim made during the round: *"only a third seed $\ge 256$ would shift the median."* That is false. The value $x = 240$ is well below $256$, yet $\operatorname{med}(256, 224, 240) = 240 \ne 224$. The correct threshold is $224$, not $256$ — the endpoint of the segment, not its far end. The geometry gives the sharp answer where intuition gave a loose one.

*The mean has none of this.* For contrast: with two seeds fixed, the arithmetic mean of three is a surjection onto all of $\mathbb{R}$ — a single wild seed drags it arbitrarily far. On the measured triple, the mean is $640/3 \approx 213.33$, which is not $224$ and is not $7/8$ of anything natural. The centre is robust; the average is not. That is the precise sense in which "take the median" was the right protocol.

---

### The picture in the plane: two rays and one that isn't

Plot each measurement as a point $(\mathrm{ctx},\, k^\*)$ in the plane and the verbal summary sharpens into geometry. Six points, in three families:

| context | low | median | top (= product point) |
|---|---|---|---|
| $1024$ | $96$ | $112$ | $128$ |
| $2048$ | $160$ | $224$ | $256$ |

Two points lie on a common ray through the origin exactly when the $2\times 2$ determinant $x_1y_2 - y_1x_2$ vanishes.

**The top edge is a ray.** $(1024,128)$ and $(2048,256)$ both have slope $1/8$; the determinant is zero. The product-point law $k^\* \le d\cdot\mathrm{ctx}/32$ is exactly proportionality.

**The median is a ray too.** $(1024,112)$ and $(2048,224)$ both have slope

$$\frac{7}{64} \;=\; \frac{7}{8}\cdot\frac{1}{8},$$

the product-law slope scaled by the constant $7/8$. And this is genuinely predictive rather than doubly fitted: a proportional law through the origin matching the $\mathrm{ctx}=1024$ median is *forced* to have slope $7/64$ — one measurement determines the constant with no freedom left — and that same slope then hits the $\mathrm{ctx}=2048$ median on the nose. One context fixes the law; the other tests it.

**The low tail is not a ray.** $(1024, 96)$ and $(2048, 160)$ give determinant $1024\cdot 160 - 96\cdot 2048 = -32768 \ne 0$; the triangle they span with the origin has area $16384$. No proportional law fits the low tail.

Doubling the context is the dilation $p \mapsto 2p$ of the plane. It carries the $8\times$ top point to the $16\times$ top point and the $8\times$ median point to the $16\times$ median point — the law is *equivariant* under context doubling. It fails on the low tail, and the failure is a clean scalar: the dilated low tail is $2\cdot 96 = 192$, the measured one is $160$, a defect of exactly

$$32 \;=\; \frac{256}{8} \;=\; \frac{P}{8},$$

one eighth of the product point. And no dilation whatsoever, by any factor, matches the whole $8\times$ configuration onto the $16\times$ one: the factor forced by the top points is $2$, the factor forced by the low points is $5/3$. **The knee distribution is not self-similar, even though its median and its upper edge are.** All of the context dependence of the *distribution* — not just its centre — is concentrated in a single scalar defect.

That has a crisp consequence for the spread. Normalising each triple by its product point gives $(3/4,\, 7/8,\, 1)$ at $\mathrm{ctx}=1024$ and $(5/8,\, 7/8,\, 1)$ at $\mathrm{ctx}=2048$. The optimal total-distance costs are $1/4$ and $3/8$ respectively, and

$$\frac{3}{8} = \frac{3}{2}\cdot\frac14 .$$

The reported "roughly $50\%$ wider spread" is exact: the longer context's optimal transport cost is precisely $3/2$ times the shorter one's. Moreover the widening is *entirely* a low-tail phenomenon — the top two normalised coordinates are identical at the two contexts, and the increase in cost, $3/8 - 1/4 = 1/8$, equals exactly the drop in the low coordinate, $3/4 - 5/8 = 1/8$.

---

### A flat face on a crooked set

One more piece of geometry hides in those normalised triples, and it says the agreement between the two contexts is a real structural fact rather than a tautology.

View a normalised triple as a point of $\mathbb{R}^3$ and consider the **level set** of the median map, $\{v : \operatorname{med}(v) = 7/8\}$. Both measurements lie in it, by construction. What is not automatic is that the entire *segment joining them* lies in it too.

It does, and for a strong reason: the whole half-line

$$\{(t,\ 7/8,\ 1)\ :\ t \le 7/8\}$$

sits inside the level set. The low coordinate is invisible to the centre for as long as it stays below it. And this half-line is maximal — the moment $t$ rises above $7/8$ (while staying under the pinned top coordinate $1$), the median moves with it, $\operatorname{med}(t, 7/8, 1) = t$. So the two contexts occupy a common *flat face* of the level set, and that face extends past both of them: the low tail is free to keep growing, over more contexts, without disturbing the centre.

Why is that a genuine statement? Because the level set is **not convex**. The triples $(5/8,\, 7/8,\, 1)$ and $(7/8,\, 1,\, 5/8)$ both have median $7/8$, but their midpoint $(3/4,\, 15/16,\, 13/16)$ has median $13/16 \ne 7/8$. Two points can each have the right centre while everything between them does not. That the two measured contexts nevertheless lie in a common convex face of this crooked set is information about the data, not about the definition of a median.

---

### What a fourth seed can, and cannot, do

The next experiment is already named: a **fourth** seed at $\mathrm{ctx} = 2048$. With four measurements, the parity flips, and the geometry changes qualitatively. Fermat–Weber problems with an even number of points do not have unique solutions.

> **Theorem (even samples).** For sorted data $a \le b \le c \le d$ and any $t$,
> $$|t-a| + |t-b| + |t-c| + |t-d| \;\ge\; (d-a) + (c-b),$$
> with equality **if and only if** $b \le t \le c$. The set of optimal centres is the closed middle segment $[b,c]$, and it degenerates to a single point exactly when the two middle order statistics coincide.

So "the median of a four-seed experiment" is not a number; it is a *set*. Any prediction stated as a point is therefore already the wrong shape of prediction. The right one is about the position of that set's endpoints — and it can be stated now, before the run:

> **Theorem (the fourth seed cannot move the centre).** Let $x$ be the fourth measured knee, whatever it turns out to be. Then $224$ is an optimal centre of $\{160, 224, 256, x\}$: for every $t$,
> $$\bigl|\,t-160\,\bigr| + \bigl|\,t-224\,\bigr| + \bigl|\,t-256\,\bigr| + \bigl|\,t-x\,\bigr| \;\ge\; 96 + |224 - x| ,$$
> with equality at $t = 224$. Moreover the optimal cost is exactly $96 + |224 - x|$: the response to the new datum is exactly linear, with slope $1$ away from $224$.

The proof is two triangle inequalities: $|t-160| + |t-256| \ge 96$ pins the outer pair, and $|t-224| + |t-x| \ge |224 - x|$ pins the inner pair, and both are tight at $t = 224$.

The regimes are sharp. If the fourth seed repeats the low tail, $x \in [160, 224]$, the optimal set is the segment $[x, 224]$ — it widens *downwards*, with its **upper endpoint pinned at the $7/8$ centre**. If instead $x \in [224, 256]$, the optimal set is $[224, x]$ — widening upwards, lower endpoint pinned. Either way, $224$ is an endpoint. The one case in which the centre remains a *unique* optimum is the knife edge $x = 224$ exactly.

The moral is unusually clean. **No fourth seed can refute the $7/8$ centre in the variational sense. It can only destroy uniqueness — and it does so unless it lands exactly on the centre.** A prediction that the pending measurement cannot refute is, in the usual scientific idiom, a bad one; but that is precisely the point. The fourth seed is not a test of the centre at all. It is a test of the *low tail* — of whether the value $160$, and the ratio $5/8$ it represents, is a stable feature of the longer context or an accident of one seed.

---

### The general law behind all of it

Everything above is a shadow of one clean characterisation, valid for samples of any size and either parity.

Call a point $m$ **balanced** for a sample $S$ if neither side strictly outweighs the other: at least as many entries of $S$ are $\le m$ as are $> m$, and at least as many are $\ge m$ as are $< m$.

> **Theorem (characterisation of geometric medians on a line).** A point $m$ minimises the total distance $\sum_{x \in S} |m - x|$ **if and only if** $m$ is balanced for $S$.

Sufficiency needs no completeness or even any real numbers: it holds in any linearly ordered abelian group, by a counting argument. Move from $m$ toward $t$; every sample point on the near side pays the displacement, every point on the far side refunds it, and balance says the payers are at least as numerous as the refunders. Necessity is the converse: if one side is strictly heavier, step to the *nearest* sample point on that side. Because the step jumps over no data, the cost changes exactly linearly, by (light side minus heavy side) times the step length — a strictly negative amount. So $m$ was not optimal. The witness is a data point, so the argument is finitary: no limiting process is needed.

Two corollaries fall out immediately. For an odd sample the counting median is balanced, so the classical odd-size theorem is the odd case of this one — with the sharp refinement $F(m) + |t-m| \le F(t)$, which delivers minimality and uniqueness in one stroke: the cost grows at unit rate, at least, as you leave the median. And because the total-distance functional is convex — a pointwise consequence of the triangle inequality — the set of minimisers is convex, hence an interval. A point for odd samples; a genuine segment for even ones.

That is the structural reason a fourth seed can only *widen* the optimal centre into a segment rather than move it. Not a coincidence of the particular numbers $160$, $224$, $256$; a theorem about the shape of the $\ell^1$ landscape.

---

### The moral

Four point predictions were made, and four failed. One structural prediction was made, and it held. The difference between them was not luck; it was that the structural prediction was about a quantity that the geometry protects.

Per-seed knees scatter because they are the output of a noisy optimisation whose exact threshold sits between grid points — the seed reported here crossed the bar at $k^\* = 160$ with a margin of just $+0.0012$, so razor thin that the true knee lies somewhere around $150$–$160$, invisible to the sampling grid. Nothing about that number is stable enough to predict. But their median is a projection, and a projection is firmly nonexpansive: it absorbs the excursion of a wild datum instead of transmitting it. That is why the third seed's $64$-unit dive below the segment moved the reported centre by nothing at all.

There is a practical payoff too. The bound $k^\* \le d\cdot\mathrm{ctx}/32$ passed at every seed at both contexts — six for six — which makes it a usable guarantee rather than a trend, and the centre sits a factor $8/7$ below it.

When you cannot predict a measurement, predict its centre — and then prove that the centre is a projection, so that you know in advance exactly how much abuse it can absorb.
