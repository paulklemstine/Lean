/-
# Sums of Three Cubes — Basic Definitions and Core Infrastructure

This file defines the fundamental predicates and types for studying the Diophantine equation
  x³ + y³ + z³ = n
over the integers. It provides:
- `SumThreeCubesRep n`: the proposition that n is representable as a sum of three cubes
- `CubicSurfacePoint n`: the type of integral points on the cubic surface X_n
- `CubicSurfacePointMod m a`: local points modulo m
- `LocRep m a`: local representability predicate
- `HasLocalPointEverywhere n`: the "everywhere locally soluble" predicate

These definitions serve as the foundation for the mod-9 obstruction, infinite families,
local-global analysis, and density results developed in companion files.
-/
import Mathlib

/-- An integer `n` is representable as a sum of three integer cubes. -/
def SumThreeCubesRep (n : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = n

/-- The type of integral points on the affine cubic surface x³ + y³ + z³ = n. -/
def CubicSurfacePoint (n : ℤ) :=
  {p : ℤ × ℤ × ℤ // p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = n}

/-
Integer representability is equivalent to the nonemptiness of integral points
on the cubic surface X_n : x³ + y³ + z³ = n. This connects the Diophantine
problem to the geometric language of integral points on varieties.
-/
theorem sumThreeCubes_iff_nonempty_cubicSurfacePoint (n : ℤ) :
    SumThreeCubesRep n ↔ Nonempty (CubicSurfacePoint n) := by
  exact ⟨ fun ⟨ x, y, z, h ⟩ => ⟨ ⟨ ⟨ x, y, z ⟩, h ⟩ ⟩, fun ⟨ ⟨ ⟨ x, y, z ⟩, h ⟩ ⟩ => ⟨ x, y, z, h ⟩ ⟩

/-- Local representability: there exist x, y, z in ZMod m whose cubes sum to a. -/
def LocRep (m : ℕ) (a : ZMod m) : Prop :=
  ∃ x y z : ZMod m, x ^ 3 + y ^ 3 + z ^ 3 = a

/-- The type of local points on the cubic surface modulo m. -/
def CubicSurfacePointMod (m : ℕ) (a : ZMod m) :=
  {p : ZMod m × ZMod m × ZMod m // p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = a}

/-- The "everywhere locally soluble" predicate: for every positive modulus m,
the equation x³ + y³ + z³ ≡ n (mod m) has a solution. This is the local
condition in the Hasse principle. -/
def HasLocalPointEverywhere (n : ℤ) : Prop :=
  ∀ m : ℕ, m ≠ 0 → LocRep m (n : ZMod m)

/-
Every perfect cube is representable as a sum of three cubes.
Witness: m³ = m³ + 0³ + 0³.
-/
theorem cube_is_sum_of_three_cubes (m : ℤ) :
    SumThreeCubesRep (m ^ 3) := by
  exact ⟨ m, 0, 0, by ring ⟩

/-
There exist arbitrarily large integers (in absolute value) that are
representable as sums of three cubes.
-/
theorem infinitely_many_sum_three_cubes :
    ∀ B : ℤ, ∃ n : ℤ, Int.natAbs n > Int.natAbs B ∧ SumThreeCubesRep n := by
  intro B
  use (Int.natAbs B + 1)^3
  constructor
  ·
    grind
  ·
    exact cube_is_sum_of_three_cubes _

/-
There exist arbitrarily large positive integers that are representable
as sums of three cubes.
-/
theorem infinitely_many_positive_sum_three_cubes :
    ∀ B : ℕ, ∃ n : ℕ, B < n ∧ SumThreeCubesRep (n : ℤ) := by
  -- Let n = (B+1)^3 as a natural number. Then n > B (since (B+1)^3 ≥ B+1 > B for all B), and (n : ℤ) = ((B+1 : ℤ))^3 is a sum of three cubes by cube_is_sum_of_three_cubes.
  intro B
  use ((B + 1 : ℕ) ^ 3);
  exact ⟨ lt_of_lt_of_le ( Nat.lt_succ_self _ ) ( Nat.le_self_pow ( by decide ) _ ), by exact ⟨ B + 1, 0, 0, by norm_num ⟩ ⟩