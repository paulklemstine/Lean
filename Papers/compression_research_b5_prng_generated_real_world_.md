# Computational evidence — PRNG detection and seed recovery (B5)

All numbers below were produced with `#eval` inside the project (Lean 4 /
Mathlib v4.28.0) against the *formal* definitions in
`Catalog/MachineLearning/PRNGSeedRecoveryLFSR.lean`,
`Catalog/MachineLearning/PRNGSeedRecoveryLCG.lean` and
`Catalog/MachineLearning/PRNGSeedDetection.lean`.  They are evidence, not
proofs; every claim that is asserted as a theorem is proved separately in Lean
with no `sorry`.

## 1. The formal LFSR generator emits the expected stream

Taps `c = (1,1,0,0)` (the polynomial `x⁴ + x + 1`), seed `1000`.  First 32 bits
of `lfsrBits 4 c s`:

```
1 0 0 0 1 0 0 1 1 0 1 0 1 1 1 1 0 0 0 1 0 0 1 1 0 1 0 1 1 1 1 0
```

* Cross-check: an independent iterative implementation (`fastRun`, window-based,
  linear time) agrees with the formal `lfsrRun`-based `lfsrBits` on the first 12
  bits — `true`.
* Period test: `bit n == bit (n+15)` for `n = 0 … 14` — all `true`.
  The register is maximal length, period `2⁴ − 1 = 15`, as expected for a
  primitive connection polynomial.

*Note recorded for future work:* the formal `lfsrRun` is defined by the
mathematically transparent recursion `x(n) = ∑ᵢ cᵢ x(n−L+i)` and therefore takes
exponential time to evaluate naively; an equivalent state-iterating generator is
linear time.  This gap is Conjecture C4 in `FUTURE_DIRECTIONS.md`.

## 2. How many files are actually seed-compressible?

Order-3 binary LFSRs, all `2³ · 2³ = 64` (taps, seed) pairs:

| window length `N` | distinct streams produced | naive bound `4^L` | proved bound `4^L − 2^L + 1` | total `2^N` |
|---|---|---|---|---|
| 12 | **43** | 64 | 57 | 4096 |
| 16 | **43** | 64 | 57 | 65536 |

So at `N = 16` only `43 / 65536 ≈ 6.6·10⁻⁴` of files are order-3 seed
compressible.  The count saturates at `N = 12` already (all order-3 streams are
periodic with period dividing 7 or 1).

The observed `43 < 57 < 64` motivated `card_seedCompressible_le_sharp`: every
zero-seed register emits the all-zero file, which alone removes `2^L − 1`
candidates from the naive count.  The residual gap `57 − 43 = 14` comes from
further coincidences between tap vectors of lower effective order — see
Conjecture C1 in `FUTURE_DIRECTIONS.md`.

## 3. LCGs over `ℤ/m`

`a = 5, b = 3, m = 16`, seed `0`:

```
0 3 2 13 4 7 6 1 8 11 10 5 12 15 14 9 0 3 2 13 …
```

purely periodic with full period 16 (`5 ≡ 1 mod 4`, `gcd(3,16)=1`: Hull–Dobell).
This is an instance of `exists_lcg_period` (`5 · 13 = 65 ≡ 1 mod 16`, so the
multiplier is a unit).

Order-2 recurrence check `x(n+2) = (1+a)·x(n+1) − a·x(n)` for `n = 0 … 17`:
all `true`.  This is the computational shadow of `lcgSeq_isLinRec`, which says
that *every* LCG is an order-2 linear recurrence, so the LFSR fingerprint
detects the whole LCG family.

Counting over `ℤ/8`, all `8³ = 512` parameter triples `(a, b, s)`:

* distinct length-8 streams produced: **344** (bound `m³ = 512` — see
  `lcg_prefix_card_le`),
* total length-8 streams over `ℤ/8`: `8⁸ = 16 777 216`.

Detected fraction: `344 / 16 777 216 ≈ 2.0·10⁻⁵`.

## 4. Counterexample hunt

* Claim "every file is `L`-seed compressible" — refuted computationally already
  at `N = 16, L = 3` (43 of 65536 files), and proved false in general by
  `exists_not_seedCompressible` whenever `2L < N`.
* Claim "an LCG needs its own detector" — no counterexample found; instead it is
  a theorem that an LCG is always an order-2 linear recurrence
  (`lcgSeq_isLinRec`).
* Claim "tap recovery is always unique" — **false**; the degenerate case is a
  stream whose state windows do not span `F^L` (e.g. the all-zero stream, where
  every tap vector fits).  This is exactly the content of
  `taps_unique_iff_windowSpan`.

## 5. OEIS

No new integer sequence arises here; the relevant counts (`43`, `344`) are
window-length- and modulus-specific and were not matched to an OEIS entry.
