# Metric Stability and Exact Completion Thresholds for Rips Complexes of Finite Point Clouds

## Abstract

We develop a self-contained metric and combinatorial foundation for Poincaré-inspired manifold detection from finite data. For an indexed point cloud in a metric or pseudometric space, we define its scale-dependent Rips graph and flag complex. We prove monotonicity in scale, exact boundary behavior at nonpositive scales, and monotonicity of the edge-count profile. For two pointwise matched clouds whose corresponding observations differ by at most $\delta$, we establish a two-sided $2\delta$ interleaving of their Rips flag complexes; the same inclusion yields monotonicity of simplex counts under the translated scale. We then characterize the full-simplex transition exactly: at a nonnegative scale $\varepsilon$, the complex has all $2^n$ faces if and only if every pairwise distance is at most $\varepsilon$. Thus the first full-simplex scale is the sample diameter, not a homological sphere-recognition threshold. Exact samples on a sphere of radius $r$ become full by scale $2r$, while samples within radial error $\delta$ become full by scale $2(r+\delta)$. We also develop antitonic covering numbers and the maximal-packing-implies-cover principle. These results rigorously separate noise stability, diameter, packing, coverage, and topology. In particular, sphere homology alone does not imply geometric nearness to a sphere, and the commonly proposed $n^{-1/d}$ law describes a spacing scale more naturally than a uniform coverage scale, for which logarithmic corrections are expected under independent sampling.

## 1. Introduction

Topological data analysis seeks qualitative structure in finite metric data. A standard construction begins with a point cloud and joins pairs whose distance is below a scale parameter. As the scale grows, the resulting graphs and simplicial complexes form a filtration. Persistent homology then records the scales over which connected components, loops, voids, and higher-dimensional features survive.

A particularly appealing aspiration is a “Poincaré principle for data”: if a finite sample has the homological signature of a sphere over a suitable range of scales, perhaps it lies on or near a sphere. The classical three-dimensional Poincaré theorem, however, concerns closed simply connected manifolds, not arbitrary finite complexes or point clouds. Homology is weaker than homeomorphism, global invariants do not enforce local manifold structure, and a single Rips scale can be dominated by sampling artifacts. Any credible data-analytic analogue must therefore combine topology with quantitative geometry.

This paper establishes the metric part of that program and identifies an exact threshold that can otherwise be misinterpreted. The main conclusions are:

1. Rips graphs and their flag complexes grow monotonically with scale.
2. Pointwise perturbation by at most $\delta$ induces a two-sided interleaving after a scale translation of $2\delta$.
3. The full-simplex threshold is exactly the cloud diameter.
4. A sample on a sphere of radius $r$ is necessarily full by scale $2r$, and radial error $\delta$ changes this bound to $2(r+\delta)$.
5. Covering numbers decrease with radius, and an explicitly maximal separated subset is a cover.

The third point is a crucial negative clarification. A full simplex is contractible and contains no nontrivial reduced homology. Its appearance certifies only an all-pairs distance condition. It is not a sphere-recognition event. Similarly, sphere-like homology without density, reach, local link conditions, or simple connectivity cannot identify a sphere.

The presentation permits repeated observations by working initially in a pseudometric setting. When zero-scale emptiness is needed, we require a genuine metric. All finite-complex counts include the empty face.

## 2. Metric and combinatorial definitions

### 2.1. Indexed point clouds

Let $I$ be a finite index set of cardinality $n$, let $(M,d)$ be a pseudometric space, and let

$$
X:I\to M,
$$

be an indexed point cloud. Indexing permits repeated observations: distinct indices may represent the same location or have zero pseudodistance. When separation of distinct points is required, $M$ will be assumed to be a metric space.

### 2.2. Rips graphs and flag complexes

**Definition 2.1 (Rips graph).** For a real scale $\varepsilon$, the Rips graph $G_X(\varepsilon)$ has vertex set $I$. Distinct vertices $i$ and $j$ are adjacent exactly when

$$
d(X(i),X(j))\leq\varepsilon.
$$

**Definition 2.2 (Rips flag complex).** The Rips flag complex $K_X(\varepsilon)$ consists of all subsets $\sigma\subseteq I$ whose distinct vertices are pairwise adjacent in $G_X(\varepsilon)$. Equivalently,

$$
\sigma\in K_X(\varepsilon)
\quad\Longleftrightarrow\quad
\forall i,j\in\sigma,\ d(X(i),X(j))\leq\varepsilon.
$$

The empty set and every singleton are faces. If the graph is complete, every subset of $I$ is a face, so $K_X(\varepsilon)$ is the full simplex and has $2^n$ faces.

### 2.3. Filtrations

**Definition 2.3 (Metric graph filtration).** A metric graph filtration on a vertex set is a family $F(\varepsilon)$ of graphs indexed by $\varepsilon\in\mathbb R$ such that $F(\varepsilon)\subseteq F(\eta)$ whenever $\varepsilon\leq\eta$, and $F(\varepsilon)$ is empty for every $\varepsilon<0$.

The Rips graph family is the canonical example. More generally, the scale parameter can belong to any preordered set; only monotonicity is essential to the abstract notion of filtration.

### 2.4. Edge and simplex profiles

For a finite metric space and integer $r\geq0$, define the **edge-count profile**

$$
E_X(r)=\#\{\{i,j\}:i\neq j,\ d(X(i),X(j))\leq r\}.
$$

Also define the **simplex-count profile**

$$
S_X(\varepsilon)=\#K_X(\varepsilon).
$$

The latter counts faces of every dimension, including the empty face.

### 2.5. Covers and packings

Let $S$ be a finite subset of a pseudometric space.

**Definition 2.4 ($\varepsilon$-cover).** A finite set $C$ is an $\varepsilon$-cover of $S$ if every $x\in S$ lies within distance $\varepsilon$ of some $c\in C$:

$$
\forall x\in S,\ \exists c\in C,\ d(x,c)\leq\varepsilon.
$$

The centers need not be required to lie in $S$ for this definition, although many algorithms choose them from $S$.

**Definition 2.5 (Covering number).** The covering number $N(S,\varepsilon)$ is the minimum cardinality of a finite $\varepsilon$-cover of $S$.

**Definition 2.6 ($\varepsilon$-packing).** A subset $P\subseteq S$ is an $\varepsilon$-packing if distinct $p,q\in P$ satisfy

$$
d(p,q)>\varepsilon.
$$

We will use an explicit maximality condition: every $x\in S\setminus P$ lies within $\varepsilon$ of some $p\in P$. This is exactly the condition produced when a greedy packing procedure terminates.

### 2.6. Exact and approximate spheres

Let $M$ be a normed real vector space, $c\in M$, and $r\geq0$.

**Definition 2.7 (Spherical sample).** The cloud $X$ lies on the sphere of center $c$ and radius $r$ if

$$
d(X(i),c)=r
$$

for every $i\in I$.

**Definition 2.8 (Approximately spherical sample).** For $\delta\geq0$, the cloud is $\delta$-approximately spherical about $c$ with radius $r$ if

$$
\left|d(X(i),c)-r\right|\leq\delta
$$

for every $i\in I$.

## 3. Filtration and counting results

**Theorem 3.1 (Rips filtration monotonicity).** Let $X:I\to M$ be an indexed cloud in a pseudometric space. If $\varepsilon\leq\eta$, then

$$
G_X(\varepsilon)\subseteq G_X(\eta)
\quad\text{and}\quad
K_X(\varepsilon)\subseteq K_X(\eta).
$$

**Proof sketch.** An edge at scale $\varepsilon$ satisfies $d(X(i),X(j))\leq\varepsilon\leq\eta$, so it remains an edge at scale $\eta$. A face is a clique, and preservation of all its edges preserves the face. $\square$

**Proposition 3.2 (Boundary behavior).** In a pseudometric space, $G_X(\varepsilon)$ is empty for every $\varepsilon<0$. In a metric space, $G_X(0)$ is empty as well.

**Proof sketch.** Distances are nonnegative, so no distance can be at most a negative number. At scale zero, adjacency of distinct points would require distance zero. This is impossible in a metric space but may occur in a pseudometric space. $\square$

**Corollary 3.3 (Monotone edge-count profile).** For a finite metric cloud, $E_X(r)$ is nondecreasing in the integer scale $r$, satisfies $E_X(0)=0$, and is bounded above by the number of unordered pairs of indices.

**Proof sketch.** Graph inclusion induces inclusion of edge sets. The zero statement follows from Proposition 3.2, and every edge is an unordered pair. $\square$

The same argument proves that $S_X(\varepsilon)$ is nondecreasing. Unlike homology ranks, which can rise and fall as cycles are born and filled, raw edge and simplex counts only increase.

## 4. Stability under matched perturbations

Assume that two clouds $X,Y:I\to M$ use the same finite index set and satisfy

$$
d(X(i),Y(i))\leq\delta
$$

for every $i\in I$. This pointwise matching is stronger than a Hausdorff-distance hypothesis because it identifies which observation corresponds to which.

**Theorem 4.1 (Graph stability under pointwise perturbation).** For every real $\varepsilon$,

$$
G_X(\varepsilon)\subseteq G_Y(\varepsilon+2\delta).
$$

**Proof sketch.** If $i$ and $j$ are adjacent in $G_X(\varepsilon)$, the triangle inequality along the chain $Y(i),X(i),X(j),Y(j)$ gives

$$
\begin{aligned}
d(Y(i),Y(j))
&\leq d(Y(i),X(i))+d(X(i),X(j))+d(X(j),Y(j))\\
&\leq\delta+\varepsilon+\delta.
\end{aligned}
$$

Distinctness is a property of the indices, so the corresponding edge belongs to $G_Y(\varepsilon+2\delta)$. $\square$

**Theorem 4.2 (Rips-complex perturbation interleaving).** Under the same hypothesis, for every $\varepsilon$,

$$
K_X(\varepsilon)\subseteq K_Y(\varepsilon+2\delta)
$$

and

$$
K_Y(\varepsilon)\subseteq K_X(\varepsilon+2\delta).
$$

**Proof sketch.** The first inclusion follows from Theorem 4.1 because every edge of every clique is preserved after translation. For the second, symmetry of distance gives $d(Y(i),X(i))\leq\delta$, so the same argument applies with $X$ and $Y$ exchanged. $\square$

**Corollary 4.3 (Simplex-count stability).** For every $\varepsilon$,

$$
S_X(\varepsilon)\leq S_Y(\varepsilon+2\delta)
$$

and, symmetrically,

$$
S_Y(\varepsilon)\leq S_X(\varepsilon+2\delta).
$$

**Proof sketch.** Inclusion between finite sets of faces implies the corresponding cardinality inequality. $\square$

**Remark 4.4 (Sharpness of the translation).** The factor $2$ is optimal for a uniform theorem of this kind. Take two points at distance $\varepsilon$ on a line and move each outward by $\delta$. Their distance becomes $\varepsilon+2\delta$. Any smaller universal translation would fail to preserve this edge.

Theorem 4.2 is a filtration-level statement. Applying homology functorially is expected to produce an analogous interleaving of persistent homology modules, provided the connecting maps and coefficient choices are fixed. For unmatched clouds, correspondences of controlled distortion are the natural generalization.

## 5. Exact characterization of the full-simplex threshold

Define the diameter of the indexed cloud by

$$
\operatorname{diam}(X)=\max_{i,j\in I}d(X(i),X(j)),
$$

with the usual harmless convention for an empty cloud. For nonempty finite clouds the maximum exists.

**Theorem 5.1 (Full-simplex criterion).** Let $\varepsilon\geq0$. For a cloud with $n$ indexed observations, the following are equivalent:

1. $K_X(\varepsilon)$ has exactly $2^n$ faces.
2. $K_X(\varepsilon)$ is the full simplex on $I$.
3. Every pair satisfies $d(X(i),X(j))\leq\varepsilon$.

**Proof sketch.** There are exactly $2^n$ subsets of an $n$-element index set, and the faces of a flag complex form a subset of this power set. Hence cardinality $2^n$ means every subset is a face. In particular, every two-element subset is an edge, yielding the all-pairs inequality. Conversely, if all pairs satisfy the inequality, every subset is a clique and hence a face. The nonnegative-scale condition ensures diagonal distances are also beneath the threshold when the all-pairs statement includes $i=j$. $\square$

**Corollary 5.2 (Strict deficit below a witnessed distance).** If $\varepsilon\geq0$ and there exist indices $i,j$ with

$$
\varepsilon<d(X(i),X(j)),
$$

then

$$
S_X(\varepsilon)<2^n.
$$

**Proof sketch.** The pair $\{i,j\}$ is not a face, so the complex omits at least one subset of $I$. $\square$

**Corollary 5.3 (Diameter threshold).** For a nonempty finite cloud, the smallest nonnegative scale at which its Rips flag complex is the full simplex is exactly $\operatorname{diam}(X)$.

**Proof sketch.** Theorem 5.1 says fullness is equivalent to $\varepsilon$ dominating every pairwise distance, which is equivalent to $\varepsilon\geq\operatorname{diam}(X)$. $\square$

**Example 5.4 (A sharp two-point transition).** Consider points at $0$ and $2$ in $\mathbb R$. At scale $1$, the two-point subset is absent, so the complex has strictly fewer than $4$ faces. At scale $2$, all subsets are faces and the count is $2^2=4$.

**Interpretive consequence.** The diameter threshold is not a sphere-detection threshold. The full simplex is contractible, regardless of whether the original cloud sampled a sphere, a ball, a curve, or an arbitrary bounded set. It is the terminal combinatorial phase of every finite Rips filtration.

## 6. Spherical and approximately spherical clouds

**Theorem 6.1 (Spherical diameter bound).** Suppose $X$ lies on a sphere of center $c$ and radius $r\geq0$. Then, for every $i,j$,

$$
d(X(i),X(j))\leq2r.
$$

**Proof sketch.** By the triangle inequality through the center,

$$
d(X(i),X(j))\leq d(X(i),c)+d(c,X(j))=r+r.
$$

Antipodal points show that the constant $2$ is sharp. $\square$

**Corollary 6.2 (Spherical completion bound).** A finite sample of $n$ points on a sphere of radius $r$ has

$$
S_X(2r)=2^n.
$$

**Proof sketch.** Theorem 6.1 supplies the all-pairs condition at scale $2r$, and Theorem 5.1 supplies fullness. $\square$

The conclusion is an upper bound: a particular sample may have diameter strictly below $2r$ if it contains no nearly antipodal pair, and then it becomes full earlier.

**Theorem 6.3 (Radial stability under perturbation).** Let $X$ lie exactly on the sphere of center $c$ and radius $r$. If $d(X(i),Y(i))\leq\delta$ for every $i$, then $Y$ is $\delta$-approximately spherical about the same $c$ and $r$:

$$
\left|d(Y(i),c)-r\right|\leq\delta.
$$

**Proof sketch.** Substitute $r=d(X(i),c)$ and apply the reverse triangle inequality

$$
\left|d(Y(i),c)-d(X(i),c)\right|\leq d(Y(i),X(i)).
$$

$\square$

**Theorem 6.4 (Approximate spherical completion bound).** Suppose $r,\delta\geq0$ and

$$
\left|d(X(i),c)-r\right|\leq\delta
$$

for every $i$. Then

$$
S_X\bigl(2(r+\delta)\bigr)=2^n.
$$

**Proof sketch.** The radial condition gives $d(X(i),c)\leq r+\delta$. Hence

$$
d(X(i),X(j))\leq d(X(i),c)+d(c,X(j))\leq2(r+\delta).
$$

The full-simplex criterion completes the argument. $\square$

These theorems are geometric rather than homological. Their converses are false: a diameter bound does not force points to occupy a thin spherical shell, and approximate radial fit does not ensure uniform angular coverage.

## 7. Covering complexity and packing-covering duality

**Proposition 7.1 (Self-cover bound).** If $\varepsilon\geq0$, then $S$ covers itself at radius $\varepsilon$, and therefore

$$
N(S,\varepsilon)\leq\#S.
$$

For the empty set, $N(\varnothing,\varepsilon)=0$ at every scale. For a singleton, $N(S,\varepsilon)\leq1$ at every nonnegative scale.

**Proof sketch.** Every point is distance zero from itself, and $0\leq\varepsilon$. The boundary statements follow directly. $\square$

**Theorem 7.2 (Antitonicity of covering numbers).** If $0\leq\varepsilon_1\leq\varepsilon_2$, then

$$
N(S,\varepsilon_2)\leq N(S,\varepsilon_1).
$$

**Proof sketch.** Every $\varepsilon_1$-cover is also an $\varepsilon_2$-cover because each distance bound $d(x,c)\leq\varepsilon_1$ implies $d(x,c)\leq\varepsilon_2$. Minimizing over the larger class of admissible covers cannot increase cardinality. $\square$

**Theorem 7.3 (Maximal packing is a cover).** Let $P\subseteq S$ be an $\varepsilon$-packing with $\varepsilon\geq0$. Assume explicitly that every $x\in S\setminus P$ has some $p\in P$ with $d(x,p)\leq\varepsilon$. Then $P$ is an $\varepsilon$-cover of $S$.

**Proof sketch.** If $x\in P$, choose $p=x$ and use $d(x,x)=0\leq\varepsilon$. If $x\notin P$, use the stated maximality condition. $\square$

The theorem motivates a greedy procedure. Start with $P=\varnothing$. While some data point lies farther than $\varepsilon$ from every selected point, add it to $P$. Each new point is more than $\varepsilon$ from previous selections, so $P$ remains a packing. On termination, every point lies within $\varepsilon$ of $P$, so it is a cover. With a precomputed $n\times n$ distance matrix, a direct implementation costs $O(n^2)$ time and $O(n^2)$ memory; distances can instead be computed on demand using $O(n)$ auxiliary memory.

## 8. Computational algorithms

### 8.1. Rips profile sweep

Given an $n\times n$ distance matrix and sorted scales $\varepsilon_1\leq\cdots\leq\varepsilon_m$, one may compute edge counts by sorting the $n(n-1)/2$ pairwise distances and advancing a pointer through them. Sorting costs $O(n^2\log n)$ time, and the scale sweep costs $O(m+n^2)$. Materializing all faces is exponential in $n$ in the full-simplex regime, so practical systems enumerate only low-dimensional simplices or compute homology with dedicated reductions.

The exact terminal threshold requires no simplex enumeration: it is simply the largest pairwise distance, computable in $O(n^2)$ time and $O(1)$ extra memory when distances are streamed.

### 8.2. Perturbation audit

For matched clouds, calculate

$$
\widehat\delta=\max_i d(X(i),Y(i)).
$$

For each tested scale $\varepsilon$, compare the edge set of $X$ at $\varepsilon$ with that of $Y$ at $\varepsilon+2\widehat\delta$, and reverse the roles. Theorem 4.2 guarantees both inclusions up to floating-point tolerance. A failed audit therefore indicates a mismatch of indices, inconsistent metrics, or numerical error rather than a geometric counterexample.

### 8.3. Greedy packing cover

The greedy maximal-packing algorithm selects a representative, marks every point within $\varepsilon$ as covered, and repeats. The resulting centers provide both separated landmarks and a certificate of coverage of the observed sample. They do not, without additional assumptions, certify coverage of an unknown continuum from which the sample was drawn.

## 9. Applications and interpretation

### 9.1. Sensor and imaging robustness

The $2\delta$ law translates localization error into scale uncertainty. If each sensor location is known within $\delta$, features seen at scale $\varepsilon$ in one matched realization must be represented simplicially by scale $\varepsilon+2\delta$ in another. This offers a principled margin for comparing scans, trajectories, or embedded feature vectors.

### 9.2. Spherical model diagnostics

A proposed spherical model can be assessed in three distinct ways:

1. **Radial residual:** estimate a center $c$ and radius $r$, then evaluate $\max_i|d(X(i),c)-r|$.
2. **Coverage:** evaluate angular or intrinsic coverage, possibly through a net or covering-radius estimate.
3. **Topology:** search for a scale interval with the desired homological signature, avoiding both the disconnected small-scale phase and the contractible full-simplex phase.

The bound $2(r+\delta)$ predicts only when completion must have occurred. It is a useful consistency check, not a positive detector.

### 9.3. Distinguishing three scales

Three scales should not be conflated:

- the **spacing scale**, describing typical nearest-neighbor distances;
- the **coverage scale**, describing the largest unsampled region;
- the **diameter scale**, at which the Rips complex becomes full.

For $n$ reasonably uniform points on a $d$-dimensional object, a typical spacing scale is often proportional to $n^{-1/d}$. Uniform random coverage is governed by extreme gaps and is therefore commonly expected at order

$$
\left(\frac{\log n}{n}\right)^{1/d}.
$$

The diameter of a unit sphere sample remains of constant order and approaches $2$ when nearly antipodal observations occur. These are different phase transitions with different statistical meanings.

## 10. Limitations of homological sphere recognition

Suppose a Rips complex has the same homology as a $d$-sphere: one connected component, one top-dimensional class, and no intermediate homology. This statement alone does not imply that the cloud lies near a geometric sphere. Several obstructions remain.

First, homology does not determine homotopy type or homeomorphism type. Second, an arbitrary flag complex may have singular vertex links and fail to be a manifold. Third, the ambient Euclidean dimension and the intrinsic sphere dimension are different quantities. Fourth, a sparse or nonuniform sample can create accidental cycles at one scale. Fifth, the full-simplex phase erases all reduced homology and must not be mistaken for successful recognition.

A credible sphere-recognition theorem should impose quantitative sampling hypotheses, such as small Hausdorff distance from a compact manifold with positive reach; identify a nonempty scale interval on which the complex recovers the manifold’s homotopy type; verify local manifold structure through vertex links or related conditions; and, in dimension three, supplement homology with a computable simple-connectivity certificate. The classical Poincaré conclusion becomes relevant only after the object has genuinely been certified as a closed three-manifold.

## 11. Discussion

The results establish a compact metric-combinatorial core. Monotonicity expresses the order structure of scale. Perturbation stability follows from a four-point triangle inequality and propagates from edges to cliques. Fullness reduces exactly to an all-pairs condition. Spherical completion follows from passing through the center. Covering antitonicity and packing-covering duality capture the complementary geometry of sampling density.

The framework deliberately avoids an unsupported implication from homology to geometric nearness. Its value lies partly in this separation. If an empirical “Poincaré threshold” is reported, one should ask which event defines it. Is it the first scale with sphere-like Betti numbers, the beginning of a persistent interval, the coverage radius, or the diameter? Only the last of these is characterized by the full-simplex theorem, and only the matched-noise shift has the universal $2\delta$ guarantee proved here.

## 12. Future work

The next theoretical step is a quantitative homotopy-recovery theorem under reach and density assumptions, with explicit endpoints separating sampling error from geometric regularity. A probabilistic analysis should determine tail bounds for coverage on spheres and clarify when $n^{-1/d}$ rather than $(\log n/n)^{1/d}$ is the appropriate rate. Matched perturbations should be generalized to metric correspondences of bounded distortion, leading naturally to Gromov–Hausdorff stability. Finally, global homology should be combined with local-link tests, discrete curvature or expansion conditions, and simple connectivity to formulate a genuine finite certificate of spherical manifold structure.

## 13. Conclusion

Finite Rips complexes provide a powerful bridge from distance data to topology, but their thresholds must be interpreted precisely. The filtration is monotone; pointwise noise of size $\delta$ shifts it by at most $2\delta$; and the full-simplex threshold is exactly the sample diameter. Exact and approximate spherical samples satisfy corresponding completion bounds of $2r$ and $2(r+\delta)$. Covering and packing results quantify another essential ingredient: whether the data are sufficiently distributed to represent an underlying space. Together these statements define the reliable foundation on which a future Poincaré-style theorem for data would have to stand.