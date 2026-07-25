import Mathlib

/-! # Combinatorial Bridge

Proves combinatorial inequalities connecting discrete mathematics to
certified adversarial robustness:

1. Pigeonhole principle: |A| > |B| → ∃ x≠y, f(x) = f(y)
2. Pigeonhole for finsets
3. Union bound (finite): |A ∪ B| ≤ |A| + |B|
4. Subset cardinality: S ⊆ T → |S| ≤ |T|
5. No injection when card target < card source
6. Finite set bounded by universe

These connect to certified robustness: adversarial inputs must collide
when there are more regions than certified margins.
-/

namespace CombinatorialBridge

/-! ## Section 1: Pigeonhole Principle -/

/-- Pigeonhole principle: if |α| > |β|, then ∃ x≠y with f(x) = f(y).
    In robustness: more input regions than output classes → collision. -/
theorem pigeonhole {α β : Type*} [Fintype α] [Fintype β] (f : α → β)
    (h : Fintype.card β < Fintype.card α) :
    ∃ x y, x ≠ y ∧ f x = f y :=
  Fintype.exists_ne_map_eq_of_card_lt f h

/-- Pigeonhole for Finset: if |s| > |t| and f maps s into t,
    then ∃ x≠y ∈ s with f(x) = f(y). -/
theorem pigeonhole_finset {α β : Type*} [DecidableEq β] {s : Finset α} {t : Finset β}
    (f : α → β) (hst : Set.MapsTo f ↑s ↑t) (hcard : t.card < s.card) :
    ∃ x ∈ s, ∃ y ∈ s, x ≠ y ∧ f x = f y :=
  Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hst

/-! ## Section 2: Finite Counting Bounds -/

/-- Subset cardinality bound: S ⊆ T → |S| ≤ |T|.-/
theorem subset_card_le {α : Type*} [DecidableEq α] {s t : Finset α} (hst : s ⊆ t) :
    s.card ≤ t.card :=
  Finset.card_le_card hst

/-- Finite set bounded by universe: |S| ≤ |α|. -/
theorem finset_card_le_univ {α : Type*} [Fintype α] [DecidableEq α] (s : Finset α) :
    s.card ≤ Fintype.card α :=
  Finset.card_le_univ s

/-- Union bound (finite): |A ∪ B| ≤ |A| + |B|.
    The combinatorial analog of Boole's inequality P(A ∪ B) ≤ P(A) + P(B). -/
theorem union_card_le {α : Type*} [DecidableEq α] (s t : Finset α) :
    (s ∪ t).card ≤ s.card + t.card :=
  Finset.card_union_le s t

/-! ## Section 3: No Injection When Outnumbered -/

/-- If |α| > |β|, no injective map α → β exists.
    In robustness: can't assign distinct certified margins to more inputs
    than there are margin classes. -/
theorem no_injection_when_card_lt {α β : Type*} [Fintype α] [Fintype β]
    (h : Fintype.card β < Fintype.card α) (f : α → β) :
    ¬Function.Injective f := by
  intro hf
  have := Fintype.card_le_of_injective f hf
  omega

end CombinatorialBridge