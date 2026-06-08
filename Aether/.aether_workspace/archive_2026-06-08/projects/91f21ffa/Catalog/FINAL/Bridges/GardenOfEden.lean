/-
# Finite Garden-of-Eden Principle

A formal treatment of the Garden-of-Eden theorem for finite dynamical systems,
establishing that non-surjective dynamics on finite state spaces produce
permanently unreachable ("Garden-of-Eden") configurations, and that monotone
descending maps on finite partial orders stabilize in bounded time.

## Main Results

- `iterate_descends`: Iterates of a descending map form a descending chain.
- `finite_garden_of_eden_descent`: Every orbit of a monotone descending map on a
  finite partial order stabilizes within `Fintype.card P` steps.
- `finite_garden_of_eden_of_not_surjective`: A non-surjective monotone descending map
  has a Garden-of-Eden state outside the eventual image.
- `finite_configuration_garden_of_eden`: On finite configuration spaces, non-surjective
  maps have unreachable configurations.
- `preinjective_of_surjective_on_finite_configurations`: Finite Moore–Myhill shadow —
  surjectivity implies injectivity on finite types.

## Concepts

A **Garden-of-Eden** state is a configuration with no preimage under the dynamics.
The **eventual image** is the range of sufficiently many iterates.
**Descent-stabilization** means every orbit reaches a fixed point in bounded time.
-/

import Mathlib

open Function Set

/-- A Garden-of-Eden state for `F` is one with no preimage. -/
def IsGardenOfEden {α : Type*} (F : α → α) (y : α) : Prop :=
  ∀ x, F x ≠ y

/-- Garden-of-Eden states exist if and only if `F` is not surjective. -/
theorem exists_garden_of_eden_iff_not_surjective
    {α : Type*} (F : α → α) :
    (∃ y, IsGardenOfEden F y) ↔ ¬ Surjective F := by
  simp [IsGardenOfEden, Surjective]

/-- Iterates of a descending map form a descending chain:
`F^[n+1] x ≤ F^[n] x` for all `n` and `x`. -/
theorem iterate_descends
    {P : Type*} [PartialOrder P]
    (F : P → P) (hdesc : ∀ x, F x ≤ x) :
    ∀ n x, F^[n + 1] x ≤ F^[n] x :=
  fun _n x => by simpa only [Function.iterate_succ_apply'] using hdesc _

/-- **Finite Garden-of-Eden Descent Principle.**
Every orbit of a monotone descending map on a finite partial order
stabilizes (reaches a fixed point) within `Fintype.card P` steps. -/
theorem finite_garden_of_eden_descent
    {P : Type*} [Fintype P] [DecidableEq P] [PartialOrder P]
    (F : P → P)
    (_hmono : Monotone F)
    (hdesc : ∀ x : P, F x ≤ x) :
    ∀ x : P, ∃ n ≤ Fintype.card P, F^[n] x = F^[n + 1] x := by
  intro x
  by_contra h_contra
  push_neg at h_contra
  have h_ne : ∀ n ≤ Fintype.card P, F^[n] x ≠ F^[n + 1] x := by finiteness
  have h_card : Finset.card (Finset.image (fun n => F^[n] x)
      (Finset.range (Fintype.card P + 1))) = Fintype.card P + 1 := by
    nontriviality
    have h_strict : ∀ m n : ℕ, m < n → n ≤ Fintype.card P → F^[m] x ≠ F^[n] x := by
      intro m n mn hn hmn
      induction mn <;> simp_all +decide [Function.iterate_succ_apply']
      · exact h_contra m hn.le hmn
      · have h_bound : ∀ k ≥ m + 1, F^[k] x ≤ F^[m + 1] x := by
          intro k hk; induction hk <;> simp_all +decide [Function.iterate_succ_apply']
          grind
        have := h_bound _ (Nat.succ_le_of_lt ‹_›)
        simp_all +decide [Function.iterate_succ_apply']
        grind
    rw [Finset.card_image_of_injOn fun m hm n hn hmn =>
      le_antisymm
        (le_of_not_gt fun hmn' =>
          h_strict _ _ hmn' (Finset.mem_range_succ_iff.mp hm) hmn.symm)
        (le_of_not_gt fun hmn' =>
          h_strict _ _ hmn' (Finset.mem_range_succ_iff.mp hn) hmn),
      Finset.card_range]
  exact h_card.not_lt (lt_of_le_of_lt (Finset.card_le_univ _) (by simp +decide))

/-- An element not in the range of `F` is not in the range of any positive iterate. -/
theorem not_in_range_iterate_of_not_in_range
    {α : Type*} (F : α → α) {y : α}
    (hy : y ∉ Set.range F) :
    ∀ n : ℕ, n ≠ 0 → y ∉ Set.range (F^[n]) := by
  intro n hn h
  induction n <;> simp_all +decide [Function.iterate_succ_apply']
  obtain ⟨z, hz⟩ := h
  cases ‹ℕ› <;> simp_all +decide

/-- **Garden-of-Eden of non-surjective monotone descending maps.**
If `F` is monotone, descending, and non-surjective, then there exists a
Garden-of-Eden state that lies outside the eventual image `range (F^[card P])`. -/
theorem finite_garden_of_eden_of_not_surjective
    {P : Type*} [Fintype P] [DecidableEq P] [PartialOrder P]
    (F : P → P)
    (_hmono : Monotone F)
    (_hdesc : ∀ x : P, F x ≤ x)
    (hnsurj : ¬ Surjective F) :
    ∃ y : P, (∀ x : P, F x ≠ y) ∧ y ∉ Set.range (F^[Fintype.card P]) := by
  obtain ⟨y, hy⟩ : ∃ y, y ∉ Set.range F := not_forall.mp hnsurj
  exact ⟨y, fun x hx => hy ⟨x, hx⟩,
    not_in_range_iterate_of_not_in_range F hy _
      (Nat.ne_of_gt (Fintype.card_pos_iff.mpr ⟨y⟩))⟩

/-- **Finite configuration Garden-of-Eden.**
On a finite configuration space `ι → α`, any non-surjective map has an
unreachable configuration — a Garden-of-Eden state. -/
theorem finite_configuration_garden_of_eden
    {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]
    (F : (ι → α) → (ι → α))
    (hnsurj : ¬ Surjective F) :
    ∃ c : (ι → α), ∀ x : (ι → α), F x ≠ c := by
  simpa [Function.Surjective, Classical.or_iff_not_imp_left] using hnsurj

/-- **Finite Moore–Myhill shadow.**
On finite types, surjectivity implies injectivity.
This is the finite analogue of the Moore direction of the Moore–Myhill theorem
for cellular automata. -/
theorem preinjective_of_surjective_on_finite_configurations
    {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]
    (F : (ι → α) → (ι → α))
    (hsurj : Surjective F) :
    Injective F :=
  Finite.injective_iff_surjective.mpr hsurj

/-- The eventual image of a monotone descending map equals the set of fixed points. -/
theorem eventual_image_eq_fixed_points
    {P : Type*} [Fintype P] [DecidableEq P] [PartialOrder P]
    (F : P → P)
    (hmono : Monotone F)
    (hdesc : ∀ x : P, F x ≤ x) :
    Set.range (F^[Fintype.card P]) = {x | F x = x} := by
  have h_stabilize : ∀ x : P, ∃ n ≤ Fintype.card P,
      F^[n] x = F^[n + 1] x ∧ ∀ k ≥ n, F^[k] x = F^[n] x := by
    intro x
    obtain ⟨n, hn⟩ := finite_garden_of_eden_descent F hmono hdesc x
    use n
    refine ⟨hn.1, hn.2, fun k hk => ?_⟩
    induction hk <;> simp_all +singlePass [Function.iterate_succ_apply']
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    obtain ⟨n, hn₁, hn₂, hn₃⟩ := h_stabilize y
    simp +decide [← Function.iterate_succ_apply', hn₃ _ hn₁] at hn₂ ⊢
    exact hn₂.symm
  · intro hx
    exact ⟨x, Function.iterate_fixed hx _⟩