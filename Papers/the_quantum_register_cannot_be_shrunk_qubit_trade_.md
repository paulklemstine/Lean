# Computational evidence — QUBIT-TRADE register threshold

All numbers below are **exploratory** (produced by an ad-hoc simulation and by
`#eval` in Lean); they are *not* proofs. The proofs are in
`Catalog/Algebra/QubitTrade/*.lean` and are `sorry`-free.

## 1. Replication of the measured threshold `t_min ≈ 2 log₂ r`

Honest post-processing: for a random numerator `k < r`, the register reports
`m = round(2^t · k / r) mod 2^t`; the classical step takes the continued-fraction
convergents of `m / 2^t` and keeps the last one with denominator `≤ r`; several
samples are combined by `lcm`. For each order `r` we report the smallest `t` for
which 20 independent trials all return the true `r`.

| `r`        | `log₂ r` | `2 log₂ r` | `t_min`, 1 sample | `t_min`, 5 samples | `t_min`, 10 samples |
|------------|----------|------------|-------------------|--------------------|---------------------|
| `2^10 + 1` | 10       | 20         | —                 | 20                 | 21                  |
| `2^12 + 1` | 12       | 24         | 25                | 24                 | 25                  |
| `2^14 + 1` | 14       | 28         | —                 | 28                 | 28                  |
| `2^16 + 1` | 16       | 32         | 32                | 32                 | 32                  |
| `2^18 + 1` | 18       | 36         | —                 | 36                 | 36                  |
| `2^20 + 1` | 20       | 40         | 40                | 40                 | 40                  |

("—" = no `t` in the searched range made *all* trials succeed with a single
sample; that is the `gcd(k, r) > 1` effect, not a resolution effect.)

Observed: `t_min = 2 log₂ r + O(1)`, never `log₂ r + O(log log r)`, and adding
samples moves `t_min` by at most one bit. This is exactly the window proved in
`QubitTrade.register_threshold_bits`:

* ambiguity is *proved* for every `t` with `2^t < R(R-1)`;
* uniqueness is *proved* for every `t` with `R^2 ≤ 2^t`;

so the true threshold must lie in the one-bit window `R(R-1) ≤ 2^{t_min} < 2R^2`.

## 2. Support collapse (`#eval`, order `r = 12`)

Number of distinct values of `k ↦ ⌊2^t k / r⌋` for `k < 12`:

| `t`                  | 0 | 1 | 2 | 3 | 4  |
|----------------------|---|---|---|---|----|
| distinct outcomes    | 1 | 2 | 4 | 8 | 12 |
| alphabet size `2^t`  | 1 | 2 | 4 | 8 | 16 |

For every `t` with `2^t ≤ 12` the outcome map is **onto** the whole alphabet, so
the record distribution's support carries no information about `r` — this is
`QubitTrade.outcomes_eq_alphabet`, and the reason `samples_do_not_help` holds.
At `t = 4` the alphabet is larger than the order and the collapse stops.

## 3. Sample fungibility (`#eval`, order `r = 12`)

`recovered k 12 = 12 / gcd(k,12)` for `k = 0,…,11`:

`[1, 12, 6, 4, 3, 12, 2, 12, 3, 4, 6, 12]`

* `lcm(recovered 4 12, recovered 3 12) = lcm(3,4) = 12` — two under-reporting
  samples (`3` and `4`) jointly recover the order, as in
  `QubitTrade.two_samples_recover` (`gcd(gcd(4,3),12) = 1`).
* `lcm(recovered 6 12, recovered 8 12) = lcm(2,3) = 6 ≠ 12` — jointly non-coprime
  numerators can never recover it, as in `QubitTrade.samples_recover_iff`
  (`gcd(gcd(6,8),12) = 2`).

## 4. Counterexample hunt

We searched for a pair of distinct reduced fractions with denominators `≤ R`
closer than `1/(R(R-1))` (which would break the sharpness claim) — none exists,
and the proof is `QubitTrade.rat_den_separation` (any two distinct rationals are
at distance `≥ 1/(d₁d₂) ≥ 1/R²`). Conversely `1/R` and `1/(R-1)` realise
distance exactly `1/(R(R-1))`, so the constant `1/(2R²)` in the Legendre-type
criterion is optimal up to the factor `R/(R-1) → 1`.

## 5. Success density of a record of `m` samples (`#eval`)

Number of records `(k₁,…,k_m) ∈ [0,r)^m` with `gcd(gcd(k₁,…,k_m), r) = 1`, i.e.
the records that recover the order (`QubitTrade.samples_recover_iff`):

| `r`            | 2 | 3 | 4  | 5  | 6  | 7  | 8  | 9  | 10 | 11  | 12  | 30  | 60   | 210   |
|----------------|---|---|----|----|----|----|----|----|----|-----|-----|-----|------|-------|
| `#good (m=2)`  | 3 | 8 | 12 | 24 | 24 | 48 | 48 | 72 | 72 | 120 | 96  | 576 | 2304 | 27648 |
| `r²`           | 4 | 9 | 16 | 25 | 36 | 49 | 64 | 81 |100 | 121 | 144 | 900 | 3600 | 44100 |


Every ratio exceeds `1/2`, and the smallest ratio in the sample is at the
primorial `r = 210 = 2·3·5·7`: `27648/44100 = 0.62694…`, decreasing towards
`6/π² = 0.60793…` — exactly the behaviour of Conjecture 3.  The *proved*
statement is the uniform bound `r^m < 2·#good` for all `r ≥ 1, m ≥ 2`
(`QubitTrade.two_pow_card_goodRecords`), i.e. success probability `> 1/2`.

For `m = 3` the same `#eval` gives
`[7, 26, 56, 124, 182, 342, 448, 702, 868, 1330, 1456]` for `r = 2,…,12`, ratios
`≥ 0.842` — consistent with the conjectured `∏_{p ∣ r}(1 − p^{−3}) ≥ 1/ζ(3)`.

The *proved* concentration bound behind these ratios is
`QubitTrade.pow_mul_card_badRecords_lt`: the failure fraction is `< 2^{-(m-1)}`
for every `r ≥ 1` and `m ≥ 2` (`1/2` at `m = 2`, `1/4` at `m = 3`, …), which the
table respects with room to spare — the true failure fractions above are
`≤ 0.373` for `m = 2` and `≤ 0.158` for `m = 3`.

**Update (this cycle).** The table above is no longer only evidence: the exact
count is now a theorem.  `QubitTrade.card_goodRecords_eq_euler_product` proves
`#good(r,m) = r^m ∏_{p ∣ r}(1 − p^{−m})` (Jordan's totient `J_m(r)`) for every
`r ≥ 1`.  Every entry of the `m = 2` row is the corresponding `J_2(r)`; e.g.
`J_2(6) = 36·(3/4)·(8/9) = 24` and `J_2(12) = 144·(3/4)·(8/9) = 96`, matching the
`#eval` counts exactly.
