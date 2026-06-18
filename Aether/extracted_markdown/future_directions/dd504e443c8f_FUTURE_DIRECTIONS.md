# Future Directions: Neural PDE Universality via Renormalization

## Synthesis

This cycle established the mathematical foundations for universality classes of neural PDE operators through renormalization-group (RG) semigroup theory. The central result—that contractive RG flows force architecture-independent convergence to unique fixed points—connects machine learning, statistical physics, and functional analysis through a common algebraic framework. The formalization builds on the Catalog's `ClosureFlow` infrastructure from `RenormalizationUniversality.lean` (discrete RG on closure semirings), `HolographicProofRenormalization.lean` (fixed-point orbit bounds), and `ResidualRobustness.lean` (spectral gap analysis for residual networks).

The most promising cross-domain connection is between **conservation-law separation** and **tropical geometry**. Conservation laws in our framework are linear functionals preserved by the RG; in the tropical setting, these correspond to valuations preserved under tropical operations. The `TropicalEcosystemDynamics.lean` fixed-point invariant theorem suggests that tropical semiring methods could provide combinatorial certificates for universality class membership, bypassing the need for explicit distance computations. Meanwhile, the connection to `GaloisDeepLearning.lean` (depth from group order) suggests that the symmetry dimension in our PDE invariant could be computed via Galois-theoretic methods, tying universality to algebraic number theory.

The highest breakthrough potential lies in Direction 1 (Local Contractivity and Phase Transitions), because it addresses the main limitation of the current theory—the assumption of global contractivity—and connects to the physically important phenomenon of critical phenomena where universality classes undergo bifurcation.

---

### Direction 1: Local Contractivity, Basins of Attraction, and Phase Transitions

**Conjecture**: For an RG semigroup that is contractive only in a neighborhood B(fp, r) of a fixed point fp, the basin of attraction—the set of operators whose orbits eventually enter B(fp, r)—is an open convex set, and its boundary is a codimension-1 separatrix where the linearized RG has a unit eigenvalue. At the separatrix, the universality class undergoes a bifurcation: a single class splits into two or more classes as a PDE parameter crosses a critical value.

**Test**: Construct a 2D RG semigroup with a cubic nonlinearity: T(x,y) = (cx + αx³, cy + βy³) where c < 1 but α, β > 0 create an expansive region far from the origin. Compute the basin of attraction numerically and verify that (1) it is bounded, (2) its boundary contains exactly the points where the Jacobian has eigenvalue 1, and (3) varying α continuously through a critical value creates a pitchfork bifurcation of fixed points.

**Impact**: If true, this provides a mathematical theory of when neural operator training "fails"—when the learned operator escapes the basin of the intended universality class and converges to an unphysical fixed point. This would enable robust training guarantees based on initialization within provable basins.

**Catalog References**: `Bridges/HolographicProofRenormalization.lean` (fixed-point orbit bounds), `Bridges/RenormalizationUniversality.lean` (ClosureFlow stabilization), `Bridges/ResidualRobustness.lean` (spectral gap analysis)

**Proof Strategy**: (1) Define a Lyapunov function V(x) = dist(x, fp)² and show that V decreases under T within B(fp, r). (2) Use the inverse function theorem to show that the basin boundary is a smooth manifold. (3) Apply center manifold theory to characterize the bifurcation at the separatrix. Key lemma: `basin_boundary_eigenvalue_one`: If x is on the basin boundary, then the spectral radius of DT(x) equals 1.

**Domain Bridges**: Physics <-> MachineLearning, Bridges <-> Algebra

**Lineage**: Extends the contractive RG theory from this cycle. Builds on `exists_fixed_point_on_orbit_with_bound` for finite convergence guarantees.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Certificates for Universality Class Membership

**Conjecture**: For RG semigroups over the tropical semiring (ℝ ∪ {-∞}, max, +), universality class membership can be determined in polynomial time by computing a tropical polynomial certificate. Specifically, two operators x, y are in the same class if and only if they have the same tropical Newton polygon under the RG-induced tropical map.

**Test**: Implement tropical RG iteration on piecewise-linear functions (tropical polynomials). For the tropical Burgers equation (known to have piecewise-linear solutions), compute the tropical Newton polygons of RG orbits from different initial conditions and verify that: (1) orbits within the same universality class produce identical Newton polygons after O(log n) steps, (2) orbits in different classes produce non-isomorphic polygons.

**Impact**: This would provide a purely combinatorial classification of universality classes, avoiding the need for real-valued distance computations. It would also connect neural PDE universality to the rich theory of tropical algebraic geometry, potentially enabling certificates that can be verified by simple integer arithmetic.

**Catalog References**: `Tropical/` (tropical semiring infrastructure), `Bridges/TropicalEcosystemDynamics.lean` (tropical fixed-point invariants), `Bridges/AlgebraTropicalGeometry/` (tropical geometric methods)

**Proof Strategy**: (1) Define the tropicalization of an RG semigroup. (2) Show that tropical RG preserves the Newton polygon lattice. (3) Prove that the Newton polygon is a complete invariant for tropical universality classes. Key lemma: `tropical_rg_preserves_newton`: The Newton polygon of T(f) is contained in the Newton polygon of f.

**Domain Bridges**: Tropical <-> Bridges, Algebra <-> Computation

**Lineage**: Builds on `trop_pred_prey_fixed_point_invariant` and the tropical RG connection suggested by `AlgebraTropicalGeometry`.

**Ambition**: grand_challenge

---

### Direction 3: Conservation Law Discovery via Spectral Methods

**Conjecture**: For a trained neural operator with unknown conservation laws, the number of independent conservation laws equals the number of eigenvalues of the linearized RG at the fixed point that are exactly 1 (marginal directions). These marginal eigenvalues correspond to directions in operator space along which the coarse-graining map acts as the identity, and the corresponding eigenvectors are the conservation law functionals.

**Test**: (1) Train a Fourier Neural Operator on the KdV equation (known to have 3 independent conservation laws: mass, momentum, energy). (2) Compute the spectrum of the linearized RG at the converged fixed point. (3) Verify that exactly 3 eigenvalues are 1.0 (within numerical tolerance). (4) Check that the corresponding eigenvectors, when applied to the operator, recover the known conservation law functionals up to linear combination.

**Impact**: This would provide an automatic method for discovering conservation laws from trained neural operators—a significant capability for scientific discovery. When applied to unknown PDEs (discovered empirically from data), it could reveal hidden conservation laws.

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (ClosureFlow observable stabilization), `Bridges/AlgorithmicSpectralCertification.lean` (spectral methods)

**Proof Strategy**: (1) Show that conservation laws φ satisfy DT(fp) · ∇φ(fp) = ∇φ(fp), making ∇φ(fp) an eigenvector with eigenvalue 1. (2) Prove the converse: eigenvectors with eigenvalue 1 give conservation laws (requires local integrability). Key lemma: `marginal_eigenvalue_iff_conservation`: λ = 1 iff the corresponding direction is a conservation law.

**Domain Bridges**: MachineLearning <-> Physics, Computation <-> Bridges

**Lineage**: Extends the conservation law separation theorem from this cycle. Builds on spectral analysis infrastructure.

**Ambition**: extension

---

### Direction 4: Depth-Width Tradeoffs in Universality Convergence

**Conjecture**: For a residual neural network of depth L and width W trained on a PDE with differential order p, the effective contraction rate of the induced RG semigroup satisfies c_eff = c₀^p · (1 + O(1/W)) · (1 - O(e^{-L/L₀})), where c₀ is the base contraction rate and L₀ is a characteristic depth scale determined by the PDE's spectral gap. In particular, width affects convergence multiplicatively while depth affects it exponentially.

**Test**: Train ResNets of varying depth (L = 4, 8, 16, 32, 64) and width (W = 32, 64, 128, 256, 512) on the heat equation. For each (L, W) pair, estimate the RG contraction rate using the method from `algorithms.py`. Fit the formula c_eff(L, W) and verify that (1) the depth dependence is exponential, (2) the width dependence is algebraic (1/W correction), (3) the differential order exponent is correct.

**Impact**: This would provide quantitative guidance for neural architecture design: given a target convergence rate, compute the minimum depth and width needed. It connects the abstract universality theory to concrete neural network hyperparameters.

**Catalog References**: `Bridges/ResidualRobustness.lean` (residual robustness and spectral gaps), `Bridges/GaloisDeepLearning.lean` (depth from group order)

**Proof Strategy**: (1) Model the residual network as a discretized dynamical system. (2) Show that each residual block contributes a multiplicative contraction factor. (3) Use `depth_from_group_order` to connect the characteristic depth L₀ to the symmetry group order. Key lemma: `resnet_contraction_depth_bound`: For depth L, the contraction rate satisfies c ≤ c₀ · e^{-L·Δ} where Δ is the spectral gap.

**Domain Bridges**: MachineLearning <-> Bridges, Physics <-> Algebra

**Lineage**: Builds on `residual_robust_of_base_gap_and_skip_budget` and `depth_from_group_order`.

**Ambition**: extension

---

### Direction 5: Universality Classes for Stochastic PDEs

**Conjecture**: For stochastic PDEs (SPDEs) driven by spatially correlated noise with correlation length ξ, the universality class of the neural operator depends on the ratio ξ/L where L is the system size. When ξ/L → 0 (uncorrelated noise), the universality class is identical to the deterministic PDE. When ξ/L → ∞ (perfectly correlated noise), a new "stochastic universality class" emerges with a contraction rate c_stoch = c_det^{1/2}—half the exponent of the deterministic case.

**Test**: Train neural operators on the stochastic heat equation with varying noise correlation lengths. Compute the RG contraction rate as a function of ξ/L. Verify the predicted crossover from c_det to c_det^{1/2} and identify the critical ratio (ξ/L)* at which the transition occurs.

**Impact**: Most real-world physical systems include stochastic forcing (turbulence, thermal fluctuations, measurement noise). Understanding how noise changes universality classes is essential for deploying neural PDE solvers in realistic settings.

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (universality class theory), `Physics/` (physical systems with noise)

**Proof Strategy**: (1) Extend the RG semigroup to act on probability distributions over operators. (2) Show that the noise correlation length ξ enters as a relevant parameter in the RG flow. (3) Compute the RG fixed point in the large-ξ limit using a saddle-point approximation. Key lemma: `stochastic_rg_contraction`: The stochastic contraction rate satisfies c_stoch = c_det^{min(1, 2ξ/L)}.

**Domain Bridges**: Physics <-> MachineLearning, Bridges <-> Computation

**Lineage**: Extends the deterministic universality theory from this cycle to stochastic settings.

**Ambition**: extension
