/-
# Perfect Cuboid / Euler Brick — Core Definitions

A **perfect cuboid** (also called a perfect Euler brick) is a rectangular
parallelepiped whose edges, face diagonals, and space diagonal are all
integers. Whether one exists is a famous open problem in number theory.

This file provides the core definitions used throughout the formalization.
-/
import Mathlib

namespace PerfectCuboid

/-- A natural number is a perfect square. -/
def IsSquare (n : ℕ) : Prop := ∃ k : ℕ, k ^ 2 = n

/-- An Euler brick is a triple `(x, y, z)` of positive natural numbers
    such that all three face diagonals are integers. -/
def IsEulerBrick (x y z : ℕ) : Prop :=
  IsSquare (x ^ 2 + y ^ 2) ∧
  IsSquare (x ^ 2 + z ^ 2) ∧
  IsSquare (y ^ 2 + z ^ 2)

/-- A perfect cuboid is an Euler brick whose space diagonal is also an integer. -/
def IsPerfectCuboid (x y z : ℕ) : Prop :=
  IsEulerBrick x y z ∧ IsSquare (x ^ 2 + y ^ 2 + z ^ 2)

/-- Expanded form: a perfect cuboid with explicit diagonal witnesses. -/
def IsPerfectCuboidExplicit (x y z : ℕ) : Prop :=
  ∃ a b c d : ℕ,
    a ^ 2 = x ^ 2 + y ^ 2 ∧
    b ^ 2 = x ^ 2 + z ^ 2 ∧
    c ^ 2 = y ^ 2 + z ^ 2 ∧
    d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2

/-- A triple `(x, y, z)` is primitive if `gcd(x, gcd(y, z)) = 1`. -/
def PrimitiveTriple (x y z : ℕ) : Prop :=
  Nat.gcd x (Nat.gcd y z) = 1

/-- Exactly one of three natural numbers is even. -/
def ExactlyOneEven (x y z : ℕ) : Prop :=
  (Even x ∧ Odd y ∧ Odd z) ∨
  (Odd x ∧ Even y ∧ Odd z) ∨
  (Odd x ∧ Odd y ∧ Even z)

/-- The two definitions of perfect cuboid are equivalent. -/
theorem isPerfectCuboid_iff_explicit (x y z : ℕ) :
    IsPerfectCuboid x y z ↔ IsPerfectCuboidExplicit x y z := by
  simp only [IsPerfectCuboid, IsEulerBrick, IsPerfectCuboidExplicit, IsSquare]
  constructor
  · rintro ⟨⟨⟨a, ha⟩, ⟨b, hb⟩, ⟨c, hc⟩⟩, ⟨d, hd⟩⟩
    exact ⟨a, b, c, d, ha, hb, hc, hd⟩
  · rintro ⟨a, b, c, d, ha, hb, hc, hd⟩
    exact ⟨⟨⟨a, ha⟩, ⟨b, hb⟩, ⟨c, hc⟩⟩, ⟨d, hd⟩⟩

end PerfectCuboid