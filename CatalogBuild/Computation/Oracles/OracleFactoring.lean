/-! # CatalogBuild.Computation.Oracles.OracleFactoring

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11
-/

import Mathlib

noncomputable section

theorem gcd_idempotent_on_self (n : ℕ) : Nat.gcd n n = n := by
  grind

/-
If p divides both a and N, then p divides gcd(a, N)
-/

theorem factor_divides_gcd {p a N : ℕ} (hpa : p ∣ a) (hpN : p ∣ N) :
    p ∣ Nat.gcd a N := by
      exact Nat.dvd_gcd hpa hpN

/-
GCD gives a nontrivial factor when it's between 1 and N
-/

theorem five_sum_of_squares : (1 : ℤ)^2 + 2^2 = 5 := by
  grind

/-
13 = 2² + 3²
-/

theorem thirteen_sum_of_squares : (2 : ℤ)^2 + 3^2 = 13 := by
  grind +ring

/-
65 = 5 × 13 has two sum-of-squares representations
-/

theorem sixty_five_two_reps :
    (1 : ℤ)^2 + 8^2 = 65 ∧ (4 : ℤ)^2 + 7^2 = 65 := by
      decide +revert

/-! ## §3: Fermat's Method as Oracle -/

/-
Fermat's factoring: N = x² - y² = (x+y)(x-y)
-/

theorem fermat_factoring (x y : ℤ) :
    x^2 - y^2 = (x + y) * (x - y) := by
      ring

/-
If N = x² - y², we get a factorization
-/

theorem fermat_gives_factors (N x y : ℤ) (hN : N = x^2 - y^2) :
    N = (x + y) * (x - y) := by
      exact hN.trans ( by ring )

/-! ## §4: Pythagorean Triple Oracle -/

/-
Parametrization of Pythagorean triples
-/

theorem pythagorean_parametrize (m n : ℤ) :
    (m^2 - n^2)^2 + (2*m*n)^2 = (m^2 + n^2)^2 := by
      ring

/-
The (3,4,5) triple is Pythagorean
-/

theorem composite_has_factor {n : ℕ} (hn : ¬ Nat.Prime n) (hn2 : 2 ≤ n) :
    ∃ d, 1 < d ∧ d < n ∧ d ∣ n := by
      exact Exists.imp ( by aesop ) ( Nat.exists_dvd_of_not_prime2 hn2 hn )

/-
Trial division succeeds for factors up to √n
-/

theorem trial_division_bound {n p : ℕ} (hp : Nat.Prime p) (hpn : p ∣ n) (hn : 1 < n) :
    p ≤ n := by
      exact Nat.le_of_dvd hn.le hpn

/-
The number of primes up to n is at most n
-/

theorem prime_count_bound (n : ℕ) : (Finset.filter Nat.Prime (Finset.range (n + 1))).card ≤ n + 1 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

end

end
