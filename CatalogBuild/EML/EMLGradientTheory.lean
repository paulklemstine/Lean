/-! # CatalogBuild.EML.EMLGradientTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 24
-/

import Mathlib

noncomputable section

/-- Trigonometric energy: E(x) = sin²(π·N/x). -/
def trigEnergy (N : ℕ) (x : ℝ) : ℝ := Real.sin (π * ↑N / x) ^ 2


/-- Energy is nonneg. -/
theorem trig_energy_nonneg (N : ℕ) (x : ℝ) : 0 ≤ trigEnergy N x :=
  sq_nonneg _


/-- Energy ≤ 1. -/
theorem trig_energy_le_one (N : ℕ) (x : ℝ) : trigEnergy N x ≤ 1 :=
  sin_sq_le_one _


/-- |sin(2θ)| ≤ 1. -/
theorem sin_two_bounded (θ : ℝ) : |Real.sin (2 * θ)| ≤ 1 :=
  abs_sin_le_one _


/-- Double angle: 2 sin θ cos θ = sin(2θ). -/
theorem gradient_formula (θ : ℝ) :
    2 * Real.sin θ * Real.cos θ = Real.sin (2 * θ) :=
  (Real.sin_two_mul θ).symm


/-- Safe learning rate: η = 1/(2L). -/
def safeLR (L : ℝ) : ℝ := 1 / (2 * L)


/-- Safe LR is positive. -/
theorem safe_lr_pos (L : ℝ) (hL : 0 < L) : 0 < safeLR L := by
  unfold safeLR; positivity


/-- Descent gain is positive when gradient ≠ 0. -/
theorem descent_gain_pos (g eta : ℝ) (hg : g ≠ 0) (heta : 0 < eta) :
    0 < eta * g ^ 2 / 2 := by positivity


/-- Geometric decay sequence. -/
def geomDecay (L0 r : ℝ) (t : ℕ) : ℝ := (1 - r) ^ t * L0


/-- Geometric decay → 0. -/
theorem geom_decay_tendsto (L0 r : ℝ) (_ : 0 < L0) (hr : 0 < r) (hr1 : r < 1) :
    Filter.Tendsto (geomDecay L0 r) Filter.atTop (nhds 0) := by
  show Filter.Tendsto (fun t => (1 - r) ^ t * L0) Filter.atTop (nhds 0)
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (by linarith : 0 ≤ 1 - r) (by linarith : 1 - r < 1)
  have := h.mul_const L0
  simp only [zero_mul] at this
  exact this


/-- Decay is bounded by initial loss. -/
theorem geom_decay_bound (L0 r : ℝ) (hL : 0 ≤ L0) (_ : 0 < r) (hr1 : r < 1)
    (t : ℕ) : geomDecay L0 r t ≤ L0 := by
  unfold geomDecay
  have h1 : 0 ≤ 1 - r := by linarith
  have h2 : 1 - r ≤ 1 := by linarith
  have h3 : (1 - r) ^ t ≤ 1 := pow_le_one₀ h1 h2
  nlinarith [pow_nonneg h1 t]


/-- Adam LR: η / (√v + ε). -/
def adamLR (eta v eps : ℝ) : ℝ := eta / (Real.sqrt v + eps)


/-- Adam LR is positive. -/
theorem adam_lr_pos (eta v eps : ℝ) (heta : 0 < eta) (_ : 0 ≤ v) (heps : 0 < eps) :
    0 < adamLR eta v eps := by
  unfold adamLR
  exact div_pos heta (by linarith [Real.sqrt_nonneg v])


/-- Adam LR decreases with variance. -/
theorem adam_lr_mono (eta eps v1 v2 : ℝ)
    (heta : 0 < eta) (heps : 0 < eps) (hv1 : 0 ≤ v1) (h : v1 ≤ v2) :
    adamLR eta v2 eps ≤ adamLR eta v1 eps := by
  unfold adamLR
  apply div_le_div_of_nonneg_left heta.le (by linarith [Real.sqrt_nonneg v1])
  linarith [Real.sqrt_le_sqrt h]


/-- With k channels, variance = base/k. -/
def varianceReduction (base : ℝ) (k : ℕ) : ℝ := base / k


/-- More channels → less variance. -/
theorem variance_mono (base : ℝ) (hb : 0 < base)
    (k1 k2 : ℕ) (hk1 : 0 < k1) (h : k1 ≤ k2) :
    varianceReduction base k2 ≤ varianceReduction base k1 := by
  simp only [varianceReduction]
  exact div_le_div_of_nonneg_left hb.le (by positivity) (by exact_mod_cast h)


/-- Search window at scale s. -/
def searchWindow (s : ℕ) : ℕ := 2 ^ (s + 1)


/-- Windows grow with scale. -/
theorem window_mono (s1 s2 : ℕ) (h : s1 ≤ s2) :
    searchWindow s1 ≤ searchWindow s2 := by
  simp only [searchWindow]
  exact Nat.pow_le_pow_right (by omega) (by omega)


/-- Expressiveness grows with depth. -/
def emlExpressiveness (d : ℕ) : ℕ := 2 ^ d


/-- Deeper = more expressive. -/
theorem expressiveness_mono (d1 d2 : ℕ) (h : d1 ≤ d2) :
    emlExpressiveness d1 ≤ emlExpressiveness d2 :=
  Nat.pow_le_pow_right (by omega) h


/-- Exponential expressiveness gain per layer. -/
theorem expressiveness_exp (d : ℕ) :
    emlExpressiveness d < emlExpressiveness (d + 1) := by
  simp only [emlExpressiveness]
  exact Nat.pow_lt_pow_right (by omega) (by omega)


/-- Proximity: N mod k. -/
def factorProximity (N k : ℕ) : ℕ := N % k


/-- Proximity 0 ↔ factor. -/
theorem proximity_zero_iff (N k : ℕ) (_ : 0 < k) :
    factorProximity N k = 0 ↔ k ∣ N :=
  Nat.dvd_iff_mod_eq_zero.symm


/-- Proximity < k. -/
theorem proximity_bounded (N k : ℕ) (hk : 0 < k) :
    factorProximity N k < k :=
  Nat.mod_lt N hk


end
