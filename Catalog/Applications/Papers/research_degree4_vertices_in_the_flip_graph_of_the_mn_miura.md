# Mountain–Valley Configurations and the Hypercube Flip Graph of the Miura-ori

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (computational origami, rigid-folding combinatorics)

## Abstract

The Miura-ori is a rigid-origami tessellation whose crease pattern is a grid of degree-4 vertices. We give a fully formalized combinatorial treatment of two layers of its folding theory. At the *local* layer, we model a mountain/valley (MV) assignment at a degree-4 vertex as a Boolean function $a : \mathrm{Fin}\,4 \to \mathrm{Bool}$ and isolate the *generic flat-foldable* assignments through the combinatorial characterization $a(0) \neq a(1) \wedge a(2) = a(3)$, which encodes Hull's big-little-big lemma together with Maekawa's parity constraint. We prove (i) **Maekawa's theorem** in the form that every generic-valid assignment has exactly one or three mountains, and (ii) **Hull's count** that there are exactly four generic-valid assignments. At the *global* layer, we model the single-vertex MV flip graph in the independent-vertex regime as the Boolean hypercube $Q_d$ on configurations $\mathrm{Fin}\,d \to \mathrm{Bool}$, with adjacency defined by unit Hamming distance. We prove that $Q_d$ is **$d$-regular** (so $Q_4$ is exactly 4-regular), **connected**, has exactly $d\cdot 2^{d-1}$ edges and $2^d$ vertices, and is **bipartite** via a mountain-count parity invariant. All results are stated for general parameters and established by exact arguments. We discuss why the per-crease flip graph is edgeless (justifying the per-vertex abstraction), and outline the route to diameter, degree-census, and mixing-time results for the genuinely coupled Miura-ori.

---

## 1. Introduction

Origami has matured from an art into a rigorous engineering and mathematical discipline. Among flat-foldable crease patterns the **Miura-ori** — Koryo Miura's herringbone tessellation of congruent parallelograms — is paradigmatic: it deploys with a single degree of freedom, packs flat, and underlies space-grade deployable structures, metamaterials, and self-folding devices. Combinatorially, the interior of the Miura crease pattern is a grid of **degree-4 vertices**: points where four creases cross, dividing the local neighborhood into four angular sectors.

Two distinct but intertwined questions drive this paper.

1. **Local enumeration.** At a single generic degree-4 vertex, how many mountain/valley assignments fold flat? Classical results — Maekawa's theorem and Hull's big-little-big lemma — answer this, and we render the answer as exact combinatorial theorems.

2. **Global reconfiguration.** Given the space of valid configurations of many such vertices, what is the structure of the *flip graph* whose edges are elementary local moves? We show that the natural per-vertex flip move yields the Boolean hypercube $Q_d$, and we establish its core structural invariants.

A central methodological point emerges: the *per-crease* flip move (toggle one crease) destroys validity at a degree-4 vertex (turning a $3$–$1$ split into a $2$–$2$ split), making the per-crease flip graph on valid states **edgeless**. The productive abstraction is the *per-vertex* flip (toggle all creases at a vertex simultaneously), under which each independently flippable vertex contributes one binary degree of freedom and the configuration space becomes a hypercube.

### Notation

Throughout, $\mathrm{Bool} = \{\text{true}, \text{false}\}$ with `true` denoting *mountain* and `false` denoting *valley*. For a natural number $d$, $\mathrm{Fin}\,d = \{0, 1, \dots, d-1\}$. We write $\#S$ for the cardinality of a finite set $S$ and $\mathrm{univ}$ for the finite universe of a finite type. For a Boolean function $a$, $\neg a(i)$ (written `!a i`) denotes Boolean negation, and $a^{(i)}$ denotes the function agreeing with $a$ everywhere except that coordinate $i$ is negated, i.e. the pointwise update $\mathrm{update}(a, i, \neg a(i))$.

---

## 2. The local degree-4 vertex

### 2.1 Definitions

**Definition 2.1 (MV assignment).** A *mountain/valley assignment* at a degree-4 vertex is a function
$$a : \mathrm{Fin}\,4 \to \mathrm{Bool},$$
assigning to each of the four creases (indexed $0,1,2,3$ in cyclic order) the value `true` (mountain) or `false` (valley). There are $2^4 = 16$ such assignments.

**Definition 2.2 (Mountain count).** The number of mountain creases of $a$ is
$$\mathrm{mountains}(a) = \#\{\, i \in \mathrm{Fin}\,4 : a(i) = \text{true} \,\}.$$

**Definition 2.3 (Generic-valid assignment).** Suppose the four sector angles around the vertex have a unique strict minimum, located between creases $0$ and $1$. The assignment $a$ is *generic-valid* (a generic flat-foldable MV assignment) iff
$$\mathrm{GenericValid}(a) \iff \bigl(a(0) \neq a(1)\bigr) \wedge \bigl(a(2) = a(3)\bigr).$$

The two clauses encode, respectively, **Hull's big-little-big lemma** — the two creases bounding the strictly smallest sector must fold oppositely — and the residual constraint imposed by Maekawa's parity rule on the remaining pair. We take this combinatorial condition as the working definition, the geometric derivation of big-little-big lying outside our formal scope; we then *prove* that it entails Maekawa's parity and that it has exactly four solutions.

### 2.2 Maekawa's theorem

**Theorem 2.4 (Maekawa, combinatorial form — `mountains_of_genericValid`).** For every generic-valid assignment $a$,
$$\mathrm{mountains}(a) = 1 \quad \text{or} \quad \mathrm{mountains}(a) = 3.$$

*Proof sketch.* Write $a = (a(0), a(1), a(2), a(3))$. The hypothesis gives $a(0) \neq a(1)$, so exactly one of $\{a(0), a(1)\}$ is a mountain, contributing exactly $1$ to the count. It also gives $a(2) = a(3)$, so $\{a(2), a(3)\}$ contributes either $0$ (both valley) or $2$ (both mountain). Hence $\mathrm{mountains}(a) \in \{1, 3\}$. Formally this is a finite case analysis over the sixteen assignments, restricted by the two constraints, discharged exhaustively. $\qquad\blacksquare$

This is the flat-foldability signature of a degree-4 vertex: the mountains and valleys differ by exactly two, giving a $3$–$1$ or $1$–$3$ split, never $2$–$2$ or $4$–$0$.

### 2.3 Hull's count

**Theorem 2.5 (Hull's count — `card_genericValid`).** The number of generic-valid assignments is exactly four:
$$\#\{\, a : \mathrm{Fin}\,4 \to \mathrm{Bool} \mid \mathrm{GenericValid}(a) \,\} = 4.$$

*Proof sketch.* A generic-valid assignment is determined by independent choices: the disagreeing pair $(a(0), a(1))$ admits $2$ ordered options ($a(0)$ free, $a(1) = \neg a(0)$), and the agreeing pair $(a(2), a(3))$ admits $2$ options ($a(2)$ free, $a(3) = a(2)$). The total is $2 \times 2 = 4$. Formally, enumerate all sixteen assignments and count those satisfying the predicate. $\qquad\blacksquare$

Thus a generic flat-foldable degree-4 origami vertex has precisely four valid foldings — independent of the exact sector angles, provided the smallest sector is unique.

---

## 3. The flip graph as the Boolean hypercube

### 3.1 The configuration space and elementary move

We model a global configuration in the *independent-vertex regime* as an assignment of one bit to each of $d$ independently flippable degrees of freedom: $a : \mathrm{Fin}\,d \to \mathrm{Bool}$. The elementary reconfiguration move is a single flip — toggling one coordinate.

**Definition 3.1 (Flip graph $Q_d$).** The *flip graph* on $d$ binary degrees of freedom is the simple graph $\mathrm{flipGraph}(d)$ with vertex set $\mathrm{Fin}\,d \to \mathrm{Bool}$ and adjacency
$$a \sim b \iff \#\{\, i \in \mathrm{Fin}\,d : a(i) \neq b(i) \,\} = 1,$$
i.e. two configurations are adjacent iff their Hamming distance is exactly $1$. Symmetry follows from the symmetry of $\neq$; irreflexivity holds since the empty disagreement set has cardinality $0 \neq 1$. This is the Boolean hypercube $Q_d$.

**Lemma 3.2 (Single-flip characterization — `flipGraph_adj_iff`).** For all configurations $a, b$,
$$a \sim b \iff \exists\, i \in \mathrm{Fin}\,d,\; b = a^{(i)},$$
where $a^{(i)} = \mathrm{update}(a, i, \neg a(i))$ is $a$ with coordinate $i$ negated.

*Proof sketch.* ($\Rightarrow$) If the disagreement set has cardinality $1$, it equals $\{i\}$ for a unique $i$; then $b$ agrees with $a$ off $i$ and is its Boolean opposite at $i$, so $b = a^{(i)}$. ($\Leftarrow$) For $b = a^{(i)}$, the disagreement set is exactly $\{i\}$, which has cardinality $1$. $\qquad\blacksquare$

### 3.2 Regularity

**Theorem 3.3 ($d$-regularity — `flipGraph_degree`).** Every configuration $a$ in $Q_d$ has exactly $d$ neighbors:
$$\deg_{Q_d}(a) = d.$$

*Proof sketch.* By Lemma 3.2 the neighbor set of $a$ is $\{\, a^{(i)} : i \in \mathrm{Fin}\,d \,\}$, the image of $\mathrm{Fin}\,d$ under $i \mapsto a^{(i)}$. This map is injective: if $a^{(i)} = a^{(j)}$ with $i \neq j$, evaluating at $i$ gives $\neg a(i)$ on the left and $a(i)$ on the right (since the update at $j \neq i$ leaves coordinate $i$ untouched), a contradiction in $\mathrm{Bool}$. An injective image of a $d$-element set has $d$ elements, so the neighbor set — and hence the degree — is $d$. $\qquad\blacksquare$

**Corollary 3.4 (`flipGraph_degree_four`).** In $Q_4$, every vertex has degree exactly $4$:
$$\deg_{Q_4}(a) = 4 \quad \text{for all } a.$$

This is the unification of the two "fours": the four creases of a degree-4 origami vertex ($\mathrm{Fin}\,4$) and the four neighbors of a degree-4 flip-graph node coincide, both stemming from a four-element index set. $Q_4$ is the unique hypercube that is simultaneously $4$-regular.

### 3.3 Vertex and edge counts

**Theorem 3.5 (Vertex count — `flipGraph_card_verts`).**
$$\#\{\, a : \mathrm{Fin}\,d \to \mathrm{Bool} \,\} = 2^d.$$

*Proof sketch.* The number of functions from a $d$-element set into a $2$-element set is $2^d$. $\qquad\blacksquare$

**Theorem 3.6 (Edge count — `flipGraph_card_edges`).** The number of edges $E$ of $Q_d$ satisfies
$$2E = d \cdot 2^d, \qquad\text{equivalently}\qquad E = d \cdot 2^{d-1}.$$

*Proof sketch.* By the handshake lemma, $\sum_{a} \deg(a) = 2E$. By Theorem 3.3 every degree equals $d$, and by Theorem 3.5 there are $2^d$ vertices, so the left side is $d \cdot 2^d$. Rearranging gives the claim; the formal proof uses a short `calc` step because $d \cdot 2^d$ is a product of two non-constant factors. $\qquad\blacksquare$

For $Q_4$: $E = 4 \cdot 2^3 = 32$ edges on $16$ vertices.

### 3.4 Connectivity

**Theorem 3.7 (Connectivity — `flipGraph_connected`).** The flip graph $Q_d$ is connected.

*Proof sketch.* It suffices to show every configuration is reachable from the fixed all-mountain configuration $\mathbf{1}$ (the constant `true`). Proceed by induction on the number of `false` coordinates of $a$. If there are none, $a = \mathbf{1}$ and reachability is reflexive. Otherwise pick a coordinate $i$ with $a(i) = \text{false}$; the configuration $a' = \mathrm{update}(a, i, \text{true})$ has one fewer `false` coordinate, hence is reachable from $\mathbf{1}$ by the inductive hypothesis, and $a' \sim a$ by Lemma 3.2 (they differ exactly at $i$). Concatenating gives a walk from $\mathbf{1}$ to $a$. By transitivity any two configurations are connected. $\qquad\blacksquare$

This is the rigorous mixing statement: under single-vertex flips the configuration space is fully reachable — in sharp contrast to the per-crease move discussed in §4.

### 3.5 Bipartiteness

**Definition 3.8 (True-count).** $\mathrm{trueCount}(d, a) = \#\{\, i \in \mathrm{Fin}\,d : a(i) = \text{true} \,\}$, the number of mountain coordinates of $a$.

**Theorem 3.9 (Parity invariant / bipartiteness — `flipGraph_adj_parity`).** If $a \sim b$ in $Q_d$, then
$$\mathrm{trueCount}(d, a) \bmod 2 \neq \mathrm{trueCount}(d, b) \bmod 2.$$

*Proof sketch.* By Lemma 3.2, $b = a^{(i)}$ for some $i$. If $a(i) = \text{true}$, then negating coordinate $i$ removes one mountain: the mountain set of $b$ is the mountain set of $a$ with $i$ deleted, so $\mathrm{trueCount}(d,b) = \mathrm{trueCount}(d,a) - 1$. If $a(i) = \text{false}$, negating adds one mountain: $\mathrm{trueCount}(d,b) = \mathrm{trueCount}(d,a) + 1$. In either case the count changes by one, flipping its parity. $\qquad\blacksquare$

**Corollary 3.10.** Coloring each configuration by the parity of its mountain count is a proper $2$-coloring, so $Q_d$ is bipartite. Consequently any walk between two fixed configurations has length of fixed parity, equal to the parity of the difference of their mountain counts.

---

## 4. Why per-crease flips fail, and the per-vertex abstraction

A natural alternative elementary move is to toggle a *single crease* at a degree-4 vertex. By Maekawa's theorem (Theorem 2.4) every valid vertex has a $3$–$1$ mountain/valley split. Toggling one crease changes the count by exactly one, producing a $2$–$2$ split, which violates Maekawa and is therefore not flat-foldable. Hence **no** single-crease move connects two valid states: the per-crease flip graph restricted to valid origami configurations is *edgeless*; every valid state is isolated.

This failure is the precise motivation for the per-vertex abstraction. A *vertex flip* negates all four creases at a vertex simultaneously, sending a $3$–$1$ split to a $1$–$3$ split — still Maekawa-valid. Modeling each independently flippable vertex as one binary degree of freedom (its global mountain/valley polarity), the reconfiguration graph on $d$ such vertices is exactly $Q_d$, and §3 applies in full.

---

## 5. Algorithms

We summarize the constructive content as algorithms; full type-hinted implementations accompany this work.

**Algorithm A — Generic-valid enumeration.** Enumerate all $2^4$ assignments $a : \mathrm{Fin}\,4 \to \mathrm{Bool}$, retain those with $a(0) \neq a(1)$ and $a(2) = a(3)$, and (optionally) verify each retained assignment has mountain count in $\{1,3\}$. Returns the four valid assignments. Complexity $O(2^4)$, constant.

**Algorithm B — Hypercube neighbor generation.** Given $a : \mathrm{Fin}\,d \to \mathrm{Bool}$, output the $d$ configurations $a^{(i)}$ for $i = 0, \dots, d-1$. This realizes the bijection underlying Theorem 3.3. Complexity $O(d^2)$ to materialize all neighbors as explicit vectors (or $O(d)$ flips).

**Algorithm C — Shortest reconfiguration path.** Given configurations $a, b$, compute the disagreement set $D = \{ i : a(i) \neq b(i) \}$ and flip its coordinates in any order; this is a geodesic of length $|D|$ (the Hamming distance), realizing the constructive content of Theorem 3.7. Complexity $O(d)$.

---

## 6. Applications

- **Deployable structures and metamaterials.** Reconfiguration graphs model the admissible transitions of foldable space structures, origami metamaterials, and programmable matter. Connectivity (Theorem 3.7) guarantees reachability of target states; regularity (Theorem 3.3) bounds the local branching of reconfiguration; the edge count (Theorem 3.6) measures total transition capacity.
- **Worst-case planning.** The geodesic construction (Algorithm C) yields optimal single-flip reconfiguration plans of length equal to the Hamming distance, with maximum $d$.
- **Sampling and statistical physics.** Identifying the configuration space with $Q_d$ makes single-flip Glauber dynamics on Miura MV assignments an instance of lazy random walk on the hypercube, an exactly analyzable Markov chain, and the parity invariant (Theorem 3.9) exposes its bipartite (period-2) structure relevant to mixing.

---

## 7. Discussion and honest scope

The hypercube $Q_d$ faithfully models the *generic, independent-vertex* regime, in which each flippable Miura vertex contributes one binary degree of freedom. The actual $m \times n$ Miura-ori shares creases between neighboring vertices, coupling their MV states; its global flip graph is therefore a subgraph or quotient of a hypercube and need not be regular. The results here delimit the clean combinatorial core; the coupled theory is the natural next target.

We emphasize what is and is not claimed. Theorems 2.4–2.5 are exact statements about the sixteen degree-4 assignments under the stated genericity (unique smallest sector between creases $0$ and $1$). Theorems 3.3–3.10 are exact statements about $Q_d$ for arbitrary $d$. The geometric derivation of the big-little-big lemma is taken as input via Definition 2.3.

---

## 8. Future directions

Building on (a) the local count of four valid degree-4 vertex assignments and (b) the identification of the single-vertex flip graph with the regular, connected hypercube $Q_d$:

1. **Diameter of the MV flip graph.** Conjecture: the single-site flip graph of MV assignments of the $m \times n$ Miura-ori has diameter exactly $(m+1)(n+1)$. The hypercube $Q_N$ with $N = (m+1)(n+1)$ has diameter $N$, realized by a configuration and its global complement; the established regularity and connectivity isolate the graph as a hypercube, making the diameter the immediate next invariant and unlocking worst-case single-site reconfiguration bounds.

2. **Degree census as a fingerprint.** Conjecture: among finite planar grid graphs, the triple $(\#\deg\text{-}2, \#\deg\text{-}3, \#\deg\text{-}4) = (4,\, 2(m-1)+2(n-1),\, (m-1)(n-1))$ characterizes the $m \times n$ crease graph up to isomorphism. The corner/edge/interior split is rigid: degree-2 vertices must be the four corners and degree-3 the boundary chains, forcing the rectangular shape, so the degree census is a complete combinatorial fingerprint.

3. **Mixing time of Glauber dynamics.** Conjecture: single-site Glauber dynamics on the unconstrained MV assignments mixes in $\Theta(N\log N)$ steps with $N = (m+1)(n+1)$. Once the state graph is the hypercube $Q_N$, Glauber dynamics is the classical lazy random walk on the cube, whose mixing time is $\tfrac12 N\log N\,(1+o(1))$ via a coupon-collector coupling.

4. **Flat-foldable subgraph.** Conjecture: restricting to flat-foldable MV assignments (Maekawa/Kawasaki at each interior degree-4 vertex) yields an induced flip subgraph in which every vertex has degree $(m+1)(n+1) - c(p)$, where the defect $c(p)$ counts sites whose flip would violate a local Maekawa constraint, with $\sum_p c(p)$ governed by the $(m-1)(n-1)$ interior vertices — each interior degree-4 vertex imposing one Maekawa parity constraint.

---

## 9. Conclusion

We have established a tight, exact account of two layers of Miura-ori folding combinatorics: the local degree-4 vertex has exactly four generic flat-foldable MV assignments, each obeying Maekawa's $3$–$1$ rule; and the natural per-vertex reconfiguration graph is the Boolean hypercube $Q_d$, which is $d$-regular, connected, bipartite, with $2^d$ vertices and $d\cdot 2^{d-1}$ edges. The per-crease move is shown to be a dead end, justifying the per-vertex abstraction. These results form a rigid foundation for the coupled-vertex theory of the full $m\times n$ Miura-ori.
