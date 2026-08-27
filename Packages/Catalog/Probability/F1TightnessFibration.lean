import Mathlib
import Probability.F1TightnessCore

/-!
# The mean-position fibration of the slack factor

The identity `gapX_eq_meanPos` of `Probability.F1TightnessCore` shows that the
slack factor `X` of an `M`-cell profile depends on the profile *only* through
the mean probe position `E_x`.  This file draws the two consequences asked for
by direction 2 of `FUTURE_DIRECTIONS.md`.

* `gapX_eq_of_meanPos_eq` — **the fibration**: two profiles with the same mean
  position have the same slack, whatever their shape.  Extremality of the slack
  is therefore a statement about the reachable set of mean positions, not about
  the profile.
* `meanPos_mem_Icc` — the reachable set is contained in `[1/(2M), (2M−1)/(2M)]`,
  and `deltaFirst_meanPos`, `deltaLast_meanPos` show both endpoints are attained
  by point masses, so the containment is an equality of extremes.
* `gapX_mem_Icc`, `deltaFirst_gapX`, `deltaLast_gapX` — the resulting exact
  range of the slack factor, `X ∈ [(M+1)/(2M), (M+1)/2]`, with both endpoints
  attained.  In particular the slack of a *sorted* pool can be as large as
  `(M+1)/2`, while it can never drop below `(M+1)/(2M) → 1/2`.
-/

namespace F1Tightness

open Finset

variable {M : ℕ}

/-- **The fibration.**  The slack factor is a function of the mean probe
position alone: profiles on the same fibre have identical slack. -/
theorem gapX_eq_of_meanPos_eq {p q : Fin M → ℝ} (hM : 0 < M)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i : Fin M, p i = 1)
    (hq : ∀ i, 0 ≤ q i) (hqsum : ∑ i : Fin M, q i = 1)
    (h : meanPos p = meanPos q) : gapX p = gapX q := by
  rw [gapX_eq_meanPos hM hp hpsum, gapX_eq_meanPos hM hq hqsum, h]

/-- The reachable mean positions lie in `[1/(2M), (2M−1)/(2M)]`. -/
theorem meanPos_mem_Icc {p : Fin M → ℝ} (hM : 0 < M) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) :
    1 / (2 * (M : ℝ)) ≤ meanPos p ∧ meanPos p ≤ (2 * (M : ℝ) - 1) / (2 * (M : ℝ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  constructor
  · have hlow : ∑ i : Fin M, (1 / (2 * (M : ℝ))) * p i ≤ meanPos p := by
      refine Finset.sum_le_sum fun i _ => ?_
      have hi : (0 : ℝ) ≤ ((i : ℕ) : ℝ) := Nat.cast_nonneg _
      have : 1 / (2 * (M : ℝ)) ≤ (((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ) := by
        rw [div_le_div_iff₀ (by positivity) hMR]
        nlinarith
      exact mul_le_mul_of_nonneg_right this (hp i)
    rwa [← Finset.mul_sum, hsum, mul_one] at hlow
  · have hhigh : meanPos p ≤ ∑ i : Fin M, ((2 * (M : ℝ) - 1) / (2 * (M : ℝ))) * p i := by
      refine Finset.sum_le_sum fun i _ => ?_
      have hi : ((i : ℕ) : ℝ) + 1 ≤ (M : ℝ) := by exact_mod_cast i.isLt
      have : (((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ) ≤ (2 * (M : ℝ) - 1) / (2 * (M : ℝ)) := by
        rw [div_le_div_iff₀ hMR (by positivity)]
        nlinarith
      exact mul_le_mul_of_nonneg_right this (hp i)
    rwa [← Finset.mul_sum, hsum, mul_one] at hhigh

/-- The exact range of the slack factor over all `M`-cell profiles. -/
theorem gapX_mem_Icc {p : Fin M → ℝ} (hM : 0 < M) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) :
    ((M : ℝ) + 1) / (2 * (M : ℝ)) ≤ gapX p ∧ gapX p ≤ ((M : ℝ) + 1) / 2 := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  obtain ⟨hlow, hhigh⟩ := meanPos_mem_Icc hM hp hsum
  have hE0 : 0 < meanPos p := lt_of_lt_of_le (by positivity) hlow
  have hden : 0 < 2 * (M : ℝ) * meanPos p + 1 := by positivity
  rw [le_div_iff₀ (by positivity : (0:ℝ) < 2 * (M : ℝ))] at hhigh
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 2 * (M : ℝ))] at hlow
  rw [gapX_eq_meanPos hM hp hsum]
  constructor
  · rw [div_le_div_iff₀ (by positivity) hden]
    nlinarith
  · rw [div_le_div_iff₀ hden (by norm_num)]
    nlinarith

/-! ## The two extreme profiles -/

/-- All the mass on the first cell. -/
noncomputable def deltaFirst (M : ℕ) : Fin M → ℝ := fun i => if (i : ℕ) = 0 then 1 else 0

/-- All the mass on the last cell. -/
noncomputable def deltaLast (M : ℕ) : Fin M → ℝ := fun i => if (i : ℕ) = M - 1 then 1 else 0

theorem deltaFirst_nonneg (M : ℕ) : ∀ i, 0 ≤ deltaFirst M i := by
  intro i; unfold deltaFirst; split <;> norm_num

theorem deltaLast_nonneg (M : ℕ) : ∀ i, 0 ≤ deltaLast M i := by
  intro i; unfold deltaLast; split <;> norm_num

theorem deltaFirst_sum {M : ℕ} (hM : 0 < M) : ∑ i : Fin M, deltaFirst M i = 1 := by
  have h : ∀ i : Fin M, deltaFirst M i = if i = (⟨0, hM⟩ : Fin M) then 1 else 0 := by
    intro i
    unfold deltaFirst
    congr 1
    simp [Fin.ext_iff]
  simp [h]

theorem deltaLast_sum {M : ℕ} (hM : 0 < M) : ∑ i : Fin M, deltaLast M i = 1 := by
  have h : ∀ i : Fin M, deltaLast M i = if i = (⟨M - 1, by omega⟩ : Fin M) then 1 else 0 := by
    intro i
    unfold deltaLast
    congr 1
    simp [Fin.ext_iff]
  simp [h]

theorem deltaFirst_meanPos {M : ℕ} (hM : 0 < M) :
    meanPos (deltaFirst M) = 1 / (2 * (M : ℝ)) := by
  have h : ∀ i : Fin M,
      ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * deltaFirst M i
        = if i = (⟨0, hM⟩ : Fin M) then 1 / (2 * (M : ℝ)) else 0 := by
    intro i
    unfold deltaFirst
    by_cases h0 : (i : ℕ) = 0
    · have hi : i = (⟨0, hM⟩ : Fin M) := by simp [Fin.ext_iff, h0]
      simp only [hi, if_true]
      ring
    · have hi : i ≠ (⟨0, hM⟩ : Fin M) := by simp [Fin.ext_iff, h0]
      simp [h0, hi]
  rw [meanPos, Finset.sum_congr rfl fun i _ => h i]
  simp

theorem deltaLast_meanPos {M : ℕ} (hM : 0 < M) :
    meanPos (deltaLast M) = (2 * (M : ℝ) - 1) / (2 * (M : ℝ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hcast : (((M - 1 : ℕ) : ℝ)) = (M : ℝ) - 1 := by
    have : ((M - 1 : ℕ) : ℝ) = ((M : ℕ) : ℝ) - ((1 : ℕ) : ℝ) := by
      exact_mod_cast Nat.cast_sub hM
    simpa using this
  have h : ∀ i : Fin M,
      ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * deltaLast M i
        = if i = (⟨M - 1, by omega⟩ : Fin M) then (2 * (M : ℝ) - 1) / (2 * (M : ℝ)) else 0 := by
    intro i
    unfold deltaLast
    by_cases h0 : (i : ℕ) = M - 1
    · have hi : i = (⟨M - 1, by omega⟩ : Fin M) := by simp [Fin.ext_iff, h0]
      simp only [hi, if_true]
      rw [hcast]
      field_simp
      ring
    · have hi : i ≠ (⟨M - 1, by omega⟩ : Fin M) := by simp [Fin.ext_iff, h0]
      simp [h0, hi]
  rw [meanPos, Finset.sum_congr rfl fun i _ => h i]
  simp

/-- The first-cell point mass attains the **largest** possible slack. -/
theorem deltaFirst_gapX {M : ℕ} (hM : 0 < M) :
    gapX (deltaFirst M) = ((M : ℝ) + 1) / 2 := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hden : 2 * (M : ℝ) * (1 / (2 * (M : ℝ))) + 1 = 2 := by
    field_simp
    ring
  rw [gapX_eq_meanPos hM (deltaFirst_nonneg M) (deltaFirst_sum hM), deltaFirst_meanPos hM, hden]

/-- The last-cell point mass attains the **smallest** possible slack. -/
theorem deltaLast_gapX {M : ℕ} (hM : 0 < M) :
    gapX (deltaLast M) = ((M : ℝ) + 1) / (2 * (M : ℝ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hden : 2 * (M : ℝ) * ((2 * (M : ℝ) - 1) / (2 * (M : ℝ))) + 1 = 2 * (M : ℝ) := by
    field_simp
    ring
  rw [gapX_eq_meanPos hM (deltaLast_nonneg M) (deltaLast_sum hM), deltaLast_meanPos hM, hden]

/-- **Packaged range statement.**  The slack factor of an `M`-cell profile lies
in `[(M+1)/(2M), (M+1)/2]`, and both endpoints are attained by point masses, so
the interval cannot be shrunk. -/
theorem gapX_range_sharp {M : ℕ} (hM : 0 < M) :
    (∀ p : Fin M → ℝ, (∀ i, 0 ≤ p i) → (∑ i : Fin M, p i = 1) →
        ((M : ℝ) + 1) / (2 * (M : ℝ)) ≤ gapX p ∧ gapX p ≤ ((M : ℝ) + 1) / 2)
      ∧ gapX (deltaLast M) = ((M : ℝ) + 1) / (2 * (M : ℝ))
      ∧ gapX (deltaFirst M) = ((M : ℝ) + 1) / 2 :=
  ⟨fun _ hp hsum => gapX_mem_Icc hM hp hsum, deltaLast_gapX hM, deltaFirst_gapX hM⟩

end F1Tightness