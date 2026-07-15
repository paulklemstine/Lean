# Equivariant Simplicial Maps Between Cross-Polytope Spheres: Coordinate Classification, Coindex, and Suspension

## Abstract

We give a self-contained classification of antipode-preserving simplicial maps between boundaries of cross-polytopes. The boundary of the $(n+1)$-dimensional cross-polytope is modeled by signed coordinate vertices $(i,\varepsilon)$, with antipodal involution $(i,\varepsilon)\mapsto(i,-\varepsilon)$, and with simplices characterized by the absence of antipodal pairs. Equivariance reduces a vertex map to its values on positive source vertices. We prove that the induced equivariant map is simplicial if and only if the resulting map of coordinate axes is injective; sign choices are unrestricted. Consequently, an equivariant simplicial map from the $m$-dimensional cross-polytope sphere to the $n$-dimensional cross-polytope sphere exists exactly when $m\le n$. This yields an all-dimensional finite Borsuk–Ulam obstruction, identifies the $\mathbb Z_2$-coindex of each cross-polytope sphere with its dimension, and proves that suspension preserves map existence in both directions and raises coindex by exactly one. We also present constructive algorithms for map generation and validation, discuss their complexity, and describe applications to certificates of nonexistence, map enumeration, symmetry, joins, and finite models of equivariant topology.

## 1. Introduction

The Borsuk–Ulam principle expresses a fundamental limitation on antipode-sensitive dimension reduction. In a standard continuous formulation, every continuous map from an $n$-sphere to $\mathbb R^n$ identifies some antipodal pair. An equivalent equivariant perspective rules out antipode-preserving maps from a higher-dimensional sphere to a lower-dimensional one. Although such statements are topological, certain triangulated spheres expose a purely finite mechanism beneath the obstruction.

The relevant family consists of boundaries of cross-polytopes. An $(n+1)$-dimensional cross-polytope has vertices $\pm e_0,\ldots,\pm e_n$. Its boundary is an $n$-sphere equipped with a free involution exchanging opposite vertices. Its combinatorics is unusually transparent: a collection of vertices forms a simplex precisely when it does not contain both signs of any coordinate axis.

This paper studies equivariant simplicial maps between these boundaries. Our central result is a local-to-global reduction. Once equivariance is imposed, the map is determined by the images of positive source vertices. Each such image chooses a target coordinate and a target sign. We show that simpliciality is equivalent to injectivity of the coordinate choices. If two source axes collide, appropriate source signs produce a non-antipodal pair whose images are antipodal. If the coordinate choices are injective, every antipodal image pair must have originated from an antipodal source pair.

This characterization immediately converts map existence into a cardinality comparison. There are $m+1$ axes in the source and $n+1$ in the target, so a map exists if and only if $m\le n$. The same criterion simultaneously supplies a constructive inclusion below the dimension threshold and a pigeonhole obstruction above it. It also makes suspension exact: adding one source axis and one target axis preserves the defining inequality.

The results are finite, explicit, and algorithmic. A proposed map can be validated by duplicate detection among target coordinate labels. A valid map can be constructed in linear time whenever the dimension inequality holds. A failed candidate carries a concrete collision witness. These features make cross-polytope spheres a useful laboratory for the interaction of equivariant topology, combinatorics, and computation.

## 2. Cross-polytope spheres and equivariant maps

### 2.1. The signed-coordinate complex

Fix $n\ge0$. Let

$$
V_n=\{0,1,\ldots,n\}\times\{+1,-1\}.
$$

The first component is called the **coordinate axis**, and the second is called the **sign**. Define the antipodal involution $\alpha_n:V_n\to V_n$ by

$$
\alpha_n(i,\varepsilon)=(i,-\varepsilon).
$$

The **$n$-dimensional cross-polytope sphere**, denoted $C_n$, is the abstract simplicial complex with vertex set $V_n$ in which a finite set $F\subseteq V_n$ is a simplex if and only if it contains no antipodal pair. Equivalently,

$$
(i,+1)\in F\quad\Longrightarrow\quad(i,-1)\notin F
$$

for every coordinate $i$. This complex is the boundary of the convex hull of $\pm e_0,\ldots,\pm e_n$ in $\mathbb R^{n+1}$ and is homeomorphic to $S^n$.

The involution is free on vertices and extends simplicially to $C_n$. We use the signed-coordinate model throughout; no geometric realization is needed for the classification.

### 2.2. Equivariance and simpliciality

A vertex map $f:V_m\to V_n$ is **equivariant** if

$$
f\bigl(\alpha_m(v)\bigr)=\alpha_n\bigl(f(v)\bigr)
$$

for every $v\in V_m$. It is **simplicial** if the image of every simplex of $C_m$ is a simplex of $C_n$. An **equivariant simplicial map** $C_m\to C_n$ is a vertex map satisfying both conditions.

Because the complexes are defined by forbidden antipodal pairs, simpliciality has a pairwise formulation.

**Lemma 2.1 (Pairwise simpliciality criterion).** An equivariant vertex map $f:V_m\to V_n$ is simplicial if and only if, whenever $f(p)=\alpha_n(f(q))$, one has $p=\alpha_m(q)$.

**Proof sketch.** If non-antipodal vertices $p$ and $q$ have antipodal images, then $\{p,q\}$ is a source edge while its image is not a target simplex, so $f$ is not simplicial. Conversely, if a source simplex has a nonsimplicial image, that image contains an antipodal pair $f(p),f(q)$. The stated implication says $p,q$ were antipodal, contradicting the assumption that the source set was a simplex. $\square$

### 2.3. Positive-vertex data

Write the positive source vertex on axis $i$ as $(i,+1)$. Any equivariant map is determined by a function

$$
g:\{0,\ldots,m\}\to V_n,
$$

where $g(i)=f(i,+1)$. If

$$
g(i)=\bigl(a(i),\sigma(i)\bigr),
$$

then equivariance forces

$$
f(i,\varepsilon)=\bigl(a(i),\varepsilon\sigma(i)\bigr).
$$

Here

$$
a:\{0,\ldots,m\}\to\{0,\ldots,n\}
$$

is the **coordinate map**, while

$$
\sigma:\{0,\ldots,m\}\to\{+1,-1\}
$$

is the **sign assignment**. Every pair $(a,\sigma)$ defines an equivariant vertex map by the displayed formula. The remaining question is exactly which coordinate and sign data yield a simplicial map.

## 3. The coordinate-axis classification

The key theorem shows that signs play no role in the existence obstruction.

**Theorem 3.1 (Coordinate-Axis Theorem).** Let $f:V_m\to V_n$ be the equivariant vertex map determined by coordinate data $a$ and sign data $\sigma$. Then $f$ is simplicial if and only if $a$ is injective.

**Proof.** First suppose $f$ is simplicial, and assume $a(i)=a(j)$. We prove $i=j$. If $\sigma(i)\ne\sigma(j)$, then

$$
f(i,+1)=\alpha_n\bigl(f(j,+1)\bigr).
$$

By Lemma 2.1, $(i,+1)$ and $(j,+1)$ must be antipodal. Antipodal vertices have the same coordinate and opposite signs, which here forces $i=j$ but would also require $+1=-1$; equivalently, for distinct $i$ and $j$ this is an immediate contradiction. If instead $\sigma(i)=\sigma(j)$, compare $(i,+1)$ with $(j,-1)$. Equivariance gives

$$
f(i,+1)=\alpha_n\bigl(f(j,-1)\bigr).
$$

Lemma 2.1 then forces $(i,+1)=\alpha_m(j,-1)=(j,+1)$, hence $i=j$. Thus $a$ is injective.

Conversely, assume $a$ is injective and suppose

$$
f(i,\varepsilon)=\alpha_n\bigl(f(j,\delta)\bigr).
$$

Antipodal target vertices have the same coordinate, so $a(i)=a(j)$. Injectivity gives $i=j$. Using the explicit formula for $f$, equality with the antipode then implies

$$
\varepsilon\sigma(i)=-\delta\sigma(i),
$$

and cancellation of $\sigma(i)\in\{+1,-1\}$ yields $\varepsilon=-\delta$. Hence $(i,\varepsilon)=\alpha_m(j,\delta)$. Lemma 2.1 now shows that $f$ is simplicial. $\square$

The proof identifies the precise obstruction. A collision $a(i)=a(j)$ can always be exposed by choosing either equal source signs or opposite source signs according to whether $\sigma(i)$ and $\sigma(j)$ disagree or agree. Conversely, coordinate injectivity ensures that antipodal target images can only arise on one source axis, where equivariance controls the signs exactly.

**Corollary 3.2 (Freedom of signs).** Fix an injective coordinate map $a$. Every sign assignment $\sigma$ produces an equivariant simplicial map. Thus signs distinguish maps but do not affect whether maps exist.

**Proof sketch.** The coordinate map remains injective for every $\sigma$, so Theorem 3.1 applies. $\square$

## 4. Exact existence and the finite Borsuk–Ulam obstruction

We now obtain the complete numerical classification.

**Theorem 4.1 (Exact Existence Classification).** For all $m,n\ge0$, an equivariant simplicial map $C_m\to C_n$ exists if and only if

$$
m\le n.
$$

**Proof.** If such a map exists, Theorem 3.1 gives an injection from the $m+1$ source axes to the $n+1$ target axes. Therefore

$$
m+1\le n+1,
$$

and hence $m\le n$.

For the converse, suppose $m\le n$. Define

$$
f(i,\varepsilon)=(i,\varepsilon)
$$

for $0\le i\le m$. This is the standard equatorial inclusion. Its coordinate map $a(i)=i$ is injective, so Theorem 3.1 proves that $f$ is equivariant and simplicial. $\square$

This theorem has a direct Borsuk–Ulam consequence.

**Corollary 4.2 (All-Dimensional Finite Borsuk–Ulam Theorem).** For every $n\ge0$, there is no equivariant simplicial map

$$
C_{n+1}\longrightarrow C_n.
$$

**Proof.** Such a map would exist only if $n+1\le n$, by Theorem 4.1, which is impossible. Equivalently, it would induce an injection of $n+2$ axes into $n+1$ axes. $\square$

The low-dimensional cases recover familiar pictures. No antipode-preserving simplicial map sends the four-cycle $C_1$ to the two-point sphere $C_0$. Likewise, no such map sends the octahedral sphere $C_2$ to the four-cycle $C_1$. The proof does not rely on separate finite checks; it identifies one uniform obstruction in all dimensions.

**Corollary 4.3 (Collision certificate).** If $m>n$, every equivariant vertex map $V_m\to V_n$ has two distinct source axes with the same target coordinate. Those axes, together with an appropriate choice of source signs, form a non-antipodal pair whose images are antipodal.

**Proof sketch.** The pigeonhole principle supplies the coordinate collision. The two-case argument in the forward direction of Theorem 3.1 constructs the required signs. $\square$

This corollary strengthens a bare nonexistence statement by producing a local witness of failure.

## 5. Coindex and sharpness

For the present family, define the **$\mathbb Z_2$-coindex** of $C_n$ by

$$
\operatorname{coind}(C_n)=\max\{m\ge0:\text{an equivariant simplicial map }C_m\to C_n\text{ exists}\}.
$$

The set is nonempty because $C_0$ includes equivariantly into every $C_n$, and it is bounded by Theorem 4.1.

**Theorem 5.1 (Exact Coindex).** For every $n\ge0$,

$$
\operatorname{coind}(C_n)=n.
$$

**Proof.** The identity map shows that $C_n\to C_n$ exists, so $\operatorname{coind}(C_n)\ge n$. Corollary 4.2 rules out a map $C_{n+1}\to C_n$, and Theorem 4.1 rules out every still larger source. Hence $\operatorname{coind}(C_n)\le n$. $\square$

The theorem separates naturally into constructive and obstructive halves. Standard coordinate inclusions establish all lower bounds $m\le n$. Coordinate injectivity and cardinality establish the matching upper bound. The result is sharp in every dimension, not only at the base of the tower.

## 6. Suspension

### 6.1. Combinatorial suspension

The simplicial suspension of a complex adds two new vertices, viewed as north and south poles, and joins each old simplex to either pole. In the cross-polytope family, suspension adds one signed coordinate axis. There is a canonical simplicial isomorphism

$$
\Sigma C_n\cong C_{n+1},
$$

where the two new suspension vertices correspond to $(n+1,+1)$ and $(n+1,-1)$.

Given an equivariant simplicial map $f:C_m\to C_n$, its suspension sends old vertices according to $f$ and sends the new source pole pair to the new target pole pair. In coordinate terms, if $a$ is the original injection, the suspended coordinate map is

$$
a^+(i)=
\begin{cases}
a(i),&0\le i\le m,\\
n+1,&i=m+1.
\end{cases}
$$

The old image coordinates lie in $\{0,\ldots,n\}$, so $a^+$ is injective.

**Proposition 6.1 (Constructive suspension).** Every equivariant simplicial map $C_m\to C_n$ gives an equivariant simplicial map $C_{m+1}\to C_{n+1}$ by adjoining a new matched coordinate axis.

**Proof sketch.** Extend the injective coordinate map by the new coordinate and choose either sign for the new positive pole. The extended coordinate map is injective, so Theorem 3.1 applies. $\square$

The converse at the level of existence is equally exact.

**Theorem 6.2 (Suspension Existence Equivalence).** For all $m,n\ge0$, an equivariant simplicial map

$$
C_{m+1}\longrightarrow C_{n+1}
$$

exists if and only if an equivariant simplicial map

$$
C_m\longrightarrow C_n
$$

exists.

**Proof.** By Theorem 4.1, the first map exists exactly when $m+1\le n+1$. This inequality is equivalent to $m\le n$, which by the same theorem is equivalent to existence of the second map. $\square$

This is an existence-level desuspension statement. It does not claim that every individual map $C_{m+1}\to C_{n+1}$ is literally the suspension of a specified map $C_m\to C_n$ relative to fixed pole coordinates. Instead, it says that suspension neither creates nor destroys the possibility of a map within this tower.

**Corollary 6.3 (Sharp coindex increment).** For every $n\ge0$,

$$
\operatorname{coind}(\Sigma C_n)=\operatorname{coind}(C_n)+1.
$$

**Proof.** Since $\Sigma C_n\cong C_{n+1}$, Theorem 5.1 gives the left side as $n+1$ and the right side as $n+1$. $\square$

Thus the suspension excess is exactly one. The lower increment is realized by suspending maps, while the upper limit follows because one new target axis can accommodate only one additional source axis.

## 7. Algorithms and computational interpretation

The classification leads to simple algorithms whose correctness follows directly from Theorem 3.1.

### 7.1. Validating a proposed map

A proposed equivariant map may be represented by a list of pairs

$$
\bigl[(a(0),\sigma(0)),\ldots,(a(m),\sigma(m))\bigr].
$$

To validate it, first check that every coordinate lies between $0$ and $n$ and every sign is $+1$ or $-1$. Then check whether the coordinate list contains duplicates. The map is simplicial exactly when no duplicate occurs.

With a boolean array of length $n+1$, validation takes time $O(m+n)$ if initialization is counted and space $O(n)$. With a hash set, it takes expected time $O(m)$ and space $O(m)$. Sorting the $m+1$ coordinates gives deterministic time $O(m\log m)$ and space depending on the sorting implementation.

When a duplicate is found at axes $i\ne j$, the algorithm can produce a certificate. If $\sigma(i)\ne\sigma(j)$, choose source vertices $(i,+1)$ and $(j,+1)$. If $\sigma(i)=\sigma(j)$, choose $(i,+1)$ and $(j,-1)$. In both cases the chosen source vertices are non-antipodal and their images are antipodal.

### 7.2. Deciding existence and constructing a witness

To decide whether any map $C_m\to C_n$ exists, compare $m$ and $n$. If $m>n$, report nonexistence. If $m\le n$, return the standard inclusion

$$
(i,\varepsilon)\mapsto(i,\varepsilon).
$$

The decision itself is constant time in a unit-cost arithmetic model. Materializing all $2(m+1)$ vertex images takes time and output space $O(m)$.

### 7.3. Suspending a map

Given positive-vertex data for $C_m\to C_n$, retain all existing pairs and append $(n+1,+1)$ for the new positive source pole. Equivariance supplies the negative pole image. The extension takes $O(m)$ time if the full list is copied, or amortized constant time if appended to a mutable representation with available capacity.

Correctness follows because the new coordinate $n+1$ is absent from all old target coordinates. Thus injectivity is preserved.

## 8. Applications and broader connections

### 8.1. Transparent obstruction certificates

In general topological settings, proving that no equivariant map exists may require global invariants. Here every failure has a two-axis witness. This makes the obstruction auditable and suitable for exhaustive experiments: a candidate map fails because of an explicit collision, not because of an opaque global computation.

### 8.2. Antipodal dimension reduction

An equivariant map may be viewed as a dimension-reduction rule constrained to preserve a binary symmetry. The classification states that, in this cross-polytope model, no such rule can encode more independent signed axes than the target possesses. This is a precise discrete analogue of the intuition that antipodal structure prevents lossless symmetric compression below the source dimension.

### 8.3. Relation to labeling arguments

Tucker-type combinatorial lemmas encode Borsuk–Ulam obstructions through antipodal labelings. Cross-polytope targets are natural label spaces: a target vertex is exactly a signed coordinate label. The Coordinate-Axis Theorem shows that for cross-polytope sources, the obstruction collapses to label collision. This suggests using axis assignments as a base case for more general free involutive complexes, where local labeling constraints may replace literal coordinate injectivity.

### 8.4. Enumeration suggested by the classification

Theorem 3.1 almost immediately yields a counting formula. An injection of $m+1$ labeled source axes into $n+1$ labeled target axes can be chosen in

$$
(n+1)n\cdots(n-m)=\frac{(n+1)!}{(n-m)!}
$$

ways when $m\le n$. For each injection, every source axis has two independent sign choices, suggesting

$$
2^{m+1}\frac{(n+1)!}{(n-m)!}
$$

equivariant simplicial maps. A complete enumerative treatment would package the coordinate and sign decomposition as an explicit natural bijection and study how conventions about abstract simplicial maps affect counting.

### 8.5. Signed permutation symmetry

Automorphisms of a cross-polytope sphere permute axes and independently reverse signs; they form a hyperoctahedral symmetry group. The coordinate-sign description suggests that precomposition and postcomposition by these automorphisms act transitively on equivariant simplicial maps of fixed source and target dimensions. If established explicitly, every map would be equivalent to the standard equatorial inclusion under source and target symmetries.

## 9. Discussion

The main reduction is elementary but structurally informative. Equivariance first halves the vertex data: negative images are forced by positive images. Simpliciality then forgets the sign decoration and retains only coordinate injectivity. Cardinality finally converts injectivity into the inequality $m\le n$. Each stage removes inessential structure while preserving exactly the obstruction needed for the next stage.

The result also clarifies the status of suspension. A generic lower-bound argument might show only that suspending a map produces another map, hence that coindex rises by at least one. The exact existence theorem supplies the missing upper bound. Since both source and target gain one axis, their cardinality comparison is invariant. The increase is therefore exactly one throughout the cross-polytope tower.

There are limits to the immediate conclusion. The existence equivalence under suspension does not itself characterize which individual maps are suspensions relative to fixed equators and poles. Nor does the axis argument directly apply to arbitrary free involutive complexes, whose simplices may have constraints beyond avoiding antipodal pairs. These limitations point naturally toward map-level desuspension criteria and Tucker-labeling generalizations.

## 10. Future directions

First, the coordinate-sign decomposition should be upgraded to a canonical bijection and exact enumeration theorem. This would turn the suggested formula into a complete classification of the map set.

Second, one can seek a faithful suspension theorem at map level. A suspended map has a distinguished source pole pair mapped to a distinguished target pole pair; deleting these should recover the original map. Characterizing the image of suspension requires expressing this distinguished-axis condition invariantly.

Third, the signed permutation groups of source and target should be used to classify orbits of maps. The expected normal form is the standard equatorial inclusion.

Fourth, joins should extend the suspension calculation. Since the join of cross-polytope boundaries concatenates coordinate systems, one expects

$$
\operatorname{coind}(C_m*C_n)=\operatorname{coind}(C_m)+\operatorname{coind}(C_n)+1.
$$

Finally, for a general finite free involutive simplicial complex, one may search for finite Tucker-style certificates witnessing failure of an equivariant map to $C_n$. The present collision certificate is the simplest possible model of such a witness.

## 11. Conclusion

Equivariant simplicial maps between cross-polytope spheres admit a complete finite classification. Such a map is determined by a target coordinate and sign on each positive source axis. It is simplicial exactly when the coordinate assignment is injective. Hence a map $C_m\to C_n$ exists exactly when $m\le n$.

From this single criterion follow an all-dimensional finite Borsuk–Ulam theorem, the identity $\operatorname{coind}(C_n)=n$, suspension equivalence of map existence, and the sharp formula that suspension raises coindex by exactly one. The classification is constructive below the threshold and produces explicit collision certificates above it. It reveals a concise combinatorial core within equivariant topology: the geometry of antipodes is controlled by the arithmetic of coordinate axes.