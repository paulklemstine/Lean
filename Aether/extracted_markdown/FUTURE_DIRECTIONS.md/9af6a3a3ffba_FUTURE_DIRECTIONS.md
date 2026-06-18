# Future Research Directions: Tropical Orbit Shadowing and Certified Dynamics

## Synthesis

This research cycle established a comprehensive formal foundation for orbit shadowing in non-autonomous and tropical dynamical systems. The central achievement is the **variable-rate inductive bound** (Theorem `NA.variable_rate_bound`), which generalizes the classical contractive shadowing lemma to systems with time-varying Lipschitz constants. The accumulated product formula e_n ≤ δ · Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L_j captures precisely how errors interact through varying contraction rates — a result that has no direct precedent in the formal mathematics literature. The uniform contractive shadowing theorem (`NA.uniform_contractive_shadowing`) recovers the autonomous δ/(1−L) bound as a special case, validating the generalization.

The most promising cross-domain bridge connects **tropical spectral theory** to **certified computation**. We proved that max-plus matrix-vector multiplication is 1-Lipschitz (non-expansive) in the supremum metric (`tropMV_component_nonexpansive`), and developed a certificate composition framework (`TropicalShadowingCertificate.compose_radius_bound`) that enables modular verification. The missing link is the **Birkhoff contraction theorem**: proving that scrambling tropical matrices contract the oscillation seminorm would complete the bridge from tropical spectral gaps to certified shadowing radii. The Catalog's existing tropical matrix theory (`Tropical/OrbitComplexity.lean`, `Tropical/SpectralTheory.lean`) provides algebraic foundations, while the orbit shadowing theory (`MachineLearning/Shadowing/OrbitShadowingDeep.lean`) provides the dynamical framework. Direction 1 (Birkhoff contraction) has the highest breakthrough potential because it would unify three established mathematical theories in a single formal proof.

The defect triangle inequality and certificate composition results open a practical path toward **streaming certified computation** (Direction 3), where shadowing guarantees are maintained incrementally as computation proceeds. The non-autonomous framework is the correct mathematical setting for adaptive algorithms, and formalizing the connection to specific optimization algorithms (Direction 2) would yield the first formally verified convergence rates for SGD with learning rate schedules.

---

### Direction 1: Birkhoff Contraction Theorem for Tropical Matrices

**Conjecture**: For any n × n tropical matrix A that is "scrambling" (for every pair of rows i₁, i₂, there exists a column j such that both A_{i₁,j} and A_{i₂,j} are finite), the oscillation osc(x) = max(x) − min(x) contracts under tropical multiplication:

osc(A ⊗ x) ≤ τ(A) · osc(x)

where τ(A) = tanh(diam(A)/4) < 1 and diam(A) = max_{i,j,k}(A_{ij} − A_{ik}).

**Test**: For the 3×3 matrix A = [[0, −1, −2], [−2, 0, −1], [−1, −2, 0]], compute τ(A) theoretically (diam = 2, so τ = tanh(1/2) ≈ 0.462) and verify computationally that osc(A ⊗ x)/osc(x) ≤ 0.462 for 10,000 random vectors x ∈ ℝ³. If any counterexample is found, the conjecture is falsified.

**Impact**: If true, this would complete the tropical-shadowing bridge: tropical matrices with spectral gaps would automatically yield contractive dynamics with certified shadowing radii. This would enable fully automated shadowing certificate construction from tropical spectral data. If false, it would reveal that Birkhoff contraction requires stronger conditions than scrambling.

**Catalog References**: `Tropical/OrbitComplexity.lean` (tropical matrix powers), `Tropical/SpectralTheory.lean` (cycle gap spectral bound), `MachineLearning/Shadowing/OrbitShadowingDeep.lean` (contractive shadowing)

**Proof Strategy**: 
1. Define the oscillation seminorm osc(x) = sup(x) − inf(x) on ℝⁿ
2. Show osc is a seminorm (subadditivity, positive homogeneity)  
3. Define the Hilbert projective metric d_H(x,y) = max_i(x_i − y_i) − min_i(x_i − y_i)
4. Show tropical linear maps are non-expansive in d_H
5. Show scrambling ⟹ strict contraction by constructing a coupling argument
6. Extract τ(A) = tanh(diam(A)/4) via the Bushell-Birkhoff analysis
Key lemma: the coupling step (5) requires showing that max_j min_i A_{ij} > −∞.

**Domain Bridges**: Tropical algebra <-> Contraction mapping theory <-> Certified computation

**Lineage**: Builds on `tropMV_component_nonexpansive` (this cycle) and `cycle_gap_spectral_bound_at` from `Tropical/SpectralTheory.lean`

**Ambition**: grand_challenge

---

### Direction 2: Non-Autonomous Shadowing for SGD with Learning Rate Schedules

**Conjecture**: For SGD with cosine annealing schedule η_t = η₀ · (1 + cos(πt/T))/2 on a μ-strongly convex, β-smooth function, the variable-rate shadowing bound gives:

tracking_error(t) ≤ σ · Σ_{k=0}^{t-1} Π_{j=k+1}^{t-1} |1 − η_j · μ|

which is strictly tighter than the autonomous bound σ/(1 − |1 − η₀·μ|) for all T > 1.

**Test**: Compute both bounds numerically for μ = 1, β = 10, η₀ = 0.1, T = 100, σ = 0.01, and verify the non-autonomous bound is at least 10% tighter at t = T/2. The autonomous bound uses L = max_t |1 − η_t · μ|.

**Impact**: If true, this provides the first formally verified convergence rate for SGD with learning rate schedules that is strictly tighter than treating the schedule as worst-case. This bridges the gap between theoretical optimization (which assumes constant step size) and practical deep learning (which always uses schedules).

**Catalog References**: `MachineLearning/Shadowing/OrbitShadowingDeep.lean` (GradientSystem structure), `Tropical/TropicalOrbitShadowing.lean` (non-autonomous framework)

**Proof Strategy**:
1. Define GradientSystem with time-varying step as a non-autonomous system
2. Compute L_t = |1 − η_t · μ| for cosine annealing
3. Apply `NA.variable_rate_bound` to get the accumulated product bound
4. Show the accumulated product bound is strictly less than the geometric series bound
5. The key step is showing that when η_t varies, the product Π L_j averages below max L_j
Use the AM-GM inequality on logarithms: Σ log(L_j) < n · log(max L_j) when not all L_j are equal.

**Domain Bridges**: Optimization <-> Non-autonomous dynamics <-> Formal verification

**Lineage**: Builds on `NA.variable_rate_bound` and `NA.uniform_contractive_shadowing` (this cycle)

**Ambition**: extension

---

### Direction 3: Streaming Shadowing Certificates with Adaptive Windows

**Conjecture**: There exists an online algorithm that maintains a shadowing certificate with window size W, processing one orbit point per step in O(W) time, such that the certified radius never exceeds 2 · δ/(1−L) (twice the offline optimal), where L is the contraction constant and δ is the per-step error.

**Test**: Implement the streaming algorithm for the system f(x) = 0.7x on ℝ with δ = 0.1. Run for 10,000 steps and verify that (1) the maintained certificate is always valid (the shadowing defect never exceeds the certified radius), and (2) the certified radius is always ≤ 2 · 0.1/0.3 ≈ 0.667.

**Impact**: If true, this enables real-time certified computation for autonomous systems, robotics, and embedded control. The 2× overhead is a small price for online operation. If false, it reveals a fundamental barrier to online certification.

**Catalog References**: `MachineLearning/Shadowing/OrbitShadowingDeep.lean` (DS.ComposedCertificate, DS.shadowingDefect), `Tropical/TropicalOrbitShadowing.lean` (TropicalShadowingCertificate)

**Proof Strategy**:
1. Define a sliding window certificate that drops the oldest point and adds the newest
2. Show the defect over any window of size W is bounded by δ · W · L^{W-1}/(1-L) (geometric decay makes old errors irrelevant)
3. Choose W = O(log(1/ε) / log(1/L)) to achieve ε-closeness to the infinite-horizon bound
4. The 2× overhead comes from the transition between windows
Key lemma: defect monotonicity — the defect over [k, k+W] is bounded by the defect over [0, k+W].

**Domain Bridges**: Online algorithms <-> Dynamical systems <-> Embedded systems verification

**Lineage**: Builds on `ShadowDS.defect_triangle` (this cycle) and `DS.orbit_shift_defect_bound` from OrbitShadowingDeep.lean

**Ambition**: extension

---

### Direction 4: Hyperbolic Shadowing via Stable/Unstable Decomposition

**Conjecture**: For a linear hyperbolic map T : ℝⁿ → ℝⁿ with eigenvalues satisfying |λᵢ| ≠ 1 for all i, every δ-pseudo-orbit is ε-shadowed with ε = δ · max(1/(1−L_s), 1/(L_u−1)) where L_s = max{|λ| : |λ| < 1} and L_u = min{|λ| : |λ| > 1}.

**Test**: For T = diag(0.5, 2.0) on ℝ², generate a δ-pseudo-orbit with δ = 0.1 for 1000 steps. Verify that the shadowing distance converges to ≤ 0.1 · max(1/0.5, 1/1.0) = 0.2. The stable direction contributes 1/(1−0.5) = 2 and the unstable direction contributes 1/(2−1) = 1.

**Impact**: If true, this would be the first formal proof of the linear case of the Anosov-Bowen shadowing theorem, a grand challenge in formal mathematics. It would establish the mathematical infrastructure (stable/unstable splittings, adapted norms) needed for the full nonlinear theorem.

**Catalog References**: `MachineLearning/Shadowing/OrbitShadowingDeep.lean` (DS.contractive_shadowing for the stable part), `Tropical/TropicalOrbitShadowing.lean` (NA.variable_rate_bound for the general framework)

**Proof Strategy**:
1. Decompose ℝⁿ = E_s ⊕ E_u into stable and unstable subspaces
2. Project the pseudo-orbit onto each subspace
3. Apply contractive shadowing forward on E_s (L_s < 1)
4. Apply contractive shadowing **backward** on E_u (L_u⁻¹ < 1)
5. Combine using the uniqueness of the shadow in each subspace
Key challenge: the backward shadowing construction requires choosing the initial point of the shadow orbit to ensure the unstable component stays bounded. This is where the hyperbolicity condition is essential.

**Domain Bridges**: Hyperbolic dynamics <-> Linear algebra (spectral theory) <-> Tropical dynamics (tropical eigenvalues as limits)

**Lineage**: Builds on `NA.variable_rate_bound` and `ShadowDS.iterate_dist_fixed_point_bound` (this cycle)

**Ambition**: grand_challenge

---

### Direction 5: Tropical Entropy and Shadowing Radius Duality

**Conjecture**: For a tropical matrix A with spectral radius ρ(A), the normalized orbit entropy h(A) = lim_{n→∞} (1/n) log |{normalized A^⊗n : distinct}| satisfies:

h(A) = 0 if and only if the Birkhoff contraction coefficient τ(A) < 1

In other words, zero orbit entropy is equivalent to the existence of a finite shadowing radius for the centered tropical dynamics.

**Test**: For the family of matrices A_t = [[0, t, 2t], [2t, 0, t], [t, 2t, 0]] with parameter t ∈ {0.1, 0.5, 1.0, 2.0, 5.0}, compute both h(A_t) (by counting distinct normalized powers up to n = 100) and τ(A_t) (by computing max osc(A_t ⊗ x)/osc(x) over 1000 random x). Verify that h = 0 ↔ τ < 1.

**Impact**: If true, this establishes a deep duality between information-theoretic complexity (entropy) and metric dynamics (shadowing). It would mean that orbit complexity in tropical systems is entirely determined by contraction — a profound structural result. If false, it reveals orbit systems that are metrically well-behaved but informationally complex, or vice versa.

**Catalog References**: `Tropical/OrbitComplexity.lean` (orbit_card_bound_of_box_bound, orbit_entropy_upper_bound_zero), `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at), `Tropical/TropicalInformationRichness.lean` (uniform_entropy_bound)

**Proof Strategy**:
1. (⟹) If τ < 1, normalized orbits lie in a ball of radius C/(1−τ), hence in a finite lattice, hence h = 0. Use `orbit_card_bound_of_box_bound` from OrbitComplexity.lean.
2. (⟸) If h = 0, the orbit visits finitely many states, hence must eventually be periodic. Periodicity of tropical powers implies the normalized power is bounded, which implies contraction in oscillation.
Key lemma: periodicity of tropical powers implies a coupling structure (every row pair eventually couples through some column under iteration).

**Domain Bridges**: Information theory (entropy) <-> Tropical algebra (spectral radius) <-> Dynamical systems (shadowing)

**Lineage**: Builds on `tropMV_component_nonexpansive` (this cycle) and `orbit_card_bound_of_box_bound` from `Tropical/OrbitComplexity.lean`

**Ambition**: grand_challenge
