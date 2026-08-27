import Mathlib
import Probability.F1TightnessCore

/-!
# Sharpness over the prior class, stability, and the binding arm (paper 250)

`Probability.F1TightnessCore` proves that on a fixed front-loaded, non-flat
positional profile the F1 master bound is *never attained*: the slack factor
`X = C₀/c_asc` is strictly larger than one.  The natural objection is that the
inequality might then be improvable.  This file shows it is not: the bound is
**sharp over the prior class** even though it is unattainable on any fixed
non-flat pool.  This is the theorem-side closer named in the round-92
deliverable: sharpness must be posed over the class of priors, never as
tightness on one pool.

Main results.

* `twoCell` — the two-cell family `p_δ = (1/2 + δ, 1/2 − δ)`, antitone and
  non-flat for `0 < δ < 1/2`, with slack factor `X = (3/2)/(3/2 − δ)`.
* `twoCell_gapX`, `twoCell_slack_small` — the slack of `p_δ` tends to `1`.
* `sharp_over_prior_class` — for every `ε > 0` there is an admissible
  (antitone, non-flat) profile whose slack is `< 1 + ε`: the constant `1`
  cannot be improved uniformly over the prior class, yet
  `slack_never_attained` says no admissible profile reaches it.
* `gapX_stability` — the slack factor is Lipschitz in the profile for the `L¹`
  distance; this is the formal content of "hump-insensitivity": a bounded
  perturbation of the profile moves `X` by a bounded amount.
* `binding_arm` — with `k_bits = 0` and `q̂ ≥ 1` the first arm of the master
  bound `min(1/(ΛΘq̂), 2^k/(ΛΘ))` is the binding one, as booked.
-/

open Finset

namespace F1Tightness

/-! ## A two-cell family approaching flatness -/

/-- The two-cell profile `(1/2 + δ, 1/2 − δ)`. -/
noncomputable def twoCell (δ : ℝ) : Fin 2 → ℝ := fun i => if i = 0 then 1 / 2 + δ else 1 / 2 - δ

theorem twoCell_sum (δ : ℝ) : ∑ i : Fin 2, twoCell δ i = 1 := by
  rw [Fin.sum_univ_two]
  simp [twoCell]
  ring

theorem twoCell_nonneg {δ : ℝ} (h0 : 0 ≤ δ) (h1 : δ ≤ 1 / 2) : ∀ i, 0 ≤ twoCell δ i := by
  intro i
  fin_cases i <;> simp [twoCell] <;> linarith

theorem twoCell_antitone {δ : ℝ} (h0 : 0 ≤ δ) : Antitone (twoCell δ) := by
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [twoCell]
  linarith

theorem twoCell_not_flat {δ : ℝ} (h0 : 0 < δ) : twoCell δ 0 ≠ twoCell δ 1 := by
  simp [twoCell]
  linarith

theorem twoCell_scanCost (δ : ℝ) : scanCost (twoCell δ) = 3 / 2 - δ := by
  rw [scanCost, Fin.sum_univ_two]
  simp [twoCell]
  ring

/-- The slack factor of the two-cell family. -/
theorem twoCell_gapX (δ : ℝ) :
    gapX (twoCell δ) = (3 / 2) / (3 / 2 - δ) := by
  rw [gapX, twoCell_scanCost, baseCost]
  norm_num

/-- The slack of the two-cell family can be made arbitrarily close to `1`. -/
theorem twoCell_slack_small {ε : ℝ} (hε : 0 < ε) :
    ∃ δ, 0 < δ ∧ δ < 1 / 2 ∧ gapX (twoCell δ) < 1 + ε := by
  refine ⟨min (1 / 4) (ε / 2), by positivity, ?_, ?_⟩
  · calc min (1 / 4) (ε / 2) ≤ 1 / 4 := min_le_left _ _
      _ < 1 / 2 := by norm_num
  · set δ := min (1 / 4) (ε / 2) with hδ
    have hδ0 : 0 < δ := by positivity
    have hδ4 : δ ≤ 1 / 4 := min_le_left _ _
    have hδε : δ ≤ ε / 2 := min_le_right _ _
    rw [twoCell_gapX]
    rw [div_lt_iff₀ (by linarith)]
    nlinarith

/-- **Sharpness over the prior class.**  For every `ε > 0` there is an
admissible (antitone, non-flat) profile whose slack factor is below `1 + ε`:
the master inequality cannot be improved by any constant factor uniformly over
the class of priors. -/
theorem sharp_over_prior_class {ε : ℝ} (hε : 0 < ε) :
    ∃ (p : Fin 2 → ℝ), (∀ i, 0 ≤ p i) ∧ (∑ i : Fin 2, p i = 1) ∧ Antitone p ∧
      p 0 ≠ p 1 ∧ 1 < gapX p ∧ gapX p < 1 + ε := by
  obtain ⟨δ, hδ0, hδ1, hlt⟩ := twoCell_slack_small hε
  refine ⟨twoCell δ, twoCell_nonneg hδ0.le (by linarith), twoCell_sum δ,
    twoCell_antitone hδ0.le, twoCell_not_flat hδ0, ?_, hlt⟩
  exact one_lt_gapX (twoCell_nonneg hδ0.le (by linarith)) (twoCell_sum δ)
    (twoCell_antitone hδ0.le) (twoCell_not_flat hδ0)

/-- ... and yet the value `1` is never attained inside the class: sharpness is a
statement about the class, not about any pool. -/
theorem slack_never_attained {M : ℕ} {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) {i₀ j₀ : Fin M}
    (hne : p i₀ ≠ p j₀) : gapX p ≠ 1 :=
  ne_of_gt (one_lt_gapX hp hsum hanti hne)

/-! ## Stability of the slack factor ("hump-insensitivity") -/

variable {M : ℕ}

theorem scanCost_sub_abs_le (p q : Fin M → ℝ) :
    |scanCost p - scanCost q| ≤ (M : ℝ) * ∑ i : Fin M, |p i - q i| := by
  have hdiff : scanCost p - scanCost q
      = ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * (p i - q i) := by
    rw [scanCost, scanCost, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hdiff]
  calc |∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * (p i - q i)|
      ≤ ∑ i : Fin M, |(((i : ℕ) : ℝ) + 1) * (p i - q i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i : Fin M, (M : ℝ) * |p i - q i| := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [abs_mul]
        have h1 : |((i : ℕ) : ℝ) + 1| ≤ (M : ℝ) := by
          have hb : ((i : ℕ) : ℝ) + 1 ≤ (M : ℝ) := by exact_mod_cast i.isLt
          rw [abs_of_nonneg (by positivity)]
          exact hb
        exact mul_le_mul_of_nonneg_right h1 (abs_nonneg _)
    _ = (M : ℝ) * ∑ i : Fin M, |p i - q i| := by rw [Finset.mul_sum]

/-- **Hump-insensitivity.**  The slack factor is Lipschitz in the profile with
respect to the `L¹` distance: a perturbation of total mass `ε` moves `X` by at
most `M(M+1)ε/2`.  (Both costs are at least `1`, which is what makes the
denominators harmless.) -/
theorem gapX_stability {p q : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsump : ∑ i : Fin M, p i = 1) (hq : ∀ i, 0 ≤ q i) (hsumq : ∑ i : Fin M, q i = 1) :
    |gapX p - gapX q| ≤ ((M : ℝ) + 1) / 2 * ((M : ℝ) * ∑ i : Fin M, |p i - q i|) := by
  have hcp : 1 ≤ scanCost p := one_le_scanCost hp hsump
  have hcq : 1 ≤ scanCost q := one_le_scanCost hq hsumq
  have hcp0 : 0 < scanCost p := by linarith
  have hcq0 : 0 < scanCost q := by linarith
  have hb : 0 < baseCost M := baseCost_pos M
  have hdiff : gapX p - gapX q
      = baseCost M * (scanCost q - scanCost p) / (scanCost p * scanCost q) := by
    unfold gapX
    field_simp
  rw [hdiff, abs_div, abs_mul, abs_of_pos (by positivity : (0:ℝ) < scanCost p * scanCost q),
    abs_of_pos hb]
  rw [div_le_iff₀ (by positivity)]
  have habs : |scanCost q - scanCost p| ≤ (M : ℝ) * ∑ i : Fin M, |p i - q i| := by
    have := scanCost_sub_abs_le q p
    have hsymm : ∑ i : Fin M, |q i - p i| = ∑ i : Fin M, |p i - q i| :=
      Finset.sum_congr rfl fun i _ => abs_sub_comm _ _
    rwa [hsymm] at this
  have hsum0 : 0 ≤ (M : ℝ) * ∑ i : Fin M, |p i - q i| := by
    have : 0 ≤ ∑ i : Fin M, |p i - q i| := Finset.sum_nonneg fun i _ => abs_nonneg _
    positivity
  have hprod : 1 ≤ scanCost p * scanCost q := by nlinarith
  have hbc : baseCost M = ((M : ℝ) + 1) / 2 := rfl
  calc baseCost M * |scanCost q - scanCost p|
      ≤ baseCost M * ((M : ℝ) * ∑ i : Fin M, |p i - q i|) :=
        mul_le_mul_of_nonneg_left habs hb.le
    _ ≤ ((M : ℝ) + 1) / 2 * ((M : ℝ) * ∑ i : Fin M, |p i - q i|) *
          (scanCost p * scanCost q) := by
        rw [hbc]
        have hK : 0 ≤ ((M : ℝ) + 1) / 2 * ((M : ℝ) * ∑ i : Fin M, |p i - q i|) := by
          have : (0:ℝ) ≤ ((M : ℝ) + 1) / 2 := by positivity
          exact mul_nonneg this hsum0
        exact le_mul_of_one_le_right hK hprod

/-! ## A worked rational example -/

/-- The linear profile `(0.4, 0.3, 0.2, 0.1)` on four cells: a fully explicit
instance of the identity chain, with `Λ = 2/3`, `Θ = 4/5`, `X = 5/4`,
`S_asc = 3/2` and `bound = 15/8 = X · S_asc`. -/
theorem linear4_values :
    scanCost (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 2 ∧
    revCost (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 3 ∧
    Lam (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 2 / 3 ∧
    Theta (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 4 / 5 ∧
    gapX (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 5 / 4 ∧
    boundF1 (Lam (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10))
        (Theta (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10)) 1
      = gapX (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) *
          Sasc (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) := by
  have hs : scanCost (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 2 := by
    rw [scanCost, Fin.sum_univ_four]
    norm_num
  have hr : revCost (fun i : Fin 4 => (4 - ((i : ℕ) : ℝ)) / 10) = 3 := by
    rw [revCost, Fin.sum_univ_four]
    norm_num
  refine ⟨hs, hr, ?_, ?_, ?_, ?_⟩
  · rw [Lam, hs, hr]
  · rw [Theta, hs, baseCost]; norm_num
  · rw [gapX, hs, baseCost]; norm_num
  · rw [boundF1, Lam, Theta, gapX, Sasc, hs, hr, baseCost]; norm_num

/-! ## Which arm of the master bound binds -/

/-- The two-armed master bound `min(1/(ΛΘq̂), 2^k/(ΛΘ))`. -/
noncomputable def boundF1two (lam th q : ℝ) (k : ℕ) : ℝ :=
  min (1 / (lam * th * q)) ((2 : ℝ) ^ k / (lam * th))

/-- With `k_bits = 0` (test-blind) and `q̂ ≥ 1`, the first arm binds. -/
theorem binding_arm {lam th q : ℝ} (hlam : 0 < lam) (hth : 0 < th) (hq : 1 ≤ q) :
    boundF1two lam th q 0 = boundF1 lam th q := by
  have hlt : 1 / (lam * th * q) ≤ (2 : ℝ) ^ (0 : ℕ) / (lam * th) := by
    rw [pow_zero]
    apply div_le_div_of_nonneg_left (by norm_num) (by positivity)
    have hlt := mul_pos hlam hth
    nlinarith
  unfold boundF1two boundF1
  exact min_eq_left hlt

/-- At `q̂ = 1` the two arms coincide: the unidentified coverage parameter is
exactly the degree of freedom that separates them. -/
theorem arms_agree_at_one (lam th : ℝ) :
    boundF1two lam th 1 0 = boundF1 lam th 1 := by
  unfold boundF1two boundF1
  norm_num

end F1Tightness