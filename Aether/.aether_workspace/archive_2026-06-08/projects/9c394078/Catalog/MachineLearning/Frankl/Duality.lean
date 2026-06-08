/-
  # Frankl's Conjecture — Duality and Lattice Reformulations

  This module establishes the duality between union-closed and
  intersection-closed families, and provides lattice-theoretic viewpoints.

  ## Main results

  * `unionClosed_dual_interClosed` — UC families dualize to IC families
  * `unionClosed_iff_closed_under_sup` — UC = closed under ⊔ on Finset
  * `frankl_set_family_iff_lattice_form` — the lattice reformulation (definitional)
-/
import Mathlib
import Speculative.Frankl.Defs

namespace Frankl

open Finset

variable {α : Type*} [DecidableEq α]

/-! ### Union-closure is closure under sup -/

/-
Union-closure is the same as closure under the lattice sup operation on `Finset`.
-/
theorem unionClosed_iff_closed_under_sup
    (F : Finset (Finset α)) :
    UnionClosed F ↔ ∀ ⦃A B⦄, A ∈ F → B ∈ F → A ⊔ B ∈ F := by
  rfl

/-! ### Duality: union-closed ↔ complement is intersection-closed -/

/-- Membership criterion for the dual family. -/
theorem mem_dualFamily (U : Finset α) (F : Finset (Finset α)) (S : Finset α) :
    S ∈ dualFamily U F ↔ ∃ A ∈ F, S = U \ A := by
  simp [dualFamily, Finset.mem_image, eq_comm]

/-
A family `F` is union-closed if and only if its complement-dual
    `dualFamily U F` is intersection-closed (i.e., closed under `∩`),
    provided every member of `F` is contained in `U`.
-/
theorem unionClosed_dual_interClosed
    (U : Finset α) (F : Finset (Finset α))
    (hsub : ∀ A ∈ F, A ⊆ U) :
    UnionClosed F ↔
      (∀ ⦃A B⦄, A ∈ dualFamily U F → B ∈ dualFamily U F → A ∩ B ∈ dualFamily U F) := by
  constructor;
  · grind +suggestions;
  · intro h;
    -- Given A, B ∈ F with A ⊆ U and B ⊆ U. Then U \ A and U \ B are in dualFamily U F.
    intro A B hA hB
    have hA' : U \ A ∈ dualFamily U F := by
      exact Finset.mem_image_of_mem _ hA
    have hB' : U \ B ∈ dualFamily U F := by
      exact Finset.mem_image_of_mem _ hB;
    have := h hA' hB'; simp_all +decide [ dualFamily ] ;
    obtain ⟨ C, hC, hC' ⟩ := this; have := hsub C hC; simp_all +decide [ Finset.ext_iff ] ;
    convert hC using 1;
    grind

/-! ### Lattice reformulation (definitional bridge) -/

/-
The "lattice reformulation" of Frankl's conjecture is definitionally
    equivalent to the set-family version. This theorem serves as a formal
    bridge, showing that seeking `x : α` with `2 * (F.filter (x ∈ ·)).card ≥ F.card`
    is the same as seeking `x` with `2 * element_frequency x F ≥ F.card`.
-/
theorem frankl_set_family_iff_lattice_form
    [Fintype α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : ∃ A ∈ F, A.Nonempty) :
    (∃ x : α, 2 * element_frequency x F ≥ F.card)
      ↔
    (∃ x : α, 2 * (F.filter (fun A => x ∈ A)).card ≥ F.card) := by
  rfl

end Frankl