/-
Copyright (c) 2025. All rights reserved.

# Reflection Positivity and Spectral Gaps for Transfer Matrices

This file establishes the mathematical bridge from Osterwalder–Schrader reflection
positivity to spectral gap existence via transfer matrices and Perron–Frobenius theory,
in the finite-dimensional setting relevant to lattice gauge theory.

## Main definitions

* `ReflectionPositiveKernel` — A kernel with an involution satisfying OS positivity
* `TransferMatrix` — The transfer matrix induced by a symmetric kernel and involution
* `HasSimpleTopEigenvalue` — A positive operator has a unique largest eigenvalue of multiplicity 1

## Main results

* `transferMatrix_nonneg_entries` — Nonneg kernel implies nonneg transfer matrix entries
* `osForm_nonneg` — The OS quadratic form is nonneg for reflection-positive kernels
* `transferMatrix_posSemidef_quadForm` — OS positivity → transfer matrix pos semidefinite form
* `factored_kernel_posSemidef` — Gram/factored kernels have pos semidef quadratic forms
* `factored_kernel_os_positive` — Factored kernels are reflection positive
* `wilsonKernel_pos` — Wilson kernel entries are strictly positive
* `wilsonTransferMatrix_positivityImproving` — Wilson transfer is positivity improving
* `isPositivityImproving_of_pos_entries` — All-positive entries ⟹ positivity improving

## References

- Osterwalder, K., Schrader, R.: Axioms for Euclidean Green's functions (1973)
- Glimm, J., Jaffe, A.: Quantum Physics — A Functional Integral Point of View (1987)
-/

import Mathlib

open Finset BigOperators Matrix

/-! ## Section 1: Reflection Positive Kernels -/

/-- A **reflection-positive kernel** consists of a kernel `K : α → α → ℝ` together with
an involution `θ : α → α` (representing time reflection) such that for every function `f`,
the OS quadratic form `∑ x y, f x * K (θ x) y * f y` is nonneg.

This is the finite-dimensional version of the Osterwalder–Schrader positivity axiom. -/
structure ReflectionPositiveKernel (α : Type*) [Fintype α] where
  /-- The kernel function -/
  K : α → α → ℝ
  /-- The time-reflection involution -/
  theta : α → α
  /-- θ is an involution -/
  theta_involutive : Function.Involutive theta
  /-- The OS quadratic form is nonnegative for all functions -/
  os_nonneg : ∀ f : α → ℝ, 0 ≤ ∑ x : α, ∑ y : α, f x * K (theta x) y * f y

/-- The OS quadratic form associated with a kernel and involution. -/
def osForm {α : Type*} [Fintype α] (K : α → α → ℝ) (theta : α → α) (f : α → ℝ) : ℝ :=
  ∑ x : α, ∑ y : α, f x * K (theta x) y * f y

/-- Basic property: the OS form is nonneg for reflection-positive kernels. -/
theorem osForm_nonneg {α : Type*} [Fintype α]
    (rpk : ReflectionPositiveKernel α) (f : α → ℝ) :
    0 ≤ osForm rpk.K rpk.theta f :=
  rpk.os_nonneg f

/-! ## Section 2: Transfer Matrix Construction -/

/-- The **transfer matrix** induced by a kernel K and involution θ.
Entry `T x y = K (θ x) y`, capturing the one-time-step propagator. -/
def transferMatrixOf {α : Type*} (K : α → α → ℝ) (theta : α → α) :
    Matrix α α ℝ :=
  Matrix.of (fun x y => K (theta x) y)

/-- The transfer matrix entries are given by the kernel composed with the involution. -/
@[simp]
theorem transferMatrixOf_apply {α : Type*}
    (K : α → α → ℝ) (theta : α → α) (x y : α) :
    transferMatrixOf K theta x y = K (theta x) y := rfl

/-- If K has nonnegative entries everywhere, the transfer matrix has nonneg entries. -/
theorem transferMatrix_nonneg_entries {α : Type*} [Fintype α]
    (K : α → α → ℝ) (theta : α → α)
    (hK : ∀ x y, 0 ≤ K x y) :
    ∀ i j, 0 ≤ transferMatrixOf K theta i j := by
  intro i j
  simp [transferMatrixOf]
  exact hK (theta i) j

/-! ## Section 3: Quadratic Form Positivity -/

/-- The quadratic form associated with the transfer matrix equals the OS form.
This is the key bridge: OS positivity becomes operator positivity. -/
theorem transferMatrix_quadForm_eq_osForm {α : Type*} [Fintype α]
    (K : α → α → ℝ) (theta : α → α) (f : α → ℝ) :
    ∑ x : α, ∑ y : α, f x * transferMatrixOf K theta x y * f y =
    osForm K theta f := by
  simp only [osForm, transferMatrixOf, transferMatrixOf_apply]
  rfl

/-- **Main Bridge Theorem**: Reflection positivity of K implies the transfer matrix
induces a positive semidefinite quadratic form. -/
theorem transferMatrix_posSemidef_quadForm {α : Type*} [Fintype α]
    (rpk : ReflectionPositiveKernel α) (f : α → ℝ) :
    0 ≤ ∑ x : α, ∑ y : α, f x * transferMatrixOf rpk.K rpk.theta x y * f y := by
  rw [transferMatrix_quadForm_eq_osForm]
  exact osForm_nonneg rpk f

/-! ## Section 4: Constructing Reflection-Positive Kernels -/

/-
A factored kernel `K(x,y) = ∑ k, L(x,k) * L(y,k)` gives a positive semidefinite
quadratic form. This is the Gram matrix construction.
-/
theorem factored_kernel_posSemidef {α β : Type*} [Fintype α] [Fintype β]
    (L : α → β → ℝ) :
    let K := fun x y => ∑ k : β, L x k * L y k
    ∀ f : α → ℝ, 0 ≤ ∑ x : α, ∑ y : α, f x * K x y * f y := by
  -- Expand the sum and regroup: ∑ x y, f(x) * (∑ k, L(x,k) * L(y,k)) * f(y) = ∑ k, (∑ x, f(x) * L(x,k)) * (∑ y, L(y,k) * f(y)) = ∑ k, (∑ x, f(x) * L(x,k))^2 ≥ 0.
  have h_expand : ∀ f : α → ℝ, ∑ x, ∑ y, f x * (∑ k, L x k * L y k) * f y = ∑ k, (∑ x, f x * L x k) * (∑ y, f y * L y k) := by
    simp +decide only [Finset.mul_sum _ _ _, sum_mul, mul_right_comm, mul_assoc];
    exact fun f => Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) ) );
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ];
  exact fun f => Finset.sum_nonneg fun k _ => mul_self_nonneg _

/-
A **θ-factored kernel** is one where `K(θx, y) = ∑ k M(x,k) * M(y,k)` for some M.
Equivalently, the transfer matrix T(x,y) = K(θx, y) is a Gram matrix.
This is the natural condition ensuring reflection positivity.
-/
theorem theta_factored_kernel_os_positive {α β : Type*} [Fintype α] [Fintype β]
    (M : α → β → ℝ) (theta : α → α) (htheta : Function.Involutive theta) :
    let K := fun x y => ∑ k : β, M (theta x) k * M y k
    ∀ f : α → ℝ, 0 ≤ osForm K theta f := by
  unfold osForm;
  intro K f
  have h_expand : ∑ x : α, ∑ y : α, f x * (∑ k : β, M (theta (theta x)) k * M y k) * f y = ∑ k : β, (∑ x : α, f x * M x k) * (∑ y : α, f y * M y k) := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm, mul_left_comm, mul_assoc, sum_mul];
    exact Eq.symm ( by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ htheta ] ; ring ) );
  convert h_expand.symm ▸ Finset.sum_nonneg fun k _ => mul_self_nonneg _ using 1

/-
A factored kernel `K(x,y) = ∑ k L(x,k) * L(y,k)` where L is θ-invariant
(`L(θx,k) = L(x,k)`) gives a reflection-positive OS form.
Under θ-invariance, the OS form equals `∑ k (∑ x f(x) * L(x, k))² ≥ 0`.
-/
theorem factored_kernel_os_positive_of_invariant {α β : Type*} [Fintype α] [Fintype β]
    (L : α → β → ℝ) (theta : α → α) (htheta : Function.Involutive theta)
    (hinv : ∀ x k, L (theta x) k = L x k) :
    let K := fun x y => ∑ k : β, L x k * L y k
    ∀ f : α → ℝ, 0 ≤ osForm K theta f := by
  convert factored_kernel_posSemidef L using 1;
  simp +decide only [osForm, hinv]

/-- **Corollary**: A θ-factored kernel defines a reflection-positive kernel structure. -/
noncomputable def ReflectionPositiveKernel.ofThetaFactored {α β : Type*} [Fintype α] [Fintype β]
    (M : α → β → ℝ) (theta : α → α) (htheta : Function.Involutive theta) :
    ReflectionPositiveKernel α where
  K := fun x y => ∑ k : β, M (theta x) k * M y k
  theta := theta
  theta_involutive := htheta
  os_nonneg := theta_factored_kernel_os_positive M theta htheta

/-! ## Section 5: Spectral Gap Definitions -/

/-- A symmetric matrix has a **simple top eigenvalue** if there exists a largest eigenvalue
that is positive and has a one-dimensional eigenspace. -/
structure HasSimpleTopEigenvalue {n : Type*} [Fintype n] [DecidableEq n]
    (T : Matrix n n ℝ) where
  /-- The top eigenvalue -/
  topEigenval : ℝ
  /-- The top eigenvalue is positive -/
  topEigenval_pos : 0 < topEigenval
  /-- An eigenvector for the top eigenvalue -/
  topEigenvec : n → ℝ
  /-- The eigenvector is nonzero -/
  topEigenvec_ne_zero : ∃ i, topEigenvec i ≠ 0
  /-- T * eigenvec = topEigenval • eigenvec (componentwise) -/
  is_eigenpair : ∀ i, ∑ j, T i j * topEigenvec j = topEigenval * topEigenvec i
  /-- topEigenval is the largest: all other eigenvalues are ≤ it -/
  is_largest : ∀ (mu : ℝ) (v : n → ℝ),
    (∃ i, v i ≠ 0) →
    (∀ i, ∑ j, T i j * v j = mu * v i) →
    mu ≤ topEigenval
  /-- Uniqueness: any eigenvector for topEigenval is proportional to topEigenvec -/
  eigenspace_dim_one : ∀ (v : n → ℝ),
    (∀ i, ∑ j, T i j * v j = topEigenval * v i) →
    ∃ c : ℝ, ∀ i, v i = c * topEigenvec i

/-! ## Section 6: Positivity Improving Matrices -/

/-- A matrix is **positivity improving** if it maps every nonzero nonneg vector
to a strictly positive vector. This is the key condition for Perron–Frobenius. -/
def IsPositivityImproving {n : Type*} [Fintype n]
    (T : Matrix n n ℝ) : Prop :=
  ∀ v : n → ℝ,
    (∀ i, 0 ≤ v i) →
    (∃ i, v i ≠ 0) →
    ∀ j, 0 < ∑ i, T j i * v i

/-
If a matrix has strictly positive entries, it is positivity improving.
-/
theorem isPositivityImproving_of_pos_entries {n : Type*} [Fintype n] [Nonempty n]
    (T : Matrix n n ℝ)
    (hpos : ∀ i j, 0 < T i j) :
    IsPositivityImproving T := by
  intro v hv hv_ne_zero j;
  exact lt_of_lt_of_le ( mul_pos ( hpos _ _ ) ( lt_of_le_of_ne ( hv _ ) ( Ne.symm hv_ne_zero.choose_spec ) ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( le_of_lt ( hpos j i ) ) ( hv i ) ) ( Finset.mem_univ _ ) )

/-! ## Section 7: Wilson Plaquette Kernel -/

/-- A **Wilson-type kernel** on a finite set, parametrized by a coupling β > 0
and a "plaquette weight" function. This models the Boltzmann weight
`exp(β * w(x,y))` in finite-volume lattice gauge theory. -/
noncomputable def wilsonKernel {α : Type*}
    (plaquetteWeight : α → α → ℝ) (beta : ℝ) : α → α → ℝ :=
  fun x y => Real.exp (beta * plaquetteWeight x y)

/-- Wilson kernel entries are strictly positive. -/
theorem wilsonKernel_pos {α : Type*}
    (w : α → α → ℝ) (beta : ℝ) (x y : α) :
    0 < wilsonKernel w beta x y := by
  simp [wilsonKernel]
  exact Real.exp_pos _

/-- Wilson kernel entries are nonneg. -/
theorem wilsonKernel_nonneg {α : Type*}
    (w : α → α → ℝ) (beta : ℝ) (x y : α) :
    0 ≤ wilsonKernel w beta x y :=
  le_of_lt (wilsonKernel_pos w beta x y)

/-- The Wilson transfer matrix for a plaquette weight and involution. -/
noncomputable def wilsonTransferMatrix {α : Type*}
    (plaquetteWeight : α → α → ℝ) (theta : α → α) (beta : ℝ) : Matrix α α ℝ :=
  transferMatrixOf (wilsonKernel plaquetteWeight beta) theta

/-- The Wilson transfer matrix has strictly positive entries. -/
theorem wilsonTransferMatrix_pos_entries {α : Type*}
    (w : α → α → ℝ) (theta : α → α) (beta : ℝ) (i j : α) :
    0 < wilsonTransferMatrix w theta beta i j := by
  simp [wilsonTransferMatrix, transferMatrixOf, Matrix.of, wilsonKernel]
  exact Real.exp_pos _

/-- **Key theorem**: The Wilson transfer matrix is positivity improving
(since all entries are strictly positive). -/
theorem wilsonTransferMatrix_positivityImproving {α : Type*} [Fintype α] [Nonempty α]
    (w : α → α → ℝ) (theta : α → α) (beta : ℝ) :
    IsPositivityImproving (wilsonTransferMatrix w theta beta) := by
  apply isPositivityImproving_of_pos_entries
  intro i j
  exact wilsonTransferMatrix_pos_entries w theta beta i j

/-- The Wilson kernel is symmetric when the plaquette weight is symmetric. -/
theorem wilsonKernel_symm {α : Type*}
    (w : α → α → ℝ) (beta : ℝ)
    (hw : ∀ x y, w x y = w y x) :
    ∀ x y, wilsonKernel w beta x y = wilsonKernel w beta y x := by
  intro x y
  simp [wilsonKernel, hw x y]

/-! ## Section 8: Spectral Gap from Simple Top Eigenvalue -/

/-
If a matrix has a simple top eigenvalue and at least one other eigenvalue,
there is a strictly positive spectral gap.
-/
theorem spectralGap_pos_of_simpleTop
    {n : Type*} [Fintype n] [DecidableEq n]
    (T : Matrix n n ℝ)
    (htop : HasSimpleTopEigenvalue T)
    (hother : ∃ (mu : ℝ) (v : n → ℝ),
      (∃ i, v i ≠ 0) ∧
      (∀ i, ∑ j, T i j * v j = mu * v i) ∧
      mu ≠ htop.topEigenval) :
    ∃ gap : ℝ, 0 < gap ∧
      ∀ (mu : ℝ) (v : n → ℝ),
        (∃ i, v i ≠ 0) →
        (∀ i, ∑ j, T i j * v j = mu * v i) →
        mu ≠ htop.topEigenval →
        gap ≤ htop.topEigenval - mu := by
  -- By definition of $HasSimpleTopEigenvalue$, there exists a finite set of eigenvalues $\mu_1, \mu_2, \ldots, \mu_k$ such that $\mu_i \neq htop.topEigenval$ for all $i$.
  set S := {mu : ℝ | ∃ (v : n → ℝ), (∃ i, v i ≠ 0) ∧ (∀ i, ∑ j, T i j * v j = mu * v i) ∧ mu ≠ htop.topEigenval} with hS_def;
  -- Since $S$ is finite, it must have a maximum element.
  obtain ⟨mu_max, hmu_max⟩ : ∃ mu_max ∈ S, ∀ mu ∈ S, mu ≤ mu_max := by
    apply_rules [ Set.exists_max_image ];
    refine' Set.Finite.subset ( Set.toFinite ( Multiset.toFinset ( Polynomial.roots ( Matrix.charpoly ( Matrix.of T ) ) ) ) ) _;
    intro mu hmu
    obtain ⟨v, hv_ne_zero, hv_eigenvalue, hv_ne_top⟩ := hmu
    have h_charpoly : Polynomial.eval mu (Matrix.charpoly (Matrix.of T)) = 0 := by
      have h_charpoly : Matrix.det (Matrix.of T - Matrix.diagonal (fun _ => mu)) = 0 := by
        rw [ ← Matrix.exists_mulVec_eq_zero_iff ];
        refine' ⟨ v, _, _ ⟩ <;> simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
        simp_all +decide [ sub_mul, Matrix.diagonal ];
      rw [ Matrix.det_eq_sign_charpoly_coeff ] at h_charpoly;
      simp_all +decide [ Matrix.charpoly, Matrix.det_apply' ];
      simp_all +decide [ Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_prod, Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_one, Polynomial.coeff_zero_eq_eval_zero ];
      convert h_charpoly using 4 ; simp +decide [ Matrix.charmatrix, Matrix.diagonal ];
      split_ifs <;> simp +decide [ * ]
    exact Multiset.mem_toFinset.mpr (Polynomial.mem_roots (Matrix.charpoly_monic (Matrix.of T) |>.ne_zero) |>.mpr h_charpoly);
  -- Since $mu_max$ is the maximum element in $S$, we have $mu_max < htop.topEigenval$.
  have hmu_max_lt_top : mu_max < htop.topEigenval := by
    exact lt_of_le_of_ne ( htop.is_largest _ _ hmu_max.1.choose_spec.1 hmu_max.1.choose_spec.2.1 ) hmu_max.1.choose_spec.2.2;
  exact ⟨ htop.topEigenval - mu_max, sub_pos.mpr hmu_max_lt_top, fun mu v hv₁ hv₂ hv₃ => by linarith [ hmu_max.2 mu ⟨ v, hv₁, hv₂, hv₃ ⟩ ] ⟩

/-! ## Section 9: Concrete 2-element model -/

/-- A concrete 2-element configuration space for demonstration. -/
noncomputable def twoPointWilsonTransfer (beta : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.of (fun i j => Real.exp (beta * if i = j then 1 else -1))

/-- The 2-point Wilson transfer matrix has positive entries. -/
theorem twoPointWilsonTransfer_pos (beta : ℝ) (i j : Fin 2) :
    0 < twoPointWilsonTransfer beta i j := by
  simp only [twoPointWilsonTransfer, Matrix.of]
  exact Real.exp_pos _

/-
The 2-point Wilson transfer matrix is symmetric.
-/
theorem twoPointWilsonTransfer_symm (beta : ℝ) :
    (twoPointWilsonTransfer beta).IsSymm := by
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [ twoPointWilsonTransfer ] ;

/-! ## Section 10: Combined Architecture Theorem -/

/-- **Architecture Theorem**: For any finite configuration space with a symmetric
plaquette weight and any positive coupling, the Wilson transfer matrix is:
1. Has strictly positive entries
2. Is positivity improving
3. Has nonneg transfer matrix entries

This establishes the finite-volume doorway from reflection positivity to
spectral theory. -/
theorem wilson_transfer_architecture
    {α : Type*} [Fintype α] [Nonempty α]
    (w : α → α → ℝ) (theta : α → α) (beta : ℝ) :
    (∀ i j, 0 < wilsonTransferMatrix w theta beta i j) ∧
    IsPositivityImproving (wilsonTransferMatrix w theta beta) ∧
    (∀ i j, 0 ≤ wilsonTransferMatrix w theta beta i j) := by
  refine ⟨?_, ?_, ?_⟩
  · exact wilsonTransferMatrix_pos_entries w theta beta
  · exact wilsonTransferMatrix_positivityImproving w theta beta
  · intro i j; exact le_of_lt (wilsonTransferMatrix_pos_entries w theta beta i j)