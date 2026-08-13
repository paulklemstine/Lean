# Computational evidence — spectral flatness of the factoring bit functions

All numbers below were produced by exact rational (`ℚ`) computation inside Lean 4 (`#eval`) in this
project's toolchain; no floating point, no external scripts. They are *evidence*, not proof: the
theorems they motivated are proved without them in
`Catalog/Novelty/WalshSpectralFlatness.lean` and `Catalog/Novelty/SpectralFlatnessFactoring.lean`.

## 1. The low block: correlation is exactly zero on the full odd support

Support: all ordered pairs `(p,q)` of odd residues mod `2^t`; public value `N = p q mod 2^t`;
target `f_j = ` bit `j` of `p`; predictor family: *all* GF(2) parities of the bits of `N`
(all `2^t` of them, i.e. every degree, not just degree ≤ 3).

| `t` | bit `j` | # parities scanned | max &#124;corr&#124; over all parities |
|----|----|----|----|
| 4 | 1,2,3 | 16 | `0` |
| 5 | 1 | 32 | `0` |
| 5 | 2 | 32 | `0` |
| 5 | 3 | 32 | `0` |
| 6 | 2 | 64 | `0` |

Exact zero, as rationals. This is the empirical face of `lowblock_corr_zero`.

**Conditional (per-fiber) version.** For each individual public value `N`, counting the
factorisations with bit `j` of `p` equal to `0` vs `1`:

| `t` | bit `j` | `(#p_j = 0, #p_j = 1)` over every fiber |
|----|----|----|
| 5 | 2 | `(8, 8)` for all 16 odd `N` |
| 6 | 3 | `(16, 16)` for all 32 odd `N` |

Every fiber, exactly balanced — the empirical face of `fiber_bit_balanced`.

**Where the reported `O(m^{-1/2})` residues come from.** Restricting the same support to the
*ordered* pairs `p < q` (the "smaller factor" convention) destroys the exact cancellation, and the
best degree-≤ 3 parity acquires a small nonzero correlation that decays with `t`:

| `t` | best degree-≤ 3 parity for bit 2 | correlation |
|----|----|----|
| 5 | `∅` (constant) | `2/15 ≈ 0.1333` |
| 6 | `∅` (constant) | `2/31 ≈ 0.0645` |
| 7 | `{6}` | `1/21 ≈ 0.0476` |

So the residual signal is a property of the *ordering constraint* (and of prime restriction), not
of the arithmetic of multiplication — exactly the "small-`k` finite-support fluctuation" reading.

## 2. The top-bit family on the exact `k`-bit prime semiprime support

Support: all pairs `p ≤ q` of `k`-bit primes. Support sizes reproduce the reported `m`:

| `k` | 5 | 6 | 7 | 8 | 9 | 10 |
|----|----|----|----|----|----|----|
| `m` | 15 | 28 | 91 | **276** | 946 | **2850** |

(`276` at `k=8` and `2850` at `k=10` match the experiment's stated support sizes.)

`corr(p_{k-d}, N_{2k-1})`, ×1000, truncated:

| `d` | k=5 | k=6 | k=7 | k=8 | k=9 | k=10 |
|----|----|----|----|----|----|----|
| 2 | 200 | 142 | 538 | 318 | 287 | 256 |
| 3 | 600 | 285 | 186 | 318 | 350 | 270 |
| 4 | 333 | 71 | 32 | 115 | 266 | 78 |

The `d = 2,3` rows settle in the `0.25–0.35` band, consistent with the reported `0.285 / 0.310`.

**The j = 2 anomaly.** `corr(p_2, N_{2k-1})`, ×1000:

| k | 6 | 7 | 8 | 9 | 10 |
|----|----|----|----|----|----|
| | 71 | −11 | **253** | −17 | **165** |

The `k = 8` and `k = 10` values (`0.253`, `0.165`) reproduce the reported `0.254 / 0.166`; the
sign flips at `k = 7, 9` identify the effect as a fluctuation, not a trend.

## 3. Counterexample hunt for the transmission law

Claim under test: `p_{k-2} = 1 ⟹ N_{2k-1} = 1` for balanced semiprimes.

| `k` | 5 | 6 | 7 | 8 | 9 | 10 |
|----|----|----|----|----|----|----|
| violations | 0 | 0 | 0 | 0 | 0 | 0 |

Zero counterexamples over all `4206` balanced prime pairs tested. Now proved unconditionally as
`second_bit_transmits_to_top_bit` (for all integer pairs, primality not needed).

## 4. The covariance of the top-bit family over the full balanced integer support

`covTop e = Cov(1[p_{k-2}=1], 1[N_{2k-1}=1])` over all pairs `2^{k-1} ≤ p ≤ q < 2^k`, `k = e+2`
(exact rationals):

| `e` | 0 | 1 | 2 | 3 | 4 |
|----|----|----|----|----|----|
| `|BalSupp|` | 3 | 10 | 36 | 136 | 528 |
| `|hiSet|` | 1 | 3 | 10 | 36 | 136 |
| `|topSet|` | 1 | 4 | 18 | 75 | 308 |
| `covTop` | `2/9` | `9/50` | `5/36` | `549/4624` | `85/792` |
| decimal | 0.222 | 0.180 | 0.138 | 0.118 | 0.107 |

Strictly positive at every size, and provably so for *all* `e` (`covTop_pos`) — the one direction
in which the spectrum is not flat.

## 5. OEIS

The support-size sequence `3, 10, 36, 136, 528` for `|BalSupp e|` is `C(2^{e+1}+1, 2)`, i.e. the
triangular numbers `T(2^{e+1})`; `|hiSet e| = |BalSupp (e-1)|` (a shift, visible in the table). No
new sequence is claimed. The `|topSet|` sequence `1, 4, 18, 75, 308` was not matched to a catalogued
sequence and is not used in any proof.
