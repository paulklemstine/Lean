import Mathlib

/-!
# Möbius integers: construction of `Z̃` and its ring structure

The *Möbius integers* are defined as the set of **oriented integers**

```
Oriented = ℤ × {+1, -1}
```

modulo the Möbius identification `(n, +1) ~ (-n, -1)`.  Concretely we take the
kernel setoid of the *signed value* map `value (n, ε) = ε · n` and set
`MInt = Oriented / ~`.

The main results of this file are:

* `Mobius.MInt.deck_involutive`, `Mobius.MInt.deck_no_fixed_point`,
  `Mobius.MInt.mk_eq_mk_iff_deck`, `Mobius.MInt.fiber_card`:
  the quotient map `Oriented → MInt` is a genuine free double cover — every
  fibre has *exactly* two points, exchanged by the fixed-point-free deck
  involution `τ (n, ε) = (-n, -ε)`.
* `Mobius.MInt.commRing`: the twisted addition and multiplication (performed
  through the identification) make `MInt` a commutative ring.
* `Mobius.MInt.equivZ`: **structure theorem** — `MInt ≃+* ℤ`.  The Möbius band
  identification collapses the double cover to an ordinary copy of `ℤ`; the
  orientation survives only as the unit group.
* `Mobius.MInt.unitsEquivZMod2`: the unit ("orientation") group of `MInt` is
  cyclic of order two, mirroring `π₁` of the Möbius band.

Everything downstream (factorisation theory, spectra, the zeta function) is
developed in the companion files.
-/

namespace Mobius

/-- An *oriented integer*: a magnitude `n : ℤ` together with an orientation
(`true` stands for `+1`, `false` for `-1`). -/
abbrev Oriented : Type := ℤ × Bool

/-- The signed value `ε · n` of an oriented integer `(n, ε)`. -/
def value (a : Oriented) : ℤ := if a.2 then a.1 else -a.1

@[simp] theorem value_pos (n : ℤ) : value (n, true) = n := rfl
@[simp] theorem value_neg (n : ℤ) : value (n, false) = -n := rfl

/-- The Möbius identification: `(n, +1) ~ (-n, -1)`, i.e. two oriented integers
are identified exactly when they have the same signed value. -/
instance orientSetoid : Setoid Oriented := Setoid.ker value

theorem orient_equiv_iff (a b : Oriented) : a ≈ b ↔ value a = value b := Iff.rfl

/-- The **Möbius integers** `Z̃`. -/
def MInt : Type := Quotient orientSetoid

namespace MInt

/-- The class of an oriented integer in `Z̃`. -/
def mk (a : Oriented) : MInt := Quotient.mk _ a

/-- The signed value of a Möbius integer; well defined by construction. -/
def toZ : MInt → ℤ := Quotient.lift value fun _ _ h => h

@[simp] theorem toZ_mk (a : Oriented) : toZ (mk a) = value a := rfl

theorem mk_surjective : Function.Surjective mk := Quotient.mk_surjective

theorem toZ_injective : Function.Injective toZ := by
  intro x y h
  induction x using Quotient.inductionOn with
  | _ a =>
    induction y using Quotient.inductionOn with
    | _ b => exact Quotient.sound h

theorem toZ_surjective : Function.Surjective toZ := fun n => ⟨mk (n, true), rfl⟩

theorem mk_eq_mk_iff (a b : Oriented) : mk a = mk b ↔ value a = value b :=
  ⟨fun h => congrArg toZ h, fun h => Quotient.sound h⟩

/-- The defining Möbius identification, in the form `(n, +1) = (-n, -1)`. -/
@[simp] theorem mk_flip (n : ℤ) : mk (n, true) = mk (-n, false) := by
  rw [mk_eq_mk_iff]; simp

/-!
### The double cover `Oriented → MInt`
-/

/-- The deck transformation of the cover `Oriented → MInt`: reverse the
orientation and negate the magnitude. -/
def deck (a : Oriented) : Oriented := (-a.1, !a.2)

theorem deck_involutive : Function.Involutive deck := by
  rintro ⟨n, e⟩; simp [deck]

theorem deck_no_fixed_point (a : Oriented) : deck a ≠ a := by
  obtain ⟨n, e⟩ := a
  cases e <;> simp [deck]

@[simp] theorem mk_deck (a : Oriented) : mk (deck a) = mk a := by
  obtain ⟨n, e⟩ := a
  cases e <;> rw [mk_eq_mk_iff] <;> simp [deck, value]

/-- Two oriented integers have the same class iff they are equal or swapped by
the deck transformation: the cover is exactly two-to-one. -/
theorem mk_eq_mk_iff_deck (a b : Oriented) : mk a = mk b ↔ b = a ∨ b = deck a := by
  constructor
  · intro h
    rw [mk_eq_mk_iff] at h
    obtain ⟨n, e⟩ := a
    obtain ⟨m, f⟩ := b
    cases e <;> cases f <;> simp [value, deck] at h ⊢ <;> omega
  · rintro (rfl | rfl) <;> simp

/-- Every fibre of the covering map `Oriented → MInt` has exactly two points. -/
theorem fiber_card (x : MInt) : {a : Oriented | mk a = x}.ncard = 2 := by
  obtain ⟨a, rfl⟩ := mk_surjective x
  have hset : {b : Oriented | mk b = mk a} = {a, deck a} := by
    ext b
    simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    constructor
    · intro hb; exact (mk_eq_mk_iff_deck a b).1 hb.symm
    · rintro (rfl | rfl) <;> simp
  rw [hset, Set.ncard_pair (fun h => deck_no_fixed_point a h.symm)]

/-!
### Twisted arithmetic

Addition and multiplication are performed *through* the identification: the
representatives are pushed to their signed values, combined there, and the
result is given the positive orientation.
-/

instance : Zero MInt := ⟨mk (0, true)⟩
instance : One MInt := ⟨mk (1, true)⟩
instance : Add MInt := ⟨fun x y => mk (toZ x + toZ y, true)⟩
instance : Mul MInt := ⟨fun x y => mk (toZ x * toZ y, true)⟩
instance : Neg MInt := ⟨fun x => mk (-toZ x, true)⟩
instance : Sub MInt := ⟨fun x y => mk (toZ x - toZ y, true)⟩
instance : SMul ℕ MInt := ⟨fun n x => mk ((n : ℤ) * toZ x, true)⟩
instance : SMul ℤ MInt := ⟨fun n x => mk (n * toZ x, true)⟩
instance : Pow MInt ℕ := ⟨fun x n => mk (toZ x ^ n, true)⟩
instance : NatCast MInt := ⟨fun n => mk ((n : ℤ), true)⟩
instance : IntCast MInt := ⟨fun n => mk (n, true)⟩

@[simp] theorem toZ_zero : toZ 0 = 0 := rfl
@[simp] theorem toZ_one : toZ 1 = 1 := rfl
@[simp] theorem toZ_add (x y : MInt) : toZ (x + y) = toZ x + toZ y := rfl
@[simp] theorem toZ_mul (x y : MInt) : toZ (x * y) = toZ x * toZ y := rfl
@[simp] theorem toZ_neg (x : MInt) : toZ (-x) = -toZ x := rfl
@[simp] theorem toZ_sub (x y : MInt) : toZ (x - y) = toZ x - toZ y := rfl
@[simp] theorem toZ_pow (x : MInt) (n : ℕ) : toZ (x ^ n) = toZ x ^ n := rfl
@[simp] theorem toZ_intCast (n : ℤ) : toZ (n : MInt) = n := rfl
@[simp] theorem toZ_natCast (n : ℕ) : toZ (n : MInt) = n := rfl

/-- The twisted operations satisfy all the commutative ring axioms. -/
instance commRing : CommRing MInt :=
  toZ_injective.commRing toZ rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl)
    (fun n x => by change ((n : ℤ) * toZ x) = n • toZ x; rw [nsmul_eq_mul])
    (fun n x => by change (n * toZ x) = n • toZ x; rw [zsmul_eq_mul, Int.cast_id])
    (fun _ _ => rfl) (fun _ => rfl) (fun _ => rfl)

/-- **Structure theorem.**  The Möbius integers form a ring isomorphic to `ℤ`:
the twist is invisible to the ring structure, and only survives in the
orientation (unit) data. -/
def equivZ : MInt ≃+* ℤ where
  toFun := toZ
  invFun := fun n => mk (n, true)
  left_inv := by intro x; apply toZ_injective; rfl
  right_inv := fun _ => rfl
  map_add' := fun _ _ => rfl
  map_mul' := fun _ _ => rfl

@[simp] theorem equivZ_apply (x : MInt) : equivZ x = toZ x := rfl
@[simp] theorem equivZ_symm_apply (n : ℤ) : equivZ.symm n = mk (n, true) := rfl

theorem toZ_eq_zero_iff (x : MInt) : toZ x = 0 ↔ x = 0 :=
  ⟨fun h => toZ_injective (by simpa using h), fun h => by simp [h]⟩

instance : IsDomain MInt :=
  Function.Injective.isDomain (equivZ : MInt →+* ℤ) toZ_injective

instance : IsPrincipalIdealRing MInt :=
  IsPrincipalIdealRing.of_surjective (equivZ.symm : ℤ →+* MInt) equivZ.symm.surjective

/-!
### Orientation reversal and the unit group
-/

/-- Orientation reversal on `Z̃` is exactly ring-theoretic negation. -/
theorem mk_orientation_reverse (n : ℤ) (e : Bool) : mk (n, !e) = -mk (n, e) := by
  apply toZ_injective
  cases e <;> simp [value]

/-- A Möbius integer is a unit iff it is `±1`. -/
theorem isUnit_iff (x : MInt) : IsUnit x ↔ x = 1 ∨ x = -1 := by
  constructor
  · intro h
    have hu : IsUnit (toZ x) := (equivZ : MInt →+* ℤ).isUnit_map h
    rcases Int.isUnit_iff.1 hu with h1 | h1
    · exact Or.inl (toZ_injective (by simpa using h1))
    · exact Or.inr (toZ_injective (by simpa using h1))
  · rintro (rfl | rfl)
    · exact isUnit_one
    · exact isUnit_one.neg

/-- The orientation of a unit, as an element of `ZMod 2`. -/
def unitOrientation (u : MIntˣ) : ZMod 2 := if toZ (u : MInt) = 1 then 0 else 1

theorem units_eq_one_or (u : MIntˣ) : u = 1 ∨ u = -1 := by
  rcases (isUnit_iff (u : MInt)).1 u.isUnit with h | h
  · exact Or.inl (Units.ext h)
  · exact Or.inr (Units.ext (by simpa using h))

theorem neg_one_ne_one : (-1 : MInt) ≠ 1 := by
  intro h
  have := congrArg toZ h
  simp at this

/-- **The orientation group.**  The units of `Z̃` form a cyclic group of order
two — the `ℤ/2` of the Möbius double cover. -/
def unitsEquivZMod2 : MIntˣ ≃* Multiplicative (ZMod 2) where
  toFun u := Multiplicative.ofAdd (unitOrientation u)
  invFun a := if Multiplicative.toAdd a = 0 then 1 else -1
  left_inv u := by
    rcases units_eq_one_or u with rfl | rfl <;>
      simp [unitOrientation, Units.val_neg, show ((1 : ZMod 2) = 0) = False by simp]
  right_inv a := by
    fin_cases a <;> simp [unitOrientation]
  map_mul' u v := by
    rcases units_eq_one_or u with rfl | rfl <;> rcases units_eq_one_or v with rfl | rfl <;>
      simp only [unitOrientation, ← ofAdd_add, Units.val_one, Units.val_neg, toZ_one, toZ_neg,
        neg_mul, neg_neg, one_mul, mul_one] <;> decide

end MInt
end Mobius