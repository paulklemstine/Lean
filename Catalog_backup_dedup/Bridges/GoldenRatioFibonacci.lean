import Mathlib

/-! # Golden Ratio–Fibonacci Bridge

New theorems connecting Fibonacci numbers to number theory and the SPB framework.
Builds on Mathlib's existing golden ratio theory.

## Main Results

- `fib_cassini_bridge`: Cassini's identity
- `fib_sum_identity`: ∑ F(k) = F(n+1) - 1
- `fib_sq_sum`: F(n)² + F(n+1)² = F(2n+1)
- `fib_sq_sum_prod`: ∑ F(k+1)² = F(n)·F(n+1)
- `fib_ge_n`: F(n) ≥ n for n ≥ 5
- SPB algebraic properties
-/

open Finset

/-
Cassini's identity: F(n+2)·F(n) - F(n+1)² = (-1)^(n+1).
-/
theorem fib_cassini_bridge (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * Nat.fib n - (Nat.fib (n + 1))^2 = (-1)^(n + 1) := by
  induction n <;> simp_all +decide [ Nat.fib_add_two, pow_succ' ] ; ring;
  rw [ add_comm 1 ] ; linarith

/-
Sum of first n Fibonacci numbers: ∑_{k=0}^{n-1} F(k) = F(n+1) - 1.
-/
theorem fib_sum_identity (n : ℕ) :
    ∑ k ∈ range n, Nat.fib k = Nat.fib (n + 1) - 1 := by
  exact eq_tsub_of_add_eq ( by induction n <;> simp_all +decide [ Finset.sum_range_succ, Nat.fib_add_two ] ; linarith )

/-
Sum of squares: F(n)² + F(n+1)² = F(2n+1).
-/
theorem fib_sq_sum (n : ℕ) :
    Nat.fib n ^ 2 + Nat.fib (n + 1) ^ 2 = Nat.fib (2 * n + 1) := by
  rw [ Nat.fib_two_mul_add_one ];
  ring

/-
|F(n+1)² - F(n+1)·F(n) - F(n)²| = 1, showing that
    consecutive Fibonacci numbers approximate the golden ratio.
-/
theorem fib_ratio_det_one (n : ℕ) :
    |(Nat.fib (n + 1) : ℤ)^2 - (Nat.fib (n + 1) : ℤ) * Nat.fib n
     - (Nat.fib n : ℤ)^2| = 1 := by
  norm_num [ abs_eq, ← fib_cassini_bridge ];
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul, Nat.fib_add_two ] at *;
  · exact Or.inl ( by induction k <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at * ; linarith );
  · exact Nat.recOn k ( by norm_num ) fun n ih => by norm_num [ Nat.fib_add_two, Nat.mul_succ ] at * ; cases ih <;> first | left; linarith | right; linarith;

/-- gcd(F(n), F(n+1)) = 1 — consecutive Fibonacci numbers are coprime. -/
theorem fib_gcd_coprime_succ (n : ℕ) :
    Nat.gcd (Nat.fib n) (Nat.fib (n + 1)) = 1 :=
  Nat.fib_coprime_fib_succ n

/-
F(n) ≥ n for n ≥ 5.
-/
theorem fib_ge_n (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We'll use induction to prove that the Fibonacci sequence grows at least as fast as n.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-
The sum ∑_{k=1}^{n} F(k)² = F(n)·F(n+1).
-/
theorem fib_sq_sum_prod (n : ℕ) :
    ∑ k ∈ range n, Nat.fib (k + 1) ^ 2 = Nat.fib n * Nat.fib (n + 1) := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by rw [ Finset.sum_range_succ, Nat.fib_add_two ] ; linarith;

/-
F(n) < F(n+1) for n ≥ 2.
-/
theorem fib_strict_mono_bridge (n : ℕ) (hn : 2 ≤ n) :
    Nat.fib n < Nat.fib (n + 1) := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ]

/-- SPB is commutative. -/
theorem spb_comm_bridge (x y : ℝ) :
    (x + y) / (1 + x * y) = (y + x) / (1 + y * x) := by ring

/-- SPB has 0 as identity element. -/
theorem spb_zero_bridge (x : ℝ) :
    (x + 0) / (1 + x * 0) = x := by ring

/-- SPB connection: The operation spb(x,y) = (x+y)/(1+xy) preserves
    rationality — if x,y ∈ ℚ and 1+xy ≠ 0, then spb(x,y) ∈ ℚ. -/
theorem spb_rational (x y : ℚ) (h : 1 + x * y ≠ 0) :
    ∃ q : ℚ, (q : ℝ) = ((x : ℝ) + y) / (1 + (x : ℝ) * y) :=
  ⟨(x + y) / (1 + x * y), by push_cast; rfl⟩