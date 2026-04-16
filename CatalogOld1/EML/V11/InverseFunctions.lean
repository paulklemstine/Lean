/-
# EML V11 — Inverse Function Theory

Analysis of EML inverse problems, surjectivity/injectivity,
Lambert W connections, and implicit function theory.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Definitions -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

/-! ## Section 1: Injectivity -/

/-- eml(·, y) is injective (for any fixed y), since exp is injective. -/
theorem eml_injective_x (y : ℝ) : Function.Injective (fun x => eml x y) := by
  intro a b h
  unfold eml at h
  have : Real.exp a = Real.exp b := by linarith
  exact Real.exp_injective this

/-- eml(x, ·) is injective on (0,∞) (for any fixed x), since log is injective there. -/
theorem eml_injective_y_pos (x : ℝ) :
    Set.InjOn (fun y => eml x y) (Set.Ioi 0) := by
  intro a ha b hb h
  unfold eml at h
  have : Real.log a = Real.log b := by linarith
  exact Real.log_injOn_pos ha hb this

/-! ## Section 2: Surjectivity Analysis -/

/-- Range lower bound: eml(x, y) > −log(y) for all x, when y > 0. -/
theorem eml_range_lower (x y : ℝ) :
    eml x y > -Real.log y := by
  unfold eml; linarith [Real.exp_pos x]

/-- eml(·, y) is NOT surjective onto ℝ (range is (−log y, ∞)). -/
theorem eml_not_surjective_x (y : ℝ) :
    ¬Function.Surjective (fun x => eml x y) := by
  intro h
  obtain ⟨x, hx⟩ := h (-Real.log y - 1)
  have := eml_range_lower x y
  linarith

/-- eml(x, ·) IS surjective on (0,∞) → ℝ for any fixed x. -/
theorem eml_surjective_y (x : ℝ) :
    ∀ c : ℝ, ∃ y : ℝ, 0 < y ∧ eml x y = c := by
  intro c
  use Real.exp (Real.exp x - c)
  constructor
  · exact Real.exp_pos _
  · unfold eml; rw [Real.log_exp]; ring

/-- For y = 1: eml(·, 1) = exp is surjective onto (0,∞). -/
theorem eml_y1_range_pos (c : ℝ) (hc : 0 < c) :
    ∃ x : ℝ, eml x 1 = c := by
  use Real.log c
  simp [eml, Real.log_one, Real.exp_log hc]

/-! ## Section 3: Level Sets -/

/-- The level set eml(x,y) = c has the explicit form y = exp(exp(x) − c). -/
theorem eml_level_set (x c : ℝ) :
    eml x (Real.exp (Real.exp x - c)) = c := by
  unfold eml; rw [Real.log_exp]; ring

/-- Level set values are always positive. -/
theorem eml_level_set_pos (x c : ℝ) :
    Real.exp (Real.exp x - c) > 0 := Real.exp_pos _

/-! ## Section 4: Fixed Point Analysis -/

/-- eml(x,y) = x has solution y = exp(exp(x)−x). -/
theorem eml_fixed_x (x : ℝ) :
    eml x (Real.exp (Real.exp x - x)) = x := by
  unfold eml; rw [Real.log_exp]; ring

/-- The equation eml(x,y) = y requires exp(x) = y + log(y). -/
theorem eml_fixed_y_condition (x y : ℝ) :
    eml x y = y ↔ Real.exp x = y + Real.log y := by
  unfold eml; constructor <;> intro h <;> linarith

/-- eml(x,x) = emlDiag(x). -/
theorem eml_diag_eq (x : ℝ) : eml x x = emlDiag x := by
  simp [eml, emlDiag]

/-! ## Section 5: σ range analysis -/

/-- σ is bounded below by 1. -/
theorem emlSelfPair_range_ge_one :
    ∀ x : ℝ, emlSelfPair x ≥ 1 := by
  intro x; unfold emlSelfPair; linarith [Real.add_one_le_exp x]

/-- σ(0) = 1 (the minimum). -/
theorem emlSelfPair_min : emlSelfPair 0 = 1 := by
  unfold emlSelfPair; simp

/-
For any c ≥ 1, there is an x ≥ 0 with σ(x) ≥ c.
-/
theorem emlSelfPair_achieves_nonneg (c : ℝ) (hc : 1 ≤ c) :
    ∃ x : ℝ, 0 ≤ x ∧ emlSelfPair x ≥ c := by
  -- By definition of $emlSelfPair$, we know that $emlSelfPair x = e^x - x$.
  unfold emlSelfPair;
  -- Consider $x = c$.
  use c;
  exact ⟨ by positivity, by have := Real.exp_one_gt_d9.le; norm_num1 at *; rw [ show c = 1 + ( c - 1 ) by ring, Real.exp_add ] ; nlinarith [ Real.add_one_le_exp ( c - 1 ) ] ⟩

/-! ## Section 6: Partial Inverses -/

/-- Solving eml(x,y) = c for x: x = ln(c + ln(y)) when c + ln(y) > 0. -/
theorem eml_solve_x (c y : ℝ) (h : c + Real.log y > 0) :
    eml (Real.log (c + Real.log y)) y = c := by
  unfold eml
  rw [Real.exp_log h]; ring

/-- Solving eml(x,y) = c for y: y = exp(exp(x) − c). -/
theorem eml_solve_y (x c : ℝ) :
    eml x (Real.exp (Real.exp x - c)) = c := eml_level_set x c

/-! ## Section 7: Monotonicity -/

/-- eml is strictly increasing in x. -/
theorem eml_strictMono_x (y : ℝ) : StrictMono (fun x => eml x y) := by
  intro a b hab
  unfold eml
  linarith [Real.exp_strictMono hab]

/-- eml is strictly decreasing in y on (0,∞). -/
theorem eml_strictAnti_y (x : ℝ) : StrictAntiOn (fun y => eml x y) (Set.Ioi 0) := by
  intro a ha b _hb hab
  unfold eml
  linarith [Real.log_lt_log ha hab]

/-! ## Section 8: Image Characterization -/

/-- The image of eml(·, y) is the interval (−log y, ∞). -/
theorem eml_image_x (y : ℝ) :
    Set.range (fun x => eml x y) = Set.Ioi (-Real.log y) := by
  ext c
  simp only [Set.mem_range, Set.mem_Ioi]
  constructor
  · rintro ⟨x, rfl⟩; exact eml_range_lower x y
  · intro hc
    use Real.log (c + Real.log y)
    have hpos : c + Real.log y > 0 := by linarith
    exact eml_solve_x c y hpos

end