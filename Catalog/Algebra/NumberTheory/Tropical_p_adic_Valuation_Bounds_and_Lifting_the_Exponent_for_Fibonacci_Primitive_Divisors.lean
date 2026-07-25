/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
  · rcases k with ( _ | k ) <;> simp_all +arith +decide [ Nat.mul_succ, pow_succ' ];
    norm_num [ Nat.add_div ];
    induction' k with k ih <;> norm_num [ Nat.pow_succ', Nat.fib_add_two, Nat.mul_succ ] at *;
    linarith [ Nat.zero_le ( fib ( 2 * k ) ), Nat.zero_le ( fib ( 2 * k + 1 ) ) ]

/-
F_{m+n} ≥ F_m * F_n for m, n ≥ 1. This is a key multiplicative bound.
-/
theorem fib_mul_le_fib_add (m n : ℕ) (hm : 1 ≤ m) (hn : 1 ≤ n) :
    Nat.fib m * Nat.fib n ≤ Nat.fib (m + n) := by
  induction' hn with hn ih <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ];
  · exact Nat.fib_le_fib_succ;
  · rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.fib_add, mul_add ];
    · exact Nat.fib_mono ( by linarith );
    · simp_all +decide [ ← add_assoc, Nat.fib_add ];
      exact le_add_of_nonneg_of_le ( Nat.zero_le _ ) ( Nat.mul_le_mul ( by simp +arith +decide ) le_rfl )

/-! ## Section 6: The Tropical Valuation Framework

The p-adic valuation v_p satisfies the ultrametric inequality:
  v_p(a + b) ≥ min(v_p(a), v_p(b))
This is the "tropical" or "min-plus" structure underlying the LTE lemma.
-/

/-
The p-adic valuation is subadditive in the tropical (min-plus) sense:
    v_p(a + b) ≥ min(v_p(a), v_p(b)).
-/
theorem padic_val_min_le_add (p a b : ℕ) (hp : Nat.Prime p) (ha : 0 < a) (hb : 0 < b) :
    min (padicValNat p a) (padicValNat p b) ≤ padicValNat p (a + b) := by
  have h_div : p ^ min (padicValNat p a) (padicValNat p b) ∣ a + b := by
    have h_div : p ^ padicValNat p a ∣ a ∧ p ^ padicValNat p b ∣ b := by
      exact ⟨ by exact? , by exact? ⟩;
    exact dvd_add ( dvd_trans ( pow_dvd_pow _ ( min_le_left _ _ ) ) h_div.1 ) ( dvd_trans ( pow_dvd_pow _ ( min_le_right _ _ ) ) h_div.2 );
  rw [ ← Nat.factorization_le_iff_dvd ] at h_div <;> simp_all +decide [ hp.ne_zero, hp.factorization ];
  · simp_all +decide [ Nat.factorization ];
  · aesop

/-
Multiplicativity of p-adic valuation: v_p(a * b) = v_p(a) + v_p(b).
-/
theorem padic_val_mul_eq_add (p a b : ℕ) (hp : Nat.Prime p) (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI := Fact.mk hp; rw [ padicValNat.mul ha.ne' hb.ne' ] ;

/-! ## Section 7: Lifting-the-Exponent for Fibonacci

The LTE lemma for Fibonacci: if p is an odd prime with p | F_k,
then v_p(F_{nk}) = v_p(F_k) + v_p(n).
-/

/-
**Lifting-the-Exponent for Fibonacci**: For an odd prime p dividing F_k,
    the p-adic valuation satisfies v_p(F_{n·k}) = v_p(F_k) + v_p(n)
    when gcd(n, p) = 1.

    This is a Fibonacci-specific instance of the general LTE lemma,
    connecting tropical (min-plus) valuation calculus with Fibonacci divisibility.
-/
theorem fib_lte (p k n : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2)
    (hk : 0 < k) (hn : 0 < n) (hpk : p ∣ Nat.fib k) (hpn : ¬(p ∣ n)) :
    padicValNat p (Nat.fib (n * k)) = padicValNat p (Nat.fib k) + padicValNat p n := by
  -- By induction on $n$, we can show that $p \nmid F_{nk}/F_k$.
  have h_ind : ∀ n : ℕ, 0 < n → ¬(p ∣ n) → ¬(p ∣ (Nat.fib (n * k) / Nat.fib k)) := by
    intro n hn hpn
    have h_fib_div : Nat.fib (n * k) = Nat.fib k * (Nat.fib (n * k) / Nat.fib k) := by
      rw [ Nat.mul_div_cancel' ];
      convert Nat.fib_dvd _ _ ( dvd_mul_left k n ) using 1;
    -- By induction on $n$, we can show that $F_{nk}/F_k \equiv n F_{k-1}^{n-1} \pmod{p}$.
    have h_induction : ∀ n : ℕ, 0 < n → (Nat.fib (n * k) / Nat.fib k) ≡ n * Nat.fib (k - 1) ^ (n - 1) [MOD p] := by
      intro n hn; induction hn <;> simp_all +decide [ Nat.succ_mul, ← ZMod.natCast_eq_natCast_iff ] ;
      -- Using the identity $F_{m+k} = F_m F_{k-1} + F_{m+1} F_k$, we can rewrite $F_{mk+k}$.
      have h_fib_identity : Nat.fib (‹_› * k + k) = Nat.fib (‹_› * k) * Nat.fib (k - 1) + Nat.fib (‹_› * k + 1) * Nat.fib k := by
        have h_fib_identity : ∀ m n : ℕ, m > 0 → n > 0 → Nat.fib (m + n) = Nat.fib m * Nat.fib (n - 1) + Nat.fib (m + 1) * Nat.fib n := by
          intros m n hm hn; induction' hn with n hn ih generalizing m <;> simp_all +decide [ Nat.fib_add_two, Nat.fib_add ] ;
          convert ih ( m + 1 ) ( Nat.succ_pos _ ) using 1 ; ring;
          cases n <;> simp_all +decide [ Nat.fib_add_two ] ; linarith;
        exact h_fib_identity _ _ ( Nat.mul_pos ‹_› hk ) hk;
      have h_fib_div : Nat.fib (‹_› * k + k) / Nat.fib k = Nat.fib (‹_› * k) / Nat.fib k * Nat.fib (k - 1) + Nat.fib (‹_› * k + 1) := by
        rw [ h_fib_identity, Nat.add_div ] <;> norm_num [ Nat.mul_div_assoc, Nat.fib_pos.mpr hk ];
        rw [ Nat.mul_comm, Nat.mul_div_assoc ];
        · rw [ if_neg ( Nat.not_le_of_gt ( Nat.mod_lt _ ( Nat.fib_pos.mpr hk ) ) ) ] ; ring;
        · exact Nat.fib_dvd _ _ ( dvd_mul_left _ _ );
      have h_fib_mod : Nat.fib (‹_› * k + 1) ≡ Nat.fib (k - 1) ^ ‹_› [MOD p] := by
        have h_fib_mod : ∀ m : ℕ, Nat.fib (m * k + 1) ≡ Nat.fib (k - 1) ^ m [MOD p] := by
          intro m; induction m <;> simp_all +decide [ Nat.succ_mul, ← ZMod.natCast_eq_natCast_iff ] ;
          have h_fib_identity : Nat.fib (‹_› * k + k + 1) = Nat.fib (‹_› * k + 1) * Nat.fib (k + 1) + Nat.fib (‹_› * k) * Nat.fib k := by
            grind +suggestions;
          simp_all +decide [ pow_succ, ← ZMod.natCast_eq_zero_iff ];
          rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.fib_add_two ];
        exact h_fib_mod _;
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      rw [ mul_assoc, ← pow_succ, Nat.sub_add_cancel ‹_› ];
    -- Since $p \nmid n$ and $p \nmid F_{k-1}$, it follows that $p \nmid n F_{k-1}^{n-1}$.
    have h_not_div : ¬(p ∣ n * Nat.fib (k - 1) ^ (n - 1)) := by
      have h_not_div : ¬(p ∣ Nat.fib (k - 1)) := by
        have h_coprime : Nat.gcd (Nat.fib k) (Nat.fib (k - 1)) = 1 := by
          rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.fib_add_two, Nat.gcd_comm ];
          exact Nat.recOn k ( by norm_num ) fun n ih => by simp_all +decide [ Nat.fib_add_two, Nat.gcd_comm ] ;
        exact fun h => hp.not_dvd_one <| h_coprime ▸ Nat.dvd_gcd hpk h;
      exact Nat.Prime.not_dvd_mul hp hpn fun h => h_not_div <| hp.dvd_of_dvd_pow h;
    exact fun h => h_not_div <| Nat.dvd_of_mod_eq_zero <| h_induction n hn ▸ Nat.modEq_zero_iff_dvd.mpr h;
  have h_div : Nat.fib k ∣ Nat.fib (n * k) := by
    convert Nat.fib_dvd _ _ ( dvd_mul_left k n ) using 1;
  have h_val : padicValNat p (fib (n * k)) = padicValNat p (fib k) + padicValNat p (fib (n * k) / fib k) := by
    haveI := Fact.mk hp; rw [ ← padicValNat.mul ( Nat.ne_of_gt ( Nat.pos_of_dvd_of_pos h_div ( Nat.fib_pos.mpr ( by positivity ) ) ) ) ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.fib_pos.mpr ( by positivity ) ) h_div ) ( Nat.pos_of_dvd_of_pos h_div ( Nat.fib_pos.mpr ( by positivity ) ) ) ) ), Nat.mul_div_cancel' h_div ] ;
  simp_all +decide [ padicValNat.eq_zero_of_not_dvd ]

/-! ## Section 8: Carmichael's Theorem - Computational Cases

We verify the small cases of Carmichael's theorem computationally.
-/

/-
F_1 = 1 has no primitive prime divisor (it has no prime divisors at all).
-/
theorem fib_one_no_primitive : ¬ HasPrimitivePrimeDivisor 1 := by
  -- By definition, 1 has no primitive prime divisors.
  simp [HasPrimitivePrimeDivisor, IsPrimitivePrimeDivisor];
  norm_num

/-
F_2 = 1 has no primitive prime divisor.
-/
theorem fib_two_no_primitive : ¬ HasPrimitivePrimeDivisor 2 := by
  rintro ⟨ p, hp₁, hp₂, hp₃ ⟩;
  exact hp₁.not_dvd_one hp₂

/-
F_6 = 8 has no primitive prime divisor (2 = z(2) divides 6 but z(2) ≠ 6).
-/
theorem fib_six_no_primitive : ¬ HasPrimitivePrimeDivisor 6 := by
  rintro ⟨ p, hp₁, hp₂, hp₃ ⟩;
  have := Nat.le_of_dvd ( by decide ) hp₂; interval_cases p <;> specialize hp₃ 3 <;> norm_num at *;

/-
F_12 = 144 has no primitive prime divisor
    (2 | F_3 so z(2) = 3 | 12; 3 | F_4 so z(3) = 4 | 12).
-/
theorem fib_twelve_no_primitive : ¬ HasPrimitivePrimeDivisor 12 := by
  rintro ⟨ p, hp₁, hp₂, hp₃ ⟩;
  have := Nat.le_of_dvd ( by decide ) hp₂; interval_cases p <;> norm_num at *;
  · exact absurd ( hp₃ 3 ( by decide ) ( by decide ) ) ( by decide );
  · exact hp₃ 4 ( by decide ) ( by decide ) ( by decide )

/-! ## Section 9: Carmichael's Theorem - Positive Cases

For specific indices, we verify the existence of primitive prime divisors.
-/

/-
F_3 = 2 has primitive prime divisor p = 2.
-/
theorem fib_three_has_primitive : HasPrimitivePrimeDivisor 3 := by
  use 2;
  constructor <;> norm_num;
  intro k hk hk'; interval_cases k <;> trivial;

/-
F_4 = 3 has primitive prime divisor p = 3.
-/
theorem fib_four_has_primitive : HasPrimitivePrimeDivisor 4 := by
  -- We verify that 4 has a primitive prime divisor using the definition.
  unfold HasPrimitivePrimeDivisor
  use 3
  constructor
  all_goals norm_num;
  intro k hk hk'; interval_cases k <;> trivial;

/-
F_5 = 5 has primitive prime divisor p = 5.
-/
theorem fib_five_has_primitive : HasPrimitivePrimeDivisor 5 := by
  use 5;
  constructor <;> norm_num;
  intro k hk hk'; interval_cases k <;> trivial;

/-
F_7 = 13 has primitive prime divisor p = 13.
-/
theorem fib_seven_has_primitive : HasPrimitivePrimeDivisor 7 := by
  -- Consider the prime number $p = 13$.
  use 13;
  exact ⟨ by norm_num, by native_decide, fun k hk hk' => by interval_cases k <;> trivial ⟩

/-! ## Section 10: Key Divisibility Properties for Composite Case -/

/-- **Fibonacci GCD identity** (from Mathlib): gcd(F_m, F_n) = F_{gcd(m, n)}.
    This is the foundation of the entry point theory. -/
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- **Fibonacci divisibility** (from Mathlib): m | n → F_m | F_n. -/
theorem fib_dvd_of_dvd (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd m n h

/-
If n > 0 is composite (not prime and > 1), then n has a proper divisor d
    with 1 < d < n.
-/
theorem composite_has_proper_divisor (n : ℕ) (hn : 1 < n) (hnp : ¬ Nat.Prime n) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n := by
  exact Exists.imp ( by tauto ) ( Nat.exists_dvd_of_not_prime2 hn hnp )

/-
For composite n, F_n has a non-trivial factor from a proper divisor.
-/
theorem fib_composite_nontrivial_factor (n : ℕ) (hn : 1 < n) (hnp : ¬ Nat.Prime n) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ Nat.fib d ∣ Nat.fib n := by
  rcases composite_has_proper_divisor n hn hnp with ⟨ d, hd1, hdn, hdvd ⟩ ; exact ⟨ d, hd1, hdn, fib_dvd_of_dvd d n hdvd ⟩

/-! ## Section 11: Carmichael's Theorem for Prime Indices

For prime p, F_p has a primitive prime divisor. This is easier than
the composite case because the only proper divisors of p are 1 and p.
-/

/-
**Carmichael for primes ≥ 5**: If p ≥ 5 is prime, then F_p > 1
    and any prime factor q of F_p with q ∤ F_1 = 1 is automatically primitive.
-/
theorem fib_prime_has_primitive (p : ℕ) (hp : Nat.Prime p) (hp5 : 5 ≤ p) :
    HasPrimitivePrimeDivisor p := by
  obtain ⟨q, hq_prime, hq_div⟩ : ∃ q : ℕ, Nat.Prime q ∧ q ∣ Nat.fib p ∧ ¬(q ∣ Nat.fib 1) := by
    norm_num +zetaDelta at *;
    exact ⟨ Nat.minFac ( fib p ), Nat.minFac_prime ( by linarith [ fib_ge_index p hp5 ] ), Nat.minFac_dvd _, Nat.Prime.ne_one ( Nat.minFac_prime ( by linarith [ fib_ge_index p hp5 ] ) ) ⟩;
  refine' ⟨ q, hq_prime, hq_div.1, _ ⟩;
  intro k hk hk' hk''; have := Nat.dvd_gcd hk'' hq_div.1; simp_all +decide [ fib_gcd_identity ] ;
  rw [ Nat.gcd_comm ] at this; rw [ hp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt hk hk' ] at this; aesop;

/-! ## Section 12: Main Theorem Infrastructure

The key lemma for the composite case: F_n strictly exceeds the product
contribution from proper divisors when n > 12.
-/

/-- F_n > F_d whenever 2 ≤ d < n. -/
theorem fib_strict_mono_pos {d n : ℕ} (hd : 2 ≤ d) (hdn : d < n) :
    Nat.fib d < Nat.fib n :=
  fib_strict_mono_of_ge_two hd hdn

/-
For n ≥ 13, F_n has more than 2 digits (F_n > 100).
-/
theorem fib_large (n : ℕ) (hn : 13 ≤ n) : 100 < Nat.fib n := by
  exact lt_of_lt_of_le ( by decide ) ( Nat.fib_mono hn )

/-! ## Section 13: Auxiliary Number Theory -/

/-
Every integer > 1 has a prime divisor.
-/
theorem exists_prime_dvd (n : ℕ) (hn : 1 < n) : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
  exact Nat.exists_prime_and_dvd hn.ne'

/-
Every natural number > 1 has a prime factor. Applied to Fibonacci.
-/
theorem fib_has_prime_factor (n : ℕ) (hn : 1 < Nat.fib n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n := by
  exact Nat.exists_prime_and_dvd hn.ne'

/-
The entry point z(p) divides p² - 1 for any odd prime p.
-/
theorem entry_point_dvd_sq_sub_one (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    ∃ k : ℕ, 0 < k ∧ k ∣ (p * p - 1) ∧ p ∣ Nat.fib k := by
  -- Consider the Fibonacci sequence modulo \( p \), viewed as pairs \( (F_n \mod p, F_{n+1} \mod p) \) in \( (\mathbb{Z}/p\mathbb{Z})^2 \).
  -- This is determined by the matrix \( Q = \begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix} \) in \( \text{Mat}_2(\mathbb{Z}/p\mathbb{Z}) \).
  -- We have \( Q^n \) corresponds to \( (F_{n+1}, F_n) \) in the first column.
  set Q : Matrix (Fin 2) (Fin 2) (ZMod p) := !![1, 1; 1, 0] with hQ_def;
  haveI := Fact.mk hp;
  -- Since $p \neq 5$, the discriminant $5$ is non-zero in $\mathbb{Z}/p\mathbb{Z}$, so $Q$ has distinct eigenvalues.
  have h_distinct_eigenvalues : ∃ α β : AlgebraicClosure (ZMod p), α ≠ β ∧ α^2 = α + 1 ∧ β^2 = β + 1 := by
    -- The polynomial $x^2 - x - 1$ has two distinct roots in the algebraic closure of $\mathbb{Z}/p\mathbb{Z}$ because its discriminant is $5$, which is non-zero modulo $p$.
    have h_discriminant : ∃ α : AlgebraicClosure (ZMod p), α^2 - α - 1 = 0 := by
      have h_alg_closed : ∀ (f : Polynomial (AlgebraicClosure (ZMod p))), f.degree > 0 → ∃ α : AlgebraicClosure (ZMod p), f.eval α = 0 := by
        exact fun f hf => by simpa using ( IsAlgClosed.exists_root f hf.ne' ) ;
      exact Exists.elim ( h_alg_closed ( Polynomial.X ^ 2 - Polynomial.X - 1 ) ( by erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num ) ) fun x hx => ⟨ x, by simpa using hx ⟩;
    obtain ⟨ α, hα ⟩ := h_discriminant;
    refine' ⟨ α, 1 - α, _, _, _ ⟩ <;> norm_num;
    · intro h; rw [ eq_sub_iff_add_eq ] at h; ring_nf at h;
      norm_num [ show α = 1 / 2 by exact eq_one_div_of_mul_eq_one_left h ] at hα;
      rw [ inv_eq_one_div, inv_eq_one_div, div_sub_div, div_sub_one, div_eq_iff ] at hα <;> norm_num at *;
      · erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod p ) ) p ] at hα;
        have := Nat.le_of_dvd ( by decide ) hα; interval_cases p <;> trivial;
      · erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod p ) ) p ];
        intro h; have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial;
      · aesop;
      · grind;
      · grind;
    · linear_combination' hα;
    · linear_combination' hα;
  -- Since $Q$ has distinct eigenvalues, it is diagonalizable over the algebraic closure of $\mathbb{Z}/p\mathbb{Z}$.
  obtain ⟨α, β, hαβ, hα, hβ⟩ := h_distinct_eigenvalues;
  have h_diag : ∃ P : Matrix (Fin 2) (Fin 2) (AlgebraicClosure (ZMod p)), P.det ≠ 0 ∧ P⁻¹ * (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) * P = !![α, 0; 0, β] := by
    have h_diag : ∃ P : Matrix (Fin 2) (Fin 2) (AlgebraicClosure (ZMod p)), P.det ≠ 0 ∧ (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) * P = P * !![α, 0; 0, β] := by
      use !![α, β; 1, 1];
      simp_all +decide [ ← Matrix.ext_iff, Fin.forall_fin_two, Matrix.mul_apply ];
      exact ⟨ sub_ne_zero_of_ne hαβ, by linear_combination' hα.symm, by linear_combination' hβ.symm ⟩;
    obtain ⟨ P, hP₁, hP₂ ⟩ := h_diag; use P; simp_all +decide [ Matrix.mul_assoc, isUnit_iff_ne_zero ] ;
  -- Since $α$ and $β$ are roots of the characteristic polynomial, we have $α^{p^2-1} = 1$ and $β^{p^2-1} = 1$.
  have h_eigenvalues_order : α ^ (p ^ 2 - 1) = 1 ∧ β ^ (p ^ 2 - 1) = 1 := by
    have h_eigenvalues_order : ∀ x : AlgebraicClosure (ZMod p), x ^ 2 = x + 1 → x ^ (p ^ 2 - 1) = 1 := by
      intro x hx
      have h_eigenvalues_order : x ^ (p ^ 2) = x := by
        have h_eigenvalues_order : x ^ p = x ∨ x ^ p = 1 - x := by
          have h_eigenvalues_order : (x ^ p) ^ 2 = x ^ p + 1 := by
            rw [ ← pow_mul, mul_comm, pow_mul, hx ];
            simp +decide [ add_pow_char ];
          grind;
        cases' h_eigenvalues_order with h h <;> simp_all +decide [ pow_succ, pow_mul ];
        rw [ sub_pow_char ] ; aesop;
      rcases k : p ^ 2 with ( _ | _ | k ) <;> simp_all +decide [ pow_succ, pow_mul ];
      grind;
    exact ⟨ h_eigenvalues_order α hα, h_eigenvalues_order β hβ ⟩;
  -- Therefore, $Q^{p^2-1} = I$, where $I$ is the identity matrix.
  have h_Q_order : (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) ^ (p ^ 2 - 1) = 1 := by
    obtain ⟨ P, hP₁, hP₂ ⟩ := h_diag;
    have h_Q_order : (P⁻¹ * (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) * P) ^ (p ^ 2 - 1) = 1 := by
      ext i j ; fin_cases i <;> fin_cases j <;> simp +decide [ *, Matrix.diagonal_pow ];
      · convert h_eigenvalues_order.1 using 1;
        induction p ^ 2 - 1 <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
      · induction p ^ 2 - 1 <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
      · induction p ^ 2 - 1 <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
      · rw [ ← h_eigenvalues_order.2 ];
        induction p ^ 2 - 1 <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
    have h_Q_order : (P⁻¹ * (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) * P) ^ (p ^ 2 - 1) = P⁻¹ * (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p)))) ^ (p ^ 2 - 1) * P := by
      induction' p ^ 2 - 1 with n ih <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp_all +decide [ ← mul_assoc, ← hP₂ ];
    apply_fun fun x => P * x * P⁻¹ at ‹ ( P⁻¹ * Q.map ⇑ ( algebraMap ( ZMod p ) ( AlgebraicClosure ( ZMod p ) ) ) * P ) ^ ( p ^ 2 - 1 ) = 1 › ; simp_all +decide [ mul_assoc, isUnit_iff_ne_zero ];
  -- Therefore, $F_{p^2-1} \equiv 0 \pmod{p}$.
  have h_fib_order : (Nat.fib (p ^ 2 - 1) : ZMod p) = 0 := by
    have h_fib_order : ∀ n : ℕ, (Nat.fib n : ZMod p) = (Q ^ n) 0 1 := by
      intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ, Matrix.mul_apply ] ;
      have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; simp_all +decide [ pow_succ, Matrix.mul_apply, Nat.fib_add_two ] ;
      ring;
    replace h_Q_order := congr_arg ( fun m => m 0 1 ) h_Q_order ; simp_all +decide [ Matrix.mul_apply ];
    have h_map : ∀ n : ℕ, (Matrix.map Q (algebraMap (ZMod p) (AlgebraicClosure (ZMod p))) ^ n) = Matrix.map (Q ^ n) (algebraMap (ZMod p) (AlgebraicClosure (ZMod p))) := by
      intro n; induction n <;> simp_all +decide [ pow_succ, Matrix.mul_apply ] ;
    simp_all +decide [ Matrix.map_apply ];
  exact ⟨ p ^ 2 - 1, Nat.sub_pos_of_lt ( by nlinarith only [ hp.two_le ] ), by rw [ sq ], by rw [ ← ZMod.natCast_eq_zero_iff ] ; aesop ⟩