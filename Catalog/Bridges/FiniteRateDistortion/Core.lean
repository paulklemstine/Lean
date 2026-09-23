import Mathlib

/-!
# Finite rate–distortion theory: channels, mutual information, and the Lagrangian dual

This module supplies the objects used by
`Bridges/FiniteRateDistortion/TropicalEnvelope.lean`, which referred to a finite
rate-distortion vocabulary that no module in the catalog provided.

Everything is finite and elementary:

* `FinProbDist α`, `Channel α β` — a source distribution and a test channel;
* `mutualInfo`, `distortion` — the two functionals of a channel;
* `rateDistortion μ d D` — the infimum of the mutual information over channels meeting
  the distortion constraint;
* `lagrangianDual μ d s` — the infimum of `I(W) + s · d(W)`;
* `lagrangianDual_le_rateDistortion` — **weak duality**: `Φ(s) - s·D ≤ R(D)` for every
  slope `s ≥ 0`, the affine lower bound whose tropical envelope is studied downstream.

The only analytic input is the elementary estimate `w · log (w / q) ≥ -q/e`
(`neg_div_exp_one_le_mul_log_div`), which makes the Lagrangian set bounded below, so the
infima are genuine.
-/

open Finset

noncomputable section

namespace FiniteRateDistortion

variable {α β : Type*} [Fintype α] [Fintype β]

/-! ## Sources and channels -/

/-- A probability distribution on a finite alphabet. -/
structure FinProbDist (α : Type*) [Fintype α] where
  /-- The probability mass. -/
  mass : α → ℝ
  /-- Masses are nonnegative. -/
  mass_nonneg : ∀ a, 0 ≤ mass a
  /-- Masses sum to one. -/
  mass_sum_one : ∑ a, mass a = 1

/-- A test channel from `α` to `β`: a stochastic matrix. -/
structure Channel (α β : Type*) [Fintype α] [Fintype β] where
  /-- Transition probabilities. -/
  prob : α → β → ℝ
  /-- Transition probabilities are nonnegative. -/
  prob_nonneg : ∀ a b, 0 ≤ prob a b
  /-- Each row sums to one. -/
  prob_sum_one : ∀ a, ∑ b, prob a b = 1

/-- The output distribution induced by a source and a channel. -/
def outMass (μ : FinProbDist α) (W : Channel α β) (b : β) : ℝ :=
  ∑ a, μ.mass a * W.prob a b

theorem outMass_nonneg (μ : FinProbDist α) (W : Channel α β) (b : β) : 0 ≤ outMass μ W b :=
  Finset.sum_nonneg fun a _ => mul_nonneg (μ.mass_nonneg a) (W.prob_nonneg a b)

/-- The joint distribution is normalised. -/
theorem joint_sum_eq_one (μ : FinProbDist α) (W : Channel α β) :
    ∑ a, ∑ b, μ.mass a * W.prob a b = 1 := by
  have h : ∀ a : α, ∑ b, μ.mass a * W.prob a b = μ.mass a := by
    intro a; rw [← Finset.mul_sum, W.prob_sum_one a, mul_one]
  simp_rw [h]
  exact μ.mass_sum_one

/-- The output distribution is normalised. -/
theorem sum_outMass_eq_one (μ : FinProbDist α) (W : Channel α β) :
    ∑ b, outMass μ W b = 1 := by
  unfold outMass
  rw [Finset.sum_comm]
  exact joint_sum_eq_one μ W

/-! ## The elementary entropy estimate -/

/-- `log u ≤ u / e`, the tangent bound at `u = e`. -/
theorem log_le_div_exp_one {u : ℝ} (hu : 0 < u) : Real.log u ≤ u / Real.exp 1 := by
  have h := Real.log_le_sub_one_of_pos (x := u / Real.exp 1) (by positivity)
  rw [Real.log_div hu.ne' (Real.exp_ne_zero 1), Real.log_exp] at h
  linarith

/-- `w · log (w / q) ≥ -q/e` for nonnegative `w, q` (with Lean's junk conventions at
`0`).  This is what keeps the information functional bounded below. -/
theorem neg_div_exp_one_le_mul_log_div {w q : ℝ} (hw : 0 ≤ w) (hq : 0 ≤ q) :
    -(q / Real.exp 1) ≤ w * Real.log (w / q) := by
  rcases eq_or_lt_of_le hw with hw0 | hw0
  · simp [← hw0]
    positivity
  rcases eq_or_lt_of_le hq with hq0 | hq0
  · simp [← hq0]
  · have h1 : Real.log (q / w) ≤ (q / w) / Real.exp 1 := log_le_div_exp_one (by positivity)
    have h2 : Real.log (q / w) = - Real.log (w / q) := by
      rw [← Real.log_inv]; congr 1; field_simp
    have h3 : -Real.log (w / q) ≤ (q / w) / Real.exp 1 := by rw [← h2]; exact h1
    have h4 : w * (-Real.log (w / q)) ≤ w * ((q / w) / Real.exp 1) :=
      mul_le_mul_of_nonneg_left h3 hw0.le
    have h5 : w * ((q / w) / Real.exp 1) = q / Real.exp 1 := by field_simp
    rw [h5] at h4
    linarith

/-! ## Mutual information and distortion -/

/-- The mutual information of a source and a test channel. -/
def mutualInfo (μ : FinProbDist α) (W : Channel α β) : ℝ :=
  ∑ a, ∑ b, μ.mass a * W.prob a b * Real.log (W.prob a b / outMass μ W b)

/-- Mutual information is bounded below by `-1/e`.  (The sharp bound is `0`; this crude
version is all that is needed to make the infima below well posed.) -/
theorem mutualInfo_lower_bound (μ : FinProbDist α) (W : Channel α β) :
    -(1 / Real.exp 1) ≤ mutualInfo μ W := by
  have hterm : ∀ a : α, ∀ b : β,
      -(μ.mass a * (outMass μ W b / Real.exp 1))
        ≤ μ.mass a * W.prob a b * Real.log (W.prob a b / outMass μ W b) := by
    intro a b
    have h := neg_div_exp_one_le_mul_log_div (w := W.prob a b) (q := outMass μ W b)
      (W.prob_nonneg a b) (outMass_nonneg μ W b)
    have h2 := mul_le_mul_of_nonneg_left h (μ.mass_nonneg a)
    calc -(μ.mass a * (outMass μ W b / Real.exp 1))
        = μ.mass a * -(outMass μ W b / Real.exp 1) := by ring
      _ ≤ μ.mass a * (W.prob a b * Real.log (W.prob a b / outMass μ W b)) := h2
      _ = μ.mass a * W.prob a b * Real.log (W.prob a b / outMass μ W b) := by ring
  have key : ∀ a : α, ∑ b, -(μ.mass a * (outMass μ W b / Real.exp 1))
      = -(μ.mass a * (1 / Real.exp 1)) := by
    intro a
    have h1 : ∑ b, -(μ.mass a * (outMass μ W b / Real.exp 1))
        = -(μ.mass a / Real.exp 1) * ∑ b, outMass μ W b := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl (fun b _ => by ring)
    rw [h1, sum_outMass_eq_one]
    ring
  have hsum : ∑ a : α, ∑ b : β, -(μ.mass a * (outMass μ W b / Real.exp 1))
      = -(1 / Real.exp 1) := by
    rw [Finset.sum_congr rfl (fun a _ => key a)]
    have h2 : ∑ a : α, -(μ.mass a * (1 / Real.exp 1))
        = -(1 / Real.exp 1) * ∑ a : α, μ.mass a := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl (fun a _ => by ring)
    rw [h2, μ.mass_sum_one, mul_one]
  calc -(1 / Real.exp 1)
      = ∑ a : α, ∑ b : β, -(μ.mass a * (outMass μ W b / Real.exp 1)) := hsum.symm
    _ ≤ mutualInfo μ W :=
        Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => hterm a b

/-- The expected distortion of a test channel. -/
def distortion (μ : FinProbDist α) (d : α → β → ℝ) (W : Channel α β) : ℝ :=
  ∑ a, ∑ b, μ.mass a * W.prob a b * d a b

/-- A crude a-priori bound on the size of the distortion measure. -/
def distortionBudget (d : α → β → ℝ) : ℝ := ∑ a, ∑ b, |d a b|

/-- The distortion of any channel is bounded below by minus the budget. -/
theorem distortion_lower_bound (μ : FinProbDist α) (d : α → β → ℝ) (W : Channel α β) :
    -distortionBudget d ≤ distortion μ d W := by
  have hle : ∀ a : α, ∀ b : β, -distortionBudget d ≤ d a b := by
    intro a b
    have h1 : |d a b| ≤ ∑ b', |d a b'| :=
      Finset.single_le_sum (f := fun b' => |d a b'|) (fun b' _ => abs_nonneg _)
        (Finset.mem_univ b)
    have h2 : ∑ b', |d a b'| ≤ distortionBudget d :=
      Finset.single_le_sum (f := fun a' => ∑ b', |d a' b'|)
        (fun a' _ => Finset.sum_nonneg fun b' _ => abs_nonneg _) (Finset.mem_univ a)
    have h3 : -(d a b) ≤ |d a b| := neg_le_abs _
    linarith
  have hterm : ∀ a : α, ∀ b : β,
      μ.mass a * W.prob a b * (-distortionBudget d) ≤ μ.mass a * W.prob a b * d a b := by
    intro a b
    exact mul_le_mul_of_nonneg_left (hle a b)
      (mul_nonneg (μ.mass_nonneg a) (W.prob_nonneg a b))
  have hsum : ∑ a : α, ∑ b : β, μ.mass a * W.prob a b * (-distortionBudget d)
      = -distortionBudget d := by
    have h1 : ∀ a : α, ∑ b : β, μ.mass a * W.prob a b * (-distortionBudget d)
        = (∑ b : β, μ.mass a * W.prob a b) * (-distortionBudget d) := by
      intro a; rw [Finset.sum_mul]
    rw [Finset.sum_congr rfl (fun a _ => h1 a), ← Finset.sum_mul, joint_sum_eq_one, one_mul]
  calc -distortionBudget d
      = ∑ a : α, ∑ b : β, μ.mass a * W.prob a b * (-distortionBudget d) := hsum.symm
    _ ≤ distortion μ d W :=
        Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => hterm a b

/-! ## The rate–distortion function and its Lagrangian dual -/

/-- A distortion level is feasible when some channel achieves it. -/
def FeasibleDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ W : Channel α β, distortion μ d W ≤ D

/-- The set of achievable rates at distortion level `D`. -/
def rateDistortionSet (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r | ∃ W : Channel α β, distortion μ d W ≤ D ∧ mutualInfo μ W = r}

/-- The rate–distortion function. -/
def rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (rateDistortionSet μ d D)

/-- The set of Lagrangian values at slope `s`. -/
def lagrangianDualSet (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : Set ℝ :=
  {r | ∃ W : Channel α β, mutualInfo μ W + s * distortion μ d W = r}

/-- The Lagrangian dual value at slope `s`. -/
def lagrangianDual (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : ℝ :=
  sInf (lagrangianDualSet μ d s)

/-- For nonnegative slope the Lagrangian set is bounded below, so its infimum is
meaningful. -/
theorem bddBelow_lagrangianDualSet (μ : FinProbDist α) (d : α → β → ℝ) {s : ℝ} (hs : 0 ≤ s) :
    BddBelow (lagrangianDualSet μ d s) := by
  refine ⟨-(1 / Real.exp 1) + s * (-distortionBudget d), ?_⟩
  rintro r ⟨W, rfl⟩
  have h1 := mutualInfo_lower_bound μ W
  have h2 : s * (-distortionBudget d) ≤ s * distortion μ d W :=
    mul_le_mul_of_nonneg_left (distortion_lower_bound μ d W) hs
  linarith

/-- **Weak duality.**  Each slope `s ≥ 0` gives an affine lower bound on the
rate–distortion function. -/
theorem lagrangianDual_le_rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ)
    (hs : 0 ≤ s) (D : ℝ) (hD : FeasibleDistortion μ d D) :
    lagrangianDual μ d s - s * D ≤ rateDistortion μ d D := by
  obtain ⟨W₀, hW₀⟩ := hD
  have hne : (rateDistortionSet μ d D).Nonempty := ⟨mutualInfo μ W₀, W₀, hW₀, rfl⟩
  refine le_csInf hne ?_
  rintro r ⟨W, hWD, rfl⟩
  have h1 : lagrangianDual μ d s ≤ mutualInfo μ W + s * distortion μ d W :=
    csInf_le (bddBelow_lagrangianDualSet μ d hs) ⟨W, rfl⟩
  have h2 : s * distortion μ d W ≤ s * D := mul_le_mul_of_nonneg_left hWD hs
  linarith

end FiniteRateDistortion