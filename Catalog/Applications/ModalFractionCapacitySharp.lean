import Mathlib
import Applications.ModalFractionCapacity

/-!
# Sharpening the law-change budget, and the half-modal capacity theorem

`Applications.ModalFractionCapacity` established that the conjectured budget
`|Δρ| ≤ |Δa| + O(1/n)` is false and replaced it by `|Δρ| ≤ |Δa| + C` with
`1/2 < C ≤ 109/200`.  This file is the second research cycle on the same thread.  It

* sharpens the bracket to `51/100 < C ≤ 21/40` (i.e. `0.510 < C ≤ 0.525`), by keeping the
  square root instead of linearising it (`spearman_le_of_modal_sharp`,
  `spearman_modal_budget_sharp`, `budget_constant_gt_fiftyone`, `budget_bracket_sharp`);
* proves the **half-modal capacity theorem** (`half_modal_capacity`): *any* two draw laws whose
  modal class carries exactly half the sample have tie ceilings within `0.07` of each other —
  and `> 1/20` is attainable (`half_modal_capacity_sharp`).  This is the structural explanation
  of the `< 0.07` balanced-versus-uniform movement recorded in
  `Cryptography.BalancedBKeyFixedWeight.law_change_capacity`: both laws are half-modal, and
  half-modality alone forces the movement into `(0.05, 0.07]`;
* derives that recorded capacity from the general theorem
  (`catalog_capacity_from_half_modality`), using a central-binomial size bound.

## Why the constants are what they are

The exact envelope for a profile of modal fraction `a` is
`√(1 - a²) ≤ ρ ≤ √(1 - a³) + O(1/n²)`.  Hence:

* equal modal fractions still allow a movement of `√(1-a³) - √(1-a²)`, maximal `≈ 0.0987`
  near `a ≈ 0.79`, and equal to `√(7/8) - √(3/4) ≈ 0.0694` at `a = 1/2`;
* across different modal fractions the extra slack is
  `maxₐ (√(1-a³) - 1 + a) ≈ 0.5103` (at `a ≈ 0.7286`, against a fully tied second law), which
  is why no additive constant below `0.51` can work and `21/40` does.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialResolution
open Catalog.Cryptography.BalancedBKeyFixedWeight
open Catalog.Applications.ModalFractionCapacity

namespace Catalog.Applications.ModalFractionCapacitySharp

/-! ## 1. The sharp upper budget: keep the square root -/

/-- The cubic certificate behind the sharp constant: `1 - a³ ≤ (21/40 + 1 - a)²` on `[0,1]`.
The margin is only `≈ 0.021`, attained near `a ≈ 0.7286`; this is what pins the optimal
additive constant to `≈ 0.5103`. -/
lemma poly_budget_bound {a : ℝ} (ha0 : 0 ≤ a) :
    1 - a ^ 3 ≤ (21 / 40 + 1 - a) ^ 2 := by
  nlinarith [mul_nonneg (sq_nonneg (a - 73 / 100)) (by linarith : (0 : ℝ) ≤ a + 5 / 2),
    sq_nonneg (a - 73 / 100), ha0]

/-- **Sharp upper half of the budget.**  `ρ ≤ (1 - a) + 21/40 + 1/(n²-1)`. -/
theorem spearman_le_of_modal_sharp (L : List ℕ) (h : 2 ≤ L.sum) :
    spearman L ≤ 1 - ((modalFrac L : ℚ) : ℝ) + 21 / 40 + 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, L.sum = N := ⟨_, rfl⟩
  have hN2 : 2 ≤ N := hN ▸ h
  have hNR : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN2
  have hsq : (0 : ℝ) < (N : ℝ) ^ 2 - 1 := by nlinarith
  have he0 : (0 : ℝ) ≤ 1 / ((N : ℝ) ^ 2 - 1) := le_of_lt (div_pos one_pos hsq)
  have hQ := modal_fraction_cap L h
  rw [hN] at hQ
  have ha0 : (0 : ℝ) ≤ ((modalFrac L : ℚ) : ℝ) := by exact_mod_cast modalFrac_nonneg L
  have ha1 : ((modalFrac L : ℚ) : ℝ) ≤ 1 := by exact_mod_cast modalFrac_le_one h
  have hcast : ((spearmanSq L : ℚ) : ℝ)
      ≤ 1 - ((modalFrac L : ℚ) : ℝ) ^ 3 + 1 / ((N : ℝ) ^ 2 - 1) := by
    have hc := (Rat.cast_le (K := ℝ)).2 hQ
    push_cast at hc
    linarith
  rw [hN, spearman_eq_sqrt L h]
  set a : ℝ := ((modalFrac L : ℚ) : ℝ) with ha
  set e : ℝ := 1 / ((N : ℝ) ^ 2 - 1) with he
  have hpoly := poly_budget_bound ha0
  have hX : (1 : ℝ) / 2 ≤ 21 / 40 + 1 - a := by linarith
  have hy0 : (0 : ℝ) ≤ 21 / 40 + 1 - a + e := by linarith
  have hys : ((spearmanSq L : ℚ) : ℝ) ≤ (21 / 40 + 1 - a + e) ^ 2 := by
    nlinarith [sq_nonneg e, mul_nonneg he0 (by linarith : (0 : ℝ) ≤ 21 / 40 + 1 - a)]
  calc Real.sqrt ((spearmanSq L : ℚ) : ℝ) ≤ Real.sqrt ((21 / 40 + 1 - a + e) ^ 2) :=
        Real.sqrt_le_sqrt hys
    _ = 21 / 40 + 1 - a + e := Real.sqrt_sq hy0
    _ = 1 - a + 21 / 40 + e := by ring

/-- **The sharp universal law-change budget**: `|Δρ| ≤ |Δa| + 21/40 + O(1/n²) + O(1/n'²)`. -/
theorem spearman_modal_budget_sharp (L L' : List ℕ) (h : 2 ≤ L.sum) (h' : 2 ≤ L'.sum) :
    |spearman L - spearman L'|
      ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 21 / 40
        + 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) + 1 / (((L'.sum : ℕ) : ℝ) ^ 2 - 1) := by
  have hup := spearman_le_of_modal_sharp L h
  have hlo := spearman_ge_of_modal L h
  have hup' := spearman_le_of_modal_sharp L' h'
  have hlo' := spearman_ge_of_modal L' h'
  have he := eps_nonneg h
  have he' := eps_nonneg h'
  set a : ℝ := ((modalFrac L : ℚ) : ℝ) with ha
  set a' : ℝ := ((modalFrac L' : ℚ) : ℝ) with ha'
  have hda : a - a' ≤ |a - a'| := le_abs_self _
  have hda' : a' - a ≤ |a - a'| := by
    rw [abs_sub_comm]; exact le_abs_self _
  rw [abs_le]
  constructor <;> linarith

/-- **Response-effect test, sharp form.**  For samples of at least `100` points,
`|Δρ| ≤ |Δa| + 0.53`.  A recorded law-to-law movement above this is provably not a tie
effect. -/
theorem response_effect_threshold_sharp (L L' : List ℕ) (hn : 100 ≤ L.sum) (hn' : 100 ≤ L'.sum) :
    |spearman L - spearman L'|
      ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 53 / 100 := by
  have h : 2 ≤ L.sum := by omega
  have h' : 2 ≤ L'.sum := by omega
  have hnR : (100 : ℝ) ≤ ((L.sum : ℕ) : ℝ) := by exact_mod_cast hn
  have hnR' : (100 : ℝ) ≤ ((L'.sum : ℕ) : ℝ) := by exact_mod_cast hn'
  have hb := spearman_modal_budget_sharp L L' h h'
  have hsmall : 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) ≤ 1 / 9999 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  have hsmall' : 1 / (((L'.sum : ℕ) : ℝ) ^ 2 - 1) ≤ 1 / 9999 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  linarith

/-! ## 2. The sharp lower bound on the constant -/

lemma dominantProfile_spearmanSq_sharp {k : ℕ} (hk : 1 ≤ k) :
    361 / 625 < spearmanSq (dominantProfile k) := by
  have h2 : 2 ≤ (dominantProfile k).sum := by
    rw [dominantProfile_sum]; omega
  have hkQ : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have hk2 : (1 : ℚ) ≤ (k : ℚ) ^ 2 := by nlinarith
  have hk3 : (k : ℚ) ≤ (k : ℚ) ^ 3 := by nlinarith
  have hden : (0 : ℚ) < (4 * (k : ℚ)) ^ 3 - 4 * (k : ℚ) := by nlinarith
  rw [spearmanSq_eq_cube_ratio _ h2, dominantProfile_cubeSum, dominantProfile_sum]
  push_cast
  rw [lt_div_iff₀ (by nlinarith)]
  nlinarith

/-- **The optimal budget constant exceeds `0.51`.**  The dominant/tied pair has modal-fraction
gap `1/4` and ceiling gap `> 0.76`. -/
theorem dominant_tied_excess_sharp {k : ℕ} (hk : 1 ≤ k) :
    |((modalFrac (dominantProfile k) : ℚ) : ℝ) - ((modalFrac (tiedProfile k) : ℚ) : ℝ)|
        + 51 / 100
      < |spearman (dominantProfile k) - spearman (tiedProfile k)| := by
  have h2 : 2 ≤ (dominantProfile k).sum := by
    rw [dominantProfile_sum]; omega
  have hdom : (19 : ℝ) / 25 < spearman (dominantProfile k) := by
    rw [spearman_eq_sqrt _ h2, Real.lt_sqrt (by norm_num)]
    have hc := (Rat.cast_lt (K := ℝ)).2 (dominantProfile_spearmanSq_sharp hk)
    push_cast at hc
    nlinarith
  have htied : spearman (tiedProfile k) = 0 := tiedProfile_spearman hk
  have hgap : |((modalFrac (dominantProfile k) : ℚ) : ℝ) - ((modalFrac (tiedProfile k) : ℚ) : ℝ)|
      = 1 / 4 := by
    rw [dominantProfile_modalFrac hk, tiedProfile_modalFrac hk]
    push_cast
    rw [abs_sub_comm, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 1 - 3 / 4)]
    norm_num
  rw [hgap, htied, sub_zero, abs_of_pos (by linarith)]
  linarith

/-- Any universal additive budget constant is larger than `51/100`. -/
theorem budget_constant_gt_fiftyone (C : ℝ)
    (hC : ∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum →
      |spearman L - spearman L'|
        ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + C) : 51 / 100 < C := by
  have h1 : 2 ≤ (dominantProfile 1).sum := by
    rw [dominantProfile_sum]; omega
  have h2 : 2 ≤ (tiedProfile 1).sum := by
    rw [tiedProfile_sum]; omega
  have hbad := hC (dominantProfile 1) (tiedProfile 1) h1 h2
  have hexc := dominant_tied_excess_sharp (k := 1) le_rfl
  linarith

/-- **Sharp bracket.**  Every universal additive budget constant exceeds `0.51`, and `0.53`
is one (for samples of at least `100` points).  The optimal constant is therefore located in
`(0.51, 0.53]` — in particular the conjectured value `0` is wrong by more than a half. -/
theorem budget_bracket_sharp :
    (∀ C : ℝ, (∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum →
        |spearman L - spearman L'|
          ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + C) → 51 / 100 < C) ∧
      (∀ L L' : List ℕ, 100 ≤ L.sum → 100 ≤ L'.sum →
        |spearman L - spearman L'|
          ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 53 / 100) :=
  ⟨budget_constant_gt_fiftyone, response_effect_threshold_sharp⟩

/-! ## 3. The half-modal capacity theorem -/

/-- Two-sided reading window of a half-modal law: `0.866 ≤ ρ ≤ 0.9358` once `n ≥ 40`. -/
theorem half_modal_window (L : List ℕ) (hn : 40 ≤ L.sum) (ha : modalFrac L = 1 / 2) :
    866 / 1000 ≤ spearman L ∧ spearman L ≤ 9358 / 10000 := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, L.sum = N := ⟨_, rfl⟩
  have h : 2 ≤ L.sum := by omega
  have hnN : 40 ≤ N := hN ▸ hn
  have hnR : (40 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hnN
  have hsq : (0 : ℝ) < (N : ℝ) ^ 2 - 1 := by nlinarith
  have hx0 : (0 : ℝ) ≤ ((spearmanSq L : ℚ) : ℝ) := by exact_mod_cast spearmanSq_nonneg L
  -- floor: `ρ² ≥ 1 - (1/2)² = 3/4`
  have hfloor : (3 : ℝ) / 4 ≤ ((spearmanSq L : ℚ) : ℝ) := by
    have hc := (Rat.cast_le (K := ℝ)).2 (mass_fraction_floor L h)
    rw [ha] at hc
    push_cast at hc
    linarith
  -- cap: `ρ² ≤ 1 - (1/2)³ + 1/(n²-1)`
  have hcapQ := modal_fraction_cap L h
  rw [ha, hN] at hcapQ
  have hcap : ((spearmanSq L : ℚ) : ℝ) ≤ 7 / 8 + 1 / ((N : ℝ) ^ 2 - 1) := by
    have hc := (Rat.cast_le (K := ℝ)).2 hcapQ
    push_cast at hc
    linarith
  have hsmall : 1 / ((N : ℝ) ^ 2 - 1) ≤ 1 / 1599 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  constructor
  · rw [spearman_eq_sqrt L h, Real.le_sqrt (by norm_num) hx0]
    nlinarith
  · rw [spearman_eq_sqrt L h]
    have hle : ((spearmanSq L : ℚ) : ℝ) ≤ ((9358 : ℝ) / 10000) ^ 2 := by
      nlinarith
    calc Real.sqrt ((spearmanSq L : ℚ) : ℝ) ≤ Real.sqrt (((9358 : ℝ) / 10000) ^ 2) :=
          Real.sqrt_le_sqrt hle
      _ = 9358 / 10000 := Real.sqrt_sq (by norm_num)

/-- **Half-modal capacity theorem.**  Any two draw laws whose modal tie class carries exactly
half of the sample (`n, n' ≥ 40`) have tie ceilings within `0.07` of each other — no matter how
different the rest of their profiles are.  This is the structural content of the recorded
balanced-versus-uniform bound. -/
theorem half_modal_capacity (L L' : List ℕ) (hn : 40 ≤ L.sum) (hn' : 40 ≤ L'.sum)
    (ha : modalFrac L = 1 / 2) (ha' : modalFrac L' = 1 / 2) :
    |spearman L - spearman L'| ≤ 7 / 100 := by
  obtain ⟨hlo, hhi⟩ := half_modal_window L hn ha
  obtain ⟨hlo', hhi'⟩ := half_modal_window L' hn' ha'
  rw [abs_le]
  constructor <;> linarith

/-- **The capacity is not vacuous.**  At modal fraction `1/2` the ceiling really can move by
more than `1/20`, so the half-modal capacity is pinned inside `(0.05, 0.07]`. -/
theorem half_modal_capacity_sharp :
    (∀ L L' : List ℕ, 40 ≤ L.sum → 40 ≤ L'.sum → modalFrac L = 1 / 2 → modalFrac L' = 1 / 2 →
        |spearman L - spearman L'| ≤ 7 / 100) ∧
      (∃ L L' : List ℕ, 40 ≤ L.sum ∧ 40 ≤ L'.sum ∧ modalFrac L = 1 / 2 ∧ modalFrac L' = 1 / 2 ∧
        1 / 20 < |spearman L - spearman L'|) := by
  refine ⟨half_modal_capacity, ⟨splitProfile 20, pairProfile 20, by rw [splitProfile_sum],
    by rw [pairProfile_sum], splitProfile_modalFrac (by norm_num),
    pairProfile_modalFrac (by norm_num), ?_⟩⟩
  · obtain ⟨-, -, hgap⟩ := equal_modal_ceiling_gap (m := 20) (by norm_num)
    have := le_abs_self (spearman (splitProfile 20) - spearman (pairProfile 20))
    linarith

/-! ## 4. Deriving the recorded balanced-versus-uniform capacity -/

lemma forty_mul_le_four_pow {v : ℕ} (hv : 4 ≤ v) : 40 * v ≤ 4 ^ v := by
  induction v with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge k 4 with hk | hk
      · interval_cases k <;> simp_all
      · have hstep := ih (by omega)
        have h4 : 4 ^ (k + 1) = 4 * 4 ^ k := by ring
        have hpos : 0 < 4 ^ k := by positivity
        omega

/-- The exactly balanced fixed-weight profile has at least `40` keys once `v ≥ 4`. -/
lemma forty_le_weightBlocks_sum {v : ℕ} (hv : 4 ≤ v) : 40 ≤ (weightBlocks (2 * v) v).sum := by
  have hsum : (weightBlocks (2 * v) v).sum = Nat.choose (2 * v) v :=
    weightBlocks_sum (by omega) (by omega)
  have hcb : Nat.centralBinom v = (2 * v).choose v := rfl
  have hbig : 4 ^ v < v * Nat.centralBinom v := Nat.four_pow_lt_mul_centralBinom v hv
  have hfour := forty_mul_le_four_pow hv
  have hvpos : 0 < v := by omega
  rw [hsum, ← hcb]
  by_contra hcon
  push_neg at hcon
  have : v * Nat.centralBinom v ≤ v * 39 := Nat.mul_le_mul_left v (by omega)
  omega

/-- The uniform dyadic profile has at least `40` points once `v ≥ 3`. -/
lemma forty_le_dyadic_sum {v : ℕ} (hv : 3 ≤ v) : 40 ≤ (dyadicBlocks (2 * v)).sum := by
  rw [dyadicBlocks_sum]
  calc (40 : ℕ) ≤ 2 ^ 6 := by norm_num
    _ ≤ 2 ^ (2 * v) := Nat.pow_le_pow_right (by norm_num) (by omega)

/-- **The recorded law-change capacity is a corollary of half-modality.**  For `v ≥ 4` the
balanced (fixed-weight) and uniform (dyadic) laws at bitlen `2v` both have modal fraction
`1/2`, hence their tie ceilings differ by at most `0.07` — the recorded bound of
`Cryptography.BalancedBKeyFixedWeight.law_change_capacity` follows from a property shared by
*all* half-modal law pairs, and by `half_modal_capacity_sharp` no better universal bound than
`(0.05, 0.07]` is available from the modal fraction alone. -/
theorem catalog_capacity_from_half_modality {v : ℕ} (hv : 4 ≤ v) :
    modalFrac (weightBlocks (2 * v) v) = modalFrac (dyadicBlocks (2 * v)) ∧
      |spearman (weightBlocks (2 * v) v) - spearman (dyadicBlocks (2 * v))| ≤ 7 / 100 := by
  have hW : modalFrac (weightBlocks (2 * v) v) = 1 / 2 := modalFrac_weightBlocks (by omega)
  have hD : modalFrac (dyadicBlocks (2 * v)) = 1 / 2 := modalFrac_dyadic (by omega)
  refine ⟨by rw [hW, hD], ?_⟩
  exact half_modal_capacity _ _ (forty_le_weightBlocks_sum hv) (forty_le_dyadic_sum (by omega))
    hW hD

end Catalog.Applications.ModalFractionCapacitySharp