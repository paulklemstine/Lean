/-! # CatalogBuild.Geometry.Stereographic.QuantumGravityErrorCorrection

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Physics.Spacetime.QuantumGravityErrorCorrection
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 17] -/
structure QECCode where
  n : ℕ
  k : ℕ
  d : ℕ
  valid : k ≤ n
  distance_bound : d ≤ n - k + 1


/-- [Section: # CatalogBuild.Physics.Spacetime.QuantumGravityErrorCorrection
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 17] -/
def QECCode.rate (C : QECCode) : ℝ := (C.k : ℝ) / (C.n : ℝ)


/-- [Section: # CatalogBuild.Physics.Spacetime.QuantumGravityErrorCorrection
Auto-generated from theorem catalog database.
Domain: Physics/Spacetime
Declarations: 17] -/
theorem code_rate_bounded (C : QECCode) (hn : C.n > 0) :
    0 ≤ C.rate ∧ C.rate ≤ 1 := by
  constructor
  · exact div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  · exact div_le_one_of_le₀ (by exact_mod_cast C.valid) (by positivity)


def correctableErrors (d : ℕ) : ℕ := (d - 1) / 2


theorem more_distance_more_correction (d1 d2 : ℕ) (h : d1 < d2) :
    correctableErrors d1 ≤ correctableErrors d2 := by
  simp [correctableErrors]; omega


structure PerfectTensor where
  legs : ℕ
  bond_dim : ℕ
  even_legs : legs % 2 = 0
  dim_pos : bond_dim ≥ 2


def PerfectTensor.maxEntropy (T : PerfectTensor) : ℝ :=
  (T.legs / 2 : ℝ) * Real.log (T.bond_dim : ℝ)


theorem perfect_tensor_entropy_pos (T : PerfectTensor) (hl : T.legs ≥ 2) :
    T.maxEntropy > 0 := by
  unfold PerfectTensor.maxEntropy
  apply mul_pos
  · exact div_pos (by positivity : (T.legs : ℝ) > 0) two_pos
  · exact Real.log_pos (by exact_mod_cast T.dim_pos)


theorem jlms_formula (S_bulk area GN S_bdry : ℝ)
    (h : S_bulk + area / (4 * GN) = S_bdry) :
    S_bdry - S_bulk = area / (4 * GN) := by linarith


theorem er_epr_mutual_info (SA SB SAB : ℝ) (hmax : SAB = 0) :
    SA + SB - SAB = SA + SB := by linarith


theorem wormhole_growth (rate t1 t2 : ℝ) (hr : rate > 0) (h : t2 > t1) :
    rate * t2 > rate * t1 := by nlinarith


theorem tfd_weight_pos (beta E : ℝ) :
    Real.exp (-beta * E / 2) > 0 := Real.exp_pos _


def allowedWavenumber (n : ℕ) (L : ℝ) : ℝ := 2 * Real.pi * (n : ℝ) / L


theorem wavenumber_monotone (n m : ℕ) (L : ℝ) (hL : L > 0) (h : n < m) :
    allowedWavenumber n L < allowedWavenumber m L := by
  simp only [allowedWavenumber]
  apply div_lt_div_of_pos_right _ hL
  apply mul_lt_mul_of_pos_left _ (by positivity : 2 * Real.pi > 0)
  exact_mod_cast h


theorem topology_low_freq_cutoff (L1 L2 : ℝ) (hL1 : L1 > 0) (h : L1 < L2) :
    allowedWavenumber 1 L1 > allowedWavenumber 1 L2 := by
  simp only [allowedWavenumber, gt_iff_lt]
  exact div_lt_div_of_pos_left (by positivity) hL1 h


theorem gw_energy_quantized (n : ℕ) (L : ℝ) (hL : L > 0) (hn : n ≥ 1) :
    (allowedWavenumber n L) ^ 2 > 0 := by
  apply sq_pos_of_pos; simp only [allowedWavenumber]
  exact div_pos (mul_pos (by positivity) (by positivity : (n : ℝ) > 0)) hL


theorem spectral_gap_exists (L : ℝ) (hL : L > 0) :
    allowedWavenumber 1 L > 0 := by
  simp only [allowedWavenumber]; positivity


end
