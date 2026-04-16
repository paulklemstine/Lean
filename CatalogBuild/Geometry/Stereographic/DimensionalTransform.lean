/-! # CatalogBuild.Geometry.Stereographic.DimensionalTransform

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 9
-/

import Geometry.Stereographic.Basic
import Mathlib

noncomputable section

/-- Two-fold inverse stereographic: ℝ^N → ℝ^{N+1} → ℝ^{N+2}
First apply invStereoN to get a point on S^N ⊂ ℝ^{N+1},
then apply invStereoN again to get a point on S^{N+1} ⊂ ℝ^{N+2} -/
def iteratedInvStereo {N : ℕ} (y : Fin N → ℝ) : Fin (N + 2) → ℝ :=
  invStereoN (invStereoN y)


/-- The two-fold inverse stereographic projection lands on S^{N+1} -/
theorem iteratedInvStereo_on_sphere {N : ℕ} (y : Fin N → ℝ) :
    ∑ i : Fin (N + 2), (iteratedInvStereo y i) ^ 2 = 1 :=
  invStereoN_norm_sq (invStereoN y)


theorem iteratedInvStereo_injective {N : ℕ} :
    Function.Injective (@iteratedInvStereo N) := by
      convert Function.Injective.comp ?_ ?_ using 1;
      · exact?;
      · exact?


/-- Suspension embedding: S^N ↪ S^{N+1} via (x₁,...,x_{N+1}) ↦ (x₁,...,x_{N+1}, 0) -/
def suspensionEmbed {N : ℕ} (x : Fin (N + 1) → ℝ) : Fin (N + 2) → ℝ := fun i =>
  if h : i.val < N + 1 then x ⟨i.val, h⟩ else 0


theorem suspensionEmbed_on_sphere {N : ℕ} (x : Fin (N + 1) → ℝ)
    (hx : ∑ i : Fin (N + 1), x i ^ 2 = 1) :
    ∑ i : Fin (N + 2), (suspensionEmbed x i) ^ 2 = 1 := by
      unfold suspensionEmbed;
      simp_all +decide [ Fin.sum_univ_castSucc ]


/-- The Hopf map S³ → S² in coordinates:
(x₀, x₁, x₂, x₃) ↦ (2(x₀x₂ + x₁x₃), 2(x₁x₂ - x₀x₃), x₀² + x₁² - x₂² - x₃²) -/
def hopfMapCoord (x : Fin 4 → ℝ) : Fin 3 → ℝ := fun i =>
  match i with
  | ⟨0, _⟩ => 2 * (x 0 * x 2 + x 1 * x 3)
  | ⟨1, _⟩ => 2 * (x 1 * x 2 - x 0 * x 3)
  | ⟨2, _⟩ => x 0 ^ 2 + x 1 ^ 2 - x 2 ^ 2 - x 3 ^ 2
  | ⟨n + 3, h⟩ => absurd h (by omega)


theorem hopfMapCoord_preserves_sphere (x : Fin 4 → ℝ)
    (hx : ∑ i : Fin 4, x i ^ 2 = 1) :
    ∑ i : Fin 3, (hopfMapCoord x i) ^ 2 = 1 := by
      simp_all +decide [ Fin.sum_univ_four ];
      rw [ Fin.sum_univ_three ] ; unfold hopfMapCoord ; ring;
      nlinarith


/-- Composed lift from ℝ² to ℝ³: invStereo then suspend then stereo -/
def stereoLift2to3 (y : Fin 2 → ℝ) : Fin 3 → ℝ :=
  stereoN (suspensionEmbed (invStereoN y))


theorem stereoLift2to3_denom_ne_zero (y : Fin 2 → ℝ) :
    1 - suspensionEmbed (invStereoN y) (lastIdx 3) ≠ 0 := by
      erw [ show suspensionEmbed ( invStereoN y ) ( lastIdx 3 ) = 0 from _ ] <;> norm_num;
      exact?


end
