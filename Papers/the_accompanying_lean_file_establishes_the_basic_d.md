# Computational evidence — strongly complete sets (cycle 2)

All numbers below were produced with `#eval` inside Lean 4 (Nat arithmetic, exact), using a
small dynamic-programming routine `reach l bound` that lists the subset sums of a finite
list `l` bounded by `bound`.  They motivated the theorems in
`Catalog/Combinatorics/StronglyCompleteBlocks.lean` and
`Catalog/Combinatorics/StronglyCompleteResidues.lean`.  They are *evidence*, not proof: the
corresponding statements are proved formally in those files.

## 1. How many multiples of 3 live in a dyadic block?

`#(a ∈ (2^k, 2^(k+1)] : 3 ∣ a)` for `k = 0 … 8`:

| k | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| count | 0 | 1 | 1 | 3 | 5 | 11 | 21 | 43 | 85 |

The count first reaches `6` at `k = 5` (it is `5` at `k = 4`), so the hypothesis `k ≥ 5` in
`six_elements_in_dyadicBlock` is sharp for this witness.  This is the computational seed of
`six_per_block_insufficient`: a set can have six (indeed, arbitrarily many) elements in every
large dyadic block and still fail to be complete.

## 2. Subset sums of the multiples of 3

`reach {3,6,9,…} 60 = [0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,…]` — only multiples of `3`,
as the formal proof `multiplesOfThree_not_complete` records.

## 3. The parity counterexample `threeAndUnits = 3ℕ ∪ {1,2}`

* Non-representable `n ≤ 40` using all of `threeAndUnits`: **none** (so it is complete;
  formalized threshold `N = 3`).
* Non-representable `n ≤ 40` after deleting `{1,2}`:
  `1,2,4,5,7,8,10,11,13,14,16,17,19,20,22,23,25,26,28,29,31,32,34,35,37,38,40`
  — exactly the non-multiples of `3`.
* `threeAndUnits` contains the infinitely many odd numbers `3, 9, 15, 21, …`.

Hence "complete + infinitely many odd elements ⟹ strongly complete" is false; the
obstruction after finite deletion is a congruence mod `3`, not mod `2`
(`complete_infinite_odd_not_stronglyComplete`).

## 4. Two classical sanity checks

* Powers of two `{1,2,4,…,64}`: every `n ≤ 64` is a subset sum; after deleting the single
  element `1`, the unreachable numbers are exactly the odd ones `1,3,5,7,…`.
* `evenWithOne` (the catalog's earlier counterexample): every `n ≤ 30` is a subset sum;
  after deleting `1`, the unreachable numbers are `1,3,5,7,…`.

Both examples are complete but not strongly complete, matching the earlier cycle.

## 5. Why the ordered-block criterion uses *pairs* of dyadic ranges

The criterion `stronglyComplete_of_orderedBlocks` requires `2 * lo k ≤ hi k + 1`.  For a
single dyadic range `lo = 2^k + 1`, `hi = 2^(k+1)` the test
`2 * (2^k + 1) ≤ 2^(k+1) + 1` evaluates to `false` for every `k = 0 … 5` (it misses by
exactly `1`), whereas for a *doubled* range `hi = 2^(k+2)` it evaluates to `true` for every
`k = 0 … 5`.  This is why `stronglyComplete_of_full_dyadicBlocks` groups the dyadic ranges in
consecutive pairs.

## 6. OEIS

No new integer sequence is introduced by this cycle; the counting sequence in §1 is the
count of multiples of `3` in dyadic ranges, i.e. `⌊2^(k+1)/3⌋ - ⌊2^k/3⌋`
(`0,1,1,3,5,11,21,43,85`, the Jacobsthal numbers `A001045` shifted), which we use only as a
size estimate and do not rely on formally.
