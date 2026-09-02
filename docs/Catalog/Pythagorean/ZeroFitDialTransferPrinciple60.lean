import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialBalanced60

/-!
# The transfer principle for tie profiles

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

Every ceiling bound in this thread compares cube sums of tie profiles that have the *same*
total `n`: `cubeSum_balanced_le`, `weight_ceiling_ge`, `loss_invariant`, `geom_cube_bound`.
That is not a coincidence — by the tie-attenuation law
`ρ² = 1 − 12·tieCorr/(n³ − n)` and `12·tieCorr = Σⱼmⱼ³ − n`, at fixed `n` the ceiling is a
strictly decreasing function of the cube sum alone.

This file isolates the resulting order principle.

## Main results

* `spearmanSq_anti_cubeSum`, `spearmanSq_strict_anti_cubeSum` — at fixed total, the ceiling
  is antitone (strictly antitone) in the cube sum.  This is the reusable comparison lemma
  behind all the ad-hoc estimates above.
* `cubeSum_transfer`, `spearmanSq_transfer` — **the transfer principle**: moving one
  observation from a smaller tie block to a larger one strictly increases the cube sum and
  hence strictly *lowers* the ceiling.  Concentration of ties is what destroys rank
  resolution; spreading them out preserves it.
* `two_block_spread`, `two_block_flat_max` — the two-block case in closed form: with total
  `n` fixed, `ρ²` is monotone in the spread `|a − b|`, and the flat split maximises it.

## Why the constant `3` keeps appearing

The transfer inequality is driven by the cubic difference
`(b+1)³ − b³ = 3b² + 3b + 1`, which is strictly increasing in `b`.  The same polynomial
`3c² + 3c + 1` decides the half-weight phase boundary in
`Pythagorean.ZeroFitDialSparseWindow60` (through `(1+c)³ − c³ > 7`), and its value at `c = 1`
is the `7` in the universal constant `6/7`.  The three facts are one fact about cubes.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialBalanced60

namespace Catalog.Pythagorean.ZeroFitDialTransferPrinciple60

/-! ## 1. The ceiling is antitone in the cube sum -/

/-- At a fixed number of observations, a larger cube sum means a lower ceiling. -/
theorem spearmanSq_anti_cubeSum (L L' : List ℕ) (hsum : L.sum = L'.sum) (h2 : 2 ≤ L.sum)
    (hC : cubeSum L ≤ cubeSum L') : spearmanSq L' ≤ spearmanSq L := by
  have h2' : 2 ≤ L'.sum := by omega
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  have hcast : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  rw [spearmanSq_eq L h2, spearmanSq_eq L' h2', twelve_tieCorr_eq, twelve_tieCorr_eq, hcast]
  have : (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - L.sum)
      ≤ (cubeSum L' - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - L.sum) := by
    rw [div_le_div_iff_of_pos_right hden]
    linarith
  linarith

/-- Strict version of `spearmanSq_anti_cubeSum`. -/
theorem spearmanSq_strict_anti_cubeSum (L L' : List ℕ) (hsum : L.sum = L'.sum) (h2 : 2 ≤ L.sum)
    (hC : cubeSum L < cubeSum L') : spearmanSq L' < spearmanSq L := by
  have h2' : 2 ≤ L'.sum := by omega
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  have hcast : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  rw [spearmanSq_eq L h2, spearmanSq_eq L' h2', twelve_tieCorr_eq, twelve_tieCorr_eq, hcast]
  have hlt : (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - L.sum)
      < (cubeSum L' - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - L.sum) := by
    rw [div_lt_div_iff_of_pos_right hden]
    linarith
  linarith

/-! ## 2. The transfer principle -/

/-- **Transfer increases the cube sum.**  Moving one observation from a block of size
`a + 1` to a strictly larger block of size `b` (`a + 1 ≤ b`) increases `Σⱼ mⱼ³`.  The engine
is that `(x+1)³ − x³ = 3x² + 3x + 1` is strictly increasing in `x`. -/
theorem cubeSum_transfer (a b : ℕ) (L : List ℕ) (hab : a + 1 ≤ b) :
    cubeSum ((a + 1) :: b :: L) < cubeSum (a :: (b + 1) :: L) := by
  rw [cubeSum_cons, cubeSum_cons, cubeSum_cons, cubeSum_cons]
  have hQ : ((a : ℚ) + 1) ≤ (b : ℚ) := by exact_mod_cast hab
  have ha0 : (0 : ℚ) ≤ (a : ℚ) := Nat.cast_nonneg a
  have hcast1 : (((a + 1 : ℕ)) : ℚ) = (a : ℚ) + 1 := by push_cast; ring
  have hcast2 : (((b + 1 : ℕ)) : ℚ) = (b : ℚ) + 1 := by push_cast; ring
  rw [hcast1, hcast2]
  -- `(b+1)³ − b³ = 3b² + 3b + 1 > 3a² + 3a + 1 = (a+1)³ − a³`
  nlinarith [hQ, ha0, sq_nonneg ((b : ℚ) - (a : ℚ))]

/-- **The transfer principle.**  Concentrating ties lowers the ceiling: moving one
observation from a smaller block into a larger one strictly decreases `ρ²`. -/
theorem spearmanSq_transfer (a b : ℕ) (L : List ℕ) (hab : a + 1 ≤ b)
    (h2 : 2 ≤ ((a + 1) :: b :: L).sum) :
    spearmanSq (a :: (b + 1) :: L) < spearmanSq ((a + 1) :: b :: L) := by
  have hsum : ((a + 1) :: b :: L).sum = (a :: (b + 1) :: L).sum := by
    simp [List.sum_cons]
    omega
  exact spearmanSq_strict_anti_cubeSum _ _ hsum h2 (cubeSum_transfer a b L hab)

/-! ## 3. Two blocks: the flat split is optimal -/

/-- Cube sum of a two-block profile in terms of its total and its product. -/
lemma two_block_cubeSum (a b : ℕ) :
    cubeSum [a, b] = ((a : ℚ) + b) ^ 3 - 3 * ((a : ℚ) * b) * ((a : ℚ) + b) := by
  rw [cubeSum_cons, cubeSum_cons]
  simp [cubeSum]
  ring

/-- **Spread lowers the ceiling.**  Among two-block profiles with a fixed total, a more
spread-out split has a smaller (or equal) ceiling. -/
theorem two_block_spread (a b a' b' : ℕ) (hsum : a + b = a' + b') (h1 : a' ≤ a) (h2 : a ≤ b)
    (h3 : b ≤ b') (hn : 2 ≤ a + b) :
    spearmanSq [a', b'] ≤ spearmanSq [a, b] := by
  have hsumL : ([a, b] : List ℕ).sum = ([a', b'] : List ℕ).sum := by
    simp [List.sum_cons]
    omega
  have h2L : 2 ≤ ([a, b] : List ℕ).sum := by simp [List.sum_cons]; omega
  refine spearmanSq_anti_cubeSum _ _ hsumL h2L ?_
  rw [two_block_cubeSum, two_block_cubeSum]
  have hst : ((a' : ℚ) + b') = ((a : ℚ) + b) := by
    have : (a' + b' : ℕ) = (a + b : ℕ) := by omega
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) this
  rw [hst]
  -- the product drops when the pair is spread apart
  have hprod : (a' : ℚ) * b' ≤ (a : ℚ) * b := by
    have hnat : a' * b' ≤ a * b := by
      have hd : a' + (a - a') = a := by omega
      have hb : b' = b + (a - a') := by omega
      subst hb
      have ha' : a' = a - (a - a') := by omega
      nlinarith [Nat.sub_le a a', h2, h1]
    exact_mod_cast hnat
  have hs0 : (0 : ℚ) ≤ (a : ℚ) + b := by positivity
  nlinarith [hprod, hs0]

/-- The flat split maximises the ceiling among two-block profiles: for any split `a + b = n`
the balanced split `⌊n/2⌋ + ⌈n/2⌉` is at least as good. -/
theorem two_block_flat_max (a b : ℕ) (hn : 2 ≤ a + b) (hab : a ≤ b) :
    spearmanSq [a, b] ≤ spearmanSq [(a + b) / 2, (a + b) - (a + b) / 2] := by
  refine two_block_spread ((a + b) / 2) ((a + b) - (a + b) / 2) a b (by omega) (by omega)
    (by omega) (by omega) (by omega)

/-!
## Lab Notes (cycle 9)

The transfer principle explains, in one line, why every profile in this thread was compared
by its cube sum.  A few exact values of the two-block ceiling at total `n = 12`:

| split `[a, b]` | `Σ mⱼ³` | `ρ²` |
|----------------|---------|------|
| [6, 6] | 432 | 0.755245 |
| [5, 7] | 468 | 0.734266 |
| [4, 8] | 576 | 0.671329 |
| [3, 9] | 756 | 0.566434 |
| [2, 10] | 1008 | 0.419580 |
| [1, 11] | 1332 | 0.230769 |

Each single transfer `[a+1, b] → [a, b+1]` (with `a + 1 ≤ b`) raises the cube sum by
`3(b² − a²) + 3(b − a) > 0` and therefore lowers `ρ²`, monotonically — the table is strictly
decreasing, as `spearmanSq_transfer` requires.

The same cubic difference `3x² + 3x + 1` appears three times in this thread:

* here, as the gain of one transfer;
* in `Pythagorean.ZeroFitDialSparseWindow60`, as `(1+c)³ − c³ > 7` — the asymptotic form of
  the half-weight phase boundary, whose solution `c = 1` is the half-weight line;
* in `Pythagorean.ZeroFitDialRadixCeiling60`, as the denominator of the universal constant
  `3q/(q² + q + 1)`, whose value at `q = 2` is `6/7`.
-/

end Catalog.Pythagorean.ZeroFitDialTransferPrinciple60