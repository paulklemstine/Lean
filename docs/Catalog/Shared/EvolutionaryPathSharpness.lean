/-
  # Sharpness: each axiom of a quotient system is necessary

  Adversarial review of `Shared.EvolutionaryPathCore`.  The decomposition
  theorem `EvolPath.jordan_holder` rests on three axioms — `rank_lt`,
  `label_unique`, `exchange`.  Here we show that **none of them can be dropped**,
  by exhibiting, for each axiom, a labelled step relation satisfying the other
  two for which the corresponding conclusion fails.

  To speak about chains for a step relation that is *not* a `QuotientSystem`, we
  use the axiom-free `Chain` predicate; `evolPath_iff_chain` shows that `Chain`
  restricted to a genuine quotient system is exactly `EvolPath`, so the
  counterexamples really are counterexamples about evolutionary paths.

  * `exchange_is_necessary`     — without exchange: two complete chains from the
    same source with different lengths (so also different label multisets).
  * `label_unique_is_necessary` — without label determinacy: two complete chains
    with different label multisets (though of equal length).
  * `termination_is_necessary`  — without a decreasing rank: no complete chain
    exists at all, so no decomposition invariant can be defined.
-/
import Shared.EvolutionaryPathCore

namespace Shared.EvolutionaryPath

/-- Chains of an arbitrary labelled step relation, with no axioms assumed. -/
inductive Chain {α Λ : Type} (step : α → Λ → α → Prop) : α → α → List Λ → Prop
  | nil (x : α) : Chain step x x []
  | cons {x l y t ls} : step x l y → Chain step y t ls → Chain step x t (l :: ls)

/-- `x` admits no step of the given relation. -/
def Stuck {α Λ : Type} (step : α → Λ → α → Prop) (x : α) : Prop := ∀ l y, ¬ step x l y

/-- For a genuine quotient system, chains are exactly evolutionary paths. -/
theorem evolPath_iff_chain {α Λ : Type} (Q : QuotientSystem α Λ) (x t : α) (ls : List Λ) :
    EvolPath Q x t ls ↔ Chain Q.step x t ls := by
  constructor
  · intro h
    induction h with
    | nil x => exact Chain.nil x
    | cons hs _ ih => exact Chain.cons hs ih
  · intro h
    induction h with
    | nil x => exact EvolPath.nil x
    | cons hs _ ih => exact EvolPath.cons hs ih

/-- `Stuck` for a quotient system is `Terminal`. -/
theorem stuck_iff_terminal {α Λ : Type} (Q : QuotientSystem α Λ) (x : α) :
    Stuck Q.step x ↔ Terminal Q x := Iff.rfl

section ExchangeNecessary

/-- A three-element system with the steps `0 → 1`, `1 → 2` and the "shortcut"
`0 → 2`.  Ranks decrease and labels are trivially determined, but the diamond
`0 → 1`, `0 → 2` cannot be closed. -/
def badStep : Fin 3 → Unit → Fin 3 → Prop := fun x _ y =>
  (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 2) ∨ (x = 0 ∧ y = 2)

/-- The rank `2 - x`. -/
def badRank : Fin 3 → ℕ := fun x => 2 - (x : ℕ)

theorem badStep_rank_lt : ∀ x l y, badStep x l y → badRank y < badRank x := by
  rintro x l y (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;> decide

theorem badStep_label_unique : ∀ x l₁ l₂ y, badStep x l₁ y → badStep x l₂ y → l₁ = l₂ :=
  fun _ l₁ l₂ _ _ _ => Subsingleton.elim l₁ l₂

theorem badStep_stuck_two : Stuck badStep 2 := by
  rintro l y (⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩) <;> exact absurd h (by decide)

theorem badStep_exchange_fails :
    ¬ ∀ (x : Fin 3) (l₁ : Unit) (y₁ : Fin 3) (l₂ : Unit) (y₂ : Fin 3),
        badStep x l₁ y₁ → badStep x l₂ y₂ → y₁ ≠ y₂ → ∃ z, badStep y₁ l₂ z ∧ badStep y₂ l₁ z := by
  intro h
  obtain ⟨z, -, hz⟩ := h 0 () 1 () 2 (Or.inl ⟨rfl, rfl⟩) (Or.inr (Or.inr ⟨rfl, rfl⟩))
    (by decide)
  exact badStep_stuck_two () z hz

/-- **The exchange axiom cannot be dropped.**  With termination and label
determinacy alone, two complete chains out of the same object can have different
lengths, hence different label multisets: the decomposition invariant would be
ill defined. -/
theorem exchange_is_necessary :
    ∃ (step : Fin 3 → Unit → Fin 3 → Prop) (rank : Fin 3 → ℕ),
      (∀ x l y, step x l y → rank y < rank x) ∧
      (∀ x l₁ l₂ y, step x l₁ y → step x l₂ y → l₁ = l₂) ∧
      ∃ (t : Fin 3) (ls₁ ls₂ : List Unit),
        Chain step 0 t ls₁ ∧ Chain step 0 t ls₂ ∧ Stuck step t ∧
        ls₁.length ≠ ls₂.length ∧ (ls₁ : Multiset Unit) ≠ (ls₂ : Multiset Unit) := by
  refine ⟨badStep, badRank, badStep_rank_lt, badStep_label_unique, 2, [(), ()], [()], ?_, ?_,
    badStep_stuck_two, by simp, ?_⟩
  · exact Chain.cons (Or.inl ⟨rfl, rfl⟩) (Chain.cons (Or.inr (Or.inl ⟨rfl, rfl⟩)) (Chain.nil 2))
  · exact Chain.cons (Or.inr (Or.inr ⟨rfl, rfl⟩)) (Chain.nil 2)
  · intro hm
    have := congrArg Multiset.card hm
    simp at this

end ExchangeNecessary

section LabelUniqueNecessary

/-- A two-element system with two differently labelled copies of the same step
`0 → 1`.  Termination and exchange hold (there is only one possible target, so
the exchange hypothesis `y₁ ≠ y₂` is vacuous), but labels are not determined. -/
def twinStep : Fin 2 → Bool → Fin 2 → Prop := fun x _ y => x = 0 ∧ y = 1

def twinRank : Fin 2 → ℕ := fun x => 1 - (x : ℕ)

/-- **Label determinacy cannot be dropped.**  With termination and exchange
alone, two complete chains out of the same object can carry different label
multisets, so the labelled invariant collapses. -/
theorem label_unique_is_necessary :
    ∃ (step : Fin 2 → Bool → Fin 2 → Prop) (rank : Fin 2 → ℕ),
      (∀ x l y, step x l y → rank y < rank x) ∧
      (∀ x l₁ y₁ l₂ y₂, step x l₁ y₁ → step x l₂ y₂ → y₁ ≠ y₂ →
        ∃ z, step y₁ l₂ z ∧ step y₂ l₁ z) ∧
      ∃ (t : Fin 2) (ls₁ ls₂ : List Bool),
        Chain step 0 t ls₁ ∧ Chain step 0 t ls₂ ∧ Stuck step t ∧
        (ls₁ : Multiset Bool) ≠ (ls₂ : Multiset Bool) := by
  refine ⟨twinStep, twinRank, ?_, ?_, 1, [true], [false], ?_, ?_, ?_, ?_⟩
  · rintro x l y ⟨rfl, rfl⟩
    decide
  · rintro x l₁ y₁ l₂ y₂ ⟨-, rfl⟩ ⟨-, rfl⟩ hne
    exact absurd rfl hne
  · exact Chain.cons ⟨rfl, rfl⟩ (Chain.nil 1)
  · exact Chain.cons ⟨rfl, rfl⟩ (Chain.nil 1)
  · rintro l y ⟨h, -⟩
    exact absurd h (by decide)
  · intro hm
    have h1 : (true : Bool) ∈ (↑[true] : Multiset Bool) := by simp
    rw [hm] at h1
    simp at h1

end LabelUniqueNecessary

section TerminationNecessary

/-- A one-element system with a loop: label determinacy and exchange hold, but
nothing ever terminates. -/
def loopStep : Unit → Unit → Unit → Prop := fun _ _ _ => True

/-- **Termination cannot be dropped.**  With label determinacy and exchange
alone, no chain ever reaches a stuck object, so there is no complete
evolutionary path and no decomposition invariant to speak of. -/
theorem termination_is_necessary :
    ∃ step : Unit → Unit → Unit → Prop,
      (∀ x l₁ l₂ y, step x l₁ y → step x l₂ y → l₁ = l₂) ∧
      (∀ x l₁ y₁ l₂ y₂, step x l₁ y₁ → step x l₂ y₂ → y₁ ≠ y₂ →
        ∃ z, step y₁ l₂ z ∧ step y₂ l₁ z) ∧
      (∀ t ls, Chain step () t ls → ¬ Stuck step t) := by
  refine ⟨loopStep, fun _ l₁ l₂ _ _ _ => Subsingleton.elim l₁ l₂, ?_, ?_⟩
  · rintro x l₁ y₁ l₂ y₂ - - hne
    exact absurd (Subsingleton.elim y₁ y₂) hne
  · intro t ls _ hstuck
    exact hstuck () () trivial

end TerminationNecessary

/-- Positive counterpart of the three independence results: for a genuine
quotient system all complete chains out of a point agree, both in length and in
labels.  (Restatement of the decomposition theorem in the `Chain` language.) -/
theorem chain_jordan_holder {α Λ : Type} (Q : QuotientSystem α Λ) {x t₁ t₂ : α}
    {ls₁ ls₂ : List Λ} (h₁ : Chain Q.step x t₁ ls₁) (h₂ : Chain Q.step x t₂ ls₂)
    (ht₁ : Stuck Q.step t₁) (ht₂ : Stuck Q.step t₂) :
    t₁ = t₂ ∧ (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) ∧ ls₁.length = ls₂.length := by
  rw [← evolPath_iff_chain] at h₁ h₂
  obtain ⟨he, hm⟩ := h₁.jordan_holder h₂ ht₁ ht₂
  exact ⟨he, hm, by simpa using congrArg Multiset.card hm⟩

end Shared.EvolutionaryPath