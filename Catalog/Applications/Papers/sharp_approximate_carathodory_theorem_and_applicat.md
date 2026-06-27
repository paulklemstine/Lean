# THEOREM TRACE (internal — anti-hallucination ledger)

Every result below is taken verbatim from the Phase A Lean source. The package
prose may ONLY refer to these names and statements.

## `Greedy.lean` (ApproxCaratheodory.Greedy) — the new sharp/deterministic result

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `dev` (def) | `dev p V i = V i − x`, where `x = Σⱼ pⱼ Vⱼ` | yes | yes |
| `bestIdx` (def) | arg-min over `i` of `‖s + dev i‖²` | yes | yes |
| `greedySum` (def) | `s₀ = 0`, `s_{t+1} = s_t + dev(bestIdx s_t)` | yes | yes |
| `greedyIdx` (def) | `greedyIdx t = bestIdx (greedySum t)` | yes | yes |
| `tau` (def) | `τ = Σᵢ pᵢ ‖dev i‖²` | yes | yes |
| `bestIdx_spec` | `‖s + dev(bestIdx s)‖² ≤ ‖s + dev i‖²` for all `i` | yes | yes |
| `sum_weighted_dev_eq_zero` | `Σᵢ pᵢ • dev i = 0` (when `Σ pᵢ = 1`) | yes | yes |
| `avg_sq_dev` | `Σᵢ pᵢ ‖s + dev i‖² = ‖s‖² + τ` | yes | yes |
| `step_bound` | `‖s + dev(bestIdx s)‖² ≤ ‖s‖² + τ` | yes | yes |
| `greedySum_sq_le` | `‖s_k‖² ≤ k·τ` | yes | yes |
| `tau_eq` | `τ = (Σᵢ pᵢ‖Vᵢ‖²) − ‖x‖²` | yes | yes |
| `tau_le_sq` | `τ ≤ R²` when `‖Vᵢ‖ ≤ R` | yes | yes |
| `greedySum_eq` | `s_k = (Σ_{t<k} V(greedyIdx t)) − k•x` | yes | yes |

Main corollary (assembled from `greedySum_eq` + `greedySum_sq_le` + `tau_le_sq`):
`‖x − (1/k) Σⱼ V(greedyIdx j)‖² ≤ τ/k ≤ R²/k`.

## `Maurey.lean` (ApproxCaratheodory) — probabilistic base case

| Lean name | Statement |
|---|---|
| `exists_le_weighted_average` | some `i` has `g i ≤ Σⱼ pⱼ g j` |
| `weighted_mean_sq_dist` | `Σᵢ pᵢ‖x − Vᵢ‖² = (Σᵢ pᵢ‖Vᵢ‖²) − ‖x‖²` |
| `maurey_one_point` | `∃ i, ‖x − Vᵢ‖² ≤ R²` |
| `maurey_one_point_variance` | `∃ i, ‖x − Vᵢ‖² ≤ R² − ‖x‖²` |

## `MaureyGeneral.lean` (ApproxCaratheodory.General) — full √k rate

| Lean name | Statement |
|---|---|
| `expectation_bound` | product-weighted mean of `‖x − (1/k)Σ V(ωⱼ)‖²` is `≤ R²/k` |
| `maurey_sqrt` | `∃ f, ‖x − (1/k)Σⱼ V(f j)‖² ≤ R²/k` |
| `marg_diag`, `marg_off`, `prod_weight_*` | marginalization helpers |

## `Contraction.lean` (DelaunayContraction) — exponential refinement decay

| Lean name | Statement |
|---|---|
| `ContractionProcess` (struct) | `d : ℕ→ℝ`, `λ>1`, `d≥0`, `d(k+1) ≤ (1/λ) d k` |
| `diam_le_pow` | `d k ≤ (1/λ)^k · d 0` |
| `diam_tendsto_zero` | `d k → 0` |
| `exists_steps_below` | `∀ ε>0, ∃ N, ∀ k≥N, d k < ε` |
| `minicenter_segment_halves` | midpoint splits edge into two equal halves `= dist/2` |
| `segmentBisection` / `segmentBisection_bound` | concrete process with `λ=2`, `d k = D/2^k` |

## `Bridge.lean` (DelaunayContraction.Bridge) — cumulative budget

| Lean name | Statement |
|---|---|
| `summable_of_contraction` | `Summable d` |
| `total_budget` | `Σ'_k d k ≤ D·λ/(λ−1)` |
| `covering_tendsto_zero` | `cov k → 0` when `cov k ≤ d k` |
| `covering_budget` | `Σ'_k cov k ≤ D·λ/(λ−1)` |
