# The Price of a Hint

## What a good guess is actually worth when you can only check the answer at the end

Imagine you are standing at the root of an enormous decision tree. At every step you must choose one of three doors. Behind exactly one of them lies the path to the treasure; the other two lead into vast subterranean networks of their own, all of them dead ends. The tree is $h$ levels deep, so there are $3^h$ leaves and exactly one of them is right.

Now imagine you are given an oracle — a whispered hint at each door, a heuristic, a trained model, a hunch — that names the correct door with probability $\alpha$. The question that this article is about is deceptively simple:

**How much is that hint worth?**

The intuitive answer, the one almost everyone gives, is: *a good hint shrinks the tree*. If the oracle is right most of the time, then effectively you are not branching three ways any more — you are branching, say, 1.4 ways, and the search that used to cost $3^h$ now costs $1.4^h$. The hint buys you a smaller **base**. Call this the *effective branching hypothesis*. It is the folk theory behind an enormous amount of practical search engineering.

It is false. Not approximately false, not false in some corner case — false for every accuracy $\alpha$ strictly below $1$, exactly, with the base pinned at $3$ forever. And understanding *why* it is false, and what is true instead, turns out to reveal a sharp phase transition in the economics of guessing, sitting at precisely the accuracy $\alpha = 1/3$.

---

## The one rule that changes everything

Everything hinges on a single modelling choice, and it is the choice that matches most real search problems: **verification happens only at the end**.

You cannot tell, standing at level 5, whether the path that got you there is correct. There is no partial credit, no gradient, no smell of treasure getting stronger. You find out you were wrong only when you reach a leaf and it isn't the goal. This is the regime of factoring a number, of finding a proof, of guessing a cryptographic key, of any problem where a candidate is cheap to check and impossible to partially check. Call it **end-verification-only semantics**.

Under this rule, a wrong turn is not a small mistake. A wrong turn at level $j$ means you will exhaustively explore the *entire* wrong subtree hanging below it before you learn anything. And that subtree has $\Theta(3^{h-j})$ leaves.

That is the whole story in one sentence: *the oracle controls how often you make a mistake, but it has no control at all over what a mistake costs.*

---

## Two ways to climb

Given the setup, there are two natural strategies, and both can be priced exactly.

**Strategy 1: depth-first search with backtracking.** Descend, following the oracle. When you hit a dead leaf, back up to the last unexplored sibling and try again. This is what any sane implementation does.

To price it, note that at level $j$ you pay one visit to enter, and then — weighted by how often the oracle misleads you — you pay for the wrong subtrees you exhaust. If the oracle picks the right door with probability $\alpha$, then the expected number of wrong siblings you fully expand before finding the right one is captured by the **failure weight**
$$K = (1-\alpha)(2-\alpha),$$
which runs smoothly from $K = 2$ for a blind agent ($\alpha = 0$) down to $K = 0$ for a perfect one ($\alpha = 1$). A complete wrong ternary subtree at level $j$ contains $(3^j - 1)/2$ nodes, so level $j$ costs
$$1 + \frac{K(3^j - 1)}{2}.$$
Summing over all levels gives the closed form:

> **The DFS Ascent Law.** The expected cost of a depth-first backtracking ascent of height $h$ guided by an accuracy-$\alpha$ ternary branch oracle is exactly
> $$E_{\mathrm{DFS}}(h) \;=\; h\left(1 - \tfrac{K}{2}\right) \;+\; \frac{K\left(3^{h+1} - 3\right)}{4}, \qquad K = (1-\alpha)(2-\alpha).$$

The law is calibrated at both ends. At $\alpha = 0$ it collapses to $(3^{h+1}-3)/2$, exactly the number of internal nodes of the whole tree: a blind agent sweeps everything, as it must. At $\alpha = 1$ it collapses to $h$: a perfect agent walks straight down. In between, it interpolates — and here is the punchline. Look at where $\alpha$ appears. It appears **only in $K$**, and $K$ is a multiplicative prefactor on $3^{h+1}$. The base is $3$. It was always $3$. It will always be $3$.

> **Effective branching is refuted.** For every accuracy $\alpha < 1$, the growth ratio of the DFS ascent law satisfies
> $$\lim_{h\to\infty}\frac{E_{\mathrm{DFS}}(h+1)}{E_{\mathrm{DFS}}(h)} = 3,$$
> and more precisely $E_{\mathrm{DFS}}(h)/3^h \to 3K/4$. Accuracy rescales the cost; it does not bend the exponent.

An oracle that is right 99% of the time gives $K = 0.0101$ — a hundredfold saving, magnificent, and *completely irrelevant to the asymptotics*. It buys you about four extra levels of depth. Then the exponential eats it, as exponentials do.

**Strategy 2: restart from the root.** Don't backtrack at all. Follow the oracle all the way down; if the leaf is wrong, throw everything away and start over from the top with fresh randomness.

This sounds wasteful and is often brilliant. A full descent is correct with probability $\alpha^h$ — all $h$ guesses must land — and each attempt costs exactly $h$ visits. The number of attempts until the first success is geometric with mean $\alpha^{-h}$, so:

> **The Restart Ascent Law.** The expected cost of restart-from-root is exactly
> $$E_{\mathrm{restart}}(h) \;=\; h\,\alpha^{-h}.$$

Now compare the two. DFS grows like $3^h$. Restart grows like $(1/\alpha)^h$. And *that* is where accuracy finally gets to touch the base.

---

## The 1/3 boundary

The comparison is not subtle once you see it. Restart wins whenever $1/\alpha < 3$, that is, whenever $\alpha > 1/3$; DFS wins whenever $\alpha < 1/3$. And the winning is total:

> **The Dominance Theorem.** If $\alpha > 1/3$ then $E_{\mathrm{restart}}(h)/E_{\mathrm{DFS}}(h) \to 0$; if $\alpha < 1/3$ then $E_{\mathrm{DFS}}(h)/E_{\mathrm{restart}}(h) \to 0$. Each schedule beats the other by an *unbounded* factor on its own side of the boundary.

There is no genteel region of near-parity. Cross $\alpha = 1/3$ and the entire economics of the search inverts.

Why $1/3$? Because $1/3$ is exactly the accuracy of guessing at random on three doors. Below random, the oracle is worse than useless and the only rational thing to do is sweep the tree. Above random, every unit of accuracy above chance compounds multiplicatively down the descent, and it is worth paying the whole $h$-step descent again to harvest that compounding.

Putting the two laws together gives the object that organizes the whole subject:

> **The Ascent Exponent Law.** The optimal of the two schedules has exponential rate
> $$\lim_{h\to\infty} \frac{\log \min\{E_{\mathrm{DFS}}(h),\, E_{\mathrm{restart}}(h)\}}{h} \;=\; \log \min\left(3, \tfrac{1}{\alpha}\right).$$

This is a **kinked** function of accuracy: flat at $3$ for all $\alpha \le 1/3$, then descending along the hyperbola $1/\alpha$. It is continuous but not differentiable at $\alpha = 1/3$. Below the kink, accuracy is worth *nothing* to the exponent — although, and this is a nice piece of fine structure, it is always worth something to the *cost*: both laws are strictly decreasing in $\alpha$ at every fixed height. Accuracy always buys you something. It just doesn't always buy you an exponent.

And at the far end, $\alpha = 1$ exactly, there is a genuine phase transition: $E_{\mathrm{restart}}(h) = h$, polynomial, while for every $\alpha < 1$ the cost per unit depth $E_{\mathrm{restart}}(h)/h$ diverges. Exponential right up to the boundary, then polynomial in one step.

---

## It was never about the number three

The most satisfying part of the story is that the $1/3$ has nothing to do with ternary trees.

Redo the whole computation with branching factor $b \ge 2$ and an arbitrary *level waste weight* $w \in (0, b-1]$ — the weight is the expected number of wrong siblings you expand, and it cannot exceed $b - 1$ because a level cannot waste more than its wrong siblings. The DFS law becomes
$$E_b(h) \;=\; h\left(1 - \frac{w}{b-1}\right) \;+\; \frac{w\left(b^{h+1} - b\right)}{(b-1)^2},$$
which recovers the ternary law exactly at $b = 3$, $w = K$. And everything goes through verbatim:

> **Universality.** For every branching factor $b \ge 2$ and every admissible waste weight $w$: the DFS growth ratio is exactly $b$ (effective branching is refuted at every branching factor); the restart/DFS crossover is exactly at $\alpha = 1/b$; and the optimal exponent is
> $$\min\left(b, \tfrac{1}{\alpha}\right),$$
> with its kink at the reciprocal branching factor.

Concretely, at $b = 5$: a blind agent ($w = 4$) climbing six levels pays $4(5^7-5)/16 = 19{,}530$ visits, exactly the internal-node count of a depth-6 quinary tree, and the growth ratio at that height is already $5.00026$. Drop the waste weight to $w = 0.2$ — a twentyfold better oracle — and the ratio is $4.97801$. Same base, prefactor down by twenty. The crossover moves to $\alpha = 0.2$, right where the reciprocal says it should be.

So the $1/3$ was never a fact about three doors. It is a fact about *randomness being the origin of the accuracy scale*: the phase boundary sits exactly at the accuracy of a coin flip on however many doors there are.

---

## Hints do not all belong to the same species

There is a widely used rule of thumb for pricing hints: a hint that eliminates all but a fraction $\theta$ of your search space buys you a speedup of $1/\theta$, and no more. A one-shot *class hint* on a ternary branching keeps at least a third of the tree, so it is capped at speedup $3$. Full stop, ceiling reached.

Branch hints break that ceiling, and they break it comprehensively. Measured against the uninformed baseline $\alpha = 1/3$, an accuracy-$\alpha$ branch oracle under the restart law gives a speedup of exactly
$$\frac{E_{\mathrm{restart}}(1/3, h)}{E_{\mathrm{restart}}(\alpha, h)} = (3\alpha)^h,$$
which for any $\alpha > 1/3$ **exceeds every constant cap** as $h$ grows. Empirically the same divergence is visible immediately: measured speedups of $1.01$, $1.30$, $1.98$, $3.56$, $10.10$ as $\alpha$ runs from $1/3$ to $0.9$ — already past the cap of $3$ at $\alpha \approx 0.7$, and climbing.

The reason is structural. A class hint fires *once*. A branch hint fires at *every level*, and the successes multiply: a chain of $h_1$ then $h_2$ hinted branchings succeeds with the product $\alpha^{h_1}\cdot\alpha^{h_2}$ of the stage probabilities. This is a genuinely different kind of resource — **sequential, geometric hints**, priced by $h\,\alpha^{-h}$ rather than by any bounded ratio.

---

## Does any of this buy a real win?

Exact laws let you do something rare: compute, in advance, whether a proposed heuristic feature is worth building.

Take a concrete benchmark — an exact scan that solves its instances in a median of about $183{,}000$ steps. Should you replace it with a guided ascent? The laws answer precisely. With per-step overhead $c$ (the cost of consulting your oracle, measured in visit-equivalents) and a budget $F$ set by the exact solver, the guided ascent wins **if and only if**
$$\alpha \;>\; \alpha^{*} \;=\; \left(\frac{(1+c)\,h}{F}\right)^{1/h},$$
an exact threshold, not merely a sufficient condition — and $\alpha^*$ strictly increases with $c$, so a costlier feature strictly raises the accuracy bar.

Running this on the benchmark: the majority stratum survives all the way to $c \le 3000$ visit-equivalents per step, with the required accuracy climbing from $\alpha^* \approx 0.85$ to $0.96$ across that range. That is a real, if demanding, target. But the balanced stratum *never* wins — the exact solver is already effectively instantaneous there, so there is nothing to buy. And the hardest tail is unwinnable even at $\alpha = 0.9999$: when $F$ is astronomically large, $\alpha^*$ is astronomically close to $1$.

The most sobering number is the margin. Probing whether a per-step feature costing $\sqrt{N}$ could ever pay for itself, the answer is *no* — but excluded by only about $1.7$ orders of magnitude. That is thin. Cheapen the feature by a factor of fifty and the calculus flips.

Meanwhile, on the supply side, the best-measured candidate channel carries roughly $19\%$ of the relevant entropy, with a raw accuracy hovering near the majority baseline — far below the $\alpha^* \ge 0.85$ that breakeven demands. The channel is real; it simply isn't loud enough. The gap is now quantified from both ends: this is what the oracle delivers, that is what it would need to deliver.

---

## The moral

Guessing well is valuable, and the value is quantifiable to the last decimal. But it is not the kind of value the folk theory advertises.

Inside a backtracking search under end-verification, accuracy is a *discount*, never a *rate*. It buys you a smaller constant in front of an exponential that does not care about you. The only way accuracy touches the exponent is by changing the strategy entirely — by abandoning backtracking for restarts, and thereby swapping the base $b$ for the base $1/\alpha$. That swap is worth making exactly when $\alpha > 1/b$, and the exponent of the best possible ascent is the kinked curve $\min(b, 1/\alpha)$.

Below the kink, a better hint makes you faster. Above the kink, a better hint makes you *asymptotically* faster. The difference between those two sentences is the difference between engineering and a phase transition — and it sits at exactly the accuracy of a random guess.
