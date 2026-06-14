/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.AutoResearch.EckmannHilton

set_option autoImplicit false

/-!
# The Eckmann–Hilton Equational Theory *is* Commutative Monoids

This file extends the abstract Eckmann–Hilton engine of
`Speculative.AutoResearch.EckmannHilton` (the structure `EckmannHiltonData` and the
theorems `EckmannHilton.same_op`, `EckmannHilton.comm`, `EckmannHilton.assoc`) by
identifying its full algebraic content with the theory of **commutative monoids**.

Where the catalog file proved the *equational consequences* of the interchange law,
here we package them into a bona fide `CommMonoid` instance and prove the converse,
obtaining a clean two-way bridge:

> A binary operation with a unit is the vertical composition of some Eckmann–Hilton
> structure **iff** it is the multiplication of a commutative monoid.

This is the precise sense in which "there is no genuinely higher algebra in dimension
two": every doubly-unital interchanging pair of operations is just a commutative
monoid, viewed twice. It is the algebraic shadow of the homotopical fact that the
second homotopy group `π₂` is abelian, and that double loop spaces deloop to
*commutative* (E∞ in the limit) structures.

## Main results

* `EckmannHiltonMonoid.toCommMonoid` — Eckmann–Hilton data endows `X` with a
  `CommMonoid` whose multiplication is the vertical operation `m₁`.
* `EckmannHiltonMonoid.ofCommMonoid` — every commutative monoid is Eckmann–Hilton
  data (both operations = multiplication).
* `EckmannHiltonMonoid.eh_iff_commMonoid` — the operation-level equivalence: the
  two equational theories coincide.
* `EckmannHiltonMonoid.pi_two_commutative` — the abstract "`π₂` is abelian" corollary.
* `EckmannHiltonMonoid.structure_rigidity` — the vertical operation `m₁` alone
  determines the unit and the horizontal operation `m₂`.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: The catalog `EckmannHiltonData` records the *consequences* of the
--   interchange law (same_op / comm / assoc) but stops short of asserting that the
--   whole package is nothing more than a commutative monoid. We conjectured a tight
--   equivalence "EH-data ⇔ CommMonoid" at the level of (operation, unit) pairs.
-- Result: Proved with `sorry = 0`. `toCommMonoid` assembles the catalog lemmas into a
--   `CommMonoid`; `ofCommMonoid` runs the medial law `mul_mul_mul_comm` to verify
--   interchange; `eh_iff_commMonoid` glues the two directions. We further proved
--   `structure_rigidity`: `m₁` determines everything (unit by uniqueness of the
--   monoid identity, `m₂` by `same_op`).
-- Insight: The Eckmann–Hilton argument is not merely "two operations collapse" — the
--   collapse lands *exactly* on the commutative-monoid theory, no weaker and no
--   stronger. Rigidity shows the data has no hidden freedom: the 2-dimensional
--   bookkeeping (m₂, unit) is a function of the 1-dimensional operation m₁.
-- Failure analysis: A naive `simp only [...]` discharge of the interchange field of
--   `ofCommMonoid` made no progress because the stored operation is a lambda; the fix
--   was to `show a*b*(c*d) = a*c*(b*d)` and invoke `mul_mul_mul_comm` directly. The
--   backward direction of `eh_iff_commMonoid` needs the ambient `CommMonoid` instance
--   to be the witness fed to `ofCommMonoid`, after which `m₁ = m` holds by `funext`.

universe u

namespace EckmannHiltonMonoid

variable {X : Type u}

-- !-- Assemble the catalog lemmas `EckmannHilton.assoc` and `EckmannHilton.comm`
-- together with the unit fields of the structure into a `CommMonoid`. -- !--
/-- **Eckmann–Hilton data canonically endows `X` with a commutative monoid**, whose
multiplication is the vertical operation `m₁` and whose unit is the shared unit. -/
def toCommMonoid (E : EckmannHiltonData X) : CommMonoid X where
  mul := E.m₁
  one := E.unit
  one_mul := E.m₁_unit_l
  mul_one := E.m₁_unit_r
  mul_assoc := EckmannHilton.assoc E
  mul_comm := EckmannHilton.comm E

@[simp] theorem toCommMonoid_mul (E : EckmannHiltonData X) (a b : X) :
    (toCommMonoid E).mul a b = E.m₁ a b := rfl

-- !-- Take both operations to be multiplication; interchange is the medial law
-- `(a*b)*(c*d) = (a*c)*(b*d)`, i.e. `mul_mul_mul_comm`. -- !--
/-- **Every commutative monoid is Eckmann–Hilton data**, with both the vertical and
horizontal operations equal to multiplication and the unit equal to `1`. -/
def ofCommMonoid (M : Type u) [CommMonoid M] : EckmannHiltonData M where
  m₁ := (· * ·)
  m₂ := (· * ·)
  unit := 1
  m₁_unit_l := one_mul
  m₁_unit_r := mul_one
  m₂_unit_l := one_mul
  m₂_unit_r := mul_one
  interchange := by
    intro a b c d
    show a * b * (c * d) = a * c * (b * d)
    exact mul_mul_mul_comm a b c d

@[simp] theorem ofCommMonoid_m₁ (M : Type u) [CommMonoid M] (a b : M) :
    (ofCommMonoid M).m₁ a b = a * b := rfl

@[simp] theorem ofCommMonoid_m₂ (M : Type u) [CommMonoid M] (a b : M) :
    (ofCommMonoid M).m₂ a b = a * b := rfl

-- !-- Forward: feed the constructed `toCommMonoid` and read off the operation by
-- `rfl`. Backward: use the ambient instance as witness; `m₁ = m` by `funext`. -- !--
/-- **The Eckmann–Hilton equational theory coincides with that of commutative
monoids.** A binary operation `m` with unit `e` arises as the vertical operation
`m₁` of some Eckmann–Hilton structure on `X` iff `(X, m, e)` underlies a commutative
monoid. -/
theorem eh_iff_commMonoid (m : X → X → X) (e : X) :
    (∃ E : EckmannHiltonData X, E.m₁ = m ∧ E.unit = e) ↔
      (∃ _ : CommMonoid X, (∀ a b : X, a * b = m a b) ∧ (1 : X) = e) := by
  constructor
  · rintro ⟨E, rfl, rfl⟩
    exact ⟨toCommMonoid E, fun _ _ => rfl, rfl⟩
  · rintro ⟨_inst, hmul, hone⟩
    refine ⟨ofCommMonoid X, ?_, hone⟩
    funext a b
    exact hmul a b

-- !-- Combine `EckmannHilton.comm` (commutativity of `m₁`) with
-- `EckmannHilton.same_op` (`m₁ = m₂`). -- !--
/-- **Abstract "`π₂` is abelian".** Reading `m₁` as vertical and `m₂` as horizontal
composition of `2`-cells that share the identity `2`-cell, the two compositions agree
*and* are commutative: `m₁ a b = m₂ b a`. Specialising to a double loop space, this
is the classical statement that the second homotopy group is abelian. -/
theorem pi_two_commutative (E : EckmannHiltonData X) (a b : X) :
    E.m₁ a b = E.m₂ b a := by
  rw [EckmannHilton.comm E, EckmannHilton.same_op E]

-- !-- The unit is the identity of the monoid `toCommMonoid`, hence unique:
-- `E.unit = m₁ E.unit F.unit = F.unit`. Then `m₂ = m₁` on both sides by `same_op`. -- !--
/-- **Rigidity.** The vertical operation `m₁` alone determines the entire
Eckmann–Hilton structure: any two structures sharing `m₁` share their unit and their
horizontal operation `m₂`. Thus the "`2`-dimensional" data carries no information
beyond the `1`-dimensional operation. -/
theorem structure_rigidity (E F : EckmannHiltonData X) (h : E.m₁ = F.m₁) :
    E.unit = F.unit ∧ E.m₂ = F.m₂ := by
  have hunit : E.unit = F.unit := by
    have hkey : E.m₁ E.unit F.unit = F.unit := by rw [E.m₁_unit_l]
    rw [h, F.m₁_unit_r] at hkey
    exact hkey
  refine ⟨hunit, ?_⟩
  funext a b
  rw [← EckmannHilton.same_op E, ← EckmannHilton.same_op F, h]

-- !-- Package the monoid multiplication as `m₁` and `n` as `m₂` with shared unit `1`
-- into `EckmannHiltonData`, then read off `EckmannHilton.comm`. -- !--
/-- **Forced commutativity of a delooped monoid.** If a monoid's multiplication
admits a *second* unital operation `n` (sharing the unit `1`) that interchanges with
it, then the monoid is automatically commutative. This is the algebraic incarnation
of "a connected double loop space is homotopy-commutative": a second compatible
multiplication on a monoid is no extra structure -- it forces, and coincides with,
an abelian one. -/
theorem monoid_comm_of_second_interchange [Monoid X] (n : X → X → X)
    (hl : ∀ x, n 1 x = x) (hr : ∀ x, n x 1 = x)
    (hi : ∀ a b c d, (n a b) * (n c d) = n (a * c) (b * d)) (a b : X) :
    a * b = b * a :=
  EckmannHilton.comm
    { m₁ := (· * ·), m₂ := n, unit := 1,
      m₁_unit_l := one_mul, m₁_unit_r := mul_one,
      m₂_unit_l := hl, m₂_unit_r := hr,
      interchange := hi } a b

end EckmannHiltonMonoid