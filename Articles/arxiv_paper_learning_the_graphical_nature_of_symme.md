# The Geometry Hidden Inside Symmetry

## Why a network built from a group looks the same everywhere—and remembers relative position

A subway map, a social network, and a molecule can all be drawn as dots joined by lines. The dots may represent stations, people, or atoms; the lines record which pairs interact. The resulting graph invites geometric questions. How many neighbors does a typical dot have? How often do triangles close? How many squares pass through a pair of dots? Do two local neighborhoods have the same internal shape?

Finite groups enter this picture from a different direction. A group is a collection of reversible operations that can be composed. Rotating a polygon, permuting a set of objects, or adding hours on a clock all produce groups. Groups are usually introduced through equations, multiplication tables, and generators. Yet every finite group also supports a natural family of networks—its **Cayley graphs**—that turn algebra into geometry.

This bridge matters in data-rich mathematics. A large collection of Cayley graphs may contain millions of local measurements: degrees, triangle counts, square statistics, distances, and spectra. At first sight, each ordered pair of vertices seems to require its own record. Symmetry says otherwise. The central fact developed here is stronger than the familiar slogan that “every vertex looks the same.” For a pair of vertices, every common-neighborhood feature considered here is controlled by one algebraic quantity: their **group difference**.

That principle explains exact repetitions in local network data, gives a lossless compression rule, and identifies which measurements can genuinely distinguish one relative position from another.

## From operations to edges

Let $G$ be a group with identity element $e$. Choose a subset $S\subseteq G$ of allowed moves, called the **connection set**. We impose two conditions:

1. $e\notin S$, so a vertex is not connected to itself;
2. if $s\in S$, then $s^{-1}\in S$, so every allowed move can be reversed.

The corresponding undirected Cayley graph has one vertex for every $g\in G$. Two vertices $a$ and $b$ are adjacent precisely when

$$
a^{-1}b\in S.
$$

In words, an edge joins $a$ to $b$ when the operation carrying $a$ to $b$ is one of the allowed moves. The two conditions on $S$ make the graph simple and undirected. Excluding $e$ removes loops, while closure under inverses ensures that adjacency has no preferred direction.

The most accessible example is the cyclic group of clock positions. In $\mathbb Z/n\mathbb Z$, choose $S=\{1,-1\}$. Every position is joined to its immediate clockwise and counterclockwise neighbors, producing a cycle. If one also allows jumps by two positions, then $S=\{1,-1,2,-2\}$ and the cycle acquires short chords. The graph becomes richer, but its local geometry still repeats around the clock.

## Moving the whole universe

Pick any $c\in G$ and move every vertex $x$ to $cx$. This operation is called **left translation**. It preserves adjacency because

$$
(ca)^{-1}(cb)=a^{-1}c^{-1}cb=a^{-1}b.
$$

The allowed move between the translated vertices is exactly the move between the originals. Left translation is reversible—translation by $c^{-1}$ undoes it—so it is a graph symmetry.

This one-line cancellation identity drives all the results that follow.

The first is the **Neighborhood Transport Theorem**: for any vertices $a$ and $c$, the map $x\mapsto cx$ is a bijection from the neighbors of $a$ to the neighbors of $ca$. Its inverse is $x\mapsto c^{-1}x$. Consequently, when $G$ is finite, every vertex has the same degree. More precisely, every degree equals the degree of $e$, which in this simple Cayley graph is $|S|$.

Regularity is only the beginning. A vertex statistic asks what surrounds one root. Triangle and square statistics often ask what surrounds two roots at once.

## Two vertices collapse to one difference

For vertices $a,b\in G$, define their **common neighborhood** by

$$
C(a,b)=\{x\in G:x\text{ is adjacent to }a\text{ and to }b\}.
$$

Simultaneous translation sends this set to another common neighborhood:

$$
x\longmapsto cx,\qquad C(a,b)\longrightarrow C(ca,cb).
$$

The map is a bijection. But there is a particularly useful choice: set $c=a^{-1}$. Then the first root becomes the identity and the second becomes $a^{-1}b$. This yields the **Pair-Difference Theorem**:

> For every $a,b\in G$, the map $x\mapsto a^{-1}x$ is a bijection from $C(a,b)$ to $C(e,a^{-1}b)$, with inverse $y\mapsto ay$.

Thus the common neighborhood of an ordered pair does not depend independently on two positions. Up to a canonical relabeling, it depends only on the relative element $a^{-1}b$.

For finite groups, taking cardinalities gives an immediate corollary:

$$
|C(a,b)|=|C(e,a^{-1}b)|.
$$

This count has several interpretations. If $a$ and $b$ are adjacent, each common neighbor closes their edge into a triangle. If they are not adjacent, a common neighbor forms a two-step path between them. Pairs of common neighbors can serve as opposite routes around a four-cycle. All such counts inherit the pair-difference rule.

There is also a concrete set formula. The neighbors of $a$ are $aS=\{as:s\in S\}$. Hence

$$
C(a,b)=aS\cap bS.
$$

After multiplying on the left by $a^{-1}$, this intersection becomes

$$
S\cap (a^{-1}b)S.
$$

Common-neighbor counting is therefore a translated-set intersection, closely related to autocorrelation: it measures how strongly $S$ overlaps a shifted copy of itself.

## Not just how many, but how they connect

Counting common neighbors discards information. Suppose $C(a,b)$ contains six vertices. Those six might have no edges among themselves, form a path, split into triangles, or support some other internal network. Square- and higher-cycle statistics can distinguish these cases.

The stronger **Induced Common-Neighborhood Theorem** says that no such information is lost under translation. The bijection $x\mapsto cx$ from $C(a,b)$ to $C(ca,cb)$ preserves adjacency between every pair $x,y$ of common neighbors. In particular, $x$ and $y$ are adjacent if and only if $cx$ and $cy$ are adjacent. Choosing $c=a^{-1}$ shows that the entire graph induced by $C(a,b)$ is isomorphic to the graph induced by $C(e,a^{-1}b)$.

This is strictly stronger than equality of counts. It implies equality of every graph invariant determined by the induced common-neighborhood graph: its number of vertices, number of edges, degree multiset, connected-component structure, cycle counts, and—once an adjacency-matrix convention is fixed—its spectrum.

The proof is almost disarmingly simple. The map is already a bijection on common neighbors. For two of them, the same cancellation identity gives

$$
(cx)^{-1}(cy)=x^{-1}y.
$$

Therefore the move connecting them is unchanged. The richness of the consequence comes not from a long calculation, but from choosing the right symmetry.

## A worked clock example

Take $G=\mathbb Z/8\mathbb Z$ under addition and allow steps

$$
S=\{1,2,6,7\}=\{\pm1,\pm2\}.
$$

Every vertex has four neighbors. Consider the pair $(2,5)$. Its relative difference is $5-2=3$ modulo $8$. Translation by $-2$ sends the pair to $(0,3)$. It also sends every common neighbor $x$ to $x-2$.

The neighbors of $2$ are $\{0,1,3,4\}$, while those of $5$ are $\{3,4,6,7\}$. Thus

$$
C(2,5)=\{3,4\}.
$$

The neighbors of $0$ are $\{1,2,6,7\}$, while those of $3$ are $\{1,2,4,5\}$. Thus

$$
C(0,3)=\{1,2\}.
$$

Translation by $-2$ sends $3$ to $1$ and $4$ to $2$, exactly matching the two common neighborhoods. Moreover, $3$ and $4$ are adjacent because they differ by $1$, and $1$ and $2$ are adjacent for the same reason. Both the count and the internal edge survive.

The example is small enough to inspect by hand, but the theorem applies without change to noncommutative groups, where order matters and $a^{-1}b$ cannot be replaced casually by subtraction.

## Why this matters for learning from graphs

Suppose a dataset records a local feature for every ordered pair in a group of size $n$. That creates $n^2$ entries. The pair-difference principle says that translation-invariant common-neighborhood features require at most $n$ group-indexed profiles: one for each possible value of $a^{-1}b$. The map

$$
(a,b)\longmapsto a^{-1}b
$$

is therefore a lossless compression coordinate for these observables.

This has two consequences for statistical learning. First, it prevents accidental data leakage. Randomly splitting many translated copies of the same local configuration between training and test sets can exaggerate predictive performance. Grouping examples by relative element, or by larger symmetry classes when appropriate, gives a more honest benchmark.

Second, it suggests symmetry-aware features. Rather than asking a model to rediscover that $C(a,b)$ and $C(ca,cb)$ are equivalent, one can present a canonical representative $C(e,a^{-1}b)$. Computational effort then goes toward differences that are genuinely distinct.

The result also clarifies the limits of local statistics. Degree cannot distinguish vertices at all. Common-neighbor counts can distinguish relative elements only through overlaps $S\cap gS$. Induced common-neighborhood graphs retain more information, but even they may coincide for different $g$. Symmetry determines what a feature cannot see; it does not guarantee that what remains identifies the group.

## The boundary of the principle

Three cautions are essential.

First, regularity alone is far weaker than Cayley structure. A regular graph can have pairs with very different common-neighbor profiles. Equal degree does not produce a group-difference coordinate.

Second, a vertex-transitive graph does ensure that individual vertices look alike under automorphisms, and ordered pairs in the same automorphism orbit have matching local data. But a general vertex-transitive graph need not come with the canonical label $a^{-1}b$. Cayley graphs provide both symmetry and an algebraic coordinate for its orbits.

Third, inverse closure and exclusion of the identity have specific roles. Without inverse closure, the natural object is directed. If the identity belongs to $S$, loops appear. Translation still preserves the corresponding relation, but the familiar language of simple undirected graphs must be adjusted.

## A wider horizon

The common-neighbor theorem is the smallest nontrivial case of a broader idea. Take any finite pattern described solely by which vertices are equal and which are adjacent. If some vertices of that pattern are pinned to roots in a Cayley graph, simultaneous left translation carries every realization to a realization at translated roots. Fixing one root at $e$ should reduce the data to a tuple of relative group elements.

That perspective points toward formulas for square clustering as autocorrelations of the connection set, spectra of induced local graphs, and stability questions for networks that only approximately obey Cayley-like identities. It also suggests a practical principle: before treating repeated graph measurements as independent data, identify the symmetry that transports one measurement to another.

A Cayley graph is not merely homogeneous scenery laid over a group. Its local network geometry is organized by algebra. One vertex can always be moved to the identity; a pair becomes a single difference; and an entire induced common neighborhood moves intact. The graph may be large, but its local stories are written in a much smaller alphabet—the relative elements of the group.