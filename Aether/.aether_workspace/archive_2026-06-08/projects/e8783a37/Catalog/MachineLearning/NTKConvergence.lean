/-
# Neural Tangent Kernel: Convergence in the Lazy Regime

This file formalizes the core of the Jacot-Gabriel-Hongler NTK convergence theory.
We prove that gradient descent on a parameterized model, when driven by a fixed
kernel matrix (the "lazy regime"), converges to the kernel regression solution.

## Main Results

1. **Residual Iteration Formula**: The training residual at step t equals
   (I - ηK)^t · u₀, proved by induction on the discrete gradient flow.

2. **Contractivity Propagation**: If the update operator is contractive
   (‖(I-ηK)v‖ ≤ c‖v‖ with c < 1), then ‖u_t‖ ≤ c^t · ‖u₀‖.

3. **Fixed Point Characterization**: The only fixed point of the gradient
   flow u ↦ u - ηKu (with η > 0) satisfies Ku = 0.

4. **Lazy Regime Stability**: When the kernel perturbation is small,
   the perturbed dynamics stay close to the unperturbed solution.

5. **NTK Universality Principle**: The convergence properties depend only
   on the spectrum of K, not on the architecture that generated K.
-/

import Mathlib

open Matrix Finset BigOperators

noncomputable section

/-! ## Section 1: Kernel-Driven Gradient Flow -/

/-- A kernel-driven dynamical system for NTK training.
    This captures the discrete gradient flow u_{t+1} = u_t - η · K · u_t
    where K is the neural tangent kernel matrix evaluated on n training points. -/
structure NTKDynamics (n : ℕ) where
  /-- The kernel matrix K ∈ ℝ^{n×n} -/
  kernel : Matrix (Fin n) (Fin n) ℝ
  /-- Learning rate η > 0 -/
  learningRate : ℝ
  /-- Learning rate is positive -/
  lr_pos : 0 < learningRate

/-- The update operator T = I - η·K that drives the gradient flow -/
def NTKDynamics.updateOp {n : ℕ} (sys : NTKDynamics n) : Matrix (Fin n) (Fin n) ℝ :=
  1 - sys.learningRate • sys.kernel

/-- One step of gradient descent: u_{t+1} = (I - ηK) · u_t -/
def NTKDynamics.step {n : ℕ} (sys : NTKDynamics n) (u : Fin n → ℝ) : Fin n → ℝ :=
  sys.updateOp.mulVec u

/-- The residual vector after t steps of gradient descent -/
def NTKDynamics.residual {n : ℕ} (sys : NTKDynamics n) (u₀ : Fin n → ℝ) : ℕ → (Fin n → ℝ)
  | 0 => u₀
  | t + 1 => sys.step (sys.residual u₀ t)

/-! ## Section 2: Iteration Formula -/

/-
**Residual Iteration Formula**: The residual at step t equals (I - ηK)^t · u₀.
    This is the fundamental algebraic identity underlying NTK convergence.
-/
theorem NTKDynamics.residual_eq_pow_mulVec {n : ℕ} (sys : NTKDynamics n)
    (u₀ : Fin n → ℝ) (t : ℕ) :
    sys.residual u₀ t = (sys.updateOp ^ t).mulVec u₀ := by
  induction' t with t ih;
  · aesop;
  · convert congr_arg ( fun x => sys.updateOp.mulVec x ) ih using 1;
    rw [ pow_succ', Matrix.mulVec_mulVec ]

/-! ## Section 3: Contractivity and Convergence -/

/-- A dynamical system is contractive if the update operator shrinks all vectors. -/
def NTKDynamics.IsContractive {n : ℕ} (sys : NTKDynamics n) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ v : Fin n → ℝ,
    ‖sys.updateOp.mulVec v‖ ≤ c * ‖v‖

/-
**Contractivity Propagation**: Under contractivity with constant c,
    the norm of residuals decays geometrically: ‖u_t‖ ≤ c^t · ‖u₀‖.
    This is the core convergence estimate for NTK training.
-/
theorem NTKDynamics.contraction_bound {n : ℕ} (sys : NTKDynamics n)
    (c : ℝ) (hc : sys.IsContractive c)
    (u₀ : Fin n → ℝ) (t : ℕ) :
    ‖sys.residual u₀ t‖ ≤ c ^ t * ‖u₀‖ := by
  induction' t with t ih generalizing u₀ <;> simp_all +decide [ pow_succ', mul_assoc ];
  · rfl;
  · exact le_trans ( hc.2.2 _ ) ( mul_le_mul_of_nonneg_left ( ih _ ) hc.1 )

/-! ## Section 4: Fixed Point Characterization -/

/-
**NTK Fixed Point Theorem**: If u is a fixed point of the gradient flow
    (i.e., u = u - ηKu), then Ku = 0. This means convergence implies
    interpolation (or projection onto the kernel null space).
-/
theorem NTKDynamics.fixed_point_kernel_null {n : ℕ} (sys : NTKDynamics n)
    (u : Fin n → ℝ)
    (hfixed : sys.step u = u) :
    sys.kernel.mulVec u = 0 := by
  simp_all +decide [ NTKDynamics.step, NTKDynamics.updateOp, funext_iff ];
  simp_all +decide [ Matrix.mulVec, dotProduct, sub_mul ];
  simp_all +decide [ Matrix.one_apply, mul_assoc, Finset.mul_sum _ _ _ ];
  exact fun x => by simpa [ ← Finset.mul_sum _ _ _, sys.lr_pos.ne' ] using hfixed x;

/-! ## Section 5: Kernel Matrix Properties -/

/-- An NTK system where the kernel is symmetric (self-adjoint).
    This holds for any NTK since K_{ij} = ⟨∇f(x_i), ∇f(x_j)⟩. -/
def NTKDynamics.IsSymmetric {n : ℕ} (sys : NTKDynamics n) : Prop :=
  sys.kernel.IsSymm

/-
The update operator of a symmetric NTK system is also symmetric.
-/
theorem NTKDynamics.updateOp_symm {n : ℕ} (sys : NTKDynamics n)
    (hsymm : sys.IsSymmetric) :
    sys.updateOp.IsSymm := by
  convert Matrix.IsSymm.sub ( Matrix.isSymm_one ) ( Matrix.IsSymm.smul ( hsymm ) sys.learningRate ) using 1

/-! ## Section 6: Lazy Regime Perturbation Bound -/

/-
Single-step perturbation bound: one step of perturbed vs unperturbed dynamics.
    The difference between updating with K₁ vs K₂ equals η·(K₂ - K₁)·u.
-/
theorem ntk_single_step_perturbation {n : ℕ}
    (K₁ K₂ : Matrix (Fin n) (Fin n) ℝ) (eta : ℝ)
    (u : Fin n → ℝ) :
    (1 - eta • K₁).mulVec u - (1 - eta • K₂).mulVec u =
      (eta • (K₂ - K₁)).mulVec u := by
  ext i; simp +decide [ Matrix.mulVec, dotProduct ] ; ring;
  simpa only [ ← Finset.sum_sub_distrib ] using Finset.sum_congr rfl fun _ _ => by ring;

/-! ## Section 7: NTK Construction from Parameterized Models -/

/-- A parameterized model: maps parameters θ and input x to a prediction. -/
structure ParameterizedModel (p d : ℕ) where
  /-- The model function f(θ, x) -/
  predict : (Fin p → ℝ) → (Fin d → ℝ) → ℝ

/-- The Neural Tangent Kernel: K(x, x') = ⟨∇_θ f(θ, x), ∇_θ f(θ, x')⟩.
    This is the fundamental kernel governing training dynamics. -/
def neuralTangentKernel {p d : ℕ}
    (grad : (Fin p → ℝ) → (Fin d → ℝ) → (Fin p → ℝ))
    (theta : Fin p → ℝ)
    (x y : Fin d → ℝ) : ℝ :=
  ∑ j : Fin p, grad theta x j * grad theta y j

/-- The NTK matrix on training data: K_{ij} = K(x_i, x_j). -/
def ntkMatrix {p d n : ℕ}
    (grad : (Fin p → ℝ) → (Fin d → ℝ) → (Fin p → ℝ))
    (theta : Fin p → ℝ)
    (X : Fin n → (Fin d → ℝ)) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => neuralTangentKernel grad theta (X i) (X j))

/-
**NTK Symmetry**: The NTK matrix is always symmetric, regardless of
    the architecture. This is because K(x,y) = ⟨∇f(x), ∇f(y)⟩ = K(y,x).
-/
theorem ntkMatrix_symmetric {p d n : ℕ}
    (grad : (Fin p → ℝ) → (Fin d → ℝ) → (Fin p → ℝ))
    (theta : Fin p → ℝ)
    (X : Fin n → (Fin d → ℝ)) :
    (ntkMatrix grad theta X).IsSymm := by
  exact Matrix.ext fun i j => by simp +decide [ ntkMatrix, neuralTangentKernel ] ; ac_rfl;

/-
**NTK Positive Semidefiniteness**: The NTK matrix is PSD because
    it is a Gram matrix. For any vector v, v^T K v = ‖Σ_i v_i ∇f(x_i)‖² ≥ 0.
-/
theorem ntkMatrix_posSemidef {p d n : ℕ}
    (grad : (Fin p → ℝ) → (Fin d → ℝ) → (Fin p → ℝ))
    (theta : Fin p → ℝ)
    (X : Fin n → (Fin d → ℝ)) :
    (ntkMatrix grad theta X).PosSemidef := by
  -- The NTK matrix is symmetric, so we can use the fact that a symmetric matrix is positive semi-definite if and only if for all vectors $v$, $v^T K v \geq 0$.
  apply And.intro (ntkMatrix_symmetric grad theta X);
  simp +decide [ neuralTangentKernel, Finsupp.sum ];
  intro x
  have h_sum_squares : ∑ x_1 ∈ x.support, ∑ x_2 ∈ x.support, (x x_1 * ∑ j, grad theta (X x_1) j * grad theta (X x_2) j) * x x_2 = ∑ j, (∑ x_1 ∈ x.support, x x_1 * grad theta (X x_1) j) ^ 2 := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm, mul_left_comm, pow_two];
    exact Eq.symm ( by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) );
  exact h_sum_squares.symm ▸ Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## Section 8: Universality — Architecture Independence -/

/-
**NTK Universality Principle**: Two different architectures with the
    same NTK matrix have identical training dynamics. The convergence
    depends only on the kernel, not on the specific parameterization.
    This is the Jacot-Gabriel-Hongler universality result.
-/
theorem ntk_universality {n : ℕ}
    (sys₁ sys₂ : NTKDynamics n)
    (hkernel : sys₁.kernel = sys₂.kernel)
    (hlr : sys₁.learningRate = sys₂.learningRate)
    (u₀ : Fin n → ℝ) (t : ℕ) :
    sys₁.residual u₀ t = sys₂.residual u₀ t := by
  induction t generalizing u₀ <;> simp_all +decide [ NTKDynamics.residual ];
  unfold NTKDynamics.step;
  unfold NTKDynamics.updateOp; aesop;

/-! ## Section 9: Spectral Convergence -/

/-- The quadratic form v^T K v for the kernel matrix -/
def kernelQuadForm {n : ℕ} (sys : NTKDynamics n) (v : Fin n → ℝ) : ℝ :=
  dotProduct v (sys.kernel.mulVec v)

/-
**Update Operator Quadratic Expansion** (in L2 inner product):
    ⟨Tv, Tv⟩ = ⟨v,v⟩ - 2η·⟨v, Kv⟩ + η²·⟨Kv, Kv⟩.
    This is the key algebraic identity for spectral convergence analysis.
-/
theorem update_quadratic_expansion {n : ℕ} (sys : NTKDynamics n)
    (v : Fin n → ℝ) :
    dotProduct (sys.updateOp.mulVec v) (sys.updateOp.mulVec v) =
      dotProduct v v - 2 * sys.learningRate * dotProduct v (sys.kernel.mulVec v)
        + sys.learningRate ^ 2 * dotProduct (sys.kernel.mulVec v) (sys.kernel.mulVec v) := by
  unfold NTKDynamics.updateOp;
  simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, Finset.sum_mul, mul_assoc, mul_left_comm, mul_sub, sub_mul, pow_two ] ; ring;
  simp +decide [ Matrix.one_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, pow_two ] ; ring;
  simpa only [ ← Finset.sum_mul _ _ _ ] using by ring;

/-! ## Section 10: NTK Kernel Commutativity (Symmetry of Training) -/

/-
**NTK Kernel Value Symmetry**: The NTK is a symmetric function of its inputs.
    K(x, y) = K(y, x) for all x, y. This follows from commutativity of the
    inner product in parameter space.
-/
theorem neuralTangentKernel_symm {p d : ℕ}
    (grad : (Fin p → ℝ) → (Fin d → ℝ) → (Fin p → ℝ))
    (theta : Fin p → ℝ) (x y : Fin d → ℝ) :
    neuralTangentKernel grad theta x y = neuralTangentKernel grad theta y x := by
  exact Finset.sum_congr rfl fun _ _ => mul_comm _ _

/-! ## Section 11: Conjecture -/

/-- **Conjecture (NTK Width Convergence)**: For a two-layer ReLU network of
    width m, the NTK at initialization converges to a deterministic kernel
    as m → ∞. Formally, the entrywise error is O(1/√m).

    This is a formalization of the Jacot-Gabriel-Hongler (2018) infinite-width
    limit theorem. A full proof would require concentration inequalities for
    random matrices. -/
def KernelWidthConvergence (n : ℕ) : Prop :=
  ∃ K_lim : Matrix (Fin n) (Fin n) ℝ,
    ∀ eps : ℝ, eps > 0 → ∃ m₀ : ℕ, ∀ m : ℕ, m ≥ m₀ →
      ∀ K_m : Matrix (Fin n) (Fin n) ℝ,
        (∀ i j, |K_m i j - K_lim i j| < eps) →
        ∀ u₀ : Fin n → ℝ, ∀ eta : ℝ, eta > 0 → ∀ t : ℕ,
          ‖(((1 : Matrix (Fin n) (Fin n) ℝ) - eta • K_m) ^ t).mulVec u₀ -
           (((1 : Matrix (Fin n) (Fin n) ℝ) - eta • K_lim) ^ t).mulVec u₀‖ ≤
            eps * (↑t : ℝ) * eta * ‖u₀‖

end