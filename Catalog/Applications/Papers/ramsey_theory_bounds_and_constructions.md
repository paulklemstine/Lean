# Computational Evidence — Probabilistic lower bounds for diagonal Ramsey numbers

All numbers below were produced with `#eval` in Lean (kernel-evaluated `Nat`
arithmetic), so they are exact, not floating-point estimates.

## 1. The counting threshold

For the two-colour diagonal Ramsey number `R(k,k)`, the Erdős first-moment
argument gives `R(k,k) > n` whenever `2·C(n,k) < 2^{C(k,2)}`.  Using the crude
slack `C(n,k) ≤ n^k` weakens the test to `2·n^k < 2^{C(k,2)}`.

For each `k`, let
* `best(k)`   = largest `n` with `2·C(n,k) < 2^{C(k,2)}`  (sharp counting bound),
* `bestpow(k)`= largest `n` with `2·n^k   < 2^{C(k,2)}`  (crude `n^k` bound).

| k  | best(k) = R(k,k) > | bestpow(k) = R(k,k) > |
|----|--------------------|------------------------|
| 2  | 1                  | 0                      |
| 3  | 3                  | 1                      |
| 4  | 6                  | 2                      |
| 5  | 11                 | 3                      |
| 6  | 17                 | 5                      |
| 7  | 27                 | 7                      |
| 8  | 42                 | 10                     |
| 9  | 65                 | 14                     |
| 10 | 100                | 21                     |
| 11 | 152                | 30                     |
| 12 | 231                | 42                     |
| 13 | 349                | 60                     |

Both columns grow exponentially (`best(k) ≈ 2^{k/2}·k!^{-1/?}`,
`bestpow(k) ≈ 2^{k/2}`).  The gap between the two columns is exactly the `k!`
factor discarded by `C(n,k) ≤ n^k`.

The formal `ramsey_ten_lower : ¬ Arrows 16 10 10` (i.e. `R(10,10) > 16`) is a
*conservative* instance of the crude `bestpow(10) = 21` row, chosen so the
exponent arithmetic `2·16^10 = 2^41 < 2^45 = 2^{C(10,2)}` is a clean power-of-two
comparison.

## 2. The even-diagonal family

`ramsey_lower_even` instantiates `k = 2m`, `n = 2^{m-1}`.  The table confirms the
side conditions and that `2^{m-1}` stays below the (larger) sharp threshold:

| m | k = 2m | n = 2^{m-1} (our bound) | best(2m) (sharp) |
|---|--------|--------------------------|-------------------|
| 4 | 8      | 8                        | 42                |
| 5 | 10     | 16                       | 100               |
| 6 | 12     | 32                       | 231               |
| 7 | 14     | 64                       | 527               |
| 8 | 16     | 128                      | 1186              |

So `2^{m-1} ≤ best(2m)` throughout (our crude family bound is valid and
conservative), and `2m ≤ 2^{m-1}` holds from `m = 4` on (`8 ≤ 8`, `10 ≤ 16`, …),
matching the `m ≥ 4` hypothesis of `ramsey_lower_even`.

## 3. Counterexample hunt (Extra Adversarial Mandate)

* **`m = 3` boundary.**  `2m = 6` but `2^{m-1} = 4`, so the side condition
  `2m ≤ n` fails (`6 ≤ 4` is false).  Hence the lower bound is *not* claimed at
  `m = 3`; the `m ≥ 4` hypothesis is the exact boundary, not a convenience.
* **Small-`k` weakness.**  At `k = 3` the counting test only certifies
  `R(3,3) > 3`, far from the true `R(3,3) = 6` (proved structurally elsewhere in
  the catalog).  No counterexample to the *theorem* exists — the method is simply
  asymptotic, confirming the "two laws" analysis in the Lab Notes.

## 4. Known exact values (sanity anchor)

The exact diagonal values currently known are `R(1,1)=1`, `R(2,2)=2`,
`R(3,3)=6`, `R(4,4)=18` (and no further `R(k,k)` is known exactly).  Every row of
the `best(k)` column above is strictly below the corresponding known/true value
where comparison is possible (`best(3)=3 < 6`, `best(4)=6 < 18`), as a lower
bound must be.
