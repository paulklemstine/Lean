# Computational evidence: the UMW `(α,β)` divisor-cover wall

All formal claims are in `Catalog/Tropical/UMWDivisorWall.lean` (no `sorry`). The table
below comes from an exploratory brute-force search (Python, not checked in Lean); it is
context only.

## Small cases: least possible largest element `M` of a cover of `[n]` with `|S| = |T| = k`

`S, T ⊆ [1, M]`, every `1 ≤ i ≤ n` divides some positive difference `s − t`.

| n | k=1: min M (witness) | lcm(1..n) | k=2: min M (witness S; T) | lcm wall `⌈lcm^{1/4}⌉` |
|---|---|---|---|---|
| 2 | 3 ({3};{1}) | 2 | 3 ({1,3};{1,2}) | 2 |
| 3 | 7 | 6 | 4 ({1,4};{1,2}) | 2 |
| 4 | 13 | 12 | 5 ({1,5};{1,2}) | 2 |
| 5 | 61 | 60 | 6 ({4,6};{1,2}) | 3 |
| 6 | 61 | 60 | 7 ({5,7};{1,2}) | 3 |
| 7 | 421 | 420 | 8 ({6,8};{1,2}) | 5 |
| 8 | 841 | 840 | 9 ({7,9};{1,2}) | 6 |
| 9 | 2521 | 2520 | 19 ({8,19};{1,3}) | 8 |
| 10 | 2521 | 2520 | 21 ({17,21};{1,3}) | 8 |

Observations:
* `k = 1`: the minimum is always exactly `lcm(1..n) + 1`. This is now a **theorem**
  (`UMWWall.singleton_optimum`): for one-against-one covers the `lcm` wall is attained.
* `k = 2`: the minimum stays within a factor ≈ 2.6 of the `lcm` wall `lcm^{1/(k²)}` for
  `n ≤ 10`. At this size the lower-order terms dominate, so this says nothing about the
  asymptotic `(1/3,1/3)` question.

## Counterexample hunt for the wall

Every cover found (all `n ≤ 10`, `k ≤ 2`) satisfies `lcm(1..n) ≤ M^{k²}` and
`4^{⌊n/2⌋} ≤ (n+1)·M^{k²}`, which is what the theorems say. There can be no counterexample
because both inequalities are proved (`UMWWall.lcm_wall`, `UMWWall.counting_wall`).

## OEIS
`lcm(1..n)` = A003418 (1, 2, 6, 12, 60, 60, 420, 840, 2520, 2520, …). The `k = 1` column is
A003418 + 1.
