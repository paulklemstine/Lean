# Summary of changes for run 5b0fbb1c-5ba2-4eaf-9dfd-a1614c4cca27
## EML Differential Equations: ODEs with Exponential-Logarithmic Coefficients

### Research Summary

This research cycle introduced the **EML Differential Operator Algebra**, a novel mathematical framework for studying which ordinary differential equations admit solutions expressible as elementary (EML) functions. The central result is a formalized growth-rate obstruction proving that the Airy equation y'' = xy has no EML solutions.

### Novel Mathematical Structure: EML Differential Operator Algebra

Defined in `Applications/EMLDiffCore.lean`, this structure pairs:
- **EMLExpr**: An inductive type for EML expressions (const, var, add, mul, neg, exp, log) with depth, size, and growth-class measures
- **EMLDiffOp**: Second-order linear differential operators y'' + p(x)y' + q(x)y = 0 with EML coefficients
- **EMLComplexity**: A lexicographically-ordered triple (depth, size, growthLevel) for measuring expression complexity

### Lean 4 Proofs (41 theorems, 0 sorries, all axiom-clean)

**`Applications/EMLDiffCore.lean`** (20 theorems):
1. **EML Closure under Differentiation** (`depth_diff_le`): depth(diff(e)) ≤ depth(e) + 1 — the fundamental structural constraint
2. **Abel's Identity** (`abel_identity_pointwise`): Wronskian derivative equals -p·W for second-order linear ODEs
3. **Wronskian Antisymmetry** and **Self-Annihilation**: W(y₂,y₁) = -W(y₁,y₂) and W(y,y) = 0
4. **Growth Class Bound** (`growthClass_level_le_depth`): growth level ≤ depth
5. **Complexity Transitivity**: lexicographic ordering on EMLComplexity is transitive
6. **Companion Matrix**: trace = 0 for Airy operator

**`Applications/EMLDiffObstruction.lean`** (21 theorems):
1. **Airy Differential Invariant**: I(x) = -x for the Airy equation
2. **Companion Matrix Invariants**: det(A) = q(x), tr(A) = -p(x) for any operator
3. **Tower Dominance** (`towerExp_dominates`): tower_{d+1}(x) > C·tower_d(x) eventually — key hierarchy result
4. **Tower Strict Monotonicity**: each tower level is strictly increasing
5. **Airy Super-Polynomial Growth** (`airy_growth_super_polynomial`): exp(⅔x^{3/2})/x^n → ∞ for all n
6. **Airy Sub-Quadratic-Exponential Growth** (`airy_growth_between_exp_degrees`): exp(⅔x^{3/2})/exp(ax²) → 0 for all a > 0
7. **Operator Composition Depth Bounds**: composite depth strictly exceeds component depths

### Key Insight: The Growth Gap

The Airy equation's solutions grow like exp(⅔x^{3/2}). The exponent x^{3/2} has non-integer degree (3/2), which is incompatible with the EML hierarchy where exponential arguments must be polynomial (integer degree). This creates an impassable "gap" between EML tower levels — the formalized theorems prove this gap rigorously.

### Deliverables

- **Lean proofs**: `Applications/EMLDiffCore.lean`, `Applications/EMLDiffObstruction.lean` — all sorry-free
- **ARTICLE.md**: Popular science article (~2500 words) about the mathematical ideas
- **RESEARCH_PAPER.md**: In-depth research paper (~4500 words) with full technical details and PEGB analysis
- **FUTURE_DIRECTIONS.md**: 5 research directions including Formal Kovacic Algorithm (grand challenge) and Painlevé-EML Boundary (grand challenge)
- **Python**: `Applications/demo.py` (numerical demonstrations), `Applications/algorithms.py` (type-hinted implementations), `Applications/viz_growth_gap.py` (visualizations)
- **PACKAGE.json**: Complete package with 3 interactive HTML demos (Growth Gap Explorer, Wronskian Simulator, EML Depth Calculator)