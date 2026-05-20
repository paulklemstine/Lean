/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# SU(2) Gradient Flow: Definitions

## Overview

We formalize the optimization landscape of the normalized quantum exponential map
on SU(2) using Pauli coordinates (ℝ³) and the quaternion model (S³ ⊂ ℝ⁴).

## Mathematical Model

Every traceless Hermitian 2×2 matrix H can be uniquely written as
  H = x σ₁ + y σ₂ + z σ₃
where σᵢ are the Pauli matrices and (x, y, z) ∈ ℝ³.

The normalized quantum exponential map in these coordinates is:
  qEMLnorm(v) = (cos ‖v‖, sinc(‖v‖) · v) ∈ S³ ⊂ ℝ⁴

where sinc(r) = sin(r)/r for r > 0 and sinc(0) = 1.

An SU(2) element has positive trace iff its scalar quaternion component is positive
(i.e., cos(‖v‖) > 0, equivalently ‖v‖ < π/2).

The Frobenius loss against a target q* = (a*, b*) ∈ S³ is:
  L(v) = 4 − 4⟨qEMLnorm(v), q*⟩ₛ₃
-/

namespace SU2GradientFlow

open Real

noncomputable section

-- ============================================================================
-- Section 1: The sinc function
-- ============================================================================

/-- The cardinal sine function: `sin(x)/x` for `x ≠ 0`, extended to `sinc(0) = 1`.
This is the fundamental bridge between Pauli coordinates and the quaternion
representation of SU(2). For traceless Hermitian H with ‖H‖ = r,
exp(iH) = cos(r)·I + i·sinc(r)·H. -/
def sinc (x : ℝ) : ℝ := if x = 0 then 1 else sin x / x

@[simp] lemma sinc_zero : sinc 0 = 1 := by simp [sinc]

lemma sinc_of_ne_zero {x : ℝ} (hx : x ≠ 0) : sinc x = sin x / x := if_neg hx

/-- `sinc(x) * x = sin(x)` for all x. -/
lemma sinc_mul (x : ℝ) : sinc x * x = sin x := by
  by_cases hx : x = 0 <;> simp [sinc, hx]

/-- `x * sinc(x) = sin(x)` for all x. -/
lemma mul_sinc (x : ℝ) : x * sinc x = sin x := by rw [mul_comm, sinc_mul]

-- ============================================================================
-- Section 2: Pauli coordinate space
-- ============================================================================

/-- Pauli coordinate representation of a traceless Hermitian 2×2 matrix.
  H = x·σ₁ + y·σ₂ + z·σ₃ where σᵢ are the Pauli matrices.
  This is the Lie algebra su(2) identified with ℝ³. -/
@[ext]
structure PauliVec where
  x : ℝ
  y : ℝ
  z : ℝ


instance : Zero PauliVec := ⟨⟨0, 0, 0⟩⟩



/-- The squared Euclidean norm of a Pauli vector. -/
def PauliVec.normSq (v : PauliVec) : ℝ := v.x ^ 2 + v.y ^ 2 + v.z ^ 2

/-- The Euclidean norm of a Pauli vector. -/
def PauliVec.norm (v : PauliVec) : ℝ := Real.sqrt v.normSq

/-- The Euclidean inner product (dot product) of two Pauli vectors. -/
def PauliVec.dot (v w : PauliVec) : ℝ := v.x * w.x + v.y * w.y + v.z * w.z

/-- Scalar multiplication of a Pauli vector. -/
def PauliVec.smul (c : ℝ) (v : PauliVec) : PauliVec := ⟨c * v.x, c * v.y, c * v.z⟩

-- ============================================================================
-- Section 3: qEMLnorm in quaternion/Pauli coordinates
-- ============================================================================

/-- The scalar (identity) component of qEMLnorm(v): cos(‖v‖).
  This corresponds to the trace: tr(qEMLnorm(v)) = 2·cos(‖v‖). -/
def qScalar (v : PauliVec) : ℝ := cos v.norm

/-- The Pauli-vector component of qEMLnorm(v): sinc(‖v‖) · v.
  This is the traceless part of the SU(2) element. -/
def qVector (v : PauliVec) : PauliVec := v.smul (sinc v.norm)

-- ============================================================================
-- Section 4: Target and loss function
-- ============================================================================

/-- A target SU(2) element in quaternion representation.
  Consists of a scalar part `a` and a vector part `b` satisfying a² + ‖b‖² = 1. -/
structure SUTarget where
  a : ℝ
  b : PauliVec
  on_sphere : a ^ 2 + b.normSq = 1

/-- An SU(2) target has positive trace iff its scalar component is positive. -/
def SUTarget.hasPositiveTrace (q : SUTarget) : Prop := 0 < q.a

/-- The quaternion inner product between qEMLnorm(v) and a target.
  For unit quaternions q₁ = (a₁, b₁), q₂ = (a₂, b₂):
  ⟨q₁, q₂⟩ = a₁·a₂ + b₁·b₂ -/
def quatInner (v : PauliVec) (target : SUTarget) : ℝ :=
  qScalar v * target.a + (qVector v).dot target.b

/-- The Frobenius loss between qEMLnorm(v) and a target U* in SU(2).
  ‖qEMLnorm(v) - U*‖²_F = 4 - 4⟨qEMLnorm(v), U*⟩
  where ⟨·,·⟩ is the quaternion inner product. -/
def frobeniusLoss (target : SUTarget) (v : PauliVec) : ℝ :=
  4 - 4 * quatInner v target

-- ============================================================================
-- Section 5: Principal ball and positive trace
-- ============================================================================

/-- A Pauli vector is in the principal ball if its norm is strictly less than π.
  This is the domain on which the exponential map is a diffeomorphism. -/
def InPrincipalBall (v : PauliVec) : Prop := v.norm < π

/-- The principal logarithm domain for the positive-trace chart. -/
def PositiveTraceChartDomain : Set PauliVec := {v | InPrincipalBall v}

-- ============================================================================
-- Section 6: Critical points and gradient domination
-- ============================================================================

/-- A Pauli vector is a directional critical point of a function if the
  derivative along every direction vanishes. We define this using the
  directional derivative at rate zero. -/
def IsDirectionalCriticalPoint (f : PauliVec → ℝ) (v₀ : PauliVec) : Prop :=
  ∀ d : PauliVec, ∀ ε > 0,
    ∃ δ > 0, ∀ t : ℝ, |t| < δ →
      |f ⟨v₀.x + t * d.x, v₀.y + t * d.y, v₀.z + t * d.z⟩ - f v₀| ≤ ε * |t|

/-- Gradient domination (Polyak–Łojasiewicz type condition).
  The function value is controlled by a squared gradient-like quantity. -/
def GradientDominatedOn (f : PauliVec → ℝ)
    (s : Set PauliVec) (fmin : ℝ) (μ : ℝ) : Prop :=
  0 < μ ∧ ∀ v ∈ s, ∀ d : PauliVec, d.normSq = 1 →
    ∃ t₀ > 0, ∀ t : ℝ, |t| < t₀ →
      f v - fmin ≤ μ * ((f ⟨v.x + t * d.x, v.y + t * d.y, v.z + t * d.z⟩ - f v) / t) ^ 2

/-- Discrete gradient descent recurrence: Hₙ₊₁ = Hₙ - η · ∇f(Hₙ).
  We express this abstractly through a contraction property. -/
def IsContractionSequence (seq : ℕ → PauliVec) (target : PauliVec)
    (ρ : ℝ) : Prop :=
  0 < ρ ∧ ρ < 1 ∧ ∀ n : ℕ,
    let diff_next := ⟨(seq (n+1)).x - target.x,
                      (seq (n+1)).y - target.y,
                      (seq (n+1)).z - target.z⟩
    let diff_curr := ⟨(seq n).x - target.x,
                      (seq n).y - target.y,
                      (seq n).z - target.z⟩
    PauliVec.normSq diff_next ≤ ρ ^ 2 * PauliVec.normSq diff_curr

end

end SU2GradientFlow