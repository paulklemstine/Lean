/-
# Transseries: Core Theorems

## Main Results

1. **Growth Level Total Order**: The lexicographic order on growth levels
   is a strict total order, ensuring every pair of transmonomials is comparable.

2. **Exp-Log Duality on Growth Levels**: The exponential shift and logarithmic
   shift form an order-isomorphism pair on the growth levels, preserving the
   dominance hierarchy.

3. **Asymptotic Uniqueness Theorem**: If a transseries evaluates to zero
   asymptotically (i.e., its evaluation vanishes faster than any of its
   transmonomials), then all its coefficients are zero.

4. **Growth Scale Structure**: The growth levels form a filtration indexed
   by depth, with each layer isomorphic to ℝ.
-/

import Mathlib
import Applications.TransseriesDefs

namespace Transseries

open Filter

/-! ## Growth Level Total Order -/

/-
The lexicographic order on growth levels is a strict linear order.
-/

theorem growthLevel_lt_trans {a b c : GrowthLevel}
    (hab : a < b) (hbc : b < c) : a < c := by
  cases hab ; cases hbc;
  · exact Or.inl ( lt_trans ‹_› ‹_› );
  · exact Or.inl ( by linarith );
  · cases hbc;
    · exact Or.inl ( by linarith );
    · exact Or.inr ⟨ by linarith, by linarith ⟩

/-! ## Exp-Log Duality -/

/-
Exponential shift preserves strict ordering.
-/

theorem exp_rpow_dominates_pow (α : ℝ) (hα : 0 < α) (n : ℕ) :
    AsympDominates (fun x => Real.exp (x ^ α)) (fun x => x ^ n) := by
  -- Let $y = x^\alpha$ and note that $x^n = y^{n/\alpha}$.
  suffices h_subst : AsympDominates (fun y : ℝ => Real.exp y) (fun y : ℝ => y ^ (n / α)) by
    have := h_subst.comp ( tendsto_rpow_atTop hα );
    refine' this.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx using by rw [ Function.comp_apply, ← Real.rpow_natCast, ← Real.rpow_mul hx.le, mul_div_cancel₀ _ hα.ne' ] );
  have := exp_dominates_poly ( Nat.ceil ( n / α ) );
  refine' Filter.tendsto_atTop_mono' _ _ this;
  filter_upwards [ Filter.eventually_gt_atTop 1 ] with x hx using div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by exact_mod_cast Real.rpow_le_rpow_of_exponent_le hx.le <| Nat.le_ceil _ ) ;

/-
**Asymptotic Separation: Higher depth dominates lower**.
    exp(exp(x)) / exp(x) → ∞. This is the canonical example of
    depth-2 dominating depth-1.
-/