import Mathlib
import Speculative.SumThreeCubes.Defs

/-!
# Cube Residues Modulo 9

We prove that every integer cube is congruent to 0, 1, or 8 modulo 9,
and that sums of three cubes can never be congruent to 4 or 5 modulo 9.

## Strategy

The proof proceeds by exhaustive residue classification: for any integer `x`,
`x % 9` takes one of 9 values, and in each case `x^3 % 9 ∈ {0, 1, 8}`.
Then the sum of three such residues is checked against all 27 combinations.
-/

/-
Every integer cube is congruent to 0, 1, or 8 modulo 9.
-/
theorem int_cube_mod_nine_mem (x : ℤ) :
    x ^ 3 % 9 = 0 ∨ x ^ 3 % 9 = 1 ∨ x ^ 3 % 9 = 8 := by
  norm_num [ pow_succ', Int.mul_emod ] ; have := Int.emod_nonneg x ( by norm_num : ( 9 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos x ( by norm_num : ( 9 : ℤ ) > 0 ) ; interval_cases x % 9 <;> trivial;

/-
The sum of three integer cubes is never congruent to 4 or 5 modulo 9.
-/
theorem sum_three_cubes_mod_nine_ne_four_five
    {x y z k : ℤ} (h : x ^ 3 + y ^ 3 + z ^ 3 = k) :
    k % 9 ≠ 4 ∧ k % 9 ≠ 5 := by
  -- Use int_cube_mod_nine_mem to get that each of x^3, y^3, z^3 is congruent to 0, 1, or 8 mod 9.
  have hx : x ^ 3 % 9 = 0 ∨ x ^ 3 % 9 = 1 ∨ x ^ 3 % 9 = 8 := int_cube_mod_nine_mem x
  have hy : y ^ 3 % 9 = 0 ∨ y ^ 3 % 9 = 1 ∨ y ^ 3 % 9 = 8 := int_cube_mod_nine_mem y
  have hz : z ^ 3 % 9 = 0 ∨ z ^ 3 % 9 = 1 ∨ z ^ 3 % 9 = 8 := int_cube_mod_nine_mem z;
  omega

/-- Any integer representable as a sum of three cubes is admissible. -/
theorem sum_three_cubes_not_four_five_mod_nine
    {k : ℤ} (hk : SumThreeCubes k) :
    CubeSumAdmissible k := by
  obtain ⟨x, y, z, hxyz⟩ := hk
  exact sum_three_cubes_mod_nine_ne_four_five hxyz

/-- `Rep ⊆ Adm`: the set of representable integers is contained in the admissible set. -/
theorem rep_subset_adm : {k : ℤ | SumThreeCubes k} ⊆ {k : ℤ | CubeSumAdmissible k} :=
  fun _ hk => sum_three_cubes_not_four_five_mod_nine hk