import Mathlib
import Pythagorean.Core

/-! # CatalogBuild.Pythagorean.TropicalSPB

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 9
-/

noncomputable section

/-- Tropical SPB is commutative. -/
theorem tspb_comm (x y : ℝ) : tspb x y = tspb y x := by
  unfold tspb; simp [max_comm, add_comm]

/-- tspb for non-negative inputs: tspb(x,y) = -min(x,y) when x,y ≥ 0. -/
theorem tspb_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y = -min x y := by
  unfold tspb; cases le_total x y <;> simp +decide [ * ] ;
  · rw [ max_eq_right ] <;> linarith;
  · rw [ max_eq_right ] <;> linarith

/-- tspb for non-positive inputs: tspb(x,y) = max(x,y). -/
theorem tspb_nonpos (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    tspb x y = max x y := by
  unfold tspb; cases max_cases x y <;> simp +decide [ * ] ;
  · linarith;
  · linarith

/-- tspb(x, 0) = 0 for x ≥ 0 (0 absorbs nonnegative inputs). -/
theorem tspb_zero_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x 0 = 0 := by
  unfold tspb; grind

/-- [Section: # CatalogBuild.Pythagorean.TropicalSPB
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 9] -/
theorem tspb_zero_absorb (x : ℝ) : tspb x 0 = 0 := by
  unfold tspb;
  grind

/-- [Section: # CatalogBuild.Pythagorean.TropicalSPB
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 9] -/
theorem tspb_no_global_identity :
    ¬ ∃ e : ℝ, ∀ x : ℝ, tspb x e = x := by
  simp +zetaDelta at *;
  intro x;
  by_cases hx : x ≤ 0;
  · unfold tspb;
    exact ⟨ x - 1, by cases max_cases ( x - 1 ) x <;> cases max_cases 0 ( x - 1 + x ) <;> linarith ⟩;
  · exact ⟨ 1, by unfold tspb; cases max_cases ( 1 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) ( 1 + x ) <;> linarith ⟩

  unfold tspb; norm_num; cases max_cases x x <;> cases max_cases 0 ( 2 * x ) <;> linarith;

theorem tspb_self_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x x = -x := by
  unfold tspb
  simp [max_self, hx]

/-- Specific computation: tspb(1,1) = -1. -/
theorem tspb_one_one : tspb 1 1 = -1 := by
  unfold tspb; norm_num [max_def]

end
