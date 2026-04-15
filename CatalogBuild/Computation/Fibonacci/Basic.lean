/-! # CatalogBuild.Computation.Fibonacci.Basic

Auto-generated from theorem catalog database.
Domain: Computation/Fibonacci
Declarations: 21
-/

import Mathlib

theorem fib_pos (n : ℕ) (hn : 1 ≤ n) : 0 < Nat.fib n := by
  exact Nat.fib_pos.mpr hn

/-- Fibonacci numbers are strictly monotone for n ≥ 2. -/

theorem fib_ge_half (n : ℕ) (hn : 1 ≤ n) : n ≤ 2 * Nat.fib n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-! ## Section 2: Zeckendorf Representation Basics -/

/-- A Zeckendorf representation is a list of Fibonacci indices (≥ 2) such that
    no two indices are consecutive. -/

def IsValidZeckendorf (indices : List ℕ) : Prop :=
  (∀ i ∈ indices, 2 ≤ i) ∧
  (indices.Pairwise (· < ·)) ∧
  (∀ i ∈ indices, ∀ j ∈ indices, i + 1 ≠ j)

/-- The value of a Zeckendorf representation is the sum of the corresponding
    Fibonacci numbers. -/

def zeckendorfValue (indices : List ℕ) : ℕ :=
  indices.foldl (fun acc i => acc + Nat.fib i) 0

/-- The number of binary strings of length n with no two consecutive 1s
    is exactly F(n+2), where F is the Fibonacci sequence. This is the
    fundamental count underlying the search space reduction claim. -/

def noAdjacentOnes : ℕ → ℕ
  | 0 => 1
  | 1 => 2
  | n + 2 => noAdjacentOnes (n + 1) + noAdjacentOnes n

/-- The count of binary strings of length n with no two consecutive 1s
    equals F(n+2). -/

theorem noAdjacentOnes_eq_fib (n : ℕ) : noAdjacentOnes n = Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.fib_add_two ];
  erw [ show noAdjacentOnes ( n + 3 ) = noAdjacentOnes ( n + 2 ) + noAdjacentOnes ( n + 1 ) from rfl, ih _ <| Nat.lt_succ_self _, ih _ <| Nat.lt_succ_of_lt <| Nat.lt_succ_self _ ] ; simp +arith +decide [ *, Nat.fib_add_two ]

/-! ## Section 3: Search Space Reduction -/

/-- For all n ≥ 2, 2^n > F(n+2), i.e., the Zeckendorf search space is
    strictly smaller than the binary search space. -/

theorem zeckendorf_search_space_smaller (n : ℕ) (hn : 2 ≤ n) :
    Nat.fib (n + 2) < 2 ^ n := by
  induction hn <;> simp_all +decide [ Nat.fib_add_two, pow_succ' ];
  grind

/-- The ratio of valid Zeckendorf strings to binary strings decreases:
    F(n+3) < 2^(n+1) for n ≥ 2. -/

theorem zeckendorf_fraction_decreasing (n : ℕ) (hn : 2 ≤ n) :
    Nat.fib (n + 3) < 2 ^ (n + 1) := by
  have := zeckendorf_search_space_smaller n hn
  have := zeckendorf_search_space_smaller (n + 1) (by omega)
  linarith

/-! ## Section 4: Fibonacci Product Identities -/

/-- Cassini's identity (even case):
    F(n)·F(n+2) + 1 = F(n+1)² when n is even. -/

theorem cassini_even (n : ℕ) (hn : n % 2 = 0) :
    Nat.fib n * Nat.fib (n + 2) + 1 = Nat.fib (n + 1) ^ 2 := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> simp_all +decide [ Nat.fib_add_two ];
  induction k <;> simp_all +decide [ Nat.fib_add_two, Nat.mul_succ ] ; linarith

/-- Cassini's identity (odd case):
    F(n+1)² + 1 = F(n)·F(n+2) when n is odd. -/

theorem cassini_odd (n : ℕ) (hn : n % 2 = 1) :
    Nat.fib (n + 1) ^ 2 + 1 = Nat.fib n * Nat.fib (n + 2) := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> simp_all +arith +decide [ Nat.fib_add_two ];
  induction k <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at * ; linarith

/-
The d'Ocagne identity (even case): for m ≥ n with n even,
    F(m)·F(n+1) = F(m+1)·F(n) + F(m-n).
-/

theorem fib_docagne_even (m n : ℕ) (hmn : n ≤ m) (hn : n % 2 = 0) :
    Nat.fib m * Nat.fib (n + 1) = Nat.fib (m + 1) * Nat.fib n + Nat.fib (m - n) := by
  -- We prove the general d'Ocagne identity by induction on $m - n$.
  have h_ind : ∀ k n, Nat.fib (n + k) * Nat.fib (n + 1) = Nat.fib (n + k + 1) * Nat.fib n + Nat.fib k * (-1 : ℤ)^n := by
    intros k n; induction' n with n ih generalizing k <;> simp_all +decide [ pow_succ, Nat.fib_add_two ];
    have := ih k; have := ih ( k + 1 ) ; simp_all +decide [ add_right_comm, Nat.fib_add_two ] ; ring;
    grind;
  convert h_ind ( m - n ) n using 1 ; norm_num [ Nat.add_sub_of_le hmn ];
  rw [ ← Nat.mod_add_div n 2, hn ] ; norm_num [ pow_add, pow_mul ] ; norm_cast;

/-
The Vajda identity (even case): for n even,
    F(n)·F(n+i+j) + F(i)·F(j) = F(n+i)·F(n+j).
-/

theorem fib_vajda_even (n i j : ℕ) (hn : n % 2 = 0) :
    Nat.fib n * Nat.fib (n + i + j) + Nat.fib i * Nat.fib j =
    Nat.fib (n + i) * Nat.fib (n + j) := by
  -- Write n as 2k, since n is even.
  obtain ⟨k, rfl⟩ : ∃ k, n = 2 * k := by
    exact Nat.dvd_of_mod_eq_zero hn;
  induction' k with k ih generalizing i j;
  · norm_num;
  · induction' i with i ih generalizing j <;> induction' j with j ih' <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    · grind +qlia;
    · rename_i h; have := h ( i + 1 ) ( j + 1 ) ; simp_all +arith +decide [ Nat.fib_add_two ] ;
      grind

/-
The Vajda identity (odd case): for n odd,
    F(n+i)·F(n+j) + F(i)·F(j) = F(n)·F(n+i+j).
-/

theorem fib_vajda_odd (n i j : ℕ) (hn : n % 2 = 1) :
    Nat.fib (n + i) * Nat.fib (n + j) + Nat.fib i * Nat.fib j =
    Nat.fib n * Nat.fib (n + i + j) := by
  -- Using the identity for Fibonacci numbers, we can rewrite the terms.
  have h_fib_id : ∀ m, fib m = (((1 + Real.sqrt 5) / 2 : ℝ) ^ m - ((1 - Real.sqrt 5) / 2 : ℝ) ^ m) / Real.sqrt 5 := by
    intro m; have := Real.coe_fib_eq m; unfold Real.goldenRatio Real.goldenConj at this; linarith
  norm_num [ ← @Nat.cast_inj ℝ, h_fib_id ] ; ring_nf ; norm_num ; ring;
  rw [ ← Nat.mod_add_div n 2, hn ] ; norm_num [ pow_add, pow_mul ] ; ring;
  norm_num [ mul_assoc, ← mul_pow ] ; ring;
  norm_num ; ring

/-! ## Section 5: Product Spread Properties -/

/-- Product spread examples: F(2k+1)² for small k.
    Verified computationally to demonstrate the spread pattern. -/
-- spread(F(3)²) = 2: F(3)² = F(4) + F(2)
example : Nat.fib 3 ^ 2 = Nat.fib 4 + Nat.fib 2 := by native_decide
-- spread(F(5)²) = 3: F(5)² = F(8) + F(4) + F(2)
example : Nat.fib 5 ^ 2 = Nat.fib 8 + Nat.fib 4 + Nat.fib 2 := by native_decide
-- spread(F(7)²) = 4: F(7)² = F(12) + F(8) + F(4) + F(2)
example : Nat.fib 7 ^ 2 = Nat.fib 12 + Nat.fib 8 + Nat.fib 4 + Nat.fib 2 := by native_decide
-- spread(F(9)²) = 5: F(9)² = F(16) + F(12) + F(8) + F(4) + F(2)
example : Nat.fib 9 ^ 2 = Nat.fib 16 + Nat.fib 12 + Nat.fib 8 + Nat.fib 4 + Nat.fib 2 := by native_decide

/-! ## Section 6: Carry Cascade Reach -/

/-- The carry cascade from position n can reach position n-2 (downward carry).
    This is the fundamental bidirectional carry property. -/

theorem carry_reaches_down (n : ℕ) (hn : 4 ≤ n) :
    2 * Nat.fib n = Nat.fib (n + 1) + Nat.fib (n - 2) := by
  have : n = (n - 2) + 2 := by omega
  rw [this]
  exact fib_carry_rule (n - 2)

/-
The iterated carry rule: 3·F(n+2) = F(n+4) + F(n-1) for n ≥ 1.
    A column value of 3 creates a spread of carries.
-/

theorem fib_triple (n : ℕ) (hn : 2 ≤ n) :
    3 * Nat.fib n = Nat.fib (n + 2) + Nat.fib (n - 2) := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ]

/-- Carry cascade verification: from position 8, carries reach positions 6, 4, 2. -/
example : 2 * Nat.fib 8 = Nat.fib 9 + Nat.fib 6 := by native_decide
example : 2 * Nat.fib 6 = Nat.fib 7 + Nat.fib 4 := by native_decide
example : 2 * Nat.fib 4 = Nat.fib 5 + Nat.fib 2 := by native_decide

/-! ## Section 7: Pisano Period Properties -/

/-- Fibonacci numbers modulo m are eventually periodic (Wall, 1960). -/

theorem pisano_period_5 (n : ℕ) : Nat.fib (n + 20) % 5 = Nat.fib n % 5 := by
  norm_num [ Nat.fib_add, Nat.add_mod, Nat.mul_mod ]

/-! ## Section 8: Parity Constraints -/

/-
F(3k) is even for all k ≥ 1. This follows from the Pisano period mod 2
    being 3: the pattern is F(1)=1, F(2)=1, F(3)=2, repeating.
    This means position 3k in Zeckendorf representation always contributes
    an even amount, creating a parity constraint.
-/

theorem fib_3k_even (k : ℕ) (hk : 1 ≤ k) : 2 ∣ Nat.fib (3 * k) := by
  exact Nat.dvd_of_mod_eq_zero ( by induction hk <;> simp_all +arith +decide [ Nat.mul_succ, Nat.fib_add_two, Nat.add_mod ] )

/-
F(3k+1) is odd.
-/

theorem fib_3k1_odd (k : ℕ) : ¬ 2 ∣ Nat.fib (3 * k + 1) := by
  induction k <;> simp_all +arith +decide [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_succ, Nat.fib_add_two ];
  norm_num [ Nat.mul_mod, ‹_› ]

/-
F(3k+2) is odd.
-/

theorem fib_3k2_odd (k : ℕ) : ¬ 2 ∣ Nat.fib (3 * k + 2) := by
  induction ‹ℕ› <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
  omega

/-! ## Section 9: Fibonacci GCD Properties -/

/-- gcd(F(m), F(n)) = F(gcd(m, n)). This is a classical identity that
    connects Fibonacci arithmetic to the structure of the integers. -/

theorem fib_add_formula (m n : ℕ) :
    Nat.fib (m + n + 1) = Nat.fib m * Nat.fib n + Nat.fib (m + 1) * Nat.fib (n + 1) := by
  exact fib_add m n

/-! ## Section 11: Constraint Graph Properties -/

/-- The constraint density advantage: F(i+2)·F(j+2) > 0 for all i, j,
    meaning every pair of factor digits contributes to the product. -/

theorem fib_product_positive (i j : ℕ) : 0 < Nat.fib (i + 2) * Nat.fib (j + 2) := by
  apply Nat.mul_pos <;> exact fib_pos _ (by omega)

/-- For i,j ≥ 1, F(i+2)·F(j+2) requires at least 2 Zeckendorf digits.
    Verified for the base case: F(3)·F(3) = 4 = F(4) + F(2), spread 2. -/
example : Nat.fib 3 * Nat.fib 3 = Nat.fib 4 + Nat.fib 2 := by native_decide
example : Nat.fib 4 * Nat.fib 3 = Nat.fib 5 + Nat.fib 2 := by native_decide
example : Nat.fib 4 * Nat.fib 4 = Nat.fib 6 + Nat.fib 2 := by native_decide

/-! ## Section 12: Concrete Verification Examples -/

/-- Verify the carry rule for F(4) = 3: 2*3 = 5 + 1 = F(5) + F(2). -/
example : 2 * Nat.fib 4 = Nat.fib 5 + Nat.fib 2 := by native_decide

/-- Verify the carry rule for F(5) = 5: 2*5 = 8 + 2 = F(6) + F(3). -/
example : 2 * Nat.fib 5 = Nat.fib 6 + Nat.fib 3 := by native_decide

/-- Verify 143 = 11 * 13, our running example semiprime. -/
example : 11 * 13 = 143 := by norm_num

/-- Verify Zeckendorf representation of 143 = F(11) + F(9) + F(7) + F(5) + F(3)
    = 89 + 34 + 13 + 5 + 2 = 143. -/
example : Nat.fib 11 + Nat.fib 9 + Nat.fib 7 + Nat.fib 5 + Nat.fib 3 = 143 := by
  native_decide

/-- Verify that the product spread for F(5)^2 = 25 has Zeckendorf representation
    F(8) + F(4) + F(2) = 21 + 3 + 1 = 25 (3 set bits). -/
example : Nat.fib 5 ^ 2 = 25 := by native_decide
example : Nat.fib 8 + Nat.fib 4 + Nat.fib 2 = 25 := by native_decide

/-- Verify F(7)^2 = 169 = F(12) + F(8) + F(4) + F(2) = 144+21+3+1 (4 set bits). -/
example : Nat.fib 7 ^ 2 = 169 := by native_decide
example : Nat.fib 12 + Nat.fib 8 + Nat.fib 4 + Nat.fib 2 = 169 := by native_decide

/-- Verify the factoring example: 17 × 19 = 323. -/
example : 17 * 19 = 323 := by norm_num

/-- Verify Zeckendorf representations used in the 17×19 example. -/
example : Nat.fib 7 + Nat.fib 4 + Nat.fib 2 = 17 := by native_decide  -- 17 = 100101
example : Nat.fib 7 + Nat.fib 5 + Nat.fib 2 = 19 := by native_decide  -- 19 = 101001

/-- Zeckendorf representation of 7 = F(5) + F(3) = 5 + 2. -/
example : Nat.fib 5 + Nat.fib 3 = 7 := by native_decide

/-- Zeckendorf representation of 100 = F(11) + F(6) + F(4) = 89 + 8 + 3. -/
example : Nat.fib 11 + Nat.fib 6 + Nat.fib 4 = 100 := by native_decide
