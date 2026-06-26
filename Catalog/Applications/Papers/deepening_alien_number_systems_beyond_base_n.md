# Computational Evidence — Alien Number Systems (Mixed Radix)

All computations below were produced with `#eval` on the definitions
`MixedRadix.mval` and `MixedRadix.mdigits` (verified to elaborate in Lean).

## 1. Small-case calculations

### Factorial base (factoradic), bases `[2,3,4,5]`, capacity `5! = 120`
```
mdigits [2,3,4,5] 100  = [0, 2, 0, 4]     -- 0·1! + 2·2! + 0·3! + 4·4! = 4 + 96 = 100
mval    [2,3,4,5] [0,2,0,4] = 100         -- round trip ✓
[2,3,4,5].prod = 120 = 5!                 -- capacity telescopes
```

### Uniform base 10, bases `[10,10,10]`, capacity `10³ = 1000`
```
mdigits [10,10,10] 723 = [3, 2, 7]        -- least-significant first
mval    [10,10,10] [3,2,7] = 723          -- round trip ✓
```

These confirm the two master laws on concrete inputs:
* `mval bs (mdigits bs n) = n` for `n < bs.prod` (`mval_mdigits_of_lt`).
* each extracted digit is `< its base` (`mdigits_forall₂_lt`).

## 2. OEIS

* The factorial-base capacities `1, 2, 6, 24, 120, …` are the factorials
  (OEIS A000142); the digit-count for `n < (k+1)!` is `k`.
* The number of valid length-`k` factoradic strings is `(k+1)!` itself,
  matching the cardinality of `S_{k+1}` (Lehmer-code correspondence; see
  FUTURE_DIRECTIONS).

## 3. Counterexample hunt

* **Round-trip out of range.** For `n ≥ bs.prod` the reconstruction returns
  `n % bs.prod`, *not* `n` — e.g. `mval [2,3,4,5] (mdigits [2,3,4,5] 125) = 5`.
  This is exactly what `mval_mdigits` predicts (`125 % 120 = 5`), so it is not a
  counterexample to the in-range theorem but a confirmation of the modular law.
* **Zero bases.** With a base `0` in the list the capacity collapses (`prod = 0`)
  and `mval_mdigits` still holds as `n % 0 = n`; digit-validity (`mdigits_forall₂_lt`)
  correctly requires positivity of every base, so no false claim is made.

No counterexamples were found to any stated theorem; all are proved in Lean with
only the standard axioms `propext, Classical.choice, Quot.sound`.

## 4. Table — factoradic digits of `0..7` (bases `[2,3,4]`, capacity `24`)
```
0 -> [0,0,0]      4 -> [0,2,0]
1 -> [1,0,0]      5 -> [1,2,0]
2 -> [0,1,0]      6 -> [0,0,1]
3 -> [1,1,0]      7 -> [1,0,1]
```
Each column `i` ranges over `0..i` exactly once per block, the defining
property of the factorial number system.
