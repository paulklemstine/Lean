/-
Copyright (c) 2025 Categorical Neural Architecture Theory. All rights reserved.
Released under Apache 2.0 license.

# Attention as a Natural Transformation

This file proves that linear attention mechanisms satisfy the naturality condition
from category theory. Specifically, scalar attention (attention weights proportional
to identity) commutes with all linear maps, making it a natural endomorphism of the
identity functor on the category of finite-dimensional vector spaces.

## Main results

* `scalar_attention_natural_component` — scalar attention commutes with linear maps
* `scalar_attention_natural_matrix` — matrix form of naturality
* `attention_natural_iff_scalar` — attention is natural iff it is scalar (Schur's lemma)
* `attention_composed_natural` — composition of natural attentions is natural
-/

import Mathlib

open Matrix BigOperators

variable {n m : ℕ}

/-! ## Linear Attention Operators -/

/-- Apply a linear attention operator (given as a matrix) to a state vector. -/
def attApply (W : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ := W.mulVec x

/-- Scalar attention: attention weight is a scalar multiple of identity.
    This models uniform attention where every position receives equal weight `c`. -/
def scalarAttention (n : ℕ) (c : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  c • (1 : Matrix (Fin n) (Fin n) ℝ)

/-- The action of a linear map on state vectors (functor action on morphisms). -/
def linearAction (φ : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) : Fin m → ℝ :=
  φ.mulVec x

/-! ## Naturality Theorems -/

/-
**Theorem 2a (Scalar Attention Naturality — Component Form).**
    For any linear map φ and scalar attention weight c,
    applying φ after attention equals applying attention after φ.
    This is the naturality square: `φ ∘ att_n = att_m ∘ φ`.
-/
theorem scalar_attention_natural_component
    (c : ℝ) (φ : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    linearAction φ (attApply (scalarAttention n c) x) =
    attApply (scalarAttention m c) (linearAction φ x) := by
  unfold linearAction attApply scalarAttention;
  simp +decide [ Matrix.one_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
**Theorem 2b (Scalar Attention Naturality — Matrix Form).**
    φ * (c • I) = (c • I) * φ as square matrices.
-/
theorem scalar_attention_natural_matrix
    (c : ℝ) (φ : Matrix (Fin n) (Fin n) ℝ) :
    φ * scalarAttention n c = scalarAttention n c * φ := by
  unfold scalarAttention;
  simp +decide [ mul_smul_comm, smul_mul_assoc ]

/-
**Theorem 2c (Natural Attention Characterization).**
    An attention operator commutes with ALL endomorphisms
    if and only if it is a scalar multiple of identity.
    This is the Schur lemma for the matrix algebra.
-/
theorem attention_natural_iff_scalar (W : Matrix (Fin n) (Fin n) ℝ) :
    (∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * W = W * φ) ↔
    ∃ c : ℝ, W = c • (1 : Matrix (Fin n) (Fin n) ℝ) := by
  refine' ⟨ fun hW => _, fun ⟨ c, hc ⟩ φ => by simp +decide [ hc, mul_smul_comm, smul_mul_assoc ] ⟩;
  -- By definition of matrix multiplication and the fact that W commutes with all matrices, we can show that W must be a scalar multiple of the identity matrix.
  have hW_diag : ∀ i j : Fin n, i ≠ j → W i j = 0 := by
    intro i j hij; specialize hW ( Matrix.diagonal ( fun k => if k = i then 1 else 0 ) ) ; replace hW := congr_fun ( congr_fun hW i ) j ; aesop;
  have hW_diag : ∀ i j : Fin n, W i i = W j j := by
    intro i j; specialize hW ( Matrix.single i j 1 ) ; replace hW := congr_fun ( congr_fun hW i ) j ; aesop;
  rcases n with ( _ | n ) <;> simp_all +decide [ ← Matrix.ext_iff ];
  exact ⟨ W 0 0, fun i j => by by_cases hi : i = j <;> simpa [ *, Matrix.one_apply ] using hW_diag i 0 ⟩

/-
**Theorem 2d (Composed Natural Attentions).**
    If two operators both commute with all morphisms, their product does too.
    Natural transformations form a monoid.
-/
theorem attention_composed_natural
    (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ)
    (h₁ : ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * W₁ = W₁ * φ)
    (h₂ : ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * W₂ = W₂ * φ) :
    ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * (W₁ * W₂) = (W₁ * W₂) * φ := by
  exact fun φ => by rw [ ← Matrix.mul_assoc, h₁, Matrix.mul_assoc, h₂, ← Matrix.mul_assoc ] ;

/-
Natural attention operators form a subalgebra (closed under addition).
-/
theorem attention_sum_natural
    (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ)
    (h₁ : ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * W₁ = W₁ * φ)
    (h₂ : ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * W₂ = W₂ * φ) :
    ∀ φ : Matrix (Fin n) (Fin n) ℝ, φ * (W₁ + W₂) = (W₁ + W₂) * φ := by
  simp_all +decide [ mul_add, add_mul ]

/-
Scalar attention applied to a vector scales it uniformly.
-/
theorem scalarAttention_apply (c : ℝ) (x : Fin n → ℝ) :
    attApply (scalarAttention n c) x = c • x := by
  -- By definition of scalar attention, we have `scalarAttention n c = c • (1 : Matrix (Fin n) (Fin n) ℝ)`.
  unfold attApply scalarAttention;
  simp +decide [ funext_iff, Matrix.mulVec, dotProduct ];
  simp +decide [ Matrix.one_apply, mul_assoc, Finset.mul_sum _ _ _, mul_comm ]

/-
Scalar attention at c=1 is the identity matrix.
-/
theorem scalarAttention_one : scalarAttention n 1 = (1 : Matrix (Fin n) (Fin n) ℝ) := by
  exact one_smul ℝ _

/-
Scalar attention at c=0 is the zero matrix.
-/
theorem scalarAttention_zero : scalarAttention n 0 = (0 : Matrix (Fin n) (Fin n) ℝ) := by
  exact Matrix.ext fun i j => by simp +decide [ scalarAttention ] ;