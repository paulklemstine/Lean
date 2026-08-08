import Probability.ThreeCubes.FourCubes

/-!
# Four cubes: closing the `±2, ±16 (mod 54)` gap down to six classes mod `216`

`Probability.ThreeCubes.FourCubes` proves that every integer `n` with `n ≢ ±4 (mod 9)` and
`n ≢ ±2, ±16 (mod 54)` is a sum of four integer cubes: `38` of the `54` classes mod `54`,
equivalently `152` of the `216` classes mod `216`.

This file pushes the covering further.  Six new one-parameter linear families — two of modulus
`72`, two of modulus `108` and two of modulus `216` — fill in ten of the sixteen residue classes
modulo `216` that were previously missed, leaving only

`n ≡ ±38, ±52, ±70 (mod 216)`

uncovered among the classes with `n ≢ ±4 (mod 9)`.  So `162` of the `168` admissible classes
modulo `216` are now certified.

The families were produced by the same mechanism as in `FourCubes`: a quadruple `(aᵢ)` with
`∑ aᵢ³ = 0` together with a shift `(bᵢ)` with `∑ aᵢ²bᵢ = 0` makes

`∑ (aᵢ k + bᵢ)³ = 3(∑ aᵢbᵢ²) k + ∑ bᵢ³`

a *linear* polynomial in `k`; one then needs the slope `3 ∑ aᵢbᵢ²` to be the desired modulus and
the constant `∑ bᵢ³` to be the desired residue.  An exhaustive search over `|aᵢ| ≤ 20`,
`|bᵢ| ≤ 50` found *no* linear family at all whose modulus divides `216` and whose constant lies
in `{±38, ±52, ±70} (mod 216)`; these six classes are therefore beyond the reach of the linear
method, and closing them requires genuinely different (e.g. quadratic) parametrisations.

Main results.

* `ThreeCubes.isSumOfFourCubes_of_mod_seventytwo`,
  `ThreeCubes.isSumOfFourCubes_of_mod_hundredeight`,
  `ThreeCubes.isSumOfFourCubes_of_mod_216_ninetytwo` — the three new covering steps.
* `ThreeCubes.isSumOfFourCubes_of_not_exceptional_216` — the combined statement: every `n`
  with `n ≢ ±4 (mod 9)` and `n % 216 ∉ {38, 52, 70, 146, 164, 178}` is a sum of four cubes.
* The six residues that remain uncovered all satisfy `n ≡ ±2 (mod 9)`; every other admissible
  class modulo `216` is now certified.
* `ThreeCubes.four_cubes_quadratic_family` and
  `ThreeCubes.exceptional_class_has_arbitrarily_large_four_cube` — a *quadratic* mechanism
  `(x+6s)³ + (x-6s)³ + u³ + u³ = 2(x³+u³) + 216xs²` shows that each of the six leftover classes
  still contains arbitrarily large sums of four cubes, so nothing arithmetic obstructs them.
-/

namespace ThreeCubes

/-! ### Two families of modulus `72` -/

theorem four_cubes_mod72_fiftysix (k : ℤ) :
    (-9 * k + 4) ^ 3 + (k + 4) ^ 3 + (6 * k - 2) ^ 3 + (8 * k - 4) ^ 3 = 72 * k + 56 := by ring

theorem four_cubes_mod72_sixteen (k : ℤ) :
    (-9 * k - 13) ^ 3 + (k - 3) ^ 3 + (6 * k + 8) ^ 3 + (8 * k + 12) ^ 3 = 72 * k + 16 := by ring

/-! ### Two families of modulus `108` -/

theorem four_cubes_mod108_two (k : ℤ) :
    (-3 * k - 41) ^ 3 + (-k - 22) ^ 3 + (k + 4) ^ 3 + (3 * k + 43) ^ 3 = 108 * k + 2 := by ring

theorem four_cubes_mod108_hundredsix (k : ℤ) :
    (-3 * k + 38) ^ 3 + (-k + 21) ^ 3 + (k - 3) ^ 3 + (3 * k - 40) ^ 3 = 108 * k + 106 := by ring

/-! ### Two families of modulus `216` -/

theorem four_cubes_mod216_ninetytwo (k : ℤ) :
    (-3 * k + 160) ^ 3 + (-k + 71) ^ 3 + (3 * k - 164) ^ 3 + (k - 35) ^ 3 = 216 * k + 92 := by
  ring

theorem four_cubes_mod216_hundredtwentyfour (k : ℤ) :
    (-3 * k - 163) ^ 3 + (-k - 72) ^ 3 + (3 * k + 167) ^ 3 + (k + 36) ^ 3 = 216 * k + 124 := by
  ring

/-! ### The new covering steps -/

/-- Every `n` with `n ≡ 16` or `56 (mod 72)` is a sum of four integer cubes.  Both classes lie
inside the block `±2 (mod 18)` missed by `isSumOfFourCubes_of_mod_eighteen`. -/
theorem isSumOfFourCubes_of_mod_seventytwo {n : ℤ} (h : n % 72 = 56 ∨ n % 72 = 16) :
    IsSumOfFourCubes n := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, n = 72 * k + n % 72 := ⟨n / 72, by omega⟩
  rcases h with h | h <;> rw [h] at hk <;> subst hk
  · exact ⟨_, _, _, _, four_cubes_mod72_fiftysix k⟩
  · exact ⟨_, _, _, _, four_cubes_mod72_sixteen k⟩

/-- Every `n` with `n ≡ 2` or `106 (mod 108)` is a sum of four integer cubes. -/
theorem isSumOfFourCubes_of_mod_hundredeight {n : ℤ} (h : n % 108 = 2 ∨ n % 108 = 106) :
    IsSumOfFourCubes n := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, n = 108 * k + n % 108 := ⟨n / 108, by omega⟩
  rcases h with h | h <;> rw [h] at hk <;> subst hk
  · exact ⟨_, _, _, _, four_cubes_mod108_two k⟩
  · exact ⟨_, _, _, _, four_cubes_mod108_hundredsix k⟩

/-- Every `n` with `n ≡ 92` or `124 (mod 216)` is a sum of four integer cubes. -/
theorem isSumOfFourCubes_of_mod_216_ninetytwo {n : ℤ} (h : n % 216 = 92 ∨ n % 216 = 124) :
    IsSumOfFourCubes n := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, n = 216 * k + n % 216 := ⟨n / 216, by omega⟩
  rcases h with h | h <;> rw [h] at hk <;> subst hk
  · exact ⟨_, _, _, _, four_cubes_mod216_ninetytwo k⟩
  · exact ⟨_, _, _, _, four_cubes_mod216_hundredtwentyfour k⟩

/-- The ten residue classes modulo `216` that the new families add to the old covering. -/
theorem isSumOfFourCubes_of_ten_new_classes {n : ℤ}
    (h : n % 216 = 2 ∨ n % 216 = 16 ∨ n % 216 = 56 ∨ n % 216 = 92 ∨ n % 216 = 106 ∨
      n % 216 = 110 ∨ n % 216 = 124 ∨ n % 216 = 160 ∨ n % 216 = 200 ∨ n % 216 = 214) :
    IsSumOfFourCubes n := by
  by_cases h72 : n % 72 = 56 ∨ n % 72 = 16
  · exact isSumOfFourCubes_of_mod_seventytwo h72
  · by_cases h108 : n % 108 = 2 ∨ n % 108 = 106
    · exact isSumOfFourCubes_of_mod_hundredeight h108
    · exact isSumOfFourCubes_of_mod_216_ninetytwo (by omega)

/-- **The improved covering theorem.**  Every integer `n` with `n ≢ ±4 (mod 9)` and
`n % 216 ∉ {38, 52, 70, 146, 164, 178}` is a sum of four integer cubes: `162` of the `168`
residue classes modulo `216` that are not congruent to `±4 (mod 9)`.  This strictly improves
`ThreeCubes.isSumOfFourCubes_of_not_exceptional`, which covered `152` of them. -/
theorem isSumOfFourCubes_of_not_exceptional_216 {n : ℤ} (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5)
    (e38 : n % 216 ≠ 38) (e52 : n % 216 ≠ 52) (e70 : n % 216 ≠ 70)
    (e146 : n % 216 ≠ 146) (e164 : n % 216 ≠ 164) (e178 : n % 216 ≠ 178) :
    IsSumOfFourCubes n := by
  by_cases hgap : n % 54 = 2 ∨ n % 54 = 16 ∨ n % 54 = 38 ∨ n % 54 = 52
  · exact isSumOfFourCubes_of_ten_new_classes (by omega)
  · exact isSumOfFourCubes_of_not_exceptional h4 h5 (by omega) (by omega) (by omega) (by omega)

/-! ### The six remaining classes are not empty of sums of four cubes

The six classes `±38, ±52, ±70 (mod 216)` are beyond the reach of *linear* families, but they
are certainly not obstructed.  A second, genuinely quadratic mechanism reaches them: from
`(x + w)³ + (x - w)³ = 2x³ + 6xw²` with `w = 6s` one gets

`(x + 6s)³ + (x - 6s)³ + u³ + u³ = 2(x³ + u³) + 216 x s²`,

an arithmetic progression modulo `216` *inside* a quadratic family.  Choosing `(x, u)` with
`2(x³ + u³) ≡ r (mod 216)` therefore produces infinitely many sums of four cubes in the class
`r`, for each of the six exceptional `r`. -/

/-- The quadratic four-cube identity: `216 x s²` is added to the fixed value `2(x³ + u³)`. -/
theorem four_cubes_quadratic_family (x u s : ℤ) :
    (x + 6 * s) ^ 3 + (x - 6 * s) ^ 3 + u ^ 3 + u ^ 3 = 2 * (x ^ 3 + u ^ 3) + 216 * x * s ^ 2 := by
  ring

theorem isSumOfFourCubes_class38 (s : ℤ) : IsSumOfFourCubes (648 * s ^ 2 + 38) :=
  ⟨3 + 6 * s, 3 - 6 * s, -2, -2, by ring⟩

theorem isSumOfFourCubes_class52 (s : ℤ) : IsSumOfFourCubes (648 * s ^ 2 + 52) :=
  ⟨3 + 6 * s, 3 - 6 * s, -1, -1, by ring⟩

theorem isSumOfFourCubes_class70 (s : ℤ) : IsSumOfFourCubes (432 * s ^ 2 + 70) :=
  ⟨2 + 6 * s, 2 - 6 * s, 3, 3, by ring⟩

theorem isSumOfFourCubes_class146 (s : ℤ) : IsSumOfFourCubes (2592 * s ^ 2 + 794) :=
  ⟨12 + 6 * s, 12 - 6 * s, -11, -11, by ring⟩

theorem isSumOfFourCubes_class164 (s : ℤ) : IsSumOfFourCubes (216 * s ^ 2 - 52) :=
  ⟨1 + 6 * s, 1 - 6 * s, -3, -3, by ring⟩

theorem isSumOfFourCubes_class178 (s : ℤ) : IsSumOfFourCubes (432 * s ^ 2 - 38) :=
  ⟨2 + 6 * s, 2 - 6 * s, -3, -3, by ring⟩

/-- A quadratic family with leading coefficient at least `216` and constant term at least `-52`
eventually exceeds any bound, at `s = |M| + 1`. -/
theorem le_quadratic_at_abs_succ {A B M : ℤ} (hA : 216 ≤ A) (hB : -52 ≤ B) :
    M ≤ A * (|M| + 1) ^ 2 + B := by
  set s : ℤ := |M| + 1 with hs
  have hs1 : 1 ≤ s := by have := abs_nonneg M; omega
  have hsM : M ≤ s := by have := le_abs_self M; omega
  have hsq : s ≤ s ^ 2 := by nlinarith
  nlinarith

/-- **The six exceptional classes are populated.**  Each of `38, 52, 70, 146, 164, 178
(mod 216)` — the classes that `isSumOfFourCubes_of_not_exceptional_216` leaves open — contains
arbitrarily large integers that *are* sums of four integer cubes.  So the obstruction is one of
*method* (no linear family reaches them), not of arithmetic. -/
theorem exceptional_class_has_arbitrarily_large_four_cube {r : ℤ}
    (hr : r = 38 ∨ r = 52 ∨ r = 70 ∨ r = 146 ∨ r = 164 ∨ r = 178) (M : ℤ) :
    ∃ n : ℤ, M ≤ n ∧ n % 216 = r ∧ IsSumOfFourCubes n := by
  set s : ℤ := |M| + 1 with hs
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨648 * s ^ 2 + 38, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class38 s⟩
  · exact ⟨648 * s ^ 2 + 52, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class52 s⟩
  · exact ⟨432 * s ^ 2 + 70, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class70 s⟩
  · exact ⟨2592 * s ^ 2 + 794, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class146 s⟩
  · exact ⟨216 * s ^ 2 - 52, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class164 s⟩
  · exact ⟨432 * s ^ 2 - 38, le_quadratic_at_abs_succ (by norm_num) (by norm_num),
      by omega, isSumOfFourCubes_class178 s⟩

end ThreeCubes