# Future Directions: Matroid Minor Theory and Obstruction Spectra

## Synthesis

This research cycle established a rigorous framework for studying matroid minor theory through the lens of *obstruction spectra* — rank-graded distributions of excluded minors for minor-closed matroid classes. The key insight is that the Robertson-Seymour theorem and its conjectured generalization to representable matroids can be studied quantitatively through spectral analysis, rather than only as a qualitative WQO question.

Three cross-domain connections emerged as particularly promising: (1) the palindromy of obstruction spectra under matroid duality connects to the rich existing theory of self-dual codes in coding theory and algebraic geometry; (2) the growth-bounded obstruction system links the Growth Rate Theorem (a structural result about matroid density) to the complexity of excluded minor characterizations; and (3) the minor-closed lattice structure connects to the lattice of varieties in universal algebra, suggesting potential category-theoretic unifications.

The direction with highest breakthrough potential is Direction 1 (Spectral Rigidity), because a proof that the obstruction spectrum uniquely determines a minor-closed class (up to some equivalence) would transform the GGW conjecture from a finiteness question into a classification problem with computable invariants. The width-total relationship (proved: width ≤ total) is the first step, but much sharper bounds should hold for structured classes.

---

### Direction 1: Spectral Rigidity for Representable Matroid Classes

**Conjecture**: For GF(q)-representable matroids with q prime, two distinct minor-closed classes with the same obstruction spectrum must differ at rank ≤ 2q. More precisely: if two minor-closed classes C₁, C₂ of GF(q)-representable matroids have identical obstruction spectra and agree on all matroids of rank ≤ 2q, then C₁ = C₂.

**Test**: Enumerate all minor-closed classes of binary matroids (GF(2)) with total obstruction count ≤ 5. For each pair with the same spectrum, check whether they agree on matroids of rank ≤ 4. If any counterexample is found among binary matroids, the conjecture fails at the simplest case.

**Impact**: If true, this would mean the obstruction spectrum plus low-rank data completely determines a minor-closed class. This would provide a "fingerprint" for minor-closed classes that could be computed incrementally (checking low ranks first), making the GGW conjecture computationally approachable.

**Catalog References**: `Novelty/MatroidMinors/Basic.lean` (ObstructionSpectrum, exists_of_wqo), `Novelty/MatroidMinors/Duality.lean` (SpectralDualityPair)

**Proof Strategy**: First establish that the spectrum determines the multiset of ranks of excluded minors. Then use properties of GF(q)-representable matroids (the Dowling geometry bound, the Growth Rate Theorem) to show that for fixed rank r, the number of simple GF(q)-representable matroids of rank r with n elements is polynomially bounded. Combined with the spectral constraint, this limits the possibilities for excluded minors at each rank.

**Domain Bridges**: Matroid Theory <-> Coding Theory (self-dual codes as self-dual matroids) <-> Algebraic Geometry (representable matroids as point configurations)

**Lineage**: Builds on ObstructionSpectrum and exists_of_wqo from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Palindromic Spectral Structure and Self-Dual Matroid Classes

**Conjecture**: For every self-dual minor-closed class of matroids representable over GF(q) with q odd, the obstruction spectrum satisfies a *strict* palindromic inequality: spectrum(r) ≥ spectrum(r+1) for r < maxGroundRank/2. That is, obstructions are concentrated at low and high ranks, with a monotone decrease toward the center.

**Test**: Compute the obstruction spectrum for the self-dual minor-closed classes of GF(3)-representable matroids (whose excluded minors include U₂,₅, U₃,₅, F₇, F₇*). Verify: spectrum(2) = 1 ≥ spectrum(3) = 2? If spectrum(3) > spectrum(2), the strict inequality fails, but a weaker "near-palindromic" version might hold after accounting for the duality pairing.

**Impact**: If true, this constrains the search for unknown excluded minors: for self-dual classes, most excluded minors live at extreme ranks. If false, the failure mode would reveal which self-dual classes violate the monotonicity and why — likely connected to the existence of self-dual excluded minors (matroids isomorphic to their own duals).

**Catalog References**: `Novelty/MatroidMinors/Duality.lean` (self_dual_palindromic, palindromic_center)

**Proof Strategy**: Use the palindromic theorem (self_dual_palindromic) as a starting point. For the monotonicity, analyze the possible structure of excluded minors at ranks near maxGroundRank/2. Key lemma needed: for GF(q)-representable matroids, the number of matroids of rank r with ≤ n elements is bounded by a function of q, r, and n that grows faster in r, implying more "room" for excluded minors at extreme ranks.

**Domain Bridges**: Matroid Theory <-> Algebraic Coding Theory (palindromic weight enumerators of self-dual codes)

**Lineage**: Builds directly on SpectralDualityPair.self_dual_palindromic from this cycle.

**Ambition**: extension

---

### Direction 3: Lattice Structure of Minor-Closed Classes and Möbius Functions

**Conjecture**: The lattice of minor-closed classes of GF(q)-representable matroids (ordered by inclusion) has a well-defined Möbius function μ, and for any two classes C₁ ⊂ C₂, the Möbius value μ(C₁, C₂) equals (-1)^k times a product of combinatorial invariants, where k = |ExcludedMinors(C₂) \ ExcludedMinors(C₁)|.

**Test**: Compute the lattice of minor-closed classes of binary matroids with ≤ 3 excluded minors. Compute the Möbius function on this finite lattice and check whether it factors as predicted. The lattice should include: class of all matroids (0 excluded minors), class excluding U₂,₄ (1), class excluding U₂,₄ and some specific matroid (2), etc.

**Impact**: A closed-form Möbius function would connect matroid minor theory to enumerative combinatorics via the Möbius inversion formula. This could yield counting formulas for matroids in a class using inclusion-exclusion over excluded minors.

**Catalog References**: `Novelty/MatroidMinors/Duality.lean` (MinorClosedLattice, meet_excluded_minors, top_no_excluded_minors, bot_excluded_minors_characterization)

**Proof Strategy**: Start with the meet decomposition theorem (meet_excluded_minors) to understand how excluded minor sets combine under lattice operations. Then compute the Möbius function on small examples using the recursive definition. Look for a pattern in terms of the "overlap" between excluded minor sets.

**Domain Bridges**: Matroid Theory <-> Order Theory (Möbius functions) <-> Enumerative Combinatorics (inclusion-exclusion)

**Lineage**: Builds on MinorClosedLattice from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Matroid Minors and Valuated WQO

**Conjecture**: Tropical matroids (matroids defined over the tropical semiring) with bounded coefficients are well-quasi-ordered under a suitably defined "tropical minor" relation. This would extend the Robertson-Seymour theory from classical fields to the tropical semiring, connecting to the existing tropical optimization work in the Catalog.

**Test**: Define a tropical matroid as a valuated matroid (a matroid with a valuation on its bases). Define tropical deletion and contraction. Construct the first 10 tropical matroids in a natural enumeration and verify that no two form an antichain under tropical minors. A single antichain pair would disprove the conjecture.

**Impact**: If true, this would extend the GGW conjecture to a fundamentally new algebraic setting (the tropical semiring), bridging combinatorial optimization and structural matroid theory. The forbidden minor characterization would yield finite certificates for tropical matroid properties relevant to optimization.

**Catalog References**: `Tropical/GL3FiniteTestFamily.lean`, `Novelty/MatroidMinors/Basic.lean` (MatroidMinorSystem, WQO)

**Proof Strategy**: First formalize tropical matroids as valuated matroids in Lean 4. Define tropical deletion (restrict the valuation) and tropical contraction (quotient the valuation). Prove that the tropical minor relation is reflexive and transitive. Then attempt to show WQO by adapting the Nash-Williams tree theorem argument used in the Robertson-Seymour proof.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry <-> Combinatorial Optimization

**Lineage**: Combines MatroidMinorSystem from this cycle with existing Tropical catalog entries.

**Ambition**: grand_challenge

---

### Direction 5: Effective Bounds on Excluded Minor Size

**Conjecture**: For GF(q)-representable matroids, every excluded minor for a minor-closed class with growth rate at most f(r) has at most g(f, q) · r elements, where g is a computable function. Specifically, for quadratic growth (f(r) = O(r²)), excluded minors have at most Cq · r² elements for a constant Cq depending only on q.

**Test**: For binary matroids (q=2), verify that every known excluded minor for representability (just U₂,₄ with 4 elements, rank 2) satisfies |E| ≤ C₂ · r² = C₂ · 4 for some reasonable C₂. For ternary matroids, check the 4 known excluded minors. Find the smallest C₃ that works.

**Impact**: Effective size bounds would make the search for excluded minors computationally feasible: instead of searching all matroids, one only needs to search matroids of bounded size at each rank. Combined with spectral analysis, this could yield a practical algorithm for discovering excluded minors.

**Catalog References**: `Novelty/MatroidMinors/Basic.lean` (GrowthBoundedObstructionSystem, obstruction_size_bound)

**Proof Strategy**: Use the growth rate bound to limit the number of elements in a matroid of given rank. Then use the minor-minimality of excluded minors: every element and every pair of elements is "essential" (deletion or contraction reduces the obstruction). This essentiality constrains the structure tightly.

**Domain Bridges**: Matroid Theory <-> Computational Complexity (decidability of minor testing) <-> Finite Geometry (counting points in projective spaces)

**Lineage**: Builds on GrowthBoundedObstructionSystem from this cycle.

**Ambition**: extension
