# The Suspension Tower of a Free $\mathbb{Z}_2$-Complex and the Excess Spectrum of the Cross-Polytope Spheres

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We develop a purely combinatorial theory of free $\mathbb{Z}_2$-complexes and their equivariant (antipodal) simplicial maps, taking as models the boundary spheres $S^n$ of the $(n+1)$-dimensional cross-polytopes with the coordinate-swap involution. Within this model we assemble the **suspension operation** into a rigorous endofunctor of the category of antipodal maps and construct the **suspension tower** $\Sigma^k$, the $k$-fold iterate that lifts a map $S^m \to S^n$ to $S^{m+k} \to S^{n+k}$. We prove the functor laws — preservation of identities and composition — and lift them to the tower by induction. We then establish two complementary propagation principles: a *constructive* one (the tower preserves every coindex witness, so lower bounds climb the tower undiminished) and an *obstructive* one (two descent lemmas, obtained by composing with the equatorial inclusion, spread a single non-existence fact across an entire cone of dimensions). Combining descent with three finite Borsuk–Ulam base instances — the exhaustively verifiable non-existence of antipodal maps $S^1 \to S^0$, $S^2 \to S^1$, and $S^3 \to S^2$ — yields the non-existence of antipodal maps $S^{m+1} \to S^0$, $S^{m+2} \to S^1$, and $S^{m+3} \to S^2$ for all $m$. Together with the diagonal lower bound this pins the coindex exactly, $\operatorname{coind}(S^n) = n$ for $n \in \{0,1,2\}$, showing that the bottom three rungs of the suspension tower each raise the coindex by precisely one unit.

**Keywords:** Borsuk–Ulam theorem, free $\mathbb{Z}_2$-complex, antipodal map, cross-polytope, suspension, coindex, functoriality, equivariant topology.

## 1. Introduction

The Borsuk–Ulam theorem asserts that every continuous map $S^n \to \mathbb{R}^n$ identifies a pair of antipodal points, or equivalently that there is no continuous antipodal (odd) map $S^n \to S^{n-1}$. Reformulated in the language of equivariant topology, it says that the *$\mathbb{Z}_2$-coindex* of the sphere $S^n$ — the largest $d$ for which an equivariant map $S^d \to S^n$ exists — equals $n$. The coindex, and its companion the index, are among the most useful numerical invariants in topological combinatorics, controlling lower bounds for problems ranging from the Ham Sandwich theorem to the chromatic numbers of Kneser graphs.

This paper isolates a completely finite, combinatorial core of this circle of ideas and organizes it around a single structural device: the **suspension tower**. We work throughout in the category whose objects are the cross-polytope boundary spheres with their antipodal involution and whose morphisms are equivariant simplicial maps. The contributions are:

1. A proof that the suspension operation is an **endofunctor** (Section 4), including the iterated tower and its lifted functor laws.
2. A **constructive propagation** theorem: the tower preserves coindex witnesses, so every lower bound is stable under iterated suspension (Section 5).
3. Two **descent principles** that turn one non-existence statement into a cone of them (Section 6).
4. A determination of the **excess spectrum at the base**: the coindex increment of the tower is exactly one at each of the bottom three rungs, giving $\operatorname{coind}(S^n) = n$ for $n \le 2$ (Section 7).

The development is elementary and self-contained; the only non-combinatorial ingredient is the exhaustive verification of three finite base cases.

## 2. The combinatorial model

### 2.1 Cross-polytope spheres

For $n \ge 0$, the $(n+1)$-dimensional **cross-polytope** is the convex hull of $\{\pm e_0, \dots, \pm e_n\}$ in $\mathbb{R}^{n+1}$. We take as our model of the sphere $S^n$ its boundary complex, described purely combinatorially as follows.

**Definition 2.1 (vertices).** The vertex set of $S^n$ is
$$V(S^n) = \{\,(i, b) : i \in \{0, 1, \dots, n\},\ b \in \{0, 1\}\,\},$$
so $|V(S^n)| = 2(n+1)$. We think of $(i,0)$ as $+e_i$ and $(i,1)$ as $-e_i$; the first coordinate $i$ is the **axis** and $b$ is the **sign**.

**Definition 2.2 (antipodal involution).** The free involution $a : V(S^n) \to V(S^n)$ is $a(i,b) = (i, 1-b)$, swapping the sign. It has no fixed points, so the $\mathbb{Z}_2$-action is **free**.

**Definition 2.3 (simplices).** A subset $\sigma \subseteq V(S^n)$ is a **simplex** iff it contains at most one vertex from each antipodal pair, i.e. it never contains both $(i,0)$ and $(i,1)$. The maximal simplices (**facets**) are exactly the sign-selections $\{(i, s_i) : i = 0, \dots, n\}$ for $s \in \{0,1\}^{n+1}$; there are $2^{n+1}$ of them, each of dimension $n$.

This is the standard boundary triangulation of the cross-polytope, and it is the antipodal join $S^0 * S^0 * \cdots * S^0$ of $n+1$ copies of the two-point sphere $S^0$.

### 2.2 Antipodal maps

**Definition 2.4 (antipodal map).** For $m, n \ge 0$, an **antipodal map** (equivariant simplicial map) $F : S^m \to S^n$ consists of a vertex map $f : V(S^m) \to V(S^n)$ such that:
- **(equivariance)** $f(a(v)) = a(f(v))$ for all $v$; and
- **(simpliciality)** $f(\sigma)$ is a simplex of $S^n$ whenever $\sigma$ is a simplex of $S^m$.

We write $\mathrm{Map}(S^m, S^n)$ for the set of antipodal maps.

Because equivariance and simpliciality are *properties* of the underlying vertex map, an antipodal map carries no data beyond $f$. This gives the basic rigidity lemma on which everything else rests.

**Lemma 2.5 (Extensionality).** Two antipodal maps $F, G : S^m \to S^n$ are equal iff their underlying vertex maps agree, $f = g$.

*Proof sketch.* The equivariance and simpliciality conditions are propositions attached to the vertex map; two records with equal vertex maps have identical (proof-irrelevant) auxiliary data, hence are equal. $\qquad\blacksquare$

**Identity and composition.** For each $n$ the identity vertex map yields the **identity antipodal map** $\mathrm{id}_{S^n}$, and if $F : S^m \to S^n$ and $G : S^n \to S^k$ are antipodal maps then the vertex-wise composite is an antipodal map $G \circ F : S^m \to S^k$ (equivariance and simpliciality compose). Thus the cross-polytope spheres and antipodal maps form a category.

### 2.3 The coindex

**Definition 2.6 (coindex).** The **$\mathbb{Z}_2$-coindex** of $S^n$ is $\operatorname{coind}(S^n) = \max\{\, d : \mathrm{Map}(S^d, S^n) \ne \varnothing \,\}$.

Two elementary maps anchor the theory. First, whenever $m \le n$ there is an antipodal map $S^m \to S^n$: send axis $i$ to axis $i$ preserving signs (an axis-preserving inclusion of the smaller cross-polytope into the larger one). We call the existence statement the **diagonal lower bound**. In particular the self-map $\mathrm{id}_{S^n}$ shows $\operatorname{coind}(S^n) \ge n$. Second, the **equatorial inclusion** $\iota_n : S^n \hookrightarrow S^{n+1}$ realizes $S^n$ as the equator of $S^{n+1}$ by embedding the first $n+1$ axes, omitting the polar axis; it is an antipodal map used repeatedly below.

## 3. Structural characterization

It is illuminating to record the exact criterion for existence of an antipodal map in this model, which underlies both the constructive and obstructive halves of the theory.

**Proposition 3.1 (existence criterion).** By equivariance, an antipodal map $F : S^m \to S^n$ is determined by its values $g(i) := f(i,0) \in V(S^n)$ on the positive vertices, since $f(i,1) = a(g(i))$. Simpliciality holds iff the axes of $g(0), \dots, g(m)$ are pairwise distinct; equivalently, $F$ induces an injection on axes. Consequently $\mathrm{Map}(S^m, S^n) \ne \varnothing$ iff $m \le n$.

*Proof sketch.* Fix distinct domain axes $i \ne j$ and write $g(i) = (a_i, c_i)$, $g(j) = (a_j, c_j)$. The facet obtained by choosing signs $s_i, s_j$ contains $(i,s_i)$ and $(j,s_j)$, whose images are $(a_i, c_i \oplus s_i)$ and $(a_j, c_j \oplus s_j)$. If $a_i = a_j$, one may choose $s_i, s_j$ making these two images antipodal, so the image of that facet is not a simplex; hence simpliciality forces $a_i \ne a_j$. Conversely, distinct axes guarantee no image facet contains an antipodal pair. Distinct axes for the $m+1$ positive vertices require $m+1 \le n+1$. $\qquad\blacksquare$

Proposition 3.1 is the "clean" statement of Borsuk–Ulam for this model. The remaining sections do not presuppose it in full generality; rather, they *rebuild* both directions functorially, proving the impossibility direction only up to the base rungs that can be verified by exhaustive search, while the lifting and descent machinery extends those verified rungs across infinitely many dimensions.

## 4. Suspension as an endofunctor

### 4.1 The suspension operation

**Definition 4.1 (suspension).** The **suspension** of an antipodal map $F : S^m \to S^n$ is the antipodal map $\Sigma F : S^{m+1} \to S^{n+1}$ whose vertex map acts by cases on the domain axis:
- on the *equatorial* axes $i \le m$ (the `castSucc` vertices), $\Sigma F$ acts as $F$: $(i,b) \mapsto f(i,b)$ mapped into the first $n+1$ axes of $S^{n+1}$;
- on the new *polar* axis $m+1$ (the `last` vertex), $\Sigma F$ sends the north pole to the north pole and the south pole to the south pole: $(m+1, b) \mapsto (n+1, b)$.

Geometrically $\Sigma F$ is the join $F * \mathrm{id}_{S^0}$: it is $F$ on the equator and the identity on the added suspension poles. Equivariance and simpliciality are immediate from those of $F$ together with the fresh, otherwise-unused polar axis.

### 4.2 Functor laws

**Theorem 4.2 (functoriality).** Suspension preserves identities and composition:
$$\Sigma(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+1}}, \qquad \Sigma(G \circ F) = \Sigma G \circ \Sigma F.$$

*Proof sketch.* By Lemma 2.5 it suffices to check equality of vertex maps, and by the case split of Definition 4.1 it suffices to check separately on the polar (`last`) vertex and on the equatorial (`castSucc`) vertices. On the polar axis both sides send $(\cdot, b) \mapsto (\cdot, b)$; on the equatorial axes both sides reduce to the identity resp. the composite of the underlying maps. $\qquad\blacksquare$

Thus suspension is an endofunctor of the category of antipodal maps between cross-polytope spheres.

### 4.3 The tower

**Definition 4.3 (suspension tower).** For $F : S^m \to S^n$ define the **$k$-fold suspension** $\Sigma^k F : S^{m+k} \to S^{n+k}$ recursively by $\Sigma^0 F = F$ and $\Sigma^{k+1} F = \Sigma(\Sigma^k F)$.

**Theorem 4.4 (functor laws for the tower).** For every height $k$,
$$\Sigma^k(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+k}}, \qquad \Sigma^k(G \circ F) = \Sigma^k G \circ \Sigma^k F.$$

*Proof sketch.* Induction on $k$. The base $k=0$ is immediate. The inductive step applies the single-step laws of Theorem 4.2 to the height-$k$ instance supplied by the induction hypothesis. $\qquad\blacksquare$

## 5. Constructive propagation: lower bounds climb the tower

**Theorem 5.1 (lifting).** If $\mathrm{Map}(S^m, S^n) \ne \varnothing$ then $\mathrm{Map}(S^{m+k}, S^{n+k}) \ne \varnothing$ for every $k$.

*Proof.* Apply $\Sigma^k$ to a witness. $\qquad\blacksquare$

**Corollary 5.2 (diagonal bound is tower-stable).** If $m \le n$ then $\mathrm{Map}(S^{m+k}, S^{n+k}) \ne \varnothing$ for every $k$.

*Proof.* Combine the diagonal lower bound with Theorem 5.1. $\qquad\blacksquare$

**Corollary 5.3 (base-point tower).** For all $n, k$ there is an antipodal map $S^k \to S^{n+k}$.

*Proof.* Suspend the equatorial map $S^0 \to S^n$ (the case $m = 0$ of the diagonal bound) $k$ times. $\qquad\blacksquare$

The upshot: whatever symmetric complexity is present at the bottom of the tower is preserved, undiminished, at every higher rung.

## 6. Obstructive propagation: descent principles

The impossibility direction propagates through composition with the equatorial inclusion $\iota$.

**Theorem 6.1 (codomain descent).** If $\mathrm{Map}(S^m, S^{n+1}) = \varnothing$ then $\mathrm{Map}(S^m, S^n) = \varnothing$.

*Proof.* Any $F : S^m \to S^n$ would give $\iota_n \circ F : S^m \to S^{n+1}$, contradicting the hypothesis. $\qquad\blacksquare$

**Theorem 6.2 (domain ascent).** If $\mathrm{Map}(S^m, S^n) = \varnothing$ then $\mathrm{Map}(S^{m+1}, S^n) = \varnothing$.

*Proof.* Any $F : S^{m+1} \to S^n$ would give $F \circ \iota_m : S^m \to S^n$, contradicting the hypothesis. $\qquad\blacksquare$

Together these two one-line principles convert a single non-existence fact into a whole cone: descending the codomain and ascending the domain. All that remains is to seed the cone with finite base cases.

## 7. The excess spectrum at the base

### 7.1 Finite Borsuk–Ulam base instances

The following three impossibilities are finite statements — each asserts the emptiness of a finite set of candidate vertex maps — and are verified by exhaustive search over the positive-vertex reformulation of Proposition 3.1.

**Lemma 7.1.** $\mathrm{Map}(S^1, S^0) = \varnothing$, $\mathrm{Map}(S^2, S^1) = \varnothing$, and $\mathrm{Map}(S^3, S^2) = \varnothing$.

*Proof sketch.* By Proposition 3.1 an antipodal map $S^{n+1} \to S^n$ would require an injection from $n+2$ domain axes into $n+1$ codomain axes, which is impossible; concretely, for each of $n = 0, 1, 2$ one enumerates all sign-and-axis assignments of the positive vertices and checks that every candidate produces an antipodal pair in the image of some facet. The search space is finite (of sizes governed by $(2(n+1))^{\,n+2}$), so the check terminates. $\qquad\blacksquare$

### 7.2 Non-existence to low spheres

Feeding Lemma 7.1 into domain ascent (Theorem 6.2) gives three infinite families.

**Theorem 7.2.** For every $m \ge 0$:
$$\mathrm{Map}(S^{m+1}, S^0) = \varnothing, \qquad \mathrm{Map}(S^{m+2}, S^1) = \varnothing, \qquad \mathrm{Map}(S^{m+3}, S^2) = \varnothing.$$

*Proof.* Induction on $m$ with base cases Lemma 7.1 and inductive step Theorem 6.2. $\qquad\blacksquare$

In words: no positive-dimensional sphere maps antipodally onto $S^0$; no sphere of dimension $\ge 2$ maps antipodally onto $S^1$; no sphere of dimension $\ge 3$ maps antipodally onto $S^2$.

### 7.3 The sharp diagonal

**Theorem 7.3 (sharp diagonal).** For $n \in \{0,1,2\}$ there is no antipodal map $S^{n+1} \to S^n$.

*Proof.* This is the diagonal instance of Lemma 7.1 for each of $n = 0, 1, 2$. $\qquad\blacksquare$

**Theorem 7.4 (excess spectrum at the base).** For $n \in \{0, 1, 2\}$,
$$\mathrm{Map}(S^n, S^n) \ne \varnothing \quad\text{and}\quad \mathrm{Map}(S^{n+1}, S^n) = \varnothing,$$
hence $\operatorname{coind}(S^n) = n$ exactly.

*Proof.* The self-map $\mathrm{id}_{S^n}$ gives the first clause and Theorem 7.3 the second. Together they bracket the coindex from below and above. $\qquad\blacksquare$

Interpreting Theorem 7.4 through the tower: climbing one rung of the suspension tower raises the coindex by **precisely one** at each of the bottom three levels. The constructive half (Section 5) guarantees the increment is at least one; the obstructive half (Sections 6–7) guarantees it is at most one; the two meet exactly.

## 8. Algorithms

The theory is constructive and its base cases are decidable. Three algorithms make this explicit.

**(A) Antipodal-map enumeration / decision.** Given $m, n$, enumerate candidate positive-vertex assignments $g : \{0,\dots,m\} \to V(S^n)$ and test the axis-injectivity criterion of Proposition 3.1 (equivalently, test simpliciality on all $2^{m+1}$ facets). Returns whether $\mathrm{Map}(S^m, S^n)$ is nonempty and, if so, a witness. This decides the finite Borsuk–Ulam base cases.

**(B) Suspension and tower construction.** Given a witness $F$, produce $\Sigma^k F$ by iterating the case-split of Definition 4.1. Used to realize the lifting theorem constructively and to exhibit explicit high-dimensional maps.

**(C) Coindex computation.** For fixed $n$, scan $d = 0, 1, 2, \dots$ using algorithm (A) to find the largest $d$ with $\mathrm{Map}(S^d, S^n) \ne \varnothing$, returning $\operatorname{coind}(S^n)$.

## 9. Applications

The coindex of a free $\mathbb{Z}_2$-complex is a workhorse lower-bound invariant in topological combinatorics. The finite, functorial machinery developed here models, in a fully verifiable way, the mechanisms that power:

- **Ham Sandwich–type partition theorems**, where non-existence of equivariant maps to low spheres obstructs simultaneous bisections;
- **Fair-division / necklace-splitting** results, whose combinatorial bounds descend from Borsuk–Ulam;
- **Kneser-type chromatic lower bounds**, where the coindex of an associated neighborhood/box complex bounds the chromatic number from below.

The distinctive feature is *modularity*: a small number of exhaustively checked base cases, amplified by descent and lifting, yields infinite families of obstructions with a functorial coherence guarantee.

## 10. Discussion and future work

We have shown that the excess spectrum — the per-rung coindex increment of the suspension tower — is exactly one at the bottom three levels, and that both the lower-bound and obstruction directions propagate through the tower by elementary composition principles. The obstruction direction currently relies on finite base cases at levels $0, 1, 2$; the constructive direction and the functorial framework are already dimension-uniform.

Natural next steps include:

- **Uniformizing the obstruction.** Proposition 3.1 already gives the full diagonal impossibility $\mathrm{Map}(S^{n+1}, S^n) = \varnothing$ for all $n$ by a pigeonhole argument on axes; formalizing this uniformly would extend Theorem 7.4 to every $n$, giving $\operatorname{coind}(S^n) = n$ across the whole tower without finite base cases.
- **Beyond spheres.** Extending the suspension tower and descent principles to general free $\mathbb{Z}_2$-complexes $K$, computing $\operatorname{coind}(\Sigma^k K)$ and comparing with the index.
- **Joins and products.** Studying the interaction of the tower with the antipodal join and with box/Hom-complex constructions relevant to Kneser bounds.
- **Quantitative descent.** Tracking explicit witnesses through the descent cone to extract effective combinatorial partition algorithms.

## 11. Conclusion

The suspension tower packages the Borsuk–Ulam phenomenon for cross-polytope spheres into a single functorial object with two propagation laws pulling in opposite directions. Their meeting point is sharp: the coindex of $S^n$ is exactly $n$ for the first three floors, and each rung of the tower adds precisely one unit of symmetric complexity. The framework is elementary, constructive, and modular — a compact machine for turning a handful of finite impossibilities into infinite families of them.
