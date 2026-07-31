# Exact Intersections and Local Decomposition in Linear Intersecting Hypergraphs

**Aristotle**  
**July 31, 2026**

## Abstract

We develop the elementary structural theory that underlies the Erdős–Faber–Lovász coloring problem in its linear-hypergraph formulation. A finite hypergraph is linear when distinct edges share at most one vertex and intersecting when every two edges meet. We prove that distinct edges in a linear intersecting hypergraph meet in exactly one vertex, so fixing an edge assigns every other edge to a unique point on it. We further prove a punctured-edge disjointness principle: two distinct edges through the same vertex become disjoint after that vertex is removed. Inclusion–exclusion then gives the exact identity $|E\cup F|+1=|E|+|F|$ for distinct edges; in an $r$-uniform system this specializes to $|E\cup F|=2r-1$. We also formulate rainbow coloring as edgewise injectivity and explain how the local decomposition supports incidence algorithms, degree counts, clique-union coloring, and future matching and probabilistic approaches. The emphasis is on a self-contained derivation of the local geometry, its algorithmic recognition, and its role in the broader chromatic problem.

## 1. Introduction

A hypergraph permits a single constraint to involve more than two objects. Formally, its vertices are objects and its edges are finite groups of vertices. In a coloring problem, one assigns labels to vertices subject to conditions within each edge. The rainbow convention requires every edge to have pairwise distinct colors. It is the natural hypergraph counterpart of proper graph coloring after each hyperedge is replaced by a clique.

The Erdős–Faber–Lovász problem asks for an optimal coloring in a rigid overlap regime. In one standard formulation, there are $k$ edges, each containing $k$ vertices, and any two distinct edges share at most one vertex. The desired conclusion is that $k$ colors suffice for a rainbow coloring. The lower bound of $k$ is immediate from any edge of size $k$; the substance lies in showing that no additional color is forced by the interaction among edges.

This paper establishes the local structural layer of that problem in the intersecting regime. The assumptions are simple:

- **linearity:** distinct edges share at most one vertex;
- **intersectingness:** every pair of edges has a common vertex;
- optionally, **uniformity:** every edge has the same size $r$.

Linearity and intersectingness together force exact pairwise overlap. Although elementary, exactness has several consequences worth separating and naming. It gives a unique contact point for every pair of distinct edges. It partitions all edges relative to a fixed edge. It implies disjointness of the residual parts of edges through a fixed vertex. Finally, it turns inclusion–exclusion into an exact two-edge union formula.

These facts are useful beyond their immediate statements. They justify local incidence representations and efficient tests for the hypotheses. They yield exact star-union counts. They clarify the equivalence between rainbow hypergraph coloring and ordinary coloring of a union of cliques. Most importantly, they identify the low-complexity interfaces across which a global coloring must be coordinated.

We do not claim here that the local results alone settle the full chromatic theorem. Rather, the purpose is to give a complete, self-contained account of the structural invariants on which more global methods—systems of distinct representatives, list coloring, partial transversals, and probabilistic completion—can be built.

## 2. Definitions and equivalent viewpoints

### 2.1 Finite hypergraphs

Let $V$ be a set. A **finite hypergraph** on $V$ is a finite collection $\mathcal H$ of finite subsets of $V$. Members of $V$ are called vertices, and members of $\mathcal H$ are called edges. Vertices outside $\bigcup_{E\in\mathcal H}E$ play no role and may be ignored.

The hypergraph $\mathcal H$ is **$r$-uniform** if

$$
|E|=r
$$

for every $E\in\mathcal H$. It is **linear** if

$$
|E\cap F|\le 1
$$

whenever $E,F\in\mathcal H$ and $E\ne F$. It is **intersecting** if

$$
E\cap F\ne\varnothing
$$

for every $E,F\in\mathcal H$. The definition includes the harmless case $E=F$; thus an intersecting hypergraph has no empty edge.

Linearity places an upper bound on pairwise overlap, while intersectingness places a lower bound. Their conjunction is the main structural assumption of this paper.

### 2.2 Rainbow colorings

For a positive integer $q$, write $[q]=\{1,\ldots,q\}$. A map

$$
c:V\longrightarrow[q]
$$

is a **proper rainbow coloring** of $\mathcal H$ if for every edge $E\in\mathcal H$ and all distinct $x,y\in E$,

$$
c(x)\ne c(y).
$$

Equivalently, the restriction $c|_E:E\to[q]$ is injective for every edge $E$. We call $\mathcal H$ **$q$-colorable** if such a map exists.

The condition immediately yields the lower bound $q\ge |E|$ for every edge $E$. If $\mathcal H$ is $r$-uniform and $q=r$, then every restricted map $c|_E:E\to[r]$ is a bijection. Thus each edge uses every color exactly once.

### 2.3 The clique-union graph

Associated with $\mathcal H$ is an ordinary graph $G(\mathcal H)$ on the active vertex set $\bigcup\mathcal H$. Two distinct vertices are adjacent exactly when they lie together in some edge of $\mathcal H$. Each hyperedge therefore induces a clique.

A map $c:V\to[q]$ is a proper rainbow coloring of $\mathcal H$ if and only if its restriction to the active vertices is a proper graph coloring of $G(\mathcal H)$. Indeed, two vertices conflict in the hypergraph precisely when they are adjacent in the clique-union graph. This equivalence translates the chromatic problem without changing its content.

### 2.4 The Erdős–Faber–Lovász framing

The central chromatic statement may be phrased as follows: if $\mathcal H$ consists of $k$ edges, each of size $k$, and is linear, then $\mathcal H$ should admit a proper rainbow coloring with $k$ colors. Equivalently, the union of $k$ cliques of order $k$, any two sharing at most one vertex, should have chromatic number at most $k$.

The results below concentrate on a linear intersecting substructure. Nonintersecting pairs can be present in the general problem, but whenever intersectingness is available, it sharpens every pairwise overlap to equality.

## 3. Edgewise injectivity

We begin with the coloring observation that motivates the rainbow terminology.

**Theorem 3.1 (Edgewise Injectivity).** Let $\mathcal H$ be a finite hypergraph and let $c:V\to[q]$ be a proper rainbow coloring. For every edge $E\in\mathcal H$, the restriction $c|_E$ is injective.

**Proof.** Take $x,y\in E$ and suppose $c(x)=c(y)$. If $x\ne y$, properness would require $c(x)\ne c(y)$, a contradiction. Hence $x=y$, which is injectivity. $\square$

The converse is immediate from the definition, so edgewise injectivity and rainbow properness are equivalent. In an $r$-uniform hypergraph colored with $r$ colors, finite injectivity implies bijectivity on each edge.

**Corollary 3.2 (Complete Palette on Every Uniform Edge).** If $\mathcal H$ is $r$-uniform and $c:V\to[r]$ is a proper rainbow coloring, then each edge contains exactly one vertex of each color.

**Proof sketch.** Theorem 3.1 makes $c|_E$ an injection between two finite sets of cardinality $r$. It is therefore a bijection. $\square$

This corollary reframes optimal coloring as consistency among local permutations of a common palette. Each edge carries a bijection to $[r]$, and shared vertices force the corresponding local assignments to agree.

## 4. Uniqueness of pairwise contact

Linearity already implies that two common vertices cannot be distinct.

**Lemma 4.1 (Uniqueness Under Linearity).** Let $\mathcal H$ be a finite linear hypergraph, and let $E,F\in\mathcal H$ be distinct. If $x,y\in E\cap F$, then $x=y$.

**Proof.** If $x\ne y$, then $\{x,y\}\subseteq E\cap F$, so $|E\cap F|\ge2$. This contradicts linearity, which gives $|E\cap F|\le1$. $\square$

Intersectingness supplies existence, and the lemma supplies uniqueness.

**Theorem 4.2 (Unique-Contact Theorem).** Let $\mathcal H$ be a finite linear intersecting hypergraph. For distinct edges $E,F\in\mathcal H$, there exists a unique vertex $x$ satisfying

$$
x\in E\cap F.
$$

**Proof.** Since $\mathcal H$ is intersecting, $E\cap F$ is nonempty, so choose $x\in E\cap F$. If $y$ is another point of $E\cap F$, Lemma 4.1 gives $y=x$. $\square$

The cardinal form is equivalent and will be convenient for counting.

**Theorem 4.3 (Exact-Intersection Theorem).** If $\mathcal H$ is finite, linear, and intersecting, then for all distinct $E,F\in\mathcal H$,

$$
|E\cap F|=1.
$$

**Proof.** Intersectingness gives $|E\cap F|\ge1$, while linearity gives $|E\cap F|\le1$. Antisymmetry yields equality. $\square$

### 4.1 Partition relative to a fixed edge

Fix $E\in\mathcal H$. For every $x\in E$, define

$$
\mathcal H_x(E)=\{F\in\mathcal H: F\ne E\text{ and }x\in F\}.
$$

**Corollary 4.4 (Contact Partition).** If $\mathcal H$ is linear and intersecting, then the families $\mathcal H_x(E)$, indexed by $x\in E$, partition $\mathcal H\setminus\{E\}$.

**Proof sketch.** For every $F\ne E$, Theorem 4.2 provides a unique point $x\in E\cap F$, so $F$ belongs to exactly one class $\mathcal H_x(E)$. $\square$

This partition converts the set of all other edges into bins attached to the vertices of $E$. It is the basic incidence decomposition relative to a reference edge.

## 5. Punctured edges and local disjointness

The uniqueness statement can be sharpened into a set-theoretic disjointness principle.

**Theorem 5.1 (Punctured-Edge Disjointness).** Let $\mathcal H$ be a finite linear hypergraph. Suppose $E,F\in\mathcal H$ are distinct and $x\in E\cap F$. Then

$$
(E\setminus\{x\})\cap(F\setminus\{x\})=\varnothing.
$$

**Proof.** Suppose instead that $y$ lies in both punctured edges. Then $y\in E\cap F$ and $y\ne x$. Thus $x$ and $y$ are two distinct members of $E\cap F$, contradicting linearity. $\square$

Notice that intersectingness is unnecessary here; the common point $x$ is supplied explicitly. The theorem describes the neighborhood of a high-degree vertex as a union of separate branches.

Let

$$
\mathcal H(x)=\{E\in\mathcal H:x\in E\}
$$

be the star at $x$, and let $d(x)=|\mathcal H(x)|$.

**Corollary 5.2 (Disjoint Star Decomposition).** In a finite linear hypergraph, the sets $E\setminus\{x\}$ for $E\in\mathcal H(x)$ are pairwise disjoint, and

$$
\bigcup_{E\in\mathcal H(x)}E
=
\{x\}\,\dot\cup\!\bigdotcup_{E\in\mathcal H(x)}(E\setminus\{x\}),
$$

where $\dot\cup$ denotes disjoint union.

**Proof sketch.** Theorem 5.1 gives pairwise disjointness for the punctured edges of any two distinct members of the star. None of the punctured edges contains $x$, and adjoining $x$ reconstructs every incident edge. $\square$

**Corollary 5.3 (Uniform Star Count).** If $\mathcal H$ is additionally $r$-uniform, then

$$
\left|\bigcup_{E\in\mathcal H(x)}E\right|=1+d(x)(r-1).
$$

**Proof.** Each punctured edge has $r-1$ vertices. Corollary 5.2 says these sets are pairwise disjoint and are also disjoint from $\{x\}$. Cardinalities therefore add. $\square$

This formula is a standard local source of degree estimates. Every additional edge through $x$ forces $r-1$ new vertices in the union of the star.

## 6. Exact two-edge cardinalities

For arbitrary finite sets $E$ and $F$, inclusion–exclusion gives

$$
|E\cup F|+|E\cap F|=|E|+|F|.
$$

The Exact-Intersection Theorem substitutes the value $1$ for the intersection term.

**Theorem 6.1 (Two-Edge Union Identity).** Let $\mathcal H$ be a finite linear intersecting hypergraph. If $E,F\in\mathcal H$ are distinct, then

$$
|E\cup F|+1=|E|+|F|.
$$

Equivalently,

$$
|E\cup F|=|E|+|F|-1.
$$

**Proof.** By Theorem 4.3, $|E\cap F|=1$. Substitution into inclusion–exclusion gives the result. $\square$

**Theorem 6.2 (Uniform Two-Edge Union Formula).** Let $\mathcal H$ be an $r$-uniform finite linear intersecting hypergraph. For any two distinct edges $E,F\in\mathcal H$,

$$
|E\cup F|=2r-1.
$$

**Proof.** Theorem 6.1 gives $|E\cup F|+1=|E|+|F|=2r$. Rearranging yields $|E\cup F|=2r-1$. $\square$

The formula supplies an immediate consistency check. For distinct $r$-element edges in the claimed regime, a union smaller than $2r-1$ reveals at least two shared vertices, while a union of size $2r$ reveals disjointness.

### 6.1 A finite example

Consider

$$
E_1=\{0,1,2\},\qquad
E_2=\{0,3,4\},\qquad
E_3=\{1,3,5\}.
$$

The hypergraph $\mathcal H=\{E_1,E_2,E_3\}$ is $3$-uniform. Its pairwise intersections are

$$
E_1\cap E_2=\{0\},\qquad
E_1\cap E_3=\{1\},\qquad
E_2\cap E_3=\{3\}.
$$

It is therefore linear and intersecting. Every pairwise union has cardinality $5=2\cdot3-1$. Moreover, $E_1$ and $E_2$ pass through $0$, and their punctured parts $\{1,2\}$ and $\{3,4\}$ are disjoint.

A valid rainbow coloring with three colors is

$$
c(0)=1,\quad c(1)=2,\quad c(2)=3,\quad
c(3)=3,\quad c(4)=2,\quad c(5)=1.
$$

Each edge receives the palette $\{1,2,3\}$ exactly once, illustrating Corollary 3.2.

## 7. Algorithms

The theorems suggest direct finite algorithms. Let $n$ be the number of edges, let $m=|\bigcup\mathcal H|$, and let $L=\sum_{E\in\mathcal H}|E|$ be the total number of incidences. Assume edges are stored as hash sets, so membership and insertions have expected constant cost.

### 7.1 Pairwise structural audit

For every unordered pair $\{E,F\}$, compute $s=|E\cap F|$. The system is linear exactly when $s\le1$ for every pair, and intersecting exactly when $s\ge1$ for every pair. Thus it is linear and intersecting exactly when every distinct pair has $s=1$.

If all edges have size $r$, the algorithm may additionally verify $|E\cup F|=2r-1$. This second test is mathematically redundant after uniformity and exact intersection have been established, but it is a useful diagnostic invariant.

With naïve set intersection, the running time is

$$
O\!\left(\sum_{i<j}\min(|E_i|,|E_j|)\right),
$$

which is $O(n^2r)$ in the $r$-uniform case. The storage beyond the input is $O(r)$ for a temporary intersection or union.

### 7.2 Contact-map construction

Fix a reference edge $E$. Initialize one bucket for each $x\in E$. For every $F\ne E$, compute $E\cap F$. If it is a singleton $\{x\}$, append $F$ to the bucket indexed by $x$. If it is empty or has more than one element, report failure of the intersecting or linear condition.

The resulting map realizes Corollary 4.4. Its running time is

$$
O\!\left(\sum_{F\ne E}\min(|E|,|F|)\right),
$$

or $O(nr)$ in an $r$-uniform system. The buckets store each nonreference edge once, so auxiliary storage is $O(n+r)$ apart from the edge data.

### 7.3 Star-disjointness audit

Build an incidence map from each vertex $x$ to the edges containing it in $O(L)$ expected time. For each star $\mathcal H(x)$, scan the vertices in every $E\setminus\{x\}$ and insert them into a temporary set. Encountering a vertex already present exhibits two edges containing both $x$ and that repeated vertex, hence a violation of linearity.

If the hypergraph is linear, each scan succeeds and certifies the disjoint-star decomposition. Summed over all centers, the worst-case amount of work can be bounded in terms of incidences and edge sizes by

$$
O\!\left(\sum_{E\in\mathcal H}|E|^2\right),
$$

because edge $E$ contributes $|E|-1$ punctured vertices at each of its $|E|$ possible centers. For $r$-uniform input this is $O(nr^2)$. When the goal is to inspect only one selected star, the cost is linear in the incidences of that star.

### 7.4 Exhaustive search for illustrative colorings

For small examples, a backtracking routine can assign one of $q$ colors to each active vertex. Whenever a color is proposed for $v$, the routine rejects it if another already colored vertex in an incident edge has that color. Choosing the next vertex by high conflict degree and trying colors in a constrained order substantially reduces search in practice.

The worst-case running time remains exponential, $O(q^m)$, because graph coloring contains difficult global instances. The purpose of this routine is demonstration and small-instance exploration, not a polynomial proof of the general chromatic result. The structural audits should precede it: they verify that the example occupies the intended regime and expose the unique-contact geometry used to interpret the result.

## 8. Applications and mathematical interpretation

### 8.1 Clique-union coloring

Replacing every edge by a clique turns the hypergraph into a graph without changing proper colorings. In a linear family, two generating cliques share at most one vertex. In an intersecting linear family, they share exactly one. Hence every pairwise interface between local clique colorings consists of one color-consistency constraint.

The global challenge is not local colorability—each clique of order $r$ plainly admits $r$ colors—but compatibility across all interfaces. The contact partition records where these compatibility conditions attach to a chosen clique.

### 8.2 Resource and frequency assignment

Suppose each edge is a set of devices that mutually interfere and therefore require distinct frequencies. Theorem 3.1 identifies valid assignments with injections on every interference group. If two groups meet at a hub and the system is linear, Theorem 5.1 ensures that their nonhub devices are separate. In an $r$-uniform star of degree $d(x)$, exactly $1+d(x)(r-1)$ devices occur, so capacity estimates can be made without overcounting.

### 8.3 Block designs

Treatments may be vertices and experimental blocks edges. Pairwise balance at the value one is exactly the statement that distinct blocks meet once. Theorem 6.2 says that two blocks of size $r$ cover $2r-1$ treatments. The contact partition relative to a block sorts all other blocks by the treatment they share with it.

### 8.4 Incidence matrices and transversals

Represent $\mathcal H$ by a $0$-$1$ incidence matrix whose rows correspond to edges and columns to vertices. The scalar product of two distinct rows is $|E\cap F|$. Thus in the linear intersecting regime, all distinct row scalar products equal $1$. A rainbow coloring partitions columns into color classes, each meeting every row in at most one position; in the optimal $r$-uniform case, every class meets every row exactly once.

This matrix viewpoint points toward systems of distinct representatives and partial transversals. A color class behaves like a transversal selecting one vertex from each edge, subject to the fact that one selected vertex may represent several incident edges. Coordinating several such classes is a natural bridge from local intersection theory to the full chromatic problem.

## 9. Discussion

The main results are elementary but exact. Their value lies in converting qualitative overlap assumptions into canonical structure.

First, the Unique-Contact Theorem replaces existential intersection by a function: relative to a fixed edge, every other edge has a unique address. Second, Punctured-Edge Disjointness replaces a cardinal inequality by a decomposition into disjoint pieces. Third, the union identities eliminate uncertainty from pairwise counts. Together they provide a compact local model:

- edge-centered view: other edges partition by their contact point;
- vertex-centered view: incident edges split into disjoint punctured branches;
- pair-centered view: two edges contain exactly one duplicated vertex.

These views are mutually reinforcing. The edge-centered partition is appropriate for organizing compatibility constraints in coloring. The vertex-centered decomposition supports degree and neighborhood estimates. The pair-centered formula supports audits and extremal counting.

There are also clear limits. Pairwise exactness does not make all residual pieces globally disjoint: edges meeting a reference edge at different points may intersect each other elsewhere. Such secondary intersections create the global dependency network. Likewise, a collection of individually compatible local colorings need not automatically extend to a single global coloring. The unresolved coordination is precisely where matching theory, list coloring, and probabilistic methods enter.

The distinction is important for faithful interpretation. The theorems in this paper establish the structural foundation and exact local arithmetic. They do not infer the full $k$-color conclusion solely from those facts. Instead, they make explicit the constraints that any complete argument or algorithm must exploit.

## 10. Future work

Several directions naturally extend this foundation.

1. Prove the full Erdős–Faber–Lovász theorem for finite linear hypergraphs with $k$ edges of size $k$ in the rainbow-edge formulation.
2. Develop partial transversals and systems of distinct representatives for the incidence matrix, and connect them to list coloring of the clique-union graph.
3. Analyze random partial colorings, concentration bounds, and a Lovász-local-lemma completion step for sparse or high-degree regimes.
4. Develop the dual formulation in which $k$ pairwise-intersecting cliques of order $k$, any two sharing at most one vertex, receive at most $k$ colors.
5. Study extremal finite-projective-plane instances and show that their natural incidence colorings attain the expected bound.

On the computational side, useful extensions include canonical encodings up to isomorphism, generators for small linear intersecting hypergraphs, exact chromatic search, and visual incidence explorers. The structural tests of Section 7 provide inexpensive filters before more costly coloring computations.

## 11. Conclusion

A finite hypergraph that is both linear and intersecting possesses a rigid pairwise geometry. Distinct edges meet in one unique vertex. Relative to any fixed edge, all others are assigned to unique contact points. Through any fixed vertex, punctured incident edges are pairwise disjoint. Inclusion–exclusion consequently yields

$$
|E\cup F|+1=|E|+|F|,
$$

and uniformity sharpens this to

$$
|E\cup F|=2r-1.
$$

Meanwhile, proper rainbow coloring is exactly injectivity on each edge, and with $r$ colors on an $r$-edge it becomes a local bijection. These statements provide a complete local vocabulary for the intersecting linear regime: unique contacts, disjoint branches, exact unions, and compatible edgewise palettes. They isolate the structure from which global coloring arguments must proceed.
