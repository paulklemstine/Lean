/-! # CatalogBuild.Bridges.NumberTheoryBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15
-/

import Mathlib

/-- **Fermat's Little Theorem**: For prime p, a^(p-1) = 1 in ZMod p for any unit a.
Cornerstone of computational number theory and public-key cryptography. -/
theorem fermat_little (p : ℕ) [Fact (Nat.Prime p)] (a : (ZMod p)ˣ) :
    a ^ (p - 1) = 1 :=
  ZMod.units_pow_card_sub_one_eq_one p a


/-- **Wilson's Theorem**: For prime p, (p-1)! ≡ -1 (mod p).
Wilson's theorem provides an if-and-only-if primality test:
n is prime iff (n-1)! ≡ -1 (mod n). -/
theorem wilsons_theorem (p : ℕ) [Fact (Nat.Prime p)] :
    ((p - 1).factorial : ZMod p) = -1 :=
  ZMod.wilsons_lemma p


/-- **Euler's totient of a prime**: φ(p) = p - 1. -/
theorem totient_prime {p : ℕ} (hp : Nat.Prime p) :
    Nat.totient p = p - 1 :=
  Nat.totient_prime hp


/-- Euler's totient is positive for positive n. -/
theorem totient_pos {n : ℕ} (hn : 0 < n) :
    0 < Nat.totient n :=
  Nat.totient_pos.mpr hn


/-- Totient of 1 is 1. -/
theorem totient_one : Nat.totient 1 = 1 := by native_decide


/-- For any n > 0, φ(n) ≤ n. -/
theorem totient_le (n : ℕ) : Nat.totient n ≤ n :=
  Nat.totient_le n


/-- **Chinese Remainder Theorem**: For coprime m, n, and any a, b,
there exists k with k ≡ a (mod n) and k ≡ b (mod m).
Fundamental for solving simultaneous congruences. -/
theorem chinese_remainder_exists {m n : ℕ} (hmn : n.Coprime m) (a b : ℕ) :
    ∃ k, k ≡ a [MOD n] ∧ k ≡ b [MOD m] :=
  let ⟨k, hk⟩ := Nat.chineseRemainder hmn a b
  ⟨k, hk.1, hk.2⟩


/-- Multiplication preserves congruence. -/
theorem mod_mul {n a b c d : ℕ} (hab : a ≡ b [MOD n]) (hcd : c ≡ d [MOD n]) :
    a * c ≡ b * d [MOD n] :=
  Nat.ModEq.mul hab hcd


/-- Exponentiation preserves congruence. -/
theorem mod_pow {n a b : ℕ} (hab : a ≡ b [MOD n]) (m : ℕ) :
    a ^ m ≡ b ^ m [MOD n] :=
  Nat.ModEq.pow m hab


/-- Congruence is reflexive. -/
theorem mod_refl (n a : ℕ) : a ≡ a [MOD n] := Nat.ModEq.refl a


/-- Congruence is transitive. -/
theorem mod_trans {n a b c : ℕ} (hab : a ≡ b [MOD n]) (hbc : b ≡ c [MOD n]) :
    a ≡ c [MOD n] := Nat.ModEq.trans hab hbc


/-- Congruence is symmetric. -/
theorem mod_symm {n a b : ℕ} (hab : a ≡ b [MOD n]) :
    b ≡ a [MOD n] := Nat.ModEq.symm hab


/-- Every prime p > 2 is odd. -/
theorem prime_eq_two_or_odd {p : ℕ} (hp : Nat.Prime p) :
    p = 2 ∨ p % 2 = 1 :=
  Nat.Prime.eq_two_or_odd hp


/-- A prime does not divide 1. -/
theorem prime_not_dvd_one {p : ℕ} (hp : Nat.Prime p) :
    ¬(p ∣ 1) :=
  Nat.Prime.not_dvd_one hp


/-- The minimum factor of a positive natural number is positive. -/
theorem minFac_pos {n : ℕ} (_hn : 0 < n) : 0 < n.minFac :=
  Nat.minFac_pos n

