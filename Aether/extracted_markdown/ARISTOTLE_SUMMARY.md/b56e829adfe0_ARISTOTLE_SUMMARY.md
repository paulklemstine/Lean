# Summary of changes for run 1c638392-6911-40b6-91af-166a8b149949
## Split Geometry: A Riemannian Geometry with Sign-Changing Curvature

### Formally Verified Mathematics (Lean 4)

**`Geometry/SplitGeometry.lean`** — 17 theorems, **zero `sorry`**, all using only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The file builds successfully.

#### Novel Definitions
- **`DiagMetric2D`**: A structure for diagonal Riemannian metric tensors with built-in positivity proofs
- **`SplitPhase`**: An inductive type classifying points as elliptic, flat, or hyperbolic
- **`splitCurvature`**: The Gaussian curvature K(x,y) = sech²(x) − sech²(y)
- **`splitDivergence`**: An information-theoretic divergence between points
- **`SplitTriangle`**: A triangle with vertices in all three phase regions
- **`phaseIndicator`** and **`countSignChanges`**: Computational tools for phase analysis

#### Key Theorems (all proved, no sorry)
1. **`splitCurvature_diag`**: K(a,a) = 0 — curvature vanishes on diagonal y = x
2. **`splitCurvature_antidiag`**: K(a,−a) = 0 — curvature vanishes on anti-diagonal
3. **`splitCurvature_antisymm`**: K(x,y) = −K(y,x) — perfect antisymmetry
4. **`splitCurvature_pos_iff`**: K > 0 ↔ |y| > |x| — elliptic region characterization (uses `inv_lt_inv₀`, `pow_lt_pow_iff_left₀`, multi-step reasoning)
5. **`splitCurvature_neg_iff`**: K < 0 ↔ |x| > |y| — hyperbolic region characterization
6. **`splitCurvature_zero_iff`**: K = 0 ↔ |x| = |y| — phase boundary (uses `contrapose!`, `lt_or_gt_of_ne`, `nlinarith`)
7. **`splitCurvature_abs_le_one`**: |K| ≤ 1 everywhere (uses `abs_sub_le_iff`, `nlinarith` with multiple lemma applications)
8. **`splitMetric_areaElement`**: √(EG) = cosh(x)/cosh(y)
9. **`splitDivergence_eq_zero_iff`**: D = 0 ↔ cosh-coordinates match (multi-step with `Or.casesOn`, `linarith`)
10. **`splitTriangle_curvature_opposite_signs`**: Elliptic and hyperbolic vertices have opposite curvature signs
11. Plus 7 more supporting theorems

#### Depth Requirements Met
- ≥3 deep proofs: `splitCurvature_zero_iff` (contrapositive + case analysis), `splitCurvature_pos_iff` (inverse/power monotonicity chain), `splitCurvature_abs_le_one` (nlinarith with 4 helper lemmas), `splitDivergence_eq_zero_iff` (case analysis on disjunctions)
- Cross-domain: Information geometry connection via `splitDivergence`
- Falsifiable conjecture: Geodesic phase-crossing bound (≤4 crossings), testable via numerical integration

### Other Deliverables

- **`ARTICLE.md`** — ~2200-word popular science article about split geometry (no mention of formal verification or proof assistants)
- **`RESEARCH_PAPER.md`** — ~4000-word research paper with abstract, definitions, full theorem statements, proof sketches, algorithms, applications
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including 2 grand challenges (Gauss-Bonnet for split geometry, natural gradient optimization) and 3 extensions
- **`demo.py`** — Demonstrates all proved theorems with numerical verification
- **`algorithms.py`** — Christoffel symbol computation, RK4 geodesic integration, curvature field evaluation, split triangle area computation
- **`applications.py`** — Anisotropic wave propagation, Fisher information metric, cosmological anisotropy model
- **`viz_curvature_field.py`**, **`viz_geodesics.py`**, **`viz_area_element.py`** — matplotlib visualizations
- **`interactive_curvature.html`**, **`interactive_geodesic.html`** — Interactive HTML/JS demos
- **`PACKAGE.json`** — Complete JSON bundle of all artifacts