# Future Directions: Split Geometry and Information-Geometric Bridges

## Synthesis

This research cycle established *split geometry* as a rigorously formalized Riemannian geometry on ℝ² with the conformally flat metric g = diag(sech²(x), sech²(y)) and Gaussian curvature K(x,y) = sech²(x) − sech²(y). The formalization in Lean 4 achieved zero sorry statements across three files (≈440 lines), proving curvature bounds, complete phase characterization, a discrete Gauss-Bonnet theorem, and information-geometric divergence properties. The novel *curvature spectrum* formalism—encoding finite point configurations as antisymmetric matrices—bridges discrete and continuous geometry and connects to spectral theory.

The most promising cross-domain connection from this cycle is the link between split geometry and **statistical learning theory** via Fisher information geometry. The split divergence satisfies a quasi-triangle inequality (factor 2), and the curvature variance bound (Var_K ≤ 1) mirrors PAC-learning-style uniform convergence bounds. This suggests that curvature bounds in Riemannian geometry can be translated into convergence guarantees for optimization algorithms, with the curvature spectrum playing the role of a feature kernel matrix. The existing Catalog bridge `Bridges/WeightedVariance.lean` already establishes weighted variance bounds that could be composed with the curvature variance bound to yield cross-domain transfer theorems.

The highest breakthrough potential lies in Direction 1 (Geodesic Dynamics), which would connect the phase structure to dynamical systems theory and provide explicit solutions to the geodesic equation in a mixed-curvature surface—a rare achievement in Riemannian geometry. Direction 2 (Gauss-Bonnet Integration) would produce the first formally verified Gauss-Bonnet theorem for a non-trivial surface, bridging differential geometry and algebraic topology in the Catalog.

---

### Direction 1: Geodesic Dynamics in Split Geometry

**Conjecture**: Every geodesic of the split metric that starts in the elliptic region (|x| < |y|) with velocity component vₓ > 0 crosses the phase boundary |x| = |y| in finite time. Moreover, the crossing time T satisfies T ≤ C · cosh(y₀) for some universal constant C, where y₀ is the initial y-coordinate.

**Test**: Numerically integrate the geodesic equation ẍ + Γ¹₁₁ ẋ² = 0, ÿ + Γ²₂₂ ẏ² = 0 (where the Christoffel symbols are Γ¹₁₁ = −tanh(x), Γ²₂₂ = −tanh(y)) starting from (0, 2) with initial velocity (1, 0). The geodesic should cross x = y at a finite time. Plot crossing time vs. initial y₀ for y₀ ∈ [0.1, 10] and verify the linear-in-cosh(y₀) bound.

**Impact**: If true, this proves that the phase boundary is *dynamically accessible*—no geodesic can be permanently trapped in a single phase region. This has implications for optimization: gradient descent trajectories on the split-metric loss landscape must eventually encounter flat directions, preventing indefinite descent into curvature traps. If false, the existence of trapped geodesics would reveal invariant manifolds with surprising topological structure.

**Catalog References**: `Bridges/SplitGeometry/Core.lean` (splitCurvature, anisotropyRatio), `Bridges/SplitGeometry/PhaseStructure.lean` (phase classification)

**Proof Strategy**: 
1. Derive the Christoffel symbols Γ¹₁₁ = −tanh(x), Γ²₂₂ = −tanh(y) from the metric.
2. Show the geodesic equation admits a conserved energy E = sech²(x)ẋ² + sech²(y)ẏ².
3. Use the energy conservation to bound the x-velocity from below in the elliptic region.
4. Integrate the velocity bound to get a finite crossing time.

**Domain Bridges**: Geometry <-> Physics, Geometry <-> MachineLearning

**Lineage**: Builds on splitCurvature_pos_of_abs_lt (phase sign theorem) and anisotropyRatio_reciprocal (incompressibility) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Gauss-Bonnet Integration for Split Geometry

**Conjecture**: For the split metric on the disk B_R of radius R centered at the origin, the integrated Gaussian curvature satisfies:

∫∫_{B_R} K · √det(g) dx dy = 0

for all R > 0. That is, the total curvature of any centered disk vanishes exactly, not just in the R → ∞ limit.

**Test**: Numerically integrate K(x,y) · sech(x) · sech(y) over the disk x² + y² ≤ R² for R = 1, 2, 5, 10. Each integral should be zero to machine precision. This is stronger than the concentration conjecture (which only claims the signed area fraction → 1/2) because it asserts exact cancellation for finite regions with circular symmetry.

**Impact**: If true, this would be a Gauss-Bonnet-type theorem for split geometry, asserting that the topology of the disk (Euler characteristic χ = 1) and the geodesic curvature of the boundary conspire to make the interior curvature integral vanish. This would be the first formally verified Gauss-Bonnet computation for a non-trivially curved surface. If false, the deviation from zero would encode the geodesic curvature of the circular boundary under the split metric—still interesting.

**Catalog References**: `Bridges/SplitGeometry/Core.lean` (splitCurvature, splitAreaElement), `Bridges/SplitGeometry/PhaseStructure.lean` (discrete_gauss_bonnet)

**Proof Strategy**:
1. Convert to polar-like coordinates (r, θ) and use the antisymmetry K(x,y) = −K(y,x).
2. For the centered disk, the change of variables (x,y) ↦ (y,x) maps B_R to itself and negates K while preserving the area element.
3. This symmetry argument shows ∫∫ K dA = −∫∫ K dA = 0.
4. Formalize the change-of-variables argument in Lean using Mathlib's measure theory.

**Domain Bridges**: Geometry <-> Algebra (topology), Bridges <-> EML

**Lineage**: Builds on splitCurvature_antisymm, splitAreaElement_pos, and curvatureSpectrum_total_zero from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Curvature Spectrum Eigenvalue Distribution

**Conjecture**: For n points uniformly distributed in [−R, R], the empirical spectral distribution of the curvature spectrum matrix S (rescaled by 1/n) converges to a semicircular distribution as n → ∞ with R fixed. Specifically, the largest eigenvalue λ_max satisfies λ_max / n → c(R) where c(R) = (2/π) ∫₀ᴿ sech²(t) dt.

**Test**: For R = 3 and n = 50, 100, 200, 500, compute the curvature spectrum of n uniformly spaced points, find eigenvalues (the matrix is real antisymmetric, so eigenvalues are purely imaginary), and plot the histogram of |λ|/n. Check convergence of |λ_max|/n to c(3) ≈ 0.632.

**Impact**: If true, this connects split geometry to random matrix theory, specifically the Wigner semicircle law for antisymmetric matrices. The function c(R) would serve as a *curvature capacity* measuring how much geometric information a finite sample captures. If false, the deviation from semicircular behavior would indicate non-universality of the spectral distribution due to the structured (non-random) nature of the curvature spectrum.

**Catalog References**: `Bridges/SplitGeometry/InfoGeometry.lean` (curvatureSpectrum, spectral_frobenius_bound), `Bridges/WeightedVariance.lean` (weighted_var_cross_domain_bound)

**Proof Strategy**:
1. Establish the moment method: compute E[tr(S^{2k})] for the uniform distribution.
2. Use the curvature sum decomposition (splitCurvature_sum_eq) to reduce moments to integrals of sech² products.
3. Show the limiting moments match the semicircle moments via dominated convergence.
4. Apply the method of moments to conclude weak convergence.

**Domain Bridges**: Geometry <-> EML (spectral theory), Bridges <-> Algebra (random matrices)

**Lineage**: Builds on curvatureSpectrum_total_zero and spectral_frobenius_bound from this cycle.

**Ambition**: extension

---

### Direction 4: Split Metric as Fisher Information for Exponential Families

**Conjecture**: Define the split exponential family as the set of probability distributions on ℝ² with density p(t; x, y) ∝ exp(−x · cosh(t₁) − y · cosh(t₂)). Then the Fisher information metric of this family, restricted to the parameter space (x, y) ∈ (0, ∞)², is proportional to the split metric diag(sech²(x), sech²(y)) up to a global conformal factor.

**Test**: Compute the Fisher information matrix Iᵢⱼ = E[∂ᵢ log p · ∂ⱼ log p] symbolically for the split exponential family. Verify that I₁₂ = I₂₁ = 0 (diagonal metric) and that I₁₁/I₂₂ = sech²(x)/sech²(y) for 10 randomly chosen parameter values.

**Impact**: If true, this provides a canonical statistical interpretation of split geometry: every theorem about curvature becomes a theorem about statistical efficiency, and every theorem about divergence becomes a theorem about hypothesis testing. The curvature bound |K| ≤ 1 would translate to a uniform bound on the statistical curvature, controlling the Cramér-Rao lower bound. If false, characterizing which exponential families do produce the split metric would constrain the geometric-statistical dictionary.

**Catalog References**: `Bridges/SplitGeometry/InfoGeometry.lean` (splitDivergence, curvatureVariance_le_one), `Bridges/ArithmeticLearningTheory/Core.lean` (height_computation_bound)

**Proof Strategy**:
1. Write the normalizing constant Z(x,y) = ∫∫ exp(−x cosh(t₁) − y cosh(t₂)) dt₁ dt₂.
2. Factor as Z(x,y) = Z₁(x) · Z₂(y) where Zₖ(u) = ∫ exp(−u cosh(t)) dt = 2K₀(u) (modified Bessel function).
3. Compute I₁₁ = ∂²log Z / ∂x² = −Z₁''/Z₁ + (Z₁'/Z₁)².
4. Use asymptotic properties of K₀ to relate I₁₁ to sech²(x).

**Domain Bridges**: Geometry <-> MachineLearning (information geometry), Bridges <-> Computation

**Lineage**: Builds on splitDivergence_quasi_triangle and curvature_divergence_bound from this cycle.

**Ambition**: extension

---

### Direction 5: Curvature Flow Convergence and Stability

**Conjecture**: The split curvature flow ∂f/∂t = Δ_split f, where Δ_split = sech²(x)∂²/∂x² + sech²(y)∂²/∂y², satisfies a Poincaré inequality: for f with ∫∫ f · dA = 0,

∫∫ |∇_split f|² dA ≥ λ₁ · ∫∫ f² dA

where λ₁ ≥ 1 − max|K| = 0. More precisely, the spectral gap λ₁ of the split Laplacian on [−R, R]² with Dirichlet boundary conditions satisfies λ₁ ≥ c/R² for a universal constant c > 0.

**Test**: Discretize the split Laplacian on a 100×100 grid over [−R, R]² for R = 1, 2, 5, 10. Compute the smallest nonzero eigenvalue of the discrete Laplacian matrix. Plot λ₁ vs R and verify the 1/R² scaling. Extract the constant c.

**Impact**: If true, this provides an explicit convergence rate for the split curvature flow, which models diffusion in anisotropic media. The 1/R² scaling would match the standard Euclidean Poincaré inequality, showing that the curvature of the split metric doesn't degrade the mixing time. If false, a slower convergence rate would indicate curvature-induced trapping.

**Catalog References**: `Bridges/SplitGeometry/InfoGeometry.lean` (splitLaplacian, curvatureFlowStep_const), `Bridges/SpectralApplications.lean` (fundamental_cross_domain_bridge)

**Proof Strategy**:
1. Establish the split Laplacian as a self-adjoint operator on L²(dA).
2. Use the Rayleigh quotient characterization of λ₁.
3. Construct a test function to get an upper bound on λ₁ (establishing the R⁻² scaling from above).
4. Use the curvature bound |K| ≤ 1 and comparison geometry (Cheng's theorem) to get a lower bound.

**Domain Bridges**: Geometry <-> Physics (heat equation), Bridges <-> Computation (spectral methods)

**Lineage**: Builds on splitLaplacian_const and curvatureFlowStep_const from this cycle, plus fundamental_cross_domain_bridge from the Catalog.

**Ambition**: extension
