/-! # CatalogBuild.Speculative.TropicalFactoring

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7
-/

import Mathlib

theorem padic_val_mul' (p : ℕ) [Fact p.Prime] {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b :=
  padicValNat.mul ha hb


theorem semiprime_valuation {p q ℓ : ℕ} [hℓf : Fact ℓ.Prime]
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hℓp : ℓ ≠ p) (hℓq : ℓ ≠ q) :
    padicValNat ℓ (p * q) = 0 := by
  simp_all +decide [ padicValNat.mul, hp.ne_zero, hq.ne_zero ];
  exact ⟨ Or.inr fun h => hℓp <| by have := Nat.prime_dvd_prime_iff_eq hℓf.1 hp; tauto, Or.inr fun h => hℓq <| by have := Nat.prime_dvd_prime_iff_eq hℓf.1 hq; tauto ⟩


theorem semiprime_self_valuation {p q : ℕ} [hpf : Fact p.Prime]
    (hq : Nat.Prime q) (hpq : p ≠ q) :
    padicValNat p (p * q) = 1 := by
  rw [ padicValNat.mul ] <;> simp_all +decide [ Nat.Prime.ne_zero ];
  · exact Or.inr ( by rw [ Nat.prime_dvd_prime_iff_eq hpf.1 hq ] ; tauto );
  · exact hpf.1.ne_zero


theorem tropical_factoring_constraint (ℓ : ℕ) [Fact ℓ.Prime] {p q : ℕ}
    (hp : p ≠ 0) (hq : q ≠ 0) :
    padicValNat ℓ (p * q) = padicValNat ℓ p + padicValNat ℓ q :=
  padicValNat.mul hp hq


theorem smooth_iff_tropical {n B : ℕ} (hn : n ≠ 0) :
    (∀ p : ℕ, Nat.Prime p → p ∣ n → p ≤ B) ↔
    (∀ p : ℕ, Nat.Prime p → B < p → padicValNat p n = 0) := by
  constructor;
  · exact fun h p hp hpn => padicValNat.eq_zero_of_not_dvd fun hpn' => hpn.not_ge <| h p hp hpn';
  · intro h p hp hdvd; contrapose! h;
    use p;
    rw [ Ne.eq_def, padicValNat.eq_zero_iff ] ; aesop


theorem square_even_valuation {N : ℕ} (hN : N ≠ 0) {m : ℕ} (hm : N = m ^ 2)
    (p : ℕ) [Fact p.Prime] : Even (padicValNat p N) := by
  rw [ hm, padicValNat.pow ] <;> simp_all +decide [ parity_simps ]


theorem odd_valuation_not_square {N : ℕ} (hN : N ≠ 0) (p : ℕ) [Fact p.Prime]
    (hodd : ¬Even (padicValNat p N)) :
    ¬∃ m : ℕ, N = m ^ 2 :=
  fun ⟨m, hm⟩ => hodd (square_even_valuation hN hm p)

