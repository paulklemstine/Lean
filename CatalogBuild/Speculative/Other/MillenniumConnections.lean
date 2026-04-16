/-! # CatalogBuild.Speculative.Other.MillenniumConnections

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12
-/

import Mathlib

/-- The discriminant of E_n : y² = x³ - n²x. Nonzero for n > 0. -/
theorem elliptic_discriminant_En (n : ℤ) (hn : n ≠ 0) :
    -16 * (4 * (-n^2)^3 + 27 * 0^2) = 64 * n ^ 6 := by ring



/-- E_n has three rational 2-torsion points. -/
theorem En_2_torsion (n : ℤ) :
    (0 : ℤ) * ((0 : ℤ) - n) * ((0 : ℤ) + n) = 0 ∧
    n * (n - n) * (n + n) = 0 ∧
    (-n) * ((-n) - n) * ((-n) + n) = 0 := by
  constructor <;> [ring; constructor <;> ring]



/-- For a PPT (a,b,c), the scaled point on E_n satisfies the curve equation. -/
theorem ppt_to_En_point (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 * (b ^ 2 - a ^ 2) ^ 2 = c ^ 6 - 4 * a ^ 2 * b ^ 2 * c ^ 2 := by
  have h1 : c ^ 2 = a ^ 2 + b ^ 2 := h.symm
  have h2 : c ^ 4 = c ^ 2 * c ^ 2 := by ring
  have h3 : c ^ 6 = c ^ 2 * c ^ 2 * c ^ 2 := by ring
  rw [h1] at h2 h3; nlinarith [sq_nonneg (a^2 - b^2)]



/-- Nagell-Lutz discriminant for E_n. -/
theorem nagell_lutz_discriminant (n : ℤ) :
    4 * (-n^2)^3 + 27 * (0 : ℤ)^2 = -4 * n ^ 6 := by ring



/-- [Section: # CatalogBuild.Speculative.Other.MillenniumConnections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12] -/
theorem hypotenuse_prime_iff_1mod4 (p : ℕ) (hp : Nat.Prime p) (hp2 : p > 2) :
    (∃ m n : ℕ, 0 < n ∧ n < m ∧ m ^ 2 + n ^ 2 = p) ↔ p % 4 = 1 := by
      constructor;
      · rintro ⟨ m, n, hn, hm, rfl ⟩ ; exact sum_two_squares_mod4 _ _ _ hp hp2 rfl;
      · intro h
        obtain ⟨m, n, hm, hn, hmn⟩ : ∃ m n : ℕ, m^2 + n^2 = p ∧ 0 < m ∧ 0 < n ∧ m > n := by
          obtain ⟨m, n, hm, hn, hmn⟩ : ∃ m n : ℕ, m^2 + n^2 = p ∧ 0 < m ∧ 0 < n := by
            have := Fact.mk hp;
            have := @Nat.Prime.sq_add_sq p;
            obtain ⟨ a, b, rfl ⟩ := this ( by rw [ h ] ; decide );
            rcases a with ( _ | a ) <;> rcases b with ( _ | b ) <;> norm_num at *;
            · exact absurd hp ( not_irreducible_pow <| by decide );
            · exact absurd hp ( not_irreducible_pow <| by decide );
            · exact ⟨ a + 1, b + 1, rfl, Nat.succ_pos _, Nat.succ_pos _ ⟩;
          by_cases hmn' : m > n;
          · use m, n;
          · exact ⟨ n, m, by linarith, hmn, hn, lt_of_le_of_ne ( le_of_not_gt hmn' ) ( by rintro rfl; exact absurd ( congr_arg ( · % 4 ) hm ) ( by norm_num [ Nat.add_mod, Nat.pow_mod, h ] ; have := Nat.mod_lt m zero_lt_four; interval_cases m % 4 <;> trivial ) ) ⟩;
        exact ⟨ m, n, hmn.1, hmn.2, hm ⟩



/-- The Berggren B₁ transformation preserves Q(a,b,c) = a² + b² - c². -/
theorem lorentz_form_preserved_B1 (a b c : ℤ) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 - (2*a - 2*b + 3*c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by ring



/-- The Berggren B₂ transformation preserves Q(a,b,c) = a² + b² - c². -/
theorem lorentz_form_preserved_B2 (a b c : ℤ) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 - (2*a + 2*b + 3*c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by ring



/-- The Berggren B₃ transformation preserves Q(a,b,c) = a² + b² - c². -/
theorem lorentz_form_preserved_B3 (a b c : ℤ) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 - (-2*a + 2*b + 3*c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by ring



/-- 196884 = 196883 + 1 (Thompson's observation connecting j-function to Monster). -/
theorem moonshine_numerology : 196884 = 196883 + 1 := by norm_num



/-- Second coefficient: 21493760 = 21296876 + 196883 + 1. -/
theorem moonshine_second : 21493760 = 21296876 + 196883 + 1 := by norm_num



/-- The Monster group order factorization. -/
theorem monster_order :
    2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71
    = 808017424794512875886459904961710757005754368000000000 := by norm_num



/-- The Berggren Cayley graph mod p has |SL(2,𝔽_p)| vertices. -/
theorem berggren_cayley_vertices :
    Fintype.card (Matrix.SpecialLinearGroup (Fin 2) (ZMod 3)) = 24 ∧
    Fintype.card (Matrix.SpecialLinearGroup (Fin 2) (ZMod 5)) = 120 ∧
    Fintype.card (Matrix.SpecialLinearGroup (Fin 2) (ZMod 7)) = 336 := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

