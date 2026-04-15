/-! # CatalogBuild.Speculative.FibonacciEntryPoint

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7
-/

import Mathlib

theorem fib_cassini_int (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) = (-1) ^ n := by
  induction n <;> simp_all +decide [ pow_succ, fib_add_two ] ; linarith


theorem fib_cassini_variant (n : ℕ) :
    (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) - (Nat.fib (n + 1) : ℤ) ^ 2 = (-1) ^ (n + 1) := by
  induction n <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ; linarith


theorem fib_gcd_dvd (p k m : ℕ) (hk : p ∣ Nat.fib k) (hm : p ∣ Nat.fib m) :
    p ∣ Nat.fib (Nat.gcd k m) := by
  exact Nat.dvd_gcd hk hm |> fun h => by simpa [ Nat.fib_gcd ] using h;


theorem fib_prime_mod (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    (p : ℤ) ∣ ((Nat.fib p : ℤ) ^ 2 - 1) := by
  -- By the properties of the Fibonacci sequence modulo a prime $p$, we know that $F_p \equiv \left(\frac{5}{p}\right) \pmod{p}$ where $\left(\frac{5}{p}\right)$ is the Legendre symbol.
  have h_fib_mod : (fib p) ^ 2 ≡ 1 [ZMOD p] := by
    -- Let's consider the Fibonacci sequence modulo $p$. We know that $F(p) \equiv \left(\frac{5}{p}\right) \pmod{p}$, where $\left(\frac{5}{p}\right)$ is the Legendre symbol.
    have h_legendre : (fib p : ℤ) ≡ jacobiSym 5 p [ZMOD p] := by
      -- By definition of Fibonacci sequence, we know that $F_p = \frac{\phi^p - \psi^p}{\sqrt{5}}$, where $\phi = \frac{1 + \sqrt{5}}{2}$ and $\psi = \frac{1 - \sqrt{5}}{2}$.
      have h_fib_def : (fib p : ℤ) = ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) := by
        have h_fib_def : ∀ n, (fib n : ℝ) = ((1 + Real.sqrt 5) ^ n - (1 - Real.sqrt 5) ^ n) / (2 ^ n * Real.sqrt 5) := by
          intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two ] at *;
          · ring_nf; norm_num;
          · rw [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ] ; repeat ring <;> norm_num [ pow_succ' ];
        exact_mod_cast h_fib_def p;
      -- Let's simplify the expression for $F_p$ modulo $p$.
      have h_fib_mod_simplified : (fib p : ℤ) * 2 ^ (p - 1) ≡ (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) [ZMOD p] := by
        -- Let's simplify the expression for $F_p$ modulo $p$ using the binomial theorem.
        have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 * Real.sqrt 5) = ∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k := by
          have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) := by
            have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k - ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (-Real.sqrt 5) ^ k := by
              exact congrArg₂ _ ( by rw [ add_comm, add_pow ] ; simp +decide [ mul_comm ] ) ( by rw [ sub_eq_add_neg, add_comm, add_pow ] ; simp +decide [ mul_comm ] );
            rw [ h_binom, ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] ; ring;
          -- Let's simplify the sum by separating the terms where $k$ is odd and where $k$ is even.
          have h_split_sum : ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) = ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * Real.sqrt 5 ^ (2 * k + 1) * 2 := by
            have h_binom_simplified : Finset.filter (fun k => k % 2 = 1) (Finset.range (p + 1)) = Finset.image (fun k => 2 * k + 1) (Finset.range ((p + 1) / 2)) := by
              ext ( _ | k ) <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod ];
              exact ⟨ fun h => ⟨ k / 2, by omega, by omega ⟩, fun ⟨ a, ha, ha' ⟩ => ⟨ by omega, by omega ⟩ ⟩;
            simp_all +decide [ Finset.sum_ite ];
          simp_all +decide [ pow_add, pow_mul ];
          rw [ div_eq_iff ( by positivity ) ] ; norm_num [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; cases Nat.Prime.eq_two_or_odd hp <;> simp_all +arith +decide [ Nat.add_div ] ;
        rcases p with ( _ | _ | p ) <;> simp_all +decide [ pow_succ, mul_assoc, div_eq_mul_inv ];
        field_simp at *;
        exact Int.modEq_of_dvd ⟨ 0, by push_cast [ ← @Int.cast_inj ℝ ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ⟩;
      -- Since $p$ is prime and $p \neq 2$, $5$, we know that $\binom{p}{2k+1} \equiv 0 \pmod{p}$ for $k < \frac{p-1}{2}$.
      have h_binom_zero : ∀ k < p / 2, Nat.choose p (2 * k + 1) ≡ 0 [ZMOD p] := by
        exact fun k hk => Int.modEq_zero_iff_dvd.mpr <| mod_cast hp.dvd_choose_self ( by linarith ) ( by linarith [ Nat.div_mul_le_self p 2 ] );
      -- Therefore, the sum simplifies to $5^{(p-1)/2}$ modulo $p$.
      have h_sum_simplified : (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
        rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> simp_all +decide [ Finset.sum_range_succ ];
        · simp_all +decide [ Nat.prime_mul_iff ];
        · norm_num [ Nat.add_div ] at *;
          exact Finset.dvd_sum fun i hi => dvd_mul_of_dvd_left ( Int.dvd_of_emod_eq_zero ( h_binom_zero i ( Finset.mem_range.mp hi ) ) ) _;
      -- By Fermat's Little Theorem, we know that $2^{p-1} \equiv 1 \pmod{p}$.
      have h_fermat : 2 ^ (p - 1) ≡ 1 [ZMOD p] := by
        have := Nat.totient_prime hp; erw [ ← this ] ; simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => hp2 <| by have := Nat.le_of_dvd ( by norm_num ) h; interval_cases p <;> trivial;
      -- Therefore, $F_p \equiv 5^{(p-1)/2} \pmod{p}$.
      have h_fib_final : (fib p : ℤ) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
        simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
      rw [ jacobiSym ];
      norm_num [ Nat.primeFactorsList_prime hp ];
      haveI := Fact.mk hp; simp +decide [ ← ZMod.intCast_eq_intCast_iff, legendreSym.eq_pow ] ;
      cases Nat.Prime.odd_of_ne_two hp hp2 ; simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
      norm_cast at * ; simp_all +decide [ Nat.add_div ];
      convert h_fib_final using 1;
      norm_cast;
      erw [ ZMod.natCast_eq_natCast_iff ];
      simp +decide [ ← ZMod.natCast_eq_natCast_iff, ‹p = _› ];
    convert h_legendre.pow 2 |> Int.ModEq.trans <| _ using 1;
    rw [ jacobiSym.sq_one ];
    exact Nat.coprime_comm.mp ( hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial );
  exact h_fib_mod.symm.dvd


theorem fib_double' (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * (2 * Nat.fib (n + 1) - Nat.fib n) :=
  Nat.fib_two_mul n


theorem fib_double_plus_one (n : ℕ) :
    Nat.fib (2 * n + 1) = Nat.fib (n + 1) ^ 2 + Nat.fib n ^ 2 :=
  Nat.fib_two_mul_add_one n


theorem cassini_factoring (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) ^ 2 - 1 =
    ((Nat.fib (n + 1) : ℤ) - 1) * ((Nat.fib (n + 1) : ℤ) + 1) := by ring
