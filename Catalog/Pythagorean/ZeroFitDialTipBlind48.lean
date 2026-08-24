import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48
import Pythagorean.ZeroFitDialResolutionLadder48

/-!
# Where the zero-fit dial demands resolution: the bulk/tip asymmetry at exact bitlen 48

## Research context (FACT round-56 #1, exp 526, `CELL-CLOSED-DIAL-HOLDS-UNIF-48`)

`Pythagorean.ZeroFitDialResolutionLadder48` showed that the recorded dial
`0.7192 / 0.7202 / 0.7198` excludes every response that is blind inside the *bottom* dyadic
bulk of depth `t ≥ 3` (i.e. flat on `87.5 %` of the T-scale), however finely it resolves
above the boundary.  That is a one-sided statement: it says the response must see the bulk,
but says nothing about the *tip* — the rare, high-`T` end where the relation events live.

This file settles the dual question, and the answer is a sharp asymmetry.

## Main results

* `ssR_append` — additivity of the between-group sum of squares along a concatenation.
* `ssR_tip_merged` — **the tip is free**: merging the entire top `2^{-t}` fraction of the
  T-scale into a single tie costs *exactly* the sum of squares of the merged part,
  `ssR(tip-merged) = ssR(fine) - (8^{b-t} - 1)/14`.  The parallel-axis cross terms cancel
  identically, which is why the cost has a closed form with no interaction term.
* `tip_merged_ceiling` — hence `ρ² = (8^b - 8^{b-t})/(8^b - 1)`.
* `tip_blind_ceiling_large` — this exceeds `7/8` for every depth `t ≥ 1`.
* `tip_blind_response_admissible` — **the payload**: at exact bitlen 48 there is, at every
  depth `t ≥ 1`, a response totally blind on the top `2^{-t}` of the T-scale whose squared
  Spearman coefficient still exceeds the recorded `0.7192²`.
* `bulk_tip_resolution_asymmetry` — the two sides together: merging the *bottom* `87.5 %`
  destroys the dial, while merging the *top* `50 %` does not.  The information the recorded
  dial certifies lives in the no-relation bulk, not on the relation events.
* `dial_ceiling_bitlen_invariant` — every ceiling in this cycle is the limit parabola
  `(7/2)p(1-p)` up to `2·8^{-b}`, so the dial is bitlen-invariant to exponential accuracy;
  this is the algebraic reason the measured value is flat across bitlen scans.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48
open Catalog.Pythagorean.ZeroFitDialResolutionLadder48

namespace Catalog.Pythagorean.ZeroFitDialTipBlind48

/-! ## 1. Additivity of `ssR` along a concatenation -/

/-- The between-group sum of squares is additive along a concatenation, the second summand
being evaluated at the shifted offset. -/
lemma ssR_append (mu : ℚ) (L₁ L₂ : List ℕ) (c : ℚ) :
    ssR mu (L₁ ++ L₂) c = ssR mu L₁ c + ssR mu L₂ (c + (L₁.sum : ℚ)) := by
  induction L₁ generalizing c with
  | nil => simp [ssR]
  | cons m L ih =>
      have harg : c + (m : ℚ) + (L.sum : ℚ) = c + (((m :: L).sum : ℕ) : ℚ) := by
        rw [List.sum_cons, Nat.cast_add]; ring
      rw [List.cons_append, ssR, ssR, ih (c + m), harg]
      ring

/-- Flattening a list of singletons gives back the list. -/
lemma flatten_map_singleton (L : List ℕ) : (L.map (fun m => [m])).flatten = L := by
  induction L with
  | nil => simp
  | cons m L ih => simp [ih]

/-- The coarse profile of "resolve every block of `L`, then merge all of `G`". -/
lemma coarseProfile_tip (L G : List ℕ) :
    coarseProfile (L.map (fun m => [m]) ++ [G]) = L ++ [G.sum] := by
  rw [coarseProfile, List.map_append, List.map_map, List.map_cons, List.map_nil]
  congr 1
  have : (List.sum ∘ fun m : ℕ => [m]) = id := by funext m; simp
  rw [this, List.map_id]

/-! ## 2. The tip-blind response -/

/-- The tie profile of a *tip-blind* response: full resolution on the bottom `t` dyadic
blocks, then one single group for the whole top `2^{-t}` fraction. -/
def tipMergedProfile (b t : ℕ) : List ℕ := (dyadicBlocks b).take t ++ [2 ^ (b - t)]

/-- **Merging the tip costs exactly the tip's own sum of squares.**  The parallel-axis cross
term of the merged group coincides with that of the fine blocks it replaces, so no
interaction term survives. -/
theorem ssR_tip_merged (b t : ℕ) (ht : t ≤ b) (hbt : 1 ≤ b - t) :
    ssR (gmean (dyadicBlocks b)) (tipMergedProfile b t) 0
      = ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 - ((((2 : ℚ) ^ (b - t)) ^ 3 - 1) / 14) := by
  set mu : ℚ := gmean (dyadicBlocks b)
  set S : ℚ := ((((dyadicBlocks b).take t).sum : ℕ) : ℚ)
  have hdrop : (dyadicBlocks b).drop t = dyadicBlocks (b - t) := dyadic_drop_eq b t ht
  have hM : ((2 ^ (b - t) : ℕ) : ℚ) = (2 : ℚ) ^ (b - t) := by push_cast; ring
  have hsumd : (((dyadicBlocks (b - t)).sum : ℕ) : ℚ) = (2 : ℚ) ^ (b - t) := by
    rw [dyadicBlocks_sum]; push_cast; ring
  have hgmd : gmean (dyadicBlocks (b - t)) = ((2 : ℚ) ^ (b - t) + 1) / 2 := by
    rw [gmean, dyadicBlocks_sum]; push_cast; ring
  -- the fine side, split at the boundary
  have hfine : ssR mu (dyadicBlocks b) 0
      = ssR mu ((dyadicBlocks b).take t) 0 + ssR mu (dyadicBlocks (b - t)) (0 + S) := by
    rw [← hdrop, ← ssR_append, List.take_append_drop]
  -- the coarse side, split at the same boundary
  have htip : ssR mu (tipMergedProfile b t) 0
      = ssR mu ((dyadicBlocks b).take t) 0 + ssR mu [2 ^ (b - t)] (0 + S) := by
    rw [tipMergedProfile, ssR_append]
  -- the merged group and the fine tip differ by exactly the tip's own sum of squares
  have hsingle : ssR mu [2 ^ (b - t)] (0 + S)
      = (2 : ℚ) ^ (b - t) * ((0 + S) + ((2 : ℚ) ^ (b - t) + 1) / 2 - mu) ^ 2 := by
    simp only [ssR, hM]
    ring
  have hmerged : ssR mu (dyadicBlocks (b - t)) (0 + S)
      = ((((2 : ℚ) ^ (b - t)) ^ 3 - 1) / 14)
        + (2 : ℚ) ^ (b - t) * ((0 + S) + ((2 : ℚ) ^ (b - t) + 1) / 2 - mu) ^ 2 := by
    rw [ssR_shift_parallel mu (dyadicBlocks (b - t)) (0 + S), ssR_dyadic (b - t) hbt, hsumd, hgmd]
    ring
  rw [htip, hsingle, hfine, hmerged]
  ring

/-- **The tip-blind ceiling.**  A response that resolves the bottom `1 - 2^{-t}` of the
T-scale perfectly and is totally blind above it attains
`ρ² = (8^b - 8^{b-t})/(8^b - 1)`. -/
theorem tip_merged_ceiling (b t : ℕ) (ht : t ≤ b) (hbt : 1 ≤ b - t) :
    ssR (gmean (dyadicBlocks b)) (tipMergedProfile b t) 0
        / ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0
      = (((2 : ℚ) ^ b) ^ 3 - ((2 : ℚ) ^ (b - t)) ^ 3) / (((2 : ℚ) ^ b) ^ 3 - 1) := by
  have hb1 : 1 ≤ b := by omega
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 hb1
    simpa using this
  rw [ssR_tip_merged b t ht hbt, ssR_dyadic b hb1]
  rw [div_eq_div_iff (by linarith) (by linarith)]
  ring

/-- Every tip-blind ceiling is above `7/8`, no matter how much of the top is merged. -/
theorem tip_blind_ceiling_large (b t : ℕ) (ht : 1 ≤ t) (hb : t + 1 ≤ b) :
    7 / 8 < (((2 : ℚ) ^ b) ^ 3 - ((2 : ℚ) ^ (b - t)) ^ 3) / (((2 : ℚ) ^ b) ^ 3 - 1) := by
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 (by omega)
    simpa using this
  have hstep : ((2 : ℚ) ^ (b - t)) ^ 3 * 8 ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have hpow : ((2 : ℚ) ^ (b - t)) ^ 3 * 8 = ((2 : ℚ) ^ (b - t + 1)) ^ 3 := by
      rw [pow_succ]; ring
    rw [hpow, pow_two_cube, pow_two_cube]
    exact pow_le_pow_right₀ (by norm_num) (by omega)
  have hpos : (0 : ℚ) < ((2 : ℚ) ^ b) ^ 3 - 1 := by linarith
  rw [lt_div_iff₀ hpos]
  linarith

/-! ## 3. Payload: the tip may be merged, the bulk may not -/

/-- **At exact bitlen 48 the whole tip may be thrown away.**  For every depth `t ≥ 1` the
response that resolves the bottom `t` dyadic blocks and merges the entire top `2^{-t}`
fraction of the T-scale still has `ρ² > 7/8 > 0.7192²`. -/
theorem tip_blind_response_admissible (t : ℕ) (ht : 1 ≤ t) (htb : t + 1 ≤ 47) :
    seedA ^ 2
      < spearmanSqNest (((dyadicBlocks 47).take t).map (fun m => [m]) ++ [dyadicBlocks (47 - t)]) := by
  set LL : List (List ℕ) :=
    ((dyadicBlocks 47).take t).map (fun m => [m]) ++ [dyadicBlocks (47 - t)] with hLL
  have hbt : 1 ≤ 47 - t := by omega
  have hflat : LL.flatten = dyadicBlocks 47 := by
    rw [hLL, List.flatten_append, flatten_map_singleton, List.flatten_cons, List.flatten_nil,
      List.append_nil, ← dyadic_drop_eq 47 t (by omega), List.take_append_drop]
  have hcoarse : coarseProfile LL = tipMergedProfile 47 t := by
    rw [hLL, coarseProfile_tip, tipMergedProfile, dyadicBlocks_sum]
  have hratio : ssR (gmean (dyadicBlocks 47)) (tipMergedProfile 47 t) 0
      / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0
      = (((2 : ℚ) ^ 47) ^ 3 - ((2 : ℚ) ^ (47 - t)) ^ 3) / (((2 : ℚ) ^ 47) ^ 3 - 1) :=
    tip_merged_ceiling 47 t (by omega) hbt
  have hbig := tip_blind_ceiling_large 47 t ht (by omega)
  have hne : ssR (gmean LL.flatten) (coarseProfile LL) 0 ≠ 0 := by
    rw [hflat, hcoarse]
    intro h0
    rw [h0] at hratio
    have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ 47) ^ 3 := by
      have := cube_two_pow_ge 47 1 (by norm_num)
      simpa using this
    rw [zero_div] at hratio
    rw [← hratio] at hbig
    norm_num at hbig
  rw [nested_spearmanSq LL hne, hflat, hcoarse, hratio]
  have hs : seedA ^ 2 < 7 / 8 := by norm_num [seedA]
  linarith

/-- **The bulk/tip asymmetry.**  At exact bitlen 48 the recorded dial is destroyed by
blindness on the bottom `87.5 %` of the T-scale (left conjunct, `< 0.7192²`) but survives
blindness on the top `50 %` (right conjunct, `> 7/8`).  The dial therefore certifies graded
information inside the no-relation bulk and *none* on the relation events themselves. -/
theorem bulk_tip_resolution_asymmetry :
    ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 3) 0
        / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 < seedA ^ 2 ∧
      seedA ^ 2 < ssR (gmean (dyadicBlocks 47)) (tipMergedProfile 47 1) 0
        / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
  refine ⟨resolution_threshold_at_bitlen48.1 3 (by norm_num) (by norm_num), ?_⟩
  rw [tip_merged_ceiling 47 1 (by norm_num) (by norm_num)]
  have hbig := tip_blind_ceiling_large 47 1 (by norm_num) (by norm_num)
  have hs : seedA ^ 2 < 7 / 8 := by norm_num [seedA]
  linarith

/-! ## 4. Bitlen invariance of the whole ceiling family -/

/-- **The dial ceiling is bitlen-invariant to exponential accuracy.**  Every ceiling of this
cycle equals its `b → ∞` limit `(7/2)p(1-p)` up to `2·8^{-b}`; the bitlen enters only through
the normalisation `n³/(n³-1)`.  So a bitlen scan of the dial is redundant beyond small `b`,
and the value measured at exact bitlen 48 is the limiting value for all practical purposes
(here the error is below `2^{-140}`). -/
theorem dial_ceiling_bitlen_invariant (b : ℕ) (hb : 1 ≤ b) (p : ℚ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    |(7 / 2) * p * (1 - p) * ((((2 : ℚ) ^ b) ^ 3) / (((2 : ℚ) ^ b) ^ 3 - 1))
        - (7 / 2) * p * (1 - p)| ≤ 2 / (((2 : ℚ) ^ b) ^ 3) := by
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 hb
    simpa using this
  set x : ℚ := ((2 : ℚ) ^ b) ^ 3 with hx
  have hx1 : (0 : ℚ) < x - 1 := by linarith
  have hxpos : (0 : ℚ) < x := by linarith
  have hC0 : (0 : ℚ) ≤ (7 / 2) * p * (1 - p) := by nlinarith
  have hC1 : (7 / 2) * p * (1 - p) ≤ 7 / 8 := by nlinarith [sq_nonneg (p - 1 / 2)]
  have hdiff : (7 / 2) * p * (1 - p) * (x / (x - 1)) - (7 / 2) * p * (1 - p)
      = ((7 / 2) * p * (1 - p)) / (x - 1) := by
    field_simp
    ring
  rw [hdiff, abs_of_nonneg (div_nonneg hC0 (le_of_lt hx1))]
  rw [div_le_div_iff₀ hx1 hxpos]
  nlinarith

end Catalog.Pythagorean.ZeroFitDialTipBlind48