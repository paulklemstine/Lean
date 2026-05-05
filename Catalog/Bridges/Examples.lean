/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Concrete Examples of Coherent Closure Proof Semirings

This file provides concrete instances of `CoherentClosureProofSemiring` and
demonstrates the adequacy theorem on them.

## Examples

1. **Identity closure** on any bounded distributive lattice — where `cl = id`,
   so derivability equals the lattice order.
2. **Top closure** — where `cl x = ⊤` for all `x`, so everything derives everything.
3. **Threshold closure** on `Fin n` — a non-trivial finite example.
-/

import Bridges.JacobsonAdequacy.Theorems

open CoherentClosureProofSemiring

/-! ## Example 1: Identity Closure (Trivial Nucleus) -/

/-- The identity closure on any bounded distributive lattice. Under this closure,
`derivable x y ↔ x ≤ y`, so the adequacy theorem recovers the prime ideal
theorem for distributive lattices directly. -/
instance identityClosure (α : Type*) [DistribLattice α] [BoundedOrder α] :
    CoherentClosureProofSemiring α where
  cl := id
  cl_extensive := fun _ => le_refl _
  cl_idempotent := fun _ => rfl
  cl_monotone := fun _ _ h => h

example : @derivable Bool (identityClosure Bool) false true := by
  unfold derivable cl'
  simp [identityClosure]

example : ¬ @derivable Bool (identityClosure Bool) true false := by
  unfold derivable cl'
  simp [identityClosure]

/-- Under the identity closure, derivability equals the lattice order. -/
theorem identity_derivable_iff_le {α : Type*} [DistribLattice α] [BoundedOrder α]
    (x y : α) :
    @derivable α (identityClosure α) x y ↔ x ≤ y := by
  unfold derivable cl'
  simp [identityClosure]

/-- Under the identity closure, the adequacy theorem specializes to:
`x ≤ y ↔ ∀ e admissible, e x → e y`. This is exactly the prime ideal
theorem for bounded distributive lattices stated in evaluation form. -/
theorem identity_adequacy {α : Type*} [DistribLattice α] [BoundedOrder α]
    (x y : α) :
    x ≤ y ↔ ∀ e, @AdmissibleEvaluation α (identityClosure α) e → (e x → e y) := by
  rw [← identity_derivable_iff_le]
  exact derivable_iff_all_jacobson_evaluations_validate' x y

/-! ## Example 2: Top Closure (Trivializing Nucleus) -/

/-- The top closure maps everything to `⊤`. Under this closure, `derivable x y`
holds for all `x, y`, since `cl x = ⊤ = cl y`. -/
instance topClosure (α : Type*) [DistribLattice α] [BoundedOrder α] :
    CoherentClosureProofSemiring α where
  cl := fun _ => ⊤
  cl_extensive := fun _ => le_top
  cl_idempotent := fun _ => rfl
  cl_monotone := fun _ _ _ => le_refl _

/-- Under the top closure, everything derives everything. -/
theorem top_derivable {α : Type*} [DistribLattice α] [BoundedOrder α]
    (x y : α) :
    @derivable α (topClosure α) x y := by
  unfold derivable cl'
  simp [topClosure]

/-! ## Example 3: Threshold Closure on Fin n -/

/-- A threshold closure on `Fin (n+2)`: `cl(x) = x ⊔ t` where `t` is a fixed
threshold. This gives a non-trivial closure operator on a finite chain. -/
noncomputable instance thresholdClosure (n : ℕ) (t : Fin (n+2)) :
    CoherentClosureProofSemiring (Fin (n+2)) where
  cl := fun x => x ⊔ t
  cl_extensive := fun x => le_sup_left
  cl_idempotent := fun x => by
    show (x ⊔ t) ⊔ t = x ⊔ t
    rw [sup_assoc, sup_idem]
  cl_monotone := fun x y h => sup_le_sup_right h t

/-- Under the threshold closure with threshold `t`, `derivable x y ↔ x ⊔ t ≤ y ⊔ t`. -/
theorem threshold_derivable_iff {n : ℕ} {t : Fin (n+2)} (x y : Fin (n+2)) :
    @derivable _ (thresholdClosure n t) x y ↔ x ⊔ t ≤ y ⊔ t := by
  unfold derivable cl'
  simp [thresholdClosure]

/-! ## Example 4: Bool Classification -/

/-- On `Bool` (ordered `false < true`), the only closure operators are
the identity and the constant `true` function. -/
theorem bool_only_closures :
    ∀ (cl : Bool → Bool),
      (∀ x, x ≤ cl x) → (∀ x, cl (cl x) = cl x) → (∀ x y, x ≤ y → cl x ≤ cl y) →
      cl = id ∨ cl = fun _ => true := by
  intro cl hext hidem hmono
  by_cases h : cl false = false
  · left; ext x; cases x
    · exact h
    · exact le_antisymm le_top (hext true)
  · right
    have hcf : cl false = true := by
      cases hf : cl false
      · exact absurd hf h
      · rfl
    have hct : cl true = true := le_antisymm le_top (hext true)
    ext x; cases x <;> simp [hcf, hct]