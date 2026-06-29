/-
  Collatz-Based Hash Collision Falsification
  ==========================================

  We instantiate the Merkle–Damgård (MD) framework of `Cryptography.MerkleDamgard`
  with a concrete, deliberately *broken* compression function built from the
  Collatz step map `T`.  We then exhibit an explicit collision and feed it through
  the MD collision-extraction theorem `md_collision_extract`, demonstrating that
  this hash fails collision resistance.

  The Collatz step map is
      T(n) = n / 2          if n is even,
      T(n) = 3 n + 1        if n is odd.
  Two distinct inputs already collide at the first step:
      T(1) = 3·1 + 1 = 4,
      T(8) = 8 / 2   = 4,
  recorded as `T_one_eq_T_eight`.

  The compression function `collatzCompress s b = T (s + b)` therefore inherits a
  collision: starting from the IV `0`, the single-block messages `m₁ = [1]` and
  `m₂ = [8]` both hash to `4`, yet are distinct and of equal length.  Applying
  `md_collision_extract` turns this MD collision into an explicit collision of the
  compression function, giving `collatzCompress_has_collision`.
-/
import Mathlib
import Cryptography.MerkleDamgard

namespace Cryptography.CollatzHash

open Cryptography.MerkleDamgard

/-- The Collatz step map on natural numbers:
    `T n = n / 2` when `n` is even and `T n = 3 n + 1` when `n` is odd. -/
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-- `T 1 = 4` and `T 8 = 4`: two distinct inputs of the Collatz map collide. -/
theorem T_one_eq_T_eight : T 1 = T 8 := by decide

/-- The Merkle–Damgård compression function built from the Collatz map:
    `collatzCompress s b = T (s + b)`. -/
def collatzCompress (s b : ℕ) : ℕ := T (s + b)

/-- The two colliding single-block messages. -/
def m₁ : List ℕ := [1]

/-- The two colliding single-block messages. -/
def m₂ : List ℕ := [8]

/-- Both messages hash, from the IV `0`, to the same value `4`. -/
theorem collatzHash_collision_value :
    mdHash collatzCompress 0 m₁ = mdHash collatzCompress 0 m₂ := by decide

/-- **Collision resistance failure of the Collatz-based MD hash.**
    The compression function `collatzCompress` has an explicit collision,
    extracted from the MD collision on the distinct equal-length messages
    `m₁ = [1]` and `m₂ = [8]` via `md_collision_extract`.  The underlying
    single-step collision is `T_one_eq_T_eight`. -/
theorem collatzCompress_has_collision :
    HasCompressionCollision collatzCompress :=
  md_collision_extract collatzCompress 0 m₁ m₂ (by decide) (by decide)
    collatzHash_collision_value

end Cryptography.CollatzHash