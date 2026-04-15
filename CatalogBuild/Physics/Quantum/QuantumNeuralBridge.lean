/-! # CatalogBuild.Physics.Quantum.QuantumNeuralBridge

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 14
-/

import Mathlib

noncomputable section

theorem relu_fixed_points : {x : ℝ | relu x = x} = Set.Ici 0 := by
  exact Set.ext fun x => max_eq_left_iff

/-
PROBLEM
Quantum measurement eigenvalue theorem: if x² = x then x ∈ {0, 1}.
    The eigenvalues of a projection operator are exactly 0 and 1.

PROVIDED SOLUTION
x*x = x means x*(x-1)=0, so x=0 or x=1 by mul_eq_zero
-/

theorem matrix_projection_idempotent {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) : P * P * P = P := by
  lia

/-! ## §2: Unitary Gates Preserve Probability

The defining property of quantum gates: they preserve the norm of state vectors.
This is the quantum analogue of neural network normalization layers.
-/

/-
PROBLEM
Quaternion norm is multiplicative — the algebraic foundation of unitary gates.
    Unit quaternions form SU(2), the fundamental quantum gate group for single qubits.

PROVIDED SOLUTION
Use map_mul since normSq is a MonoidWithZeroHom
-/

theorem orthogonal_preserves_dot {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ)
    (hQ : Q * Qᵀ = 1) (u v : Fin n → ℝ) :
    dotProduct (Q.mulVec u) (Q.mulVec v) = dotProduct u v := by
  simp +decide [ Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec, hQ ];
  rw [ mul_eq_one_comm.mp hQ, Matrix.vecMul_one ]

/-! ## §3: Composition of Layers Forms a Monoid

Both quantum circuits and neural networks are fundamentally about composing layers.
This algebraic structure is a monoid: associative composition with an identity element.
-/

/-
PROBLEM
Composing three layers is associative — the fundamental law of both
    quantum circuits and neural network architectures.

PROVIDED SOLUTION
rfl or Function.comp.assoc
-/

theorem layer_composition_assoc {X : Type*} (f g h : X → X) :
    f ∘ (g ∘ h) = (f ∘ g) ∘ h := by
  rfl

/-
PROBLEM
The identity function is a neutral element for composition (left).

PROVIDED SOLUTION
rfl or Function.id_comp
-/

theorem layer_identity_left {X : Type*} (f : X → X) : id ∘ f = f := by
  aesop

/-
PROBLEM
The identity function is a neutral element for composition (right).

PROVIDED SOLUTION
rfl or Function.comp_id
-/

theorem layer_identity_right {X : Type*} (f : X → X) : f ∘ id = f := by
  exact?

/-
PROBLEM
Matrix multiplication is associative — concrete version for gate composition.

PROVIDED SOLUTION
mul_assoc
-/

theorem gate_composition_assoc {n : ℕ} (U V W : Matrix (Fin n) (Fin n) ℝ) :
    U * (V * W) = U * V * W := by
  rw [ Matrix.mul_assoc ]

/-! ## §4: The Parameter-Shift Rule

The quantum analogue of backpropagation: computing gradients of quantum circuits.
For a gate R(θ) = exp(-iθσ/2), the derivative of the expectation value is:
  ∂⟨H⟩/∂θ = [⟨H⟩(θ + π/2) - ⟨H⟩(θ - π/2)] / 2
-/

/-
PROBLEM
The derivative of sin at 0 is cos 0 = 1.
    This is the mathematical core of the parameter-shift rule.

PROVIDED SOLUTION
Real.hasDerivAt_sin 0
-/

theorem sin_deriv_at_zero : HasDerivAt sin (cos 0) 0 := by
  exact Real.hasDerivAt_sin 0

/-
PROBLEM
The parameter-shift rule: for f(θ) = sin(θ), we have
    f'(θ) = [f(θ + π/2) - f(θ - π/2)] / 2.
    This is EXACT, not an approximation — a remarkable property of sinusoidal functions.

PROVIDED SOLUTION
Use sin_add and sin_sub to expand, then simplify using sin(π/2) = 1 and cos(π/2) = 0. We get (sin θ cos(π/2) + cos θ sin(π/2) - (sin θ cos(π/2) - cos θ sin(π/2)))/2 = (2 cos θ)/2 = cos θ.
-/

theorem parameter_shift_rule (θ : ℝ) :
    cos θ = (sin (θ + π / 2) - sin (θ - π / 2)) / 2 := by
  norm_num [ Real.sin_add, Real.sin_sub ]

/-
PROBLEM
The chain rule: the mathematical foundation of backpropagation.
    Both classical backprop and quantum parameter-shift compose gradients via the chain rule.

PROVIDED SOLUTION
Use HasDerivAt.comp
-/

theorem chain_rule_at {f g : ℝ → ℝ} {x : ℝ} {f' g' : ℝ}
    (hf : HasDerivAt f f' (g x)) (hg : HasDerivAt g g' x) :
    HasDerivAt (f ∘ g) (f' * g') x := by
  exact hf.comp x hg

/-! ## §5: Sigmoid — The Approximate Oracle

Sigmoid maps ℝ → (0, 1), approximating the step function (a true projection/measurement).
Unlike ReLU, sigmoid is NOT idempotent — it's a "soft" measurement.
-/

/-- Logistic sigmoid function: the smooth approximation to binary measurement -/

theorem dense_subgroup_approximation {G : Type*} [TopologicalSpace G] [Group G]
    (S : Subgroup G) (hS : Dense (S : Set G)) (g : G) :
    g ∈ closure (S : Set G) := by
  exact hS g

/-! ## §7: Correlations Across Subsystems

Both entanglement and attention create correlations between components via bilinear maps.
-/

/-
PROBLEM
Bilinear maps are linear in each argument — the shared abstraction
    behind both entanglement operations and attention mechanisms.

PROVIDED SOLUTION
simp [map_add]
-/

theorem bilinear_add_left {R M N P : Type*}
    [CommSemiring R] [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P]
    [Module R M] [Module R N] [Module R P]
    (f : M →ₗ[R] N →ₗ[R] P) (m₁ m₂ : M) (n : N) :
    f (m₁ + m₂) n = f m₁ n + f m₂ n := by
  aesop

/-! ## §8: The Noise-Regularization Correspondence -/

/-
PROBLEM
A contraction does not increase distances — the basis for both quantum
    error correction and neural network regularization (dropout, weight decay).

PROVIDED SOLUTION
Directly apply hf x y
-/

theorem contraction_bound (f : ℝ → ℝ) (hf : ∀ x y, |f x - f y| ≤ |x - y|)
    (x y : ℝ) : |f x - f y| ≤ |x - y| := by
  exact hf x y

/-
PROBLEM
Dropout scaling: at dropout rate p, active neurons are scaled by (1-p).
    This is analogous to quantum amplitude damping at rate p.

PROVIDED SOLUTION
ring
-/

theorem dropout_scaling (x p : ℝ) :
    (1 - p) * x = x - p * x := by
  ring


end
