/-! # CatalogBuild.Computation.Fibonacci.ResearchFormalization

Auto-generated from theorem catalog database.
Domain: Computation/Fibonacci
Declarations: 13
-/

import Mathlib

theorem search_space_ratio (k : ℕ) (hk : 2 ≤ k) :
    Nat.fib (k + 2) < 2 ^ k := by
  induction hk <;> simp_all +arith +decide [ Nat.fib_add_two, pow_succ' ];
  grind


theorem search_space_shrinks (k : ℕ) (hk : 5 ≤ k) :
    2 * Nat.fib (k + 2) < 2 ^ k := by
  induction' k using Nat.strong_induction_on with k ih;
  rcases hk with ( _ | _ | _ | _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  grind


/-- F(d) | F(m) whenever d | m. -/
theorem fib_divides_multiples (d m : ℕ) (h : d ∣ m) :
    Nat.fib d ∣ Nat.fib m :=
  Nat.fib_dvd d m h


/-- If p divides F(d), then for any multiple m of d, p divides F(m). -/
theorem prime_fib_divisibility (p d m : ℕ)
    (hpd : p ∣ Nat.fib d) (hdm : d ∣ m) :
    p ∣ Nat.fib m :=
  dvd_trans hpd (fib_divides_multiples d m hdm)


/-- Adjacent Fibonacci numbers are coprime. -/
theorem fib_coprime_adjacent (n : ℕ) :
    Nat.Coprime (Nat.fib n) (Nat.fib (n + 1)) :=
  Nat.fib_coprime_fib_succ n


theorem fib_subexponential_growth (n : ℕ) (hn : 1 ≤ n) :
    Nat.fib (n + 1) ≤ 2 * Nat.fib n := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ fib_add_two ]


theorem fib_subexponential_growth_strict (n : ℕ) (hn : 3 ≤ n) :
    Nat.fib (n + 1) < 2 * Nat.fib n := by
  induction hn <;> simp_all +arith +decide [ Nat.fib_add_two ];
  induction ‹3 ≤ _› <;> simp_all +arith +decide [ Nat.fib_add_two ];
  linarith


/-- A predicate for valid Zeckendorf digit strings: no two consecutive 1s. -/
def ValidZeckendorfBits (bits : ℕ → Bool) (len : ℕ) : Prop :=
  ∀ i, i + 1 < len → ¬(bits i = true ∧ bits (i + 1) = true)


theorem nonadjacency_forward
    (bits : ℕ → Bool) (len : ℕ) (hvalid : ValidZeckendorfBits bits len)
    (i : ℕ) (hi : i + 1 < len) (hset : bits i = true) :
    bits (i + 1) = false := by
  exact not_not.mp fun h => hvalid i hi ⟨ hset, by simpa using h ⟩


theorem nonadjacency_backward
    (bits : ℕ → Bool) (len : ℕ) (hvalid : ValidZeckendorfBits bits len)
    (i : ℕ) (hi : i + 1 < len) (hset : bits (i + 1) = true) :
    bits i = false := by
  grind +locals


theorem carry_cascade_reach (n : ℕ) :
    2 * Nat.fib (n + 2) = Nat.fib (n + 3) + Nat.fib n := by
  norm_num [ two_mul, add_comm, add_left_comm, Nat.fib_add_two ]


theorem parity_constraint_period (n : ℕ) :
    Nat.fib n % 2 = Nat.fib (n + 3) % 2 := by
  simp_all +arith +decide [ Nat.fib_add_two, Nat.add_mod ]


theorem combined_pisano_mod6 (n : ℕ) :
    Nat.fib n % 6 = Nat.fib (n + 24) % 6 := by
  norm_num [ Nat.fib_add, Nat.add_mod, Nat.mul_mod, Nat.mod_self ]

