# Summary of changes for run e368f734-c963-4b5d-8fcc-3d3f0d279161
## Completed: Renormalization Group for Subgroup Ensembles

### Lean 4 Formalization (`Catalog/Pythagorean/SubgroupRenormalization.lean`)

**Zero `sorry` statements.** All 15 theorems fully machine-verified with standard axioms (propext, Classical.choice, Quot.sound). ~320 lines.

**Novel definitions introduced:**
- `SubgroupEnsemble` — weighted finite family of subgroups with nonneg weights
- `SubgroupComplexity` — abstract complexity measure on subgroups
- `CoarseGraining` — RG operator with pressure scaling law
- `IsRGFixedPoint` — fixed-point predicate for coarse-graining
- `SameUniversalityClass` — equivalence relation via pressure under all RG iterates

**Main theorems proved:**

1. **`pressure_iterate_of_coarseGraining`** — Fundamental RG law: pressure transforms geometrically under iterated coarse-graining: Π(ℛⁿ(E)) = λⁿ · Π(E). Proved by induction.

2. **`pressure_invariant_at_fixedPoint`** — At a fixed point with unit scaling, pressure is exactly invariant under all iterates. Uses `Function.iterate_fixed`.

3. **`criticalExponent_from_scaling`** — The critical exponent identity α = log(λ)/log(μ) linking pressure eigenvalue to parameter eigenvalue. Uses `Real.log_rpow`.

4. **`pressure_scaling_exponent_formula`** — Parameterized version: if Π(μt) = λ·Π(t) and Π(t) = t^α, then α = log(λ)/log(μ).

5. **`ensemblePressure_product_extensivity`** — Product extensivity F(n) = n·F(1) from the recursion. Proved by induction with `push_cast; ring`.

6. **`intensivePressure_convergence`** — Thermodynamic limit: F(n)/n → F(1). Uses `Filter.Tendsto` and `eventually_ne_atTop`.

7. **`pressure_contraction`** — If |λ| < 1, iterated RG drives pressure to zero. Uses `tendsto_pow_atTop_nhds_zero_of_abs_lt_one`.

8. **`normalized_subadditive_convergence`** — Fekete's lemma: subadditive sequences a(n)/n converge. Full constructive proof.

9. **`scalar_linearization_iter`** — Dynamical systems bridge: iterated linear maps give power growth.

10. **`sameUniversalityClass_refl/symm/trans`** — Universality class is an equivalence relation.

11. **`fixedPoints_universalityClass_iff`** — Two fixed points share a universality class iff they have equal pressure.

12. **`scaling_composition`** — Composition of scaling maps gives product of scales.

### Other Deliverables

- **`ARTICLE.md`** — 2500-word popular science article on how phase transition ideas enter finite group theory
- **`RESEARCH_PAPER.md`** — 4000-word research paper with abstract, definitions, theorems, proof sketches, experiments, references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format including conjectures, tests, domain bridges (spectral theory, profinite groups, quantum information, Cohen-Lenstra heuristics, continuous-time RG)
- **`demo.py`** — 6 demonstrations: pressure computation, RG flow, fixed-point detection, critical exponent extraction, universality classes, conjecture testing
- **`algorithms.py`** — Implementations of partition function, RG iteration, critical exponent extraction, universality class detection, pressure contraction
- **`applications.py`** — Phase transition detection, permutation code analysis, cryptographic key-space analysis
- **Visualization scripts** — 3 matplotlib scripts: pressure landscape, RG flow/contraction, critical exponents/universality
- **Interactive HTML demos** — 2 self-contained demos with sliders: RG pressure contraction, critical exponent explorer
- **`PACKAGE.json`** — Complete JSON package bundling all artifacts