/-! # CatalogBuild.Physics.Spacetime.LorentzCausalStructure

Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Physics.Spacetime.LorentzCausalStructure
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 16] -/
theorem minkowski_symmetric (u v : Fin 4 → ℝ) :
    minkowskiInner u v = minkowskiInner v u := by
  simp [minkowskiInner]; ring




/-- [Section: # CatalogBuild.Physics.Spacetime.LorentzCausalStructure
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 16] -/
theorem temporal_is_timelike (t : ℝ) (ht : t ≠ 0) :
    isTimelike (fun i : Fin 4 => if i = 0 then t else 0) := by
  simp only [isTimelike, minkowskiInner]
  have h0 : (0 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h1 : (0 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h2 : (0 : Fin 4) ≠ (3 : Fin 4) := by decide
  simp [h0, h1, h2]
  exact ht




theorem lorentz_boost_preserves_inner (phi : ℝ) (u v : Fin 4 → ℝ) :
    minkowskiInner (lorentzBoostX phi u) (lorentzBoostX phi v) =
    minkowskiInner u v := by
  simp only [minkowskiInner, lorentzBoostX]
  have h01 : (0 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h02 : (0 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h03 : (0 : Fin 4) ≠ (3 : Fin 4) := by decide
  have h10 : (1 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h12 : (1 : Fin 4) ≠ (2 : Fin 4) := by decide
  have h13 : (1 : Fin 4) ≠ (3 : Fin 4) := by decide
  have h20 : (2 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h21 : (2 : Fin 4) ≠ (1 : Fin 4) := by decide
  have h30 : (3 : Fin 4) ≠ (0 : Fin 4) := by decide
  have h31 : (3 : Fin 4) ≠ (1 : Fin 4) := by decide
  simp only [h01, h02, h03, h10, h12, h20, h21, h30, h31, ite_true, ite_false,
             if_neg, Ne, not_false_eq_true]
  have hcs := Real.cosh_sq_sub_sinh_sq phi
  linear_combination -(u 0 * v 0) * hcs + u 1 * v 1 * hcs




theorem lorentz_preserves_timelike (phi : ℝ) (v : Fin 4 → ℝ)
    (h : isTimelike v) : isTimelike (lorentzBoostX phi v) := by
  simp [isTimelike] at *; rw [lorentz_boost_preserves_inner]; exact h




theorem lorentz_preserves_null (phi : ℝ) (v : Fin 4 → ℝ)
    (h : isNull v) : isNull (lorentzBoostX phi v) := by
  simp [isNull] at *; rw [lorentz_boost_preserves_inner]; exact h




theorem strain_decay_monotone (h₀ r₁ r₂ : ℝ)
    (hh : h₀ > 0) (hr1 : r₁ > 0) (hr2 : r₂ > 0) (hr : r₁ < r₂) :
    h₀ / r₂ < h₀ / r₁ :=
  div_lt_div_of_pos_left hh hr1 hr




theorem chirp_mass_bound (m1 m2 : ℝ) :
    m1 * m2 ≤ ((m1 + m2) / 2) ^ 2 := by nlinarith [sq_nonneg (m1 - m2)]




theorem gw_energy_nonneg (coeff hdot : ℝ) (hcoeff : coeff ≥ 0) :
    coeff * hdot ^ 2 ≥ 0 := mul_nonneg hcoeff (sq_nonneg _)




theorem causal_diamond_scaling (tau1 tau2 k : ℝ)
    (hk : k > 0) (ht1 : tau1 > 0) (h : tau2 > tau1) :
    k * tau2 ^ 4 > k * tau1 ^ 4 := by
  gcongr




theorem bekenstein_hawking_positive (A lP : ℝ) (hA : A > 0) (hlP : lP > 0) :
    A / (4 * lP ^ 2) > 0 := by positivity




theorem deflection_positive (G M c b : ℝ)
    (hG : G > 0) (hM : M > 0) (hc : c > 0) (hb : b > 0) :
    4 * G * M / (c ^ 2 * b) > 0 := by positivity




theorem deflection_monotone (G M c b1 b2 : ℝ)
    (hG : G > 0) (hM : M > 0) (hc : c > 0) (hb1 : b1 > 0) (hb2 : b2 > 0)
    (h : b1 < b2) :
    4 * G * M / (c ^ 2 * b2) < 4 * G * M / (c ^ 2 * b1) :=
  div_lt_div_of_pos_left (by positivity) (by positivity)
    (mul_lt_mul_of_pos_left h (by positivity))




theorem gravitational_time_dilation (phi1 phi2 : ℝ)
    (h12 : phi1 < phi2) (hb2 : phi2 < 1) (h0 : 0 < phi1) :
    Real.sqrt (1 - phi2) < Real.sqrt (1 - phi1) :=
  Real.sqrt_lt_sqrt (by linarith) (by linarith)




theorem cosmological_redshift_positive (a_obs a_emit : ℝ)
    (he : a_emit > 0) (h : a_obs > a_emit) :
    a_obs / a_emit - 1 > 0 := by
  rw [gt_iff_lt, sub_pos]; exact (one_lt_div he).mpr h




theorem hubble_law_monotone (H0 d1 d2 : ℝ) (hH : H0 > 0) (hd : d2 > d1) :
    H0 * d2 > H0 * d1 := mul_lt_mul_of_pos_left hd hH




theorem friedmann_flat_positive (G rho : ℝ) (hG : G > 0) (hrho : rho > 0) :
    8 * Real.pi * G * rho / 3 > 0 := by positivity




end
