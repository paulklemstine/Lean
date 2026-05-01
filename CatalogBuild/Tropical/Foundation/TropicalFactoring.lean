/-! # CatalogBuild.Tropical.Foundation.TropicalFactoring

Auto-generated from theorem catalog database.
Domain: Tropical/Foundation
Declarations: 4
-/

import Mathlib

/-- A local field is a locally compact non-discrete topological field.
This is a minimal definition sufficient for the tropical Satake isomorphism. -/
class LocalField (F : Type*) extends Field F, TopologicalSpace F


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

/-- [Section: ## Permutation Action on Coweight Lattice] -/
theorem perm_smul_apply {n : ℕ} {α : Type*} (σ : Equiv.Perm (Fin n)) (v : Fin n → α)
    (i : Fin n) : (σ • v) i = v (σ⁻¹ i) := rfl


/-- Permuting coordinates preserves the sum. -/
theorem perm_sum_eq {n : ℕ} (σ : Equiv.Perm (Fin n)) (v : Fin n → ℤ) :
    ∑ i, (σ • v) i = ∑ i, v i := by
  change ∑ i, v (σ⁻¹ i) = ∑ i, v i
  exact Equiv.sum_comp σ⁻¹ v

