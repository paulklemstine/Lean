/-
  # Effective Potential Unique Minimum

  The effective potential V_eff(r) = l²/(2mr²) - k/r has a unique global minimum
  at r* = l²/(mk), with value V_min = -mk²/(2l²). This is the circular orbit.
-/
import Mathlib
import Pythagorean.KeplerDefs

open Real

/-- The circular orbit radius is positive. -/
theorem circularOrbitRadius_pos {m k l : ℝ} (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    circularOrbitRadius m k l > 0 := by
  unfold circularOrbitRadius
  positivity

/-- The effective potential at the circular orbit radius equals the minimum value. -/
theorem effectivePotential_at_circular {m k l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    effectivePotential m k l (circularOrbitRadius m k l) = effectivePotentialMin m k l := by
  unfold effectivePotential circularOrbitRadius effectivePotentialMin
  have hm' : m ≠ 0 := ne_of_gt hm
  have hk' : k ≠ 0 := ne_of_gt hk
  have hl' : l ≠ 0 := ne_of_gt hl
  field_simp
  ring

/-- Auxiliary: the effective potential difference V_eff(r) - V_min can be expressed
    as a perfect square term, proving V_eff(r) ≥ V_min with equality iff r = r*. -/
theorem effectivePotential_sub_min {m k l r : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) (hr : r > 0) :
    effectivePotential m k l r - effectivePotentialMin m k l =
      l ^ 2 / (2 * m * r ^ 2) * (1 - m * k * r / l ^ 2) ^ 2 := by
  unfold effectivePotential effectivePotentialMin
  have hm' : m ≠ 0 := ne_of_gt hm
  have hk' : k ≠ 0 := ne_of_gt hk
  have hl' : l ≠ 0 := ne_of_gt hl
  have hr' : r ≠ 0 := ne_of_gt hr
  field_simp
  ring

/-- The effective potential achieves its minimum value at the circular orbit radius. -/
theorem effectivePotential_ge_min {m k l r : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) (hr : r > 0) :
    effectivePotential m k l r ≥ effectivePotentialMin m k l := by
  have h := effectivePotential_sub_min hm hk hl hr
  have : l ^ 2 / (2 * m * r ^ 2) * (1 - m * k * r / l ^ 2) ^ 2 ≥ 0 := by positivity
  linarith

/-
The effective potential strictly exceeds the minimum at any non-circular radius.
-/
theorem effectivePotential_gt_min {m k l r : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) (hr : r > 0)
    (hne : r ≠ circularOrbitRadius m k l) :
    effectivePotential m k l r > effectivePotentialMin m k l := by
  -- We first express the difference as a perfect square expression using `effectivePotential_sub_min`.
  have h_diff : effectivePotential m k l r - effectivePotentialMin m k l =
    l ^ 2 / (2 * m * r ^ 2) * (1 - m * k * r / l ^ 2) ^ 2 := by
      convert effectivePotential_sub_min hm hk hl hr using 1;
  exact lt_of_sub_pos ( h_diff.symm ▸ mul_pos ( by positivity ) ( sq_pos_of_ne_zero ( sub_ne_zero_of_ne ( by contrapose! hne; unfold circularOrbitRadius at *; rw [ eq_div_iff ] at * <;> nlinarith [ mul_pos hm hk, mul_pos hm hl, mul_pos hk hl ] ) ) ) )

/-- The effective potential has a unique global minimum at r* = l²/(mk),
    with V_eff(r*) = -mk²/(2l²). -/
theorem effective_potential_unique_minimum {m k l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    let r_star := circularOrbitRadius m k l
    let V_min := effectivePotentialMin m k l
    r_star > 0 ∧
    effectivePotential m k l r_star = V_min ∧
    ∀ r, r > 0 → r ≠ r_star → effectivePotential m k l r > V_min := by
  refine ⟨circularOrbitRadius_pos hm hk hl,
         effectivePotential_at_circular hm hk hl,
         fun r hr hne => effectivePotential_gt_min hm hk hl hr hne⟩