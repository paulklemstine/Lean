/-
# Density of Admissible Residue Classes for Sums of Three Cubes

This file formalizes counting results for the set of integers not obstructed
by the mod-9 condition. In each block of 9 consecutive integers, exactly 7
are admissible (not ≡ 4,5 mod 9).

Key results:
- `count_admissible_mod9_block`: exact count in [0, 9N)
- `admissibleMod9`: decidable predicate for admissibility
-/
import Mathlib
import Speculative.AutoResearch.NumberTheory.SumThreeCubes.Basic

/-- A natural number is mod-9 admissible if it is not congruent to 4 or 5 mod 9.
These are exactly the residue classes that are not obstructed from being
sums of three cubes by the mod-9 condition. -/
def admissibleMod9 (n : ℕ) : Prop :=
  n % 9 ≠ 4 ∧ n % 9 ≠ 5

instance : DecidablePred admissibleMod9 := fun n => by
  unfold admissibleMod9
  exact instDecidableAnd

/-
In each complete block of 9N consecutive natural numbers [0, 9N),
exactly 7N are admissible (not ≡ 4,5 mod 9). This gives the admissible
set a natural density of 7/9.
-/
theorem count_admissible_mod9_block (N : ℕ) :
    ((Finset.range (9 * N)).filter (fun n => admissibleMod9 n)).card = 7 * N := by
  induction' N with N ih;
  · rfl;
  · simp +arith +decide [ Nat.mul_succ, Finset.range_add_one ] at *;
    simp_all +decide [ Finset.filter_insert, admissibleMod9 ]