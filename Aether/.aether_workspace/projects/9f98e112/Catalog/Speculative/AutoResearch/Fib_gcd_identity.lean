import Mathlib
import Speculative.AutoResearch.CarmichaelComposite

/-! # CatalogBuild.Shared.Fib_gcd_identity

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

/-- GCD identity: gcd(F(m), F(n)) = F(gcd(m,n)). -/
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_dvd_chain (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd _ _ h

/-- Carmichael's theorem (weak): For n ≥ 13, F(n) has a primitive prime divisor.
    Uses the full proof from `CarmichaelComposite`. -/
theorem fib_primitive_divisor_existence :
    ∀ n : ℕ, 13 ≤ n → ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  fun n hn => fib_carmichael n hn

/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem fib_linear_lower (n : ℕ) (hn : 6 ≤ n) : n ≤ Nat.fib n := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  exact Nat.recOn n ( by decide ) fun n ihn => by norm_num [ Nat.fib_add_two ] at * ; linarith

/-- F(n) ≤ 2^n for all n. -/
theorem fib_exp_bound (n : ℕ) : Nat.fib n ≤ 2^n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => simp
    | 1 => simp [Nat.fib]
    | n + 2 =>
      rw [Nat.fib_add_two]
      have h1 := ih (n+1) (by omega)
      have h2 := ih n (by omega)
      have : 2^n ≤ 2^(n+1) := Nat.pow_le_pow_right (by omega) (by omega)
      linarith [show 2^(n+2) = 2^(n+1) + 2^(n+1) from by ring]

/-- F(4) = 3. -/
theorem fib_four_val : Nat.fib 4 = 3 := by native_decide
