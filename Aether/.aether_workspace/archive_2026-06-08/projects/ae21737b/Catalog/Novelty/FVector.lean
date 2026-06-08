import Mathlib
import Novelty.NeuralHodge.Defs

/-!
# f-Vector Theory, Zaslavsky Recurrence, and Euler Characteristic Bounds
-/

open Finset BigOperators

/-! ## Zaslavsky Bound: Basic Properties -/


theorem zaslavsky_recurrence (m : ℕ) {n : ℕ} (hn : 1 ≤ n) :
    zaslavskyBound (m + 1) n = zaslavskyBound m n + zaslavskyBound m (n - 1) := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ zaslavskyBound ];
  · simp +arith +decide [ Finset.sum_range_succ ];
  · induction' n with n ih <;> simp_all +arith +decide [ Nat.choose, Finset.sum_range_succ ]

/-! ## Euler Characteristic Bounds -/

/-
The absolute value of the Euler characteristic is bounded by the total
    face count. This is the triangle inequality for the alternating sum.
-/

theorem refines_totalFaces_le {d : ℕ} {v₁ v₂ : FVectorData d}
    (h : ∀ i, v₁.f i ≤ v₂.f i) : v₁.totalFaces ≤ v₂.totalFaces := by
  exact Finset.sum_le_sum fun i _ => h i

/-
Refinement preserves the Euler characteristic bound.
-/

theorem refines_euler_bound {d : ℕ} {v₁ v₂ : FVectorData d}
    (h : ∀ i, v₁.f i ≤ v₂.f i) : |v₁.eulerChar| ≤ v₂.totalFaces := by
  refine' le_trans ( euler_char_triangle_bound _ ) ( mod_cast refines_totalFaces_le h )