/-! # CatalogBuild.Bridges.HilbertSpaceBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 8
-/

import Mathlib

/-- Inner product is additive in the first argument. -/
theorem inner_add_left' {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (x y z : E) :
    inner 𝕜 (x + y) z = inner 𝕜 x z + inner 𝕜 y z :=
  inner_add_left x y z


/-- Inner product is additive in the second argument. -/
theorem inner_add_right' {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (x y z : E) :
    inner 𝕜 x (y + z) = inner 𝕜 x y + inner 𝕜 x z :=
  inner_add_right x y z


/-- Inner product is conjugate-linear in the left argument. -/
theorem inner_smul_left' {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (x y : E) (r : 𝕜) :
    inner 𝕜 (r • x) y = (starRingEnd 𝕜) r * inner 𝕜 x y :=
  inner_smul_left x y r


/-- Inner product is linear in the right argument. -/
theorem inner_smul_right' {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (x y : E) (r : 𝕜) :
    inner 𝕜 x (r • y) = r * inner 𝕜 x y :=
  inner_smul_right x y r


/-- ‖x‖² = Re⟨x, x⟩: norm squared equals inner product. -/
theorem norm_sq_eq_inner {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (x : E) :
    RCLike.re (inner 𝕜 x x) = ‖x‖ ^ 2 :=
  inner_self_eq_norm_sq x


/-- A subspace and its orthogonal complement are trivially intersecting. -/
theorem orthogonal_disjoint' {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] (K : Submodule 𝕜 E) :
    Disjoint K Kᗮ :=
  Submodule.orthogonal_disjoint K


/-- Orthonormal vectors have unit norm. -/
theorem orthonormal_unit_norm {𝕜 E : Type*} [RCLike 𝕜] [SeminormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] {ι : Type*} {v : ι → E}
    (h : Orthonormal 𝕜 v) (i : ι) :
    ‖v i‖ = 1 :=
  Orthonormal.norm_eq_one h i


/-- Orthonormal vectors from different indices are orthogonal. -/
theorem orthonormal_pairwise_orthogonal {𝕜 E : Type*} [RCLike 𝕜] [SeminormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] {ι : Type*} {v : ι → E}
    (h : Orthonormal 𝕜 v) {i j : ι} (hij : i ≠ j) :
    inner 𝕜 (v i) (v j) = 0 :=
  Orthonormal.inner_eq_zero h hij

