import Mathlib
import Algebra.SumThreeCubes.Defs

/-!
# Mod 9 Local Obstruction

This file reformulates the classical mod 9 obstruction for sums of three cubes
into the local admissibility framework.

## Main Results

* `not_threeCubeLocalAdmissible_mod9_four` — 4 is not locally admissible mod 9
* `not_threeCubeLocalAdmissible_mod9_five` — 5 is not locally admissible mod 9
* `not_threeCubeLocalAdmissible_mod9_of_eq_four_or_five` — combined statement
* `sumThreeCubesRep_implies_not_mod9_four_five` — integral corollary
-/

/-
The residue 4 mod 9 is not locally admissible for sums of three cubes.
-/
theorem not_threeCubeLocalAdmissible_mod9_four :
    ¬ ThreeCubeLocalAdmissible 9 (4 : ZMod 9) := by
  simp +decide only [ThreeCubeLocalAdmissible]

/-
The residue 5 mod 9 is not locally admissible for sums of three cubes.
-/
theorem not_threeCubeLocalAdmissible_mod9_five :
    ¬ ThreeCubeLocalAdmissible 9 (5 : ZMod 9) := by
  -- By definition of ThreeCubeLocalAdmissible, we need to show that there do not exist $x, y, z \in \mathbb{Z}/9\mathbb{Z}$ such that $x^3 + y^3 + z^3 = 5$.
  unfold ThreeCubeLocalAdmissible
  simp +decide

/-- Combined: residues 4 and 5 mod 9 are not locally admissible. -/
theorem not_threeCubeLocalAdmissible_mod9_of_eq_four_or_five
    (a : ZMod 9) (h : a = 4 ∨ a = 5) :
    ¬ ThreeCubeLocalAdmissible 9 a := by
  rcases h with rfl | rfl
  · exact not_threeCubeLocalAdmissible_mod9_four
  · exact not_threeCubeLocalAdmissible_mod9_five

/-
Integral corollary: if k is representable as a sum of three cubes,
then k mod 9 is neither 4 nor 5.
-/
theorem sumThreeCubesRep_implies_not_mod9_four_five
    (k : ℤ) (hrep : SumThreeCubesRep k) :
    ¬ ((k : ZMod 9) = 4 ∨ (k : ZMod 9) = 5) := by
  rcases hrep with ⟨ x, y, z, h ⟩ ; replace h := congr_arg ( ( ↑ ) : ℤ → ZMod 9 ) h ; simp_all +decide ;
  -- Use the fact that cubes modulo 9 are 0, 1, or 8.
  have h_cubes_mod_9 (n : ZMod 9) : n^3 = 0 ∨ n^3 = 1 ∨ n^3 = 8 := by
    native_decide +revert;
  rcases h_cubes_mod_9 x with ha | ha | ha <;> rcases h_cubes_mod_9 y with hb | hb | hb <;> rcases h_cubes_mod_9 z with hc | hc | hc <;> simp +decide only [← h, ha, hb, hc]