/-! # CatalogBuild.Algebra.Factoring.FactoringTheory

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 28
-/

import Mathlib
import Pythagorean.ClosedFormAncestor.ClosedFormAncestor

/-- 2·C_G = -(H² + 2PH - ε). -/
def twoCG (G : ℕ) : ℤ :=
  -(compPell G ^ 2 + 2 * pellNum G * compPell G - (-1 : ℤ) ^ G)


/-- twoCG(G) = -2·P·(P+H), using the Pell identity H²-2P²=(-1)^G. -/
theorem twoCG_factored (G : ℕ) :
    twoCG G = -2 * pellNum G * (pellNum G + compPell G) := by
  unfold twoCG
  have h := pell_sq_identity G
  nlinarith [sq_nonneg (compPell G), sq_nonneg (pellNum G)]


/-- Joint induction: P_n + H_n = P_{n+1} and H_{n+1} = P_{n+1} + P_n. -/
theorem pell_plus_comp (n : ℕ) :
    pellNum n + compPell n = pellNum (n + 1) :=
  (pell_comp_both n).1


/-- twoCG(G) = -2·P_G·P_{G+1}. -/
theorem twoCG_consecutive_pell (G : ℕ) :
    twoCG G = -2 * pellNum G * pellNum (G + 1) := by
  rw [twoCG_factored, pell_plus_comp]

-- Concrete values


/-- [Section: # Factoring Theory via Pythagorean Tree Ancestry
KEY RESULT: The factoring constant C_G = -P_G · P_{G+1} where P_n are Pell numbers.
Finding gcd(P_G · P_{G+1}, N) > 1 yields a factor of N.] -/
theorem twoCG_1 : twoCG 1 = -4 := by native_decide


/-- [Section: # CatalogBuild.Pythagorean.ClosedFormAncestor.FactoringTheory
Auto-generated from theorem catalog database.
Domain: Pythagorean/ClosedFormAncestor
Declarations: 28] -/
theorem twoCG_2 : twoCG 2 = -20 := by native_decide


theorem twoCG_3 : twoCG 3 = -120 := by native_decide


theorem twoCG_4 : twoCG 4 = -696 := by native_decide


theorem twoCG_5 : twoCG 5 = -4060 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 2: N divides the leading terms
-- ═══════════════════════════════════════════════════════════════


/-- N divides the "non-constant" part of 2·p_G(N). -/
theorem two_p_G_leading_divisible (G : ℕ) (N : ℤ) :
    N ∣ (2 * compPell G ^ 2 * N +
         (compPell G ^ 2 - (-1 : ℤ) ^ G) * (N^2 - 1) -
         2 * pellNum G * compPell G * (N^2 + 1) -
         twoCG G) := by
  unfold twoCG
  refine ⟨2 * compPell G ^ 2 +
         (compPell G ^ 2 - (-1 : ℤ) ^ G - 2 * pellNum G * compPell G) * N, ?_⟩
  ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Concrete Factoring Verifications
-- ═══════════════════════════════════════════════════════════════

-- Pell products: P_G · P_{G+1}
-- G=1: 1·2 = 2     → factors of 2
-- G=2: 2·5 = 10    → factors of {2,5}
-- G=3: 5·12 = 60   → factors of {2,3,4,5,6,10,12,15,20,30,60}
-- G=4: 12·29 = 348 → factors of {2,3,4,6,12,29,58,87,116,174,348}
-- G=5: 29·70 = 2030 → factors of {2,5,7,10,14,29,35,58,70,...}

-- Direct Pell product factoring checks


theorem pell_product_1 : pellNum 1 * pellNum 2 = 2 := by native_decide


theorem pell_product_2 : pellNum 2 * pellNum 3 = 10 := by native_decide


theorem pell_product_3 : pellNum 3 * pellNum 4 = 60 := by native_decide


theorem pell_product_4 : pellNum 4 * pellNum 5 = 348 := by native_decide


theorem pell_product_5 : pellNum 5 * pellNum 6 = 2030 := by native_decide


theorem pell_product_6 : pellNum 6 * pellNum 7 = 11830 := by native_decide

-- GCD-based factoring


theorem gcd_factor_15 :
    Nat.gcd (pellNum 2 * pellNum 3).natAbs 15 = 5 := by native_decide


theorem gcd_factor_21 :
    Nat.gcd (pellNum 3 * pellNum 4).natAbs 21 = 3 := by native_decide


theorem gcd_factor_77 :
    Nat.gcd (pellNum 5 * pellNum 6).natAbs 77 = 7 := by native_decide


theorem gcd_factor_221 :
    Nat.gcd (pellNum 6 * pellNum 7).natAbs 221 = 13 := by native_decide


theorem gcd_factor_899 :
    Nat.gcd (pellNum 4 * pellNum 5).natAbs 899 = 29 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Connection to Williams' p+1
-- ═══════════════════════════════════════════════════════════════


/-- The factoring succeeds when the Pell sequence mod p hits zero.
The "rank of apparition" of p in the Pell sequence — the smallest k
with P_k ≡ 0 (mod p) — divides p-1 when (2/p)=1 and p+1 when (2/p)=-1.
This is exactly the condition in Williams' p+1 method with discriminant 8.
The following are concrete verifications that P_{T(p)} ≡ 0 (mod p). -/
theorem pell_zero_mod_3 : pellNum 4 % 3 = 0 := by native_decide  -- P_4 = 12


theorem pell_zero_mod_5 : pellNum 3 % 5 = 0 := by native_decide  -- P_3 = 5


theorem pell_zero_mod_7 : pellNum 6 % 7 = 0 := by native_decide  -- P_6 = 70


theorem pell_zero_mod_11 : pellNum 12 % 11 = 0 := by native_decide


theorem pell_zero_mod_13 : pellNum 7 % 13 = 0 := by native_decide -- P_7 = 169


theorem pell_zero_mod_17 : pellNum 8 % 17 = 0 := by native_decide -- P_8 = 408


theorem pell_zero_mod_29 : pellNum 5 % 29 = 0 := by native_decide -- P_5 = 29


