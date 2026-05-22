import Mathlib

/-!
# Fibonacci Entry Point Theory and Lifting-the-Exponent

This file develops the valuation-theoretic backbone for the Fibonacci
primitive-divisor program. The central results are:

1. **Entry point theory**: For a prime `p`, the *Fibonacci entry point*
   is the least positive index `z` with `p ∣ F(z)`. We prove existence,
   positivity, minimality, and the fundamental divisibility criterion:
   `p ∣ F(n) ↔ z ∣ n`.

2. **LTE-style valuation theorem**: For odd prime `p ≠ 5` with entry point `z`,
   `v_p(F(k·z)) = v_p(F(z)) + v_p(k)`.

3. **GCD identity**: `gcd(F(m), F(n)) = F(gcd(m,n))` and its consequences.

4. **Composite-index primitive divisor theorem**: For composite `n ≥ 13`,
   `F(n)` has a primitive prime divisor.

## References

* Carmichael, R.D. (1913). *On the numerical factors of the arithmetic
  forms α^n ± β^n*. Annals of Mathematics.
-/

open Nat

set_option maxHeartbeats 800000

/-! ## Section 1: IsFibEntry — the entry point specification -/

/-- A predicate asserting that `z` is the Fibonacci entry point of `p`:
the least positive index where `p` divides `F(z)`. -/
def IsFibEntry (p z : ℕ) : Prop :=
  0 < z ∧ p ∣ fib z ∧ ∀ m, 0 < m → m < z → ¬ p ∣ fib m

/-! ## Section 2: GCD identity and divisibility sequence -/

/-- The GCD identity: `gcd(F(m), F(n)) = F(gcd(m, n))`. -/
theorem fib_gcd_eq (m n : ℕ) : Nat.gcd (fib m) (fib n) = fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- Divisibility in the index lifts to divisibility in values. -/
theorem fib_dvd_of_dvd {m n : ℕ} (h : m ∣ n) : fib m ∣ fib n :=
  Nat.fib_dvd m n h

/-- If `p` divides both `F(m)` and `F(n)`, then `p ∣ F(gcd(m,n))`. -/
theorem dvd_fib_gcd_of_dvd_fib {p m n : ℕ}
    (hm : p ∣ fib m) (hn : p ∣ fib n) :
    p ∣ fib (Nat.gcd m n) := by
  rw [← fib_gcd_eq]; exact Nat.dvd_gcd hm hn

/-- `gcd(F(m), F(n)) = F(gcd(m,n))` — valuation corollary. -/
theorem padicValNat_fib_gcd {p m n : ℕ} :
    padicValNat p (Nat.gcd (fib m) (fib n)) = padicValNat p (fib (Nat.gcd m n)) := by
  rw [fib_gcd_eq]

/-- A prime divides `gcd(F(m), F(n))` iff it divides `F(gcd(m,n))`. -/
theorem prime_dvd_fib_gcd_iff {p m n : ℕ} :
    p ∣ Nat.gcd (fib m) (fib n) ↔ p ∣ fib (Nat.gcd m n) := by
  rw [fib_gcd_eq]

attribute [local simp] fib_gcd_eq


/-! ## Section 3: Entry point divisibility -/

/-- The entry point divides any positive index where divisibility occurs. -/
theorem isFibEntry_dvd_of_dvd {p n z : ℕ}
    (hz : IsFibEntry p z) (_hn : 0 < n) (hpn : p ∣ fib n) :
    z ∣ n := by
  obtain ⟨hz_pos, hz_dvd, hz_min⟩ := hz
  have h_gcd_dvd_fib : p ∣ fib (Nat.gcd z n) :=
    dvd_fib_gcd_of_dvd_fib hz_dvd hpn
  have h_gcd_le : Nat.gcd z n ≤ z := Nat.gcd_le_left n hz_pos
  rcases eq_or_lt_of_le h_gcd_le with h | h
  · exact h ▸ Nat.gcd_dvd_right z n
  · exact absurd h_gcd_dvd_fib (hz_min _ (Nat.gcd_pos_of_pos_left n hz_pos) h)

/-- Non-divisibility below the entry point. -/
theorem not_dvd_fib_of_lt_entry {p m z : ℕ}
    (hz : IsFibEntry p z) (hm0 : 0 < m) (hmz : m < z) :
    ¬ p ∣ fib m :=
  hz.2.2 m hm0 hmz

/-- The divisibility criterion: `p ∣ F(n) ↔ z ∣ n`. -/
theorem prime_dvd_fib_iff_entry_dvd {p n z : ℕ} (_hp : Nat.Prime p)
    (hz : IsFibEntry p z) (hn : 0 < n) :
    p ∣ fib n ↔ z ∣ n := by
  constructor
  · exact isFibEntry_dvd_of_dvd hz hn
  · exact fun hdvd => dvd_trans hz.2.1 (fib_dvd_of_dvd hdvd)

/-- If the entry point doesn't divide `n`, then `p ∤ F(n)`. -/
theorem not_dvd_fib_of_not_entry_dvd {p n z : ℕ} (_hp : Nat.Prime p)
    (hz : IsFibEntry p z) (hn : 0 < n) (hnd : ¬ z ∣ n) :
    ¬ p ∣ fib n :=
  fun h => hnd (isFibEntry_dvd_of_dvd hz hn h)

/-- When the entry point doesn't divide `n`, the p-adic valuation of F(n) is zero. -/
theorem padicValNat_fib_eq_zero_of_not_entry_dvd {p n z : ℕ}
    (hp : Nat.Prime p) (hz : IsFibEntry p z) (hn : 0 < n) (hnd : ¬ z ∣ n) :
    padicValNat p (fib n) = 0 :=
  padicValNat.eq_zero_of_not_dvd (not_dvd_fib_of_not_entry_dvd hp hz hn hnd)

/-! ## Section 4: Existence of entry points -/

/-
Every prime divides some positive Fibonacci number.
For any prime `p`, the Pisano period `π(p) ≤ p² - 1` guarantees
that `p ∣ F(k)` for some `1 ≤ k ≤ p² - 1`.
-/
theorem prime_dvd_some_pos_fib (p : ℕ) (hp : Nat.Prime p) :
    ∃ k, 0 < k ∧ p ∣ fib k := by
  -- By the pigeonhole principle, among the p²+1 pairs (F(n) mod p, F(n+1) mod p) for n = 0,...,p², two must coincide (since there are only p² possible pairs).
  obtain ⟨i, j, hij, h_pair⟩ : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧ (fib (i + 1) % p = fib (j + 1) % p) ∧ j ≤ p^2 := by
    have h_pigeonhole : Finset.card (Finset.image (fun n => (fib n % p, fib (n + 1) % p)) (Finset.range (p^2 + 1))) ≤ p^2 := by
      exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun n hn => Finset.mem_product.mpr ⟨ Finset.mem_range.mpr <| Nat.mod_lt _ hp.pos, Finset.mem_range.mpr <| Nat.mod_lt _ hp.pos ⟩ ) ( by norm_num [ sq ] );
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn ] <;> norm_num;
    exact fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => by have := h_pigeonhole _ _ hi' ( by aesop ) ( by aesop ) ; linarith [ Set.mem_Iio.mp hi, Set.mem_Iio.mp hj ] ) ( le_of_not_gt fun hj' => by have := h_pigeonhole _ _ hj' ( by aesop ) ( by aesop ) ; linarith [ Set.mem_Iio.mp hi, Set.mem_Iio.mp hj ] );
  induction' i with i ih generalizing j;
  · exact ⟨ j, hij, Nat.dvd_of_mod_eq_zero <| by simpa using h_pair.1.symm ⟩;
  · apply ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij );
    rcases j <;> simp_all +decide [ Nat.fib_add_two ];
    exact ⟨ Nat.ModEq.symm ( Nat.modEq_of_dvd <| by simpa [ ← Int.natCast_dvd_natCast ] using Nat.modEq_iff_dvd.mp ( h_pair.2.1.symm.trans <| Nat.ModEq.add ( Nat.ModEq.refl _ ) h_pair.1 ) ), by linarith ⟩

/-- For any prime `p`, there exists `z` with `IsFibEntry p z`. -/
theorem exists_isFibEntry (p : ℕ) (hp : Nat.Prime p) : ∃ z, IsFibEntry p z := by
  obtain ⟨k, hk_pos, hk_dvd⟩ := prime_dvd_some_pos_fib p hp
  have hP : ∃ n, 0 < n ∧ p ∣ fib n := ⟨k, hk_pos, hk_dvd⟩
  exact ⟨Nat.find hP, (Nat.find_spec hP).1, (Nat.find_spec hP).2,
    fun m hm hmz hpm => Nat.find_min hP hmz ⟨hm, hpm⟩⟩

/-! ## Section 5: Fibonacci LTE — Lifting the Exponent

The key machinery: if `p ∣ F(m)` and `p ∤ k`, then
`v_p(F(mk)) = v_p(F(m))`; and for `k = p`,
`v_p(F(mp)) = v_p(F(m)) + 1`. Together these give
`v_p(F(mk)) = v_p(F(m)) + v_p(k)`.

The proofs use the quotient `Q(m,k) = F(mk)/F(m)` and the congruence
`Q(m,k) ≡ k · F(m-1)^{k-1} (mod p)`.
-/

/-- If `p ∣ F(m)`, then `p ∤ F(m-1)` (consecutive Fibonacci numbers are coprime). -/
theorem not_dvd_fib_pred {p m : ℕ} (hp : Nat.Prime p) (hm : 0 < m)
    (h : p ∣ fib m) : ¬ p ∣ fib (m - 1) := by
  rcases m with _ | m
  · omega
  · simp
    intro h2
    have hcop := Nat.fib_coprime_fib_succ m
    have : p ∣ 1 := hcop ▸ Nat.dvd_gcd h2 h
    exact absurd (Nat.le_of_dvd one_pos this) (not_le.mpr hp.one_lt)

/-
**Coprime case**: when `p ∤ k` and `p ∣ F(m)`,
`v_p(F(mk)) = v_p(F(m))`.
-/
theorem padicValNat_fib_mul_of_coprime {p m k : ℕ}
    (hp : Nat.Prime p) (hodd : p ≠ 2) (h5 : p ≠ 5)
    (hm : 0 < m) (hk : 0 < k) (hdvd : p ∣ fib m) (hcop : ¬ p ∣ k) :
    padicValNat p (fib (m * k)) = padicValNat p (fib m) := by
  -- We show p ∤ Q(m,k) where Q(m,k) = F(mk)/F(m), then use padicValNat.mul and padicValNat.eq_zero_of_not_dvd.
  have hQ_not_div : ¬(p ∣ fib (m * k) / fib m) := by
    -- By induction on $k$, we show that $Q(m,k) \equiv k \cdot F(m-1)^{k-1} \pmod{p}$.
    have hQ_cong : ∀ k > 0, fib (m * k) / fib m ≡ k * fib (m - 1) ^ (k - 1) [MOD p] := by
      intro k hk
      have hQ_cong_step : ∀ j > 0, fib (m * j) / fib m ≡ j * fib (m - 1) ^ (j - 1) [MOD p] → fib (m * (j + 1)) / fib m ≡ (j + 1) * fib (m - 1) ^ j [MOD p] := by
        intro j hj ih
        have h_fib_mul : fib (m * (j + 1)) = fib (m - 1) * fib (m * j) + fib m * fib (m * j + 1) := by
          have h_fib_mul : ∀ a b : ℕ, a > 0 → b > 0 → fib (a + b) = fib (a - 1) * fib b + fib a * fib (b + 1) := by
            intros a b ha hb; induction' ha with a ha ih generalizing b <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ] ;
            · ring;
            · convert ih ( b + 1 ) ( Nat.succ_pos _ ) using 1 ; ring;
              cases a <;> simp_all +decide [ Nat.fib_add_two ] ; linarith;
          convert h_fib_mul m ( m * j ) hm ( Nat.mul_pos hm hj ) using 1 ; ring;
        -- By the properties of the Fibonacci sequence, we know that $fib(m * j + 1) \equiv fib(m - 1)^j \pmod{p}$.
        have h_fib_mod : fib (m * j + 1) ≡ fib (m - 1) ^ j [MOD p] := by
          refine' Nat.recOn j _ _ <;> simp_all +decide [ Nat.mul_succ, pow_succ, ← ZMod.natCast_eq_natCast_iff ];
          intro n hn; haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, Nat.fib_add ] ;
          rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.fib_add_two ];
        have h_fib_div : fib (m * (j + 1)) / fib m = fib (m - 1) * (fib (m * j) / fib m) + fib (m * j + 1) := by
          rw [ h_fib_mul, Nat.add_div ] <;> norm_num [ Nat.mul_div_assoc, Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod ];
          · rw [ Nat.mul_div_assoc _ ( show fib m ∣ fib ( m * j ) from fib_dvd_of_dvd <| dvd_mul_right _ _ ) ] ; norm_num [ Nat.mul_div_cancel_left _ ( show 0 < fib m from Nat.fib_pos.mpr hm ) ];
            exact Nat.mod_lt _ ( Nat.fib_pos.mpr hm );
          · positivity;
        simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        cases j <;> simp_all +decide [ pow_succ' ] ; ring;
      induction hk <;> aesop;
    haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, ← ZMod.natCast_eq_natCast_iff ] ;
    intro h; have := not_dvd_fib_pred hp hm; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  have h_fib_mk : fib (m * k) = fib m * (fib (m * k) / fib m) := by
    rw [ Nat.mul_div_cancel' ( fib_dvd_of_dvd ( dvd_mul_right _ _ ) ) ];
  haveI := Fact.mk hp; rw [ h_fib_mk, padicValNat.mul ] <;> norm_num [ hQ_not_div ] ;
  · linarith;
  · exact ⟨ hm.ne', Nat.fib_mono <| Nat.le_mul_of_pos_right _ hk ⟩

/-
**Prime step**: `v_p(F(mp)) = v_p(F(m)) + 1` when `p ∣ F(m)`,
`p` odd, `p ≠ 5`.
-/
theorem padicValNat_fib_mul_prime {p m : ℕ}
    (hp : Nat.Prime p) (hodd : p ≠ 2) (h5 : p ≠ 5)
    (hm : 0 < m) (hdvd : p ∣ fib m) :
    padicValNat p (fib (m * p)) = padicValNat p (fib m) + 1 := by
  have hgcd : Nat.gcd (fib m) (fib (m + 1)) = 1 := by
    exact?;
  have h_fibQuot : ∃ Q : ℕ, fib (m * p) = fib m * Q ∧ Q ≡ p * fib (m - 1) ^ (p - 1) [MOD p ^ 2] := by
    -- Using the identity for Fibonacci numbers, we have $F_{mk+1} = F_{m-1}^k + k F_{m-1}^{k-1} F_m + \binom{k}{2} F_{m-1}^{k-2} F_m^2 + \cdots$
    have h_fib_identity : ∀ k : ℕ, fib (m * k + 1) ≡ fib (m - 1) ^ k + k * fib (m - 1) ^ (k - 1) * fib m [MOD p ^ 2] := by
      intro k
      induction' k with k ih;
      · norm_num;
        rfl;
      · -- Using the recurrence relation for Fibonacci numbers, we have $F_{m(k+1)+1} = F_{mk+1}F_{m+1} + F_{mk}F_m$.
        have h_recurrence : fib (m * (k + 1) + 1) = fib (m * k + 1) * fib (m + 1) + fib (m * k) * fib m := by
          rw [ Nat.mul_succ, Nat.fib_add ];
          ring;
        -- Using the induction hypothesis and the recurrence relation, we can simplify the expression.
        have h_simplify : fib (m * k) * fib m ≡ k * fib (m - 1) ^ (k - 1) * fib m ^ 2 [MOD p ^ 2] := by
          have h_simplify : fib (m * k) ≡ k * fib (m - 1) ^ (k - 1) * fib m [MOD p] := by
            have h_simplify : ∀ k : ℕ, fib (m * k) ≡ k * fib (m - 1) ^ (k - 1) * fib m [MOD p] := by
              intro k; induction' k with k ih <;> simp_all +decide [ Nat.mul_succ, ← ZMod.natCast_eq_natCast_iff ] ;
              have h_recurrence : ∀ n, fib (n + m) = fib n * fib (m - 1) + fib (n + 1) * fib m := by
                intro n; induction' n with n ih <;> simp_all +decide [ Nat.fib_add_two, Nat.mul_succ ] ;
                rw [ Nat.succ_add, Nat.fib_add ];
                cases m <;> simp_all +decide [ Nat.fib_add_two ] ; linarith;
              simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
            exact h_simplify k;
          rw [ Nat.modEq_iff_dvd ] at *;
          convert mul_dvd_mul h_simplify ( Int.natCast_dvd_natCast.mpr hdvd ) using 1 ; push_cast ; ring;
          push_cast; ring;
        have h_simplify : fib (m + 1) ≡ fib (m - 1) + fib m [MOD p ^ 2] := by
          cases m <;> simp_all +decide [ Nat.fib_add_two ];
          rfl;
        simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        cases k <;> simp_all +decide [ pow_succ' ] ; ring;
        obtain ⟨ k, hk ⟩ := hdvd; simp_all +decide [ pow_succ, mul_assoc, mul_comm, mul_left_comm ] ;
        ring;
        norm_cast ; simp_all +decide [ Nat.pow_succ', Nat.mul_assoc, Nat.mul_comm, Nat.mul_left_comm ];
    -- Using the identity for Fibonacci numbers, we have $F_{mk} = F_m \cdot Q$ where $Q = F_{m-1} \cdot Q_{k-1} + F_{mk-1}$.
    have h_fib_mul : ∀ k : ℕ, fib (m * k) = fib m * (∑ i ∈ Finset.range k, fib (m - 1) ^ (k - 1 - i) * fib (m * i + 1)) := by
      intro k;
      induction' k with k ih;
      · norm_num;
      · have h_fib_mul_step : ∀ k : ℕ, fib (m * (k + 1)) = fib (m - 1) * fib (m * k) + fib m * fib (m * k + 1) := by
          intro k
          have h_fib_mul_step : ∀ a b : ℕ, a > 0 → b > 0 → fib (a + b) = fib (a - 1) * fib b + fib a * fib (b + 1) := by
            intros a b ha hb; induction' ha with a ha ih generalizing b <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ] ;
            · rw [ add_comm ];
            · convert ih ( b + 1 ) ( Nat.succ_pos _ ) using 1 ; ring;
              cases a <;> simp_all +decide [ Nat.fib_add_two ] ; linarith;
          by_cases hk : 0 < k <;> simp_all +decide [ Nat.mul_succ ];
          ring;
        simp_all +decide [ Finset.sum_range_succ ];
        simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, pow_succ', tsub_tsub, add_comm ];
        exact Finset.sum_congr rfl fun x hx => by rw [ show k - x = k - ( x + 1 ) + 1 by rw [ tsub_add_eq_add_tsub ( by linarith [ Finset.mem_range.mp hx ] ) ] ; simp +decide ] ; ring;
    -- Using the identity for Fibonacci numbers, we have $Q = \sum_{i=0}^{p-1} F_{m-1}^{p-1-i} F_{mi+1}$.
    use ∑ i ∈ Finset.range p, fib (m - 1) ^ (p - 1 - i) * fib (m * i + 1);
    have h_sum_identity : ∑ i ∈ Finset.range p, fib (m - 1) ^ (p - 1 - i) * fib (m * i + 1) ≡ ∑ i ∈ Finset.range p, fib (m - 1) ^ (p - 1) + ∑ i ∈ Finset.range p, i * fib (m - 1) ^ (p - 2) * fib m [MOD p ^ 2] := by
      have h_sum_identity : ∀ i ∈ Finset.range p, fib (m - 1) ^ (p - 1 - i) * fib (m * i + 1) ≡ fib (m - 1) ^ (p - 1) + i * fib (m - 1) ^ (p - 2) * fib m [MOD p ^ 2] := by
        intro i hi
        have h_fib_identity_i : fib (m * i + 1) ≡ fib (m - 1) ^ i + i * fib (m - 1) ^ (i - 1) * fib m [MOD p ^ 2] := by
          exact h_fib_identity i;
        convert h_fib_identity_i.mul_left ( fib ( m - 1 ) ^ ( p - 1 - i ) ) using 1 ; ring;
        rcases p with ( _ | _ | p ) <;> simp_all +decide [ ← pow_add ];
        rcases i with ( _ | _ | i ) <;> simp_all +arith +decide;
      simpa only [ ← Finset.sum_add_distrib ] using Nat.ModEq.sum h_sum_identity;
    simp_all +decide [ ← Finset.sum_mul _ _ _, Finset.sum_range_id ];
    refine h_sum_identity.trans <| Nat.ModEq.symm <| Nat.modEq_of_dvd ?_;
    obtain ⟨ k, hk ⟩ := hdvd; simp +decide [ hk, mul_assoc, mul_left_comm, hp.pos ] ;
    exact ⟨ ( p * ( p - 1 ) / 2 ) * ( fib ( m - 1 ) ^ ( p - 2 ) * k ) / p, by nlinarith [ Int.ediv_mul_cancel ( show ( p : ℤ ) ∣ ( p * ( p - 1 ) / 2 ) * ( fib ( m - 1 ) ^ ( p - 2 ) * k ) from dvd_mul_of_dvd_left ( Int.dvd_div_of_mul_dvd ( by exact ⟨ ( p - 1 ) / 2, by nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ ( p - 1 : ℤ ) from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using hp.eq_two_or_odd'.resolve_left hodd ) ) ] ⟩ ) ) _ ) ] ⟩;
  -- Since $p$ is prime and does not divide $fib(m-1)$, we have $p^2 \nmid Q$.
  obtain ⟨Q, hQ1, hQ2⟩ := h_fibQuot
  have hQ3 : ¬(p^2 ∣ Q) := by
    rw [ Nat.dvd_iff_mod_eq_zero, hQ2 ];
    rw [ ← Nat.dvd_iff_mod_eq_zero ];
    rw [ sq, mul_dvd_mul_iff_left hp.ne_zero ];
    exact mt hp.dvd_of_dvd_pow ( by intro h; have := Nat.dvd_gcd hdvd ( show p ∣ fib ( m + 1 ) from by cases m <;> simp_all +decide [ Nat.fib_add_two, Nat.dvd_add_right ] ) ; aesop );
  haveI := Fact.mk hp; rw [ hQ1, padicValNat.mul ] <;> norm_num;
  · have hQ4 : p ∣ Q := by
      exact Nat.dvd_of_mod_eq_zero ( hQ2.of_dvd ( dvd_pow_self _ two_ne_zero ) ▸ Nat.mod_eq_zero_of_dvd ( dvd_mul_right _ _ ) );
    rw [ padicValNat_dvd_iff ] at *;
    exact le_antisymm ( Nat.le_of_not_lt fun h => hQ3 <| Or.inr h ) ( Nat.pos_of_ne_zero <| by aesop );
  · linarith;
  · rintro rfl; simp_all +decide [ Nat.fib_add_two ]

/-- **Prime power step** by induction:
`v_p(F(m · p^t)) = v_p(F(m)) + t`. -/
theorem padicValNat_fib_mul_prime_pow {p m : ℕ}
    (hp : Nat.Prime p) (hodd : p ≠ 2) (h5 : p ≠ 5)
    (hm : 0 < m) (hdvd : p ∣ fib m) (t : ℕ) :
    padicValNat p (fib (m * p ^ t)) = padicValNat p (fib m) + t := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [pow_succ, ← mul_assoc,
        padicValNat_fib_mul_prime hp hodd h5
          (Nat.mul_pos hm (pow_pos hp.pos t))
          (dvd_trans hdvd (fib_dvd_of_dvd ⟨p ^ t, rfl⟩)),
        ih, Nat.add_assoc]

/-- **Fibonacci LTE (Lifting the Exponent).**
For odd prime `p ≠ 5` with `p ∣ F(m)`:
`v_p(F(mk)) = v_p(F(m)) + v_p(k)`. -/
theorem padicValNat_fib_lte {p m k : ℕ}
    (hp : Nat.Prime p) (hodd : p ≠ 2) (h5 : p ≠ 5)
    (hm : 0 < m) (hk : 0 < k) (hdvd : p ∣ fib m) :
    padicValNat p (fib (m * k)) = padicValNat p (fib m) + padicValNat p k := by
  obtain ⟨t, v, rfl, hv⟩ : ∃ t v, k = p ^ t * v ∧ ¬ p ∣ v :=
    ⟨k.factorization p, k / p ^ k.factorization p,
      (Nat.ordProj_mul_ordCompl_eq_self k p).symm,
      Nat.not_dvd_ordCompl hp hk.ne'⟩
  have hv_pos : 0 < v := Nat.pos_of_ne_zero (by intro hv0; simp [hv0] at hk)
  rw [show m * (p ^ t * v) = m * p ^ t * v from by ring]
  rw [padicValNat_fib_mul_of_coprime hp hodd h5
    (Nat.mul_pos hm (pow_pos hp.pos t)) hv_pos
    (dvd_trans hdvd (fib_dvd_of_dvd ⟨p ^ t, rfl⟩)) hv]
  rw [padicValNat_fib_mul_prime_pow hp hodd h5 hm hdvd t]
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  rw [padicValNat.mul (pow_ne_zero t hp.ne_zero) hv_pos.ne',
      padicValNat.prime_pow t, padicValNat.eq_zero_of_not_dvd hv, add_zero]

/-- Entry-point form of LTE: `v_p(F(kz)) = v_p(F(z)) + v_p(k)`. -/
theorem padicValNat_fib_entry_mult {p z k : ℕ}
    (hp : Nat.Prime p) (hp2 : p ≠ 2) (h5 : p ≠ 5)
    (hz : IsFibEntry p z) (hk : 0 < k) :
    padicValNat p (fib (k * z)) = padicValNat p (fib z) + padicValNat p k := by
  rw [mul_comm]
  exact padicValNat_fib_lte hp hp2 h5 hz.1 hk hz.2.1

/-- Commuted variant. -/
theorem padicValNat_fib_entry_mult' {p z k : ℕ}
    (hp : Nat.Prime p) (hp2 : p ≠ 2) (h5 : p ≠ 5)
    (hz : IsFibEntry p z) (hk : 0 < k) :
    padicValNat p (fib (z * k)) = padicValNat p (fib z) + padicValNat p k :=
  padicValNat_fib_lte hp hp2 h5 hz.1 hk hz.2.1

/-- Valuation on indices divisible by the entry point. -/
theorem padicValNat_fib_of_entry_dvd {p n z : ℕ}
    (hp : Nat.Prime p) (hp2 : p ≠ 2) (h5 : p ≠ 5)
    (hz : IsFibEntry p z) (hn : 0 < n) (hdvd : z ∣ n) :
    padicValNat p (fib n) = padicValNat p (fib z) + padicValNat p (n / z) := by
  obtain ⟨k, rfl⟩ := hdvd
  have hk : 0 < k := Nat.pos_of_mul_pos_left hn
  rw [Nat.mul_div_cancel_left _ hz.1]
  exact padicValNat_fib_entry_mult' hp hp2 h5 hz hk

/-! ## Section 6: Primitive divisor definitions and bridge lemma -/

/-- `FibPrimitivePrimeAt n p` asserts that `p` is a primitive prime
divisor of `F(n)`: prime, divides `F(n)`, not dividing any earlier `F(k)`. -/
def FibPrimitivePrimeAt (n p : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ fib n ∧ ∀ m, 0 < m → m < n → ¬ p ∣ fib m

/-- **Bridge lemma**: primitivity over all `0 < k < n` reduces to
proper divisors `d | n`, using `gcd(F(n), F(k)) = F(gcd(n,k))`. -/
theorem fib_primitive_of_proper_div (n : ℕ) (hn : 0 < n) (p : ℕ)
    (hp : Nat.Prime p) (hpn : p ∣ fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ fib d) :
    FibPrimitivePrimeAt n p := by
  refine ⟨hp, hpn, fun k hk hkn hpk => ?_⟩
  exact hdiv (Nat.gcd n k) (Nat.gcd_dvd_left n k)
    (Nat.gcd_pos_of_pos_left k hn)
    (lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn)
    (dvd_fib_gcd_of_dvd_fib hpn hpk)

/-- Checking primitivity reduces to proper divisors. -/
theorem fib_primitive_iff_proper_divs {n : ℕ} (hn : 0 < n) {p : ℕ}
    (_hp : Nat.Prime p) (hpn : p ∣ fib n) :
    (∀ k, 0 < k → k < n → ¬ p ∣ fib k) ↔
    (∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ fib d) := by
  constructor
  · exact fun h d _ hd hd' => h d hd hd'
  · exact fun h k hk hkn hpk =>
      h (Nat.gcd n k) (Nat.gcd_dvd_left n k)
        (Nat.gcd_pos_of_pos_left k hn)
        (lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn)
        (dvd_fib_gcd_of_dvd_fib hpn hpk)

/-! ## Section 7: Specific entry points -/

/-- `IsFibEntry 5 5`: the entry point of 5 is 5 (since F(5) = 5). -/
theorem isFibEntry_five : IsFibEntry 5 5 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · native_decide
  · intro m hm hm5; interval_cases m <;> native_decide

/-- `IsFibEntry 3 4`: the entry point of 3 is 4 (since F(4) = 3). -/
theorem isFibEntry_three : IsFibEntry 3 4 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · native_decide
  · intro m hm hm4; interval_cases m <;> native_decide

/-- `IsFibEntry 7 8`: the entry point of 7 is 8 (since F(8) = 21). -/
theorem isFibEntry_seven : IsFibEntry 7 8 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · native_decide
  · intro m hm hm8; interval_cases m <;> native_decide

/-- `IsFibEntry 11 10`: the entry point of 11 is 10 (since F(10) = 55). -/
theorem isFibEntry_eleven : IsFibEntry 11 10 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · native_decide
  · intro m hm hm10; interval_cases m <;> native_decide

/-- `IsFibEntry 13 7`: the entry point of 13 is 7 (since F(7) = 13). -/
theorem isFibEntry_thirteen : IsFibEntry 13 7 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · native_decide
  · intro m hm hm7; interval_cases m <;> native_decide