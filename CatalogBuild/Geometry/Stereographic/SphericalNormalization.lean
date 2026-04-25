/-! # CatalogBuild.Geometry.Stereographic.SphericalNormalization

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 8
-/

import Mathlib

noncomputable section

/-- Squared norm of a vector. -/
def vecSqNorm (n : ℕ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, (v i) ^ 2





/-- Spherical normalization: project a nonzero vector to the unit sphere
via v ↦ v / ‖v‖. This is the simplest spherical normalization. -/
def sphericalNorm (n : ℕ) (v : Fin n → ℝ) (hv : vecSqNorm n v ≠ 0) : Fin n → ℝ :=
  fun i => v i / Real.sqrt (vecSqNorm n v)





/-- The stereographic spherical normalization: project to Sⁿ⁺¹ via inverse
stereographic projection, providing an extra dimension for "confidence". -/
def stereoSphericalNorm (n : ℕ) (v : Fin n → ℝ) : Fin (n + 1) → ℝ := fun i =>
  let D := 1 + vecSqNorm n v
  if h : i.val < n then
    2 * v ⟨i.val, h⟩ / D
  else
    (vecSqNorm n v - 1) / D





/-- [Section: # CatalogBuild.Geometry.Stereographic.SphericalNormalization
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 8] -/
theorem stereo_spherical_norm_unit (n : ℕ) (v : Fin n → ℝ) :
    ∑ i, (stereoSphericalNorm n v i) ^ 2 = 1 := by
  unfold stereoSphericalNorm;
  norm_num [ Fin.sum_univ_castSucc, Fin.sum_univ_succ ];
  norm_num [ mul_pow, mul_div_assoc, Finset.sum_div _ _ _ ];
  norm_num [ Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_pow, div_pow ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rw [ mul_div, ← add_div, div_eq_iff ] <;> nlinarith! [ show 0 ≤ vecSqNorm n v from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]





/-- [Section: # CatalogBuild.Geometry.Stereographic.SphericalNormalization
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 8] -/
theorem stereo_norm_zero_is_south_pole (n : ℕ) (hn : 0 < n) :
    stereoSphericalNorm n (fun _ => 0) ⟨n, Nat.lt_succ_iff.mpr (le_refl n)⟩ = -1 := by
  unfold stereoSphericalNorm;
  unfold vecSqNorm; aesop





/-- [Section: # CatalogBuild.Geometry.Stereographic.SphericalNormalization
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 8] -/
theorem stereo_norm_last_coord_bound (n : ℕ) (v : Fin n → ℝ) :
    stereoSphericalNorm n v ⟨n, Nat.lt_succ_iff.mpr (le_refl n)⟩ ≤ 1 := by
  unfold stereoSphericalNorm;
  norm_num [ div_le_iff₀, vecSqNorm ];
  rw [ div_le_iff₀ ] <;> linarith [ show 0 ≤ ∑ i, v i ^ 2 by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ]





/-- Exponential map normalization: a smooth normalization that uses the
exponential map on the sphere. Given a base point p ∈ Sⁿ and a
tangent vector v ∈ TₚSⁿ, this produces a point on the sphere.
For the south pole base point, this reduces to inverse stereographic
projection (up to reparameterization). -/
def expMapNorm (θ : ℝ) (v : Fin 2 → ℝ) : Fin 3 → ℝ := fun i =>
  let norm_v := Real.sqrt ((v 0) ^ 2 + (v 1) ^ 2)
  match i with
  | ⟨0, _⟩ => if norm_v = 0 then 0 else Real.sin (θ * norm_v) * v 0 / norm_v
  | ⟨1, _⟩ => if norm_v = 0 then 0 else Real.sin (θ * norm_v) * v 1 / norm_v
  | ⟨2, _⟩ => Real.cos (θ * norm_v)





theorem expMapNorm_unit (θ : ℝ) (v : Fin 2 → ℝ) :
    (expMapNorm θ v 0) ^ 2 + (expMapNorm θ v 1) ^ 2 + (expMapNorm θ v 2) ^ 2 = 1 := by
  by_cases h : Real.sqrt ( ( v 0 ) ^ 2 + ( v 1 ) ^ 2 ) = 0 <;> simp_all +decide [ expMapNorm ];
  field_simp;
  rw [ Real.sq_sqrt ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ] ; rw [ Real.sin_sq, Real.cos_sq ] ; ring





end
