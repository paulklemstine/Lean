# Explicit Graceful Labelings of Paths and Stars, with an Edge-Partition Counting Principle

**Aristotle**  
**29 July 2026**

## Abstract

A graceful labeling of a graph with $m$ edges is an injective assignment of vertex labels from $\{0,1,\ldots,m\}$ such that the absolute differences across edges are exactly $\{1,2,\ldots,m\}$. The Graceful Tree Conjecture asserts that every finite tree admits such a labeling and remains open in full generality. This paper develops two explicit infinite families and the elementary counting principle underlying their connection to graph decompositions. First, every path with $n$ edges is gracefully labeled by the alternating sequence $0,n,1,n-1,2,n-2,\ldots$; a closed formula is given, injectivity is proved by parity analysis, and the consecutive edge differences are shown to be $n,n-1,\ldots,1$. Second, every star with $n$ leaves is gracefully labeled by assigning $0$ to the center and $1,\ldots,n$ to the leaves. Third, if the edge set of a finite host graph is partitioned into $r$ pieces of $m$ edges each, then the host has $rm$ edges. This gives the necessary divisibility condition for complete-graph decompositions into equal tree copies. The constructions yield linear-time labeling algorithms and transparent certificates, while also identifying precise next problems concerning caterpillars, olive trees, leaf extensions, and cyclic decompositions.

## 1. Introduction

Let $G=(V,E)$ be a finite simple graph. A vertex labeling turns each edge $\{u,v\}$ into a numerical difference $|f(u)-f(v)|$. A graceful labeling asks for the most economical possible arrangement: if $G$ has $m$ edges, the vertices receive distinct labels from $0$ through $m$, and the edge differences exhaust every positive integer from $1$ through $m$.

The definition creates a rigid interaction between local and global data. Locally, every adjacent pair must have a nonzero difference in the permitted interval. Globally, all $m$ target differences must occur. When $G$ is a tree with $m$ edges, it has $m+1$ vertices. Consequently, injectivity into the $m+1$ labels $0,1,\ldots,m$ forces every label to be used. A graceful tree therefore realizes two simultaneous bijections: its vertices occupy the whole label interval, and its edges occupy the whole difference interval.

The Graceful Tree Conjecture states that every finite tree is graceful. Although its formulation is elementary, the conjecture remains unresolved. It is therefore important to distinguish the universal claim from explicit families for which complete constructions are available. This paper proves gracefulness for two fundamental families: paths and stars. These families represent opposite degree profiles. A path distributes degree along a linear spine, whereas a star concentrates all edges at one center. Their successful labelings accordingly use different mechanisms: alternating extremes for paths and direct radial differences for stars.

Graceful labelings are also naturally associated with decomposition questions. A decomposition of a host graph partitions its edge set into copies of a smaller graph. Before any structural construction can succeed, its edge counts must agree. We prove the general counting identity for a finite exact edge partition and specialize it to complete graphs. This result is elementary but indispensable: it separates the arithmetic requirement from the harder tasks of proving disjointness and coverage.

The contributions are as follows.

1. A closed formula for the alternating path labeling is stated and proved to be injective and range-bounded.
2. The difference across the edge joining positions $i$ and $i+1$ is proved to be exactly $n-i$, yielding all differences from $n$ down to $1$.
3. The center-and-leaves labeling of every star is proved graceful, including the degenerate case.
4. An exact cardinality theorem is proved for finite edge partitions into equally sized pieces.
5. Linear-time construction and verification algorithms are extracted, with applications to finite experimentation and decomposition design.

No claim is made here that all trees, all caterpillars, or all olive trees are graceful. The scope is deliberately precise: paths, stars, and the counting law for exact edge partitions.

## 2. Definitions and basic consequences

### 2.1 Finite simple graphs and trees

A **finite simple graph** is a pair $G=(V,E)$ in which $V$ is a finite set and $E$ is a set of two-element subsets of $V$. Thus edges are undirected, loops are excluded, and no pair of vertices supports more than one edge. The number of edges is denoted by $|E|$.

A **path with $n$ edges**, denoted here by $P_{n+1}$, has vertex set

$$
\{0,1,\ldots,n\}
$$

and edge set

$$
\bigl\{\{i,i+1\}:0\le i<n\bigr\}.
$$

A **star with $n$ leaves**, denoted by $S_n$, consists of a center $c$, leaves $\ell_1,\ldots,\ell_n$, and precisely the edges

$$
\bigl\{\{c,\ell_j\}:1\le j\le n\bigr\}.
$$

Both graphs are trees: they are connected and contain no cycle. The case $n=0$ is allowed. Then each graph consists of one isolated vertex.

### 2.2 Graceful labelings

**Definition 2.1 (Graceful labeling).** Let $G=(V,E)$ be a finite simple graph and let $m$ be a nonnegative integer. A function

$$
f:V\longrightarrow\{0,1,\ldots,m\}
$$

is a **graceful labeling with parameter $m$** if:

1. $f$ is injective;
2. every edge difference belongs to $\{1,2,\ldots,m\}$; and
3. for every $d\in\{1,2,\ldots,m\}$, some edge $\{u,v\}\in E$ satisfies $|f(u)-f(v)|=d$.

When $m=|E|$, this is the standard notion of a graceful labeling. The graph is called **graceful** if such a labeling exists.

The second condition is partly redundant when the graph is simple and labels are injective: adjacent vertices then have distinct labels, so their differences are positive, while the range bound makes them at most $m$. It remains useful to state it explicitly because it records the exact certificate expected of a labeling.

**Lemma 2.2 (Uniqueness of realized differences).** Suppose $G$ has exactly $m$ edges and a labeling realizes every difference in $\{1,\ldots,m\}$. Then each of those differences occurs on exactly one edge.

**Proof sketch.** There are $m$ edges and $m$ required values. Surjectivity from the edge set to the difference set is therefore a bijection. If one value occurred twice, some other value would necessarily be absent. $\square$

**Lemma 2.3 (Full use of labels for trees).** If a tree with $m$ edges is gracefully labeled from $\{0,1,\ldots,m\}$, then every number in that interval labels exactly one vertex.

**Proof sketch.** A finite tree with $m$ edges has $m+1$ vertices. An injective map from an $(m+1)$-element vertex set to an $(m+1)$-element label set is bijective. $\square$

## 3. The alternating path construction

### 3.1 Definition of the labeling

Fix $n\ge 0$. For the vertex at position $i\in\{0,1,\ldots,n\}$ on $P_{n+1}$, define

$$
L_n(i)=
\begin{cases}
\dfrac{i}{2}, & \text{if $i$ is even},\\[6pt]
n-\left\lfloor\dfrac{i}{2}\right\rfloor, & \text{if $i$ is odd}.
\end{cases}
$$

Thus the labels appear in path order as

$$
0,n,1,n-1,2,n-2,\ldots.
$$

The construction interleaves an increasing low sequence with a decreasing high sequence.

**Lemma 3.1 (Range bound).** For every $i\in\{0,1,\ldots,n\}$,

$$
0\le L_n(i)\le n.
$$

**Proof sketch.** If $i$ is even, then $L_n(i)=i/2$, which is nonnegative and no larger than $i$, hence no larger than $n$. If $i$ is odd, then $\lfloor i/2\rfloor\le n$, so $L_n(i)=n-\lfloor i/2\rfloor$ is nonnegative, and it is automatically at most $n$. $\square$

**Lemma 3.2 (Injectivity).** The function $L_n$ is injective on $\{0,1,\ldots,n\}$.

**Proof sketch.** Write even positions as $2a$ and odd positions as $2b+1$. At even positions,

$$
L_n(2a)=a,
$$

so equal labels imply equal positions. At odd positions,

$$
L_n(2b+1)=n-b,
$$

and equal labels again imply equal positions. It remains to exclude a collision between an even and an odd position. Such a collision would give $a=n-b$, or $a+b=n$. But the bounds $2a\le n$ and $2b+1\le n$ imply

$$
2(a+b)+1\le 2n,
$$

whereas $a+b=n$ would imply $2n+1\le 2n$, a contradiction. Hence the low and high streams are disjoint. $\square$

The parity split is not cosmetic. It describes why the construction uses the label interval efficiently: even positions move upward from $0$, odd positions move downward from $n$, and the path terminates before the streams meet.

### 3.2 Consecutive edge differences

**Lemma 3.3 (Consecutive-difference formula).** For every integer $i$ with $0\le i<n$,

$$
\bigl|L_n(i+1)-L_n(i)\bigr|=n-i.
$$

**Proof sketch.** There are two parity cases.

If $i=2a$ is even, then $i+1=2a+1$ is odd, so

$$
L_n(i)=a,
\qquad
L_n(i+1)=n-a.
$$

Because $2a=i<n$, the latter is at least the former, and

$$
|L_n(i+1)-L_n(i)|=(n-a)-a=n-2a=n-i.
$$

If $i=2a+1$ is odd, then $i+1=2a+2$ is even, giving

$$
L_n(i)=n-a,
\qquad
L_n(i+1)=a+1.
$$

Since $i<n$, the first label exceeds the second, and

$$
|L_n(i+1)-L_n(i)|=(n-a)-(a+1)=n-(2a+1)=n-i.
$$

Thus the same formula holds in both cases. $\square$

**Theorem 3.4 (Graceful Path Theorem).** For every nonnegative integer $n$, the path $P_{n+1}$ with $n$ edges is graceful. In particular, the labeling $L_n$ defined above is injective, takes values in $\{0,1,\ldots,n\}$, and its edge differences are exactly $\{1,2,\ldots,n\}$.

**Proof sketch.** The range and injectivity requirements follow from Lemmas 3.1 and 3.2. The edges of $P_{n+1}$ are precisely $\{i,i+1\}$ for $0\le i<n$. By Lemma 3.3, their differences are $n-i$. As $i$ runs from $0$ through $n-1$, $n-i$ runs through $n,n-1,\ldots,1$, each once. Hence the labeling is graceful. $\square$

**Example 3.5.** For $n=8$, the vertex labels in path order are

$$
0,8,1,7,2,6,3,5,4,
$$

and the edge differences are

$$
8,7,6,5,4,3,2,1.
$$

The theorem includes $n=0$: the one-vertex path receives label $0$, while the required set of edge differences is empty.

## 4. The center-and-leaves star construction

Fix $n\ge 0$. Define a labeling $R_n$ of the star $S_n$ by

$$
R_n(c)=0,
\qquad
R_n(\ell_j)=j\quad\text{for }1\le j\le n.
$$

**Lemma 4.1 (Range and injectivity for stars).** The labels $R_n(c),R_n(\ell_1),\ldots,R_n(\ell_n)$ are distinct and all lie in $\{0,1,\ldots,n\}$.

**Proof sketch.** The center has label $0$, while the leaves have the pairwise distinct positive labels $1$ through $n$. $\square$

**Lemma 4.2 (Radial difference formula).** For each $j\in\{1,\ldots,n\}$, the edge $\{c,\ell_j\}$ has difference $j$.

**Proof sketch.** Directly,

$$
|R_n(\ell_j)-R_n(c)|=|j-0|=j.
$$

$\square$

**Theorem 4.3 (Graceful Star Theorem).** Every star $S_n$ is graceful. The center-and-leaves labeling realizes the edge differences $1,2,\ldots,n$ exactly once.

**Proof sketch.** Lemma 4.1 gives the valid injective vertex labeling. Every edge is incident to the center, and Lemma 4.2 assigns difference $j$ to the edge ending at $\ell_j$. Thus all required differences occur. There are no additional edges, so none can repeat. $\square$

The path and star constructions expose complementary design principles. On a path, adjacency is controlled by alternating low and high labels. On a star, all differences are controlled by anchoring the center at the extreme label $0$. Any extension to more elaborate tree families must coordinate these mechanisms across branching structure.

## 5. Exact edge partitions and counting

### 5.1 Definition

Let $K=(W,F)$ be a finite simple host graph, let $I$ be a finite index set, and for each $a\in I$ let $F_a$ be a finite set of edges of $K$.

**Definition 5.1 (Exact edge partition).** The family $(F_a)_{a\in I}$ is an **exact edge partition** of $K$ if:

1. $F_a\subseteq F$ for every $a\in I$; and
2. every edge $e\in F$ belongs to exactly one set $F_a$.

The second condition contains both coverage and uniqueness. It is equivalent to saying that

$$
F=\bigcup_{a\in I}F_a
$$

and that the sets $F_a$ are pairwise disjoint.

**Theorem 5.2 (Edge-Partition Counting Theorem).** Suppose $(F_a)_{a\in I}$ is an exact edge partition of a finite graph $K$. If every piece has exactly $m$ edges, then

$$
|F|=|I|m.
$$

**Proof sketch.** Exact coverage gives $F=\bigcup_{a\in I}F_a$. Exact uniqueness implies that the pieces are pairwise disjoint: an edge in both $F_a$ and $F_b$ would have two indices unless $a=b$. Cardinality is additive over a finite disjoint union, hence

$$
|F|=\sum_{a\in I}|F_a|.
$$

Since every summand is $m$ and there are $|I|$ indices,

$$
|F|=\sum_{a\in I}m=|I|m.
$$

$\square$

**Corollary 5.3 (Divisibility condition).** If a finite graph is decomposed into copies of a graph having $m$ edges, then $m$ divides the number of host edges.

**Proof sketch.** Let $r$ be the number of copies. Theorem 5.2 gives $|F|=rm$. $\square$

**Corollary 5.4 (Complete-graph condition).** If the complete graph on $q$ vertices is decomposed into copies of an $m$-edge graph, then

$$
m\mid \binom{q}{2}=\frac{q(q-1)}{2}.
$$

**Proof sketch.** A complete graph has one edge for each unordered pair of distinct vertices, hence $\binom{q}{2}$ edges. Apply Corollary 5.3. $\square$

These are necessary conditions, not sufficient ones. Correct cardinality does not prevent two pieces from overlapping, nor does it guarantee that all host edges are covered. A decomposition proof must separately establish containment, pairwise disjointness, and coverage. Once those structural facts are known, the theorem supplies the final count.

### 5.2 Relation to graceful labelings

A graceful labeling of an $m$-edge tree distinguishes its edges by the lengths $1,\ldots,m$. This difference spectrum suggests translation constructions in cyclic groups. One places the labels in a cyclic set, translates all labels by a common offset, and studies the resulting copies. If the translated edge sets are shown to be pairwise disjoint and to cover the complete host, they form an exact partition. Theorem 5.2 then confirms the associated edge count.

The counting theorem alone does not prove the cyclic construction. Its role is precise: it supplies the arithmetic identity that any such partition must satisfy and reduces the remaining burden to structural edge arguments.

## 6. Algorithms

### 6.1 Alternating path labeling algorithm

Given $n$, evaluate $L_n(i)$ for every $i=0,\ldots,n$ using the parity formula. This takes $O(n)$ time and stores $O(n)$ labels. If labels are streamed one at a time, the auxiliary space beyond the output is $O(1)$.

A certificate consists of the label list and the consecutive differences. Verification checks:

1. the list has length $n+1$;
2. every label lies between $0$ and $n$;
3. labels are distinct; and
4. sorted edge differences equal $[1,2,\ldots,n]$.

Using a Boolean presence array or hash set, this verification takes expected $O(n)$ time and $O(n)$ space. Sorting instead gives $O(n\log n)$ time.

### 6.2 Radial star labeling algorithm

Given $n$, output center label $0$ and leaf labels $1,\ldots,n$. Construction and explicit output require $O(n)$ time and $O(n)$ output space. The difference on the $j$th radial edge is immediately $j$. Formula-level random access to any label or edge difference takes $O(1)$ time.

### 6.3 Exact partition audit

For a finite host edge set and a list of proposed pieces, maintain a frequency map from host edges to occurrence counts. Reject any piece containing a non-host edge. Increment the frequency of each listed edge, then accept exactly when every host edge has frequency one and every piece has the prescribed cardinality. If $M$ edge occurrences are supplied, the expected running time is $O(M+|F|)$ with hashing, and space is $O(|F|)$. This audit numerically demonstrates the hypotheses of Theorem 5.2; the identity $|F|=|I|m$ then follows.

## 7. Applications and computational use

Explicit graceful constructions are valuable as benchmarks. A search procedure for graceful labelings should recover the path and star solutions immediately. Since their correct difference spectra are known in closed form, implementation errors are easy to identify. Paths test parity and adjacency order; stars test degree concentration and extreme labels.

In network design, the edge difference can represent a separation class, channel offset, time lag, or resource distance. A graceful assignment guarantees that every class from $1$ through $m$ appears once. The interpretation depends on the application, but the combinatorial guarantee is invariant.

The edge-partition theorem supports decomposition experiments. Before searching for a partition of a complete graph into fixed-size pieces, one checks divisibility. This inexpensive filter rules out impossible parameter choices. For candidates that pass, a frequency audit checks exact coverage. Graceful labelings then provide structured templates rather than arbitrary pieces, potentially reducing search complexity through symmetry.

Computational experiments must be interpreted carefully. Checking finitely many trees cannot prove the universal Graceful Tree Conjecture. It can, however, refute a proposed construction, discover patterns, and validate algorithms on bounded instances. A failed labeling formula produces an explicit witness: two vertices share a label, a label leaves the interval, or an edge difference repeats or disappears. A failed decomposition similarly exhibits either overlap or a missing host edge.

## 8. Discussion

The alternating path theorem and radial star theorem prove gracefulness at two extremes of tree geometry. The path has maximum degree at most two and a canonical linear order. The star has a single vertex of degree $n$ and no nontrivial linear spine. The constructions succeed because each geometry offers a direct coordinate system.

For paths, position and parity determine whether the next label is taken from the low or high end. The consecutive-difference lemma is the central invariant: at step $i$, the remaining target is $n-i$. For stars, the center is a universal reference point, so leaf labels are themselves the differences. These invariants suggest how more complex constructions might be organized. A caterpillar could combine alternating labels along its non-leaf spine with carefully allocated blocks for leaves. An olive tree could coordinate several pathwise sequences sharing a common extreme label at the root.

The counting result belongs to a different but complementary level. Gracefulness concerns the internal organization of one graph copy; partition counting concerns the external organization of many copies in a host. The bridge between them is the edge-difference spectrum. Distinct differences can encode edge orbits under translation, but only a full disjointness-and-coverage proof converts that encoding into a decomposition.

The limitations are clear. The established results do not prove that every caterpillar is graceful, do not give a general olive-tree construction, and do not settle the Graceful Tree Conjecture. Nor does divisibility imply decomposability. These boundaries are not defects; they identify the exact mathematical obligations for future work.

## 9. Future work

A first target is the full caterpillar theorem: define a caterpillar as a tree whose non-leaf vertices induce a path, then construct all differences from $1$ to the number of edges. A second is an explicit formula for olive trees obtained by identifying one endpoint of paths of lengths $1,2,\ldots,k$. In both cases, bounded exhaustive search can test candidate formulas before a general proof is attempted.

A local structural problem concerns leaf extension. Starting from a graceful $m$-edge tree, attach a leaf and seek a graceful labeling with parameter $m+1$. The new edge must realize the new largest difference, suggesting attachment near labels $0$ or $m$, but a precise necessary-and-sufficient criterion remains to be developed.

A global direction is cyclic complete-graph decomposition. Given a graceful tree with $m$ edges, place its labels in a cyclic group of order $2m+1$ and translate the labeled copy. The decisive tasks are to prove that translated undirected edge sets are disjoint and cover the complete graph. The Edge-Partition Counting Theorem then gives the required cardinality identity.

Finally, bounded-spine caterpillars invite parameterized algorithms. For each fixed number of spine vertices, one may seek a recursive labeling procedure depending on leaf multiplicities. Such an algorithm would be constructive, experimentally falsifiable on bounded inputs, and potentially extensible as the spine bound increases.

## 10. Conclusion

Every finite path and every finite star admits an explicit graceful labeling. For the $n$-edge path, the alternating formula

$$
0,n,1,n-1,2,n-2,\ldots
$$

produces consecutive differences $n,n-1,\ldots,1$. For the $n$-edge star, assigning $0$ to the center and $1,\ldots,n$ to the leaves produces radial differences $1,\ldots,n$. Both constructions are linear-time and supply immediate certificates.

If a finite host graph is exactly partitioned into $r$ pieces of $m$ edges, then it has $rm$ edges. This counting principle provides the necessary divisibility condition for decompositions into equal graph copies and clarifies the arithmetic role of graceful difference spectra.

Together, these results isolate three durable ideas: alternate between extremes along a linear structure, anchor branching at an extreme label, and count disjoint pieces only after exact coverage is established. They solve two basic infinite families and define a rigorous platform for broader graceful-tree and graph-decomposition constructions.
