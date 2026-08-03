import Mathlib

/-! # The bounded lattice universal property attached to a Grothendieck topos

A Grothendieck topos is a category, not a lattice, so the literal assertion that
"every Grothendieck topos is a bounded lattice" is ill-typed.  The standard true
statement is that the subobjects of each object form a complete Heyting algebra
(a frame).  This file formalizes the algebraic universal property shared by all
such subobject frames and gives the frame of open sets as its concrete sheaf-topos
model.

The central universal property says that Heyting implication `a ⇨ c` is the
greatest `x` for which `a ⊓ x ≤ c`; equivalently, meet with `a` is left adjoint
to implication by `a`.
-/

namespace ToposSubobjectLattice

universe u

variable {L : Type u} [Order.Frame L]

/-- The bounded-lattice structure underlying a topos subobject frame. -/
theorem subobject_frame_is_bounded_lattice :
    Nonempty (BoundedOrder L) ∧ Nonempty (Lattice L) :=
  ⟨⟨inferInstance⟩, ⟨inferInstance⟩⟩

/-- **Universal property of Heyting implication.** `a ⇨ c` is the greatest
subobject whose conjunction with `a` factors through `c`. -/
theorem implication_isGreatest (a c : L) :
    IsGreatest {x | a ⊓ x ≤ c} (a ⇨ c) := by
  refine ⟨inf_himp_le, ?_⟩
  intro x hx
  rw [le_himp_iff, inf_comm]
  exact hx

/-- The same universal property in adjunction form. -/
theorem meet_implication_adjunction (a x c : L) :
    a ⊓ x ≤ c ↔ x ≤ a ⇨ c := by
  rw [le_himp_iff, inf_comm]

/-- The universal property determines implication uniquely. -/
theorem implication_unique (a c r : L)
    (hr : IsGreatest {x | a ⊓ x ≤ c} r) : r = a ⇨ c := by
  apply le_antisymm
  · exact (implication_isGreatest a c).2 hr.1
  · exact hr.2 (implication_isGreatest a c).1

/-- Double negation on the intuitionistic subobject frame. -/
def doubleNegation (a : L) : L := aᶜᶜ

/-- Double negation is extensive. -/
theorem le_doubleNegation (a : L) : a ≤ doubleNegation a :=
  le_compl_compl

/-- Double negation is monotone. -/
theorem doubleNegation_monotone : Monotone (doubleNegation : L → L) := by
  intro a b h
  exact compl_le_compl (compl_le_compl h)

/-- Double negation is idempotent. -/
theorem doubleNegation_idempotent (a : L) :
    doubleNegation (doubleNegation a) = doubleNegation a := by
  show aᶜᶜᶜᶜ = aᶜᶜ
  rw [compl_compl_compl]

/-- Double negation preserves binary meets, hence is a nucleus. -/
theorem doubleNegation_inf (a b : L) :
    doubleNegation (a ⊓ b) = doubleNegation a ⊓ doubleNegation b :=
  compl_compl_inf_distrib a b

/-- The lower bound is fixed by double negation. -/
@[simp] theorem doubleNegation_bot : doubleNegation (⊥ : L) = ⊥ := by
  show (⊥ : L)ᶜᶜ = ⊥
  rw [compl_bot, compl_top]

/-- The upper bound is fixed by double negation. -/
@[simp] theorem doubleNegation_top : doubleNegation (⊤ : L) = ⊤ := by
  show (⊤ : L)ᶜᶜ = ⊤
  rw [compl_top, compl_bot]

/-- A regular subobject is one fixed by double negation. -/
def IsRegular (a : L) : Prop := doubleNegation a = a

/-- Regular subobjects are closed under conjunction. -/
theorem isRegular_inf {a b : L} (ha : IsRegular a) (hb : IsRegular b) :
    IsRegular (a ⊓ b) := by
  unfold IsRegular at *
  rw [doubleNegation_inf, ha, hb]

section Opens

variable {X : Type u} [TopologicalSpace X]

/-- The topology endpoint of the bridge: open sets form a bounded lattice with
exactly the same implication universal property as a topos subobject frame. -/
theorem opens_implication_isGreatest (U W : TopologicalSpace.Opens X) :
    IsGreatest {V | U ⊓ V ≤ W} (U ⇨ W) :=
  implication_isGreatest U W

/-- Double negation on opens preserves intersections. -/
theorem opens_doubleNegation_inf (U V : TopologicalSpace.Opens X) :
    doubleNegation (U ⊓ V) = doubleNegation U ⊓ doubleNegation V :=
  doubleNegation_inf U V

end Opens

end ToposSubobjectLattice