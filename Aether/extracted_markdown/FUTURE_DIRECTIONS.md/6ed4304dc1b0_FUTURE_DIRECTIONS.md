# Future Directions: Certified Mass Gap Bounds

## Synthesis

This cycle established a rigorous framework for certifying spectral gap bounds in lattice gauge theories through interval arithmetic. The key innovation is the `CertifiedEigenvalueBound` structure, which bridges numerical computation and mathematical proof by packaging eigenvalue intervals with validity certificates. Three cross-cutting themes emerged:

**Theme 1: Certification ↔ Difficulty.** The cross-domain theorem (mass_gap_condition_number_bound) reveals a fundamental tension: the mass gap simultaneously measures the physical observable and the computational difficulty of certifying it. Confining theories have large gaps and large condition numbers, making them both physically interesting and numerically challenging. This tension is the central obstacle to extending certification to weak coupling.

**Theme 2: Finite Volume ↔ Continuum.** The finite_volume_gap_positive theorem shows that above a computable threshold L₀, lattice certificates remain valid. Chaining such certificates across lattice sizes could yield a constructive proof of the continuum mass gap — but this requires uniform bounds that persist under refinement, connecting to the catalog's `uniform_lattice_gap_persists_under_refinement` in `Physics/SpectralGap.lean`.

**Theme 3: Representation Theory ↔ Numerical Analysis.** The Casimir bound monotonicity results connect the representation-theoretic structure of gauge groups (Casimir eigenvalues, sector ordering) with numerical properties (interval width, tightness ratio). The most promising cross-domain direction is extending this bridge to spectral theory in machine learning, where similar eigenvalue certification problems arise in graph neural networks and kernel methods.

---

### Direction 1: Verified Interval Arithmetic for Transfer Matrices

**Conjecture**: For SU(2) on a 4×4 lattice at β = 0.3, the transfer matrix eigenvalues can be certified to lie within intervals of width < 10⁻⁶ using 128-bit interval arithmetic, yielding a tightness ratio τ > 0.999.

**Test**: Implement the SU(2) transfer matrix construction in verified interval arithmetic (e.g., using Lean's native Float or a certified interval library). Compute the two largest eigenvalues with rigorous bounds. Construct a CertifiedEigenvalueBound and verify τ > 0.999.

**Impact**: This would be the first machine-verified mass gap certificate for a non-trivial lattice gauge theory. It would demonstrate that the CertifiedEigenvalueBound framework produces practical, tight bounds — not just theoretical guarantees. If tightness is low (τ < 0.9), it would reveal that interval arithmetic alone is insufficient and preconditioning is needed.

**Catalog References**: `Physics/CertifiedMassGapBounds.lean` (CertifiedEigenvalueBound, tightness_ratio_in_unit_interval), `Physics/SpectralGap.lean` (diagonal_hamiltonian_mass_gap)

**Proof Strategy**: (A) Implement SU(2) group integration using the Weyl character formula. (B) Construct the transfer matrix as a Kronecker product over plaquettes. (C) Use power iteration with interval arithmetic to bound the two largest eigenvalues. (D) Apply compose_interval_gap_bounds to certify the gap.

**Domain Bridges**: Physics <-> Computation, Algebra <-> Physics

**Lineage**: Builds directly on CertifiedEigenvalueBound and compose_interval_gap_bounds from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Casimir Tightness Conjecture Resolution

**Conjecture**: There exists K ≤ 10 such that for SU(2) on lattices L ≤ 8 and β ∈ (0, 1], the Casimir bound satisfies bound/true_gap ≥ 1 - K·β.

**Test**: Exactly diagonalize the SU(2) transfer matrix on 2×2, 3×3, 4×4 lattices for β ∈ {0.05, 0.1, 0.15, ..., 1.0}. For each (β, L), compute the Casimir bound and the true gap. Fit K by least squares. Verify the bound holds for all data points.

**Impact**: If true with K ≤ 10, the Casimir bound is a practical tool for certified QFT — the bound is within 10β percent of the truth, which is < 10% for β < 0.1 (strong coupling). If false, it constrains the region where Casimir bounds are useful and motivates higher-order corrections.

**Catalog References**: `Physics/CertifiedMassGapBounds.lean` (casimir_tightness_conjecture, casimir_tightness_nontrivial), `Physics/CharacterExpansionMassGap.lean` (mass_gap_lower_bound_from_character_suppression)

**Proof Strategy**: (A) Implement exact diagonalization for small SU(2) transfer matrices. (B) Compute bound/true_gap ratios. (C) If K ≤ 10 works: formalize the result as a concrete theorem for each (β, L) pair. (D) If K > 10 or doesn't exist: compute the next-order correction term and formalize an improved bound.

**Domain Bridges**: Physics <-> Computation

**Lineage**: Direct follow-up to casimir_tightness_conjecture and casimir_tightness_nontrivial from this cycle.

**Ambition**: extension

---

### Direction 3: Preconditioning the Confinement Barrier

**Conjecture**: There exists a polynomial preconditioner P (computable in time O(dim²)) such that the condition number of P·T is bounded by exp(C·β⁻¹/²) instead of exp(C·β⁻¹), halving the logarithmic barrier to gap certification.

**Test**: For SU(2) on a 4×4 lattice, implement block-Jacobi and polynomial preconditioners. Measure the condition number of P·T vs T for β ∈ {0.1, 0.2, ..., 0.5}. Compare convergence rates of preconditioned vs unpreconditioned power iteration.

**Impact**: Would break the tightness-difficulty tradeoff identified in this cycle. The mass_gap_condition_number_bound theorem shows that simulation cost is exponential in the gap; a preconditioner that reduces this to exp(√gap) would make strong-coupling certification feasible for physically relevant parameters.

**Catalog References**: `Physics/CertifiedMassGapBounds.lean` (mass_gap_condition_number_bound, gap_perturbation_bound), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: (A) Analyze the spectral structure of SU(2) transfer matrices to identify clustered eigenvalue groups. (B) Design a polynomial preconditioner that separates the two largest eigenvalue clusters. (C) Prove that the preconditioned condition number grows as exp(C·β⁻¹/²) using perturbation theory. (D) Formalize the bound in Lean using gap_perturbation_bound.

**Domain Bridges**: Physics <-> Computation, Physics <-> MachineLearning

**Lineage**: Motivated by the condition number barrier revealed by mass_gap_condition_number_bound.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Certification for Graph Neural Networks

**Conjecture**: The CertifiedEigenvalueBound framework generalizes to certify spectral gaps of graph Laplacians, enabling provable bounds on the expressive power of message-passing neural networks.

**Test**: Apply the framework to random regular graphs (d=3, n=100). Certify the spectral gap of the normalized Laplacian using interval arithmetic. Compare certified bounds with empirical gap measurements.

**Impact**: Would bridge physics (mass gap certification) and machine learning (GNN expressiveness). The Cheeger inequality relates spectral gaps to graph connectivity, so certified gap bounds would yield certified connectivity guarantees. This connects to the structural opportunity identified in the catalog: Algebra ↔ MachineLearning bridge via spectral theory.

**Catalog References**: `Physics/CertifiedMassGapBounds.lean` (CertifiedEigenvalueBound, compose_interval_gap_bounds), `MachineLearning/` (various), `Algebra/` (spectral theory)

**Proof Strategy**: (A) Generalize CertifiedEigenvalueBound to arbitrary symmetric matrices. (B) Implement certified eigenvalue computation for sparse matrices. (C) Prove that GNN distinguishing power is bounded by exp(-gap · depth). (D) Apply to concrete graph families.

**Domain Bridges**: Physics <-> MachineLearning, Algebra <-> MachineLearning

**Lineage**: Natural generalization of CertifiedEigenvalueBound to non-physics domains.

**Ambition**: extension

---

### Direction 5: Uniform Bound Chain for Continuum Mass Gap

**Conjecture**: For SU(2) in the strong coupling regime (β < β_c for some critical β_c > 0), the sequence of finite-volume mass gaps m_L satisfies m_L ≥ c > 0 for all L ≥ 2, where c depends only on β.

**Test**: Compute m_L for L = 2, 3, ..., 8 at β = 0.1, 0.2, 0.3. Check whether inf_L m_L remains bounded away from zero. Extrapolate the L → ∞ limit using finite-size scaling.

**Impact**: A uniform lower bound across all lattice sizes would, combined with the continuum limit existence (assumed), yield a rigorous proof of the mass gap for SU(2) at strong coupling. This would resolve a restricted version of the Millennium Prize Problem. Even a negative result (m_L → 0 for some β) would be valuable, identifying the critical coupling where the mass gap vanishes.

**Catalog References**: `Physics/CertifiedMassGapBounds.lean` (finite_volume_gap_positive, gap_certification_from_strong_coupling), `Physics/SpectralGap.lean` (uniform_lattice_gap_persists_under_refinement, lattice_gap_infimum_positive)

**Proof Strategy**: (A) Use gap_certification_from_strong_coupling to establish β₀ for each L. (B) Show β₀ can be chosen independently of L (uniform bound). (C) Apply uniform_lattice_gap_persists_under_refinement from the catalog. (D) Take the continuum limit using the uniform bound.

**Domain Bridges**: Physics <-> Algebra (representation theory)

**Lineage**: Builds on finite_volume_gap_positive and gap_certification_from_strong_coupling from this cycle, plus uniform_lattice_gap_persists_under_refinement from the catalog.

**Ambition**: grand_challenge
