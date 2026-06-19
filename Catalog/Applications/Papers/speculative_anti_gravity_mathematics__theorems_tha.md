# Computational Evidence — Anti-Gravity Mathematics (divisor-dependency model)

We model a library of size `N` by the integers `1..N`, a "theorem" `d` by the number `d`,
and the dependency relation by `d ∣ n`. Two scalars:

* **gravitational weight** `support N d = #{n ∈ [1,N] : d ∣ n} = ⌊N/d⌋`;
* **proof length** `proofCost d = Ω(d)` = number of prime factors of `d` with multiplicity.

## 1. Small-case calculations (N = 12)

| d | ⌊12/d⌋ = weight | Ω(d) = proofCost | anti-gravity (Ω≤1)? |
|---|------------------|------------------|----------------------|
| 1 | 12               | 0                | yes (trivial axiom)  |
| 2 | 6                | 1                | yes (prime)          |
| 3 | 4                | 1                | yes (prime)          |
| 4 | 3                | 2                | no                   |
| 5 | 2                | 1                | yes (prime)          |
| 6 | 2                | 2                | no                   |
| 7 | 1                | 1                | yes (prime)          |
| 8 | 1                | 3                | no                   |
| 9 | 1                | 2                | no                   |
|10 | 1                | 2                | no                   |
|11 | 1                | 1                | yes (prime)          |
|12 | 1                | 2                | no                   |

Observations confirmed by the formal theorems:

* The trivial theorem `d=1` has maximal weight `N` (`support_one`).
* Weight is anti-monotone in `d` (`support_le_of_le`).
* The **tension bound** `weight ≤ N / 2^Ω(d)` holds in every row, e.g.
  `d=8`: `1 ≤ 12/2^3 = 1`; `d=4`: `3 ≤ 12/2^2 = 3`; `d=2`: `6 ≤ 12/2^1 = 6` (tight).
* The bound is **saturated exactly at `d=2`** (`tension_sharp`).

## 2. Tension-bound tightness check (counterexample hunt)

We searched all `1 ≤ d ≤ N` for `N ∈ {10,12,20,50,100}` for any violation of
`⌊N/d⌋ ≤ ⌊N / 2^Ω(d)⌋`. **No counterexample** found — consistent with the proved theorem
`support_le_div_two_pow`. Equality cases are exactly the powers of two `d = 2^k ≤ N` (each
factor equal to the minimal prime 2), the "purest" anti-gravity directions.

## 3. Abundance check

For target weight `w`, taking `N = 2w` makes the short-proof theorem `2` carry weight
`⌊2w/2⌋ = w`. So anti-gravity weight is unbounded (`antiGravity_weight_unbounded`), the formal
density/abundance analog of the informal "anti-gravity theorems are dense" conjecture.

## 4. Cross-domain (Tropical) bridge spot-check

Using `Catalog/Tropical/Basic.lean`'s `tropFactorRank (encodeDiag d) = d`, the product
`rank · weight = d · ⌊N/d⌋` for `N=12`:

| d | d·⌊12/d⌋ | ≤ 12? | slack 12 − d·⌊12/d⌋ = 12 % d |
|---|----------|-------|------------------------------|
| 2 | 12       | yes   | 0                            |
| 3 | 12       | yes   | 0                            |
| 5 | 10       | yes   | 2                            |
| 7 | 7        | yes   | 5                            |

All `≤ 12`, matching `rank_weight_uncertainty`; slack equals `N % d`, matching
`antiGravity_prime_bridge`.

## OEIS note

The weight column for fixed `N` is `(⌊N/d⌋)_{d≥1}` (rows of A010766 / A003988-style divisor
tables); `proofCost` is `Ω(n) = A001222`. Anti-gravity numbers (`Ω ≤ 1`) are `{1} ∪ primes`
(A008578, the noncomposite numbers). No new sequence is introduced; the content is the
*tension inequality* between A001222 and the weight, not a sequence per se.
