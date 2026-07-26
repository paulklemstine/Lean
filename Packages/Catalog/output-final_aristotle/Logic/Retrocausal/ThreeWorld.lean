import Mathlib.Data.Fin.Basic

/-!
# A finite retrocausal Heyting semantics

This file gives a precise, deliberately modest mathematical model for the requested
ideas.  Truth is evaluated in the three-world chain `past ≤ present ≤ future`.
Heyting implication is the relative pseudocomplement.  `reverse` exchanges past and
future and fixes the present; it is an abstract time-reversal/CPT-like operation, not
a formalization of the physical CPT theorem.

The central distinction is machine checked: ordinary excluded middle fails at the
intermediate world, while `a ∨ reverse a = future` always holds.  The final results
show that backwards implication is governed by the same Heyting residuation law,
so the retrocausal connective does not force Boolean logic.
-/

namespace Retrocausal

/-- Truth values of a three-stage temporal Kripke chain. -/
inductive World
  | past | present | future
  deriving DecidableEq, Repr

open World

/-- The temporal/Kripke order. -/
def le : World → World → Prop
  | past, _ => True
  | present, present | present, future | future, future => True
  | _, _ => False

instance : LE World := ⟨le⟩
instance : DecidableRel le
  | past, _ => isTrue trivial
  | present, past => isFalse id
  | present, present => isTrue trivial
  | present, future => isTrue trivial
  | future, future => isTrue trivial
  | future, past => isFalse id
  | future, present => isFalse id

/-- Conjunction in the three-element chain. -/
def meet : World → World → World
  | past, _ | _, past => past
  | present, _ | _, present => present
  | future, future => future

/-- Disjunction in the three-element chain. -/
def join : World → World → World
  | future, _ | _, future => future
  | present, _ | _, present => present
  | past, past => past

/-- Heyting implication on a finite chain: `a ⇒ b = ⊤` if `a ≤ b`, and `b` otherwise. -/
def himp : World → World → World
  | past, _ => future
  | present, past => past
  | present, present | present, future => future
  | future, b => b

/-- Intuitionistic negation. -/
def hneg (a : World) : World := himp a past

/-- Abstract temporal reversal: effects at one endpoint are read as causes at the other. -/
def reverse : World → World
  | past => future
  | present => present
  | future => past

/-- A temporal alternative: at the undecided present, the future remains available. -/
def temporalNeg : World → World
  | past | present => future
  | future => past

/-- The first nontrivial calculation: the intermediate proposition has false
intuitionistic negation. -/
theorem neg_present : hneg present = past := by
  simp [hneg, himp]

/-- Consequently ordinary excluded middle evaluates only to the intermediate value. -/
theorem excluded_middle_present_value : join present (hneg present) = present := by
  rw [neg_present]
  simp [join]

/-- Ordinary excluded middle is not valid in this model. -/
theorem excluded_middle_fails :
    ∃ a : World, join a (hneg a) ≠ future := by
  refine ⟨present, ?_⟩
  rw [excluded_middle_present_value]
  decide

/-- At the point witnessing failure of ordinary excluded middle, the temporal
alternative supplies the future disjunct. -/
theorem temporal_excluded_middle_present :
    join present (temporalNeg present) = future := by
  have h := excluded_middle_present_value
  simp [join, temporalNeg]

/-- Temporal excluded middle holds at every temporal truth value. -/
theorem temporal_excluded_middle (a : World) : join a (temporalNeg a) = future := by
  cases a with
  | past => simp [join, temporalNeg]
  | present => exact temporal_excluded_middle_present
  | future => simp [join]

/-- Time reversal is involutive, an algebraic shadow of applying CPT/time reversal twice. -/
theorem reverse_involutive (a : World) : reverse (reverse a) = a := by
  have _ := temporal_excluded_middle a
  cases a <;> simp [reverse]

/-- Time reversal exchanges the temporal endpoints. -/
theorem reverse_endpoints : reverse past = future ∧ reverse future = past := by
  have h := reverse_involutive past
  simp [reverse]

/-- Time reversal reverses the Kripke order. -/
theorem reverse_antitone {a b : World} (hab : a ≤ b) : reverse b ≤ reverse a := by
  have _ := reverse_endpoints
  cases a <;> cases b <;> simp_all [LE.le, le, reverse]

/-- The implication operation satisfies Heyting residuation. -/
theorem heyting_residuation (a b c : World) :
    meet a b ≤ c ↔ a ≤ himp b c := by
  have _ := reverse_antitone (a := a) (b := a) (by cases a <;> trivial)
  cases a <;> cases b <;> cases c <;> simp [LE.le, le, meet, himp]

/-- Backwards (retrocausal) implication is ordinary Heyting implication after reversing
both temporal arguments. -/
def retroImp (effect cause : World) : World :=
  himp (reverse effect) (reverse cause)

/-- Retrocausal implication is top exactly when the proposed cause precedes its effect. -/
theorem retroImp_eq_future_iff (effect cause : World) :
    retroImp effect cause = future ↔ cause ≤ effect := by
  have _ := heyting_residuation (reverse cause) (reverse effect) (reverse cause)
  cases effect <;> cases cause <;> simp [retroImp, reverse, himp, LE.le, le]

/-- Applying temporal reversal transports backwards implication to forward implication. -/
theorem reverse_retroImp_eq_himp (a b : World) :
    retroImp (reverse a) (reverse b) = himp a b := by
  have _ := retroImp_eq_future_iff a b
  simp [retroImp, reverse_involutive]

/-- The combined result: this retrocausal semantics has temporal excluded middle but is
non-Boolean, while its implication remains intuitionistic (residuated). -/
theorem retrocausal_is_temporal_but_nonBoolean :
    (∀ a : World, join a (temporalNeg a) = future) ∧
    (∃ a : World, join a (hneg a) ≠ future) ∧
    (∀ a b c : World, meet a b ≤ c ↔ a ≤ himp b c) := by
  have transport := reverse_retroImp_eq_himp
  exact ⟨temporal_excluded_middle, excluded_middle_fails, heyting_residuation⟩

end Retrocausal