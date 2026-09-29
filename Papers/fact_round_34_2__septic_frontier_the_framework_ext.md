# Computational Evidence — SEPTIC-FRONTIER (paper 120)

Status: **exploratory**. The numbers in §2 come from a plain Python script
(distinct-degree factorisation of `x^7 - 3` over `F_p`). They are **not** checked in Lean.
Everything in §1 is proved in Lean in `Catalog/Novelty/SepticFrontier.lean`.

## 1. Exact model values (proved in Lean)

The Galois group of `x^7 - 3` is `F42 = AGL(1,7)`. The splitting type of a uniform
element `x ↦ a x + b` in this group:

| type (fixed roots, cycle length) | factorisation pattern | count / 42 | condition on `a = p mod 7` |
|---|---|---|---|
| (7,1) | 1·1·1·1·1·1·1 | 1  | a = 1, b = 0 |
| (0,7) | 7             | 6  | a = 1, b ≠ 0 |
| (1,2) | 1·2·2·2       | 7  | ord a = 2 |
| (1,3) | 1·3·3         | 14 | ord a = 3 |
| (1,6) | 1·6           | 14 | ord a = 6 |

* `H(T) = 4/21 + (6/7)·log₂3 + (1/6)·log₂7 ≈ 2.01691` bits (`septic_type_entropy`)
* `I(T ; p mod 7) = 1/3 + log₂3 = typeEntropy 6 ≈ 1.91830` bits (`septic_conductor_info`,
  `septic_conductor_eq_sextic`)
* `H(T | p mod 7) = (1/6)·log₂7 − 1/7 − (1/7)·log₂3 ≈ 0.09861` bits (`septic_residual`)
* The general prime-degree law `I(T ; p mod q) = typeEntropy (q−1)` (`agl_conductor_info`).

## 2. Prime data (exploratory, Python)

All primes `p < 300000`, `p ∉ {2,3,7}` (N = 25994). Factorisation patterns, scaled to /42:

| pattern | observed (×42/N) | predicted |
|---|---|---|
| 1·6 | 14.02 | 14 |
| 1·3·3 | 13.98 | 14 |
| 1·2·2·2 | 7.01 | 7 |
| 7 | 6.03 | 6 |
| 1^7 | 0.96 | 1 |

Observed `H(T) = 2.01466` (predicted 2.01691).

Empirical mutual information `I(T ; p mod m)` in bits:

| m | 3 | 4 | 5 | 7 | 8 | 9 | 11 | 13 | 14 | 21 | 28 | 49 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| I | 0.00001 | 0.00001 | 0.00026 | **1.91838** | 0.00018 | 0.00024 | 0.00053 | 0.00047 | **1.91838** | **1.91839** | **1.91839** | **1.91866** |

Observations:
* The signal appears exactly when `7 | m` and matches the predicted `1/3 + log₂3 = 1.91830`
  to within 1e-4.
* **Mod 3 is flat** (1e-5), even though 3 is ramified in the splitting field. This matches
  `abelian_character_kills_translations`: abelian (cyclotomic) information sees only the
  linear part `a = p mod 7`, so `ℚ(ζ_3)` is linearly disjoint from the splitting field.
  So "conductor moduli" should be read as "multiples of 7", not "moduli divisible by 3 or 7".
* The small non-zero values at coprime `m` are the expected finite-sample upward bias of
  plug-in mutual information (of order (#cells)/(2N ln 2)); the value at `m = 49` is
  inflated for the same reason (294 joint cells).

## 3. Counterexample hunt

No prime in the range contradicted the five-type list. No coprime modulus showed a
signal above the sampling-noise level.

## 4. OEIS

No integer sequence came up that needed an OEIS lookup.
