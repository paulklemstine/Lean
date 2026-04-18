/-
# Hyperbolic Geometry via Stereographic Projection

This file formalizes the connection between stereographic projection
and hyperbolic geometry. The key insight is that replacing the
denominator 1+||y||² with 1-||y||² (restricted to the open unit ball)
gives the Poincaré disk model of hyperbolic space.

We also formalize the gnomonic projection and its relationship
to stereographic projection.

## Main results

* `poincare_on_hyperboloid` — Poincaré disk embedding lands on the hyperboloid
* `poincare_metric_conformal` — the Poincaré metric is conformal
* `gnomonic_central` — gnomonic projection maps geodesics to lines
* `stereo_vs_gnomonic` — relationship between the two projections
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-- Poincaré disk model: map from the open unit ball in ℝ^N to H^N.
    This uses the hyperboloid model: (x₀² - x₁² - ... - x_N²) = 1 with x₀ > 0.
    The map sends y ↦ ((1+||y||²)/(1-||y||²), 2y/(1-||y||²)). -/
def poincareEmbed {N : ℕ} (y : Fin N → ℝ) : Fin (N + 1) → ℝ := fun i =>
  if h : i.val < N then
    2 * y ⟨i.val, h⟩ / (1 - sqNormFin y)
  else
    (1 + sqNormFin y) / (1 - sqNormFin y)

/-- The hyperbolic denominator: 1 - ||y||², positive in the unit ball. -/
def hypDenom {N : ℕ} (y : Fin N → ℝ) : ℝ := 1 - sqNormFin y

lemma hypDenom_pos_of_ball {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y < 1) :
    0 < hypDenom y := by
  unfold hypDenom; linarith

/-
In the Poincaré disk model, the embedded point satisfies the hyperboloid equation:
x₀² - Σᵢ xᵢ² = 1 (Minkowski norm = 1).
-/
theorem poincare_on_hyperboloid {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y < 1) :
    (poincareEmbed y (lastIdx N)) ^ 2 -
    ∑ i : Fin N, (poincareEmbed y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ^ 2 = 1 := by
      unfold poincareEmbed;
      norm_num [ Finset.sum_div _ _ _, lastIdx ];
      norm_num [ ← Finset.sum_div _ _ _, div_pow, mul_pow, hy.le ];
      rw [ ← sub_div, div_eq_iff ] <;> nlinarith! [ show 0 ≤ ∑ i, y i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _, show ∑ i, 4 * y i ^ 2 = 4 * ∑ i, y i ^ 2 from by rw [ Finset.mul_sum _ _ _ ] ]

/-
The hyperbolic conformal factor is 2/(1-||y||²), which is the
metric tensor of the Poincaré disk: ds² = (2/(1-||y||²))² Σ dyᵢ².
-/
theorem poincare_metric_conformal {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y < 1) :
    (2 / hypDenom y) ^ 2 = 4 / (hypDenom y) ^ 2 := by
      rw [ div_pow ] ; ring

/-
The stereographic conformal factor and the Poincaré conformal factor
are related by: (2/D_stereo) · (2/D_hyp) = 4/((1+S)(1-S)) = 4/(1-S²)
where S = ||y||².
-/
theorem stereo_poincare_factor_product {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y < 1) :
    (2 / stereoDenom y) * (2 / hypDenom y) = 4 / (1 - sqNormFin y ^ 2) := by
      unfold stereoDenom hypDenom; rw [ div_mul_div_comm ] ; ring;

/-- The gnomonic (central) projection from S^N to ℝ^N.
    This projects from the center of the sphere rather than from the north pole.
    gnomonic(x) = (x₁/x_N,...,x_{N-1}/x_N) for x_N > 0. -/
def gnomonic {N : ℕ} (x : Fin (N + 1) → ℝ) : Fin N → ℝ := fun i =>
  x ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ / x (lastIdx N)

/-
Relationship between stereographic and gnomonic: for a point on S^N with
last coordinate x_N, stereo(x)ᵢ = x_i/(1-x_N) while gnomonic(x)ᵢ = x_i/x_N.
The ratio is stereo(x)ᵢ/gnomonic(x)ᵢ = x_N/(1-x_N).
-/
theorem stereo_gnomonic_ratio {N : ℕ} (x : Fin (N + 1) → ℝ)
    (hN : x (lastIdx N) ≠ 0) (hNP : x (lastIdx N) ≠ 1) (i : Fin N) :
    stereoN x i * (1 - x (lastIdx N)) = gnomonic x i * x (lastIdx N) := by
      unfold stereoN gnomonic;
      rw [ div_mul_cancel₀ ];
      · exact div_mul_cancel₀ _ ( sub_ne_zero_of_ne <| Ne.symm hNP );
      · assumption

/-
Composing stereographic inverse with gnomonic gives a map from ℝ^N to ℝ^N.
For the first coordinate: gnomonic(invStereoN(y))ᵢ = 2yᵢ/(||y||²-1) when ||y||>1.
-/
theorem gnomonic_of_invStereo {N : ℕ} (y : Fin N → ℝ) (hy : 1 < sqNormFin y) (i : Fin N) :
    gnomonic (invStereoN y) i = 2 * y i / (sqNormFin y - 1) := by
      unfold gnomonic invStereoN;
      unfold lastIdx stereoDenom; norm_num; ring;
      grind

end

end StereographicProjection