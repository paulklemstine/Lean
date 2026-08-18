# Computational evidence — almost-lossless / Monte-Carlo compression

All numbers below were produced by exhaustive enumeration in Lean (`#eval` over
lists of `ℕ` implementing arithmetic mod `p`), before the corresponding theorems
were formalised.  Every claim that survived is now a `sorry`-free theorem in
`Catalog/Logic/AlmostLossless/`; the two claims that are *exactly* reproduced by
the theorems are flagged below.

## 1. Pairwise collision fraction of the inner-product family

Family: seed `a ∈ (ZMod p)^k`, hash `x ↦ ⟨a,x⟩ ∈ ZMod p`.
For a fixed pair `x ≠ y` we counted the seeds with `⟨a,x⟩ = ⟨a,y⟩`.

| `p` | `k` | `x` | `y` | colliding seeds / all seeds | fraction |
|----|----|------|------|------|------|
| 7 | 2 | (1,0) | (0,0) | 7 / 49 | 1/7 |
| 7 | 3 | (3,1,1) | (0,2,5) | 49 / 343 | 1/7 |
| 5 | 2 | (2,4) | (1,1) | 5 / 25 | 1/5 |
| 11 | 2 | (3,4) | (7,1) | 11 / 121 | 1/11 |

The fraction is **exactly** `1/p` in every case — the family is not merely
2-universal but pairwise independent.  Formalised as
`AlmostLossless.twoUniversal_dotHash` (proved through
`AlmostLossless.card_ker_mul_card_eq`, which gives the exact fibre count).

## 2. Probability that a random seed is injective on a typical set `T`

| `p` | `k` | `|T|` | good seeds / all | failure prob. | union bound `|T|(|T|-1)/p` | random-function birthday value |
|----|----|-----|------|------|------|------|
| 11 | 2 | 3 | 90 / 121 | 0.256 | 0.545 | 0.256 |
| 11 | 2 | 4 | 80 / 121 | 0.339 | > 1 | 0.459 |
| 11 | 2 | 5 | 40 / 121 | 0.669 | > 1 | 0.656 |
| 13 | 3 | 5 | 888 / 2197 | 0.596 | > 1 | 0.584 |

Observations:

* the union bound `AlmostLossless.collisionProb_le` is always valid but loose by
  a factor ≈ 2 already at `|T| = 3`;
* the empirical failure probability tracks the *birthday* value
  `1 - ∏_{i<|T|}(1 - i/p)` closely, i.e. the quadratic dependence on `|T|` is
  genuine and not an artefact of the union bound.  This motivated the
  "birthday penalty" statement `AlmostLossless.exists_quadratic_rate_scanScheme`
  (range of size `≍ |T|²`).

## 3. Exact structure of the bad-seed set (`k = 2`)

Counting the distinct **projective directions** `d` of the difference set of
`T` (normalising each nonzero difference to `[1, *]` or `[0, 1]`):

| `p` | `T` | `d` | predicted bad seeds `1 + d(p-1)` | measured bad seeds |
|----|-----|----|------|------|
| 11 | {(1,0),(0,1),(2,3)} | 3 | 31 | 31 |
| 11 | {(1,0),(0,1),(2,3),(5,7)} | 4 | 41 | 41 |
| 11 | {(1,0),(0,1),(2,3),(5,7),(9,4)} | 8 | 81 | 81 |

Exact agreement in all cases.  This is now the theorem
`AlmostLossless.exact_card_collides_planar` (bad seeds form a pencil of `d`
lines through the origin), together with the machine-checked instance
`AlmostLossless.example_card_collides` and its independent `decide`
cross-check `AlmostLossless.example_card_collides_bruteForce` (31 of 121).

In dimension 3 the analogous count is *not* `1 + d(p^{k-1}-1)`
(`p = 13, k = 3, |T| = 5`: `d = 20`, measured bad seeds `1309`, formula would
give `1 + 20·168 = 3361 > p^k`), because three or more hyperplanes through the
origin intersect in more than the origin.  Hence the theorem is stated for
`k = 2` only; the higher-dimensional case needs inclusion–exclusion over the
lattice of subspaces spanned by the directions (see `FUTURE_DIRECTIONS.md`).

## 4. Expected decoder work of the bucketed decoder

Average, over all `p^k` seeds, of the size of the bucket containing a fixed
typical word `x` (this is exactly the number of candidate tests the bucketed
decoder performs):

| `p` | `k` | `|T|` | measured average | `1 + (|T|-1)/p` |
|----|----|-----|------|------|
| 11 | 2 | 5 | 165/121 = 1.3636 | 1 + 4/11 = 1.3636 |
| 13 | 3 | 5 | 2873/2197 = 1.3077 | 1 + 4/13 = 1.3077 |

The bound `AlmostLossless.avg_decodeCost_bucketed_le` is **attained with
equality** for this family — expected decoder work is `1 + (|T|-1)/m₁` candidate
tests, i.e. essentially constant once the bucket count exceeds `|T|`, versus
`|T|` for the naive scan.

## 5. Counterexample hunt

* *"Honesty needs a checksum."*  Refuted: with uniqueness decoding the scan is
  honest for **every** seed, because the true word is always a candidate, so a
  unique match must be it (`AlmostLossless.honest_scanCode`).  No separate
  checksum field is needed; the second hash only buys decoding *speed*.
* *"Shared randomness beats the counting bound."*  Refuted for uniform sources:
  averaging the deterministic bound over any seed distribution gives the same
  `1 - |C|/|S|` (`AlmostLossless.randomized_avg_failProb_lower`).
* *"The relaxed bound is just `(1-ε)|S| ≤ |C|`."*  Only for uniform sources; the
  correct general statement is the concentration characterisation
  `AlmostLossless.epsilon_pigeonhole_iff`.
