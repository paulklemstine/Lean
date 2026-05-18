/-
Copyright (c) 2025 Tropical Brill-Noether Formalization Project. All rights reserved.

# Brill–Noether Number: Algebraic Properties

This file proves fundamental algebraic properties of the Brill–Noether number
`ρ(g, r, d) = g − (r + 1)(g − d + r)`.
-/

import Tropical.BrillNoether.Defs

open Finset BigOperators

/-! ## Equivalence of formulations -/

/-- The two formulations of the Brill–Noether number agree. -/
theorem brillNoetherNumber_eq_alt (g r d : ℕ) :
    brillNoetherNumber g r d = brillNoetherNumberAlt g r d := by
  simp [brillNoetherNumber, brillNoetherNumberAlt]; ring

/-! ## Special values -/

/-- When `r = 0`, the Brill–Noether number equals `d`. -/
theorem brillNoetherNumber_r_zero (g d : ℕ) :
    brillNoetherNumber g 0 d = (d : ℤ) := by
  simp [brillNoetherNumber]

/-- When `d = g + r`, the Brill–Noether number equals `g`. -/
theorem brillNoetherNumber_d_eq_g_add_r (g r : ℕ) :
    brillNoetherNumber g r (g + r) = (g : ℤ) := by
  unfold brillNoetherNumber
  push_cast; ring

/-- When `g = 0`, `ρ(0, r, d) = (r + 1)(d − r)`. -/
theorem brillNoetherNumber_g_zero (r d : ℕ) :
    brillNoetherNumber 0 r d = ((r : ℤ) + 1) * ((d : ℤ) - (r : ℤ)) := by
  simp [brillNoetherNumber]; ring

/-- When `d = r`, `ρ(g, r, r) = −r * g`. -/
theorem brillNoetherNumber_d_eq_r (g r : ℕ) :
    brillNoetherNumber g r r = -(r : ℤ) * (g : ℤ) := by
  simp [brillNoetherNumber]; ring

/-! ## Monotonicity -/

/-- `ρ` increases by `r + 1` when `d` increases by 1. -/
theorem brillNoetherNumber_add_one_d (g r d : ℕ) :
    brillNoetherNumber g r (d + 1) = brillNoetherNumber g r d + ((r : ℤ) + 1) := by
  unfold brillNoetherNumber; push_cast; ring

/-- `ρ` is monotone increasing in `d`. -/
theorem brillNoetherNumber_mono_d (g r d₁ d₂ : ℕ) (h : d₁ ≤ d₂) :
    brillNoetherNumber g r d₁ ≤ brillNoetherNumber g r d₂ := by
  unfold brillNoetherNumber
  nlinarith [h]

/-- `ρ` decreases when `r` increases by 1. Specifically,
    `ρ(g, r+1, d) = ρ(g, r, d) − (g − d + 2r + 2)`. -/
theorem brillNoetherNumber_add_one_r (g r d : ℕ) :
    brillNoetherNumber g (r + 1) d =
      brillNoetherNumber g r d - ((g : ℤ) - (d : ℤ) + 2 * (r : ℤ) + 2) := by
  unfold brillNoetherNumber
  push_cast; ring

/-! ## Nonnegativity conditions -/

/-- `ρ(g, r, d) ≥ 0` iff `g ≥ (r+1)(g − d + r)`. -/
theorem brillNoetherNumber_nonneg_iff (g r d : ℕ) :
    0 ≤ brillNoetherNumber g r d ↔
      (g : ℤ) ≥ ((r : ℤ) + 1) * ((g : ℤ) - (d : ℤ) + (r : ℤ)) := by
  unfold brillNoetherNumber
  constructor <;> intro h <;> linarith

/-- Expanded form: `ρ ≥ 0 ↔ (r+1) * d ≥ r * (g + r + 1)`. -/
theorem brillNoetherNumber_nonneg_iff' (g r d : ℕ) :
    0 ≤ brillNoetherNumber g r d ↔
      (r : ℤ) * ((g : ℤ) + (r : ℤ) + 1) ≤ ((r : ℤ) + 1) * (d : ℤ) := by
  rw [brillNoetherNumber_eq_alt]; simp [brillNoetherNumberAlt]
  constructor <;> intro h <;> nlinarith

/-- When `d ≥ g + r`, `ρ` is always nonneg. -/
theorem brillNoetherNumber_nonneg_of_large_d (g r d : ℕ) (h : g + r ≤ d) :
    0 ≤ brillNoetherNumber g r d := by
  unfold brillNoetherNumber
  nlinarith [h]

/-- When `d < r` and `g ≥ 1`, `ρ` is negative. -/
theorem brillNoetherNumber_neg_of_small_d (g r d : ℕ) (hg : 1 ≤ g) (hd : d < r) :
    brillNoetherNumber g r d < 0 := by
  unfold brillNoetherNumber
  nlinarith [hd, hg]

/-! ## Dimension Formula -/

/-- `ρ = (r+1)d − r(r+1) − r·g`. -/
theorem brillNoetherNumber_dimension_formula (g r d : ℕ) :
    brillNoetherNumber g r d =
      ((r : ℤ) + 1) * (d : ℤ) - (r : ℤ) * ((r : ℤ) + 1) - (r : ℤ) * (g : ℤ) := by
  simp [brillNoetherNumber]; ring

/-! ## Degree-Genus Bounds -/

/-- If `ρ ≥ 0` and `g ≥ 1`, then `d ≥ r`. -/
theorem degree_ge_rank_of_rho_nonneg (g r d : ℕ) (hg : 1 ≤ g)
    (hρ : 0 ≤ brillNoetherNumber g r d) : r ≤ d := by
  by_contra h
  push_neg at h
  exact absurd hρ (not_le.mpr (brillNoetherNumber_neg_of_small_d g r d hg h))

/-- The rank-1 BN number: `ρ(g, 1, d) = 2d − g − 2`. -/
theorem rank_one_rho (g d : ℕ) :
    brillNoetherNumber g 1 d = 2 * (d : ℤ) - (g : ℤ) - 2 := by
  simp [brillNoetherNumber]; ring

/-- Gonality bound: `ρ(g, 1, d) ≥ 0 ↔ 2d ≥ g + 2`. -/
theorem generic_tropical_gonality_bound (g d : ℕ) :
    0 ≤ brillNoetherNumber g 1 d ↔ (g : ℤ) + 2 ≤ 2 * (d : ℤ) := by
  rw [rank_one_rho]; omega