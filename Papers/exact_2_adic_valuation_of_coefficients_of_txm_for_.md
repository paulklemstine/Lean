# Computational Evidence — 2-adic valuations of coefficients of `T(x)^m`

Let `T(x) = ∏_{k≥0} (1 - x^{2^k})` be the Thue–Morse generating function, with
coefficient sequence `tm(n) = (-1)^{s₂(n)}` (`s₂` = binary digit sum). Write
`T(x)^m = ∑ t_m(n) x^n`. The `t_m(n)` were computed by directly convolving `tm`
with itself `m` times. Here `ν₂` denotes the 2-adic valuation.

## 1. The brief's universal claim

> For every odd `m ≡ 1 (mod 4)` and all `n ≥ 0`, `j ∈ {0,…,m-2}`:
> `ν₂(t_m((m-1)n+j)) = (m-1)·⌈ν₂(n+1)/2⌉ − ((m-1)/4)·(ν₂(n+1) mod 2)`.

## 2. Small-case calculations

First coefficients of `T(x)^5` (matches OEIS-style ±/blocks):
```
t5(0..15) = 1, -5, 5, 15, -40, 24, 40, -120, 135, 45, -301, 265, 80, -400, 400, 176
ν₂        = 0,  0, 0,  0,   3,  3,  3,    3,   0,  0,    0,   0,  4,    4,   4,   4
```
So `ν₂(t5(n))` is **constant on length-4 blocks** `{4q, 4q+1, 4q+2, 4q+3}`, with
block value depending only on `ν₂(q+1)`:
```
ν₂(q+1) : 0  1  2  3  4  5 ...
block ν₂: 0  3  4  7  8 11 ...   ( = 2·ν₂(q+1) + (ν₂(q+1) mod 2) )
```

## 3. Counterexample hunt against the universal claim

Convolving `tm` `m` times and comparing `ν₂` to the formula for `n < 500`:

| m  | formula holds? | notes |
|----|----------------|-------|
| 5  | ✅ all n       | reduces to `ν₂ = 2·ν₂(q+1) + (ν₂(q+1) mod 2)` |
| 9  | ❌             | `ν₂` is constant in `j`, but equals `⌊(5v+(v mod 2))/2⌋`, **not** the brief's `8⌈v/2⌉−2(v mod 2)` |
| 13 | ❌             | not even constant across `j` — block structure breaks |
| 17 | ❌             | matches at small `v`, breaks at `v = 5` |
| 21 | ❌             | not constant across `j` |
| 25 | ❌             | not constant across `j` |

**Smallest explicit counterexample.** `m = 9`, `n = 1`, `j = 0`. Index
`(m-1)n+j = 8`. Here `ν₂(n+1) = ν₂(2) = 1`, so the brief predicts
`8·⌈1/2⌉ − 2·(1 mod 2) = 8 − 2 = 6`. But
```
t9(8) = 2376 = 2³ · 297,   ν₂(t9(8)) = 3  ≠  6.
```
This is formalized in `GeneralRefutation.lean` (`brief_formula_fails_at_m9`,
`tmpow9_8_valuation`).

**Conclusion.** The universal claim is false. It holds **only for `m = 5`**, where
it reads `ν₂(t5(4q+j)) = 2·ν₂(q+1) + (ν₂(q+1) mod 2)` for `j ∈ {0,1,2,3}`
(verified for all `0 ≤ q < 2000`).

## 4. Structure discovered for `m = 5`

* Mod-2 recursion: `t5(n) ≡ t5(⌊n/2⌋) + t5(⌊n/2⌋−2) (mod 2)` for `n ≥ 4`
  (verified `n < 4000`). Gives `t5(n)` odd `⟺` `⌊n/4⌋` even (the `v=0` layer).
  Formalized: `t5_mod2`, `t5_odd_iff`.
* Self-similar block-doubling law: block `2r+1` (indices `8r+4..8r+7`) is an explicit
  linear combination of block `r`. Formalized: `t5_odd_block`.
* Even-block odd-parts mod 8 are a permutation of `{1,3,5,7}`; the two occurring
  patterns `[1,3,5,7]` / `[7,5,3,1]` are selected by the **Thue–Morse sign of
  `r/2`** — an unexpected self-reference. (Observed `r < 24`; drives the `v=1`
  layer; not yet formalized.)

## 5. Faithfulness check

The linear-recursion sequence `t5` used for the proofs agrees with the genuine
`5`-fold Cauchy convolution of `tm` (the literal coefficients of `T(x)^5`) for all
`0 ≤ n < 40` — see `t5_eq_tmpow5_lt_40`.
