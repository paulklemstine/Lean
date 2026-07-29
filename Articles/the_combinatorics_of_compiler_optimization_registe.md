# When the Busiest Variable Is the Wrong One to Evict

## A graph-theoretic lesson for compiler register allocation

A modern processor can perform arithmetic at astonishing speed, but only on values placed close at hand. Its fastest storage locations are registers: a small bank of named slots sitting directly inside the processor. A compiler translating a program into machine instructions therefore faces a recurring packing problem. Which temporary values should occupy which registers, and what should happen when too many values are needed at once?

This engineering problem has a crisp mathematical translation. Imagine one vertex for every program variable or temporary value. Join two vertices by an edge whenever their values must be available at the same time. Such values *interfere*: assigning them the same register would overwrite one value before its final use. The resulting object is the **interference graph**.

A register assignment is then a graph coloring. Each color represents one register, and adjacent vertices must receive different colors. A graph is **$k$-colorable** if its vertices can be assigned $k$ colors so that adjacent vertices have different colors. The smallest possible $k$ is its **chromatic number**, written $\chi(G)$. Thus $\chi(G)$ is exactly the least number of registers needed when no value is moved to memory.

Two other graph parameters immediately enter the story. The **degree** $\deg(v)$ of a vertex $v$ is the number of its neighbors, and the **maximum degree** is

$$
\Delta(G)=\max_{v\in V(G)}\deg(v).
$$

A **clique** is a set of pairwise adjacent vertices. Its largest possible size is the **clique number** $\omega(G)$. Every member of a clique needs a different color, so

$$
\chi(G)\geq \omega(G).
$$

Meanwhile, a straightforward greedy procedure gives the familiar upper bound $\chi(G)\leq \Delta(G)+1$: when coloring a vertex, at most $\Delta(G)$ colors are forbidden by its neighbors, leaving one color among $\Delta(G)+1$ choices.

It is tempting to turn these two bounds into an exact formula. Could the register requirement be $\max(\Delta(G)+1,\omega(G))$? Since $\omega(G)\leq\Delta(G)+1$ for every nontrivial finite graph, this expression is usually just $\Delta(G)+1$. The temptation is understandable: maximum degree measures local congestion, and local congestion feels like the source of register pressure.

But local congestion and global coloring are not the same thing.

## An eight-vertex reality check

Consider a graph made from two disconnected pieces. The first piece is a triangle on vertices $0,1,2$. Every pair among these three vertices is joined. The second is a star with center $3$ and leaves $4,5,6,7$. The center is joined to all four leaves, while the leaves are not joined to one another. Symbolically, the graph is the disjoint union

$$
K_3\sqcup K_{1,4}.
$$

This tiny graph captures the entire issue.

The triangle requires three colors because its three vertices are pairwise adjacent. Three colors also suffice for the whole graph: use three distinct colors on the triangle, one color on the star center, and a different color on every leaf. Hence

$$
\chi(G)=3.
$$

The center of the star has degree $4$, the triangle vertices have degree $2$, and each leaf has degree $1$. Therefore

$$
\Delta(G)=4,
\qquad
\Delta(G)+1=5.
$$

The proposed degree formula predicts five colors, yet the graph needs only three. The gap does not arise from an exotic or densely tangled construction. It comes from placing a high-degree, easy-to-color star beside a low-degree, genuinely color-demanding triangle. Degree counts neighbors; it does not ask whether those neighbors conflict with one another. Four mutually compatible leaves create less coloring pressure than two neighbors that are themselves adjacent.

This yields the **Degree-Formula Counterexample Theorem**: *There is an eight-vertex interference graph with maximum degree $4$ that is $3$-colorable. Consequently its chromatic number is $3$, whereas $\Delta(G)+1=5$, so the claimed identity $\chi(G)=\max(\Delta(G)+1,\omega(G))$ fails.* Here $\omega(G)=3$, making the claimed right-hand side $5$.

## Why the example remains relevant to SSA programs

Compiler graphs arising from static single assignment, or SSA, often have additional structure. A useful mathematical model is the class of **chordal graphs**. A graph is chordal if every cycle of length at least four has a chord, meaning an edge joining two nonconsecutive vertices of the cycle. Equivalently, a finite graph is chordal when it admits a **perfect elimination ordering**: an ordering of the vertices such that, for each vertex, its earlier neighbors form a clique.

Our eight-vertex graph is chordal. Indeed, use the natural order $0,1,\ldots,7$. For each vertex, inspect its earlier neighbors. Vertex $0$ has none; vertex $1$ has only $0$; vertex $2$ has $0$ and $1$, which are adjacent. Vertex $3$ has no earlier neighbor because the two components are disconnected. Each leaf $4,5,6,7$ has only the center $3$ among its earlier neighbors. Empty sets, singleton sets, and the pair $\{0,1\}$ are all cliques. Thus the order is a perfect elimination ordering.

This proves the **Chordal Structure Theorem for the Example**: *The graph $K_3\sqcup K_{1,4}$ has a perfect elimination ordering and is therefore chordal.* The failure of the degree formula cannot be dismissed as a pathology caused by a long chordless cycle.

Chordality points toward the correct positive principle. Chordal graphs are perfect: for them, the chromatic number equals the clique number. Thus the natural exact target for chordal interference graphs is

$$
\chi(G)=\omega(G),
$$

not $\chi(G)=\Delta(G)+1$. In our example, both sides equal $3$. Maximum degree remains a convenient upper-bound parameter, but it does not determine the optimum.

## Spilling: choosing what to send to memory

When only $k$ registers are available and the interference graph is not $k$-colorable, the compiler may **spill** some values to memory. Mathematically, spilling a set $S$ means deleting those vertices and asking whether the induced graph on $V(G)\setminus S$ is $k$-colorable. A one-vertex spill is successful for budget $k$ if deleting that vertex makes the remaining graph $k$-colorable.

A common intuition says to spill a maximum-degree vertex. The busiest value conflicts with the greatest number of others, so removing it appears likely to relieve the most pressure. Our graph shows why that reasoning can fail even when the graph is chordal.

The unique maximum-degree vertex is the star center $3$, with degree $4$. Spill it. The four leaves become isolated, but the triangle on $0,1,2$ remains untouched. Because a triangle cannot be colored with two colors, the remaining graph still cannot run with two registers.

Now spill vertex $0$, whose degree is only $2$. The triangle collapses to the single edge joining $1$ and $2$, while the star remains. Both components are bipartite, so two colors suffice. One explicit assignment gives one color to $1$ and the star center $3$, and the other color to $2$ and all four leaves. Every surviving edge joins unlike colors.

We therefore obtain the **Failure of Maximum-Degree Spilling Theorem**: *In the chordal graph $K_3\sqcup K_{1,4}$, deleting the maximum-degree vertex $3$ does not make the graph $2$-colorable, while deleting the lower-degree vertex $0$ does. Hence choosing a spill solely by maximum degree need not minimize the register deficit, even for chordal interference graphs.*

The lesson is subtle. Removing the star center deletes four edges, while removing a triangle vertex deletes only two. If success were measured by edge count, the center would look twice as useful. But coloring is controlled by obstructions. The triangle is the obstruction to two-colorability, and only a spill that hits the triangle removes it. Four irrelevant edges are worth less than one strategically chosen vertex.

## From a heuristic to better compiler questions

This counterexample does not say that degree is useless. Degree is cheap to compute, often correlates with live-range pressure, and can be one ingredient in a practical score. It says that degree alone cannot certify optimality. Real compilers also weigh execution frequency, reload cost, rematerialization, loop depth, and interactions among several potential spills. The graph suggests another indispensable ingredient: whether a candidate intersects a clique or another coloring obstruction that exceeds the register budget.

For a budget of $k$ registers, every clique of size $m>k$ forces at least $m-k$ of its vertices to be spilled. This elementary lower bound focuses attention on the right bottleneck. In the example, the triangle has $m=3$ and the budget is $k=2$, so at least one triangle vertex must go. Spilling the star center cannot possibly help with that requirement.

A stronger allocator for chordal graphs can exploit a perfect elimination ordering. Process vertices in the reverse of that order and assign each the smallest available color. Because the already colored neighbors form a clique, their colors are all distinct, and the greedy procedure uses no more colors than the largest clique. This recovers the exact equality $\chi(G)=\omega(G)$ and provides both a coloring and an explanation of why it is optimal.

Spilling then becomes a different optimization problem: delete a minimum-cost set of vertices so that the remaining clique number is at most $k$. With weighted variables, the objective is not to remove the most edges but to minimize total spill cost while hitting every oversized clique sufficiently often. That perspective aligns better with the actual compiler tradeoff.

## A small graph with a large message

The graph $K_3\sqcup K_{1,4}$ has only eight vertices and seven edges. Yet it separates three notions that are easy to blur together:

1. $\Delta(G)+1$ is a general coloring upper bound, not an exact register count.
2. $\omega(G)$ captures exact coloring demand on chordal graphs.
3. Maximum degree does not identify the best vertex to spill.

The star center is locally busiest but globally harmless for three-coloring and irrelevant to the triangle blocking two-coloring. A quieter triangle vertex is the decisive one. That reversal is the heart of the result.

Compiler optimization thrives on heuristics because exact decisions can be expensive. Mathematics helps by showing which heuristics are guarantees and which are guesses. Here the boundary is sharp: perfect elimination and clique structure support exact reasoning, while degree alone supplies only coarse information. When registers are scarce, the right question is not merely “Which variable has the most conflicts?” It is “Which variable participates in the obstruction that actually exceeds the budget?”
