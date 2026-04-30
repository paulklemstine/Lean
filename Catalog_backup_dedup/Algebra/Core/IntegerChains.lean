import Mathlib

/-! # CatalogBuild.Pythagorean.Core.IntegerChains

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 17
-/

/-- [Section: # CatalogBuild.Pythagorean.Core.IntegerChains
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 17] -/
theorem chain_01_complete : ∀ n : ℤ,
    ((-(n : ℚ) + 1) ≠ 0 ∧ ∃ m : ℤ, twoPole 0 1 (n : ℚ) = (m : ℚ)) ↔
    (n = 0 ∨ n = 2 ∨ n = -1 ∨ n = 3) := by
      intro n; constructor <;> intro hn;
      · -- For the forward direction, if the denominator (-(n:ℚ)+1) ≠ 0 and twoPole 0 1 n = m for some integer m, then F(n) = (n+1)/(1-n). The denominator is 1-n, and for F(n) to be integer we need (1-n) | (n+1). Since (n+1) = -(1-n) + 2, we need (1-n) | 2. So 1-n ∈ {±1,±2}, giving n ∈ {0,2,-1,3}.
        obtain ⟨hn_ne_zero, ⟨m, hm⟩⟩ := hn
        have h_div : (1 - n) ∣ 2 := by
          unfold twoPole at hm;
          rw [ div_eq_iff ] at hm <;> norm_cast at *;
          · exact ⟨ m + 1, by norm_num [ Int.subNatNat_eq_coe ] at hm; linarith ⟩;
          · grind;
        have : 1 - n ≤ 2 := Int.le_of_dvd ( by decide ) h_div; ( have : 1 - n ≥ -2 := neg_le_of_abs_le ( Int.le_of_dvd ( by decide ) ( by rwa [ abs_dvd ] ) ) ; interval_cases _ : 1 - n <;> simp_all +decide );
        · exact Or.inr <| Or.inr <| Or.inr <| by linarith;
        · exact Or.inr <| Or.inl <| by linarith;
        · exact Or.inr <| Or.inr <| Or.inl <| by linarith;
      · rcases hn with ( rfl | rfl | rfl | rfl ) <;> norm_num [ twoPole ] <;> tauto

/-- [Section: # CatalogBuild.Pythagorean.Core.IntegerChains
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 17] -/
theorem chain_1_neg1_complete (n : ℤ) (hn : (n : ℚ) ≠ 0) :
    (∃ m : ℤ, twoPole 1 (-1) (n : ℚ) = (m : ℚ)) ↔ (n = 1 ∨ n = -1) := by
      unfold twoPole;
      norm_num +zetaDelta at *;
      constructor;
      · field_simp;
        exact fun ⟨ m, hm ⟩ => Int.eq_one_or_neg_one_of_mul_eq_neg_one <| by exact_mod_cast hm.symm;
      · rintro ( rfl | rfl ) <;> [ exact ⟨ -1, by norm_num ⟩ ; exact ⟨ 1, by norm_num ⟩ ]

theorem twoPole_02_at_0 : twoPole 0 2 0 = 2 := by
  norm_num [ twoPole ]

theorem twoPole_02_at_1 : twoPole 0 2 1 = -3 := by
  decide +kernel

theorem twoPole_02_at_neg2 : twoPole 0 2 (-2) = 0 := by
  unfold twoPole; norm_num

theorem twoPole_02_at_3 : twoPole 0 2 3 = -1 := by
  unfold twoPole; norm_num;

theorem twoPole_03_at_0 : twoPole 0 3 0 = 3 := by
  decide +kernel

theorem twoPole_03_at_2 : twoPole 0 3 2 = -1 := by
  norm_num [ twoPole ]

theorem twoPole_03_at_neg3 : twoPole 0 3 (-3) = 0 := by
  decide +kernel

theorem twoPole_03_at_1 : twoPole 0 3 1 = -2 := by
  decide +kernel

theorem twoPole_12_at_2 : twoPole 1 2 2 = 7 := by
  -- Let's simplify the expression for $F_{1,2}(2)$.
  norm_num [twoPole]

theorem twoPole_12_at_4 : twoPole 1 2 4 = -13 := by
  -- Substitute a=1 and b=2 into the twoPole function and simplify.
  norm_num [ twoPole ]

theorem twoPole_12_at_neg2 : twoPole 1 2 (-2) = -1 := by
  exact show ( ( 1 * 2 + 1 ) * ( -2 ) + ( 2 - 1 ) ) / ( ( 1 - 2 ) * ( -2 ) + ( 1 * 2 + 1 ) ) = -1 from by norm_num;

theorem twoPole_12_at_5 : twoPole 1 2 5 = -8 := by
  rw [ twoPole ] ; norm_num

theorem twoPole_12_at_neg7 : twoPole 1 2 (-7) = -2 := by
  decide +kernel

theorem twoPole_12_at_8 : twoPole 1 2 8 = -5 := by
  unfold twoPole; norm_num;

theorem twoPole_12_at_13 : twoPole 1 2 13 = -4 := by
  norm_num [ twoPole ]

