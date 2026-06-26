# Computational Evidence — Binary 2-binomial class sizes

All numbers below were produced by `#eval` of the Lean definitions in
`Catalog/Probability/BinaryTwoBinomial.lean` (`classSize n k i` = number of binary words of
length `n` with `k` ones and inversion number `i`).

## 1. Small-case tables (`classSize n k i`, i = 0,1,2,…)

| (n,k)  | distribution of class sizes over i           | row sum |
|--------|----------------------------------------------|---------|
| (4,2)  | 1, 1, 2, 1, 1                                | 6  = C(4,2) |
| (5,2)  | 1, 1, 2, 2, 2, 1, 1                          | 10 = C(5,2) |
| (6,2)  | 1, 1, 2, 2, 3, 2, 2, 1, 1                    | 15 = C(6,2) |
| (6,3)  | 1, 1, 2, 3, 3, 3, 3, 2, 1, 1                 | 20 = C(6,3) |
| (7,3)  | 1, 1, 2, 3, 4, 4, 5, 4, 4, 3, 2, 1, 1        | 35 = C(7,3) |

Each row is exactly the coefficient list of the Gaussian (q-)binomial coefficient
`[n choose k]_q`.  Observations on every row computed:

* **Palindromic** about the central index `k(n-k)/2`  → formalized as `classSize_symm`.
* **Unimodal**, with the (a) maximum attained at the central index → headline `central_max_*`.
* **Row sum = C(n,k)** → formalized as `total_eq_choose`.
* Endpoints `classSize n k 0 = classSize n k (k(n-k)) = 1` (unique extreme words
  `0…01…1` and `1…10…0`).

## 2. Sequence identification (OEIS)

* The **row sums** are the binomial coefficients — Pascal's triangle, OEIS **A007318**.
* The **rows themselves** are the coefficient triangle of the Gaussian binomial
  coefficients (`[n choose 2]_q` rows match the table above).
* Equivalent combinatorial reading: `classSize n k i` = number of integer partitions of `i`
  fitting in a `k × (n-k)` box (at most `k` parts, each `≤ n-k`).  This is the standard
  partition-in-a-box interpretation of `[n choose k]_q`.

## 3. Counterexample hunt (central = global maximum)

Tested `∀ i, classSize n k i ≤ classSize n k (k(n-k)/2)` exhaustively (via `native_decide`)
for all `(n,k)` with `n ≤ 8`.  **No counterexample found.**  Representative verified instances
are recorded as theorems `central_max_4_2`, `central_max_5_2`, `central_max_6_3`,
`central_max_7_3`.  The general statement (full unimodality of Gaussian binomials) is a known
deep theorem and is listed in `FUTURE_DIRECTIONS.md`.

## 4. Mean inversion number

For each table the weighted mean `Σ i·classSize / C(n,k)` equals exactly `k(n-k)/2`, the
central index (e.g. (6,3): mean `= 90/20 = 4.5 = 9/2`).  This is formalized denominator-free
as `inv_weighted_sum`: `2 · Σ i·classSize n k i = k(n-k) · C(n,k)`.
