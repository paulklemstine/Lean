/-! # CatalogBuild.Geometry.Stereographic.DimensionalTransform

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/

import Geometry.Stereographic.NDimResearch.Basic
import Mathlib

noncomputable section

/-- Composing invStereoN with the ambient inclusion gives an embedding ℝ^N ↪ ℝ^{N+1}. -/
theorem invStereoN_embedding (N : ℕ) :
    Function.Injective (invStereoN N) := invStereoN_injective N


/-- Two-step embedding: ℝ^N → S^N ⊂ ℝ^{N+1} → S^{N+1} ⊂ ℝ^{N+2}.
First apply invStereoN N, then treat the result as a point in ℝ^{N+1}
and apply invStereoN (N+1). -/
def iteratedInvStereo (N : ℕ) (y : Fin N → ℝ) : Fin (N + 2) → ℝ :=
  invStereoN (N + 1) (invStereoN N y)


/-- The iterated embedding maps to S^{N+1}. -/
theorem iteratedInvStereo_on_sphere (N : ℕ) (y : Fin N → ℝ) :
    ∑ i : Fin (N + 2), (iteratedInvStereo N y i) ^ 2 = 1 := by
  unfold iteratedInvStereo
  exact invStereoN_norm_sq (N + 1) (invStereoN N y)


/-- The iterated embedding is injective: ℝ^N ↪ S^{N+1}. -/
theorem iteratedInvStereo_injective (N : ℕ) :
    Function.Injective (iteratedInvStereo N) := by
  unfold iteratedInvStereo
  exact Function.Injective.comp (invStereoN_injective (N + 1)) (invStereoN_injective N)


/-- K-fold iterated inverse stereographic projection: ℝ^N → S^{N+K-1} ⊂ ℝ^{N+K}.
Defined recursively. -/
def kFoldInvStereo (N : ℕ) : (K : ℕ) → (Fin N → ℝ) → (Fin (N + K) → ℝ)
  | 0 => fun y i => y ⟨i, by omega⟩  -- N + 0 = N
  | K + 1 => fun y => by
      rw [show N + (K + 1) = (N + K) + 1 from by omega]
      exact invStereoN (N + K) (kFoldInvStereo N K y)


/-- [Section: ## K-fold Iterated Stereographic Embedding] -/
theorem kFoldInvStereo_on_sphere (N : ℕ) (K : ℕ) (hK : 0 < K) (y : Fin N → ℝ) :
    ∑ i : Fin (N + K), (kFoldInvStereo N K y i) ^ 2 = 1 := by
  induction hK <;> simp_all +decide [ Fin.sum_univ_castSucc, kFoldInvStereo ];
  · convert invStereoN_norm_sq N y using 1;
    rw [ Fin.sum_univ_castSucc ];
  · exact?


/-- The suspension embeds S^N into S^{N+1} as the "equator":
(x₀, ..., x_N) ↦ (x₀, ..., x_N, 0). -/
def suspensionEmbed (N : ℕ) (x : Fin (N + 1) → ℝ) : Fin (N + 2) → ℝ := fun i =>
  if h : (i : ℕ) < N + 1 then x ⟨i, h⟩ else 0


/-- [Section: ## Suspension Map] -/
theorem suspensionEmbed_on_sphere (N : ℕ) (x : Fin (N + 1) → ℝ)
    (hx : ∑ i : Fin (N + 1), (x i) ^ 2 = 1) :
    ∑ i : Fin (N + 2), (suspensionEmbed N x i) ^ 2 = 1 := by
  rw [ ← hx, Fin.sum_univ_castSucc ];
  simp +decide [ suspensionEmbed ];
  exact Finset.sum_congr rfl fun i hi => if_pos i.is_le


/-- The Hopf map from ℝ⁴ (representing a point on S³) to ℝ³ (representing S²). -/
def hopfMapCoord (x : Fin 4 → ℝ) : Fin 3 → ℝ := fun i =>
  match i with
  | ⟨0, _⟩ => 2 * (x ⟨0, by omega⟩ * x ⟨2, by omega⟩ + x ⟨1, by omega⟩ * x ⟨3, by omega⟩)
  | ⟨1, _⟩ => 2 * (x ⟨1, by omega⟩ * x ⟨2, by omega⟩ - x ⟨0, by omega⟩ * x ⟨3, by omega⟩)
  | ⟨2, _⟩ => (x ⟨0, by omega⟩)^2 + (x ⟨1, by omega⟩)^2 - (x ⟨2, by omega⟩)^2 - (x ⟨3, by omega⟩)^2


/-- [Section: ## Hopf Fibration: S³ → S²] -/
theorem hopfMapCoord_preserves_sphere (x : Fin 4 → ℝ)
    (hx : ∑ i : Fin 4, (x i) ^ 2 = 1) :
    ∑ i : Fin 3, (hopfMapCoord x i) ^ 2 = 1 := by
  simp_all +decide [ Fin.sum_univ_four, Fin.sum_univ_three ];
  unfold hopfMapCoord;
  grind


/-- Composite map from ℝ² to ℝ³ via stereographic + suspension + stereographic.
This gives a concrete way to "transform 2D space into 3D space" using
stereographic projection as the bridge. -/
def stereoLift2to3 (y : Fin 2 → ℝ) : Fin 3 → ℝ :=
  let on_S2 := invStereoN 2 y          -- ℝ² → S² ⊂ ℝ³
  let on_S3 := suspensionEmbed 2 on_S2  -- S² ↪ S³ ⊂ ℝ⁴
  -- Now project S³ \ {NP} → ℝ³
  fun i => on_S3 ⟨i, Nat.lt_succ_of_lt i.isLt⟩ /
    (1 - on_S3 ⟨3, by omega⟩)


/-- [Section: ## Composition: ℝ² →[stereo] S² →[suspend] S³ →[stereo⁻¹] ℝ³] -/
theorem stereoLift2to3_denom_ne_zero (y : Fin 2 → ℝ) :
    1 - suspensionEmbed 2 (invStereoN 2 y) ⟨3, by omega⟩ ≠ 0 := by
  unfold suspensionEmbed; norm_num


end
