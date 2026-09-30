# Computational Evidence — D5-CONDUCTOR (x⁵ + 20x + 32)

Exploratory scripts (plain Python, not part of the verified artifact) unless marked **[Lean]**.

## 1. Discriminant
Trinomial formula `disc(x⁵+ax+b) = 5⁵b⁴ + 4⁴a⁵` gives `3 276 800 000 + 819 200 000 = 4 096 000 000
= 2¹⁸·5⁶ = 64000²` — a perfect square, so `Gal ⊆ A₅` (consistent with `D₅`).
**[Lean]** `trinomialDisc_x5_20x_32`. (The identification of this formula with Mathlib's
polynomial discriminant is *not* formalized.)

## 2. Frobenius statistics (primes 3 ≤ p < 3000, p ≠ 5; 428 primes)
| roots of f mod p | Frobenius class in D₅ | count | Chebotarev prediction |
|---|---|---|---|
| 1 | reflection | 221 | 214 (1/2) |
| 0 | 5-cycle | 175 | 171.2 (2/5) |
| 5 | identity | 32 | 42.8 (1/10) |

First primes: 3:0, 7:0, 11:1, 13:1, 17:1, 19:1, 23:0, 29:0, 31:1, 37:1, 41:0, 43:0, 47:0, 53:1, 59:1, 61:0, 67:5.

## 3. Which quadratic character is the fork?
Tested `d ∈ {−1, ±2, ±3, ±5, ±6, ±10, ±15, ±20, ±30, 40, −40}` against
"root count ∈ {0,5}  ⇔  (d/p) = 1" for all 428 primes: **only d = −5 (≡ −20) matches**.
So the quadratic subfield is `K = ℚ(√−5)`, `d(K) = −20`, conductor 20.
**[Lean]** `rootCount_certificate` / `rootCount_rotation_iff_fork` check this for all primes `< 400`
by kernel evaluation; `quintic_mod5`, `quintic_mod2` show total ramification shapes at 5 and 2.

## 4. Mutual information I(p mod m ; fork), primes < 20000 (2260 primes; fork balance 1124/1136)
| m | 4 | 5 | 8 | 10 | 16 | **20** | 40 | 64 | 80 | 160 | 320 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| I (bits) | 0.0000 | 0.0001 | 0.0002 | 0.0001 | 0.0007 | **1.0** | 1.0 | 0.0045 | 1.0 | 1.0 | 1.0 |

Exactly the multiples of 20 carry the full bit. **[Lean]** `forkDeterminedMod_iff : ForkDeterminedMod m ↔ 20 ∣ m`.

## 5. Counterexample to "|d(K)| = 320"
320 = 4·80 with 16 ∣ 80, so 320 is not a fundamental discriminant; no quadratic field has
discriminant ±320. **[Lean]** `quadDisc_ne_pm320`, `not_isFundDisc_pm320`.
