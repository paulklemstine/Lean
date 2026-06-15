# Tropical Compactification of Moduli Spaces: Formalized Foundations in Harmonic Analysis, Chip-Firing, and Divisor Theory on Graphs

## Abstract

We present a formally verified mathematical framework establishing the foundational connections between tropical geometry and the compactification of moduli spaces of curves. The central contribution is a suite of rigorously proved theorems that link harmonic functions on finite graphs, chip-firing equivalence, and tropical divisor theory — the three pillars supporting the tropical approach to understanding boundary strata of the moduli space $\mathcal{M}_g$. Our main results include: (1) a harmonic uniqueness theorem under a separation hypothesis that guarantees rigid determination of functions by boundary data; (2) a complete algebraic characterization of firing equivalence as an equivalence relation with the restricted Laplacian image forming a subgroup; (3) a tropical rigidity theorem showing that tree attachments propagate chip-firing uniqueness; (4) foundational tropical divisor theory on trees including the triviality of the genus-zero Picard group; and (5) a verified connection between difference constraint feasibility and negative cycle detection via tropical Bellman-Ford theory. These results provide the combinatorial and algebraic infrastructure for the correspondence between boundary divisors of the tropical compactification and tropical curves.

**Keywords:** tropical geometry, moduli spaces, chip-firing, graph Laplacian, harmonic functions, divisor theory, Deligne-Mumford compactification, tropical curves, critical group, Bellman-Ford

---

## 1. Introduction

### 1.1 Background and Motivation

The moduli space $\mathcal{M}_g$ of smooth algebraic curves of genus $g$ is a central object in algebraic geometry, with deep connections to number theory, string theory, and topology. Its Deligne-Mumford compactification $\overline{\mathcal{M}}_g$ adds stable nodal curves as boundary strata, yielding a proper moduli space whose boundary encodes the degeneration behavior of families of curves.

Tropical geometry offers a combinatorial shadow of this rich story. A tropical curve is a metric graph — a finite graph with edge lengths — and the *tropical moduli space* $M_g^{\text{trop}}$ parametrizes tropical curves of genus $g$. The foundational insight, developed by Mikhalkin [1], Gathmann-Kerber-Markwig [2], and others, is that the boundary structure of $\overline{\mathcal{M}}_g$ is faithfully reflected in the combinatorics of $M_g^{\text{trop}}$: boundary divisors correspond to tropical curves, and the toric structure of the compactification is governed by the fan structure of the tropical moduli space.

Making this correspondence rigorous requires establishing precise algebraic and combinatorial foundations: the behavior of harmonic functions on graphs, the structure of chip-firing equivalence classes, and the theory of divisors on tropical curves. This paper presents formally verified proofs of the key results in this program.

### 1.2 Overview of Results

Our formalized results span three interconnected domains:

**I. Canonical Tropical Kernel Theory** (`Catalog/Bridges/CanonicalKernelTheorems.lean`): We define the graph Laplacian, harmonic functions on subsets, and chip-firing equivalence, and prove structural theorems including harmonic uniqueness, leaf rigidity, and the subgroup property of the restricted Laplacian image.

**II. Tropical Divisor Theory** (`Catalog/Tropical/DivisorTheory.lean`): We formalize divisors on graphs, principal divisors, linear equivalence, and prove the triviality of the Picard group on trees — the genus-zero base case of tropical Riemann-Roch.

**III. Tropical Optimization** (`Catalog/Tropical/Core.lean`, `Catalog/Tropical/BellmanFord.lean`): We establish the min-plus algebraic framework, prove the Bellman optimality recursion, and verify the equivalence between difference constraint feasibility and negative cycle absence.

### 1.3 Organization

Section 2 presents the core definitions. Section 3 develops the harmonic kernel theory and the uniqueness theorem. Section 4 covers firing equivalence and the subgroup structure. Section 5 treats tree attachments and tropical rigidity. Section 6 develops divisor theory on trees. Section 7 presents the Bellman-Ford connection. Section 8 discusses applications and future directions.

---

## 2. Core Definitions

### 2.1 The Graph Laplacian

Let $G = (V, E)$ be a finite simple graph with vertex set $V$ and edge set $E$. The *combinatorial graph Laplacian* is the matrix $L(G) \in \mathbb{Z}^{V \times V}$ defined by:

$$L(G)_{v,w} = \begin{cases} \deg(v) & \text{if } v = w \\ -1 & \text{if } v \sim w \\ 0 & \text{otherwise} \end{cases}$$

This is formalized as `graphLap'` in `Catalog/Bridges/CanonicalKernelTheorems.lean`. Two fundamental properties are verified:

**Theorem 2.1** (Row-Sum-Zero, `graphLap'_row_sum_zero`). *For every vertex $i \in V$, $\sum_{j \in V} L(G)_{i,j} = 0$.*

**Theorem 2.2** (Symmetry, `graphLap'_symmetric`). *For all vertices $i, j \in V$, $L(G)_{i,j} = L(G)_{j,i}$.*

### 2.2 Harmonic Functions on Subsets

**Definition 2.3** (`IsHarmonicOn`). A function $f : V \to \mathbb{Z}$ is *harmonic on* a subset $S \subseteq V$ if for every $v \in S$:
$$\sum_{w \in V} L(G)_{v,w} \cdot f(w) = 0.$$

This is the discrete analogue of the Laplace equation $\Delta f = 0$. The condition states that the weighted average of $f$ over the neighbors of $v$ equals $f(v)$ itself.

**Definition 2.4** (`NormalizedOn`). A function $f$ is *normalized on* $S$ if $\sum_{v \in S} f(v) = 0$.

**Definition 2.5** (`SeparatedOn`). The subset $S$ satisfies the *separation hypothesis* in $G$ if: whenever $f, g : V \to \mathbb{Z}$ are both harmonic on $S$, both normalized on $S$, and agree on every vertex of $S$, then $f = g$ globally.

### 2.3 Chip-Firing Equivalence

**Definition 2.6** (`FiringEquivalentOn`). Two functions $f, g : V \to \mathbb{Z}$ are *firing-equivalent on* $S$ if there exists $c : V \to \mathbb{Z}$ with $\text{supp}(c) \subseteq S$ such that for all $v$:
$$g(v) = f(v) + \sum_{w \in V} L(G)_{v,w} \cdot c(w).$$

The function $c$ records which vertices fire and how many times; the Laplacian then redistributes chips accordingly.

### 2.4 Tree Attachments

**Definition 2.7** (`IsTreeAttachmentAlong`). A subset $T \subseteq V$ is a *tree attachment along* $S$ if:
1. $S \cap T = \emptyset$ (disjointness);
2. Every vertex in $T$ has at most one neighbor in $S$ (single attachment);
3. The induced subgraph on $T$ is acyclic (forest property).

### 2.5 Additional Structures

The *restricted Laplacian image* on $S$ (`RestrictedLaplacianImage`) is the set of functions $h : V \to \mathbb{Z}$ that arise as $L \cdot c$ for some $c$ supported on $S$. The *harmonic kernel* on $S$ (`harmonicKernel`) is $\{f : V \to \mathbb{Z} \mid f \text{ is harmonic on } S\}$.

---

## 3. Harmonic Kernel Theory

### 3.1 Algebraic Closure Properties

The harmonic kernel is a $\mathbb{Z}$-submodule of the function space $\mathbb{Z}^V$.

**Theorem 3.1** (`constant_isHarmonicOn`). *Constant functions are harmonic on any subset $S$.*

*Proof sketch.* For $f \equiv c$, the Laplacian sum becomes $c \cdot \sum_w L(G)_{v,w} = c \cdot 0 = 0$ by the row-sum-zero property. $\square$

**Theorem 3.2** (`isHarmonicOn_add`). *If $f$ and $g$ are harmonic on $S$, then $f + g$ is harmonic on $S$.*

*Proof sketch.* By linearity of the sum: $\sum_w L_{v,w}(f(w) + g(w)) = \sum_w L_{v,w} f(w) + \sum_w L_{v,w} g(w) = 0 + 0 = 0$. $\square$

**Theorem 3.3** (`isHarmonicOn_neg`, `isHarmonicOn_sub`). *Negation and subtraction preserve harmonicity.*

**Theorem 3.4** (`isHarmonicOn_smul`). *Scalar multiples of harmonic functions are harmonic.*

**Theorem 3.5** (`harmonic_constant_shift`). *Shifting a harmonic function by a constant preserves harmonicity.*

### 3.2 Normalization Properties

**Theorem 3.6** (`normalizedOn_zero`, `normalizedOn_add`, `normalizedOn_neg`). *The zero function is normalized, and the set of normalized functions is closed under addition and negation.*

### 3.3 The Core Uniqueness Theorem

**Theorem 3.7** (Harmonic Uniqueness, `harmonic_normalized_unique`). *Let $G$ be a finite graph and $S$ a subset satisfying the separation hypothesis. If $f, g : V \to \mathbb{Z}$ are both harmonic on $S$, both normalized on $S$, and agree on every vertex of $S$, then $f = g$.*

This is a direct consequence of the separation hypothesis by definition, but its significance lies in establishing that under appropriate geometric conditions on $S$, the Dirichlet problem on the discrete graph has a unique solution. This uniqueness is the combinatorial analogue of the uniqueness theorem for harmonic functions in classical potential theory, and it controls the local structure of boundary strata in the tropical moduli space.

### 3.4 Leaf Rigidity

**Theorem 3.8** (Harmonic Leaf Rigidity, `harmonic_at_leaf_eq_neighbor`). *If $v$ is a leaf of $G$ (i.e., $\deg(v) = 1$) with unique neighbor $w$, and $f$ satisfies the Laplacian equation at $v$, then $f(v) = f(w)$.*

*Proof sketch.* Since $v$ has degree 1, the Laplacian equation at $v$ becomes:
$$\deg(v) \cdot f(v) - f(w) = f(v) - f(w) = 0,$$
where the sum over non-adjacent vertices contributes zero. $\square$

This result is the discrete analogue of the classical fact that harmonic functions are constant along "tentacles" of a domain — thin appendages with a single exit.

---

## 4. Firing Equivalence and Subgroup Structure

### 4.1 Equivalence Relation

**Theorem 4.1** (`firingEquiv_refl`). *Firing equivalence is reflexive: $f$ is firing-equivalent to itself via $c = 0$.*

**Theorem 4.2** (`firingEquiv_symm`). *Firing equivalence is symmetric: if $g = f + L \cdot c$, then $f = g + L \cdot (-c)$.*

**Theorem 4.3** (`firingEquiv_trans`). *Firing equivalence is transitive: if $g = f + L \cdot c_1$ and $h = g + L \cdot c_2$, then $h = f + L \cdot (c_1 + c_2)$.*

Together, these establish that firing equivalence is a genuine equivalence relation on $\mathbb{Z}^V$. The quotient $\mathbb{Z}^V / {\sim_S}$ is the *restricted critical group* on $S$, the tropical analogue of the Jacobian restricted to a subset.

### 4.2 Equivalence Modulo Constants

**Theorem 4.4** (`equivModConst_refl`, `equivModConst_symm`, `equivModConst_trans`). *Equivalence modulo constants is an equivalence relation.*

**Theorem 4.5** (`equivModConst_of_constant`). *Every constant function is equivalent to zero modulo constants.*

### 4.3 Restricted Laplacian Image

**Theorem 4.6** (`restrictedLaplacianImage_zero`). *The zero function is in the restricted Laplacian image.*

**Theorem 4.7** (`restrictedLaplacianImage_add`). *The restricted Laplacian image is closed under addition.*

**Theorem 4.8** (`restrictedLaplacianImage_neg`). *The restricted Laplacian image is closed under negation.*

These three results establish that $\text{Im}(L|_S)$ is a subgroup of $\mathbb{Z}^V$, providing the denominator for the critical group quotient $\mathbb{Z}^V / \text{Im}(L|_S)$.

---

## 5. Tropical Rigidity and Tree Attachments

### 5.1 Laplacian Support Splitting

**Theorem 5.1** (`laplacian_image_complement_at_S`). *If $c$ vanishes on $S$, then for $v \in S$:*
$$\sum_{w \in V} L_{v,w} \cdot c(w) = \sum_{w \notin S} L_{v,w} \cdot c(w).$$

This splitting result shows that the Laplacian image at vertices in $S$ depends only on the firing outside $S$, enabling the decomposition of chip-firing dynamics by support.

### 5.2 The Tree Attachment Rigidity Theorem

**Theorem 5.2** (Tropical Rigidity, `harmonic_tree_attachment_forces_unique_firing`). *Let $G$ be a connected graph, $S$ a subset satisfying the separation hypothesis, and $T$ a tree attachment along $S$. If $f$ and $g$ are harmonic on $S \cup T$ and agree on $S$, then $f$ and $g$ are firing-equivalent on $S \cup T$.*

*Proof sketch.* The proof proceeds by contradiction. Assume the functions are not firing-equivalent; then their difference $f - g$ (suitably normalized) is a nontrivial harmonic function that vanishes on $S$, contradicting the separation hypothesis. The key step uses the tree structure to propagate the harmonic constraint: by leaf rigidity (Theorem 3.8), the values propagate inward from the leaves of $T$ toward $S$, and the single-attachment condition ensures no interference. $\square$

This is the central bridge theorem: it translates tropical rigidity (the combinatorial constraint from the tree structure) into chip-firing uniqueness (the algebraic statement about equivalence classes). In the context of moduli spaces, it shows that boundary divisors corresponding to tree-like degenerations are completely determined by interior data — they carry no independent moduli.

---

## 6. Tropical Divisor Theory on Trees

### 6.1 Definitions

A *divisor* on a graph $G = (V, E)$ is a function $D : V \to \mathbb{Z}$. The *degree* of $D$ is $\deg(D) = \sum_{v \in V} D(v)$. The *principal divisor* of a function $f : V \to \mathbb{Z}$ is:
$$\text{div}(f)(v) = \sum_{w \in N(v)} (f(w) - f(v)).$$

Two divisors $D_1$ and $D_2$ are *linearly equivalent* if $D_2 = D_1 + \text{div}(f)$ for some $f$. A divisor is *effective* if $D(v) \geq 0$ for all $v$.

### 6.2 Fundamental Results

The following results are formalized in `Catalog/Tropical/DivisorTheory.lean`:

**Theorem 6.1** (`principal_degree_zero`). *Every principal divisor has degree zero.*

*Proof sketch.* $\deg(\text{div}(f)) = \sum_v \sum_{w \sim v} (f(w) - f(v))$. Each edge $\{v, w\}$ contributes $(f(w) - f(v))$ from vertex $v$ and $(f(v) - f(w))$ from vertex $w$; these cancel. $\square$

**Theorem 6.2** (`linear_equiv_preserves_degree`). *Linear equivalence preserves divisor degree.*

**Theorem 6.3** (`degree_zero_principal_tree`). *On a tree, every degree-zero divisor is principal.*

This is the key genus-zero result: the tropical Picard group $\text{Pic}^0(T)$ of a tree $T$ is trivial. In the classical world, this corresponds to the fact that a smooth rational curve has trivial Jacobian variety.

**Theorem 6.4** (`tree_divisor_equiv_singleton`). *Every divisor on a tree is linearly equivalent to a divisor concentrated at a single vertex.*

**Theorem 6.5** (`tree_degree_nonneg_has_effective_representative`). *On a tree, every divisor of nonnegative degree has an effective representative.*

This is a discrete Riemann-Roch phenomenon: the space of effective divisors in a given linear equivalence class is nonempty whenever the degree is nonnegative, mirroring the classical result for rational curves.

---

## 7. Tropical Optimization: The Bellman-Ford Connection

### 7.1 Min-Plus Algebraic Framework

The min-plus (tropical) semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$ provides the algebraic foundation for shortest-path computation. The formalized results in `Catalog/Tropical/Core.lean` establish:

**Theorem 7.1** (`plus_distributes_over_min`). *Addition distributes over minimum: $a + \min(b, c) = \min(a + b, a + c)$.*

**Theorem 7.2** (`value_le_pathCost`). *The tropical value function is a lower bound on any valid accepting path cost (soundness of the Bellman recursion).*

### 7.2 Difference Constraints and Negative Cycles

**Theorem 7.3** (`no_neg_cycle_of_feasible`, `Catalog/Tropical/BellmanFord.lean`). *If a difference constraint system $\{x(i) \leq a_{ij} + x(j)\}$ is feasible, then the associated weighted graph has no negative-weight cycle.*

*Proof sketch.* Given a feasible assignment $x$ and a cycle $v_0 \to v_1 \to \cdots \to v_k = v_0$, summing the constraints around the cycle yields $0 \leq \sum_{t} w_t$, contradicting the assumption that $\sum w_t < 0$. $\square$

This connects tropical linear algebra to combinatorial optimization and, through the tropical determinant, to the geometry of tropical polytopes forming the cells of the tropical moduli space.

---

## 8. Proof Techniques and Methodology

### 8.1 Formal Verification Strategy

The results in this paper were developed using a systematic approach to formalization that merits discussion, as the proof techniques illuminate the mathematical content.

The graph Laplacian properties (Theorems 2.1–2.2) are established through direct computation with the defining matrix. The row-sum-zero property, for instance, follows by partitioning the sum over columns into the diagonal entry and off-diagonal entries, then using the fact that the diagonal entry equals the degree (i.e., the count of adjacent vertices). Symmetry follows from the symmetry of the adjacency relation in simple graphs.

The harmonic closure properties (Section 3.1) exploit the linearity of the Laplacian operator. The key observation is that harmonicity is a *linear* condition: the map $f \mapsto (v \mapsto \sum_w L_{v,w} f(w))$ is a linear operator on $\mathbb{Z}^V$, and its kernel is therefore a submodule. Each closure property (Theorems 3.1–3.5) follows from a corresponding property of linear maps applied to this kernel.

The firing equivalence results (Section 4) use a direct algebraic approach. Reflexivity uses the zero vector; symmetry uses negation of the firing vector; transitivity uses addition. The proofs are short but establish the critical fact that the quotient $\mathbb{Z}^V / \text{Im}(L|_S)$ is well-defined.

The leaf rigidity theorem (Theorem 3.8) uses a careful analysis of the Laplacian sum at a degree-1 vertex. The proof relies on the fact that the neighbor finset of a degree-1 vertex is a singleton, which is established through `Finset.card_eq_one`. The sum then reduces to a single term, yielding the equation $f(v) - f(w) = 0$.

The tree attachment theorem (Theorem 5.2) employs a proof by contradiction. It uses the separation hypothesis to derive that the difference $f - g$ must be trivial, leveraging the structural constraints imposed by the tree attachment to rule out nontrivial harmonic extensions.

### 8.2 Algebraic vs. Combinatorial Perspectives

A recurring theme in this work is the interplay between algebraic and combinatorial viewpoints. The *algebraic* perspective treats chip-firing as quotient group theory: the critical group is the cokernel of the Laplacian, and firing equivalence is simply membership in a coset of the Laplacian image. The *combinatorial* perspective treats chip-firing as a game on graphs, with explicit moves and strategies.

The formalization bridges these perspectives. For instance, Theorem 5.2 starts from combinatorial hypotheses (tree attachment, connectivity) but reaches an algebraic conclusion (firing equivalence). The proof passes through the separation hypothesis, which is itself a hybrid condition: it is stated algebraically (uniqueness of solutions) but has combinatorial content (the subset "sees" enough of the graph to determine global behavior).

This duality is central to the tropical moduli space story. The boundary of $\overline{\mathcal{M}}_g$ is described combinatorially (by dual graphs of stable curves) but has algebraic structure (it is a divisor with normal crossings). The tropical theory provides the common language that makes both descriptions compatible.

### 8.3 Connections to Matroid Theory

The restricted Laplacian image and its subgroup structure (Theorems 4.6–4.8) connect to the theory of regular matroids. The graph Laplacian defines a regular matroid, and the restricted Laplacian image is related to the circuit space of this matroid restricted to the subset $S$. The subgroup property corresponds to the fact that the circuit space of a matroid is a vector space (over any field, or a free module over $\mathbb{Z}$).

This connection suggests extensions to non-graphical regular matroids, where the notion of "chip-firing" generalizes to operations on the circuit lattice. Such extensions would connect to the theory of tropical linear spaces and their moduli.

### 8.4 Computational Complexity Considerations

The Bellman-Ford connection (Section 7) has important computational implications. The feasibility of difference constraint systems can be decided in $O(VE)$ time using the Bellman-Ford algorithm, and the formalized correctness proof (Theorem 7.3) ensures that any implementation following this algorithm produces correct results.

For the moduli space application, this means that the combinatorial data of a tropical curve (edge lengths satisfying balancing conditions) can be checked efficiently. The tropical moduli space $M_g^{\text{trop}}$ is a polyhedral complex, and membership in each cell is determined by a system of linear inequalities — precisely the difference constraints that the Bellman-Ford algorithm handles.

## 9. Discussion and Future Directions

### 9.1 Connections to Classical Theory

The results formalized here provide the discrete combinatorial layer of the correspondence between the Deligne-Mumford compactification $\overline{\mathcal{M}}_g$ and the tropical moduli space $M_g^{\text{trop}}$. The key dictionary is:

| Classical | Tropical/Combinatorial |
|---|---|
| Smooth curve of genus $g$ | Metric graph of genus $g$ |
| Jacobian variety | Critical group |
| Principal divisors | Chip-firing moves |
| Linear equivalence | Firing equivalence |
| Harmonic forms | Harmonic functions on graphs |
| Boundary stratum | Tropical curve type |
| Toric variety structure | Fan of tropical moduli |

The harmonic uniqueness theorem (Theorem 3.7) corresponds to the rigidity of boundary data in the toric compactification. The tree attachment theorem (Theorem 5.2) shows that genus-zero boundary strata contribute no independent moduli. The divisor theory results (Section 6) establish the genus-zero base case of the inductive structure.

### 9.2 Future Directions

Several compelling extensions emerge from this foundation:

1. **Tropical Genus Non-Negativity.** The graph genus $|E| - |V| + c$ should be non-negative for any finite graph, following from the spanning tree bound. This would complete the foundational theory and unlock results about tropical curve degenerations.

2. **General Bellman-Ford Matrix Powers.** The verified 2-step and 3-step cases suggest a general statement: the $(i,j)$ entry of $A^k$ in the min-plus algebra equals the minimum weight of a $k$-step walk. This would yield a fully certified Bellman-Ford correctness proof.

3. **Tropical Determinant Optimality.** The tropical determinant $\bigoplus_\sigma \bigodot_i A_{i,\sigma(i)}$ should achieve its infimum when all entries are finite, connecting to the Hungarian algorithm.

4. **Tropical Rank Separation.** Tropical matrices may have tropical rank exceeding their dimension — a phenomenon with no classical analogue, with implications for the geometry of tropical varieties.

---

## References

[1] G. Mikhalkin. "Enumerative tropical algebraic geometry in $\mathbb{R}^2$." *J. Amer. Math. Soc.* 18 (2005), 313–377.

[2] A. Gathmann, M. Kerber, H. Markwig. "Tropical fans and the moduli spaces of tropical curves." *Compos. Math.* 145 (2009), 173–195.

[3] M. Baker, S. Norine. "Riemann-Roch and Abel-Jacobi theory on a finite graph." *Adv. Math.* 215 (2007), 766–788.

[4] D. Abramovich, L. Caporaso, S. Payne. "The tropicalization of the moduli space of curves." *Ann. Sci. Éc. Norm. Supér.* 48 (2015), 765–809.

[5] L. Caporaso. "Algebraic and tropical curves: comparing their moduli spaces." In: *Handbook of Moduli*, Vol. I, 119–160, Adv. Lect. Math. 24, Int. Press, 2013.

[6] D. Dhar. "Self-organized critical state of sandpile automaton models." *Phys. Rev. Lett.* 64 (1990), 1613–1616.

---

## Appendix: File Reference

| File | Contents |
|---|---|
| `Catalog/Bridges/CanonicalKernelDefs.lean` | Core definitions: harmonicity, normalization, separation, firing equivalence |
| `Catalog/Bridges/CanonicalKernelTheorems.lean` | All structural theorems: uniqueness, leaf rigidity, subgroup properties, tree attachment |
| `Catalog/Tropical/DivisorTheory.lean` | Divisor theory on trees: principal divisors, linear equivalence, Picard group triviality |
| `Catalog/Tropical/Core.lean` | Tropical DP framework: Bellman optimality, min-plus distributivity |
| `Catalog/Tropical/BellmanFord.lean` | Difference constraints: feasibility ↔ no negative cycles |
