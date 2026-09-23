# Computational evidence — SIX-KEYSTONE-ZERO-DRIFT (paper 103)

All numbers below were produced by evaluating the same arithmetic model that the Lean
files formalise (`Catalog/NumberTheory/SixKeystoneZeroDrift.lean`,
`SixKeystoneCapacityExact.lean`, `SixKeystoneSynergyGap.lean`). They are exploratory
evaluations; the *proved* statements are the Lean theorems, and every claim in the
"verified" column below has a corresponding sorry-free theorem.

## 1. Capacity curve and deficits (keystone: capacity saturation)

Rotation pipeline `x ↦ x+1 mod 97`, seed `5`. Columns: `k`, orbit count,
`I(k) = log₂(count)`, deficit `d(k) = k − I(k)`.

| k | #states | I(k) | d(k) |
|---|---|---|---|
| 0 | 1 | 0.000000 | +0.000000 |
| 1 | 2 | 1.000000 | +0.000000 |
| 2 | 3 | 1.584963 | +0.415037 |
| 3 | 4 | 2.000000 | +1.000000 |
| 4 | 5 | 2.321928 | +1.678072 |
| 5 | 6 | 2.584963 | +2.415037 |
| 6 | 7 | 2.807355 | +3.192645 |
| 7 | 8 | 3.000000 | +4.000000 |
| 8 | 9 | 3.169925 | +4.830075 |
| 9 | 10 | 3.321928 | +5.678072 |
| 10 | 11 | 3.459432 | +6.540568 |
| 11 | 12 | 3.584963 | +7.415037 |

The deficit column starts at `+0.000`, never decreases, and is strictly increasing from
`k = 1` on — exactly the recorded audit profile. Verified in Lean:
`deficit_zero`, `deficit_mono`, `rot_deficit_strictMono_presaturation`.

A full LCG (`a = 1103515245`, `c = 12345`, `m = 2¹⁵`, seed `7`) produces the *identical*
deficit column over the same range (`+0.000, +0.000, +0.415, +1.000, +1.678, +2.415,
+3.193, +4.000, …`): before saturation the curve depends only on the number of steps, not
on the multiplier. Verified in Lean for the rotation family: `rot_deficit_eq`.

Saturation, `m = 64`, `k = 60 … 69`:
`54.069, 55.046, 56.023, 57.000, 58.000, 59.000, 60.000, 61.000, 62.000, 63.000` —
consecutive differences become exactly `1`. Verified: `rot_deficit_slope_one`.

## 2. Synergy and overlap (keystone: synergy decomposition)

| p | q | synergy `I(lcm) − max(I p, I q)` | overlap `I(gcd)/min(I p, I q)` |
|---|---|---|---|
| 3 | 4 | +1.584963 | 0.000000 |
| 6 | 10 | +1.584963 | 0.386853 |
| 12 | 18 | +1.000000 | 0.721057 |
| 5 | 7 | +2.321928 | 0.000000 |
| 4 | 8 | +0.000000 | 1.000000 |
| 9 | 27 | +0.000000 | 1.000000 |
| 100 | 101 | +6.643856 | 0.000000 |
| 1024 | 768 | +1.584963 | 0.834641 |
| 360 | 540 | +1.000000 | 0.882240 |

Synergy is `0` exactly in the nested cases (`4 ∣ 8`, `9 ∣ 27`) — verified:
`synergy_eq_zero_iff`. Overlap always lands in `[0,1]` — verified: `overlap_nonneg`,
`overlap_le_one`.

## 3. Counterexample hunt: is there a small positive synergy?

Exhaustive scan of all pairs `1 ≤ p, q ≤ 120` (14 400 pairs) for a synergy strictly
between `0` and `1`: **0 hits**; the smallest strictly positive value observed is exactly
`1.000000`. This suggested — and Lean then proved — the quantisation theorem
`synergy_gap`: a non-nested pair has synergy `≥ 1` bit.

This is an adversarial finding about the audited table: the recorded `+0.0049` synergy of
the `A₄ × D₄` cell *cannot* arise from integer channel periods in this model, so it must
come from a different (estimator-level, non-period) mechanism. See Direction 1 in
`FUTURE_DIRECTIONS.md`.

## 4. The ramp law (keystone: `P₁ ≈ ramp(q/r²)`)

| q | r | measured `P₁` | `ramp(q/r²)` |
|---|---|---|---|
| 0 | 5 | 0.000000 | 0.000000 |
| 7 | 5 | 0.280000 | 0.280000 |
| 25 | 5 | 1.000000 | 1.000000 |
| 30 | 5 | 1.000000 | 1.000000 |
| 13 | 4 | 0.812500 | 0.812500 |

Agreement is exact, not approximate, in every cell tested. Verified in Lean for all
`q` and all `r > 0`: `P₁_eq_ramp` (via the counting lemma `lexCount_eq`).

## 5. The orbit-count law for arbitrary congruential pipelines (cycle IV)

Evaluated inside Lean with the formalised definitions (the pipeline definitions are
computable, so `#eval` runs the very functions the theorems talk about):

| pipeline `(a, c, m, s)` | `#states(k)` for `k = 0 … 12` |
|---|---|
| `(5, 3, 16, 1)` | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 |
| `(6, 3, 16, 1)` | 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 |
| `(1, 1, 12, 0)` | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12 |
| `(3, 0, 11, 1)` | 1, 2, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5 |

Every column is `min (k+1) N` for the pipeline's own orbit size `N` (13+, 2, 12, 5
respectively — the first one has not saturated yet by `k = 12`). An exhaustive `#eval`
check over all `4096` triples `(a, c, s)` with `m = 16` and all `k ≤ 39` returned `true`:
no pipeline deviates from the law. Proved in Lean for every finite-window pipeline, with
no periodicity hypothesis: `orb_card_eq_min`, `states_card_eq_min`.

## 6. OEIS

The orbit-count sequence of the full-period pipeline is `min (k+1) m`
(`1, 2, 3, …, m, m, m, …`), a truncated-identity sequence; nothing beyond the trivial
`A000027`-prefix is involved, so no OEIS identification is claimed.
