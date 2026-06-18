# Future Directions: Support Compression for Lorentzian Certification

## Synthesis

The support compression theorem reveals that Lorentzian recognition complexity for matroid basis polynomials is governed not by ambient polynomial structure but by the combinatorial geometry of the support. This opens a research program connecting three traditionally separate domains: (1) discrete convex analysis and the M-convex exchange property, (2) algorithmic matroid theory and independent-set enumeration, and (3) Lorentzian/log-concavity certification in algebraic combinatorics. The five directions below push this program from exact identities for matroid basis polynomials toward a general complexity theory for structured polynomial certification, with bridges to statistical physics, coding theory, and computational complexity.

---

## Direction 1: M-Convex Exchange as a Universal Pruning Principle

**Conjecture:** For any homogeneous polynomial *p* with nonnegative coefficients whose Newton support is M-convex, the number of nonzero quadratic derivative leaves is at most |{α : |α| = d−2, α is in the (d−2)-truncation of the M-convex set}|. This truncation has cardinality controlled by the exchange geometry, yielding compression ratios independent of the ambient dimension.

**Test:** Formalize the (d−2)-truncation of an M-convex set as a Finset operation. Compute the truncation size for (a) valuated matroid supports, (b) generalized permutahedra vertices, and (c) stable polynomial supports from the Borcea–Brändén theory. Compare with actual derivative leaf counts from symbolic computation.

**Impact:** Would establish M-convexity itself — not just the matroid axiom — as the structural driver of certification compression. This generalizes from matroid basis polynomials to Schur polynomials, partition functions of discrete convex ensembles, and multivariate generating functions arising in algebraic combinatorics.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — `IsMConvexExchangeNat`, `NewtonSupport`
- `Catalog/Pythagorean/SupportCompression.lean` — `independentSetsOfSize`, `derivative_nonzero_iff_dominated`
- `Catalog/Bridges/LorentzianRecognition.lean` — `numberOfQuadraticLeaves`, `multiIndexSet`

**Proof Strategy:** Generalize Theorem 1 from multiaffine supports to arbitrary M-convex supports by showing that the exchange property forces the set of dominated multiindices to form a well-structured truncation. Key technical step: prove that if S is M-convex and α ≤ β for some β ∈ S with |α| = |β| − 2, then α lies in the "shadow" of S, which is again M-convex (or at least cardinality-bounded by M-convex exchange counts).

**Domain Bridges:** Discrete convex analysis (Murota), algebraic combinatorics (Schur positivity), tropical geometry (valuated matroids).

**Lineage:** Extends Theorem 2 (quadraticLeaves_eq_indepSets) from matroid bases to arbitrary M-convex supports.

**Ambition:** Grand challenge — paradigm-shifting. Would unify Lorentzian recognition theory with discrete convex analysis.

---

## Direction 2: Graphic Matroid Leaf Counts via Matrix-Tree Methods

**Conjecture:** For the graphic matroid of a graph G on m edges with cyclomatic number c = m − n + 1, the quadratic leaf count (= number of forests of size n − 3) satisfies:

#{forests of size n−3 in G} = coefficient of t^{n−3} in the forest polynomial F_G(t) = det(I + tL_G)

where L_G is the Laplacian matrix. This can be computed in O(n^ω) time using matrix methods, avoiding the exponential enumeration of bases.

**Test:** For graphs with known Laplacian spectra (complete graphs, cycles, grids, random sparse graphs), compute forest counts both by enumeration and by the matrix-tree formula. Verify agreement and benchmark running times.

**Impact:** Would give polynomial-time computation of the exact Lorentzian certification complexity for graphic matroids, making support-compressed certification practical for networks with thousands of edges.

**Catalog References:**
- `Catalog/Pythagorean/SupportCompression.lean` — `independentSetsOfSize`, `countNonzeroQuadraticLeavesFromBases`
- `Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`

**Proof Strategy:** Connect forest counts to Laplacian determinants via the matrix-tree theorem generalization for forests. The coefficient of t^k in det(I + tL_G) counts k-edge forests. Formalize the matrix-tree theorem for forests in Lean 4, then specialize to k = n − 3.

**Domain Bridges:** Spectral graph theory, network reliability (all-terminal reliability coefficients), electrical network theory (effective resistance).

**Lineage:** Specializes Theorem 2 to graphic matroids; connects to `Catalog/Bridges/LorentzianRecognition.lean` complexity bounds.

**Ambition:** Solid extension. Directly converts the abstract compression theorem into an efficient algorithm.

---

## Direction 3: Support Compression for Statistical Physics Partition Functions

**Conjecture:** For the basis generating polynomial of a matroid M arising from a strongly Rayleigh measure (random spanning tree, determinantal point process), the support-compressed certification complexity is O(poly(n)) — not merely sub-exponential but polynomial — because the underlying negative dependence structure forces the independent-set complex to have polynomial-size (n − 3)-skeleton.

**The key insight is** that negative dependence (as formalized by the strongly Rayleigh property) constrains the matroid to have polynomially many independent sets of any fixed deficiency from the rank, because the exchange property combined with negative dependence forces rapid "filling" of independent sets to bases.

**Why now?** The connection between Lorentzian polynomials and strongly Rayleigh measures was established by Brändén–Huh (2020), but its algorithmic implications for certification complexity have not been explored. The support compression theorem provides the missing link: it converts the spectral certification problem into an independent-set counting problem where negative dependence can be leveraged.

**Test:** For determinantal point processes on graphs with known kernels, compute independent (r−2)-set counts and verify polynomial scaling. Compare with random matroids (which should show exponential counts, disproving the conjecture in the non-strongly-Rayleigh case).

**Impact:** Would establish that physically meaningful partition functions — those with negative dependence — are certifiably Lorentzian in polynomial time, connecting Lorentzian certification to efficient simulation of physical systems.

**Catalog References:**
- `Catalog/Pythagorean/SupportCompression.lean` — all main theorems
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — M-convex exchange

**Proof Strategy:** Combine the support compression theorem with known results on the polynomial growth of independent-set counts in strongly Rayleigh matroids. The key technical lemma: a strongly Rayleigh matroid of rank r on n elements has at most n^{O(1)} independent sets of size r − k for any fixed k.

**Domain Bridges:** Statistical physics (negative dependence, Rayleigh measures), probability (determinantal point processes), quantum information (fermion algebras).

**Lineage:** Extends the support compression framework from complexity bounds to computational feasibility.

**Ambition:** Grand challenge. Would bridge Lorentzian polynomial theory with computational physics.

---

## Direction 4: Coding Theory via Support Compression of Linear Matroid Polynomials

**Conjecture:** For the matroid of a linear code C ⊆ F_q^n (the vector matroid of the generator matrix), the support-compressed leaf count equals the number of codeword-free (r−2)-subsets of coordinate positions, which is related to the minimum distance profile of the code.

**The key insight is** that for a [n, k, d] linear code, the independent sets of size k − 2 in the associated matroid correspond to column subsets of the generator matrix that have full rank after removing 2 columns. The minimum distance d controls how many such subsets can fail to be independent, creating a direct link between coding-theoretic parameters and certification complexity.

**Why now?** The weight enumerator of a linear code is a specialization of the matroid basis polynomial (Tutte polynomial). Support compression for matroid basis polynomials thus immediately specializes to give certification complexity bounds for weight enumerators, which are central objects in coding theory and have known Lorentzian-type properties for self-dual codes.

**Test:** For Reed-Solomon codes, BCH codes, and random linear codes over F_2, compute independent (k−2)-set counts and correlate with minimum distance, covering radius, and generalized Hamming weights.

**Impact:** Would connect Lorentzian certification to coding theory, potentially yielding new bounds on code parameters from log-concavity properties and new efficient decoding algorithms from certified Lorentzian structure.

**Catalog References:**
- `Catalog/Pythagorean/SupportCompression.lean` — `independentSets_le_active_choose`, `indepSets_le_choose_univ`

**Proof Strategy:** Use the fact that a column subset of the generator matrix is independent in the matroid iff it has full rank. The number of rank-deficient (k−2)-subsets is controlled by the minimum distance and generalized Hamming weights. Formalize the matroid of a linear code and apply Theorem 4.

**Domain Bridges:** Coding theory (weight enumerators, minimum distance), information theory, algebraic geometry over finite fields (Goppa codes).

**Lineage:** Applies the general framework to the specific matroid family of linear codes.

**Ambition:** Solid extension with potential for surprising connections.

---

## Direction 5: Computational Hardness Boundaries for Lorentzian Certification

**Conjecture:** Computing the exact support-compressed leaf count (i.e., counting independent (r−2)-sets of a matroid) is #P-hard for general matroids presented by an independence oracle, but polynomial-time solvable for graphic, transversal, and representable matroids over fixed finite fields.

**The key insight is** that counting independent sets of a given size in a matroid is equivalent, by the support compression theorem, to computing the exact Lorentzian certification complexity. This converts a question about polynomial algebra into a question about combinatorial counting complexity, where mature tools from computational complexity theory can be applied.

**Why now?** The #P-hardness of counting bases of general matroids is classical (Colbourn 1987). The support compression theorem shows that leaf counting is a cousin of basis counting — both involve enumeration in the independent-set complex — but the precise complexity of counting independent sets of *intermediate* size (not just bases) in general matroids is less explored.

**Test:** Implement the support-compressed algorithm for matroids presented by different oracles (rank oracle, independence oracle, basis enumeration) and benchmark empirically. Construct specific matroid families (e.g., Vämos matroid, non-representable matroids) where the independent-set counting problem is provably hard, and verify that the support-compressed leaf count is computationally intractable for these families.

**Impact:** Would delineate the boundary between tractable and intractable Lorentzian certification. For specific matroid families used in applications (graphic, transversal, representable), it would confirm that support-compressed certification is efficient. For general matroids, it would establish fundamental limits.

**Catalog References:**
- `Catalog/Pythagorean/SupportCompression.lean` — `countNonzeroQuadraticLeavesFromBases`, correctness theorems
- `Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`

**Proof Strategy:** Reduce known #P-hard counting problems (e.g., counting Hamiltonian cycles) to independent-set counting in appropriately constructed matroids. For the positive direction, use matrix-tree methods (graphic), flow methods (transversal), and Gaussian elimination (representable).

**Domain Bridges:** Computational complexity (#P, counting complexity), algorithm design (FPT, parameterized complexity), cryptography (hardness assumptions from matroid counting).

**Lineage:** Provides complexity-theoretic foundations for the support compression framework.

**Ambition:** Grand challenge — would establish the computational complexity landscape of Lorentzian certification.
