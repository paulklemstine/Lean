# Computational evidence

Target statement: for every fixed `0 < δ < 1` there is `C(δ) > 0` such that for all large
`n` there is `S ⊆ [n]` with `|S| ≥ δn` and no sumset `A + B ⊆ S` with
`min(|A|,|B|) ≥ C(δ)·log n / log(1/δ)`, with `C(δ) = 3 + o(1)`.

Below, `δ = 1/2` and `m = ⌈δ n⌉` throughout.

## 1. Kernel-verified instance (Lean, `Bridges/DeltaDenseSumsetAvoidanceExample.lean`)

The set

```
S = {0, 1, 3, 6, 8, 12, 13, 14} ⊆ [16],   |S| = 8 = 16/2
```

is proved in Lean (by `decide`, i.e. kernel computation, plus a short argument reducing
the unbounded quantifiers to the range `[0,16)`) to satisfy:

* `S` contains **no** 4-term arithmetic progression (`DeltaDense.S16_no_ap`);
* `S` contains **no** sumset `A + B` of two arithmetic progressions of common length
  `≥ 4` with arbitrary positive common differences (`DeltaDense.S16_no_ap_sumset`).

These are the only *verified* computations reported here.

## 2. Exploratory search (not machine-verified)

A random-sampling search (uniform `m`-subsets of `[n]`, several hundred trials per `n`)
records the smallest observed value of the longest arithmetic progression inside `S`, and
the smallest observed largest `k` for which an "L-shaped" witness
`{t, t+d₁, …, t+(k-1)d₁} ∪ {t+(k-1)d₁, …, t+(k-1)d₁+(k-1)d₂}` fits inside `S`.  The last
two columns are the thresholds appearing in the formal proof: the least `L` (resp. least
`k`) making the first-moment condition `n²·m^L < n^L` (resp. `n³·m^{2k-1} < n^{2k-1}`)
true.

| n   | m  | min. longest AP found | least `L` with `n²m^L < n^L` | `⌈2.5 log n / log(1/δ)⌉` |
|-----|----|-----------------------|------------------------------|--------------------------|
| 16  | 8  | 3                     | 9                            | 10                       |
| 32  | 16 | 4                     | 11                           | 13                       |
| 64  | 32 | 5                     | 13                           | 15                       |
| 128 | 64 | 6                     | 15                           | 18                       |

| n  | m  | min. largest L-witness `k` | least `k` with `n³m^{2k-1} < n^{2k-1}` | `3 log n / log(1/δ)` |
|----|----|----------------------------|-----------------------------------------|----------------------|
| 16 | 8  | 2                          | 7                                       | 12                   |
| 32 | 16 | 3                          | 9                                       | 15                   |
| 64 | 32 | 4                          | 10                                      | 18                   |

Observations.

* The observed extremal quantities grow like `log₂ n` (values `3,4,5,6` for
  `n = 16,32,64,128`), i.e. like `log n / log(1/δ)`, matching the predicted order of
  magnitude and confirming that the logarithmic scaling — not a constant or a power of
  `n` — is the right one.
* The union-bound thresholds are larger than what random sets actually achieve by a
  constant factor of about `2`–`3` in this range; this is the usual first-moment loss and
  is consistent with the constant `3` being an upper bound on the optimal `C(δ)`.
* **Counterexample hunt.** No sampled set violated the theorem: in every trial with `n`
  in the table, no arithmetic-progression sumset of common length exceeding the proved
  thresholds was contained in the sampled `δ`-dense set.  (The theorem asserts existence
  of a good `S`, so a single good sample per `n` already witnesses it, and good samples
  were abundant: a uniformly random half-density subset of `[128]` typically has longest
  AP `6`–`8`, far below the threshold `15`.)

## 3. OEIS

The quantity "minimum over `δn`-element subsets of `[n]` of the longest arithmetic
progression contained in the subset" produced the sequence `3, 4, 5, 6` for
`n = 16, 32, 64, 128` in the sampling above (upper bounds only, since the search is not
exhaustive).  No OEIS entry was identified for this sequence; the data are too short and
are upper bounds rather than exact values, so no OEIS identification is claimed.
