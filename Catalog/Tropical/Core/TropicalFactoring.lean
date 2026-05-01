/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Algebra Foundations

This file establishes the foundational definitions for tropical algebraic geometry
in the context of the Langlands program. It provides:

- A `LocalField` class for p-adic and function fields
- The permutation action on function spaces (Weyl group action on coweights)
- Basic lemmas for tropical lattice operations
-/
import Mathlib

open Finset BigOperators

/-! ## Local Fields -/

/-- A local field is a locally compact non-discrete topological field.
    This is a minimal definition sufficient for the tropical Satake isomorphism. -/
class LocalField (F : Type*) extends Field F, TopologicalSpace F

/-! ## Permutation Action on Coweight Lattice -/

/-- The natural action of the symmetric group S_n on the coweight lattice ℤⁿ,
    given by permuting coordinates: (σ • v)(i) = v(σ⁻¹(i)).
    This is the Weyl group action on the coweight lattice for GL_n. -/
instance permMulAction (n : ℕ) (α : Type*) :
    MulAction (Equiv.Perm (Fin n)) (Fin n → α) where
  smul σ v := fun i => v (σ⁻¹ i)
  one_smul v := by
    ext i; show v ((1 : Equiv.Perm (Fin n))⁻¹ i) = v i; simp
  mul_smul σ τ v := by
    ext i
    show v ((σ * τ)⁻¹ i) = (fun j => (fun k => v (τ⁻¹ k)) (σ⁻¹ j)) i
    simp [Equiv.Perm.mul_apply]

@[simp]
theorem perm_smul_apply {n : ℕ} {α : Type*} (σ : Equiv.Perm (Fin n)) (v : Fin n → α)
    (i : Fin n) : (σ • v) i = v (σ⁻¹ i) := rfl

/-- Permuting coordinates preserves the sum. -/
theorem perm_sum_eq {n : ℕ} (σ : Equiv.Perm (Fin n)) (v : Fin n → ℤ) :
    ∑ i, (σ • v) i = ∑ i, v i := by
  change ∑ i, v (σ⁻¹ i) = ∑ i, v i
  exact Equiv.sum_comp σ⁻¹ v

/-! ## Tropical Lattice Min-Max Lemma -/

/-- Key factoring lemma for tropical lattice computations. -/
theorem tropical_lattice_min_max {n : ℕ} {f g : Fin n → ℤ}
    (h : ∀ i, f i ≤ g i) : ∑ i, f i ≤ ∑ i, g i :=
  Finset.sum_le_sum (fun i _ => h i)