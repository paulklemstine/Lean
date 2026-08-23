import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import MachineLearning.ZeroFitDialResolution

/-!
# The deployment envelope: dominant blocks cap the dial, and the cap is shift-stable

## Research context (FACT round-58 #1, exp 528, `CELL-CLOSED-DIAL-HOLDS-UNIF-52`)

Round 58 records that the zero-fit dial "survives uniform draws at bitlen 52", so that its
*deployment envelope* now covers balanced **and** uniform draws through bitlen 52.  A
deployment envelope is a robustness claim: the dial keeps reading inside `[0.55, 0.85]`
when the draw law changes.  `Novelty.ZeroFitDialU64` fixes the ceiling for the *exact*
uniform law, and `MachineLearning.ZeroFitDialResolution` bounds ceilings from above in
terms of the number of distinct values.  Neither says what happens when the draw law
*moves*.

This file proves the two facts an envelope claim needs.

## Main results

* `tieCorr_ge_of_mem`, `dominant_block_upper` — the **dominant-block upper law**: a single
  tie class of size `M` already caps the ceiling at `ρ² ≤ 1 - (M³-M)/(n³-n)`.  (This is the
  exact converse of the dominant-block *lower* law of `Novelty.ZeroFitDialMaxBlock`.)
* `half_mass_ceiling` — if the modal value of the statistic carries at least half the mass —
  which holds for the trailing-zero dial under *any* draw law with `P(odd) ≥ 1/2` — then
  `ρ² ≤ 7/8 + 7/(8(n²-1))`, hence `ρ ≤ 0.936`.
* `dyadic_half_mass`, `envelope_reading_cap` — the dial at bitlen 52 is such a statistic,
  so a recorded reading above `0.936` would falsify the half-mass model outright; the whole
  validation band `[0.55, 0.85]` lies safely below the cap.
* `cubeSum_lipschitz`, `ceiling_stability`, `ceiling_tv_stability` — the **envelope
  stability law**: two draw laws whose tie profiles are within total-variation distance `τ`
  have ceilings within `7τ` of each other.
* `unif52_envelope` — the payoff: *every* draw law whose 52-bit trailing-zero profile is
  within total variation `1/100` of the uniform one still has ceiling above `0.78`, hence
  strictly above all three recorded seed readings squared.  The recorded band membership is
  therefore not a knife-edge property of the exact uniform law.

## The scientific payload

The envelope claim of round 58 is, mathematically, a statement that the tie ceiling is
*Lipschitz in the draw law* (`ceiling_tv_stability`, constant `7`) while being *capped away
from one* by the dominant 2-adic block (`half_mass_ceiling`, cap `≈ 0.936`).  Both bounds
are distribution-free: they hold for balanced draws, uniform draws, and anything in between,
which is exactly the envelope the experiment claims to have extended.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.MachineLearning.ZeroFitDialUnif52

open Catalog.MachineLearning.ZeroFitDialResolution

namespace Catalog.MachineLearning.ZeroFitDialEnvelope

/-! ## 1. The dominant-block upper law -/

/-- Every block size is at most the total mass. -/
lemma le_sum_of_mem {L : List ℕ} {M : ℕ} (hM : M ∈ L) : M ≤ L.sum := by
  induction L with
  | nil => simp at hM
  | cons a L ih =>
      rcases List.mem_cons.1 hM with rfl | hM'
      · simp
      · have := ih hM'
        simp only [List.sum_cons]
        omega

/-- The tie correction dominates the contribution of any single block. -/
theorem tieCorr_ge_of_mem {L : List ℕ} {M : ℕ} (hM : M ∈ L) :
    ((M : ℚ) ^ 3 - M) / 12 ≤ tieCorr L := by
  induction L with
  | nil => simp at hM
  | cons a L ih =>
      rw [tieCorr_cons]
      rcases List.mem_cons.1 hM with rfl | hM'
      · have := tieCorr_nonneg L
        linarith
      · have h1 := ih hM'
        have h2 := tieCorr_term_nonneg a
        linarith

/-- **Dominant-block upper law.**  One tie class of size `M` caps the ceiling:
`ρ² ≤ 1 - (M³-M)/(n³-n)`.  No hypothesis on the rest of the profile. -/
theorem dominant_block_upper (L : List ℕ) (M : ℕ) (hM : M ∈ L) (h : 2 ≤ L.sum) :
    spearmanSq L ≤ 1 - ((M : ℚ) ^ 3 - M) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hgt := tieCorr_ge_of_mem hM
  rw [spearmanSq_eq L h]
  have : ((M : ℚ) ^ 3 - M) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      ≤ 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    gcongr
    linarith
  linarith

/-- **Half-mass cap.**  If some value of the statistic is taken by at least half the sample,
the ceiling cannot exceed `7/8 + 7/(8(n²-1))`, whatever the rest of the profile looks like. -/
theorem half_mass_ceiling (L : List ℕ) (M : ℕ) (hM : M ∈ L) (h : 2 ≤ L.sum)
    (hhalf : (L.sum : ℚ) ≤ 2 * (M : ℚ)) :
    spearmanSq L ≤ 7 / 8 + 7 / (8 * ((L.sum : ℚ) ^ 2 - 1)) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hMn : (M : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast le_sum_of_mem hM
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hup := dominant_block_upper L M hM h
  have hsq : (0 : ℚ) < (L.sum : ℚ) ^ 2 - 1 := by nlinarith
  -- `M³ - M ≥ n³/8 - n`, so the deficit is at least `1/8 - 7/(8(n²-1))`
  have hcube : ((L.sum : ℚ)) ^ 3 / 8 - (L.sum : ℚ) ≤ (M : ℚ) ^ 3 - (M : ℚ) := by
    have hcubemono : ((L.sum : ℚ)) ^ 3 ≤ (2 * (M : ℚ)) ^ 3 :=
      pow_le_pow_left₀ (by linarith) hhalf 3
    have h8 : ((L.sum : ℚ)) ^ 3 / 8 ≤ (M : ℚ) ^ 3 := by nlinarith
    linarith
  have hfrac : (1 : ℚ) / 8 - 7 / (8 * ((L.sum : ℚ) ^ 2 - 1))
      ≤ ((M : ℚ) ^ 3 - M) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [le_div_iff₀ hden]
    have hid : ((1 : ℚ) / 8 - 7 / (8 * ((L.sum : ℚ) ^ 2 - 1))) * ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
        = ((L.sum : ℚ)) ^ 3 / 8 - (L.sum : ℚ) := by
      field_simp
      ring
    linarith
  linarith

/-! ## 2. The dial at bitlen 52 is a half-mass statistic -/

lemma dyadic_head_mem (b : ℕ) : 2 ^ b ∈ dyadicBlocks (b + 1) := by
  rw [dyadicBlocks]
  exact List.mem_cons_self ..

/-- The trailing-zero statistic on `b`-bit words is half-mass: the odd residues form a
single tie class of size `2^(b-1) = n/2`. -/
theorem dyadic_half_mass (b : ℕ) :
    2 ^ b ∈ dyadicBlocks (b + 1) ∧ (((dyadicBlocks (b + 1)).sum : ℚ)) = 2 * (2 : ℚ) ^ b := by
  refine ⟨dyadic_head_mem b, ?_⟩
  rw [dyadicBlocks_sum]
  push_cast
  ring

/-- **Envelope cap for the recorded measurement.**  Any half-mass statistic on at least `1024`
points — in particular the 52-bit trailing-zero dial, whose odd class has mass `n/2` — reads at
most `0.936`; the validation band `[0.55, 0.85]` lies strictly inside the cap, and a reading
above `0.936` would refute the half-mass (dominant-odd-class) model. -/
theorem envelope_reading_cap (L : List ℕ) (M : ℕ) (hM : M ∈ L) (h : 2 ≤ L.sum)
    (hbig : (1024 : ℚ) ≤ (L.sum : ℚ)) (hhalf : (L.sum : ℚ) ≤ 2 * (M : ℚ)) :
    spearman L ≤ 936 / 1000 := by
  have hcap := half_mass_ceiling L M hM h hhalf
  have hsq : (0 : ℚ) < (L.sum : ℚ) ^ 2 - 1 := by nlinarith
  have hsmall : 7 / (8 * ((L.sum : ℚ) ^ 2 - 1)) ≤ 1 / 1000000 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    nlinarith
  have hq : spearmanSq L ≤ (936 / 1000 : ℚ) ^ 2 := by
    have : (7 : ℚ) / 8 + 1 / 1000000 ≤ (936 / 1000 : ℚ) ^ 2 := by norm_num
    linarith
  rw [spearman_eq_sqrt L h]
  have hr : ((spearmanSq L : ℚ) : ℝ) ≤ ((936 : ℝ) / 1000) ^ 2 := by
    have hcast := (Rat.cast_le (K := ℝ)).2 hq
    push_cast at hcast
    exact hcast
  calc Real.sqrt ((spearmanSq L : ℚ) : ℝ) ≤ Real.sqrt (((936 : ℝ) / 1000) ^ 2) :=
        Real.sqrt_le_sqrt hr
    _ = 936 / 1000 := Real.sqrt_sq (by norm_num)

/-- The cap applied to the recorded configuration: the 52-bit trailing-zero dial can never
read above `0.936`, so the whole validation band `[0.55, 0.85]` — and every recorded seed —
lies strictly inside the half-mass cap. -/
theorem dial52_reading_cap : spearman (dyadicBlocks 52) ≤ 936 / 1000 := by
  obtain ⟨hmem, hmass⟩ := dyadic_half_mass 51
  have h51 : (51 : ℕ) + 1 = 52 := by norm_num
  rw [h51] at hmem hmass
  have hsum : ((dyadicBlocks 52).sum : ℕ) = 2 ^ 52 := dyadicBlocks_sum 52
  have h2 : 2 ≤ (dyadicBlocks 52).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ 52 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
  have hbig : (1024 : ℚ) ≤ (((dyadicBlocks 52).sum : ℕ) : ℚ) := by
    rw [hsum]
    push_cast
    calc (1024 : ℚ) = 2 ^ 10 := by norm_num
      _ ≤ 2 ^ 52 := by apply pow_le_pow_right₀ (by norm_num) (by norm_num)
  exact envelope_reading_cap (dyadicBlocks 52) (2 ^ 51) hmem h2 hbig
    (by rw [hmass]; push_cast; norm_num)

/-! ## 3. Stability of the ceiling under a shift of the draw law -/

/-- `ℓ¹` distance between two tie profiles listed in the same order. -/
def l1dist : List ℕ → List ℕ → ℚ
  | [], _ => 0
  | _, [] => 0
  | a :: L, b :: M => |(a : ℚ) - (b : ℚ)| + l1dist L M

lemma l1dist_nonneg (L L' : List ℕ) : 0 ≤ l1dist L L' := by
  induction L generalizing L' with
  | nil => simp [l1dist]
  | cons a L ih =>
      cases L' with
      | nil => simp [l1dist]
      | cons b L' =>
          have := ih L'
          have habs : (0 : ℚ) ≤ |(a : ℚ) - (b : ℚ)| := abs_nonneg _
          rw [l1dist]
          linarith

/-- **Lipschitz bound for the cube sum.**  If all blocks of both profiles are bounded by `N`,
the cube sums differ by at most `3N²` times the `ℓ¹` distance of the profiles. -/
theorem cubeSum_lipschitz (L L' : List ℕ) (N : ℕ) (hL : ∀ m ∈ L, m ≤ N) (hL' : ∀ m ∈ L', m ≤ N)
    (hlen : L.length = L'.length) :
    |cubeSum L - cubeSum L'| ≤ 3 * (N : ℚ) ^ 2 * l1dist L L' := by
  induction L generalizing L' with
  | nil =>
      have : L' = [] := List.length_eq_zero_iff.1 hlen.symm
      subst this
      simp [cubeSum, l1dist]
  | cons a L ih =>
      cases L' with
      | nil => simp at hlen
      | cons b L' =>
          have hlen' : L.length = L'.length := by simpa using hlen
          have hLa : a ≤ N := hL a (List.mem_cons_self ..)
          have hLb : b ≤ N := hL' b (List.mem_cons_self ..)
          have hrest := ih L' (fun m hm => hL m (List.mem_cons_of_mem _ hm))
            (fun m hm => hL' m (List.mem_cons_of_mem _ hm)) hlen'
          have hcs : cubeSum (a :: L) - cubeSum (b :: L')
              = ((a : ℚ) ^ 3 - (b : ℚ) ^ 3) + (cubeSum L - cubeSum L') := by
            simp only [cubeSum]
            ring
          have hterm : |(a : ℚ) ^ 3 - (b : ℚ) ^ 3| ≤ 3 * (N : ℚ) ^ 2 * |(a : ℚ) - (b : ℚ)| := by
            have hfac : (a : ℚ) ^ 3 - (b : ℚ) ^ 3
                = ((a : ℚ) - b) * ((a : ℚ) ^ 2 + (a : ℚ) * b + (b : ℚ) ^ 2) := by ring
            have haN : (a : ℚ) ≤ (N : ℚ) := by exact_mod_cast hLa
            have hbN : (b : ℚ) ≤ (N : ℚ) := by exact_mod_cast hLb
            have ha0 : (0 : ℚ) ≤ (a : ℚ) := by positivity
            have hb0 : (0 : ℚ) ≤ (b : ℚ) := by positivity
            have hbound : |(a : ℚ) ^ 2 + (a : ℚ) * b + (b : ℚ) ^ 2| ≤ 3 * (N : ℚ) ^ 2 := by
              rw [abs_of_nonneg (by positivity)]
              nlinarith
            calc |(a : ℚ) ^ 3 - (b : ℚ) ^ 3|
                = |(a : ℚ) - b| * |(a : ℚ) ^ 2 + (a : ℚ) * b + (b : ℚ) ^ 2| := by
                  rw [hfac, abs_mul]
              _ ≤ |(a : ℚ) - b| * (3 * (N : ℚ) ^ 2) := by
                  exact mul_le_mul_of_nonneg_left hbound (abs_nonneg _)
              _ = 3 * (N : ℚ) ^ 2 * |(a : ℚ) - b| := by ring
          calc |cubeSum (a :: L) - cubeSum (b :: L')|
              ≤ |(a : ℚ) ^ 3 - (b : ℚ) ^ 3| + |cubeSum L - cubeSum L'| := by
                rw [hcs]; exact abs_add_le _ _
            _ ≤ 3 * (N : ℚ) ^ 2 * |(a : ℚ) - (b : ℚ)| + 3 * (N : ℚ) ^ 2 * l1dist L L' := by
                linarith
            _ = 3 * (N : ℚ) ^ 2 * l1dist (a :: L) (b :: L') := by rw [l1dist]; ring

/-- **Envelope stability law.**  Two tie profiles of the same length and the same total mass
have ceilings differing by at most `3n²·‖L - L'‖₁/(n³-n)`. -/
theorem ceiling_stability (L L' : List ℕ) (hlen : L.length = L'.length)
    (hsum : L.sum = L'.sum) (h : 2 ≤ L.sum) :
    |spearmanSq L - spearmanSq L'|
      ≤ 3 * ((L.sum : ℚ)) ^ 2 * l1dist L L' / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have h' : 2 ≤ L'.sum := hsum ▸ h
  have hcubeL : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := twelve_tieCorr_eq L
  have hcubeL' : 12 * tieCorr L' = cubeSum L' - (L'.sum : ℚ) := twelve_tieCorr_eq L'
  have hsq : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  have hlip : |cubeSum L - cubeSum L'| ≤ 3 * ((L.sum : ℚ)) ^ 2 * l1dist L L' :=
    cubeSum_lipschitz L L' L.sum (fun m hm => le_sum_of_mem hm)
      (fun m hm => by rw [hsum]; exact le_sum_of_mem hm) hlen
  have hdiff : spearmanSq L - spearmanSq L'
      = (cubeSum L' - cubeSum L) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [spearmanSq_eq L h, spearmanSq_eq L' h', hcubeL, hcubeL', hsq]
    field_simp
    ring
  rw [hdiff, abs_div, abs_of_pos hden, div_le_div_iff₀ hden hden]
  have habs : |cubeSum L' - cubeSum L| = |cubeSum L - cubeSum L'| := abs_sub_comm _ _
  rw [habs]
  have h3 : 0 < 3 * ((L.sum : ℚ)) ^ 2 * l1dist L L' + 1 := by
    have := l1dist_nonneg L L'
    positivity
  nlinarith [hlip, hden]

/-- **Total-variation form.**  If the two draw laws are within total variation `τ`, i.e. their
profiles differ by at most `2τn` in `ℓ¹`, their tie ceilings differ by at most `7τ`. -/
theorem ceiling_tv_stability (L L' : List ℕ) (tau : ℚ) (htau : 0 ≤ tau)
    (hlen : L.length = L'.length) (hsum : L.sum = L'.sum) (h : 3 ≤ L.sum)
    (htv : l1dist L L' ≤ 2 * tau * (L.sum : ℚ)) :
    |spearmanSq L - spearmanSq L'| ≤ 7 * tau := by
  have h2 : 2 ≤ L.sum := by omega
  have hn : (3 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos (by linarith)
  have hst := ceiling_stability L L' hlen hsum h2
  have hbound : 3 * ((L.sum : ℚ)) ^ 2 * l1dist L L' / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) ≤ 7 * tau := by
    rw [div_le_iff₀ hden]
    have hmul : 3 * ((L.sum : ℚ)) ^ 2 * l1dist L L'
        ≤ 3 * ((L.sum : ℚ)) ^ 2 * (2 * tau * (L.sum : ℚ)) := by
      have : (0 : ℚ) ≤ 3 * ((L.sum : ℚ)) ^ 2 := by positivity
      exact mul_le_mul_of_nonneg_left htv this
    have hcubepos : (0 : ℚ) ≤ (L.sum : ℚ) ^ 3 - 7 * (L.sum : ℚ) := by nlinarith
    nlinarith [mul_nonneg htau hcubepos]
  linarith

/-! ## 4. The recorded envelope at bitlen 52 -/

lemma dyadic52_sum : ((dyadicBlocks 52).sum : ℕ) = 2 ^ 52 := dyadicBlocks_sum 52

/-- **The deployment envelope at bitlen 52.**  Every draw law whose trailing-zero tie profile
is within total variation `1/100` of the uniform one still has tie ceiling above `0.78`, hence
strictly above the square of every recorded seed reading.  Band membership at bitlen 52 is
therefore robust to a `1%` shift of the draw law, not a knife-edge property of exact
uniformity. -/
theorem unif52_envelope (L' : List ℕ) (hlen : (dyadicBlocks 52).length = L'.length)
    (hsum : (dyadicBlocks 52).sum = L'.sum)
    (htv : l1dist (dyadicBlocks 52) L' ≤ 2 * (1 / 100) * (((dyadicBlocks 52).sum : ℕ) : ℚ)) :
    (78 / 100 : ℚ) < spearmanSq L' ∧ seed22 ^ 2 < spearmanSq L' := by
  have h3 : 3 ≤ (dyadicBlocks 52).sum := by
    rw [dyadic52_sum]
    calc 3 ≤ 2 ^ 2 := by norm_num
      _ ≤ 2 ^ 52 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
  have hstab := ceiling_tv_stability (dyadicBlocks 52) L' (1 / 100) (by norm_num) hlen hsum h3 htv
  have hexact : spearmanSq (dyadicBlocks 52)
      = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1))) := dyadic_spearmanSq 52 (by norm_num)
  have hpos : (0 : ℚ) < 1 / ((2 : ℚ) ^ 52 * (2 ^ 52 + 1)) := by positivity
  have hlow : (6 : ℚ) / 7 ≤ spearmanSq (dyadicBlocks 52) := by
    rw [hexact]; nlinarith
  have habs : spearmanSq (dyadicBlocks 52) - spearmanSq L' ≤ 7 * (1 / 100) :=
    (abs_le.1 hstab).2
  have hmain : (78 / 100 : ℚ) < spearmanSq L' := by linarith
  exact ⟨hmain, by rw [seed22]; nlinarith⟩

end Catalog.MachineLearning.ZeroFitDialEnvelope