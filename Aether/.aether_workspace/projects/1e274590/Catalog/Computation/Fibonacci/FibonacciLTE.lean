import Mathlib
import LiftingExponentLemma

/-!
# Lifting the Exponent Lemma for Fibonacci Numbers

This file formalizes the Lifting the Exponent Lemma (LTE) specialized to Fibonacci
sequences. The main result is:

**Theorem** (`fib_emultiplicity_mul`): For an odd prime `p` dividing `Nat.fib m`
(with `m > 0`),
  `v_p(F(k * m)) = v_p(F(m)) + v_p(k)`

Note: This result is false for `p = 2`. For example, `v_2(F(6)) = 3` but
`v_2(F(3)) + v_2(2) = 1 + 1 = 2`.

## Proof outline

The proof uses strong induction on `k`, decomposing into two cases:

1. **Case `p ∤ k`**: We show `p ∤ fibQuot(m, k)` where `fibQuot(m, k) = F(km)/F(m)`.
   This follows from the congruence `fibQuot(m, k) ≡ k · F(m-1)^(k-1) (mod p)`,
   since `p ∤ k` and `p ∤ F(m-1)` (from coprimality of consecutive Fibonacci numbers).

2. **Case `p | k`**: Write `k = p · j`. By the inductive hypothesis,
   `v_p(F(j·m)) = v_p(F(m)) + v_p(j)`. Then we show `v_p(F(p·(j·m))) = v_p(F(j·m)) + 1`,
   which uses the mod `p²` analysis showing `fibQuot(jm, p) ≡ p · F(jm-1)^(p-1) (mod p²)`.

## References

* The Lifting the Exponent Lemma is classical; see e.g. Ribenboim's "The Little Book
  of Bigger Primes" or various competition resources.
-/

open scoped Nat

noncomputable section

/-! ## Fibonacci addition formula -/

/-
The Fibonacci addition formula: `F(n + m) = F(n) * F(m-1) + F(n+1) * F(m)` for `m ≥ 1`.
This is a direct consequence of `Nat.fib_add`.
-/
theorem fib_add_formula (n : ℕ) {m : ℕ} (hm : 0 < m) :
    Nat.fib (n + m) = Nat.fib n * Nat.fib (m - 1) + Nat.fib (n + 1) * Nat.fib m := by
  convert Nat.fib_add n ( m - 1 ) using 1 ; cases m <;> simp_all +arith +decide;
  rw [ Nat.sub_add_cancel hm ]

/-! ## Fibonacci quotient and basic properties -/

/-- The Fibonacci quotient: `fibQuot m k = F(k * m) / F(m)`.
This is always a natural number by `Nat.fib_dvd`. -/
def fibQuot (m k : ℕ) : ℕ := Nat.fib (k * m) / Nat.fib m

/-- `F(m) ∣ F(k * m)`. -/
theorem fib_dvd_fib_mul (m k : ℕ) : Nat.fib m ∣ Nat.fib (k * m) :=
  Nat.fib_dvd m (k * m) (dvd_mul_left m k)

/-- `fibQuot m k * F(m) = F(k * m)`. -/
theorem fibQuot_mul_fib (m k : ℕ) :
    fibQuot m k * Nat.fib m = Nat.fib (k * m) :=
  Nat.div_mul_cancel (fib_dvd_fib_mul m k)

/-- For `m ≥ 1`, consecutive Fibonacci numbers are coprime. -/
theorem fib_coprime_fib_pred {m : ℕ} (hm : 0 < m) :
    Nat.Coprime (Nat.fib m) (Nat.fib (m - 1)) := by
  rcases m with _ | n
  · omega
  · simp; exact (Nat.fib_coprime_fib_succ n).symm

/-
If `p` is prime and `p ∣ F(m)` with `m > 0`, then `p ∤ F(m-1)`.
-/
theorem not_dvd_fib_pred_of_prime_dvd_fib {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : 0 < m)
    (hpF : p ∣ Nat.fib m) : ¬p ∣ Nat.fib (m - 1) := by
  exact fun h => hp.not_dvd_one <| Nat.dvd_gcd hpF h |> fun h => by have := fib_coprime_fib_pred hm; aesop;

/-! ## Key congruences -/

/-
`F(k*m + 1) ≡ F(m+1)^k [MOD F(m)]` for `m ≥ 1`.
This is proven by induction on `k` using the Fibonacci addition formula.
-/
theorem fib_mul_add_one_mod_fib (k : ℕ) {m : ℕ} (hm : 0 < m) :
    Nat.fib (k * m + 1) ≡ Nat.fib (m + 1) ^ k [MOD Nat.fib m] := by
  -- We use the Fibonacci addition formula: F(k*m+1) = F(k*m) * F(m-1) + F(k*m+1) * F(m).
  have h_add : ∀ n, Nat.fib (n + m) ≡ Nat.fib n * Nat.fib (m - 1) + Nat.fib (n + 1) * Nat.fib m [MOD Nat.fib m] := by
    exact fun n => by rw [ fib_add_formula n hm ] ;
  induction' k with k ih;
  · norm_num;
    rfl;
  · simp_all +decide [ ← ZMod.natCast_eq_natCast_iff, pow_succ, mul_add, add_mul, add_assoc ];
    convert h_add ( k * m + 1 ) using 1 ; ring;
    cases m <;> simp_all +decide [ Nat.fib_add_two ]

/-
The Fibonacci quotient satisfies `fibQuot m k ≡ k * F(m-1)^(k-1) [MOD p]`
when `p ∣ F(m)`, for `k ≥ 1` and `m > 0`.
-/
theorem fibQuot_mod_prime {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : 0 < m)
    (hpF : p ∣ Nat.fib m) {k : ℕ} (hk : 0 < k) :
    (fibQuot m k : ZMod p) = k * (Nat.fib (m - 1) : ZMod p) ^ (k - 1) := by
  -- We proceed by induction on $k$.
  induction' k with k ih;
  · contradiction;
  · -- By definition of fibQuot, we have:
    have h_fibQuot_succ : fibQuot m (k + 1) = fibQuot m k * Nat.fib (m - 1) + Nat.fib (k * m + 1) := by
      -- We use the recurrence relation for Fibonacci numbers: F((k+1)*m) = F(km)*F(m-1) + F(km+1)*F(m).
      have h_fib_recurrence : Nat.fib ((k + 1) * m) = Nat.fib (k * m) * Nat.fib (m - 1) + Nat.fib (k * m + 1) * Nat.fib m := by
        convert fib_add_formula ( k * m ) hm using 1 ; ring;
      unfold fibQuot;
      rw [ h_fib_recurrence, Nat.div_eq_of_eq_mul_left ];
      · exact Nat.fib_pos.mpr hm;
      · nlinarith [ Nat.div_mul_cancel ( show Nat.fib m ∣ Nat.fib ( k * m ) from Nat.fib_dvd _ _ ( dvd_mul_left _ _ ) ) ];
    have h_fib_mul_add_one_mod_fib : Nat.fib (k * m + 1) ≡ Nat.fib (m + 1) ^ k [MOD p] := by
      exact Nat.ModEq.of_dvd hpF ( fib_mul_add_one_mod_fib k hm );
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
    rcases k <;> simp_all +decide [ add_mul, pow_succ' ];
    · unfold fibQuot; aesop;
    · cases m <;> simp_all +decide [ Nat.fib_add_two ] ; ring;
      simp_all +decide [ ← ZMod.natCast_eq_zero_iff, add_comm 1 ] ; ring

/-
For an odd prime `p` with `p ∣ F(m)` and `m > 0`,
`fibQuot m p ≡ p * F(m-1)^(p-1) (mod p²)`.
This is the key step for the LTE: it implies `v_p(fibQuot m p) = 1`.
-/
set_option maxHeartbeats 800000 in
theorem fibQuot_mod_prime_sq {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {m : ℕ} (hm : 0 < m) (hpF : p ∣ Nat.fib m) :
    (fibQuot m p : ZMod (p ^ 2)) =
      p * (Nat.fib (m - 1) : ZMod (p ^ 2)) ^ (p - 1) := by
  -- By induction on $k$, we show that for any $k$, $(fibQuot m k : ZMod (p^2)) = k * (Nat.fib (m - 1) : ZMod (p^2)) ^ (k - 1) + (k.choose 2) * (Nat.fib (m - 1) : ZMod (p^2)) ^ (k - 2) * (Nat.fib m : ZMod (p^2))$.
  have h_induction : ∀ k : ℕ, (fibQuot m k : ZMod (p^2)) = k * (Nat.fib (m - 1) : ZMod (p^2)) ^ (k - 1) + (k.choose 2) * (Nat.fib (m - 1) : ZMod (p^2)) ^ (k - 2) * (Nat.fib m : ZMod (p^2)) := by
    intro k;
    induction' k with k ih;
    · unfold fibQuot; aesop;
    · -- By definition of `fibQuot`, we have `fibQuot m (k + 1) = fibQuot m k * Nat.fib (m - 1) + Nat.fib (k * m + 1)`.
      have h_fibQuot_succ : fibQuot m (k + 1) = fibQuot m k * Nat.fib (m - 1) + Nat.fib (k * m + 1) := by
        unfold fibQuot;
        rw [ Nat.succ_mul, fib_add_formula ];
        · rw [ Nat.add_div ] <;> norm_num [ Nat.fib_pos, hm ];
          rw [ if_neg ];
          · rw [ Nat.div_eq_of_eq_mul_left ];
            rw [ add_zero ];
            · exact Nat.fib_pos.mpr hm;
            · rw [ mul_right_comm, Nat.div_mul_cancel ( fib_dvd_fib_mul m k ) ];
          · exact Nat.not_le_of_gt ( Nat.mod_lt _ ( Nat.fib_pos.mpr hm ) );
        · linarith;
      -- By definition of `Nat.fib`, we have `Nat.fib (k * m + 1) ≡ (Nat.fib (m - 1) + Nat.fib m) ^ k [MOD p^2]`.
      have h_fib_succ : Nat.fib (k * m + 1) ≡ (Nat.fib (m - 1) + Nat.fib m) ^ k [MOD p^2] := by
        have h_fib_succ : Nat.fib (k * m + 1) ≡ Nat.fib (m + 1) ^ k [MOD p^2] := by
          have h_fib_succ : ∀ k : ℕ, Nat.fib (k * m + 1) ≡ Nat.fib (m + 1) ^ k [MOD Nat.fib m ^ 2] := by
            intro k;
            induction' k with k ih;
            · norm_num;
              rfl;
            · have h_fib_succ : Nat.fib ((k + 1) * m + 1) = Nat.fib (k * m + 1) * Nat.fib (m + 1) + Nat.fib (k * m) * Nat.fib m := by
                convert fib_add_formula ( k * m + 1 ) ( show 0 < m by linarith ) using 1 ; ring;
                cases m <;> simp_all +decide [ Nat.fib_add_two ] ; linarith;
              simp_all +decide [ ← ZMod.natCast_eq_natCast_iff, pow_succ ];
              norm_cast;
              rw [ ZMod.natCast_eq_zero_iff ];
              exact mul_dvd_mul ( by simpa [ Nat.fib_dvd ] ) dvd_rfl;
          exact h_fib_succ k |> Nat.ModEq.of_dvd ( pow_dvd_pow_of_dvd hpF 2 );
        cases m <;> simp_all +decide [ Nat.fib_add_two ];
      -- Expand $(Nat.fib (m - 1) + Nat.fib m) ^ k$ using the binomial theorem.
      have h_binom : (Nat.fib (m - 1) + Nat.fib m) ^ k ≡ Nat.fib (m - 1) ^ k + k * Nat.fib (m - 1) ^ (k - 1) * Nat.fib m [MOD p^2] := by
        have h_binom : (Nat.fib (m - 1) + Nat.fib m) ^ k = ∑ i ∈ Finset.range (k + 1), Nat.choose k i * Nat.fib (m - 1) ^ (k - i) * Nat.fib m ^ i := by
          exact by rw [ Nat.add_comm, add_pow ] ; ac_rfl;
        rcases k with ( _ | k ) <;> simp_all +decide [ Finset.sum_range_succ' ];
        norm_num [ add_comm, add_left_comm, add_assoc, Nat.modEq_iff_dvd ];
        exact Finset.dvd_sum fun i hi => dvd_mul_of_dvd_right ( mod_cast dvd_trans ( pow_dvd_pow_of_dvd hpF 2 ) ( pow_dvd_pow _ ( by linarith ) ) ) _;
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.choose_succ_succ, pow_succ' ] ; ring;
      ring;
  obtain ⟨ k, hk ⟩ := hpF; simp_all +decide [ Nat.choose_two_right ] ;
  norm_cast; simp +decide [ Nat.mul_div_assoc _ ( show 2 ∣ p - 1 from even_iff_two_dvd.mp ( hp.even_sub_one <| by rintro rfl; contradiction ) ) ] ;
  norm_cast; ring_nf; aesop;

/-! ## Core valuation lemmas -/

/-
If `p ∤ k` and `p ∣ F(m)` with `m > 0`, then `p ∤ fibQuot m k`.
-/
theorem fibQuot_not_dvd_of_not_dvd {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : 0 < m)
    (hpF : p ∣ Nat.fib m) {k : ℕ} (hk : 0 < k) (hpk : ¬p ∣ k) :
    ¬p ∣ fibQuot m k := by
  haveI := Fact.mk hp;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff, fibQuot_mod_prime ];
  exact fun h => absurd h ( by simpa [ ← ZMod.natCast_eq_zero_iff ] using not_dvd_fib_pred_of_prime_dvd_fib hp hm <| by rwa [ ← ZMod.natCast_eq_zero_iff ] )

/-
For an odd prime `p` with `p ∣ F(m)` and `m > 0`,
`v_p(fibQuot m p) = 1`, i.e., `p` exactly divides the Fibonacci quotient `F(pm)/F(m)`.
-/
theorem fibQuot_emultiplicity_prime {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {m : ℕ} (hm : 0 < m) (hpF : p ∣ Nat.fib m) :
    emultiplicity p (fibQuot m p) = 1 := by
  have h_div : p ∣ fibQuot m p := by
    have := fibQuot_mod_prime hp hm hpF ( show 0 < p from hp.pos );
    simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]
  have h_not_div_sq : ¬p^2 ∣ fibQuot m p := by
    have h_mod : (fibQuot m p : ZMod (p^2)) = p * (Nat.fib (m - 1) : ZMod (p^2)) ^ (p - 1) := by
      convert fibQuot_mod_prime_sq hp hodd hm hpF using 1;
    have h_not_div_sq : ¬(p : ZMod (p^2)) * (Nat.fib (m - 1) : ZMod (p^2)) ^ (p - 1) = 0 := by
      have h_not_div_sq : ¬(p : ℤ) ^ 2 ∣ (p : ℤ) * (Nat.fib (m - 1) : ℤ) ^ (p - 1) := by
        rw [ sq, mul_dvd_mul_iff_left ( Nat.cast_ne_zero.mpr hp.ne_zero ) ];
        exact_mod_cast mt hp.dvd_of_dvd_pow ( not_dvd_fib_pred_of_prime_dvd_fib hp hm hpF );
      norm_cast at *;
      rw [ ZMod.natCast_eq_zero_iff ] ; aesop;
    contrapose! h_not_div_sq; erw [ ← ZMod.natCast_eq_zero_iff ] at *; aesop;
  rw [ emultiplicity_eq_of_dvd_of_not_dvd ] <;> norm_cast;
  simpa using h_div

/-! ## The main theorem -/

/-
**Fibonacci Lifting the Exponent Lemma.**
For an odd prime `p` with `p ∣ F(m)` and `m > 0`,
`v_p(F(k * m)) = v_p(F(m)) + v_p(k)`.
-/
theorem fib_emultiplicity_mul {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {m : ℕ} (hm : 0 < m) (hpF : p ∣ Nat.fib m) (k : ℕ) :
    emultiplicity p (Nat.fib (k * m)) =
      emultiplicity p (Nat.fib m) + emultiplicity p k := by
  induction' k using Nat.strongRecOn with k ih;
  by_cases hk : 0 < k;
  · by_cases h : p ∣ k;
    · obtain ⟨ j, rfl ⟩ := h;
      -- Using the induction hypothesis and the properties of emultiplicity, we can simplify the expression.
      have h_emultiplicity : emultiplicity p (Nat.fib (p * j * m)) = emultiplicity p (Nat.fib (j * m)) + emultiplicity p (fibQuot (j * m) p) := by
        have h_emultiplicity : emultiplicity p (Nat.fib (p * j * m)) = emultiplicity p (fibQuot (j * m) p * Nat.fib (j * m)) := by
          rw [ fibQuot_mul_fib ] ; ring;
        rw [ h_emultiplicity, add_comm, emultiplicity_mul ];
        exact Nat.prime_iff.mp hp;
      rw [ h_emultiplicity, ih j ( by nlinarith [ hp.two_le ] ), fibQuot_emultiplicity_prime hp hodd ];
      · rw [ add_assoc, emultiplicity_mul ];
        · rw [ add_comm, hp.emultiplicity_self ];
          ring;
        · exact Nat.prime_iff.mp hp;
      · nlinarith;
      · exact dvd_trans hpF ( Nat.fib_dvd _ _ ( dvd_mul_left _ _ ) );
    · -- Since $p \nmid k$, we have $emultiplicity p (fibQuot m k) = 0$.
      have h_emultiplicity_fibQuot : emultiplicity p (fibQuot m k) = 0 := by
        exact emultiplicity_eq_zero.mpr ( fibQuot_not_dvd_of_not_dvd hp hm hpF hk h );
      rw [ ← fibQuot_mul_fib m k, emultiplicity_mul ];
      · rw [ h_emultiplicity_fibQuot, zero_add, add_comm ];
        rw [ emultiplicity_eq_zero.mpr h, zero_add ];
      · exact Nat.prime_iff.mp hp;
  · aesop

/-! ## Corollaries -/

/-- If `p ∣ F(m)` and `p ∤ k`, with p odd prime and `m > 0`,
then `v_p(F(k*m)) = v_p(F(m))`. -/
theorem fib_emultiplicity_mul_of_not_dvd {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {m : ℕ} (hm : 0 < m) (hpF : p ∣ Nat.fib m) {k : ℕ} (hk : ¬p ∣ k) :
    emultiplicity p (Nat.fib (k * m)) = emultiplicity p (Nat.fib m) := by
  rw [fib_emultiplicity_mul hp hodd hm hpF]
  simp [emultiplicity_eq_zero.mpr hk]

/-- If `p ∣ F(m)` with p odd prime and `m > 0`, then `v_p(F(p * m)) = v_p(F(m)) + 1`. -/
theorem fib_emultiplicity_prime_mul {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {m : ℕ} (hm : 0 < m) (hpF : p ∣ Nat.fib m) :
    emultiplicity p (Nat.fib (p * m)) = emultiplicity p (Nat.fib m) + 1 := by
  rw [fib_emultiplicity_mul hp hodd hm hpF]
  congr 1
  exact hp.emultiplicity_self

end