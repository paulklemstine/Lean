# Future Directions: Matroid Minor Theory

## Synthesis

This research cycle established a formalized framework for matroid minor theory, proving the interaction between duality and the minor relation, the antichain property of forbidden minors, and the implication from well-quasi-ordering to finite forbidden minor characterizations. The key insight is that duality acts as a perfect symmetry on the forbidden minor structure: FM(P✶) = (FM(P))✶. This duality-preserving property of the minor relation, combined with the algebraic structure of minor ideals (closed under intersection, forming a lattice), suggests deep connections between matroid minor theory, order theory, and categorical structures.

The most promising cross-domain connection from this cycle is the bridge between matroid representability and finite field theory. The Robertson-Seymour conjecture for matroids stratifies by the base field: each finite field F_q defines a well-quasi-ordering problem with its own set of excluded minors. This creates a "spectrum" of WQO problems parameterized by prime powers, potentially connecting to questions about the arithmetic of finite fields via the Catalog's existing work on algebraic structures (e.g., `Algebra/RotaBasisConjecture.lean`).

The highest breakthrough potential lies in Direction 1 (Rota's Conjecture and the Excluded Minor Spectrum), which connects our formalized framework to one of the most celebrated open problems in combinatorics. A proof strategy based on the Geelen-Gerards-Whittle structural theory, formalized using our `MatroidWQO` framework, could yield the first machine-verified progress toward the matroid RS conjecture.

---

### Direction 1: Rota's Conjecture and the Excluded Minor Spectrum

**Conjecture**: For each prime power q, the number of excluded minors for GF(q)-representability is finite. Moreover, the number of excluded minors grows at most polynomially in q.

**Test**: For q = 2, verify that the single excluded minor for GF(2)-representability is U(2,4). For q = 3, verify that the excluded minors include U(2,5), U(3,5), F₇, and F₇*. Computationally enumerate matroids on ≤ 9 elements and check GF(q)-representability for q = 2, 3, 4.

**Impact**: Rota's conjecture (now a theorem for q ≤ 4 due to Geelen-Gerards-Whittle) is one of the central problems in matroid theory. A formalized proof, even for q = 2, would be a significant achievement. The polynomial growth bound, if true, would constrain the structure of representable matroids in a quantitative way.

**Catalog References**: `Algebra/MatroidMinors/Theorems.lean` (rs_implies_finite_obstructions), `Algebra/MatroidMinors/DualMinor.lean` (forbiddenMinors_dual_eq), `Algebra/RotaBasisConjecture.lean`

**Proof Strategy**: For q = 2, the excluded minor U(2,4) can be constructed explicitly and shown to be the unique excluded minor by case analysis. The key lemma is that every non-GF(2)-representable matroid of minimum size is isomorphic to U(2,4). For q = 3, use the classification of excluded minors (U(2,5), U(3,5), F₇, F₇*) and verify each. The polynomial growth bound would require new structural results about matroid representability.

**Domain Bridges**: Matroid theory <-> finite field arithmetic <-> coding theory (linear codes are representable matroids)

**Lineage**: Builds on the ExcludedMinorSystem and MatroidWQO structures from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Matroid Connectivity and the Splitter Theorem

**Conjecture**: Every 3-connected matroid M with a 3-connected minor N (where |E(M)| > |E(N)|) has an element e such that either M \ e or M / e is 3-connected with N as a minor. This is Seymour's Splitter Theorem.

**Test**: Formalize 3-connectivity for matroids (using the connectivity function λ(A, B) = r(A) + r(B) - r(E)). Verify the splitter theorem for small matroids (|E| ≤ 8) by exhaustive enumeration.

**Impact**: The splitter theorem is the key structural result that enables inductive proofs in matroid minor theory. Formalizing it would open the door to formalizing the Geelen-Gerards-Whittle structure theory, which is the main approach to the matroid RS conjecture.

**Catalog References**: `Algebra/MatroidMinors/Defs.lean` (MinorIdeal, ProperMinor), `Algebra/MatroidMinors/Theorems.lean` (forbidden_minor_characterization_wf)

**Proof Strategy**: Define the connectivity function κ_M(X) = r(X) + r(E \ X) - r(E) for subsets X of the ground set. A matroid is k-connected if κ_M(X) ≥ k for all non-trivial partitions. The splitter theorem proceeds by considering elements e where M \ e or M / e maintains connectivity, using the round structure of the matroid. Key lemma: if no single-element deletion or contraction preserves 3-connectivity and the minor, then M itself has a specific structure (a fan or a spike).

**Domain Bridges**: Matroid connectivity <-> graph connectivity <-> algebraic geometry (moduli of arrangements)

**Lineage**: Extends the minor-closed property framework from this cycle to incorporate connectivity constraints.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Matroid Minors and Valuated Matroids

**Conjecture**: The minor relation on valuated matroids (matroids with a valuation function compatible with the tropical semiring) satisfies a weak form of the RS property when restricted to realizable valuated matroids.

**Test**: Define valuated matroids as matroids with a function v : bases → ℝ satisfying the tropical Plücker relations. Construct examples of valuated matroid minors and verify that deletion/contraction preserve the tropical structure. Check whether the known infinite antichains of matroids (e.g., the Vámos-like matroids) lift to valuated antichains.

**Impact**: Tropical geometry has emerged as a powerful tool in algebraic geometry and combinatorics. Connecting the RS conjecture to tropical structures could provide new proof techniques via the combinatorics of polyhedral complexes and tropical varieties.

**Catalog References**: `Tropical/` (existing tropical theory in the Catalog), `Algebra/MatroidMinors/Defs.lean` (HasRSProperty, MatroidWQO)

**Proof Strategy**: Define a `ValuatedMatroid` structure extending `Matroid` with a valuation on bases. Show that minor operations on valuated matroids correspond to tropical operations (min-plus algebra). The key insight is that the tropical Grassmannian parametrizes valuated matroids, and the minor relation corresponds to projections in this space. Use the finite-dimensionality of tropical Grassmannians to argue for WQO-like properties.

**Domain Bridges**: Matroid theory <-> tropical geometry <-> polyhedral combinatorics <-> algebraic geometry

**Lineage**: Builds on the MatroidWQO structure and extends it to the tropical setting.

**Ambition**: extension

---

### Direction 4: Algorithmic Consequences of Matroid WQO

**Conjecture**: If the RS conjecture holds for GF(q)-representable matroids, then for every minor-closed property P of GF(q)-representable matroids, there exists a polynomial-time algorithm deciding P (assuming the excluded minors are known).

**Test**: Implement the forbidden minor testing algorithm for graphic matroids (where the excluded minors are known) and verify polynomial-time behavior. For GF(2)-representable matroids, implement the U(2,4)-minor test.

**Impact**: The Robertson-Seymour theorem for graphs implies that every minor-closed graph property is decidable in O(n³) time (though the constants are non-constructive). Extending this to matroids would have applications in optimization (matroid intersection), coding theory (linear code classification), and constraint satisfaction.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity framework), `Algebra/MatroidMinors/Theorems.lean` (rs_implies_finite_obstructions)

**Proof Strategy**: The algorithm proceeds by testing each excluded minor in sequence. For each excluded minor F, testing whether F ≤m M can be done in polynomial time if |E(F)| is bounded (the "minor containment problem" is FPT parameterized by |E(F)|). The key lemma is that the number of excluded minors is finite (our Theorem 5), and each test is polynomial in |E(M)|.

**Domain Bridges**: Matroid theory <-> computational complexity <-> parameterized algorithms <-> coding theory

**Lineage**: Builds on rs_implies_finite_obstructions and connects to the Catalog's computation framework.

**Ambition**: extension

---

### Direction 5: Matroid Minors and the Hodge Theory of Matroids

**Conjecture**: The Hodge-theoretic invariants of a matroid (the coefficients of the reduced characteristic polynomial, which satisfy log-concavity by the work of Adiprasito-Huh-Katz) are monotone under the minor relation in a suitable sense: if N ≤m M, then the "Hodge numbers" of N are bounded by those of M.

**Test**: Compute the reduced characteristic polynomials of uniform matroids U(r,n) for small r, n and their minors. Verify that the coefficients satisfy the conjectured monotonicity. Check the Fano matroid F₇ and its minors.

**Impact**: The Adiprasito-Huh-Katz theorem proving log-concavity of matroid characteristic polynomials was one of the great achievements of recent combinatorics. Connecting this to the minor relation would provide a new "Hodge-theoretic" obstruction to minor containment, potentially giving a new approach to the RS conjecture via algebraic geometry.

**Catalog References**: `Algebra/MatroidMinors/DualMinor.lean` (duality preserves minors), `FINAL/Algebra/RankOne.lean` (Hodge class theory)

**Proof Strategy**: Define the reduced characteristic polynomial χ_M(t) = Σ (-1)^i w_i t^{r-i} where w_i are the Whitney numbers. The Adiprasito-Huh-Katz theorem shows w_0, w_1, ..., w_r is log-concave. For minors, deletion reduces the ground set while contraction reduces the rank. The conjecture is that w_i(N) ≤ w_i(M) when N ≤m M and both have the same rank (after appropriate normalization). This would follow from the Kähler package if the hard Lefschetz theorem for matroids is compatible with minor operations.

**Domain Bridges**: Matroid theory <-> Hodge theory <-> algebraic geometry <-> combinatorial topology

**Lineage**: Builds on the duality-minor interaction and connects to the Catalog's Hodge theory results.

**Ambition**: grand_challenge
