/-! # CatalogBuild.GravitationalFactoringResearch.MillerRabinFoundations

Auto-generated from theorem catalog database.
Domain: GravitationalFactoringResearch
Declarations: 8
-/

import Mathlib

theorem odd_decomp (n : ℕ) (hn : 2 < n) (hodd : ¬ 2 ∣ n) :
    ∃ s d : ℕ, 0 < s ∧ ¬ 2 ∣ d ∧ n - 1 = 2 ^ s * d := by
  -- Let $s$ be the 2-adic valuation of $n-1$, i.e., $s = \text{padicValNat } 2 (n-1)$.
  set s := padicValNat 2 (n - 1) with hs;
  refine' ⟨ s, ( n - 1 ) / 2 ^ s, _, _, Eq.symm ( Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ) ⟩;
  · contrapose! hodd; rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ ← even_iff_two_dvd, parity_simps ] ;
  · rw [ Nat.Prime.dvd_iff_one_le_factorization ] <;> norm_num;
    · rw [ Nat.factorization_div ] <;> norm_num;
      · exact Nat.sub_eq_zero_of_le ( Nat.le_refl _ );
      · exact Nat.ordProj_dvd _ _;
    · exact Nat.le_of_dvd ( Nat.sub_pos_of_lt ( by linarith ) ) ( Nat.ordProj_dvd _ _ )


/-- A base a is a Miller-Rabin witness for n if the MR test detects compositeness. -/
def IsMillerRabinWitness (a n : ℕ) (s d : ℕ) : Prop :=
  n - 1 = 2 ^ s * d ∧
  a ^ d % n ≠ 1 ∧
  ∀ r : ℕ, r < s → a ^ (2 ^ r * d) % n ≠ n - 1


/-- A strong pseudoprime to base a passes the MR test despite being composite. -/
def IsStrongPseudoprime (n a : ℕ) : Prop :=
  ¬ Nat.Prime n ∧ 1 < n ∧
  ∃ s d : ℕ, n - 1 = 2 ^ s * d ∧ ¬ 2 ∣ d ∧
    (a ^ d % n = 1 ∨ ∃ r : ℕ, r < s ∧ a ^ (2 ^ r * d) % n = n - 1)


theorem prime_passes_miller_rabin (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (a : ℕ) (ha : 0 < a) (hap : a < p) :
    ∃ s d : ℕ, p - 1 = 2 ^ s * d ∧ ¬ 2 ∣ d ∧
      (a ^ d % p = 1 ∨ ∃ r : ℕ, r < s ∧ a ^ (2 ^ r * d) % p = p - 1) := by
  -- Use odd_decomp to get s, d with p-1 = 2^s * d.
  obtain ⟨s, d, hs, hd⟩ : ∃ s d, p - 1 = 2 ^ s * d ∧ ¬ 2 ∣ d := by
    exact ⟨ Nat.factorization ( p - 1 ) 2, ( p - 1 ) / 2 ^ Nat.factorization ( p - 1 ) 2, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by norm_num ) ( by cases p <;> aesop ) ⟩;
  -- By Fermat's Little Theorem, we know that $a^{p-1} \equiv 1 \pmod{p}$.
  have h_fermat : a ^ (p - 1) ≡ 1 [MOD p] := by
    exact Nat.totient_prime hp ▸ Nat.ModEq.pow_totient ( Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt ha hap );
  -- Consider the sequence $a^d, a^{2d}, a^{4d}, \ldots, a^{2^s d}$. The last term is $1 \mod p$.
  have h_seq : ∃ r ≤ s, a ^ (2 ^ r * d) ≡ 1 [MOD p] ∧ ∀ r' < r, ¬(a ^ (2 ^ r' * d) ≡ 1 [MOD p]) := by
    have h_seq : ∃ r ≤ s, a ^ (2 ^ r * d) ≡ 1 [MOD p] := by
      exact ⟨ s, le_rfl, by simpa [ hs ] using h_fermat ⟩;
    exact ⟨ Nat.find h_seq, Nat.find_spec h_seq |>.1, Nat.find_spec h_seq |>.2, fun r' hr' hr'' => Nat.find_min h_seq hr' ⟨ Nat.le_trans ( Nat.le_of_lt hr' ) ( Nat.find_spec h_seq |>.1 ), hr'' ⟩ ⟩;
  obtain ⟨ r, hr₁, hr₂, hr₃ ⟩ := h_seq;
  by_cases hr : r = 0;
  · exact ⟨ s, d, hs, hd, Or.inl <| by simpa [ hr, Nat.ModEq, Nat.mod_eq_of_lt hp.two_le ] using hr₂ ⟩;
  · -- Since $r \neq 0$, we have $a^{2^{r-1} d} \equiv -1 \pmod{p}$.
    have h_neg_one : a ^ (2 ^ (r - 1) * d) ≡ p - 1 [MOD p] := by
      haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_natCast_iff, pow_succ, mul_assoc ] ;
      rcases r <;> simp_all +decide [ pow_succ', mul_assoc ];
      simp_all +decide [ pow_mul', ← ZMod.natCast_eq_zero_iff ];
      norm_cast; rw [ ← hs ] ;
      norm_num [ hp.pos ];
    exact ⟨ s, d, hs, hd, Or.inr ⟨ r - 1, Nat.lt_of_lt_of_le ( Nat.pred_lt hr ) hr₁, h_neg_one.symm ▸ Nat.mod_eq_of_lt ( Nat.sub_lt hp.pos zero_lt_one ) ⟩ ⟩


/-- 341 = 11 × 31 is the smallest Fermat pseudoprime to base 2. -/
theorem fermat_pseudoprime_341 :
    ¬ Nat.Prime 341 ∧ 2 ^ 340 % 341 = 1 := by
  constructor
  · native_decide
  · native_decide


/-- 2047 is a strong pseudoprime to base 2 (the smallest one). -/
theorem strong_pseudoprime_2047_base2 :
    ¬ Nat.Prime 2047 ∧ (2 : ℕ) ^ 1023 % 2047 = 1 := by
  constructor
  · native_decide
  · native_decide


theorem carmichael_561 :
    ¬ Nat.Prime 561 ∧
    (∀ a : ℕ, Nat.Coprime a 561 → a ^ 560 % 561 = 1) := by
  norm_num;
  intro a ha; rw [ Nat.pow_mod ] ; rw [ Nat.Coprime, Nat.gcd_comm ] at ha; rw [ Nat.gcd_rec ] at ha; have := Nat.mod_lt a ( by decide : 561 > 0 ) ; interval_cases a % 561 <;> trivial;


/-- Carmichael numbers are not strong pseudoprimes to ALL bases.
For 561, base 7 is a Miller-Rabin witness. -/
theorem carmichael_561_witness :
    (7 : ℕ) ^ 280 % 561 ≠ 1 ∧ (7 : ℕ) ^ 280 % 561 ≠ 560 := by
  constructor <;> native_decide
