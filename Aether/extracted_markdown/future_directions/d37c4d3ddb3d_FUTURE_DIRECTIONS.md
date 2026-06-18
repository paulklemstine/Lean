# Future Directions

## Synthesis

This cycle established the categorical foundations of physical theories, proving that the (2,∞)-category with duals is the necessary and sufficient algebraic skeleton for any theory unifying TQFTs and string theory. The tight bound (Theorem 2) and the dimension gap (Theorem 12) together pin down the precise categorical level at which physics operates. The oracle hierarchy (Theorems 7–10) reveals a deep connection between dimension and computability that bridges algebraic topology and computability theory.

The most promising cross-domain connection is between the **oracle hierarchy for TQFTs** and the **existing oracle/computability results** in the Catalog (`Computation/GravityOracle.lean`, `Algebra/OptimalComputer.lean`). The oracle level of TQFTs grows linearly with dimension, and this growth rate can be connected to the structure of the arithmetical hierarchy — a connection that could yield new results in both directions. The bridge between categorical physics and computability theory is largely unexplored in the formalization literature.

The second major opportunity is the connection between the **shadow functor framework** and **existing bridge constructions** (`Bridges/AlgebraEMLClosureComputation.lean`). The truncation/shadow picture — where different physical theories emerge as restrictions of a single higher-categorical object — is a special case of the general pattern of "forgetful functors between structured categories." Formalizing this general pattern would unify several existing catalog entries.

---

### Direction 1: Oracle-Computability Bridge for Physical Theories

**Conjecture**: The oracle level of the partition function of a d-dimensional TQFT is exactly Σ⁰_{max(0, d-3)} in the arithmetical hierarchy, with the lower bound witnessed by an explicit reduction from the (d-3)-fold iterated halting problem.

**Test**: For d = 4, construct an explicit reduction from the halting problem to the computation of the partition function of a specific 4-dimensional TQFT (e.g., Crane-Yetter theory or a discretized version of 4d Yang-Mills). For d = 5, construct a reduction from the Σ⁰₂-complete problem (halting of programs with halting oracle) to a 5d TQFT partition function.

**Impact**: If true, this gives the first tight computability classification of physical partition functions by dimension, establishing TQFTs as a natural physical realization of the arithmetical hierarchy. If false at d = 5 or higher, it would suggest that the oracle hierarchy of TQFTs grows sub-linearly, requiring revision of the oracle level model.

**Catalog References**: `Computation/GravityOracle.lean` (oracle structures), `Algebra/OptimalComputer.lean` (oracle hierarchy), `Physics/CategoricalPhysics/Theorems.lean` (tqftOracleLevel, oracle_unbounded)

**Proof Strategy**: 
1. Formalize the arithmetical hierarchy Σ⁰_n as a tower of decision problems.
2. For the upper bound: show that d-dimensional TQFTs can be computed with a Σ⁰_{d-3} oracle by reducing cobordism classification to the word problem for finitely presented groups (for d ≥ 4).
3. For the lower bound: construct a TQFT whose partition function encodes the iterated halting problem. Use the Adyan-Rabin theorem (undecidability of manifold properties from group presentations) to get the d = 4 case, then use suspension/product constructions for higher d.
4. Key lemma: the word problem for groups embeds into the homeomorphism problem for 4-manifolds (Markov's theorem).

**Domain Bridges**: Computability Theory ↔ Algebraic Topology ↔ Physics
**Lineage**: Builds on oracle_unbounded, oracle_level_monotone, and the gravity oracle formalism in Computation/GravityOracle.lean
**Ambition**: grand_challenge

---

### Direction 2: Surjectivity of the Cobordism Hypothesis

**Conjecture**: Every fully dualizable object in a symmetric monoidal (∞,n)-category with duals gives rise to a unique fully extended n-dimensional TQFT. In our formalism: for every element x : HigherCatData(d).Obj(0) satisfying appropriate duality conditions, there exists a FullyExtendedTQFT(d) with pointValue = x.

**Test**: Construct the TQFT explicitly for d = 1 (where the cobordism category is Fin-graded vector spaces and the TQFT assigns finite-dimensional vector spaces to points) and d = 2 (where the TQFT is determined by a commutative Frobenius algebra). Verify that the construction satisfies all TQFT axioms.

**Impact**: Combined with our cobordism_hypothesis_structural (injectivity), this would give the full cobordism hypothesis as an equivalence. This would be one of the first machine-verified formulations of a major result in higher category theory.

**Catalog References**: `Physics/CategoricalPhysics/Theorems.lean` (cobordism_hypothesis_structural, FullyExtendedTQFT), `Catalog/Algebra/CategoryTheory.lean`

**Proof Strategy**:
1. For d = 1: define the cobordism category of 0-manifolds (finite sets of points with orientations) and 1-cobordisms (oriented intervals). The TQFT assigns a vector space V to a positive point and V* to a negative point. The fully dualizable object is V with eval : V ⊗ V* → k and coeval : k → V* ⊗ V.
2. For d = 2: define the cobordism category of 1-manifolds (circles) and 2-cobordisms (surfaces with boundary). The TQFT is determined by a commutative Frobenius algebra A, with Z(S¹) = A and Z(pair of pants) = multiplication.
3. Key definitions needed: FrobeniusAlgebra structure, the specific 1d and 2d cobordism categories.

**Domain Bridges**: Category Theory ↔ Algebraic Topology ↔ Linear Algebra
**Lineage**: Extends cobordism_hypothesis_structural from this cycle
**Ambition**: grand_challenge

---

### Direction 3: Monoidal TQFT Factorization and Locality

**Conjecture**: For any monoidal cobordism category and any TQFT Z, the amplitude of a disjoint cobordism factorizes: Z(W₁ ⊔ W₂) = Z(W₁) ⊗ Z(W₂). Moreover, this factorization is natural in both W₁ and W₂, making Z a symmetric monoidal functor.

**Test**: Formalize MonoidalTQFT as a TQFT together with monoidal natural isomorphisms, and prove that the factorization is coherent (satisfies the pentagon and hexagon axioms). Verify for the trivial TQFT (stateSpace = PUnit) and the "counting" TQFT (stateSpace = ℝ, amplitude = constant).

**Impact**: This would formalize the principle of **locality** in physics: the partition function of a disconnected spacetime factorizes as a product. This is a foundational axiom of quantum field theory that has never been machine-verified.

**Catalog References**: `Physics/CategoricalPhysics/Theorems.lean` (MonoidalCobordismData, duality_monoidal_coherence), `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**:
1. Define MonoidalTQFT extending TQFT with additional structure: a natural isomorphism stateSpace(M ⊔ N) ≅ stateSpace(M) ⊗ stateSpace(N).
2. Prove that the trivial TQFT is monoidal (with the obvious isomorphism PUnit ≅ PUnit ⊗ PUnit).
3. Define the universal monoidal TQFT and prove that every TQFT factors through it monoidally.
4. Key lemma: the duality_monoidal_coherence result extends to a full monoidal functor structure.

**Domain Bridges**: Category Theory ↔ Physics ↔ Algebra
**Lineage**: Extends MonoidalCobordismData and duality_monoidal_coherence from this cycle
**Ambition**: extension

---

### Direction 4: Concrete 2d TQFT Classification

**Conjecture**: The category of 2-dimensional TQFTs (over a field k) is equivalent to the category of commutative Frobenius algebras over k. In particular, every 2d TQFT is determined by a finite-dimensional commutative Frobenius algebra, and every such algebra gives a 2d TQFT.

**Test**: Define FrobeniusAlgebra as a structure (algebra + coalgebra + Frobenius relation). Construct the 2d cobordism category with generators (pair of pants, cap, cup, twist) and relations. Show the equivalence by constructing functors in both directions and proving they are inverse.

**Impact**: This is the classical classification theorem for 2d TQFTs, proved informally in the 1990s but never fully formalized. A machine-verified version would be a landmark in formalized mathematical physics.

**Catalog References**: `Physics/CategoricalPhysics/Defs.lean` (CobordismData, TQFT), `Catalog/Algebra/AlgebraicTheoryOfAlgebra.lean`

**Proof Strategy**:
1. Define `FrobeniusAlgebra` over a commutative ring R: a structure with multiplication, comultiplication, unit, counit, and the Frobenius relation (Δ ∘ μ = (id ⊗ μ) ∘ (Δ ⊗ id) = (μ ⊗ id) ∘ (id ⊗ Δ)).
2. Define `Cob₂` as a CobordismData structure with generators for the pair of pants, disk, and annulus.
3. Construct the functor TQFT₂ → FrobeniusAlg by evaluation on generators.
4. Construct the inverse functor by defining amplitudes on generators using algebra operations.
5. Prove roundtrip: both compositions are naturally isomorphic to the identity.

**Domain Bridges**: Algebraic Topology ↔ Algebra ↔ Physics
**Lineage**: Builds on CobordismData and TQFT definitions from this cycle
**Ambition**: extension

---

### Direction 5: Tropical Shadows and Information Geometry

**Conjecture**: The shadow functor from a dualizable tower to its TQFT truncation has a tropical analogue: replacing the target category with the tropical semiring (ℝ ∪ {∞}, min, +) gives a "tropical TQFT" that captures the dominant-term behavior of partition functions in the semiclassical limit (ℏ → 0).

**Test**: Define TropicalTQFT as a TQFT valued in the tropical semiring. Show that for the 2d case, tropical TQFTs correspond to tropical Frobenius algebras. Verify that the partition function of a surface of genus g in the tropical limit is min over saddle-point configurations.

**Impact**: This would connect the categorical physics framework to tropical geometry (already well-developed in the Catalog) and semiclassical physics. The tropical shadow would give computable lower bounds on partition functions, partially circumventing the computability barrier.

**Catalog References**: `Tropical/FunctorialSurgery.lean`, `Physics/TropicalTDuality.lean`, `Physics/TropicalBarrier.lean`, `Physics/CategoricalPhysics/Theorems.lean`

**Proof Strategy**:
1. Define the tropical semiring formally (already partially in Catalog).
2. Define TropicalTQFT by replacing stateSpace with tropical modules and amplitude with tropical linear maps.
3. Show that the tropicalization of a classical TQFT is a TropicalTQFT (by taking val ∘ Z where val is the valuation map).
4. Prove the tropical Frobenius algebra classification for 2d tropical TQFTs.
5. Connect to the semiclassical limit via the Maslov dequantization (replace (ℝ, +, ×) with (ℝ, min, +)).

**Domain Bridges**: Tropical Geometry ↔ Physics ↔ Computability Theory
**Lineage**: Builds on Tropical catalog entries and the shadow framework from this cycle
**Ambition**: extension
