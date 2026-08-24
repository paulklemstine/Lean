# Computational Evidence — Greedy avoidance of differences and `B_h` sets

Scope: this note records the small-case data that guided the Lean development in
`Catalog/Novelty/GreedyDifferenceSidon.lean`, `GreedyDifferenceCubic.lean`,
`BhSetsDifferences.lean`, `GreedyBhSets.lean` and `BhTowerStrictness.lean`.

**Status of the numbers below.** Only the entries explicitly marked *(Lean)* are
machine-verified; the tables were produced by ad-hoc enumeration and are exploratory
evidence, not verification. Every theorem cited is separately proved with 0 sorries.

## 1. The greedy difference-avoiding sequence

Greedy rule: start from `∅`; repeatedly adjoin the least natural number that repeats no
difference `a i − a j` already realised. Values of the Lean `greedySeq`:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|----|----|----|----|
| `greedySeq n` | 0 | 1 | 3 | 7 | 12 | 20 | 30 | 44 | 65 | 80 | 96 | 122 | 147 | 181 |

Shifting by `+1` gives `1, 2, 4, 8, 13, 21, 31, 45, 66, 81, 97, 123, 148, 182`, i.e.
**OEIS A005282** (Mian–Chowla). So greedy *difference* avoidance and greedy *sum* avoidance
produce the same sequence — the reason is `isSidon_iff_sub_injOn` *(Lean)*, which shows the
two rules define the same predicate over `ℕ`.

*(Lean)* `greedySeq_zero = 0`, `greedySeq_one = 1`, `greedySeq_two = 3`, `greedySeq_three = 7`
are proved in `GreedyDifferenceSidon.lean`; the strict monotonicity of the whole sequence is
`greedySeq_strictMono`.

## 2. Counterexample hunt against the growth bounds

Both sides of the sandwich were tested on all computed terms; no counterexample was found,
consistent with the theorems `greedySeq_sandwich` *(Lean)* and `greedySeq_sandwich_cubic` *(Lean)*.

| n | `n(n+1)/2` (lower) | `greedySeq n` | `n³+n²+n` (cubic) | `(n+1)⁴/4` (old quartic) |
|---|---|---|---|---|
| 4 | 10 | 12 | 84 | 156 |
| 8 | 36 | 65 | 584 | 1640 |
| 11 | 66 | 122 | 1463 | 5184 |
| 13 | 91 | 181 | 2379 | 9604 |

Observed growth in the accessible range is roughly `n^{2.4}`, comfortably inside the
proved band `[n²/2, n³+n²+n]`. The cubic bound is the exact strength of the counting
argument (the obstruction set has `≤ |A|³` elements); closing the remaining gap is a
*dispersion* question, not a counting one.

## 3. Sharpness of the halving obstruction

The unordered step criterion `isSidon_insert_of_avoid` needs two obstruction sets. A search
over small sets produced the minimal witness that the quadratic one cannot be dropped:

* `A = {0, 2}` is Sidon, `m = 1 ∉ A`;
* every element of `sidonBad A = {c + d − b}` is even, so `1 ∉ sidonBad A`;
* yet `{0, 1, 2}` is not Sidon, because `0 + 2 = 1 + 1`.

This is exactly `halving_obstruction_necessary` *(Lean)*, proved by parity rather than by
enumeration, and lifted to one witness of every size `k ≥ 2` by
`halving_obstruction_family` *(Lean)* using the dilates `2 · greedySet k`. In the other
direction the two obstructions turn out to be exactly complete
(`isSidon_insert_iff_avoid` *(Lean)*).

## 3b. Perfect (Singer) difference sets

A Sidon set of `n` elements is *perfect* modulo `q = n² − n + 1` when its differences cover
every nonzero residue. Reducing the greedy set:

| n | q | perfect? | first missed residues |
|---|---|---|---|
| 3 | 7 | yes | — |
| 4 | 13 | no | 5, 8 |
| 5 | 21 | no | 8, 13 |
| 6 | 31 | no | 10, 15, 16, 21 |
| 7 | 43 | no | 15, 21, 22, 28 |
| 8 | 57 | no | 15, 21, 22, 26, 31, 35 |
| 9 | 73 | no | 16, 22, 25, 26, 31, 33 |

The first two rows are machine-verified: `greedySet_three_perfect` and
`greedySet_four_not_perfect` *(Lean)*. The rest is exploratory and motivates Direction 4 of
`FUTURE_DIRECTIONS.md`.

## 4. Greedy `B_h` sequences

Greedy `B_h` sets (least element keeping the `B_h` property), shifted by `+1`:

| h | first terms (shifted) | OEIS |
|---|---|---|
| 2 | 1, 2, 4, 8, 13, 21, 31, 45, 66 | A005282 |
| 3 | 1, 2, 5, 14, 33, 72, 125, 219, 376 | A046185 |
| 4 | 1, 2, 6, 22, 56, 154, 369, 857, 1425 | A046186 |

The growth is visibly faster in `h`, matching the polynomial-degree jump in the proved
sandwich `greedySeqBh_sandwich` *(Lean)*: lower bound of degree `h` (`C(n+1,h) ≤ h·a n + 1`)
and upper bound of degree `2h+1`, improved to degree `2h` by
`greedySeqBh_le_deg2h` *(Lean)* once chain rigidity is available at level `h`
(`greedyBh_valid_gt` *(Lean)*, in `Catalog/Novelty/GreedyBhRigidity.lean`).

Checked on the `B_3` data: `C(n+1,3) ≤ 3·a n + 1` holds for every computed `n`.

## 5. Strictness of the tower

The greedy Sidon set `{0,1,3,7,12,20,30,44}` is `B_2` but **not** `B_3`; already
`{0,1,3}` fails `B_3` (`{0,0,3}` and `{1,1,1}` both sum to `3`). The generic separator
`{0, 1, h+1}` — `B_h` but not `B_{h+1}` — is proved in `BhTowerStrictness.lean`
(`tripleSet_isBh`, `tripleSet_not_isBh_succ`, `bh_tower_strict`) *(Lean)*, and transported
to the difference layers by `isDiffBh_iff_isBh_two_mul` *(Lean)*.
