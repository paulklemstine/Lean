# Future Directions: Support-Compressed Lorentzian Certification

## Synthesis

The central discovery — that Lorentzian recognition recursion trees for matroid basis polynomials collapse to independent-set complexes — establishes a new bridge between discrete convexity and symbolic certification complexity. This synthesis opens five research directions, from concrete algorithmic applications to paradigm-shifting conjectures. The unifying theme is that **discrete convexity (M-convexity, exchange axioms, matroid structure) is a computational complexity theory for polynomial positivity**, not merely a geometric abstraction. Each direction below builds on the formally verified theorems in `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` and the algorithmic framework in `algorithms.py`, extending them toward new domains and deeper structural questions.

---

## Direction 1: Universal M-Convex Compression Theorem

**Conjecture:** For any homogeneous polynomial p with nonneg coefficients whose Newton support S forms an M-convex set, the nonzero quadratic leaf count of the Lorentzian recognition tree is exactly |{α ∈ S^{(r-2)} : α lies in the (r-2)-skeleton of S}|, where S^{(k)} denotes the k-truncation shadow of S under M-convex exchange.

**Test:** Formalize the M-convex shadow operator, compute it for non-matroidal M-convex sets (e.g., flow polytope lattice points), and verify that the leaf count matches. A disproof would be an M-convex support where cancellation invalidates the bijection.

**Impact:** This would generalize the matroid leaf-independence bijection to the full class of M-convex supports, making discrete convex analysis the *universal* language for Lorentzian certification complexity. It would subsume all matroid-specific results as special cases.

**Catalog References:** `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` (Theorem `derivative_nonzero_iff_dominated_support`), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (M-convex exchange definition `IsMConvexExchangeNat`).

**Proof Strategy:** Extend the multiaffine domination lemma to general M-convex supports. The key obstacle is coefficient cancellation: for non-multiaffine supports, distinct β with α ≤ β may produce the same monomial after differentiation, allowing cancellation. Show that M-convex exchange prevents such cancellation by proving that the derivative map is injective on the fiber above each surviving leaf.

**Domain Bridges:** Discrete optimization (flow polytopes), algebraic combinatorics (Schur positivity), tropical geometry (valuated matroids).

**Lineage:** Extends `derivative_nonzero_iff_dominated_support` from multiaffine to general M-convex.

**Ambition:** Grand challenge — would establish discrete convexity as a complexity theory.

---

## Direction 2: Algorithmic Leaf Counting via Matroid Oracles

**Conjecture:** For any matroid M given by an independence oracle, the nonzero quadratic leaf count can be computed in time O(indepCount(M, r−2) · poly(n, r)), i.e., output-sensitive time, without enumerating all C(n, r−2) candidate subsets.

**Test:** Implement an output-sensitive algorithm using matroid partition and truncation oracles. Benchmark against brute-force enumeration for graphic matroids of random graphs with 50+ vertices. A disproof would be a provable Ω(C(n, r−2)) lower bound for oracle-based algorithms.

**Impact:** Would make Lorentzian certification practical for large matroids arising in network optimization and coding theory, where n can be in the thousands but the independent set count is manageable.

**Catalog References:** `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` (algorithm `countNonzeroQuadraticLeaves`, bound `indepCount_le_active_choose`).

**Proof Strategy:** Use matroid truncation to reduce to enumeration of independent sets of the (r−2)-truncation. Apply the random sampling technique of Anari–Liu–Oveis Gharan–Vinzant for approximate counting, or the direct enumeration technique of Knuth for exact counting in bounded-branchwidth matroids.

**Domain Bridges:** Computational complexity theory, parameterized algorithms, network design.

**Lineage:** Builds directly on `countNonzeroQuadraticLeaves_correct`.

**Ambition:** Solid extension — algorithmic and practically impactful.

---

## Direction 3: Partition Function Certification for Statistical Mechanics

**Conjecture:** For any ferromagnetic Ising model on a graph G with coupling constants J_e ≥ 0, the partition function Z_G(β, h) admits a Lorentzian certificate whose size is bounded by the number of connected subgraphs of G with at most |V|−3 edges, not by the ambient monomial count.

**The key insight is** that physically meaningful partition functions have matroid-like support structure because the thermodynamically dominant configurations are governed by exchange-type constraints (energy minimization, entropy maximization). This means physical relevance implies computational tractability of positivity certification.

**Why now?** The Brändén–Huh theory was established in 2020, but its computational implications for statistical mechanics are unexplored. Our compression theorem provides the first concrete mechanism for translating support geometry into certification efficiency. Recent work on log-concave polynomials in sampling (ALOV 2019) provides the algorithmic infrastructure.

**Test:** Compute Lorentzian certificates for Ising partition functions on random regular graphs. Compare certificate sizes with and without support compression. A disproof would be a physically reasonable model where the support is too irregular for compression.

**Impact:** Would establish that the computational tractability of certifying thermodynamic inequalities (correlation decay, rapid mixing) is governed by the combinatorial structure of the underlying physical system, creating a bridge between statistical physics and combinatorial optimization.

**Catalog References:** `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` (support compression theorem), `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (exchange certification pipeline).

**Proof Strategy:** Express Ising partition functions as specializations of multivariate matroid polynomials. Show that the ferromagnetic condition (J_e ≥ 0) implies the support satisfies M-convex exchange. Apply the compression theorem to bound certificate size.

**Domain Bridges:** Statistical physics, Monte Carlo methods, phase transitions.

**Lineage:** Extends `supportCompression_le_active_choose` to partition functions.

**Ambition:** Grand challenge — bridges combinatorics and physics.

---

## Direction 4: Graphic Matroid Forest Counting and Tutte Polynomial Connections

**Conjecture:** For a graphic matroid of a connected graph G with m edges and cyclomatic number c = m − |V| + 1, the quadratic leaf count equals the number of forests of size |V|−3 in G, and this quantity is computable from the Tutte polynomial T_G(x, y) as a specific evaluation or derivative.

**The key insight is** that the independent-set count at a fixed rank is encoded in the coefficients of the Tutte polynomial, which is the universal matroid invariant. If the leaf count equals a Tutte evaluation, then the entire complexity theory of Lorentzian certification for graphic matroids reduces to Tutte polynomial computation.

**Why now?** The Tutte polynomial is computable in polynomial time for graphs of bounded treewidth (Noble 1998), and recent advances in approximate Tutte polynomial computation (Goldberg–Jerrum 2008) give FPRAS for specific evaluations. Connecting leaf counts to Tutte evaluations would immediately import these algorithmic results.

**Test:** For small graphs (≤ 12 vertices), compute both the leaf count and Tutte polynomial evaluations. Identify the exact relationship. For graphs with known Tutte polynomials (complete graphs, complete bipartite, wheels), verify the conjectured formula.

**Impact:** Would connect Lorentzian certification complexity to one of the most studied invariants in combinatorics, instantly providing exact formulas for many graph families and polynomial-time algorithms for bounded-treewidth instances.

**Catalog References:** `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` (`leafCount_uniformMatroid`, `indep_subset_active`).

**Proof Strategy:** Express the forest count as a coefficient of the rank generating polynomial r_M(x, y) = Σ x^{r(S)} y^{|S|−r(S)}, which is a simple transformation of T_G. Show that the (r−2)-truncation independent set count corresponds to a specific partial derivative of r_M evaluated at appropriate points.

**Domain Bridges:** Graph theory, algebraic combinatorics, computational complexity (Tutte polynomial hardness).

**Lineage:** Specializes the general compression theorem to graphic matroids.

**Ambition:** Solid extension with concrete computational payoff.

---

## Direction 5: Matroid Minor Operations and Certificate Functoriality

**Conjecture:** The nonzero quadratic leaf count is a matroid valuation: for any matroid M and element e, the leaf count satisfies a deletion-contraction recurrence that mirrors the Tutte polynomial recurrence. Specifically:
$$\text{leafCount}(M) = \text{leafCount}(M \setminus e) + \text{correction}(M, e)$$
where the correction term depends on the corank-nullity contribution of e.

**The key insight is** that if the leaf count is a matroid valuation, then it can be computed by any deletion-contraction algorithm, giving a recursive procedure whose complexity depends on the matroid's branch-decomposition width rather than the ambient size. This would make Lorentzian certification fixed-parameter tractable in branchwidth.

**Why now?** Matroid minor theory is fully developed (Oxley 2011), and the formal verification of matroid operations in Lean/Mathlib has recently reached sufficient maturity for machine-checked proofs of deletion-contraction identities. Our formalization provides the base case.

**Test:** Verify the deletion-contraction recurrence computationally for all matroids on ≤ 8 elements (using the matroid database). A disproof would be a matroid where the recurrence fails, indicating the leaf count is not a valuation.

**Impact:** Would make Lorentzian certification a *structurally recursive* computation on matroids, bringing it into the realm of fixed-parameter tractable algorithms and enabling practical certification for large sparse matroids.

**Catalog References:** `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` (`BasisFamily`, `indepCount`).

**Proof Strategy:** Define deletion and contraction for BasisFamily. Prove that indepSets decomposes as indepSets(M\e) ∪ {I ∪ {e} : I ∈ indepSets(M/e)}. The key step is showing this decomposition preserves cardinality counting.

**Domain Bridges:** Fixed-parameter tractable algorithms, tree decompositions, structural graph theory.

**Lineage:** Extends `BasisFamily.indep_subset` to minor operations.

**Ambition:** Solid extension — directly implementable and testable.
