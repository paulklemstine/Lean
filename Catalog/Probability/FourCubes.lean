import Probability.ThreeCubes.Moduli

/-!
# Four cubes: covering the residue classes

Over `ℤ` three cubes never represent `n ≡ ±4 (mod 9)`
(`ThreeCubes.not_isSumOfThreeCubes_of_mod_nine`) while five cubes always suffice
(`ThreeCubes.isSumOfFiveCubes`).  The four-cube problem sits exactly in between: there is *no*
congruence obstruction at all (four cubes cover every residue class modulo every modulus), and
it is a classical open problem whether every integer is a sum of four integer cubes.

This file proves the strongest covering result we could certify: an explicit finite system of
one-parameter polynomial identities

`(p₁k + q₁)³ + (p₂k + q₂)³ + (p₃k + q₃)³ + (p₄k + q₄)³ = 18k + r`

one for each admissible residue `r`, plus two identities with modulus `54`.  Each identity is a
polynomial identity checked by `ring`; they were found by a search over quadruples `(aᵢ)` with
`∑aᵢ³ = 0` and `(bᵢ)` with `∑aᵢ²bᵢ = 0`, which is exactly the condition for
`∑(aᵢt+bᵢ)³` to be a *linear* polynomial `3(∑aᵢbᵢ²)t + ∑bᵢ³`.

Main results.

* `ThreeCubes.isSumOfFourCubes_of_mod_eighteen` — every `n` whose residue mod `18` avoids
  `{2, 4, 5, 13, 14, 16}` is a sum of four integer cubes.  The four residues `4, 5, 13, 14`
  are exactly the classes `±4 (mod 9)`; these are *not* obstructed for four cubes
  (`4 = 1³+1³+1³+1³`), but no linear family was found meeting them.
* `ThreeCubes.isSumOfFourCubes_of_mod_fiftyfour` — the classes `±20 (mod 54)`, which lie inside
  the missing `±2 (mod 18)`, are covered as well.
* `ThreeCubes.isSumOfFourCubes_of_three_dvd` — in particular **every multiple of `3`** is a sum
  of four integer cubes, strengthening `ThreeCubes.isSumOfFourCubes_of_six_dvd`.
* `ThreeCubes.isSumOfFourCubes_of_not_exceptional` — the combined statement: every `n` with
  `n ≢ ±4 (mod 9)` and `n ≢ ±2, ±16 (mod 54)` is a sum of four integer cubes.  This covers
  `38` of the `54` residue classes modulo `54`; Demjanenko's theorem (not formalised here)
  asserts that all `42` classes with `n ≢ ±4 (mod 9)` are attainable.
* `ThreeCubes.isSumOfFourCubes_covers_all_residues` — the complementary local statement: modulo
  every positive modulus, four cubes represent every residue class, so no congruence
  obstruction exists for four cubes.
-/

namespace ThreeCubes

/-- `n` is a sum of four integer cubes. -/
def IsSumOfFourCubes (n : ℤ) : Prop := ∃ a b c d : ℤ, a ^ 3 + b ^ 3 + c ^ 3 + d ^ 3 = n

theorem isSumOfFourCubes_neg {n : ℤ} (h : IsSumOfFourCubes n) : IsSumOfFourCubes (-n) := by
  obtain ⟨a, b, c, d, habcd⟩ := h
  exact ⟨-a, -b, -c, -d, by rw [← habcd]; ring⟩

/-! ### The twelve linear families modulo `18` -/

theorem four_cubes_mod18_zero (k : ℤ) :
    (3 * k - 1) ^ 3 + (3 * k + 1) ^ 3 + (-(3 * k)) ^ 3 + (-(3 * k)) ^ 3 = 18 * k := by ring

theorem four_cubes_mod18_one (k : ℤ) :
    (-3 * k - 26) ^ 3 + (-2 * k - 23) ^ 3 + (2 * k + 14) ^ 3 + (3 * k + 30) ^ 3
      = 18 * k + 1 := by ring

theorem four_cubes_mod18_three (k : ℤ) :
    (6 * k - 5) ^ 3 + (3 * k) ^ 3 + (-3 * k + 4) ^ 3 + (-6 * k + 4) ^ 3 = 18 * k + 3 := by ring

theorem four_cubes_mod18_six (k : ℤ) :
    (3 * k) ^ 3 + (3 * k + 2) ^ 3 + (-3 * k - 1) ^ 3 + (-3 * k - 1) ^ 3 = 18 * k + 6 := by ring

theorem four_cubes_mod18_seven (k : ℤ) :
    (-9 * k + 2) ^ 3 + (k + 2) ^ 3 + (6 * k - 1) ^ 3 + (8 * k - 2) ^ 3 = 18 * k + 7 := by ring

theorem four_cubes_mod18_eight (k : ℤ) :
    (3 * k - 30) ^ 3 + (k - 5) ^ 3 + (-k + 14) ^ 3 + (-3 * k + 29) ^ 3 = 18 * k + 8 := by ring

theorem four_cubes_mod18_nine (k : ℤ) :
    (2 * k - 2) ^ 3 + (k + 2) ^ 3 + (-k + 2) ^ 3 + (-2 * k + 1) ^ 3 = 18 * k + 9 := by ring

theorem four_cubes_mod18_ten (k : ℤ) :
    (-3 * k - 32) ^ 3 + (-k - 15) ^ 3 + (k + 6) ^ 3 + (3 * k + 33) ^ 3 = 18 * k + 10 := by ring

theorem four_cubes_mod18_eleven (k : ℤ) :
    (-9 * k - 11) ^ 3 + (k - 1) ^ 3 + (6 * k + 7) ^ 3 + (8 * k + 10) ^ 3 = 18 * k + 11 := by ring

theorem four_cubes_mod18_twelve (k : ℤ) :
    (3 * k + 1) ^ 3 + (3 * k + 3) ^ 3 + (-3 * k - 2) ^ 3 + (-3 * k - 2) ^ 3
      = 18 * k + 12 := by ring

theorem four_cubes_mod18_fifteen (k : ℤ) :
    (6 * k - 1) ^ 3 + (3 * k + 2) ^ 3 + (-3 * k + 2) ^ 3 + (-6 * k) ^ 3 = 18 * k + 15 := by ring

theorem four_cubes_mod18_seventeen (k : ℤ) :
    (3 * k - 27) ^ 3 + (2 * k - 12) ^ 3 + (-2 * k + 21) ^ 3 + (-3 * k + 23) ^ 3
      = 18 * k + 17 := by ring

/-! ### Two further families modulo `54` -/

theorem four_cubes_mod54_twenty (k : ℤ) :
    (-3 * k + 10) ^ 3 + (-k + 7) ^ 3 + (k + 2) ^ 3 + (3 * k - 11) ^ 3 = 54 * k + 20 := by ring

theorem four_cubes_mod54_thirtyfour (k : ℤ) :
    (-3 * k - 13) ^ 3 + (-k - 8) ^ 3 + (k - 1) ^ 3 + (3 * k + 14) ^ 3 = 54 * k + 34 := by ring

/-! ### The covering theorems -/

/-- **Twelve of the fourteen admissible residues modulo `18`.**  Every integer whose residue
modulo `18` is not one of `2, 4, 5, 13, 14, 16` is a sum of four integer cubes.  The classes
`4, 5, 13, 14` are precisely `±4 (mod 9)`; these are excluded only because no linear
one-parameter family was found for them, not because of a congruence obstruction
(`ThreeCubes.solvableMod_four_cubes`). -/
theorem isSumOfFourCubes_of_mod_eighteen {n : ℤ}
    (h2 : n % 18 ≠ 2) (h4 : n % 18 ≠ 4) (h5 : n % 18 ≠ 5) (h13 : n % 18 ≠ 13)
    (h14 : n % 18 ≠ 14) (h16 : n % 18 ≠ 16) : IsSumOfFourCubes n := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, n = 18 * k + n % 18 := ⟨n / 18, by omega⟩
  have hr : n % 18 = 0 ∨ n % 18 = 1 ∨ n % 18 = 3 ∨ n % 18 = 6 ∨ n % 18 = 7 ∨ n % 18 = 8 ∨
      n % 18 = 9 ∨ n % 18 = 10 ∨ n % 18 = 11 ∨ n % 18 = 12 ∨ n % 18 = 15 ∨ n % 18 = 17 := by
    omega
  rcases hr with h | h | h | h | h | h | h | h | h | h | h | h <;> rw [h] at hk <;> subst hk
  · exact ⟨_, _, _, _, (four_cubes_mod18_zero k).trans (by ring)⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_one k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_three k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_six k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_seven k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_eight k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_nine k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_ten k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_eleven k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_twelve k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_fifteen k⟩
  · exact ⟨_, _, _, _, four_cubes_mod18_seventeen k⟩

/-- **Two of the six residues modulo `54` missed above.**  The classes `±20 (mod 54)` lie
inside the class `±2 (mod 18)` missed by `isSumOfFourCubes_of_mod_eighteen`. -/
theorem isSumOfFourCubes_of_mod_fiftyfour {n : ℤ} (h : n % 54 = 20 ∨ n % 54 = 34) :
    IsSumOfFourCubes n := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, n = 54 * k + n % 54 := ⟨n / 54, by omega⟩
  rcases h with h | h <;> rw [h] at hk <;> subst hk
  · exact ⟨_, _, _, _, four_cubes_mod54_twenty k⟩
  · exact ⟨_, _, _, _, four_cubes_mod54_thirtyfour k⟩

/-- **Every multiple of `3` is a sum of four integer cubes.**  This strictly strengthens
`ThreeCubes.isSumOfFourCubes_of_six_dvd`, which only covers the multiples of `6`. -/
theorem isSumOfFourCubes_of_three_dvd {n : ℤ} (h : (3 : ℤ) ∣ n) : IsSumOfFourCubes n := by
  obtain ⟨m, rfl⟩ := h
  exact isSumOfFourCubes_of_mod_eighteen (by omega) (by omega) (by omega) (by omega)
    (by omega) (by omega)

/-- **The combined covering theorem.**  Every integer `n` with `n ≢ ±4 (mod 9)` and
`n ≢ ±2, ±16 (mod 54)` is a sum of four integer cubes; that is `38` of the `54` residue classes
modulo `54`.  (Recall `38 ≡ -16` and `52 ≡ -2` modulo `54`.) -/
theorem isSumOfFourCubes_of_not_exceptional {n : ℤ} (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5)
    (e2 : n % 54 ≠ 2) (e16 : n % 54 ≠ 16) (e38 : n % 54 ≠ 38) (e52 : n % 54 ≠ 52) :
    IsSumOfFourCubes n := by
  by_cases h : n % 18 = 2 ∨ n % 18 = 16
  · exact isSumOfFourCubes_of_mod_fiftyfour (by omega)
  · push_neg at h
    exact isSumOfFourCubes_of_mod_eighteen h.1 (by omega) (by omega) (by omega) (by omega) h.2

/-! ### No congruence obstruction for four cubes -/

/-- **Four cubes have no congruence obstruction.**  For every modulus `m > 0` and every `n`
the congruence `a³ + b³ + c³ + d³ ≡ n (mod m)` is solvable: one of `n`, `n - 1`, `n + 1`
avoids the classes `±4 (mod 9)`, and the shift is itself a cube.  Contrast
`ThreeCubes.forall_solvableMod_iff`, where the modulus `9` genuinely obstructs three cubes. -/
theorem solvableMod_four_cubes {m : ℕ} (hm : 0 < m) (n : ℤ) :
    ∃ a b c d : ℤ, (m : ℤ) ∣ a ^ 3 + b ^ 3 + c ^ 3 + d ^ 3 - n := by
  obtain ⟨e, he3, h4, h5⟩ : ∃ e : ℤ, e ^ 3 = e ∧ (n - e) % 9 ≠ 4 ∧ (n - e) % 9 ≠ 5 := by
    rcases (by omega : n % 9 = 4 ∨ n % 9 = 5 ∨ (n % 9 ≠ 4 ∧ n % 9 ≠ 5)) with h | h | h
    · exact ⟨1, by norm_num, by omega, by omega⟩
    · exact ⟨-1, by norm_num, by omega, by omega⟩
    · exact ⟨0, by norm_num, by omega, by omega⟩
  obtain ⟨x, y, z, hxyz⟩ := solvableMod_of_mod_nine (n - e) h4 h5 m hm
  refine ⟨x, y, z, e, ?_⟩
  have hrw : x ^ 3 + y ^ 3 + z ^ 3 + e ^ 3 - n = x ^ 3 + y ^ 3 + z ^ 3 - (n - e) := by
    rw [he3]; ring
  rw [hrw]
  exact hxyz

end ThreeCubes