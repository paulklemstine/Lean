import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.KTuples

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 2
-/

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.KTuples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 2] -/
theorem ktuple_factor_identity {k : ℕ} (v : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (_h : IsPythagoreanKTuple v d) :
    (d - v j) * (d + v j) = ∑ i ∈ Finset.univ.erase j, (v i)^2 := by
  simp_all +decide [ IsPythagoreanKTuple, mul_comm ];
  ring

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.KTuples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 2] -/
theorem ktuple_even_hypotenuse_sq_div4 {k : ℕ} (v : Fin k → ℤ) (d : ℤ)
    (h : IsPythagoreanKTuple v d) (heven : 2 ∣ d) :
    4 ∣ ∑ i, (v i)^2 := by
  exact h.symm ▸ pow_dvd_pow_of_dvd heven 2

