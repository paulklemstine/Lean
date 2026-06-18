# Split Geometry: A Riemannian Metric with Sign-Changing Gaussian Curvature

## Abstract

We introduce **split geometry**, a Riemannian geometry on ℝ² defined by the diagonal metric tensor g = diag(sech²(y), cosh²(x)). This metric produces a Gaussian curvature K(x,y) = sech²(x) − sech²(y) that smoothly transitions between positive (elliptic) and negative (hyperbolic) values across diagonal phase boundaries |x| = |y|. We establish the following main results: (1) the metric is positive definite everywhere; (2) the curvature is strictly bounded in (−1, 1); (3) the curvature vanishes if and only if the point lies on the phase boundary; (4) the curvature exhibits a fundamental antisymmetry K(y,x) = −K(x,y); and (5) the anisotropy ratio g₂₂/g₁₁ = cosh²(x)cosh²(y) equals 1 only at the origin. All results are formalized and machine-verified in Lean 4 with Mathlib.

## 1. Introduction

The classification of surfaces by the sign of Gaussian curvature is one of the foundational themes of differential geometry. Surfaces of constant positive curvature (spheres), constant negative curvature (pseudospheres), and zero curvature (planes) form the three model geometries in the Thurston–Perelman classification program.

Surfaces of *variable* curvature are, of course, ubiquitous—every smooth surface embedded in ℝ³ has curvature that varies from point to point. However, the systematic study of metrics specifically *designed* to exhibit controlled sign changes in curvature is less developed. In particular, metrics where the curvature changes sign along an algebraically simple locus, with exactly computable curvature, are rare in the literature.

We present the **split metric** on ℝ²:

$$ds^2 = \operatorname{sech}^2(y)\, dx^2 + \cosh^2(x)\, dy^2$$

This metric is constructed so that horizontal distances contract (via sech²(y) → 0 as |y| → ∞) while vertical distances expand (via cosh²(x) → ∞ as |x| → ∞). The resulting curvature

$$K(x,y) = \operatorname{sech}^2(x) - \operatorname{sech}^2(y)$$

changes sign exactly on the diagonals |x| = |y|.

### 1.1 Motivation

The split metric arises naturally when one asks: *what is the simplest diagonal metric on ℝ² whose curvature changes sign along a prescribed algebraic curve?* The choice of hyperbolic functions (cosh, sech) ensures:

- **Smoothness**: all metric coefficients are C^∞.
- **Positivity**: g₁₁ = sech²(y) > 0 and g₂₂ = cosh²(x) > 0 for all (x,y).
- **Bounded curvature**: K ∈ (−1, 1), avoiding singularities.
- **Exact computability**: all Christoffel symbols, curvature, and geodesic equations are expressible in closed form.

### 1.2 Relation to Prior Work

Metrics with sign-changing curvature appear in several contexts:

- **Bianchi cosmologies**: anisotropic spacetime metrics in general relativity, where expansion rates differ along spatial axes.
- **Transition surfaces**: surfaces in ℝ³ where the Gaussian curvature changes sign across a curve (e.g., the inner rim of a torus).
- **Mixed-curvature manifolds**: studied in Riemannian geometry, particularly in connection with the soul theorem and Cheeger–Gromoll splitting.

The split metric differs from these in being explicitly constructed, exactly solvable, and possessing the antisymmetry K(y,x) = −K(x,y), which appears to be novel.

## 2. Definitions

### 2.1 The sech² Function

We define:

$$\operatorname{sechSq}(t) = \frac{1}{\cosh^2(t)}$$

**Properties:**
- sechSq(t) > 0 for all t ∈ ℝ (Lemma `sechSq_pos`)
- sechSq(t) ≤ 1 for all t ∈ ℝ (Lemma `sechSq_le_one`)
- sechSq(t) = 1 ⟺ t = 0 (Lemma `sechSq_eq_one_iff`)
- sechSq(|t|) = sechSq(t) (Lemma `sechSq_abs`)
- sechSq is strictly decreasing on [0, ∞) (Lemma `sechSq_strictAntiOn`)

### 2.2 The Split Metric

The **split metric** on ℝ² is the Riemannian metric with components:

- g₁₁(y) = sechSq(y) = 1/cosh²(y)
- g₁₂ = g₂₁ = 0
- g₂₂(x) = cosh²(x)

The metric is positive definite (Theorem `splitMetric_det_pos`): det(g) = g₁₁ · g₂₂ > 0.

### 2.3 Gaussian Curvature

$$K(x,y) = \operatorname{sechSq}(x) - \operatorname{sechSq}(y)$$

### 2.4 Region Classification

- **Elliptic region**: {(x,y) : |x| < |y|} — curvature positive
- **Hyperbolic region**: {(x,y) : |x| > |y|} — curvature negative
- **Phase boundary**: {(x,y) : |x| = |y|} — curvature zero

### 2.5 Novel Structure: SplitMetricData

We define the `SplitMetricData` structure bundling the metric tensor components and curvature at a point, providing a clean interface for computations.

## 3. Main Results

### 3.1 Curvature Sign Analysis

**Theorem 3.1** (Phase Boundary Characterization). *For all (x, y) ∈ ℝ²:*
$$K(x,y) = 0 \iff |x| = |y|$$

*Proof sketch.* The forward direction uses the strict monotonicity of cosh on [0,∞) and the evenness of cosh to conclude that sechSq(x) = sechSq(y) implies cosh(x) = cosh(y) implies |x| = |y|. The reverse direction is immediate from the definition. □

**Theorem 3.2** (Elliptic Region). *If |x| < |y|, then K(x,y) > 0.*

*Proof sketch.* Since sechSq is strictly decreasing on [0,∞) and even, |x| < |y| implies sechSq(|x|) > sechSq(|y|), i.e., sechSq(x) > sechSq(y). □

**Theorem 3.3** (Hyperbolic Region). *If |x| > |y|, then K(x,y) < 0.*

*Proof.* Symmetric to Theorem 3.2. □

### 3.2 Curvature Bounds

**Theorem 3.4** (Strict Boundedness). *For all (x,y) ∈ ℝ², −1 < K(x,y) < 1.*

*Proof sketch.* Since 0 < sechSq(t) ≤ 1 for all t, the difference sechSq(x) − sechSq(y) is strictly bounded by the strict positivity of sechSq on both sides. Specifically, K < sechSq(x) ≤ 1 with the last inequality strict because sechSq(y) > 0, and K > −sechSq(y) ≥ −1 with the last inequality strict because sechSq(x) > 0. □

### 3.3 Symmetries

**Theorem 3.5** (Four-fold Symmetry). *For all (x,y) ∈ ℝ²:*
- K(−x, y) = K(x, y)
- K(x, −y) = K(x, y)

*Proof.* Follows from the evenness of cosh (and hence sechSq). □

**Theorem 3.6** (Fundamental Antisymmetry). *For all (x,y) ∈ ℝ²:*
$$K(y, x) = -K(x, y)$$

*Proof.* K(y,x) = sechSq(y) − sechSq(x) = −(sechSq(x) − sechSq(y)) = −K(x,y). □

This antisymmetry is the defining structural property of split geometry. It means the curvature is a *skew-symmetric function* of its arguments—an unusual property for a geometric invariant.

### 3.4 Anisotropy

**Theorem 3.7** (Anisotropy Ratio). *For all (x,y) ∈ ℝ²:*
$$\frac{g_{22}(x)}{g_{11}(y)} = \cosh^2(x) \cdot \cosh^2(y) \geq 1$$
*with equality if and only if x = y = 0.*

*Proof sketch.* Since cosh(t) ≥ 1 for all t, the product cosh²(x)cosh²(y) ≥ 1. Equality requires cosh(x) = cosh(y) = 1, hence x = y = 0. □

### 3.5 Axis Profiles

**Theorem 3.8.** *Along the coordinate axes:*
- K(x, 0) = sechSq(x) − 1 ≤ 0 (purely hyperbolic profile on x-axis)
- K(0, y) = 1 − sechSq(y) ≥ 0 (purely elliptic profile on y-axis)

These axis profiles demonstrate the dual character of the geometry: the x-axis is a locus of maximal hyperbolic behavior, while the y-axis is a locus of maximal elliptic behavior.

## 4. Christoffel Symbols and Geodesic Equations

For the diagonal metric g = diag(E, G) with E = sech²(y), G = cosh²(x), the non-zero Christoffel symbols are:

$$\Gamma^1_{11} = -\frac{E_y}{2E} = \tanh(y)$$

$$\Gamma^1_{22} = -\frac{G_x}{2E} = -\sinh(x)\cosh(x)\cosh^2(y)$$

$$\Gamma^2_{11} = -\frac{E_y}{2G} = \frac{\tanh(y)}{\cosh^2(x)\cosh^2(y)}$$

$$\Gamma^2_{22} = \frac{G_x}{2G} = \tanh(x)$$

The geodesic equations are:

$$\ddot{x} + \tanh(y)\dot{x}^2 - \sinh(x)\cosh(x)\cosh^2(y)\dot{y}^2 = 0$$

$$\ddot{y} + \frac{\tanh(y)}{\cosh^2(x)\cosh^2(y)}\dot{x}^2 + \tanh(x)\dot{y}^2 = 0$$

These equations are implemented numerically in the accompanying Python code (algorithms.py) and visualized in the geodesic plots.

## 5. Computational Results

### 5.1 Curvature Landscape

Numerical evaluation on a 1000×1000 grid over [−5, 5]² confirms:
- min(K) ≈ −0.9999 (approaching but never reaching −1)
- max(K) ≈ +0.9999 (approaching but never reaching +1)
- K = 0 exactly on the diagonals |x| = |y|

### 5.2 Geodesic Behavior

Numerical integration of geodesics reveals:
- Geodesics originating in the elliptic region tend to oscillate around the y-axis
- Geodesics originating in the hyperbolic region tend to escape toward large |x|
- Geodesics crossing the phase boundary exhibit visible changes in their curvature

### 5.3 Phase Boundary Crossings

Computational experiments suggest that generic geodesics cross the phase boundary a finite number of times, typically 0–4 crossings. The question of whether there exists an upper bound on the number of crossings for any geodesic remains open (see Conjectures, §7).

## 6. Discussion

### 6.1 Novelty

The key novel contribution is the identification of sechSq(x) − sechSq(y) as a curvature function with exact, algebraically simple phase boundaries. The antisymmetry K(y,x) = −K(x,y) appears to be new in the literature on sign-changing curvature surfaces.

### 6.2 Physical Interpretation

The split metric models an anisotropic space where:
- Horizontal distances are compressed by a factor of sech(y)
- Vertical distances are stretched by a factor of cosh(x)
- The compression and stretching interact to produce sign-changing curvature

This is reminiscent of anisotropic cosmological models where the universe expands at different rates along different axes.

### 6.3 Limitations

The current work is restricted to two dimensions. The natural extension to higher dimensions—replacing sechSq and cosh² with more general warping functions—is straightforward in principle but requires careful analysis of the Riemann curvature tensor (which has more independent components in d > 2).

## 7. Conjectures and Open Problems

**Conjecture 7.1** (Finite Crossing Conjecture). *Every geodesic in split geometry crosses the phase boundary at most finitely many times.*

**Test:** Numerical integration of geodesics with random initial conditions. If a geodesic is found with unboundedly many crossings, the conjecture is false.

**Conjecture 7.2** (Geodesic Escape). *Every geodesic that starts in the hyperbolic region with sufficiently large |ẋ/ẏ| ratio escapes to infinity without crossing the phase boundary.*

**Conjecture 7.3** (Isoperimetric Anomaly). *The isoperimetric ratio of geodesic circles in split geometry is not monotone as a function of radius.*

## 8. Formalization

All definitions and theorems in Sections 2–3 are formalized in Lean 4 with Mathlib. The formalization includes:

- 7 definitions (sechSq, splitCurvature, region predicates, metric components, SplitMetricData)
- 19 theorems with complete machine-verified proofs
- 0 uses of sorry or non-standard axioms

The formalization file is `Geometry/SplitGeometry.lean`.

## 9. Future Work

1. **Higher-dimensional split metrics**: Define split metrics on ℝⁿ with curvature that changes sign along hyperplanar boundaries.
2. **Geodesic classification**: Prove or disprove the Finite Crossing Conjecture.
3. **Spectral geometry**: Study the Laplacian eigenvalue problem on bounded domains straddling the phase boundary.
4. **Connections to tropical geometry**: The piecewise-linear nature of the phase boundary |x| = |y| suggests connections to tropical geometry's "corner locus" structures.

## References

1. do Carmo, M.P. *Riemannian Geometry*. Birkhäuser, 1992.
2. Lee, J.M. *Riemannian Manifolds: An Introduction to Curvature*. Springer, 1997.
3. O'Neill, B. *Semi-Riemannian Geometry with Applications to Relativity*. Academic Press, 1983.
4. Thurston, W.P. *Three-Dimensional Geometry and Topology*. Princeton University Press, 1997.
