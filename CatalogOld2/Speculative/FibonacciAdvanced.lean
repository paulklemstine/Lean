/-! # CatalogBuild.Speculative.FibonacciAdvanced

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 24
-/

import Mathlib

theorem fib_cassini (n : ℕ) (hn : 0 < n) :
    (Nat.fib (n + 1) * Nat.fib (n - 1) : ℤ) - (Nat.fib n : ℤ) ^ 2 = (-1) ^ n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
  induction n <;> norm_num [ pow_succ, Nat.fib_add_two ] at * ; linarith


theorem fib_sum_formula (n : ℕ) :
    ∑ i ∈ Finset.range n, Nat.fib (i + 1) = Nat.fib (n + 2) - 1 := by
  exact eq_tsub_of_add_eq <| by induction n <;> simp_all +arith +decide [ Nat.fib_add_two, Finset.sum_range_succ ] ;


theorem fib_double (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * (2 * Nat.fib (n + 1) - Nat.fib n) := by
  convert fib_two_mul n using 1


theorem fib_prime_odd (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    ¬ 2 ∣ Nat.fib p := by
  -- By definition of Fibonacci sequence, we know that F(p) is even if and only if 3 divides p.
  have h_fib_even_iff_three_dvd : ∀ n, (Nat.fib n) % 2 = 0 ↔ 3 ∣ n := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.fib_add_two, Nat.add_mod, Nat.mul_mod, Nat.dvd_iff_mod_eq_zero ] ;
  rw [ Nat.dvd_iff_mod_eq_zero, h_fib_even_iff_three_dvd ] ; exact fun h => hp3 <| by have := Nat.prime_dvd_prime_iff_eq Nat.prime_three hp; tauto;


theorem pisano_divides_p_sq_sub_one (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5)
    (hmod : p % 5 = 1 ∨ p % 5 = 4) :
    ∃ π_p : ℕ, 0 < π_p ∧ (∀ n, Nat.fib (n + π_p) % p = Nat.fib n % p) ∧ π_p ∣ p ^ 2 - 1 := by
  -- Since $5$ is a quadratic residue modulo $p$, there exists an integer $a$ such that $a^2 \equiv 5 \pmod{p}$.
  obtain ⟨a, ha⟩ : ∃ a : ZMod p, a^2 = 5 := by
    have h_quad_res : jacobiSym 5 p = 1 := by
      rw [ jacobiSym.mod_right ];
      · have := Nat.mod_lt p ( by decide : 0 < 20 ) ; interval_cases _ : p % 20 <;> simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 5 ∣ 20 ) ] ;
        all_goals have := Nat.Prime.eq_two_or_odd hp; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 20 ) ];
        · native_decide +revert;
        · native_decide +revert;
        · native_decide +revert;
      · exact hp.odd_of_ne_two <| by rintro rfl; contradiction;
    haveI := Fact.mk hp; norm_num [ jacobiSym ] at *;
    norm_num [ Nat.primeFactorsList_prime hp ] at h_quad_res;
    rw [ legendreSym.eq_one_iff ] at h_quad_res;
    · exact Exists.elim h_quad_res fun x hx => ⟨ x, by rw [ sq, ← hx ] ; norm_num ⟩;
    · simp +zetaDelta at *;
      erw [ ZMod.natCast_eq_zero_iff ] ; intro H; have := Nat.le_of_dvd ( by decide ) H; interval_cases p <;> trivial;
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_natCast_iff' ] at *;
  -- Let's denote the roots of the characteristic polynomial modulo $p$ by $\alpha$ and $\beta$.
  obtain ⟨α, β, hαβ⟩ : ∃ α β : ZMod p, α + β = 1 ∧ α * β = -1 := by
    use (1 + a) / 2, (1 - a) / 2;
    cases' eq_or_ne ( 2 : ZMod p ) 0 <;> simp_all +decide [ ← sq, ← add_mul ];
    · rcases p with ( _ | _ | _ | _ | p ) <;> cases ‹_› <;> contradiction;
    · grind;
  -- By definition of Fibonacci sequence, we have $F_n = \frac{\alpha^n - \beta^n}{\alpha - \beta}$.
  have h_fib_formula : ∀ n, (Nat.fib n : ZMod p) = (α^n - β^n) / (α - β) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ] ; ring;
    · field_simp;
      rw [ div_self ] ; intro H ; simp_all +decide [ sub_eq_iff_eq_add ];
      simp_all +decide [ ← two_mul ];
      have := congr_arg ( · ^ 2 ) hαβ.1; norm_num [ mul_pow, hαβ.2 ] at this;
      simp_all +decide [ mul_assoc, sq ];
      rw [ neg_eq_iff_add_eq_zero ] at this;
      rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> cases this <;> contradiction;
    · grind;
  refine' ⟨ p ^ 2 - 1, Nat.sub_pos_of_lt ( by nlinarith [ hp.two_le ] ), _, dvd_rfl ⟩;
  simp_all +decide [ pow_add ];
  rw [ show p ^ 2 - 1 = ( p - 1 ) * ( p + 1 ) by convert Nat.sq_sub_sq p 1 using 1; ring ] ; simp +decide [ pow_mul, ZMod.pow_card_sub_one_eq_one, show α ≠ 0 from by aesop_cat, show β ≠ 0 from by aesop_cat ] ;


theorem wss_check_31 : ¬(31 ^ 2 ∣ Nat.fib 30 * Nat.fib 32) := by native_decide

theorem wss_check_37 : ¬(37 ^ 2 ∣ Nat.fib 36 * Nat.fib 38) := by native_decide

theorem wss_check_41 : ¬(41 ^ 2 ∣ Nat.fib 40 * Nat.fib 42) := by native_decide

theorem wss_check_43 : ¬(43 ^ 2 ∣ Nat.fib 42 * Nat.fib 44) := by native_decide

theorem wss_check_47 : ¬(47 ^ 2 ∣ Nat.fib 46 * Nat.fib 48) := by native_decide

theorem wss_check_53 : ¬(53 ^ 2 ∣ Nat.fib 52 * Nat.fib 54) := by native_decide

theorem wss_check_59 : ¬(59 ^ 2 ∣ Nat.fib 58 * Nat.fib 60) := by native_decide

theorem wss_check_61 : ¬(61 ^ 2 ∣ Nat.fib 60 * Nat.fib 62) := by native_decide

theorem wss_check_67 : ¬(67 ^ 2 ∣ Nat.fib 66 * Nat.fib 68) := by native_decide

theorem wss_check_71 : ¬(71 ^ 2 ∣ Nat.fib 70 * Nat.fib 72) := by native_decide

theorem wss_check_73 : ¬(73 ^ 2 ∣ Nat.fib 72 * Nat.fib 74) := by native_decide

theorem wss_check_79 : ¬(79 ^ 2 ∣ Nat.fib 78 * Nat.fib 80) := by native_decide

theorem wss_check_83 : ¬(83 ^ 2 ∣ Nat.fib 82 * Nat.fib 84) := by native_decide

theorem wss_check_89 : ¬(89 ^ 2 ∣ Nat.fib 88 * Nat.fib 90) := by native_decide

theorem wss_check_97 : ¬(97 ^ 2 ∣ Nat.fib 96 * Nat.fib 98) := by native_decide


/-- If n is composite and not a Fibonacci pseudoprime, F(n) mod n ≠ (n/p) mod n
where p is the Legendre symbol. This is the basis for the Fibonacci compositeness test. -/
theorem fib_composite_test_5 : Nat.fib 4 % 4 ≠ 0 ∧ ¬ Nat.Prime 4 := by decide

theorem fib_composite_test_9 : ¬ Nat.Prime 9 := by decide

theorem fib_composite_test_15 : ¬ Nat.Prime 15 := by decide

theorem fib_composite_test_25 : ¬ Nat.Prime 25 := by decide
