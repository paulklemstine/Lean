# Theorem Trace (internal anti-hallucination ledger)

Source of truth:
- `Catalog/MachineLearning/UniversalApproximation/QuantitativeBoundsCore.lean` (complete, verified)
- `Catalog/MachineLearning/UniversalApproximation/SobolevQuadraticRate.lean` (Phase A diff; quadratic rate)

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `relu` | def | `relu x = max x 0` | yes (ramp) | §2 Def 1 |
| `grid` | def | `grid n k = k/n` | yes | §2 Def 2 |
| `cellSlope` | def | `cellSlope f n k = n·(f((k+1)/n) − f(k/n))` | yes | §2 Def 3 |
| `reluInterpNet` | def | `f0 + Σ_{k<n} cellSlope·(relu(x−k/n) − relu(x−(k+1)/n))` | yes | §2 Def 4 |
| `LipOn01` | def | `∀x,y∈[0,1], |f x − f y| ≤ L|x−y|` | yes | §2 Def 5 |
| `HasDerivOn01` | def | `∀x∈[0,1], HasDerivAt f (f' x) x` | yes | §2 Def 6 |
| `ramp_left` | lemma | `x≤a ⇒ relu(x−a)−relu(x−b)=0` | yes | §3 Lem 1 |
| `ramp_mid` | lemma | `a≤x≤b ⇒ relu(x−a)−relu(x−b)=x−a` | yes | §3 Lem 1 |
| `ramp_right` | lemma | `b≤x ⇒ relu(x−a)−relu(x−b)=b−a` | yes | §3 Lem 1 |
| `grid_succ_sub` | lemma | `grid n (k+1) − grid n k = 1/n` | implicit | §3 |
| `cellSlope_mul_width` | lemma | `cellSlope·(width) = f((k+1)/n)−f(k/n)` | implicit | §3 |
| `reluInterpNet_eq_on_cell` | lemma | network = `f(k/n)+cellSlope·(x−k/n)` on cell | yes | §4 Thm 1 |
| `interp_error_le` | lemma | interpolant error ≤ `L/n` on a cell | yes | §4 |
| `quantitative_uat_cell` | theorem | `|reluInterpNet − f| ≤ L/n` on a cell | yes | §4 Thm 2 |
| `quantitative_uat_core` | theorem | `|reluInterpNet − f| ≤ L/n` on `[0,1]` | yes (main) | §4 Thm 3 |
| `quantitative_uat_width` | theorem | `L ≤ ε·n ⇒ error ≤ ε`, width `2n=O(1/ε)` | yes | §4 Thm 4 |
| `sobolev_interp_error_cell` | lemma | cellwise error ≤ `M/n²` for `W^{2,∞}` | yes | §5 Thm 5 |
| `sobolev_quadratic_rate` | theorem | global error ≤ `M/n²` on `[0,1]` | yes | §5 Thm 6 |
| `sobolev_width_tradeoff` | theorem | width `2n=O(1/√ε)` for accuracy `ε` | yes | §5 Thm 7 |

Results that appear ONLY in future directions (NOT proven here, do not claim as theorems):
`shallowNet_discreteTV_le`, `tent_discreteTV`, sharp constant `M/(8n²)`.
