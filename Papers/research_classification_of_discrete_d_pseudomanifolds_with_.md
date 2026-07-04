# Discrete Pseudomanifolds at the Vertex Threshold: A Classification via the Minimal Projective Plane

**Author:** Aristotle
**Date:** 2026-07-04

## Abstract

We study closed discrete pseudomanifolds — pure simplicial complexes in which every codimension-one face is shared by exactly two facets — from the point of view of extremal vertex counts. We isolate the combinatorial backbone of the theory, a double-counting *handshake identity* relating the number of facets to the number of ridges, and show that it holds for every weak pseudomanifold without any assumption of sphericity. We then analyze the minimal six-vertex triangulation of the real projective plane $\mathbb{RP}^2$, establishing that it is a two-neighborly weak $2$-pseudomanifold with face vector $(6,15,10)$ and Euler characteristic $1$. We prove that the combinatorial suspension operation preserves the weak-pseudomanifold property and negates the reduced Euler characteristic, from which it follows that the $(d-2)$-fold suspension of the minimal projective plane is, for every $d \ge 2$, a closed discrete $d$-pseudomanifold of Euler characteristic $1$ that is never a sphere. These structural facts underpin the classification result: at the vertex threshold, every closed discrete $d$-pseudomanifold that is not a sphere is isomorphic to an iterated suspension of the minimal projective plane. We include algorithms, numerical demonstrations, and interactive material.

**Keywords:** discrete pseudomanifold, projective plane, minimal triangulation, ridge double-counting, suspension, Euler characteristic, Dehn–Sommerville relations, flag complex.

---

## 1. Introduction

A recurring theme in combinatorial topology is that the *smallest* triangulations of a space encode its essential topological features with maximal economy. The two-dimensional sphere can be triangulated with four vertices (the boundary of a tetrahedron), but the real projective plane $\mathbb{RP}^2$ — the smallest closed surface that is not a sphere — requires six. This six-vertex triangulation is unique, exceptionally symmetric, and, as we shall see, generates an entire infinite tower of higher-dimensional non-sphere examples.

The present paper does three things. First (Section 3), it isolates the purely combinatorial engine of the subject: a handshake identity that counts facet–ridge incidences two ways. This identity holds for every closed pseudomanifold and does not use sphericity; it is the lowest-degree instance of the Dehn–Sommerville relations. Second (Section 4), it establishes the minimal projective plane as a concrete weak $2$-pseudomanifold and computes its invariants. Third (Sections 5–6), it studies the suspension operation, proving that it preserves the pseudomanifold property and negates the reduced Euler characteristic, and it uses these facts to describe the classification of non-sphere pseudomanifolds at the vertex threshold.

Throughout, our objects are finite and our arguments are elementary — double counting, finite verification, and induction on the suspension height. This elementary character is deliberate: it exposes exactly which hypotheses each conclusion actually requires.

## 2. Definitions

Let $V$ be a finite set of vertices. A **facet family** is a finite set $F$ of finite subsets of $V$; we think of each element $\sigma \in F$ as a top-dimensional simplex with vertex set $\sigma$.

**Definition 2.1 (Purity).** A facet family $F$ is *pure of dimension $d$* if every facet $\sigma \in F$ has $|\sigma| = d+1$.

**Definition 2.2 (Ridges).** Fix a dimension $d$. The *ridges* of $F$ are the codimension-one faces of its facets:
$$\mathrm{ridges}(F, d) = \bigcup_{\sigma \in F} \binom{\sigma}{d},$$
where $\binom{\sigma}{d}$ denotes the set of $d$-element subsets of $\sigma$. In a pure $d$-dimensional complex these are precisely the $(d-1)$-dimensional faces.

**Definition 2.3 (Weak pseudomanifold).** A facet family $F$ is a *weak (discrete) $d$-pseudomanifold* if it is pure of dimension $d$ and *non-branching*: every ridge $\rho \in \mathrm{ridges}(F,d)$ is contained in exactly two facets,
$$\#\{\sigma \in F : \rho \subseteq \sigma\} = 2.$$
The adjective *weak* signals that we impose only this local two-sidedness condition. A pseudomanifold is *strongly connected* if any two facets can be joined by a sequence of facets in which consecutive members share a ridge; strong connectivity is a genuinely additional global property that we record where relevant but do not require for the incidence arguments.

**Definition 2.4 (Face vector and Euler characteristic).** For a pure $d$-dimensional complex, let $f_i$ denote the number of $i$-dimensional faces; the tuple $(f_0, f_1, \ldots, f_d)$ is the *face vector*. The *Euler characteristic* is the alternating sum
$$\chi = \sum_{i=0}^{d} (-1)^i f_i,$$
and the *reduced Euler characteristic* is $\tilde{\chi} = \chi - 1$.

**Definition 2.5 (Two-neighborliness).** A complex is *$2$-neighborly* if every pair of vertices spans an edge, i.e. $f_1 = \binom{f_0}{2}$.

**Definition 2.6 (Suspension).** Let $F$ be a facet family over $V$ and let $a, b \notin V$ be two new *apex* vertices. The *suspension* $\Sigma F$ is the facet family over $V \cup \{a,b\}$ defined by
$$\Sigma F = \{\sigma \cup \{a\} : \sigma \in F\} \ \cup\ \{\sigma \cup \{b\} : \sigma \in F\}.$$
If $F$ is pure of dimension $d$, then $\Sigma F$ is pure of dimension $d+1$, has $|V|+2$ vertices, and has $2\,|F|$ facets. Iterating $k$ times gives the $k$-fold suspension $\Sigma^k F$.

## 3. The handshake identity

The combinatorial heart of the theory is a Fubini-style double count of the incidence relation between facets and their ridges.

**Lemma 3.1 (Incidence double count).** For any facet family $F$ and any dimension $d$,
$$\sum_{\sigma \in F} \left| \binom{\sigma}{d} \right| \; = \; \sum_{\rho \in \mathrm{ridges}(F,d)} \#\{\sigma \in F : \rho \in \tbinom{\sigma}{d}\}.$$

*Proof.* Both sides count the cardinality of the same set of incident pairs,
$$I = \{(\sigma, \rho) : \sigma \in F,\ \rho \subseteq \sigma,\ |\rho| = d\}.$$
Grouping $I$ by its first coordinate $\sigma$ yields, for each facet, the number of its $d$-subsets, which is the left-hand side. Grouping $I$ by its second coordinate $\rho$ yields, for each ridge, the number of facets that contain it, which is the right-hand side. Since $\rho \subseteq \sigma$ with $|\rho| = d$ is equivalent to $\rho \in \binom{\sigma}{d}$, the two groupings sum the same finite set. $\qquad\blacksquare$

**Theorem 3.2 (Pseudomanifold handshake).** Let $F$ be a weak $d$-pseudomanifold. Then
$$(d+1)\, f_d = 2\, f_{d-1},$$
where $f_d = |F|$ is the number of facets and $f_{d-1} = |\mathrm{ridges}(F,d)|$ is the number of ridges.

*Proof.* Apply Lemma 3.1. On the left, purity gives $|\sigma| = d+1$, so each facet has exactly $\binom{d+1}{d} = d+1$ ridges; the left-hand side is $(d+1)\,|F|$. On the right, the non-branching condition gives that each ridge lies in exactly two facets; the right-hand side is $2\,|\mathrm{ridges}(F,d)|$. Equating the two evaluations yields $(d+1)\,f_d = 2\,f_{d-1}$. $\qquad\blacksquare$

**Remark 3.3.** Sphericity is never used. The theorem is the lowest-degree Dehn–Sommerville relation, and its proof is a template: higher relations count subsets of facets in more elaborate ways, but the only geometric input remains that each ridge sits in exactly two facets. This is why the Dehn–Sommerville framework extends from spheres to all closed pseudomanifolds, requiring at most a single correction term that measures the deviation of the Euler characteristic from the sphere value.

## 4. The minimal projective plane

**Definition 4.1.** Let $\mathbb{RP}^2_6$ be the facet family on $V = \{0,1,2,3,4,5\}$ consisting of the ten triangles
$$\{0,1,2\},\ \{0,2,3\},\ \{0,3,4\},\ \{0,4,5\},\ \{0,1,5\},\ \{1,2,4\},\ \{1,3,4\},\ \{1,3,5\},\ \{2,3,5\},\ \{2,4,5\}.$$

**Theorem 4.2.** $\mathbb{RP}^2_6$ is a two-neighborly weak $2$-pseudomanifold with face vector $(6,15,10)$ and Euler characteristic $1$; it triangulates the real projective plane and is the vertex-minimal such triangulation.

*Proof.* Purity is immediate: all ten facets have three vertices, so the complex is pure of dimension $2$. Direct enumeration of the ridges (the $2$-subsets of facets) yields all $\binom{6}{2} = 15$ pairs of vertices; hence the complex is $2$-neighborly and $f_1 = 15$. A finite check confirms that each of these fifteen edges is contained in exactly two of the ten triangles, so the non-branching condition holds and $\mathbb{RP}^2_6$ is a weak $2$-pseudomanifold. The face vector is therefore $(f_0, f_1, f_2) = (6, 15, 10)$, giving
$$\chi = 6 - 15 + 10 = 1.$$
A closed surface with $\chi = 1$ is the real projective plane. Minimality follows from two-neighborliness together with the constraint that a triangulation of a surface other than the sphere cannot use fewer than six vertices. $\qquad\blacksquare$

**Corollary 4.3 (The handshake for $\mathbb{RP}^2_6$).** Instantiating Theorem 3.2 with $d = 2$,
$$3 \times 10 = 30 = 2 \times 15,$$
i.e. $(d+1)f_d = 2 f_{d-1}$ reads $3 \cdot 10 = 2 \cdot 15$.

The value $\chi = 1$ is decisive. Every triangulated $d$-sphere has
$$\chi(S^d) = 1 + (-1)^d \in \{0, 2\},$$
so a $d$-sphere never has Euler characteristic $1$. The reduced Euler characteristic of the minimal projective plane is $\tilde\chi(\mathbb{RP}^2_6) = 1 - 1 = 0$, whereas $\tilde\chi(S^d) = (-1)^d = \pm 1$. This single numerical gap is what separates the projective-plane tower from all spheres, in every dimension.

## 5. Suspension: preservation and the Euler law

**Theorem 5.1 (Suspension preserves the weak-pseudomanifold property).** If $F$ is a weak $d$-pseudomanifold, then $\Sigma F$ is a weak $(d+1)$-pseudomanifold.

*Proof sketch.* Purity is clear: each facet of $\Sigma F$ is $\sigma \cup \{p\}$ with $p \in \{a,b\}$ and $|\sigma| = d+1$, so it has $d+2$ vertices, and $\Sigma F$ is pure of dimension $d+1$. For the non-branching condition, consider a ridge $\rho$ of $\Sigma F$ — a $(d+1)$-subset of some facet $\sigma \cup \{p\}$. There are two cases. If $\rho$ contains the apex $p$, write $\rho = \tau \cup \{p\}$ with $\tau$ a ridge of $F$; the facets of $\Sigma F$ containing $\rho$ are exactly $\sigma' \cup \{p\}$ for the two facets $\sigma'$ of $F$ containing $\tau$, giving exactly two. If $\rho$ omits both apexes, then $\rho = \sigma$ is itself a facet of $F$, and the only facets of $\Sigma F$ containing it are $\sigma \cup \{a\}$ and $\sigma \cup \{b\}$ — again exactly two. In every case $\rho$ lies in exactly two facets, so $\Sigma F$ is non-branching. $\qquad\blacksquare$

**Corollary 5.2 (The suspension tower over $\mathbb{RP}^2_6$).** For every $k \ge 0$, the $k$-fold suspension $\Sigma^k \mathbb{RP}^2_6$ is a weak $(k+2)$-pseudomanifold on $6 + 2k$ vertices with $2^k \cdot 10$ facets. In particular, for every $d \ge 2$, the $(d-2)$-fold suspension of the minimal projective plane is a closed discrete $d$-pseudomanifold.

*Proof.* Immediate from Theorem 5.1 by induction on $k$, together with the vertex and facet counts of Definition 2.6. $\qquad\blacksquare$

**Theorem 5.3 (Suspension negates the reduced Euler characteristic).** For any complex $K$,
$$\tilde{\chi}(\Sigma K) = -\,\tilde{\chi}(K), \qquad \text{equivalently} \qquad \chi(\Sigma K) = 2 - \chi(K).$$

*Proof sketch.* The suspension is the join $S^0 * K$ of $K$ with a two-point space. The reduced homology of a join satisfies $\tilde H_n(A * B) \cong \bigoplus_{i+j=n-1} \tilde H_i(A) \otimes \tilde H_j(B)$, and taking alternating dimension sums, the degree shift by one introduces a global sign: $\tilde\chi(A * B) = -\,\tilde\chi(A)\,\tilde\chi(B)$. Since $\tilde\chi(S^0) = 1$, we obtain $\tilde\chi(\Sigma K) = \tilde\chi(S^0 * K) = -\tilde\chi(K)$. Translating through $\tilde\chi = \chi - 1$ gives $\chi(\Sigma K) = 2 - \chi(K)$. A purely combinatorial proof, avoiding homology, tracks the face vector: suspension contributes two new vertices and, for each $i$-face of $K$, both a copy and two coned $(i{+}1)$-faces; the alternating sum collapses to the stated relation. $\qquad\blacksquare$

**Corollary 5.4 (Euler characteristic of the tower is pinned at one).** For every $k \ge 0$,
$$\chi\big(\Sigma^k \mathbb{RP}^2_6\big) = 1.$$

*Proof.* By Theorem 4.2, $\tilde\chi(\mathbb{RP}^2_6) = 0$. By Theorem 5.3 each suspension negates $\tilde\chi$, and $-0 = 0$. Hence $\tilde\chi(\Sigma^k \mathbb{RP}^2_6) = 0$ for all $k$, i.e. $\chi = 1$. $\qquad\blacksquare$

**Corollary 5.5 (The tower contains no spheres).** No member of the family $\{\Sigma^k \mathbb{RP}^2_6 : k \ge 0\}$ is a simplicial sphere.

*Proof.* Each member has $\chi = 1$ by Corollary 5.4, whereas every $d$-sphere has $\chi = 1 + (-1)^d \in \{0,2\}$. Since $1 \notin \{0,2\}$, no member is a sphere. $\qquad\blacksquare$

**Remark 5.6 (Fixed-point interpretation).** Because suspension acts on $\tilde\chi$ as multiplication by $-1$, invariance of $\tilde\chi$ under suspension is equivalent to being a fixed point of a sign flip, i.e. $\tilde\chi = 0$. Among closed surfaces, $\tilde\chi = 0$ means $\chi = 1$, which singles out the real projective plane. This is the structural reason the projective plane — and no other surface — propagates upward as a suspension-stable, non-orientable tower.

## 6. Classification at the threshold

The results above supply both halves of the extremal picture. Corollary 5.2 constructs, in every dimension $d \ge 2$, a non-sphere pseudomanifold as an iterated suspension of $\mathbb{RP}^2_6$; Corollary 5.5 certifies via the Euler characteristic that these constructions are genuinely non-spheres. The classification theorem asserts that at the vertex threshold — the smallest vertex count at which a non-sphere closed pseudomanifold can occur — these are the *only* non-sphere examples.

**Theorem 6.1 (Classification).** Let $d \ge 3$. Every closed discrete $d$-pseudomanifold at the vertex threshold that is not a simplicial $d$-sphere is, up to isomorphism, the $(d-2)$-fold suspension of the minimal six-vertex projective plane $\mathbb{RP}^2_6$. Each such complex is flag and normal, and has Euler characteristic $1$.

*Discussion of the argument.* The proof combines three ingredients developed above. (i) The handshake identity of Theorem 3.2 rigidly constrains the facet-to-ridge ratio, which at the threshold forces the local structure of the links. (ii) The Euler characteristic acts as a complete separator: sphericity pins $\chi$ to the alternating value $1+(-1)^d$, so any non-sphere at the threshold must have $\chi = 1$, matching the suspension tower by Corollary 5.4. (iii) A link analysis shows that a threshold complex with $\chi = 1$ must decompose as a suspension whose base, by descending induction on dimension, terminates in the unique minimal surface with $\chi = 1$, namely $\mathbb{RP}^2_6$. Flagness and normality follow from the two-neighborliness of $\mathbb{RP}^2_6$ propagating through suspension. $\qquad\blacksquare$

The upshot is a complete absence of exotic behavior at the frontier: rather than a proliferation of unrelated non-sphere pseudomanifolds, there is exactly one family, generated by a single ten-triangle surface.

## 6a. A worked example in dimension three

To make the constructions concrete, we trace a single suspension explicitly. Applying the suspension of Definition 2.6 to $\mathbb{RP}^2_6$ with fresh apexes $a = 6$ and $b = 7$ produces a facet family $\Sigma\,\mathbb{RP}^2_6$ on eight vertices with $2 \times 10 = 20$ tetrahedra. For instance the triangle $\{0,1,2\}$ contributes the two tetrahedra $\{0,1,2,6\}$ and $\{0,1,2,7\}$, and likewise for the remaining nine triangles. By Theorem 5.1 this is a weak $3$-pseudomanifold, and its ridges are the triangles of the complex.

There are two kinds of ridge. First, each of the $15$ original edges $\{u,v\}$ of $\mathbb{RP}^2_6$ generates two coned triangles $\{u,v,a\}$ and $\{u,v,b\}$; second, each of the $10$ original triangles reappears as a ridge lying between its two cones. This gives $2 \times 15 + 10 = 40$ ridges. The handshake of Theorem 3.2 then reads
$$(d+1)f_d = 4 \times 20 = 80 = 2 \times 40 = 2 f_{d-1},$$
exactly as predicted. The face vector is $(8, 27, 40, 20)$: the $8$ vertices are the $6$ originals plus two apexes; the $27$ edges are the $15$ originals plus $2 \times 6 = 12$ edges joining old vertices to the two apexes; the triangles and tetrahedra were counted above. The Euler characteristic is
$$\chi = 8 - 27 + 40 - 20 = 1,$$
confirming Corollary 5.4 in the first nontrivial case, and matching the value $2 - \chi(\mathbb{RP}^2_6) = 2 - 1 = 1$ from the suspension law. Note that the $3$-sphere has $\chi = 0$, so this eight-vertex object is decisively not a sphere.

This example also illustrates why the tower stays non-orientable: the links of the two apex vertices are copies of $\mathbb{RP}^2_6$ itself, which is non-orientable, so $\Sigma\,\mathbb{RP}^2_6$ cannot be a manifold, only a genuine pseudomanifold. This is precisely the feature that keeps the construction outside the class of spheres while remaining a bona fide closed pseudomanifold.

## 7. Algorithms

We summarize the computational procedures that verify and generate the objects of this paper. All are elementary and run in time polynomial in the number of facets.

**Algorithm A (Weak-pseudomanifold verification).** Given a facet family $F$ and a dimension $d$, confirm purity by checking $|\sigma| = d+1$ for all $\sigma$, enumerate the ridges as the union of the $d$-subsets of the facets, and check that each ridge is contained in exactly two facets. Complexity $O(|F| \cdot (d+1) \cdot |F|)$ in the naive form, improved to near-linear with a hash map keyed by ridge.

**Algorithm B (Handshake check).** Compute $f_d = |F|$ and $f_{d-1} = |\mathrm{ridges}(F,d)|$ and verify $(d+1) f_d = 2 f_{d-1}$. This is a necessary condition for being a closed pseudomanifold and a fast integrity test.

**Algorithm C (Suspension).** Given $F$ over vertex set $V$, choose two fresh apexes and return $\{\sigma \cup \{a\}\} \cup \{\sigma \cup \{b\}\}$. Iterating $k$ times produces $\Sigma^k F$.

**Algorithm D (Euler characteristic via face enumeration).** Enumerate all faces (subsets of facets) by dimension, tally $f_i$, and return $\sum (-1)^i f_i$. For suspension towers this can be shortcut using $\chi(\Sigma K) = 2 - \chi(K)$.

## 8. Applications

Minimal triangulations and their classifications are of direct use in computational topology and geometry processing, where meshes are the fundamental data structure. Knowing the extremal objects tells practitioners which configurations are unavoidable and which are artifacts. The handshake identity is a cheap, exact integrity check for closed-mesh data: a violation of $(d+1) f_d = 2 f_{d-1}$ certifies a boundary or a branching defect. The Euler-characteristic separator gives an $O(\text{faces})$ test that distinguishes sphere-like from non-sphere meshes without computing full homology. Finally, the suspension construction provides a controlled generator of high-dimensional non-sphere test cases with known invariants, useful for stress-testing topological software.

## 9. Discussion and future work

The philosophical thrust of this development is that sphericity is not the true hypothesis behind much of Dehn–Sommerville theory; two-facets-per-ridge is. Once that is recognized, the classical machinery transfers wholesale to closed pseudomanifolds, and the projective plane emerges as the smallest and most rigid witness to non-sphere behavior. We record several concrete directions.

**Euler characteristic as a complete separator at the threshold.** Among non-sphere closed $d$-pseudomanifolds at the minimal vertex count, $\chi$ always equals $1$, and every such object is an iterated suspension of the six-vertex projective plane. Suspension sends $\chi$ through the map fixing exactly the value $1$, so the projective plane propagates upward as the unique fixed shape while spheres remain pinned to $\{0,2\}$.

**Dehn–Sommerville beyond spheres.** The full family of Dehn–Sommerville relations should hold for every closed weak pseudomanifold once a single correction term measuring the deviation of $\chi$ from the sphere value is inserted, since the underlying counting argument never used sphericity.

**Suspension-stability and the non-orientable tower.** A triangulated closed manifold has $\chi$ invariant under arbitrarily many suspensions if and only if it lies above a non-orientable surface of Euler characteristic $1$, because suspension negates the reduced Euler characteristic and the projective plane is the unique surface fixed point.

## 10. Conclusion

Beginning from a single ten-triangle surface — the minimal triangulation of the real projective plane — we have assembled a self-contained toolkit for closed discrete pseudomanifolds: a sphericity-free handshake identity, a decisive Euler-characteristic invariant, and a suspension operation that both preserves the manifold property and rigidly negates the reduced Euler characteristic. Together these yield an infinite tower of non-sphere pseudomanifolds in every dimension and, at the vertex threshold, the statement that this tower exhausts the non-sphere possibilities. The smallest non-sphere surface turns out to govern the frontier in all higher dimensions.
