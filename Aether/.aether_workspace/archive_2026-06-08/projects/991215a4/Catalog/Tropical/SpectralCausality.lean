/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Spectral Causality: Eigenpairs as Invariant Causal Directions

This file establishes a bridge between tropical spectral theory and causal/order
structures on state space. The central insight is:

> A tropical eigenvector is not merely a fixed projective direction; it is a
> **causal geodesic ray** for min-plus dynamics. The eigenvalue controls the
> exact displacement budget of that ray under matrix action.

## Main Results

### Algebraic foundations
- `tropMatVecMul_const_add` — Scalar-shift equivariance: `A ⊗ (v + t·1) = (A ⊗ v) + t·1`
- `tropMatVecMul_eigenvector_shift` — Eigenpair unfolding: `A ⊗ v = v + d·1`

### Displacement lemmas
- `tropicalSupDisplacement_const_shift` — `d∞(v, v + t·1) = |t|`
- `tropicalOneSidedDisplacement_const_shift` — `d⁺(v, v + t·1) = t`

### Spectral causality theorems
- `eigenvector_causal_invariance` — The eigen-ray is causally invariant under A
- `eigenpair_preserves_future_param` — Eigenpairs with d ≤ 0 preserve futures

### Iterate theory
- `eigenray_iterate_drift` — `A^k ⊗ v = v + k·d`
- `eigenray_iterates_are_causal` — All iterates preserve causal structure on the eigen-ray

## Mathematical Significance

In ordinary spectral theory, eigenvectors define invariant lines.
In tropical spectral causality, eigenvectors define **invariant futures**.
This reframes tropical Perron–Frobenius theory as a dynamical causality theory,
opening interfaces to discrete event systems, min-plus control, scheduling,
and idempotent analysis.
-/

noncomputable section

open Finset

/-! ## §0. Self-contained definitions (from MinPlusAlgebra and TropicalCausality) -/

/-- The **tropical matrix-vector product**: `(A ⊗ v)(i) = min_k (A(i,k) + v(k))`. -/
def tropMatVecMul' {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty fun k => A i k + v k

/-- A **tropical eigenpair** `(d, v)` of matrix `A` satisfies `A ⊗ v = v + d·1`. -/
def IsTropicalEigenpair' {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (d : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMatVecMul' A v i = v i + d

/-- Budgeted causal relation: `τ x y ≤ T`. -/
def TropicalCausal' {α : Type*} (τ : α → α → ℝ) (T : ℝ) (x y : α) : Prop :=
  τ x y ≤ T

/-- Zero-budget future relation: `τ x y ≤ 0`. -/
def TropicalFuture' {α : Type*} (τ : α → α → ℝ) (x y : α) : Prop :=
  τ x y ≤ 0

/-- The **sup-norm tropical displacement**: `max_i |x(i) - y(i)|`. -/
def tropicalSupDisplacement' {n : ℕ} [NeZero n] (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |x i - y i|)

/-- **One-sided tropical displacement**: `max_i (y(i) - x(i))`. -/
def tropicalOneSidedDisplacement' {n : ℕ} [NeZero n] (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => y i - x i)

/-! ## §1. Scalar-Shift Equivariance -/

/-
**Scalar-shift equivariance**: `A ⊗ (v + t·1) = (A ⊗ v) + t·1`.
-/
theorem tropMatVecMul_const_add'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (t : ℝ) :
    tropMatVecMul' A (fun i => x i + t) = fun i => tropMatVecMul' A x i + t := by
  funext i;
  refine' le_antisymm _ _ <;> simp_all +decide [ tropMatVecMul' ];
  · exact Exists.elim ( Finset.exists_mem_eq_inf' Finset.univ_nonempty fun k => A i k + x k ) fun k hk => ⟨ k, by linarith ⟩;
  · exact fun k => by linarith [ Finset.inf'_le ( fun k => A i k + x k ) ( Finset.mem_univ k ) ] ;

/-! ## §2. Eigenpair Unfolding -/

/-
**Eigenpair unfolding**: `A ⊗ v = v + d·1` as a function equality.
-/
theorem tropMatVecMul_eigenvector_shift'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    tropMatVecMul' A v = fun i => v i + d := by
  exact funext heig

/-- Image of the full eigen-ray: `A ⊗ (v + t) = v + (d + t)`. -/
theorem tropMatVecMul_eigenray'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d t : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    tropMatVecMul' A (fun i => v i + t) = fun i => v i + (d + t) := by
  rw [tropMatVecMul_const_add', tropMatVecMul_eigenvector_shift' A d v heig]
  ext i; ring

/-! ## §3. Displacement Lemmas -/

/-
**Sup-displacement of a constant shift**: `d∞(v, v + t·1) = |t|`.
-/
theorem tropicalSupDisplacement_const_shift'
    {n : ℕ} [NeZero n] (v : Fin n → ℝ) (t : ℝ) :
    tropicalSupDisplacement' v (fun i => v i + t) = |t| := by
  unfold tropicalSupDisplacement';
  norm_num [ sub_eq_iff_eq_add ]

/-
**One-sided displacement of a constant shift**: `d⁺(v, v + t·1) = t`.
-/
theorem tropicalOneSidedDisplacement_const_shift'
    {n : ℕ} [NeZero n] (v : Fin n → ℝ) (t : ℝ) :
    tropicalOneSidedDisplacement' v (fun i => v i + t) = t := by
  unfold tropicalOneSidedDisplacement';
  simp +zetaDelta at *

/-! ## §4. Displacement Covariance Along the Eigen-Ray -/

/-- **Shift covariance law**: displacement is preserved by matrix action along the eigen-ray. -/
theorem tropicalSupDisplacement_eigen_ray_exact'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d t : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    tropicalSupDisplacement'
      (tropMatVecMul' A v)
      (tropMatVecMul' A (fun i => v i + t))
    =
    tropicalSupDisplacement' v (fun i => v i + t) := by
  rw [tropMatVecMul_eigenvector_shift' A d v heig]
  rw [tropMatVecMul_const_add', tropMatVecMul_eigenvector_shift' A d v heig]
  simp only [tropicalSupDisplacement']
  congr 1; ext i; ring_nf

/-- The sup-displacement along the eigen-ray equals `|t|`. -/
theorem tropicalSupDisplacement_eigen_ray_value'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d t : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    tropicalSupDisplacement'
      (tropMatVecMul' A v)
      (tropMatVecMul' A (fun i => v i + t))
    = |t| := by
  rw [tropicalSupDisplacement_eigen_ray_exact' A d t v heig]
  exact tropicalSupDisplacement_const_shift' v t

/-! ## §5. Causal Invariance -/

/-- **One-step causal invariance**: the eigen-ray is causally preserved by `A`. -/
theorem eigenvector_causal_invariance'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    ∀ t : ℝ, 0 ≤ t →
      TropicalCausal'
        (fun x y =>
          tropicalSupDisplacement' (tropMatVecMul' A x) (tropMatVecMul' A y))
        t
        (fun i => v i)
        (fun i => v i + t) := by
  intro t ht
  show tropicalSupDisplacement' (tropMatVecMul' A (fun i => v i)) (tropMatVecMul' A (fun i => v i + t)) ≤ t
  have heta : (fun i => v i) = v := funext fun _ => rfl
  rw [heta, tropicalSupDisplacement_eigen_ray_value' A d t v heig]
  exact le_of_eq (abs_of_nonneg ht)

/-! ## §6. Future Preservation -/

/-- **One-sided displacement covariance**: preserved by matrix action along eigen-ray. -/
theorem tropicalOneSidedDisplacement_eigen_ray'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d t : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    tropicalOneSidedDisplacement'
      (tropMatVecMul' A v)
      (tropMatVecMul' A (fun i => v i + t))
    = t := by
  rw [tropMatVecMul_eigenvector_shift' A d v heig]
  rw [tropMatVecMul_const_add', tropMatVecMul_eigenvector_shift' A d v heig]
  show Finset.univ.sup' Finset.univ_nonempty (fun i => (v i + d + t) - (v i + d)) = t
  simp [show ∀ i : Fin n, v i + d + t - (v i + d) = t by intro i; ring]

/-- **Eigenvector enters its own future**: when `d ≤ 0`, `A ⊗ v` lies in
the one-sided tropical future of `v`. -/
theorem eigenpair_future_step'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v)
    (hd : d ≤ 0) :
    TropicalFuture' tropicalOneSidedDisplacement' v (tropMatVecMul' A v) := by
  unfold TropicalFuture'
  rw [tropMatVecMul_eigenvector_shift' A d v heig]
  rw [tropicalOneSidedDisplacement_const_shift']
  exact hd

/-- **Future preservation along the eigen-ray**: if `d ≤ 0`, every point on
the eigen-ray is mapped into its own future by `A`. -/
theorem eigenpair_preserves_future_param'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v)
    (hd : d ≤ 0) :
    ∀ t : ℝ,
      TropicalFuture' tropicalOneSidedDisplacement'
        (fun i => v i + t)
        (tropMatVecMul' A (fun i => v i + t)) := by
  intro t
  unfold TropicalFuture'
  rw [tropMatVecMul_eigenray' A d t v heig]
  have : (fun i => v i + (d + t)) = (fun i => (v i + t) + d) := by ext i; ring
  rw [this, tropicalOneSidedDisplacement_const_shift']
  exact hd

/-! ## §7. Tropical Matrix Power and Iterate Drift -/

/-- **Tropical matrix power action on vectors**. -/
def tropMatPowMul' {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → (Fin n → ℝ) → (Fin n → ℝ)
  | 0 => id
  | k + 1 => fun v => tropMatVecMul' A (tropMatPowMul' A k v)

@[simp] theorem tropMatPowMul_zero' {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    tropMatPowMul' A 0 v = v := rfl

@[simp] theorem tropMatPowMul_succ' {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (v : Fin n → ℝ) :
    tropMatPowMul' A (k + 1) v = tropMatVecMul' A (tropMatPowMul' A k v) := rfl

/-
**Scalar-shift equivariance for iterates**.
-/
theorem tropMatPowMul_const_add'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (t : ℝ) :
    ∀ k : ℕ, tropMatPowMul' A k (fun i => x i + t) = fun i => tropMatPowMul' A k x i + t := by
  intro k;
  induction' k with k ih;
  · rfl;
  · convert tropMatVecMul_const_add' A _ t using 1;
    exact ih ▸ rfl

/-
**Eigen-ray iterate drift**: `A^⊗k ⊗ v = v + k·d`.
-/
theorem eigenray_iterate_drift'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    ∀ k : ℕ,
      tropMatPowMul' A k v = fun i => v i + (k : ℝ) * d := by
  intro k;
  induction' k with k ih;
  · aesop;
  · convert tropMatVecMul_const_add' A v ( k * d ) using 1;
    · exact ih ▸ rfl;
    · exact funext fun i => by rw [ heig i ] ; push_cast; ring;

/-
**Sup-displacement preserved through all iterates along the eigen-ray**.
-/
theorem tropicalSupDisplacement_iterate_eigen_ray'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    ∀ k : ℕ, ∀ t : ℝ,
      tropicalSupDisplacement'
        (tropMatPowMul' A k v)
        (tropMatPowMul' A k (fun i => v i + t))
      = |t| := by
  intros k t;
  have h_eigenray_iterate_drift : tropMatPowMul' A k v = fun i => v i + k * d := by
    exact eigenray_iterate_drift' A d v heig k;
  convert tropicalSupDisplacement_const_shift' ( fun i => v i + k * d ) t using 1;
  rw [ h_eigenray_iterate_drift, tropMatPowMul_const_add' ];
  rw [ h_eigenray_iterate_drift ]

/-- **All iterates preserve causal structure on the eigen-ray**. -/
theorem eigenray_iterates_are_causal'
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair' A d v) :
    ∀ k : ℕ, ∀ t : ℝ, 0 ≤ t →
      TropicalCausal'
        (fun x y =>
          tropicalSupDisplacement'
            (tropMatPowMul' A k x)
            (tropMatPowMul' A k y))
        t
        (fun i => v i)
        (fun i => v i + t) := by
  intro k t ht
  show tropicalSupDisplacement' (tropMatPowMul' A k (fun i => v i)) (tropMatPowMul' A k (fun i => v i + t)) ≤ t
  have heta : (fun i => v i) = v := funext fun _ => rfl
  rw [heta, tropicalSupDisplacement_iterate_eigen_ray' A d v heig k t]
  exact le_of_eq (abs_of_nonneg ht)

end