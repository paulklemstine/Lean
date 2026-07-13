# When a Textbook Threshold Is Simply Wrong: Counting the Pieces of a Graph

## A conjecture that felt too clean

Mathematics is full of formulas that look so tidy you assume they must be true. One of them appears in the study of *dense graphs* — the mathematical objects that model everything from social networks to statistical-physics lattices. The formula concerns how "spread out" a network can be while still being locally crowded everywhere you look.

Here is the setting in ordinary words. Imagine a gigantic network — so large that it is more useful to describe it by a smooth density function than by listing edges. Mathematicians call such an idealized object a **graphon**. You can think of a graphon $W$ as a rule that assigns, to every pair of points $x$ and $y$ in a population, a number $W(x,y)$ between $0$ and $1$: the probability that $x$ and $y$ are connected.

Now suppose the network is *locally dense*: no matter which sub-community $S$ you zoom in on, the average connection strength inside $S$ is at least some fixed level $\rho$. Formally,

$$\frac{1}{|S|^2}\int_{S\times S} W \;\ge\; \rho \qquad \text{for every set } S.$$

This is a strong, uniform crowding condition. A classical inequality — the lower bound at the heart of the Kohayakawa–Nagle–Rödl–Schacht circle of results — then says that if you count how often a small pattern graph $F$ with $e(F)$ edges appears, weighted multiplicatively, you can never dip below $\rho^{e(F)}$. Density everywhere forces patterns everywhere.

The tidy-looking conjecture asked what happens when you *soften* the counting. Instead of the ordinary (average) count, use an $L^p$ average — a knob $p$ that, when small, rewards concentration and, when large, rewards uniformity. The claim was:

> **The suspect claim.** For a pattern graph $F$ with $m$ edges and $n$ non-isolated vertices, if
> $$p < \frac{\binom{n}{2}}{m},$$
> then some locally dense graphon $W$ manages to make the $L^p$ pattern count drop below the "forbidden" value $\rho^{e(F)}$.

In other words: below the threshold $\binom{n}{2}/m$, the classical lower bound can be cheated. The formula $\binom{n}{2}/m$ is irresistibly clean — it is the number of *possible* edges among $n$ vertices divided by the number of *actual* edges. It smells right.

This article is about discovering that, for a large family of patterns, **it is wrong** — and about the surprisingly elementary reason why.

## The one case where the formula is perfect

Start with the simplest possible pattern: a single edge, $K_2$, which has $n=2$ vertices and $m=1$ edge. The formula predicts a threshold of $\binom{2}{2}/1 = 1$.

For the single edge the $L^p$ count is just the $p$-th power average of $W$ itself, and the story is completely settled by a classical fact about averages, the **power-mean inequality**: raising to a power $p\ge 1$ and averaging can only *increase* a mean. Concretely, one proves:

> **Single-edge lower bound.** For every $p \ge 1$ and every $\rho$-locally dense graphon $W$ (with values in $[0,1]$),
> $$\|W_{K_2}\|_{L^p} \;\ge\; \rho.$$

So above the threshold there is no cheating. And below it there is: for any $0 < p < 1$ one can write down an explicit two-block graphon — connections fully present inside two equal communities and absent between them — that is genuinely $\rho$-locally dense yet has

$$\|W_{K_2}\|_{L^p} \;<\; \rho.$$

Concretely, split the population into $k$ equal blocks, connect everything inside each block and nothing across blocks. This is $\rho$-locally dense with $\rho = 1/k$, and its $L^p$ value is $(1/k)^{1/p}$, which slips below $\rho = 1/k$ exactly when $p<1$. Putting the two halves together:

> **Sharp single-edge threshold.** The single edge has threshold exactly $p^\star = 1 = \binom{2}{2}/1$. The conjecture is correct here — and sharp.

So far the clean formula looks vindicated. This is exactly the trap.

## Two edges break it

Now take the next simplest pattern: the **2-edge matching** $M_2$, two *disjoint* edges — four vertices, two edges, no shared endpoints. Here $n=4$, $m=2$, and the suspect formula predicts a threshold of

$$\frac{\binom{4}{2}}{2} = \frac{6}{2} = 3.$$

The prediction is dramatic: for every $p<3$ — including the perfectly ordinary $p=2$ — a locally dense counterexample should exist.

It does not. The reason is a factorization so clean it barely needs a picture. Because the two edges of $M_2$ share no vertices, the multiplicative count over $M_2$ splits into a product of two independent single-edge counts:

> **Matching factorization.** For every graphon $W$ and every $p$,
> $$\|W_{M_2}\|_{L^p} \;=\; \|W_{K_2}\|_{L^p}^{\,2}.$$

Now combine this with the single-edge lower bound. For any $p\ge 1$ we already know $\|W_{K_2}\|_{L^p}\ge \rho$, so squaring gives

> **The contrarian theorem.** For the 2-edge matching $M_2$ and *every* $p\ge 1$, every $\rho$-locally dense nonnegative graphon satisfies
> $$\|W_{M_2}\|_{L^p} \;\ge\; \rho^{2}.$$
> In particular there is **no** counterexample anywhere on $1 \le p < 3$, and the literal $\binom{n}{2}/m$ threshold is **false**.

The true threshold for $M_2$ is $p^\star = 1$, not $3$. And below $p=1$ the two-block construction squared *does* give a genuine counterexample, so $1$ is exactly right. The formula overshot by a factor of three — and the gap only grows: for a matching with $m$ disjoint edges the formula predicts $2m-1$, while the true threshold stays pinned at $1$. The error is unbounded.

## What the formula forgot: the number of pieces

Why did such a natural formula fail so badly? The answer is a single graph invariant the formula never mentions: the **number of connected components**.

Think again about the block constructions — the only tool the conjecture's "there exists a counterexample" direction really has. A block graphon colors the population into $k$ blocks and decides connections purely by block membership. When you count copies of a pattern $F$ against such a kernel, only one kind of vertex-coloring survives: the colorings that assign the *same block to every pair of adjacent vertices*. Every other coloring contributes zero.

Here is the elementary but decisive observation. **A coloring that is constant across every edge is exactly a coloring that is constant on each connected piece of the graph.** If two vertices are joined by a path, and colors never change along an edge, then the two endpoints get the same color. So a "legal" coloring is free to choose one color per connected component and nothing more:

> **The counting bridge.** The colorings of a graph's vertices with $k$ colors that are constant along every edge are in exact correspondence with arbitrary colorings of its *connected components*. Consequently their number is
> $$k^{\,c}, \qquad c = \text{number of connected components}.$$

That exponent $c$ is the whole story. Feeding the count into the block functional gives a clean closed form:

> **Block-kernel closed form.** Summing the pattern functional of a block-diagonal kernel (value $t$ within a block, $0$ across blocks) over all $k$ colorings equals
> $$t^{\,D}\cdot k^{\,c},$$
> where $D$ is the number of directed edges of the pattern and $c$ its number of components.

Normalize this (divide by $k^{n}$ for the $n$ vertices, and dial the block weight to keep local density at level $\rho$) and the reachable $L^p$ value becomes proportional to $k^{\,c - n + mp}$. Sending $k\to\infty$, this drops below the forbidden value precisely when the exponent is negative:

$$p \;<\; \frac{n - c}{m}.$$

So the *honest* threshold that block constructions can reach is $\dfrac{n-c}{m}$ — not $\dfrac{\binom{n}{2}}{m}$. The conjecture had silently replaced the number of components $c$ with something much larger, inflating the threshold.

Check the two cases against this corrected law:

- **Single edge:** $n=2$, $m=1$, one component $c=1$, giving $(2-1)/1 = 1$. ✔ Matches the sharp threshold.
- **2-edge matching:** $n=4$, $m=2$, two components $c=2$, giving $(4-2)/2 = 1$. ✔ Matches the true threshold, and exposes the false $3$.

And since $n - c \le \binom{n}{2}$ always, the corrected threshold is *never* larger than the conjectured one; for matchings the two diverge without bound. The clean formula was an upper fantasy; the number of pieces is the reality.

## The deeper lesson: geometry hiding in an inequality

What makes this satisfying is not just that a plausible formula was corrected, but *how*. The correction came from noticing that an analytic quantity — the size of an $L^p$ pattern integral, a smooth object living in the world of measures and averages — was secretly governed by a discrete, topological feature of the pattern: how many separate pieces it falls into.

This kind of bridge, where counting connected components controls the magnitude of an integral, recurs throughout mathematics. It is the same spirit in which the number of "holes" of a surface controls the outcome of a curvature integral, or the number of pieces of a space controls the rank of its simplest invariants. Here the mechanism is stripped to its essentials: constant-along-edges equals constant-on-components, and therefore the count is $k^{c}$.

The upshot is a corrected map of the landscape. The genuine phenomena are:

1. For a single edge, softening the count to $L^p$ can cheat the classical density lower bound **exactly** when $p<1$, and never above.
2. For disjoint edges the count simply factorizes, so no amount of clever construction beats the classical bound for any $p\ge 1$ — the conjectured window $1\le p<3$ is empty.
3. Behind both facts sits one invariant: block constructions reach down to $(n-c)/m$ and no further, because the number of legal colorings is the number of components-many independent choices.

## Where the trail leads

The corrected threshold $(n-c)/m$ is now proven to be *reachable* by explicit constructions, and for matchings it is proven to be *optimal*. Whether $(n-c)/m$ is the exact threshold for **every** pattern is open. The first genuinely new test case is the triangle $K_3$ ($n=3$, $m=3$, one component), where block constructions reach $2/3$; does a counterexample survive up to $p=1$, or does the triangle behave like a single edge? Settling this likely requires either a cleverer construction or a Sidorenko-type lower bound.

Beyond block kernels lie richer constructions — rank-one positive perturbations of the form $W = \rho + c\,\varphi(x)\varphi(y)$, which are automatically locally dense and far more flexible than blocks. These are the natural candidates to push past $(n-c)/m$, if anything can. And at $p=1$ the whole question touches Sidorenko's famous conjecture, one of the central open problems about pattern counts in dense graphs.

The moral is an old one, freshly illustrated: a formula can be beautiful, symmetric, and completely wrong. The way to tell is to count the pieces.
