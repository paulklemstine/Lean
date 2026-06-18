# Future Directions: Inverse Stereographic Neural Field Theory

## Synthesis

This research cycle established a rigorous geometric foundation for neural field theory on the 2-sphere, proving that the conformal factor of stereographic projection σ = 2/(1+r²) governs the transformation of cortical dynamics between spherical and planar descriptions. The central result — that the Mexican-hat connectivity kernel on S² selects exactly 2k+1 stable patterns for interaction radius r = 1/k — connects neural pattern formation to the representation theory of SO(3), specifically the dimension formula for irreducible representations.

The most promising cross-domain connection discovered is between the eigenvalue structure of the Laplace-Beltrami operator on S² (eigenvalues λ_l = l(l+1), gap 2(l+1)) and the spectral theory of graph Laplacians already present in the Catalog (see `laplacian_kernel_contains_const` and `laplacian_diag_eq_degree` in `MachineLearning/ViralInformationTopology.lean` and `FINAL/MachineLearning/PadicChipFiring.lean`). The continuous Laplace-Beltrami spectrum provides a limiting case of discrete graph Laplacian spectra, and this bridge could yield transfer theorems connecting cortical neural fields to network models of neural computation.

The pattern counting theorem also connects naturally to the Catalog's work on error-correcting codes (`ecoc_stable_under_flip_budget`) and tropical geometry (`tropicalMargin_stable_under_perturbation`): the 2l+1 pattern count can be reinterpreted as a coding-theoretic statement about the number of distinguishable cortical states, while the conformal factor's decay properties parallel the geometric power series decay established in `UltrametricKLDivergence.lean`. The highest breakthrough potential lies in Direction 1, which proposes using the spectral gap structure to prove nonlinear orbital stability — a result that would elevate the theory from linear pattern counting to genuine dynamical systems analysis.

---

### Direction 1: Nonlinear Orbital Stability of Spherical Harmonic Patterns

**Conjecture**: For the neural field equation ∂u/∂t = -u + ∫_{S²} K(d(x,y)) f(u(y)) dω(y) on S² with Mexican-hat kernel K of interaction radius r = 1/k, the 2k+1-dimensional manifold of degree-k spherical harmonic patterns is orbitally stable under the full nonlinear dynamics, provided the spectral gap Δλ = 2k satisfies Δλ > C·‖f'‖_∞ for an explicit constant C depending only on the kernel parameters.

**Test**: For k=1 (the simplest case with 3 patterns), numerically integrate the nonlinear neural field equation on S² with sigmoidal firing rate f(u) = 1/(1+exp(-βu)) and verify that initial conditions near the Y₁ᵐ spherical harmonics converge to the pattern manifold. Compute the basin of attraction radius as a function of β and compare with the predicted spectral gap condition Δλ = 2 > C/β.

**Impact**: This would be the first rigorous nonlinear stability result for neural field patterns on curved surfaces. It would establish that the linear pattern count (2k+1) extends to the nonlinear regime, confirming that representation-theoretic predictions have genuine dynamical content. Failure would indicate that nonlinear mode coupling destabilizes some patterns, reducing the effective pattern count below 2k+1.

**Catalog References**: `FINAL/MachineLearning/ViralInformationTopology.lean` (graph Laplacian kernel), `FINAL/MachineLearning/PadicChipFiring.lean` (Laplacian diagonal structure), `MachineLearning/InverseStereographicNeuralField.lean` (eigenvalue gap theorem)

**Proof Strategy**: 
1. Establish a Lyapunov functional using the mode energy E_l(a) = l(l+1)·a²·(2l+1) already defined.
2. Show that the spectral gap 2(l+1) between degree l and degree l+1 provides a separation between the selected mode and all competitor modes.
3. Use a center manifold reduction to project the infinite-dimensional dynamics onto the 2k+1-dimensional space of degree-k harmonics.
4. Apply LaSalle's invariance principle to show convergence to the pattern manifold.
Key lemma needed: mode_energy_Lyapunov showing dE/dt ≤ -c·E for modes outside the selected degree.

**Domain Bridges**: PDE Theory <-> Dynamical Systems, Representation Theory <-> Neural Field Theory

**Lineage**: Builds on `sphericalEigenvalue_S2_strictMono`, `eigenvalue_gap_S2`, and `modeEnergy_nonneg` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Discrete Cortical Graphs and Spectral Convergence

**Conjecture**: For a sequence of icosahedral mesh refinements {G_n} of S² with n vertices, the normalized graph Laplacian eigenvalues λ_k(G_n) converge to the Laplace-Beltrami eigenvalues k(k+1)/(n^{2/3}) as n → ∞, with convergence rate O(n^{-1/3}). The graph Laplacian kernel always contains the constant vector (a discrete version of the degree-0 spherical harmonic).

**Test**: Construct icosahedral meshes with n = 12, 42, 162, 642, 2562 vertices. Compute the first 10 eigenvalues of the normalized graph Laplacian. Plot the rescaled eigenvalues against l(l+1) and fit the convergence rate. Verify that the eigenvalue multiplicities converge to the predicted values (1, 3, 5, 7, ...).

**Impact**: This would provide a rigorous bridge between the continuous neural field theory on S² and discrete network models of cortical computation. It would validate using graph Laplacians (already studied in the Catalog for chip-firing and viral dynamics) as approximations to the cortical Laplace-Beltrami operator. If the convergence rate is worse than O(n^{-1/3}), it suggests that graph discretizations require mesh-dependent corrections to the Mexican-hat kernel.

**Catalog References**: `FINAL/MachineLearning/ViralInformationTopology.lean` (`laplacian_kernel_contains_const`), `FINAL/MachineLearning/PadicChipFiring.lean` (`laplacian_diag_eq_degree`)

**Proof Strategy**:
1. Define icosahedral mesh refinement formally as a sequence of SimpleGraphs on Fin n.
2. Prove that `laplacian_kernel_contains_const` (already in Catalog) gives the discrete analogue of the l=0 spherical harmonic.
3. Use Weyl's asymptotic law for graph Laplacians to establish eigenvalue convergence.
4. Key sub-result: prove that the spherical harmonic dimension formula d(2,l) = 2l+1 agrees with the multiplicity of the l-th cluster of graph eigenvalues for sufficiently fine meshes.

**Domain Bridges**: Graph Theory <-> Differential Geometry, Discrete Mathematics <-> PDE Theory

**Lineage**: Bridges `laplacian_kernel_contains_const` (Catalog) with `sphericalHarmonicDim_S2` (this cycle).

**Ambition**: extension

---

### Direction 3: Conformal Neural Fields and Hallucination Pattern Classification

**Conjecture**: The conformal decay exponent of a projected spherical harmonic pattern uniquely determines its spherical harmonic degree: if a neural activity pattern u(x) on R² satisfies |u(x)| ≤ C·|x|^{-α} for large |x| with optimal exponent α, then the pattern originated from a spherical harmonic of degree l = α/2, and the 2l+1 pattern count follows. Conversely, any pattern with non-integer α/2 cannot arise from the stereographic projection of a pure spherical harmonic mode.

**Test**: Generate synthetic neural field patterns by projecting spherical harmonics Y_l^m of degrees l = 1, 2, 3, 4, 5 via stereographic projection. Fit the decay exponent α from the tail behavior. Verify that α = 2l in all cases. Then construct superpositions of two different degrees and verify that the decay exponent reflects the lower degree (slower decay dominates).

**Impact**: This would provide a measurable biomarker for identifying the spherical harmonic degree of cortical instability patterns from planar recordings (e.g., EEG or optical imaging). It would connect the abstract representation-theoretic pattern count to observable neural signals, making the 2l+1 prediction empirically testable. If the decay exponent classification fails for realistic cortical geometries (non-spherical), it quantifies the correction needed for folded cortex.

**Catalog References**: `FINAL/MachineLearning/UltrametricKLDivergence.lean` (`geometric_power_series_decay`), `MachineLearning/InverseStereographicNeuralField.lean` (`projected_pattern_decay`, `conformalFactor_decay`)

**Proof Strategy**:
1. Strengthen `projected_pattern_decay` to a two-sided bound: c₁·2^l/r^{2l} ≤ σ(r²)^l ≤ c₂·2^l/r^{2l} for large r.
2. Prove that the decay exponent α = 2l is sharp (lower bound matching upper bound).
3. Use the uniqueness of the decay exponent to classify patterns by degree.
4. For superpositions, prove that the dominant decay term comes from the lowest-degree component.

**Domain Bridges**: Conformal Geometry <-> Signal Processing, Representation Theory <-> Neuroscience

**Lineage**: Directly extends `projected_pattern_decay` and `conformalFactor_decay` from this cycle. Connects to `geometric_power_series_decay` from the Catalog.

**Ambition**: extension

---

### Direction 4: Mexican-Hat Kernel Optimization on S^n

**Conjecture**: On S^n with n ≥ 2, the Mexican-hat kernel K(d) = exp(-d²/2σ_e²) - A·exp(-d²/2σ_i²) optimally selects degree l when the inhibitory scale σ_i satisfies σ_i/σ_e = √(λ_{l+1}/λ_l) = √((l+1)(l+n)/(l(l+n-1))). For n = 2, this gives σ_i/σ_e = √((l+2)/(l)), which approaches 1 as l → ∞, meaning finer patterns require increasingly matched excitatory and inhibitory scales.

**Test**: For n = 2 and l = 1, 2, 3, 5, 10, numerically compute the Fourier-Legendre coefficients of the Mexican-hat kernel on S² as a function of σ_i/σ_e. Identify the ratio that maximizes the coefficient at degree l relative to all other degrees. Compare with the predicted formula √((l+2)/l).

**Impact**: This would provide a design principle for neural connectivity: given a desired pattern complexity (degree l), the optimal kernel parameters are determined by the eigenvalue structure. For S^2, the general dimension formula d(n,l) = C(n+l,n) - C(n+l-2,n) gives pattern counts in any dimension, and the optimization formula connects these counts to concrete kernel parameters.

**Catalog References**: `MachineLearning/InverseStereographicNeuralField.lean` (eigenvalue and dimension formulas for general n)

**Proof Strategy**:
1. Compute the Fourier-Legendre expansion K_l = ∫ K(d(x,y)) P_l(cos d) dω of the Mexican-hat kernel.
2. Show that K_l is maximized at degree l when the Gaussian widths satisfy the predicted ratio.
3. Prove selectivity: |K_l|/|K_{l±1}| → ∞ as the kernel is tuned to degree l.
4. Key lemma: use `sphericalEigenvalue_S2_strictMono` to establish that the Gaussian decay preferentially suppresses higher eigenvalues.

**Domain Bridges**: Optimization <-> Spectral Theory, Neural Engineering <-> Representation Theory

**Lineage**: Extends the eigenvalue structure results (`sphericalEigenvalue_S2`, `eigenvalue_gap_S2`) from this cycle.

**Ambition**: extension

---

### Direction 5: Cortical Pattern Codes and Error-Correcting Capacity

**Conjecture**: The 2l+1 spherical harmonic patterns of degree l on S² form a neural error-correcting code with minimum angular distance d_min = π/(l+1) between any two patterns' peak locations. The code rate is R = log₂(2l+1) / log₂(4π/(d_min)²), and this approaches the sphere-packing bound as l → ∞. Under noise of angular radius ε < d_min/2, the maximum-likelihood decoder correctly identifies all 2l+1 patterns.

**Test**: For l = 1 (3 patterns on S²), compute the angular distance between the three degree-1 spherical harmonics' peak orientations (which form an orthogonal frame). Verify d_min = π/2 and that the error-correcting radius is π/4. Repeat for l = 2 (5 patterns) and verify the predicted distances.

**Impact**: This would connect neural pattern formation to coding theory, showing that the brain's cortical patterns naturally form near-optimal spherical codes. The connection to `ecoc_stable_under_flip_budget` in the Catalog would establish that the same error-correction principles governing machine learning classifiers also govern cortical representations. If the code rate falls short of the sphere-packing bound, it quantifies the efficiency loss from the SO(3) symmetry constraint.

**Catalog References**: `FINAL/MachineLearning/ECOCRobustness.lean` (`ecoc_stable_under_flip_budget`), `FINAL/MachineLearning/ClosureNetworks.lean` (`ecoc_stable_under_flip_budget`)

**Proof Strategy**:
1. Define the angular distance between two spherical harmonics via their correlation on S².
2. Use orthogonality of spherical harmonics (different m values within the same l) to establish minimum distances.
3. Prove that the decoder based on maximum correlation correctly identifies patterns when noise is below d_min/2.
4. Compare the code rate with the sphere-packing bound using `total_harmonics_S2` for asymptotic analysis.

**Domain Bridges**: Coding Theory <-> Neural Field Theory, Machine Learning <-> Differential Geometry

**Lineage**: Bridges `ecoc_stable_under_flip_budget` (Catalog) with `mexican_hat_conjecture` and `patternCount_odd` from this cycle. Connects the "odd pattern count" observation to error-correction parity constraints.

**Ambition**: grand_challenge
