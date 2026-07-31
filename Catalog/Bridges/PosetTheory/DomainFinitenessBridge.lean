import Mathlib
import Bridges.NumberTheoryBridge

/-! # Domain Finiteness Bridge

A self-contained, non-circular development of the bridge from order-theoretic
*finiteness* to algebraic *field structure*.

The headline result (`domain_isField`) states that every finite integral domain is a
field.  Crucially, we do **not** invoke Mathlib's `Finite.isField_of_domain` (or any
other pre-existing theorem that already produces the field structure).  Instead we
rebuild the inverse from two ingredients only:

* **cancellation** in an integral domain (left multiplication by a nonzero element is
  injective), and
* the **pigeonhole principle** for finite types
  (`Finite.injective_iff_surjective`): an injective self-map of a finite type is
  surjective.

From surjectivity we constructively extract, for every nonzero `a`, a `b` with
`a * b = 1`, which is exactly the data demanded by `IsField`.

We then derive the standard consequences:

* every nonzero element satisfies `a ^ (q - 1) = 1` with `q = Fintype.card R`
  (`pow_card_sub_one_eq_one`),
* the unit group `Rˣ` is cyclic (`units_isCyclic`), and
* the specialization to `ZMod p`, connecting to Wilson's theorem through
  `Bridges/NumberTheoryBridge.lean`.
-/

namespace DomainFinitenessBridge

variable {R : Type*} [CommRing R] [IsDomain R] [Fintype R]

/-! ## Section 1: Left multiplication is bijective -/

omit [Fintype R] in
/-- **Cancellation.** In an integral domain, left multiplication by a nonzero element
`a` is injective.  This is purely the cancellation property `mul_left_cancel₀`.
(Finiteness is not needed here, so `[Fintype R]` is omitted.) -/
theorem mulLeft_injective {a : R} (ha : a ≠ 0) :
    Function.Injective (fun x : R => a * x) := by
  intro x y h
  exact mul_left_cancel₀ ha h

/-- **Pigeonhole.** Left multiplication by a nonzero element of a *finite* domain is
bijective: it is injective by cancellation, hence surjective by the pigeonhole
principle `Finite.injective_iff_surjective`. -/
theorem mulLeft_bijective {a : R} (ha : a ≠ 0) :
    Function.Bijective (fun x : R => a * x) :=
  ⟨mulLeft_injective ha, Finite.injective_iff_surjective.mp (mulLeft_injective ha)⟩

/-! ## Section 2: Constructive inverse -/

/-- **Constructive inverse.** Every nonzero element of a finite integral domain has a
right inverse.  The witness comes from surjectivity of left multiplication. -/
theorem exists_inverse {a : R} (ha : a ≠ 0) : ∃ b : R, a * b = 1 := by
  obtain ⟨b, hb⟩ := (mulLeft_bijective ha).surjective 1
  exact ⟨b, hb⟩

/-! ## Section 3: The core bridge -/

/-- **Domain Finiteness Bridge.** A finite integral domain is a field, witnessed by the
explicitly constructed inverses of `exists_inverse`.  Proved without
`Finite.isField_of_domain`. -/
theorem domain_isField : IsField R where
  exists_pair_ne := exists_pair_ne R
  mul_comm := mul_comm
  mul_inv_cancel := fun ha => exists_inverse ha

/-! ## Section 4: Fermat-type exponent and cyclic units -/

/-- **Fermat-type identity.** Every nonzero element of a finite integral domain satisfies
`a ^ (q - 1) = 1`, where `q = Fintype.card R`.  Proved by transporting `a` into the unit
group via `Units.mk0` and applying `pow_card_eq_one` together with `Fintype.card_units`.
The field structure used here is the one we built in `domain_isField` — no pre-existing
finite-field theorem is invoked. -/
theorem pow_card_sub_one_eq_one {a : R} (ha : a ≠ 0) :
    a ^ (Fintype.card R - 1) = 1 := by
  letI : Field R := domain_isField.toField
  classical
  have hu : (Units.mk0 a ha) ^ Fintype.card Rˣ = 1 := pow_card_eq_one
  rw [Fintype.card_units] at hu
  have h2 := congrArg (Units.val) hu
  simpa using h2

/-- **Cyclic units.** The unit group of a finite integral domain is cyclic.  We endow `R`
with the field structure built in `domain_isField` and conclude via the cyclicity of the
unit group of a finite field. -/
theorem units_isCyclic : IsCyclic Rˣ := by
  letI : Field R := domain_isField.toField
  infer_instance

/-! ## Section 5: Connection to `ZMod p` and Wilson's theorem -/

section ZMod

variable (p : ℕ) [Fact (Nat.Prime p)]

/-- The bridge specializes: `ZMod p` is a field for prime `p`. -/
theorem zmod_isField : IsField (ZMod p) := domain_isField

/-- Fermat's little theorem (element form) recovered from the bridge:
`a ^ (p - 1) = 1` for every nonzero `a : ZMod p`. -/
theorem zmod_pow_card_sub_one {a : ZMod p} (ha : a ≠ 0) : a ^ (p - 1) = 1 := by
  have h := pow_card_sub_one_eq_one (R := ZMod p) ha
  rwa [ZMod.card] at h

/-- The unit group `(ZMod p)ˣ` is cyclic. -/
theorem zmod_units_isCyclic : IsCyclic (ZMod p)ˣ := units_isCyclic

/-- **Wilson's theorem**, imported through the number-theory bridge:
`(p - 1)! ≡ -1 (mod p)`. -/
theorem wilson : ((p - 1).factorial : ZMod p) = -1 :=
  NumberTheoryBridge.wilsons_theorem p

end ZMod

end DomainFinitenessBridge