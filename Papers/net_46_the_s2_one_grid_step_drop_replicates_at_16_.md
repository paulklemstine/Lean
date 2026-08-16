# Computational evidence — NET-46 knee-drift ladder

All arithmetic below is **machine-checked in Lean over exact rationals** in
`Catalog/Logic/KneeDriftEvidence.lean` (sweeps as `List (ℕ × ℚ)`, knee = first budget
reaching the bar, every claim discharged by `norm_num`, no floating point, no
`native_decide`). Nothing here is a scratch computation.

## 1. Small-case recomputation of the reported sweep

`(d = 4, ctx = 2048, seed 2)`, bar `= 0.98` of full accuracy:

| `k`   |  96   | 128   | 160   | 192   | **224** | 256   | 288   | 384   | 512   | 768   | 1024  |
|-------|-------|-------|-------|-------|---------|-------|-------|-------|-------|-------|-------|
| ret.  | 0.956 | 0.965 | 0.971 | 0.978 | **0.982** | 0.986 | 0.987 | 0.992 | 0.993 | 0.998 | 0.998 |
| pass  |  ✗    |  ✗    |  ✗    |  ✗    | **✓**   |  ✓    |  ✓    |  ✓    |  ✓    |  ✓    |  ✓    |

* `knee_2048_s2 : kneeOf sweep2048S2 = some 224` — the reported knee is reproduced.
* `knee_2048_s1 : kneeOf sweep2048S1 = some 256` — seed 1 at the same cell.
* `margin_224 : 0.982 - bar = 0.002` and `deficit_192 : bar - 0.978 = 0.002` — the
  reading is decided at the round's own resolution, with nothing to spare.
* `loss_gaps` — the `k = 1024` loss gap `0.0006` (seed 2) is smaller than `0.0015` (seed 1).

## 2. Counterexample hunt against the "systematic drop" reading

The claim under test is that the second seed's one-grid-step drop carries information
beyond noise. Two checks were run, both of which **found the claim unsupported**:

* `deficit_s1_224_lt_spread : bar - 0.976 < 0.006` — the seed-1 deficit at the deciding
  budget `224` is `0.004`, *smaller* than the inter-seed spread `0.006` measured at that
  very budget.
* `knee_2048_s1_shifted : kneeOf (shift sweep2048S1 0.006) = some 224` — shifting the
  seed-1 sweep by the observed spread already reports `224`.

So the "replication" is the value predicted by the recorded seed noise. The formal
counterparts are `KneeDrift.net46_any_spread_upshift_of_seed1_drops_to_224` and
`KneeDrift.net46_seed2_knee_not_robust`.

A second hunt targeted the *sign* of the drift: is `k*(s2) ≤ k*(s1)` informative? It is
not — it is forced by pointwise domination of the retained curves
(`KneeDrift.drop_direction_forced`), while the magnitude is not forced
(`KneeDrift.domination_does_not_force_drop` builds strictly dominating curves with equal
knees).

## 3. The ladder, and the amplitude windows

| `i`            | 0   | 1   | 2   | 3    | 4    |
|----------------|-----|-----|-----|------|------|
| `ctx = 128·2^i`| 128 | 256 | 512 | 1024 | 2048 |
| product `P i`  | 16  | 32  | 64  | 128  | 256  |
| `k*(s1)`       | 16  | 32  | 64  | 128  | 256  |
| `k*(s2)`       | 16  | 32  | 64  | 96   | 224  |

Fitting an affine law `a·ctx + b` to the first two seed-2 rungs gives `a = 1/8, b = 0`,
which predicts `128` at `ctx = 1024` against the measured `96` — refuted
(`KneeDrift.no_affine_law_fits_seed2_ladder`).

Fitting a *multiplicative* law `κ = A·2^i` rung by rung, each reported knee `k` with
previous swept budget `p` confines `A` to `(p/2^i, k/2^i]`:

| round  | seed | rung | prev `p` | knee `k` | window     |
|--------|------|------|----------|----------|------------|
| NET-44 | 1    | 3    | 96       | 128      | `(12, 16]` |
| NET-46 | 1    | 4    | 224      | 256      | `(14, 16]` |
| NET-44 | 2    | 3    | 64       | 96       | `(8, 12]`  |
| NET-46 | 2    | 4    | 192      | 224      | `(12, 14]` |

Checked in `amplitude_windows_rational` and `window_intersections`:
seed 1 intersects in `(14, 16]` (which contains the product law's `A = 16`); **seed 2's
two windows are disjoint** — no amplitude explains both. Formal statements:
`KneeAmplitude.seed1_amplitude_iff`, `KneeAmplitude.seed2_no_common_amplitude`.

## 4. Ratios and asymptotics (small cases)

| rung `i`             | 3     | 4     | 5      | 6       | limit |
|----------------------|-------|-------|--------|---------|-------|
| `k*(s2) / P i`       | 3/4   | 7/8   | 15/16  | 31/32   | 1     |
| `ctx / k*(s2)`       | 32/3  | 64/7  | 128/15 | 256/31  | 8     |
| resolution `32/2^i`  | 4     | 2     | 1      | 1/2     | 0     |

The first two columns are the measured cells; the pattern `1 - 2^{1-i}` is proved for all
rungs (`KneeDrift.kneeRatio_eq`), with the two limits
`KneeDrift.kneeRatio_tendsto_one` and `KneeDrift.speedup_tendsto_eight`. The resolution
row is the amplitude-window width, matched above and below in
`KneeResolution.amplitude_resolution` / `KneeResolution.exists_indistinguishable_amplitude`.

## 5. Null model for the two-cell "replication"

Two broken rungs, each either dropping or not, gives four equally likely patterns under an
unbiased per-cell null; the observed one has probability `1/4 > 0.05`
(`KneeDrift.replication_null_probability`, `KneeDrift.replication_not_significant`). A
third seed at `ctx = 1024` would take the null probability to `1/8`.

## 6. OEIS

The ladders `16, 32, 64, 128, 256` and `16, 32, 64, 96, 224` were considered for sequence
lookup. The first is `2^(n+4)` (powers of two, A000079 shifted); the second is a
five-term finite measurement with no meaningful extension, and no OEIS search was
performed for it — the object of study is the *window* it defines, not a sequence.
