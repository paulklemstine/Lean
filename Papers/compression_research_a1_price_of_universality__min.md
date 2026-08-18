# Computational evidence — price of universality (Phase A, Question 1)

All numbers below were produced with Lean `#eval` (Float arithmetic) on the
definitions used in the formal development; they are *evidence*, not proof.
The proved statements are the Lean theorems in `Catalog/NumberTheory/`.

## 1. Shtarkov sums of the Bernoulli (memoryless, binary) class

`C_n = Σ_j C(n,j) (j/n)^j ((n−j)/n)^(n−j)` is the Shtarkov sum whose logarithm
is the exact worst-case price of universality of the class.

| n | C_n | √(πn/2) | log₂ C_n | ½ log₂ n |
|---|-----|---------|----------|----------|
| 1 | 2.000 | 1.253 | 1.000 | 0.000 |
| 2 | 2.500 | 1.772 | 1.322 | 0.500 |
| 4 | 3.219 | 2.507 | 1.687 | 1.000 |
| 8 | 4.245 | 3.545 | 2.086 | 1.500 |
| 16 | 5.704 | 5.013 | 2.512 | 2.000 |
| 20 | 6.294 | 5.605 | 2.654 | 2.161 |
| 100 | 13.210 | 12.533 | 3.724 | 3.322 |
| 1000 | 40.303 | 39.633 | 5.333 | 4.983 |

`C_n / √(πn/2) → 1` numerically (1.017 at n = 1000), i.e.
`log₂ C_n ≈ ½ log₂ n + ½ log₂(π/2) = ½ log₂ n + 0.326`, which is the classical
Rissanen/Shtarkov rate for a one-parameter class.  This is consistent with the
formally proved sandwich in the catalog
(`½ log₂ n − 2 ≤ log₂ C_n ≤ log₂ (n+1)`) and with the new exact value
`log₂ (n+1)` for the constant-composition class (§3).

## 2. The separation, numerically

`price(deterministic class on n bits) = n` versus
`price(memoryless class) ≤ 2 log₂(n+1)`:

| n | n − 2 log₂(n+1) |
|---|------------------|
| 1 | −1.000 |
| 5 | −0.170 |
| 6 | +0.385 |
| 10 | 3.081 |
| 20 | 11.215 |
| 100 | 86.68 |

The gap changes sign at `n = 6` and then diverges — matching the proved
`average_price_gap_tendsto_top`.

## 3. Constant-composition class

Its Shtarkov sum is exactly `n + 1` (proved: `shtarkovSum_compositionClass`), so
its price is `log₂(n+1)`: 3.46 bits at n = 10, 6.66 at n = 100, 9.97 at n = 1000
— larger than the Bernoulli price (2.22 / 3.72 / 5.33) by about a factor 2, as
expected since the composition class is the "conditioned" family with `n+1`
mutually singular members.

## 4. Counterexample hunt

* *Is the average-case price always strictly below the worst-case price?*  No —
  for mutually singular classes the two coincide (both `log₂ #Θ`); this is
  proved (`singular_minimax_average_exact` vs
  `shtarkovSum_eq_card_of_disjoint_supports`).  Only `≤` holds in general
  (`klDiv_nml_le_logb_shtarkovSum`).
* *Is `t log₂ t ≥ −1` on `[0,1]`?*  Numerically the minimum is
  `−1/(e ln 2) = −0.5307`, so `−2` (the constant used in
  `mul_logb_self_ge`) is safe with room to spare; the sharper constant is not
  needed anywhere.
* *Is the Shtarkov sum of a union of two classes equal to the sum of the
  Shtarkov sums?*  No: `Σ_x max(S₁ x, S₂ x) < C₁ + C₂` whenever the classes
  overlap (e.g. two copies of the same class give `C` and not `2C`), which is
  why only subadditivity is proved (`shtarkovSum_sigma_le`).
