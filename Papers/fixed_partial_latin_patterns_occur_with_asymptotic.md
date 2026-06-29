# Computational Evidence — Fixed partial Latin patterns occur with probability ≈ n⁻ᵏ

This note records the small-case evidence that motivated the formal results in
`LatinPatternProbability.lean`.

## 1. Counts of Latin squares of small order

Let `N(n)` be the number of Latin squares of order `n` (OEIS **A002860**):

| n | N(n)                  |
|---|-----------------------|
| 1 | 1                     |
| 2 | 2                     |
| 3 | 12                    |
| 4 | 576                   |
| 5 | 161280                |
| 6 | 812851200             |
| 7 | 61479419904000        |

## 2. Single-cell marginal (k = 1)

Claim: for every `n ≥ 1` and every cell `(r,c)` and symbol `s`,
`#{L : L r c = s} = N(n)/n`, so `Pr[L r c = s] = 1/n` *exactly*.

Check (n = 3, N = 12, expect each fiber = 4): fixing `L 0 0 = 0` leaves the
reduced count `4` (there are 4 Latin squares of order 3 with a fixed top-left
entry). `4 · 3 = 12 = N(3)`. ✓

Check (n = 4, N = 576, expect 144): `576 / 4 = 144`. The number of Latin squares
of order 4 with a fixed entry is indeed `144`. ✓

Hence `Pr · n = 1` for all `n`; the conjectural sequence `Pr · n^1` is the
*constant* `1`. This is **stronger** than the asymptotic conjecture and is what
`prob_single_cell` / `prob_single_cell_mul` prove.

## 3. Single-row pattern of size k

Claim: a fixed single-row pattern with `k` distinct columns / `k` distinct
symbols has probability exactly `1 / (n)_k`, where `(n)_k = n(n-1)…(n-k+1)`
(`Nat.descFactorial n k`).

Reason: by relabelling symbols (a permutation of the alphabet) all admissible
`(n)_k` symbol patterns on the chosen columns are equinumerous and partition the
Latin squares, giving `#fiber = N(n)/(n)_k`.

Numeric check, two cells in one row (k = 2):

| n | (n)_2 = n(n-1) | 1/(n)_2 | n²·Pr = n²/(n)_2 = n/(n-1) |
|---|----------------|---------|----------------------------|
| 3 | 6              | 1/6     | 3/2  = 1.5000              |
| 4 | 12             | 1/12    | 4/3  ≈ 1.3333              |
| 5 | 20             | 1/20    | 5/4  = 1.2500             |
| 10| 90             | 1/90    | 10/9 ≈ 1.1111             |
| 100|9900           | 1/9900  | 100/99 ≈ 1.0101           |

The product `n^k · Pr = n^k/(n)_k → 1`, with the explicit correction
`(n)_k / n^k = ∏_{i<k}(1 - i/n)`. This limit is `singleRow_pattern_density`,
and the combination with `prob_rowfiber` is `rowpattern_prob_mul_tendsto`.

## 4. Counterexample hunt for the *general* conjecture

The general conjecture (arbitrary pattern, possibly across several rows and
columns) is NOT proven here; it is a known research-level statement. We found no
counterexample in the single-row family — there the exact `1/(n)_k` law makes the
limit `1` provable. For genuinely 2-dimensional patterns (e.g. an intercalate
`{(0,0,0),(0,1,1),(1,0,1),(1,1,0)}`) the alphabet-symmetry argument no longer
pins the count, which is exactly the boundary recorded in the Lab Notes.

## 5. OEIS pointers

- `N(n)` = number of Latin squares of order n: **A002860**.
- `(n)_k = Nat.descFactorial n k` falling factorial: rows of **A008279**.
