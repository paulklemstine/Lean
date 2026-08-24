import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import MachineLearning.ZeroFitDialResolution
import Novelty.ZeroFitDialExactBitlen48

/-!
# The exact threshold of the ceiling-inversion law

## Research context (FACT round-57 #1, exp 527, second cycle)

`Novelty.ZeroFitDialExactBitlen48` reduced the exact-bitlen-48 measurement to the
full-range profiles at bitlen `47` and established the *odd* half of the
ceiling-inversion law (the catalog previously had only the even half, in
`MachineLearning.ZeroFitDialUnif52.ceiling_inversion`, valid for bitlen `≥ 10`).

Both halves are asymptotic: they need bitlen `≥ 10`, because they go through the
Franel estimate `franel b · (3m+1) ≤ 8^b`, which is too lossy below that.  This
file closes the remaining window and determines the inversion threshold
**exactly**.

## Main results

* `spearmanSq_of_cubeSum` — the tie ceiling depends on a profile only through its
  mass `n` and its cube sum `Σⱼ mⱼ³`.
* `spearmanSq_lt_of_cubeSum_lt`, `spearmanSq_eq_of_cubeSum_eq` — hence comparing
  two ceilings of equal mass is comparing two cube sums, in the *opposite* order.
* `dyadic_cubeSum` (`= (8^b-1)/7 + 1`) and `binom_cubeSum` (`= franel b`) — the
  two cube sums in closed form.
* `inversion_of_franel_lt` — the arithmetic criterion `7·franel b < 8^b + 6`.
* `ceiling_inversion_threshold` — **for every bitlen `b ≥ 3` the popcount
  baseline has the strictly higher tie ceiling**, both parities, no asymptotics.
* `ceiling_tie_at_one`, `ceiling_tie_at_two`, `inversion_iff_three_le` — and the
  threshold is sharp: at `b = 1, 2` the dyadic and binomial profiles have equal
  cube sums, so the two ceilings coincide exactly.
* `exact_bitlen_inversion` — the inversion is invariant under exact-bitlen
  conditioning (both profiles shift by one bit, `ZeroFitDialExactBitlen48`), so
  it applies verbatim to the round-57 uniform-at-exact-bitlen-48 cell.

## The scientific payload

The tie-headroom ordering between the trailing-zero dial and the popcount
baseline is *universal above bitlen 3* and *degenerate below it*: `b ≤ 2` are the
only bitlens where the two statistics are tie-equivalent (indeed their profiles
are permutations of each other: `[2,1,1]` versus `[1,2,1]`).  Consequently no
measured advantage of the dial over the count baseline at any realistic bitlen
can be explained by tie geometry — the geometry always favours the baseline.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52
open Catalog.MachineLearning.ZeroFitDialResolution
open Catalog.Novelty.ZeroFitDialExactBitlen48

namespace Catalog.Novelty.ZeroFitDialInversionThreshold

/-! ## 1. The ceiling as a function of mass and cube sum -/

/-- The tie ceiling of a profile is a function of its mass and its cube sum alone. -/
theorem spearmanSq_of_cubeSum (L : List ℕ) (h2 : 2 ≤ L.sum) :
    spearmanSq L = 1 - (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  rw [spearmanSq_eq L h2, twelve_tieCorr_eq]

lemma sum_cube_pos {L : List ℕ} (h2 : 2 ≤ L.sum) : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := by
  have h : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hfac : (L.sum : ℚ) ^ 3 - (L.sum : ℚ)
      = (L.sum : ℚ) * ((L.sum : ℚ) - 1) * ((L.sum : ℚ) + 1) := by ring
  rw [hfac]
  have h1 : (0 : ℚ) < (L.sum : ℚ) - 1 := by linarith
  have h2' : (0 : ℚ) < (L.sum : ℚ) + 1 := by linarith
  positivity

/-- **Cube-sum comparison.**  Among profiles of equal mass, a larger cube sum means a
strictly smaller ceiling. -/
theorem spearmanSq_lt_of_cubeSum_lt {L M : List ℕ} (hs : L.sum = M.sum) (h2 : 2 ≤ L.sum)
    (h : cubeSum M < cubeSum L) : spearmanSq L < spearmanSq M := by
  have h2' : 2 ≤ M.sum := hs ▸ h2
  have hpos : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := sum_cube_pos h2
  have hcast : ((M.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hs]
  rw [spearmanSq_of_cubeSum L h2, spearmanSq_of_cubeSum M h2', hcast]
  have hmono : (cubeSum M - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      < (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [div_lt_div_iff₀ hpos hpos]
    nlinarith
  linarith

/-- Equal mass and equal cube sum give exactly equal ceilings. -/
theorem spearmanSq_eq_of_cubeSum_eq {L M : List ℕ} (hs : L.sum = M.sum) (h2 : 2 ≤ L.sum)
    (h : cubeSum L = cubeSum M) : spearmanSq L = spearmanSq M := by
  have h2' : 2 ≤ M.sum := hs ▸ h2
  have hcast : ((M.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hs]
  rw [spearmanSq_of_cubeSum L h2, spearmanSq_of_cubeSum M h2', hcast, h]

/-! ## 2. The two cube sums in closed form -/

lemma cubeSum_eq (L : List ℕ) : cubeSum L = 12 * tieCorr L + (L.sum : ℚ) := by
  rw [twelve_tieCorr_eq]; ring

/-- Cube sum of the dyadic (trailing-zero) profile. -/
theorem dyadic_cubeSum (b : ℕ) : cubeSum (dyadicBlocks b) = ((8 : ℚ) ^ b - 1) / 7 + 1 := by
  rw [cubeSum_eq, tieCorr_dyadic b, dyadicBlocks_sum b]
  push_cast
  ring

/-- Cube sum of the binomial (popcount) profile is the Franel number. -/
theorem binom_cubeSum (b : ℕ) : cubeSum (binomBlocks b) = (franel b : ℚ) := by
  rw [cubeSum_eq, tieCorr_binomBlocks b, binomBlocks_sum b]
  push_cast
  ring

/-- **Arithmetic inversion criterion.**  `7·franel b < 8^b + 6` forces the popcount ceiling
above the trailing-zero ceiling at bitlen `b`. -/
theorem inversion_of_franel_lt (b : ℕ) (hb : 1 ≤ b) (h : 7 * franel b < 8 ^ b + 6) :
    spearmanSq (dyadicBlocks b) < spearmanSq (binomBlocks b) := by
  have hsum : (dyadicBlocks b).sum = (binomBlocks b).sum := by
    rw [dyadicBlocks_sum, binomBlocks_sum]
  have h2 : 2 ≤ (dyadicBlocks b).sum := by
    rw [dyadicBlocks_sum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  refine spearmanSq_lt_of_cubeSum_lt hsum h2 ?_
  rw [dyadic_cubeSum, binom_cubeSum]
  have hq : 7 * (franel b : ℚ) < (8 : ℚ) ^ b + 6 := by
    have := (Nat.cast_lt (α := ℚ)).2 h
    push_cast at this
    exact this
  linarith

/-! ## 3. The small bitlens, by direct arithmetic -/

lemma franel_small (b : ℕ) (hb : 3 ≤ b) (hb' : b ≤ 9) : 7 * franel b < 8 ^ b + 6 := by
  interval_cases b <;> simp [franel, Finset.sum_range_succ, Nat.choose]

/-! ## 4. The threshold theorem -/

/-- **Inversion threshold.**  At every bitlen `b ≥ 3` — even or odd, small or large — the
popcount baseline has a strictly higher tie ceiling than the trailing-zero statistic. -/
theorem ceiling_inversion_threshold (b : ℕ) (hb : 3 ≤ b) :
    spearmanSq (dyadicBlocks b) < spearmanSq (binomBlocks b) := by
  rcases lt_or_ge b 10 with hsmall | hbig
  · exact inversion_of_franel_lt b (by omega) (franel_small b hb (by omega))
  · rcases Nat.even_or_odd b with ⟨m, hm⟩ | ⟨m, hm⟩
    · have hm5 : 5 ≤ m := by omega
      have h : b = 2 * m := by omega
      rw [h]
      exact ceiling_inversion m hm5
    · have hm5 : 5 ≤ m := by omega
      rw [hm]
      exact ceiling_inversion_odd m hm5

/-- At bitlen 1 the two profiles are both `[1,1]`: the ceilings coincide. -/
theorem ceiling_tie_at_one : spearmanSq (dyadicBlocks 1) = spearmanSq (binomBlocks 1) := by
  refine spearmanSq_eq_of_cubeSum_eq (by simp [dyadicBlocks_sum, binomBlocks_sum]) (by decide) ?_
  rw [dyadic_cubeSum, binom_cubeSum]
  norm_num [franel, Finset.sum_range_succ]

/-- At bitlen 2 the profiles are `[2,1,1]` and `[1,2,1]` — permutations of each other — so the
ceilings again coincide exactly. -/
theorem ceiling_tie_at_two : spearmanSq (dyadicBlocks 2) = spearmanSq (binomBlocks 2) := by
  refine spearmanSq_eq_of_cubeSum_eq (by simp [dyadicBlocks_sum, binomBlocks_sum]) (by decide) ?_
  rw [dyadic_cubeSum, binom_cubeSum]
  norm_num [franel, Finset.sum_range_succ, Nat.choose]

/-- **Sharpness.**  For `b ≥ 1` the strict inversion holds exactly when `b ≥ 3`. -/
theorem inversion_iff_three_le (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks b) < spearmanSq (binomBlocks b) ↔ 3 ≤ b := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    interval_cases b
    · exact absurd ceiling_tie_at_one (ne_of_lt h)
    · exact absurd ceiling_tie_at_two (ne_of_lt h)
  · exact ceiling_inversion_threshold b

/-- **Inversion survives exact-bitlen conditioning.**  Because both tie profiles shift by
exactly one bit, the round-57 sampling scheme (uniform at exact bitlen `b+1`) inherits the
inversion for every `b ≥ 3`. -/
theorem exact_bitlen_inversion (b : ℕ) (hb : 3 ≤ b) :
    spearmanSq (windowProfile b) < spearmanSq (weightWindowProfile b) := by
  rw [windowProfile_eq_dyadicBlocks, weightWindowProfile_eq_binomBlocks]
  exact ceiling_inversion_threshold b hb

/-- The round-57 cell, restated through the threshold theorem: at exact bitlen 48 the tie
geometry favours the count baseline, while the measurement favours the dial by `+0.134`. -/
theorem round57_inversion_and_measured_advantage :
    spearmanSq (windowProfile 47) < spearmanSq (weightWindowProfile 47) ∧
    0 < advantage48 := by
  exact ⟨exact_bitlen_inversion 47 (by norm_num), by norm_num [advantage48]⟩

end Catalog.Novelty.ZeroFitDialInversionThreshold