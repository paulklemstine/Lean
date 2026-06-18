# Future Directions: Matroid Minors and the Robertson-Seymour Program

## Synthesis

This research cycle established the formal foundations of the forbidden minor framework for matroid theory, proving the key implication chain: WQO → finite antichains → finite forbidden minor characterizations. The central insight is that the entire content of deep results like the Robertson-Seymour theorem is concentrated in establishing the WQO hypothesis — once WQO is known, the forbidden minor finiteness follows by a clean abstract argument (contradiction via injection from an infinite antichain).

Three cross-domain connections emerged as particularly promising. First, the interplay between matroid duality and the minor order (Theorem: dual of a minor is a minor of the dual) suggests a deeper categorical structure — matroid duality is a contravariant functor that preserves the minor preorder. This connects to the Catalog's work on algebraic structures and could be extended to tropical matroid duality. Second, the representability framework bridges discrete combinatorics with linear algebra, and extending it to contraction (not just deletion) requires formalizing the quotient-space interpretation of matroid contraction. Third, the WQO property itself connects to order theory (Higman's lemma, Kruskal's tree theorem) and could be studied in a unified framework with the Catalog's work on well-founded relations.

The highest breakthrough potential lies in Direction 1: formalizing the WQO property for specific matroid classes (uniform matroids, graphic matroids), which would give the first fully formalized instances of the Robertson-Seymour theorem. Direction 3 (tropical matroid minors) offers the most novel cross-domain bridge.

---

### Direction 1: WQO for Uniform and Graphic Matroids

**Conjecture**: The class of uniform matroids is well-quasi-ordered by the minor relation. Specifically, for any infinite sequence U(k_1, n_1), U(k_2, n_2), ..., there exist i < j such that U(k_i, n_i) ≤_m U(k_j, n_j).

**Test**: Prove that U(k, n) ≤_m U(k', n') if and only if k ≤ k' and n - k ≤ n' - k'. Then the WQO property follows from Dickson's lemma (the product of two copies of ℕ with the componentwise ordering is WQO). Verify computationally for all sequences of length 20 with parameters bounded by 10.

**Impact**: This would give the first formally verified instance of WQO for a natural matroid class. It would also validate the abstract framework (Theorem `wqo_forbidden_minor_finite`) on a concrete class, producing explicit forbidden minor bounds.

**Catalog References**: `MatroidMinors/Basic.lean` (this cycle), `Mathlib.Order.WellQuasiOrder` (Dickson's lemma may be available)

**Proof Strategy**: 
1. Define uniform matroids formally using Mathlib's matroid infrastructure.
2. Prove the characterization: U(k,n) ≤_m U(k',n') ↔ k ≤ k' ∧ n-k ≤ n'-k'. The forward direction: deletion reduces n by 1 (keeping k), contraction reduces both n and k by 1. The backward direction: by induction, using sequences of deletions and contractions.
3. Apply Dickson's lemma (WQO of ℕ × ℕ) to conclude WQO of uniform matroids.

**Domain Bridges**: Order Theory (Dickson's lemma) ↔ Matroid Theory (uniform matroid WQO) ↔ Combinatorics (forbidden minor enumeration)

**Lineage**: Builds on `wqo_forbidden_minor_finite` and `uniform_rank_mono` from this cycle.

**Ambition**: extension

---

### Direction 2: Contraction Preserves Representability

**Conjecture**: If a matroid M is F-representable (over a field F), then M / C is F-representable for any C ⊆ E. Combined with the deletion result (proved this cycle), this would establish that representability is fully minor-closed.

**Test**: Formalize the proof that if repr : E → F^n represents M and B_C is a basis for C in M, then the quotient representation (projecting to the orthogonal complement of span(repr(B_C))) represents M / C. Verify computationally for all rank-3 matroids on ≤ 7 elements over GF(2) and GF(3).

**Impact**: Completing the proof that representability is minor-closed would allow applying the full forbidden minor framework to representable matroids, giving a formal path to Rota's conjecture.

**Catalog References**: `MatroidMinors/Basic.lean` (`representable_delete`, `IsRepresentable`), `Mathlib.LinearAlgebra.Quotient`

**Proof Strategy**:
1. Given repr : E → F^n for M and a basis B_C of C in M, define the contracted representation as the projection of repr onto the orthogonal complement of span{repr(b) : b ∈ B_C}.
2. Show that I ⊆ E \ C is independent in M / C iff I ∪ B_C is independent in M iff {repr(e) : e ∈ I ∪ B_C} is linearly independent iff the projected vectors {π(repr(e)) : e ∈ I} are linearly independent.
3. This requires formalizing the relationship between linear independence and orthogonal projection, using Mathlib's `Submodule.Quotient` or `LinearMap.ker`.

**Domain Bridges**: Linear Algebra (quotient spaces, projections) ↔ Matroid Theory (contraction) ↔ Representation Theory

**Lineage**: Builds on `representable_delete` and `not_representable_of_minor_not_representable` from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Matroid Minors and Valuated Matroids

**Conjecture**: There exists a well-defined notion of "minor" for valuated matroids (matroids equipped with a valuation function on bases, arising in tropical geometry) that extends the ordinary matroid minor relation, and the class of valuated matroids of fixed rank over a fixed tropical semifield is WQO.

**Test**: Define valuated matroid minors formally. Construct the tropical analogue of U(2,4) and verify that its valuated minor structure matches the expected tropical Grassmannian combinatorics. Test WQO on random sequences of valuated matroids of rank 2 on ground sets of size ≤ 6.

**Impact**: This would bridge matroid minor theory with tropical geometry, a rapidly growing field. Valuated matroids encode the combinatorics of linear spaces over valued fields (e.g., p-adic numbers), and a WQO result would have implications for the structure of tropical varieties.

**Catalog References**: `Tropical/` (tropical arithmetic from Catalog), `MatroidMinors/Basic.lean` (minor framework), `Bridges/AlgebraTropicalGeometry/` (tropical persistence)

**Proof Strategy**:
1. Define valuated matroids: a matroid M together with a function v : Bases(M) → ℝ ∪ {-∞} satisfying the tropical Plücker relations.
2. Define valuated deletion and contraction, extending the ordinary matroid operations.
3. Show that the "forget the valuation" functor preserves minors.
4. For the WQO conjecture: attempt to reduce to Higman's lemma or Kruskal's theorem by encoding the valuation as a labeled tree.

**Domain Bridges**: Tropical Geometry (valuated matroids, tropical Grassmannians) ↔ Matroid Theory (minor order) ↔ Order Theory (WQO, Kruskal's theorem)

**Lineage**: Builds on the minor framework from this cycle and connects to `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Categorical Structure of the Minor Order

**Conjecture**: The category of matroids with minor-preserving maps (strong maps) has a well-defined Grothendieck group, and the class of this group encodes the excluded minor obstructions for representability. Specifically, the K-theory of the matroid minor category detects the difference between representable and non-representable matroids.

**Test**: Define the category of matroids with strong maps formally. Compute the Grothendieck group for matroids on ground sets of size ≤ 5. Check whether the class [U(2,4)] (the excluded minor for GF(2)) generates a nontrivial element that distinguishes binary from non-binary matroids.

**Impact**: A K-theoretic framework for matroid minor theory would connect combinatorics with algebraic topology and algebraic K-theory, potentially revealing new invariants that detect representability.

**Catalog References**: `MatroidMinors/Structural.lean` (forbidden minor framework), `Algebra/` (algebraic structures from Catalog)

**Proof Strategy**:
1. Define strong maps between matroids (maps preserving rank and ground set inclusion).
2. Formalize the category of matroids with strong maps.
3. Construct the Grothendieck group using Mathlib's categorical infrastructure.
4. Compute explicit K-groups for small examples.

**Domain Bridges**: Category Theory (Grothendieck groups, K-theory) ↔ Matroid Theory (minor order, representability) ↔ Algebraic Topology (classifying spaces)

**Lineage**: Builds on `dual_isMinor_dual` and the antichain results from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Effective Bounds for Excluded Minor Sets

**Conjecture**: For the class of matroids representable over GF(q), the number of excluded minors for any minor-closed subproperty P is bounded by a computable function of q and the "complexity" of P (measured, e.g., by the maximum rank of an excluded minor).

**Test**: For GF(2), enumerate all minor-closed properties of binary matroids on ≤ 8 elements and count their excluded minors. Plot the distribution of excluded minor counts as a function of the property's "rank threshold." Check whether an exponential or polynomial bound fits the data.

**Impact**: The current proofs of forbidden minor finiteness are non-constructive — they guarantee existence of a finite bound but provide no explicit value. Effective bounds would transform the theory from existential to algorithmic.

**Catalog References**: `MatroidMinors/Basic.lean` (`wqo_forbidden_minor_finite`), `Computation/` (algorithmic frameworks from Catalog)

**Proof Strategy**:
1. For uniform matroids (Direction 1), derive explicit bounds using Dickson's lemma quantitatively.
2. For graphic matroids, use the Robertson-Seymour structure theorem to bound excluded minor sizes.
3. For general F_q-representable matroids, use the Geelen-Gerards-Whittle structure theorem (growth rates, templates) to derive bounds in terms of q.

**Domain Bridges**: Computability Theory (effective bounds, algorithms) ↔ Matroid Theory (forbidden minors) ↔ Combinatorics (enumeration, growth rates)

**Lineage**: Builds on `wqo_forbidden_minor_finite` and the representability framework from this cycle.

**Ambition**: extension
