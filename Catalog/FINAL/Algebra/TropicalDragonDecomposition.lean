import Mathlib

/-!
# Directional Decomposition for Tropical Dragon Dynamics

This file establishes a **directional decomposition theorem** for the tropical dragon
curve dynamics: any finite word of turns decomposes into an additive accumulation of
local directional translations.

## Mathematical Overview

The Heighway dragon curve walker moves on ℤ² with a facing direction from `Fin 4`
(East/North/West/South). At each step, it advances one unit in its current direction,
then turns left or right. The key insight is that the position update at each step
is a pure translation determined by the current facing direction.

**Main Theorem** (`foldl_applyStep_eq_add_totalDisp`): For any initial walker state
and any finite sequence of turns, the final position equals the initial position plus
the sum of direction vectors along the path. The direction sequence is entirely
determined by the initial facing direction and the turn sequence.

This decomposes a complex iterated dynamical system into:
1. A **finite-state automaton** (direction evolution, determined by turns),
2. An **additive accumulator** (position = sum of direction vectors).

## Significance

- Turns symbolic dynamics into additive invariants over ℤ².
- Enables orbit classification: two turn sequences produce the same displacement
  iff their accumulated direction-vector sums agree.
- Periodicity reduces to vanishing displacement.
- Opens a pathway to tropical/idempotent finite-generation analysis.

## Main Results

* `step_displacement` — each step translates position by the current direction vector
* `foldl_applyStep_eq_add_totalDisp` — the main decomposition theorem
* `totalDisp_append` — displacement is additive under word concatenation
* `fold_fixed_iff_totalDisp_eq_zero` — periodicity ↔ zero displacement
* `fold_eq_of_totalDisp_eq` — equal displacement ⇒ equal orbit action
* `totalDisp_as_weighted_sum` — displacement decomposes over direction multiplicities
-/

open List Finset

namespace TropicalDragonDecomp

/-! ### Core Definitions -/

/-- Direction on the integer lattice, encoded as `Fin 4`.
0 = East, 1 = North, 2 = West, 3 = South. -/
abbrev Dir := Fin 4

/-- Unit displacement vector for each cardinal direction. -/
def dirVec : Dir → ℤ × ℤ
  | ⟨0, _⟩ => (1, 0)
  | ⟨1, _⟩ => (0, 1)
  | ⟨2, _⟩ => (-1, 0)
  | ⟨3, _⟩ => (0, -1)

/-- Walker state: current position on ℤ² and facing direction. -/
structure WalkState where
  pos : ℤ × ℤ
  dir : Dir
  deriving DecidableEq, Repr

/-- Apply a single step: move one unit in the current direction,
then turn right (if `true`) or left (if `false`).
Right turn = `(d + 3) mod 4`, left turn = `(d + 1) mod 4`. -/
def applyStep (s : WalkState) (turn : Bool) : WalkState :=
  { pos := (s.pos.1 + (dirVec s.dir).1, s.pos.2 + (dirVec s.dir).2),
    dir := if turn then (s.dir + 3 : Fin 4) else (s.dir + 1 : Fin 4) }

/-- Update direction after a turn. -/
def turnDir (d : Dir) (turn : Bool) : Dir :=
  if turn then (d + 3 : Fin 4) else (d + 1 : Fin 4)

/-! ### Direction Sequence -/

/-- The sequence of facing directions visited during a walk,
given an initial direction and a list of turns.
The list has the same length as `turns`: one direction per step. -/
def visitedDirs : Dir → List Bool → List Dir
  | _, [] => []
  | d, t :: ts => d :: visitedDirs (turnDir d t) ts

@[simp]
theorem visitedDirs_nil (d : Dir) : visitedDirs d [] = [] := rfl

@[simp]
theorem visitedDirs_cons (d : Dir) (t : Bool) (ts : List Bool) :
    visitedDirs d (t :: ts) = d :: visitedDirs (turnDir d t) ts := rfl

theorem visitedDirs_length (d : Dir) (turns : List Bool) :
    (visitedDirs d turns).length = turns.length := by
  induction turns generalizing d <;> simp_all [visitedDirs]

/-! ### Displacement: Recursive Definition -/

/-- Total displacement from a sequence of turns starting at direction `d`.
Defined recursively: empty word gives zero, cons adds the current direction vector. -/
def totalDisp : Dir → List Bool → ℤ × ℤ
  | _, [] => (0, 0)
  | d, t :: ts =>
    let rest := totalDisp (turnDir d t) ts
    ((dirVec d).1 + rest.1, (dirVec d).2 + rest.2)

@[simp]
theorem totalDisp_nil (d : Dir) : totalDisp d [] = (0, 0) := rfl

@[simp]
theorem totalDisp_cons (d : Dir) (t : Bool) (ts : List Bool) :
    totalDisp d (t :: ts) =
    ((dirVec d).1 + (totalDisp (turnDir d t) ts).1,
     (dirVec d).2 + (totalDisp (turnDir d t) ts).2) := rfl

/-! ### The Direction After a Word -/

/-- The direction after processing a sequence of turns. -/
def finalDir : Dir → List Bool → Dir
  | d, [] => d
  | d, t :: ts => finalDir (turnDir d t) ts

@[simp] theorem finalDir_nil (d : Dir) : finalDir d [] = d := rfl

@[simp] theorem finalDir_cons (d : Dir) (t : Bool) (ts : List Bool) :
    finalDir d (t :: ts) = finalDir (turnDir d t) ts := rfl

/-! ### Helper: step properties -/

/-- Each step translates the position by the direction vector. -/
theorem step_displacement (s : WalkState) (t : Bool) :
    (applyStep s t).pos = (s.pos.1 + (dirVec s.dir).1, s.pos.2 + (dirVec s.dir).2) := rfl

/-- The direction after a step equals `turnDir`. -/
theorem step_dir (s : WalkState) (t : Bool) :
    (applyStep s t).dir = turnDir s.dir t := rfl

/-! ### Main Decomposition Theorem -/

/-- **Main Theorem**: The position after folding a sequence of turns
equals the initial position plus the total displacement.

This is the directional decomposition theorem: a complex iterated
dynamical system on ℤ² decomposes into an additive accumulation of
local directional translations. -/
theorem foldl_applyStep_eq_add_totalDisp (s : WalkState) (turns : List Bool) :
    (turns.foldl applyStep s).pos =
    (s.pos.1 + (totalDisp s.dir turns).1, s.pos.2 + (totalDisp s.dir turns).2) := by
  induction turns generalizing s with
  | nil => simp
  | cons t ts ih =>
    simp only [foldl_cons]
    rw [ih]
    simp only [step_displacement, step_dir, totalDisp_cons]
    ext <;> ring

/-- The direction after folding equals `finalDir`. -/
theorem foldl_applyStep_dir (s : WalkState) (turns : List Bool) :
    (turns.foldl applyStep s).dir = finalDir s.dir turns := by
  induction turns generalizing s with
  | nil => rfl
  | cons t ts ih =>
    simp only [foldl_cons]
    rw [ih]; simp [step_dir]

/-! ### Additive Structure of Displacement -/

/-- Displacement is additive under word concatenation. -/
theorem totalDisp_append (d : Dir) (ts₁ ts₂ : List Bool) :
    totalDisp d (ts₁ ++ ts₂) =
    ((totalDisp d ts₁).1 + (totalDisp (finalDir d ts₁) ts₂).1,
     (totalDisp d ts₁).2 + (totalDisp (finalDir d ts₁) ts₂).2) := by
  induction ts₁ generalizing d with
  | nil => simp
  | cons t ts ih =>
    simp only [cons_append, totalDisp_cons, finalDir_cons]
    rw [ih]
    ext <;> ring

/-- `finalDir` composes under concatenation. -/
theorem finalDir_append (d : Dir) (ts₁ ts₂ : List Bool) :
    finalDir d (ts₁ ++ ts₂) = finalDir (finalDir d ts₁) ts₂ := by
  induction ts₁ generalizing d with
  | nil => simp
  | cons t ts ih => simp [ih]

/-! ### Orbit Classification -/

/-- Two turn sequences produce the same position if they have
equal total displacement (from the same initial direction). -/
theorem fold_eq_of_totalDisp_eq (s : WalkState) (ts₁ ts₂ : List Bool)
    (hdisp : totalDisp s.dir ts₁ = totalDisp s.dir ts₂) :
    (ts₁.foldl applyStep s).pos = (ts₂.foldl applyStep s).pos := by
  rw [foldl_applyStep_eq_add_totalDisp, foldl_applyStep_eq_add_totalDisp, hdisp]

/-! ### Periodicity Criterion -/

/-- A turn sequence returns the walker to its starting position
if and only if the total displacement is zero. -/
theorem fold_fixed_iff_totalDisp_eq_zero (s : WalkState) (turns : List Bool) :
    (turns.foldl applyStep s).pos = s.pos ↔ totalDisp s.dir turns = (0, 0) := by
  rw [foldl_applyStep_eq_add_totalDisp]
  constructor
  · intro h
    have h1 := congr_arg Prod.fst h
    have h2 := congr_arg Prod.snd h
    simp at h1 h2
    ext <;> omega
  · intro h
    have h1 := congr_arg Prod.fst h
    have h2 := congr_arg Prod.snd h
    simp at h1 h2
    ext <;> omega

/-! ### Existential Form -/

/-- **Existential decomposition**: any fold of turns acts as translation
by some displacement vector. -/
theorem exists_word_translation (d : Dir) (turns : List Bool) :
    ∃ Δ : ℤ × ℤ, ∀ p : ℤ × ℤ,
      (turns.foldl applyStep ⟨p, d⟩).pos = (p.1 + Δ.1, p.2 + Δ.2) := by
  exact ⟨totalDisp d turns, fun p => foldl_applyStep_eq_add_totalDisp ⟨p, d⟩ turns⟩

/-! ### Singleton and Two-Step Composition -/

/-- Displacement of a single turn equals the initial direction vector. -/
theorem totalDisp_singleton (d : Dir) (t : Bool) :
    totalDisp d [t] = dirVec d := by
  simp [totalDisp]

/-- Two-step composition adds the two direction vectors. -/
theorem totalDisp_two_steps (d : Dir) (t₁ t₂ : Bool) :
    totalDisp d [t₁, t₂] =
    ((dirVec d).1 + (dirVec (turnDir d t₁)).1,
     (dirVec d).2 + (dirVec (turnDir d t₁)).2) := by
  simp [totalDisp]

/-! ### Direction Vector Finset Decomposition -/

/-- Count of direction `d'` in the visited direction sequence. -/
def dirCount (d : Dir) (turns : List Bool) (d' : Dir) : ℕ :=
  ((visitedDirs d turns).filter (· = d')).length

/-
Total displacement decomposes as a weighted sum over direction multiplicities:
the displacement equals the sum over all directions of
(count of that direction) × (direction vector).
-/
theorem totalDisp_as_weighted_sum (d : Dir) (turns : List Bool) :
    totalDisp d turns =
    (∑ d' : Fin 4, (dirCount d turns d' : ℤ) * (dirVec d').1,
     ∑ d' : Fin 4, (dirCount d turns d' : ℤ) * (dirVec d').2) := by
  induction' turns with t turns ih generalizing d;
  · native_decide +revert;
  · -- By definition of `dirCount`, we have:
    have h_dirCount_cons : ∀ d' : Dir, dirCount d (t :: turns) d' = dirCount (turnDir d t) turns d' + (if d = d' then 1 else 0) := by
      intro d'
      simp [dirCount, visitedDirs];
      grind;
    simp_all +decide [ Finset.sum_add_distrib, add_mul ];
    exact ⟨ add_comm _ _, add_comm _ _ ⟩

/-- The set of reachable displacements from a fixed initial direction
is generated by the four direction vectors.
For any turn sequence, the displacement can be written as
`∑ d', n d' • dirVec d'` for some `n : Dir → ℕ`. -/
theorem exists_count_representation (d : Dir) (turns : List Bool) :
    ∃ n : Dir → ℕ,
      totalDisp d turns =
      (∑ d' : Fin 4, (n d' : ℤ) * (dirVec d').1,
       ∑ d' : Fin 4, (n d' : ℤ) * (dirVec d').2) := by
  exact ⟨dirCount d turns, totalDisp_as_weighted_sum d turns⟩

end TropicalDragonDecomp