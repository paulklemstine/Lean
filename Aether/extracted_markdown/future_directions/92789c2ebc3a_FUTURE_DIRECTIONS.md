# Future Directions: Split Geometry Curvature

## Synthesis

This cycle established the foundational curvature theory of the split metric ds² = sech²(y) dx² + cosh²(x) dy² on ℝ². We defined the Gaussian curvature K(x,y) = 1/cosh²(x) - 1/cosh²(y) and proved four main structural theorems: antisymmetry K(x,y) = -K(y,x), the phase boundary characterization K = 0 ↔ |x| = |y|, the curvature sign characterization K > 0 ↔ |x| < |y| (and its negative counterpart), and the uniform curvature bound |K| < 1.

The key technical challenge was proving the injectivity of 1/cosh² modulo absolute value, which required reducing cosh equality to exponential equations via `Real.cosh_eq` and solving the resulting algebraic system. The monotonicity lemmas from Mathlib (`cosh_lt_cosh`, `cosh_le_cosh`) were essential for the sign characterization. The curvature bound followed cleanly from the pointwise bounds 0 < 1/cosh² ≤ 1.

What emerged structurally: the split metric is a rare explicit example of a complete diagonal metric with mixed-sign curvature, where the curvature sign is determined by a simple geometric condition (which coordinate has larger absolute value). The antisymmetry under coordinate exchange and the separability K = f(x) - f(y) are the root causes of all the clean characterizations.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `splitCurvature_antisymm` | proved | K(x,y) = -K(y,x): the Z₂ symmetry exchanging elliptic/hyperbolic regions |
| `splitCurvature_zero_iff` | proved | K = 0 ↔ \|x\| = \|y\|: phase boundary is the pair of diagonals y = ±x |
| `splitCurvature_pos_iff` | proved | K > 0 ↔ \|x\| < \|y\|: elliptic region characterized by y-dominance |
| `splitCurvature_bound` | proved | \|K\| < 1: uniform strict bound, sharp but never attained |
| `splitCurvature_neg_iff` | proved | K < 0 ↔ \|y\| < \|x\|: derived from antisymmetry + positivity |
| `splitMetricDet_pos` | proved | det(g) > 0: the metric is non-degenerate everywhere |
| `splitCurvature_origin` | proved | K(0,0) = 0: the origin lies on the phase boundary |

## Research Directions

### Direction 1: Christoffel Symbols and Geodesic Equations

**Hypothesis**: The Christoffel symbols of the split metric can be computed explicitly, yielding a coupled ODE system ẍ = F(x, y, ẋ, ẏ), ÿ = G(x, y, ẋ, ẏ) where F and G involve only tanh and sech. Geodesics crossing the phase boundary |x| = |y| do so at most finitely many times for any initial condition with bounded energy.

**Test**: Compute Γ^k_{ij} for the split metric (6 independent symbols for a 2D diagonal metric), formalize them in Lean, and verify they satisfy the standard symmetry and metric-compatibility conditions. Then analyze the geodesic flow qualitatively.

**Why now**: The curvature sign characterization (splitCurvature_pos_iff) gives the precise geometric partition, and the curvature bound (splitCurvature_bound) provides the uniform ellipticity needed for ODE existence theory.

**If true**: Establishes the split metric as a tractable model for studying geodesic behavior across curvature transitions — relevant to general relativity (signature changes) and geometric optics.

**If false**: Would mean geodesics can oscillate infinitely across the phase boundary, suggesting the curvature transition is "soft" enough to permit recurrent crossing — itself an interesting phenomenon.

### Direction 2: Area Integrals and Gauss-Bonnet

**Hypothesis**: For a geodesic triangle T with vertices in both curvature regions, the total curvature integral ∫∫_T K dA separates as a difference of two independent 1D integrals with closed-form antiderivatives involving tanh and sinh, yielding an explicit angle-excess formula.

**Test**: Formalize the volume form dA = (cosh x / cosh y) dx dy, prove it is well-defined (using splitMetricDet_pos), compute ∫∫ K·dA over a rectangle [a,b]×[c,d], and verify the result matches ∫_a^b (tanh x / cosh x) dx · ∫_c^d (1/cosh y) dy minus the transposed integral.

**Why now**: splitMetricDet_pos guarantees the volume form is positive, and the separability K = f(x) - f(y) means the double integral factors.

**If true**: Gives a computational Gauss-Bonnet formula for split geometry, testable against numerical integration.

**If false**: The integral may not factor cleanly for non-rectangular regions, requiring a different decomposition strategy.

### Direction 3: Generalized Split Metrics — the (α, β)-Family

**Hypothesis**: For ds² = cosh^α(y) dx² + cosh^β(x) dy² with α, β ∈ ℝ, the curvature K(x,y) is always of the form f_β(x) + g_α(y) for explicit functions, and the phase boundary K = 0 is a curve of the form g_α(y) = -f_β(x). When α < 0 < β, the phase boundary is asymptotic to the diagonals y = ±x; when αβ > 0, the curvature has constant sign.

**Test**: Compute the Brioschi formula for the (α,β)-family symbolically, derive the curvature expression, and check whether the zero-curvature locus is always a separable curve. The key insight is that the separability of K as a sum f(x) + g(y) follows from the metric being a product of univariate functions.

**Why now**: The auxiliary lemmas on 1/cosh² monotonicity generalize directly to cosh^n for integer n, and the antisymmetry theorem extends to the case α = -β by the same algebraic argument.

**If true**: Opens a parameter space of mixed-curvature geometries, potentially connecting to spectral theory (Pöschl-Teller potentials arise for specific α, β).

**If false**: The separability may break for non-integer powers due to branch-cut issues, limiting the family to discrete parameter values.

### Direction 4: Completeness Analysis

**Hypothesis**: The split metric is geodesically complete despite the degeneration sech²(y) → 0 as |y| → ∞. The key insight is that while horizontal distances shrink, the vertical metric component cosh²(x) grows, and geodesics are forced to curve vertically before reaching infinity horizontally — preventing finite-time blowup.

**Test**: Prove that the length of any horizontal curve from (0,0) to (L, 0) is ≥ L (since g₁₁(0) = sech²(0) = 1), and more generally bound geodesic lengths from below using the Hopf-Rinow criterion. The curvature bound |K| < 1 provides the compactness control.

**Why now**: splitMetricDet_pos and the explicit metric components give quantitative control over curve lengths. Mathlib's metric space completeness API could be leveraged.

**If true**: Establishes the split metric as a complete non-compact surface with mixed curvature — a natural counterexample to naive intuitions about degenerate metrics.

**If false**: Would mean horizontal geodesics can escape to infinity in finite time when the metric degenerates, making the split surface incomplete — itself interesting as an explicit incompleteness example.

### Direction 5: Spectral Decomposition of the Split Laplacian

**Hypothesis**: The Laplace-Beltrami operator for the split metric separates variables, yielding Δ(X(x)Y(y)) = cosh²(y)X''Y + sech²(x)Y''X (up to lower-order terms), and each factor is a Pöschl-Teller-type Sturm-Liouville problem with known spectral properties.

**Test**: Compute the Laplacian explicitly from the metric, verify the separation of variables, and identify the resulting 1D eigenvalue problems. Check whether the Pöschl-Teller potential V(t) = -n(n+1)sech²(t) appears for integer spectral parameters.

**Why now**: The curvature bound |K| < 1 ensures the operator is uniformly elliptic on compact sets, and the separability of the metric makes the spectral analysis tractable.

**If true**: Connects split geometry to exactly solvable quantum mechanics (the Pöschl-Teller potential), potentially yielding explicit eigenfunctions and heat kernel asymptotics.

**If false**: The lower-order Christoffel terms may break the separation, requiring perturbation theory rather than exact solutions.
