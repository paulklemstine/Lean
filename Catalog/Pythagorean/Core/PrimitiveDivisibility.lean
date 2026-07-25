import Mathlib

/-! # CatalogBuild.Pythagorean.Core.PrimitiveDivisibility

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 5
-/

/-- [Section: # CatalogBuild.Pythagorean.Core.PrimitiveDivisibility
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 5] -/
theorem sq_mod5 (n : ℤ) : n ^ 2 % 5 = 0 ∨ n ^ 2 % 5 = 1 ∨ n ^ 2 % 5 = 4 := by
  rw [ sq, Int.mul_emod ] ; have := Int.emod_nonneg n ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos n ( by decide : ( 5 : ℤ ) > 0 ) ; interval_cases n % 5 <;> trivial;

/-- [Section: # CatalogBuild.Pythagorean.Core.PrimitiveDivisibility
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 5] -/
theorem pyth_div5 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    5 ∣ a ∨ 5 ∣ b ∨ 5 ∣ c := by
  exact Classical.or_iff_not_imp_left.2 fun ha => Classical.or_iff_not_imp_left.2 fun hb => by rw [ Int.dvd_iff_emod_eq_zero ] at *; have := congr_arg ( · % 5 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this; have := Int.emod_nonneg a ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg b ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos b ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 5 : ℤ ) > 0 ) ; interval_cases a % 5 <;> interval_cases b % 5 <;> interval_cases c % 5 <;> trivial;

theorem pyth_div3' {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 ∣ a ∨ 3 ∣ b := by
  rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ];
  have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial

theorem pyth_div2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 ∣ a ∨ 2 ∣ b := by
  contrapose! h;
  exact ne_of_apply_ne ( · % 4 ) ( by rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf <;> norm_num [ Int.add_emod, Int.mul_emod ] at * )

theorem pyth_60_div_abc {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    60 ∣ a * b * c := by
  have h60 : 60 ∣ a * b * c := by
    have h12 : 12 ∣ a * b := by
      -- Since $2 \mid a$ or $2 \mid b$, and $3 \mid a$ or $3 \mid b$, it follows that $12 \mid a * b$.
      have h_div_12 : 4 ∣ a * b ∧ 3 ∣ a * b := by
        have h_div_4 : 4 ∣ a * b := by
          rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> ring_nf;
          · norm_num;
          · rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> ( ( have aux := congr_arg Even h ; norm_num [ parity_simps ] at aux; ) );
            · exact ⟨ a + a * b * 2, by ring ⟩;
            · grind +suggestions;
          · rcases Int.even_or_odd' b with ⟨ k, rfl | rfl ⟩ <;> ring_nf at *;
            · exact ⟨ a * k * 2 + k, by ring ⟩;
            · exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg a ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; have := Int.emod_lt_of_pos a ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> interval_cases a % 8 <;> trivial );
          · exact absurd ( congr_arg ( · % 4 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.mul_emod, sq ] ; have := Int.emod_nonneg c four_pos.ne'; have := Int.emod_lt_of_pos c four_pos; interval_cases c % 4 <;> trivial )
        have h_div_3 : 3 ∣ a * b := by
          exact Int.dvd_of_emod_eq_zero ( by have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this ⊢; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial )
        exact ⟨h_div_4, h_div_3⟩;
      exact dvd_trans ( by decide ) ( Int.coe_lcm_dvd h_div_12.1 h_div_12.2 )
    have h5 : 5 ∣ a * b * c := by
      exact Int.dvd_of_emod_eq_zero ( by have := congr_arg ( · % 5 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this ⊢; have := Int.emod_nonneg a ( by norm_num : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg b ( by norm_num : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by norm_num : 0 < ( 5 : ℤ ) ) ; have := Int.emod_lt_of_pos b ( by norm_num : 0 < ( 5 : ℤ ) ) ; have := Int.emod_lt_of_pos c ( by norm_num : 0 < ( 5 : ℤ ) ) ; interval_cases a % 5 <;> interval_cases b % 5 <;> interval_cases c % 5 <;> trivial )
    exact dvd_trans ( by decide ) ( Int.coe_lcm_dvd ( dvd_mul_of_dvd_left h12 c ) h5 );
  assumption