# Future Directions: Matroid Minor Theory and Well-Quasi-Ordering

## Synthesis

This research cycle established a complete formal framework for the interaction between well-quasi-ordering (WQO) and minor-closed properties in abstract minor systems. The key discovery is that the "excluded minors are antichains" principle, combined with the WQO finite antichain theorem, yields the forbidden minor characterization theorem as a clean algebraic consequence. This abstracts the structural core of the Robertson-Seymour theorem into a setting that applies equally to graphs, matroids, and any combinatorial structure with a well-behaved minor relation.

The most promising cross-domain connection is between the obstruction spectrum (our novel invariant) and coding theory / information theory. The spectrum σ_P(k) counts excluded minors at each size level, and its shape encodes the "complexity" of a minor-closed property. For matroid representability over finite fields, the spectrum has a characteristic shape that might be predictable from field-theoretic invariants — connecting combinatorics to algebra in a new way.

The highest breakthrough potential lies in Direction 1 (Higman's lemma formalization), which would unlock WQO results for sequences and thereby connect to the full power of the Robertson-Seymour proof strategy. Dickson's lemma (proved in this cycle) handles products; Higman handles sequences. Together, they form the combinatorial backbone of all WQO arguments.

---

### Direction 1: Formal Higman's Lemma and WQO on Sequences

**Conjecture**: For any WQO (Σ, ≤), the set of finite sequences Σ* is WQO under the subsequence embedding relation: (a₁,...,aₘ) ≤ (b₁,...,bₙ) iff there exist indices i₁ < ... < iₘ such that aⱼ ≤ bᵢⱼ for all j.

**Test**: Formalize Higman's lemma in Lean 4 and verify it for the concrete case Σ = {0, 1} with the trivial ordering. Then test computationally: generate random sequences of length up to 20 over {0,1,2} and verify that no antichain exceeds a predicted size bound.

**Impact**: Higman's lemma is the key ingredient for extending WQO from products (Dickson) to sequences. Combined with our forbidden minor characterization, it would enable WQO arguments for labeled structures (e.g., edge-labeled graphs, colored matroids). This is a prerequisite for formalizing the full Robertson-Seymour proof.

**Catalog References**: `Shared/MatroidMinorWQO.lean` (WQO structure, `wqo_prod`, `natWQO`)

**Proof Strategy**: Use Nash-Williams's minimal bad sequence argument. Define a "bad sequence" as one with no comparable pair. Assume Higman's lemma fails, so there exists a minimal bad sequence (minimal in a lexicographic sense). Show that the first element can be replaced by a shorter sequence, contradicting minimality. The key lemma is that the set of sequences starting with a fixed symbol is WQO by induction on the alphabet size.

**Domain Bridges**: WQO Theory <-> Formal Language Theory (subsequence closure is a regular language — Haines 1969)

**Lineage**: Builds on `wqo_prod` (Dickson's lemma) and `wqo_antichain_finite` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Obstruction Spectrum Classification for Small Matroids

**Conjecture**: For the class of matroids representable over GF(5), the obstruction spectrum satisfies σ(k) = 0 for k ≥ 15. That is, all excluded minors for GF(5)-representability have ground set size at most 14.

**Test**: Enumerate all simple matroids of rank ≤ 3 on ground sets of size ≤ 12. For each, test GF(5)-representability by checking if a representation matrix exists (via Gaussian elimination over GF(5)). Count excluded minors at each size level. If any excluded minor has size > 14, the conjecture is refuted.

**Impact**: The obstruction spectrum is a new invariant introduced in this cycle. Understanding its shape for specific fields would provide concrete evidence for or against the GGW conjecture, and could reveal patterns connecting field size to obstruction depth. A bound on the maximum excluded minor size would be a significant new result.

**Catalog References**: `Shared/MatroidMinorWQO.lean` (`obstructionSpectrum`, `obstruction_spectrum_finite_support`)

**Proof Strategy**: Start with known excluded minors for GF(5) (there are infinitely many if GGW fails, finitely many if it holds). Computationally enumerate candidates using the Sage matroid library. For the formal side, define GF(5)-representability via rank functions matching matrix ranks, and prove basic properties.

**Domain Bridges**: Matroid Theory <-> Finite Geometry (excluded minors correspond to non-embeddable configurations in PG(r-1, 5))

**Lineage**: Builds on `obstruction_spectrum_finite_support` and `excluded_minor_monotonicity` from this cycle.

**Ambition**: extension

---

### Direction 3: WQO Transfer Theorems for Matroid Duality

**Conjecture**: If a class C of matroids is WQO by the minor relation, then the class C* = {M* : M ∈ C} of dual matroids is also WQO. Moreover, the obstruction spectra of C and C* are related by a duality involution.

**Test**: Formalize matroid duality (rk*(A) = |A| - rk(E) + rk(E\A)) and prove that (M\e)* = M*/e and (M/e)* = M*\e (duality interchanges deletion and contraction). Then attempt to transfer the WQO property through the duality bijection.

**Impact**: If WQO is preserved under duality, it would halve the work needed to verify the GGW conjecture: proving it for a field automatically gives it for the dual class. Since duality swaps deletion and contraction, this would also constrain the structure of excluded minors (excluded minors of C* are duals of excluded minors of C).

**Catalog References**: `Shared/MatroidMinorWQO.lean` (MinorSystem, WQO)

**Proof Strategy**: The key step is showing that duality is an order-isomorphism on the minor partial order (reversing the roles of deletion and contraction). If C → C* is an order-isomorphism, WQO transfers immediately. The proof requires formalizing that minor operations commute with duality.

**Domain Bridges**: Matroid Theory <-> Projective Geometry (duality of matroids extends point-hyperplane duality in projective spaces)

**Lineage**: Builds on `FiniteMatroid` and `MinorSystem` definitions from this cycle. Extends the matroid rank function axioms.

**Ambition**: extension

---

### Direction 4: Kruskal's Tree Theorem as WQO on Labeled Trees

**Conjecture**: Kruskal's tree theorem (finite labeled trees are WQO under homeomorphic embedding) can be derived from our WQO framework combined with Higman's lemma and a structural induction on tree depth.

**Test**: Formalize labeled trees as a type, define the homeomorphic embedding relation, construct a MinorSystem instance, and prove the WQO property. Test with concrete tree families: caterpillar trees, binary trees, path graphs.

**Impact**: Kruskal's theorem is historically the first WQO result for tree-like structures and was the inspiration for Robertson-Seymour. Formalizing it within our framework would validate that our abstract MinorSystem captures the right level of generality. It would also provide the foundation for the graph minor theorem, since Robertson-Seymour's proof uses tree decompositions.

**Catalog References**: `Shared/MatroidMinorWQO.lean` (WQO, MinorSystem, `wqo_antichain_finite`)

**Proof Strategy**: Follow Nash-Williams's elegant proof using minimal bad sequences. Define trees inductively, define embedding recursively, and use well-founded induction on tree size. The key lemma is Higman's lemma applied to the sequence of children at each node.

**Domain Bridges**: WQO Theory <-> Proof Theory (Kruskal's theorem is independent of Peano arithmetic — connection to ordinal analysis and Γ₀)

**Lineage**: Builds on `wqo_prod` (Dickson) and would use Direction 1 (Higman) as a prerequisite.

**Ambition**: grand_challenge

---

### Direction 5: Computational Bounds on Excluded Minor Sets

**Conjecture**: For graphic matroids (= cycle matroids of graphs), the number of excluded minors for the property "is a minor of the Petersen graph" is exactly 3.

**Test**: Enumerate all graphs on ≤ 10 vertices that are not minors of the Petersen graph but all whose proper minors are. Use the Sage graph library or a custom enumeration. Verify computationally, then formalize the finite characterization.

**Impact**: This is a concrete, testable instance of the forbidden minor characterization theorem. The Petersen graph is a fundamental object in graph theory (it appears as an excluded minor for many properties). Understanding its "upward closure" in the minor order would provide concrete data points for the obstruction spectrum theory.

**Catalog References**: `Shared/MatroidMinorWQO.lean` (`forbidden_minor_characterization`, `excluded_minors_antichain`)

**Proof Strategy**: Use the forbidden_minor_characterization theorem applied to the property P(G) = "G is a minor of the Petersen graph". Since this property is minor-closed (if G ≤ H and H ≤ Petersen, then G ≤ Petersen), the theorem guarantees finitely many excluded minors. The computational challenge is exhaustive enumeration.

**Domain Bridges**: Graph Theory <-> Algorithm Design (forbidden minor characterizations yield polynomial-time recognition algorithms)

**Lineage**: Direct application of `forbidden_minor_characterization` from this cycle.

**Ambition**: extension
