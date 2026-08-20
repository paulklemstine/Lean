# Computational evidence — Bonferroni machinery and marginal selection

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0), i.e. by the
kernel-compatible compiler on the same definitions that appear in
`Catalog/Combinatorics/BonferroniMarginals.lean` (`mult`, `support`, `pairSum`,
`doubleCollision`).  They are *exploratory data*, not proofs; every claim that survived them
is proved separately in the Lean file with 0 sorries.

## 1. Exhaustive check of the machinery on all families `Fin 3 → Finset (Fin 4)`

Ground set `Fin 4`, index set `Fin 3`, so `2^4 = 16` possible members and `16³ = 4096`
families.  For each family we tested the three universal statements.

| quantity | count (out of 4096) |
|---|---|
| families violating `∑ᵢ \|Aᵢ\| ≤ \|support\| + pairSum` | **0** |
| families with **equality** in that inequality | 256 |
| families violating `2·\|doubleCollision\| ≤ pairSum` | **0** |
| families with equality `2·\|doubleCollision\| = pairSum ≠ 0` | 2145 |
| families violating `(∑ᵢ \|Aᵢ\|)² ≤ \|support\|·(∑ᵢ \|Aᵢ\| + pairSum)` | **0** |

The equality count `256 = 4⁴` is exactly the number of pairwise disjoint families (each of
the 4 points is placed in one of the 3 members or in none).  This is a numerical confirmation
of the equality characterisation proved as `Bonferroni.sum_eq_iff_pairwiseDisjoint`.

Both sharpness observations were then turned into theorems
(`doubleCollision_bound_sharp`, `bonferroni_can_be_strict`).

## 2. Which marginals? Sidon sets in `ZMod N`

`maxSidon N` is the true maximum size of a Sidon set in `ZMod N`, computed by brute force
over all subsets.  `maxAll N` is the largest `m` permitted by the **all-translate** output
`m(m-1) ≤ N-1`; `maxSelf N` is the largest `m` permitted by the **self-translate** output
`m³ ≤ (2m-1)N`.

| N | maxSidon | maxAll (`S = G`) | maxSelf (`S = A`) |
|---|---|---|---|
| 2 | 1 | 1 | 1 |
| 3 | 2 | 2 | 2 |
| 4 | 2 | 2 | 2 |
| 5 | 2 | 2 | 2 |
| 6 | 2 | 2 | **3** |
| 7 | 3 | 3 | 3 |
| 8 | 3 | 3 | 3 |
| 9 | 3 | 3 | 3 |
| 10 | 3 | 3 | **4** |
| 11 | 3 | 3 | **4** |
| 12 | 3 | 3 | **4** |
| 13 | 4 | 4 | 4 |
| 14 | 4 | 4 | **5** |
| 15 | 4 | 4 | **5** |
| 16 | 4 | 4 | **5** |
| 17 | 4 | 4 | **5** |
| 18 | 4 | 4 | **5** |
| 19 | 4 | 4 | **5** |
| 20 | 4 | 4 | **6** |
| 21 | 5 | 5 | **6** |

Observations.

* For every `N` in the range, `maxAll N = maxSidon N`: feeding **all** `|G|` translates into
  the machinery is not merely sharp asymptotically, it predicts the exact extremal value on
  this whole range.
* `maxSelf` first overshoots at `N = 6` and the gap grows; asymptotically the two outputs are
  `m ≲ √N` versus `m ≲ √(2N)`.
* This is the numerical content of the pair
  `all_translate_bound_implies_self_translate_bound` (the all-translate output always implies
  the self-translate one) and `marginal_selection_strict` (at `N = 100, m = 13` the converse
  fails), both proved in Lean.

## 3. Counterexample hunt

* The universal claims of §1 were tested on the full `4096`-family space: no counterexample.
* The Sidon marginal `#(translate A g ∩ translate A h) ≤ 1` for `g ≠ h` was checked implicitly
  by the fact that no Sidon set in the table exceeds `maxAll`, and is proved in Lean
  (`IsSidon.card_inter_translate_le_one`).
* No OEIS sequence lookup was performed: the sequences appearing here (`maxSidon N` — the
  cyclic-Sidon/perfect-difference-set growth) are used only as a sanity check against the two
  bounds, and no new integer sequence is claimed.
