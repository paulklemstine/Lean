# Computational evidence — SEQHINT-COMPOUND-LAW (Pythagorean / exp 563 · paper 212)

All numbers below were produced by kernel evaluation (`#eval`) inside the Lean
environment of this project, against the definitions in
`Catalog/Pythagorean/SeqHint/`.  The claims that they motivated are proved as
theorems in the same directory; the exhaustive sweeps are additionally
re-checked by the kernel as theorems in `SeqHint/LabNotes.lean` (`decide`, not
`native_decide`).

## 1. Residual-width tables (adaptive arm, lower-median bisection)

`halfIter k w` = worst-case number of surviving candidates after `k` adaptive
`p ≤ t?` queries on a window of `w` candidates.

`w = 2^20 = 1048576` (the bit-length-40 search window `[2, √N]`):

| k     | 0       | 1      | 2      | 3      | 6     | 9    | 12  | 16 | 19 | 20 | 24 |
|-------|---------|--------|--------|--------|-------|------|-----|----|----|----|----|
| width | 1048576 | 524288 | 262144 | 131072 | 16384 | 2048 | 256 | 16 | 2  | 1  | 1  |

Exact powers of two at every step, and the pin (`width = 1`) occurs at
`k = 20 = ⌈log₂ 2^20⌉` and never earlier — the *hard isolation cap*.

`w = 3600` (the balanced support window, `ρ ≤ 1.01` at bit length 40):

| k     | 0    | 1    | 2   | 3   | 4   | 5   | 6  | 7  | 8  | 9 | 10 | 11 | 12 |
|-------|------|------|-----|-----|-----|-----|----|----|----|---|----|----|----|
| width | 3600 | 1800 | 900 | 450 | 225 | 113 | 57 | 29 | 15 | 8 | 4  | 2  | 1  |

Pin at `k = 12 = Nat.clog 2 3600`, matching `min_queries_eq_clog`.  Note
`225 → 113` and `113 → 57`: the ceiling, not the floor — the halving law is
`w ↦ ⌈w / 2⌉` exactly (`halfIter_eq_ceilDiv`).

## 2. The adaptivity premium on the experiment's `k`-grid

`premium k = 2^k / (k+1)`:

| k       | 0 | 1 | 2   | 3 | 6    | 9     | 12      | 14        | 16        | 20         | 24          |
|---------|---|---|-----|---|------|-------|---------|-----------|-----------|------------|-------------|
| premium | 1 | 1 | 4/3 | 2 | 64/7 | 256/5 | 4096/13 | 16384/15  | 65536/17  | 1048576/21 | 16777216/25 |

`premium 1 = 1` **exactly** — the experiment's `r(1) = 1.00` in all four arm
pairs.  `premium 12 = 4096/13 ≈ 315.1`, above the measured `239.5` (CI
`[220.1, 261.0]`), as an idealized ceiling should be.

## 3. Counterexample hunt: is the linear law for fixed batteries tight?

Exhaustive enumeration of **all** fixed comparison batteries on small windows.

* Window `[0, 8)`, all `56` batteries with `|T| = 3`: the set of worst-case class
  sizes realised is `{2, 3, 4, 5, 6}`.  Minimum `2 = ⌈8 / 4⌉`, attained e.g. by
  `{1, 3, 5}`.  No battery beats `#W / (k+1)`; the bound is tight.
* Window `[0, 16)`, all `1820` batteries with `|T| = 4`: worst-case class sizes
  realised are `{4, …, 13}`.  Minimum `4`, again `≈ #W / (k+1) = 16/5`.
* Same window, adaptive: all `16` candidates isolated after `4` queries
  (residual class size `1` for every hidden value).

No counterexample to the linear law was found; both sweeps are now theorems
(`fixed_battery_sweep_8_optimum`, `fixed_battery_sweep_16`, `adaptive_sweep_16`).

## 4. The balanced zero-bit collapse, concretely

Uniform `24`-threshold battery over `[0, 2^20)`, `t_i = i · 2^20 / 25`:

```
41943, 83886, 125829, 167772, 209715, 251658, 293601, 335544, 377487, 419430,
461373, 503316, 545259, 587202, 629145, 671088, 713031, 754974, 796917, 838860,
880803, 922746, 964689, 1006632
```

The balanced support window `[720000, 723600)` (relative width `0.5 %` around
`√N`) falls strictly between `t_17 = 713031` and `t_18 = 754974`.  Every
candidate of the support therefore answers all `24` queries identically:
**zero bits**, speedup exactly `1.00` (`uniform_battery_zero_bits_balanced`).
Twelve *adaptive* queries on the same window isolate the factor exactly
(`balanced_dichotomy`).

## 5. Isolation budgets

`Nat.clog 2 1048576 = 20`, `Nat.clog 2 3600 = 12`, `Nat.clog 2 1000000 = 20`.
The pin observed at `k = 20 = ⌈log₂ W⌉` is forced, not fitted
(`clog_window_twenty`, `min_queries_eq_clog`).

## 6. OEIS

No new integer sequence arises: the width table is `⌈w / 2^k⌉` and the premium
numerators are powers of two (`A000079`).  Recorded for completeness; no OEIS
lookup was needed to identify them.

## 7. What one lie costs (small cases)

Volume bound `(k+1) · #C ≤ 2^k`, i.e. the largest one-lie-identifiable candidate
set has size at most `⌊2^k / (k+1)⌋`:

| k | 2^k | ⌊2^k/(k+1)⌋ | truthful ceiling 2^k | lost factor |
|---|-----|-------------|----------------------|-------------|
| 1 | 2 | 1 | 2 | 2 |
| 3 | 8 | 2 | 8 | 4 |
| 6 | 64 | 9 | 64 | 7 |
| 12 | 4096 | 315 | 4096 | 13 |
| 20 | 1048576 | 49932 | 1048576 | 21 |

At `k = 20` the bound `49932 < 2^20 = 1048576` shows the observed `100 %` pin is
destroyed by a single lie (`one_lie_breaks_the_twenty_query_pin`); recovering it
needs `k ≥ 25` since `2^25/26 = 1290555 > 2^20`.

## 8. The residue channel: count without interval

Primorial windows isolated by a *non-adaptive* prime residue battery, against
the adaptive comparison ceiling `2^k`:

| k | moduli | ∏ mᵢ (primorial) | 2^k |
|---|--------|------------------|-----|
| 1 | 2 | 2 | 2 |
| 2 | 2,3 | 6 | 4 |
| 3 | 2,3,5 | 30 | 8 |
| 4 | 2,3,5,7 | 210 | 16 |
| 6 | 2,…,13 | 30030 | 64 |
| 9 | 2,…,23 | 223092870 | 512 |

so a fixed battery of `9` residue queries separates more than `2 ^ 27`
candidates — geometric pricing with **no adaptivity at all**
(`prime_residue_battery_isolates`).

Interval side, same battery on the balanced support window `[720000, 723600)`:
knowing `p mod 2` still leaves candidates at `720000` and `723598`, a spread of
`3598` out of `3600`; knowing `p mod 30030` leaves the window untouched because
the whole window lies inside one period.  In every case the residue class
spreads across all but `2m` of the window
(`residue_hints_carry_no_interval_information`), so the downstream Fermat
*interval* scan is not shortened at all: count currency, not interval currency.
