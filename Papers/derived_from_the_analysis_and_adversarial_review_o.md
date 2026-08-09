# Computational evidence — cycle IX (the silver growth rate)

All data below was produced by direct enumeration of the Berggren tree in Euclid-seed
coordinates, `B₁(m,n) = (2m−n, m)`, `B₂(m,n) = (2m+n, m)`, `B₃(m,n) = (m+2n, n)`, root
`(2,1)`, with the exact distance `d(m,n) = arcosh((m²+n²+1)/(2m))` from
`cosh_dist_hpoint_I`.  Every statement that this evidence motivated is proved in
`Catalog/Novelty/HyperbolicBerggrenSilverGrowth.lean` with 0 sorries; the numbers here are
exploratory only.

## 1. The distance is `log m` up to `log 2` (`dist_window_log_fst`)

For all `3^0 + 3^1 + ⋯ + 3^10 = 88573` nodes of depth `≤ 10` the residual
`d(m,n) − log m` was computed: **0 violations** of `0 ≤ d − log m ≤ log 2 = 0.6931`.
Typical values: `(2,1) : 0.2694`, `(4,1) : 0.0645`, `(3,2) : 0.4926`,
`(32,31) : 0.6819` (approaching the upper end as `n/m → 1`),
`(62,1) : 0.0003` (approaching the lower end as `n/m → 0`).

## 2. The silver potential is exactly extremal

`Φ(m,n) = m + (√2 − 1) n`, `λ = 1 + √2`.  Maximum of `Φ` over the full depth-`k` layer,
compared with `λ^{k+1}`:

| depth `k` | `max m` | `λ^{k+1}` | `max Φ` | `max Φ / λ^{k+1}` | `max d` | `(k+1) log λ + log 2` |
|---|---|---|---|---|---|---|
| 0 | 2 | 2.41 | 2.414 | 1.00000 | 0.9624 | 1.5745 |
| 2 | 12 | 14.07 | 14.071 | 1.00000 | 2.6459 | 3.3373 |
| 4 | 70 | 82.01 | 82.012 | 1.00000 | 4.4069 | 5.1000 |
| 6 | 408 | 478.00 | 478.002 | 1.00000 | 6.1696 | 6.8628 |
| 8 | 2378 | 2786.00 | 2786.000 | 1.00000 | 7.9324 | 8.6255 |
| 10 | 13860 | 16238.00 | 16238.000 | 1.00000 | 9.6951 | 10.3883 |
| 12 | 80782 | 94642.00 | 94642.000 | 1.00000 | 11.4579 | 12.1510 |

So the bound `Φ ≤ λ^{k+1}` (`reaches_pot_le`) is an **equality on the extremal branch** at
every depth — the maximiser is always the pure-`B₂` (Pell) spine `2, 5, 12, 29, 70, …`
(OEIS A000129 companion: `m_k` are the NSW-type Pell numbers `2, 5, 12, 29, 70, 169, 408,
985, 2378, 5741, …` = A000129 shifted).  The proved distance bound
`d ≤ (k+1) log λ + log 2` overshoots the true maximum by a constant `≈ 0.61`, as it should:
the slack is exactly `log 2 − (d − log m)`.

## 3. Growth rate of each pure spine (`pure_spine_rate_trichotomy`)

`d/k` at depth 30 along the three one-generator branches:

| branch | node at depth 30 | `d` | `d/k` | conjectured by H2 | truth |
|---|---|---|---|---|---|
| pure `B₁` | `(32,31)` | 4.1279 | 0.1376 | — (excluded) | `→ 0` |
| pure `B₂` | `(627013566048, 259717522849)` | 27.3226 | 0.9108 | `∈ [log 2, log 3]` | `→ log(1+√2) = 0.88137` |
| pure `B₃` | `(62,1)` | 4.1274 | 0.1376 | `→ log 3 = 1.0986` | `→ 0` |

The pure-`B₃` column is the counterexample to conjecture **H2**: that path uses the
parabolic move `B₁` *never*, and yet its rate is `0`, not `≥ δ log 2`.

## 4. The maximiser over all words

For every length `k ≤ 14`, brute force over all `3^k` words gives the maximum of `d/k`:

| `k` | 1 | 2 | 4 | 6 | 8 | 10 | 12 | 14 |
|---|---|---|---|---|---|---|---|---|
| `max d/k` | 1.7627 | 1.3229 | 1.1017 | 1.0283 | 0.9915 | 0.9695 | 0.9548 | 0.9443 |
| argmax | `M` | `MM` | `M⁴` | `M⁶` | `M⁸` | `M¹⁰` | `M¹²` | `M¹⁴` |

The maximiser is the pure-`B₂` word at every length, and the value decreases monotonically
towards `log(1+√2) = 0.88137…` — never towards `log 3 = 1.09861…`.

## 5. Depth needed to reach a given hypotenuse

Along the Pell spine, `log N / (2 log λ)` where `N = hypot(mspine k)`:

| `k` | 1 | 3 | 5 | 7 | 9 | 11 |
|---|---|---|---|---|---|---|
| `N` | 29 | 985 | 33461 | 1136689 | 38613965 | 1311738121 |
| `log N/(2 log λ)` | 1.91 | 3.91 | 5.91 | 7.91 | 9.91 | 11.91 |

i.e. the depth is `log N/(2 log λ) − 0.91 + o(1)`, consistent with the proved window
`(log N − log 2)/(2 log λ) − 1 ≤ k` (`depth_ge_of_hypot`) and
`k ≤ (log N + log 2)/(2 log λ)` (`exists_depth_reach_silver`).

## 6. Counterexample hunt for the theorems actually proved

* `Φ(B_i v) ≤ λ Φ(v)` for all three moves: `265719` child checks over all nodes of depth
  `≤ 10` — 0 violations, and equality for `B₂` in all `88573` cases (to `10⁻⁹`).
* `m ≥ 2^{#B₂+1}` (`run_fst_ge_two_pow`): all `797161` words of length `≤ 12` — 0
  violations.
