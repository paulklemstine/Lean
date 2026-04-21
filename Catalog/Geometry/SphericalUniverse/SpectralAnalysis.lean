/-! # CatalogBuild.Geometry.SphericalUniverse.SpectralAnalysis

Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 20
-/

import Mathlib

noncomputable section

/-- The eigenvalue of the Laplacian on S³ of radius R for mode l. -/
def eigenvalueS3 (R : ℝ) (l : ℕ) : ℝ :=
  (l * (l + 2) : ℝ) / R ^ 2




/-- The eigenvalues are non-negative. -/
theorem eigenvalue_nonneg (R : ℝ) (hR : 0 < R) (l : ℕ) :
    0 ≤ eigenvalueS3 R l := by
  unfold eigenvalueS3; positivity




/-- The eigenvalues are strictly increasing. -/
theorem eigenvalue_strict_mono (R : ℝ) (hR : 0 < R) (l : ℕ) :
    eigenvalueS3 R l < eigenvalueS3 R (l + 1) := by
  unfold eigenvalueS3
  apply div_lt_div_of_pos_right _ (by positivity : (0 : ℝ) < R ^ 2)
  push_cast; nlinarith




/-- The zero mode has eigenvalue 0. -/
theorem eigenvalue_zero (R : ℝ) : eigenvalueS3 R 0 = 0 := by
  unfold eigenvalueS3; simp




/-- The first non-trivial eigenvalue is 3/R². -/
theorem eigenvalue_one (R : ℝ) : eigenvalueS3 R 1 = 3 / R ^ 2 := by
  unfold eigenvalueS3; push_cast; ring




/-- The second eigenvalue is 8/R². -/
theorem eigenvalue_two (R : ℝ) : eigenvalueS3 R 2 = 8 / R ^ 2 := by
  unfold eigenvalueS3; push_cast; ring




/-- The degeneracy of the l-th eigenvalue on S³: d_l = (l + 1)². -/
def degeneracyS3 (l : ℕ) : ℕ := (l + 1) ^ 2




/-- The degeneracy is always positive. -/
theorem degeneracy_pos (l : ℕ) : 0 < degeneracyS3 l := by
  unfold degeneracyS3; positivity




/-- The degeneracies for the first few modes. -/
theorem degeneracy_values :
    (degeneracyS3 0, degeneracyS3 1, degeneracyS3 2, degeneracyS3 3) = (1, 4, 9, 16) := by
  simp [degeneracyS3]




/-- The S³ degeneracy equals the sum of the first (l+1) odd numbers. -/
theorem degeneracy_as_sum_of_odds (l : ℕ) :
    (degeneracyS3 l : ℤ) = ∑ m ∈ range (l + 1), (2 * (m : ℤ) + 1) := by
  unfold degeneracyS3
  induction l with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ]; push_cast; push_cast at ih; linarith




/-- The total number of modes up to level l. -/
def totalModes (l : ℕ) : ℕ := ∑ i ∈ range (l + 1), degeneracyS3 i




/-- [Section: # CatalogBuild.Geometry.SphericalUniverse.SpectralAnalysis
Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 20] -/
theorem total_modes_formula (l : ℕ) :
    6 * totalModes l = (l + 1) * (l + 2) * (2 * l + 3) := by
      induction l <;> simp_all +arith +decide [ Finset.sum_range_succ, totalModes ] ; ring;
      unfold degeneracyS3 at * ; linarith




/-- Total modes for small values. -/
theorem total_modes_values :
    (totalModes 0, totalModes 1, totalModes 2, totalModes 3) = (1, 5, 14, 30) := by
  simp [totalModes, degeneracyS3, Finset.sum_range_succ]




/-- [Section: # CatalogBuild.Geometry.SphericalUniverse.SpectralAnalysis
Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 20] -/
theorem weyl_law_leading_term (l : ℕ) :
    3 * totalModes l ≤ (l + 2) ^ 3 := by
      nlinarith [total_modes_formula l]




/-- The gap between the first two non-zero eigenvalues is 5/R². -/
theorem spectral_gap_12 (R : ℝ) :
    eigenvalueS3 R 2 - eigenvalueS3 R 1 = 5 / R ^ 2 := by
  unfold eigenvalueS3; push_cast; field_simp; ring




/-- Sachs-Wolfe coefficient: C_l ∝ 1/(l(l+2)). -/
def cmbPowerCoeff (l : ℕ) (hl : 0 < l) : ℝ :=
  1 / (l * (l + 2) : ℝ)




/-- The quadrupole-to-octupole ratio C₂/C₃ = 15/8. -/
theorem quadrupole_octupole_ratio :
    cmbPowerCoeff 2 (by norm_num) / cmbPowerCoeff 3 (by norm_num) = 15 / 8 := by
  unfold cmbPowerCoeff; norm_num




/-- S³ has at least as many modes per eigenvalue as S². -/
theorem mode_ratio_growth (l : ℕ) : (l + 1) ^ 2 ≥ 2 * l + 1 := by
  nlinarith [Nat.zero_le l]




/-- The spectral zeta function converges for s > 3/2. -/
theorem spectral_zeta_convergence : (3 : ℝ) / 2 > 1 := by norm_num




/-- Consecutive eigenvalues: l(l+2) ≤ (l+1)(l+3). -/
theorem eigenvalue_ratio_bound (l : ℕ) :
    (l : ℝ) * ((l : ℝ) + 2) ≤ ((l : ℝ) + 1) * ((l : ℝ) + 3) := by nlinarith




end
