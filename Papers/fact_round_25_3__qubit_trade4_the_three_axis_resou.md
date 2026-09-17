# Computational evidence — QUBIT-TRADE4 resource surface (paper 87)

All numbers below were produced by direct arithmetic on the model
`P(q, n) = 1 − (1 − q)^n`, `q = q₀ / 2^d`, `cost = n · t²`, with the round's
fitted values `q₀ = 1/8`, target `P* = 3/10`, full register width `T = 40`.

**Status note.** The tables in this file are *exploratory* numerics computed
outside Lean. Every claim that the Lean files assert — the cap-lift law, the
doubling identity, the shot-count floor, the cost inequalities and the three
cell bounds `4800 / ≥ 14440 / ≥ 50544` — is proved in
`Catalog/Shared/QubitTradeResourceSurface.lean` and
`Catalog/Shared/QubitTradeCornerSeparation.lean` and is *not* relying on these
tables.

## 1. The cost surface along the width axis (`T = 40`, `P* = 0.3`, `q₀ = 1/8`)

`n(d)` is the least number of shots with `1 − (1 − q₀2^{-d})^n ≥ 0.3`.

| shave `d` | width `t = 40 − d` | per-shot `q` | least `n` | cost `n·t²` | cost / corner |
|---|---|---|---|---|---|
| 0 | 40 | 0.12500 | 3   | 4800   | 1.00 |
| 1 | 39 | 0.06250 | 6   | 9126   | 1.90 |
| 2 | 38 | 0.03125 | 12  | 17328  | 3.61 |
| 3 | 37 | 0.01562 | 23  | 31487  | 6.56 |
| 4 | 36 | 0.00781 | 46  | 59616  | 12.42 |
| 5 | 35 | 0.00391 | 92  | 112700 | 23.48 |
| 6 | 34 | 0.00195 | 183 | 211548 | 44.07 |
| 7 | 33 | 0.00098 | 366 | 398574 | 83.04 |
| 8 | 32 | 0.00049 | 731 | 748544 | 155.95 |

The ratio column is monotonically increasing and never dips below 1: the
minimum of the surface is at `d = 0`, the full-register corner. This is exactly
what `standard_corner_optimal` proves (for all `T ≥ 8` and `1 ≤ d ≤ T/2`,
with the slightly weaker union-bound floor, giving `≥ 14440` and `≥ 50544`
where the exact search gives `17328` and `59616`).

## 2. Counterexample hunt along the width axis

Searching `T ∈ {8,…,200}`, `d ∈ {1,…,⌊T/2⌋}` for a violation of
`(5/4)·T² < 2^d·(T−d)²` (the inequality behind the verdict): no violation found.
The tightest cell is `d = 1, T = 8`, where `2·49 = 98` against
`(5/4)·64 = 80`. Dropping the hypothesis `T ≥ 8` does break it: at `T = 4, d = 2`
one has `2^2·4 = 16` against `(5/4)·16 = 20`, so the width hypothesis in the
Lean statement is necessary, not decorative. Likewise `d = T` (a zero-width
register) makes the left side `0`, which is why the statement restricts to
`2d ≤ T`.

The cubic variant `(5/4)·T³ < 2^d·(T−d)³` survives the same sweep, with the
tightest cell again `d = 1, T = 8`: `2·343 = 686` against `(5/4)·512 = 640`.

## 3. Cap lift along the re-draw axis

Round-25 #3 measured, at `t = wall`, `s = 5`: `k = 1 → 0.504`, `k = 2 → 0.735`,
`k = 4 → 0.940`. The cap-lift law `1 − P(k) = (1 − P(1))^k` predicts from the
`k = 1` cell alone:

| `k` | law prediction | measured | deviation |
|---|---|---|---|
| 1 | 0.504000 (input) | 0.504 | — |
| 2 | 0.753984 | 0.735 | −0.018984 |
| 4 | 0.939476 | 0.940 | +0.000524 |

The `k = 4` cell matches the law to `5.2·10⁻⁴`; the `k = 2` cell is the single
visible deviation, `1.9·10⁻²` low. Both deviations are bounded in Lean
(`caplift_prediction_k2`, `caplift_prediction_k4`).

## 4. Doubling gains (the fungibility increment)

With `q = 1/8`, the measured increment from `n` to `2n` against the identity
`ΔP = P(1 − P)`:

| `n` | `P(n)` | `P(2n) − P(n)` | `P(n)(1 − P(n))` |
|---|---|---|---|
| 1 | 0.1250 | 0.1094 | 0.1094 |
| 2 | 0.2344 | 0.1794 | 0.1794 |
| 3 | 0.3301 | 0.2211 | 0.2211 |
| 4 | 0.4138 | 0.2426 | 0.2426 |
| 5 | 0.4871 | 0.2498 | 0.2498 |
| 6 | 0.5512 | 0.2474 | 0.2474 |

The two right-hand columns agree to all printed digits — this is the exact
identity `succProb_double_gain` — and the gain peaks at `0.25` exactly where
`P = 1/2` (here between `n = 5` and `n = 6`), the saturation ceiling of
`gain_le_quarter`. The round's reported "mean ΔP = +0.18 per single-resource
doubling" sits squarely inside this range of values.

## 5. Sequence search

The integer sequence of least shot counts `3, 6, 12, 23, 46, 92, 183, 366, 731`
(column `least n` above) is the near-doubling sequence
`n(d) ≈ ⌈2.4·2^d⌉`; no OEIS entry was consulted or is claimed for it, since it
is parameter-dependent (it changes with `q₀` and `P*`).
