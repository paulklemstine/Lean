/-! # CatalogBuild.Physics.Classical.MassEnergyDuality

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 15
-/

import Mathlib

noncomputable section

/-- Stereographic projection from the North pole (0,1): x/(1-y). -/
def stereoNorth (x y : ℝ) : ℝ := x / (1 - y)



/-- Stereographic projection from the South pole (0,-1): x/(1+y). -/
def stereoSouth (x y : ℝ) : ℝ := x / (1 + y)



/-- [Section: # CatalogBuild.Physics.Classical.MassEnergyDuality
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 16] -/
theorem invStereoNorth_on_circle (t : ℝ) :
    (invStereoNorth' t).1 ^ 2 + (invStereoNorth' t).2 ^ 2 = 1 := by
  simp only [invStereoNorth']
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp; ring



theorem invStereoSouth_on_circle (s : ℝ) :
    (invStereoSouth' s).1 ^ 2 + (invStereoSouth' s).2 ^ 2 = 1 := by
  simp only [invStereoSouth']
  have h : (1 + s ^ 2) ≠ 0 := by positivity
  field_simp; ring



/-- The mass-energy transition map: t ↦ 1/t. -/
def massEnergyTransition (t : ℝ) : ℝ := 1 / t



/-- **Mass-Energy Isomorphism**: Bijection on ℝ \ {0}. -/
theorem mass_energy_bijection :
    Set.BijOn massEnergyTransition {t : ℝ | t ≠ 0} {t : ℝ | t ≠ 0} := by
  constructor
  · intro t ht
    simp only [massEnergyTransition, mem_setOf_eq] at *
    exact div_ne_zero one_ne_zero ht
  constructor
  · intro t₁ ht₁ t₂ ht₂ heq
    simp only [massEnergyTransition, mem_setOf_eq] at *
    simp only [one_div] at heq
    exact inv_injective heq
  · intro s hs
    simp only [mem_setOf_eq] at hs
    exact ⟨1 / s, div_ne_zero one_ne_zero hs, by simp [massEnergyTransition, div_div]⟩



/-- **Involutivity**: (1/(1/t)) = t. -/
theorem mass_energy_involutive (t : ℝ) (_ht : t ≠ 0) :
    massEnergyTransition (massEnergyTransition t) = t := by
  simp [massEnergyTransition]



/-- A physical state: a point on the unit circle.
The photon IS this point. Mass and energy are its two projections. -/
structure PhysicalState where
  x : ℝ
  y : ℝ
  on_circle : x ^ 2 + y ^ 2 = 1



/-- The mass of a physical state (north-pole projection). -/
def PhysicalState.mass (p : PhysicalState) : ℝ := stereoNorth p.x p.y



/-- The energy of a physical state (south-pole projection). -/
def PhysicalState.energy (p : PhysicalState) : ℝ := stereoSouth p.x p.y



/-- **The Duality Relation**: mass × energy = 1. -/
theorem mass_times_energy_eq_one (p : PhysicalState)
    (_hyN : p.y ≠ 1) (_hyS : p.y ≠ -1) (hx : p.x ≠ 0) :
    p.mass * p.energy = 1 := by
  simp only [PhysicalState.mass, PhysicalState.energy, stereoNorth, stereoSouth]
  rw [div_mul_div_comm]
  have h := p.on_circle
  have _ := _hyN; have _ := _hyS
  have h1 : (1 - p.y) * (1 + p.y) = 1 - p.y ^ 2 := by ring
  have h2 : p.x * p.x = p.x ^ 2 := by ring
  rw [h2, h1]
  have h3 : 1 - p.y ^ 2 = p.x ^ 2 := by nlinarith
  rw [h3]
  exact div_self (pow_ne_zero 2 hx)



/-- **Commutative Triangle**: energy = 1 / mass. -/
theorem commutative_triangle (p : PhysicalState)
    (hyN' : p.y ≠ 1) (hyS' : p.y ≠ -1) (hx : p.x ≠ 0) :
    p.energy = 1 / p.mass := by
  have h := mass_times_energy_eq_one p hyN' hyS' hx
  have hm : p.mass ≠ 0 := by
    intro habs; rw [habs, zero_mul] at h; exact zero_ne_one h
  rw [eq_div_iff hm]; linarith



/-- **Location Theorem**: The photon sits on S¹, mass and energy are reciprocal. -/
theorem photon_is_common_ancestor (p : PhysicalState)
    (_hyN : p.y ≠ 1) (_hyS : p.y ≠ -1) (hx : p.x ≠ 0) :
    massEnergyTransition p.mass = p.energy := by
  rw [commutative_triangle p _hyN _hyS hx]; rfl



/-- Inversion is continuous on ℝ \ {0}. -/
theorem inversion_continuous : ContinuousOn (fun t : ℝ => 1 / t) {t | t ≠ 0} := by
  apply ContinuousOn.div continuousOn_const continuousOn_id
  intro x hx; exact hx



/-- **Mass-energy duality is a homeomorphism of ℝ \ {0} to itself.** -/
theorem mass_energy_homeomorphism :
    ∃ f : ℝ → ℝ, (∀ t, t ≠ 0 → f t ≠ 0) ∧
    (∀ t, t ≠ 0 → f (f t) = t) ∧
    ContinuousOn f {t | t ≠ 0} :=
  ⟨fun t => 1 / t,
    fun t ht => div_ne_zero one_ne_zero ht,
    fun t ht => by simp [one_div],
    inversion_continuous⟩



end
