# Computational evidence for the `q`-analogue of Kummer's theorem

All computations below were performed inside Lean with `#eval` on the very definitions that the
formal development uses (`QKummer.qNat`, `QKummer.qFact`, `QKummer.qBinom`, `padicValNat`), so the
numbers are produced by the same objects that the theorems talk about.  Everything that is
*asserted* in the Lean files is proved; the tables here are exploratory data that guided the
statements.

## 1. Small cases of the `q`-Pascal triangle (`q = 2`)

```
n = 0 : 1
n = 1 : 1  1
n = 2 : 1  3   1
n = 3 : 1  7   7    1
n = 4 : 1 15  35   15    1
n = 5 : 1 31 155  155   31    1
n = 6 : 1 63 651 1395  651   63   1
n = 7 : 1 127 2667 11811 11811 2667 127 1
```

The row `n = 6` contains the falsifiable test case of the mission:
`binom(6,3)_2 = 1395 = 3² · 5 · 31`.

## 2. The conjectured formula

For a prime `ℓ ∤ q` let `d = ord_ℓ(q)`, `e = v_ℓ([d]_q)`, and put
`N = ⌊n/d⌋`, `A = ⌊k/d⌋`, `B = ⌊(n-k)/d⌋`, `c = N − A − B ∈ {0,1}` (the base-`d` carry).  The
conjecture tested was

```
v_ℓ(binom(n,k)_q)  =  e·c  +  v_ℓ(binom(N, A))  +  c · v_ℓ(B+1).
```

## 3. Counterexample hunt

Exhaustive test over
`ℓ ∈ {3,5,7,11,13}`, `q ∈ {2,…,10}` with `ℓ ∤ q`, `0 ≤ k ≤ n ≤ 11`
(≈ 3 500 instances): **no counterexample**.  The predicted and actual valuations agreed in every
case.

Exhaustive test over `ℓ = 2`, `q ∈ {3,5,7,9}`, `0 ≤ k ≤ n ≤ 5`: **six counterexamples**, all with
`q ≡ 3 (mod 4)`:

| q | ℓ | n | k | actual `v_2` | naive prediction |
|---|---|---|---|--------------|------------------|
| 3 | 2 | 2 | 1 | 2 | 1 |
| 3 | 2 | 4 | 1 | 3 | 2 |
| 3 | 2 | 4 | 3 | 3 | 2 |
| 7 | 2 | 2 | 1 | 3 | 1 |
| 7 | 2 | 4 | 1 | 4 | 2 |
| 7 | 2 | 4 | 3 | 4 | 2 |

No failure occurred for `q ≡ 1 (mod 4)`.  This is exactly the failure of lifting-the-exponent at
`p = 2`, and it led to the corrected statement: at `ℓ = 2` the period `d` must be the order of `q`
modulo `4` (so `d = 2` when `q ≡ 3 (mod 4)`), with offset `e = v_2(q+1)`.  Both the failure
(`QKummer.not_isQRegular_two_of_orderOf`) and the repair
(`QKummer.isQRegular_two_of_one_mod_four`, `QKummer.isQRegular_two_of_three_mod_four`) are proved
in `Catalog/NumberTheory/QKummer/TwoAdic.lean`.

## 4. The designated test point in detail

`q = 2`, `n = 6`, `k = 3`, `binom(6,3)_2 = 1395 = 3² · 5 · 31`.

* `ℓ = 5`: `d = ord_5(2) = 4`, `e = v_5([4]_2) = v_5(15) = 1`.  `N = 1`, `A = B = 0`, so `c = 1`.
  Prediction `1·1 + v_5(binom(1,0)) + 1·v_5(1) = 1`.  Actual `v_5(1395) = 1`. ✔
* `ℓ = 3`: `d = ord_3(2) = 2`, `e = v_3([2]_2) = v_3(3) = 1`.  `N = 3`, `A = B = 1`, so `c = 1`.
  Prediction `1·1 + v_3(binom(3,1)) + 1·v_3(2) = 1 + 1 + 0 = 2`.  Actual `v_3(1395) = 2`. ✔
* `ℓ = 31`: `d = ord_31(2) = 5`, `e = v_31([5]_2) = v_31(31) = 1`.  `N = 1`, `A = B = 0`, `c = 1`,
  prediction `1`.  Actual `v_31(1395) = 1`. ✔

Both `ℓ = 5` and `ℓ = 3` are proved in `Catalog/NumberTheory/QKummer/Examples.lean`, *derived from
the general theorem* and cross-checked against the direct factorisation.

## 5. Sequences

The Gaussian binomial rows above are the classical `q = 2` Galois numbers / Gaussian binomial
tables (e.g. `1, 3, 7, 15, 31, 63` are the Mersenne numbers `2^n − 1 = [n]_2`, and
`1, 7, 35, 155, 651` is the `k = 2` column).  No new sequence was needed for the conjecture, so no
OEIS identification is claimed here.

## 6. Row counts (second cycle)

Let `cnt(q,ℓ,n) = #{k ≤ n : ℓ ∤ binom(n,k)_q}` and
`pred(ℓ,d,n) = (n % d + 1) · ∏ (digit + 1)` over the base-`ℓ` digits of `⌊n/d⌋`.  Evaluated
inside Lean for `n = 0, …, 12`:

| `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `cnt(2,5,n)`, `d = 4` | 1 | 2 | 3 | 4 | 2 | 4 | 6 | 8 | 3 | 6 | 9 | 12 | 4 |
| `cnt(2,3,n)`, `d = 2` | 1 | 2 | 2 | 4 | 3 | 6 | 2 | 4 | 4 | 8 | 6 | 12 | 3 |
| `cnt(3,5,n)`, `d = 4` | 1 | 2 | 3 | 4 | 2 | 4 | 6 | 8 | 3 | 6 | 9 | 12 | 4 |

In every case `cnt = pred`.  The initial guess `d − n % d` for the residual factor is refuted
already at `n = 1`, `ℓ = 5`, `q = 2` (`d = 4`): the guess gives `3`, the truth is `2 = n % d + 1`.
The identity `cnt = pred` is now a theorem
(`QKummer.card_row_not_dvd_qBinom_digits`, `Catalog/NumberTheory/QKummer/RowCount.lean`), so the
table is a check rather than evidence.

## 7. The extremal family (second cycle)

`v_ℓ(binom(d·ℓ^s, d+1)_q) = e + s` was tested before being proved:

| `q` | `ℓ` | `d` | `e` | `s` | `n` | `k` | `v_ℓ(binom(n,k)_q)` |
|---|---|---|---|---|---|---|---|
| 2 | 5 | 4 | 1 | 1 | 20 | 5 | 2 |
| 2 | 3 | 2 | 1 | 1 | 6 | 3 | 2 |

(`binom(20,5)_2 = 126769425631762997934675` is divisible by `25` and not by `125`;
`binom(6,3)_2 = 1395` is divisible by `9` and not by `27`.)  Both are instances of
`QKummer.padicValNat_qBinom_sharp`.

## 8. Full rows (third cycle)

A row `n` is *full* when every entry `binom(n,k)_q`, `k ≤ n`, is prime to `ℓ`.  Enumerating the
full rows by direct evaluation of the Gaussian binomial coefficients:

| `q` | `ℓ` | `d = ord_ℓ(q)` | full rows `n < 45` |
|---|---|---|---|
| 2 | 5 | 4 | 0, 1, 2, 3, 7, 11, 15, 19, 39 |
| 2 | 3 | 2 | 0, 1, 3, 5, 11, 17 |

Both lists match the predicate "`n + 1 ≤ d` or `n + 1 = d·c·ℓ^t` with `1 ≤ c ≤ ℓ`":
for `q = 2`, `ℓ = 5` the admissible values of `n + 1` are `1,2,3,4` and `4c` (`c ≤ 5`), i.e.
`4,8,12,16,20`, then `20c`, i.e. `20,40,60,…`; for `q = 2`, `ℓ = 3` they are `1,2` and `2c`
(`c ≤ 3`), i.e. `2,4,6`, then `6,12,18,…`.  The identity is now a theorem
(`QKummer.not_dvd_qBinom_row_iff_orderOf`, `Catalog/NumberTheory/QKummer/FullRows.lean`).

The row `n = 7` at `q = 2`, `ℓ = 5` is the counterexample that refutes the previous cycle's
"row maximum decouples" conjecture: the row is full, so its maximal valuation is `0`, whereas the
conjectured formula predicts `e = v_5([4]_2) = v_5(15) = 1`
(`QKummer.row_max_decoupling_fails`).
