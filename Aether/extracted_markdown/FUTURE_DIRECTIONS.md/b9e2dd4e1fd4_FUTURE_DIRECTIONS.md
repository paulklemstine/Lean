# Future Directions: Matroid Minor Theory and the Robertson-Seymour Program

## Synthesis

This research cycle established the logical backbone of the Robertson-Seymour framework for matroids: forbidden minors form antichains, well-quasi-ordering prevents infinite antichains, and the combination forces every minor-closed property to have finitely many obstructions. These results were formalized in Lean 4 using Mathlib's matroid library, creating a foundation that any future WQO result can immediately plug into.

The most promising cross-domain connection is between matroid theory and coding theory via finite field representability. Linear codes over GF(q) correspond exactly to GF(q)-representable matroids, so the forbidden minor framework translates directly into structural constraints on code families. A bridge between the matroid minor formalization (this cycle) and existing algebraic structures in the Catalog (e.g., `Algebra/Advanced.lean`, `Algebra/Basic.lean`) could yield new results about algebraic structures constrained by forbidden substructure conditions.

The highest breakthrough potential lies in Direction 1 (well-foundedness of the minor order for finite matroids), because it would remove the hypothesis from our forbidden minor characterization theorem, making it unconditional. This is a concrete, achievable target that would significantly strengthen the formalized theory and is a prerequisite for all downstream applications.

---

### Direction 1: Well-Foundedness of the Matroid Minor Order on Finite Ground Sets

**Conjecture**: For matroids on a finite ground set, the proper minor relation (N <_m M iff N ≤_m M and N ≠ M) is well-founded. Equivalently, there is no infinite strictly descending chain of proper minors.

**Test**: Prove in Lean 4 that for matroids with `[Fintype α]`, the proper minor relation is well-founded. The key measure should be `|M.E|` (the cardinality of the ground set), which strictly decreases under proper minors. Verify computationally for all matroids on ground sets of size ≤ 6 that every chain of proper minors has length ≤ |E|.

**Impact**: This would remove the `WellFounded` hypothesis from `forbidden_minor_characterization_wf`, making the forbidden minor characterization unconditional for finite matroids. This is the standard setting for all applications in combinatorics and coding theory.

**Catalog References**: `Algebra/MatroidMinors/Theorems.lean` (theorem `forbidden_minor_characterization_wf`, definition `ProperMinor`)

**Proof Strategy**: Define a measure `μ(M) = M.E.ncard` (the natural number cardinality of the ground set). Show that if N is a proper minor of M (i.e., N = (M/C)\D with N ≠ M), then `μ(N) < μ(M)`. This requires showing that deletion or contraction of a non-empty set strictly reduces the ground set. Use `Set.ncard_lt_ncard` and properties of `Matroid.delete_ground_eq` and `Matroid.contract_ground_eq` from Mathlib.

**Domain Bridges**: Combinatorics <-> Order Theory, Matroid Theory <-> Set Theory

**Lineage**: Builds directly on `forbidden_minor_characterization_wf` from this cycle.

**Ambition**: extension

---

### Direction 2: Formalizing Tutte's Excluded Minor Theorem for Binary Matroids

**Conjecture**: A matroid is binary (representable over GF(2)) if and only if it has no U(2,4) minor. This is Tutte's 1958 theorem, one of the most important results in matroid theory.

**Test**: Formalize the statement in Lean 4 using our `IsRepresentable` definition with `F = ZMod 2`. Then either (a) prove it from first principles using the matroid-theoretic argument (showing that the Fano matroid is the unique obstruction), or (b) prove it for small cases (matroids on ≤ 7 elements) computationally and state the general result as a verified theorem assuming the result.

**Impact**: This would be the first formalized proof of a classical forbidden minor theorem. It would validate our framework on a concrete, well-understood case and provide a template for formalizing excluded minor results for larger fields.

**Catalog References**: `Algebra/MatroidMinors/Theorems.lean` (definitions `IsRepresentable`, `ForbiddenMinors`, theorem `avoids_forbidden_minors`)

**Proof Strategy**: The classical proof has two parts: (1) Show U(2,4) is not binary (it has 4 elements of rank 2, requiring 4 nonzero vectors in GF(2)^2, but there are only 3). (2) Show that any non-binary matroid contains a U(2,4) minor (using the theory of matroid connectivity and Seymour's splitter theorem). Part (1) is computational; part (2) requires substantial matroid theory. Start with part (1) as a concrete lemma, then attempt part (2) or state it as an axiom.

**Domain Bridges**: Matroid Theory <-> Linear Algebra, Combinatorics <-> Finite Geometry

**Lineage**: Builds on `IsRepresentable` and the forbidden minor framework from this cycle. Connects to `Algebra/Dim2.lean` for 2-dimensional linear algebra.

**Ambition**: grand_challenge

---

### Direction 3: Matroid Duality and the Forbidden Minor Theorem for Duals

**Conjecture**: If P is a minor-closed matroid property, then the dual property P* (defined by P*(M) iff P(M*)) is also minor-closed, and the forbidden minors for P* are exactly the duals of the forbidden minors for P: Forb(P*) = {M* : M ∈ Forb(P)}.

**Test**: Formalize matroid duality in Lean 4 (the dual matroid M* has the same ground set with bases being complements of bases of M). Prove that (M*)* = M, that deletion dualizes to contraction ((M\D)* = M*/D and (M/C)* = M*\C), and that the forbidden minor sets transform correctly under duality. Verify computationally for matroids on ≤ 7 elements.

**Impact**: Duality is fundamental to matroid theory and halves the work needed to find forbidden minors. For example, since F_7 is an excluded minor for GF(3)-representability, its dual F_7* must also be one. Formalizing this would demonstrate the power of the abstract framework.

**Catalog References**: `Algebra/MatroidMinors/Theorems.lean` (theorem `forbiddenMinors_antichain`, definition `IsMinorClosed`)

**Proof Strategy**: Mathlib may already have `Matroid.dual`. The key lemmas are: (1) the dual of a minor is a minor of the dual (with deletion and contraction swapped), (2) minor-closedness is preserved under duality. These follow from the identities (M\D)* = M*/D and (M/C)* = M*\C, which are standard results in matroid theory (Oxley, Chapter 2).

**Domain Bridges**: Matroid Theory <-> Projective Geometry, Algebra <-> Combinatorics

**Lineage**: Extends the forbidden minor framework from this cycle. Connects to duality concepts in `Algebra/Oracle.lean` (dual structures).

**Ambition**: extension

---

### Direction 4: Tropical Matroid Minors and Valuated Matroids

**Conjecture**: The theory of matroid minors extends to valuated matroids (matroids equipped with a valuation function taking values in a tropical semiring). Specifically: if M is a valuated matroid over the tropical semiring T and N is a minor of the underlying matroid, then there is a canonical valuation on N making it a valuated matroid over T, and the valuated minor relation is a well-quasi-order when restricted to valuated matroids of bounded rank over a fixed tropical semifield.

**Test**: Define valuated matroids in Lean 4 as pairs (M, v) where M is a matroid and v : Bases(M) → T satisfies the tropical Plücker relations. Define valuated deletion and contraction. Verify that the operations are well-defined on small examples (rank ≤ 3, |E| ≤ 6) computationally. State and attempt to prove that valuated minor-closed properties have finite forbidden minors under a valuated WQO hypothesis.

**Impact**: Valuated matroids are the correct framework for tropical geometry, and connecting them to the Robertson-Seymour program would open a new frontier in tropical combinatorics. This would bridge matroid minor theory with the tropical algebra structures already in the Catalog.

**Catalog References**: `Tropical/` (tropical algebra infrastructure), `Algebra/MatroidMinors/Theorems.lean` (matroid minor framework)

**Proof Strategy**: Build on the abstract framework from this cycle. The key new ingredient is the tropical Plücker relations, which can be formalized as a predicate on functions from bases to the tropical semiring. The minor operations should respect these relations. Use the existing tropical semiring formalization in the Catalog as a starting point.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry, Combinatorics <-> Algebraic Geometry

**Lineage**: Builds on the matroid minor framework from this cycle. Connects to tropical algebra in `Tropical/` and bridges in `Bridges/`.

**Ambition**: grand_challenge

---

### Direction 5: Computational Enumeration of Excluded Minors for GF(5)

**Conjecture**: The number of excluded minors for GF(5)-representability is finite and at most 1000. More specifically, every excluded minor for GF(5)-representability has at most 15 elements.

**Test**: Implement an efficient enumeration algorithm for simple matroids of rank ≤ 4 on n ≤ 12 elements. For each, test GF(5)-representability by searching for a 4×n matrix over GF(5) whose column matroid matches. Identify all minimal non-GF(5)-representable matroids in this range. Compare with known excluded minors for smaller fields (U(2,4) for GF(2), etc.) to ensure consistency.

**Impact**: No excluded minor for GF(5)-representability has been completely characterized. Even finding a single one would be a significant advance. An upper bound on the number or size of excluded minors would provide evidence for or against Rota's conjecture in a concrete, understudied case.

**Catalog References**: `Algebra/MatroidMinors/Theorems.lean` (definition `ForbiddenMinors`, theorem `rs_implies_finite_obstructions`)

**Proof Strategy**: This is primarily computational. Use the algorithms in `algorithms.py` as a starting point. The key optimization is to use matroid intersection and oracle algorithms rather than brute-force matrix search. For formal verification, any discovered excluded minors could be certified in Lean 4 by exhibiting a matroid with the right independence structure and proving it's not GF(5)-representable.

**Domain Bridges**: Combinatorics <-> Computation, Matroid Theory <-> Finite Geometry

**Lineage**: Builds on the representability testing infrastructure from this cycle.

**Ambition**: extension
