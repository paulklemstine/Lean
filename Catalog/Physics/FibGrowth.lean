import Mathlib

/-! # Fibonacci growth lemmas

Key results:
- `fib_add_ge_mul`: F(a + b) ≥ F(a) * F(b) for a, b ≥ 1
- `fib_mul_ge_pow`: F(a * b) ≥ F(a) ^ b for a, b ≥ 1
- Strict monotonicity and lower bounds
-/

set_option maxHeartbeats 400000

/-
From Nat.fib_add, we get F(m+n+1) = F(m)*F(n) + F(m+1)*F(n+1) ≥ F(m+1)*F(n+1)
-/
lemma fib_add_one_ge_mul (m n : ℕ) :
    Nat.fib (m + 1) * Nat.fib (n + 1) ≤ Nat.fib (m + n + 1) := by
  induction' m with m ih generalizing n <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ]

/-
F(a + b) ≥ F(a) * F(b) for a ≥ 1, b ≥ 1
-/
lemma fib_add_ge_mul {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    Nat.fib a * Nat.fib b ≤ Nat.fib (a + b) := by
  obtain ⟨ m, rfl ⟩ := Nat.exists_eq_add_of_le ha;
  induction' b with b hb <;> simp_all +arith +decide [ Nat.fib_add ]

/-
F(a * b) ≥ F(a) ^ b for a ≥ 1, b ≥ 1
-/
lemma fib_mul_ge_pow {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    Nat.fib a ^ b ≤ Nat.fib (a * b) := by
  induction hb <;> simp_all +decide [ Nat.fib_add, pow_succ', Nat.mul_succ ];
  refine le_trans ( Nat.mul_le_mul_left _ ‹_› ) ?_;
  convert fib_add_ge_mul ( show 1 ≤ a * _ from Nat.mul_pos ha ‹_› ) ha using 1 ; ring

/-
F(n) is strictly monotone for n ≥ 2
-/
lemma fib_strictMono_of_ge_two {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) :
    Nat.fib a < Nat.fib b :=
  (Nat.fib_lt_fib ha).mpr hab

/-
F(n) ≥ n for n ≥ 5
-/
lemma fib_ge_self {n : ℕ} (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  exact Nat.recOn n ( by norm_num ) fun n ih ↦ by norm_num [ Nat.fib_add_two ] at * ; linarith;

/-
For composite n ≥ 4, n/p < n where p is any prime factor
-/
lemma div_lt_of_prime_dvd {n p : ℕ} (hp : Nat.Prime p) (hdvd : p ∣ n) (hn : 2 ≤ n) :
    n / p < n := by
  exact Nat.div_lt_self ( by positivity ) hp.one_lt

/-
F(n) / F(d) > 1 when n > d ≥ 2 and d | n
-/
lemma fib_div_gt_one {n d : ℕ} (hd : 2 ≤ d) (hdn : d ∣ n) (hlt : d < n) :
    1 < Nat.fib n / Nat.fib d := by
  -- By Nat.fib_dvd, since d divides n, we have Nat.fib d ∣ Nat.fib n.
  have h_div : Nat.fib d ∣ Nat.fib n := by
    exact Nat.fib_dvd d n hdn
  nlinarith [ Nat.div_mul_cancel h_div, Nat.fib_pos.mpr ( by linarith : 0 < d ), show Nat.fib n > Nat.fib d from fib_strictMono_of_ge_two hd hlt ]