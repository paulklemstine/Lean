import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.AntipodalChart2

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10
-/


noncomputable section

/-- The antipodal (south-pole) stereographic projection to the null cone.
This is the complementary chart to `inverseStereoNull`:
k^μ(u, v, ω') = ω' · (1 + u² + v², 2u, 2v, u² + v² - 1)
Note the sign flip in the last component compared to inverseStereoNull.
This chart covers the south pole direction but misses the north pole. -/
def stereoNullAnti (u v ω : ℝ) : Fin 4 → ℝ := fun i =>
  match i with
  | 0 => ω * (1 + u ^ 2 + v ^ 2)
  | 1 => ω * (2 * u)
  | 2 => ω * (2 * v)
  | 3 => ω * (u ^ 2 + v ^ 2 - 1)




/-- **Core Theorem**: The antipodal stereographic chart produces null vectors.
The algebraic identity is the same as for the standard chart:
(1 + r²)² - (2u)² - (2v)² - (r² - 1)² = 0 -/
theorem stereoNull_isNull (u v ω : ℝ) :
    IsNull (stereoNullAnti u v ω) := by
  unfold IsNull minkowskiInner stereoNullAnti; ring




/-- With positive energy, the antipodal chart produces future-directed vectors. -/
theorem stereoNullAnti_future (u v ω : ℝ) (hω : ω > 0) :
    IsFutureDirected (stereoNullAnti u v ω) := by
  exact mul_pos hω (by positivity)




/-- The antipodal chart lands in the future null cone. -/
theorem stereoNullAnti_in_future_cone (u v ω : ℝ) (hω : ω > 0) :
    stereoNullAnti u v ω ∈ FutureNullCone :=
  ⟨stereoNull_isNull u v ω, stereoNullAnti_future u v ω hω⟩




/-- [Section: # CatalogBuild.Geometry.Stereographic.AntipodalChart2
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
lemma stereoNullAnti_surj (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 - k 3 > 0) :
    let u := k 1 / (k 0 - k 3)
    let v := k 2 / (k 0 - k 3)
    let ω := (k 0 - k 3) / 2
    ω > 0 ∧ stereoNullAnti u v ω = k := by
  unfold stereoNullAnti
  grind +suggestions




/-- [Section: # CatalogBuild.Geometry.Stereographic.AntipodalChart2
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
lemma future_null_k0_minus_k3_nonneg (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 - k 3 ≥ 0 := by
  -- From the null condition, we know that $(k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2$.
  have h_null : (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2 := by
    exact null_condition_rearranged k hk.1;
  nlinarith [ hk.2, show 0 ≤ k 0 from hk.2.le ]




theorem chart_coverage (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 > 0 ∨ k 0 - k 3 > 0 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by linarith [ hk.2, show ( k 0 : ℝ ) > 0 from hk.2 ] ;




theorem complete_surjectivity (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    (∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) ∨
    (∃ u v ω : ℝ, ω > 0 ∧ stereoNullAnti u v ω = k) := by
  obtain h|h := chart_coverage k hk;
  · exact Or.inl <| by exact ⟨ _, _, _, by linarith, inverseStereoNull_surj_standard k hk.1 hk.2 h |>.2 ⟩ ;
  · exact Or.inr <| by rcases stereoNullAnti_surj k hk.1 hk.2 h with ⟨ h₁, h₂ ⟩ ; exact ⟨ k 1 / ( k 0 - k 3 ), k 2 / ( k 0 - k 3 ), ( k 0 - k 3 ) / 2, by linarith, by aesop ⟩ ;




/-- **The Full Encoding Theorem**: Combines complete surjectivity with unbounded
information capacity. Every future null direction is covered by stereographic
coordinates, and the information capacity of the celestial sphere is unbounded.
This is the mathematical content of the hypothesis:
"A photon has the encoding of the entire universe, and its worldline
is its inverse stereographic projection." -/
theorem full_encoding_theorem :
    -- Part 1: Every future null vector is covered by a stereographic chart
    (∀ k : Fin 4 → ℝ, k ∈ FutureNullCone →
      (∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) ∨
      (∃ u v ω : ℝ, ω > 0 ∧ stereoNullAnti u v ω = k)) ∧
    -- Part 2: The information capacity is unbounded
    (∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M) :=
  ⟨complete_surjectivity, photonInfoCapacity_unbounded⟩




theorem chart_transition_inversion (k : Fin 4 → ℝ) (hnull : IsNull k)
    (h1 : k 0 + k 3 > 0) (h2 : k 0 - k 3 > 0) :
    let z₁ := k 1 / (k 0 + k 3)
    let z₂ := k 2 / (k 0 + k 3)
    let w₁ := k 1 / (k 0 - k 3)
    let w₂ := k 2 / (k 0 - k 3)
    z₁ * w₁ + z₂ * w₂ = 1 := by
  field_simp;
  linarith [ null_condition_rearranged k hnull ]




end
