import Mathlib
import Shared.FibonacciLTE

/-! # Helper lemmas for Carmichael's theorem -/

    (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
    (by aesop)

/-
Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
-/
lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
    padicValNat p (Nat.fib (n * p) / Nat.fib n) = 1 := by
  have := @padicValNat_fib_mul_prime p n hp hp2;
  by_cases h5 : p = 5 <;> simp_all +decide;
  · -- Since $5 \mid F(n)$, we know that $n$ is a multiple of $5$. Let $n = 5k$ for some integer $k$.
    obtain ⟨k, rfl⟩ : ∃ k, n = 5 * k := by
      have h_mod : ∀ n, Nat.fib n % 5 = 0 → 5 ∣ n := by
        intro n hn; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ] ;
        exact ih n ( by linarith ) ( by omega );
      exact h_mod n ( Nat.mod_eq_zero_of_dvd hpn );
    -- Using the identity $F(5n) = F(n) \cdot (25F(n)^4 + 25F(n)^2(-1)^n + 5(-1)^{2n})$, we can simplify the expression.
    have h_fib_5n : ∀ n, Nat.fib (5 * n) = Nat.fib n * (25 * Nat.fib n ^ 4 + 25 * Nat.fib n ^ 2 * (-1 : ℤ) ^ n + 5 * (-1 : ℤ) ^ (2 * n)) := by
      intro n;
      -- Using the closed-form expression for Fibonacci numbers, we can expand $F(5n)$.
      have h_closed_form : ∀ n, Nat.fib n = ((1 + Real.sqrt 5) / 2 : ℝ) ^ n / Real.sqrt 5 - ((1 - Real.sqrt 5) / 2 : ℝ) ^ n / Real.sqrt 5 := by
        intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two ] at *;
        · ring_nf; norm_num;
        · grind +qlia;
      norm_num [ h_closed_form ] ; ring;
      norm_num [ ← @Int.cast_inj ℝ ] ; rw [ h_closed_form, h_closed_form ] ; ring;
      norm_num [ pow_mul', ← mul_pow ] ; ring;
      rw [ show ( Real.sqrt 5 ) ^ 5 = ( Real.sqrt 5 ^ 2 ) ^ 2 * Real.sqrt 5 by ring, show ( Real.sqrt 5 ) ^ 4 = ( Real.sqrt 5 ^ 2 ) ^ 2 by ring, show ( Real.sqrt 5 ) ^ 3 = ( Real.sqrt 5 ^ 2 ) * Real.sqrt 5 by ring, Real.sq_sqrt ( by norm_num ) ] ; ring;
      norm_num [ pow_three, pow_succ, mul_assoc, ← mul_pow ] ; ring;
      norm_num [ pow_three, show ( Real.sqrt 5 ) ⁻¹ ^ 5 = ( Real.sqrt 5 ) ⁻¹ ^ 3 * ( Real.sqrt 5 ) ⁻¹ ^ 2 by ring, show ( Real.sqrt 5 ) ⁻¹ ^ 3 = ( Real.sqrt 5 ) ⁻¹ * ( Real.sqrt 5 ) ⁻¹ ^ 2 by ring, Real.sq_sqrt ] ; ring;
    -- Using the identity $F(5n) = F(n) \cdot (25F(n)^4 + 25F(n)^2(-1)^n + 5(-1)^{2n})$, we can simplify the expression for $F(25k)/F(5k)$.
    have h_fib_25k : Nat.fib (25 * k) / Nat.fib (5 * k) = 25 * Nat.fib (5 * k) ^ 4 + 25 * Nat.fib (5 * k) ^ 2 * (-1 : ℤ) ^ (5 * k) + 5 * (-1 : ℤ) ^ (2 * (5 * k)) := by
      rw [ show 25 * k = 5 * ( 5 * k ) by ring, h_fib_5n ];
      rw [ Int.mul_ediv_cancel_left _ ( Nat.cast_ne_zero.mpr <| ne_of_gt <| Nat.fib_pos.mpr <| by linarith ) ];
    rw [ show 5 * k * 5 = 25 * k by ring ];
    norm_cast at *;
    rw [ padicValNat ];
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
    · grind +splitIndPred;
    · exact absurd ( ‹0 < k → Nat.fib ( 25 * k ) < Nat.fib ( 5 * k ) › ( by linarith ) ) ( not_lt_of_ge ( Nat.fib_mono ( by linarith ) ) );
  · have h_val : padicValNat p (Nat.fib (n * p)) = padicValNat p (Nat.fib n) + padicValNat p (Nat.fib (n * p) / Nat.fib n) := by
      haveI := Fact.mk hp; rw [ ← padicValNat.mul ( Nat.ne_of_gt ( Nat.fib_pos.mpr ( by linarith ) ) ) ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.fib_pos.mpr ( by nlinarith [ hp.pos ] ) ) ( fib_div_fib_dvd _ _ ) ) ( Nat.fib_pos.mpr ( by linarith ) ) ) ), Nat.mul_div_cancel' ( fib_div_fib_dvd _ _ ) ] ;
    linarith [ this ( pos_of_gt hn ) ]

/-
Wall's theorem: v_p(F(n*k)) = v_p(F(n)) + v_p(k) for odd prime p | F(n).
-/
lemma wall_theorem (n k p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) (hk : 0 < k) :
    padicValNat p (Nat.fib (n * k)) = padicValNat p (Nat.fib n) + padicValNat p k := by
    -- Since $p = 5$, we know that $5 \mid n$.
    have h5_div_n : 5 ∣ n := by
      subst h5;
      have h_entry : IsFibEntry 5 5 := by
        exact?;
      exact isFibEntry_dvd_of_dvd h_entry hn hpn;
    obtain ⟨ m, rfl ⟩ := h5_div_n; simp_all +decide [ Nat.fib_two_mul ] ;
    -- By induction on the p-adic valuation of k.
    induction' k using Nat.strong_induction_on with k ih generalizing m;
    by_cases hk5 : 5 ∣ k;
    · obtain ⟨ k, rfl ⟩ := hk5; specialize ih k ( by linarith ) ( by linarith ) ( m * 5 ) ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
      have h_fib_25 : padicValNat 5 (Nat.fib (m * 25)) = padicValNat 5 (Nat.fib (m * 5)) + 1 := by
        have h_fib_25 : padicValNat 5 (Nat.fib (m * 5 * 5)) = padicValNat 5 (Nat.fib (m * 5)) + 1 := by
          have h_fib_25 : 5 ∣ Nat.fib (m * 5) := hpn
          have h_fib_25 : 2 ≤ m * 5 := by linarith
          have := wall_base ( m * 5 ) 5 ( by norm_num ) ( by norm_num ) ( by assumption ) h_fib_25; simp_all +decide [ Nat.fib_add_two, Nat.mul_assoc ] ;
          rw [ ← this, ← Nat.factorization_def, ← Nat.factorization_def ];
          · rw [ ← Nat.factorization_def ];
            · rw [ Nat.factorization_div ] <;> norm_num;
              · rw [ Nat.add_sub_of_le ];
                exact Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 ( Nat.fib_dvd _ _ ( by exact ⟨ 5, by ring ⟩ ) ) 5;
              · convert fib_div_fib_dvd ( m * 5 ) 5 using 1 ; ring;
            · norm_num;
          · norm_num;
          · norm_num;
        convert h_fib_25 using 1 ; ring;
      rw [ ih ] <;> simp_all +decide [ padicValNat.mul, ne_of_gt ];
      · ring;
      · contrapose! h_fib_25; simp_all +decide [ padicValNat.eq_zero_of_not_dvd ] ;
    · have h_weak_wall : ¬(5 ∣ (Nat.fib (5 * m * k) / Nat.fib (5 * m))) := by
        apply_rules [ weak_wall ];
        · norm_num;
        · positivity;
      have h_weak_wall : padicValNat 5 (Nat.fib (5 * m * k)) = padicValNat 5 (Nat.fib (5 * m)) + padicValNat 5 (Nat.fib (5 * m * k) / Nat.fib (5 * m)) := by
        have h_weak_wall : Nat.fib (5 * m) ∣ Nat.fib (5 * m * k) := by
          simpa [ Nat.fib_dvd ];
        haveI := Fact.mk ( by decide : Nat.Prime 5 ) ; rw [ ← padicValNat.mul ( Nat.ne_of_gt ( Nat.fib_pos.mpr ( by positivity ) ) ) ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.fib_pos.mpr ( by positivity ) ) h_weak_wall ) ( Nat.fib_pos.mpr ( by positivity ) ) ) ), Nat.mul_div_cancel' h_weak_wall ] ;
      simp_all +decide [ padicValNat.eq_zero_of_not_dvd ] else padicValNat_fib_lte hp hp2 h5 hn hk hpn