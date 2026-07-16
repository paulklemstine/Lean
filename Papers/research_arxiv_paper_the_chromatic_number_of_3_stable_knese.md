# Chromatic Bounds for Cyclically Stable Kneser Graphs: Canonical Colorings, Intersecting Families, and the 3-Stable Case

## Abstract

For positive integers $n$, $k$, and $s$, a cyclically $s$-stable $k$-subset of $[n]=\{1,\ldots,n\}$ is a set in which every two elements have cyclic distance at least $s$. The associated stable Kneser graph has these sets as vertices and joins two vertices exactly when the corresponding sets are disjoint. The predicted chromatic number, in the nonempty range $n\ge sk$, is $n-sk+s$. This paper develops the mathematical framework behind that prediction. A canonical least-element coloring proves the upper bound $n-sk+s$ for every admissible parameter triple. The lower-bound problem is translated into the structure of intersecting families, with stable analogues of the Hilton–Milner principle controlling color classes without a common point. This yields equality for $s=3$ when $n$ is sufficiently large relative to $k$, and equality for every $n\ge9$ in the exact case $k=s=3$. We also describe the complementary box-complex approach, give explicit generation and coloring algorithms, and formulate rigidity, stability, and topological directions suggested by the common cyclic-gap structure.

## 1. Introduction

Kneser graphs encode disjointness among uniform set systems. Given a family $\mathcal F$ of subsets, its Kneser graph $\operatorname{KG}(\mathcal F)$ has vertex set $\mathcal F$, with two vertices adjacent precisely when they are disjoint. A proper coloring of this graph is therefore a partition of $\mathcal F$ into intersecting subfamilies.

The stable variant imposes geometric spacing on a cycle. It restricts the vertices to subsets whose elements remain far apart in cyclic order, but keeps disjointness as adjacency. This interaction between local separation and global intersection produces a particularly crisp chromatic prediction.

For $s=2$, the predicted value specializes to $n-2k+2$, the chromatic number of the classical stable Kneser graph. For general $s$, the proposed equality is

$$
\chi\left(\operatorname{KG}(\mathcal S_s(n,k))\right)=n-sk+s,
$$

where $\mathcal S_s(n,k)$ denotes the family of cyclically $s$-stable $k$-subsets of $[n]$. The equality is meaningful for $n\ge sk$, which is exactly the basic packing threshold.

The upper bound is elementary and uniform: color each stable set by its least element. The spacing requirement ensures that only $n-sk+s$ least elements can occur, and two sets with the same least element intersect. The lower bound is the substantive issue. Every color class is intersecting, so a hypothetical coloring with too few colors would cover all stable sets by too few intersecting families. Stable Hilton–Milner theorems constrain those families, especially when they do not share a common point.

The principal conclusions are the following.

1. For all $s\ge2$, $k\ge1$, and $n\ge sk$, the canonical coloring uses $n-sk+s$ colors.
2. For $s=3$ and each fixed $k$, equality holds once $n$ is sufficiently large relative to $k$.
3. For $k=s=3$, equality holds for every admissible $n\ge9$; explicitly, the chromatic number is $n-6$.
4. The same cyclic-gap data underlying the canonical coloring supports a topological lower-bound program through equivariant box-complex invariants.

The aim here is to present these results and their proof architecture in a self-contained form, while distinguishing the universal elementary argument from the deeper lower-bound mechanisms.

## 2. Definitions and elementary structure

### 2.1 Cyclic distance and stable subsets

Let $[n]=\{1,2,\ldots,n\}$, viewed in cyclic order. For $i,j\in[n]$, define their cyclic distance by

$$
d_n(i,j)=\min\{|i-j|,\,n-|i-j|\}.
$$

**Definition 2.1 (Cyclic stability).** A subset $A\subseteq[n]$ is cyclically $s$-stable if

$$
d_n(i,j)\ge s
$$

for all distinct $i,j\in A$. Let $\mathcal S_s(n,k)$ be the family of all cyclically $s$-stable subsets of $[n]$ having cardinality $k$.

The word “cyclically” is essential. Besides the ordinary gaps between successive elements in increasing order, the wrap-around gap from the largest element back to the smallest must also be at least $s$.

If $A=\{a_1<\cdots<a_k\}$, define its cyclic gaps by

$$
g_r=a_{r+1}-a_r\quad(1\le r<k),\qquad g_k=n+a_1-a_k.
$$

Then $A$ is cyclically $s$-stable if and only if $g_r\ge s$ for every $r$, and always

$$
g_1+\cdots+g_k=n.
$$

This immediately gives the packing condition.

**Lemma 2.2 (Packing threshold).** If $\mathcal S_s(n,k)$ is nonempty, then $n\ge sk$.

**Proof sketch.** The $k$ cyclic gaps of a stable set are each at least $s$ and sum to $n$, so $n\ge sk$. Conversely, when $n\ge sk$, the set $\{1,1+s,\ldots,1+(k-1)s\}$ is cyclically $s$-stable because its final wrap-around gap is $n-s(k-1)\ge s$. Thus the threshold is exact. $\square$

### 2.2 The stable Kneser graph

**Definition 2.3 (Stable Kneser graph).** The graph $G_s(n,k)$ has vertex set $\mathcal S_s(n,k)$. Two vertices $A$ and $B$ are adjacent if and only if $A\cap B=\varnothing$.

A proper coloring is a function $c:\mathcal S_s(n,k)\to C$ such that $c(A)\ne c(B)$ whenever $A\cap B=\varnothing$. Its least possible number of colors is the chromatic number $\chi(G_s(n,k))$.

**Definition 2.4 (Intersecting family and star).** A family $\mathcal A\subseteq\mathcal S_s(n,k)$ is intersecting if every two members meet. It is a star centered at $x\in[n]$ if every member contains $x$. A family is non-star if its total intersection is empty.

A proper coloring partitions $\mathcal S_s(n,k)$ into intersecting families: every color fiber is intersecting, because two disjoint members of one fiber would be adjacent with equal colors. This elementary observation converts chromatic lower bounds into covering problems for intersecting families.

## 3. The canonical upper bound

The proposed chromatic number has a direct arithmetic explanation.

**Theorem 3.1 (Least-element coloring).** Let $s\ge2$, $k\ge1$, and $n\ge sk$. Define

$$
q=n-sk+s=n-s(k-1).
$$

The assignment

$$
c(A)=\min A
$$

is a proper coloring of $G_s(n,k)$ using colors from $[q]$. Consequently,

$$
\chi(G_s(n,k))\le n-sk+s.
$$

**Proof.** Write $A=\{a_1<a_2<\cdots<a_k\}$. The ordinary gaps satisfy $a_{r+1}-a_r\ge s$, hence

$$
a_k\ge a_1+s(k-1).
$$

As $a_k\le n$, it follows that

$$
a_1\le n-s(k-1)=q.
$$

Thus $c(A)\in[q]$. If $c(A)=c(B)=x$, then $x\in A\cap B$, so $A$ and $B$ are not adjacent. Therefore $c$ is proper. $\square$

The proof uses only the linear order to bound the least element; cyclic stability supplies at least as much separation as required. The color fibers are explicitly star-like:

$$
c^{-1}(x)=\{A\in\mathcal S_s(n,k):\min A=x\},
$$

and every member contains $x$.

### 3.1 Sharpness as a covering statement

The equality conjecture is equivalent to the assertion that $\mathcal S_s(n,k)$ cannot be covered by fewer than $q$ intersecting subfamilies. Indeed, the fibers of any proper coloring give such a cover, and any partition into intersecting families gives a proper coloring.

This reformulation reveals why a mere bound on the maximum size of an intersecting family may be inadequate. If $M$ is that maximum, cardinality gives only

$$
\chi(G_s(n,k))\ge \left\lceil\frac{|\mathcal S_s(n,k)|}{M}\right\rceil.
$$

Overlaps in hypothetical covers and the variety of near-extremal families can make this estimate too weak. Structural information is needed: large fibers should have identifiable centers, while uncentered fibers should suffer a quantitative deficit.

## 4. Stable Hilton–Milner structure

The classical intersection paradigm separates stars from non-stars. In the stable cyclic setting, the spacing condition changes both their sizes and the permitted exceptional configurations, but the conceptual dichotomy survives.

### 4.1 Star and non-star fibers

A star is automatically intersecting. It is natural for a coloring because choosing a center gives a common witness to non-adjacency. The canonical coloring consists of truncated stars indexed by possible least elements.

A non-star intersecting family $\mathcal A$ has

$$
\bigcap_{A\in\mathcal A}A=\varnothing,
$$

although $A\cap B\ne\varnothing$ for each pair $A,B\in\mathcal A$. Such a family must distribute its intersections among multiple labels. Stability limits this distribution: labels near a chosen point are unavailable, and cyclic wrap-around couples the first and last positions.

**Stable Hilton–Milner principle.** For fixed $s$ and $k$, and for $n$ sufficiently large relative to these parameters, a non-star intersecting family in $\mathcal S_s(n,k)$ is strictly smaller and more rigid than a largest star. Its members are forced into finitely controlled exceptional intersection patterns.

The exact numerical form depends on the stable regime under analysis. For chromatic applications, the decisive content is the gap between centered and uncentered families and the classification of families near the extremal size.

### 4.2 How the principle yields chromatic lower bounds

Assume for contradiction that $G_3(n,k)$ is colored with fewer than

$$
q=n-3k+3
$$

colors. Let $\mathcal A_1,\ldots,\mathcal A_m$ be the color fibers, with $m<q$. Each is intersecting.

The proof architecture proceeds in four stages.

1. **Classify large fibers.** Stable Hilton–Milner bounds imply that a sufficiently large fiber has a common center, unless it belongs to a controlled exceptional class.
2. **Record centers.** Star-like fibers can be charged to their common labels. Fewer than $q$ fibers provide too few independent centers to cover the stable sets generated across the relevant initial-segment filtration.
3. **Bound exceptions.** Non-star fibers have a deficit. When $n$ is sufficiently large relative to $k$, the union of all exceptional fibers cannot compensate for the stable sets missed by the centered fibers.
4. **Construct an uncovered set.** The cyclic spacing room permits selection of a $3$-stable $k$-set avoiding the assigned centers and exceptional patterns, contradicting that the fibers cover the whole vertex set.

This gives the asymptotic $3$-stable theorem.

**Theorem 4.1 (Chromatic number for large 3-stable graphs).** For every fixed integer $k\ge1$, there exists a threshold $N(k)$ such that, for every $n\ge N(k)$,

$$
\chi(G_3(n,k))=n-3k+3.
$$

**Proof sketch.** Theorem 3.1 supplies the upper bound. For the lower bound, suppose fewer than $n-3k+3$ colors are used. Regard each color fiber as an intersecting family. Apply the stable Hilton–Milner dichotomy: large fibers are centered, while non-star fibers obey a strict size and structure restriction. For $n\ge N(k)$, centered fibers indexed by fewer than $n-3k+3$ labels leave enough cyclic room to build stable sets avoiding all centers, and the aggregate exceptional capacity of the non-star fibers cannot cover these remaining sets. Hence some stable set is uncolored, a contradiction. $\square$

The theorem’s threshold reflects the range in which the extremal estimates dominate lower-order exceptional behavior. It does not assert a specific universal threshold in this presentation.

## 5. Exact analysis for cyclically 3-stable triples

The case $k=s=3$ admits a complete statement with no asymptotic qualification.

**Theorem 5.1 (Exact triple theorem).** For every integer $n\ge9$,

$$
\chi(G_3(n,3))=n-6.
$$

**Upper bound.** Theorem 3.1 gives $n-3\cdot3+3=n-6$ colors. Explicitly, a stable triple $\{a<b<c\}$ receives color $a$. Since $b\ge a+3$ and $c\ge b+3$, one has $a\le n-6$.

**Lower-bound proof sketch.** Encode a stable triple by its three cyclic gaps

$$
(x,y,z)=(b-a,\,c-b,\,n+a-c),
$$

where $x,y,z\ge3$ and $x+y+z=n$. Every color fiber is an intersecting family of triples. If it has a common point, it is controlled by a star center. If it has no common point, the stable Hilton–Milner analysis restricts the possible triples through a finite pattern of pairwise intersections. Track these families through the cyclic order and the gap compositions of $n$. With at most $n-7$ fibers, the centered classes leave an admissible initial position uncovered, while the restricted non-star classes cannot cover all gap profiles based at that position. This produces a stable triple disjoint from the covering constraints, contradicting that the fibers form a coloring. Thus at least $n-6$ colors are necessary. $\square$

### 5.1 Boundary example

At $n=9$, every stable triple has all three gaps equal to $3$. The vertices are

$$
\{1,4,7\},\qquad \{2,5,8\},\qquad \{3,6,9\}.
$$

They are pairwise disjoint, so $G_3(9,3)$ is a triangle. Its chromatic number is $3=9-6$.

At larger $n$, gap slack appears. If $x'=x-3$, $y'=y-3$, and $z'=z-3$, then

$$
x',y',z'\ge0,\qquad x'+y'+z'=n-9.
$$

Thus stable triples are organized by weak compositions of $n-9$ into three parts, together with cyclic starting positions. This arithmetic representation is useful both in proofs and in computation.

## 6. A topological lower-bound program

Kneser-type chromatic lower bounds often have topological formulations. For a graph $G$, its box complex packages ordered pairs of nonempty vertex collections $(\mathcal A,\mathcal B)$ such that every vertex in $\mathcal A$ is adjacent to every vertex in $\mathcal B$. Swapping the two coordinates gives a free involution.

A proper coloring of $G$ with $m$ colors induces an equivariant map from the box complex into a standard antipodal complex of dimension related to $m-1$. Therefore, a lower bound on the equivariant coindex of the box complex gives a lower bound on $\chi(G)$.

For $G_s(n,k)$, adjacency means disjointness. A box-complex face consists of two collections of stable sets such that every set in one collection is disjoint from every set in the other. The cyclic order and spacing filtration provide natural candidates for equivariant labels.

**Topological target statement.** An explicit equivariant certificate of coindex $n-sk+s-1$ would imply

$$
\chi(G_s(n,k))\ge n-sk+s,
$$

which, together with Theorem 3.1, would establish the full equality.

The arithmetic and topological approaches should not be viewed as competitors. The least-element coloring uses the filtration

$$
[1]\subset[2]\subset\cdots\subset[n]
$$

and the fact that a stable $k$-set cannot begin after $n-s(k-1)$. A topological labeling can potentially record where positive and negative collections first become unavoidable in the same filtration. Both descriptions are controlled by cyclic gaps; one produces an explicit map into colors, while the other seeks to obstruct maps into smaller palettes.

Odd $s$ presents a special challenge because simple parity-based antipodal constructions are less naturally aligned with the spacing condition. The $s=3$ intersecting-family results supply a combinatorial substitute and may also indicate the correct equivariant labels.

## 7. Algorithms and numerical exploration

### 7.1 Generating stable sets

A direct generator enumerates the $\binom nk$ subsets and tests cyclic gaps.

**Algorithm 7.1 (Stable-set generation).** For each increasing tuple $a_1<\cdots<a_k$, compute

$$
a_{r+1}-a_r\quad(1\le r<k),\qquad n+a_1-a_k.
$$

Retain the tuple if every quantity is at least $s$.

The running time is $O\!\left(k\binom nk\right)$ and the output storage is $O(kV)$, where $V=|\mathcal S_s(n,k)|$. A recursive gap-aware generator can prune partial tuples when a required future gap cannot fit, but the direct method is preferable for transparent small examples.

### 7.2 Building the disjointness graph

Given $V$ stable sets, compare every unordered pair and insert an edge when their intersection is empty. With hash-set representations, each test costs $O(k)$ in the worst case, giving $O(kV^2)$ time and $O(V+E)$ graph storage.

### 7.3 Canonical coloring and validation

Assign $c(A)=\min A$. Validation checks both that $c(A)\le n-sk+s$ and that every disjoint pair receives different colors. The first condition follows mathematically from spacing; the second follows because equal minima give a common element. Computational validation costs $O(kV^2)$ if performed against all edges, though assignment alone costs only $O(V)$ once tuples are sorted.

### 7.4 Exact chromatic search

For small graphs, backtracking decides whether an $m$-coloring exists. Choose an uncolored vertex—preferably one with high saturation degree—try each available color, and backtrack on conflict. Repeating for increasing $m$ determines the chromatic number.

The worst-case running time is exponential, on the order of $O(m^V)$ before pruning. It is therefore a microscope for small instances, not a replacement for structural proof. Symmetry breaking, such as fixing the first vertex’s color, substantially reduces redundant branches.

### 7.5 Gap-profile enumeration

For each stable set, compute its cyclic gap tuple. Aggregating equal tuples up to cyclic rotation reveals how the vertex family is distributed among compositions of $n$ with parts at least $s$. In the triple case, subtracting $3$ from each gap reduces the profile space to weak compositions of $n-9$. This visualization makes the boundary $n=9$ and the growth of slack immediately apparent.

## 8. Applications and broader connections

Stable Kneser graphs model incompatibility among separated configurations. In circular scheduling, a vertex can represent $k$ recurring slots separated by mandatory recovery time; adjacent vertices are schedules sharing no slot. A coloring groups schedules guaranteed to overlap. In channel selection, stability models guard bands and colors can classify support patterns so that completely disjoint allocations are separated. In coding theory, stable supports form constrained constant-weight words, and graph coloring partitions them into pairwise-intersecting classes.

The theory also illustrates a general methodological principle. A local constraint—minimum cyclic spacing—can create a global coordinate, the least element, that yields a canonical construction. Optimality, however, is global: it depends on all ways that large intersecting families can organize themselves. The conjunction of an easy construction and a difficult rigidity theorem is common in extremal combinatorics.

## 9. Discussion

Three features of the results deserve emphasis.

First, the universal upper bound is exact in every proven regime and is likely exact throughout the admissible range. Its formula is not mysterious: after reserving $s$ units for each of the $k-1$ forward gaps, the least element has exactly $n-s(k-1)$ possible values.

Second, color fibers—not individual edges—are the right objects for the lower bound. Since fibers are intersecting families, the chromatic problem inherits the star versus non-star dichotomy. Stable Hilton–Milner theory is therefore not auxiliary; it directly controls the possible architecture of a coloring.

Third, the combinatorial and topological viewpoints share a common substrate. Cyclic gaps govern stable-set existence, the least-element filtration, exceptional intersecting families, and candidate equivariant labels. A unified certificate may ultimately explain the complete formula.

## 10. Future work

The foremost conjecture is the full odd-stability equality: for all $s\ge3$, $k\ge1$, and $n\ge sk$,

$$
\chi(G_s(n,k))=n-sk+s.
$$

A sharp classification of maximum non-star intersecting families for fixed $s$ and sufficiently large $n$ would strengthen the lower-bound method. It should identify finitely many cyclic Hilton–Milner constructions and quantify the deficit from a star.

A second direction is rigidity of optimal colorings. For $s=3$ and large $n$, one may ask whether every optimal coloring can, after a cyclic relabeling and permutation of colors, be transformed into classes of prescribed initial-segment or Hilton–Milner type.

A third direction is quantitative stability below the threshold. A coloring with fewer than $n-sk+s$ colors must fail; one can ask for a lower bound on the number or density of monochromatic disjoint pairs. Such a supersaturation theorem would measure how strongly optimality fails.

Finally, an explicit equivariant index certificate derived from the initial-segment filtration could bridge the elementary and topological arguments. The ideal construction would encode the same gap data that makes the least-element coloring work, but in a form that obstructs every smaller palette.

## 11. Conclusion

Cyclically stable Kneser graphs turn a spacing problem on a circle into a chromatic problem about disjointness. Their canonical coloring is immediate once the least possible gaps are counted, yielding the universal bound $n-sk+s$. Proving optimality requires understanding the internal structure of intersecting stable families. Stable Hilton–Milner principles provide that structure for the $3$-stable large-$n$ regime and, with a complete gap analysis, for every cyclically $3$-stable triple graph. The resulting exact formula $\chi(G_3(n,3))=n-6$ holds throughout the admissible range. The remaining general conjecture invites a synthesis of extremal set theory, cyclic arithmetic, and equivariant topology.