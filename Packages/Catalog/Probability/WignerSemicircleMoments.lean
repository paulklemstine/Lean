/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Moments of the Wigner semicircle law are the Catalan numbers

This file establishes the analytic half of the moment method for the Wigner
semicircle law: the `m`-th moment of the standard semicircle distribution
(density `√(4 - x²)/(2π)` on `[-2, 2]`) vanishes for odd `m` and equals the
Catalan number `Cₖ` for `m = 2k`.

The proof runs through the trigonometric substitution `x = 2 sin t`, the
Mathlib reduction formula `integral_sin_pow`, and the Catalan recursion
`(k+2) Cₖ₊₁ = 2(2k+1) Cₖ` extracted from the central binomial coefficients.
-/
import Mathlib

open Real intervalIntegral MeasureTheory
open scoped Nat

namespace WignerSemicircle

noncomputable section

/-- `sinPowInt m = ∫_{-π/2}^{π/2} sinᵐ t dt`, the Wallis integral on the
symmetric interval. -/
def sinPowInt (m : ℕ) : ℝ := ∫ t in (-(π / 2))..(π / 2), Real.sin t ^ m

/-- The `m`-th moment of the standard Wigner semicircle law with density
`√(4 - x²) / (2π)` supported on `[-2, 2]`. -/
def semicircleMoment (m : ℕ) : ℝ :=
  (1 / (2 * π)) * ∫ x in (-2 : ℝ)..2, x ^ m * Real.sqrt (4 - x ^ 2)

/-! ### Wallis integrals on `[-π/2, π/2]` -/

theorem sinPowInt_zero : sinPowInt 0 = π := by
  simp [sinPowInt]

theorem sinPowInt_one : sinPowInt 1 = 0 := by
  simp [sinPowInt]

/-- The Wallis reduction formula on the symmetric interval: the boundary terms
vanish because `cos (±π/2) = 0`. -/
theorem sinPowInt_rec (m : ℕ) :
    sinPowInt (m + 2) = ((m : ℝ) + 1) / ((m : ℝ) + 2) * sinPowInt m := by
  have h := integral_sin_pow (a := -(π / 2)) (b := π / 2) m
  simp only [sinPowInt]
  rw [h]
  simp [Real.cos_pi_div_two]

theorem sinPowInt_odd (k : ℕ) : sinPowInt (2 * k + 1) = 0 := by
  induction k with
  | zero => simpa using sinPowInt_one
  | succ n ih =>
      have : 2 * (n + 1) + 1 = (2 * n + 1) + 2 := by ring
      rw [this, sinPowInt_rec, ih, mul_zero]

theorem sinPowInt_pos_even (k : ℕ) : 0 < sinPowInt (2 * k) := by
  induction k with
  | zero => simpa [sinPowInt_zero] using Real.pi_pos
  | succ n ih =>
      have h : 2 * (n + 1) = 2 * n + 2 := by ring
      rw [h, sinPowInt_rec]
      have : (0:ℝ) < ((2 * n : ℕ) + 1) / ((2 * n : ℕ) + 2) := by positivity
      exact mul_pos this ih

/-! ### The trigonometric substitution -/

/-- Substituting `x = 2 sin t` turns the semicircle integral into a Wallis-type
trigonometric integral. -/
theorem semicircle_integral_eq (m : ℕ) :
    (∫ x in (-2 : ℝ)..2, x ^ m * Real.sqrt (4 - x ^ 2)) =
      2 ^ (m + 2) * ∫ t in (-(π / 2))..(π / 2), Real.sin t ^ m * Real.cos t ^ 2 := by
  have hderiv : ∀ x ∈ Set.uIcc (-(π / 2)) (π / 2),
      HasDerivAt (fun y => 2 * Real.sin y) (2 * Real.cos x) x :=
    fun x _ => (Real.hasDerivAt_sin x).const_mul 2
  have hcont : ContinuousOn (fun x : ℝ => 2 * Real.cos x) (Set.uIcc (-(π / 2)) (π / 2)) := by
    fun_prop
  have hg : Continuous (fun u : ℝ => u ^ m * Real.sqrt (4 - u ^ 2)) := by fun_prop
  have h := intervalIntegral.integral_comp_mul_deriv hderiv hcont hg
  have he1 : 2 * Real.sin (-(π / 2)) = -2 := by simp
  have he2 : 2 * Real.sin (π / 2) = 2 := by simp
  rw [he1, he2] at h
  rw [← h]
  rw [← intervalIntegral.integral_const_mul]
  refine intervalIntegral.integral_congr ?_
  intro x hx
  have hx' : x ∈ Set.Icc (-(π / 2)) (π / 2) := by
    rwa [Set.uIcc_of_le (by linarith [Real.pi_pos])] at hx
  have hcosnn : 0 ≤ Real.cos x := Real.cos_nonneg_of_mem_Icc hx'
  have hsq : Real.sqrt (4 - (2 * Real.sin x) ^ 2) = 2 * Real.cos x := by
    have : 4 - (2 * Real.sin x) ^ 2 = (2 * Real.cos x) ^ 2 := by
      have := Real.sin_sq_add_cos_sq x
      nlinarith [this]
    rw [this, Real.sqrt_sq (by linarith)]
  simp only [Function.comp_apply]
  rw [hsq]
  rw [mul_pow]
  ring

theorem sin_pow_mul_cos_sq_int (m : ℕ) :
    (∫ t in (-(π / 2))..(π / 2), Real.sin t ^ m * Real.cos t ^ 2) =
      sinPowInt m - sinPowInt (m + 2) := by
  have hcongr : (∫ t in (-(π / 2))..(π / 2), Real.sin t ^ m * Real.cos t ^ 2) =
      ∫ t in (-(π / 2))..(π / 2), (Real.sin t ^ m - Real.sin t ^ (m + 2)) := by
    refine intervalIntegral.integral_congr ?_
    intro x _
    have := Real.sin_sq_add_cos_sq x
    simp only
    rw [pow_add]
    linear_combination (Real.sin x ^ m) * this
  rw [hcongr, sinPowInt, sinPowInt]
  refine intervalIntegral.integral_sub ?_ ?_ <;>
    exact (Continuous.intervalIntegrable (by fun_prop) _ _)

/-- Master formula for the semicircle moments in terms of Wallis integrals. -/
theorem semicircleMoment_eq (m : ℕ) :
    semicircleMoment m = 2 ^ (m + 2) / (2 * π) * (sinPowInt m - sinPowInt (m + 2)) := by
  rw [semicircleMoment, semicircle_integral_eq, sin_pow_mul_cos_sq_int]
  ring

/-! ### Odd moments vanish -/

theorem semicircleMoment_odd (k : ℕ) : semicircleMoment (2 * k + 1) = 0 := by
  have h1 : sinPowInt (2 * k + 1) = 0 := sinPowInt_odd k
  have h2 : sinPowInt (2 * k + 1 + 2) = 0 := by
    have : 2 * k + 1 + 2 = 2 * (k + 1) + 1 := by ring
    rw [this]; exact sinPowInt_odd (k + 1)
  rw [semicircleMoment_eq, h1, h2]
  ring

/-! ### Even moments are Catalan numbers -/

/-- The Catalan recursion `(k+2) Cₖ₊₁ = 2(2k+1) Cₖ`. -/
theorem catalan_rec (k : ℕ) : (k + 2) * catalan (k + 1) = 2 * (2 * k + 1) * catalan k := by
  have h1 := succ_mul_catalan_eq_centralBinom (k + 1)
  have h2 := Nat.succ_mul_centralBinom_succ k
  have h3 := succ_mul_catalan_eq_centralBinom k
  nlinarith [h1, h2, h3]

theorem semicircleMoment_two_mul_eq (k : ℕ) :
    semicircleMoment (2 * k) = 2 ^ (2 * k + 1) * sinPowInt (2 * k) / ((2 * (k : ℝ) + 2) * π) := by
  have hrec := sinPowInt_rec (2 * k)
  have hpi := Real.pi_ne_zero
  rw [semicircleMoment_eq, hrec]
  push_cast
  field_simp
  rw [show (2:ℝ) ^ (2 * k + 2) = 2 * 2 ^ (2 * k + 1) by ring]
  ring

/-- **Even moments of the semicircle law are Catalan numbers.** -/
theorem semicircleMoment_two_mul (k : ℕ) : semicircleMoment (2 * k) = catalan k := by
  induction k with
  | zero =>
      rw [semicircleMoment_two_mul_eq]
      simp [sinPowInt_zero, Real.pi_ne_zero]
  | succ n ih =>
      have hpi := Real.pi_ne_zero
      have hrec : sinPowInt (2 * (n + 1)) =
          ((2 * n : ℝ) + 1) / ((2 * n : ℝ) + 2) * sinPowInt (2 * n) := by
        have h : 2 * (n + 1) = 2 * n + 2 := by ring
        rw [h, sinPowInt_rec]
        push_cast
        ring_nf
      have hcat : ((n : ℝ) + 2) * (catalan (n + 1) : ℝ) = 2 * (2 * n + 1) * (catalan n : ℝ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) (catalan_rec n)
      rw [semicircleMoment_two_mul_eq, hrec]
      rw [semicircleMoment_two_mul_eq] at ih
      have hpow : (2 : ℝ) ^ (2 * (n + 1) + 1) = 4 * 2 ^ (2 * n + 1) := by
        rw [show 2 * (n + 1) + 1 = (2 * n + 1) + 2 by ring]
        ring
      rw [hpow]
      push_cast
      push_cast at ih hcat
      field_simp at ih ⊢
      linear_combination (4 * (2 * (n : ℝ) + 1)) * ih - (4 * ((n : ℝ) + 1) * π) * hcat

/-! ### Small cases -/

theorem semicircleMoment_zero : semicircleMoment 0 = 1 := by
  simpa using semicircleMoment_two_mul 0

theorem semicircleMoment_two : semicircleMoment 2 = 1 := by
  have := semicircleMoment_two_mul 1
  simpa using this

theorem semicircleMoment_four : semicircleMoment 4 = 2 := by
  have := semicircleMoment_two_mul 2
  norm_num [catalan_two] at this
  simpa using this

end

end WignerSemicircle