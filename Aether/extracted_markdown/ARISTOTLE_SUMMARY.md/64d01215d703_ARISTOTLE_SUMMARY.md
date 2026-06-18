# Summary of changes for run 9d971316-04c7-4a2c-a80c-9ef0d2d8a2af
## Completed: ML Universal Approximation — Width vs Depth Trade-offs

### Deliverables

**`MachineLearning/DepthWidth.lean`** — 226 lines, 0 sorry, builds cleanly.

**`FUTURE_DIRECTIONS.md`** — 5 research directions with falsifiable hypotheses.

### Theorem Declarations & Results

| # | Name | Status | Significance |
|---|------|--------|-------------|
| 1 | `relu_abs_decomposition` | **proved** | `|x| = relu(x) + relu(-x)` — absolute value is a width-2 ReLU network |
| 2 | `tent_lower_half` / `tent_upper_half` | **proved** | Piecewise linear structure: `tent(x) = 2x` on `[0,½]`, `tent(x) = 2(1-x)` on `[½,1]` |
| 3 | `tent_iter_peak` | **proved** | `tent^[n](1/2^n) = 1` for `n ≥ 1` — depth-n composition resolves exponentially fine features |
| 4 | `tent_iter_grid_even` / `tent_iter_grid_odd` | **proved** | Grid evaluation: `tent^[n](k/2^n) = 0` for even `k`, `= 1` for odd `k` — the combinatorial core of depth separation |
| 5 | `tent_iter_oscillation_count` | **proved** | Corollary: `tent^[n]` oscillates between 0 and 1 exactly `2^{n-1}` times on `[0,1]` |

### Mathematical Content

The file formalizes the tent map `T(x) = 1 - |2x - 1|` and proves that its n-fold iterate exhibits exponential oscillation complexity. The key theorem (`tent_iter_grid_even`/`tent_iter_grid_odd`) shows that `T^n` evaluates to 0 at even dyadic rationals and 1 at odd dyadic rationals on the grid `{k/2^n}`. This means `T^n` has `2^{n-1}` full oscillations between 0 and 1.

Since the tent map itself is computable by a 2-neuron ReLU layer (via `relu_abs_decomposition`), `T^n` is computable by a depth-n network of constant width. But any depth-1 network approximating `T^n` within 1/2 must have at least `2^{n-1}` linear pieces (requiring exponential width). This is the Telgarsky depth separation phenomenon.

### Axiom Verification

All theorems depend only on `propext`, `Classical.choice`, and `Quot.sound` — standard Lean axioms.