# Summary of changes for run b0f25051-3c90-4ced-a141-f6ae0cb201d4
## Completed: Double-Scaling Limit Theory for Wreath-Product Subgroup Pressure

### Lean 4 Proofs (`Pythagorean/DoubleScalingLimit.lean`)

All theorems are fully proved with **zero sorries**. The file introduces 6 new definitions and proves 7 theorems:

**New Definitions:**
- `WreathDefect` — the fundamental observable Δ(k,m) = β_W(k,m) − m·β(S_k)
- `RelevanceRatio` — scaling-dimension observable Φ_α(k,m) = |Δ|·k^α/m
- `AsymptoticallyIrrelevantAtExponent` — formal irrelevance predicate
- `SeparatesRegimes` — regime separation predicate (irrelevant ∧ relevant exist)
- `PerturbationRegime` — inductive type with irrelevant/marginal/relevant
- `CrossoverProfileConjecture` — formal statement of the crossover conjecture

**Proved Theorems:**
1. **`wreath_defect_tendsto_zero_of_subcritical_nat`** — If |Δ(k,m)| ≤ C·m^a/k^b and m(k)^a/k^b → 0, then Δ(k,m(k)) → 0. Identifies α_c = b/a as the critical exponent.
2. **`wreath_pressure_per_copy_tendsto_betaSymm_of_subcritical`** — Below threshold, per-copy pressure β_W/m converges to β(S_k).
3. **`not_tendsto_zero_of_critical_lower_bound`** — If |Δ| ≥ c > 0 eventually, defect does not tend to zero (obstruction theorem).
4. **`relevance_ratio_bound_of_defect_bound`** — Polynomial envelope transfers to relevance ratio bounds.
5. **`polynomial_bounds_separate_regimes`** — Polynomial bounds + witness sequence imply genuine regime separation.
6. **`asymptotically_irrelevant_of_le_exponent`** — Monotonicity: irrelevance at exponent α implies irrelevance at smaller exponents.
7. **`wreath_per_copy_stable_of_polynomial_bound`** — Combined theorem: polynomial bounds directly yield per-copy stability.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) explaining the phase-transition discovery without mentioning formal verification.
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, theorems, proof sketches, algorithms, computational experiments, and future work.
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with the required structured format, including 2 grand challenges (crossover profile universality, representation-theoretic critical exponent) and 3 extensions (iterated wreath products, GAP verification, random matrix bridge).
- **`demo.py`** — Interactive demonstration of scaling laws with configurable parameters.
- **`algorithms.py`** — Implementations of defect computation, critical exponent estimation, and regime classification.
- **`applications.py`** — Concrete applications to subgroup pressure, universality testing, and finite-size scaling.
- **`visualize_phase_diagram.py`** — Phase diagram heatmap visualization.
- **`visualize_scaling_collapse.py`** — Scaling collapse test for crossover conjecture.
- **`visualize_defect_decay.py`** — Defect decay across regimes.
- **`PACKAGE.json`** — Complete JSON bundle of all artifacts.