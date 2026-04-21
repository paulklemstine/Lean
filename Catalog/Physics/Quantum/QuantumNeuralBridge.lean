/-! # CatalogBuild.Physics.Quantum.QuantumNeuralBridge

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumNeuralBridge
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14] -/
theorem relu_fixed_points : {x : ℝ | relu x = x} = Set.Ici 0 := by
  exact Set.ext fun x => max_eq_left_iff




/-- [Section: # CatalogBuild.Physics.Quantum.QuantumNeuralBridge
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14] -/
theorem matrix_projection_idempotent {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) : P * P * P = P := by
  lia




theorem orthogonal_preserves_dot {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ)
    (hQ : Q * Qᵀ = 1) (u v : Fin n → ℝ) :
    dotProduct (Q.mulVec u) (Q.mulVec v) = dotProduct u v := by
  simp +decide [ Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec, hQ ];
  rw [ mul_eq_one_comm.mp hQ, Matrix.vecMul_one ]




theorem layer_composition_assoc {X : Type*} (f g h : X → X) :
    f ∘ (g ∘ h) = (f ∘ g) ∘ h := by
  rfl




theorem layer_identity_left {X : Type*} (f : X → X) : id ∘ f = f := by
  aesop




theorem layer_identity_right {X : Type*} (f : X → X) : f ∘ id = f := by
  exact?




theorem gate_composition_assoc {n : ℕ} (U V W : Matrix (Fin n) (Fin n) ℝ) :
    U * (V * W) = U * V * W := by
  rw [ Matrix.mul_assoc ]




theorem sin_deriv_at_zero : HasDerivAt sin (cos 0) 0 := by
  exact Real.hasDerivAt_sin 0




theorem parameter_shift_rule (θ : ℝ) :
    cos θ = (sin (θ + π / 2) - sin (θ - π / 2)) / 2 := by
  norm_num [ Real.sin_add, Real.sin_sub ]




theorem chain_rule_at {f g : ℝ → ℝ} {x : ℝ} {f' g' : ℝ}
    (hf : HasDerivAt f f' (g x)) (hg : HasDerivAt g g' x) :
    HasDerivAt (f ∘ g) (f' * g') x := by
  exact hf.comp x hg




theorem dense_subgroup_approximation {G : Type*} [TopologicalSpace G] [Group G]
    (S : Subgroup G) (hS : Dense (S : Set G)) (g : G) :
    g ∈ closure (S : Set G) := by
  exact hS g




theorem bilinear_add_left {R M N P : Type*}
    [CommSemiring R] [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P]
    [Module R M] [Module R N] [Module R P]
    (f : M →ₗ[R] N →ₗ[R] P) (m₁ m₂ : M) (n : N) :
    f (m₁ + m₂) n = f m₁ n + f m₂ n := by
  aesop




theorem contraction_bound (f : ℝ → ℝ) (hf : ∀ x y, |f x - f y| ≤ |x - y|)
    (x y : ℝ) : |f x - f y| ≤ |x - y| := by
  exact hf x y




theorem dropout_scaling (x p : ℝ) :
    (1 - p) * x = x - p * x := by
  ring




end
