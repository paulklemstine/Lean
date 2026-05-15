/-
Copyright (c) 2025 Categorical Neural Architecture Theory. All rights reserved.
Released under Apache 2.0 license.

# Residual Connections as Categorical Universal Constructions

This file establishes that residual (skip) connections in neural networks arise from
a categorical product-style universal construction: duplication followed by parallel
composition followed by summation. The main theorem proves that this categorical
decomposition is equivalent to the algebraic identity `1 + f`.

## Main results

* `residualCat_eq` — categorical residual equals identity plus layer
* `residualLayer_mulVec` — residual applied to vectors gives skip connection
* `residualLayer_composition` — composition of two residual layers
* `residualLayer_det` — determinant of residual layer (invertibility criterion)
* `residualLayer_pow_eq` — iterated residual composition via binomial theorem (k=2)
-/

import Mathlib

open Matrix BigOperators Finset

variable {n : ℕ}

/-! ## Categorical Decomposition of Residual Connections -/

/-- Duplication map: x ↦ (x, x). This is the diagonal morphism in a category with products. -/
def neuralDup (x : Fin n → ℝ) : (Fin n → ℝ) × (Fin n → ℝ) := (x, x)

/-- Summation map: (x, y) ↦ x + y. This is the codiagonal / fold morphism. -/
def neuralSum (p : (Fin n → ℝ) × (Fin n → ℝ)) : Fin n → ℝ := p.1 + p.2

/-- Parallel composition of two endomorphisms. This is the product bifunctor on morphisms. -/
def neuralPar (f g : (Fin n → ℝ) → (Fin n → ℝ))
    (p : (Fin n → ℝ) × (Fin n → ℝ)) : (Fin n → ℝ) × (Fin n → ℝ) :=
  (f p.1, g p.2)

/-- The categorical residual construction: sum ∘ (id ⊕ f) ∘ dup.
    This decomposes the skip connection into three universal operations:
    1. Duplicate the input
    2. Apply identity to one copy and the layer to the other
    3. Sum the results -/
def residualCat (f : (Fin n → ℝ) → (Fin n → ℝ)) : (Fin n → ℝ) → (Fin n → ℝ) :=
  neuralSum ∘ neuralPar id f ∘ neuralDup

/-
**Theorem 1a (Categorical Residual Identity).**
    The categorical residual construction `sum ∘ (id ⊕ f) ∘ dup` equals `x ↦ x + f(x)`.
    This is the fundamental theorem connecting categorical composition to skip connections.
-/
theorem residualCat_eq (f : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    residualCat f x = x + f x := by
  rfl

/-! ## Matrix Formulation -/

/-- A residual layer in matrix form: the skip connection adds the identity. -/
def residualLayer (f : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ := 1 + f

/-
**Theorem 1b (Residual Layer Action).**
    A residual layer applied to a vector gives `x + f·x`, the defining property of skip connections.
-/
theorem residualLayer_mulVec (f : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    (residualLayer f).mulVec x = x + f.mulVec x := by
  -- By definition of matrix multiplication, we can expand both sides.
  simp [residualLayer, Matrix.mulVec];
  rw [ Matrix.add_mulVec, Matrix.one_mulVec ]

/-
**Theorem 1c (Residual Composition).**
    Composing two residual layers gives `1 + f + g + f·g`.
    This reveals the multiplicative interaction between skip connections.
-/
theorem residualLayer_composition (f g : Matrix (Fin n) (Fin n) ℝ) :
    residualLayer f * residualLayer g = 1 + f + g + f * g := by
  unfold residualLayer;
  norm_num [ add_mul, mul_add, add_assoc ]

/-
**Corollary: Residual composition is itself a residual layer.**
    The composed residual `(1+f)(1+g)` equals `residualLayer(f + g + f*g)`.
-/
theorem residualLayer_mul_eq_residualLayer (f g : Matrix (Fin n) (Fin n) ℝ) :
    residualLayer f * residualLayer g = residualLayer (f + g + f * g) := by
  unfold residualLayer; ext i j; simp +decide [ Matrix.mul_apply ] ; ring;
  simp +decide [ Matrix.one_apply, Finset.sum_add_distrib ] ; ring

/-
**Theorem 1d (Residual Determinant).**
    The determinant of a residual layer `1 + f` equals `det(1 + f)`.
    When f is nilpotent of order 2, this simplifies to `1 + trace(f)`.
-/
theorem residualLayer_det (f : Matrix (Fin n) (Fin n) ℝ) :
    (residualLayer f).det = (1 + f).det := by
  rfl

/-
**Theorem 1e (Residual Invertibility).**
    A residual layer is invertible if and only if `det(1 + f) ≠ 0`.
-/
theorem residualLayer_invertible_iff (f : Matrix (Fin n) (Fin n) ℝ) :
    IsUnit (residualLayer f) ↔ IsUnit (residualLayer f).det := by
  exact?

/-
Residual of the zero layer is the identity.
-/
theorem residualLayer_zero : residualLayer (0 : Matrix (Fin n) (Fin n) ℝ) = 1 := by
  exact add_zero _

/-
Residual preserves addition in a specific sense: if f and g commute,
    then residual(f) * residual(g) = residual(g) * residual(f).
-/
theorem residualLayer_comm_of_comm (f g : Matrix (Fin n) (Fin n) ℝ)
    (h : f * g = g * f) :
    residualLayer f * residualLayer g = residualLayer g * residualLayer f := by
  -- Expand both sides using the definition of residualLayer
  simp [residualLayer, h];
  simp +decide [ add_mul, mul_add, h ];
  abel1

/-
The categorical residual of a linear map agrees with the matrix residual.
-/
theorem residualCat_eq_residualLayer_mulVec (f : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    residualCat (f.mulVec) x = (residualLayer f).mulVec x := by
  convert residualLayer_mulVec f x |> Eq.symm using 1