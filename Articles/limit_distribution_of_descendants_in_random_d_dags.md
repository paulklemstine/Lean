# When a Family Tree Becomes a Bell of Chance: Counting Descendants in Random Networks

## A tree that isn't quite a tree

Imagine building a network one node at a time. You start with a single root. Each new arrival doesn't just attach to one existing member of the club — it reaches back and picks **two** of them (or three, or any fixed number $d \ge 2$) uniformly at random, and links to all of them. Keep going, and after $n$ steps you have a sprawling web of dependencies: a *random recursive directed acyclic graph*, or random $d$-DAG.

These objects are not exotic curiosities. They are the mathematical skeleton of a surprising number of real systems. A software project where each new module imports several existing ones. A scientific literature where each paper cites a handful of predecessors. A blockchain where each block confirms multiple earlier blocks. A dependency graph in a build system, a lineage of file versions, the propagation of an idea through a citation web. In all of these, the arrow of time forbids cycles — you can only point *backward* — and each newcomer connects to several ancestors, not just one.

A natural and stubborn question hangs over all of these networks: **how many descendants does the root accumulate?** If you plant an idea at the very beginning, how much of the eventual network traces its lineage back to you? Call that set of descendants $D_n$, and its size $|D_n|$.

## The surprise of the scaling

Here is where intuition stumbles. In an ordinary random *tree* — where each node attaches to exactly one parent, the case $d = 1$ — the root's descendant count grows *linearly*: a fixed positive fraction of the whole tree, on average, descends from the root. The root dominates.

But raise the out-degree to $d = 2$ and something dramatic happens. Because each node now reaches back to *two* ancestors, "being a descendant of the root" becomes a much more demanding condition — a node counts only if *all* the required backward paths eventually route through the root. The competition among ancestors intensifies, and the root's share collapses. Instead of growing like $n$, the descendant count grows only like $\sqrt{n}$. For general out-degree $d$, the growth is like $n^{1/d}$: the cube root when $d = 3$, the fourth root when $d = 4$, and so on. The larger the out-degree, the more slowly any single ancestor's dynasty expands.

But the size is only half the story. The *shape* of the randomness — the full probabilistic silhouette of $|D_n|$ once you zoom to the right scale — is the real prize. And it turns out to be one of the most beautiful and well-studied distributions in all of mathematics.

**The Descendant Limit Law.** *For the random recursive DAG with out-degree $d \ge 2$, the rescaled descendant count converges in distribution:*
$$\frac{|D_n|}{n^{1/d}} \xrightarrow{\ d\ } \mathrm{Gamma}(d, 1) \qquad (n \to \infty).$$

The right-hand side is the **Gamma distribution** with shape $d$ and rate $1$: the continuous law on the positive half-line with probability density
$$f_d(x) = \frac{x^{d-1} e^{-x}}{\Gamma(d)}, \qquad x > 0,$$
where $\Gamma$ is Euler's Gamma function, the smooth interpolation of the factorial ($\Gamma(d) = (d-1)!$ for a positive integer $d$). A wild, discrete, combinatorial counting problem — how many nodes in a random web descend from the root — dissolves, in the limit, into a single clean bell-shaped curve of continuous chance.

## A hidden discreteness inside the continuous curve

The Gamma distribution is continuous. It lives on the real line; it has a smooth density; it is the stuff of integrals, not sums. And yet — precisely because our shape parameter $d$ is a whole number — it conceals a perfectly discrete heart.

When the shape parameter is a positive integer, the Gamma law has a special name: the **Erlang distribution**, named after the Danish telephone engineer A. K. Erlang, who used it a century ago to model the arrival of phone calls. And the Erlang distribution has a remarkable property that a general Gamma distribution does not: its cumulative distribution function — the probability that the value lands at or below a threshold $t$ — can be written as a **finite sum**, with no leftover integral.

This is the centerpiece of the present work, an identity we call the **Gamma–Poisson duality**.

**Gamma–Poisson Duality.** *For every nonnegative integer $m$ and every real $t \ge 0$,*
$$\mathbb{P}\big(\mathrm{Gamma}(m+1, 1) \le t\big) = 1 - \sum_{k=0}^{m} \frac{e^{-t}\, t^{k}}{k!}.$$

Stare at the sum on the right. Each term $e^{-t} t^k / k!$ is not just any expression — it is exactly the probability that a **Poisson random variable** with mean $t$ takes the value $k$. The Poisson distribution is the canonical law of counting: the number of raindrops hitting a tile in a second, the number of calls arriving at a switchboard, the number of mutations along a strand of DNA. So the identity says something startling:
$$\mathbb{P}\big(\mathrm{Gamma}(m+1,1) \le t\big) = \mathbb{P}\big(\mathrm{Poisson}(t) \ge m+1\big).$$

The chance that a *continuous* Erlang variable falls below $t$ equals the chance that a *discrete* Poisson counter, tuned to average $t$, reaches at least $m+1$. A continuous scaling limit of a combinatorial process is governed, exactly, by a discrete counting law. The two worlds — the smooth and the granular — are the same fact viewed from two sides.

There is even a vivid probabilistic reason this must be true. Picture events arriving along a timeline at a steady unit rate — a *Poisson process*. The waiting time until the $(m+1)$-st event is precisely an $\mathrm{Erlang}(m+1)$ random variable. Saying "the $(m+1)$-st event has arrived by time $t$" is the very same statement as "at least $m+1$ events occurred in $[0,t]$," and the number of events by time $t$ is Poisson with mean $t$. The two probabilities are equal because they describe *the same event* in two languages: one measuring time, the other counting arrivals.

## How the identity proves itself: a telescoping trick

One of the pleasures of this result is that it needs no heavy machinery — no incomplete Gamma functions, no integration by parts, no special-function wizardry. It falls out of a single elegant observation about derivatives.

Write $p_k(t) = e^{-t} t^k / k!$ for the $k$-th Poisson term. A one-line calculation with the product rule shows that differentiating $p_{k+1}$ produces exactly the *difference of two consecutive terms*:
$$\frac{d}{dt}\, p_{k+1}(t) = p_k(t) - p_{k+1}(t).$$

Now define the **survival sum** $S_{m+1}(t) = \sum_{k=0}^{m} p_k(t)$. When we differentiate it term by term, the difference structure makes almost everything cancel — a *telescope*. The $p_k$ produced by differentiating $p_{k+1}$ annihilates the $-p_k$ from the previous term, and the whole cascade collapses to a single survivor:
$$S_{m+1}'(t) = -p_m(t) = -\frac{e^{-t} t^m}{m!}.$$

The derivative of the survival sum is *minus the Erlang density*. From there the Fundamental Theorem of Calculus does the rest. Since $S_{m+1}(0) = 1$ (only the $k=0$ term survives at $t = 0$), integrating the density from $0$ to $t$ gives
$$\int_0^t \frac{e^{-x} x^m}{m!}\, dx = 1 - S_{m+1}(t),$$
which is precisely the Gamma–Poisson duality. The same telescoping identity, at no extra cost, delivers three companion facts: the survival sum $S_{m+1}(t)$ decays to $0$ as $t \to \infty$ (because each term $t^k e^{-t}$ does); the Erlang density therefore integrates to exactly $1$, confirming it is a genuine probability law; and the cumulative distribution function is monotonically increasing, as any respectable distribution function must be. All from one derivative.

## Why equal spreading is a Poisson fingerprint

The duality does more than give a tidy formula — it explains a coincidence that would otherwise look like magic. For the limiting $\mathrm{Gamma}(d, 1)$ law, the **mean equals the variance**, both equal to $d$. A distribution whose average and whose spread coincide is said to be *equidispersed*, and equidispersion is the unmistakable signature of the Poisson distribution. The Erlang's hidden Poisson layer, exposed by the duality, is exactly where this fingerprint comes from. The descendant count, in the limit, behaves like a randomized Poisson mixture — and it carries the Poisson's most characteristic tic, the perfect balance of center and spread, straight through the scaling limit.

The moments of the limit law are equally clean. The $k$-th moment is a *rising factorial*,
$$\mathbb{E}\big[\mathrm{Gamma}(d,1)^k\big] = d(d+1)(d+2)\cdots(d+k-1) = \prod_{i=0}^{k-1}(d + i),$$
a sequence that grows slowly enough (far slower than $(2k)!$) that no other distribution on the line can share it. In technical terms it satisfies Carleman's condition, which means the moments *uniquely determine* the law. This is what makes the method of moments — matching the descendant count's averages to the Gamma law's averages, one power at a time — a fully valid proof strategy and not merely a suggestive one.

## The bridge, and why it matters

Step back and take in the arc. We began with a purely combinatorial gadget — a growing web of backward-pointing links — and asked a counting question about it. The answer, in the limit, is a smooth continuous curve, the Gamma distribution. And inside that smooth curve, because the out-degree is a whole number, lives a finite discrete sum of Poisson probabilities. Three levels of mathematics — the combinatorial, the continuous, and the discrete-counting — turn out to be three faces of one object.

This kind of bridge is more than aesthetic. It is *useful*. The finite Poisson-tail formula means that questions about the descendant count in a large random DAG — "what fraction of dependency graphs of size $n$ leave the root with fewer than $c\sqrt{n}$ descendants?" — can be answered instantly with a short, exact sum of $d$ terms, with no numerical integration and no special-function evaluation. It means confidence intervals and thresholds for these networks are as easy to compute as looking up a Poisson probability. And it means that the enormous, well-developed theory of the Poisson and Erlang distributions — a century of results from queueing theory, telecommunications, and reliability engineering — can be imported wholesale to reason about the lineage structure of modern random networks.

A family tree that grows by reaching backward turns, in the fullness of scale, into a bell of chance; and that bell, listened to closely, rings with the discrete chime of counting. That is the quiet unity this work makes precise.
