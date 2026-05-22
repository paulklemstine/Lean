/-
# Reciprocal Binomial Coefficient Sum Bounds

This file proves tight upper bounds on sums of reciprocal binomial coefficients,
which arise naturally as intransitive obstruction bounds in the probabilistic
analysis of random generation in symmetric groups (Dixon's theorem).

## Main Results

* `sum_inv_choose_le`: For n ≥ 6, ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) ≤ 1/n + 5/n².
* `sum_inv_choose_tail_le`: For n ≥ 6, ∑_{k=2}^{⌊n/2⌋} 1/C(n,k) ≤ 5/n².

The constant 5 is not optimal (the true asymptotic is 2 + o(1)) but suffices
for applications to generation probability bounds with explicit constants.

## Proof Strategy

The proof uses a hybrid approach:
- For small n (6 ≤ n ≤ 80), verified by exact rational computation.
- For large n (n > 80), uses monotonicity of binomial coefficients plus an
  algebraic tail bound: the k=2 term contributes 2/(n(n-1)) and the
  remaining terms are bounded by (n/2-2)/C(n,3), giving a total tail of
  (5n-16)/(n(n-1)(n-2)) ≤ 5/n².
-/
import Mathlib

open Finset BigOperators

/-! ### Monotonicity and positivity of binomial coefficients -/

/-
Binomial coefficients are monotone increasing up to n/2.
-/
lemma choose_mono_le_half {n : ℕ} {j k : ℕ} (hj : j ≤ k) (hk : k ≤ n / 2) :
    Nat.choose n j ≤ Nat.choose n k := by
  induction hj <;> simp_all +arith +decide [ Nat.choose ];
  exact le_trans ( by solve_by_elim [ Nat.le_of_lt ] ) ( Nat.choose_le_succ_of_lt_half_left hk )

/-
For 3 ≤ k ≤ n/2 with n ≥ 6, we have C(n,3) ≤ C(n,k).
-/
lemma choose_three_le {n k : ℕ} (hn : 6 ≤ n) (hk3 : 3 ≤ k) (hkn : k ≤ n / 2) :
    Nat.choose n 3 ≤ Nat.choose n k := by
  exact?

/-! ### Reciprocal bound: each term bounded by 1/C(n,3) -/

/-
For 3 ≤ k ≤ n/2 with n ≥ 6, 1/C(n,k) ≤ 1/C(n,3) over ℚ.
-/
lemma inv_choose_le_inv_choose_three {n k : ℕ} (hn : 6 ≤ n)
    (hk3 : 3 ≤ k) (hkn : k ≤ n / 2) :
    (1 : ℚ) / (Nat.choose n k) ≤ 1 / (Nat.choose n 3) := by
  gcongr;
  · exact Nat.cast_pos.mpr ( Nat.choose_pos ( by linarith ) );
  · exact?

/-! ### Algebraic tail bound -/

/-
The key algebraic inequality: (5n-16)·n ≤ 5·(n-1)·(n-2) is equivalent to
    -n - 10 ≤ 0, which holds for all n. In ℕ form: n*(5*n - 16) ≤ 5*(n-1)*(n-2)
    needs care with truncating subtraction, so we state it for n ≥ 6.
-/
lemma algebraic_key_ineq (n : ℕ) (hn : 6 ≤ n) :
    n * (5 * n - 16) ≤ 5 * (n - 1) * (n - 2) := by
  zify [ hn ];
  rw [ Nat.cast_sub, Nat.cast_sub, Nat.cast_sub ] <;> push_cast <;> nlinarith

/-! ### Small cases by computation -/

/-- Verification for n = 6 through 80 by exact rational arithmetic. -/
lemma sum_inv_choose_le_small (n : ℕ) (hn : 6 ≤ n) (hn' : n ≤ 80) :
    (∑ k ∈ Finset.Icc 1 (n / 2), (1 : ℚ) / (Nat.choose n k))
      ≤ (1 : ℚ) / n + 5 / n ^ 2 := by
  interval_cases n <;> native_decide

/-! ### Main theorems -/

/-
**Main Theorem (Corrected Intransitive Obstruction Bound).**
For n ≥ 6, the sum of reciprocal binomial coefficients satisfies
  ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) ≤ 1/n + 5/n².

This gives an explicit upper bound on the intransitive obstruction
probability in the analysis of random generation in Sₙ. The leading
term 1/n captures the dominant k=1 contribution (point stabilizers),
while the 5/n² term bounds all higher-order subset stabilizers.

**Note:** The original conjecture with constant 3 (i.e., 3/n² instead of 5/n²)
is false for n < 15. The constant 5 is the smallest integer that works
for all n ≥ 6. For n ≥ 15, the tighter bound with constant 3 holds.
-/
theorem sum_inv_choose_le (n : ℕ) (hn : 6 ≤ n) :
    (∑ k ∈ Finset.Icc 1 (n / 2), (1 : ℚ) / (Nat.choose n k))
      ≤ (1 : ℚ) / n + 5 / n ^ 2 := by
  by_cases hn_large : n ≤ 80;
  · -- For n ≤ 80, we can verify the inequality by direct computation.
    apply sum_inv_choose_le_small n hn hn_large;
  · -- For n > 80, we'll use the algebraic tail bound.
    have h_tail_bound : (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ (5 * n - 16 : ℚ) / (n * (n - 1) * (n - 2)) := by
      -- Split the sum into two parts: the term for $k=2$ and the terms for $k \geq 3$.
      have h_split : (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) = (1 : ℚ) / (Nat.choose n 2) + (∑ k ∈ Finset.Icc 3 (n / 2), (1 : ℚ) / (Nat.choose n k)) := by
        rw [ Finset.Icc_eq_cons_Ioc ( by omega ), Finset.sum_cons ] ; aesop;
      -- For $k \geq 3$, we have $\frac{1}{\binom{n}{k}} \leq \frac{1}{\binom{n}{3}}$.
      have h_bound : (∑ k ∈ Finset.Icc 3 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ (n / 2 - 2 : ℚ) * (1 / (Nat.choose n 3)) := by
        have h_bound : ∀ k ∈ Finset.Icc 3 (n / 2), (1 : ℚ) / (Nat.choose n k) ≤ (1 : ℚ) / (Nat.choose n 3) := by
          exact fun k hk => one_div_le_one_div_of_le ( Nat.cast_pos.mpr <| Nat.choose_pos <| by linarith [ Finset.mem_Icc.mp hk, Nat.div_mul_le_self n 2 ] ) <| mod_cast choose_three_le hn ( Finset.mem_Icc.mp hk |>.1 ) ( Finset.mem_Icc.mp hk |>.2 );
        refine' le_trans ( Finset.sum_le_sum h_bound ) _ ; norm_num;
        exact mul_le_mul_of_nonneg_right ( by rw [ le_sub_iff_add_le ] ; rw [ le_div_iff₀ ] <;> norm_cast ; omega ) ( by positivity );
      convert add_le_add_left h_bound ( 1 / ( n.choose 2 : ℚ ) ) using 1;
      · grind;
      · rw [ Nat.choose_two_right, Nat.choose_eq_factorial_div_factorial ] <;> norm_num;
        · rcases n with ( _ | _ | _ | n ) <;> norm_num [ Nat.factorial ] at *;
          rw [ Nat.cast_div, Nat.cast_div ] <;> norm_num <;> ring;
          · -- Combine and simplify the fractions
            field_simp
            ring;
            rw [ Nat.add_sub_cancel_left ] ; ring;
          · norm_num [ ← even_iff_two_dvd, parity_simps ];
          · norm_num [ Nat.factorial_succ ];
            exact ⟨ ( n * 11 + n ^ 2 * 6 + n ^ 3 ) / 6, by nlinarith [ Nat.div_mul_cancel ( show 6 ∣ n * 11 + n ^ 2 * 6 + n ^ 3 from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial ) ) ] ⟩;
          · positivity;
        · linarith;
    -- Combine the bounds for the k=1 term and the tail.
    have h_combined_bound : (∑ k ∈ Finset.Icc 1 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ (1 : ℚ) / n + (5 * n - 16 : ℚ) / (n * (n - 1) * (n - 2)) := by
      rw [ Finset.Icc_eq_cons_Ioc ( by omega ), Finset.sum_cons ] ; aesop;
    refine le_trans h_combined_bound ?_;
    rw [ add_le_add_iff_left, div_le_div_iff₀ ] <;> nlinarith only [ show ( n : ℚ ) ≥ 81 by exact_mod_cast not_le.mp hn_large, sq ( n - 6 : ℚ ) ]

/-
**Tail Bound.** For n ≥ 6, the tail sum from k=2 satisfies
  ∑_{k=2}^{⌊n/2⌋} 1/C(n,k) ≤ 5/n².

This isolates the k=1 term (= 1/n) as the dominant contribution,
showing all higher terms are genuinely second-order.
-/
theorem sum_inv_choose_tail_le (n : ℕ) (hn : 6 ≤ n) :
    (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k))
      ≤ 5 / (n : ℚ) ^ 2 := by
  -- Split the sum at k=1.
  have h_split : (∑ k ∈ Finset.Icc 1 (n / 2), (1 : ℚ) / (Nat.choose n k)) = (1 : ℚ) / (Nat.choose n 1) + (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) := by
    rw [ Finset.Icc_eq_cons_Ioc ( Nat.div_pos ( by linarith ) zero_lt_two ), Finset.sum_cons ] ; aesop;
  have := sum_inv_choose_le n hn; norm_num at *; linarith;

/-
**Tighter bound for large n.** For n ≥ 15, the original conjecture
with constant 3 holds:
  ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) ≤ 1/n + 3/n².
-/
theorem sum_inv_choose_le_tight (n : ℕ) (hn : 15 ≤ n) :
    (∑ k ∈ Finset.Icc 1 (n / 2), (1 : ℚ) / (Nat.choose n k))
      ≤ (1 : ℚ) / n + 3 / n ^ 2 := by
  by_cases hn'' : n ≤ 80;
  · interval_cases n <;> native_decide;
  · -- For $n \geq 80$, we can use a refine decomposition
    have hrefined : (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ 2 / (n * (n - 1) : ℚ) + 6 / (n * (n - 1) * (n - 2) : ℚ) + 12 * (n - 6) / (n * (n - 1) * (n - 2) * (n - 3) : ℚ) := by
      -- Split the sum into three parts: k=2, k=3, and k≥4.
      have h_split : (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) = (∑ k ∈ Finset.Icc 2 3, (1 : ℚ) / (Nat.choose n k)) + (∑ k ∈ Finset.Icc 4 (n / 2), (1 : ℚ) / (Nat.choose n k)) := by
        erw [ Finset.sum_Ico_consecutive ] <;> norm_cast ; omega;
      nontriviality;
      -- For $k \geq 4$, we have $\frac{1}{\binom{n}{k}} \leq \frac{1}{\binom{n}{4}}$.
      have h_ge_4 : (∑ k ∈ Finset.Icc 4 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ (n / 2 - 3) * (1 : ℚ) / (Nat.choose n 4) := by
        have h_ge_4 : ∀ k ∈ Finset.Icc 4 (n / 2), (1 : ℚ) / (Nat.choose n k) ≤ (1 : ℚ) / (Nat.choose n 4) := by
          intros k hk;
          gcongr;
          · exact Nat.cast_pos.mpr ( Nat.choose_pos ( by linarith ) );
          · apply choose_mono_le_half;
            · linarith [ Finset.mem_Icc.mp hk ];
            · grind;
        refine le_trans ( Finset.sum_le_sum h_ge_4 ) ?_;
        norm_num [ div_eq_mul_inv ];
        exact mul_le_mul_of_nonneg_right ( by rw [ Nat.cast_sub <| by omega ] ; push_cast ; linarith [ show ( n : ℚ ) ≥ 81 by norm_cast; linarith, show ( n : ℚ ) / 2 ≥ ↑ ( n / 2 ) by exact Nat.cast_div_le .. ] ) <| by positivity;
      refine le_trans h_split.le <| add_le_add ?_ <| h_ge_4.trans ?__;
      · norm_num [ Finset.Icc_eq_cons_Ioc ];
        congr! 1;
        · rw [ Nat.choose_two_right ];
          cases n <;> norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.mod_two_of_bodd ];
        · rw [ Nat.cast_choose ] <;> try linarith;
          rcases n with ( _ | _ | _ | n ) <;> norm_num [ Nat.factorial ] at *;
          rw [ div_eq_div_iff ] <;> first | positivity | ring!;
          positivity;
      · rw [ Nat.cast_choose ] <;> try linarith;
        rcases n with ( _ | _ | _ | _ | n ) <;> norm_num [ Nat.factorial ] at *;
        rw [ div_div_eq_mul_div, div_le_div_iff₀ ] <;> first | positivity | ring_nf ; norm_num [ Nat.factorial_ne_zero ] ;
        positivity;
    -- For $n \geq 80$, we can use the refine decomposition to bound the sum.
    have h_bound : (∑ k ∈ Finset.Icc 2 (n / 2), (1 : ℚ) / (Nat.choose n k)) ≤ 3 / (n ^ 2 : ℚ) := by
      refine le_trans hrefined ?_;
      rw [ div_add_div, div_add_div, div_le_div_iff₀ ] <;> try nlinarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ), sq ( n - 4 : ℚ ) ] ;
      · nlinarith only [ show ( n : ℚ ) ≥ 81 by norm_cast; linarith, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 3, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 4, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 5, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 6, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 7, pow_pos ( show ( n : ℚ ) > 0 by positivity ) 8 ];
      · exact mul_pos ( mul_pos ( mul_pos ( by positivity ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) ) ( mul_pos ( mul_pos ( by positivity ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) ) ) ( mul_pos ( mul_pos ( mul_pos ( by positivity ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) ) ( by linarith [ ( by norm_cast : ( 15 : ℚ ) ≤ n ) ] ) );
      · exact mul_ne_zero ( mul_ne_zero ( by positivity ) ( by linarith [ show ( n : ℚ ) ≥ 81 by norm_cast; linarith ] ) ) ( mul_ne_zero ( mul_ne_zero ( by positivity ) ( by linarith [ show ( n : ℚ ) ≥ 81 by norm_cast; linarith ] ) ) ( by linarith [ show ( n : ℚ ) ≥ 81 by norm_cast; linarith ] ) );
    rw [ Finset.Icc_eq_cons_Ioc, Finset.sum_cons ] <;> norm_num at *;
    · exact h_bound;
    · omega