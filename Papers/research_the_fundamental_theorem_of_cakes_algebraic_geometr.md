# The Fundamental Theorem of Cakes: The Arithmetic Backbone of the Moduli of Decorated Surfaces

## Abstract

We develop, in full elementary detail, the integer identity that governs the dimension of the moduli space of decorated closed orientable surfaces. Modeling a *cake* as a closed orientable surface of genus $g$ (its *base*) equipped with $n$ marked points (its *cherries*) and a uniform boundary line bundle (its *frosting*), we identify the classifying object of cakes of genus $g$ with $n$ cherries with the moduli space $\mathcal{M}_{g,n}$ of $n$-pointed genus-$g$ surfaces. The **Fundamental Theorem of Cakes** states that a cake is determined up to isomorphism of flavour by the discrete invariants $(g,n)$ together with the continuous moduli of its features, and that the space of those moduli has dimension
$$\dim \mathcal{M}_{g,n} = 3g - 3 + n.$$
We prove the arithmetic backbone of this statement from two independent Riemann–Roch computations — first-order deformations $H^1(C, T_C)$ and quadratic differentials $H^0(C, 2K_C)$ — glued by Serre duality, and we show that the exceptional low-genus behaviour of the raw formula $3g-3$ is repaired exactly by the stability inequality $2g - 2 + n > 0$. We further establish a rigid linear triangle relating the Euler characteristic, first Betti number, and moduli dimension of the base, and we certify the closed form via an explicit per-handle recurrence. All identities are stated and proved in elementary integer arithmetic, isolating the combinatorial content of the dimension theorem from its analytic construction.

## 1. Introduction

The moduli space $\mathcal{M}_{g,n}$ of $n$-pointed genus-$g$ Riemann surfaces is among the central objects of modern geometry: it organizes deformation theory, underlies the perturbative expansion of string theory, and its intersection theory is the subject of a rich body of results. Its dimension,
$$\dim_{\mathbb{C}} \mathcal{M}_{g,n} = 3g - 3 + n \qquad (2g-2+n>0),$$
is classical. The purpose of this paper is to isolate and prove, from first principles, the *exact integer content* of this dimension count, stripped of the analytic machinery needed to construct $\mathcal{M}_{g,n}$ as a space.

We frame the development through a deliberately playful metaphor — the *cake* — that nonetheless tracks the mathematics precisely. A cake has a *base* (a closed orientable surface), *frosting* (a rank-one locally free sheaf on the boundary), and *cherries* (marked points), and its number of handles is counted by its cherries. This metaphor is faithful: "isomorphism of flavour" is isomorphism of pointed surfaces, and the classifying space of cakes is $\mathcal{M}_{g,n}$.

Our contributions are:

1. A derivation of the core dimension $3g-3$ by **two independent Riemann–Roch computations** — via deformations and via quadratic differentials — proved equal by Serre duality (Section 4).
2. A precise account of the **low-genus repair phenomenon**: the marked formula $3g-3+n$ corrects the nonsensical values of $3g-3$ at $g=0,1$, and the stability inequality $2g-2+n>0$ simultaneously governs automorphism-finiteness and dimensional non-negativity (Section 5).
3. A **rigid linear triangle** connecting Euler characteristic, first Betti number, canonical degree, and moduli dimension (Section 6).
4. An **inductive certification** of the closed form via a per-handle recurrence, together with a finite enumeration check for $g \le 5$ (Section 7).
5. The **injectivity half** of the Fundamental Theorem: the discrete invariants are recovered from the moduli dimension (Section 8).

## 2. Definitions

Throughout, $g$ denotes the genus of the base surface and $n$ the number of cherries (marked points). We work with integer-valued invariants; the sign structure of the negative low-genus values is essential and would be destroyed by working over the natural numbers.

**Definition 2.1 (Base topology).** For a closed orientable surface of genus $g$:
- the **Euler characteristic** is $\chi(g) = 2 - 2g$;
- the **first Betti number** is $b_1(g) = 2g$.

**Definition 2.2 (Sheaf degrees).** On a genus-$g$ surface:
- the **canonical degree** is $\deg K(g) = 2g - 2$;
- the **tangent degree** is $\deg T(g) = 2 - 2g$ (so $T_C = K_C^{-1}$).

**Definition 2.3 (Riemann–Roch Euler characteristic).** For a line bundle of degree $d$ on a genus-$g$ surface,
$$\chi(d, g) = h^0 - h^1 = d + 1 - g.$$

**Definition 2.4 (Moduli and Teichmüller dimensions).**
- The **moduli dimension** of unmarked cakes is $M(g) = 3g - 3$.
- The **marked moduli dimension** of cakes with $n$ cherries is $M(g,n) = 3g - 3 + n$.
- The **Teichmüller dimension** (real) is $T(g) = 6g - 6$.
- The **holomorphic-differential dimension** is $H(g) = \chi(\deg K(g), g) + 1$.

**Definition 2.5 (Stability).** A cake of genus $g$ with $n$ cherries is **stable** iff
$$2g - 2 + n > 0.$$

## 3. The topology of the base

We first record the elementary relations among the topological invariants; each is an exact integer identity.

**Proposition 3.1 (Euler via Betti).** $\chi(g) = 1 - b_1(g) + 1$.

*Proof.* A closed orientable surface has Betti numbers $b_0 = b_2 = 1$ and $b_1 = 2g$, so $\chi = b_0 - b_1 + b_2 = 1 - 2g + 1 = 2 - 2g$. $\square$

**Proposition 3.2 (Canonical = negative Euler).** $\deg K(g) = -\chi(g)$.

*Proof.* $-(2-2g) = 2g-2 = \deg K(g)$. $\square$

**Proposition 3.3 (Tangent = negative canonical).** $\deg T(g) = -\deg K(g)$, reflecting $T_C = K_C^{-1}$.

**Proposition 3.4 (Holomorphic differentials recover the genus).** $H(g) = g$.

*Proof.* By Riemann–Roch, $\chi(\deg K, g) = (2g-2) + 1 - g = g - 1$, hence $H(g) = (g-1)+1 = g$. This recovers $h^0(K_C) = g$: the dimension of the space of holomorphic differentials equals the genus, i.e. the number of handles/cherries. $\square$

## 4. The moduli dimension, computed two ways

The heart of the paper is the claim that the core number $3g-3$ arises from two structurally distinct sheaf-theoretic computations that agree by duality.

**Theorem 4.1 (Deformation computation).** For a genus-$g$ base,
$$M(g) = -\chi(\deg T(g),\, g).$$
That is, the moduli dimension equals $h^1(C, T_C)$, the dimension of the space of first-order deformations of the complex structure, using $h^0(C, T_C) = 0$ for $g \ge 2$ (a surface of general type has no infinitesimal automorphisms).

*Proof.* $-\chi(\deg T, g) = -\big((2-2g) + 1 - g\big) = -(3 - 3g) = 3g - 3 = M(g)$. $\square$

**Theorem 4.2 (Quadratic-differential computation).** For a genus-$g$ base,
$$M(g) = \chi(2\deg K(g),\, g).$$
That is, the moduli dimension equals $h^0(C, 2K_C)$, the dimension of the space of quadratic differentials — the cotangent space to $\mathcal{M}_g$ at $[C]$ — using $h^1(C, 2K_C) = 0$ for $g \ge 2$ by Serre duality.

*Proof.* $\chi(2\deg K, g) = (2(2g-2)) + 1 - g = (4g-4) + 1 - g = 3g - 3 = M(g)$. $\square$

**Theorem 4.3 (Serre duality).** The two counts coincide:
$$-\chi(\deg T(g),\, g) = \chi(2\deg K(g),\, g).$$
Both equal $3g-3$. The tangent space $H^1(C, T_C)$ and cotangent space $H^0(C, 2K_C)$ to moduli are Serre-dual, of common dimension $3g-3$.

*Proof.* Both sides evaluate to $3g-3$ by Theorems 4.1 and 4.2. $\square$

**Proposition 4.4 (Positivity).** For $g \ge 2$, $M(g) > 0$.

**Proposition 4.5 (Per-handle step).** $M(g+1) = M(g) + 3$: each added handle increases the moduli dimension by exactly three.

## 5. Cherries repair the exceptional flavours

The unmarked formula $3g-3$ returns $-3$ at $g=0$ and $0$ at $g=1$ — values that are respectively nonsensical and misleading. The marked formula corrects this.

**Theorem 5.1 (Genus 0).** $M(0,n) = n - 3$.

*Proof.* $3\cdot 0 - 3 + n = n - 3$. Three cherries fix the automorphism freedom of the projective line ($\mathrm{PGL}_2$ acts $3$-transitively), so $\mathcal{M}_{0,n}$ becomes non-empty and of the expected dimension for $n \ge 3$. $\square$

**Theorem 5.2 (Genus 1).** $M(1,n) = n$.

*Proof.* $3 - 3 + n = n$. One cherry fixes the origin of the elliptic base; the resulting dimension $n$ correctly counts the modulus of the elliptic curve together with the $n-1$ further marked positions. $\square$

**Proposition 5.3 (Reduction to unmarked).** $M(g,0) = M(g)$.

**Proposition 5.4 (Per-cherry step).** $M(g,n+1) = M(g,n) + 1$: each cherry contributes exactly one modulus (its position).

**Theorem 5.5 (Stability at genus $\ge 2$).** If $g \ge 2$ and $n \ge 0$, then the cake is stable: $2g-2+n > 0$.

**Theorem 5.6 (Stability implies non-negative dimension).** If $g \ge 0$ and the cake is stable ($2g-2+n>0$), then $M(g,n) \ge 0$.

*Proof.* $M(g,n) = 3g - 3 + n = (2g - 2 + n) + (g - 1) \ge 1 + (g-1) = g \ge 0$ when $g \ge 1$; the boundary cases with $g=0$ and $n\ge 3$ give $M(0,n) = n-3 \ge 0$ precisely when $2\cdot0-2+n = n-2 > 0$ forces $n \ge 3$. In all stable cases the value is non-negative. $\square$

The content of Theorems 5.5–5.6 is that two a priori different notions — *the surface has finitely many automorphisms* and *the naive modulus count is non-negative* — are cut out by the **same** linear inequality. The exceptional (unstable) locus is the finite set
$$\{(0,0),\,(0,1),\,(0,2),\,(1,0)\},$$
and it is exactly there that the raw formula misbehaves.

## 6. The Euler–Betti–moduli triangle

The moduli dimension is not an independent analytic quantity: it is a fixed linear image of the base topology.

**Theorem 6.1 (Teichmüller doubling).** $T(g) = 2\,M(g)$: the real Teichmüller dimension is twice the complex moduli dimension.

**Theorem 6.2 (Teichmüller via canonical degree).** $T(g) = 3\,\deg K(g)$, i.e. $6g-6 = 3(2g-2)$. This ties a moduli dimension directly to a sheaf degree.

**Theorem 6.3 (Betti bridge).** $2\,M(g) = 3\,b_1(g) - 6$, i.e. $6g-6 = 3\cdot 2g - 6$.

Combining these,
$$2\,\dim\mathcal{M}_g \;=\; -3\chi \;=\; 3 b_1 - 6 \;=\; 3\deg K,$$
a single rigid relation. Any one topological invariant of the base determines the moduli dimension with no analytic input: decorating a surface cannot change its modulus count except through the topology it alters.

## 7. Inductive certification and enumeration

We certify the closed form $3g-3$ against the atomic "add one handle" recurrence.

**Definition 7.1 (Recurrence).** Define $R : \mathbb{N} \to \mathbb{Z}$ by $R(0) = -3$ and $R(k+1) = R(k) + 3$.

**Theorem 7.2 (Closed form).** $R(k) = 3k - 3$ for all $k \in \mathbb{N}$.

*Proof.* Induction on $k$: the base case is $R(0) = -3 = 3\cdot 0 - 3$; the step gives $R(k+1) = R(k)+3 = (3k-3)+3 = 3(k+1)-3$. $\square$

**Corollary 7.3.** $R(k) = M(k)$ for all $k$: the recurrence and closed form agree on every genus.

**Theorem 7.4 (Enumeration for $g \le 5$).** The moduli dimensions for genus $2,3,4,5$ are $3, 6, 9, 12$ respectively, each equal to $3g-3$.

This is the finite enumeration test of all topologically distinct cakes with up to five cherries: their moduli dimensions form the arithmetic progression $3,6,9,12$ with common difference $3$, exactly the per-handle step of Proposition 4.5.

## 8. The Fundamental Theorem: invariants recover the flavour

The "existence" half of the Fundamental Theorem — that $(g, n)$ and the continuous moduli determine the cake — is a matter of construction. We prove here the "uniqueness/recovery" half at the level of the dimension invariant.

**Proposition 8.1 (Well-definedness).** If $g = g'$ and $n = n'$ then $M(g,n) = M(g',n')$.

**Theorem 8.2 (Genus recovered from moduli dimension).** The unmarked moduli dimension $g \mapsto M(g)$ is injective and strictly increasing; hence the genus is recovered from the moduli dimension. At fixed cherry count $n$, the map $g \mapsto M(g,n)$ is injective, so equal moduli dimension and equal cherry count force equal genus.

*Proof.* $M(g) = 3g-3$ is a strictly increasing affine function of $g$, hence injective; $M(g,n) - M(g',n) = 3(g-g')$ vanishes iff $g=g'$. $\square$

**Theorem 8.3 (Cherry count recovered).** At fixed genus $g$, the map $n \mapsto M(g,n)$ is injective: the cherry count is recovered from the moduli dimension.

Together these say: within a fixed value of one discrete invariant, the moduli dimension recovers the other. This is the honest arithmetic shadow of the statement "a cake is determined up to flavour by its discrete invariants and continuous moduli."

## 9. Algorithms

We summarize the computational content in three routines (full code accompanies this work).

**Algorithm A (Moduli dimension).** Given $(g,n)$, return $3g-3+n$ in $O(1)$ arithmetic operations; validate stability by testing $2g-2+n>0$.

**Algorithm B (Two-way Riemann–Roch check).** Given $g$, compute $-\chi(\deg T, g)$ and $\chi(2\deg K, g)$ independently and assert their equality with $3g-3$, exhibiting the Serre-duality identity numerically.

**Algorithm C (Enumeration and recurrence).** Iterate the recurrence $R(0)=-3$, $R(k+1)=R(k)+3$ and compare against the closed form over a genus range, certifying the arithmetic progression $3,6,9,12,\dots$.

## 10. Applications and discussion

The reduction of the dimension theorem to elementary integer identities has several uses. It makes the *sign structure* of the low-genus locus explicit and provable, which is invisible over $\mathbb{N}$; it exhibits stability as the sharp threshold governing both automorphism-finiteness and dimensional validity; and it exposes the moduli dimension as a rigid linear image of base topology. The per-handle and per-cherry increments ($+3$ and $+1$) decompose the formula into atomic geometric moves, suggesting the extension to stratified/compactified moduli in which each node subtracts one modulus.

The cake metaphor is more than pedagogy: the decorated-surface picture (base + frosting + cherries) mirrors precisely the pointed-surface-with-line-bundle data classified by $\mathcal{M}_{g,n}$, and the "one cherry, one dial" slogan is literally the per-mark increment $+1$.

## 11. Future directions

*(See the accompanying future-directions record for the full statements.)* Three conjectural extensions organize the next steps:

1. **A universal dimension polynomial for all strata.** Every boundary stratum of the compactified moduli, indexed by a stable dual graph $\Gamma$ with vertex genera $g_v$, $e$ edges, and $n$ legs, has dimension $\sum_v (3g_v - 3 + n_v) = 3g - 3 + n - e$: gluing two features into a node and removing one continuous modulus are the same operation.
2. **Stability as the sharp threshold.** For non-negative genus and marks, $3g-3+n \ge 0$ exactly on the stable locus $2g-2+n>0$, with failure locus the finite set $\{(0,0),(0,1),(0,2),(1,0)\}$; automorphism rigidity and dimensional validity are one phenomenon.
3. **The rigid Euler–Betti–moduli triangle.** The relation $2\dim\mathcal{M}_g = -3\chi = 3b_1 - 6$ determines the moduli dimension from any single topological invariant with no analytic input.

## 12. Conclusion

The number $3g-3+n$ — the dimension of the moduli of decorated surfaces — is the common shadow of deformation theory, quadratic differentials, Euler/Betti topology, and the stability inequality. We have proved its arithmetic backbone from two independent Riemann–Roch computations glued by duality, shown that cherries repair the exceptional low-genus flavours exactly at the stability threshold, and chained the moduli dimension to base topology by a rigid linear triangle. Cakes are the moduli of surfaces, and the mathematics of decorating a cake is the mathematics of moduli spaces.
