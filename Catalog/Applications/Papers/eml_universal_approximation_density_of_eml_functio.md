# Computational Evidence — EML Universal Approximation: Density & Depth Compression

This note records the small-case computations that motivated the two Lean files
`Catalog/EML/CubeDensity.lean` and `Catalog/EML/DepthCompression.lean`.

## 1. Depth tables for the two monomial representations

Computed in Lean via `#eval (List.range 8).map (fun n => (n, (monoNaive n).depth, (monoExpLog n).depth))`:

| degree `n` | `depth (monoNaive n)` (mul-only) | `depth (monoExpLog n)` (exp/log) | gap |
|:----------:|:-------------------------------:|:--------------------------------:|:---:|
| 0 | 0 | 3 | -3 |
| 1 | 1 | 3 | -2 |
| 2 | 2 | 3 | -1 |
| 3 | 3 | 3 |  0 |
| 4 | 4 | 3 | +1 |
| 5 | 5 | 3 | +2 |
| 6 | 6 | 3 | +3 |
| 7 | 7 | 3 | +4 |

Observation: the multiplication-only depth is exactly `n` (linear), while the exp/log depth is
the constant `3`. The crossover is at `n = 4`, after which exp/log is strictly shallower and the
gap `n - 3` grows without bound. This is precisely `Term.eml_depth_compression`
(threshold `n ≥ 4`) and `Term.eml_depth_unbounded_gap` (unbounded gap).

## 2. Value agreement (counterexample hunt)

The identity `exp(n · log x) = xⁿ` was checked symbolically and proved on `(0, ∞)`
(`Term.monoExpLog_eval`). The guard `0 < x` is essential and is *not* removable:

- At `x = 0`: `monoNaive n` gives `0ⁿ = 0` (for `n ≥ 1`), while `monoExpLog n` gives
  `exp(n · log 0) = exp(n · 0) = 1` in Mathlib's convention `log 0 = 0`. So the two terms
  disagree at `x = 0` — the theorem is correctly stated only on `(0, ∞)`.
- At `x < 0`: `log x = 0` in Mathlib, so `monoExpLog` is constant `1`, again disagreeing.

This confirms the boundary of the compression theorem is exactly `(0, ∞)`, matching the
domain on which `log` is the genuine inverse of `exp`.

## 3. Cube density / shallow-feature bounds

For the cube file, the shallow coordinate feature `x ↦ exp(xᵢ)` on `[0,1]` ranges over
`[exp 0, exp 1] = [1, e] ≈ [1, 2.718]`, verifying the explicit bound
`coordExp_bounds_unitCube` numerically (endpoints `1` and `e`).

No counterexample to any claimed theorem was found; all finite checks agree with the proved
statements.
