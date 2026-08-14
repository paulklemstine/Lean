# Computational evidence — Experiment 398 (CFPERIOD-NULL)

All numbers below were produced by `#eval` on the *same* Lean definitions that
the theorems are stated about (`CFPeriodNull.cfRun`, `Catalog/Shared/CFPeriodNull.lean`),
so the evidence and the formal statements cannot drift apart.  Evidence is
evidence: only the statements proved in the `.lean` file are verified.

## 1. Period table of `√N` (non-squares, `2 ≤ N ≤ 39`)

Period `l` = least `k ≥ 1` with `d_k = 1` in the PQa run:

```
N : 2  3  5  6  7  8 10 11 12 13 14 15 17 18 19 20 21 22 23 24 26 27 28 29 30 31 32 33 34 35 37 38 39
l : 1  2  1  2  4  2  1  2  2  5  4  2  1  2  6  2  6  6  4  2  1  2  4  5  2  8  4  4  4  2  1  2  2
```

This reproduces OEIS **A003285** (period of the continued fraction of `√n`)
term by term on this range, which is the correctness check for the state
machine.  Three of these are re-proved inside Lean (`cf_13`, `cf_21`, `cf_65`).

## 2. Period-end unit and its norm

At the first `k` with `d_k = 1` the state satisfies `h² − N q² = ±1`
(theorem `cfRun_pell`).  Sample:

| N  | l | h    | q  | h²−Nq² |
|----|---|------|----|--------|
| 2  | 1 | 1    | 1  | −1 |
| 7  | 4 | 8    | 3  | +1 |
| 13 | 5 | 18   | 5  | −1 |
| 19 | 6 | 170  | 39 | +1 |
| 21 | 6 | 55   | 12 | +1 |
| 29 | 5 | 70   | 13 | −1 |
| 31 | 8 | 1520 | 273| +1 |
| 65 | 1 | 8    | 1  | −1 |

Norm `−1` occurs **exactly** on the odd periods in every computed case — the
negative-Pell dichotomy.  The half of it that is unconditional
(`norm −1 ⇒ no prime factor ≡ 3 mod 4`) is proved
(`negPell_prime_factor_ne_three_mod_four`).

## 3. Semiprime sweep: does the unit factor `N`?

All odd semiprimes `N = p·q`, `3 ≤ p < q`, `N < 300` (53 of them).  For each we
computed `l`, the unit `x = h`, `gcd(x−1, N)` and `gcd(x+1, N)`:

```
(N, l, x, norm, gcd(x-1,N), gcd(x+1,N))
(15,  2, 4,        1,   3,  5)   (21,  6, 55,       1,  3,  7)
(33,  4, 23,       1,  11,  3)   (35,  2, 6,        1,  5,  7)
(51,  2, 50,       1,   1, 51)   (55,  4, 89,       1, 11,  5)
(65,  1, 8,       -1,   1,  1)   (69,  8, 7775,     1, 23,  3)
(85,  5, 378,     -1,   1,  1)   (91,  8, 1574,     1, 13,  7)
(119, 4, 120,      1, 119,  1)   (123, 2, 122,      1,  1,123)
(133,16, 2588599,  1,  19,  7)   (145, 1, 12,      -1,  1,  1)
(185, 5, 68,      -1,   1,  1)   (187, 6, 1682,     1,  1,187)
(205, 8, 39689,    1,  41,  5)   (253,22, 3222617399,1, 11, 23)
(265, 9, 6072,    -1,   1,  1)   (291, 2, 290,      1,  1,291)
```

* **41 / 53** period-end units give a proper factor via `gcd(x ± 1, N)`
  (77 %, matching the 206/269 = 77 % of the original sweep).
* **5 / 53** have odd period (`65, 85, 145, 185, 265`) — every one of them is
  `5 · q` with `q ≡ 1 (mod 4)`, as the congruence bit predicts; on those the
  unit has norm `−1` and both gcds are trivial.
* The remaining **7** have even period but `x ≡ ±1 (mod N)`, so the split-root
  exit does not fire (e.g. `51, 119, 123, 187, 291`).

The cost is the point: for `N = 253` the period is `l = 22` and the unit has
10 digits; `l` grows like `√N`, not like `log N`.

## 4. De-confounding check and counterexample hunt

Partial quotients of `√N` over one full period, for all 283 non-square
`N ≤ 300`:

* `max_k a_k = 2·⌊√N⌋` on **283 / 283** instances — the maximal partial quotient
  is a pure `N`-size coordinate.  (Example: `√21 = [4; 1,1,2,1,1,8]`,
  `2⌊√21⌋ = 8`; `√13 = [3; 1,1,1,1,6]`.)  Both halves are now **theorems**:
  `cf_partial_quotient_le_two_a0` (cap) and `cf_period_end_quotient`
  (attainment).
* At the end of the period `m_l = ⌊√N⌋` on **283 / 283** instances; this is the
  hypothesis of `cf_period_end_quotient` and is left as an open (classical)
  periodicity statement, not assumed anywhere else.
* Cheap-period window `l ≤ 2`: every such `N ≤ 300` is `m² + c` with small `c`,
  and the unit's gcds are trivial (`51, 65, 123, 145, 291` in the sweep above).
  Proved for `c = 1, 2` (`cheap_window_null_m2_add_one`,
  `cheap_window_null_m2_add_two`).
* Odd prime powers: no split square root of `1` can exist — proved outright
  (`sqrt_one_prime_pow`, `cf_channel_null_on_prime_powers`), so no search was
  needed.
