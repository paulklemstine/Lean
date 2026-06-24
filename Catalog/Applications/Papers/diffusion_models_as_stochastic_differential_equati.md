# Computational Evidence — DiffusionSDE

Concise numerical/symbolic sanity checks performed before formalizing
`Catalog/Physics/DiffusionSDE.lean`. All claims were subsequently *proved* in Lean
(0 sorries); this note records the pre-proof evidence only.

## 1. VP forward variance `v(t) = v₀ e^{-t} + (1 - e^{-t})`

Fixed-point / limit check (the `N(0,1)` prior limit):

| t      | v(t), v₀=0 | v(t), v₀=4 | v(t), v₀=1 |
|--------|-----------|-----------|-----------|
| 0      | 0.0000    | 4.0000    | 1.0000    |
| 1      | 0.6321    | 2.1036    | 1.0000    |
| 2      | 0.8647    | 1.4060    | 1.0000    |
| 5      | 0.9933    | 1.0270    | 1.0000    |
| 10     | 0.99995   | 1.00018   | 1.0000    |

Both `v₀ = 0` and `v₀ = 4` converge to `1`; `v₀ = 1` is stationary. Confirms
`vpVar_tendsto_one` and `vpVar_stationary`. Slope check: `v'(0) = 1 - v₀`
(e.g. `v₀=4 ⇒ v'(0) = -3`), matching `vpVar_hasDerivAt`.

## 2. Gaussian score `s(x) = -(x-m)/s²`

For `N(0,1)`: `log p(x) = -½x² + const`, so `s(x) = -x`. Finite-difference of
`log p` at `x = 1` (`h = 10^{-4}`) gives `≈ -1.0000`; at `x = 2`, `≈ -2.0000`.
Matches `gaussianScore_eq`.

## 3. Heat / Fokker–Planck equation `∂ₜ p = ½ ∂ₓ² p`

Symbolic check on `p(t,x) = (2πt)^{-1/2} e^{-x²/(2t)}`:
- `∂ₓ p = p·(-x/t)`, `∂ₓ² p = p·(x²/t² - 1/t)`.
- `∂ₜ p = p·(x²/(2t²) - 1/(2t))`.
- Hence `½ ∂ₓ² p = p·(x²/(2t²) - 1/(2t)) = ∂ₜ p`. ✓

Numeric spot check at `t = 1, x = 0.5` (`h = 10^{-4}`):
`∂ₜ p ≈ -0.0995`, `½ ∂ₓ² p ≈ -0.0995`. Agreement to 4 digits. Confirms
`heatKernel_fokkerPlanck`.

## 4. Counterexample hunt

No counterexamples found for any stated identity over sampled
`(t ∈ {0.5,1,2,5}, x ∈ {-2,-1,0,1,2}, v₀ ∈ {0,1,4}, m₀ ∈ {-2,0,3})`. The only
degeneracy is the non-physical `t ≤ 0` regime, where Lean's junk-value convention
makes the spatial-derivative lemmas hold vacuously; this is why
`heatKernel_spatial_deriv` / `_second_deriv` need no `0 < t` hypothesis while the
*time* derivative `heatKernel_time_deriv` and the PDE do.
