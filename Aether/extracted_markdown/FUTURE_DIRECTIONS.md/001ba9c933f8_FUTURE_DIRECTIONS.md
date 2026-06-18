# Future Research Directions: Gravity from Information

## Synthesis

This research cycle established a rigorous mathematical bridge between quantum error-correcting codes and holographic gravity. The central achievement was proving that the Ryu-Takayanagi formula — the cornerstone of holographic entanglement — is mathematically equivalent to the quantum Singleton bound, and that BTZ black holes exactly saturate this bound (achieving maximum distance separable status). The **EntanglementWedge** structure provides a novel, code-theoretic definition of bulk reconstruction that is monotone, threshold-based, and respects the no-cloning theorem.

The most promising cross-domain connections emerging from this cycle are: (1) the link between coding bounds and the existing `quantum_singleton_bound` theorems in the Catalog (Physics/StabilizerBounds.lean, Physics/ToricCode.lean), which could be unified with the holographic framework to give a single theorem covering both tabletop quantum computers and black holes; (2) the connection to the `Computation/GravityOracle.lean` framework, where the `IsGravOracle` structure captures gravitational computation — the holographic code provides the concrete error-correcting substrate for such oracles; (3) the potential bridge between the `Bridges/AlgebraEMLClosureComputation.lean` filtered closure systems and holographic reconstruction, since entanglement wedge nesting is precisely a closure operation on boundary subregions.

The highest-breakthrough-potential direction is **Direction 1** (Tensor Network Realization), because it would provide explicit, constructible codes that saturate the Singleton bound — moving from parameter constraints to concrete constructions. This would transform the framework from "gravity is *consistent with* error correction" to "here is the *specific* code that gravity uses."

---

### Direction 1: Tensor Network Realization of Singleton-Saturating Holographic Codes

**Conjecture**: The HaPPY (Pastawski-Yoshida-Harlow-Preskill) pentagon code, when defined as a [[n, k, d]] stabilizer code on a hyperbolic tiling of pentagons, exactly saturates the quantum Singleton bound 2d + k = n + 2 at every level of the bulk-boundary hierarchy.

**Test**: Define the HaPPY code on a {5,4} hyperbolic tiling with r layers. For each r, compute:
- n(r) = number of boundary legs
- k(r) = number of bulk legs (logical qubits)
- d(r) = code distance (minimum weight of a logical operator)

Check whether 2d(r) + k(r) = n(r) + 2 for r = 1, 2, 3, 4, 5. If any layer fails saturation, determine whether the failure is due to boundary effects or represents a fundamental departure.

**Impact**: If true, this gives an explicit, constructive tensor network that realizes holographic gravity as an optimal error-correcting code. This would provide a concrete "lattice model" for quantum gravity. If false, the pattern of deviations from saturation would reveal which geometric features of the tiling correspond to non-optimal coding (possibly quantum corrections to the RT formula).

**Catalog References**: `Catalog/Physics/StabilizerBounds.lean` (quantum_singleton_bound_general), `Catalog/Physics/CechStabilizerCode.lean` (stabilizer_commutation_from_boundary_sq)

**Proof Strategy**:
1. Define the {5,4} hyperbolic tiling as a planar graph with pentagon faces and 4 pentagons meeting at each vertex.
2. Define the HaPPY code by placing a [[6,1,4]] perfect tensor at each pentagon and contracting internal legs.
3. Compute n(r), k(r), d(r) by counting boundary/bulk legs and analyzing minimum-weight logical operators.
4. Prove or disprove 2d(r) + k(r) = n(r) + 2 using the explicit structure.

**Domain Bridges**: Physics (holographic codes) ↔ Computation (tensor network contraction complexity) ↔ Geometry (hyperbolic tilings)

**Lineage**: Builds on `HolographicCode`, `singleton_implies_area_entropy_bound`, and `btz_singleton_saturates` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Holographic Codes with Quantum Corrections (FLM Formula)

**Conjecture**: The quantum-corrected RT formula (Faulkner-Lewkowycz-Maldacena formula)

S(A) = Area(γ_A)/(4G) + S_bulk(W_A)

where S_bulk(W_A) is the bulk entanglement entropy within the entanglement wedge W_A, corresponds to a *non-MDS* code where the Singleton bound is not saturated, with the gap 2d + k - (n + 2) measuring the bulk entanglement contribution.

**Test**: Define a "quantum-corrected holographic code" with parameters [[n, k, d]] and an additional parameter s (bulk entropy). The corrected Singleton relation should be: 2d + k = n + 2 - s, where s ≥ 0 measures the quantum correction. Verify that:
1. s = 0 recovers the classical (MDS) case
2. The modified bound s + 2d + k ≤ n + 2 is equivalent to the standard Singleton bound with effective parameters
3. For the [[5,1,3]] perfect code (no bulk entropy), s = 0 and saturation holds
4. For a [[7,1,3]] Steane code (sub-optimal), s = 2 and the formula predicts bulk entanglement

**Impact**: This would extend the gravity-as-error-correction framework to include quantum gravity corrections, moving beyond the semiclassical regime. The parameter s would be measurable in tensor network simulations.

**Catalog References**: `Catalog/Physics/VonNeumannEntropy.lean` (post_quantum_security_entropy_defect_bound), `Catalog/Physics/StabilizerBounds.lean` (quantum_singleton_bound_general)

**Proof Strategy**:
1. Define `QuantumCorrectedHolographicCode` extending `HolographicCode` with a `bulkEntropy : ℕ` field.
2. State the modified Singleton relation and prove it follows from the standard bound.
3. Show that the bulk entropy s is bounded: s ≤ k (bulk entropy cannot exceed total logical information).
4. Prove that s = 0 iff the code is MDS, connecting to the existing `btz_singleton_saturates` theorem.

**Domain Bridges**: Physics (quantum gravity corrections) ↔ EML (entropy measures) ↔ Cryptography (entropy defects in security proofs)

**Lineage**: Builds on `ryu_takayanagi_from_singleton`, `singleton_saturation_identity`, and `error_correction_threshold` from this cycle.

**Ambition**: extension

---

### Direction 3: Entanglement Wedge Nesting as a Closure Algebra

**Conjecture**: The collection of entanglement wedges for a holographic code forms a closure algebra (in the sense of `FilteredClosureSystem` from the Catalog), where the closure operator maps a boundary subregion to its entanglement wedge, and the monotonicity and idempotence properties follow from code distance constraints.

**Test**: Define a function EW : P(boundary) → P(bulk) that maps boundary subregions to their entanglement wedges. Verify:
1. Monotone: A ⊆ B → EW(A) ⊆ EW(B) (proved as `entanglement_wedge_monotone` this cycle)
2. Extensive: A ⊆ EW(A) (in the sense that boundary operators in A can represent themselves)
3. Idempotent: EW(EW(A)) = EW(A) (reconstruction is stable)
4. The wedge nesting structure satisfies the axioms of `FilteredClosureSystem`

Check whether the absorption property from `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean` (`absorption_yields_monotone_profile`) has a gravitational interpretation as the statement that "adding more boundary always improves or maintains reconstruction."

**Impact**: This would reveal a deep algebraic structure underlying holographic reconstruction — entanglement wedges are not just geometric regions but elements of a closure algebra. This bridges abstract algebra (closure systems) with quantum gravity.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (ClosureSemimoduleSystem, ClosureStableProbe), `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean` (FilteredClosureSystem, absorption_yields_monotone_profile)

**Proof Strategy**:
1. Define `EntanglementWedgeClosure` as a closure operator on `Finset (Fin n)` (boundary sites).
2. Prove monotonicity from `entanglement_wedge_monotone`.
3. Prove extensivity from the fact that boundary operators always have trivial self-action.
4. Prove idempotence from the code structure.
5. Verify the `FilteredClosureSystem` axioms.

**Domain Bridges**: Physics (entanglement wedges) ↔ Algebra (closure operators, lattice theory) ↔ Bridges (filtered closure systems) ↔ Computation (gravitational oracles as closure-based computation)

**Lineage**: Builds on `entanglement_wedge_monotone`, `greedy_wedge_steps`, and `EntanglementWedge` from this cycle, plus `ClosureSemimoduleSystem` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Code Distance as Geodesic Length in Hyperbolic Geometry

**Conjecture**: For a holographic code on a regular hyperbolic tiling {p, q}, the code distance d satisfies d = ⌊cosh⁻¹(cos(π/p) / sin(π/q)) · r / ℓ_P⌋ + 1, where r is the number of layers of tiling and ℓ_P is the Planck length. This formula relates the abstract coding parameter to a concrete geometric quantity.

**Test**: For the {5,4} tiling (HaPPY code) and {3,7} tiling (triangular hyperbolic code), compute d analytically for r = 1, 2, 3, 4 layers and compare with the formula. The hyperbolic distance from center to boundary of an r-layer tiling is r · arccosh(cos(π/p)/sin(π/q)).

**Impact**: A precise formula for code distance in terms of hyperbolic geometry would cement the dictionary between coding theory and AdS geometry. It would allow prediction of code distance for any tiling, enabling systematic search for optimal holographic codes.

**Catalog References**: `Computation/GravityOracle.lean` (geodesic_oracle_idempotent), `Physics/GravityFromInformation.lean` (code_distance_is_depth)

**Proof Strategy**:
1. Define hyperbolic distance in the Poincaré disk model.
2. Compute the distance from center to boundary of an {p,q} tiling of depth r.
3. Show that minimal-weight logical operators in the code must traverse from boundary to center.
4. Prove d ≥ r + 1 using a counting argument on the geodesic path.
5. For perfect tensors, prove d = r + 1 exactly.

**Domain Bridges**: Physics (holographic codes) ↔ Geometry (hyperbolic geometry, tilings) ↔ Computation (geodesic oracle bounds)

**Lineage**: Builds on `code_distance_is_depth` and `greedy_wedge_steps` from this cycle.

**Ambition**: extension

---

### Direction 5: Gravitational Error Correction in Dynamical Spacetimes

**Conjecture**: For a time-dependent holographic code modeling an evaporating black hole, the code distance d(t) is a non-increasing function of time t until the Page time t_P, after which d(t) increases. The Page time corresponds to the transition from a sub-MDS code (quantum corrections dominate) to a near-MDS code (classical geometry dominates).

**Test**: Model an evaporating black hole as a sequence of holographic codes [[n(t), k(t), d(t)]] where:
- n(t) = n₀ (boundary is fixed)
- k(t) = k₀ - t (entropy decreases as Hawking radiation is emitted)
- d(t) is determined by the Singleton bound

Compute the Singleton gap s(t) = n + 2 - 2d(t) - k(t) and check:
1. s(t) increases until t = t_P = k₀/2 (Page time)
2. s(t) decreases after t_P
3. At t = 0 and t = 2k₀, s = 0 (MDS at beginning and end)

**Impact**: This would provide a coding-theoretic derivation of the Page curve — one of the most important results in quantum gravity in the last decade. It would show that the transition in entanglement entropy at the Page time is a code-theoretic phase transition.

**Catalog References**: `Catalog/Physics/TheorySpacePerturbation.lean` (truncation_error_bound), `Physics/GravityFromInformation.lean` (error_correction_threshold)

**Proof Strategy**:
1. Define a time-parameterized family of holographic codes.
2. Show that the Singleton gap s(t) is determined by the bulk entropy.
3. Prove that s(t) is maximized at the Page time using the entropy formula.
4. Connect the phase transition to the quantum extremal surface prescription.
5. Verify numerically for small black holes (k₀ = 4, 8, 16).

**Domain Bridges**: Physics (black hole evaporation, Page curve) ↔ EML (entropy dynamics) ↔ Computation (information-theoretic complexity of scrambling)

**Lineage**: Builds on `singleton_saturation_identity`, `error_correction_threshold`, and the entire holographic code framework from this cycle.

**Ambition**: grand_challenge
