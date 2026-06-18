# Summary of changes for run b00c2c0d-ccac-45f5-b12f-d4680f434a71
## Completed: Double Scaling Limit for Wreath-Product Subgroup Pressure

### Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Pythagorean/DoubleScalingLimit.lean` — 320 lines, **zero sorries**, clean build with no warnings.

**New Definitions (6):**
- `WreathDefect` — the fundamental observable Δ(k,m) = β_W(k,m) − m·β(S_k)
- `RelevanceRatio` — scaling-dimension observable Φ_α(k,m)
- `AsymptoticallyIrrelevantAtExponent` — defect vanishing predicate
- `SeparatesRegimes` — critical exponent separation predicate
- `PerturbationRegime` — enumeration of irrelevant/marginal/relevant
- `CrossoverProfileConjecture` — formal conjecture statement

**Proved Theorems (10, all sorry-free):**

1. **`wreath_defect_tendsto_zero_of_subcritical_nat`** — If |Δ(k,m)| ≤ C·m^a/k^b and m(k)^a/k^b → 0, then Δ(k,m(k)) → 0. This identifies the critical exponent α_c = b/a.

2. **`wreath_pressure_per_copy_tendsto`** — If Δ → 0 and m(k) > 0 eventually, then β_W(k,m(k))/m(k) − β(S_k) → 0. Same universality class below threshold.

3. **`not_tendsto_zero_of_eventually_ge`** — If |f(k)| ≥ c > 0 eventually, then f does not converge to 0. Critical obstruction theorem.

4. **`wreath_defect_not_tendsto_zero_of_lower_bound`** — Wreath defect instantiation of the obstruction.

5. **`abs_wreath_defect_tendsto_zero_of_subcritical`** — Absolute defect vanishing (bridge to statistical mechanics scaling dimension).

6. **`separatesRegimes_of_bounds`** — Polynomial upper bound + persistent witness = regime separation.

7. **`asymptotically_irrelevant_of_polynomial_bound`** — Polynomial bound implies asymptotic irrelevance.

8. **`wreath_defect_tendsto_zero_of_subcritical_real`** — Real-exponent version with rpow.

9. **`wreath_pressure_stable_of_subcritical`** — Combined subcritical stability theorem.

10. **`defect_vanishing_monotone`** — Monotonicity: smaller m implies smaller defect.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Written Deliverables

- **`ARTICLE.md`** — 1,800-word popular science article explaining the phase-transition discovery, with no mention of formal verification tools.
- **`RESEARCH_PAPER.md`** — 4,000-word research paper with abstract, full theorem statements, proof sketches, algorithms, computational experiments, and future work.
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format (Conjecture, Test, Impact, etc.), including grand challenges (explicit critical exponents for symmetric groups, random matrix bridge) and solid extensions.

### Python Code

- **`demo.py`** — Interactive demonstration showing subcritical, critical, and supercritical regimes with collapse test.
- **`algorithms.py`** — Implementation of wreath defect computation, critical exponent search, regime classification, and polynomial bound verification.
- **`applications.py`** — Applications to hierarchical network design, cryptographic security, and molecular symmetry.

### Visualizations

- **`viz_phase_diagram.py`** — Phase diagram heatmap in the (k,m) plane with critical boundary.
- **`viz_defect_scaling.py`** — Three-panel plot of defect, per-copy correction, and rescaled defect across regimes.
- **`viz_collapse.py`** — Data collapse test showing that only the correct α produces collapse.

### Interactive Demos

- **`interactive_phase.html`** — Interactive phase diagram with sliders for k, m, a, b.
- **`interactive_scaling.html`** — Interactive defect scaling explorer with adjustable growth exponent.

### Data Package

- **`PACKAGE.json`** — Complete JSON bundle of all artifacts for web templating.