# Persistent Connectivity of Prime Point Clouds on the Real Line

## Abstract

We study Vietoris–Rips filtrations of finite strictly increasing point clouds on the real line, with prime numbers as the motivating example. The deterministic structure is completely controlled by consecutive spacings. At scale $\varepsilon$, two ordered points are connected if and only if every intervening consecutive gap is at most $\varepsilon$; consequently, their connection threshold is the maximum intervening gap. For a finite cloud, the finite death times in zeroth persistent homology are therefore exactly the consecutive gaps, with multiplicity, together with one infinite class. For the cloud $\{2,3,5,7,11,13\}$, the endpoint connection threshold is $4$. We also establish a geometric obstruction to a proposed higher-dimensional interpretation: if an edge spans an intermediate point on the line, both shorter edges are already present, so the Vietoris–Rips flag complex fills the associated triangle. Twin-prime edges consequently do not generate one-dimensional holes in this model. We formulate an efficient barcode algorithm, explain how local normalized prime-gap statistics may be compared cautiously with an inhomogeneous Poisson heuristic, and identify alternative embeddings capable of supporting nontrivial higher-dimensional arithmetic topology.

## 1. Introduction

Let $p_1=2,p_2=3,p_3=5,\ldots$ denote the increasing sequence of primes. Viewing a finite initial segment as a point cloud in $\mathbb R$ invites the use of persistent homology: connect nearby primes at a growing distance scale and record the birth and death of topological features. This viewpoint appears to promise a geometric encoding of prime gaps, exceptional local clusters, and perhaps special pairs such as twin primes.

The first objective of this paper is to determine exactly what the ordinary Vietoris–Rips filtration can detect in this one-dimensional embedding. The answer in dimension zero is complete and elementary but consequential. Every connectivity question reduces to consecutive gaps. No nonconsecutive edge can bypass a gap before that gap itself enters the filtration. Thus the zeroth persistence barcode is not merely correlated with gap data; its finite death multiset is the consecutive-gap multiset.

The second objective is corrective. A suggested interpretation associates one-dimensional persistent holes with even prime gaps and imagines a class at the twin-prime scale. In an ordinary Vietoris–Rips complex, every clique is filled. For ordered real points, an edge joining two outer points forces edges from each outer point to every intermediate point. In particular, any apparent three-edge cycle is filled immediately. A twin-prime pair is a short edge, not a hole.

The third objective is methodological. A Poisson process with local intensity approximately $1/\log X$ is a useful heuristic benchmark for prime gaps near $X$, but exact distributional equality is impossible: prime gaps are discrete and, after the initial pair, even. A defensible comparison must be local, normalized, and expressed through a specified statistic. The exact topological theorem and the approximate statistical hypothesis must remain separate.

The results apply to every finite strictly increasing real point cloud. Primes enter only through their ordered positions and gap sequence. This generality exposes both the strength and limitation of the model: it gives an exact and efficient summary of spacings, while discarding arithmetic information not encoded by Euclidean distance on the line.

## 2. Ordered point clouds and Rips filtrations

### 2.1. Basic definitions

Let

$$
X=\{x_0,x_1,\ldots,x_{n-1}\}\subset\mathbb R,
\qquad x_0<x_1<\cdots<x_{n-1}.
$$

For $0\le k<n-1$, define the consecutive gap

$$
g_k=x_{k+1}-x_k>0.
$$

For a scale $\varepsilon\ge0$, the proximity graph $G_\varepsilon(X)$ has vertex set $\{0,\ldots,n-1\}$ and an edge between $i$ and $j$ precisely when

$$
|x_i-x_j|\le\varepsilon.
$$

The Vietoris–Rips complex $\operatorname{VR}_\varepsilon(X)$ is the flag complex of this graph: a finite set of vertices spans a simplex if every pair in the set is joined by an edge. In particular, a three-clique is filled by a $2$-simplex.

Two vertices are **connected at scale $\varepsilon$** if a finite path in $G_\varepsilon(X)$ joins them. The connected components of $G_\varepsilon(X)$ represent the generators of $H_0(\operatorname{VR}_\varepsilon(X))$. Because an edge present at scale $\varepsilon$ remains present at every $\delta\ge\varepsilon$, the graphs and complexes form filtrations:

$$
G_\varepsilon(X)\subseteq G_\delta(X),
\qquad
\operatorname{VR}_\varepsilon(X)\subseteq\operatorname{VR}_\delta(X).
$$

Thus connected components may merge as scale increases but cannot split.

### 2.2. Persistence conventions

At scale zero, distinct points form $n$ components. Under the standard elder-rule interpretation of zero-dimensional persistence, each merger kills one finite class, while one component survives indefinitely. The $H_0$ barcode therefore consists of $n-1$ finite intervals and one infinite interval. Since every class is born at scale $0$ for a point cloud with distinct points, the finite barcode is determined by its death multiset.

When several gaps have the same length, several mergers may occur at the same scale. A multiset, rather than a set, is therefore essential.

For indices $i\le j$, define the connection threshold

$$
\tau(i,j)=\inf\{\varepsilon\ge0: i\text{ and }j\text{ are connected in }G_\varepsilon(X)\}.
$$

We set $\tau(i,i)=0$. The main theorem identifies $\tau(i,j)$ exactly.

## 3. Deterministic connectivity theory

### Lemma 3.1 (Filtration monotonicity)

If $\varepsilon\le\delta$, every edge of $G_\varepsilon(X)$ is an edge of $G_\delta(X)$, and any two vertices connected at scale $\varepsilon$ remain connected at scale $\delta$.

**Proof sketch.** The edge condition $|x_i-x_j|\le\varepsilon$ and the inequality $\varepsilon\le\delta$ imply $|x_i-x_j|\le\delta$. Applying this observation to every edge of a path preserves the path. $\square$

### Lemma 3.2 (Long edges force shorter edges)

Let $i\le j\le k$. If $|x_k-x_i|\le\varepsilon$, then

$$
|x_j-x_i|\le\varepsilon
\qquad\text{and}\qquad
|x_k-x_j|\le\varepsilon.
$$

**Proof sketch.** Ordering gives

$$
0\le x_j-x_i\le x_k-x_i
$$

and

$$
0\le x_k-x_j\le x_k-x_i.
$$

Since the absolute values equal these nonnegative differences, both shorter distances are bounded by the outer distance. $\square$

This elementary interval property is central. It implies that a nonlocal edge never appears without all edges from its endpoints to intervening vertices.

### Lemma 3.3 (A large consecutive gap is an edge cut)

Suppose $g_k=x_{k+1}-x_k>\varepsilon$. If $a\le k<b$, then $a$ and $b$ are not adjacent in $G_\varepsilon(X)$. Equivalently, every edge has both endpoints in $\{0,\ldots,k\}$ or both endpoints in $\{k+1,\ldots,n-1\}$.

**Proof sketch.** Monotonicity of the points yields $x_a\le x_k<x_{k+1}\le x_b$. Hence

$$
|x_b-x_a|=x_b-x_a\ge x_{k+1}-x_k=g_k>\varepsilon.
$$

Thus the edge condition fails. $\square$

### Corollary 3.4 (A large gap separates components)

Under the hypotheses of Lemma 3.3, no vertex at or left of $k$ is connected at scale $\varepsilon$ to a vertex at or right of $k+1$.

**Proof sketch.** Every path crossing from one side to the other would contain a first edge whose endpoints lie on opposite sides of the cut. Lemma 3.3 excludes such an edge. $\square$

### Lemma 3.5 (Small consecutive gaps provide a path)

Let $i\le j$. If $g_k\le\varepsilon$ for every $i\le k<j$, then $i$ and $j$ are connected in $G_\varepsilon(X)$.

**Proof sketch.** Each pair $(k,k+1)$ for $i\le k<j$ is an edge. Concatenating these edges gives the path

$$
i,i+1,\ldots,j.
$$

$\square$

### Theorem 3.6 (Exact connectivity criterion)

For a finite strictly increasing real point cloud and indices $i\le j$, the vertices $i$ and $j$ are connected at scale $\varepsilon$ if and only if

$$
g_k\le\varepsilon
\quad\text{for every }i\le k<j.
$$

**Proof sketch.** If all intervening gaps are at most $\varepsilon$, Lemma 3.5 supplies the consecutive-edge path. Conversely, suppose some intervening gap $g_k$ exceeds $\varepsilon$. Since $i\le k<j$, Corollary 3.4 places $i$ and $j$ on opposite sides of a component-separating cut. They cannot be connected. $\square$

### Corollary 3.7 (Exact endpoint threshold)

For $i<j$,

$$
\tau(i,j)=\max_{i\le k<j}g_k.
$$

In particular, the full cloud becomes connected at scale

$$
\tau(0,n-1)=\max_{0\le k<n-1}g_k.
$$

**Proof sketch.** By Theorem 3.6, the set of scales at which $i$ and $j$ are connected is exactly the interval of scales greater than or equal to every intervening gap. Its least element is their maximum. $\square$

The result may also be stated without an explicit maximum: connectivity at scale $\varepsilon$ is equivalent to the pointwise family of inequalities $g_k\le\varepsilon$ over the index interval.

## 4. Zeroth persistence is the gap multiset

### Theorem 4.1 (Zeroth barcode theorem)

Let $X=\{x_0<\cdots<x_{n-1}\}$. The persistent $H_0$ barcode of its Vietoris–Rips filtration contains one interval $[0,\infty)$ and $n-1$ finite intervals whose death times, counted with multiplicity, are

$$
\{g_0,g_1,\ldots,g_{n-2}\}.
$$

Equivalently, the minimum spanning tree of the complete Euclidean graph on $X$ is the adjacent chain, with edge weights equal to the consecutive gaps.

**Proof sketch.** For each threshold $\varepsilon$, Theorem 3.6 shows that components are exactly the maximal consecutive blocks obtained by cutting the ordered list at gaps larger than $\varepsilon$. Therefore the number of components is

$$
\beta_0(\varepsilon)=1+\#\{k:g_k>\varepsilon\}.
$$

Whenever $\varepsilon$ passes a gap value, one boundary disappears for each occurrence of that value, producing the same number of component mergers. Hence the finite death multiset is the gap multiset. One component remains after all cuts disappear and persists indefinitely. The minimum-spanning-tree formulation follows because the adjacent chain connects all vertices, while every cut between $x_k$ and $x_{k+1}$ requires any spanning tree to use a crossing edge of weight at least $g_k$. $\square$

A useful corollary is an exact survival-count formula. If $D$ denotes the multiset of finite death times, then

$$
\#\{d\in D:d>\varepsilon\}=\beta_0(\varepsilon)-1.
$$

Thus the empirical survival function of finite $H_0$ bars is simply the empirical survival function of consecutive gaps.

### Example 4.2 (The first six primes)

Consider

$$
X=\{2,3,5,7,11,13\}.
$$

Its consecutive gaps are

$$
(1,2,2,4,2).
$$

The finite $H_0$ death multiset is therefore $\{1,2,2,2,4\}$, and there is one infinite bar. More explicitly:

- for $0\le\varepsilon<1$, there are $6$ components;
- for $1\le\varepsilon<2$, there are $5$ components;
- for $2\le\varepsilon<4$, there are $2$ components, namely $\{2,3,5,7\}$ and $\{11,13\}$;
- for $\varepsilon\ge4$, there is $1$ component.

Consequently, $2$ and $13$ are connected if and only if $4\le\varepsilon$. The gap $11-7=4$ is the unique last barrier.

## 5. Higher-dimensional obstruction on the line

### Theorem 5.1 (Ordered-triangle filling theorem)

Let $x_i\le x_j\le x_k$. If the outer edge $\{i,k\}$ belongs to $G_\varepsilon(X)$, then the edges $\{i,j\}$ and $\{j,k\}$ also belong to $G_\varepsilon(X)$. Consequently, the three vertices span a filled $2$-simplex in $\operatorname{VR}_\varepsilon(X)$.

**Proof sketch.** Lemma 3.2 supplies both shorter edges. Together with the assumed outer edge, the vertices form a clique. By the defining flag property of a Vietoris–Rips complex, every clique spans a simplex. $\square$

### Corollary 5.2 (No three-point Rips hole from an ordered triple)

No three ordered points on the real line support an unfilled triangular $1$-cycle at any scale in an ordinary Vietoris–Rips filtration.

**Proof sketch.** Before the longest of the three edges appears, the triangular boundary is incomplete. When the longest edge appears, all three edges are present and Theorem 5.1 fills the triangle simultaneously. There is no scale interval on which the boundary exists without its interior. $\square$

### Consequence for twin primes

If $p$ and $p+2$ are twin primes, their distance-$2$ edge appears at scale $2$. This event can merge two $H_0$ components, depending on neighboring edges, but it does not by itself create an $H_1$ class. In particular, the persistence or infinitude of twin-prime pairs cannot be represented as a single one-dimensional bar extending from scale $2$ to infinity in this construction.

The obstruction is not specific to primes. It follows from one-dimensional ordering and the flag-complex rule. Connected unit interval graphs admit a strong elimination structure, and their clique complexes are expected to collapse to a point componentwise. The ordered-triangle theorem proves the local obstruction needed to reject the proposed triangular mechanism; a complete dismantling proof would establish vanishing reduced homology in all positive dimensions.

## 6. Algorithms

### 6.1. Direct gap-barcode algorithm

**Input:** a finite list of distinct real points.

**Output:** finite $H_0$ death times and the infinite bar.

1. Sort the points into $x_0<\cdots<x_{n-1}$.
2. Compute $g_k=x_{k+1}-x_k$ for $0\le k<n-1$.
3. Sort the gaps if an ordered barcode is desired.
4. Return finite intervals $[0,g_k)$, with multiplicity, and one interval $[0,\infty)$.

Sorting arbitrary input costs $O(n\log n)$ time. Gap computation costs $O(n)$ time and $O(n)$ output space. If the input is already ordered, the unsorted death multiset is produced in $O(n)$ time. This avoids constructing $O(n^2)$ pairwise distances or a general boundary matrix.

### 6.2. Connectivity-query algorithm

After preprocessing the gap array for range maxima, the threshold between endpoints $i<j$ is the range maximum of $g_i,\ldots,g_{j-1}$. A sparse table uses $O(n\log n)$ preprocessing time and space and answers static queries in $O(1)$ time. A segment tree uses $O(n)$ space, $O(n)$ construction time, and $O(\log n)$ query time. For a single query, a direct scan costs $O(j-i)$.

### 6.3. Local prime-gap comparison

To compare prime data near a large location $X$ with a Poisson heuristic:

1. generate primes in a specified window $[X,X+H]$;
2. compute consecutive gaps whose two endpoints lie in the window;
3. normalize each gap by $\log X$;
4. compare the empirical survival function with $e^{-t}$;
5. report a chosen discrepancy, such as the Kolmogorov–Smirnov distance;
6. record the window, endpoint convention, sample size, and whether any parameter was fitted.

By Theorem 4.1, this procedure is simultaneously a comparison of normalized finite $H_0$ bar lengths. The statistical calculation does not alter the deterministic theorem.

## 7. Statistical interpretation for prime numbers

The prime number theorem motivates the local density approximation $1/\log X$ near a large $X$. A homogeneous Poisson process with this intensity has exponential gap density

$$
f_X(t)=\frac{1}{\log X}\exp\!\left(-\frac{t}{\log X}\right),
\qquad t\ge0,
$$

and mean $\log X$. Its normalized gaps $T/\log X$ have unit exponential survival function

$$
\Pr(T/\log X>u)=e^{-u}.
$$

This is a benchmark, not an exact model. For all primes beyond $2$, consecutive primes are odd, so their differences are even integers. The empirical prime-gap measure is supported on a discrete arithmetic lattice, whereas the exponential law is absolutely continuous. Exact equality in distribution is therefore impossible. Congruence restrictions modulo small primes further produce dependencies absent from an independent Poisson process.

The nonconstant intensity also matters. Combining gaps from a broad interval without normalization mixes different local scales. A comparison should use windows $[X,X+H]$ narrow enough that $\log x$ changes little relative to the intended precision, yet wide enough to contain a useful sample. These competing asymptotic requirements must be stated rather than hidden.

A goodness-of-fit claim requires a defined statistic. For normalized observations $z_1,\ldots,z_m$, one option is

$$
D_m=\sup_{t\ge0}|F_m(t)-(1-e^{-t})|,
$$

where $F_m$ is the empirical distribution function. Interpreting $D_m$ through the classical independent-sample null distribution would itself be heuristic because prime gaps are not independent. Quantile comparisons and survival plots remain useful descriptive tools, provided they are not promoted to exact arithmetic laws.

## 8. Applications and extensions

The exact $H_0$ characterization has several practical uses. First, it compresses connectivity information. The entire filtration of connected components is encoded by $n-1$ numbers rather than all pairwise distances. Second, it gives immediate interpretability: a long finite bar is exactly a large adjacent spacing, and clusters at scale $\varepsilon$ are maximal runs separated by gaps exceeding $\varepsilon$. Third, it provides a baseline for validating general persistent-homology software on one-dimensional data.

For arithmetic data, persistence summaries can compare windows or sequences. One may examine distributions of normalized death times, counts above selected thresholds, maximum-bar growth, or changes across residue-restricted subsets. Every such statistic should be understood as a transformation of gap data in this embedding.

To obtain nontrivial higher-dimensional information, the representation must change. Promising alternatives include:

1. **Delay-coordinate gap embeddings.** Map an index $k$ to $(g_k,g_{k+1},\ldots,g_{k+d-1})\in\mathbb R^d$. Recurring multi-gap patterns may then form loops or higher-dimensional structures.
2. **Residue-feature embeddings.** Represent primes or prime neighborhoods by vectors of residues modulo selected moduli, preserving congruence information erased by location alone.
3. **Weighted or non-flag complexes.** Modify simplex-filling rules so that a clique does not automatically erase an arithmetically meaningful cycle.
4. **Witness complexes from arithmetic relations.** Use divisibility, admissible constellations, or shared modular obstructions to define witnesses and landmarks.
5. **Multiparameter filtrations.** Combine Euclidean gap scale with an arithmetic parameter such as modulus, tuple admissibility, or local density.

Each alternative changes the mathematical object. Conclusions about such enriched constructions must not be attributed to the ordinary Rips complex of the prime locations in $\mathbb R$.

## 9. Discussion

The one-dimensional model succeeds precisely because order dominates geometry. A single large consecutive gap is a cut respected by every edge and every path. Conversely, a chain of small consecutive gaps is already sufficient for connectivity. The maximum intervening gap is therefore a minimax distance: among all paths between two ordered points, the adjacent chain minimizes the largest edge, and its bottleneck is the largest local gap.

This minimax interpretation connects persistent connectivity with single-linkage clustering and minimum spanning trees. Cutting the adjacent chain at edges above $\varepsilon$ produces exactly the single-linkage clusters. The dendrogram merge heights are the sorted gaps. Persistent $H_0$, hierarchical clustering, and one-dimensional minimum spanning trees are three descriptions of the same structure.

The higher-dimensional correction is equally instructive. A cycle in the proximity graph need not represent homology in its flag complex, because clique boundaries are filled. Confusing graph cycles with topological holes is especially risky in ordered data, where interval geometry creates many forced chords and simplices. Any arithmetic interpretation must account for the filling rule, not merely the appearance of selected edges.

The results also delimit the role of machine-learning language. Persistent features can serve as inputs to statistical or learning pipelines, but no classifier can recover arithmetic distinctions discarded by the representation. If two ordered clouds have the same consecutive-gap multiset, their finite $H_0$ barcodes agree even if the order of gaps differs; richer summaries or embeddings are needed to retain sequence order and congruence structure.

## 10. Future work

A natural first extension is a complete collapse theorem for Vietoris–Rips complexes of finite subsets of $\mathbb R$. An elimination ordering for interval graphs should show that every connected component of the clique complex is contractible, proving vanishing reduced homology in every positive dimension.

A second direction is statistical. Local normalized prime-gap barcodes should be studied with clearly specified windows, normalization, discrepancy statistics, and dependence-aware uncertainty assessments. The parity obstruction should be built into any null model, perhaps through conditioned or sieved random processes rather than a raw Poisson process.

A third direction is representational. Delay embeddings retain ordered blocks of gaps and can be compared across dimensions and window locations. Residue-aware and multiparameter constructions may expose arithmetic patterns unavailable on the line. Their stability, computational cost, and interpretability require separate analysis.

Finally, the exact barcode theorem suggests scalable studies over very large prime ranges. Because only consecutive gaps are required, streaming algorithms can update histograms, survival curves, maxima, and selected persistence summaries without storing pairwise distances.

## 11. Conclusion

For a strictly increasing real point cloud, connectivity in the Vietoris–Rips filtration is exact and local: two points are connected at scale $\varepsilon$ exactly when every intervening consecutive gap is at most $\varepsilon$. Their connection threshold is the largest such gap, and the finite $H_0$ death multiset of a finite cloud is precisely its consecutive-gap multiset. Applied to $2,3,5,7,11,13$, this gives endpoint threshold $4$.

The same ordering rules out the proposed triangular source of $H_1$: an outer edge forces both shorter edges, and the flag complex fills the triangle. Twin primes generate short edges, not persistent holes. The correct role of the one-dimensional topology is therefore clear. It offers an exact geometric language for gap structure and an efficient basis for statistical summaries, while genuinely higher-dimensional arithmetic topology demands a richer embedding or a different complex.
