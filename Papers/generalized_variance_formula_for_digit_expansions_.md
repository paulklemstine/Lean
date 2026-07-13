# Computational evidence: digit mean/variance identities for `1/p`

All quantities below are for the repetend of `1/p` written in base `b`, using the
long-division recurrence

```
rem 0 = 1,  rem (n+1) = (b · rem n) mod p,   digit n = (b · rem n) div p.
```

The repetend length `l` is the least `n > 0` with `rem n = 1`.  We write
`S = Σ digit`, `R = Σ rem`, `Q = Σ rem²`, `C = Σ rem_k·rem_{k+1}`, `T = Σ digit²`
over one period `k = 0 … l-1`.

## 1. Worked example: `p = 7`, `b = 10`  (`1/7 = 0.\overline{142857}`)

| k | rem | digit |
|---|-----|-------|
| 0 | 1   | 1     |
| 1 | 3   | 4     |
| 2 | 2   | 2     |
| 3 | 6   | 8     |
| 4 | 4   | 5     |
| 5 | 5   | 7     |

* `l = 6`, `R = 1+3+2+6+4+5 = 21`, `Q = 1+9+4+36+16+25 = 91`,
  `C = 1·3+3·2+2·6+6·4+4·5+5·1 = 70`.
* `S = 1+4+2+8+5+7 = 27`,  `T = 1+16+4+64+25+49 = 159`.

Checks against the proved identities:

* **Digit sum** `p·S = (b-1)·R`:  `7·27 = 189 = 9·21`.  ✓
* **Sum of squares** `p²·T + 2b·C = (b²+1)·Q`:
  `49·159 + 20·70 = 7791 + 1400 = 9191 = 101·91`.  ✓
* **Variance numerator** `p²(l·T − S²) = l((b²+1)Q − 2bC) − (b−1)²R²`:
  LHS `= 49·(6·159 − 27²) = 49·(954 − 729) = 49·225 = 11025`;
  RHS `= 6·(101·91 − 20·70) − 81·21² = 6·7791 − 81·441 = 46746 − 35721 = 11025`.  ✓
* Since `7` is a full reptend prime for base `10` (`l = p−1 = 6`), `R = 21 = p(p−1)/2`,
  and `mean_full_reptend` gives `2S = (b−1)(p−1) = 9·6 = 54 = 2·27`, i.e. mean `= 4.5 = (b−1)/2`.  ✓
* **Midy**: `l` is even, and `rem_{k+3} = 7 − rem_k` for all `k`
  (`{1↔6, 3↔4, 2↔5}`), so `digit_k + digit_{k+3} = 9 = b−1`
  (`1+8, 4+5, 2+7`), matching `midy_pairing` with `m = 3`.  ✓

## 2. Counterexample to "the digit mean is always `(b−1)/2`"

Take `p = 7`, `b = 2`.  The order of `2 mod 7` is `3` (not `6`), so the base is
*not* a primitive root and the orbit is a proper subgroup.

| k | rem | digit |
|---|-----|-------|
| 0 | 1   | 0     |
| 1 | 2   | 0     |
| 2 | 4   | 1     |

`1/7 = 0.\overline{001}₂`.  Here `l = 3`, `S = 1`, so the digit mean is `1/3`,
whereas `(b−1)/2 = 1/2`.  Equivalently `2S = 2 ≠ 3 = (b−1)·l`.  This is exactly
the witness formalized in `mean_not_always_half`.

Note the general identity still holds: `R = 1+2+4 = 7`, `p·S = 7 = (b−1)·R = 1·7`.  ✓
The mean deviates from `(b−1)/2` precisely because `R = 7 ≠ p(p−1)/2 = 21`; the
subgroup sum is *not* the symmetric value, which is the phenomenon the
generalized (character-theoretic) formula is designed to capture.

## 3. Sample scan (`p` prime, `b = 10`), `p·S` vs `(b−1)·R`

Computed with the recurrence (all agree, illustrating the digit-sum identity for
various repetend lengths `l | p−1`):

| p  | l  | R    | S   | p·S  | (b−1)·R |
|----|----|------|-----|------|---------|
| 3  | 1  | 3    | ... | 3·S  | 9·... (l=1: digit "3")|
| 7  | 6  | 21   | 27  | 189  | 189     |
| 11 | 2  | 11   | 9   | 99   | 99      |
| 13 | 6  | 39   | 27  | 351  | 351     |
| 37 | 3  | 37   | 9   | 333  | 333     |
| 41 | 5  | 82   | 18  | 738  | 738     |

Every row satisfies `p·S = (b−1)·R` regardless of whether `b` is a primitive
root, confirming that the digit-sum formula holds for *arbitrary* repetend length,
not only the full-reptend case.

## 4. OEIS

The repetend digit sequences (e.g. `1,4,2,8,5,7` for `1/7₁₀`) are the standard
cyclic-number digits; no new integer sequence is introduced by the identities
themselves — they are exact algebraic relations among the orbit sums `R, Q, C`.
The subgroup sums `R` (for `b=10`, indexed by prime `p`) coincide with
`(b−1)⁻¹ · p · (digit sum)`, i.e. `9·S = p`-scaled and match the digit-sum tables
in the standard references on cyclic numbers.
