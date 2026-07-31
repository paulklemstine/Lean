# Adjacency–Degree Matrix Moments as Degree Statistics and Star Homomorphism Counts

**Aristotle**  
**July 31, 2026**

## Abstract

Let $G$ be a finite simple undirected graph with adjacency matrix $A$, diagonal degree matrix $D$, and all-ones vector $\mathbf 1$. We establish the identity

$$
\mathbf 1^TADA\mathbf 1=\sum_{v\in V(G)}d(v)^3=\operatorname{hom}(K_{1,3},G).
$$

Thus the scalar adjacency–degree word $ADA$ is simultaneously the third raw moment of the degree sequence and the number of graph homomorphisms from the three-leaf star. We first prove a more general result for arbitrary finite symmetric real matrices: if $r$ is the row-sum vector and $D_r$ is its diagonal matrix, then $\mathbf 1^TAD_rA\mathbf 1=\sum_i r_i^3$. We then identify row sums of a graph adjacency matrix with vertex degrees and give a direct combinatorial interpretation in terms of ordered triples of neighbors. The resulting connector supplies three equivalent computational algorithms, clarifies the observable’s sensitivity to high-degree vertices, and provides a base case for a broader dictionary between words in adjacency and degree matrices and degree-decorated tree homomorphisms. We also discuss information loss, complexity, weighted extensions, higher star moments, and prospective applications to network analysis and spectral graph invariants.

## 1. Introduction

A finite graph admits several complementary descriptions. Combinatorially, it is a set of vertices together with unordered pairs designated as edges. Algebraically, it is represented by an adjacency matrix. Statistically, it has a degree distribution recording how many neighbors each vertex possesses. Homomorphism theory studies the number of structure-preserving maps from small pattern graphs into the graph. The purpose of this paper is to exhibit an exact bridge among these descriptions.

Let $A$ denote the adjacency matrix of a finite simple undirected graph, let $D$ denote the diagonal matrix of degrees, and let $\mathbf 1$ be the all-ones vector. We focus on the scalar matrix moment $\mathbf 1^TADA\mathbf 1$. This expression belongs to the family of observables obtained by evaluating noncommutative words in $A$ and $D$ between $\mathbf 1^T$ and $\mathbf 1$. Although it appears to involve a two-step propagation through the graph, it collapses to a basic degree statistic:

$$
\mathbf 1^TADA\mathbf 1=\sum_v d(v)^3.
$$

The sum on the right is the third raw power sum of the degree multiset. It is highly sensitive to hubs because cubic weighting emphasizes large degrees. The same sum has an exact motif interpretation. If $K_{1,3}$ is the star with one center and three leaves, then a homomorphism $K_{1,3}\to G$ is specified by choosing an image $v$ for the center and choosing, independently and with repetition allowed, an image among the neighbors of $v$ for each leaf. Hence there are $d(v)^3$ maps centered at $v$, and

$$
\operatorname{hom}(K_{1,3},G)=\sum_v d(v)^3.
$$

The contribution of this paper is a self-contained derivation of this three-way identity, beginning with a matrix theorem that does not depend on graphs. This separation makes clear which assumption is responsible for each step. Symmetry converts column sums to row sums; adjacency matrices convert row sums to degrees; and the Cartesian product rule converts degree cubes to star homomorphisms.

The identity is elementary enough to serve as a transparent prototype for a larger program. Words in $A$ and $D$ alternate movement along edges with weighting by local degree. Their scalar moments can encode homomorphism counts of degree-decorated caterpillars. Families of such moments may be compared with graph spectra, color-refinement invariants, and reconstruction procedures. The present result supplies a rigorously defined base case whose algebraic, statistical, and combinatorial meanings coincide exactly.

## 2. Definitions and notation

### 2.1 Finite simple graphs

A **finite simple undirected graph** is a pair $G=(V,E)$, where $V$ is a finite set and $E$ is a set of two-element subsets of $V$. There are no loops and no parallel edges. Vertices $u,v\in V$ are adjacent, written $u\sim v$, when $\{u,v\}\in E$.

The **neighborhood** of $v$ is

$$
N(v)=\{u\in V:u\sim v\},
$$

and the **degree** of $v$ is $d(v)=|N(v)|$.

After fixing an ordering of the $n=|V|$ vertices, the **adjacency matrix** is the matrix $A\in\{0,1\}^{n\times n}$ defined by

$$
A_{uv}=\begin{cases}
1,&u\sim v,\\
0,&u\not\sim v.
\end{cases}
$$

Because the graph is undirected, $A^T=A$. Because it is simple, the diagonal entries are zero. The **degree matrix** is

$$
D=\operatorname{diag}(d(v):v\in V).
$$

The column vector $\mathbf 1\in\mathbb R^n$ has every coordinate equal to $1$.

### 2.2 Row sums and diagonalization

For an arbitrary real matrix $A=(A_{ij})$ indexed by a finite set $V$, define its **row-sum vector** $r\in\mathbb R^V$ by

$$
r_i=\sum_{j\in V}A_{ij}.
$$

Equivalently, $r=A\mathbf 1$. Let $D_r$ be the diagonal matrix with $(D_r)_{ii}=r_i$. For an adjacency matrix, $r_v=d(v)$ and therefore $D_r=D$.

We define the **adjacency–row-sum moment** of a symmetric real matrix $A$ to be

$$
\mu_{ADA}(A)=\mathbf 1^TAD_rA\mathbf 1.
$$

For a graph adjacency matrix, this becomes the **adjacency–degree moment**

$$
\mu_{ADA}(G)=\mathbf 1^TADA\mathbf 1.
$$

### 2.3 Raw degree moments

For an integer $q\ge 0$, the $q$th **raw degree power sum** is

$$
p_q(G)=\sum_{v\in V}d(v)^q.
$$

If degrees are normalized into a probability distribution by selecting a uniformly random vertex $X$, then

$$
\mathbb E[d(X)^q]=\frac{p_q(G)}{|V|}.
$$

Accordingly, $p_3(G)$ is $|V|$ times the third raw moment of the empirical degree distribution. We use the unnormalized power sum because it is the natural count arising from matrix products and graph homomorphisms.

### 2.4 Graph homomorphisms and stars

Given finite simple graphs $H$ and $G$, a **graph homomorphism** from $H$ to $G$ is a map $f:V(H)\to V(G)$ such that

$$
xy\in E(H)\implies f(x)f(y)\in E(G).
$$

The map need not be injective, and nonadjacent vertices of $H$ may have equal images. Write $\operatorname{hom}(H,G)$ for the number of such maps.

The **three-leaf star** $K_{1,3}$ consists of a center $c$, leaves $\ell_1,\ell_2,\ell_3$, and edges $c\ell_1$, $c\ell_2$, and $c\ell_3$. Once the image of $c$ is chosen, the images of the leaves are ordered independent choices from the center’s neighborhood. Repetitions among leaf images are allowed.

## 3. The symmetric matrix identity

We begin at the level of arbitrary symmetric matrices. This result isolates symmetry as the essential algebraic condition.

### Theorem 1 (Symmetric Row-Sum Moment Theorem)

Let $V$ be a finite index set, let $A\in\mathbb R^{V\times V}$ be symmetric, let $r=A\mathbf 1$ be its row-sum vector, and let $D_r=\operatorname{diag}(r)$. Then

$$
\mathbf 1^TAD_rA\mathbf 1=\sum_{i\in V}r_i^3.
$$

#### Proof sketch

The relation $A\mathbf 1=r$ is immediate from the definition of matrix-vector multiplication. Symmetry gives

$$
\mathbf 1^TA=(A^T\mathbf 1)^T=(A\mathbf 1)^T=r^T.
$$

Therefore

$$
\mathbf 1^TAD_rA\mathbf 1=r^TD_rr.
$$

Since $D_r$ is diagonal, its action is coordinatewise multiplication by $r_i$. Thus the $i$th contribution to the quadratic expression is $r_i\cdot r_i\cdot r_i=r_i^3$, and summing over $i$ proves the result.

An index expansion gives the same conclusion and highlights the use of symmetry. First,

$$
\mathbf 1^TAD_rA\mathbf 1
=\sum_{i,j}A_{ij}r_j^2
=\sum_j\left(\sum_i A_{ij}\right)r_j^2.
$$

For a symmetric matrix, the $j$th column sum equals the $j$th row sum $r_j$. Hence the expression is $\sum_j r_j^3$.

### Remark 1 (Necessity of symmetry)

Without symmetry, the left factor contributes column sums while the right factor contributes row sums. If $c_j=\sum_i A_{ij}$ denotes the column-sum vector, then the general identity is

$$
\mathbf 1^TAD_rA\mathbf 1=\sum_j c_jr_j^2.
$$

This equals $\sum_j r_j^3$ whenever $c=r$, a condition weaker than symmetry but automatically satisfied by every symmetric matrix. Thus symmetry is a natural sufficient hypothesis rather than a merely cosmetic one.

### Remark 2 (Weighted networks)

Theorem 1 permits arbitrary real entries. For a symmetric weighted network with interaction weight $A_{ij}=A_{ji}$, the weighted degree or strength is $r_i=\sum_jA_{ij}$. The same scalar moment is the sum of cubes of weighted strengths, even when weights are not binary. If negative weights are allowed, the result remains algebraically valid, although the homomorphism-count interpretation is then replaced by a weighted partition sum.

## 4. Specialization to finite graphs

The next lemma identifies the matrix row sums with graph degrees.

### Lemma 2 (Adjacency Row-Sum Lemma)

Let $G$ be a finite simple undirected graph with adjacency matrix $A$. For every vertex $v$,

$$
(A\mathbf 1)_v=\sum_{u\in V}A_{vu}=d(v).
$$

#### Proof sketch

Each summand $A_{vu}$ equals $1$ precisely when $u\in N(v)$ and equals $0$ otherwise. The sum therefore counts the members of $N(v)$, which by definition is $d(v)$.

Combining Theorem 1 and Lemma 2 immediately yields the graph-theoretic matrix/statistics connector.

### Theorem 3 (Adjacency–Degree Moment Theorem)

Let $G$ be any finite simple undirected graph, with adjacency matrix $A$, degree matrix $D$, and all-ones vector $\mathbf 1$. Then

$$
\mu_{ADA}(G)=\mathbf 1^TADA\mathbf 1=
\sum_{v\in V(G)}d(v)^3=p_3(G).
$$

#### Proof sketch

The adjacency matrix is symmetric, and by Lemma 2 its row-sum vector is the degree vector $d$. Its row-sum diagonal matrix is therefore exactly $D$. Theorem 1 then gives the stated identity.

### Corollary 4 (Permutation invariance)

The scalar $\mathbf 1^TADA\mathbf 1$ is invariant under graph isomorphism and under any relabeling of the vertices.

#### Proof sketch

A relabeling is represented by a permutation matrix $P$. The transformed matrices are $A'=PAP^T$ and $D'=PDP^T$, while $P\mathbf 1=\mathbf 1$. Substitution gives

$$
\mathbf 1^TA'D'A'\mathbf 1
=\mathbf 1^TPADA P^T\mathbf 1
=\mathbf 1^TADA\mathbf 1.
$$

Alternatively, Theorem 3 shows that the scalar depends only on the multiset of degrees, which is preserved by isomorphism.

## 5. The star-homomorphism interpretation

The degree cube at a vertex is naturally a Cartesian-product count.

### Lemma 5 (Ordered Neighbor-Triple Lemma)

For every vertex $v$ of a finite simple graph,

$$
d(v)^3=|N(v)\times N(v)\times N(v)|.
$$

Consequently,

$$
\sum_vd(v)^3=
\left|\{(v,x,y,z):x,y,z\in N(v)\}\right|.
$$

#### Proof sketch

The cardinality of a finite Cartesian product is the product of the cardinalities of its factors. Each of the three factors has size $d(v)$, giving $d(v)^3$. The sets indexed by different centers $v$ are disjoint once the center is retained as part of the tuple, so summing their cardinalities gives the second formula.

### Lemma 6 (Star Homomorphism Lemma)

For every finite simple graph $G$,

$$
\operatorname{hom}(K_{1,3},G)=\sum_{v\in V(G)}d(v)^3.
$$

#### Proof sketch

Let $c$ be the center of $K_{1,3}$. Partition all homomorphisms according to $v=f(c)$. If the center maps to $v$, each leaf must map to a member of $N(v)$. There are $d(v)$ possibilities for each of three labeled leaves, independently, so there are $d(v)^3$ homomorphisms with center image $v$. Summation over $v$ proves the formula.

It is important that homomorphisms need not be injective. The three leaves are distinct vertices of the source and hence provide three ordered choices, but two or all three may map to the same neighbor. Therefore the count is not $3!\binom{d(v)}{3}$ and not $\binom{d(v)}{3}$.

### Theorem 7 (Matrix–Statistics–Homomorphism Correspondence)

For every finite simple undirected graph $G$,

$$
\boxed{
\mathbf 1^TADA\mathbf 1
=\sum_{v\in V(G)}d(v)^3
=\operatorname{hom}(K_{1,3},G)
}.
$$

Equivalently, the scalar adjacency–degree moment is the number of ordered quadruples $(v,x,y,z)$ such that each of $x$, $y$, and $z$ is adjacent to $v$.

#### Proof sketch

The first equality is Theorem 3. The second is Lemma 6. The ordered-quadruple formulation is Lemma 5.

## 6. Algorithms and computational complexity

The correspondence yields three algorithms with different computational profiles. Let $n=|V|$ and $m=|E|$.

### 6.1 Degree-power algorithm

For an adjacency-list representation, compute every degree and sum its cube.

**Procedure.** Initialize $S=0$. For each vertex $v$, set $d(v)$ equal to the length of its adjacency list and update $S\leftarrow S+d(v)^3$. Return $S$.

**Correctness.** Theorem 3 states that the returned sum equals $\mathbf 1^TADA\mathbf 1$, and Theorem 7 states that it also equals the star-homomorphism count.

**Complexity.** If adjacency lists are already stored, reading their lengths and summing takes $O(n)$ time. If degrees must be constructed from an edge list, the total time is $O(n+m)$. Storage is $O(n+m)$ for the graph and $O(n)$ auxiliary space for degrees, reducible to $O(n)$ beyond the input.

### 6.2 Matrix-word algorithm

Construct $A$, compute $d=A\mathbf 1$, form $D=\operatorname{diag}(d)$, and evaluate $\mathbf 1^TADA\mathbf 1$.

A naive dense implementation takes $O(n^3)$ time if full matrix products are formed. However, associativity permits the sequence $x=A\mathbf 1$, $y=Dx$, $z=Ay$, and $S=\mathbf 1^Tz$, which takes $O(n^2)$ time for a dense matrix and avoids forming $ADA$. With sparse matrix-vector multiplication it takes $O(n+m)$ time. The theorem predicts that the output is an integer for an unweighted graph despite being expressed through real linear algebra.

### 6.3 Explicit ordered-triple enumeration

For each center $v$, loop independently over $x,y,z\in N(v)$ and increment a counter. This directly enumerates the homomorphisms and takes

$$
O\left(\sum_vd(v)^3\right)
$$

time, proportional to the output count, with constant auxiliary space apart from the graph representation. It is usually slower than summing cubes, but it is appropriate when the actual maps, rather than only their number, are required.

### 6.4 Cross-validation protocol

Computing the observable by two or three routes gives a strong implementation check. The degree-power and matrix-vector methods should agree exactly for integer adjacency matrices. On small graphs, explicit enumeration can provide a third check. Disagreement identifies an error in adjacency symmetrization, degree extraction, matrix ordering, or the interpretation of repeated leaf images.

## 7. Examples

### 7.1 The empty graph

If $G$ has no edges, then every degree is $0$. Thus

$$
\mathbf 1^TADA\mathbf 1=0,
$$

and there is no homomorphism from $K_{1,3}$ to $G$, since every source edge would need an image edge.

### 7.2 A single edge

For $G=K_2$, both vertices have degree $1$. Hence

$$
\mathbf 1^TADA\mathbf 1=1^3+1^3=2.
$$

There are exactly two star homomorphisms: choose either endpoint as the center image, after which every leaf is forced to the opposite endpoint.

### 7.3 Paths

For the path $P_n$ with $n\ge 2$, two endpoints have degree $1$ and $n-2$ internal vertices have degree $2$. Therefore

$$
\mu_{ADA}(P_n)=2\cdot1^3+(n-2)\cdot2^3=8n-14.
$$

For $P_1$, the value is $0$.

### 7.4 Cycles

Every vertex of the cycle $C_n$ has degree $2$, so

$$
\mu_{ADA}(C_n)=8n.
$$

The count can also be seen locally: each possible center has two choices for each of three leaves, giving $2^3=8$ maps per center.

### 7.5 Stars

For the star $K_{1,m}$, the center has degree $m$ and the $m$ leaves have degree $1$. Hence

$$
\mu_{ADA}(K_{1,m})=m^3+m.
$$

The $m^3$ term comes from mapping the source center to the target center; each source leaf then chooses any target leaf. The additional $m$ maps arise when the source center maps to one of the target leaves, forcing all source leaves to map to the target center.

### 7.6 Complete graphs

Every vertex of $K_n$ has degree $n-1$, yielding

$$
\mu_{ADA}(K_n)=n(n-1)^3.
$$

### 7.7 Equal moments do not imply isomorphism

The cycle $C_6$ and the disjoint union $C_3\sqcup C_3$ both have six vertices, all of degree $2$. Both therefore have adjacency–degree moment $48$. They are not isomorphic: one is connected and the other is not. This example shows that the observable is not a complete graph invariant.

## 8. Statistical and structural interpretation

The value $p_3(G)$ combines graph size and degree heterogeneity. Let $n=|V|$ and let $X$ be a uniformly chosen vertex. Then

$$
\frac{1}{n}\mathbf 1^TADA\mathbf 1=\mathbb E[d(X)^3].
$$

Because $x\mapsto x^3$ is convex on nonnegative reals, degree concentration increases the observable. For a fixed degree sum $2m$, Jensen’s inequality gives

$$
\frac{1}{n}\sum_vd(v)^3\ge
\left(\frac{2m}{n}\right)^3.
$$

Thus

$$
\mathbf 1^TADA\mathbf 1\ge \frac{(2m)^3}{n^2}.
$$

Equality in the real-valued Jensen inequality occurs when all degrees are equal, so regular graphs minimize the cubic power sum among feasible graphs with a fixed average degree whenever exact regularity is possible. This observation explains the moment’s sensitivity to hubs: redistributing degree from a lower-degree vertex to a higher-degree vertex tends to increase the sum of cubes.

The statistic is nevertheless determined entirely by the degree multiset. It does not record which high-degree vertices are adjacent to one another or how components are arranged. Its value should therefore be viewed as a degree-sensitive observable, not as a complete description of topology.

## 9. Prospective higher star moments

The established identity suggests a uniform extension based on the words $AD^kA$. The proposed program is to prove, for every nonnegative integer $k$, that the scalar $\mathbf 1^TAD^kA\mathbf 1$ is the degree power sum $\sum_vd(v)^{k+2}$ and to identify that sum with the homomorphism count of the star having $k+2$ leaves. The theorem proved in this paper supplies the first degree-decorated case, $k=1$.

If this family is developed uniformly, then an $n$-vertex graph’s first $n$ star moments can be combined with Newton’s identities. Those identities recover the elementary symmetric polynomials in the degrees from their power sums, thereby recovering the polynomial $\prod_{v\in V}(t-d(v))$ and hence the degree multiset. This would reconstruct degree data, not generally the entire graph.

## 10. Words in adjacency and degree matrices

Matrices $A$ and $D$ generally do not commute. A word such as $AD^2AD$ specifies an ordered sequence of two kinds of operation:

- multiplication by $A$ aggregates values across adjacent vertices;
- multiplication by $D^q$ weights a value at vertex $v$ by $d(v)^q$.

Placing a word $w(A,D)$ between $\mathbf 1^T$ and $\mathbf 1$ produces a scalar moment

$$
\mathbf 1^Tw(A,D)\mathbf 1.
$$

Expanding the matrix product suggests sums over walks with degree powers decorating visited vertices. This motivates a prospective combinatorial dictionary with degree-decorated caterpillars: adjacency factors should trace a path-like spine, while degree factors should count independent choices of attached leaves. The present three-leaf-star theorem is the established base case, with three independent neighbor choices at one center.

Building this dictionary would convert broader algebraic observables into graph-pattern counts. Algebraic identities could then be interpreted combinatorially, while matrix methods could aggregate large families of local configurations without explicit enumeration.

## 11. Applications

### 11.1 Network heterogeneity

The normalized quantity $n^{-1}\mathbf 1^TADA\mathbf 1$ is the empirical third raw degree moment. It can compare concentration of connectivity across networks of equal order. Because the cube strongly weights high degrees, the statistic can serve as a hub-sensitive summary in communication, biological, transportation, and social networks.

### 11.2 Motif counting

Theorem 7 provides a closed formula for a homomorphism motif count. Unlike counts of injective embedded stars, it permits repeated leaf images and is therefore naturally compatible with matrix multiplication. In applications where homomorphism densities are the chosen graph statistics, the formula avoids explicit enumeration.

### 11.3 Weighted interaction systems

For symmetric weighted matrices, Theorem 1 computes the cubic moment of vertex strengths. In a physical interaction model, $A_{ij}$ may represent coupling strength and $r_i$ total incident coupling. The scalar $\mathbf 1^TAD_rA\mathbf 1$ then aggregates the cubic strength profile. With nonnegative weights it also equals a weighted three-star partition sum, where each mapped edge contributes its weight.

### 11.4 Data validation

Graph-processing pipelines commonly maintain both an edge representation and matrix or degree summaries. The three-way equality supplies an invariant for testing consistency. It can detect accidental asymmetry, omitted edges, incorrect degree counts, or a motif routine that mistakenly requires distinct leaf images.

### 11.5 Feature construction

Collections of adjacency–degree moments can be used as isomorphism-invariant numerical features. The single moment studied here should not be expected to distinguish all graphs, but it provides an interpretable coordinate: unlike a black-box feature, its exact meaning is known in three mathematical languages.

## 12. Limitations

The main identity has several clear boundaries.

First, the graph-level theorem assumes an undirected graph. For a directed adjacency matrix, row sums and column sums represent out-degrees and in-degrees, and the analogous expression becomes a mixed statistic $\sum_v d_{\mathrm{in}}(v)d_{\mathrm{out}}(v)^2$ when the middle diagonal uses out-degrees.

Second, the observable depends only on degrees. Graphs with the same degree multiset share the value, regardless of connectivity or arrangement. Even all star moments together reconstruct only the degree multiset.

Third, homomorphism counts differ from injective subgraph counts. Repeated leaf images are essential to the degree-cube formula. Applications requiring distinct leaves must replace $d(v)^3$ by a falling-factorial expression such as $d(v)(d(v)-1)(d(v)-2)$ for ordered injective choices.

Fourth, negative matrix weights preserve the algebraic identity but weaken its interpretation as a literal count. The resulting quantity is a signed weighted sum.

These limitations do not undermine the connector; they specify exactly what information it transports.

## 13. Future work

Several directions arise naturally.

1. **Arbitrary star moments.** Develop the family $\mathbf 1^TAD^kA\mathbf 1=\sum_vd(v)^{k+2}$ uniformly and express its right-hand side as the homomorphism count from the $(k+2)$-leaf star.

2. **Degree-decorated caterpillars.** Associate a decorated caterpillar with each word in $A$ and $D$, and prove inductively that its homomorphism count equals the corresponding scalar moment.

3. **Degree-multiset reconstruction.** Combine the first $n$ star moments for an $n$-vertex graph with Newton’s identities to reconstruct its degree multiset algorithmically.

4. **Adjacency–degree cyclic spaces.** Study the vector space generated from $\mathbf 1$ by words in $A$ and $D$, including its behavior under graph isomorphisms and automorphisms.

5. **Forests and orbit structure.** Investigate when the cyclic space coincides with the span of indicator vectors of automorphism orbits, particularly for forests.

6. **Tree rigidity.** Determine conditions under which all scalar adjacency–degree word moments characterize a finite tree.

7. **Color refinement.** Compare successive spaces generated from $\mathbf 1$ by $A$ and $D$ with equitable partitions and one-dimensional Weisfeiler–Leman refinement.

8. **Small switching examples.** Analyze nonisomorphic graphs produced by integral switching operations that preserve selected scalar moments or cyclic-space invariants.

The first three directions extend the explicit connector developed here. The remaining questions require deeper interaction among graph automorphisms, finite-dimensional algebra, and graph-isomorphism invariants.

## 14. Conclusion

For a finite simple undirected graph, the scalar matrix word $\mathbf 1^TADA\mathbf 1$ has an exact and elementary meaning:

$$
\mathbf 1^TADA\mathbf 1
=\sum_vd(v)^3
=\operatorname{hom}(K_{1,3},G).
$$

The proof factors into three transparent observations. Multiplying the all-ones vector by the adjacency matrix produces row sums; for a graph these row sums are degrees; and the cube of a degree counts ordered choices of three neighbors. Symmetry aligns the row sums appearing on the two sides of the diagonal weighting.

This identity is useful beyond its brevity. It provides equivalent linear-algebraic, statistical, and combinatorial algorithms; it identifies a hub-sensitive network statistic; it extends to symmetric weighted systems; and it forms a base case for interpreting richer adjacency–degree words as decorated homomorphism counts. Most importantly, it shows how a compact matrix observable can carry a completely explicit combinatorial meaning.