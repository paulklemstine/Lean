# Computational Evidence — NET-63 retention knee (round 16, ctx = 2048)

All numbers below were computed exactly over `ℚ` with `#eval` in the project's
Lean toolchain (no floating point), and every claim that is used in a theorem is
re-proved in Lean (`Catalog/Bridges/AttentionKneeGeometry.lean`,
`Catalog/Bridges/AttentionKneeEntropyBound.lean`).

## 1. The reported fine grid

| k | 20 | 24 | 28 | 32 |
|---|----|----|----|----|
| retained | 0.9793 | 0.9835 | 0.9854 | 0.9885 |
| pass at gate 0.98 | ✗ | ✓ | ✓ | ✓ |

Deficit at 20: `0.98 − 0.9793 = 0.0007`.
Margin at 24: `0.9835 − 0.98 = 0.0035 = 5 × 0.0007`.

Formalised: `net63_first_pass_is_24`, `net63_margin_ratio`, and the sharp
bracket `20 < k* ≤ 24` (`net63_knee_bracket`).

## 2. Counterexample hunt: is the row a top-`k` mass curve?

Block increments over the equal-width blocks of 4 keys:

```
(20→24) = 0.0042      (24→28) = 0.0019      (28→32) = 0.0031
```

For a **sorted** weight row the block increments must be non-increasing
(each block takes strictly smaller weights than the previous one), and this is
preserved by averaging over windows. The measured sequence
`0.0042, 0.0019, 0.0031` **increases** at the last step, so the row is not the
window-average of top-`k` masses of sorted attention rows.

This is a genuine counterexample to the implicit modelling assumption, not to
the knee reading itself: the knee `24` uses only monotonicity, which the data
does satisfy. Formalised as `net63_fine2048_not_window_averaged_topk`.

Likely explanations (untested here): the 12 windows are not the same across the
grid points (`k`-dependent window sets), rounding to 4 decimals (the needed
correction is ≥ 0.0012, i.e. 12 units in the last place — so rounding alone is
**not** enough), or a `k`-dependent gate/eviction rule.

## 3. Grid effects, exactly

Dyadic profile `w i = 2^{-(i+1)}`, so `mass k = 1 − 2^{-k}`:

```
k       : 0     1     2     3      4      5      6      7
mass k  : 0    1/2   3/4   7/8   15/16  31/32  63/64  127/128
```

First `k` with `mass k ≥ 0.98` is `k = 6` (`63/64 = 0.984375`; `31/32 = 0.96875`
fails). A power-of-two sweep `{2,4,8,16}` reports `8` — a 33% over-provision;
adding the single point `6` recovers the truth. Formalised as
`knee_geometricProfile` and `geometric_coarse_grid_overestimates`, with the
general mechanism as `gridKnee_refine` (refining a grid can only lower the
reported knee) and `knee_le_gridKnee` (a sweep never under-reports).

## 4. Entropy floor implied by the reading

Cauchy–Schwarz gives `g² ≤ k · E_k` for the energy (collision probability)
`E_k = ∑_{i<k} w_i²`. With `g = 0.98` and a measured knee of `24`:

```
E_24 ≥ 0.98² / 24 = 2401/60000 = 0.0400166…  > 0.04
```

i.e. Rényi-2 entropy `H₂ ≤ log₂(1/0.0400166) ≈ 4.643` bits. This is a
falsifiable prediction about the measured attention rows: a row flatter than
4.65 bits of collision entropy cannot have a 24-key knee at gate 0.98.
Formalised as `net63_energy_lower_bound`, attained exactly by the 24-key plateau
profile (`net63_energy_bound_attained`), so the constant cannot be improved.

## 5. OEIS

No integer sequence arises here; the deployment chain `16, 20, 24` is a
three-term arithmetic progression with difference 4 and is far too short to
warrant an OEIS lookup. (`{16,20,24}` matches, e.g., A008586 `4n` shifted, which
carries no information about the experiment.) No lookup was performed.

## 6. Cycle 3: the knee-to-floor ratio on geometric rows

Counterexample hunt for the conjecture "the ratio (true knee)/(ℓ² floor) grows
without bound as `a → 1⁻`" on the geometric row `w i = (1-a) aⁱ` at gate
`g = 0.98`.  Here the true knee is the least `N` with `aᴺ ≤ 1 - g = 0.02`, and
the floor is `g²/E(a) = 0.9604 (1+a)/(1-a)`.

| a       | true knee | floor `g²/E` | ratio  |
|---------|-----------|--------------|--------|
| 0.5     | 6         | 2.8812       | 2.0825 |
| 0.9     | 38        | 18.2476      | 2.0825 |
| 0.99    | 390       | 191.1196     | 2.0406 |
| 0.999   | 3911      | 1919.8396    | 2.0371 |
| 0.9999  | 39119     | 19207.0396   | 2.0367 |

The ratio does **not** diverge; it settles at `log 50 / (2·0.98²) = 2.03666…`.
This exploratory floating-point table is *not* itself a verified computation —
it is what prompted the proof.  The verified statements are
`geoRow_flatness_ratio_bounded` (ratio `≤ (1 + log(1/(1-g)))/g²`, uniformly in
`a`), `net63_flatness_constant_lt_six` (that constant is `< 6` at `g = 0.98`;
its exact value is `(1 + log 50)/0.9604 = 5.1146…`) and `dyadic_knee_and_floor`
(the `a = 1/2` row of the table, with `E = 1/3` and knee exactly `6`, proved in
Lean).  The observed limit `2.0367` is recorded as conjecture C7.

## 7. Cycle 4: the spike-plus-plateau family

Counterexample hunt for "the knee-to-floor ratio is bounded for every sorted
row".  The candidate family is `spikeRow m`: one key of weight `1/2` followed by
`2m` keys of weight `1/(4m)`.  All entries below are exact rationals obtained
from the closed forms that are *proved in Lean* (`mass_spikeRow`,
`energy_spikeRow`, `spikeRow_knee`), at gate `g = 3/4`:

| m    | knee `k*` | energy `E = 1/4 + 1/(8m)` | floor `g²/E` | ratio `k*/floor` |
|------|-----------|---------------------------|--------------|------------------|
| 1    | 2         | 3/8      = 0.375          | 1.5          | 1.33             |
| 4    | 5         | 9/32     = 0.28125        | 2.0          | 2.5              |
| 25   | 26        | 51/200   = 0.255          | 2.2059       | 11.79            |
| 250  | 251       | 501/2000 = 0.2505         | 2.2455       | 111.78           |
| 2500 | 2501      | 0.25005                   | 2.2495       | 1111.78          |

The energy is trapped in `[1/4, 3/8]` — the spike alone contributes `1/4` — so
the Cauchy–Schwarz floor never exceeds `9/4 = 2.25` keys, while the knee is
`m + 1`.  The ratio therefore grows linearly in `m`, in sharp contrast with the
geometric table of §6 where it settles at `2.0367`.

The table is arithmetic bookkeeping; the verified statements are
`spikeRow_knee` (knee `= m+1` exactly), `energy_spikeRow_le` together with
`spikeRow_energy_ge_quarter` (`1/4 ≤ E ≤ 1/4 + 1/(8m)`), `spikeRow_floor_le`
(floor `≤ 9/4`), `heavyTail_floor_ratio_unbounded` (the ratio exceeds any `R`)
and `entropy_floor_tightness_dichotomy` (bounded on geometric rows, unbounded
here), all proved in `Catalog/Bridges/AttentionKneeHeavyTail.lean`.
