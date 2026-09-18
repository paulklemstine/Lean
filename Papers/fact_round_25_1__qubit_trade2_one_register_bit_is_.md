# Computational evidence — QUBIT-TRADE2 (the fungibility ramp)

All numbers below were computed inside Lean (`#eval` over the very definitions
used in the theorems) and the load-bearing ones are additionally **kernel
checked** as `by decide` examples inside the Lean files, so they are part of
the verified artefact rather than side computations:

* `Catalog/Shared/ShorPeakCertificationRamp.lean`, §6 Lab notes;
* `Catalog/Shared/ShorRampSharpness.lean`, §4 Lab notes;
* `Catalog/Shared/ShorInformativeRamp.lean`, §4 Lab notes.

The object measured is the **certification set**
`certPeaks q r = { j < r : ∃ k ∈ ℤ, |k/q − j/r| ≤ 1/(2r²) }`, the set of Shor
peaks that can pass the continued-fraction test with denominator bound `r`,
and its informative subset `infoPeaks q r` (numerator coprime to `r`).

## 1. Small-case calculations: the single-sample ramp

`r = 21` (`3 · 7`), `q = 2^t`:

| `t` | `q`  | `#certPeaks` | `2⌊q/2r⌋+1` | rate `#/r` | `q/r²` |
|-----|------|--------------|-------------|-----------|--------|
|  5  |  32  |      1       |      1      |  0.048    | 0.073  |
|  6  |  64  |      3       |      3      |  0.143    | 0.145  |
|  7  | 128  |      7       |      7      |  0.333    | 0.290  |
|  8  | 256  |     13       |     13      |  0.619    | 0.580  |
|  9  | 512  |     21       |  25 (sat.)  |  1.000    | 1.161  |

`r = 15`: counts `1,1,1,1,1,3,5,9,15,15,…` for `t = 0…9`; `r = 11` (prime):
`1,1,1,1,1,3,5,11,11,…`; `r = 8` (pure power of two): `1,2,4,8,8,8,…` — the
flat-saturated degenerate family of the round (measurement 1), because every
peak sits exactly on a grid point once `r ∣ q`.

The rate column tracks `q/r²` with unit slope and saturates; this is the
**ramp**, proved exactly as `card_certPeaks` + `ramp_lower`/`ramp_upper`.

## 2. Counterexample hunt: is there a wall?

The pre-registered hypothesis was a *vertical wall* at `q = r²` for odd `r`.
The hunt found certificates far below it:

* `r = 21`, `q = 64 = 3r` → 3 certifying peaks, 2 of them informative
  (`j` with `gcd(j,21)=1`), i.e. certification already works at
  `q/r² = 0.145`;
* the general construction (`subwall_certificate`) needs only `q ≥ 2r`.

So the quadratic wall is **refuted**.  Conversely the search found a genuine
wall one order lower: for `q < 2r` the informative set is empty in every case
tested (`r = 21`, `q ≤ 32`; `r = 15`, `q ≤ 16`; `r = 11`, `q ≤ 16`), which is
`infoPeaks_eq_empty_iff` — an **iff**, so this is the exact boundary.

Saturation was likewise measured against the folklore `r²`: for `r = 21`,
`q = 256` is *not* saturated while `r(r-1) = 420 ≤ 512` is; for `r = 15`,
`q = 256 ≥ 210 = r(r-1)` is saturated although `q < r² = 225` fails — both
matching `wall_position_odd`, not `q = r²`.

## 3. The informative sub-ramp

| `r`  | `q`  | `B = ⌊q/2r⌋` | `#certPeaks` | `#infoPeaks` | `2·#totatives ≤ B` |
|------|------|--------------|--------------|--------------|--------------------|
| 21   | 128  |      3       |      7       |      4       |        4           |
| 21   | 256  |      6       |     13       |      8       |        8           |
| 15   | 128  |      4       |      9       |      6       |        6           |
| 11   |  64  |      2       |      5       |      4       |        4           |
| 21   | 512  |  (sat.)      |     21       |     12       |   `φ(21) = 12`     |

Exact agreement with `card_infoPeaks` in every below-saturation row, and the
saturated row lands on `φ(r)`, as it must.

## 4. The sample axis

The compounding law `P_s = 1 − (1 − P₁)^s` is exact by construction of the
model (independent shots), so the measurable content is the *contour*.  With
`P₁ = #certPeaks / r` one gets, for `r = 21`:

| `q`  | `P₁`  | `s` needed for `P_s ≥ 1/2` | `log₂ s` | `t + log₂ s` |
|------|-------|----------------------------|----------|--------------|
|  64  | 0.143 |            5               |   2.32   |    8.32      |
| 128  | 0.333 |            2               |   1.00   |    8.00      |
| 256  | 0.619 |            1               |   0.00   |    8.00      |

`t + log₂ s` is constant to within one bit — the exchange law proved as
`contour_band` (`1/2 ≤ c·s·2^t ≤ 1` on the contour) and `exchange_band`
(`m ≤ bits bought by 2m doublings ≤ 2m`).

## 5. OEIS

The certification counts `2⌊q/(2r)⌋+1` are an elementary arithmetic family
(odd numbers indexed by a floor), so no OEIS lookup is informative here; the
totative counts of §3 are initial segments of the standard totative-counting
sequences of the individual moduli (e.g. A000010 evaluated at `r` in the
saturated row).  No new integer sequence is claimed.
