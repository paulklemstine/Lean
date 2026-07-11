import Mathlib

/-!
# Anti-Mathematics II: Negating the Axiom of Extensionality

**Mission.** *Anti-Mathematics: What if all axioms were negated?*  This file treats
the negation of the **Axiom of Extensionality**.

## The claim

Dropping (and negating) Extensionality yields a theory of **indistinguishable
sets**: distinct objects may have exactly the same members.  We build an explicit
model, `V = Option ℕ`, in which the Ackermann sets `some n` sit alongside a second,
distinct empty set `none`.  We prove:

* **Failure of Extensionality** (`non_extensionality`): `some 0` and `none` have the
  same (namely, no) members yet differ.
* Indistinguishability `Indist` is an **equivalence relation** (`indist_equiv`).
* Genuine sets are still faithfully separated (`indist_some`, `indist_none`).
* **The obstruction to quotienting** (`membership_not_congruent`): membership is
  *not* a congruence for indistinguishability, so one cannot naively collapse
  indistinguishables to recover an extensional universe.

This uses the Ackermann membership `Mem` of `AckermannModel.lean` (re-declared here
so the file is self-contained).
-/

namespace AntiMath

/-- Ackermann membership on `ℕ` (as in `AckermannModel.lean`). -/
def Mem (a b : ℕ) : Prop := b.testBit a

/-- Extensionality *for the genuine Ackermann sets*. -/
theorem Mem.ext {a b : ℕ} (h : ∀ x, Mem x a ↔ Mem x b) : a = b := by
  apply Nat.eq_of_testBit_eq; intro i; simpa [Mem] using (h i)

/-- A universe with a **duplicate empty set**: `none` is a second, distinct empty
set alongside the Ackermann empty `some 0`. -/
abbrev V := Option ℕ

/-- Membership in the non-extensional universe: `some m` belongs to `some n` iff
`m ∈ n` in the Ackermann sense; the atom `none` is never an element and has no
elements. -/
def NMem : V → V → Prop
  | some m, some n => Mem m n
  | _, _ => False

/-- **Indistinguishability**: two objects with exactly the same members. -/
def Indist (a b : V) : Prop := ∀ x, NMem x a ↔ NMem x b

/-- Indistinguishability is an equivalence relation. -/
theorem indist_equiv : Equivalence Indist where
  refl _ := fun _ => Iff.rfl
  symm h := fun x => (h x).symm
  trans h1 h2 := fun x => (h1 x).trans (h2 x)

/-- **Failure of Extensionality**: two distinct objects with the same members. -/
theorem non_extensionality : ∃ a b : V, a ≠ b ∧ Indist a b := by
  refine ⟨some 0, none, by simp, fun x => ?_⟩
  cases x with
  | none => simp [NMem]
  | some m => simp [NMem, Mem]

/-- Genuine sets remain faithfully classified: `some n` and `some m` are
indistinguishable iff `n = m`. -/
theorem indist_some {n m : ℕ} : Indist (some n) (some m) ↔ n = m := by
  constructor
  · intro h; apply Mem.ext; intro x; have := h (some x); simpa [NMem] using this
  · rintro rfl; exact indist_equiv.refl _

/-- A genuine set `some n` collapses with the atom `none` iff it is the empty
Ackermann set. -/
theorem indist_none {n : ℕ} : Indist (some n) none ↔ n = 0 := by
  constructor
  · intro h; apply Mem.ext; intro x; have hx := h (some x); simpa [NMem, Mem] using hx
  · rintro rfl; intro x; cases x <;> simp [NMem, Mem]

/-- **The obstruction to quotienting.**  Membership is *not* a congruence for
indistinguishability: there are `a ≈ a'` and a set `b` with `a ∈ b` but `a' ∉ b`.
Concretely `some 0 ≈ none`, yet `some 0 ∈ some 1` while `none ∉ some 1`.  Hence in
anti-extensional set theory one cannot collapse indistinguishable objects to
recover an extensional universe. -/
theorem membership_not_congruent :
    ∃ a a' b : V, Indist a a' ∧ NMem a b ∧ ¬ NMem a' b := by
  refine ⟨some 0, none, some 1, indist_none.mpr rfl, ?_, ?_⟩
  · simp [NMem, Mem]
  · simp [NMem]

end AntiMath