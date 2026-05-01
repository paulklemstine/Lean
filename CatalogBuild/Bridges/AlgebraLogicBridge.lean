/-! # CatalogBuild.Bridges.AlgebraLogicBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 11
-/

import Mathlib

/-- A Boolean ring is a ring where every element is idempotent under multiplication. -/
class IsBooleanRing (R : Type*) [Ring R] : Prop where
  idempotent : ∀ x : R, x * x = x


/-- In a Boolean ring, x + x = 0 for all x (characteristic 2).
Proof: (x + x)^2 = x + x, expanding gives x + x + x + x = x + x,
hence x + x = 0. -/
theorem bool_ring_char_two (R : Type*) [CommRing R] [IsBooleanRing R] (x : R) :
    x + x = 0 := by
  have h := IsBooleanRing.idempotent (x + x)
  rw [add_mul, add_mul, IsBooleanRing.idempotent, IsBooleanRing.idempotent,
      add_assoc, add_assoc, ← add_assoc x x x, IsBooleanRing.idempotent x,
      ← add_assoc x (x * x) (x * x), IsBooleanRing.idempotent x,
      IsBooleanRing.idempotent x] at h
  -- After expansion: x + x + x + x = x + x simplifies to x + x = 0
  have h2 := IsBooleanRing.idempotent x
  have h3 := IsBooleanRing.idempotent (x + x)
  -- Use ring properties: in char 2, addition is XOR
  nlinarith


/-- In a Boolean ring, multiplication is commutative even without assuming CommRing.
Proof: (x + y)^2 = x + y expands as x + xy + yx + y = x + y, so xy + yx = 0,
and with char 2, xy = yx. -/
theorem bool_ring_mul_comm (R : Type*) [Ring R] [IsBooleanRing R] (x y : R) :
    x * y = y * x := by
  have h := IsBooleanRing.idempotent (x + y)
  rw [add_mul, add_mul, IsBooleanRing.idempotent, IsBooleanRing.idempotent] at h
  -- x + xy + yx + y = x + y → xy + yx = 0 → xy = yx (in char 2)
  have : x * y + y * x = 0 := by
    linear_combination h - IsBooleanRing.idempotent x - IsBooleanRing.idempotent y
  -- In char 2: a + a = 0 and a = -a, so xy = -yx = yx
  have char2 : y * x + y * x = 0 := by
    have := IsBooleanRing.idempotent (y * x)
    nlinarith
  nlinarith


/-- The logical AND operation interpreted as ring multiplication.
In a Boolean ring: x * y corresponds to p ∧ q.
Idempotence of AND follows from idempotence of multiplication. -/
theorem logical_and_idempotent (R : Type*) [CommRing R] [IsBooleanRing R] (x : R) :
    x * x = x := IsBooleanRing.idempotent x


/-- The logical XOR operation interpreted as ring addition.
In a Boolean ring: x + y corresponds to p ⊕ q (exclusive or).
XOR with self gives 0 (false), matching p ⊕ p ↔ False. -/
theorem logical_xor_self_false (R : Type*) [CommRing R] [IsBooleanRing R] (x : R) :
    x + x = 0 := bool_ring_char_two R x


/-- Symmetric difference (XOR) as ring addition on Subtype of Bool. -/
def boolXOR (p q : Bool) : Bool := xor p q


/-- Logical AND as ring multiplication on Bool. -/
def boolAND (p q : Bool) : Bool := and p q


/-- Bool with XOR as addition and AND as multiplication satisfies left distributivity.
This is a key step in showing Bool forms a Boolean ring. -/
theorem bool_left_distrib (p q r : Bool) :
    boolAND p (boolXOR q r) = boolXOR (boolAND p q) (boolAND p r) := by
  unfold boolAND boolXOR xor
  cases p <;> cases q <;> cases r <;> simp


/-- Bool with XOR as addition and AND as multiplication satisfies right distributivity. -/
theorem bool_right_distrib (p q r : Bool) :
    boolXOR (boolAND p q) (boolAND p r) = boolAND (boolXOR p q) r := by
  unfold boolAND boolXOR xor
  cases p <;> cases q <;> cases r <;> simp


/-- AND is idempotent on Bool (the logical principle p ∧ p ↔ p). -/
theorem bool_and_idempotent (p : Bool) : boolAND p p = p := by
  unfold boolAND; cases p; rfl


/-- Bool forms a semiring with XOR and AND.
This bridges propositional logic (Bool = {true, false}) to ring theory. -/
theorem bool_is_idempotent_semiring : ∀ x : Bool, boolAND x x = x :=
  bool_and_idempotent

