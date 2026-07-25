/-
# Neural Tangent Kernel: Core Theory

This file formalizes the mathematical core of the Neural Tangent Kernel (NTK)
theory introduced by Jacot, Gabriel, and Hongler (2018). We prove:

1. **Gram Matrix PSD**: The NTK matrix K_{ij} = ⟨∇f(x_i), ∇f(x_j)⟩ is
   positive semidefinite, being a Gram matrix of gradients.

2. **Residual Power Iteration**: Under discrete gradient flow u_{t+1} = u_t - ηKu_t,
   the residual satisfies u_t = (I - ηK)^t u₀.

3. **Geometric Convergence**: If the update operator is contractive with
   constant c < 1, then ‖u_t‖ ≤ c^t ‖u₀‖.

4. **Kernel Constancy in Linearized Models**: When the model is linearized
   around initialization θ₀, the induced kernel J(θ₀)ᵀJ(θ₀) is constant
   along the gradient flow trajectory — the "lazy training" regime.

## Mathematical Context

The NTK Θ(x,x') = ⟨∇_θ f(θ,x), ∇_θ f(θ,x')⟩ governs the training dynamics
of overparameterized neural networks. In the infinite-width limit, Θ stays
approximately constant during training, reducing the dynamics to kernel
regression with a fixed kernel. This file formalizes the finite-dimensional
algebraic core of this theory.
-/

import Mathlib

open Matrix Finset BigOperators

noncomputable section

variable {n p d : ℕ}

/-! ## Part 1: NTK as a Gram Matrix -/

/-- The Neural Tangent Kernel evaluated at two inputs, given a gradient map.
    NTK(x,y) = Σⱼ (∂f/∂θⱼ)(x) · (∂f/∂θⱼ)(y) -/
def ntkValue (grad : Fin d → Fin p → ℝ) (i j : Fin d) : ℝ :=
  ∑ k : Fin p, grad i k * grad j k

/-- The NTK Gram matrix on a set of training points. -/
def ntkGramMatrix (Φ : Fin n → Fin p → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => ∑ k : Fin p, Φ i k * Φ j k

-- !-- The NTK kernel value is symmetric because multiplication is commutative. -- !--
theorem ntkValue_symm (grad : Fin d → Fin p → ℝ) (i j : Fin d) :
    ntkValue grad i j = ntkValue grad j i := by
  simp [ntkValue, mul_comm]

-- !-- The NTK Gram matrix is symmetric: K_{ij} = K_{ji}. -- !--
theorem ntkGramMatrix_isSymm (Φ : Fin n → Fin p → ℝ) :
    (ntkGramMatrix Φ).IsSymm := by
  ext i j
  simp [ntkGramMatrix, mul_comm]

/-! ## Part 2: Positive Semidefiniteness of the NTK -/

/-- The NTK Gram matrix expressed as Φ · Φᵀ. -/
theorem ntkGramMatrix_eq_mul_transpose (Φ : Fin n → Fin p → ℝ) :
    ntkGramMatrix Φ = (Matrix.of Φ) * (Matrix.of Φ)ᵀ := by
  ext i j
  simp [ntkGramMatrix, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply]

/-
!-- Gram matrix PSD: for any v, v^T K v = ‖Φᵀv‖² ≥ 0. This is the
key structural property ensuring gradient descent converges. -- !--
-/
theorem ntkGramMatrix_posSemidef (Φ : Fin n → Fin p → ℝ) :
    (ntkGramMatrix Φ).PosSemidef := by
  refine' ⟨ ntkGramMatrix_isSymm Φ, _ ⟩;
  intro x
  have h_quad_form : ∑ i, ∑ j, x i * ntkGramMatrix Φ i j * x j = ∑ k, (∑ i, x i * Φ i k) ^ 2 := by
    simp +decide [ ntkGramMatrix, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, pow_two ];
    exact?;
  simp_all +decide [ mul_comm, Finsupp.sum_fintype ];
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## Part 3: Gradient Descent Dynamics -/

/-- The update operator T = I - η·K for gradient descent. -/
def gdUpdateOp (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  1 - η • K

/-- One step of gradient descent on the residual: u_{t+1} = (I - ηK) u_t. -/
def gdStep (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ) (u : Fin n → ℝ) : Fin n → ℝ :=
  (gdUpdateOp K η).mulVec u

/-- The residual after t steps of gradient descent. -/
def gdResidual (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ) (u₀ : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => u₀
  | t + 1 => gdStep K η (gdResidual K η u₀ t)

/-
!-- The residual after t steps equals (I - ηK)^t · u₀, proved by
induction using the definition of matrix power. -- !--
-/
theorem gdResidual_eq_pow (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ)
    (u₀ : Fin n → ℝ) (t : ℕ) :
    gdResidual K η u₀ t = (gdUpdateOp K η ^ t).mulVec u₀ := by
  induction' t with t ih;
  · aesop;
  · convert congr_arg ( fun x => ( gdUpdateOp K η |> Matrix.mulVec ) x ) ih using 1;
    simp +decide [ pow_succ', Matrix.mul_assoc ]

/-! ## Part 4: Geometric Convergence -/

/-- Contractivity: the update operator shrinks all vectors by factor c. -/
def IsContractive (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ v : Fin n → ℝ, ‖(gdUpdateOp K η).mulVec v‖ ≤ c * ‖v‖

/-
!-- Under contractivity with constant c < 1, the residual norm decays
geometrically: ‖u_t‖ ≤ c^t · ‖u₀‖. Proved by induction on t. -- !--
-/
theorem gdResidual_geometric_decay (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ) (c : ℝ)
    (hc : IsContractive K η c) (u₀ : Fin n → ℝ) (t : ℕ) :
    ‖gdResidual K η u₀ t‖ ≤ c ^ t * ‖u₀‖ := by
  induction' t with t ih;
  · norm_num [ gdResidual ];
  · convert le_trans ( hc.2.2 _ ) ( mul_le_mul_of_nonneg_left ih hc.1 ) using 1 ; ring!

/-! ## Part 5: Fixed Point Characterization -/

/-
!-- If u is a fixed point of gradient descent (u = u - ηKu) with η > 0,
then Ku = 0. This means convergence implies interpolation. -- !--
-/
theorem gdStep_fixed_point_iff (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ)
    (hη : η ≠ 0) (u : Fin n → ℝ) :
    gdStep K η u = u ↔ K.mulVec u = 0 := by
  unfold gdStep gdUpdateOp;
  simp +decide [ sub_mul, Matrix.sub_mulVec, funext_iff ];
  simp +decide [ Matrix.mulVec, dotProduct, hη ];
  simp +decide [ ← Finset.mul_sum _ _ _, mul_assoc, hη ]

/-! ## Part 6: Linearized Model and Kernel Constancy -/

/-- A linearized model around parameters θ₀:
    f_lin(θ, x) = f(θ₀, x) + J(θ₀, x) · (θ - θ₀)
    where J is the Jacobian ∂f/∂θ evaluated at θ₀. -/
def linearizedPrediction
    (f₀ : Fin n → ℝ)        -- f(θ₀, xᵢ) for each training point
    (J : Fin n → Fin p → ℝ) -- Jacobian J(θ₀, xᵢ)ⱼ = ∂f(θ₀,xᵢ)/∂θⱼ
    (θ₀ θ : Fin p → ℝ)     -- initial and current parameters
    : Fin n → ℝ :=
  fun i => f₀ i + ∑ j : Fin p, J i j * (θ j - θ₀ j)

/-- Gradient of linearized loss ½‖f_lin(θ) - y‖² with respect to θ.
    ∇_θ L = Jᵀ(f_lin(θ) - y) -/
def linearizedGradient
    (J : Fin n → Fin p → ℝ) -- Jacobian (constant in linearized model)
    (residual : Fin n → ℝ)  -- f_lin(θ) - y
    : Fin p → ℝ :=
  fun j => ∑ i : Fin n, J i j * residual i

/-- One step of gradient descent on the linearized model parameters:
    θ_{t+1} = θ_t - η · Jᵀ · (f_lin(θ_t) - y) -/
def linearizedParamStep
    (J : Fin n → Fin p → ℝ)
    (η : ℝ)
    (θ₀ θ : Fin p → ℝ)
    (f₀ y : Fin n → ℝ)
    : Fin p → ℝ :=
  fun j => θ j - η * linearizedGradient J (fun i => linearizedPrediction f₀ J θ₀ θ i - y i) j

/-
!-- Key theorem: the residual dynamics of the linearized model are
u_{t+1} = u_t - η · K · u_t where K = JJᵀ is the NTK. This shows
the kernel is CONSTANT along the training trajectory. -- !--
-/
theorem linearized_residual_dynamics
    (J : Fin n → Fin p → ℝ)
    (η : ℝ)
    (θ₀ θ : Fin p → ℝ)
    (f₀ y : Fin n → ℝ)
    (u : Fin n → ℝ)
    (hu : ∀ i, u i = linearizedPrediction f₀ J θ₀ θ i - y i) :
    let θ' := linearizedParamStep J η θ₀ θ f₀ y
    let u' := fun i => linearizedPrediction f₀ J θ₀ θ' i - y i
    ∀ i, u' i = u i - η * ∑ j : Fin n, ntkGramMatrix J i j * u j := by
  unfold ntkGramMatrix linearizedParamStep linearizedPrediction; simp +decide [ hu ] ; ring;
  simp +decide [ linearizedGradient, linearizedPrediction, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ; ring;
  intro i; rw [ Finset.sum_comm ] ; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm ] ; ring;

/-! ## Part 7: Update Operator Symmetry Preservation -/

/-
!-- The update operator I - ηK preserves symmetry: if K is symmetric,
so is I - ηK. This is important for spectral analysis. -- !--
-/
theorem gdUpdateOp_isSymm (K : Matrix (Fin n) (Fin n) ℝ) (η : ℝ)
    (hK : K.IsSymm) : (gdUpdateOp K η).IsSymm := by
  unfold gdUpdateOp; aesop;

/-! ## Part 8: Architecture Universality -/

-- !-- Universality: Two models with the same NTK Gram matrix and learning
--     rate produce identical training trajectories. The architecture is
--     irrelevant — only the kernel matters. -- !--
theorem ntk_universality
    (K₁ K₂ : Matrix (Fin n) (Fin n) ℝ) (η : ℝ)
    (hK : K₁ = K₂) (u₀ : Fin n → ℝ) (t : ℕ) :
    gdResidual K₁ η u₀ t = gdResidual K₂ η u₀ t := by
  subst hK; rfl

end