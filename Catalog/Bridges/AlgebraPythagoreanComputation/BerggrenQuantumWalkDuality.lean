import Mathlib

/-!
# Berggren Quantum Walk Duality: Core Definitions and Kernel Properties

## Overview

This module establishes the foundational theory of quantum walks on the Berggren
triple tree. We define the Berggren generators, quantum walks on finite-dimensional
complex Hilbert spaces, and prove core properties of the amplitude kernel.

## Main Results

- `BerggrenQuantumWalk.evalWord_mul`: Word evaluation is multiplicative
- `berggren_kernel_hermitian`: The amplitude kernel is Hermitian
- `berggren_kernel_diagonal_nonneg`: Kernel diagonal is non-negative
- `berggren_kernel_shift_invariant`: Unitary generators preserve the kernel
-/

noncomputable section

open Matrix Complex Finset BigOperators

/-! ## Section 1: Berggren Generators and Words -/

/-- The three Berggren generators for the primitive Pythagorean triple tree. -/
inductive BerggrenGen : Type
  | A | B | C
  deriving DecidableEq, Fintype, Inhabited

/-- Words in the Berggren generators, forming the free monoid. -/
abbrev BerggrenWord := FreeMonoid BerggrenGen

/-! ## Section 2: Berggren Quantum Walk -/

/-- A Berggren quantum walk of dimension `n` over ℂⁿ. -/
structure BerggrenQuantumWalk (n : ℕ) where
  /-- Unitary operator assigned to each Berggren generator -/
  U : BerggrenGen → Matrix (Fin n) (Fin n) ℂ
  /-- Left unitarity: U†U = I -/
  hU_star_mul : ∀ g, (U g)ᴴ * (U g) = 1
  /-- Right unitarity: UU† = I -/
  hU_mul_star : ∀ g, (U g) * (U g)ᴴ = 1
  /-- Initial state vector -/
  psi0 : Fin n → ℂ
  /-- Observation vector -/
  obs : Fin n → ℂ

variable {n : ℕ}

/-- Extend the generator action to words via the free monoid. -/
def BerggrenQuantumWalk.evalWord (Q : BerggrenQuantumWalk n) :
    BerggrenWord →* Matrix (Fin n) (Fin n) ℂ :=
  FreeMonoid.lift Q.U

/-- Evaluate a word on the initial state: U(w) · ψ₀ -/
def BerggrenQuantumWalk.evalState (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    Fin n → ℂ :=
  (Q.evalWord w).mulVec Q.psi0

/-- The amplitude kernel: K(u,v) = ⟨U(u)ψ₀, U(v)ψ₀⟩ -/
def BerggrenQuantumWalk.kernel (Q : BerggrenQuantumWalk n) (u v : BerggrenWord) : ℂ :=
  dotProduct (star (Q.evalState u)) (Q.evalState v)

/-- The amplitude function: amp(w) = ⟨obs, U(w)ψ₀⟩ -/
def BerggrenQuantumWalk.amplitude (Q : BerggrenQuantumWalk n) (w : BerggrenWord) : ℂ :=
  dotProduct (star Q.obs) (Q.evalState w)

/-- evalWord is multiplicative. -/
theorem BerggrenQuantumWalk.evalWord_mul (Q : BerggrenQuantumWalk n)
    (w₁ w₂ : BerggrenWord) :
    Q.evalWord (w₁ * w₂) = Q.evalWord w₁ * Q.evalWord w₂ :=
  map_mul Q.evalWord w₁ w₂

/-- evalWord at a single generator gives the generator matrix. -/
theorem BerggrenQuantumWalk.evalWord_of (Q : BerggrenQuantumWalk n) (g : BerggrenGen) :
    Q.evalWord (FreeMonoid.of g) = Q.U g :=
  FreeMonoid.lift_eval_of Q.U g

/-- evalWord at the empty word gives the identity matrix. -/
@[simp]
theorem BerggrenQuantumWalk.evalWord_one (Q : BerggrenQuantumWalk n) :
    Q.evalWord 1 = 1 :=
  map_one Q.evalWord

/-! ## Section 3: Kernel Properties -/

/-
Hermitian symmetry: K(u,v) = conj(K(v,u)).
-/
theorem berggren_kernel_hermitian (Q : BerggrenQuantumWalk n) (u v : BerggrenWord) :
    Q.kernel u v = starRingEnd ℂ (Q.kernel v u) := by
      unfold BerggrenQuantumWalk.kernel; simp +decide [ dotProduct, Finset.mul_sum ] ;
      grind

/-
Non-negativity of the kernel diagonal: K(w,w) ≥ 0.
-/
theorem berggren_kernel_diagonal_nonneg (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    0 ≤ (Q.kernel w w).re := by
      -- Unfold the definition of K.
      rw [BerggrenQuantumWalk.kernel];
      norm_num [ dotProduct ];
      exact Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ )

/-
The kernel diagonal is real.
-/
theorem berggren_kernel_diagonal_real (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    (Q.kernel w w).im = 0 := by
      have := berggren_kernel_hermitian Q w w; norm_num [ Complex.ext_iff ] at *; linarith;

/-- State evaluation is compatible with word concatenation. -/
theorem BerggrenQuantumWalk.evalState_mul (Q : BerggrenQuantumWalk n)
    (w₁ w₂ : BerggrenWord) :
    Q.evalState (w₁ * w₂) = (Q.evalWord w₁).mulVec (Q.evalState w₂) := by
  simp only [BerggrenQuantumWalk.evalState, Q.evalWord_mul]
  rw [Matrix.mulVec_mulVec]

/-- Amplitude decomposes over word concatenation. -/
theorem BerggrenQuantumWalk.amplitude_mul (Q : BerggrenQuantumWalk n)
    (w₁ w₂ : BerggrenWord) :
    Q.amplitude (w₁ * w₂) = dotProduct (star Q.obs) ((Q.evalWord w₁).mulVec (Q.evalState w₂)) := by
  simp [BerggrenQuantumWalk.amplitude, Q.evalState_mul]

/-
Unitary shift invariance: K(g·u, g·v) = K(u,v).
-/
theorem berggren_kernel_shift_invariant (Q : BerggrenQuantumWalk n)
    (g : BerggrenGen) (u v : BerggrenWord) :
    Q.kernel (FreeMonoid.of g * u) (FreeMonoid.of g * v) = Q.kernel u v := by
      unfold BerggrenQuantumWalk.kernel;
      -- By definition of matrix multiplication and the properties of the dot product, we can rewrite the left-hand side.
      suffices h_suff : ∀ (x y : Fin n → ℂ), star (Matrix.mulVec (Q.U g) x) ⬝ᵥ Matrix.mulVec (Q.U g) y = star x ⬝ᵥ y by
        convert h_suff _ _ using 2 <;> simp +decide [ BerggrenQuantumWalk.evalState, BerggrenQuantumWalk.evalWord ];
      intro x y;
      have h_unitary : (Q.U g)ᴴ * (Q.U g) = 1 := by
        exact Q.hU_star_mul g;
      convert congr_arg ( fun m => star x ⬝ᵥ m *ᵥ y ) h_unitary using 1;
      · simp +decide [ Matrix.mulVec, dotProduct ];
        simp +decide [ Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
        exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm );
      · norm_num

end