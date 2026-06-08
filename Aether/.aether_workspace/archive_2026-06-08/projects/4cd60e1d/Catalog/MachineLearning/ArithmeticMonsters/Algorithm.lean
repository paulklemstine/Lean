/-
# Arithmetic Monsters: Verified Classification Algorithm

This file implements a verified search algorithm for classifying arithmetic monsters
(vampire numbers, ghost numbers, etc.) in arbitrary bases.
-/
import Mathlib
import Speculative.ArithmeticMonsters.Defs
import Speculative.ArithmeticMonsters.Theorems

open Finset BigOperators

namespace ArithmeticMonsters

/-! ## Decidable Classification -/

/-- Classify all monster triples `(v, x, y)` with `v ≤ N` in base `b`.
    For each `v`, tries all factor pairs `(x, y)` with `2 ≤ x ≤ y` and `x * y = v`. -/
def classifyMonsterTriples (b N : ℕ) : List (MonsterKind × ℕ × ℕ × ℕ) :=
  let results := (List.range (N + 1)).flatMap fun v =>
    if v < 4 then [] else
    let sqrtV := v.sqrt
    (List.range (sqrtV + 1)).filterMap fun x =>
      if x < 2 then none else
      if v % x ≠ 0 then none else
      let y := v / x
      if y < x then none else
      if decide (IsVampire b v x y) then some (MonsterKind.vampire, v, x, y)
      else if decide (IsGhost b v x y) then some (MonsterKind.ghost, v, x, y)
      else none
  results

/-
Soundness of vampire classification: every triple classified as vampire
    actually satisfies the `IsVampire` predicate.
-/
theorem classifyMonsterTriples_vampire_sound (b N : ℕ) :
    ∀ t ∈ classifyMonsterTriples b N,
      match t with
      | (MonsterKind.vampire, v, x, y) => IsVampire b v x y
      | (MonsterKind.ghost, v, x, y) => IsGhost b v x y
      | _ => True := by
  unfold classifyMonsterTriples;
  grind

/-- The modular sieve: a necessary condition for vampire pairs.
    This can be used to skip impossible factor pairs. -/
def vampireModSieve (b x y : ℕ) : Bool :=
  (x * y) % (b - 1) == (x + y) % (b - 1)

/-
The sieve is correct: it never rejects true vampire pairs.
-/
theorem vampireModSieve_necessary {b x y : ℕ} (hb : 2 ≤ b)
    (hV : IsVampire b (x * y) x y) :
    vampireModSieve b x y = true := by
  have := hV.2; have := IsVampire.modEq_sum hb hV;
  unfold vampireModSieve; aesop;

end ArithmeticMonsters