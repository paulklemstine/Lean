# Computational Evidence — separating temporal lag from pitch interval

All numbers below were produced by the reproducible script at the end of this file
(exact integer arithmetic, unbounded spigot algorithm for the decimal digits of π).
They are *script* computations and are labelled as such; the mathematical claims that the
project asserts are the Lean theorems in `Catalog/Tropical/MusicalDigits/`, each of which
is proved without `sorry`.

## 1. Small-case calculation: the alphabet's own interval distribution

For a base-`b` alphabet the number of *ordered* digit pairs at pitch distance `v`
(`TropicalMusicalDigits.pairCount`) was computed inside Lean with `#eval`:

| base | counts for `v = 0, 1, 2, …` |
|------|------------------------------|
| 10   | `10, 18, 16, 14, 12, 10, 8, 6, 4, 2` |
| 13   | `13, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2` |

This is the triangular law `pairCount b 0 = b`, `pairCount b v = 2(b − v)`, proved in
`NullIntervalDistribution.lean`.  Second moment in base ten: `Σ v² · pairCount 10 v = 1650`,
i.e. a mean squared interval of `1650 / 100 = 16.5` semitones² — matching the closed form
`(b² − 1)/6 = 99/6` proved as `six_mul_sum_sq_pairCount`.

**No entry of these tables sits at `v = 12`.**  Twelve semitones is unreachable on a
ten-note digit scale, at any lag, which is the content of `decimal_octave_count_eq_zero`.

## 2. π: interval histograms at several temporal lags (9000 position pairs each)

Digits used: the first 10 000 decimal digits after the point of π
(`1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 …`).

| lag | `N(0)` | `N(1)` | `N(2)` | `N(3)` | `N(4)` | `N(5)` | `N(6)` | `N(7)` | `N(8)` | `N(9)` |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 1   | 856 | 1621 | 1422 | 1301 | 1114 | 876 | 739 | 510 | 355 | 206 |
| 2   | 911 | 1649 | 1468 | 1278 | 1057 | 876 | 718 | 489 | 353 | 201 |
| 12  | 956 | 1613 | 1450 | 1258 | 1044 | 871 | 759 | 501 | 372 | 176 |
| 13  | 919 | 1623 | 1502 | 1240 | 1105 | 887 | 711 | 493 | 338 | 182 |
| 100 | 895 | 1572 | 1512 | 1275 | 1082 | 905 | 708 | 505 | 381 | 165 |
| **null** | **900** | **1620** | **1440** | **1260** | **1080** | **900** | **720** | **540** | **360** | **180** |

Pearson statistics against the triangular null (9 degrees of freedom):
`lag 1: 11.41`, `lag 12: 11.14`, `lag 13: 9.73` — all unremarkable.

Mean squared interval: `lag 1: 16.638`, `lag 12: 16.350`, null `16.5`.

**Interpretation via the proved moment bridge.**  `autocorrelation_moment_identity` says
`2·autocorrelation = 2·energy − Σ_v v²·N(v)`.  The lag-12 "peak" visible in the older
autocorrelation framing is exactly the deficit `16.350 < 16.5` of the second moment,
together with the unison excess `N(0) = 956` versus the null `900` — a statement about the
interval value `0`, not about the interval value `12`, whose count is `0` by theorem.

## 3. Counterexample hunt

* Claim tested: "a temporal lag of 12 produces twelve-semitone intervals."  Falsified for
  *every* decimal melody, not just π: `intervalCount x n 12 12 = 0`
  (`decimal_octave_count_eq_zero`), and computationally the observed maximum interval at
  every lag `1 … 20` in π is `9`, never `12`.
* Claim tested: "the interval histogram at a given lag constrains the melody."  Falsified:
  `exists_melody_with_intervalDistribution` builds a decimal melody realizing *any*
  prescribed histogram on `{0, …, 9}`, and
  `exists_melody_with_intervalDistribution_at_lag` does the same at every lag `ℓ ≥ 1` with
  multiplicity `ℓ`.
* Claim tested: "the lag spectrum `maxInterval` could be superadditive."  No counterexample
  to subadditivity was found, and subadditivity is now a theorem
  (`maxInterval_add_le`); a witness that it is *not* additive is the pair
  `squareWave_maxInterval_twelve` / `squareWave_maxInterval_twentyfour`, where
  `maxInterval 12 = 7` while `maxInterval 24 = 0`.

## 4. Verification of the energy identity used by the bridge

For π at lags 1 and 12, the direct sums `Σ_i (d_i − d_{i+ℓ})²` equal the moment sums
`Σ_v v² N(v)` exactly (`149742` and `147151` respectively), confirming numerically the
theorem `intervalEnergy_eq_second_moment` that the Lean development proves in general.

## 5. Reproducible script

```python
from itertools import islice
from collections import Counter

def pi_digits():                     # Gibbons' unbounded spigot
    q, r, t, k, n, l = 1, 0, 1, 1, 3, 3
    while True:
        if 4*q + r - t < n*t:
            yield n
            q, r, t, k, n, l = 10*q, 10*(r - n*t), t, k, (10*(3*q + r))//t - 10*n, l
        else:
            q, r, t, k, n, l = q*k, (2*q + r)*l, t*l, k + 1, (q*(7*k + 2) + r*l)//(t*l), l + 2

d = list(islice(pi_digits(), 10001))[1:]        # 10000 fractional digits

def dist(d, lag, n):
    c = Counter(abs(d[i] - d[i + lag]) for i in range(n))
    return [c.get(v, 0) for v in range(10)]

n = 9000
for lag in (1, 2, 12, 13, 100):
    print(lag, dist(d, lag, n))
print("null", [n*(10 if v == 0 else 2*(10 - v))/100 for v in range(10)])
```
