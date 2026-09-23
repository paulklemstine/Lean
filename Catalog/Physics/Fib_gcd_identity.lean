import Mathlib
import Speculative.AbstractAlgebra.PisanoPeriodFactoring
import Shared.NumberTheory.CarmichaelProof
import Shared.NumberTheory.CarmichaelHelpers
import Shared.CarmichaelHelper

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




/-- Certified-range Carmichael theorem: for `13 ≤ n ≤ 10000`, `F(n)` has a
primitive prime divisor. -/
theorem fib_primitive_divisor_existence :
    ∀ n : ℕ, 13 ≤ n → n ≤ 10000 → ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro n hn hn2
  by_cases hnp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hnp
  · exact fib_carmichael_composite n hn hn2 hnp



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




/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8] -/
theorem fib_sq_mod_prime (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    (Nat.fib p ^ 2) % p = 1 % p := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_natCast_iff' ] ; ring_nf;
  -- By definition of Fibonacci sequence, we know that $F_p = \frac{(1 + \sqrt{5})^p - (1 - \sqrt{5})^p}{2^p \sqrt{5}}$.
  have h_fib_def : (Nat.fib p : ℤ) = ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) := by
    have h_fib_def : ∀ n, (Nat.fib n : ℝ) = ((1 + Real.sqrt 5) ^ n - (1 - Real.sqrt 5) ^ n) / (2 ^ n * Real.sqrt 5) := by
      intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two ] at *;
      · ring_nf; norm_num;
      · rw [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ] ; repeat ring <;> norm_num [ pow_succ' ] ;
    exact h_fib_def p ▸ by norm_num;
  -- Let's simplify the expression for $F_p$ modulo $p$.
  have h_fib_mod : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) = (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) / 2 ^ (p - 1) := by
    have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) := by
      have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k - ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (-Real.sqrt 5) ^ k := by
        exact congrArg₂ _ ( by rw [ add_comm, add_pow ] ; simp +decide [ mul_comm ] ) ( by rw [ sub_eq_add_neg, add_comm, add_pow ] ; simp +decide [ mul_comm ] );
      rw [ h_binom, ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] ; ring;
    -- Let's simplify the expression for $F_p$ modulo $p$ using the binomial theorem.
    have h_binom_simplified : ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) = 2 * ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * Real.sqrt 5 ^ (2 * k + 1) := by
      have h_binom_simplified : Finset.filter (fun k => k % 2 = 1) (Finset.range (p + 1)) = Finset.image (fun k => 2 * k + 1) (Finset.range ((p + 1) / 2)) := by
        ext ( _ | k ) <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod ];
        exact ⟨ fun h => ⟨ k / 2, by omega, by omega ⟩, fun ⟨ a, ha, ha' ⟩ => ⟨ by omega, by omega ⟩ ⟩;
      simp_all +decide [ Finset.sum_ite, mul_comm, Finset.mul_sum _ _ _ ];
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num [ Nat.add_div ] at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · rw [ h_binom, h_binom_simplified ] ; ring_nf ; norm_num [ pow_add, pow_mul, mul_assoc, mul_left_comm, mul_comm ] ; ring;
      norm_num [ pow_mul', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  -- Let's simplify the expression for $F_p$ modulo $p$ further.
  have h_fib_mod_simplified : (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    have h_fib_mod_simplified : ∀ k ∈ Finset.range (p / 2), Nat.choose p (2 * k + 1) ≡ 0 [ZMOD p] := by
      exact fun k hk => Int.modEq_zero_iff_dvd.mpr <| mod_cast hp.dvd_choose_self ( by linarith [ Finset.mem_range.mp hk ] ) ( by linarith [ Finset.mem_range.mp hk, Nat.div_mul_le_self p 2 ] ) ;
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · norm_num [ Nat.add_div, Finset.sum_range_succ ] at *;
      exact Finset.dvd_sum fun i hi => dvd_mul_of_dvd_left ( Int.dvd_of_emod_eq_zero ( h_fib_mod_simplified i ( Finset.mem_range.mp hi ) ) ) _;
  -- Let's simplify the expression for $F_p$ modulo $p$ further using the fact that $2^{p-1} \equiv 1 \pmod{p}$.
  have h_fib_mod_final : (Nat.fib p : ℤ) * 2 ^ (p - 1) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    convert h_fib_mod_simplified using 1;
    rw [ ← @Int.cast_inj ℝ ] ; aesop;
  have h_fermat : 2 ^ (p - 1) ≡ 1 [ZMOD p] ∧ 5 ^ (p - 1) ≡ 1 [ZMOD p] := by
    have := Nat.totient_prime hp; erw [ ← this ] ; exact ⟨ by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial, by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial ⟩ ;
  simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ ← pow_mul', Nat.mul_div_cancel' <| even_iff_two_dvd.mp <| hp.even_sub_one hp2 ] ; aesop;




theorem fib_composite_test (n : ℕ) (hn : 1 < n) (hn2 : n ≠ 2) (hn5 : n ≠ 5)
    (h : (Nat.fib n ^ 2) % n ≠ 1 % n) :
    ¬Nat.Prime n := by
  exact fun h' => h <| by have := fib_sq_mod_prime n h' hn2 hn5; simpa [ sq, Nat.mul_mod ] using this;




/-- F(4) = 3. -/
theorem fib_four_val : Nat.fib 4 = 3 := by native_decide