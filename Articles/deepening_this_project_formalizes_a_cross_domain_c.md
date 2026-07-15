# When Every Pair Connects: Counting Simplices in Vietoris–Rips Complexes

## From proximity to combinatorial explosion

Imagine a collection of sensors scattered across a landscape. At a chosen communication radius, join two sensors when each can reach the other. Three mutually connected sensors form a triangle; four form the boundary and interior of a tetrahedron; larger mutually connected groups form higher-dimensional simplices. As the radius grows, these pieces assemble into a Vietoris–Rips complex, one of the central constructions of topological data analysis.

The geometry changes continuously, but the complex changes in sudden combinatorial jumps. An edge appears exactly when a pair crosses the current distance threshold. That edge can complete triangles, tetrahedra, and many larger simplices all at once. The total number of simplices therefore acts as a coarse but revealing gauge of the filtration.

There is a universal ceiling. A set of $n$ points has exactly $2^n$ subsets, including the empty set and all singletons. Since every simplex is a subset of the vertex set, no simplicial complex on those vertices can contain more than $2^n$ simplices. The central result here identifies the equality case and proves that every genuine edge birth causes strict growth:

> **Extremal and growth principle.** A clique complex on $n$ vertices contains all $2^n$ possible simplices if and only if its graph is complete. Moreover, whenever edges are added and at least one new edge truly appears, the number of cliques increases strictly.

Transferred to Vietoris–Rips complexes, this says that maximal size is not merely a numerical coincidence. It is a rigid geometric certificate: every pair of points lies within the chosen scale. Before that terminal stage, every newly admitted pair forces the simplex count upward.

## The graph hidden inside the geometry

Let $V$ be a finite set with $|V|=n$, and let $G$ be a simple undirected graph on $V$. A subset $S\subseteq V$ is a **clique** when every two distinct vertices in $S$ are adjacent. The empty set and every singleton count as cliques. The **clique complex** $\mathrm{Cl}(G)$ is the family of all cliques of $G$.

Because $\mathrm{Cl}(G)$ is contained in the power set $\mathcal P(V)$,

$$
|\mathrm{Cl}(G)|\leq |\mathcal P(V)|=2^n.
$$

The complete graph $K_V$ reaches this bound, since every subset is a clique. The more interesting direction is rigidity: if the count reaches $2^n$, then no subset can be absent. In particular, every two-element subset $\{u,v\}$ must be a clique, so every distinct pair is an edge. Thus $G=K_V$.

This short argument carries a useful lesson. A global count of objects can recover a local relation. Knowing only that every possible subset has survived forces every possible pair to be connected.

The strict-growth statement is almost as direct. Suppose $G$ is a proper subgraph of $H$ on the same vertices. Every clique of $G$ remains a clique of $H$, because adding edges cannot destroy pairwise adjacency. Since the inclusion is proper, some edge $\{u,v\}$ belongs to $H$ but not to $G$. The two-element set $\{u,v\}$ is therefore a clique of $H$ and not of $G$. Hence

$$
\mathrm{Cl}(G)\subsetneq \mathrm{Cl}(H),
$$

and consequently

$$
|\mathrm{Cl}(G)|<|\mathrm{Cl}(H)|.
$$

This proof does not need to count the larger simplices created by the edge. The newborn edge itself already witnesses strict growth. Any completed triangles and higher-dimensional faces only enlarge the jump.

## Turning distances into edges

The same mechanism applies beyond ordinary metrics. Let $D:V\times V\to\mathbb R$ be a symmetric dissimilarity, so $D(x,y)=D(y,x)$. Fix a scale $r$. Assume the diagonal is controlled by $D(x,x)\leq r$ for every $x\in V$; ordinary metrics satisfy this whenever $r\geq 0$ because $D(x,x)=0$.

The Vietoris–Rips complex at scale $r$ is

$$
\mathrm{VR}(D,r)=\{S\subseteq V: D(x,y)\leq r\text{ for all }x,y\in S\}.
$$

Now form the proximity graph $G_r$: two distinct vertices $x$ and $y$ are adjacent precisely when $D(x,y)\leq r$. Symmetry makes this an undirected graph. The diagonal condition handles repeated pairs. A subset belongs to $\mathrm{VR}(D,r)$ exactly when every distinct pair in it is an edge of $G_r$. Therefore

$$
\mathrm{VR}(D,r)=\mathrm{Cl}(G_r).
$$

This identity is the bridge between geometry and extremal combinatorics. It immediately yields the metric equality theorem:

> **Maximal Vietoris–Rips theorem.** For a finite symmetric dissimilarity space with $n$ points and diagonal values at most $r$,
> $$
> |\mathrm{VR}(D,r)|=2^n
> $$
> if and only if $D(x,y)\leq r$ for every pair $x,y$.

In an ordinary finite metric space, the least scale at which the complex reaches $2^n$ is exactly the diameter

$$
\operatorname{diam}(V)=\max_{x,y\in V}D(x,y).
$$

Thus a single integer—the total simplex count—detects whether the filtration has passed its final pairwise-distance threshold.

## Every edge birth leaves a footprint

Consider two scales $r\leq s$. Every edge present at scale $r$ remains present at scale $s$, so $G_r\subseteq G_s$. Suppose distinct points $i$ and $j$ satisfy

$$
r<D(i,j)\leq s.
$$

Their edge is absent at scale $r$ and present at scale $s$. Therefore $G_r$ is a proper subgraph of $G_s$, and strict clique growth gives

$$
|\mathrm{VR}(D,r)|<|\mathrm{VR}(D,s)|.
$$

This is stronger than detecting only the final complete graph. The simplex-count filtration reacts to every edge birth. If several edges share the same distance, they may arrive together, producing a larger jump; nevertheless, every interval containing a newly attained pairwise distance has a strictly positive increase.

For a simple example, place four points at the corners of a unit square. Below scale $1$, only the empty set and four vertices occur, for a total of $5$. At scale $1$, the four side edges appear. The count becomes $9$: the empty set, four vertices, and four edges. At scale $\sqrt 2$, both diagonals appear, the graph becomes complete, and all $2^4=16$ subsets become simplices. The final jump includes two new edges, four triangles, and the four-vertex simplex.

The count is coarse—it does not reveal which edge appeared—but it is never blind to an edge birth.

## Why the equality case matters

Upper bounds are common in combinatorics; equality cases are where structure emerges. The inequality $|\mathrm{Cl}(G)|\leq 2^n$ follows immediately from containment in a power set. Yet equality converts a maximum count into complete pairwise connectivity. This rigidity has several practical interpretations.

In network science, it says that a network whose clique complex contains every possible group is necessarily fully connected; no missing link can hide behind a rich collection of larger communities. In sensor systems, maximal Rips size certifies universal pairwise communication at the chosen range. In clustering, it marks the scale at which the entire data set has become one simplex, beyond merely becoming graph-connected. In topological data analysis, it identifies the terminal combinatorial threshold without inspecting each edge separately.

The theorem also warns about exponential size. Once the proximity graph is complete, the complex contains $2^n$ simplices. Explicitly listing them becomes impossible surprisingly quickly: for $n=50$, the count exceeds $10^{15}$. Algorithms therefore often work with truncated dimensions, implicit representations, or sparsified approximations. The equality theorem supplies a precise benchmark against which such representations can be compared.

## An effective counting procedure

For modest $n$, the mathematics translates directly into an algorithm. First build the threshold graph by checking every unordered pair, requiring $O(n^2)$ distance comparisons. Then enumerate all $2^n$ subsets and test whether each is a clique. A straightforward test examines at most $O(n^2)$ pairs per subset, for total time $O(n^2 2^n)$ and modest working memory if subsets are streamed.

A more efficient incremental method processes vertices one at a time. Every clique either excludes the new vertex or consists of that vertex joined to a clique among its earlier neighbors. This recursion can avoid many failed subsets in sparse graphs. Regardless of implementation, the extremal test itself has a shortcut: the count is $2^n$ exactly when all $\binom n2$ edges are present. One need not enumerate the power set to recognize the maximum.

Across an entire filtration, sort the distinct pairwise distances. Insert all edges at each distance, update the clique count, and record the jump. The strict-growth theorem guarantees that each nonempty batch of edge insertions produces a positive jump. This yields an exact event-driven description: between attained distances the complex is constant, and at every attained off-diagonal distance it grows.

## A meeting point of three subjects

The construction links three mathematical viewpoints.

**Metric geometry** supplies pairwise dissimilarities and threshold scales. **Extremal combinatorics** supplies the power-set bound, its rigid equality case, and strict growth under edge insertion. **Topological data analysis** interprets the resulting clique complexes as a filtration whose simplices encode multiscale proximity.

The bridge is elementary enough to be transparent yet strong enough to be useful. Geometry becomes a graph; graph cliques become simplices; a global simplex count detects local edge events and the terminal diameter threshold.

Several refinements now suggest themselves. If a graph is missing $m$ edges, how far below $2^n$ must its clique count lie? Can one express the jump at a distance exactly through the cliques completed by the newborn edges? What happens when counts are separated by dimension, so that edges, triangles, and tetrahedra are tracked independently? How stable is near-maximality under approximate filtrations? And can finite-window arguments extend these ideas to locally finite infinite spaces?

The basic message is already complete: in a finite Vietoris–Rips filtration, no edge is born silently. Every new pairwise connection increases the simplex count, and reaching the absolute maximum $2^n$ is equivalent to universal proximity. A seemingly blunt statistic therefore carries a sharp structural certificate.