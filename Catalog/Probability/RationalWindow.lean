import Probability.ThreeCubes.RationalWitnessesB

/-!
# The rational window `|n| ≤ 1000`

Integrally, the Hasse principle for `x³ + y³ + z³ = n` is certified here only for `|n| ≤ 113`
(`ThreeCubes.hasse_of_abs_le_113`): `114` is the smallest locally solvable integer for which no
representation is known, and eight further values below `1000` (`165, 390, 579, 627, 633, 732,
921, 975`) are open as well.

Over `ℚ` the situation is completely different.  Combining the certified witness banks
`ThreeCubes.rationalCubes_chunk_a` … `ThreeCubes.rationalCubes_chunk_d` we prove here that
**every** integer with `|n| ≤ 1000` is a sum of three rational cubes — an order of magnitude
past the integral frontier, and in particular covering all nine integrally open cases.  Every
witness has denominator `d ≤ 12`; by `ThreeCubes.denominator_three_dvd_of_obstructed` a
denominator divisible by `3` is unavoidable whenever `n ≡ ±4 (mod 9)`.
-/

namespace ThreeCubes

/-- Every integer `0 ≤ n ≤ 1000` is a sum of three rational cubes. -/
theorem rationalCubes_of_nonneg_le_1000 (n : ℤ) (h0 : 0 ≤ n) (h1 : n ≤ 1000) :
    IsSumOfThreeRationalCubes (n : ℚ) := by
  rcases le_or_gt n 250 with h | h
  · exact rationalCubes_chunk_a n h0 h
  rcases le_or_gt n 500 with h' | h'
  · exact rationalCubes_chunk_b n (by omega) h'
  rcases le_or_gt n 750 with h'' | h''
  · exact rationalCubes_chunk_c n (by omega) h''
  · exact rationalCubes_chunk_d n (by omega) h1

/-- **Every integer with `|n| ≤ 1000` is a sum of three rational cubes.**

Contrast with `ThreeCubes.hasse_of_abs_le_113`, which certifies the *integral* problem only up
to `113`.  The rational problem has no congruence obstruction at all: `1001` explicit witnesses
(plus symmetry `n ↦ -n`) settle the whole window. -/
theorem rationalCubes_window_1000 (n : ℤ) (h : |n| ≤ 1000) :
    IsSumOfThreeRationalCubes (n : ℚ) := by
  rw [abs_le] at h
  obtain ⟨hlo, hhi⟩ := h
  rcases le_or_gt 0 n with hn | hn
  · exact rationalCubes_of_nonneg_le_1000 n hn hhi
  · have := isSumOfThreeRationalCubes_neg
      (rationalCubes_of_nonneg_le_1000 (-n) (by omega) (by omega))
    simpa using this

/-- **The nine integers below `1000` whose status as a sum of three *integer* cubes is unknown
are all sums of three *rational* cubes.**  Concretely, using
`ThreeCubes.rationalCubes_of_scaled`, each of `114, 165, 390, 579, 627, 633, 732, 921, 975`
is `(X/d)³ + (Y/d)³ + (Z/d)³` for an explicit integral triple and a denominator `d ≤ 6`. -/
theorem rationalCubes_open_cases_below_1000 :
    ∀ n ∈ ({114, 165, 390, 579, 627, 633, 732, 921, 975} : Finset ℤ),
      IsSumOfThreeRationalCubes (n : ℚ) := by
  intro n hn
  fin_cases hn <;> exact rationalCubes_of_nonneg_le_1000 _ (by norm_num) (by norm_num)

end ThreeCubes