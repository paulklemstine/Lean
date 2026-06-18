# Future Directions

## Synthesis

This research cycle established a rigorous foundation for matroid minor theory in Lean 4, centered on the novel **Rank-Filtered Minor Ideal (RFMI)** structure. The RFMI decomposes minor-closed matroid classes by rank level, reducing the infinitary well-quasi-ordering question to finite combinatorial questions at each level. We proved 14 sorry-free theorems across three files, covering rank function axioms, deletion/contraction/duality operations, the minor relation, filtration properties, width analysis, and the excluded minor finiteness theorem.

The most promising cross-domain connection is between **matroid rank filtrations and tropical geometry**. Tropical matroids (valuated matroids) generalize classical matroids by equipping the rank function with a valuation from the tropical semiring. The RFMI framework could extend naturally to this setting, where the "rank" filtration becomes a "valuation depth" filtration. This connects to the Catalog's `TropicalPersistenceRealizationDuality` bridge theorem, which establishes interleaving results for filtered structures — precisely the kind of structure our rank filtration provides.

The cycle also revealed a fundamental modeling insight: the classical duality theorem for matroid minors fails in fixed-ground-set representations. This negative result is itself valuable, as it constrains which formalization strategies can succeed for the full Robertson-Seymour program. The most promising path forward requires a variable-ground-set formalization using Mathlib's native `Matroid` type.

---

### Direction 1: Tropical Rank Filtrations and Valuated Matroid WQO

**Conjecture**: The RFMI framework extends to valuated matroids (tropical matroids), where the rank function is replaced by a tropical Plücker vector. Specifically, the "tropical rank filtration" — decomposing valuated matroids by the minimum valuation of their bases — yields a filtration with the same monotonicity and width-boundedness properties as the classical case.

**Test**: Define a `TropicalRFMI` structure in Lean 4, where the rank function maps to ℤ ∪ {∞} (tropical semiring) instead of ℕ. Prove filtration monotonicity and minor-closure for tropical matroids on ground sets of size ≤ 4. Verify computationally that the width of each filtration level matches the classical case for uniform valuated matroids.

**Impact**: If true, this would unify the Robertson-Seymour program with tropical geometry, potentially yielding new tools for the conjecture via tropical algebraic geometry. If false, the failure mode would reveal fundamental differences between classical and tropical minor theory.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`, `FINAL/Tropical/GL3FiniteTestFamily.lean`

**Proof Strategy**: Start with the Dressian (parameter space of tropical linear spaces) as the ambient object. Define tropical deletion/contraction via restriction and contraction of tropical Plücker vectors. The key lemma is that tropical submodularity (the tropical analogue of (R3)) is preserved under these operations. Use `graphs_same_rank_interleaving` as a template for the interleaving/filtration arguments.

**Domain Bridges**: Matroid Minor Theory <-> Tropical Geometry <-> Persistence Theory

**Lineage**: Builds on this cycle's RFMI framework (MatroidRankFiltration.lean) and the Catalog's tropical persistence results.

**Ambition**: grand_challenge

---

### Direction 2: Variable-Ground-Set Matroid Minors via Mathlib's Matroid Type

**Conjecture**: The RFMI framework can be reformulated using Mathlib's native `Matroid α` type (which allows variable ground sets), recovering the full duality theorem for minors: if M' is a minor of M, then M'* is a minor of M*. Furthermore, this reformulation will yield a cleaner proof of the excluded minor finiteness theorem that does not require the fixed-ground-set assumption.

**Test**: Define `IsMinorOf` for `Matroid α` using Mathlib's `Matroid.restrict` and the exchange property. Prove the duality theorem. Then reformulate and prove all RFMI theorems in this setting.

**Impact**: Would provide the definitive Lean 4 formalization of matroid minor theory, suitable for attacking the actual Robertson-Seymour conjecture. The fixed-ground-set limitation (discovered in this cycle) would be eliminated.

**Catalog References**: `Shared/MatroidMinor.lean`, `Shared/MatroidWQO.lean` (this cycle's results)

**Proof Strategy**: Use Mathlib's `Matroid.Indep` and `Matroid.restrict` to define deletion. For contraction, define `M / C` via the dual: M / C = (M* \ C)*. This immediately yields the duality theorem by construction. The RFMI framework transfers directly once a notion of "rank" is established via `Matroid.erk` (the rank function in Mathlib).

**Domain Bridges**: Matroid Theory <-> Order Theory (WQO) <-> Lean4/Mathlib Foundations

**Lineage**: Directly extends this cycle's three files, resolving the negative result about duality.

**Ambition**: extension

---

### Direction 3: Finite Excluded Minors for F₃-Representability

**Conjecture**: The set of excluded minors for F₃-representability (ternary matroids) is exactly {U(2,5), U(3,5), F₇, F₇*}, where F₇ is the Fano matroid. Specifically, no matroid on ≤ 8 elements is an excluded minor for F₃-representability beyond these four.

**Test**: Enumerate all matroids of rank ≤ 3 on ground sets of size ≤ 8. For each, determine F₃-representability by checking whether a representing matrix over GF(3) exists (via Gaussian elimination on all possible 3×8 matrices over GF(3)). Identify which non-representable matroids are minimal (excluded minors). Verify the list matches {U(2,5), U(3,5), F₇, F₇*}.

**Impact**: If confirmed computationally up to n=8, this provides strong evidence for the conjecture and could guide theoretical proofs. If a new excluded minor is found, it would be a significant contribution to matroid theory.

**Catalog References**: `Novelty/Basic.lean` (ggw_implies_finite_excluded_minors)

**Proof Strategy**: For each candidate matroid M:
1. Check representability: does there exist a 3×n matrix A over GF(3) whose column matroid is M?
2. If not representable, check minimality: is every proper minor representable?
3. Use the rank filtration to organize the search by rank level, reducing the search space.
The key computational challenge is that the number of matroids grows super-exponentially. Focus on rank 3 (by duality, rank n-3 is equivalent).

**Domain Bridges**: Matroid Theory <-> Finite Fields <-> Computational Algebra

**Lineage**: Builds on the RFMI excluded minor theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Antichain Width Bounds via Ramsey Theory

**Conjecture**: The width of the rank-k filtration of the RFMI of all matroids on n elements grows at most polynomially in n for fixed k. Specifically, w(k, n) ≤ n^{O(k²)} where w(k, n) is the maximum antichain size among rank-≤-k matroids on n elements.

**Test**: Compute w(k, n) for k ∈ {1, 2} and n ∈ {3, 4, 5, 6} by exhaustive enumeration of matroids and antichain detection. Fit the growth rate and check if it matches polynomial bounds.

**Impact**: Polynomial width bounds would provide a concrete quantitative refinement of the Robertson-Seymour conjecture, with potential algorithmic applications (polynomial-time minor testing for bounded-rank matroids). Exponential growth would indicate that the rank filtration alone is insufficient.

**Catalog References**: `Shared/MatroidRankFiltration.lean` (width_bounded_by_ground_set, width_mono)

**Proof Strategy**: For k=1 (rank-1 matroids = partition matroids), the antichain structure is governed by the Dilworth theorem applied to set containment. For k=2, use the theory of graphic matroids (every rank-2 matroid is graphic) to reduce to graph minor antichains, where Robertson-Seymour theory provides explicit bounds. For general k, explore connections to Ramsey theory: large antichains should contain structured sub-antichains that can be related to Ramsey numbers.

**Domain Bridges**: Matroid Theory <-> Ramsey Theory <-> Extremal Combinatorics

**Lineage**: Directly extends the width analysis theorems from MatroidRankFiltration.lean.

**Ambition**: extension

---

### Direction 5: Matroid Connectivity and the Splitter Theorem

**Conjecture**: For 3-connected matroids in an RFMI, the excluded minors are themselves 3-connected. Formally: if an RFMI is closed under 3-connected minors, and M is an excluded minor, then M is 3-connected.

**Test**: Define 3-connectivity for rank matroids (no partition E = A ∪ B with r(A) + r(B) - r(E) ≤ 1 and |A|, |B| ≥ 2). Prove or disprove the conjecture for matroids on ground sets of size ≤ 6 by enumeration.

**Impact**: The Splitter Theorem (Seymour 1980) states that in the class of 3-connected matroids, every minor-closed class has 3-connected excluded minors. Formalizing this would be a significant step toward the full matroid structure theory needed for Robertson-Seymour.

**Catalog References**: `Shared/MatroidMinor.lean` (minor relation), `Shared/MatroidWQO.lean` (excluded minors)

**Proof Strategy**: Define connectivity function λ(A) = r(A) + r(E\A) - r(E). A matroid is 3-connected if λ(A) ≥ 2 for all non-trivial partitions. Use Seymour's splitter theorem proof strategy: if an excluded minor M is not 3-connected, find a 2-separation and show that a proper minor of M is also not in the class, contradicting minimality.

**Domain Bridges**: Matroid Theory <-> Graph Connectivity <-> Structural Decomposition

**Lineage**: Extends the excluded minor theory from MatroidWQO.lean.

**Ambition**: extension
