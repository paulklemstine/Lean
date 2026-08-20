# Computational evidence — the two-parameter ±-frame

All numbers below were produced by `#eval` inside the Lean project, using the
*computable* part of `Catalog/Shared/PMFrameTwoParameter.lean` (the lattice-point
counter `repPairs`), and every claim they support is separately proved as a
`sorry`-free theorem in that file.

The evaluated helper is the closed-formula coefficient

```
coeffPQ p q n = #repPairs p q n − #repPairs p q (n−1)      (n ≥ 1)
coeffPQ p q 0 = #repPairs p q 0
```

which the file proves equals `(pmFrame (p*q)).coeff n` for `n < p·q`
(`coeff_pmFrame_succ`, `coeff_pmFrame_zero`).

## 1. Small-case coefficient vectors

| `(p,q)` | `n = p·q` | coefficient vector of `Φ_{pq}` (degrees `0 … (p−1)(q−1)`) |
|---|---|---|
| `(3,5)` | 15 | `[1, −1, 0, 1, −1, 1, 0, −1, 1]` |
| `(2,11)` | 22 | `[1, −1, 1, −1, 1, −1, 1, −1, 1, −1, 1]` |
| `(5,7)` | 35 | `[1, −1, 0, 0, 0, 1, −1, 1, −1, 0, 1, −1, 1, −1, 1, 0, −1, 1, −1, 1, 0, 0, 0, −1, 1]` |

Every entry lies in `{−1, 0, 1}` — the content of
`coeff_pmFrame_two_param_mem`.  The `n = 1` entry is `−1` in each row, which is
the sharpness theorem `coeff_pmFrame_one_eq_neg_one`.

## 2. Balance

Sum of the coefficient vectors:

* `(3,5)` → `1`
* `(5,7)` → `1`

matching `pmFrame_coeff_sum_eq_one` (`Φ_{pq}(1) = 1`): the `+1`'s outnumber the
`−1`'s by exactly one.  Each vector is also a palindrome, as proved in
`coeff_pmFrame_palindromic`.

## 3. Lattice-point counts (the two-dimensional region)

`#repPairs 5 7 n` for `n = 0 … 39`:

```
1 0 0 0 0 1 0 1 0 0 1 0 1 0 1 1 0 1 0 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1
```

Two features are visible and both are theorems in the file:

* every entry is `0` or `1` (`card_repPairs_le_one`, from `repPair_unique`);
* the pattern on `0 … 23` (`= p·q − p − q`) is anti-symmetric under
  `n ↦ 23 − n` (`frameRep_reflect_iff`), and the last `0` occurs at
  `n = 23 = 5·7 − 5 − 7`, the Frobenius number.

The single `0` at `n = 35` is *not* a counterexample to the Frobenius bound: it
is the point where uniqueness stops being guaranteed and `repPairs` (which is
capped by the box `[0,q) × [0,p)`) stops representing the semigroup.  This is
why every statement in the file that uses `repPairs` as a semigroup indicator
carries the hypothesis `n < p·q`.

## 4. Sylvester gap counts

`#(frameGaps p q)` versus `(p−1)(q−1)/2`:

| `(p,q)` | computed gap count | `(p−1)(q−1)/2` |
|---|---|---|
| `(3,5)` | 4 | 4 |
| `(5,7)` | 12 | 12 |
| `(7,11)` | 30 | 30 |

Proved in general as `card_frameGaps`.

## 5. Counterexample hunt

* **Coprimality is necessary.** Searching non-coprime step pairs immediately
  produces `#repPairs 2 4 4 = 2`, so the frame geometry of `(2,4)` has the
  coefficient `2`.  This is proved (`card_repPairs_two_four`,
  `coeff_frameGeom_two_four`) and delimits the method exactly.
* **No counterexample to the `{−1,0,1}` claim** was found for any coprime pair
  scanned; consistent with the proof.

## 6. OEIS

The gap counts `4, 12, 30, …` for `(3,5), (5,7), (7,11)` are the values of
`(p−1)(q−1)/2`; the coefficient vectors of `Φ_{pq}` are the standard binary
cyclotomic coefficient tables.  No new sequence is claimed.
