/-
# Quantum-Tropical Reflective Operators and Decoherence-Stable Fixed Points

This file formalizes quantum tropical dynamics: a finite-dimensional "quantum" (entropy-regularized)
deformation of min-plus (tropical) linear algebra. The central objects are:

- `qminVec β x`: the log-sum-exp soft minimum, converging to min as β → ∞
- `qTropMap β A x`: the induced soft min-plus linear map from a weight matrix A
- `normalize0 x`: normalization by subtracting the 0-th coordinate

The main results are:
1. **Additive homogeneity** (`qTropMap_add_const`): T_{β,A}(x + c) = T_{β,A}(x) + c
2. **Tropical approximation bounds** (`qminVec_le_min`, `min_sub_le_qminVec`):
   min(x) - log(n)/β ≤ qminVec(β, x) ≤ min(x)
3. **Eigenvector existence** (`exists_qtrop_eigenvector`):
   ∃ x λ, T_{β,A}(x) = x + λ  (modulo Brouwer's fixed-point theorem)

These establish that decohered tropical reflection preserves fixed-point structure
up to additive gauge, exactly as in tropical spectral theory.
-/

import Mathlib

open Finset Real BigOperators Matrix

noncomputable section

/-! ## Core Definitions -/

/-- Quantum (soft) minimum via log-sum-exp. As β → ∞, this converges to the actual minimum.
    Physically, this is the negative free energy at inverse temperature β. -/
def qminVec {n : ℕ} (β : ℝ) (x : Fin n → ℝ) : ℝ :=
  -(1 / β) * Real.log (∑ i : Fin n, Real.exp (-β * x i))

/-- Quantum tropical map: the soft min-plus analogue of the tropical linear map
    (T_A x)(i) = min_j (A_{ij} + x_j). This is the entropy-regularized Bellman operator. -/
def qTropMap {n : ℕ} (β : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => -(1 / β) * Real.log (∑ j : Fin n, Real.exp (-β * (A i j + x j)))

/-- Normalization by subtracting the 0-th coordinate. This quotients out the
    additive gauge symmetry, projecting onto the hyperplane {x | x 0 = 0}. -/
def normalize0 {n : ℕ} [NeZero n] (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => x i - x 0

/-! ## Auxiliary Lemmas -/

/-- The sum of exponentials is always positive (for nonempty index). -/
lemma sum_exp_pos {n : ℕ} [NeZero n] (β : ℝ) (x : Fin n → ℝ) :
    0 < ∑ i : Fin n, Real.exp (-β * x i) :=
  Finset.sum_pos (fun i _ => Real.exp_pos _) Finset.univ_nonempty

/-- Pulling a constant factor out of sum of exponentials. -/
lemma sum_exp_shift {n : ℕ} (β : ℝ) (x : Fin n → ℝ) (c : ℝ) :
    (∑ i : Fin n, Real.exp (-β * (x i + c))) =
    Real.exp (-β * c) * (∑ i : Fin n, Real.exp (-β * x i)) := by
  rw [Finset.mul_sum, Finset.sum_congr rfl]; intros; rw [← Real.exp_add]; ring

/-! ## Main Algebraic Theorems -/

/-
**Additive Homogeneity of qminVec**: shifting all inputs by c shifts the output by c.
    This is the key algebraic property that makes the soft minimum compatible with
    tropical gauge symmetry.
-/
theorem qminVec_add_const {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (x : Fin n → ℝ) (c : ℝ) :
    qminVec β (fun i => x i + c) = qminVec β x + c := by
  unfold qminVec;
  rw [ show ( ∑ i : Fin n, Real.exp ( -β * ( x i + c ) ) ) = ( ∑ i : Fin n, Real.exp ( -β * x i ) ) * Real.exp ( -β * c ) by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ ← Real.exp_add ] ; ring ] ; rw [ Real.log_mul ( by exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) <| Real.exp_ne_zero _ ] ; norm_num [ Real.log_exp, hβ.ne' ] ; ring;
  rw [ mul_inv_cancel₀ hβ.ne', one_mul, neg_add_eq_sub ]

/-
**Additive Homogeneity of qTropMap**: T_{β,A}(x + c) = T_{β,A}(x) + c.
    This is the central algebraic theorem. It shows the quantum tropical operator
    preserves the additive gauge symmetry, hence descends to the projective quotient.
-/
theorem qTropMap_add_const {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (c : ℝ) :
    qTropMap β A (fun i => x i + c) = fun i => qTropMap β A x i + c := by
  ext i;
  unfold qTropMap;
  rw [ show ( ∑ j, Real.exp ( -β * ( A i j + ( fun i => x i + c ) j ) ) ) = Real.exp ( -β * c ) * ( ∑ j, Real.exp ( -β * ( A i j + x j ) ) ) by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ ← Real.exp_add ] ; ring ];
  rw [ Real.log_mul ( by positivity ) ( by exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ i, Finset.mem_univ _ ⟩ ), Real.log_exp ] ; ring;
  rw [ mul_inv_cancel₀ hβ.ne', one_mul, neg_add_eq_sub ]

/-! ## Tropical Approximation Bounds -/

/-
**Upper bound**: the soft minimum is at most the hard minimum.
-/
theorem qminVec_le_min {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β) (x : Fin n → ℝ) :
    qminVec β x ≤ Finset.univ.inf' Finset.univ_nonempty x := by
  simp +decide [ qminVec, Real.log_le_iff_le_exp ];
  intro i; rw [ ← div_eq_inv_mul ] ; rw [ neg_div', div_le_iff₀ ( by positivity ) ] ; linarith [ Real.log_exp ( - ( β * x i ) ), Real.log_le_log ( by positivity ) ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( - ( β * x a ) ) ) ( Finset.mem_univ i ) ) ] ;

/-
**Lower bound**: the soft minimum is at least min - log(n)/β.
    Together with the upper bound, this sandwiches qminVec between the hard minimum
    and its O(log n / β) relaxation.
-/
theorem min_sub_le_qminVec {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β) (x : Fin n → ℝ) :
    Finset.univ.inf' Finset.univ_nonempty x - Real.log (Fintype.card (Fin n)) / β
      ≤ qminVec β x := by
  -- Since $x_i \geq m$ for all $i$, we have $\exp(-\beta x_i) \leq \exp(-\beta m)$.
  have h_exp_le : ∀ i, Real.exp (-β * x i) ≤ Real.exp (-β * (Finset.univ.inf' Finset.univ_nonempty x)) := by
    exact fun i => Real.exp_le_exp.mpr ( mul_le_mul_of_nonpos_left ( Finset.inf'_le _ <| Finset.mem_univ _ ) <| neg_nonpos.mpr hβ.le );
  -- Summing these inequalities over all $i$, we get $\sum_{i=1}^n \exp(-\beta x_i) \leq n \exp(-\beta m)$.
  have h_sum_exp_le : ∑ i, Real.exp (-β * x i) ≤ n * Real.exp (-β * (Finset.univ.inf' Finset.univ_nonempty x)) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => h_exp_le _ ) ( by norm_num );
  unfold qminVec;
  field_simp;
  have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty ) ) ( show ∑ i, Real.exp ( - ( β * x i ) ) ≤ ( n : ℝ ) * Real.exp ( - ( β * Finset.univ.inf' Finset.univ_nonempty x ) ) by simpa using h_sum_exp_le );
  rw [ Real.log_mul ( by norm_cast; exact NeZero.ne n ) ( by positivity ), Real.log_exp ] at this ; norm_num at * ; linarith

/-! ## Normalization Properties -/

/-- The normalization map always sends the 0-th coordinate to 0. -/
theorem normalize0_zero {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    normalize0 x 0 = 0 :=
  sub_self _

/-- normalize0 is idempotent. -/
theorem normalize0_idem {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    normalize0 (normalize0 x) = normalize0 x :=
  funext fun i => by unfold normalize0; ring

/-
The normalized quantum tropical map has bounded range: each coordinate is
    bounded by the oscillation of the weight matrix rows. This is the compactness engine
    for the Brouwer fixed-point argument.
-/
theorem normalize_qTropMap_bounded {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ R : ℝ, ∀ x : Fin n → ℝ, ∀ i : Fin n,
      |normalize0 (qTropMap β A x) i| ≤ R := by
  unfold normalize0 qTropMap;
  -- By the properties of logarithms and exponentials, we can simplify the expression.
  suffices h_simp : ∃ R, ∀ x : Fin n → ℝ, ∀ i, |Real.log (∑ j, Real.exp (-β * (A i j + x j))) - Real.log (∑ j, Real.exp (-β * (A 0 j + x j)))| ≤ R by
    exact ⟨ h_simp.choose * ( 1 / β ), fun x i => abs_le.mpr ⟨ by nlinarith [ abs_le.mp ( h_simp.choose_spec x i ), show 0 < 1 / β by positivity ], by nlinarith [ abs_le.mp ( h_simp.choose_spec x i ), show 0 < 1 / β by positivity ] ⟩ ⟩;
  -- By the properties of logarithms and exponentials, we can bound the difference of the sums.
  have h_bound : ∀ x : Fin n → ℝ, ∀ i : Fin n, (∑ j : Fin n, Real.exp (-β * (A i j + x j))) ≤ (∑ j : Fin n, Real.exp (-β * (A 0 j + x j))) * (∑ j : Fin n, Real.exp (-β * (A i j - A 0 j))) := by
    intro x i;
    rw [ Finset.sum_mul _ _ _ ];
    refine Finset.sum_le_sum fun j _ => ?_;
    exact le_trans ( by rw [ ← Real.exp_add ] ; ring_nf; norm_num ) ( mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( -β * ( A i a - A 0 a ) ) ) ( Finset.mem_univ j ) ) ( Real.exp_nonneg _ ) );
  -- Similarly, we can bound the difference of the sums in the other direction.
  have h_bound_rev : ∀ x : Fin n → ℝ, ∀ i : Fin n, (∑ j : Fin n, Real.exp (-β * (A 0 j + x j))) ≤ (∑ j : Fin n, Real.exp (-β * (A i j + x j))) * (∑ j : Fin n, Real.exp (β * (A i j - A 0 j))) := by
    intros x i
    have h_bound_rev_step : ∀ j : Fin n, Real.exp (-β * (A 0 j + x j)) ≤ Real.exp (-β * (A i j + x j)) * Real.exp (β * (A i j - A 0 j)) := by
      intro j; rw [ ← Real.exp_add ] ; ring_nf; norm_num;
    exact le_trans ( Finset.sum_le_sum fun _ _ => h_bound_rev_step _ ) ( by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun j _ => Real.exp_nonneg ( β * ( A i j - A 0 j ) ) ) ( Finset.mem_univ _ ) ) ( Real.exp_nonneg _ ) );
  -- Using the bounds, we can derive the inequality for the logarithms.
  have h_log_bound : ∀ x : Fin n → ℝ, ∀ i : Fin n, Real.log (∑ j : Fin n, Real.exp (-β * (A i j + x j))) - Real.log (∑ j : Fin n, Real.exp (-β * (A 0 j + x j))) ≤ Real.log (∑ j : Fin n, Real.exp (-β * (A i j - A 0 j))) := by
    intro x i; rw [ ← Real.log_div ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] ; exact Real.log_le_log ( div_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ) ( by rw [ div_le_iff₀ ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] ; linarith [ h_bound x i ] ) ;
  have h_log_bound_rev : ∀ x : Fin n → ℝ, ∀ i : Fin n, Real.log (∑ j : Fin n, Real.exp (-β * (A 0 j + x j))) - Real.log (∑ j : Fin n, Real.exp (-β * (A i j + x j))) ≤ Real.log (∑ j : Fin n, Real.exp (β * (A i j - A 0 j))) := by
    intros x i
    have := h_bound_rev x i
    have := Real.log_le_log (by
    exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty) this
    norm_num at *;
    rw [ Real.log_mul ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] at this ; linarith;
  use ∑ i : Fin n, |Real.log (∑ j : Fin n, Real.exp (-β * (A i j - A 0 j)))| + ∑ i : Fin n, |Real.log (∑ j : Fin n, Real.exp (β * (A i j - A 0 j)))|;
  intro x i; rw [ abs_le ] ; constructor <;> linarith [ h_log_bound x i, h_log_bound_rev x i, abs_le.mp ( Finset.single_le_sum ( fun i _ => abs_nonneg ( Real.log ( ∑ j : Fin n, Real.exp ( -β * ( A i j - A 0 j ) ) ) ) ) ( Finset.mem_univ i ) ), abs_le.mp ( Finset.single_le_sum ( fun i _ => abs_nonneg ( Real.log ( ∑ j : Fin n, Real.exp ( β * ( A i j - A 0 j ) ) ) ) ) ( Finset.mem_univ i ) ) ] ;

/-
The quantum tropical operator applied coordinatewise is sandwiched between the
    hard tropical (min-plus) value and its log(n)/β relaxation.
-/
theorem qTropMap_coordwise_bounds {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin n) :
    let m := Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)
    m - Real.log (Fintype.card (Fin n)) / β ≤ qTropMap β A x i ∧
      qTropMap β A x i ≤ m := by
  convert min_sub_le_qminVec β hβ ( fun j => A i j + x j ) |> And.intro <| qminVec_le_min β hβ ( fun j => A i j + x j ) using 1

/-! ## Eigenvector Existence via Reduction to Linear Perron-Frobenius -/

/-- The entrywise exponential matrix: M_{ij} = exp(-β * A_{ij}).
    This matrix has all strictly positive entries. -/
def expMat {n : ℕ} (β : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => Real.exp (-β * A i j))

/-- **Perron-Frobenius for strictly positive matrices** (finite-dimensional).
    Any matrix with all strictly positive entries has a positive eigenvalue with
    a positive eigenvector. This is a classical theorem (Perron, 1907) not yet
    formalized in Mathlib. The proof requires either Brouwer's fixed-point theorem
    or the Collatz-Wielandt variational characterization.

    This is the sole unproved assumption in the development. All other results
    are fully machine-verified. -/
theorem perron_frobenius_pos_matrix {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) (hM : ∀ i j, 0 < M i j) :
    ∃ (μ : ℝ) (u : Fin n → ℝ), 0 < μ ∧ (∀ i, 0 < u i) ∧
      ∀ i, ∑ j, M i j * u j = μ * u i := by
  sorry

/-
The expMat has all strictly positive entries.
-/
lemma expMat_pos {n : ℕ} (β : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    0 < expMat β A i j := by
  exact Real.exp_pos _

/-
**Eigenvector Existence**: For every nonempty finite dimension and every β > 0,
    the quantum tropical operator T_{β,A} admits a nonlinear eigenvector:
    there exist x and eigval such that T_{β,A}(x) = x + eigval.

    This is the quantum-tropical analogue of the Perron-Frobenius theorem.
    It says the decohered tropical reflection has a self-consistent state
    modulo additive gauge.

    The proof reduces to the Perron-Frobenius theorem for the entrywise-exponentiated
    matrix M_{ij} = exp(-β * A_{ij}). The eigenvector equation T(x) = x + λ is
    equivalent, after the substitution u_j = exp(-β * x_j) and μ = exp(-βλ),
    to the linear eigenvalue equation Mu = μu.
-/
theorem exists_qtrop_eigenvector {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (x : Fin n → ℝ) (eigval : ℝ), qTropMap β A x = fun i => x i + eigval := by
  -- By the Perron-Frobenius theorem, there exists a positive eigenvalue μ and a corresponding positive eigenvector u for the matrix M.
  obtain ⟨μ, u, hμ_pos, hu_pos, h_eigen⟩ : ∃ (μ : ℝ) (u : Fin n → ℝ), 0 < μ ∧ (∀ i, 0 < u i) ∧ ∀ i, ∑ j, Real.exp (-β * A i j) * u j = μ * u i := by
    exact perron_frobenius_pos_matrix _ fun i j => Real.exp_pos _;
  refine' ⟨ fun i => - ( 1 / β ) * Real.log ( u i ), - ( 1 / β ) * Real.log ( μ ), _ ⟩;
  ext i; simp +decide [ qTropMap ] ; ring;
  simp_all +decide [ sub_eq_add_neg, Real.exp_add, Real.exp_neg, Real.exp_log, ne_of_gt, mul_assoc, mul_comm β ];
  simp_all +decide [ mul_comm, ← mul_assoc, ← Finset.sum_mul _ _ _ ];
  rw [ Real.log_mul ( ne_of_gt hμ_pos ) ( ne_of_gt ( hu_pos i ) ) ] ; ring

/-
Equivalent formulation: the normalized map has a fixed point.
    Follows from eigenvector existence via additive homogeneity.
-/
theorem exists_normalized_qtrop_fixed_point {n : ℕ} [NeZero n] (β : ℝ) (hβ : 0 < β)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ x : Fin n → ℝ, normalize0 (qTropMap β A x) = x := by
  obtain ⟨x₀, eigval, h_eigval⟩ := exists_qtrop_eigenvector β hβ A
  -- Define x as the normalized vector of x₀.
  use fun i => x₀ i - x₀ 0;
  -- By added homogeneity, we have qTropMap β A (x₀ + (-x₀ 0)) = fun i => qTropMap β A x₀ i + (-x₀ 0).
  have h_homogeneous : qTropMap β A (fun i => x₀ i - x₀ 0) = fun i => qTropMap β A x₀ i + (-x₀ 0) := by
    convert qTropMap_add_const β hβ A x₀ ( -x₀ 0 ) using 1;
  ext i; simp +decide [ *, normalize0 ] ;
  ring

/-! ## Negative Result -/

/-
**No literal fixed point in general**: additive homogeneity forbids T_{β,A}(x) = x
    unless the eigenvalue λ happens to be 0. This negative result sharpens the theory:
    the correct invariant notion is projective/eigenvector, not literal fixed point.
-/
theorem no_literal_fixed_point_example :
    ∃ (A : Matrix (Fin 1) (Fin 1) ℝ) (β : ℝ), 0 < β ∧
      ¬∃ x : Fin 1 → ℝ, qTropMap β A x = x := by
  -- Let's choose A and β such that T_{β, A}(x) ≠ x for all x.
  use !![1], 1;
  unfold qTropMap;
  norm_num [ funext_iff, Fin.forall_fin_one ]

end