# The Pyramid with a Square Hat

*How a simple question about stacked squares leads to partitions, a missing pair of numbers, and a growth law that sits exactly halfway between polynomial and exponential.*

---

## A shape you can build with coins

Put some coins in a row of columns on a table. Each column has at least one coin, and the coins in a column rest on the table — no floating. Now impose one rule: as you walk from left to right, the columns may only get taller, and then, at some point, only shorter. Up, then down. No second peak.

Shapes like this are called **stack polyominoes**, and they are one of the friendliest families in all of combinatorics. They are the discrete version of a mountain: a single summit, two slopes. If the column heights are $h_1, h_2, \dots, h_r$, then all $h_i \ge 1$, and the sequence is **unimodal** — weakly increasing, then weakly decreasing. The **area** is the total number of coins, $n = h_1 + \dots + h_r$.

The summit is rarely a single column. Usually several adjacent columns tie for the maximum height $k$; that flat block on top is the **core** of the stack. Here is the question this article is about:

> **What if the core is a perfect square?**

That is, what if the number of columns in the top plateau is exactly equal to their common height $k$, so that the crown of the mountain is a $k \times k$ block?

Call $a(n)$ the number of such **square-core stacks** of area $n$. Counting them turns out to be a small adventure. The first few values are

$$1,\, 1,\, 0,\, 0,\, 1,\, 2,\, 3,\, 4,\, 5,\, 7,\, 9,\, 13,\, 17,\, 24,\, 31,\, 42,\, 54,\, 71,\, 90,\, 117,\, 147,\, 188,\, 236,\, 298,\, 371,\, 466,\, 576,\, 716,\, 882,\, 1088,\, 1331,\, 1633.$$

Two things jump out immediately. There is a **hole**: $a(2) = a(3) = 0$. And after the hole, the numbers climb — but at a strange, hesitant pace. They are not growing like $n^2$; they are not doubling either. They are doing something in between. Understanding exactly what that "in between" is will be the punchline.

## Why 2 and 3 are impossible

Start with the hole, because it is the easiest thing in the story and already reveals the mechanism.

Suppose a stack has area $2$. Its maximum height $k$ is either $1$ or $2$. If $k = 1$, the shape is a flat row of columns of height one, and the core is the entire row — all $2$ columns. For a square core we would need exactly $k = 1$ column of height $1$, but there are two. If $k=2$, the shape is one column of height $2$; the core is one column at height $2$, and a square core would need $2$ of them. Neither works. So $a(2) = 0$.

Area $3$ is the same story with one more case, and again nothing fits: a flat row of three, an L-shape of maximum height $2$ with a single tall column, or one column of height $3$ — each has a core one column too narrow or too wide.

From area $4$ onward, however, there is always something: the $2 \times 2$ square itself works at $n=4$, and for larger $n$ you can hang a tail of height-one columns off the side of a $2\times 2$ block. Counting those tails gives $a(n) \ge n - 3$ — a linear supply of shapes that never runs out. So the sequence is zero at exactly two places, $n = 2$ and $n = 3$, and strictly positive everywhere else. Small as it is, this is a genuine theorem, and it is the first sign that the square-core condition is a real constraint rather than a decoration.

## Slice the mountain into three pieces

Here is the idea that unlocks everything. Take a square-core stack whose core has height $k$. Cut it into three parts:

$$\text{(left slope)} \;\;\Vert\;\; \underbrace{k \times k \text{ square}}_{\text{the core}} \;\;\Vert\;\; \text{(right slope)}.$$

The core swallows exactly $k^2$ coins. What is left over, $n - k^2$ coins, is split between the two slopes. And now the crucial observation: **the left slope, read from the core outward, is a weakly decreasing list of positive integers, each strictly less than $k$.** That is precisely a *partition* of its area into parts of size at most $k-1$. Same for the right slope.

Why strictly less than $k$? Because if a slope column had height $k$, it would join the plateau and the core would be wider than $k$ columns — no longer a square. The square-core condition is exactly a *ceiling* on the slopes.

Write $p_{\le b}(m)$ for the number of partitions of $m$ into parts of size at most $b$ — one of the oldest and best-behaved objects in number theory. The slicing then gives a complete formula:

$$a(n) \;=\; \sum_{k^2 \le n} \;\; \sum_{i+j \,=\, n-k^2} p_{\le k-1}(i)\, p_{\le k-1}(j).$$

Each value of $k$ contributes a **core layer**: all the stacks whose crown is the $k\times k$ square. Layer $k$ switches on at area $n = k^2$ and thereafter grows by absorbing more and more slope.

This is more than a formula; it is a *dictionary*. It translates a geometric question about shapes into an arithmetic question about partitions, and every subsequent result is obtained by pushing that dictionary hard.

For instance, generating functions. Euler taught us that partitions with parts at most $b$ are packaged by
$$\sum_{m \ge 0} p_{\le b}(m)\, x^m \;=\; \frac{1}{(1-x)(1-x^2)\cdots(1-x^b)} .$$
Two slopes means squaring that, and the core contributes $x^{k^2}$. Summing over $k$:

$$\boxed{\;\sum_{n\ge 0} a(n)\, x^n \;=\; \sum_{k \ge 0}\; \frac{x^{k^2}}{\bigl[(1-x)(1-x^2)\cdots(1-x^{k-1})\bigr]^{2}}\;}$$

Anyone who has met partitions will feel a jolt of recognition here. The classical **Durfee square** identity says
$$\sum_{n\ge0} p(n)x^n = \sum_{k\ge0}\frac{x^{k^2}}{\bigl[(1-x)(1-x^2)\cdots(1-x^{k})\bigr]^{2}},$$
where $p(n)$ is the ordinary partition function. The two series are *the same*, except that ours truncates each Euler product one factor earlier. Square-core stacks are a shadow of the Durfee-square decomposition of partitions — which strongly suggests, and computation confirms at least into the thousands, that $a(n) \le p(n)$ for every $n$.

## The third layer, in closed form

The first three layers are anticlimactic. Layer $k=0$ is the empty stack; layer $k=1$ is the single coin; layer $k=2$ has slopes made of $1$'s only, so it just counts how to split $n-4$ coins into a left tail and a right tail: exactly $n-3$ ways. Linear.

Layer $k = 3$ is where arithmetic finally appears. Its slopes are partitions into parts $1$ and $2$, of which there are $\lfloor m/2 \rfloor + 1$ for area $m$. Convolving that sequence with itself gives the layer's count, and one can integrate a two-step recurrence to obtain an exact **quasi-polynomial**: writing $c_2(m)$ for the layer's contribution when the leftover area is $m$,

$$c_2(m) \;=\; \frac{(m+2)(m+3)(m+4)}{24} \ \ (m \text{ even}), \qquad c_2(m) \;=\; \frac{(m+1)(m+3)(m+5)}{24} \ \ (m \text{ odd}).$$

A cubic in $m$, with a period-two twitch: the parity of $m$ decides which of two cubics applies. That twitch is not cosmetic, as we are about to see.

## Convex, but only just

Look again at the numbers $1, 2, 3, 4, 5, 7, 9, 13, 17, 24, \dots$ from $n=4$ on. They increase, and the *gaps* between consecutive terms — $1,1,1,1,2,2,4,4,7,\dots$ — also increase. Both facts are true in general.

**Monotonicity.** For $n \ge 4$, $a(n) < a(n+1)$: strictly. The reason is charmingly concrete. No layer can shrink when you add a coin (more area means more room for slope), and the $k=2$ layer gains exactly one shape at every step. One layer pushes; nobody pulls.

**Convexity.** For $n \ge 2$,
$$2\,a(n+1) \;\le\; a(n) + a(n+2),$$
so the gaps never decrease. The proof is a small piece of magic. Each layer is a *self-convolution* $f * f$ of a non-decreasing sequence $f$ (the bounded partition counts). In generating-function language, $(1-x)^2 (f*f)(x) = \bigl[(1-x)f(x)\bigr]^2$: the second difference of a self-convolution is the self-convolution of the first difference. Since $f$ increases, its first difference is non-negative, and a convolution of non-negative sequences is non-negative. Convexity falls out of an algebraic identity rather than any estimate. Combined with the fact that $a$ eventually outgrows every polynomial, convexity forces the gaps $a(n+1)-a(n)$ to diverge to infinity.

So the sequence is well behaved. How well behaved? Combinatorialists have a wish list of increasingly strong regularity properties, and the natural next two both **fail**.

*Log-concavity* — the property $a(n)^2 \ge a(n-1)a(n+1)$ enjoyed by binomial coefficients and by the partition function for large $n$ — fails here at the very first opportunity:
$$a(8)^2 = 5^2 = 25 \;<\; 28 = 4 \cdot 7 = a(7)\,a(9).$$

*Higher-order convexity* fails too, and this is where the parity twitch of the third layer bites. One can ask whether the third difference $\Delta^3$ is always non-negative, as it would be for a sequence with total positivity. It is not. The exact closed form above yields exact third differences for the third layer:
$$\Delta^3 c_2(2t) = -(t+2), \qquad \Delta^3 c_2(2t+1) = +(t+3).$$
They alternate in sign with period two and with amplitude growing *linearly*. This is an infinite family of violations, not a small-number accident, and it propagates to the sequence itself:
$$a(10) + 3a(8) = 9 + 15 = 24 \;<\; 25 = 21 + 4 = 3a(9) + a(7).$$
Convexity, then, is the exact ceiling of regularity for square-core stacks: true, but not improvable in either the multiplicative or the higher-order direction.

## The real question: how fast?

Now the growth law. Two crude bounds bracket the answer.

**From below.** A partition into parts of size at most $b+1$ can be built by deciding, for each of $b$ chosen part sizes, whether to use it or not — provided there is room. Making that precise gives $2^{\,b} \le p_{\le b+1}(m)$ as soon as $b(b+3) \le 2m$. Feeding it into a single well-chosen core layer yields
$$2^{\,m} \;\le\; a(n) \qquad \text{whenever } 3m^2 + 11m + 8 \le 2n .$$
Since $m$ can be taken of size roughly $\sqrt{2n/3}$, this already says $a(n)$ grows at least like $e^{c\sqrt n}$ — faster than any polynomial.

**From above.** Each bounded partition count is at most $(m+1)^b$, and there are only about $\sqrt n$ layers, giving $a(n) \le (n+1)^{2\sqrt n + 2}$, i.e. $\log a(n) \le C\sqrt n \log n$.

Between them sits an annoying factor of $\log n$. Removing it takes real work — the classical Hardy–Ramanujan trick, done by hand. For any $0 < x < 1$, a Chebyshev/Rankin-style argument gives the completely elementary inequality
$$p_{\le b}(m)\, x^m \;\le\; \prod_{i=1}^{b} \frac{1}{1-x^i},$$
because the left-hand side is a single term of a series with non-negative coefficients. Taking logarithms and choosing $x = 1 - 1/N$ with $N \approx \sqrt m$ turns the estimate into
$$\log p_{\le b}(m) \;\le\; 8\sqrt m + 12,$$
**uniformly in $b$** — the ceiling on part sizes never helps and never hurts more than a constant. Summing over the $O(\sqrt n)$ layers and their convolutions removes the logarithm entirely:
$$\log a(n) \;\le\; 16\sqrt n + 2\log(n+1) + 24 .$$

Combining with the lower bound, for every $n \ge 100$:
$$\frac{\sqrt n - 2}{2}\,\log 2 \;\le\; \log a(n) \;\le\; 30\sqrt n .$$

In other words,
$$\log a(n) \;\asymp\; \sqrt{n} .$$

The order of growth is pinned down exactly. Square-core stacks live in the **stretched-exponential** regime: $a(n) \approx e^{c\sqrt n}$, faster than any polynomial $n^d$ (which it eventually dominates for every fixed $d$), yet slower than any exponential $\lambda^n$.

## What a physicist sees

Turn the picture sideways and a stack polyomino becomes a **discrete interface**: a one-dimensional surface separating "solid" from "empty", with the constraint that the profile has a single hump. Such objects are the bread and butter of solid-on-solid models, of crystal-facet growth, and of directed-walk models of polymers. The area $n$ plays the role of the number of particles; $\log a(n)$ is the microcanonical **entropy** of the configuration space at that particle number; and the ratio
$$s(n) \;=\; \frac{\log a(n)}{n}$$
is the entropy *density*.

The bound above says immediately that
$$\lim_{n\to\infty} \frac{\log a(n)}{n} = 0 .$$

The entropy density vanishes. That is a genuinely physical statement, and it separates our shapes sharply from the general population of polyominoes. The number of arbitrary polyominoes of area $n$ grows like $\lambda^n$ with $\lambda \approx 4.06$ — a strictly positive entropy density, a system with extensive disorder. Impose unimodality plus a square crown and the disorder collapses: the number of configurations is subexponential, all the freedom is squeezed into the $O(\sqrt n)$ "degrees of freedom" of the two slopes, and the free energy per particle is zero. In statistical-mechanics language, the model has no extensive entropy; it is *rigid*.

The $\sqrt n$ exponent has its own physical reading. It is the same exponent that governs the partition function $p(n) \sim \frac{1}{4n\sqrt3}\exp\bigl(\pi\sqrt{2n/3}\bigr)$, i.e. the same exponent as a one-dimensional Bose gas, where the number of states at energy $n$ grows as $\exp(c\sqrt n)$. Stacks with a square core are, from a distance, a Bose gas with an unusual selection rule.

## The constant that is (almost certainly) $\pi\sqrt{2/3}$

The proved bounds sandwich $\log a(n)/\sqrt n$ between about $0.34$ and $30$ — a factor of roughly 87. The truth is far more precise. Numerically, $\log a(n)/\sqrt n$ climbs through $1.77$ at $n=100$, $2.14$ at $n=500$, $2.24$ at $n=1000$, $2.29$ at $n=1500$ — creeping, with the notorious slowness of Hardy–Ramanujan asymptotics, toward
$$\pi\sqrt{2/3} \;=\; 2.56509966\ldots,$$
*exactly* the constant of the unrestricted partition function.

There is a beautiful reason to expect this. Analyse the generating function $\sum_k x^{k^2}\prod_{i<k}(1-x^i)^{-2}$ near $x = e^{-t}$ with $t \to 0^+$ by a saddle point. The core costs $-k^2 t$, and the two truncated Euler products gain $2\int_0^{kt} -\log(1-e^{-s})\,\frac{ds}{t}$. Optimising over $k$ places the saddle exactly at $kt = \log 2$ — and there the loss from the square core is precisely cancelled by the gain from lengthening the products, leaving the effective free energy $\pi^2/6$: the very same value as the single, untruncated Euler product that governs $p(n)$. The square core is asymptotically free. Making that heuristic into a theorem — sharpening the crude constants $8$ and $30$ down to $\pi\sqrt{2/3}$ — is the obvious next target, and the elementary machinery above (a uniform-in-$b$ Rankin bound plus a two-regime estimate of $\sum_i -\log(1-x^i)$) already reaches most of the way there.

## Why any of this is satisfying

Start with coins on a table and one aesthetic whim: *let the crown be a perfect square*. What comes back is a small tour of mathematics.

The whim turns into a ceiling on part sizes, which turns into bounded partitions, which turns into an Euler product with the last factor removed — a near-miss of the Durfee square identity. The resulting sequence has a two-element hole at the start, is strictly increasing and convex thereafter, and is *exactly* convex: log-concavity and third-order convexity both fail, the latter by an infinite family of counterexamples that the exact cubic quasi-polynomial of the third layer makes completely explicit. And the global growth law, $\log a(n) \asymp \sqrt n$, places the whole family in the stretched-exponential world, with vanishing entropy density and a conjectured Hardy–Ramanujan constant it appears to share with the partition function itself.

A single geometric constraint — five words, "the core must be square" — reaches from an elementary parity argument about $n=2$ all the way to the free energy of a one-dimensional interface. That is a good day's work for a pile of coins.
