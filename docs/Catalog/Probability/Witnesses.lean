import Probability.ThreeCubes.LocalSolvability

/-!
# Verified computational results and the Hasse principle for `x³ + y³ + z³ = n`

The theorem `ThreeCubes.locallySolvable_iff` shows that the only local obstruction is the
congruence mod `9`.  Whether every locally solvable `n` is *globally* solvable — the Hasse
principle for the affine surface — is a famous open problem.  Here we

* reformulate the conjecture purely in congruence terms (`hasse_iff_congruence`);
* **verify it for every `n` with `|n| ≤ 113`**, using explicit representations checked by the
  Lean kernel.  This is the widest window currently possible: `114` is the smallest positive
  integer that is locally solvable and for which no representation is known.  Several of the
  witnesses are genuinely large, the most famous being
  `33 = 8866128975287528³ - 8778405442862239³ - 2736111468807040³` and
  `42 = (-80538738812075974)³ + 80435758145817515³ + 12602123297335631³`;
* record a second, huge representation of `3`.
-/

namespace ThreeCubes

/-- The Hasse principle for the affine surface `x³ + y³ + z³ = n`: local solvability implies
global solvability.  This is an open conjecture in general. -/
def HasseHolds (n : ℤ) : Prop := LocallySolvable n → IsSumOfThreeCubes n

/-- The Hasse principle for all `n` is equivalent to the purely congruence-theoretic
statement that every `n ≢ ±4 (mod 9)` is a sum of three cubes. -/
theorem hasse_iff_congruence :
    (∀ n : ℤ, HasseHolds n) ↔ (∀ n : ℤ, n % 9 ≠ 4 → n % 9 ≠ 5 → IsSumOfThreeCubes n) := by
  constructor
  · intro h n h4 h5
    exact h n (locallySolvable_of_not_mod_nine h4 h5)
  · intro h n hL
    obtain ⟨h4, h5⟩ := (locallySolvable_iff n).mp hL
    exact h n h4 h5

/-- Explicit representations for every `0 ≤ n ≤ 113` with `n ≢ ±4 (mod 9)`. -/
theorem isSumOfThreeCubes_of_nonneg_le_113 (n : ℤ) (h0 : 0 ≤ n) (h1 : n ≤ 113)
    (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5) : IsSumOfThreeCubes n := by
  interval_cases n
  · exact ⟨0, 0, 0, by norm_num⟩
  · exact ⟨0, 0, 1, by norm_num⟩
  · exact ⟨0, 1, 1, by norm_num⟩
  · exact ⟨1, 1, 1, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-1), (-1), 2, by norm_num⟩
  · exact ⟨(-1), 0, 2, by norm_num⟩
  · exact ⟨0, 0, 2, by norm_num⟩
  · exact ⟨0, 1, 2, by norm_num⟩
  · exact ⟨1, 1, 2, by norm_num⟩
  · exact ⟨(-2), (-2), 3, by norm_num⟩
  · exact ⟨7, 10, (-11), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-1), 2, 2, by norm_num⟩
  · exact ⟨0, 2, 2, by norm_num⟩
  · exact ⟨1, 2, 2, by norm_num⟩
  · exact ⟨(-2), (-1), 3, by norm_num⟩
  · exact ⟨(-2), 0, 3, by norm_num⟩
  · exact ⟨(-2), 1, 3, by norm_num⟩
  · exact ⟨(-14), (-11), 16, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨2, 2, 2, by norm_num⟩
  · exact ⟨(-1), (-1), 3, by norm_num⟩
  · exact ⟨(-1), 0, 3, by norm_num⟩
  · exact ⟨0, 0, 3, by norm_num⟩
  · exact ⟨0, 1, 3, by norm_num⟩
  · exact ⟨1, 1, 3, by norm_num⟩
  · exact ⟨2220422932, (-2218888517), (-283059965), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨8866128975287528, (-8778405442862239), (-2736111468807040), by norm_num⟩
  · exact ⟨(-1), 2, 3, by norm_num⟩
  · exact ⟨0, 2, 3, by norm_num⟩
  · exact ⟨1, 2, 3, by norm_num⟩
  · exact ⟨(-3), 0, 4, by norm_num⟩
  · exact ⟨(-3), 1, 4, by norm_num⟩
  · exact ⟨134476, 117367, (-159380), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-80538738812075974), 80435758145817515, 12602123297335631, by norm_num⟩
  · exact ⟨2, 2, 3, by norm_num⟩
  · exact ⟨(-7), (-5), 8, by norm_num⟩
  · exact ⟨(-3), 2, 4, by norm_num⟩
  · exact ⟨(-2), 3, 3, by norm_num⟩
  · exact ⟨6, 7, (-8), by norm_num⟩
  · exact ⟨(-2), (-2), 4, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-796), 602, 659, by norm_num⟩
  · exact ⟨60702901317, 23961292454, (-61922712865), by norm_num⟩
  · exact ⟨(-1), 3, 3, by norm_num⟩
  · exact ⟨0, 3, 3, by norm_num⟩
  · exact ⟨(-2), (-1), 4, by norm_num⟩
  · exact ⟨(-2), 0, 4, by norm_num⟩
  · exact ⟨(-2), 1, 4, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-4), (-1), 5, by norm_num⟩
  · exact ⟨(-4), 0, 5, by norm_num⟩
  · exact ⟨(-1), (-1), 4, by norm_num⟩
  · exact ⟨(-1), 0, 4, by norm_num⟩
  · exact ⟨0, 0, 4, by norm_num⟩
  · exact ⟨0, 1, 4, by norm_num⟩
  · exact ⟨1, 1, 4, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-4), 2, 5, by norm_num⟩
  · exact ⟨11, 20, (-21), by norm_num⟩
  · exact ⟨(-1), 2, 4, by norm_num⟩
  · exact ⟨0, 2, 4, by norm_num⟩
  · exact ⟨1, 2, 4, by norm_num⟩
  · exact ⟨(-284650292555885), 66229832190556, 283450105697727, by norm_num⟩
  · exact ⟨4381159, 435203083, (-435203231), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨26, 53, (-55), by norm_num⟩
  · exact ⟨(-33), (-19), 35, by norm_num⟩
  · exact ⟨2, 2, 4, by norm_num⟩
  · exact ⟨3, 3, 3, by norm_num⟩
  · exact ⟨(-11), (-11), 14, by norm_num⟩
  · exact ⟨(-2), 3, 4, by norm_num⟩
  · exact ⟨41639611, (-41531726), (-8241191), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-1972), (-4126), 4271, by norm_num⟩
  · exact ⟨(-4), (-4), 6, by norm_num⟩
  · exact ⟨6, 6, (-7), by norm_num⟩
  · exact ⟨(-3), (-2), 5, by norm_num⟩
  · exact ⟨0, 3, 4, by norm_num⟩
  · exact ⟨1, 3, 4, by norm_num⟩
  · exact ⟨(-5), (-5), 7, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨14, 20, (-22), by norm_num⟩
  · exact ⟨(-3), (-1), 5, by norm_num⟩
  · exact ⟨(-3), 0, 5, by norm_num⟩
  · exact ⟨(-3), 1, 5, by norm_num⟩
  · exact ⟨(-6), (-3), 7, by norm_num⟩
  · exact ⟨(-3), 4, 4, by norm_num⟩
  · exact ⟨118, 229, (-239), by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
  · exact ⟨(-7), (-4), 8, by norm_num⟩
  · exact ⟨(-3), 2, 5, by norm_num⟩
  · exact ⟨(-48), (-28), 51, by norm_num⟩
  · exact ⟨(-1165), (-948), 1345, by norm_num⟩
  · exact ⟨(-2), (-2), 5, by norm_num⟩
  · exact ⟨109938919, 16540290030, (-16540291649), by norm_num⟩
  · exact ⟨(-1040), 148, 1039, by norm_num⟩
  · exact absurd (by norm_num) h4
  · exact absurd (by norm_num) h5
/-- **The Hasse principle holds for every `|n| ≤ 113`.**  Since `114` is the smallest locally
solvable positive integer with no known representation, this is the largest symmetric window
that can currently be certified. -/
theorem hasse_of_abs_le_113 (n : ℤ) (h : |n| ≤ 113) : HasseHolds n := by
  intro hL
  obtain ⟨h4, h5⟩ := (locallySolvable_iff n).mp hL
  rw [abs_le] at h
  obtain ⟨hlo, hhi⟩ := h
  by_cases hn : 0 ≤ n
  · exact isSumOfThreeCubes_of_nonneg_le_113 n hn hhi h4 h5
  · push_neg at hn
    have hneg := isSumOfThreeCubes_of_nonneg_le_113 (-n) (by omega) (by omega)
      (by omega) (by omega)
    simpa using isSumOfThreeCubes_neg hneg

/-- The famous "third" representation of `3`, besides `1³+1³+1³` and `4³+4³+(-5)³`. -/
theorem three_third_representation :
    (569936821221962380720 : ℤ) ^ 3 + (-569936821113563493509 : ℤ) ^ 3
      + (-472715493453327032 : ℤ) ^ 3 = 3 := by norm_num

/-- `3` therefore has at least three pairwise distinct representations as an ordered sum of
three cubes. -/
theorem three_has_three_representations :
    ∃ p q r : ℤ × ℤ × ℤ, p ≠ q ∧ p ≠ r ∧ q ≠ r ∧
      (p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = 3) ∧
      (q.1 ^ 3 + q.2.1 ^ 3 + q.2.2 ^ 3 = 3) ∧
      (r.1 ^ 3 + r.2.1 ^ 3 + r.2.2 ^ 3 = 3) :=
  ⟨(1, 1, 1), (4, 4, -5),
    (569936821221962380720, -569936821113563493509, -472715493453327032),
    by decide, by decide, by decide, by norm_num, by norm_num, three_third_representation⟩

end ThreeCubes