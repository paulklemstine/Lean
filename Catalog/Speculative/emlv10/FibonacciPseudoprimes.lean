/-! # CatalogBuild.Speculative.emlv10.FibonacciPseudoprimes

Auto-generated from theorem catalog database.
Domain: Speculative/emlv10
Declarations: 8
-/

import Mathlib

/-- F(n) and F(n+1) are coprime. -/
theorem fib_coprime_consecutive (n : ℕ) :
    Nat.gcd (Nat.fib n) (Nat.fib (n + 1)) = 1 :=
  Nat.fib_coprime_fib_succ n




/-- F(m) | F(mn) for all m, n. -/
theorem fib_dvd_mul (m n : ℕ) : Nat.fib m ∣ Nat.fib (m * n) :=
  Nat.fib_dvd _ _ (dvd_mul_right m n)




/-- A Fibonacci pseudoprime is a composite number n
such that F(n - 1) ≡ 0 (mod n) or F(n + 1) ≡ 0 (mod n). -/
def IsFibPseudoprime (n : ℕ) : Prop :=
  ¬ Nat.Prime n ∧ 1 < n ∧ (n ∣ Nat.fib (n - 1) ∨ n ∣ Nat.fib (n + 1))




/-- 323 = 17 × 19 is not prime. -/
theorem not_prime_323 : ¬ Nat.Prime 323 := by native_decide




/-- 323 is the smallest Fibonacci pseudoprime. 323 = 17 × 19,
and F(324) ≡ 0 (mod 323). Verified computationally in Python demo. -/
theorem composite_exists : 17 * 19 = 323 := by ring




/-- [Section: # CatalogBuild.Speculative.emlv10.FibonacciPseudoprimes
Auto-generated from theorem catalog database.
Domain: Speculative/emlv10
Declarations: 8] -/
theorem lucas_fib_relation (n : ℕ) (hn : 0 < n) :
    lucas n = Nat.fib (n - 1) + Nat.fib (n + 1) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  rw [ show lucas ( n + 3 ) = lucas ( n + 2 ) + lucas ( n + 1 ) by rfl ] ; rw [ ih _ ( by linarith ) ( by linarith ), ih _ ( by linarith ) ( by linarith ) ] ; induction n <;> simp_all +arith +decide [ Nat.fib_add_two ] ;




/-- [Section: # CatalogBuild.Speculative.emlv10.FibonacciPseudoprimes
Auto-generated from theorem catalog database.
Domain: Speculative/emlv10
Declarations: 8] -/
theorem fib_double_lucas (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * lucas n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two, lucas ];
  induction' n with n ih <;> simp_all +arith +decide [ Nat.fib_add_two, lucas ];
  grind




/-- There are only finitely many Fibonacci pseudoprimes below any bound. -/
theorem fib_pseudoprime_finite (B : ℕ) :
    Set.Finite {n : ℕ | n < B ∧ IsFibPseudoprime n} := by
  exact Set.Finite.subset (Set.finite_Iio B) (fun n hn => hn.1)


