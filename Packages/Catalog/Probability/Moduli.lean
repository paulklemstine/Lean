import Probability.ThreeCubes.LocalSolvability

/-!
# `9` is the unique obstructing modulus, and five cubes always suffice

Two complements to the local theory.

* `ThreeCubes.forall_solvableMod_iff` : for a positive modulus `m`, *every* integer is a sum
  of three cubes modulo `m` **iff** `9 ∤ m`.  So among all moduli, `9` (and its multiples)
  is the unique source of congruence obstructions for `x³ + y³ + z³`.

* `ThreeCubes.isSumOfFiveCubes` : **every** integer is a sum of five integer cubes.  Together
  with the mod `9` obstruction this pins the "waring number for cubes over `ℤ`" between `4`
  and `5`; the identity `6k = (k+1)³ + (k-1)³ + (-k)³ + (-k)³` also shows every multiple of
  `6` is a sum of four cubes.
-/

namespace ThreeCubes

/-! ### Solvability modulo `3` -/

/-- Modulo `3` cubing is the identity, so every residue is already a single cube. -/
theorem solvableMod_three (n : ℤ) : SolvableMod 3 n := by
  refine ⟨n, 0, 0, ?_⟩
  have h : n % 3 = 0 ∨ n % 3 = 1 ∨ n % 3 = 2 := by omega
  obtain ⟨q, hq⟩ : ∃ q, n = 3 * q + n % 3 := ⟨n / 3, by omega⟩
  rcases h with h | h | h
  · exact ⟨9 * q ^ 3 - q, by rw [hq, h]; ring⟩
  · exact ⟨9 * q ^ 3 + 9 * q ^ 2 + 2 * q, by rw [hq, h]; ring⟩
  · exact ⟨9 * q ^ 3 + 18 * q ^ 2 + 11 * q + 2, by rw [hq, h]; ring⟩

/-- **`9` is the only obstructing modulus.**  Every integer is a sum of three cubes modulo
`m` precisely when `9` does not divide `m`. -/
theorem forall_solvableMod_iff {m : ℕ} (hm : 0 < m) :
    (∀ n : ℤ, SolvableMod m n) ↔ ¬ (9 ∣ m) := by
  constructor
  · intro h hdvd
    obtain ⟨c, rfl⟩ := hdvd
    obtain ⟨x, y, z, hz⟩ := h 4
    have h9 : SolvableMod 9 (4 : ℤ) := by
      refine ⟨x, y, z, ?_⟩
      have : ((9 : ℤ)) ∣ ((9 * c : ℕ) : ℤ) := by
        push_cast; exact ⟨(c : ℤ), rfl⟩
      exact dvd_trans this hz
    exact not_solvableMod_nine (Or.inl (by norm_num)) h9
  · intro hnd n
    induction m using Nat.recOnPosPrimePosCoprime with
    | prime_pow p k hp hk =>
        by_cases h3 : p = 3
        · subst h3
          have hk1 : k = 1 := by
            by_contra hc
            exact hnd ⟨3 ^ (k - 2), by
              rw [show (9 : ℕ) = 3 ^ 2 by norm_num, ← pow_add]
              congr 1
              omega⟩
          rw [hk1, pow_one]
          exact solvableMod_three n
        · exact solvableMod_prime_pow_ne_three p hp h3 n k
    | zero => exact absurd hm (by omega)
    | one => exact ⟨0, 0, 0, by simp⟩
    | coprime a b ha hb hab iha ihb =>
        refine solvableMod_mul hab (iha (by omega) ?_) (ihb (by omega) ?_)
        · exact fun hd => hnd (hd.trans (Dvd.intro b rfl))
        · exact fun hd => hnd (hd.trans (Dvd.intro_left a rfl))

/-! ### Five cubes always suffice -/

/-- `6k` is a sum of four cubes, for every `k`. -/
theorem six_mul_isSumOfFourCubes (k : ℤ) :
    (k + 1) ^ 3 + (k - 1) ^ 3 + (-k) ^ 3 + (-k) ^ 3 = 6 * k := by ring

/-- `n³ ≡ n (mod 6)` for every integer `n`. -/
theorem six_dvd_cube_sub_self (n : ℤ) : (6 : ℤ) ∣ n ^ 3 - n := by
  have h : n % 6 = 0 ∨ n % 6 = 1 ∨ n % 6 = 2 ∨ n % 6 = 3 ∨ n % 6 = 4 ∨ n % 6 = 5 := by omega
  obtain ⟨q, hq⟩ : ∃ q, n = 6 * q + n % 6 := ⟨n / 6, by omega⟩
  rcases h with h | h | h | h | h | h
  · exact ⟨36 * q ^ 3 - q, by rw [hq, h]; ring⟩
  · exact ⟨36 * q ^ 3 + 18 * q ^ 2 + 2 * q, by rw [hq, h]; ring⟩
  · exact ⟨36 * q ^ 3 + 36 * q ^ 2 + 11 * q + 1, by rw [hq, h]; ring⟩
  · exact ⟨36 * q ^ 3 + 54 * q ^ 2 + 26 * q + 4, by rw [hq, h]; ring⟩
  · exact ⟨36 * q ^ 3 + 72 * q ^ 2 + 47 * q + 10, by rw [hq, h]; ring⟩
  · exact ⟨36 * q ^ 3 + 90 * q ^ 2 + 74 * q + 20, by rw [hq, h]; ring⟩

/-- **Every integer is a sum of five integer cubes.**  This is the sharp contrast with the
three-cube situation, where `n ≡ ±4 (mod 9)` is impossible. -/
theorem isSumOfFiveCubes (n : ℤ) :
    ∃ a b c d e : ℤ, a ^ 3 + b ^ 3 + c ^ 3 + d ^ 3 + e ^ 3 = n := by
  obtain ⟨k, hk⟩ := six_dvd_cube_sub_self n
  refine ⟨n, -k + 1, -k - 1, k, k, ?_⟩
  have : n ^ 3 - n = 6 * k := hk
  linarith [this, show (-k + 1) ^ 3 + (-k - 1) ^ 3 + k ^ 3 + k ^ 3 = -6 * k by ring]

/-- Every multiple of `6` is a sum of four integer cubes. -/
theorem isSumOfFourCubes_of_six_dvd {n : ℤ} (h : (6 : ℤ) ∣ n) :
    ∃ a b c d : ℤ, a ^ 3 + b ^ 3 + c ^ 3 + d ^ 3 = n := by
  obtain ⟨k, rfl⟩ := h
  exact ⟨k + 1, k - 1, -k, -k, by ring⟩

end ThreeCubes