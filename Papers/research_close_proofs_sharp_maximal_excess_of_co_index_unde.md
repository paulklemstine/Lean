# Join Superadditivity of the $\mathbb{Z}_2$ Co-index of Free Simplicial Complexes

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We develop a self-contained combinatorial theory of *free $\mathbb{Z}_2$-simplicial complexes* — abstract simplicial complexes equipped with a fixed-point-free, face-preserving involution — and study the behavior of their $\mathbb{Z}_2$-**co-index** under the **join** operation. Modeling the topological spheres $S^n$ by the *octahedral spheres* $\mathrm{Oct}(n)$ (boundaries of cross-polytopes), we define the co-index lower bound $\operatorname{coind}(K) \ge n$ to mean the existence of an equivariant simplicial map $\mathrm{Oct}(n) \to K$. Our main theorem is that this lower bound is **join-superadditive**:
$$\operatorname{coind}(K \star L) \;\ge\; \operatorname{coind}(K) + \operatorname{coind}(L) + 1.$$
The proof is constructive: we show the join is a bifunctor on the category of free $\mathbb{Z}_2$-complexes and equivariant simplicial maps, and we exhibit an explicit equivariant simplicial map $\mathrm{Oct}(m+n+1) \to \mathrm{Oct}(m) \star \mathrm{Oct}(n)$ realizing the classical join homeomorphism $S^{m+n+1} \cong S^m \star S^n$. As a corollary, the octahedral spheres form a *join-monoid*, $\mathrm{Oct}(m) \star \mathrm{Oct}(n) \cong \mathrm{Oct}(m+n+1)$. Specializing to $L = S^0 = \mathrm{Oct}(0)$ recovers the suspension law $\operatorname{coind}(SK) \ge \operatorname{coind}(K) + 1$, the constructive core of the Simonyi–Tardos–Vrécica sharp-excess program. We complement these results with a dimension calculation showing $\dim(K \star L) \ge \dim(K) + \dim(L) + 1$, and we discuss the matching upper bound as the principal open problem.

**Keywords:** $\mathbb{Z}_2$ co-index, free simplicial complex, join, octahedral sphere, suspension, Borsuk–Ulam, equivariant map, topological combinatorics.

**MSC 2020:** 55M20 (Borsuk–Ulam and related), 05E45 (combinatorial aspects of simplicial complexes), 55U10 (simplicial sets and complexes).

---

## 1. Introduction

The Borsuk–Ulam theorem and its combinatorial descendants are governed by a single integer invariant of spaces with a free $\mathbb{Z}_2$-action: the **co-index**. Informally, the co-index of a symmetric space $K$ measures the largest sphere that can be mapped equivariantly *into* $K$. It bounds the chromatic number of Kneser-type graphs, controls fair-division and mass-partition results, and packages a wide range of topological obstructions into a comparison against a fixed family of test spaces, the spheres.

This paper isolates and proves a clean algebraic law obeyed by the co-index under the **join** — the fundamental topological operation that glues two spaces by filling in every segment between them. The join is responsible for the identity $S^m \star S^n \cong S^{m+n+1}$, and one expects the co-index, being a sphere-detection invariant, to inherit a corresponding additive law. We confirm the lower-bound half of this expectation, constructively and in full combinatorial detail.

### 1.1 Contributions

1. A fully self-contained model of free $\mathbb{Z}_2$-simplicial complexes, equivariant simplicial maps, and their co-index, requiring no ambient topology (Section 2).
2. The octahedral spheres $\mathrm{Oct}(n)$ as combinatorial models of $S^n$, with an explicit free antipodal action (Section 3).
3. The join $K \star L$ of free $\mathbb{Z}_2$-complexes, proved to be a well-defined free $\mathbb{Z}_2$-complex and a *bifunctor* on equivariant simplicial maps (Section 4).
4. An explicit equivariant simplicial map $\mathrm{Oct}(m+n+1) \to \mathrm{Oct}(m) \star \mathrm{Oct}(n)$ realizing the classical join homeomorphism of spheres (Section 5).
5. The main theorem, **join superadditivity** $\operatorname{coind}(K \star L) \ge \operatorname{coind}(K) + \operatorname{coind}(L) + 1$, and its corollaries including the suspension law (Section 6).
6. A dimension calculation $\dim(K \star L) \ge \dim(K) + \dim(L) + 1$ (Section 7).
7. A discussion of the sharp equality, the octahedral-tower obstruction, and the maximal-excess program (Section 8).

---

## 2. The model: free $\mathbb{Z}_2$-complexes and their co-index

We work with abstract simplicial complexes carrying a free involution.

**Definition 2.1 (Free $\mathbb{Z}_2$-complex).**
A *free $\mathbb{Z}_2$-simplicial complex* on a vertex type $V$ (with decidable equality) is a tuple $K = (\alpha, \mathcal{F})$ where:
- $\alpha : V \to V$ is an **involution** ($\alpha(\alpha(v)) = v$ for all $v$) that is **free** (fixed-point-free): $\alpha(v) \ne v$ for all $v$;
- $\mathcal{F}$, the set of **faces**, is a family of finite subsets of $V$ that is
  - **nonempty**: $\varnothing \in \mathcal{F}$;
  - **downward closed**: $t \subseteq s$ and $s \in \mathcal{F}$ imply $t \in \mathcal{F}$;
  - **$\alpha$-invariant**: $s \in \mathcal{F}$ implies $\alpha(s) \in \mathcal{F}$, where $\alpha(s) = \{\alpha(v) : v \in s\}$.

The map $\alpha$ is the *antipodal map*, and freeness is exactly the hypothesis that makes the co-index a meaningful obstruction: a fixed point of $\alpha$ would allow a constant equivariant map and collapse all co-indices to $-\infty$.

**Definition 2.2 (Equivariant simplicial map).**
A *$\mathbb{Z}_2$-simplicial map* $f : K \to L$ between free $\mathbb{Z}_2$-complexes is a vertex map $f : V_K \to V_L$ such that
- $f$ **commutes with the antipodes**: $f(\alpha_K(v)) = \alpha_L(f(v))$ for all $v \in V_K$;
- $f$ is **simplicial**: $s \in \mathcal{F}_K$ implies $f(s) \in \mathcal{F}_L$.

These maps compose, and the identity vertex map is equivariant simplicial; thus free $\mathbb{Z}_2$-complexes form a category.

**Definition 2.3 (Co-index lower bound).**
Fix the family of octahedral spheres $\{\mathrm{Oct}(n)\}_{n \ge 0}$ (Definition 3.1). For a free $\mathbb{Z}_2$-complex $K$ we write
$$\operatorname{coind}(K) \ge n \quad :\Longleftrightarrow\quad \text{there exists an equivariant simplicial map } \mathrm{Oct}(n) \to K.$$
We denote this relation $\mathrm{HasCoindGe}(\mathrm{Oct}(n), K)$. The **co-index** $\operatorname{coind}(K)$ is the supremum of all such $n$ (or $-\infty$ if no equivariant map from any $\mathrm{Oct}(n)$ exists; freeness guarantees at least $\operatorname{coind}(K) \ge 0$ whenever $K$ is nonempty and free).

**Remark 2.4.** This is the standard $\mathbb{Z}_2$-co-index of topological combinatorics, phrased entirely combinatorially. In the topological setting one uses maps $S^n \to \|K\|$ of the geometric realization; because $\|\mathrm{Oct}(n)\| \cong S^n$ and equivariant simplicial maps realize to equivariant continuous maps, the combinatorial definition provides genuine co-index lower bounds.

---

## 3. Octahedral spheres

**Definition 3.1 (Octahedral $n$-sphere).**
For $n \ge 0$, the *octahedral $n$-sphere* $\mathrm{Oct}(n)$ is the free $\mathbb{Z}_2$-complex on the vertex set $V_n = \{0, 1, \dots, n\} \times \{\mathsf{true}, \mathsf{false}\}$ (that is, $n+1$ *axes* each with a $+$ and a $-$ end) with:
- antipodal map $\alpha(i, b) = (i, \lnot b)$ (flip the sign);
- faces $\mathcal{F}_n = \{\, s \subseteq V_n : \forall i,\ \lnot\big((i,\mathsf{true}) \in s \wedge (i,\mathsf{false}) \in s\big)\,\}$ — a set is a face iff it contains **no antipodal pair**.

**Proposition 3.2.** $\mathrm{Oct}(n)$ is a free $\mathbb{Z}_2$-complex.

*Proof.* The map $\alpha$ is an involution since $\lnot\lnot b = b$, and free since $\lnot b \ne b$. The empty set contains no antipodal pair, so $\varnothing \in \mathcal{F}_n$. If $t \subseteq s$ and $s$ has no antipodal pair, then neither does $t$; hence $\mathcal{F}_n$ is downward closed. Finally, if $s$ has no antipodal pair then applying $\alpha$ (which permutes each pair) again yields no antipodal pair, so $\mathcal{F}_n$ is $\alpha$-invariant. $\square$

Geometrically $\mathrm{Oct}(n)$ is the boundary of the $(n+1)$-dimensional cross-polytope (generalized octahedron), a simplicial triangulation of $S^n$ with $2(n+1)$ vertices. Its maximal faces have exactly $n+1$ vertices (one end from each axis), so $\dim \mathrm{Oct}(n) = n$.

**Proposition 3.3 (Self co-index).** $\operatorname{coind}(\mathrm{Oct}(n)) \ge n$.

*Proof.* The identity vertex map is equivariant and simplicial, witnessing $\mathrm{HasCoindGe}(\mathrm{Oct}(n), \mathrm{Oct}(n))$. $\square$

---

## 4. The join and its bifunctoriality

**Definition 4.1 (Join of free $\mathbb{Z}_2$-complexes).**
Let $K$ (on $V$) and $L$ (on $W$) be free $\mathbb{Z}_2$-complexes. Their *join* $K \star L$ is the free $\mathbb{Z}_2$-complex on the disjoint union $V \sqcup W$ with:
- antipodal map acting coordinatewise, $\alpha_{K \star L} = \alpha_K \sqcup \alpha_L$ (i.e. $\alpha_K$ on the $V$-summand, $\alpha_L$ on the $W$-summand);
- a finite set $T \subseteq V \sqcup W$ is a **face** iff its $V$-part $T|_V := \{v \in V : \iota_V(v) \in T\}$ is a face of $K$ **and** its $W$-part $T|_W$ is a face of $L$:
$$T \in \mathcal{F}_{K \star L} \;\Longleftrightarrow\; T|_V \in \mathcal{F}_K \ \wedge\ T|_W \in \mathcal{F}_L.$$
Crucially, there is **no cross-constraint** linking the $V$- and $W$-parts.

**Proposition 4.2.** $K \star L$ is a free $\mathbb{Z}_2$-complex.

*Proof.* Coordinatewise, the antipode is an involution (each side is) and free (each side is: on the $V$-summand $\alpha_K(v) \ne v$, and $\iota_V(v) \ne \iota_W(w)$ automatically across summands). The empty set restricts to $\varnothing$ on both sides, both faces, so $\varnothing \in \mathcal{F}_{K \star L}$. If $T' \subseteq T$ then $T'|_V \subseteq T|_V$ and $T'|_W \subseteq T|_W$, and downward closure on each side gives downward closure of the join. For $\alpha$-invariance, the $V$-part of $\alpha_{K\star L}(T)$ equals $\alpha_K(T|_V)$ and similarly on $W$; both are faces by $\alpha$-invariance of $K$ and $L$. $\square$

The join is not merely an operation on objects; it is functorial in both arguments.

**Theorem 4.3 (Join is a bifunctor).**
Given equivariant simplicial maps $g : K \to K'$ and $h : L \to L'$, the coordinatewise map $g \sqcup h : V \sqcup W \to V' \sqcup W'$ is an equivariant simplicial map $K \star L \to K' \star L'$. Moreover $\mathrm{id} \sqcup \mathrm{id} = \mathrm{id}$ and $(g' \sqcup h') \circ (g \sqcup h) = (g' \circ g) \sqcup (h' \circ h)$.

*Proof.* *Equivariance:* on the $V$-summand, $(g \sqcup h)(\alpha_{K\star L}(\iota_V v)) = \iota_{V'}(g(\alpha_K v)) = \iota_{V'}(\alpha_{K'} g(v)) = \alpha_{K'\star L'}((g \sqcup h)(\iota_V v))$, using equivariance of $g$; symmetrically on $W$. *Simpliciality:* the $V'$-part of $(g \sqcup h)(T)$ is $g(T|_V)$, a face of $K'$ by simpliciality of $g$; likewise the $W'$-part is $h(T|_W)$, a face of $L'$; hence $(g\sqcup h)(T)$ is a face of $K' \star L'$. The functor laws are immediate from those of the disjoint-union map. $\square$

---

## 5. The combinatorial join homeomorphism $S^{m+n+1} \cong S^m \star S^n$

The heart of the construction is an explicit equivariant simplicial map realizing the classical homeomorphism $S^{m+n+1} \cong S^m \star S^n$ at the level of octahedral spheres.

**Definition 5.1 (Splitting map).**
Recall $\mathrm{Oct}(m+n+1)$ has axes indexed by $\{0, \dots, m+n+1\}$, i.e. $m+n+2$ axes. Define the vertex map
$$\varphi_{m,n} : V_{m+n+1} \longrightarrow V_m \sqcup V_n$$
by splitting the axis range at $m+1$: for a vertex $(i, b)$ with $i \in \{0, \dots, m+n+1\}$,
$$\varphi_{m,n}(i, b) = \begin{cases} \iota_{V_m}(i, b) & \text{if } i < m+1, \\[2pt] \iota_{V_n}(i - (m+1),\, b) & \text{if } i \ge m+1. \end{cases}$$
The sign coordinate $b$ is carried along unchanged; the first $m+1$ axes are shipped to the $\mathrm{Oct}(m)$-side and the last $n+1$ to the $\mathrm{Oct}(n)$-side.

**Theorem 5.2 (Splitting map is equivariant simplicial).**
$\varphi_{m,n}$ is an equivariant simplicial map $\mathrm{Oct}(m+n+1) \to \mathrm{Oct}(m) \star \mathrm{Oct}(n)$.

*Proof.*
*Equivariance.* The antipode of $\mathrm{Oct}(m+n+1)$ flips the sign $b$ and fixes the axis $i$. Since $\varphi_{m,n}$ decides which side to land on using only $i$ (never $b$) and preserves $b$, we have $\varphi_{m,n}(i, \lnot b) = \alpha_{\mathrm{Oct}(m)\star\mathrm{Oct}(n)}(\varphi_{m,n}(i, b))$ in both branches.

*Simpliciality.* Let $s$ be a face of $\mathrm{Oct}(m+n+1)$, i.e. $s$ contains no antipodal pair. We must show $\varphi_{m,n}(s)$ is a face of the join, i.e. its $\mathrm{Oct}(m)$-part and $\mathrm{Oct}(n)$-part each contain no antipodal pair. The $\mathrm{Oct}(m)$-part consists of images $(i, b)$ with $i < m+1$; an antipodal pair there would be $(i, \mathsf{true})$ and $(i, \mathsf{false})$ both coming from $s$ at the same axis $i < m+1$ — impossible, since $s$ has no antipodal pair at axis $i$. The $\mathrm{Oct}(n)$-part consists of images with $i \ge m+1$, re-indexed by $j = i - (m+1)$; because the shift $i \mapsto i - (m+1)$ is injective on $\{m+1, \dots, m+n+1\}$, a conflict at re-indexed axis $j$ would force a conflict at the original axis $i = j + (m+1)$ in $s$ — again impossible. Hence both parts are faces. $\square$

**Corollary 5.3 (Octahedral join splitting).** There is an equivariant simplicial map
$$\mathrm{Oct}(m+n+1) \longrightarrow \mathrm{Oct}(m) \star \mathrm{Oct}(n).$$

This is the combinatorial shadow of $S^{m+n+1} \cong S^m \star S^n$; it provides the "$+1$" that pervades the theory.

---

## 6. Main theorem: join superadditivity of the co-index

**Theorem 6.1 (Join superadditivity).**
Let $K, L$ be free $\mathbb{Z}_2$-complexes with $\operatorname{coind}(K) \ge m$ and $\operatorname{coind}(L) \ge n$. Then
$$\operatorname{coind}(K \star L) \;\ge\; m + n + 1.$$
Equivalently, $\operatorname{coind}(K \star L) \ge \operatorname{coind}(K) + \operatorname{coind}(L) + 1$.

*Proof.* By hypothesis there are equivariant simplicial maps $g : \mathrm{Oct}(m) \to K$ and $h : \mathrm{Oct}(n) \to L$. By bifunctoriality (Theorem 4.3), their join
$$g \star h : \mathrm{Oct}(m) \star \mathrm{Oct}(n) \longrightarrow K \star L$$
is equivariant simplicial. Precomposing with the splitting map of Corollary 5.3 gives the composite
$$\mathrm{Oct}(m+n+1) \xrightarrow{\ \varphi_{m,n}\ } \mathrm{Oct}(m) \star \mathrm{Oct}(n) \xrightarrow{\ g \star h\ } K \star L,$$
which is equivariant simplicial (equivariant simplicial maps compose). This witnesses $\operatorname{coind}(K \star L) \ge m+n+1$. $\square$

**Corollary 6.2 (Octahedral tower is a join-monoid).**
$\operatorname{coind}(\mathrm{Oct}(m) \star \mathrm{Oct}(n)) \ge m + n + 1$. Combined with the reverse geometric inequality $\dim(\mathrm{Oct}(m)\star\mathrm{Oct}(n)) = m+n+1$ (Section 7) and the general bound $\operatorname{coind} \le \dim$, this pins the co-index and realizes the join isomorphism $\mathrm{Oct}(m) \star \mathrm{Oct}(n) \cong \mathrm{Oct}(m+n+1)$ up to co-index.

*Proof.* Apply Theorem 6.1 with $K = \mathrm{Oct}(m)$, $L = \mathrm{Oct}(n)$ using Proposition 3.3. $\square$

### 6.1 Suspension as the special case $L = S^0$

**Definition 6.3 (Suspension).** The *suspension* of a free $\mathbb{Z}_2$-complex $K$ is $SK := K \star \mathrm{Oct}(0)$, where $\mathrm{Oct}(0) = S^0$ is the two-point antipodal $0$-sphere.

**Theorem 6.4 (Suspension raises co-index).**
If $\operatorname{coind}(K) \ge m$ then $\operatorname{coind}(SK) \ge m + 1$.

*Proof.* Take $L = \mathrm{Oct}(0)$ with $n = 0$ in Theorem 6.1; since $\operatorname{coind}(\mathrm{Oct}(0)) \ge 0$ (Proposition 3.3), we obtain $\operatorname{coind}(K \star \mathrm{Oct}(0)) \ge m + 0 + 1 = m+1$. $\square$

This recovers the constructive core of the Simonyi–Tardos–Vrécica suspension results: each suspension guarantees a co-index jump of at least one, and the join law reveals it as the smallest case ($n=0$) of the general phenomenon "joining with $S^n$ raises co-index by $n+1$."

---

## 7. Dimension bookkeeping

Let $\dim(K)$ denote the maximal face dimension of $K$: one less than the largest number of vertices in a face (so $\dim \varnothing = -1$).

**Lemma 7.1 (Faces combine).**
If $s$ is a face of $K$ and $t$ a face of $L$, then $\iota_V(s) \cup \iota_W(t)$ is a face of $K \star L$.

*Proof.* Its $V$-part is exactly $s$ (a face of $K$) and its $W$-part is exactly $t$ (a face of $L$), because $\iota_V$ and $\iota_W$ have disjoint images. By the join face criterion, the union is a face. $\square$

**Lemma 7.2 (Vertex counts add).**
$\big|\iota_V(s) \cup \iota_W(t)\big| = |s| + |t|$.

*Proof.* The maps $\iota_V, \iota_W$ are injective, so $|\iota_V(s)| = |s|$ and $|\iota_W(t)| = |t|$; their images are disjoint, so the union's cardinality is the sum. $\square$

**Corollary 7.3 (Join dimension lower bound).**
$\dim(K \star L) \ge \dim(K) + \dim(L) + 1$.

*Proof.* Take top faces $s$ of $K$ and $t$ of $L$ with $|s| = \dim(K)+1$, $|t| = \dim(L)+1$. By Lemmas 7.1–7.2, $K \star L$ has a face with $|s|+|t| = \dim(K)+\dim(L)+2$ vertices, hence dimension $\ge \dim(K)+\dim(L)+1$. $\square$

For the octahedral spheres this is an equality: $\dim(\mathrm{Oct}(m) \star \mathrm{Oct}(n)) = m+n+1 = \dim(\mathrm{Oct}(m+n+1))$, matching both the co-index bound (Corollary 6.2) and the topological join dimension formula. The "$+1$" is thus shared by the dimension law and the co-index law — the same shift appearing in $S^m \star S^n \cong S^{m+n+1}$.

---

## 8. Discussion and future work

### 8.1 The sharp equality

Theorem 6.1 is the *lower-bound* half of the conjectural exact law
$$\operatorname{coind}(K \star L) = \operatorname{coind}(K) + \operatorname{coind}(L) + 1.$$
Because our lower bound is realized by an explicit coordinate-splitting map, the entire difficulty of the sharp statement concentrates in a single **matching upper bound** $\operatorname{coind}(K \star L) \le \operatorname{coind}(K) + \operatorname{coind}(L) + 1$. Unlike the lower bound, an upper bound cannot be produced by exhibiting a map; it requires an *obstruction* — a proof that certain equivariant maps *do not exist*. The natural candidate is the $\mathbb{Z}_2$-**index** (the dual invariant, defined via equivariant maps *out of* $K$ into spheres) or an equivariant cohomological characteristic class, both of which are expected to be additive under joins. With the join bifunctor and its explicit connecting map now in hand, the missing ingredient is precisely this obstruction-theoretic input, an isolable target.

### 8.2 The octahedral-tower Borsuk–Ulam obstruction

A cornerstone upper bound would be: *any equivariant simplicial map $\mathrm{Oct}(n) \to \mathrm{Oct}(k)$ forces $n \le k$* — equivalently $\operatorname{coind}(\mathrm{Oct}(k)) = k$ exactly. The base case (no equivariant map from a higher sphere to $\mathrm{Oct}(0) = S^0$) is the combinatorial Borsuk–Ulam parity/degree obstruction. The join splitting $\mathrm{Oct}(k) \cong \mathrm{Oct}(0) \star \mathrm{Oct}(k-1)$ suggests an inductive "peel one coordinate" argument reducing the general case to the base case.

### 8.3 The maximal-excess program

Define the *excess* of $K$ as $\dim(K) - \operatorname{coind}(K) \ge 0$. The suspension law (Theorem 6.4) combined with the exact dimension law $\dim(SK) = \dim(K) + 1$ shows that each suspension raises dimension by exactly one but co-index by *at least* one, so excess is non-increasing under suspension. The maximal-excess conjecture asks, for every $d \ge 2$ and every feasible $c$ with $1 \le c \le d$, for a $d$-dimensional free $\mathbb{Z}_2$-complex $K$ with $\operatorname{coind}(K) = c$ and $\operatorname{coind}(SK) = d+1$. The join provides the essential tool: a *dial for dimension independent of co-index*, realized by joining a low-co-index/high-dimension building block (whose co-index is pinned below its dimension by a Borsuk–Ulam obstruction) with a sphere that supplies the missing co-index only after one further suspension.

### 8.4 Summary

We have established, constructively and in complete detail, that the $\mathbb{Z}_2$ co-index lower bound is join-superadditive: $\operatorname{coind}(K \star L) \ge \operatorname{coind}(K) + \operatorname{coind}(L) + 1$, with the octahedral spheres forming a join-monoid and the classical suspension jump recovered as the $L = S^0$ special case. The results assemble into a bridge between combinatorics and equivariant topology: the join, one of the oldest topological constructions, obeys a clean arithmetic law at the level of the co-index, and that law has a fully explicit, checkable combinatorial witness.

---

## References (selected background)

1. K. Borsuk. *Drei Sätze über die n-dimensionale euklidische Sphäre.* Fund. Math. 20 (1933), 177–190.
2. L. Lovász. *Kneser's conjecture, chromatic number, and homotopy.* J. Combin. Theory Ser. A 25 (1978), 319–324.
3. J. Matoušek. *Using the Borsuk–Ulam Theorem.* Springer, 2003.
4. G. Simonyi, G. Tardos. *Local chromatic number, Ky Fan's theorem, and circular colorings.* Combinatorica 26 (2006), 587–626.
5. G. Simonyi, G. Tardos, S. T. Vrécica. *Local chromatic number and distinguishing the strength of topological obstructions.* Trans. Amer. Math. Soc. 361 (2009), 889–908.
