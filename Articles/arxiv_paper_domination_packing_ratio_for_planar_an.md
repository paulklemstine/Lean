# Guard Towers and Watchtowers: How Far Apart Can Covering and Packing Be?

## A problem you have already solved without noticing

Imagine you run a delivery service in a city. You want to place depots so that every neighbourhood is either a depot itself or next door to one. You want as few depots as possible. Call the answer $\gamma$ — the *domination number* of the city's map.

Now play the opposite game. You want to place watchtowers so far apart that no two of them can even see the same street: the "one-block radius" zones around any two towers must be completely disjoint. You want as *many* towers as possible. Call the answer $\rho$ — the *packing number*.

These two games are duals of each other, and one relation is immediate. Every watchtower zone must contain a depot: a depot is required to cover the tower's own block, and any depot that covers it lies inside that tower's zone. Different towers have disjoint zones, so they claim different depots. Therefore

$$\rho(G) \le \gamma(G)$$

for every finite map $G$. Packings are always cheaper than covers.

The interesting question is the reverse. If you can only fit $\rho$ disjoint watchtower zones into your city, how many depots might you still be forced to build? Could the two numbers be wildly different — a city needing a thousand depots even though no two disjoint zones fit anywhere?

This article is about exactly how far apart $\gamma$ and $\rho$ can drift, and about the surprising fact that *geometry* — the mere fact that a map is drawn in the plane, or arises from overlapping circular transmitters — pins them together within a constant factor.

## The formal setup

Let $G$ be a finite graph with vertex set $V$. For a vertex $v$, its **radius-$1$ ball** is
$$B(v) = \{v\} \cup \{u : u \text{ adjacent to } v\},$$
the closed neighbourhood of $v$. A set $D \subseteq V$ is **dominating** if every vertex lies in $B(d)$ for some $d \in D$, and $\gamma(G)$ is the least size of a dominating set. A set $P \subseteq V$ is a **packing** if the balls $B(p)$, $p \in P$, are pairwise disjoint, and $\rho(G)$ is the largest size of a packing.

In the language of hypergraphs, consider the hypergraph whose hyperedges are the balls $B(v)$. Then $\gamma$ is its *transversal number* (fewest vertices hitting every hyperedge) and $\rho$ is its *matching number* (most pairwise disjoint hyperedges). The inequality $\rho \le \gamma$ is the trivial half of an *Erdős–Pósa duality*, and the question is whether the other half — $\gamma \le c \cdot \rho$ for a universal constant $c$ — holds.

There is one reformulation worth recording, because it drives every proof below. Two balls $B(u)$ and $B(v)$ intersect precisely when $u$ and $v$ are at graph distance at most $2$. So a packing is exactly a set of vertices that are pairwise at distance at least $3$, and "the region relevant to $p$" is the ball of radius $2$ around $p$.

## First answer: in general, hopeless

Over *all* finite graphs the ratio $\gamma/\rho$ is unbounded. Here is a clean construction — call it a **spread graph**. Fix numbers $k$ and $t$ with $k < 2t$. The vertices are:

* $k$ **indices** $1, \dots, k$, forming a clique (every two indices adjacent);
* all $t$-element subsets $S \subseteq \{1,\dots,k\}$, forming an independent set;
* an index $i$ is joined to a subset $S$ exactly when $i \in S$.

Because $k < 2t$, any two $t$-subsets must overlap. That single pigeonhole fact makes *every* two balls of the spread graph intersect: two index-balls share indices, an index-ball and a subset-ball share any index of the subset, and two subset-balls share a common element of the two subsets. Hence no two vertices are at distance $\ge 3$, and $\rho = 1$.

Domination, meanwhile, is expensive. Suppose $D$ is a dominating set and let $A$ be the set of indices it contains. A $t$-subset $S$ disjoint from $A$ can only be dominated by putting $S$ itself into $D$ (its other neighbours are indices, and its non-neighbours are other subsets, which are never adjacent to it). Counting how many such subsets can be forced yields

$$\gamma \ge k - t + 1 .$$

Taking $k = 2m$ and $t = m+1$ gives, for every $m \ge 1$, a graph with
$$\rho = 1, \qquad \gamma \ge m .$$

So no inequality of the form $\gamma \le c\rho + b$ can hold for all finite graphs, whatever the constants. If we want a duality theorem, we must restrict the class of graphs.

## Second answer: geometry saves the day

Restrict to **unit disk graphs**: vertices are points of the plane, two distinct points adjacent when their distance is at most $1$. (These model wireless networks, where each transmitter reaches everything within a fixed radius.) Now something remarkable happens: $\gamma$ and $\rho$ are locked within a constant.

The mechanism is a single, very general lemma, which we may call the **local cover principle**.

> **Local Cover Principle.** Let $G$ be a finite graph and $c$ a number. Suppose that for every vertex $p$ there is a set $D_p$ of at most $c$ vertices dominating everything at distance $\le 2$ from $p$. Then $\gamma(G) \le c \cdot \rho(G)$.

*Why it is true.* Take a packing $P$ of maximum size $\rho$. Being maximum, it is in particular *maximal*: no vertex can be added. That means every vertex $v$ of the graph is at distance at most $2$ from some $p \in P$ — otherwise $P \cup \{v\}$ would be a bigger packing. So the radius-$2$ balls around $P$ cover the whole graph. Replace each of them by its $c$-element dominator $D_p$ and take the union: it dominates everything and has at most $c\rho$ vertices. $\square$

The elegance is that the entire graph-theoretic problem has been reduced to a *purely local* question: how many vertices are needed to dominate a radius-$2$ neighbourhood?

Two instant corollaries. First, in any graph the closed neighbourhood of $p$ alone dominates everything within distance $2$ of $p$, and it has at most $\Delta + 1$ vertices where $\Delta$ is the maximum degree. Hence
$$\gamma(G) \le (\Delta + 1)\,\rho(G)$$
for every finite graph. Second — and this is the geometric payoff — in a unit disk graph, take a *maximal independent* subset $I$ of the radius-$2$ neighbourhood of $p$. Maximality means $I$ dominates that neighbourhood. Independence means the corresponding points are pairwise at distance more than $1$. And all of them lie inside a disk of radius $2$ around $p$. So the whole question becomes:

> How many points, pairwise more than $1$ apart, fit in a disk of radius $2$?

A crude but rigorous count answers this: put a disk of radius $\tfrac12$ around each point; these are pairwise disjoint and all sit inside a disk of radius $\tfrac52$. Comparing areas, the number of points is at most $(5/2)^2/(1/2)^2 = 25$. Therefore

$$\gamma(G) \le 25\,\rho(G) \quad\text{for every unit disk graph } G.$$

Equivalently, in Erdős–Pósa form: in any unit disk network, *either* there are $k$ pairwise disjoint one-hop zones, *or* $25k$ vertices suffice to be within one hop of everything.

Nothing about the argument is two-dimensional. In $\mathbb{R}^n$, the same volume comparison gives at most $5^n$ points, hence $\gamma \le 5^n \rho$ for unit ball graphs in $\mathbb{R}^n$. The abstract statement is worth isolating: say a metric space $X$ has **local packing bound** $N$ if no ball of radius $2$ in $X$ contains more than $N$ points that are pairwise more than $1$ apart. Then every graph represented by points of $X$ (adjacency = distinct and at distance $\le 1$) satisfies $\gamma \le N\rho$. Geometry enters the graph theory through exactly one number.

It should be said that the constant $25$ is not the last word — a careful analysis of how $1$-separated points can be arranged in a disk of radius $2$ pushes the geometric input down, and the literature on this problem has driven the unit-disk constant to $18\sqrt3/\pi \approx 9.924$ and the planar constant to $5$, by more elaborate arguments. What the volume count buys is a fully rigorous, entirely elementary bound with the same shape.

## The line: the ratio collapses to one

Go down a dimension. What is the local packing bound of the real line? An interval of radius $2$ has length $4$, and points pairwise more than $1$ apart inside it are at most $4$ in number: the map $x \mapsto \min(\lfloor x - (c-2)\rfloor, 3)$ is injective on such a set with values in $\{0,1,2,3\}$. So $\gamma \le 4\rho$ for unit interval graphs. And $4$ is genuinely optimal for this method: the four points $0, \tfrac{11}{10}, \tfrac{11}{5}, \tfrac{33}{10}$ all lie within distance $2$ of the point $2$ and are pairwise more than $1$ apart, so no bound of $3$ is available.

But the truth on the line is far better than $4$: the ratio is exactly $1$. And it is true not just for unit interval graphs, but for all **interval graphs**, where each vertex $v$ receives an arbitrary closed interval $[\ell(v), r(v)]$ and adjacency means the intervals meet.

> **Interval Graph Theorem.** For every finite interval graph $G$, $\gamma(G) = \rho(G)$.

The proof is a greedy sweep from left to right — the same idea that solves the classic "minimum number of stabbing points for a family of intervals" puzzle. Given the current set $S$ of undominated vertices, pick $u \in S$ whose interval ends *first*. Among all vertices whose interval meets $u$'s, pick the one, $d$, whose interval ends *last*. Put $d$ into the dominating set and bank $u$ into the packing. Then delete everything $d$ dominates, and repeat. Every vertex surviving the deletion begins strictly to the right of $r(d)$, which is precisely what guarantees that the banked centres $u$ have pairwise disjoint balls. The result is a dominating set and a packing of *equal* size, so $\gamma \le |D| = |P| \le \rho$; combined with the universal $\rho \le \gamma$, equality follows.

A concrete instance: the path $P_n$ on $n$ vertices, where vertex $i$ sits at the real number $i$. Here
$$\gamma(P_n) = \rho(P_n) = \left\lceil \tfrac n3\right\rceil,$$
witnessed on the packing side by the vertices with index divisible by $3$, whose balls $\{i-1,i,i+1\}$ are pairwise disjoint.

## What makes the ratio collapse? A one-line criterion

Both the interval sweep and, as it turns out, the classical theory of trees are instances of a single abstract condition. Say a graph $G$ has a **greedy dominator** if for every nonempty finite set $S$ of vertices there is a vertex $u \in S$ and a *single* vertex $d$ such that every $s \in S$ at distance at most $2$ from $u$ lies in the ball of $d$. In words: some member of $S$ has the part of its radius-$2$ neighbourhood inside $S$ collapsible onto one closed neighbourhood.

> **Collapse Theorem.** If $G$ has a greedy dominator, then $\gamma(G) = \rho(G)$.

The proof runs the greedy: spend the single dominator $d$, bank $u$ as a packing centre, recurse on what is left. Because $u$'s whole distance-$2$ neighbourhood inside $S$ is removed at each step, the banked centres are pairwise at distance $\ge 3$ — a packing — and the dominators are equinumerous with them.

Interval graphs have a greedy dominator, by the earliest-endpoint rule already described. So do forests, and that is the classical theorem of Meir and Moon:

> **Meir–Moon Theorem.** For every finite forest $F$, $\gamma(F) = \rho(F)$.

The greedy dominator for a forest comes from rooting each component and choosing $u \in S$ of *maximal depth*, with $d$ the parent of $u$. Why does the parent capture the whole distance-$2$ neighbourhood of $u$ inside $S$? Two structural facts about acyclic graphs do the work. First, adjacent vertices always have different depths — otherwise a cycle appears. Second, a vertex has at most one parent: two neighbours at depth one less than $u$ would close a cycle. Hence a neighbour of $u$ in $S$ can only be its parent (children would be deeper, contradicting maximality), and a vertex of $S$ at distance exactly $2$ from $u$ either hangs off $u$'s parent, or would be a second parent of a child of $u$, hence equals $u$. Everything relevant lands in the closed neighbourhood of the parent.

The criterion is a genuine restriction, not a tautology. The $4$-cycle fails it: $\gamma(C_4) = 2$ while $\rho(C_4) = 1$, since all four closed neighbourhoods pairwise intersect. And $C_4$ is a unit disk graph — the four points $(0,0), (\tfrac45, 0), (\tfrac45, \tfrac{21}{25}), (0, \tfrac{21}{25})$ realize it, with consecutive distances $\le 1$ and diagonals $> 1$. So already in the plane the ratio exceeds $1$, and the collapse to $\gamma = \rho$ is a one-dimensional/acyclic phenomenon. As a bonus consistency check, the failure of the criterion for $C_4$ re-proves that $C_4$ is not a forest.

## How large must the constant be? The Wagner family

We have $\gamma \le 25\rho$ in the plane and $\gamma = \rho$ on trees and on the line. What is the truth in between — how big must the constant be?

Meet the **Wagner graph** $V_8$, also known as the Möbius ladder $M_4$: eight vertices arranged in a cycle $0 - 1 - \cdots - 7 - 0$, with the four long diagonals $i \sim i+4$ added. It is a $3$-regular graph on eight vertices. Two facts, both checkable by finite inspection:

* every two closed neighbourhoods of $V_8$ intersect, so $\rho(V_8) = 1$;
* no two vertices dominate $V_8$ (each closed neighbourhood has $4$ of the $8$ vertices, and no two of them cover everything), while $\{0,1,2\}$ does. So $\gamma(V_8) = 3$.

Hence $\gamma = 3\rho$. But a single eight-vertex graph proves very little: perhaps the ratio $3$ is a small-scale artefact, and $\gamma \le \rho + O(1)$, or $\gamma \le c\rho$ with $c < 3$, holds asymptotically. It does not. Take $k$ disjoint copies of $V_8$ — vertex set $\{1,\dots,k\}\times\{0,\dots,7\}$ with $(i,a)$ adjacent to $(j,b)$ iff $i = j$ and $a \sim b$ in $V_8$. Then

$$\rho = k, \qquad \gamma = 3k, \qquad \text{so } \gamma = 3\rho \text{ with } \rho \text{ arbitrarily large.}$$

Both computations are fibrewise. A ball never leaves its copy, so a packing takes at most one vertex per copy (all balls within a copy meet) and can take exactly one; and a dominating set of the union restricts, copy by copy, to a dominating set of $V_8$, each of which needs three vertices — while three vertices per copy suffice.

The consequence is sharp: **no bound $\gamma \le c\rho + b$ can hold with $c < 3$**, for if it did, then $3k \le ck + b$ for every $k$, which fails at $k = b+1$ when $c \le 2$. The additive slack $b$ buys nothing when the ratio persists at every scale. ($V_8$ is not planar, so this particular family bounds the constant for general graph classes containing it; the $4$-cycle already forces the constant to be at least $2$ for unit disk graphs.)

## The landscape

Putting the pieces side by side:

| class | domination–packing ratio |
| --- | --- |
| all finite graphs | unbounded ($\rho = 1$, $\gamma \ge m$ for every $m$) |
| all finite graphs, degree $\le \Delta$ | at most $\Delta + 1$ |
| forests, interval graphs, paths | exactly $1$ |
| unit interval graphs (via geometry alone) | at most $4$ |
| unit disk graphs | at least $2$; at most $25$ by area count |
| unit ball graphs in $\mathbb{R}^n$ | at most $5^n$ |
| graphs containing large Wagner families | at least $3$ |

The moral is that a single number controls the whole story in the geometric cases: the maximum number of points, pairwise more than $1$ apart, that fit in a ball of radius $2$. Everything else — the maximal-packing argument, the maximal-independent-set trick, the counting — is soft and uniform. Improving the graph theorem is *exactly* a finite plane-packing problem: how many $1$-separated points fit in a disk of radius $2$? The area count is visibly lossy: an explicit arrangement — the centre, a ring of six points at radius $1.05$, and a ring of twelve points at radius $2$ offset by $15°$ — achieves $19$ pairwise-separated points, and $19$ is believed to be the exact answer. That single finite question is the one place where more work still pays.

There is an appealing symmetry to how the story ends. On the line and on trees, geometry is so rigid that greed is optimal and covering costs exactly what packing gains. In the plane, greed is no longer optimal, but the local rigidity of Euclidean space still ties the two within a constant. And in the wild world of all graphs, where no locality survives, the two invariants fly apart without limit. Between order and chaos, geometry is precisely the amount of structure needed to make duality hold — up to a constant.
