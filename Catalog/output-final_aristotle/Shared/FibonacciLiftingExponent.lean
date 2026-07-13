import Mathlib

set_option maxHeartbeats 2000000

/-! # A lifting-the-exponent law for Fibonacci numbers

This file proves the *lifting-the-exponent* increment for the Fibonacci sequence:
for an odd prime `p ≠ 5` that divides `F n` (equivalently, `n` is a multiple of the
rank of apparition of `p`), the `p`-adic valuation of the Fibonacci number increases
by exactly one when the index is multiplied by `p`:

`v_p (F (p * n)) = v_p (F n) + 1`.

The proof rests on the closed-form expansion
`2^{p-1} F(p n) = ∑_{k} C(p, 2k+1) · 5^k · F(n)^{2k+1} · L(n)^{p-1-2k}`,
where `L(n) = F(n-1) + F(n+1)` is the companion (Lucas) value, obtained from Binet's
formula and the binomial theorem.  Since `p ∣ F(n)` forces `p ∤ L(n)` (the two share
only a factor of `2`), the term `k = 0` contributes valuation `v_p(F n) + 1`, while
every `k ≥ 1` term contributes at least `v_p(F n) + 2`; the minimum is therefore
attained uniquely at `k = 0`.

This increment is the exact quantitative heart of Carmichael's primitive-divisor
theorem for Fibonacci numbers.
-/
lemma fib_padic_val_mul_prime (p n : ℕ) (hp : p.Prime) (hp2 : 2 < p) (hp5 : p ≠ 5)
    (hpos : 0 < n) (hdvd : p ∣ Nat.fib n) :
    (Nat.fib (p * n)).factorization p = (Nat.fib n).factorization p + 1 := by
  -- From the closed form, we have $2^{p-1} F_{pn} = \sum_{k=0}^{(p-1)/2} \binom{p}{2k+1} 5^k F_n^{2k+1} L_n^{p-1-2k}$.
  have h_closed_form : 2^(p-1) * Nat.fib (p * n) = ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * Nat.fib n^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k) := by
    -- Let's express the Fibonacci numbers using Binet's formula.
    obtain ⟨α, β, hαβ⟩ : ∃ α β : ℝ, α + β = 1 ∧ α * β = -1 ∧ Nat.fib n = (α^n - β^n) / Real.sqrt 5 ∧ Nat.fib (n - 1) + Nat.fib (n + 1) = α^n + β^n := by
      have h_binet : ∀ n : ℕ, Nat.fib n = (((1 + Real.sqrt 5) / 2) ^ n - ((1 - Real.sqrt 5) / 2) ^ n) / Real.sqrt 5 := by
        exact Real.coe_fib_eq;
      rcases n <;> simp_all +decide [ Nat.fib_add_two ] ; ring ; norm_num;
      grind;
    -- Using Binet's formula, we can expand $F_{pn}$ as follows:
    have h_binet : (2^(p-1) * Nat.fib (p * n) : ℝ) = (∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * (Nat.fib n)^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k)) := by
      have h_binet : (α^(p * n) - β^(p * n)) / Real.sqrt 5 * 2^(p-1) = (∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * ((α^n - β^n) / Real.sqrt 5)^(2 * k + 1) * (α^n + β^n)^(p - 1 - 2 * k)) := by
        have h_binet : (α^(p * n) - β^(p * n)) = ((α^n + β^n) + (α^n - β^n))^(p) / 2^p - ((α^n + β^n) - (α^n - β^n))^(p) / 2^p := by
          ring;
          norm_num [ mul_assoc, ← mul_pow ];
        -- Apply the binomial theorem to expand $((α^n + β^n) + (α^n - β^n))^p$ and $((α^n + β^n) - (α^n - β^n))^p$.
        have h_binom : ((α^n + β^n) + (α^n - β^n))^p - ((α^n + β^n) - (α^n - β^n))^p = 2 * ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * (α^n - β^n)^(2 * k + 1) * (α^n + β^n)^(p - 1 - 2 * k) := by
          have h_binom : ((α^n + β^n) + (α^n - β^n))^p - ((α^n + β^n) - (α^n - β^n))^p = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (α^n - β^n)^k * (α^n + β^n)^(p - k) * (if k % 2 = 1 then 2 else 0) := by
            have h_binom : ((α^n + β^n) + (α^n - β^n))^p - ((α^n + β^n) - (α^n - β^n))^p = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (α^n - β^n)^k * (α^n + β^n)^(p - k) - ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (-1)^k * (α^n - β^n)^k * (α^n + β^n)^(p - k) := by
              congr 1;
              · exact by rw [ add_comm, add_pow ] ; ac_rfl;
              · rw [ sub_eq_add_neg, add_comm, add_pow ];
                exact Finset.sum_congr rfl fun _ _ => by rw [ neg_pow ] ; ring;
            rw [ h_binom, ← Finset.sum_sub_distrib ];
            refine Finset.sum_congr rfl fun x hx => ?_ ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] ; ring;
          have h_binom_filter : Finset.filter (fun k => k % 2 = 1) (Finset.range (p + 1)) = Finset.image (fun k => 2 * k + 1) (Finset.range ((p + 1) / 2)) := by
            ext ( _ | k ) <;> simp +arith +decide;
            exact ⟨ fun h => ⟨ k / 2, by omega, by omega ⟩, fun ⟨ a, ha, ha' ⟩ => ⟨ by omega, by omega ⟩ ⟩;
          simp_all +decide [ Finset.sum_ite ];
          rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ Nat.sub_sub, add_comm ] ; ring;
        rcases p <;> simp_all +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
        field_simp at *;
        convert h_binom using 1 ; norm_num [ pow_mul', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
        norm_num [ mul_assoc, mul_comm, mul_left_comm, pow_mul', ← mul_pow ] ; ring;
      convert h_binet using 1;
      · rw [ mul_comm ] ; congr ; induction' p * n using Nat.strong_induction_on with m ih ; rcases m with ( _ | _ | m ) <;> norm_num [ Nat.fib_add_two ] at *;
        · rw [ ← sq_eq_sq₀ ] <;> ring <;> norm_num ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ];
          by_contra h_contra;
          -- Since $\beta > \alpha$, we have $\beta^n > \alpha^n$ for all $n \geq 1$.
          have h_beta_gt_alpha_pow : ∀ n ≥ 1, β^n > α^n := by
            intros n hn; induction hn <;> simp_all +decide [ pow_succ' ] ;
            by_cases hα_neg : α < 0;
            · rename_i k hk ih;
              rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] at *;
              · exact lt_of_lt_of_le ( mul_neg_of_neg_of_pos hα_neg ( pow_pos ( sq_pos_of_neg hα_neg ) _ ) ) ( mul_nonneg ( by nlinarith ) ( pow_nonneg ( sq_nonneg _ ) _ ) );
              · nlinarith [ pow_pos ( sq_pos_of_neg hα_neg ) k, pow_le_pow_left₀ ( by nlinarith ) ( by nlinarith : α ^ 2 ≤ β ^ 2 ) k ];
            · exact mul_lt_mul'' h_contra ‹_› ( by linarith ) ( by exact pow_nonneg ( by linarith ) _ );
          exact absurd hαβ.2.2.1 ( by rw [ eq_div_iff ] <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ), h_beta_gt_alpha_pow n hpos, show ( Nat.fib n : ℝ ) ≥ 1 by exact_mod_cast Nat.fib_pos.mpr hpos ] );
        · grind;
      · simp +decide [ ← hαβ.2.2.1, ← hαβ.2.2.2 ];
    exact_mod_cast h_binet;
  -- Since $p \mid F_n$, the term $k=0$ gives $p * L_n^{p-1} * F_n$ with valuation $v_p(F_n)+1$, and all $k \geq 1$ terms have valuation $\geq 2 v_p(F_n) + ... \geq v_p(F_n) + 2$.
  have h_valuation : Nat.factorization (∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * Nat.fib n^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k)) p = Nat.factorization (Nat.fib n) p + 1 := by
    have h_valuation : ∀ k ∈ Finset.range ((p + 1) / 2), k ≠ 0 → p^(Nat.factorization (Nat.fib n) p + 2) ∣ Nat.choose p (2 * k + 1) * 5^k * Nat.fib n^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k) := by
      intro k hk hk'; refine' dvd_mul_of_dvd_left _ _; refine' dvd_mul_of_dvd_right _ _;
      rw [ ← Nat.factorization_le_iff_dvd ] <;> norm_num;
      · intro i; by_cases hi : p = i <;> simp_all +decide [ Nat.factorization_eq_zero_iff ] ;
        nlinarith [ show k > 0 from Nat.pos_of_ne_zero hk', show Nat.factorization ( Nat.fib n ) i > 0 from Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ) ];
      · linarith;
      · omega;
    have h_valuation : p^(Nat.factorization (Nat.fib n) p + 1) ∣ ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * Nat.fib n^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k) ∧ ¬p^(Nat.factorization (Nat.fib n) p + 2) ∣ ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * 5^k * Nat.fib n^(2 * k + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * k) := by
      have h_valuation : ¬p^(Nat.factorization (Nat.fib n) p + 2) ∣ Nat.choose p 1 * 5^0 * Nat.fib n^(2 * 0 + 1) * (Nat.fib (n - 1) + Nat.fib (n + 1))^(p - 1 - 2 * 0) := by
        have h_valuation : ¬p ∣ (Nat.fib (n - 1) + Nat.fib (n + 1)) := by
          have h_coprime : Nat.gcd (Nat.fib n) (Nat.fib (n - 1) + Nat.fib (n + 1)) ∣ 2 := by
            rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
            norm_num [ ( by ring : Nat.fib ( n + 1 ) + ( Nat.fib ( n + 1 ) + ( Nat.fib n + Nat.fib ( n + 1 ) ) ) = Nat.fib n + Nat.fib ( n + 1 ) + ( Nat.fib ( n + 1 ) + Nat.fib ( n + 1 ) ) ) ];
            norm_num [ ( by ring : Nat.fib ( n + 1 ) + Nat.fib ( n + 1 ) = 2 * Nat.fib ( n + 1 ) ), Nat.gcd_comm ];
            have h_coprime : Nat.gcd (Nat.fib n + Nat.fib (n + 1)) (Nat.fib (n + 1)) = 1 := by
              exact Nat.recOn n ( by norm_num ) fun n ih => by simp_all +decide [ Nat.fib_add_two, Nat.gcd_comm ] ;
            exact Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( Nat.gcd ( Nat.fib n + Nat.fib ( n + 1 ) ) ( 2 * Nat.fib ( n + 1 ) ) ) ( Nat.fib ( n + 1 ) ) from Nat.Coprime.coprime_dvd_left ( Nat.gcd_dvd_left _ _ ) h_coprime ) ( Nat.gcd_dvd_right _ _ );
          exact fun h => by have := Nat.dvd_trans ( Nat.dvd_gcd hdvd h ) h_coprime; exact absurd this ( Nat.not_dvd_of_pos_of_lt ( by positivity ) ( by linarith ) ) ;
        rw [ Nat.Prime.pow_dvd_iff_le_factorization ] <;> norm_num [ hp ];
        · rw [ Nat.factorization_mul, Nat.factorization_mul ] <;> simp_all +decide [ Nat.Prime.factorization ];
          · rw [ Nat.factorization_eq_zero_of_not_dvd h_valuation ] ; norm_num ; linarith [ Nat.sub_add_cancel hp.pos ];
          · grind +splitImp;
          · linarith;
          · aesop;
        · exact ⟨ hp.ne_zero, hpos.ne' ⟩;
      constructor;
      · refine' Finset.dvd_sum fun k hk => _;
        by_cases hk0 : k = 0 <;> simp_all +decide [ Nat.factorization_eq_zero_iff ];
        · rw [ pow_succ' ];
          exact dvd_mul_of_dvd_left ( mul_dvd_mul_left _ ( Nat.ordProj_dvd _ _ ) ) _;
        · exact dvd_trans ( pow_dvd_pow _ ( Nat.le_succ _ ) ) ( by solve_by_elim );
      · rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_range.mpr ( show 0 < ( p + 1 ) / 2 from Nat.div_pos ( by linarith ) zero_lt_two ) ) ];
        rw [ Nat.dvd_add_left ];
        · assumption;
        · exact Finset.dvd_sum fun x hx => by aesop;
    obtain ⟨ k, hk ⟩ := h_valuation.1;
    rw [ hk, Nat.factorization_mul ] <;> norm_num [ hp.ne_zero ];
    · simp_all +decide [ hp.factorization ];
      exact Nat.factorization_eq_zero_of_not_dvd fun h => h_valuation <| mul_dvd_mul_left _ h;
    · rintro rfl; simp_all +decide [ ne_of_gt hp.pos ];
  rw [ ← h_valuation, ← h_closed_form, Nat.factorization_mul ] <;> norm_num [ hp.ne_zero, hp.ne_one ];
  · rw [ Finsupp.single_apply, Finsupp.single_apply ] ; aesop_cat;
  · linarith