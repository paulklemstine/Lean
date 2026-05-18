/-
  # Frankl's Union-Closed Conjecture — Statement and Special Cases

  This module states Frankl's conjecture precisely and assembles the
  proved special cases as corollaries.

  ## Main results

  * `frankl_union_closed_conjecture` — the full conjecture (sorry'd)
  * `frankl_of_singleton_in_family` — Frankl holds when some singleton is in F
  * `frankl_of_small_family` — Frankl holds for |F| ≤ 2
  * `frankl_of_average_large` — Frankl holds when average set size ≥ half ground size
-/
import Mathlib
import Speculative.Frankl.Defs
import Speculative.Frankl.DoubleCount
import Speculative.Frankl.Maximals
import Speculative.Frankl.Duality

namespace Frankl

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ### The full conjecture -/

/-- **Frankl's union-closed conjecture**: If `F` is a finite union-closed family
    containing at least one nonempty set, then some element belongs to at least
    half the members of `F`.

    This remains an open problem. -/
theorem frankl_union_closed_conjecture
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : ∃ A ∈ F, A.Nonempty) :
    ∃ x : α, 2 * element_frequency x F ≥ F.card := by
  sorry

/-! ### Proved special cases -/

/-- Frankl's conjecture holds for families containing a singleton `{x}`. -/
theorem frankl_of_singleton_in_family
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hx : ∃ x : α, ({x} : Finset α) ∈ F) :
    ∃ x : α, 2 * element_frequency x F ≥ F.card := by
  obtain ⟨x, hx⟩ := hx
  exact ⟨x, frankl_of_singleton_mem F hUC x hx⟩

/-- Frankl's conjecture holds for families with at most 2 members. -/
theorem frankl_of_small_family
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : ∃ A ∈ F, A.Nonempty)
    (hcard : F.card ≤ 2) :
    ∃ x : α, 2 * element_frequency x F ≥ F.card :=
  frankl_of_card_le_two F hUC hne hcard

/-- Frankl's conjecture holds when the average set size is at least half
    the ground set size. -/
theorem frankl_of_average_large
    (F : Finset (Finset α))
    (hne : ∃ A ∈ F, A.Nonempty)
    (havg : 2 * ∑ A ∈ F, A.card ≥ F.card * (ground F).card) :
    ∃ x : α, 2 * element_frequency x F ≥ F.card := by
  obtain ⟨x, hxG, hx⟩ := exists_frequent_of_average_card_ge_half_ground F
    (ground_nonempty_of_nonempty_member F hne) havg
  exact ⟨x, hx⟩

/-! ### Structural results summary -/

/-- A nonempty union-closed family has exactly one maximal member. -/
theorem unique_maximum
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : F.Nonempty) :
    (maximalMembers F).card = 1 :=
  maximalMembers_card_eq_one F hUC hne

/-- The unique maximal member of a UC family is the ground set. -/
theorem maximum_is_ground
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (M : Finset α)
    (hM : IsMaximalMember F M) :
    M = ground F :=
  maximal_eq_ground F hUC M hM

end Frankl