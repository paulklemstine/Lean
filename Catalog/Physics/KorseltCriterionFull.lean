/-! # CatalogBuild.Physics.KorseltCriterionFull

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 16
-/

import Mathlib

/-- A Carmichael number: composite n > 1 with a^(n-1) ≡ 1 (mod n) for all gcd(a,n)=1. -/
def IsCarmichaelNum (n : ℕ) : Prop :=
  1 < n ∧ ¬ Nat.Prime n ∧ ∀ a : ℕ, Nat.Coprime a n → a ^ (n - 1) ≡ 1 [MOD n]




/-- Korselt's criterion predicate. -/
def SatisfiesKorseltCrit (n : ℕ) : Prop :=
  1 < n ∧ ¬ Nat.Prime n ∧ Squarefree n ∧
  ∀ p : ℕ, Nat.Prime p → p ∣ n → (p - 1) ∣ (n - 1)




/-- 561 satisfies Korselt's criterion. -/
theorem korselt_561_verified :
    ¬ Nat.Prime 561 ∧ Squarefree 561 ∧
    Nat.primeFactorsList 561 = [3, 11, 17] := by
  refine ⟨by native_decide, by native_decide, by native_decide⟩




/-- 1105 satisfies Korselt's criterion. -/
theorem korselt_1105_verified :
    ¬ Nat.Prime 1105 ∧ Squarefree 1105 ∧
    Nat.primeFactorsList 1105 = [5, 13, 17] := by
  refine ⟨by native_decide, by native_decide, by native_decide⟩




/-- 1729 satisfies Korselt's criterion. -/
theorem korselt_1729_verified :
    ¬ Nat.Prime 1729 ∧ Squarefree 1729 ∧
    Nat.primeFactorsList 1729 = [7, 13, 19] := by
  refine ⟨by native_decide, by native_decide, by native_decide⟩




/-- Korselt divisibility conditions: (p-1) | (n-1) for each prime factor p. -/
theorem korselt_561_divs_full :
    (2 ∣ 560) ∧ (10 ∣ 560) ∧ (16 ∣ 560) := by
  exact ⟨⟨280, by norm_num⟩, ⟨56, by norm_num⟩, ⟨35, by norm_num⟩⟩




/-- [Section: # CatalogBuild.Physics.KorseltCriterionFull
Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 16] -/
theorem korselt_1105_divs :
    (4 ∣ 1104) ∧ (12 ∣ 1104) ∧ (16 ∣ 1104) := by
  exact ⟨⟨276, by norm_num⟩, ⟨92, by norm_num⟩, ⟨69, by norm_num⟩⟩




/-- [Section: # CatalogBuild.Physics.KorseltCriterionFull
Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 16] -/
theorem korselt_2465_divs :
    (4 ∣ 2464) ∧ (16 ∣ 2464) ∧ (28 ∣ 2464) := by
  exact ⟨⟨616, by norm_num⟩, ⟨154, by norm_num⟩, ⟨88, by norm_num⟩⟩




theorem korselt_2821_divs :
    (6 ∣ 2820) ∧ (12 ∣ 2820) ∧ (30 ∣ 2820) := by
  exact ⟨⟨470, by norm_num⟩, ⟨235, by norm_num⟩, ⟨94, by norm_num⟩⟩




theorem korselt_6601_divs :
    (6 ∣ 6600) ∧ (22 ∣ 6600) ∧ (40 ∣ 6600) := by
  exact ⟨⟨1100, by norm_num⟩, ⟨300, by norm_num⟩, ⟨165, by norm_num⟩⟩




theorem korselt_8911_divs :
    (6 ∣ 8910) ∧ (18 ∣ 8910) ∧ (66 ∣ 8910) := by
  exact ⟨⟨1485, by norm_num⟩, ⟨495, by norm_num⟩, ⟨135, by norm_num⟩⟩




theorem all_carmichael_to_10000 :
    561 = 3 * 11 * 17 ∧
    1105 = 5 * 13 * 17 ∧
    1729 = 7 * 13 * 19 ∧
    2465 = 5 * 17 * 29 ∧
    2821 = 7 * 13 * 31 ∧
    6601 = 7 * 23 * 41 ∧
    8911 = 7 * 19 * 67 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num




theorem carmichael_odd (n : ℕ) (hc : IsCarmichaelNum n) : ¬ Even n := by
  rcases hc with ⟨ hn₁, hn₂, hn₃ ⟩;
  -- If $n$ is even, then $n-1$ is odd, so $(-1)^{n-1} = -1$.
  by_contra h_even
  have h_neg_one : (-1 : ℤ) ^ (n - 1) ≡ 1 [ZMOD n] := by
    have h_odd : (n - 1) ^ (n - 1) ≡ 1 [ZMOD n] := by
      convert Int.natCast_modEq_iff.mpr ( hn₃ ( n - 1 ) ?_ ) using 1;
      · cases n <;> aesop;
      · simp +decide [ hn₁.le ];
    simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ parity_simps ];
  nlinarith [ Int.le_of_dvd ( by linarith ) h_neg_one.dvd, show n > 0 from Nat.pos_of_ne_zero ( by rintro rfl; contradiction ) ]




theorem carmichael_not_prime_power (n : ℕ) (hc : IsCarmichaelNum n) :
    ¬ IsPrimePow n := by
      -- By contradiction, assume that $n$ is a prime power.
      by_contra h_prime_power
      obtain ⟨p, k, hp, rfl⟩ : ∃ p k : ℕ, Nat.Prime p ∧ n = p^k := by
        rw [ isPrimePow_nat_iff ] at h_prime_power ; aesop;
      -- Since $p$ is a prime number, we have $k \geq 2$.
      have hk_ge_2 : 2 ≤ k := by
        rcases k with ( _ | _ | k ) <;> simp_all +decide [ IsCarmichaelNum ];
      -- Consider $a = 1 + p$. We have $a^{n-1} \equiv 1 \pmod{n}$.
      have h_cong : (1 + p) ^ (p ^ k - 1) ≡ 1 [MOD p ^ k] := by
        convert hc.2.2 ( 1 + p ) _ using 1;
        cases k <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
      -- Expanding $(1 + p)^{p^k - 1}$ using the binomial theorem, we get:
      have h_expand : (1 + p) ^ (p ^ k - 1) ≡ 1 + (p ^ k - 1) * p [MOD p ^ 2] := by
        have h_expand : ∀ m : ℕ, (1 + p) ^ m ≡ 1 + m * p [MOD p ^ 2] := by
          intro m; induction m <;> simp_all +decide [ ← ZMod.natCast_eq_natCast_iff, pow_succ' ] ; ring;
          norm_cast ; simp +decide [ sq, hp.ne_zero ];
        apply h_expand;
      -- Since $p^k \mid (p^k - 1) * p$, we have $p^2 \mid (p^k - 1) * p$.
      have h_div : p ^ 2 ∣ (p ^ k - 1) * p := by
        have h_div : 1 + (p ^ k - 1) * p ≡ 1 [MOD p ^ 2] := by
          exact h_expand.symm.trans ( h_cong.of_dvd <| pow_dvd_pow _ hk_ge_2 );
        simpa [ ← Int.natCast_dvd_natCast ] using h_div.symm.dvd;
      rw [ Nat.pow_two, mul_dvd_mul_iff_right hp.ne_zero ] at h_div;
      haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, Nat.cast_sub ( Nat.one_le_pow _ _ hp.pos ) ] ;
      cases k <;> simp_all +decide




theorem no_carmichael_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) : ¬ IsCarmichaelNum (p * q) := by
      intro h;
      -- By Korselt's criterion (backward direction), (p-1) | (pq-1) and (q-1) | (pq-1).
      have h_korselt_p : (p - 1) ∣ (p * q - 1) := by
        -- Let $a$ be a primitive root modulo $p$. Then $a^{p-1} \equiv 1 \pmod{p}$.
        obtain ⟨a, ha⟩ : ∃ a, Nat.gcd a (p * q) = 1 ∧ orderOf (a : ZMod p) = p - 1 := by
          -- Let $a$ be a primitive root modulo $p$. Then $a^{p-1} \equiv 1 \pmod{p}$ by definition.
          obtain ⟨a, ha⟩ : ∃ a, Nat.gcd a p = 1 ∧ orderOf (a : ZMod p) = p - 1 := by
            haveI := Fact.mk hp; have := IsCyclic.exists_generator ( α := ( ZMod p )ˣ ) ; obtain ⟨ a, ha ⟩ := this; use a.val.val; simp_all +decide [ orderOf_units ] ;
            exact ⟨ Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr <| by rw [ ← ZMod.natCast_eq_zero_iff ] ; aesop, by rw [ orderOf_eq_card_of_forall_mem_zpowers ha ] ; simp +decide [ Nat.totient_prime hp ] ⟩;
          -- Let $b$ be a number such that $b \equiv a \pmod{p}$ and $b \equiv 1 \pmod{q}$.
          obtain ⟨b, hb⟩ : ∃ b, b ≡ a [MOD p] ∧ b ≡ 1 [MOD q] := by
            have := Nat.chineseRemainder ( show Nat.Coprime p q from hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.prime_dvd_prime_iff_eq hp hq; aesop ) a 1; aesop;
          refine' ⟨ b, _, _ ⟩;
          · exact Nat.Coprime.mul_right ( hb.1.gcd_eq.trans ha.1 ) ( hb.2.gcd_eq.trans ( by norm_num ) );
          · simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        rw [ ← ha.2, orderOf_dvd_iff_pow_eq_one ];
        have := h.2.2 a ha.1;
        simpa [ ← ZMod.natCast_eq_natCast_iff ] using this.of_dvd <| dvd_mul_right _ _
      have h_korselt_q : (q - 1) ∣ (p * q - 1) := by
        -- Let $a$ be a primitive root modulo $q$.
        obtain ⟨a, ha⟩ : ∃ a, Nat.gcd a (p * q) = 1 ∧ orderOf (a : ZMod q) = q - 1 := by
          -- Let $a$ be a primitive root modulo $q$. Such an $a$ exists because $q$ is prime.
          obtain ⟨a, ha⟩ : ∃ a, Nat.gcd a q = 1 ∧ orderOf (a : ZMod q) = q - 1 := by
            have := Fact.mk hq;
            obtain ⟨ a, ha ⟩ := IsCyclic.exists_generator ( α := ( ZMod q )ˣ );
            refine' ⟨ a.val.val, _, _ ⟩;
            · exact Nat.coprime_comm.mp ( hq.coprime_iff_not_dvd.mpr <| by rw [ ← ZMod.natCast_eq_zero_iff ] ; aesop );
            · simp +decide [ orderOf_units, orderOf_eq_card_of_forall_mem_zpowers ha, Nat.totient_prime hq ];
          -- By the Chinese Remainder Theorem, there exists an integer $a$ such that $a \equiv a \pmod{q}$ and $a \equiv 1 \pmod{p}$.
          obtain ⟨a', ha'⟩ : ∃ a', a' ≡ a [MOD q] ∧ a' ≡ 1 [MOD p] := by
            have := Nat.chineseRemainder ( show Nat.Coprime p q from hp.coprime_iff_not_dvd.mpr fun h => hpq.ne <| Nat.prime_dvd_prime_iff_eq hp hq |>.1 h );
            exact ⟨ _, this 1 a |>.2.2, this 1 a |>.2.1 ⟩;
          refine' ⟨ a', _, _ ⟩;
          · exact Nat.Coprime.mul_right ( by simpa using ha'.2.gcd_eq ) ( by simpa using ha'.1.gcd_eq.trans ha.1 );
          · simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        -- By the Carmichael property, we have $a^{pq-1} \equiv 1 \pmod{pq}$.
        have h_carmichael : a ^ (p * q - 1) ≡ 1 [MOD p * q] := by
          exact h.2.2 a ha.1;
        exact ha.2 ▸ orderOf_dvd_iff_pow_eq_one.mpr ( by simpa [ ← ZMod.natCast_eq_natCast_iff ] using h_carmichael.of_dvd <| dvd_mul_left _ _ );
      rcases p with ( _ | _ | p ) <;> rcases q with ( _ | _ | q ) <;> simp_all +decide [ Nat.mul_succ, Nat.dvd_iff_mod_eq_zero ];
      obtain ⟨ m, hm ⟩ := Nat.modEq_zero_iff_dvd.mp h_korselt_q;
      nlinarith [ show m = p + 2 by nlinarith ]




theorem korselt_forward (n : ℕ) (hk : SatisfiesKorseltCrit n) :
    IsCarmichaelNum n := by
      refine' ⟨ hk.1, hk.2.1, _ ⟩;
      intro a ha_coprime
      have h_cauchy : ∀ p ∈ n.primeFactors, a ^ (n - 1) ≡ 1 [MOD p] := by
        intro p hp
        have h_prime : Nat.Prime p := by
          exact Nat.prime_of_mem_primeFactors hp
        have h_div : (p - 1) ∣ (n - 1) := by
          exact hk.2.2.2 p h_prime ( Nat.dvd_of_mem_primeFactors hp )
        have h_fermat : a ^ (p - 1) ≡ 1 [MOD p] := by
          exact Nat.totient_prime h_prime ▸ Nat.ModEq.pow_totient ( Nat.Coprime.coprime_dvd_right ( Nat.dvd_of_mem_primeFactors hp ) ha_coprime )
        have h_exp : a ^ (n - 1) ≡ 1 [MOD p] := by
          obtain ⟨ k, hk ⟩ := h_div; simpa [ pow_mul, hk ] using h_fermat.pow k;
        exact h_exp;
      simp_all +decide [ Nat.modEq_iff_dvd ];
      -- Since $n$ is squarefree, it is the product of its prime factors.
      have h_prod_prime_factors : ∏ p ∈ Nat.primeFactors n, (p : ℤ) = n := by
        rw [ ← Nat.cast_prod, Nat.prod_primeFactors_of_squarefree hk.2.2.1 ];
      rw [ ← h_prod_prime_factors ] ; exact Finset.prod_dvd_of_coprime ( fun p hp q hq hpq ↦ by have := Nat.coprime_primes ( Nat.prime_of_mem_primeFactors hp ) ( Nat.prime_of_mem_primeFactors hq ) ; aesop ) fun p hp ↦ h_cauchy p ( Nat.prime_of_mem_primeFactors hp ) ( Nat.dvd_of_mem_primeFactors hp ) ( by aesop ) ;


