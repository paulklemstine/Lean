/-! # CatalogBuild.Tropical.Core.TropicalSemiringProperties

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 6
-/

import Mathlib

theorem tropical_scalar_distrib (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  cases le_total b c with
  | inl h =>
    rw [max_eq_right h]
    have : a + c ≥ a + b := by linarith
    rw [max_eq_right this]
  | inr h =>
    rw [max_eq_left h]
    have : a + b ≥ a + c := by linarith
    rw [max_eq_left this]


theorem tropical_scalar_distrib_right (a b c : ℝ) :
    max a b + c = max (a + c) (b + c) := by
  have h := tropical_scalar_distrib c a b
  rw [add_comm c (max a b), add_comm c a, add_comm c b] at h
  exact h


theorem tropical_absorption (x y : ℝ) : max x (max x y) = max x y := by simp


theorem tropical_absorption_dual (x y : ℝ) : max (max x y) y = max x y := by simp


theorem tropical_add_mono (x y z : ℝ) (h : x ≤ y) : max x z ≤ max y z :=
  max_le_max h le_rfl


theorem tropical_mul_inv (x : ℝ) : x + (-x) = 0 := add_neg_cancel x

