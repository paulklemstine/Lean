import Mathlib

/-!
# Hydrogen Atom: Core Definitions

This file establishes the foundational definitions for a machine-verified
spectral theory of the hydrogen atom. We define:

- **Quantum numbers** and their validity constraints
- **Energy levels** in atomic units: `E_n = -1/n²`
- **Eigenpair predicates** for operator eigenvalue problems

## Mathematical Context

The hydrogen atom Hamiltonian in atomic units is:
  H = -Δ - 2/r

Its bound-state spectrum is `{-1/n² : n ∈ ℕ₊}`. For each principal
quantum number `n`, the angular momentum quantum number `l` ranges
over `0, 1, …, n-1`, and the magnetic quantum number `m` ranges over
`-l, -l+1, …, l`.
-/

noncomputable section

open Finset BigOperators

/-! ## Quantum Number Validity -/

/-- A valid set of hydrogen quantum numbers `(n, l, m)` satisfies
`n ≥ 1`, `0 ≤ l < n`, and `|m| ≤ l`. -/
structure HydrogenQuantumNumbers where
  /-- Principal quantum number (≥ 1) -/
  n : ℕ+
  /-- Angular momentum quantum number -/
  l : ℕ
  /-- Magnetic quantum number -/
  m : ℤ
  /-- Angular momentum is bounded by principal quantum number -/
  hl : l < n
  /-- Magnetic quantum number is bounded by angular momentum -/
  hm : Int.natAbs m ≤ l

/-! ## Energy Levels -/

/-- The hydrogen bound-state energy for principal quantum number `n`,
in units where `E_n = -1/n²`. -/
def hydrogenEnergy (n : ℕ+) : ℝ := -1 / ((n : ℝ) ^ 2)

/-- The hydrogen energy is always negative for bound states. -/
theorem hydrogenEnergy_neg (n : ℕ+) : hydrogenEnergy n < 0 := by
  unfold hydrogenEnergy
  apply div_neg_of_neg_of_pos
  · norm_num
  · positivity

/-
Distinct principal quantum numbers give distinct energies.
-/
theorem hydrogenEnergy_injective : Function.Injective hydrogenEnergy := by
  intro n₁; simp_all +decide [ hydrogenEnergy, div_eq_mul_inv ] ;

/-
Energy levels increase (become less negative) with `n`.
-/
theorem hydrogenEnergy_strictMono : StrictMono hydrogenEnergy := by
  unfold StrictMono hydrogenEnergy;
  intro a b h; rw [ div_lt_div_iff₀ ] <;> norm_num ; gcongr ; norm_cast;

/-! ## Eigenpair Predicate -/

/-- A general eigenpair predicate for linear operators: `v` is an eigenvector
of `T` with eigenvalue `μ` if `v ≠ 0` and `T v = μ • v`. -/
def IsEigenpair {V : Type*} [AddCommMonoid V] [Module ℝ V]
    (T : V → V) (μ : ℝ) (v : V) : Prop :=
  v ≠ 0 ∧ T v = μ • v

/-- Complex-valued eigenpair predicate. -/
def IsEigenpairℂ {V : Type*} [AddCommMonoid V] [Module ℂ V]
    (T : V → V) (μ : ℂ) (v : V) : Prop :=
  v ≠ 0 ∧ T v = μ • v

end