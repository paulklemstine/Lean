import Mathlib

/-!
# 14-gonal numbers that are perfect cubes

The 14th gonal (tetradecagonal) number is `P₁₄(n) = 6n² − 5n = n(6n − 5)`.

This file proves four key lemmas used in the study of which tetradecagonal
numbers are perfect cubes.
-/

namespace TetradecagonalCubes

/-- **Lemma 1 (Factorization and Coprimality).**
`gcd(n, 6n − 5) = gcd(n, 5)` for all integers `n`, because subtracting a
multiple of `n` from the second argument does not change the gcd.
-/
lemma gcd_n_six_mul_sub_five (n : ℤ) :
    Int.gcd n (6 * n - 5) = Int.gcd n 5 := by
  refine' Nat.dvd_antisymm _ _;
  · exact Int.dvd_gcd ( Int.gcd_dvd_left _ _ ) ( by convert Int.dvd_sub ( dvd_mul_of_dvd_right ( Int.gcd_dvd_left _ _ ) 6 ) ( Int.gcd_dvd_right _ _ ) using 1; ring );
  · exact Int.dvd_gcd ( Int.gcd_dvd_left _ _ ) ( dvd_sub ( dvd_mul_of_dvd_right ( Int.gcd_dvd_left _ _ ) _ ) ( Int.gcd_dvd_right _ _ ) )

/-- **Lemma 2 (Case A — Coprime Cube Splitting).**
If `5 ∤ n` and `n(6n − 5)` is a perfect cube, then both `n` and `6n − 5` are
perfect cubes. Since `gcd(n, 6n − 5) ∣ 5` and `5 ∤ n`, the factors are coprime,
and the product of two coprime integers being a cube forces each to be a cube.
-/
lemma case_A_cube_split (n t : ℤ) (h5 : ¬ (5 ∣ n))
    (h : n * (6 * n - 5) = t ^ 3) :
    ∃ a b : ℤ, n = a ^ 3 ∧ 6 * n - 5 = b ^ 3 := by
  -- Let's first show that $n$ and $6n - 5$ are coprime.
  have h_coprime : Int.gcd n (6 * n - 5) = 1 := by
    rw [ ← Int.natAbs_dvd_natAbs ] at *;
    exact Nat.Coprime.symm ( Nat.Prime.coprime_iff_not_dvd ( by decide ) |>.2 h5 ) ▸ gcd_n_six_mul_sub_five n;
  have := Int.eq_pow_of_mul_eq_pow_odd ( show IsCoprime n ( 6 * n - 5 ) from by rwa [ Int.isCoprime_iff_gcd_eq_one ] ) ( by decide : Odd 3 ) h; aesop;

/-- **Lemma 3 (Case B — 5-adic Valuation).**
If `5 ∣ n` and `n(6n − 5)` is a perfect cube, then writing `n = 5m` we must have
`5 ∣ m` or `5 ∣ (6m − 1)`. Otherwise `n(6n − 5) = 25·m·(6m − 1)` would have
5-adic valuation exactly `2`, which cannot be the valuation of a cube.
-/
lemma case_B_five_adic (m t : ℤ)
    (h : (5 * m) * (6 * (5 * m) - 5) = t ^ 3) :
    5 ∣ m ∨ 5 ∣ (6 * m - 1) := by
  -- Since $5 \mid t$, we can write $t = 5s$ for some integer $s$.
  obtain ⟨s, hs⟩ : ∃ s : ℤ, t = 5 * s := by
    exact Int.Prime.dvd_pow' ( by norm_num ) ( h ▸ dvd_mul_of_dvd_left ( dvd_mul_right _ _ ) _ );
  exact Int.Prime.dvd_mul' ( by norm_num ) ( show 5 ∣ m * ( 6 * m - 1 ) by subst hs; use s ^ 3; linarith )

/-- **Lemma 4 (Mordell Transform).**
If `n(6n − 5) = t³` then `(12n − 5)² = 24t³ + 25`, by the algebraic identity
`(12n − 5)² = 144n² − 120n + 25 = 24(6n² − 5n) + 25`.
-/
lemma mordell_transform (n t : ℤ) (h : n * (6 * n - 5) = t ^ 3) :
    (12 * n - 5) ^ 2 = 24 * t ^ 3 + 25 := by
  grind

end TetradecagonalCubes