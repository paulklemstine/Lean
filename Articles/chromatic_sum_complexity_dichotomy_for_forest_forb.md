# The Cheapest Way to Color a Graph

Imagine you run a small radio network. Each transmitter needs a frequency, and two transmitters that are close enough to interfere must be assigned different frequencies. Frequencies are not free: lower channels are cheap and abundant, higher channels are scarce and expensive. You want everyone on the air, no two neighbors clashing, and the *total bill* as small as possible.

This everyday puzzle is the heart of one of the most elegant and quietly surprising invariants in graph theory: the **chromatic sum**. It looks almost identical to the famous graph-coloring problem your calculus professor may have mentioned — the one behind the Four Color Theorem — but it hides a twist that turns intuition on its head.

## From counting colors to counting cost

Let us set the stage precisely. A *graph* $G$ is a collection of vertices (the transmitters) together with edges joining pairs that must differ (the interfering pairs). A **proper coloring** assigns to each vertex $v$ a positive whole number $c(v) \in \{1, 2, 3, \dots\}$ — its color, or frequency, or channel — subject to a single rule: if $u$ and $v$ are joined by an edge, then $c(u) \neq c(v)$.

The classical *chromatic number* $\chi(G)$ asks: what is the smallest number of *distinct* colors needed for a proper coloring? It counts the size of your palette.

The **chromatic sum** $\Sigma(G)$ asks a different question entirely:

$$\Sigma(G) = \min_{c \text{ proper}} \sum_{v} c(v).$$

Instead of counting *how many* colors you use, it adds up *the colors themselves*. Colors are now literal costs. Using color $5$ costs five units; using color $1$ costs one. The chromatic sum is the smallest possible total.

At first glance these two invariants seem like cousins that should always agree. Both reward "using small colors." Both are minimized by clever colorings. But they diverge in ways that are genuinely startling — and understanding that divergence is what this article is about.

## A guarantee, a floor, and a ceiling

Before the surprises, a few reassurances. First, a proper coloring always exists: just give every vertex its own distinct color, $1, 2, 3, \dots$, and no two neighbors can possibly clash. So the set of achievable total costs is never empty, and the minimum defining $\Sigma(G)$ is genuinely attained by some honest coloring — it is not a phantom limit but a concrete best assignment.

Second, there is an unbeatable floor. Every vertex costs at least $1$, so if the graph has $n$ vertices,

$$\Sigma(G) \geq n.$$

You can never pay less than one unit per transmitter. When can you hit that floor exactly? Precisely when there are *no edges at all*: with nothing to separate, color everything $1$ and pay exactly $n$. In symbols, for the edgeless graph, $\Sigma(G) = n$. Constraints are what make coloring expensive; remove them all and the bill is as small as arithmetic allows.

Third, cost respects structure monotonically. If you take a graph $G$ and *add* edges to get a denser graph, the chromatic sum can only go up, never down — more constraints, more cost. Formally, if $H$ is a subgraph of $G$ (same vertices, fewer or equal edges), then $\Sigma(H) \leq \Sigma(G)$. Every proper coloring of the bigger graph is automatically a proper coloring of the smaller one, so the smaller graph has at least as many cheap options.

## The complete graph: a perfect triangle

Now push to the opposite extreme from the edgeless graph. In the **complete graph** $K_n$, *every* pair of vertices is joined by an edge. Nobody may share a color with anybody. So a proper coloring must use $n$ genuinely distinct positive integers.

What is the cheapest way to pick $n$ distinct positive integers? Use the smallest ones available: $1, 2, 3, \dots, n$. Their total is the famous **triangular number**

$$\Sigma(K_n) = 1 + 2 + \cdots + n = \frac{n(n+1)}{2}.$$

This is not merely an upper bound from a lucky guess — it is exactly optimal, and the reason is a clean little inequality: *any* set of $n$ distinct positive integers sums to at least $1 + 2 + \cdots + n$, because the smallest conceivable choice for the values is precisely $\{1, 2, \dots, n\}$. No arrangement of distinct positive channels can undercut the triangular number.

There is a charming reformulation. The complete graph $K_n$ has $n$ vertices and $\binom{n}{2}$ edges. A short calculation shows

$$\Sigma(K_n) = \underbrace{n}_{\text{vertices}} + \underbrace{\binom{n}{2}}_{\text{edges}} = |V| + |E|.$$

Suddenly a tempting pattern appears: *maybe the chromatic sum is always the number of vertices plus the number of edges?* It works for the edgeless graph ($|V| + 0 = n$). It works for a single edge ($2 + 1 = 3$, and indeed you color the two endpoints $1$ and $2$). It works for *every* complete graph. The formula is seductive, symmetric, and easy to remember.

It is also **false**.

## The path that breaks the pattern

Consider the humblest counterexample imaginable: the **path on three vertices**, $P_3$. Three transmitters in a row, $a - b - c$, where the middle one $b$ interferes with both ends but the two ends do not interfere with each other.

The naive formula predicts $\Sigma(P_3) = |V| + |E| = 3 + 2 = 5$. And indeed, if you insist on coloring the *center* with the cheapest color $1$, then both endpoints must avoid $1$, so each costs at least $2$, and the total is $1 + 2 + 2 = 5$.

But watch what happens if you spend your cheap color more wisely. Color the two *endpoints* $1$ and the *center* $2$:

$$c(a) = 1, \quad c(b) = 2, \quad c(c) = 1.$$

The center differs from both endpoints — proper coloring, no clashes. Total cost: $1 + 2 + 1 = 4$. And one can check that no proper coloring does better, so

$$\Sigma(P_3) = 4 \neq 5.$$

The pattern shatters at the smallest tree with a branch. The lesson is deep: in the chromatic sum, *where* you spend your cheap color matters enormously. The high-degree vertex — the one with many neighbors — should often be sacrificed to an expensive color, precisely so that its many neighbors can all share the cheap one. This is the opposite of what greedy intuition suggests, and it is exactly why $\Sigma$ is subtler than $\chi$.

## When "fewest colors" is not "cheapest"

The $P_3$ example exposes a second illusion. The path $P_3$ needs only *two* colors — it is bipartite, $\chi(P_3) = 2$. One might assume that any coloring using the fewest colors is automatically the cheapest. It is not.

Take the two-coloring that assigns the endpoints $2$ and the center $1$:

$$c(a) = 2, \quad c(b) = 1, \quad c(c) = 2.$$

This uses exactly two colors — optimal for the palette question — yet its total is $2 + 1 + 2 = 5$, strictly more than the true minimum $4$. Minimizing the *number* of colors and minimizing the *sum* of colors are genuinely different optimization problems. An algorithm tuned to find few colors can be blind to cost.

## The star: a clean formula for the simplest trees

The behavior of $P_3$ is not a one-off accident; it is the tip of a family. A **star** $K_{1,n}$ is a single central hub joined to $n$ outer leaves, with no edges among the leaves — think of one router serving $n$ independent devices. (The path $P_3$ is exactly the star $K_{1,2}$.)

Here the sum-optimal strategy is crystal clear and always the same: give the hub the expensive color $2$, and give *every* leaf the cheap color $1$. Since leaves never interfere with each other, they can all share color $1$; only the hub needs something different. The total is

$$\Sigma(K_{1,n}) = 2 + \underbrace{1 + 1 + \cdots + 1}_{n \text{ leaves}} = n + 2.$$

Compare this to the tempting-but-worse alternative of coloring the hub $1$ and each leaf $2$, which costs $1 + 2n$ — nearly *twice* as much for large $n$. The single decision of where to place the cheap color separates a linear cost $n + 2$ from a nearly-doubled cost $1 + 2n$. For a star with a hundred leaves, that is $102$ versus $201$. Concentrating the cheap color on the many, and paying a premium for the one, is the whole game.

This closed form also cements the $P_3$ story: setting $n = 2$ recovers $\Sigma(K_{1,2}) = 4$, exactly as before.

## Why this matters: a conjectured dividing line

These small computations are more than curiosities. They live at the frontier of a genuine open question about *computational difficulty*.

For the ordinary chromatic number, a beautiful classification is known: forbidding certain small "pattern" graphs from appearing inside your network makes coloring easy (solvable quickly), while forbidding others leaves it hard. The chromatic sum is conjectured to obey a strikingly clean version of this dividing line. Fix a small "forbidden pattern" graph $H$, and consider only networks that never contain $H$ as an induced substructure. The **complexity dichotomy conjecture** for the chromatic sum states:

- If $H$ is a **forest** (a graph with no cycles — all trees and disjoint unions of trees), then computing $\Sigma$ on $H$-free networks is *easy*: a fast polynomial-time algorithm exists.
- If $H$ contains even a single **cycle**, then computing $\Sigma$ on $H$-free networks is *hard*: it is NP-complete, as computationally intractable as the toughest problems we know.

A sharp line, drawn by a single feature: does the forbidden pattern contain a loop or not?

The results above are the combinatorial foundation stones for the *easy* side of this line. Trees and forests are exactly the structures conjectured to be tractable, and the star formula $\Sigma(K_{1,n}) = n + 2$ is a first exact, closed-form beachhead on that side — the simplest nontrivial tree family, solved completely. The very phenomena that make the chromatic sum tricky (the failure of $|V| + |E|$, the gap between few-colors and cheap-colors) are precisely the phenomena a good algorithm must navigate, and precisely why the hard side is expected to be hard.

## The takeaway

The chromatic sum reframes coloring as economics. It rewards not diversity but frugality, and its optimal solutions have a counterintuitive signature: sacrifice the busy, high-degree vertices to expensive colors so that their many quiet neighbors can crowd onto the cheap ones. Along the way it demolishes two natural guesses — that the cost is simply vertices plus edges, and that using the fewest colors means paying the least — with a single three-vertex path.

From a floor of $n$ for the edgeless graph, to the triangular number $n(n+1)/2$ for the complete graph, to the clean $n + 2$ for stars, the chromatic sum tells a story of constraint and cost that is at once intuitive enough to explain over coffee and deep enough to sit on the edge of what we can compute efficiently. The cheapest way to color a graph, it turns out, is rarely the obvious one.
