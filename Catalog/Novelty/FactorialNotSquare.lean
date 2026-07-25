import Mathlib

/-!
# Factorials are almost never perfect squares

This file proves that `n !` is a perfect square if and only if `n ≤ 1`, and the analogous
classification for factorials that are simultaneously square and triangular.

The key ingredient is Bertrand's postulate: for `n ≥ 2` there is a prime `p` with
`n / 2 < p ≤ n`, hence `p ≤ n` and `n < 2 * p`. Such a prime divides `n !` exactly once,
so `p ^ 2 ∤ n !`, which forces `n !` not to be a perfect square.
-/

namespace FactorialNotSquare

/-- A natural number is a perfect square. -/
def IsSquareNat (m : Nat) : Prop := ∃ k : Nat, m = k ^ 2

/-- A natural number is a triangular number. -/
def IsTriangularNat (m : Nat) : Prop := ∃ t : Nat, m = t * (t + 1) / 2

/-
If a prime `p` divides `m` but `p ^ 2` does not, then `m` is not a perfect square.
-/
theorem not_square_of_prime_dvd_not_sq_dvd {p m : Nat} (hp : p.Prime)
    (hdvd : p ∣ m) (hndvd : ¬ p ^ 2 ∣ m) : ¬ IsSquareNat m := by
  rintro ⟨ k, rfl ⟩;
  exact hndvd ( pow_dvd_pow_of_dvd ( hp.dvd_of_dvd_pow hdvd ) 2 )

/-
If `p` is prime with `p ≤ n < 2 * p`, then `p` divides `n !` exactly once,
so `p ^ 2` does not divide `n !`.
-/
theorem not_sq_dvd_factorial {p n : Nat} (hp : p.Prime) (hpn : p ≤ n) (hn : n < 2 * p) :
    ¬ p ^ 2 ∣ n.factorial := by
  -- By Legendre's formula, we have $(n!).factorization p = \sum_{i=1}^{\infty} \left\lfloor \frac{n}{p^i} \right\rfloor$.
  have h_legendre : (n.factorial.factorization p) = ∑ i ∈ Finset.Ico 1 2, n / p ^ i := by
    rw [ Nat.factorization_def ];
    · haveI := Fact.mk hp; rw [ padicValNat_factorial ] ;
      exact Nat.log_lt_of_lt_pow ( by linarith [ hp.pos ] ) ( by nlinarith [ Nat.pow_le_pow_left hp.two_le 2 ] );
    · assumption;
  rw [ Nat.Prime.pow_dvd_iff_le_factorization ] <;> norm_num [ hp ];
  · exact h_legendre.symm ▸ by norm_num; nlinarith [ Nat.div_mul_le_self n p ] ;
  · positivity

/-
For `n ≥ 2`, the factorial `n !` is not a perfect square.
-/
theorem factorial_not_square_of_two_le {n : Nat} (hn : 2 ≤ n) : ¬ IsSquareNat n.factorial := by
  obtain ⟨ p, hp, h ⟩ := Nat.exists_prime_lt_and_le_two_mul ( n / 2 ) ( Nat.ne_of_gt <| Nat.div_pos ( by linarith ) zero_lt_two ) ; have := Nat.exists_prime_lt_and_le_two_mul ( n / 2 ) ; simp_all +decide ;
  exact not_square_of_prime_dvd_not_sq_dvd hp ( Nat.dvd_factorial hp.pos <| by omega ) ( not_sq_dvd_factorial hp ( by omega ) <| by omega )

/-
`n !` is a perfect square iff `n ≤ 1`.
-/
theorem factorial_square_iff_le_one (n : Nat) : IsSquareNat n.factorial ↔ n ≤ 1 := by
  constructor;
  · exact fun h => not_lt.1 fun contra => factorial_not_square_of_two_le contra h;
  · exact fun h => ⟨ 1, by interval_cases n <;> trivial ⟩

/-
`n !` is simultaneously a perfect square and a triangular number iff `n ≤ 1`.
-/
theorem factorial_square_triangular_iff_le_one (n : Nat) :
    IsSquareNat n.factorial ∧ IsTriangularNat n.factorial ↔ n ≤ 1 := by
  constructor;
  · exact fun h => factorial_square_iff_le_one n |>.1 h.1;
  · intro hn
    interval_cases n <;> simp_all +decide [ IsSquareNat, IsTriangularNat ]; all_goals exact ⟨ ⟨ 1, rfl ⟩, ⟨ 1, rfl ⟩ ⟩

end FactorialNotSquare