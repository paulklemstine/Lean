# Computational evidence

All numbers below were obtained by exhaustive enumeration over **all** families of subsets
of `[n]` (i.e. `2^(2^n)` families) for `n ≤ 4`, and by direct binomial computation
otherwise.  The Lean statements that these experiments motivated are all fully proved in
`Catalog/Combinatorics/B3FreeKSperner.lean`, `B3FreePosetBracket.lean`,
`B3FreeButterfly.lean` and `B3FreeTallButterfly.lean`.

## 1. Erdős' `k`-Sperner theorem (the main new theorem)

Maximum size of a family of subsets of `[n]` containing **no chain of `k + 1` sets**,
compared with the sum of the `k` largest binomial coefficients in row `n`:

| `n` | `k` | max size (brute force) | Σ of `k` largest `C(n,i)` |
|----|----|----|----|
| 3 | 1 | 3 | 3 |
| 3 | 2 | 6 | 6 |
| 3 | 3 | 7 | 7 |
| 3 | 4 | 8 | 8 |
| 4 | 1 | 6 | 6 |
| 4 | 2 | 10 | 10 |
| 4 | 3 | 14 | 14 |
| 4 | 4 | 15 | 15 |

Perfect agreement, which is exactly `card_le_central_layers_of_not_hasChain` together with
the layer construction — formalized as `La_fin_eq` (the exact chain-poset extremal number).

## 2. How much the new upper bound gains

Catalog bound `La(n, B_d) ≤ (2^d − 1)·C(n, ⌊n/2⌋)` versus the new bound
`La(n, B_d) ≤ Σ` of the `2^d − 1` largest binomial coefficients, for `d = 3`
(so `k = 7`):

| `n` | `7·C(n,⌊n/2⌋)` | Σ of 7 largest `C(n,i)` | ratio |
|----|----|----|----|
| 8 | 490 | 254 | 0.518 |
| 10 | 1764 | 1002 | 0.568 |
| 12 | 6468 | 3938 | 0.609 |
| 20 | 1293292 | 927656 | 0.717 |

The `n = 10` instance is formalized as `La_boolLat3_le_of_card_ten : La(10, B_3) ≤ 1002`,
and the general strict inequality as `sum_window_lt_mul` / `La_boolLat_window_lt_mul`.

## 3. Weak `B_2`-free (diamond) families — the layer construction looks optimal

Exhaustive search over all families in `[n]`:

| `n` | `La(n, B_2)` (brute force) | 2-layer bound | 3-layer bound (our upper bound) |
|----|----|----|----|
| 3 | 6 | 6 | 7 |
| 4 | 10 | 10 | 14 |

An extremal family found for `n = 4` is the two middle layers (levels 1 and 2).  This is
the small-case evidence for the (open) diamond conjecture recorded in
`FUTURE_DIRECTIONS.md`.

## 4. The butterfly obstruction

Two consecutive layers `{|A| = a}` ∪ `{|A| = a+1}`: an element of the upper layer that
contains two distinct sets of the lower layer must equal their union, so it is *unique*.
Enumerating `[4]` with `a = 1` confirms: no four distinct sets `A₁, A₂ ⊂ B₁, B₂` exist in
two consecutive layers, while for three consecutive layers (`a = 1`, levels 1–3) there are
many (e.g. `{1}, {2} ⊂ {1,2,3}, {1,2,4}`).

This is `layers_weakFree_of_hasButterfly` and, in its general form,
`layers_weakFree_of_hasTallButterfly`.

## 5. Small-poset checks

* `Fintype.card Butterfly = 4`, and the butterfly poset has no 3-chain
  (`butterfly_no_three_chain`) — verified by exhaustive check over the 4-element poset and
  formalized by `decide`.
* The diamond `B_2` contains **no** butterfly (`not_hasButterfly_boolLat2`, checked over all
  `4^4 = 256` quadruples), whereas `B_3` does (`hasButterfly_boolLat3`).

## Addendum: antichain posets (weak vs strong)

Small-case values used to guide the theorems in
`Catalog/Combinatorics/B3FreeWeakStrongGap.lean` and
`Catalog/Combinatorics/B3FreeAntichainThree.lean` (all subsequently **proved for all n**,
so these rows are corroboration rather than evidence):

| n | La(n, A₂) | La*(n, A₂) = n+1 | La*(n, A₃) = 2n | Σ_i min(2, C(n,i)) |
|---|-----------|------------------|-----------------|---------------------|
| 1 | 1 | 2 | 2 | 2 |
| 2 | 1 | 3 | 4 | 4 |
| 3 | 1 | 4 | 6 | 6 |
| 4 | 1 | 5 | 8 | 8 |

For `A₂` the extremal strong-free families are exactly the maximal chains; for `A₃` the
extremal families are unions of two chains, e.g. for `n = 3` the six sets
`∅ ⊂ {1} ⊂ {1,2} ⊂ {1,2,3}` together with `{2,3} ⊃ {3}`.  The layer bound
`Σ_i min(m−1, C(n,i))` agrees with the Greene–Kleitman value `Σ_{i<m−1}(n+1−2i)` for
`m = 2, 3` at every `n`, and first differs at `m = 4, n = 4`
(`Σ_i min(3, C(4,i)) = 1+3+3+3+1 = 11` versus `5 + 3 + 1 = 9`), which is why the general
case is stated as a conjecture rather than proved by layer counting.
