import Mathlib

/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonParity

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 4
-/

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonParity
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 4] -/
theorem pyth_not_both_odd (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : ¬ 2 ∣ a) (hb : ¬ 2 ∣ b) : False := by
  simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
  exact absurd ( congr_arg ( · % 4 ) h ) ( by obtain ⟨ k, rfl ⟩ := ha; obtain ⟨ l, rfl ⟩ := hb; rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf <;> norm_num )

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonParity
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 4] -/
theorem pyth_hypotenuse_odd (a b c : ℕ) (h : a^2 + b^2 = c^2)
    (hcop : Nat.Coprime a b) : ¬ 2 ∣ c := by
  contrapose! hcop; have := congr_arg ( · % 4 ) h; rcases Nat.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
  · norm_num [ Nat.gcd_mul_right, Nat.gcd_mul_left ];
  · grind +ring;
  · grind +ring

theorem pyth_one_leg_even (a b c : ℕ) (h : a^2 + b^2 = c^2)
    (hcop : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (2 ∣ a ∧ ¬ 2 ∣ b) ∨ (¬ 2 ∣ a ∧ 2 ∣ b) := by
  by_cases ha : 2 ∣ a <;> by_cases hb : 2 ∣ b <;> simp_all +decide [ Nat.dvd_iff_mod_eq_zero ];
  · have := Nat.dvd_gcd ( Nat.dvd_of_mod_eq_zero ha ) ( Nat.dvd_of_mod_eq_zero hb ) ; aesop;
  · exact absurd ( congr_arg ( · % 4 ) h ) ( by rw [ ← Nat.mod_add_div a 2, ← Nat.mod_add_div b 2, ha, hb ] ; ring_nf; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt c zero_lt_four ; interval_cases c % 4 <;> trivial )

theorem pyth_parametrization (m n : ℤ) :
    (m^2 - n^2)^2 + (2*m*n)^2 = (m^2 + n^2)^2 := by
  ring

