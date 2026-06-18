# Summary of changes for run 055bdb60-7537-4ffd-8439-fd019d92a730
## Completed: Formal Percolation Threshold Theory

### Lean 4 Formal Proofs (Zero Sorries)

Three fully verified Lean files under `Speculative/Percolation/`:

**1. `TriangularThreshold.lean`** — Exact algebraic threshold for triangular lattice bond percolation:
- `triangularCriticalPolynomial` — defines p³ - 3p + 1
- `exists_unique_triangular_bond_threshold` — **unique root in (0,1)** proved via IVT + strict monotonicity
- `triangular_bond_threshold_closed_form` — **root = 2·sin(π/18)** proved via triple-angle formula
- `honeycomb_bond_threshold_closed_form` — dual honeycomb threshold = 1 - 2·sin(π/18)
- `square_bond_duality_fixed_point` — duality map p ↦ 1-p fixes p = 1/2
- Supporting lemmas: polynomial evaluation at endpoints, derivative, strict anti-monotonicity, continuity, sin(3θ) identity

**2. `BernoulliMeasure.lean`** — Bernoulli product measure and monotonicity:
- `bernoulliWeight` / `bernoulliProb` — finite Bernoulli product measure
- `bernoulliWeight_total` — normalization: weights sum to 1
- `bernoulliWeight_nonneg` — non-negativity for p ∈ [0,1]
- `increasing_event_prob_monotone` — **core theorem: Bernoulli probability of any increasing event is monotone on [0,1]**, proved by induction on dimension with coordinate conditioning

**3. `Percolation.lean`** — Graph percolation definitions and properties:
- `SiteConnected` / `BondConnected` — connectivity in site/bond percolation
- `siteConnected_increasing` / `bondConnected_increasing` — connectivity is an increasing event
- `gridGraph` — nearest-neighbor grid graph on Fin n × Fin n
- `HasHorizontalCrossing` — horizontal crossing event
- `hasHorizontalCrossing_increasing` — crossing is increasing

All proofs depend only on standard axioms (propext, Classical.choice, Quot.sound).

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2500 words) about percolation thresholds, connecting to coffee filters, epidemics, and material science
- **`RESEARCH_PAPER.md`** — Comprehensive research paper with theorem statements, proof sketches, algorithms, computational experiments, and references
- **`FUTURE_DIRECTIONS.md`** — Five falsifiable conjectures: finite-size convergence, dual crossing dichotomy, Russo's formula, algebraic certification, site-bond comparison
- **`demo.py`** — Demonstrates triangular threshold computation, crossing probability monotonicity, finite-volume thresholds
- **`algorithms.py`** — Exact crossing probability enumeration, polynomial root isolation, threshold extraction
- **`applications.py`** — Network resilience, forest fire spread, epidemic thresholds, material conductivity
- **`PACKAGE.json`** — JSON bundle of all artifacts for web templating