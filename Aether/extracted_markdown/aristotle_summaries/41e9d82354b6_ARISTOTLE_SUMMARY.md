# Summary of changes for run d7ae89bf-a3f3-4dc2-8766-2369182359e6
## Research Cycle: Self-Avoiding Walks and Tropical Geometry

### Lean 4 Proofs (18 theorems, 0 sorries)

All proofs are machine-verified with only standard axioms (propext, Classical.choice, Quot.sound). Three files in `Bridges/SAWTropical/`:

**SubadditiveSeq.lean** — Subadditive sequences and Fekete-type bounds:
- `log_submult_is_subadditive`: Log of submultiplicative sequence is subadditive
- `subadditive_mul_bound`: f(kn) ≤ k·f(n) for subadditive f with f(0) ≤ 0
- `fekete_decomposition`: f(n) ≤ ⌊n/d⌋·f(d) + f(n mod d) — the core Fekete decomposition
- `submult_growth_rate_le`: Growth rate ≤ c(n)^{1/n} for all n (infimum property)
- `submult_growth_rate_pos`: Growth rate > 0 when c(n) ≥ 1
- `submult_upper_bound`: c(n) ≤ c(1)^n by induction
- `growth_rate_le_c1`: Growth rate ≤ c(1)

**TropicalConvergence.lean** — Tropical convergence criteria and bridge theorems:
- `tropical_convergent_of_lt_neg_growth`: Tropical series converges when v < -γ
- `tropical_divergent_of_gt_neg_growth`: Tropical series diverges when v > -γ
- `growthRate_le_val_div`: Growth rate is a lower bound on val(n)/n
- `classical_tropical_radius_bridge`: Growth rate = inf(log c(n)/n)
- `saw_generating_convergence_iff_tropical`: x < 1/μ ⟺ log x < -γ (main bridge)
- `connective_constant_pos`: Connective constant > 0

**NienhuisConstant.lean** — Irrationality of √(2+√2):
- `nienhuis_sq`: (√(2+√2))² = 2 + √2
- `nienhuis_minimal_poly`: α⁴ - 4α² + 2 = 0
- `no_rational_roots_of_nienhuis_poly`: x⁴ - 4x² + 2 has no rational roots
- `nienhuis_irrational`: √(2+√2) is irrational
- `sqrt2_irrational`: √2 is irrational

### Novel Definitions
- `IsSubadditive`, `IsSubmultiplicative`: Sequence properties for SAW counts
- `TropicalValuation`: Subadditive valuation framework for tropical analysis
- `submultGrowthRate`, `connectiveConstant`: Connective constant as infimum/exponential
- `TropicalConvergent`, `TropicalDivergent`: Tropical convergence predicates
- `nienhuisConstant`: The Nienhuis constant √(2+√2)

### Key Mathematical Insights
1. The Fekete decomposition (Theorem 3) uses the division algorithm to bound subadditive sequences — removing any step breaks the proof
2. The tropical convergence theorem (Theorems 7-8) precisely characterizes convergence via a piecewise-linear criterion — the proof requires constructing explicit bounds from subadditivity
3. The irrationality proof chains through the minimal polynomial and rational root theorem — each algebraic identity is essential

### Falsifiable Conjecture
The Nienhuis polynomial x⁴ - 4x² + 2 is irreducible over ℚ (not just root-free). Testable by checking it has no factorization as a product of two quadratics with rational coefficients.

### Deliverables
- **ARTICLE.md**: Popular-science article on SAW-tropical connections (no mention of formal verification)
- **RESEARCH_PAPER.md**: Technical paper with proofs, algorithms, and references
- **FUTURE_DIRECTIONS.md**: 5 research directions including discrete holomorphicity (grand challenge) and quantitative Fekete bounds (extension)
- **demo.py**: Working demo enumerating SAWs, verifying submultiplicativity, testing tropical convergence
- **algorithms.py**: Type-hinted implementations of all algorithms
- **viz_tropical_convergence.py**, **viz_saw_growth.py**: Visualization scripts
- **PACKAGE.json**: Complete package with 3 interactive HTML demos (tropical convergence explorer, Fekete growth rate visualizer, Nienhuis polynomial explorer)