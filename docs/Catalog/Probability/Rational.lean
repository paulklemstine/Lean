import Probability.Witnesses

/-!
# The mod `9` obstruction is *purely integral*: sums of three **rational** cubes

Over `ℤ` the congruence `n ≡ ±4 (mod 9)` is a genuine obstruction to `x³+y³+z³ = n`
(`ThreeCubes.not_isSumOfThreeCubes_of_mod_nine`), and by `ThreeCubes.locallySolvable_iff` it is the
*only* local obstruction.  This file shows that the obstruction evaporates completely as soon as
one allows **rational** cubes.  Concretely:

* `sum_two_rational_cubes_form` — the classical parametrisation of sums of two rational cubes:
  `a(a²+3b²)/4 = ((a+b)/2)³ + ((a-b)/2)³`.
* `rationalCubes_five`, `rationalCubes_four` — the two smallest obstructed integers are sums of
  three rational cubes, e.g. `5 = (-2)³ + (7/3)³ + (2/3)³` and
  `4 = (-23)³ + (121/6)³ + (95/6)³`.
* `rationalCubes_of_obstructed_le_113` — explicit rational representations of *all* `26`
  integers `0 ≤ n ≤ 113` with `n ≡ ±4 (mod 9)`; every one of them has denominator `3` or `6`.
* `rationalCubes_window` — combining this with `hasse_of_abs_le_113`: **every** integer with
  `|n| ≤ 113` is a sum of three rational cubes.  So in the whole verified window the rational
  problem has no obstruction whatsoever, in sharp contrast with the integral one.
* `denominator_three_dvd_of_obstructed` — the flip side: any rational representation of an
  obstructed `n` must have denominators divisible by `3`, which is exactly why the integral
  obstruction is invisible over `ℚ`.
* `rational_not_integral_infinite` — there are infinitely many integers that are sums of three
  rational cubes but not of three integer cubes (`5t³` for `3 ∤ t`).
-/

namespace ThreeCubes

/-- `q` is a sum of three **rational** cubes. -/
def IsSumOfThreeRationalCubes (q : ℚ) : Prop := ∃ x y z : ℚ, x ^ 3 + y ^ 3 + z ^ 3 = q

/-- An integral representation is in particular a rational one. -/
theorem isSumOfThreeRationalCubes_of_int {n : ℤ} (h : IsSumOfThreeCubes n) :
    IsSumOfThreeRationalCubes (n : ℚ) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  refine ⟨(x : ℚ), (y : ℚ), (z : ℚ), ?_⟩
  exact_mod_cast congrArg (fun m : ℤ => (m : ℚ)) hxyz

/-- The set of sums of three rational cubes is stable under negation. -/
theorem isSumOfThreeRationalCubes_neg {q : ℚ} (h : IsSumOfThreeRationalCubes q) :
    IsSumOfThreeRationalCubes (-q) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact ⟨-x, -y, -z, by rw [← hxyz]; ring⟩

/-- The set of sums of three rational cubes is stable under multiplication by a cube; this is the
homogeneity of the cubic surface. -/
theorem isSumOfThreeRationalCubes_mul_cube {q : ℚ} (h : IsSumOfThreeRationalCubes q) (t : ℚ) :
    IsSumOfThreeRationalCubes (q * t ^ 3) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact ⟨x * t, y * t, z * t, by rw [← hxyz]; ring⟩

/-- **Clearing denominators.**  An integral solution of `X³ + Y³ + Z³ = n d³` with `d ≠ 0` is
exactly a rational representation of `n` with common denominator `d`.  This is the interface
used for all the certified rational witnesses. -/
theorem rationalCubes_of_scaled (n d X Y Z : ℤ) (hd : d ≠ 0)
    (h : X ^ 3 + Y ^ 3 + Z ^ 3 = n * d ^ 3) : IsSumOfThreeRationalCubes (n : ℚ) := by
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  have h' : (X : ℚ) ^ 3 + (Y : ℚ) ^ 3 + (Z : ℚ) ^ 3 = (n : ℚ) * (d : ℚ) ^ 3 := by
    exact_mod_cast congrArg (fun m : ℤ => (m : ℚ)) h
  refine ⟨(X : ℚ) / d, (Y : ℚ) / d, (Z : ℚ) / d, ?_⟩
  field_simp
  linarith [h']

/-- **The classical parametrisation of sums of two rational cubes.**  Writing `a = y + z` and
`b = y - z` turns `y³ + z³` into `a(a² + 3b²)/4`; conversely every value of that quadratic-form
expression is a sum of two rational cubes.  This is the engine behind every representation below:
one first subtracts a cube `c³` and then hits the remainder with this identity. -/
theorem sum_two_rational_cubes_form (a b : ℚ) :
    ((a + b) / 2) ^ 3 + ((a - b) / 2) ^ 3 = a * (a ^ 2 + 3 * b ^ 2) / 4 := by ring

/-- Consequently, every rational of the shape `c³ + a(a²+3b²)/4` is a sum of three rational
cubes. -/
theorem isSumOfThreeRationalCubes_cube_add_form (c a b : ℚ) :
    IsSumOfThreeRationalCubes (c ^ 3 + a * (a ^ 2 + 3 * b ^ 2) / 4) :=
  ⟨c, (a + b) / 2, (a - b) / 2, by ring⟩

/-- `5 = (-2)³ + (7/3)³ + (2/3)³`.  Note `5 ≡ 5 (mod 9)`, so `5` is **not** a sum of three
integer cubes. -/
theorem rationalCubes_five : IsSumOfThreeRationalCubes 5 :=
  ⟨-2, 7 / 3, 2 / 3, by norm_num⟩

/-- `4 = (-23)³ + (121/6)³ + (95/6)³`.  Note `4 ≡ 4 (mod 9)`, so `4` is **not** a sum of three
integer cubes. -/
theorem rationalCubes_four : IsSumOfThreeRationalCubes 4 :=
  ⟨-23, 121 / 6, 95 / 6, by norm_num⟩

/-- **Rational representations of every obstructed `n` in `[0, 113]`.**  These are the `26`
integers `n ≡ ±4 (mod 9)` with `0 ≤ n ≤ 113`, none of which is a sum of three integer cubes.
Every witness has denominator `3` or `6` — the smallest possible, by
`denominator_three_dvd_of_obstructed`. -/
theorem rationalCubes_of_obstructed_le_113 (n : ℤ) (h0 : 0 ≤ n) (h1 : n ≤ 113)
    (hm : n % 9 = 4 ∨ n % 9 = 5) : IsSumOfThreeRationalCubes (n : ℚ) := by
  have hcase : n = 4 ∨ n = 5 ∨ n = 13 ∨ n = 14 ∨ n = 22 ∨ n = 23 ∨ n = 31 ∨ n = 32 ∨
      n = 40 ∨ n = 41 ∨ n = 49 ∨ n = 50 ∨ n = 58 ∨ n = 59 ∨ n = 67 ∨ n = 68 ∨ n = 76 ∨
      n = 77 ∨ n = 85 ∨ n = 86 ∨ n = 94 ∨ n = 95 ∨ n = 103 ∨ n = 104 ∨ n = 112 ∨
      n = 113 := by omega
  rcases hcase with h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h |
    h | h | h | h | h | h | h <;> subst h
  · exact ⟨-23, 121 / 6, 95 / 6, by norm_num⟩
  · exact ⟨-2, 7 / 3, 2 / 3, by norm_num⟩
  · exact ⟨0, 7 / 3, 2 / 3, by norm_num⟩
  · exact ⟨2 / 3, 7 / 3, 1, by norm_num⟩
  · exact ⟨-3, 11 / 3, -2 / 3, by norm_num⟩
  · exact ⟨1 / 2, 7 / 3, 13 / 6, by norm_num⟩
  · exact ⟨-6, 20 / 3, -11 / 3, by norm_num⟩
  · exact ⟨-46, 121 / 3, 95 / 3, by norm_num⟩
  · exact ⟨2 / 3, 3, 7 / 3, by norm_num⟩
  · exact ⟨-2, 11 / 3, -2 / 3, by norm_num⟩
  · exact ⟨-2 / 3, 11 / 3, 0, by norm_num⟩
  · exact ⟨-2 / 3, 11 / 3, 1, by norm_num⟩
  · exact ⟨-5, 14 / 3, 13 / 3, by norm_num⟩
  · exact ⟨-3, 13 / 3, 5 / 3, by norm_num⟩
  · exact ⟨-8, 25 / 3, 2 / 3, by norm_num⟩
  · exact ⟨11 / 6, 7 / 2, 8 / 3, by norm_num⟩
  · exact ⟨-2 / 3, 11 / 3, 3, by norm_num⟩
  · exact ⟨2 / 3, 4, 7 / 3, by norm_num⟩
  · exact ⟨-1, 13 / 3, 5 / 3, by norm_num⟩
  · exact ⟨0, 13 / 3, 5 / 3, by norm_num⟩
  · exact ⟨5 / 3, 13 / 3, 2, by norm_num⟩
  · exact ⟨-8, 29 / 3, -20 / 3, by norm_num⟩
  · exact ⟨-1, 14 / 3, 4 / 3, by norm_num⟩
  · exact ⟨0, 14 / 3, 4 / 3, by norm_num⟩
  · exact ⟨4 / 3, 14 / 3, 2, by norm_num⟩
  · exact ⟨-2 / 3, 4, 11 / 3, by norm_num⟩

/-- **Every integer with `|n| ≤ 113` is a sum of three rational cubes.**

For `n ≢ ±4 (mod 9)` this follows from the integral verification `hasse_of_abs_le_113`; for the
`52` obstructed values (`±4, ±5, ±13, …, ±113`) genuinely rational witnesses are needed, and are
supplied by `rationalCubes_of_obstructed_le_113`.  Thus in the entire window that is currently
verifiable, the rational problem is unobstructed while the integral one is not. -/
theorem rationalCubes_window (n : ℤ) (h : |n| ≤ 113) : IsSumOfThreeRationalCubes (n : ℚ) := by
  rw [abs_le] at h
  obtain ⟨hlo, hhi⟩ := h
  -- reduce to `0 ≤ n`
  have key : ∀ m : ℤ, 0 ≤ m → m ≤ 113 → IsSumOfThreeRationalCubes (m : ℚ) := by
    intro m hm0 hm1
    by_cases hobs : m % 9 = 4 ∨ m % 9 = 5
    · exact rationalCubes_of_obstructed_le_113 m hm0 hm1 hobs
    · push_neg at hobs
      exact isSumOfThreeRationalCubes_of_int
        (hasse_of_abs_le_113 m (by rw [abs_le]; omega)
          (locallySolvable_of_not_mod_nine hobs.1 hobs.2))
  by_cases hn : 0 ≤ n
  · exact key n hn hhi
  · push_neg at hn
    have := isSumOfThreeRationalCubes_neg (key (-n) (by omega) (by omega))
    simpa using this

/-- **The denominators are forced.**  If `n ≡ ±4 (mod 9)` and `n = x³+y³+z³` with `x, y, z`
rational sharing the common denominator `d`, then `3 ∣ d`.  Indeed otherwise
`X³+Y³+Z³ = n d³` would be an integral representation of an integer `≡ ±4 (mod 9)`.  This
explains why every witness above has denominator a multiple of `3`. -/
theorem denominator_three_dvd_of_obstructed {n : ℤ} (hn : n % 9 = 4 ∨ n % 9 = 5)
    {d X Y Z : ℤ} (h : X ^ 3 + Y ^ 3 + Z ^ 3 = n * d ^ 3) : (3 : ℤ) ∣ d := by
  by_contra hdiv
  -- `d³ ≡ ±1 (mod 9)`, hence `n d³ ≡ ±4 (mod 9)`, contradicting the integral obstruction.
  have hr : d % 3 = 1 ∨ d % 3 = 2 := by omega
  have hkey : (n * d ^ 3) % 9 = 4 ∨ (n * d ^ 3) % 9 = 5 := by
    obtain ⟨k, hk⟩ : ∃ k : ℤ, d = 3 * k + d % 3 := ⟨d / 3, by omega⟩
    rcases hr with hr | hr <;> rw [hr] at hk <;> subst hk
    · have hexp : n * (3 * k + 1) ^ 3 =
          9 * (n * (3 * k ^ 3 + 3 * k ^ 2 + k)) + n := by ring
      rw [hexp]; omega
    · have hexp : n * (3 * k + 2) ^ 3 =
          9 * (n * (3 * k ^ 3 + 6 * k ^ 2 + 4 * k)) + 8 * n := by ring
      rw [hexp]; omega
  exact not_isSumOfThreeCubes_of_mod_nine hkey ⟨X, Y, Z, h⟩

/-- For `3 ∤ t` the integer `5t³` is congruent to `±4` mod `9`, hence is **not** a sum of three
integer cubes. -/
theorem not_isSumOfThreeCubes_five_mul_cube {t : ℤ} (ht : ¬ ((3 : ℤ) ∣ t)) :
    ¬ IsSumOfThreeCubes (5 * t ^ 3) := by
  refine not_isSumOfThreeCubes_of_mod_nine ?_
  have hr : t % 3 = 1 ∨ t % 3 = 2 := by omega
  obtain ⟨k, hk⟩ : ∃ k : ℤ, t = 3 * k + t % 3 := ⟨t / 3, by omega⟩
  rcases hr with hr | hr <;> rw [hr] at hk <;> subst hk
  · have hexp : 5 * (3 * k + 1) ^ 3 = 9 * (15 * k ^ 3 + 15 * k ^ 2 + 5 * k) + 5 := by ring
    right; rw [hexp]; omega
  · have hexp : 5 * (3 * k + 2) ^ 3 = 9 * (15 * k ^ 3 + 30 * k ^ 2 + 20 * k) + 40 := by ring
    left; rw [hexp]; omega

/-- Yet `5t³` *is* always a sum of three rational cubes, by homogeneity from
`5 = (-2)³ + (7/3)³ + (2/3)³`. -/
theorem rationalCubes_five_mul_cube (t : ℤ) :
    IsSumOfThreeRationalCubes ((5 * t ^ 3 : ℤ) : ℚ) := by
  have := isSumOfThreeRationalCubes_mul_cube rationalCubes_five (t : ℚ)
  refine ⟨-2 * (t : ℚ), 7 / 3 * (t : ℚ), 2 / 3 * (t : ℚ), ?_⟩
  push_cast
  ring

/-- **The mod `9` obstruction is purely integral.**  There are infinitely many integers which are
sums of three rational cubes but not sums of three integer cubes: the numbers `5(3m+1)³`. -/
theorem rational_not_integral_infinite :
    {n : ℤ | IsSumOfThreeRationalCubes (n : ℚ) ∧ ¬ IsSumOfThreeCubes n}.Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun m : ℕ => 5 * ((3 : ℤ) * (m : ℤ) + 1) ^ 3) ?_ ?_
  · intro a b hab
    simp only at hab
    have h1 : ((3 : ℤ) * (a : ℤ) + 1) ^ 3 = ((3 : ℤ) * (b : ℤ) + 1) ^ 3 := by linarith
    have h2 : (3 : ℤ) * (a : ℤ) + 1 = (3 : ℤ) * (b : ℤ) + 1 :=
      (Odd.strictMono_pow (R := ℤ) (by decide)).injective h1
    have : (a : ℤ) = (b : ℤ) := by omega
    exact_mod_cast this
  · intro m
    have hnd : ¬ ((3 : ℤ) ∣ (3 * (m : ℤ) + 1)) := by omega
    exact ⟨rationalCubes_five_mul_cube _, not_isSumOfThreeCubes_five_mul_cube hnd⟩

end ThreeCubes