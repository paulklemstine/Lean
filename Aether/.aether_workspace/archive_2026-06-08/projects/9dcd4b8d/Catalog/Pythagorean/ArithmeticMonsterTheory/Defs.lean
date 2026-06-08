/-
# Arithmetic Monster Theory: Core Definitions

This file establishes the foundational definitions for the theory of digit-interaction
under multiplication in arbitrary bases. It defines digit bags, carry-free addition,
digit complexity, and the novel concept of a **Digit Interaction Signature** — an algebraic
structure capturing how digit representations compose under arithmetic operations.

## References

Builds on `Catalog/MachineLearning/ArithmeticMonsters/Defs.lean`.
-/
import Mathlib

open Finset BigOperators

namespace ArithMonster

/-! ## Digit Infrastructure -/

/-- The digit bag of `n` in base `b`: counts occurrences of each digit `d ∈ Fin b`. -/
def digitBag (b : ℕ) (n : ℕ) : Fin b → ℕ :=
  fun d => (Nat.digits b n).count d.val

/-- Total number of digits (length of base-b representation). -/
def digitLen (b : ℕ) (n : ℕ) : ℕ := (Nat.digits b n).length

/-- Sum of digits of `n` in base `b`. -/
def digitSum (b : ℕ) (n : ℕ) : ℕ := (Nat.digits b n).sum

/-- The digit overlap between two numbers: counts shared digit occurrences. -/
def digitOverlap (b : ℕ) (m n : ℕ) : ℕ :=
  ∑ d : Fin b, min (digitBag b m d) (digitBag b n d)

/-- Two numbers are digit-disjoint in base `b` if they share no digits. -/
def DigitDisjoint (b : ℕ) (m n : ℕ) : Prop :=
  digitOverlap b m n = 0

instance (b m n : ℕ) : Decidable (DigitDisjoint b m n) :=
  inferInstanceAs (Decidable (_ = 0))

/-! ## Vampire and Monster Definitions -/

/-- A vampire pair `(x, y)` for `v` in base `b`: `v = x * y` and
    the digit bag of `v` equals the sum of digit bags of `x` and `y`. -/
def IsVampire (b : ℕ) (v x y : ℕ) : Prop :=
  v = x * y ∧ ∀ d : Fin b, digitBag b v d = digitBag b x d + digitBag b y d

instance (b v x y : ℕ) : Decidable (IsVampire b v x y) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-! ## Novel Concept: Carry-Free Addition -/

/-- Addition of `a` and `b` is carry-free in base `bs` if every digit pair sums to
    less than `bs`. We check up to the maximum of their digit lengths. -/
def CarryFree (bs a b : ℕ) : Prop :=
  ∀ i : ℕ, (Nat.digits bs a).getD i 0 + (Nat.digits bs b).getD i 0 < bs

/-! ## Novel Structure: Digit Interaction Signature -/

/-- A digit interaction signature captures how the digits of a product relate to
    the digits of its factors. It records:
    - `preserved`: digits appearing in both product and factors
    - `created`: digits in product but not factors
    - `destroyed`: digits in factors but not product -/
structure DigitSignature (b : ℕ) where
  preserved : ℕ
  created : ℕ
  destroyed : ℕ
  deriving Repr, DecidableEq

/-- Compute the digit interaction signature for a multiplication v = x * y. -/
noncomputable def digitSignature (b : ℕ) (v x y : ℕ) : DigitSignature b :=
  let bagV := digitBag b v
  let bagXY := fun d => digitBag b x d + digitBag b y d
  { preserved := ∑ d : Fin b, min (bagV d) (bagXY d)
    created := ∑ d : Fin b, (bagV d - bagXY d)
    destroyed := ∑ d : Fin b, (bagXY d - bagV d) }

/-- A multiplication is digit-preserving if no digits are created or destroyed
    (i.e., it is a vampire multiplication). -/
def IsDigitPreserving (b : ℕ) (v x y : ℕ) : Prop :=
  (digitSignature b v x y).created = 0 ∧ (digitSignature b v x y).destroyed = 0

/-- The digit complexity of `n` in base `b`: the number of distinct digits used. -/
noncomputable def digitComplexity (b : ℕ) (n : ℕ) : ℕ :=
  ((Nat.digits b n).toFinset).card

end ArithMonster