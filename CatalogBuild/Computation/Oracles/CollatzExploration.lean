/-! # CatalogBuild.Computation.Oracles.CollatzExploration

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

/-- The Collatz function: n ↦ n/2 if even, 3n+1 if odd -/
def collatz (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-
Basic property: collatz maps even numbers to half
-/

theorem collatz_even (n : ℕ) (h : 2 ∣ n) : collatz n = n / 2 := by
  exact if_pos ( Nat.mod_eq_zero_of_dvd h )

/-
Basic property: collatz maps odd numbers to 3n+1
-/

theorem collatz_odd (n : ℕ) (h : ¬ 2 ∣ n) : collatz n = 3 * n + 1 := by
  unfold collatz; aesop;

/-! ## Section 2: Structural Properties -/

/-
The Collatz function always produces a positive result for positive input
-/

theorem collatz_pos (n : ℕ) (hn : n > 0) : collatz n > 0 := by
  exact Nat.pos_of_ne_zero ( by unfold collatz; split_ifs <;> omega )

/-
Powers of 2 reach 1 under iterated Collatz application.
    This is the simplest infinite family for which Collatz terminates.
-/

theorem collatz_power_of_two (k : ℕ) : collatz (2 ^ (k + 1)) = 2 ^ k := by
  unfold collatz; norm_num [ pow_succ' ] ;

/-! ## Section 3: Descent Lemma -/

/-
Key insight: for even n, collatz strictly decreases.
    The Oracle of Descent observes that the "even half" of the Collatz map
    is always contracting. The difficulty is that odd steps expand.
-/

theorem collatz_even_descent (n : ℕ) (hn : n > 0) (he : 2 ∣ n) :
    collatz n < n := by
  obtain ⟨ k, hk ⟩ := he;
  unfold collatz; aesop

/-
After any odd step, the next step is always even (since 3n+1 is even when n is odd).
    This means every expansion is immediately followed by a contraction.
-/

theorem collatz_odd_then_even (n : ℕ) (hn : n > 0) (ho : ¬ 2 ∣ n) :
    2 ∣ collatz n := by
  unfold collatz; split_ifs <;> simp_all +arith +decide [ Nat.add_mod, Nat.mul_mod ] ;
  norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod, ho ]

/-! ## Section 4: Modular Analysis -/

/-
Numbers ≡ 0 (mod 2) decrease under one Collatz step
-/

theorem collatz_mod2_zero (n : ℕ) (hn : n > 0) (h : n % 2 = 0) :
    collatz n < n := by
  exact collatz_even_descent n hn ( Nat.dvd_of_mod_eq_zero h )

/-
After two steps on an odd number, the result is (3n+1)/2.
-/

theorem collatz_two_steps_odd (n : ℕ) (hn : n > 0) (ho : ¬ 2 ∣ n) :
    collatz (collatz n) = (3 * n + 1) / 2 := by
  unfold collatz;
  grind

/-! ## Section 5: The 2-adic Valuation Connection -/

/-
The 2-adic valuation of 3n+1 when n is odd determines how many
    "free" halvings we get after an odd step. This is the engine of descent.
-/

theorem collatz_descent_engine (n : ℕ) (hn : n > 0) (ho : n % 2 = 1) :
    ∃ k, k ≥ 1 ∧ (3 * n + 1) = 2 ^ k * ((3 * n + 1) / 2 ^ k) ∧
    ¬ 2 ∣ ((3 * n + 1) / 2 ^ k) := by
  refine' ⟨ Nat.factorization ( 3 * n + 1 ) 2, Nat.pos_of_ne_zero _, _, _ ⟩;
  · norm_num [ Nat.factorization_eq_zero_iff, Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod, ho ];
  · rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ];
  · exact Nat.not_dvd_ordCompl ( by norm_num ) ( by norm_num )
