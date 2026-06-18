# Summary of changes for run a227e2ad-0096-4027-94f2-e19d8a0d1fb0
## Split Geometry: Formalized in Lean 4

Created `Geometry/SplitGeometry.lean` — a complete formalization of the "split metric" ds² = dx²/cosh²(y) + cosh²(x)dy² on ℝ².

### Key Mathematical Result

The concept proposed that this metric has curvature K = -sech²(y) + sech²(x) that changes sign, creating regions of both elliptic and hyperbolic behavior. **We prove this claim is false.** The correct Gaussian curvature formula is:

K(x,y) = -cosh²(y) + (2 - cosh²(y)) / (cosh²(y) · cosh²(x))

and we establish that K ≤ 0 everywhere, with K = 0 only at the origin. The split metric is thus a globally non-positively curved surface — not a sign-changing geometry.

### Proven Theorems (all sorry-free, standard axioms only)

1. **Metric positivity**: `g₁₁_pos`, `g₂₂_pos`, `metricDet_pos` — the metric components and determinant are strictly positive
2. **`K_origin`**: K(0,0) = 0
3. **`K_nonpos`**: K(x,y) ≤ 0 for all (x,y) ∈ ℝ² — the central result
4. **`K_eq_zero_iff`**: K(x,y) = 0 ↔ x = 0 ∧ y = 0 — curvature vanishes uniquely at the origin
5. **`K_neg_on_axes`**: K is strictly negative on both coordinate axes away from the origin
6. **`K_le_neg_of_large_y`**: When cosh²(y) ≥ 2, the curvature K ≤ -1
7. **`K_ge_lower_bound`**: K(x,y) ≥ -cosh²(y) - 1 — a lower bound
8. **`K_le_along_x_axis`**: K(x,0) = -1 + 1/cosh²(x) — explicit formula on the x-axis
9. **Christoffel symbols**: Γ¹₁₂ = -tanh(y), Γ²₁₂ = tanh(x), vanishing at origin
10. **Algebraic helpers**: `curvature_numerator_nonpos`, `curvature_numerator_eq_zero_iff`, `cosh_eq_one_iff`

### PEGB Structure
Each main theorem has Proof, Example, Generalization, and Boundary analysis as required by the v5 depth requirements.

### Proof Strategy
The key algebraic insight: writing c = cosh²(y) ≥ 1 and d = cosh²(x) ≥ 1, the curvature numerator is -(c²d + c - 2), and c²d + c - 2 = c²(d-1) + (c-1)(c+2) ≥ 0 since both factors are non-negative. Equality forces c = d = 1, hence x = y = 0.