import Mathlib
-- import PhotonUniverseEncoding.PhotonUniverseEncoding  -- [consolidated: module not available as separate import]

/-!
# Antipodal Stereographic Chart and Full Surjectivity

## Overview

The standard inverse stereographic projection covers the entire future null cone
*except* the south-pole ray (k⁰ + k³ = 0). To achieve full coverage of S²,
we need a second chart — the antipodal stereographic projection — which covers
the south pole and misses only the north pole.

Together, the two charts form the standard atlas of S² ≅ ℂP¹, with transition
function w = 1/z̄ (equivalently w₁ = u/(u²+v²), w₂ = v/(u²+v²)).

## Main Results

1. `inverseStereoNullAntipodal_is_null`: The antipodal chart also produces null vectors.
2. `inverseStereoNullAntipodal_future`: With positive energy, the result is future-directed.
3. `full_surjectivity`: **Every** future-directed null vector is in the image of one of the
   two charts. This eliminates the south-pole exception entirely.
4. `chart_transition_coords`: The coordinate transition between charts is w = u/r², w₂ = v/r².
-/

open Real BigOperators Finset

noncomputable section

/-! ## The Antipodal (South Pole) Chart -/

/-- The antipodal inverse stereographic projection from ℝ² to the null cone.
    This is the second chart, covering the south pole:

    k^μ(w₁, w₂, ω') = ω' · (1 + w₁² + w₂², 2w₁, 2w₂, w₁² + w₂² - 1)

    Note the sign flip in the last component compared to `inverseStereoNull`.
    The stereographic coordinate is w = k¹/(k⁰ - k³). -/
def inverseStereoNullAntipodal (w₁ w₂ ω : ℝ) : Fin 4 → ℝ := fun i =>
  match i with
  | 0 => ω * (1 + w₁ ^ 2 + w₂ ^ 2)
  | 1 => ω * (2 * w₁)
  | 2 => ω * (2 * w₂)
  | 3 => ω * (w₁ ^ 2 + w₂ ^ 2 - 1)

/-- The antipodal chart also produces null vectors.
    The identity: (1+|w|²)² - (2w₁)² - (2w₂)² - (|w|²-1)² = 0. -/
theorem inverseStereoNullAntipodal_is_null (w₁ w₂ ω : ℝ) :
    IsNull (inverseStereoNullAntipodal w₁ w₂ ω) := by
  unfold IsNull minkowskiInner inverseStereoNullAntipodal; ring

/-- With positive energy, the antipodal chart is future-directed. -/
theorem inverseStereoNullAntipodal_future (w₁ w₂ ω : ℝ) (hω : ω > 0) :
    IsFutureDirected (inverseStereoNullAntipodal w₁ w₂ ω) := by
  exact mul_pos hω (by positivity)

/-- The antipodal chart lands in the future null cone. -/
theorem inverseStereoNullAntipodal_in_future_cone (w₁ w₂ ω : ℝ) (hω : ω > 0) :
    inverseStereoNullAntipodal w₁ w₂ ω ∈ FutureNullCone :=
  ⟨inverseStereoNullAntipodal_is_null w₁ w₂ ω,
   inverseStereoNullAntipodal_future w₁ w₂ ω hω⟩

/-! ## Surjectivity of the Antipodal Chart -/

/-- For a future null vector with k⁰ - k³ > 0, the antipodal reconstruction works. -/
lemma inverseStereoNullAntipodal_surj (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 - k 3 > 0) :
    let w₁ := k 1 / (k 0 - k 3)
    let w₂ := k 2 / (k 0 - k 3)
    let ω := (k 0 - k 3) / 2
    ω > 0 ∧ inverseStereoNullAntipodal w₁ w₂ ω = k := by
  unfold inverseStereoNullAntipodal
  refine' ⟨half_pos hsum, _⟩
  field_simp
  ext i; fin_cases i <;> norm_num
  · rw [div_eq_iff] <;> nlinarith [null_condition_rearranged k hnull]
  · rfl
  · rw [div_eq_iff] <;> nlinarith! [null_condition_rearranged k hnull]

/-! ## Full Surjectivity: Every Future Null Vector is Covered -/

/-- For any future null vector, either k⁰ + k³ > 0 or k⁰ - k³ > 0 (or both).
    This follows because k⁰ > 0 implies both cannot be ≤ 0 simultaneously. -/
lemma future_null_chart_dichotomy (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 > 0 ∨ k 0 - k 3 > 0 := by
  have h_pos : k 0 > 0 := hk.2
  contrapose! h_pos; linarith

/-
PROBLEM
**THE FULL SURJECTIVITY THEOREM**: Every future-directed null vector
    is in the image of either the standard or the antipodal inverse stereographic chart.
    This eliminates the south-pole exception entirely — the two charts together
    cover the entire future null cone, as befits the standard atlas of S² ≅ ℂP¹.

PROVIDED SOLUTION
Use future_null_chart_dichotomy to get k 0 + k 3 > 0 ∨ k 0 - k 3 > 0. In the first case, use inverseStereoNull_surj_standard to get u, v, ω with the standard chart (Left case). In the second case, use inverseStereoNullAntipodal_surj to get w₁, w₂, ω with the antipodal chart (Right case). For each, extract the components from the conjunction.
-/
theorem full_surjectivity (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    (∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) ∨
    (∃ w₁ w₂ ω : ℝ, ω > 0 ∧ inverseStereoNullAntipodal w₁ w₂ ω = k) := by
  cases' future_null_chart_dichotomy k hk with h h;
  · exact Or.inl <| Exists.intro _ <| Exists.intro _ <| Exists.intro _ <| ⟨ by linarith, inverseStereoNull_surj_standard k hk.1 hk.2 h |>.2 ⟩;
  · exact Or.inr <| by rcases inverseStereoNullAntipodal_surj k hk.1 ( by simpa using hk.2 ) h with ⟨ h₁, h₂ ⟩ ; exact ⟨ _, _, _, h₁, h₂ ⟩ ;

/-! ## Chart Transition Function -/

/-
PROBLEM
The chart transition: if a null vector k = inverseStereoNull u v ω (standard chart),
    with u² + v² ≠ 0 (not the north pole), then the same vector is also expressed in the
    antipodal chart with coordinates w₁ = u/(u²+v²), w₂ = v/(u²+v²), and energy
    parameter ω' = ω·(u²+v²). In complex notation, w = z̄/|z|² = 1/z.

PROVIDED SOLUTION
Expand both inverseStereoNullAntipodal and inverseStereoNull. For each component i : Fin 4, show they are equal by ext i; fin_cases i; unfold both definitions; then use field_simp and ring. The key algebraic identities: w₁² + w₂² = (u² + v²)/(u²+v²)² = 1/r2, so ω'*(1 + w₁² + w₂²) = ω*r2*(1 + 1/r2) = ω*(r2 + 1) = ω*(1 + u² + v²). Similarly for other components.
-/
theorem chart_transition_coords (u v ω : ℝ) (hω : ω > 0)
    (hr : u ^ 2 + v ^ 2 ≠ 0) :
    let r2 := u ^ 2 + v ^ 2
    let w₁ := u / r2
    let w₂ := v / r2
    let ω' := ω * r2
    inverseStereoNullAntipodal w₁ w₂ ω' = inverseStereoNull u v ω := by
  unfold inverseStereoNull inverseStereoNullAntipodal; ext i; fin_cases i <;> norm_num <;> ring_nf <;> norm_num [ hr ] ;
  · -- Combine like terms and simplify the expression.
    field_simp [hr]
    ring;
  · grind;
  · grind;
  · -- Combine like terms and simplify the expression.
    field_simp
    ring

/-! ## The Complete Encoding Theorem -/

/-- **The Complete Photon Universe Encoding Theorem**: Combining full surjectivity
    with unbounded information capacity. Every future-directed null vector (without
    exception) is parameterized by an inverse stereographic chart, and the information
    capacity is unbounded. -/
theorem photon_universe_encoding_complete :
    (∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M) ∧
    (∀ k : Fin 4 → ℝ, k ∈ FutureNullCone →
      (∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) ∨
      (∃ w₁ w₂ ω : ℝ, ω > 0 ∧ inverseStereoNullAntipodal w₁ w₂ ω = k)) :=
  ⟨photonInfoCapacity_unbounded, full_surjectivity⟩

end