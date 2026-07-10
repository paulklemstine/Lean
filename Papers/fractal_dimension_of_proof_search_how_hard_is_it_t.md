# Computational Evidence — Proof-Search Fractal Dimension

We model a self-similar proof-search space as a complete `b`-ary tree in which
exactly `s` of the `b` branches at each node extend to a full proof.

## 1. Small-case calculations

Successful paths of depth `n` = `s^n`; candidate paths = `b^n`.

| b | s | n | succ = s^n | total = b^n | D = log s / log b | total^D |
|---|---|---|-----------|-------------|-------------------|---------|
| 2 | 1 | 5 | 1         | 32          | 0.0000            | 1       |
| 2 | 2 | 5 | 32        | 32          | 1.0000            | 32      |
| 3 | 2 | 4 | 16        | 81          | 0.6309            | 16.000  |
| 8 | 2 | 3 | 8         | 512         | 0.3333            | 8.000   |
| 10| 3 | 6 | 729       | 1000000     | 0.4771            | 729.00  |

The last column confirms the **bridge identity** `succ = total^D` numerically:
`total^D = (b^n)^(log s / log b) = s^n` in every row.

## 2. Density / codimension law

The success density `(s/b)^n = total^(D-1)`.  For `b = 3, s = 2`:
`(2/3)^n` versus `(3^n)^(log2/log3 − 1)` agree (both `0.667, 0.444, 0.296, …`),
so the codimension `1 − D ≈ 0.369` is the exponential pruning rate.

## 3. Boundary / counterexample hunt

* `s = b` gives `D = 1` **exactly** and only then (checked for all `2 ≤ b ≤ 20`):
  no `s < b` produces `D = 1`.  This refutes the naive reading of the informal
  conjecture that generic theorems sit at `D = 1`; `D = 1` is a sharp threshold.
* No self-similar *subset* of the boundary can have `D > 1`: since `s ≤ b`,
  `D = log s / log b ≤ 1`.  The informal "`D > 1` for hard theorems" is therefore
  false under this (subset) normalisation; the correct hardness invariant is the
  codimension `1 − D` (slow pruning ⇔ small codimension ⇔ expensive search).

## 4. Entropy / Fekete average

`L(n) = log(s^n) = n log s`, so `L(n)/n = log s` for all `n ≥ 1` — the per-depth
growth is already constant, i.e. Fekete's average is attained exactly.  For
`s = 2`: `L(n)/n = 0.6931…` for every `n`, matching `searchEntropy_tendsto`.

All identities above are proved in
`Catalog/Bridges/ProofSearchFractalDimension.lean` and
`Catalog/Bridges/ProofSearchEntropyFekete.lean`.
