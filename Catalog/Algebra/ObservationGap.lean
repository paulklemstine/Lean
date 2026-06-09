import Mathlib

/-!
# The Observation Gap: Algebraic Foundations of Functional Indistinguishability

We formalize the mathematical structure underlying the problem of distinguishing
internal states from external observations. The central question: when can a finite
collection of observations fully determine the internal state of a system?

## Main Results

1. **`observation_pigeonhole`**: Any system of `n` Boolean observations on a type with
   more than `2^n` elements must contain a "twin pair" — two distinct elements that are
   observationally indistinguishable.

2. **`observation_quotient_card_le`**: The quotient by observational equivalence has at most
   `2^n` classes, bounding the discriminative power of any finite observation system.

3. **`refinement_monotone_separation`**: Refining an observation system (adding predicates)
   can only increase discriminative power — the quotient map is surjective.

4. **`observation_can_suffice`**: When `|α| = 2^n`, observations CAN distinguish all
   elements — establishing the tight boundary of the pigeonhole result.

5. **`generalized_observation_pigeonhole`**: Generalization to observations valued in an
   arbitrary finite type `β`, with bound `|β|^n`.
-/

namespace ObservationGap

-- ============================================================================
-- Core Definitions
-- ============================================================================

/-- An observation system consists of `n` Boolean predicates on a type `α`. -/
structure ObsSys (α : Type*) (n : ℕ) where
  pred : Fin n → α → Bool

/-- The observation profile maps each element to its tuple of predicate values. -/
def ObsSys.profile {α : Type*} {n : ℕ} (O : ObsSys α n) (a : α) : Fin n → Bool :=
  fun i => O.pred i a

/-- Two elements are observationally indistinguishable (twins). -/
def ObsSys.twins {α : Type*} {n : ℕ} (O : ObsSys α n) (a b : α) : Prop :=
  O.profile a = O.profile b

/-- The twin relation is an equivalence relation. -/
theorem observation_equiv_is_equivalence {α : Type*} {n : ℕ} (O : ObsSys α n) :
    Equivalence (O.twins) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- The setoid induced by observational equivalence. -/
def ObsSys.setoid {α : Type*} {n : ℕ} (O : ObsSys α n) : Setoid α where
  r := O.twins
  iseqv := observation_equiv_is_equivalence O

/-- Fintype instance for the observation quotient. -/
noncomputable instance ObsSys.quotientFintype {α : Type*} [Fintype α] {n : ℕ}
    (O : ObsSys α n) : Fintype (Quotient O.setoid) := by
  letI : DecidableRel O.setoid.r := fun a b =>
    inferInstanceAs (Decidable (O.profile a = O.profile b))
  exact Quotient.fintype O.setoid

-- ============================================================================
-- Theorem 1: Observation Pigeonhole
-- ============================================================================

-- !-- Uses Fintype.exists_ne_map_eq_of_card_lt on the profile map. The codomain
-- Fin n → Bool has cardinality 2^n, so if |α| > 2^n, profile is not injective. -- !--

/-- **Observation Pigeonhole Theorem**: Any system of `n` Boolean observations on a
    finite type with more than `2^n` elements must contain a twin pair — two distinct
    elements that are observationally indistinguishable. -/
theorem observation_pigeonhole {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}
    (O : ObsSys α n) (hcard : 2 ^ n < Fintype.card α) :
    ∃ a b : α, a ≠ b ∧ O.twins a b := by
  convert Fintype.exists_ne_map_eq_of_card_lt _ _
  exacts [inferInstance, inferInstance, by simpa [Fintype.card_pi] using hcard]

-- ============================================================================
-- Theorem 2: Quotient Cardinality Bound
-- ============================================================================

-- !-- The profile map descends to an injection on the quotient. Since the codomain has
-- 2^n elements, the quotient has at most 2^n equivalence classes. -- !--

/-- The profile map factors through the quotient injectively. -/
theorem profile_factors_injective {α : Type*} {n : ℕ} (O : ObsSys α n) :
    ∃ f : Quotient O.setoid → (Fin n → Bool),
      Function.Injective f ∧
      ∀ a : α, f (Quotient.mk O.setoid a) = O.profile a := by
  refine ⟨fun q => Quotient.liftOn' q (fun x => O.profile x) ?_, ?_, fun _ => rfl⟩
  · intro a b hab; exact hab
  · rintro ⟨a₁⟩ ⟨a₂⟩ h
    exact Quotient.sound h

/-- **Quotient Cardinality Bound**: The observation quotient has at most `2^n` classes. -/
theorem observation_quotient_card_le {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}
    (O : ObsSys α n) :
    Fintype.card (Quotient O.setoid) ≤ 2 ^ n := by
  obtain ⟨f, hf, _⟩ := profile_factors_injective O
  simpa using Fintype.card_le_of_injective f hf

-- ============================================================================
-- Theorem 3: Refinement Monotonicity
-- ============================================================================

/-- An observation system `O₂` refines `O₁` if `O₂`-equivalence implies `O₁`-equivalence. -/
def ObsSys.refines {α : Type*} {m n : ℕ} (O₂ : ObsSys α m) (O₁ : ObsSys α n) : Prop :=
  ∀ a b : α, O₂.twins a b → O₁.twins a b

-- !-- Define a map on quotients via Quotient.lift. Well-definedness follows from the
-- refinement condition. Surjectivity follows because every quotient class has a rep. -- !--

/-- **Refinement Surjection**: If `O₂` refines `O₁`, there is a surjection from
    `O₂`-quotient to `O₁`-quotient. -/
theorem refinement_monotone_separation {α : Type*} {m n : ℕ}
    (O₁ : ObsSys α n) (O₂ : ObsSys α m) (href : O₂.refines O₁) :
    ∃ f : Quotient O₂.setoid → Quotient O₁.setoid, Function.Surjective f := by
  use fun q => Quotient.lift (fun a => Quotient.mk O₁.setoid a)
    (fun a b hab => Quotient.sound <| href a b <| by simpa using hab) q
  exact fun q => Quotient.inductionOn' q fun a => ⟨⟦a⟧, rfl⟩

-- ============================================================================
-- Theorem 4: Concrete Example and Boundary
-- ============================================================================

/-- **Concrete Twin Example**: For any single Boolean predicate on `Fin 3`,
    there exist two distinct elements with the same predicate value. -/
theorem concrete_twin_fin3 (p : Fin 3 → Bool) :
    ∃ a b : Fin 3, a ≠ b ∧ p a = p b := by
  native_decide +revert

-- !-- Construct O using bit extraction: pred i a = a.val.testBit i. Two elements
-- with identical first n bits in Fin (2^n) must be equal. -- !--

/-- **Sufficiency Boundary**: When `|α| = 2^n`, an observation system CAN
    distinguish all elements. Uses the binary encoding of `Fin (2^n)`. -/
theorem observation_can_suffice (n : ℕ) :
    ∃ O : ObsSys (Fin (2 ^ n)) n,
      ∀ a b : Fin (2 ^ n), O.twins a b → a = b := by
  use ⟨fun i a => a.val.testBit i⟩
  unfold ObsSys.twins
  simp +decide [funext_iff, ObsSys.profile]
  intro a b h
  exact Fin.ext <| Nat.eq_of_testBit_eq fun i =>
    if hi : i < n then h ⟨i, hi⟩
    else by
      rw [Nat.testBit_eq_false_of_lt, Nat.testBit_eq_false_of_lt] <;>
        linarith [Fin.is_lt a, Fin.is_lt b,
          Nat.pow_le_pow_right two_pos (show n ≤ i from le_of_not_gt hi)]

-- ============================================================================
-- Generalization: Arbitrary Observation Codomains
-- ============================================================================

/-- A generalized observation system with values in an arbitrary finite type `β`. -/
structure GenObsSys (α β : Type*) (n : ℕ) where
  pred : Fin n → α → β

def GenObsSys.profile {α β : Type*} {n : ℕ} (O : GenObsSys α β n) (a : α) : Fin n → β :=
  fun i => O.pred i a

def GenObsSys.twins {α β : Type*} {n : ℕ} (O : GenObsSys α β n) (a b : α) : Prop :=
  O.profile a = O.profile b

-- !-- Same argument as observation_pigeonhole but with |β|^n in place of 2^n. -- !--

/-- **Generalized Pigeonhole**: For observations valued in a `k`-element type,
    `n` observations cannot distinguish more than `k^n` elements. -/
theorem generalized_observation_pigeonhole {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq α] {n : ℕ}
    (O : GenObsSys α β n)
    (hcard : Fintype.card β ^ n < Fintype.card α) :
    ∃ a b : α, a ≠ b ∧ O.twins a b := by
  convert Fintype.exists_ne_map_eq_of_card_lt _ _
  exacts [inferInstance, inferInstance, by simpa [Fintype.card_pi] using hcard]

end ObservationGap