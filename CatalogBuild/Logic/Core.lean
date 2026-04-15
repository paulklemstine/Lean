/-! # CatalogBuild.Logic.Core

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 32
-/

import Mathlib

noncomputable section

/-- A collection of fundamental physical constants. -/
structure PhysicalConstants where
  c : ℝ       -- speed of light
  G : ℝ       -- gravitational constant
  hbar : ℝ    -- reduced Planck constant
  kB : ℝ      -- Boltzmann constant
  hc_pos : 0 < c
  hG_pos : 0 < G
  hbar_pos : 0 < hbar
  kB_pos : 0 < kB

variable (κ : PhysicalConstants)


/-- Planck length: ℓ_P = √(ħG/c³) -/
def planckLength : ℝ := Real.sqrt (κ.hbar * κ.G / κ.c ^ 3)


/-- Planck mass: m_P = √(ħc/G) -/
def planckMass : ℝ := Real.sqrt (κ.hbar * κ.c / κ.G)


/-- Planck energy: E_P = √(ħc⁵/G) -/
def planckEnergy : ℝ := Real.sqrt (κ.hbar * κ.c ^ 5 / κ.G)


/-- Schwarzschild radius as a function of energy: r_s = 2GE/c⁴ -/
def schwarzschildRadiusEnergy (E : ℝ) : ℝ := 2 * κ.G * E / κ.c ^ 4


/-- Schwarzschild radius as a function of mass: r_s = 2GM/c² -/
def schwarzschildRadius (M : ℝ) : ℝ := 2 * κ.G * M / κ.c ^ 2


/-- Event horizon area: A = 4π r_s² -/
def horizonArea (M : ℝ) : ℝ := 4 * π * (schwarzschildRadius κ M) ^ 2


/-- Bekenstein-Hawking entropy: S_BH = kc³A/(4Għ) -/
def bekensteinHawkingEntropy (M : ℝ) : ℝ :=
  κ.kB * κ.c ^ 3 * horizonArea κ M / (4 * κ.G * κ.hbar)


/-- Information content in bits: I = S/(kB · ln 2) -/
def blackHoleInformation (M : ℝ) : ℝ :=
  bekensteinHawkingEntropy κ M / (κ.kB * Real.log 2)


/-- Photon wavelength from energy: λ = 2πħc/E -/
def photonWavelength (E : ℝ) : ℝ := 2 * π * κ.hbar * κ.c / E


/-- Reduced Compton wavelength: λ̄ = ħc/E -/
def comptonWavelength (E : ℝ) : ℝ := κ.hbar * κ.c / E


/-- The Schwarzschild radius is proportional to energy. -/
theorem schwarzschild_linear (E : ℝ) :
    schwarzschildRadiusEnergy κ E = (2 * κ.G / κ.c ^ 4) * E := by
  unfold schwarzschildRadiusEnergy; ring


/-- The Schwarzschild radius grows with energy. -/
theorem schwarzschild_monotone :
    Monotone (schwarzschildRadiusEnergy κ) := by
  exact fun x y hxy => div_le_div_of_nonneg_right
    (mul_le_mul_of_nonneg_left hxy <| mul_nonneg zero_le_two <| le_of_lt κ.hG_pos)
    (pow_nonneg (le_of_lt κ.hc_pos) 4)


/-- **KEY THEOREM**: At the crossing energy E² = ħc⁵/(2G), the Schwarzschild
radius equals the reduced Compton wavelength. -/
theorem planck_crossing (E : ℝ) (hE : 0 < E)
    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
    schwarzschildRadiusEnergy κ E = comptonWavelength κ E := by
  unfold schwarzschildRadiusEnergy comptonWavelength
  rw [div_eq_div_iff] <;>
    try nlinarith [κ.hc_pos, κ.hG_pos, κ.hbar_pos, pow_pos κ.hc_pos 4]
  rw [eq_div_iff] at hcross <;> nlinarith [κ.hG_pos]


/-- The Bekenstein-Hawking entropy simplifies to S = 4πk_B GM²/(ħc).
This is the standard physics formula. -/
theorem bekenstein_hawking_simplified (M : ℝ) :
    bekensteinHawkingEntropy κ M =
    4 * π * κ.kB * κ.G * M ^ 2 / (κ.hbar * κ.c) := by
  unfold bekensteinHawkingEntropy horizonArea schwarzschildRadius
  have hG := κ.hG_pos
  have hc := κ.hc_pos
  have hbar := κ.hbar_pos
  have hkB := κ.kB_pos
  field_simp
  ring


/-- [Section: ## Part V: Information-Theoretic Properties] -/
theorem entropy_quadratic (M₁ M₂ : ℝ) (hM : 0 ≤ M₁) (hM2 : M₁ ≤ M₂) :
    bekensteinHawkingEntropy κ M₁ ≤ bekensteinHawkingEntropy κ M₂ := by
  rw [ bekenstein_hawking_simplified, bekenstein_hawking_simplified ];
  gcongr;
  · exact mul_nonneg κ.hbar_pos.le κ.hc_pos.le;
  · exact mul_nonneg ( mul_nonneg ( mul_nonneg zero_le_four Real.pi_pos.le ) κ.kB_pos.le ) κ.hG_pos.le


theorem information_content_formula (M : ℝ) :
    blackHoleInformation κ M =
    4 * π * κ.G * M ^ 2 / (κ.hbar * κ.c * Real.log 2) := by
  convert congr_arg ( fun x : ℝ => x / ( κ.kB * Real.log 2 ) ) ( bekenstein_hawking_simplified κ M ) using 1 ; ring;
  norm_num [ κ.kB_pos.ne' ]


/-- [Section: ## Part VI: The Holographic Bound] -/
theorem entropy_area_planck (M : ℝ) :
    bekensteinHawkingEntropy κ M =
    κ.kB * horizonArea κ M / (4 * (planckLength κ) ^ 2) := by
  unfold bekensteinHawkingEntropy planckLength horizonArea; ring;
  field_simp;
  rw [ Real.sq_sqrt ( by exact div_nonneg ( mul_nonneg κ.hG_pos.le κ.hbar_pos.le ) ( pow_nonneg κ.hc_pos.le _ ) ), div_div_eq_mul_div ] ; ring


/-- Each Planck area contributes one nat of entropy. -/
def planckAreasOnHorizon (M : ℝ) : ℝ :=
  horizonArea κ M / (4 * (planckLength κ) ^ 2)


theorem holographic_principle (M : ℝ) :
    bekensteinHawkingEntropy κ M = κ.kB * planckAreasOnHorizon κ M := by
  unfold planckAreasOnHorizon
  rw [entropy_area_planck, mul_div_assoc]


/-- Ratio of Schwarzschild radius to Compton wavelength. -/
def isomorphismParameter (E : ℝ) : ℝ :=
  schwarzschildRadiusEnergy κ E / comptonWavelength κ E


/-- The isomorphism parameter = 2GE²/(ħc⁵). -/
theorem isomorphism_parameter_formula (E : ℝ) (hE : 0 < E) :
    isomorphismParameter κ E = 2 * κ.G * E ^ 2 / (κ.hbar * κ.c ^ 5) := by
  unfold isomorphismParameter schwarzschildRadiusEnergy comptonWavelength
  field_simp


/-- [Section: ## Part VII: The Isomorphism Question] -/
theorem isomorphism_at_crossing (E : ℝ) (hE : 0 < E)
    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
    isomorphismParameter κ E = 1 := by
  rw [isomorphismParameter]
  unfold schwarzschildRadiusEnergy comptonWavelength
  grind +revert


theorem subplanckian_photon_dominates (E : ℝ) (hE : 0 < E)
    (hsub : E ^ 2 < κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
    isomorphismParameter κ E < 1 := by
  rw [ lt_div_iff₀ ( mul_pos two_pos ( by linarith [ κ.hG_pos ] ) ) ] at hsub;
  convert div_lt_one ?_ |>.2 hsub using 1;
  · convert isomorphism_parameter_formula κ E hE using 1 ; ring;
  · exact mul_pos κ.hbar_pos ( pow_pos κ.hc_pos _ )


theorem superplanckian_bh_dominates (E : ℝ) (hE : 0 < E)
    (hsup : κ.hbar * κ.c ^ 5 / (2 * κ.G) < E ^ 2) :
    1 < isomorphismParameter κ E := by
  rw [ isomorphismParameter, lt_div_iff₀ ];
  · rw [ div_lt_iff₀ ( by linarith [ κ.hG_pos ] ) ] at hsup;
    rw [ one_mul, schwarzschildRadiusEnergy, comptonWavelength ];
    rw [ div_lt_div_iff₀ ] <;> nlinarith [ pow_pos κ.hc_pos 4 ];
  · exact div_pos ( mul_pos ( κ.hbar_pos ) ( κ.hc_pos ) ) hE


/-- [Section: ## Part VIII: The Entropy Gap] -/
theorem planck_bh_entropy_simplified
    (h : 0 < κ.hbar * κ.c / κ.G) :
    bekensteinHawkingEntropy κ (planckMass κ) = 4 * π * κ.kB := by
  rw [ @bekenstein_hawking_simplified ];
  unfold planckMass;
  grind


/-- Black hole entropy is positive for positive mass. -/
theorem bh_entropy_pos (M : ℝ) (hM : 0 < M) :
    0 < bekensteinHawkingEntropy κ M := by
  rw [bekenstein_hawking_simplified]
  exact div_pos
    (by have := κ.hG_pos; have := κ.kB_pos; have := κ.hc_pos; have := κ.hbar_pos; positivity)
    (by have := κ.hc_pos; have := κ.hbar_pos; positivity)


/-- Schwarzschild radius is positive for positive mass. -/
theorem schwarzschild_pos (M : ℝ) (hM : 0 < M) :
    0 < schwarzschildRadius κ M := by
  exact div_pos (mul_pos (mul_pos two_pos κ.hG_pos) hM) (sq_pos_of_pos κ.hc_pos)


/-- Photon energy → BH mass with matching wavelength/radius: M = ħc³/(4πGE) -/
def photonToBHMass (E : ℝ) : ℝ :=
  κ.hbar * κ.c ^ 3 / (4 * π * κ.G * E)


/-- BH mass → photon energy with matching radius/wavelength: E = πħc³/(GM) -/
def bhToPhotonEnergy (M : ℝ) : ℝ :=
  π * κ.hbar * κ.c ^ 3 / (κ.G * M)


/-- The round trip photon→BH→photon scales energy by 4π². NOT an isomorphism! -/
theorem round_trip_scaling (E : ℝ) (hE : 0 < E) :
    bhToPhotonEnergy κ (photonToBHMass κ E) = 4 * π ^ 2 * E := by
  unfold photonToBHMass bhToPhotonEnergy
  field_simp
  exact div_self <| mul_ne_zero
    (mul_ne_zero (ne_of_gt κ.hbar_pos) (ne_of_gt κ.hc_pos))
    (ne_of_gt κ.hG_pos)


/-- **MAIN THEOREM**: At the Planck crossing energy:
1. Geometric convergence (r_s = λ_compton)
2. Isomorphism parameter = 1
3. Planck-mass BH still has 4π·kB entropy (not zero like a photon)
Conclusion: Black holes and photons are geometrically isomorphic at the
Planck scale but thermodynamically distinct. The "isomorphism" is a
quasi-isomorphism — exact in geometry, broken by entropy. -/
theorem black_hole_photon_quasi_isomorphism
    (E : ℝ) (hE : 0 < E)
    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G))
    (hconst : 0 < κ.hbar * κ.c / κ.G) :
    schwarzschildRadiusEnergy κ E = comptonWavelength κ E ∧
    isomorphismParameter κ E = 1 ∧
    bekensteinHawkingEntropy κ (planckMass κ) = 4 * π * κ.kB := by
  exact ⟨planck_crossing κ E hE hcross,
         isomorphism_at_crossing κ E hE hcross,
         planck_bh_entropy_simplified κ hconst⟩


end
