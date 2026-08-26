import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48

/-!
# The resolution ladder of the zero-fit dial: how coarse may the relation rate be?

## Research context (FACT round-56 #1, exp 526, `CELL-CLOSED-DIAL-HOLDS-UNIF-48`)

`Pythagorean.ZeroFitDialRelationRate48` proved that a *two-valued* relation-rate response at
the recorded rate `12.5 %` cannot produce the recorded dial `0.7192 / 0.7202 / 0.7198` at
exact bitlen 48.  A natural objection is that the response only needs to be coarse **where
nothing happens**: a rate statistic may well be flat on the `87.5 %` of draws carrying no
relation while resolving the `12.5 %` that do.  This file closes that gap.

## Main results

* `ssR_recenter`, `ssR_affine`, `ssR_parallel` — the parallel-axis algebra of the
  between-block sum of squares.
* `covNest_eq_ssR`, `nested_spearmanSq` — **the nested-ties law**: whenever the response is
  constant on groups of consecutive tie blocks of `T` (a *coarsening*, encoded by a list of
  lists `LL`), the squared Spearman coefficient is *exactly*
  `ρ² = ssR(coarse profile) / ssR(fine profile)`.
  This one identity contains both previous ceilings: taking the fine side to be the
  tie-free ranking gives the `6/7` tie-attenuation law of `Novelty.ZeroFitDialU64`, and
  taking the coarse side to be a two-block profile gives the rate parabola of
  `Pythagorean.ZeroFitDialRelationRate48`.
* `massR_sq_le_ssR`, `ssR_coarse_le`, `spearmanSqNest_le_one` — **coarsening loses
  variance** (a Cauchy–Schwarz/parallel-axis argument block by block), hence the ladder:
  the finer the response, the higher the attainable dial, and the whole ladder is capped
  at `1`.
* `ssR_bottom_merged`, `bottom_merged_ceiling` — the exact ceiling for a response that is
  *arbitrarily fine above the boundary but blind below it*:
  `ρ² = (197·8^{b-3} - 1)/(8^b - 1) → 197/512 ≈ 0.38477`.
* `bottom_blind_response_excluded` — **the payload**.  At exact bitlen 48, *every* response
  that fails to distinguish inside the `87.5 %` no-relation bulk — no matter how finely it
  resolves the remaining `12.5 %` — has `ρ² ≤ 0.3848`, strictly below every recorded seed
  (`≈ 0.5172`).  The `12.5 %` unstarved regime therefore forces the dial's response to carry
  graded information *inside the bulk*, not only on the relation events.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48

namespace Catalog.Pythagorean.ZeroFitDialResolutionLadder48

/-! ## 1. Parallel-axis algebra for `ssR` -/

/-- `ssR` only depends on the offset through `mu - c`. -/
lemma ssR_recenter (mu mu' : ℚ) (L : List ℕ) (c c' : ℚ) (h : mu - c = mu' - c') :
    ssR mu L c = ssR mu' L c' := by
  induction L generalizing c c' with
  | nil => simp [ssR]
  | cons m L ih =>
      have h' : mu - (c + m) = mu' - (c' + m) := by linarith
      rw [ssR, ssR, ih (c + m) (c' + m) h']
      have : c + ((m : ℚ) + 1) / 2 - mu = c' + ((m : ℚ) + 1) / 2 - mu' := by linarith
      rw [this]

/-- `ssR` as a quadratic in the centring constant. -/
lemma ssR_affine (mu : ℚ) (L : List ℕ) (c : ℚ) :
    ssR mu L c = ssR 0 L c - 2 * mu * massR 0 L c + mu ^ 2 * (L.sum : ℚ) := by
  induction L generalizing c with
  | nil => simp [ssR, massR]
  | cons m L ih =>
      simp only [ssR, massR, List.sum_cons, Nat.cast_add, ih]
      ring

/-- **Parallel-axis theorem.**  Re-centring `ssR` away from the grand mean costs exactly
`n·(shift)²`. -/
lemma ssR_parallel (nu : ℚ) (L : List ℕ) :
    ssR nu L 0 = ssR (gmean L) L 0 + (L.sum : ℚ) * (nu - gmean L) ^ 2 := by
  have hM : massR 0 L 0 = (L.sum : ℚ) * gmean L := by
    rw [massR_closed, gmean]; ring
  have h1 := ssR_affine nu L 0
  have h2 := ssR_affine (gmean L) L 0
  rw [hM] at h1 h2
  rw [h1, h2]
  ring

/-- Parallel axis with an offset. -/
lemma ssR_shift_parallel (nu : ℚ) (L : List ℕ) (c : ℚ) :
    ssR nu L c = ssR (gmean L) L 0 + (L.sum : ℚ) * (nu - c - gmean L) ^ 2 := by
  rw [ssR_recenter nu (nu - c) L c 0 (by ring)]
  exact ssR_parallel (nu - c) L

/-! ## 2. Nested tie profiles: the exact law for a coarsened response -/

/-- A *nesting*: `LL` groups consecutive tie blocks of `T`; the response is constant on each
group.  Its own tie profile is the list of group totals. -/
def coarseProfile (LL : List (List ℕ)) : List ℕ := LL.map List.sum

/-- Centred cross moment `Σᵢ (Rᵢ - μ)(Sᵢ - μ)` of the midranks of `T` (profile `LL.flatten`)
against a response constant on the groups of `LL`. -/
def covNest (mu : ℚ) : List (List ℕ) → ℚ → ℚ
  | [], _ => 0
  | G :: LL, c => ((c + ((G.sum : ℚ) + 1) / 2) - mu) * massR mu G c + covNest mu LL (c + G.sum)

/-- **Midrank collapse for a coarsening.**  The centred cross moment equals the *coarse*
between-group sum of squares. -/
theorem covNest_eq_ssR (mu : ℚ) (LL : List (List ℕ)) (c : ℚ) :
    covNest mu LL c = ssR mu (coarseProfile LL) c := by
  induction LL generalizing c with
  | nil => simp [covNest, ssR, coarseProfile]
  | cons G LL ih =>
      rw [covNest, coarseProfile, List.map_cons, ssR, ← coarseProfile, ih (c + G.sum),
        massR_closed]
      ring

/-- Squared Spearman coefficient between `T` (fine profile `LL.flatten`) and a response
constant on the groups of `LL`. -/
def spearmanSqNest (LL : List (List ℕ)) : ℚ :=
  covNest (gmean LL.flatten) LL 0 ^ 2 /
    (ssR (gmean LL.flatten) LL.flatten 0 * ssR (gmean LL.flatten) (coarseProfile LL) 0)

/-- **The nested-ties law.**  For a response that coarsens the tie blocks of `T`,
`ρ² = ssR(coarse) / ssR(fine)`. -/
theorem nested_spearmanSq (LL : List (List ℕ))
    (hM : ssR (gmean LL.flatten) (coarseProfile LL) 0 ≠ 0) :
    spearmanSqNest LL
      = ssR (gmean LL.flatten) (coarseProfile LL) 0 / ssR (gmean LL.flatten) LL.flatten 0 := by
  rw [spearmanSqNest, covNest_eq_ssR]
  rw [pow_two]
  rw [mul_comm (ssR (gmean LL.flatten) LL.flatten 0)]
  rw [mul_div_mul_left _ _ hM]

/-! ## 3. Coarsening loses variance: the resolution ladder -/

/-- Cauchy–Schwarz inside a group: the squared centred mass is at most the group size times
the group's own between-block sum of squares. -/
lemma massR_sq_le_ssR (mu : ℚ) (G : List ℕ) (c : ℚ) :
    (massR mu G c) ^ 2 ≤ (G.sum : ℚ) * ssR mu G c := by
  induction G generalizing c with
  | nil => simp [massR, ssR]
  | cons m G ih =>
      have hIH := ih (c + m)
      have hm : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hs : (0 : ℚ) ≤ (G.sum : ℚ) := by positivity
      have hB : 0 ≤ ssR mu G (c + m) := ssR_nonneg mu G (c + m)
      simp only [massR, ssR, List.sum_cons, Nat.cast_add]
      set v : ℚ := c + ((m : ℚ) + 1) / 2 - mu with hv
      set A : ℚ := massR mu G (c + m) with hA
      set B : ℚ := ssR mu G (c + m) with hBdef
      set s : ℚ := (G.sum : ℚ) with hsdef
      rcases eq_or_lt_of_le hs with hs0 | hspos
      · have hA0 : A = 0 := by nlinarith
        have hmB : 0 ≤ (m : ℚ) * B := mul_nonneg hm hB
        rw [← hs0, hA0]
        nlinarith
      · have hkey : 2 * v * A ≤ s * v ^ 2 + B := by
          have h1 : 0 ≤ (s * v - A) ^ 2 := sq_nonneg _
          nlinarith
        nlinarith

/-- **Coarsening loses variance.**  Merging tie blocks can only decrease the between-block
sum of squares. -/
theorem ssR_coarse_le (mu : ℚ) (LL : List (List ℕ)) (c : ℚ) :
    ssR mu (coarseProfile LL) c ≤ ssR mu LL.flatten c := by
  induction LL generalizing c with
  | nil => simp [coarseProfile, ssR]
  | cons G LL ih =>
      have hsplit : ssR mu (G ++ LL.flatten) c = ssR mu G c + ssR mu LL.flatten (c + (G.sum : ℚ)) := by
        clear ih
        induction G generalizing c with
        | nil => simp [ssR]
        | cons m G ihG =>
            have harg : c + (m : ℚ) + (G.sum : ℚ) = c + (((m :: G).sum : ℕ) : ℚ) := by
              rw [List.sum_cons, Nat.cast_add]; ring
            rw [List.cons_append, ssR, ssR, ihG (c + m), harg]
            ring
      have hgroup : ((G.sum : ℚ)) * ((c + ((G.sum : ℚ) + 1) / 2) - mu) ^ 2 ≤ ssR mu G c := by
        rcases eq_or_lt_of_le (by positivity : (0 : ℚ) ≤ (G.sum : ℚ)) with h0 | hpos
        · have hzero : ((G.sum : ℚ)) = 0 := h0.symm
          rw [hzero]
          simpa using ssR_nonneg mu G c
        · have hCS := massR_sq_le_ssR mu G c
          rw [massR_closed] at hCS
          have hsq : ((G.sum : ℚ) * (c + ((G.sum : ℚ) + 1) / 2 - mu)) ^ 2
              = (G.sum : ℚ) ^ 2 * ((c + ((G.sum : ℚ) + 1) / 2) - mu) ^ 2 := by ring
          rw [hsq] at hCS
          nlinarith
      rw [List.flatten_cons, hsplit, coarseProfile, List.map_cons, ssR, ← coarseProfile]
      have := ih (c + (G.sum : ℚ))
      linarith

/-- The whole resolution ladder is capped at `1`. -/
theorem spearmanSqNest_le_one (LL : List (List ℕ))
    (hM : 0 < ssR (gmean LL.flatten) (coarseProfile LL) 0) : spearmanSqNest LL ≤ 1 := by
  have hfine : ssR (gmean LL.flatten) (coarseProfile LL) 0
      ≤ ssR (gmean LL.flatten) LL.flatten 0 := ssR_coarse_le _ LL 0
  rw [nested_spearmanSq LL (ne_of_gt hM)]
  rw [div_le_one (by linarith)]
  exact hfine

/-! ## 4. The bottom-blind response at exact bitlen 48 -/

/-- Dropping the first `t` blocks of the 2-adic profile leaves the 2-adic profile of bitlen
`b - t`. -/
lemma dyadic_drop_eq (b t : ℕ) (ht : t ≤ b) : (dyadicBlocks b).drop t = dyadicBlocks (b - t) := by
  induction t generalizing b with
  | zero => simp
  | succ t ih =>
      obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
      have htb : t ≤ b' := by omega
      have hd : dyadicBlocks (b' + 1) = 2 ^ b' :: dyadicBlocks b' := rfl
      have hidx : b' + 1 - (t + 1) = b' - t := by omega
      rw [hd, List.drop_succ_cons, ih b' htb, hidx]

/-- The tie profile of a *bottom-blind* response: one group for the whole no-relation bulk,
full resolution above it. -/
def bottomMergedProfile (b t : ℕ) : List ℕ :=
  ((dyadicBlocks b).take t).sum :: dyadicBlocks (b - t)

/-- Exact between-group sum of squares of the bottom-blind response at rate `1/8`. -/
theorem ssR_bottom_merged (b : ℕ) (hb : 4 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (bottomMergedProfile b 3) 0
      = 14 * ((2 : ℚ) ^ (b - 3)) ^ 3 + ((((2 : ℚ) ^ (b - 3)) ^ 3 - 1) / 14) := by
  have hb3 : 1 ≤ b - 3 := by omega
  have hpow : (2 : ℚ) ^ b = 8 * (2 : ℚ) ^ (b - 3) := by
    rw [show (8 : ℚ) = 2 ^ 3 by norm_num, ← pow_add]
    congr 1
    omega
  have hK : ((((dyadicBlocks b).take 3).sum : ℕ) : ℚ) = 7 * (2 : ℚ) ^ (b - 3) := by
    have hnat := dyadic_take_sum b 3 (by omega)
    have hq : ((((dyadicBlocks b).take 3).sum : ℕ) : ℚ) + (2 : ℚ) ^ (b - 3) = (2 : ℚ) ^ b := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ℚ)) hnat
    rw [hpow] at hq
    linarith
  have hgm : gmean (dyadicBlocks b) = ((2 : ℚ) ^ b + 1) / 2 := by
    rw [gmean, dyadicBlocks_sum]; push_cast; ring
  have hgm' : gmean (dyadicBlocks (b - 3)) = ((2 : ℚ) ^ (b - 3) + 1) / 2 := by
    rw [gmean, dyadicBlocks_sum]; push_cast; ring
  have hsum' : (((dyadicBlocks (b - 3)).sum : ℕ) : ℚ) = (2 : ℚ) ^ (b - 3) := by
    rw [dyadicBlocks_sum]; push_cast; ring
  rw [bottomMergedProfile, ssR, hK, ssR_shift_parallel, ssR_dyadic (b - 3) hb3, hgm, hgm',
    hsum', hpow]
  ring_nf

/-- **The bottom-blind ceiling.**  A response with full resolution above the `12.5 %`
boundary but no resolution at all below it attains at most
`ρ² = (197·8^{b-3} - 1)/(8^b - 1)`, which decreases to `197/512 ≈ 0.38477`. -/
theorem bottom_merged_ceiling (b : ℕ) (hb : 4 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (bottomMergedProfile b 3) 0
        / ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0
      = (197 * ((2 : ℚ) ^ (b - 3)) ^ 3 - 1) / (((2 : ℚ) ^ b) ^ 3 - 1) := by
  have hb1 : 1 ≤ b := by omega
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 hb1
    simpa using this
  rw [ssR_bottom_merged b hb, ssR_dyadic b hb1]
  rw [div_eq_div_iff (by linarith) (by linarith)]
  ring

/-- The bottom-blind profile really is a coarsening of the 2-adic profile: it is the coarse
profile of the nesting that merges the first three blocks and leaves the rest alone. -/
lemma coarseProfile_bottomMerged (b : ℕ) (hb : 3 ≤ b) :
    coarseProfile ((dyadicBlocks b).take 3 :: ((dyadicBlocks b).drop 3).map (fun m => [m]))
      = bottomMergedProfile b 3 := by
  rw [coarseProfile, List.map_cons, List.map_map, bottomMergedProfile, dyadic_drop_eq b 3 hb]
  congr 1
  have : (List.sum ∘ fun m : ℕ => [m]) = id := by funext m; simp
  rw [this, List.map_id]

/-- **The payload.**  At exact bitlen 48 every response that is blind inside the `87.5 %`
no-relation bulk — however finely it resolves the `12.5 %` of relation events — has
`ρ² ≤ (197·2¹³² - 1)/(2¹⁴¹ - 1) ≈ 0.3848`, strictly below the square of each recorded seed
`0.7192 / 0.7202 / 0.7198`.  So the recorded dial cannot be explained by *any* response,
binary or graded, whose resolution lives only on the relation events. -/
theorem bottom_blind_response_excluded (LL' : List (List ℕ))
    (hLL : LL'.flatten = (dyadicBlocks 47).drop 3) :
    spearmanSqNest ((dyadicBlocks 47).take 3 :: LL') < seedA ^ 2 ∧
    spearmanSqNest ((dyadicBlocks 47).take 3 :: LL') < seedB ^ 2 ∧
    spearmanSqNest ((dyadicBlocks 47).take 3 :: LL') < seedC ^ 2 := by
  set LL : List (List ℕ) := (dyadicBlocks 47).take 3 :: LL' with hLLdef
  have hflat : LL.flatten = dyadicBlocks 47 := by
    rw [hLLdef, List.flatten_cons, hLL, List.take_append_drop]
  have hssRpos : 0 < ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
    rw [ssR_dyadic 47 (by norm_num)]
    have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ 47) ^ 3 := by
      have := cube_two_pow_ge 47 1 (by norm_num)
      simpa using this
    linarith
  -- the coarse profile of `LL` is dominated by the bottom-merged profile
  have hcoarse : ssR (gmean (dyadicBlocks 47)) (coarseProfile LL) 0
      ≤ ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 3) 0 := by
    have hsplit : coarseProfile LL
        = ((dyadicBlocks 47).take 3).sum :: coarseProfile LL' := by
      rw [hLLdef, coarseProfile, List.map_cons, ← coarseProfile]
    rw [hsplit, bottomMergedProfile, ssR, ssR, ← dyadic_drop_eq 47 3 (by norm_num), ← hLL]
    have := ssR_coarse_le (gmean (dyadicBlocks 47)) LL'
      (0 + ((((dyadicBlocks 47).take 3).sum : ℕ) : ℚ))
    linarith
  have hle : spearmanSqNest LL
      ≤ (197 * ((2 : ℚ) ^ (47 - 3)) ^ 3 - 1) / (((2 : ℚ) ^ 47) ^ 3 - 1) := by
    rw [← bottom_merged_ceiling 47 (by norm_num)]
    rcases eq_or_lt_of_le (ssR_nonneg (gmean LL.flatten) (coarseProfile LL) 0) with hz | hpos
    · have hzero : spearmanSqNest LL = 0 := by
        rw [spearmanSqNest, covNest_eq_ssR, ← hz]
        simp
      rw [hzero]
      exact div_nonneg (ssR_nonneg _ _ _) (le_of_lt hssRpos)
    · rw [nested_spearmanSq LL (ne_of_gt hpos), hflat]
      gcongr
  have hnum : (197 * ((2 : ℚ) ^ (47 - 3)) ^ 3 - 1) / (((2 : ℚ) ^ 47) ^ 3 - 1) < 39 / 100 := by
    norm_num
  refine ⟨lt_of_le_of_lt hle (lt_trans hnum ?_), lt_of_le_of_lt hle (lt_trans hnum ?_),
    lt_of_le_of_lt hle (lt_trans hnum ?_)⟩ <;> norm_num [seedA, seedB, seedC]

/-! ## 5. How much resolution does the recorded dial force?

The same computation at a general blindness threshold `1 - 2^{-t}` gives the whole
*resolution threshold*: blindness below `75 %` is compatible with the recorded dial,
blindness below `87.5 %` is not. -/

/-- Exact between-group sum of squares of a response blind below the dyadic boundary
`1 - 2^{-t}` and fully resolving above it. -/
theorem ssR_bottom_merged_gen (b t : ℕ) (hb : t + 1 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (bottomMergedProfile b t) 0
      = ((2 : ℚ) ^ t - 1) * (2 : ℚ) ^ t / 4 * ((2 : ℚ) ^ (b - t)) ^ 3
        + ((((2 : ℚ) ^ (b - t)) ^ 3 - 1) / 14) := by
  have hbt : 1 ≤ b - t := by omega
  have hpow : (2 : ℚ) ^ b = (2 : ℚ) ^ t * (2 : ℚ) ^ (b - t) := by
    rw [← pow_add]; congr 1; omega
  have hK : ((((dyadicBlocks b).take t).sum : ℕ) : ℚ)
      = ((2 : ℚ) ^ t - 1) * (2 : ℚ) ^ (b - t) := by
    have hnat := dyadic_take_sum b t (by omega)
    have hq : ((((dyadicBlocks b).take t).sum : ℕ) : ℚ) + (2 : ℚ) ^ (b - t) = (2 : ℚ) ^ b := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ℚ)) hnat
    rw [hpow] at hq
    linarith [hq]
  have hgm : gmean (dyadicBlocks b) = ((2 : ℚ) ^ b + 1) / 2 := by
    rw [gmean, dyadicBlocks_sum]; push_cast; ring
  have hgm' : gmean (dyadicBlocks (b - t)) = ((2 : ℚ) ^ (b - t) + 1) / 2 := by
    rw [gmean, dyadicBlocks_sum]; push_cast; ring
  have hsum' : (((dyadicBlocks (b - t)).sum : ℕ) : ℚ) = (2 : ℚ) ^ (b - t) := by
    rw [dyadicBlocks_sum]; push_cast; ring
  rw [bottomMergedProfile, ssR, hK, ssR_shift_parallel, ssR_dyadic (b - t) hbt, hgm, hgm',
    hsum', hpow]
  ring_nf

/-- **The blindness ceiling.**  A response blind below the dyadic boundary `1 - 2^{-t}`
attains at most `ρ² = ((7/2)(2^t-1)2^t·8^{b-t} + 8^{b-t} - 1)/(8^b - 1)`. -/
theorem bottom_merged_ceiling_gen (b t : ℕ) (hb : t + 1 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (bottomMergedProfile b t) 0
        / ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0
      = ((7 / 2) * ((2 : ℚ) ^ t - 1) * (2 : ℚ) ^ t * ((2 : ℚ) ^ (b - t)) ^ 3
          + ((2 : ℚ) ^ (b - t)) ^ 3 - 1) / (((2 : ℚ) ^ b) ^ 3 - 1) := by
  have hb1 : 1 ≤ b := by omega
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 hb1
    simpa using this
  rw [ssR_bottom_merged_gen b t hb, ssR_dyadic b hb1]
  rw [div_eq_div_iff (by linarith) (by linarith)]
  ring

/-- Blindness below `1 - 2^{-t}` with `t ≥ 3` is incompatible with the recorded dial. -/
theorem blindness_ceiling_small (b t : ℕ) (ht : 3 ≤ t) (hb : t + 1 ≤ b) :
    ((7 / 2) * ((2 : ℚ) ^ t - 1) * (2 : ℚ) ^ t * ((2 : ℚ) ^ (b - t)) ^ 3
        + ((2 : ℚ) ^ (b - t)) ^ 3 - 1) / (((2 : ℚ) ^ b) ^ 3 - 1) < 45 / 100 := by
  have hbt : 1 ≤ b - t := by omega
  have hu : (8 : ℚ) ≤ (2 : ℚ) ^ t := by
    calc (8 : ℚ) = 2 ^ 3 := by norm_num
      _ ≤ 2 ^ t := two_pow_ge t 3 ht
  have hy : (8 : ℚ) ≤ ((2 : ℚ) ^ (b - t)) ^ 3 := by
    have := cube_two_pow_ge (b - t) 1 hbt
    simpa using this
  have hcube : ((2 : ℚ) ^ b) ^ 3 = ((2 : ℚ) ^ t) ^ 3 * ((2 : ℚ) ^ (b - t)) ^ 3 := by
    rw [← mul_pow, ← pow_add]
    congr 2
    omega
  have hu3 : (512 : ℚ) ≤ ((2 : ℚ) ^ t) ^ 3 := by
    have := cube_two_pow_ge t 3 ht
    norm_num at this ⊢
    linarith
  set u : ℚ := (2 : ℚ) ^ t with hudef
  set y : ℚ := ((2 : ℚ) ^ (b - t)) ^ 3 with hydef
  have hden : (0 : ℚ) < u ^ 3 * y - 1 := by nlinarith [hu3, hy]
  rw [hcube, div_lt_div_iff₀ hden (by norm_num)]
  nlinarith [hu, hy, sq_nonneg (u - 8), mul_pos (by linarith : (0:ℚ) < u) (by linarith : (0:ℚ) < y)]

/-- **The resolution threshold at exact bitlen 48.**  Blindness inside the bottom `87.5 %`
(or any deeper dyadic bulk) is excluded by the recorded dial, while blindness inside the
bottom `75 %` is still compatible with it.  The response must therefore separate the
2-adic valuation class `v₂ = 2` from the classes below it. -/
theorem resolution_threshold_at_bitlen48 :
    (∀ t : ℕ, 3 ≤ t → t + 1 ≤ 47 →
      ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 t) 0
        / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 < seedA ^ 2) ∧
    seedA ^ 2 < ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 2) 0
        / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
  constructor
  · intro t ht htb
    rw [bottom_merged_ceiling_gen 47 t htb]
    have h := blindness_ceiling_small 47 t ht htb
    have hs : (45 : ℚ) / 100 < seedA ^ 2 := by norm_num [seedA]
    linarith
  · rw [bottom_merged_ceiling_gen 47 2 (by norm_num)]
    norm_num [seedA]

/-- **Bulk-blind responses are excluded at every dyadic depth `t ≥ 3`.**  Generalises
`bottom_blind_response_excluded`. -/
theorem bulk_blind_response_excluded (t : ℕ) (ht : 3 ≤ t) (htb : t + 1 ≤ 47)
    (LL' : List (List ℕ)) (hLL : LL'.flatten = (dyadicBlocks 47).drop t) :
    spearmanSqNest ((dyadicBlocks 47).take t :: LL') < seedA ^ 2 := by
  set LL : List (List ℕ) := (dyadicBlocks 47).take t :: LL' with hLLdef
  have hflat : LL.flatten = dyadicBlocks 47 := by
    rw [hLLdef, List.flatten_cons, hLL, List.take_append_drop]
  have hssRpos : 0 < ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
    rw [ssR_dyadic 47 (by norm_num)]
    have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ 47) ^ 3 := by
      have := cube_two_pow_ge 47 1 (by norm_num)
      simpa using this
    linarith
  have hcoarse : ssR (gmean (dyadicBlocks 47)) (coarseProfile LL) 0
      ≤ ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 t) 0 := by
    have hsplit : coarseProfile LL = ((dyadicBlocks 47).take t).sum :: coarseProfile LL' := by
      rw [hLLdef, coarseProfile, List.map_cons, ← coarseProfile]
    rw [hsplit, bottomMergedProfile, ssR, ssR, ← dyadic_drop_eq 47 t (by omega), ← hLL]
    have := ssR_coarse_le (gmean (dyadicBlocks 47)) LL'
      (0 + ((((dyadicBlocks 47).take t).sum : ℕ) : ℚ))
    linarith
  have hle : spearmanSqNest LL
      ≤ ssR (gmean (dyadicBlocks 47)) (bottomMergedProfile 47 t) 0
          / ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
    rcases eq_or_lt_of_le (ssR_nonneg (gmean LL.flatten) (coarseProfile LL) 0) with hz | hpos
    · have hzero : spearmanSqNest LL = 0 := by
        rw [spearmanSqNest, covNest_eq_ssR, ← hz]
        simp
      rw [hzero]
      exact div_nonneg (ssR_nonneg _ _ _) (le_of_lt hssRpos)
    · rw [nested_spearmanSq LL (ne_of_gt hpos), hflat]
      gcongr
  exact lt_of_le_of_lt hle (resolution_threshold_at_bitlen48.1 t ht htb)

end Catalog.Pythagorean.ZeroFitDialResolutionLadder48