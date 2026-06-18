# Future Directions: Overlap Class Theory for Tropical Kernel Generators

## Synthesis

The overlap class framework established in this work reveals that cycle supports in graphs decompose into independent interaction sectors — the connected components of the support interaction graph. This decomposition is exact: supports from different sectors are provably disjoint (Theorem `disjoint_overlap_classes_no_interaction`), and the framework recovers the classical disjoint-support rigidity as the special case of maximal fragmentation (Theorems `overlapDegree_eq_zero_iff_pairwiseDisjoint` and `overlapClassCount_eq_card_of_pairwiseDisjoint`).

The five directions below push from this foundation toward a complete understanding of how overlap geometry governs tropical algebra. They range from targeted extensions (Directions 2–3) that build directly on verified catalog theorems to paradigm-shifting conjectures (Directions 1, 4–5) that would connect graph theory to matroid theory, coding theory, and combinatorial topology. Each direction is designed to be falsifiable and specific enough to fail.

---

## Direction 1: Componentwise Factorization of TropProjEquiv Classes

**Conjecture:** For any connected graph $G$, basepoint $q$, and subset $S \subseteq V \setminus \{q\}$, the number of tropical projective equivalence classes of minimal generating families factors as a product over overlap classes:
$$|\text{TropProjEquiv classes}| = \prod_{C \in \text{OverlapClasses}} f(C)$$
where $f(C)$ depends only on the restriction of the generating family to class $C$.

**Test:** Implement the full tropical kernel computation for connected graphs on $n \leq 8$ vertices. For each $(G, q, S)$, enumerate minimal generating families, quotient by TropProjEquiv, and check whether the class count is multiplicative over overlap classes. A single instance where the count is not a product of per-class counts would refute the conjecture.

**Impact:** If true, this reduces the global classification problem to independent local problems, one per overlap class. This is the tropical analogue of the decomposition of representations into irreducible components.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean`: `overlapClassCount_eq_card_of_pairwiseDisjoint`, `disjoint_overlap_classes_no_interaction`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `disjoint_support_unique_up_to_tropProjEquiv`

**Proof Strategy:** Use the sector independence theorem to decompose any minimal generating family into per-class subfamilies. Show that TropProjEquiv acts independently on each sector (the permutation $\sigma$ preserves overlap classes by `tropProjEquiv_preserves_overlap`). Deduce multiplicativity.

**Domain Bridges:** Statistical physics (independent partition functions per interaction sector), representation theory (irreducible decomposition).

**Lineage:** Extends `overlapClassCount_eq_card_of_pairwiseDisjoint` from the disjoint case to general overlap.

**Ambition:** Grand challenge — would establish overlap classes as the definitive interaction sectors for tropical algebra on graphs.

---

## Direction 2: Uniqueness in the Overlap-Degree-One Regime

**Conjecture:** When the overlap degree is at most 1 (every pair of distinct cycle supports shares at most one vertex), the minimal generating family within each overlap class is unique up to TropProjEquiv.

**Test:** For all connected graphs on $n \leq 9$ vertices with overlap degree $\leq 1$, enumerate generating families within each overlap class and verify uniqueness up to TropProjEquiv. The `overlapDegree_le_one_iff` theorem provides the Lean-verified characterization.

**Impact:** This would be the first genuinely new rigidity theorem beyond disjoint supports. It covers a large fraction of non-trivial cases (our computational experiments show overlap degree 1 is the most common non-trivial regime).

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean`: `overlapDegree_le_one_iff`, `overlapDegree_le_iff`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `support_matching_injective`

**Proof Strategy:** When two supports share exactly one vertex $v$, the harmonic constraint at $v$ creates a linear relation between the two generators' values. This should force the generators to be related by an additive constant on their overlap, which combined with `support_matching_injective` should yield the permutation. The key insight is that a single shared vertex creates a "hinge" constraint, not enough freedom for independent variation.

**Domain Bridges:** Matroid theory (circuits sharing one element satisfy the weak circuit elimination axiom), coding theory (minimum-weight codewords with overlap 1 are "almost orthogonal").

**Lineage:** Directly extends the base case `overlapDegree_eq_zero_iff_pairwiseDisjoint` by one step.

**Ambition:** Solid extension — high probability of success, would open the overlap-degree hierarchy.

---

## Direction 3: Sandwich Bounds via Induced Cycle Rank

**Conjecture:** The number of TropProjEquiv classes is bounded above by a function of the induced cycle rank and the overlap class count:
$$\text{overlapClassCount}(F) \leq |\text{TropProjEquiv classes}| \leq \text{overlapClassCount}(F) \cdot (1 + \text{inducedCycleRank}(G, S))$$

**Test:** Compute both sides for all connected graphs on $n \leq 8$ vertices. The lower bound should always hold (each overlap class contributes at least one equivalence class). The upper bound uses `inducedCycleRank` from `DefectTheory.lean` as the control parameter.

**Impact:** Even a weaker version (replacing the exact upper bound with any computable function of the cycle rank) would be highly valuable. It would show that the interaction within each overlap class is controlled by the topological complexity of the induced subgraph.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean`: `inducedCycleRank`, `structuralDefect_nonneg`
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean`: `overlapClassCount_le_card`, `overlapClassCount_pos`

**Proof Strategy:** Lower bound: each overlap class contains at least one generator, and generators from different classes are independent (by `disjoint_overlap_classes_no_interaction`). Upper bound: within an overlap class on $k$ supports with cycle rank $\beta_1$, the tropical kernel restricted to the class has dimension $\leq \beta_1$, bounding the number of essentially different generators.

**Domain Bridges:** Algebraic topology (Betti numbers control dimensions of harmonic spaces), spectral graph theory (cycle rank bounds spectral gap).

**Lineage:** Bridges `DefectTheory.lean` and `OverlapClassRigidity.lean`.

**Ambition:** Solid extension — the lower bound is likely provable; the upper bound requires more work.

---

## Direction 4: Matroid-Level Generalization

**Conjecture:** The overlap class theory extends from graphic matroids to all regular matroids: for any regular matroid $M$ on ground set $E$, the circuit intersection graph's connected components control the tropical projective equivalence classes of minimal tropical Grassmannian representatives.

The key insight is that our proofs use only the circuit elimination axiom and the fact that circuit supports in graphic matroids are vertex sets of cycles — both of which generalize to regular matroids.

**Why now?** The formalization in `TropicalKernelRigidity.lean` already uses `SameInducedStructure` (matroidal invariance), showing that the Laplacian kernel depends only on the induced subgraph structure (i.e., the graphic matroid). This is the seed for a matroid-level theory.

**Test:** Implement the overlap class framework for the regular matroid $R_{10}$ (which is not graphic) and check whether the circuit intersection graph still controls tropical representatives. A failure here would identify exactly what graphic property is needed beyond matroid structure.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`: `same_induced_structure_same_laplacian`, `same_laplacian_same_kernel`

**Proof Strategy:** Replace graph-specific constructions (adjacency, degree, Laplacian) with matroid-theoretic ones (circuits, rank function, Tutte polynomial). The overlap graph becomes the circuit intersection graph. Prove that tropical projective equivalence in the valuated matroid setting respects circuit intersection components.

**Domain Bridges:** Algebraic geometry (tropicalization of Grassmannians), optimization (matroid intersection algorithms), cryptography (matroid-based secret sharing schemes).

**Lineage:** Generalizes all graph-specific results to the matroid level.

**Ambition:** Grand challenge — would establish the overlap framework as a universal tool across combinatorial optimization and algebraic geometry.

---

## Direction 5: Overlap Nerve and Higher-Order Interactions

**Conjecture:** The 2-skeleton of the support nerve (pairwise intersections) does not capture all the relevant interaction structure. There exist examples where three supports have pairwise nonempty intersections but empty triple intersection, and this distinction affects the TropProjEquiv class count.

The key insight is that our `supportNerve2` definition captures only pairwise interactions. If three cycle supports all share vertices pairwise but have no common vertex, the interaction is fundamentally different from when they share a common triple point.

**Why now?** The formalization of `supportNerve2_symm` and `supportNerve2_diag` provides the foundation for higher-order nerve analysis. The overlap graph (2-dimensional) may be too coarse for the full story.

**Test:** Find two graph instances $(G_1, q_1, S_1)$ and $(G_2, q_2, S_2)$ with isomorphic overlap graphs and identical overlap signatures, but different TropProjEquiv class counts. Such a pair would prove the 2-skeleton is insufficient and higher-order interactions matter.

**Impact:** If confirmed, this would redirect the field from overlap graphs (1-dimensional) to overlap simplicial complexes (higher-dimensional), connecting to persistent homology and topological data analysis.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean`: `supportNerve2`, `supportNerve2_symm`, `overlapSignature`

**Proof Strategy:** Systematic computer search among graphs on $n = 7, 8, 9$ vertices for pairs with matching overlap graphs but different algebraic structure. If found, formalize the distinguishing higher-order invariant (e.g., the 3-skeleton of the support nerve).

**Domain Bridges:** Topological data analysis (persistent homology of support complexes), algebraic topology (nerve theorems), quantum information (multipartite entanglement structures).

**Lineage:** Extends the overlap signature to higher-order nerve invariants.

**Ambition:** Grand challenge — would open a new direction connecting tropical algebra to computational topology.
