# Future Directions: Support-Compressed Lorentzian Recognition

## Synthesis

The discovery that Lorentzian recognition recursion trees for matroid basis polynomials collapse to the independent-set complex opens a new research program at the intersection of discrete convex analysis, algebraic combinatorics, and computational complexity. The five directions below follow a logical arc: from exact enumeration in specific matroid families (Directions 1–2), through structural deepening via M-convexity (Direction 3), to algorithmic and physical consequences (Directions 4–5). Together, they aim to establish **discrete convexity as a complexity theory for symbolic inequalities**, where support geometry replaces brute-force algebra as the controlling parameter.

---

## Direction 1: Forest Counting and the Kirchhoff Connection

**Conjecture.** For the graphic matroid of a connected graph *G* on *n* vertices with *m* edges, the number of nonzero quadratic leaves of the basis generating polynomial equals the number of forests of *G* with exactly *n*−3 edges. This count is computable in polynomial time via a determinantal formula analogous to Kirchhoff's matrix-tree theorem.

**Test.** Implement and compare:
1. Direct enumeration of (*n*−3)-forests in random sparse graphs (Erdős–Rényi with edge probability *p* = *c*/*n*).
2. Determinantal computation via a Kirchhoff-type Laplacian minor formula.
3. The support-compressed leaf count algorithm.

Verify agreement for all graphs up to 10 vertices and 20 edges.

**Impact.** Establishes a polynomial-time algorithm for Lorentzian leaf counting in graphic matroids, bypassing exponential enumeration. Connects Lorentzian recognition to the deep algebraic graph theory of the Laplacian.

**Catalog References.**
- `Pythagorean/SupportCompression.lean`: `quadraticLeaves_eq_indepSets`
- `Pythagorean/SupportCompressionPoly.lean`: `derivative_survival_iff_independent`

**Proof Strategy.** Use the matrix-tree theorem to express the number of spanning trees as det(L₀), where L₀ is a reduced Laplacian. Derive an analogous formula for forests of size *k* using the full Laplacian's characteristic polynomial. Show the coefficient of λ² in det(λI + L) counts forests of size *n*−3 (by Kelmans–Chelnokov).

**Domain Bridges.** Graph theory ↔ spectral theory ↔ Lorentzian polynomials.

**Lineage.** Extends the uniform matroid closed form (Theorem 3) to the graphic family.

**Ambition.** ★★★☆☆ — Solid extension, well-connected to classical results.

---

## Direction 2: Transversal Matroids and Bipartite Matching Complexity

**Conjecture.** For transversal matroids arising from bipartite graphs with bounded degree Δ, the quadratic leaf count grows as O(n^{r−2} · Δ^{O(1)}), where *r* is the rank. This is polynomial in *n* for fixed *r* and Δ, and dramatically below the ambient bound when the bipartite graph is sparse.

**Test.** Compute leaf counts for transversal matroids from:
1. Random bipartite graphs with bounded degree Δ ∈ {2, 3, 4}.
2. Structured bipartite graphs: grids, expanders, Ramanujan bipartite graphs.
3. Compare with the permanent of the biadjacency matrix (counting perfect matchings).

**Impact.** Opens a route to efficient Lorentzian certification for assignment and scheduling problems, where the underlying combinatorial structure is a bipartite matching.

**Catalog References.**
- `Pythagorean/SupportCompressionPoly.lean`: `supportCompressedLeafCount_le_active_choose`
- `Speculative/AutoResearch/LorentzianMConvex.lean`: `IsMConvexExchangeNat`

**Proof Strategy.** Bound the number of independent (*r*−2)-sets by relating them to partial matchings. Use the Tutte–Berge formula or König's theorem to control the structure of partial matchings in bounded-degree bipartite graphs.

**Domain Bridges.** Matching theory ↔ assignment problems ↔ operations research.

**Lineage.** Builds on the active variable bound (Theorem 4) and the hereditary property.

**Ambition.** ★★★☆☆ — Solid, with clear practical applications.

---

## Direction 3: M-Convex Shadow Theory for General Lorentzian Supports

**Conjecture** (Grand Challenge). For *any* Lorentzian polynomial *f* of degree *d* with M-convex Newton support *S*, the set of surviving degree-(*d*−2) derivative indices is exactly the 2-step shadow of *S* in the M-convex lattice. This shadow has size at most O(|S| · d²), independent of the ambient dimension.

The key insight is that M-convex exchange forces the "shadow" (set of elements obtainable by removing 2 units from some support element) to be tightly controlled by the exchange graph's diameter. Lorentzian supports cannot spread arbitrarily — their exchange geometry constrains them.

**Why now?** The formal verification of the matroid case (Theorems 1–3) provides the first rigorous example of this shadow phenomenon. The M-convex exchange property (`IsMConvexExchangeNat`) is already formalized in the catalog. What's missing is the general shadow bound, which would extend support compression from matroids to arbitrary M-convex families.

**Test.**
1. Construct M-convex sets that are NOT matroid indicator sets (e.g., flow polytope integer points).
2. Compute shadow sizes and compare with the ambient multiindex count.
3. Search for counterexamples: M-convex sets where the shadow grows superlinearly in |S|.

**Impact.** A positive resolution would establish that support compression is a *universal* phenomenon for M-convex Lorentzian polynomials, not specific to matroids. This would be a foundational result in discrete convex analysis.

**Catalog References.**
- `Speculative/AutoResearch/LorentzianMConvex.lean`: `IsMConvexExchangeNat`, `NewtonSupport`
- `Pythagorean/SupportCompressionPoly.lean`: `derivative_nonzero_iff_dominated_support`

**Proof Strategy.** Use the exchange graph of the M-convex set (where two elements are adjacent if they differ by a single exchange). Show that the 2-step shadow is contained in the ball of radius 2 in this graph. Bound the ball size using M-convex structure theorems (Murota 2003, Chapter 4).

**Domain Bridges.** Discrete convex analysis ↔ tropical geometry ↔ optimization theory.

**Lineage.** Generalizes the matroid-specific bijection (Theorem 2) to the M-convex setting.

**Ambition.** ★★★★★ — Paradigm-shifting if true. Would unify support compression across discrete convex analysis.

---

## Direction 4: Certified Lorentzian Recognition for Network Reliability

**Conjecture.** For planar graphs with bounded treewidth *w*, the support-compressed Lorentzian recognition of the reliability polynomial runs in time O(n^{O(w)}), making it fixed-parameter tractable.

The key insight is that for bounded-treewidth graphs, the number of forests (independent sets of the graphic matroid) of any fixed size is bounded by a polynomial whose degree depends on *w*. Combined with support compression, this turns Lorentzian certification from exponential to polynomial.

**Why now?** Support compression (Theorems 2, 4) reduces Lorentzian recognition to independent-set counting. Tree decomposition methods can compute independent-set counts efficiently for bounded-treewidth graphs. The missing step is the formal connection between these two algorithmic paradigms.

**Test.**
1. Implement tree-decomposition-based forest counting for series-parallel graphs and outerplanar graphs.
2. Compare with direct enumeration for graphs up to 50 vertices.
3. Verify that the Lorentzian property holds (using the compressed certificate) for reliability polynomials of telecommunications network models.

**Impact.** Would provide the first practical, provably efficient algorithm for certifying log-concavity of reliability polynomials — a problem of direct interest in network engineering and combinatorial optimization.

**Catalog References.**
- `Pythagorean/SupportCompression.lean`: `countNonzeroQuadraticLeavesFromBases_correct`
- `Pythagorean/SupportCompressionPoly.lean`: `countNonzeroQuadraticLeaves_le_active`

**Proof Strategy.** Use the Courcelle–Makowsky framework for graph polynomials definable in monadic second-order logic. Show that the independent-set count function is MSOL-definable, hence computable in FPT time parameterized by treewidth.

**Domain Bridges.** Network reliability ↔ fixed-parameter tractability ↔ telecommunications.

**Lineage.** Applies the verified algorithm (Section 4 of the paper) to a concrete engineering domain.

**Ambition.** ★★★★☆ — High impact, bridging pure mathematics to engineering practice.

---

## Direction 5: Partition Function Certification in Statistical Mechanics

**Conjecture** (Grand Challenge). For lattice models in statistical mechanics whose partition functions are matroid basis polynomials (e.g., hard-core models on regular lattices), the support-compressed Lorentzian certificate proves strong log-concavity of the partition function with certification cost polynomial in the lattice size, enabling rigorous verification of thermodynamic inequalities at scale.

The key insight is that thermodynamically natural partition functions arise from sparse geometric matroids (graphic matroids of lattice graphs), where the independent-set complex is controlled by the lattice's local geometry. Support compression translates this physical sparsity into computational efficiency.

**Why now?** The connection between Lorentzian polynomials and log-concavity was established by Brändén–Huh [2020]. Support compression (this work) makes the Lorentzian certificate computationally feasible for structured partition functions. What's missing is the explicit construction for specific lattice models and the connection to thermodynamic quantities (free energy, entropy, phase transitions).

**Test.**
1. Compute compressed leaf counts for graphic matroids of square lattice, triangular lattice, and hexagonal lattice subgraphs.
2. Verify that the compression ratio decreases with lattice regularity and dimension.
3. Use the certified log-concavity to derive bounds on partition function zeros (Lee–Yang theory).

**Impact.** Would provide machine-verifiable proofs of thermodynamic inequalities for lattice models, a novel form of rigorous statistical mechanics. Could resolve open conjectures about the location of partition function zeros.

**Catalog References.**
- `Pythagorean/SupportCompressionPoly.lean`: Full theory
- `Speculative/AutoResearch/LorentzianMConvex.lean`: M-convex exchange property

**Proof Strategy.** For regular lattice graphs, use symmetry (automorphism group action) to reduce the independent-set count. Combine with transfer-matrix methods to compute the count exactly for strip lattices. Extrapolate to infinite lattices via thermodynamic limits.

**Domain Bridges.** Statistical mechanics ↔ algebraic combinatorics ↔ computational complexity.

**Lineage.** Extends the graphic matroid analysis (Direction 1) to physically motivated graph families.

**Ambition.** ★★★★★ — Grand challenge connecting pure mathematics to physics. Success would establish a new paradigm: certified statistical mechanics via support geometry.
