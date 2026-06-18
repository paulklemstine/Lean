# Future Directions: Matroid Minors and Robertson-Seymour Theory

## Synthesis

This cycle established the **Hereditary Minor System (HMS)** framework, a novel abstract structure that captures the common algebraic core of graph minor theory and matroid minor theory. Nine theorems were formalized and machine-verified, culminating in the abstract Robertson-Seymour theorem: if the universe of an HMS is well-quasi-ordered (WQO), then every minor-closed property has finitely many proper excluded minors.

The key insight driving future work is the *separation principle*: the HMS framework isolates the "easy" implication (WQO → finite excluded minors) from the "hard" content (proving WQO for specific combinatorial classes). This separation suggests two complementary research directions: (1) extending the abstract framework with richer structure (filtration, grading, categorical operations), and (2) using the framework to study concrete instances like ternary matroids or graph classes with specific structural properties.

The most promising cross-domain connection is between the HMS exclusion spectrum and the tropical geometry structures already in the Catalog (`Tropical/GL3FiniteTestFamily.lean`). Matroid rank functions over finite fields can be tropicalized, and the resulting tropical matroids may provide a bridge between algebraic WQO arguments and the computational tropical optimization techniques developed in prior cycles. The direction with highest breakthrough potential is Direction 1 (Ternary WQO), because establishing WQO for ternary matroids — even for bounded-rank subclasses — would resolve a major open problem and instantly yield finite excluded minor characterizations via our framework.

---

### Direction 1: Well-Quasi-Ordering of Bounded-Rank Ternary Matroids

**Conjecture**: For each fixed rank r, the class of 𝔽₃-representable matroids of rank ≤ r is well-quasi-ordered under the matroid minor relation. Formally: for any infinite sequence M₁, M₂, ... of 𝔽₃-representable matroids with rank ≤ r, there exist i < j such that Mᵢ is a minor of Mⱼ.

**Test**: Implement a computational enumeration of 𝔽₃-representable matroids of rank 3 on ground sets of size ≤ 12. Verify that every antichain in this set has size ≤ some bound B(3). If B(3) is small (say ≤ 50), this provides strong computational evidence for WQO at rank 3.

**Impact**: If true, this gives a constructive proof that the exclusion spectrum for ternary representability is zero beyond rank r for any fixed r. Combined with our HMS framework (Theorem 4.3), this would yield finite excluded minor characterizations for ternary representability restricted to each rank level. If false, a counterexample antichain would reveal the structural obstruction to WQO for ternary matroids and redirect the field.

**Catalog References**: `Novelty/MatroidMinors/Main.lean` (HMS framework, `universe_wqo_implies_finite_proper_excluded_minors`), `Speculative/AutoResearch/MatroidWQO.lean` (prior matroid WQO formalization)

**Proof Strategy**: 
1. Formalize 𝔽₃-representable matroids as equivalence classes of matrices over GF(3) modulo row operations and column permutations.
2. Define the minor relation via deletion (removing columns) and contraction (pivoting and removing).
3. For rank ≤ 2, prove WQO directly by showing the finite number of isomorphism types.
4. For rank 3, use Higman's lemma applied to the column space representation.
5. The key technical challenge is showing that the "forbidden patterns" in column configurations are well-quasi-ordered.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry (tropicalization of rank functions), Matroid Theory <-> Linear Algebra over Finite Fields

**Lineage**: Builds on this cycle's HMS framework and the Geelen-Gerards-Whittle conjecture.

**Ambition**: grand_challenge

---

### Direction 2: Exclusion Spectrum Asymptotics for Surface Embeddability

**Conjecture**: For the minor-closed property "embeddable on the orientable surface of genus g," the exclusion spectrum satisfies exclSpec(Sg, k) = 0 for all k > f(g) where f(g) = O(g²). That is, the excluded minors for genus-g embeddability have bounded complexity.

**Test**: Use the known excluded minor lists for the sphere (genus 0: {K₅, K₃,₃}, max rank 4), torus (genus 1: hundreds of excluded minors), and projective plane. Compute the maximum rank among excluded minors for each surface and fit a growth curve.

**Impact**: A tight bound on the exclusion spectrum would give an algorithm for testing surface embeddability that runs in time polynomial in the graph size for each fixed genus. If the bound is superpolynomial, it would suggest fundamental computational barriers.

**Catalog References**: `Novelty/MatroidMinors/Main.lean` (`exclusionSpectrum`, `exclusion_spectrum_finite`), `Geometry/PrimewisePersistence.lean`

**Proof Strategy**: 
1. Define the HMS of graphs with rank = number of edges.
2. Use the grid minor theorem: graphs of high treewidth contain large grid minors.
3. Show that excluded minors for Sg have treewidth ≤ h(g) for some function h.
4. Use the finiteness of graphs with bounded treewidth and bounded rank to bound the exclusion spectrum.

**Domain Bridges**: Graph Theory <-> Topology (surface embedding), Combinatorics <-> Computational Complexity

**Lineage**: Extends this cycle's exclusion spectrum definition with quantitative bounds.

**Ambition**: extension

---

### Direction 3: Categorical HMS — Functoriality of Excluded Minor Sets

**Conjecture**: If F : H₁ → H₂ is a "minor-preserving functor" between HMS (preserving the minor relation and bounded rank distortion), then the excluded minors for F⁻¹(P) (the pullback of a minor-closed property P in H₂) can be bounded by the excluded minors for P composed with F. Specifically, every excluded minor for F⁻¹(P) maps under F to either an excluded minor for P or an element of P.

**Test**: Instantiate with F = cycle matroid functor (graphs → matroids). For the property "is graphic" in matroids, verify that the excluded minors for "is graphic" (U₂,₄, M(K₅)*, M(K₃,₃)*, M*(K₅), M*(K₃,₃)) map correctly under F⁻¹ to graph-theoretic excluded minors.

**Impact**: A categorical framework for HMS would enable transfer theorems: proving WQO for one class of objects automatically gives WQO for related classes via functorial transport. This could provide a systematic approach to the Geelen-Gerards-Whittle conjecture by reducing matroid WQO to graph WQO via representation functors.

**Catalog References**: `Novelty/MatroidMinors/Main.lean` (HMS, `MinorClosed`, `properExcludedMinors`), `EML/CategoryTheorems.lean`

**Proof Strategy**: 
1. Define morphisms of HMS as rank-bounded, minor-preserving maps.
2. Show that pullback of minor-closed properties along HMS morphisms is minor-closed.
3. Prove the excluded minor transfer theorem using the antichain characterization.
4. Instantiate for the cycle matroid functor and verify known examples.

**Domain Bridges**: Matroid Theory <-> Category Theory, Graph Theory <-> Abstract Algebra

**Lineage**: Extends this cycle's HMS framework with categorical structure.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Matroid WQO via Valuation Theory

**Conjecture**: The class of valuated matroids (matroids with a valuation function, as studied in tropical geometry) over a fixed valuated field is WQO under the valuated matroid minor relation.

**Test**: Enumerate valuated matroids of rank 2 on ≤ 8 elements over the tropical semiring. Check that all antichains have size ≤ 10.

**Impact**: Valuated matroids bridge classical matroid theory and tropical geometry. A WQO result would immediately yield finite excluded minor characterizations for tropical analogues of representability, potentially connecting to the tropical optimization results in the Catalog.

**Catalog References**: `Novelty/MatroidMinors/Main.lean`, `Pythagorean/ValuatedMatroidExchange.lean`, `Tropical/GL3FiniteTestFamily.lean`

**Proof Strategy**: 
1. Define valuated matroid minor operations (tropical deletion and contraction).
2. Verify that the valuated matroid HMS satisfies our axioms.
3. For rank 1 and 2, prove WQO directly.
4. For higher rank, attempt to use Higman's lemma on the value vectors.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry <-> Valuation Theory

**Lineage**: Builds on this cycle's HMS framework and existing Catalog tropical matroid files.

**Ambition**: extension

---

### Direction 5: Computational Excluded Minor Search via HMS Rank Filtration

**Conjecture**: For the minor-closed property "𝔽₃-representable" restricted to matroids of rank ≤ 4, the complete list of excluded minors can be computationally enumerated and verified, and the list contains exactly the known excluded minors (Fano, dual Fano, non-Pappus, and possibly others at rank 4).

**Test**: Write an algorithm that:
1. Enumerates all matroids of rank ≤ 4 on ≤ 10 elements (using the matroid database).
2. Tests 𝔽₃-representability for each by solving a system of polynomial equations over GF(3).
3. Identifies excluded minors by checking that every proper minor is representable.
4. Compares the output to the known list.

**Impact**: A verified computational enumeration would either confirm the known excluded minor list or discover new excluded minors, directly advancing the classification of ternary matroids.

**Catalog References**: `Novelty/MatroidMinors/Main.lean` (`exclusionSpectrum`, `exclusion_spectrum_finite`)

**Proof Strategy**: 
1. Implement matroid representation testing over GF(3) using Gaussian elimination and backtracking.
2. Use the rank filtration: enumerate rank 1, then rank 2, then rank 3, then rank 4.
3. At each rank level, the number of matroids is finite (by HMS axioms), so the search terminates.
4. Parallelize the representability tests using matrix operations over GF(3).

**Domain Bridges**: Combinatorics <-> Computational Algebra, Matroid Theory <-> Finite Geometry

**Lineage**: Extends this cycle's exclusion spectrum with computational instantiation.

**Ambition**: extension
