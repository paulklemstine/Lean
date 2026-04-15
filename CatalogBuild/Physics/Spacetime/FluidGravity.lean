/-! # CatalogBuild.Physics.Spacetime.FluidGravity

Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 19
-/

import Mathlib

noncomputable section

theorem kinetic_energy_nonneg (rho v : ℝ) (hrho : rho > 0) :
    rho * v ^ 2 / 2 ≥ 0 := by positivity


theorem viscous_dissipation_negative (nu gradv_sq : ℝ)
    (hnu : nu > 0) (hg : gradv_sq ≥ 0) :
    -(2 * nu * gradv_sq) ≤ 0 := by nlinarith


def reynoldsNumber (rho v L mu : ℝ) : ℝ := rho * v * L / mu


theorem kolmogorov_decay (C eps k1 k2 : ℝ)
    (hC : C > 0) (heps : eps > 0) (hk1 : k1 > 0) (hk2 : k2 > 0) (h : k1 < k2) :
    C * eps ^ (2/3 : ℝ) * k2 ^ (-(5/3 : ℝ)) <
    C * eps ^ (2/3 : ℝ) * k1 ^ (-(5/3 : ℝ)) := by
  apply mul_lt_mul_of_pos_left _ (by positivity : C * eps ^ (2/3 : ℝ) > 0)
  simp only [Real.rpow_neg (le_of_lt hk2), Real.rpow_neg (le_of_lt hk1)]
  gcongr

/-! ## Part II: Holographic Dictionary -/


theorem kss_bound_positive : (1 : ℝ) / (4 * Real.pi) > 0 := by positivity
theorem diffusion_positive (eta rhoP : ℝ) (heta : eta > 0) (hrhoP : rhoP > 0) :
    eta / rhoP > 0 := by positivity


theorem dominant_energy (T00 T0i : ℝ) (h : T00 ≥ |T0i|) : T00 ≥ 0 := by
  linarith [abs_nonneg T0i]

/-! ## Part III: Entanglement Entropy -/


theorem rt_entropy_positive (area GN : ℝ) (ha : area > 0) (hG : GN > 0) :
    area / (4 * GN) > 0 := by positivity


theorem strong_subadditivity (SABC SB SAB SBC : ℝ) (h : SABC + SB ≤ SAB + SBC) :
    SABC - SAB ≤ SBC - SB := by linarith


theorem bekenstein_bound_scales (R1 R2 E : ℝ) (hE : E > 0) (h : R1 < R2) :
    2 * Real.pi * R1 * E < 2 * Real.pi * R2 * E := by
  have hpi := Real.pi_pos
  have h1 : 2 * Real.pi * E > 0 := by positivity
  calc 2 * Real.pi * R1 * E = (2 * Real.pi * E) * R1 := by ring
    _ < (2 * Real.pi * E) * R2 := by exact mul_lt_mul_of_pos_left h h1
    _ = 2 * Real.pi * R2 * E := by ring


theorem scrambling_time_positive (T S : ℝ) (hT : T > 0) (hS : S > 1) :
    Real.log S / (2 * Real.pi * T) > 0 :=
  div_pos (Real.log_pos hS) (by positivity)


theorem lloyd_bound (M : ℝ) (hM : M > 0) : 2 * M / Real.pi > 0 := by positivity

/-! ## Part V: Page Curve -/


def pageEntropy (t S_BH : ℝ) : ℝ := min t (S_BH - t)


theorem page_time_maximum (S_BH : ℝ) (hS : S_BH > 0) :
    pageEntropy (S_BH / 2) S_BH = S_BH / 2 := by
  simp [pageEntropy, min_def]; linarith


theorem page_symmetric (t S_BH : ℝ) :
    pageEntropy t S_BH = pageEntropy (S_BH - t) S_BH := by
  simp only [pageEntropy]; rw [min_comm]; ring_nf


theorem page_nonneg (t S_BH : ℝ) (ht : 0 ≤ t) (hS : t ≤ S_BH) :
    pageEntropy t S_BH ≥ 0 := by
  simp only [pageEntropy, ge_iff_le, le_min_iff]; constructor <;> linarith

/-! ## Part VI: Blackening Factor -/


def blackeningFactor (r rH : ℝ) (d : ℕ) : ℝ := 1 - (rH / r) ^ d


theorem blackening_at_horizon (rH : ℝ) (d : ℕ) (hrH : rH > 0) :
    blackeningFactor rH rH d = 0 := by
  simp [blackeningFactor, div_self (ne_of_gt hrH)]


theorem blackening_outside_horizon (r rH : ℝ) (d : ℕ)
    (hr : r > rH) (hrH : rH > 0) (hd : d ≥ 1) :
    0 < blackeningFactor r rH d ∧ blackeningFactor r rH d < 1 := by
  have hr_pos : r > 0 := by linarith
  constructor
  · simp only [blackeningFactor, sub_pos]
    have h1 : rH / r < 1 := by rwa [div_lt_one hr_pos]
    exact pow_lt_one₀ (le_of_lt (div_pos hrH hr_pos)) h1 (by omega)
  · simp only [blackeningFactor, sub_lt_self_iff]
    exact pow_pos (div_pos hrH hr_pos) d


theorem hawking_temp_positive (d : ℕ) (rH : ℝ) (hd : d ≥ 1) (hrH : rH > 0) :
    (d : ℝ) * rH / (4 * Real.pi) > 0 := by positivity


end
