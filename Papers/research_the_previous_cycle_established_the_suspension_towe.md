# Functoriality, the $\mathbb{Z}_2$-Index, and the Exact Enumeration of Antipodal Maps of Cross-Polytope Spheres

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study antipodal (that is, $\mathbb{Z}_2$-equivariant) simplicial maps between combinatorial spheres realized as boundaries of cross-polytopes. In this rigid model, the boundary of the $(n+1)$-dimensional cross-polytope furnishes a triangulated $n$-sphere $S^n$ with $2(n+1)$ vertices — a positive and a negative pole for each of $n+1$ coordinate axes — carrying a free $\mathbb{Z}_2$-action given by the antipode. Building on the existence dichotomy that an antipodal map $S^m \to S^n$ exists if and only if $m \le n$, we develop the *structural* and *enumerative* theory of these maps. Our results are threefold. First, antipodal maps compose, so the family of spheres forms a thin category whose reachability relation is exactly $m \le n$; composition realizes transitivity of existence constructively. Second, the $\mathbb{Z}_2$-*index* — the least target dimension into which $S^m$ admits an antipodal map — equals $m$, so it coincides with the coindex, and the index–coindex gap vanishes for cross-polytope spheres. Third, we establish a bijection identifying an antipodal map with an injection of coordinate axes together with an independent sign vector, yielding the exact count
$$
\#\{\text{antipodal maps } S^m \to S^n\} = (n+1)^{\underline{\,m+1\,}}\cdot 2^{m+1},
$$
where $(n+1)^{\underline{\,m+1\,}}$ denotes the falling factorial. The diagonal recovers the order $2^{n+1}(n+1)!$ of the hyperoctahedral group $B_{n+1}$, and positivity of the count is exactly the Borsuk–Ulam threshold $m \le n$. We conclude with the interaction with the suspension tower and a discussion of the general index–coindex gap beyond the octahedral case.

## 1. Introduction

The Borsuk–Ulam theorem asserts that there is no continuous antipodal map from the $m$-sphere to the $n$-sphere when $m > n$. It is one of the most consequential results in combinatorial and topological mathematics, underlying lower bounds for chromatic numbers (Lovász's solution of the Kneser conjecture), fair-division and necklace-splitting theorems, and much of topological combinatorics. Its natural invariants are the $\mathbb{Z}_2$-**index** and $\mathbb{Z}_2$-**coindex** of a free $\mathbb{Z}_2$-space: the smallest sphere the space maps into, and the largest sphere that maps into the space.

For general free $\mathbb{Z}_2$-complexes these invariants are subtle: they need not agree, and the upper bound "coindex $\le$ dimension" requires the full strength of Borsuk–Ulam (equivalently, Tucker's lemma). The purpose of this paper is to show that in the **cross-polytope model** — where spheres are boundaries of orthoplexes and maps are antipodal simplicial maps — the entire theory collapses to elementary, exact combinatorics, and to extract from that collapse a complete quantitative description.

Our contributions:

1. **Functoriality (Section 3).** Antipodal maps compose, making the cross-polytope spheres a thin category ordered by $m \le n$.
2. **Index = coindex (Section 4).** The index of $S^m$ is exactly $m$; combined with the known coindex $= n$, the index–coindex gap vanishes.
3. **Exact enumeration (Sections 5–6).** An explicit bijection identifies antipodal maps with (axis injection, sign vector) pairs, yielding a closed-form count whose diagonal is the order of the hyperoctahedral group and whose positivity is the Borsuk–Ulam threshold.
4. **Suspension (Section 7).** The invariants shift in lockstep along the suspension tower.

## 2. The cross-polytope model

### 2.1 Vertices, poles, and the antipode

**Definition 2.1 (Combinatorial sphere).** For $n \in \mathbb{N}$, the *combinatorial $n$-sphere* $S^n$ is the boundary complex of the $(n+1)$-dimensional cross-polytope. Its vertex set is
$$
V(S^n) = \{0,1,\dots,n\} \times \{+,-\},
$$
so that each of the $n+1$ coordinate axes $i$ contributes two vertices: the *positive pole* $(i,+)$ and the *negative pole* $(i,-)$. We identify $(i,+)$ with $+e_i$ and $(i,-)$ with $-e_i$.

**Definition 2.2 (Faces).** A subset $\sigma \subseteq V(S^n)$ is a *face* iff it contains at most one pole of each axis; equivalently, $\sigma$ never contains both $(i,+)$ and $(i,-)$. Thus the maximal faces are precisely the sign-choices $\{(0,\varepsilon_0),\dots,(n,\varepsilon_n)\}$, the $2^{n+1}$ facets of the cross-polytope.

**Definition 2.3 (Antipode).** The *antipodal map* $\alpha : V(S^n) \to V(S^n)$ flips the sign, $\alpha(i,\varepsilon) = (i,-\varepsilon)$, and leaves the axis fixed. It is a free simplicial involution, giving $S^n$ the structure of a free $\mathbb{Z}_2$-complex.

### 2.2 Antipodal simplicial maps

**Definition 2.4 ($\mathbb{Z}_2$-map).** A *$\mathbb{Z}_2$-map* (antipodal simplicial map) $F : S^m \to S^n$ is a vertex map $F : V(S^m) \to V(S^n)$ satisfying:

- **(Equivariance)** $F(\alpha v) = \alpha F(v)$ for all vertices $v$; and
- **(Simpliciality)** the image of every face is a face.

We write $\operatorname{Z2Map}(m,n)$ for the set of such maps.

Because every subset of a face is a face and the maximal faces are the sign-choices, simpliciality is equivalent to the statement that the images of any two distinct-axis, arbitrarily-signed source vertices lie on distinct axes. This is the observation exploited throughout.

### 2.3 Positive-vertex data and induced maps

**Definition 2.5 (Positive-vertex data).** For an equivariant map $F$, its *positive-vertex data* is the function
$$
g_F : \{0,\dots,m\} \to V(S^n), \qquad g_F(i) = F(i,+).
$$

**Definition 2.6 (Induced map).** Conversely, any $g : \{0,\dots,m\} \to V(S^n)$ *induces* the unique equivariant vertex map $\operatorname{ind}(g)$ with $\operatorname{ind}(g)(i,+) = g(i)$ and $\operatorname{ind}(g)(i,-) = \alpha\, g(i)$.

**Definition 2.7 (Coordinate map).** For $g$ as above, its *coordinate map* $\operatorname{coord}(g) : \{0,\dots,m\} \to \{0,\dots,n\}$ records only the axis, $\operatorname{coord}(g)(i) = \pi_{\text{axis}}(g(i))$.

**Lemma 2.8 (Reconstruction).** Every equivariant map $F$ equals $\operatorname{ind}(g_F)$. *Proof.* On positive poles this is the definition of $g_F$; on negative poles, equivariance gives $F(i,-) = \alpha F(i,+) = \alpha\, g_F(i)$, which is exactly $\operatorname{ind}(g_F)(i,-)$. $\square$

**Lemma 2.9 (Simpliciality criterion).** The induced map $\operatorname{ind}(g)$ is simplicial (hence a $\mathbb{Z}_2$-map) if and only if $\operatorname{coord}(g)$ is injective.

*Proof sketch.* A maximal face upstairs is a full sign-choice over all $m+1$ axes; its image under $\operatorname{ind}(g)$ uses the target axes $\operatorname{coord}(g)(0),\dots,\operatorname{coord}(g)(m)$. This image is a face iff these axes are pairwise distinct, i.e. iff $\operatorname{coord}(g)$ is injective. The sign carried by each image vertex is irrelevant to whether the image is a face, since a face constraint only forbids two poles of the *same* axis. $\square$

Lemma 2.9 is the combinatorial heart of the model: it converts the topological condition "simplicial antipodal map" into the purely set-theoretic condition "injective on axes."

## 3. Functoriality

**Definition 3.1 (Composition).** Given $G \in \operatorname{Z2Map}(n,p)$ and $F \in \operatorname{Z2Map}(m,n)$, define $G \circ F : V(S^m) \to V(S^p)$ by ordinary composition of vertex maps.

**Theorem 3.2 (Composition is a $\mathbb{Z}_2$-map).** $G \circ F \in \operatorname{Z2Map}(m,p)$.

*Proof.* Equivariance: $(G\circ F)(\alpha v) = G(F(\alpha v)) = G(\alpha F(v)) = \alpha G(F(v))$. Simpliciality: if $\sigma$ is a face of $S^m$ then $F(\sigma)$ is a face of $S^n$ by simpliciality of $F$, and then $G(F(\sigma))$ is a face of $S^p$ by simpliciality of $G$. $\square$

**Corollary 3.3 (Transitivity of existence).** If $\operatorname{Z2Map}(n,p)$ and $\operatorname{Z2Map}(m,n)$ are nonempty, so is $\operatorname{Z2Map}(m,p)$.

Composition is strictly associative and admits the identity map as a unit, so the cross-polytope spheres form a **thin category** (at most our interest is in existence): the objects are the dimensions $\mathbb{N}$, and there is a morphism $m \to n$ precisely when a $\mathbb{Z}_2$-map exists. By the existence dichotomy (Theorem 5.4) this reachability relation is exactly the order $\le$.

## 4. The $\mathbb{Z}_2$-index and its coincidence with the coindex

We recall the coindex and introduce the dual index.

**Definition 4.1 (Coindex).** $\operatorname{coind}(S^n) = \sup\{\, m : \operatorname{Z2Map}(m,n) \ne \varnothing \,\}$.

**Definition 4.2 (Index).** $\operatorname{ind}(S^m) = \inf\{\, n : \operatorname{Z2Map}(m,n) \ne \varnothing \,\}$.

The coindex measures the largest sphere that maps *into* $S^n$; the index measures the smallest sphere $S^m$ maps *out of*. From the established coindex identity $\operatorname{coind}(S^n) = n$ and the existence dichotomy we obtain the following.

**Lemma 4.3 (Admissible targets).** The set of target dimensions admitting a map from $S^m$ is exactly $\{m, m+1, m+2, \dots\}$.

*Proof.* Immediate from the existence dichotomy: $\operatorname{Z2Map}(m,n) \ne \varnothing \iff m \le n$. $\square$

**Theorem 4.4 (Index of a cross-polytope sphere).** $\operatorname{ind}(S^m) = m$.

*Proof.* By Lemma 4.3 the admissible set is $\{n : n \ge m\}$, whose infimum is $m$. $\square$

**Theorem 4.5 (Index–coindex coincidence).** For every $n$,
$$
\operatorname{ind}(S^n) = \operatorname{coind}(S^n) = n.
$$
In particular the index–coindex gap of a cross-polytope sphere is zero.

This vanishing is *special to spheres*. For a general free simplicial $\mathbb{Z}_2$-complex $K$ the coindex is not determined by dimension alone, the two invariants can differ, and the inequality $\operatorname{coind}(K) \le \dim K$ genuinely requires Tucker's lemma. The cross-polytope family thus provides a fully solved, zero-gap baseline.

## 5. The enumeration bijection

We now upgrade existence to exact structure.

**Theorem 5.1 (Structure of $\mathbb{Z}_2$-maps).** There is a bijection
$$
\Phi : \operatorname{Z2Map}(m,n) \;\xrightarrow{\ \sim\ }\; \bigl(\{0,\dots,m\} \hookrightarrow \{0,\dots,n\}\bigr) \times \bigl(\{0,\dots,m\} \to \{+,-\}\bigr),
$$
sending a map $F$ to the pair $(\operatorname{coord}(g_F),\ \operatorname{sign}(g_F))$, where the first coordinate is the (necessarily injective) axis map of the positive-vertex data and the second records the sign of each positive image.

*Proof.* By Lemma 2.8 a $\mathbb{Z}_2$-map is determined by its positive-vertex data $g_F$, and $g_F$ is equivalent to the pair (coordinate map, sign function). By Lemma 2.9 the coordinate map is injective iff the induced map is simplicial; since $F$ *is* simplicial, $\operatorname{coord}(g_F)$ is injective, so $\Phi$ lands in the stated codomain. Conversely, any (injection, sign vector) pair reassembles into positive-vertex data $g$ with injective coordinate map, hence by Lemma 2.9 into a genuine $\mathbb{Z}_2$-map $\operatorname{ind}(g)$; this inverse is mutually inverse to $\Phi$ by Lemma 2.8. $\square$

The content of Theorem 5.1 is a **decoupling**: an antipodal map is exactly two independent choices — *which axes* (rigid: an injection) and *which signs* (free: an arbitrary Boolean vector).

**Corollary 5.2 (Finiteness).** $\operatorname{Z2Map}(m,n)$ is a finite set.

## 6. Exact enumeration

**Theorem 6.1 (Exact count).** For all $m, n \in \mathbb{N}$,
$$
\#\operatorname{Z2Map}(m,n) \;=\; (n+1)^{\underline{\,m+1\,}}\cdot 2^{m+1},
$$
where $(n+1)^{\underline{\,m+1\,}} = (n+1)\,n\,(n-1)\cdots(n-m+1)$ is the falling factorial with $m+1$ factors.

*Proof.* By Theorem 5.1 the count is the product of the number of injections $\{0,\dots,m\}\hookrightarrow\{0,\dots,n\}$ and the number of sign vectors $\{0,\dots,m\}\to\{+,-\}$. The former is the falling factorial $(n+1)^{\underline{\,m+1\,}}$; the latter is $2^{m+1}$. $\square$

**Theorem 6.2 (Quantitative Borsuk–Ulam).** $\#\operatorname{Z2Map}(m,n) > 0 \iff m \le n$, and $\#\operatorname{Z2Map}(m,n) = 0 \iff n < m$.

*Proof.* The falling factorial $(n+1)^{\underline{\,m+1\,}}$ is positive iff $m+1 \le n+1$ and zero otherwise; the power of two is always positive. $\square$

In particular the critical count $\#\operatorname{Z2Map}(n+1, n) = 0$: there is no antipodal map $S^{n+1} \to S^n$, which is exactly the Borsuk–Ulam theorem in the cross-polytope model, now obtained as the vanishing of a counting formula.

**Theorem 6.3 (Self-maps and the hyperoctahedral group).** The number of antipodal self-maps of $S^n$ is
$$
\#\operatorname{Z2Map}(n,n) \;=\; (n+1)!\cdot 2^{n+1},
$$
the order of the hyperoctahedral group $B_{n+1}$ of signed permutations of $n+1$ coordinates.

*Proof.* Set $m = n$ in Theorem 6.1; the falling factorial $(n+1)^{\underline{\,n+1\,}}$ becomes $(n+1)!$. $\square$

Thus every antipodal self-map of the combinatorial $n$-sphere is a *signed permutation of coordinate axes* — precisely a rigid symmetry of the cross-polytope. The self-map monoid is in fact the symmetry group $B_{n+1}$; there is no additional non-invertible antipodal self-map, a strong rigidity statement.

**Small values.** The table below lists $\#\operatorname{Z2Map}(m,n)$:

| $m \backslash n$ | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| **0** | 2 | 4 | 6 | 8 | 10 |
| **1** | 0 | 8 | 24 | 48 | 80 |
| **2** | 0 | 0 | 48 | 192 | 480 |

The zeros strictly below the diagonal are Borsuk–Ulam; the diagonal $2, 8, 48, 384, \dots$ is $2^{n+1}(n+1)!$.

## 7. Interaction with the suspension tower

The **suspension** $\Sigma$ adds one coordinate axis with two new poles and cones the old complex to each pole; combinatorially it sends $S^n$ to $S^{n+1}$. On maps, $\Sigma$ extends a $\mathbb{Z}_2$-map $F : S^m \to S^n$ to $\Sigma F : S^{m+1} \to S^{n+1}$ by mapping the new source axis to the new target axis with matching sign.

**Theorem 7.1 (Suspension preserves excess).** For all $m,n,k$,
$$
\operatorname{Z2Map}(m+k,\, n+k) \ne \varnothing \iff \operatorname{Z2Map}(m,n) \ne \varnothing.
$$
Equivalently, the *excess* $n - m$ is invariant under suspension; the coindex bound increases by exactly $k$ after $k$ suspensions, with no slack.

*Proof sketch.* Both sides are equivalent to $m \le n$ by the existence dichotomy, since $m + k \le n + k \iff m \le n$. Constructively, $\Sigma$ provides the forward map and restriction to the non-pole axes provides the backward direction. $\square$

Consequently the coindex, the index, and the raw cardinality all shift coherently along the tower $S^0 \hookrightarrow S^1 \hookrightarrow \cdots$; every rung is Borsuk–Ulam sharp. The single invariant governing the whole tower is the excess $n - m$.

## 8. Discussion

The cross-polytope model exhibits maximal rigidity. Three facets of one invariant $m \le n$ are pinned down simultaneously: functorial reachability (the thin category ordered by $\le$), the coincidence of the dual index and coindex (zero gap), and an exact map-count that factors as a falling factorial times a power of two. The factorization is the enumerative signature of the two decoupled degrees of freedom — axis choice and sign choice — that separate precisely because every face is spanned by antipodal axis pairs.

This rigidity is a feature, not a limitation. Because the octahedral family is a controlled zero-gap, exactly-counted baseline, deviations from it become computable obstructions:

- A **positive index–coindex gap** certifies non-octahedral structure.
- A map-count **not** of the shape (falling factorial)$\times$(power of two) certifies that the source is not a join of copies of $S^0$.

## 9. Future work

- **A strictly positive index–coindex gap.** For general free simplicial $\mathbb{Z}_2$-complexes the coindex is not determined by dimension. One expects, for every $g \ge 1$, a complex $K$ with $\operatorname{coind}(K) = d$ and $\operatorname{ind}(K) = d + g$, with the minimal vertex count realizing a gap $g$ growing at least linearly in $g$. The octahedral collapse is forced only by the rigidity that a simplicial antipodal self-map of a cross-polytope must permute axes.
- **A characterization of the falling-factorial signature.** Among free simplicial $\mathbb{Z}_2$-complexes on a fixed vertex set, the count of antipodal maps into $S^n$ should be a falling factorial times a power of two *iff* the source is a join of copies of $S^0$.
- **Suspension as an enumerative equivalence.** Beyond preserving existence, suspension should induce a bijection between antipodal maps $S^m \to S^n$ and pole-fixing maps $S^{m+1}\to S^{n+1}$.
- **Beyond cross-polytopes.** For general $K$ the upper bound $\operatorname{coind} \le \dim$ genuinely needs Tucker's lemma.
- **Chromatic applications.** Connect the coindex of neighborhood/box complexes to chromatic lower bounds (Lovász–Kneser), now that the coindex is pinned down exactly for spheres.

## References

- K. Borsuk, *Drei Sätze über die $n$-dimensionale euklidische Sphäre*, Fund. Math. 20 (1933).
- L. Lovász, *Kneser's conjecture, chromatic number, and homotopy*, J. Combin. Theory Ser. A 25 (1978).
- J. Matoušek, *Using the Borsuk–Ulam Theorem*, Springer, 2003.
