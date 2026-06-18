# Summary of changes for run 275e87e3-83de-4ca6-a756-564c795e4dfc
## Completed: Double Scaling Limit — Critical Phenomena for Wreath-Product Subgroup Pressure

### Lean 4 Formalization (`Catalog/Pythagorean/DoubleScalingLimit.lean`)

All theorems are fully proved with **zero `sorry`** statements, verified by `lean build` and axiom checking (only standard axioms: `propext`, `Classical.choice`, `Quot.sound`).

**New definitions introduced:**
- `WreathDefect` — measures deviation of wreath pressure from direct-power prediction
- `RelevanceRatio` — normalized defect measuring scaling dimension
- `AsymptoticallyIrrelevantAtExponent` — formalized irrelevance predicate
- `PerturbationRegime` — three-way classification (irrelevant/marginal/relevant)
- `SeparatesRegimes` — regime-separation predicate at critical exponent
- `PolynomialDefectEnvelope` — polynomial bound structure
- `CrossoverProfileConjecture` — formal conjecture statement

**7 fully proved theorems:**
1. **`wreath_defect_tendsto_zero_of_subcritical_nat`** — Subcritical irrelevance: |Δ(k,m)| ≤ C·m^a/k^b and m(k)^a/k^b → 0 implies Δ → 0. Proof via squeeze theorem.
2. **`wreath_pressure_per_copy_tendsto_betaSymm_of_subcritical`** — Per-copy stability: β_W(k,m)/m − β(S_k) → 0 below threshold. Proof via ε-δ and division by ≥1.
3. **`not_tendsto_zero_of_critical_lower_bound`** — Critical obstruction: |Δ| ≥ c > 0 eventually ⟹ Δ ↛ 0. Proof by contradiction via filter intersection.
4. **`relevance_ratio_bounded_of_polynomial_envelope`** — Bridge theorem: |Δ|·k^b/m^a ≤ C eventually. Proof via envelope multiplication.
5. **`defect_per_copy_tendsto_zero_of_subcritical`** — Per-copy defect |Δ|/m → 0 subcritically. Proof via squeeze.
6. **`defect_eventually_bounded_below`** — Quantitative obstruction: |Δ| ≥ c ⟹ |Δ| > c/2 eventually.
7. **`polynomial_bounds_force_threshold`** — Combined threshold: polynomial upper + critical lower bounds force sharp regime separation.

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) on the mathematical phase transition in group theory, connecting to renormalization group ideas. No mention of formal verification or proof assistants.
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, theorem statements, proof sketches, algorithms, computational experiments, and future work.
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format (Conjecture/Test/Impact/etc.), including grand challenges on crossover profiles and random matrix crossover.
- **`demo.py`** — Interactive CLI demo: input k, m, α; computes defect, scaling ratios, regime classification, and crossover collapse tests.
- **`algorithms.py`** — Implementations of critical exponent estimation, regime classification, crossover profile computation, and polynomial envelope fitting.
- **`applications.py`** — Applications to random group generation, hierarchical network symmetry, and phase diagram computation.
- **`viz_phase_diagram.py`** — Phase diagram visualization of (k,m) space colored by regime.
- **`viz_scaling_convergence.py`** — Four-panel convergence plot showing Theorems 1-3 in action.
- **`viz_crossover_profile.py`** — Data collapse test for the crossover profile conjecture.
- **`interactive_scaling.html`** — Interactive HTML/JS explorer with sliders for k, m, a, b.
- **`PACKAGE.json`** — Complete JSON bundle of all deliverables for web templating.