# Computational evidence: subspace counts and the Galois `p`-binomial prediction

Target 2 of the previous cycle predicts: if `Cl(𝒪_K) ≃ (ℤ/p)^r`, a Hilbert class field
datum has exactly `∑_{k=0}^{r} binom(r,k)_p` intermediate fields, of which exactly
`binom(r,k)_p` have degree `p^k` over `K`.

## 1. Gaussian binomial values

`binom(r,k)_p = ∏_{i<k}(p^r - p^i) / ∏_{i<k}(p^k - p^i)` (all divisions are exact):

| p | r | `binom(r,k)_p`, k = 0..r | total |
|---|---|---|---|
| 2 | 1 | 1, 1            | 2  |
| 2 | 2 | 1, 3, 1         | 5  |
| 2 | 3 | 1, 7, 7, 1      | 16 |
| 2 | 4 | 1, 15, 35, 15, 1| 67 |
| 3 | 2 | 1, 4, 1         | 6  |
| 3 | 3 | 1, 13, 13, 1    | 28 |
| 5 | 2 | 1, 6, 1         | 8  |

The totals `1, 2, 5, 16, 67, 374, …` for `p = 2` are the Galois numbers, OEIS **A006116**
(number of subspaces of `F_2^n`). For `p = 3` the totals `1, 2, 6, 28, …` are OEIS **A006117**.

## 2. Brute-force check against actual subgroup counts

Enumerating *all* subgroups of the elementary abelian group `(ℤ/p)^r` by spanning sets and
grouping them by order gives:

| p | r | total subgroups | count by dimension |
|---|---|---|---|
| 2 | 2 | 5  | {0:1, 1:3, 2:1} |
| 2 | 3 | 16 | {0:1, 1:7, 2:7, 3:1} |
| 3 | 2 | 6  | {0:1, 1:4, 2:1} |

These agree exactly with the Gaussian binomial table. In particular the falsifiable
predictions of the previous cycle are confirmed numerically:

* `p = r = 2`: five intermediate fields, degrees `1, 2, 2, 2, 4` (already proved);
* `p = 2, r = 3`: **sixteen** intermediate fields, one of degree `1`, seven of degree `2`,
  seven of degree `4`, one of degree `8`.

## 3. Counterexample hunt

No counterexample exists: the brute-force enumeration above matches the closed formula in
every case tested, and the general statement is what is proved formally in
`Catalog/NumberTheory/SubspaceCounting.lean` (`card_submodule_finrank_eq_gaussBinom`,
`card_submodule_eq_sum_gaussBinom`) and transported to Hilbert class field data in
`Catalog/NumberTheory/ElementaryAbelianClassField.lean`.

The one place where a naive guess *would* fail is the symmetry `binom(r,k)_p =
binom(r,r-k)_p`: it is true, but not visible from the definition as a truncated natural
number division, and it is proved here through the duality bijection between `k`-dimensional
subspaces of `V` and `(r-k)`-dimensional subspaces of `V` (`gaussBinom_symm`).
