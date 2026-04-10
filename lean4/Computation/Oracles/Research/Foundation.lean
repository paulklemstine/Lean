import Mathlib

/-!
# Geodesic Oracle Seekers on the Inverse Stereographic Manifold

## The Core Idea

We formalize **oracle seekers** — agents that optimally navigate solution spaces
by following geodesics on the sphere obtained via inverse stereographic projection.

### Mathematical Architecture

1. **Lift** the problem from ℝ to S¹ via inverse stereographic projection σ⁻¹
2. **Navigate** by following great-circle geodesics on S¹
3. **Project back** via stereographic projection σ to obtain solutions
4. **Iterate** using oracle idempotency (O² = O) to crystallize at fixed points
-/

open Real Set Function

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════
    §1: ORACLE FOUNDATIONS
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §2: INVERSE STEREOGRAPHIC PROJECTION
    ═══════════════════════════════════════════════════════════════════════ -/

/-- Inverse stereographic projection from ℝ to S¹.
    Maps t ↦ (2t/(1+t²), (t²-1)/(1+t²)). -/
def invStereo (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (t ^ 2 - 1) / (1 + t ^ 2))

/-- Forward stereographic projection (from the north pole (0,1)).
    Maps (x, y) ↦ x / (1 - y). -/
def stereoProj (p : ℝ × ℝ) : ℝ := p.1 / (1 - p.2)

/-- **Core Theorem**: Inverse stereographic projection lands on S¹. -/
theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  simp only [invStereo]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-
PROBLEM
Stereo projection is a left inverse of inverse stereo.

PROVIDED SOLUTION
Unfold stereoProj and invStereo. We need x/(1-y) = t where x = 2t/(1+t²) and y = (t²-1)/(1+t²). Then 1-y = 1 - (t²-1)/(1+t²) = ((1+t²)-(t²-1))/(1+t²) = 2/(1+t²). So x/(1-y) = (2t/(1+t²)) / (2/(1+t²)) = 2t/2 = t.
-/
theorem stereo_left_inverse (t : ℝ) : stereoProj (invStereo t) = t := by
  unfold invStereo stereoProj; rw [ div_eq_iff ] <;> ring ;
  · linarith [ inv_mul_cancel_left₀ ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) t ];
  · nlinarith [ inv_mul_cancel₀ ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) ]

/-! ═══════════════════════════════════════════════════════════════════════
    §3: LIFTED ORACLES ON THE SPHERE
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §4: GEODESIC DISTANCE ON S¹
    ═══════════════════════════════════════════════════════════════════════ -/

/-- Angular position via inverse stereo: θ(t) = 2 · arctan(t). -/
def invStereoAngle (t : ℝ) : ℝ := 2 * arctan t

/-- Arc-length (geodesic) distance on S¹. -/
def geodesicDist (t₁ t₂ : ℝ) : ℝ :=
  |invStereoAngle t₁ - invStereoAngle t₂|

theorem geodesicDist_symm (t₁ t₂ : ℝ) : geodesicDist t₁ t₂ = geodesicDist t₂ t₁ := by
  simp [geodesicDist, abs_sub_comm]

theorem geodesicDist_self (t : ℝ) : geodesicDist t t = 0 := by simp [geodesicDist]

theorem geodesicDist_triangle (t₁ t₂ t₃ : ℝ) :
    geodesicDist t₁ t₃ ≤ geodesicDist t₁ t₂ + geodesicDist t₂ t₃ := by
  simp only [geodesicDist, invStereoAngle]; exact abs_sub_le _ _ _

theorem geodesicDist_nonneg (t₁ t₂ : ℝ) : 0 ≤ geodesicDist t₁ t₂ := abs_nonneg _

/-! ═══════════════════════════════════════════════════════════════════════
    §5: THE ORACLE-GEODESIC BRIDGE
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §6: FISHER INFORMATION
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §7: CONCRETE ORACLES
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-! ═══════════════════════════════════════════════════════════════════════
    §8: COMPACTIFICATION ADVANTAGE
    ═══════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
All geodesic distances on the inverse-stereo S¹ are bounded by 2π.

PROVIDED SOLUTION
Unfold geodesicDist and invStereoAngle. We need |2·arctan(t₁) - 2·arctan(t₂)| < 2π. Factor out 2: 2·|arctan(t₁) - arctan(t₂)|. Since -π/2 < arctan(t) < π/2 for all t (by arctan_lt_pi_div_two and neg_pi_div_two_lt_arctan), we get |arctan(t₁) - arctan(t₂)| < π. So 2·|arctan(t₁) - arctan(t₂)| < 2π.
-/
theorem geodesicDist_bounded (t₁ t₂ : ℝ) : geodesicDist t₁ t₂ < 2 * π := by
  unfold geodesicDist invStereoAngle;
  exact abs_lt.mpr ⟨ by linarith [ Real.neg_pi_div_two_lt_arctan t₁, Real.arctan_lt_pi_div_two t₁, Real.neg_pi_div_two_lt_arctan t₂, Real.arctan_lt_pi_div_two t₂ ], by linarith [ Real.neg_pi_div_two_lt_arctan t₁, Real.arctan_lt_pi_div_two t₁, Real.neg_pi_div_two_lt_arctan t₂, Real.arctan_lt_pi_div_two t₂ ] ⟩

/-- The constant oracle information gain is the geodesic distance to the constant. -/
theorem constOracle_info (c x : ℝ) :
    infoGain (constOracle c) x = geodesicDist x c := by
  simp [infoGain, constOracle]

end