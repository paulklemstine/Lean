# A Finite Stability Core for Zeroth Vietoris--Rips Persistence

**Aristotle**  
**July 25, 2026**

## Abstract

We develop a self-contained finite stability theory for radius-parametrized Vietoris--Rips connectivity. Two real-valued distance tables on a common label set are said to have distortion at most $\delta$ when every pairwise value differs by at most $\delta$. Under the convention that an edge of length $a$ enters the Rips graph at radius $a/2$, a distortion bound $\delta$ induces edge inclusions in both directions after a radius shift of $\delta/2$. Monotonicity of connected components then yields a corresponding stability inequality for the zeroth Betti number. We define an equal-cardinality finite bottleneck distance using bijective matchings and the $L^\infty$ metric on birth--death points, and show that any explicit pointwise matching bounds this distance. For zeroth persistence encoded by corresponding weighted tree edges, uniform edge perturbation by $\delta$ gives a bottleneck bound of $\delta/2$. Finally, two two-point clouds with separations $2$ and $3$ attain the bound, proving that the normalization factor is sharp. The results isolate the metric and order-theoretic core needed for broader correspondence-based stability theorems while making explicit the limitations imposed by equal cardinality and certified tree presentations.

## 1. Introduction

Persistent homology summarizes a filtered geometric object by recording when topological features are born and when they die. Its usefulness in data analysis rests on robustness: small perturbations of input distances should produce small perturbations of persistence summaries. The general stability philosophy spans metric geometry, simplicial topology, and optimal matching. In degree zero, however, the essential mechanism can be separated into elementary pieces.

This paper studies a finite common-label model. Let $I$ be a set of labels and let $d,e:I\times I\to\mathbb{R}$ be two distance tables. We assume a uniform comparison

$$
|d(i,j)-e(i,j)|\le\delta
$$

for all labels $i,j$. Although metric applications motivate the terminology, the basic edge-transport argument requires only this inequality; symmetry, positivity, and the triangle inequality are not needed for the stated conclusions.

We use the radius convention in which two labels form a Vietoris--Rips edge at scale $r$ exactly when their distance is at most $2r$. Under this convention, additive error $\delta$ in edge length becomes additive error $\delta/2$ in radius. The resulting edge relation at radius $r$ for one table is contained in the edge relation at radius $r+\delta/2$ for the other, and conversely. Since enlarging an edge relation can only merge connected components, the zeroth Betti number cannot increase along either arm of this interleaving.

To pass from component counts to diagrams, we focus on a finite equal-cardinality bottleneck problem. A persistence point is measured with the $L^\infty$ metric, and diagrams indexed by one common type are compared over all bijections of that type. An explicit bijection whose pointwise cost is at most $\varepsilon$ immediately implies that the bottleneck distance is at most $\varepsilon$.

The main diagram-level result concerns a certified tree presentation. If a family of tree-edge weights $w_k$ records merger events, then the associated finite zeroth-persistence points are $(0,w_k/2)$. When corresponding weights in a second certificate differ by at most $\delta$, the identity matching moves each diagram point by at most $\delta/2$. This gives a concise, reusable stability certificate.

The scope is precise. We prove neither arbitrary-cardinality diagram stability nor the full theorem for arbitrary compact metric spaces and all homological degrees. Diagonal completion, partial matchings, correspondence selections, simplicial contiguity, and persistence-module structure lie beyond the finite core developed here. Stating these boundaries is essential: the present results are ingredients for those extensions, not substitutes for them.

The paper is organized as follows. Section 2 defines distortion, Rips edge relations, connected components, diagrams, and finite bottleneck distance. Section 3 proves the two-way edge interleaving. Section 4 derives monotonicity of $\beta_0$. Section 5 establishes the matching principle. Section 6 proves stability for tree-encoded diagrams. Section 7 gives a sharp two-point computation. Section 8 presents algorithms, Section 9 discusses applications and limitations, and Section 10 outlines future work.

## 2. Definitions and finite setting

### 2.1 Distance tables and distortion

Let $I$ be a nonempty set. A **distance table** is any function

$$
d:I\times I\longrightarrow\mathbb{R}.
$$

In applications $d$ is usually a metric or pseudometric, but our first results only use numerical comparisons.

**Definition 2.1 (Uniform distortion bound).** Two distance tables $d$ and $e$ on the same label set have distortion at most $\delta$ if

$$
\operatorname{dis}(d,e)\le\delta
\quad\text{means}\quad
|d(i,j)-e(i,j)|\le\delta
$$

for every $i,j\in I$.

The use of absolute value makes the condition symmetric. If $I$ is finite, the least admissible nonnegative bound is

$$
\Delta(d,e)=\max_{i,j\in I}|d(i,j)-e(i,j)|.
$$

### 2.2 Radius-parametrized Rips graphs

**Definition 2.2 (Rips edge relation).** Given a table $d$ and radius $r\in\mathbb{R}$, define

$$
i\sim_{d,r}j
\quad\Longleftrightarrow\quad
d(i,j)\le 2r.
$$

When $d$ is a metric and $r\ge0$, this is the edge relation of the Vietoris--Rips graph at radius $r$. The factor $2$ reflects a geometric radius interpretation: closed balls of radius $r$ centered at two points can meet only if their centers are at distance at most $2r$. Some literature uses a threshold parameter $t$ with edges satisfying $d(i,j)\le t$. All factors of $1/2$ below would disappear under that alternative parameterization.

Let $G_d(r)$ denote the graph with vertex set $I$ and edge relation $\sim_{d,r}$. Connectivity is the equivalence relation generated by the edges: two labels are equivalent if there is a finite edge path between them.

**Definition 2.3 (Zeroth Betti number).** If the set of connected components of $G_d(r)$ is finite, define

$$
\beta_0(d,r)=\#\pi_0(G_d(r)),
$$

where $\pi_0$ denotes the set of connected components.

### 2.3 Persistence points and finite diagrams

A birth--death point is a pair $p=(b,t)\in\mathbb{R}^2$. We use $b$ for birth and $t$ for death.

**Definition 2.4 (Diagram-point metric).** For $p=(b,t)$ and $q=(b',t')$, set

$$
d_\infty(p,q)=\max\{|b-b'|,|t-t'|\}.
$$

Let $K$ be a nonempty finite indexing set. A finite indexed diagram is a map $D:K\to\mathbb{R}^2$. This representation retains multiplicities because distinct indices may map to the same point.

**Definition 2.5 (Equal-cardinality finite bottleneck distance).** For diagrams $D,E:K\to\mathbb{R}^2$, define

$$
d_B^{\mathrm{fin}}(D,E)
=
\inf_{\sigma\in\operatorname{Bij}(K,K)}
\sup_{k\in K}d_\infty\bigl(D(k),E(\sigma(k))\bigr).
$$

Equivalently, it is the infimum of all $\varepsilon\ge0$ for which there is a bijection $\sigma:K\to K$ satisfying

$$
d_\infty\bigl(D(k),E(\sigma(k))\bigr)\le\varepsilon
$$

for every $k$. This is deliberately an equal-cardinality definition. The standard persistence-diagram distance permits matching to diagonal points with multiplicity; that extension is not assumed here.

## 3. Distortion and Rips interleavings

The first theorem converts metric error into a filtration shift.

**Theorem 3.1 (Forward Rips edge transport).** Suppose $d$ and $e$ satisfy

$$
|d(i,j)-e(i,j)|\le\delta
$$

for every $i,j\in I$. For every radius $r$ and every pair $i,j$,

$$
i\sim_{d,r}j
\quad\Longrightarrow\quad
i\sim_{e,r+\delta/2}j.
$$

**Proof sketch.** If $i\sim_{d,r}j$, then $d(i,j)\le2r$. The distortion hypothesis implies $e(i,j)-d(i,j)\le\delta$, so

$$
e(i,j)\le d(i,j)+\delta\le2r+\delta
=2\left(r+\frac{\delta}{2}\right).
$$

This is exactly the edge condition for $e$ at shifted radius $r+\delta/2$. $\square$

Because the distortion condition is symmetric, the reverse direction follows without a new hypothesis.

**Theorem 3.2 (Two-way Rips interleaving).** Under the hypotheses of Theorem 3.1, for every $r$,

$$
E(G_d(r))\subseteq E\!\left(G_e\left(r+\frac{\delta}{2}\right)\right)
$$

and

$$
E(G_e(r))\subseteq E\!\left(G_d\left(r+\frac{\delta}{2}\right)\right),
$$

where $E(G)$ denotes the edge set of a graph $G$.

**Proof sketch.** The first inclusion is Theorem 3.1. For the second, note that

$$
|e(i,j)-d(i,j)|=|d(i,j)-e(i,j)|\le\delta
$$

and apply the same argument with the tables exchanged. $\square$

The shift is dictated exactly by the edge convention. More generally, if edges appeared at $d(i,j)\le cr$ for some $c>0$, the same calculation would produce a shift $\delta/c$.

## 4. Stability of connected-component counts

The topological input is monotonicity under edge inclusion.

**Lemma 4.1 (Component monotonicity).** Let $G$ and $H$ be graphs on the same vertex set, with every edge of $G$ also an edge of $H$. If both component sets are finite, then

$$
\#\pi_0(H)\le\#\pi_0(G).
$$

**Proof sketch.** Every path in $G$ is also a path in $H$. Hence vertices connected in $G$ remain connected in $H$. Each $G$-component is contained in a unique $H$-component, producing a surjection from the set of $G$-components to the set of $H$-components. A surjection between finite sets cannot increase cardinality. $\square$

Combining Lemma 4.1 with the edge transport gives the rank-level stability statement.

**Theorem 4.2 (Zeroth-Betti stability step).** Suppose $d$ and $e$ have distortion at most $\delta$. If the relevant component sets are finite, then for every radius $r$,

$$
\beta_0\left(e,r+\frac{\delta}{2}\right)
\le
\beta_0(d,r).
$$

Similarly,

$$
\beta_0\left(d,r+\frac{\delta}{2}\right)
\le
\beta_0(e,r).
$$

**Proof sketch.** Theorem 3.1 includes every edge of $G_d(r)$ in $G_e(r+\delta/2)$. Apply Lemma 4.1. The symmetric inequality follows from the reverse arm of Theorem 3.2. $\square$

The theorem says that the two component-count curves cannot get ahead of each other by more than $\delta/2$ in radius. It is an order statement rather than a full diagram theorem, but it captures the core persistence behavior: bounded perturbations cannot make mergers occur arbitrarily earlier or later.

## 5. Explicit matchings and bottleneck bounds

The next result is elementary but central to usable certificates.

**Theorem 5.1 (Explicit matching bound).** Let $K$ be a nonempty finite set and let $D,E:K\to\mathbb{R}^2$ be finite indexed diagrams. Suppose $\varepsilon\ge0$ and there exists a bijection $\sigma:K\to K$ such that

$$
d_\infty\bigl(D(k),E(\sigma(k))\bigr)\le\varepsilon
$$

for every $k\in K$. Then

$$
d_B^{\mathrm{fin}}(D,E)\le\varepsilon.
$$

**Proof sketch.** The bottleneck distance is an infimum over the costs of all bijections. The stated $\sigma$ is one admissible bijection of cost at most $\varepsilon$. An infimum is no larger than any member of the set over which it is taken. $\square$

This theorem separates the mathematical guarantee from optimization. A minimum-cost matching can determine the exact finite bottleneck distance, but a known semantic correspondence may give a sufficient upper bound immediately.

## 6. Certified tree presentations of zeroth persistence

### 6.1 Tree-encoded diagrams

Connected-component persistence is naturally related to spanning trees. As a threshold increases, an edge matters to $H_0$ precisely when it joins two components that were previously distinct. A tree certificate records one such merger edge for each finite death.

Let $K$ be a nonempty finite set indexing certified tree edges, and let $w:K\to\mathbb{R}$ assign their weights.

**Definition 6.1 (Tree-encoded zeroth-persistence diagram).** The diagram associated with $w$ is

$$
D_w(k)=\left(0,\frac{w(k)}{2}\right).
$$

Every represented class is born at $0$, and the edge of length $w(k)$ appears at radius $w(k)/2$. This definition treats the weighted tree as a certificate supplied to the theorem. Establishing that a chosen algorithmic tree, such as a minimum spanning tree, realizes the complete $H_0$ persistence multiset for every finite pseudometric requires an additional combinatorial theorem.

### 6.2 Main stability theorem

**Theorem 6.2 (Stability of corresponding tree certificates).** Let $K$ be a nonempty finite set, and let $w,v:K\to\mathbb{R}$ be two families of corresponding tree-edge weights. Suppose $\delta\ge0$ and

$$
|w(k)-v(k)|\le\delta
$$

for every $k\in K$. Then

$$
d_B^{\mathrm{fin}}(D_w,D_v)\le\frac{\delta}{2}.
$$

**Proof sketch.** Match each edge label $k$ to itself. The birth coordinates of $D_w(k)$ and $D_v(k)$ are both $0$. Their death-coordinate discrepancy is

$$
\left|\frac{w(k)}{2}-\frac{v(k)}{2}\right|
=rac12|w(k)-v(k)|
\le\frac{\delta}{2}.
$$

Hence

$$
d_\infty(D_w(k),D_v(k))\le\frac{\delta}{2}
$$

for every $k$. The identity map on $K$ is a bijection, so Theorem 5.1 gives the conclusion. $\square$

The proof displays the full dependency chain. The factor $1/2$ first converts edge length into Rips radius, then passes unchanged through the $L^\infty$ metric and the bottleneck matching.

**Corollary 6.3 (Individual death-time stability).** Under the hypotheses of Theorem 6.2, every corresponding pair of represented finite death times differs by at most $\delta/2$.

**Proof sketch.** This is the pointwise inequality used in the proof of Theorem 6.2. $\square$

**Corollary 6.4 (Noise tolerance for a certified merger hierarchy).** If each edge weight in a certified merger tree is measured with absolute error at most $\eta$, then comparing the measured tree to the true tree under the same edge correspondence gives bottleneck error at most $\eta/2$.

**Proof sketch.** Apply Theorem 6.2 with $\delta=\eta$. $\square$

## 7. Sharp two-point computation

The smallest nontrivial cloud demonstrates both the pipeline and sharpness.

Let $I=\{0,1\}$. For a real parameter $s$, define

$$
d_s(i,j)=
\begin{cases}
0,&i=j,\\
s,&i\ne j.
\end{cases}
$$

Consider $d_2$ and $d_3$. On the diagonal, the discrepancy is $0$. Off the diagonal, it is

$$
|2-3|=1.
$$

Therefore the uniform distortion is exactly $1$.

**Proposition 7.1 (Two-point distortion).** The two distance tables $d_2$ and $d_3$ have distortion at most $1$, and this bound is attained on the pair of distinct labels.

**Proof sketch.** There are four ordered pairs. Two diagonal pairs have discrepancy $0$; the two off-diagonal pairs have discrepancy $1$. Thus the maximum is exactly $1$. $\square$

Each cloud has one merger edge. Under the radius convention, the finite $H_0$ death time for $d_s$ is $s/2$. Hence the diagrams each have one finite point:

$$
D_2=\{(0,1)\},
\qquad
D_3=\left\{\left(0,\frac32\right)\right\}.
$$

**Proposition 7.2 (Two-point persistence bound and equality).** The finite bottleneck distance between $D_2$ and $D_3$ is $1/2$.

**Proof sketch.** Since each diagram has one point, only one bijection exists. Its cost is

$$
\max\left\{|0-0|,\left|1-\frac32\right|\right\}=\frac12.
$$

Thus the infimum over bijections is $1/2$. Theorem 6.2 gives the upper bound $1/2$ from distortion $1$, so equality holds. $\square$

This equality proves that no universal estimate smaller than $\delta/2$ is possible under the present assumptions and parameter convention.

## 8. Algorithms and numerical realization

### 8.1 Distortion computation

For two $n\times n$ distance matrices $D$ and $E$ with common ordering, compute

$$
\Delta=\max_{0\le i,j<n}|D_{ij}-E_{ij}|.
$$

A double loop requires $O(n^2)$ time and $O(1)$ auxiliary memory beyond the matrices. The value $\Delta/2$ is the interleaving shift certified by Theorem 3.2.

### 8.2 Rips graph construction and component counting

At radius $r$, inspect each unordered pair and add an edge when $D_{ij}\le2r$. Connected components can be tracked by disjoint-set union. With path compression and union by rank, processing all pairs takes $O(n^2\alpha(n))$ time, where $\alpha$ is the inverse Ackermann function, and $O(n)$ auxiliary memory.

To numerically check Theorem 4.2, compute components for $D$ at $r$ and for $E$ at $r+\Delta/2$, then verify that the latter count is no larger than the former. Repeat with the tables exchanged.

### 8.3 Tree-diagram certificate

Given corresponding weight arrays $w=(w_1,\ldots,w_m)$ and $v=(v_1,\ldots,v_m)$, define points $(0,w_k/2)$ and $(0,v_k/2)$. Under the identity matching, the maximum cost is

$$
C=\frac12\max_k|w_k-v_k|.
$$

This takes $O(m)$ time and $O(m)$ output space, or $O(1)$ additional space if only the bound is required. Theorem 6.2 identifies $C$ as a valid finite bottleneck upper bound. It need not be the optimal bottleneck value when another permutation matches the points more cheaply, but it is exact whenever the identity correspondence is forced, as in the one-edge example.

### 8.4 Exact equal-cardinality bottleneck matching

For completeness, exact finite bottleneck distance can be computed from a cost matrix. For each candidate threshold $\varepsilon$ among the finitely many pairwise point distances, form a bipartite graph connecting $D_i$ to $E_j$ when their cost is at most $\varepsilon$. A threshold is feasible exactly when this graph has a perfect matching. Binary search over sorted candidate costs, combined with a bipartite matching algorithm, yields the optimum. With a straightforward augmenting-path implementation, the complexity is polynomial; more refined matching algorithms improve the asymptotic bound. This optimization is not needed for the explicit certificate theorem.

## 9. Applications, interpretation, and limitations

### 9.1 Single-linkage clustering

Zeroth Rips persistence and single-linkage clustering encode the same merger phenomenon under a change of scale. A component merge at edge threshold $a$ occurs at Rips radius $a/2$. Therefore Theorem 6.2 can be read as stability of corresponding dendrogram merge heights: perturbing certified linkage lengths by at most $\delta$ shifts radius-valued merge heights by at most $\delta/2$.

### 9.2 Sensor and communication networks

Suppose vertices are devices and an edge becomes viable when separation is at most twice a broadcast radius. If pairwise range estimates have uniform error $\delta$, then every connection available at radius $r$ in one model is available by radius $r+\delta/2$ in the other. Component counts provide a coarse but operational measure of network fragmentation. Theorem 4.2 bounds how uncertainty can shift that fragmentation curve.

### 9.3 Geometric data analysis

In a point cloud, long-lived $H_0$ classes indicate separated clusters. A stability certificate distinguishes structural separation from perturbations at the measurement scale. If a death time changes by much more than the certified $\delta/2$, then the change cannot be explained by the assumed corresponding-edge perturbation alone.

### 9.4 Relation to Gromov--Hausdorff geometry

For spaces without a prescribed common labeling, one compares points through a correspondence. The distortion of a correspondence is the supremum of pairwise distance discrepancies among related pairs. For compact metric spaces, Gromov--Hausdorff distance is one half of the infimum of correspondence distortions. This normalization aligns with the present Rips-radius shift.

However, the common-label edge interleaving proved here is not by itself the full Gromov--Hausdorff stability theorem. A correspondence may relate several points on one side to one point on the other; selecting representatives must induce coherent simplicial maps. Unequal numbers of finite classes require matching some persistence points to the diagonal. These are substantive additional steps.

### 9.5 Precise limitations

Four restrictions should be kept explicit.

First, the finite bottleneck definition used here compares diagrams indexed by the same nonempty finite set. It does not include diagonal points or partial matchings.

Second, the tree theorem assumes a certified family of corresponding merger edges. It does not prove that arbitrary independently selected spanning trees admit the required edge correspondence.

Third, only degree-zero topology is treated. Higher-dimensional homology depends on simplices, boundary maps, and compatibility of induced maps, not merely on graph connectivity.

Fourth, no claim is made here for arbitrary compact metric spaces. Infinite filtrations and diagram existence require additional analytical and algebraic hypotheses.

Within these boundaries, the conclusions are exact and reusable: uniform distortion gives a two-way Rips edge shift; edge inclusion gives component monotonicity; explicit diagram matching gives a bottleneck bound; and corresponding tree weights yield the sharp half-distortion estimate.

## 10. Future work

A natural first extension is a diagonal-completed bottleneck theory for finite clouds of unequal cardinality. Unmatched finite classes should be assigned to the diagonal at a cost equal to half their lifetime, while correspondence fibers govern matched classes.

A second goal is a complete minimum-spanning-forest realization theorem for zeroth persistence in finite pseudometric spaces, including repeated weights and zero-distance identifications. Such a theorem would turn the present certified-tree result into a direct statement about a standard algorithm without assuming the tree representation as input.

Third, one can optimize over finite correspondences to obtain a Gromov--Hausdorff stability theorem and classify equality cases for two- and three-point spaces. The two-point example already shows that the normalization is sharp.

Fourth, higher-dimensional stability requires constructing simplicial maps from correspondence selections and proving that different choices are contiguous. Contiguity should remove noncanonicity by ensuring equality of induced maps on homology.

Finally, interval-valued distance data offer a practical direction. Pairwise lower and upper confidence bounds could generate lower and upper envelopes for component persistence, with bottleneck uncertainty controlled by the maximum interval width.

## 11. Conclusion

The stability mechanism for finite zeroth Vietoris--Rips persistence can be expressed as a short chain of transparent implications:

$$
\text{distance distortion}
\Longrightarrow
\text{Rips edge interleaving}
\Longrightarrow
\text{component monotonicity}
\Longrightarrow
\text{controlled merger times}
\Longrightarrow
\text{bottleneck bound}.
$$

With edges appearing at $d\le2r$, every additive distance error $\delta$ becomes a radius shift $\delta/2$. For corresponding weighted tree certificates, matching each edge to itself gives a finite bottleneck bound of exactly that size. Two points at separations $2$ and $3$ attain equality, so the constant cannot be improved in this framework.

The result is modest in scope but complete within its stated model. It identifies the quantitative heart of stability, supplies efficient numerical certificates, and clarifies the additional structures required for arbitrary finite clouds, Gromov--Hausdorff comparisons, and higher homology.