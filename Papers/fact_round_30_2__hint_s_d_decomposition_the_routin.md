# Computational evidence — paper 105 (HINT-S-D-DECOMPOSITION)

Exploratory Python enumeration (not itself a proof). Every claim used in the write-up is
proved in `Catalog/Cryptography/HintSumDifference/*.lean`.

## 1. Paper 105's mod-8 claim, all residue classes

For odd `p`, `q = N·p⁻¹ (mod 8)` and every unit `u` of `ZMod 8` satisfies `u² = 1`, so
`p + q ≡ p(1 + N) (mod 8)`. The factor classes `p mod 8` that fit each observed `s = (p+q) mod 8`:

| N mod 8 | s ↦ factor classes p | unordered pair fixed? |
|---|---|---|
| 1 | 2 ↦ {1,5}, 6 ↦ {3,7} | no ({1,1} vs {5,5}) |
| 3 | 4 ↦ {1,3,5,7} | no; s is fixed by N (carries 0 bits) |
| 5 | 2 ↦ {3,7}, 6 ↦ {1,5} | **yes** ({3,7} and {1,5} are partner pairs) |
| 7 | 0 ↦ {1,3,5,7} | no; s is fixed by N (carries 0 bits) |

Lean: `unordered_determined_iff_five`, `card_sumSufficient_classes` (1 class out of 4),
`pairSum_const_of_three_mod_four`, `paper105_ordered_claim_false`.
Counterexample with actual primes: `17·41` and `5·13` (`paper105_prime_counterexample`).

## 2. Precision law at ℓ = 2 (largest fibre of unordered pairs mod r, for odd p, q)

| data mod M | r=4 | r=8 | r=16 | r=32 |
|---|---|---|---|---|
| 8   | 1 | 2 | 2 | 2 |
| 16  | 1 | 2 | 3 | 3 |
| 32  | 1 | **1** | 2 | 4 |
| 64  | 1 | 1 | 2 | 3 |
| 128 | 1 | 1 | **1** | 2 |

A fibre size of 1 means the pair is determined. The pattern is: data mod `2^k` determines the
unordered pair mod `2^⌈k/2⌉` and no finer. Lean: `vieta_precision`, `vieta_precision_sharp`,
`d4_pair_determined_mod32`, `d4_pair_not_determined_mod16`.

## 3. Odd primes: the unrestricted law versus the separated (Hensel) regime

Largest fibre of unordered pairs mod `ℓ^k` (all pairs / pairs with `ℓ ∤ p−q`):

| ℓ | k=1 | k=2 | k=3 |
|---|---|---|---|
| 3 | 1/1 | 2/1 | 3/1 |
| 5 | 1/1 | 3/1 | 5/1 |
| 7 | 1/1 | 4/1 | 7/1 |

Separated pairs are always determined at full precision
(`vieta_full_precision_of_separated`). Odd factors are never separated at ℓ = 2
(`two_adic_never_separated`).

## 4. Counterexample hunt
We searched for a pair determined beyond precision `⌈k/2⌉` at ℓ = 2 (M ≤ 128) and found none;
the lower bound is proved in general (`vieta_precision_sharp`).
No OEIS lookup was relevant.
