import Mathlib

/-!
# Sums of three cubes: basic theory, the mod 9 obstruction, and parametric families

This file sets up the arithmetic of the affine cubic surface
`x³ + y³ + z³ = n` over `ℤ`.

Main contents.

* `ThreeCubes.IsSumOfThreeCubes` — the predicate `∃ x y z : ℤ, x³ + y³ + z³ = n`.
* `ThreeCubes.SolvableMod` / `ThreeCubes.LocallySolvable` — solvability of the
  congruence `x³ + y³ + z³ ≡ n (mod m)`, for one modulus and for all moduli.
* `ThreeCubes.not_isSumOfThreeCubes_of_mod_nine` — the classical congruence
  obstruction: `n ≡ ±4 (mod 9)` is never a sum of three cubes.
* Closure properties: negation, cubic scaling, translation by a cube.
* Two classical one-parameter families showing that `1` and `2` have infinitely
  many representations, and hence that the representation-counting function is
  unbounded.

The deeper statement that `n ≢ ±4 (mod 9)` is the *only* obstruction to local
solvability is proved in `Probability.ThreeCubes.LocalSolvability`.
-/

namespace ThreeCubes

/-- `n` is a sum of three integer cubes. -/
def IsSumOfThreeCubes (n : ℤ) : Prop := ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = n

/-- The congruence `x³ + y³ + z³ ≡ n (mod m)` is solvable. -/
def SolvableMod (m : ℕ) (n : ℤ) : Prop := ∃ x y z : ℤ, (m : ℤ) ∣ x ^ 3 + y ^ 3 + z ^ 3 - n

/-- `n` is *locally solvable*: the congruence `x³ + y³ + z³ ≡ n` is solvable modulo every
positive modulus. Equivalently (by the Chinese remainder theorem and compactness) the affine
surface has a `ℤ_p`-point for every prime `p`. -/
def LocallySolvable (n : ℤ) : Prop := ∀ m : ℕ, 0 < m → SolvableMod m n

/-! ### Elementary closure properties -/

theorem isSumOfThreeCubes_of_eq {n : ℤ} (x y z : ℤ) (h : x ^ 3 + y ^ 3 + z ^ 3 = n) :
    IsSumOfThreeCubes n := ⟨x, y, z, h⟩

theorem isSumOfThreeCubes_cube (k : ℤ) : IsSumOfThreeCubes (k ^ 3) := ⟨k, 0, 0, by ring⟩

theorem isSumOfThreeCubes_neg {n : ℤ} (h : IsSumOfThreeCubes n) : IsSumOfThreeCubes (-n) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact ⟨-x, -y, -z, by rw [← hxyz]; ring⟩

@[simp] theorem isSumOfThreeCubes_neg_iff (n : ℤ) :
    IsSumOfThreeCubes (-n) ↔ IsSumOfThreeCubes n :=
  ⟨fun h => by simpa using isSumOfThreeCubes_neg h, isSumOfThreeCubes_neg⟩

/-- The set of sums of three cubes is stable under multiplication by a cube. -/
theorem isSumOfThreeCubes_mul_cube {n : ℤ} (k : ℤ) (h : IsSumOfThreeCubes n) :
    IsSumOfThreeCubes (k ^ 3 * n) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact ⟨k * x, k * y, k * z, by rw [← hxyz]; ring⟩

/-! ### The mod 9 obstruction -/

/-- Every cube is `0`, `1` or `-1` modulo `9`. -/
theorem cube_mod_nine (x : ZMod 9) : x ^ 3 = 0 ∨ x ^ 3 = 1 ∨ x ^ 3 = 8 := by decide +revert

/-- No sum of three cubes is `≡ 4` or `≡ 5` modulo `9`. -/
theorem sum_three_cubes_ne_four_five (x y z : ZMod 9) :
    x ^ 3 + y ^ 3 + z ^ 3 ≠ 4 ∧ x ^ 3 + y ^ 3 + z ^ 3 ≠ 5 := by decide +revert

theorem intCast_eq_of_emod {n : ℤ} {r : ℤ} (h : n % 9 = r) : (n : ZMod 9) = (r : ZMod 9) := by
  have : n % (9 : ℤ) = r % (9 : ℤ) := by
    rw [h]
    have : r % (9 : ℤ) = r := by
      rw [← h]; exact Int.emod_emod_of_dvd n dvd_rfl
    rw [this]
  exact (ZMod.intCast_eq_intCast_iff' n r 9).mpr this

/-- **Congruence obstruction.**  If `n ≡ 4` or `n ≡ 5 (mod 9)` then `x³ + y³ + z³ ≡ n (mod 9)`
has no solution. -/
theorem not_solvableMod_nine {n : ℤ} (h : n % 9 = 4 ∨ n % 9 = 5) : ¬ SolvableMod 9 n := by
  rintro ⟨x, y, z, hd⟩
  have hcast : ((x ^ 3 + y ^ 3 + z ^ 3 - n : ℤ) : ZMod 9) = 0 := by
    exact_mod_cast (ZMod.intCast_zmod_eq_zero_iff_dvd _ 9).mpr (by exact_mod_cast hd)
  push_cast at hcast
  have hn : ((x : ZMod 9) ^ 3 + (y : ZMod 9) ^ 3 + (z : ZMod 9) ^ 3) = (n : ZMod 9) := by
    linear_combination hcast
  rcases h with h | h
  · have := intCast_eq_of_emod h
    rw [this] at hn
    exact (sum_three_cubes_ne_four_five (x : ZMod 9) y z).1 (by rw [hn]; norm_num)
  · have := intCast_eq_of_emod h
    rw [this] at hn
    exact (sum_three_cubes_ne_four_five (x : ZMod 9) y z).2 (by rw [hn]; norm_num)

/-- **The classical obstruction.** An integer congruent to `±4` mod `9` is not a sum of three
integer cubes. -/
theorem not_isSumOfThreeCubes_of_mod_nine {n : ℤ} (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬ IsSumOfThreeCubes n := by
  rintro ⟨x, y, z, hxyz⟩
  exact not_solvableMod_nine h ⟨x, y, z, by rw [hxyz]; simp⟩

theorem not_locallySolvable_of_mod_nine {n : ℤ} (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬ LocallySolvable n := fun hL => not_solvableMod_nine h (hL 9 (by norm_num))

/-- Being a sum of three cubes implies local solvability. -/
theorem locallySolvable_of_isSumOfThreeCubes {n : ℤ} (h : IsSumOfThreeCubes n) :
    LocallySolvable n := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact fun m _ => ⟨x, y, z, by rw [hxyz]; simp⟩

/-! ### Parametric families -/

/-- Mahler's family: `1` is a sum of three cubes in infinitely many ways. -/
theorem mahler_one (t : ℤ) : (9 * t ^ 4) ^ 3 + (3 * t - 9 * t ^ 4) ^ 3 + (1 - 9 * t ^ 3) ^ 3 = 1 := by
  ring

/-- The classical family for `2`. -/
theorem family_two (t : ℤ) : (1 + 6 * t ^ 3) ^ 3 + (1 - 6 * t ^ 3) ^ 3 + (-6 * t ^ 2) ^ 3 = 2 := by
  ring

/-- The number of representations of `1` as a sum of three cubes is unbounded: the map
`t ↦ (9t⁴, 3t - 9t⁴, 1 - 9t³)` is injective on `ℤ`. -/
theorem mahler_one_injective : Function.Injective
    (fun t : ℤ => ((9 * t ^ 4 : ℤ), (3 * t - 9 * t ^ 4 : ℤ), (1 - 9 * t ^ 3 : ℤ))) := by
  intro a b hab
  simp only [Prod.mk.injEq] at hab
  have h : (1 : ℤ) - 9 * a ^ 3 = 1 - 9 * b ^ 3 := hab.2.2
  have h3 : a ^ 3 = b ^ 3 := by linarith
  exact Odd.strictMono_pow (R := ℤ) (by decide) |>.injective h3

/-- The family for `2` is likewise injective. -/
theorem family_two_injective : Function.Injective
    (fun t : ℤ => ((1 + 6 * t ^ 3 : ℤ), (1 - 6 * t ^ 3 : ℤ), (-6 * t ^ 2 : ℤ))) := by
  intro a b hab
  simp only [Prod.mk.injEq] at hab
  have h : (1 : ℤ) + 6 * a ^ 3 = 1 + 6 * b ^ 3 := hab.1
  have h3 : a ^ 3 = b ^ 3 := by linarith
  exact Odd.strictMono_pow (R := ℤ) (by decide) |>.injective h3

/-- The set of representations of `1` as an ordered sum of three cubes is infinite. -/
theorem infinite_representations_one :
    {p : ℤ × ℤ × ℤ | p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = 1}.Infinite := by
  apply Set.Infinite.mono (s := Set.range
    (fun t : ℤ => ((9 * t ^ 4 : ℤ), (3 * t - 9 * t ^ 4 : ℤ), (1 - 9 * t ^ 3 : ℤ))))
  · rintro _ ⟨t, rfl⟩
    exact mahler_one t
  · exact Set.infinite_range_of_injective mahler_one_injective

/-- The set of representations of `2` as an ordered sum of three cubes is infinite. -/
theorem infinite_representations_two :
    {p : ℤ × ℤ × ℤ | p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = 2}.Infinite := by
  apply Set.Infinite.mono (s := Set.range
    (fun t : ℤ => ((1 + 6 * t ^ 3 : ℤ), (1 - 6 * t ^ 3 : ℤ), (-6 * t ^ 2 : ℤ))))
  · rintro _ ⟨t, rfl⟩
    exact family_two t
  · exact Set.infinite_range_of_injective family_two_injective

end ThreeCubes