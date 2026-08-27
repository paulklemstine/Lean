import Mathlib
import Probability.F1TightnessCore

/-!
# A quantitative (L¹) strengthening of the F1 master inequality

`Probability.F1TightnessCore` proves that on an antitone non-flat profile the
slack factor `X = C₀/c_asc` is strictly larger than one, so the master bound is
never attained; but `one_lt_gapX` is qualitative — it gives no number.

This file supplies the number.  Write

`flatDist p = ∑ i, |p i − 1/M|`

for the L¹ distance of the profile to the flat profile.  Then, for every
antitone profile,

* `scanCost_le_baseCost_sub_flatDist` — `c_asc ≤ C₀ − ‖p − flat‖₁ / 2`;
* `one_add_flatDist_le_gapX` — `1 + ‖p − flat‖₁/(2M) ≤ X`;
* `speedup_mul_le_bound_quantitative` — **the refined master inequality**
  `S · (1 + ‖p − flat‖₁/(2M)) ≤ bound`, i.e. `S ≤ bound/(1 + V)` with the
  explicit, computable dispersion functional `V = ‖p − flat‖₁/(2M)`;
* `flatDist_eq_zero_iff` — `V` vanishes exactly on the flat profile, the case
  the three independent tests reject pool-side.

The proof route is the pairwise expansion `sum_pairs_identity` of the core file,
kept with its quadratic remainder instead of discarded: for an antitone profile
each pairwise term of the Chebyshev double sum is bounded below by `|p i − p j|`
in absolute value, and the triangle inequality converts the resulting double sum
into the L¹ distance to flat.  This is the shape asked for by direction 3 of
`FUTURE_DIRECTIONS.md`, with the absolute constant `c = 1` in the normalisation
`V = ‖p − flat‖₁/(2M)`.
-/

namespace F1Tightness

open Finset

variable {M : ℕ}

/-- L¹ distance of the profile to the flat profile. -/
noncomputable def flatDist (p : Fin M → ℝ) : ℝ := ∑ i : Fin M, |p i - (M : ℝ)⁻¹|

theorem flatDist_nonneg (p : Fin M → ℝ) : 0 ≤ flatDist p :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- The dispersion functional vanishes exactly on the flat profile. -/
theorem flatDist_eq_zero_iff (p : Fin M → ℝ) :
    flatDist p = 0 ↔ ∀ i, p i = (M : ℝ)⁻¹ := by
  unfold flatDist
  rw [Finset.sum_eq_zero_iff_of_nonneg fun i _ => abs_nonneg _]
  constructor
  · intro h i
    have := h i (mem_univ i)
    have : p i - (M : ℝ)⁻¹ = 0 := abs_eq_zero.mp this
    linarith
  · intro h i _
    rw [h i]
    simp

/-- **Pairwise lower bound.**  For an antitone profile the Chebyshev pairwise
product dominates the absolute difference of the two probabilities. -/
theorem abs_sub_le_pair {p : Fin M → ℝ} (hanti : Antitone p) (i j : Fin M) :
    |p i - p j| ≤ (((j : ℕ) : ℝ) - ((i : ℕ) : ℝ)) * (p i - p j) := by
  rcases lt_trichotomy i j with h | h | h
  · have hij : ((i : ℕ) : ℝ) + 1 ≤ ((j : ℕ) : ℝ) := by
      have : (i : ℕ) + 1 ≤ (j : ℕ) := h
      exact_mod_cast this
    have hp : 0 ≤ p i - p j := by linarith [hanti h.le]
    rw [abs_of_nonneg hp]
    nlinarith
  · subst h; simp
  · have hij : ((j : ℕ) : ℝ) + 1 ≤ ((i : ℕ) : ℝ) := by
      have : (j : ℕ) + 1 ≤ (i : ℕ) := h
      exact_mod_cast this
    have hp : p i - p j ≤ 0 := by linarith [hanti h.le]
    rw [abs_of_nonpos hp]
    nlinarith

/-- The row sums of the pairwise absolute differences dominate `M·|p i − 1/M|`. -/
theorem row_sum_ge {p : Fin M → ℝ} (hsum : ∑ i : Fin M, p i = 1) (i : Fin M) :
    (M : ℝ) * |p i - (M : ℝ)⁻¹| ≤ ∑ j : Fin M, |p i - p j| := by
  have htri : |∑ j : Fin M, (p i - p j)| ≤ ∑ j : Fin M, |p i - p j| :=
    Finset.abs_sum_le_sum_abs _ _
  have hrow : ∑ j : Fin M, (p i - p j) = (M : ℝ) * p i - 1 := by
    rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, Finset.card_univ, Fintype.card_fin]
    simp [nsmul_eq_mul]
  rw [hrow] at htri
  rcases Nat.eq_zero_or_pos M with hM | hM
  · subst hM; simp
  · have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
    have hfac : (M : ℝ) * |p i - (M : ℝ)⁻¹| = |(M : ℝ) * p i - 1| := by
      rw [← abs_of_pos hMR, ← abs_mul, abs_of_pos hMR]
      congr 1
      field_simp
    rw [hfac]
    exact htri

/-- **Quantitative Chebyshev slack.**  On an antitone profile the ascending cost
falls below the flat baseline by at least half the L¹ distance to flat. -/
theorem scanCost_le_baseCost_sub_flatDist {p : Fin M → ℝ}
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) :
    scanCost p ≤ baseCost M - flatDist p / 2 := by
  rcases Nat.eq_zero_or_pos M with hM | hM
  · subst hM
    simp only [Finset.univ_eq_empty, Finset.sum_empty] at hsum
    exact absurd hsum (by norm_num)
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  set a : Fin M → ℝ := fun i => ((i : ℕ) : ℝ) + 1 with ha
  -- the pairwise identity, with the quadratic remainder kept
  have hid : ∑ i : Fin M, ∑ j : Fin M, (a i - a j) * (p i - p j)
      = 2 * ((M : ℝ) * scanCost p - (M : ℝ) * ((M : ℝ) + 1) / 2) := by
    have := sum_pairs_identity (univ : Finset (Fin M)) a p
    rw [Finset.card_univ, Fintype.card_fin, sum_rank_weights, hsum] at this
    simpa [scanCost, ha, mul_comm, mul_left_comm, mul_assoc] using this
  -- each pairwise term dominates the absolute difference
  have hterm : ∀ i j : Fin M, |p i - p j| ≤ -((a i - a j) * (p i - p j)) := by
    intro i j
    have h := abs_sub_le_pair hanti i j
    have : (((j : ℕ) : ℝ) - ((i : ℕ) : ℝ)) * (p i - p j) = -((a i - a j) * (p i - p j)) := by
      simp only [ha]; ring
    linarith [h, this.le, this.ge]
  have hdouble : ∑ i : Fin M, ∑ j : Fin M, |p i - p j|
      ≤ ∑ i : Fin M, ∑ j : Fin M, -((a i - a j) * (p i - p j)) :=
    Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => hterm i j
  have hneg : ∑ i : Fin M, ∑ j : Fin M, -((a i - a j) * (p i - p j))
      = -(∑ i : Fin M, ∑ j : Fin M, (a i - a j) * (p i - p j)) := by
    simp [Finset.sum_neg_distrib]
  -- the L¹ lower bound on the double sum
  have hrow : (M : ℝ) * flatDist p ≤ ∑ i : Fin M, ∑ j : Fin M, |p i - p j| := by
    rw [flatDist, Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => row_sum_ge hsum i
  rw [hneg, hid] at hdouble
  have hkey : (M : ℝ) * flatDist p
      ≤ -(2 * ((M : ℝ) * scanCost p - (M : ℝ) * ((M : ℝ) + 1) / 2)) := le_trans hrow hdouble
  have hb : baseCost M = ((M : ℝ) + 1) / 2 := rfl
  rw [hb]
  nlinarith [hkey]

theorem scanCost_le_card {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : scanCost p ≤ (M : ℝ) := by
  have h : scanCost p ≤ ∑ i : Fin M, (M : ℝ) * p i := by
    refine Finset.sum_le_sum fun i _ => ?_
    have hi : ((i : ℕ) : ℝ) + 1 ≤ (M : ℝ) := by exact_mod_cast i.isLt
    nlinarith [hp i]
  rwa [← Finset.mul_sum, hsum, mul_one] at h

/-- **The quantitative slack.**  The gap factor exceeds one by at least the L¹
distance to flatness, normalised by `2M`. -/
theorem one_add_flatDist_le_gapX {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) :
    1 + flatDist p / (2 * (M : ℝ)) ≤ gapX p := by
  rcases Nat.eq_zero_or_pos M with hM | hM
  · subst hM
    simp only [Finset.univ_eq_empty, Finset.sum_empty] at hsum
    exact absurd hsum (by norm_num)
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hc := scanCost_pos hp hsum
  have hcM := scanCost_le_card hp hsum
  have hb := scanCost_le_baseCost_sub_flatDist hsum hanti
  have hL := flatDist_nonneg p
  unfold gapX
  rw [le_div_iff₀ hc]
  have hstep : flatDist p / (2 * (M : ℝ)) * scanCost p ≤ flatDist p / 2 := by
    rw [div_mul_eq_mul_div, div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  linarith

/-- **The refined master inequality.**  Every realizable policy on an antitone
profile satisfies `S · (1 + V) ≤ bound` with the explicit dispersion functional
`V = ‖p − flat‖₁/(2M)`, which vanishes exactly on the flat profile. -/
theorem speedup_mul_le_bound_quantitative {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) (σ : Equiv.Perm (Fin M)) :
    speedup p σ * (1 + flatDist p / (2 * (M : ℝ))) ≤ boundF1 (Lam p) (Theta p) 1 := by
  have hL := flatDist_nonneg p
  have hV : 0 ≤ 1 + flatDist p / (2 * (M : ℝ)) := by positivity
  have hS : speedup p σ ≤ Sasc p := policy_speedup_le_Sasc hp hsum hanti σ
  have hSpos : 0 < Sasc p := div_pos (revCost_pos hp hsum) (scanCost_pos hp hsum)
  have hX := one_add_flatDist_le_gapX hp hsum hanti
  calc speedup p σ * (1 + flatDist p / (2 * (M : ℝ)))
      ≤ Sasc p * (1 + flatDist p / (2 * (M : ℝ))) := mul_le_mul_of_nonneg_right hS hV
    _ ≤ Sasc p * gapX p := mul_le_mul_of_nonneg_left hX hSpos.le
    _ = boundF1 (Lam p) (Theta p) 1 := by
        rw [slack_identity hp hsum]; ring

/-- Explicit form of the refinement: the bound divided by `1 + V` still
dominates every realizable speed-up. -/
theorem speedup_le_bound_div_quantitative {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) (σ : Equiv.Perm (Fin M)) :
    speedup p σ ≤ boundF1 (Lam p) (Theta p) 1 / (1 + flatDist p / (2 * (M : ℝ))) := by
  have hL := flatDist_nonneg p
  have hV : 0 < 1 + flatDist p / (2 * (M : ℝ)) := by positivity
  rw [le_div_iff₀ hV]
  exact speedup_mul_le_bound_quantitative hp hsum hanti σ

/-! ## Non-vacuity: an explicit profile with a positive dispersion -/

/-- The two-cell profile `(3/4, 1/4)`. -/
noncomputable def demoTwo : Fin 2 → ℝ := ![3 / 4, 1 / 4]

theorem demoTwo_sum : ∑ i : Fin 2, demoTwo i = 1 := by
  norm_num [demoTwo, Fin.sum_univ_succ]

theorem demoTwo_nonneg : ∀ i, 0 ≤ demoTwo i := by
  intro i; fin_cases i <;> norm_num [demoTwo]

theorem demoTwo_antitone : Antitone demoTwo := by
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [demoTwo]
  norm_num

theorem demoTwo_flatDist : flatDist demoTwo = 1 / 2 := by
  norm_num [flatDist, demoTwo, Fin.sum_univ_succ, abs_of_nonneg, abs_of_nonpos]

/-- On `(3/4, 1/4)` the refinement is a genuine improvement: the bound is
divided by `1 + 1/8`. -/
theorem demoTwo_refined (σ : Equiv.Perm (Fin 2)) :
    speedup demoTwo σ * (9 / 8) ≤ boundF1 (Lam demoTwo) (Theta demoTwo) 1 := by
  have h := speedup_mul_le_bound_quantitative demoTwo_nonneg demoTwo_sum demoTwo_antitone σ
  rw [demoTwo_flatDist] at h
  norm_num at h ⊢
  linarith [h]

end F1Tightness