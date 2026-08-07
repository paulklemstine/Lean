import Mathlib

/-! # CatalogBuild.Pythagorean.TropicalSPB

Tropical analogue of the "special Pythagorean bracket" `spb x y = (x+y)/(1-xy)`.

Under the tropical dictionary `(·+·) ↦ max`, `(·*·) ↦ (·+·)`, `1 ↦ 0`, the
bracket becomes

`tspb x y = max x y - max 0 (x + y)`,

which is the definition used throughout this file.  (The file previously relied
on an external definition that no longer exists in the catalogue; the definition
is now supplied here so that the module is self-contained and compiles.)
-/

noncomputable section

/-- The tropical special Pythagorean bracket. -/
def tspb (x y : ℝ) : ℝ := max x y - max 0 (x + y)

/-- Tropical SPB is commutative. -/
theorem tspb_comm (x y : ℝ) : tspb x y = tspb y x := by
  unfold tspb; simp [max_comm, add_comm]

/-- tspb for non-negative inputs: tspb(x,y) = -min(x,y) when x,y ≥ 0. -/
theorem tspb_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y = -min x y := by
  unfold tspb
  cases le_total x y <;> cases max_cases x y <;> cases max_cases (0:ℝ) (x + y) <;>
    simp_all <;> linarith

/-- tspb for non-positive inputs: tspb(x,y) = max(x,y). -/
theorem tspb_nonpos (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    tspb x y = max x y := by
  unfold tspb
  cases max_cases x y <;> cases max_cases (0:ℝ) (x + y) <;> simp_all <;> linarith

/-- tspb(x, 0) = 0 for x ≥ 0 (0 absorbs nonnegative inputs). -/
theorem tspb_zero_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x 0 = 0 := by
  unfold tspb
  cases max_cases x (0:ℝ) <;> cases max_cases (0:ℝ) (x + 0) <;> simp_all

/-- `0` is absorbing on the right for every real input. -/
theorem tspb_zero_absorb (x : ℝ) : tspb x 0 = 0 := by
  unfold tspb
  cases max_cases x (0:ℝ) <;> cases max_cases (0:ℝ) (x + 0) <;> simp_all

/-- Since `0` is absorbing, no element can be a two-sided identity. -/
theorem tspb_no_global_identity :
    ¬ ∃ e : ℝ, ∀ x : ℝ, tspb x e = x := by
  rintro ⟨e, he⟩
  have hae : -e ≤ |e| := neg_le_abs e
  have hae' : e ≤ |e| := le_abs_self e
  have h2 := he (|e| + 1)
  unfold tspb at h2
  rw [max_eq_left (by linarith), max_eq_right (by linarith)] at h2
  linarith

theorem tspb_self_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x x = -x := by
  unfold tspb
  cases max_cases (0:ℝ) (x + x) <;> simp_all

/-- Specific computation: tspb(1,1) = -1. -/
theorem tspb_one_one : tspb 1 1 = -1 := by
  unfold tspb; norm_num

end