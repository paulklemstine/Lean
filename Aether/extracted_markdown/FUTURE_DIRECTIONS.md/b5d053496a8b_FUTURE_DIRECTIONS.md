# Future Directions: Standard Conjectures on Algebraic Cycles

## Synthesis

This cycle established the algebraic skeleton of Grothendieck's standard conjectures, formalizing and proving structural theorems about Lefschetz modules, pure motives, Künneth projectors, and weight filtrations. The key discovery is that the linear-algebraic consequences of the standard conjectures — rank additivity, direct sum decomposition, Hodge index, and weight filtration purity — can be proved unconditionally, without any geometric input.

The most promising cross-domain connection is between the **Hodge index theorem** (proved here for rank-2 forms) and the **tropical Hodge theory** developed in the Catalog's `Tropical/HodgeTheory/Foundations.lean`. The Hodge index theorem constrains intersection forms on algebraic surfaces; its tropical analog constrains valuations on tropical varieties. Bridging these two would connect our abstract Lefschetz module framework to the combinatorial setting of tropical geometry, potentially yielding a purely combinatorial proof strategy for the standard conjectures in special cases.

The highest breakthrough potential lies in Direction 1 (Hard Lefschetz decomposition), because formalizing the full primitive decomposition would unlock the proof of B ⟹ C ⟹ D, completing the implication chain that Kleiman established but which has never been formalized. Direction 3 (motivic Galois group) has the broadest impact: formalizing the Tannakian structure of motives would connect to the Langlands program and provide a foundation for motivic integration.

---

### Direction 1: Hard Lefschetz Decomposition for Abstract Lefschetz Modules

**Conjecture**: For any Lefschetz module (V, L, Q) where L satisfies the Hard Lefschetz condition (L^k : V_{n-k} → V_{n+k} is an isomorphism for all k), the space V admits a unique primitive decomposition V = ⊕_{j≥0} L^j · P_{n-2j} where P_i = ker(L^{n-i+1} : V_i → V_{n+i+2}) is the primitive subspace in degree i.

**Test**: Formalize the decomposition for a graded Lefschetz module with V = ℚ^{2n+1} and L = shift operator. Verify that the primitive pieces are linearly independent and span V. Test computationally for n = 1, 2, 3 by constructing explicit Lefschetz operators on ℚ-vector spaces of Betti-number dimensions matching known varieties (ℙ^n, Grassmannians, hypersurfaces).

**Impact**: If proved, this would formalize the first step of Kleiman's proof that B ⟹ C ⟹ D. The primitive decomposition is the key structural result needed to construct Künneth projectors from the Lefschetz operator.

**Catalog References**: `Algebra/StandardConjectures/Defs.lean` (LefschetzModule, primitiveSpace), `Tropical/HodgeTheory/Foundations.lean`

**Proof Strategy**: Define a graded Lefschetz module with graded pieces V_0, ..., V_{2n}. Prove by induction on n that L^k is injective from V_{n-k} to V_{n+k} implies the primitive decomposition exists. Key lemma: ker(L^{k+1}) ∩ V_{n-k} has the correct dimension. Use the existing `LefschetzModule.primitiveSpace` definition as the base case.

**Domain Bridges**: Algebra <-> Topology, Algebra <-> Tropical

**Lineage**: Builds on `complement_idempotent`, `PureMotive.rank_add_complement_rank`, and `numKer_Lefschetz_stable` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hodge-Riemann Bilinear Relations in Abstract Setting

**Conjecture**: For a polarized Lefschetz module (V, L, Q) with Q positive definite on the (appropriately signed) primitive subspace, the Hodge-Riemann bilinear relations hold: (-1)^{(n-k)(n-k-1)/2} Q(ξ, L^{n-2k}ξ̄) > 0 for all nonzero primitive classes ξ ∈ P^k, where ξ̄ is the complex conjugate in a suitable complexification.

**Test**: Construct explicit polarized Lefschetz modules modeling H*(ℙ^n), H*(elliptic curve), and H*(K3 surface) and verify the bilinear relations numerically. For the K3 surface, the intersection form has signature (3, 19) on H^2, and the Hodge-Riemann relations should give the correct sign pattern on primitive classes.

**Impact**: The Hodge-Riemann relations are the key analytic input that converts the algebraic structure of Lefschetz modules into signature constraints. Formalizing them would complete the Hodge index theorem in all dimensions (our current result is only for rank 2).

**Catalog References**: `Algebra/StandardConjectures/Theorems.lean` (hodge_index_rank2), `Catalog/Algebra/HodgeConjecture/Defs.lean` (PolarizedHS), `Catalog/Algebra/HodgeDecomposition/Basic.lean`

**Proof Strategy**: Define a complexified Lefschetz module (V_ℂ, L, Q_ℂ). Formalize the Weil operator C acting on V_ℂ. Prove that Q(ξ, Cξ) defines a positive-definite Hermitian form on primitive classes. The key difficulty is formalizing the complexification and the Weil operator; the algebraic content then follows from spectral theory of Hermitian forms.

**Domain Bridges**: Algebra <-> Analysis, Algebra <-> Physics (Kähler geometry)

**Lineage**: Extends `hodge_index_rank2` from rank 2 to arbitrary rank, builds on `PolarizedHS` from `HodgeConjecture/Defs.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Tannakian Structure of Pure Motives

**Conjecture**: The category of pure motives (as defined by our `PureMotive` structure, with morphisms being linear maps commuting with projectors) forms a rigid abelian tensor category. If Standard Conjecture D holds (numKer = homKer for all Lefschetz modules), this category is furthermore Tannakian, and its Tannaka dual is the *motivic Galois group* G_mot.

**Test**: Formalize the tensor product of two pure motives M₁ = (V₁, p₁, m₁) and M₂ = (V₂, p₂, m₂) as M₁ ⊗ M₂ = (V₁ ⊗ V₂, p₁ ⊗ p₂, m₁ + m₂). Verify that p₁ ⊗ p₂ is idempotent. Prove that the Tate motive ℚ(1) = (ℚ, id, 1) is a unit for the twist operation.

**Impact**: The motivic Galois group is the conjectural symmetry group governing all cohomology theories simultaneously. Formalizing its definition would provide a foundation for motivic integration (used in the Langlands program) and connect algebraic geometry to representation theory.

**Catalog References**: `Algebra/StandardConjectures/Defs.lean` (PureMotive), `Algebra/CategoryTheory.lean`, `Catalog/Algebra/HodgeConjecture/Theorems.lean`

**Proof Strategy**: Step 1: Define morphisms of pure motives as f : V₁ → V₂ with p₂ ∘ f ∘ p₁ = f. Step 2: Define tensor product and verify idempotency of p₁ ⊗ p₂ (uses `complement_idempotent` generalized to tensor products). Step 3: Define the fiber functor to ℚ-vector spaces. Step 4: Verify Tannakian axioms using Deligne's theorem.

**Domain Bridges**: Algebra <-> Category Theory, Algebra <-> Number Theory

**Lineage**: Builds on `PureMotive.complement`, `PureMotive.rank_add_complement_rank`, and the Künneth projector theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Computational Falsification of the Primitive Bound Conjecture

**Conjecture**: The primitive bound conjecture (dim ker L ≤ d/2 + 1 for compatible nondegenerate (Q, L)) is FALSE for arbitrary Lefschetz modules but TRUE for "geometric" ones satisfying additional axioms (e.g., Hard Lefschetz, Hodge-Riemann relations).

**Test**: Construct explicit counterexamples by:
1. Building a 6×6 symmetric nondegenerate Q with L-compatible L having ker(L) of dimension 4 (> 6/2+1 = 4, so the bound is tight).
2. Searching over rational matrices using lattice reduction (LLL/BKZ) to find exact rational counterexamples.
3. If no counterexamples exist, prove the conjecture using the spectral theory of self-adjoint operators.

**Impact**: If the conjecture is true, it identifies a new algebraic consequence of L-compatibility that goes beyond what was previously known. If false, the counterexample would reveal the precise additional axiom (beyond compatibility and nondegeneracy) needed to control the primitive dimension — illuminating the gap between algebra and geometry.

**Catalog References**: `Algebra/StandardConjectures/Theorems.lean` (conjecture_primitive_bound), `Algebra/StandardConjectures/Defs.lean` (LefschetzModule, primitiveSpace)

**Proof Strategy**: For the proof direction: use the fact that Q-compatibility forces L to be Q-self-adjoint, so L is diagonalizable over ℝ. The kernel dimension is the multiplicity of eigenvalue 0, which is constrained by the rank-nullity theorem and the nondegeneracy of Q. Key lemma: if Q is nondegenerate and QL = L^TQ, then rank(L) ≥ d/2 - 1.

**Domain Bridges**: Algebra <-> Computation, Algebra <-> Optimization

**Lineage**: Direct extension of `conjecture_primitive_bound` from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Standard Conjectures via Lefschetz Modules

**Conjecture**: The standard conjectures have tropical analogs: for a tropical variety X of dimension n, the tropical Lefschetz operator L_trop on the tropical cohomology H^*_trop(X) satisfies: (a) Hard Lefschetz (L_trop^k is an isomorphism in complementary degrees), (b) the tropical Künneth projectors are "algebraic" in the tropical sense, and (c) tropical numerical equivalence equals tropical homological equivalence.

**Test**: Formalize the tropical Lefschetz operator for tropical ℙ^2 (the standard tropical 2-simplex) and verify Hard Lefschetz computationally. The tropical Betti numbers of ℙ^2_trop are (1, 0, 1, 0, 1), matching the classical case. Verify that L_trop : H^0 → H^2 is an isomorphism (both are 1-dimensional).

**Impact**: If true, this would establish the standard conjectures in the tropical setting — a potentially easier target than the classical algebraic setting. Tropical geometry provides a "combinatorial shadow" of algebraic geometry, and proving the conjectures there could provide insight into the classical case.

**Catalog References**: `Tropical/HodgeTheory/Foundations.lean`, `Tropical/HodgeCorrespondence.lean`, `Algebra/StandardConjectures/Defs.lean` (LefschetzModule)

**Proof Strategy**: Define a tropical Lefschetz module by equipping tropical cohomology with the tropical intersection pairing and the operator induced by intersecting with a tropical hyperplane. Apply the abstract theorems from this cycle (standardD_of_nondegenerate, künneth_two_projectors) to conclude the tropical standard conjectures hold whenever the tropical intersection pairing is nondegenerate.

**Domain Bridges**: Algebra <-> Tropical, Topology <-> Combinatorics

**Lineage**: Bridges this cycle's Lefschetz module framework with the tropical Hodge theory in the Catalog.

**Ambition**: extension
