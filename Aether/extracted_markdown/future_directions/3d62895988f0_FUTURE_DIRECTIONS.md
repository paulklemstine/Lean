# Future Directions: Split Geometry and Beyond

## Synthesis

This research cycle introduced **split geometry**, a Riemannian geometry on ℝ² whose curvature K(x,y) = sech²(x) − sech²(y) smoothly transitions between positive (elliptic) and negative (hyperbolic) values across the phase boundaries |x| = |y|. We proved 19 theorems establishing the fundamental properties: positive definiteness, strict curvature bounds, the curvature–boundary equivalence (K = 0 ⟺ |x| = |y|), four-fold symmetry, the antisymmetry K(y,x) = −K(x,y), anisotropy characterization, and axis profiles.

The most promising cross-domain connection is between split geometry's phase boundaries and **tropical geometry**. The phase boundary |x| = |y| is precisely the tropical hypersurface defined by the tropical polynomial max(x, −x) = max(y, −y), i.e., |x| = |y|. This suggests that tropical geometry may provide a combinatorial skeleton for understanding the topology of sign-changing curvature regions in more general Riemannian metrics. The connection to the Catalog's tropical results (e.g., `Tropical/DivisorTheory.lean`, `Tropical/Existence.lean`) could yield a bridge between algebraic combinatorics and differential geometry.

The direction with highest breakthrough potential is **Direction 1** (Spectral Splitting), because eigenvalue problems on domains that straddle phase boundaries may exhibit novel spectral phenomena not captured by existing Weyl-law asymptotics. This would connect analysis, geometry, and mathematical physics in a concrete, testable way.

---

### Direction 1: Spectral Splitting of the Laplacian Across Phase Boundaries

**Conjecture**: Let Ω be a geodesic disk of radius R centered at the origin in split geometry. The eigenvalues λ_n of the Laplace–Beltrami operator on Ω (with Dirichlet boundary conditions) satisfy an asymptotic law of the form λ_n ~ C · n / Area(Ω) as n → ∞, but the spectral gap λ₂ − λ₁ exhibits a non-monotone dependence on R, with a local maximum when the boundary of Ω first intersects the phase boundary.

**Test**: Numerically discretize the Laplace–Beltrami operator Δ_g f = (1/√det(g)) ∂_i(√det(g) g^{ij} ∂_j f) on a grid over a geodesic disk. Compute eigenvalues for R = 0.5, 1.0, 1.5, ..., 5.0 and plot the spectral gap as a function of R. A non-monotone spectral gap would confirm the conjecture; a monotone decay would refute it.

**Impact**: If true, this would be the first example of a spectral gap anomaly caused by curvature sign change rather than domain topology or boundary geometry. It would connect Riemannian geometry to spectral theory in a way that could have applications to quantum mechanics on curved spaces and to the heat equation on anisotropic media.

**Catalog References**: `Geometry/SplitGeometry.lean` (metric and curvature definitions), `Computation/PadicValuationDepth.lean` (depth measures that could generalize to spectral depth).

**Proof Strategy**: (1) Formalize the Laplace–Beltrami operator for diagonal metrics in Lean 4. (2) Prove that the Weyl asymptotic law holds for the split metric (this requires showing the metric is complete or working on bounded domains). (3) Analyze the spectral gap by decomposing the domain into elliptic and hyperbolic subdomains and using domain monotonicity of eigenvalues. (4) Key lemma: prove that on a purely elliptic subdomain, the first eigenvalue is bounded below by the minimum curvature (Lichnerowicz-type bound), while on a purely hyperbolic subdomain, no such bound exists.

**Domain Bridges**: Riemannian Geometry ↔ Spectral Theory ↔ Mathematical Physics

**Lineage**: Builds on the split geometry definitions and curvature analysis from this cycle. Extends the metric positivity and curvature bounds to operator-theoretic consequences.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Phase Boundaries and Combinatorial Curvature

**Conjecture**: The phase boundary |x| = |y| of split geometry is a tropical hypersurface, and the sign of the curvature in each region corresponds to the orientation of the dual tropical cell. More generally, for any tropical hypersurface V(f) defined by a tropical polynomial f on ℝⁿ, there exists a Riemannian metric on ℝⁿ \ V(f) whose curvature sign is determined by the combinatorial structure of f.

**Test**: Construct explicit metrics for the tropical lines max(x, y, 0) = max of the other two, and compute their curvature. Verify that each region of the tropical complement has curvature sign matching the orientation of the corresponding cell in the tropical dual complex.

**Impact**: This would establish a direct bridge between tropical algebraic geometry (a combinatorial theory) and Riemannian geometry (a smooth theory). The phase boundary would serve as the "tropicalization" of the curvature sign locus, providing new tools for studying sign-changing curvature using polyhedral combinatorics.

**Catalog References**: `Tropical/DivisorTheory.lean` (tropical divisor theory), `Tropical/Existence.lean` (existence results for tropical structures), `Geometry/SplitGeometry.lean` (the split metric as a base case).

**Proof Strategy**: (1) Define "tropical curvature assignment" as a function from regions of a tropical complement to {+, −, 0}. (2) For each region, construct a warping function using products of cosh and sech applied to tropical linear forms. (3) Prove that the resulting metric has curvature sign matching the assignment. (4) Key difficulty: ensuring the metric is smooth across the tropical hypersurface (the current sechSq-based construction handles this for the simple case |x| = |y|).

**Domain Bridges**: Tropical Geometry ↔ Riemannian Geometry ↔ Combinatorics

**Lineage**: Builds on the split geometry phase boundary analysis and the Catalog's tropical geometry results.

**Ambition**: grand_challenge

---

### Direction 3: Geodesic Crossing Number Bounds

**Conjecture**: Every geodesic in split geometry crosses the phase boundary |x| = |y| at most 4 times. Moreover, geodesics that are tangent to the phase boundary (i.e., touch |x| = |y| without crossing) do so at most twice.

**Test**: Numerically integrate 10,000 geodesics with random initial conditions (x₀, y₀, v_x, v_y) sampled uniformly from [−3,3]⁴, counting phase boundary crossings for each. If any geodesic has more than 4 crossings, the conjecture is false. Also test geodesics started on the phase boundary with various tangent directions.

**Impact**: If proved, this would be a rigidity result constraining how geodesics interact with the curvature sign-change locus. The bound of 4 would come from the quartic nature of the phase boundary equation when pulled back to a geodesic parameterization. If false, the counterexample would reveal unexpected oscillatory behavior in sign-changing curvature geometries.

**Catalog References**: `Geometry/SplitGeometry.lean` (curvature sign analysis, phase boundary characterization).

**Proof Strategy**: (1) Write the geodesic equations and the phase boundary condition |x(s)| = |y(s)| as a system. (2) Define g(s) = |x(s)|² − |y(s)|² along a geodesic. (3) Show that g satisfies a second-order ODE whose coefficients are bounded (using the curvature bounds). (4) Use Sturm comparison to bound the number of zeros of g. (5) Key lemma: the function g''(s) has a definite sign relationship with g(s) in the elliptic/hyperbolic regions.

**Domain Bridges**: Riemannian Geometry ↔ ODE Theory (Sturm Comparison)

**Lineage**: Builds directly on the curvature bounds and phase boundary characterization from this cycle.

**Ambition**: extension

---

### Direction 4: Split Geometry in Higher Dimensions

**Conjecture**: The n-dimensional split metric g = diag(sech²(x₂), sech²(x₃), ..., sech²(xₙ), cosh²(x₁)) on ℝⁿ has sectional curvatures that change sign across hyperplanar phase boundaries. The number of distinct curvature sign regions grows as 2ⁿ, partitioned by the n−1 hyperplanes |x₁| = |xₖ| for k = 2, ..., n.

**Test**: For n = 3, compute the 3 independent sectional curvatures K₁₂, K₁₃, K₂₃ explicitly. Verify that each sectional curvature has its own phase boundary, and that the 8 octants of ℝ³ have distinct sectional curvature sign patterns.

**Impact**: Would establish split geometry as a genuine family of geometries parametrized by dimension, with exponentially growing combinatorial complexity. This connects to the theory of Riemannian manifolds with "mixed curvature" conditions, which have applications in comparison geometry and topology (cf. the soul theorem, Cheeger–Gromoll splitting).

**Catalog References**: `Geometry/SplitGeometry.lean` (2D base case), `FINAL/Tropical/QuantumLLMCompilation.lean` (exponential growth bounds).

**Proof Strategy**: (1) Define the n-dimensional split metric. (2) Compute the Christoffel symbols (they decompose into 2D blocks for diagonal metrics). (3) Compute sectional curvatures K_{ij} using the formula for diagonal metrics. (4) Show each K_{ij} = sechSq(xᵢ) − sechSq(xⱼ) (or a similar expression). (5) Classify the sign regions combinatorially.

**Domain Bridges**: Riemannian Geometry ↔ Combinatorics ↔ Comparison Geometry

**Lineage**: Direct generalization of the 2D split geometry results.

**Ambition**: extension

---

### Direction 5: Anisotropic Cosmology via Split Metrics

**Conjecture**: The split metric, when Wick-rotated to Lorentzian signature (replacing one sech² with −sech²), defines a consistent anisotropic cosmological model (a Bianchi type I spacetime) with expansion in one spatial direction and contraction in another. The Einstein field equations for this metric have a solution with a physically reasonable stress-energy tensor (satisfying the weak energy condition).

**Test**: Compute the Einstein tensor G_μν for the Lorentzian split metric and determine what stress-energy tensor T_μν is required by G_μν = 8πG T_μν. Check whether T_μν satisfies the weak, strong, and dominant energy conditions.

**Impact**: If the energy conditions are satisfied, the split metric would provide an exact, closed-form solution to Einstein's equations with anisotropic expansion — a rare find in general relativity. This could model an early universe undergoing asymmetric inflation.

**Catalog References**: `Geometry/SplitGeometry.lean` (Riemannian base case), `Physics/` (if physical models exist in the Catalog).

**Proof Strategy**: (1) Define the Lorentzian split metric ds² = −sech²(t) dt² + cosh²(x) dx² (or appropriate signature). (2) Compute the Einstein tensor. (3) Verify energy conditions algebraically using curvature bounds. (4) Key challenge: ensuring the Lorentzian version remains geodesically complete (or characterizing the singularities if it isn't).

**Domain Bridges**: Riemannian Geometry ↔ General Relativity ↔ Cosmology

**Lineage**: Extends the split metric from pure mathematics to mathematical physics.

**Ambition**: extension
