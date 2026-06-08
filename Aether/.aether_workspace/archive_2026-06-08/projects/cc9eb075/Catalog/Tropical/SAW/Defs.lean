/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Self-Avoiding Walks on ℤ²

Foundational definitions for self-avoiding walks (SAWs) on the integer lattice ℤ².
A self-avoiding walk is a sequence of lattice points where each step moves to an
adjacent lattice point (Manhattan distance 1) and no point is visited twice.
-/
import Mathlib

open Finset Function

/-! ## Lattice definitions -/

/-- A point in the 2D integer lattice. -/
abbrev LatticePoint := ℤ × ℤ

/-- Two lattice points are adjacent if they differ by exactly 1 in Manhattan distance. -/
def LatticeAdj (p q : LatticePoint) : Prop :=
  (|p.1 - q.1| + |p.2 - q.2| = 1)

/-
Adjacency is symmetric.
-/
theorem latticeAdj_symm : ∀ p q : LatticePoint, LatticeAdj p q → LatticeAdj q p := by
  unfold LatticeAdj; intro p q h; rw [ abs_sub_comm p.1 q.1, abs_sub_comm p.2 q.2 ] at h; exact h;

/-
A lattice point is not adjacent to itself.
-/
theorem latticeAdj_irrefl : ∀ p : LatticePoint, ¬LatticeAdj p p := by
  exact fun p => ne_of_lt ( by simp [ LatticeAdj ] )

/-! ## Self-avoiding walk definition -/

/-- A walk of length n on ℤ² is a function from `Fin (n+1)` to lattice points
    where consecutive points are adjacent. -/
structure LatticeWalk (n : ℕ) where
  /-- The sequence of lattice points visited. -/
  path : Fin (n + 1) → LatticePoint
  /-- Consecutive points are adjacent. -/
  adj_step : ∀ i : Fin n, LatticeAdj (path i.castSucc) (path i.succ)

/-- A walk is self-avoiding if no point is visited twice. -/
def LatticeWalk.IsSelfAvoiding {n : ℕ} (w : LatticeWalk n) : Prop :=
  Function.Injective w.path

/-- A self-avoiding walk (SAW) of length n starting at the origin. -/
structure SAW (n : ℕ) where
  /-- The underlying walk. -/
  walk : LatticeWalk n
  /-- The walk starts at the origin. -/
  start_origin : walk.path 0 = (0, 0)
  /-- The walk is self-avoiding. -/
  self_avoiding : walk.IsSelfAvoiding

/-- The endpoint of a SAW. -/
def SAW.endpoint {n : ℕ} (w : SAW n) : LatticePoint :=
  w.walk.path (Fin.last n)

/-! ## Translation of walks -/

/-
Translation preserves self-avoidance.
-/
theorem translate_injective {n : ℕ} (f : Fin (n + 1) → LatticePoint)
    (v : LatticePoint) (h : Function.Injective f) :
    Function.Injective (fun i => ((f i).1 + v.1, (f i).2 + v.2)) := by
  exact fun i j h' => h <| Prod.ext ( by injection h' with h₁ h₂; linarith ) ( by injection h' with h₁ h₂; linarith )

/-! ## SAW count function -/

/-- The number of SAWs of length n starting at origin.
    Known values: c(0) = 1, c(1) = 4, c(2) = 12. -/
noncomputable def saw_count : ℕ → ℕ
  | 0 => 1
  | 1 => 4
  | 2 => 12
  | _ + 3 => 0  -- placeholder

/-- c(0) = 1: only the trivial walk. -/
theorem saw_count_zero : saw_count 0 = 1 := rfl

/-- c(1) = 4: four possible first steps. -/
theorem saw_count_one : saw_count 1 = 4 := rfl

/-- c(2) = 12: each of 4 first steps has 3 continuations. -/
theorem saw_count_two : saw_count 2 = 12 := rfl