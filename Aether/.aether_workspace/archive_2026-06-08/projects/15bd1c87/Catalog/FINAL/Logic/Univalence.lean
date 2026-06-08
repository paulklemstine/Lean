/-
# Univalence Interface

We formalize univalence as an explicit typeclass interface, not a kernel
modification. This allows proving transport consequences and invariance
theorems parametrically.
-/

import Logic.HoTT.Basic
import Logic.HoTT.FundamentalTheorem
import Logic.HoTT.Equiv

universe u v w

namespace HoTT

/-! ## Univalence interface -/

/-- The univalence interface: equivalences between types can be turned
    into equalities, with a computation rule. -/
class Univalence.{uu} where
  ua : {A B : Sort uu} → QEquiv A B → A = B
  ua_transport : ∀ {A B : Sort uu} (e : QEquiv A B) (a : A),
    cast (ua e) a = e.toFun a

/-! ## Transport consequences -/

/-- Transport via univalence: casting along `ua e` is the same as applying
    the equivalence. -/
theorem transport_via_univalence [Univalence.{u}]
    {A B : Sort u} (e : QEquiv A B) (a : A) :
    cast (Univalence.ua e) a = e.toFun a :=
  Univalence.ua_transport e a

/-- Under univalence, equivalent types are literally equal. -/
theorem equiv_implies_eq [Univalence.{u}]
    {A B : Sort u} (e : QEquiv A B) : A = B :=
  Univalence.ua e

/-- Univalence respects contractibility: if `A` is contractible and
    `A ≃q B`, then `B` is contractible. -/
theorem univalence_respects_contr
    {A B : Sort u} (e : QEquiv A B) :
    isContr A → isContr B :=
  qequiv_preserves_isContr e

/-! ## Invariance principles -/

/-- Any type family is invariant under equivalence, given univalence. -/
noncomputable def transport_family [Univalence.{u}]
    (F : Sort u → Sort v)
    {A B : Sort u} (e : QEquiv A B) : F A → F B :=
  cast (congrArg F (Univalence.ua e))

/-- Transport preserves contractibility through type families under univalence. -/
theorem transport_preserves_isContr
    {A B : Sort u} (e : QEquiv A B)
    (h : isContr A) : isContr B :=
  qequiv_preserves_isContr e h

/-- Equivalence preserves subsingletonhood. -/
theorem equiv_preserves_subsingleton_prop
    {A B : Sort u} (e : QEquiv A B)
    (h : ∀ a b : A, a = b) : ∀ a b : B, a = b :=
  qequiv_preserves_subsingleton e h

/-! ## HIT-like interfaces -/

/-- Abstract propositional truncation: a universal property encoding
    of the propositional truncation HIT. -/
class PropTrunc (A : Sort u) where
  trunc : Prop
  inc : A → trunc
  elim : ∀ {P : Prop}, (A → P) → trunc → P

/-- Abstract suspension interface: specified by its universal property. -/
structure SuspensionData (A : Sort u) where
  susp : Sort v
  north : susp
  south : susp
  elim : ∀ {B : Sort w} (n s : B) (m : A → n = s), susp → B
  elim_north : ∀ {B : Sort w} (n s : B) (m : A → n = s),
    elim n s m north = n
  elim_south : ∀ {B : Sort w} (n s : B) (m : A → n = s),
    elim n s m south = s

/-- Elimination theorem for propositional truncation. -/
theorem propTrunc_elim {A : Sort u} [PropTrunc A]
    {P : Prop} (f : A → P) : PropTrunc.trunc (A := A) → P :=
  PropTrunc.elim f

/-! ## 0-Truncated types (Sets in HoTT sense) -/

/-- A type is a set (0-truncated) if its identity types are all propositions,
    i.e., any two proofs of equality are themselves equal. -/
def isSet (A : Sort u) : Prop :=
  ∀ (a b : A) (p q : a = b), p = q

/-- A contractible type is a set. -/
theorem isContr_isSet {A : Sort u} (h : isContr A) : isSet A := by
  intro a b p q
  have hab : a = b := isContr_subsingleton h a b
  subst hab
  have : p = rfl := by
    obtain ⟨c, hc⟩ := h
    have ha := hc a
    subst ha
    simp [eq_comm] at hc
    have hp : p = rfl := by
      cases p; rfl
    exact hp
  have : q = rfl := by
    obtain ⟨c, hc⟩ := h
    have ha := hc a
    subst ha
    simp [eq_comm] at hc
    cases q; rfl
  rw [‹p = rfl›, ‹q = rfl›]

end HoTT