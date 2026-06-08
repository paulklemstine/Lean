/-
  # Frankl's Conjecture — Double Counting and Average-Size Criterion

  This module proves the fundamental double-counting identity for set families
  and uses it to establish Theorem A: if the average set size is at least
  half the ground set size, then some element appears in at least half the sets.

  ## Main results

  * `sum_card_eq_sum_frequency` — the incidence double-counting identity
  * `exists_frequent_of_average_card_ge_half_ground` — Theorem A
-/
import Mathlib
import Speculative.Frankl.Defs

namespace Frankl

open Finset

variable {α : Type*} [DecidableEq α]

/-! ### The double-counting identity

The key identity:
  `∑ A ∈ F, A.card = ∑ x ∈ ground F, element_frequency x F`

Both sides count the same incidence pairs `(x, A)` with `x ∈ A ∈ F`. -/

/-- The incidence double-counting identity for finite set families. -/
theorem sum_card_eq_sum_frequency
    (F : Finset (Finset α)) :
    ∑ A ∈ F, A.card = ∑ x ∈ ground F, element_frequency x F := by
  simp +decide only [card_eq_sum_ones, element_frequency]
  rw [Finset.sum_sigma', Finset.sum_sigma']
  refine Finset.sum_bij (fun x _ => ⟨x.2, x.1⟩) ?_ ?_ ?_ ?_ <;>
    simp +contextual [appearsIn]
  · exact fun a ha₁ ha₂ => Finset.mem_biUnion.2 ⟨a.1, ha₁, ha₂⟩
  · grind
  · grind

/-! ### Theorem A: Average-size criterion -/

/-
**Theorem A** (Average-size criterion implies Frankl witness).

If the average cardinality of members of `F` is at least half the ground-set size —
i.e. `2 * ∑ A in F, A.card ≥ F.card * (ground F).card` —
and the ground set is nonempty,
then some element of the ground set belongs to at least half the members.
-/
theorem exists_frequent_of_average_card_ge_half_ground
    [Fintype α]
    (F : Finset (Finset α))
    (hG : (ground F).Nonempty)
    (havg : 2 * ∑ A ∈ F, A.card ≥ F.card * (ground F).card) :
    ∃ x ∈ ground F, 2 * element_frequency x F ≥ F.card := by
  contrapose! havg;
  convert Finset.sum_lt_sum_of_nonempty hG havg using 1;
  · rw [ ← Finset.mul_sum _ _ _, sum_card_eq_sum_frequency ];
  · simp +decide [ mul_comm ]

end Frankl