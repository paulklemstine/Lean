# Future Directions: Overlap Class Rigidity and Beyond

## Synthesis

The overlap class framework introduced in `OverlapClassRigidity.lean` establishes the first rigorous theory of support interactions for tropical kernel generators. The key achievement is the **disjointness-from-non-connectivity theorem**: supports in different overlap classes share no elements, making overlap classes the natural interaction sectors. Combined with the zero-characterization theorem (overlap degree zero ↔ pairwise disjoint), this proves the framework genuinely extends the existing disjoint-support rigidity theory.

The five directions below fan out from this foundation. Directions 1–2 are immediate extensions provable with current tools. Direction 3 bridges to matroid theory. Direction 4 connects to algebraic topology and higher-order interactions. Direction 5 is a grand challenge that would unify tropical algebra with combinatorial optimization.

All directions share a common thread: the conviction that **local overlap patterns among cycle supports control global algebraic structure**, and that formalizing this control will reveal new invariants applicable across discrete mathematics.

---

## Direction 1: Componentwise Factorization of Tropical Projective Classes

**Conjecture:** If the support overlap graph decomposes into connected components $C_1, \ldots, C_k$, then the set of tropical projective equivalence classes of minimal generating families factorizes as a product over components:
$$|\text{TropProjClasses}(G, q, S)| = \prod_{i=1}^{k} |\text{TropProjClasses}_{C_i}(G, q, S)|.$$

**Test:** For all connected graphs on $n \leq 9$ vertices, compute the class count and verify multiplicativity over overlap components. A single counterexample refutes the conjecture; verification up to $n = 9$ provides strong evidence.

**Impact:** This would establish overlap classes as the true interaction sectors of tropical algebra, reducing the classification problem to independent subproblems. It would also suggest a parallel factorization in matroid theory.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `TropProjEquiv`, `disjoint_support_unique_up_to_tropProjEquiv`
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `OverlapEquiv`, `disjoint_of_not_overlapConnected`

**Proof Strategy:** Define "component-restricted generating families" and show that any full generating family decomposes uniquely into component-restricted parts. The key lemma is that generators with support in different overlap classes are algebraically independent in the tropical kernel. Use the disjointness theorem from `OverlapClassRigidity.lean` to establish this independence, then apply the existing uniqueness theorem componentwise.

**Domain Bridges:** Statistical mechanics (decoupling of independent sectors), algebraic topology (Künneth-type factorization).

**Lineage:** Direct extension of `disjoint_of_not_overlapConnected` and `overlapDegree_eq_zero_iff`.

**Ambition:** ★★★☆☆ (solid extension — high probability of success)

---

## Direction 2: Uniqueness in the Overlap-Degree-One Regime

**Conjecture:** When every pair of distinct cycle supports intersects in at most one vertex (max overlap degree ≤ 1), minimal generating families are unique up to `TropProjEquiv` within each overlap class.

**The key insight is** that single-vertex intersections create "pinch points" that force values on one generator to propagate constraints to the overlapping generator, analogous to the leaf rigidity theorem but at intersection points rather than pendant vertices.

**Why now?** The max overlap degree characterization theorem (`maxOverlapDeg_eq_zero_of_pairwiseDisjoint`) provides the base case, and the harmonic leaf rigidity theorem from `TropicalKernelRigidity.lean` provides the propagation mechanism. The overlap-degree-one regime is the natural next step.

**Test:** Enumerate all connected graphs on $n \leq 8$ with max overlap degree exactly 1 and verify uniqueness of tropical projective classes within each overlap component.

**Impact:** First genuinely new rigidity result beyond disjoint supports. Would open a sequence of "overlap-degree $k$" theorems.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `harmonic_leaf_rigidity`, `support_matching_injective`
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `MaxOverlapDeg`, `crossOverlapCount_pos_iff`

**Proof Strategy:** At each single-vertex intersection $v \in F_i \cap F_j$, harmonicity forces $f_i(v) + c_i = f_j(v) + c_j$ for appropriate constants. This creates a system of linear constraints on the constants $c_i$, which is determined when the overlap graph is a tree (no cycles among supports). For overlap graphs with cycles, additional combinatorial arguments involving the cycle rank of the overlap graph itself are needed.

**Domain Bridges:** Coding theory (single-overlap interactions among codeword supports), graph coloring (intersection graphs with bounded clique number).

**Lineage:** Extends `harmonic_leaf_rigidity` and `pairwiseDisjoint_of_maxOverlapDeg_zero`.

**Ambition:** ★★★★☆ (challenging but feasible with current tools)

---

## Direction 3: Matroid Circuit Intersection Reformulation

**Conjecture:** The overlap class structure generalizes from cycle supports in graphs to circuit supports in graphic matroids, and the overlap rigidity principle (if true) extends to regular matroids.

**The key insight is** that cycle supports in $G[S]$ are exactly circuit supports in the graphic matroid $M(G[S])$. The overlap graph on cycle supports is the **circuit intersection graph** of the matroid. Circuit elimination — the operation that replaces two circuits sharing an element with a third circuit — provides the algebraic mechanism for understanding how overlap classes interact.

**Why now?** The matroid-invariance theorem in `TropicalKernelRigidity.lean` (`same_induced_structure_same_laplacian`) already shows that the tropical kernel depends only on the induced subgraph structure, which encodes the cycle matroid. The overlap framework is ready to absorb this matroid-level perspective.

**Test:** Implement the circuit intersection graph for small matroids (representable over GF(2), GF(3)) and test the overlap rigidity conjecture. Compare class counts for isomorphic matroids with different graph representations.

**Impact:** If successful, this would generalize the entire overlap theory from graphs to matroids, connecting tropical algebra to one of the most powerful abstract frameworks in combinatorics. It would also suggest a valuated matroid version relevant to tropical Grassmannians.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `same_induced_structure_same_laplacian`
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `OverlapConnected`, `OverlapSignature`

**Proof Strategy:** Reformulate `OverlapConnected` in terms of matroid circuits rather than graph cycles. Show that circuit elimination preserves overlap classes. Use the matroid union theorem to establish decomposition results.

**Domain Bridges:** Algebraic geometry (tropical Grassmannians), optimization (matroid intersection algorithms).

**Lineage:** Conceptual generalization of the entire overlap framework.

**Ambition:** ★★★★★ (grand challenge — potentially field-opening)

---

## Direction 4: Higher-Order Overlap via Support Nerves

**Conjecture:** The overlap graph (pairwise intersections) is insufficient to determine tropical projective class counts in general. The **support nerve** — the simplicial complex whose $k$-simplices are $(k+1)$-tuples of supports with nonempty common intersection — captures the missing information.

**The key insight is** that three supports $A, B, C$ can pairwise overlap without having a common triple intersection ($A \cap B \neq \emptyset$, $B \cap C \neq \emptyset$, $A \cap C \neq \emptyset$, but $A \cap B \cap C = \emptyset$). This distinction is invisible to the overlap graph but captured by the nerve. Higher-order interactions may create or destroy tropical projective classes.

**Why now?** The overlap signature introduced in `OverlapClassRigidity.lean` records pairwise intersection sizes but not higher-order intersections. Computing the nerve requires the same Finset operations already available. Applied topology (TDA) provides both computational tools and conceptual motivation.

**Test:** Find two support families with isomorphic overlap graphs and identical overlap signatures but different nerves. Check whether they have different tropical projective class counts.

**Impact:** Would identify the "correct" topological invariant controlling tropical algebra. Could connect to persistent homology and topological data analysis.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `OverlapSignature`, `CrossOverlapCount`

**Proof Strategy:** Define the support nerve as a simplicial complex. Compute its Betti numbers. Conjecture that class count depends on overlap graph plus nerve Euler characteristic (or specific Betti number).

**Domain Bridges:** Topological data analysis (persistent homology of support complexes), algebraic topology (nerve theorems), statistical physics (higher-order interactions).

**Lineage:** Refinement of `OverlapSignature` to capture non-pairwise data.

**Ambition:** ★★★★☆ (conceptually deep, computationally tractable)

---

## Direction 5: Tropical Kernel Complete Invariant Classification

**Conjecture (Grand Challenge):** There exists a computable combinatorial invariant $\mathcal{I}(G, q, S)$ — expressible in terms of the support overlap data and the induced cycle rank — that exactly determines the number of tropical projective equivalence classes of minimal generating families.

**The key insight is** that the overlap framework provides a lower bound (overlap class count) and the induced cycle rank from `DefectTheory.lean` provides an upper bound. The true invariant lies between these bounds and is determined by their interaction.

**Why now?** The overlap class count and the induced cycle rank are both computable and formalized. The gap between them is the "overlap correction term" that encodes the genuine new mathematics. Computational experiments can map this gap precisely.

**Test:** For all connected graphs on $n \leq 10$, compute (overlap class count, induced cycle rank, TropProjEquiv class count) and search for a functional relationship. If a polynomial or linear relationship exists, conjecture and test it.

**Impact:** A complete invariant would be a major advance in tropical combinatorics, providing an exact bridge between topology (cycle rank), combinatorics (overlap structure), and algebra (tropical kernel decomposition). It would also yield new algorithms for graph classification and recognition.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — all overlap invariants
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` — `inducedCycleRank`, `structuralDefect`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `TropProjEquiv`

**Proof Strategy:** Start with the sandwich inequality: overlap class count ≤ TropProjEquiv class count ≤ f(overlap data, cycle rank). Narrow the sandwich by proving structural lemmas about how cycle rank constrains the overlap correction term. If the sandwich collapses to equality, the invariant is found.

**Domain Bridges:** Computational complexity (graph isomorphism via invariants), tropical geometry (tropical Grassmannian stratification), information theory (minimal description complexity of tropical kernels).

**Lineage:** Synthesis of the entire overlap framework with defect theory.

**Ambition:** ★★★★★ (paradigm-shifting if achieved)
