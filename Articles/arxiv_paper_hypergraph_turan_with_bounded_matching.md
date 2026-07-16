# Pair-Stars and Forbidden Triangles: Building Large Hypergraphs with Small Matchings

A triangle is the simplest closed loop. Three points, three connecting lines, and suddenly a network has acquired a cycle. In ordinary graph theory, forbidding triangles imposes a famous kind of scarcity: a graph on $n$ vertices with no triangle cannot have more than roughly $n^2/4$ edges. Hypergraphs complicate this picture. Their edges may join three or more vertices at once, so even deciding what should count as a triangle requires care.

One especially fruitful notion is the **Berge triangle**. In a $3$-uniform hypergraph, every hyperedge is a set of exactly three vertices. A Berge triangle consists of three distinct core vertices $a,b,c$ and three distinct hyperedges $E_{ab},E_{bc},E_{ca}$ such that

$$
\{a,b\}\subseteq E_{ab},\qquad \{b,c\}\subseteq E_{bc},\qquad \{c,a\}\subseteq E_{ca}.
$$

The hyperedges may contain extra vertices, but each side of the core triangle must receive its own representative. This definition preserves the combinatorial essence of a triangle while allowing the larger edges of a hypergraph.

Now impose a second restriction. A **matching** is a collection of pairwise disjoint hyperedges, and the **matching number** is the largest possible size of such a collection. Bounding the matching number says that the network cannot support too many mutually independent interactions. This condition appears naturally when hyperedges represent teams competing for people, transactions competing for resources, or tasks competing for machines.

The central construction described here shows how to create many $3$-vertex interactions while simultaneously avoiding Berge triangles and keeping the matching number exactly controlled. Its geometry is simple enough to visualize and rigid enough to analyze completely.

## The pair-star architecture

Choose two nonnegative integers $s$ and $t$. Create $s$ disjoint pairs of special vertices,

$$
P_i=\{u_i,v_i\},\qquad 1\le i\le s,
$$

and create a separate set $X=\{x_1,\ldots,x_t\}$ of outside vertices. For every pair $P_i$ and every outside vertex $x_j$, introduce the hyperedge

$$
E_{i,j}=P_i\cup\{x_j\}=\{u_i,v_i,x_j\}.
$$

The resulting hypergraph is a union of $s$ **pair-stars**. Each special pair is the fixed two-vertex spine of one star, and its $t$ edges are obtained by attaching the outside vertices one at a time.

Several numerical facts are immediate but important. The construction has

$$
2s+t
$$

vertices, because the $s$ spine pairs contribute $2s$ vertices and the outside set contributes $t$. Every edge has exactly three vertices. The indexing pair $(i,j)$ uniquely determines its edge, so the number of edges is exactly

$$
st.
$$

This is already a remarkably efficient design: every outside vertex participates in one edge from every pair-star.

## The fingerprint of two edges

The entire structure can be read from how pairs of edges intersect. Consider $E_{i,x}$ and $E_{j,y}$. Their intersection has size

$$
|E_{i,x}\cap E_{j,y}|=
\begin{cases}
3,&i=j\text{ and }x=y,\\
2,&i=j\text{ and }x\ne y,\\
1,&i\ne j\text{ and }x=y,\\
0,&i\ne j\text{ and }x\ne y.
\end{cases}
$$

Thus two distinct edges in the same pair-star share the whole spine pair. Edges from different pair-stars can share only their outside vertex, and otherwise are disjoint. This four-case formula is the construction’s fingerprint. It explains both its matching behavior and its resistance to triangles.

For matchings, the first consequence is decisive: a matching can use at most one edge from each pair-star, because two edges with the same spine overlap in two vertices. Therefore every matching has at most $s$ edges.

When $t\ge s$, this upper bound is attained. Assign distinct outside vertices to the $s$ spine pairs and choose

$$
E_{1,1},E_{2,2},\ldots,E_{s,s}.
$$

Their spines are disjoint and their outside vertices are distinct, so the selected edges are pairwise disjoint. The matching number is therefore exactly $s$ whenever $t\ge s$.

This argument has a resource-allocation interpretation. Each spine pair acts like a department with an inseparable two-person core, while the outside vertices are shared contractors. Any independent portfolio can contain only one project from each department; if at least $s$ contractors are available, all $s$ departments can run disjoint projects simultaneously.

## Why no Berge triangle can form

The absence of Berge triangles is subtler, but the pair-star geometry makes it inevitable.

Every edge contains exactly one complete spine pair and one outside vertex. Suppose three distinct core vertices were to form a Berge triangle, with their three pairs represented by three distinct hyperedges. If two core vertices lie in the same spine pair, then any edge containing both belongs to that one pair-star. To connect either spine vertex to the third core vertex, the structure forces severe repetition: the only possible extra vertex in such an edge is an outside vertex, and the required representatives cannot all remain distinct.

If no two core vertices form a spine pair, then an edge cannot contain two core vertices from two different spines. The only way an edge meets two such cores is when one is an outside vertex and the other is a spine vertex. But among three core vertices, the cyclic demand would then require incompatible types: each of the three pairs would need one outside and one spine vertex, which is impossible around an odd cycle. If two or three cores are outside vertices, no edge can contain the corresponding outside-outside pair at all.

These cases exhaust the possibilities. Hence the construction contains no Berge triangle.

The result is worth stating in full:

**Pair-Star Construction Theorem.** For all nonnegative integers $s$ and $t$, the pair-star hypergraph has $2s+t$ vertices, exactly $st$ edges, and every edge has size $3$. It is Berge-triangle-free, and every matching has at most $s$ edges. If $s\le t$, it contains a matching of size $s$, so its matching number is exactly $s$.

## Tuning the construction to $n$ vertices

Suppose the desired number of vertices is $n$ and the desired matching number is $s$, with

$$
n\ge 3s.
$$

Set

$$
t=n-2s.
$$

Then $t\ge s$, so the exact matching conclusion applies. The vertex count becomes

$$
2s+t=2s+(n-2s)=n,
$$

and the edge count becomes

$$
st=s(n-2s).
$$

We therefore obtain the principal sharpness statement:

**Extremal Lower-Bound Theorem.** If $n\ge 3s$, there exists an $n$-vertex, $3$-uniform, Berge-triangle-free hypergraph with matching number exactly $s$ and exactly $s(n-2s)$ edges.

This theorem is a construction result: it proves that no universal upper bound for this problem can be smaller than $s(n-2s)$. A separate structural argument is needed to prove that every hypergraph obeying the same restrictions has at most this many edges, and a still finer equality analysis is needed to show uniqueness. The pair-star family supplies the target that such an upper-bound theory must meet.

## A concrete example

Take $n=12$ and $s=3$. Then $t=12-6=6$. There are three spine pairs and six outside vertices, for a total of twelve vertices. Every spine pair combines with each outside vertex, producing

$$
3\cdot 6=18
$$

hyperedges. No matching has more than three edges, while choosing three different spines and three different outside vertices gives a matching of size three. No Berge triangle occurs.

The example also reveals the density mechanism. Reusing a spine pair creates many edges cheaply, but that reuse prevents those edges from coexisting in a matching. Sharing outside vertices across different stars boosts the total edge count, yet the rigid “one spine pair plus one outside vertex” format blocks the three distinct representatives needed for a Berge triangle.

## Why the construction matters

Extremal combinatorics often advances through a tension between freedom and obstruction. One wants as many edges as possible, but forbidden configurations remove certain patterns, while a matching bound limits independence. The pair-star construction resolves both pressures through deliberate overlap. It concentrates edges around $s$ disjoint two-vertex cores, turning overlap from a defect into a design principle.

This principle has analogues beyond pure mathematics. In scheduling, repeated use of a fixed bottleneck pair limits simultaneous execution. In database systems, transactions sharing a locked resource cannot run independently. In experimental design, treatments sharing a mandatory pair of conditions create many possible trials but few disjoint ones. The Berge-triangle condition adds a consistency constraint: three pairwise relationships cannot be witnessed by three separate interactions.

The construction also gives an exact local diagnostic through its intersection formula. That formula can drive recognition algorithms, small-instance searches, and stability questions. If a nearly optimal hypergraph has almost $s(n-2s)$ edges, must most of its edges cluster around nearly disjoint spine pairs? If equality holds under the universal upper bound, is the pair-star architecture forced? These are natural structural questions because the construction’s efficiency comes from such a distinctive overlap pattern.

The lesson extends to the way extremal examples are discovered. Rather than adding edges one by one and hoping forbidden patterns do not appear, one first chooses an incidence rule whose local geometry makes the obstruction impossible. Exact counting then becomes a consequence of the rule. Here, the rule partitions the difficult interactions into two transparent coordinates: a spine index and an outside-vertex index. One coordinate limits matchings; the other allows expansion. Their product counts the edges, while their asymmetry blocks triangles. This separation of roles is what makes the design both efficient and mathematically legible.

At heart, the story is one of controlled reuse. The same pair of vertices can support many hyperedges; this abundance does not create a large matching because the edges collide, and it does not create a Berge triangle because their representatives cannot separate into the required cycle. From a small collection of rigid spines emerges a large, sparse-in-independence, cycle-free hypergraph—an elegant example of how extremal mathematics turns constraints into architecture.
