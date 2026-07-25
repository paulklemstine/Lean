import Mathlib.SetTheory.Cardinal.Aleph
import Mathlib.SetTheory.Cardinal.Continuum

/-!
# Different sizes of infinity

This file records Cantor's diagonal theorem, the aleph and beth hierarchies, a
precise formulation of the continuum hypothesis, and a type-theoretic Hartogs
construction.  The diagonal argument is stated directly for functions, so its
mathematical content does not depend on cardinal arithmetic.
-/

open Function Set
open Cardinal Ordinal

universe u

namespace InfinityHierarchy

/-- Cantor's diagonal set associated to a proposed enumeration of all subsets. -/
def diagonal {α : Type u} (f : α → Set α) : Set α := {x | x ∉ f x}

/-- Cantor's theorem in its direct diagonal form: no function enumerates all subsets.
-/
theorem cantor_no_surjection (α : Type u) (f : α → Set α) : ¬ Surjective f := by
  intro h_surj
  obtain ⟨x, hx⟩ : ∃ x : α, f x = {x | x ∉ f x} := by
    exact h_surj _;
  exact absurd ( Set.ext_iff.mp hx x ) ( by tauto )

/-- Consequently, no type has the same cardinality as its power set.
-/
theorem no_equiv_powerset (α : Type u) : ¬ Nonempty (α ≃ Set α) := by
  intro h
  obtain ⟨e⟩ := h;
  exact cantor_no_surjection α e.toFun e.surjective

/-- The power-set type has strictly larger cardinality than the original type.
-/
theorem powerset_strictly_larger (α : Type u) : #α < #(Set α) := by
  simpa using Cardinal.cantor #α

/-- The power set of a set is strictly larger than that set itself.
-/
theorem set_powerset_strictly_larger {α : Type u} (s : Set α) : #s < #(𝒫 s) := by
  rw [ Cardinal.mk_powerset ] ; exact Cardinal.cantor _;

/-- The zeroth aleph is the cardinality of the natural numbers.
-/
theorem aleph_zero_is_countable : aleph (0 : Ordinal.{u}) = #(ULift.{u} ℕ) := by
  simp

/-- Aleph-one is strictly larger than aleph-zero.
-/
theorem aleph_zero_lt_aleph_one :
    aleph (0 : Ordinal.{u}) < aleph (1 : Ordinal.{u}) := by
  exact Cardinal.aleph_lt_aleph.mpr zero_lt_one

/-- Aleph-one is the successor cardinal of aleph-zero.
-/
theorem aleph_one_eq_successor :
    aleph (1 : Ordinal.{u}) = Order.succ (aleph0 : Cardinal.{u}) := by
  rw [← Ordinal.succ_zero, Cardinal.aleph_succ, Cardinal.aleph_zero]

/-- Every step of the beth hierarchy is a strict increase.
-/
theorem beth_strict_step (o : Ordinal.{u}) : beth o < beth (Order.succ o) := by
  convert Cardinal.cantor _ using 1;
  convert Cardinal.beth_succ o

/-- The first beth number is the power of two to aleph-zero.
-/
theorem beth_one_eq_two_power_aleph0 :
    beth (1 : Ordinal.{u}) = 2 ^ (aleph0 : Cardinal.{u}) := by
  rw [← Ordinal.succ_zero, Cardinal.beth_succ, Cardinal.beth_zero]

/-- The continuum hypothesis, expressed as equality of aleph-one and the continuum. -/
def ContinuumHypothesis : Prop :=
  continuum = aleph (1 : Ordinal.{u})

/-- CH is equivalently the assertion that the first beth equals the first aleph.
-/
theorem continuumHypothesis_iff_beth_one :
    ContinuumHypothesis.{u} ↔ beth (1 : Ordinal.{u}) = aleph (1 : Ordinal.{u}) := by
  rw [ eq_comm ];
  rw [ eq_comm, Cardinal.beth_one ];
  rfl

/-- Cantor's theorem gives the unconditional lower bound aleph-one ≤ continuum.
-/
theorem aleph_one_le_continuum :
    aleph (1 : Ordinal.{u}) ≤ continuum := by
  exact Cardinal.aleph_one_le_continuum

/-- A type representing the successor cardinal of the cardinality of `α`.
This is the type-theoretic Hartogs construction used in this development. -/
def HartogsType (α : Type u) : Type u := (Order.succ (#α)).ord.ToType

/-- The Hartogs type has exactly the successor cardinal of `α`.
-/
theorem mk_hartogsType (α : Type u) :
    #(HartogsType α) = Order.succ (#α) := by
  convert Cardinal.mk_ord_toType _

/-- Hartogs' conclusion: the constructed well-ordered type cannot inject into `α`.
-/
theorem no_embedding_hartogs (α : Type u) :
    ¬ Nonempty (HartogsType α ↪ α) := by
  intro h
  obtain ⟨f⟩ := h
  have h_card : #(HartogsType α) ≤ #α := by
    exact Cardinal.mk_le_of_injective f.injective;
  exact h_card.not_gt ( mk_hartogsType α ▸ Order.lt_succ _ )

/-- Nevertheless `α` embeds into its Hartogs type, exhibiting a strict size increase.
-/
theorem embedding_into_hartogs (α : Type u) :
    Nonempty (α ↪ HartogsType α) := by
  have h_card_order : Cardinal.mk α < Cardinal.mk (HartogsType α) := by
    have h_card_order : Cardinal.mk α < Order.succ (Cardinal.mk α) := by
      exact Order.lt_succ _
    convert h_card_order using 1;
    convert mk_hartogsType α;
  convert Cardinal.lift_mk_le'.mp ( Cardinal.lift_le.2 h_card_order.le ) using 1

end InfinityHierarchy