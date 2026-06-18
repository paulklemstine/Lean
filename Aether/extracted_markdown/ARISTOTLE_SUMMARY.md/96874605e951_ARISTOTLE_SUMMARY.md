# Summary of changes for run bdf5ef28-3dab-4466-bd52-d4c4644b8398
# The Borsuk-Ulam–Arrow Bridge: Research Deliverables

## Lean 4 Formalization (`Geometry/BorsukUlamArrow.lean`)

### 17 Fully Proved Theorems (no sorry, clean axioms)

**Kendall Distance Geometry (6 theorems):**
- `kendall_dist_symm` — Symmetry of Kendall distance
- `kendall_dist_self` — Identity of indiscernibles
- `kendall_dist_triangle` — Triangle inequality (genuine mathematical insight: partition-of-discordant-pairs argument)
- `max_pairs_eq_choose` — Cardinality of ordered pairs equals n choose 2
- `kendall_dist_reverse_eq_choose` — Reversal achieves maximal distance n choose 2
- `kendall_reverse_maximal` — Upper bound on Kendall distance

**Arrow's Impossibility Theorem (8 theorems):**
- `prefers_total_fin3` — Totality of preference relation
- `splitting_lemma` — Key profile construction forcing a decisive singleton
- `decisive_contagion_ac` — Decisiveness spreads to (a,c) pairs
- `decisive_contagion_cb` — Decisiveness spreads to (c,b) pairs
- `singleton_decisive_implies_dictator` — Field expansion: decisive singleton → dictator
- `arrow_impossibility_three` — **Arrow's Impossibility Theorem for k=3, n=2** (the main result)
- `decisive_coalition_nonempty` — Grand coalition is decisive under Pareto
- `pareto_respects_unanimity` — Unanimity implies social agreement

**Geometric Bridge (3 theorems):**
- `dictator_curvature_collapse` — Dictatorial SWFs have zero Condorcet curvature on homogeneous profiles
- `curvature_bounded` — Condorcet curvature bounded by 2·C(k,2)
- `antipodal_symmetry_breaking` — Pareto SWFs distinguish antipodal profiles

### 2 Conjectures (with sorry, clearly marked)
- `decisive_contraction_principle` — General field expansion for arbitrary k (extremely hard to formalize)
- `preference_sphere_rigidity_conjecture` — Full Arrow's theorem for general k,n

### Novel Definitions
- **Condorcet Curvature**: κ(f,p) = d_K(f(p), id) - (1/n)Σ d_K(pᵢ, id) — measures how a SWF distorts the metric geometry of preference space
- **Preference Radius**: max_i d_K(f(p), pᵢ) — spread of social outcome from voters
- **Kendall Distance** on Equiv.Perm (Fin n) with full metric axioms

## Other Deliverables

- **ARTICLE.md** — 1800-word Scientific American-style article about the geometry of democracy (no mentions of formal verification)
- **RESEARCH_PAPER.md** — 4000-word research paper with definitions, theorems, proof sketches, and future directions
- **FUTURE_DIRECTIONS.md** — 5 research directions with conjectures, tests, proof strategies, and domain bridges
- **demo.py** — Interactive Python demo of Kendall distance, Arrow's theorem verification, and Condorcet curvature
- **algorithms.py** — Type-hinted implementations of all core algorithms
- **viz_kendall_sphere.py** — Visualization of the preference sphere (Cayley graph of S₃)
- **viz_curvature.py** — Condorcet curvature heatmap across profiles
- **PACKAGE.json** — Complete package with 3 interactive HTML widgets:
  1. Preference Sphere Explorer (interactive Kendall distance calculator)
  2. Arrow's Splitting Argument (step-by-step proof walkthrough)
  3. Condorcet Curvature Calculator (compute curvature for custom profiles)