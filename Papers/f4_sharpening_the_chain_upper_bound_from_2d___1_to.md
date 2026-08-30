# Computational Evidence — F4: sharpening the chain bound for `La(n, B_d)`

All formal claims live in `Catalog/Algebra/BooleanLatticeChainBound.lean` and
`Catalog/Algebra/BooleanLatticeLevelSharpening.lean`. The tables below are *exploratory*
(computed with an ad-hoc Python enumeration) unless explicitly marked **[Lean-verified]**;
they were used to pick which statements to formalise, not as substitutes for proof.

## 1. Exact small cases (brute force over all families, unverified exploration)

Here `La(n, B_d)` is the maximum size of a family of subsets of `[n]` containing no weak
(non-induced) copy of the `d`-dimensional Boolean lattice, and `C = C(n, ⌊n/2⌋)`.

| n | 2^n | C | 2^n / C | La(n,B_1) | La(n,B_2) | La(n,B_3) |
|---|-----|---|---------|-----------|-----------|-----------|
| 0 | 1   | 1 | 1.000   | 1 | 1 | 1 |
| 1 | 2   | 1 | 2.000   | 1 | 2 | 2 |
| 2 | 4   | 2 | 2.000   | 2 | 3 | 4 |
| 3 | 8   | 3 | 2.667   | 3 | 6 | 7 |

Observations used later:

* `La(n, B_1) = C(n, ⌊n/2⌋)` in every computed case — this is Sperner's theorem, and it is the
  statement `La_one` **[Lean-verified]**.
* For `n ≤ 3` the values of `La(n, B_3)` are far below the conjectured `4C` (e.g. `7 ≤ 12` at
  `n = 3`), consistent with the conjecture; no counterexample appeared.
* No family found in this range beats `4 C(n,⌊n/2⌋)`, i.e. the counterexample hunt for the
  falsifiable half of the conjecture came up empty in the computable range.

## 2. Where the trivial bound already proves the conjecture for `d = 3`

`La(n, B_3) ≤ 2^n`, so the conjectured `La(n,B_3) ≤ 4 C(n,⌊n/2⌋)` is automatic whenever
`2^n ≤ 4 C(n, ⌊n/2⌋)`:

| n | 2^n | C(n,⌊n/2⌋) | 2^n / C |
|---|-----|------------|---------|
| 0–2 | 1,2,4 | 1,1,2 | 1.00, 2.00, 2.00 |
| 3,4 | 8,16 | 3,6 | 2.67, 2.67 |
| 5,6 | 32,64 | 10,20 | 3.20, 3.20 |
| 7,8 | 128,256 | 35,70 | 3.657, 3.657 |
| 9,10 | 512,1024 | 126,252 | **4.063**, 4.063 |
| 11,12 | 2048,4096 | 462,924 | 4.433, 4.433 |

The ratio first exceeds `4` at `n = 9`. Hence the cut-off `n ≤ 8` in the theorem
`La_three_le_four_of_le_eight` **[Lean-verified]**; the ratio grows like `√(πn/2)`, so no
counting-only argument can settle the conjecture for large `n`.

## 3. Lower bound from the three middle levels vs. the sharpened upper bound

For `n = 2m` the three middle levels form a `B_3`-free family, and the Lubell-split argument
gives an upper bound. Both are **[Lean-verified]**
(`three_levels_lower_bound`, `La_le_sharpened_even`; the odd analogue is `La_le_sharpened_odd`), and both are stated in the exact form
`(m+1)·La(2m,B_3) ≤ …` so that no real division is needed:

| m (n = 2m) | lower `(3m+1)/(m+1)` | sharpened upper `(7m+1)/(m+1)` | chain bound |
|---|---|---|---|
| 1 | 2.000 | 4.000 | 7 |
| 2 | 2.333 | 5.000 | 7 |
| 3 | 2.500 | 5.500 | 7 |
| 5 | 2.667 | 6.000 | 7 |
| 10 | 2.818 | 6.455 | 7 |
| 100 | 2.980 | 6.941 | 7 |

So the true constant for `d = 3` lies in `[3 − o(1), 7 − o(1)]`, and the conjectured value `4`
sits strictly inside that window: the level construction does **not** falsify it, and the
sharpened chain bound does not yet reach it.

## 4. What the data rules out

* A construction from complete levels cannot beat `d` levels: `d+1` complete levels always
  contain a `B_d` copy (**[Lean-verified]** `hasBdCopy_of_complete_levels`). So within the
  class of level unions the conjecture holds with `c = 0` (**[Lean-verified]**
  `card_le_of_bdFree_levelUnion`). Any counterexample to `La(n,B_3) ≤ 4C` must therefore be
  *non-levelled*.
* A single-chain argument cannot go below `2^d − 1` asymptotically: a chain of `2^d − 1` sets
  is `B_d`-free, so the "no long chain" information is exactly saturated. Improvements must
  use configurations such as the parallel-chain criterion
  (**[Lean-verified]** `hasBdCopy_succ_of_parallel_chains`).
