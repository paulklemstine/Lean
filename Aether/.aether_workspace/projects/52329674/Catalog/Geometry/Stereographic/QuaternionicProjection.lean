import Geometry.Stereographic.Basic
import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.QuaternionicProjection

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 8
-/


noncomputable section

/-- [Section: # Quaternionic Stereographic Projection and the Hopf Fibration
This file develops the quaternionic perspective on stereographic projection,
connecting to the Hopf fibration S³ → S² and its generalizations.
## Main Results
* `hopf_preserves_sphere` — Hopf map sends S³ to S²
* `quaternion_norm_product` — |q₁q₂| = |q₁||q₂|
* `hopf_fiber_north_pole` — fiber over north pole
* `hopf_s1_invariance_z` — S¹ equivariance
* `hopf_linking_identity` — linking number identity
* `invStereoN_neg_first` — negation reverses first N coords
* `invStereoN_neg_last` — negation preserves last coord] -/
theorem hopf_preserves_sphere (x : Fin 4 → ℝ)
    (hx : ∑ i : Fin 4, x i ^ 2 = 1) :
    ∑ i : Fin 3, (hopfMap x i) ^ 2 = 1 := by
  norm_num [ Fin.sum_univ_four, Fin.sum_univ_three ] at *;
  unfold hopfMap;
  grind +qlia


/-- Quaternion norm multiplicativity (Euler 4-square identity) -/
theorem quaternion_norm_product (a b c d e f g h : ℝ) :
    (a*e - b*f - c*g - d*h)^2 +
    (a*f + b*e + c*h - d*g)^2 +
    (a*g - b*h + c*e + d*f)^2 +
    (a*h + b*g - c*f + d*e)^2 =
    (a^2 + b^2 + c^2 + d^2) * (e^2 + f^2 + g^2 + h^2) := by ring


/-- Hopf fiber over north pole: (x₀,x₁,0,0) maps to (0,0,1) -/
theorem hopf_fiber_north_pole (x₀ x₁ : ℝ) (h : x₀^2 + x₁^2 = 1) :
    let x : Fin 4 → ℝ := fun i =>
      match i with
      | ⟨0, _⟩ => x₀
      | ⟨1, _⟩ => x₁
      | _ => 0
    hopfMap x ⟨2, by omega⟩ = 1 := by
  simp [hopfMap, h]


/-- S¹ equivariance: rotation in (x₀,x₁) plane preserves z-component -/
theorem hopf_s1_invariance_z (x₀ x₁ x₂ x₃ θ : ℝ) :
    let x₀' := x₀ * Real.cos θ - x₁ * Real.sin θ
    let x₁' := x₀ * Real.sin θ + x₁ * Real.cos θ
    x₀'^2 + x₁'^2 - x₂^2 - x₃^2 = x₀^2 + x₁^2 - x₂^2 - x₃^2 := by
  simp only
  nlinarith [Real.sin_sq_add_cos_sq θ,
             sq_nonneg (x₀ * Real.cos θ - x₁ * Real.sin θ),
             sq_nonneg (x₀ * Real.sin θ + x₁ * Real.cos θ)]


/-- Linking number identity: (a²+b²)(c²+d²) - (ac+bd)² = (ad-bc)² -/
theorem hopf_linking_identity (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) - (a*c + b*d)^2 = (a*d - b*c)^2 := by ring


/-- Composing invStereoN with hopfMap: ℝ³ → S³ → S² -/
theorem hopf_of_stereo_on_sphere (y : Fin 3 → ℝ) :
    ∑ i : Fin 3, (hopfMap (invStereoN y) i) ^ 2 = 1 := by
  apply hopf_preserves_sphere
  exact invStereoN_norm_sq y


theorem invStereoN_neg_first {N : ℕ} (y : Fin N → ℝ) (i : Fin (N+1)) (hi : i.val < N) :
    invStereoN (fun j => -y j) i = -invStereoN y i := by
  unfold invStereoN;
  unfold stereoDenom;
  unfold sqNormFin;
  split_ifs ; ring


theorem invStereoN_neg_last {N : ℕ} (y : Fin N → ℝ) :
    invStereoN (fun j => -y j) (lastIdx N) = invStereoN y (lastIdx N) := by
  unfold invStereoN lastIdx
  simp [Fin.sum_univ_castSucc, Fin.sum_univ_succ, Fin.sum_univ_zero];
  unfold sqNormFin stereoDenom; norm_num [ Finset.sum_neg_distrib ] ;
  unfold sqNormFin; norm_num [ Finset.sum_neg_distrib ] ;


end
