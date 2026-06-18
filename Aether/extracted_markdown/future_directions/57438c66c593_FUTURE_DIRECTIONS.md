# Future Directions: Categorical Physics

## Synthesis

This cycle established the foundational framework for categorical physics, proving that the mathematical shape of any unified physical theory is constrained by the cobordism hypothesis to be at least a (2,∞)-category with duals. The (2,∞)-necessity theorem bridges higher category theory and physics by showing that the simultaneous requirements of TQFT (nontrivial objects) and string theory (nontrivial morphisms) force exactly two nontrivial categorical levels. The oracle hierarchy theorem reveals a deep connection between geometry (smooth structures on manifolds) and computability theory, showing that dimension 4 is a critical threshold where physics transitions from computable to undecidable.

The most promising cross-domain connection from this cycle is the **computability-geometry bridge**: the oracle level function σ(d) = max(0, d-3) connects the arithmetical hierarchy from computability theory to the classification of smooth structures in differential topology. This suggests that the "exotic" nature of 4-manifolds is not an isolated phenomenon but the first step in an infinite staircase of computational complexity. Future work should investigate whether this staircase has additional structure (e.g., whether certain dimensions are computationally harder than the linear bound suggests).

The tightness of the (2,∞) bound — achievable by a concrete construction with Bool-valued objects — suggests that the category number (minimal stable level for a given shadow set) is a meaningful invariant of collections of physical theories. Computing this invariant for larger shadow sets could reveal unexpected constraints.

---

### Direction 1: Category Number of Shadow Sets

**Conjecture**: For any finite set S of theory types drawn from {TQFT, CFT, String, Gravity, Chern-Simons, Yang-Mills}, define the *category number* cat(S) as the minimum stable level of any dualizable tower admitting S as its shadow set. Then cat(S) is determined by the maximum "morphism level" required by any theory in S. Specifically, cat({TQFT}) = 1, cat({String}) = 2, cat({TQFT, String}) = 2, and cat({TQFT, CFT, String, Gravity}) = 4 (gravity requires nontrivial 3-morphisms for the Ricci flow).

**Test**: Formalize Yang-Mills and Chern-Simons as theory types with explicit morphism level requirements. Compute cat(S) for all subsets S of the six theory types. Verify that cat is subadditive: cat(S₁ ∪ S₂) ≤ max(cat(S₁), cat(S₂)).

**Impact**: If the category number is computable and subadditive, it provides a classification scheme for families of physical theories based on categorical complexity. If gravity truly requires cat = 4, it explains why quantum gravity is fundamentally harder than quantum field theory.

**Catalog References**: `Speculative/CategoricalPhysics/Core.lean` (PhysicalTheoryCandidate, two_infinity_necessity)

**Proof Strategy**: Define a `MorphismLevel : TheoryType → ℕ` function, prove cat(S) = max over S of MorphismLevel, establish subadditivity from the max. The key lemma is that each theory type's requirement is independent (no cancellations between level requirements).

**Domain Bridges**: Higher category theory <-> mathematical physics, computability <-> differential topology

**Lineage**: Builds on `two_infinity_necessity` and `two_infinity_achievable` from this cycle.

**Ambition**: extension

---

### Direction 2: Sharp Oracle Bounds via Exotic Smooth Structures

**Conjecture**: The oracle level function σ(d) = max(0, d-3) for TQFTs is *sharp*: for each d ≥ 4, there exists a specific TQFT in dimension d whose partition function is Σ_{d-3}-complete (complete for that level of the arithmetical hierarchy). In particular, the d=4 TQFT partition function distinguishing exotic smooth structures on S² × S² is Σ₁-complete.

**Test**: For d = 4, construct a TQFT whose partition function Z(M) encodes the word problem for groups (known to be Σ₁-complete). Verify that this TQFT's state spaces satisfy the Atiyah axioms (functoriality, multiplicativity). For d = 5, attempt a Σ₂-completeness reduction.

**Impact**: If true, this establishes the oracle hierarchy as an exact invariant, not just an upper bound. It would mean that each dimension genuinely adds computational power to physics, with no "shortcuts" where higher-dimensional theories are simpler than expected.

**Catalog References**: `Computation/GravityOracle.lean` (IsGravOracle, GravTruthSet), `Algebra/OptimalComputer.lean` (god_oracle_contains_all)

**Proof Strategy**: Use the connection between group presentations and 4-manifolds (every finitely presented group is the fundamental group of a closed 4-manifold). Encode the word problem into a TQFT via the fundamental group functor. For d = 5, use the correspondence between cobordisms and handle decompositions.

**Domain Bridges**: Computability theory <-> differential topology <-> group theory <-> TQFT

**Lineage**: Builds on `oracle_unbounded` and `tqft_undecidable_dim4` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Constructive Cobordism Hypothesis in Low Dimensions

**Conjecture**: In dimensions d ≤ 3, the cobordism hypothesis can be made *constructive* — the equivalence between fully extended TQFTs and fully dualizable objects can be witnessed by an explicit algorithm (no classical choice required). Specifically, for d = 2, the fully dualizable objects in the 2-category of linear categories are precisely the finite semisimple categories, and the correspondence TQFT ↔ fully dualizable object is computable.

**Test**: Formalize the 2-dimensional cobordism category (objects: finite sets of points, morphisms: 1-manifolds with boundary, 2-morphisms: surfaces). Construct the functor from fully dualizable objects in 2-Vect to 2-TQFTs. Verify it is an equivalence without using Classical.choice.

**Impact**: A constructive cobordism hypothesis in low dimensions would provide algorithms for computing with TQFTs, connecting the abstract categorical framework to concrete computation. It would also clarify exactly where classical logic enters the proof in higher dimensions.

**Catalog References**: `Speculative/CategoricalPhysics/Core.lean` (cobordism_hypothesis_structural, tqft_computable_low_dim)

**Proof Strategy**: In d = 2, classify surfaces by genus and boundary components. The fully extended 2-TQFT is determined by its value on a point (a Frobenius algebra). Make this correspondence algorithmic. Key lemma: every commutative Frobenius algebra over a field determines a unique 2-TQFT.

**Domain Bridges**: Constructive mathematics <-> categorical physics <-> algebraic topology

**Lineage**: Builds on `tqft_computable_low_dim` and `cobordism_hypothesis_structural` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Shadows of Categorical Physics

**Conjecture**: The duality sector bound `(n+1)/2` has a tropical analogue: in the tropical semiring (ℝ, min, +), the "tropicalized" partition function of a TQFT with n states has at most (n+1)/2 distinct critical values. This connects the categorical physics framework to tropical geometry.

**Test**: For small examples (n = 2, 3, 4 states), compute the tropical partition function and count critical values. Verify the bound. Attempt to find a TQFT that saturates the bound.

**Impact**: If the bound holds tropically, it suggests a deeper connection between duality in physics and the piecewise-linear structure of tropical geometry. This could provide combinatorial tools for computing with TQFTs.

**Catalog References**: `Tropical/TropicalOracle.lean`, `Tropical/QuantumTropicalComputation.lean`, `Speculative/CategoricalPhysics/Core.lean` (dualitySectorBound)

**Proof Strategy**: Define a tropicalization functor from TQFT amplitudes to piecewise-linear maps. Show that the Z/2 duality action tropicalizes to a reflection symmetry. Apply the tropical Morse theory bound on critical values.

**Domain Bridges**: Tropical geometry <-> categorical physics <-> combinatorics

**Lineage**: Builds on `duality_sector_le_total` from this cycle and tropical structures in the Catalog.

**Ambition**: extension

---

### Direction 5: Higher Duality and the Periodicity Conjecture

**Conjecture**: In a dualizable tower with stable level s, the dual operation at levels k < s exhibits a periodicity: the "higher dual" (composing duality with shift) applied 2s times is the identity, not just 2 times. This Z/(2s)-symmetry would be a higher analogue of the CPT theorem in physics.

**Test**: For s = 2, check whether the Z/4 symmetry (dual composed with level shift, applied 4 times = identity) holds in known 2-TQFTs. Construct explicit examples and counterexamples for s = 3.

**Impact**: If a Z/(2s) periodicity exists, it would give a mathematical explanation for the 8-fold periodicity in real K-theory (Bott periodicity), connecting it to the stable level of the categorical tower. This is speculative but would be a major bridge between algebraic topology and categorical physics.

**Catalog References**: `Speculative/CategoricalPhysics/Core.lean` (dual_fourth_power, dual_invol)

**Proof Strategy**: Define a "shifted dual" operation combining duality at level k with the structure map to level k+1. Compute its order in specific examples. Attempt to prove the order divides 2s using the stability condition.

**Domain Bridges**: Algebraic K-theory <-> categorical physics <-> representation theory

**Lineage**: Builds on `dual_fourth_power` and `self_dual_above_stable` from this cycle.

**Ambition**: extension
