/-! # CatalogBuild.Geometry.Stereographic.AntipodalChart2

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10
-/

import Mathlib

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

/-! ## Part II: Surjectivity of the Antipodal Chart -/

/-
PROBLEM
For a future null vector with k⁰ - k³ > 0, the antipodal chart reconstruction works.

PROVIDED SOLUTION
Set u = k 1/(k 0 - k 3), v = k 2/(k 0 - k 3), ω = (k 0 - k 3)/2. ω > 0 since k 0 - k 3 > 0. For the equality, use funext i, fin_cases i, unfold stereoNullAnti, then field_simp and use the null condition (null_condition_rearranged). The calculation is analogous to inverseStereoNull_surj_standard but with k 0 - k 3 instead of k 0 + k 3. The key identity: for i=3, ω*(u²+v²-1) = ((k0-k3)/2)*((k1²+k2²)/(k0-k3)² - 1) = ((k0-k3)/2)*((k1²+k2²-(k0-k3)²)/(k0-k3)²). Using the null condition k0²=k1²+k2²+k3², we get k1²+k2² = k0²-k3² = (k0+k3)(k0-k3). So k1²+k2²-(k0-k3)² = (k0+k3)(k0-k3)-(k0-k3)² = (k0-k3)(k0+k3-k0+k3) = 2k3(k0-k3). Then ω*(u²+v²-1) = ((k0-k3)/2)*(2k3(k0-k3))/(k0-k3)² = k3.
-/

lemma stereoNullAnti_surj (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 - k 3 > 0) :
    let u := k 1 / (k 0 - k 3)
    let v := k 2 / (k 0 - k 3)
    let ω := (k 0 - k 3) / 2
    ω > 0 ∧ stereoNullAnti u v ω = k := by
  unfold stereoNullAnti
  grind +suggestions

/-! ## Part III: Chart Coverage -/

/-
PROBLEM
For a future null vector, k⁰ - k³ ≥ 0.

PROVIDED SOLUTION
From FutureNullCone: IsNull k gives (k 0)² = (k 1)² + (k 2)² + (k 3)² (via null_condition_rearranged), so (k 0)² ≥ (k 3)². Since k 0 > 0 (IsFutureDirected), k 0 ≥ |k 3| ≥ k 3, so k 0 - k 3 ≥ 0. Use nlinarith with sq_nonneg.
-/

lemma future_null_k0_minus_k3_nonneg (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 - k 3 ≥ 0 := by
  -- From the null condition, we know that $(k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2$.
  have h_null : (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2 := by
    exact null_condition_rearranged k hk.1;
  nlinarith [ hk.2, show 0 ≤ k 0 from hk.2.le ]

/-
PROBLEM
**Key Lemma**: Every future null vector has either k⁰ + k³ > 0 or k⁰ - k³ > 0
    (or both). This means the two charts together cover everything.

PROVIDED SOLUTION
From FutureNullCone, k 0 > 0. So k 0 + k 3 + (k 0 - k 3) = 2 * k 0 > 0. This means at least one of k 0 + k 3 or k 0 - k 3 is positive. If both were ≤ 0, their sum would be ≤ 0, contradicting 2 * k 0 > 0. Use by_contra and linarith.
-/

theorem chart_coverage (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 > 0 ∨ k 0 - k 3 > 0 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by linarith [ hk.2, show ( k 0 : ℝ ) > 0 from hk.2 ] ;

/-! ## Part IV: Complete Surjectivity -/

/-
PROBLEM
**Complete Surjectivity**: Every future null vector is in the image of one of
    the two stereographic charts. No direction is missed.

PROVIDED SOLUTION
Use chart_coverage to get k 0 + k 3 > 0 ∨ k 0 - k 3 > 0. In the left case, use inverseStereoNull_surj_standard (from PhotonUniverseEncoding) to get the standard chart. In the right case, use stereoNullAnti_surj to get the antipodal chart. Wrap with Or.inl / Or.inr and existentials.
-/

theorem complete_surjectivity (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    (∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) ∨
    (∃ u v ω : ℝ, ω > 0 ∧ stereoNullAnti u v ω = k) := by
  obtain h|h := chart_coverage k hk;
  · exact Or.inl <| by exact ⟨ _, _, _, by linarith, inverseStereoNull_surj_standard k hk.1 hk.2 h |>.2 ⟩ ;
  · exact Or.inr <| by rcases stereoNullAnti_surj k hk.1 hk.2 h with ⟨ h₁, h₂ ⟩ ; exact ⟨ k 1 / ( k 0 - k 3 ), k 2 / ( k 0 - k 3 ), ( k 0 - k 3 ) / 2, by linarith, by aesop ⟩ ;

/-! ## Part V: The Full Encoding Theorem -/

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

/-
PROBLEM
The transition function between charts: if both k⁰ + k³ > 0 and k⁰ - k³ > 0,
    the stereographic coordinates from the two charts are related by inversion:
    w = (k¹ + i·k²)/(k⁰ - k³) is the inverse of z = (k¹ + i·k²)/(k⁰ + k³),
    in the sense that z · w̄ = 1 when k is null (identifying the real coordinates).

PROVIDED SOLUTION
z₁ * w₁ + z₂ * w₂ = (k 1)²/((k 0 + k 3)(k 0 - k 3)) + (k 2)²/((k 0 + k 3)(k 0 - k 3)) = ((k 1)² + (k 2)²)/((k 0)² - (k 3)²). From the null condition (null_condition_rearranged), (k 0)² = (k 1)² + (k 2)² + (k 3)², so (k 1)² + (k 2)² = (k 0)² - (k 3)². Therefore the fraction equals 1. Use field_simp, then nlinarith with null_condition_rearranged.
-/

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
