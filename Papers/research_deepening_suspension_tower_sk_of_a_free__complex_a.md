# Enumerative Rigidity of Antipodal Maps Between Octahedral Spheres

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

We study antipodally-equivariant simplicial maps between octahedral spheres — the combinatorial spheres realized as boundaries of cross-polytopes, each carrying the free $\mathbb{Z}_2$-action given by the antipodal involution. Our central result is an exact enumeration: the number of equivariant simplicial maps $S^m \to S^n$ is
$$
\#\{\text{$\mathbb{Z}_2$-maps } S^m \to S^n\} \;=\; 2^{\,m+1}\cdot (n+1)^{\underline{\,m+1\,}} \;=\; 2^{\,m+1}\cdot\frac{(n+1)!}{(n-m)!},
$$
a product of an independent sign for each source axis and a falling-factorial count of axis injections. The proof rests on a *rigidity* phenomenon: equivariance reconstructs an entire map from the images of its positive vertices, and simpliciality reduces to injectivity of the induced axis map, so a $\mathbb{Z}_2$-map is *exactly* an injection of coordinate axes decorated with an independent sign vector. Three classical facts follow as corollaries of this single formula. The count is positive iff $m \le n$, yielding a combinatorial Borsuk–Ulam theorem and the identity $\operatorname{coind}(S^n) = n$. Its diagonal value $2^{n+1}(n+1)!$ is the order of the hyperoctahedral group $B_{n+1}$, so every $\mathbb{Z}_2$-self-map of $S^n$ is a signed permutation of axes. Finally, the *existence dichotomy* is stable along the suspension tower: since $m \le n$ is equivalent to $m+k \le n+k$, the excess $n-m$ is a suspension invariant, and correspondingly $S(S^n) \cong S^{n+1}$ raises dimension and coindex in lockstep. The exact count, by contrast, is not suspension-invariant — it grows by a factor $2(n+2)$ per step — so it is the positivity of the formula, not its value, that is stable. The unifying theme is that the coindex, the excess, and the suspension tower are all shadows of a single elementary finite object — the set of signed axis injections.

**Keywords:** free $\mathbb{Z}_2$-complex, antipodal map, octahedral sphere, cross-polytope, coindex, Borsuk–Ulam theorem, hyperoctahedral group, signed permutation, falling factorial, suspension tower, equivariant simplicial map.

## 1. Introduction

The Borsuk–Ulam theorem is one of the load-bearing results of combinatorial and algebraic topology: it powers Lovász's proof of the Kneser conjecture, a wealth of fair-division and Tucker-lemma arguments, and the general theory of topological lower bounds in combinatorics. In its equivariant formulation it asserts the *nonexistence* of a $\mathbb{Z}_2$-equivariant map from a higher sphere to a lower one. This is fundamentally a *qualitative* statement — it decides a yes/no question about existence.

This paper asks the sharper *quantitative* question. Among all combinatorial models of spheres, the octahedral spheres (boundaries of cross-polytopes) are the most symmetric, and their equivariant simplicial maps are so rigid that they can be *counted exactly*. We prove that the number of antipodally-equivariant simplicial maps $S^m \to S^n$ is a clean closed form, and we show that the classical existence dichotomy, the identification of the sphere's symmetry group, and the behavior of the suspension tower are all corollaries of this one enumeration.

The philosophy is "count, don't merely decide." Existence theorems tell us whether an object exists; enumeration theorems tell us how the objects are organized, expose their symmetry groups, and often make the existence statement fall out as the positivity of a formula. We carry this philosophy through the entire coindex theory of octahedral spheres.

### Contributions

1. **A classifying bijection (Section 3).** We exhibit an explicit equivalence identifying the set of $\mathbb{Z}_2$-maps $S^m \to S^n$ with the set of pairs (sign vector, axis injection).
2. **The exact count (Section 4).** We derive $\#\{S^m \to S^n\} = 2^{m+1}(n+1)^{\underline{m+1}}$.
3. **A combinatorial Borsuk–Ulam theorem (Section 5).** Positivity of the count is equivalent to $m \le n$, giving $\operatorname{coind}(S^n) = n$.
4. **The hyperoctahedral identification (Section 6).** The diagonal count is $|B_{n+1}| = 2^{n+1}(n+1)!$, and every self-map is a signed permutation.
5. **Suspension stability (Section 7).** The existence dichotomy and the excess $n-m$ are invariant under simultaneous suspension of source and target, while the exact count grows by a controlled factor.

## 2. Definitions

### 2.1 Free $\mathbb{Z}_2$-complexes

A **free $\mathbb{Z}_2$-complex** is an abstract simplicial complex $K$ equipped with a simplicial involution $\nu\colon K \to K$ (the *antipodal action*) that is free: $\nu$ has no fixed vertices, and no simplex of $K$ contains both a vertex $v$ and its antipode $\nu(v)$. We write $-v$ for $\nu(v)$.

An **equivariant simplicial map** (a **$\mathbb{Z}_2$-map**) $f\colon K \to L$ between free $\mathbb{Z}_2$-complexes is a simplicial map — it carries vertices to vertices and simplices to simplices — that commutes with the antipodal actions: $f(-v) = -f(v)$ for every vertex $v$. We write $\mathrm{Z2Map}(K, L)$ for the set of such maps.

### 2.2 The octahedral sphere

Fix $n \ge 0$. The **octahedral $n$-sphere** $S^n$ is the boundary complex of the $(n+1)$-dimensional cross-polytope, described combinatorially as follows. Its vertex set is
$$
V(S^n) \;=\; \{0, 1, \dots, n\} \times \{+, -\},
$$
consisting of $n+1$ **axes** $\{0,\dots,n\}$, each carrying a positive vertex $(i,+)$ and a negative vertex $(i,-)$. The antipodal action flips the sign: $-(i,\pm) = (i,\mp)$; it is manifestly free. A finite set $\sigma \subseteq V(S^n)$ is a **simplex** of $S^n$ precisely when it contains at most one vertex from each axis — equivalently, when the *coordinate map* $\sigma \to \{0,\dots,n\}$, $(i,\pm)\mapsto i$, is injective on $\sigma$.

Thus $S^n$ has $2(n+1)$ vertices and $2^{\,n+1}$ facets (maximal simplices), one for each choice of sign on each of the $n+1$ axes; it is a triangulation of the topological $n$-sphere. Low-dimensional cases: $S^0$ is two antipodal points; $S^1$ is a $4$-cycle (the square); $S^2$ is the octahedron.

### 2.3 Positive-vertex data

For a source $S^m$, call $e_0, \dots, e_m$ with $e_i = (i,+)$ the **positive vertices**. A signed vertex of $S^n$ is a pair $(j, s)$ with $j \in \{0,\dots,n\}$ an axis and $s \in \{+,-\}$ a sign. The **positive-vertex data** of a map $f$ is the tuple $g = (g_0,\dots,g_m)$ where $g_i = f(e_i) \in V(S^n)$. Writing $g_i = (\gamma_i, s_i)$, the **coordinate map** of $g$ is $\gamma\colon \{0,\dots,m\} \to \{0,\dots,n\}$, $i \mapsto \gamma_i$, and the **sign vector** is $s = (s_0,\dots,s_m) \in \{+,-\}^{m+1}$.

### 2.4 Coindex and excess

The **$\mathbb{Z}_2$-coindex** of a free $\mathbb{Z}_2$-complex $K$ is
$$
\operatorname{coind}(K) \;=\; \max\{\, m \ge 0 : \mathrm{Z2Map}(S^m, K) \ne \varnothing \,\},
$$
the largest dimension of an octahedral sphere admitting an equivariant map into $K$ (or $-1$ by convention if none exists). For a complex of dimension $d$, the **excess** is $d - \operatorname{coind}(K)$, measuring how far the complex reaches below its dimension.

### 2.5 Suspension and the suspension tower

The **join** $K * L$ of two free $\mathbb{Z}_2$-complexes has vertex set the disjoint union $V(K) \sqcup V(L)$, simplices all unions $\sigma \cup \tau$ with $\sigma$ a simplex of $K$ and $\tau$ a simplex of $L$, and the antipodal action inherited coordinatewise. The **suspension** of $K$ is
$$
S(K) \;=\; K * S^0,
$$
the join with a single antipodal pair of poles $\{p_+, p_-\}$. Suspension raises dimension by one and coindex by one. Iterating, the **suspension tower** is $S^k(K) = \underbrace{S(S(\cdots S}_{k}(K)\cdots))$. On octahedral spheres, $S(S^n) \cong S^{n+1}$, so $S^k(S^n) \cong S^{n+k}$.

## 3. The classifying bijection

The engine of the paper is the reduction of a $\mathbb{Z}_2$-map to a finite piece of data.

**Lemma 3.1 (Reconstruction from positive data).** *A $\mathbb{Z}_2$-map $f\colon S^m \to S^n$ is uniquely determined by its positive-vertex data $g = (f(e_0),\dots,f(e_m))$. Conversely, any tuple $g \in V(S^n)^{m+1}$ extends to a (unique) equivariant vertex map by setting $f(i,+) = g_i$ and $f(i,-) = -g_i$.*

*Proof sketch.* Every vertex of $S^m$ is either a positive vertex $e_i = (i,+)$ or its antipode $(i,-)$. Equivariance forces $f(i,-) = -f(i,+) = -g_i$, so the values on positive vertices determine $f$ on all vertices. Conversely, the assignment $f(i,\pm) = \pm g_i$ is equivariant by construction. $\square$

**Lemma 3.2 (Simpliciality is axis-injectivity).** *The equivariant vertex map $f$ induced by data $g = ((\gamma_0,s_0),\dots,(\gamma_m,s_m))$ is simplicial if and only if its coordinate map $\gamma\colon i \mapsto \gamma_i$ is injective.*

*Proof sketch.* ($\Rightarrow$) The positive vertices $\{e_0,\dots,e_m\}$ form a facet of $S^m$ (distinct axes, one each). If $f$ is simplicial their images $\{g_0,\dots,g_m\}$ form a simplex of $S^n$, hence lie on distinct axes, i.e. $\gamma$ is injective.

($\Leftarrow$) Suppose $\gamma$ is injective. Any simplex $\sigma$ of $S^m$ uses distinct axes; write its vertices as $(i, \epsilon_i)$ for $i$ ranging over an axis set $A \subseteq \{0,\dots,m\}$ and signs $\epsilon_i$. Its image consists of the signed vertices $\epsilon_i \cdot g_i$, whose axes are $\{\gamma_i : i \in A\}$. Since $\gamma$ is injective, these axes are distinct, so the image is a simplex of $S^n$. Hence $f$ is simplicial. $\square$

Combining the two lemmas and recording that the data $g$ splits into its sign and coordinate parts gives the central structural statement.

**Theorem 3.3 (Classifying bijection).** *For all $m, n \ge 0$ there is an explicit bijection*
$$
\mathrm{Z2Map}(S^m, S^n) \;\;\xrightarrow{\ \sim\ }\;\; \{+,-\}^{\,m+1} \;\times\; \operatorname{Inj}\big(\{0,\dots,m\},\{0,\dots,n\}\big),
$$
*sending a map $f$ to the pair (sign vector of its positive data, coordinate injection of its positive data). Here $\operatorname{Inj}(A,B)$ denotes the set of injections $A \hookrightarrow B$.*

*Proof sketch.* By Lemma 3.1, $f \mapsto g$ identifies $\mathrm{Z2Map}(S^m, S^n)$ with the set of tuples $g \in V(S^n)^{m+1}$ whose coordinate map is injective (Lemma 3.2). Each such $g$ is equivalent to the pair (sign vector $s \in \{+,-\}^{m+1}$, injective coordinate map $\gamma$). The two directions are mutually inverse by inspection. $\square$

Theorem 3.3 is the precise sense in which antipodal maps of octahedral spheres are **rigid**: the only freedom is *which* axes go *where* (an injection) and *with what sign* (a bit per source axis). Nothing else.

## 4. The exact count

**Theorem 4.1 (Exact enumeration).** *For all $m, n \ge 0$,*
$$
\#\,\mathrm{Z2Map}(S^m, S^n) \;=\; 2^{\,m+1}\cdot (n+1)^{\underline{\,m+1\,}},
$$
*where $(n+1)^{\underline{\,m+1\,}} = (n+1)\,n\,(n-1)\cdots(n-m+1) = (n+1)!/(n-m)!$ is the falling factorial with $m+1$ descending factors (interpreted as $0$ when $m > n$).*

*Proof sketch.* Apply Theorem 3.3 and count the product. The number of sign vectors in $\{+,-\}^{m+1}$ is $2^{m+1}$. The number of injections $\{0,\dots,m\} \hookrightarrow \{0,\dots,n\}$ is the number of ways to choose ordered distinct images for $m+1$ source elements among $n+1$ targets, which is the falling factorial $(n+1)^{\underline{m+1}}$. Multiplying gives the claim. $\square$

**Worked value.** For $m=1$, $n=2$: $2^2 \cdot (3 \cdot 2) = 4 \cdot 6 = 24$ maps $S^1 \to S^2$.

**Proposition 4.2 (Free-action divisor).** *For all $m,n$, $\;2^{\,m+1} \mid \#\,\mathrm{Z2Map}(S^m, S^n)$.*

*Proof sketch.* Immediate from Theorem 4.1: the count is $2^{m+1}$ times an integer. Structurally, the sign vector can be flipped freely and independently on each source axis, so the free $\mathbb{Z}_2^{m+1}$ action on signs partitions the maps into orbits of size $2^{m+1}$. $\square$

## 5. A combinatorial Borsuk–Ulam theorem

**Theorem 5.1 (Existence dichotomy).** *For all $m,n \ge 0$,*
$$
\mathrm{Z2Map}(S^m, S^n) \ne \varnothing \iff \#\,\mathrm{Z2Map}(S^m, S^n) > 0 \iff m \le n.
$$

*Proof sketch.* By Theorem 4.1 the count is a product of the strictly positive factor $2^{m+1}$ with the falling factorial $(n+1)^{\underline{m+1}}$. The falling factorial is positive iff all $m+1$ descending factors $n+1, n, \dots, n-m+1$ are positive, i.e. iff $n - m + 1 \ge 1$, i.e. iff $m \le n$; if $m > n$ one factor is $0$. $\square$

**Corollary 5.2 (Coindex of the octahedral sphere).** *$\operatorname{coind}(S^n) = n$. In particular there is no $\mathbb{Z}_2$-map $S^{n+1} \to S^n$.*

*Proof sketch.* By Theorem 5.1 a map $S^m \to S^n$ exists iff $m \le n$, so the largest such $m$ is $n$; and taking $m = n+1$ shows no map $S^{n+1} \to S^n$ exists. $\square$

Corollary 5.2 is the combinatorial core of the Borsuk–Ulam theorem: the antipodal nonexistence of maps decreasing the sphere dimension. Here it is not an independent theorem but the vanishing of a falling factorial once it runs out of factors.

## 6. The hyperoctahedral group

**Theorem 6.1 (Self-map count).** *For all $n \ge 0$,*
$$
\#\,\mathrm{Z2Map}(S^n, S^n) \;=\; 2^{\,n+1}\,(n+1)! \;=\; |B_{n+1}|,
$$
*the order of the hyperoctahedral group $B_{n+1}$ of signed permutations of $n+1$ symbols.*

*Proof sketch.* Set $m = n$ in Theorem 4.1. The falling factorial becomes $(n+1)^{\underline{n+1}} = (n+1)\,n\cdots 1 = (n+1)!$, and the count is $2^{n+1}(n+1)!$. The group $B_{n+1}$ of symmetries of the $(n+1)$-cross-polytope has exactly this order: $(n+1)!$ permutations of axes times $2^{n+1}$ independent sign choices. $\square$

**Corollary 6.2 (Total rigidity of self-maps).** *Every $\mathbb{Z}_2$-self-map of $S^n$ is a signed permutation of the coordinate axes; in particular it is a bijective simplicial automorphism. There are no non-invertible equivariant self-maps.*

*Proof sketch.* By Theorem 3.3 (with $m = n$) a self-map corresponds to a sign vector together with an injection $\{0,\dots,n\} \hookrightarrow \{0,\dots,n\}$. An injection of a finite set into itself is a bijection, so the coordinate map is a permutation and the map is a signed permutation, hence an automorphism. $\square$

This is the sharpest reading of the rigidity phenomenon: on the diagonal, "map" and "symmetry" coincide. It also explains, structurally, why the coindex is pinned to the dimension — a self-map cannot lose an axis.

## 7. The suspension tower

Recall that the suspension $S(K) = K * S^0$ adjoins a single antipodal pair of poles, raising dimension by one; on octahedral spheres $S(S^n) \cong S^{n+1}$, so iterating gives $S^k(S^n) \cong S^{n+k}$.

**Theorem 7.1 (Suspension raises dimension and coindex in lockstep).** *For all $n, k \ge 0$, $\dim S^{n+k} = n+k$ and $\operatorname{coind}(S^{n+k}) = n+k$. In particular each suspension step increases both the dimension and the coindex by exactly one, and the excess $\dim - \operatorname{coind}$ is fixed at $0$.*

*Proof sketch.* The dimension of $S^{n+k}$ is $n+k$ by definition (its facets have $n+k+1$ vertices). The coindex equals $n+k$ by Corollary 5.2. Both quantities therefore rise by one per suspension step, leaving their difference at $0$. $\square$

**Theorem 7.2 (Stability of the existence dichotomy / excess).** *For all $m, n, k \ge 0$,*
$$
\mathrm{Z2Map}(S^{m+k}, S^{n+k}) \ne \varnothing \iff \mathrm{Z2Map}(S^m, S^n) \ne \varnothing,
$$
*because both are equivalent to $m \le n$. Consequently the excess $n - m$ between source and target dimension is a suspension invariant: simultaneously suspending source and target preserves reachability.*

*Proof sketch.* By Theorem 5.1, $\mathrm{Z2Map}(S^{m+k},S^{n+k}) \ne \varnothing \iff m+k \le n+k \iff m \le n \iff \mathrm{Z2Map}(S^m,S^n)\ne\varnothing$. The condition depends only on the difference $n-m$, which is unchanged when both indices are raised by $k$. $\square$

**Proposition 7.3 (The count is *not* suspension invariant).** *In contrast to existence, the exact count grows along the tower: for all $m, n \ge 0$,*
$$
\#\,\mathrm{Z2Map}(S^{m+1}, S^{n+1}) \;=\; 2\,(n+2)\cdot \#\,\mathrm{Z2Map}(S^{m}, S^{n}).
$$

*Proof sketch.* By Theorem 4.1,
$$
\frac{\#\,\mathrm{Z2Map}(S^{m+1}, S^{n+1})}{\#\,\mathrm{Z2Map}(S^{m}, S^{n})}
= \frac{2^{m+2}\,(n+2)^{\underline{m+2}}}{2^{m+1}\,(n+1)^{\underline{m+1}}}
= 2 \cdot \frac{(n+2)^{\underline{m+2}}}{(n+1)^{\underline{m+1}}}.
$$
Writing out the descending factors, $(n+2)^{\underline{m+2}} = (n+2)(n+1)n\cdots(n-m+1) = (n+2)\cdot(n+1)^{\underline{m+1}}$, so the ratio of falling factorials is exactly $n+2$ and the total ratio is $2(n+2)$. For example $\#\{S^0\to S^0\} = 2$, $\#\{S^1\to S^1\}=8$ (ratio $4 = 2\cdot 2$), $\#\{S^2\to S^2\}=48$ (ratio $6 = 2\cdot 3$). $\square$

**Remark 7.4.** The moral is a clean separation of what suspension does and does not stabilize. Suspension leaves invariant the *qualitative* coindex theory — existence of maps, the value of the coindex, and the excess — precisely because these depend only on the difference $n-m$. It does *not* fix the *quantitative* count, which grows because each new axis multiplies the number of sign choices and enlarges the pool of available target axes. This is exactly the boundary between the enumeration and the classical existence theory: the falling-factorial formula refines existence into multiplicity, but only its positivity, not its value, is a stable invariant of the tower.

## 8. Algorithms

We record the elementary algorithms underlying the enumeration; all run in time polynomial in $m$ and $n$ (indeed linear in $m$ for the closed-form count).

**Algorithm A (Closed-form count).** Given $m, n$, return $2^{m+1}(n+1)^{\underline{m+1}}$ by accumulating the falling factorial as a product of $m+1$ descending factors and multiplying by $2^{m+1}$. Complexity $O(m)$ arithmetic operations (on big integers).

**Algorithm B (Brute-force enumeration and verification).** Given small $m, n$, enumerate all functions from the $2(m+1)$ vertices of $S^m$ to the $2(n+1)$ vertices of $S^n$, filter for equivariance and simpliciality, and count. Used to certify Algorithm A on small cases. Complexity exponential; a practical refinement enumerates only signed axis injections (Algorithm C).

**Algorithm C (Structured enumeration via the classifying bijection).** Enumerate injections $\{0,\dots,m\}\hookrightarrow\{0,\dots,n\}$ and sign vectors $\{+,-\}^{m+1}$ directly, materializing each corresponding map. This produces exactly $2^{m+1}(n+1)^{\underline{m+1}}$ maps with no filtering, matching Algorithm A by construction and Algorithm B by verification.

## 9. Applications and discussion

**Topological combinatorics.** Corollary 5.2 is a self-contained, purely combinatorial route to the equivariant Borsuk–Ulam statement for the standard sphere triangulations, of the kind that underlies chromatic lower bounds (Kneser graphs), Tucker-type lemmas, and fair-division results. The enumerative refinement supplies not just nonexistence above the diagonal but exact multiplicities below it.

**Symmetry and representation theory.** Theorem 6.1 realizes the hyperoctahedral group $B_{n+1}$ as the *entire* endomorphism monoid of $S^n$ in the equivariant simplicial category, a compact statement of the total rigidity of these complexes.

**Enumerative topology.** The suspension analysis (Theorems 7.1–7.2, Proposition 7.3) exemplifies a general principle: a counting formula cleanly separates the *stable* invariants of a tower (here the existence dichotomy and the excess $n-m$, which depend only on differences of indices) from the *unstable* multiplicities (the exact count, which grows by a controlled factor $2(n+2)$ per step).

**Limitations.** The exactness of the count is special to octahedral spheres, whose facet structure imposes *no* constraint beyond axis-distinctness. For general free $\mathbb{Z}_2$-complexes additional simpliciality relations appear, and the count becomes a constrained transversal problem rather than a free product — the subject of the future directions below.

## 10. Future work

The present results sharpen the existence theory of the $\mathbb{Z}_2$-coindex into an exact enumeration and suggest three lines of advance. First, an **enumerative rigidity conjecture** for general finite free $\mathbb{Z}_2$-complexes: for a complex $K$ of dimension $d$ whose facets carry a transitive sign action, the number of equivariant maps $S^m \to K$ should be a polynomial in the facet count, with leading behavior controlled by $2^{m+1}$ and the number of $(m+1)$-cliques of the sign-quotient graph of $K$ — because equivariance again collapses a map to positive-vertex images subject to a single local incompatibility, turning the count into an enumeration of independent transversals in a colored intersection structure. Second, a **realizability program for the excess spectrum**: for every pair $0 \le c \le d$ there should exist a finite free $\mathbb{Z}_2$-complex of dimension exactly $d$ and coindex exactly $c$, with at least $2^{c+1}$ coindex-realizing maps and equality characterizing "coindex-rigid" complexes; this is plausible because suspensions add dimension with a $+1$ shift while joins add coindex with a $+1$ shift, letting the two be tuned independently and making the excess $d-c$ a free parameter. Third, a **sphere-recognition conjecture**: a finite free $\mathbb{Z}_2$-complex $K$ of dimension $n$ satisfying $\#\{S^m \to K\} = 2^{m+1}(n+1)^{\underline{m+1}}$ for all $m \le n$ should be equivariantly isomorphic to the octahedral sphere $S^n$ — because the octahedral count is the maximum possible, so attaining it for all $m$ forces the absence of any extra simpliciality constraint, i.e. the cross-polytope boundary itself.

## Appendix: table of counts

The value $\#\{S^m \to S^n\} = 2^{m+1}(n+1)^{\underline{m+1}}$ for small $m, n$ (rows $m$, columns $n$):

| $m \backslash n$ | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **0** | 2 | 4 | 6 | 8 |
| **1** | 0 | 8 | 24 | 48 |
| **2** | 0 | 0 | 48 | 192 |
| **3** | 0 | 0 | 0 | 384 |

The diagonal entries $2, 8, 48, 384$ are the hyperoctahedral orders $|B_1|, |B_2|, |B_3|, |B_4|$. Entries strictly below the diagonal vanish (Borsuk–Ulam).
