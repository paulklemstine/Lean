/-
# EML V12 — Integral Theory

Definite integrals of the self-pairing σ, diagonal map,
and EML operator. Integral bounds and antiderivatives.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set MeasureTheory

/-! ## Core Definitions -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

/-! ## Section 1: Integral of σ on [0,1] -/

/-- ∫₀¹ exp(t) dt = e − 1. -/
theorem integral_exp_01 : ∫ t in (0:ℝ)..1, Real.exp t = Real.exp 1 - 1 := by
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun x _ => Real.hasDerivAt_exp x)
    (Real.continuous_exp.intervalIntegrable 0 1)]
  simp [Real.exp_zero]

/-
∫₀¹ t dt = 1/2.
-/
theorem integral_id_01 : ∫ t in (0:ℝ)..1, t = 1 / 2 := by
  norm_num +zetaDelta at *

/-
∫₀¹ σ(t) dt = e − 3/2.
-/
theorem integral_selfPair_01 :
    ∫ t in (0:ℝ)..1, emlSelfPair t = Real.exp 1 - 3 / 2 := by
      unfold emlSelfPair;
      norm_num;
      ring

/-! ## Section 2: Integrability -/

/-- σ is integrable on any interval. -/
theorem emlSelfPair_intervalIntegrable (a b : ℝ) :
    IntervalIntegrable emlSelfPair MeasureTheory.volume a b := by
  exact (Real.continuous_exp.sub continuous_id).intervalIntegrable a b

/-! ## Section 3: Antiderivative of σ -/

/-
The antiderivative of σ(x) = eˣ − x is F(x) = eˣ − x²/2.
-/
theorem emlSelfPair_antideriv (x : ℝ) :
    HasDerivAt (fun t => Real.exp t - t ^ 2 / 2) (emlSelfPair x) x := by
      simpa using HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( HasDerivAt.div_const ( hasDerivAt_pow 2 x ) 2 )

/-
∫₀ᵃ σ(t) dt = eᵃ − a²/2 − 1.
-/
theorem integral_selfPair_exact (a : ℝ) :
    ∫ t in (0:ℝ)..a, emlSelfPair t = Real.exp a - a ^ 2 / 2 - 1 := by
      convert intervalIntegral.integral_eq_sub_of_hasDerivAt _ _ using 1;
      rotate_left;
      exacts [ by infer_instance, fun x => Real.exp x - x ^ 2 / 2, fun x hx => emlSelfPair_antideriv x, emlSelfPair_intervalIntegrable 0 a, by norm_num ]

/-! ## Section 4: Integral Bounds -/

/-
The integral of σ on [0, a] for a ≥ 0 is at least a (since σ ≥ 1).
-/
theorem integral_selfPair_ge_length (a : ℝ) (ha : 0 ≤ a) :
    ∫ t in (0:ℝ)..a, emlSelfPair t ≥ a := by
      -- Since σ(t) ≥ 1 for all t (from exp(t) ≥ 1 + t), the integral ∫₀ᵃ σ(t) dt ≥ ∫₀ᵃ 1 dt = a.
      have h_int_ge_a : ∫ t in (0:ℝ)..a, emlSelfPair t ≥ ∫ t in (0:ℝ)..a, 1 := by
        apply_rules [ intervalIntegral.integral_mono_on ];
        · norm_num;
        · exact?;
        · exact fun x hx => by unfold emlSelfPair; linarith [ Real.add_one_le_exp x ] ;
      aesop

/-- σ² is integrable on any interval. -/
theorem emlSelfPair_sq_integrable (a b : ℝ) :
    IntervalIntegrable (fun t => emlSelfPair t ^ 2) MeasureTheory.volume a b :=
  (Real.continuous_exp.sub continuous_id).pow 2 |>.intervalIntegrable a b

/-
∫₀ᵃ σ(t)² dt ≥ a for a ≥ 0 (since σ² ≥ 1).
-/
theorem integral_selfPair_sq_ge (a : ℝ) (ha : 0 ≤ a) :
    ∫ t in (0:ℝ)..a, emlSelfPair t ^ 2 ≥ a := by
      rw [ intervalIntegral.integral_of_le ha ];
      refine' le_trans _ ( MeasureTheory.setIntegral_mono_on _ _ measurableSet_Ioc fun x hx => one_le_pow₀ <| show 1 ≤ emlSelfPair x from _ ) <;> norm_num [ ha ];
      · exact Continuous.integrableOn_Ioc ( by exact Continuous.pow ( by exact Continuous.sub ( Real.continuous_exp ) continuous_id' ) _ );
      · exact le_tsub_of_add_le_left ( by linarith [ Real.add_one_le_exp x, hx.1 ] )

/-! ## Section 5: Exponential remainder integral -/

/-- exp(x) − 1 − x ≥ 0 for all x. -/
theorem exp_remainder_nonneg (x : ℝ) : Real.exp x - 1 - x ≥ 0 := by
  linarith [Real.add_one_le_exp x]

/-
∫₀¹ (eᵗ − 1 − t) dt = e − 5/2.
-/
theorem integral_exp_remainder_01 :
    ∫ t in (0:ℝ)..1, (Real.exp t - 1 - t) = Real.exp 1 - 5 / 2 := by
      rw [ intervalIntegral.integral_sub, intervalIntegral.integral_sub ] <;> norm_num ; ring

end