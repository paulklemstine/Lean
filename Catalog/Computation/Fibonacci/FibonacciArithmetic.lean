/-! # CatalogBuild.Computation.Fibonacci.FibonacciArithmetic

Auto-generated from theorem catalog database.
Domain: Computation/Fibonacci
Declarations: 7
-/

import Mathlib

/-- The fundamental Fibonacci recurrence, reinterpreted as the carry rule.
This is the computational manifestation of φ² = φ + 1. -/
theorem fibonacci_carry_rule (n : ℕ) (hn : n ≥ 1) :
    Nat.fib n + Nat.fib (n + 1) = Nat.fib (n + 2) := by
  rw [Nat.fib_add_two, add_comm]



/-- The double carry rule: when two copies of the same Fibonacci number appear,
they can be decomposed. Specifically: 2 * F(n+2) = F(n+3) + F(n). -/
theorem fibonacci_double_carry (n : ℕ) :
    2 * Nat.fib (n + 2) = Nat.fib (n + 3) + Nat.fib n := by
  simp +arith +decide [Nat.fib_add_two]



/-- The classical identity: gcd(F_m, F_n) = F_{gcd(m, n)}.
This is the foundation of the Fibonacci GCD descent factoring method. -/
theorem fibonacci_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm



/-- Euclid's formula generates Pythagorean triples:
(m²-n²)² + (2mn)² = (m²+n²)² -/
theorem euclid_pythagorean (m n : ℕ) (hmn : n ≤ m) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  zify
  rw [Nat.cast_sub] <;> push_cast <;> nlinarith



/-- The mediant of two fractions a/b < c/d satisfies a/b < (a+c)/(b+d) < c/d.
(Stated for natural numbers to avoid division.) -/
theorem mediant_between (a b c d : ℕ) (hb : b > 0) (hd : d > 0)
    (h : a * d < c * b) :
    a * (b + d) < (a + c) * b ∧ (a + c) * d < c * (b + d) := by
  constructor <;> nlinarith



/-- [Section: # CatalogBuild.Computation.Fibonacci.FibonacciArithmetic
Auto-generated from theorem catalog database.
Domain: Computation/Fibonacci
Declarations: 7] -/
theorem mediant_coprime (a b c d : ℕ)
    (hab : Nat.gcd a b = 1) (hcd : Nat.gcd c d = 1)
    (hdet : a * d + 1 = b * c ∨ b * c + 1 = a * d) :
    Nat.gcd (a + c) (b + d) = 1 := by
  obtain h | h := hdet;
  · by_contra h_contra;
    -- If $g$ is a common divisor of $a+c$ and $b+d$, then $g$ must also divide $(a+c)d - c(b+d) = ad - bc = -1$.
    obtain ⟨g, hg⟩ : ∃ g, 1 < g ∧ g ∣ a + c ∧ g ∣ b + d := by
      exact ⟨ _, lt_of_le_of_ne ( Nat.gcd_pos_of_pos_left _ ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ) ( Ne.symm h_contra ), Nat.gcd_dvd_left _ _, Nat.gcd_dvd_right _ _ ⟩;
    -- Then $g$ must also divide $(a+c)d - c(b+d) = ad - bc = -1$.
    have hg_div_neg1 : (g : ℤ) ∣ (a + c : ℤ) * d - c * (b + d) := by
      exact dvd_sub ( dvd_mul_of_dvd_left ( mod_cast hg.2.1 ) _ ) ( dvd_mul_of_dvd_right ( mod_cast hg.2.2 ) _ );
    exact absurd hg_div_neg1 ( by rw [ show ( a + c : ℤ ) * d - c * ( b + d ) = -1 by linarith ] ; norm_num; exact mod_cast Nat.not_dvd_of_pos_of_lt ( by norm_num ) hg.1 );
  · by_contra h_contra;
    -- Then there exists a prime $p$ such that $p \mid a + c$ and $p \mid b + d$.
    obtain ⟨p, hp_prime, hp_div_ac, hp_div_bd⟩ : ∃ p, Nat.Prime p ∧ p ∣ a + c ∧ p ∣ b + d := by
      exact Nat.Prime.not_coprime_iff_dvd.mp h_contra;
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, Nat.add_mod, Nat.mul_mod ] ;
    replace h := congr_arg ( ( ↑ ) : ℕ → ZMod p ) h ; simp_all +decide [ add_eq_zero_iff_eq_neg ];
    ring_nf at h; aesop;



theorem fib_sum (n : ℕ) :
    (Finset.range n).sum Nat.fib = Nat.fib (n + 1) - 1 := by
  exact eq_tsub_of_add_eq <| by induction n <;> simp_all +decide [ Finset.sum_range_succ, Nat.fib_add_two ] ; linarith


