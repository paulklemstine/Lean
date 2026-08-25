# Computational evidence — k-taxonomy (pin / census-optimal / econ-optimal)

All numbers below were produced by the script at the end of this file (`python3`, < 2 s).
They are *evidence*, not proof: every claim that survived is proved in Lean in
`Catalog/Cryptography/KTaxonomyCensusEcon.lean` and
`Catalog/Cryptography/KTaxonomyGeneralWidth.lean`.  The Lean file names for each item are
given in the last column.

Objectives used throughout (`k : ℕ`):

* census `V(k; W) = k + (W / 2^k + 1) / 2`
* economics `E(k; T₀, c_q) = c_q (1 + k) + (T₀ - 1) / 2^k`
* pin `k_pin(W) = ⌈log₂ W⌉`

## 1. Dyadic census: tie set and exact optimal value

| `W = 2^m` | census argmin set | offsets rel. `log₂ W` | `V*` | `= m + 1/2`? |
|---|---|---|---|---|
| 2¹ | {0} | {−1} | 1.5 | yes |
| 2² | {0, 1} | {−2, −1} | 2.5 | yes |
| 2³ | {1, 2} | {−2, −1} | 3.5 | yes |
| 2⁴ | {2, 3} | {−2, −1} | 4.5 | yes |
| 2⁵ | {3, 4} | {−2, −1} | 5.5 | yes |
| 2⁶ | {4, 5} | {−2, −1} | 6.5 | yes |
| 2¹² | {10, 11} | {−2, −1} | 12.5 | yes |

Scan over all dyadic `W ≤ 4096`: offsets always in `{−2, −1}` and `V* = log₂ W + 1/2`
exactly (no floating-point slack).  → proved as `census_dyadic_min`,
`census_dyadic_eq_iff`, `census_dyadic_argmin_iff`.

## 2. The anchor identity

`E(k; T₀, 1) − (V(k; 2(T₀−1)) + 1/2)`, maximum absolute value over
`T₀ ∈ {2.5, 10, 1072.425, 286205.89}` and `k ∈ [0, 40)`: **0.0** (exact in binary floating
point).  → proved as the exact algebraic identity `econ_eq_census_anchor`, hence
`econ_argmin_iff_census_argmin`.

## 3. Unconverted (same-number) inputs shift the optimum by exactly +1

| `T₀` | econ argmin | census argmin at `W = T₀ − 1` | shift |
|---|---|---|---|
| 10 | {3} | {2} | +1 |
| 1072.425 | {10} | {9} | +1 |
| 286205.89 | {18} | {17} | +1 |

→ proved as the identity `econ_eq_census_naive_shift` (`E(k+1) = V(k) + 3/2`), so the shift
is `+1` for *every* anchor, and `kOptEcon_eq_kOptCost_add_one` for the continuous locations.

## 4. Reproduction of the recorded `exp563` rows

| run | `T̄₀` | continuous prediction `log₂((T̄₀−1) ln 2)` | econ argmin | matched-anchor census argmin |
|---|---|---|---|---|
| balanced | 1072.425 | 9.536549 | 10 | 10 |
| unbalanced | 286205.89 | 17.597922 | 18 | 18 |

These match the previously recorded values.  → proved as `exp563_balanced_argmin`,
`exp563_unbalanced_argmin` (global minimality over all `k : ℕ`),
`exp563_balanced_census_argmin`, `exp563_unbalanced_census_argmin`, and the certified
brackets `exp563_balanced_pred_bracket` (`9 < k < 10`),
`exp563_unbalanced_pred_bracket` (`17 < k < 18`).  The decimal digits themselves are *not*
certified in Lean; the exact characterisation `2 ^ k_opt = (T₀ − 1) ln 2 / c_q`
(`two_rpow_kOptEcon`) plus the integer bracket is what is proved.

## 5. Counterexample hunt: is the pin ever optimal?

Scanned every integer width `2 ≤ W ≤ 4096`: the pin `⌈log₂ W⌉` is **never** in the census
argmin set, and the observed gaps `k_pin − k_opt` are exactly `{1, 2}`.  No counterexample
found.  → proved *for all* `W ≥ 2` (not just the scanned range) as
`census_pin_strictly_suboptimal`, `census_pin_not_argmin`, `pin_gap_general`.

## 6. OEIS

No new integer sequence arises: the census argmin as a function of `m` is `m − 2, m − 1`
(shifted copies of the identity), so an OEIS lookup is not informative here.

## Script

```python
import math
def census(W,k): return k + (W/2**k + 1)/2
def econ(T0,k,cq=1.0): return cq*(1+k) + (T0-1)/2**k
def argmin_set(f, kmax=64):
    vals=[f(k) for k in range(kmax)]
    m=min(vals); return [k for k,v in enumerate(vals) if abs(v-m)<1e-12], m

for m in range(1,13):                      # 1. dyadic tie set / exact value
    W=2**m; s,v=argmin_set(lambda k: census(W,k))
    assert sorted(k-m for k in s) in ([-2,-1],[-1]) and abs(v-(m+0.5))<1e-12

err=0.0                                     # 2. anchor identity
for T0 in [2.5,10.0,1072.425,286205.89]:
    for k in range(0,40):
        err=max(err,abs(econ(T0,k)-(census(2*(T0-1),k)+0.5)))
assert err==0.0

for T0 in [10.0,1072.425,286205.89]:        # 3. unconverted shift
    se,_=argmin_set(lambda k: econ(T0,k)); sc,_=argmin_set(lambda k: census(T0-1,k))
    assert [a-b for a,b in zip(se,sc)]==[1]*len(se)

for T0 in [1072.425,286205.89]:             # 4. exp563 rows
    print(T0, round(math.log2((T0-1)*math.log(2)),6),
          argmin_set(lambda k: econ(T0,k))[0],
          argmin_set(lambda k: census(2*(T0-1),k))[0])

gaps=set()                                  # 5. pin never optimal
for W in range(2,4097):
    pin=math.ceil(math.log2(W)); s,_=argmin_set(lambda k: census(W,k))
    assert pin not in s; gaps |= {pin-k for k in s}
assert gaps=={1,2}
print("ALL PASS")
```

## 7. Round-3 items (rigidity)

* **Price rescaling.** For `c_q ∈ {0.25, 1, 4}` and `T₀ ∈ {10, 1072.425, 286205.89}`, the
  argmin of `E(·; T₀, c_q)` agrees with the argmin of `V(·; 2(T₀−1)/c_q)` in every case.
  → proved for all `c_q > 0` as `econ_argmin_iff_census_argmin_price`.
* **Counterexample that corrected a conjecture.**  The natural guess "pin gap `2` happens
  only at dyadic widths" is **false**: at `W = 3` the census values are
  `V(0) = 2, V(1) = 2.25, V(2) = 2.875`, so the unique optimum is `k = 0` while the pin is
  `⌈log₂ 3⌉ = 2` — gap `2` at a non-dyadic width.  The corrected statement (gap `1` iff
  `W = 2^(k+1)`, gap `2` otherwise) is proved as `pin_gap_one_iff_two_pow` and
  `pin_gap_two_of_not_two_pow`.
* **Overcharge range.**  Scanning `2 ≤ W < 200000`: the overcharge
  `V(k_pin) − min_k V(k)` has minimum exactly `0.5` and maximum `1.2499942…`, attained at
  `W = 131073 = 2¹⁷ + 1`; along `W = 2^m + 1` the values increase
  `1.0625, 1.15625, 1.203125, …, 1.249999`, approaching `5/4` without reaching it.
  → proved as `pin_overcharge_bounds` (`1/2 ≤ overcharge < 5/4` for every `W ≥ 2`).
* **Running average of the overcharge** over `2 ≤ W ≤ N`: `0.87985` (`N = 10³`),
  `0.92735` (`N = 10⁴`), `0.93621` (`N = 10⁵`), `0.87497` (`N = 2¹⁸`), `0.91546`
  (`N = 3·10⁵`) — an oscillation, not a convergence.  This is *not* proved; it is the
  open conjecture "Log-Periodic Mean of the Pin Overcharge" in `FUTURE_DIRECTIONS.md`.
