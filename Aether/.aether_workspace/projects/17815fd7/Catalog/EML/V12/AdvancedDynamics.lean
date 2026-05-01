import Mathlib

/-! # CatalogBuild.EML.V12.AdvancedDynamics

Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 21
-/

noncomputable section

/-- d(0) = 1 (since log(0) = 0 in Mathlib). -/
theorem emlDiag_zero : emlDiag 0 = 1 := by
  simp [emlDiag, Real.log_zero]

/-- d(1) = e (since log(1) = 0). -/
theorem emlDiag_one : emlDiag 1 = Real.exp 1 := by
  simp [emlDiag, Real.log_one]

/-- d(e) = eᵉ − 1. -/
theorem emlDiag_e : emlDiag (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  simp [emlDiag, Real.log_exp]

/-- d is continuous on (0,∞). -/
theorem emlDiag_continuousOn : ContinuousOn emlDiag (Set.Ioi 0) := by
  unfold emlDiag
  exact continuousOn_exp.sub (Real.continuousOn_log.mono (fun x hx => ne_of_gt hx))

/-- d(z) > 0 for z ≥ 0. -/
theorem emlDiag_pos_nonneg (z : ℝ) (hz : 0 ≤ z) : emlDiag z > 0 := by
  unfold emlDiag
  by_cases hz' : z = 0
  · norm_num [hz']
  · linarith [Real.add_one_le_exp z,
      Real.log_le_sub_one_of_pos (lt_of_le_of_ne hz (Ne.symm hz'))]

/-- Key step lemma: d(z) ≥ z + 1 for z ≥ 1. -/
theorem emlDiag_step (z : ℝ) (hz : 1 ≤ z) : emlDiag z ≥ z + 1 := by
  unfold emlDiag
  have h1 : Real.log z ≤ z - 1 := Real.log_le_sub_one_of_pos (by linarith)
  have h2 : Real.exp z ≥ 2 * z := by
    have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ z by linarith) 3
    simp [sum_range_succ] at h3; nlinarith [sq_nonneg (z - 1)]
  linarith

/-- Linear orbit bound: dⁿ(z) ≥ z + n for z ≥ 1. -/
theorem emlDiagIter_linear (n : ℕ) (z : ℝ) (hz : 1 ≤ z) :
    emlDiagIter n z ≥ z + n := by
  induction n with
  | zero => simp [emlDiagIter]
  | succ n ih =>
    simp only [emlDiagIter]
    have h1 : emlDiagIter n z ≥ 1 := by linarith
    push_cast; linarith [emlDiag_step _ h1]

/-- All orbits of d from z ≥ 1 escape to +∞. -/
theorem emlDiagIter_tendsto_top (z : ℝ) (hz : 1 ≤ z) :
    Tendsto (fun n => emlDiagIter n z) atTop atTop := by
  rw [tendsto_atTop]; intro b; simp only [eventually_atTop]
  exact ⟨⌈b - z⌉₊, fun n hn => by
    linarith [emlDiagIter_linear n z hz, Nat.le_ceil (b - z),
      show (⌈b - z⌉₊ : ℝ) ≤ n from Nat.cast_le.mpr hn]⟩

/-- After one step from z ≥ 1: d(z) ≥ exp(z)/2 (exponential amplification). -/
theorem emlDiag_exp_amplify (z : ℝ) (hz : 1 ≤ z) :
    emlDiag z ≥ Real.exp z / 2 := by
  unfold emlDiag
  have h1 : Real.log z ≤ z - 1 := Real.log_le_sub_one_of_pos (by linarith)
  have h2 : Real.exp z ≥ 2 * z := by
    have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ z by linarith) 3
    simp [sum_range_succ] at h3; nlinarith [sq_nonneg (z - 1)]
  linarith

/-- Two-step super-exponential: d²(z) ≥ exp(exp(z)/2)/2 for z ≥ 1. -/
theorem emlDiag_two_step (z : ℝ) (hz : 1 ≤ z) :
    emlDiagIter 2 z ≥ Real.exp (Real.exp z / 2) / 2 := by
  simp [emlDiagIter]
  have h1 := emlDiag_exp_amplify z hz
  have h2 : emlDiag z ≥ 1 := by linarith [emlDiag_ge_two z hz]
  have h3 := emlDiag_exp_amplify (emlDiag z) h2
  calc emlDiag (emlDiag z) ≥ Real.exp (emlDiag z) / 2 := h3
    _ ≥ Real.exp (Real.exp z / 2) / 2 := by
        apply div_le_div_of_nonneg_right _ (by norm_num : (0:ℝ) ≤ 2) |>.ge
        exact Real.exp_le_exp.mpr h1

/-- σ has no fixed points: σ(x) = x ↔ exp(x) = 2x. -/
theorem emlSelfPair_fixedPoint_iff (x : ℝ) :
    emlSelfPair x = x ↔ Real.exp x = 2 * x := by
  unfold emlSelfPair; constructor <;> intro h <;> linarith

/-- σ(0) ≠ 0. -/
theorem emlSelfPair_no_fix_zero : emlSelfPair 0 ≠ 0 := by
  unfold emlSelfPair; simp

/-- σ(x) > x for all x (σ has no fixed points). -/
theorem emlSelfPair_gt (x : ℝ) : emlSelfPair x > x := by
  unfold emlSelfPair
  have := Real.exp_one_gt_d9.le
  rw [show Real.exp x = Real.exp 1 * Real.exp (x - 1) by rw [← Real.exp_add]; ring_nf]
  nlinarith [Real.add_one_le_exp (x - 1), Real.exp_pos (x - 1)]

/-- Iterated self-pairing. -/
def emlSelfPairIter : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => emlSelfPair (emlSelfPairIter n x)

/-- σⁿ⁺¹(x) > σⁿ(x) (orbits are strictly increasing). -/
theorem emlSelfPairIter_strictMono (n : ℕ) (x : ℝ) :
    emlSelfPairIter (n + 1) x > emlSelfPairIter n x := by
  simp [emlSelfPairIter]; exact emlSelfPair_gt _

/-- d'(z) = exp(z) − 1/z for z ≠ 0. -/
theorem emlDiag_deriv_value (z : ℝ) (hz : z ≠ 0) :
    HasDerivAt emlDiag (Real.exp z - z⁻¹) z :=
  (Real.hasDerivAt_exp z).sub (Real.hasDerivAt_log hz)

/-- |d'(z)| > 1 for z ≥ 1 (expansive dynamics ↔ positive Lyapunov exponent). -/
theorem emlDiag_deriv_gt_one (z : ℝ) (hz : 1 ≤ z) :
    Real.exp z - z⁻¹ > 1 := by
  field_simp
  nlinarith [Real.add_one_lt_exp (show z ≠ 0 by linarith), Real.exp_pos z]

/-- The "damped" diagonal map: d_α(z) = α·exp(z) + (1−α)·z − log(z). -/
def emlDiagDamped (α z : ℝ) : ℝ := α * Real.exp z + (1 - α) * z - Real.log z

/-- The damped map reduces to the original when α = 1. -/
theorem emlDiagDamped_one (z : ℝ) : emlDiagDamped 1 z = emlDiag z := by
  simp [emlDiagDamped, emlDiag]

/-- The damped map at α = 0 is z − log(z). -/
theorem emlDiagDamped_zero (z : ℝ) : emlDiagDamped 0 z = z - Real.log z := by
  simp [emlDiagDamped]

/-- For z > 0 and α ∈ [0,1]: d_α(z) > 0. -/
theorem emlDiagDamped_pos (α z : ℝ) (hα : 0 ≤ α) (_hα1 : α ≤ 1) (hz : 0 < z) :
    emlDiagDamped α z > 0 := by
  unfold emlDiagDamped
  -- α·exp(z) + (1-α)·z ≥ α·z + (1-α)·z = z (since exp(z) ≥ z for z > 0)
  -- And z - log(z) ≥ 1 for z > 0 (from log z ≤ z - 1)
  have h1 : α * Real.exp z + (1 - α) * z ≥ z := by
    nlinarith [Real.add_one_le_exp z]
  have h2 : Real.log z ≤ z - 1 := Real.log_le_sub_one_of_pos hz
  linarith

end
