# Future Directions: Split Geometry and Beyond

## Synthesis

This research cycle established *split geometry* as a rigorously formalized Riemannian geometry on ℝ² with sign-changing curvature. The key insight is that the curvature function K(x,y) = sech²(x) − sech²(y) has a clean antisymmetric structure that partitions the plane into elliptic and hyperbolic regions separated by flat phase boundaries along the diagonals y = ±x. All properties — curvature bounds, sign characterization, phase consistency, divergence non-negativity — were formally verified in Lean 4.

The most promising cross-domain connection from this cycle is the link between split geometry and **information geometry**. The split metric arises as a Fisher information metric for anisotropic statistical families, and the split divergence behaves like a KL divergence. This suggests that techniques from Riemannian geometry (geodesic computation, curvature analysis) could be applied to optimization problems in machine learning where the loss landscape has strongly anisotropic curvature. The curvature bound |K| ≤ 1 is particularly interesting: it suggests that despite wild metric distortion, the intrinsic curvature remains controlled — a potential convergence guarantee for gradient-based methods.

The second major connection is to **cosmological anisotropy models**. The split metric's property that the area element cosh(x)/cosh(y) preserves total volume (since the product of directional scale factors is 1) makes it a candidate for modeling incompressible anisotropic flows. This connects to existing work on Bianchi cosmologies and could bridge the Catalog's Geometry and Physics domains.

The highest breakthrough potential lies in Direction 1 (Gauss-Bonnet for split geometry), which would directly connect the formal curvature theorems to a topological invariant, creating a novel bridge between differential geometry and algebraic topology in the Catalog.

---

### Direction 1: Gauss-Bonnet Theorem for Split Geometry

**Conjecture**: For any compact region R ⊂ ℝ² with piecewise-smooth boundary ∂R, the Gauss-Bonnet integral ∫∫_R K dA + ∫_{∂R} κ_g ds = 2π χ(R) holds for the split metric, where K is the split curvature, dA = (cosh x / cosh y) dx dy, κ_g is the geodesic curvature of the boundary, and χ(R) is the Euler characteristic. In particular, for a split triangle (genus-0 region with three vertices), the angle defect equals the integrated curvature.

**Test**: Numerically integrate the split curvature over a triangle straddling the phase boundary and compare with the angle defect computed from geodesic angles. If these agree (up to numerical precision), the Gauss-Bonnet relation holds. Compute for at least 10 triangles of varying size and position.

**Impact**: If true, this would provide the first formal Gauss-Bonnet result for a metric with sign-changing curvature in the Catalog, connecting differential geometry to topology. If false (which would be remarkable, since Gauss-Bonnet is a general theorem), it would indicate an error in the curvature formula.

**Catalog References**: `Catalog/Geometry/DiscreteGaussBonnet.lean`, `Catalog/Geometry/EulerTopology.lean`

**Proof Strategy**: (1) Formalize the Gauss-Bonnet theorem for diagonal metrics using the existing discrete Gauss-Bonnet infrastructure. (2) Prove that the split curvature satisfies the Bianchi identity. (3) Use the area element formula (Theorem 3.9) to convert the surface integral. (4) Verify numerically first, then formalize.

**Domain Bridges**: Geometry <-> Topology, Geometry <-> Physics

**Lineage**: Builds on `splitCurvature_pos_iff`, `splitCurvature_abs_le_one`, `splitMetric_areaElement` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Split Metric as Natural Gradient for Anisotropic Optimization

**Conjecture**: For a two-parameter optimization problem where the loss function has the form L(θ₁, θ₂) = f(cosh(θ₁), cosh(θ₂)), the natural gradient descent (using the split metric as the Fisher information metric) converges in O(log(1/ε)) iterations, compared to O(1/ε) for standard gradient descent.

**Test**: Implement natural gradient descent using the split metric's inverse as the preconditioner. Compare convergence rates on synthetic anisotropic loss functions with standard gradient descent and Adam optimizer. Measure: number of iterations to reach ε-optimality for ε ∈ {10⁻², 10⁻⁴, 10⁻⁶}.

**Impact**: If true, this identifies split geometry as a natural preconditioner for a class of anisotropic optimization problems, with applications to machine learning. If false, the failure mode (divergence, oscillation, or slow convergence) would reveal where the curvature-based analysis breaks down.

**Catalog References**: `Catalog/MachineLearning/` (optimization-related files), `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**: (1) Compute the inverse split metric g⁻¹ = diag(cosh²(y), sech²(x)). (2) Show that the natural gradient update θ ← θ - α g⁻¹ ∇L equalizes the effective step size across directions. (3) Use the curvature bound |K| ≤ 1 to bound the Hessian of the transformed loss. (4) Apply standard convex optimization convergence theorems.

**Domain Bridges**: Geometry <-> MachineLearning, Algebra <-> MachineLearning

**Lineage**: Builds on the split metric definition and curvature bounds from this cycle, plus the information-geometric interpretation of the split divergence.

**Ambition**: grand_challenge

---

### Direction 3: Higher-Dimensional Split Geometry

**Conjecture**: The n-dimensional split metric on ℝⁿ defined by g_{ii}(x) = cosh²(x_i) for i odd and g_{ii}(x) = sech²(x_i) for i even (with g_{ij} = 0 for i ≠ j) has sectional curvatures that decompose into pairwise split curvatures: K(e_i, e_j) = f(x_i, x_j) for some function f depending only on the types (odd/even) of i and j.

**Test**: Compute the Riemann curvature tensor for the 3D and 4D split metrics using symbolic computation (SymPy or similar). Verify the conjectured decomposition for n = 3, 4. Check whether the Ricci tensor and scalar curvature have closed-form expressions.

**Impact**: If the decomposition holds, it opens the path to studying split geometry in arbitrary dimensions, which is needed for the cosmological and optimization applications. It would also connect to the theory of warped products in Riemannian geometry.

**Catalog References**: `Catalog/Geometry/AdvancedTheory.lean`, `Catalog/Physics/GravitationalWaves.lean`

**Proof Strategy**: (1) Write the n-dimensional Christoffel symbols for the generalized split metric. (2) Use the diagonal structure to simplify the Riemann tensor computation. (3) Show that non-vanishing components only involve pairs of coordinates. (4) Identify the pairwise function f.

**Domain Bridges**: Geometry <-> Physics, Geometry <-> Algebra

**Lineage**: Direct extension of the 2D split metric and curvature theorems from this cycle.

**Ambition**: extension

---

### Direction 4: Spectral Theory of the Split Laplacian

**Conjecture**: The Laplace-Beltrami operator for the split metric, $\Delta_g f = \frac{1}{\sqrt{EG}} \left[\partial_x\left(\frac{\sqrt{G}}{\sqrt{E}} \partial_x f\right) + \partial_y\left(\frac{\sqrt{E}}{\sqrt{G}} \partial_y f\right)\right]$, is separable: its eigenfunctions have the form $\Phi(x,y) = X(x) \cdot Y(y)$ where X and Y satisfy independent ODEs. The eigenvalues form a lattice $\lambda_{mn} = \lambda_m^{(x)} + \lambda_n^{(y)}$ in the spectral plane.

**Test**: (1) Substitute the ansatz Φ(x,y) = X(x)Y(y) into the eigenvalue equation and check if the variables separate. (2) If separable, solve the 1D ODEs numerically using a spectral method (Chebyshev collocation) and plot the first 20 eigenvalues. (3) If not separable, compute eigenvalues of the full 2D operator numerically and check for approximate lattice structure.

**Impact**: Separability would make the split Laplacian analytically tractable, enabling closed-form heat kernel and wave equation solutions. This has direct applications to diffusion on anisotropic surfaces and quantum mechanics on curved backgrounds.

**Catalog References**: `Catalog/Geometry/HamiltonianBridge.lean`, `Catalog/Physics/` (quantum mechanics files)

**Proof Strategy**: (1) Write out the Laplace-Beltrami operator explicitly using E = sech²(y), G = cosh²(x). (2) After simplification, check if the equation Δ_g Φ = λΦ separates. (3) If yes, identify the 1D operators and their spectra.

**Domain Bridges**: Geometry <-> Physics, Geometry <-> Computation

**Lineage**: Builds on the area element formula and metric positivity from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Geometry of Curvature Sign Patterns

**Conjecture**: The phase boundary {|x| = |y|} of the split curvature is a *tropical variety* — it is the corner locus of the tropical polynomial max(|x|, |y|) = min(|x|, |y|). More generally, for the n-dimensional split metric, the locus where the scalar curvature vanishes is a tropical hypersurface in the sense of tropical algebraic geometry.

**Test**: (1) Verify that {|x| = |y|} in ℝ² coincides with the tropical curve V(max(|x|,|y|) - min(|x|,|y|)). (2) For the 3D split metric, compute the scalar curvature zero set and check if it is a tropical surface. (3) Define a "tropical curvature" as the max/min analogue of the split curvature and study its properties.

**Impact**: A connection between Riemannian curvature sign patterns and tropical geometry would be entirely novel, linking two seemingly unrelated fields. The piecewise-linear structure of tropical varieties could provide combinatorial tools for studying curvature sign changes.

**Catalog References**: `Catalog/Tropical/Matrix/PowerStabilization.lean`, `Bridges/AlgebraPythagoreanCryptography/`, `tropical_triangle_ineq` from `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean`

**Proof Strategy**: (1) Formalize the tropical variety structure of {|x| = |y|}. (2) Show that the split curvature sign function sgn(K(x,y)) = sgn(|y| - |x|) is a tropical polynomial evaluation. (3) Connect to the existing `tropical_triangle_ineq` in the Catalog.

**Domain Bridges**: Geometry <-> Tropical, Algebra <-> Geometry

**Lineage**: Builds on `splitCurvature_pos_iff` (which shows K > 0 ↔ |x| < |y|) and `phaseIndicator_pos_iff_elliptic` from this cycle. Also relates to `tropical_triangle_ineq` in the existing Catalog.

**Ambition**: extension
