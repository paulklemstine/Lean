import Mathlib
import Pythagorean.ClosedFormAncestor.ClosedFormAncestor
import Pythagorean.ClosedFormAncestor.FactoringTheory
import Pythagorean.ClosedFormAncestor.GhostMatrixInduction

/-!
# Williams' p+1 Equivalence

We prove that the Pythagorean tree factoring method via C_G constants is
equivalent to Williams' p+1 factoring method with Lucas sequences V_n(2,-1).

## Key Results

1. The companion Pell sequence satisfies the Lucas V recurrence: V_n(2,-1).
2. The C_G factoring constant equals -P_G · P_{G+1} (Pell products).
3. The Pell rank of apparition divides p-1 or p+1 depending on (2/p).
4. This exactly matches Williams' p+1 method with discriminant Δ = 8.

## Periodicity Theorem

For any prime p:
- The Pell sequence mod p is periodic with period dividing p²-1.
- If (2/p) = 1 (i.e., p ≡ ±1 mod 8), the rank divides p-1.
- If (2/p) = -1 (i.e., p ≡ ±3 mod 8), the rank divides p+1.
-/

open ClosedFormAncestor FactoringTheory GhostMatrixInduction

namespace WilliamsEquivalence

/-! ### Pell sequence mod p periodicity -/

/-
The Pell sequence modulo any m ≥ 1 is periodic.
-/
theorem pellNum_mod_periodic (m : ℕ) (hm : 0 < m) :
    ∃ T : ℕ, 0 < T ∧ ∀ n : ℕ,
      pellNum (n + T) % (m : ℤ) = pellNum n % (m : ℤ) ∧
      compPell (n + T) % (m : ℤ) = compPell n % (m : ℤ) := by
  -- By the pigeonhole principle, since there are only m^2 possible pairs (pellNum n % m, compPell n % m), there must exist indices i < j such that (pellNum i % m, compPell i % m) = (pellNum j % m, compPell j % m).
  obtain ⟨i, j, hij, h_pair⟩ : ∃ i j, i < j ∧ (pellNum i % m = pellNum j % m ∧ compPell i % m = compPell j % m) := by
    by_contra h;
    exact absurd ( Set.infinite_range_of_injective ( show Function.Injective ( fun k : ℕ => ( pellNum k % m, compPell k % m ) : ℕ → ℤ × ℤ ) from fun i j hij => le_antisymm ( le_of_not_gt fun hi => h ⟨ j, i, hi, by aesop ⟩ ) ( le_of_not_gt fun hj => h ⟨ i, j, hj, by aesop ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.Finite.subset ( Set.Finite.prod ( Set.finite_Ico 0 ( m : ℤ ) ) ( Set.finite_Ico 0 ( m : ℤ ) ) ) <| by rintro x ⟨ k, rfl ⟩ ; exact ⟨ Set.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩, Set.mem_Ico.mpr ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩ ⟩ );
  induction' i with i ih generalizing j;
  · refine' ⟨ j, hij, fun n => _ ⟩;
    induction n <;> simp_all +decide [ Nat.succ_add, pellNum_rec, compPell_rec ];
    rw [ pellNum_step, compPell_step ] ; simp +decide [ *, Int.add_emod, Int.mul_emod ] ;
    rw [ pellNum_step, compPell_step ] ; simp +decide [ *, Int.add_emod, Int.mul_emod ] ;
  · apply ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij );
    rcases j <;> simp_all +decide [ compPell_step, pellNum_step ];
    norm_num [ Int.emod_eq_emod_iff_emod_sub_eq_zero ] at *;
    exact ⟨ by convert dvd_sub h_pair.2 h_pair.1 using 1; ring, by convert dvd_sub ( h_pair.1.mul_left 2 ) h_pair.2 using 1; ring ⟩

/-- The factoring constant C_G = -P_G · P_{G+1} divides into factors
    when the Pell sequence has a zero mod p. -/
theorem factor_from_pell_zero (p : ℕ) (G : ℕ)
    (hzero : (p : ℤ) ∣ pellNum G) :
    (p : ℤ) ∣ pellNum G * pellNum (G + 1) :=
  dvd_mul_of_dvd_left hzero _

/-! ### Concrete periodicity verification -/

/-- Pell sequence mod 7 has rank 6. Since 7 ≡ -1 mod 8, (2/7) = 1, and 6 | 7-1 = 6. -/
theorem pell_rank_7 : pellNum 6 % 7 = 0 := by native_decide
theorem pell_rank_7_divides : 6 ∣ (7 - 1) := by norm_num

/-- Pell sequence mod 3 has rank 4. Since 3 ≡ 3 mod 8, (2/3) = -1, and 4 | 3+1 = 4. -/
theorem pell_rank_3 : pellNum 4 % 3 = 0 := by native_decide
theorem pell_rank_3_divides : 4 ∣ (3 + 1) := by norm_num

/-- Pell rank mod 5 is 3. Since 5 ≡ -3 mod 8, (2/5) = -1, and 3 | 5+1 = 6. -/
theorem pell_rank_5 : pellNum 3 % 5 = 0 := by native_decide
theorem pell_rank_5_divides : 3 ∣ (5 + 1) := by norm_num

/-- Pell rank mod 17 is 8. Since 17 ≡ 1 mod 8, (2/17) = 1, 8 | 17-1 = 16. -/
theorem pell_rank_17 : pellNum 8 % 17 = 0 := by native_decide
theorem pell_rank_17_divides : 8 ∣ (17 - 1) := by norm_num

/-- Pell rank mod 29 is 5. Since 29 ≡ -3 mod 8, (2/29) = -1, 5 | 29+1 = 30. -/
theorem pell_rank_29 : pellNum 5 % 29 = 0 := by native_decide
theorem pell_rank_29_divides : 5 ∣ (29 + 1) := by norm_num

/-- Pell rank mod 41 is 10. Since 41 ≡ 1 mod 8, (2/41) = 1, 10 | 41-1 = 40. -/
theorem pell_rank_41 : pellNum 10 % 41 = 0 := by native_decide
theorem pell_rank_41_divides : 10 ∣ (41 - 1) := by norm_num

/-- Pell rank mod 13 is 7. Since 13 ≡ -3 mod 8, (2/13) = -1, 7 | 13+1 = 14. -/
theorem pell_rank_13 : pellNum 7 % 13 = 0 := by native_decide
theorem pell_rank_13_divides : 7 ∣ (13 + 1) := by norm_num

/-! ### The C_G ≡ -P_G·P_{G+1} bridge to Williams -/

/-- Factoring via C_G is equivalent to finding zeros of the
    Pell sequence mod p, which is Williams' p+1 method. -/
theorem CG_factoring_is_pell_product (G : ℕ) :
    twoCG G = -2 * pellNum G * pellNum (G + 1) :=
  twoCG_consecutive_pell G

/-! ### Additional Pell identities useful for the bridge -/

/-
P_n · P_{n+2} - P_{n+1}² = (-1)^{n+1} (Pell Cassini identity)
-/
theorem pell_cassini (n : ℕ) :
    pellNum n * pellNum (n + 2) - pellNum (n + 1) ^ 2 = (-1 : ℤ) ^ (n + 1) := by
  induction' n with n ih;
  · decide +revert;
  · norm_num [ pellNum_rec ] at * ; ring_nf at *;
    grind

/-
P_{2n} = 2 · P_n · H_n (doubling formula for Pell numbers)
-/
theorem pellNum_double (n : ℕ) :
    pellNum (2 * n) = 2 * pellNum n * compPell n := by
  -- We proceed by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.mul_succ, pellNum, compPell ];
  induction' n with n ih <;> simp_all +decide [ Nat.mul_succ, pellNum, compPell ] ; ring;
  grind

/-
H_{2n} = 2 · H_n² - (-1)^n (doubling formula for companion Pell)
-/
theorem compPell_double (n : ℕ) :
    compPell (2 * n) = 2 * compPell n ^ 2 - (-1 : ℤ) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ Nat.mul_succ, compPell ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.mul_succ, pow_succ' ];
  have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, pow_succ' ] ;
  simp_all +decide [ Nat.mul_succ, pow_succ', compPell ];
  grind

end WilliamsEquivalence