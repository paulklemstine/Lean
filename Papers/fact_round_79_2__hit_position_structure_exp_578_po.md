# Computational evidence — hit positions of the Fermat / QS sieve polynomial

All numbers below were produced by the two pre-registered scripts in `evidence/`
(headers written before any data generation) and are reproducible from the seeds
recorded there.  **Status of these numbers: exploratory / statistical.**  They are *not*
machine-checked; the machine-checked content of this project is the Lean development in
`Catalog/NumberTheory/FermatPosition*.lean`, whose theorems are stated below where a
finding was turned into a proof.

Setting.  `m = isqrt(N) + 1`, sieve value `v(j) = (m + j)^2 - N`, a *hit* at position `j`
means `v(j)` is `B`-smooth (exact smoothness, full sieve-and-divide, no log
approximation).

---

## 1. Small-case calculations and the position–gcd law (leg L0)

`v(j) - v(0) = j (j + 2m)` gives `gcd(j, v(j)) = gcd(j, v(0))`, hence
`j ∣ v(j) ↔ j ∣ v(0)`.

Direct check (`evidence/exp579_L0_gcdlaw_check.py`, 40 random balanced 96-bit
semiprimes, 3999 positions each):

```
L0: checked 159960 (j, N) pairs, violations = 0
```

A 12-term hand example (`b = 10`, `N = 97`, so `v(0) = 3`), listing
`(gcd(j, v(j)), gcd(j, v(0)))` for `j = 1..12`:

```
[(1,1), (1,1), (3,3), (1,1), (1,1), (3,3), (1,1), (1,1), (3,3), (1,1), (1,1), (3,3)]
```

**Proved** as `FermatPosition.gcd_position_law` and `FermatPosition.dvd_sieveVal_self_iff`.

---

## 2. exp579A — is the gcd carrier a real, magnitude-free smoothness enrichment?

16 balanced 96-bit semiprimes, seed `20260829`, `J = 150000` positions per `N`,
`B = 10^6`; 67 878 hits in total.  Magnitude is controlled by comparing only positions
inside the same window of 1000 consecutive `j` (inside such a window `|v|` varies by well
under a factor 2, and by <1% in the upper half of the range).

| leg | statistic | result |
|---|---|---|
| L1 window-matched rate, `gcd(j,v0) > 1` vs `= 1` | 0.032101 vs 0.026417 | ratio **1.215**, z = **+24.2** — FIRES |
| L1 restricted to the upper half `j > J/2` | 0.028513 vs 0.023522 | ratio **1.212**, z = **+15.9** |
| L2 dose–response by `g = gcd(j, v0)` | see below | monotone, top/bottom = **2.90** — FIRES |

Dose–response (hit rate by `g`):

| `g` | 1 | 2–3 | 4–15 | 16–255 | ≥256 |
|---|---|---|---|---|---|
| rate | 0.02473 | 0.02836 | 0.03515 | 0.04244 | 0.07159 |
| positions | 1243043 | 645848 | 407414 | 100077 | 3618 |

Observed hit-position deciles (`u = j/J`):
`[.1422, .1152, .1038, .0999, .0951, .0919, .0907, .0891, .0867, .0853]` — monotone
declining, the same shape reported in exp 578 (`[.162 … .072]`).

**Conclusion.**  The gcd carrier is real: at matched magnitude, positions sharing a factor
with `v(0)` are ~21% more likely to be hits, with a clean dose–response.  This is exactly
the *free cofactor reduction* proved as
`FermatPosition.smooth_iff_cofactor_smooth` / `FermatPosition.smooth_of_pos_dvd_base`.

**But it cannot explain the small-`j` excess**: the set `{j : gcd(j, v(0)) > 1}` is
periodic in `j` with period `|v(0)|`, so its density does not depend on the position.
That is **proved** as `FermatPosition.gcd_carrier_window_card_indep`, and generalised to
every finite-modulus carrier by `FermatPosition.periodic_block_balance` (discrepancy at
most the modulus).  Only the *full-divisor* sub-carrier `j ∣ v(0)` has a genuinely
declining `1/j` profile — proved as
`FermatPosition.divisor_positions_small_j_excess` — but its total mass is tiny (the
observed counts of `j ≤ J` dividing `v(0)` were 1–64 per `N`).

---

## 3. exp579B — the decisive cross-scale test of "beyond magnitude"

Within one `N`, `v` is strictly increasing in `j`, so position and magnitude are
functionally dependent, and every bit-length cell is an *interval of positions* — proved
as `FermatPosition.sizeClass_ordConnected` and quantified by
`FermatPosition.cell_collapse` (`b·j₂ ≤ 2b·j₁ + 2b + j₁²` inside a one-bit cell).  A
within-`N` stratification by `|v|` therefore cannot decorrelate the two variables.

The dependence *can* be broken across scales: `v(j) ≈ 2^41 j` for an 80-bit modulus and
`v(j) ≈ 2^49 j` for a 96-bit one, so a value of size `2^55` sits at `j ≈ 2^14` on the
first arm and `j ≈ 2^6` on the second — a ~256-fold difference in position at matched
magnitude.

Design (seed `20260830`, `B = 10^6`): arm A96 = 300 balanced 96-bit semiprimes,
`j ≤ 2048`; arm A80 = 12 balanced 80-bit semiprimes, `j ≤ 300000`.  Pre-stated rule:
positional structure fires iff `R = rate(small-j arm)/rate(large-j arm) > 1.20` in a
majority of shared `bitlen(v)` bins with pooled `p < 0.001` in that direction.

| bitlen(v) | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 |
|---|---|---|---|---|---|---|---|---|---|---|
| R | 1.136 | 0.915 | 1.032 | 0.882 | 1.041 | 0.992 | 0.998 | 1.016 | 0.989 | 0.963 |
| z | +0.95 | −0.84 | +0.42 | −2.08 | +0.96 | −0.25 | −0.07 | +0.88 | −0.84 | −3.67 |

Inverse-variance weighted `R = 0.983` (z = −2.56); 233 752 hits in total.

**Verdict: the positional leg does NOT fire.**  At matched magnitude the small-`j` arm is
*not* hit-richer; the residual deviation is ≤4% and, where individually significant
(bitlen 59), in the *opposite* direction.  By the pre-stated rule this is not a clean
"magnitude-only" fire either (one bin is significant at `p < 0.001`), so the honest label
is **magnitude-dominant, no positional excess detected**, with the caveat that a bit-length
bin still allows a factor-2 spread of `|v|` whose within-bin mean can differ slightly
between the two arms.

Together with the proved cell-collapse theorem this says: the monotone-declining
`u`-deciles seen within a single `N` (reproduced here) are what the magnitude law
`2 b j ≤ v(j) ≤ 2 b j + j² + 2b` (`FermatPosition.sieveVal_sandwich`) predicts, plus the
positionally *uniform* gcd enrichment; the cross-scale design finds no residual
positional geometry.

---

## 4. What the sieve's positional geometry provably *is*

The one exactly known piece of positional geometry survives: square positions.
`v(j) = k²` iff `N = (b+j-k)(b+j+k)`, the only nontrivial one for a semiprime is the
terminal Fermat position `2(b+j) = p+q`
(`FermatPosition.square_position_unique`), and it obeys the same magnitude law
`2 b j₀ ≤ d²` (`FermatPosition.terminal_position_bound`).

## 5. OEIS

No new integer sequence is produced by this work: the counting functions that appear are
the divisor-counting function (positions `j ∣ v(0)`, A000005) and the harmonic partial
sums used in `harmonic_block_decline`.  No OEIS submission is warranted.
