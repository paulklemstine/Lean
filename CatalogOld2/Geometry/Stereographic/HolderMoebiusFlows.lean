/-! # CatalogBuild.Geometry.Stereographic.HolderMoebiusFlows

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 20
-/

import Mathlib

noncomputable section

/-- A continuous Möbius flow parameter: interpolates between identity (t=0) and
target parameters (t=1). Uses exponential interpolation for smoothness. -/
structure MoebiusFlowParam where
  /-- Target a-parameter (complex, encoded as ℝ×ℝ) -/
  a_target : ℝ × ℝ
  /-- Target b-parameter -/
  b_target : ℝ × ℝ
  /-- Target c-parameter -/
  c_target : ℝ × ℝ
  /-- Target d-parameter -/
  d_target : ℝ × ℝ


/-- Linear interpolation between identity and target. -/
def moebiusFlowAt (p : MoebiusFlowParam) (t : ℝ) : (ℝ × ℝ) × (ℝ × ℝ) × (ℝ × ℝ) × (ℝ × ℝ) :=
  let a := ((1 - t) * 1 + t * p.a_target.1, (1 - t) * 0 + t * p.a_target.2)
  let b := ((1 - t) * 0 + t * p.b_target.1, (1 - t) * 0 + t * p.b_target.2)
  let c := ((1 - t) * 0 + t * p.c_target.1, (1 - t) * 0 + t * p.c_target.2)
  let d := ((1 - t) * 1 + t * p.d_target.1, (1 - t) * 0 + t * p.d_target.2)
  (a, b, c, d)


/-- At t=0, the flow is the identity transform. -/
theorem moebiusFlowParam_at_zero (p : MoebiusFlowParam) :
    moebiusFlowAt p 0 = ((1, 0), (0, 0), (0, 0), (1, 0)) := by
  unfold moebiusFlowAt; simp


/-- At t=1, the flow reaches the target transform. -/
theorem moebiusFlowParam_at_one (p : MoebiusFlowParam) :
    moebiusFlowAt p 1 = (p.a_target, p.b_target, p.c_target, p.d_target) := by
  unfold moebiusFlowAt; simp


/-- The conformal factor of the stereographic projection composed with a
flow-parameterized Möbius transform. -/
def moebiusFlowConformalFactor (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (x i) ^ 2)


theorem moebiusFlowConformalFactor_pos (n : ℕ) (x : Fin n → ℝ) :
    0 < moebiusFlowConformalFactor n x := by
  unfold moebiusFlowConformalFactor; positivity


theorem moebiusFlowConformalFactor_bounded (n : ℕ) (x : Fin n → ℝ) :
    moebiusFlowConformalFactor n x ≤ 2 := by
  unfold moebiusFlowConformalFactor
  exact div_le_self (by positivity)
    (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))


/-- Hölder exponent for the flow. We require α ∈ (0, 1]. -/
def holderExponent (alpha : ℝ) : Prop :=
  0 < alpha ∧ alpha ≤ 1


/-- A valid Hölder exponent satisfies 0 < α ≤ 1. -/
theorem holderExponent_valid (alpha : ℝ) (h1 : 0 < alpha) (h2 : alpha ≤ 1) :
    holderExponent alpha := ⟨h1, h2⟩


/-- The Hölder seminorm bound for the flow interpolation.
|μ(t) - μ(s)| ≤ C · |t - s|^α -/
def holderBound (C alpha t s : ℝ) : ℝ :=
  C * |t - s| ^ alpha


theorem holderBound_nonneg (C alpha t s : ℝ) (hC : 0 ≤ C) (ha : 0 ≤ alpha) :
    0 ≤ holderBound C alpha t s := by
  unfold holderBound
  exact mul_nonneg hC (rpow_nonneg (abs_nonneg _) alpha)


theorem holderBound_zero (C alpha t : ℝ) (hC : 0 ≤ C) (ha : 0 < alpha) :
    holderBound C alpha t t = 0 := by
  unfold holderBound; simp [rpow_eq_zero_iff_of_nonneg (abs_nonneg _), ha.ne']


/-- The flow interpolation parameter t ↦ t is monotone on [0,1]. -/
theorem flowInterpolation_monotone :
    Monotone (fun t : ℝ => t) := fun _ _ h => h


/-- The flow velocity (time derivative of the Möbius parameters). -/
def flowVelocity (p : MoebiusFlowParam) : (ℝ × ℝ) × (ℝ × ℝ) × (ℝ × ℝ) × (ℝ × ℝ) :=
  ((p.a_target.1 - 1, p.a_target.2),
   (p.b_target.1, p.b_target.2),
   (p.c_target.1, p.c_target.2),
   (p.d_target.1 - 1, p.d_target.2))


/-- The squared norm of a pair. -/
def pairSqNorm (p : ℝ × ℝ) : ℝ := p.1 ^ 2 + p.2 ^ 2


/-- The total velocity squared norm. -/
def flowVelocitySqNorm (p : MoebiusFlowParam) : ℝ :=
  let v := flowVelocity p
  pairSqNorm v.1 + pairSqNorm v.2.1 + pairSqNorm v.2.2.1 + pairSqNorm v.2.2.2


theorem flowVelocitySqNorm_nonneg (p : MoebiusFlowParam) :
    0 ≤ flowVelocitySqNorm p := by
  unfold flowVelocitySqNorm pairSqNorm flowVelocity; positivity


/-- The flow velocity is bounded (constant along the linear interpolation). -/
theorem flowVelocityBounded (p : MoebiusFlowParam) (B : ℝ)
    (hB : flowVelocitySqNorm p ≤ B ^ 2) (hBpos : 0 ≤ B) :
    Real.sqrt (flowVelocitySqNorm p) ≤ B := by
  rwa [Real.sqrt_le_left hBpos]


/-- Riemannian gradient descent step on the Möbius flow parameter.
We use the flat metric on the parameter space as an approximation. -/
def flowGradientStep (p : MoebiusFlowParam) (lr : ℝ)
    (grad_a grad_b grad_c grad_d : ℝ × ℝ) : MoebiusFlowParam where
  a_target := (p.a_target.1 - lr * grad_a.1, p.a_target.2 - lr * grad_a.2)
  b_target := (p.b_target.1 - lr * grad_b.1, p.b_target.2 - lr * grad_b.2)
  c_target := (p.c_target.1 - lr * grad_c.1, p.c_target.2 - lr * grad_c.2)
  d_target := (p.d_target.1 - lr * grad_d.1, p.d_target.2 - lr * grad_d.2)


/-- Zero learning rate preserves parameters. -/
theorem flowGradientStep_zero_lr (p : MoebiusFlowParam)
    (ga gb gc gd : ℝ × ℝ) :
    flowGradientStep p 0 ga gb gc gd = p := by
  unfold flowGradientStep; simp


end
