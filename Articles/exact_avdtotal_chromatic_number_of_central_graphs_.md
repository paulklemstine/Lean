# When Colours Have to Tell Vertices Apart: A Surprise in the Central Graphs of Regular Networks

Imagine you are asked to paint every point *and* every road of a country's map so that no two roads meeting at a town share a colour, no road matches either town it connects, and no two neighbouring towns share a colour either. That is the puzzle of **total colouring**: colour the vertices and the edges of a graph together, keeping everything that touches everything else distinct. It is one of the oldest and most stubborn problems in combinatorics — the *Total Colouring Conjecture*, that any graph can be totally coloured with only two colours more than its busiest vertex needs, has been open for more than half a century.

This article is about a twist on that puzzle that makes it even more demanding, and about a specific family of graphs where the answer turns out to be cleaner — and more surprising — than the experts predicted.

## Colours that carry a signature

Start with an ordinary total colouring, and then add one more rule. For each town (vertex) $w$, gather up the colour painted on the town itself together with the colours of all the roads leaving it. Call this bundle the town's **colour set** — its *signature*. The extra rule is simple to state and hard to satisfy:

> **Neighbouring towns must have different signatures.**

A total colouring obeying this is called an **adjacent-vertex-distinguishing total colouring**, or AVD total colouring for short. The idea is that colours should do more than avoid clashes: they should let you *tell adjacent places apart* just by looking at the palette of colours around them. The least number of colours needed to pull this off is written $\chi''_a(G)$, the AVD-total chromatic number.

The distinguishing requirement can be surprisingly costly. Consider two neighbouring towns that happen to have the *same number* of roads. Around each of them you must use its own colour plus one colour per road, and — because everything at a single town touches everything else — all of those colours must be different. So a town of degree $r$ always displays exactly $r+1$ distinct colours. Now suppose the whole map uses a palette of only $\Delta+1$ colours, where $\Delta$ is the largest degree anywhere. A town of maximum degree $\Delta$ then displays $\Delta+1$ colours — *the entire palette*. If two neighbouring towns both have maximum degree, they both light up the whole palette, so their signatures are identical. The distinguishing rule is violated. The escape is to widen the palette: you need at least $\Delta+2$ colours whenever two adjacent vertices both sit at the maximum degree. This little observation — that **adjacent maximum-degree vertices force an extra colour** — is the engine behind everything that follows.

## The central graph: subdivide, then complete

Our stage is not an arbitrary network but a very particular construction called the **central graph** of a graph $G$, written $C(G)$. You build it in two moves:

1. **Subdivide every edge.** Put a brand-new vertex in the middle of each existing edge, splitting that edge into two.
2. **Join every non-adjacent pair.** For every two original vertices that were *not* connected in $G$, add a fresh edge between them.

The result blends $G$ with its own complement, threaded through a layer of midpoints. Central graphs show up whenever you want a canonical, symmetric way to "expand" a network, and their colourings have been studied precisely because they stress-test colouring rules in interesting ways.

Two facts about $C(G)$ are worth internalising, because they drive the whole story. Suppose $G$ has $n$ vertices.

- **Every midpoint has degree exactly $2$.** A subdivision vertex sits on one original edge and touches only that edge's two endpoints. Nothing else.
- **Every original vertex has degree exactly $n-1$.** This is the striking one. Take an original vertex $u$. For each vertex it *was* adjacent to in $G$, it now reaches the midpoint on that edge; for each vertex it was *not* adjacent to, it now has a direct new edge. Either way, $u$ acquires exactly one connection accounting for every other original vertex. Add them up: $u$ touches all $n-1$ of them, one way or another.

So in $C(G)$ the original vertices are the celebrities — each of maximum degree $n-1$ — while the midpoints are humble degree-$2$ connectors.

## The conjecture, and why it cannot be right

Here is where a natural-looking guess enters. If $G$ is *regular* — every vertex with the same degree $d$ — one might hope for a clean formula. A widely circulated conjecture proposed that for every $d$-regular graph $G$ that is *not* complete,
$$\chi''_a(C(G)) = d + 3,$$
with the lone complete graph $K_{d+1}$ giving the slightly smaller $d+2$. It is a tidy, tempting statement: the answer depends only on the regularity $d$.

But the degree calculation above quietly demolishes it. The value that matters is not $d$ but $n$, the *number of vertices*. Here is the argument, in full.

If $G$ is regular but not complete, then somewhere there are two vertices $a$ and $b$ that are *not* joined in $G$. By the central-graph rule, non-adjacency in $G$ becomes adjacency in $C(G)$ — so $a$ and $b$ *are* neighbours in $C(G)$. And both, being original vertices, have degree $n-1$, the maximum. We now have exactly the dangerous configuration from earlier: two adjacent vertices, both of maximum degree. The extra-colour principle applies verbatim, and it says
$$\chi''_a(C(G)) \ge (n-1) + 2 = n + 1.$$

Compare this proven lower bound, $n+1$, with the conjectured answer $d+3$. Because $G$ is regular but not complete, each vertex misses at least one other vertex, so $n \ge d + 2$, i.e. $n + 1 \ge d + 3$. The two agree only in the razor-thin boundary case $n = d+2$ — where each vertex is non-adjacent to exactly one other. The instant $n > d+2$, the true answer *overshoots* the conjecture: it is impossible to AVD-total-colour $C(G)$ with only $d+3$ colours.

The cleanest witness is the humble pentagon. Take $G = C_5$, the $5$-cycle. It is $2$-regular, so the conjecture predicts $\chi''_a(C(C_5)) = d + 3 = 5$. But $C_5$ has $n = 5$ vertices, and non-adjacent pairs abound (each vertex misses two others). So the lower bound bites: $\chi''_a(C(C_5)) \ge 5 + 1 = 6$. Five colours provably cannot do the job. The conjecture is off by one on the very first non-trivial regular graph you would try.

## Why the complete graph is the exception that proves the rule

The special status the conjecture grants to complete graphs turns out to have a genuine structural reason — just not the one the formula suggests. In $C(K_n)$, *every* pair of original vertices was adjacent in $K_n$, so by the central-graph rule *no* two of them are adjacent in $C(K_n)$. The original vertices form an **independent set**: they are mutually non-neighbours. The "two adjacent maximum-degree vertices" trap simply never springs, because no two maximum-degree vertices are adjacent at all. This is exactly why the complete case behaves differently. It is not a coincidence to be patched over with a separate formula; it is the single hypothesis — "some pair of vertices is non-adjacent" — that the whole lower-bound argument rests on, and complete graphs are precisely the graphs that fail it.

## A unifying picture

Once you see that the governing quantity is $n$ rather than $d$, a much cleaner conjecture emerges. Collect the evidence:

- For a **non-complete** regular $G$ on $n$ vertices, the two maximum-degree neighbours force $\chi''_a(C(G)) \ge n + 1$.
- For the **complete** graph $K_{d+1}$, we have $n = d+1$, and the classically expected value $d+2$ is *also* $n+1$.

Both cases point to the same elegant statement:
$$\boxed{\chi''_a(C(G)) = |V(G)| + 1 \quad\text{for every regular } G.}$$
The old $d$-based formula was a shadow of this: it happened to coincide with $n+1$ only at the boundary and for complete graphs, and diverged everywhere else.

What has been *established* here are the lower bounds — the "at least $n+1$" half — together with the exact degree structure and the independent-set anatomy of the complete case. These are unconditional. The matching *upper* bound, an explicit recipe that colours $C(G)$ with exactly $n+1$ colours for every regular $G$, is the natural next target; it would turn the boxed equation from a well-supported conjecture into a theorem. Small cases already agree perfectly: for $G = K_3$, the central graph $C(K_3)$ is nothing but the $6$-cycle, and a direct search shows its AVD-total chromatic number is exactly $4 = n + 1$.

## Why any of this matters

Total colourings are not just a game. They model scheduling problems where both "resources" (vertices) and "interactions" (edges) must be assigned non-conflicting slots — think of assigning frequencies to both transmitters and the links between them, or time-slots to both machines and the jobs that pass between them. The distinguishing refinement adds a diagnostic flavour: it guarantees that neighbouring units are recognisable from their local colour footprint alone, a property useful for fault localisation and for symmetry-breaking in distributed systems.

But the deeper lesson here is a cautionary tale about *which parameter is really in charge*. A conjecture phrased in terms of the regularity $d$ looked natural, symmetric, and plausible — and was quietly wrong, because the central-graph construction secretly promotes every original vertex to degree $n-1$. The moment you compute that degree, the correct invariant announces itself. It is a small, sharp reminder that in combinatorics the honest bookkeeping of degrees, done carefully, often overrules the prettiest guess. And in this case it replaces a fragmented, case-split formula with a single clean law: to distinguish the neighbours in the central graph of any regular network, you need exactly one colour more than it has vertices.
