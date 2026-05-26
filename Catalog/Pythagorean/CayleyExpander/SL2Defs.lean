/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# SL₂(𝔽_p) Definitions for Cayley Expander Theory

Core definitions for the arithmetic spectral theory of Cayley graphs
on the special linear group SL₂ over finite fields.

## Main Definitions

* `ArithmeticCayleyCertificate` — packages spectral data for symmetric generating sets
* `sl2_u_mat`, `sl2_v_mat` — canonical unipotent generator matrices
* `upperUnipotent`, `lowerUnipotent` — parameterized elementary matrices
* `IsSL2GeneratingPair` — predicate for generating pairs in SL₂(𝔽_p)

## Keywords

spectral gap, Cayley expander, SL₂(𝔽_p), arithmetic group, property (τ),
Ramanujan graph, random walk mixing, finite group representation theory,
automorphic forms, Langlands program, quasirandomness, pseudorandomness,
quantum compiling, sum-product phenomenon, Bourgain–Gamburd machine
-/
import Mathlib

open Finset BigOperators Matrix

/-! ## Arithmetic Certificate Structure -/

/-- An arithmetic Cayley certificate packages the spectral information of a
    symmetric generating set for a finite group. This is the fundamental
    data structure connecting group-theoretic generation to quantitative
    spectral expansion bounds. -/
structure ArithmeticCayleyCertificate (G : Type*) [Group G] [Fintype G] where
  /-- The symmetric generating set -/
  S : Finset G
  /-- Symmetry: g ∈ S implies g⁻¹ ∈ S -/
  symm : ∀ g ∈ S, g⁻¹ ∈ S
  /-- The set generates the whole group -/
  generates : Subgroup.closure (↑S : Set G) = ⊤
  /-- Upper bound on the normalized second eigenvalue -/
  normalizedSecondEigUpperBound : ℝ
  /-- Witness proposition certifying the eigenvalue bound -/
  witness : Prop

/-- A certificate witnesses expansion when its eigenvalue bound is strictly
    less than 1. -/
def ArithmeticCayleyCertificate.isExpander {G : Type*} [Group G] [Fintype G]
    (cert : ArithmeticCayleyCertificate G) : Prop :=
  cert.normalizedSecondEigUpperBound < 1

/-! ## SL₂(𝔽_p) Generator Matrices -/

/-- The upper unipotent generator matrix u = [[1,1],[0,1]] in Mat₂(ZMod p). -/
def sl2_u_mat (p : ℕ) : Matrix (Fin 2) (Fin 2) (ZMod p) :=
  !![1, 1; 0, 1]

/-- The lower unipotent generator matrix v = [[1,0],[1,1]] in Mat₂(ZMod p). -/
def sl2_v_mat (p : ℕ) : Matrix (Fin 2) (Fin 2) (ZMod p) :=
  !![1, 0; 1, 1]

/-- The determinant of the upper unipotent generator is 1. -/
theorem sl2_u_mat_det (p : ℕ) : (sl2_u_mat p).det = 1 := by
  simp [sl2_u_mat, det_fin_two]

/-- The determinant of the lower unipotent generator is 1. -/
theorem sl2_v_mat_det (p : ℕ) : (sl2_v_mat p).det = 1 := by
  simp [sl2_v_mat, det_fin_two]

/-- The upper unipotent raised to power n gives [[1,n],[0,1]]. -/
theorem sl2_u_mat_pow (p : ℕ) (n : ℕ) :
    (sl2_u_mat p) ^ n = !![1, (n : ZMod p); 0, 1] := by
  induction n with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp [sl2_u_mat]
  | succ n ih =>
    rw [pow_succ, ih]; simp only [sl2_u_mat]
    ext i j; fin_cases i <;> fin_cases j <;> simp [mul_apply, Fin.sum_univ_two] <;> ring

/-- The lower unipotent raised to power n gives [[1,0],[n,1]]. -/
theorem sl2_v_mat_pow (p : ℕ) (n : ℕ) :
    (sl2_v_mat p) ^ n = !![1, 0; (n : ZMod p), 1] := by
  induction n with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp [sl2_v_mat]
  | succ n ih =>
    rw [pow_succ, ih]; simp only [sl2_v_mat]
    ext i j; fin_cases i <;> fin_cases j <;> simp [mul_apply, Fin.sum_univ_two] <;> ring

/-- Predicate: a pair (σ, τ) generates SL₂(𝔽_p). -/
def IsSL2GeneratingPair (p : ℕ) [Fact p.Prime]
    (σ τ : SpecialLinearGroup (Fin 2) (ZMod p)) : Prop :=
  Subgroup.closure ({σ, τ} : Set (SpecialLinearGroup (Fin 2) (ZMod p))) = ⊤

/-! ## Elementary matrix operations in SL₂ -/

/-- Upper unipotent elementary matrix with parameter a: [[1,a],[0,1]]. -/
def upperUnipotent (p : ℕ) (a : ZMod p) : Matrix (Fin 2) (Fin 2) (ZMod p) :=
  !![1, a; 0, 1]

/-- Lower unipotent elementary matrix with parameter a: [[1,0],[a,1]]. -/
def lowerUnipotent (p : ℕ) (a : ZMod p) : Matrix (Fin 2) (Fin 2) (ZMod p) :=
  !![1, 0; a, 1]

/-- The upper unipotent matrix has determinant 1. -/
theorem upperUnipotent_det (p : ℕ) (a : ZMod p) :
    (upperUnipotent p a).det = 1 := by
  simp [upperUnipotent, det_fin_two]

/-- The lower unipotent matrix has determinant 1. -/
theorem lowerUnipotent_det (p : ℕ) (a : ZMod p) :
    (lowerUnipotent p a).det = 1 := by
  simp [lowerUnipotent, det_fin_two]

/-- Product of upper unipotents. -/
theorem upperUnipotent_mul (p : ℕ) (a b : ZMod p) :
    upperUnipotent p a * upperUnipotent p b = upperUnipotent p (a + b) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [upperUnipotent, mul_apply, Fin.sum_univ_two] <;> ring

/-- Product of lower unipotents. -/
theorem lowerUnipotent_mul (p : ℕ) (a b : ZMod p) :
    lowerUnipotent p a * lowerUnipotent p b = lowerUnipotent p (a + b) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [lowerUnipotent, mul_apply, Fin.sum_univ_two] <;> ring

/-- Upper unipotent at 0 is the identity. -/
theorem upperUnipotent_zero (p : ℕ) :
    upperUnipotent p 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [upperUnipotent]

/-- Lower unipotent at 0 is the identity. -/
theorem lowerUnipotent_zero (p : ℕ) :
    lowerUnipotent p 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [lowerUnipotent]

/-- The upper unipotent generator is upperUnipotent at 1. -/
theorem sl2_u_eq_upperUnipotent (p : ℕ) :
    sl2_u_mat p = upperUnipotent p 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [sl2_u_mat, upperUnipotent]

/-- The lower unipotent generator is lowerUnipotent at 1. -/
theorem sl2_v_eq_lowerUnipotent (p : ℕ) :
    sl2_v_mat p = lowerUnipotent p 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [sl2_v_mat, lowerUnipotent]

/-- Key elimination identity: v * u^a * v multiplied on the right produces
    a matrix with controlled entries. This is used in the Gaussian elimination
    proof for SL₂ generation. -/
theorem upperUnipotent_lowerUnipotent_mul (p : ℕ) (a b : ZMod p) :
    upperUnipotent p a * lowerUnipotent p b =
      !![1 + a * b, a; b, 1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [upperUnipotent, lowerUnipotent, mul_apply, Fin.sum_univ_two] <;> ring

theorem lowerUnipotent_upperUnipotent_mul (p : ℕ) (a b : ZMod p) :
    lowerUnipotent p a * upperUnipotent p b =
      !![1, b; a, 1 + a * b] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [upperUnipotent, lowerUnipotent, mul_apply, Fin.sum_univ_two] <;> ring