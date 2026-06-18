# Future Directions: Inverse Stereographic Neural Field Theory

## Synthesis

This cycle established the mathematical foundations of neural field theory on S² via inverse stereographic projection, producing a complete formal verification of the conformal weight properties, the spherical harmonic multiplicity formula 2l+1, and the pattern counting theorem for Mexican-hat kernels. The most significant discovery is the tight connection between representation theory of SO(3) and neural pattern counting: the number of stable patterns is not a dynamical accident but a forced consequence of the symmetry group of the sphere.

The most promising cross-domain connection is between **differential geometry** (conformal weights, Laplace-Beltrami operators) and **representation theory** (SO(3) irreducible representations, Casimir operators), mediated by the concrete structure of neural field equations. This bridge already exists in mathematical physics (e.g., quantum mechanics on the sphere), but its application to neuroscience is novel and opens significant territory. The Casimir relation λ_l = (l + 1/2)² - 1/4, which we proved, suggests a deep analogy between neural pattern formation and quantum angular momentum — an analogy that could yield new tools for both fields.

The highest breakthrough potential lies in Direction 1 (nonlinear stability), because it would turn our pattern *counting* theorem into a pattern *classification* theorem — not just how many patterns exist, but which ones actually appear in biological neural fields. This requires going beyond linear analysis to energy methods and Lyapunov theory on the sphere, connecting to the Yamabe problem in geometric analysis.

---

### Direction 1: Nonlinear Stability of Spherical Neural Patterns

**Conjecture**: Among the 2N+1 pattern solutions selected by a Mexican-hat kernel of degree N on S², exactly N+1 are nonlinearly stable (the zonal harmonics Y_l^0 and the N pairs related by π/2 rotations). The remaining N patterns are saddle points of the neural field energy functional.

**Test**: Construct the energy functional E[u] = ∫_{S²} [½|∇u|² - F(u)] dA in stereographic coordinates, compute its Hessian at each of the 2N+1 critical points, and verify that exactly N+1 have all-positive Hessian eigenvalues. For N=1, this means 2 of 3 patterns are stable; for N=2, 3 of 5.

**Impact**: If true, this provides a selection mechanism that reduces the exponentially many potential patterns to a polynomial number of observable ones. This would explain why Klüver's form constants are so limited — only a handful of the mathematically possible patterns are dynamically accessible. If false, the failure reveals that nonlinear interactions create unexpected stable configurations, possibly explaining rare or atypical hallucination geometries.

**Catalog References**: `Catalog/Geometry/InverseStereoUniverse.lean` (conformal factor properties), `Catalog/Geometry/AdvancedTheory.lean` (stereo kernel symmetry, Jacobian formulas)

**Proof Strategy**: 
1. Define the energy functional on S² using the Jacobian identity σ²·(1+r²)² = 4 from our `conformal_laplacian_identity`.
2. Compute the second variation at a spherical harmonic pattern Y_N^m using the eigenvalue formula λ_l = l(l+1) from `eigenvalue_formula`.
3. Show the Hessian matrix in the basis {Y_l^m} is diagonal with entries depending on (w_l - w_N)·(λ_l - λ_N).
4. Use the strict peak condition from `MexicanHatKernel.peak_is_max` to determine the sign of each diagonal entry.
5. The zonal case m=0 requires separate treatment using Legendre polynomial integrals.

**Domain Bridges**: Geometry <-> Analysis, Representation Theory <-> Dynamical Systems

**Lineage**: Builds on `conformal_weight_pos`, `conformal_weight_mono`, `eigenvalue_mono`, `pattern_count_formula` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Higher-Dimensional Spherical Neural Fields (S³ and Beyond)

**Conjecture**: On S^n, a Mexican-hat kernel with peak at degree l selects exactly dim(V_l^{SO(n+1)}) patterns, where V_l is the l-th irreducible representation of SO(n+1). For n=3, this gives (l+1)² patterns (the dimension of the spin-l representation of SO(4) ≅ SU(2) × SU(2)).

**Test**: Compute the dimension formula for irreducible representations of SO(4) and verify that the predicted pattern count for S³ with l=1 is 4 (not 3 as on S²). Implement the S³ neural field in stereographic coordinates on ℝ³ and count steady-state patterns numerically.

**Impact**: If true, this provides a unified pattern-counting framework valid in any dimension, with applications to high-dimensional neural network architectures (where "neurons" live on high-dimensional spheres in weight space). The transition from 2l+1 on S² to (l+1)² on S³ reveals how curvature dimension affects pattern diversity.

**Catalog References**: `Catalog/Geometry/InverseStereoUniverse.lean` (n-dimensional conformal factor), `Catalog/Geometry/AdvancedTheory.lean` (invStereoN_injective for n-dimensional projection)

**Proof Strategy**:
1. Generalize `conformalWeight` to arbitrary n (already done as `conformalWeight n r_sq`).
2. Use the Weyl dimension formula for SO(n+1) representations: dim(V_l) = ∏_{1≤i<j≤⌊(n+1)/2⌋} (l_i - l_j + j - i)/(j - i) for the highest weight (l, 0, ..., 0).
3. Verify the formula reduces to 2l+1 for n=2 (SO(3)) using `harmonic_poly_dim_3d`.
4. For n=3: dim = (l+1)² via the isomorphism SO(4) ≅ (SU(2)×SU(2))/ℤ₂.
5. Formalize the n-dimensional Mexican-hat kernel using the Gegenbauer polynomial expansion.

**Domain Bridges**: Geometry <-> Representation Theory, Neuroscience <-> Machine Learning

**Lineage**: Builds on `conformalWeight`, `sphericalHarmonicMultiplicity`, `total_harmonics_sum` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Spectral Rigidity of the Mexican-Hat Kernel

**Conjecture**: The Mexican-hat kernel (difference of Gaussians) on S² with parameters (σ_e, σ_i) has peak degree N = ⌊π/(σ_i - σ_e)⌋ when σ_e < σ_i. Moreover, there exists a critical ratio σ_i/σ_e = φ (the golden ratio) at which two adjacent modes have equal strength, producing a degenerate bifurcation with (2N+1) + (2N+3) = 4N+4 simultaneous patterns.

**Test**: Numerically compute the Legendre coefficients of exp(-γ²/2σ_e²) - exp(-γ²/2σ_i²) on S² for σ_i/σ_e ranging from 1.1 to 3.0 and locate the ratio at which consecutive coefficients are equal. Check whether this ratio is close to φ ≈ 1.618.

**Impact**: If the golden ratio appears, it would establish a deep connection between the aesthetics of neural patterns and number theory. If the critical ratio is not φ but some other algebraic number, characterizing it exactly would still be valuable — it would define the bifurcation locus in parameter space and predict when the brain transitions between different pattern regimes.

**Catalog References**: `Catalog/Algebra/SpectralContractionAlgebra.lean` (geometric decay bounds), `Catalog/Geometry/AdvancedTheory.lean` (Descartes form, spectral properties)

**Proof Strategy**:
1. Compute the Legendre coefficients w_l = ∫₀^π [exp(-γ²/2σ_e²) - exp(-γ²/2σ_i²)] P_l(cos γ) sin γ dγ in closed form using Mehler's integral.
2. Find the peak by solving dw_l/dl = 0 (treating l as continuous).
3. Analyze the degeneracy condition w_N = w_{N+1} as a transcendental equation in σ_i/σ_e.
4. Use the asymptotic expansion of Legendre coefficients for large l to approximate the solution.

**Domain Bridges**: Geometry <-> Number Theory, Analysis <-> Neuroscience

**Lineage**: Builds on `MexicanHatKernel.peak_is_max`, `pattern_count_formula` from this cycle.

**Ambition**: extension

---

### Direction 4: Stereographic Neural Fields on Hyperbolic Space

**Conjecture**: On the hyperbolic plane ℍ², the Mexican-hat kernel produces a continuous spectrum of patterns (not discrete), but with a spectral gap determined by the curvature κ < 0. Specifically, patterns exist only for spatial frequencies ω > |κ|^{1/2}, and the pattern density (per unit frequency) diverges at ω = |κ|^{1/2}.

**Test**: Discretize the Poincaré disk model of ℍ² (which is itself a stereographic projection), implement the neural field equation with Mexican-hat kernel, and measure the power spectrum of steady-state patterns as a function of spatial frequency. Compare against the predicted spectral edge at |κ|^{1/2}.

**Impact**: This would complete the trichotomy: S² (positive curvature) → discrete patterns, ℝ² (zero curvature) → continuous patterns, ℍ² (negative curvature) → continuous with gap. This unification through curvature sign could provide insights into pattern formation on general Riemannian manifolds and connects to the spectral theory of the Laplacian on negatively curved spaces (a major area in mathematical physics and number theory via Selberg's trace formula).

**Catalog References**: `Catalog/Geometry/InverseStereoUniverse.lean` (stereographic framework), `Catalog/Geometry/GapMatterResearch.lean` (spectral gap analysis)

**Proof Strategy**:
1. Define the conformal factor for the Poincaré disk: σ_ℍ = 2/(1 - |x|²) (note the minus sign vs. plus sign for S²).
2. Show that σ_ℍ diverges at |x| = 1 (boundary of the disk = "point at infinity" of ℍ²).
3. Analyze the Laplace-Beltrami spectrum on ℍ²: continuous spectrum [1/4, ∞) with spectral gap 1/4 = |κ|/4.
4. Show the Mexican-hat kernel on ℍ² selects a band of frequencies rather than a single degree.

**Domain Bridges**: Geometry <-> Number Theory (Selberg), Neuroscience <-> Mathematical Physics

**Lineage**: Builds on `conformalFactor2D`, `conformal_factor_decay`, `eigenvalue_formula` from this cycle.

**Ambition**: extension

---

### Direction 5: Time-Dependent Patterns and Rotating Waves on S²

**Conjecture**: The time-dependent neural field equation on S² with Mexican-hat kernel admits rotating wave solutions that are spherical harmonics modulated by a phase factor: u(θ, φ, t) = Y_N^m(θ, φ) · cos(ωt - mφ). The rotation frequency ω = m · c(N) where c(N) depends only on the kernel and activation function, not on m. These rotating waves correspond, under stereographic projection, to spiraling patterns on ℝ² with angular velocity ω/m = c(N).

**Test**: Simulate the time-dependent neural field PDE on a stereographic grid with initial conditions close to Y_2^1 and Y_2^2. Measure the angular velocities of the resulting rotating patterns and verify that ω₁/1 = ω₂/2 (both equal to c(2)).

**Impact**: Rotating waves on S² would provide a geometric explanation for the rotational dynamics observed in many visual hallucinations (rotating spirals, expanding/contracting tunnels). The prediction that angular velocity scales as ω = m·c(N) is specific and falsifiable. If confirmed, it provides the first quantitative prediction of hallucination dynamics from geometric principles.

**Catalog References**: `Catalog/Geometry/AdvancedTheory.lean` (stereo kernel, chordal distance), `Catalog/Geometry/InverseStereoUniverse.lean` (conformal factor dynamics)

**Proof Strategy**:
1. Substitute the rotating wave ansatz u = Y_N^m · e^{iωt} into the time-dependent neural field equation.
2. The Laplace-Beltrami eigenvalue λ_N = N(N+1) determines the spatial part.
3. The azimuthal quantum number m enters through the φ-dependence of Y_N^m.
4. The frequency ω is determined by a dispersion relation involving the kernel coefficients w_N and the activation slope f'(u*).
5. Show that the dispersion relation is linear in m: ω = m · [f'(u*) · w_N - 1/τ].

**Domain Bridges**: Geometry <-> Dynamical Systems, Neuroscience <-> Wave Physics

**Lineage**: Builds on `conformal_factor_2d_on_unit_circle`, `eigenvalue_casimir_relation`, `pattern_count_formula` from this cycle.

**Ambition**: extension
