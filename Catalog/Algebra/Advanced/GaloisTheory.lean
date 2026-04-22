import Mathlib

/-! # CatalogBuild.Algebra.Advanced.GaloisTheory

Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8
-/


/-- [Section: # CatalogBuild.Algebra.Advanced.GaloisTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8] -/
theorem gf2_card : Fintype.card (ZMod 2) = 2 := by decide



/-- [Section: # CatalogBuild.Algebra.Advanced.GaloisTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8] -/
theorem gf3_card : Fintype.card (ZMod 3) = 3 := by decide




theorem frobenius_endomorphism' (p : ℕ) [Fact (Nat.Prime p)] (x : ZMod p) :
    x ^ p = x := ZMod.pow_card x




theorem cyclotomic_degree' (n : ℕ) :
    (cyclotomic n ℤ).natDegree = Nat.totient n :=
  Polynomial.natDegree_cyclotomic n ℤ




theorem cyclotomic_monic' (n : ℕ) : (cyclotomic n ℤ).Monic :=
  Polynomial.cyclotomic.monic n ℤ




theorem prod_cyclotomic' (n : ℕ) (hn : 0 < n) :
    ∏ d ∈ Nat.divisors n, cyclotomic d ℤ = X ^ n - 1 :=
  Polynomial.prod_cyclotomic_eq_X_pow_sub_one hn ℤ




theorem tower_degree' (F K L : Type*) [Field F] [Field K] [Field L]
    [Algebra F K] [Algebra K L] [Algebra F L] [IsScalarTower F K L]
    [FiniteDimensional F K] [FiniteDimensional K L] :
    Module.finrank F K * Module.finrank K L = Module.finrank F L :=
  Module.finrank_mul_finrank F K L




theorem complex_over_real_degree' : Module.finrank ℝ ℂ = 2 :=
  Complex.finrank_real_complex



