/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Substitution Fractals: Dragon Curve Min-Plus Generation

This file formalizes the connection between the Heighway dragon curve's
combinatorial iteration and min-plus (tropical) algebra.

## Main Results

* `DragonTropical.reachable_eq_tropPot_zero` — The set of reachable dragon states at step `n`
  is exactly the zero set of a min-plus potential function `tropPot n`.
* `DragonTropical.tropPot_recursion` — The potential satisfies a min-plus
  convolution recursion: `tropPot (n+1) s = min (tropPot n (stepLInv s)) (tropPot n (stepRInv s))`.
* `DragonTropical.reachable_selfsimilar` — The reachable set decomposes as the union of
  two image copies under the left and right step maps.
* `DragonTropical.stepL_bijective` / `DragonTropical.stepR_bijective` — The step maps are
  bijections on the state space, with explicit inverses.
* `DragonTropical.dragonWord_starts_true` — Every non-empty dragon turn word begins with
  `true` (a right turn), proving non-universality of dragon turn languages.

## Mathematical Context

The Heighway dragon curve arises from iterated paper folding. At each stage,
a segment is replaced by two segments forming a right angle. We model this as a
binary tree of reachable states `(x, y, d) : ℤ × ℤ × Fin 4`, where `(x, y)` is
a lattice position and `d` encodes a quarter-turn direction.

The key insight is that reachability in this system can be encoded as a **min-plus
potential**: a function `Φ : DragonState → ℕ` whose zero set is exactly the set of
reachable states, and which satisfies a tropical (min-plus) recursion. This provides
a bridge between substitution dynamics and tropical optimization.
-/

namespace DragonTropical

/-! ## Basic Definitions -/

/-- Direction displacement in x-coordinate for each of 4 cardinal directions.
  Direction 0 = East, 1 = North, 2 = West, 3 = South. -/
def dx : Fin 4 → ℤ := ![1, 0, -1, 0]

/-- Direction displacement in y-coordinate for each of 4 cardinal directions. -/
def dy : Fin 4 → ℤ := ![0, 1, 0, -1]

/-- A dragon state: lattice position `(x, y)` and cardinal direction `d ∈ Fin 4`. -/
abbrev DragonState := ℤ × ℤ × Fin 4

/-- The initial dragon state: origin facing East. -/
def init : DragonState := (0, 0, 0)

/-- Step forward in current direction, then turn left (counterclockwise).
  Maps `(x, y, d)` to `(x + dx d, y + dy d, (d + 1) mod 4)`. -/
def stepL : DragonState → DragonState
  | (x, y, d) => (x + dx d, y + dy d, d + 1)

/-- Step forward in current direction, then turn right (clockwise).
  Maps `(x, y, d)` to `(x + dx d, y + dy d, (d + 3) mod 4)`. -/
def stepR : DragonState → DragonState
  | (x, y, d) => (x + dx d, y + dy d, d + 3)

/-- Left inverse of `stepL`. Given output `(x, y, d)`, recovers the unique input. -/
def stepLInv : DragonState → DragonState
  | (x, y, d) => (x - dx (d + 3), y - dy (d + 3), d + 3)

/-- Left inverse of `stepR`. Given output `(x, y, d)`, recovers the unique input. -/
def stepRInv : DragonState → DragonState
  | (x, y, d) => (x - dx (d + 1), y - dy (d + 1), d + 1)

/-! ## Reachable States -/

/-- The set of dragon states reachable in exactly `n` steps from the initial state,
  where at each step we choose either a left turn or a right turn. -/
def reachable : ℕ → Set DragonState
  | 0 => {init}
  | n + 1 => stepL '' reachable n ∪ stepR '' reachable n

/-! ## Step Inverse Lemmas -/

theorem stepL_stepLInv (s : DragonState) : stepL (stepLInv s) = s := by
  grind +locals

theorem stepLInv_stepL (s : DragonState) : stepLInv (stepL s) = s := by
  rcases s with ⟨ x, y, d ⟩ ; fin_cases d <;> simp +decide [ stepL, stepLInv ]

theorem stepR_stepRInv (s : DragonState) : stepR (stepRInv s) = s := by
  grind +locals

theorem stepRInv_stepR (s : DragonState) : stepRInv (stepR s) = s := by
  rcases s with ⟨ x, y, d ⟩;
  fin_cases d <;> simp +decide [ stepR, stepRInv ]

/-- `stepL` is a bijection on dragon states. -/
theorem stepL_bijective : Function.Bijective stepL :=
  ⟨Function.LeftInverse.injective stepLInv_stepL,
   fun s => ⟨stepLInv s, stepL_stepLInv s⟩⟩

/-- `stepR` is a bijection on dragon states. -/
theorem stepR_bijective : Function.Bijective stepR :=
  ⟨Function.LeftInverse.injective stepRInv_stepR,
   fun s => ⟨stepRInv s, stepR_stepRInv s⟩⟩

/-! ## Self-Similarity of Reachable Sets -/

/-- The reachable set at stage `n+1` is the union of two transformed copies
  of the stage-`n` set, under `stepL` and `stepR`. This is the tropical
  self-similarity decomposition. -/
theorem reachable_selfsimilar (n : ℕ) :
    reachable (n + 1) = stepL '' reachable n ∪ stepR '' reachable n := by
  rfl

/-! ## Tropical (Min-Plus) Potential -/

/-- The tropical potential function. `tropPot n s = 0` if `s` is reachable
  in `n` steps, and `tropPot n s = 1` otherwise.

  Defined recursively by the min-plus convolution:
  `tropPot (n+1) s = min (tropPot n (stepLInv s)) (tropPot n (stepRInv s))`. -/
def tropPot : ℕ → DragonState → ℕ
  | 0, s => if s = init then 0 else 1
  | n + 1, s => min (tropPot n (stepLInv s)) (tropPot n (stepRInv s))

/-- The tropical potential satisfies a min-plus recursion. -/
theorem tropPot_recursion (n : ℕ) (s : DragonState) :
    tropPot (n + 1) s = min (tropPot n (stepLInv s)) (tropPot n (stepRInv s)) := by
  rfl

/-! ## Main Theorem: Reachable States = Zero Set of Tropical Potential -/

/-
**Theorem A (Min-Plus Generation of Dragon Approximants).**
  For every `n : ℕ`, the set of states reachable in `n` dragon steps is exactly
  the zero-sublevel set of the tropical potential `tropPot n`.

  This is the cleanest theorem establishing that the dragon curve iteration
  is generated by iterated min-plus maps.
-/
theorem reachable_eq_tropPot_zero (n : ℕ) :
    reachable n = {s | tropPot n s = 0} := by
  induction' n with n ih;
  · -- In the base case, `reachable 0 = {init}` and `tropPot 0 s = 0` if and only if `s = init`.
    ext s
    simp [reachable, tropPot];
  · -- By definition of reachable, we have:
    ext s
    simp [reachable_selfsimilar, ih];
    grind +locals

/-! ## Dragon Turn Words and Non-Universality -/

/-- The dragon turn word at stage `n`. This is the sequence of turns
  (right = `true`, left = `false`) in the `n`-th dragon curve approximant.
  Generated by the paper-folding substitution:
  `dragonWord (n+1) = dragonWord n ++ [true] ++ reverse (map not (dragonWord n))`. -/
def dragonWord : ℕ → List Bool
  | 0 => []
  | n + 1 => dragonWord n ++ [true] ++ (dragonWord n).reverse.map (!·)

/-- The dragon language: all sublists that appear in some dragon turn word. -/
def dragonLanguage : Set (List Bool) :=
  {w | ∃ n, w <:+ dragonWord n ∨ w <+: dragonWord n ∨ w.IsInfix (dragonWord n)}

/-
Every non-empty dragon turn word starts with `true` (a right turn).
-/
theorem dragonWord_starts_true (n : ℕ) (hn : 0 < n) :
    (dragonWord n).head? = some true := by
  induction hn <;> simp_all +decide [ dragonWord ]

/-
**Counterexample: Dragon turn words are not universal.**
  The single-element word `[false]` is not a prefix of any dragon turn word.
  This means the dragon substitution system cannot generate all space-filling curves,
  since some curves begin with a left turn.
-/
theorem dragon_not_universal_prefix :
    ∀ n, ¬ [false] <+: dragonWord (n + 1) := by
  intro n;
  -- By definition of `dragonWord`, we know that `dragonWord (n + 1)` starts with `true`.
  have h_start_true : (dragonWord (n + 1)).head? = some true := by
    exact DragonTropical.dragonWord_starts_true _ ( Nat.succ_pos _ );
  cases h : dragonWord ( n + 1 ) <;> aesop

/-! ## Occupied Lattice Cells -/

/-- Project a dragon state to its lattice position, forgetting orientation. -/
def toPos : DragonState → ℤ × ℤ
  | (x, y, _) => (x, y)

/-- The set of lattice positions occupied at stage `n`. -/
def occupiedPositions (n : ℕ) : Set (ℤ × ℤ) :=
  toPos '' reachable n

/-- The occupied positions at stage `n+1` decompose as a union of two
  transformed copies, mirroring the self-similar structure. -/
theorem occupiedPositions_selfsimilar (n : ℕ) :
    occupiedPositions (n + 1) =
      toPos '' (stepL '' reachable n) ∪ toPos '' (stepR '' reachable n) := by
  simp [occupiedPositions, reachable, Set.image_union]

end DragonTropical