import Mathlib

/-! # CatalogBuild.Computation.Factoring.BridgeTheorems

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9
-/

/-- [Section: # CatalogBuild.Computation.Factoring.BridgeTheorems
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9] -/
theorem cassini_identity (n : ℕ) (hn : 1 ≤ n) :
    (Nat.fib (n + 1) : ℤ) * Nat.fib (n - 1) - (Nat.fib n : ℤ) ^ 2 = (-1) ^ n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
  induction n <;> norm_num [ pow_succ, Nat.fib_add_two ] at * ; linarith

/-- For prime p, totient(p) = p - 1. -/
theorem totient_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 :=
  Nat.totient_prime hp

/-- The order of (ℤ/pℤ)* is p-1 for prime p, connecting to spectral analysis. -/
theorem units_card_prime (p : ℕ) [Fact (Nat.Prime p)] :
    Fintype.card (ZMod p)ˣ = p - 1 := by
  rw [ZMod.card_units_eq_totient]
  exact Nat.totient_prime (Fact.out)

/-- [Section: # CatalogBuild.Computation.Factoring.BridgeTheorems
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9] -/
theorem orbit_size_bound (n : ℕ) (hn : 0 < n) (f : Fin n → Fin n) (x : Fin n) :
    (Finset.image (fun k => f^[k] x) (Finset.range (n + 1))).card ≤ n := by
  exact le_trans ( Finset.card_le_univ _ ) ( by simpa )

theorem min_divisor_bound (n : ℕ) (hn : 1 < n) (hc : ¬ Nat.Prime n) :
    n.minFac ≤ Nat.sqrt n := by
  -- Since n is composite, there exists a factor p such that 1 < p < n. Let's consider the smallest such p.
  obtain ⟨p, hp₁, hp₂⟩ : ∃ p, 1 < p ∧ p < n ∧ p ∣ n := by
    exact Exists.imp ( by tauto ) ( Nat.exists_dvd_of_not_prime2 hn hc );
  cases' hp₂.2 with q hq;
  exact Nat.le_sqrt.2 ( by nlinarith [ Nat.minFac_le_of_dvd ( by linarith ) ( dvd_of_mul_right_eq _ hq.symm ), Nat.minFac_le_of_dvd ( by nlinarith ) ( dvd_of_mul_left_eq _ hq.symm ) ] )

theorem fib_ratio_bound (n : ℕ) (hn : 1 ≤ n) :
    Nat.fib (n + 1) ≤ 2 * Nat.fib n := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ]

/-- Fibonacci numbers satisfy the monotonicity property. -/
theorem fib_monotone (n : ℕ) : Nat.fib n ≤ Nat.fib (n + 1) :=
  Nat.fib_mono (by omega)

/-- In dimension 2, two representations give peel equations via the difference identity. -/
theorem norm_channel_dim2 (a b c d : ℤ) :
    (a*d - b*c) * (a*d + b*c) = a^2 * d^2 - b^2 * c^2 := by ring

/-- Quaternion norm is multiplicative (restated for bridge context). -/
theorem quaternion_norm_multiplicative (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring

