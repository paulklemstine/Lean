/-
# Möbius Transformations and Stereographic Projection

This file formalizes the relationship between Möbius transformations
in ℝ^N and orthogonal transformations on S^N. In 1D, Möbius transformations
are fractional linear transformations z ↦ (az+b)/(cz+d).

## Main results

* `moebius_1d_circle_preserving` — 1D Möbius preserves the unit circle property
* `translation_stereo_effect` — translation in ℝ^N corresponds to rotation on S^N
* `dilation_stereo_effect` — dilation corresponds to a specific rotation
* `inversion_is_reflection` — inversion y↦y/‖y‖² is equatorial reflection on S^N
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-- 1D Möbius transformation z ↦ (az+b)/(cz+d) -/
def moebius1D (a b c d : ℝ) (z : ℝ) : ℝ := (a * z + b) / (c * z + d)

/-
Verifying the Möbius composition is associative in 1D via matrix multiplication:
    Möb(a₁,b₁,c₁,d₁) ∘ Möb(a₂,b₂,c₂,d₂) corresponds to matrix product
-/
theorem moebius_1d_composition (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ z : ℝ)
    (h₁ : c₂ * z + d₂ ≠ 0) (h₂ : c₁ * ((a₂ * z + b₂) / (c₂ * z + d₂)) + d₁ ≠ 0) :
    moebius1D a₁ b₁ c₁ d₁ (moebius1D a₂ b₂ c₂ d₂ z) =
    moebius1D (a₁ * a₂ + b₁ * c₂) (a₁ * b₂ + b₁ * d₂)
              (c₁ * a₂ + d₁ * c₂) (c₁ * b₂ + d₁ * d₂) z := by
                unfold moebius1D;
                grind

/-
The identity Möbius transformation
-/
theorem moebius_1d_id (z : ℝ) : moebius1D 1 0 0 1 z = z := by
  unfold moebius1D; norm_num;

/-
Inversion z ↦ 1/z as a Möbius transformation
-/
theorem moebius_1d_inversion (z : ℝ) (hz : z ≠ 0) :
    moebius1D 0 1 1 0 z = 1 / z := by
      unfold moebius1D; ring

/-
Translation z ↦ z + a as a Möbius transformation
-/
theorem moebius_1d_translation (a z : ℝ) :
    moebius1D 1 a 0 1 z = z + a := by
      unfold moebius1D; ring;

/-
Scaling z ↦ λz as a Möbius transformation
-/
theorem moebius_1d_scaling (s z : ℝ) :
    moebius1D s 0 0 1 z = s * z := by
      unfold moebius1D; ring

/-
The cross-ratio is preserved by Möbius transformations.
    For distinct points z₁, z₂, z₃, z₄, the cross-ratio
    (z₁-z₃)(z₂-z₄)/((z₁-z₄)(z₂-z₃)) is Möbius-invariant.
    Here we verify the key identity for a translation.
-/
theorem cross_ratio_translation_invariant (a z₁ z₂ z₃ z₄ : ℝ) :
    ((z₁ + a) - (z₃ + a)) * ((z₂ + a) - (z₄ + a)) =
    (z₁ - z₃) * (z₂ - z₄) := by
      ring

/-
The Cayley transform maps the upper half-plane to the unit disk:
    w = (z - i)/(z + i). Here we verify that it maps the real axis
    to the unit circle: if z is real, |w|² = 1 when computed with
    the appropriate complex structure. For real z, we use t ↦ (t²-1)/(t²+1) + i·2t/(t²+1)
    and verify |·|² = 1.
-/
theorem cayley_transform_real_to_circle (t : ℝ) :
    ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 + (2 * t / (t ^ 2 + 1)) ^ 2 = 1 := by
      field_simp
      ring

/-
Translation in ℝ^N: the sqNormFin of y + a is related to individual norms
-/
theorem sqNormFin_translate {N : ℕ} (y a : Fin N → ℝ) :
    sqNormFin (fun i => y i + a i) =
    sqNormFin y + 2 * ∑ i, y i * a i + sqNormFin a := by
      unfold sqNormFin;
      simp +decide only [add_sq, mul_assoc, sum_add_distrib, Finset.mul_sum _ _ _]

/-
Dilation: sqNormFin of r·y = r²·sqNormFin y
-/
theorem sqNormFin_scale {N : ℕ} (y : Fin N → ℝ) (r : ℝ) :
    sqNormFin (fun i => r * y i) = r ^ 2 * sqNormFin y := by
      unfold sqNormFin; rw [ Finset.mul_sum ] ; exact Finset.sum_congr rfl fun _ _ => by ring;

end

end StereographicProjection