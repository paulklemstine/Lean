import Mathlib

/-!
# Finite rate–distortion theory: definitions and weak duality

`Bridges/FiniteRateDistortion/TropicalEnvelope.lean` studies the piecewise-linear
(tropical) envelope of the rate–distortion function, but the underlying information
theory it is written against was absent from this repository, so the file did not
compile.  This module supplies it:

* `FinProbDist`, `Channel`, `outMarginal` — the finite source and channel model;
* `mutualInfo`, `expectedDistortion` — the two functionals;
* `mutualInfo_nonneg` — the information inequality `I(X;Y) ≥ 0`, proved from
  `log t ≤ t − 1` termwise;
* `rateDistortion`, `lagrangianDual`, `FeasibleDistortion` — the primal and the
  Lagrangian dual;
* `lagrangianDual_le_rateDistortion` — **weak duality**: every dual parameter `s ≥ 0`
  yields the affine lower bound `Φ(s) − s·D ≤ R(D)`.
-/

open Finset

noncomputable section

variable {α β : Type*} [Fintype α] [Fintype β]

/-- A probability distribution on a finite type. -/
structure FinProbDist (α : Type*) [Fintype α] where
  /-- The probability mass function. -/
  prob : α → ℝ
  /-- Masses are nonnegative. -/
  nonneg : ∀ a, 0 ≤ prob a
  /-- Masses sum to one. -/
  sum_one : ∑ a, prob a = 1

/-- A channel: a conditional distribution on `β` for each input in `α`. -/
structure Channel (α β : Type*) [Fintype α] [Fintype β] where
  /-- The conditional probabilities. -/
  cond : α → β → ℝ
  /-- Conditional probabilities are nonnegative. -/
  nonneg : ∀ a b, 0 ≤ cond a b
  /-- Each row is a probability distribution. -/
  row_sum : ∀ a, ∑ b, cond a b = 1

/-- The output marginal of a source through a channel. -/
def outMarginal (μ : FinProbDist α) (W : Channel α β) (b : β) : ℝ :=
  ∑ a, μ.prob a * W.cond a b

/-- The mutual information `I(X;Y)` of the joint law `μ ⊗ W`. -/
def mutualInfo (μ : FinProbDist α) (W : Channel α β) : ℝ :=
  ∑ a, ∑ b, μ.prob a * W.cond a b * Real.log (W.cond a b / outMarginal μ W b)

/-- The expected distortion of a channel with respect to a distortion measure `d`. -/
def expectedDistortion (μ : FinProbDist α) (W : Channel α β) (d : α → β → ℝ) : ℝ :=
  ∑ a, ∑ b, μ.prob a * W.cond a b * d a b

theorem outMarginal_nonneg (μ : FinProbDist α) (W : Channel α β) (b : β) :
    0 ≤ outMarginal μ W b :=
  Finset.sum_nonneg fun a _ => mul_nonneg (μ.nonneg a) (W.nonneg a b)

theorem outMarginal_sum_one (μ : FinProbDist α) (W : Channel α β) :
    ∑ b, outMarginal μ W b = 1 := by
  simp only [outMarginal]
  rw [Finset.sum_comm]
  simp_rw [← Finset.mul_sum, W.row_sum]
  simpa using μ.sum_one

/-- Termwise form of the information inequality. -/
theorem mutualInfo_term_bound (μ : FinProbDist α) (W : Channel α β) (a : α) (b : β) :
    μ.prob a * W.cond a b - μ.prob a * outMarginal μ W b
      ≤ μ.prob a * W.cond a b * Real.log (W.cond a b / outMarginal μ W b) := by
  rcases eq_or_lt_of_le (μ.nonneg a) with hm | hm
  · simp [← hm]
  rcases eq_or_lt_of_le (W.nonneg a b) with hx | hx
  · rw [← hx]
    have h0 : (0 : ℝ) ≤ μ.prob a * outMarginal μ W b :=
      mul_nonneg hm.le (outMarginal_nonneg μ W b)
    simp only [mul_zero, zero_mul, zero_sub]
    linarith
  · have hle : μ.prob a * W.cond a b ≤ outMarginal μ W b :=
      Finset.single_le_sum (f := fun a' => μ.prob a' * W.cond a' b)
        (fun a' _ => mul_nonneg (μ.nonneg a') (W.nonneg a' b)) (Finset.mem_univ a)
    have hy : 0 < outMarginal μ W b := lt_of_lt_of_le (mul_pos hm hx) hle
    have hlog : 1 - outMarginal μ W b / W.cond a b
        ≤ Real.log (W.cond a b / outMarginal μ W b) := by
      have h1 : Real.log (outMarginal μ W b / W.cond a b)
          ≤ outMarginal μ W b / W.cond a b - 1 :=
        Real.log_le_sub_one_of_pos (div_pos hy hx)
      have h2 : Real.log (W.cond a b / outMarginal μ W b)
          = - Real.log (outMarginal μ W b / W.cond a b) := by
        rw [← Real.log_inv]
        congr 1
        field_simp
      rw [h2]
      linarith
    have hxlog : W.cond a b - outMarginal μ W b
        ≤ W.cond a b * Real.log (W.cond a b / outMarginal μ W b) := by
      have hmul := mul_le_mul_of_nonneg_left hlog hx.le
      have he : W.cond a b * (1 - outMarginal μ W b / W.cond a b)
          = W.cond a b - outMarginal μ W b := by
        field_simp
      linarith [he ▸ hmul]
    calc μ.prob a * W.cond a b - μ.prob a * outMarginal μ W b
        = μ.prob a * (W.cond a b - outMarginal μ W b) := by ring
      _ ≤ μ.prob a * (W.cond a b * Real.log (W.cond a b / outMarginal μ W b)) :=
          mul_le_mul_of_nonneg_left hxlog hm.le
      _ = μ.prob a * W.cond a b * Real.log (W.cond a b / outMarginal μ W b) := by ring

/-- **The information inequality**: mutual information is nonnegative. -/
theorem mutualInfo_nonneg (μ : FinProbDist α) (W : Channel α β) : 0 ≤ mutualInfo μ W := by
  have hzero : ∑ a, ∑ b, (μ.prob a * W.cond a b - μ.prob a * outMarginal μ W b) = 0 := by
    have hrow : ∀ a : α, ∑ b, (μ.prob a * W.cond a b - μ.prob a * outMarginal μ W b)
        = μ.prob a - μ.prob a * ∑ b, outMarginal μ W b := by
      intro a
      rw [Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum, W.row_sum a, mul_one]
    simp only [hrow, outMarginal_sum_one, mul_one, sub_self, Finset.sum_const_zero]
  calc (0 : ℝ) = ∑ a, ∑ b, (μ.prob a * W.cond a b - μ.prob a * outMarginal μ W b) := hzero.symm
    _ ≤ ∑ a, ∑ b, μ.prob a * W.cond a b * Real.log (W.cond a b / outMarginal μ W b) :=
        Finset.sum_le_sum fun a _ =>
          Finset.sum_le_sum fun b _ => mutualInfo_term_bound μ W a b
    _ = mutualInfo μ W := rfl

/-- Expected distortion is bounded below by minus the total absolute distortion. -/
theorem expectedDistortion_lower_bound (μ : FinProbDist α) (W : Channel α β)
    (d : α → β → ℝ) : - ∑ a, ∑ b, |d a b| ≤ expectedDistortion μ W d := by
  have hμ1 : ∀ a, μ.prob a ≤ 1 := by
    intro a
    have := Finset.single_le_sum (f := μ.prob) (fun a' _ => μ.nonneg a') (Finset.mem_univ a)
    rw [μ.sum_one] at this
    exact this
  have hW1 : ∀ a b, W.cond a b ≤ 1 := by
    intro a b
    have := Finset.single_le_sum (f := fun b' => W.cond a b')
      (fun b' _ => W.nonneg a b') (Finset.mem_univ b)
    rw [W.row_sum a] at this
    exact this
  have hterm : ∀ a b, -|d a b| ≤ μ.prob a * W.cond a b * d a b := by
    intro a b
    have hp : 0 ≤ μ.prob a * W.cond a b := mul_nonneg (μ.nonneg a) (W.nonneg a b)
    have hp1 : μ.prob a * W.cond a b ≤ 1 := by
      calc μ.prob a * W.cond a b ≤ 1 * 1 :=
            mul_le_mul (hμ1 a) (hW1 a b) (W.nonneg a b) zero_le_one
        _ = 1 := by ring
    have habs : -|d a b| ≤ d a b := neg_abs_le _
    nlinarith [abs_nonneg (d a b), le_abs_self (d a b)]
  calc - ∑ a, ∑ b, |d a b| = ∑ a, ∑ b, -|d a b| := by
        simp [Finset.sum_neg_distrib]
    _ ≤ ∑ a, ∑ b, μ.prob a * W.cond a b * d a b :=
        Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => hterm a b
    _ = expectedDistortion μ W d := rfl

/-- A distortion level is feasible when some channel achieves it. -/
def FeasibleDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ W : Channel α β, expectedDistortion μ W d ≤ D

/-- The set of achievable rates at distortion level `D`. -/
def rateDistortionSet (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r | ∃ W : Channel α β, expectedDistortion μ W d ≤ D ∧ mutualInfo μ W = r}

/-- The rate–distortion function `R(D)`. -/
def rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (rateDistortionSet μ d D)

/-- The set of Lagrangian values at dual parameter `s`. -/
def lagrangianDualSet (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : Set ℝ :=
  {r | ∃ W : Channel α β, mutualInfo μ W + s * expectedDistortion μ W d = r}

/-- The Lagrangian dual function `Φ(s)`. -/
def lagrangianDual (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : ℝ :=
  sInf (lagrangianDualSet μ d s)

theorem lagrangianDualSet_bddBelow (μ : FinProbDist α) (d : α → β → ℝ) {s : ℝ}
    (hs : 0 ≤ s) : BddBelow (lagrangianDualSet μ d s) := by
  refine ⟨s * (- ∑ a, ∑ b, |d a b|), ?_⟩
  rintro r ⟨W, rfl⟩
  have h1 : 0 ≤ mutualInfo μ W := mutualInfo_nonneg μ W
  have h2 : s * (- ∑ a, ∑ b, |d a b|) ≤ s * expectedDistortion μ W d :=
    mul_le_mul_of_nonneg_left (expectedDistortion_lower_bound μ W d) hs
  linarith

theorem rateDistortionSet_bddBelow (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    BddBelow (rateDistortionSet μ d D) := by
  refine ⟨0, ?_⟩
  rintro r ⟨W, -, rfl⟩
  exact mutualInfo_nonneg μ W

/-- **Weak duality for the finite rate–distortion problem.**  For every nonnegative dual
parameter `s`, the affine function `Φ(s) − s·D` lies below `R(D)`. -/
theorem lagrangianDual_le_rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ)
    (hs : 0 ≤ s) (D : ℝ) (hD : FeasibleDistortion μ d D) :
    lagrangianDual μ d s - s * D ≤ rateDistortion μ d D := by
  obtain ⟨W₀, hW₀⟩ := hD
  have hne : (rateDistortionSet μ d D).Nonempty := ⟨mutualInfo μ W₀, ⟨W₀, hW₀, rfl⟩⟩
  refine le_csInf hne ?_
  rintro r ⟨W, hWD, rfl⟩
  have hmem : mutualInfo μ W + s * expectedDistortion μ W d ∈ lagrangianDualSet μ d s :=
    ⟨W, rfl⟩
  have hinf : lagrangianDual μ d s ≤ mutualInfo μ W + s * expectedDistortion μ W d :=
    csInf_le (lagrangianDualSet_bddBelow μ d hs) hmem
  have hdist : s * expectedDistortion μ W d ≤ s * D := mul_le_mul_of_nonneg_left hWD hs
  linarith

end