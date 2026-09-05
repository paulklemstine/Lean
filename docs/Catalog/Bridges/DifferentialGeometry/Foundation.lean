import Mathlib

open Real

open Set

/-! # CatalogBuild.Computation.Oracles.Foundation

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 28
-/


noncomputable section

/-- Inverse stereographic projection: ℝ → S¹ ⊂ ℝ².
The encoding: a massive particle's state t maps to a photon state on S¹. -/
def invStereo (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The encoding maps to S¹. -/
theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  unfold invStereo
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-- Stereographic projection from the unit circle (minus the south pole `(0,-1)`)
back to `ℝ`: `(x, y) ↦ x / (1 + y)`. -/
def stereoProj (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)

/-- A geodesic oracle seeker: an idempotent map that "seeks" fixed points. -/
structure GeodesicOracle (X : Type*) where
  seek : X → X
  idempotent : ∀ x, seek (seek x) = seek x

/-- The solution set of a geodesic oracle. -/
def GeodesicOracle.solutionSet {X : Type*} (O : GeodesicOracle X) : Set X :=
  {x | O.seek x = x}

/-- Every oracle output is already a solution. -/
theorem GeodesicOracle.output_is_solution {X : Type*} (O : GeodesicOracle X) (x : X) :
    O.seek x ∈ O.solutionSet := O.idempotent x

/-- The range of the oracle equals its solution set. -/
theorem GeodesicOracle.range_eq_solutions {X : Type*} (O : GeodesicOracle X) :
    range O.seek = O.solutionSet := by
  ext y; simp only [GeodesicOracle.solutionSet, mem_range, mem_setOf_eq]
  exact ⟨fun ⟨x, hx⟩ => hx ▸ O.idempotent x, fun hy => ⟨y, hy⟩⟩

/-- [Section: # CatalogBuild.Computation.Oracles.Foundation
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 28] -/
theorem stereo_left_inverse (t : ℝ) : stereoProj (invStereo t) = t := by
  unfold invStereo stereoProj; rw [ div_eq_iff ] <;> ring ;
  · linarith [ inv_mul_cancel_left₀ ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) t ];
  · nlinarith [ inv_mul_cancel₀ ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) ]

/-- Lift an oracle from ℝ to S¹ via stereographic projection. -/
def liftOracle (O : GeodesicOracle ℝ) : ℝ × ℝ → ℝ × ℝ :=
  invStereo ∘ O.seek ∘ stereoProj

/-- The lifted oracle preserves S¹. -/
theorem liftOracle_on_circle (O : GeodesicOracle ℝ) (p : ℝ × ℝ) :
    (liftOracle O p).1 ^ 2 + (liftOracle O p).2 ^ 2 = 1 :=
  invStereo_on_circle _

/-- Idempotency of lifted oracle on invStereo image. -/
theorem liftOracle_idempotent_on_image (O : GeodesicOracle ℝ) (t : ℝ) :
    liftOracle O (liftOracle O (invStereo t)) = liftOracle O (invStereo t) := by
  simp only [liftOracle, Function.comp_apply, stereo_left_inverse, O.idempotent]

/-- Angular position via inverse stereo: θ(t) = 2 · arctan(t). -/
def invStereoAngle (t : ℝ) : ℝ := 2 * arctan t

/-- Arc-length (geodesic) distance on S¹. -/
def geodesicDist (t₁ t₂ : ℝ) : ℝ :=
  |invStereoAngle t₁ - invStereoAngle t₂|

/-- [Section: # CatalogBuild.Computation.Oracles.Foundation
Auto-generated from theorem catalog database.
Declarations: 28] -/
theorem geodesicDist_symm (t₁ t₂ : ℝ) : geodesicDist t₁ t₂ = geodesicDist t₂ t₁ := by
  simp [geodesicDist, abs_sub_comm]

theorem geodesicDist_self (t : ℝ) : geodesicDist t t = 0 := by simp [geodesicDist]

theorem geodesicDist_triangle (t₁ t₂ t₃ : ℝ) :
    geodesicDist t₁ t₃ ≤ geodesicDist t₁ t₂ + geodesicDist t₂ t₃ := by
  simp only [geodesicDist, invStereoAngle]; exact abs_sub_le _ _ _

theorem geodesicDist_nonneg (t₁ t₂ : ℝ) : 0 ≤ geodesicDist t₁ t₂ := abs_nonneg _

/-- A geodesic-seeking oracle contracts under geodesic distance. -/
structure GeodesicSeekingOracle extends GeodesicOracle ℝ where
  contractive : ∀ x, geodesicDist (seek x) (seek (seek x)) ≤ geodesicDist x (seek x)

/-- The oracle output has zero geodesic distance to its own image. -/
theorem oracle_geodesic_bridge (O : GeodesicSeekingOracle) (x : ℝ) :
    geodesicDist (O.seek x) (O.seek (O.seek x)) = 0 := by
  simp [geodesicDist, invStereoAngle, O.idempotent]

/-- Information gain = geodesic distance traveled. -/
def infoGain (O : GeodesicOracle ℝ) (x : ℝ) : ℝ := geodesicDist x (O.seek x)

theorem infoGain_nonneg (O : GeodesicOracle ℝ) (x : ℝ) : 0 ≤ infoGain O x :=
  geodesicDist_nonneg x (O.seek x)

/-- At a fixed point, no information is gained. -/
theorem infoGain_at_fixed_point (O : GeodesicOracle ℝ) (x : ℝ)
    (hx : x ∈ O.solutionSet) : infoGain O x = 0 := by
  simp only [GeodesicOracle.solutionSet, mem_setOf_eq] at hx
  simp [infoGain, geodesicDist, hx]

/-- Fisher information: squared geodesic displacement. -/
def fisherInfoOracle (O : GeodesicOracle ℝ) (x : ℝ) : ℝ :=
  (geodesicDist x (O.seek x)) ^ 2

theorem fisherInfoOracle_nonneg (O : GeodesicOracle ℝ) (x : ℝ) :
    0 ≤ fisherInfoOracle O x := sq_nonneg _

/-- At solutions, Fisher information is zero. -/
theorem fisherInfoOracle_zero_at_solution (O : GeodesicOracle ℝ) (x : ℝ)
    (hx : x ∈ O.solutionSet) : fisherInfoOracle O x = 0 := by
  simp only [fisherInfoOracle, GeodesicOracle.solutionSet, mem_setOf_eq] at *
  simp [geodesicDist, hx]

def constOracle (c : ℝ) : GeodesicOracle ℝ where
  seek := fun _ => c
  idempotent _ := rfl

def clampOracle : GeodesicOracle ℝ where
  seek := fun x => max 0 (min x 1)
  idempotent := by intro x; simp [max_def, min_def]; split_ifs <;> linarith

def zeroOracle : GeodesicOracle ℝ where
  seek := fun _ => 0
  idempotent _ := rfl

def sqrtOracle (a : ℝ) : GeodesicOracle ℝ where
  seek := fun _ => Real.sqrt a
  idempotent _ := rfl

theorem geodesicDist_bounded (t₁ t₂ : ℝ) : geodesicDist t₁ t₂ < 2 * π := by
  unfold geodesicDist invStereoAngle;
  exact abs_lt.mpr ⟨ by linarith [ Real.neg_pi_div_two_lt_arctan t₁, Real.arctan_lt_pi_div_two t₁, Real.neg_pi_div_two_lt_arctan t₂, Real.arctan_lt_pi_div_two t₂ ], by linarith [ Real.neg_pi_div_two_lt_arctan t₁, Real.arctan_lt_pi_div_two t₁, Real.neg_pi_div_two_lt_arctan t₂, Real.arctan_lt_pi_div_two t₂ ] ⟩

/-- The constant oracle information gain is the geodesic distance to the constant. -/
theorem constOracle_info (c x : ℝ) :
    infoGain (constOracle c) x = geodesicDist x c := by
  simp [infoGain, constOracle]

end