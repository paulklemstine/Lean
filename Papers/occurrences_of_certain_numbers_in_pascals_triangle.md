# Computational evidence — occurrences of numbers in Pascal's triangle

Let `N(t) = #{(n,k) : 0 ≤ k ≤ n, C(n,k) = t}` be the multiplicity of `t`.

## 1. Verified-in-Lean data

These are the only computational claims in this project that are backed by a
`sorry`-free Lean artifact.  They are decided inside Lean over the exhaustive search
box `[0,t] × [0,t]`, whose exhaustiveness is itself a theorem
(`Singmaster.mem_occ_iff`).

| statement | Lean name | how |
|---|---|---|
| `N(2) = 1` | `Singmaster.mult_two` | `decide` |
| `N(3) = 2` | `Singmaster.mult_three` | `decide` |
| `N(4) = 2` | `Singmaster.mult_four` | `decide` |
| `N(5) = 2` | `Singmaster.mult_five` | `decide` |
| `N(6) = 3` | `Singmaster.mult_six` | `decide` |
| `N(10) = 4` | `Singmaster.mult_ten` | `decide` |
| `N(3003) ≥ 8` | `Singmaster.eight_le_mult_3003` | eight explicit witnesses |
| `N(3003) = 8` | `Singmaster.mult_3003` | bounded box search, `79 × 79` |
| `N(120) = N(210) = N(1540) = N(7140) = N(11628) = 6` | `Singmaster.mult_120`, … , `Singmaster.mult_11628` | bounded box searches, side `17 … 154` |
| `N(C(2m,m)) = 3` for `2 ≤ m ≤ 10`, i.e. for `6, 20, 70, 252, 924, 3432, 12870, 48620, 184756` | `Singmaster.mult_centralBinom_eq_three_of_le_ten` | sandwich theorem + bounded row search, `2m < n < N`, `N ≤ 609` |
| no `2 ≤ t < 705432` has `N(t) = 5` or `7` | `Singmaster.mult_ne_five_or_seven_of_lt` | parity criterion + the ten searches above |
| `N(C(2m,m)) = 3` for `2 ≤ m ≤ 20`, i.e. up to `C(40,20) = 137846528820` | `Singmaster.mult_centralBinom_eq_three_of_le_twenty` | triangular obstruction (column `k = 2`) + column collapse (`3 ≤ k ≤ m-1`) + row search `2m < n < (6t)^{1/3}` |
| no `2 ≤ t < 538257874440` has `N(t) = 5` or `7` | `Singmaster.mult_ne_five_or_seven_of_lt_large` | parity criterion + the nineteen searches above |
| every `2 ≤ t < 10^6` with `t ≠ 3003` has `N(t) ≤ 6` | `Singmaster.mult_le_six_of_lt_million` | refined reflection decomposition + exhaustive comparison of the `320` positions with column `≥ 3` and value `< 10^6` |
| `3003` is the **only** `t < 10^6` with `N(t) = 8`; `N(t) ≤ 8` on `[2,10^6)` | `Singmaster.mult_eq_eight_iff_of_lt_million`, `Singmaster.mult_le_eight_of_lt_million` | as above, plus `Singmaster.mult_3003` |
| `N(24310) = 6` | `Singmaster.mult_24310` | upper bound above + the occurrences `C(221,2)`, `C(17,8)` |

Also verified by evaluation inside Lean (`#eval`, using the definitions of this
project): the first two members of the Fibonacci family are

```
(famRow 0, famCol 0, famVal 0) = (15, 5, 3003)          and  C(14,6) = 3003
(famRow 1, famCol 1, famVal 1) = (104, 39, 61218182743304701891431482520)
                                                        and  C(103,40) = famVal 1
```

## 2. Exploratory search (NOT machine-verified)

An ad-hoc enumeration of all `C(n,k) ≤ 200000` gives the following distribution of
`N(t)` for `2 ≤ t ≤ 200000`.  **This table is exploratory only; it is not backed by a
Lean proof.**

| `N(t)` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| count | 1 | 199180 | 9 | 802 | **0** | 6 | **0** | 1 |

* the unique `t` with `N(t) = 1` is `t = 2`;
* the `t ≤ 200000` with `N(t) = 3` are exactly `6, 20, 70, 252, 924, 3432, 12870,
  48620, 184756` — these are precisely the central binomial coefficients `C(2m,m)`;
* the `t ≤ 200000` with `N(t) = 4` begin `10, 15, 21, 28, 35, 36, 45, 55, 56, 66, 78,
  84, 91, 105, 126` — mostly triangular numbers `C(n,2)`;
* the `t ≤ 200000` with `N(t) ≥ 6` are `120, 210, 1540, 3003, 7140, 11628, 24310`;
* `3003` is the unique `t ≤ 200000` with `N(t) = 8`;
* **no `t ≤ 200000` has `N(t) = 5` or `N(t) = 7`** — the phenomenon quoted in the
  problem statement.  This item is no longer merely exploratory: it is now a theorem
  over the much larger range `2 ≤ t < 538257874440`
  (`Singmaster.mult_ne_five_or_seven_of_lt_large`), obtained *without* enumerating all
  `t`;
* the observations "`3003` is the unique `t` of multiplicity `8`" and "`N(t) ≤ 8`" are
  likewise now theorems on the range `2 ≤ t < 10^6`
  (`Singmaster.mult_eq_eight_iff_of_lt_million`, `Singmaster.mult_le_eight_of_lt_million`),
  which strictly contains the exploratory range of the table.

## 3. Related OEIS sequences

* A003016 — number of times `n` appears in Pascal's triangle (the function `N` above);
  begins `1, 2, 1, 2, 2, 2, 3, 2, 2, 2, 4, 2, ...` (indexed from `n = 0`).
* A003015 — numbers occurring at least 5 times: `120, 210, 1540, 3003, 7140, 11628,
  24310, 61218182743304701891431482520, ...`; the last entry is `C(104,39)`, i.e.
  `famVal 1` of this project.
* A090162 / A098565 — the Fibonacci-product rows `15, 104, 714, 4895, ...`
  (`famRow i = F(2i+4) F(2i+5)`) and the associated columns.

## 4. Counterexample hunt for the proved upper bound

The theorem `Singmaster.mult_le_two_mul_log` asserts `N(t) ≤ 2 log₂ t` for `t ≥ 2`.
Over the exploratory range above the extreme case is `t = 3003`, where
`N(t) = 8` and `2⌊log₂ 3003⌋ = 22`; no violation was found, as expected.
The bound is far from tight, which is exactly what makes Singmaster's conjecture
(`N` bounded) plausible.

## 5. Where the two "six-fold" mechanisms come from

Among `t ≤ 200000` with `N(t) ≥ 6` only `3003` belongs to the Fibonacci family; the
others (`120, 210, 1540, 7140, 11628, 24310`) come from sporadic coincidences of the
shape `C(n,2) = C(m,3)`, `C(n,2) = C(m,4)`, ….  Those equations define curves of
genus `≥ 1`, so each yields only finitely many solutions, whereas the equation
`C(n,k) = C(n-1,k+1)` is a disguised **Pell** equation and yields the infinite
Fibonacci family formalised in `Catalog/Combinatorics/SingmasterFibonacci.lean`.
This is the structural reason why the infinitude proof must go through Fibonacci
numbers rather than through the numerically smaller examples.

## 6. Cost of the certified searches

The searches are run by the Lean kernel, so their cost is part of the proof.  Two
tricks make them feasible.

1. **Quadratic row cut-off.**  An interior entry satisfies `C(n,2) ≤ C(n,k)`, so the
   search box for `t` has side `≈ √(2t)` rather than `t`: for `t = 3003` the box is
   `79 × 79` instead of `3003 × 3003`, and for `t = 184756` it is `609 × 609` instead of
   `184756 × 184756`.
2. **Descending factorials.**  `C(n,k) = t` is tested as `n^{\underline{k}} = k!·t`
   (`Singmaster.choose_eq_iff_descFactorial`): `k` multiplications, instead of the
   `≈ C(n,k)` additions that the defining recursion of `Nat.choose` would need.  Without
   this the `m = 10` search would require of the order of `10^{178}` kernel additions.

3. **The triangular obstruction** (`Singmaster.choose_two_ne_of_not_sq`).  `C(n,2) = t`
   forces `8t + 1` to be a perfect square, so exhibiting `s` with
   `s² < 8t + 1 < (s+1)²` deletes the column `k = 2` — the column that forced the row
   window `√(2t)`.  What remains satisfies `C(n,3) ≤ t`, so the window shrinks to
   `(6t)^{1/3}`: for `m = 20` from `524248` rows to `9347`.
4. **The column collapse** (`Singmaster.column_lt_of_choose_eq_centralBinom`).  A
   repetition of `C(2m,m)` in a lower row has folded column `< m`, so the column range
   is `[3, m-1]` (`17` values for `m = 20`) instead of `[2, n/2]` (`262124` values).
   Together, 3 and 4 shrink the `m = 20` box by more than nine orders of magnitude.

Measured wall-clock time: `SingmasterCentralBinomial.lean` (ten searches, largest of
side `609`) about three minutes; `SingmasterExactCounts.lean` (six searches, largest box
`154 × 154`) about three minutes; `SingmasterCentralBinomialExtended.lean` (ten searches
`m = 11 … 20`, largest `9347 × 17`) about three minutes;
`SingmasterMaxBelowMillion.lean` (one search comparing all `320²` pairs of positions
with column `≥ 3` and value `< 10^6`) about one minute.  Large searches are run with
`decide +kernel` — the Boolean evaluation is checked by the Lean kernel, and
`native_decide` is *not* used anywhere.  Rows are split with
`Singmaster.forall_Ico_glue` when a single window would exhaust the stack.  The value
`t = 24310`, previously out of reach because its `interiorOcc` box has side `221`, is
now certified (`Singmaster.mult_24310`) by the new upper bound instead of a box search.
