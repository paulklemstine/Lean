# Future Directions: Discrete Curvature Convergence

## Synthesis

The discrete curvature convergence framework established in this work opens a systematic path from combinatorial geometry to certified scientific computing. Our formally verified theorems prove that discrete angle-defect curvature converges to smooth Gaussian curvature under consistency hypotheses, bridging the gap between mesh-based computation and differential geometry. The five directions below extend this foundation along complementary axes: sharpening convergence rates (Direction 1), removing type-theoretic restrictions (Direction 2), generalizing to higher dimensions for physics applications (Direction 3), connecting to optimal transport theory (Direction 4), and building end-to-end certified pipelines (Direction 5). Together, they chart a course toward a complete formal discrete differential geometry theory.

---

## Direction 1: Linear Consistency Hypothesis for Inscribed Meshes

**Conjecture:** For any smooth strictly convex closed surface S ⊂ ℝ³ and any sequence of inscribed triangulations with mesh size h_n → 0 and uniformly bounded aspect ratio, the consistency error satisfies

  curvatureConsistencyError(V_n, K_n, w_n, κ_n) ≤ C · h_n

for all sufficiently large n, where C depends only on the surface curvature bounds and the aspect ratio bound.

**Test:** Implement geodesic Delaunay triangulations on ellipsoids with varying eccentricity. Measure the consistency error decay rate as a function of mesh size. The conjecture predicts O(h) decay; verify this holds across at least 3 different ellipsoid geometries and 5 refinement levels.

**Impact:** This would give quantitative, not just qualitative, convergence guarantees. Combined with our `curvaturePairing_sub_le_of_bdd`, it would yield explicit error bounds for curvature estimation from triangulated data.

**Catalog References:** `Geometry/CurvatureMeasureConvergence.lean` — `curvaturePairing_sub_le_of_bdd`, `total_curvature_error_le_consistency`; `Catalog/Geometry/DiscreteGaussBonnet.lean` — `discrete_gauss_bonnet`

**Proof Strategy:** Decompose the consistency error into (1) an angular defect estimation error (controlled by the second fundamental form) and (2) a dual-area estimation error (controlled by surface regularity). Both scale as O(h²) per vertex, and there are O(1/h²) vertices, giving O(1) total — but the O(h) improvement comes from cancellation in the sum, which requires Euler–Maclaurin type analysis on the mesh.

**Domain Bridges:** Geometry → Numerical Analysis (finite element error theory), Geometry → Computer Graphics (mesh quality guarantees)

**Lineage:** Extends `total_curvature_error_le_consistency` by providing the rate, not just existence, of convergence.

**Ambition:** ★★★☆☆ — Solid extension. The O(h) rate is well-established informally but has never been formalized.

---

## Direction 2: Superconvergence for Geodesic Delaunay Meshes

**Conjecture:** For geodesic Delaunay triangulations of surfaces of constant curvature, the curvature test-function pairing error for harmonic test functions satisfies

  |⟨K_n, φ⟩ - ⟨κ·w_n, φ⟩| = O(h_n²)

This is a full order better than the generic O(h) bound from Direction 1.

**Test:** On the unit sphere, compute the pairing error for spherical harmonic test functions (Y₁⁰, Y₂⁰, Y₃⁰) on icosahedral subdivisions. Plot the error decay; the conjecture predicts quadratic decay for harmonic test functions vs. linear decay for generic Lipschitz functions.

**Impact:** Superconvergence results are the holy grail of numerical methods — they explain why practitioners often observe better convergence than theory predicts.

**Catalog References:** `Geometry/CurvatureMeasureConvergence.lean` — `tendsto_curvaturePairing_of_consistency`, `pairing_stability_under_uniform_perturbation`

**Proof Strategy:** Use the fact that harmonic functions satisfy a mean-value property on the sphere. The quadrature error for the dual-cell integral of a harmonic function on a regular mesh has enhanced cancellation due to symmetry.

**Domain Bridges:** Geometry → Spectral Theory (spherical harmonics), Geometry → FEM Theory (superconvergence)

**Lineage:** Builds on `pairing_stability_under_uniform_perturbation` by exploiting special structure of the test function.

**Ambition:** ★★★★☆ — Requires significant new mathematical infrastructure around spherical harmonics in Lean.

---

## Direction 3 (Grand Challenge): Regge Calculus Convergence in 3+1 Dimensions

**Conjecture:** The abstract curvature pairing framework (`CurvatureApproximationScheme`) extends to scalar curvature on 3-dimensional Regge simplicial complexes. Specifically, for simplicial approximations to a Riemannian 3-manifold with bounded geometry, the edge-hinge curvature measure (deficit angle × edge length) converges weakly to the scalar curvature measure.

**Test:** Construct simplicial approximations to the 3-sphere S³ via 600-cell subdivisions. Compute the Regge scalar curvature (edge deficit angles × edge lengths) and measure convergence of the total scalar curvature to 2π²·R² (the Einstein–Hilbert action of S³ with radius R).

**Impact:** This would provide the first formal certification layer for numerical general relativity simulations based on Regge calculus. It directly addresses the question: "Does the discrete Einstein equation converge to the continuum Einstein equation?"

**Catalog References:** `Geometry/CurvatureMeasureConvergence.lean` — `CurvatureApproximationScheme`, `tendsto_total_curvature_sphere_model`; `Catalog/Geometry/DiscreteGaussBonnet.lean` — `FinCellComplex2`, `discrete_gauss_bonnet`

**Proof Strategy:** Generalize `FinCellComplex2` to a `FinCellComplex3` with tetrahedra. Define Regge curvature on edges (not vertices). The abstract convergence machinery (consistency error → pairing convergence) transfers directly; the hard part is proving the consistency estimate for 3D Regge curvature.

**Domain Bridges:** Geometry → Physics (general relativity), Geometry → Numerical PDE (Regge finite elements)

**Lineage:** Direct generalization of `tendsto_total_curvature_sphere_model` to 3 dimensions.

**Ambition:** ★★★★★ — Paradigm-shifting. Would be the first formal convergence theorem for discrete gravity.

---

## Direction 4 (Grand Challenge): Wasserstein Convergence of Curvature Measures

**Conjecture:** Under bounded aspect ratio and inscribed mesh hypotheses, the discrete curvature measure μ_n = ∑_v K_n(v) δ_v converges to the smooth curvature measure K dA in the Wasserstein-1 (earth-mover's) distance, with rate

  W₁(μ_n, K dA) = O(h_n)

**Test:** On the unit sphere, compute W₁ between the discrete curvature measure and the uniform measure (κ=1) using linear programming. Verify O(h) decay across 5 refinement levels.

**Impact:** Wasserstein convergence is strictly stronger than weak convergence and gives geometric, not just functional-analytic, control. It would connect discrete geometry to the rapidly developing theory of optimal transport.

**Catalog References:** `Geometry/CurvatureMeasureConvergence.lean` — `curvatureConsistencyError`, `tendsto_curvaturePairing_of_consistency`

**Proof Strategy:** Use the Kantorovich–Rubinstein duality: W₁ = sup over 1-Lipschitz functions of the pairing difference. By `pairing_stability_under_uniform_perturbation` with L=1, the pairing difference is bounded by h · ∑|K_n(v)|. If ∑|K_n(v)| is bounded (which follows from bounded aspect ratio), this gives W₁ = O(h).

**Domain Bridges:** Geometry → Optimal Transport, Geometry → Machine Learning (Wasserstein GANs for shape generation)

**Lineage:** Combines `pairing_stability_under_uniform_perturbation` with Kantorovich–Rubinstein duality.

**Ambition:** ★★★★★ — Would open entirely new connections between discrete geometry and optimal transport.

---

## Direction 5: Certified Curvature Estimation Pipeline

**Conjecture:** Given a point cloud P sampled from a smooth surface S with known sampling density, there exists an algorithm that:
1. Constructs a triangulation T of P with bounded aspect ratio
2. Computes angle-defect curvature K(v)
3. Returns a certified bound ε such that for all 1-Lipschitz test functions φ:
   |∑_v K(v)φ(v) - ∫_S Kφ dA| < ε

The bound ε is computable and tight to within a constant factor.

**Test:** Implement the pipeline for point clouds sampled from ellipsoids. Compare the certified bound ε with the actual error for 100 random Lipschitz test functions. The certified bound should be within 10× of the actual maximum error.

**Impact:** This would be the first end-to-end certified geometry processing pipeline: from raw point cloud data to a curvature estimate with formal error guarantees.

**Catalog References:** `Geometry/CurvatureMeasureConvergence.lean` — all main theorems; `Catalog/Geometry/DiscreteGaussBonnet.lean` — `discrete_gauss_bonnet`

**Proof Strategy:** Combine (1) a sampling lemma (Delaunay triangulation of ε-net has bounded aspect ratio), (2) the consistency error estimate from Direction 1, and (3) the pairing bound from `curvaturePairing_sub_le_of_bdd`. The main challenge is formalizing the sampling-to-triangulation step.

**Domain Bridges:** Geometry → Data Science (point cloud analysis), Geometry → Robotics (certified perception)

**Lineage:** Integrates all theorems from the current cycle into an applied pipeline.

**Ambition:** ★★★☆☆ — Solid engineering extension with high practical impact.
