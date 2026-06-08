import Mathlib

/-!
# Sum of Three Cubes: Definitions and Basic Properties

This file establishes the foundational definitions for studying the sum-of-three-cubes
problem through the lens of local-to-global obstructions.

## Main Definitions

* `SumThreeCubes k` — the predicate that `k` is representable as a sum of three integer cubes
* `CubeSumAdmissible k` — the predicate that `k` avoids the mod-9 obstruction
* `admissibleCount N` — counts admissible integers in `[0, N)`
* `boundedSumThreeCubes B k` — bounded-search representability
* `LocalObstruction` — a general structure packaging modular obstructions
-/

open Finset

/-- An integer `k` is representable as a sum of three cubes. -/
def SumThreeCubes (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- An integer `k` is admissible for the sum-of-three-cubes problem if it avoids
the mod-9 obstruction (residues 4 and 5 are forbidden). -/
def CubeSumAdmissible (k : ℤ) : Prop :=
  k % 9 ≠ 4 ∧ k % 9 ≠ 5

instance (k : ℤ) : Decidable (CubeSumAdmissible k) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- Count of admissible integers in `[0, N)`. -/
def admissibleCount (N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun n : ℕ => decide (CubeSumAdmissible (n : ℤ)))).card

/-- Bounded-search representability: `k` is representable using cubes of integers
with absolute value at most `B`. -/
def boundedSumThreeCubes (B : ℕ) (k : ℤ) : Prop :=
  ∃ x y z : ℤ,
    |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x ^ 3 + y ^ 3 + z ^ 3 = k

/-- A general local obstruction packages a modulus, a set of forbidden residues,
and the induced admissibility predicate. This generalizes to any additive
Diophantine representation problem with modular obstructions. -/
structure LocalObstruction where
  /-- The modulus for the congruence obstruction -/
  modulus : ℕ
  /-- The modulus is positive -/
  modulus_pos : 0 < modulus
  /-- The set of forbidden residues -/
  forbidden : Finset ℤ
  /-- All forbidden residues are in `[0, modulus)` -/
  forbidden_range : ∀ r ∈ forbidden, 0 ≤ r ∧ r < modulus
  /-- The admissibility predicate -/
  admissible : ℤ → Prop
  /-- Admissibility is equivalent to having a non-forbidden residue -/
  admissible_iff : ∀ k : ℤ, admissible k ↔ k % modulus ∉ forbidden

/-- The local obstruction for the sum-of-three-cubes problem. -/
def sumThreeCubesObstruction : LocalObstruction where
  modulus := 9
  modulus_pos := by omega
  forbidden := {4, 5}
  forbidden_range := by
    intro r hr
    simp only [Finset.mem_insert, Finset.mem_singleton] at hr
    rcases hr with rfl | rfl <;> omega
  admissible := CubeSumAdmissible
  admissible_iff := by
    intro k
    simp only [CubeSumAdmissible, Finset.mem_insert, Finset.mem_singleton, Nat.cast_ofNat]
    tauto