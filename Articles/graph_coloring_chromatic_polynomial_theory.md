# Coloring by Counting: The Recurrence Inside Every Graph

A mapmaker reaches for four colors. A compiler assigns registers to variables. A school scheduler places classes into time slots. At first glance these tasks have little in common, but each asks the same mathematical question: how can labels be assigned to objects that are not allowed to agree with certain neighbors?

A **finite simple graph** distills the question. Its vertices are the objects, and an edge joins each incompatible pair. A **proper coloring with $q$ colors** assigns one of $q$ labels to every vertex so that the endpoints of every edge receive different labels. Finding one coloring is useful, but counting all of them reveals much more. Let $P(G,q)$ denote the number of proper $q$-colorings of a graph $G$. The function $P$ measures a network’s flexibility: a small value means constraints are tight, while a large value means many assignments survive.

The central discovery is that this seemingly global count can be understood one edge at a time. Choose an edge, erase it, and compare two possibilities: its endpoints either remain different or become equal. That simple split produces the deletion–contraction recurrence, the engine of chromatic-polynomial theory.

Counting also changes the kind of answer mathematics can give. A yes-or-no result says whether a palette works; a count says how resilient the solution is. Ten thousand valid schedules can absorb a late change more easily than one unique schedule. In that sense, the chromatic count is a measure not only of possibility but of room to maneuver.

## Two extreme worlds

Before opening the engine, it helps to calibrate the count at opposite extremes.

Suppose $E_n$ is the edgeless graph on $n$ vertices. No pair conflicts, so every vertex may be colored independently. There are $q$ choices at each of $n$ vertices. Therefore the Empty-Graph Theorem states

$$
P(E_n,q)=q^n.
$$

At the other extreme lies the complete graph $K_n$, in which every pair of distinct vertices is adjacent. A proper coloring must give all $n$ vertices distinct colors. The first vertex has $q$ choices, the second has $q-1$, and so on. The Complete-Graph Theorem states

$$
P(K_n,q)=q(q-1)(q-2)\cdots(q-n+1)=q^{\underline n},
$$

where $q^{\underline n}$ is the falling factorial. If $q<n$, one factor is zero, reflecting the impossibility of coloring $K_n$ with too few colors.

These formulas are more than examples. They are terminal cases for a recursive counting process. Repeatedly simplify a graph until only easy pieces remain, evaluate those pieces, and rebuild the answer.

## The decisive move: delete or contract

Choose an edge $e=\{a,b\}$ of $G$. The **deletion** $G-e$ keeps every vertex but removes that one edge. The **contraction** $G/e$ merges $a$ and $b$ into a single vertex; the merged vertex is adjacent to every former neighbor of either endpoint, with loops discarded because the graph remains simple.

Now inspect all proper colorings of $G-e$. Because the edge between $a$ and $b$ has vanished, such a coloring falls into exactly one of two classes.

* If $a$ and $b$ have different colors, the missing edge constraint is already satisfied. The coloring is therefore a proper coloring of $G$.
* If $a$ and $b$ have the same color, the two endpoints can be fused. Restricting the coloring to the contracted graph gives a proper coloring of $G/e$. Conversely, any proper coloring of $G/e$ expands uniquely by assigning the merged color to both $a$ and $b$.

The classes are disjoint and exhaustive. Counting them gives the Deletion–Contraction Theorem:

$$
P(G-e,q)=P(G,q)+P(G/e,q).
$$

Equivalently,

$$
P(G,q)=P(G-e,q)-P(G/e,q).
$$

The proof is a bijective argument, not a symbolic trick. The contraction term counts exactly those assignments newly permitted by deleting the edge—those in which its endpoints collapse to one color. In particular,

$$
P(G/e,q)\le P(G-e,q),
$$

because the contraction colorings correspond to a subset of the deletion colorings.

## A triangle becomes a path

Take a triangle $K_3$ and delete one edge. The result is a three-vertex path. For $q=3$, the triangle has

$$
P(K_3,3)=3\cdot2\cdot1=6
$$

proper colorings. Contracting the deleted edge in the triangle produces a single edge $K_2$, which has

$$
P(K_2,3)=3\cdot2=6
$$

colorings. The path therefore has

$$
P(K_3-e,3)=6+6=12
$$

proper colorings. One can see the two groups directly: six assignments give the path’s endpoints different colors, and six give them the same color.

For general $q$, the same calculation reads

$$
q(q-1)^2=q(q-1)(q-2)+q(q-1).
$$

The left side colors the path by choosing its middle color and then independently choosing a different color for each endpoint. The right side separates endpoint-distinct colorings from endpoint-equal colorings. The identity is algebraic, but its reason is combinatorial.

## Independent worlds multiply

Many networks break into disconnected components. Let $G\sqcup H$ be the disjoint union of graphs $G$ and $H$: vertices from different parts share no edges. A coloring of the union is proper precisely when its restriction to each component is proper. Choosing the coloring of $G$ and choosing the coloring of $H$ are independent decisions. Thus the Disjoint-Union Theorem states

$$
P(G\sqcup H,q)=P(G,q)P(H,q).
$$

This product law has an immediate practical meaning. If a scheduling problem separates into departments with no cross-department conflicts, the number of global schedules is the product of the departmental counts. It also accelerates computation: disconnected graphs should be split before recursion, preventing unrelated choices from being mixed in one search tree.

For example, the disjoint union of an edge and an isolated vertex has

$$
P(K_2\sqcup E_1,q)=q(q-1)\cdot q=q^2(q-1)
$$

colorings. At $q=3$, that is $18$.

## Why call it a polynomial?

The quantity $P(G,q)$ was defined for nonnegative integers $q$ by counting assignments. Deletion–contraction explains why these values are governed by a polynomial. Start with an edgeless graph, whose count is the polynomial $q^n$. Adding constraints can be handled recursively through subtraction after deletion and contraction. Each step combines smaller graph counts using polynomial operations. The resulting expression agrees with the coloring count for every palette size.

The current results can be read safely at the level of the counting function: empty and complete graphs have closed forms, deletion–contraction holds at every finite palette size, and disjoint unions multiply. These statements already provide a complete recursive calculus for numerical evaluation. A fuller algebraic treatment constructs a single integer-coefficient polynomial object and proves that every natural-number evaluation matches the count; that is a natural next stage rather than an assumption needed here.

## An algorithm hidden in a theorem

The recurrence immediately suggests an exact algorithm.

1. If the graph has no edges, return $q^n$.
2. If the graph is disconnected, evaluate each component and multiply the answers.
3. Otherwise choose an edge $e$.
4. Recursively evaluate $G-e$ and $G/e$, then subtract:

$$
P(G,q)=P(G-e,q)-P(G/e,q).
$$

The algorithm is exact, but worst-case exponential: every chosen edge may branch into two subproblems. That is not a flaw in the theorem; it reflects the intrinsic difficulty of exact coloring counts. Still, structure matters enormously. Component factorization, memoization of repeated graphs, and intelligent edge selection can shrink the recursion dramatically.

There is also a straightforward independent method: enumerate all $q^n$ assignments and reject those that violate an edge. This brute-force method is often slower, but it is valuable for small examples and for checking a recurrence implementation. Two conceptually different routes—direct enumeration and deletion–contraction—should return the same number.

## From maps to constrained systems

Graph coloring first became famous through maps: neighboring regions require different colors. Yet counting colorings asks a richer question than whether a map can be colored. It measures redundancy. If one color becomes unavailable, how many assignments survive? If a constraint is removed, how much freedom appears? The contraction term answers the second question exactly.

In register allocation, vertices represent quantities that are simultaneously active, edges represent interference, and colors represent registers. In frequency assignment, edges connect transmitters that must avoid the same channel. In timetabling, edges connect events that cannot occur simultaneously. The value $P(G,q)$ counts feasible allocations, while comparisons among $P(G,q)$ for different $q$ quantify the effect of adding resources.

Deletion–contraction also offers a form of sensitivity analysis. Removing one incompatibility changes the count by precisely $P(G/e,q)$. A large contraction count identifies an edge whose removal unlocks many assignments; a zero contraction count means that, at that palette size, deleting the edge creates no new proper colorings.

## The larger landscape

Several celebrated coloring statements lie beyond the counting results established here. Brooks’ theorem concerns upper bounds for the least number of colors required, with complete graphs and odd cycles as exceptions. The Four Color Theorem concerns planar graphs. Positivity conjectures for special graph classes require richer polynomial bases. These topics share the vocabulary of coloring, but they are not consequences of the elementary recurrence alone and should not be conflated with it.

What deletion–contraction does provide is the dependable foundation on which such investigations can build. It turns a global constraint problem into a local dichotomy. It explains the empty and complete cases, supports exact computation, and cooperates perfectly with disconnected decomposition.

The deepest idea is almost childlike: after erasing one line, its endpoints are either different or the same. Yet from that binary choice comes a calculus for an entire graph. The colors may represent paints, times, channels, or memories; the recurrence remains unchanged. Count the assignments, split them cleanly, and let the network reveal its structure one edge at a time.
