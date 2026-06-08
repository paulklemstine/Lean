/-
# Arithmetic Monsters: A Formal Theory of Digit-Interaction under Multiplication

This file defines the core concepts of "arithmetic creature theory" — a formal framework
for studying how multiplication interacts with digit representations in arbitrary bases.

The key abstraction is the **digit bag** (digit multiset profile): for a natural number `n`
in base `b`, we track the multiplicity of each digit. This converts ad hoc decimal folklore
(vampire numbers, etc.) into a reusable finite invariant.
-/
import Mathlib

open Finset BigOperators

namespace ArithmeticMonsters

/-! ## Digit Infrastructure -/

/-- The digit bag of `n` in base `b`: counts occurrences of each digit `d ∈ Fin b`.
    For `b ≥ 2`, this is well-defined since `Nat.digits b n` only contains values in `{0, ..., b-1}`.
    For `b < 2`, we define it as the zero function. -/
def digitBag (b : ℕ) (n : ℕ) : Fin b → ℕ :=
  fun d => (Nat.digits b n).count d.val

/-- Total number of digits (length of base-b representation). -/
def digitLen (b : ℕ) (n : ℕ) : ℕ := (Nat.digits b n).length

/-- The digit overlap between two numbers: counts shared digit occurrences. -/
def digitOverlap (b : ℕ) (m n : ℕ) : ℕ :=
  ∑ d : Fin b, min (digitBag b m d) (digitBag b n d)

/-- Two numbers are digit-disjoint in base `b` if they share no digits. -/
def DigitDisjoint (b : ℕ) (m n : ℕ) : Prop :=
  digitOverlap b m n = 0

instance (b m n : ℕ) : Decidable (DigitDisjoint b m n) :=
  inferInstanceAs (Decidable (_ = 0))

/-! ## Monster Definitions -/

/-- A general monster relation: `v = x * y` and a digit-bag relation `R` holds. -/
def IsMonsterRel (b : ℕ) (R : (Fin b → ℕ) → (Fin b → ℕ) → (Fin b → ℕ) → Prop)
    (v x y : ℕ) : Prop :=
  v = x * y ∧ R (digitBag b v) (digitBag b x) (digitBag b y)

/-- A vampire pair `(x, y)` for `v` in base `b`: the product `v = x * y` and
    the digit bag of `v` equals the sum of digit bags of `x` and `y`. -/
def IsVampire (b : ℕ) (v x y : ℕ) : Prop :=
  v = x * y ∧ ∀ d : Fin b, digitBag b v d = digitBag b x d + digitBag b y d

/-- A ghost triple: the product shares no digits with either factor. -/
def IsGhost (b : ℕ) (v x y : ℕ) : Prop :=
  v = x * y ∧ DigitDisjoint b v x ∧ DigitDisjoint b v y

/-- A werewolf pair: the total digit overlap between the product and its factors
    equals exactly `k`. -/
def IsWerewolf (b : ℕ) (k v x y : ℕ) : Prop :=
  v = x * y ∧ digitOverlap b v x + digitOverlap b v y = k

instance (b v x y : ℕ) : Decidable (IsVampire b v x y) :=
  inferInstanceAs (Decidable (_ ∧ _))

instance (b v x y : ℕ) : Decidable (IsGhost b v x y) :=
  inferInstanceAs (Decidable (_ ∧ _))

instance (b k v x y : ℕ) : Decidable (IsWerewolf b k v x y) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-! ## Monster Classification -/

/-- Classification of monster types. -/
inductive MonsterKind
  | vampire
  | ghost
  | werewolf (k : ℕ)
  deriving Repr, DecidableEq

end ArithmeticMonsters