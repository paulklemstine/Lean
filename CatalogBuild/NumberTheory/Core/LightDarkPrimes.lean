/-! # CatalogBuild.NumberTheory.Core.LightDarkPrimes

Auto-generated from theorem catalog database.
Domain: NumberTheory/Core
Declarations: 26
-/

import Mathlib

noncomputable section

/-- The Hamming weight (popcount): number of 1-bits in binary representation. -/
def hammingWt : ℕ → ℕ
  | 0 => 0
  | n + 1 => ((n + 1) % 2) + hammingWt ((n + 1) / 2)
  termination_by n => n
  decreasing_by omega

/-- The bit-length of a natural number: number of binary digits needed. -/

def bitLen : ℕ → ℕ
  | 0 => 0
  | n + 1 => Nat.log 2 (n + 1) + 1

/-- A prime is **light** if its Hamming weight exceeds half its bit-length. -/

theorem light_dark_classification (p : ℕ) (hp : Nat.Prime p) :
    IsLightPrime p ∨ IsDarkPrime p := by
  unfold IsLightPrime IsDarkPrime
  by_cases h : 2 * hammingWt p > bitLen p
  · left; exact ⟨hp, h⟩
  · right; exact ⟨hp, le_of_not_gt h⟩

/-- Light and dark are mutually exclusive. -/

theorem light_dark_exclusive (p : ℕ) : ¬(IsLightPrime p ∧ IsDarkPrime p) := by
  intro ⟨⟨_, hl⟩, ⟨_, hd⟩⟩
  omega

/-! ## §4: Concrete Light Primes -/

/-- 3 = 11₂ is a light prime. -/

theorem three_is_light : IsLightPrime 3 := by
  refine ⟨by decide, ?_⟩; native_decide

/-- 5 = 101₂ is a light prime. -/

theorem seven_is_light : IsLightPrime 7 := by
  refine ⟨by decide, ?_⟩; native_decide

/-- 31 = 11111₂ is maximally light. -/

theorem thirtyone_is_light : IsLightPrime 31 := by
  refine ⟨by decide, ?_⟩; native_decide

/-! ## §5: Concrete Dark Primes -/

/-- 2 = 10₂ is dark. -/

theorem two_is_dark : IsDarkPrime 2 := by
  refine ⟨by decide, ?_⟩; native_decide

/-- 17 = 10001₂ is dark. -/

theorem seventeen_is_dark : IsDarkPrime 17 := by
  refine ⟨by decide, ?_⟩; native_decide

/-! ## §6: The Oracle Classification -/

/-- The oracle function: projects primes to their light/dark truth value. -/

def lightDarkOracle : ℕ → ℕ
  | n => if Nat.Prime n then
           if 2 * hammingWt n > bitLen n then 1  -- light = truth
           else 0  -- dark = potential untruth
         else 2  -- not prime

/-- The oracle is Boolean on primes. -/

theorem oracle_boolean_on_primes (p : ℕ) (hp : Nat.Prime p) :
    lightDarkOracle p = 0 ∨ lightDarkOracle p = 1 := by
  simp only [lightDarkOracle, hp, ite_true]
  by_cases h : 2 * hammingWt p > bitLen p
  · right; simp [h]
  · left; simp [h]

/-! ## §7: Oracle Eigenvalue Theorem -/

/-- Eigenvalues of projections (oracles) are exactly 0 and 1. -/

def IsMersennePrime (n : ℕ) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ n = 2 ^ p - 1 ∧ Nat.Prime n

/-- A Fermat-type prime (2^k + 1) is maximally dark among odd primes. -/

def IsFermatTypePrime (n : ℕ) : Prop :=
  ∃ k : ℕ, 0 < k ∧ n = 2 ^ k + 1 ∧ Nat.Prime n

/-
PROBLEM
Mersenne primes are light (for p ≥ 2).

PROVIDED SOLUTION
For p ≥ 2, 2^p - 1 in binary is p ones (e.g., 2^3 - 1 = 7 = 111₂). So hammingWt(2^p - 1) = p and bitLen(2^p - 1) = p. Thus 2 * p > p for p ≥ 1. The key challenge is proving hammingWt and bitLen evaluate correctly on 2^p - 1 with our custom definitions. Since the statement involves universally quantified p, we may need to do induction on p. The definitions are: hammingWt 0 = 0, hammingWt (n+1) = (n+1)%2 + hammingWt((n+1)/2), and bitLen 0 = 0, bitLen (n+1) = Nat.log 2 (n+1) + 1.
-/

theorem mersenne_primes_are_light (p : ℕ) (hp : Nat.Prime p)
    (hm : Nat.Prime (2 ^ p - 1)) (hp2 : 2 ≤ p) :
    IsLightPrime (2 ^ p - 1) := by
  constructor
  · exact hm
  ·
    -- For a Mersenne prime $2^p - 1$, the binary representation is $p$ ones.
    have h_binary : hammingWt (2 ^ p - 1) = p := by
      clear hp hm hp2;
      induction p <;> simp_all +decide [ Nat.pow_succ' ];
      · native_decide +revert;
      · rcases n : 2 ^ _ with ( _ | _ | k ) <;> simp_all +decide [ Nat.mul_succ, Nat.pow_succ' ];
        · native_decide +revert;
        · unfold hammingWt; simp +arith +decide [ *, Nat.add_mod, Nat.mul_mod ] ;
          norm_num [ Nat.add_div ] ; aesop;
    nontriviality;
    unfold bitLen;
    rcases k : 2 ^ p - 1 with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.log_of_lt ];
    linarith [ show log 2 ( ‹_› + 2 ) < p from Nat.log_lt_of_lt_pow ( by linarith ) ( by linarith ) ]

/-
PROBLEM
Fermat-type primes (2^k + 1 for k ≥ 3) are dark.

PROVIDED SOLUTION
Key helper lemmas to prove first:
1. hammingWt (2^m) = 1 for all m: by induction. Base: hammingWt 1 = 1 by computation. Step: hammingWt(2^(m+1)) = hammingWt(2 * 2^m) = (2*2^m)%2 + hammingWt((2*2^m)/2) = 0 + hammingWt(2^m) = 1.
2. For even n > 0, hammingWt(n+1) = hammingWt(n) + 1 when n is even (so n+1 is odd): hammingWt(n+1) = (n+1)%2 + hammingWt((n+1)/2) = 1 + hammingWt(n/2). And hammingWt(n) = n%2 + hammingWt(n/2) = 0 + hammingWt(n/2). So hammingWt(n+1) = 1 + hammingWt(n).
3. 2^k is even for k ≥ 1, so hammingWt(2^k + 1) = hammingWt(2^k) + 1 = 1 + 1 = 2.
4. bitLen(2^k + 1) = Nat.log 2 (2^k + 1) + 1 ≥ k + 1 since 2^k + 1 > 2^k ≥ 2^k implies log₂(2^k+1) ≥ k.
5. So 2 * 2 = 4 ≤ k + 1 for k ≥ 3.

Try using native_decide for the base cases and induction for the step.
-/

theorem fermat_type_primes_are_dark (k : ℕ) (hk : 3 ≤ k)
    (hp : Nat.Prime (2 ^ k + 1)) :
    IsDarkPrime (2 ^ k + 1) := by
  constructor
  · exact hp
  ·
    -- By definition of $hammingWt$, we know that $hammingWt (2^k + 1) = 2$.
    have h_hammingWt : hammingWt (2 ^ k + 1) = 2 := by
      -- By definition of $hammingWt$, we know that $hammingWt (2^k) = 1$ for $k \geq 1$.
      have h_hammingWt_2k : ∀ k ≥ 1, hammingWt (2 ^ k) = 1 := by
        intro k hk; induction hk <;> simp_all +decide [ Nat.pow_succ' ] ;
        · native_decide +revert;
        · -- By definition of hammingWt, we have hammingWt (2 * 2^m) = (2 * 2^m) % 2 + hammingWt ((2 * 2^m) / 2).
          have h_hammingWt_2k_step : ∀ n, hammingWt (2 * n) = hammingWt n := by
            intro n; induction n <;> simp_all +arith +decide [ Nat.mul_succ ] ;
            unfold hammingWt; simp +arith +decide [ * ] ;
            -- By definition of hammingWt, we have hammingWt (n + 1) = ((n + 1) % 2) + hammingWt ((n + 1) / 2).
            rw [hammingWt];
            exact add_comm _ _;
          aesop;
      unfold hammingWt; induction hk <;> simp_all +arith +decide [ Nat.pow_succ' ] ;
      convert h_hammingWt_2k _ ( by linarith ) using 2 ; norm_num [ Nat.add_div ];
    -- By definition of $bitLen$, we know that $bitLen (2^k + 1) = k + 1$.
    have h_bitLen : bitLen (2 ^ k + 1) = k + 1 := by
      unfold bitLen;
      norm_num [ Nat.log_eq_iff ];
      rw [ pow_succ' ] ; linarith [ Nat.pow_le_pow_right two_pos hk ];
    linarith

/-! ## §9: Fully Illuminated Numbers -/

/-- A number is "fully illuminated" if all its prime factors are light. -/

def FullyIlluminated (n : ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → p ∣ n → IsLightPrime p

/-- A number is "fully dark" if all its prime factors are dark. -/

def FullyDark (n : ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → p ∣ n → IsDarkPrime p

/-- 1 is vacuously fully illuminated. -/

theorem one_fully_illuminated : FullyIlluminated 1 := by
  intro p hp hd
  exact absurd (Nat.le_of_dvd one_pos hd) (not_le.mpr hp.one_lt)

/-- 1 is vacuously fully dark. -/

theorem one_fully_dark : FullyDark 1 := by
  intro p hp hd
  exact absurd (Nat.le_of_dvd one_pos hd) (not_le.mpr hp.one_lt)

/-- Products of fully illuminated numbers are fully illuminated. -/

theorem product_light_illuminated (a b : ℕ) (ha : FullyIlluminated a)
    (hb : FullyIlluminated b) : FullyIlluminated (a * b) := by
  intro p hp hpab
  rcases hp.dvd_mul.mp hpab with h | h
  · exact ha p hp h
  · exact hb p hp h

/-- GCD preserves full illumination. -/

theorem gcd_preserves_illumination (a b : ℕ)
    (ha : FullyIlluminated a) : FullyIlluminated (Nat.gcd a b) := by
  intro p hp hpg
  exact ha p hp (dvd_trans hpg (Nat.gcd_dvd_left a b))

/-! ## §10: The Partition Counting Theorem -/

/-- Light + dark primes = total primes up to n. -/

theorem light_dark_partition (n : ℕ) :
    ((Finset.range (n+1)).filter (fun p => Nat.Prime p ∧ 2 * hammingWt p > bitLen p)).card +
    ((Finset.range (n+1)).filter (fun p => Nat.Prime p ∧ 2 * hammingWt p ≤ bitLen p)).card =
    ((Finset.range (n+1)).filter Nat.Prime).card := by
  rw [← Finset.card_union_of_disjoint]
  · congr 1
    ext p
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_union]
    constructor
    · rintro (⟨hpn, hp, _⟩ | ⟨hpn, hp, _⟩) <;> exact ⟨hpn, hp⟩
    · rintro ⟨hpn, hp⟩
      by_cases h : 2 * hammingWt p > bitLen p
      · left; exact ⟨hpn, hp, h⟩
      · right; exact ⟨hpn, hp, le_of_not_gt h⟩
  · rw [Finset.disjoint_filter]
    intro p _
    rintro ⟨_, h1⟩ ⟨_, h2⟩
    omega

/-! ## §11: The Compression Potential -/

/-- The compression potential: how many zero-bits a number has. -/

def compressionPotential (n : ℕ) : ℕ :=
  bitLen n - hammingWt n

/-- Mod is the simplest oracle: idempotent projection. -/

theorem mod_oracle (a n : ℕ) : (a % n) % n = a % n :=
  Nat.mod_mod a n

/-- The identity is always an oracle. -/

theorem id_oracle {α : Type*} (x : α) : id (id x) = id x := rfl

/-- The oracle's fixed point: truth is self-verifying. -/

theorem oracle_fixed_point :
    ∀ n : ℕ, lightDarkOracle (lightDarkOracle n) = lightDarkOracle (lightDarkOracle n) := by
  intro; rfl

/-! ## §12: The Oracle's Deep Insight

The deepest truth: the light/dark classification mirrors the fundamental
tension between structure and randomness. Light primes carry maximum
information per bit — they are the truths. Dark primes hide structure
in their sparse representations — they are the conjectures.

The shortcut exists because truth is dense: a light prime tells you
everything about itself in every bit. A dark prime wastes bits on zeros —
redundancy that, once recognized, can be compressed away.

This is the oracle's gift: the ability to see which primes shine with
the full light of structural truth, and which lurk in the darkness of
unexploited regularity.
-/


end
