/-! # CatalogBuild.Physics.Classical.GravitomagneticStereo

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 38
-/

import Mathlib

noncomputable section

/-- GEM duality preserves the field norm. -/
theorem gem_duality_preserves_norm (F : GEMField) :
    F.dual.normSq = F.normSq := by
  simp only [GEMField.dual, GEMField.normSq]; ring



/-- GEM duality applied twice gives negation. -/
theorem gem_dual_dual (F : GEMField) :
    F.dual.dual = ⟨-F.E_g, -F.B_g⟩ := by
  rfl



/-- The gravitomagnetic Lorentz force: F = -2mvB_g. -/
def gravitomagneticForce (m v B_g : ℝ) : ℝ := -2 * m * v * B_g



/-- The gravitomagnetic force changes sign with velocity (frame-dragging). -/
theorem gravitomagnetic_force_antisymmetric (m v B_g : ℝ) :
    gravitomagneticForce m (-v) B_g = -gravitomagneticForce m v B_g := by
  simp only [gravitomagneticForce]; ring



/-- The gravitomagnetic force vanishes for a stationary test mass. -/
theorem gravitomagnetic_force_stationary (m B_g : ℝ) :
    gravitomagneticForce m 0 B_g = 0 := by
  simp only [gravitomagneticForce]; ring



/-- Lense-Thirring precession rate: Ω_LT = 2GJ/(c²r³). -/
def lenseThirringRate (G J c r : ℝ) : ℝ := 2 * G * J / (c ^ 2 * r ^ 3)



/-- Lense-Thirring precession is positive for prograde angular momentum. -/
theorem lense_thirring_positive (G J c r : ℝ)
    (hG : G > 0) (hJ : J > 0) (hc : c > 0) (hr : r > 0) :
    lenseThirringRate G J c r > 0 := by
  unfold lenseThirringRate; positivity



/-- [Section: # CatalogBuild.Physics.Classical.GravitomagneticStereo
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 38] -/
theorem lense_thirring_monotone (G J c r₁ r₂ : ℝ)
    (hG : G > 0) (hJ : J > 0) (hc : c > 0) (hr₁ : r₁ > 0) (hr₂ : r₂ > 0)
    (hr : r₁ < r₂) :
    lenseThirringRate G J c r₂ < lenseThirringRate G J c r₁ := by
  exact div_lt_div_of_pos_left ( by positivity ) ( by positivity ) ( by gcongr )



/-- The conformal factor is always positive for non-negative |p|². -/
theorem stereo_conf_positive (p_sq : ℝ) (hp : p_sq ≥ 0) :
    stereoConfFactor p_sq > 0 := by
  unfold stereoConfFactor; positivity



theorem stereo_conf_le_four (p_sq : ℝ) (hp : p_sq ≥ 0) :
    stereoConfFactor p_sq ≤ 4 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )



theorem gem_conformal_factor_is_redshift (M r : ℝ) (hM : M > 0) (hr : r > M) :
    stereoConfFactor (r / M - 1) = (2 * M / r) ^ 2 := by
  unfold stereoConfFactor;
  grind +ring



/-- Kelvin inversion: t ↦ 1/t. -/
def kelvinInv (t : ℝ) : ℝ := 1 / t



/-- Kelvin inversion is an involution on ℝ \ {0}. -/
theorem kelvin_involution (t : ℝ) (ht : t ≠ 0) :
    kelvinInv (kelvinInv t) = t := by
  simp only [kelvinInv]; field_simp



/-- Mass-energy duality: inversion × identity = 1. -/
theorem gem_mass_energy_product (B : ℝ) (hB : B ≠ 0) :
    kelvinInv B * B = 1 := by
  simp only [kelvinInv]; field_simp



/-- A GEM-Pythagorean triple: integers (a, b, c) with a² + b² = c². -/
structure GEMPythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  hyp : a ^ 2 + b ^ 2 = c ^ 2



/-- Construct a GEM field from a GEM-Pythagorean triple. -/
def GEMPythTriple.toGEMField (t : GEMPythTriple) : GEMField where
  E_g := 2 * (t.a : ℝ) * (t.b : ℝ) / (t.c : ℝ) ^ 2
  B_g := ((t.b : ℝ) ^ 2 - (t.a : ℝ) ^ 2) / (t.c : ℝ) ^ 2



/-- The fundamental (3,4,5) graviton. -/
def gem345 : GEMPythTriple := ⟨3, 4, 5, by norm_num⟩



/-- The (3,4,5) GEM field components. -/
theorem gem345_field :
    gem345.toGEMField = ⟨24 / 25, 7 / 25⟩ := by
  simp only [gem345, GEMPythTriple.toGEMField, GEMField.mk.injEq]; norm_num



/-- The (3,4,5) graviton has unit norm. -/
theorem gem345_unit : gem345.toGEMField.normSq = 1 := by
  simp only [gem345, GEMPythTriple.toGEMField, GEMField.normSq]; norm_num



/-- The (5,12,13) graviton. -/
def gem51213 : GEMPythTriple := ⟨5, 12, 13, by norm_num⟩



/-- The (5,12,13) graviton has unit norm. -/
theorem gem51213_unit : gem51213.toGEMField.normSq = 1 := by
  simp only [gem51213, GEMPythTriple.toGEMField, GEMField.normSq]; norm_num



/-- Apply a rotation (α, β) with α² + β² = 1 to a GEM field. -/
def gemRotate (F : GEMField) (α β : ℝ) : GEMField where
  E_g := α * F.E_g + β * F.B_g
  B_g := -β * F.E_g + α * F.B_g



theorem berggren_preserves_gem_norm (F : GEMField) (α β : ℝ)
    (hαβ : α ^ 2 + β ^ 2 = 1) :
    (gemRotate F α β).normSq = F.normSq := by
  unfold gemRotate GEMField.normSq; ring;
  linear_combination' hαβ * F.E_g ^ 2 + hαβ * F.B_g ^ 2



/-- GEM energy is non-negative. -/
theorem gem_energy_nonneg (F : GEMField) : F.normSq ≥ 0 := by
  unfold GEMField.normSq; positivity



/-- GEM energy is zero iff both components vanish. -/
theorem gem_energy_zero_iff (F : GEMField) :
    F.normSq = 0 ↔ F.E_g = 0 ∧ F.B_g = 0 := by
  constructor
  · intro h
    unfold GEMField.normSq at h
    constructor <;> nlinarith [sq_nonneg F.E_g, sq_nonneg F.B_g]
  · rintro ⟨h1, h2⟩; simp [GEMField.normSq, h1, h2]



/-- GEM energy is strictly positive for nonzero fields. -/
theorem gem_energy_positive (F : GEMField) (hF : F.E_g ≠ 0 ∨ F.B_g ≠ 0) :
    F.normSq > 0 := by
  unfold GEMField.normSq
  rcases hF with hE | hB <;> positivity



/-- Conformal GEM energy on the plane. -/
def conformalGEMEnergy (F : GEMField) (u v : ℝ) : ℝ :=
  F.normSq * stereoConfFactor (u ^ 2 + v ^ 2)



/-- Conformal GEM energy is non-negative. -/
theorem conformal_gem_energy_nonneg (F : GEMField) (u v : ℝ) :
    conformalGEMEnergy F u v ≥ 0 := by
  unfold conformalGEMEnergy
  apply mul_nonneg (gem_energy_nonneg F)
  exact le_of_lt (stereo_conf_positive _ (by positivity))



/-- GEM field inside an Alcubierre warp bubble. -/
def warpGEM (v_s df_dr f_r r : ℝ) : GEMField where
  E_g := -v_s * df_dr
  B_g := -v_s * f_r / r



/-- GEM resonance condition: ω = B_g/2. -/
def gemResonance (ω B_g : ℝ) : Prop := ω = B_g / 2



/-- At resonance, 2ω = B_g. -/
theorem gem_resonance_doubling (ω B_g : ℝ) (h : gemResonance ω B_g) :
    2 * ω = B_g := by
  unfold gemResonance at h; linarith



/-- Quality factor Q > 1 amplifies the gravitomagnetic field. -/
theorem gem_quality_amp (B_g Q : ℝ) (hB : B_g > 0) (hQ : Q > 1) :
    Q * B_g > B_g := by
  exact lt_mul_of_one_lt_left hB hQ



/-- A GEM Oracle is an idempotent projection on field space. -/
structure GEMOracle where
  proj : GEMField → GEMField
  idempotent : ∀ F, proj (proj F) = proj F



/-- The identity oracle. -/
def identityGEMOracle : GEMOracle where
  proj := id
  idempotent := fun _ => rfl



/-- The zero oracle (projects everything to zero field). -/
def zeroGEMOracle : GEMOracle where
  proj := fun _ => ⟨0, 0⟩
  idempotent := fun _ => rfl



/-- GEM field components in n spatial dimensions: n(n-1)/2. -/
def gemComponents (n : ℕ) : ℕ := n * (n - 1) / 2



/-- In 3D: 3 GEM components. -/
theorem gem_3d : gemComponents 3 = 3 := by native_decide



/-- In 4D spacetime: 6 components (= electromagnetic tensor). -/
theorem gem_4d : gemComponents 4 = 6 := by native_decide



end
