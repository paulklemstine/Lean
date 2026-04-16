/-
# EML V12 — Asymptotic Analysis

Growth rates, limits at infinity, and asymptotic comparisons
for the EML operator, self-pairing σ, and diagonal map d.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set Finset

/-! ## Core Definitions -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-! ## Section 1: σ Growth — Dominated by exp -/

/-- σ(x) ≤ exp(x) for x ≥ 0. -/
theorem emlSelfPair_le_exp (x : ℝ) (hx : 0 ≤ x) :
    emlSelfPair x ≤ Real.exp x := by
  unfold emlSelfPair; linarith

/-- σ(x) = exp(x) − x. -/
theorem emlSelfPair_eq (x : ℝ) : emlSelfPair x = Real.exp x - x := rfl

/-- For x ≥ 1: exp(x)/2 ≤ σ(x) ≤ exp(x). -/
theorem emlSelfPair_sandwich (x : ℝ) (hx : 1 ≤ x) :
    Real.exp x / 2 ≤ emlSelfPair x ∧ emlSelfPair x ≤ Real.exp x := by
  unfold emlSelfPair
  constructor
  · have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ x by linarith) 3
    simp [sum_range_succ] at h3; nlinarith [sq_nonneg (x - 1)]
  · linarith

/-- σ(x)/exp(x) → 1 as x → +∞. -/
theorem emlSelfPair_over_exp_tendsto :
    Tendsto (fun x => emlSelfPair x / Real.exp x) atTop (nhds 1) := by
  have heq : (fun x => emlSelfPair x / Real.exp x) = (fun x => 1 - x * Real.exp (-x)) := by
    ext x; unfold emlSelfPair; rw [Real.exp_neg]; field_simp
  rw [heq]
  have h : Tendsto (fun x : ℝ => x * Real.exp (-x)) atTop (nhds 0) :=
    tendsto_pow_mul_exp_neg_atTop_nhds_zero 1 |>.congr (by simp)
  convert h.const_sub 1 using 1; ring

/-! ## Section 2: σ at −∞ -/

/-- For x ≤ 0: σ(x) ≥ −x (since exp ≥ 0). -/
theorem emlSelfPair_ge_neg (x : ℝ) (hx : x ≤ 0) :
    emlSelfPair x ≥ -x := by
  unfold emlSelfPair; linarith [Real.exp_pos x]

/-- For x ≤ -1: −x ≤ σ(x) ≤ −x + 1. -/
theorem emlSelfPair_approx_neg (x : ℝ) (hx : x ≤ -1) :
    -x ≤ emlSelfPair x ∧ emlSelfPair x ≤ -x + 1 := by
  unfold emlSelfPair
  constructor
  · linarith [Real.exp_pos x]
  · linarith [Real.exp_le_one_iff.mpr (by linarith)]

/-! ## Section 3: Diagonal Map Growth -/

/-- d(z) ≥ z + 1 for z ≥ 1 (key growth lemma). -/
theorem emlDiag_ge_succ (z : ℝ) (hz : 1 ≤ z) : emlDiag z ≥ z + 1 := by
  unfold emlDiag
  have h1 : Real.log z ≤ z - 1 := Real.log_le_sub_one_of_pos (by linarith)
  have h2 : Real.exp z ≥ 2 * z := by
    have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ z by linarith) 3
    simp [sum_range_succ] at h3; nlinarith [sq_nonneg (z - 1)]
  linarith

/-- d(z) ≥ exp(z)/2 for z ≥ 1 (exponential growth). -/
theorem emlDiag_exp_growth (z : ℝ) (hz : 1 ≤ z) :
    emlDiag z ≥ Real.exp z / 2 := by
  unfold emlDiag
  have h1 : Real.log z ≤ z - 1 := Real.log_le_sub_one_of_pos (by linarith)
  have h2 : Real.exp z ≥ 2 * z := by
    have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ z by linarith) 3
    simp [sum_range_succ] at h3; nlinarith [sq_nonneg (z - 1)]
  linarith

/-! ## Section 4: EML Limits -/

/-- eml(x, 1) → +∞ as x → +∞. -/
theorem eml_tendsto_top :
    Tendsto (fun x => eml x 1) atTop atTop := by
  simp only [eml, Real.log_one, sub_zero]
  exact Real.tendsto_exp_atTop

/-- σ(x) → +∞ as x → +∞. -/
theorem emlSelfPair_tendsto_top :
    Tendsto emlSelfPair atTop atTop := by
  rw [Filter.tendsto_atTop]; intro b
  filter_upwards [Filter.Ioi_mem_atTop (2 * (|b| + 1))] with x hx
  unfold emlSelfPair; simp only [Set.mem_Ioi] at hx
  have hx0 : x > 0 := by linarith [abs_nonneg b]
  have h := Real.sum_le_exp_of_nonneg (le_of_lt hx0) 3
  simp [sum_range_succ] at h
  nlinarith [le_abs_self b, sq_nonneg (x - 2), abs_nonneg b]

/-- σ(x) → +∞ as x → −∞. -/
theorem emlSelfPair_tendsto_neg_top :
    Tendsto emlSelfPair atBot atTop := by
  rw [Filter.tendsto_atTop]; intro b
  filter_upwards [Filter.Iio_mem_atBot (-(b + 1))] with x hx
  unfold emlSelfPair; simp only [Set.mem_Iio] at hx
  linarith [Real.exp_pos x]

/-! ## Section 5: E-Tower Growth -/

/-- eTower n ≥ n for all n. -/
theorem eTower_ge_nat (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    simp only [eTower]
    have := Real.add_one_le_exp (eTower n)
    push_cast; linarith

/-- The e-tower grows at least exponentially: eTower(n+1) ≥ e · eTower(n). -/
theorem eTower_exp_growth (n : ℕ) : eTower (n + 1) ≥ Real.exp 1 * eTower n := by
  simp only [eTower]
  have hge : eTower n ≥ 1 := by
    induction n with
    | zero => simp [eTower]
    | succ n _ => simp only [eTower]; linarith [Real.add_one_le_exp (eTower n)]
  rw [show eTower n = 1 + (eTower n - 1) by ring, Real.exp_add]
  nlinarith [Real.add_one_le_exp (eTower n - 1), Real.exp_pos 1, Real.exp_pos (eTower n - 1)]

/-! ## Section 6: σ dominates identity -/

/-- σ(x) ≥ 1 for all x (fundamental lower bound). -/
theorem emlSelfPair_ge_one (x : ℝ) : emlSelfPair x ≥ 1 := by
  unfold emlSelfPair; linarith [Real.add_one_le_exp x]

/-- σ(x) ≥ 1 + x²/2 for x ≥ 0 (quadratic lower bound). -/
theorem emlSelfPair_ge_quad (x : ℝ) (hx : 0 ≤ x) : emlSelfPair x ≥ 1 + x ^ 2 / 2 := by
  unfold emlSelfPair
  have h := Real.sum_le_exp_of_nonneg hx 3
  simp [sum_range_succ] at h; linarith

end
