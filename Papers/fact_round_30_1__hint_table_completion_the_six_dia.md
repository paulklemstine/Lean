# Computational evidence — HINT-TABLE-COMPLETION (paper 104)

These are exploratory computations (plug-in entropies in bits, done in Python). Each
structural claim they suggested was then proved exactly in Lean, in `Catalog/Geometry/HintTable*.lean`.

## 1. Counterexample hunt for "the hint is universal" (`hintValue ≥ 0`)

20 000 random batteries per modulus (2–10 samples, residues uniform, 2–5 labels):

| modulus m | min hint | max hint | 2 ∣ m? |
|---|---|---|---|
| 5  | 0.0  | 2.0456 | no |
| 7  | 0.0  | 2.0    | no |
| 8  | **−1.0** | 1.9349 | yes |
| 9  | 0.0  | 1.6016 | no |
| 11 | 0.0  | 2.0    | no |
| 12 | **−1.0** | 1.93 | yes |
| 16 | **−1.0** | 1.6  | yes |
| 23 | 0.0  | 1.585  | no |
| 31 | 0.0  | 1.585  | no |

At odd moduli no negative hint was found; at even moduli the minimum is exactly −1 and never lower.
Lean: `hint_universal_iff_odd`, `neg_one_le_hintValue_of_even`, `exists_hintValue_eq_neg_one`.

## 2. Exact collision witnesses (two samples, labels 0/1)

| m | pairs (p,q) | products N | (s,d) | hint |
|---|---|---|---|---|
| 2  | (0,0),(1,1) | 0, 1 | (0,0),(0,0) | −1 |
| 6  | (0,0),(3,3) | 0, 3 | (0,0),(0,0) | −1 |
| 8  | (0,1),(4,5) | 0, 4 | (1,1),(1,1) | −1 |
| 12 | (0,1),(6,7) | 0, 6 | (1,1),(1,1) | −1 |

Pattern: with m = 2k, use (0,0),(k,k) when k is odd and (0,1),(k,k+1) when k is even.
Over ZMod 8 × ZMod 8, four samples with the same (s,d) and four distinct products give hint = −2
(`square_hintValue_eq_neg_two`).

## 3. The paper-104 table itself

Totals: Σ hint = 4.0908 and Σ capacity = 5.5015 (checked exactly). Pearson r = 0.25598 (exact
rational covariance 48451189/10⁸, variances 299900341/(1.2·10⁸) and 71677991/(5·10⁷)).
Lean: `total_hint`, `total_capacity`, `pearson_bounds`.

Window ceilings 2·log₂ m: 11 → 6.92, 5 → 4.64, 31 → 9.91, 23 → 9.05, 8 → 6.00, 9 → 6.34. All
reported hints sit well inside their windows (`table_within_windows`).

## 4. OEIS

No integer sequence came up (the objects are real-valued entropies), so no OEIS lookup applies.
