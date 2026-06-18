# Future Directions: Tropical Rank / Laplacian Minor Bridge

## Synthesis

The computational exploration reveals that the naive conjecture $r(D_S) \geq \mathrm{tropRank}(L_S) - 1$ fails even on trees, but the corrected upper bound $r(D_S) \leq \mathrm{tropRank}(L_S) - 1$ holds universally in all tested cases. This reversal fundamentally reframes the bridge: tropical rank provides an *upper bound* on chip-firing rank, measuring the maximum capacity for redistribution rather than a minimum guarantee. The formally verified structural theorems — degree-zero certification, support localization, subset decomposition, and principal minor row-sum characterization — provide the mathematical infrastructure for all five future directions below. Together, these directions form a research program aimed at establishing **tropical spectral Brill–Noether theory**: a unified framework connecting chip-firing rank, tropical linear algebra, and discrete potential theory on graphs.

---

## Direction 1: Upper Bound Proof for Trees

**Conjecture:** For every finite tree $G$, root $q$, and subset $S \subseteq V \setminus \{q\}$:
$$r(D_S) \leq \mathrm{tropRank}(L_S) - 1.$$

**Test:** Exhaustive computation on all labeled trees up to 12 vertices, all roots, all subsets. Current verification covers $n \leq 3$. Extend to $n = 8$ using optimized Dhar's burning algorithm for divisor rank (avoid BFS).

**Impact:** Trees are the simplest nontrivial class where both invariants are well-controlled. A proof here would establish the first fully verified instance of the tropical-chip-firing bridge and validate the proof architecture (Strategy A: reduced divisors + minor combinatorics) for extension to broader graph classes.

**Catalog References:**
- `Pythagorean/TropicalBridge/Defs.lean` — `rootedSubsetDivisor`, `graphLaplacian`, `laplacianPrincipalMinor`, `IsTree`
- `Pythagorean/TropicalBridge/Theorems.lean` — `rootedSubsetDivisor_total`, `principalMinor_row_sum`
- `Catalog/Tropical/ChipFiring/Theorems.lean` — `divisorDegree_laplacian_zero`, `linearEquivalent_degree_eq`

**Proof Strategy:** For trees, every degree-zero divisor has a unique $q$-reduced representative. Show that if the $q$-reduced form of $D_S$ has rank $r$, then $L_S$ contains a tropically nonsingular $(r+1) \times (r+1)$ submatrix. The key step is to translate chip-firing moves on the tree into tropical linear combinations of Laplacian rows, using the tree's path structure to control cancellations.

**Domain Bridges:** Tropical geometry ↔ graph Brill–Noether theory; spectral graph theory (tree eigenvalues are well-understood) ↔ tropical rank.

**Lineage:** Extends Baker–Norine [2007] tropical Riemann–Roch to incorporate Laplacian minor structure; builds on Develin–Santos–Sturmfels [2005] tropical rank theory.

**Ambition:** ★★★☆☆ (Solid extension — trees are the natural testing ground, and the tools are available.)

---

## Direction 2: Equality Characterization Conjecture

**Conjecture:** For a connected graph $G$, root $q$, and $S \subseteq V \setminus \{q\}$, equality $r(D_S) = \mathrm{tropRank}(L_S) - 1$ holds if and only if $S$ consists of vertices in a single connected component of $G - q$ and the induced subgraph $G[S]$ is a tree.

**Test:** For all connected graphs on $n \leq 8$ vertices, classify all equality cases and check whether they match the combinatorial criterion. Compare against the alternative criterion: "$S$ is a union of rooted cut-components relative to $q$."

**Impact:** Equality characterization is the fingerprint of the bridge — it reveals exactly when tropical rank perfectly captures chip-firing capacity. If the criterion involves tree structure of the induced subgraph, this connects to the theory of $q$-reduced divisors and the Bernardi bijection.

**Catalog References:**
- `Pythagorean/TropicalBridge/Defs.lean` — `NestedCutFamily`, `firingIndependentOn`
- `Pythagorean/TropicalBridge/Theorems.lean` — `rootedSubsetDivisor_decomposition`, `rootedSubsetDivisor_S_pos`

**Proof Strategy:** Show that equality holds iff the Laplacian columns restricted to $S$ form a "tight" system: every tropical linear dependence corresponds to an actual chip-firing relation. Formalize using `firingIndependentOn` and connect to the tropical Plücker relations.

**Domain Bridges:** Matroid theory (valuated matroids and their tight spans) ↔ chip-firing lattice structure ↔ tropical Grassmannian.

**Lineage:** Connects to Speyer's tropical linear spaces [2008] and the theory of regular subdivisions.

**Ambition:** ★★★★☆ (Requires deep structural insight into when tropical and integer independence coincide.)

---

## Direction 3: Tropical Hodge Decomposition for Graph Divisors

**Conjecture (Grand Challenge):** There exists a decomposition of the degree-zero divisor lattice $\mathrm{Div}^0(G)$ into orthogonal tropical-algebraic components:
$$\mathrm{Div}^0(G) = \bigoplus_{k=0}^{g} H^k_{\mathrm{trop}}(G)$$
where $g$ is the genus and $H^k_{\mathrm{trop}}(G)$ consists of divisors whose rank is controlled by tropical rank- $k$ principal minors. Specifically, $D \in H^k_{\mathrm{trop}}(G)$ iff the minimal supporting subset $S$ satisfies $\mathrm{tropRank}(L_S) = k + 1$.

**Test:** For all connected graphs on $n \leq 7$, compute the partition of $\mathrm{Div}^0(G)$ by tropical rank of minimal supporting subset. Check whether the components satisfy orthogonality (vanishing inner product in the chip-firing lattice).

**Impact:** A tropical Hodge decomposition would be a paradigm shift — it would provide a new structural theory for graph divisors paralleling the Hodge decomposition in Riemannian geometry. This could unify chip-firing, tropical geometry, and spectral graph theory into a single framework.

**Catalog References:**
- `Pythagorean/TropicalBridge/Theorems.lean` — `support_rootedSubsetDivisor_subset` (support localization as prototype for component membership)
- `Catalog/Tropical/FactorRank.lean` — `tropFactorRank`, `tropDecompOfRank` (tropical decomposition machinery)

**Proof Strategy:** Begin by defining the "tropical support rank" of a divisor as the tropical rank of the minimal principal minor containing its support. Show this defines a filtration (not just partition) compatible with chip-firing equivalence. The key lemma: if $D_1 \sim D_2$ and $D_1$ has tropical support rank $k$, then $D_2$ has tropical support rank $\leq k$.

**Domain Bridges:** Combinatorial Hodge theory ↔ tropical algebraic geometry ↔ discrete differential forms ↔ graph Laplacian eigenspace decomposition.

**Lineage:** Would parallel the work of Adiprasito–Huh–Katz [2018] on Hodge theory for matroids, transposed to the chip-firing/divisor setting.

**Ambition:** ★★★★★ (Grand challenge — paradigm-shifting if successful.)

---

## Direction 4: Effective Resistance and Tropical Rank Defect

**Conjecture:** For a connected graph $G$, root $q$, and $S \subseteq V \setminus \{q\}$, the gap
$$\Delta(G, q, S) = (\mathrm{tropRank}(L_S) - 1) - r(D_S)$$
is bounded below by a function of the effective resistance diameter of $S \cup \{q\}$:
$$\Delta(G, q, S) \geq f(R_{\max}(S \cup \{q\}))$$
where $R_{\max}$ is the maximum pairwise effective resistance within $S \cup \{q\}$ and $f$ is a monotone increasing function.

**Test:** For all connected graphs on $n \leq 6$ vertices, compute both $\Delta$ and $R_{\max}$ for all rooted subsets. Fit the relationship and identify $f$.

**Impact:** This would provide a physical interpretation of the tropical-chip-firing gap: the gap grows when the subset is "electrically dispersed" (high resistance diameter), meaning chip-firing moves are less effective at redistributing chips across the subset.

**Catalog References:**
- `Pythagorean/TropicalBridge/Theorems.lean` — `graphLaplacian_symmetric`, `principalMinor_row_sum` (Laplacian structure underlying resistance)
- `Catalog/Tropical/ChipFiring/Theorems.lean` — `divisorDegree_laplacian_zero` (conservation law for chip-firing)

**Proof Strategy:** Use the Green's function (Laplacian pseudoinverse) to express effective resistance as a quadratic form. Show that high resistance implies that chip-firing potentials needed to reach effective divisors must have large gradients, which tropical rank cannot detect.

**Domain Bridges:** Discrete potential theory ↔ electrical networks ↔ random walks ↔ tropical linear algebra.

**Lineage:** Extends classical effective resistance theory (Doyle–Snell) into the tropical setting.

**Ambition:** ★★★★☆ (Requires new techniques at the intersection of potential theory and tropical algebra.)

---

## Direction 5: Algorithmic Applications — Tropical Upper Bounds for Network Design

**Conjecture:** The upper bound $r(D_S) \leq \mathrm{tropRank}(L_S) - 1$ can be used as a polynomial-time computable *certificate* for network robustness: if the tropical rank of a principal Laplacian minor is low, then no chip-firing strategy can achieve high divisor rank on the corresponding canonical divisor.

**Test:** Implement the tropical rank computation for Laplacian minors as a polynomial-time approximation algorithm (using the Hungarian algorithm for optimal assignment as a subroutine). Compare the tropical upper bound against exact divisor rank computation on random graphs with $n \leq 50$ vertices.

**Impact:** Computing Baker–Norine rank exactly is NP-hard in general. A polynomial-time tropical upper bound would provide a practical certificate for network designers: "this network cannot support high-rank divisors on this subset," enabling efficient pruning of design space.

**Catalog References:**
- `Pythagorean/TropicalBridge/Defs.lean` — `graphLaplacian`, `laplacianPrincipalMinor`
- `Catalog/Tropical/FactorRank.lean` — `tropFactorRank_le_min` (dimension bounds)

**Proof Strategy:** Show that the tropical rank of a $k \times k$ matrix can be computed in $O(k^3)$ time using the tropical analog of Gaussian elimination (Butkovič's algorithm). Combine with the upper bound theorem to get a polynomial-time certificate.

**Domain Bridges:** Computational complexity ↔ combinatorial optimization ↔ network design ↔ tropical algorithms.

**Lineage:** Builds on Butkovič's "Max-linear Systems" [2010] and extends tropical algorithmic theory to graph divisor computation.

**Ambition:** ★★★☆☆ (Solid algorithmic extension with clear practical applications.)
