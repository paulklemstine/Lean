/-! # CatalogBuild.Algebra.Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 18
-/

import Mathlib

noncomputable section

/-- The key recurrence: F(m*(k+1)) = F(m-1)*F(mk) + F(m)*F(mk+1), for m ≥ 1.
This follows from Nat.fib_add. -/
lemma fib_mul_succ (m k : ℕ) (hm : m ≥ 1) :
    Nat.fib (m * (k + 1)) = Nat.fib (m - 1) * Nat.fib (m * k) +
      Nat.fib m * Nat.fib (m * k + 1) := by
  cases m <;> simp_all +decide [Nat.fib_add, Nat.mul_succ, add_comm]
  have := Nat.fib_add (‹_›) ((‹_› + 1) * k); ring_nf at *; aesop


/-- F(m) divides F(mk) - a wrapper for Nat.fib_dvd -/
lemma fib_dvd_fib_mul (m k : ℕ) : Nat.fib m ∣ Nat.fib (m * k) :=
  Nat.fib_dvd m (m * k) ⟨k, rfl⟩


/-- If p divides F(m), then p does not divide F(m-1), for m ≥ 1.
This follows from gcd(F(m), F(m-1)) = 1. -/
lemma not_dvd_fib_pred_of_dvd_fib {p m : ℕ} (hp : Nat.Prime p) (hm : m ≥ 1)
    (hdvd : p ∣ Nat.fib m) : ¬(p ∣ Nat.fib (m - 1)) := by
  rcases m with (_ | _ | m) <;>
    simp_all +arith +decide [Nat.fib_add_two, Nat.Prime.dvd_mul]
  intro h
  have := Nat.dvd_gcd hdvd h
  simp_all +decide [Nat.fib_add_two, Nat.fib_coprime_fib_succ]


/-- If p divides F(m), then p does not divide F(mk+1), for m ≥ 1.
This follows from gcd(F(mk), F(mk+1)) = 1 and p ∣ F(mk). -/
lemma not_dvd_fib_mul_succ {p m k : ℕ} (hp : Nat.Prime p) (hm : m ≥ 1)
    (hdvd : p ∣ Nat.fib m) : ¬(p ∣ Nat.fib (m * k + 1)) := by
  have h_coprime : Nat.gcd (Nat.fib (m * k)) (Nat.fib (m * k + 1)) = 1 :=
    Nat.fib_coprime_fib_succ (m * k)
  exact fun h => hp.not_dvd_one <|
    h_coprime ▸ Nat.dvd_gcd (fib_dvd_fib_mul m k |> dvd_trans hdvd) h


/-- The quotient Q(m,k) = F(mk)/F(m), well-defined since F(m) ∣ F(mk). -/
noncomputable def fibQuot (m k : ℕ) : ℕ := Nat.fib (m * k) / Nat.fib m


/-- [Section: ## The quotient F(mk)/F(m) and its congruence mod p] -/
lemma fib_mul_eq (m k : ℕ) : Nat.fib (m * k) = Nat.fib m * fibQuot m k :=
  Eq.symm (Nat.mul_div_cancel' (fib_dvd_fib_mul m k))


/-- Multiplicativity of the quotient: Q(m, k₁*k₂) = Q(m, k₁) * Q(m*k₁, k₂) -/
lemma fibQuot_mul (m k₁ k₂ : ℕ) :
    fibQuot m (k₁ * k₂) = fibQuot m k₁ * fibQuot (m * k₁) k₂ := by
  have h_mul : Nat.fib (m * (k₁ * k₂)) =
      Nat.fib m * fibQuot m k₁ * fibQuot (m * k₁) k₂ := by
    rw [← fib_mul_eq, ← fib_mul_eq]; ring!
  by_cases hm : Nat.fib m = 0
  · unfold fibQuot; aesop
  · exact Nat.div_eq_of_eq_mul_left (Nat.pos_of_ne_zero hm) (by linarith)


/-- Since F(m+1) = F(m) + F(m-1) and p | F(m), we get F(m+1) ≡ F(m-1) (mod p). -/
lemma fib_succ_eq_pred_mod (p m : ℕ) (hp : Nat.Prime p) (hm : m ≥ 1)
    (hdvd : p ∣ Nat.fib m) :
    (Nat.fib (m + 1) : ZMod p) = (Nat.fib (m - 1) : ZMod p) := by
  rcases m with (_ | _ | m) <;> simp_all +arith +decide [Nat.fib_add_two]
  simp_all +decide [← ZMod.natCast_eq_zero_iff]
  linear_combination' hdvd


/-- [Section: ## Congruences mod p for the quotient] -/
lemma fib_mul_add_one_mod (p m k : ℕ) (hp : Nat.Prime p) (hm : m ≥ 1)
    (hdvd : p ∣ Nat.fib m) :
    (Nat.fib (m * k + 1) : ZMod p) = (Nat.fib (m + 1) : ZMod p) ^ k := by
  induction' k with k ih;
  · norm_num;
  · have := @Nat.fib_add m ( m * k ) ; ring_nf at *; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;


lemma fibQuot_mod (p m k : ℕ) (hp : Nat.Prime p) (hm : m ≥ 1) (hk : k ≥ 1)
    (hdvd : p ∣ Nat.fib m) :
    (fibQuot m k : ZMod p) = (k : ZMod p) * (Nat.fib (m - 1) : ZMod p) ^ (k - 1) := by
  -- We proceed by induction on $k$.
  induction' k with k ihk generalizing m;
  · contradiction;
  · -- Using the recurrence relation again, we have $Q(m, k+1) = F(m-1) * Q(m, k) + F(mk+1)$.
    have h_recurrence_succ : fibQuot m (k + 1) = fib (m - 1) * fibQuot m k + fib (m * k + 1) := by
      have h_recurrence_succ : Nat.fib (m * (k + 1)) = Nat.fib m * (fib (m - 1) * fibQuot m k + fib (m * k + 1)) := by
        grind +suggestions;
      unfold fibQuot at *;
      rw [ h_recurrence_succ, Nat.mul_div_cancel_left _ ( Nat.fib_pos.mpr hm ) ];
    rcases k with ( _ | k ) <;> simp_all +decide;
    · unfold fibQuot; aesop;
    · rw [ fib_mul_add_one_mod p m ( k + 1 ) hp hm hdvd ] ; ring;
      rw [ show 1 + m = m + 1 by ring, fib_succ_eq_pred_mod p m hp hm hdvd ] ; ring


/-- [Section: ## Coprime case: v_p(F(mk)) = v_p(F(m)) when p ∤ k] -/
lemma fibQuot_not_dvd (p m k : ℕ) (hp : Nat.Prime p) (hm : m ≥ 1) (hk : k ≥ 1)
    (hdvd : p ∣ Nat.fib m) (hcoprime : ¬(p ∣ k)) :
    ¬(p ∣ fibQuot m k) := by
  haveI := Fact.mk hp;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff, fibQuot_mod ];
  exact fun h => absurd h ( by simpa [ ← ZMod.natCast_eq_zero_iff ] using not_dvd_fib_pred_of_dvd_fib hp hm ( by rwa [ ← ZMod.natCast_eq_zero_iff ] ) )


lemma padicValNat_fib_mul_coprime {p m k : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m > 0) (hk : k > 0) (hdvd : p ∣ Nat.fib m)
    (hcoprime : ¬(p ∣ k)) :
    padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) := by
  haveI := Fact.mk hp; rw [ fib_mul_eq m k, padicValNat.mul ] <;> simp_all +decide [ Nat.fib_pos ] ;
  · exact Or.inr <| Or.inr <| fibQuot_not_dvd p m k hp hm hk hdvd hcoprime;
  · linarith;
  · exact Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.fib_pos.mpr ( Nat.mul_pos hm hk ) ) ( fib_dvd_fib_mul m k ) ) ( Nat.fib_pos.mpr hm ) )


/-- [Section: ## Prime step: v_p(F(mp)) = v_p(F(m)) + 1] -/
lemma fibQuot_prime_dvd (p m : ℕ) (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m ≥ 1) (hdvd : p ∣ Nat.fib m) :
    p ∣ fibQuot m p := by
  have := fibQuot_mod p m p hp hm ( Nat.Prime.pos hp );
  simp_all +decide [ ZMod.natCast_eq_zero_iff ]


lemma fibQuot_prime_sq_not_dvd (p m : ℕ) (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m ≥ 1) (hdvd : p ∣ Nat.fib m) :
    ¬(p ^ 2 ∣ fibQuot m p) := by
  -- Write F(m+1) = F(m-1) + F(m) = F(m-1) + p*a (where F(m) = p*a for some a, since p | F(m); here a may not be exact if v_p(F(m)) > 1 but that's fine).
  obtain ⟨a, ha⟩ : ∃ a, Nat.fib m = p * a := hdvd
  have h_fib_succ : Nat.fib (m + 1) = Nat.fib (m - 1) + p * a := by
    cases m <;> simp_all +decide [ Nat.fib_add_two ];
  -- So Q(m,k+1) ≡ F(m-1)*Q(m,k) + F(m+1)^k (mod p²).
  have h_quot_succ : ∀ k ≥ 1, fibQuot m (k + 1) ≡ Nat.fib (m - 1) * fibQuot m k + (Nat.fib (m - 1) + p * a) ^ k [MOD p ^ 2] := by
    -- From Q(m,k+1) = F(m-1)*Q(m,k) + F(mk+1), we can use the recurrence relation for Fibonacci numbers.
    have h_recurrence : ∀ k ≥ 1, fibQuot m (k + 1) = Nat.fib (m - 1) * fibQuot m k + Nat.fib (m * k + 1) := by
      intros k hk
      have h_fib_mul_succ : Nat.fib (m * (k + 1)) = Nat.fib (m - 1) * Nat.fib (m * k) + Nat.fib m * Nat.fib (m * k + 1) := by
        convert fib_mul_succ m k hm using 1;
      have h_fib_mul_succ : fibQuot m (k + 1) * Nat.fib m = Nat.fib (m - 1) * (fibQuot m k * Nat.fib m) + Nat.fib m * Nat.fib (m * k + 1) := by
        convert h_fib_mul_succ using 1;
        · exact Nat.div_mul_cancel ( fib_dvd_fib_mul m ( k + 1 ) );
        · rw [ show fib ( m * k ) = fib m * fibQuot m k from fib_mul_eq m k ];
          ring;
      exact mul_left_cancel₀ ( show fib m ≠ 0 from Nat.ne_of_gt <| Nat.fib_pos.mpr hm ) <| by linarith;
    intro k hk; induction hk <;> simp_all +decide [ Nat.pow_succ', Nat.mul_succ, Nat.ModEq ] ;
    -- Using the identity $F_{m(k+1)+1} = F_{mk+1}F_{m+1} + F_{mk}F_m$, we can rewrite the goal.
    have h_identity : Nat.fib (m * ‹_› + m + 1) = Nat.fib (m * ‹_› + 1) * Nat.fib (m + 1) + Nat.fib (m * ‹_›) * Nat.fib m := by
      have h_identity : ∀ n k : ℕ, Nat.fib (n + k + 1) = Nat.fib (n + 1) * Nat.fib (k + 1) + Nat.fib n * Nat.fib k := by
        intro n k; induction' n with n ih generalizing k <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ] ;
        ring;
      exact h_identity _ _;
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    rw [ mul_comm ] ; norm_cast ; simp_all +decide [ fib_mul_eq ] ;
    ring;
    norm_cast ; simp_all +decide [ sq, mul_assoc, Nat.mul_mod_mul_left ];
    norm_cast ; simp_all +decide [ ← mul_assoc, ← ZMod.natCast_eq_zero_iff ];
  -- Claim: Q(m,k) ≡ k*F(m-1)^(k-1) + C(k,2)*F(m-1)^(k-2)*F(m) (mod p²).
  have h_quot_formula : ∀ k ≥ 1, fibQuot m k ≡ k * Nat.fib (m - 1) ^ (k - 1) + (k * (k - 1) / 2) * Nat.fib (m - 1) ^ (k - 2) * p * a [MOD p ^ 2] := by
    intro k hk; induction hk <;> simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ] ;
    · unfold fibQuot; norm_num;
      rw [ Nat.div_self ( Nat.fib_pos.mpr hm ) ] ; norm_num;
    · rename_i k hk ih;
      -- Expand $(fib(m-1) + p*a)^k$ using the binomial theorem.
      have h_binom : (Nat.fib (m - 1) + p * a) ^ k ≡ Nat.fib (m - 1) ^ k + k * Nat.fib (m - 1) ^ (k - 1) * p * a [MOD p ^ 2] := by
        have h_binom : (Nat.fib (m - 1) + p * a) ^ k = ∑ i ∈ Finset.range (k + 1), Nat.choose k i * Nat.fib (m - 1) ^ (k - i) * (p * a) ^ i := by
          exact by rw [ Nat.add_comm, add_pow ] ; ac_rfl;
        rcases k with ( _ | k ) <;> simp_all +decide [ Finset.sum_range_succ', pow_succ, mul_assoc, mul_comm, mul_left_comm ];
        norm_num [ add_comm, add_left_comm, add_assoc, Nat.modEq_iff_dvd ];
        exact Finset.dvd_sum fun i hi => ⟨ a * a * ( a * p ) ^ i * Nat.choose ( k + 1 ) ( i + 2 ) * fib ( m - 1 ) ^ ( k - ( i + 1 ) ), by ring ⟩;
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mod_two_of_bodd ] ; ring;
      ring;
      rw [ show ( 6 + k * 5 + k ^ 2 ) / 2 = ( 2 + k * 3 + k ^ 2 ) / 2 + ( k + 2 ) by exact Nat.div_eq_of_eq_mul_left zero_lt_two <| by linarith [ Nat.div_mul_cancel ( show 2 ∣ 2 + k * 3 + k ^ 2 from even_iff_two_dvd.mp <| by simp +arith +decide [ parity_simps ] ) ] ] ; norm_num ; ring;
  -- For k = p: Q(m,p) ≡ p*F(m-1)^(p-1) + C(p,2)*F(m-1)^(p-2)*F(m) (mod p²).
  have h_quot_p : fibQuot m p ≡ p * Nat.fib (m - 1) ^ (p - 1) + (p * (p - 1) / 2) * Nat.fib (m - 1) ^ (p - 2) * p * a [MOD p ^ 2] := by
    exact h_quot_formula p hp.pos;
  -- Since p is odd, (p-1)/2 is an integer, and p | C(p,2).
  have h_c_p2 : p ^ 2 ∣ (p * (p - 1) / 2) * Nat.fib (m - 1) ^ (p - 2) * p * a := by
    rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.mul_div_assoc ];
    exact ⟨ ( p + 1 + 1 ) * ( p + 1 ) / 2 * fib ( m - 1 ) ^ p * a / ( p + 1 + 1 ), by nlinarith [ Nat.div_mul_cancel ( show p + 1 + 1 ∣ ( p + 1 + 1 ) * ( p + 1 ) / 2 * fib ( m - 1 ) ^ p * a from dvd_mul_of_dvd_left ( dvd_mul_of_dvd_left ( Nat.dvd_div_of_mul_dvd ( by exact ⟨ ( p + 1 ) / 2, by nlinarith [ Nat.div_mul_cancel ( show 2 ∣ p + 1 from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using hodd ) ) ] ⟩ ) ) _ ) _ ) ] ⟩;
  rw [ Nat.dvd_iff_mod_eq_zero, h_quot_p ];
  rw [ Nat.add_mod, Nat.mod_eq_zero_of_dvd h_c_p2 ] ; norm_num [ sq, Nat.mul_mod_mul_left, hp.ne_zero ];
  rw [ ← Nat.dvd_iff_mod_eq_zero ];
  exact mt hp.dvd_of_dvd_pow ( not_dvd_fib_pred_of_dvd_fib hp hm ( ha.symm ▸ dvd_mul_right _ _ ) )


lemma padicValNat_fibQuot_prime (p m : ℕ) (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m ≥ 1) (hdvd : p ∣ Nat.fib m) :
    padicValNat p (fibQuot m p) = 1 := by
  have h_val : padicValNat p (fibQuot m p) = 1 := by
    have h_div : p ∣ fibQuot m p := fibQuot_prime_dvd p m hp hodd hfive hm hdvd
    have h_not_div : ¬(p^2 ∣ fibQuot m p) := fibQuot_prime_sq_not_dvd p m hp hodd hfive hm hdvd
    haveI := Fact.mk hp;
    rw [ padicValNat_dvd_iff ] at *;
    cases h : padicValNat p ( fibQuot m p ) <;> aesop
  exact h_val


lemma padicValNat_fib_mul_prime {p m : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m > 0) (hdvd : p ∣ Nat.fib m) :
    padicValNat p (Nat.fib (m * p)) = padicValNat p (Nat.fib m) + 1 := by
  -- By padicValNat.mul: v_p(F(mp)) = v_p(F(m)) + v_p(Q(m,p)).
  have h_mul : padicValNat p (fib m * fibQuot m p) = padicValNat p (fib m) + padicValNat p (fibQuot m p) := by
    by_cases h : fib m * fibQuot m p = 0 <;> simp_all +decide [ padicValNat.mul ];
    have h_pos : 0 < m * p → 0 < Nat.fib (m * p) := by
      exact fun _ => Nat.fib_pos.mpr ‹_›;
    exact absurd ( h.resolve_left hm.ne' ) ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( h_pos ( Nat.mul_pos hm hp.pos ) ) ( fib_dvd_fib_mul m p ) ) ( Nat.fib_pos.mpr hm ) ) );
  rw [ ← padicValNat_fibQuot_prime p m hp hodd hfive hm hdvd ];
  rwa [ ← fib_mul_eq ] at h_mul


/-- [Section: ## Prime power case by induction] -/
lemma padicValNat_fib_mul_prime_pow {p m : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    (hfive : p ≠ 5) (hm : m > 0) (hdvd : p ∣ Nat.fib m) (t : ℕ) :
    padicValNat p (Nat.fib (m * p ^ t)) = padicValNat p (Nat.fib m) + t := by
  induction' t with t ih;
  · norm_num;
  · rw [ pow_succ, ← mul_assoc, padicValNat_fib_mul_prime ] <;> simp_all +decide [ pow_succ, Nat.mul_assoc ];
    · ring;
    · exact pow_pos hp.pos _;
    · exact dvd_trans hdvd ( fib_dvd_fib_mul _ _ )


/-- [Section: ## Main theorem] -/
theorem fib_lifting_the_exponent {p m k : ℕ} (hp : Nat.Prime p) (hodd : Odd p) (hfive : p ≠ 5)
    (hm : m > 0) (hk : k > 0) (hdiv : p ∣ Nat.fib m) :
    padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k := by
  obtain ⟨t, v, ht, hv⟩ : ∃ t v : ℕ, k = p^t * v ∧ ¬(p ∣ v) := by
    exact ⟨ Nat.factorization k p, k / p ^ Nat.factorization k p, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by aesop ) ( by aesop ) ⟩;
  -- By padicValNat_fib_mul_prime_pow: v_p(F(m * p^t)) = v_p(F(m)) + t.
  have h_step1 : padicValNat p (Nat.fib (m * p ^ t)) = padicValNat p (Nat.fib m) + t := by
    grind +suggestions;
  -- By padicValNat_fib_mul_coprime: v_p(F((m * p^t) * v)) = v_p(F(m * p^t)).
  have h_step2 : padicValNat p (Nat.fib ((m * p ^ t) * v)) = padicValNat p (Nat.fib (m * p ^ t)) := by
    apply padicValNat_fib_mul_coprime;
    any_goals assumption;
    · exact Nat.mul_pos hm ( pow_pos hp.pos _ );
    · exact Nat.pos_of_ne_zero ( by aesop_cat );
    · exact dvd_trans hdiv ( fib_dvd_fib_mul _ _ );
  simp_all +decide [ mul_assoc, Nat.Prime.dvd_mul ];
  haveI := Fact.mk hp; rw [ padicValNat.mul ] <;> aesop;

end
